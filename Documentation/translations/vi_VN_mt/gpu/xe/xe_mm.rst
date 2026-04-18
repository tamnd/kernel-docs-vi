.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/xe/xe_mm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Quản lý bộ nhớ
===================

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
========================

.. kernel-doc:: drivers/gpu/drm/xe/xe_pt.c
   :doc: Pagetable building