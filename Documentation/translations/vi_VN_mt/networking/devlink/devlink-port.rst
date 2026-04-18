.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-port.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _devlink_port:

============================
Cổng liên kết nhà phát triển
============================

ZZ0000ZZ là một cổng tồn tại trên thiết bị. Nó có tính logic
điểm vào/ra riêng biệt của thiết bị. Cổng devlink có thể là bất kỳ cổng nào
của nhiều hương vị. Một phiên bản cổng devlink cùng với các thuộc tính cổng
mô tả những gì một cổng đại diện.

Trình điều khiển thiết bị có ý định xuất bản cổng devlink sẽ đặt
thuộc tính cổng devlink và đăng ký cổng devlink.

Các loại cổng Devlink được mô tả dưới đây.

.. list-table:: List of devlink port flavours
   :widths: 33 90

   * - Flavour
     - Description
   * - ``DEVLINK_PORT_FLAVOUR_PHYSICAL``
     - Any kind of physical port. This can be an eswitch physical port or any
       other physical port on the device.
   * - ``DEVLINK_PORT_FLAVOUR_DSA``
     - This indicates a DSA interconnect port.
   * - ``DEVLINK_PORT_FLAVOUR_CPU``
     - This indicates a CPU port applicable only to DSA.
   * - ``DEVLINK_PORT_FLAVOUR_PCI_PF``
     - This indicates an eswitch port representing a port of PCI
       physical function (PF).
   * - ``DEVLINK_PORT_FLAVOUR_PCI_VF``
     - This indicates an eswitch port representing a port of PCI
       virtual function (VF).
   * - ``DEVLINK_PORT_FLAVOUR_PCI_SF``
     - This indicates an eswitch port representing a port of PCI
       subfunction (SF).
   * - ``DEVLINK_PORT_FLAVOUR_VIRTUAL``
     - This indicates a virtual port for the PCI virtual function.

Cổng Devlink có thể có loại khác dựa trên lớp liên kết được mô tả bên dưới.

.. list-table:: List of devlink port types
   :widths: 23 90

   * - Type
     - Description
   * - ``DEVLINK_PORT_TYPE_ETH``
     - Driver should set this port type when a link layer of the port is
       Ethernet.
   * - ``DEVLINK_PORT_TYPE_IB``
     - Driver should set this port type when a link layer of the port is
       InfiniBand.
   * - ``DEVLINK_PORT_TYPE_AUTO``
     - This type is indicated by the user when driver should detect the port
       type automatically.

Bộ điều khiển PCI
-----------------
Trong hầu hết các trường hợp, thiết bị PCI chỉ có một bộ điều khiển. Một bộ điều khiển bao gồm
có thể có nhiều chức năng vật lý, ảo và chức năng con. một chức năng
bao gồm một hoặc nhiều cổng. Cổng này được đại diện bởi eswitch devlink
cổng.

Một thiết bị PCI được kết nối với nhiều CPU hoặc nhiều tổ hợp gốc PCI hoặc một
Tuy nhiên, SmartNIC có thể có nhiều bộ điều khiển. Đối với một thiết bị có nhiều
bộ điều khiển, mỗi bộ điều khiển được phân biệt bằng một số bộ điều khiển duy nhất.
Một eswitch có trên thiết bị PCI hỗ trợ các cổng của nhiều bộ điều khiển.

Một ví dụ về hệ thống có hai bộ điều khiển::

---------------------------------------------------------
                 ZZ0000ZZ
                 ZZ0001ZZ
    ----------- ZZ0002ZZ vf(s) ZZ0003ZZ sf(s) |         |vf(s)| |sf(s)ZZ0006ZZ
    ZZ0007ZZ ZZ0008ZZ
    ZZ0009ZZ=== ZZ0010ZZ______/________/ ZZ0011ZZ___/_______/ |
    ZZ0012ZZ ZZ0013ZZ
    ----------- ZZ0014ZZ control_num=1 (không có eswitch) |
                 ------|----------------------------------------------------------------
                 (dây bên trong)
                       |
                 ---------------------------------------------------------
                 ZZ0015ZZ
                 ZZ0016ZZ
                 | |ctrl-0 ZZ0018ZZ ctrl-0 ZZ0019ZZ ctrl-0 ZZ0020ZZ |
                 | |pf0 ZZ0022ZZ pf0sfN ZZ0023ZZ pf1vfN ZZ0024ZZ |
                 ZZ0025ZZ
                 | |ctrl-1 ZZ0027ZZ ctrl-1 ZZ0028ZZ ctrl-1 ZZ0029ZZ |
                 | |pf0 ZZ0031ZZ pf0sfN ZZ0032ZZ pf1vfN ZZ0033ZZ |
                 ZZ0034ZZ
                 ZZ0035ZZ
                 ZZ0036ZZ
    ----------- ZZ0037ZZ
    ZZ0038ZZ ZZ0039ZZ vf(s) ZZ0040ZZ sf(s) |         |vf(s)| |sf(s)ZZ0043ZZ
    ZZ0044ZZ==ZZ0045ZZ
    ZZ0046ZZ ZZ0047ZZ pf0 ZZ0048ZZ pf1 ZZ0049ZZ
    ----------- ZZ0050ZZ
                 ZZ0051ZZ
                 ZZ0052ZZ
                 ---------------------------------------------------------

Trong ví dụ trên, bộ điều khiển bên ngoài (được xác định bởi số bộ điều khiển = 1)
không có eswitch. Bộ điều khiển cục bộ (được xác định bởi số bộ điều khiển = 0)
có eswitch. Phiên bản Devlink trên bộ điều khiển cục bộ có eswitch
cổng devlink cho cả hai bộ điều khiển.

Cấu hình chức năng
======================

Người dùng có thể định cấu hình một hoặc nhiều thuộc tính chức năng trước khi liệt kê PCI
chức năng. Thông thường, điều đó có nghĩa là người dùng nên cấu hình thuộc tính hàm
trước khi một thiết bị bus cụ thể cho chức năng này được tạo ra. Tuy nhiên, khi
SRIOV được bật, các thiết bị chức năng ảo được tạo trên bus PCI.
Do đó, thuộc tính hàm phải được cấu hình trước khi liên kết ảo
thiết bị chức năng cho người lái xe. Đối với các chức năng phụ, điều này có nghĩa là người dùng nên
cấu hình thuộc tính chức năng cổng trước khi kích hoạt chức năng cổng.

Người dùng có thể đặt địa chỉ phần cứng của chức năng bằng cách sử dụng
Lệnh ZZ0000ZZ. Đối với chức năng cổng Ethernet
điều này có nghĩa là địa chỉ MAC.

Người dùng cũng có thể thiết lập khả năng RoCE của chức năng bằng cách sử dụng
Lệnh ZZ0000ZZ.

Người dùng cũng có thể đặt chức năng này là có thể di chuyển bằng cách sử dụng
Lệnh ZZ0000ZZ.

Người dùng cũng có thể đặt khả năng mã hóa IPsec của chức năng bằng cách sử dụng
Lệnh ZZ0000ZZ.

Người dùng cũng có thể đặt khả năng gói IPsec của chức năng này bằng cách sử dụng
Lệnh ZZ0000ZZ.

Người dùng cũng có thể đặt hàng đợi sự kiện IO tối đa của hàm
sử dụng lệnh ZZ0000ZZ.

Thuộc tính chức năng
====================

Thiết lập địa chỉ MAC
---------------------
Địa chỉ MAC được định cấu hình của PCI VF/SF sẽ được netdevice và rdma sử dụng
thiết bị được tạo cho PCI VF/SF.

- Lấy địa chỉ MAC của VF được xác định bởi chỉ số cổng devlink duy nhất của nó::

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
      chức năng:
        hw_addr 00:00:00:00:00:00

- Đặt địa chỉ MAC của VF được xác định bởi chỉ mục cổng devlink duy nhất của nó::

$ bộ hàm cổng devlink pci/0000:06:00.0/2 hw_addr 00:11:22:33:44:55

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
      chức năng:
        hw_addr 00:11:22:33:44:55

- Lấy địa chỉ MAC của SF được xác định bởi chỉ số cổng devlink duy nhất của nó::

$ cổng devlink hiển thị pci/0000:06:00.0/32768
    pci/0000:06:00.0/32768: gõ eth netdev enp6s0pf0sf88 hương vị pcisf pfnum 0 sfnum 88
      chức năng:
        hw_addr 00:00:00:00:00:00

- Đặt địa chỉ MAC của SF được xác định bởi chỉ mục cổng devlink duy nhất của nó::

$ bộ hàm cổng devlink pci/0000:06:00.0/32768 hw_addr 00:00:00:00:88:88

$ cổng devlink hiển thị pci/0000:06:00.0/32768
    pci/0000:06:00.0/32768: gõ eth netdev enp6s0pf0sf88 hương vị pcisf pfnum 0 sfnum 88
      chức năng:
        hw_addr 00:00:00:00:88:88

Thiết lập khả năng RoCE
-----------------------
Không phải tất cả các VF/SF PCI đều yêu cầu khả năng RoCE.

Khi khả năng RoCE bị tắt, nó sẽ tiết kiệm bộ nhớ hệ thống trên mỗi PCI VF/SF.

Khi người dùng vô hiệu hóa khả năng RoCE cho VF/SF, ứng dụng người dùng không thể gửi hoặc
nhận bất kỳ gói RoCE nào thông qua bảng VF/SF và RoCE GID cho PCI này
sẽ trống rỗng.

Khi khả năng RoCE bị tắt trong thiết bị sử dụng thuộc tính chức năng cổng,
Trình điều khiển VF/SF không thể ghi đè lên nó.

- Nhận khả năng RoCE của thiết bị VF::

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 roce kích hoạt

- Thiết lập khả năng RoCE của thiết bị VF::

$ devlink port chức năng set pci/0000:06:00.0/2 roce vô hiệu hóa

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 roce vô hiệu hóa

thiết lập khả năng di chuyển
----------------------------
Di chuyển trực tiếp là quá trình chuyển một máy ảo đang hoạt động
từ máy chủ vật lý này sang máy chủ vật lý khác mà không làm gián đoạn hoạt động bình thường của nó
hoạt động.

Người dùng muốn PCI VF có thể thực hiện di chuyển trực tiếp cần phải
kích hoạt rõ ràng khả năng di chuyển VF.

Khi người dùng kích hoạt khả năng di chuyển cho VF và HV liên kết trình điều khiển VF với VFIO
với sự hỗ trợ di chuyển, người dùng có thể di chuyển VM với VF này từ một HV sang một HV
cái khác.

Tuy nhiên, khi bật khả năng di chuyển, thiết bị sẽ tắt các tính năng không thể di chuyển được.
được di cư. Do đó, giới hạn có thể di chuyển có thể áp đặt các giới hạn đối với VF, vì vậy hãy để người dùng quyết định.

Ví dụ về LM với cấu hình hàm có thể di chuyển:
- Nhận khả năng di chuyển của thiết bị VF::

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 vô hiệu hóa di chuyển

- Thiết lập khả năng di chuyển của thiết bị VF::

$ chức năng cổng devlink thiết lập pci/0000:06:00.0/2 có thể di chuyển được

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 kích hoạt di chuyển

- Liên kết trình điều khiển VF với VFIO với hỗ trợ di chuyển::

$ echo <pci_id> > /sys/bus/pci/devices/0000:08:00.0/driver/unbind
    $ echo mlx5_vfio_pci > /sys/bus/pci/devices/0000:08:00.0/driver_override
    $ echo <pci_id> > /sys/bus/pci/devices/0000:08:00.0/driver/bind

Đính kèm VF vào VM.
Khởi động máy ảo.
Thực hiện di chuyển trực tiếp.

Thiết lập khả năng mã hóa IPsec
-------------------------------
Khi người dùng kích hoạt khả năng mã hóa IPsec cho VF, ứng dụng người dùng có thể giảm tải
Hoạt động mã hóa trạng thái XFRM (Mã hóa/Giải mã) cho VF này.

Khi khả năng mã hóa IPsec bị tắt (mặc định) đối với VF, trạng thái XFRM là
được xử lý trong phần mềm bởi kernel.

- Nhận khả năng mã hóa IPsec của thiết bị VF::

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 ipsec_crypto bị vô hiệu hóa

- Thiết lập khả năng mã hóa IPsec của thiết bị VF::

$ chức năng cổng devlink đặt pci/0000:06:00.0/2 ipsec_crypto kích hoạt

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 ipsec_crypto đã bật

Thiết lập khả năng gói IPsec
-----------------------------
Khi người dùng kích hoạt khả năng gói IPsec cho VF, ứng dụng người dùng có thể giảm tải
Hoạt động mã hóa chính sách và trạng thái XFRM (Mã hóa/Giải mã) cho VF này, cũng như
Đóng gói IPsec.

Khi khả năng gói IPsec bị tắt (mặc định) đối với VF, trạng thái XFRM và
chính sách được xử lý trong phần mềm bởi kernel.

- Nhận khả năng gói IPsec của thiết bị VF::

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 ipsec_packet bị vô hiệu hóa

- Thiết lập khả năng gói IPsec của thiết bị VF::

$ chức năng cổng devlink thiết lập pci/0000:06:00.0/2 ipsec_packet kích hoạt

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 ipsec_packet đã bật

Thiết lập hàng đợi sự kiện IO tối đa
------------------------------------
Khi người dùng đặt số lượng hàng đợi sự kiện IO tối đa cho SF hoặc
một VF, trình điều khiển chức năng như vậy bị giới hạn chỉ sử dụng được thực thi
số lượng hàng đợi sự kiện IO.

Hàng đợi sự kiện IO cung cấp các sự kiện liên quan đến hàng đợi IO, bao gồm cả mạng
hàng đợi truyền và nhận thiết bị (txq và rxq) và Cặp hàng đợi RDMA (QP).
Ví dụ: số lượng kênh netdevice và mức độ hoàn thành của thiết bị RDMA
vectơ được lấy từ hàng đợi sự kiện IO của hàm. Thông thường, số
số vectơ ngắt được trình điều khiển sử dụng bị giới hạn bởi số lượng IO
hàng đợi sự kiện trên mỗi thiết bị, vì mỗi hàng đợi sự kiện IO được kết nối với một
vectơ ngắt.

- Nhận hàng đợi sự kiện IO tối đa của thiết bị VF::

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 ipsec_packet bị vô hiệu hóa max_io_eqs 10

- Đặt hàng đợi sự kiện IO tối đa của thiết bị VF::

$ bộ hàm cổng devlink pci/0000:06:00.0/2 max_io_eqs 32

$ cổng devlink hiển thị pci/0000:06:00.0/2
    pci/0000:06:00.0/2: gõ eth netdev enp6s0pf0vf1 hương vị pcivf pfnum 0 vfnum 1
        chức năng:
            hw_addr 00:00:00:00:00:00 ipsec_packet bị vô hiệu hóa max_io_eqs 32

Chức năng con
=============

Hàm con là một hàm nhẹ có hàm PCI gốc trên đó
nó được triển khai. Chức năng con được tạo và triển khai theo đơn vị 1. Không giống như
SRIOV VF, một chức năng phụ không yêu cầu chức năng ảo PCI của riêng nó.
Một chức năng con giao tiếp với phần cứng thông qua chức năng PCI gốc.

Để sử dụng một chức năng phụ, trình tự thiết lập gồm 3 bước được thực hiện:

1) tạo - tạo chức năng con;
2) cấu hình - cấu hình các thuộc tính chức năng phụ;
3) triển khai - triển khai chức năng con;

Quản lý chức năng phụ được thực hiện bằng giao diện người dùng cổng devlink.
Người dùng thực hiện thiết lập trên thiết bị quản lý chức năng phụ.

(1) Tạo
----------
Một chức năng con được tạo bằng giao diện cổng devlink. Một người dùng thêm
chức năng phụ bằng cách thêm một cổng liên kết phát triển của chức năng phụ. liên kết nhà phát triển
mã hạt nhân gọi xuống trình điều khiển quản lý chức năng con (devlink ops) và hỏi
nó để tạo một cổng liên kết nhà phát triển chức năng phụ. Trình điều khiển sau đó sẽ khởi tạo
cổng chức năng phụ và mọi đối tượng liên quan như phóng viên y tế và
đại diện netdevice.

(2) Cấu hình
-------------
Một cổng liên kết nhà phát triển chức năng con được tạo nhưng nó chưa hoạt động. Điều đó có nghĩa là
các thực thể được tạo ở phía devlink, đại diện cổng e-switch được tạo,
nhưng bản thân thiết bị chức năng phụ không được tạo. Người dùng có thể sử dụng cổng e-switch
đại diện để thực hiện cài đặt, đưa nó vào cầu nối, thêm quy tắc TC, v.v. Người dùng
cũng có thể định cấu hình địa chỉ phần cứng (chẳng hạn như địa chỉ MAC) của
chức năng phụ trong khi chức năng phụ không hoạt động.

(3) Triển khai
--------------
Khi một chức năng phụ được cấu hình, người dùng phải kích hoạt nó để sử dụng nó. Khi
kích hoạt, trình điều khiển quản lý chức năng phụ sẽ yêu cầu quản lý chức năng phụ
thiết bị để khởi tạo thiết bị chức năng phụ trên chức năng PCI cụ thể.
Một thiết bị chức năng phụ được tạo trên ZZ0000ZZ.
Tại thời điểm này, trình điều khiển chức năng phụ phù hợp sẽ liên kết với thiết bị phụ trợ của chức năng phụ.

Đánh giá quản lý đối tượng
==========================

Devlink cung cấp API để quản lý tốc độ tx của một cổng hoặc một nhóm liên kết phát triển.
Điều này được thực hiện thông qua các đối tượng xếp hạng, có thể là một trong hai loại:

ZZ0000ZZ
  Đại diện cho một cổng liên kết phát triển duy nhất; được tạo/hủy bởi trình điều khiển. Vì lá
  có ánh xạ 1to1 tới cổng devlink của nó, trong không gian người dùng, nó được gọi là
  ZZ0001ZZ;

ZZ0000ZZ
  Đại diện cho một nhóm đối tượng tỷ lệ (lá và/hoặc nút); được tạo/xóa bởi
  yêu cầu từ không gian người dùng; ban đầu trống (không có đối tượng đánh giá nào được thêm vào). trong
  không gian người dùng, nó được gọi là ZZ0001ZZ, trong đó
  ZZ0002ZZ có thể là bất kỳ mã định danh nào, ngoại trừ số thập phân, để tránh
  va chạm với lá cây.

API cho phép cấu hình các thông số của đối tượng đánh giá sau:

ZZ0000ZZ
  Giá trị tốc độ TX tối thiểu được chia sẻ giữa tất cả các đối tượng tỷ lệ khác hoặc đối tượng tỷ lệ
  phần đó của nhóm mẹ, nếu nó là một phần của cùng một nhóm.

ZZ0000ZZ
  Giá trị tốc độ TX tối đa.

ZZ0000ZZ
  Cho phép sử dụng trọng tài ưu tiên nghiêm ngặt giữa anh chị em. Cái này
  sơ đồ trọng tài cố gắng lên lịch cho các nút dựa trên mức độ ưu tiên của chúng
  miễn là các nút vẫn nằm trong giới hạn băng thông của chúng. càng cao thì
  mức độ ưu tiên thì xác suất nút đó sẽ được chọn càng cao
  lập kế hoạch.

ZZ0000ZZ
  Cho phép sử dụng sơ đồ trọng tài Xếp hàng công bằng có trọng số giữa các
  anh chị em. Cơ chế trọng tài này có thể được sử dụng đồng thời với
  ưu tiên nghiêm ngặt. Khi một nút được cấu hình với tốc độ cao hơn, nó sẽ nhận được nhiều hơn
  BW so với anh chị em của nó. Các giá trị mang tính tương đối như phần trăm
  điểm, về cơ bản chúng cho biết nút BW sẽ lấy bao nhiêu so với
  anh chị em của nó.

ZZ0000ZZ
  Tên nút cha. Giới hạn tốc độ của nút gốc được coi là giới hạn bổ sung
  tới tất cả các giới hạn của nút con. ZZ0001ZZ là giới hạn trên dành cho trẻ em.
  ZZ0002ZZ là tổng băng thông được phân bổ cho trẻ em.

ZZ0000ZZ
  Cho phép người dùng đặt phân bổ băng thông cho mỗi loại lưu lượng theo tỷ lệ
  đồ vật. Điều này cho phép cấu hình QoS chi tiết bằng cách chỉ định một
  chia sẻ giá trị cho mỗi lớp lưu lượng. Băng thông được phân bổ theo tỷ lệ
  giá trị cổ phiếu của mỗi loại, tương ứng với tổng của tất cả các cổ phiếu.
  Khi được áp dụng cho nút không phải lá, tc_bw xác định cách chia sẻ băng thông
  giữa các phần tử con của nó.

ZZ0000ZZ và ZZ0001ZZ có thể được sử dụng đồng thời. Trong trường hợp đó
các nút có cùng mức độ ưu tiên tạo thành nhóm con WFQ trong nhóm anh chị em
và việc phân xử giữa chúng dựa trên trọng số được chỉ định.

Luồng trọng tài từ cấp cao:

#. Chọn một nút hoặc nhóm nút có mức độ ưu tiên cao nhất
   trong giới hạn BW và không bị chặn. Sử dụng ZZ0000ZZ làm
   tham số cho trọng tài này.

#. Nếu nhóm nút có cùng mức độ ưu tiên, hãy thực hiện phân xử WFQ trên
   nhóm con đó. Sử dụng ZZ0000ZZ làm tham số cho việc phân xử này.

#. Chọn nút chiến thắng và tiếp tục luồng trọng tài giữa các nút con của nó,
   cho đến khi đạt được nút lá và người chiến thắng được xác định.

#. Nếu tất cả các nút từ nhóm con có mức độ ưu tiên cao nhất đều được thỏa mãn, hoặc
   sử dụng quá mức BW được chỉ định của họ, hãy chuyển đến các nút có mức độ ưu tiên thấp hơn.

Việc triển khai trình điều khiển được phép hỗ trợ cả hai hoặc xếp hạng các loại đối tượng
và phương pháp thiết lập các thông số của chúng. Ngoài ra việc triển khai trình điều khiển
có thể xuất các nút/lá và mối quan hệ con-cha của chúng.

Điều khoản và định nghĩa
========================

.. list-table:: Terms and Definitions
   :widths: 22 90

   * - Term
     - Definitions
   * - ``PCI device``
     - A physical PCI device having one or more PCI buses consists of one or
       more PCI controllers.
   * - ``PCI controller``
     -  A controller consists of potentially multiple physical functions,
        virtual functions and subfunctions.
   * - ``Port function``
     -  An object to manage the function of a port.
   * - ``Subfunction``
     -  A lightweight function that has parent PCI function on which it is
        deployed.
   * - ``Subfunction device``
     -  A bus device of the subfunction, usually on a auxiliary bus.
   * - ``Subfunction driver``
     -  A device driver for the subfunction auxiliary device.
   * - ``Subfunction management device``
     -  A PCI physical function that supports subfunction management.
   * - ``Subfunction management driver``
     -  A device driver for PCI physical function that supports
        subfunction management using devlink port interface.
   * - ``Subfunction host driver``
     -  A device driver for PCI physical function that hosts subfunction
        devices. In most cases it is same as subfunction management driver. When
        subfunction is used on external controller, subfunction management and
        host drivers are different.