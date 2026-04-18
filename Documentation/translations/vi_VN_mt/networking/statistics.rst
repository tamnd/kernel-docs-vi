.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/statistics.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Thống kê giao diện
======================

Tổng quan
=========

Tài liệu này là hướng dẫn thống kê giao diện mạng Linux.

Có ba nguồn thống kê giao diện chính trong Linux:

- Thống kê giao diện chuẩn dựa trên
   ZZ0000ZZ;
 - thống kê theo giao thức cụ thể; và
 - số liệu thống kê do trình điều khiển xác định có sẵn thông qua ethtool.

Thống kê giao diện chuẩn
-----------------------------

Có nhiều giao diện để đạt được số liệu thống kê tiêu chuẩn.
Được sử dụng phổ biến nhất là lệnh ZZ0000ZZ từ ZZ0001ZZ::

$ ip -s -s hiển thị liên kết dev ens4u1u1
  6: ens4u1u1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel trạng thái Chế độ UP chế độ UP mặc định của nhóm DEFAULT qlen 1000
    liên kết/ether 48:2a:e3:4c:b1:d1 brd ff:ff:ff:ff:ff:ff
    RX: lỗi gói byte bị bỏ qua mcast
    74327665117 69016965 0 0 0 0
    Lỗi RX: thiếu độ dài khung crc fifo
               0 0 0 0 0
    TX: lỗi gói byte bị rớt mạng thu thập sóng mang
    21405556176 44608960 0 0 0 0
    Lỗi TX: quá trình truyền nhịp tim của cửa sổ fifo bị hủy bỏ
               0 0 0 0 128
    tên thay thế enp58s0u1u1

Lưu ý rằng ZZ0001ZZ đã được chỉ định hai lần để xem tất cả các thành viên của
ZZ0000ZZ.
Nếu ZZ0002ZZ được chỉ định khi lỗi chi tiết sẽ không được hiển thị.

ZZ0000ZZ hỗ trợ định dạng JSON thông qua tùy chọn ZZ0001ZZ.

Thống kê hàng đợi
~~~~~~~~~~~~~~~~~

Thống kê hàng đợi có thể truy cập được thông qua họ netlink netdev.

Hiện tại không có CLI được phân phối rộng rãi để truy cập các số liệu thống kê đó.
Các công cụ phát triển hạt nhân (ynl) có thể được sử dụng để thử nghiệm chúng,
xem ZZ0000ZZ.

Thống kê theo giao thức cụ thể
------------------------------

Số liệu thống kê theo giao thức cụ thể được hiển thị thông qua các giao diện có liên quan,
các giao diện tương tự như được sử dụng để cấu hình chúng.

công cụ đạo đức
~~~~~~~~~~~~~~~

Ethtool hiển thị số liệu thống kê cấp thấp phổ biến.
Tất cả các số liệu thống kê tiêu chuẩn dự kiến sẽ được duy trì
bởi thiết bị chứ không phải do trình điều khiển (ngược lại với các số liệu thống kê do trình điều khiển xác định
được mô tả trong phần tiếp theo kết hợp số liệu thống kê phần mềm và phần cứng).
Đối với các thiết bị có chứa không được quản lý
bộ chuyển mạch (ví dụ: SR-IOV cũ hoặc NIC nhiều máy chủ), các sự kiện được tính
có thể không liên quan riêng đến các gói được gửi tới
giao diện máy chủ cục bộ. Nói cách khác, các sự kiện có thể
được tính tại cổng mạng (khối MAC/PHY) mà không cần phân tách
cho các thiết bị phía máy chủ (PCIe) khác nhau. Sự mơ hồ như vậy không được
hiện diện khi bộ chuyển mạch nội bộ được quản lý bởi Linux (được gọi là
chế độ switchdev cho NIC).

Số liệu thống kê ethtool tiêu chuẩn có thể được truy cập thông qua các giao diện được sử dụng
cho cấu hình. Ví dụ giao diện ethtool được sử dụng
để định cấu hình các khung tạm dừng có thể báo cáo các bộ đếm phần cứng tương ứng::

$ ethtool --include-statistics -a eth0
  Tạm dừng tham số cho eth0:
  Tự động đàm phán: bật
  RX: bật
  TX: bật
  Thống kê:
    tx_pause_frames: 1
    rx_pause_frames: 1

Số liệu thống kê chung về Ethernet không liên quan đến bất kỳ thông tin cụ thể nào
chức năng được hiển thị thông qua ZZ0000ZZ bằng cách chỉ định
tham số ZZ0001ZZ::

$ ethtool -S eth0 --groups eth-phy eth-mac eth-ctrl rmon
  Số liệu thống kê cho eth0:
  eth-phy-SymbolErrorDuringCarrier: 0
  eth-mac-FramesTruyền OK: 1
  eth-mac-FrameTooLongErrors: 1
  eth-ctrl-MACControlFramesĐã truyền: 1
  eth-ctrl-MACControlFramesĐã nhận: 0
  eth-ctrl-Không được hỗ trợOpcodesĐã nhận: 1
  rmon-etherStatsUndersizePkts: 1
  rmon-etherStatsJabbers: 0
  rmon-rx-etherStatsPkts64Octets: 1
  rmon-rx-etherStatsPkts65to127Octets: 0
  rmon-rx-etherStatsPkts128to255Octets: 0
  rmon-tx-etherStatsPkts64Octets: 2
  rmon-tx-etherStatsPkts65to127Octets: 3
  rmon-tx-etherStatsPkts128to255Octets: 0

Thống kê do người lái xe xác định
---------------------------------

Số liệu thống kê ethtool do trình điều khiển xác định có thể được kết xuất bằng ZZ0000ZZ, ví dụ::

$ ethtool -S ens4u1u1
  Thống kê NIC:
     tx_single_collisions: 0
     tx_multi_collisions: 0

uAPI
=====

giao dịch
---------

Giao diện văn bản ZZ0000ZZ lịch sử cho phép truy cập vào danh sách
của các giao diện cũng như số liệu thống kê của chúng.

Lưu ý rằng mặc dù giao diện này đang sử dụng
ZZ0000ZZ
bên trong nó kết hợp một số lĩnh vực.

sysfs
-----

Mỗi thư mục thiết bị trong sysfs chứa thư mục ZZ0001ZZ (ví dụ:
ZZ0002ZZ) với các tập tin tương ứng với
thành viên của ZZ0000ZZ.

Giao diện đơn giản này thuận tiện đặc biệt trong các ứng dụng bị ràng buộc/nhúng
môi trường không có quyền truy cập vào các công cụ. Tuy nhiên, sẽ không hiệu quả khi
đọc nhiều số liệu thống kê vì nó thực hiện kết xuất đầy đủ nội bộ
ZZ0000ZZ
và chỉ báo cáo số liệu thống kê tương ứng với tệp được truy cập.

Các tập tin Sysfs được ghi lại trong
Tài liệu/ABI/testing/sysfs-class-net-statistics.


liên kết mạng
-------------

ZZ0001ZZ (ZZ0002ZZ) là phương pháp truy cập ưa thích
Số liệu thống kê ZZ0000ZZ.

Thống kê được báo cáo cả trong các phản hồi về thông tin liên kết
yêu cầu (ZZ0000ZZ) và yêu cầu thống kê (ZZ0001ZZ,
khi bit ZZ0002ZZ được đặt trong ZZ0003ZZ của yêu cầu).

netdev (liên kết mạng)
~~~~~~~~~~~~~~~~~~~~~~

Họ liên kết mạng chung ZZ0000ZZ cho phép truy cập nhóm trang và mỗi hàng đợi
số liệu thống kê.

công cụ đạo đức
---------------

Giao diện Ethtool IOCTL cho phép driver báo cáo việc thực hiện
thống kê cụ thể. Trong lịch sử nó cũng đã được sử dụng để báo cáo
số liệu thống kê mà các API khác không tồn tại, như hàng đợi trên mỗi thiết bị
thống kê hoặc thống kê dựa trên tiêu chuẩn (ví dụ RFC 2863).

Thống kê và mã định danh chuỗi của chúng được truy xuất riêng biệt.
Mã định danh thông qua ZZ0000ZZ với ZZ0001ZZ được đặt thành ZZ0002ZZ,
và giá trị thông qua ZZ0003ZZ. Không gian người dùng nên sử dụng ZZ0004ZZ
để lấy số lượng thống kê (ZZ0005ZZ).

ethtool-netlink
---------------

Ethtool netlink là sự thay thế cho giao diện IOCTL cũ hơn.

Thống kê liên quan đến giao thức có thể được yêu cầu trong lệnh get bằng cách cài đặt
cờ ZZ0000ZZ trong ZZ0001ZZ. Hiện tại
số liệu thống kê được hỗ trợ trong các lệnh sau:

-ZZ0000ZZ
  -ZZ0001ZZ
  -ZZ0002ZZ
  -ZZ0003ZZ
  -ZZ0004ZZ

gỡ lỗi
-------

Một số trình điều khiển hiển thị số liệu thống kê bổ sung thông qua ZZ0000ZZ.

cấu trúc rtnl_link_stats64
==========================

.. kernel-doc:: include/uapi/linux/if_link.h
    :identifiers: rtnl_link_stats64

Ghi chú cho tác giả trình điều khiển
====================================

Người lái xe nên báo cáo tất cả số liệu thống kê có thành viên phù hợp trong
ZZ0000ZZ độc quyền
thông qua ZZ0001ZZ. Báo cáo số liệu thống kê tiêu chuẩn như vậy thông qua ethtool
hoặc debugfs sẽ không được chấp nhận.

Người lái xe phải đảm bảo tuân thủ tốt nhất có thể các quy định
ZZ0000ZZ.
Ví dụ xin lưu ý rằng số liệu thống kê lỗi chi tiết phải được
được thêm vào bộ đếm ZZ0001ZZ / ZZ0002ZZ chung.

Cuộc gọi lại ZZ0000ZZ không thể ngủ vì có quyền truy cập
thông qua ZZ0001ZZ. Nếu trình điều khiển có thể ngủ khi truy xuất số liệu thống kê
từ thiết bị, nó sẽ thực hiện việc này một cách không đồng bộ định kỳ và chỉ trả về
một bản sao gần đây từ ZZ0002ZZ. Giao diện kết hợp ngắt Ethtool
cho phép thiết lập tần suất làm mới số liệu thống kê, nếu cần.

Truy xuất số liệu thống kê ethtool là một quá trình đa tòa nhà, các trình điều khiển nên
để giữ số lượng thống kê không đổi để tránh tình trạng chạy đua với
không gian người dùng đang cố gắng đọc chúng.

Thống kê phải tồn tại trong các hoạt động thông thường như đưa giao diện
xuống và lên.

Cấu trúc dữ liệu bên trong hạt nhân
-----------------------------------

Các cấu trúc sau đây nằm bên trong kernel, các thành viên của chúng là
được dịch sang các thuộc tính liên kết mạng khi được kết xuất. Trình điều khiển không được ghi đè
số liệu thống kê họ không báo cáo bằng 0.

- ethtool_pause_stats()
- ethtool_fec_stats()