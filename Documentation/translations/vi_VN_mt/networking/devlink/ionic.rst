.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/ionic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
hỗ trợ liên kết phát triển ion
==============================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

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
     - Version of firmware running on the device
   * - ``asic.id``
     - fixed
     - The ASIC type for this device
   * - ``asic.rev``
     - fixed
     - The revision of the ASIC for this device