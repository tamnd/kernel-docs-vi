.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Tài liệu BPF
===================

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
