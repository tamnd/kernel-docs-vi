.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/freescale/dpaa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Trình điều khiển Ethernet QorIQ DPAA
==============================

tác giả:
- Madalin Bucur <madalin.bucur@nxp.com>
- Camelia Groza <camelia.groza@nxp.com>

.. Contents

	- DPAA Ethernet Overview
	- DPAA Ethernet Supported SoCs
	- Configuring DPAA Ethernet in your kernel
	- DPAA Ethernet Frame Processing
	- DPAA Ethernet Features
	- DPAA IRQ Affinity and Receive Side Scaling
	- Debugging

Tổng quan về Ethernet DPAA
======================

DPAA là viết tắt của Kiến trúc tăng tốc đường dẫn dữ liệu và nó là một
tập hợp các IP tăng tốc mạng có sẵn trên một số
thế hệ SoC, cả trên PowerPC và ARM64.

Kiến trúc Freescale DPAA bao gồm một loạt các khối phần cứng
hỗ trợ kết nối Ethernet. Trình điều khiển Ethernet phụ thuộc vào
trình điều khiển sau trong nhân Linux:

- Bộ nhớ truy cập ngoại vi (PAMU) (* chỉ cần cho nền tảng PPC)
    trình điều khiển/iommu/fsl_*
 - Trình quản lý khung (FMan)
    trình điều khiển/net/ethernet/freescale/fman
 - Trình quản lý hàng đợi (QMan), Trình quản lý bộ đệm (BMan)
    trình điều khiển/soc/fsl/qbman

Một cái nhìn đơn giản về các giao diện dpaa_eth được ánh xạ tới MAC FMan::

dpaa_eth /eth0\ ... /ethN\
  trình điều khiển ZZ0000ZZ ZZ0001ZZ
  ------------- ---- ------------- ---- -------------
       -Cổng/Tx Rx\.../Tx Rx\
  FMan ZZ0002ZZ ZZ0003ZZ
       -MAC ZZ0004ZZ ZZ0005ZZ
	     /dtsec0\.../dtsecN\(hoặc tgec)
	    / \ / \(hoặc memac)
  --------- -------------- --- -------------- ---------
      Trình điều khiển FMan, FMan Port, FMan SP, FMan MURAM
  ---------------------------------------------------------
      Khối FMan HW: MURAM, MAC, Cổng, SP
  ---------------------------------------------------------

Mối quan hệ dpaa_eth với QMan, BMan và FMan::

________________________________
  dpaa_eth / eth0 \
  trình điều khiển / \
  --------- -^- -^- -^- --- ---------
  Trình điều khiển QMan / \ / \ / \ \ / ZZ0000ZZ
	     ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ
  --------- ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ
  QMan HW ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ
	     / \ / \ / \ \ / ZZ0016ZZ
  --------- --- --- --- -v- ---------
	    ZZ0017ZZ |
	    ZZ0018ZZ BMan HW |
	      -------------- --------

trong đó các từ viết tắt được sử dụng ở trên (và trong mã) là:

================================================================================
Kiến trúc tăng tốc đường dẫn dữ liệu DPAA
Trình quản lý khung FMan DPAA
Trình quản lý hàng đợi QMan DPAA
Trình quản lý bộ đệm BMan DPAA
Giao diện QMI QMan trong FMan
Giao diện BMI BMan trong FMan
Hồ sơ lưu trữ FMan SP FMan
MURAM Đa người dùng RAM trong FMan
Hàng đợi khung FQ QMan
Rx Dfl FQ tiếp nhận mặc định FQ
Rx Err FQ Khung lỗi Rx FQ
Tx Cnf FQ Tx xác nhận FQ
Hàng đợi khung truyền Tx FQ
Bộ điều khiển Ethernet ba tốc độ dtsec datapath (10/100/1000 Mbps)
Bộ điều khiển Ethernet tgec mười gigabit (10 Gbps)
Ethernet đa tốc độ memac MAC (10/100/1000/10000)
================================================================================

SoC hỗ trợ Ethernet DPAA
============================

Trình điều khiển DPAA kích hoạt bộ điều khiển Ethernet có trên các SoC sau:

PPC
-P1023
-P2041
-P3041
-P4080
-P5020
-P5040
-T1023
-T1024
-T1040
-T1042
-T2080
-T4240
-B4860

ARM
-LS1043A
-LS1046A

Định cấu hình DPAA Ethernet trong kernel của bạn
========================================

Để bật trình điều khiển Ethernet DPAA, cần có các tùy chọn Kconfig sau ::

# common dành cho nền tảng Arch/arm64 và Arch/powerpc
  CONFIG_FSL_DPAA=y
  CONFIG_FSL_FMAN=y
  CONFIG_FSL_DPAA_ETH=y
  CONFIG_FSL_XGMAC_MDIO=y

Chỉ # for vòm/powerpc
  CONFIG_FSL_PAMU=y

Các tùy chọn # common cần thiết cho PHY được sử dụng trên RDB
  CONFIG_VITESSE_PHY=y
  CONFIG_REALTEK_PHY=y
  CONFIG_AQUANTIA_PHY=y

Xử lý khung Ethernet DPAA
==============================

Trên Rx, bộ đệm cho các khung đến được lấy từ bộ đệm được tìm thấy
trong vùng đệm giao diện chuyên dụng. Trình điều khiển khởi tạo và gieo mầm những thứ này
với bộ đệm một trang.

Trên Tx, tất cả các khung được truyền sẽ được trả về trình điều khiển thông qua Tx
hàng đợi khung xác nhận. Người lái xe sau đó có trách nhiệm giải phóng xe
bộ đệm. Để thực hiện việc này đúng cách, một con trỏ lùi được thêm vào bộ đệm
trước khi truyền dẫn đến skb. Khi bộ đệm trở về trạng thái
trình điều khiển trên FQ xác nhận, skb có thể được sử dụng chính xác.

Tính năng Ethernet DPAA
======================

Hiện tại trình điều khiển Ethernet DPAA hỗ trợ các tính năng cơ bản cần thiết cho
trình điều khiển Ethernet Linux. Sự hỗ trợ cho các tính năng nâng cao sẽ được thêm vào
dần dần.

Trình điều khiển có tính năng giảm tải tổng kiểm Rx và Tx cho UDP và TCP. Hiện tại Rx
Tính năng giảm tải tổng kiểm tra được bật theo mặc định và không thể kiểm soát được thông qua
ethtool. Ngoài ra, rx-flow-hash và rx-hashing đã được thêm vào. Việc bổ sung RSS
cung cấp sự tăng cường hiệu suất lớn cho các kịch bản chuyển tiếp, cho phép
các luồng lưu lượng khác nhau được nhận bởi một giao diện sẽ được xử lý bởi các giao diện khác nhau
CPU song song.

Trình điều khiển có hỗ trợ nhiều loại lưu lượng Tx được ưu tiên. Ưu tiên
nằm trong khoảng từ 0 (thấp nhất) đến 3 (cao nhất). Chúng được ánh xạ tới hàng công việc CTNH với
mức độ ưu tiên nghiêm ngặt. Mỗi lớp lưu lượng chứa hàng đợi NR_CPU TX. Bởi
mặc định, chỉ có một loại lưu lượng được kích hoạt và hàng đợi Tx có mức ưu tiên thấp nhất
được sử dụng. Các lớp lưu lượng ưu tiên cao hơn có thể được kích hoạt bằng mqprio
qdisc. Ví dụ: tất cả bốn lớp lưu lượng đều được kích hoạt trên giao diện có
lệnh sau. Hơn nữa, mức độ ưu tiên của skb được ánh xạ tới lưu lượng truy cập
các lớp như sau:

* mức độ ưu tiên 0 đến 3 - loại lưu lượng 0 (mức độ ưu tiên thấp)
	* mức độ ưu tiên 4 đến 7 - lưu lượng loại 1 (mức độ ưu tiên trung bình-thấp)
	* mức độ ưu tiên 8 đến 11 - lưu lượng loại 2 (mức độ ưu tiên trung bình cao)
	* mức độ ưu tiên 12 đến 15 - lưu lượng loại 3 (mức độ ưu tiên cao)

::

tc qdisc thêm mã điều khiển gốc dev <int> 1: \
	 mqprio num_tc 4 bản đồ 0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 hw 1

DPAA IRQ Mối quan hệ và nhận tỷ lệ bên
==========================================

Lưu lượng truy cập đến trên hàng đợi DPAA Rx hoặc trên xác nhận DPAA Tx
hàng đợi được CPU xem là lưu lượng truy cập vào một cổng nhất định.
Mỗi ngắt cổng DPAA QMan được gắn với một CPU nhất định.
Cổng thông tin tương tự làm gián đoạn dịch vụ cho tất cả người tiêu dùng cổng thông tin QMan.

Theo mặc định, trình điều khiển Ethernet DPAA kích hoạt RSS, sử dụng
DPAA FMan Parser và Keygen chặn để phân phối lưu lượng truy cập trên 128
hàng đợi khung phần cứng sử dụng hàm băm trên nguồn và đích IP v4/v6
và các cổng nguồn và đích L4, hiện diện trong khung nhận được.
Khi RSS bị tắt, tất cả lưu lượng truy cập nhận được bởi một giao diện nhất định sẽ bị vô hiệu hóa.
nhận được trên hàng đợi khung Rx mặc định. Khung DPAA Rx mặc định
hàng đợi được cấu hình để đưa lưu lượng nhận được vào kênh chung
cho phép bất kỳ cổng CPU có sẵn nào loại bỏ lưu lượng truy cập vào.
Hàng đợi khung mặc định có tùy chọn HOLDACTIVE được đặt, đảm bảo rằng
các đợt bùng phát lưu lượng từ một hàng đợi nhất định được phục vụ bởi cùng một CPU.
Điều này đảm bảo tỷ lệ sắp xếp lại khung hình rất thấp. Một nhược điểm của điều này
là tại một thời điểm chỉ có một CPU có thể phục vụ lưu lượng mà một mạng nhận được
giao diện nhất định khi RSS không được kích hoạt.

Để triển khai RSS, trình điều khiển Ethernet DPAA phân bổ thêm một bộ
Hàng đợi khung 128 Rx được định cấu hình cho các kênh chuyên dụng, trong một
theo kiểu vòng tròn. Việc ánh xạ hàng đợi khung tới CPU hiện đã được thực hiện
được mã hóa cứng, không có bảng hướng dẫn để di chuyển lưu lượng truy cập trong một khoảng thời gian nhất định
FQ (kết quả băm) sang CPU khác. Lưu lượng truy cập đi vào một
trong số các hàng đợi khung này sẽ đến cùng một cổng và sẽ luôn
được xử lý bởi cùng một CPU. Điều này đảm bảo duy trì trật tự trong luồng
và phân phối khối lượng công việc cho nhiều luồng lưu lượng.

RSS có thể được tắt cho một giao diện nhất định bằng ethtool, tức là::

# ethtool -N fm1-mac9 rx-flow-hash tcp4 ""

Để bật lại, người ta cần đặt rx-flow-hash cho tcp4/6 hoặc udp4/6::

# ethtool -N fm1-mac9 rx-flow-hash udp4 sfdn

Không có sự kiểm soát độc lập cho các giao thức riêng lẻ, bất kỳ lệnh nào
chạy cho một trong các tcp4|udp4|ah4|esp4|sctp4|tcp6|udp6|ah6|esp6|sctp6 là
sẽ kiểm soát việc băm rx-flow-băm cho tất cả các giao thức trên giao diện đó.

Bên cạnh việc sử dụng hàm băm được tính toán của FMan Keygen để phân tán lưu lượng truy cập trên
128 Rx FQ, trình điều khiển Ethernet DPAA cũng đặt giá trị băm skb khi
tính năng NETIF_F_RXHASH được bật (hoạt động theo mặc định). Điều này có thể được biến
bật hoặc tắt thông qua ethtool, tức là::

Tắt # ethtool -K fm1-mac9 rx-băm
	# ethtool -k fm1-mac9 | băm grep
	nhận-băm: tắt
	# ethtool -K fm1-mac9 rx-băm đang bật
	Những thay đổi thực tế:
	nhận-băm: bật
	# ethtool -k fm1-mac9 | băm grep
	nhận-băm: bật

Xin lưu ý rằng việc băm Rx phụ thuộc vào việc băm rx-flow-flow được bật
đối với giao diện đó - việc tắt rx-flow-hashing cũng sẽ vô hiệu hóa
rx-hashing (không có ethtool báo cáo nó bị tắt vì điều đó phụ thuộc vào
Cờ tính năng NETIF_F_RXHASH).

Gỡ lỗi
=========

Số liệu thống kê sau đây được xuất cho từng giao diện thông qua ethtool:

- số lần ngắt trên mỗi CPU
	- Số gói Rx trên mỗi CPU
	- Số gói Tx trên mỗi CPU
	- Số lượng gói được xác nhận Tx trên mỗi CPU
	- Số khung hình Tx S/G trên mỗi CPU
	- Số lỗi Tx trên mỗi CPU
	- Số lỗi Rx trên mỗi CPU
	- Số lỗi Rx cho mỗi loại
	- Thống kê liên quan đến tắc nghẽn:

- tình trạng tắc nghẽn
		- thời gian bị tắc nghẽn
		- số lần thiết bị rơi vào tình trạng tắc nghẽn
		- số lượng gói bị mất theo nguyên nhân

Trình điều khiển cũng xuất thông tin sau trong sysfs:

- ID FQ cho từng loại FQ
	  /sys/devices/platform/soc/<addr>.fman/<addr>.ethernet/dpaa-ethernet.<id>/net/fm<nr>-mac<nr>/fqids

- ID của vùng đệm đang sử dụng
	  /sys/devices/platform/soc/<addr>.fman/<addr>.ethernet/dpaa-ethernet.<id>/net/fm<nr>-mac<nr>/bpids