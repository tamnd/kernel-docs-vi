.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/kfan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân kfan
==============================

Chip được hỗ trợ:

* Bộ điều khiển quạt KEBA (lõi IP trong FPGA)

Tiền tố: 'kfan'

tác giả:

Gerhard Engleder <eg@keba.com>
	Petar Bojanic <boja@keba.com>

Sự miêu tả
-----------

Bộ điều khiển quạt KEBA là lõi IP cho FPGA, giúp theo dõi tình trạng
và điều khiển tốc độ quạt. Quạt thường được sử dụng để làm mát CPU
và toàn bộ thiết bị. Ví dụ: CP500 FPGA bao gồm lõi IP này để giám sát
và điều khiển quạt của PLC và trình điều khiển cp500 tương ứng tạo ra
thiết bị phụ trợ cho trình điều khiển kfan.

Trình điều khiển này cung cấp thông tin về tình trạng của quạt cho không gian người dùng.
Không gian người dùng sẽ được thông báo nếu quạt bị tháo hoặc bị chặn.
Ngoài ra, tốc độ trong RPM được báo cáo cho quạt có tín hiệu tacho.

Để điều khiển quạt PWM được hỗ trợ. Đối với PWM 255 bằng 100%. Không thể điều chỉnh
quạt có thể được bật bằng PWM 255 và tắt bằng PWM 0.

======================= ==== ========================================================
Nội dung R/W thuộc tính
======================= ==== ========================================================
fan1_fault R Lỗi quạt
fan1_input R Đầu vào máy đo tốc độ quạt (ở RPM)
pwm1 RW Chu kỳ nhiệm vụ mục tiêu của quạt (0..255)
======================= ==== ========================================================