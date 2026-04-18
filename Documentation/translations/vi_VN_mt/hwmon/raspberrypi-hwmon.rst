.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/raspberrypi-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân Raspberrypi-hwmon
===============================

Các bảng được hỗ trợ:

* Raspberry Pi A+ (thông qua GPIO trên SoC)
  * Raspberry Pi B+ (thông qua GPIO trên SoC)
  * Raspberry Pi 2 B (thông qua GPIO trên SoC)
  * Raspberry Pi 3 B (thông qua GPIO trên bộ mở rộng cổng)
  * Raspberry Pi 3 B+ (thông qua PMIC)

Tác giả: Stefan Wahren <stefan.wahren@i2se.com>

Sự miêu tả
-----------

Trình điều khiển này thăm dò định kỳ thuộc tính hộp thư của phần sụn VC4 để phát hiện
điều kiện điện áp thấp.

Mục nhập hệ thống
-------------

============================================
in0_lcrit_alarm Báo động điện áp thấp
============================================
