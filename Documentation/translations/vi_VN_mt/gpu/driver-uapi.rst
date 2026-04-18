.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/driver-uapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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
