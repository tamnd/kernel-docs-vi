.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/auxiliary_bus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _auxiliary_bus:

==============
Xe buýt phụ trợ
=============

.. kernel-doc:: drivers/base/auxiliary.c
   :doc: PURPOSE

Khi nào nên sử dụng xe buýt phụ trợ
=====================================

.. kernel-doc:: drivers/base/auxiliary.c
   :doc: USAGE


Tạo thiết bị phụ trợ
=========================

.. kernel-doc:: include/linux/auxiliary_bus.h
   :identifiers: auxiliary_device

.. kernel-doc:: drivers/base/auxiliary.c
   :identifiers: auxiliary_device_init __auxiliary_device_add

Model bộ nhớ thiết bị phụ trợ và tuổi thọ
------------------------------------------

.. kernel-doc:: include/linux/auxiliary_bus.h
   :doc: DEVICE_LIFESPAN


Trình điều khiển phụ trợ
=================

.. kernel-doc:: include/linux/auxiliary_bus.h
   :identifiers: auxiliary_driver module_auxiliary_driver

.. kernel-doc:: drivers/base/auxiliary.c
   :identifiers: __auxiliary_driver_register auxiliary_driver_unregister

Cách sử dụng ví dụ
=============

.. kernel-doc:: drivers/base/auxiliary.c
   :doc: EXAMPLE
