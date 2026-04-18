.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/page_table_check.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Kiểm tra bảng trang
================

Giới thiệu
============

Kiểm tra bảng trang cho phép làm cứng kernel bằng cách đảm bảo rằng một số loại
sự hỏng bộ nhớ được ngăn chặn.

Kiểm tra bảng trang thực hiện xác minh bổ sung tại thời điểm các trang mới trở thành
có thể truy cập từ không gian người dùng bằng cách lấy các mục trong bảng trang của họ (PTEs PMDs
v.v.) được thêm vào bảng.

Trong trường hợp hầu hết các lỗi được phát hiện đều có nghĩa là kernel bị hỏng. Có một cái nhỏ
hiệu suất và chi phí bộ nhớ liên quan đến việc kiểm tra bảng trang. Vì vậy,
nó bị tắt theo mặc định, nhưng có thể được bật tùy chọn trên các hệ thống có
độ cứng thêm lớn hơn chi phí hiệu suất. Ngoài ra, vì việc kiểm tra bảng trang
đồng bộ, nó có thể giúp gỡ lỗi các vấn đề hỏng bộ nhớ bản đồ kép,
bằng cách làm hỏng kernel tại thời điểm ánh xạ sai xảy ra thay vì sau đó
thường xảy ra trường hợp lỗi hỏng bộ nhớ.

Nó cũng có thể được sử dụng để thực hiện kiểm tra mục nhập bảng trang qua các cờ khác nhau, kết xuất
cảnh báo khi phát hiện sự kết hợp bất hợp pháp của các cờ nhập cảnh.  Hiện tại,
userfaultfd là người dùng duy nhất như vậy để kiểm tra bit wr-protect chống lại
bất kỳ cờ có thể ghi được.  Sự kết hợp cờ bất hợp pháp sẽ không trực tiếp gây ra dữ liệu
hỏng ngay lập tức trong trường hợp này, nhưng điều đó sẽ khiến dữ liệu chỉ đọc bị
có thể ghi được, dẫn đến bị hỏng khi nội dung trang được sửa đổi sau đó.

Logic phát hiện ánh xạ kép
==============================

+-------------------+-------------------+-------------------+-------------------+
ZZ0000ZZ Ánh xạ mới Quy tắc ZZ0001ZZ |
+====================+======================================================================================================================================
ZZ0002ZZ Ẩn danh ZZ0003ZZ Cho phép |
+-------------------+-------------------+-------------------+-------------------+
ZZ0004ZZ Ẩn danh ZZ0005ZZ Cấm |
+-------------------+-------------------+-------------------+-------------------+
ZZ0006ZZ Được đặt tên là ZZ0007ZZ Cấm |
+-------------------+-------------------+-------------------+-------------------+
ZZ0008ZZ Ẩn danh ZZ0009ZZ Cấm |
+-------------------+-------------------+-------------------+-------------------+
ZZ0010ZZ Đặt tên ZZ0011ZZ Cho phép |
+-------------------+-------------------+-------------------+-------------------+

Bật kiểm tra bảng trang
=========================

Xây dựng hạt nhân với:

- PAGE_TABLE_CHECK=y
  Lưu ý, nó chỉ có thể được kích hoạt trên các nền tảng có ARCH_SUPPORTS_PAGE_TABLE_CHECK
  có sẵn.

- Khởi động với tham số kernel 'page_table_check=on'.

Tùy chọn, xây dựng kernel với PAGE_TABLE_CHECK_ENFORCED để có trang
hỗ trợ bảng mà không cần thêm tham số kernel.

Ghi chú thực hiện
====================

Chúng tôi đặc biệt quyết định không sử dụng thông tin VMA để tránh dựa vào
Trạng thái MM (ngoại trừ thông tin "trang cấu trúc" hạn chế). Việc kiểm tra bảng trang là một
tách biệt với máy trạng thái Linux-MM xác minh rằng người dùng có thể truy cập được
các trang không được chia sẻ sai.

PAGE_TABLE_CHECK phụ thuộc vào EXCLUSIVE_SYSTEM_RAM. Lý do là vì không có
EXCLUSIVE_SYSTEM_RAM, người dùng được phép ánh xạ bộ nhớ vật lý tùy ý
các vùng vào không gian người dùng thông qua /dev/mem. Đồng thời, các trang có thể thay đổi
thuộc tính của chúng (ví dụ: từ các trang ẩn danh đến các trang được đặt tên) trong khi chúng
vẫn được ánh xạ trong không gian người dùng, dẫn đến "tham nhũng" bị phát hiện bởi
kiểm tra bảng trang.

Ngay cả với EXCLUSIVE_SYSTEM_RAM, các trang I/O vẫn có thể được phép ánh xạ thông qua
/dev/mem. Tuy nhiên, những trang này luôn được coi là trang được đặt tên nên chúng
sẽ không phá vỡ logic được sử dụng trong kiểm tra bảng trang.