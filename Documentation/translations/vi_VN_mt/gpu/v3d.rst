.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/v3d.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
 Trình điều khiển đồ họa drm/v3d Broadcom V3D
=====================================

.. kernel-doc:: drivers/gpu/drm/v3d/v3d_drv.c
   :doc: Broadcom V3D Graphics Driver

Quản lý đối tượng bộ đệm (BO) GPU
---------------------------------

.. kernel-doc:: drivers/gpu/drm/v3d/v3d_bo.c
   :doc: V3D GEM BO management support

Quản lý không gian địa chỉ
===========================================
.. kernel-doc:: drivers/gpu/drm/v3d/v3d_mmu.c
   :doc: Broadcom V3D MMU

Lập kế hoạch GPU
===========================================
.. kernel-doc:: drivers/gpu/drm/v3d/v3d_sched.c
   :doc: Broadcom V3D scheduling

Ngắt
--------------

.. kernel-doc:: drivers/gpu/drm/v3d/v3d_irq.c
   :doc: Interrupt management for the V3D engine
