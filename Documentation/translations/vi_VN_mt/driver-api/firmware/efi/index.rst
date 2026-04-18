.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/efi/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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