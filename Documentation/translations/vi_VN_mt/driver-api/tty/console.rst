.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/console.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======
Bảng điều khiển
=======

.. contents:: :local:

Bảng điều khiển cấu trúc
==============

.. kernel-doc:: include/linux/console.h
   :identifiers: console cons_flags

Nội bộ
---------

.. kernel-doc:: include/linux/console.h
   :identifiers: nbcon_state nbcon_prio nbcon_context nbcon_write_context

Cấu trúc Consw
============

.. kernel-doc:: include/linux/console.h
   :identifiers: consw

Chức năng điều khiển
=================

.. kernel-doc:: include/linux/console.h
   :identifiers: console_srcu_read_flags console_srcu_write_flags
        console_is_registered for_each_console_srcu for_each_console

.. kernel-doc:: drivers/tty/vt/selection.c
   :export:
.. kernel-doc:: drivers/tty/vt/vt.c
   :export:

Nội bộ
---------

.. kernel-doc:: drivers/tty/vt/selection.c
   :internal:
.. kernel-doc:: drivers/tty/vt/vt.c
   :internal: