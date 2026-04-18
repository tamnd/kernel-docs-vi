.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/sysctl/abi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Documentation for /proc/sys/abi/
================================

.. See scripts/check-sysctl-docs to keep this up to date:
.. scripts/check-sysctl-docs -vtable="abi" \
..         Documentation/admin-guide/sysctl/abi.rst \
..         $(git grep -l register_sysctl_)

Copyright (c) 2020, Stephen Kitt

For general info, see Documentation/admin-guide/sysctl/index.rst.

------------------------------------------------------------------------------

The files in ``/proc/sys/abi`` can be used to see and modify
ABI-related settings.

Currently, these files might (depending on your configuration)
show up in ``/proc/sys/kernel``:

.. contents:: :local:

vsyscall32 (x86)
================

Determines whether the kernels maps a vDSO page into 32-bit processes;
can be set to 1 to enable, or 0 to disable. Defaults to enabled if
``CONFIG_COMPAT_VDSO`` is set, disabled otherwise.

This controls the same setting as the ``vdso32`` kernel boot
parameter.