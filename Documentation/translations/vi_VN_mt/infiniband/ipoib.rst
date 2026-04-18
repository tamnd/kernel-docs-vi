.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/infiniband/ipoib.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================
IP qua InfiniBand
==================

Trình điều khiển ib_ipoib là việc triển khai IP qua InfiniBand
  giao thức được chỉ định bởi RFC 4391 và 4392, do IETF ipoib ban hành
  nhóm làm việc.  Đây là một cách triển khai "bản địa" theo nghĩa
  cài đặt loại giao diện thành ARPHRD_INFINIBAND và phần cứng
  độ dài địa chỉ lên tới 20 (các triển khai độc quyền trước đó
  giả mạo hạt nhân dưới dạng giao diện ethernet).

Phân vùng và P_Key
=====================

Khi trình điều khiển IPoIB được tải, nó sẽ tạo một giao diện cho mỗi trình điều khiển.
  cổng bằng cách sử dụng P_Key ở chỉ số 0. Để tạo giao diện với
  P_Key khác nhau, hãy ghi P_Key mong muốn vào giao diện chính
  /sys/class/net/<intf name>/tệp create_child.  Ví dụ::

echo 0x8001 > /sys/class/net/ib0/create_child

Điều này sẽ tạo ra một giao diện có tên ib0.8001 với P_Key 0x8001.  Đến
  xóa giao diện con, sử dụng tệp "delete_child"::

echo 0x8001 > /sys/class/net/ib0/delete_child

P_Key cho bất kỳ giao diện nào được cung cấp bởi tệp "pkey" và
  giao diện chính cho giao diện phụ nằm ở "cha mẹ".

Việc tạo/xóa giao diện con cũng có thể được thực hiện bằng cách sử dụng IPoIB
  rtnl_link_ops, trong đó trẻ em được tạo bằng cách sử dụng một trong hai cách sẽ hoạt động giống nhau.

Datagram và chế độ được kết nối
===========================

Trình điều khiển IPoIB hỗ trợ hai chế độ hoạt động: datagram và
  được kết nối.  Chế độ được thiết lập và đọc qua giao diện
  /sys/class/net/<intf name>/tệp chế độ.

Trong chế độ datagram, việc truyền tải IB UD (Datagram không đáng tin cậy) được sử dụng
  và do đó giao diện MTU có bằng IB L2 MTU trừ đi
  Tiêu đề đóng gói IPOIB (4 byte).  Ví dụ, trong một IB điển hình
  vải có 2K MTU thì IPoIB MTU sẽ là 2048 - 4 = 2044 byte.

Ở chế độ được kết nối, vận chuyển IB RC (Được kết nối đáng tin cậy) được sử dụng.
  Chế độ kết nối tận dụng tính chất kết nối của IB
  vận chuyển và cho phép MTU có kích thước gói IP tối đa là 64K,
  giúp giảm số lượng gói IP cần thiết để xử lý UDP lớn
  datagram, phân đoạn TCP, v.v. và tăng hiệu suất cho các gói dữ liệu lớn
  tin nhắn.

Ở chế độ kết nối, UD QP của giao diện vẫn được sử dụng cho multicast
  và liên lạc với các đồng nghiệp không hỗ trợ chế độ kết nối. trong
  trong trường hợp này, mô phỏng RX của các gói ICMP PMTU được sử dụng để gây ra
  ngăn xếp mạng để sử dụng UD MTU nhỏ hơn cho những người hàng xóm này.

Giảm tải không quốc tịch
==================

Nếu IB HW hỗ trợ giảm tải không trạng thái IPoIB, IPoIB sẽ quảng cáo
  Tổng kiểm tra TCP/IP và/hoặc khả năng giảm tải Gửi lớn (LSO) tới
  ngăn xếp mạng.

Việc giảm tải Nhận lớn (LRO) cũng được triển khai và có thể được chuyển sang
  bật/tắt bằng lệnh gọi ethtool.  Hiện tại LRO chỉ được hỗ trợ cho
  các thiết bị có khả năng giảm tải tổng kiểm tra.

Giảm tải không trạng thái chỉ được hỗ trợ ở chế độ datagram.

Kiểm duyệt gián đoạn
====================

Nếu thiết bị IB cơ bản hỗ trợ kiểm duyệt sự kiện CQ, người ta có thể
  sử dụng ethtool để đặt các tham số giảm thiểu gián đoạn và do đó giảm
  chi phí phát sinh bằng cách xử lý các ngắt.  Đường dẫn mã chính của
  IPoIB không sử dụng các sự kiện để báo hiệu hoàn thành TX nên chỉ có RX
  kiểm duyệt được hỗ trợ.

Thông tin gỡ lỗi
=====================

Bằng cách biên dịch trình điều khiển IPoIB với bộ CONFIG_INFINIBAND_IPOIB_DEBUG
  đến 'y', các thông báo truy tìm sẽ được biên dịch vào trình điều khiển.  Họ là
  được bật bằng cách cài đặt các tham số mô-đun debug_level và
  mcast_debug_level thành 1. Các tham số này có thể được kiểm soát tại
  thời gian chạy thông qua các tệp trong /sys/module/ib_ipoib/.

CONFIG_INFINIBAND_IPOIB_DEBUG cũng kích hoạt các tệp trong debugfs
  hệ thống tập tin ảo.  Bằng cách gắn hệ thống tập tin này, ví dụ như với::

mount -t debugfs none /sys/kernel/debug

có thể lấy số liệu thống kê về các nhóm multicast từ
  các tập tin /sys/kernel/debug/ipoib/ib0_mcg, v.v.

Tác động hiệu suất của tùy chọn này là không đáng kể, vì vậy nó
  an toàn khi bật tùy chọn này với debug_level được đặt thành 0 đối với bình thường
  hoạt động.

CONFIG_INFINIBAND_IPOIB_DEBUG_DATA cho phép đầu ra gỡ lỗi nhiều hơn nữa trong
  đường dẫn dữ liệu khi data_debug_level được đặt thành 1. Tuy nhiên, ngay cả với
  đầu ra bị tắt, việc bật tùy chọn cấu hình này sẽ ảnh hưởng đến
  hiệu suất, bởi vì nó thêm các bài kiểm tra vào đường dẫn nhanh.

Tài liệu tham khảo
==========

Truyền IP qua InfiniBand (IPoIB) (RFC 4391)
    ZZ0000ZZ

Kiến trúc IP qua InfiniBand (IPoIB) (RFC 4392)
    ZZ0000ZZ

IP qua InfiniBand: Chế độ kết nối (RFC 4755)
    ZZ0000ZZ
