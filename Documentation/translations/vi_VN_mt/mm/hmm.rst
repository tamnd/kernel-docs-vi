.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/hmm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Quản lý bộ nhớ không đồng nhất (HMM)
========================================

Cung cấp cơ sở hạ tầng và trợ giúp để tích hợp bộ nhớ không thông thường (thiết bị
bộ nhớ như GPU trên bộ nhớ bo mạch) vào đường dẫn kernel thông thường, với nền tảng
đây là trang cấu trúc chuyên dụng cho bộ nhớ đó (xem phần 5 đến 7 của
tài liệu này).

HMM cũng cung cấp các trình trợ giúp tùy chọn cho SVM (Chia sẻ bộ nhớ ảo), tức là
cho phép một thiết bị truy cập một cách minh bạch các địa chỉ chương trình một cách mạch lạc với
CPU có nghĩa là bất kỳ con trỏ hợp lệ nào trên CPU cũng là một con trỏ hợp lệ
cho thiết bị. Điều này đang trở thành bắt buộc để đơn giản hóa việc sử dụng các công cụ nâng cao
tính toán không đồng nhất trong đó GPU, DSP hoặc FPGA được sử dụng để thực hiện nhiều
tính toán thay mặt cho một quá trình.

Tài liệu này được chia như sau: trong phần đầu tiên tôi trình bày các vấn đề
liên quan đến việc sử dụng bộ cấp phát bộ nhớ dành riêng cho thiết bị. Trong phần thứ hai, tôi
bộc lộ những hạn chế về phần cứng vốn có của nhiều nền tảng. thứ ba
phần cung cấp cái nhìn tổng quan về thiết kế HMM. Phần thứ tư giải thích cách
Việc phản chiếu bảng trang CPU hoạt động và mục đích của HMM trong bối cảnh này. các
phần thứ năm đề cập đến cách thể hiện bộ nhớ thiết bị bên trong kernel.
Cuối cùng, phần cuối cùng trình bày một trình trợ giúp di chuyển mới cho phép
tận dụng động cơ DMA của thiết bị.

.. contents:: :local:

Các vấn đề khi sử dụng bộ cấp phát bộ nhớ dành riêng cho thiết bị
====================================================

Các thiết bị có dung lượng bộ nhớ trên bo mạch lớn (vài gigabyte) như GPU
trước đây đã quản lý bộ nhớ của họ thông qua các API dành riêng cho trình điều khiển.
Điều này tạo ra sự ngắt kết nối giữa bộ nhớ được thiết bị cấp phát và quản lý
trình điều khiển và bộ nhớ ứng dụng thông thường (bộ nhớ ẩn danh riêng tư, bộ nhớ dùng chung hoặc
bộ nhớ hỗ trợ tập tin thông thường). Từ đây trở đi tôi sẽ gọi khía cạnh này là sự phân chia
không gian địa chỉ. Tôi sử dụng không gian địa chỉ dùng chung để chỉ tình huống ngược lại:
tức là, một vùng trong đó bất kỳ vùng bộ nhớ ứng dụng nào cũng có thể được thiết bị sử dụng
một cách minh bạch.

Sự phân chia không gian địa chỉ xảy ra do các thiết bị chỉ có thể truy cập vào bộ nhớ được phân bổ
thông qua một thiết bị cụ thể API. Điều này ngụ ý rằng tất cả các đối tượng bộ nhớ trong một chương trình
không bằng nhau về mặt thiết bị, điều này làm phức tạp các chương trình lớn
dựa vào một bộ thư viện rộng lớn.

Cụ thể, điều này có nghĩa là mã muốn tận dụng các thiết bị như GPU cần
để sao chép các đối tượng giữa bộ nhớ được phân bổ chung (malloc, mmap riêng tư, mmap
chia sẻ) và bộ nhớ được phân bổ thông qua trình điều khiển thiết bị API (điều này vẫn kết thúc
bằng mmap nhưng bằng tệp thiết bị).

Đối với các tập dữ liệu phẳng (mảng, lưới, hình ảnh, ...), điều này không quá khó để đạt được nhưng
đối với các tập dữ liệu phức tạp (danh sách, cây, ...) thật khó để làm đúng. Nhân bản một
tập dữ liệu phức tạp cần ánh xạ lại tất cả các quan hệ con trỏ giữa mỗi quan hệ của nó
các phần tử. Điều này dễ xảy ra lỗi và các chương trình khó gỡ lỗi hơn do
tập dữ liệu và địa chỉ trùng lặp.

Chia không gian địa chỉ cũng có nghĩa là các thư viện không thể sử dụng dữ liệu một cách minh bạch
họ đang lấy từ chương trình cốt lõi hoặc thư viện khác và do đó mỗi thư viện
có thể phải sao chép tập dữ liệu đầu vào của nó bằng bộ nhớ dành riêng cho thiết bị
người cấp phát. Các dự án lớn gặp phải tình trạng này và lãng phí tài nguyên vì
bản sao bộ nhớ khác nhau.

Sao chép từng thư viện API để chấp nhận làm bộ nhớ đầu vào hoặc đầu ra được phân bổ bởi
mỗi bộ cấp phát cụ thể của thiết bị không phải là một lựa chọn khả thi. Nó sẽ dẫn đến một
vụ nổ tổ hợp tại các điểm vào thư viện.

Cuối cùng, với sự tiến bộ của các cấu trúc ngôn ngữ cấp cao (trong C++ nhưng trong
các ngôn ngữ khác nữa), giờ đây trình biên dịch có thể tận dụng GPU và
các thiết bị khác mà không có kiến thức về lập trình viên. Một số mẫu được xác định của trình biên dịch
chỉ có thể thực hiện được với một không gian địa chỉ được chia sẻ. Sử dụng cũng hợp lý hơn
một không gian địa chỉ dùng chung cho tất cả các mẫu khác.


Bus I/O, đặc điểm bộ nhớ thiết bị
======================================

Các bus I/O làm tê liệt không gian địa chỉ dùng chung do một số hạn chế. Hầu hết I/O
xe buýt chỉ cho phép truy cập bộ nhớ cơ bản từ thiết bị đến bộ nhớ chính; thậm chí bộ nhớ đệm
tính mạch lạc thường là tùy chọn. Truy cập vào bộ nhớ thiết bị từ CPU thậm chí còn nhiều hơn thế
hạn chế. Thông thường, nó không được kết hợp chặt chẽ với bộ nhớ đệm.

Nếu chúng ta chỉ xem xét bus PCIE thì một thiết bị có thể truy cập bộ nhớ chính (thường
thông qua IOMMU) và được kết hợp bộ đệm với CPU. Tuy nhiên nó chỉ cho phép
một tập hợp giới hạn các hoạt động nguyên tử từ thiết bị trên bộ nhớ chính. Điều này còn tệ hơn
theo hướng khác: CPU chỉ có thể truy cập một phạm vi giới hạn của thiết bị
bộ nhớ và không thể thực hiện các hoạt động nguyên tử trên nó. Do đó bộ nhớ thiết bị không thể
được coi giống như bộ nhớ thông thường theo quan điểm kernel.

Một yếu tố gây tê liệt khác là băng thông hạn chế (~32GBytes/s với PCIE 4.0
và 16 làn xe). Con số này ít hơn 33 lần so với bộ nhớ GPU nhanh nhất (1 TByte/s).
Hạn chế cuối cùng là độ trễ. Quyền truy cập vào bộ nhớ chính từ thiết bị có
có độ trễ cao hơn so với khi thiết bị truy cập vào bộ nhớ của chính nó.

Một số nền tảng đang phát triển các bus I/O mới hoặc bổ sung/sửa đổi cho PCIE
để giải quyết một số hạn chế này (OpenCAPI, CCIX). Họ chủ yếu cho phép
sự kết hợp bộ đệm hai chiều giữa CPU và thiết bị và cho phép tất cả các hoạt động nguyên tử
kiến trúc hỗ trợ. Đáng buồn thay, không phải tất cả các nền tảng đều theo xu hướng này và
một số kiến trúc chính vẫn chưa có giải pháp phần cứng cho những vấn đề này.

Vì vậy, để không gian địa chỉ dùng chung có ý nghĩa, chúng ta không chỉ phải cho phép các thiết bị
truy cập bất kỳ bộ nhớ nào nhưng chúng tôi cũng phải cho phép mọi bộ nhớ được di chuyển sang thiết bị
bộ nhớ trong khi thiết bị đang sử dụng nó (chặn truy cập CPU khi điều đó xảy ra).


Không gian địa chỉ được chia sẻ và di chuyển
==================================

HMM dự định cung cấp hai tính năng chính. Đầu tiên là chia sẻ địa chỉ
khoảng trống bằng cách sao chép bảng trang CPU trong bảng trang thiết bị sao cho giống nhau
địa chỉ trỏ đến cùng một bộ nhớ vật lý cho bất kỳ địa chỉ bộ nhớ chính hợp lệ nào trong
không gian địa chỉ tiến trình.

Để đạt được điều này, HMM cung cấp một bộ công cụ trợ giúp để điền vào bảng trang thiết bị
trong khi theo dõi các cập nhật bảng trang CPU. Cập nhật bảng trang thiết bị là
không dễ dàng như cập nhật bảng trang CPU. Để cập nhật bảng trang thiết bị, bạn phải
phân bổ bộ đệm (hoặc sử dụng nhóm bộ đệm được phân bổ trước) và viết GPU
các lệnh cụ thể trong đó để thực hiện cập nhật (hủy bản đồ, vô hiệu hóa bộ đệm và
xả nước,...). Điều này không thể thực hiện được thông qua mã chung cho tất cả các thiết bị. Do đó
tại sao HMM cung cấp những người trợ giúp để xác định mọi thứ có thể xảy ra khi rời khỏi
chi tiết cụ thể về phần cứng cho trình điều khiển thiết bị.

Cơ chế thứ hai mà HMM cung cấp là một loại bộ nhớ ZONE_DEVICE mới.
cho phép cấp phát một trang cấu trúc cho mỗi trang của bộ nhớ thiết bị. Những trang đó
rất đặc biệt vì CPU không thể ánh xạ chúng. Tuy nhiên, họ cho phép di chuyển
bộ nhớ chính sang bộ nhớ thiết bị bằng cách sử dụng các cơ chế di chuyển hiện có và mọi thứ
trông giống như một trang được hoán đổi sang đĩa theo quan điểm CPU. Sử dụng một
trang struct mang lại sự tích hợp dễ dàng và rõ ràng nhất với mm hiện có
cơ chế. Một lần nữa, HMM chỉ cung cấp người trợ giúp, đầu tiên là cắm nóng ZONE_DEVICE mới
bộ nhớ dành cho bộ nhớ thiết bị và bộ nhớ thứ hai để thực hiện di chuyển. Quyết định chính sách
việc di chuyển nội dung gì và khi nào được giao cho trình điều khiển thiết bị.

Lưu ý rằng mọi quyền truy cập CPU vào trang thiết bị sẽ gây ra lỗi trang và di chuyển
trở lại bộ nhớ chính. Ví dụ: khi một trang sao lưu địa chỉ A CPU nhất định là
được di chuyển từ trang bộ nhớ chính sang trang thiết bị, sau đó mọi quyền truy cập CPU vào
địa chỉ A gây ra lỗi trang và bắt đầu di chuyển trở lại bộ nhớ chính.

Với hai tính năng này, HMM không chỉ cho phép thiết bị phản ánh địa chỉ quy trình
không gian và giữ cho cả bảng trang CPU và thiết bị được đồng bộ hóa, nhưng cũng
tận dụng bộ nhớ thiết bị bằng cách di chuyển phần tập dữ liệu đang được tích cực
được sử dụng bởi thiết bị.


Triển khai phản ánh không gian địa chỉ và API
==============================================

Mục tiêu chính của phản ánh không gian địa chỉ là cho phép sao chép một phạm vi
bảng trang CPU thành bảng trang thiết bị; HMM giúp cả hai được đồng bộ hóa. A
trình điều khiển thiết bị muốn phản chiếu không gian địa chỉ quy trình phải bắt đầu bằng
đăng ký mmu_interval_notifier::

int mmu_interval_notifier_insert(struct mmu_interval_notifier *interval_sub,
				  struct mm_struct *mm, khởi đầu dài không dấu,
				  chiều dài không dấu,
				  const struct mmu_interval_notifier_ops *ops);

Trong quá trình gọi lại ops->invalidate() trình điều khiển thiết bị phải thực hiện
cập nhật hành động cho phạm vi (đánh dấu phạm vi chỉ đọc hoặc hủy ánh xạ hoàn toàn, v.v.). các
thiết bị phải hoàn tất cập nhật trước khi lệnh gọi lại trình điều khiển quay trở lại.

Khi trình điều khiển thiết bị muốn điền vào một dải địa chỉ ảo, nó có thể
sử dụng::

int hmm_range_fault(struct hmm_range *range);

Nó sẽ gây ra lỗi trang đối với các mục bị thiếu hoặc chỉ đọc nếu quyền truy cập ghi bị hạn chế.
yêu cầu (xem bên dưới). Lỗi trang chỉ sử dụng đường dẫn mã lỗi trang mm chung
giống như lỗi trang CPU. Mô hình sử dụng là::

int driver_populate_range(...)
 {
      phạm vi cấu trúc hmm_range;
      ...

range.notifier = &interval_sub;
      phạm vi.start = ...;
      phạm vi.end = ...;
      phạm vi.hmm_pfns = ...;

if (!mmget_not_zero(interval_sub->notifier.mm))
          trả về -EFAULT;

một lần nữa:
      range.notifier_seq = mmu_interval_read_begin(&interval_sub);
      mmap_read_lock(mm);
      ret = hmm_range_fault(&range);
      nếu (ret) {
          mmap_read_unlock(mm);
          nếu (ret == -EBUSY)
                 đi lại lần nữa;
          trở lại ret;
      }
      mmap_read_unlock(mm);

take_lock(trình điều khiển->cập nhật);
      if (mmu_interval_read_retry(&ni, range.notifier_seq) {
          Release_lock(trình điều khiển->cập nhật);
          đi lại lần nữa;
      }

/* Sử dụng nội dung mảng pfns để cập nhật bảng trang thiết bị,
       *dưới khóa cập nhật */

Release_lock(trình điều khiển->cập nhật);
      trả về 0;
 }

Khóa trình điều khiển->cập nhật là khóa tương tự mà trình điều khiển sử dụng bên trong nó.
gọi lại không hợp lệ(). Khóa đó phải được giữ trước khi gọi
mmu_interval_read_retry() để tránh mọi cuộc đua với bảng trang CPU đồng thời
cập nhật.

Tận dụng default_flags và pfn_flags_mask
=========================================

Cấu trúc hmm_range có 2 trường, default_flags và pfn_flags_mask, chỉ định
chính sách lỗi hoặc ảnh chụp nhanh cho toàn bộ phạm vi thay vì phải đặt chúng
cho mỗi mục trong mảng pfns.

Ví dụ: nếu trình điều khiển thiết bị muốn các trang có phạm vi ít nhất được đọc
sự cho phép, nó đặt::

phạm vi->default_flags = HMM_PFN_REQ_FAULT;
    phạm vi->pfn_flags_mask = 0;

và gọi hmm_range_fault() như mô tả ở trên. Điều này sẽ lấp đầy lỗi tất cả các trang
trong phạm vi có ít nhất quyền đọc.

Bây giờ, giả sử trình điều khiển muốn thực hiện tương tự ngoại trừ một trang trong phạm vi dành cho
mà nó muốn có quyền viết. Bây giờ bộ trình điều khiển::

phạm vi->default_flags = HMM_PFN_REQ_FAULT;
    phạm vi->pfn_flags_mask = HMM_PFN_REQ_WRITE;
    phạm vi->pfns[index_of_write] = HMM_PFN_REQ_WRITE;

Với điều này, HMM sẽ báo lỗi ở tất cả các trang có ít nhất là đã đọc (tức là hợp lệ) và đối với
địa chỉ == phạm vi->bắt đầu + (index_of_write << PAGE_SHIFT) nó sẽ bị lỗi
quyền ghi, tức là nếu pte CPU không có quyền ghi thì HMM
sẽ gọi hàm xử lý_mm_fault().

Sau khi hmm_range_fault hoàn thành, các bit cờ được đặt ở trạng thái hiện tại là
các bảng trang, tức là HMM_PFN_VALID | HMM_PFN_WRITE sẽ được đặt nếu trang được
có thể ghi được.


Trình bày và quản lý bộ nhớ thiết bị theo quan điểm lõi lõi
=================================================================

Một số thiết kế khác nhau đã được thử để hỗ trợ bộ nhớ thiết bị. cái đầu tiên
đã sử dụng cấu trúc dữ liệu dành riêng cho thiết bị để lưu giữ thông tin về bộ nhớ đã di chuyển
và HMM tự nối vào nhiều vị trí khác nhau của mã mm để xử lý mọi quyền truy cập vào
địa chỉ được hỗ trợ bởi bộ nhớ thiết bị. Hóa ra chuyện này đã kết thúc
sao chép hầu hết các trường của trang cấu trúc và cũng cần nhiều mã kernel
đường dẫn được cập nhật để hiểu loại bộ nhớ mới này.

Hầu hết các đường dẫn mã hạt nhân không bao giờ thử truy cập vào bộ nhớ phía sau một trang
nhưng chỉ quan tâm đến nội dung trang struct. Vì điều này, HMM đã chuyển sang
trực tiếp sử dụng trang struct cho bộ nhớ thiết bị để lại hầu hết các đường dẫn mã kernel
không biết về sự khác biệt. Chúng ta chỉ cần đảm bảo rằng không ai từng cố gắng
ánh xạ các trang đó từ phía CPU.

Di chuyển đến và đi từ bộ nhớ thiết bị
===================================

Vì CPU không thể truy cập trực tiếp vào bộ nhớ thiết bị nên trình điều khiển thiết bị phải
sử dụng phần cứng DMA hoặc hướng dẫn tải/lưu trữ cụ thể của thiết bị để di chuyển dữ liệu.
Migrate_vma_setup(), di chuyển_vma_pages() và di chuyển_vma_finalize()
các chức năng được thiết kế để làm cho trình điều khiển dễ viết hơn và tập trung các chức năng chung
mã trên các trình điều khiển.

Trước khi di chuyển các trang sang bộ nhớ riêng của thiết bị, quyền riêng tư của thiết bị đặc biệt
ZZ0000ZZ cần được tạo. Chúng sẽ được sử dụng như một "trao đổi" đặc biệt
các mục trong bảng trang để quá trình CPU sẽ bị lỗi nếu nó cố truy cập
một trang đã được di chuyển sang bộ nhớ riêng của thiết bị.

Chúng có thể được phân bổ và giải phóng với ::

tài nguyên cấu trúc *res;
    sơ đồ trang struct dev_pagemap;

res = request_free_mem_khu vực(&iomem_resource, /* số byte */,
                                  "tên tài nguyên trình điều khiển");
    pagemap.type = MEMORY_DEVICE_PRIVATE;
    pagemap.range.start = res->start;
    pagemap.range.end = res->end;
    pagemap.nr_range = 1;
    pagemap.ops = &device_devmem_ops;
    memremap_pages(&pagemap, numa_node_id());

memunmap_pages(&pagemap);
    phát hành_mem_khu vực(pagemap.range.start, range_len(&pagemap.range));

Ngoài ra còn có devm_request_free_mem_khu vực(), devm_memremap_pages(),
devm_memunmap_pages() và devm_release_mem_zone() khi tài nguyên có thể
được gắn với ZZ0000ZZ.

Các bước di chuyển tổng thể tương tự như di chuyển các trang NUMA trong hệ thống
bộ nhớ (xem Documentation/mm/page_migration.rst) nhưng các bước được chia nhỏ
giữa mã cụ thể của trình điều khiển thiết bị và mã chung được chia sẻ:

1. ZZ0000ZZ

Trình điều khiển thiết bị phải chuyển ZZ0000ZZ tới
   Migrate_vma_setup() nên mmap_read_lock() hoặc mmap_write_lock() cần
   được giữ trong suốt thời gian di chuyển.

2. ZZ0000ZZ

Trình điều khiển thiết bị khởi tạo các trường ZZ0000ZZ và chuyển
   con trỏ tới Migrate_vma_setup(). Trường ZZ0001ZZ được sử dụng để
   lọc những trang nguồn nào sẽ được di chuyển. Ví dụ, thiết lập
   ZZ0002ZZ sẽ chỉ di chuyển bộ nhớ hệ thống và
   ZZ0003ZZ sẽ chỉ di chuyển các trang nằm trong
   bộ nhớ riêng của thiết bị. Nếu cờ sau được đặt, ZZ0004ZZ
   trường được sử dụng để xác định các trang riêng tư của thiết bị do trình điều khiển sở hữu. Cái này
   tránh cố gắng di chuyển các trang riêng tư của thiết bị nằm trong các thiết bị khác.
   Hiện tại chỉ có thể di chuyển các phạm vi VMA riêng tư ẩn danh đến hoặc từ
   bộ nhớ hệ thống và bộ nhớ riêng của thiết bị.

Một trong những bước đầu tiên Migrate_vma_setup() thực hiện là vô hiệu hóa các
   MMU của thiết bị với ZZ0000ZZ và
   ZZ0001ZZ gọi quanh bảng trang
   đi để điền vào mảng ZZ0002ZZ với các PFN sẽ được di chuyển.
   Cuộc gọi lại ZZ0003ZZ được thông qua
   ZZ0004ZZ với trường ZZ0005ZZ được đặt thành
   ZZ0006ZZ và trường ZZ0007ZZ được đặt thành
   trường ZZ0008ZZ được chuyển tới Migrate_vma_setup(). Cái này
   cho phép trình điều khiển thiết bị bỏ qua lệnh gọi lại vô hiệu và chỉ
   vô hiệu hóa ánh xạ MMU riêng tư của thiết bị đang thực sự di chuyển.
   Điều này sẽ được giải thích thêm ở phần tiếp theo.

Trong khi duyệt các bảng trang, ZZ0000ZZ hoặc ZZ0001ZZ
   mục nhập dẫn đến PFN "không" hợp lệ được lưu trữ trong mảng ZZ0002ZZ.
   Điều này cho phép trình điều khiển phân bổ bộ nhớ riêng của thiết bị và thay vào đó xóa nó
   sao chép một trang số không. Các mục nhập PTE hợp lệ vào bộ nhớ hệ thống hoặc
   các trang cấu trúc riêng tư của thiết bị sẽ bị khóa bằng ZZ0003ZZ, bị cô lập
   từ LRU (nếu bộ nhớ hệ thống vì các trang riêng tư của thiết bị không được bật
   LRU), chưa được ánh xạ khỏi quy trình và một quá trình di chuyển đặc biệt PTE được
   được chèn vào vị trí của PTE ban đầu.
   Migrate_vma_setup() cũng xóa mảng ZZ0004ZZ.

3. Trình điều khiển thiết bị phân bổ các trang đích và sao chép các trang nguồn vào
   các trang đích.

Trình điều khiển kiểm tra từng mục ZZ0000ZZ để xem ZZ0001ZZ có
   bit được đặt và bỏ qua các mục không di chuyển. Trình điều khiển thiết bị
   cũng có thể chọn bỏ qua việc di chuyển một trang bằng cách không điền vào ZZ0002ZZ
   mảng cho trang đó.

Sau đó, trình điều khiển sẽ phân bổ một trang cấu trúc riêng của thiết bị hoặc một trang
   trang bộ nhớ hệ thống, khóa trang bằng ZZ0000ZZ và điền vào
   Mục nhập mảng ZZ0001ZZ với::

dst[i] = di chuyển_pfn(page_to_pfn(dpage));

Bây giờ trình điều khiển đã biết rằng trang này đang được di chuyển, nó có thể
   vô hiệu hóa ánh xạ MMU riêng tư của thiết bị và sao chép bộ nhớ riêng của thiết bị
   vào bộ nhớ hệ thống hoặc trang riêng tư của thiết bị khác. Nhân Linux cốt lõi
   xử lý việc vô hiệu hóa bảng trang CPU nên trình điều khiển thiết bị chỉ phải
   vô hiệu hóa ánh xạ MMU của chính nó.

Người lái xe có thể sử dụng ZZ0000ZZ để lấy
   ZZ0001ZZ của nguồn và sao chép trang nguồn vào
   đích hoặc xóa bộ nhớ riêng của thiết bị đích nếu con trỏ
   là ZZ0002ZZ có nghĩa là trang nguồn không được đưa vào bộ nhớ hệ thống.

4. ZZ0000ZZ

Bước này là nơi quá trình di chuyển thực sự được "cam kết".

Nếu trang nguồn là trang ZZ0000ZZ hoặc ZZ0001ZZ thì trang này
   là nơi trang mới được cấp phát được chèn vào bảng trang của CPU.
   Điều này có thể thất bại nếu một chuỗi CPU bị lỗi trên cùng một trang. Tuy nhiên, trang
   bảng bị khóa và chỉ một trong các trang mới sẽ được chèn vào.
   Trình điều khiển thiết bị sẽ thấy bit ZZ0002ZZ bị xóa
   nếu nó thua cuộc đua.

Nếu trang nguồn bị khóa, cách ly, v.v. thì nguồn ZZ0000ZZ
   thông tin hiện được sao chép đến đích ZZ0001ZZ đang hoàn tất quá trình
   di chuyển về phía CPU.

5. Trình điều khiển thiết bị cập nhật bảng trang MMU của thiết bị cho các trang vẫn đang di chuyển,
   cuộn lại các trang không di chuyển.

Nếu mục ZZ0000ZZ vẫn có bộ bit ZZ0001ZZ, thiết bị
   trình điều khiển có thể cập nhật thiết bị MMU và đặt bit cho phép ghi nếu
   Bit ZZ0002ZZ được thiết lập.

6. ZZ0000ZZ

Bước này thay thế mục nhập bảng trang di chuyển đặc biệt bằng mục nhập mới
   mục nhập bảng trang của trang và giải phóng tham chiếu đến nguồn và
   đích ZZ0000ZZ.

7. ZZ0000ZZ

Bây giờ khóa có thể được mở.

Bộ nhớ truy cập độc quyền
=======================

Một số thiết bị có các tính năng như bit PTE nguyên tử có thể được sử dụng để thực hiện
truy cập nguyên tử vào bộ nhớ hệ thống. Để hỗ trợ các hoạt động nguyên tử cho một mạng ảo được chia sẻ
trang bộ nhớ, một thiết bị như vậy cần quyền truy cập vào trang đó không bao gồm bất kỳ
truy cập không gian người dùng từ CPU. Chức năng ZZ0000ZZ
có thể được sử dụng để làm cho phạm vi bộ nhớ không thể truy cập được từ không gian người dùng.

Điều này thay thế tất cả ánh xạ cho các trang trong phạm vi nhất định bằng trao đổi đặc biệt
mục nhập. Bất kỳ nỗ lực nào để truy cập vào mục trao đổi đều dẫn đến lỗi
được giải quyết bằng cách thay thế mục nhập bằng ánh xạ ban đầu. Một người lái xe được
đã thông báo rằng ánh xạ đã được thay đổi bởi trình thông báo MMU, sau thời điểm đó
nó sẽ không còn có quyền truy cập độc quyền vào trang nữa. Quyền truy cập độc quyền là
đảm bảo kéo dài cho đến khi trình điều khiển bỏ khóa trang và tham chiếu trang, tại
điểm này cho thấy bất kỳ lỗi CPU nào trên trang đều có thể tiếp tục như mô tả.

Bộ nhớ cgroup (memcg) và kế toán rss
========================================

Hiện tại, bộ nhớ thiết bị được tính là bất kỳ trang thông thường nào trong bộ đếm rss (hoặc
ẩn danh nếu trang thiết bị được sử dụng cho ẩn danh, tệp nếu trang thiết bị được sử dụng cho
trang được hỗ trợ tệp hoặc shmem nếu trang thiết bị được sử dụng cho bộ nhớ dùng chung). Đây là một
lựa chọn có chủ ý để giữ lại các ứng dụng hiện có, có thể bắt đầu sử dụng thiết bị
bộ nhớ mà không biết về nó, chạy không bị ảnh hưởng.

Một nhược điểm là OOM Killer có thể giết chết một ứng dụng bằng cách sử dụng nhiều
bộ nhớ thiết bị và không có nhiều bộ nhớ hệ thống thông thường và do đó không giải phóng nhiều
bộ nhớ hệ thống. Chúng tôi muốn thu thập thêm kinh nghiệm thực tế về cách các ứng dụng
và hệ thống phản ứng dưới áp lực bộ nhớ với sự hiện diện của bộ nhớ thiết bị trước đó
quyết định tính toán bộ nhớ thiết bị theo cách khác.


Quyết định tương tự đã được đưa ra cho nhóm bộ nhớ. Các trang bộ nhớ thiết bị được hạch toán
đối với cùng một nhóm bộ nhớ, một trang thông thường sẽ được tính đến. Điều này không
đơn giản hóa việc di chuyển đến và đi từ bộ nhớ thiết bị. Điều này cũng có nghĩa là việc di cư
việc quay lại từ bộ nhớ thiết bị về bộ nhớ thông thường không thể bị lỗi vì nó sẽ
vượt quá giới hạn cgroup bộ nhớ. Chúng ta có thể xem lại lựa chọn này sau này khi chúng ta
có thêm kinh nghiệm về cách sử dụng bộ nhớ thiết bị và tác động của nó đến bộ nhớ
kiểm soát tài nguyên.


Lưu ý rằng bộ nhớ thiết bị không bao giờ có thể được ghim bởi trình điều khiển thiết bị cũng như thông qua GUP
và do đó bộ nhớ như vậy luôn trống khi thoát khỏi quá trình. Hoặc khi tham khảo lần cuối
bị loại bỏ trong trường hợp bộ nhớ dùng chung hoặc bộ nhớ hỗ trợ tập tin.
