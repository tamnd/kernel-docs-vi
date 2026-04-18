.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/error-codes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _gpio_errors:

*******************
Mã lỗi GPIO
*******************

.. _gpio-errors:

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table:: Common GPIO error codes
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 16

    -  -  ``EAGAIN`` (aka ``EWOULDBLOCK``)

       -  The device was opened in non-blocking mode and a read can't
          be performed as there is no data available.

    -  -  ``EBADF``

       -  The file descriptor is not valid.

    -  -  ``EBUSY``

       -  The ioctl can't be handled because the device is busy. Typically
          returned when an ioctl attempts something that would require the
          usage of a resource that was already allocated. The ioctl must not
          be retried without performing another action to fix the problem
          first.

    -  -  ``EFAULT``

       -  There was a failure while copying data from/to userspace, probably
	  caused by an invalid pointer reference.

    -  -  ``EINVAL``

       -  One or more of the ioctl parameters are invalid or out of the
          allowed range. This is a widely used error code.

    -  -  ``ENODEV``

       -  Device not found or was removed.

    -  -  ``ENOMEM``

       -  There's not enough memory to handle the desired operation.

    -  -  ``EPERM``

       -  Permission denied. Typically returned in response to an attempt
          to perform an action incompatible with the current line
          configuration.

    -  -  ``EIO``

       -  I/O error. Typically returned when there are problems communicating
          with a hardware device or requesting features that hardware does not
          support. This could indicate broken or flaky hardware.
          It's a 'Something is wrong, I give up!' type of error.

    -  - ``ENXIO``

       -  Typically returned when a feature requiring interrupt support was
          requested, but the line does not support interrupts.

.. note::

  #. This list is not exhaustive; ioctls may return other error codes.
     Since errors may have side effects such as a driver reset,
     applications should abort on unexpected errors, or otherwise
     assume that the device is in a bad state.

  #. Request-specific error codes are listed in the individual
     requests descriptions.