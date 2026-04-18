.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/dsa/configuration.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Cấu hình chuyển đổi DSA từ không gian người dùng
================================================

Cấu hình switch DSA không được tích hợp vào không gian người dùng chính
bộ cấu hình mạng bây giờ và phải được thực hiện thủ công.

.. _dsa-config-showcases:

Trình diễn cấu hình
-----------------------

Để định cấu hình bộ chuyển đổi DSA, một số lệnh cần được thực thi. Trong này
tài liệu hướng dẫn một số tình huống cấu hình phổ biến được xử lý dưới dạng giới thiệu:

ZZ0000ZZ
  Mỗi cổng chuyển mạch hoạt động như một cổng Ethernet có thể cấu hình khác nhau

ZZ0000ZZ
  Mỗi cổng chuyển mạch là một phần của một cầu Ethernet có thể cấu hình

ZZ0000ZZ
  Mỗi cổng chuyển đổi ngoại trừ một cổng ngược dòng là một phần của cấu hình
  Cầu Ethernet.
  Cổng ngược dòng hoạt động như cổng Ethernet có thể cấu hình khác.

Tất cả các cấu hình được thực hiện bằng các công cụ từ iproute2, có sẵn
tại ZZ0000ZZ

Thông qua DSA, mọi cổng của bộ chuyển mạch đều được xử lý giống như Ethernet linux thông thường
giao diện. Cổng CPU là cổng chuyển mạch được kết nối với chip Ethernet MAC.
Giao diện Ethernet linux tương ứng được gọi là giao diện ống dẫn.
Tất cả các giao diện linux tương ứng khác được gọi là giao diện người dùng.

Các giao diện người dùng phụ thuộc vào giao diện ống dẫn được thiết lập để phù hợp với chúng
để gửi hoặc nhận lưu lượng. Trước kernel v5.12, trạng thái của ống dẫn
giao diện phải được quản lý rõ ràng bởi người dùng. Bắt đầu với kernel v5.12,
hành vi như sau:

- khi giao diện người dùng DSA được hiển thị, giao diện ống dẫn sẽ
  tự động đưa lên.
- khi giao diện ống dẫn được hạ xuống, tất cả giao diện người dùng DSA đều được
  tự động hạ xuống.

Trong tài liệu này, các giao diện Ethernet sau được sử dụng:

ZZ0000ZZ
  giao diện ống dẫn

ZZ0000ZZ
  giao diện ống dẫn khác

ZZ0000ZZ
  giao diện người dùng

ZZ0000ZZ
  giao diện người dùng khác

ZZ0000ZZ
  giao diện người dùng thứ ba

ZZ0000ZZ
  Giao diện người dùng dành riêng cho lưu lượng truy cập ngược dòng

Các giao diện Ethernet khác có thể được cấu hình tương tự.
Các IP và mạng được cấu hình là:

ZZ0000ZZ
  * lan1: 192.0.2.1/30 (192.0.2.0 - 192.0.2.3)
  * lan2: 192.0.2.5/30 (192.0.2.4 - 192.0.2.7)
  * lan3: 192.0.2.9/30 (192.0.2.8 - 192.0.2.11)

ZZ0000ZZ
  *br0: 192.0.2.129/25 (192.0.2.128 - 192.0.2.255)

ZZ0000ZZ
  *br0: 192.0.2.129/25 (192.0.2.128 - 192.0.2.255)
  * mạng: 192.0.2.1/30 (192.0.2.0 - 192.0.2.3)

.. _dsa-tagged-configuration:

Cấu hình có hỗ trợ gắn thẻ
----------------------------------

Cấu hình dựa trên gắn thẻ được mong muốn và hỗ trợ bởi phần lớn
Công tắc DSA. Các thiết bị chuyển mạch này có khả năng gắn thẻ lưu lượng truy cập đến và đi
mà không sử dụng cấu hình dựa trên VLAN.

ZZ0000ZZ
  .. code-block:: sh

    # configure each interface
    ip addr add 192.0.2.1/30 dev lan1
    ip addr add 192.0.2.5/30 dev lan2
    ip addr add 192.0.2.9/30 dev lan3

    # For kernels earlier than v5.12, the conduit interface needs to be
    # brought up manually before the user ports.
    ip link set eth0 up

    # bring up the user interfaces
    ip link set lan1 up
    ip link set lan2 up
    ip link set lan3 up

ZZ0000ZZ
  .. code-block:: sh

    # For kernels earlier than v5.12, the conduit interface needs to be
    # brought up manually before the user ports.
    ip link set eth0 up

    # bring up the user interfaces
    ip link set lan1 up
    ip link set lan2 up
    ip link set lan3 up

    # create bridge
    ip link add name br0 type bridge

    # add ports to bridge
    ip link set dev lan1 master br0
    ip link set dev lan2 master br0
    ip link set dev lan3 master br0

    # configure the bridge
    ip addr add 192.0.2.129/25 dev br0

    # bring up the bridge
    ip link set dev br0 up

ZZ0000ZZ
  .. code-block:: sh

    # For kernels earlier than v5.12, the conduit interface needs to be
    # brought up manually before the user ports.
    ip link set eth0 up

    # bring up the user interfaces
    ip link set wan up
    ip link set lan1 up
    ip link set lan2 up

    # configure the upstream port
    ip addr add 192.0.2.1/30 dev wan

    # create bridge
    ip link add name br0 type bridge

    # add ports to bridge
    ip link set dev lan1 master br0
    ip link set dev lan2 master br0

    # configure the bridge
    ip addr add 192.0.2.129/25 dev br0

    # bring up the bridge
    ip link set dev br0 up

.. _dsa-vlan-configuration:

Cấu hình không hỗ trợ gắn thẻ
-------------------------------------

Một số ít thiết bị chuyển mạch không có khả năng sử dụng giao thức gắn thẻ
(DSA_TAG_PROTO_NONE). Các công tắc này có thể được cấu hình bằng VLAN
cấu hình.

ZZ0000ZZ
  Cấu hình chỉ có thể được thiết lập thông qua gắn thẻ VLAN và thiết lập cầu nối.

  .. code-block:: sh

    # tag traffic on CPU port
    ip link add link eth0 name eth0.1 type vlan id 1
    ip link add link eth0 name eth0.2 type vlan id 2
    ip link add link eth0 name eth0.3 type vlan id 3

    # For kernels earlier than v5.12, the conduit interface needs to be
    # brought up manually before the user ports.
    ip link set eth0 up
    ip link set eth0.1 up
    ip link set eth0.2 up
    ip link set eth0.3 up

    # bring up the user interfaces
    ip link set lan1 up
    ip link set lan2 up
    ip link set lan3 up

    # create bridge
    ip link add name br0 type bridge

    # activate VLAN filtering
    ip link set dev br0 type bridge vlan_filtering 1

    # add ports to bridges
    ip link set dev lan1 master br0
    ip link set dev lan2 master br0
    ip link set dev lan3 master br0

    # tag traffic on ports
    bridge vlan add dev lan1 vid 1 pvid untagged
    bridge vlan add dev lan2 vid 2 pvid untagged
    bridge vlan add dev lan3 vid 3 pvid untagged

    # configure the VLANs
    ip addr add 192.0.2.1/30 dev eth0.1
    ip addr add 192.0.2.5/30 dev eth0.2
    ip addr add 192.0.2.9/30 dev eth0.3

    # bring up the bridge devices
    ip link set br0 up


ZZ0000ZZ
  .. code-block:: sh

    # tag traffic on CPU port
    ip link add link eth0 name eth0.1 type vlan id 1

    # For kernels earlier than v5.12, the conduit interface needs to be
    # brought up manually before the user ports.
    ip link set eth0 up
    ip link set eth0.1 up

    # bring up the user interfaces
    ip link set lan1 up
    ip link set lan2 up
    ip link set lan3 up

    # create bridge
    ip link add name br0 type bridge

    # activate VLAN filtering
    ip link set dev br0 type bridge vlan_filtering 1

    # add ports to bridge
    ip link set dev lan1 master br0
    ip link set dev lan2 master br0
    ip link set dev lan3 master br0
    ip link set eth0.1 master br0

    # tag traffic on ports
    bridge vlan add dev lan1 vid 1 pvid untagged
    bridge vlan add dev lan2 vid 1 pvid untagged
    bridge vlan add dev lan3 vid 1 pvid untagged

    # configure the bridge
    ip addr add 192.0.2.129/25 dev br0

    # bring up the bridge
    ip link set dev br0 up

ZZ0000ZZ
  .. code-block:: sh

    # tag traffic on CPU port
    ip link add link eth0 name eth0.1 type vlan id 1
    ip link add link eth0 name eth0.2 type vlan id 2

    # For kernels earlier than v5.12, the conduit interface needs to be
    # brought up manually before the user ports.
    ip link set eth0 up
    ip link set eth0.1 up
    ip link set eth0.2 up

    # bring up the user interfaces
    ip link set wan up
    ip link set lan1 up
    ip link set lan2 up

    # create bridge
    ip link add name br0 type bridge

    # activate VLAN filtering
    ip link set dev br0 type bridge vlan_filtering 1

    # add ports to bridges
    ip link set dev wan master br0
    ip link set eth0.1 master br0
    ip link set dev lan1 master br0
    ip link set dev lan2 master br0

    # tag traffic on ports
    bridge vlan add dev lan1 vid 1 pvid untagged
    bridge vlan add dev lan2 vid 1 pvid untagged
    bridge vlan add dev wan vid 2 pvid untagged

    # configure the VLANs
    ip addr add 192.0.2.1/30 dev eth0.2
    ip addr add 192.0.2.129/25 dev br0

    # bring up the bridge devices
    ip link set br0 up

Quản lý cơ sở dữ liệu chuyển tiếp (FDB)
---------------------------------------

Các công tắc DSA hiện tại không có hỗ trợ phần cứng cần thiết để duy trì
phần mềm FDB của cầu đồng bộ với các bảng phần cứng nên cả hai
các bảng được quản lý riêng biệt (ZZ0000ZZ truy vấn cả hai và tùy thuộc vào
về việc cờ ZZ0001ZZ hay ZZ0002ZZ đang được sử dụng hay không, lệnh ZZ0003ZZ hoặc ZZ0004ZZ sẽ tác động lên các mục từ một hoặc cả hai bảng).

Cho đến kernel v4.14, DSA chỉ hỗ trợ quản lý không gian người dùng của bridge FDB
các mục sử dụng thao tác bắc cầu (không cập nhật phần mềm
FDB, chỉ phần cứng) sử dụng cờ ZZ0000ZZ (tùy chọn và có thể
được bỏ qua).

  .. code-block:: sh

    bridge fdb add dev swp0 00:01:02:03:04:05 self static
    # or shorthand
    bridge fdb add dev swp0 00:01:02:03:04:05 static

Do có lỗi nên việc triển khai bridge bypass FDB do DSA cung cấp đã không thực hiện được
phân biệt giữa các mục nhập ZZ0000ZZ và ZZ0001ZZ FDB (ZZ0002ZZ có nghĩa là
được chuyển tiếp, trong khi ZZ0003ZZ có nghĩa là được kết thúc cục bộ, tức là được gửi
đến cổng máy chủ). Thay vào đó, tất cả các mục FDB có cờ ZZ0004ZZ (ẩn hoặc
rõ ràng) được DSA coi là ZZ0005ZZ ngay cả khi chúng là ZZ0006ZZ.

  .. code-block:: sh

    # This command:
    bridge fdb add dev swp0 00:01:02:03:04:05 static
    # behaves the same for DSA as this command:
    bridge fdb add dev swp0 00:01:02:03:04:05 local
    # or shorthand, because the 'local' flag is implicit if 'static' is not
    # specified, it also behaves the same as:
    bridge fdb add dev swp0 00:01:02:03:04:05

Lệnh cuối cùng là một cách không chính xác để thêm mục nhập FDB của cầu nối tĩnh vào một
Công tắc DSA sử dụng các hoạt động bỏ qua cầu nối và hoạt động do nhầm lẫn. Khác
trình điều khiển sẽ coi mục nhập FDB được thêm bằng lệnh tương tự như ZZ0000ZZ và như
như vậy, sẽ không chuyển tiếp nó, trái ngược với DSA.

Giữa kernel v4.14 và v5.14, DSA đã hỗ trợ song song hai chế độ
thêm mục nhập bridge FDB vào switch: bridge bypass đã thảo luận ở trên, như
cũng như một chế độ mới sử dụng cờ ZZ0000ZZ để cài đặt các mục FDB trong
cầu phần mềm cũng vậy.

  .. code-block:: sh

    bridge fdb add dev swp0 00:01:02:03:04:05 master static

Kể từ kernel v5.14, DSA đã tích hợp mạnh mẽ hơn với bridge
phần mềm FDB và hỗ trợ triển khai cầu nối FDB (sử dụng
cờ ZZ0000ZZ) đã bị xóa. Điều này dẫn đến những thay đổi sau:

  .. code-block:: sh

    # This is the only valid way of adding an FDB entry that is supported,
    # compatible with v4.14 kernels and later:
    bridge fdb add dev swp0 00:01:02:03:04:05 master static
    # This command is no longer buggy and the entry is properly treated as
    # 'local' instead of being forwarded:
    bridge fdb add dev swp0 00:01:02:03:04:05
    # This command no longer installs a static FDB entry to hardware:
    bridge fdb add dev swp0 00:01:02:03:04:05 static

Do đó, người viết kịch bản được khuyến khích sử dụng bộ ZZ0000ZZ
cờ khi làm việc với các mục cầu FDB trên giao diện chuyển đổi DSA.

Mối quan hệ của cổng người dùng với cổng CPU
--------------------------------------------

Thông thường, các bộ chuyển mạch DSA được gắn vào máy chủ thông qua một cổng Ethernet duy nhất.
giao diện, nhưng trong trường hợp chip chuyển đổi rời rạc, thiết kế phần cứng
có thể cho phép sử dụng 2 cổng trở lên được kết nối với máy chủ để tăng
thông lượng chấm dứt.

DSA có thể sử dụng nhiều cổng CPU theo hai cách. Đầu tiên, có thể
chỉ định tĩnh lưu lượng truy cập kết thúc được liên kết với một cổng người dùng nhất định
được xử lý bởi một cổng CPU nhất định. Bằng cách này, không gian người dùng có thể thực hiện
chính sách tùy chỉnh về cân bằng tải tĩnh giữa các cổng người dùng, bằng cách trải rộng
ái lực theo các cổng CPU có sẵn.

Thứ hai, có thể thực hiện cân bằng tải giữa các cổng CPU trên mỗi cổng.
dựa trên gói, thay vì gán tĩnh các cổng người dùng cho các cổng CPU.
Điều này có thể đạt được bằng cách đặt ống dẫn DSA dưới giao diện LAG (liên kết
hoặc đội). DSA giám sát hoạt động này và tạo bản sao của phần mềm này LAG
trên các cổng CPU đối diện với các ống dẫn DSA vật lý cấu thành LAG phụ
thiết bị.

Để sử dụng nhiều cổng CPU, phần mô tả chương trình cơ sở (cây thiết bị) của
công tắc phải đánh dấu tất cả các liên kết giữa các cổng CPU và ống dẫn DSA của chúng
sử dụng tham chiếu/phandle ZZ0000ZZ. Khi khởi động, chỉ có một cổng CPU duy nhất
và ống dẫn DSA sẽ được sử dụng - cổng số đầu tiên từ phần sụn
description có thuộc tính ZZ0001ZZ. Tùy thuộc vào người dùng
cấu hình hệ thống cho công tắc để sử dụng các ống dẫn khác.

DSA sử dụng cơ chế ZZ0000ZZ (với "dsa" ZZ0001ZZ) để cho phép
thay đổi ống dẫn DSA của cổng người dùng. Liên kết mạng ZZ0002ZZ u32
Thuộc tính chứa ifindex của thiết bị ống dẫn xử lý từng người dùng
thiết bị. Ống dẫn DSA phải là ứng cử viên hợp lệ dựa trên nút phần sụn
thông tin hoặc giao diện LAG chỉ chứa các nô lệ hợp lệ
ứng viên.

Sử dụng iproute2, có thể thực hiện các thao tác sau:

  .. code-block:: sh

    # See the DSA conduit in current use
    ip -d link show dev swp0
        (...)
        dsa master eth0

    # Static CPU port distribution
    ip link set swp0 type dsa master eth1
    ip link set swp1 type dsa master eth0
    ip link set swp2 type dsa master eth1
    ip link set swp3 type dsa master eth0

    # CPU ports in LAG, using explicit assignment of the DSA conduit
    ip link add bond0 type bond mode balance-xor && ip link set bond0 up
    ip link set eth1 down && ip link set eth1 master bond0
    ip link set swp0 type dsa master bond0
    ip link set swp1 type dsa master bond0
    ip link set swp2 type dsa master bond0
    ip link set swp3 type dsa master bond0
    ip link set eth0 down && ip link set eth0 master bond0
    ip -d link show dev swp0
        (...)
        dsa master bond0

    # CPU ports in LAG, relying on implicit migration of the DSA conduit
    ip link add bond0 type bond mode balance-xor && ip link set bond0 up
    ip link set eth0 down && ip link set eth0 master bond0
    ip link set eth1 down && ip link set eth1 master bond0
    ip -d link show dev swp0
        (...)
        dsa master bond0

Lưu ý rằng trong trường hợp các cổng CPU trong LAG, việc sử dụng
Thuộc tính liên kết mạng ZZ0000ZZ không thực sự cần thiết mà đúng hơn là DSA
phản ứng với sự thay đổi thuộc tính ZZ0001ZZ của ống dẫn hiện tại của nó (ZZ0002ZZ)
và di chuyển tất cả các cổng người dùng sang phần trên mới của ZZ0003ZZ, ZZ0004ZZ. Tương tự,
khi ZZ0005ZZ bị hủy bằng ZZ0006ZZ, DSA sẽ di chuyển các cổng người dùng
đã được gán cho giao diện này cho ống dẫn DSA vật lý đầu tiên
đủ điều kiện, dựa trên mô tả chương trình cơ sở (nó hoàn nguyên về trạng thái
cấu hình khởi động).

Do đó, trong thiết lập có nhiều hơn 2 cổng CPU vật lý, có thể kết hợp
người dùng tĩnh để gán cổng CPU với LAG giữa các ống dẫn DSA. Nó không phải
có thể gán tĩnh một cổng người dùng cho ống dẫn DSA có bất kỳ cổng nào
giao diện phía trên (bao gồm các thiết bị LAG - ống dẫn phải luôn là LAG
trong trường hợp này).

Việc thay đổi trực tiếp mối quan hệ của ống dẫn DSA (và do đó là cổng CPU) của cổng người dùng là
được phép, để cho phép phân phối lại động để đáp ứng lưu lượng truy cập.

Các ống dẫn DSA vật lý được phép tham gia và rời đi bất cứ lúc nào với giao diện LAG
được sử dụng làm ống dẫn DSA; tuy nhiên, DSA sẽ từ chối giao diện LAG vì nó hợp lệ
ứng cử viên để trở thành ống dẫn DSA trừ khi nó có ít nhất một ống dẫn DSA vật lý
như một thiết bị nô lệ.