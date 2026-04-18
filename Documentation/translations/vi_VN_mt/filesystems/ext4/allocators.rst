.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/allocators.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Chính sách phân bổ khối và Inode
---------------------------------

ext4 nhận ra (dù sao thì tốt hơn ext3) rằng vị trí dữ liệu là
nói chung là chất lượng mong muốn của một hệ thống tập tin. Trên một đĩa quay,
giữ các khối liên quan gần nhau làm giảm lượng chuyển động
mà bộ truyền động đầu và đĩa phải thực hiện để truy cập khối dữ liệu,
do đó tăng tốc đĩa IO. Trên SSD tất nhiên không có bộ phận chuyển động nào,
nhưng địa phương có thể tăng quy mô của mỗi yêu cầu chuyển trong khi
giảm tổng số yêu cầu. Địa phương này cũng có thể có
tác dụng của việc tập trung ghi vào một khối xóa duy nhất, có thể tăng tốc
lên tập tin viết lại đáng kể. Vì vậy, rất hữu ích để giảm
phân mảnh bất cứ khi nào có thể.

Công cụ đầu tiên mà ext4 sử dụng để chống phân mảnh là multi-block
người cấp phát. Khi một tập tin được tạo lần đầu tiên, bộ cấp phát khối
giả định phân bổ 8KiB dung lượng ổ đĩa cho tệp theo suy đoán
rằng không gian sẽ được viết sớm. Khi tập tin được đóng lại,
tất nhiên các phân bổ đầu cơ không được sử dụng sẽ được giải phóng, nhưng nếu
suy đoán là chính xác (thường là trường hợp ghi đầy đủ các dữ liệu nhỏ
files) thì dữ liệu tệp sẽ được ghi ra thành một khối đa khối
mức độ. Thủ thuật liên quan thứ hai mà ext4 sử dụng là phân bổ chậm.
Theo sơ đồ này, khi một tệp cần nhiều khối hơn để hấp thụ việc ghi tệp,
hệ thống tập tin trì hoãn việc quyết định vị trí chính xác trên đĩa cho đến khi tất cả
bộ đệm bẩn đang được ghi ra đĩa. Bằng cách không cam kết một
vị trí cụ thể cho đến khi nó thực sự cần thiết (thời gian chờ cam kết
bị tấn công, hoặc sync() được gọi, hoặc kernel hết bộ nhớ), hy vọng
là hệ thống tập tin có thể đưa ra quyết định vị trí tốt hơn.

Thủ thuật thứ ba mà ext4 (và ext3) sử dụng là nó cố gắng giữ một
khối dữ liệu của tệp trong cùng nhóm khối với nút của nó. Điều này cắt giảm
về hình phạt tìm kiếm khi hệ thống tập tin lần đầu tiên phải đọc inode của tập tin
để tìm hiểu vị trí các khối dữ liệu của tệp và sau đó tìm kiếm
khối dữ liệu của tệp để bắt đầu các thao tác I/O.

Bí quyết thứ tư là tất cả các nút trong một thư mục đều được đặt trong thư mục
cùng nhóm khối với thư mục, khi khả thi. Giả định làm việc
đây là tất cả các tập tin trong một thư mục có thể có liên quan với nhau, do đó nó
rất hữu ích để cố gắng giữ tất cả chúng lại với nhau.

Thủ thuật thứ năm là chia dung lượng ổ đĩa thành khối 128MB
nhóm; những thùng chứa nhỏ này được sử dụng như đã nêu ở trên để cố gắng
duy trì địa phương dữ liệu. Tuy nhiên, có một sai lầm có chủ ý -- khi một
thư mục được tạo trong thư mục gốc, bộ cấp phát inode sẽ quét
các nhóm khối và đặt thư mục đó vào nơi được tải ít nhất
nhóm khối mà nó có thể tìm thấy. Điều này khuyến khích các thư mục lan rộng ra
trên một đĩa; khi các đốm màu thư mục/tập tin cấp cao nhất lấp đầy một khối
nhóm, người phân bổ chỉ cần chuyển sang nhóm khối tiếp theo. Bị cáo buộc
sơ đồ này cân bằng tải trên các nhóm khối, mặc dù tác giả
nghi ngờ rằng những thư mục xui xẻo lại rơi vào
sự kết thúc của một ổ quay có được một thỏa thuận hiệu quả về mặt hiệu suất.

Tất nhiên, nếu tất cả các cơ chế này đều thất bại, người ta luôn có thể sử dụng e4defrag
để chống phân mảnh tập tin.