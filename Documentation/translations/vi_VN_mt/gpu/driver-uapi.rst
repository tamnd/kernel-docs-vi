.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/driver-uapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Trình điều khiển DRM uAPI
===============

uAPI drm/i915
=============

.. kernel-doc:: include/uapi/drm/i915_drm.h

uAPI drm/nouveau
================

VM_BIND / EXEC uAPI
-------------------

.. kernel-doc:: drivers/gpu/drm/nouveau/nouveau_exec.c
    :doc: Overview

.. kernel-doc:: include/uapi/drm/nouveau_drm.h

uAPI drm/panthor
================

.. kernel-doc:: include/uapi/drm/panthor_drm.h

drm/xe uAPI
===========

.. kernel-doc:: include/uapi/drm/xe_drm.h

drm/asahi uAPI
================

.. kernel-doc:: include/uapi/drm/asahi_drm.h
