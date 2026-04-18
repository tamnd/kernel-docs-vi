.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/display/dcn-blocks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _dcn_blocks:

===========
Khối DCN
==========

Trong phần này, bạn sẽ tìm thấy một số chi tiết bổ sung về một số khối DCN
và tài liệu mã khi nó được tạo tự động.

DCHUBBUB
--------

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/dchubbub.h
   :doc: overview

HUBP
----

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/hubp.h
   :doc: overview

DPP
---

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/dpp.h
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/dpp.h
   :internal:

MPC
---

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/mpc.h
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/mpc.h
   :internal:
   :no-identifiers: mpcc_blnd_cfg mpcc_alpha_blend_mode

OPP
---

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/opp.h
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/inc/hw/opp.h
   :internal:

DIO
---

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/link/hwss/link_hwss_dio.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/amd/display/dc/link/hwss/link_hwss_dio.c
   :internal:
