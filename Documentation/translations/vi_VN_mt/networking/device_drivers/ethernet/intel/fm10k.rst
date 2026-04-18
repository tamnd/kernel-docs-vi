.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/intel/fm10k.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================================
Trình điều khiển cơ sở Linux cho Bộ điều khiển đa máy chủ Ethernet Intel(R)
===========================================================================

Ngày 20 tháng 8 năm 2018
Bản quyền(c) 2015-2018 Tập đoàn Intel.

Nội dung
========
- Xác định bộ chuyển đổi của bạn
- Cấu hình bổ sung
- Điều chỉnh hiệu suất
- Các vấn đề đã biết
- Hỗ trợ

Xác định bộ điều hợp của bạn
========================
Trình điều khiển trong phiên bản này tương thích với các thiết bị dựa trên Intel(R)
Bộ điều khiển đa máy chủ Ethernet.

Để biết thông tin về cách xác định bộ điều hợp của bạn và để có phiên bản Intel mới nhất
trình điều khiển mạng, hãy tham khảo trang web Hỗ trợ của Intel:
ZZ0000ZZ


Kiểm soát dòng chảy
------------
Trình điều khiển giao diện máy chủ chuyển mạch Ethernet Intel(R) không hỗ trợ Flow
Kiểm soát. Nó sẽ không gửi các khung tạm dừng. Điều này có thể dẫn đến hiện tượng rớt khung hình.


Hàm ảo (VF)
-----------------------
Sử dụng sysfs để kích hoạt VF.
Phạm vi hợp lệ: 0-64

Ví dụ::

echo $num_vf_enabled > /sys/class/net/$dev/device/sriov_numvfs //bật VF
    echo 0 > /sys/class/net/$dev/device/sriov_numvfs // vô hiệu hóa VF

NOTE: Cả thiết bị và trình điều khiển đều không kiểm soát cách ánh xạ VF vào cấu hình
không gian. Bố cục xe buýt sẽ thay đổi tùy theo hệ điều hành. Trên các hệ điều hành có
hỗ trợ nó, bạn có thể kiểm tra sysfs để tìm ánh xạ.

NOTE: Khi chế độ SR-IOV được bật, bộ lọc VLAN phần cứng và thẻ VLAN
tính năng tước/chèn sẽ vẫn được bật. Vui lòng loại bỏ bộ lọc VLAN cũ
trước khi bộ lọc VLAN mới được thêm vào. Ví dụ::

liên kết ip đặt eth0 vf 0 vlan 100 // đặt vlan 100 cho VF 0
    liên kết ip được đặt eth0 vf 0 vlan 0 // Xóa vlan 100
    ip link set eth0 vf 0 vlan 200 // đặt vlan 200 mới cho VF 0


Các tính năng và cấu hình bổ sung
======================================

Khung Jumbo
------------
Hỗ trợ Khung Jumbo được bật bằng cách thay đổi Đơn vị truyền tối đa (MTU)
đến giá trị lớn hơn giá trị mặc định là 1500.

Sử dụng lệnh ifconfig để tăng kích thước MTU. Ví dụ: nhập
sau đây trong đó <x> là số giao diện::

ifconfig eth<x> mtu 9000 trở lên

Ngoài ra, bạn có thể sử dụng lệnh ip như sau ::

bộ liên kết ip mtu 9000 dev eth<x>
    liên kết ip thiết lập dev eth<x>

Cài đặt này không được lưu trong các lần khởi động lại. Việc thay đổi cài đặt có thể được thực hiện
vĩnh viễn bằng cách thêm 'MTU=9000' vào tệp:

- Đối với RHEL: /etc/sysconfig/network-scripts/ifcfg-eth<x>
- Đối với SLES: /etc/sysconfig/network/<config_file>

NOTE: Cài đặt MTU tối đa cho Khung Jumbo là 15342. Giá trị này trùng khớp
với kích thước Khung Jumbo tối đa là 15364 byte.

NOTE: Trình điều khiển này sẽ cố gắng sử dụng nhiều bộ đệm có kích thước trang để nhận
mỗi gói lớn. Điều này sẽ giúp tránh được vấn đề thiếu bộ đệm khi
phân bổ các gói nhận.


Giảm tải nhận chung, hay còn gọi là GRO
--------------------------------
Trình điều khiển hỗ trợ triển khai phần mềm trong kernel của GRO. GRO có
đã chỉ ra rằng bằng cách kết hợp lưu lượng Rx thành các khối dữ liệu lớn hơn, CPU
việc sử dụng có thể giảm đáng kể khi chịu tải Rx lớn. GRO là một
sự phát triển của giao diện LRO được sử dụng trước đây. GRO có thể kết hợp lại
các giao thức khác ngoài TCP. Nó cũng an toàn khi sử dụng với các cấu hình
là vấn đề đối với LRO, cụ thể là cầu nối và iSCSI.



Các lệnh và tùy chọn ethtool được hỗ trợ để lọc
----------------------------------------------------
-n --show-nfc
  Truy xuất cấu hình phân loại luồng mạng nhận.

rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|tcp6|udp6|ah6|esp6|sctp6
  Truy xuất các tùy chọn băm cho loại lưu lượng mạng được chỉ định.

-N --config-nfc
  Định cấu hình phân loại luồng mạng nhận.

rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r
  Định cấu hình các tùy chọn băm cho loại lưu lượng mạng được chỉ định.

- udp4: UDP qua IPv4
- udp6: UDP qua IPv6
- f Băm byte 0 và 1 của tiêu đề Lớp 4 của gói rx.
- n Băm byte 2 và 3 của tiêu đề Lớp 4 của gói rx.


Sự cố đã biết/Khắc phục sự cố
============================

Kích hoạt SR-IOV trong hệ điều hành khách Microsoft Windows Server 2012/R2 64-bit trong Linux KVM
-------------------------------------------------------------------------------------
KVM Hypervisor/VMM hỗ trợ gán trực tiếp thiết bị PCIe cho VM. Cái này
bao gồm các thiết bị PCIe truyền thống cũng như các thiết bị hỗ trợ SR-IOV dựa trên
Bộ điều khiển Ethernet Intel XL710.


Ủng hộ
=======
Để biết thông tin chung, hãy truy cập trang web hỗ trợ của Intel tại:
ZZ0000ZZ

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến sự cố
tới intel-wired-lan@lists.osuosl.org.