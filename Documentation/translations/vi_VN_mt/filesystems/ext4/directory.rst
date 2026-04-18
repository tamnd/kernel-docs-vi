.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/directory.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Mục nhập thư mục
-----------------

Trong hệ thống tập tin ext4, một thư mục ít nhiều là một tập tin phẳng ánh xạ
một chuỗi byte tùy ý (thường là ASCII) thành số inode trên
hệ thống tập tin. Có thể có nhiều mục thư mục trên hệ thống tập tin
tham chiếu cùng số inode - chúng được gọi là liên kết cứng và
đó là lý do tại sao các liên kết cứng không thể tham chiếu các tệp trên các hệ thống tệp khác. Như
như vậy, các mục thư mục được tìm thấy bằng cách đọc (các) khối dữ liệu
được liên kết với một tệp thư mục cho mục nhập thư mục cụ thể
được mong muốn.

Thư mục tuyến tính (Cổ điển)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Theo mặc định, mỗi thư mục liệt kê các mục của nó ở dạng “gần như tuyến tính”
mảng. Tôi viết “gần như” vì nó không phải là một mảng tuyến tính trong bộ nhớ
có ý nghĩa vì các mục thư mục không được chia thành các khối hệ thống tập tin.
Vì vậy, sẽ chính xác hơn khi nói rằng thư mục là một chuỗi các
khối dữ liệu và mỗi khối chứa một mảng thư mục tuyến tính
mục nhập. Sự kết thúc của mỗi mảng trên mỗi khối được biểu thị bằng cách đạt đến
cuối khối; mục cuối cùng trong khối có độ dài bản ghi
đưa nó đến tận cuối dãy nhà. Sự kết thúc của toàn bộ
Tất nhiên, thư mục được biểu thị bằng cách đến cuối tập tin. Chưa sử dụng
các mục trong thư mục được biểu thị bằng inode = 0. Theo mặc định, hệ thống tập tin
sử dụng ZZ0000ZZ cho các mục nhập thư mục trừ khi
Cờ tính năng “filetype” không được đặt, trong trường hợp đó nó sử dụng
ZZ0001ZZ.

Định dạng mục nhập thư mục gốc là ZZ0000ZZ,
dài tối đa là 263 byte, mặc dù trên đĩa bạn sẽ cần tham khảo
ZZ0001ZZ để biết chắc chắn.

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - inode
     - Number of the inode that this directory entry points to.
   * - 0x4
     - __le16
     - rec_len
     - Length of this directory entry. Must be a multiple of 4.
   * - 0x6
     - __le16
     - name_len
     - Length of the file name.
   * - 0x8
     - char
     - name[EXT4_NAME_LEN]
     - File name.

Vì tên tệp không thể dài hơn 255 byte nên thư mục mới
định dạng mục nhập rút ngắn trường name_len và sử dụng khoảng trắng cho tệp
gõ cờ, có thể là để tránh phải tải mọi inode trong thư mục
duyệt cây. Định dạng này là ZZ0000ZZ, nhiều nhất là
Dài 263 byte, mặc dù trên đĩa bạn sẽ cần tham khảo
ZZ0001ZZ để biết chắc chắn.

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - inode
     - Number of the inode that this directory entry points to.
   * - 0x4
     - __le16
     - rec_len
     - Length of this directory entry.
   * - 0x6
     - __u8
     - name_len
     - Length of the file name.
   * - 0x7
     - __u8
     - file_type
     - File type code, see ftype_ table below.
   * - 0x8
     - char
     - name[EXT4_NAME_LEN]
     - File name.

.. _ftype:

Loại tệp thư mục là một trong các giá trị sau:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 0x0
     - Unknown.
   * - 0x1
     - Regular file.
   * - 0x2
     - Directory.
   * - 0x3
     - Character device file.
   * - 0x4
     - Block device file.
   * - 0x5
     - FIFO.
   * - 0x6
     - Socket.
   * - 0x7
     - Symbolic link.

Để hỗ trợ các thư mục vừa được mã hóa vừa được phân loại theo dạng case, chúng tôi
cũng phải bao gồm thông tin băm trong mục nhập thư mục. Chúng tôi nối thêm
ZZ0000ZZ đến ZZ0001ZZ ngoại trừ các mục
cho dấu chấm và dấu chấm, được giữ nguyên. Cấu trúc theo sau ngay lập tức
sau ZZ0002ZZ và được bao gồm trong kích thước được liệt kê bởi ZZ0003ZZ Nếu một thư mục
mục sử dụng tiện ích mở rộng này, nó có thể lên tới 271 byte.

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - hash
     - The hash of the directory name
   * - 0x4
     - __le32
     - minor_hash
     - The minor hash of the directory name


Để thêm tổng kiểm tra vào các khối thư mục cổ điển này, một phần mềm giả mạo
ZZ0000ZZ được đặt ở cuối mỗi khối lá để
giữ tổng kiểm tra. Mục nhập thư mục dài 12 byte. nút
trường số và tên_len được đặt thành 0 để đánh lừa phần mềm cũ
bỏ qua một mục nhập thư mục dường như trống rỗng và tổng kiểm tra được lưu trữ
ở nơi tên thường đi. Cấu trúc là
ZZ0001ZZ:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Size
     - Name
     - Description
   * - 0x0
     - __le32
     - det_reserved_zero1
     - Inode number, which must be zero.
   * - 0x4
     - __le16
     - det_rec_len
     - Length of this directory entry, which must be 12.
   * - 0x6
     - __u8
     - det_reserved_zero2
     - Length of the file name, which must be zero.
   * - 0x7
     - __u8
     - det_reserved_ft
     - File type, which must be 0xDE.
   * - 0x8
     - __le32
     - det_checksum
     - Directory leaf block checksum.

Tổng kiểm tra khối thư mục lá được tính toán dựa trên FS UUID (hoặc
hạt giống tổng kiểm tra, nếu tính năng đó được bật cho fs), thư mục
số inode, số tạo inode của thư mục và toàn bộ
chặn mục nhập thư mục tối đa (nhưng không bao gồm) mục nhập thư mục giả mạo.

Thư mục cây băm
~~~~~~~~~~~~~~~~~~~~~

Một mảng tuyến tính gồm các mục trong thư mục không tốt cho hiệu năng, vì vậy
tính năng mới đã được thêm vào ext3 để cung cấp tốc độ nhanh hơn (nhưng đặc biệt)
cây cân bằng đã khóa một hàm băm của tên mục nhập thư mục. Nếu
Cờ EXT4_INDEX_FL (0x1000) được đặt trong inode, thư mục này sử dụng một
btree băm (htree) để sắp xếp và tìm các mục trong thư mục. cho
khả năng tương thích chỉ đọc ngược với ext2, các nút cây bên trong thực sự là
ẩn bên trong tập tin thư mục, giả mạo là các mục thư mục "trống"
bao trùm toàn bộ khối. Nó đã được tuyên bố trước đó rằng các mục thư mục
với inode được đặt thành 0 được coi là các mục không được sử dụng; đây là (ab) được sử dụng để
đánh lừa thuật toán quét tuyến tính cũ bỏ qua các khối chứa
dữ liệu nút cây bên trong.

Gốc của cây luôn nằm trong khối dữ liệu đầu tiên của cây.
thư mục. Theo tùy chỉnh ext2, '.' và các mục '..' phải xuất hiện ở
đầu khối đầu tiên này, vì vậy chúng được đặt ở đây thành hai
ZZ0000ZZ s và không được lưu trữ trên cây. Phần còn lại của
nút gốc chứa siêu dữ liệu về cây và cuối cùng là khối băm->
map để tìm các nút thấp hơn trong htree. Nếu
ZZ0001ZZ khác 0 thì htree có nhiều như vậy
các cấp độ và các khối được chỉ ra bởi bản đồ của nút gốc là các nút bên trong.
Các nút bên trong này có ZZ0002ZZ bị loại bỏ theo sau là
bản đồ băm-> khối để tìm các nút ở cấp độ tiếp theo. Các nút lá trông giống như
khối thư mục tuyến tính cổ điển, nhưng tất cả các mục của nó đều có giá trị băm
bằng hoặc lớn hơn giá trị băm được chỉ định của nút cha.

Giá trị băm thực tế cho một tên mục chỉ có 31 bit, giá trị nhỏ nhất
bit được đặt thành 0. Tuy nhiên, nếu có xung đột băm giữa thư mục
các mục có ý nghĩa nhỏ nhất có thể được đặt thành 1 trên các nút bên trong
trường hợp hai (hoặc nhiều) mục va chạm băm này không vừa với một lá
nút và phải được chia thành nhiều nút.

Để tra cứu tên trong cây htree như vậy, mã sẽ tính toán giá trị băm của tên mong muốn
tên tệp và sử dụng nó để tìm nút lá có phạm vi giá trị băm
hàm băm được tính rơi vào (nói cách khác, việc tra cứu về cơ bản hoạt động giống nhau
giống như trong B-Tree được khóa bằng giá trị băm) và cũng có thể quét
các nút lá theo sau (theo thứ tự cây) trong trường hợp có xung đột băm.

Để duyệt thư mục dưới dạng một mảng tuyến tính (chẳng hạn như mã cũ),
mã chỉ đơn giản là đọc mọi khối dữ liệu trong thư mục. Các khối được sử dụng
vì htree dường như không có mục nào (ngoài '.' và '..')
và do đó chỉ có các nút lá mới có nội dung thú vị.

Gốc của htree nằm trong ZZ0000ZZ, có độ dài đầy đủ
của một khối dữ liệu:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - __le32
     - dot.inode
     - inode number of this directory.
   * - 0x4
     - __le16
     - dot.rec_len
     - Length of this record, 12.
   * - 0x6
     - u8
     - dot.name_len
     - Length of the name, 1.
   * - 0x7
     - u8
     - dot.file_type
     - File type of this entry, 0x2 (directory) (if the feature flag is set).
   * - 0x8
     - char
     - dot.name[4]
     - “.\0\0\0”
   * - 0xC
     - __le32
     - dotdot.inode
     - inode number of parent directory.
   * - 0x10
     - __le16
     - dotdot.rec_len
     - block_size - 12. The record length is long enough to cover all htree
       data.
   * - 0x12
     - u8
     - dotdot.name_len
     - Length of the name, 2.
   * - 0x13
     - u8
     - dotdot.file_type
     - File type of this entry, 0x2 (directory) (if the feature flag is set).
   * - 0x14
     - char
     - dotdot_name[4]
     - “..\0\0”
   * - 0x18
     - __le32
     - struct dx_root_info.reserved_zero
     - Zero.
   * - 0x1C
     - u8
     - struct dx_root_info.hash_version
     - Hash type, see dirhash_ table below.
   * - 0x1D
     - u8
     - struct dx_root_info.info_length
     - Length of the tree information, 0x8.
   * - 0x1E
     - u8
     - struct dx_root_info.indirect_levels
     - Depth of the htree. Cannot be larger than 3 if the INCOMPAT_LARGEDIR
       feature is set; cannot be larger than 2 otherwise.
   * - 0x1F
     - u8
     - struct dx_root_info.unused_flags
     -
   * - 0x20
     - __le16
     - limit
     - Maximum number of dx_entries that can follow this header, plus 1 for
       the header itself.
   * - 0x22
     - __le16
     - count
     - Actual number of dx_entries that follow this header, plus 1 for the
       header itself.
   * - 0x24
     - __le32
     - block
     - The block number (within the directory file) that lead to the left-most
       leaf node, i.e. the leaf containing entries with the lowest hash values.
   * - 0x28
     - struct dx_entry
     - entries[0]
     - As many 8-byte ``struct dx_entry`` as fits in the rest of the data block.

.. _dirhash:

Băm thư mục là một trong các giá trị sau:

.. list-table::
   :widths: 16 64
   :header-rows: 1

   * - Value
     - Description
   * - 0x0
     - Legacy.
   * - 0x1
     - Half MD4.
   * - 0x2
     - Tea.
   * - 0x3
     - Legacy, unsigned.
   * - 0x4
     - Half MD4, unsigned.
   * - 0x5
     - Tea, unsigned.
   * - 0x6
     - Siphash.

Các nút bên trong của một htree được ghi là ZZ0000ZZ, đó là
cũng là chiều dài đầy đủ của một khối dữ liệu:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - __le32
     - fake.inode
     - Zero, to make it look like this entry is not in use.
   * - 0x4
     - __le16
     - fake.rec_len
     - The size of the block, in order to hide all of the dx_node data.
   * - 0x6
     - u8
     - name_len
     - Zero. There is no name for this “unused” directory entry.
   * - 0x7
     - u8
     - file_type
     - Zero. There is no file type for this “unused” directory entry.
   * - 0x8
     - __le16
     - limit
     - Maximum number of dx_entries that can follow this header, plus 1 for
       the header itself.
   * - 0xA
     - __le16
     - count
     - Actual number of dx_entries that follow this header, plus 1 for the
       header itself.
   * - 0xE
     - __le32
     - block
     - The block number (within the directory file) that goes with the lowest
       hash value of this block. This value is stored in the parent block.
   * - 0x12
     - struct dx_entry
     - entries[0]
     - As many 8-byte ``struct dx_entry`` as fits in the rest of the data block.

Các bản đồ băm tồn tại trong cả ZZ0000ZZ và
ZZ0001ZZ được ghi là ZZ0002ZZ, có dung lượng 8 byte
dài:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - __le32
     - hash
     - Hash code.
   * - 0x4
     - __le32
     - block
     - Block number (within the directory file, not filesystem blocks) of the
       next node in the htree.

(Nếu bạn cho rằng điều này khá thông minh và kỳ dị, thì
tác giả.)

Nếu tổng kiểm tra siêu dữ liệu được bật, 8 byte cuối cùng của thư mục
khối (chính xác là độ dài của một dx_entry) được sử dụng để lưu trữ một
ZZ0000ZZ, chứa tổng kiểm tra. ZZ0001ZZ và
Các mục ZZ0002ZZ trong cấu trúc dx_root/dx_node được điều chỉnh như
cần thiết để khớp dx_tail vào khối. Nếu không có chỗ cho
dx_tail, người dùng được thông báo chạy e2fsck -D để xây dựng lại
chỉ mục thư mục (sẽ đảm bảo rằng có không gian cho tổng kiểm tra.
Cấu trúc dx_tail dài 8 byte và trông như thế này:

.. list-table::
   :widths: 8 8 24 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - u32
     - dt_reserved
     - Unused (but still part of the checksum curiously).
   * - 0x4
     - __le32
     - dt_checksum
     - Checksum of the htree directory block.

Tổng kiểm tra được tính toán dựa trên FS UUID, tiêu đề chỉ mục htree
(dx_root hoặc dx_node), tất cả các chỉ số htree (dx_entry) có trong
sử dụng và khối đuôi (dx_tail) với dt_checksum ban đầu được đặt thành 0.