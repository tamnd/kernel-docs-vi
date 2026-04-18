.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/n_tty.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====
N_TTY
=====

.. contents:: :local:

ZZ0000ZZ mặc định (và dự phòng). Nó cố gắng
xử lý các ký tự theo POSIX.

Chức năng bên ngoài
==================

.. kernel-doc:: drivers/tty/n_tty.c
   :export:

Chức năng nội bộ
==================

.. kernel-doc:: drivers/tty/n_tty.c
   :internal: