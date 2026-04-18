.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/wwan/t7xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2020-21 Intel Corporation

.. _t7xx_driver_doc:

================================================
trình điều khiển t7xx cho modem T700 5G dựa trên MTK PCIe
============================================
Trình điều khiển t7xx là trình điều khiển máy chủ WWAN PCIe được phát triển cho linux hoặc Chrome OS
nền tảng để trao đổi dữ liệu qua giao diện PCIe giữa nền tảng Máy chủ &
Modem T700 5G của MediaTek.
Trình điều khiển hiển thị giao diện phù hợp với giao thức MBIM [1]. Bất kỳ mặt trận nào
ứng dụng cuối (ví dụ: Trình quản lý Modem) có thể dễ dàng quản lý giao diện MBIM để
cho phép truyền dữ liệu tới WWAN. Trình điều khiển cũng cung cấp một giao diện
để tương tác với modem của MediaTek thông qua các lệnh AT.

Cách sử dụng cơ bản
===========
Các chức năng MBIM & AT không hoạt động khi không được quản lý. Trình điều khiển t7xx cung cấp
Giao diện không gian người dùng cổng WWAN đại diện cho các kênh điều khiển MBIM & AT và
không đóng bất kỳ vai trò nào trong việc quản lý chức năng của chúng. Đó là công việc của không gian người dùng
ứng dụng để phát hiện việc liệt kê cổng và kích hoạt các chức năng MBIM & AT.

Ví dụ về một số ứng dụng không gian người dùng như vậy là:

- mbimcli (có trong thư viện libmbim [2]) và
- Trình quản lý modem [3]

Ứng dụng quản lý để thực hiện các hành động cần thiết dưới đây để thiết lập
Phiên IP MBIM:

- mở kênh điều khiển MBIM
- cấu hình cài đặt kết nối mạng
- kết nối với mạng
- cấu hình giao diện mạng IP

Ứng dụng quản lý để thực hiện các hành động cần thiết dưới đây để gửi AT
ra lệnh và nhận phản hồi:

- mở kênh điều khiển AT bằng công cụ UART hoặc công cụ người dùng đặc biệt

hệ thống
=====
Trình điều khiển cung cấp giao diện sysfs cho không gian người dùng.

t7xx_mode
---------
Giao diện sysfs cung cấp không gian người dùng quyền truy cập vào chế độ thiết bị, điều này
giao diện hỗ trợ các hoạt động đọc và ghi.

Chế độ thiết bị:

- ZZ0000ZZ đại diện cho thiết bị đó ở trạng thái không xác định
- ZZ0001ZZ thể hiện thiết bị đó ở trạng thái sẵn sàng
- ZZ0002ZZ đại diện cho thiết bị đó ở trạng thái reset
- ZZ0003ZZ đại diện cho thiết bị đó ở trạng thái chuyển fastboot
- ZZ0004ZZ đại diện cho thiết bị đó ở trạng thái tải fastboot
- ZZ0005ZZ đại diện cho thiết bị đó ở trạng thái kết xuất fastboot

Đọc từ không gian người dùng để có chế độ thiết bị hiện tại.

::
  $ cat /sys/bus/pci/devices/${bdf}/t7xx_mode

Viết từ không gian người dùng để đặt chế độ thiết bị.

::
  $ echo fastboot_switching > /sys/bus/pci/devices/${bdf}/t7xx_mode

t7xx_debug_ports
----------------
Giao diện sysfs cung cấp không gian người dùng quyền truy cập để bật/tắt tính năng gỡ lỗi
cổng, giao diện này hỗ trợ các hoạt động đọc và ghi.

Trạng thái cổng gỡ lỗi:

- ZZ0000ZZ đại diện cho việc kích hoạt các cổng gỡ lỗi
- ZZ0001ZZ đại diện cho việc vô hiệu hóa các cổng gỡ lỗi

Các cổng gỡ lỗi hiện được hỗ trợ (ADB/MIPC).

Đọc từ không gian người dùng để biết trạng thái cổng gỡ lỗi hiện tại.

::
  $ cat /sys/bus/pci/devices/${bdf}/t7xx_debug_ports

Viết từ không gian người dùng để đặt trạng thái cổng gỡ lỗi.

::
  $ echo 1 > /sys/bus/pci/devices/${bdf}/t7xx_debug_ports

Phát triển ứng dụng quản lý
==================================
Giao diện trình điều khiển và không gian người dùng được mô tả bên dưới. Giao thức MBIM là
được mô tả trong [1] Mô hình giao diện băng thông rộng di động v1.0 Errata-1.

Không gian người dùng kênh điều khiển MBIM ABI
----------------------------------

/dev/wwan0mbim0 thiết bị ký tự
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển hiển thị giao diện MBIM cho chức năng MBIM bằng cách triển khai
Cổng MBIM WWAN. Đầu không gian người dùng của ống kênh điều khiển là một
Thiết bị ký tự /dev/wwan0mbim0. Ứng dụng sẽ sử dụng giao diện này cho
Giao thức truyền thông MBIM.

Sự phân mảnh
~~~~~~~~~~~~~
Ứng dụng không gian người dùng chịu trách nhiệm cho tất cả sự phân mảnh thông điệp điều khiển
và chống phân mảnh theo thông số kỹ thuật của MBIM.

/dev/wwan0mbim0 write()
~~~~~~~~~~~~~~~~~~~~~~~
Các thông báo điều khiển MBIM từ ứng dụng quản lý không được vượt quá
kích thước thông điệp điều khiển được đàm phán.

/dev/wwan0mbim0 đọc()
~~~~~~~~~~~~~~~~~~~~~~
Ứng dụng quản lý phải chấp nhận các thông báo điều khiển theo thỏa thuận
kiểm soát kích thước tin nhắn.

Không gian người dùng kênh dữ liệu MBIM ABI
-------------------------------

thiết bị mạng wwan0-X
~~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển t7xx hiển thị giao diện liên kết IP "wwan0-X" thuộc loại "wwan" cho IP
giao thông. Tiện ích mạng Iproute được sử dụng để tạo mạng "wwan0-X"
giao diện và để liên kết nó với phiên IP MBIM.

Ứng dụng quản lý userspace có nhiệm vụ tạo liên kết IP mới
trước khi thiết lập phiên IP MBIM trong đó SessionId lớn hơn 0.

Ví dụ: tạo liên kết IP mới cho phiên IP MBIM với SessionId 1:

liên kết ip thêm dev wwan0-1 parentdev wwan0 loại wwan linkid 1

Trình điều khiển sẽ tự động ánh xạ thiết bị mạng "wwan0-1" tới IP MBIM
phiên 1.

Không gian người dùng cổng AT ABI
----------------------------------

thiết bị ký tự /dev/wwan0at0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển hiển thị cổng AT bằng cách triển khai Cổng AT WWAN.
Phần cuối không gian người dùng của cổng điều khiển là ký tự /dev/wwan0at0
thiết bị. Ứng dụng sẽ sử dụng giao diện này để phát lệnh AT.

không gian người dùng cổng fastboot ABI
---------------------------

/dev/wwan0fastboot0 thiết bị ký tự
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển hiển thị giao diện giao thức fastboot bằng cách triển khai
Cổng fastboot WWAN. Phần cuối không gian người dùng của ống kênh fastboot là một
Thiết bị ký tự /dev/wwan0fastboot0. Ứng dụng sẽ sử dụng giao diện này cho
giao tiếp giao thức fastboot.

Xin lưu ý rằng trình điều khiển cần được tải lại để xuất /dev/wwan0fastboot0
cổng, vì thiết bị cần thiết lập lại nguội sau khi nhập ZZ0000ZZ
chế độ.

Không gian người dùng cổng ADB ABI
----------------------

thiết bị ký tự /dev/wwan0adb0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển hiển thị giao diện giao thức ADB bằng cách triển khai Cổng ADB WWAN.
Phần cuối không gian người dùng của ống kênh ADB là thiết bị ký tự /dev/wwan0adb0.
Ứng dụng sẽ sử dụng giao diện này để liên lạc với giao thức ADB.

Không gian người dùng cổng MIPC ABI
-----------------------

/dev/wwan0mipc0 thiết bị ký tự
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển hiển thị giao diện chẩn đoán bằng cách triển khai MIPC (Modem
Trung tâm xử lý thông tin) Cổng WWAN. Phần cuối không gian người dùng của kênh MIPC
pipe là thiết bị ký tự /dev/wwan0mipc0.
Ứng dụng sẽ sử dụng giao diện này để liên lạc chẩn đoán modem MTK.

Modem T700 của MediaTek hỗ trợ thông số kỹ thuật 3GPP TS 27.007 [4].

Tài liệu tham khảo
==========
[1] ZZ0000ZZ

-ZZ0000ZZ

[2] *libmbim "một thư viện dựa trên glib để nói chuyện với các modem và thiết bị WWAN
nói giao thức Mô hình băng thông rộng giao diện di động (MBIM)"*

-ZZ0000ZZ

[3] *Trình quản lý modem "một trình nền được kích hoạt bằng DBus để điều khiển băng thông rộng di động
(2G/3G/4G/5G) thiết bị và kết nối"*

-ZZ0000ZZ

[4] ZZ0000ZZ

-ZZ0000ZZ

[5] ZZ0000ZZ

-ZZ0000ZZ

[6] *ADB (Cầu gỡ lỗi Android) "một cơ chế theo dõi các thiết bị Android
và các phiên bản trình mô phỏng được kết nối hoặc chạy trên một nhà phát triển máy chủ nhất định
máy có giao thức ADB"*

-ZZ0000ZZ