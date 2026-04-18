.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/etas_es58x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
hỗ trợ liên kết nhà phát triển etas_es58x
==========================

Tài liệu này mô tả các tính năng của devlink được triển khai bởi
Trình điều khiển thiết bị ZZ0000ZZ.

Phiên bản thông tin
=============

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``fw``
     - running
     - Version of the firmware running on the device. Also available
       through ``ethtool -i`` as the first member of the
       ``firmware-version``.
   * - ``fw.bootloader``
     - running
     - Version of the bootloader running on the device. Also available
       through ``ethtool -i`` as the second member of the
       ``firmware-version``.
   * - ``board.rev``
     - fixed
     - The hardware revision of the device.
   * - ``serial_number``
     - fixed
     - The USB serial number. Also available through ``lsusb -v``.