.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/pktgen.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
HOWTO cho trình tạo gói linux
====================================

Kích hoạt CONFIG_NET_PKTGEN để biên dịch và xây dựng pktgen trong kernel
hoặc dưới dạng mô-đun.  Ưu tiên một mô-đun; modprobe pktgen nếu cần.  Một lần
đang chạy, pktgen tạo một luồng cho mỗi CPU có ái lực với CPU đó.
Việc giám sát và kiểm soát được thực hiện thông qua /proc.  Dễ nhất là chọn một
tập lệnh mẫu phù hợp và cấu hình nó.

Trên CPU kép::

phụ trợ ps | gói grep
    gốc 129 0,3 0,0 0 0 ?        SW 2003 523:20 [kpktgend_0]
    gốc 130 0,3 0,0 0 0 ?        SW 2003 509:50 [kpktgend_1]


Để theo dõi và kiểm soát, pktgen tạo ra::

/proc/net/pktgen/pgctrl
	/proc/net/pktgen/kpktgend_X
	/proc/net/pktgen/ethX


Điều chỉnh NIC để có hiệu suất tối đa
==============================

Cài đặt NIC mặc định (có thể) không được điều chỉnh cho nhân tạo của pktgen
loại điểm chuẩn quá tải, vì điều này có thể gây tổn hại cho trường hợp sử dụng thông thường.

Cụ thể là tăng bộ đệm vòng TX trong NIC::

# ethtool -G ethX tx 1024

Vòng TX lớn hơn có thể cải thiện hiệu suất của pktgen, tuy nhiên nó có thể gây tổn hại
trong trường hợp chung, 1) vì bộ đệm vòng TX có thể lớn hơn
hơn bộ nhớ đệm L1/L2 của CPU, 2) vì nó cho phép xếp hàng nhiều hơn trong
Lớp NIC HW (không tốt cho tình trạng sưng phồng bộ đệm).

Người ta nên ngần ngại khi kết luận rằng các gói/bộ mô tả trong HW
Vòng TX gây ra sự chậm trễ.  Các tài xế thường trì hoãn việc dọn dẹp
bộ đệm vòng vì nhiều lý do hiệu suất khác nhau và các gói bị đình trệ
vòng TX có thể đang chờ dọn dẹp.

Vấn đề dọn dẹp này đặc biệt xảy ra với trình điều khiển ixgbe
(chip Intel 82599).  Trình điều khiển này (ixgbe) kết hợp dọn dẹp vòng TX+RX,
và khoảng thời gian dọn dẹp bị ảnh hưởng bởi cài đặt ethtool --coalesce
của tham số "rx-usecs".

Để sử dụng ixgbe, vd "30" dẫn đến khoảng 33K ngắt/giây (1/30*10^6)::

# ethtool -C ethX rx-usecs 30


Chủ đề hạt nhân
==============
Pktgen tạo một luồng cho mỗi CPU có ái lực với CPU đó.
Được điều khiển thông qua procfile /proc/net/pktgen/kpktgend_X.

Ví dụ: /proc/net/pktgen/kpktgend_0::

Đang chạy:
 Đã dừng: eth4@0
 Kết quả: OK: add_device=eth4@0

Quan trọng nhất là các thiết bị được gán cho thread.

Hai lệnh luồng cơ bản là:

* add_device DEVICE@NAME -- thêm một thiết bị
 * rem_device_all - xóa tất cả các thiết bị được liên kết

Khi thêm một thiết bị vào một luồng, một procfile tương ứng sẽ được tạo
được sử dụng để cấu hình thiết bị này. Vì vậy, tên thiết bị cần phải
trở nên độc đáo.

Để hỗ trợ thêm cùng một thiết bị vào nhiều luồng, điều này rất hữu ích
với các NIC nhiều hàng đợi, sơ đồ đặt tên thiết bị được mở rộng bằng "@":
thiết bị@thứ gì đó

Phần sau "@" có thể là bất cứ thứ gì, nhưng việc sử dụng chuỗi là tùy chỉnh
số.

Xem thiết bị
===============

Phần Params chứa thông tin được cấu hình.  Phần hiện tại
giữ số liệu thống kê đang chạy.  Kết quả được in sau khi chạy hoặc sau
gián đoạn.  Ví dụ::

/proc/net/pktgen/eth4@0

Thông số: đếm 100000 min_pkt_size: 60 max_pkt_size: 60
	mảnh: 0 độ trễ: 0 clone_skb: 64 ifname: eth4@0
	dòng chảy: 0 dòng chảy: 0
	queue_map_min: 0 queue_map_max: 0
	dst_min: 192.168.81.2 dst_max:
	src_min: src_max:
	src_mac: 90:e2:ba:0a:56:b4 dst_mac: 00:1b:21:3c:9d:f8
	udp_src_min: 9 udp_src_max: 109 udp_dst_min: 9 udp_dst_max: 9
	src_mac_count: 0 dst_mac_count: 0
	Cờ: UDPSRC_RND NO_TIMESTAMP QUEUE_MAP_CPU
    Hiện tại:
	pkts-sofar: 100000 lỗi: 0
	đã bắt đầu: 623913381008us đã dừng: 623913396439us không hoạt động: 25us
	seq_num: 100001 cur_dst_mac_offset: 0 cur_src_mac_offset: 0
	cur_saddr: 192.168.8.3 cur_daddr: 192.168.81.2
	cur_udp_dst: 9 cur_udp_src: 42
	cur_queue_map: 0
	dòng chảy: 0
    Kết quả: OK: 15430(c15405+d25) usec, 100000 (60byte,0frags)
    Lỗi 6480562pps 3110Mb/giây (3110669760bps): 0


Cấu hình thiết bị
===================
Việc này được thực hiện thông qua giao diện /proc và được thực hiện dễ dàng nhất thông qua pgset
như được định nghĩa trong các tập lệnh mẫu.
Bạn cần chỉ định biến môi trường PGDEV để sử dụng các hàm từ mẫu
tập lệnh, tức là::

xuất PGDEV=/proc/net/pktgen/eth4@0
    mẫu nguồn/pktgen/functions.sh

Ví dụ::

pg_ctrl start bắt đầu tiêm.
 pg_ctrl dừng hủy bỏ việc tiêm. Ngoài ra, ^C hủy bỏ trình tạo.

pgset "clone_skb 1" đặt số lượng bản sao của cùng một gói
 pgset "clone_skb 0" sử dụng một SKB cho tất cả các lần truyền
 pgset "burst 8" sử dụng xmit_more API để xếp hàng 8 bản sao giống nhau
			 gói và cập nhật con trỏ đuôi hàng đợi HW tx một lần.
			 "bùng nổ 1" là mặc định
 pgset "pkt_size 9014" đặt kích thước gói thành 9014
 Gói pgset "frags 5" sẽ bao gồm 5 đoạn
 pgset "count 200000" đặt số lượng gói cần gửi, được đặt thành 0
			 để gửi liên tục cho đến khi dừng rõ ràng.

pgset "delay 5000" thêm độ trễ cho hard_start_xmit(). nano giây

pgset "dst 10.0.0.1" đặt địa chỉ đích IP
			 (BEWARE! Máy phát điện này rất hung hãn!)

pgset "dst_min 10.0.0.1" Tương tự như dst
 pgset "dst_max 10.0.0.254" Đặt IP đích tối đa.
 pgset "src_min 10.0.0.1" Đặt IP nguồn tối thiểu (hoặc duy nhất).
 pgset "src_max 10.0.0.254" Đặt IP nguồn tối đa.
 pgset "dst6 fec0::1" Địa chỉ đích IPV6
 pgset "src6 fec0::2" Địa chỉ nguồn IPV6
 pgset "dstmac 00:00:00:00:00:00" đặt địa chỉ đích MAC
 pgset "srcmac 00:00:00:00:00:00" đặt địa chỉ nguồn MAC

pgset "queue_map_min 0" Đặt giá trị tối thiểu của khoảng thời gian hàng đợi tx
 pgset "queue_map_max 7" Đặt giá trị tối đa của khoảng thời gian xếp hàng tx, cho các thiết bị nhiều hàng đợi
			 Để chọn hàng đợi 1 của một thiết bị nhất định,
			 sử dụng queue_map_min=1 và queue_map_max=1

pgset "src_mac_count 1" Đặt số lượng MAC mà chúng tôi sẽ duyệt qua.
			 MAC 'tối thiểu' là những gì bạn đặt với srcmac.

pgset "dst_mac_count 1" Đặt số lượng MAC mà chúng tôi sẽ duyệt qua.
			 MAC 'tối thiểu' là những gì bạn đặt với dstmac.

pgset "flag [name]" Đặt cờ để xác định hành vi.  Cờ hiện tại
			 là: Nguồn IPSRC_RND # IP là ngẫu nhiên (trong khoảng tối thiểu/tối đa)
			      Điểm đến IPDST_RND # IP là ngẫu nhiên
			      UDPSRC_RND, UDPDST_RND,
			      MACSRC_RND, MACDST_RND
			      TXSIZE_RND, IPV6,
			      MPLS_RND, VID_RND, SVID_RND
			      FLOW_SEQ,
			      Bản đồ QUEUE_MAP_RND # queue ngẫu nhiên
			      Gương bản đồ QUEUE_MAP_CPU # queue smp_processor_id()
			      UDPCSUM,
			      Đóng gói IPSEC # IPsec (cần CONFIG_XFRM)
			      Phân bổ bộ nhớ cụ thể NODE_ALLOC # node
			      Dấu thời gian NO_TIMESTAMP # disable
			      SHARED # enable đã chia sẻ SKB
 pgset 'flag ![name]' Xóa cờ để xác định hành vi.
			 Lưu ý rằng bạn có thể cần sử dụng dấu ngoặc đơn trong
			 chế độ tương tác, để vỏ của bạn không mở rộng
			 cờ được chỉ định làm lệnh lịch sử.

pgset "spi [SPI_VALUE]" Đặt SA cụ thể được sử dụng để chuyển đổi gói.

pgset "udp_src_min 9" đặt cổng nguồn UDP tối thiểu, Nếu < udp_src_max thì
			 quay vòng qua phạm vi cổng.

pgset "udp_src_max 9" đặt cổng nguồn UDP tối đa.
 pgset "udp_dst_min 9" đặt cổng đích UDP tối thiểu, Nếu < udp_dst_max thì
			 quay vòng qua phạm vi cổng.
 pgset "udp_dst_max 9" đặt tối đa cổng đích UDP.

pgset "mpls 0001000a,0002000a,0000000a" đặt nhãn MPLS (trong ví dụ này
					 nhãn ngoài=16, nhãn giữa=32,
					 nhãn bên trong=0 (IPv4 NULL)) Lưu ý rằng
					 không được có khoảng cách giữa các
					 lý lẽ. Số 0 đứng đầu là bắt buộc.
					 Không đặt phần dưới cùng của bit ngăn xếp,
					 việc đó được thực hiện tự động. Nếu bạn làm
					 đặt phần dưới cùng của bit ngăn xếp, đó
					 chỉ ra rằng bạn muốn ngẫu nhiên
					 tạo địa chỉ đó và cờ
					 MPLS_RND sẽ được bật. bạn
					 có thể có bất kỳ sự kết hợp nào giữa ngẫu nhiên và cố định
					 nhãn trong ngăn xếp nhãn.

pgset "mpls 0" tắt mpls (hoặc bất kỳ đối số không hợp lệ nào cũng hoạt động!)

pgset "vlan_id 77" đặt ID VLAN 0-4095
 pgset "vlan_p 3" đặt bit ưu tiên 0-7 (mặc định 0)
 pgset "vlan_cfi 0" đặt định danh định dạng chuẩn 0-1 (mặc định 0)

pgset "svlan_id 22" đặt SVLAN ID 0-4095
 pgset "svlan_p 3" đặt bit ưu tiên 0-7 (mặc định 0)
 pgset "svlan_cfi 0" đặt định danh định dạng chuẩn 0-1 (mặc định 0)

pgset "vlan_id 9999" > 4095 xóa thẻ vlan và svlan
 pgset "svlan 9999"> 4095 xóa thẻ svlan


pgset "tos XX" đặt trường IPv4 TOS cũ (ví dụ: "tos 28" cho AF11 no ECN, mặc định 00)
 pgset "traffic_class XX" đặt IPv6 TRAFFIC CLASS cũ (ví dụ: "traffic_class B8" cho EF no ECN, mặc định 00)

pgset "tốc độ 300M" đặt tốc độ thành 300 Mb/s
 pgset "ratep 1000000" đặt tốc độ thành 1Mpps

pgset "xmit_mode netif_receive" RX đưa vào ngăn xếp netif_receive_skb()
				  Hoạt động với "burst" nhưng không hoạt động với "clone_skb".
				  Xmit_mode mặc định là "start_xmit".

Kịch bản mẫu
==============

Một tập hợp các tập lệnh hướng dẫn và trợ giúp dành cho pktgen có trong
thư mục mẫu/pktgen. Các tập tin trợ giúp tham số.sh hỗ trợ dễ dàng
và phân tích tham số nhất quán trên các tập lệnh mẫu.

Ví dụ sử dụng và trợ giúp::

./pktgen_sample01_simple.sh -i eth4 -m 00:1B:21:3C:9D:F8 -d 192.168.8.2

Cách sử dụng:::

./pktgen_sample01_simple.sh [-vx] -i ethX

-i : ($DEV) giao diện/thiết bị đầu ra (bắt buộc)
  -s : ($PKT_SIZE) kích thước gói
  -d : ($DEST_IP) IP đích. CIDR (ví dụ: 198.18.0.0/15) cũng được cho phép
  -m : ($DST_MAC) đích MAC-addr
  -p : ($DST_PORT) phạm vi PORT đích (ví dụ: 433-444) cũng được cho phép
  -t : ($THREADS) chủ đề để bắt đầu
  -f : ($F_THREAD) chỉ mục của luồng đầu tiên (số CPU được lập chỉ mục bằng 0)
  -c : ($SKB_CLONE) Bản sao SKB gửi trước khi phân bổ SKB mới
  -n : ($COUNT) số tin nhắn cần gửi trên mỗi chuỗi, 0 có nghĩa là vô thời hạn
  -b : ($BURST) Mức độ CTNH của SKB tăng vọt
  -v : ($VERBOSE) dài dòng
  -x : ($DEBUG) gỡ lỗi
  -6 : ($IP6) IPv6
  -w : ($DELAY) Giá trị độ trễ Tx (ns)
  -a : ($APPEND) Tập lệnh sẽ không đặt lại trạng thái của trình tạo nhưng sẽ nối thêm cấu hình của nó

Các biến toàn cục đang được đặt cũng được liệt kê.  Ví dụ. yêu cầu
tham số giao diện/thiết bị "-i" đặt biến $DEV.  Sao chép
pktgen_sampleXX và sửa đổi chúng để phù hợp với nhu cầu của riêng bạn.


Mối quan hệ gián đoạn
===================
Lưu ý rằng khi thêm thiết bị vào CPU cụ thể, bạn nên
đồng thời gán /proc/irq/XX/smp_affinity để các ngắt TX bị ràng buộc
đến cùng một CPU.  Điều này làm giảm tình trạng nảy bộ đệm khi giải phóng skbs.

Ngoài ra, việc sử dụng cờ thiết bị QUEUE_MAP_CPU, ánh xạ hàng đợi TX của SKB
tới các luồng đang chạy CPU (trực tiếp từ smp_processor_id()).

Bật IPsec
============
Chuyển đổi IPsec mặc định với chế độ đóng gói ESP cộng với chế độ vận chuyển
có thể được kích hoạt bằng cách chỉ cần cài đặt ::

pgset "cờ IPSEC"
    pgset "dòng 1"

Để tránh phá vỡ các tập lệnh thử nghiệm hiện có khi sử dụng loại AH và chế độ đường hầm,
bạn có thể sử dụng "pgset spi SPI_VALUE" để chỉ định chế độ chuyển đổi nào
để tuyển dụng.

Tắt SKB được chia sẻ
==================
Theo mặc định, SKB gửi bởi pktgen được chia sẻ (số lượng người dùng > 1).
Để kiểm tra với SKB không được chia sẻ, hãy xóa cờ "SHARED" bằng cách chỉ cần cài đặt::

pg_set "cờ !SHARED"

Tuy nhiên, nếu tham số "clone_skb" hoặc "burst" được định cấu hình, skb
vẫn cần được pktgen giữ để truy cập thêm. Do đó skb phải là
đã chia sẻ.

Các lệnh hiện tại và tùy chọn cấu hình
==========================================

ZZ0000ZZ::

bắt đầu
    dừng lại
    đặt lại

ZZ0000ZZ::

thêm_thiết bị
    rem_device_all


ZZ0000ZZ::

đếm
    bản sao_skb
    nổ tung
    gỡ lỗi

mảnh vỡ
    sự chậm trễ

src_mac_count
    dst_mac_count

gói_kích thước
    kích thước tối thiểu_pkt_
    max_pkt_size

hàng_map_min
    hàng_map_max
    skb_priority

tos (ipv4)
    lớp_giao thông (ipv6)

mpls

udp_src_min
    udp_src_max

udp_dst_min
    udp_dst_max

nút

cờ
    IPSRC_RND
    IPDST_RND
    UDPSRC_RND
    UDPDST_RND
    MACSRC_RND
    MACDST_RND
    TXSIZE_RND
    IPV6
    MPLS_RND
    VID_RND
    SVID_RND
    FLOW_SEQ
    QUEUE_MAP_RND
    QUEUE_MAP_CPU
    UDPCSUM
    IPSEC
    NODE_ALLOC
    NO_TIMESTAMP
    SHARED

spi (ipsec)

dst_min
    dst_max

src_min
    src_max

dst_mac
    src_mac

Clear_counters

src6
    dst6
    dst6_max
    dst6_min

dòng chảy
    trôi chảy

tỷ lệ
    tỷ lệ

xmit_mode <start_xmit|netif_receive>

vlan_cfi
    vlan_id
    vlan_p

svlan_cfi
    svlan_id
    svlan_p


Tài liệu tham khảo:

- ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/
- ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/examples/

Bài viết từ Linux-Kongress trong Erlangen 2004.
- ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/pktgen_paper.pdf

Cảm ơn:

Cấp cho Grundler để thử nghiệm trên IA-64 và parisc, Harald Welte, Lennert Buytenhek
Stephen Hemminger, Andi Kleen, Dave Miller và nhiều người khác.


Chúc may mắn với việc phát triển mạng linux.