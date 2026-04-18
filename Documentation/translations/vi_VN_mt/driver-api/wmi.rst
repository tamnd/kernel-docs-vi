.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/wmi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
Trình điều khiển WMI API
==============

Lõi trình điều khiển WMI hỗ trợ giao diện dựa trên bus hiện đại hơn để tương tác
với các thiết bị WMI và giao diện dựa trên GUID cũ hơn. Giao diện sau là
được coi là không được dùng nữa, vì vậy trình điều khiển WMI mới thường nên tránh nó vì
nó có một số vấn đề với nhiều thiết bị WMI dùng chung GUID.
Thay vào đó, giao diện dựa trên bus hiện đại ánh xạ từng thiết bị WMI tới một
ZZ0000ZZ, vì vậy nó hỗ trợ các thiết bị WMI chia sẻ
cùng GUID. Trình điều khiển sau đó có thể đăng ký ZZ0001ZZ
lõi trình điều khiển sẽ được liên kết với các thiết bị WMI tương thích.

.. kernel-doc:: include/linux/wmi.h
   :internal:

.. kernel-doc:: drivers/platform/wmi/string.c
   :export:

.. kernel-doc:: drivers/platform/wmi/core.c
   :export: