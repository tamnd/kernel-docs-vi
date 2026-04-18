.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/xe/xe_mm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Quản lý bộ nhớ
=================

.. kernel-doc:: drivers/gpu/drm/xe/xe_bo_doc.h
   :doc: Buffer Objects (BO)

GGTT
====

.. kernel-doc:: drivers/gpu/drm/xe/xe_ggtt.c
   :doc: Global Graphics Translation Table (GGTT)

GGTT Nội bộ API
-----------------

.. kernel-doc:: drivers/gpu/drm/xe/xe_ggtt_types.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/xe/xe_ggtt.c
   :internal:

Xây dựng bảng phân trang
==================

.. kernel-doc:: drivers/gpu/drm/xe/xe_pt.c
   :doc: Pagetable building