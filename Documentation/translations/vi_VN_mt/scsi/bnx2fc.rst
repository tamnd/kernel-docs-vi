.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/bnx2fc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================
Vận hành FCoE bằng bnx2fc
===========================
Giảm tải Broadcom FCoE thông qua bnx2fc là giảm tải phần cứng ở trạng thái đầy đủ.
hợp tác với tất cả các giao diện do hệ sinh thái Linux cung cấp cho FC/FCoE và
Bộ điều khiển SCSI.  Như vậy, chức năng FCoE, một khi được kích hoạt phần lớn sẽ được
minh bạch. Các thiết bị được phát hiện trên SAN sẽ được đăng ký và hủy đăng ký
tự động với các lớp lưu trữ phía trên.

Mặc dù thực tế là việc giảm tải FCoE của Broadcom đã được giảm tải hoàn toàn, nhưng nó vẫn
phụ thuộc vào trạng thái của các giao diện mạng để hoạt động. Như vậy, mạng
giao diện (ví dụ: eth0) được liên kết với bộ khởi tạo giảm tải FCoE phải ở trạng thái 'lên'.
Chúng tôi khuyên bạn nên cấu hình các giao diện mạng để hiển thị
tự động khi khởi động.

Hơn nữa, giải pháp giảm tải Broadcom FCoE tạo giao diện VLAN để
hỗ trợ các Vlan đã được phát hiện cho hoạt động FCoE (ví dụ:
eth0.1001-fcoe).  Không xóa hoặc vô hiệu hóa các giao diện này hoặc hoạt động FCoE
sẽ bị gián đoạn.

Mô hình sử dụng trình điều khiển:
===================

1. Đảm bảo rằng gói fcoe-utils đã được cài đặt.

2. Định cấu hình các giao diện mà trình điều khiển bnx2fc phải hoạt động trên đó.
Dưới đây là các bước để cấu hình:

Một. cd /etc/fcoe
	b. sao chép cfg-ethx sang cfg-eth5 nếu FCoE phải được bật trên eth5.
	c. Lặp lại điều này cho tất cả các giao diện mà FCoE phải được bật.
	d. Chỉnh sửa tất cả các tệp cfg-eth để đặt "no" cho trường DCB_REQUIRED** và
	   "có" cho AUTO_VLAN.
	đ. Các thông số cấu hình khác nên để mặc định

3. Đảm bảo rằng "bnx2fc" có trong danh sách SUPPORTED_DRIVERS trong /etc/fcoe/config.

4. Bắt đầu dịch vụ fcoe. (bắt đầu dịch vụ fcoe). Nếu thiết bị Broadcom có mặt ở
hệ thống, trình điều khiển bnx2fc sẽ tự động yêu cầu các giao diện, khởi động vlan
khám phá và đăng nhập vào các mục tiêu.

5. "Tên tượng trưng" trong đầu ra 'fcoeadm -i' sẽ hiển thị nếu bnx2fc đã xác nhận quyền sở hữu
giao diện.

Ví dụ::

[root@bh2 ~]# fcoeadm -i
    Mô tả: NetXtreme II BCM57712 10 Gigabit Ethernet
    Sửa đổi: 01
    Nhà sản xuất: Broadcom Corporation
    Số Serial: 0010186FD558
    Trình điều khiển: bnx2x 1.70.00-0
    Số cổng: 2

Tên tượng trưng: bnx2fc v1.0.5 trên eth5.4
        Tên thiết bị hệ điều hành: Host11
        Tên nút: 0x10000010186FD559
        Tên cổng: 0x20000010186FD559
        Tên vải: 0x2001000DECB3B681
        Tốc độ: 10 Gbit
        Tốc độ được hỗ trợ: 10 Gbit
        Kích thước khung tối đa: 2048
        FC-ID (ID cổng): 0x0F0377
        Tiểu bang: Trực tuyến

6. Xác minh việc khám phá vlan được thực hiện bằng cách chạy ifconfig và thông báo
   <INTERFACE>.<VLAN>Các giao diện-fcoe được tạo tự động.

Tham khảo trang chủ fcoeadm để biết thêm thông tin về các hoạt động của fcoeadm đối với
tạo/hủy giao diện hoặc hiển thị thông tin lun/mục tiêu.

NOTE
====
** Các thiết bị có khả năng Broadcom FCoE triển khai máy khách DCBX/LLDP trên chip. Chỉ có một
Máy khách LLDP được phép trên mỗi giao diện. Để vận hành đúng tất cả phần mềm máy chủ
phải tắt các máy khách DCBX/LLDP dựa trên (ví dụ: lldpad). Để tắt lldpad trên một
giao diện đã cho, hãy chạy lệnh sau ::

lldptool set-lldp -i <interface_name> adminStatus=disabled