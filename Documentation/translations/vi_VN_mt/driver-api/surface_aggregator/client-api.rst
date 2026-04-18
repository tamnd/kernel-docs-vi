.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/client-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================
Tài liệu trình điều khiển máy khách API
=======================================

.. contents::
    :depth: 2


Truyền thông trung tâm nối tiếp
===============================

.. kernel-doc:: include/linux/surface_aggregator/serial_hub.h

.. kernel-doc:: drivers/platform/surface/aggregator/ssh_packet_layer.c
    :export:


Bộ điều khiển và giao diện lõi
==============================

.. kernel-doc:: include/linux/surface_aggregator/controller.h

.. kernel-doc:: drivers/platform/surface/aggregator/controller.c
    :export:

.. kernel-doc:: drivers/platform/surface/aggregator/core.c
    :export:


Bus máy khách và thiết bị máy khách API
=======================================

.. kernel-doc:: include/linux/surface_aggregator/device.h

.. kernel-doc:: drivers/platform/surface/aggregator/bus.c
    :export: