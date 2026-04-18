.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/qnx6.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Hệ thống tập tin QNX6
===================

Qnx6fs được sử dụng bởi các phiên bản hệ điều hành QNX mới hơn. (ví dụ neutrino)
Nó được giới thiệu trong QNX 6.4.0 và được sử dụng mặc định kể từ 6.4.1.

Lựa chọn
======

mmi_fs Hệ thống tập tin gắn kết như được sử dụng chẳng hạn bởi hệ thống Audi MMI 3G

Đặc điểm kỹ thuật
=============

qnx6fs chia sẻ nhiều thuộc tính với hệ thống tệp Unix truyền thống. Nó có
khái niệm về khối, inode và thư mục.

Trên QNX, có thể tạo các hệ thống tập tin qnx6 endian nhỏ và big endian.
Tính năng này cho phép tạo và sử dụng fs endianness khác
cho mục tiêu (QNX được sử dụng trên khá nhiều nền tảng hệ thống nhúng)
chạy trên một endianness khác.

Trình điều khiển Linux xử lý độ bền một cách minh bạch. (LE và BE)

Khối
------

Không gian trong thiết bị hoặc tệp được chia thành các khối. Đây là một cố định
kích thước 512, 1024, 2048 hoặc 4096, được quyết định khi hệ thống tập tin được
được tạo ra.

Con trỏ khối là 32 bit, vì vậy không gian tối đa có thể được giải quyết là
2^32 * 4096 byte hoặc 16TB

Các siêu khối
---------------

Siêu khối chứa tất cả thông tin chung về hệ thống tập tin.
Mỗi qnx6fs có hai siêu khối, mỗi siêu khối có số sê-ri 64 bit.
Số sê-ri đó được sử dụng để xác định siêu khối "hoạt động".
Ở chế độ ghi với ảnh chụp nhanh mới (sau mỗi lần ghi đồng bộ),
nối tiếp của siêu khối chính mới được tăng lên (serial siêu khối cũ + 1)

Vì vậy, về cơ bản, chức năng chụp nhanh được thực hiện bằng một bản tóm tắt nguyên tử
cập nhật số serial. Trước khi cập nhật serial đó, tất cả các sửa đổi
được thực hiện bằng cách sao chép tất cả các khối đã sửa đổi trong yêu cầu ghi cụ thể đó
(hoặc giai đoạn) và xây dựng cấu trúc hệ thống tập tin mới (ổn định) theo
siêu khối không hoạt động.

Mỗi siêu khối chứa một tập hợp các nút gốc cho hệ thống tập tin khác nhau
các bộ phận. (Inode, Bitmap và tên tệp dài)
Mỗi nút gốc này chứa thông tin như tổng kích thước của
dữ liệu và các mức địa chỉ trong cây cụ thể đó.
Nếu giá trị cấp độ là 0, mỗi khối có thể được xử lý tối đa 16 khối trực tiếp.
nút.

Cấp 1 bổ sung thêm một cấp độ địa chỉ gián tiếp trong đó mỗi cấp độ địa chỉ gián tiếp
khối địa chỉ giữ tối đa kích thước khối/4 byte con trỏ tới khối dữ liệu.
Cấp độ 2 bổ sung thêm một cấp độ khối địa chỉ gián tiếp (vì vậy, đã có
đến 16 * 256 * 256 = 1048576 khối có thể được xử lý bằng cây như vậy).

Con trỏ khối không sử dụng luôn được đặt thành ~0 - bất kể nút gốc,
khối hoặc inode địa chỉ gián tiếp.

Lá dữ liệu luôn ở mức thấp nhất. Vì vậy không có dữ liệu nào được lưu trữ ở phía trên
cấp độ cây.

Superblock đầu tiên có kích thước 0x2000. (0x2000 là kích thước bootblock)
Siêu khối đầu tiên của Audi MMI 3G bắt đầu trực tiếp ở byte 0.

Vị trí siêu khối thứ hai có thể được tính từ siêu khối
thông tin (tổng số khối hệ thống tập tin) hoặc bằng cách lấy mức cao nhất
địa chỉ thiết bị, xóa 3 byte cuối cùng rồi trừ 0x1000 từ
địa chỉ đó.

0x1000 là kích thước dành riêng cho mỗi siêu khối - bất kể
kích thước khối của hệ thống tập tin.

Inode
------

Mỗi đối tượng trong hệ thống tập tin được biểu diễn bằng một nút. (nút chỉ mục)
Cấu trúc inode chứa các con trỏ tới các khối hệ thống tập tin chứa
dữ liệu được lưu giữ trong đối tượng và tất cả siêu dữ liệu về một đối tượng ngoại trừ
tên dài của nó. (tên tệp dài hơn 27 ký tự)
Siêu dữ liệu về một đối tượng bao gồm các quyền, chủ sở hữu, nhóm, cờ,
kích thước, số khối được sử dụng, thời gian truy cập, thời gian thay đổi và thời gian sửa đổi.

Trường chế độ đối tượng có định dạng POSIX. (điều này làm cho mọi việc dễ dàng hơn)

Ngoài ra còn có các con trỏ tới 16 khối đầu tiên, nếu dữ liệu đối tượng có thể được
được giải quyết bằng 16 khối trực tiếp.

Đối với hơn 16 khối, việc đánh địa chỉ gián tiếp dưới dạng cây khác được thực hiện
đã sử dụng. (sơ đồ giống với sơ đồ được sử dụng cho các nút gốc siêu khối)

Kích thước tập tin được lưu trữ 64bit. Việc đếm inode bắt đầu bằng 1. (trong khi dài
các nút tên tệp bắt đầu bằng 0)

Thư mục
-----------

Thư mục là một đối tượng hệ thống tập tin và có một nút giống như một tập tin.
Nó là một tập tin có định dạng đặc biệt chứa các bản ghi liên kết từng
tên có số inode.

'.' số inode trỏ tới thư mục inode

'..' số inode trỏ đến inode thư mục mẹ

Mỗi bản ghi tên tệp cũng có trường độ dài tên tệp.

Một trường hợp đặc biệt là tên tệp dài hoặc tên thư mục con.

Chúng đã đặt trường độ dài tên tệp là 0xff trong thư mục tương ứng
bản ghi cộng với số inode tệp dài cũng được lưu trong bản ghi đó.

Với số inode longfilename đó, cây longfilename có thể được duyệt
bắt đầu với các con trỏ nút gốc superblock longfilename.

Các tập tin đặc biệt
-------------

Liên kết tượng trưng cũng là đối tượng hệ thống tập tin có nút. Họ đã có một thông tin cụ thể
bit trong trường chế độ inode xác định chúng là liên kết tượng trưng.

Con trỏ inode của tệp mục nhập thư mục trỏ đến inode của tệp đích.

Liên kết cứng có một nút, một mục nhập thư mục, nhưng có một bộ bit chế độ cụ thể,
không có con trỏ khối và bản ghi tệp thư mục trỏ đến tệp đích
inode.

Các thiết bị đặc biệt về ký tự và khối không tồn tại trong QNX dưới dạng các tệp đó
được xử lý bởi hạt nhân/trình điều khiển QNX và được tạo trong /dev độc lập với
hệ thống tập tin cơ bản.

Tên tệp dài
--------------

Tên tệp dài được lưu trữ trong một cây địa chỉ riêng. Điểm nhìn chằm chằm
là nút gốc longfilename trong siêu khối đang hoạt động.

Mỗi khối dữ liệu (lá cây) chứa một tên tệp dài. Tên tập tin đó là
giới hạn ở 510 byte. Hai byte bắt đầu đầu tiên được sử dụng làm trường độ dài
cho tên tập tin thực tế.

Nếu cấu trúc đó phù hợp với tất cả các kích thước khối được phép thì rõ ràng tại sao lại có
là giới hạn 510 byte cho tên tệp thực tế được lưu trữ.

Bản đồ bit
------

Bitmap phân bổ hệ thống tập tin qnx6fs được lưu trữ trong cây dưới bitmap
nút gốc trong siêu khối và mỗi bit trong bitmap đại diện cho một
khối hệ thống tập tin.

Khối đầu tiên là khối 0, bắt đầu 0x1000 sau khi bắt đầu siêu khối.
Vì vậy, đối với một qnx6fs bình thường 0x3000 (bootblock + superblock) là vật lý
địa chỉ tại khối 0.

Các bit ở cuối khối bitmap cuối cùng được đặt thành 1, nếu thiết bị
nhỏ hơn không gian địa chỉ trong bitmap.

Khu vực hệ thống bitmap
------------------

Bản thân bitmap được chia thành ba phần.

Đầu tiên là khu vực hệ thống, được chia thành hai nửa.

Sau đó là không gian người dùng.

Yêu cầu về một vùng hệ thống được phân bổ trước tĩnh, cố định xuất phát từ cách thức
qnx6fs xử lý việc ghi.

Mỗi siêu khối có một nửa diện tích hệ thống riêng. Vậy siêu khối #1
luôn sử dụng các khối ở nửa dưới trong khi siêu khối #2 chỉ ghi vào
các khối được biểu thị bằng các bit khu vực hệ thống bitmap nửa trên.

Khối bitmap, khối Inode và khối địa chỉ gián tiếp cho hai khối đó
cấu trúc cây được coi là khối hệ thống.

Lý do đằng sau đó là yêu cầu ghi có thể hoạt động trên một ảnh chụp nhanh mới
(khu vực hệ thống của siêu khối không hoạt động - tương ứng với siêu khối có số sê-ri thấp hơn) trong khi
đồng thời vẫn có cấu trúc hệ thống tập tin ổn định hoàn chỉnh trong
nửa còn lại của khu vực hệ thống.

Khi kết thúc quá trình ghi (ghi đồng bộ hoàn tất, bước nhảy đồng bộ hóa tối đa
thời gian hoặc yêu cầu đồng bộ hóa hệ thống tập tin), nối tiếp các phiên bản không hoạt động trước đó
siêu khối về mặt nguyên tử được tăng lên và fs chuyển sang đó - sau đó
tuyên bố ổn định - superblock.

Đối với tất cả dữ liệu ngoài vùng hệ thống, các khối chỉ được sao chép trong khi ghi.