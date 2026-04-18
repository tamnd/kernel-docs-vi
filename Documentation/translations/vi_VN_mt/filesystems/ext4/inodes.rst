.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/inodes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Nút chỉ mục
-----------

Trong hệ thống tệp UNIX thông thường, inode lưu trữ tất cả siêu dữ liệu
liên quan đến tập tin (dấu thời gian, bản đồ khối, thuộc tính mở rộng,
v.v.), không phải mục nhập thư mục. Để tìm thông tin liên quan đến một
tập tin, người ta phải duyệt qua các tập tin thư mục để tìm mục nhập thư mục
được liên kết với một tệp, sau đó tải inode để tìm siêu dữ liệu cho
tập tin đó. ext4 có vẻ gian lận một chút (vì lý do hiệu suất)
bằng cách lưu trữ một bản sao của loại tập tin (thường được lưu trữ trong inode) trong
mục nhập thư mục. (So sánh tất cả điều này với FAT, nơi lưu trữ tất cả các tệp
thông tin trực tiếp trong mục nhập thư mục, nhưng không hỗ trợ cứng
liên kết và nói chung được tìm kiếm nhiều hơn ext4 do đơn giản hơn
cấp phát khối và sử dụng rộng rãi các danh sách liên kết.)

Bảng inode là một mảng tuyến tính ZZ0000ZZ. Cái bàn là
có kích thước để có đủ khối để lưu trữ ít nhất
byte ZZ0001ZZ. Số lượng của
nhóm khối chứa một nút có thể được tính như sau
ZZ0002ZZ và phần bù vào
bảng của nhóm là ZZ0003ZZ. Ở đó
không có inode 0.

Tổng kiểm tra inode được tính toán dựa trên FS UUID, số inode,
và cấu trúc inode của chính nó.

Mục nhập bảng inode được trình bày trong ZZ0000ZZ.

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1
   :class: longtable

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le16
     - i_mode
     - File mode. See the table i_mode_ below.
   * - 0x2
     - __le16
     - i_uid
     - Lower 16-bits of Owner UID.
   * - 0x4
     - __le32
     - i_size_lo
     - Lower 32-bits of size in bytes.
   * - 0x8
     - __le32
     - i_atime
     - Last access time, in seconds since the epoch. However, if the EA_INODE
       inode flag is set, this inode stores an extended attribute value and
       this field contains the checksum of the value.
   * - 0xC
     - __le32
     - i_ctime
     - Last inode change time, in seconds since the epoch. However, if the
       EA_INODE inode flag is set, this inode stores an extended attribute
       value and this field contains the lower 32 bits of the attribute value's
       reference count.
   * - 0x10
     - __le32
     - i_mtime
     - Last data modification time, in seconds since the epoch. However, if the
       EA_INODE inode flag is set, this inode stores an extended attribute
       value and this field contains the number of the inode that owns the
       extended attribute.
   * - 0x14
     - __le32
     - i_dtime
     - Deletion Time, in seconds since the epoch.
   * - 0x18
     - __le16
     - i_gid
     - Lower 16-bits of GID.
   * - 0x1A
     - __le16
     - i_links_count
     - Hard link count. Normally, ext4 does not permit an inode to have more
       than 65,000 hard links. This applies to files as well as directories,
       which means that there cannot be more than 64,998 subdirectories in a
       directory (each subdirectory's '..' entry counts as a hard link, as does
       the '.' entry in the directory itself). With the DIR_NLINK feature
       enabled, ext4 supports more than 64,998 subdirectories by setting this
       field to 1 to indicate that the number of hard links is not known.
   * - 0x1C
     - __le32
     - i_blocks_lo
     - Lower 32-bits of “block” count. If the huge_file feature flag is not
       set on the filesystem, the file consumes ``i_blocks_lo`` 512-byte blocks
       on disk. If huge_file is set and EXT4_HUGE_FILE_FL is NOT set in
       ``inode.i_flags``, then the file consumes ``i_blocks_lo + (i_blocks_hi
       << 32)`` 512-byte blocks on disk. If huge_file is set and
       EXT4_HUGE_FILE_FL IS set in ``inode.i_flags``, then this file
       consumes (``i_blocks_lo + i_blocks_hi`` << 32) filesystem blocks on
       disk.
   * - 0x20
     - __le32
     - i_flags
     - Inode flags. See the table i_flags_ below.
   * - 0x24
     - 4 bytes
     - i_osd1
     - See the table i_osd1_ for more details.
   * - 0x28
     - 60 bytes
     - i_block[EXT4_N_BLOCKS=15]
     - Block map or extent tree. See the section “The Contents of inode.i_block”.
   * - 0x64
     - __le32
     - i_generation
     - File version (for NFS).
   * - 0x68
     - __le32
     - i_file_acl_lo
     - Lower 32-bits of extended attribute block. ACLs are of course one of
       many possible extended attributes; I think the name of this field is a
       result of the first use of extended attributes being for ACLs.
   * - 0x6C
     - __le32
     - i_size_high / i_dir_acl
     - Upper 32-bits of file/directory size. In ext2/3 this field was named
       i_dir_acl, though it was usually set to zero and never used.
   * - 0x70
     - __le32
     - i_obso_faddr
     - (Obsolete) fragment address.
   * - 0x74
     - 12 bytes
     - i_osd2
     - See the table i_osd2_ for more details.
   * - 0x80
     - __le16
     - i_extra_isize
     - Size of this inode - 128. Alternately, the size of the extended inode
       fields beyond the original ext2 inode, including this field.
   * - 0x82
     - __le16
     - i_checksum_hi
     - Upper 16-bits of the inode checksum.
   * - 0x84
     - __le32
     - i_ctime_extra
     - Extra change time bits. This provides sub-second precision. See Inode
       Timestamps section.
   * - 0x88
     - __le32
     - i_mtime_extra
     - Extra modification time bits. This provides sub-second precision.
   * - 0x8C
     - __le32
     - i_atime_extra
     - Extra access time bits. This provides sub-second precision.
   * - 0x90
     - __le32
     - i_crtime
     - File creation time, in seconds since the epoch.
   * - 0x94
     - __le32
     - i_crtime_extra
     - Extra file creation time bits. This provides sub-second precision.
   * - 0x98
     - __le32
     - i_version_hi
     - Upper 32-bits for version number.
   * - 0x9C
     - __le32
     - i_projid
     - Project ID.

.. _i_mode:

Giá trị ZZ0000ZZ là sự kết hợp của các cờ sau:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 0x1
     - S_IXOTH (Others may execute)
   * - 0x2
     - S_IWOTH (Others may write)
   * - 0x4
     - S_IROTH (Others may read)
   * - 0x8
     - S_IXGRP (Group members may execute)
   * - 0x10
     - S_IWGRP (Group members may write)
   * - 0x20
     - S_IRGRP (Group members may read)
   * - 0x40
     - S_IXUSR (Owner may execute)
   * - 0x80
     - S_IWUSR (Owner may write)
   * - 0x100
     - S_IRUSR (Owner may read)
   * - 0x200
     - S_ISVTX (Sticky bit)
   * - 0x400
     - S_ISGID (Set GID)
   * - 0x800
     - S_ISUID (Set UID)
   * -
     - These are mutually-exclusive file types:
   * - 0x1000
     - S_IFIFO (FIFO)
   * - 0x2000
     - S_IFCHR (Character device)
   * - 0x4000
     - S_IFDIR (Directory)
   * - 0x6000
     - S_IFBLK (Block device)
   * - 0x8000
     - S_IFREG (Regular file)
   * - 0xA000
     - S_IFLNK (Symbolic link)
   * - 0xC000
     - S_IFSOCK (Socket)

.. _i_flags:

Trường ZZ0000ZZ là sự kết hợp của các giá trị sau:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 0x1
     - This file requires secure deletion (EXT4_SECRM_FL). (not implemented)
   * - 0x2
     - This file should be preserved, should undeletion be desired
       (EXT4_UNRM_FL). (not implemented)
   * - 0x4
     - File is compressed (EXT4_COMPR_FL). (not really implemented)
   * - 0x8
     - All writes to the file must be synchronous (EXT4_SYNC_FL).
   * - 0x10
     - File is immutable (EXT4_IMMUTABLE_FL).
   * - 0x20
     - File can only be appended (EXT4_APPEND_FL).
   * - 0x40
     - The dump(1) utility should not dump this file (EXT4_NODUMP_FL).
   * - 0x80
     - Do not update access time (EXT4_NOATIME_FL).
   * - 0x100
     - Dirty compressed file (EXT4_DIRTY_FL). (not used)
   * - 0x200
     - File has one or more compressed clusters (EXT4_COMPRBLK_FL). (not used)
   * - 0x400
     - Do not compress file (EXT4_NOCOMPR_FL). (not used)
   * - 0x800
     - Encrypted inode (EXT4_ENCRYPT_FL). This bit value previously was
       EXT4_ECOMPR_FL (compression error), which was never used.
   * - 0x1000
     - Directory has hashed indexes (EXT4_INDEX_FL).
   * - 0x2000
     - AFS magic directory (EXT4_IMAGIC_FL).
   * - 0x4000
     - File data must always be written through the journal
       (EXT4_JOURNAL_DATA_FL).
   * - 0x8000
     - File tail should not be merged (EXT4_NOTAIL_FL). (not used by ext4)
   * - 0x10000
     - All directory entry data should be written synchronously (see
       ``dirsync``) (EXT4_DIRSYNC_FL).
   * - 0x20000
     - Top of directory hierarchy (EXT4_TOPDIR_FL).
   * - 0x40000
     - This is a huge file (EXT4_HUGE_FILE_FL).
   * - 0x80000
     - Inode uses extents (EXT4_EXTENTS_FL).
   * - 0x100000
     - Verity protected file (EXT4_VERITY_FL).
   * - 0x200000
     - Inode stores a large extended attribute value in its data blocks
       (EXT4_EA_INODE_FL).
   * - 0x400000
     - This file has blocks allocated past EOF (EXT4_EOFBLOCKS_FL).
       (deprecated)
   * - 0x01000000
     - Inode is a snapshot (``EXT4_SNAPFILE_FL``). (not in mainline)
   * - 0x04000000
     - Snapshot is being deleted (``EXT4_SNAPFILE_DELETED_FL``). (not in
       mainline)
   * - 0x08000000
     - Snapshot shrink has completed (``EXT4_SNAPFILE_SHRUNK_FL``). (not in
       mainline)
   * - 0x10000000
     - Inode has inline data (EXT4_INLINE_DATA_FL).
   * - 0x20000000
     - Create children with the same project ID (EXT4_PROJINHERIT_FL).
   * - 0x40000000
     - Use case-insensitive lookups for directory contents (EXT4_CASEFOLD_FL).
   * - 0x80000000
     - Reserved for ext4 library (EXT4_RESERVED_FL).
   * -
     - Aggregate flags:
   * - 0x705BDFFF
     - User-visible flags.
   * - 0x604BC0FF
     - User-modifiable flags. Note that while EXT4_JOURNAL_DATA_FL and
       EXT4_EXTENTS_FL can be set with setattr, they are not in the kernel's
       EXT4_FL_USER_MODIFIABLE mask, since it needs to handle the setting of
       these flags in a special manner and they are masked out of the set of
       flags that are saved directly to i_flags.

.. _i_osd1:

Trường ZZ0000ZZ có nhiều ý nghĩa tùy thuộc vào người tạo:

Linux:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - l_i_version
     - Inode version. However, if the EA_INODE inode flag is set, this inode
       stores an extended attribute value and this field contains the upper 32
       bits of the attribute value's reference count.

Vội vàng:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - h_i_translator
     - ??

Masix:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - m_i_reserved
     - ??

.. _i_osd2:

Trường ZZ0000ZZ có nhiều ý nghĩa tùy thuộc vào người tạo hệ thống tệp:

Linux:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le16
     - l_i_blocks_high
     - Upper 16-bits of the block count. Please see the note attached to
       i_blocks_lo.
   * - 0x2
     - __le16
     - l_i_file_acl_high
     - Upper 16-bits of the extended attribute block (historically, the file
       ACL location). See the Extended Attributes section below.
   * - 0x4
     - __le16
     - l_i_uid_high
     - Upper 16-bits of the Owner UID.
   * - 0x6
     - __le16
     - l_i_gid_high
     - Upper 16-bits of the GID.
   * - 0x8
     - __le16
     - l_i_checksum_lo
     - Lower 16-bits of the inode checksum.
   * - 0xA
     - __le16
     - l_i_reserved
     - Unused.

Vội vàng:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le16
     - h_i_reserved1
     - ??
   * - 0x2
     - __u16
     - h_i_mode_high
     - Upper 16-bits of the file mode.
   * - 0x4
     - __le16
     - h_i_uid_high
     - Upper 16-bits of the Owner UID.
   * - 0x6
     - __le16
     - h_i_gid_high
     - Upper 16-bits of the GID.
   * - 0x8
     - __u32
     - h_i_author
     - Author code?

Masix:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le16
     - h_i_reserved1
     - ??
   * - 0x2
     - __u16
     - m_i_file_acl_high
     - Upper 16-bits of the extended attribute block (historically, the file
       ACL location).
   * - 0x4
     - __u32
     - m_i_reserved2[2]
     - ??

Kích thước nút
~~~~~~~~~~

Trong ext2 và ext3, kích thước cấu trúc inode được cố định ở mức 128 byte
(ZZ0000ZZ) và mỗi nút có kích thước bản ghi đĩa là
128 byte. Bắt đầu với ext4, có thể phân bổ số tiền lớn hơn
inode trên đĩa tại thời điểm định dạng để tất cả các inode trong hệ thống tập tin cung cấp
khoảng trống ngoài phần cuối của inode ext2 ban đầu. Inode trên đĩa
kích thước bản ghi được ghi trong siêu khối là ZZ0001ZZ. các
số byte thực sự được sử dụng bởi struct ext4_inode ngoài bản gốc
Inode ext2 128 byte được ghi trong trường ZZ0002ZZ cho mỗi
inode, cho phép struct ext4_inode phát triển cho kernel mới mà không cần
phải nâng cấp tất cả các nút trên đĩa. Truy cập vào các lĩnh vực ngoài
EXT2_GOOD_OLD_INODE_SIZE phải được xác minh nằm trong
ZZ0003ZZ. Theo mặc định, các bản ghi inode ext4 là 256 byte và (như
của tháng 8 năm 2019) cấu trúc inode là 160 byte
(ZZ0004ZZ). Khoảng trống thừa giữa phần cuối của inode
Cấu trúc và phần cuối của bản ghi inode có thể được sử dụng để lưu trữ phần mở rộng
thuộc tính. Mỗi bản ghi inode có thể lớn bằng khối hệ thống tập tin
size, mặc dù điều này không hiệu quả lắm.

Tìm một Inode
~~~~~~~~~~~~~~~~

Mỗi nhóm khối chứa các nút ZZ0000ZZ. Bởi vì
inode 0 được xác định là không tồn tại, công thức này có thể được sử dụng để tìm
nhóm khối mà một inode sống trong:
ZZ0001ZZ. Inode cụ thể
có thể được tìm thấy trong bảng inode của nhóm khối tại
ZZ0002ZZ. Để lấy byte
địa chỉ trong bảng inode, sử dụng
ZZ0003ZZ.

Dấu thời gian Inode
~~~~~~~~~~~~~~~~

Bốn dấu thời gian được ghi ở 128 byte thấp hơn của nút
cấu trúc -- thời gian thay đổi inode (ctime), thời gian truy cập (atime), dữ liệu
thời gian sửa đổi (mtime) và thời gian xóa (dtime). Bốn cánh đồng
là các số nguyên có dấu 32 bit biểu thị giây kể từ kỷ nguyên Unix
(1970-01-01 00:00:00 GMT), có nghĩa là các trường sẽ tràn vào
Tháng 1 năm 2038. Nếu hệ thống tập tin không có tính năng orphan_file, inodes
không được liên kết từ bất kỳ thư mục nào nhưng vẫn mở (inode mồ côi) có
trường dtime bị quá tải để sử dụng với danh sách mồ côi. Trường siêu khối
ZZ0000ZZ trỏ đến nút đầu tiên trong danh sách mồ côi; dtime là sau đó
số lượng của nút mồ côi tiếp theo hoặc bằng 0 nếu không còn nút mồ côi nào nữa.

Nếu kích thước cấu trúc inode ZZ0000ZZ lớn hơn 128
byte và trường ZZ0001ZZ đủ lớn để bao gồm
trường ZZ0002ZZ tương ứng, ctime, atime và mtime
trường inode được mở rộng lên 64 bit. Trong trường 32-bit “bổ sung” này,
hai bit thấp hơn được sử dụng để mở rộng trường giây 32 bit thành 34
hơi rộng; 30 bit trên được sử dụng để cung cấp dấu thời gian nano giây
độ chính xác. Do đó, dấu thời gian không được tràn cho đến tháng 5 năm 2446.
dtime không được mở rộng. Ngoài ra còn có dấu thời gian thứ năm để ghi inode
thời gian tạo (crtime); trường này rộng 64-bit và được giải mã trong
theo cách tương tự như thời gian [cma] 64-bit. Cả crtime và dtime đều không thể truy cập được
thông qua giao diện stat() thông thường, mặc dù các trình gỡ lỗi sẽ báo cáo chúng.

Chúng tôi sử dụng giá trị thời gian đã ký 32 bit cộng thêm (2^32 * (bit kỷ nguyên bổ sung)).
Nói cách khác:

.. list-table::
   :widths: 20 20 20 20 20
   :header-rows: 1

   * - Extra epoch bits
     - MSB of 32-bit time
     - Adjustment for signed 32-bit to 64-bit tv_sec
     - Decoded 64-bit tv_sec
     - valid time range
   * - 0 0
     - 1
     - 0
     - ``-0x80000000 - -0x00000001``
     - 1901-12-13 to 1969-12-31
   * - 0 0
     - 0
     - 0
     - ``0x000000000 - 0x07fffffff``
     - 1970-01-01 to 2038-01-19
   * - 0 1
     - 1
     - 0x100000000
     - ``0x080000000 - 0x0ffffffff``
     - 2038-01-19 to 2106-02-07
   * - 0 1
     - 0
     - 0x100000000
     - ``0x100000000 - 0x17fffffff``
     - 2106-02-07 to 2174-02-25
   * - 1 0
     - 1
     - 0x200000000
     - ``0x180000000 - 0x1ffffffff``
     - 2174-02-25 to 2242-03-16
   * - 1 0
     - 0
     - 0x200000000
     - ``0x200000000 - 0x27fffffff``
     - 2242-03-16 to 2310-04-04
   * - 1 1
     - 1
     - 0x300000000
     - ``0x280000000 - 0x2ffffffff``
     - 2310-04-04 to 2378-04-22
   * - 1 1
     - 0
     - 0x300000000
     - ``0x300000000 - 0x37fffffff``
     - 2378-04-22 to 2446-05-10

Đây là một cách mã hóa hơi kỳ lạ vì thực tế có tới bảy lần
nhiều giá trị dương cũng như nhiều giá trị âm. Cũng đã có
các lỗi giải mã và mã hóa lâu đời có niên đại vượt quá năm 2038, không
dường như đã được sửa từ kernel 3.12 và e2fspross 1.42.8. Hạt nhân 64-bit
sử dụng không chính xác các bit epoch bổ sung 1,1 cho các ngày từ năm 1901 đến
1970. Đến một lúc nào đó kernel sẽ được sửa và e2fsck sẽ sửa lỗi này
tình huống, giả sử rằng nó được chạy trước năm 2310.