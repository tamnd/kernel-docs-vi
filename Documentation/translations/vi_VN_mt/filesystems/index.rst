.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _filesystems_index:

==================================
Hệ thống tập tin trong nhân Linux
===============================

Sổ tay hướng dẫn đang được phát triển này, một ngày nào đó huy hoàng, sẽ cung cấp
thông tin toàn diện về cách lớp hệ thống tệp ảo Linux (VFS)
hoạt động cùng với các hệ thống tập tin nằm bên dưới nó.  Hiện tại, những gì chúng tôi có
có thể được tìm thấy dưới đây.

Tài liệu lõi VFS
======================

Xem các hướng dẫn này để biết tài liệu về chính lớp VFS và cách thức hoạt động của nó.
thuật toán hoạt động.

.. toctree::
   :maxdepth: 2

   vfs
   path-lookup
   api-summary
   splice
   locking
   directory-locking
   devpts
   dnotify
   fiemap
   files
   locks
   mmap_prepare
   multigrain-ts
   mount_api
   quota
   seq_file
   sharedsubtree
   idmappings
   iomap/index

   automount-support

   caching/index

   porting

Các lớp hỗ trợ hệ thống tập tin
=========================

Tài liệu về mã hỗ trợ trong lớp hệ thống tập tin để sử dụng trong
triển khai hệ thống tập tin.

.. toctree::
   :maxdepth: 2

   buffer
   journalling
   fscrypt
   fsverity
   netfs_library

Hệ thống tập tin
===========

Tài liệu cho việc triển khai hệ thống tập tin.

.. toctree::
   :maxdepth: 2

   9p
   adfs
   affs
   afs
   autofs
   autofs-mount-control
   befs
   bfs
   btrfs
   ceph
   coda
   configfs
   cramfs
   dax
   debugfs
   dlmfs
   ecryptfs
   efivarfs
   erofs
   ext2
   ext3
   ext4/index
   f2fs
   gfs2/index
   hfs
   hfsplus
   hpfs
   fuse/index
   inotify
   isofs
   nilfs2
   nfs/index
   ntfs
   ntfs3
   ocfs2
   ocfs2-online-filecheck
   omfs
   orangefs
   overlayfs
   proc
   qnx6
   ramfs-rootfs-initramfs
   relay
   resctrl
   romfs
   smb/index
   spufs/index
   squashfs
   sysfs
   tmpfs
   ubifs
   ubifs-authentication
   udf
   virtiofs
   vfat
   xfs/index
   zonefs
