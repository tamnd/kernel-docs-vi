.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/blockgroup.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Nhóm khối
------------

Cách trình bày
~~~~~~~~~~~~~~

Bố cục của một nhóm khối tiêu chuẩn xấp xỉ như sau (mỗi khối
của các trường này được thảo luận trong một phần riêng bên dưới):

.. list-table::
   :widths: 1 1 1 1 1 1 1 1
   :header-rows: 1

   * - Group 0 Padding
     - ext4 Super Block
     - Group Descriptors
     - Reserved GDT Blocks
     - Data Block Bitmap
     - inode Bitmap
     - inode Table
     - Data Blocks
   * - 1024 bytes
     - 1 block
     - many blocks
     - many blocks
     - 1 block
     - 1 block
     - many blocks
     - many more blocks

Đối với trường hợp đặc biệt của nhóm khối 0, 1024 byte đầu tiên không được sử dụng,
để cho phép cài đặt các cung khởi động x86 và những điều kỳ lạ khác.
Siêu khối sẽ bắt đầu ở offset 1024 byte, tùy theo khối nào
xảy ra (thường là 0). Tuy nhiên, nếu vì lý do nào đó kích thước khối =
1024 thì khối 0 được đánh dấu đang sử dụng và siêu khối sẽ ở khối 1.
Đối với tất cả các nhóm khối khác, không có phần đệm.

Trình điều khiển ext4 chủ yếu hoạt động với siêu khối và nhóm
các bộ mô tả được tìm thấy trong nhóm khối 0. Các bản sao dư thừa của
mô tả nhóm và siêu khối được ghi vào một số nhóm khối
trên đĩa trong trường hợp phần đầu của đĩa bị chuyển vào thùng rác
không phải tất cả các nhóm khối đều nhất thiết phải lưu trữ một bản sao dự phòng (xem phần sau
đoạn để biết thêm chi tiết). Nếu nhóm không có người thừa
sao chép, nhóm khối bắt đầu bằng bitmap khối dữ liệu. Cũng lưu ý rằng
khi hệ thống tập tin được định dạng mới, mkfs sẽ phân bổ “dự trữ
Khối GDT” không gian sau bộ mô tả nhóm khối và trước khi bắt đầu
của các bitmap khối để cho phép mở rộng hệ thống tập tin trong tương lai. Bởi
mặc định, hệ thống tập tin được phép tăng kích thước theo hệ số
1024x so với kích thước hệ thống tập tin gốc.

Vị trí của bảng inode được đưa ra bởi ZZ0000ZZ. Nó
là phạm vi liên tục của các khối đủ lớn để chứa
byte ZZ0001ZZ.

Về việc sắp xếp các mục trong một nhóm khối, thông thường
đã xác định rằng siêu khối và bảng mô tả nhóm, nếu
hiện tại, sẽ ở đầu nhóm khối. Các bitmap và
bảng inode có thể ở bất cứ đâu, và điều đó hoàn toàn có thể xảy ra đối với
bitmap nằm sau bảng inode hoặc cả hai có vị trí khác nhau
nhóm (flex_bg). Không gian còn lại được sử dụng cho các khối dữ liệu tệp, gián tiếp
bản đồ khối, khối cây phạm vi và thuộc tính mở rộng.

Nhóm khối linh hoạt
~~~~~~~~~~~~~~~~~~~~~

Bắt đầu từ ext4, có một tính năng mới gọi là nhóm khối linh hoạt
(flex_bg). Trong flex_bg, một số nhóm khối được liên kết với nhau thành một
nhóm khối logic; không gian bitmap và không gian bảng inode trong
nhóm khối đầu tiên của flex_bg được mở rộng để bao gồm các bitmap
và bảng inode của tất cả các nhóm khối khác trong flex_bg. Ví dụ,
nếu kích thước flex_bg là 4 thì nhóm 0 sẽ chứa (theo thứ tự)
superblock, bộ mô tả nhóm, bitmap khối dữ liệu cho các nhóm 0-3, inode
bitmap cho nhóm 0-3, bảng inode cho nhóm 0-3 và phần còn lại
khoảng trống trong nhóm 0 dành cho dữ liệu tệp. Tác dụng của việc này là nhóm các
siêu dữ liệu nhóm khối gần nhau để tải nhanh hơn và để kích hoạt
các tập tin lớn được liên tục trên đĩa. Bản sao lưu của siêu khối
và mô tả nhóm luôn ở đầu các nhóm khối, thậm chí
nếu flex_bg được bật. Số lượng nhóm khối tạo nên một
flex_bg được cho bởi 2^ZZ0000ZZ.

Nhóm khối meta
~~~~~~~~~~~~~~~~~

Không có tùy chọn META_BG, vì lý do an toàn, tất cả nhóm khối
bản sao mô tả được giữ trong nhóm khối đầu tiên. Cho mặc định
Kích thước nhóm khối 128MiB(2^27 byte) và bộ mô tả nhóm 64 byte, ext4
có thể có tối đa 2^27/64 = 2^21 nhóm khối. Điều này hạn chế toàn bộ
kích thước hệ thống tệp thành 2^21 * 2^27 = 2^48byte hoặc 256TiB.

Giải pháp cho vấn đề này là sử dụng tính năng nhóm metablock
(META_BG), đã có sẵn trong ext3 cho tất cả các bản phát hành 2.6. Với
Tính năng META_BG, hệ thống tập tin ext4 được phân vùng thành nhiều metablock
các nhóm. Mỗi nhóm metablock là một cụm các nhóm khối có nhóm
cấu trúc mô tả có thể được lưu trữ trong một khối đĩa đơn. Đối với ext4
hệ thống tập tin có kích thước khối 4 KB, một phân vùng nhóm metablock duy nhất
bao gồm 64 nhóm khối hoặc 8 GiB dung lượng ổ đĩa. Nhóm metablock
tính năng di chuyển vị trí của các bộ mô tả nhóm từ vùng bị tắc nghẽn
nhóm khối đầu tiên của toàn bộ hệ thống tập tin vào nhóm đầu tiên của mỗi hệ thống tập tin
chính nhóm metablock. Các bản sao lưu nằm trong nhóm thứ hai và cuối cùng của
mỗi nhóm metablock. Điều này làm tăng giới hạn nhóm khối tối đa 2^21
đến giới hạn cứng 2^32, cho phép hỗ trợ hệ thống tệp 512PiB.

Sự thay đổi trong định dạng hệ thống tập tin sẽ thay thế sơ đồ hiện tại trong đó
siêu khối được theo sau bởi một tập hợp nhóm khối có độ dài thay đổi
những người mô tả. Thay vào đó, siêu khối và một bộ mô tả nhóm khối duy nhất
khối được đặt ở đầu khối đầu tiên, khối thứ hai và khối cuối cùng
các nhóm trong một nhóm meta-block. Nhóm meta-block là một tập hợp các
các nhóm khối có thể được mô tả bằng một bộ mô tả nhóm khối duy nhất
khối. Vì kích thước của cấu trúc mô tả nhóm khối là 64
byte, một nhóm siêu khối chứa 16 nhóm khối cho các hệ thống tập tin có
kích thước khối 1KB và 64 nhóm khối cho hệ thống tệp có 4KB
blocksize. Hệ thống tập tin có thể được tạo bằng nhóm khối mới này
bố cục mô tả hoặc hệ thống tệp hiện có có thể được thay đổi kích thước trực tuyến và
trường s_first_meta_bg trong siêu khối sẽ chỉ ra giá trị đầu tiên
nhóm khối bằng cách sử dụng bố cục mới này.

Vui lòng xem một lưu ý quan trọng về ZZ0000ZZ trong phần về
bitmap khối và inode.

Khởi tạo nhóm khối lười biếng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Một tính năng mới cho ext4 là ba cờ mô tả nhóm khối
cho phép mkfs bỏ qua việc khởi tạo các phần khác của nhóm khối
siêu dữ liệu. Cụ thể, cờ INODE_UNINIT và BLOCK_UNINIT có nghĩa là
rằng các bitmap inode và khối cho nhóm đó có thể được tính toán và
do đó các khối bitmap trên đĩa không được khởi tạo. Đây là
nói chung là trường hợp nhóm khối trống hoặc nhóm khối chứa
chỉ siêu dữ liệu nhóm khối vị trí cố định. Cờ INODE_ZEROED có nghĩa là
bảng inode đã được khởi tạo; mkfs sẽ bỏ cờ này và
dựa vào kernel để khởi tạo các bảng inode ở chế độ nền.

Bằng cách không ghi số 0 vào bảng bitmap và inode, thời gian của mkfs là
giảm đáng kể. Lưu ý cờ tính năng là RO_COMPAT_GDT_CSUM,
nhưng kết quả đầu ra của dumpe2fs in ra là “uninit_bg”. Họ giống nhau
thứ.