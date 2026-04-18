.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-get-send-mode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: RC

.. _lirc_get_send_mode:
.. _lirc_set_send_mode:

*************************************************
ioctls LIRC_GET_SEND_MODE và LIRC_SET_SEND_MODE
************************************************

Tên
====

LIRC_GET_SEND_MODE/LIRC_SET_SEND_MODE - Nhận/đặt chế độ truyền hiện tại.

Tóm tắt
========

.. c:macro:: LIRC_GET_SEND_MODE

ZZ0000ZZ

.. c:macro:: LIRC_SET_SEND_MODE

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Chế độ được sử dụng để truyền.

Description
===========

Get/set current transmit mode.

Only :ref:`LIRC_MODE_PULSE <lirc-mode-pulse>` and
:ref:`LIRC_MODE_SCANCODE <lirc-mode-scancode>` are supported by for IR send,
depending on the driver. Use :ref:`lirc_get_features` to find out which
modes the driver supports.

Return Value
============

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  .. row 1

       -  ``ENODEV``

       -  Device not available.

    -  .. row 2

       -  ``ENOTTY``

       -  Device does not support transmitting.

    -  .. row 3

       -  ``EINVAL``

       -  Invalid mode or invalid mode for this device.