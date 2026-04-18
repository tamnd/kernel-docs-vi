.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/cgbc-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân cgbc-hwmon
========================

Chip được hỗ trợ:

* Ban Kiểm soát Congatec.

Tiền tố: 'cgbc-hwmon'

Tác giả: Thomas Richard <thomas.richard@bootlin.com>

Sự miêu tả
-----------

Trình điều khiển này cho phép hỗ trợ giám sát cho Bộ điều khiển Congatec Board.
Bộ điều khiển này được nhúng trên SoM x86 của Congatec.

Mục nhập hệ thống
-------------

Danh sách mục sysfs sau đây chứa tất cả các cảm biến được xác định trong Bảng
Người điều khiển. Các cảm biến có sẵn trong sysfs phụ thuộc vào SoM và
hệ thống.

======================================
Tên Mô tả
======================================
nhiệt độ temp1_input CPU
temp2_input Nhiệt độ hộp
temp3_input Nhiệt độ môi trường
temp4_input Nhiệt độ bảng
temp5_input Nhiệt độ sóng mang
temp6_input Nhiệt độ chipset
temp7_input Nhiệt độ video
temp8_input Nhiệt độ khác
nhiệt độ temp9_input TOPDIM
nhiệt độ temp10_input BOTTOMDIM
in0_input CPU điện áp
in1_input DC Điện áp thời gian chạy
in2_input DC Điện áp dự phòng
in3_input CMOS Điện áp pin
in4_input Điện áp pin
điện áp xoay chiều in5_input
in6_input Điện áp khác
in7_input điện áp 5V
in8_input 5V Điện áp dự phòng
điện áp in9_input 3V3
in10_input 3V3 Điện áp dự phòng
in11_input VCore A điện áp
điện áp VCore B in12_input
đầu vào13_input điện áp 12V
dòng điện một chiều curr1_input
curr2_input dòng điện 5V
curr3_input dòng điện 12V
fan1_input Quạt CPU
fan2_input Quạt hộp
fan3_input Quạt xung quanh
fan4_input Quạt Chipset
fan5_input Người hâm mộ video
fan6_input Người hâm mộ khác
======================================