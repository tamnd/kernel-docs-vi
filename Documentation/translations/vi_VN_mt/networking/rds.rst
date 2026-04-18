.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/rds.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===
RDS
===

Tổng quan
========

Bài đọc này cố gắng cung cấp một số thông tin cơ bản về cách thức và lý do của RDS,
và hy vọng sẽ giúp bạn tìm ra cách giải mã.

Ngoài ra, vui lòng xem email này về nguồn gốc RDS:
ZZ0000ZZ

Kiến trúc RDS
================

RDS cung cấp khả năng phân phối datagram theo thứ tự, đáng tin cậy bằng cách sử dụng một
kết nối đáng tin cậy giữa hai nút bất kỳ trong cụm. Điều này cho phép
các ứng dụng sử dụng một ổ cắm duy nhất để giao tiếp với bất kỳ quy trình nào khác trong
cụm - vì vậy, trong một cụm có N quy trình, bạn cần N ổ cắm, ngược lại
đến N*N nếu bạn sử dụng phương thức vận chuyển ổ cắm hướng kết nối như TCP.

RDS không dành riêng cho Infiniband; nó được thiết kế để hỗ trợ khác nhau
vận chuyển.  Việc triển khai hiện tại cũng được sử dụng để hỗ trợ RDS trên TCP
như IB.

Ngữ nghĩa cấp cao của RDS theo quan điểm của ứng dụng là

* Địa chỉ

RDS sử dụng địa chỉ IPv4 và số cổng 16bit để xác định
	điểm cuối của một kết nối. Tất cả các hoạt động socket liên quan đến
	truyền địa chỉ giữa kernel và không gian người dùng nói chung
	sử dụng cấu trúc sockaddr_in.

Việc sử dụng địa chỉ IPv4 không có nghĩa là ý nghĩa cơ bản
	truyền tải phải dựa trên IP. Trên thực tế, RDS trên IB sử dụng
	kết nối IB đáng tin cậy; địa chỉ IP được sử dụng riêng để
	xác định vị trí GID của nút từ xa (bằng ARPing cho IP đã cho).

Không gian cổng hoàn toàn độc lập với UDP, TCP hoặc bất kỳ cổng nào khác
	giao thức.

* Giao diện ổ cắm

Ổ cắm RDS hoạt động ZZ0000ZZ như bạn mong đợi từ BSD
	ổ cắm. Phần tiếp theo sẽ đề cập đến các chi tiết. Dù sao đi nữa,
	tất cả I/O được thực hiện thông qua ổ cắm BSD tiêu chuẩn API.
	Một số bổ sung như hỗ trợ zerocopy được triển khai thông qua
	kiểm soát tin nhắn, trong khi các tiện ích mở rộng khác sử dụng getsockopt/
	setsockopt cuộc gọi.

Ổ cắm phải được ràng buộc trước khi bạn có thể gửi hoặc nhận dữ liệu.
	Điều này là cần thiết vì việc liên kết cũng chọn một phương thức vận chuyển và
	gắn nó vào ổ cắm. Sau khi bị ràng buộc, nhiệm vụ vận chuyển
	không thay đổi. RDS sẽ cho phép các IP di chuyển xung quanh (ví dụ: trong
	một kịch bản HA đang hoạt động), nhưng chỉ miễn là địa chỉ
	không chuyển sang phương tiện giao thông khác.

* hệ thống

RDS hỗ trợ một số sysctls trong /proc/sys/net/rds


Giao diện ổ cắm
================

AF_RDS, PF_RDS, SOL_RDS
	AF_RDS và PF_RDS là loại miền được sử dụng với socket(2)
	để tạo ổ cắm RDS. SOL_RDS là cấp độ ổ cắm được sử dụng
	với setsockopt(2) và getsockopt(2) cho ổ cắm cụ thể RDS
	tùy chọn.

fd = ổ cắm(PF_RDS, SOCK_SEQPACKET, 0);
	Điều này tạo ra một ổ cắm RDS mới, không bị ràng buộc.

setsockopt(SOL_SOCKET): gửi và nhận kích thước bộ đệm
	RDS tôn vinh các tùy chọn ổ cắm kích thước bộ đệm gửi và nhận.
	Bạn không được phép xếp hàng nhiều hơn SO_SNDSIZE byte để
	một ổ cắm. Một tin nhắn được xếp hàng đợi khi sendmsg được gọi và
	nó rời khỏi hàng đợi khi hệ thống từ xa xác nhận
	sự xuất hiện của nó.

Tùy chọn SO_RCVSIZE kiểm soát độ dài hàng đợi nhận tối đa.
	Đây là giới hạn mềm chứ không phải giới hạn cứng - RDS sẽ
	tiếp tục chấp nhận và xếp hàng các tin nhắn đến, ngay cả khi điều đó
	đưa chiều dài hàng đợi vượt quá giới hạn. Tuy nhiên, nó cũng sẽ
	đánh dấu cổng là "tắc nghẽn" và gửi bản cập nhật tắc nghẽn tới
	nút nguồn. Nút nguồn có nhiệm vụ điều tiết bất kỳ
	xử lý việc gửi đến cổng bị tắc nghẽn này.

liên kết(fd, &sockaddr_in, ...)
	Điều này liên kết ổ cắm với một địa chỉ và cổng IP cục bộ và một
	vận chuyển, nếu một phương tiện chưa được chọn thông qua
	Tùy chọn ổ cắm SO_RDS_TRANSPORT

tin nhắn gửi (fd, ...)
	Gửi tin nhắn đến người nhận được chỉ định. Hạt nhân sẽ
	thiết lập minh bạch kết nối đáng tin cậy cơ bản
	nếu nó chưa lên.

Việc cố gắng gửi tin nhắn vượt quá SO_SNDSIZE sẽ
	quay lại với -EMSGSIZE

Một nỗ lực để gửi một tin nhắn sẽ lấy tổng số
	số byte được xếp hàng vượt quá ngưỡng SO_SNDSIZE sẽ trả về
	EAGAIN.

Nỗ lực gửi tin nhắn tới một địa chỉ được đánh dấu
	vì "tắc nghẽn" sẽ trả về ENOBUFS.

recvmsg(fd, ...)
	Nhận tin nhắn đã được xếp hàng đợi vào ổ cắm này. Các ổ cắm
	việc tính toán hàng đợi recv được điều chỉnh và nếu độ dài hàng đợi
	giảm xuống dưới SO_SNDSIZE, cổng được đánh dấu là không tắc nghẽn và
	một bản cập nhật tắc nghẽn được gửi đến tất cả các đồng nghiệp.

Các ứng dụng có thể yêu cầu mô-đun hạt nhân RDS nhận
	thông báo qua tin nhắn điều khiển (ví dụ: có
	thông báo khi có bản cập nhật tắc nghẽn hoặc khi RDMA
	thao tác hoàn tất). Những thông báo này được nhận thông qua
	bộ đệm msg.msg_control của struct msghdr. Định dạng của
	tin nhắn được mô tả trong trang hướng dẫn.

thăm dò ý kiến(fd)
	RDS hỗ trợ giao diện thăm dò ý kiến cho phép ứng dụng
	để triển khai I/O không đồng bộ.

Việc xử lý POLLIN khá đơn giản. Khi có một
	tin nhắn đến được xếp hàng vào ổ cắm hoặc thông báo đang chờ xử lý,
	chúng tôi báo hiệu POLLIN.

POLLOUT khó hơn một chút. Vì về cơ bản bạn có thể gửi
	tới bất kỳ điểm đến nào, RDS sẽ luôn phát tín hiệu cho POLLOUT miễn là
	có chỗ trên hàng đợi gửi (tức là số byte được xếp hàng đợi
	nhỏ hơn kích thước sendbuf).

Tuy nhiên, kernel sẽ từ chối chấp nhận tin nhắn tới
	một điểm đến được đánh dấu là tắc nghẽn - trong trường hợp này bạn sẽ lặp lại
	mãi mãi nếu bạn dựa vào cuộc thăm dò ý kiến để cho bạn biết phải làm gì.
	Đây không phải là một vấn đề tầm thường, nhưng các ứng dụng có thể giải quyết
	điều này - bằng cách sử dụng thông báo tắc nghẽn và bằng cách kiểm tra
	Lỗi ENOBUFS được trả về bởi sendmsg.

setsockopt(SOL_RDS, RDS_CANCEL_SENT_TO, &sockaddr_in)
	Điều này cho phép ứng dụng loại bỏ tất cả các tin nhắn được xếp hàng đợi vào một
	đích cụ thể trên ổ cắm cụ thể này.

Điều này cho phép ứng dụng hủy các tin nhắn chưa xử lý nếu
	nó phát hiện thời gian chờ. Ví dụ: nếu nó cố gửi tin nhắn,
	và máy chủ từ xa không thể truy cập được, RDS sẽ tiếp tục cố gắng mãi mãi.
	Ứng dụng có thể quyết định rằng nó không có giá trị và hủy bỏ
	hoạt động. Trong trường hợp này, nó sẽ sử dụng RDS_CANCEL_SENT_TO để
	hủy bỏ mọi tin nhắn đang chờ xử lý.

ZZ0000ZZ
	Đặt hoặc đọc một số nguyên xác định cơ sở
	đóng gói vận chuyển được sử dụng cho các gói RDS trên
	ổ cắm. Khi cài đặt tùy chọn, đối số số nguyên có thể là
	một trong những RDS_TRANS_TCP hoặc RDS_TRANS_IB. Khi truy xuất
	giá trị, RDS_TRANS_NONE sẽ được trả về trên ổ cắm không liên kết.
	Tùy chọn ổ cắm này chỉ có thể được đặt chính xác một lần trên ổ cắm,
	trước khi ràng buộc nó thông qua lệnh gọi hệ thống bind(2). Nỗ lực để
	đặt SO_RDS_TRANSPORT trên ổ cắm mà phương tiện vận chuyển có
	đã được đính kèm rõ ràng trước đó (bởi SO_RDS_TRANSPORT) hoặc
	ngầm (thông qua liên kết (2)) sẽ trả về lỗi EOPNOTSUPP.
	Việc cố gắng đặt SO_RDS_TRANSPORT thành RDS_TRANS_NONE sẽ
	luôn trả về EINVAL.

RDMA cho RDS
============

xem trang chủ rds-rdma(7) (có sẵn trong rds-tools)


Thông báo tắc nghẽn
========================

xem trang chủ rds(7)


Giao thức RDS
============

Tiêu đề tin nhắn

Tiêu đề thư là 'struct rds_header' (xem rds.h):

Lĩnh vực:

h_sequence:
	  số thứ tự mỗi gói
      h_ack:
	  cõng xác nhận gói cuối cùng đã nhận được
      h_len:
	  độ dài của dữ liệu, không bao gồm tiêu đề
      h_sport:
	  cổng nguồn
      h_dport:
	  cảng đích
      h_flags:
	  có thể là:

===================================================
	  CONG_BITMAP đây là bitmap cập nhật tắc nghẽn
	  Bộ thu ACK_REQUIRED phải xác nhận gói này
	  Gói RETRANSMITTED đã được gửi trước đó
	  ===================================================

h_credit:
	  cho biết đầu bên kia của kết nối rằng
	  nó có nhiều tín dụng hơn (tức là có
	  thêm phòng gửi)
      h_padding[4]:
	  chưa sử dụng, để sử dụng trong tương lai
      h_csum:
	  tổng kiểm tra tiêu đề
      h_extdr:
	  dữ liệu tùy chọn có thể được chuyển qua đây. Điều này hiện đang được sử dụng cho
	  truyền thông tin liên quan đến RDMA.

ACK và xử lý truyền lại

Người ta có thể nghĩ rằng với các kết nối IB đáng tin cậy, bạn sẽ không cần
      để xác nhận tin nhắn đã nhận được.  Vấn đề là IB
      phần cứng tạo ra một tin nhắn ack trước khi nó gửi tin nhắn DMA
      vào bộ nhớ.  Điều này có thể gây mất tin nhắn nếu HCA
      bị vô hiệu hóa vì bất kỳ lý do gì kể từ thời điểm nó gửi ack đến trước đó
      tin nhắn được DMAed và xử lý.  Đây chỉ là một vấn đề tiềm năng
      nếu HCA khác có sẵn để chuyển đổi dự phòng.

Gửi một ack ngay lập tức sẽ cho phép người gửi giải phóng thư đã gửi
      tin nhắn từ hàng đợi gửi của họ một cách nhanh chóng, nhưng có thể gây ra quá nhiều
      lưu lượng truy cập được sử dụng cho acks. RDS cõng xác nhận dữ liệu đã gửi
      gói.  Các gói chỉ có ACK được giảm bớt bằng cách chỉ cho phép một gói được
      trong chuyến bay tại một thời điểm và bởi người gửi chỉ yêu cầu xác nhận khi
      bộ đệm gửi của nó bắt đầu đầy. Tất cả các lần truyền lại cũng được
      ack.

Kiểm soát dòng chảy

Vận chuyển IB của RDS sử dụng cơ chế dựa trên tín dụng để xác minh rằng
      có không gian trong bộ đệm nhận của thiết bị ngang hàng để có thêm dữ liệu. Cái này
      loại bỏ sự cần thiết phải thử lại phần cứng trên kết nối.

Sự tắc nghẽn

Tin nhắn đang chờ trong hàng đợi nhận trên ổ cắm nhận
      được tính vào giá trị tùy chọn SO_RCVBUF của ổ cắm.  Chỉ
      các byte tải trọng trong tin nhắn đã được tính đến.  Nếu
      số byte được xếp hàng đợi bằng hoặc vượt quá rcvbuf thì ổ cắm
      bị tắc nghẽn.  Tất cả các lần gửi đều được cố gắng gửi đến địa chỉ của ổ cắm này
      nên trả về khối hoặc trả về -EWOULDBLOCK.

Các ứng dụng dự kiến sẽ được điều chỉnh hợp lý sao cho
      trường hợp rất hiếm khi xảy ra.  Một ứng dụng gặp phải điều này
      "Áp lực ngược" được coi là một lỗi.

Điều này được thực hiện bằng cách yêu cầu mỗi nút duy trì các bitmap
      cho biết cổng nào trên các địa chỉ bị ràng buộc bị tắc nghẽn.  Như
      những thay đổi bitmap, nó được gửi qua tất cả các kết nối
      chấm dứt ở địa chỉ cục bộ của bitmap đã thay đổi.

Các bitmap được phân bổ khi các kết nối được đưa lên.  Cái này
      tránh phân bổ trong đường dẫn xử lý ngắt xếp hàng
      tin nhắn trên socket.  Các bitmap dày đặc cho phép các phương tiện vận chuyển gửi
      toàn bộ bitmap trên bất kỳ bitmap nào thay đổi một cách hiệu quả một cách hợp lý.  Cái này
      dễ thực hiện hơn nhiều so với một số chi tiết hơn
      thông tin về tắc nghẽn trên mỗi cổng.  Người gửi thực hiện rất
      kiểm tra bit rẻ tiền để kiểm tra xem cổng nó sắp gửi tới
      có bị tắc nghẽn hay không.


Lớp vận chuyển RDS
===================

Như đã đề cập ở trên, RDS không dành riêng cho IB. Mã của nó được chia
  thành lớp RDS chung và lớp vận chuyển.

Lớp chung xử lý socket API, xử lý tắc nghẽn,
  loopback, số liệu thống kê, ghim người dùng và máy trạng thái kết nối.

Lớp vận chuyển xử lý các chi tiết của việc vận chuyển. IB
  Ví dụ: Transport xử lý tất cả các cặp hàng đợi, yêu cầu công việc,
  Trình xử lý sự kiện CM và các chi tiết Infiniband khác.


Cấu trúc hạt nhân RDS
=====================

cấu trúc rds_message
    hay còn gọi là "rds_outending", lớp RDS chung sao chép dữ liệu vào
    được gửi và đặt các trường tiêu đề nếu cần, dựa trên ổ cắm API.
    Điều này sau đó được xếp hàng đợi cho kết nối riêng lẻ và được gửi bởi
    vận chuyển của kết nối.

cấu trúc rds_incoming
    một cấu trúc chung đề cập đến dữ liệu đến có thể được truyền từ
    việc vận chuyển đến mã chung và được xếp hàng theo mã chung
    trong khi ổ cắm được đánh thức. Sau đó nó được chuyển trở lại phương tiện vận chuyển
    mã để xử lý việc sao chép thực tế cho người dùng.

cấu trúc rds_socket
    thông tin trên mỗi ổ cắm

cấu trúc rds_connection
    thông tin mỗi kết nối

cấu trúc rds_transport
    con trỏ tới các chức năng vận chuyển cụ thể

cấu trúc rds_statistic
    số liệu thống kê không cụ thể về vận tải

cấu trúc rds_cong_map
    bao bọc bitmap tắc nghẽn thô, chứa rbnode, waitq, v.v.

Quản lý kết nối
=====================

Các kết nối có thể ở dạng UP, DOWN, CONNECTING, DISCONNECTING và
  Trạng thái ERROR.

Lần đầu tiên ổ cắm RDS cố gắng gửi dữ liệu tới
  một nút, một kết nối được phân bổ và kết nối. Sự kết nối đó là
  sau đó được duy trì mãi mãi -- nếu có lỗi vận chuyển,
  kết nối sẽ bị hủy và được thiết lập lại.

Việc ngắt kết nối trong khi các gói đang được xếp hàng đợi sẽ gây ra tình trạng xếp hàng đợi hoặc
  các gói dữ liệu được gửi một phần sẽ được truyền lại khi kết nối được thực hiện
  được thành lập lại.


Đường dẫn gửi
=============

rds_sendmsg()
    - struct rds_message được xây dựng từ dữ liệu đến
    - CMSG được phân tích cú pháp (ví dụ: hoạt động RDMA)
    - kết nối vận chuyển được phân bổ và kết nối nếu chưa
    - rds_message được đặt trong hàng đợi gửi
    - gửi công nhân đánh thức

rds_send_worker()
    - gọi rds_send_xmit() cho đến khi hàng đợi trống

rds_send_xmit()
    - truyền bản đồ tắc nghẽn nếu bản đồ đang chờ xử lý
    - có thể đặt ACK_REQUIRED
    - gọi phương tiện vận chuyển để gửi tin nhắn không phải RDMA hoặc RDMA
      (RDMA hoạt động không bao giờ được truyền lại)

rds_ib_xmit()
    - phân bổ các yêu cầu công việc từ vòng gửi
    - thêm bất kỳ khoản tín dụng gửi mới nào có sẵn cho ngang hàng (h_credits)
    - ánh xạ danh sách sg của rds_message
    - cõng ack
    - điền các yêu cầu công việc
    - gửi bài tới cặp hàng đợi của kết nối

Đường dẫn recv
=============

rds_ib_recv_cq_comp_handler()
    - xem xét việc hoàn thành viết
    - hủy bản đồ bộ đệm recv khỏi thiết bị
    - không có lỗi, hãy gọi rds_ib_process_recv()
    - đổ đầy vòng recv

rds_ib_process_recv()
    - xác thực tổng kiểm tra tiêu đề
    - sao chép tiêu đề vào cấu trúc rds_ib_incoming nếu bắt đầu một datagram mới
    - thêm vào danh sách mong manh của ibinc
    - nếu datagram hoàn thành:
	 - cập nhật cong map nếu datagram đã được cập nhật cong
	 - gọi rds_recv_incoming() nếu không
	 - lưu ý nếu cần ack

rds_recv_incoming()
    - bỏ các gói trùng lặp
    - trả lời ping
    - tìm chiếc tất được liên kết với datagram này
    - thêm vào hàng đợi tất
    - thức dậy vớ
    - thực hiện một số tính toán tắc nghẽn
  rds_recvmsg
    - sao chép dữ liệu vào người dùng iovec
    - xử lý CMSG
    - quay lại ứng dụng

Đa đường RDS (mprds)
=====================
Mprds là multipathed-RDS, chủ yếu dành cho RDS-over-TCP
  (mặc dù khái niệm này có thể được mở rộng sang các phương tiện vận tải khác). cổ điển
  việc triển khai RDS-over-TCP được triển khai bằng cách phân kênh nhiều kênh
  Ổ cắm PF_RDS giữa 2 điểm cuối bất kỳ (trong đó điểm cuối == [địa chỉ IP,
  port]) qua một ổ cắm TCP duy nhất giữa 2 địa chỉ IP có liên quan. Cái này
  có hạn chế là nó kết thúc việc phân luồng nhiều luồng RDS qua một
  luồng TCP đơn lẻ, do đó nó là
  (a) giới hạn trên của băng thông luồng đơn,
  (b) bị chặn đầu dòng đối với tất cả các ổ cắm RDS.

Có thể đạt được thông lượng tốt hơn (đối với kích thước gói nhỏ cố định, MTU)
  bằng cách có nhiều luồng TCP/IP trên mỗi kết nối rds/tcp, tức là đa đường
  RDS (mprds).  Mỗi luồng TCP/IP như vậy tạo thành một đường dẫn cho rds/tcp
  kết nối. Ổ cắm RDS sẽ được gắn vào một đường dẫn dựa trên một số hàm băm
  (ví dụ: địa chỉ cục bộ và số cổng RDS) và các gói cho RDS đó
  socket sẽ được gửi qua đường dẫn đính kèm bằng TCP để phân đoạn/tập hợp lại
  Các datagram RDS trên đường dẫn đó.

RDS đa đường được triển khai bằng cách chia cấu trúc rds_connection thành
  một phần chung (cho tất cả các đường dẫn) và một cấu trúc trên mỗi đường dẫn rds_conn_path. Tất cả
  Các luồng công việc I/O và kết nối lại được điều khiển từ rds_conn_path.
  Các phương tiện vận chuyển như TCP có khả năng đa đường sau đó có thể thiết lập một
  Ổ cắm TCP trên mỗi rds_conn_path và điều này được quản lý bởi quá trình vận chuyển thông qua
  con trỏ cp_transport_data riêng vận chuyển.

Các phương tiện vận tải thông báo mình có khả năng đa đường bằng cách thiết lập
  bit t_mp_capable trong quá trình đăng ký với mô-đun lõi rds. Khi
  truyền tải có khả năng đa đường, rds_sendmsg() băm lưu lượng đi
  qua nhiều con đường. Hàm băm gửi đi được tính toán dựa trên
  địa chỉ và cổng cục bộ mà ổ cắm PF_RDS được liên kết với.

Ngoài ra, ngay cả khi phương tiện vận chuyển có khả năng MP, chúng tôi có thể
  ngang hàng với một số nút không hỗ trợ mprds hoặc hỗ trợ
  số đường đi khác nhau. Kết quả là, các nút ngang hàng cần
  để thống nhất về số lượng đường dẫn được sử dụng cho kết nối.
  Điều này được thực hiện bằng cách gửi đi một gói trao đổi điều khiển trước khi
  gói dữ liệu đầu tiên. Việc trao đổi gói điều khiển phải hoàn thành
  trước khi hoàn thành hàm băm gửi đi trong rds_sendmsg() khi quá trình vận chuyển
  có khả năng đa đường.

Gói điều khiển là gói ping RDS (tức là gói tới đích rds
  cổng 0) với gói ping có tùy chọn tiêu đề mở rộng rds là
  gõ RDS_EXTHDR_NPATHS, dài 2 byte và giá trị là
  số lượng đường dẫn được người gửi hỗ trợ. Gói ping "thăm dò" sẽ
  được gửi từ một số cổng dành riêng, RDS_FLAG_PROBE_PORT (trong <linux/rds.h>)
  Do đó, người nhận ping từ RDS_FLAG_PROBE_PORT sẽ ngay lập tức
  có thể tính toán min(sender_paths, rcvr_paths). cái bóng bàn
  được gửi để phản hồi một ping thăm dò phải chứa đường dẫn của RCVR
  khi RCVR có khả năng mprds.

Nếu RCVR không hỗ trợ mprds, exthdr trong ping sẽ là
  bị phớt lờ.  Trong trường hợp này, pong sẽ không có bất kỳ exthdr nào, vì vậy người gửi
  của ping thăm dò có thể mặc định là mprds một đường dẫn.
