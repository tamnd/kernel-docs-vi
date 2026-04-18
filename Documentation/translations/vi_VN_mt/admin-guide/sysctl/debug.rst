.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/sysctl/debug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
/proc/sys/debug/
================

These files show up in ``/proc/sys/debug/``, depending on the
kernel configuration:

.. contents:: :local:

exception-trace
===============

This flag controls whether the kernel prints information about unhandled
signals (like segmentation faults) to the kernel log (``dmesg``).

- ``0``: Unhandled signals are not traced.
- ``1``: Information about unhandled signals is printed.

The default value is ``1`` on most architectures (like x86, MIPS, RISC-V),
but it is ``0`` on **arm64**.

The actual information printed and the context provided varies
significantly depending on the CPU architecture. For example:

- On **x86**, it typically prints the instruction pointer (IP), error
  code, and address that caused a page fault.
- On **PowerPC**, it may print the next instruction pointer (NIP),
  link register (LR), and other relevant registers.

When enabled, this feature is often rate-limited to prevent the kernel
log from being flooded during a crash loop.

kprobes-optimization
====================

This flag enables or disables the optimization of Kprobes on certain
architectures (like x86).

- ``0``: Kprobes optimization is turned off.
- ``1``: Kprobes optimization is turned on (default).

For more details on Kprobes and its optimization, please refer to
Documentation/trace/kprobes.rst.

Copyright (c) 2026, Shubham Chakraborty <chakrabortyshubham66@gmail.com>

For general info and legal blurb, please look in
Documentation/admin-guide/sysctl/index.rst.

.. See scripts/check-sysctl-docs to keep this up to date:
.. scripts/check-sysctl-docs -vtable="debug" \
..         $(git grep -l register_sysctl_)
