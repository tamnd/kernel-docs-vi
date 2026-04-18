.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/pci/tsm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

=============================================================
PCI Trình quản lý bảo mật môi trường thực thi đáng tin cậy (TSM)
========================================================

Giao diện hệ thống con
====================

.. kernel-doc:: include/linux/pci-ide.h
   :internal:

.. kernel-doc:: drivers/pci/ide.c
   :export:

.. kernel-doc:: include/linux/pci-tsm.h
   :internal:

.. kernel-doc:: drivers/pci/tsm.c
   :export: