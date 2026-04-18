.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/aspeed-pwm-tacho.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân aspeed-pwm-tacho
==============================

Chip được hỗ trợ:
	ASPEED AST2400/2500

tác giả:
	<jaghu@google.com>

Sự miêu tả:
------------
Trình điều khiển này triển khai hỗ trợ cho ASPEED AST2400/2500 PWM và Fan Tacho
bộ điều khiển. Bộ điều khiển PWM hỗ trợ tối đa 8 đầu ra PWM. Người hâm mộ tacho
bộ điều khiển hỗ trợ lên đến 16 đầu vào máy đo tốc độ.

Trình điều khiển cung cấp các quyền truy cập cảm biến sau trong sysfs:

====================== ===========================================================
fanX_input ro cung cấp giá trị vòng quay quạt hiện tại trong RPM như đã báo cáo
			từ quạt tới thiết bị.

pwmX rw nhận hoặc đặt giá trị điều khiển quạt PWM. Đây là một số nguyên
			giá trị trong khoảng từ 0 (tắt) đến 255 (tốc độ tối đa).
====================== ===========================================================
