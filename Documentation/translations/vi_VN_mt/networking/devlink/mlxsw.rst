.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/mlxsw.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
hỗ trợ liên kết phát triển mlxsw
=====================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Thông số
==========

.. list-table:: Generic parameters implemented

   * - Name
     - Mode
   * - ``fw_load_policy``
     - driverinit

Trình điều khiển ZZ0000ZZ cũng triển khai các trình điều khiển cụ thể sau:
các thông số.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``acl_region_rehash_interval``
     - u32
     - runtime
     - Sets an interval for periodic ACL region rehashes. The value is
       specified in milliseconds, with a minimum of ``3000``. The value of
       ``0`` disables periodic work entirely. The first rehash will be run
       immediately after the value is set.

Trình điều khiển ZZ0000ZZ hỗ trợ tải lại qua ZZ0001ZZ

Phiên bản thông tin
=============

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``hw.revision``
     - fixed
     - The hardware revision for this board
   * - ``fw.psid``
     - fixed
     - Firmware PSID
   * - ``fw.version``
     - running
     - Three digit firmware version

Phiên bản thông tin thiết bị phụ trợ thẻ dòng
========================================

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau cho thiết bị phụ trợ card dòng

.. list-table:: devlink info versions implemented
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``hw.revision``
     - fixed
     - The hardware revision for this line card
   * - ``ini.version``
     - running
     - Version of line card INI loaded
   * - ``fw.psid``
     - fixed
     - Line card device PSID
   * - ``fw.version``
     - running
     - Three digit firmware version of line card device

Bẫy dành riêng cho người lái xe
=====================

.. list-table:: List of Driver-specific Traps Registered by ``mlxsw``
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``irif_disabled``
     - ``drop``
     - Traps packets that the device decided to drop because they need to be
       routed from a disabled router interface (RIF). This can happen during
       RIF dismantle, when the RIF is first disabled before being removed
       completely
   * - ``erif_disabled``
     - ``drop``
     - Traps packets that the device decided to drop because they need to be
       routed through a disabled router interface (RIF). This can happen during
       RIF dismantle, when the RIF is first disabled before being removed
       completely