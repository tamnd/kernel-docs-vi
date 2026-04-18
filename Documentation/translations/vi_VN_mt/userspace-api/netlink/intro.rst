.. SPDX-License-Identifier: BSD-3-Clause

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/netlink/intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Giới thiệu về Netlink
==========================

Netlink thường được mô tả là sự thay thế ioctl().
Nó nhằm mục đích thay thế các cấu trúc C có định dạng cố định như được cung cấp
vào ioctl() với định dạng cho phép dễ dàng thêm
hoặc mở rộng các đối số.

Để đạt được điều này Netlink sử dụng tiêu đề siêu dữ liệu có định dạng cố định tối thiểu
theo sau là nhiều thuộc tính ở định dạng TLV (loại, độ dài, giá trị).

Thật không may, giao thức này đã phát triển qua nhiều năm, theo một cách hữu cơ.
và kiểu cách không có giấy tờ, khiến cho việc giải thích mạch lạc trở nên khó khăn.
Để có ý nghĩa thực tế nhất, tài liệu này bắt đầu bằng cách mô tả
netlink như nó được sử dụng ngày nay và đi sâu vào các cách sử dụng "lịch sử" hơn
ở những phần sau.

Mở một ổ cắm
================

Giao tiếp Netlink diễn ra qua các socket, một socket cần phải được
mở đầu tiên:

.. code-block:: c

  fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);

Việc sử dụng ổ cắm cho phép trao đổi thông tin một cách tự nhiên
theo cả hai hướng (đến và đi từ hạt nhân). Các hoạt động vẫn
được thực hiện đồng bộ khi ứng dụng gửi() yêu cầu nhưng
cần có một cuộc gọi hệ thống recv() riêng biệt để đọc câu trả lời.

Do đó, một luồng "cuộc gọi" Netlink rất đơn giản sẽ có vẻ như
một cái gì đó như:

.. code-block:: c

  fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);

  /* format the request */
  send(fd, &request, sizeof(request));
  n = recv(fd, &response, RSP_BUFFER_SIZE);
  /* interpret the response */

Netlink cũng cung cấp sự hỗ trợ tự nhiên cho việc "bán phá giá", tức là giao tiếp
vào không gian người dùng tất cả các đối tượng thuộc một loại nhất định (ví dụ: kết xuất tất cả các mạng
giao diện).

.. code-block:: c

  fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);

  /* format the dump request */
  send(fd, &request, sizeof(request));
  while (1) {
    n = recv(fd, &buffer, RSP_BUFFER_SIZE);
    /* one recv() call can read multiple messages, hence the loop below */
    for (nl_msg in buffer) {
      if (nl_msg.nlmsg_type == NLMSG_DONE)
        goto dump_finished;
      /* process the object */
    }
  }
  dump_finished:

Hai đối số đầu tiên của lệnh gọi socket() không cần giải thích nhiều -
nó đang mở một ổ cắm Netlink, với tất cả các tiêu đề do người dùng cung cấp
(do đó NETLINK, RAW). Đối số cuối cùng là giao thức trong Netlink.
Trường này được sử dụng để xác định hệ thống con mà socket sẽ
giao tiếp.

Netlink cổ điển và chung
--------------------------

Việc triển khai Netlink ban đầu phụ thuộc vào phân bổ tĩnh
ID cho các hệ thống con và cung cấp rất ít cơ sở hạ tầng hỗ trợ.
Chúng ta hãy gọi chung các giao thức đó là ZZ0001ZZ.
Danh sách chúng được xác định ở trên cùng của ZZ0000ZZ
tệp, chúng bao gồm các tệp khác - mạng chung (NETLINK_ROUTE),
iSCSI (NETLINK_ISCSI) và kiểm toán (NETLINK_AUDIT).

ZZ0000ZZ (được giới thiệu năm 2005) cho phép đăng ký động
hệ thống con (và phân bổ ID hệ thống con), xem xét nội tâm và đơn giản hóa
thực hiện phía kernel của giao diện.

Phần sau đây mô tả cách sử dụng Generic Netlink, làm
số lượng hệ thống con sử dụng Generic Netlink đông hơn hệ thống cũ
các giao thức theo thứ tự độ lớn. Cũng không có kế hoạch bổ sung
nhiều giao thức Netlink cổ điển hơn cho kernel.
Thông tin cơ bản về cách giao tiếp với các bộ phận mạng lõi của
nhân Linux (hoặc một hệ thống con khác trong số 20 hệ thống con sử dụng Classic
Netlink) khác với Netlink chung được cung cấp sau trong tài liệu này.

Liên kết mạng chung
===============

Ngoài tiêu đề siêu dữ liệu cố định Netlink, mỗi giao thức Netlink
xác định tiêu đề siêu dữ liệu cố định của riêng nó. (Tương tự như cách mạng
ngăn xếp tiêu đề - Ethernet > IP > TCP chúng tôi có Netlink > Generic N. > Family.)

Thông báo Netlink luôn bắt đầu bằng struct nlmsghdr, theo sau là
bởi một tiêu đề dành riêng cho giao thức. Trong trường hợp Generic Netlink giao thức
tiêu đề là struct genlmsghdr.

Ý nghĩa thực tế của các trường trong trường hợp Generic Netlink như sau:

.. code-block:: c

  struct nlmsghdr {
	__u32	nlmsg_len;	/* Length of message including headers */
	__u16	nlmsg_type;	/* Generic Netlink Family (subsystem) ID */
	__u16	nlmsg_flags;	/* Flags - request or dump */
	__u32	nlmsg_seq;	/* Sequence number */
	__u32	nlmsg_pid;	/* Port ID, set to 0 */
  };
  struct genlmsghdr {
	__u8	cmd;		/* Command, as defined by the Family */
	__u8	version;	/* Irrelevant, set to 1 */
	__u16	reserved;	/* Reserved, set to 0 */
  };
  /* TLV attributes follow... */

Trong Classic Netlink ZZ0000ZZ dùng để nhận dạng
hoạt động nào trong hệ thống con mà thông báo đang đề cập đến
(ví dụ: lấy thông tin về netdev). Netlink chung cần mux
nhiều hệ thống con trong một giao thức duy nhất nên nó sử dụng trường này để
xác định hệ thống con và ZZ0001ZZ xác định
thay vào đó là hoạt động. (Xem ZZ0002ZZ để biết
thông tin về cách tìm ID gia đình của hệ thống con quan tâm.)
Lưu ý rằng 16 giá trị đầu tiên (0 - 15) của trường này được dành riêng cho
kiểm soát tin nhắn cả trong Classic Netlink và Generic Netlink.
Xem ZZ0003ZZ để biết thêm chi tiết.

Có 3 loại trao đổi tin nhắn thông thường trên ổ cắm Netlink:

- thực hiện một hành động duy nhất (ZZ0000ZZ);
 - thông tin bán phá giá (ZZ0001ZZ);
 - nhận thông báo không đồng bộ (ZZ0002ZZ).

Netlink cổ điển rất linh hoạt và có lẽ cho phép các loại khác
trao đổi xảy ra, nhưng trên thực tế đó là ba điều có được
đã sử dụng.

Thông báo không đồng bộ được gửi bởi kernel và được nhận bởi
ổ cắm người dùng đã đăng ký với chúng. Yêu cầu ZZ0001ZZ và ZZ0002ZZ
được khởi tạo bởi người dùng. ZZ0000ZZ nên
được thiết lập như sau:

-đối với ZZ0000ZZ: ZZ0001ZZ
 -đối với ZZ0002ZZ: ZZ0003ZZ

ZZ0000ZZ phải là một tập hợp đơn điệu
giá trị ngày càng tăng. Giá trị được phản hồi lại trong các phản hồi và không
quan trọng trong thực tế, nhưng đặt nó ở một giá trị ngày càng tăng cho mỗi
tin nhắn được gửi được coi là vệ sinh tốt. Mục đích của lĩnh vực này là
phản hồi phù hợp với yêu cầu. Thông báo không đồng bộ sẽ có
ZZ0001ZZ của ZZ0002ZZ.

ZZ0000ZZ là địa chỉ Netlink tương đương.
Trường này có thể được đặt thành ZZ0002ZZ khi nói chuyện với kernel.
Xem ZZ0001ZZ để biết cách sử dụng (không phổ biến) của trường.

Mục đích sử dụng dự kiến của ZZ0000ZZ là cho phép
phiên bản của các API được cung cấp bởi các hệ thống con. Không có hệ thống con để
ngày đã sử dụng đáng kể trường này, vì vậy việc đặt nó thành ZZ0001ZZ có vẻ
giống như một vụ cá cược an toàn.

.. _nl_msg_type:

Các loại tin nhắn Netlink
---------------------

Như đã đề cập trước đây ZZ0000ZZ mang
các giá trị cụ thể của giao thức nhưng 16 mã định danh đầu tiên được bảo lưu
(loại thông báo cụ thể của hệ thống con đầu tiên phải bằng
ZZ0001ZZ là ZZ0002ZZ).

Chỉ có 4 thông báo điều khiển Netlink được xác định:

- ZZ0000ZZ - bỏ qua tin nhắn, không sử dụng trong thực tế;
 - ZZ0001ZZ - mang mã trả về của một thao tác;
 - ZZ0002ZZ - đánh dấu sự kết thúc của bãi rác;
 - ZZ0003ZZ - bộ đệm ổ cắm đã bị tràn, chưa được sử dụng cho đến nay.

ZZ0000ZZ và ZZ0001ZZ có tầm quan trọng thực tế.
Họ mang theo mã trả lại cho các hoạt động. Lưu ý rằng trừ khi
cờ ZZ0002ZZ được đặt theo yêu cầu Netlink sẽ không phản hồi
với ZZ0003ZZ nếu không có lỗi. Để tránh phải xử lý trường hợp đặc biệt
điều khó hiểu này, bạn nên luôn đặt ZZ0004ZZ.

Định dạng của ZZ0000ZZ được mô tả bởi struct nlmsgerr::

----------------------------------------------
  ZZ0000ZZ
  ----------------------------------------------
  ZZ0001ZZ
  ----------------------------------------------
  ZZ0002ZZ
  ----------------------------------------------
  ZZ0003ZZ
  ----------------------------------------------
  ZZ0004ZZ
  ----------------------------------------------

Có hai trường hợp của struct nlmsghdr ở đây, đầu tiên là phản hồi
và thứ hai của yêu cầu. ZZ0000ZZ mang thông tin về
yêu cầu dẫn đến lỗi. Điều này có thể hữu ích khi cố gắng
để khớp yêu cầu với phản hồi hoặc phân tích lại yêu cầu để chuyển nó vào
nhật ký.

Tải trọng của yêu cầu không được lặp lại trong các thông báo báo cáo thành công
(ZZ0001ZZ) hoặc nếu ZZ0002ZZ setsockopt() đã được đặt.
Cái sau là phổ biến
và có lẽ được khuyến nghị là phải đọc lại bản sao của mọi yêu cầu
từ kernel khá lãng phí. Sự vắng mặt của tải trọng yêu cầu
được biểu thị bằng ZZ0003ZZ trong ZZ0000ZZ.

Phần tử tùy chọn thứ hai của ZZ0002ZZ là ACK mở rộng
thuộc tính. Xem ZZ0000ZZ để biết thêm chi tiết. Sự hiện diện
của ACK mở rộng được biểu thị bằng ZZ0003ZZ trong
ZZ0001ZZ.

ZZ0000ZZ đơn giản hơn, yêu cầu không bao giờ được phản hồi mà được mở rộng
Các thuộc tính ACK có thể có mặt::

----------------------------------------------
  ZZ0000ZZ
  ----------------------------------------------
  ZZ0001ZZ
  ----------------------------------------------
  ZZ0002ZZ
  ----------------------------------------------

Lưu ý rằng một số triển khai có thể đưa ra thông báo ZZ0000ZZ tùy chỉnh
để trả lời các yêu cầu hành động ZZ0001ZZ. Trong trường hợp đó tải trọng là
triển khai cụ thể và cũng có thể không có.

.. _res_fam:

Giải quyết ID gia đình
-----------------------

Phần này giải thích cách tìm ID gia đình của hệ thống con.
Nó cũng phục vụ như một ví dụ về giao tiếp Netlink chung.

Bản thân Generic Netlink là một hệ thống con được hiển thị thông qua Generic Netlink API.
Để tránh sự phụ thuộc vòng tròn Generic Netlink có một phân bổ tĩnh
ID gia đình (ZZ0000ZZ tương đương với ZZ0001ZZ).
Họ Generic Netlink thực hiện một lệnh dùng để tìm hiểu thông tin
về các gia đình khác (ZZ0002ZZ).

Để lấy thông tin về họ Generic Netlink có tên chẳng hạn
ZZ0000ZZ chúng ta cần gửi tin nhắn trên Generic Netlink đã mở trước đó
ổ cắm. Thông báo phải nhắm mục tiêu Dòng Netlink chung (1), là một
ZZ0001ZZ (2) gọi tới ZZ0002ZZ (3). Phiên bản ZZ0003ZZ này
cuộc gọi sẽ làm cho hạt nhân phản hồi với thông tin về các họ ZZ0004ZZ
nó biết về. Cuối cùng nhưng không kém phần quan trọng, tên của gia đình được đề cập có
được chỉ định (4) làm thuộc tính với loại thích hợp::

cấu trúc nlmsghdr:
    __u32 nlmsg_len: 32
    __u16 nlmsg_type: GENL_ID_CTRL // (1)
    __u16 nlmsg_flags: NLM_F_REQUEST | NLM_F_ACK // (2)
    __u32 nlmsg_seq: 1
    __u32 nlmsg_pid: 0

cấu trúc genlmsghdr:
    __u8 cmd: CTRL_CMD_GETFAMILY // (3)
    __u8 phiên bản: 2 /* hoặc 1, không thành vấn đề */
    __u16 dành riêng: 0

cấu trúc nlattr: // (4)
    __u16 nla_len: 10
    __u16 nla_type: CTRL_ATTR_FAMILY_NAME
    dữ liệu char: test1\0

(đệm :)
    dữ liệu char: \0\0

Các trường độ dài trong Netlink (ZZ0000ZZ
và ZZ0001ZZ) luôn là tiêu đề ZZ0004ZZ.
Tiêu đề thuộc tính trong liên kết mạng phải được căn chỉnh thành 4 byte ngay từ đầu
của tin nhắn, do đó có thêm ZZ0002ZZ sau ZZ0003ZZ.
Thuộc tính có độ dài ZZ0005ZZ phần đệm.

Nếu họ tìm thấy kernel sẽ trả lời bằng hai tin nhắn, phản hồi
với tất cả các thông tin về gia đình::

/* Tin nhắn #1 - trả lời */
  cấu trúc nlmsghdr:
    __u32 nlmsg_len: 136
    __u16 nlmsg_type: GENL_ID_CTRL
    __u16 nlmsg_flags: 0
    __u32 nlmsg_seq: 1 /* lặp lại từ yêu cầu của chúng tôi */
    __u32 nlmsg_pid: 5831 /* PID của quy trình không gian người dùng của chúng tôi */

cấu trúc genlmsghdr:
    __u8 cmd: CTRL_CMD_GETFAMILY
    __u8 phiên bản: 2
    __u16 dành riêng: 0

cấu trúc nlattr:
    __u16 nla_len: 10
    __u16 nla_type: CTRL_ATTR_FAMILY_NAME
    dữ liệu char: test1\0

(đệm :)
    dữ liệu: \0\0

cấu trúc nlattr:
    __u16 nla_len: 6
    __u16 nla_type: CTRL_ATTR_FAMILY_ID
    __u16: 123 /* ID gia đình mà chúng tôi đang theo đuổi */

(đệm :)
    dữ liệu char: \0\0

cấu trúc nlattr:
    __u16 nla_len: 9
    __u16 nla_type: CTRL_ATTR_FAMILY_VERSION
    __u16: 1

/* ... vv, nhiều thuộc tính hơn sẽ theo sau. */

Và mã lỗi (thành công) do ZZ0000ZZ đã được đặt theo yêu cầu::

/* Tin nhắn #2 - ACK */
  cấu trúc nlmsghdr:
    __u32 nlmsg_len: 36
    __u16 nlmsg_type: NLMSG_ERROR
    __u16 nlmsg_flags: NLM_F_CAPPED /* Sẽ không có tải trọng */
    __u32 nlmsg_seq: 1 /* lặp lại từ yêu cầu của chúng tôi */
    __u32 nlmsg_pid: 5831 /* PID của quy trình không gian người dùng của chúng tôi */

lỗi int: 0

struct nlmsghdr: /* Bản sao tiêu đề yêu cầu khi chúng tôi gửi nó */
    __u32 nlmsg_len: 32
    __u16 nlmsg_type: GENL_ID_CTRL
    __u16 nlmsg_flags: NLM_F_REQUEST | NLM_F_ACK
    __u32 nlmsg_seq: 1
    __u32 nlmsg_pid: 0

Thứ tự của các thuộc tính (struct nlattr) không được đảm bảo nên người dùng
phải xem xét các thuộc tính và phân tích chúng.

Lưu ý rằng các ổ cắm Netlink chung không được liên kết hoặc ràng buộc với một ổ cắm duy nhất.
gia đình. Một socket có thể được sử dụng để trao đổi tin nhắn với nhiều người khác nhau.
họ, chọn họ người nhận trên cơ sở từng tin nhắn bằng cách sử dụng
trường ZZ0000ZZ.

.. _ext_ack:

ACK mở rộng
------------

Kiểm soát ACK mở rộng báo cáo các TLV lỗi/cảnh báo bổ sung
trong tin nhắn ZZ0000ZZ và ZZ0001ZZ. Để duy trì lạc hậu
khả năng tương thích tính năng này phải được kích hoạt rõ ràng bằng cách cài đặt
ZZ0002ZZ setsockopt() tới ZZ0003ZZ.

Các loại thuộc tính ack mở rộng được xác định trong enum nlmsgerr_attrs.
Các thuộc tính được sử dụng phổ biến nhất là ZZ0000ZZ,
ZZ0001ZZ và ZZ0002ZZ.

ZZ0000ZZ mang thông điệp bằng tiếng Anh mô tả
vấn đề gặp phải. Những tin nhắn này chi tiết hơn nhiều
hơn những gì có thể được thể hiện thông qua mã lỗi UNIX tiêu chuẩn.

ZZ0000ZZ trỏ đến thuộc tính gây ra sự cố.

ZZ0000ZZ và ZZ0001ZZ
thông báo về một thuộc tính bị thiếu.

ACK mở rộng có thể được báo cáo về lỗi cũng như trong trường hợp thành công.
Sau này nên được coi như một cảnh báo.

ACK mở rộng cải thiện đáng kể khả năng sử dụng của Netlink và sẽ
luôn được kích hoạt, phân tích cú pháp và báo cáo phù hợp cho người dùng.

Chủ đề nâng cao
===============

Tính nhất quán của kết xuất
----------------

Một số cấu trúc dữ liệu mà kernel sử dụng để lưu trữ các đối tượng
thật khó để cung cấp một ảnh chụp nhanh nguyên tử của tất cả các đối tượng trong một bãi chứa
(không ảnh hưởng đến các đường dẫn nhanh đang cập nhật chúng).

Hạt nhân có thể đặt cờ ZZ0000ZZ trên bất kỳ tin nhắn nào trong kết xuất
(bao gồm thông báo ZZ0001ZZ) nếu kết xuất bị gián đoạn và
có thể không nhất quán (ví dụ: thiếu đồ vật). Không gian người dùng nên thử lại
bãi chứa nếu nó thấy cờ được đặt.

Xem xét nội tâm
-------------

Khả năng xem xét nội tâm cơ bản được kích hoạt bằng cách truy cập vào Gia đình
đối tượng như được báo cáo trong ZZ0000ZZ. Người dùng có thể truy vấn thông tin về
dòng Generic Netlink, bao gồm những hoạt động nào được hỗ trợ
bởi kernel và những thuộc tính mà kernel hiểu được.
Thông tin họ bao gồm ID cao nhất của hạt nhân thuộc tính có thể phân tích cú pháp,
một lệnh riêng biệt (ZZ0001ZZ) cung cấp thông tin chi tiết
về các thuộc tính được hỗ trợ, bao gồm phạm vi giá trị mà kernel chấp nhận.

Truy vấn thông tin gia đình rất hữu ích trong trường hợp người dùng cần không gian
để đảm bảo rằng kernel có hỗ trợ một tính năng trước khi phát hành
một yêu cầu.

.. _nlmsg_pid:

nlmsg_pid
---------

ZZ0000ZZ là địa chỉ Netlink tương đương.
Nó được gọi là ID cổng, đôi khi là ID tiến trình vì đối với lịch sử
lý do nếu ứng dụng không chọn (liên kết() với) ID cổng rõ ràng
kernel sẽ tự động gán cho nó ID bằng ID tiến trình của nó
(như được báo cáo bởi lệnh gọi hệ thống getpid()).

Tương tự như ngữ nghĩa bind() của giao thức mạng TCP/IP, giá trị
bằng 0 có nghĩa là "gán tự động", do đó nó phổ biến đối với các ứng dụng
để rời khỏi trường ZZ0000ZZ được khởi tạo thành ZZ0001ZZ.

Trường này vẫn được sử dụng cho đến ngày nay trong những trường hợp hiếm hoi khi kernel cần gửi
một thông báo unicast. Ứng dụng không gian người dùng có thể sử dụng bind() để liên kết
socket của nó với một PID cụ thể, sau đó nó truyền PID của nó tới kernel.
Bằng cách này, kernel có thể tiếp cận quy trình không gian người dùng cụ thể.

Kiểu giao tiếp này được sử dụng giống như UMH (Trình trợ giúp chế độ người dùng)
các tình huống khi kernel cần kích hoạt xử lý không gian người dùng hoặc yêu cầu người dùng
không gian cho một quyết định chính sách.

Thông báo đa phương tiện
-----------------------

Một trong những điểm mạnh của Netlink là khả năng gửi thông báo sự kiện
tới không gian người dùng. Đây là một hình thức giao tiếp một chiều (kernel ->
người dùng) và không liên quan đến bất kỳ thông báo điều khiển nào như ZZ0000ZZ hoặc
ZZ0001ZZ.

Ví dụ, chính họ Generic Netlink xác định một tập hợp các địa chỉ multicast
thông báo về các gia đình đã đăng ký. Khi một họ mới được thêm vào
ổ cắm đã đăng ký nhận thông báo sẽ nhận được thông báo sau ::

cấu trúc nlmsghdr:
    __u32 nlmsg_len: 136
    __u16 nlmsg_type: GENL_ID_CTRL
    __u16 nlmsg_flags: 0
    __u32 nlmsg_seq: 0
    __u32 nlmsg_pid: 0

cấu trúc genlmsghdr:
    __u8 cmd: CTRL_CMD_NEWFAMILY
    __u8 phiên bản: 2
    __u16 dành riêng: 0

cấu trúc nlattr:
    __u16 nla_len: 10
    __u16 nla_type: CTRL_ATTR_FAMILY_NAME
    dữ liệu char: test1\0

(đệm :)
    dữ liệu: \0\0

cấu trúc nlattr:
    __u16 nla_len: 6
    __u16 nla_type: CTRL_ATTR_FAMILY_ID
    __u16: 123 /* ID gia đình mà chúng tôi đang theo đuổi */

(đệm :)
    dữ liệu char: \0\0

cấu trúc nlattr:
    __u16 nla_len: 9
    __u16 nla_type: CTRL_ATTR_FAMILY_VERSION
    __u16: 1

/* ... vv, nhiều thuộc tính hơn sẽ theo sau. */

Thông báo chứa thông tin giống như phản hồi
theo yêu cầu ZZ0000ZZ.

Tiêu đề Netlink của thông báo hầu hết là 0 và không liên quan.
ZZ0000ZZ có thể bằng 0 hoặc đơn điệu
tăng số thứ tự thông báo được duy trì bởi gia đình.

Để nhận được thông báo, socket người dùng phải đăng ký các thông tin liên quan
nhóm thông báo Giống như ID gia đình, ID nhóm cho một
nhóm multicast rất năng động và có thể được tìm thấy trong thông tin Gia đình.
Thuộc tính ZZ0000ZZ chứa các tổ có tên
(ZZ0001ZZ) và ID (ZZ0002ZZ) của
gia đình nhóm.

Khi ID nhóm được biết, lệnh gọi setsockopt() sẽ thêm ổ cắm vào nhóm:

.. code-block:: c

  unsigned int group_id;

  /* .. find the group ID... */

  setsockopt(fd, SOL_NETLINK, NETLINK_ADD_MEMBERSHIP,
             &group_id, sizeof(group_id));

Ổ cắm bây giờ sẽ nhận được thông báo.

Nên sử dụng ổ cắm riêng để nhận thông báo
và gửi yêu cầu đến kernel. Bản chất không đồng bộ của thông báo
có nghĩa là chúng có thể bị lẫn lộn với những câu trả lời tạo nên thông điệp
xử lý khó khăn hơn nhiều.

Kích thước bộ đệm
-------------

Ổ cắm Netlink là ổ cắm datagram chứ không phải ổ cắm luồng,
nghĩa là mỗi tin nhắn phải được nhận toàn bộ bởi một
lệnh gọi hệ thống recv()/recvmsg(). Nếu bộ đệm do người dùng cung cấp quá
ngắn, tin nhắn sẽ bị cắt bớt và cờ ZZ0000ZZ được đặt
trong struct msghdr (struct msghdr là đối số thứ hai
của lệnh gọi hệ thống recvmsg(), ZZ0001ZZ là tiêu đề Netlink).

Sau khi cắt bớt phần còn lại của tin nhắn sẽ bị loại bỏ.

Netlink mong muốn bộ đệm người dùng sẽ có ít nhất 8kB hoặc một trang
kích thước của kiến trúc CPU, tùy theo kích thước nào lớn hơn. Liên kết mạng cụ thể
Tuy nhiên, các gia đình có thể yêu cầu vùng đệm lớn hơn. Nên sử dụng bộ đệm 32kB
để xử lý các bãi chứa hiệu quả nhất (bộ đệm lớn hơn phù hợp với nhiều bãi chứa hơn
đối tượng và do đó cần ít lệnh gọi recvmsg() hơn).

.. _classic_netlink:

Liên kết mạng cổ điển
===============

Sự khác biệt chính giữa Netlink cổ điển và chung là tính năng động
phân bổ các mã định danh hệ thống con và tính khả dụng của việc xem xét nội tâm.
Về lý thuyết, giao thức không khác biệt đáng kể, tuy nhiên, trên thực tế
Netlink cổ điển đã thử nghiệm các khái niệm đã bị loại bỏ trong Generic
Netlink (thực sự thì chúng thường chỉ được sử dụng ở một góc nhỏ của một
hệ thống con). Phần này nhằm mục đích giải thích một số khái niệm như vậy,
với mục tiêu rõ ràng là cung cấp Generic Netlink
người dùng tự tin bỏ qua chúng khi đọc các tiêu đề uAPI.

Hầu hết các khái niệm và ví dụ ở đây đều đề cập đến họ ZZ0000ZZ,
bao gồm phần lớn cấu hình của ngăn xếp mạng Linux.
Tài liệu thực sự của gia đình đó xứng đáng có một chương (hoặc một cuốn sách) riêng.

Gia đình
--------

Netlink coi các hệ thống con là các hệ thống gia đình. Đây là tàn dư của việc sử dụng
socket và khái niệm về họ giao thức, là một phần của thông điệp
tách kênh trong ZZ0000ZZ.

Đáng buồn thay, mọi lớp đóng gói đều thích đề cập đến bất cứ thứ gì nó mang theo
là "gia đình" làm cho thuật ngữ này trở nên rất khó hiểu:

1. AF_NETLINK là họ giao thức socket thực sự
 2. Tài liệu của AF_NETLINK đề cập đến những gì xảy ra sau tài liệu của chính nó
    tiêu đề (struct nlmsghdr) trong tin nhắn dưới dạng "Tiêu đề gia đình"
 3. Netlink chung là họ của AF_NETLINK (struct genlmsghdr theo sau
    struct nlmsghdr), nhưng nó cũng gọi người dùng của mình là "Gia đình".

Lưu ý rằng ID nhóm Netlink chung nằm trong một "không gian ID" khác
và trùng lặp với các số giao thức Netlink cổ điển (ví dụ: ZZ0000ZZ
có ID giao thức Netlink cổ điển là 21 mà Netlink chung sẽ
vui vẻ phân bổ cho một trong các họ của nó).

Kiểm tra nghiêm ngặt
---------------

Tùy chọn ổ cắm ZZ0000ZZ cho phép kiểm tra đầu vào nghiêm ngặt
trong ZZ0001ZZ. Nó cần thiết vì trong lịch sử kernel không
xác thực các trường cấu trúc mà nó không xử lý. Điều này đã làm cho nó không thể
để bắt đầu sử dụng các trường đó sau này mà không gặp phải rủi ro hồi quy trong ứng dụng
đã khởi tạo chúng không chính xác hoặc không hề khởi tạo chúng.

ZZ0000ZZ tuyên bố rằng ứng dụng đang khởi chạy
tất cả các trường một cách chính xác. Nó cũng chọn tham gia xác nhận thông báo đó không
chứa dữ liệu theo dõi và yêu cầu kernel từ chối các thuộc tính với
loại cao hơn loại thuộc tính lớn nhất được biết đến trong kernel.

ZZ0000ZZ không được sử dụng bên ngoài ZZ0001ZZ.

Thuộc tính không xác định
------------------

Về mặt lịch sử, Netlink đã bỏ qua tất cả các thuộc tính chưa biết. Suy nghĩ đó là
nó sẽ giải phóng ứng dụng khỏi việc phải thăm dò xem kernel nào hỗ trợ.
Ứng dụng có thể đưa ra yêu cầu thay đổi trạng thái và kiểm tra trạng thái nào
các phần của yêu cầu "bị kẹt".

Điều này không còn xảy ra đối với các dòng Generic Netlink mới và những người chọn
vào kiểm tra nghiêm ngặt. Xem enum netlink_validation để biết các loại xác thực
được thực hiện.

Đã sửa lỗi siêu dữ liệu và cấu trúc
-----------------------------

Netlink cổ điển đã sử dụng tự do các cấu trúc có định dạng cố định bên trong
những tin nhắn. Tin nhắn thường có cấu trúc với
một số lượng đáng kể các trường sau struct nlmsghdr. Nó cũng đã
phổ biến để đặt các cấu trúc có nhiều thành viên bên trong các thuộc tính,
mà không chia mỗi thành viên thành một thuộc tính riêng.

Điều này đã gây ra vấn đề với việc xác nhận và mở rộng và
do đó việc sử dụng cấu trúc nhị phân không được khuyến khích cho các cấu trúc mới
thuộc tính.

Các loại yêu cầu
-------------

ZZ0000ZZ phân loại yêu cầu thành 4 loại ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
và ZZ0004ZZ. Mỗi đối tượng có thể xử lý tất cả hoặc một số yêu cầu đó
(đối tượng là netdev, tuyến đường, địa chỉ, qdiscs, v.v.) Loại yêu cầu
được xác định bởi 2 bit thấp nhất của loại thông báo, vì vậy các lệnh dành cho
các đối tượng mới sẽ luôn được phân bổ với bước tiến là 4.

Mỗi đối tượng cũng sẽ có siêu dữ liệu cố định riêng được chia sẻ bởi tất cả các yêu cầu
các loại (ví dụ: struct ifinfomsg cho các yêu cầu netdev, struct ifaddrmsg cho địa chỉ
yêu cầu, struct tcmsg cho các yêu cầu qdisc).

Mặc dù các giao thức khác và các lệnh Netlink chung thường sử dụng
các động từ giống nhau trong tên thông điệp của chúng (ZZ0000ZZ, ZZ0001ZZ) khái niệm
trong số các loại yêu cầu không được áp dụng rộng rãi hơn.

Tiếng vang thông báo
-----------------

ZZ0000ZZ yêu cầu thông báo phát sinh từ yêu cầu
được xếp hàng vào socket yêu cầu. Điều này rất hữu ích để khám phá
tác động của yêu cầu.

Lưu ý rằng tính năng này không được triển khai phổ biến.

Các cờ dành riêng cho loại yêu cầu khác
---------------------------------

Classic Netlink đã xác định các cờ khác nhau cho ZZ0000ZZ, ZZ0001ZZ của nó
và các yêu cầu ZZ0002ZZ ở byte trên của nlmsg_flags trong struct nlmsghdr.
Vì các loại yêu cầu chưa được khái quát nên loại yêu cầu cụ thể
cờ hiếm khi được sử dụng (và được coi là không dùng nữa đối với các dòng mới).

Đối với ZZ0000ZZ - ZZ0001ZZ và ZZ0002ZZ được kết hợp thành
ZZ0003ZZ và không được sử dụng riêng. ZZ0004ZZ không bao giờ được sử dụng.

Đối với ZZ0000ZZ - ZZ0001ZZ chỉ được sử dụng bởi nftables và ZZ0002ZZ
chỉ bằng FDB một số thao tác.

Cờ cho ZZ0000ZZ được sử dụng phổ biến nhất trong Netlink cổ điển. Thật không may,
ý nghĩa không rõ ràng. Mô tả sau đây dựa trên
đoán tốt nhất về ý định của tác giả và trên thực tế tất cả các gia đình
đi lạc khỏi nó bằng cách này hay cách khác. ZZ0001ZZ yêu cầu thay thế
một đối tượng hiện có, nếu không có đối tượng phù hợp thì thao tác sẽ thất bại.
ZZ0002ZZ có ngữ nghĩa ngược lại và chỉ thành công nếu đối tượng đã có
đã tồn tại.
ZZ0003ZZ yêu cầu tạo đối tượng nếu không
tồn tại, nó có thể được kết hợp với ZZ0004ZZ và ZZ0005ZZ.

Một nhận xét trong tiêu đề Netlink uAPI chính nêu rõ::

4.4BSD ADD NLM_F_CREATE|NLM_F_EXCL
   4.4BSD CHANGE NLM_F_REPLACE

Đúng CHANGE NLM_F_CREATE|NLM_F_REPLACE
   Nối NLM_F_CREATE
   Kiểm tra NLM_F_EXCL

điều này dường như chỉ ra rằng những lá cờ đó có trước các loại yêu cầu.
ZZ0000ZZ không có ZZ0001ZZ ban đầu được sử dụng thay thế
của các lệnh ZZ0002ZZ.
ZZ0003ZZ không có ZZ0004ZZ được sử dụng để kiểm tra xem đối tượng có tồn tại không
mà không tạo ra nó, có lẽ là có trước các lệnh ZZ0005ZZ.

ZZ0000ZZ chỉ ra rằng nếu một khóa có thể liên kết nhiều đối tượng
với nó (ví dụ: nhiều đối tượng bước nhảy tiếp theo cho một tuyến đường), đối tượng mới sẽ là
thêm vào danh sách thay vì thay thế toàn bộ danh sách.

tham chiếu uAPI
==============

.. kernel-doc:: include/uapi/linux/netlink.h