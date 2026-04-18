.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/efi/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================================
Hỗ trợ giao diện phần mềm mở rộng hợp nhất (UEFI)
====================================================

Chức năng thư viện sơ khai UEFI
===========================

.. kernel-doc:: drivers/firmware/efi/libstub/mem.c
   :internal:

Chức năng ghi lỗi nền tảng phổ biến UEFI (CPER)
==================================================

.. kernel-doc:: drivers/firmware/efi/cper.c