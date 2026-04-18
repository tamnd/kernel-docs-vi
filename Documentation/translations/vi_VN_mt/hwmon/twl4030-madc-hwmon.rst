.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/twl4030-madc-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân twl4030-madc
==========================

Chip được hỗ trợ:

* Dụng cụ Texas TWL4030

Tiền tố: 'twl4030-madc'


tác giả:
	J Keerthy <j-keerthy@ti.com>

Sự miêu tả
-----------

Texas Instruments TWL4030 là Mạch âm thanh và quản lý nguồn. Trong số
những thứ khác, nó chứa bộ chuyển đổi A/D 10 bit MADC. Bộ chuyển đổi có 16
các kênh có thể được sử dụng ở các chế độ khác nhau.


Xem bảng này để biết ý nghĩa của các kênh khác nhau

======= ===============================================================
Tín hiệu kênh
======= ===============================================================
0 Loại pin(BTYPE)
1 BCI: Nhiệt độ pin (BTEMP)
Đầu vào tương tự 2 GP
Đầu vào tương tự 3 GP
Đầu vào tương tự 4 GP
Đầu vào tương tự 5 GP
Đầu vào tương tự 6 GP
Đầu vào tương tự 7 GP
8 BCI: Điện áp VBUS (VBUS)
9 Điện áp pin dự phòng (VBKP)
10 BCI: Dòng sạc pin (ICHG)
11 BCI: Điện áp sạc pin (VCHG)
12 BCI: Điện áp pin chính (VBAT)
13 Dự trữ
14 Dự trữ
15 VRUSB Mức phân cực nguồn/Loa trái/Loa phải
======= ===============================================================


Các nút Sysfs sẽ biểu thị điện áp theo đơn vị mV,
kênh nhiệt độ hiển thị nhiệt độ được chuyển đổi trong
độ C. Kênh dòng điện sạc pin đại diện cho
dòng sạc pin tính bằng mA.
