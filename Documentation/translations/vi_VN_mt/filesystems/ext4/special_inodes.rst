.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/special_inodes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Inode đặc biệt
--------------

ext4 dành một số inode cho các tính năng đặc biệt, như sau:

.. list-table::
   :widths: 6 70
   :header-rows: 1

   * - inode Number
     - Purpose
   * - 0
     - Doesn't exist; there is no inode 0.
   * - 1
     - List of defective blocks.
   * - 2
     - Root directory.
   * - 3
     - User quota.
   * - 4
     - Group quota.
   * - 5
     - Boot loader.
   * - 6
     - Undelete directory.
   * - 7
     - Reserved group descriptors inode. (“resize inode”)
   * - 8
     - Journal inode.
   * - 9
     - The “exclude” inode, for snapshots(?)
   * - 10
     - Replica inode, used for some non-upstream feature?
   * - 11
     - Traditional first non-reserved inode. Usually this is the lost+found directory. See s_first_ino in the superblock.

Lưu ý rằng cũng có một số nút được phân bổ từ số nút không dành riêng
đối với các tính năng hệ thống tập tin khác không được tham chiếu từ thư mục tiêu chuẩn
thứ bậc. Đây thường là tài liệu tham khảo từ siêu khối. Họ là:

.. list-table::
   :widths: 20 50
   :header-rows: 1

   * - Superblock field
     - Description

   * - s_lpf_ino
     - Inode number of lost+found directory.
   * - s_prj_quota_inum
     - Inode number of quota file tracking project quotas
   * - s_orphan_file_inum
     - Inode number of file tracking orphan inodes.