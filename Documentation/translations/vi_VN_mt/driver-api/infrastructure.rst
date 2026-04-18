.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/infrastructure.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Cơ sở hạ tầng trình điều khiển thiết bị
=============================

Cấu trúc mô hình trình điều khiển thiết bị cơ bản
----------------------------------------

.. kernel-doc:: include/linux/device.h
   :internal:
   :no-identifiers: device_link_state

.. kernel-doc:: include/linux/device/bus.h
   :identifiers: bus_type bus_notifier_event

.. kernel-doc:: include/linux/device/class.h
   :identifiers: class

.. kernel-doc:: include/linux/device/driver.h
   :identifiers: probe_type device_driver

Cơ sở trình điều khiển thiết bị
-------------------

.. kernel-doc:: drivers/base/init.c
   :internal:

.. kernel-doc:: include/linux/device/driver.h
   :no-identifiers: probe_type device_driver

.. kernel-doc:: drivers/base/driver.c
   :export:

.. kernel-doc:: drivers/base/core.c
   :export:

.. kernel-doc:: drivers/base/syscore.c
   :export:

.. kernel-doc:: include/linux/device/class.h
   :no-identifiers: class

.. kernel-doc:: drivers/base/class.c
   :export:

.. kernel-doc:: include/linux/device/faux.h
   :internal:

.. kernel-doc:: drivers/base/faux.c
   :export:

.. kernel-doc:: drivers/base/node.c
   :internal:

.. kernel-doc:: drivers/base/transport_class.c
   :export:

.. kernel-doc:: drivers/base/dd.c
   :export:

.. kernel-doc:: include/linux/platform_device.h
   :internal:

.. kernel-doc:: drivers/base/platform.c
   :export:

.. kernel-doc:: include/linux/device/bus.h
   :no-identifiers: bus_type bus_notifier_event

.. kernel-doc:: drivers/base/bus.c
   :export:

Trình điều khiển thiết bị Quản lý DMA
-----------------------------

.. kernel-doc:: kernel/dma/mapping.c
   :export:

Trình điều khiển thiết bị hỗ trợ PnP
--------------------------

.. kernel-doc:: drivers/pnp/core.c
   :internal:

.. kernel-doc:: drivers/pnp/card.c
   :export:

.. kernel-doc:: drivers/pnp/driver.c
   :internal:

.. kernel-doc:: drivers/pnp/manager.c
   :export:

.. kernel-doc:: drivers/pnp/support.c
   :export:

Thiết bị IO không gian người dùng
--------------------

.. kernel-doc:: drivers/uio/uio.c
   :export:

.. kernel-doc:: include/linux/uio_driver.h
   :internal:

