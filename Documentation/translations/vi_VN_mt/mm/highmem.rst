.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/highmem.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Xử lý bộ nhớ cao
======================

Bởi: Peter Zijlstra <a.p.zijlstra@chello.nl>

.. contents:: :local:

Bộ nhớ cao là gì?
====================

Bộ nhớ cao (highmem) được sử dụng khi kích thước của bộ nhớ vật lý đạt tới hoặc
vượt quá kích thước tối đa của bộ nhớ ảo.  Tại thời điểm đó nó trở thành
kernel không thể giữ tất cả bộ nhớ vật lý có sẵn được ánh xạ
mọi lúc.  Điều này có nghĩa là kernel cần bắt đầu sử dụng ánh xạ tạm thời của
phần bộ nhớ vật lý mà nó muốn truy cập.

Phần bộ nhớ (vật lý) không được ánh xạ vĩnh viễn bao phủ là những gì chúng ta
gọi là 'highmem'.  Có nhiều ràng buộc phụ thuộc vào kiến trúc khác nhau trên
chính xác thì ranh giới đó nằm ở đâu.

Ví dụ: trong i386 Arch, chúng tôi chọn ánh xạ kernel vào mọi quy trình.
Dung lượng VM để chúng tôi không phải trả toàn bộ chi phí vô hiệu hóa TLB cho
vào/ra kernel.  Điều này có nghĩa là không gian bộ nhớ ảo khả dụng (4GiB trên
i386) phải được phân chia giữa không gian người dùng và kernel.

Sự phân chia truyền thống cho các kiến trúc sử dụng phương pháp này là 3:1, 3GiB cho
không gian người dùng và 1GiB hàng đầu cho không gian kernel ::

+--------+ 0xffffffff
		ZZ0000ZZ
		+--------+ 0xc0000000
		ZZ0001ZZ
		ZZ0002ZZ
		ZZ0003ZZ
		+--------+ 0x00000000

Điều này có nghĩa là kernel có thể ánh xạ tối đa 1GiB bộ nhớ vật lý vào bất kỳ bộ nhớ nào
thời gian, mà bởi vì chúng ta cần không gian địa chỉ ảo cho những thứ khác - bao gồm cả
bản đồ tạm thời để truy cập phần còn lại của bộ nhớ vật lý - trực tiếp thực tế
bản đồ thường sẽ ít hơn (thường khoảng ~ 896MiB).

Các kiến trúc khác có TLB được gắn thẻ ngữ cảnh mm có thể có hạt nhân riêng biệt
và bản đồ người dùng.  Tuy nhiên, một số phần cứng (như một số ARM) có hạn chế về ảo
khoảng trống khi họ sử dụng thẻ ngữ cảnh mm.


Ánh xạ ảo tạm thời
==========================

Hạt nhân chứa một số cách tạo ánh xạ tạm thời. Sau đây
danh sách hiển thị chúng theo thứ tự ưu tiên sử dụng.

* kmap_local_page(), kmap_local_folio() - Các hàm này dùng để tạo
  bản đồ ngắn hạn. Chúng có thể được gọi từ bất kỳ ngữ cảnh nào (bao gồm cả
  ngắt) nhưng ánh xạ chỉ có thể được sử dụng trong ngữ cảnh thu được
  họ. Sự khác biệt duy nhất giữa chúng bao gồm việc lấy con trỏ đầu tiên
  đến một trang cấu trúc và trang thứ hai lấy một con trỏ tới folio cấu trúc và byte
  phần bù trong folio xác định trang.

Những hàm này phải luôn được sử dụng, trong khi kmap_atomic() và kmap() có
  không còn được dùng nữa.

Các ánh xạ này là luồng cục bộ và CPU-cục bộ, nghĩa là ánh xạ
  chỉ có thể được truy cập từ bên trong luồng này và luồng này được liên kết với
  CPU trong khi ánh xạ đang hoạt động. Mặc dù quyền ưu tiên không bao giờ bị vô hiệu hóa bởi
  chức năng này, CPU không thể rút phích cắm khỏi hệ thống thông qua
  CPU-hotplug cho đến khi ánh xạ được xử lý.

Việc xác định lỗi trang trong vùng kmap cục bộ là hợp lệ, trừ khi ngữ cảnh
  trong đó bản đồ cục bộ được thu thập không cho phép nó vì những lý do khác.

Như đã nói, lỗi trang và quyền ưu tiên không bao giờ bị vô hiệu hóa. Không cần thiết phải
  vô hiệu hóa quyền ưu tiên vì khi ngữ cảnh chuyển sang một tác vụ khác,
  bản đồ của tác vụ gửi đi được lưu và bản đồ của tác vụ đến được lưu
  được khôi phục.

kmap_local_page(), cũng như kmap_local_folio() luôn trả về ảo hợp lệ
  địa chỉ kernel và giả định rằng kunmap_local() sẽ không bao giờ bị lỗi.

Trên hạt nhân CONFIG_HIGHMEM=n và đối với các trang có bộ nhớ thấp, chúng trả về
  địa chỉ ảo của ánh xạ trực tiếp. Chỉ có những trang highmem thực sự mới có
  được lập bản đồ tạm thời. Do đó, người dùng có thể gọi một page_address() đơn giản
  đối với các trang được biết là không đến từ ZONE_HIGHMEM. Tuy nhiên, nó là
  luôn an toàn khi sử dụng kmap_local_{page,folio}() / kunmap_local().

Mặc dù chúng nhanh hơn đáng kể so với kmap(), nhưng đối với trường hợp highmem, chúng
  đi kèm với những hạn chế về tính hợp lệ của con trỏ. Ngược lại với kmap()
  ánh xạ, ánh xạ cục bộ chỉ hợp lệ trong ngữ cảnh của người gọi
  và không thể chuyển sang bối cảnh khác. Điều này ngụ ý rằng người dùng phải
  hãy chắc chắn duy trì việc sử dụng địa chỉ trả lại cục bộ cho
  thread đã ánh xạ nó.

Hầu hết các mã có thể được thiết kế để sử dụng ánh xạ cục bộ của luồng. Người dùng nên
  do đó hãy cố gắng thiết kế mã của họ để tránh sử dụng kmap() bằng cách ánh xạ
  các trang trong cùng một chủ đề, địa chỉ sẽ được sử dụng và ưu tiên
  kmap_local_page() hoặc kmap_local_folio().

Việc lồng các ánh xạ kmap_local_page() và kmap_atomic() được cho phép ở một mức độ nhất định
  phạm vi (lên tới KMAP_TYPE_NR) nhưng lời gọi của chúng phải được sắp xếp nghiêm ngặt
  vì việc triển khai bản đồ dựa trên ngăn xếp. Xem kmap_local_page() kdocs
  (có trong phần "Chức năng") để biết chi tiết về cách quản lý các ứng dụng lồng nhau
  ánh xạ.

* kmap_atomic(). Chức năng này không còn được dùng nữa; sử dụng kmap_local_page().

NOTE: Chuyển đổi sang kmap_local_page() phải chú ý tuân theo ánh xạ
  các hạn chế áp đặt đối với kmap_local_page(). Hơn nữa, mã giữa
  các cuộc gọi tới kmap_atomic() và kunmap_atomic() có thể ngầm phụ thuộc vào phía
  ảnh hưởng của ánh xạ nguyên tử, tức là vô hiệu hóa lỗi trang hoặc quyền ưu tiên hoặc cả hai.
  Trong trường hợp đó, hãy gọi rõ ràng tới pagefault_disable() hoặc preempt_disable() hoặc
  cả hai phải được thực hiện cùng với việc sử dụng kmap_local_page().

[Tài liệu kế thừa]

Điều này cho phép ánh xạ thời gian rất ngắn của một trang.  Kể từ khi
  ánh xạ bị giới hạn ở CPU đã phát hành nó, nó hoạt động tốt, nhưng
  do đó nhiệm vụ phát hành bắt buộc phải ở trên CPU đó cho đến khi nó có
  đã hoàn thành, kẻo một số tác vụ khác sẽ thay thế ánh xạ của nó.

kmap_atomic() cũng có thể được sử dụng trong bối cảnh ngắt, vì nó không
  ngủ và người gọi cũng có thể không ngủ cho đến sau khi kunmap_atomic()
  được gọi.

Mỗi lệnh gọi kmap_atomic() trong kernel sẽ tạo ra một phần không được ưu tiên
  và vô hiệu hóa lỗi trang. Đây có thể là nguyên nhân gây ra độ trễ không mong muốn. Vì thế
  người dùng nên thích kmap_local_page() thay vì kmap_atomic().

Người ta cho rằng k[un]map_atomic() sẽ không thành công.

* kmap(). Chức năng này không còn được dùng nữa; sử dụng kmap_local_page().

NOTE: Chuyển đổi sang kmap_local_page() phải chú ý tuân theo ánh xạ
  các hạn chế áp đặt đối với kmap_local_page(). Đặc biệt, cần phải
  đảm bảo rằng con trỏ bộ nhớ ảo kernel chỉ hợp lệ trong luồng
  đã có được nó.

[Tài liệu kế thừa]

Điều này nên được sử dụng để tạo bản đồ trong thời gian ngắn của một trang mà không cần
  hạn chế về quyền ưu tiên hoặc di chuyển. Nó đi kèm với một chi phí chung như lập bản đồ
  không gian bị hạn chế và được bảo vệ bởi khóa toàn cầu để đồng bộ hóa. Khi nào
  ánh xạ không còn cần thiết nữa, địa chỉ mà trang được ánh xạ tới phải là
  được phát hành bằng kunmap().

Các thay đổi ánh xạ phải được truyền bá trên tất cả các CPU. kmap() cũng vậy
  yêu cầu vô hiệu hóa TLB toàn cầu khi nhóm kmap kết thúc và nó có thể
  chặn khi không gian ánh xạ được sử dụng hết cho đến khi một vị trí trở thành
  có sẵn. Do đó, kmap() chỉ có thể gọi được từ ngữ cảnh có sẵn.

Tất cả các công việc trên là cần thiết nếu việc lập bản đồ phải kéo dài trong một thời gian tương đối
  thời gian dài nhưng phần lớn ánh xạ bộ nhớ cao trong kernel
  tồn tại trong thời gian ngắn và chỉ được sử dụng ở một nơi. Điều này có nghĩa là chi phí của
  kmap() hầu như bị lãng phí trong những trường hợp như vậy. kmap() không được dự định lâu dài
  ánh xạ thuật ngữ nhưng nó đã biến đổi theo hướng đó và việc sử dụng nó là
  không khuyến khích sử dụng mã mới hơn và tập hợp các hàm trước đó
  nên được ưu tiên.

Trên hệ thống 64 bit, lệnh gọi tới kmap_local_page(), kmap_atomic() và kmap() có
  không có việc gì thực sự phải làm vì không gian địa chỉ 64-bit là quá đủ để
  giải quyết tất cả bộ nhớ vật lý có các trang được ánh xạ vĩnh viễn.

*vmap().  Điều này có thể được sử dụng để tạo một bản đồ trong thời gian dài của nhiều
  các trang vật lý vào một không gian ảo liền kề.  Nó cần toàn cầu
  đồng bộ hóa để hủy bản đồ.


Chi phí lập bản đồ tạm thời
===========================

Chi phí tạo ánh xạ tạm thời có thể khá cao.  Vòm phải
thao tác các bảng trang của kernel, dữ liệu TLB và/hoặc các thanh ghi của MMU.

Nếu CONFIG_HIGHMEM không được đặt thì kernel sẽ thử và tạo ánh xạ
chỉ cần một chút phép tính sẽ chuyển đổi địa chỉ cấu trúc trang thành
một con trỏ tới nội dung trang thay vì sắp xếp các ánh xạ.  Trong một
trường hợp, thao tác unmap có thể là thao tác rỗng.

Nếu CONFIG_MMU không được đặt thì không thể có ánh xạ tạm thời và không có
caomem.  Trong trường hợp đó, phương pháp số học cũng sẽ được sử dụng.


i386 PAE
========

Arch i386, trong một số trường hợp, sẽ cho phép bạn duy trì tối đa 64GiB
của RAM vào máy 32-bit của bạn.  Điều này có một số hậu quả:

* Linux cần cấu trúc khung trang cho mỗi trang trong hệ thống và
  khung trang cần phải tồn tại trong ánh xạ cố định, có nghĩa là:

* bạn có thể có tối đa 896M/sizeof(struct page) khung trang; với cấu trúc
  trang có kích thước 32 byte sẽ có kích thước khoảng 112G
  giá trị của trang; tuy nhiên, kernel cần lưu trữ nhiều thứ hơn là chỉ
  khung trang trong bộ nhớ đó ...

* PAE làm cho các bảng trang của bạn lớn hơn - điều này càng làm chậm hệ thống hơn
  dữ liệu phải được truy cập để duyệt qua trong phần điền TLB và những thứ tương tự.  một
  Ưu điểm là PAE có nhiều bit PTE hơn và có thể cung cấp các tính năng nâng cao
  như NX và PAT.

Khuyến nghị chung là bạn không nên sử dụng nhiều hơn 8GiB trên thiết bị 32 bit
máy móc - mặc dù nhiều thứ hơn có thể phù hợp với bạn và khối lượng công việc của bạn, nhưng bạn vẫn xinh đẹp
tự mình làm nhiều việc - đừng mong đợi các nhà phát triển kernel thực sự quan tâm nhiều nếu mọi thứ
tách ra.


Chức năng
=========

.. kernel-doc:: include/linux/highmem.h
.. kernel-doc:: mm/highmem.c
.. kernel-doc:: include/linux/highmem-internal.h
