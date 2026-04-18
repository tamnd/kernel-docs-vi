.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/sysctl/sunrpc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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
