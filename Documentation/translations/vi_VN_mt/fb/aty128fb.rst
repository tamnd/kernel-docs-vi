.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/aty128fb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
aty128fb - Trình điều khiển bộ đệm khung ATI Rage128
====================================================

Đây là trình điều khiển cho bộ đệm khung đồ họa cho các thiết bị dựa trên ATI Rage128
trên các hộp Intel và PPC.

Thuận lợi:

* Nó cung cấp một bảng điều khiển lớn đẹp mắt (128 cols + 48 dòng với 1024x768)
   không sử dụng các phông chữ nhỏ, không thể đọc được.
 * Bạn có thể chạy XF68_FBDev trên /dev/fb0
 * Quan trọng nhất: logo khởi động :-)

Nhược điểm:

* Chế độ đồ họa chậm hơn chế độ văn bản...nhưng bạn không nên để ý
   nếu bạn sử dụng độ phân giải giống như bạn đã sử dụng trong chế độ văn bản.
 * vẫn đang thử nghiệm.


Làm thế nào để sử dụng nó?
==============

Việc chuyển đổi chế độ được thực hiện bằng cách sử dụng video=aty128fb:<độ phân giải>... moddb
tham số khởi động hoặc sử dụng chương trình ZZ0000ZZ.

Xem Documentation/fb/modeb.rst để biết thêm thông tin về modem
nghị quyết.

Bạn nên biên dịch trong cả vgacon (để khởi động nếu bạn xóa Rage128 khỏi
box) và aty128fb (dành cho chế độ đồ họa). Bạn không nên biên dịch vesafb
trừ khi bạn có màn hình chính trên thiết bị VBE2.0 không phải Rage128 (xem
Tài liệu/fb/vesafb.rst để biết chi tiết).


X11
===

XF68_FBDev nhìn chung sẽ hoạt động tốt nhưng không được tăng tốc. Kể từ
tài liệu này, 8 và 32bpp hoạt động tốt.  Đã có vấn đề về bảng màu
khi chuyển từ X sang console và quay lại X. Bạn sẽ phải khởi động lại
X để khắc phục điều này.


Cấu hình
=============

Bạn có thể chuyển các tùy chọn dòng lệnh kernel cho vesafb bằng
ZZ0000ZZ (nhiều lựa chọn nên
được phân tách bằng dấu phẩy, các giá trị được phân tách khỏi các tùy chọn bằng ZZ0001ZZ).
Tùy chọn được chấp nhận:

======================================================================
noaccel không sử dụng động cơ tăng tốc. Đó là mặc định.
tăng tốc sử dụng động cơ tăng tốc. Chưa hoàn thành.
vmode:x chọn chế độ video PowerMacintosh <x>. Không dùng nữa.
cmode:x chọn chế độ màu PowerMacintosh <x>. Không dùng nữa.
<XxX@X> chọn chế độ video khởi động. Xem moddb.txt để biết chi tiết
	  lời giải thích. Mặc định là 640x480x8bpp.
======================================================================


Hạn chế
===========

Có những lỗi, tính năng và tính năng sai đã biết và chưa biết.
Hiện tại có các lỗi đã biết sau:

- Driver này vẫn đang thử nghiệm và chưa hoàn thiện.  Quá nhiều
   lỗi/lỗi để liệt kê ở đây.

Brad Douglas <brad@neruo.com>
