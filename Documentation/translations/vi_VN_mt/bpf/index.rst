.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Tài liệu BPF
=================

Thư mục này chứa tài liệu về BPF (Berkeley Packet
Filter), tập trung vào phiên bản BPF mở rộng (eBPF).

Tài liệu phía kernel này vẫn đang được hoàn thiện.
Dự án Cilium cũng duy trì ZZ0000ZZ
đi sâu vào kỹ thuật chuyên sâu về Kiến trúc BPF.

.. toctree::
   :maxdepth: 1

   verifier
   libbpf/index
   standardization/index
   btf
   faq
   syscall_api
   helpers
   kfuncs
   cpumasks
   fs_kfuncs
   programs
   maps
   bpf_prog_run
   classic_vs_extended.rst
   bpf_iterators
   bpf_licensing
   test_debug
   clang-notes
   linux-notes
   other
   redirect

.. Links:
.. _BPF and XDP Reference Guide: https://docs.cilium.io/en/latest/bpf/
