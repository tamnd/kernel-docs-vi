.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/dlmfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=====
DLMFS
=====

Giao diện không gian người dùng DLM tối thiểu được triển khai thông qua tệp ảo
hệ thống.

dlmfs được xây dựng bằng OCFS2 vì nó yêu cầu hầu hết cơ sở hạ tầng.

:Trang web dự án: ZZ0000ZZ
:Trang web công cụ: ZZ0001ZZ
:OCFS2 danh sách gửi thư: ZZ0002ZZ

Tất cả các mã bản quyền 2005 Oracle trừ khi có ghi chú khác.

Tín dụng
========

Một số mã lấy từ ramfs Copyright ZZ0000ZZ 2000 Linus Torvalds
và Tập đoàn Transmeta.

Đánh dấu Fasheh <mark.fasheh@oracle.com>

Hãy cẩn thận
============
- Hiện tại nó chỉ hoạt động với OCFS2 DLM, mặc dù hỗ trợ cho các thiết bị khác
  Việc triển khai DLM không phải là vấn đề lớn.

Tùy chọn gắn kết
================
Không có

Cách sử dụng
============

Nếu bạn chỉ quan tâm đến OCFS2, vui lòng xem ocfs2.rst. các
phần còn lại của tài liệu này sẽ hướng tới những người muốn sử dụng
dlmfs để dễ cài đặt và dễ sử dụng khóa theo cụm
không gian người dùng.

Cài đặt
=======

dlmfs yêu cầu cơ sở hạ tầng cụm OCFS2 ở
nơi. Vui lòng tải xuống ocfs2-tools từ url trên và định cấu hình
cụm.

Bạn sẽ muốn bắt đầu đo nhịp tim trên một âm lượng mà tất cả các nút trong
không gian khóa của bạn có thể truy cập. Cách dễ nhất để làm điều này là thông qua
ocfs2_hb_ctl (được phân phối với công cụ ocfs2). Lúc này nó đòi hỏi
rằng hệ thống tệp OCFS2 phải được cài đặt để nó có thể tự động
tìm khu vực nhịp tim của nó, mặc dù cuối cùng nó sẽ hỗ trợ nhịp tim
chống lại các đĩa thô.

Vui lòng xem các trang hướng dẫn ocfs2_hb_ctl và mkfs.ocfs2 được phân phối
với công cụ ocfs2.

Khi bạn đã sẵn sàng, bạn có thể dễ dàng tạo 'tên miền' khóa DLM /
bị phá hủy và các khóa bên trong chúng được truy cập.

Khóa
=======

Người dùng có thể truy cập dlmfs thông qua các cuộc gọi hệ thống tệp tiêu chuẩn hoặc họ có thể sử dụng
'libo2dlm' (được phân phối với ocfs2-tools) tóm tắt tệp
hệ thống gọi và trình bày một api khóa truyền thống hơn.

dlmfs tự động xử lý khóa bộ nhớ đệm cho người dùng, vì vậy khóa
yêu cầu khóa đã có được sẽ không tạo ra DLM khác
gọi. Các chương trình không gian người dùng được cho là xử lý các vấn đề cục bộ của riêng chúng.
khóa.

Hai cấp độ khóa được hỗ trợ - Đọc chia sẻ và Độc quyền.
Hoạt động Trylock cũng được hỗ trợ.

Để biết thông tin về giao diện libo2dlm, vui lòng xem o2dlm.h,
được phân phối bằng công cụ ocfs2.

Các khối giá trị khóa có thể được đọc và ghi vào tài nguyên thông qua read(2)
và viết (2) dựa vào fd thu được thông qua lệnh gọi open(2) của bạn. các
Độ dài LVB tối đa hiện được hỗ trợ là 64 byte (mặc dù đó là
Giới hạn OCFS2 DLM). Thông qua cơ chế này, người dùng dlmfs có thể chia sẻ
lượng nhỏ dữ liệu giữa các nút của chúng.

mkdir(2) báo hiệu dlmfs tham gia một miền (sẽ có cùng tên
làm thư mục kết quả)

rmdir(2) báo hiệu dlmfs rời khỏi miền

Các khóa cho một miền nhất định được thể hiện bằng các nút thông thường bên trong
thư mục tên miền.  Việc khóa chúng được thực hiện thông qua hệ thống open(2)
gọi.

Cuộc gọi open(2) sẽ không quay lại cho đến khi khóa của bạn được cấp hoặc
đã xảy ra lỗi, trừ khi nó được hướng dẫn thực hiện khóa thử
hoạt động. Nếu khóa thành công, bạn sẽ nhận được fd.

open(2) bằng O_CREAT để đảm bảo inode tài nguyên được tạo - dlmfs thực hiện
không tự động tạo nút cho tài nguyên khóa hiện có.

==========================================
Loại yêu cầu khóa cờ mở
==========================================
O_RDONLY Đọc chia sẻ
O_RDWR độc quyền
==========================================


==========================================
Cờ mở dẫn đến hành vi khóa
==========================================
O_NONBLOCK Hoạt động thử khóa
==========================================

Bạn phải cung cấp chính xác một trong số O_RDONLY hoặc O_RDWR.

Nếu O_NONBLOCK cũng được cung cấp và thao tác khóa thử hợp lệ nhưng
không thể khóa tài nguyên thì open(2) sẽ trả về ETXTBUSY.

close(2) bỏ khóa được liên kết với fd của bạn.

Các chế độ được chuyển tới mkdir(2) hoặc open(2) được tuân thủ cục bộ. Chown là
cũng được hỗ trợ tại địa phương. Điều này có nghĩa là bạn có thể sử dụng chúng để hạn chế
chỉ truy cập vào tài nguyên thông qua dlmfs trên nút cục bộ của bạn.

Tài nguyên LVB có thể được đọc từ fd ở chế độ Đọc chia sẻ hoặc
Các chế độ độc quyền thông qua lệnh gọi hệ thống read(2). Nó có thể được viết thông qua
write(2) chỉ khi mở ở chế độ Độc quyền.

Sau khi được viết, LVB sẽ hiển thị với các nút khác có được quyền Đọc
Chỉ khóa tài nguyên ở cấp độ cao hơn hoặc cao hơn.

Xem thêm
========
ZZ0000ZZ

Để biết thêm thông tin về VMS khóa phân tán API.