.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/api-summary.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Tóm tắt hệ thống tập tin Linux API
=============================

Phần này chứa tài liệu cấp API, chủ yếu được lấy từ nguồn
mã của chính nó.

Linux VFS
=============

Các loại hệ thống tập tin
--------------------

.. kernel-doc:: include/linux/fs.h
   :internal:

Bộ đệm thư mục
-------------------

.. kernel-doc:: fs/dcache.c
   :export:

.. kernel-doc:: include/linux/dcache.h
   :internal:

Xử lý nút
--------------

.. kernel-doc:: fs/inode.c
   :export:

.. kernel-doc:: fs/bad_inode.c
   :export:

Đăng ký và siêu khối
----------------------------

.. kernel-doc:: fs/super.c
   :export:

Khóa tập tin
----------

.. kernel-doc:: fs/locks.c
   :export:

.. kernel-doc:: fs/locks.c
   :internal:

Các chức năng khác
---------------

.. kernel-doc:: fs/mpage.c
   :export:

.. kernel-doc:: fs/namei.c
   :export:

.. kernel-doc:: fs/open.c
   :export:

.. kernel-doc:: block/bio.c
   :export:

.. kernel-doc:: fs/seq_file.c
   :export:

.. kernel-doc:: fs/filesystems.c
   :export:

.. kernel-doc:: fs/fs-writeback.c
   :export:

.. kernel-doc:: fs/anon_inodes.c
   :export:

.. kernel-doc:: fs/attr.c
   :export:

.. kernel-doc:: fs/d_path.c
   :export:

.. kernel-doc:: fs/dax.c
   :export:

.. kernel-doc:: fs/libfs.c
   :export:

.. kernel-doc:: fs/posix_acl.c
   :export:

.. kernel-doc:: fs/stat.c
   :export:

.. kernel-doc:: fs/sync.c
   :export:

.. kernel-doc:: fs/xattr.c
   :export:

.. kernel-doc:: fs/namespace.c
   :export:

Hệ thống tập tin Proc
===================

giao diện sysctl
----------------

.. kernel-doc:: kernel/sysctl.c
   :export:

giao diện hệ thống tập tin proc
-------------------------

.. kernel-doc:: fs/proc/base.c
   :internal:

Sự kiện dựa trên mô tả tập tin
================================

.. kernel-doc:: fs/eventfd.c
   :export:

giao diện sự kiện (epoll)
============================

.. kernel-doc:: fs/eventpoll.c
   :internal:

Hệ thống tập tin để xuất các đối tượng hạt nhân
===========================================

.. kernel-doc:: fs/sysfs/file.c
   :export:

.. kernel-doc:: fs/sysfs/symlink.c
   :export:

Hệ thống tập tin debugfs
======================

giao diện gỡ lỗi
-----------------

.. kernel-doc:: fs/debugfs/inode.c
   :export:

.. kernel-doc:: fs/debugfs/file.c
   :export:
