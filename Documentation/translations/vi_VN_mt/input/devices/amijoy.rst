.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/amijoy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Cần điều khiển Amiga
===============

Sơ đồ chân
=======

Amiga 4 phím điều khiển mở rộng cổng song song
----------------------------------------

Chân cổng song song:

===== ========= ==== ===========
Ý nghĩa của ghim Ý nghĩa của ghim
===== ========= ==== ===========
 2 Lên1 6 Lên2
 3 Xuống1 7 Xuống2
 4 trái1 8 trái2
 5 Đúng1 9 Đúng2
13 Lửa1 11 Lửa2
19 Gnd1 18 Gnd2
===== ========= ==== ===========

Cần điều khiển kỹ thuật số Amiga
----------------------

=== =============
Ý nghĩa của ghim
=== =============
1 lên
2 xuống
3 trái
4 Đúng
5 n/c
6 Nút bắn
7 +5V (50mA)
8 Gnd
9 Nút ngón tay cái
=== =============

Chuột Amiga
-----------

=== =============
Ý nghĩa của ghim
=== =============
1 xung V
2 xung H
3 xung VQ
4 xung HQ
5 Nút giữa
6 Nút trái
7 +5V (50mA)
8 Gnd
9 Nút phải
=== =============

Cần điều khiển tương tự Amiga
---------------------

=== ================
Ý nghĩa của ghim
=== ================
1 nút trên cùng
2 nút Top2
3 Nút kích hoạt
4 Nút ngón tay cái
5 Tương tự X
6 n/c
7 +5V (50mA)
8 Gnd
9 Tương tự Y
=== ================

bút đèn Amiga
--------------

=== ===============
Ý nghĩa của ghim
=== ===============
1 n/c
2 n/c
3 n/c
4 n/c
5 Nút cảm ứng
6 / Kích hoạt chùm tia
7 +5V (50mA)
8 Gnd
9 Nút bút cảm ứng
=== ===============

Đăng ký địa chỉ
==================

JOY0DAT/JOY1DAT
---------------

======== === ==== ==== ====== ================================================
NAME rev ADDR loại chip Mô tả
======== === ==== ==== ====== ================================================
Dữ liệu JOY0DAT 00A R Denise Joystick-mouse 0 (đỉnh trái, chân trời)
Dữ liệu JOY1DAT 00C R Denise Joystick-mouse 1 (đỉnh phải, chân trời)
======== === ==== ==== ====== ================================================

Mỗi địa chỉ này đọc một thanh ghi 16 bit. Những điều này lần lượt
        được tải từ luồng nối tiếp MDAT và được bấm giờ trên
        cạnh đang lên của SCLK. Đầu ra MLD được sử dụng để tải song song
        bộ chuyển đổi song song sang nối tiếp bên ngoài. Điều này lần lượt là
        được tải với 4 đầu vào cầu phương từ mỗi trò chơi
        cổng điều khiển (tổng cộng 8) cộng với 8 bit điều khiển linh tinh
        tính năng mới dành cho LISA và có thể được đọc ở 8 bit trên của
        LISAID.

Các bit đăng ký như sau:

- Cách sử dụng bộ đếm chuột (chân 1,3 = Yclock, chân 2,4 = Xclock)

======== === === === === === === === === ====== === === === === === === ===
    BIT#  15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
======== === === === === === === === === ====== === === === === === === ===
JOY0DAT Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0 X7 X6 X5 X4 X3 X2 X1 X0
JOY1DAT Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0 X7 X6 X5 X4 X3 X2 X1 X0
======== === === === === === === === === ====== === === === === === === ===

0=LEFT CONTROLLER PAIR, 1=RIGHT CONTROLLER PAIR.
        (tổng cộng 4 quầy). Việc sử dụng bit cho cả bên trái và bên phải
        địa chỉ được hiển thị dưới đây. Mỗi bộ đếm 6 bit (Y7-Y2,X7-X2) là
        xung nhịp bởi 2 trong số các tín hiệu đầu vào từ nối tiếp chuột
        suối. Bắt đầu với bit đầu tiên nhận được:

+--------+----------+------------------------------------------+
         Tên bit ZZ0000ZZ ZZ0001ZZ
         +=========+===========+========================================================================================================
         ZZ0002ZZ M0H ZZ0003ZZ
         +--------+----------+------------------------------------------+
         ZZ0004ZZ M0HQ ZZ0005ZZ
         +--------+----------+------------------------------------------+
         ZZ0006ZZ M0V ZZ0007ZZ
         +--------+----------+------------------------------------------+
         ZZ0008ZZ M0VQ ZZ0009ZZ
         +--------+----------+------------------------------------------+
         ZZ0010ZZ M1V ZZ0011ZZ
         +--------+----------+------------------------------------------+
         ZZ0012ZZ M1VQ ZZ0013ZZ
         +--------+----------+------------------------------------------+
         ZZ0014ZZ M1V ZZ0015ZZ
         +--------+----------+------------------------------------------+
         ZZ0016ZZ M1VQ ZZ0017ZZ
         +--------+----------+------------------------------------------+

Bit 1 và 0 của mỗi bộ đếm (Y1-Y0,X1-X0) có thể
         đọc để xác định trạng thái của cặp tín hiệu đầu vào liên quan.
         Điều này cho phép các chân này tăng gấp đôi làm đầu vào của công tắc cần điều khiển.
         Việc đóng công tắc cần điều khiển có thể được giải mã như sau:

+-------------+------+---------------------------------+
         ZZ0000ZZ Pin# ZZ0011ZZ
         +=============+=======+=========================================================================================================
         ZZ0002ZZ 1 ZZ0003ZZ
         +-------------+------+---------------------------------+
         ZZ0004ZZ 3 ZZ0005ZZ
         +-------------+------+---------------------------------+
         ZZ0006ZZ 2 ZZ0007ZZ
         +-------------+------+---------------------------------+
         ZZ0008ZZ 4 ZZ0009ZZ
         +-------------+------+---------------------------------+

JOYTEST
-------

======== === ==== ==== ====== =======================================================
NAME rev ADDR loại chip Mô tả
======== === ==== ==== ====== =======================================================
JOYTEST 036 W Denise Ghi vào tất cả 4 bộ đếm chuột cần điều khiển cùng một lúc.
======== === ==== ==== ====== =======================================================

Bộ đếm chuột ghi dữ liệu kiểm tra:

========= === === === === === === === === ====== === === === === === === ===
     BIT#  15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
========= === === === === === === === === ====== === === === === === === ===
  JOYxDAT Y7 Y6 Y5 Y4 Y3 Y2 xx xx X7 X6 X5 X4 X3 X2 xx xx
  JOYxDAT Y7 Y6 Y5 Y4 Y3 Y2 xx xx X7 X6 X5 X4 X3 X2 xx xx
========= === === === === === === === === ====== === === === === === === ===

POT0DAT/POT1DAT
---------------

======= === ==== ==== ====== =================================================
NAME rev ADDR loại chip Mô tả
======= === ==== ==== ====== =================================================
POT0DAT h 012 R Cặp trái dữ liệu bộ đếm Paula Pot (vert., horiz.)
POT1DAT h 014 R Cặp phải dữ liệu bộ đếm Paula Pot (vert., horiz.)
======= === ==== ==== ====== =================================================

Mỗi địa chỉ này đọc một cặp bộ đếm nồi 8 bit.
        (tổng cộng 4 quầy). Việc gán bit cho cả hai
        địa chỉ được hiển thị dưới đây. Bộ đếm bị dừng bởi tín hiệu
        từ 2 đầu nối bộ điều khiển (trái-phải) với mỗi đầu nối 2 chân.

====== === === === === === === === === ====== === === === === === === ===
  BIT#  15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
====== === === === === === === === === ====== === === === === === === ===
 RIGHT Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0 X7 X6 X5 X4 X3 X2 X1 X0
  LEFT Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0 X7 X6 X5 X4 X3 X2 X1 X0
====== === === === === === === === === ====== === === === === === === ===

+--------------------------+-------+
         ZZ0000ZZ PAULA |
         +-------+------+------+-----+-------+
         ZZ0001ZZ Giám đốc. Chân ZZ0002ZZ ZZ0003ZZ
         +========+=======+=============+========+
         ZZ0004ZZ Y ZZ0005ZZ 9 ZZ0006ZZ
         +-------+------+------+-----+-------+
         ZZ0007ZZ X ZZ0008ZZ 5 ZZ0009ZZ
         +-------+------+------+-----+-------+
         ZZ0010ZZ Y ZZ0011ZZ 9 ZZ0012ZZ
         +-------+------+------+-----+-------+
         ZZ0013ZZ X ZZ0014ZZ 5 ZZ0015ZZ
         +-------+------+------+-----+-------+

Với chân trời bình thường (NTSC hoặc PAL). tỷ lệ dòng, các chậu sẽ
         đưa ra số đọc toàn thang (FF) với khoảng 500k ohm trong một
         khung thời gian. Với chân trời tương ứng nhanh hơn. thời gian xếp hàng,
         các bộ đếm sẽ đếm tương ứng nhanh hơn.
         Điều này cần được lưu ý khi thực hiện hiển thị chùm tia thay đổi.

POTGO
-----

====== === ==== ==== ====== =====================================================
NAME rev ADDR loại chip Mô tả
====== === ==== ==== ====== =====================================================
POTGO 034 W Cổng Paula Pot (4 bit) hai chiều và dữ liệu, và pot
			    truy cập bắt đầu.
====== === ==== ==== ====== =====================================================

POTINP
------

====== === ==== ==== ====== =====================================================
NAME rev ADDR loại chip Mô tả
====== === ==== ==== ====== =====================================================
Đọc dữ liệu chân POTINP 016 R Paula Pot
====== === ==== ==== ====== =====================================================

Thanh ghi này điều khiển cổng I/O hai chiều 4 bit
        có chung 4 chân như 4 quầy nồi ở trên.

+-------+----------+----------------------------------------------+
         ZZ0000ZZ FUNCTION ZZ0001ZZ
         +====================+===================================================================================================
         ZZ0002ZZ OUTRY ZZ0003ZZ
         +-------+----------+----------------------------------------------+
         ZZ0004ZZ DATRY ZZ0005ZZ
         +-------+----------+----------------------------------------------+
         ZZ0006ZZ OUTRX ZZ0007ZZ
         +-------+----------+----------------------------------------------+
         ZZ0008ZZ DATRX ZZ0009ZZ
         +-------+----------+----------------------------------------------+
         ZZ0010ZZ OUTLY ZZ0011ZZ
         +-------+----------+----------------------------------------------+
         ZZ0012ZZ DATLY ZZ0013ZZ
         +-------+----------+----------------------------------------------+
         ZZ0014ZZ OUTLX ZZ0015ZZ
         +-------+----------+----------------------------------------------+
         ZZ0016ZZ DATLX ZZ0017ZZ
         +-------+----------+----------------------------------------------+
         ZZ0018ZZ X ZZ0019ZZ
         +-------+----------+----------------------------------------------+
         ZZ0020ZZ START ZZ0021ZZ
         +-------+----------+----------------------------------------------+
