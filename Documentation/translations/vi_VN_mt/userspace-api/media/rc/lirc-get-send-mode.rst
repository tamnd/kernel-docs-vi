.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-get-send-mode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: RC

.. _lirc_get_send_mode:
.. _lirc_set_send_mode:

*************************************************
ioctls LIRC_GET_SEND_MODE và LIRC_SET_SEND_MODE
*************************************************

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