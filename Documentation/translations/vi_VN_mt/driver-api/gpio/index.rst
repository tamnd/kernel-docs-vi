.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Đầu vào/đầu ra mục đích chung (GPIO)
======================================

Nội dung:

.. toctree::
   :maxdepth: 2

   intro
   using-gpio
   driver
   consumer
   board
   legacy-boards
   drivers-on-gpio
   bt8xxgpio
   pca953x

Cốt lõi
====

.. kernel-doc:: include/linux/gpio/driver.h
   :internal:

.. kernel-doc:: drivers/gpio/gpiolib.c
   :export:

Hỗ trợ ACPI
============

.. kernel-doc:: drivers/gpio/gpiolib-acpi-core.c
   :export:

Hỗ trợ cây thiết bị
===================

.. kernel-doc:: drivers/gpio/gpiolib-of.c
   :export:

API do thiết bị quản lý
==================

.. kernel-doc:: drivers/gpio/gpiolib-devres.c
   :export:

người trợ giúp sysfs
=============

.. kernel-doc:: drivers/gpio/gpiolib-sysfs.c
   :export:
