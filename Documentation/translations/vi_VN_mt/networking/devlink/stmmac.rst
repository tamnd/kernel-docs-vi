.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/stmmac.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
hỗ trợ liên kết phát triển stmmac (tóm tắt dwmac)
=======================================

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
   * - ``phc_coarse_adj``
     - Boolean
     - runtime
     - Enable the Coarse timestamping mode, as defined in the DWMAC TRM.
       A detailed explanation of this timestamping mode can be found in the
       Socfpga Functionnal Description [1].

       In Coarse mode, the ptp clock is expected to be fed by a high-precision
       clock that is externally adjusted, and the subsecond increment used for
       timestamping is set to 1/ptp_clock_rate.

       In Fine mode (i.e. Coarse mode == false), the ptp clock frequency is
       continuously adjusted, but the subsecond increment is set to
       2/ptp_clock_rate.

       Coarse mode is suitable for PTP Grand Master operation. If unsure, leave
       the parameter to False.

       [1] https://www.intel.com/content/www/us/en/docs/programmable/683126/21-2/functional-description-of-the-emac.html