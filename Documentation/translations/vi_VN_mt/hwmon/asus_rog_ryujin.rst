.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/asus_rog_ryujin.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân asus_rog_ryujin
=============================

Các thiết bị được hỗ trợ:

* ASUS ROG RYUJIN II 360

Tác giả: Aleksa Savic

Sự miêu tả
-----------

Trình điều khiển này cho phép hỗ trợ giám sát phần cứng cho ASUS ROG RYUJIN được liệt kê
bộ làm mát chất lỏng CPU tất cả trong một. Cảm biến có sẵn là máy bơm, bên trong và bên ngoài
(bộ điều khiển) tốc độ quạt trong RPM, nhiệm vụ của chúng trong PWM, cũng như nhiệt độ nước làm mát.

Việc gắn quạt bên ngoài vào bộ điều khiển là tùy chọn và cho phép chúng
được điều khiển từ thiết bị. Nếu không được kết nối, các cảm biến liên quan đến quạt sẽ
báo cáo số không. Bộ điều khiển là một đơn vị phần cứng riêng biệt đi kèm
với AIO và kết nối với nó để cho phép điều khiển quạt.

Màn hình LCD có địa chỉ không được hỗ trợ trong trình điều khiển này và sẽ
được kiểm soát thông qua các công cụ không gian người dùng.

ghi chú sử dụng
-----------

Vì đây là các USB HID nên trình điều khiển có thể được tải tự động bởi kernel và
hỗ trợ trao đổi nóng.

Mục nhập hệ thống
-------------

=========== ==================================================
fan1_input Tốc độ bơm (tính bằng vòng/phút)
fan2_input Tốc độ quạt bên trong (tính bằng vòng/phút)
fan3_input Quạt bên ngoài (bộ điều khiển) 1 tốc độ (tính bằng vòng/phút)
fan4_input Quạt ngoài (bộ điều khiển) 2 tốc độ (tính bằng vòng/phút)
fan5_input Quạt bên ngoài (bộ điều khiển) 3 tốc độ (tính bằng vòng/phút)
fan6_input Quạt ngoài (bộ điều khiển) 4 tốc độ (tính bằng vòng/phút)
temp1_input Nhiệt độ nước làm mát (tính bằng mili độ C)
pwm1 Nhiệm vụ của máy bơm
pwm2 Nhiệm vụ của quạt bên trong
pwm3 Nhiệm vụ của quạt bên ngoài (bộ điều khiển)
=========== ==================================================