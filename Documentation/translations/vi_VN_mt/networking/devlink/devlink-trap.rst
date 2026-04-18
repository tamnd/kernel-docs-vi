.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-trap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Bẫy liên kết nhà phát triển
===========================

Lý lịch
==========

Các thiết bị có khả năng giảm tải đường dẫn dữ liệu của kernel và thực hiện các chức năng như
vì cầu nối và định tuyến cũng phải có khả năng gửi các gói cụ thể đến
kernel (tức là CPU) để xử lý.

Ví dụ: một thiết bị hoạt động như một cầu nối nhận biết multicast phải có khả năng gửi
Thành viên IGMP báo cáo cho kernel để mô-đun cầu nối xử lý.
Nếu không xử lý các gói tin như vậy, mô-đun cầu nối sẽ không bao giờ có thể đưa vào
MDB.

Một ví dụ khác, hãy xem xét một thiết bị đóng vai trò là bộ định tuyến đã nhận được địa chỉ IP
gói có TTL là 1. Khi định tuyến gói, thiết bị phải gửi nó đến
kernel để nó cũng sẽ định tuyến nó và tạo ra ICMP Đã vượt quá thời gian
datagram lỗi. Không để kernel tự định tuyến các gói như vậy, các tiện ích
chẳng hạn như ZZ0000ZZ không bao giờ có thể hoạt động được.

Khả năng cơ bản của việc gửi các gói nhất định đến kernel để xử lý
được gọi là "bẫy gói".

Tổng quan
========

Cơ chế ZZ0000ZZ cho phép các trình điều khiển thiết bị có khả năng đăng ký
hỗ trợ bẫy gói với ZZ0001ZZ và báo cáo các gói bị mắc kẹt tới
ZZ0002ZZ để phân tích thêm.

Khi nhận được các gói bị mắc kẹt, ZZ0001ZZ sẽ thực hiện việc xử lý các gói trên mỗi bẫy và
tính toán byte và có khả năng báo cáo gói tin tới không gian người dùng thông qua liên kết mạng
sự kiện cùng với tất cả siêu dữ liệu được cung cấp (ví dụ: lý do bẫy, dấu thời gian, thông tin đầu vào
cổng). Điều này đặc biệt hữu ích cho bẫy thả (xem ZZ0000ZZ)
vì nó cho phép người dùng có được khả năng hiển thị sâu hơn về các gói tin bị rơi
nếu không thì vô hình.

Sơ đồ sau đây cung cấp cái nhìn tổng quan chung về ZZ0000ZZ::

Sự kiện Netlink: Gói có siêu dữ liệu
                                                   Hoặc bản tóm tắt về những lần giảm gần đây
                                  ^
                                  |
         Không gian người dùng |
        +---------------------------------------------------+
         hạt nhân |
                                  |
                          +-------+--------+
                          ZZ0000ZZ
                          ZZ0001ZZ
                          ZZ0002ZZ
                          +-------^--------+
                                  |
                                  | Bẫy không kiểm soát
                                  |
                             +----+----+
                             Đường dẫn Rx của hạt nhân ZZ0003ZZ
                             ZZ0004ZZ (bẫy không thả)
                             ZZ0005ZZ
                             +----^----+ ^
                                  ZZ0006ZZ
                                  +----------+
                                  |
                          +-------+-------+
                          ZZ0007ZZ
                          ZZ0008ZZ
                          ZZ0009ZZ
                          +-------^-------+
         hạt nhân |
        +---------------------------------------------------+
         Phần cứng |
                                  | Gói bị mắc kẹt
                                  |
                               +--+---+
                               ZZ0010ZZ
                               ZZ0011ZZ
                               ZZ0012ZZ
                               +------+

.. _Trap-Types:

Các loại bẫy
==========

Cơ chế ZZ0000ZZ hỗ trợ các loại bẫy gói sau:

* ZZ0001ZZ: Các gói bị mắc kẹt đã bị thiết bị bên dưới loại bỏ. Gói
    chỉ được xử lý bởi ZZ0002ZZ và không được đưa vào đường dẫn Rx của kernel.
    Hành động bẫy (xem ZZ0000ZZ) có thể được thay đổi.
  * ZZ0003ZZ: Các gói bị mắc kẹt không được chuyển tiếp như dự định
    thiết bị cơ bản do một ngoại lệ (ví dụ: lỗi TTL, thiếu hàng xóm
    entry) và bị giữ lại trong mặt phẳng điều khiển để giải quyết. Các gói được
    được xử lý bởi ZZ0004ZZ và đưa vào đường dẫn Rx của kernel. Thay đổi
    hành động của những cái bẫy như vậy là không được phép, vì nó có thể dễ dàng phá vỡ sự kiểm soát
    máy bay.
  * ZZ0005ZZ: Các gói bị bẫy đã bị thiết bị giữ lại vì đây là
    các gói điều khiển cần thiết cho hoạt động chính xác của mặt phẳng điều khiển.
    Ví dụ: gói yêu cầu ARP và gói truy vấn IGMP. Các gói được đưa vào
    đường dẫn Rx của kernel, nhưng không được báo cáo cho trình giám sát thả của kernel.
    Không được phép thay đổi hoạt động của những cái bẫy như vậy vì nó có thể dễ dàng bị gãy.
    mặt phẳng điều khiển.

.. _Trap-Actions:

Hành động bẫy
============

Cơ chế ZZ0000ZZ hỗ trợ các hành động bẫy gói sau:

* ZZ0000ZZ: Bản sao duy nhất của gói được gửi đến CPU.
  * ZZ0001ZZ: Gói tin bị thiết bị bên dưới bỏ đi và không có bản sao
    được gửi đến CPU.
  * ZZ0002ZZ: Gói được chuyển tiếp bởi thiết bị cơ bản và một bản sao được
    được gửi đến CPU.

Bẫy gói chung
====================

Bẫy gói chung được sử dụng để mô tả các bẫy bẫy các gói được xác định rõ
hoặc các gói bị kẹt do các điều kiện được xác định rõ (ví dụ: lỗi TTL).
Những cái bẫy như vậy có thể được chia sẻ bởi nhiều trình điều khiển thiết bị và mô tả của chúng phải
thêm vào bảng sau:

.. list-table:: List of Generic Packet Traps
   :widths: 5 5 90

   * - Name
     - Type
     - Description
   * - ``source_mac_is_multicast``
     - ``drop``
     - Traps incoming packets that the device decided to drop because of a
       multicast source MAC
   * - ``vlan_tag_mismatch``
     - ``drop``
     - Traps incoming packets that the device decided to drop in case of VLAN
       tag mismatch: The ingress bridge port is not configured with a PVID and
       the packet is untagged or prio-tagged
   * - ``ingress_vlan_filter``
     - ``drop``
     - Traps incoming packets that the device decided to drop in case they are
       tagged with a VLAN that is not configured on the ingress bridge port
   * - ``ingress_spanning_tree_filter``
     - ``drop``
     - Traps incoming packets that the device decided to drop in case the STP
       state of the ingress bridge port is not "forwarding"
   * - ``port_list_is_empty``
     - ``drop``
     - Traps packets that the device decided to drop in case they need to be
       flooded (e.g., unknown unicast, unregistered multicast) and there are
       no ports the packets should be flooded to
   * - ``port_loopback_filter``
     - ``drop``
     - Traps packets that the device decided to drop in case after layer 2
       forwarding the only port from which they should be transmitted through
       is the port from which they were received
   * - ``blackhole_route``
     - ``drop``
     - Traps packets that the device decided to drop in case they hit a
       blackhole route
   * - ``ttl_value_is_too_small``
     - ``exception``
     - Traps unicast packets that should be forwarded by the device whose TTL
       was decremented to 0 or less
   * - ``tail_drop``
     - ``drop``
     - Traps packets that the device decided to drop because they could not be
       enqueued to a transmission queue which is full
   * - ``non_ip``
     - ``drop``
     - Traps packets that the device decided to drop because they need to
       undergo a layer 3 lookup, but are not IP or MPLS packets
   * - ``uc_dip_over_mc_dmac``
     - ``drop``
     - Traps packets that the device decided to drop because they need to be
       routed and they have a unicast destination IP and a multicast destination
       MAC
   * - ``dip_is_loopback_address``
     - ``drop``
     - Traps packets that the device decided to drop because they need to be
       routed and their destination IP is the loopback address (i.e., 127.0.0.0/8
       and ::1/128)
   * - ``sip_is_mc``
     - ``drop``
     - Traps packets that the device decided to drop because they need to be
       routed and their source IP is multicast (i.e., 224.0.0.0/8 and ff::/8)
   * - ``sip_is_loopback_address``
     - ``drop``
     - Traps packets that the device decided to drop because they need to be
       routed and their source IP is the loopback address (i.e., 127.0.0.0/8 and ::1/128)
   * - ``ip_header_corrupted``
     - ``drop``
     - Traps packets that the device decided to drop because they need to be
       routed and their IP header is corrupted: wrong checksum, wrong IP version
       or too short Internet Header Length (IHL)
   * - ``ipv4_sip_is_limited_bc``
     - ``drop``
     - Traps packets that the device decided to drop because they need to be
       routed and their source IP is limited broadcast (i.e., 255.255.255.255/32)
   * - ``ipv6_mc_dip_reserved_scope``
     - ``drop``
     - Traps IPv6 packets that the device decided to drop because they need to
       be routed and their IPv6 multicast destination IP has a reserved scope
       (i.e., ffx0::/16)
   * - ``ipv6_mc_dip_interface_local_scope``
     - ``drop``
     - Traps IPv6 packets that the device decided to drop because they need to
       be routed and their IPv6 multicast destination IP has an interface-local scope
       (i.e., ffx1::/16)
   * - ``mtu_value_is_too_small``
     - ``exception``
     - Traps packets that should have been routed by the device, but were bigger
       than the MTU of the egress interface
   * - ``unresolved_neigh``
     - ``exception``
     - Traps packets that did not have a matching IP neighbour after routing
   * - ``mc_reverse_path_forwarding``
     - ``exception``
     - Traps multicast IP packets that failed reverse-path forwarding (RPF)
       check during multicast routing
   * - ``reject_route``
     - ``exception``
     - Traps packets that hit reject routes (i.e., "unreachable", "prohibit")
   * - ``ipv4_lpm_miss``
     - ``exception``
     - Traps unicast IPv4 packets that did not match any route
   * - ``ipv6_lpm_miss``
     - ``exception``
     - Traps unicast IPv6 packets that did not match any route
   * - ``non_routable_packet``
     - ``drop``
     - Traps packets that the device decided to drop because they are not
       supposed to be routed. For example, IGMP queries can be flooded by the
       device in layer 2 and reach the router. Such packets should not be
       routed and instead dropped
   * - ``decap_error``
     - ``exception``
     - Traps NVE and IPinIP packets that the device decided to drop because of
       failure during decapsulation (e.g., packet being too short, reserved
       bits set in VXLAN header)
   * - ``overlay_smac_is_mc``
     - ``drop``
     - Traps NVE packets that the device decided to drop because their overlay
       source MAC is multicast
   * - ``ingress_flow_action_drop``
     - ``drop``
     - Traps packets dropped during processing of ingress flow action drop
   * - ``egress_flow_action_drop``
     - ``drop``
     - Traps packets dropped during processing of egress flow action drop
   * - ``stp``
     - ``control``
     - Traps STP packets
   * - ``lacp``
     - ``control``
     - Traps LACP packets
   * - ``lldp``
     - ``control``
     - Traps LLDP packets
   * - ``igmp_query``
     - ``control``
     - Traps IGMP Membership Query packets
   * - ``igmp_v1_report``
     - ``control``
     - Traps IGMP Version 1 Membership Report packets
   * - ``igmp_v2_report``
     - ``control``
     - Traps IGMP Version 2 Membership Report packets
   * - ``igmp_v3_report``
     - ``control``
     - Traps IGMP Version 3 Membership Report packets
   * - ``igmp_v2_leave``
     - ``control``
     - Traps IGMP Version 2 Leave Group packets
   * - ``mld_query``
     - ``control``
     - Traps MLD Multicast Listener Query packets
   * - ``mld_v1_report``
     - ``control``
     - Traps MLD Version 1 Multicast Listener Report packets
   * - ``mld_v2_report``
     - ``control``
     - Traps MLD Version 2 Multicast Listener Report packets
   * - ``mld_v1_done``
     - ``control``
     - Traps MLD Version 1 Multicast Listener Done packets
   * - ``ipv4_dhcp``
     - ``control``
     - Traps IPv4 DHCP packets
   * - ``ipv6_dhcp``
     - ``control``
     - Traps IPv6 DHCP packets
   * - ``arp_request``
     - ``control``
     - Traps ARP request packets
   * - ``arp_response``
     - ``control``
     - Traps ARP response packets
   * - ``arp_overlay``
     - ``control``
     - Traps NVE-decapsulated ARP packets that reached the overlay network.
       This is required, for example, when the address that needs to be
       resolved is a local address
   * - ``ipv6_neigh_solicit``
     - ``control``
     - Traps IPv6 Neighbour Solicitation packets
   * - ``ipv6_neigh_advert``
     - ``control``
     - Traps IPv6 Neighbour Advertisement packets
   * - ``ipv4_bfd``
     - ``control``
     - Traps IPv4 BFD packets
   * - ``ipv6_bfd``
     - ``control``
     - Traps IPv6 BFD packets
   * - ``ipv4_ospf``
     - ``control``
     - Traps IPv4 OSPF packets
   * - ``ipv6_ospf``
     - ``control``
     - Traps IPv6 OSPF packets
   * - ``ipv4_bgp``
     - ``control``
     - Traps IPv4 BGP packets
   * - ``ipv6_bgp``
     - ``control``
     - Traps IPv6 BGP packets
   * - ``ipv4_vrrp``
     - ``control``
     - Traps IPv4 VRRP packets
   * - ``ipv6_vrrp``
     - ``control``
     - Traps IPv6 VRRP packets
   * - ``ipv4_pim``
     - ``control``
     - Traps IPv4 PIM packets
   * - ``ipv6_pim``
     - ``control``
     - Traps IPv6 PIM packets
   * - ``uc_loopback``
     - ``control``
     - Traps unicast packets that need to be routed through the same layer 3
       interface from which they were received. Such packets are routed by the
       kernel, but also cause it to potentially generate ICMP redirect packets
   * - ``local_route``
     - ``control``
     - Traps unicast packets that hit a local route and need to be locally
       delivered
   * - ``external_route``
     - ``control``
     - Traps packets that should be routed through an external interface (e.g.,
       management interface) that does not belong to the same device (e.g.,
       switch ASIC) as the ingress interface
   * - ``ipv6_uc_dip_link_local_scope``
     - ``control``
     - Traps unicast IPv6 packets that need to be routed and have a destination
       IP address with a link-local scope (i.e., fe80::/10). The trap allows
       device drivers to avoid programming link-local routes, but still receive
       packets for local delivery
   * - ``ipv6_dip_all_nodes``
     - ``control``
     - Traps IPv6 packets that their destination IP address is the "All Nodes
       Address" (i.e., ff02::1)
   * - ``ipv6_dip_all_routers``
     - ``control``
     - Traps IPv6 packets that their destination IP address is the "All Routers
       Address" (i.e., ff02::2)
   * - ``ipv6_router_solicit``
     - ``control``
     - Traps IPv6 Router Solicitation packets
   * - ``ipv6_router_advert``
     - ``control``
     - Traps IPv6 Router Advertisement packets
   * - ``ipv6_redirect``
     - ``control``
     - Traps IPv6 Redirect Message packets
   * - ``ipv4_router_alert``
     - ``control``
     - Traps IPv4 packets that need to be routed and include the Router Alert
       option. Such packets need to be locally delivered to raw sockets that
       have the IP_ROUTER_ALERT socket option set
   * - ``ipv6_router_alert``
     - ``control``
     - Traps IPv6 packets that need to be routed and include the Router Alert
       option in their Hop-by-Hop extension header. Such packets need to be
       locally delivered to raw sockets that have the IPV6_ROUTER_ALERT socket
       option set
   * - ``ptp_event``
     - ``control``
     - Traps PTP time-critical event messages (Sync, Delay_req, Pdelay_Req and
       Pdelay_Resp)
   * - ``ptp_general``
     - ``control``
     - Traps PTP general messages (Announce, Follow_Up, Delay_Resp,
       Pdelay_Resp_Follow_Up, management and signaling)
   * - ``flow_action_sample``
     - ``control``
     - Traps packets sampled during processing of flow action sample (e.g., via
       tc's sample action)
   * - ``flow_action_trap``
     - ``control``
     - Traps packets logged during processing of flow action trap (e.g., via
       tc's trap action)
   * - ``early_drop``
     - ``drop``
     - Traps packets dropped due to the RED (Random Early Detection) algorithm
       (i.e., early drops)
   * - ``vxlan_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the VXLAN header parsing which
       might be because of packet truncation or the I flag is not set.
   * - ``llc_snap_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the LLC+SNAP header parsing
   * - ``vlan_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the VLAN header parsing. Could
       include unexpected packet truncation.
   * - ``pppoe_ppp_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the PPPoE+PPP header parsing.
       This could include finding a session ID of 0xFFFF (which is reserved and
       not for use), a PPPoE length which is larger than the frame received or
       any common error on this type of header
   * - ``mpls_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the MPLS header parsing which
       could include unexpected header truncation
   * - ``arp_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the ARP header parsing
   * - ``ip_1_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the first IP header parsing.
       This packet trap could include packets which do not pass an IP checksum
       check, a header length check (a minimum of 20 bytes), which might suffer
       from packet truncation thus the total length field exceeds the received
       packet length etc
   * - ``ip_n_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the parsing of the last IP
       header (the inner one in case of an IP over IP tunnel). The same common
       error checking is performed here as for the ip_1_parsing trap
   * - ``gre_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the GRE header parsing
   * - ``udp_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the UDP header parsing.
       This packet trap could include checksum errors, an improper UDP
       length detected (smaller than 8 bytes) or detection of header
       truncation.
   * - ``tcp_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the TCP header parsing.
       This could include TCP checksum errors, improper combination of SYN, FIN
       and/or RESET etc.
   * - ``ipsec_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the IPSEC header parsing
   * - ``sctp_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the SCTP header parsing.
       This would mean that port number 0 was used or that the header is
       truncated.
   * - ``dccp_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the DCCP header parsing
   * - ``gtp_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the GTP header parsing
   * - ``esp_parsing``
     - ``drop``
     - Traps packets dropped due to an error in the ESP header parsing
   * - ``blackhole_nexthop``
     - ``drop``
     - Traps packets that the device decided to drop in case they hit a
       blackhole nexthop
   * - ``dmac_filter``
     - ``drop``
     - Traps incoming packets that the device decided to drop because
       the destination MAC is not configured in the MAC table and
       the interface is not in promiscuous mode
   * - ``eapol``
     - ``control``
     - Traps "Extensible Authentication Protocol over LAN" (EAPOL) packets
       specified in IEEE 802.1X
   * - ``locked_port``
     - ``drop``
     - Traps packets that the device decided to drop because they failed the
       locked bridge port check. That is, packets that were received via a
       locked port and whose {SMAC, VID} does not correspond to an FDB entry
       pointing to the port

Bẫy gói dành riêng cho trình điều khiển
============================

Trình điều khiển thiết bị có thể đăng ký bẫy gói dành riêng cho trình điều khiển, nhưng chúng phải được
có tài liệu rõ ràng. Những cái bẫy như vậy có thể tương ứng với các trường hợp ngoại lệ dành riêng cho thiết bị và
giúp gỡ lỗi các gói bị rớt do những ngoại lệ này gây ra. Danh sách sau đây bao gồm
liên kết đến mô tả bẫy dành riêng cho trình điều khiển được đăng ký bởi nhiều thiết bị khác nhau
trình điều khiển:

* Tài liệu/mạng/devlink/netdevsim.rst
  * Tài liệu/mạng/devlink/mlxsw.rst
  * Tài liệu/mạng/devlink/prestera.rst

.. _Generic-Packet-Trap-Groups:

Nhóm bẫy gói chung
==========================

Các nhóm bẫy gói chung được sử dụng để tổng hợp các gói liên quan đến logic
bẫy. Các nhóm này cho phép người dùng thực hiện các thao tác hàng loạt như đặt bẫy
hành động của tất cả các bẫy thành viên. Ngoài ra, ZZ0000ZZ có thể báo cáo tổng hợp
số liệu thống kê về gói và byte trên mỗi nhóm, trong trường hợp số liệu thống kê trên mỗi bẫy quá
hẹp. Mô tả của các nhóm này phải được thêm vào bảng sau:

.. list-table:: List of Generic Packet Trap Groups
   :widths: 10 90

   * - Name
     - Description
   * - ``l2_drops``
     - Contains packet traps for packets that were dropped by the device during
       layer 2 forwarding (i.e., bridge)
   * - ``l3_drops``
     - Contains packet traps for packets that were dropped by the device during
       layer 3 forwarding
   * - ``l3_exceptions``
     - Contains packet traps for packets that hit an exception (e.g., TTL
       error) during layer 3 forwarding
   * - ``buffer_drops``
     - Contains packet traps for packets that were dropped by the device due to
       an enqueue decision
   * - ``tunnel_drops``
     - Contains packet traps for packets that were dropped by the device during
       tunnel encapsulation / decapsulation
   * - ``acl_drops``
     - Contains packet traps for packets that were dropped by the device during
       ACL processing
   * - ``stp``
     - Contains packet traps for STP packets
   * - ``lacp``
     - Contains packet traps for LACP packets
   * - ``lldp``
     - Contains packet traps for LLDP packets
   * - ``mc_snooping``
     - Contains packet traps for IGMP and MLD packets required for multicast
       snooping
   * - ``dhcp``
     - Contains packet traps for DHCP packets
   * - ``neigh_discovery``
     - Contains packet traps for neighbour discovery packets (e.g., ARP, IPv6
       ND)
   * - ``bfd``
     - Contains packet traps for BFD packets
   * - ``ospf``
     - Contains packet traps for OSPF packets
   * - ``bgp``
     - Contains packet traps for BGP packets
   * - ``vrrp``
     - Contains packet traps for VRRP packets
   * - ``pim``
     - Contains packet traps for PIM packets
   * - ``uc_loopback``
     - Contains a packet trap for unicast loopback packets (i.e.,
       ``uc_loopback``). This trap is singled-out because in cases such as
       one-armed router it will be constantly triggered. To limit the impact on
       the CPU usage, a packet trap policer with a low rate can be bound to the
       group without affecting other traps
   * - ``local_delivery``
     - Contains packet traps for packets that should be locally delivered after
       routing, but do not match more specific packet traps (e.g.,
       ``ipv4_bgp``)
   * - ``external_delivery``
     - Contains packet traps for packets that should be routed through an
       external interface (e.g., management interface) that does not belong to
       the same device (e.g., switch ASIC) as the ingress interface
   * - ``ipv6``
     - Contains packet traps for various IPv6 control packets (e.g., Router
       Advertisements)
   * - ``ptp_event``
     - Contains packet traps for PTP time-critical event messages (Sync,
       Delay_req, Pdelay_Req and Pdelay_Resp)
   * - ``ptp_general``
     - Contains packet traps for PTP general messages (Announce, Follow_Up,
       Delay_Resp, Pdelay_Resp_Follow_Up, management and signaling)
   * - ``acl_sample``
     - Contains packet traps for packets that were sampled by the device during
       ACL processing
   * - ``acl_trap``
     - Contains packet traps for packets that were trapped (logged) by the
       device during ACL processing
   * - ``parser_error_drops``
     - Contains packet traps for packets that were marked by the device during
       parsing as erroneous
   * - ``eapol``
     - Contains packet traps for "Extensible Authentication Protocol over LAN"
       (EAPOL) packets specified in IEEE 802.1X

Cảnh sát bẫy gói
====================

Như đã giải thích trước đây, thiết bị cơ bản có thể bẫy các gói nhất định vào
CPU để xử lý. Trong hầu hết các trường hợp, thiết bị cơ bản có khả năng xử lý
tốc độ gói cao hơn vài bậc so với tốc độ gói
có thể được xử lý bởi CPU.

Do đó, để ngăn thiết bị cơ bản lấn át CPU,
các thiết bị thường bao gồm các cảnh sát bẫy gói có khả năng cảnh sát
các gói bị mắc kẹt ở mức mà CPU có thể xử lý.

Cơ chế ZZ0001ZZ cho phép các trình điều khiển thiết bị có khả năng đăng ký
hỗ trợ cảnh sát bẫy gói với ZZ0002ZZ. Trình điều khiển thiết bị có thể chọn
để liên kết các cảnh sát này với các nhóm bẫy gói được hỗ trợ (xem
ZZ0000ZZ) trong quá trình khởi tạo, do đó làm lộ ra
chính sách mặt phẳng điều khiển mặc định của nó đối với không gian người dùng.

Trình điều khiển thiết bị nên cho phép không gian người dùng thay đổi các thông số của cảnh sát
(ví dụ: tốc độ, kích thước cụm) cũng như sự liên kết giữa cảnh sát và
nhóm bẫy bằng cách thực hiện các cuộc gọi lại có liên quan.

Nếu có thể, trình điều khiển thiết bị nên triển khai lệnh gọi lại để cho phép không gian người dùng
để lấy lại số lượng gói tin đã bị cảnh sát đánh rơi vì nó
chính sách được cấu hình đã bị vi phạm.

Kiểm tra
=======

Xem ZZ0000ZZ để biết
thử nghiệm bao phủ cơ sở hạ tầng cốt lõi. Các trường hợp thử nghiệm nên được thêm vào cho bất kỳ trường hợp mới nào
chức năng.

Trình điều khiển thiết bị nên tập trung kiểm tra chức năng dành riêng cho thiết bị, chẳng hạn như
như kích hoạt các bẫy gói được hỗ trợ.