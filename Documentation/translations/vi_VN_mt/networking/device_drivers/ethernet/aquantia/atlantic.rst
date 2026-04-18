.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/aquantia/atlantic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=============================================
Trình điều khiển AQtion của Marvell(Aquantia)
=============================================

Dành cho bộ điều hợp Ethernet aQuantia Multi-Gigabit PCI Express

.. Contents

    - Identifying Your Adapter
    - Configuration
    - Supported ethtool options
    - Command Line Parameters
    - Config file parameters
    - Support
    - License

Xác định bộ điều hợp của bạn
========================

Trình điều khiển trong phiên bản này tương thích với AQC-100, AQC-107, AQC-108
bộ điều hợp ethernet dựa trên.


Thiết bị SFP+ (dành cho bộ điều hợp dựa trên AQC-100)
-----------------------------------------

Bản phát hành này đã được thử nghiệm với Cáp gắn trực tiếp thụ động (DAC) và SFP+/LC
Bộ thu phát quang học.

Cấu hình
=============

Xem tin nhắn liên kết
---------------------
Thông báo liên kết sẽ không được hiển thị trên bảng điều khiển nếu việc phân phối
  hạn chế tin nhắn hệ thống. Để xem thông báo liên kết trình điều khiển mạng trên
  bảng điều khiển của bạn, hãy đặt dmesg thành 8 bằng cách nhập thông tin sau::

dmesg -n 8

  .. note::

     This setting is not saved across reboots.

Khung Jumbo
------------
Trình điều khiển hỗ trợ Khung Jumbo cho tất cả các bộ điều hợp. Hỗ trợ khung Jumbo là
  được bật bằng cách thay đổi MTU thành giá trị lớn hơn giá trị mặc định là 1500.
  Giá trị tối đa cho MTU là 16000. Sử dụng lệnh ZZ0000ZZ để
  tăng kích thước MTU.  Ví dụ::

bộ liên kết ip mtu 16000 dev enp1s0

công cụ đạo đức
-------
Trình điều khiển sử dụng giao diện ethtool để cấu hình trình điều khiển và
  chẩn đoán cũng như hiển thị thông tin thống kê. mới nhất
  phiên bản ethtool là cần thiết cho chức năng này.

NAPI
----
NAPI (Chế độ bỏ phiếu Rx) được hỗ trợ trong trình điều khiển atlantic.

Tùy chọn ethtool được hỗ trợ
=========================

Xem cài đặt bộ điều hợp
------------------------

 ::

công cụ đạo đức <ethX>

Ví dụ đầu ra::

Cài đặt cho enp1s0:
    Các cổng được hỗ trợ: [ TP ]
    Chế độ liên kết được hỗ trợ: 100baseT/Full
			    1000baseT/Đầy đủ
			    10000baseT/Đầy đủ
			    2500baseT/Đầy đủ
			    5000baseT/Đầy đủ
    Sử dụng khung tạm dừng được hỗ trợ: Đối xứng
    Hỗ trợ tự động đàm phán: Có
    Các chế độ FEC được hỗ trợ: Không được báo cáo
    Chế độ liên kết được quảng cáo: 100baseT/Full
			    1000baseT/Đầy đủ
			    10000baseT/Đầy đủ
			    2500baseT/Đầy đủ
			    5000baseT/Đầy đủ
    Sử dụng khung tạm dừng được quảng cáo: Đối xứng
    Tự động đàm phán được quảng cáo: Có
    Chế độ FEC được quảng cáo: Chưa được báo cáo
    Tốc độ: 10000Mb/giây
    Hai mặt: Đầy đủ
    Cổng: Cặp xoắn
    PHYAD: 0
    Bộ thu phát: nội bộ
    Tự động đàm phán: bật
    MDI-X: Không rõ
    Hỗ trợ Wake-on: g
    Thức dậy :d
    Liên kết được phát hiện: có


 .. note::

    AQrate speeds (2.5/5 Gb/s) will be displayed only with linux kernels > 4.10.
    But you can still use these speeds::

ethtool -s eth0 autoneg tắt tốc độ 2500

Xem thông tin bộ điều hợp
---------------------------

 ::

ethtool -i <ethX>

Ví dụ đầu ra::

tài xế: Đại Tây Dương
  phiên bản: 5.2.0-050200rc5-generic-kern
  phiên bản phần sụn: 3.1.78
  phiên bản mở rộng-rom:
  thông tin xe buýt: 0000:01:00.0
  thống kê hỗ trợ: có
  hỗ trợ-kiểm tra: không
  hỗ trợ-eeprom-truy cập: không
  hỗ trợ-đăng ký-dump: có
  hỗ trợ-priv-flag: không


Xem số liệu thống kê bộ điều hợp Ethernet
-----------------------------------

 ::

công cụ đạo đức -S <ethX>

Ví dụ đầu ra::

Thống kê NIC:
     Gói trong: 13238607
     InUCast: 13293852
     InMCast: 52
     InBCcast: 3
     Lỗi sai: 0
     Gói đi: 23703019
     OutUCast: 23704941
     OutMCast: 67
     OutBcast: 11
     InUCastTháng 10: 213182760
     OutUCastTháng 10: 22698443
     InMCastTháng 10: 6600
     OutMCastTháng 10: 8776
     InBcastTháng 10: 192
     OutBCastTháng 10: 704
     Trong tháng 10: 2131839552
     OutOctects: 226938073
     Trong góiDma: 95532300
     OutPacketsDma: 59503397
     InOctetsDma: 1137102462
     OutOctetsDma: 2394339518
     InDroppedDma: 0
     Hàng đợi [0] Gói trong: 23567131
     Hàng đợi [0] Gói ngoài: 20070028
     Hàng đợi [0] Gói InJumbo: 0
     Hàng đợi [0] Gói InLro: 0
     Hàng đợi[0] Lỗi: 0
     Hàng đợi [1] Gói trong: 45428967
     Hàng đợi [1] Gói ngoài: 11306178
     Hàng đợi [1] InJumboPackets: 0
     Hàng đợi [1] Gói InLro: 0
     Hàng đợi[1] Lỗi: 0
     Hàng đợi [2] Gói trong: 3187011
     Hàng đợi [2] Gói ngoài: 13080381
     Hàng đợi [2] InJumboPackets: 0
     Hàng đợi [2] Gói InLro: 0
     Hàng đợi[2] Lỗi: 0
     Hàng đợi [3] Gói trong: 23349136
     Hàng đợi [3] Gói ngoài: 15046810
     Hàng đợi [3] InJumboPackets: 0
     Hàng đợi [3] Gói InLro: 0
     Hàng đợi[3] Lỗi: 0

Hỗ trợ liên kết gián đoạn
----------------------------

Chế độ ITR, thời gian kết hợp TX/RX có thể được xem bằng::

ethtool -c <ethX>

và thay đổi bằng::

ethtool -C <ethX> tx-usecs <usecs> rx-usecs <usecs>

Để tắt tính năng kết hợp::

ethtool -C <ethX> tx-usecs 0 rx-usecs 0 tx-max-frames 1 tx-max-frames 1

Hỗ trợ Wake on LAN
-------------------

Hỗ trợ WOL bằng gói ma thuật::

ethtool -s <ethX> wol g

Để tắt WOL::

ethtool -s <ethX> wol d

Đặt và kiểm tra mức thông báo trình điều khiển
--------------------------------------

Đặt mức tin nhắn

 ::

ethtool -s <ethX> msglvl <level>

Giá trị cấp độ:

====== ================================
 Trạng thái trình điều khiển chung 0x0001.
 Thăm dò phần cứng 0x0002
 Trạng thái liên kết 0x0004.
 Kiểm tra trạng thái định kỳ 0x0008
 Giao diện 0x0010 đang được gỡ xuống.
 Giao diện 0x0020 đang được đưa lên.
 0x0040 nhận được lỗi.
 Lỗi truyền 0x0080.
 Xử lý ngắt 0x0200
 Hoàn thành truyền 0x0400.
 0x0800 nhận được hoàn thành.
 Nội dung gói 0x1000.
 Trạng thái phần cứng 0x2000.
 Trạng thái 0x4000 Wake-on-LAN.
 ====== ================================

Theo mặc định, mức độ thông báo gỡ lỗi được đặt 0x0001 (trạng thái trình điều khiển chung).

Kiểm tra mức độ tin nhắn

 ::

công cụ đạo đức <ethX> | grep "Mức tin nhắn hiện tại"

Nếu bạn muốn tắt đầu ra của tin nhắn ::

ethtool -s <ethX> msglvl 0

Quy tắc luồng RX (bộ lọc ntuple)
------------------------------

Có các quy tắc riêng được hỗ trợ, áp dụng theo thứ tự đó:

1. 16 quy tắc ID VLAN
 2. 16 quy tắc EtherType L2
 3. 8 quy tắc 5 bộ L3/L4


Trình điều khiển sử dụng giao diện ethtool để định cấu hình các bộ lọc ntuple,
 thông qua ZZ0000ZZ.

Để bật hoặc tắt quy tắc luồng RX::

ethtool -K ethX ntuple <on|off>

Khi tắt nhiều bộ lọc, tất cả các bộ lọc do người dùng lập trình sẽ bị
 bị xóa khỏi bộ đệm trình điều khiển và phần cứng. Tất cả các bộ lọc cần thiết phải
 được thêm lại khi ntuple được kích hoạt lại.

Do thứ tự cố định của các quy tắc nên vị trí của các bộ lọc cũng cố định:

- Vị trí 0 - 15 cho bộ lọc ID VLAN
 - Vị trí 16 - 31 cho bộ lọc L2 EtherType
 - Vị trí 32 - 39 cho bộ lọc 5 bộ L3/L4 (vị trí 32, 36 cho IPv6)

L3/L4 5 bộ (giao thức, địa chỉ IP nguồn và đích, nguồn và
 cổng TCP/UDP/SCTP đích) được so sánh với 8 bộ lọc. Đối với IPv4, tối đa
 8 địa chỉ nguồn và đích có thể được khớp. Đối với IPv6, tối đa 2 cặp
 địa chỉ có thể được hỗ trợ. Cổng nguồn và cổng đích chỉ được so sánh cho
 Các gói TCP/UDP/SCTP.

Để thêm bộ lọc hướng gói đến hàng đợi 5, hãy sử dụng
 Công tắc ZZ0000ZZ::

ethtool -N <ethX> loại luồng udp4 src-ip 10.0.0.1 dst-ip 10.0.0.2 src-port 2000 dst-port 2001 hành động 5 <loc 32>

- hành động là số hàng đợi.
 - loc là số quy tắc.

Đối với ZZ0000ZZ, bạn phải đặt loc
 số trong vòng 32 - 39.
 Đối với ZZ0001ZZ bạn có thể đặt 8 quy tắc
 đối với lưu lượng IPv4 hoặc bạn có thể đặt 2 quy tắc cho lưu lượng IPv6. Số lộc lưu thông
 IPv6 là 32 và 36.
 Hiện tại, bạn không thể sử dụng bộ lọc IPv4 và IPv6 cùng một lúc.

Bộ lọc ví dụ cho lưu lượng bộ lọc IPv6::

sudo ethtool -N <ethX> loại luồng tcp6 src-ip 2001:db8:0:f101::1 dst-ip 2001:db8:0:f101::2 hành động 1 loc 32
    sudo ethtool -N <ethX> flow-type ip6 src-ip 2001:db8:0:f101::2 dst-ip 2001:db8:0:f101::5 hành động -1 loc 36

Bộ lọc ví dụ cho lưu lượng bộ lọc IPv4::

sudo ethtool -N <ethX> loại luồng udp4 src-ip 10.0.0.4 dst-ip 10.0.0.7 src-port 2000 dst-port 2001 loc 32
    sudo ethtool -N <ethX> loại luồng tcp4 src-ip 10.0.0.3 dst-ip 10.0.0.9 src-port 2000 dst-port 2001 loc 33
    sudo ethtool -N <ethX> loại luồng ip4 src-ip 10.0.0.6 dst-ip 10.0.0.4 loc 34

Nếu bạn đặt hành động -1 thì tất cả lưu lượng truy cập tương ứng với bộ lọc sẽ bị loại bỏ.

Hành động giá trị tối đa là 31.


Bộ lọc VLAN (id VLAN) được so sánh với 16 bộ lọc.
 Id VLAN phải đi kèm với mặt nạ 0xF000. Đó là để phân biệt bộ lọc VLAN
 từ bộ lọc Ethertype L2 với UserPriority vì cả Ưu tiên người dùng và ID VLAN
 được truyền trong cùng tham số 'vlan'.

Để thêm bộ lọc chuyển các gói từ VLAN 2001 sang hàng đợi 5::

ethtool -N <ethX> loại luồng ip4 vlan 2001 m 0xF000 hành động 1 loc 0


Bộ lọc EtherType L2 cho phép lọc gói theo trường EtherType hoặc cả EtherType
 và trường Ưu tiên người dùng (PCP) của 802.1Q.
 Tham số UserPriority (vlan) phải đi kèm với mặt nạ 0x1FFF. Đó là để
 phân biệt bộ lọc VLAN với bộ lọc Ethertype L2 bằng UserPriority vì cả hai
 Mức độ ưu tiên của người dùng và ID VLAN được chuyển trong cùng một tham số 'vlan'.

Để thêm bộ lọc hướng gói IP4 có mức độ ưu tiên 3 vào hàng đợi 3::

ethtool -N <ethX> loại luồng ether proto 0x800 vlan 0x600 m 0x1FFF hành động 3 loc 16

Để xem danh sách các bộ lọc hiện có::

ethtool <-u|-n|--show-nfc|--show-ntuple> <ethX>

Các quy tắc có thể bị xóa khỏi bảng. Điều này được thực hiện bằng cách sử dụng::

sudo ethtool <-NZZ0000ZZ--config-nfc|--config-ntuple> <ethX> xóa <loc>

- loc là số quy tắc cần xóa.

Bộ lọc Rx là một giao diện để tải bảng bộ lọc phân luồng tất cả các luồng
 vào hàng đợi 0 trừ khi hàng đợi thay thế được chỉ định bằng "hành động". Trong đó
 trường hợp, bất kỳ luồng nào phù hợp với tiêu chí lọc sẽ được chuyển hướng đến
 hàng đợi thích hợp. Bộ lọc RX được hỗ trợ trên tất cả các hạt nhân 2.6.30 trở lên.

RSS cho UDP
-----------

Hiện tại, NIC không hỗ trợ RSS cho các gói IP bị phân mảnh, dẫn đến
 RSS hoạt động không chính xác đối với lưu lượng truy cập UDP bị phân mảnh. Để tắt RSS cho UDP,
 Quy tắc RX Flow L3/L4 có thể được sử dụng.

Ví dụ::

ethtool -N eth0 hành động udp4 loại luồng 0 loc 32

Giảm tải phần cứng UDP GSO
------------------------

UDP GSO cho phép tăng tốc độ tx UDP bằng cách giảm tải phân bổ tiêu đề UDP
 vào phần cứng. Cần có tùy chọn ổ cắm không gian người dùng đặc biệt cho việc này,
 có thể được xác thực bằng /kernel/tools/testing/selftests/net/::

udpgso_bench_tx -u -4 -D 10.0.1.1 -s 6300 -S 100

Sẽ khiến việc gửi các gói UDP có kích thước 100 byte được hình thành từ một
 Bộ đệm người dùng 6300 byte.

UDP GSO được cấu hình bởi::

ethtool -K eth0 tx-udp-phân đoạn trên

Cờ riêng (thử nghiệm)
-----------------------

Trình điều khiển Atlantic hỗ trợ cờ riêng cho các tính năng tùy chỉnh phần cứng::

$ ethtool --show-priv-flags ethX

Cờ riêng cho ethX:
	DMASystemLoopback: tắt
	PKTSystemLoopback: tắt
	DMANetworkLoopback: tắt
	PHYInternalLoopback: tắt
	PHYExternalLoopback: tắt

Ví dụ::

$ ethtool --set-priv-flags ethX DMASystemLoopback bật

DMASystemLoopback: Vòng lặp máy chủ DMA.
 PKTSystemLoopback: Vòng lặp máy chủ bộ đệm gói.
 DMANetworkLoopback: Vòng lặp phía mạng trên khối DMA.
 PHYInternalLoopback: Vòng lặp nội bộ trên Phy.
 PHYExternalLoopback: Loopback bên ngoài trên Phy (với cáp ethernet loopback).


Tham số dòng lệnh
=======================
Các tham số dòng lệnh sau có sẵn trên trình điều khiển atlantic:

aq_itr -Chế độ điều chỉnh ngắt
---------------------------------
Các giá trị được chấp nhận: 0, 1, 0xFFFF

Giá trị mặc định: 0xFFFF

====== ===================================================================
0 Tắt điều chỉnh ngắt.
1 Cho phép điều chỉnh ngắt và sử dụng tốc độ tx và rx được chỉ định.
0xFFFF Chế độ điều tiết tự động. Tài xế sẽ chọn RX và TX tốt nhất
	 làm gián đoạn cài đặt điều chỉnh dựa trên tốc độ liên kết.
====== ===================================================================

aq_itr_tx - Tốc độ điều tiết ngắt TX
--------------------------------------

Giá trị được chấp nhận: 0 - 0x1FF

Giá trị mặc định: 0

Điều tiết bên TX tính bằng micro giây. Bộ điều hợp sẽ thiết lập độ trễ ngắt tối đa
đến giá trị này. Độ trễ ngắt tối thiểu sẽ bằng một nửa giá trị này

aq_itr_rx - Tốc độ điều tiết ngắt RX
--------------------------------------

Giá trị được chấp nhận: 0 - 0x1FF

Giá trị mặc định: 0

Điều chỉnh phía RX tính bằng micro giây. Bộ điều hợp sẽ thiết lập độ trễ ngắt tối đa
đến giá trị này. Độ trễ ngắt tối thiểu sẽ bằng một nửa giá trị này

.. note::

   ITR settings could be changed in runtime by ethtool -c means (see below)

Thông số tập tin cấu hình
======================

Đối với một số tinh chỉnh và tối ưu hóa hiệu suất,
một số tham số có thể được thay đổi trong tệp {source_dir}/aq_cfg.h.

AQ_CFG_RX_PAGEORDER
-------------------

Giá trị mặc định: 0

Ghi đè thứ tự trang RX. Đó là lũy thừa của 2 số trang RX được phân bổ cho
mỗi mô tả. Kích thước mô tả nhận được vẫn bị giới hạn bởi
AQ_CFG_RX_FRAME_MAX.

Việc tăng thứ tự trang giúp việc tái sử dụng trang tốt hơn (thực tế trên các hệ thống hỗ trợ iommu).

AQ_CFG_RX_REFILL_THRES
----------------------

Giá trị mặc định: 32

Ngưỡng nạp lại RX. Đường dẫn RX sẽ không nạp lại các bộ mô tả được giải phóng cho đến khi
số lượng mô tả miễn phí được chỉ định được quan sát. Giá trị lớn hơn có thể giúp ích
tái sử dụng trang tốt hơn nhưng cũng có thể dẫn đến rớt gói.

AQ_CFG_VECS_DEF
---------------

Số lượng hàng đợi

Phạm vi hợp lệ: 0 - 8 (tối đa AQ_CFG_VECS_MAX)

Giá trị mặc định: 8

Lưu ý rằng giá trị này sẽ bị giới hạn bởi số lượng lõi có sẵn trên hệ thống.

AQ_CFG_IS_RSS_DEF
-----------------

Bật/tắt tính năng chia tỷ lệ bên nhận

Tính năng này cho phép bộ điều hợp phân phối xử lý nhận
trên nhiều lõi CPU và để tránh làm quá tải một lõi CPU.

Giá trị hợp lệ

=========
0 bị vô hiệu hóa
1 đã được kích hoạt
=========

Giá trị mặc định: 1

AQ_CFG_NUM_RSS_QUEUES_DEF
-------------------------

Số lượng hàng đợi để chia tỷ lệ bên nhận

Phạm vi hợp lệ: 0 - 8 (tối đa AQ_CFG_VECS_DEF)

Giá trị mặc định: AQ_CFG_VECS_DEF

AQ_CFG_IS_LRO_DEF
-----------------

Bật/tắt Giảm tải nhận lớn

Việc giảm tải này cho phép bộ chuyển đổi kết hợp nhiều phân đoạn TCP và chỉ ra
chúng như một đơn vị được kết hợp duy nhất với hệ thống con mạng hệ điều hành.

Hệ thống tiêu thụ ít năng lượng hơn nhưng cũng gây ra nhiều độ trễ hơn trong các gói
xử lý.

Giá trị hợp lệ

=========
0 bị vô hiệu hóa
1 đã được kích hoạt
=========

Giá trị mặc định: 1

AQ_CFG_TX_CLEAN_BUDGET
----------------------

Bộ mô tả tối đa để dọn dẹp trên TX cùng một lúc.

Giá trị mặc định: 256

Sau khi thay đổi tệp aq_cfg.h, trình điều khiển phải được xây dựng lại để có hiệu lực.

Ủng hộ
=======

Nếu một vấn đề được xác định với mã nguồn được phát hành trên thiết bị được hỗ trợ
kernel với bộ điều hợp được hỗ trợ, gửi email thông tin cụ thể liên quan
gửi vấn đề tới aqn_support@marvell.com

Giấy phép
=======

Trình điều khiển mạng của Tập đoàn aQuantia

Bản quyền ZZ0000ZZ 2014 - 2019 aQuantia Corporation.

Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi nó
theo các điều khoản và điều kiện của Giấy phép Công cộng GNU,
phiên bản 2, do Tổ chức Phần mềm Tự do xuất bản.