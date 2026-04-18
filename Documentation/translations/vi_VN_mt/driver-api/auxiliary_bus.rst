.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/auxiliary_bus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _auxiliary_bus:

===============
Xe buýt phụ trợ
===============

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
========================

.. kernel-doc:: include/linux/auxiliary_bus.h
   :identifiers: auxiliary_driver module_auxiliary_driver

.. kernel-doc:: drivers/base/auxiliary.c
   :identifiers: __auxiliary_driver_register auxiliary_driver_unregister

Cách sử dụng ví dụ
==================

.. kernel-doc:: drivers/base/auxiliary.c
   :doc: EXAMPLE
