.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/nfp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
hỗ trợ liên kết phát triển nfp
===================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Thông số
==========

.. list-table:: Generic parameters implemented

   * - Name
     - Mode
   * - ``fw_load_policy``
     - permanent
   * - ``reset_dev_on_drv_probe``
     - permanent

Phiên bản thông tin
=============

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``board.id``
     - fixed
     - Identifier of the board design
   * - ``board.rev``
     - fixed
     - Revision of the board design
   * - ``board.manufacture``
     - fixed
     - Vendor of the board design
   * - ``board.model``
     - fixed
     - Model name of the board design
   * - ``board.part_number``
     - fixed
     - Part number of the board and its components
   * - ``fw.bundle_id``
     - stored, running
     - Firmware bundle id
   * - ``fw.mgmt``
     - stored, running
     - Version of the management firmware
   * - ``fw.cpld``
     - stored, running
     - The CPLD firmware component version
   * - ``fw.app``
     - stored, running
     - The APP firmware component version
   * - ``fw.undi``
     - stored, running
     - The UNDI firmware component version
   * - ``fw.ncsi``
     - stored, running
     - The NSCI firmware component version
   * - ``chip.init``
     - stored, running
     - The CFGR firmware component version