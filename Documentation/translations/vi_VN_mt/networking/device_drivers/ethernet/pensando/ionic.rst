.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/pensando/ionic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================================
Trình điều khiển Linux cho dòng bộ điều hợp Ethernet Pensando(R)
================================================================

Trình điều khiển Ethernet Pensando Linux.
Bản quyền(c) 2019 Pensando Systems, Inc

Nội dung
========

- Nhận dạng Adaptor
- Kích hoạt trình điều khiển
- Cấu hình trình điều khiển
- Hỗ trợ RDMA thông qua thiết bị phụ trợ
- Thống kê
- Hỗ trợ

Xác định bộ chuyển đổi
=======================

Để tìm xem một hoặc nhiều thiết bị Ethernet Pensando PCI có được cài đặt trên
máy chủ, hãy kiểm tra các thiết bị PCI::

$ lspci -d 1dd8:
  b5:00.0 Bộ điều khiển Ethernet: Thiết bị 1dd8:1002
  b6:00.0 Bộ điều khiển Ethernet: Thiết bị 1dd8:1002

Nếu các thiết bị như vậy được liệt kê như trên thì trình điều khiển ionic.ko sẽ tìm
và cấu hình chúng để sử dụng.  Cần có các mục nhật ký trong kernel
những tin nhắn như thế này::

$dmesg | ion grep
  ionic 0000:b5:00.0: Băng thông PCIe khả dụng 126,016 Gb/s (liên kết PCIe x16 8.0 GT/s)
  ion 0000:b5:00.0 enp181s0: được đổi tên từ eth0
  ionic 0000:b5:00.0 enp181s0: Liên kết lên - 100 Gbps
  ionic 0000:b6:00.0: Băng thông PCIe khả dụng 126,016 Gb/s (liên kết PCIe x16 8.0 GT/s)
  ion 0000:b6:00.0 enp182s0: được đổi tên từ eth0
  ionic 0000:b6:00.0 enp182s0: Liên kết lên - 100 Gbps

Thông tin phiên bản trình điều khiển và phần sụn có thể được thu thập bằng một trong hai
công cụ ethtool hoặc devlink::

$ ethtool -i enp181s0
  trình điều khiển: ion
  phiên bản: 5.7.0
  phiên bản phần sụn: 1.8.0-28
  ...

$ devlink thông tin nhà phát triển pci/0000:b5:00.0
  pci/0000:b5:00.0:
    ion điều khiển
    số_sê-ri FLM18420073
    phiên bản:
        đã sửa:
          asic.id 0x0
          asic.rev 0x0
        đang chạy:
          fw 1.8.0-28

Xem Tài liệu/mạng/devlink/ionic.rst để biết thêm thông tin
trên dữ liệu thông tin nhà phát triển devlink.

Kích hoạt trình điều khiển
===================

Trình điều khiển được kích hoạt thông qua hệ thống cấu hình kernel tiêu chuẩn,
sử dụng lệnh tạo ::

tạo oldconfig/menuconfig/etc.

Trình điều khiển nằm trong cấu trúc menu tại:

-> Trình điều khiển thiết bị
    -> Hỗ trợ thiết bị mạng (NETDEVICES [=y])
      -> Hỗ trợ trình điều khiển Ethernet
        -> Thiết bị Pensando
          -> Hỗ trợ Pensando Ethernet IONIC

Cấu hình trình điều khiển
======================

MTU
---

Hỗ trợ khung Jumbo có sẵn với kích thước tối đa là 9194 byte.

Sự kết hợp gián đoạn
--------------------

Việc kết hợp ngắt có thể được cấu hình bằng cách thay đổi giá trị rx-usecs bằng
lệnh "ethtool -C".  Phạm vi rx-usecs là 0-190.  Giá trị tx-usecs
phản ánh giá trị rx-usecs khi chúng được gắn với nhau trên cùng một ngắt.

SR-IOV
------

Hỗ trợ SR-IOV tối thiểu hiện được cung cấp và có thể được bật bằng cách cài đặt
giá trị 'sriov_numvfs' của sysfs, nếu được chương trình cơ sở cụ thể của bạn hỗ trợ
cấu hình.

XDP
---

Hỗ trợ cho XDP bao gồm những điều cơ bản, cộng với khung Jumbo, Chuyển hướng và
ndo_xmit.  Hiện tại không có hỗ trợ nào cho ổ cắm không sao chép hoặc giảm tải CTNH.

Hỗ trợ RDMA thông qua thiết bị phụ trợ
=================================

Trình điều khiển ion hỗ trợ chức năng RDMA (Truy cập bộ nhớ trực tiếp từ xa)
thông qua khung thiết bị phụ trợ Linux khi được phần sụn quảng cáo.
Khả năng RDMA được phát hiện trong quá trình khởi tạo thiết bị và nếu được hỗ trợ,
trình điều khiển ethernet sẽ tạo một thiết bị phụ trợ cho phép RDMA
trình điều khiển để liên kết và cung cấp chức năng InfiniBand/RoCE.

Thống kê
==========

Số liệu thống kê phần cứng cơ bản
--------------------

Các lệnh ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ hiển thị
một bộ số liệu thống kê giới hạn được lấy trực tiếp từ phần sụn.  Ví dụ::

$ ip -s hiển thị liên kết enp181s0
  7: enp181s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq trạng thái Chế độ UP Chế độ mặc định nhóm DEFAULT qlen 1000
      liên kết/ether 00:ae:cd:00:07:68 brd ff:ff:ff:ff:ff:ff
      RX: lỗi gói byte bị bỏ qua mcast
      414 5 0 0 0 0
      TX: lỗi gói byte bị rớt mạng thu thập sóng mang
      1384 18 0 0 0 0

ethtool -S
----------

Số liệu thống kê được hiển thị từ lệnh ZZ0000ZZ bao gồm sự kết hợp của
bộ đếm trình điều khiển và bộ đếm phần sụn, bao gồm các giá trị cụ thể của cổng và hàng đợi.
Các giá trị trình điều khiển là các bộ đếm được trình điều khiển tính toán và các giá trị phần sụn
được tập hợp bởi phần sụn từ phần cứng cổng và được chuyển qua
driver không có giải thích gì thêm.

Cổng trình điều khiển cụ thể::

tx_packets: 12
     tx_byte: 964
     rx_packets: 5
     rx_byte: 414
     tx_tso: 0
     tx_tso_byte: 0
     tx_csum_none: 12
     tx_csum: 0
     rx_csum_none: 0
     rx_csum_complete: 3
     rx_csum_error: 0
     xdp_drop: 0
     xdp_aborted: 0
     xdp_pass: 0
     xdp_tx: 0
     xdp_redirect: 0
     xdp_frames: 0

Hàng đợi trình điều khiển cụ thể::

tx_0_pkts: 3
     tx_0_byte: 294
     tx_0_clean: 3
     tx_0_dma_map_err: 0
     tx_0_tuyến tính hóa: 0
     tx_0_frags: 0
     tx_0_tso: 0
     tx_0_tso_byte: 0
     tx_0_hwstamp_valid: 0
     tx_0_hwstamp_invalid: 0
     tx_0_csum_none: 3
     tx_0_csum: 0
     tx_0_vlan_inserted: 0
     tx_0_xdp_frames: 0
     rx_0_pkts: 2
     rx_0_byte: 120
     rx_0_dma_map_err: 0
     rx_0_alloc_err: 0
     rx_0_csum_none: 0
     rx_0_csum_complete: 0
     rx_0_csum_error: 0
     rx_0_hwstamp_valid: 0
     rx_0_hwstamp_invalid: 0
     rx_0_dropped: 0
     rx_0_vlan_stripped: 0
     rx_0_xdp_drop: 0
     rx_0_xdp_aborted: 0
     rx_0_xdp_pass: 0
     rx_0_xdp_tx: 0
     rx_0_xdp_redirect: 0

Cổng phần mềm cụ thể::

hw_tx_dropped: 0
     hw_rx_dropped: 0
     hw_rx_over_errors: 0
     hw_rx_missed_errors: 0
     hw_tx_aborted_errors: 0
     khung_rx_ok: 15
     khung_rx_all: 15
     khung_rx_bad_fcs: 0
     khung_rx_bad_all: 0
     octet_rx_ok: 1290
     octet_rx_all: 1290
     khung_rx_unicast: 10
     khung_rx_multicast: 5
     khung_rx_broadcast: 0
     khung_rx_pause: 0
     khung_rx_bad_length: 0
     khung_rx_undersize: 0
     khung_rx_quá khổ: 0
     khung_rx_fragments: 0
     khung_rx_jabber: 0
     khung_rx_pripause: 0
     khung_rx_stomped_crc: 0
     khung_rx_too_long: 0
     khung_rx_vlan_good: 3
     khung_rx_dropped: 0
     khung_rx_less_than_64b: 0
     khung_rx_64b: 4
     khung_rx_65b_127b: 11
     khung_rx_128b_255b: 0
     khung_rx_256b_511b: 0
     khung_rx_512b_1023b: 0
     khung_rx_1024b_1518b: 0
     khung_rx_1519b_2047b: 0
     khung_rx_2048b_4095b: 0
     khung_rx_4096b_8191b: 0
     khung_rx_8192b_9215b: 0
     khung_rx_other: 0
     khung_tx_ok: 31
     khung_tx_all: 31
     khung_tx_bad: 0
     octet_tx_ok: 2614
     octet_tx_total: 2614
     khung_tx_unicast: 8
     khung_tx_multicast: 21
     khung_tx_broadcast: 2
     khung_tx_pause: 0
     khung_tx_pripause: 0
     khung_tx_vlan: 0
     khung_tx_less_than_64b: 0
     khung_tx_64b: 4
     khung_tx_65b_127b: 27
     khung_tx_128b_255b: 0
     khung_tx_256b_511b: 0
     khung_tx_512b_1023b: 0
     khung_tx_1024b_1518b: 0
     khung_tx_1519b_2047b: 0
     khung_tx_2048b_4095b: 0
     khung_tx_4096b_8191b: 0
     khung_tx_8192b_9215b: 0
     khung_tx_other: 0
     khung_tx_pri_0: 0
     khung_tx_pri_1: 0
     khung_tx_pri_2: 0
     khung_tx_pri_3: 0
     khung_tx_pri_4: 0
     khung_tx_pri_5: 0
     khung_tx_pri_6: 0
     khung_tx_pri_7: 0
     khung_rx_pri_0: 0
     khung_rx_pri_1: 0
     khung_rx_pri_2: 0
     khung_rx_pri_3: 0
     khung_rx_pri_4: 0
     khung_rx_pri_5: 0
     khung_rx_pri_6: 0
     khung_rx_pri_7: 0
     tx_pripause_0_1us_count: 0
     tx_pripause_1_1us_count: 0
     tx_pripause_2_1us_count: 0
     tx_pripause_3_1us_count: 0
     tx_pripause_4_1us_count: 0
     tx_pripause_5_1us_count: 0
     tx_pripause_6_1us_count: 0
     tx_pripause_7_1us_count: 0
     rx_pripause_0_1us_count: 0
     rx_pripause_1_1us_count: 0
     rx_pripause_2_1us_count: 0
     rx_pripause_3_1us_count: 0
     rx_pripause_4_1us_count: 0
     rx_pripause_5_1us_count: 0
     rx_pripause_6_1us_count: 0
     rx_pripause_7_1us_count: 0
     rx_pause_1us_count: 0
     khung_tx_truncated: 0


Ủng hộ
=======

Để được hỗ trợ mạng Linux nói chung, vui lòng sử dụng gửi thư netdev
danh sách, được giám sát bởi nhân viên của Pensando::

netdev@vger.kernel.org

Để biết thêm nhu cầu hỗ trợ cụ thể, vui lòng sử dụng hỗ trợ trình điều khiển Pensando
thư điện tử::

driver@pensando.io