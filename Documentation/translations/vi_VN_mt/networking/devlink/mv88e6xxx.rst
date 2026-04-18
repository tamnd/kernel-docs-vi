.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/mv88e6xxx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
hỗ trợ liên kết phát triển mv88e6xxx
====================================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Thông số
==========

Trình điều khiển ZZ0000ZZ triển khai các tham số dành riêng cho trình điều khiển sau.

.. list-table:: Driver-specific parameters implemented
   :widths: 5 5 5 85

   * - Name
     - Type
     - Mode
     - Description
   * - ``ATU_hash``
     - u8
     - runtime
     - Select one of four possible hashing algorithms for MAC addresses in
       the Address Translation Unit. A value of 3 may work better than the
       default of 1 when many MAC addresses have the same OUI. Only the
       values 0 to 3 are valid for this parameter.