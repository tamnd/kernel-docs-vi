.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/frame-buffer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thư viện bộ đệm khung
====================

Trình điều khiển bộ đệm khung phụ thuộc rất nhiều vào bốn cấu trúc dữ liệu. Những cái này
cấu trúc được khai báo trong include/linux/fb.h. Họ là fb_info,
fb_var_screeninfo, fb_fix_screeninfo và fb_monospecs. cuối cùng
ba có thể được cung cấp đến và đi từ vùng đất người dùng.

fb_info xác định trạng thái hiện tại của một card màn hình cụ thể. Bên trong
fb_info, tồn tại cấu trúc fb_ops là tập hợp các
các chức năng cần thiết để fbdev và fbcon hoạt động. fb_info chỉ hiển thị
tới hạt nhân.

fb_var_screeninfo được sử dụng để mô tả các tính năng của card màn hình
được người dùng xác định. Với fb_var_screeninfo, những thứ như độ sâu
và độ phân giải có thể được xác định.

Cấu trúc tiếp theo là fb_fix_screeninfo. Điều này xác định các thuộc tính
của thẻ được tạo khi một chế độ được đặt và không thể thay đổi
mặt khác. Một ví dụ điển hình về điều này là sự bắt đầu của bộ đệm khung
trí nhớ. Việc này "khóa" địa chỉ của bộ nhớ đệm khung để nó
không thể thay đổi hoặc di chuyển.

Cấu trúc cuối cùng là fb_monospecs. Trong API cũ, có rất ít
tầm quan trọng đối với fb_monospecs. Điều này cho phép những điều bị cấm như
cài đặt chế độ 800x600 trên màn hình tần số cố định. Với API mới,
fb_monospecs ngăn chặn những điều như vậy và nếu được sử dụng đúng cách, có thể ngăn chặn
theo dõi không bị nấu chín. fb_monospecs sẽ không hữu ích cho đến khi
hạt nhân 2.5.x.

Bộ nhớ đệm khung
-------------------

.. kernel-doc:: drivers/video/fbdev/core/fbmem.c
   :export:

Bản đồ màu đệm khung
---------------------

.. kernel-doc:: drivers/video/fbdev/core/fbcmap.c
   :export:

Cơ sở dữ liệu chế độ video đệm khung
--------------------------------

.. kernel-doc:: drivers/video/fbdev/core/modedb.c
   :internal:

.. kernel-doc:: drivers/video/fbdev/core/modedb.c
   :export:

Bộ đệm khung Cơ sở dữ liệu chế độ video Macintosh
------------------------------------------

.. kernel-doc:: drivers/video/fbdev/macmodes.c
   :export:

Phông chữ đệm khung
------------------

Tham khảo tệp lib/fonts/fonts.c để biết thêm thông tin.

