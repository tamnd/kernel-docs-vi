.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/wwan/iosm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2020-21 Intel Corporation

.. _iosm_driver_doc:

===============================================
Trình điều khiển IOSM cho Modem dựa trên Intel M.2 PCIe
===========================================
Trình điều khiển IOSM (IPC trên bộ nhớ dùng chung) là trình điều khiển máy chủ WWAN được phát triển
dành cho nền tảng linux hoặc chrome để trao đổi dữ liệu qua giao diện PCIe giữa
Nền tảng máy chủ & Modem Intel M.2. Trình điều khiển hiển thị giao diện phù hợp với
Giao thức MBIM [1]. Bất kỳ ứng dụng giao diện người dùng nào (ví dụ: Trình quản lý Modem) đều có thể dễ dàng
quản lý giao diện MBIM để cho phép truyền dữ liệu tới WWAN.

Cách sử dụng cơ bản
===========
Các chức năng MBIM không hoạt động khi không được quản lý. Trình điều khiển IOSM chỉ cung cấp một
giao diện không gian người dùng MBIM "WWAN PORT" đại diện cho kênh điều khiển MBIM và thực hiện
không đóng bất kỳ vai trò nào trong việc quản lý chức năng. Đó là công việc của không gian người dùng
ứng dụng để phát hiện việc liệt kê cổng và kích hoạt chức năng MBIM.

Ví dụ về một số ứng dụng không gian người dùng như vậy là:
- mbimcli (có trong thư viện libmbim [2]) và
- Trình quản lý modem [3]

Ứng dụng quản lý để thực hiện các hành động cần thiết dưới đây để thiết lập
Phiên IP MBIM:
- mở kênh điều khiển MBIM
- cấu hình cài đặt kết nối mạng
- kết nối với mạng
- cấu hình giao diện mạng IP

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
Trình điều khiển IOSM hiển thị giao diện liên kết IP "wwan0-X" thuộc loại "wwan" cho IP
giao thông. Tiện ích mạng Iproute được sử dụng để tạo mạng "wwan0-X"
giao diện và để liên kết nó với phiên IP MBIM. Trình điều khiển hỗ trợ
tối đa 8 phiên IP để liên lạc IP đồng thời.

Ứng dụng quản lý userspace có nhiệm vụ tạo liên kết IP mới
trước khi thiết lập phiên IP MBIM trong đó SessionId lớn hơn 0.

Ví dụ: tạo liên kết IP mới cho phiên IP MBIM với SessionId 1:

liên kết ip thêm dev wwan0-1 parentdev-name wwan0 loại wwan linkid 1

Trình điều khiển sẽ tự động ánh xạ thiết bị mạng "wwan0-1" tới IP MBIM
phiên 1.

Tài liệu tham khảo
==========
[1] "MBIM (Mẫu giao diện băng thông rộng di động) Errata-1"
      -ZZ0000ZZ

[2] libmbim - "một thư viện dựa trên glib để nói chuyện với modem WWAN và
      các thiết bị hỗ trợ Model băng thông rộng giao diện di động (MBIM)
      giao thức"
      -ZZ0000ZZ

[3] Trình quản lý Modem - "daemon được kích hoạt DBus để điều khiển thiết bị di động
      thiết bị và kết nối băng thông rộng (2G/3G/4G)"
      -ZZ0000ZZ