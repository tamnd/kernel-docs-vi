.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/squashfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Hệ thống tập tin Squashfs 4.0
=======================

Squashfs là một hệ thống tệp nén chỉ đọc dành cho Linux.

Nó sử dụng nén zlib, lz4, lzo, xz hoặc zstd để nén các tập tin, inode và
thư mục.  Các nút trong hệ thống rất nhỏ và tất cả các khối được đóng gói thành
giảm thiểu chi phí dữ liệu. Kích thước khối lớn hơn 4K được hỗ trợ lên tới
tối đa 1Mbyte (kích thước khối mặc định 128K).

Squashfs được thiết kế để sử dụng chung cho hệ thống tệp chỉ đọc, để lưu trữ
sử dụng (tức là trong trường hợp có thể sử dụng tệp .tar.gz) và trong trường hợp bị ràng buộc
chặn thiết bị/hệ thống bộ nhớ (ví dụ: hệ thống nhúng) nơi có chi phí hoạt động thấp
cần thiết.

Danh sách gửi thư (mã hạt nhân): linux-fsdevel@vger.kernel.org
Trang web: github.com/plougher/squashfs-tools

1. Tính năng hệ thống tập tin
----------------------

Các tính năng của hệ thống tập tin Squashfs so với Cramfs:

=============================== =====================
				Giải bóng quần
=============================== =====================
Kích thước hệ thống tập tin tối đa 2^64 256 MiB
Kích thước tệp tối đa ~ 2 TiB 16 MiB
Tập tin tối đa không giới hạn không giới hạn
Thư mục tối đa không giới hạn không giới hạn
Mục nhập tối đa cho mỗi thư mục không giới hạn không giới hạn
Kích thước khối tối đa 1 MiB 4 KiB
Nén siêu dữ liệu có không
Chỉ mục thư mục có không
Hỗ trợ tập tin thưa thớt có không
Đóng gói ở phần đuôi (mảnh vỡ) có không
Có thể xuất khẩu (NFS, v.v.) có không
Hỗ trợ liên kết cứng có không
"." và ".." trong readdir có không
Số inode thực có không
uid/gids 32-bit có không
Thời gian tạo tập tin có không
Hỗ trợ Xattr có không
Hỗ trợ ACL không không
=============================== =====================

Squashfs nén dữ liệu, inode và thư mục.  Ngoài ra, inode và
dữ liệu thư mục được nén chặt và đóng gói trên các ranh giới byte.  Mỗi
inode nén có độ dài trung bình là 8 byte (độ dài chính xác thay đổi tùy theo
loại tệp, tức là tệp thông thường, thư mục, liên kết tượng trưng và thiết bị khối/char
inode có kích thước khác nhau).

2. Sử dụng Squashf
-----------------

Vì Squashfs là một hệ thống tập tin chỉ đọc nên chương trình mksquashfs phải được sử dụng để
tạo các hệ thống tập tin squatfs đông dân.  Tiện ích này và các tiện ích squatfs khác
rất có thể được đóng gói bởi bản phân phối linux của bạn (được gọi là công cụ squatfs).
Mã nguồn có thể được lấy từ github.com/plougher/squashfs-tools.
Hướng dẫn sử dụng cũng có thể được lấy từ trang web này.

2.1 Tùy chọn gắn kết
-----------------
==================================================================================
error=%s Chỉ định xem lỗi squallfs có gây ra hoảng loạn kernel hay không
                       hay không

============================================================
                         lỗi tiếp tục không gây ra sự hoảng loạn (mặc định)
                            hoảng loạn gây ra hoảng loạn khi gặp phải lỗi,
                                   tương tự như một số hệ thống tập tin khác (ví dụ:
                                   btrfs, ext4, f2fs, GFS2, jfs, ntfs, ubifs)

Điều này cho phép lưu kết xuất kernel,
                                   hữu ích cho việc phân tích và gỡ lỗi
                                   tham nhũng.
                       ============================================================
thread=%s Chọn chế độ giải nén hoặc số lượng thread

Nếu SQUASHFS_CHOICE_DECOMP_BY_MOUNT được đặt:

============================================================
                           giải nén đơn luồng sử dụng một lần (mặc định)

Chỉ có thể có một khối (dữ liệu hoặc siêu dữ liệu)
                                   giải nén bất cứ lúc nào. Giới hạn này
                                   CPU và mức sử dụng bộ nhớ ở mức tối thiểu, nhưng nó
                                   cũng cho hiệu suất kém trên I/O song song
                                   khối lượng công việc khi sử dụng nhiều máy CPU
                                   do phải chờ đợi bộ giải nén sẵn có.
                            đa sử dụng tối đa hai bộ giải nén song song trên mỗi lõi

Nếu bạn có khối lượng công việc I/O song song và
                                   hệ thống có đủ bộ nhớ, sử dụng tùy chọn này
                                   có thể cải thiện hiệu suất I/O tổng thể. Nó
                                   phân bổ động các bộ giải nén trên một
                                   cơ sở nhu cầu.
                           percpu sử dụng tối đa một bộ giải nén cho mỗi lõi

Nó sử dụng các biến percpu để đảm bảo
                                   giải nén được cân bằng tải trên toàn bộ
                                   lõi.
                        1|2|3|... định cấu hình số lượng luồng được sử dụng cho
                                   giải nén

Giới hạn trên là num_online_cpus() * 2.
                       ============================================================

Nếu SQUASHFS_CHOICE_DECOMP_BY_MOUNT được đặt ZZ0000ZZ và
                       SQUASHFS_DECOMP_MULTI, SQUASHFS_MOUNT_DECOMP_THREADS là
                       cả hai đều được đặt:

============================================================
                          2|3|... định cấu hình số lượng luồng được sử dụng cho
                                   giải nén

Giới hạn trên là num_online_cpus() * 2.
                       ============================================================

==================================================================================

3. Thiết kế hệ thống tập tin Squashfs
-----------------------------

Một hệ thống tập tin squallfs bao gồm tối đa chín phần, được đóng gói cùng nhau trên một
căn chỉnh byte::

---------------
	ZZ0000ZZ
	ZZ0001ZZ
	ZZ0002ZZ
	ZZ0003ZZ
	ZZ0004ZZ
	ZZ0005ZZ
	ZZ0006ZZ
	ZZ0007ZZ
	ZZ0008ZZ
	ZZ0009ZZ
	ZZ0010ZZ
	ZZ0011ZZ
	ZZ0012ZZ
	ZZ0013ZZ
	ZZ0014ZZ
	ZZ0015ZZ
	ZZ0016ZZ
	ZZ0017ZZ
	ZZ0018ZZ
	ZZ0019ZZ
	ZZ0020ZZ
	ZZ0021ZZ
	ZZ0022ZZ
	ZZ0023ZZ
	 ---------------

Các khối dữ liệu nén được ghi vào hệ thống tập tin khi các tập tin được đọc từ
thư mục nguồn và kiểm tra các bản sao.  Khi tất cả dữ liệu tập tin đã được
đã viết inode, thư mục, đoạn, xuất, tra cứu uid/gid và
bảng xattr được viết.

3.1 Tùy chọn nén
-----------------------

Máy nén có thể tùy chọn hỗ trợ các tùy chọn nén cụ thể (ví dụ:
kích thước từ điển).  Nếu các tùy chọn nén không mặc định đã được sử dụng thì
chúng được lưu trữ ở đây.

3.2 Inode
----------

Siêu dữ liệu (inode và thư mục) được nén thành các khối 8Kbyte.  Mỗi
khối nén được bắt đầu bằng độ dài hai byte, bit trên cùng được đặt nếu
khối không bị nén.  Một khối sẽ không bị nén nếu tùy chọn -noI được đặt,
hoặc nếu khối nén lớn hơn khối không nén.

Các nút được đóng gói vào các khối siêu dữ liệu và không được căn chỉnh theo khối
ranh giới, do đó các nút chồng lên nhau các khối nén.  Inode được xác định
bằng số 48 bit mã hóa vị trí của khối siêu dữ liệu đã nén
chứa inode và byte offset vào khối chứa inode đó
được đặt (<khối, offset>).

Để tối đa hóa khả năng nén, có các nút khác nhau cho từng loại tệp
(tệp thông thường, thư mục, thiết bị, v.v.), nội dung và độ dài của inode
khác nhau tùy theo loại.

Để tối đa hóa khả năng nén hơn nữa, hai loại tệp inode thông thường và
inode thư mục được định nghĩa: các inode được tối ưu hóa cho các trường hợp xảy ra thường xuyên
các tập tin và thư mục thông thường cũng như các loại mở rộng có thêm
thông tin phải được lưu trữ.

3.3 Thư mục
---------------

Giống như inode, các thư mục được đóng gói thành các khối siêu dữ liệu nén, được lưu trữ
trong một bảng thư mục.  Các thư mục được truy cập bằng địa chỉ bắt đầu của
metablock chứa thư mục và offset vào
khối được giải nén (<khối, offset>).

Các thư mục được tổ chức theo cách hơi phức tạp và không đơn giản
một danh sách tên tập tin.  Tổ chức này tận dụng lợi thế của
thực tế là (trong hầu hết các trường hợp) các nút của tệp sẽ giống nhau
khối siêu dữ liệu được nén và do đó có thể chia sẻ khối bắt đầu.
Do đó, các thư mục được tổ chức theo danh sách hai cấp, một thư mục
tiêu đề chứa giá trị khối bắt đầu được chia sẻ và một chuỗi thư mục
các mục, mỗi mục chia sẻ khối bắt đầu được chia sẻ.  Tiêu đề thư mục mới
được viết một lần/nếu khối bắt đầu inode thay đổi.  Thư mục
danh sách mục nhập tiêu đề/thư mục được lặp lại nhiều lần nếu cần thiết.

Các thư mục được sắp xếp và có thể chứa chỉ mục thư mục để tăng tốc
tra cứu tập tin.  Chỉ mục thư mục lưu trữ một mục nhập cho mỗi metablock, mỗi mục nhập
lưu trữ ánh xạ chỉ mục/tên tệp vào tiêu đề thư mục đầu tiên
trong mỗi khối siêu dữ liệu.  Các thư mục được sắp xếp theo thứ tự bảng chữ cái,
và khi tra cứu, chỉ mục được quét tuyến tính để tìm tên tệp đầu tiên
lớn hơn theo thứ tự bảng chữ cái so với tên tệp đang được tra cứu.  Tại thời điểm này
vị trí của khối siêu dữ liệu chứa tên tệp đã được tìm thấy.
Ý tưởng chung của chỉ mục là đảm bảo chỉ cần một khối siêu dữ liệu
được giải nén để thực hiện tra cứu bất kể độ dài của thư mục.
Lược đồ này có ưu điểm là không yêu cầu thêm chi phí bộ nhớ
và không yêu cầu thêm nhiều dung lượng lưu trữ trên đĩa.

3.4 Dữ liệu tệp
-------------

Các tệp thông thường bao gồm một chuỗi các khối nén liền kề và/hoặc một
khối mảnh nén (khối đóng gói ở cuối đuôi).   Kích thước nén
của mỗi khối dữ liệu được lưu trữ trong một danh sách khối chứa trong
tập tin inode.

Để tăng tốc độ truy cập vào khối dữ liệu khi đọc các tệp 'lớn' (256 Mbyte hoặc
lớn hơn), mã sẽ triển khai bộ đệm chỉ mục để lưu trữ ánh xạ từ
chặn chỉ mục đến vị trí khối dữ liệu trên đĩa.

Bộ đệm chỉ mục cho phép Squashfs xử lý các tệp lớn (lên tới 1,75 TiB) trong khi
giữ lại một danh sách khối đơn giản và tiết kiệm không gian trên đĩa.  Bộ đệm
được chia thành các khe, lưu vào bộ nhớ đệm tối đa tám tệp 224 GiB (128 khối KiB).
Các tệp lớn hơn sử dụng nhiều khe cắm, với 1,75 tệp TiB sử dụng tất cả 8 khe cắm.
Bộ đệm chỉ mục được thiết kế để có hiệu quả về bộ nhớ và theo mặc định sử dụng
16 KiB.

3.5 Bảng tra cứu mảnh
-------------------------

Các tệp thông thường có thể chứa chỉ mục phân đoạn được ánh xạ tới một phân đoạn
vị trí trên đĩa và kích thước nén bằng bảng tra cứu phân đoạn.  Cái này
bảng tra cứu đoạn được lưu trữ nén thành các khối siêu dữ liệu.
Bảng chỉ mục thứ hai được sử dụng để xác định vị trí này.  Bảng chỉ mục thứ hai này cho
tốc độ truy cập (và vì nó nhỏ) được đọc tại thời điểm gắn kết và được lưu vào bộ đệm
trong bộ nhớ.

3.6 Bảng tra cứu Uid/gid
------------------------

Để tiết kiệm không gian, các tệp thông thường lưu trữ các chỉ mục uid và gid, đó là
được chuyển đổi thành uid/gid 32 bit bằng bảng tra cứu id.  Bảng này là
được lưu trữ nén thành các khối siêu dữ liệu.  Bảng chỉ mục thứ hai được sử dụng để
xác định vị trí này.  Bảng chỉ mục thứ hai này cho tốc độ truy cập (và bởi vì nó
nhỏ) được đọc tại thời điểm gắn kết và được lưu vào bộ nhớ.

3.7 Xuất bảng
----------------

Để cho phép hệ thống tệp Squashfs có thể xuất được (thông qua NFS, v.v.)
có thể tùy chọn (bị vô hiệu hóa với tùy chọn -no-exports Mksquashfs) chứa
một số inode vào bảng tra cứu vị trí đĩa inode.  Điều này là cần thiết để
cho phép Squashfs ánh xạ các số inode được truyền trong các tước hiệu tệp tới inode
vị trí trên đĩa, điều này cần thiết khi mã xuất được khôi phục
inode hết hạn/xóa.

Bảng này được lưu trữ nén thành các khối siêu dữ liệu.  Bảng chỉ mục thứ hai là
được sử dụng để định vị những thứ này.  Bảng chỉ mục thứ hai này cho tốc độ truy cập (và bởi vì
nó nhỏ) được đọc tại thời điểm gắn kết và được lưu vào bộ nhớ.

3.8 Bảng Xattr
---------------

Bảng xattr chứa các thuộc tính mở rộng cho mỗi inode.  Xattrs
đối với mỗi nút được lưu trữ trong một danh sách, mỗi mục danh sách chứa một loại,
trường tên và giá trị.  Trường loại mã hóa tiền tố xattr
("người dùng.", "đáng tin cậy." v.v.) và nó cũng mã hóa cách các trường tên/giá trị
nên được giải thích.  Hiện tại loại cho biết liệu giá trị
được lưu trữ nội tuyến (trong trường hợp đó trường giá trị chứa giá trị xattr),
hoặc nếu nó được lưu ngoài dòng (trong trường hợp đó trường giá trị lưu trữ một
tham chiếu đến nơi lưu trữ giá trị thực tế).  Điều này cho phép các giá trị lớn
được lưu trữ ngoài dòng để cải thiện hiệu suất quét và tra cứu và nó
cũng cho phép các giá trị được loại bỏ trùng lặp, giá trị được lưu trữ một lần và
tất cả các lần xuất hiện khác có tham chiếu ngoài dòng đến giá trị đó.

Danh sách xattr được đóng gói thành các khối siêu dữ liệu 8K được nén.
Để giảm chi phí hoạt động ở các nút, thay vì lưu trữ trên đĩa
vị trí của danh sách xattr bên trong mỗi inode, id xattr 32 bit
được lưu trữ.  Id xattr này được ánh xạ vào vị trí của xattr
list bằng bảng tra cứu id xattr thứ hai.

4. TODO và các vấn đề tồn đọng
-------------------------------

4.1 Danh sách TODO
-------------

Triển khai hỗ trợ ACL.

4.2 Bộ nhớ đệm nội bộ của Squashfs
---------------------------

Các khối trong Squashfs được nén.  Để tránh phải giải nén nhiều lần
dữ liệu được truy cập gần đây Squashfs sử dụng hai bộ đệm siêu dữ liệu và phân đoạn nhỏ.

Bộ đệm không được sử dụng cho các khối dữ liệu tệp, chúng được giải nén và lưu vào bộ đệm
bộ đệm trang theo cách thông thường.  Bộ đệm được sử dụng để lưu trữ tạm thời
đoạn và khối siêu dữ liệu đã được đọc nhờ siêu dữ liệu
(tức là inode hoặc thư mục) hoặc truy cập phân đoạn.  Bởi vì siêu dữ liệu và các đoạn
được đóng gói lại với nhau thành các khối (để đạt được độ nén lớn hơn) việc đọc của một
phần siêu dữ liệu hoặc đoạn cụ thể sẽ truy xuất siêu dữ liệu/đoạn khác
đã được đóng gói cùng với nó, những thứ này do tham chiếu địa phương có thể
đọc trong thời gian sắp tới. Lưu trữ tạm thời chúng để đảm bảo chúng có sẵn
để truy cập trong tương lai gần mà không cần đọc và giải nén thêm.

Trong tương lai bộ đệm nội bộ này có thể được thay thế bằng một triển khai
sử dụng bộ đệm trang kernel.  Bởi vì bộ đệm trang hoạt động trên kích thước trang
các đơn vị này có thể gây thêm sự phức tạp về mặt khóa và
điều kiện chủng tộc liên quan.