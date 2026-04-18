.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/liveupdate.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Người điều phối cập nhật trực tiếp
==================================
:Tác giả: Pasha Tatashin <pasha.tatashin@soleen.com>

.. kernel-doc:: kernel/liveupdate/luo_core.c
   :doc: Live Update Orchestrator (LUO)

Phiên LUO
============
.. kernel-doc:: kernel/liveupdate/luo_session.c
   :doc: LUO Sessions

Bộ mô tả tệp bảo quản LUO
===============================
.. kernel-doc:: kernel/liveupdate/luo_file.c
   :doc: LUO File Descriptors

Dữ liệu toàn cầu về vòng đời của tệp LUO
========================================
.. kernel-doc:: kernel/liveupdate/luo_flb.c
   :doc: LUO File Lifecycle Bound Global Data

Trình soạn thảo cập nhật trực tiếp ABI
======================================
.. kernel-doc:: include/linux/kho/abi/luo.h
   :doc: Live Update Orchestrator ABI

Các loại mô tả tệp sau đây có thể được giữ nguyên

.. toctree::
   :maxdepth: 1

   ../mm/memfd_preservation

API công khai
=============
.. kernel-doc:: include/linux/liveupdate.h

.. kernel-doc:: include/linux/kho/abi/luo.h
   :functions:

.. kernel-doc:: kernel/liveupdate/luo_core.c
   :export:

.. kernel-doc:: kernel/liveupdate/luo_flb.c
   :export:

.. kernel-doc:: kernel/liveupdate/luo_file.c
   :export:

API nội bộ
============
.. kernel-doc:: kernel/liveupdate/luo_core.c
   :internal:

.. kernel-doc:: kernel/liveupdate/luo_flb.c
   :internal:

.. kernel-doc:: kernel/liveupdate/luo_session.c
   :internal:

.. kernel-doc:: kernel/liveupdate/luo_file.c
   :internal:

Xem thêm
========

-ZZ0000ZZ
-ZZ0001ZZ