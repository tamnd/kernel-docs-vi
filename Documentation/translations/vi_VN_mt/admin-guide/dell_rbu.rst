.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/dell_rbu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================
Trình điều khiển cập nhật Dell Remote BIOS (dell_rbu)
=========================================

Mục đích
=======

Tài liệu hướng dẫn sử dụng driver Dell Remote BIOS Update
để cập nhật hình ảnh BIOS trên máy chủ và máy tính để bàn Dell.

Phạm vi
=====

Tài liệu này chỉ thảo luận về chức năng của trình điều khiển rbu.
Nó không bao gồm sự hỗ trợ cần thiết từ các ứng dụng để cho phép BIOS
tự cập nhật với hình ảnh được tải xuống bộ nhớ.

Tổng quan
========

Trình điều khiển này hoạt động với Dell OpenManager hoặc Gói cập nhật Dell để cập nhật
BIOS trên máy chủ Dell (bắt đầu từ máy chủ được bán từ năm 1999), máy tính để bàn
và sổ ghi chép (bắt đầu từ những cuốn được bán năm 2005).

Vui lòng vào phần đăng ký ZZ0000ZZ và bạn có thể tìm thấy thông tin về
Gói OpenManager và Dell Update (DUP).

Libsmbios cũng có thể được sử dụng để cập nhật BIOS trên hệ thống Dell, hãy truy cập
ZZ0000ZZ để biết chi tiết.

Trình điều khiển Dell_RBU hỗ trợ cập nhật BIOS bằng hình ảnh nguyên khối và được đóng gói
các phương pháp hình ảnh Trong trường hợp nguyên khối, trình điều khiển phân bổ một đoạn liền kề
của các trang vật lý có hình ảnh BIOS. Trong trường hợp đóng gói ứng dụng
sử dụng trình điều khiển sẽ chia hình ảnh thành các gói có kích thước cố định và trình điều khiển
sẽ đặt mỗi gói vào bộ nhớ vật lý liền kề. Người lái xe cũng
duy trì một danh sách liên kết các gói để đọc lại chúng.

Nếu trình điều khiển Dell_rbu không được tải thì tất cả bộ nhớ được phân bổ sẽ được giải phóng.

Trình điều khiển rbu cần phải có một ứng dụng (như đã đề cập ở trên) sẽ
thông báo cho BIOS để kích hoạt bản cập nhật trong lần khởi động lại hệ thống tiếp theo.

Người dùng không nên dỡ trình điều khiển rbu sau khi tải xuống hình ảnh BIOS
hoặc đang cập nhật.

Tải trình điều khiển tạo các thư mục sau trong hệ thống tệp /sys::

/sys/class/firmware/dell_rbu/đang tải
	/sys/class/firmware/dell_rbu/data
	/sys/thiết bị/nền tảng/dell_rbu/image_type
	/sys/thiết bị/nền tảng/dell_rbu/dữ liệu
	/sys/thiết bị/nền tảng/dell_rbu/packet_size

Trình điều khiển hỗ trợ hai loại cơ chế cập nhật; nguyên khối và đóng gói.
Cơ chế cập nhật này phụ thuộc vào BIOS hiện đang chạy trên hệ thống.
Hầu hết các hệ thống Dell đều hỗ trợ bản cập nhật nguyên khối trong đó có hình ảnh BIOS
được sao chép vào một khối bộ nhớ vật lý liền kề.

Trong trường hợp cơ chế gói, bộ nhớ đơn có thể được chia thành các phần nhỏ hơn
bộ nhớ liền kề và hình ảnh BIOS nằm rải rác trong các gói này.

Theo mặc định, trình điều khiển sử dụng bộ nhớ nguyên khối cho loại cập nhật. Đây có thể là
đã thay đổi thành các gói trong thời gian tải trình điều khiển bằng cách chỉ định tải
tham số image_type=packet.  Điều này cũng có thể được thay đổi sau này như sau::

gói echo > /sys/devices/platform/dell_rbu/image_type

Trong chế độ cập nhật gói, kích thước gói phải được đưa ra trước khi bất kỳ gói nào có thể
được tải xuống. Nó được thực hiện như sau::

echo XXXX > /sys/devices/platform/dell_rbu/packet_size

Trong cơ chế cập nhật gói, người dùng cần tạo một tệp mới có
các gói dữ liệu được sắp xếp quay lưng lại với nhau. Nó có thể được thực hiện như sau:
Người dùng tạo tiêu đề gói, lấy đoạn hình ảnh BIOS và
đặt nó bên cạnh tiêu đề gói; bây giờ, phần hình ảnh tiêu đề gói + BIOS
được thêm vào cùng nhau phải khớp với packet_size được chỉ định. Điều này làm cho một
gói, người dùng cần tạo thêm các gói như vậy trong toàn bộ BIOS
tập tin hình ảnh và sau đó sắp xếp tất cả các gói này trở lại thành một
tập tin.

Sau đó, tệp này được sao chép vào /sys/class/firmware/dell_rbu/data.
Khi tệp này đến trình điều khiển, trình điều khiển sẽ trích xuất dữ liệu packet_size từ
tệp và trải rộng nó trên bộ nhớ vật lý theo dạng gói_size liền kề
không gian.

Phương pháp này đảm bảo rằng tất cả các gói đều đến được trình điều khiển chỉ bằng một thao tác.

Trong bản cập nhật nguyên khối, người dùng chỉ cần lấy hình ảnh BIOS (tệp .hdr) và sao chép
vào tệp dữ liệu mà không có bất kỳ thay đổi nào đối với hình ảnh BIOS.

Thực hiện các bước bên dưới để tải xuống hình ảnh BIOS.

1) echo 1 > /sys/class/firmware/dell_rbu/loading
2) cp bios_image.hdr /sys/class/firmware/dell_rbu/data
3) echo 0 > /sys/class/firmware/dell_rbu/loading

Các mục /sys/class/firmware/dell_rbu/ sẽ vẫn còn cho đến khi hoàn tất
xong.

::

echo -1 > /sys/class/firmware/dell_rbu/đang tải

Cho đến khi hoàn thành bước này, trình điều khiển không thể được tải xuống.

Ngoài ra, việc lặp lại mono, packet hoặc init vào image_type sẽ giải phóng
bộ nhớ được phân bổ bởi trình điều khiển.

Nếu người dùng vô tình thực hiện bước 1 và 3 ở trên mà không thực hiện bước 2;
nó sẽ làm cho các mục /sys/class/firmware/dell_rbu/ biến mất.

Các mục có thể được tạo lại bằng cách thực hiện như sau::

echo init > /sys/devices/platform/dell_rbu/image_type

.. note:: echoing init in image_type does not change its original value.

Ngoài ra, trình điều khiển còn cung cấp tệp chỉ đọc /sys/devices/platform/dell_rbu/data cho
đọc lại hình ảnh được tải xuống.

.. note::

   After updating the BIOS image a user mode application needs to execute
   code which sends the BIOS update request to the BIOS. So on the next reboot
   the BIOS knows about the new image downloaded and it updates itself.
   Also don't unload the rbu driver if the image has to be updated.

