.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/checksums.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Tổng kiểm tra
---------

Bắt đầu từ đầu năm 2012, tổng kiểm tra siêu dữ liệu đã được thêm vào tất cả các ext4 chính.
và cấu trúc dữ liệu jbd2. Cờ tính năng liên quan là siêu dữ liệu_csum.
Thuật toán tổng kiểm tra mong muốn được chỉ định trong siêu khối, mặc dù
vào tháng 10 năm 2012, thuật toán được hỗ trợ duy nhất là crc32c. Một số dữ liệu
các cấu trúc không có không gian để chứa tổng kiểm tra 32 bit đầy đủ, do đó chỉ có
16 bit thấp hơn được lưu trữ. Kích hoạt tính năng 64bit sẽ tăng dữ liệu
kích thước cấu trúc để có thể lưu trữ tổng kiểm tra 32 bit đầy đủ cho nhiều dữ liệu
các cấu trúc. Tuy nhiên, hệ thống tập tin 32-bit hiện tại không thể được mở rộng sang
kích hoạt chế độ 64bit, ít nhất là không có các thay đổi kích thước2fs thử nghiệm
các bản vá để làm như vậy.

Các hệ thống tập tin hiện có có thể được thêm tính năng kiểm tra bằng cách chạy
ZZ0000ZZ so với thiết bị cơ bản. Nếu tune2fs
gặp phải các khối thư mục thiếu đủ không gian trống để thêm một
tổng kiểm tra, nó sẽ yêu cầu bạn chạy ZZ0001ZZ để có
thư mục được xây dựng lại bằng tổng kiểm tra. Điều này có thêm lợi ích là
loại bỏ không gian trống khỏi các tệp thư mục và cân bằng lại htree
chỉ số. Nếu bạn _bỏ qua_ bước này, thư mục của bạn sẽ không được
được bảo vệ bởi tổng kiểm tra!

Bảng sau mô tả các thành phần dữ liệu thuộc từng loại
của tổng kiểm tra. Hàm tổng kiểm tra là bất cứ điều gì siêu khối mô tả
(crc32c kể từ tháng 10 năm 2013) trừ khi có ghi chú khác.

.. list-table::
   :widths: 20 8 50
   :header-rows: 1

   * - Metadata
     - Length
     - Ingredients
   * - Superblock
     - __le32
     - The entire superblock up to the checksum field. The UUID lives inside
       the superblock.
   * - MMP
     - __le32
     - UUID + the entire MMP block up to the checksum field.
   * - Extended Attributes
     - __le32
     - UUID + the entire extended attribute block. The checksum field is set to
       zero.
   * - Directory Entries
     - __le32
     - UUID + inode number + inode generation + the directory block up to the
       fake entry enclosing the checksum field.
   * - HTREE Nodes
     - __le32
     - UUID + inode number + inode generation + all valid extents + HTREE tail.
       The checksum field is set to zero.
   * - Extents
     - __le32
     - UUID + inode number + inode generation + the entire extent block up to
       the checksum field.
   * - Bitmaps
     - __le32 or __le16
     - UUID + the entire bitmap. Checksums are stored in the group descriptor,
       and truncated if the group descriptor size is 32 bytes (i.e. ^64bit)
   * - Inodes
     - __le32
     - UUID + inode number + inode generation + the entire inode. The checksum
       field is set to zero. Each inode has its own checksum.
   * - Group Descriptors
     - __le16
     - If metadata_csum, then UUID + group number + the entire descriptor;
       else if gdt_csum, then crc16(UUID + group number + the entire
       descriptor). In all cases, only the lower 16 bits are stored.
