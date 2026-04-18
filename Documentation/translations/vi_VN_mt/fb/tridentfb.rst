.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/tridentfb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
đinh bafb
==========

Tridentfb là trình điều khiển bộ đệm khung cho một số thẻ dựa trên chip Trident.

Danh sách chip sau đây được cho là được hỗ trợ mặc dù không phải tất cả đều được hỗ trợ
đã thử nghiệm:

những sản phẩm thuộc dòng TGUI 9440/96XX và có tên Cyber
những người trong loạt Hình ảnh và có Cyber ​​trong tên của họ
những người có tên Blade (Blade3D, CyberBlade...)
dòng CyberBladeXP mới hơn

Tất cả các gia đình đều được tăng tốc. Chỉ hỗ trợ thẻ dựa trên PCI/AGP,
không có chiếc Trident cũ nào cả.
Trình điều khiển hỗ trợ độ sâu 8, 16 và 32 bit cho mỗi pixel.
Họ TGUI yêu cầu độ dài đường dây có lũy thừa bằng 2 nếu khả năng tăng tốc
được kích hoạt. Điều này có nghĩa là phạm vi độ phân giải có thể có và bpp là
bị giới hạn so với phạm vi nếu khả năng tăng tốc bị tắt (xem danh sách
các thông số dưới đây).

Các lỗi đã biết:

1. Driver khóa ngẫu nhiên chip 3DImage975 với khả năng tăng tốc
   đã bật. Điều tương tự cũng xảy ra trong X11 (Xorg).
2. Tốc độ ramdac yêu cầu tinh chỉnh nhiều hơn. Có thể
   chuyển đổi độ phân giải mà chip không hỗ trợ ở một số độ sâu
   chip cũ hơn.

Làm thế nào để sử dụng nó?
==============

Khi khởi động, bạn có thể truyền tham số video ::

video=cây đinh bafb

Các tham số cho tridentfb được nối với nhau bằng ':' như trong ví dụ này::

video=tridentfb:800x600-16@75,noaccel

Các tham số cấp độ thứ hai mà tridentfb hiểu là:

====================================================================================
noaccel tắt khả năng tăng tốc (khi nó không hoạt động với thẻ của bạn)

fp sử dụng những thứ liên quan đến màn hình phẳng
crt giả sử màn hình có mặt thay vì fp

trung tâm dành cho màn hình phẳng và độ phân giải nhỏ hơn trung tâm kích thước gốc
	  hình ảnh, nếu không thì sử dụng
căng ra

giá trị số nguyên memsize tính bằng KB, hãy sử dụng nếu kích thước bộ nhớ thẻ của bạn bị phát hiện sai.
	  nhìn vào đầu ra của trình điều khiển để xem nó nói gì khi khởi tạo.

giá trị số nguyên memdiff tính bằng KB, phải khác 0 nếu thẻ của bạn báo cáo
	  nhiều bộ nhớ hơn thực tế nó có. Ví dụ: của tôi nhỏ hơn 192K
	  phát hiện cho biết trong cả ba tình huống có thể lựa chọn BIOS 2M, 4M, 8M.
	  Chỉ sử dụng nếu bộ nhớ video của bạn được lấy từ bộ nhớ chính do đó
	  kích thước có thể cấu hình. Nếu không thì hãy sử dụng memsize.
	  Nếu ở một số chế độ hầu như không vừa với bộ nhớ, bạn thấy rác
	  ở phía dưới, điều này có thể hữu ích bằng cách không cho phép thay đổi chế độ đó
	  nữa.

bản địax chiều rộng tính bằng pixel của màn hình phẳng. Nếu bạn biết điều đó (thường là 1024
	  800 hoặc 1280) và dường như trình điều khiển không phát hiện được việc sử dụng nó.

bit bpp trên mỗi pixel (8,16 hoặc 32)
chế độ tên chế độ như 800x600-8@75 như được mô tả trong
	  Tài liệu/fb/modeb.rst
====================================================================================

Việc sử dụng các giá trị điên rồ cho các tham số trên có thể sẽ dẫn đến lỗi driver
hành vi sai trái vì vậy hãy cẩn thận (ví dụ memsize=12345678 hoặc memdiff=23784 hoặc
bản địax=93)

Liên hệ: jani@astechnix.ro
