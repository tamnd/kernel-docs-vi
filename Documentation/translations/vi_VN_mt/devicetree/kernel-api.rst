.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/devicetree/kernel-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _devicetree:

=========================================
Hạt nhân thiết bị API
=========================================

Chức năng cốt lõi
--------------

.. kernel-doc:: drivers/of/base.c
   :export:

.. kernel-doc:: include/linux/of.h
   :internal:

.. kernel-doc:: drivers/of/property.c
   :export:

.. kernel-doc:: include/linux/of_graph.h
   :internal:

.. kernel-doc:: drivers/of/address.c
   :export:

.. kernel-doc:: drivers/of/irq.c
   :export:

.. kernel-doc:: drivers/of/fdt.c
   :export:

Chức năng mô hình trình điều khiển
----------------------

.. kernel-doc:: include/linux/of_device.h
   :internal:

.. kernel-doc:: drivers/of/device.c
   :export:

.. kernel-doc:: include/linux/of_platform.h
   :internal:

.. kernel-doc:: drivers/of/platform.c
   :export:

Chức năng lớp phủ và DT động
--------------------------------

.. kernel-doc:: drivers/of/resolver.c
   :export:

.. kernel-doc:: drivers/of/dynamic.c
   :export:

.. kernel-doc:: drivers/of/overlay.c
   :export: