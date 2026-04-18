.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/vxlan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================
Tài liệu về Mạng cục bộ có thể mở rộng ảo
===========================================================

Giao thức VXLAN là giao thức đường hầm được thiết kế để giải quyết
vấn đề về ID VLAN bị giới hạn (4096) trong IEEE 802.1q.  Với VXLAN,
kích thước của mã định danh được mở rộng lên 24 bit (16777216).

VXLAN được mô tả bởi IETF RFC 7348 và được triển khai bởi một
số lượng nhà cung cấp.  Giao thức chạy trên UDP bằng cách sử dụng một
cảng đích.  Tài liệu này mô tả đường hầm nhân Linux
thiết bị, cũng có một triển khai riêng của VXLAN cho
Openvswitch.

Không giống như hầu hết các đường hầm, VXLAN là mạng 1 đến N, không chỉ trỏ tới
điểm. Thiết bị VXLAN có thể tìm hiểu địa chỉ IP của điểm cuối khác
hoặc linh hoạt theo cách tương tự như cầu nối học tập hoặc tạo ra
sử dụng các mục chuyển tiếp được cấu hình tĩnh.

Việc quản lý vxlan được thực hiện theo cách tương tự như hai cách gần nhất của nó
hàng xóm GRE và VLAN. Cấu hình VXLAN yêu cầu phiên bản
iproute2 phù hợp với bản phát hành kernel nơi VXLAN được hợp nhất lần đầu tiên
thượng nguồn.

1. Tạo thiết bị vxlan::

Liên kết # ip thêm vxlan0 loại vxlan id 42 nhóm 239.1.1.1 dev eth1 dstport 4789

Điều này tạo ra một thiết bị mới có tên vxlan0.  Thiết bị sử dụng multicast
nhóm 239.1.1.1 trên eth1 để xử lý lưu lượng truy cập không có
mục trong bảng chuyển tiếp.  Số cổng đích được đặt thành
giá trị được gán cho IANA là 4789. Việc triển khai VXLAN trên Linux
ghi trước ngày lựa chọn số cổng đích tiêu chuẩn của IANA
và sử dụng giá trị do Linux chọn theo mặc định để duy trì ngược
khả năng tương thích.

2. Xóa thiết bị vxlan::

Liên kết # ip xóa vxlan0

3. Hiển thị thông tin vxlan::

# ip -d hiển thị liên kết vxlan0

Có thể tạo, hủy và hiển thị vxlan
bảng chuyển tiếp bằng lệnh cầu mới.

1. Tạo mục bảng chuyển tiếp::

# bridge fdb thêm vào 00:17:42:8a:b4:05 dst 192.19.0.2 dev vxlan0

2. Xóa mục bảng chuyển tiếp::

# bridge fdb xóa 00:17:42:8a:b4:05 dev vxlan0

3. Hiển thị bảng chuyển tiếp::

# bridge fdb hiển thị dev vxlan0

Các tính năng NIC sau đây có thể biểu thị sự hỗ trợ cho UDP liên quan đến đường hầm
giảm tải (phổ biến nhất là các tính năng VXLAN, nhưng hỗ trợ cho một tính năng cụ thể
giao thức đóng gói là NIC cụ thể):

-ZZ0000ZZ
 -ZZ0001ZZ
    khả năng thực hiện giảm tải phân đoạn TCP của các khung được đóng gói UDP

-ZZ0000ZZ
    nhận phân tích cú pháp bên của các khung được đóng gói UDP cho phép các NIC
    thực hiện giảm tải nhận biết giao thức, như giảm tải xác thực tổng kiểm tra của
    các khung bên trong (chỉ cần bởi các NIC không có giảm tải bất khả tri về giao thức)

Đối với các thiết bị hỗ trợ ZZ0000ZZ, danh sách hiện tại
các cổng đã giảm tải có thể được thẩm vấn bằng ZZ0001ZZ::

$ ethtool --show-tunnels eth0
  Thông tin đường hầm cho eth0:
    Bảng cổng UDP 0:
      Kích thước: 4
      Các loại: vxlan
      Không có mục nào
    Bảng cổng UDP 1:
      Kích thước: 4
      Các loại: Geneve, vxlan-gpe
      Bài viết (1):
          cổng 1230, vxlan-gpe