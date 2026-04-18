.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/aspeed-g6-pwm-tach.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân aspeed-g6-pwm-tach
============================================

Chip được hỗ trợ:
	ASPEED AST2600

tác giả:
	<billy_tsai@aspeedtech.com>

Sự miêu tả:
------------
Trình điều khiển này triển khai hỗ trợ cho bộ điều khiển ASPEED AST2600 Fan Tacho.
Bộ điều khiển hỗ trợ tới 16 đầu vào máy đo tốc độ.

Trình điều khiển cung cấp các quyền truy cập cảm biến sau trong sysfs:

====================== ===========================================================
fanX_input ro cung cấp giá trị vòng quay quạt hiện tại trong RPM như đã báo cáo
			từ quạt tới thiết bị.
fanX_div rw Ước số quạt: Giá trị được hỗ trợ là lũy thừa 4 (1, 4, 16
                        64, ... 4194304)
                        Số chia càng lớn thì độ chính xác vòng quay càng thấp và càng ít
                        bị ảnh hưởng bởi trục trặc tín hiệu quạt.
====================== ===========================================================