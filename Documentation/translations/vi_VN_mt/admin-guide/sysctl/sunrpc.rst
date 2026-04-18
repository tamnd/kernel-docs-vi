.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/sysctl/sunrpc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================
Documentation for /proc/sys/sunrpc/
===================================

kernel version 2.2.10

Copyright (c) 1998, 1999,  Rik van Riel <riel@nl.linux.org>

For general info and legal blurb, please look in index.rst.

------------------------------------------------------------------------------

This file contains the documentation for the sysctl files in
/proc/sys/sunrpc and is valid for Linux kernel version 2.2.

The files in this directory can be used to (re)set the debug
flags of the SUN Remote Procedure Call (RPC) subsystem in
the Linux kernel. This stuff is used for NFS, KNFSD and
maybe a few other things as well.

The files in there are used to control the debugging flags:
rpc_debug, nfs_debug, nfsd_debug and nlm_debug.

These flags are for kernel hackers only. You should read the
source code in net/sunrpc/ for more information.
