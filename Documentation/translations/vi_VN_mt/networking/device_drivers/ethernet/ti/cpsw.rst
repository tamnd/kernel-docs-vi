.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/ti/cpsw.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Trình điều khiển ethernet CPSW của Texas Instruments
======================================

Nhiều hàng đợi & CBS & MQPRIO
=========================


Cpsw có 3 bộ định dạng CBS cho mỗi cổng bên ngoài. Tài liệu này
mô tả cấu hình giảm tải MQPRIO và CBS Qdisc cho trình điều khiển cpsw
dựa trên các ví dụ. Nó có khả năng có thể được sử dụng trong cầu nối âm thanh video
(AVB) và mạng nhạy cảm với thời gian (TSN).

Các ví dụ sau đã được thử nghiệm trên bo mạch AM572x EVM và BBB.

Thiết lập thử nghiệm
==========

Đang xem xét hai ví dụ với AM572x EVM chạy trình điều khiển cpsw
ở chế độ Dual_emac.

Một số điều kiện tiên quyết:

- Hàng đợi TX phải được xếp hạng bắt đầu từ txq0 có mức ưu tiên cao nhất
- Các lớp lưu lượng được sử dụng bắt đầu từ 0, có mức ưu tiên cao nhất
- Nên sử dụng máy giữ gìn CBS với hàng đợi được xếp hạng
- Băng thông cho bộ định dạng CBS phải được đặt thêm một chút
  tốc độ đến tiềm năng, do đó, tốc độ của tất cả các hàng đợi tx đến có
  ít hơn một chút
- Tỷ giá thực tế có thể khác nhau do tính kín đáo
- Map skb-priority to txq thôi chưa đủ, skb-priority to l2 preo
  bản đồ phải được tạo bằng công cụ ip hoặc vconfig
- Bất kỳ l2/socket Prior (0 - 7) nào cho các lớp đều có thể được sử dụng, nhưng đối với
  giá trị mặc định đơn giản được sử dụng: 3 và 2
- chỉ có 2 lớp được kiểm tra: A và B, nhưng đã được kiểm tra và có thể hoạt động với nhiều lớp hơn,
  tối đa cho phép là 4, nhưng chỉ có thể đặt tốc độ cho 3.

Thiết lập thử nghiệm cho các ví dụ
=======================

::

+------------------------------+
					ZZ0000ZZ
					ZZ0001ZZ Máy Trạm0 |
					ZZ0002ZZ MAC 18:03:73:66:87:42 |
    +-----------------------------+ +--ZZ0003ZZ |
    ZZ0004ZZ 1 ZZ0005ZZ |  |h ZZ0007ZZ
    ZZ0008ZZ 0 ZZ0009ZZ--+ ZZ0010ZZ 18:03:73:66:87:42 -i eth0 \|
    ZZ0011ZZ 0 ZZ0012ZZ ZZ0013ZZ -s 1500 |
    ZZ0014ZZ 0 ZZ0015ZZ ZZ0016ZZ
    |  Only 2 classes:   |Mb +---|     +------------------------------+
    ZZ0018ZZ |
    ZZ0019ZZ +---|     +------------------------------+
    ZZ0020ZZ 1 ZZ0021ZZ ZZ0022ZZ
    ZZ0023ZZ 0 ZZ0024ZZ ZZ0025ZZ Máy trạm1 |
    ZZ0026ZZ 0 ZZ0027ZZ--+ ZZ0028ZZ MAC 20:cf:30:85:7d:fd |
    |                    |Mb ZZ0030ZZ +--ZZ0031ZZ |
    +-----------------------------+ ZZ0032ZZ./tsn_listener -d \ |
					ZZ0033ZZ 20:cf:30:85:7d:fd -i eth0 \|
					ZZ0034ZZ -s 1500 |
					ZZ0035ZZ
					+------------------------------+


Ví dụ 1: Sơ đồ cấu hình một cổng tx AVB cho bảng mục tiêu
----------------------------------------------------------------

(bản in và sơ đồ cho AM572x evm, áp dụng cho bảng cổng đơn)

- tc - lớp lưu lượng
- txq - hàng đợi truyền
- p - mức độ ưu tiên
- f - fifo (cpsw fifo)
- Cấu hình S - máy ép

::

+--------------------------------------------------------------------------------+ bạn
    ZZ0000ZZ s
    ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ e
    Ứng dụng ZZ0006ZZ 1 Ứng dụng ZZ0007ZZ 2 Ứng dụng ZZ0008ZZ Ứng dụng ZZ0009ZZ Ứng dụng ZZ0010ZZ r
    ZZ0011ZZ Lớp A ZZ0012ZZ Lớp B ZZ0013ZZ Phần còn lại ZZ0014ZZ Phần còn lại ZZ0015ZZ
    ZZ0016ZZ Eth0 ZZ0017ZZ Eth0 ZZ0018ZZ Eth0 ZZ0019ZZ Eth1 ZZ0020ZZ s
    ZZ0021ZZ VLAN100 ZZ0022ZZ VLAN100 ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ ZZ0026ZZ p
    ZZ0027ZZ 40 Mb/giây ZZ0028ZZ 20 Mb/giây ZZ0029ZZ ZZ0030ZZ ZZ0031ZZ ZZ0032ZZ a
    ZZ0033ZZ SO_PRIORITY=3 ZZ0034ZZ SO_PRIORITY=2 ZZ0035ZZ ZZ0036ZZ ZZ0037ZZ ZZ0038ZZ c
    ZZ0039ZZ ZZ0040ZZ ZZ0041ZZ ZZ0042ZZ ZZ0043ZZ ZZ0044ZZ ZZ0045ZZ e
    ZZ0046ZZ-------------+ +---ZZ0047ZZ--+ +---ZZ0048ZZ
    +------ZZ0049ZZ-------------------ZZ0050ZZ-------------+
	+++-------------+ ZZ0051ZZ
	ZZ0052ZZ +-----------------+ +--+
	ZZ0053ZZ ZZ0054ZZ
    +---ZZ0055ZZ-------------ZZ0056ZZ--------+
    ZZ0057ZZ
    ZZ0058ZZ p3 ZZ0059ZZ p2 ZZ0060ZZ p1 ZZ0061ZZ p0 ZZ0062ZZ p0 ZZ0063ZZ k
    ZZ0064ZZ và
    ZZ0065ZZ r
    ZZ0066ZZ n
    ZZ0067ZZ ZZ0068ZZ ZZ0069ZZ e
    ZZ0070ZZ ZZ0071ZZ | tôi
    ZZ0072ZZ ZZ0073ZZ ZZ0074ZZ
    ZZ0075ZZ s
    | |tc0 | |tc1 | |tc2 |                          |tc0 ZZ0080ZZ p
    ZZ0081ZZ một
    ZZ0082ZZ c
    ZZ0083ZZ và
    ZZ0084ZZ ZZ0085ZZ |
    ZZ0086ZZ ZZ0087ZZ ZZ0088ZZ |
    ZZ0089ZZ ZZ0090ZZ ZZ0091ZZ |
    ZZ0092ZZ ZZ0093ZZ ZZ0094ZZ |
    ZZ0095ZZ
    | |txq0| |txq1| |txq2| |txq3|                   |txq4|             |
    ZZ0102ZZ
    ZZ0103ZZ
    ZZ0104ZZ
    ZZ0105ZZ------ZZ0106ZZ------ZZ0107ZZ----------+ |
    ZZ0108ZZ ZZ0109ZZ ZZ0110ZZ ZZ0111ZZ ZZ0112ZZ |
    +---ZZ0113ZZ------ZZ0114ZZ--------------------------|-------+
	ZZ0115ZZ ZZ0116ZZ |
	p p p p |
	3 2 0-1, 4-7 <- Ưu tiên L2 |
	ZZ0117ZZ ZZ0118ZZ |
	ZZ0119ZZ ZZ0120ZZ |
    +---ZZ0121ZZ------ZZ0122ZZ--------------------------|-------+
    ZZ0123ZZ ZZ0124ZZ ZZ0125ZZ----------+ |
    ZZ0126ZZ
    | |dma7| |dma6| |dma5| |dma4|       |dma3|                         |
    ZZ0133ZZ c
    ZZ0134ZZ p
    ZZ0135ZZ s
    ZZ0136ZZ ZZ0137ZZ +------ ZZ0138ZZ w
    ZZ0139ZZ ZZ0140ZZ ZZ0141ZZ |
    ZZ0142ZZ ZZ0143ZZ ZZ0144ZZ | d
    ZZ0145ZZ r
    ZZ0146ZZ ZZ0147ZZ ZZ0148ZZ ZZ0149ZZ ZZ0150ZZ và
    ZZ0151ZZ f3 ZZ0152ZZ f2 ZZ0153ZZ f0 ZZ0154ZZ f0 ZZ0155ZZ v
    | |tc0 | |tc1 | |tc2 |t            t|tc0 ZZ0160ZZ e
    ZZ0161ZZ r
    ZZ0162ZZ
    ZZ0163ZZ
    +--------------------------------------------------------------------------------+


1) ::


// Thêm 4 hàng đợi tx cho giao diện Eth0 và 1 hàng đợi tx cho Eth1
	$ ethtool -L eth0 rx 1 tx 5
	rx chưa sửa đổi, bỏ qua

2) ::

// Kiểm tra xem số hàng đợi có được đặt chính xác không:
	$ ethtool -l eth0
	Tham số kênh cho eth0:
	Mức tối đa được đặt trước:
	RX: 8
	TX: 8
	Khác: 0
	Kết hợp: 0
	Cài đặt phần cứng hiện tại:
	RX: 1
	TX: 5
	Khác: 0
	Kết hợp: 0

3) ::

// Hàng đợi TX phải được xếp hạng bắt đầu từ 0, vì vậy hãy đặt bws cho tx0 và tx1
	// Đặt tốc độ 40 và 20 Mb/s phù hợp.
	// Hãy chú ý, tốc độ thực có thể khác một chút do tính kín đáo.
	// Để lại 2 hàng đợi tx cuối cùng không được xếp hạng.
	$ echo 40 > /sys/class/net/eth0/queues/tx-0/tx_maxrate
	$ echo 20 > /sys/class/net/eth0/queues/tx-1/tx_maxrate

4) ::

// Kiểm tra tốc độ tối đa của hàng đợi tx (cpdma):
	$ cat /sys/class/net/eth0/queues/tx-*/tx_maxrate
	40
	20
	0
	0
	0

5) ::

// Map skb->ưu tiên tới lớp lưu lượng:
	// 3pri -> tc0, 2pri -> tc1, (0,1,4-7)pri -> tc2
	// Ánh xạ lớp lưu lượng vào hàng đợi truyền:
	// tc0 -> txq0, tc1 -> txq1, tc2 -> (txq2, txq3)
	$ tc qdisc thay thế dev eth0 xử lý 100: gốc mẹ mqprio num_tc 3 \
	bản đồ 2 2 1 0 2 2 2 2 2 2 2 2 2 2 2 2 hàng đợi 1@0 1@1 2@2 hw 1

5a)::

// Vì hai giao diện chia sẻ cùng một bộ hàng đợi tx, hãy chỉ định tất cả lưu lượng truy cập
	// đến giao diện Eth1 để tách hàng đợi để không trộn lẫn
	// với lưu lượng truy cập từ giao diện Eth0, vì vậy hãy sử dụng txq riêng để gửi
	// gói tin tới Eth1, nên tất cả các ưu tiên -> tc0 và tc0 -> txq4
	// Ở đây hw 0 nên ở đây vẫn cấu hình mặc định cho eth1 ở hw
	$ tc qdisc thay thế dev eth1 xử lý 100: gốc gốc mqprio num_tc 1 \
	bản đồ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 hàng đợi 1@4 hw 0

6) ::

// Kiểm tra cài đặt lớp
	$ tc -g hiển thị lớp dev eth0
	+---(100:ffe2) mqprio
	|    +---(100:3) mqprio
	|    +---(100:4) mqprio
	|
	+---(100:ffe1) mqprio
	|    +---(100:2) mqprio
	|
	+---(100:ffe0) mqprio
	    +---(100:1) mqprio

$ tc -g hiển thị lớp dev eth1
	+---(100:ffe0) mqprio
	    +---(100:5) mqprio

7) ::

// Đặt tốc độ cho lớp A - 41 Mbit (tc0, txq0) bằng CBS Qdisc
	// Đặt +1 Mb để dự trữ (quan trọng!)
	// ở đây chỉ có độ dốc nhàn rỗi là quan trọng, các đối số khác bị bỏ qua
	// Hãy chú ý, tốc độ thực có thể khác một chút do tính kín đáo
	$ tc qdisc thêm dev eth0 parent 100:1 cbs locredit -1438 \
	hicredit 62 sendlope -959000 Idleslope 41000 giảm tải 1
	net eth0: đặt FIFO3 bw = 50

8) ::

// Đặt tốc độ cho lớp B - 21 Mbit (tc1, txq1) bằng CBS Qdisc:
	// Đặt +1 Mb để dự trữ (quan trọng!)
	$ tc qdisc thêm dev eth0 parent 100:2 cbs locredit -1468 \
	hicredit 65 sendlope -979000 Idleslope 21000 giảm tải 1
	net eth0: đặt FIFO2 bw = 30

9) ::

// Tạo vlan 100 để ánh xạ sk->ưu tiên vào vlan qos
	$ ip link thêm link eth0 tên eth0.100 gõ vlan id 100
	8021q: 802.1Q VLAN Hỗ trợ v1.8
	8021q: thêm VLAN 0 vào bộ lọc HW trên thiết bị eth0
	8021q: thêm VLAN 0 vào bộ lọc HW trên thiết bị eth1
	net eth0: Thêm vlanid 100 vào bộ lọc vlan

10) ::

// Map skb->priority to L2 preo, 1 to 1
	$ ip liên kết đặt eth0.100 loại vlan \
	đi ra 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7

11) ::

// Kiểm tra sơ đồ lối ra của vlan 100
	$ cat /proc/net/vlan/eth0.100
	[…]
	Ánh xạ ưu tiên INGRESS: 0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0
	Ánh xạ ưu tiên EGRESS: 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7

12) ::

// Chạy các công cụ thích hợp của bạn với tùy chọn socket "SO_PRIORITY"
	// đến 3 cho lớp A và/hoặc đến 2 cho lớp B
	// (mình lấy ở ZZ0000ZZ
	./tsn_talker -d 18:03:73:66:87:42 -i eth0.100 -p3 -s 1500&
	./tsn_talker -d 18:03:73:66:87:42 -i eth0.100 -p2 -s 1500&

13) ::

// chạy trình nghe của bạn trên máy trạm (nên ở cùng một vlan)
	// (mình lấy ở ZZ0000ZZ
	./tsn_listener -d 18:03:73:66:87:42 -i enp5s0 -s 1500
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39000 kbps

14) ::

// Khôi phục cấu hình mặc định nếu cần
	$ liên kết ip del eth0.100
	$ tc qdisc del dev eth1 gốc
	$ tc qdisc del dev eth0 gốc
	net eth0: Trước FIFO2 đã được định hình
	net eth0: đặt FIFO3 bw = 0
	net eth0: đặt FIFO2 bw = 0
	$ ethtool -L eth0 rx 1 tx 1

Ví dụ 2: Sơ đồ cấu hình hai cổng tx AVB cho bảng mục tiêu
----------------------------------------------------------------

(bản in và sơ đồ cho AM572x evm, chỉ dành cho bảng emac kép)

::

+--------------------------------------------------------------------------------+ bạn
    ZZ0000ZZ s
    ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ e
    Ứng dụng ZZ0007ZZ 1 Ứng dụng ZZ0008ZZ 2 Ứng dụng ZZ0009ZZ Ứng dụng ZZ0010ZZ 3 Ứng dụng ZZ0011ZZ 4 ZZ0012ZZ r
    ZZ0013ZZ Lớp A ZZ0014ZZ Lớp B ZZ0015ZZ Phần còn lại ZZ0016ZZ Lớp B ZZ0017ZZ Lớp A ZZ0018ZZ
    ZZ0019ZZ Eth0 ZZ0020ZZ Eth0 ZZ0021ZZ ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ | s
    ZZ0025ZZ VLAN100 ZZ0026ZZ VLAN100 ZZ0027ZZ ZZ0028ZZ ZZ0029ZZ ZZ0030ZZ | p
    ZZ0031ZZ 40 Mb/giây ZZ0032ZZ 20 Mb/giây ZZ0033ZZ ZZ0034ZZ ZZ0035ZZ ZZ0036ZZ | một
    ZZ0037ZZ SO_PRI=3 ZZ0038ZZ SO_PRI=2 ZZ0039ZZ ZZ0040ZZ ZZ0041ZZ ZZ0042ZZ | c
    ZZ0043ZZ ZZ0044ZZ ZZ0045ZZ ZZ0046ZZ ZZ0047ZZ ZZ0048ZZ ZZ0049ZZ ZZ0050ZZ | e
    ZZ0051ZZ------+ +---ZZ0052ZZ--+ +---ZZ0053ZZ------+ |
    +------ZZ0054ZZ-------------ZZ0055ZZ-------------|--------+
	++-+ +-------+ |         +----------+ +----+
	ZZ0056ZZ +-------+------+ ZZ0057ZZ
	ZZ0058ZZ ZZ0059ZZ ZZ0060ZZ
    +---ZZ0061ZZ-------------ZZ0062ZZ-------------ZZ0063ZZ---+
    ZZ0064ZZ
    ZZ0065ZZ p3 ZZ0066ZZ p2 ZZ0067ZZ p1 ZZ0068ZZ p0 ZZ0069ZZ p0 ZZ0070ZZ p1 ZZ0071ZZ p2 ZZ0072ZZ p3 ZZ0073ZZ k
    ZZ0074ZZ và
    ZZ0075ZZ r
    ZZ0076ZZ n
    ZZ0077ZZ ZZ0078ZZ ZZ0079ZZ ZZ0080ZZ e
    ZZ0081ZZ ZZ0082ZZ ZZ0083ZZ l
    ZZ0084ZZ ZZ0085ZZ ZZ0086ZZ ZZ0087ZZ
    ZZ0088ZZ s
    | |tc0 | |tc1 | |tc2 |                        |tc2 | |tc1 | |tc0 ZZ0095ZZ p
    ZZ0096ZZ một
    ZZ0097ZZ c
    ZZ0098ZZ và
    ZZ0099ZZ ZZ0100ZZ ZZ0101ZZ
    ZZ0102ZZ ZZ0103ZZ ZZ0104ZZ ZZ0105ZZ ZZ0106ZZ
    ZZ0107ZZ ZZ0108ZZ ZZ0109ZZ ZZ0110ZZ ZZ0111ZZ
    ZZ0112ZZ ZZ0113ZZ ZZ0114ZZ ZZ0115ZZ ZZ0116ZZ
    ZZ0117ZZ
    | |txq0| |txq1| |txq4| |txq5| h      h |txq6| |txq7| |txq3| |txq2| |
    ZZ0127ZZ
    ZZ0128ZZ
    ZZ0129ZZ
    ZZ0130ZZ------ZZ0131ZZ------ZZ0132ZZ------ZZ0133ZZ------ZZ0134ZZ
    ZZ0135ZZ ZZ0136ZZ ZZ0137ZZ ZZ0138ZZ ZZ0139ZZ ZZ0140ZZ ZZ0141ZZ
    +---ZZ0142ZZ------ZZ0143ZZ-----------ZZ0144ZZ------ZZ0145ZZ------+
	ZZ0146ZZ ZZ0147ZZ ZZ0148ZZ ZZ0149ZZ
	p p p p p p p p
	3 2 0-1, 4-7 <-L2 pri-> 0-1, 4-7 2 3
	ZZ0150ZZ ZZ0151ZZ ZZ0152ZZ ZZ0153ZZ
	ZZ0154ZZ ZZ0155ZZ ZZ0156ZZ ZZ0157ZZ
    +---ZZ0158ZZ------ZZ0159ZZ-----------ZZ0160ZZ------ZZ0161ZZ------+
    ZZ0162ZZ ZZ0163ZZ ZZ0164ZZ ZZ0165ZZ ZZ0166ZZ
    ZZ0167ZZ
    | |dma7| |dma6| |dma3| |dma2|          |dma1| |dma0| |dma4| |dma5| |
    ZZ0177ZZ c
    ZZ0178ZZ p
    ZZ0179ZZ s
    ZZ0180ZZ ZZ0181ZZ +------ ZZ0182ZZ ZZ0183ZZ | w
    ZZ0184ZZ ZZ0185ZZ ZZ0186ZZ ZZ0187ZZ |
    ZZ0188ZZ ZZ0189ZZ ZZ0190ZZ ZZ0191ZZ ZZ0192ZZ d
    ZZ0193ZZ r
    ZZ0194ZZ ZZ0195ZZ ZZ0196ZZ ZZ0197ZZ ZZ0198ZZ ZZ0199ZZ ZZ0200ZZ và
    ZZ0201ZZ f3 ZZ0202ZZ f2 ZZ0203ZZ f0 ZZ0204ZZ f3 ZZ0205ZZ f2 ZZ0206ZZ f0 ZZ0207ZZ v
    | |tc0 | |tc1 | |tc2 |t                      t|tc0 | |tc1 | |tc2 ZZ0214ZZ e
    ZZ0215ZZ r
    ZZ0216ZZ
    ZZ0217ZZ
    +--------------------------------------------------------------------------------+
    ========================================= Eth=================================================================================================

1) ::

// Thêm 8 hàng đợi tx, cho giao diện Eth0, nhưng chúng phổ biến nên được truy cập
	// bởi hai giao diện Eth0 và Eth1.
	$ ethtool -L eth1 rx 1 tx 8
	rx chưa sửa đổi, bỏ qua

2) ::

// Kiểm tra xem số hàng đợi có được đặt chính xác không:
	$ ethtool -l eth0
	Tham số kênh cho eth0:
	Mức tối đa được đặt trước:
	RX: 8
	TX: 8
	Khác: 0
	Kết hợp: 0
	Cài đặt phần cứng hiện tại:
	RX: 1
	TX: 8
	Khác: 0
	Kết hợp: 0

3) ::

// Hàng đợi TX phải được xếp hạng bắt đầu từ 0, vì vậy hãy đặt bws cho tx0 và tx1 cho Eth0
	// và cho tx2 và tx3 cho Eth1. Nghĩa là, tốc độ thích hợp là 40 và 20 Mb/s
	// cho Eth0 và 30 và 10 Mb/s cho Eth1.
	// Tốc độ thực có thể khác một chút do tính kín đáo
	// Để lại 4 hàng đợi tx cuối cùng ở dạng không được xếp hạng
	$ echo 40 > /sys/class/net/eth0/queues/tx-0/tx_maxrate
	$ echo 20 > /sys/class/net/eth0/queues/tx-1/tx_maxrate
	$ echo 30 > /sys/class/net/eth1/queues/tx-2/tx_maxrate
	$ echo 10 > /sys/class/net/eth1/queues/tx-3/tx_maxrate

4) ::

// Kiểm tra tốc độ tối đa của hàng đợi tx (cpdma):
	$ cat /sys/class/net/eth0/queues/tx-*/tx_maxrate
	40
	20
	30
	10
	0
	0
	0
	0

5) ::

// Ánh xạ skb->ưu tiên tới lớp lưu lượng cho Eth0:
	// 3pri -> tc0, 2pri -> tc1, (0,1,4-7)pri -> tc2
	// Ánh xạ lớp lưu lượng vào hàng đợi truyền:
	// tc0 -> txq0, tc1 -> txq1, tc2 -> (txq4, txq5)
	$ tc qdisc thay thế dev eth0 xử lý 100: gốc mẹ mqprio num_tc 3 \
	bản đồ 2 2 1 0 2 2 2 2 2 2 2 2 2 2 2 2 hàng đợi 1@0 1@1 2@4 hw 1

6) ::

// Kiểm tra cài đặt lớp
	$ tc -g hiển thị lớp dev eth0
	+---(100:ffe2) mqprio
	|    +---(100:5) mqprio
	|    +---(100:6) mqprio
	|
	+---(100:ffe1) mqprio
	|    +---(100:2) mqprio
	|
	+---(100:ffe0) mqprio
	    +---(100:1) mqprio

7) ::

// Đặt tốc độ cho lớp A - 41 Mbit (tc0, txq0) bằng CBS Qdisc cho Eth0
	// ở đây chỉ có độ dốc nhàn rỗi là quan trọng, những cái khác bị bỏ qua
	// Tốc độ thực có thể khác một chút do tính kín đáo
	$ tc qdisc thêm dev eth0 parent 100:1 cbs locredit -1470 \
	hicredit 62 sendlope -959000 Idleslope 41000 giảm tải 1
	net eth0: đặt FIFO3 bw = 50

8) ::

// Đặt tốc độ cho lớp B - 21 Mbit (tc1, txq1) bằng CBS Qdisc cho Eth0
	$ tc qdisc thêm dev eth0 parent 100:2 cbs locredit -1470 \
	hicredit 65 sendlope -979000 Idleslope 21000 giảm tải 1
	net eth0: đặt FIFO2 bw = 30

9) ::

// Tạo vlan 100 để ánh xạ sk->ưu tiên vlan qos cho Eth0
	$ ip link thêm link eth0 tên eth0.100 gõ vlan id 100
	net eth0: Thêm vlanid 100 vào bộ lọc vlan

10) ::

// Ánh xạ skb->ưu tiên tới L2 ưu tiên cho Eth0.100, 1-1
	$ ip liên kết đặt eth0.100 loại vlan \
	đi ra 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7

11) ::

// Kiểm tra sơ đồ lối ra của vlan 100
	$ cat /proc/net/vlan/eth0.100
	[…]
	Ánh xạ ưu tiên INGRESS: 0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0
	Ánh xạ ưu tiên EGRESS: 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7

12) ::

// Ánh xạ skb->ưu tiên tới lớp lưu lượng truy cập cho Eth1:
	// 3pri -> tc0, 2pri -> tc1, (0,1,4-7)pri -> tc2
	// Ánh xạ lớp lưu lượng vào hàng đợi truyền:
	// tc0 -> txq2, tc1 -> txq3, tc2 -> (txq6, txq7)
	$ tc qdisc thay thế dev eth1 xử lý 100: gốc gốc mqprio num_tc 3 \
	bản đồ 2 2 1 0 2 2 2 2 2 2 2 2 2 2 2 2 hàng đợi 1@2 1@3 2@6 hw 1

13) ::

// Kiểm tra cài đặt lớp
	$ tc -g hiển thị lớp dev eth1
	+---(100:ffe2) mqprio
	|    +---(100:7) mqprio
	|    +---(100:8) mqprio
	|
	+---(100:ffe1) mqprio
	|    +---(100:4) mqprio
	|
	+---(100:ffe0) mqprio
	    +---(100:3) mqprio

14) ::

// Đặt tốc độ cho lớp A - 31 Mbit (tc0, txq2) bằng CBS Qdisc cho Eth1
	// ở đây chỉ có độ dốc nhàn rỗi là quan trọng, những cái khác bị bỏ qua, nhưng được tính toán
	// cho tốc độ giao diện - 100Mb cho cổng eth1.
	// Đặt +1 Mb để dự trữ (quan trọng!)
	$ tc qdisc thêm dev eth1 parent 100:3 cbs locredit -1035 \
	hicredit 465 sendlope -69000 Idleslope 31000 giảm tải 1
	net eth1: đặt FIFO3 bw = 31

15) ::

// Đặt tốc độ cho lớp B - 11 Mbit (tc1, txq3) bằng CBS Qdisc cho Eth1
	// Đặt +1 Mb để dự trữ (quan trọng!)
	$ tc qdisc thêm dev eth1 parent 100:4 cbs locredit -1335 \
	hicredit 405 sendlope -89000 Idleslope 11000 giảm tải 1
	net eth1: đặt FIFO2 bw = 11

16)::

// Tạo vlan 100 để ánh xạ sk->ưu tiên vlan qos cho Eth1
	$ ip link thêm link eth1 tên eth1.100 gõ vlan id 100
	net eth1: Thêm vlanid 100 vào bộ lọc vlan

17)::

// Ánh xạ skb->ưu tiên tới L2 ưu tiên cho Eth1.100, 1-1
	$ ip liên kết đặt eth1.100 loại vlan \
	đi ra 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7

18)::

// Kiểm tra sơ đồ lối ra của vlan 100
	$ cat /proc/net/vlan/eth1.100
	[…]
	Ánh xạ ưu tiên INGRESS: 0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0
	Ánh xạ ưu tiên EGRESS: 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7

19)::

// Chạy các công cụ thích hợp với tùy chọn socket "SO_PRIORITY" thành 3
	// cho lớp A và 2 cho lớp B. Cho cả hai giao diện
	./tsn_talker -d 18:03:73:66:87:42 -i eth0.100 -p2 -s 1500&
	./tsn_talker -d 18:03:73:66:87:42 -i eth0.100 -p3 -s 1500&
	./tsn_talker -d 20:cf:30:85:7d:fd -i eth1.100 -p2 -s 1500&
	./tsn_talker -d 20:cf:30:85:7d:fd -i eth1.100 -p3 -s 1500&

20)::

// chạy trình nghe của bạn trên máy trạm (nên ở cùng một vlan)
	// (mình lấy ở ZZ0000ZZ
	./tsn_listener -d 18:03:73:66:87:42 -i enp5s0 -s 1500
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39012 kbps
	Tốc độ nhận dữ liệu: 39000 kbps

21)::

// Khôi phục cấu hình mặc định nếu cần
	$ liên kết ip del eth1.100
	$ liên kết ip del eth0.100
	$ tc qdisc del dev eth1 gốc
	net eth1: Trước FIFO2 đã được định hình
	net eth1: đặt FIFO3 bw = 0
	net eth1: đặt FIFO2 bw = 0
	$ tc qdisc del dev eth0 gốc
	net eth0: Trước FIFO2 đã được định hình
	net eth0: đặt FIFO3 bw = 0
	net eth0: đặt FIFO2 bw = 0
	$ ethtool -L eth0 rx 1 tx 1