.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sfctemp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân sfctemp
=====================

Chip được hỗ trợ:
 - StarFive JH7100
 - StarFive JH7110

tác giả:
 - Emil Renner Berthing <kernel@esmil.dk>

Sự miêu tả
-----------

Trình điều khiển này bổ sung thêm hỗ trợ cho việc đọc cảm biến nhiệt độ tích hợp trên
SoC JH7100 và JH7110 RISC-V của StarFive Technology Co. Ltd.

Giao diện ZZ0000ZZ
-------------------

Cảm biến nhiệt độ có thể được bật, tắt và truy vấn thông qua tiêu chuẩn
giao diện hwmon trong sysfs trong ZZ0000ZZ cho một số giá trị của
ZZ0001ZZ:

======================================================================
Tên Perm Mô tả
======================================================================
temp1_enable RW Bật hoặc tắt cảm biến nhiệt độ.
                      Tự động được kích hoạt bởi trình điều khiển,
                      nhưng có thể bị vô hiệu hóa để tiết kiệm điện.
temp1_input RO Đọc nhiệt độ tính bằng mili độ C.
======================================================================