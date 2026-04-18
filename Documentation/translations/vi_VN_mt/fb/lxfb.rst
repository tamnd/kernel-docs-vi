.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/lxfb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
lxfb - Trình điều khiển bộ đệm khung AMD Geode LX
=================================================

Đây là trình điều khiển bộ đệm khung đồ họa cho bộ xử lý dựa trên AMD Geode LX.

Thuận lợi:

* Không cần sử dụng mã VSA của AMD (hoặc lớp mô phỏng VESA khác) trong
   BIOS.
 * Nó cung cấp một bảng điều khiển lớn đẹp mắt (128 cols + 48 dòng với 1024x768)
   không sử dụng các phông chữ nhỏ, không thể đọc được.
 * Bạn có thể chạy XF68_FBDev trên /dev/fb0
 * Quan trọng nhất: logo khởi động :-)

Nhược điểm:

* chế độ đồ họa chậm hơn chế độ văn bản...


Làm thế nào để sử dụng nó?
==========================

Việc chuyển đổi chế độ được thực hiện bằng cách sử dụng lxfb.mode_option=<độ phân giải>... boot
tham số hoặc sử dụng chương trình ZZ0000ZZ.

Xem Documentation/fb/modeb.rst để biết thêm thông tin về modem
nghị quyết.


X11
===

XF68_FBDev nhìn chung sẽ hoạt động tốt nhưng không được tăng tốc.


Cấu hình
=============

Bạn có thể chuyển các tùy chọn dòng lệnh kernel tới lxfb bằng lxfb.<option>.
Ví dụ: lxfb.mode_option=800x600@75.
Tùy chọn được chấp nhận:

========================================================================
mode_option chỉ định chế độ video.  Có dạng
		 <x>x<y>[-<bpp>][@<refresh>]
kích thước vram của ram video (thường được tự động phát hiện)
vt_switch cho phép chuyển đổi vt trong khi tạm dừng/tiếp tục.  vt
		 chuyển đổi chậm, nhưng vô hại.
========================================================================

Andres Salomon <dilinger@debian.org>
