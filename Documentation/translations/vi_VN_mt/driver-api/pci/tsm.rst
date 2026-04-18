.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/pci/tsm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

================================================================
PCI Trình quản lý bảo mật môi trường thực thi đáng tin cậy (TSM)
================================================================

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