.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Hướng dẫn API không gian người dùng nhân Linux
=====================================

.. _man-pages: https://www.kernel.org/doc/man-pages/

Trong khi phần lớn không gian người dùng API của kernel được ghi lại ở nơi khác
(đặc biệt là trong dự án man-pages_), một số thông tin về không gian người dùng có thể
cũng được tìm thấy trong chính cây hạt nhân.  Sách hướng dẫn này được dự định là tài liệu
nơi thu thập thông tin này.


Cuộc gọi hệ thống
============

.. toctree::
   :maxdepth: 1

   unshare
   futex2
   ebpf/index
   ioctl/index
   mseal
   rseq

Giao diện liên quan đến bảo mật
===========================

.. toctree::
   :maxdepth: 1

   no_new_privs
   seccomp_filter
   landlock
   lsm
   mfd_noexec
   spec_ctrl
   tee
   check_exec

Thiết bị và I/O
===============

.. toctree::
   :maxdepth: 1

   accelerators/ocxl
   dma-buf-heaps
   dma-buf-alloc-exchange
   fwctl/index
   gpio/index
   iommufd
   media/index
   dcdbas
   vduse
   isapnp

Mọi thứ khác
===============

.. toctree::
   :maxdepth: 1

   ELF
   liveupdate
   netlink/index
   sysfs-platform_profile
   vduse
   futex2
   perf_ring_buffer
   ntsync
