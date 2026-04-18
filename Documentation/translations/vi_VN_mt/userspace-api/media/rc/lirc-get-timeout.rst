.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-get-timeout.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: RC

.. _lirc_get_min_timeout:
.. _lirc_get_max_timeout:

*******************************************************
ioctls LIRC_GET_MIN_TIMEOUT và LIRC_GET_MAX_TIMEOUT
****************************************************

Tên
====

LIRC_GET_MIN_TIMEOUT / LIRC_GET_MAX_TIMEOUT - Lấy thời gian chờ có thể
phạm vi nhận IR.

Tóm tắt
========

.. c:macro:: LIRC_GET_MIN_TIMEOUT

ZZ0000ZZ

.. c:macro:: LIRC_GET_MAX_TIMEOUT

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Thời gian chờ, tính bằng micro giây.

Description
===========

Some devices have internal timers that can be used to detect when
there's no IR activity for a long time. This can help lircd in
detecting that a IR signal is finished and can speed up the decoding
process. Returns an integer value with the minimum/maximum timeout
that can be set.

.. note::

   Some devices have a fixed timeout, in that case
   both ioctls will return the same value even though the timeout
   cannot be changed via :ref:`LIRC_SET_REC_TIMEOUT`.

Return Value
============

On success 0 is returned, on error -1 and the ``errno`` variable is set
appropriately. The generic error codes are described at the
:ref:`Generic Error Codes <gen-errors>` chapter.