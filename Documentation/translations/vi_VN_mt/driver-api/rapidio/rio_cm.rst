.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/rapidio/rio_cm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================================================
Trình điều khiển thiết bị ký tự nhắn tin theo kênh của hệ thống con RapidIO (rio_cm.c)
======================================================================================


1. Tổng quan
===========

Trình điều khiển thiết bị này là kết quả của sự hợp tác trong RapidIO.org
Nhóm nhiệm vụ phần mềm (STG) giữa Texas Instruments, Prodrive Technologies,
Mạng Nokia, BAE và IDT.  Đã nhận được ý kiến bổ sung từ các thành viên khác
của RapidIO.org.

Mục tiêu là tạo ra một giao diện trình điều khiển chế độ ký tự hiển thị
khả năng nhắn tin trực tiếp của thiết bị đầu cuối RapidIO (mports)
cho các ứng dụng, theo cách cho phép nhiều và đa dạng RapidIO
triển khai để tương tác.

Trình điều khiển này (RIO_CM) cung cấp cho các ứng dụng trong không gian người dùng quyền truy cập chung vào
Tài nguyên nhắn tin hộp thư RapidIO.

Đặc tả RapidIO (Phần 2) xác định rằng các thiết bị đầu cuối có thể có tới bốn
hộp thư nhắn tin trong trường hợp tin nhắn nhiều gói (tối đa 4KB) và
tối đa 64 hộp thư nếu sử dụng tin nhắn gói đơn (tối đa 256 B). Ngoài ra
đối với các hạn chế về định nghĩa giao thức, việc triển khai phần cứng cụ thể có thể
đã giảm số lượng hộp thư nhắn tin.  Các ứng dụng nhận biết RapidIO phải
do đó chia sẻ tài nguyên nhắn tin của điểm cuối RapidIO.

Mục đích chính của trình điều khiển thiết bị này là cung cấp tính năng nhắn tin hộp thư RapidIO
khả năng đáp ứng số lượng lớn các quy trình trong không gian người dùng bằng cách giới thiệu các tính năng giống như ổ cắm
hoạt động bằng cách sử dụng một hộp thư nhắn tin duy nhất.  Điều này cho phép các ứng dụng
sử dụng hiệu quả tài nguyên phần cứng nhắn tin RapidIO hạn chế.

Hầu hết các hoạt động của trình điều khiển thiết bị đều được hỗ trợ thông qua các lệnh gọi hệ thống 'ioctl'.

Khi được tải, trình điều khiển thiết bị này sẽ tạo một nút hệ thống tệp duy nhất có tên rio_cm
trong thư mục /dev chung cho tất cả các thiết bị nhập RapidIO đã đăng ký.

Các lệnh ioctl sau có sẵn cho các ứng dụng trong không gian người dùng:

-RIO_CM_MPORT_GET_LIST:
    Trả về danh sách người gọi của các thiết bị nhập cục bộ
    hỗ trợ các hoạt động nhắn tin (số lượng mục lên tới RIO_MAX_MPORTS).
    Mỗi mục danh sách là sự kết hợp giữa chỉ mục của mport trong hệ thống và RapidIO
    ID đích được gán cho cổng.
-RIO_CM_EP_GET_LIST_SIZE:
    Trả về số lượng điểm cuối từ xa có khả năng nhắn tin
    trong mạng RapidIO được liên kết với thiết bị nhập được chỉ định.
-RIO_CM_EP_GET_LIST:
    Trả về danh sách ID đích RapidIO để nhắn tin
    các điểm cuối từ xa có khả năng (ngang hàng) có sẵn trong mạng RapidIO được liên kết
    với thiết bị nhập được chỉ định.
-RIO_CM_CHAN_CREATE:
    Tạo cấu trúc dữ liệu kênh trao đổi tin nhắn RapidIO
    với ID kênh được gán tự động hoặc theo yêu cầu của người gọi.
-RIO_CM_CHAN_BIND:
    Liên kết cấu trúc dữ liệu kênh đã chỉ định với cấu trúc dữ liệu đã chỉ định
    thiết bị nhập khẩu.
-RIO_CM_CHAN_LISTEN:
    Cho phép lắng nghe các yêu cầu kết nối trên thiết bị được chỉ định
    kênh.
-RIO_CM_CHAN_ACCEPT:
    Chấp nhận yêu cầu kết nối từ ngang hàng trên thiết bị được chỉ định
    kênh. Nếu thời gian chờ cho yêu cầu này được người gọi chỉ định thì đó là
    một cuộc gọi chặn. Nếu thời gian chờ được đặt thành 0 thì đây là cuộc gọi không chặn - ioctl
    trình xử lý kiểm tra yêu cầu kết nối đang chờ xử lý và nếu không có yêu cầu kết nối
    thoát ngay lập tức với trạng thái lỗi -EGAIN.
-RIO_CM_CHAN_CONNECT:
    Gửi yêu cầu kết nối đến một kênh/ngang hàng từ xa.
-RIO_CM_CHAN_SEND:
    Gửi tin nhắn dữ liệu qua kênh được chỉ định.
    Trình xử lý yêu cầu này giả định rằng bộ đệm thông báo được chỉ định bởi
    người gọi bao gồm không gian dành riêng cho tiêu đề gói được yêu cầu bởi
    người lái xe này.
-RIO_CM_CHAN_RECEIVE:
    Nhận tin nhắn dữ liệu thông qua kênh được kết nối.
    Nếu kênh không có tin nhắn đến sẵn sàng trả lại ioctl này
    trình xử lý sẽ đợi tin nhắn mới cho đến khi hết thời gian do người gọi chỉ định
    hết hạn. Nếu giá trị thời gian chờ được đặt thành 0, trình xử lý ioctl sẽ sử dụng giá trị mặc định
    được xác định bởi MAX_SCHEDULE_TIMEOUT.
-RIO_CM_CHAN_CLOSE:
    Đóng một kênh được chỉ định và giải phóng các bộ đệm liên quan.
    Nếu kênh được chỉ định ở trạng thái CONNECTED, hãy gửi thông báo đóng
    tới máy ngang hàng ở xa.

Mã lệnh ioctl và cấu trúc dữ liệu tương ứng được thiết kế để sử dụng bởi
các ứng dụng trong không gian người dùng được xác định trong 'include/uapi/linux/rio_cm_cdev.h'.

2. Khả năng tương thích phần cứng
=========================

Trình điều khiển thiết bị này sử dụng các giao diện tiêu chuẩn được xác định bởi hệ thống con RapidIO kernel
và do đó nó có thể được sử dụng với bất kỳ trình điều khiển thiết bị mport nào được RapidIO đăng ký
hệ thống con với các giới hạn được đặt bởi việc triển khai thông báo phần cứng nhập khẩu có sẵn
hộp thư.

3. Thông số mô-đun
====================

- 'dbg_level'
      - Tham số này cho phép kiểm soát lượng thông tin gỡ lỗi
        được tạo bởi trình điều khiển thiết bị này. Tham số này được hình thành bởi tập hợp
        mặt nạ bit tương ứng với khối chức năng cụ thể.
        Để biết định nghĩa mặt nạ, hãy xem 'drivers/rapidio/devices/rio_cm.c'
        Tham số này có thể được thay đổi linh hoạt.
        Sử dụng CONFIG_RAPIDIO_DEBUG=y để bật đầu ra gỡ lỗi ở cấp cao nhất.

- 'hộp cm'
      - Số lượng hộp thư RapidIO sẽ sử dụng (giá trị mặc định là 1).
        Tham số này cho phép thiết lập số hộp thư nhắn tin sẽ được sử dụng
        trong toàn bộ mạng RapidIO. Nó có thể được sử dụng khi hộp thư mặc định
        được sử dụng bởi trình điều khiển thiết bị khác hoặc không được một số nút trong
        Mạng RapidIO.

- 'bắt đầu'
      - Bắt đầu số kênh để phân công động. Giá trị mặc định - 256.
        Cho phép loại trừ số kênh bên dưới tham số này khỏi động
        phân bổ để tránh xung đột với các thành phần phần mềm sử dụng
        số kênh được xác định trước dành riêng.

4. Các vấn đề đã biết
=================

Không có.

5. Ứng dụng không gian người dùng và Thư viện API
==========================================

Thư viện tin nhắn API và các ứng dụng sử dụng trình điều khiển thiết bị này có sẵn
từ RapidIO.org.

6. Danh sách TODO
============

- Thêm hỗ trợ tin nhắn thông báo hệ thống (kênh dành riêng 0).
