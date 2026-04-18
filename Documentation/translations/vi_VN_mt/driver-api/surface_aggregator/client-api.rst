.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/client-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================================
Tài liệu trình điều khiển máy khách API
===============================

.. contents::
    :depth: 2


Truyền thông trung tâm nối tiếp
========================

.. kernel-doc:: include/linux/surface_aggregator/serial_hub.h

.. kernel-doc:: drivers/platform/surface/aggregator/ssh_packet_layer.c
    :export:


Bộ điều khiển và giao diện lõi
=============================

.. kernel-doc:: include/linux/surface_aggregator/controller.h

.. kernel-doc:: drivers/platform/surface/aggregator/controller.c
    :export:

.. kernel-doc:: drivers/platform/surface/aggregator/core.c
    :export:


Bus máy khách và thiết bị máy khách API
================================

.. kernel-doc:: include/linux/surface_aggregator/device.h

.. kernel-doc:: drivers/platform/surface/aggregator/bus.c
    :export: