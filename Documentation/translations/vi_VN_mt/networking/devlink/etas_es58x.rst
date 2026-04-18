.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/etas_es58x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
hỗ trợ liên kết nhà phát triển etas_es58x
=========================================

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