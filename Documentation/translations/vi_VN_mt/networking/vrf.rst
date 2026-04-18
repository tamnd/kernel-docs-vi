.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/vrf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Định tuyến và chuyển tiếp ảo (VRF)
====================================

Thiết bị VRF
==============

Thiết bị VRF kết hợp với ip Rules mang đến khả năng tạo ảo
các miền định tuyến và chuyển tiếp (còn gọi là VRF, cụ thể là VRF-lite) trong
Ngăn xếp mạng Linux. Một trường hợp sử dụng là vấn đề nhiều bên thuê trong đó mỗi bên
người thuê có bảng định tuyến riêng và ít nhất cần
các cổng mặc định khác nhau.

Các quy trình có thể được "nhận biết VRF" bằng cách liên kết ổ cắm với thiết bị VRF. Gói
thông qua ổ cắm sau đó sử dụng bảng định tuyến được liên kết với VRF
thiết bị. Một tính năng quan trọng của việc triển khai thiết bị VRF là nó
chỉ tác động đến Lớp 3 trở lên nên các công cụ L2 (ví dụ: LLDP) không bị ảnh hưởng
(tức là chúng không cần phải chạy trong mỗi VRF). Thiết kế cũng cho phép
việc sử dụng các quy tắc ip có mức độ ưu tiên cao hơn (Định tuyến dựa trên chính sách, PBR) để thực hiện
được ưu tiên hơn các quy tắc của thiết bị VRF để điều hướng lưu lượng truy cập cụ thể theo ý muốn.

Ngoài ra, các thiết bị VRF cho phép VRF được lồng trong các không gian tên. cho
ví dụ về không gian tên mạng cung cấp sự phân tách các giao diện mạng tại
lớp thiết bị, Vlan trên các giao diện trong không gian tên cung cấp khả năng phân tách L2
và sau đó các thiết bị VRF cung cấp khả năng phân tách L3.

Thiết kế
------
Một thiết bị VRF được tạo với bảng lộ trình liên quan. Giao diện mạng
sau đó bị bắt làm nô lệ cho thiết bị VRF::

+-----------------------------+
	 ZZ0000ZZ ===> bảng lộ trình 10
	 +-----------------------------+
	    ZZ0001ZZ |
	 +------+ +------+ +-------------+
	 ZZ0002ZZ ZZ0003ZZ ... ZZ0004ZZ
	 +------+ +------+ +-------------+
				  ZZ0005ZZ
			      +------+ +------+
			      ZZ0006ZZ ZZ0007ZZ
			      +------+ +------+

Các gói nhận được trên thiết bị nô lệ và được chuyển sang thiết bị VRF
trong ngăn xếp xử lý IPv4 và IPv6 tạo ấn tượng rằng các gói
chảy qua thiết bị VRF. Tương tự, các quy tắc định tuyến đầu ra được sử dụng để
gửi gói đến trình điều khiển thiết bị VRF trước khi gửi đi thực tế
giao diện. Điều này cho phép tcpdump trên thiết bị VRF nắm bắt tất cả các gói vào
và ngoài VRF nói chung\ [1]_. Tương tự, các quy tắc netfilter\ [2]_ và tc
có thể được áp dụng bằng thiết bị VRF để chỉ định các quy tắc áp dụng cho VRF
miền nói chung.

.. [1] Packets in the forwarded state do not flow through the device, so those
       packets are not seen by tcpdump. Will revisit this limitation in a
       future release.

.. [2] Iptables on ingress supports PREROUTING with skb->dev set to the real
       ingress device and both INPUT and PREROUTING rules with skb->dev set to
       the VRF device. For egress POSTROUTING and OUTPUT rules can be written
       using either the VRF device or real egress device.

Cài đặt
-----
1. Thiết bị VRF được tạo với sự liên kết với bảng FIB.
   ví dụ,::

liên kết ip thêm bảng vrf loại vrf-blue 10
	liên kết ip thiết lập dev vrf-blue up

2. Quy tắc l3mdev FIB hướng các tra cứu đến bảng được liên kết với thiết bị.
   Một quy tắc l3mdev duy nhất là đủ cho tất cả các VRF. Thiết bị VRF bổ sung thêm
   quy tắc l3mdev cho IPv4 và IPv6 khi thiết bị đầu tiên được tạo bằng
   tùy chọn mặc định là 1000. Người dùng có thể xóa quy tắc nếu muốn và thêm
   với mức độ ưu tiên khác hoặc cài đặt theo quy tắc VRF.

Trước kernel v4.8, các quy tắc iif và oif là cần thiết cho mỗi thiết bị VRF::

ip ru add oif vrf-blue bảng 10
       ip ru add iif vrf-blue bảng 10

3. Đặt tuyến mặc định cho bảng (và do đó là tuyến mặc định cho VRF)::

tuyến ip thêm bảng 10 số liệu mặc định không thể truy cập 4278198272

Giá trị số liệu cao này đảm bảo rằng tuyến đường không thể truy cập mặc định có thể
   bị ghi đè bởi bộ giao thức định tuyến.  FRRouting phiên dịch
   số liệu hạt nhân dưới dạng khoảng cách quản trị viên kết hợp (byte trên) và mức độ ưu tiên
   (thấp hơn 3 byte).  Do đó, số liệu trên chuyển thành [255/8192].

4. Áp dụng giao diện L3 cho thiết bị VRF::

liên kết ip được đặt dev eth1 master vrf-blue

Các tuyến cục bộ và được kết nối cho các thiết bị nô lệ sẽ tự động được chuyển đến
   bảng được liên kết với thiết bị VRF. Bất kỳ tuyến đường bổ sung nào tùy thuộc vào
   thiết bị nô lệ bị rơi và sẽ cần được lắp lại vào VRF
   Bảng FIB sau thời kỳ nô lệ.

Tùy chọn sysctl IPv6 keep_addr_on_down có thể được bật để duy trì IPv6 trên toàn cầu
   địa chỉ khi chế độ nô lệ VRF thay đổi::

sysctl -w net.ipv6.conf.all.keep_addr_on_down=1

5. Các tuyến VRF bổ sung được thêm vào bảng liên kết::

lộ trình ip thêm bảng 10 ...


Ứng dụng
------------
Các ứng dụng hoạt động trong VRF cần liên kết ổ cắm của chúng với
Thiết bị VRF::

setsockopt(sd, SOL_SOCKET, SO_BINDTODEVICE, dev, strlen(dev)+1);

hoặc để chỉ định thiết bị đầu ra bằng cmsg và IP_PKTINFO.

Theo mặc định, phạm vi liên kết cổng cho ổ cắm không liên kết là
giới hạn ở VRF mặc định. Tức là nó sẽ không khớp với các gói
đến các giao diện được bắt làm nô lệ cho l3mdev và các quy trình có thể liên kết với
cùng một cổng nếu chúng liên kết với l3mdev.

Các dịch vụ TCP & UDP chạy trong ngữ cảnh VRF mặc định (nghĩa là không bị ràng buộc
với mọi thiết bị VRF) có thể hoạt động trên tất cả các miền VRF bằng cách bật
Tùy chọn tcp_l3mdev_accept và udp_l3mdev_accept sysctl::

sysctl -w net.ipv4.tcp_l3mdev_accept=1
    sysctl -w net.ipv4.udp_l3mdev_accept=1

Các tùy chọn này bị tắt theo mặc định nên ổ cắm trong VRF chỉ được sử dụng
được chọn cho các gói trong VRF đó. Có một tùy chọn tương tự cho RAW
socket, được bật theo mặc định vì lý do tương thích ngược.
Điều này nhằm chỉ định thiết bị đầu ra có cmsg và IP_PKTINFO, nhưng
sử dụng ổ cắm không bị ràng buộc với VRF tương ứng. Điều này cho phép ví dụ: ping cũ hơn
các triển khai sẽ được chạy với việc chỉ định thiết bị nhưng không thực thi nó
trong VRF. Tùy chọn này có thể bị tắt để các gói nhận được trong VRF
ngữ cảnh chỉ được xử lý bởi một ổ cắm thô được liên kết với VRF và các gói trong
VRF mặc định chỉ được xử lý bởi một ổ cắm không bị ràng buộc với bất kỳ VRF nào ::

sysctl -w net.ipv4.raw_l3mdev_accept=0

quy tắc netfilter trên thiết bị VRF có thể được sử dụng để hạn chế quyền truy cập vào các dịch vụ
cũng chạy trong ngữ cảnh VRF mặc định.

Sử dụng các ứng dụng nhận biết VRF (các ứng dụng đồng thời tạo các ổ cắm
bên ngoài và bên trong VRF) kết hợp với ZZ0000ZZ
là có thể nhưng có thể dẫn đến vấn đề trong một số trường hợp. Với sysctl đó
giá trị, không xác định được ổ cắm nghe nào sẽ được chọn để xử lý
kết nối cho lưu lượng VRF; tức là. ổ cắm được liên kết với VRF hoặc ổ cắm không liên kết
ổ cắm có thể được sử dụng để chấp nhận các kết nối mới từ VRF. Điều này phần nào
hành vi không mong muốn có thể dẫn đến sự cố nếu ổ cắm được cấu hình thêm
tùy chọn (ví dụ: khóa TCP MD5) với kỳ vọng rằng lưu lượng truy cập VRF sẽ
được xử lý độc quyền bởi các ổ cắm được liên kết với VRF, như trường hợp của
ZZ0001ZZ. Cuối cùng và như một lời nhắc nhở, bất kể
socket nghe nào được chọn, các socket đã thiết lập sẽ được tạo trong
VRF dựa trên giao diện xâm nhập, như được ghi lại trước đó.

--------------------------------------------------------------------------------

Sử dụng iproute2 cho VRF
=======================
iproute2 hỗ trợ từ khóa vrf kể từ v4.7. Để tương thích ngược, điều này
phần liệt kê cả hai lệnh khi thích hợp -- với từ khóa vrf và
hình thức cũ hơn mà không có nó.

1. Tạo VRF

Để khởi tạo thiết bị VRF và liên kết thiết bị đó với bảng::

$ ip link thêm dev NAME loại bảng vrf ID

Kể từ v4.8, kernel hỗ trợ quy tắc l3mdev FIB trong đó một quy tắc duy nhất
   bao gồm tất cả các VRF. Quy tắc l3mdev được tạo cho IPv4 và IPv6 trước tiên
   tạo thiết bị.

2. Liệt kê các VRF

Để liệt kê các VRF đã được tạo::

$ ip [-d] liên kết hiển thị loại vrf
	 NOTE: Cần có tùy chọn -d để hiển thị id bảng

Ví dụ::

$ ip -d liên kết hiển thị loại vrf
       11: mgmt: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái UP chế độ mặc định nhóm DEFAULT qlen 1000
	   link/ether 72:b3:ba:91:e2:24 brd ff:ff:ff:ff:ff:ff lăng nhăng 0
	   bảng vrf 1 addrgenmode eui64
       12: đỏ: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái UP Chế độ mặc định nhóm DEFAULT qlen 1000
	   link/ether b6:6f:6e:f6:da:73 brd ff:ff:ff:ff:ff:ff lăng nhăng 0
	   bảng vrf 10 addrgenmode eui64
       13: xanh dương: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái UP chế độ DEFAULT nhóm mặc định qlen 1000
	   link/ether 36:62:e8:7d:bb:8c brd ff:ff:ff:ff:ff:ff lăng nhăng 0
	   bảng vrf 66 addrgenmode eui64
       14: màu xanh lá cây: <NOARP,MASTER,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái UP chế độ DEFAULT nhóm mặc định qlen 1000
	   link/ether e6:28:b8:63:70:bb brd ff:ff:ff:ff:ff:ff lăng nhăng 0
	   bảng vrf 81 addrgenmode eui64


Hoặc trong đầu ra ngắn gọn::

$ ip -br liên kết hiển thị loại vrf
       mgmt LÊN 72:b3:ba:91:e2:24 <NOARP,MASTER,UP,LOWER_UP>
       màu đỏ LÊN b6:6f:6e:f6:da:73 <NOARP,MASTER,UP,LOWER_UP>
       xanh lam LÊN 36:62:e8:7d:bb:8c <NOARP,MASTER,UP,LOWER_UP>
       màu xanh lá cây LÊN e6:28:b8:63:70:bb <NOARP,MASTER,UP,LOWER_UP>


3. Gán giao diện mạng cho VRF

Giao diện mạng được gán cho VRF bằng cách gán thiết bị mạng cho một
   Thiết bị VRF::

$ ip link set dev NAME master NAME

Khi làm nô lệ, các tuyến đường được kết nối và cục bộ sẽ tự động được chuyển đến
   bảng được liên kết với thiết bị VRF.

Ví dụ::

$ ip liên kết thiết lập dev eth0 master mgmt


4. Hiển thị các thiết bị được gán cho VRF

Để hiển thị các thiết bị đã được gán cho một VRF cụ thể, hãy thêm thiết bị chính
   tùy chọn cho lệnh ip ::

$ ip link hiển thị vrf NAME
       $ ip link show master NAME

Ví dụ::

$ ip liên kết hiển thị vrf màu đỏ
       3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái đỏ chính Chế độ UP chế độ UP mặc định của nhóm DEFAULT qlen 1000
	   liên kết/ether 02:00:00:00:02:02 brd ff:ff:ff:ff:ff:ff
       4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái đỏ chính Chế độ UP chế độ UP mặc định của nhóm DEFAULT qlen 1000
	   liên kết/ether 02:00:00:00:02:03 brd ff:ff:ff:ff:ff:ff
       7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master trạng thái màu đỏ DOWN chế độ DEFAULT nhóm mặc định qlen 1000
	   liên kết/ether 02:00:00:00:02:06 brd ff:ff:ff:ff:ff:ff


Hoặc sử dụng đầu ra ngắn gọn::

$ ip -br liên kết hiển thị vrf màu đỏ
       eth1 LÊN 02:00:00:00:02:02 <BROADCAST,MULTICAST,UP,LOWER_UP>
       eth2 LÊN 02:00:00:00:02:03 <BROADCAST,MULTICAST,UP,LOWER_UP>
       eth5 DOWN 02:00:00:00:02:06 <BROADCAST,MULTICAST>


5. Hiển thị các mục hàng xóm cho VRF

Để liệt kê các mục lân cận được liên kết với các thiết bị được gắn với thiết bị VRF
   thêm tùy chọn chính vào lệnh ip ::

$ ip [-6] hiển thị hàng xóm vrf NAME
       $ ip [-6] hàng xóm hiển thị chủ NAME

Ví dụ::

$ ip neigh hiển thị vrf đỏ
       10.2.1.254 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE
       10.2.2.254 dev eth2 lladdr 5e:54:01:6a:ee:80 REACHABLE

$ ip -6 hiển thị vrf đỏ
       2002:1::64 dev eth1 lladdr a6:d9:c7:4f:06:23 REACHABLE


6. Hiển thị địa chỉ của VRF

Để hiển thị địa chỉ cho các giao diện được liên kết với VRF, hãy thêm địa chỉ chính
   tùy chọn cho lệnh ip ::

$ ip addr hiển thị vrf NAME
       $ ip addr show master NAME

Ví dụ::

$ ip addr hiển thị vrf đỏ
	3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái đỏ chính của nhóm UP mặc định qlen 1000
	    liên kết/ether 02:00:00:00:02:02 brd ff:ff:ff:ff:ff:ff
	    inet 10.2.1.2/24 brd 10.2.1.255 phạm vi toàn cầu eth1
	       valid_lft mãi mãi ưa thích_lft mãi mãi
	    inet6 2002:1::2/120 phạm vi toàn cầu
	       valid_lft mãi mãi ưa thích_lft mãi mãi
	    liên kết phạm vi inet6 fe80::ff:fe00:202/64
	       valid_lft mãi mãi ưa thích_lft mãi mãi
	4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast trạng thái đỏ chính của nhóm UP mặc định qlen 1000
	    liên kết/ether 02:00:00:00:02:03 brd ff:ff:ff:ff:ff:ff
	    inet 10.2.2.2/24 brd 10.2.2.255 phạm vi toàn cầu eth2
	       valid_lft mãi mãi ưa thích_lft mãi mãi
	    inet6 2002:2::2/120 phạm vi toàn cầu
	       valid_lft mãi mãi ưa thích_lft mãi mãi
	    liên kết phạm vi inet6 fe80::ff:fe00:203/64
	       valid_lft mãi mãi ưa thích_lft mãi mãi
	7: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master trạng thái màu đỏ DOWN nhóm mặc định qlen 1000
	    liên kết/ether 02:00:00:00:02:06 brd ff:ff:ff:ff:ff:ff

Hoặc ở dạng ngắn gọn::

$ ip -br addr hiển thị vrf đỏ
	eth1 LÊN 10.2.1.2/24 2002:1::2/120 fe80::ff:fe00:202/64
	eth2 LÊN 10.2.2.2/24 2002:2::2/120 fe80::ff:fe00:203/64
	eth5 DOWN


7. Hiển thị lộ trình cho VRF

Để hiển thị các tuyến đường cho VRF, hãy sử dụng lệnh ip để hiển thị bảng được liên kết
   với thiết bị VRF::

$ ip [-6] lộ trình hiển thị vrf NAME
       $ ip [-6] ID bảng hiển thị lộ trình

Ví dụ::

$ ip lộ trình hiển thị vrf đỏ
	số liệu mặc định không thể truy cập 4278198272
	phát sóng 10.2.1.0 dev eth1 liên kết phạm vi hạt nhân proto src 10.2.1.2
	10.2.1.0/24 dev eth1 liên kết phạm vi hạt nhân proto src 10.2.1.2
	local 10.2.1.2 dev eth1 proto kernel phạm vi máy chủ src 10.2.1.2
	phát sóng 10.2.1.255 dev eth1 liên kết phạm vi hạt nhân nguyên mẫu src 10.2.1.2
	phát sóng 10.2.2.0 dev eth2 liên kết phạm vi hạt nhân proto src 10.2.2.2
	10.2.2.0/24 dev eth2 liên kết phạm vi hạt nhân proto src 10.2.2.2
	local 10.2.2.2 dev eth2 proto kernel phạm vi máy chủ src 10.2.2.2
	phát sóng 10.2.2.255 dev eth2 liên kết phạm vi hạt nhân proto src 10.2.2.2

$ ip -6 lộ trình hiển thị vrf đỏ
	local 2002:1:: dev lo proto none số liệu 0 pref trung bình
	local 2002:1::2 dev lo proto none số liệu 0 pref trung bình
	2002:1::/120 dev eth1 hạt nhân nguyên mẫu số liệu 256 môi trường pref
	local 2002:2:: dev lo proto none số liệu 0 pref trung bình
	local 2002:2::2 dev lo proto none số liệu 0 pref trung bình
	2002:2::/120 dev eth2 proto kernel số liệu 256 pref media
	local fe80:: dev lo proto none số liệu 0 pref trung bình
	local fe80:: dev lo proto none số liệu 0 pref trung bình
	local fe80::ff:fe00:202 dev lo proto none số liệu 0 pref Medium
	local fe80::ff:fe00:203 dev lo proto none số liệu 0 pref Medium
	fe80::/64 dev eth1 hạt nhân nguyên mẫu số liệu 256 môi trường pref
	fe80::/64 dev eth2 hạt nhân nguyên mẫu số liệu 256 môi trường pref
	ff00::/8 dev red số liệu 256 pref trung bình
	ff00::/8 dev eth1 số liệu 256 pref trung bình
	ff00::/8 dev eth2 số liệu 256 pref trung bình
	lỗi mặc định của nhà phát triển không thể truy cập được lỗi 4278198272 -101 phương tiện trước

8. Tra cứu lộ trình cho VRF

Việc tra cứu tuyến đường thử nghiệm có thể được thực hiện cho VRF::

$ ip [-6] tuyến nhận vrf NAME ADDRESS
       $ ip [-6] tuyến nhận oif NAME ADDRESS

Ví dụ::

$ ip tuyến nhận 10.2.1.40 vrf đỏ
	10.2.1.40 bảng dev eth1 đỏ src 10.2.1.2
	    bộ nhớ đệm

$ ip -6 tuyến get 2002:1::32 vrf đỏ
	2002:1::32 từ :: dev eth1 bảng red proto kernel src 2002:1::2 số liệu 256 pref Medium


9. Xóa giao diện mạng khỏi VRF

Giao diện mạng bị xóa khỏi VRF bằng cách phá bỏ chế độ nô lệ cho
   thiết bị VRF::

$ ip link set dev NAME nomaster

Các tuyến đã kết nối sẽ được chuyển trở lại bảng mặc định và các mục cục bộ được
   chuyển đến bảng cục bộ.

Ví dụ::

$ ip liên kết đặt dev eth0 nomaster

--------------------------------------------------------------------------------

Các lệnh được sử dụng trong ví dụ này::

mèo >> /etc/iproute2/rt_tables.d/vrf.conf <<EOF
     1 mgt
     10 màu đỏ
     66 màu xanh
     81 màu xanh lá cây
     EOF

chức năng vrf_create
     {
	 VRF=$1
	 TBID=$2

Thiết bị # create VRF
	 liên kết ip thêm ${VRF} loại bảng vrf ${TBID}

nếu [ "${VRF}" != "mgmt" ]; sau đó
	     định tuyến ip thêm bảng ${TBID} số liệu mặc định không thể truy cập được 4278198272
	 fi
	 liên kết ip thiết lập dev ${VRF} lên
     }

vrf_create mgmt 1
     liên kết ip được đặt dev eth0 master mgmt

vrf_create đỏ 10
     liên kết ip thiết lập dev eth1 master màu đỏ
     liên kết ip thiết lập dev eth2 master màu đỏ
     liên kết ip bộ dev eth5 master màu đỏ

vrf_create xanh 66
     liên kết ip bộ dev eth3 master màu xanh

vrf_create xanh 81
     bộ liên kết ip dev eth4 master màu xanh lá cây


Địa chỉ giao diện từ /etc/network/interfaces:
     tự động eth0
     iface eth0 inet tĩnh
	   địa chỉ 10.0.0.2
	   mặt nạ mạng 255.255.255.0
	   cổng 10.0.0.254

iface eth0 inet6 tĩnh
	   địa chỉ 2000:1::2
	   mặt nạ mạng 120

tự động eth1
     iface eth1 inet tĩnh
	   địa chỉ 10.2.1.2
	   mặt nạ mạng 255.255.255.0

iface eth1 inet6 tĩnh
	   địa chỉ 2002:1::2
	   mặt nạ mạng 120

tự động eth2
     iface eth2 inet tĩnh
	   địa chỉ 10.2.2.2
	   mặt nạ mạng 255.255.255.0

iface eth2 inet6 tĩnh
	   địa chỉ 2002:2::2
	   mặt nạ mạng 120

tự động eth3
     iface eth3 inet tĩnh
	   địa chỉ 10.2.3.2
	   mặt nạ mạng 255.255.255.0

iface eth3 inet6 tĩnh
	   địa chỉ 2002:3::2
	   mặt nạ mạng 120

tự động eth4
     iface eth4 inet tĩnh
	   địa chỉ 10.2.4.2
	   mặt nạ mạng 255.255.255.0

iface eth4 inet6 tĩnh
	   địa chỉ 2002:4::2
	   mặt nạ mạng 120