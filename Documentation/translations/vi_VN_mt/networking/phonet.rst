.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/phonet.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===============================
Họ giao thức Linux Phonet
===============================

Giới thiệu
------------

Phonet là giao thức gói được sử dụng bởi modem di động Nokia cho cả IPC
và RPC. Với họ socket Linux Phonet, các tiến trình máy chủ Linux có thể
nhận và gửi tin nhắn từ/đến modem hoặc bất kỳ thiết bị bên ngoài nào khác
thiết bị gắn vào modem. Modem đảm nhiệm việc định tuyến.

Các gói ngữ âm có thể được trao đổi thông qua các kết nối phần cứng khác nhau
tùy thuộc vào thiết bị, chẳng hạn như:

- USB với giao diện CDC Phonet,
  - hồng ngoại,
  -Bluetooth,
  - một cổng nối tiếp RS232 (với kỷ luật dòng "FBUS" chuyên dụng),
  - bus SSI với một số bộ xử lý TI OMAP.


Định dạng gói
--------------

Các gói ngữ âm có tiêu đề chung như sau::

cấu trúc phonethdr {
    uint8_t pn_media;  /* Loại phương tiện (mã định danh lớp liên kết) */
    uint8_t pn_rdev;   /*ID thiết bị nhận */
    uint8_t pn_sdev;   /* ID thiết bị người gửi */
    uint8_t pn_res;    /* ID tài nguyên hoặc hàm */
    uint16_t pn_length; /* Độ dài byte thông báo cuối lớn (trừ 6) */
    uint8_t pn_robj;   /* ID đối tượng nhận */
    uint8_t pn_sobj;   /* ID đối tượng người gửi */
  };

Trên Linux, tiêu đề lớp liên kết bao gồm byte pn_media (xem bên dưới).
7 byte tiếp theo là một phần của tiêu đề lớp mạng.

ID thiết bị được phân chia: 6 bit bậc cao hơn tạo thành thiết bị
địa chỉ, trong khi 2 bit thứ tự thấp hơn được sử dụng để ghép kênh, cũng như
mã định danh đối tượng 8 bit. Như vậy, Phonet có thể được coi là một
Lớp mạng có 6 bit không gian địa chỉ và 10 bit để truyền tải
giao thức (giống như số cổng trong thế giới IP).

Modem luôn có số địa chỉ bằng 0. Tất cả các thiết bị khác đều có
địa chỉ 6 bit của riêng mình.


Lớp liên kết
----------

Liên kết ngữ âm luôn là liên kết điểm-điểm. Tiêu đề lớp liên kết
bao gồm một byte loại phương tiện Phonet. Nó xác định duy nhất các
liên kết mà gói tin được truyền qua đó, từ modem
quan điểm. Mỗi thiết bị mạng Phonet sẽ thêm vào và thiết lập phương tiện
gõ byte cho phù hợp. Để thuận tiện, một phonet_header_ops chung
Cấu trúc hoạt động tiêu đề lớp liên kết được cung cấp. Nó thiết lập
loại phương tiện theo địa chỉ phần cứng của thiết bị mạng.

Giao diện mạng Linux Phonet hỗ trợ các gói lớp liên kết chuyên dụng
loại (ETH_P_PHONET) nằm ngoài phạm vi loại Ethernet. Họ có thể
chỉ gửi và nhận các gói Phonet.

Trình điều khiển thiết bị đường hầm ảo TUN cũng có thể được sử dụng cho Phonet. Cái này
yêu cầu chế độ IFF_TUN, _không có_ cờ IFF_NO_PI. Trong trường hợp này,
không có tiêu đề lớp liên kết, do đó không có byte kiểu phương tiện Phonet.

Lưu ý rằng giao diện Phonet không được phép sắp xếp lại các gói tin, vì vậy
chỉ nên sử dụng qdisc Linux FIFO (mặc định) với chúng.


Lớp mạng
-------------

Họ địa chỉ ổ cắm Phonet ánh xạ tiêu đề gói Phonet::

cấu trúc sockaddr_pn {
    sa_family_t spn_family;    /* AF_PHONET */
    uint8_t spn_obj;       /*ID đối tượng */
    uint8_t spn_dev;       /*ID thiết bị */
    uint8_t spn_resource;  /* Tài nguyên hoặc hàm */
    uint8_t spn_zero[...]; /* Đệm */
  };

Trường tài nguyên chỉ được sử dụng khi gửi và nhận;
Nó bị bỏ qua bởi bind() và getsockname().


Giao thức datagram cấp thấp
---------------------------

Các ứng dụng có thể gửi tin nhắn Phonet bằng ổ cắm gói dữ liệu Phonet
giao thức từ họ PF_PHONET. Mỗi socket được liên kết với một trong các
Có sẵn 2^10 ID đối tượng và có thể gửi và nhận gói bằng bất kỳ
ngang hàng khác.

::

struct sockaddr_pn addr = { .spn_family = AF_PHONET, };
  size_t len;
  socklen_t addrlen = sizeof(addr);
  int fd;

fd = ổ cắm(PF_PHONET, SOCK_DGRAM, 0);
  bind(fd, (struct sockaddr *)&addr, sizeof(addr));
  /* ... */

sendto(fd, msg, msglen, 0, (struct sockaddr *)&addr, sizeof(addr));
  len = recvfrom(fd, buf, sizeof(buf), 0,
		 (struct sockaddr *)&addr, &addrlen);

Giao thức này tuân theo ngữ nghĩa không có kết nối SOCK_DGRAM.
Tuy nhiên, connect() và getpeername() không được hỗ trợ như trước đây
có vẻ không hữu ích với cách sử dụng Phonet (có thể được thêm vào dễ dàng).


Đăng ký tài nguyên
---------------------

Ổ cắm gói dữ liệu Phonet có thể được đăng ký với bất kỳ số lượng 8 bit nào
Tài nguyên ngữ âm, như sau::

uint32_t res = 0xXX;
  ioctl(fd, SIOCPNADDRESOURCE, &res);

Đăng ký cũng bị hủy tương tự khi sử dụng I/O SIOCPNDELRESOURCE
yêu cầu điều khiển hoặc khi ổ cắm được đóng lại.

Lưu ý rằng không thể đăng ký nhiều hơn một ổ cắm vào bất kỳ ổ cắm nào
tài nguyên tại một thời điểm. Nếu không, ioctl() sẽ trả về EBUSY.


Giao thức ống Phonet
--------------------

Giao thức Phonet Pipe là một giao thức gói tuần tự đơn giản
với việc kiểm soát tắc nghẽn từ đầu đến cuối. Nó sử dụng cách nghe thụ động
mô hình ổ cắm. Ổ cắm nghe được liên kết với một đối tượng miễn phí duy nhất
ID. Mỗi ổ cắm nghe có thể xử lý đồng thời tới 255
các kết nối, một kết nối cho mỗi ổ cắm chấp nhận().

::

int lfd, cfd;

lfd = ổ cắm(PF_PHONET, SOCK_SEQPACKET, PN_PROTO_PIPE);
  lắng nghe (lfd, INT_MAX);

/* ... */
  cfd = chấp nhận(lfd, NULL, NULL);
  cho (;;)
  {
    char buf[...];
    ssize_t len ​​= read(cfd, buf, sizeof(buf));

    /* ... */

write(cfd, msg, msglen);
  }

Các kết nối được thiết lập theo truyền thống giữa hai điểm cuối bởi một
ứng dụng của "bên thứ ba". Điều này có nghĩa là cả hai điểm cuối đều thụ động.


Kể từ phiên bản nhân Linux 2.6.39, cũng có thể kết nối
hai điểm cuối trực tiếp, sử dụng connect() ở phía hoạt động. Đây là
nhằm hỗ trợ Modem không dây Nokia API mới hơn, như được tìm thấy trong
ví dụ: Modem Nokia Slim trên nền tảng ST-Ericsson U8500::

struct sockaddr_spn spn;
  int fd;

fd = ổ cắm(PF_PHONET, SOCK_SEQPACKET, PN_PROTO_PIPE);
  bộ nhớ(&spn, 0, sizeof(spn));
  spn.spn_family = AF_PHONET;
  spn.spn_obj = ...;
  spn.spn_dev = ...;
  spn.spn_resource = 0xD9;
  connect(fd, (struct sockaddr *)&spn, sizeof(spn));
  /* I/O bình thường ở đây ... */
  đóng(fd);


.. Warning:

   When polling a connected pipe socket for writability, there is an
   intrinsic race condition whereby writability might be lost between the
   polling and the writing system calls. In this case, the socket will
   block until write becomes possible again, unless non-blocking mode
   is enabled.


Giao thức đường ống cung cấp hai tùy chọn ổ cắm ở cấp SOL_PNPIPE:

PNPIPE_ENCAP chấp nhận một giá trị nguyên (int) của:

PNPIPE_ENCAP_NONE:
      Ổ cắm hoạt động bình thường (mặc định).

PNPIPE_ENCAP_IP:
      Ổ cắm được sử dụng làm phụ trợ cho IP ảo
      giao diện. Điều này đòi hỏi khả năng CAP_NET_ADMIN. Dữ liệu GPRS
      hỗ trợ trên modem Nokia có thể sử dụng điều này. Lưu ý rằng ổ cắm không thể
      có thể được thăm dò()'d hoặc read() một cách đáng tin cậy khi ở chế độ này.

PNPIPE_IFINDEX
      là một giá trị số nguyên chỉ đọc. Nó chứa
      chỉ mục giao diện của giao diện mạng được tạo bởi PNPIPE_ENCAP,
      hoặc 0 nếu tính năng đóng gói bị tắt.

PNPIPE_HANDLE
      là một giá trị số nguyên chỉ đọc. Nó chứa nội dung cơ bản
      mã định danh ("tay cầm ống") của đường ống. Điều này chỉ được xác định cho
      mô tả ổ cắm đã được kết nối hoặc đang được kết nối.


tác giả
-------

Linux Phonet ban đầu được viết bởi Sakari Ailus.

Những người đóng góp khác bao gồm Mikä Liljeberg, Andras Domokos,
Carlos Chinea và Rémi Denis-Courmont.

Bản quyền ZZ0000ZZ 2008 Tập đoàn Nokia.