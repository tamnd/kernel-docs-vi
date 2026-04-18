.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/target.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Hướng dẫn giao diện mục tiêu và iSCSI
=================================

Giới thiệu và Tổng quan
=========================

TBD

Giao diện thiết bị lõi mục tiêu
=============================

Phần này trống vì không có bình luận kerneldoc nào được thêm vào
trình điều khiển/mục tiêu/target_core_device.c.

Giao diện truyền tải lõi mục tiêu
================================

.. kernel-doc:: drivers/target/target_core_transport.c
    :export:

I/O không gian người dùng được hỗ trợ mục tiêu
==============================

.. kernel-doc:: drivers/target/target_core_user.c
    :doc: Userspace I/O

.. kernel-doc:: include/uapi/linux/target_core_user.h
    :doc: Ring Design

Chức năng trợ giúp iSCSI
======================

.. kernel-doc:: drivers/scsi/libiscsi.c
   :export:


Thông tin khởi động iSCSI
======================

.. kernel-doc:: drivers/scsi/iscsi_boot_sysfs.c
   :export:

Giao diện iSCSI TCP
====================

.. kernel-doc:: drivers/scsi/iscsi_tcp.c
   :internal:

.. kernel-doc:: drivers/scsi/libiscsi_tcp.c
   :export:

