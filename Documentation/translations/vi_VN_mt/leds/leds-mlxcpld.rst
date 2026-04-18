.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-mlxcpld.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================
Trình điều khiển hạt nhân cho đèn LED hệ thống Mellanox
=======================================

Cung cấp hệ thống hỗ trợ LED cho hệ thống Mellanox tiếp theo:
"msx6710", "msx6720", "msb7700", "msn2700", "msx1410",
"msn2410", "msb7800", "msn2740", "msn2100".

Sự miêu tả
-----------
Trình điều khiển cung cấp các đèn LED sau cho hệ thống "msx6710", "msx6720",
"msb7700", "msn2700", "msx1410", "msn2410", "msb7800", "msn2740":

- mlxcpld:fan1:xanh
  - mlxcpld:fan1:đỏ
  - mlxcpld:fan2:xanh
  - mlxcpld:fan2:đỏ
  - mlxcpld:fan3:xanh
  - mlxcpld:fan3:đỏ
  - mlxcpld:fan4:xanh
  - mlxcpld:fan4:đỏ
  - mlxcpld:psu:xanh
  - mlxcpld:psu:đỏ
  - mlxcpld:trạng thái:màu xanh lá cây
  - mlxcpld:trạng thái:đỏ

"trạng thái"
  - Độ lệch reg CPLD: 0x20
  - Bit [3:0]

"psu"
  - Độ lệch reg CPLD: 0x20
  - Bit [7:4]

"fan1"
  - Độ lệch reg CPLD: 0x21
  - Bit [3:0]

"fan2"
  - Độ lệch reg CPLD: 0x21
  - Bit [7:4]

"fan3"
  - Độ lệch reg CPLD: 0x22
  - Bit [3:0]

"fan4"
  - Độ lệch reg CPLD: 0x22
  - Bit [7:4]

Mặt nạ màu cho tất cả các đèn LED trên:

[bit3,bit2,bit1,bit0] hoặc
  [bit7,bit6,bit5,bit4]:

- [0,0,0,0] = LED OFF
	- [0,1,0,1] = BẬT tĩnh màu đỏ
	- [1,1,0,1] = BẬT tĩnh xanh
	- [0,1,1,0] = Nhấp nháy đỏ 3Hz
	- [1,1,1,0] = Xanh nhấp nháy 3Hz
	- [0,1,1,1] = Nhấp nháy đỏ 6Hz
	- [1,1,1,1] = Nhấp nháy xanh 6Hz

Trình điều khiển cung cấp các đèn LED sau cho hệ thống "msn2100":

- mlxcpld:quạt:xanh
  - mlxcpld:quạt:đỏ
  - mlxcpld:psu1:xanh
  - mlxcpld:psu1:đỏ
  - mlxcpld:psu2:xanh
  - mlxcpld:psu2:đỏ
  - mlxcpld:trạng thái:màu xanh lá cây
  - mlxcpld:trạng thái:đỏ
  - mlxcpld:uid:blue

"trạng thái"
  - Độ lệch reg CPLD: 0x20
  - Bit [3:0]

"quạt"
  - Độ lệch reg CPLD: 0x21
  - Bit [3:0]

"psu1"
  - Độ lệch reg CPLD: 0x23
  - Bit [3:0]

"psu2"
  - Độ lệch reg CPLD: 0x23
  - Bit [7:4]

"uid"
  - Độ lệch reg CPLD: 0x24
  - Bit [3:0]

Mặt nạ màu cho tất cả các đèn LED ở trên, ngoại trừ uid:

[bit3,bit2,bit1,bit0] hoặc
  [bit7,bit6,bit5,bit4]:

- [0,0,0,0] = LED OFF
	- [0,1,0,1] = BẬT tĩnh màu đỏ
	- [1,1,0,1] = BẬT tĩnh xanh
	- [0,1,1,0] = Nhấp nháy đỏ 3Hz
	- [1,1,1,0] = Xanh nhấp nháy 3Hz
	- [0,1,1,1] = Nhấp nháy đỏ 6Hz
	- [1,1,1,1] = Nhấp nháy xanh 6Hz

Mặt nạ màu cho uid LED:
  [bit3,bit2,bit1,bit0]:

- [0,0,0,0] = LED OFF
	- [1,1,0,1] = BẬT tĩnh màu xanh
	- [1,1,1,0] = Nhấp nháy màu xanh 3Hz
	- [1,1,1,1] = Nhấp nháy màu xanh 6Hz

Trình điều khiển hỗ trợ nhấp nháy CTNH ở tần số 3Hz và 6Hz (chu kỳ hoạt động 50%).
Đối với chu kỳ nhiệm vụ 3Hz là khoảng 167 mili giây, đối với 6Hz là khoảng 83 mili giây.
