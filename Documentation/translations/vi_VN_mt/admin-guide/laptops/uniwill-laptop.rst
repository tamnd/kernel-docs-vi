.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/laptops/uniwill-laptop.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Uniwill laptop extra features
=============================

On laptops manufactured by Uniwill (either directly or as ODM), the ``uniwill-laptop`` driver
handles various platform-specific features.

Module Loading
--------------

The ``uniwill-laptop`` driver relies on a DMI table to automatically load on supported devices.
When using the ``force`` module parameter, this DMI check will be omitted, allowing the driver
to be loaded on unsupported devices for testing purposes.

Hotkeys
-------

Usually the FN keys work without a special driver. However as soon as the ``uniwill-laptop`` driver
is loaded, the FN keys need to be handled manually. This is done automatically by the driver itself.

Keyboard settings
-----------------

The ``uniwill-laptop`` driver allows the user to enable/disable:

 - the FN lock and super key of the integrated keyboard
 - the touchpad toggle functionality of the integrated touchpad

See Documentation/ABI/testing/sysfs-driver-uniwill-laptop for details.

Hwmon interface
---------------

The ``uniwill-laptop`` driver supports reading of the CPU and GPU temperature and supports up to
two fans. Userspace applications can access sensor readings over the hwmon sysfs interface.

Platform profile
----------------

Support for changing the platform performance mode is currently not implemented.

Battery Charging Control
------------------------

The ``uniwill-laptop`` driver supports controlling the battery charge limit. This happens over
the standard ``charge_control_end_threshold`` power supply sysfs attribute. All values
between 1 and 100 percent are supported.

Additionally the driver signals the presence of battery charging issues through the standard
``health`` power supply sysfs attribute.

Lightbar
--------

The ``uniwill-laptop`` driver exposes the lightbar found on some models as a standard multicolor
LED class device. The default name of this LED class device is ``uniwill:multicolor:status``.

See Documentation/ABI/testing/sysfs-driver-uniwill-laptop for details on how to control the various
animation modes of the lightbar.