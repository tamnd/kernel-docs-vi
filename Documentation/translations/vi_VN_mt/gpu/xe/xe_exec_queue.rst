.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/xe/xe_exec_queue.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Hàng đợi thực thi
===============

.. kernel-doc:: drivers/gpu/drm/xe/xe_exec_queue.c
   :doc: Execution Queue

Nhóm nhiều hàng đợi
=================

.. kernel-doc:: drivers/gpu/drm/xe/xe_exec_queue.c
   :doc: Multi Queue Group

.. _multi-queue-group-guc-interface:

Giao diện GuC nhóm nhiều hàng đợi
===============================

.. kernel-doc:: drivers/gpu/drm/xe/xe_guc_submit.c
   :doc: Multi Queue Group GuC interface

API nội bộ
============

.. kernel-doc:: drivers/gpu/drm/xe/xe_exec_queue_types.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/xe/xe_exec_queue.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/xe/xe_exec_queue.c
   :internal: