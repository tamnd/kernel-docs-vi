.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/booting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Khởi động ARM Linux
=================

Tác giả: Russell King

Ngày: 18 tháng 5 năm 2002

Tài liệu sau đây có liên quan đến 2.4.18-rmk6 trở lên.

Để khởi động ARM Linux, bạn cần có bộ tải khởi động, một bộ tải khởi động nhỏ
chương trình chạy trước kernel chính.  Bộ tải khởi động được mong đợi
để khởi tạo các thiết bị khác nhau và cuối cùng gọi nhân Linux,
truyền thông tin tới kernel.

Về cơ bản, bộ tải khởi động phải cung cấp (tối thiểu)
sau đây:

1. Thiết lập và khởi tạo RAM.
2. Khởi tạo một cổng nối tiếp.
3. Phát hiện loại máy.
4. Thiết lập danh sách gắn thẻ kernel.
5. Tải initramfs.
6. Gọi hình ảnh hạt nhân.


1. Thiết lập và khởi tạo RAM
---------------------------

Bộ tải khởi động hiện có:
	MANDATORY
Bộ tải khởi động mới:
	MANDATORY

Bộ tải khởi động dự kiến sẽ tìm và khởi tạo tất cả RAM mà
kernel sẽ sử dụng để lưu trữ dữ liệu dễ bay hơi trong hệ thống.  Nó thực hiện
điều này theo cách phụ thuộc vào máy.  (Nó có thể sử dụng các thuật toán nội bộ
để tự động định vị và định kích thước tất cả RAM hoặc có thể sử dụng kiến thức về
RAM trong máy hoặc bất kỳ phương pháp nào khác mà nhà thiết kế bộ tải khởi động
thấy phù hợp.)


2. Khởi tạo một cổng nối tiếp
-----------------------------

Bộ tải khởi động hiện có:
	OPTIONAL, RECOMMENDED
Bộ tải khởi động mới:
	OPTIONAL, RECOMMENDED

Bộ tải khởi động sẽ khởi tạo và kích hoạt một cổng nối tiếp trên
mục tiêu.  Điều này cho phép trình điều khiển nối tiếp kernel tự động phát hiện
nên sử dụng cổng nối tiếp nào cho bảng điều khiển kernel (nói chung
được sử dụng cho mục đích gỡ lỗi hoặc liên lạc với mục tiêu.)

Để thay thế, bộ tải khởi động có thể chuyển 'console=' có liên quan
tùy chọn cho kernel thông qua danh sách được gắn thẻ chỉ định cổng và
tùy chọn định dạng nối tiếp như được mô tả trong

Tài liệu/admin-guide/kernel-parameters.rst.


3. Phát hiện loại máy
--------------------------

Bộ tải khởi động hiện có:
	OPTIONAL
Bộ tải khởi động mới:
	MANDATORY ngoại trừ nền tảng chỉ DT

Bộ tải khởi động sẽ phát hiện loại máy đang chạy bởi một số
phương pháp.  Cho dù đây là một giá trị được mã hóa cứng hay một thuật toán nào đó
xem xét phần cứng được kết nối nằm ngoài phạm vi của tài liệu này.
Bộ tải khởi động cuối cùng phải có khả năng cung cấp MACH_TYPE_xxx
giá trị cho kernel. (xem linux/arch/arm/tools/mach-types).  Cái này
nên được chuyển tới kernel trong thanh ghi r1.

Đối với nền tảng chỉ DT, loại máy sẽ được xác định theo thiết bị
cây.  đặt loại máy thành tất cả loại (~0).  Điều này không nghiêm túc
cần thiết, nhưng đảm bảo rằng nó sẽ không khớp với bất kỳ loại hiện có nào.

4. Thiết lập dữ liệu khởi động
------------------

Bộ tải khởi động hiện có:
	OPTIONAL, HIGHLY RECOMMENDED
Bộ tải khởi động mới:
	MANDATORY

Bộ tải khởi động phải cung cấp danh sách được gắn thẻ hoặc hình ảnh dtb cho
truyền dữ liệu cấu hình tới kernel.  Địa chỉ vật lý của
dữ liệu khởi động được chuyển tới kernel trong thanh ghi r2.

4a. Thiết lập danh sách được gắn thẻ kernel
--------------------------------

Bộ tải khởi động phải tạo và khởi tạo danh sách được gắn thẻ kernel.
Danh sách được gắn thẻ hợp lệ bắt đầu bằng ATAG_CORE và kết thúc bằng ATAG_NONE.
Thẻ ATAG_CORE có thể trống hoặc không trống.  Thẻ ATAG_CORE trống
có trường kích thước được đặt thành '2' (0x00000002).  ATAG_NONE phải đặt
trường kích thước về 0.

Bất kỳ số lượng thẻ có thể được đặt trong danh sách.  Nó không được xác định
liệu thẻ lặp lại có gắn thêm vào thông tin được mang theo hay không
thẻ trước đó hoặc liệu nó có thay thế thông tin trong thẻ đó hay không.
toàn bộ; một số thẻ hoạt động như trước, một số khác hoạt động như sau.

Bộ tải khởi động tối thiểu phải vượt qua kích thước và vị trí của
bộ nhớ hệ thống và vị trí hệ thống tập tin gốc.  Vì vậy,
danh sách được gắn thẻ tối thiểu sẽ trông::

+----------+
  căn cứ -> ZZ0000ZZ |
		+----------+ |
		ZZ0001ZZ | tăng địa chỉ
		+----------+ |
		ZZ0002ZZ |
		+----------+v

Danh sách được gắn thẻ phải được lưu trữ trong hệ thống RAM.

Danh sách được gắn thẻ phải được đặt trong một vùng bộ nhớ mà không có
bộ giải nén kernel cũng như chương trình 'bootp' initrd sẽ ghi đè
nó.  Vị trí được đề xuất là ở 16KiB đầu tiên của RAM.

4b. Thiết lập cây thiết bị
-------------------------

Bộ tải khởi động phải tải hình ảnh cây thiết bị (dtb) vào ram hệ thống
tại địa chỉ được căn chỉnh 64 bit và khởi tạo nó bằng dữ liệu khởi động.  các
định dạng dtb được ghi lại tại ZZ0000ZZ
Kernel sẽ tìm giá trị ma thuật dtb của 0xd00dfeed tại dtb
địa chỉ vật lý để xác định xem một dtb đã được truyền thay vì một
danh sách được gắn thẻ.

Bộ tải khởi động tối thiểu phải vượt qua kích thước và vị trí của
bộ nhớ hệ thống và vị trí hệ thống tập tin gốc.  Dtb phải là
được đặt trong một vùng bộ nhớ nơi bộ giải nén kernel sẽ không
ghi đè lên nó, trong khi vẫn ở trong vùng sẽ được bao phủ
bằng ánh xạ bộ nhớ thấp của kernel.

Vị trí an toàn nằm ngay phía trên ranh giới 128MiB kể từ khi bắt đầu RAM.

5. Tải initramfs.
------------------

Bộ tải khởi động hiện có:
	OPTIONAL
Bộ tải khởi động mới:
	OPTIONAL

Nếu initramfs được sử dụng thì cũng như với dtb, nó phải được đặt trong
một vùng bộ nhớ nơi bộ giải nén kernel sẽ không ghi đè lên nó
đồng thời với vùng sẽ được bao phủ bởi kernel
ánh xạ bộ nhớ thấp.

Một vị trí an toàn nằm ngay phía trên đốm màu của cây thiết bị.
được tải ngay phía trên ranh giới 128MiB kể từ khi bắt đầu RAM dưới dạng
được đề xuất ở trên.

6. Gọi ảnh kernel
---------------------------

Bộ tải khởi động hiện có:
	MANDATORY
Bộ tải khởi động mới:
	MANDATORY

Có hai lựa chọn để gọi kernel zImage.  Nếu zImage
được lưu trữ trong flash và được liên kết chính xác để chạy từ flash,
thì việc bộ tải khởi động gọi zImage trong flash là hợp pháp
trực tiếp.

zImage cũng có thể được đặt trong hệ thống RAM và được gọi ở đó.  các
kernel phải được đặt trong 128MiB đầu tiên của RAM.  Nó được khuyến khích
rằng nó được tải trên 32MiB để tránh phải di dời
trước khi giải nén, điều này sẽ khiến quá trình khởi động hơi khó khăn.
nhanh hơn.

Khi khởi động kernel thô (không phải zImage), các ràng buộc sẽ chặt chẽ hơn.
Trong trường hợp này, hạt nhân phải được tải ở một vị trí bù vào hệ thống bằng
tới TEXT_OFFSET - PAGE_OFFSET.

Trong mọi trường hợp, các điều kiện sau phải được đáp ứng:

- Tắt tất cả các thiết bị có khả năng DMA để không nhận được bộ nhớ
  bị hỏng bởi các gói mạng hoặc dữ liệu đĩa không có thật. Điều này sẽ tiết kiệm
  bạn có nhiều giờ gỡ lỗi.

- Cài đặt đăng ký CPU

- r0 = 0,
  - r1 = số loại máy được phát hiện ở (3) trên.
  - r2 = địa chỉ vật lý của danh sách được gắn thẻ trong hệ thống RAM, hoặc
    địa chỉ vật lý của khối cây thiết bị (dtb) trong hệ thống RAM

- Chế độ CPU

Tất cả các dạng ngắt phải bị vô hiệu hóa (IRQ và FIQ)

Đối với các CPU không bao gồm phần mở rộng ảo hóa ARM,
  CPU phải ở chế độ SVC.  (Có một ngoại lệ đặc biệt dành cho Angel)

Các CPU có hỗ trợ các phần mở rộng ảo hóa có thể
  được nhập ở chế độ HYP để cho phép kernel tận dụng tối đa
  những phần mở rộng này.  Đây là phương pháp khởi động được khuyến nghị cho các CPU như vậy,
  trừ khi các ảo hóa đã được sử dụng bởi một cài đặt sẵn
  siêu giám sát.

Nếu kernel không được nhập vào chế độ HYP vì bất kỳ lý do gì thì nó phải được
  được nhập ở chế độ SVC.

- Bộ nhớ đệm, MMU

MMU phải tắt.

Bộ đệm hướng dẫn có thể bật hoặc tắt.

Bộ đệm dữ liệu phải được tắt.

Nếu kernel được nhập ở chế độ HYP, các yêu cầu trên sẽ áp dụng cho
  cấu hình chế độ HYP ngoài PL1 thông thường (đặc quyền
  cấu hình chế độ kernel).  Ngoài ra, tất cả các bẫy vào
  bộ ảo hóa phải bị vô hiệu hóa và quyền truy cập PL1 phải được cấp cho tất cả
  thiết bị ngoại vi và tài nguyên CPU mà về mặt kiến trúc
  có thể.  Ngoại trừ việc vào chế độ HYP, cấu hình hệ thống
  phải là một hạt nhân không bao gồm sự hỗ trợ cho
  tiện ích mở rộng ảo hóa có thể khởi động chính xác mà không cần trợ giúp thêm.

- Bộ nạp khởi động dự kiến sẽ gọi ảnh hạt nhân bằng cách nhảy
  trực tiếp đến lệnh đầu tiên của ảnh hạt nhân.

Trên các CPU hỗ trợ tập lệnh ARM, mục nhập phải là
  được tạo ở trạng thái ARM, ngay cả đối với hạt nhân Thumb-2.

Trên các CPU chỉ hỗ trợ tập lệnh Thumb như
  CPU lớp Cortex-M, mục nhập phải được thực hiện ở trạng thái Thumb.
