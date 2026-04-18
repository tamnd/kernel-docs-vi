.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/freescale/dpaa2/switch-driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=====================
Trình điều khiển chuyển đổi DPAA2
===================

:Bản quyền: ZZ0000ZZ 2021 NXP

Trình điều khiển DPAA2 Switch thăm dò đối tượng Datapath Switch (DPSW) có thể
được khởi tạo trên các SoC DPAA2 sau đây và các biến thể của chúng: LS2088A và
LX2160A.

Trình điều khiển sử dụng mô hình trình điều khiển thiết bị chuyển mạch và hiển thị từng cổng chuyển đổi dưới dạng
một giao diện mạng, có thể được bao gồm trong một cầu nối hoặc được sử dụng như một giao diện độc lập
giao diện. Lưu lượng chuyển đổi giữa các cổng được giảm tải vào phần cứng.

DPSW có thể có các cổng được kết nối với DPNI hoặc DPMAC để truy cập bên ngoài.
::

[ethA] [ethB] [ethC] [ethD] [ethE] [ethF]
            : : : : : :
            : : : : : :
       [dpaa2-eth] [dpaa2-eth] [ dpaa2-switch ]
            : : : : : : hạt nhân
       ====================================================================================
            : : : : : : phần cứng
         [DPNI] [DPNI] [============== DPSW ====================]
            ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
            ZZ0003ZZ [DPMAC] [DPMAC]
             ------------------------------- ZZ0004ZZ
                                                        ZZ0005ZZ
                                                      [PHY] [PHY]

Tạo một bộ chuyển mạch Ethernet
===========================

Trình điều khiển dpaa2-switch thăm dò trên các thiết bị DPSW được tìm thấy trên bus fsl-mc. Những cái này
thiết bị có thể được tạo tĩnh thông qua cấu hình thời gian khởi động
tệp - Bố cục DataPath (DPL) - hoặc trong thời gian chạy bằng API đối tượng DPAA2
(đã được tích hợp vào công cụ không gian người dùng restool).

Hiện tại, trình điều khiển dpaa2-switch áp đặt các hạn chế sau đối với
đối tượng DPSW mà nó sẽ thăm dò:

* Số lượng FDB tối thiểu ít nhất phải bằng số lượng bộ chuyển mạch
   giao diện. Điều này là cần thiết để có thể tách các cổng chuyển mạch
   xong, tức là khi không ở dưới cầu, mỗi cổng switch sẽ có FDB riêng.
   ::

fsl_dpaa2_switch dpsw.0: Số lượng FDB thấp hơn số lượng cổng, không thể thăm dò

* Cả cấu hình phát sóng và phát tràn phải theo FDB. Cái này
   cho phép trình điều khiển hạn chế các miền phát sóng và tràn ngập của từng
   FDB tùy thuộc vào các cổng switch đang chia sẻ nó (còn gọi là nằm dưới
   cùng một cây cầu).
   ::

fsl_dpaa2_switch dpsw.0: Miền tràn ngập không dành cho FDB, không thể thăm dò
        fsl_dpaa2_switch dpsw.0: Miền phát sóng không dành cho FDB, không thể thăm dò

* Không nên tắt giao diện điều khiển của công tắc
   (DPSW_OPT_CTRL_IF_DIS không được thông qua dưới dạng tùy chọn thời gian tạo). Nếu không có
   giao diện điều khiển, trình điều khiển không có khả năng cung cấp lưu lượng Rx/Tx thích hợp
   hỗ trợ trên các cổng chuyển đổi netdevices.
   ::

fsl_dpaa2_switch dpsw.0: Giao diện điều khiển bị tắt, không thể thăm dò

Bên cạnh cấu hình của đối tượng DPSW thực tế, trình điều khiển dpaa2-switch
sẽ cần các đối tượng DPAA2 sau:

* 1 DPMCP - Cần có đối tượng Cổng lệnh quản lý cho mọi tương tác
   với phần mềm MC.

* 1 DPBP - Nhóm bộ đệm được sử dụng để tạo bộ đệm dành cho đường dẫn Rx
   trên giao diện điều khiển.

* Cần có quyền truy cập vào ít nhất một đối tượng DPIO (Cổng phần mềm) cho bất kỳ
   hoạt động enqueue/dequeue được thực hiện trên hàng đợi giao diện điều khiển.
   Đối tượng DPIO sẽ được chia sẻ, không cần có đối tượng riêng tư.

Chuyển đổi tính năng
==================

Trình điều khiển hỗ trợ cấu hình các quy tắc chuyển tiếp L2 trong phần cứng cho
cầu nối cổng cũng như sử dụng độc lập các giao diện chuyển mạch độc lập.

Phần cứng không thể cấu hình được đối với nhận thức về VLAN, do đó mọi DPAA2 đều không thể cấu hình được.
cổng chuyển đổi chỉ nên được sử dụng trong các usecase có cầu nối nhận biết VLAN ::

$ ip link add dev br0 gõ bridge vlan_filtering 1

$ ip link thêm cầu dev br1 loại
        $ ip liên kết đặt dev ethX master br1
        Lỗi: fsl_dpaa2_switch: Không thể tham gia cầu nối VLAN không biết

Cấu trúc liên kết và phát hiện vòng lặp thông qua STP được hỗ trợ khi ZZ0000ZZ được hỗ trợ
được sử dụng tại cầu tạo ::

$ ip link add dev br0 gõ bridge vlan_filtering 1 stp_state 1

Hỗ trợ thao tác L2 FDB (thêm/xóa/kết xuất).

Việc học HW FDB có thể được cấu hình độc lập trên mỗi cổng chuyển đổi thông qua
lệnh cầu. Khi việc học CTNH bị vô hiệu hóa, quy trình lão hóa nhanh sẽ được thực hiện
chạy và mọi địa chỉ đã học trước đó sẽ bị xóa.
::

$ bridge link set dev ethX learning off
        $ bridge link set dev ethX learning on

Hỗ trợ hạn chế miền tràn unicast và multicast không xác định, nhưng
không độc lập với nhau::

$ ip link set dev ethX type bridge_slave lũ tắt mcast_flood off
        $ ip link set dev ethX type bridge_slave lũ lụt tắt mcast_flood trên
        Lỗi: fsl_dpaa2_switch: Không thể định cấu hình phát đa hướng độc lập với unicast.

Có thể tắt/bật tính năng phát tràn lan trên cổng chuyển mạch thông qua brport sysfs::

$ echo 0 > /sys/bus/fsl-mc/devices/dpsw.Y/net/ethX/brport/broadcast_flood

Giảm tải
========

Hành động định tuyến (chuyển hướng, bẫy, thả)
--------------------------------------

Bộ chuyển mạch DPAA2 có thể giảm tải chuyển hướng gói dựa trên luồng.
sử dụng bảng ACL. Các khối bộ lọc chia sẻ được hỗ trợ bằng cách chia sẻ một ACL duy nhất
bảng giữa nhiều cổng.

Các phím luồng sau được hỗ trợ:

* Ethernet: dst_mac/src_mac
 * IPv4: dst_ip/src_ip/ip_proto/tos
 * VLAN: vlan_id/vlan_prio/vlan_tpid/vlan_dei
 * L4: dst_port/src_port

Ngoài ra, bộ lọc matchall có thể được sử dụng để chuyển hướng toàn bộ lưu lượng truy cập nhận được
trên một cảng.

Theo hành động luồng, những điều sau đây được hỗ trợ:

* thả
 * chuyển hướng đi ra được nhân đôi
 * bẫy

Mỗi mục nhập (bộ lọc) ACL chỉ có thể được thiết lập với một trong các mục được liệt kê
hành động.

Ví dụ 1: gửi các khung nhận được trên eth4 với SA là 00:01:02:03:04:05 tới
CPU::

$ tc qdisc thêm dev eth4 clsact
        $ tc bộ lọc thêm dev eth4 ingress hoa src_mac 00:01:02:03:04:05 Skip_sw bẫy hành động

Ví dụ 2: thả các khung nhận được trên eth4 với VID 100 và PCP là 3::

$ tc bộ lọc thêm giao thức xâm nhập dev eth4 802.1q hoa Skip_sw vlan_id 100 vlan_prio 3 hành động thả

Ví dụ 3: chuyển hướng tất cả các khung nhận được trên eth4 sang eth1::

$ tc bộ lọc thêm dev eth4 ingress matchall hành động mirred egress redirect dev eth1

Ví dụ 4: Sử dụng một khối bộ lọc chia sẻ duy nhất trên cả eth5 và eth6::

$ tc qdisc thêm dev eth5 ingress_block 1 clsact
        $ tc qdisc thêm dev eth6 ingress_block 1 clsact
        $ tc bộ lọc thêm khối 1 ingress hoa dst_mac 00:01:02:03:04:04 Skip_sw \
                bẫy hành động
        $ tc bộ lọc thêm khối 1 giao thức xâm nhập ipv4 hoa src_ip 192.168.1.1 Skip_sw \
                hành động chuyển hướng đi ra được nhân đôi dev eth3

Phản chiếu
~~~~~~~~~

Công tắc DPAA2 chỉ hỗ trợ phản chiếu trên mỗi cổng và phản chiếu trên mỗi VLAN.
Việc thêm bộ lọc phản chiếu trong các khối chia sẻ cũng được hỗ trợ.

Khi sử dụng bộ phân loại tc-flower với giao thức 802.1q, chỉ
Khóa ''vlan_id'' sẽ được chấp nhận. Phản chiếu dựa trên bất kỳ trường nào khác từ
Giao thức 802.1q sẽ bị từ chối::

$ tc qdisc thêm dev eth8 ingress_block 1 clsact
        $ tc bộ lọc thêm giao thức xâm nhập khối 1 802.1q hoa Skip_sw vlan_prio 3 hành động nhân đôi gương đi ra dev eth6
        Lỗi: fsl_dpaa2_switch: Chỉ hỗ trợ khớp trên ID VLAN.
        Chúng tôi gặp lỗi khi nói chuyện với kernel

Nếu bộ lọc VLAN phản chiếu được yêu cầu trên một cổng thì VLAN phải được
được cài đặt trên cổng switch được đề cập bằng cách sử dụng '' bridge '' hoặc bằng cách tạo
thiết bị phía trên VLAN nếu cổng chuyển mạch được sử dụng làm giao diện độc lập::

$ tc qdisc thêm dev eth8 ingress_block 1 clsact
        $ tc bộ lọc thêm giao thức xâm nhập khối 1 802.1q hoa Skip_sw vlan_id 200 hành động nhân đôi gương đi ra dev eth6
        Lỗi: VLAN phải được cài đặt trên cổng switch.
        Chúng tôi gặp lỗi khi nói chuyện với kernel

$ cầu vlan thêm vid 200 dev eth8
        $ tc bộ lọc thêm giao thức xâm nhập khối 1 802.1q hoa Skip_sw vlan_id 200 hành động nhân đôi gương đi ra dev eth6

$ ip link thêm link eth8 tên eth8.200 gõ vlan id 200
        $ tc bộ lọc thêm giao thức xâm nhập khối 1 802.1q hoa Skip_sw vlan_id 200 hành động nhân đôi gương đi ra dev eth6

Ngoài ra, cần lưu ý rằng lưu lượng truy cập được nhân đôi sẽ phải chịu cùng một điều kiện
hạn chế đi ra như bất kỳ giao thông khác. Điều này có nghĩa là khi được phản chiếu
gói sẽ đến cổng nhân bản, nếu VLAN được tìm thấy trong gói không
cài đặt trên cổng nó sẽ bị loại bỏ.

Công tắc DPAA2 chỉ hỗ trợ một đích phản chiếu duy nhất, do đó có nhiều
quy tắc nhân bản có thể được cài đặt nhưng cổng ''đến'' của chúng phải giống nhau::

$ tc bộ lọc thêm giao thức xâm nhập khối 1 802.1q hoa Skip_sw vlan_id 200 hành động nhân đôi gương đi ra dev eth6
        $ tc bộ lọc thêm giao thức xâm nhập khối 1 802.1q hoa Skip_sw vlan_id 100 hành động nhân đôi gương đi ra dev eth7
        Lỗi: fsl_dpaa2_switch: Nhiều cổng nhân bản không được hỗ trợ.
        Chúng tôi gặp lỗi khi nói chuyện với kernel