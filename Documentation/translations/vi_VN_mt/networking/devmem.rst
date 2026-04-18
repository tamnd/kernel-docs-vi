.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/devmem.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Bộ nhớ thiết bị TCP
===================


giới thiệu
=====

Bộ nhớ thiết bị TCP (devmem TCP) cho phép nhận dữ liệu trực tiếp vào thiết bị
bộ nhớ (dmabuf). Tính năng này hiện được triển khai cho các ổ cắm TCP.


Cơ hội
-----------

Một số lượng lớn việc truyền dữ liệu có bộ nhớ thiết bị làm nguồn và/hoặc
điểm đến. Máy gia tốc làm tăng đáng kể sự phổ biến của những thứ như vậy
chuyển khoản.  Một số ví dụ bao gồm:

- Đào tạo phân tán, trong đó các bộ tăng tốc ML, chẳng hạn như GPU trên các máy chủ khác nhau,
  trao đổi dữ liệu.

- Các ứng dụng lưu trữ khối thô phân tán truyền lượng lớn dữ liệu với
  SSD từ xa. Phần lớn dữ liệu này không yêu cầu xử lý máy chủ.

Thông thường, việc truyền dữ liệu từ thiết bị này sang thiết bị khác trong mạng được thực hiện dưới dạng
các hoạt động cấp thấp sau: Sao chép từ thiết bị đến máy chủ, mạng từ máy chủ đến máy chủ
chuyển và sao chép từ máy chủ sang thiết bị.

Luồng liên quan đến các bản sao của máy chủ chưa tối ưu, đặc biệt đối với việc truyền dữ liệu số lượng lớn,
và có thể gây áp lực đáng kể lên tài nguyên hệ thống như bộ nhớ máy chủ
băng thông và băng thông PCIe.

Devmem TCP tối ưu hóa trường hợp sử dụng này bằng cách triển khai các API socket cho phép
người dùng nhận các gói mạng đến trực tiếp vào bộ nhớ thiết bị.

Tải trọng gói đi trực tiếp từ NIC tới bộ nhớ thiết bị.

Tiêu đề gói đi đến bộ nhớ máy chủ và được xử lý bởi ngăn xếp TCP/IP
bình thường. NIC phải hỗ trợ phân chia tiêu đề để đạt được điều này.

Thuận lợi:

- Giảm áp lực băng thông bộ nhớ máy chủ so với hiện tại
  ngữ nghĩa chuyển mạng + sao chép thiết bị.

- Giảm bớt áp lực băng thông PCIe, bằng cách hạn chế truyền dữ liệu ở mức thấp nhất
  cấp độ của cây PCIe, so với đường dẫn truyền thống gửi dữ liệu
  thông qua phức hợp gốc.


Thêm thông tin
---------

slide, video
    ZZ0000ZZ

bộ vá
    [PATCH net-next v24 00/13] Bộ nhớ thiết bị TCP
    ZZ0000ZZ


Giao diện RX
============


Ví dụ
-------

./tools/testing/selftests/drivers/net/hw/ncdevmem:do_server hiển thị một ví dụ về
thiết lập đường dẫn RX của API này.


Cài đặt NIC
---------

Phân chia tiêu đề, điều khiển luồng và RSS là những tính năng bắt buộc phải có đối với devmem TCP.

Phân chia tiêu đề được sử dụng để phân chia các gói đến thành bộ đệm tiêu đề trong máy chủ
bộ nhớ và bộ đệm tải trọng trong bộ nhớ thiết bị.

Điều khiển luồng & RSS được sử dụng để đảm bảo rằng chỉ các luồng nhắm mục tiêu vào vùng đất của nhà phát triển
một hàng đợi RX được liên kết với devmem.

Bật phân chia tiêu đề và điều khiển luồng::

Tách tiêu đề # enable
	ethtool -G eth1 tcp-data-split trên


Hệ thống lái dòng chảy # enable
	ethtool -K eth1 bật

Định cấu hình RSS để điều khiển tất cả lưu lượng truy cập khỏi hàng đợi RX mục tiêu (hàng đợi 15 trong
ví dụ này)::

ethtool --set-rxfh-indir eth1 bằng 15


Người dùng phải liên kết một dmabuf với bất kỳ số lượng hàng đợi RX nào trên NIC nhất định bằng cách sử dụng
liên kết mạng API::

/* Liên kết dmabuf với hàng đợi NIC RX 15 */
	cấu trúc netdev_queue * hàng đợi;
	hàng đợi = malloc(sizeof(ZZ0000ZZ 1);

hàng đợi [0]._hiện tại.type = 1;
	hàng đợi [0]._hiện tại.idx = 1;
	hàng đợi[0].type = NETDEV_RX_QUEUE_TYPE_RX;
	hàng đợi[0].idx = 15;

*ys = ynl_sock_create(&ynl_netdev_family, &yerr);

req = netdev_bind_rx_req_alloc();
	netdev_bind_rx_req_set_ifindex(req, 1 /* ifindex */);
	netdev_bind_rx_req_set_dmabuf_fd(req, dmabuf_fd);
	__netdev_bind_rx_req_set_queues(req, queues, n_queue_index);

rsp = netdev_bind_rx(*ys, req);

dmabuf_id = rsp->dmabuf_id;


Netlink API trả về dmabuf_id: một ID duy nhất đề cập đến dmabuf này
điều đó đã bị ràng buộc.

Người dùng có thể hủy liên kết dmabuf khỏi netdevice bằng cách đóng ổ cắm netlink
đã thiết lập sự ràng buộc. Chúng tôi làm điều này để liên kết được tự động
không bị ràng buộc ngay cả khi quá trình không gian người dùng gặp sự cố.

Lưu ý rằng mọi dmabuf hoạt động tốt từ bất kỳ nhà xuất khẩu nào đều phải hoạt động với
devmem TCP, ngay cả khi dmabuf không thực sự được hỗ trợ bởi devmem. Một ví dụ về
đây là udmabuf, bao bọc bộ nhớ người dùng (không phải devmem) trong dmabuf.


Thiết lập ổ cắm
------------

Ổ cắm phải được điều hướng theo luồng đến hàng đợi RX bị ràng buộc dmabuf ::

ethtool -N eth1 loại luồng tcp4 ... hàng đợi 15


Đang nhận dữ liệu
--------------

Ứng dụng người dùng phải báo hiệu cho kernel rằng nó có khả năng nhận
dữ liệu devmem bằng cách chuyển cờ MSG_SOCK_DEVMEM tới recvmsg::

ret = recvmsg(fd, &msg, MSG_SOCK_DEVMEM);

Các ứng dụng không chỉ định cờ MSG_SOCK_DEVMEM sẽ nhận được EFAULT
trên dữ liệu devmem.

Dữ liệu Devmem được nhận trực tiếp vào dmabuf được liên kết với NIC trong 'NIC
Setup' và kernel sẽ gửi tín hiệu như vậy tới người dùng thông qua cmsgs SCM_DEVMEM_*::

cho (cm = CMSG_FIRSTHDR(&msg); cm; cm = CMSG_NXTHDR(&msg, cm)) {
			nếu (cm->cmsg_level != SOL_SOCKET ||
				(cm->cmsg_type != SCM_DEVMEM_DMABUF &&
				 cm->cmsg_type != SCM_DEVMEM_LINEAR))
				tiếp tục;

dmabuf_cmsg = (struct dmabuf_cmsg *)CMSG_DATA(cm);

nếu (cm->cmsg_type == SCM_DEVMEM_DMABUF) {
				/* Frag đáp xuống dmabuf.
				 *
				 * dmabuf_cmsg->dmabuf_id là dmabuf
				 * mảnh vỡ đáp xuống.
				 *
				 * dmabuf_cmsg->frag_offset là phần bù vào
				 * dmabuf nơi đoạn bắt đầu.
				 *
				 * dmabuf_cmsg->frag_size là kích thước của
				 * mảnh.
				 *
				 * dmabuf_cmsg->frag_token là token dùng để
				 * tham khảo đoạn này để giải phóng sau này.
				 */

cấu trúc mã thông báo dmabuf_token;
				token.token_start = dmabuf_cmsg->frag_token;
				token.token_count = 1;
				Tiếp tục;
			}

nếu (cm->cmsg_type == SCM_DEVMEM_LINEAR)
				/* Frag đã rơi vào vùng đệm tuyến tính.
				 *
				 * dmabuf_cmsg->frag_size là kích thước của
				 * mảnh.
				 */
				Tiếp tục;

		}

Ứng dụng có thể nhận được 2 cmsgs:

- SCM_DEVMEM_DMABUF: điều này cho biết mảnh đã rơi vào dmabuf được chỉ định
  bởi dmabuf_id.

- SCM_DEVMEM_LINEAR: điều này cho biết đoạn đã được đưa vào bộ đệm tuyến tính.
  Điều này thường xảy ra khi NIC không thể chia gói tại
  ranh giới tiêu đề, sao cho một phần (hoặc tất cả) tải trọng được đưa vào máy chủ
  trí nhớ.

Các ứng dụng có thể không nhận được cmsg SO_DEVMEM_*. Điều đó cho thấy không phải devmem,
dữ liệu TCP thông thường nằm trên hàng đợi RX không bị ràng buộc với dmabuf.


Giải phóng mảnh vỡ
-------------

Các mảnh nhận được qua SCM_DEVMEM_DMABUF được hạt nhân ghim trong khi người dùng
xử lý mảnh. Người dùng phải trả lại frag cho kernel thông qua
SO_DEVMEM_DONTNEED::

ret = setsockopt(client_fd, SOL_SOCKET, SO_DEVMEM_DONTNEED, &mã thông báo,
			 sizeof(mã thông báo));

Người dùng phải đảm bảo mã thông báo được trả lại kernel kịp thời.
Không làm như vậy sẽ làm cạn kiệt dmabuf giới hạn được liên kết với hàng đợi RX
và sẽ dẫn đến rớt gói tin.

Người dùng phải chuyển không quá 128 mã thông báo, với tổng số không quá 1024 phân đoạn
trong số token->token_count trên tất cả các mã thông báo. Nếu người dùng cung cấp thêm
hơn 1024 frag, kernel sẽ giải phóng tới 1024 frag và quay về sớm.

Hạt nhân trả về số lượng mảnh thực tế được giải phóng. Số mảnh được giải phóng
có thể ít hơn số token do người dùng cung cấp trong trường hợp:

(a) lỗi rò rỉ kernel nội bộ.
(b) người dùng đã vượt qua hơn 1024 phân đoạn.

Giao diện TX
============


Ví dụ
-------

./tools/testing/selftests/drivers/net/hw/ncdevmem:do_client hiển thị một ví dụ về
thiết lập đường dẫn TX của API này.


Cài đặt NIC
---------

Người dùng phải liên kết TX dmabuf với NIC nhất định bằng cách sử dụng netlink API::

struct netdev_bind_tx_req *req = NULL;
        struct netdev_bind_tx_rsp *rsp = NULL;
        struct ynl_error yerr;

*ys = ynl_sock_create(&ynl_netdev_family, &yerr);

req = netdev_bind_tx_req_alloc();
        netdev_bind_tx_req_set_ifindex(req, ifindex);
        netdev_bind_tx_req_set_fd(req, dmabuf_fd);

rsp = netdev_bind_tx(*ys, req);

tx_dmabuf_id = rsp->id;


Netlink API trả về dmabuf_id: một ID duy nhất đề cập đến dmabuf này
điều đó đã bị ràng buộc.

Người dùng có thể hủy liên kết dmabuf khỏi netdevice bằng cách đóng ổ cắm netlink
đã thiết lập sự ràng buộc. Chúng tôi làm điều này để liên kết được tự động
không bị ràng buộc ngay cả khi quá trình không gian người dùng gặp sự cố.

Lưu ý rằng mọi dmabuf hoạt động tốt từ bất kỳ nhà xuất khẩu nào đều phải hoạt động với
devmem TCP, ngay cả khi dmabuf không thực sự được hỗ trợ bởi devmem. Một ví dụ về
đây là udmabuf, bao bọc bộ nhớ người dùng (không phải devmem) trong dmabuf.

Thiết lập ổ cắm
------------

Ứng dụng người dùng phải sử dụng cờ MSG_ZEROCOPY khi gửi devmem TCP. Devmem
kernel không thể sao chép được, vì vậy ngữ nghĩa của devmem TX tương tự nhau
theo ngữ nghĩa của MSG_ZEROCOPY::

setsockopt(socket_fd, SOL_SOCKET, SO_ZEROCOPY, &opt, sizeof(opt));

Người dùng cũng nên liên kết ổ cắm TX với cùng một giao diện
dma-buf đã được liên kết thông qua SO_BINDTODEVICE::

setsockopt(socket_fd, SOL_SOCKET, SO_BINDTODEVICE, ifname, strlen(ifname) + 1);


Gửi dữ liệu
------------

Dữ liệu Devmem được gửi bằng cmsg SCM_DEVMEM_DMABUF.

Người dùng nên tạo một msghdr trong đó,

* iov_base được đặt thành offset trong dmabuf để bắt đầu gửi từ
* iov_len được đặt thành số byte được gửi từ dmabuf

Người dùng chuyển id dma-buf để gửi từ dmabuf_tx_cmsg.dmabuf_id.

Ví dụ bên dưới gửi 1024 byte từ offset 100 vào dmabuf và 2048
từ offset 2000 vào dmabuf. Dmabuf để gửi từ đó là tx_dmabuf_id::

char ctrl_data[CMSG_SPACE(sizeof(struct dmabuf_tx_cmsg))];
       cấu trúc dmabuf_tx_cmsg ddmabuf;
       tin nhắn cấu trúc tin nhắn = {};
       struct cmsghdr *cmsg;
       struct iovec iov[2];

iov[0].iov_base = (void*)100;
       iov[0].iov_len = 1024;
       iov[1].iov_base = (void*)2000;
       iov[1].iov_len = 2048;

msg.msg_iov = iov;
       tin nhắn.msg_iovlen = 2;

tin nhắn.msg_control = ctrl_data;
       msg.msg_controllen = sizeof(ctrl_data);

cmsg = CMSG_FIRSTHDR(&msg);
       cmsg->cmsg_level = SOL_SOCKET;
       cmsg->cmsg_type = SCM_DEVMEM_DMABUF;
       cmsg->cmsg_len = CMSG_LEN(sizeof(struct dmabuf_tx_cmsg));

ddmabuf.dmabuf_id = tx_dmabuf_id;

ZZ0000ZZ)CMSG_DATA(cmsg)) = ddmabuf;

sendmsg(socket_fd, &msg, MSG_ZEROCOPY);


Tái sử dụng dmabuf TX
------------------

Tương tự như MSG_ZEROCOPY với bộ nhớ thông thường, người dùng không nên sửa đổi
nội dung của dma-buf trong khi thao tác gửi đang được tiến hành. Điều này là do
kernel không giữ bản sao nội dung dmabuf. Thay vào đó, hạt nhân
sẽ ghim và gửi dữ liệu từ bộ đệm có sẵn đến không gian người dùng.

Giống như trong MSG_ZEROCOPY, kernel thông báo cho không gian người dùng về việc hoàn tất gửi
sử dụng MSG_ERRQUEUE::

int64_t tstop = gettimeofday_ms() + waittime_ms;
        điều khiển char[CMSG_SPACE(100)] = {};
        struct sock_extends_err *serr;
        tin nhắn cấu trúc tin nhắn = {};
        cấu trúc cmsghdr *cm;
        int thử lại = 10;
        __u32 xin chào, chào;

msg.msg_control = điều khiển;
        msg.msg_controllen = sizeof(điều khiển);

trong khi (gettimeofday_ms() < tstop) {
                if (!do_poll(fd)) tiếp tục;

ret = recvmsg(fd, &msg, MSG_ERRQUEUE);

cho (cm = CMSG_FIRSTHDR(&msg); cm; cm = CMSG_NXTHDR(&msg, cm)) {
                        serr = (void *)CMSG_DATA(cm);

chào = serr->ee_data;
                        lo = serr->ee_info;

fprintf(stdout, "tx Complete [%d,%d]\n", lo, hi);
                }
        }

Sau khi gửi tin nhắn liên quan đã được hoàn thành, dmabuf có thể được sử dụng lại bởi
không gian người dùng.


Thực hiện & Hãy cẩn thận
========================

skbs không thể đọc được
---------------

Tải trọng Devmem không thể truy cập được để hạt nhân xử lý các gói. Cái này
dẫn đến một số vấn đề về tải trọng của devmem skbs:

- Loopback không hoạt động. Loopback dựa vào việc sao chép tải trọng, đó là
  không thể thực hiện được với devmem skbs.

- Phần mềm tính toán tổng kiểm tra không thành công.

- TCP Dump và bpf không thể truy cập tải trọng gói devmem.


Kiểm tra
=======

Mã ví dụ thực tế hơn có thể được tìm thấy trong nguồn kernel bên dưới
ZZ0000ZZ

ncdevmem là một netcat devmem TCP. Nó hoạt động rất giống với netcat, nhưng
nhận dữ liệu trực tiếp vào udmabuf.

Để chạy ncdevmem, bạn cần chạy nó trên máy chủ trên máy đang được kiểm tra và
bạn cần chạy netcat trên thiết bị ngang hàng để cung cấp dữ liệu TX.

ncdevmem cũng có một chế độ xác thực dự kiến sẽ có một mẫu lặp lại
dữ liệu đến và xác nhận nó như vậy. Ví dụ: bạn có thể khởi chạy
ncdevmem trên máy chủ bởi::

ncdevmem -s <IP máy chủ> -c <IP máy khách> -f <ifname> -l -p 5201 -v 7

Về phía khách hàng, sử dụng netcat thông thường để gửi dữ liệu TX tới quy trình ncdevmem
trên máy chủ::

có $(echo -e \\x01\\x02\\x03\\x04\\x05\\x06) | \
		tr \\n \\0 ZZ0000ZZ nc <IP máy chủ> 5201 -p 5201