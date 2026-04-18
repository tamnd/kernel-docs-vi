.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/hns3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
hỗ trợ liên kết phát triển hns3
====================

Tài liệu này mô tả các tính năng của devlink được ZZ0000ZZ triển khai
trình điều khiển thiết bị.

Trình điều khiển ZZ0000ZZ hỗ trợ tải lại qua ZZ0001ZZ.

Phiên bản thông tin
=============

Trình điều khiển ZZ0000ZZ báo cáo các phiên bản sau

.. list-table:: devlink info versions implemented
   :widths: 10 10 80

   * - Name
     - Type
     - Description
   * - ``fw``
     - running
     - Used to represent the firmware version.
   * - ``fw.scc``
     - running
     - Used to represent the Soft Congestion Control (SSC) firmware version.
       SCC is a firmware component which provides multiple RDMA congestion
       control algorithms, including DCQCN.