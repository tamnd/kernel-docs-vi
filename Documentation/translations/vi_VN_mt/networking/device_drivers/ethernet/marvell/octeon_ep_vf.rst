.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/marvell/octeon_ep_vf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================================
Trình điều khiển mạng nhân Linux cho Điểm cuối NIC VF của Marvell's Octeon PCI
=======================================================================

Trình điều khiển mạng cho Octeon PCI EndPoint NIC VF của Marvell.
Bản quyền (c) 2020 Marvell International Ltd.

Tổng quan
========
Trình điều khiển này triển khai chức năng kết nối mạng của Marvell's Octeon PCI
Điểm cuối NIC VF.

Thiết bị được hỗ trợ
=================
Hiện tại, trình điều khiển này hỗ trợ các thiết bị sau:
 * Bộ điều khiển mạng: Cavium, Inc. Device b203
 * Bộ điều khiển mạng: Cavium, Inc. Device b403
 * Bộ điều khiển mạng: Cavium, Inc. Device b103
 * Bộ điều khiển mạng: Cavium, Inc. Device b903
 * Bộ điều khiển mạng: Cavium, Inc. Thiết bị ba03
 * Bộ điều khiển mạng: Cavium, Inc. Device bc03
 * Bộ điều khiển mạng: Cavium, Inc. Device bd03