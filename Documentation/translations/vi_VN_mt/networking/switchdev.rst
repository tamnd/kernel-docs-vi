.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/switchdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>
.. _switchdev:

====================================================
Mô hình trình điều khiển thiết bị chuyển mạch Ethernet (switchdev)
===============================================

Bản quyền ZZ0000ZZ 2014 Jiri Pirko <jiri@resnulli.us>

Bản quyền ZZ0000ZZ 2014-2015 Scott Feldman <sfeldma@gmail.com>


Mô hình trình điều khiển thiết bị chuyển mạch Ethernet (switchdev) là trình điều khiển trong kernel
mô hình cho các thiết bị chuyển mạch giảm tải mặt phẳng chuyển tiếp (dữ liệu) từ
hạt nhân.

Hình 1 là sơ đồ khối hiển thị các thành phần của mô hình switchdev cho
một thiết lập ví dụ sử dụng chip ASIC của bộ chuyển đổi lớp trung tâm dữ liệu.  Các thiết lập khác
có thể sử dụng SR-IOV hoặc các công tắc mềm, chẳng hạn như OVS.

::


Công cụ không gian người dùng

không gian người dùng |
      +--------------------------------------------------------------------------------+
       hạt nhân | liên kết mạng
				    |
		     +--------------+------------------------------ +
		     ZZ0000ZZ
		     ZZ0001ZZ
		     ZZ0002ZZ
		     +---------------------------------------------- +

sw1p2 sw1p4 sw1p6
		      sw1p1 + sw1p3 + sw1p5 + eth1
			+ ZZ0000ZZ + |            +
			ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ |
		     +--+----+----+----+----+----+---+ +------+------+
		     ZZ0004ZZ ZZ0005ZZ
		     ZZ0006ZZ ZZ0007ZZ
		     ZZ0008ZZ ZZ0009ZZ
		     +--------------+-------+ +--------------+
				    |
       hạt nhân | Xe buýt CTNH (ví dụ PCI)
      +--------------------------------------------------------------------------------+
       phần cứng |
		     +--------------+-------+
		     ZZ0010ZZ
		     |  +----+ +--------+
		     Đường dẫn dữ liệu giảm tải ZZ0011ZZ v | cổng quản lý
		     ZZ0012ZZ ZZ0013ZZ
		     +--ZZ0014ZZ----+----+----+----+---+
			ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ
			+ + + + + +
		       p1 p2 p3 p4 p5 p6

cổng bảng mặt trước


Hình 1.


Bao gồm các tệp
-------------

::

#include <linux/netdevice.h>
    #include <net/switchdev.h>


Cấu hình
-------------

Sử dụng "phụ thuộc NET_SWITCHDEV" trong Kconfig của trình điều khiển để đảm bảo mô hình switchdev
hỗ trợ được xây dựng cho người lái xe.


Chuyển cổng
------------

Khi khởi tạo trình điều khiển switchdev, trình điều khiển sẽ phân bổ và đăng ký một
struct net_device (sử dụng register_netdev()) cho mỗi switch vật lý được liệt kê
cổng, được gọi là cổng netdev.  Một cổng netdev là đại diện phần mềm của
cổng vật lý và cung cấp một đường dẫn để điều khiển lưu lượng đến/từ cổng
bộ điều khiển (kernel) và mạng, cũng như một điểm neo cho các kết nối cao hơn
các cấu trúc cấp độ như cầu nối, liên kết, Vlan, đường hầm và bộ định tuyến L3.  sử dụng
các công cụ netdev tiêu chuẩn (iproute2, ethtool, v.v.), cổng netdev cũng có thể
cung cấp cho người dùng quyền truy cập vào các thuộc tính vật lý của cổng chuyển mạch như
dưới dạng trạng thái liên kết PHY và thống kê I/O.

(hiện tại) không có đối tượng kernel cấp cao hơn cho switch ngoài
cổng netdev.  Tất cả các hoạt động của trình điều khiển switchdev đều là các hoạt động của netdev hoặc các hoạt động của switchdev.

Cổng quản lý switch nằm ngoài phạm vi của mô hình trình điều khiển switchdev.
Thông thường, cổng quản lý không tham gia vào mặt phẳng dữ liệu được giảm tải và
được tải bằng một trình điều khiển khác, chẳng hạn như trình điều khiển NIC, trên cổng quản lý
thiết bị.

Chuyển đổi ID
^^^^^^^^^

Trình điều khiển switchdev phải triển khai thao tác net_device
ndo_get_port_parent_id cho mỗi cổng netdev, trả về cùng một ID vật lý cho
mỗi cổng của switch. ID phải là duy nhất giữa các switch trên cùng một thiết bị
hệ thống. ID không cần phải là duy nhất giữa các thiết bị chuyển mạch trên các thiết bị khác nhau
hệ thống.

ID switch được sử dụng để định vị các cổng trên switch và để biết liệu nó có được tổng hợp hay không.
các cổng thuộc cùng một switch.

Đặt tên cổng Netdev
^^^^^^^^^^^^^^^^^^

Nên sử dụng quy tắc Udev để đặt tên cổng netdev, sử dụng một số thuộc tính duy nhất
của cổng làm khóa, ví dụ: địa chỉ cổng MAC hoặc tên cổng PHYS.
Việc mã hóa cứng các tên netdev hạt nhân trong trình điều khiển không được khuyến khích; hãy để
kernel chọn tên netdev mặc định và để udev đặt tên cuối cùng dựa trên
thuộc tính cổng.

Đặc biệt sử dụng tên cổng PHYS (ndo_get_phys_port_name) cho khóa
hữu ích cho các cổng được đặt tên động trong đó thiết bị đặt tên cho các cổng của nó dựa trên
cấu hình bên ngoài.  Ví dụ: nếu cổng 40G vật lý được phân chia hợp lý
thành 4 cổng 10G, tạo ra 4 cổng netdev, thiết bị có thể cung cấp một cổng duy nhất
tên cho mỗi cổng sử dụng tên cổng PHYS.  Quy tắc udev sẽ là::

SUBSYSTEM=="net", ACTION=="thêm", ATTR{phys_switch_id}=="<phys_switch_id>", \
	    ATTR{phys_port_name}!="", NAME="swX$attr{phys_port_name}"

Quy ước đặt tên được đề xuất là "swXpYsZ", trong đó X là tên hoặc ID chuyển đổi, Y
là tên cổng hoặc ID và Z là tên hoặc ID cổng phụ.  Ví dụ: sw1p1s0
sẽ là cổng phụ 0 trên cổng 1 trên switch 1.

Tính năng cổng
^^^^^^^^^^^^^

dev->netns_immutable

Nếu trình điều khiển switchdev (và thiết bị) chỉ hỗ trợ giảm tải mặc định
không gian tên mạng (netns), trình điều khiển nên đặt cờ riêng này để ngăn chặn
cổng netdev khỏi bị chuyển ra khỏi mạng mặc định.  Nhận thức về mạng
trình điều khiển/thiết bị sẽ không đặt cờ này và chịu trách nhiệm phân vùng
phần cứng để bảo quản lưới ngăn chặn.  Điều này có nghĩa là phần cứng không thể chuyển tiếp
lưu lượng truy cập từ một cổng trong một không gian tên này đến một cổng khác trong không gian tên khác.

Cấu trúc liên kết cổng
^^^^^^^^^^^^^

Các netdev cổng đại diện cho các cổng chuyển đổi vật lý có thể được tổ chức thành
cấu trúc chuyển mạch cấp cao hơn.  Cấu trúc mặc định là độc lập
cổng bộ định tuyến, được sử dụng để giảm tải chuyển tiếp L3.  Hai hoặc nhiều cổng có thể được liên kết
cùng nhau để tạo thành một LAG.  Hai hoặc nhiều cổng (hoặc LAG) có thể được bắc cầu thành cầu nối
Mạng L2.  Vlan có thể được áp dụng cho các mạng L2 chia nhỏ.  L2-trên-L3
đường hầm có thể được xây dựng trên các cảng.  Các cấu trúc này được xây dựng bằng Linux tiêu chuẩn
các công cụ như trình điều khiển cầu nối, trình điều khiển nhóm/liên kết và các trình điều khiển dựa trên liên kết mạng
các công cụ như iproute2.

Trình điều khiển switchdev có thể biết vị trí của một cổng cụ thể trong cấu trúc liên kết bằng cách
giám sát thông báo NETDEV_CHANGEUPPER.  Ví dụ: một cổng được chuyển vào một
trái phiếu sẽ thấy sự thay đổi chủ trên của nó.  Nếu trái phiếu đó được chuyển thành một cây cầu,
chủ trên của trái phiếu sẽ thay đổi.  Và vân vân.  Người lái xe sẽ theo dõi như vậy
chuyển động để biết vị trí của một cổng trong cấu trúc liên kết tổng thể bằng cách
đăng ký sự kiện netdevice và hành động trên NETDEV_CHANGEUPPER.

Giảm tải chuyển tiếp L2
---------------------

Ý tưởng là giảm tải đường dẫn chuyển tiếp (chuyển đổi) dữ liệu L2 khỏi kernel
tới thiết bị switchdev bằng cách phản ánh các mục nhập FDB của cầu nối xuống thiết bị.  Một
Mục nhập FDB là đích chuyển tiếp bộ dữ liệu {port, MAC, VLAN}.

Để giảm tải cầu nối L2, trình điều khiển/thiết bị switchdev phải hỗ trợ:

- Các mục FDB tĩnh được cài đặt trên cổng cầu
	- Thông báo về src mac/vlans đã học/quên từ thiết bị
	- Trạng thái STP thay đổi trên cổng
	- VLAN làm ngập các gói multicast/broadcast và gói unicast không xác định

Mục nhập FDB tĩnh
^^^^^^^^^^^^^^^^^^

Trình điều khiển triển khai ZZ0000ZZ, ZZ0001ZZ và
Các hoạt động ZZ0002ZZ có thể hỗ trợ lệnh bên dưới, bổ sung thêm một
cầu tĩnh FDB mục nhập::

cầu fdb thêm dev DEV ADDRESS [vlan VID] [tự] tĩnh

(từ khóa "tĩnh" là không bắt buộc: nếu không được chỉ định, mục nhập mặc định là
là "cục bộ", có nghĩa là nó không nên được chuyển tiếp)

Từ khóa "self" (tùy chọn vì nó ẩn) có vai trò
hướng dẫn kernel thực hiện thao tác thông qua ZZ0000ZZ
triển khai chính thiết bị ZZ0001ZZ. Nếu ZZ0002ZZ là cổng cầu, thì đây
sẽ bỏ qua cầu nối và do đó khiến cơ sở dữ liệu phần mềm không đồng bộ
với phần cứng.

Để tránh điều này, từ khóa "chính" có thể được sử dụng ::

bridge fdb thêm dev DEV ADDRESS [vlan VID] master static

Lệnh trên hướng dẫn kernel tìm kiếm giao diện chính của
ZZ0000ZZ và thực hiện thao tác thông qua phương pháp ZZ0001ZZ đó.
Lần này, cây cầu tạo ra thông báo ZZ0002ZZ
mà trình điều khiển cổng có thể xử lý và sử dụng nó để lập trình bảng phần cứng của nó. Cái này
Nhân tiện, cơ sở dữ liệu phần mềm và phần cứng đều sẽ chứa FDB tĩnh này
nhập cảnh.

Lưu ý: đối với các trình điều khiển switchdev mới giảm tải cầu Linux, hãy triển khai
Phương pháp bỏ cầu ZZ0000ZZ và ZZ0001ZZ mạnh mẽ
không được khuyến khích: tất cả các mục FDB tĩnh phải được thêm vào cổng cầu nối bằng cách sử dụng
cờ "chính chủ". ZZ0002ZZ là một ngoại lệ và có thể được triển khai để
trực quan hóa các bảng phần cứng, nếu thiết bị không bị gián đoạn
thông báo cho hệ điều hành của động FDB mới học/đã quên
địa chỉ. Trong trường hợp đó, phần cứng FDB có thể có các mục mà
phần mềm FDB thì không, và việc triển khai ZZ0003ZZ là cách duy nhất để xem
họ.

Lưu ý: theo mặc định, cầu nối không lọc trên VLAN và chỉ có cầu nối không được gắn thẻ
giao thông.  Để bật hỗ trợ VLAN, hãy bật tính năng lọc VLAN::

echo 1 >/sys/class/net/<bridge>/bridge/vlan_filtering

Thông báo về nguồn đã học/quên MAC/VLAN
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Thiết bị chuyển mạch sẽ tìm hiểu/quên địa chỉ MAC nguồn/VLAN trên các gói đi vào
và thông báo cho trình điều khiển chuyển đổi của bộ dữ liệu mac/vlan/port.  Trình điều khiển chuyển đổi,
lần lượt sẽ thông báo cho trình điều khiển cầu nối bằng lệnh gọi trình thông báo switchdev ::

err = call_switchdev_notifiers(val, dev, info, extack);

Trong đó giá trị là SWITCHDEV_FDB_ADD khi học và SWITCHDEV_FDB_DEL khi
quên và thông tin trỏ đến cấu trúc switchdev_notifier_fdb_info.  Bật
SWITCHDEV_FDB_ADD, trình điều khiển cầu nối sẽ cài đặt mục FDB vào
FDB của cầu và đánh dấu mục nhập là NTF_EXT_LEARNED.  Cầu iproute2
lệnh sẽ gắn nhãn các mục này là "giảm tải"::

$ cầu fdb
	52:54:00:12:35:01 dev sw1p1 master br0 vĩnh viễn
	00:02:00:00:02:00 dev sw1p1 master br0 giảm tải
	00:02:00:00:02:00 dev sw1p1 tự
	52:54:00:12:35:02 dev sw1p2 master br0 vĩnh viễn
	00:02:00:00:03:00 dev sw1p2 master br0 giảm tải
	00:02:00:00:03:00 dev sw1p2 tự
	33:33:00:00:00:01 dev eth0 tự vĩnh viễn
	01:00:5e:00:00:01 dev eth0 tự vĩnh viễn
	33:33:ff:00:00:00 dev eth0 tự vĩnh viễn
	01:80:c2:00:00:0e dev eth0 tự vĩnh viễn
	33:33:00:00:00:01 dev br0 tự vĩnh viễn
	01:00:5e:00:00:01 dev br0 tự vĩnh viễn
	33:33:ff:12:35:01 dev br0 tự vĩnh viễn

Việc học trên cổng phải bị vô hiệu hóa trên bridge bằng lệnh bridge ::

cầu nối bộ dev DEV học tập

Học trên cổng thiết bị phải được bật, cũng như learning_sync::

bridge link set dev DEV tự học
	cầu nối thiết lập dev DEV learning_sync trên chính nó

Thuộc tính Learning_sync cho phép đồng bộ hóa mục FDB đã học/đã quên với
FDB của cây cầu.  Có thể, nhưng không phải là tối ưu, để cho phép học tập trên
cổng thiết bị và trên cổng cầu nối, đồng thời tắt learning_sync.

Để hỗ trợ việc học, trình điều khiển triển khai switchdev op
switchdev_port_attr_set cho SWITCHDEV_ATTR_PORT_ID_{PRE}_BRIDGE_FLAGS.

FDB Lão hóa
^^^^^^^^^^

Cây cầu sẽ bỏ qua các mục FDB cũ được đánh dấu bằng NTF_EXT_LEARNED và nó
trách nhiệm của trình điều khiển/thiết bị cổng trong việc loại bỏ các mục nhập này.  Nếu
thiết bị cổng hỗ trợ quá trình lão hóa, khi mục FDB hết hạn, nó sẽ thông báo cho
trình điều khiển sẽ thông báo cho cây cầu bằng SWITCHDEV_FDB_DEL.  Nếu
thiết bị không hỗ trợ lão hóa, trình điều khiển có thể mô phỏng lão hóa bằng cách sử dụng
hẹn giờ thu gom rác để theo dõi các mục FDB.  Các mục hết hạn sẽ được
được thông báo tới bridge bằng SWITCHDEV_FDB_DEL.  Xem trình điều khiển rocker cho
ví dụ về trình điều khiển chạy bộ đếm thời gian lão hóa.

Để giữ cho mục nhập NTF_EXT_LEARNED "sống", trình điều khiển nên làm mới FDB
nhập bằng cách gọi call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  các
thông báo sẽ đặt lại thời gian được sử dụng lần cuối của mục nhập FDB về thời điểm hiện tại.  Người lái xe
nên giới hạn mức xếp hạng các thông báo làm mới, chẳng hạn như không quá một lần một
thứ hai.  (Hiển thị thời gian sử dụng lần cuối bằng tùy chọn bridge -s fdb).

Thay đổi trạng thái STP trên cổng
^^^^^^^^^^^^^^^^^^^^^^^^

Trong nội bộ hoặc với việc triển khai giao thức STP của bên thứ ba (ví dụ: mstpd),
trình điều khiển cầu duy trì trạng thái STP cho các cổng và sẽ thông báo cho switch
trình điều khiển thay đổi trạng thái STP trên một cổng bằng cách sử dụng switchdev op
switchdev_attr_port_set cho SWITCHDEV_ATTR_PORT_ID_STP_UPDATE.

Trạng thái là một trong BR_STATE_*.  Trình điều khiển chuyển đổi có thể sử dụng các cập nhật trạng thái STP để
cập nhật danh sách bộ lọc gói đầu vào cho cổng.  Ví dụ: nếu cổng là
DISABLED, không có gói nào được chuyển qua, nhưng nếu cổng chuyển sang BLOCKED thì STP BPDU
và các gói multicast liên kết cục bộ IEEE 01:80:c2:xx:xx:xx khác có thể vượt qua.

Lưu ý rằng các BDPU STP không được gắn thẻ và trạng thái STP áp dụng cho tất cả các Vlan trên cổng
vì vậy các bộ lọc gói phải được áp dụng nhất quán trên các gói không được gắn thẻ và được gắn thẻ
VLAN trên cổng.

Làm ngập miền L2
^^^^^^^^^^^^^^^^^^

Đối với miền L2 VLAN nhất định, thiết bị chuyển mạch sẽ phát đa hướng/phát sóng
và các gói unicast không xác định tới tất cả các cổng trong miền, nếu được cổng cho phép
trạng thái STP hiện tại.  Trình điều khiển chuyển mạch, biết cổng nào nằm trong cổng nào
vlan L2, có thể lập trình cho thiết bị switch chống ngập.  Gói tin có thể
được gửi đến cổng netdev để trình điều khiển cầu xử lý.  các
bridge không nên tải lại gói tin đến cùng cổng mà thiết bị bị ngập,
nếu không sẽ có các gói trùng lặp trên dây.

Để tránh các gói trùng lặp, trình điều khiển chuyển mạch nên đánh dấu một gói là đã có
được chuyển tiếp bằng cách thiết lập bit skb->offload_fwd_mark. Người lái cầu sẽ đánh dấu
skb sử dụng dấu của cổng cầu vào và ngăn nó được chuyển tiếp
qua bất kỳ cổng cầu nào có cùng dấu hiệu.

Có thể thiết bị chuyển mạch không xử lý được tình trạng ngập nước và đẩy
gửi gói tin tới trình điều khiển cầu để chống ngập.  Điều này không lý tưởng vì số
quy mô cổng trong miền L2 vì thiết bị hoạt động hiệu quả hơn nhiều
làm ngập gói phần mềm đó.

Nếu được thiết bị hỗ trợ, việc kiểm soát lũ có thể được giảm tải cho thiết bị, ngăn chặn
một số nhà phát triển mạng nhất định khỏi làm ngập lưu lượng truy cập unicast mà không có mục nhập FDB.

IGMP Rình mò
^^^^^^^^^^^^^

Để hỗ trợ việc rình mò IGMP, các nhà phát triển cổng nên bẫy vào cầu
điều khiển tất cả IGMP tham gia và để lại tin nhắn.
Mô-đun multicast cầu sẽ thông báo cho các netdev cổng trên mỗi nhóm multicast
đã thay đổi dù nó được cấu hình tĩnh hay tham gia/rời động động.
Việc triển khai phần cứng phải chuyển tiếp tất cả các multicast đã đăng ký
nhóm lưu lượng truy cập chỉ vào các cổng được cấu hình.

Giảm tải định tuyến L3
------------------

Định tuyến L3 giảm tải yêu cầu thiết bị phải được lập trình với các mục FIB từ
kernel, với thiết bị thực hiện tra cứu và chuyển tiếp FIB.  thiết bị
thực hiện khớp tiền tố dài nhất (LPM) trên các mục nhập FIB khớp với tiền tố tuyến đường và
chuyển tiếp gói đến các cổng đi ra tiếp theo của mục nhập FIB phù hợp.

Để lập trình thiết bị, trình điều khiển phải đăng ký trình xử lý thông báo FIB
sử dụng register_fib_notifier. Các sự kiện sau đây có sẵn:

============================================================================
FIB_EVENT_ENTRY_ADD được sử dụng để thêm mục FIB mới vào thiết bị,
		     hoặc sửa đổi một mục hiện có trên thiết bị.
FIB_EVENT_ENTRY_DEL được sử dụng để xóa mục nhập FIB
FIB_EVENT_RULE_ADD,
FIB_EVENT_RULE_DEL được sử dụng để truyền bá các thay đổi quy tắc FIB
============================================================================

Sự kiện FIB_EVENT_ENTRY_ADD và FIB_EVENT_ENTRY_DEL vượt qua::

cấu trúc fib_entry_notifier_info {
		thông tin struct fib_notifier_info; /* phải là đầu tiên */
		u32 dst;
		int dst_len;
		struct fib_info *fi;
		u8 tos;
		loại u8;
		u32 tb_id;
		u32 nlfag;
	};

để thêm/sửa đổi/xóa tiền tố IPv4 dst/dest_len trên bảng tb_id.  ZZ0000ZZ
cấu trúc chứa thông tin chi tiết về tuyến đường và các chặng tiếp theo của tuyến đường.  ZZ0001ZZ là một
của các netdev cổng được đề cập trong danh sách chặng tiếp theo của tuyến.

Các tuyến được giảm tải cho thiết bị được gắn nhãn "giảm tải" trong tuyến ip
niêm yết::

$ ip hiển thị lộ trình
	mặc định qua 192.168.0.2 dev eth0
	11.0.0.0/30 dev sw1p1 liên kết phạm vi hạt nhân nguyên mẫu src 11.0.0.2 giảm tải
	11.0.0.4/30 qua 11.0.0.1 dev sw1p1 proto zebra số liệu giảm tải 20
	11.0.0.8/30 dev sw1p2 liên kết phạm vi hạt nhân nguyên mẫu src 11.0.0.10 giảm tải
	Giảm tải 11.0.0.12/30 qua 11.0.0.9 dev sw1p2 proto zebra số liệu 20
	Giảm tải 12.0.0.2 proto zebra số liệu 30
		nexthop qua 11.0.0.1 dev sw1p1 trọng lượng 1
		nexthop qua 11.0.0.9 dev sw1p2 trọng lượng 1
	Giảm tải 12.0.0.3 qua 11.0.0.1 dev sw1p1 proto zebra số liệu 20
	Giảm tải 12.0.0.4 qua 11.0.0.9 dev sw1p2 proto zebra số liệu 20
	192.168.0.0/24 dev eth0 liên kết phạm vi hạt nhân proto src 192.168.0.15

Cờ "giảm tải" được đặt trong trường hợp có ít nhất một thiết bị giảm tải mục FIB.

XXX: thêm/mod/del IPv6 FIB API

Độ phân giải Nexthop
^^^^^^^^^^^^^^^^^^

Danh sách nexthop của mục FIB chứa bộ nexthop (gateway, dev), nhưng đối với
thiết bị chuyển mạch để chuyển tiếp gói với địa chỉ dst mac chính xác,
cổng nexthop phải được phân giải tới địa chỉ mac của hàng xóm.  hàng xóm mac
việc khám phá địa chỉ được thực hiện thông qua quy trình ARP (hoặc ND) và có sẵn thông qua
bảng hàng xóm arp_tbl.  Để giải quyết các tuyến đường cổng nexthop, trình điều khiển
sẽ kích hoạt quá trình phân giải hàng xóm của kernel.  Xem rocker
rocker_port_ipv4_resolve() của trình điều khiển làm ví dụ.

Trình điều khiển có thể theo dõi các bản cập nhật cho arp_tbl bằng trình thông báo netevent
NETEVENT_NEIGH_UPDATE.  Thiết bị có thể được lập trình với các bước tiếp theo đã được giải quyết
cho các tuyến đường dưới dạng cập nhật arp_tbl.  Trình điều khiển thực hiện ndo_neigh_destroy
để biết khi nào các mục hàng xóm arp_tbl bị xóa khỏi cổng.

Hành vi mong đợi của trình điều khiển thiết bị
-------------------------------

Dưới đây là tập hợp các hành vi được xác định mà các thiết bị mạng hỗ trợ switchdev phải
tuân thủ.

Trạng thái không có cấu hình
^^^^^^^^^^^^^^^^^^^^^^^^

Khi trình điều khiển xuất hiện, các thiết bị mạng phải hoạt động đầy đủ và
trình điều khiển sao lưu phải cấu hình thiết bị mạng sao cho có thể
gửi và nhận lưu lượng truy cập đến thiết bị mạng này và nó được phân tách hợp lý
từ các thiết bị/cổng mạng khác (ví dụ: như thường lệ với bộ chuyển mạch ASIC). Làm thế nào
điều này đạt được phụ thuộc rất nhiều vào phần cứng, nhưng một giải pháp đơn giản có thể là
sử dụng mã định danh VLAN trên mỗi cổng trừ khi có sẵn cơ chế tốt hơn
(ví dụ: siêu dữ liệu độc quyền cho từng cổng mạng).

Thiết bị mạng phải có khả năng chạy ngăn xếp giao thức IP đầy đủ
bao gồm multicast, DHCP, IPv4/6, v.v. Nếu cần, cần lập trình
bộ lọc thích hợp cho VLAN, multicast, unicast, v.v. Thiết bị cơ bản
trình điều khiển phải được cấu hình một cách hiệu quả theo cách tương tự như những gì nó sẽ làm
khi tính năng rình mò IGMP được bật cho phát đa hướng IP qua mạng switchdev này
các thiết bị và multicast không được yêu cầu phải được lọc càng sớm càng tốt trong
phần cứng.

Khi định cấu hình Vlan trên thiết bị mạng, tất cả các Vlan phải hoạt động,
bất kể trạng thái của các thiết bị mạng khác (ví dụ: các cổng khác là một phần
của cây cầu nhận biết VLAN đang thực hiện kiểm tra VID xâm nhập). Xem bên dưới để biết chi tiết.

Nếu thiết bị thực hiện, ví dụ: lọc VLAN, đặt giao diện vào
chế độ lăng nhăng sẽ cho phép nhận tất cả các thẻ VLAN (bao gồm cả các thẻ
không có trong (các) bộ lọc).

Cổng chuyển mạch cầu nối
^^^^^^^^^^^^^^^^^^^^

Khi một thiết bị mạng hỗ trợ switchdev được thêm làm thành viên cầu nối, nó sẽ
không làm gián đoạn bất kỳ chức năng nào của các thiết bị mạng không có cầu nối và chúng
sẽ tiếp tục hoạt động như các thiết bị mạng bình thường. Tùy theo cầu
các nút cấu hình bên dưới, hoạt động dự kiến sẽ được ghi lại.

Lọc cầu VLAN
^^^^^^^^^^^^^^^^^^^^^

Cầu Linux cho phép cấu hình chế độ lọc VLAN (tĩnh,
tại thời điểm tạo thiết bị và linh hoạt trong thời gian chạy) phải
được quan sát bởi thiết bị/phần cứng mạng switchdev cơ bản:

- với tính năng lọc VLAN bị tắt: cầu nối hoàn toàn không được biết đến và VLAN
  đường dẫn dữ liệu sẽ xử lý tất cả các khung Ethernet như thể chúng không được gắn thẻ VLAN.
  Cơ sở dữ liệu bridge VLAN vẫn có thể được sửa đổi, nhưng việc sửa đổi sẽ
  không có tác dụng khi tính năng lọc VLAN bị tắt. Khung xâm nhập
  thiết bị có VID không được lập trình vào bảng VLAN của bridge/switch
  phải được chuyển tiếp và có thể được xử lý bằng thiết bị VLAN (xem bên dưới).

- với tính năng lọc VLAN được bật: cầu nối nhận biết VLAN và đang xâm nhập khung
  thiết bị có VID không được lập trình vào VLAN của cầu nối/công tắc
  bảng phải được loại bỏ (kiểm tra VID nghiêm ngặt).

Khi có thiết bị VLAN (ví dụ: sw0p1.100) được định cấu hình trên switchdev
thiết bị mạng là thành viên cổng cầu nối, hoạt động của phần mềm
ngăn xếp mạng phải được bảo tồn hoặc cấu hình phải bị từ chối nếu điều đó
là không thể.

- khi tắt bộ lọc VLAN, cầu sẽ xử lý tất cả lưu lượng truy cập vào
  cho cổng, ngoại trừ lưu lượng được gắn thẻ ID VLAN dành cho cổng
  VLAN phía trên. Giao diện phía trên VLAN (sử dụng thẻ VLAN) thậm chí có thể
  được thêm vào cầu nối thứ hai, bao gồm các cổng chuyển mạch hoặc phần mềm khác
  giao diện. Một số phương pháp đảm bảo miền chuyển tiếp cho lưu lượng
  thuộc các giao diện phía trên của VLAN được quản lý đúng cách:

* Nếu các đích chuyển tiếp có thể được quản lý trên mỗi VLAN, thì phần cứng có thể
      được định cấu hình để ánh xạ tất cả lưu lượng truy cập, ngoại trừ các gói được gắn thẻ VID
      thuộc về giao diện trên VLAN, thuộc về VID bên trong tương ứng với
      các gói không được đánh dấu. VID nội bộ này mở rộng tất cả các cổng của VLAN-không biết
      cầu. VID tương ứng với giao diện phía trên VLAN trải rộng trên
      cổng vật lý của giao diện VLAN đó, cũng như các cổng khác
      có thể được bắc cầu với nó.
    * Coi các cổng cầu có giao diện phía trên VLAN là độc lập và để
      việc chuyển tiếp được xử lý trong đường dẫn dữ liệu phần mềm.

- khi bật tính năng lọc VLAN, các thiết bị VLAN này có thể được tạo miễn là
  cây cầu hiện không có mục VLAN có cùng VID trên bất kỳ
  cảng cầu. Các thiết bị VLAN này không thể bị bắt làm nô lệ trong cầu nối vì chúng
  chức năng/trường hợp sử dụng trùng lặp với quá trình xử lý đường dẫn dữ liệu VLAN của cầu nối.

Các cổng mạng không có cầu nối của cùng một loại switch không được bị xáo trộn trong bất kỳ trường hợp nào.
bằng cách bật tính năng lọc VLAN trên (các) thiết bị cầu nối. Nếu VLAN
cài đặt lọc mang tính chung cho toàn bộ chip, sau đó là các cổng độc lập
sẽ cho biết ngăn xếp mạng rằng cần phải lọc VLAN bằng cách cài đặt
'rx-vlan-filter: on [đã sửa]' trong các tính năng của ethtool.

Bởi vì tính năng lọc VLAN có thể được bật/tắt trong thời gian chạy, trình điều khiển switchdev
phải có khả năng cấu hình lại phần cứng cơ bản một cách nhanh chóng để tôn trọng
chuyển đổi tùy chọn đó và hành xử phù hợp. Nếu điều đó là không thể thì
Trình điều khiển switchdev cũng có thể từ chối hỗ trợ chuyển đổi động của VLAN
núm lọc trong thời gian chạy và yêu cầu phá hủy (các) thiết bị cầu nối và
tạo (các) thiết bị cầu nối mới với giá trị lọc VLAN khác với
đảm bảo nhận thức về VLAN được đẩy xuống phần cứng.

Ngay cả khi tính năng lọc VLAN trong cầu nối bị tắt, công tắc bên dưới
phần cứng và trình điều khiển vẫn có thể tự cấu hình ở chế độ nhận biết VLAN được cung cấp
rằng hành vi được mô tả ở trên được quan sát.

Giao thức VLAN của bridge đóng vai trò quyết định liệu một gói có được
được coi là được gắn thẻ hay không: cầu sử dụng giao thức 802.1ad phải xử lý cả hai
Các gói không được gắn thẻ VLAN, cũng như các gói được gắn thẻ với tiêu đề 802.1Q, như
không được gắn thẻ.

Các gói được gắn thẻ 802.1p (VID 0) phải được thiết bị xử lý theo cách tương tự
dưới dạng các gói không được gắn thẻ, vì thiết bị cầu nối không cho phép thao tác
VID 0 trong cơ sở dữ liệu của nó.

Khi cầu nối đã bật tính năng lọc VLAN và PVID không được định cấu hình trên
cổng vào, các gói không được gắn thẻ và được gắn thẻ 802.1p phải bị loại bỏ. Khi cây cầu
đã bật tính năng lọc VLAN và PVID tồn tại trên cổng vào, không được gắn thẻ và
Các gói được gắn thẻ ưu tiên phải được chấp nhận và chuyển tiếp theo
thành viên cổng của cầu của PVID VLAN. Khi cầu có bộ lọc VLAN
bị vô hiệu hóa, sự hiện diện/thiếu PVID sẽ không ảnh hưởng đến gói
quyết định chuyển tiếp.

Cầu IGMP rình mò
^^^^^^^^^^^^^^^^^^^^

Cầu Linux cho phép cấu hình IGMP snooping (tĩnh, tại
thời gian tạo giao diện hoặc động trong thời gian chạy) phải được tuân thủ
bởi thiết bị/phần cứng mạng switchdev cơ bản theo cách sau:

- khi tính năng rình mò IGMP bị tắt, lưu lượng phát đa hướng phải tràn tới tất cả
  các cổng trong cùng một bridge có mcast_flood=true. CPU/quản lý
  lý tưởng nhất là cổng không bị ngập (trừ khi giao diện xâm nhập có
  IFF_ALLMULTI hoặc IFF_PROMISC) và tiếp tục tìm hiểu lưu lượng multicast thông qua
  các thông báo ngăn xếp mạng. Nếu phần cứng không có khả năng làm điều đó
  thì cổng quản lý/CPU cũng phải bị ngập và lọc đa hướng
  xảy ra trong phần mềm.

- khi bật tính năng rình mò IGMP, lưu lượng phát đa hướng phải chảy có chọn lọc
  tới các cổng mạng thích hợp (bao gồm CPU/cổng quản lý). Lũ lụt
  multicast không xác định chỉ được hướng tới các cổng được kết nối với multicast
  bộ định tuyến (thiết bị cục bộ cũng có thể hoạt động như một bộ định tuyến phát đa hướng).

Bộ chuyển mạch phải tuân theo RFC 4541 và làm tràn lưu lượng phát đa hướng tương ứng
vì đó là những gì việc triển khai cầu nối Linux thực hiện.

Vì tính năng theo dõi IGMP có thể được bật/tắt trong thời gian chạy, nên trình điều khiển switchdev
phải có khả năng cấu hình lại phần cứng cơ bản một cách nhanh chóng để tôn trọng
chuyển đổi tùy chọn đó và hành xử phù hợp.

Trình điều khiển switchdev cũng có thể từ chối hỗ trợ chuyển đổi động của chế độ phát đa hướng
núm điều chỉnh trong thời gian chạy và yêu cầu phá hủy (các) thiết bị cầu nối
và tạo ra (các) thiết bị cầu nối mới với cơ chế theo dõi phát đa hướng khác
giá trị.