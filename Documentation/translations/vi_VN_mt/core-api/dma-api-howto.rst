.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/dma-api-howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Hướng dẫn lập bản đồ DMA động
=========================

:Tác giả: David S. Miller <davem@redhat.com>
:Tác giả: Richard Henderson <rth@cygnus.com>
:Tác giả: Jakub Jelinek <jakub@redhat.com>

Đây là hướng dẫn dành cho người viết trình điều khiển thiết bị về cách sử dụng DMA API
với ví dụ mã giả.  Để biết mô tả ngắn gọn về API, hãy xem
Tài liệu/core-api/dma-api.rst.

Địa chỉ CPU và DMA
=====================

Có một số loại địa chỉ liên quan đến DMA API, và đó là
quan trọng là phải hiểu sự khác biệt.

Hạt nhân thường sử dụng địa chỉ ảo.  Bất kỳ địa chỉ nào được trả lại bởi
kmalloc(), vmalloc() và các giao diện tương tự là địa chỉ ảo và có thể
được lưu trữ trong ZZ0000ZZ.

Hệ thống bộ nhớ ảo (TLB, bảng trang, v.v.) dịch ảo
địa chỉ tới địa chỉ vật lý CPU, được lưu trữ dưới dạng "phys_addr_t" hoặc
"tài nguyên_size_t".  Hạt nhân quản lý tài nguyên thiết bị như các thanh ghi
địa chỉ vật lý.  Đây là các địa chỉ trong /proc/iomem.  Thể chất
địa chỉ không hữu ích trực tiếp cho người lái xe; nó phải sử dụng ioremap() để ánh xạ
không gian và tạo ra một địa chỉ ảo.

Các thiết bị I/O sử dụng loại địa chỉ thứ ba: "địa chỉ bus".  Nếu một thiết bị có
đăng ký tại địa chỉ MMIO hoặc nếu nó thực hiện DMA để đọc hoặc ghi hệ thống
bộ nhớ, địa chỉ được thiết bị sử dụng là địa chỉ bus.  Ở một số
hệ thống, địa chỉ bus giống hệt với địa chỉ vật lý CPU, nhưng trong
nói chung là không.  IOMMU và cầu nối máy chủ có thể tạo ra các dữ liệu tùy ý
ánh xạ giữa địa chỉ vật lý và địa chỉ bus.

Từ quan điểm của thiết bị, DMA sử dụng không gian địa chỉ bus, nhưng nó có thể
bị giới hạn ở một tập con của không gian đó.  Ví dụ, ngay cả khi một hệ thống
hỗ trợ địa chỉ 64-bit cho bộ nhớ chính và thanh PCI, nó có thể sử dụng IOMMU
vì vậy các thiết bị chỉ cần sử dụng địa chỉ DMA 32 bit.

Đây là một hình ảnh và một số ví dụ::

Xe buýt CPU CPU
             Địa chỉ vật lý ảo
             Địa chỉ Không gian địa chỉ
              không gian không gian

+-------+ +------+ +------+
            ZZ0000ZZ ZZ0001ZZ Bù đắp ZZ0002ZZ
            ZZ0003ZZ ZZ0004ZZ ảo được áp dụng ZZ0005ZZ
          C +-------+ --------> B +------+ ----------> +------+ A
            ZZ0006ZZ ánh xạ ZZ0007ZZ bởi máy chủ ZZ0008ZZ
  +------+ ZZ0009ZZ ZZ0010ZZ cầu ZZ0011ZZ +--------+
  ZZ0012ZZ ZZ0013ZZ +------+ ZZ0014ZZ ZZ0015ZZ
  ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ
  ZZ0021ZZ ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ
  +------+ +-------+ +------+ +------+ +--------+
            ZZ0026ZZ Ánh xạ ZZ0027ZZ ảo ZZ0028ZZ
          X +-------+ --------> Y +------+ <---------- +------+ Z
            Ánh xạ ZZ0029ZZ ZZ0030ZZ bởi IOMMU
            ZZ0031ZZ ZZ0032ZZ
            ZZ0033ZZ ZZ0034ZZ
            +-------+ +------+

Trong quá trình liệt kê, kernel tìm hiểu về các thiết bị I/O và
không gian MMIO của họ và các cầu nối máy chủ kết nối chúng với hệ thống.  cho
ví dụ: nếu thiết bị PCI có BAR, kernel sẽ đọc địa chỉ bus (A)
từ BAR và chuyển đổi nó thành địa chỉ vật lý CPU (B).  Địa chỉ B
được lưu trữ trong tài nguyên cấu trúc và thường được hiển thị qua/proc/iomem.  Khi một
trình điều khiển yêu cầu một thiết bị, nó thường sử dụng ioremap() để ánh xạ địa chỉ vật lý
B tại một địa chỉ ảo (C).  Sau đó nó có thể sử dụng, ví dụ: ioread32(C), để truy cập
thiết bị đăng ký tại địa chỉ bus A.

Nếu thiết bị hỗ trợ DMA, trình điều khiển sẽ thiết lập bộ đệm bằng kmalloc() hoặc
một giao diện tương tự, trả về một địa chỉ ảo (X).  ảo
hệ thống bộ nhớ ánh xạ X tới địa chỉ vật lý (Y) trong hệ thống RAM.  Người lái xe
có thể sử dụng địa chỉ ảo X để truy cập bộ đệm, nhưng bản thân thiết bị
không thể vì DMA không đi qua hệ thống bộ nhớ ảo CPU.

Trong một số hệ thống đơn giản, thiết bị có thể thực hiện DMA trực tiếp tới địa chỉ vật lý
Y. Nhưng ở nhiều nơi khác, có phần cứng IOMMU dịch DMA
địa chỉ thành địa chỉ vật lý, ví dụ: nó dịch Z thành Y. Đây là một phần
lý do cho DMA API: trình điều khiển có thể cung cấp địa chỉ ảo X cho
một giao diện như dma_map_single(), thiết lập mọi IOMMU cần thiết
ánh xạ và trả về địa chỉ DMA Z. Sau đó, trình điều khiển sẽ yêu cầu thiết bị
thực hiện DMA tới Z và IOMMU ánh xạ nó tới bộ đệm tại địa chỉ Y trong hệ thống
RAM.

Để Linux có thể sử dụng ánh xạ DMA động, nó cần một số trợ giúp từ
trình điều khiển, cụ thể là nó phải tính đến địa chỉ DMA.
chỉ được ánh xạ trong thời gian chúng thực sự được sử dụng và không được ánh xạ sau DMA
chuyển nhượng.

Tất nhiên, API sau đây sẽ hoạt động ngay cả trên các nền tảng không có tính năng này
phần cứng tồn tại.

Lưu ý rằng DMA API hoạt động với bất kỳ bus nào độc lập với cơ sở
kiến trúc vi xử lý. Bạn nên sử dụng DMA API thay vì
DMA API dành riêng cho xe buýt, tức là sử dụng giao diện dma_map_*() thay vì giao diện
giao diện pci_map_*().

Trước hết, bạn nên đảm bảo::

#include <linux/dma-mapping.h>

nằm trong trình điều khiển của bạn, nó cung cấp định nghĩa về dma_addr_t.  Loại này
có thể chứa bất kỳ địa chỉ DMA hợp lệ nào cho nền tảng và nên được sử dụng
ở mọi nơi bạn giữ địa chỉ DMA được trả về từ các hàm ánh xạ DMA.

DMA'able có bộ nhớ gì?
========================

Thông tin đầu tiên bạn phải biết là bộ nhớ kernel có thể làm gì
được sử dụng với các phương tiện lập bản đồ DMA.  Đã có một điều chưa được viết
bộ quy tắc liên quan đến vấn đề này và văn bản này là một nỗ lực để cuối cùng
viết chúng ra.

Nếu bạn có được bộ nhớ thông qua bộ cấp phát trang
(tức là __get_free_page*()) hoặc bộ cấp phát bộ nhớ chung
(tức là kmalloc() hoặc kmem_cache_alloc()) thì bạn có thể DMA đến/từ
bộ nhớ đó bằng cách sử dụng các địa chỉ được trả về từ các quy trình đó.

Điều này có nghĩa cụ thể là bạn có thể _không_ sử dụng bộ nhớ/địa chỉ
được trả về từ vmalloc() cho DMA.  Có thể DMA đến
_underlying_ bộ nhớ được ánh xạ vào vùng vmalloc(), nhưng điều này đòi hỏi
bảng trang đi bộ để lấy địa chỉ vật lý và sau đó
dịch từng trang đó trở lại địa chỉ kernel bằng cách sử dụng
đại loại như __va().  [ EDIT: Cập nhật thông tin này khi chúng tôi tích hợp
Mã chung của Gerd Knorr thực hiện điều này. ]

Quy tắc này cũng có nghĩa là bạn không được sử dụng địa chỉ hình ảnh hạt nhân
(các mục trong phân đoạn dữ liệu/văn bản/bss), cũng như địa chỉ hình ảnh mô-đun, cũng như
địa chỉ ngăn xếp cho DMA.  Tất cả những thứ này có thể được ánh xạ ở đâu đó hoàn toàn
khác với phần còn lại của bộ nhớ vật lý.  Ngay cả khi những lớp học đó
bộ nhớ có thể hoạt động vật lý với DMA, bạn cần đảm bảo I/O
bộ đệm được căn chỉnh theo dòng bộ đệm.  Không có điều đó, bạn sẽ thấy cacheline
sự cố chia sẻ (hỏng dữ liệu) trên CPU có bộ nhớ đệm không mạch lạc DMA.
(CPU có thể viết thành một từ, DMA sẽ viết thành một từ khác
trong cùng một dòng bộ đệm và một trong số chúng có thể bị ghi đè.)

Ngoài ra, điều này có nghĩa là bạn không thể trả lại kmap()
gọi và DMA đến/từ đó.  Điều này tương tự với vmalloc().

Còn khối I/O và bộ đệm mạng thì sao?  Khối I/O và
các hệ thống con mạng đảm bảo rằng bộ đệm chúng sử dụng hợp lệ
để bạn đến DMA từ/đến.

Chú thích __dma_from_device_group_begin/end
=============================================

Như đã giải thích trước đây, khi một cấu trúc chứa DMA_FROM_DEVICE /
Bộ đệm DMA_BIDIRECTIONAL (thiết bị ghi vào bộ nhớ) cùng với các trường mà
CPU ghi vào, chia sẻ dòng bộ đệm giữa bộ đệm DMA và các trường được ghi CPU
có thể gây hỏng dữ liệu trên CPU có bộ nhớ đệm không mạch lạc DMA.

ZZ0000ZZ
macro đảm bảo căn chỉnh phù hợp để ngăn chặn điều này::

cấu trúc my_device {
		spinlock_t khóa1;
		__dma_from_device_group_begin();
		char dma_buffer1[16];
		char dma_buffer2[16];
		__dma_from_device_group_end();
		spinlock_t lock2;
	};

Để tách bộ đệm DMA khỏi các trường lân cận, hãy sử dụng
ZZ0000ZZ trước bộ đệm DMA đầu tiên
trường và ZZ0001ZZ sau DMA cuối cùng
trường đệm (có cùng tên GROUP). Điều này bảo vệ cả đầu
và phần đuôi của bộ đệm từ việc chia sẻ dòng bộ đệm.

Tham số GROUP là mã định danh tùy chọn đặt tên cho nhóm bộ đệm DMA
(trong trường hợp bạn có nhiều cấu trúc giống nhau)::

cấu trúc my_device {
		spinlock_t khóa1;
		__dma_from_device_group_begin(buffer1);
		char dma_buffer1[16];
		__dma_from_device_group_end(buffer1);
		spinlock_t lock2;
		__dma_from_device_group_begin(buffer2);
		char dma_buffer2[16];
		__dma_from_device_group_end(buffer2);
	};

Trên nền tảng kết hợp bộ đệm, các macro này mở rộng thành các điểm đánh dấu mảng có độ dài bằng 0.
Trên các nền tảng không kết hợp, chúng cũng đảm bảo sự liên kết DMA tối thiểu, giúp
có thể lớn tới 128 byte.

.. note::

        It is allowed (though somewhat fragile) to include extra fields, not
        intended for DMA from the device, within the group (in order to pack the
        structure tightly) - but only as long as the CPU does not write these
        fields while any fields in the group are mapped for DMA_FROM_DEVICE or
        DMA_BIDIRECTIONAL.

Khả năng đánh địa chỉ DMA
===========================

Theo mặc định, kernel giả định rằng thiết bị của bạn có thể xử lý 32 bit DMA
địa chỉ.  Đối với thiết bị có khả năng 64-bit, điều này cần được tăng lên và đối với
một thiết bị có những hạn chế, nó cần phải được giảm bớt.

Lưu ý đặc biệt về PCI: Thông số kỹ thuật PCI-X yêu cầu các thiết bị PCI-X hỗ trợ
Địa chỉ 64-bit (DAC) cho tất cả các giao dịch.  Và ít nhất một nền tảng (SGI
SN2) yêu cầu phân bổ mạch lạc 64-bit để hoạt động chính xác khi IO
xe buýt ở chế độ PCI-X.

Để hoạt động chính xác, bạn phải đặt mặt nạ DMA để thông báo cho kernel về
khả năng đánh địa chỉ DMA của thiết bị của bạn.

Điều này được thực hiện thông qua lệnh gọi đến dma_set_mask_and_coherent()::

int dma_set_mask_and_coherent(thiết bị cấu trúc *dev, mặt nạ u64);

sẽ đặt mặt nạ cho cả API phát trực tuyến và API kết hợp với nhau.  Nếu bạn
có một số yêu cầu đặc biệt thì hai lệnh gọi riêng biệt sau đây có thể được thực hiện
được sử dụng thay thế:

Việc thiết lập ánh xạ phát trực tuyến được thực hiện thông qua lệnh gọi tới
	dma_set_mask()::

int dma_set_mask(thiết bị cấu trúc *dev, mặt nạ u64);

Việc thiết lập để phân bổ mạch lạc được thực hiện thông qua lệnh gọi
	tới dma_set_coherent_mask()::

int dma_set_coherent_mask(thiết bị cấu trúc *dev, mặt nạ u64);

Ở đây, dev là một con trỏ tới cấu trúc thiết bị của thiết bị của bạn và mặt nạ hơi
mặt nạ mô tả các bit của địa chỉ mà thiết bị của bạn hỗ trợ.  Thường thì
cấu trúc thiết bị của thiết bị của bạn được nhúng vào cấu trúc thiết bị dành riêng cho xe buýt của
thiết bị của bạn.  Ví dụ: &pdev->dev là một con trỏ tới cấu trúc thiết bị của một
Thiết bị PCI (pdev là con trỏ tới cấu trúc thiết bị PCI trên thiết bị của bạn).

Các cuộc gọi này thường trả về 0 để cho biết thiết bị của bạn có thể thực hiện DMA
đúng trên máy với mặt nạ địa chỉ bạn đã cung cấp, nhưng chúng có thể
trả về lỗi nếu mặt nạ quá nhỏ để có thể hỗ trợ trên thiết bị đã cho
hệ thống.  Nếu nó trả về khác 0, thiết bị của bạn không thể thực hiện DMA đúng cách trên
nền tảng này và cố gắng làm như vậy sẽ dẫn đến hành vi không xác định.
Bạn không được sử dụng DMA trên thiết bị này trừ khi họ dma_set_mask
chức năng đã trở lại thành công.

Điều này có nghĩa là trong trường hợp thất bại, bạn có hai lựa chọn:

1) Sử dụng một số chế độ không phải DMA để truyền dữ liệu, nếu có thể.
2) Bỏ qua thiết bị này và không khởi tạo nó.

Trình điều khiển của bạn nên in thông báo kernel KERN_WARNING khi
cài đặt mặt nạ DMA không thành công.  Theo cách này, nếu người dùng trình điều khiển của bạn báo cáo
hiệu suất kém hoặc thiết bị thậm chí không được phát hiện, bạn có thể hỏi
chúng cho các thông báo kernel để tìm hiểu chính xác lý do tại sao.

Thiết bị đánh địa chỉ 24 bit sẽ hoạt động như thế này ::

if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(24))) {
		dev_warn(dev, "mydev: Không có DMA phù hợp\n");
		hãy bỏ qua_this_device;
	}

Thiết bị đánh địa chỉ 64 bit tiêu chuẩn sẽ hoạt động như thế này ::

dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64))

dma_set_mask_and_coherent() không bao giờ trả về lỗi khi DMA_BIT_MASK(64). Điển hình
mã lỗi như::

/* Mã sai */
	nếu (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)))
		dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32))

dma_set_mask_and_coherent() sẽ không bao giờ trả về lỗi khi lớn hơn 32.
Vì vậy, mã điển hình như::

/* Mã đề xuất */
	nếu (support_64bit)
		dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
	khác
		dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32));

Nếu thiết bị chỉ hỗ trợ địa chỉ 32-bit cho bộ mô tả trong
phân bổ mạch lạc nhưng hỗ trợ đầy đủ 64-bit để truyền ánh xạ
nó sẽ trông như thế này::

if (dma_set_mask(dev, DMA_BIT_MASK(64))) {
		dev_warn(dev, "mydev: Không có DMA phù hợp\n");
		hãy bỏ qua_this_device;
	}

Mặt nạ mạch lạc sẽ luôn có thể đặt mặt nạ giống nhau hoặc nhỏ hơn như
mặt nạ phát trực tuyến. Tuy nhiên trong trường hợp hiếm hoi mà trình điều khiển thiết bị chỉ
sử dụng phân bổ mạch lạc, người ta sẽ phải kiểm tra giá trị trả về từ
dma_set_coherent_mask().

Cuối cùng, nếu thiết bị của bạn chỉ có thể điều khiển 24 bit thấp của
địa chỉ bạn có thể làm điều gì đó như::

if (dma_set_mask(dev, DMA_BIT_MASK(24))) {
		dev_warn(dev, "mydev: Không có địa chỉ DMA 24-bit\n");
		hãy bỏ qua_this_device;
	}

Khi dma_set_mask() hoặc dma_set_mask_and_coherent() thành công và
trả về 0, kernel sẽ lưu mặt nạ này mà bạn đã cung cấp.  các
kernel sẽ sử dụng thông tin này sau khi bạn tạo ánh xạ DMA.

Có một trường hợp mà chúng tôi biết vào thời điểm này, rất đáng
đề cập trong tài liệu này.  Nếu thiết bị của bạn hỗ trợ nhiều
các chức năng (ví dụ: card âm thanh cung cấp tính năng phát lại và ghi âm
chức năng) và các chức năng khác nhau có _khác nhau_
DMA giải quyết các hạn chế, bạn có thể muốn thăm dò từng mặt nạ và
chỉ cung cấp chức năng mà máy có thể xử lý.  Nó
điều quan trọng là lệnh gọi cuối cùng tới dma_set_mask() dành cho
mặt nạ cụ thể nhất.

Đây là mã giả cho biết cách thực hiện việc này::

#define PLAYBACK_ADDRESS_BITS DMA_BIT_MASK(32)
	#define RECORD_ADDRESS_BITS DMA_BIT_MASK(24)

cấu trúc my_sound_card *card;
	thiết bị cấu trúc *dev;

	...
if (!dma_set_mask(dev, PLAYBACK_ADDRESS_BITS)) {
		thẻ->playback_enabled = 1;
	} khác {
		thẻ->playback_enabled = 0;
		dev_warn(dev, "%s: Đã tắt tính năng phát lại do giới hạn của DMA\n",
		       thẻ-> tên);
	}
	if (!dma_set_mask(dev, RECORD_ADDRESS_BITS)) {
		thẻ->record_enabled = 1;
	} khác {
		thẻ->record_enabled = 0;
		dev_warn(dev, "%s: Bản ghi bị vô hiệu do giới hạn của DMA\n",
		       thẻ-> tên);
	}

Card âm thanh được sử dụng làm ví dụ ở đây vì thể loại PCI này
các thiết bị dường như tràn ngập chip ISA với giao diện người dùng PCI,
và do đó giữ lại các giới hạn địa chỉ DMA 16MB của ISA.

Các loại ánh xạ DMA
=====================

Có hai loại ánh xạ DMA:

- Ánh xạ DMA mạch lạc thường được ánh xạ tại trình điều khiển
  khởi tạo, chưa được ánh xạ ở cuối và phần cứng sẽ
  đảm bảo rằng thiết bị và CPU có thể truy cập dữ liệu
  song song và sẽ thấy các cập nhật được thực hiện bởi nhau mà không có bất kỳ
  xóa phần mềm rõ ràng.

Hãy nghĩ “mạch lạc” là “đồng bộ”.

Mặc định hiện tại là trả về bộ nhớ nhất quán ở mức thấp 32
  bit của không gian DMA.  Tuy nhiên, để tương thích trong tương lai bạn nên
  đặt mặt nạ mạch lạc ngay cả khi mặc định này phù hợp với bạn
  người lái xe.

Các ví dụ điển hình về mục đích sử dụng ánh xạ mạch lạc là:

- Bộ mô tả vòng DMA của card mạng.
	- Cấu trúc dữ liệu lệnh hộp thư bộ điều hợp SCSI.
	- Vi mã chương trình cơ sở của thiết bị được thực thi ngoài
	  bộ nhớ chính.

Điều bất biến mà tất cả các ví dụ này yêu cầu là bất kỳ cửa hàng CPU nào
  vào bộ nhớ sẽ được hiển thị ngay lập tức trên thiết bị và ngược lại
  ngược lại.  Ánh xạ mạch lạc đảm bảo điều này.

  .. important::

	     Coherent DMA memory does not preclude the usage of
	     proper memory barriers.  The CPU may reorder stores to
	     coherent memory just as it may normal memory.  Example:
	     if it is important for the device to see the first word
	     of a descriptor updated before the second, you must do
	     something like::

desc->word0 = địa chỉ;
		wmb();
		desc->word1 = DESC_VALID;

để có được hành vi đúng trên tất cả các nền tảng.

Ngoài ra, trên một số nền tảng, trình điều khiển của bạn có thể cần phải ghi CPU
	     bộ đệm theo cách tương tự như nó cần xóa bộ đệm ghi
	     được tìm thấy trong các cầu nối PCI (chẳng hạn như bằng cách đọc giá trị của thanh ghi
	     sau khi viết nó).

- Truyền ánh xạ DMA thường được ánh xạ cho một DMA
  chuyển, chưa được ánh xạ ngay sau nó (trừ khi bạn sử dụng dma_sync_* bên dưới)
  và phần cứng nào có thể tối ưu hóa để truy cập tuần tự.

Hãy coi "phát trực tuyến" là "không đồng bộ" hoặc "nằm ngoài sự mạch lạc
  miền".

Các ví dụ điển hình về mục đích sử dụng ánh xạ phát trực tuyến là:

- Bộ đệm mạng được thiết bị truyền/nhận.
	- Bộ đệm hệ thống tập tin được ghi/đọc bằng thiết bị SCSI.

Các giao diện để sử dụng loại ánh xạ này được thiết kế theo
  theo cách mà việc triển khai có thể tạo ra bất kỳ hiệu suất nào
  tối ưu hóa phần cứng cho phép.  Để đạt được mục đích này, khi sử dụng
  những ánh xạ như vậy bạn phải rõ ràng về những gì bạn muốn xảy ra.

Cả hai loại ánh xạ DMA đều không có các hạn chế căn chỉnh xuất phát từ
bus cơ bản, mặc dù một số thiết bị có thể có những hạn chế như vậy.
Ngoài ra, các hệ thống có bộ đệm không gắn liền với DMA sẽ hoạt động tốt hơn
khi bộ đệm cơ bản không chia sẻ dòng bộ đệm với dữ liệu khác.


Sử dụng ánh xạ Coherent DMA
===========================

Để phân bổ và ánh xạ các vùng DMA lớn (PAGE_SIZE hoặc hơn),
bạn nên làm::

dma_addr_t dma_handle;

cpu_addr = dma_alloc_coherent(dev, size, &dma_handle, gfp);

trong đó thiết bị là ZZ0000ZZ. Điều này có thể được gọi trong ngắt
bối cảnh với cờ GFP_ATOMIC.

Kích thước là độ dài của vùng bạn muốn phân bổ, tính bằng byte.

Quy trình này sẽ phân bổ RAM cho vùng đó, vì vậy nó hoạt động tương tự như
__get_free_pages() (nhưng lấy kích thước thay vì thứ tự trang).  Nếu bạn
trình điều khiển cần các vùng có kích thước nhỏ hơn một trang, bạn có thể thích sử dụng
giao diện DMA_pool, được mô tả bên dưới.

Theo mặc định, các giao diện ánh xạ DMA mạch lạc sẽ trả về địa chỉ DMA
đó là địa chỉ 32-bit.  Ngay cả khi thiết bị chỉ báo (thông qua mặt nạ DMA)
rằng nó có thể giải quyết 32-bit trên, việc phân bổ mạch lạc sẽ chỉ
trả về > địa chỉ 32-bit cho DMA nếu mặt nạ DMA nhất quán đã được
được thay đổi rõ ràng thông qua dma_set_coherent_mask().  Điều này đúng với
giao diện dma_pool là tốt.

dma_alloc_coherent() trả về hai giá trị: địa chỉ ảo mà bạn
có thể sử dụng để truy cập nó từ CPU và dma_handle mà bạn chuyển tới
thẻ.

Địa chỉ ảo CPU và địa chỉ DMA đều là địa chỉ
đảm bảo được căn chỉnh theo thứ tự PAGE_SIZE nhỏ nhất
lớn hơn hoặc bằng kích thước được yêu cầu.  Bất biến này
tồn tại (ví dụ) để đảm bảo rằng nếu bạn phân bổ một đoạn
nhỏ hơn hoặc bằng 64 kilobyte, phạm vi của
bộ đệm bạn nhận được sẽ không vượt qua ranh giới 64K.

Để hủy ánh xạ và giải phóng vùng DMA như vậy, bạn gọi::

dma_free_coherent(dev, size, cpu_addr, dma_handle);

trong đó dev, kích thước giống như trong lệnh gọi ở trên và cpu_addr và
dma_handle là các giá trị dma_alloc_coherent() được trả về cho bạn.
Hàm này có thể không được gọi trong ngữ cảnh ngắt.

Nếu trình điều khiển của bạn cần nhiều vùng bộ nhớ nhỏ hơn, bạn có thể viết
mã tùy chỉnh để chia nhỏ các trang được trả về bởi dma_alloc_coherent(),
hoặc bạn có thể sử dụng dma_pool API để làm điều đó.  Một DMA_pool giống như
kmem_cache, nhưng nó sử dụng dma_alloc_coherent(), không phải __get_free_pages().
Ngoài ra, nó hiểu được các ràng buộc phần cứng phổ biến đối với việc căn chỉnh,
giống như các đầu hàng đợi cần được căn chỉnh trên ranh giới N byte.

Tạo một dma_pool như thế này::

cấu trúc dma_pool *pool;

pool = dma_pool_create(tên, dev, kích thước, căn chỉnh, ranh giới);

"Tên" dùng để chẩn đoán (như tên kmem_cache); phát triển và kích thước
là như trên.  Yêu cầu căn chỉnh phần cứng của thiết bị cho việc này
loại dữ liệu là "căn chỉnh" (được biểu thị bằng byte và phải là
sức mạnh của hai).  Nếu thiết bị của bạn không có hạn chế vượt qua ranh giới,
vượt qua 0 cho ranh giới; vượt qua 4096 cho biết bộ nhớ được phân bổ từ nhóm này
không được vượt qua ranh giới 4KByte (nhưng tại thời điểm đó có thể tốt hơn nếu
thay vào đó hãy sử dụng trực tiếp dma_alloc_coherent()).

Phân bổ bộ nhớ từ nhóm DMA như thế này ::

cpu_addr = dma_pool_alloc(pool, flags, &dma_handle);

cờ là GFP_KERNEL nếu việc chặn được cho phép (không phải in_interrupt hay
giữ khóa SMP), ngược lại là GFP_ATOMIC.  Giống như dma_alloc_coherent(),
cái này trả về hai giá trị, cpu_addr và dma_handle.

Bộ nhớ trống được phân bổ từ dma_pool như thế này::

dma_pool_free(pool, cpu_addr, dma_handle);

trong đó pool là những gì bạn đã chuyển đến dma_pool_alloc(), và cpu_addr và
dma_handle là các giá trị dma_pool_alloc() được trả về. Chức năng này
có thể được gọi trong bối cảnh ngắt.

Phá hủy một dma_pool bằng cách gọi::

dma_pool_destroy(pool);

Đảm bảo bạn đã gọi dma_pool_free() cho tất cả bộ nhớ được phân bổ
từ một hồ bơi trước khi bạn phá hủy hồ bơi. Chức năng này có thể không
được gọi trong bối cảnh ngắt.

Hướng DMA
=============

Các giao diện được mô tả trong các phần tiếp theo của tài liệu này
lấy đối số hướng DMA, là một số nguyên và đảm nhận
một trong các giá trị sau::

DMA_BIDIRECTIONAL
 DMA_TO_DEVICE
 DMA_FROM_DEVICE
 DMA_NONE

Bạn nên cung cấp hướng DMA chính xác nếu bạn biết.

DMA_TO_DEVICE có nghĩa là "từ bộ nhớ chính đến thiết bị"
DMA_FROM_DEVICE có nghĩa là "từ thiết bị đến bộ nhớ chính"
Đó là hướng mà dữ liệu di chuyển trong DMA
chuyển nhượng.

Bạn được khuyến khích _mạnh mẽ_ nêu rõ điều này một cách chính xác
như bạn có thể có thể.

Nếu bạn hoàn toàn không thể biết hướng chuyển DMA,
chỉ định DMA_BIDIRECTIONAL.  Điều đó có nghĩa là DMA có thể đi vào
một trong hai hướng.  Nền tảng đảm bảo rằng bạn có thể hợp pháp
chỉ định điều này và nó sẽ hoạt động, nhưng điều này có thể ở mức
chi phí thực hiện chẳng hạn.

Giá trị DMA_NONE được sử dụng để gỡ lỗi.  Người ta có thể
giữ điều này trong cấu trúc dữ liệu trước khi bạn biết
hướng chính xác và điều này sẽ giúp nắm bắt các trường hợp trong đó bạn
logic theo dõi hướng không thể thiết lập mọi thứ đúng cách.

Một ưu điểm khác của việc xác định chính xác giá trị này (ngoài
tối ưu hóa dành riêng cho nền tảng tiềm năng như vậy) là để gỡ lỗi.
Một số nền tảng thực sự có boolean cho phép ghi DMA
ánh xạ có thể được đánh dấu, giống như bảo vệ trang trong người dùng
không gian địa chỉ chương trình.  Những nền tảng như vậy có thể và thực hiện báo cáo lỗi trong
kernel ghi lại khi phần cứng bộ điều khiển DMA phát hiện vi phạm
thiết lập quyền.

Chỉ ánh xạ phát trực tuyến chỉ định hướng, ánh xạ mạch lạc
ngầm có cài đặt thuộc tính hướng của
DMA_BIDIRECTIONAL.

Hệ thống con SCSI cho bạn biết hướng sử dụng trong
Thành viên 'sc_data_direction' của lệnh SCSI mà trình điều khiển của bạn là
đang làm việc.

Đối với trình điều khiển Mạng, đó là một việc khá đơn giản.  Để truyền
các gói, ánh xạ/hủy ánh xạ chúng theo hướng DMA_TO_DEVICE
người chỉ định.  Để nhận các gói, ngược lại, ánh xạ/hủy ánh xạ chúng
với bộ xác định hướng DMA_FROM_DEVICE.

Sử dụng ánh xạ truyền phát DMA
============================

Các thói quen ánh xạ DMA phát trực tuyến có thể được gọi từ ngắt
bối cảnh.  Có hai phiên bản của mỗi bản đồ/bỏ bản đồ, một phiên bản sẽ
ánh xạ/hủy ánh xạ một vùng bộ nhớ duy nhất và một vùng sẽ ánh xạ/hủy ánh xạ một vùng bộ nhớ
danh sách phân tán.

Để lập bản đồ một vùng, bạn thực hiện::

thiết bị cấu trúc *dev = &my_dev->dev;
	dma_addr_t dma_handle;
	void *addr = đệm->ptr;
	size_t size = bộ đệm->len;

dma_handle = dma_map_single(dev, addr, size, Direction);
	if (dma_mapping_error(dev, dma_handle)) {
		/*
		 * giảm mức sử dụng bản đồ DMA hiện tại,
		 * trì hoãn và thử lại sau hoặc
		 * thiết lập lại trình điều khiển.
		 */
		xem bản đồ_error_handling;
	}

và để hủy bản đồ nó ::

dma_unmap_single(dev, dma_handle, kích thước, hướng);

Bạn nên gọi dma_mapping_error() vì dma_map_single() có thể thất bại và quay trở lại
lỗi.  Làm như vậy sẽ đảm bảo rằng mã ánh xạ sẽ hoạt động chính xác trên tất cả
Việc triển khai DMA mà không có bất kỳ sự phụ thuộc nào vào chi tiết cụ thể của nền tảng cơ bản
thực hiện. Việc sử dụng địa chỉ được trả về mà không kiểm tra lỗi có thể
dẫn đến những thất bại từ hoảng loạn đến hỏng dữ liệu thầm lặng.  giống nhau
cũng áp dụng cho dma_map_page().

Bạn nên gọi dma_unmap_single() khi hoạt động DMA kết thúc, ví dụ:
từ ngắt cho bạn biết rằng quá trình chuyển DMA đã hoàn tất.

Việc sử dụng các con trỏ CPU như thế này cho các ánh xạ đơn lẻ có một nhược điểm:
bạn không thể tham chiếu bộ nhớ HIGHMEM theo cách này.  Như vậy, có một
cặp giao diện map/unmap gần giống với dma_{map,unmap__single().  Những cái này
giao diện xử lý các cặp trang/offset thay vì con trỏ CPU.
Cụ thể::

thiết bị cấu trúc *dev = &my_dev->dev;
	dma_addr_t dma_handle;
	trang cấu trúc *trang = bộ đệm->trang;
	phần bù dài không dấu = bộ đệm-> offset;
	size_t size = bộ đệm->len;

dma_handle = dma_map_page(dev, page, offset, size, hướng);
	if (dma_mapping_error(dev, dma_handle)) {
		/*
		 * giảm mức sử dụng bản đồ DMA hiện tại,
		 * trì hoãn và thử lại sau hoặc
		 * thiết lập lại trình điều khiển.
		 */
		xem bản đồ_error_handling;
	}

	...

dma_unmap_page(dev, dma_handle, kích thước, hướng);

Ở đây, "offset" có nghĩa là offset byte trong trang đã cho.

Bạn nên gọi dma_mapping_error() vì dma_map_page() có thể thất bại và quay trở lại
lỗi như được nêu trong cuộc thảo luận về dma_map_single().

Bạn nên gọi dma_unmap_page() khi hoạt động DMA kết thúc, ví dụ:
từ ngắt cho bạn biết rằng quá trình chuyển DMA đã hoàn tất.

Với danh sách phân tán, bạn lập bản đồ một vùng được tập hợp từ nhiều vùng bằng cách::

int i, count = dma_map_sg(dev, sglist, nents, Direction);
	danh sách phân tán cấu trúc *sg;

for_each_sg(sglist, sg, count, i) {
		hw_address[i] = sg_dma_address(sg);
		hw_len[i] = sg_dma_len(sg);
	}

trong đó nents là số mục trong sglist.

Việc triển khai có thể tự do hợp nhất một số mục sglist liên tiếp
thành một (ví dụ: nếu ánh xạ DMA được thực hiện với mức độ chi tiết của PAGE_SIZE, bất kỳ
các mục sglist liên tiếp có thể được hợp nhất thành một mục miễn là mục đầu tiên
kết thúc và trang thứ hai bắt đầu ở ranh giới trang - thực tế đây là một trang rất lớn
lợi thế cho các thẻ không thể thu thập phân tán hoặc có rất nhiều
số lượng mục nhập thu thập phân tán có giới hạn) và trả về số lượng thực tế
của các mục sg mà nó ánh xạ tới. Khi thất bại 0 được trả về.

Sau đó, bạn nên đếm số lần lặp (lưu ý: số lần này có thể nhỏ hơn số lần)
và sử dụng macro sg_dma_address() và sg_dma_len() mà trước đây bạn
truy cập sg->address và sg->length như được hiển thị ở trên.

Để hủy ánh xạ danh sách phân tán, chỉ cần gọi ::

dma_unmap_sg(dev, sglist, nents, Direction);

Một lần nữa, hãy đảm bảo hoạt động DMA đã kết thúc.

.. note::

	The 'nents' argument to the dma_unmap_sg call must be
	the _same_ one you passed into the dma_map_sg call,
	it should _NOT_ be the 'count' value _returned_ from the
	dma_map_sg call.

Mỗi lệnh gọi dma_map_{single,sg}() phải có dma_unmap_{single,sg}()
đối tác, bởi vì không gian địa chỉ DMA là tài nguyên được chia sẻ và
bạn có thể khiến máy không sử dụng được bằng cách sử dụng tất cả các địa chỉ DMA.

Nếu bạn cần sử dụng cùng một vùng DMA phát trực tuyến nhiều lần và chạm vào
dữ liệu giữa các lần truyền DMA, bộ đệm cần được đồng bộ hóa
đúng cách để CPU và thiết bị có thể xem được thông tin cập nhật và mới nhất
bản sao chính xác của bộ đệm DMA.

Vì vậy, trước tiên, chỉ cần ánh xạ nó với dma_map_{single,sg}() và sau mỗi DMA
chuyển cuộc gọi::

dma_sync_single_for_cpu(dev, dma_handle, kích thước, hướng);

hoặc::

dma_sync_sg_for_cpu(dev, sglist, nents, Direction);

sao cho phù hợp.

Sau đó, nếu bạn muốn cho phép thiết bị quay lại khu vực DMA,
hoàn tất việc truy cập dữ liệu bằng CPU và trước khi thực sự
cung cấp bộ đệm cho cuộc gọi phần cứng ::

dma_sync_single_for_device(dev, dma_handle, kích thước, hướng);

hoặc::

dma_sync_sg_for_device(dev, sglist, nents, Direction);

sao cho phù hợp.

.. note::

	      The 'nents' argument to dma_sync_sg_for_cpu() and
	      dma_sync_sg_for_device() must be the same passed to
	      dma_map_sg(). It is _NOT_ the count returned by
	      dma_map_sg().

Sau lần chuyển DMA cuối cùng, hãy gọi một trong các quy trình hủy bản đồ DMA
dma_unmap_{đơn,sg}(). Nếu bạn không chạm vào dữ liệu ngay từ đầu
dma_map_*() call till dma_unmap_*() thì bạn không cần phải gọi
dma_sync_*() các thói quen.

Đây là mã giả cho thấy tình huống mà bạn cần
để sử dụng giao diện dma_sync_*() ::

my_card_setup_receive_buffer(struct my_card *cp, char *buffer, int len)
	{
		ánh xạ dma_addr_t;

ánh xạ = dma_map_single(cp->dev, buffer, len, DMA_FROM_DEVICE);
		if (dma_mapping_error(cp->dev, ánh xạ)) {
			/*
			 * giảm mức sử dụng bản đồ DMA hiện tại,
			 * trì hoãn và thử lại sau hoặc
			 * thiết lập lại trình điều khiển.
			 */
			xem bản đồ_error_handling;
		}

cp->rx_buf = bộ đệm;
		cp->rx_len = len;
		cp->rx_dma = ánh xạ;

đưa_rx_buf_to_card(cp);
	}

	...

my_card_interrupt_handler(int irq, void *devid, struct pt_regs *regs)
	{
		struct my_card *cp = devid;

		...
if (read_card_status(cp) == RX_BUF_TRANSFERRED) {
			cấu trúc my_card_header *hp;

/* Kiểm tra tiêu đề xem chúng ta có muốn không
			 * để chấp nhận dữ liệu.  Nhưng đồng bộ hóa
			 * chuyển DMA bằng CPU trước tiên
			 * để chúng tôi thấy nội dung cập nhật.
			 */
			dma_sync_single_for_cpu(&cp->dev, cp->rx_dma,
						cp->rx_len,
						DMA_FROM_DEVICE);

/* Bây giờ việc kiểm tra bộ đệm đã an toàn. */
			hp = (struct my_card_header *) cp->rx_buf;
			nếu (header_is_ok(hp)) {
				dma_unmap_single(&cp->dev, cp->rx_dma, cp->rx_len,
						 DMA_FROM_DEVICE);
				pass_to_upper_layers(cp->rx_buf);
				make_and_setup_new_rx_buf(cp);
			} khác {
				/* CPU không nên ghi vào
				 * Khu vực được ánh xạ DMA_FROM_DEVICE,
				 * vậy dma_sync_single_for_device() là
				 * không cần thiết ở đây. Nó sẽ được yêu cầu
				 * để ánh xạ DMA_BIDIRECTIONAL nếu
				 * bộ nhớ đã được sửa đổi.
				 */
				đưa_rx_buf_to_card(cp);
			}
		}
	}

Xử lý lỗi
===============

Không gian địa chỉ DMA bị giới hạn trên một số kiến trúc và sự phân bổ
sự cố có thể được xác định bởi:

- kiểm tra xem dma_alloc_coherent() trả về NULL hay dma_map_sg trả về 0

- kiểm tra dma_addr_t được trả về từ dma_map_single() và dma_map_page()
  bằng cách sử dụng dma_mapping_error()::

dma_addr_t dma_handle;

dma_handle = dma_map_single(dev, addr, size, Direction);
	if (dma_mapping_error(dev, dma_handle)) {
		/*
		 * giảm mức sử dụng bản đồ DMA hiện tại,
		 * trì hoãn và thử lại sau hoặc
		 * thiết lập lại trình điều khiển.
		 */
		xem bản đồ_error_handling;
	}

- hủy bản đồ các trang đã được ánh xạ, khi xảy ra lỗi ánh xạ ở giữa
  của nỗ lực ánh xạ nhiều trang. Những ví dụ này có thể áp dụng cho
  dma_map_page() cũng vậy.

Ví dụ 1::

dma_addr_t dma_handle1;
	dma_addr_t dma_handle2;

dma_handle1 = dma_map_single(dev, addr, size, Direction);
	if (dma_mapping_error(dev, dma_handle1)) {
		/*
		 * giảm mức sử dụng bản đồ DMA hiện tại,
		 * trì hoãn và thử lại sau hoặc
		 * thiết lập lại trình điều khiển.
		 */
		xem bản đồ_error_handling1;
	}
	dma_handle2 = dma_map_single(dev, addr, size, Direction);
	if (dma_mapping_error(dev, dma_handle2)) {
		/*
		 * giảm mức sử dụng bản đồ DMA hiện tại,
		 * trì hoãn và thử lại sau hoặc
		 * thiết lập lại trình điều khiển.
		 */
		xem bản đồ_error_handling2;
	}

	...

map_error_handling2:
		dma_unmap_single(dma_handle1);
	map_error_handling1:

Ví dụ 2::

/*
	 * nếu bộ đệm được phân bổ trong một vòng lặp, hãy hủy ánh xạ tất cả các bộ đệm được ánh xạ khi
	 * lỗi ánh xạ được phát hiện ở giữa
	 */

dma_addr_t dma_addr;
	mảng dma_addr_t[DMA_BUFFERS];
	int save_index = 0;

cho (i = 0; tôi < DMA_BUFFERS; i++) {

		...

dma_addr = dma_map_single(dev, addr, size, Direction);
		if (dma_mapping_error(dev, dma_addr)) {
			/*
			 * giảm mức sử dụng bản đồ DMA hiện tại,
			 * trì hoãn và thử lại sau hoặc
			 * thiết lập lại trình điều khiển.
			 */
			xem bản đồ_error_handling;
		}
		mảng[i].dma_addr = dma_addr;
		save_index++;
	}

	...

map_error_handling:

for (i = 0; i < save_index; i++) {

		...

dma_unmap_single(mảng[i].dma_addr);
	}

Trình điều khiển mạng phải gọi dev_kfree_skb() để giải phóng bộ đệm ổ cắm
và trả về NETDEV_TX_OK nếu ánh xạ DMA không thành công trên móc truyền
(ndo_start_xmit). Điều này có nghĩa là bộ đệm ổ cắm vừa được thả vào
trường hợp thất bại.

Trình điều khiển SCSI phải trả về SCSI_MLQUEUE_HOST_BUSY nếu ánh xạ DMA
không thành công trong hook lệnh queue. Điều này có nghĩa là hệ thống con SCSI
chuyển lệnh cho trình điều khiển một lần nữa sau đó.

Tối ưu hóa việc sử dụng không gian trạng thái Unmap
========================================

Trên nhiều nền tảng, dma_unmap_{single,page}() chỉ đơn giản là không có.
Vì vậy, việc theo dõi địa chỉ và độ dài bản đồ là một sự lãng phí
của không gian.  Thay vì lấp đầy trình điều khiển của bạn bằng ifdefs và những thứ tương tự
để "giải quyết" vấn đề này (điều này sẽ làm hỏng toàn bộ mục đích của một
API di động), các tiện ích sau được cung cấp.

Trên thực tế, thay vì mô tả từng macro một, chúng ta sẽ
chuyển đổi một số mã ví dụ.

1) Sử dụng DEFINE_DMA_UNMAP_{ADDR,LEN} trong cấu trúc lưu trạng thái.
   Ví dụ, trước::

cấu trúc ring_state {
		cấu trúc sk_buff *skb;
		ánh xạ dma_addr_t;
		__u32 len;
	};

sau đó::

cấu trúc ring_state {
		cấu trúc sk_buff *skb;
		DEFINE_DMA_UNMAP_ADDR(ánh xạ);
		DEFINE_DMA_UNMAP_LEN(len);
	};

2) Sử dụng dma_unmap_{addr,len__set() để đặt các giá trị này.
   Ví dụ, trước::

ringp-> ánh xạ = FOO;
	ringp->len = BAR;

sau đó::

dma_unmap_addr_set(ringp, ánh xạ, FOO);
	dma_unmap_len_set(ringp, len, BAR);

3) Sử dụng dma_unmap_{addr,len}() để truy cập các giá trị này.
   Ví dụ, trước::

dma_unmap_single(dev, ringp->ánh xạ, ringp->len,
			 DMA_FROM_DEVICE);

sau đó::

dma_unmap_single(dev,
			 dma_unmap_addr(ringp, ánh xạ),
			 dma_unmap_len(ringp, len),
			 DMA_FROM_DEVICE);

Nó thực sự nên tự giải thích.  Chúng tôi xử lý ADDR và LEN
riêng biệt, bởi vì việc triển khai chỉ có thể
cần địa chỉ để thực hiện thao tác hủy bản đồ.

Sự cố nền tảng
===============

Nếu bạn chỉ viết trình điều khiển cho Linux và không duy trì
một cổng kiến trúc cho kernel, bạn có thể bỏ qua một cách an toàn
đến "Đóng".

1) Yêu cầu về danh sách phân tán cấu trúc.

Bạn cần kích hoạt CONFIG_NEED_SG_DMA_LENGTH nếu kiến trúc
   hỗ trợ IOMMU (bao gồm phần mềm IOMMU).

2) ARCH_DMA_MINALIGN

Kiến trúc phải đảm bảo rằng bộ đệm kmalloc'ed
   DMA-an toàn. Trình điều khiển và hệ thống con phụ thuộc vào nó. Nếu một kiến trúc
   DMA không hoàn toàn mạch lạc (tức là phần cứng không đảm bảo rằng dữ liệu trong
   bộ đệm CPU giống hệt với dữ liệu trong bộ nhớ chính),
   ARCH_DMA_MINALIGN phải được đặt sao cho bộ cấp phát bộ nhớ
   đảm bảo rằng bộ đệm kmalloc'ed không chia sẻ dòng bộ đệm với
   những người khác. Xem Arch/arm/include/asm/cache.h làm ví dụ.

Lưu ý rằng ARCH_DMA_MINALIGN liên quan đến việc căn chỉnh bộ nhớ DMA
   những hạn chế. Bạn không cần phải lo lắng về dữ liệu kiến trúc
   các ràng buộc căn chỉnh (ví dụ: các ràng buộc căn chỉnh về 64-bit
   đồ vật).

Đóng cửa
=======

Tài liệu này và bản thân API sẽ không có trong phiên bản hiện hành
hình thức mà không có phản hồi và đề xuất từ nhiều cá nhân.
Chúng tôi muốn đề cập cụ thể, không theo thứ tự cụ thể,
những người theo dõi::

Vua Russell <rmk@arm.linux.org.uk>
	Leo Dagum <dagum@barrel.engr.sgi.com>
	Ralf Baechle <ralf@oss.sgi.com>
	Grant Grundler <grundler@cup.hp.com>
	Jay Estabrook <Jay.Estabrook@compaq.com>
	Thomas Sailer <sailer@ife.ee.ethz.ch>
	Andrea Arcangeli <andrea@suse.de>
	Jens Axboe <jens.axboe@oracle.com>
	David Mosberger-Tang <davidm@hpl.hp.com>
