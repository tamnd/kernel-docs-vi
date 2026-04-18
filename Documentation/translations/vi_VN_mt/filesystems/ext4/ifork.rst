.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/ifork.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Nội dung của inode.i_block
------------------------------

Tùy thuộc vào loại tệp mà một nút mô tả, 60 byte của
lưu trữ trong ZZ0000ZZ có thể được sử dụng theo nhiều cách khác nhau. Nói chung,
các tập tin và thư mục thông thường sẽ sử dụng nó để lập chỉ mục khối tập tin
thông tin và các tập tin đặc biệt sẽ sử dụng nó cho các mục đích đặc biệt.

Liên kết tượng trưng
~~~~~~~~~~~~~~

Mục tiêu của một liên kết tượng trưng sẽ được lưu trữ trong trường này nếu mục tiêu
chuỗi dài dưới 60 byte. Mặt khác, phạm vi hoặc khối
bản đồ sẽ được sử dụng để phân bổ các khối dữ liệu để lưu trữ mục tiêu liên kết.

Địa chỉ khối trực tiếp/gián tiếp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trong ext2/3, số khối tệp được ánh xạ tới số khối logic bằng
phương tiện của (tối đa) ba bản đồ khối cấp 1-1. Để tìm khối logic
lưu trữ một khối tệp cụ thể, mã sẽ điều hướng qua
cấu trúc ngày càng phức tạp này. Chú ý rằng không có một
số ma thuật cũng như tổng kiểm tra để cung cấp bất kỳ mức độ tin cậy nào rằng
khối không chứa đầy rác.

.. ifconfig:: builder != 'latex'

   .. include:: blockmap.rst

.. ifconfig:: builder == 'latex'

   [Table omitted because LaTeX doesn't support nested tables.]

Lưu ý rằng với sơ đồ ánh xạ khối này, cần phải điền vào một
nhiều dữ liệu ánh xạ ngay cả đối với một tệp lớn liền kề! Sự kém hiệu quả này
dẫn đến việc tạo ra sơ đồ lập bản đồ phạm vi, được thảo luận dưới đây.

Cũng lưu ý rằng không thể đặt một tệp sử dụng sơ đồ ánh xạ này
cao hơn 2^32 khối.

Cây phạm vi
~~~~~~~~~~~

Trong ext4, tệp tới bản đồ khối logic đã được thay thế bằng phạm vi
cây. Theo sơ đồ cũ, phân bổ 1.000 khối liền kề
yêu cầu một khối gián tiếp để ánh xạ tất cả 1.000 mục; với phạm vi,
ánh xạ được giảm xuống thành một ZZ0000ZZ duy nhất với
ZZ0001ZZ. Nếu flex_bg được bật, có thể phân bổ
các tệp rất lớn với một mức độ duy nhất, giảm đáng kể
sử dụng khối siêu dữ liệu và một số cải tiến về hiệu suất ổ đĩa. nút
phải đặt cờ phạm vi (0x80000) để tính năng này hoạt động
sử dụng.

Các phạm vi được sắp xếp như một cái cây. Mỗi nút của cây bắt đầu bằng một
ZZ0000ZZ. Nếu nút là nút bên trong
(ZZ0001ZZ > 0), tiêu đề được theo sau bởi ZZ0002ZZ
phiên bản của ZZ0003ZZ; mỗi mục chỉ mục này
trỏ đến một khối chứa nhiều nút hơn trong cây phạm vi. Nếu nút
là nút lá (ZZ0004ZZ), sau đó tiêu đề được theo sau bởi
Các phiên bản ZZ0005ZZ của ZZ0006ZZ; những trường hợp này
trỏ đến khối dữ liệu của tập tin. Nút gốc của cây phạm vi là
được lưu trữ trong ZZ0007ZZ, cho phép bốn phạm vi đầu tiên
được ghi lại mà không cần sử dụng các khối siêu dữ liệu bổ sung.

Tiêu đề cây phạm vi được ghi trong ZZ0000ZZ,
dài 12 byte:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le16
     - eh_magic
     - Magic number, 0xF30A.
   * - 0x2
     - __le16
     - eh_entries
     - Number of valid entries following the header.
   * - 0x4
     - __le16
     - eh_max
     - Maximum number of entries that could follow the header.
   * - 0x6
     - __le16
     - eh_depth
     - Depth of this extent node in the extent tree. 0 = this extent node
       points to data blocks; otherwise, this extent node points to other
       extent nodes. The extent tree can be at most 5 levels deep: a logical
       block number can be at most ``2^32``, and the smallest ``n`` that
       satisfies ``4*(((blocksize - 12)/12)^n) >= 2^32`` is 5.
   * - 0x8
     - __le32
     - eh_generation
     - Generation of the tree. (Used by Lustre, but not standard ext4).

Các nút bên trong của cây phạm vi, còn được gọi là nút chỉ mục, là
được ghi là ZZ0000ZZ và dài 12 byte:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - ei_block
     - This index node covers file blocks from 'block' onward.
   * - 0x4
     - __le32
     - ei_leaf_lo
     - Lower 32-bits of the block number of the extent node that is the next
       level lower in the tree. The tree node pointed to can be either another
       internal node or a leaf node, described below.
   * - 0x8
     - __le16
     - ei_leaf_hi
     - Upper 16-bits of the previous field.
   * - 0xA
     - __u16
     - ei_unused
     -

Các nút lá của cây phạm vi được ghi là ZZ0000ZZ,
và cũng dài 12 byte:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - ee_block
     - First file block number that this extent covers.
   * - 0x4
     - __le16
     - ee_len
     - Number of blocks covered by extent. If the value of this field is <=
       32768, the extent is initialized. If the value of the field is > 32768,
       the extent is uninitialized and the actual extent length is ``ee_len`` -
       32768. Therefore, the maximum length of a initialized extent is 32768
       blocks, and the maximum length of an uninitialized extent is 32767.
   * - 0x6
     - __le16
     - ee_start_hi
     - Upper 16-bits of the block number to which this extent points.
   * - 0x8
     - __le32
     - ee_start_lo
     - Lower 32-bits of the block number to which this extent points.

Trước khi giới thiệu tổng kiểm tra siêu dữ liệu, tiêu đề phạm vi +
các mục phạm vi luôn để lại ít nhất 4 byte không gian chưa được phân bổ tại
cuối mỗi khối dữ liệu cây phạm vi (vì (2^x % 12) >= 4). Vì vậy,
tổng kiểm tra 32 bit được chèn vào không gian này. 4 phạm vi trong
inode không cần kiểm tra tổng vì inode đã được kiểm tra tổng.
Tổng kiểm tra được tính toán dựa trên FS UUID, số inode,
tạo inode và toàn bộ khối phạm vi dẫn đến (nhưng không phải
bao gồm cả) tổng kiểm tra.

ZZ0000ZZ dài 4 byte:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - eb_checksum
     - Checksum of the extent block, crc32c(uuid+inum+igeneration+extentblock)

Dữ liệu nội tuyến
~~~~~~~~~~~

Nếu tính năng dữ liệu nội tuyến được bật cho hệ thống tệp và cờ là
được đặt cho inode, có thể 60 byte đầu tiên của tệp
dữ liệu được lưu trữ ở đây.