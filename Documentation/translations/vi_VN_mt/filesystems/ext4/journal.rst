.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/journal.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Tạp chí (jbd2)
--------------

Được giới thiệu trong ext3, hệ thống tập tin ext4 sử dụng nhật ký để bảo vệ
hệ thống tập tin chống lại sự không nhất quán của siêu dữ liệu trong trường hợp hệ thống gặp sự cố. Lên
tới 10.240.000 khối hệ thống tệp (xem man mke2fs(8) để biết thêm chi tiết về tạp chí
giới hạn kích thước) có thể được đặt trước bên trong hệ thống tập tin làm nơi hạ cánh
Dữ liệu “quan trọng” được ghi vào đĩa càng nhanh càng tốt. Một khi điều quan trọng
giao dịch dữ liệu được ghi hoàn toàn vào đĩa và bị xóa khỏi đĩa ghi
cache, bản ghi dữ liệu được cam kết cũng được ghi vào nhật ký. Tại
một thời điểm nào đó sau đó, mã nhật ký sẽ ghi các giao dịch vào
vị trí cuối cùng trên đĩa (điều này có thể liên quan đến việc tìm kiếm nhiều hoặc nhiều thao tác nhỏ
đọc-ghi-xóa) trước khi xóa bản ghi cam kết. Nên hệ thống
gặp sự cố trong lần ghi chậm thứ hai, nhật ký có thể được phát lại tất cả
đường đến bản ghi cam kết mới nhất, đảm bảo tính nguyên tử của bất cứ điều gì
được ghi thông qua nhật ký vào đĩa. Tác dụng của việc này là
đảm bảo rằng hệ thống tập tin không bị kẹt giữa chừng
cập nhật siêu dữ liệu.

Vì lý do hiệu suất, ext4 theo mặc định chỉ ghi siêu dữ liệu hệ thống tệp
qua nhật ký. Điều này có nghĩa là các khối dữ liệu tệp là /not/
được đảm bảo ở bất kỳ trạng thái nhất quán nào sau khi xảy ra sự cố. Nếu mặc định này
mức độ đảm bảo (ZZ0000ZZ) không đạt yêu cầu, có gắn kết
tùy chọn để kiểm soát hành vi tạp chí. Nếu ZZ0001ZZ, tất cả dữ liệu và
siêu dữ liệu được ghi vào đĩa thông qua tạp chí. Điều này chậm hơn nhưng
an toàn nhất. Nếu ZZ0002ZZ, các khối dữ liệu bẩn sẽ không được chuyển sang
disk trước khi siêu dữ liệu được ghi vào đĩa thông qua nhật ký.

Trong trường hợp chế độ ZZ0000ZZ, Ext4 cũng hỗ trợ các cam kết nhanh
giúp giảm độ trễ cam kết đáng kể. ZZ0001ZZ mặc định
chế độ hoạt động bằng cách ghi các khối siêu dữ liệu vào tạp chí. Trong cam kết nhanh
chế độ, Ext4 chỉ lưu trữ delta tối thiểu cần thiết để tạo lại
siêu dữ liệu bị ảnh hưởng trong không gian cam kết nhanh được chia sẻ với JBD2.
Khi vùng cam kết nhanh đã đầy hoặc nếu không thể thực hiện cam kết nhanh
hoặc nếu bộ hẹn giờ cam kết JBD2 tắt, Ext4 sẽ thực hiện cam kết đầy đủ truyền thống.
Một cam kết đầy đủ làm mất hiệu lực tất cả các cam kết nhanh đã xảy ra trước đó
nó và do đó nó làm cho vùng cam kết nhanh trống để nhanh hơn nữa
cam kết. Tính năng này cần được kích hoạt tại thời điểm mkfs.

Inode nhật ký thường là inode 8. 68 byte đầu tiên của
Inode tạp chí được sao chép trong siêu khối ext4. Bản thân tạp chí
là tệp bình thường (nhưng bị ẩn) trong hệ thống tệp. Tập tin thường
tiêu thụ toàn bộ nhóm khối, mặc dù mke2fs cố gắng đặt nó vào
giữa đĩa.

Tất cả các trường trong jbd2 được ghi vào đĩa theo thứ tự big-endian. Đây là
ngược lại với ext4.

NOTE: Cả ext4 và ocfs2 đều sử dụng jbd2.

Kích thước tối đa của tạp chí được nhúng trong hệ thống tệp ext4 là 2^32
khối. Bản thân jbd2 dường như không quan tâm.

Cách trình bày
~~~~~~~~~~~~~~

Nói chung, tạp chí có định dạng này:

.. list-table::
   :widths: 16 48 16
   :header-rows: 1

   * - Superblock
     - descriptor_block (data_blocks or revocation_block) [more data or
       revocations] commmit_block
     - [more transactions...]
   * - 
     - One transaction
     -

Lưu ý rằng giao dịch bắt đầu bằng bộ mô tả và một số dữ liệu,
hoặc một danh sách thu hồi khối. Một giao dịch đã hoàn tất luôn kết thúc bằng một
cam kết. Nếu không có bản ghi cam kết (hoặc tổng kiểm tra không khớp),
giao dịch sẽ bị loại bỏ trong quá trình phát lại.

Tạp chí bên ngoài
~~~~~~~~~~~~~~~~~

Theo tùy chọn, hệ thống tệp ext4 có thể được tạo bằng nhật ký bên ngoài
thiết bị (trái ngược với nhật ký nội bộ, sử dụng nút dành riêng).
Trong trường hợp này, trên thiết bị hệ thống tập tin, ZZ0000ZZ phải
số không và ZZ0001ZZ nên được đặt. Trên thiết bị nhật ký ở đó
sẽ là một siêu khối ext4 ở vị trí thông thường, với UUID phù hợp.
Siêu khối tạp chí sẽ nằm trong khối đầy đủ tiếp theo sau khối
siêu khối.

.. list-table::
   :widths: 12 12 12 32 12
   :header-rows: 1

   * - 1024 bytes of padding
     - ext4 Superblock
     - Journal Superblock
     - descriptor_block (data_blocks or revocation_block) [more data or
       revocations] commmit_block
     - [more transactions...]
   * - 
     -
     -
     - One transaction
     -

Tiêu đề khối
~~~~~~~~~~~~

Mỗi khối trong nhật ký đều bắt đầu bằng tiêu đề 12 byte chung
ZZ0000ZZ:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - __be32
     - h_magic
     - jbd2 magic number, 0xC03B3998.
   * - 0x4
     - __be32
     - h_blocktype
     - Description of what this block contains. See the jbd2_blocktype_ table
       below.
   * - 0x8
     - __be32
     - h_sequence
     - The transaction ID that goes with this block.

.. _jbd2_blocktype:

Loại khối tạp chí có thể là một trong:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 1
     - Descriptor. This block precedes a series of data blocks that were
       written through the journal during a transaction.
   * - 2
     - Block commit record. This block signifies the completion of a
       transaction.
   * - 3
     - Journal superblock, v1.
   * - 4
     - Journal superblock, v2.
   * - 5
     - Block revocation records. This speeds up recovery by enabling the
       journal to skip writing blocks that were subsequently rewritten.

Siêu khối
~~~~~~~~~~~

Siêu khối dành cho tạp chí đơn giản hơn nhiều so với ext4.
Dữ liệu chính được lưu giữ bên trong là kích thước của tạp chí và nơi tìm thấy
bắt đầu nhật ký giao dịch.

Siêu khối tạp chí được ghi là ZZ0000ZZ,
dài 1024 byte:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * -
     -
     -
     - Static information describing the journal.
   * - 0x0
     - journal_header_t (12 bytes)
     - s_header
     - Common header identifying this as a superblock.
   * - 0xC
     - __be32
     - s_blocksize
     - Journal device block size.
   * - 0x10
     - __be32
     - s_maxlen
     - Total number of blocks in this journal.
   * - 0x14
     - __be32
     - s_first
     - First block of log information.
   * -
     -
     -
     - Dynamic information describing the current state of the log.
   * - 0x18
     - __be32
     - s_sequence
     - First commit ID expected in log.
   * - 0x1C
     - __be32
     - s_start
     - Block number of the start of log. Contrary to the comments, this field
       being zero does not imply that the journal is clean!
   * - 0x20
     - __be32
     - s_errno
     - Error value, as set by jbd2_journal_abort().
   * -
     -
     -
     - The remaining fields are only valid in a v2 superblock.
   * - 0x24
     - __be32
     - s_feature_compat;
     - Compatible feature set. See the table jbd2_compat_ below.
   * - 0x28
     - __be32
     - s_feature_incompat
     - Incompatible feature set. See the table jbd2_incompat_ below.
   * - 0x2C
     - __be32
     - s_feature_ro_compat
     - Read-only compatible feature set. There aren't any of these currently.
   * - 0x30
     - __u8
     - s_uuid[16]
     - 128-bit uuid for journal. This is compared against the copy in the ext4
       super block at mount time.
   * - 0x40
     - __be32
     - s_nr_users
     - Number of file systems sharing this journal.
   * - 0x44
     - __be32
     - s_dynsuper
     - Location of dynamic super block copy. (Not used?)
   * - 0x48
     - __be32
     - s_max_transaction
     - Limit of journal blocks per transaction. (Not used?)
   * - 0x4C
     - __be32
     - s_max_trans_data
     - Limit of data blocks per transaction. (Not used?)
   * - 0x50
     - __u8
     - s_checksum_type
     - Checksum algorithm used for the journal.  See jbd2_checksum_type_ for
       more info.
   * - 0x51
     - __u8[3]
     - s_padding2
     -
   * - 0x54
     - __be32
     - s_num_fc_blocks
     - Number of fast commit blocks in the journal.
   * - 0x58
     - __be32
     - s_head
     - Block number of the head (first unused block) of the journal, only
       up-to-date when the journal is empty.
   * - 0x5C
     - __u32
     - s_padding[40]
     -
   * - 0xFC
     - __be32
     - s_checksum
     - Checksum of the entire superblock, with this field set to zero.
   * - 0x100
     - __u8
     - s_users[16*48]
     - ids of all file systems sharing the log. e2fsprogs/Linux don't allow
       shared external journals, but I imagine Lustre (or ocfs2?), which use
       the jbd2 code, might.

.. _jbd2_compat:

Các tính năng tương thích của tạp chí là bất kỳ sự kết hợp nào sau đây:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 0x1
     - Journal maintains checksums on the data blocks.
       (JBD2_FEATURE_COMPAT_CHECKSUM)

.. _jbd2_incompat:

Các tính năng không tương thích của tạp chí là bất kỳ sự kết hợp nào sau đây:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 0x1
     - Journal has block revocation records. (JBD2_FEATURE_INCOMPAT_REVOKE)
   * - 0x2
     - Journal can deal with 64-bit block numbers.
       (JBD2_FEATURE_INCOMPAT_64BIT)
   * - 0x4
     - Journal commits asynchronously. (JBD2_FEATURE_INCOMPAT_ASYNC_COMMIT)
   * - 0x8
     - This journal uses v2 of the checksum on-disk format. Each journal
       metadata block gets its own checksum, and the block tags in the
       descriptor table contain checksums for each of the data blocks in the
       journal. (JBD2_FEATURE_INCOMPAT_CSUM_V2)
   * - 0x10
     - This journal uses v3 of the checksum on-disk format. This is the same as
       v2, but the journal block tag size is fixed regardless of the size of
       block numbers. (JBD2_FEATURE_INCOMPAT_CSUM_V3)
   * - 0x20
     - Journal has fast commit blocks. (JBD2_FEATURE_INCOMPAT_FAST_COMMIT)

.. _jbd2_checksum_type:

Mã loại tổng kiểm tra tạp chí là một trong những mã sau đây.  crc32 hoặc crc32c là
những lựa chọn có khả năng nhất.

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 1
     - CRC32
   * - 2
     - MD5
   * - 3
     - SHA1
   * - 4
     - CRC32C

Khối mô tả
~~~~~~~~~~~~~~~~

Khối mô tả chứa một mảng các thẻ khối tạp chí
mô tả vị trí cuối cùng của các khối dữ liệu tiếp theo trong
tạp chí. Các khối mô tả được mã hóa mở thay vì hoàn toàn
được mô tả bằng cấu trúc dữ liệu, nhưng dù sao đây cũng là cấu trúc khối.
Khối mô tả tiêu thụ ít nhất 36 byte, nhưng sử dụng khối đầy đủ:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Descriptor
   * - 0x0
     - journal_header_t
     - (open coded)
     - Common block header.
   * - 0xC
     - struct journal_block_tag_s
     - open coded array[]
     - Enough tags either to fill up the block or to describe all the data
       blocks that follow this descriptor block.

Thẻ khối tạp chí có bất kỳ định dạng nào sau đây, tùy thuộc vào định dạng nào
tính năng nhật ký và cờ thẻ khối được thiết lập.

Nếu JBD2_FEATURE_INCOMPAT_CSUM_V3 được đặt, thẻ khối tạp chí là
được định nghĩa là ZZ0000ZZ, trông giống như
theo dõi. Kích thước là 16 hoặc 32 byte.

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Descriptor
   * - 0x0
     - __be32
     - t_blocknr
     - Lower 32-bits of the location of where the corresponding data block
       should end up on disk.
   * - 0x4
     - __be32
     - t_flags
     - Flags that go with the descriptor. See the table jbd2_tag_flags_ for
       more info.
   * - 0x8
     - __be32
     - t_blocknr_high
     - Upper 32-bits of the location of where the corresponding data block
       should end up on disk. This is zero if JBD2_FEATURE_INCOMPAT_64BIT is
       not enabled.
   * - 0xC
     - __be32
     - t_checksum
     - Checksum of the journal UUID, the sequence number, and the data block.
   * -
     -
     -
     - This field appears to be open coded. It always comes at the end of the
       tag, after t_checksum. This field is not present if the "same UUID" flag
       is set.
   * - 0x8 or 0xC
     - char
     - uuid[16]
     - A UUID to go with this tag. This field appears to be copied from the
       ``j_uuid`` field in ``struct journal_s``, but only tune2fs touches that
       field.

.. _jbd2_tag_flags:

Cờ thẻ tạp chí là bất kỳ sự kết hợp nào sau đây:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 0x1
     - On-disk block is escaped. The first four bytes of the data block just
       happened to match the jbd2 magic number.
   * - 0x2
     - This block has the same UUID as previous, therefore the UUID field is
       omitted.
   * - 0x4
     - The data block was deleted by the transaction. (Not used?)
   * - 0x8
     - This is the last tag in this descriptor block.

Nếu JBD2_FEATURE_INCOMPAT_CSUM_V3 được đặt NOT, thẻ khối tạp chí
được định nghĩa là ZZ0000ZZ, trông giống như
theo dõi. Kích thước là 8, 12, 24 hoặc 28 byte:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Descriptor
   * - 0x0
     - __be32
     - t_blocknr
     - Lower 32-bits of the location of where the corresponding data block
       should end up on disk.
   * - 0x4
     - __be16
     - t_checksum
     - Checksum of the journal UUID, the sequence number, and the data block.
       Note that only the lower 16 bits are stored.
   * - 0x6
     - __be16
     - t_flags
     - Flags that go with the descriptor. See the table jbd2_tag_flags_ for
       more info.
   * -
     -
     -
     - This next field is only present if the super block indicates support for
       64-bit block numbers.
   * - 0x8
     - __be32
     - t_blocknr_high
     - Upper 32-bits of the location of where the corresponding data block
       should end up on disk.
   * -
     -
     -
     - This field appears to be open coded. It always comes at the end of the
       tag, after t_flags or t_blocknr_high. This field is not present if the
       "same UUID" flag is set.
   * - 0x8 or 0xC
     - char
     - uuid[16]
     - A UUID to go with this tag. This field appears to be copied from the
       ``j_uuid`` field in ``struct journal_s``, but only tune2fs touches that
       field.

Nếu JBD2_FEATURE_INCOMPAT_CSUM_V2 hoặc
JBD2_FEATURE_INCOMPAT_CSUM_V3 được thiết lập, phần cuối của khối là
ZZ0000ZZ, trông như thế này:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Descriptor
   * - 0x0
     - __be32
     - t_checksum
     - Checksum of the journal UUID + the descriptor block, with this field set
       to zero.

Khối dữ liệu
~~~~~~~~~~~~

Nói chung, các khối dữ liệu được ghi vào đĩa thông qua nhật ký
được viết nguyên văn vào tệp nhật ký sau khối mô tả.
Tuy nhiên, nếu bốn byte đầu tiên của khối khớp với phép thuật jbd2
số thì bốn byte đó được thay thế bằng số 0 và "thoát"
cờ được đặt trong thẻ khối mô tả.

Khối thu hồi
~~~~~~~~~~~~~~~~

Khối thu hồi được sử dụng để ngăn chặn việc lặp lại khối trong lần truy cập trước đó.
giao dịch. Điều này được sử dụng để đánh dấu các khối đã được ghi nhật ký tại một
thời gian nhưng không còn được ghi nhật ký. Thông thường điều này xảy ra nếu siêu dữ liệu
khối được giải phóng và phân bổ lại dưới dạng khối dữ liệu tệp; trong trường hợp này, một
việc phát lại nhật ký sau khi khối tập tin được ghi vào đĩa sẽ gây ra
tham nhũng.

ZZ0000ZZ: Cơ chế này là NOT dùng để diễn đạt “khối tạp chí này là
được thay thế bởi khối tạp chí khác này”, với tư cách là tác giả (djwong)
đã nghĩ nhầm. Bất kỳ khối nào được thêm vào giao dịch sẽ gây ra
việc loại bỏ tất cả các bản ghi thu hồi hiện có cho khối đó.

Khối thu hồi được mô tả trong
ZZ0000ZZ, có ít nhất 16 byte
length, nhưng sử dụng một khối đầy đủ:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - journal_header_t
     - r_header
     - Common block header.
   * - 0xC
     - __be32
     - r_count
     - Number of bytes used in this block.
   * - 0x10
     - __be32 or __be64
     - blocks[0]
     - Blocks to revoke.

Sau r_count là một mảng tuyến tính gồm các số khối có hiệu quả
bị thu hồi bởi giao dịch này. Kích thước của mỗi số khối là 8 byte nếu
siêu khối quảng cáo hỗ trợ số khối 64 bit hoặc 4 byte
mặt khác.

Nếu JBD2_FEATURE_INCOMPAT_CSUM_V2 hoặc
JBD2_FEATURE_INCOMPAT_CSUM_V3 đã được thiết lập, việc thu hồi kết thúc
khối là ZZ0000ZZ, có định dạng sau:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - __be32
     - r_checksum
     - Checksum of the journal UUID + revocation block

Khối cam kết
~~~~~~~~~~~~

Khối cam kết là một lệnh canh gác cho biết rằng một giao dịch đã được thực hiện
viết hoàn toàn vào nhật ký. Khi khối cam kết này đạt đến
tạp chí, dữ liệu được lưu trữ với giao dịch này có thể được ghi vào
vị trí cuối cùng trên đĩa.

Khối cam kết được mô tả bởi ZZ0000ZZ, là 32
dài byte (nhưng sử dụng khối đầy đủ):

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Descriptor
   * - 0x0
     - journal_header_s
     - (open coded)
     - Common block header.
   * - 0xC
     - unsigned char
     - h_chksum_type
     - The type of checksum to use to verify the integrity of the data blocks
       in the transaction. See jbd2_checksum_type_ for more info.
   * - 0xD
     - unsigned char
     - h_chksum_size
     - The number of bytes used by the checksum. Most likely 4.
   * - 0xE
     - unsigned char
     - h_padding[2]
     -
   * - 0x10
     - __be32
     - h_chksum[JBD2_CHECKSUM_BYTES]
     - 32 bytes of space to store checksums. If
       JBD2_FEATURE_INCOMPAT_CSUM_V2 or JBD2_FEATURE_INCOMPAT_CSUM_V3
       are set, the first ``__be32`` is the checksum of the journal UUID and
       the entire commit block, with this field zeroed. If
       JBD2_FEATURE_COMPAT_CHECKSUM is set, the first ``__be32`` is the
       crc32 of all the blocks already written to the transaction.
   * - 0x30
     - __be64
     - h_commit_sec
     - The time that the transaction was committed, in seconds since the epoch.
   * - 0x38
     - __be32
     - h_commit_nsec
     - Nanoseconds component of the above timestamp.

Cam kết nhanh
~~~~~~~~~~~~~

Vùng cam kết nhanh được tổ chức dưới dạng nhật ký giá trị độ dài thẻ. Mỗi TLV có
ZZ0000ZZ ở đầu lưu trữ thẻ và độ dài
của toàn bộ lĩnh vực. Tiếp theo là giá trị cụ thể của thẻ có độ dài thay đổi.
Dưới đây là danh sách các thẻ được hỗ trợ và ý nghĩa của chúng:

.. list-table::
   :widths: 8 20 20 32
   :header-rows: 1

   * - Tag
     - Meaning
     - Value struct
     - Description
   * - EXT4_FC_TAG_HEAD
     - Fast commit area header
     - ``struct ext4_fc_head``
     - Stores the TID of the transaction after which these fast commits should
       be applied.
   * - EXT4_FC_TAG_ADD_RANGE
     - Add extent to inode
     - ``struct ext4_fc_add_range``
     - Stores the inode number and extent to be added in this inode
   * - EXT4_FC_TAG_DEL_RANGE
     - Remove logical offsets to inode
     - ``struct ext4_fc_del_range``
     - Stores the inode number and the logical offset range that needs to be
       removed
   * - EXT4_FC_TAG_CREAT
     - Create directory entry for a newly created file
     - ``struct ext4_fc_dentry_info``
     - Stores the parent inode number, inode number and directory entry of the
       newly created file
   * - EXT4_FC_TAG_LINK
     - Link a directory entry to an inode
     - ``struct ext4_fc_dentry_info``
     - Stores the parent inode number, inode number and directory entry
   * - EXT4_FC_TAG_UNLINK
     - Unlink a directory entry of an inode
     - ``struct ext4_fc_dentry_info``
     - Stores the parent inode number, inode number and directory entry

   * - EXT4_FC_TAG_PAD
     - Padding (unused area)
     - None
     - Unused bytes in the fast commit area.

   * - EXT4_FC_TAG_TAIL
     - Mark the end of a fast commit
     - ``struct ext4_fc_tail``
     - Stores the TID of the commit, CRC of the fast commit of which this tag
       represents the end of

Cam kết phát lại nhanh Idempotence
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các thẻ cam kết nhanh về bản chất là bình thường với điều kiện mã khôi phục tuân theo
những quy tắc nhất định. Nguyên tắc hướng dẫn mà đường dẫn cam kết tuân theo trong khi
cam kết là nó lưu trữ kết quả của một hoạt động cụ thể thay vì
lưu trữ thủ tục.

Hãy xem xét thao tác đổi tên này: 'mv /a /b'. Giả sử trực tiếp '/a'
được liên kết với inode 10. Trong quá trình chuyển giao nhanh, thay vì lưu trữ thông tin này
hoạt động như một thủ tục "đổi tên a thành b", chúng tôi lưu trữ hệ thống tệp kết quả
nêu dưới dạng một "chuỗi" kết quả:

- Link hướng b tới inode 10
- Hủy liên kết trực tiếp a
- Inode 10 có số tiền hoàn lại hợp lệ

Bây giờ khi mã khôi phục chạy, nó cần "thực thi" trạng thái này trên tệp
hệ thống. Đây là những gì đảm bảo tính bình thường của việc phát lại cam kết nhanh.

Hãy lấy một ví dụ về một thủ tục không bình thường và xem tốc độ
cam kết làm cho nó bình thường. Hãy xem xét chuỗi hoạt động sau đây:

1) rm A
2) mv B A
3) đọc A

Nếu chúng ta lưu trữ chuỗi hoạt động này như cũ thì việc phát lại không bình thường.
Giả sử trong khi phát lại, chúng tôi gặp sự cố sau (2). Trong lần phát lại thứ hai,
tệp A (thực tế được tạo do thao tác "mv B A") sẽ nhận được
đã xóa. Do đó, tệp có tên A sẽ không xuất hiện khi chúng ta cố đọc A. Vì vậy, tệp này
chuỗi các hoạt động không bình thường. Tuy nhiên, như đã đề cập ở trên, thay vì
lưu trữ thủ tục nhanh chóng cam kết lưu trữ kết quả của mỗi thủ tục. Như vậy
nhật ký cam kết nhanh cho quy trình trên sẽ như sau:

(Giả sử dirent A được liên kết với inode 10 và dirent B được liên kết với
inode 11 trước khi phát lại)

1) Hủy liên kết A
2) Liên kết A với inode 11
3) Hủy liên kết B
4) Nút 11

Nếu chúng tôi gặp sự cố sau (3), chúng tôi sẽ có tệp A được liên kết với inode 11. Trong lần thứ hai
phát lại, chúng tôi sẽ xóa tệp A (inode 11). Nhưng chúng tôi sẽ tạo lại nó và thực hiện
nó trỏ tới inode 11. Chúng ta sẽ không tìm thấy B nên sẽ bỏ qua bước đó. Lúc này
Điểm này, việc đếm lại cho inode 11 không đáng tin cậy, nhưng điều đó đã được khắc phục bởi
phát lại thẻ inode 11 cuối cùng. Vì vậy, bằng cách chuyển đổi một thủ tục không đẳng thức
thành một loạt các kết quả bình thường, các cam kết nhanh chóng đảm bảo sự bình thường trong suốt
sự phát lại.

Điểm kiểm tra tạp chí
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Việc kiểm tra nhật ký đảm bảo tất cả các giao dịch và bộ đệm liên quan của chúng
được đưa vào đĩa. Các giao dịch đang diễn ra được chờ đợi và bao gồm
ở trạm kiểm soát. Điểm kiểm tra được sử dụng nội bộ trong các cập nhật quan trọng đối với
hệ thống tập tin bao gồm khôi phục tạp chí, thay đổi kích thước hệ thống tập tin và giải phóng
cấu trúc tạp chí_t.

Điểm kiểm tra tạp chí có thể được kích hoạt từ không gian người dùng thông qua ioctl
EXT4_IOC_CHECKPOINT. Ioctl này nhận một đối số u64 duy nhất cho cờ.
Hiện tại, ba lá cờ được hỗ trợ. Đầu tiên, EXT4_IOC_CHECKPOINT_FLAG_DRY_RUN
có thể được sử dụng để xác minh đầu vào của ioctl. Nó trả về lỗi nếu có
đầu vào không hợp lệ, nếu không nó sẽ trả về thành công mà không thực hiện
bất kỳ điểm kiểm tra nào. Điều này có thể được sử dụng để kiểm tra xem ioctl có tồn tại trên một
hệ thống và để xác minh không có vấn đề gì với đối số hoặc cờ. các
hai cờ còn lại là EXT4_IOC_CHECKPOINT_FLAG_DISCARD và
EXT4_IOC_CHECKPOINT_FLAG_ZEROOUT. Những lá cờ này làm cho các khối tạp chí bị
tương ứng bị loại bỏ hoặc điền vào 0 sau khi điểm kiểm tra tạp chí được hoàn thành
hoàn thành. EXT4_IOC_CHECKPOINT_FLAG_DISCARD và EXT4_IOC_CHECKPOINT_FLAG_ZEROOUT
không thể thiết lập cả hai. Ioctl có thể hữu ích khi chụp nhanh một hệ thống hoặc cho
tuân thủ SLO xóa nội dung.