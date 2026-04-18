.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-init.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Tạo sớm các thiết bị được ánh xạ
================================

Có thể định cấu hình thiết bị ánh xạ thiết bị để hoạt động như thiết bị gốc cho
hệ thống của bạn theo hai cách.

Đầu tiên là xây dựng một đĩa ram ban đầu để khởi động với không gian người dùng tối thiểu
để định cấu hình thiết bị, sau đó chuyển Pivot_root(8) vào thiết bị.

Thứ hai là tạo một hoặc nhiều trình ánh xạ thiết bị bằng tham số mô-đun
"dm-mod.create=" thông qua đối số dòng lệnh khởi động kernel.

Định dạng được chỉ định dưới dạng một chuỗi dữ liệu được phân tách bằng dấu phẩy và tùy chọn
dấu chấm phẩy, trong đó:

- dấu phẩy được sử dụng để phân tách các trường như tên, uuid, cờ và bảng
   (chỉ định một thiết bị)
 - dấu chấm phẩy dùng để phân cách các thiết bị.

Vì vậy, định dạng sẽ trông như thế này::

dm-mod.create=<name>,<uuid>,<minor>,<flags>,<table>[,<table>+][;<name>,<uuid>,<minor>,<flags>,<table>[,<table>+]+]

Ở đâu::

<name> ::= Tên thiết bị.
	<uuid> ::= xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | ""
	<minor> ::= Số thứ của thiết bị | ""
	<flags> ::= "ro" | "rw"
	<bảng> ::= <start_sector> <num_sector> <target_type> <target_args>
	<target_type> ::= "verity" ZZ0000ZZ ... (xem danh sách bên dưới)

Dòng dm phải tương đương với dòng được sử dụng bởi công cụ dmsetup với
Đối số ZZ0000ZZ.

Các loại mục tiêu
============

Không phải tất cả các loại mục tiêu đều có sẵn vì có những rủi ro nghiêm trọng khi cho phép
kích hoạt một số mục tiêu DM nhất định mà không cần sử dụng công cụ không gian người dùng để kiểm tra trước
tính hợp lệ của siêu dữ liệu liên quan.

====================================================================================
ZZ0000ZZ bị hạn chế, không gian người dùng phải xác minh thiết bị bộ đệm
ZZ0001ZZ được phép
ZZ0002ZZ được phép
ZZ0003ZZ bị hạn chế, không gian người dùng phải xác minh thiết bị siêu dữ liệu
ZZ0004ZZ bị ràng buộc, dành cho thử nghiệm
ZZ0005ZZ được phép
ZZ0006ZZ bị hạn chế, không gian người dùng phải xác minh thiết bị siêu dữ liệu
ZZ0007ZZ bị hạn chế, không gian người dùng phải xác minh thiết bị chính/gương
ZZ0008ZZ bị hạn chế, không gian người dùng phải xác minh thiết bị siêu dữ liệu
ZZ0009ZZ bị hạn chế, không gian người dùng phải xác minh thiết bị src/dst
ZZ0010ZZ được phép
ZZ0011ZZ bị hạn chế, không gian người dùng phải xác minh thiết bị src/dst
ZZ0012ZZ được phép
ZZ0013ZZ bị ràng buộc, không gian người dùng phải xác minh đường dẫn nhà phát triển
ZZ0014ZZ bị ràng buộc, yêu cầu tin nhắn mục tiêu dm từ không gian người dùng
ZZ0015ZZ bị ràng buộc, yêu cầu tin nhắn mục tiêu dm từ không gian người dùng
ZZ0016ZZ được phép
ZZ0017ZZ bị hạn chế, không gian người dùng phải xác minh thiết bị bộ đệm
ZZ0018ZZ bị ràng buộc, không dành cho rootfs
====================================================================================

Nếu mục tiêu không được liệt kê ở trên, nó sẽ bị hạn chế theo mặc định (không được kiểm tra).

Ví dụ
========
Một ví dụ về khởi động vào một mảng tuyến tính được tạo thành từ khối linux ở chế độ người dùng
thiết bị::

dm-mod.create="lroot,,,rw, 0 4096 tuyến tính 98:16 0, 4096 4096 tuyến tính 98:32 0" root=/dev/dm-0

Điều này sẽ khởi động tới mục tiêu tuyến tính rw dm gồm 8192 cung được chia thành hai khối
các thiết bị được xác định bởi số chính: số phụ của chúng.  Sau khi khởi động xong udev sẽ đổi tên
mục tiêu này tới /dev/mapper/lroot (tùy theo quy tắc). Không có uuid nào được chỉ định.

Một ví dụ về nhiều trình ánh xạ thiết bị, với nội dung dm-mod.create="..."
được hiển thị ở đây chia thành nhiều dòng để dễ đọc ::

dm-tuyến tính,,1,rw,
    0 32768 tuyến tính 8:1 0,
    32768 1024000 tuyến tính 8:2 0;
  dm-verity,,3,ro,
    0 1638400 xác thực 1/dev/sdc1/dev/sdc2 4096 4096 204800 1 sha256
    ac87db56303c9c1da433d7209b5a6ef3e4779df141200cbd7c157dcb8dd89c42
    5ebfe87f7df3235b80a117ebc4078e44f55045487ad4a96581d1adb564615b51

Các ví dụ khác (mỗi mục tiêu):

"mật mã"::

dm-crypt,,8,ro,
    0 1048576 mật mã aes-xts-plain64
    em yêu em yêu em yêu em yêu em yêu em yêu em yêu em yêu em yêu em yêu em yêu 0
    /dev/sda 0 1 allow_discards

"trì hoãn"::

dm-delay,,4,ro,0 409600 độ trễ /dev/sda1 0 500

"tuyến tính"::

dm-tuyến tính,,,rw,
    0 32768 tuyến tính/dev/sda1 0,
    32768 1024000 tuyến tính/dev/sda2 0,
    1056768 204800 tuyến tính/dev/sda3 0,
    1261568 512000 tuyến tính/dev/sda4 0

"ảnh chụp nhanh"::

dm-snap-orig,,4,ro,0 409600 snapshot-origin 8:2

"sọc"::

dm-sọc,,4,ro,0 1638400 sọc 4 4096
  /dev/sda1 0 /dev/sda2 0 /dev/sda3 0 /dev/sda4 0

"sự thật"::

dm-verity,,4,ro,
    0 1638400 sự thật 1 8:1 8:2 4096 4096 204800 1 sha256
    fb1a5a0f00deb908d8b53cb270858975e76cf64105d412ce764225d53b8f3cfd
    51934789604d1b92399c52e7cb149d1b3a1b74bbbcb103b2a0aaacbed5c08584

Đối với các thiết lập sử dụng trình ánh xạ thiết bị trên đầu khối được thăm dò không đồng bộ
các thiết bị (MMC, USB, ..), có thể cần phải báo cho dm-init
rõ ràng là đợi chúng sẵn sàng trước khi thiết lập
bảng ánh xạ thiết bị. Điều này có thể được thực hiện với "dm-mod.waitfor="
tham số mô-đun, lấy danh sách các thiết bị để chờ ::

dm-mod.waitfor=<device1>[,..,<deviceN>]
