.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sy7636a-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân sy7636a-hwmon
===========================

Chip được hỗ trợ:

* Silergy SY7636A PMIC


Sự miêu tả
-----------

Trình điều khiển này bổ sung thêm tính năng hỗ trợ đọc nhiệt độ phần cứng cho
Silergy SY7636A PMIC.

Các cảm biến sau được hỗ trợ

* Nhiệt độ
      - Nhiệt độ bên ngoài NTC tính bằng mili độ C

giao diện sysfs
---------------

temp0_input
	- Nhiệt độ bên ngoài NTC (mili độ C)