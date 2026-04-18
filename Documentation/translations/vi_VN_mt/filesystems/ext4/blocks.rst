.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/blocks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Khối
------

ext4 phân bổ không gian lưu trữ theo đơn vị “khối”. Khối là một nhóm
các lĩnh vực từ 1KiB đến 64KiB và số lượng lĩnh vực phải là một
lũy thừa tích phân của 2. Các khối lần lượt được nhóm thành các đơn vị lớn hơn gọi là
các nhóm khối. Kích thước khối được chỉ định tại thời điểm mkfs và thường là
4KiB. Bạn có thể gặp vấn đề về lắp đặt nếu kích thước khối lớn hơn
kích thước trang (tức là khối 64KiB trên i386 chỉ có bộ nhớ 4KiB
trang). Theo mặc định, hệ thống tập tin có thể chứa 2^32 khối; nếu là '64bit'
tính năng này được bật thì hệ thống tệp có thể có 2^64 khối. Vị trí
của các cấu trúc được lưu trữ dưới dạng số khối mà cấu trúc tồn tại
in chứ không phải phần bù tuyệt đối trên đĩa.

Đối với hệ thống tệp 32 bit, các giới hạn như sau:

.. list-table::
   :widths: 1 1 1 1 1
   :header-rows: 1

   * - Item
     - 1KiB
     - 2KiB
     - 4KiB
     - 64KiB
   * - Blocks
     - 2^32
     - 2^32
     - 2^32
     - 2^32
   * - Inodes
     - 2^32
     - 2^32
     - 2^32
     - 2^32
   * - File System Size
     - 4TiB
     - 8TiB
     - 16TiB
     - 256TiB
   * - Blocks Per Block Group
     - 8,192
     - 16,384
     - 32,768
     - 524,288
   * - Inodes Per Block Group
     - 8,192
     - 16,384
     - 32,768
     - 524,288
   * - Block Group Size
     - 8MiB
     - 32MiB
     - 128MiB
     - 32GiB
   * - Blocks Per File, Extents
     - 2^32
     - 2^32
     - 2^32
     - 2^32
   * - Blocks Per File, Block Maps
     - 16,843,020
     - 134,480,396
     - 1,074,791,436
     - 4,398,314,962,956 (really 2^32 due to field size limitations)
   * - File Size, Extents
     - 4TiB
     - 8TiB
     - 16TiB
     - 256TiB
   * - File Size, Block Maps
     - 16GiB
     - 256GiB
     - 4TiB
     - 256TiB

Đối với hệ thống tệp 64 bit, các giới hạn như sau:

.. list-table::
   :widths: 1 1 1 1 1
   :header-rows: 1

   * - Item
     - 1KiB
     - 2KiB
     - 4KiB
     - 64KiB
   * - Blocks
     - 2^64
     - 2^64
     - 2^64
     - 2^64
   * - Inodes
     - 2^32
     - 2^32
     - 2^32
     - 2^32
   * - File System Size
     - 16ZiB
     - 32ZiB
     - 64ZiB
     - 1YiB
   * - Blocks Per Block Group
     - 8,192
     - 16,384
     - 32,768
     - 524,288
   * - Inodes Per Block Group
     - 8,192
     - 16,384
     - 32,768
     - 524,288
   * - Block Group Size
     - 8MiB
     - 32MiB
     - 128MiB
     - 32GiB
   * - Blocks Per File, Extents
     - 2^32
     - 2^32
     - 2^32
     - 2^32
   * - Blocks Per File, Block Maps
     - 16,843,020
     - 134,480,396
     - 1,074,791,436
     - 4,398,314,962,956 (really 2^32 due to field size limitations)
   * - File Size, Extents
     - 4TiB
     - 8TiB
     - 16TiB
     - 256TiB
   * - File Size, Block Maps
     - 16GiB
     - 256GiB
     - 4TiB
     - 256TiB

Lưu ý: Các tệp không sử dụng phạm vi (tức là các tệp sử dụng bản đồ khối) phải
được đặt trong 2^32 khối đầu tiên của hệ thống tập tin. Các tập tin có phạm vi
phải được đặt trong 2^48 khối đầu tiên của hệ thống tệp. Nó không phải
rõ ràng điều gì xảy ra với các hệ thống tập tin lớn hơn.