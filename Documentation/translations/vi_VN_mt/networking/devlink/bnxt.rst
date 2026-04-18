.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/bnxt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
hỗ trợ liên kết phát triển bnxt
===============================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Thông số
==========

.. list-table:: Generic parameters implemented

   * - Name
     - Mode
   * - ``enable_sriov``
     - Permanent
   * - ``ignore_ari``
     - Permanent
   * - ``msix_vec_per_pf_max``
     - Permanent
   * - ``msix_vec_per_pf_min``
     - Permanent
   * - ``enable_remote_dev_reset``
     - Runtime
   * - ``enable_roce``
     - Permanent

Trình điều khiển ZZ0000ZZ cũng triển khai các trình điều khiển cụ thể sau:
các thông số.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``gre_ver_check``
     - Boolean
     - Permanent
     - Generic Routing Encapsulation (GRE) version check will be enabled in
       the device. If disabled, the device will skip the version check for
       incoming packets.

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
     - Part number identifying the board design
   * - ``asic.id``
     - fixed
     - ASIC design identifier
   * - ``asic.rev``
     - fixed
     - ASIC design revision
   * - ``fw.psid``
     - stored, running
     - Firmware parameter set version of the board
   * - ``fw``
     - stored, running
     - Overall board firmware version
   * - ``fw.mgmt``
     - stored, running
     - NIC hardware resource management firmware version
   * - ``fw.mgmt.api``
     - running
     - Minimum firmware interface spec version supported between driver and firmware
   * - ``fw.nsci``
     - stored, running
     - General platform management firmware version
   * - ``fw.roce``
     - stored, running
     - RoCE management firmware version