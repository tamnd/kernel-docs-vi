.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/group_descr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Bộ mô tả nhóm khối
-----------------------

Mỗi nhóm khối trên hệ thống tập tin có một trong các bộ mô tả này
liên kết với nó. Như đã lưu ý trong phần Bố cục ở trên, nhóm
bộ mô tả (nếu có) là mục thứ hai trong nhóm khối. các
cấu hình tiêu chuẩn dành cho mỗi nhóm khối chứa một bản sao đầy đủ của
bảng mô tả nhóm khối trừ khi có cờ tính năng spzzy_super
được thiết lập.

Lưu ý cách bộ mô tả nhóm ghi lại vị trí của cả ảnh bitmap và
bảng inode (tức là chúng có thể nổi). Điều này có nghĩa là trong một khối
nhóm, cấu trúc dữ liệu duy nhất có vị trí cố định là siêu khối
và bảng mô tả nhóm. Cơ chế flex_bg sử dụng điều này
thuộc tính để nhóm một số nhóm khối thành một nhóm linh hoạt và bố trí tất cả
các bitmap và bảng inode của nhóm thành một lần chạy dài trong lần đầu tiên
nhóm của nhóm flex.

Nếu cờ tính năng meta_bg được đặt thì một số nhóm khối sẽ được
được nhóm lại với nhau thành một nhóm meta. Lưu ý rằng trong trường hợp meta_bg,
tuy nhiên, hai nhóm khối đầu tiên và cuối cùng trong meta lớn hơn
nhóm chỉ chứa các mô tả nhóm cho các nhóm bên trong meta
nhóm.

flex_bg và meta_bg dường như không phải là các tính năng loại trừ lẫn nhau.

Trong ext2, ext3 và ext4 (khi tính năng 64bit không được bật),
bộ mô tả nhóm khối chỉ dài 32 byte và do đó kết thúc tại
bg_checksum. Trên hệ thống tệp ext4 có bật tính năng 64bit,
bộ mô tả nhóm khối mở rộng tới ít nhất 64 byte được mô tả bên dưới;
kích thước được lưu trữ trong siêu khối.

Nếu gdt_csum được đặt và siêu dữ liệu_csum không được đặt, nhóm khối
tổng kiểm tra là crc16 của FS UUID, số nhóm và nhóm
cấu trúc mô tả. Nếu siêu dữ liệu_csum được đặt thì nhóm khối
tổng kiểm tra là 16 bit thấp hơn của tổng kiểm tra của FS UUID, nhóm
số và cấu trúc mô tả nhóm. Cả bitmap khối và inode
tổng kiểm tra được tính toán dựa trên FS UUID, số nhóm và
toàn bộ bitmap.

Bộ mô tả nhóm khối được trình bày trong ZZ0000ZZ.

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - bg_block_bitmap_lo
     - Lower 32-bits of location of block bitmap.
   * - 0x4
     - __le32
     - bg_inode_bitmap_lo
     - Lower 32-bits of location of inode bitmap.
   * - 0x8
     - __le32
     - bg_inode_table_lo
     - Lower 32-bits of location of inode table.
   * - 0xC
     - __le16
     - bg_free_blocks_count_lo
     - Lower 16-bits of free block count.
   * - 0xE
     - __le16
     - bg_free_inodes_count_lo
     - Lower 16-bits of free inode count.
   * - 0x10
     - __le16
     - bg_used_dirs_count_lo
     - Lower 16-bits of directory count.
   * - 0x12
     - __le16
     - bg_flags
     - Block group flags. See the bgflags_ table below.
   * - 0x14
     - __le32
     - bg_exclude_bitmap_lo
     - Lower 32-bits of location of snapshot exclusion bitmap.
   * - 0x18
     - __le16
     - bg_block_bitmap_csum_lo
     - Lower 16-bits of the block bitmap checksum.
   * - 0x1A
     - __le16
     - bg_inode_bitmap_csum_lo
     - Lower 16-bits of the inode bitmap checksum.
   * - 0x1C
     - __le16
     - bg_itable_unused_lo
     - Lower 16-bits of unused inode count. If set, we needn't scan past the
       ``(sb.s_inodes_per_group - gdt.bg_itable_unused)`` th entry in the
       inode table for this group.
   * - 0x1E
     - __le16
     - bg_checksum
     - Group descriptor checksum; crc16(sb_uuid+group_num+bg_desc) if the
       RO_COMPAT_GDT_CSUM feature is set, or
       crc32c(sb_uuid+group_num+bg_desc) & 0xFFFF if the
       RO_COMPAT_METADATA_CSUM feature is set.  The bg_checksum
       field in bg_desc is skipped when calculating crc16 checksum,
       and set to zero if crc32c checksum is used.
   * -
     -
     -
     - These fields only exist if the 64bit feature is enabled and s_desc_size
       > 32.
   * - 0x20
     - __le32
     - bg_block_bitmap_hi
     - Upper 32-bits of location of block bitmap.
   * - 0x24
     - __le32
     - bg_inode_bitmap_hi
     - Upper 32-bits of location of inodes bitmap.
   * - 0x28
     - __le32
     - bg_inode_table_hi
     - Upper 32-bits of location of inodes table.
   * - 0x2C
     - __le16
     - bg_free_blocks_count_hi
     - Upper 16-bits of free block count.
   * - 0x2E
     - __le16
     - bg_free_inodes_count_hi
     - Upper 16-bits of free inode count.
   * - 0x30
     - __le16
     - bg_used_dirs_count_hi
     - Upper 16-bits of directory count.
   * - 0x32
     - __le16
     - bg_itable_unused_hi
     - Upper 16-bits of unused inode count.
   * - 0x34
     - __le32
     - bg_exclude_bitmap_hi
     - Upper 32-bits of location of snapshot exclusion bitmap.
   * - 0x38
     - __le16
     - bg_block_bitmap_csum_hi
     - Upper 16-bits of the block bitmap checksum.
   * - 0x3A
     - __le16
     - bg_inode_bitmap_csum_hi
     - Upper 16-bits of the inode bitmap checksum.
   * - 0x3C
     - __u32
     - bg_reserved
     - Padding to 64 bytes.

.. _bgflags:

Cờ nhóm chặn có thể là bất kỳ sự kết hợp nào sau đây:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 0x1
     - inode table and bitmap are not initialized (EXT4_BG_INODE_UNINIT).
   * - 0x2
     - block bitmap is not initialized (EXT4_BG_BLOCK_UNINIT).
   * - 0x4
     - inode table is zeroed (EXT4_BG_INODE_ZEROED).