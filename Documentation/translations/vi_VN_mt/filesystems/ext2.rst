.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Hệ thống tập tin mở rộng thứ hai
=================================

ext2 ban đầu được phát hành vào tháng 1 năm 1993. Viết bởi R\'emy Card,
Theodore Ts'o và Stephen Tweedie, đây là bản viết lại chính của
Hệ thống tập tin mở rộng.  Hiện tại nó vẫn là (tháng 4 năm 2001) chiếm ưu thế
hệ thống tập tin được Linux sử dụng.  Ngoài ra còn có các triển khai có sẵn
cho NetBSD, FreeBSD, GNU HURD, Windows 95/98/NT, OS/2 và RISC OS.

Tùy chọn
=======

Hầu hết các giá trị mặc định được xác định bởi siêu khối hệ thống tập tin và có thể
thiết lập bằng tune2fs(8). Giá trị mặc định do hạt nhân xác định được biểu thị bằng (*).

======================= ======================================================
bsddf (*) Làm cho ZZ0000ZZ hoạt động giống như BSD.
minixdf Làm cho ZZ0001ZZ hoạt động giống như Minix.

check=none, nocheck (*) Đừng kiểm tra thêm bitmap khi mount
				(đã loại bỏ các tùy chọn kiểm tra=bình thường và kiểm tra=nghiêm ngặt)

dax Sử dụng quyền truy cập trực tiếp (không có bộ đệm trang).  Xem
				Tài liệu/hệ thống tập tin/dax.rst.

gỡ lỗi Thông tin gỡ lỗi bổ sung được gửi đến
				nhật ký hệ thống hạt nhân.  Hữu ích cho các nhà phát triển.

error=continue Tiếp tục xảy ra lỗi hệ thống tập tin.
error=remount-ro Gắn lại hệ thống tập tin chỉ đọc khi có lỗi.
error=panic Hoảng loạn và dừng máy nếu xảy ra lỗi.

grpid, bsdgroups Cung cấp cho các đối tượng ID nhóm giống như nhóm gốc của chúng.
nogrpid, sysvgroups Các đối tượng mới có ID nhóm của người tạo ra chúng.

nouid32 Sử dụng UID và GID 16 bit.

oldalloc Kích hoạt bộ cấp phát khối cũ. Orlov nên
				có hiệu suất tốt hơn, chúng tôi muốn có được một số
				phản hồi nếu nó ngược lại với bạn.
orlov (*) Sử dụng bộ cấp phát khối Orlov.
				(Xem ZZ0000ZZ và
				ZZ0001ZZ

resuid=n ID người dùng có thể sử dụng các khối dành riêng.
resgid=n ID nhóm có thể sử dụng các khối dành riêng.

sb=n Sử dụng siêu khối thay thế tại vị trí này.

user_xattr Bật "người dùng." POSIX Thuộc tính mở rộng
				(yêu cầu CONFIG_EXT2_FS_XATTR).
nouser_xattr Không hỗ trợ "người dùng." thuộc tính mở rộng.

acl Kích hoạt hỗ trợ Danh sách điều khiển truy cập POSIX
				(yêu cầu CONFIG_EXT2_FS_POSIX_ACL).
noacl Không hỗ trợ ACL POSIX.

hạn ngạch, usrquota Kích hoạt hỗ trợ hạn ngạch đĩa người dùng
				(yêu cầu CONFIG_QUOTA).

grpquota Kích hoạt hỗ trợ hạn ngạch đĩa nhóm
				(yêu cầu CONFIG_QUOTA).
======================= ======================================================

tùy chọn noquota ls bị ext2 âm thầm bỏ qua.


Đặc điểm kỹ thuật
=============

ext2 chia sẻ nhiều thuộc tính với các hệ thống tập tin Unix truyền thống.  Nó có
các khái niệm về khối, inode và thư mục.  Nó có không gian trong
đặc điểm kỹ thuật cho Danh sách điều khiển truy cập (ACL), phân đoạn, phục hồi và
nén mặc dù chúng chưa được triển khai (một số có sẵn dưới dạng
các bản vá riêng biệt).  Ngoài ra còn có một cơ chế tạo phiên bản để cho phép các phiên bản mới
các tính năng (chẳng hạn như ghi nhật ký) sẽ được thêm vào theo cách tương thích tối đa
cách.

Khối
------

Không gian trong thiết bị hoặc tệp được chia thành các khối.  Đây là
kích thước cố định là 1024, 2048 hoặc 4096 byte (8192 byte trên hệ thống Alpha),
được quyết định khi hệ thống tập tin được tạo.  Khối nhỏ hơn có nghĩa là
ít lãng phí không gian cho mỗi tệp nhưng yêu cầu chi phí kế toán nhiều hơn một chút,
và cũng áp đặt các giới hạn khác về kích thước của tệp và hệ thống tệp.

Nhóm khối
------------

Các khối được nhóm thành các nhóm khối để giảm sự phân mảnh
và giảm thiểu việc phải suy nghĩ khi đọc một lượng lớn
của dữ liệu liên tiếp.  Thông tin về từng nhóm khối được lưu giữ trong một
bảng mô tả được lưu trữ trong (các) khối ngay sau siêu khối.
Hai khối gần đầu mỗi nhóm được dành riêng cho việc sử dụng khối
bitmap và bitmap sử dụng inode hiển thị khối và inode nào
đang được sử dụng.  Vì mỗi bitmap được giới hạn ở một khối duy nhất, điều này có nghĩa
rằng kích thước tối đa của một nhóm khối là 8 lần kích thước của một khối.

(Các) khối theo sau bitmap trong mỗi nhóm khối được chỉ định
làm bảng inode cho nhóm khối đó và phần còn lại là dữ liệu
khối.  Thuật toán phân bổ khối cố gắng phân bổ các khối dữ liệu
trong cùng nhóm khối với inode chứa chúng.

Siêu khối
--------------

Siêu khối chứa tất cả thông tin về cấu hình của
hệ thống hồ sơ.  Bản sao chính của siêu khối được lưu trữ tại một
độ lệch 1024 byte kể từ đầu thiết bị và điều cần thiết là
để gắn hệ thống tập tin.  Vì nó rất quan trọng nên hãy sao lưu các bản sao của
siêu khối được lưu trữ trong các nhóm khối trên toàn bộ hệ thống tập tin.
Phiên bản đầu tiên của ext2 (phiên bản 0) lưu trữ một bản sao ở đầu
mỗi nhóm khối, cùng với các bản sao lưu của (các) khối mô tả nhóm.
Bởi vì điều này có thể tiêu tốn một lượng không gian đáng kể cho các
hệ thống tập tin, các bản sửa đổi sau này có thể tùy ý giảm số lượng bản sao lưu
sao chép bằng cách chỉ đặt các bản sao lưu vào các nhóm cụ thể (đây là kiểu dữ liệu thưa thớt
tính năng siêu khối).  Các nhóm được chọn là 0, 1 và lũy thừa 3, 5 và 7.

Thông tin trong siêu khối chứa các trường như tổng
số lượng nút và khối trong hệ thống tập tin và bao nhiêu nút trống,
có bao nhiêu nút và khối trong mỗi nhóm khối khi hệ thống tập tin
đã được gắn kết (và nếu nó được tháo hoàn toàn), khi nó được sửa đổi,
đó là phiên bản nào của hệ thống tập tin (xem phần Sửa đổi bên dưới)
và hệ điều hành nào đã tạo ra nó.

Nếu hệ thống tập tin là phiên bản 1 hoặc cao hơn thì sẽ có các trường bổ sung,
chẳng hạn như tên ổ đĩa, số nhận dạng duy nhất, kích thước inode,
và không gian cho các tính năng hệ thống tệp tùy chọn để lưu trữ thông tin cấu hình.

Tất cả các trường trong siêu khối (như trong tất cả các cấu trúc ext2 khác) đều được lưu trữ
trên đĩa ở định dạng little endian, do đó hệ thống tập tin có thể được di chuyển giữa
máy mà không cần biết nó được tạo ra trên máy nào.

Inode
------

Inode (nút chỉ mục) là một khái niệm cơ bản trong hệ thống tập tin ext2.
Mỗi đối tượng trong hệ thống tập tin được biểu diễn bằng một nút.  nút
cấu trúc chứa các con trỏ tới các khối hệ thống tập tin chứa
dữ liệu được giữ trong đối tượng và tất cả siêu dữ liệu về một đối tượng ngoại trừ
tên của nó.  Siêu dữ liệu về một đối tượng bao gồm các quyền, chủ sở hữu,
nhóm, cờ, kích thước, số khối được sử dụng, thời gian truy cập, thời gian thay đổi,
thời gian sửa đổi, thời gian xóa, số lượng liên kết, đoạn, phiên bản
(đối với NFS) và các thuộc tính mở rộng (EA) và/hoặc Danh sách điều khiển truy cập (ACL).

Có một số trường dành riêng hiện không được sử dụng trong inode
cấu trúc và một số bị quá tải.  Một trường được dành riêng cho
thư mục ACL nếu inode là thư mục và luân phiên cho 32 đầu
bit của kích thước tệp nếu inode là tệp thông thường (cho phép kích thước tệp
lớn hơn 2GB).  Trường dịch thuật không được sử dụng trong Linux nhưng được sử dụng
bởi HURD để tham chiếu inode của chương trình sẽ được sử dụng để
diễn giải đối tượng này.  Hầu hết các trường dành riêng còn lại đã được
đã sử dụng hết cho cả Linux và HURD cho các trường nhóm và chủ sở hữu lớn hơn,
HURD cũng có trường chế độ lớn hơn nên nó sử dụng một trường chế độ khác còn lại
các trường để lưu trữ nhiều bit hơn.

Có con trỏ tới 12 khối đầu tiên chứa dữ liệu của tệp
trong inode.  Có một con trỏ tới một khối gián tiếp (chứa
con trỏ tới tập hợp các khối tiếp theo), một con trỏ tới một giá trị gián tiếp kép
khối (chứa các con trỏ tới các khối gián tiếp) và một con trỏ tới một khối
khối gián tiếp trebly (chứa các con trỏ tới các khối gián tiếp kép).

Trường cờ chứa một số cờ dành riêng cho ext2 không được cung cấp
for bằng cờ chmod tiêu chuẩn.  Những cờ này có thể được liệt kê bằng lsattr
và thay đổi bằng lệnh chattr và cho phép hệ thống tệp cụ thể
hành vi trên cơ sở mỗi tập tin.  Có cờ để xóa an toàn,
không thể xóa, nén, cập nhật đồng bộ, không thay đổi, chỉ nối thêm,
các thư mục có thể kết xuất, không có thời gian, được lập chỉ mục và ghi nhật ký dữ liệu.  Không phải tất cả
trong số này vẫn chưa được hỗ trợ.

Thư mục
-----------

Thư mục là một đối tượng hệ thống tập tin và có một nút giống như một tập tin.
Nó là một tập tin có định dạng đặc biệt chứa các bản ghi liên kết
mỗi tên có một số inode.  Các bản sửa đổi sau này của hệ thống tập tin cũng
mã hóa loại đối tượng (tệp, thư mục, liên kết tượng trưng, ​​thiết bị, fifo,
socket) để tránh phải kiểm tra chính inode để biết thông tin này
(hỗ trợ tận dụng tính năng này chưa tồn tại trong
Glibc 2.2).

Mã phân bổ inode cố gắng gán các inode giống nhau
nhóm khối làm thư mục mà chúng được tạo lần đầu tiên.

Việc triển khai ext2 hiện tại sử dụng danh sách liên kết đơn để lưu trữ
tên tập tin trong thư mục; một cải tiến đang chờ xử lý sử dụng hàm băm của
tên tập tin để cho phép tra cứu mà không cần phải quét toàn bộ thư mục.

Việc triển khai hiện tại không bao giờ loại bỏ các khối thư mục trống một khi chúng
đã được phân bổ để chứa nhiều tập tin hơn.

Các tập tin đặc biệt
-------------

Liên kết tượng trưng cũng là đối tượng hệ thống tập tin có nút.  Họ xứng đáng
đề cập đặc biệt vì dữ liệu của chúng được lưu trữ trong inode
chính nó nếu liên kết tượng trưng dài dưới 60 byte.  Nó sử dụng các trường
thường được sử dụng để lưu trữ các con trỏ tới các khối dữ liệu.
Đây là một sự tối ưu hóa đáng giá vì nó tránh được việc phân bổ toàn bộ
khối cho liên kết tượng trưng và hầu hết các liên kết tượng trưng đều dài dưới 60 ký tự.

Ký tự và khối thiết bị đặc biệt không bao giờ có khối dữ liệu được gán cho
họ.  Thay vào đó, số thiết bị của chúng được lưu trữ trong inode, tái sử dụng lại
các trường sẽ được sử dụng để trỏ đến các khối dữ liệu.

Không gian dành riêng
--------------

Trong ext2 có cơ chế dự trữ một số khối nhất định
cho một người dùng cụ thể (thường là siêu người dùng).  Điều này nhằm mục đích
cho phép hệ thống tiếp tục hoạt động ngay cả khi người dùng không có đặc quyền
lấp đầy tất cả không gian có sẵn cho chúng (điều này độc lập với hệ thống tập tin
hạn ngạch).  Nó cũng giữ cho hệ thống tập tin không bị lấp đầy hoàn toàn.
giúp chống lại sự phân mảnh.

Kiểm tra hệ thống tập tin
----------------

Khi khởi động, hầu hết các hệ thống đều chạy kiểm tra tính nhất quán (e2fsck) trên
hệ thống tập tin.  Siêu khối của hệ thống tập tin ext2 chứa một số
các trường cho biết liệu fsck có thực sự nên chạy hay không (kể từ khi kiểm tra
hệ thống tập tin khi khởi động có thể mất nhiều thời gian nếu nó lớn).  fsck sẽ
chạy nếu hệ thống tập tin chưa được ngắt kết nối hoàn toàn, nếu giá trị gắn kết tối đa
số lượng đã bị vượt quá hoặc nếu thời gian tối đa giữa các lần kiểm tra đã vượt quá
vượt quá.

Khả năng tương thích tính năng
---------------------

Cơ chế tính năng tương thích được sử dụng trong ext2 rất phức tạp.
Nó cho phép các tính năng được thêm vào hệ thống tập tin một cách an toàn mà không cần
hy sinh khả năng tương thích một cách không cần thiết với các phiên bản cũ hơn của
mã hệ thống tập tin.  Cơ chế tương thích tính năng không được hỗ trợ bởi
phiên bản gốc 0 (EXT2_GOOD_OLD_REV) của ext2, nhưng đã được giới thiệu trong
sửa đổi 1. Có ba trường 32 bit, một trường dành cho các tính năng tương thích
(COMPAT), một dành cho các tính năng tương thích chỉ đọc (RO_COMPAT) và một dành cho
các tính năng không tương thích (INCOMPAT).

Các cờ tính năng này có ý nghĩa cụ thể đối với kernel như sau:

Cờ COMPAT cho biết rằng một tính năng có trong hệ thống tệp,
nhưng định dạng trên đĩa tương thích 100% với các định dạng trên đĩa cũ hơn, vì vậy
kernel không biết gì về tính năng này có thể đọc/ghi
hệ thống tập tin mà không có cơ hội làm hỏng hệ thống tập tin (hoặc thậm chí
làm cho nó không nhất quán).  Đây thực chất chỉ là một lá cờ có nội dung
"hệ thống tập tin này có một tính năng (ẩn)" mà kernel hoặc e2fsck có thể
muốn biết về (sẽ nói thêm về e2fsck và cờ tính năng sau).  Máy lẻ 3
Tính năng HAS_JOURNAL là cờ COMPAT vì tạp chí ext3 chỉ đơn giản là
một tệp thông thường có các khối dữ liệu trong đó để kernel không cần
chú ý đặc biệt đến nó nếu nó không hiểu cách ghi nhật ký ext3.

Cờ RO_COMPAT cho biết định dạng trên đĩa tương thích 100%
với các định dạng trên đĩa cũ hơn để đọc (tức là tính năng không thay đổi
định dạng hiển thị trên đĩa).  Tuy nhiên, một kernel cũ ghi vào một
hệ thống tập tin sẽ/có thể làm hỏng hệ thống tập tin, vì vậy điều này bị ngăn chặn. các
tính năng phổ biến nhất như vậy, SPARSE_SUPER, là tính năng RO_COMPAT vì
các nhóm thưa thớt cho phép các khối dữ liệu tệp trong đó bộ mô tả siêu khối/nhóm
các bản sao lưu đã từng tồn tại và ext2_free_blocks() từ chối giải phóng các khối này,
điều này sẽ dẫn đến bitmap không nhất quán.  Một hạt nhân cũ cũng sẽ
gặp lỗi nếu nó cố giải phóng một loạt khối vượt qua một nhóm
ranh giới, nhưng đây là bố cục hợp pháp trong hệ thống tệp SPARSE_SUPER.

Cờ INCOMPAT cho biết định dạng trên đĩa đã thay đổi trong một số
theo cách khiến các hạt nhân cũ không thể đọc được, hoặc nói cách khác là
gây ra sự cố nếu hạt nhân cũ cố gắng gắn kết nó.  FILETYPE là một
Cờ INCOMPAT vì các hạt nhân cũ hơn sẽ cho rằng tên tệp dài hơn
hơn 256 ký tự, điều này sẽ dẫn đến danh sách thư mục bị hỏng.
Cờ COMPRESSION là cờ INCOMPAT rõ ràng - nếu kernel
không hiểu nén, bạn sẽ lấy lại rác từ
read() thay vì nó tự động giải nén dữ liệu của bạn.  Máy lẻ 3
Cần có cờ RECOVER để ngăn hạt nhân không hiểu được
ext3 khỏi việc gắn hệ thống tập tin mà không cần phát lại nhật ký.

Đối với e2fsck, cần phải nghiêm ngặt hơn trong việc xử lý những vấn đề này
cờ hơn kernel.  Nếu nó không hiểu ANY của COMPAT,
Cờ RO_COMPAT hoặc INCOMPAT nó sẽ từ chối kiểm tra hệ thống tập tin,
bởi vì nó không có cách nào để xác minh liệu một tính năng nhất định có hợp lệ hay không
hay không.  Cho phép e2fsck thành công trên hệ thống tệp không xác định
tính năng này là một cảm giác an toàn sai lầm cho người dùng.  Từ chối kiểm tra
một hệ thống tập tin với các tính năng chưa biết là một động lực tốt để người dùng
cập nhật lên e2fsck mới nhất.  Điều này cũng có nghĩa là bất cứ ai thêm tính năng
flags sang ext2 cũng cần cập nhật e2fsck để xác minh các tính năng này.

Siêu dữ liệu
--------

Người ta thường tuyên bố rằng việc triển khai văn bản ext2
siêu dữ liệu không đồng bộ nhanh hơn siêu dữ liệu đồng bộ ffs
chương trình nhưng kém tin cậy hơn.  Cả hai phương pháp đều có thể giải quyết được như nhau bởi
các chương trình fsck tương ứng.

Nếu bạn đặc biệt hoang tưởng, có 3 cách tạo siêu dữ liệu
ghi đồng bộ trên ext2:

- trên mỗi tệp nếu bạn có nguồn chương trình: sử dụng cờ O_SYNC để mở()
- mỗi tệp nếu bạn không có nguồn: sử dụng "chattr +S" trên tệp
- trên mỗi hệ thống tập tin: thêm tùy chọn "đồng bộ hóa" để gắn kết (hoặc trong/etc/fstab)

cái đầu tiên và cái cuối cùng không cụ thể cho ext2 nhưng buộc siêu dữ liệu phải
được viết đồng bộ.  Xem thêm Nhật ký bên dưới.

Hạn chế
-----------

Có nhiều giới hạn khác nhau được áp đặt bởi cách bố trí trên đĩa của ext2.  Khác
các giới hạn được áp đặt bởi việc triển khai mã hạt nhân hiện tại.
Nhiều giới hạn được xác định tại thời điểm hệ thống tập tin lần đầu tiên
được tạo và phụ thuộc vào kích thước khối được chọn.  Tỷ lệ của inode với
khối dữ liệu được cố định tại thời điểm tạo hệ thống tập tin, vì vậy cách duy nhất để
tăng số lượng nút là tăng kích thước của hệ thống tập tin.
Hiện tại không có công cụ nào có thể thay đổi tỷ lệ inode thành khối.

Hầu hết các giới hạn này có thể được khắc phục bằng những thay đổi nhỏ trong ổ đĩa.
định dạng và sử dụng cờ tương thích để báo hiệu sự thay đổi định dạng (tại
chi phí của một số khả năng tương thích).

============================ ======= ======= =========
Kích thước khối hệ thống tập tin 1kB 2kB 4kB 8kB
============================ ======= ======= =========
Giới hạn kích thước tệp 16GB 256GB 2048GB 2048GB
Giới hạn kích thước hệ thống tập tin 2047GB 8192GB 16384GB 32768GB
============================ ======= ======= =========

Có giới hạn 2,4 kernel là 2048GB cho một thiết bị khối đơn, vì vậy không
hệ thống tập tin lớn hơn có thể được tạo vào lúc này.  Ngoài ra còn có
giới hạn trên của kích thước khối được áp đặt bởi kích thước trang của hạt nhân,
vì vậy khối 8kB chỉ được phép trên hệ thống Alpha (và các kiến trúc khác
hỗ trợ các trang lớn hơn).

Có giới hạn trên là 32000 thư mục con trong một thư mục.

Có giới hạn trên "mềm" là khoảng 10-15k tệp trong một thư mục
với việc triển khai thư mục danh sách liên kết tuyến tính hiện tại.  Giới hạn này
bắt nguồn từ các vấn đề về hiệu suất khi tạo và xóa (và cả
tìm kiếm) các tập tin trong các thư mục lớn như vậy.  Sử dụng chỉ mục thư mục băm
(đang được phát triển) cho phép các tệp 100k-1M+ trong một thư mục mà không cần
vấn đề về hiệu suất (mặc dù kích thước RAM trở thành một vấn đề tại thời điểm này).

Giới hạn trên tuyệt đối (vô nghĩa) của các tệp trong một thư mục
(do kích thước tệp áp đặt, giới hạn thực tế rõ ràng là ít hơn nhiều)
là hơn 130 nghìn tỷ tập tin.  Nó sẽ cao hơn ngoại trừ việc không có
đủ tên 4 ký tự để tạo thành các mục thư mục duy nhất, vì vậy chúng
phải có tên tệp 8 ký tự, thậm chí sau đó chúng tôi khá gần với
hết tên tập tin duy nhất.

Nhật ký
----------

Stephen đã phát triển phần mở rộng ghi nhật ký cho mã ext2
Tweedie.  Nó tránh được nguy cơ hỏng siêu dữ liệu và sự cần thiết phải
đợi e2fsck hoàn thành sau sự cố mà không yêu cầu thay đổi
vào bố cục ext2 trên đĩa.  Tóm lại, tạp chí là một tờ báo thường xuyên
tệp lưu trữ toàn bộ khối siêu dữ liệu (và dữ liệu tùy chọn) có
đã được sửa đổi trước khi ghi chúng vào hệ thống tập tin.  Điều này có nghĩa
có thể thêm nhật ký vào hệ thống tệp ext2 hiện có mà không cần
nhu cầu chuyển đổi dữ liệu.

Khi thay đổi hệ thống tập tin (ví dụ: một tập tin được đổi tên), chúng sẽ được lưu trữ trong
một giao dịch trên nhật ký và có thể hoàn thành hoặc không đầy đủ tại
thời điểm xảy ra sự cố.  Nếu giao dịch hoàn tất tại thời điểm xảy ra sự cố
(hoặc trong trường hợp bình thường hệ thống không gặp sự cố), thì bất kỳ khối nào
trong giao dịch đó được đảm bảo thể hiện trạng thái hệ thống tệp hợp lệ,
và được sao chép vào hệ thống tập tin.  Nếu một giao dịch không hoàn thành tại
thời điểm xảy ra sự cố thì không có gì đảm bảo tính nhất quán cho
các khối trong giao dịch đó nên chúng bị loại bỏ (có nghĩa là bất kỳ khối nào
những thay đổi về hệ thống tập tin mà chúng đại diện cũng bị mất).
Kiểm tra Documentation/filesystems/ext4/ nếu bạn muốn đọc thêm về
ext4 và ghi nhật ký.

Tài liệu tham khảo
==========

============================================================================
Tệp nguồn kernel:/usr/src/linux/fs/ext2/
e2fsprogs (e2fsck) ZZ0000ZZ
Thiết kế & Thi công ZZ0001ZZ
Ghi nhật ký (ext3) ftp://ftp.uk.linux.org/pub/linux/sct/fs/jfs/
Thay đổi kích thước hệ thống tập tin ZZ0002ZZ
Nén [1]_ ZZ0003ZZ
============================================================================

Triển khai cho:

========================================================================================
Windows 95/98/NT/2000 ZZ0000ZZ
Windows 95 [1]_ ZZ0001ZZ
Máy khách DOS [1]_ ftp://metalab.unc.edu/pub/Linux/system/filesystems/ext2/
OS/2 [2]_ ftp://metalab.unc.edu/pub/Linux/system/filesystems/ext2/
Máy khách hệ điều hành RISC ZZ0002ZZ
========================================================================================

.. [1] no longer actively developed/supported (as of Apr 2001)
.. [2] no longer actively developed/supported (as of Mar 2009)