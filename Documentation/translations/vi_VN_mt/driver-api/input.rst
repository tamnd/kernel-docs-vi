.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/input.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hệ thống con đầu vào
===============

Lõi đầu vào
----------

.. kernel-doc:: include/linux/input.h
   :internal:

.. kernel-doc:: drivers/input/input.c
   :export:

.. kernel-doc:: drivers/input/ff-core.c
   :export:

.. kernel-doc:: drivers/input/ff-memless.c
   :export:

Thư viện cảm ứng đa điểm
------------------

.. kernel-doc:: include/linux/input/mt.h
   :internal:

.. kernel-doc:: drivers/input/input-mt.c
   :export:

Bàn phím/bàn phím ma trận
------------------------

.. kernel-doc:: include/linux/input/matrix_keypad.h
   :internal:

Hỗ trợ sơ đồ bàn phím thưa thớt
---------------------

.. kernel-doc:: include/linux/input/sparse-keymap.h
   :internal:

.. kernel-doc:: drivers/input/sparse-keymap.c
   :export:

Hỗ trợ giao thức PS/2
---------------------
.. kernel-doc:: include/linux/libps2.h
   :internal:

.. kernel-doc:: drivers/input/serio/libps2.c
   :export:
