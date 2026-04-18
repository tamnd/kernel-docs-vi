.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/xen-front.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================================
 drm/xen-front Trình điều khiển giao diện ảo hóa song song Xen
====================================================

Trình điều khiển giao diện người dùng này triển khai màn hình ảo hóa Xen
theo giao thức hiển thị được mô tả tại
bao gồm/xen/giao diện/io/displif.h

Các chế độ hoạt động của trình điều khiển về bộ đệm hiển thị được sử dụng
==========================================================

.. kernel-doc:: drivers/gpu/drm/xen/xen_drm_front.h
   :doc: Driver modes of operation in terms of display buffers used

Bộ đệm được phân bổ bởi trình điều khiển giao diện người dùng
----------------------------------------

.. kernel-doc:: drivers/gpu/drm/xen/xen_drm_front.h
   :doc: Buffers allocated by the frontend driver

Bộ đệm được phân bổ bởi chương trình phụ trợ
--------------------------------

.. kernel-doc:: drivers/gpu/drm/xen/xen_drm_front.h
   :doc: Buffers allocated by the backend

Hạn chế của trình điều khiển
==================

.. kernel-doc:: drivers/gpu/drm/xen/xen_drm_front.h
   :doc: Driver limitations
