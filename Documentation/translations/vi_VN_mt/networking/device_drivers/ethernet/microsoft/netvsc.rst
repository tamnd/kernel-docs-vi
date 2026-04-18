.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/microsoft/netvsc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Trình điều khiển mạng Hyper-V
=============================

Khả năng tương thích
====================

Trình điều khiển này tương thích với Windows Server 2012 R2, 2016 và
Windows 10.

Đặc trưng
=========

Giảm tải tổng kiểm tra
----------------------
Trình điều khiển netvsc hỗ trợ giảm tải tổng kiểm tra miễn là
  Phiên bản máy chủ Hyper-V có. Windows Server 2016 và Azure
  hỗ trợ giảm tải tổng kiểm tra cho TCP và UDP cho cả IPv4 và
  IPv6. Windows Server 2012 chỉ hỗ trợ giảm tải tổng kiểm tra cho TCP.

Nhận tỷ lệ bên
--------------------
Hyper-V hỗ trợ nhận tỷ lệ bên. Đối với TCP & UDP, các gói có thể
  được phân phối giữa các hàng đợi có sẵn dựa trên địa chỉ IP và cổng
  số.

Đối với TCP & UDP, chúng ta có thể chuyển đổi mức băm giữa L3 và L4 bằng ethtool
  lệnh. TCP/UDP qua IPv4 và v6 có thể được đặt khác nhau. Mặc định
  mức băm là L4. Chúng tôi hiện chỉ cho phép chuyển đổi mức băm TX
  từ bên trong khách.

Trên Azure, các gói UDP bị phân mảnh có tỷ lệ mất cao với L4
  băm. Nên sử dụng hàm băm L3 trong trường hợp này.

Ví dụ: đối với UDP qua IPv4 trên eth0:

Để bao gồm số cổng UDP khi băm::

ethtool -N eth0 rx-flow-hash udp4 sdfn

Để loại trừ số cổng UDP khi băm::

ethtool -N eth0 rx-flow-hash udp4 sd

Để hiển thị mức băm UDP::

ethtool -n eth0 rx-flow-hash udp4

Giảm tải nhận chung, hay còn gọi là GRO
---------------------------------------
Trình điều khiển hỗ trợ GRO và được bật theo mặc định. GRO kết hợp lại
  giống như các gói và giảm đáng kể việc sử dụng CPU trong Rx nặng
  tải.

Giảm tải nhận lớn (LRO) hoặc Liên kết bên nhận (RSC)
-------------------------------------------------------------
Trình điều khiển hỗ trợ LRO/RSC trong tính năng vSwitch. Nó làm giảm mỗi gói
  xử lý chi phí bằng cách kết hợp nhiều phân đoạn TCP khi có thể. các
  tính năng này được bật theo mặc định trên máy ảo chạy trên Windows Server 2019 và
  sau này. Nó có thể được thay đổi bằng lệnh ethtool ::

ethtool -K eth0 lro trên
	ethtool -K eth0 lro tắt

Hỗ trợ SR-IOV
--------------
Hyper-V hỗ trợ SR-IOV làm tùy chọn tăng tốc phần cứng. Nếu SR-IOV
  được bật trong cả cấu hình vSwitch và khách, thì
  Thiết bị Chức năng ảo (VF) được chuyển cho khách dưới dạng PCI
  thiết bị. Trong trường hợp này, cả thiết bị tổng hợp (netvsc) và VF đều
  hiển thị trong hệ điều hành khách và cả NIC đều có cùng địa chỉ MAC.

VF bị bắt làm nô lệ bởi thiết bị netvsc.  Trình điều khiển netvsc sẽ minh bạch
  chuyển đường dẫn dữ liệu sang VF khi nó sẵn sàng.
  Trạng thái mạng (địa chỉ, tường lửa, v.v.) chỉ nên được áp dụng cho
  thiết bị netvsc; thiết bị nô lệ không nên được truy cập trực tiếp trong
  hầu hết các trường hợp.  Các trường hợp ngoại lệ là nếu một số kỷ luật xếp hàng đặc biệt hoặc
  hướng dòng chảy là mong muốn, những điều này nên được áp dụng trực tiếp vào
  Thiết bị phụ VF.

Nhận bộ đệm
--------------
Các gói được nhận vào vùng nhận được tạo khi thiết bị
  được thăm dò. Vùng nhận được chia thành các khối có kích thước MTU và mỗi khối có thể
  chứa một hoặc nhiều gói. Số lượng phần nhận có thể được thay đổi
  thông qua các tham số vòng ethtool Rx.

Có một bộ đệm gửi tương tự được sử dụng để tổng hợp các gói
  để gửi.  Vùng gửi được chia thành nhiều phần, thường là 6144
  byte, mỗi phần có thể chứa một hoặc nhiều gói. nhỏ
  các gói thường được truyền qua bản sao tới bộ đệm gửi. Tuy nhiên,
  nếu bộ đệm tạm thời hết hoặc gói được truyền bị hỏng
  gói LSO, trình điều khiển sẽ cung cấp cho máy chủ các con trỏ tới dữ liệu
  từ SKB. Điều này cố gắng đạt được sự cân bằng giữa chi phí chung của
  sao chép dữ liệu và tác động của việc ánh xạ lại bộ nhớ VM để người dùng có thể truy cập được
  chủ nhà.

Hỗ trợ XDP
-----------
XDP (Đường dẫn dữ liệu eXpress) là một tính năng chạy mã byte eBPF ở đầu
  giai đoạn khi các gói đến thẻ NIC. Mục tiêu là tăng hiệu suất
  để xử lý gói, giảm chi phí phân bổ SKB và các chi phí khác
  các lớp mạng phía trên.

hv_netvsc hỗ trợ XDP ở chế độ gốc và đặt XDP một cách minh bạch
  chương trình trên VF NIC liên quan.

Cài đặt / hủy cài đặt chương trình XDP trên NIC (netvsc) tổng hợp truyền tới
  VF NIC tự động. Cài đặt/bỏ cài đặt chương trình XDP trực tiếp trên VF NIC
  không được khuyến khích, cũng không được nhân giống thành NIC tổng hợp và có thể
  được ghi đè bằng cách cài đặt NIC tổng hợp.

Chương trình XDP không thể chạy khi bật LRO (RSC), vì vậy bạn cần tắt LRO
  trước khi chạy XDP::

ethtool -K eth0 lro tắt

Hành động XDP_REDIRECT chưa được hỗ trợ.