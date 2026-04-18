.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/xe/xe_firmware.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========
Phần sụn
========

Bố cục phần sụn
===============

.. kernel-doc:: drivers/gpu/drm/xe/xe_uc_fw_abi.h
   :doc: CSS-based Firmware Layout

.. kernel-doc:: drivers/gpu/drm/xe/xe_uc_fw_abi.h
   :doc: GSC-based Firmware Layout

Bố cục bộ nhớ nội dung được bảo vệ (WOPCM) ghi một lần
==================================================

.. kernel-doc:: drivers/gpu/drm/xe/xe_wopcm.c
   :doc: Write Once Protected Content Memory (WOPCM) Layout

GuC CTB Blob
============

.. kernel-doc:: drivers/gpu/drm/xe/xe_guc_ct.c
   :doc: GuC CTB Blob

Bảo tồn năng lượng GuC (PC)
===========================

.. kernel-doc:: drivers/gpu/drm/xe/xe_guc_pc.c
   :doc: GuC Power Conservation (PC)

.. kernel-doc:: drivers/gpu/drm/xe/xe_guc_rc.c
   :doc: GuC Render C-states (GuC RC)

Hạn chế của PCIe Gen5
=====================

.. kernel-doc:: drivers/gpu/drm/xe/xe_device_sysfs.c
   :doc: PCIe Gen5 Limitations

API nội bộ
============

TODO