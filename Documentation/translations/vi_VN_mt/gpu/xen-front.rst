.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/xen-front.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================================
 drm/xen-front Trình điều khiển giao diện ảo hóa song song Xen
==============================================================

Trình điều khiển giao diện người dùng này triển khai màn hình ảo hóa Xen
theo giao thức hiển thị được mô tả tại
bao gồm/xen/giao diện/io/displif.h

Các chế độ hoạt động của trình điều khiển về bộ đệm hiển thị được sử dụng
=========================================================================

.. kernel-doc:: drivers/gpu/drm/xen/xen_drm_front.h
   :doc: Driver modes of operation in terms of display buffers used

Bộ đệm được phân bổ bởi trình điều khiển giao diện người dùng
-------------------------------------------------------------

.. kernel-doc:: drivers/gpu/drm/xen/xen_drm_front.h
   :doc: Buffers allocated by the frontend driver

Bộ đệm được phân bổ bởi chương trình phụ trợ
--------------------------------------------

.. kernel-doc:: drivers/gpu/drm/xen/xen_drm_front.h
   :doc: Buffers allocated by the backend

Hạn chế của trình điều khiển
============================

.. kernel-doc:: drivers/gpu/drm/xen/xen_drm_front.h
   :doc: Driver limitations
