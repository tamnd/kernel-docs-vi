.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/firewire.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================================
Hướng dẫn giao diện trình điều khiển Firewire (IEEE 1394)
===========================================

Giới thiệu và Tổng quan
=========================

Hệ thống con Linux FireWire thêm một số giao diện vào hệ thống Linux để
 sử dụng/bảo trì+bất kỳ tài nguyên nào trên xe buýt IEEE 1394.

Mục đích chính của các giao diện này là truy cập không gian địa chỉ trên mỗi nút
trên xe buýt IEEE 1394 bằng quy trình ISO/IEC 13213 (IEEE 1212) và để điều khiển
tài nguyên đẳng thời trên bus bằng thủ tục IEEE 1394.

Hai loại giao diện được thêm vào, theo người tiêu dùng giao diện. A
bộ giao diện không gian người dùng có sẵn thông qua ZZ0000ZZ. một bộ
của giao diện kernel có sẵn thông qua các ký hiệu được xuất trong mô-đun ZZ0001ZZ.

Cấu trúc dữ liệu thiết bị Firewire char
====================================

.. include:: ../ABI/stable/firewire-cdev
    :literal:

.. kernel-doc:: include/uapi/linux/firewire-cdev.h
    :internal:

Giao diện thăm dò và sysfs của thiết bị Firewire
============================================

.. include:: ../ABI/stable/sysfs-bus-firewire
    :literal:

.. kernel-doc:: drivers/firewire/core-device.c
    :export:

Giao diện giao dịch lõi Firewire
====================================

.. kernel-doc:: drivers/firewire/core-transaction.c
    :export:

Giao diện I/O đồng bộ Firewire
===================================

.. kernel-doc:: include/linux/firewire.h
   :functions: fw_iso_context_schedule_flush_completions
.. kernel-doc:: drivers/firewire/core-iso.c
   :export:

