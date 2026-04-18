.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/aspeed-g6-pwm-tach.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân aspeed-g6-pwm-tach
=================================

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