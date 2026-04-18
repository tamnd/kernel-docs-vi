.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/tty_internals.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Bộ phận bên trong TTY
=============

.. contents:: :local:

Kopen
=====

Các hàm này dùng để mở TTY từ không gian kernel:

.. kernel-doc:: drivers/tty/tty_io.c
      :identifiers: tty_kopen_exclusive tty_kopen_shared tty_kclose

----

Các hàm nội bộ đã xuất
===========================

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_release_struct tty_dev_name_to_number tty_get_icount

----

Chức năng nội bộ
==================

.. kernel-doc:: drivers/tty/tty_io.c
   :internal: