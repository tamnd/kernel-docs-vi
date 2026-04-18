.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/api/of.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Cây thiết bị (OF) API
====================

Cây thiết bị KUnit API được sử dụng để kiểm tra mã phụ thuộc của cây thiết bị (of_*).

.. kernel-doc:: include/kunit/of.h
   :internal:

.. kernel-doc:: drivers/of/of_kunit_helpers.c
   :export: