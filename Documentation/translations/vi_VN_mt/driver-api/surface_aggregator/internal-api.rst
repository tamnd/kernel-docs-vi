.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/internal-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Tài liệu API nội bộ
=============================

.. contents::
    :depth: 2


Lớp vận chuyển gói
======================

.. kernel-doc:: drivers/platform/surface/aggregator/ssh_parser.h
    :internal:

.. kernel-doc:: drivers/platform/surface/aggregator/ssh_parser.c
    :internal:

.. kernel-doc:: drivers/platform/surface/aggregator/ssh_msgb.h
    :internal:

.. kernel-doc:: drivers/platform/surface/aggregator/ssh_packet_layer.h
    :internal:

.. kernel-doc:: drivers/platform/surface/aggregator/ssh_packet_layer.c
    :internal:


Yêu cầu lớp vận chuyển
=======================

.. kernel-doc:: drivers/platform/surface/aggregator/ssh_request_layer.h
    :internal:

.. kernel-doc:: drivers/platform/surface/aggregator/ssh_request_layer.c
    :internal:


Bộ điều khiển
=============

.. kernel-doc:: drivers/platform/surface/aggregator/controller.h
    :internal:

.. kernel-doc:: drivers/platform/surface/aggregator/controller.c
    :internal:


Bus thiết bị khách
==================

.. kernel-doc:: drivers/platform/surface/aggregator/bus.c
    :internal:


Cốt lõi
=======

.. kernel-doc:: drivers/platform/surface/aggregator/core.c
    :internal:


Người trợ giúp theo dõi
=======================

.. kernel-doc:: drivers/platform/surface/aggregator/trace.h