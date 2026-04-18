.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/internal-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Tài liệu API nội bộ
==========================

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
==========

.. kernel-doc:: drivers/platform/surface/aggregator/controller.h
    :internal:

.. kernel-doc:: drivers/platform/surface/aggregator/controller.c
    :internal:


Bus thiết bị khách
=================

.. kernel-doc:: drivers/platform/surface/aggregator/bus.c
    :internal:


Cốt lõi
====

.. kernel-doc:: drivers/platform/surface/aggregator/core.c
    :internal:


Người trợ giúp theo dõi
=============

.. kernel-doc:: drivers/platform/surface/aggregator/trace.h