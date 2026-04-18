.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/mctp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Giao thức truyền tải thành phần quản lý (MCTP)
==================================================

net/mctp/ chứa hỗ trợ giao thức cho MCTP, như được xác định bởi tiêu chuẩn DMTF
DSP0236. Trình điều khiển giao diện vật lý ("ràng buộc" trong thông số kỹ thuật) là
được cung cấp trong driver/net/mctp/.

Mã lõi cung cấp giao diện dựa trên socket để gửi và nhận MCTP
tin nhắn, thông qua ổ cắm AF_MCTP, SOCK_DGRAM.

Cấu trúc: giao diện & mạng
================================

Hạt nhân mô hình hóa cấu trúc liên kết MCTP cục bộ thông qua hai mục: giao diện và
mạng.

Giao diện (hoặc "liên kết") là một phiên bản của ràng buộc vận chuyển vật lý MCTP
(như được định nghĩa bởi DSP0236, phần 3.2.47), có thể được kết nối với một phần cứng cụ thể
thiết bị. Điều này được thể hiện dưới dạng ZZ0000ZZ.

Mạng xác định không gian địa chỉ duy nhất cho điểm cuối MCTP theo ID điểm cuối
(được mô tả bởi DSP0236, phần 3.2.31). Mạng có mã định danh mà người dùng có thể nhìn thấy
để cho phép tham chiếu từ không gian người dùng. Định nghĩa tuyến đường dành riêng cho một
mạng.

Các giao diện được liên kết với một mạng. Một mạng có thể được liên kết với một
hoặc nhiều giao diện.

Nếu có nhiều mạng, mỗi mạng có thể chứa ID điểm cuối (EID)
cũng có mặt trên các mạng khác.

Ổ cắm API
===========

Định nghĩa giao thức
--------------------

MCTP sử dụng ZZ0000ZZ / ZZ0001ZZ cho họ địa chỉ và giao thức.
Vì MCTP dựa trên tin nhắn nên chỉ hỗ trợ ổ cắm ZZ0002ZZ.

.. code-block:: C

    int sd = socket(AF_MCTP, SOCK_DGRAM, 0);

Giá trị (hiện tại) duy nhất cho đối số ZZ0000ZZ là 0.

Giống như tất cả các họ địa chỉ socket, địa chỉ nguồn và đích là
được chỉ định bằng loại ZZ0000ZZ, với địa chỉ điểm cuối một byte:

.. code-block:: C

    typedef __u8		mctp_eid_t;

    struct mctp_addr {
            mctp_eid_t		s_addr;
    };

    struct sockaddr_mctp {
            __kernel_sa_family_t smctp_family;
            unsigned int         smctp_network;
            struct mctp_addr     smctp_addr;
            __u8                 smctp_type;
            __u8                 smctp_tag;
    };

    #define MCTP_NET_ANY	0x0
    #define MCTP_ADDR_ANY	0xff


Hành vi tòa nhà
-----------------

Các phần sau đây mô tả các hành vi dành riêng cho MCTP của tiêu chuẩn
các cuộc gọi hệ thống socket. Những hành vi này đã được lựa chọn để liên kết chặt chẽ với
API ổ cắm hiện có.

ZZ0000ZZ: đặt địa chỉ ổ cắm cục bộ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các ổ cắm nhận gói yêu cầu đến sẽ liên kết với một địa chỉ cục bộ,
bằng cách sử dụng tòa nhà cao tầng ZZ0000ZZ.

.. code-block:: C

    struct sockaddr_mctp addr;

    addr.smctp_family = AF_MCTP;
    addr.smctp_network = MCTP_NET_ANY;
    addr.smctp_addr.s_addr = MCTP_ADDR_ANY;
    addr.smctp_type = MCTP_TYPE_PLDM;
    addr.smctp_tag = MCTP_TAG_OWNER;

    int rc = bind(sd, (struct sockaddr *)&addr, sizeof(addr));

Điều này thiết lập địa chỉ cục bộ của ổ cắm. Tin nhắn MCTP đến
khớp với mạng, địa chỉ và loại tin nhắn sẽ được ổ cắm này nhận.
Ở đây việc đề cập đến 'đến' rất quan trọng; một ổ cắm bị ràng buộc sẽ chỉ nhận được
các thông báo có tập bit TO, để biểu thị một thông báo yêu cầu đến, thay vào đó
hơn là một phản hồi.

Giá trị ZZ0000ZZ sẽ định cấu hình các thẻ được chấp nhận từ phía xa của
ổ cắm này. Với những điều trên, giá trị hợp lệ duy nhất là ZZ0001ZZ, giá trị này
sẽ dẫn đến việc các thẻ "sở hữu" từ xa được định tuyến đến ổ cắm này. Kể từ khi
ZZ0002ZZ được thiết lập, 3 bit có trọng số nhỏ nhất của ZZ0003ZZ không được thiết lập
đã sử dụng; người gọi phải đặt chúng về 0.

Giá trị ZZ0000ZZ của ZZ0001ZZ sẽ định cấu hình ổ cắm thành
nhận các gói đến từ bất kỳ mạng kết nối cục bộ nào. Một mạng cụ thể
value sẽ khiến ổ cắm chỉ nhận tin nhắn đến từ mạng đó.

Trường ZZ0000ZZ chỉ định một địa chỉ cục bộ để liên kết. Một giá trị của
ZZ0001ZZ định cấu hình ổ cắm để nhận tin nhắn được gửi đến bất kỳ
điểm đến địa phương EID.

Trường ZZ0000ZZ chỉ định loại tin nhắn nào sẽ nhận. Chỉ có
7 bit thấp hơn của loại này được khớp với các tin nhắn đến (ví dụ:
Bit IC quan trọng nhất không phải là một phần của kết quả trùng khớp). Điều này dẫn đến ổ cắm
nhận các gói có và không có chân trang kiểm tra tính toàn vẹn của tin nhắn.

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ : truyền tin nhắn MCTP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Một tin nhắn MCTP được truyền bằng một trong các ZZ0000ZZ, ZZ0001ZZ hoặc
Tòa nhà cao tầng ZZ0002ZZ. Sử dụng ZZ0003ZZ làm ví dụ chính:

.. code-block:: C

    struct sockaddr_mctp addr;
    char buf[14];
    ssize_t len;

    /* set message destination */
    addr.smctp_family = AF_MCTP;
    addr.smctp_network = 0;
    addr.smctp_addr.s_addr = 8;
    addr.smctp_tag = MCTP_TAG_OWNER;
    addr.smctp_type = MCTP_TYPE_ECHO;

    /* arbitrary message to send, with message-type header */
    buf[0] = MCTP_TYPE_ECHO;
    memcpy(buf + 1, "hello, world!", sizeof(buf) - 1);

    len = sendto(sd, buf, sizeof(buf), 0,
                    (struct sockaddr_mctp *)&addr, sizeof(addr));

Các trường mạng và địa chỉ của ZZ0000ZZ xác định địa chỉ từ xa để gửi tới.
Nếu ZZ0001ZZ có ZZ0002ZZ, kernel sẽ bỏ qua mọi bit được đặt
trong ZZ0003ZZ và tạo giá trị thẻ phù hợp cho đích
EID. Nếu ZZ0004ZZ không được đặt, tin nhắn sẽ được gửi cùng với thẻ
giá trị như đã chỉ định. Nếu giá trị thẻ không thể được phân bổ, lệnh gọi hệ thống sẽ
báo cáo lỗi của ZZ0005ZZ.

Ứng dụng phải cung cấp byte loại thông báo làm byte đầu tiên của
bộ đệm tin nhắn được chuyển tới ZZ0000ZZ. Nếu việc kiểm tra tính toàn vẹn của tin nhắn được thực hiện
có trong tin nhắn được truyền đi thì nó cũng phải được cung cấp trong tin nhắn
đệm và bit có ý nghĩa nhất của byte loại thông báo phải là 1.

Lệnh gọi hệ thống ZZ0000ZZ cho phép giao diện đối số nhỏ gọn hơn và
bộ đệm thông báo được chỉ định làm danh sách thu thập phân tán. Hiện tại chưa có phụ kiện
các loại thông báo (được sử dụng cho dữ liệu ZZ0001ZZ được truyền tới ZZ0002ZZ) là
được xác định.

Truyền tin nhắn trên ổ cắm chưa được kết nối với ZZ0000ZZ
được chỉ định sẽ gây ra sự phân bổ thẻ, nếu chưa có thẻ hợp lệ
được phân bổ cho đích đó. Bộ dữ liệu (destination-eid,tag) hoạt động như một
địa chỉ ổ cắm cục bộ ẩn, để cho phép ổ cắm nhận phản hồi về điều này
tin nhắn gửi đi. Nếu bất kỳ sự phân bổ nào trước đó đã được thực hiện (cho một
khác với EID từ xa), sự phân bổ đó sẽ bị mất.

Ổ cắm sẽ chỉ nhận được phản hồi cho các yêu cầu mà chúng đã gửi (với TO=1) và
chỉ có thể phản hồi (với TO=0) đối với các yêu cầu mà họ đã nhận được.

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ : nhận tin nhắn MCTP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ứng dụng có thể nhận được tin nhắn MCTP bằng cách sử dụng một trong các
Cuộc gọi hệ thống ZZ0000ZZ, ZZ0001ZZ hoặc ZZ0002ZZ. Sử dụng ZZ0003ZZ
như ví dụ chính:

.. code-block:: C

    struct sockaddr_mctp addr;
    socklen_t addrlen;
    char buf[14];
    ssize_t len;

    addrlen = sizeof(addr);

    len = recvfrom(sd, buf, sizeof(buf), 0,
                    (struct sockaddr_mctp *)&addr, &addrlen);

    /* We can expect addr to describe an MCTP address */
    assert(addrlen >= sizeof(buf));
    assert(addr.smctp_family == AF_MCTP);

    printf("received %zd bytes from remote EID %d\n", rc, addr.smctp_addr);

Đối số địa chỉ cho ZZ0000ZZ và ZZ0001ZZ được điền bằng
địa chỉ từ xa của tin nhắn đến, bao gồm giá trị thẻ (điều này sẽ cần thiết
để trả lời tin nhắn).

Byte đầu tiên của bộ đệm thông báo sẽ chứa byte loại thông báo. Nếu một
kiểm tra tính toàn vẹn theo sau thông báo, nó sẽ được đưa vào bộ đệm nhận được.

Lệnh gọi hệ thống ZZ0000ZZ hoạt động theo cách tương tự nhưng không cung cấp
địa chỉ từ xa tới ứng dụng. Vì vậy, những điều này chỉ hữu ích nếu
địa chỉ từ xa đã được biết hoặc tin nhắn không yêu cầu trả lời.

Giống như lệnh gửi, socket sẽ chỉ nhận được phản hồi cho các yêu cầu mà chúng có
đã gửi (TO=1) và chỉ có thể trả lời (TO=0) những yêu cầu mà họ đã nhận được.

ZZ0000ZZ và ZZ0001ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các thẻ này cung cấp cho ứng dụng nhiều quyền kiểm soát hơn đối với thẻ thông báo MCTP, bằng cách phân bổ
(và loại bỏ) các giá trị thẻ một cách rõ ràng, thay vì hạt nhân tự động
phân bổ thẻ cho mỗi tin nhắn vào thời điểm ZZ0000ZZ.

Nói chung, bạn sẽ chỉ cần sử dụng các ioctls này nếu giao thức MCTP của bạn thực hiện
không phù hợp với mô hình yêu cầu/phản hồi thông thường. Ví dụ, nếu bạn cần kiên trì
gắn thẻ trên nhiều yêu cầu hoặc một yêu cầu có thể tạo ra nhiều phản hồi.
Trong những trường hợp này, ioctls cho phép bạn tách phân bổ thẻ (và
Release) từ các hoạt động gửi và nhận tin nhắn riêng lẻ.

Cả hai ioctls đều được chuyển một con trỏ tới ZZ0000ZZ:

.. code-block:: C

    struct mctp_ioc_tag_ctl {
        mctp_eid_t      peer_addr;
        __u8		tag;
        __u16   	flags;
    };

ZZ0000ZZ phân bổ một thẻ cho một thiết bị ngang hàng cụ thể mà một ứng dụng
có thể sử dụng trong các cuộc gọi ZZ0001ZZ trong tương lai. Ứng dụng này chứa các
Thành viên ZZ0002ZZ với điều khiển từ xa EID. Các trường khác phải bằng 0.

Khi trả lại, thành viên ZZ0000ZZ sẽ được điền giá trị thẻ được phân bổ.
Thẻ được phân bổ sẽ có các bit thẻ được đặt sau:

- ZZ0000ZZ: việc phân bổ thẻ chỉ có ý nghĩa nếu bạn là thẻ
   chủ sở hữu

- ZZ0000ZZ: để cho ZZ0001ZZ biết rằng đây là
   thẻ được phân bổ trước.

- ... và giá trị thẻ thực tế, trong phạm vi ba bit có ý nghĩa nhỏ nhất
   (ZZ0000ZZ). Lưu ý rằng số 0 là giá trị thẻ hợp lệ.

Giá trị thẻ phải được sử dụng nguyên trạng cho thành viên ZZ0000ZZ của ZZ0001ZZ.

ZZ0000ZZ phát hành một thẻ đã được phân bổ trước đó bởi một
ZZ0001ZZ ioctl. ZZ0002ZZ phải giống như được sử dụng cho
phân bổ và giá trị ZZ0003ZZ phải khớp chính xác với thẻ được trả về từ
phân bổ (bao gồm các bit ZZ0004ZZ và ZZ0005ZZ).
Trường ZZ0006ZZ phải bằng 0.

Bên trong hạt nhân
==================

Có một số luồng gói có thể có trong ngăn xếp MCTP:

1. TX cục bộ đến điểm cuối từ xa, tin nhắn <= MTU::

gửi tin nhắn()
	 -> mctp_local_output()
	    : tra cứu tuyến đường
	    -> rt->output() (== mctp_route_output)
	       -> dev_queue_xmit()

2. TX cục bộ đến điểm cuối từ xa, tin nhắn > MTU::

gửi tin nhắn()
	-> mctp_local_output()
	    -> mctp_do_fragment_route()
	       : tạo skbs có kích thước gói. Đối với mỗi skb mới:
	       -> rt->output() (== mctp_route_output)
	          -> dev_queue_xmit()

3. TX từ xa đến điểm cuối cục bộ, tin nhắn gói đơn::

mctp_pkttype_receive()
	: tra cứu tuyến đường
	-> rt->output() (== mctp_route_input)
	   : tra cứu sk_key
	   -> sock_queue_rcv_skb()

4. TX từ xa đến điểm cuối cục bộ, tin nhắn nhiều gói::

mctp_pkttype_receive()
	: tra cứu tuyến đường
	-> rt->output() (== mctp_route_input)
	   : tra cứu sk_key
	   : lưu trữ skb trong struct sk_key->reasm_head

mctp_pkttype_receive()
	: tra cứu tuyến đường
	-> rt->output() (== mctp_route_input)
	   : tra cứu sk_key
	   : tìm tập hợp lại hiện có trong sk_key->reasm_head
	   : nối thêm đoạn mới
	   -> sock_queue_rcv_skb()

Hoàn tiền chính
---------------

* phím được giới thiệu bởi:

- một skb: trong quá trình xuất tuyến, được lưu trong ZZ0000ZZ.

- lưới và danh sách tất.

* các phím có thể được liên kết với một thiết bị, trong trường hợp đó chúng chứa một
   tham chiếu đến nhà phát triển (được đặt qua ZZ0000ZZ, được tính qua
   ZZ0001ZZ). Nhiều phím có thể tham chiếu thiết bị.