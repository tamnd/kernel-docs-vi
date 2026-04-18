.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/qnap-mcu-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân qnap-mcu-hwmon
========================================

Trình điều khiển này cho phép sử dụng tính năng giám sát phần cứng và điều khiển quạt
của MCU được sử dụng trên một số thiết bị lưu trữ gắn mạng QNAP.

Tác giả: Heiko Stuebner <heiko@sntech.de>

Sự miêu tả
-----------

Trình điều khiển thực hiện một giao diện đơn giản để điều khiển quạt được điều khiển bởi
cài đặt giá trị đầu ra PWM của nó và hiển thị vòng tua máy và nhiệt độ vỏ máy
tới không gian người dùng thông qua giao diện sysfs của hwmon.

Tốc độ quay của quạt được trả về thông qua 'fan1_input' tùy chọn được tính toán
bên trong thiết bị MCU.

Trình điều khiển cung cấp các quyền truy cập cảm biến sau trong sysfs:

====================== =============================================================
fan1_input ro máy đo tốc độ quạt trong RPM
pwm1 rw tốc độ tương đối (0-255), 255=max. tốc độ.
temp1_input ro Nhiệt độ đo được tính bằng millicelsius
====================== =============================================================