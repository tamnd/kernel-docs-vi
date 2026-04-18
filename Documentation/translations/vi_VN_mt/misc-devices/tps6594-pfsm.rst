.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/tps6594-pfsm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Trình điều khiển TPS6594 PFSM của Texas Instruments
=====================================

Tác giả: Julien Panis (jpanis@baylibre.com)

Tổng quan
========

Nói đúng ra, PFSM (Máy trạng thái hữu hạn có thể định cấu hình trước) không phải là
phần cứng. Nó là một đoạn mã.

TPS6594 PMIC (IC quản lý nguồn) tích hợp một máy trạng thái
quản lý các chế độ hoạt động. Tùy thuộc vào chế độ hoạt động hiện tại,
một số miền điện áp vẫn có điện trong khi những miền khác có thể bị tắt.

Trình điều khiển PFSM có thể được sử dụng để kích hoạt chuyển đổi giữa các cấu hình
tiểu bang. Nó cũng cung cấp quyền truy cập R/W vào các thanh ghi thiết bị.

Chip được hỗ trợ
---------------

-tps6594-q1
-tps6593-q1
- lp8764-q1

Vị trí tài xế
===============

trình điều khiển/misc/tps6594-pfsm.c

Định nghĩa loại trình điều khiển
=======================

bao gồm/uapi/linux/tps6594_pfsm.h

Trình điều khiển IOCTL
=============

ZZ0000ZZ
Tất cả tài nguyên của thiết bị đều bị tắt nguồn. Bộ xử lý đã tắt và
không có miền điện áp được cấp năng lượng.

ZZ0000ZZ
Các chức năng kỹ thuật số và analog của PMIC không
bắt buộc phải luôn bật, sẽ bị tắt (năng lượng thấp).

ZZ0000ZZ
Kích hoạt cập nhật firmware.

ZZ0000ZZ
Một trong những chế độ hoạt động
PMIC có đầy đủ chức năng và cung cấp năng lượng cho tất cả các tải PDN.
Tất cả các miền điện áp đều được cấp điện trong cả MCU và Bộ xử lý chính
phần.

ZZ0000ZZ
Một trong những chế độ hoạt động
Chỉ các nguồn năng lượng được gán cho Đảo an toàn MCU mới được bật.

ZZ0000ZZ
Một trong những chế độ hoạt động
Tùy thuộc vào bộ kích hoạt được đặt, một số miền điện áp DDR/GPIO có thể
vẫn tràn đầy năng lượng, trong khi tất cả các miền khác đều tắt để giảm thiểu
tổng công suất hệ thống.

Sử dụng trình điều khiển
============

Xem PFSM có sẵn::

# ls /dev/pfsm*

Kết xuất các thanh ghi của trang 0 và 1::

# hexdump -C /dev/pfsm-0-0x48

Xem các sự kiện PFSM::

# cat /proc/ngắt

Ví dụ về mã không gian người dùng
----------------------

mẫu/pfsm/pfsm-wakeup.c