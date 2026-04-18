.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/can.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
SocketCAN - Mạng khu vực điều khiển
======================================

Tổng quan/SocketCAN là gì
============================

Gói socketcan là một triển khai của các giao thức CAN
(Mạng khu vực điều khiển) cho Linux.  CAN là một công nghệ mạng
được sử dụng rộng rãi trong tự động hóa, thiết bị nhúng và
lĩnh vực ô tô.  Mặc dù đã có các triển khai CAN khác
đối với Linux dựa trên các thiết bị ký tự, SocketCAN sử dụng Berkeley
socket API, ngăn xếp mạng Linux và triển khai thiết bị CAN
trình điều khiển như giao diện mạng.  Ổ cắm CAN API đã được thiết kế
tương tự nhất có thể với các giao thức TCP/IP để cho phép các lập trình viên,
làm quen với lập trình mạng, để dễ dàng học cách sử dụng CAN
ổ cắm.


.. _socketcan-motivation:

Động lực / Tại sao nên sử dụng Ổ cắm API
========================================

Đã có các triển khai CAN cho Linux trước SocketCAN nên
câu hỏi đặt ra là tại sao chúng tôi lại bắt đầu một dự án khác.  Hiện có nhất
việc triển khai dưới dạng trình điều khiển thiết bị cho một số phần cứng CAN, chúng
dựa trên các thiết bị nhân vật và cung cấp tương đối ít
chức năng.  Thông thường, chỉ có một thiết bị dành riêng cho phần cứng
trình điều khiển cung cấp giao diện thiết bị ký tự để gửi và
nhận các khung CAN thô, trực tiếp đến/từ phần cứng bộ điều khiển.
Xếp hàng các khung và các giao thức truyền tải cấp cao hơn như ISO-TP
phải được thực hiện trong các ứng dụng không gian người dùng.  Ngoài ra, hầu hết
Việc triển khai thiết bị ký tự chỉ hỗ trợ một quy trình duy nhất để
mở thiết bị cùng một lúc, tương tự như giao diện nối tiếp.  trao đổi
bộ điều khiển CAN yêu cầu sử dụng trình điều khiển thiết bị khác và
thường là nhu cầu thích ứng của phần lớn ứng dụng với
trình điều khiển mới API.

SocketCAN được thiết kế để khắc phục tất cả những hạn chế này.  Một cái mới
họ giao thức đã được triển khai để cung cấp giao diện ổ cắm
tới các ứng dụng không gian người dùng và được xây dựng trên mạng Linux
lớp, cho phép sử dụng tất cả các chức năng xếp hàng được cung cấp.  Một thiết bị
trình điều khiển cho phần cứng bộ điều khiển CAN tự đăng ký với Linux
lớp mạng như một thiết bị mạng, để CAN đóng khung từ
bộ điều khiển có thể được chuyển lên lớp mạng và tới CAN
mô-đun gia đình giao thức và ngược lại.  Ngoài ra, họ giao thức
mô-đun cung cấp API để các mô-đun giao thức truyền tải đăng ký, vì vậy
rằng bất kỳ số lượng giao thức truyền tải nào cũng có thể được tải hoặc dỡ tải
một cách năng động.  Trên thực tế, chỉ riêng mô-đun lõi can không cung cấp bất kỳ
giao thức và không thể sử dụng được nếu không tải thêm ít nhất một giao thức
mô-đun giao thức.  Có thể mở nhiều ổ cắm cùng lúc
trên cùng một mô-đun giao thức khác nhau và họ có thể nghe/gửi
các khung trên các ID CAN khác nhau hoặc giống nhau.  Một số ổ cắm đang nghe
cùng một giao diện cho các khung có cùng ID CAN đều được chuyển qua
nhận được các khung CAN phù hợp tương tự.  Một ứng dụng mong muốn
giao tiếp bằng cách sử dụng một giao thức truyền tải cụ thể, ví dụ: ISO-TP, chỉ
chọn giao thức đó khi mở ổ cắm và sau đó có thể đọc và
ghi các luồng byte dữ liệu ứng dụng mà không cần phải xử lý
CAN-ID, khung, v.v.

Chức năng tương tự hiển thị từ không gian người dùng có thể được cung cấp bởi
thiết bị ký tự cũng vậy, nhưng điều này sẽ dẫn đến một sự thiếu phù hợp về mặt kỹ thuật
giải pháp vì một số lý do:

* ZZ0000ZZ Thay vì chuyển đối số giao thức tới
  socket(2) và sử dụng bind(2) để chọn giao diện CAN và ID CAN, một
  ứng dụng sẽ phải thực hiện tất cả các thao tác này bằng ioctl(2)s.

* ZZ0000ZZ Một thiết bị ký tự không thể sử dụng Linux
  mã xếp hàng mạng, vì vậy tất cả mã đó sẽ phải được sao chép
  cho mạng CAN.

* ZZ0000ZZ Trong hầu hết các triển khai thiết bị ký tự hiện có,
  trực tiếp trình điều khiển thiết bị dành riêng cho phần cứng cho bộ điều khiển CAN
  cung cấp thiết bị ký tự để ứng dụng hoạt động.
  Điều này ít nhất là rất bất thường trong các hệ thống Unix cho cả char và
  chặn các thiết bị.  Ví dụ: bạn không có thiết bị ký tự cho
  một số UART nhất định của giao diện nối tiếp, một chip âm thanh nhất định trong
  máy tính, bộ điều khiển SCSI hoặc IDE cung cấp quyền truy cập vào phần cứng của bạn
  thiết bị truyền phát đĩa hoặc băng.  Thay vào đó, bạn có các lớp trừu tượng
  cung cấp một ký tự thống nhất hoặc giao diện thiết bị khối cho
  một mặt là ứng dụng và một giao diện dành riêng cho phần cứng
  mặt khác trình điều khiển thiết bị.  Những sự trừu tượng này được cung cấp
  bởi các hệ thống con như lớp tty, hệ thống con âm thanh hoặc SCSI
  và các hệ thống con IDE cho các thiết bị được đề cập ở trên.

Cách dễ nhất để triển khai trình điều khiển thiết bị CAN là dưới dạng ký tự
  thiết bị không có lớp trừu tượng (hoàn chỉnh) như vậy, như được thực hiện bởi hầu hết
  trình điều khiển hiện có.  Tuy nhiên, cách đúng đắn là thêm một
  lớp với tất cả các chức năng như đăng ký CAN nhất định
  ID, hỗ trợ một số bộ mô tả tệp đang mở và ghép kênh (de)
  Các khung CAN giữa chúng, các khung CAN xếp hàng (tinh vi) và
  cung cấp API để đăng ký trình điều khiển thiết bị.  Tuy nhiên, sau đó
  sẽ không còn khó khăn nữa hoặc thậm chí còn dễ dàng hơn khi sử dụng
  khung mạng được cung cấp bởi nhân Linux và đây là những gì
  Ổ cắmCAN có.

Việc sử dụng khung mạng của nhân Linux chỉ là
cách tự nhiên và thích hợp nhất để triển khai CAN cho Linux.


.. _socketcan-concept:

Khái niệm socketCAN
===================

Như được mô tả trong ZZ0000ZZ, mục tiêu chính của SocketCAN là
cung cấp giao diện ổ cắm cho các ứng dụng không gian người dùng xây dựng
trên lớp mạng Linux. Ngược lại với những gì thường được biết đến
Mạng TCP/IP và ethernet, bus CAN là một mạng chỉ phát sóng (!)
phương tiện không có địa chỉ lớp MAC như ethernet. Mã định danh CAN
(can_id) được sử dụng để phân xử trên bus CAN. Do đó, CAN-ID
phải được chọn duy nhất trên xe buýt. Khi thiết kế CAN-ECU
mạng CAN-ID được ánh xạ để gửi bởi một ECU cụ thể.
Vì lý do này, CAN-ID có thể được coi là tốt nhất như một loại địa chỉ nguồn.


.. _socketcan-receive-lists:

Nhận danh sách
--------------

Việc truy cập trong suốt mạng của nhiều ứng dụng dẫn đến
vấn đề mà các ứng dụng khác nhau có thể quan tâm đến cùng
CAN-ID từ cùng giao diện mạng CAN. Lõi SocketCAN
mô-đun - triển khai họ giao thức CAN - cung cấp một số
danh sách nhận hiệu quả cao vì lý do này. Nếu ví dụ: không gian người dùng
ứng dụng mở ổ cắm CAN RAW, chính mô-đun giao thức thô
yêu cầu (phạm vi) CAN-ID từ lõi SocketCAN
được yêu cầu bởi người dùng. Việc đăng ký và hủy đăng ký của
CAN-ID có thể được thực hiện cho các giao diện CAN cụ thể hoặc cho tất cả (!) Đã biết
CAN giao tiếp với các hàm can_rx_(un)register() được cung cấp cho
Các mô-đun giao thức CAN bằng lõi SocketCAN (xem ZZ0000ZZ).
Để tối ưu hóa việc sử dụng CPU trong thời gian chạy, danh sách nhận được chia nhỏ
vào một số danh sách cụ thể cho mỗi thiết bị phù hợp với yêu cầu
độ phức tạp của bộ lọc cho một trường hợp sử dụng nhất định.


.. _socketcan-local-loopback1:

Vòng lặp cục bộ của các khung đã gửi
------------------------------------

Như đã biết từ các khái niệm mạng khác, việc trao đổi dữ liệu
các ứng dụng có thể chạy trên cùng một nút hoặc các nút khác nhau mà không cần bất kỳ
thay đổi (ngoại trừ thông tin địa chỉ theo):

.. code::

	 ___   ___   ___                   _______   ___
	| _ | | _ | | _ |                 | _   _ | | _ |
	||A|| ||B|| ||C||                 ||A| |B|| ||C||
	|___| |___| |___|                 |_______| |___|
	  |     |     |                       |       |
	-----------------(1)- CAN bus -(2)---------------

Để đảm bảo rằng ứng dụng A nhận được thông tin tương tự trong
ví dụ (2) như nó sẽ nhận được trong ví dụ (1) cần có
một số loại vòng lặp cục bộ của các khung CAN đã gửi trên thiết bị thích hợp
nút.

Các thiết bị mạng Linux (theo mặc định) chỉ có thể xử lý
truyền và nhận các khung phụ thuộc vào phương tiện truyền thông. Do
trọng tài trên bus CAN truyền tải CAN-ID ưu tiên thấp
có thể bị trì hoãn do việc tiếp nhận khung CAN có độ ưu tiên cao. Đến
phản ánh lưu lượng [#f1]_ chính xác trên nút vòng lặp của dữ liệu đã gửi
dữ liệu phải được thực hiện ngay sau khi truyền thành công. Nếu
giao diện mạng CAN không có khả năng thực hiện vòng lặp cho
một số lý do khiến lõi SocketCAN có thể thực hiện nhiệm vụ này như một giải pháp dự phòng.
Xem ZZ0000ZZ để biết chi tiết (được khuyến nghị).

Chức năng loopback được bật theo mặc định để phản ánh tiêu chuẩn
hành vi kết nối mạng cho các ứng dụng CAN. Do một số yêu cầu từ
nhóm RT-SocketCAN, vòng lặp tùy chọn có thể bị vô hiệu hóa cho mỗi nhóm
ổ cắm riêng. Xem các ổ cắm từ ổ cắm CAN RAW trong ZZ0000ZZ.

.. [#f1] you really like to have this when you're running analyser
       tools like 'candump' or 'cansniffer' on the (same) node.


.. _socketcan-network-problem-notifications:

Thông báo sự cố mạng
-----------------------------

Việc sử dụng bus CAN có thể dẫn đến một số vấn đề về mặt vật lý
và lớp kiểm soát truy cập phương tiện truyền thông. Phát hiện và ghi lại những mức thấp hơn
các vấn đề về lớp là một yêu cầu quan trọng để người dùng CAN xác định
các vấn đề về phần cứng trên lớp thu phát vật lý cũng như
vấn đề trọng tài và khung lỗi gây ra bởi sự khác nhau
ECU. Sự xuất hiện của các lỗi được phát hiện rất quan trọng cho việc chẩn đoán
và phải được ghi lại cùng với dấu thời gian chính xác. Vì điều này
lý do trình điều khiển giao diện CAN có thể tạo ra cái gọi là Thông báo Lỗi
Các khung có thể được chuyển tùy ý tới ứng dụng người dùng trong
tương tự như các khung CAN khác. Bất cứ khi nào có lỗi trên lớp vật lý
hoặc lớp MAC được phát hiện (ví dụ: bởi bộ điều khiển CAN) trình điều khiển
tạo khung thông báo lỗi thích hợp. Khung thông báo lỗi có thể
được yêu cầu bởi ứng dụng người dùng bằng bộ lọc CAN chung
cơ chế. Bên trong định nghĩa bộ lọc này, loại (quan tâm) của
lỗi có thể được chọn. Việc tiếp nhận thông báo lỗi bị vô hiệu hóa
theo mặc định. Định dạng của khung thông báo lỗi CAN ngắn gọn
được mô tả trong tệp tiêu đề Linux "include/uapi/linux/can/error.h".


Cách sử dụng SocketCAN
======================

Giống như TCP/IP, trước tiên bạn cần mở một ổ cắm để liên lạc qua mạng
Mạng CAN. Vì SocketCAN triển khai một họ giao thức mới nên bạn
cần chuyển PF_CAN làm đối số đầu tiên cho hệ thống socket(2)
gọi. Hiện tại, có hai giao thức CAN để lựa chọn, giao thức thô
giao thức ổ cắm và trình quản lý phát sóng (BCM). Vì vậy, để mở một ổ cắm,
bạn sẽ viết::

s = ổ cắm (PF_CAN, SOCK_RAW, CAN_RAW);

Và::

s = ổ cắm (PF_CAN, SOCK_DGRAM, CAN_BCM);

tương ứng.  Sau khi tạo thành công socket, bạn sẽ
thường sử dụng lệnh gọi hệ thống bind(2) để liên kết ổ cắm với CAN
giao diện (khác với TCP/IP do địa chỉ khác nhau
- xem ZZ0000ZZ). Sau khi liên kết (CAN_RAW) hoặc kết nối (CAN_BCM)
ổ cắm, bạn có thể đọc (2) và ghi (2) từ/vào ổ cắm hoặc sử dụng
send(2), sendto(2), sendmsg(2) và các hoạt động tương ứng recv*
trên ổ cắm như bình thường. Ngoài ra còn có các tùy chọn ổ cắm cụ thể CAN
được mô tả dưới đây.

Cấu trúc khung CAN cổ điển (còn gọi là CAN 2.0B), cấu trúc khung CAN FD
và cấu trúc sockaddr được định nghĩa trong include/linux/can.h:

.. code-block:: C

    struct can_frame {
            canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
            union {
                    /* CAN frame payload length in byte (0 .. CAN_MAX_DLEN)
                     * was previously named can_dlc so we need to carry that
                     * name for legacy support
                     */
                    __u8 len;
                    __u8 can_dlc; /* deprecated */
            };
            __u8    __pad;   /* padding */
            __u8    __res0;  /* reserved / padding */
            __u8    len8_dlc; /* optional DLC for 8 byte payload length (9 .. 15) */
            __u8    data[8] __attribute__((aligned(8)));
    };

Lưu ý: Phần tử len chứa độ dài tải trọng tính bằng byte và phải
được sử dụng thay vì can_dlc. can_dlc không được dùng nữa đã được đặt tên sai là
nó luôn chứa độ dài tải trọng đơn giản tính bằng byte chứ không phải cái gọi là
'mã độ dài dữ liệu' (DLC).

Để truyền DLC thô từ/đến thiết bị mạng CAN cổ điển, len8_dlc
phần tử có thể chứa các giá trị 9 .. 15 khi phần tử len là 8 (phần tử thực
độ dài tải trọng cho tất cả các giá trị DLC lớn hơn hoặc bằng 8).

Căn chỉnh dữ liệu tải trọng (tuyến tính) [] theo ranh giới 64 bit
cho phép người dùng xác định cấu trúc và liên kết của riêng họ để dễ dàng truy cập
tải trọng CAN. Không có thứ tự byte nhất định trên bus CAN bởi
mặc định. Lệnh gọi hệ thống đọc (2) trên ổ cắm CAN_RAW sẽ chuyển một
struct can_frame vào không gian người dùng.

Cấu trúc sockaddr_can có chỉ mục giao diện giống như
Ổ cắm PF_PACKET, cũng liên kết với một giao diện cụ thể:

.. code-block:: C

    struct sockaddr_can {
            sa_family_t can_family;
            int         can_ifindex;
            union {
                    /* transport protocol class address info (e.g. ISOTP) */
                    struct { canid_t rx_id, tx_id; } tp;

                    /* J1939 address information */
                    struct {
                            /* 8 byte name when using dynamic addressing */
                            __u64 name;

                            /* pgn:
                             * 8 bit: PS in PDU2 case, else 0
                             * 8 bit: PF
                             * 1 bit: DP
                             * 1 bit: reserved
                             */
                            __u32 pgn;

                            /* 1 byte address */
                            __u8 addr;
                    } j1939;

                    /* reserved for future CAN protocols address information */
            } can_addr;
    };

Để xác định chỉ mục giao diện, ioctl() thích hợp phải
được sử dụng (ví dụ cho ổ cắm CAN_RAW không kiểm tra lỗi):

.. code-block:: C

    int s;
    struct sockaddr_can addr;
    struct ifreq ifr;

    s = socket(PF_CAN, SOCK_RAW, CAN_RAW);

    strcpy(ifr.ifr_name, "can0" );
    ioctl(s, SIOCGIFINDEX, &ifr);

    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    bind(s, (struct sockaddr *)&addr, sizeof(addr));

    (..)

Để liên kết một ổ cắm với tất cả (!) Giao diện CAN, chỉ mục giao diện phải
là 0 (không). Trong trường hợp này, socket nhận các khung CAN từ mọi
kích hoạt giao diện CAN. Để xác định giao diện CAN gốc
cuộc gọi hệ thống recvfrom(2) có thể được sử dụng thay vì read(2). Để gửi
trên một ổ cắm được liên kết với giao diện 'bất kỳ' sendto(2) là cần thiết để
chỉ định giao diện đi.

Đọc các khung CAN từ ổ cắm CAN_RAW bị ràng buộc (xem ở trên) bao gồm
về việc đọc cấu trúc can_frame:

.. code-block:: C

    struct can_frame frame;

    nbytes = read(s, &frame, sizeof(struct can_frame));

    if (nbytes < 0) {
            perror("can raw socket read");
            return 1;
    }

    /* paranoid check ... */
    if (nbytes < sizeof(struct can_frame)) {
            fprintf(stderr, "read: incomplete CAN frame\n");
            return 1;
    }

    /* do something with the received CAN frame */

Việc ghi các khung CAN có thể được thực hiện tương tự, với lệnh gọi hệ thống write(2) ::

nbytes = write(s, &frame, sizeof(struct can_frame));

Khi giao diện CAN được liên kết với giao diện CAN hiện có 'bất kỳ'
(addr.can_ifindex = 0) nên sử dụng recvfrom(2) nếu
cần có thông tin về giao diện CAN gốc:

.. code-block:: C

    struct sockaddr_can addr;
    struct ifreq ifr;
    socklen_t len = sizeof(addr);
    struct can_frame frame;

    nbytes = recvfrom(s, &frame, sizeof(struct can_frame),
                      0, (struct sockaddr*)&addr, &len);

    /* get interface name of the received CAN frame */
    ifr.ifr_ifindex = addr.can_ifindex;
    ioctl(s, SIOCGIFNAME, &ifr);
    printf("Received a CAN frame from interface %s", ifr.ifr_name);

Để ghi các khung CAN trên các ổ cắm được liên kết với giao diện CAN 'bất kỳ',
giao diện gửi đi phải được xác định chắc chắn:

.. code-block:: C

    strcpy(ifr.ifr_name, "can0");
    ioctl(s, SIOCGIFINDEX, &ifr);
    addr.can_ifindex = ifr.ifr_ifindex;
    addr.can_family  = AF_CAN;

    nbytes = sendto(s, &frame, sizeof(struct can_frame),
                    0, (struct sockaddr*)&addr, sizeof(addr));

Có thể lấy được dấu thời gian chính xác bằng lệnh gọi ioctl(2) sau khi đọc
một tin nhắn từ ổ cắm:

.. code-block:: C

    struct timeval tv;
    ioctl(s, SIOCGSTAMP, &tv);

Dấu thời gian có độ phân giải một micro giây và được đặt tự động
khi tiếp nhận khung CAN.

Nhận xét về hỗ trợ CAN FD (tốc độ dữ liệu linh hoạt):

Nói chung việc xử lý CAN FD rất giống với cách được mô tả trước đây
ví dụ. Bộ điều khiển CAN có khả năng CAN FD mới hỗ trợ hai
tốc độ bit cho giai đoạn phân xử và giai đoạn tải trọng của khung CAN FD
và tải trọng lên tới 64 byte. Độ dài tải trọng mở rộng này phá vỡ tất cả
giao diện hạt nhân (ABI) dựa chủ yếu vào khung CAN với tám cố định
byte tải trọng (struct can_frame) như ổ cắm CAN_RAW. Vì vậy, ví dụ:
ổ cắm CAN_RAW hỗ trợ tùy chọn ổ cắm mới CAN_RAW_FD_FRAMES
chuyển ổ cắm sang chế độ cho phép xử lý các khung CAN FD
và khung CAN cổ điển cùng lúc (xem ZZ0000ZZ).

Cấu trúc canfd_frame được định nghĩa trong include/linux/can.h:

.. code-block:: C

    struct canfd_frame {
            canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
            __u8    len;     /* frame payload length in byte (0 .. 64) */
            __u8    flags;   /* additional flags for CAN FD */
            __u8    __res0;  /* reserved / padding */
            __u8    __res1;  /* reserved / padding */
            __u8    data[64] __attribute__((aligned(8)));
    };

Cấu trúc canfd_frame và cấu trúc can_frame hiện có có can_id,
chiều dài tải trọng và dữ liệu tải trọng ở cùng một độ lệch bên trong chúng
các cấu trúc. Điều này cho phép xử lý các cấu trúc khác nhau rất giống nhau.
Khi nội dung của struct can_frame được sao chép vào struct canfd_frame
tất cả các thành phần cấu trúc có thể được sử dụng nguyên trạng - chỉ data[] mới được mở rộng.

Khi giới thiệu cấu trúc canfd_frame, hóa ra độ dài dữ liệu
mã (DLC) của cấu trúc can_frame được sử dụng làm thông tin về độ dài như
chiều dài và DLC có ánh xạ 1:1 trong phạm vi 0 .. 8. Để bảo toàn
việc xử lý dễ dàng thông tin độ dài của phần tử canfd_frame.len
chứa giá trị độ dài đơn giản từ 0 .. 64. Vì vậy, cả canfd_frame.len và
can_frame.len bằng nhau và chứa thông tin về độ dài và không có DLC.
Để biết chi tiết về sự khác biệt của các thiết bị có khả năng CAN và CAN FD và
ánh xạ tới mã độ dài dữ liệu liên quan đến bus (DLC), xem ZZ0000ZZ.

Độ dài của hai cấu trúc khung CAN(FD) xác định tốc độ truyền tối đa
đơn vị (MTU) của giao diện mạng CAN(FD) và độ dài dữ liệu skbuff. Hai
các định nghĩa được chỉ định cho các MTU cụ thể của CAN trong include/linux/can.h:

.. code-block:: C

  #define CAN_MTU   (sizeof(struct can_frame))   == 16  => Classical CAN frame
  #define CANFD_MTU (sizeof(struct canfd_frame)) == 72  => CAN FD frame


Cờ tin nhắn được trả lại
------------------------

Khi sử dụng lệnh gọi hệ thống recvmsg(2) trên ổ cắm RAW hoặc BCM,
trường msg->msg_flags có thể chứa các cờ sau:

MSG_DONTROUTE:
	được đặt khi khung nhận được được tạo trên máy chủ cục bộ.

MSG_CONFIRM:
	được đặt khi khung được gửi qua ổ cắm mà nó được nhận.
	Cờ này có thể được hiểu là 'xác nhận truyền' khi
	Trình điều khiển CAN hỗ trợ tiếng vang của khung ở cấp độ trình điều khiển, xem
	ZZ0000ZZ và ZZ0001ZZ.
	(Lưu ý: Để nhận được những tin nhắn như vậy trên ổ cắm RAW,
	CAN_RAW_RECV_OWN_MSGS phải được đặt.)


.. _socketcan-raw-sockets:

Ổ cắm giao thức RAW với can_filters (SOCK_RAW)
------------------------------------------------

Việc sử dụng ổ cắm CAN_RAW có thể so sánh rộng rãi với các ổ cắm thông thường
quyền truy cập đã biết vào các thiết bị ký tự CAN. Để đáp ứng những khả năng mới
được cung cấp bởi phương pháp tiếp cận SocketCAN đa người dùng, một số
mặc định được đặt ở thời gian liên kết ổ cắm RAW:

- Các bộ lọc được đặt thành chính xác một bộ lọc nhận mọi thứ
- Ổ cắm chỉ nhận các khung dữ liệu hợp lệ (=> không có khung thông báo lỗi)
- Tính năng lặp lại của các khung CAN đã gửi được bật (xem ZZ0000ZZ)
- Ổ cắm không nhận được các khung đã gửi của chính nó (ở chế độ loopback)

Các cài đặt mặc định này có thể được thay đổi trước hoặc sau khi liên kết ổ cắm.
Để sử dụng các định nghĩa được tham chiếu của các tùy chọn ổ cắm cho CAN_RAW
socket, bao gồm <linux/can/raw.h>.


.. _socketcan-rawfilter:

Tùy chọn ổ cắm RAW CAN_RAW_FILTER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có thể kiểm soát việc tiếp nhận các khung CAN bằng ổ cắm CAN_RAW
bằng cách xác định 0 .. n bộ lọc với tùy chọn ổ cắm CAN_RAW_FILTER.

Cấu trúc bộ lọc CAN được xác định trong include/linux/can.h:

.. code-block:: C

    struct can_filter {
            canid_t can_id;
            canid_t can_mask;
    };

Bộ lọc phù hợp khi:

.. code-block:: C

    <received_can_id> & mask == can_id & mask

tương tự với ngữ nghĩa bộ lọc phần cứng của bộ điều khiển CAN đã biết.
Bộ lọc có thể được đảo ngược theo ngữ nghĩa này, khi CAN_INV_FILTER
bit được đặt trong phần tử can_id của cấu trúc can_filter. trong
tương phản với các bộ lọc phần cứng của bộ điều khiển CAN, người dùng có thể đặt 0 .. n
nhận các bộ lọc cho từng ổ cắm mở riêng biệt:

.. code-block:: C

    struct can_filter rfilter[2];

    rfilter[0].can_id   = 0x123;
    rfilter[0].can_mask = CAN_SFF_MASK;
    rfilter[1].can_id   = 0x200;
    rfilter[1].can_mask = 0x700;

    setsockopt(s, SOL_CAN_RAW, CAN_RAW_FILTER, &rfilter, sizeof(rfilter));

Để tắt việc nhận khung CAN trên ổ cắm CAN_RAW đã chọn:

.. code-block:: C

    setsockopt(s, SOL_CAN_RAW, CAN_RAW_FILTER, NULL, 0);

Để đặt bộ lọc về 0, bộ lọc khá lỗi thời vì không đọc được
dữ liệu khiến ổ cắm thô loại bỏ các khung CAN đã nhận. Nhưng
với trường hợp sử dụng 'chỉ gửi' này, chúng tôi có thể xóa danh sách nhận trong
Kernel để tiết kiệm một chút (thực sự là rất ít!) sử dụng CPU.

Tối ưu hóa sử dụng bộ lọc CAN
.............................

Bộ lọc CAN được xử lý trong danh sách bộ lọc trên mỗi thiết bị ở khung CAN
thời gian tiếp nhận. Để giảm số lần kiểm tra cần thực hiện
trong khi duyệt qua danh sách bộ lọc, lõi CAN cung cấp một giải pháp tối ưu hóa
xử lý bộ lọc khi đăng ký bộ lọc tập trung vào một ID CAN duy nhất.

Đối với các số nhận dạng 2048 SFF CAN có thể, số nhận dạng này được sử dụng làm chỉ mục
để truy cập danh sách đăng ký tương ứng mà không cần kiểm tra thêm.
Đối với 2^29 số nhận dạng EFF CAN có thể có, việc gấp XOR 10 bit được sử dụng làm
hàm băm để lấy chỉ mục bảng EFF.

Để hưởng lợi từ các bộ lọc được tối ưu hóa cho các mã định danh CAN đơn lẻ,
CAN_SFF_MASK hoặc CAN_EFF_MASK phải được đặt cùng nhau trong can_filter.mask
với các bit CAN_EFF_FLAG và CAN_RTR_FLAG được đặt. Một bit CAN_EFF_FLAG được đặt trong
can_filter.mask nêu rõ rằng việc ID SFF hay EFF CAN là quan trọng
đã đăng ký. Ví dụ. trong ví dụ ở trên:

.. code-block:: C

    rfilter[0].can_id   = 0x123;
    rfilter[0].can_mask = CAN_SFF_MASK;

cả hai khung SFF có CAN ID 0x123 và khung EFF có 0xXXXXXX123 đều có thể vượt qua.

Để chỉ lọc các mã định danh CAN 0x123 (SFF) và 0x12345678 (EFF),
bộ lọc phải được xác định theo cách này để hưởng lợi từ các bộ lọc được tối ưu hóa:

.. code-block:: C

    struct can_filter rfilter[2];

    rfilter[0].can_id   = 0x123;
    rfilter[0].can_mask = (CAN_EFF_FLAG | CAN_RTR_FLAG | CAN_SFF_MASK);
    rfilter[1].can_id   = 0x12345678 | CAN_EFF_FLAG;
    rfilter[1].can_mask = (CAN_EFF_FLAG | CAN_RTR_FLAG | CAN_EFF_MASK);

    setsockopt(s, SOL_CAN_RAW, CAN_RAW_FILTER, &rfilter, sizeof(rfilter));


Tùy chọn ổ cắm RAW CAN_RAW_ERR_FILTER
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Như được mô tả trong ZZ0000ZZ, trình điều khiển giao diện CAN có thể tạo ra
được gọi là Khung thông báo lỗi có thể được chuyển đến người dùng tùy ý
ứng dụng theo cách tương tự như các khung CAN khác. Điều có thể
lỗi được chia thành các lớp lỗi khác nhau có thể được lọc
bằng cách sử dụng mặt nạ lỗi thích hợp. Để đăng ký mọi thứ có thể
tình trạng lỗi CAN_ERR_MASK có thể được sử dụng làm giá trị cho mặt nạ lỗi.
Các giá trị cho mặt nạ lỗi được xác định trong linux/can/error.h:

.. code-block:: C

    can_err_mask_t err_mask = ( CAN_ERR_TX_TIMEOUT | CAN_ERR_BUSOFF );

    setsockopt(s, SOL_CAN_RAW, CAN_RAW_ERR_FILTER,
               &err_mask, sizeof(err_mask));


Tùy chọn ổ cắm RAW CAN_RAW_LOOPBACK
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để đáp ứng nhu cầu của nhiều người dùng, vòng lặp cục bộ được bật theo mặc định
(xem ZZ0000ZZ để biết chi tiết). Nhưng trong một số trường hợp sử dụng được nhúng
(ví dụ: khi chỉ có một ứng dụng sử dụng bus CAN) vòng lặp này
chức năng có thể bị vô hiệu hóa (riêng cho từng ổ cắm):

.. code-block:: C

    int loopback = 0; /* 0 = disabled, 1 = enabled (default) */

    setsockopt(s, SOL_CAN_RAW, CAN_RAW_LOOPBACK, &loopback, sizeof(loopback));


Tùy chọn ổ cắm RAW CAN_RAW_RECV_OWN_MSGS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi vòng lặp cục bộ được bật, tất cả các khung CAN đã gửi sẽ được
lặp lại các ổ cắm CAN đang mở đã đăng ký cho CAN
frame' CAN-ID trên giao diện nhất định này để đáp ứng nhiều người dùng
nhu cầu. Việc tiếp nhận các khung CAN trên cùng một ổ cắm đã được
việc gửi khung CAN được coi là không mong muốn và do đó
bị tắt theo mặc định. Hành vi mặc định này có thể được thay đổi trên
nhu cầu:

.. code-block:: C

    int recv_own_msgs = 1; /* 0 = disabled (default), 1 = enabled */

    setsockopt(s, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS,
               &recv_own_msgs, sizeof(recv_own_msgs));

Lưu ý rằng việc tiếp nhận các khung CAN của ổ cắm phải tuân theo cùng một quy định.
lọc như các khung CAN khác (xem ZZ0000ZZ).

.. _socketcan-rawfd:

Tùy chọn ổ cắm RAW CAN_RAW_FD_FRAMES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hỗ trợ CAN FD trong ổ cắm CAN_RAW có thể được bật bằng tùy chọn ổ cắm mới
CAN_RAW_FD_FRAMES được tắt theo mặc định. Khi tùy chọn ổ cắm mới được
không được ổ cắm CAN_RAW hỗ trợ (ví dụ: trên các hạt nhân cũ hơn), việc chuyển đổi
Tùy chọn CAN_RAW_FD_FRAMES trả về lỗi -ENOPROTOOPT.

Khi CAN_RAW_FD_FRAMES được bật, ứng dụng có thể gửi cả hai khung CAN
và khung CAN FD. OTOH ứng dụng phải xử lý các khung CAN và CAN FD
khi đọc từ ổ cắm:

.. code-block:: C

    CAN_RAW_FD_FRAMES enabled:  CAN_MTU and CANFD_MTU are allowed
    CAN_RAW_FD_FRAMES disabled: only CAN_MTU is allowed (default)

Ví dụ:

.. code-block:: C

    [ remember: CANFD_MTU == sizeof(struct canfd_frame) ]

    struct canfd_frame cfd;

    nbytes = read(s, &cfd, CANFD_MTU);

    if (nbytes == CANFD_MTU) {
            printf("got CAN FD frame with length %d\n", cfd.len);
            /* cfd.flags contains valid data */
    } else if (nbytes == CAN_MTU) {
            printf("got Classical CAN frame with length %d\n", cfd.len);
            /* cfd.flags is undefined */
    } else {
            fprintf(stderr, "read: invalid CAN(FD) frame\n");
            return 1;
    }

    /* the content can be handled independently from the received MTU size */

    printf("can_id: %X data length: %d data: ", cfd.can_id, cfd.len);
    for (i = 0; i < cfd.len; i++)
            printf("%02X ", cfd.data[i]);

Khi đọc với kích thước CANFD_MTU chỉ trả về các byte CAN_MTU có
đã được nhận từ ổ cắm, khung CAN cổ điển đã được đọc vào
cung cấp cấu trúc CAN FD. Lưu ý rằng trường dữ liệu canfd_frame.flags là
không được chỉ định trong cấu trúc can_frame và do đó nó chỉ hợp lệ trong
Khung CAN FD có kích thước CANFD_MTU.

Gợi ý triển khai cho các ứng dụng CAN mới:

Để xây dựng ứng dụng nhận biết CAN FD, hãy sử dụng struct canfd_frame làm CAN cơ bản
cấu trúc dữ liệu cho các ứng dụng dựa trên CAN_RAW. Khi ứng dụng được
được thực thi trên nhân Linux cũ hơn và chuyển đổi CAN_RAW_FD_FRAMES
tùy chọn socket trả về lỗi: Không vấn đề gì. Bạn sẽ nhận được gọng kính CAN Cổ điển
hoặc khung CAN FD và có thể xử lý chúng theo cách tương tự.

Khi gửi tới các thiết bị CAN, hãy đảm bảo rằng thiết bị đó có khả năng xử lý
Khung CAN FD bằng cách kiểm tra xem đơn vị truyền tối đa của thiết bị có phải là CANFD_MTU hay không.
Có thể truy xuất thiết bị CAN MTU, ví dụ: với một tòa nhà cao tầng SIOCGIFMTU ioctl().


Tùy chọn ổ cắm RAW CAN_RAW_JOIN_FILTERS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ổ cắm CAN_RAW có thể đặt nhiều bộ lọc cụ thể cho mã định danh CAN để
dẫn đến nhiều bộ lọc trong quá trình xử lý bộ lọc af_can.c. Những bộ lọc này
độc lập với nhau dẫn đến các bộ lọc OR'ed hợp lý khi
được áp dụng (xem ZZ0000ZZ).

Tùy chọn ổ cắm này kết hợp các bộ lọc CAN đã cho theo cách mà chỉ CAN
các khung được chuyển đến không gian người dùng khớp với ZZ0000ZZ cho các bộ lọc CAN. các
do đó, ngữ nghĩa cho các bộ lọc được áp dụng được thay đổi thành AND logic.

Điều này đặc biệt hữu ích khi bộ lọc là sự kết hợp của các bộ lọc
trong đó cờ CAN_INV_FILTER được đặt để đánh dấu các ID CAN đơn lẻ hoặc
ID CAN dao động từ lưu lượng truy cập đến.


Ổ cắm giao thức quản lý phát sóng (SOCK_DGRAM)
-----------------------------------------------

Giao thức Broadcast Manager cung cấp cấu hình dựa trên lệnh
giao diện để lọc và gửi (ví dụ: tuần hoàn) các tin nhắn CAN trong không gian kernel.

Bộ lọc nhận có thể được sử dụng để lấy mẫu các tin nhắn thường xuyên; phát hiện sự kiện
chẳng hạn như thay đổi nội dung tin nhắn, thay đổi độ dài gói và thực hiện hết thời gian chờ
giám sát các tin nhắn nhận được.

Nhiệm vụ truyền định kỳ của các khung CAN hoặc một chuỗi các khung CAN có thể được thực hiện
được tạo và sửa đổi khi chạy; cả nội dung tin nhắn và cả hai
khoảng thời gian truyền có thể có thể được thay đổi.

Ổ cắm BCM không nhằm mục đích gửi các khung CAN riêng lẻ bằng cách sử dụng
struct can_frame như được biết đến từ ổ cắm CAN_RAW. Thay vào đó là một chiếc BCM đặc biệt
thông báo cấu hình được xác định. Thông báo cấu hình BCM cơ bản được sử dụng
để liên lạc với người quản lý phát sóng và các hoạt động có sẵn là
được định nghĩa trong linux/can/bcm.h. Thông báo BCM bao gồm một
tiêu đề thư có lệnh ('opcode'), theo sau là 0 hoặc nhiều khung CAN.
Trình quản lý quảng bá gửi phản hồi đến không gian người dùng ở dạng tương tự:

.. code-block:: C

    struct bcm_msg_head {
            __u32 opcode;                   /* command */
            __u32 flags;                    /* special flags */
            __u32 count;                    /* run 'count' times with ival1 */
            struct timeval ival1, ival2;    /* count and subsequent interval */
            canid_t can_id;                 /* unique can_id for task */
            __u32 nframes;                  /* number of can_frames following */
            struct can_frame frames[];
    };

'Khung' tải trọng được căn chỉnh sử dụng cùng cấu trúc khung CAN cơ bản được xác định
ở đầu ZZ0000ZZ và trong include/linux/can.h. Tất cả
tin nhắn tới người quản lý quảng bá từ không gian người dùng có cấu trúc này.

Lưu ý ổ cắm CAN_BCM phải được kết nối thay vì bị ràng buộc sau ổ cắm
tạo (ví dụ không kiểm tra lỗi):

.. code-block:: C

    int s;
    struct sockaddr_can addr;
    struct ifreq ifr;

    s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM);

    strcpy(ifr.ifr_name, "can0");
    ioctl(s, SIOCGIFINDEX, &ifr);

    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    connect(s, (struct sockaddr *)&addr, sizeof(addr));

    (..)

Ổ cắm trình quản lý phát sóng có thể xử lý bất kỳ số lượng nào trong chuyến bay
truyền hoặc nhận các bộ lọc đồng thời. Các công việc RX/TX khác nhau là
được phân biệt bằng can_id duy nhất trong mỗi tin nhắn BCM. Tuy nhiên bổ sung
Ổ cắm CAN_BCM được khuyến nghị để giao tiếp trên nhiều giao diện CAN.
Khi ổ cắm trình quản lý quảng bá được liên kết với giao diện CAN 'bất kỳ' (=>
chỉ mục giao diện được đặt thành 0) các bộ lọc nhận được định cấu hình sẽ áp dụng cho bất kỳ
Giao diện CAN trừ khi tòa nhà cao tầng sendto() được sử dụng để ghi đè CAN 'bất kỳ'
chỉ số giao diện. Khi sử dụng recvfrom() thay vì read() để truy xuất BCM
socket thông báo giao diện CAN gốc được cung cấp trong can_ifindex.


Hoạt động quản lý phát sóng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Opcode xác định hoạt động để trình quản lý quảng bá thực hiện,
hoặc nêu chi tiết phản hồi của người quản lý chương trình phát sóng đối với một số sự kiện, bao gồm
yêu cầu của người dùng.

Hoạt động truyền tải (không gian người dùng tới trình quản lý phát sóng):

TX_SETUP:
	Tạo tác vụ truyền (theo chu kỳ).

TX_DELETE:
	Xóa tác vụ truyền (theo chu kỳ), chỉ yêu cầu can_id.

TX_READ:
	Đọc thuộc tính của tác vụ truyền (theo chu kỳ) cho can_id.

TX_SEND:
	Gửi một khung CAN.

Truyền phản hồi (trình quản lý phát sóng đến không gian người dùng):

TX_STATUS:
	Trả lời yêu cầu TX_READ (cấu hình nhiệm vụ truyền tải).

TX_EXPIRED:
	Thông báo khi bộ đếm kết thúc gửi ở khoảng thời gian ban đầu
	'ival1'. Yêu cầu cờ TX_COUNTEVT được đặt ở TX_SETUP.

Nhận hoạt động (không gian người dùng cho trình quản lý phát sóng):

RX_SETUP:
	Tạo đăng ký bộ lọc nội dung RX.

RX_DELETE:
	Xóa đăng ký bộ lọc nội dung RX, chỉ yêu cầu can_id.

RX_READ:
	Đọc thuộc tính của đăng ký bộ lọc nội dung RX cho can_id.

Nhận phản hồi (trình quản lý phát sóng tới không gian người dùng):

RX_STATUS:
	Trả lời yêu cầu RX_READ (cấu hình tác vụ lọc).

RX_TIMEOUT:
	Thông báo tuần hoàn được phát hiện là vắng mặt (bộ đếm thời gian ival1 đã hết hạn).

RX_CHANGED:
	Tin nhắn BCM có khung CAN được cập nhật (đã phát hiện thay đổi nội dung).
	Đã gửi khi nhận được tin nhắn đầu tiên hoặc khi nhận được tin nhắn CAN đã sửa đổi.


Cờ tin nhắn của trình quản lý phát sóng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi gửi tin nhắn đến trình quản lý quảng bá, phần tử 'cờ' có thể
chứa các định nghĩa cờ sau ảnh hưởng đến hành vi:

SETTIMER:
	Đặt các giá trị của ival1, ival2 và count

STARTTIMER:
	Bắt đầu hẹn giờ với các giá trị thực tế của ival1, ival2
	và đếm. Việc khởi động đồng hồ hẹn giờ sẽ dẫn đến đồng thời phát ra khung CAN.

TX_COUNTEVT:
	Tạo thông báo TX_EXPIRED khi hết số đếm

TX_ANNOUNCE:
	Một sự thay đổi dữ liệu của quá trình được phát ra ngay lập tức.

TX_CP_CAN_ID:
	Sao chép can_id từ tiêu đề thư tới mỗi
	khung tiếp theo trong khung. Điều này nhằm mục đích đơn giản hóa việc sử dụng. cho
	Nhiệm vụ TX can_id duy nhất từ tiêu đề thư có thể khác với
	(các) can_id được lưu trữ để truyền trong (các) cấu trúc can_frame tiếp theo.

RX_FILTER_ID:
	Chỉ lọc theo can_id, không cần khung (nframes=0).

RX_CHECK_DLC:
	Sự thay đổi của DLC sẽ dẫn đến RX_CHANGED.

RX_NO_AUTOTIMER:
	Ngăn chặn tự động khởi động màn hình thời gian chờ.

RX_ANNOUNCE_RESUME:
	Nếu vượt qua ở RX_SETUP và xảy ra thời gian chờ nhận,
	Thông báo RX_CHANGED sẽ được tạo khi quá trình nhận (theo chu kỳ) khởi động lại.

TX_RESET_MULTI_IDX:
	Đặt lại chỉ mục cho việc truyền nhiều khung.

RX_RTR_FRAME:
	Gửi trả lời cho yêu cầu RTR (được đặt trong op->frames[0]).

CAN_FD_FRAME:
	Các khung CAN theo sau bcm_msg_head là cấu trúc của canfd_frame

Bộ định thời truyền của Trình quản lý phát sóng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cấu hình truyền định kỳ có thể sử dụng tối đa hai bộ định thời.
Trong trường hợp này, BCM gửi một số tin nhắn ('đếm') theo khoảng thời gian
'ival1', sau đó tiếp tục gửi ở một khoảng thời gian nhất định khác 'ival2'. Khi nào
chỉ cần một bộ đếm thời gian 'đếm' được đặt thành 0 và chỉ sử dụng 'ival2'.
Khi cờ SET_TIMER và START_TIMER được đặt, bộ hẹn giờ sẽ được kích hoạt.
Các giá trị hẹn giờ có thể được thay đổi trong thời gian chạy khi chỉ đặt SET_TIMER.


Truyền chuỗi thông báo của Trình quản lý phát sóng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có thể truyền tối đa 256 khung CAN theo trình tự trong trường hợp truyền tuần hoàn
Cấu hình tác vụ TX. Số lượng khung CAN được cung cấp trong 'nframes'
phần tử của đầu thông báo BCM. Số lượng khung CAN đã xác định được thêm vào
dưới dạng mảng cho thông báo cấu hình TX_SETUP BCM:

.. code-block:: C

    /* create a struct to set up a sequence of four CAN frames */
    struct {
            struct bcm_msg_head msg_head;
            struct can_frame frame[4];
    } mytxmsg;

    (..)
    mytxmsg.msg_head.nframes = 4;
    (..)

    write(s, &mytxmsg, sizeof(mytxmsg));

Với mỗi lần truyền, chỉ số trong mảng khung CAN sẽ tăng lên
và được đặt thành 0 khi tràn chỉ mục.


Trình quản lý phát sóng Bộ hẹn giờ nhận bộ lọc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các giá trị bộ định thời ival1 hoặc ival2 có thể được đặt thành các giá trị khác 0 tại RX_SETUP.
Khi cờ SET_TIMER được đặt, bộ hẹn giờ sẽ được bật:

ival1:
	Gửi RX_TIMEOUT khi không nhận được tin nhắn đã nhận trong vòng
	thời gian nhất định. Khi START_TIMER được đặt ở RX_SETUP, tính năng phát hiện thời gian chờ
	được kích hoạt trực tiếp - ngay cả khi không có khả năng nhận khung CAN trước đây.

ival2:
	Giảm tốc độ tin nhắn nhận được xuống giá trị ival2. Cái này
	rất hữu ích để giảm tin nhắn cho ứng dụng khi tín hiệu bên trong
	Khung CAN không có trạng thái vì các thay đổi trạng thái trong khoảng thời gian ival2 có thể nhận được
	bị mất.

Bộ lọc nhận tin nhắn đa kênh của Trình quản lý phát sóng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để lọc các thay đổi nội dung trong chuỗi thông báo ghép kênh, một mảng khác
hơn một khung CAN có thể được truyền trong thông báo cấu hình RX_SETUP. các
byte dữ liệu của khung CAN đầu tiên chứa mặt nạ của các bit có liên quan
phải khớp trong các khung CAN tiếp theo với khung CAN nhận được.
Nếu một trong các khung CAN tiếp theo khớp với các bit trong dữ liệu khung đó
đánh dấu nội dung liên quan để so sánh với nội dung nhận được trước đó.
Lên đến 257 khung CAN (mặt nạ bit bộ lọc ghép kênh khung CAN cộng với 256 CAN
bộ lọc) có thể được thêm dưới dạng mảng vào thông báo cấu hình TX_SETUP BCM:

.. code-block:: C

    /* usually used to clear CAN frame data[] - beware of endian problems! */
    #define U64_DATA(p) (*(unsigned long long*)(p)->data)

    struct {
            struct bcm_msg_head msg_head;
            struct can_frame frame[5];
    } msg;

    msg.msg_head.opcode  = RX_SETUP;
    msg.msg_head.can_id  = 0x42;
    msg.msg_head.flags   = 0;
    msg.msg_head.nframes = 5;
    U64_DATA(&msg.frame[0]) = 0xFF00000000000000ULL; /* MUX mask */
    U64_DATA(&msg.frame[1]) = 0x01000000000000FFULL; /* data mask (MUX 0x01) */
    U64_DATA(&msg.frame[2]) = 0x0200FFFF000000FFULL; /* data mask (MUX 0x02) */
    U64_DATA(&msg.frame[3]) = 0x330000FFFFFF0003ULL; /* data mask (MUX 0x33) */
    U64_DATA(&msg.frame[4]) = 0x4F07FC0FF0000000ULL; /* data mask (MUX 0x4F) */

    write(s, &msg, sizeof(msg));


Hỗ trợ Trình quản lý phát sóng CAN FD
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Việc lập trình API của CAN_BCM phụ thuộc vào struct can_frame, đó là
được đưa ra dưới dạng mảng trực tiếp phía sau cấu trúc bcm_msg_head. Để làm theo điều này
lược đồ cho CAN FD đóng khung một cờ mới 'CAN_FD_FRAME' trong bcm_msg_head
cờ chỉ ra rằng các cấu trúc khung CAN được nối phía sau
bcm_msg_head được định nghĩa là struct canfd_frame:

.. code-block:: C

    struct {
            struct bcm_msg_head msg_head;
            struct canfd_frame frame[5];
    } msg;

    msg.msg_head.opcode  = RX_SETUP;
    msg.msg_head.can_id  = 0x42;
    msg.msg_head.flags   = CAN_FD_FRAME;
    msg.msg_head.nframes = 5;
    (..)

Khi sử dụng khung CAN FD để lọc ghép kênh, mặt nạ MUX vẫn
dự kiến ​​trong 64 bit đầu tiên của phần dữ liệu struct canfd_frame.


Giao thức truyền tải được kết nối (SOCK_SEQPACKET)
--------------------------------------------------

(sẽ được viết)


Giao thức truyền tải không được kết nối (SOCK_DGRAM)
----------------------------------------------------

(sẽ được viết)


.. _socketcan-core-module:

Mô-đun lõi của SocketCAN
========================

Mô-đun lõi của SocketCAN triển khai họ giao thức
PF_CAN. Các mô-đun giao thức CAN được tải bởi mô-đun lõi tại
thời gian chạy. Mô-đun lõi cung cấp giao diện cho giao thức CAN
mô-đun để đăng ký ID CAN cần thiết (xem ZZ0000ZZ).


Thông số mô-đun can.ko
----------------------

-ZZ0000ZZ:
  Để tính toán số liệu thống kê cốt lõi của SocketCAN
  (ví dụ: khung hình hiện tại/tối đa trên giây) bộ hẹn giờ 1 giây này là
  được gọi tại thời điểm bắt đầu mô-đun can.ko theo mặc định. Bộ hẹn giờ này có thể
  bị vô hiệu hóa bằng cách sử dụng stattimer=0 trên dòng lệnh mô-đun.

-ZZ0000ZZ:
  (đã bị xóa kể từ SocketCAN SVN r546)


nội dung procfs
---------------

Như được mô tả trong ZZ0000ZZ, lõi SocketCAN sử dụng một số bộ lọc
danh sách để phân phối các khung CAN đã nhận tới các mô-đun giao thức CAN. Những cái này
danh sách nhận, bộ lọc của chúng và số lượng bộ lọc phù hợp có thể được
được kiểm tra trong danh sách nhận thích hợp. Tất cả các mục đều chứa
thiết bị và mã định danh mô-đun giao thức::

foo@bar:~$ cat /proc/net/can/rcvlist_all

nhận danh sách 'rx_all':
      (vcan3: không có mục nào)
      (vcan2: không có mục nào)
      (vcan1: không có mục nào)
      thiết bị can_id chức năng can_mask dữ liệu người dùng khớp với danh tính
       vcan0 000 00000000 f88e6370 f6c6f400 0 nguyên
      (bất kỳ: không được vào)

Trong ví dụ này, một ứng dụng yêu cầu bất kỳ lưu lượng truy cập CAN nào từ vcan0::

rcvlist_all - danh sách các mục chưa được lọc (không có thao tác lọc)
    rcvlist_eff - danh sách các mục nhập khung mở rộng đơn (EFF)
    rcvlist_err - danh sách mặt nạ khung thông báo lỗi
    rcvlist_fil - danh sách bộ lọc mặt nạ/giá trị
    rcvlist_inv - danh sách các bộ lọc mặt nạ/giá trị (ngữ nghĩa nghịch đảo)
    rcvlist_sff - danh sách các mục nhập khung tiêu chuẩn đơn (SFF)

Các tệp Procfs bổ sung trong /proc/net/can::

số liệu thống kê - Số liệu thống kê cốt lõi của SocketCAN (khung rx/tx, tỷ lệ khớp, ...)
    reset_stats - đặt lại thống kê thủ công
    phiên bản - in lõi SocketCAN và phiên bản ABI (đã bị xóa trong Linux 5.10)


Viết các mô-đun giao thức CAN của riêng
---------------------------------------

Để triển khai một giao thức mới trong họ giao thức PF_CAN, một giao thức mới
giao thức phải được xác định trong include/linux/can.h .
Các nguyên mẫu và định nghĩa để sử dụng lõi SocketCAN có thể
được truy cập bằng cách bao gồm include/linux/can/core.h .
Ngoài các chức năng đăng ký giao thức CAN và
Chuỗi thông báo thiết bị CAN có chức năng đăng ký CAN
các khung được nhận bởi các giao diện CAN và để gửi các khung CAN::

can_rx_register - đăng ký các khung CAN từ một giao diện cụ thể
    can_rx_unregister - hủy đăng ký khung CAN khỏi một giao diện cụ thể
    can_send - truyền khung CAN (tùy chọn với vòng lặp cục bộ)

Để biết chi tiết, hãy xem tài liệu kerneldoc trong net/can/af_can.c hoặc
mã nguồn của net/can/raw.c hoặc net/can/bcm.c .


Trình điều khiển mạng CAN
=========================

Viết trình điều khiển thiết bị mạng CAN dễ dàng hơn nhiều so với việc viết một
Trình điều khiển thiết bị ký tự CAN. Tương tự như thiết bị mạng đã biết khác
trình điều khiển bạn chủ yếu phải giải quyết:

- TX: Đưa khung CAN từ bộ đệm socket vào bộ điều khiển CAN.
- RX: Đặt khung CAN từ bộ điều khiển CAN vào bộ đệm ổ cắm.

Xem ví dụ tại Tài liệu/mạng/netdevices.rst. Sự khác biệt
để viết trình điều khiển thiết bị mạng CAN được mô tả bên dưới:


Cài đặt chung
----------------

Trình điều khiển thiết bị mạng CAN có thể sử dụng alloc_candev_mqs() và bạn bè thay vì
alloc_netdev_mqs(), để tự động xử lý việc thiết lập dành riêng cho CAN:

.. code-block:: C

    dev = alloc_candev_mqs(...);

struct can_frame hoặc struct canfd_frame là payload của mỗi socket
bộ đệm (skbuff) trong họ giao thức PF_CAN.


.. _socketcan-local-loopback2:

Vòng lặp cục bộ của các khung đã gửi
------------------------------------

Như được mô tả trong ZZ0000ZZ, trình điều khiển thiết bị mạng CAN sẽ
hỗ trợ chức năng lặp lại cục bộ tương tự như tiếng vang cục bộ
ví dụ: của các thiết bị tty. Trong trường hợp này, cờ trình điều khiển IFF_ECHO phải là
được đặt để ngăn lõi PF_CAN lặp lại các khung đã gửi cục bộ
(còn gọi là loopback) làm giải pháp dự phòng::

dev->flags = (IFF_NOARP | IFF_ECHO);


Bộ lọc phần cứng bộ điều khiển CAN
----------------------------------

Để giảm tải gián đoạn trên các hệ thống nhúng sâu, một số CAN
bộ điều khiển hỗ trợ lọc ID CAN hoặc phạm vi ID CAN.
Các khả năng lọc phần cứng này khác nhau tùy theo từng bộ điều khiển.
bộ điều khiển và phải được xác định là không khả thi trong môi trường nhiều người dùng
cách tiếp cận mạng. Việc sử dụng bộ điều khiển rất cụ thể
bộ lọc phần cứng có thể có ý nghĩa trong trường hợp sử dụng rất chuyên dụng, như một
bộ lọc ở cấp trình điều khiển sẽ ảnh hưởng đến tất cả người dùng trong chế độ nhiều người dùng
hệ thống. Bộ lọc hiệu quả cao bên trong lõi PF_CAN cho phép
để đặt nhiều bộ lọc khác nhau cho từng ổ cắm riêng biệt.
Do đó, việc sử dụng các bộ lọc phần cứng được xếp vào danh mục 'thủ công'
điều chỉnh trên các hệ thống nhúng sâu'. Tác giả đang chạy MPC603e
@ 133 MHz với bốn bộ điều khiển SJA1000 CAN từ năm 2002 dưới xe buýt hạng nặng
tải mà không gặp vấn đề gì ...


Điện trở kết thúc có thể chuyển đổi
-----------------------------------

Bus CAN yêu cầu trở kháng cụ thể trên cặp vi sai,
thường được cung cấp bởi hai điện trở 120Ohm trên các nút xa nhất của
xe buýt. Một số bộ điều khiển CAN hỗ trợ kích hoạt/hủy kích hoạt
(các) điện trở kết thúc để cung cấp trở kháng chính xác.

Truy vấn các điện trở có sẵn::

$ ip -chi tiết link show can0
    ...
chấm dứt 120 [ 0, 120 ]

Kích hoạt điện trở kết thúc::

$ ip link set dev can0 loại can chấm dứt 120

Tắt điện trở kết thúc::

$ ip link set dev can0 loại can chấm dứt 0

Để kích hoạt hỗ trợ điện trở kết thúc cho bộ điều khiển hộp, hãy
triển khai trong cấu trúc can-priv:: của bộ điều khiển

chấm dứt_const
    chấm dứt_const_cnt
    do_set_termination

hoặc thêm điều khiển gpio với các mục nhập cây thiết bị từ
Tài liệu/devicetree/binds/net/can/can-controller.yaml


Trình điều khiển CAN ảo (vcan)
------------------------------

Tương tự như các thiết bị loopback mạng, vcan cung cấp một mạng cục bộ ảo
Giao diện CAN. Một địa chỉ đủ điều kiện trên CAN bao gồm

- Mã định danh CAN duy nhất (ID CAN)
- bus CAN, ID CAN này được truyền đi (ví dụ: can0)

vì vậy, trong các trường hợp sử dụng thông thường, cần có nhiều giao diện CAN ảo.

Giao diện CAN ảo cho phép truyền và nhận CAN
khung không có phần cứng bộ điều khiển CAN thực. Mạng CAN ảo
các thiết bị thường được đặt tên là 'vcanX', như vcan0 vcan1 vcan2 ...
Khi được biên dịch dưới dạng mô-đun, mô-đun trình điều khiển CAN ảo được gọi là vcan.ko

Vì Linux Kernel phiên bản 2.6.24 nên trình điều khiển vcan hỗ trợ Kernel
giao diện netlink để tạo các thiết bị mạng vcan. Việc tạo ra và
Việc loại bỏ các thiết bị mạng vcan có thể được quản lý bằng công cụ ip(8) ::

- Tạo giao diện mạng CAN ảo:
       $ ip liên kết thêm loại vcan

- Tạo giao diện mạng CAN ảo với tên cụ thể là “vcan42”:
       $ ip link thêm dev vcan42 gõ vcan

- Loại bỏ giao diện mạng (CAN ảo) 'vcan42':
       $ ip liên kết del vcan42


Giao diện trình điều khiển thiết bị mạng CAN
--------------------------------------------

Giao diện trình điều khiển thiết bị mạng CAN cung cấp giao diện chung
để thiết lập, cấu hình và giám sát các thiết bị mạng CAN. Sau đó người dùng có thể
định cấu hình thiết bị CAN, như cài đặt các tham số thời gian bit, thông qua
giao diện netlink sử dụng chương trình "ip" từ "IPROUTE2"
bộ tiện ích. Chương sau mô tả ngắn gọn cách sử dụng nó.
Hơn nữa, giao diện sử dụng cấu trúc dữ liệu chung và xuất một
tập hợp các chức năng chung, mà tất cả các trình điều khiển thiết bị mạng CAN thực sự đều có
nên sử dụng. Vui lòng xem trình điều khiển SJA1000 hoặc MSCAN để
hiểu cách sử dụng chúng. Tên của mô-đun là can-dev.ko.


Giao diện Netlink để đặt/nhận thuộc tính thiết bị
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thiết bị CAN phải được cấu hình qua giao diện netlink. Được hỗ trợ
các loại thông báo liên kết mạng được xác định và mô tả ngắn gọn trong
"bao gồm/linux/can/netlink.h". Hỗ trợ liên kết CAN cho chương trình "ip"
của bộ tiện ích IPROUTE2 có sẵn và nó có thể được sử dụng như được hiển thị
dưới đây:

Đặt thuộc tính thiết bị CAN::

$ ip link set can0 loại can0 có thể giúp ích
    Cách sử dụng: bộ ip link DEVICE loại can
        [ tốc độ bit BITRATE [ điểm mẫu SAMPLE-POINT] ] |
        [ tq TQ prop-seg PROP_SEG giai đoạn-seg1 PHASE-SEG1
          giai đoạn-seg2 PHASE-SEG2 [ sjw SJW ] ]

[ dbitrate BITRATE [ dsample-point SAMPLE-POINT] ] |
        [ dtq TQ dprop-seg PROP_SEG dphase-seg1 PHASE-SEG1
          dphase-seg2 PHASE-SEG2 [ dsjw SJW ] ]

[ vòng lặp ngược lại { trên | tắt } ]
        [ chỉ nghe { bật | tắt } ]
        [ lấy mẫu ba lần { bật | tắt } ]
        [ một lần { trên | tắt } ]
        [ báo cáo berr { trên | tắt } ]
        [ fd { trên | tắt } ]
        [ fd-không-iso { trên | tắt } ]
        [ đoán-ack { trên | tắt } ]
        [ cc-len8-dlc { trên | tắt } ]

[ khởi động lại-ms TIME-MS]
        [ khởi động lại ]

Trong đó: BITRATE := { 1..1000000 }
               SAMPLE-POINT := { 0.000..0.999 }
               TQ := {NUMBER }
               PROP-SEG := { 1..8 }
               PHASE-SEG1 := { 1..8 }
               PHASE-SEG2 := { 1..8 }
               SJW := { 1..4 }
               RESTART-MS := { 0 | NUMBER }

Hiển thị thông tin chi tiết và thống kê của thiết bị CAN::

$ ip -details -statistics link show can0
    2: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast trạng thái UP qlen 10
      liên kết/có thể
      có thể <TRIPLE-SAMPLING> trạng thái ERROR-ACTIVE khởi động lại-ms 100
      tốc độ bit 125000 mẫu_điểm 0,875
      tq 125 prop-seg 6 pha-seg1 7 pha-seg2 2 sjw 1
      sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
      đồng hồ 8000000
      khởi động lại lỗi bus arbit-mất lỗi cảnh báo lỗi vượt qua bus-off
      41 17457 0 41 42 41
      RX: lỗi gói byte bị bỏ qua mcast
      140859 17608 17457 0 0 0
      TX: lỗi gói byte bị rớt mạng thu thập sóng mang
      861 112 0 41 0 0

Thông tin thêm về kết quả trên:

"<TRIPLE-SAMPLING>"
	Hiển thị danh sách các chế độ bộ điều khiển CAN đã chọn: LOOPBACK,
	LISTEN-ONLY, hoặc TRIPLE-SAMPLING.

"trạng thái ERROR-ACTIVE"
	Trạng thái hiện tại của bộ điều khiển CAN: "ERROR-ACTIVE",
	"ERROR-WARNING", "ERROR-PASSIVE", "BUS-OFF" hoặc "STOPPED"

"khởi động lại-ms 100"
	Tự động khởi động lại thời gian trễ. Nếu được đặt thành giá trị khác 0,
	việc khởi động lại bộ điều khiển CAN sẽ được kích hoạt tự động
	trong trường hợp có tình trạng ngắt bus sau thời gian trễ được chỉ định
	tính bằng mili giây. Theo mặc định nó tắt.

"tốc độ bit 125000 điểm mẫu 0,875"
	Hiển thị tốc độ bit thực tính bằng bit/giây và điểm mẫu trong
	phạm vi 0,000..0.999. Nếu việc tính toán các tham số thời gian bit
	được kích hoạt trong kernel (CONFIG_CAN_CALC_BITTIMING=y),
	thời gian bit có thể được xác định bằng cách đặt đối số "bitrate".
	Tùy chọn "điểm mẫu" có thể được chỉ định. Theo mặc định nó là
	0,000 giả sử điểm mẫu được đề xuất là CIA.

"tq 125 prop-seg 6 pha-seg1 7 pha-seg2 2 sjw 1"
	Hiển thị lượng tử thời gian tính bằng ns, đoạn truyền, bộ đệm pha
	phân đoạn 1 và 2 và độ rộng bước nhảy đồng bộ hóa tính bằng đơn vị
	tq. Chúng cho phép xác định thời gian bit CAN trong phần cứng
	định dạng độc lập theo đề xuất của thông số kỹ thuật Bosch CAN 2.0 (xem
	chương 8 của ZZ0000ZZ

"sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1 đồng hồ 8000000"
	Hiển thị hằng số thời gian bit của bộ điều khiển CAN, ở đây là
	"sja1000". Giá trị tối thiểu và tối đa của đoạn thời gian 1
	và 2, độ rộng bước nhảy đồng bộ hóa tính bằng đơn vị tq,
	bộ chia tỷ lệ trước bitrate và tần số xung nhịp hệ thống CAN tính bằng Hz.
	Các hằng số này có thể được sử dụng cho các trường hợp do người dùng xác định (không chuẩn)
	thuật toán tính toán thời gian bit trong không gian người dùng.

"khởi động lại lỗi bus arbit-lỗi mất-cảnh báo lỗi-chuyển bus-off"
	Hiển thị số lần khởi động lại, lỗi bus và trọng tài bị mất,
	và trạng thái thay đổi thành cảnh báo lỗi, lỗi thụ động và
	trạng thái tắt xe buýt. Lỗi tràn RX được liệt kê trong phần "overrun"
	lĩnh vực thống kê mạng tiêu chuẩn.

Đặt thời gian bit CAN
~~~~~~~~~~~~~~~~~~~~~~~~~~

Các tham số thời gian bit CAN luôn có thể được xác định trong phần cứng
định dạng độc lập như được đề xuất trong thông số kỹ thuật Bosch CAN 2.0
chỉ định các đối số "tq", "prop_seg", "phase_seg1", "phase_seg2"
và "sjw"::

$ ip link set canX type can tq 125 prop-seg 6 \
				giai đoạn-seg1 7 giai đoạn-seg2 2 sjw 1

Nếu tùy chọn kernel CONFIG_CAN_CALC_BITTIMING được bật, CIA
các tham số định thời bit CAN được khuyến nghị sẽ được tính toán nếu bit-
tốc độ được chỉ định bằng đối số "bitrate"::

$ ip link set loại canX có thể bitrate 125000

Lưu ý rằng điều này hoạt động tốt đối với các bộ điều khiển CAN phổ biến nhất với
tốc độ bit tiêu chuẩn nhưng có thể ZZ0000ZZ cho tốc độ bit kỳ lạ hoặc hệ thống CAN
tần số đồng hồ. Vô hiệu hóa CONFIG_CAN_CALC_BITTIMING sẽ tiết kiệm được một số
không gian và cho phép các công cụ trong không gian người dùng chỉ xác định và thiết lập
các thông số định thời bit. Thời gian bit cụ thể của bộ điều khiển CAN
hằng số có thể được sử dụng cho mục đích đó. Chúng được liệt kê bởi
lệnh sau::

$ ip -chi tiết link show can0
    ...
      sja1000: clock 8000000 tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1


Khởi động và dừng thiết bị mạng CAN
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thiết bị mạng CAN được khởi động hoặc dừng như bình thường bằng lệnh
"ifconfig canX up/down" hoặc "ip link set canX up/down". Hãy nhận biết rằng
bạn ZZ0000ZZ xác định các tham số định thời bit thích hợp cho các thiết bị CAN thực
trước khi bạn có thể khởi động nó để tránh cài đặt mặc định dễ bị lỗi::

$ ip link set canX up loại có thể bitrate 125000

Thiết bị có thể chuyển sang trạng thái "tắt bus" nếu xảy ra quá nhiều lỗi trên
xe buýt CAN. Sau đó không còn tin nhắn nào được nhận hoặc gửi nữa. Tự động
Có thể bật khôi phục khi tắt bus bằng cách đặt "khởi động lại-ms" thành
giá trị khác 0, ví dụ::

$ ip link set canX type có thể restart-ms 100

Ngoài ra, ứng dụng có thể nhận ra điều kiện "tắt xe buýt"
bằng cách theo dõi các khung thông báo lỗi CAN và khởi động lại khi
phù hợp với lệnh::

$ ip link set canX loại canX có thể khởi động lại

Lưu ý rằng việc khởi động lại cũng sẽ tạo ra khung thông báo lỗi CAN (xem
cũng là ZZ0000ZZ).


.. _socketcan-can-fd-driver:

Hỗ trợ trình điều khiển CAN FD (Tốc độ dữ liệu linh hoạt)
---------------------------------------------------------

Bộ điều khiển CAN có khả năng CAN FD hỗ trợ hai tốc độ bit khác nhau cho
giai đoạn phân xử và giai đoạn tải trọng của khung CAN FD. Vì vậy một
Thời gian bit thứ hai phải được chỉ định để kích hoạt tốc độ bit CAN FD.

Ngoài ra, bộ điều khiển CAN có khả năng CAN FD hỗ trợ lên tới 64 byte
tải trọng. Biểu diễn độ dài này trong can_frame.len và
canfd_frame.len cho các ứng dụng không gian người dùng và bên trong mạng Linux
lớp là một giá trị đơn giản từ 0 .. 64 thay vì độ dài CAN cổ điển
nằm trong khoảng từ 0 đến 8. Độ dài tải trọng tới ánh xạ DLC liên quan đến bus
chỉ được thực hiện bên trong trình điều khiển CAN, tốt nhất là với trình trợ giúp
các hàm can_fd_dlc2len() và can_fd_len2dlc().

Khả năng của trình điều khiển netdevice CAN có thể được phân biệt qua mạng
Đơn vị truyền tải tối đa của thiết bị (MTU)::

MTU = 16 (CAN_MTU) => sizeof(struct can_frame) => Thiết bị CAN cổ điển
  MTU = 72 (CANFD_MTU) => sizeof(struct canfd_frame) => CAN Thiết bị có khả năng FD

Có thể truy xuất thiết bị CAN MTU, ví dụ: với một tòa nhà cao tầng SIOCGIFMTU ioctl().
N.B. Các thiết bị có khả năng CAN FD cũng có thể xử lý và gửi các khung CAN Cổ điển.

Khi định cấu hình bộ điều khiển CAN có khả năng CAN FD, tốc độ bit 'dữ liệu' bổ sung
phải được thiết lập. Tốc độ bit này cho pha dữ liệu của khung CAN FD phải là
ít nhất là tốc độ bit đã được định cấu hình cho giai đoạn phân xử. Cái này
tốc độ bit thứ hai được chỉ định tương tự với tốc độ bit đầu tiên nhưng tốc độ bit
đặt từ khóa cho tốc độ bit 'dữ liệu' bắt đầu bằng 'd', ví dụ: tốc độ,
dsample-point, dsjw hoặc dtq và các cài đặt tương tự. Khi tốc độ bit dữ liệu được đặt
trong quá trình cấu hình, tùy chọn bộ điều khiển "fd on" có thể được
được chỉ định để bật chế độ CAN FD trong bộ điều khiển CAN. Bộ điều khiển này
tùy chọn cũng chuyển thiết bị MTU thành 72 (CANFD_MTU).

Thông số kỹ thuật CAN FD đầu tiên được trình bày dưới dạng sách trắng tại Hội nghị Quốc tế
Hội nghị CAN 2012 cần được cải thiện vì lý do toàn vẹn dữ liệu.
Do đó, ngày nay phải phân biệt hai triển khai CAN FD:

- Tuân thủ ISO: Triển khai ISO 11898-1:2015 CAN FD (mặc định)
- không tuân thủ ISO: Triển khai CAN FD theo sách trắng năm 2012

Cuối cùng, có ba loại bộ điều khiển CAN FD:

1. Tuân thủ ISO (đã sửa)
2. không tuân thủ ISO (đã sửa, như lõi IP M_CAN v3.0.1 trong m_can.c)
3. Bộ điều khiển ISO/không phải ISO CAN FD (có thể chuyển đổi, như PEAK PCAN-USB FD)

Chế độ ISO/không phải ISO hiện tại được trình điều khiển bộ điều khiển CAN công bố thông qua
netlink và được hiển thị bằng công cụ 'ip' (tùy chọn bộ điều khiển FD-NON-ISO).
Có thể thay đổi chế độ ISO/non-ISO bằng cách cài đặt 'fd-non-iso {on|off}' cho
chỉ có bộ điều khiển CAN FD có thể chuyển đổi.

Ví dụ định cấu hình tốc độ bit trọng tài 500 kbit/s và tốc độ bit dữ liệu 4 Mbit/s::

$ ip liên kết thiết lập can0 up loại có thể bitrate 500000 điểm mẫu 0,75 \
                                   dbitrate 4000000 dsample-point 0,8 fd bật
    $ ip -chi tiết link show can0
    5: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 72 qdisc pfifo_fast trạng thái UNKNOWN \
             chế độ mặc định nhóm DEFAULT qlen 10
    liên kết/có thể lăng nhăng 0
    có thể <FD> trạng thái ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
          tốc độ bit 500000 điểm mẫu 0,750
          tq 50 prop-đoạn 14 pha-đoạn1 15 pha-đoạn2 10 sjw 1
          pcan_usb_pro_fd: tseg1 1..64 tseg2 1..16 sjw 1..16 brp 1..1024 \
          brp-inc 1
          dbitrate 4000000 dsample-point 0,800
          dtq 12 dprop-seg 7 dphase-seg1 8 dphase-seg2 4 dsjw 1
          pcan_usb_pro_fd: dtseg1 1..16 dtseg2 1..8 dsjw 1..4 dbrp 1..1024 \
          dbrp-inc 1
          đồng hồ 80000000

Ví dụ khi thêm 'fd-non-iso on' trên bộ chuyển đổi CAN FD có thể chuyển đổi này::

có thể <FD,FD-NON-ISO> trạng thái ERROR-ACTIVE (berr-counter tx 0 rx 0) khởi động lại-ms 0


Bồi thường độ trễ máy phát
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ở tốc độ bit cao, độ trễ truyền từ chân TX đến chân RX của
bộ thu phát có thể trở nên lớn hơn thời gian bit thực tế gây ra
lỗi đo: chân RX vẫn sẽ đo bit trước đó.

Tính năng bù trễ máy phát (sau đó là TDC) giải quyết vấn đề này
bằng cách giới thiệu Điểm mẫu phụ (SSP) bằng khoảng cách, trong
lượng thời gian tối thiểu, từ khi bắt đầu thời gian bit trên chân TX đến
đo thực tế trên chân RX. SSP được tính bằng tổng của hai
các giá trị có thể định cấu hình: Giá trị TDC (TDCV) và giá trị bù TDC (TDCO).

TDC, nếu được thiết bị hỗ trợ, có thể được cấu hình cùng với CAN-FD
sử dụng đối số "tdc-mode" của công cụ ip như sau:

ZZ0000ZZ
	Khi không có tùy chọn "tdc-mode" nào được cung cấp, kernel sẽ tự động
	quyết định xem có nên bật TDC hay không, trong trường hợp đó nó sẽ
	tính toán TDCO mặc định và sử dụng TDCV như được đo bằng
	thiết bị. Đây là phương pháp được khuyến nghị sử dụng TDC.

ZZ0000ZZ
	TDC bị vô hiệu hóa rõ ràng.

ZZ0000ZZ
	Người dùng phải cung cấp đối số "tdco". TDCV sẽ
	được thiết bị tự động tính toán. Tùy chọn này chỉ
	khả dụng nếu thiết bị hỗ trợ chế độ bộ điều khiển TDC-AUTO CAN.

ZZ0000ZZ
	Người dùng phải cung cấp cả đối số "tdco" và "tdcv". Cái này
	tùy chọn chỉ khả dụng nếu thiết bị hỗ trợ TDC-MANUAL CAN
	chế độ điều khiển.

Lưu ý rằng một số thiết bị có thể cung cấp tham số bổ sung: "tdcf" (Bộ lọc TDC
cửa sổ). Nếu được thiết bị của bạn hỗ trợ, điều này có thể được thêm dưới dạng tùy chọn
đối số thành "tdc-mode auto" hoặc "tdc-mode manual".

Ví dụ định cấu hình tốc độ bit trọng tài 500 kbit/s, dữ liệu 5 Mbit/s
tốc độ bit, TDCO có lượng tử thời gian tối thiểu 15 và TDCV được đo tự động
bởi thiết bị::

$ ip link set can0 up loại can bitrate 500000 \
                                   fd trên dbitrate 4000000 \
				   chế độ tdc tự động tdco 15
    $ ip -chi tiết link show can0
    5: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 72 qdisc pfifo_fast trạng thái LÊN \
             chế độ DEFAULT nhóm mặc định qlen 10
        link/can lăng nhăng 0 allmulti 0 minmtu 72 maxmtu 72
        có thể <FD,TDC-AUTO> trạng thái ERROR-ACTIVE khởi động lại-ms 0
          tốc độ bit 500000 điểm mẫu 0,875
          tq 12 prop-seg 69 giai đoạn-seg1 70 giai đoạn-seg2 20 sjw 10 brp 1
          ES582.1/ES584.1: tseg1 2..256 tseg2 2..128 sjw 1..128 brp 1..512 \
          brp_inc 1
          dbitrate 4000000 dsample-point 0,750
          dtq 12 dprop-seg 7 dphase-seg1 7 dphase-seg2 5 dsjw 2 dbrp 1
          tdco 15 tdcf 0
          ES582.1/ES584.1: dtseg1 2..32 dtseg2 1..16 dsjw 1..8 dbrp 1..32 \
          dbrp_inc 1
          tdco 0..127 tdcf 0..127
          đồng hồ 80000000


Phần cứng CAN được hỗ trợ
-------------------------

Vui lòng kiểm tra tệp "Kconfig" trong "drivers/net/can" để có thông tin thực tế
danh sách phần cứng CAN hỗ trợ. Trên trang web của dự án SocketCAN
(xem ZZ0000ZZ) có thể có sẵn các trình điều khiển khác cho
phiên bản hạt nhân cũ hơn.


.. _socketcan-resources:

Tài nguyên socketCAN
====================

Tài nguyên dự án Linux CAN / SocketCAN (trang web dự án / danh sách gửi thư)
được tham chiếu trong tệp MAINTAINERS trong cây nguồn Linux.
Tìm kiếm CAN NETWORK [LAYERS|DRIVERS].

Tín dụng
========

- Oliver Hartkopp (lõi PF_CAN, bộ lọc, trình điều khiển, bcm, trình điều khiển SJA1000)
- Urs Thuermann (lõi PF_CAN, tích hợp kernel, giao diện socket, raw, vcan)
- Jan Kizka (lõi RT-SocketCAN, đối chiếu Socket-API)
- Wolfgang Grandegger (lõi & trình điều khiển RT-SocketCAN, đánh giá Raw Socket-API, giao diện trình điều khiển thiết bị CAN, trình điều khiển MSCAN)
- Robert Schwebel (đánh giá thiết kế, tích hợp PTXdist)
- Marc Kleine-Budde (đánh giá thiết kế, dọn dẹp Kernel 2.6, trình điều khiển)
- Benedikt Spranger (đánh giá)
- Thomas Gleixner (đánh giá LKML, phong cách mã hóa, gợi ý đăng bài)
- Andrey Volkov (cấu trúc cây con hạt nhân, ioctls, trình điều khiển MSCAN)
- Matthias Brukner (triển khai thiết bị mạng SJA1000 CAN đầu tiên vào quý 2/2003)
- Klaus Hitschler (tích hợp trình điều khiển PEAK)
- Uwe Koppe (thiết bị mạng CAN với cách tiếp cận PF_PACKET)
- Michael Schulze (yêu cầu vòng lặp lớp trình điều khiển, đánh giá trình điều khiển RT CAN)
- Pavel Pisa (Tính toán thời gian bit)
- Sascha Hauer (trình điều khiển nền tảng SJA1000)
- Sebastian Haas (Trình điều khiển SJA1000 EMS PCI)
- Markus Plessing (trình điều khiển SJA1000 EMS PCI)
- Per Dalen (trình điều khiển SJA1000 Kvaser PCI)
- Sam Ravnborg (đánh giá, phong cách viết mã, trợ giúp kbuild)
