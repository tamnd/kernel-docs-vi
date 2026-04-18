.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/attributes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Thuộc tính mở rộng
-------------------

Các thuộc tính mở rộng (xattrs) thường được lưu trữ trong một kho dữ liệu riêng biệt
khối trên đĩa và được tham chiếu từ các nút thông qua ZZ0000ZZ.
Việc sử dụng đầu tiên của các thuộc tính mở rộng dường như là để lưu trữ tập tin
ACL và dữ liệu bảo mật khác (selinux). Với ngàm ZZ0001ZZ
tùy chọn, người dùng có thể lưu trữ các thuộc tính mở rộng miễn là
tất cả tên thuộc tính đều bắt đầu bằng “người dùng”; hạn chế này dường như có
biến mất kể từ Linux 3.0.

Có hai nơi có thể tìm thấy các thuộc tính mở rộng. đầu tiên
vị trí nằm giữa phần cuối của mỗi mục inode và phần đầu của
mục inode tiếp theo. Ví dụ: nếu inode.i_extra_isize = 28 và
sb.inode_size = 256 thì có 256 - (128 + 28) = 100 byte
có sẵn để lưu trữ thuộc tính mở rộng trong inode. Vị trí thứ hai
nơi có thể tìm thấy các thuộc tính mở rộng nằm trong khối được trỏ bởi
ZZ0000ZZ. Kể từ Linux 3.11, điều này là không thể
khối chứa con trỏ tới khối thuộc tính mở rộng thứ hai (hoặc thậm chí
các khối còn lại của một cụm). Về lý thuyết, mỗi người có thể
giá trị của thuộc tính sẽ được lưu trữ trong một khối dữ liệu riêng biệt, mặc dù kể từ
Mã Linux 3.11 không cho phép điều này.

Các khóa thường được coi là các chuỗi ASCIIZ, trong khi các giá trị có thể là
chuỗi hoặc dữ liệu nhị phân.

Các thuộc tính mở rộng, khi được lưu trữ sau inode, sẽ có tiêu đề
ZZ0000ZZ dài 4 byte:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - __le32
     - h_magic
     - Magic number for identification, 0xEA020000. This value is set by the
       Linux driver, though e2fsprogs doesn't seem to check it(?)

Phần đầu của khối thuộc tính mở rộng nằm ở
ZZ0000ZZ, dài 32 byte:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - __le32
     - h_magic
     - Magic number for identification, 0xEA020000.
   * - 0x4
     - __le32
     - h_refcount
     - Reference count.
   * - 0x8
     - __le32
     - h_blocks
     - Number of disk blocks used.
   * - 0xC
     - __le32
     - h_hash
     - Hash value of all attributes.
   * - 0x10
     - __le32
     - h_checksum
     - Checksum of the extended attribute block.
   * - 0x14
     - __u32
     - h_reserved[3]
     - Zero.

Tổng kiểm tra được tính toán dựa trên FS UUID, số khối 64 bit
của khối thuộc tính mở rộng và toàn bộ khối (tiêu đề +
mục nhập).

Theo ZZ0000ZZ hoặc
ZZ0001ZZ là một mảng
ZZ0002ZZ; mỗi mục này có ít nhất 16 byte
dài. Khi được lưu trữ trong khối bên ngoài, ZZ0003ZZ
các mục phải được lưu trữ theo thứ tự sắp xếp. Thứ tự sắp xếp là
ZZ0004ZZ, rồi ZZ0005ZZ và cuối cùng là ZZ0006ZZ.
Các thuộc tính được lưu trữ bên trong một inode không cần phải được sắp xếp theo thứ tự.

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - __u8
     - e_name_len
     - Length of name.
   * - 0x1
     - __u8
     - e_name_index
     - Attribute name index. There is a discussion of this below.
   * - 0x2
     - __le16
     - e_value_offs
     - Location of this attribute's value on the disk block where it is stored.
       Multiple attributes can share the same value. For an inode attribute
       this value is relative to the start of the first entry; for a block this
       value is relative to the start of the block (i.e. the header).
   * - 0x4
     - __le32
     - e_value_inum
     - The inode where the value is stored. Zero indicates the value is in the
       same block as this entry. This field is only used if the
       INCOMPAT_EA_INODE feature is enabled.
   * - 0x8
     - __le32
     - e_value_size
     - Length of attribute value.
   * - 0xC
     - __le32
     - e_hash
     - Hash value of attribute name and attribute value. The kernel doesn't
       update the hash for in-inode attributes, so for that case this value
       must be zero, because e2fsck validates any non-zero hash regardless of
       where the xattr lives.
   * - 0x10
     - char
     - e_name[e_name_len]
     - Attribute name. Does not include trailing NULL.

Giá trị thuộc tính có thể theo cuối bảng nhập. Có vẻ như
yêu cầu chúng phải được căn chỉnh theo ranh giới 4 byte. Các giá trị
được lưu trữ bắt đầu từ cuối khối và tăng dần về phía
bảng xattr_header/xattr_entry. Khi cả hai va chạm nhau, lượng tràn là
đặt vào một khối đĩa riêng biệt. Nếu khối đĩa đầy,
hệ thống tập tin trả về -ENOSPC.

Bốn trường đầu tiên của ZZ0000ZZ được đặt thành 0 thành
đánh dấu sự kết thúc của danh sách khóa.

Tên thuộc tính Chỉ số
~~~~~~~~~~~~~~~~~~~~~~

Nói một cách logic, các thuộc tính mở rộng là một chuỗi các cặp khóa=giá trị.
Các khóa được coi là các chuỗi kết thúc NULL. Để giảm số lượng
không gian trên đĩa mà các phím sử dụng, phần đầu của chuỗi khóa
được so khớp với chỉ mục tên thuộc tính. Nếu tìm thấy sự trùng khớp,
trường chỉ mục tên thuộc tính được đặt và chuỗi phù hợp sẽ bị xóa khỏi
tên khóa. Đây là bản đồ các giá trị chỉ mục tên cho các tiền tố chính:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Name Index
     - Key Prefix
   * - 0
     - (no prefix)
   * - 1
     - “user.”
   * - 2
     - “system.posix_acl_access”
   * - 3
     - “system.posix_acl_default”
   * - 4
     - “trusted.”
   * - 6
     - “security.”
   * - 7
     - “system.” (inline_data only?)
   * - 8
     - “system.richacl” (SuSE kernels only?)

Ví dụ: nếu khóa thuộc tính là “user.fubar”, thì tên thuộc tính
chỉ mục được đặt thành 1 và tên “fubar” được ghi trên đĩa.

ACL POSIX
~~~~~~~~~~

Các ACL POSIX được lưu trữ trong phiên bản rút gọn của nhân Linux (và
libacl's) định dạng ACL nội bộ. Điểm khác biệt chính là phiên bản
số khác (1) và trường ZZ0000ZZ chỉ được lưu trữ cho tên
ACL của người dùng và nhóm.