.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/gsc-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân gsc-hwmon
=======================

Chip được hỗ trợ: Gateworks GSC
Bảng dữ liệu: ZZ0000ZZ
Tác giả: Tim Harvey <tharvey@gateworks.com>

Sự miêu tả:
------------

Trình điều khiển này hỗ trợ giám sát phần cứng cho cảm biến nhiệt độ,
nhiều ADC khác nhau được kết nối với GSC và bộ điều khiển FAN tùy chọn có sẵn
trên một số bảng.


Giám sát điện áp
------------------

Điện áp đầu vào được điều chỉnh bên trong hoặc bởi trình điều khiển tùy thuộc vào
trên phiên bản và phần sụn GSC. Các giá trị được trình điều khiển trả về không cần
mở rộng quy mô hơn nữa. Nhãn đầu vào điện áp cung cấp tên đường ray điện áp:

inX_input Đo điện áp (mV).
inX_label Tên đường ray điện áp.


Giám sát nhiệt độ
----------------------

Nhiệt độ được đo với độ phân giải 12 bit hoặc 10 bit và được chia tỷ lệ
nội bộ hoặc bởi trình điều khiển tùy thuộc vào phiên bản và chương trình cơ sở GSC.
Các giá trị được trình điều khiển trả về phản ánh mili độ C:

tempX_input Đo nhiệt độ.
tempX_label Tên của nhiệt độ đầu vào.


Kiểm soát đầu ra PWM
------------------

GSC có 1 đầu ra PWM hoạt động ở chế độ tự động trong đó
Giá trị PWM sẽ được chia tỷ lệ tùy theo 6 ranh giới nhiệt độ.
Ranh giới nhiệt độ được đọc-ghi và tính bằng mili độ C và
Các giá trị PWM chỉ đọc nằm trong khoảng từ 0 (tắt) đến 255 (tốc độ tối đa).
Tốc độ quạt sẽ được đặt ở mức tối thiểu (tắt) khi cảm biến nhiệt độ đọc
nhỏ hơn pwm1_auto_point1_temp và tối đa khi cảm biến nhiệt độ
bằng hoặc vượt quá pwm1_auto_point6_temp.

Giá trị pwm1_auto_point[1-6]_pwm PWM.
pwm1_auto_point[1-6]_temp Biên nhiệt độ.
