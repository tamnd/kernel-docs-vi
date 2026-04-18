.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/sh/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Hướng dẫn giao diện SuperH
=======================

:Tác giả: Paul Mundt

.. toctree::
    :maxdepth: 1

    booting
    new-machine
    register-banks

    features

Quản lý bộ nhớ
=================

SH-4
----

Hàng đợi cửa hàng API
~~~~~~~~~~~~~~~

.. kernel-doc:: arch/sh/kernel/cpu/sh4/sq.c
   :export:

Giao diện cụ thể của máy
===========================

mach-dreamcast
--------------

.. kernel-doc:: arch/sh/boards/mach-dreamcast/rtc.c
   :internal:

mach-x3proto
------------

.. kernel-doc:: arch/sh/boards/mach-x3proto/ilsel.c
   :export:

Xe buýt
======

Cây phong
-----

.. kernel-doc:: drivers/sh/maple/maple.c
   :export:
