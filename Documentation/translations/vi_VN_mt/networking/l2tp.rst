.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/l2tp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====
L2TP
====

Giao thức đường hầm lớp 2 (L2TP) cho phép các khung L2 được truyền qua đường hầm
một mạng IP.

Tài liệu này bao gồm hệ thống con L2TP của kernel. Nó ghi lại kernel
API dành cho nhà phát triển ứng dụng muốn sử dụng hệ thống con L2TP và
nó cung cấp một số chi tiết kỹ thuật về việc triển khai nội bộ
có thể hữu ích cho các nhà phát triển và bảo trì kernel.

Tổng quan
========

Hệ thống con L2TP của kernel triển khai đường dẫn dữ liệu cho L2TPv2 và
L2TPv3. L2TPv2 được truyền qua UDP. L2TPv3 được truyền qua UDP hoặc
trực tiếp qua IP (giao thức 115).

RFC L2TP xác định hai loại gói L2TP cơ bản: gói điều khiển
("mặt phẳng điều khiển") và các gói dữ liệu ("mặt phẳng dữ liệu"). Hạt nhân
chỉ xử lý các gói dữ liệu. Các gói điều khiển phức tạp hơn
được xử lý bởi không gian người dùng.

Một đường hầm L2TP mang một hoặc nhiều phiên L2TP. Mỗi đường hầm là
liên kết với một ổ cắm. Mỗi phiên được liên kết với một phiên ảo
netdevice, ví dụ: ZZ0000ZZ, ZZ0001ZZ, qua đó các khung dữ liệu đi qua
đến/từ L2TP. Các trường trong tiêu đề L2TP xác định đường hầm hoặc phiên
và liệu đó là gói điều khiển hay gói dữ liệu. Khi đường hầm và phiên
được thiết lập bằng nhân Linux API, chúng tôi chỉ đang thiết lập L2TP
đường dẫn dữ liệu. Tất cả các khía cạnh của giao thức điều khiển sẽ được xử lý bởi
không gian người dùng.

Sự phân chia trách nhiệm này dẫn đến một trình tự tự nhiên của
hoạt động khi thiết lập đường hầm và phiên. Thủ tục trông
như thế này:

1) Tạo một ổ cắm đường hầm. Trao đổi tin nhắn giao thức điều khiển L2TP
       với thiết bị ngang hàng trên ổ cắm đó để thiết lập một đường hầm.

2) Tạo bối cảnh đường hầm trong kernel, sử dụng thông tin
       thu được từ thiết bị ngang hàng bằng cách sử dụng các thông báo giao thức điều khiển.

3) Trao đổi thông báo giao thức điều khiển L2TP với thiết bị ngang hàng qua
       ổ cắm đường hầm để thiết lập một phiên.

4) Tạo bối cảnh phiên trong kernel bằng thông tin
       thu được từ thiết bị ngang hàng bằng cách sử dụng các thông báo giao thức điều khiển.

API L2TP
=========

Phần này ghi lại từng không gian người dùng API của hệ thống con L2TP.

Ổ cắm đường hầm
--------------

L2TPv2 luôn sử dụng UDP. L2TPv3 có thể sử dụng đóng gói UDP hoặc IP.

Để tạo một ổ cắm đường hầm để L2TP sử dụng, POSIX tiêu chuẩn
ổ cắm API được sử dụng.

Ví dụ: đối với đường hầm sử dụng địa chỉ IPv4 và đóng gói UDP ::

int sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

Hoặc đối với đường hầm sử dụng địa chỉ IPv6 và đóng gói IP ::

int sockfd = socket(AF_INET6, SOCK_DGRAM, IPPROTO_L2TP);

Lập trình socket UDP không cần phải trình bày ở đây.

IPPROTO_L2TP là loại giao thức IP được triển khai bởi L2TP của kernel
hệ thống con. Địa chỉ ổ cắm L2TPIP được xác định trong struct
sockaddr_l2tpip và struct sockaddr_l2tpip6 tại
ZZ0000ZZ. Địa chỉ bao gồm đường hầm L2TP
(kết nối) id. Để sử dụng đóng gói IP L2TP, ứng dụng L2TPv3
nên liên kết ổ cắm L2TPIP bằng cách sử dụng ổ cắm được gán cục bộ
id đường hầm. Khi biết địa chỉ IP và id đường hầm của thiết bị ngang hàng,
kết nối phải được thực hiện.

Nếu ứng dụng L2TP cần xử lý các yêu cầu thiết lập đường hầm L2TPv3
từ các đồng nghiệp sử dụng L2TPIP, nó phải mở L2TPIP chuyên dụng
socket để lắng nghe những yêu cầu đó và liên kết ổ cắm bằng đường hầm
id 0 vì yêu cầu thiết lập đường hầm được gửi tới id đường hầm 0.

Đường hầm L2TP và tất cả các phiên của nó sẽ tự động bị đóng khi
ổ cắm đường hầm của nó được đóng lại.

Netlink API
-----------

Các ứng dụng L2TP sử dụng liên kết mạng để quản lý đường hầm và phiên L2TP
các trường hợp trong kernel. Liên kết mạng L2TP API được xác định trong
ZZ0000ZZ.

L2TP sử dụng ZZ0001ZZ (GENL). Một số lệnh được xác định:
Tạo, xóa, sửa đổi và nhận cho đường hầm và phiên
trường hợp, ví dụ: ZZ0000ZZ. Tiêu đề API liệt kê
các loại thuộc tính netlink có thể được sử dụng với mỗi lệnh.

Các phiên bản đường hầm và phiên được xác định bởi một địa chỉ duy nhất cục bộ
Mã nhận dạng 32-bit.  Id đường hầm L2TP được cung cấp bởi ZZ0000ZZ và
Thuộc tính ZZ0001ZZ và id phiên L2TP được cung cấp
bởi ZZ0002ZZ và ZZ0003ZZ
thuộc tính. Nếu netlink được sử dụng để quản lý đường hầm và phiên L2TPv2
Trong các trường hợp, id phiên/đường hầm L2TPv2 16 bit được chuyển sang 32 bit
giá trị trong các thuộc tính này.

Trong lệnh ZZ0000ZZ, ZZ0001ZZ sẽ thông báo cho
kernel ổ cắm đường hầm fd đang được sử dụng. Nếu không được chỉ định, hạt nhân
tạo một ổ cắm hạt nhân cho đường hầm, sử dụng các tham số IP được đặt trong
ZZ0002ZZ, ZZ0003ZZ,
Thuộc tính ZZ0004ZZ, ZZ0005ZZ. hạt nhân
socket được sử dụng để triển khai các đường hầm L2TPv3 không được quản lý (địa chỉ "ip của iproute2
lệnh l2tp"). Nếu ZZ0006ZZ được cung cấp thì nó phải là ổ cắm fd
đó đã được ràng buộc và kết nối. Có thêm thông tin về
các đường hầm không được quản lý ở phần sau của tài liệu này.

Thuộc tính ZZ0000ZZ: -

=========================== ===
Thuộc tính bắt buộc sử dụng
=========================== ===
CONN_ID Y Đặt id đường hầm (kết nối).
PEER_CONN_ID Y Đặt id đường hầm ngang hàng (kết nối).
Phiên bản giao thức PROTO_VERSION Y. 2 hoặc 3.
ENCAP_TYPE Y Kiểu đóng gói: UDP hoặc IP.
Bộ mô tả tệp ổ cắm đường hầm FD N.
UDP_CSUM N Kích hoạt tổng kiểm tra IPv4 UDP. Chỉ được sử dụng nếu FD
                            không được thiết lập.
Tổng kiểm tra UDP_ZERO_CSUM6_TX N Zero IPv6 UDP khi truyền. Chỉ được sử dụng
                            nếu FD không được thiết lập.
Tổng kiểm tra UDP_ZERO_CSUM6_RX N Zero IPv6 UDP khi nhận. Chỉ được sử dụng nếu
                            FD không được thiết lập.
IP_SADDR N Địa chỉ nguồn IPv4. Chỉ được sử dụng nếu FD không
                            thiết lập.
IP_DADDR N Địa chỉ đích IPv4. Chỉ được sử dụng nếu FD
                            không được thiết lập.
Cổng nguồn UDP_SPORT N UDP. Chỉ được sử dụng nếu FD không được đặt.
Cổng đích UDP_DPORT N UDP. Chỉ được sử dụng nếu FD không
                            thiết lập.
IP6_SADDR N Địa chỉ nguồn IPv6. Chỉ được sử dụng nếu FD không
                            thiết lập.
IP6_DADDR N Địa chỉ đích IPv6. Chỉ được sử dụng nếu FD
                            không được thiết lập.
Cờ gỡ lỗi DEBUG N.
=========================== ===

Thuộc tính ZZ0000ZZ: -

=========================== ===
Thuộc tính bắt buộc sử dụng
=========================== ===
CONN_ID Y Xác định id đường hầm sẽ bị hủy.
=========================== ===

Thuộc tính ZZ0000ZZ: -

=========================== ===
Thuộc tính bắt buộc sử dụng
=========================== ===
CONN_ID Y Xác định id đường hầm cần sửa đổi.
Cờ gỡ lỗi DEBUG N.
=========================== ===

Thuộc tính ZZ0000ZZ: -

=========================== ===
Thuộc tính bắt buộc sử dụng
=========================== ===
CONN_ID N Xác định id đường hầm được truy vấn.
                            Bị bỏ qua trong các yêu cầu DUMP.
=========================== ===

Thuộc tính ZZ0000ZZ: -

=========================== ===
Thuộc tính bắt buộc sử dụng
=========================== ===
CONN_ID Y Id đường hầm chính.
SESSION_ID Y Đặt id phiên.
PEER_SESSION_ID Y Đặt id phiên chính.
PW_TYPE Y Đặt loại dây giả.
DEBUG N Cờ gỡ lỗi.
RECV_SEQ N Kích hoạt số thứ tự dữ liệu rx.
SEND_SEQ N Kích hoạt số thứ tự dữ liệu tx.
LNS_MODE N Bật chế độ LNS (tự động bật chuỗi dữ liệu
                            số).
RECV_TIMEOUT N Hết thời gian chờ khi nhận được thứ tự sắp xếp lại
                            gói.
L2SPEC_TYPE N Đặt loại lớp con dành riêng cho lớp 2 (L2TPv3
                            chỉ).
COOKIE N Đặt cookie tùy chọn (chỉ L2TPv3).
PEER_COOKIE N Đặt cookie ngang hàng tùy chọn (chỉ L2TPv3).
IFNAME N Đặt tên giao diện (chỉ L2TPv3).
=========================== ===

Đối với các loại phiên Ethernet, điều này sẽ tạo ra một l2tpeth ảo
giao diện mà sau đó có thể được cấu hình theo yêu cầu. Đối với phiên PPP
các loại, ổ cắm PPPoL2TP cũng phải được mở và kết nối, ánh xạ nó
vào phiên mới. Điều này sẽ được đề cập trong "Ổ cắm PPPoL2TP" sau.

Thuộc tính ZZ0000ZZ: -

=========================== ===
Thuộc tính bắt buộc sử dụng
=========================== ===
CONN_ID Y Xác định id đường hầm chính của phiên
                            bị phá hủy.
SESSION_ID Y Xác định id phiên bị hủy.
IFNAME N Xác định phiên theo tên giao diện. Nếu
                            được đặt, điều này sẽ ghi đè mọi CONN_ID và SESSION_ID
                            thuộc tính. Hiện được hỗ trợ cho L2TPv3
                            Chỉ phiên Ethernet.
=========================== ===

Thuộc tính ZZ0000ZZ: -

=========================== ===
Thuộc tính bắt buộc sử dụng
=========================== ===
CONN_ID Y Xác định id đường hầm chính của phiên
                            được sửa đổi.
SESSION_ID Y Xác định id phiên cần sửa đổi.
IFNAME N Xác định phiên theo tên giao diện. Nếu
                            được đặt, điều này sẽ ghi đè mọi CONN_ID và SESSION_ID
                            thuộc tính. Hiện được hỗ trợ cho L2TPv3
                            Chỉ phiên Ethernet.
DEBUG N Cờ gỡ lỗi.
RECV_SEQ N Kích hoạt số thứ tự dữ liệu rx.
SEND_SEQ N Kích hoạt số thứ tự dữ liệu tx.
LNS_MODE N Bật chế độ LNS (tự động bật chuỗi dữ liệu
                            số).
RECV_TIMEOUT N Hết thời gian chờ khi nhận được yêu cầu sắp xếp lại
                            gói.
=========================== ===

Thuộc tính ZZ0000ZZ: -

=========================== ===
Thuộc tính bắt buộc sử dụng
=========================== ===
CONN_ID N Xác định id đường hầm được truy vấn.
                            Đã bỏ qua các yêu cầu DUMP.
SESSION_ID N Xác định id phiên được truy vấn.
                            Đã bỏ qua các yêu cầu DUMP.
IFNAME N Xác định phiên theo tên giao diện.
                            Nếu được đặt, điều này sẽ ghi đè mọi CONN_ID và
                            Thuộc tính SESSION_ID. Bị bỏ qua đối với DUMP
                            yêu cầu. Hiện được hỗ trợ cho L2TPv3
                            Chỉ phiên Ethernet.
=========================== ===

Các nhà phát triển ứng dụng nên tham khảo ZZ0000ZZ để biết
định nghĩa lệnh và thuộc tính netlink.

Mã vùng người dùng mẫu sử dụng libmnl_:

- Mở ổ cắm netlink L2TP::

cấu trúc nl_sock *nl_sock;
        int l2tp_nl_family_id;

nl_sock = nl_socket_alloc();
        genl_connect(nl_sock);
        genl_id = genl_ctrl_resolve(nl_sock, L2TP_GENL_NAME);

- Tạo đường hầm::

struct nlmsghdr *nlh;
        struct genlmsghdr *gnlh;

nlh = mnl_nlmsg_put_header(buf);
        nlh->nlmsg_type = genl_id; /* được gán cho genl socket */
        nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
        nlh->nlmsg_seq = seq;

gnlh = mnl_nlmsg_put_extra_header(nlh, sizeof(*gnlh));
        gnlh->cmd = L2TP_CMD_TUNNEL_CREATE;
        gnlh->phiên bản = L2TP_GENL_VERSION;
        gnlh->dành riêng = 0;

mnl_attr_put_u32(nlh, L2TP_ATTR_FD, tul_sock_fd);
        mnl_attr_put_u32(nlh, L2TP_ATTR_CONN_ID, tid);
        mnl_attr_put_u32(nlh, L2TP_ATTR_PEER_CONN_ID, ngang hàng_tid);
        mnl_attr_put_u8(nlh, L2TP_ATTR_PROTO_VERSION, giao thức_version);
        mnl_attr_put_u16(nlh, L2TP_ATTR_ENCAP_TYPE, encap);

- Tạo phiên::

struct nlmsghdr *nlh;
        struct genlmsghdr *gnlh;

nlh = mnl_nlmsg_put_header(buf);
        nlh->nlmsg_type = genl_id; /* được gán cho genl socket */
        nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
        nlh->nlmsg_seq = seq;

gnlh = mnl_nlmsg_put_extra_header(nlh, sizeof(*gnlh));
        gnlh->cmd = L2TP_CMD_SESSION_CREATE;
        gnlh->phiên bản = L2TP_GENL_VERSION;
        gnlh->dành riêng = 0;

mnl_attr_put_u32(nlh, L2TP_ATTR_CONN_ID, tid);
        mnl_attr_put_u32(nlh, L2TP_ATTR_PEER_CONN_ID, ngang hàng_tid);
        mnl_attr_put_u32(nlh, L2TP_ATTR_SESSION_ID, sid);
        mnl_attr_put_u32(nlh, L2TP_ATTR_PEER_SESSION_ID, ngang hàng_sid);
        mnl_attr_put_u16(nlh, L2TP_ATTR_PW_TYPE, pwtype);
        /* có các tùy chọn phiên khác có thể được đặt bằng netlink
         * thuộc tính trong quá trình tạo phiên -- xem l2tp.h
         */

- Xóa một phiên::

struct nlmsghdr *nlh;
        struct genlmsghdr *gnlh;

nlh = mnl_nlmsg_put_header(buf);
        nlh->nlmsg_type = genl_id; /* được gán cho genl socket */
        nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
        nlh->nlmsg_seq = seq;

gnlh = mnl_nlmsg_put_extra_header(nlh, sizeof(*gnlh));
        gnlh->cmd = L2TP_CMD_SESSION_DELETE;
        gnlh->phiên bản = L2TP_GENL_VERSION;
        gnlh->dành riêng = 0;

mnl_attr_put_u32(nlh, L2TP_ATTR_CONN_ID, tid);
        mnl_attr_put_u32(nlh, L2TP_ATTR_SESSION_ID, sid);

- Xóa một đường hầm và tất cả các phiên của nó (nếu có)::

struct nlmsghdr *nlh;
        struct genlmsghdr *gnlh;

nlh = mnl_nlmsg_put_header(buf);
        nlh->nlmsg_type = genl_id; /* được gán cho genl socket */
        nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
        nlh->nlmsg_seq = seq;

gnlh = mnl_nlmsg_put_extra_header(nlh, sizeof(*gnlh));
        gnlh->cmd = L2TP_CMD_TUNNEL_DELETE;
        gnlh->phiên bản = L2TP_GENL_VERSION;
        gnlh->dành riêng = 0;

mnl_attr_put_u32(nlh, L2TP_ATTR_CONN_ID, tid);

Ổ cắm phiên PPPoL2TP API
---------------------------

Đối với các loại phiên PPP, ổ cắm PPPoL2TP phải được mở và kết nối
tới phiên L2TP.

Khi tạo ổ cắm PPPoL2TP, ứng dụng sẽ cung cấp thông tin
tới kernel về đường hầm và phiên trong socket connect()
gọi. ID phiên và đường hầm nguồn và đích được cung cấp, như
cũng như bộ mô tả tệp của ổ cắm UDP hoặc L2TPIP. Xem cấu trúc
pppol2tp_addr trong ZZ0000ZZ. Vì lý do lịch sử,
Thật không may, có cấu trúc địa chỉ hơi khác nhau cho
Các đường hầm và không gian người dùng L2TPv2/L2TPv3 IPv4/IPv6 phải sử dụng
cấu trúc phù hợp với loại ổ cắm đường hầm.

Không gian người dùng có thể kiểm soát hành vi của đường hầm hoặc phiên bằng cách sử dụng
setsockopt và ioctl trên ổ cắm PPPoX. Ổ cắm sau
các tùy chọn được hỗ trợ: -

==========================================================================
Mặt nạ bit DEBUG của các danh mục thông báo gỡ lỗi. Xem bên dưới.
SENDSEQ - 0 => không gửi gói có số thứ tự
            - 1 => gửi gói có số thứ tự
RECVSEQ - 0 => số thứ tự nhận gói là tùy chọn
            - 1 => bỏ gói nhận không có số thứ tự
LNSMODE - 0 => đóng vai trò LAC.
            - 1 => đóng vai trò LNS.
REORDERTO sắp xếp lại thời gian chờ (tính bằng mili giây). Nếu là 0, đừng cố sắp xếp lại.
==========================================================================

Ngoài ioctls PPP tiêu chuẩn, PPPIOCGL2TPSTATS được cung cấp
để truy xuất số liệu thống kê về đường hầm và phiên từ kernel bằng cách sử dụng
Ổ cắm PPPoX của đường hầm hoặc phiên thích hợp.

Mã không gian người dùng mẫu:

- Tạo socket dữ liệu PPPoX phiên::

/* Đầu vào: đường hầm L2TP UDP ổ cắm ZZ0000ZZ, cần phải có
         * đã bị ràng buộc (cả sockname và ngang hàng), nếu không thì sẽ không
         * sẵn sàng.
         */

struct sockaddr_pppol2tp sax;
        int phiên_fd;
        int ret;

session_fd = ổ cắm (AF_PPPOX, SOCK_DGRAM, PX_PROTO_OL2TP);
        nếu (session_fd < 0)
                return -errno;

sax.sa_family = AF_PPPOX;
        sax.sa_protocol = PX_PROTO_OL2TP;
        sax.pppol2tp.fd = đường hầm_fd;
        sax.pppol2tp.addr.sin_addr.s_addr = addr->sin_addr.s_addr;
        sax.pppol2tp.addr.sin_port = addr->sin_port;
        sax.pppol2tp.addr.sin_family = AF_INET;
        sax.pppol2tp.s_tunnel = đường hầm_id;
        sax.pppol2tp.s_session = session_id;
        sax.pppol2tp.d_tunnel = ngang hàng_tunnel_id;
        sax.pppol2tp.d_session = ngang hàng_session_id;

/* session_fd là fd của ổ cắm PPPoL2TP của phiên.
         * Tunnel_fd là fd của ổ cắm đường hầm UDP / L2TPIP.
         */
        ret = connect(session_fd, (struct sockaddr *)&sax, sizeof(sax));
        nếu (ret < 0 ) {
                đóng(session_fd);
                return -errno;
        }

trả về session_fd;

Các gói điều khiển L2TP vẫn có sẵn để đọc trên ZZ0000ZZ.

- Tạo kênh PPP::

/* Input: the session PPPoX data socket ZZ0000ZZ which was created
         * như đã mô tả ở trên.
         */

int ppp_chan_fd;
        int chindx;
        int ret;

ret = ioctl(session_fd, PPPIOCGCHAN, &chindx);
        nếu (ret < 0)
                return -errno;

ppp_chan_fd = open("/dev/ppp", O_RDWR);
        nếu (ppp_chan_fd < 0)
                return -errno;

ret = ioctl(ppp_chan_fd, PPPIOCATTCHAN, &chindx);
        nếu (ret < 0) {
                đóng(ppp_chan_fd);
                return -errno;
        }

trả về ppp_chan_fd;

Các khung LCP PPP sẽ có sẵn để đọc trên ZZ0000ZZ.

- Tạo giao diện PPP::

/* Đầu vào: kênh PPP ZZ0000ZZ được tạo như mô tả
         * ở trên.
         */

int ifunit = -1;
        int ppp_if_fd;
        int ret;

ppp_if_fd = open("/dev/ppp", O_RDWR);
        nếu (ppp_if_fd < 0)
                return -errno;

ret = ioctl(ppp_if_fd, PPPIOCNEWUNIT, &ifunit);
        nếu (ret < 0) {
                đóng(ppp_if_fd);
                return -errno;
        }

ret = ioctl(ppp_chan_fd, PPPIOCCONNECT, &ifunit);
        nếu (ret < 0) {
                đóng(ppp_if_fd);
                return -errno;
        }

trả về ppp_if_fd;

Các khung IPCP/IPv6CP PPP sẽ có sẵn để đọc trên ZZ0000ZZ.

Giao diện ppp<ifunit> sau đó có thể được cấu hình như bình thường với netlink's
RTM_NEWLINK, RTM_NEWADDR, RTM_NEWROUTE hoặc SIOCSIFMTU, SIOCSIFADDR của ioctl,
SIOCSIFDSTADDR, SIOCSIFNETMASK, SIOCSIFFLAGS hoặc bằng lệnh ZZ0000ZZ.

- Kết nối các phiên L2TP có loại dây giả PPP (điều này còn được gọi là
    Chuyển mạch đường hầm L2TP hoặc L2TP multihop) được hỗ trợ bằng cách kết nối PPP
    các kênh của hai phiên L2TP sẽ được bắc cầu::

/* Đầu vào: ổ cắm dữ liệu PPPoX phiên ZZ0000ZZ và ZZ0001ZZ
         * được tạo như mô tả thêm ở trên.
         */

int ppp_chan_fd;
        int chindx1;
        int chindx2;
        int ret;

ret = ioctl(session_fd1, PPPIOCGCHAN, &chindx1);
        nếu (ret < 0)
                return -errno;

ret = ioctl(session_fd2, PPPIOCGCHAN, &chindx2);
        nếu (ret < 0)
                return -errno;

ppp_chan_fd = open("/dev/ppp", O_RDWR);
        nếu (ppp_chan_fd < 0)
                return -errno;

ret = ioctl(ppp_chan_fd, PPPIOCATTCHAN, &chindx1);
        nếu (ret < 0) {
                đóng(ppp_chan_fd);
                return -errno;
        }

ret = ioctl(ppp_chan_fd, PPPIOCBRIDGECHAN, &chindx2);
        đóng(ppp_chan_fd);
        nếu (ret < 0)
                return -errno;

trả về 0;

Có thể lưu ý rằng khi bắc cầu các kênh PPP, phiên PPP không cục bộ
chấm dứt và không có giao diện PPP cục bộ nào được tạo.  Các khung PPP đến trên một
kênh này được truyền trực tiếp sang kênh khác và ngược lại.

Kênh PPP không cần phải mở.  Chỉ dữ liệu PPPoX phiên
ổ cắm cần phải được giữ mở.

Tổng quát hơn, cũng có thể thực hiện theo cách tương tự với ví dụ: kết nối PPPoL2TP
Kênh PPP với các loại kênh PPP khác, chẳng hạn như PPPoE.

Xem thêm thông tin chi tiết về phía PPP trong ppp_generic.rst.

API chỉ có L2TPv2 cũ
-------------------

Khi L2TP lần đầu tiên được thêm vào nhân Linux ở phiên bản 2.6.23, nó
chỉ triển khai L2TPv2 và không bao gồm netlink API. Thay vào đó,
các phiên bản đường hầm và phiên trong kernel được quản lý trực tiếp bằng cách sử dụng
chỉ có ổ cắm PPPoL2TP. Ổ cắm PPPoL2TP được sử dụng như mô tả trong
phần "Ổ cắm phiên PPPoL2TP API" nhưng các phiên bản đường hầm và phiên
được tạo tự động trên kết nối() của ổ cắm thay vì
được tạo bởi một yêu cầu liên kết mạng riêng biệt:

- Đường hầm được quản lý bằng cách sử dụng ổ cắm quản lý đường hầm.
      ổ cắm PPPoL2TP chuyên dụng, được kết nối với phiên (không hợp lệ)
      id 0. Phiên bản đường hầm L2TP được tạo khi PPPoL2TP
      ổ cắm quản lý đường hầm được kết nối và bị hủy khi
      ổ cắm đã đóng.

- Phiên bản phiên được tạo trong kernel khi PPPoL2TP
      socket được kết nối với id phiên khác không. Thông số phiên
      được thiết lập bằng setsockopt. Phiên bản phiên L2TP bị hủy
      khi ổ cắm được đóng lại.

API này vẫn được hỗ trợ nhưng việc sử dụng nó không được khuyến khích. Thay vào đó, mới
Các ứng dụng L2TPv2 nên sử dụng liên kết mạng để tạo đường hầm trước tiên và
phiên, sau đó tạo ổ cắm PPPoL2TP cho phiên.

Đường hầm L2TPv3 không được quản lý
------------------------

Hệ thống con L2TP kernel cũng hỗ trợ L2TPv3 tĩnh (không được quản lý)
đường hầm. Đường hầm không được quản lý không có ổ cắm đường hầm không gian người dùng và
trao đổi thông báo không kiểm soát với thiết bị ngang hàng để thiết lập đường hầm; cái
đường hầm được cấu hình thủ công ở mỗi đầu của đường hầm. Tất cả
cấu hình được thực hiện bằng cách sử dụng netlink. Không cần L2TP
ứng dụng không gian người dùng trong trường hợp này -- ổ cắm đường hầm được tạo bởi
kernel và được cấu hình bằng các tham số được gửi trong
Yêu cầu liên kết mạng ZZ0000ZZ. Tiện ích ZZ0001ZZ của
ZZ0002ZZ có các lệnh để quản lý đường hầm L2TPv3 tĩnh; làm ZZ0003ZZ để biết thêm thông tin.

Gỡ lỗi
---------

Hệ thống con L2TP cung cấp một loạt các giao diện gỡ lỗi thông qua
hệ thống tập tin debugfs.

Để truy cập các giao diện này, trước tiên hệ thống tệp debugfs phải được gắn kết ::

# mount -t debugfs debugfs/gỡ lỗi

Sau đó, các tệp trong thư mục l2tp có thể được truy cập, cung cấp bản tóm tắt
về tổng thể hiện tại của bối cảnh đường hầm và phiên hiện có trong
hạt nhân::

# cat/gỡ lỗi/l2tp/đường hầm

Các ứng dụng không nên sử dụng các tệp debugfs để lấy L2TP
thông tin trạng thái vì định dạng tệp có thể thay đổi. Đó là
được triển khai để cung cấp thêm thông tin gỡ lỗi nhằm giúp chẩn đoán
vấn đề. Thay vào đó, các ứng dụng nên sử dụng netlink API.

Ngoài ra, hệ thống con L2TP còn triển khai các điểm theo dõi bằng cách sử dụng tiêu chuẩn
truy tìm sự kiện hạt nhân API.  Các sự kiện L2TP có sẵn có thể được xem xét dưới dạng
sau::

# find/gỡ lỗi/truy tìm/sự kiện/l2tp

Cuối cùng, /proc/net/pppol2tp cũng được cung cấp để tương thích ngược
với mã pppol2tp gốc. Nó liệt kê thông tin về L2TPv2
chỉ có đường hầm và phiên. Việc sử dụng nó không được khuyến khích.

Triển khai nội bộ
=======================

Phần này dành cho các nhà phát triển và bảo trì kernel.

Ổ cắm
-------

Ổ cắm UDP được triển khai bởi lõi mạng. Khi một L2TP
đường hầm được tạo bằng ổ cắm UDP, ổ cắm được thiết lập dưới dạng
ổ cắm UDP được đóng gói bằng cách đặt encap_rcv và encap_destroy
cuộc gọi lại trên ổ cắm UDP. l2tp_udp_encap_recv được gọi khi
các gói được nhận trên socket. l2tp_udp_encap_destroy được gọi
khi không gian người dùng đóng ổ cắm.

Ổ cắm L2TPIP được triển khai trong ZZ0000ZZ và
ZZ0001ZZ.

Đường hầm
-------

Hạt nhân giữ bối cảnh struct l2tp_tunnel trên mỗi đường hầm L2TP. các
l2tp_tunnel luôn được liên kết với ổ cắm UDP hoặc L2TP/IP và
giữ một danh sách các phiên trong đường hầm. Khi một đường hầm lần đầu tiên xuất hiện
đã đăng ký với lõi L2TP, số tham chiếu trên ổ cắm là
tăng lên. Điều này đảm bảo rằng ổ cắm không thể bị tháo ra trong khi L2TP
cấu trúc dữ liệu tham chiếu nó.

Đường hầm được xác định bằng id đường hầm duy nhất. Id là 16-bit cho
L2TPv2 và 32-bit cho L2TPv3. Bên trong, id được lưu trữ dưới dạng 32-bit
giá trị.

Các đường hầm được lưu giữ trong danh sách trên mỗi mạng, được lập chỉ mục theo id đường hầm. các
không gian tên id đường hầm được chia sẻ bởi L2TPv2 và L2TPv3.

Xử lý việc đóng socket đường hầm có lẽ là phần khó khăn nhất trong quá trình
Triển khai L2TP. Nếu không gian người dùng đóng ổ cắm đường hầm, L2TP
đường hầm và tất cả các phiên của nó phải được đóng và hủy. Kể từ khi
bối cảnh đường hầm giữ một tham chiếu trên ổ cắm đường hầm, ổ cắm
sk_desturation sẽ không được gọi cho đến khi đường hầm sock_put được hoàn thành
ổ cắm. Đối với ổ cắm UDP, khi không gian người dùng đóng ổ cắm đường hầm,
trình xử lý encap_destroy của socket được gọi, mà L2TP sử dụng để khởi tạo
hành động đóng đường hầm của nó. Đối với ổ cắm L2TPIP, ổ cắm đóng
trình xử lý bắt đầu các hành động đóng đường hầm tương tự. Tất cả các phiên đều
đầu tiên đóng cửa. Mỗi phiên giảm tham chiếu đường hầm của nó. Khi đường hầm giới thiệu
đạt tới 0, đường hầm sẽ loại bỏ socket ref của nó.

Phiên
--------

Kernel giữ bối cảnh struct l2tp_session cho mỗi phiên.  Mỗi
phiên có dữ liệu riêng tư được sử dụng cho dữ liệu cụ thể cho
loại phiên. Với L2TPv2, phiên luôn mang PPP
giao thông. Với L2TPv3, phiên có thể mang các khung Ethernet (Ethernet
pseudowire) hoặc các loại dữ liệu khác như PPP, ATM, HDLC hoặc Frame
Rơle. Linux hiện chỉ triển khai các loại phiên Ethernet và PPP.

Một số loại phiên L2TP cũng có ổ cắm (dây giả PPP) trong khi
những người khác thì không (dây giả Ethernet).

Giống như các đường hầm, các phiên L2TP được xác định bởi một
id phiên. Cũng giống như id đường hầm, id phiên là 16-bit cho
L2TPv2 và 32-bit cho L2TPv3. Bên trong, id được lưu trữ dưới dạng 32-bit
giá trị.

Các phiên tổ chức một lượt giới thiệu trên đường hầm chính của chúng để đảm bảo rằng đường hầm
vẫn tồn tại trong khi một hoặc nhiều phiên tham chiếu đến nó.

Các phiên được lưu giữ trong danh sách trên mỗi mạng. Phiên L2TPv2 và L2TPv3
phiên được lưu trữ trong danh sách riêng biệt. Phiên L2TPv2 được khóa
bằng khóa 32 bit được tạo thành từ ID đường hầm 16 bit và 16 bit
ID phiên. Phiên L2TPv3 được khóa bằng ID phiên 32 bit, vì
Id phiên L2TPv3 là duy nhất trên tất cả các đường hầm.

Mặc dù L2TPv3 RFC chỉ định rằng id phiên L2TPv3 không
trong phạm vi đường hầm, việc triển khai Linux có lịch sử
cho phép điều này. Xung đột id phiên như vậy được hỗ trợ bằng cách sử dụng per-net
bảng băm được khóa bởi sk và ID phiên. Khi tra cứu L2TPv3
phiên, mục danh sách có thể liên kết đến nhiều phiên với phiên đó
ID phiên, trong trường hợp đó phiên khớp với sk (đường hầm) nhất định
được sử dụng.

PPP
---

ZZ0000ZZ triển khai dòng ổ cắm PPPoL2TP. Mỗi PPP
phiên có ổ cắm PPPoL2TP.

Sk_user_data của ổ cắm PPPoL2TP tham chiếu l2tp_session.

Không gian người dùng gửi và nhận các gói PPP qua L2TP bằng PPPoL2TP
ổ cắm. Chỉ các khung điều khiển PPP mới đi qua ổ cắm này: dữ liệu PPP
các gói được xử lý hoàn toàn bởi kernel, chuyển giữa L2TP
phiên và netdev ZZ0000ZZ được liên kết của nó thông qua kênh PPP
giao diện của hệ thống con PPP kernel.

Việc triển khai L2TP PPP xử lý việc đóng ổ cắm PPPoL2TP
bằng cách đóng phiên L2TP tương ứng của nó. Việc này phức tạp vì
nó phải xem xét việc chạy đua với các yêu cầu tạo/hủy phiên netlink
và pppol2tp_connect đang cố gắng kết nối lại với một phiên trong
quá trình đóng cửa. Các phiên PPP tổ chức một lượt giới thiệu về các phiên được liên kết của chúng
socket để ổ cắm vẫn tồn tại trong khi phiên
tham khảo nó.

Ethernet
--------

ZZ0000ZZ triển khai dây giả Ethernet L2TPv3. Nó
quản lý một netdev cho mỗi phiên.

Phiên Ethernet L2TP được tạo và hủy bởi yêu cầu liên kết mạng,
hoặc bị phá hủy khi đường hầm bị phá hủy. Không giống như các phiên PPP,
Phiên Ethernet không có ổ cắm liên quan.

Linh tinh
=============

RFC
----

Mã hạt nhân thực hiện các tính năng đường dẫn dữ liệu được chỉ định trong
RFC sau:

======= ================ ========================================
RFC2661 L2TPv2 ZZ0000ZZ
RFC3931 L2TPv3 ZZ0001ZZ
RFC4719 L2TPv3 Ethernet ZZ0002ZZ
======= ================ ========================================

Triển khai
---------------

Một số ứng dụng nguồn mở sử dụng hệ thống con kernel L2TP:

===============================================================
iproute2 ZZ0000ZZ
go-l2tp ZZ0001ZZ
máy đào hầm ZZ0002ZZ
xl2tpd ZZ0003ZZ
===============================================================

Hạn chế
-----------

Việc triển khai hiện tại có một số hạn chế:

1) Giao diện với openvswitch chưa được triển khai. Nó có thể là
     hữu ích để ánh xạ các cổng Ethernet OVS và VLAN vào các đường hầm L2TPv3.

2) Dây giả VLAN được triển khai bằng giao diện ZZ0000ZZ
     được cấu hình với giao diện phụ VLAN. Kể từ L2TPv3 VLAN
     dây giả mang một và chỉ một VLAN, tốt hơn nên sử dụng
     một thiết bị mạng duy nhất chứ không phải ZZ0001ZZ và ZZ0002ZZ:M
     cặp mỗi phiên VLAN. Thuộc tính liên kết mạng
     ZZ0003ZZ đã được thêm vào cho việc này, nhưng nó chưa bao giờ
     được thực hiện.

Kiểm tra
-------

Các tính năng Ethernet L2TPv3 không được quản lý được kiểm tra bằng phần mềm tích hợp sẵn của kernel
tự kiểm tra. Xem ZZ0000ZZ.

Một bộ thử nghiệm khác, l2tp-ktest_, bao gồm tất cả
của API L2TP và các loại đường hầm/phiên. Điều này có thể được tích hợp vào
các bản tự kiểm tra L2TP tích hợp của hạt nhân trong tương lai.

.. Links
.. _Generic Netlink: generic_netlink.html
.. _libmnl: https://www.netfilter.org/projects/libmnl
.. _include/uapi/linux/l2tp.h: ../../../include/uapi/linux/l2tp.h
.. _include/linux/if_pppol2tp.h: ../../../include/linux/if_pppol2tp.h
.. _net/l2tp/l2tp_ip.c: ../../../net/l2tp/l2tp_ip.c
.. _net/l2tp/l2tp_ip6.c: ../../../net/l2tp/l2tp_ip6.c
.. _net/l2tp/l2tp_ppp.c: ../../../net/l2tp/l2tp_ppp.c
.. _net/l2tp/l2tp_eth.c: ../../../net/l2tp/l2tp_eth.c
.. _tools/testing/selftests/net/l2tp.sh: ../../../tools/testing/selftests/net/l2tp.sh
.. _l2tp-ktest: https://github.com/katalix/l2tp-ktest