.. SPDX-License-Identifier: GPL-2.0 OR Linux-OpenIB

.. include:: ../../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/mellanox/mlx5/switchdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

==========
chuyển đổi
==========

:Bản quyền: ZZ0000ZZ 2023, NVIDIA CORPORATION & AFFILIATES. Mọi quyền được bảo lưu.

.. _mlx5_bridge_offload:

Giảm tải cầu
==============

Trình điều khiển mlx5 triển khai hỗ trợ giảm tải các quy tắc cầu nối khi ở trong switchdev
chế độ. FDB cầu nối Linux được tự động giảm tải khi chuyển đổi mlx5
người đại diện được gắn vào cây cầu.

- Chuyển thiết bị sang chế độ switchdev::

$ devlink dev eswitch set pci/0000:06:00.0 mode switchdev

- Đính kèm đại diện switchdev mlx5 'enp8s0f0' vào bridge netdev 'bridge1'::

$ ip link set enp8s0f0 master bridge1

Vlan
-----

Các chức năng VLAN của cầu nối sau được hỗ trợ bởi mlx5:

- Lọc VLAN (bao gồm nhiều Vlan trên mỗi cổng)::

$ ip link set bridge1 loại bridge vlan_filtering 1
    $ bridge vlan thêm dev enp8s0f0 vid 2-3

- VLAN đẩy vào cầu::

$ bridge vlan add dev enp8s0f0 vid 3 pvid

- VLAN bật lên ở lối ra cầu::

$ bridge vlan add dev enp8s0f0 vid 3 chưa được gắn thẻ

Chức năng con
=============

Chức năng con được sinh ra trên E-switch chỉ được tạo bằng devlink
thiết bị và theo mặc định tất cả các thiết bị phụ trợ SF đều bị tắt.
Điều này sẽ cho phép người dùng định cấu hình SF trước khi SF được thăm dò đầy đủ,
sẽ tiết kiệm thời gian.

Ví dụ sử dụng:

- Tạo SF::

$ cổng devlink thêm pci/0000:08:00.0 hương vị pcisf pfnum 0 sfnum 11
    $ chức năng cổng devlink thiết lập pci/0000:08:00.0/32768 hw_addr 00:00:00:00:00:11 trạng thái hoạt động

- Kích hoạt thiết bị phụ trợ ETH::

$ devlink dev param đặt tên phụ trợ/mlx5_core.sf.1 kích hoạt_eth giá trị true cmode driverinit

- Bây giờ, để thăm dò đầy đủ SF, hãy sử dụng devlink loading::

$ devlink dev tải lại phụ trợ/mlx5_core.sf.1

mlx5 hỗ trợ các thông số liên kết phát triển thiết bị phụ trợ ETH,rdma và vdpa (vnet) (xem ZZ0000ZZ).

mlx5 hỗ trợ quản lý chức năng phụ bằng giao diện cổng devlink (xem ZZ0000ZZ).

Một chức năng con có khả năng chức năng riêng và tài nguyên riêng. Cái này
có nghĩa là một hàm con có hàng đợi chuyên dụng riêng (txq, rxq, cq, eq). Những cái này
hàng đợi không được chia sẻ cũng như không bị đánh cắp khỏi hàm PCI gốc.

Khi một chức năng con có khả năng RDMA, nó có bảng QP1, GID và RDMA riêng
tài nguyên không được chia sẻ hoặc bị đánh cắp từ hàm PCI gốc.

Một chức năng con có một cửa sổ chuyên dụng trong không gian PCI BAR không được chia sẻ
với các hàm con khác hoặc hàm PCI gốc. Điều này đảm bảo rằng tất cả
các thiết bị (netdev, rdma, vdpa, v.v.) của các quyền truy cập chức năng phụ chỉ được chỉ định
Không gian PCI BAR.

Một chức năng con hỗ trợ biểu diễn eswitch thông qua đó nó hỗ trợ tc
giảm tải. Người dùng cấu hình eswitch để gửi/nhận gói tin từ/đến
cổng chức năng phụ.

Các chức năng con chia sẻ tài nguyên cấp PCI chẳng hạn như IRQ PCI MSI-X với
các chức năng con khác và/hoặc với chức năng PCI gốc của nó.

Ví dụ về phần mềm, hệ thống và chế độ xem thiết bị mlx5::

_______
      ZZ0000ZZ
      ZZ0001ZZ----------
      ZZ0002ZZ |
          ZZ0003ZZ
      ____ZZ0004ZZ______ _________________
     ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
     ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ
     ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ
     ZZ0014ZZ ZZ0015ZZ_________________|
           ZZ0016ZZ ZZ0017ZZ
           ZZ0018ZZ ZZ0019ZZ Không gian người dùng
 +--------ZZ0020ZZ-------------------ZZ0021ZZ--------------------+
           ZZ0022ZZ +----------+ +----------+ Hạt nhân
           ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ
           ZZ0026ZZ +----------+ +----------+
   (thêm/del cổng devlink | ^ ^
    bộ chức năng cổng) ZZ0027ZZ |
           ZZ0028ZZ +--------------|
      _____ZZ0029ZZ ZZ0030ZZ_______
     ZZ0031ZZ ZZ0032ZZ ZZ0033ZZ
     ZZ0034ZZ +-------------+ Trình điều khiển ZZ0035ZZ |
     ZZ0036ZZ ZZ0037ZZ ZZ0038ZZ(mlx5_core,ib) |
     ZZ0039ZZ +-------------+ ZZ0040ZZ_______________|
           ZZ0041ZZ |               ^
   (devlink ops) ZZ0042ZZ (thăm dò/gỡ bỏ)
  _________ZZ0043ZZ ZZ0044ZZ________
 Chức năng con ZZ0045ZZ ZZ0046ZZ |
 ZZ0047ZZ------ ZZ0048ZZ---ZZ0049ZZ
 ZZ0050ZZ ZZ0051ZZ ZZ0052ZZ
 ZZ0053ZZ +--------------+ ZZ0054ZZ
           |                                            ^
  (sf add/del, sự kiện vhca) |
           |                                      (thêm/xóa thiết bị)
      _____ZZ0055ZZ________
     ZZ0056ZZ ZZ0057ZZ
     ZZ0058ZZ--- kích hoạt/hủy kích hoạt sự kiện--->ZZ0059ZZ
     ZZ0060ZZ ZZ0061ZZ
                                                   ZZ0062ZZ

Chức năng con được tạo bằng giao diện cổng devlink.

- Chuyển thiết bị sang chế độ switchdev::

$ devlink dev eswitch set pci/0000:06:00.0 mode switchdev

- Thêm cổng devlink của chức năng phụ::

$ cổng devlink thêm pci/0000:06:00.0 hương vị pcisf pfnum 0 sfnum 88
    pci/0000:06:00.0/32768: gõ eth netdev eth6 hương vị bộ điều khiển pcisf 0 pfnum 0 sfnum 88 sai bên ngoài có thể chia tách sai
      chức năng:
        hw_addr 00:00:00:00:00:00 trạng thái không hoạt động được tách ra

- Hiển thị cổng devlink của hàm con::

$ cổng devlink hiển thị pci/0000:06:00.0/32768
    pci/0000:06:00.0/32768: gõ eth netdev enp6s0pf0sf88 hương vị pcisf pfnum 0 sfnum 88
      chức năng:
        hw_addr 00:00:00:00:00:00 trạng thái không hoạt động được tách ra

- Xóa một cổng devlink của chức năng con sau khi sử dụng::

$ cổng devlink del pci/0000:06:00.0/32768

Thuộc tính chức năng
====================

Trình điều khiển mlx5 cung cấp cơ chế thiết lập các thuộc tính chức năng PCI VF/SF trong
một cách thống nhất cho SmartNIC và không phải SmartNIC.

Điều này chỉ được hỗ trợ khi chế độ eswitch được đặt thành switchdev. Chức năng cổng
cấu hình của PCI VF/SF được hỗ trợ thông qua cổng eswitch devlink.

Các thuộc tính chức năng cổng phải được đặt trước khi PCI VF/SF được liệt kê bởi
người lái xe.

Thiết lập địa chỉ MAC
---------------------

Trình điều khiển mlx5 hỗ trợ chức năng cổng devlink cơ chế attr để thiết lập MAC
địa chỉ. (tham khảo Tài liệu/mạng/devlink/devlink-port.rst)

Thiết lập khả năng RoCE
~~~~~~~~~~~~~~~~~~~~~~~
Không phải tất cả các thiết bị/SF mlx5 PCI đều yêu cầu khả năng RoCE.

Khi khả năng RoCE bị vô hiệu hóa, nó sẽ tiết kiệm được 1 Mbyte bộ nhớ hệ thống cho mỗi
Thiết bị PCI/SF.

Trình điều khiển mlx5 hỗ trợ chức năng cổng devlink cơ chế attr để thiết lập RoCE
khả năng. (tham khảo Tài liệu/mạng/devlink/devlink-port.rst)

thiết lập khả năng di chuyển
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Người dùng muốn VF mlx5 PCI có thể thực hiện di chuyển trực tiếp cần phải
kích hoạt rõ ràng khả năng di chuyển VF.

Trình điều khiển mlx5 hỗ trợ chức năng cổng devlink cơ chế attr để thiết lập có thể di chuyển
khả năng. (tham khảo Tài liệu/mạng/devlink/devlink-port.rst)

Thiết lập khả năng mã hóa IPsec
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Người dùng muốn VF mlx5 PCI có thể thực hiện việc giảm tải mật mã IPsec cần
để kích hoạt rõ ràng khả năng VF ipsec_crypto. Kích hoạt khả năng IPsec
dành cho VF được hỗ trợ bắt đầu với các thiết bị ConnectX6dx trở lên. Khi VF có
Khả năng IPsec được bật, mọi hoạt động giảm tải IPsec đều bị chặn trên PF.

Trình điều khiển mlx5 hỗ trợ chức năng cổng devlink cơ chế attr để thiết lập ipsec_crypto
khả năng. (tham khảo Tài liệu/mạng/devlink/devlink-port.rst)

Thiết lập khả năng gói IPsec
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Người dùng muốn VF mlx5 PCI có thể thực hiện việc giảm tải gói IPsec cần
để kích hoạt rõ ràng khả năng VF ipsec_packet. Kích hoạt khả năng IPsec
dành cho VF được hỗ trợ bắt đầu với các thiết bị ConnectX6dx trở lên. Khi VF có
Khả năng IPsec được bật, mọi hoạt động giảm tải IPsec đều bị chặn trên PF.

Trình điều khiển mlx5 hỗ trợ chức năng cổng devlink cơ chế attr để thiết lập ipsec_packet
khả năng. (tham khảo Tài liệu/mạng/devlink/devlink-port.rst)

Thiết lập trạng thái SF
-----------------------

Để sử dụng SF, người dùng phải kích hoạt SF bằng trạng thái chức năng SF
thuộc tính.

- Lấy trạng thái của SF được xác định bởi chỉ số cổng devlink duy nhất của nó::

$ cổng devlink hiển thị ens2f0npf0sf88
   pci/0000:06:00.0/32768: gõ eth netdev ens2f0npf0sf88 hương vị bộ điều khiển pcisf 0 pfnum 0 sfnum 88 sai bên ngoài có thể chia tách sai
     chức năng:
       hw_addr 00:00:00:00:88:88 trạng thái không hoạt động được tách ra

- Kích hoạt chức năng và xác minh trạng thái của nó đang hoạt động::

$ chức năng cổng devlink thiết lập trạng thái ens2f0npf0sf88 hoạt động

$ cổng devlink hiển thị ens2f0npf0sf88
   pci/0000:06:00.0/32768: gõ eth netdev ens2f0npf0sf88 hương vị bộ điều khiển pcisf 0 pfnum 0 sfnum 88 sai bên ngoài có thể chia tách sai
     chức năng:
       hw_addr 00:00:00:00:88:88 trạng thái hoạt động opstate tách ra

Khi kích hoạt chức năng, phiên bản trình điều khiển PF sẽ nhận sự kiện từ thiết bị
rằng một SF cụ thể đã được kích hoạt. Đó là tín hiệu đưa thiết bị lên xe buýt, thăm dò
nó và khởi tạo phiên bản devlink và các thiết bị phụ trợ dành riêng cho lớp
cho nó.

- Hiển thị thiết bị phụ trợ và cổng của chức năng phụ::

chương trình phát triển $ devlink
    devlink dev hiển thị phụ trợ/mlx5_core.sf.4

$ cổng devlink hiển thị phụ trợ/mlx5_core.sf.4/1
    phụ trợ/mlx5_core.sf.4/1: gõ eth netdev p0sf88 cổng ảo hương vị 0 có thể chia sai

$ rdma liên kết hiển thị mlx5_0/1
    liên kết trạng thái mlx5_0/1 ACTIVE vật lý_state LINK_UP netdev p0sf88

chương trình phát triển $rdma
    8: rocept6s0f1: node_type ca fw 16.29.0550 node_guid 248a:0703:00b3:d113 sys_image_guid 248a:0703:00b3:d112
    13: mlx5_0: node_type ca fw 16.29.0550 node_guid 0000:00ff:fe00:8888 sys_image_guid 248a:0703:00b3:d112

- Phân cấp thiết bị phụ trợ chức năng và phân cấp thiết bị lớp::

mlx5_core.sf.4
          (thiết bị phụ trợ chức năng phụ)
                       /\
                      / \
                     / \
                    / \
                   / \
      mlx5_core.eth.4 mlx5_core.rdma.4
     (sf eth aux dev) (sf rdma aux dev)
         ZZ0000ZZ
         ZZ0001ZZ
      p0sf88 mlx5_0
     (sf netdev) (thiết bị sf rdma)

Ngoài ra, cổng SF còn nhận được sự kiện khi driver gắn vào
thiết bị phụ trợ của chức năng phụ. Điều này dẫn đến việc thay đổi cách thức hoạt động
trạng thái của hàm. Điều này cung cấp khả năng hiển thị cho người dùng để quyết định khi nào
an toàn để xóa cổng SF để chấm dứt chức năng phụ một cách nhẹ nhàng.

- Hiển thị trạng thái hoạt động của cổng SF::

$ cổng devlink hiển thị ens2f0npf0sf88
    pci/0000:06:00.0/32768: gõ eth netdev ens2f0npf0sf88 hương vị bộ điều khiển pcisf 0 pfnum 0 sfnum 88 sai bên ngoài có thể chia tách sai
      chức năng:
        hw_addr 00:00:00:00:88:88 đính kèm trạng thái hoạt động opstate