.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/tty_buffer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
Bộ đệm TTY
==========

.. contents:: :local:

Ở đây, chúng tôi ghi lại các chức năng để xử lý bộ đệm tty và việc lật chúng.
Trình điều khiển có nhiệm vụ lấp đầy bộ đệm bằng một trong các chức năng bên dưới và
sau đó lật bộ đệm để dữ liệu được chuyển đến ZZ0000ZZ để xử lý tiếp.

Quản lý bộ đệm lật
======================

.. kernel-doc:: drivers/tty/tty_buffer.c
   :identifiers: tty_prepare_flip_string
           tty_flip_buffer_push tty_ldisc_receive_buf

.. kernel-doc:: include/linux/tty_flip.h
   :identifiers: tty_insert_flip_string_fixed_flag tty_insert_flip_string_flags
           tty_insert_flip_char

----

Các chức năng khác
===============

.. kernel-doc:: drivers/tty/tty_buffer.c
   :identifiers: tty_buffer_space_avail tty_buffer_set_limit

----

Khóa bộ đệm
==============

Chúng chỉ được sử dụng trong những trường hợp đặc biệt. Tránh chúng.

.. kernel-doc:: drivers/tty/tty_buffer.c
   :identifiers: tty_buffer_lock_exclusive tty_buffer_unlock_exclusive

----

Chức năng nội bộ
==================

.. kernel-doc:: drivers/tty/tty_buffer.c
   :internal: