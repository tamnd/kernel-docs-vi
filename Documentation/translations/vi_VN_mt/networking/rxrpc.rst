.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/rxrpc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Giao thức mạng RxRPC
======================

Trình điều khiển giao thức RxRPC cung cấp khả năng truyền tải hai pha đáng tin cậy trên UDP
có thể được sử dụng để thực hiện các hoạt động từ xa RxRPC.  Việc này được thực hiện qua các socket
thuộc họ AF_RXRPC, sử dụng sendmsg() và recvmsg() với dữ liệu điều khiển để gửi và
nhận dữ liệu, hủy bỏ và báo lỗi.

Nội dung của tài liệu này:

(#) Tổng quan.

(#) Tóm tắt giao thức RxRPC.

(#) Mẫu trình điều khiển AF_RXRPC.

(#) Kiểm soát tin nhắn.

(#) Tùy chọn ổ cắm.

(#) Bảo vệ.

(#) Ví dụ về cách sử dụng máy khách.

(#) Ví dụ về cách sử dụng máy chủ.

(#) Giao diện hạt nhân AF_RXRPC.

(#) Các thông số có thể cấu hình.


Tổng quan
========

RxRPC là một giao thức hai lớp.  Có một lớp phiên cung cấp
kết nối ảo đáng tin cậy sử dụng UDP qua IPv4 (hoặc IPv6) làm phương tiện truyền tải
lớp, nhưng thực hiện một giao thức mạng thực sự; và sau đó là phần trình bày
lớp hiển thị dữ liệu có cấu trúc thành các đốm màu nhị phân và ngược lại bằng XDR
(cũng như SunRPC)::

+-------------+
		ZZ0000ZZ
		+-------------+
		Trình bày ZZ0001ZZ
		+-------------+
		Phiên ZZ0002ZZ
		+-------------+
		ZZ0003ZZ Vận Chuyển
		+-------------+


AF_RXRPC cung cấp:

(1) Một phần của cơ sở RxRPC cho cả ứng dụng kernel và không gian người dùng bởi
     biến phần phiên của nó thành giao thức mạng Linux (AF_RXRPC).

(2) Giao thức hai giai đoạn.  Máy khách truyền một blob (yêu cầu) và sau đó
     nhận được một blob (trả lời) và máy chủ nhận được yêu cầu, sau đó
     truyền tải câu trả lời.

(3) Việc lưu giữ các bit có thể tái sử dụng của hệ thống truyền tải được thiết lập cho một cuộc gọi
     để tăng tốc các cuộc gọi tiếp theo.

(4) Một giao thức an toàn, sử dụng phương tiện lưu giữ khóa của nhân Linux để
     quản lý bảo mật ở phía khách hàng.  Phần cuối của máy chủ nhất thiết phải được
     tích cực hơn trong các cuộc đàm phán an ninh.

AF_RXRPC không cung cấp phương tiện sắp xếp/trình bày XDR.  Đó là
còn lại cho ứng dụng.  AF_RXRPC chỉ giao dịch theo đốm màu.  Ngay cả ID hoạt động
chỉ là bốn byte đầu tiên của blob yêu cầu và như vậy nằm ngoài phạm vi
sự quan tâm của kernel.


Các ổ cắm của dòng AF_RXRPC là:

(1) được tạo dưới dạng SOCK_DGRAM;

(2) được cung cấp giao thức về loại phương tiện giao thông cơ bản mà họ sẽ sử dụng
     để sử dụng - hiện tại chỉ hỗ trợ PF_INET.


Hệ thống tệp Andrew (AFS) là một ví dụ về ứng dụng sử dụng điều này và
có cả thành phần kernel (hệ thống tập tin) và không gian người dùng (tiện ích).


Tóm tắt giao thức RxRPC
======================

Tổng quan về giao thức RxRPC:

(#) RxRPC nằm trên một giao thức mạng khác (UDP là tùy chọn duy nhất
     hiện tại) và sử dụng điều này để cung cấp vận chuyển mạng.  Cổng UDP, dành cho
     ví dụ, cung cấp các điểm cuối vận chuyển.

(#) RxRPC hỗ trợ nhiều "kết nối" ảo từ bất kỳ phương tiện truyền tải cụ thể nào
     điểm cuối, do đó cho phép các điểm cuối được chia sẻ, thậm chí với cùng một
     điểm cuối từ xa.

(#) Mỗi ​​kết nối đi đến một "dịch vụ" cụ thể.  Một kết nối có thể không đi
     tới nhiều dịch vụ.  Một dịch vụ có thể được coi là RxRPC tương đương với
     một số cổng.  AF_RXRPC cho phép nhiều dịch vụ chia sẻ điểm cuối.

(#) Các gói khởi tạo từ máy khách được đánh dấu, do đó điểm cuối truyền tải có thể được
     được chia sẻ giữa các kết nối máy khách và máy chủ (các kết nối có
     hướng).

(#) Có thể hỗ trợ đồng thời tới một tỷ kết nối giữa một
     điểm cuối truyền tải cục bộ và một dịch vụ trên một điểm cuối từ xa.  Một RxRPC
     kết nối được mô tả bằng bảy con số::

Địa chỉ địa phương }
	Cổng cục bộ } Địa chỉ vận chuyển (UDP)
	Địa chỉ từ xa }
	Cổng từ xa }
	Hướng
	ID kết nối
	ID dịch vụ

(#) Mỗi ​​thao tác RxRPC là một "cuộc gọi".  Một kết nối có thể lên tới bốn
     tỷ cuộc gọi nhưng chỉ có thể thực hiện tối đa bốn cuộc gọi trên một
     kết nối bất cứ lúc nào.

(#) Cuộc gọi có hai pha và không đối xứng: máy khách gửi dữ liệu yêu cầu của mình,
     mà dịch vụ nhận được; sau đó dịch vụ sẽ truyền dữ liệu trả lời
     mà khách hàng nhận được.

(#) Các đốm màu dữ liệu có kích thước không xác định, phần cuối của một pha được đánh dấu bằng dấu
     cờ trong gói.  Số lượng gói dữ liệu tạo nên một đốm màu có thể
     Tuy nhiên, không vượt quá 4 tỷ vì điều này sẽ khiến số thứ tự bị
     quấn.

(#) Bốn byte đầu tiên của dữ liệu yêu cầu là ID hoạt động dịch vụ.

(#) Bảo mật được đàm phán trên cơ sở mỗi kết nối.  Kết nối là
     được bắt đầu bởi gói dữ liệu đầu tiên đến.  Nếu bảo mật là
     được yêu cầu, máy chủ sẽ đưa ra một "thử thách" và sau đó máy khách
     trả lời bằng một "phản hồi".  Nếu phản hồi thành công, bảo mật sẽ được
     được đặt trong suốt thời gian tồn tại của kết nối đó và tất cả các cuộc gọi tiếp theo được thực hiện
     khi nó sử dụng bảo mật tương tự.  Trong trường hợp máy chủ cho phép
     kết nối mất hiệu lực trước máy khách, bảo mật sẽ được thương lượng lại nếu
     khách hàng sử dụng lại kết nối.

(#) Cuộc gọi sử dụng gói ACK để xử lý độ tin cậy.  Các gói dữ liệu cũng
     được sắp xếp rõ ràng cho mỗi cuộc gọi.

(#) Có hai loại xác nhận tích cực: ACK cứng và ACK mềm.
     ACK cứng cho biết ở phía xa rằng tất cả dữ liệu nhận được đến một điểm
     đã được tiếp nhận và xử lý; soft-ACK chỉ ra rằng dữ liệu có
     đã được nhận nhưng vẫn có thể bị loại bỏ và được yêu cầu lại.  Người gửi có thể
     không loại bỏ bất kỳ gói có thể truyền nào cho đến khi chúng ở dạng cứng-ACK'd.

(#) Việc tiếp nhận gói dữ liệu trả lời hoàn toàn cứng-tất cả dữ liệu của ACK
     các gói tạo nên yêu cầu.

(#) Cuộc gọi hoàn tất khi yêu cầu đã được gửi đi và đã có phản hồi
     đã nhận được và hard-ACK cuối cùng trên gói cuối cùng của phản hồi có
     đã đến máy chủ.

(#) Một cuộc gọi có thể bị hủy bỏ bởi một trong hai đầu bất kỳ lúc nào cho đến khi nó hoàn thành.


Mô hình trình điều khiển AF_RXRPC
=====================

Giới thiệu về trình điều khiển AF_RXRPC:

(#) Giao thức AF_RXRPC sử dụng các ổ cắm bên trong của phương tiện giao thông một cách minh bạch
     giao thức đại diện cho các điểm cuối vận chuyển.

(#) Ổ cắm AF_RXRPC ánh xạ vào các gói kết nối RxRPC.  RxRPC thực tế
     các kết nối được xử lý một cách minh bạch.  Một ổ cắm máy khách có thể được sử dụng để
     thực hiện nhiều cuộc gọi đồng thời đến cùng một dịch vụ.  Một ổ cắm máy chủ
     có thể xử lý các cuộc gọi từ nhiều khách hàng.

(#) Các kết nối máy khách song song bổ sung sẽ được bắt đầu để hỗ trợ thêm
     các cuộc gọi đồng thời, đến giới hạn có thể điều chỉnh được.

(#) Mỗi kết nối được giữ lại trong một khoảng thời gian nhất định [có thể điều chỉnh] sau
     cuộc gọi cuối cùng hiện đang sử dụng nó đã hoàn tất trong trường hợp cuộc gọi mới được thực hiện
     có thể tái sử dụng nó.

(#) Mỗi ổ cắm UDP bên trong được giữ lại [có thể điều chỉnh] trong một lượng nhất định
     thời gian [có thể điều chỉnh] sau khi kết nối cuối cùng sử dụng nó bị hủy, trong trường hợp có kết nối mới
     kết nối được thực hiện có thể sử dụng nó.

(#) Kết nối phía máy khách chỉ được chia sẻ giữa các cuộc gọi nếu chúng có
     cùng một cấu trúc khóa mô tả tính bảo mật của chúng (và giả sử các lệnh gọi
     nếu không sẽ chia sẻ kết nối).  Các cuộc gọi không bảo mật cũng sẽ được
     có thể chia sẻ kết nối với nhau.

(#) Kết nối phía máy chủ được chia sẻ nếu khách hàng cho biết.

(#) ACK'ing được trình điều khiển giao thức xử lý tự động, bao gồm cả ping
     đang trả lời.

(#) SO_KEEPALIVE tự động ping phía bên kia để giữ kết nối
     còn sống [TODO].

(#) Nếu nhận được lỗi ICMP, tất cả các cuộc gọi bị ảnh hưởng bởi lỗi đó sẽ bị hủy
     bị hủy do lỗi mạng thích hợp được truyền qua recvmsg().


Tương tác với người dùng ổ cắm RxRPC:

(#) Một ổ cắm được tạo thành một ổ cắm máy chủ bằng cách liên kết một địa chỉ với một
     ID dịch vụ khác 0.

(#) Trong máy khách, việc gửi yêu cầu được thực hiện bằng một hoặc nhiều tin nhắn gửi,
     theo sau là phản hồi được nhận với một hoặc nhiều recvmsgs.

(#) Tin nhắn gửi đầu tiên cho yêu cầu được gửi từ máy khách chứa thẻ tới
     được sử dụng trong tất cả các tin nhắn gửi hoặc tin nhắn nhận được liên kết với cuộc gọi đó.  các
     thẻ được mang trong dữ liệu điều khiển.

(#) connect() được sử dụng để cung cấp địa chỉ đích mặc định cho máy khách
     ổ cắm.  Điều này có thể được ghi đè bằng cách cung cấp một địa chỉ thay thế cho
     sendmsg() đầu tiên của cuộc gọi (struct msghdr::msg_name).

(#) Nếu connect() được gọi trên máy khách không liên kết, một cổng cục bộ ngẫu nhiên sẽ
     bị ràng buộc trước khi hoạt động diễn ra.

(#) Ổ cắm máy chủ cũng có thể được sử dụng để thực hiện cuộc gọi máy khách.  Để làm điều này,
     sendmsg() đầu tiên của cuộc gọi phải chỉ định địa chỉ đích.  của máy chủ
     điểm cuối vận chuyển được sử dụng để gửi các gói.

(#) Khi ứng dụng đã nhận được tin nhắn cuối cùng liên quan đến cuộc gọi,
     thẻ được đảm bảo không bị nhìn thấy nữa và vì vậy nó có thể được sử dụng để ghim
     nguồn lực của khách hàng.  Sau đó, một cuộc gọi mới có thể được bắt đầu với cùng một thẻ
     mà không sợ bị can thiệp.

(#) Trong máy chủ, một yêu cầu được nhận với một hoặc nhiều recvmsgs, sau đó
     câu trả lời được truyền đi bằng một hoặc nhiều tin nhắn gửi và sau đó là ACK cuối cùng
     được nhận với recvmsg cuối cùng.

(#) Khi gửi dữ liệu cho cuộc gọi, sendmsg được cấp MSG_MORE nếu có thêm
     dữ liệu để thực hiện cuộc gọi đó.

(#) Khi nhận dữ liệu cho cuộc gọi, recvmsg gắn cờ MSG_MORE nếu có nhiều hơn
     dữ liệu đến cho cuộc gọi đó.

(#) Khi nhận dữ liệu hoặc tin nhắn cho một cuộc gọi, MSG_EOR bị recvmsg gắn cờ
     để chỉ ra tin nhắn đầu cuối cho cuộc gọi đó.

(#) Cuộc gọi có thể bị hủy bằng cách thêm thông báo điều khiển hủy bỏ vào điều khiển
     dữ liệu.  Việc đưa ra lệnh hủy bỏ sẽ chấm dứt việc sử dụng thẻ của lệnh gọi đó trong kernel.
     Mọi tin nhắn đang chờ trong hàng nhận cho cuộc gọi đó sẽ bị loại bỏ.

(#) Hủy bỏ, thông báo bận và gói thử thách được gửi bởi recvmsg,
     và thông điệp dữ liệu điều khiển sẽ được thiết lập để chỉ ra ngữ cảnh.  Đang nhận
     một thông báo hủy bỏ hoặc một thông báo bận sẽ chấm dứt việc sử dụng thẻ của lệnh gọi đó trong kernel.

(#) Phần dữ liệu điều khiển của cấu trúc msghdr được sử dụng cho một số mục đích:

(#) Thẻ của cuộc gọi dự định hoặc bị ảnh hưởng.

(#) Gửi hoặc nhận lỗi, hủy bỏ và thông báo bận.

(#) Thông báo cuộc gọi đến.

(#) Gửi yêu cầu gỡ lỗi và nhận phản hồi gỡ lỗi [TODO].

(#) Khi kernel đã nhận và thiết lập một cuộc gọi đến, nó sẽ gửi một
     gửi tin nhắn tới ứng dụng máy chủ để thông báo rằng có cuộc gọi mới đang chờ
     sự chấp nhận của nó [recvmsg báo cáo một thông báo kiểm soát đặc biệt].  Máy chủ
     sau đó ứng dụng sẽ sử dụng sendmsg để gán thẻ cho cuộc gọi mới.  Một lần đó
     hoàn tất, phần đầu tiên của dữ liệu yêu cầu sẽ được gửi bởi recvmsg.

(#) Ứng dụng máy chủ phải cung cấp cho ổ cắm máy chủ một khóa
     khóa bí mật tương ứng với loại bảo mật mà nó cho phép.  Khi an toàn
     kết nối đang được thiết lập, kernel sẽ tra cứu khóa bí mật thích hợp
     trong quá trình khóa và sau đó gửi gói thử thách đến khách hàng và
     nhận được gói phản hồi.  Hạt nhân sau đó sẽ kiểm tra sự ủy quyền của
     gói tin và hủy kết nối hoặc thiết lập bảo mật.

(#) Tên của khóa mà khách hàng sẽ sử dụng để bảo mật thông tin liên lạc của mình là
     được đề cử bởi một tùy chọn ổ cắm.


Lưu ý về sendmsg:

(#) MSG_WAITALL có thể được đặt để yêu cầu sendmsg bỏ qua các tín hiệu nếu thiết bị ngang hàng
     đạt được tiến bộ trong việc chấp nhận các gói trong một khoảng thời gian hợp lý sao cho chúng tôi
     quản lý để xếp hàng tất cả dữ liệu để truyền.  Điều này đòi hỏi sự
     khách hàng chấp nhận ít nhất một gói trong khoảng thời gian 2*RTT.

Nếu điều này không được đặt, sendmsg() sẽ trả về ngay lập tức, hoặc trả về
     EINTR/ERESTARTSYS nếu không có gì bị tiêu thụ hoặc trả lại lượng dữ liệu
     tiêu thụ.


Ghi chú về recvmsg:

(#) Nếu có một chuỗi tin nhắn dữ liệu thuộc về một cuộc gọi cụ thể trên
     hàng đợi nhận thì recvmsg sẽ tiếp tục xử lý chúng cho đến khi:

(a) nó đáp ứng phần cuối của dữ liệu nhận được của cuộc gọi đó,

(b) nó gặp một thông báo phi dữ liệu,

(c) nó gặp một tin nhắn thuộc cuộc gọi khác, hoặc

(d) nó lấp đầy bộ đệm người dùng.

Nếu recvmsg được gọi ở chế độ chặn, nó sẽ tiếp tục ngủ và chờ
     tiếp nhận dữ liệu tiếp theo cho đến khi đáp ứng một trong bốn điều kiện trên.

(2) MSG_PEEK hoạt động tương tự, nhưng sẽ quay trở lại ngay lập tức nếu đặt bất kỳ
     dữ liệu trong bộ đệm thay vì ngủ cho đến khi nó có thể lấp đầy bộ đệm.

(3) Nếu thông báo dữ liệu chỉ được sử dụng một phần để lấp đầy bộ đệm người dùng,
     thì phần còn lại của tin nhắn đó sẽ được để ở phía trước hàng đợi
     cho người nhận tiếp theo.  MSG_TRUNC sẽ không bao giờ bị gắn cờ.

(4) Nếu có nhiều dữ liệu hơn trong cuộc gọi (nó chưa sao chép byte cuối cùng
     của thông báo dữ liệu cuối cùng trong giai đoạn đó), thì MSG_MORE sẽ
     được gắn cờ.


Kiểm soát tin nhắn
================

AF_RXRPC sử dụng các thông báo điều khiển trong sendmsg() và recvmsg() để ghép kênh
gọi, để thực hiện một số hành động nhất định và báo cáo các điều kiện nhất định.  Đây là:

======================== === ===============================================
	MESSAGE ID SRT DATA MEANING
	======================== === ===============================================
	RXRPC_USER_CALL_ID sr- Trình xác định cuộc gọi của ứng dụng ID người dùng
	RXRPC_ABORT srt Hủy mã Hủy bỏ mã để phát/nhận
	RXRPC_ACK -rt n/a Đã nhận được ACK cuối cùng
	RXRPC_NET_ERROR -rt error num Lỗi mạng khi gọi
	RXRPC_BUSY -rt n/a Cuộc gọi bị từ chối (máy chủ bận)
	RXRPC_LOCAL_ERROR -rt error num Đã gặp lỗi cục bộ
	RXRPC_NEW_CALL -r- n/a Nhận được cuộc gọi mới
	RXRPC_ACCEPT s-- n/a Chấp nhận cuộc gọi mới
	RXRPC_EXCLUSIVE_CALL s-- n/a Thực hiện cuộc gọi dành riêng cho khách hàng
	RXRPC_UPGRADE_SERVICE s-- n/a Cuộc gọi khách hàng có thể được nâng cấp
	RXRPC_TX_LENGTH s-- len dữ liệu Tổng chiều dài của dữ liệu Tx
	======================== === ===============================================

(SRT = có thể sử dụng trong Sendmsg/được gửi bởi Recvmsg/tin nhắn đầu cuối)

(#) RXRPC_USER_CALL_ID

Điều này được sử dụng để cho biết ID cuộc gọi của ứng dụng.  Nó dài không dấu
     mà ứng dụng chỉ định trong ứng dụng khách bằng cách đính kèm nó vào dữ liệu đầu tiên
     tin nhắn hoặc trong máy chủ bằng cách chuyển nó cùng với RXRPC_ACCEPT
     tin nhắn.  recvmsg() chuyển nó cùng với tất cả các tin nhắn ngoại trừ
     những thông điệp của RXRPC_NEW_CALL.

(#) RXRPC_ABORT

Ứng dụng này có thể sử dụng tính năng này để hủy cuộc gọi bằng cách chuyển nó tới
     sendmsg hoặc nó có thể được gửi bởi recvmsg để cho biết việc hủy bỏ từ xa đã được thực hiện
     đã nhận được.  Dù bằng cách nào, nó phải được liên kết với RXRPC_USER_CALL_ID để
     chỉ định cuộc gọi bị ảnh hưởng.  Nếu lệnh hủy bỏ được gửi đi thì sẽ xảy ra lỗi EBADSLT
     sẽ được trả về nếu không có cuộc gọi nào với ID người dùng đó.

(#) RXRPC_ACK

Điều này được gửi đến ứng dụng máy chủ để cho biết rằng ACK cuối cùng
     của một cuộc gọi đã nhận được từ khách hàng.  Nó sẽ được liên kết với một
     RXRPC_USER_CALL_ID để cho biết cuộc gọi hiện đã hoàn tất.

(#) RXRPC_NET_ERROR

Điều này được gửi tới một ứng dụng để cho biết rằng thông báo lỗi ICMP
     đã gặp phải trong quá trình cố gắng nói chuyện với bạn bè.  Một
     giá trị số nguyên lớp errno sẽ được bao gồm trong dữ liệu thông báo điều khiển
     cho biết sự cố và RXRPC_USER_CALL_ID sẽ cho biết cuộc gọi
     bị ảnh hưởng.

(#) RXRPC_BUSY

Điều này được gửi đến ứng dụng khách để cho biết rằng cuộc gọi đã được thực hiện
     bị máy chủ từ chối do máy chủ đang bận.  Nó sẽ là
     được liên kết với RXRPC_USER_CALL_ID để biểu thị cuộc gọi bị từ chối.

(#) RXRPC_LOCAL_ERROR

Điều này được gửi đến một ứng dụng để chỉ ra rằng một lỗi cục bộ đã xảy ra
     gặp phải và cuộc gọi đã bị hủy vì nó.  Một
     giá trị số nguyên lớp errno sẽ được bao gồm trong dữ liệu thông báo điều khiển
     cho biết sự cố và RXRPC_USER_CALL_ID sẽ cho biết cuộc gọi
     bị ảnh hưởng.

(#) RXRPC_NEW_CALL

Điều này được gửi để cho ứng dụng máy chủ biết rằng có một cuộc gọi mới
     đã đến và đang chờ được chấp nhận.  Không có ID người dùng nào được liên kết với điều này,
     làm ID người dùng sau đó phải được chỉ định bằng cách thực hiện RXRPC_ACCEPT.

(#) RXRPC_ACCEPT

Điều này được ứng dụng máy chủ sử dụng để cố gắng chấp nhận cuộc gọi và
     gán cho nó một ID người dùng.  Nó phải được liên kết với RXRPC_USER_CALL_ID
     để cho biết ID người dùng sẽ được chỉ định.  Nếu không có cuộc gọi đến
     được chấp nhận (nó có thể đã hết thời gian, bị hủy bỏ, v.v.), thì sendmsg sẽ
     lỗi trả về ENODATA.  Nếu ID người dùng đã được sử dụng bởi một cuộc gọi khác,
     thì lỗi EBADSLT sẽ được trả về.

(#) RXRPC_EXCLUSIVE_CALL

Điều này được sử dụng để chỉ ra rằng cuộc gọi của khách hàng nên được thực hiện một lần
     kết nối.  Kết nối sẽ bị hủy khi cuộc gọi kết thúc.

(#) RXRPC_UPGRADE_SERVICE

Điều này được sử dụng để thực hiện cuộc gọi máy khách để thăm dò xem ID dịch vụ được chỉ định có
     có thể được nâng cấp bởi máy chủ.  Người gọi phải kiểm tra msg_name được trả về
     recvmsg() cho ID dịch vụ thực sự đang được sử dụng.  Hoạt động được thăm dò phải
     hãy là một đối số có cùng đối số trong cả hai dịch vụ.

Một khi điều này đã được sử dụng để thiết lập khả năng nâng cấp (hoặc thiếu
     của máy chủ, ID dịch vụ được trả về sẽ được sử dụng cho tất cả
     liên lạc trong tương lai với máy chủ đó và RXRPC_UPGRADE_SERVICE sẽ không
     còn được thiết lập.

(#) RXRPC_TX_LENGTH

Điều này được sử dụng để thông báo cho kernel về tổng lượng dữ liệu được
     sẽ được truyền đi bằng một cuộc gọi (dù là trong một yêu cầu của khách hàng hay một
     phản hồi dịch vụ).  Nếu được, nó cho phép kernel mã hóa từ
     bộ đệm không gian người dùng trực tiếp vào bộ đệm gói, thay vì sao chép vào
     bộ đệm và sau đó mã hóa tại chỗ.  Điều này chỉ có thể được đưa ra với
     sendmsg() đầu tiên cung cấp dữ liệu cho cuộc gọi.  EMSGSIZE sẽ được tạo nếu
     lượng dữ liệu thực tế được đưa ra là khác nhau.

Cái này lấy một tham số thuộc loại __s64 cho biết số tiền sẽ là bao nhiêu.
     được truyền đi.  Giá trị này có thể không nhỏ hơn 0.

Ký hiệu RXRPC__SUPPORTED được định nghĩa là một ký hiệu nhiều hơn mức kiểm soát cao nhất
loại tin nhắn được hỗ trợ.  Trong thời gian chạy, điều này có thể được truy vấn bằng phương thức
Tùy chọn ổ cắm RXRPC_SUPPORTED_CMSG (xem bên dưới).


Tùy chọn ổ cắm
==============

Ổ cắm AF_RXRPC hỗ trợ một số tùy chọn ổ cắm ở cấp độ SOL_RXRPC:

(#) RXRPC_SECURITY_KEY

Điều này được sử dụng để chỉ định mô tả của khóa sẽ được sử dụng.  Chìa khóa là
     được trích xuất từ chuỗi khóa của quá trình gọi bằng request_key() và
     phải thuộc loại "rxrpc".

Con trỏ optval trỏ đến chuỗi mô tả và optlen chỉ ra
     chuỗi dài bao nhiêu, không có đầu cuối NUL.

(#) RXRPC_SECURITY_KEYRING

Tương tự như trên nhưng chỉ định cách tạo khóa của các khóa bí mật của máy chủ để sử dụng (khóa
     gõ "chuỗi khóa").  Xem phần "Bảo mật".

(#) RXRPC_EXCLUSIVE_CONNECTION

Điều này được sử dụng để yêu cầu sử dụng các kết nối mới cho mỗi cuộc gọi
     được thực hiện sau đó trên ổ cắm này.  optval phải là NULL và optlen 0.

(#) RXRPC_MIN_SECURITY_LEVEL

Điều này được sử dụng để chỉ định mức độ bảo mật tối thiểu cần thiết cho các cuộc gọi trên
     ổ cắm này.  optval phải trỏ đến một int chứa một trong những điều sau đây
     giá trị:

(a) RXRPC_SECURITY_PLAIN

Chỉ tổng kiểm tra được mã hóa.

(b) RXRPC_SECURITY_AUTH

Tổng kiểm tra được mã hóa cộng với gói được đệm và tám byte đầu tiên của gói
	 được mã hóa - bao gồm độ dài gói thực tế.

(c) RXRPC_SECURITY_ENCRYPT

Tổng kiểm tra được mã hóa cộng với toàn bộ gói được đệm và mã hóa, bao gồm
	 chiều dài gói thực tế.

(#) RXRPC_UPGRADEABLE_SERVICE

Điều này được sử dụng để chỉ ra rằng một ổ cắm dịch vụ có hai liên kết có thể
     nâng cấp một dịch vụ bị ràng buộc lên dịch vụ khác nếu khách hàng yêu cầu.  tối ưu
     phải trỏ đến một mảng gồm hai số nguyên ngắn không dấu.  Đầu tiên là
     ID dịch vụ để nâng cấp và ID dịch vụ thứ hai để nâng cấp lên.

(#) RXRPC_SUPPORTED_CMSG

Đây là tùy chọn chỉ đọc, ghi int vào bộ đệm cho biết
     loại thông báo điều khiển cao nhất được hỗ trợ.


Bảo vệ
========

Hiện tại, chỉ có giao thức tương đương kerberos 4 được triển khai
(chỉ số bảo mật 2 - rxkad).  Điều này yêu cầu mô-đun rxkad phải được tải và,
trên máy khách, loại vé thích hợp sẽ được lấy từ AFS
kaserver hoặc máy chủ kerberos và được cài đặt dưới dạng khóa loại "rxrpc".  Đây là
thường được thực hiện bằng chương trình klog.  Một ví dụ về chương trình klog đơn giản có thể là
được tìm thấy tại:

ZZ0000ZZ

Tải trọng được cung cấp cho add_key() trên máy khách phải như sau
hình thức::

cấu trúc rxrpc_key_sec2_v1 {
		uint16_t security_index;	/* 2 */
		uint16_t ticket_length;	/* chiều dài vé[] */
		uint32_t hết hạn;		/*thời điểm hết hạn*/
		uint8_t kvno;		/* số phiên bản chính */
		uint8_t __pad[3];
		uint8_t session_key[8];	/* Khóa phiên DES */
		vé uint8_t[0];	/* vé được mã hóa */
	};

Trường hợp blob vé chỉ được thêm vào cấu trúc trên.


Đối với máy chủ, các khóa thuộc loại "rxrpc_s" phải được cung cấp cho máy chủ.
Họ có mô tả "<serviceID>:<securityIndex>" (ví dụ: "52:2" cho
khóa rxkad cho dịch vụ AFS VL).  Khi một khóa như vậy được tạo ra, nó phải được
lấy khóa bí mật của máy chủ làm dữ liệu khởi tạo (xem ví dụ
bên dưới).

add_key("rxrpc_s", "52:2", secret_key, 8, keyring);

Một chuỗi khóa được chuyển đến ổ cắm máy chủ bằng cách đặt tên nó trong tệp sockopt.  Máy chủ
socket sau đó sẽ tìm kiếm các khóa bí mật của máy chủ trong khóa này khi được bảo mật
các kết nối đến được thực hiện.  Điều này có thể được nhìn thấy trong một chương trình ví dụ có thể
được tìm thấy tại:

ZZ0000ZZ


Ví dụ về cách sử dụng của khách hàng
====================

Một khách hàng sẽ đưa ra một thao tác bằng cách:

(1) Ổ cắm RxRPC được thiết lập bởi::

khách hàng = ổ cắm (AF_RXRPC, SOCK_DGRAM, PF_INET);

Trong đó tham số thứ ba cho biết họ giao thức của phương thức vận chuyển
     socket được sử dụng - thường là IPv4 nhưng cũng có thể là IPv6 [TODO].

(2) Một địa chỉ cục bộ có thể bị ràng buộc tùy ý::

struct sockaddr_rxrpc srx = {
		.srx_family = AF_RXRPC,
		.srx_service = 0, /* chúng tôi là khách hàng */
		.transport_type = SOCK_DGRAM, /* loại ổ cắm truyền tải */
		.transport.sin_family = AF_INET,
		.transport.sin_port = htons(7000), /* AFS gọi lại */
		.transport.sin_address = 0, /* tất cả giao diện cục bộ */
	};
	bind(client, &srx, sizeof(srx));

Điều này chỉ định cổng UDP cục bộ sẽ được sử dụng.  Nếu không được đưa ra, một cách ngẫu nhiên
     cổng không có đặc quyền sẽ được sử dụng.  Cổng UDP có thể được chia sẻ giữa
     một số ổ cắm RxRPC không liên quan.  Việc bảo mật được xử lý trên cơ sở
     kết nối ảo trên mỗi RxRPC.

(3) Bảo mật được thiết lập::

const char *key = "AFS:cambridge.redhat.com";
	setsockopt(client, SOL_RXRPC, RXRPC_SECURITY_KEY, key, strlen(key));

Điều này đưa ra request_key() để lấy khóa đại diện cho bảo mật
     bối cảnh.  Mức độ bảo mật tối thiểu có thể được đặt::

unsign int giây = RXRPC_SECURITY_ENCRYPT;
	setsockopt(client, SOL_RXRPC, RXRPC_MIN_SECURITY_LEVEL,
		   &giây, sizeof(giây));

(4) Sau đó, máy chủ được liên hệ có thể được chỉ định (cách khác, điều này có thể
     được thực hiện thông qua sendmsg)::

struct sockaddr_rxrpc srx = {
		.srx_family = AF_RXRPC,
		.srx_service = VL_SERVICE_ID,
		.transport_type = SOCK_DGRAM, /* loại ổ cắm truyền tải */
		.transport.sin_family = AF_INET,
		.transport.sin_port = htons(7005), /* Trình quản lý âm lượng AFS */
		.transport.sin_address = ...,
	};
	connect(client, &srx, sizeof(srx));

(5) Sau đó, dữ liệu yêu cầu sẽ được đăng lên ổ cắm máy chủ bằng cách sử dụng một chuỗi
     của các cuộc gọi sendmsg(), mỗi cuộc gọi có kèm theo thông báo điều khiển sau:

==========================================================
	RXRPC_USER_CALL_ID chỉ định ID người dùng cho cuộc gọi này
	==========================================================

MSG_MORE phải được đặt trong msghdr::msg_flags trên tất cả trừ phần cuối cùng của
     yêu cầu.  Nhiều yêu cầu có thể được thực hiện đồng thời.

Một thông báo điều khiển RXRPC_TX_LENGTH cũng có thể được chỉ định ở lần đầu tiên
     cuộc gọi sendmsg().

Nếu cuộc gọi có ý định đi đến một đích khác ngoài địa chỉ mặc định
     được chỉ định thông qua connect(), thì msghdr::msg_name phải được đặt trên
     tin nhắn yêu cầu đầu tiên của cuộc gọi đó.

(6) Dữ liệu trả lời sau đó sẽ được đăng lên ổ cắm máy chủ cho recvmsg() tới
     nhặt lên.  MSG_MORE sẽ được gắn cờ bởi recvmsg() nếu có thêm dữ liệu trả lời
     để đọc một cuộc gọi cụ thể.  MSG_EOR sẽ được đặt trên thiết bị đầu cuối
     đọc để gọi.

Tất cả dữ liệu sẽ được gửi kèm theo thông báo kiểm soát sau:

RXRPC_USER_CALL_ID - chỉ định ID người dùng cho cuộc gọi này

Nếu xảy ra lỗi hủy hoặc xảy ra lỗi, thông tin này sẽ được trả về trong dữ liệu điều khiển
     thay vào đó là bộ đệm và MSG_EOR sẽ được gắn cờ để cho biết sự kết thúc của bộ đệm đó
     gọi.

Một khách hàng có thể yêu cầu một ID dịch vụ mà nó biết và yêu cầu nâng cấp nó lên một
dịch vụ tốt hơn nếu có sẵn bằng cách cung cấp RXRPC_UPGRADE_SERVICE trên
sendmsg() đầu tiên của cuộc gọi.  Sau đó, khách hàng nên kiểm tra srx_service trong
msg_name được điền bởi recvmsg() khi thu thập kết quả.  srx_service sẽ
giữ nguyên giá trị như được đưa cho sendmsg() nếu yêu cầu nâng cấp bị bỏ qua bởi
dịch vụ - nếu không nó sẽ bị thay đổi để chỉ ra ID dịch vụ
máy chủ được nâng cấp lên.  Lưu ý rằng ID dịch vụ nâng cấp được chọn bởi máy chủ.
Người gọi phải đợi cho đến khi thấy ID dịch vụ trong thư trả lời trước khi gửi
bất kỳ cuộc gọi nào nữa (các cuộc gọi tiếp theo đến cùng một điểm đến sẽ bị chặn cho đến khi
cuộc thăm dò được kết thúc).


Cách sử dụng máy chủ mẫu
====================

Một máy chủ sẽ được thiết lập để chấp nhận các hoạt động theo cách sau:

(1) Ổ cắm RxRPC được tạo bởi::

máy chủ = ổ cắm (AF_RXRPC, SOCK_DGRAM, PF_INET);

Trong đó tham số thứ ba cho biết loại địa chỉ của phương tiện vận chuyển
     ổ cắm được sử dụng - thường là IPv4.

(2) Bảo mật được thiết lập nếu muốn bằng cách cung cấp cho ổ cắm một khóa với máy chủ
     khóa bí mật trong đó::

keyring = add_key("keyring", "AFSkeys", NULL, 0,
			  KEY_SPEC_PROCESS_KEYRING);

const char secret_key[8] = {
		0xa7, 0x83, 0x8a, 0xcb, 0xc7, 0x83, 0xec, 0x94 };
	add_key("rxrpc_s", "52:2", secret_key, 8, keyring);

setsockopt(máy chủ, SOL_RXRPC, RXRPC_SECURITY_KEYRING, "AFSkeys", 7);

Móc khóa có thể được thao tác sau khi nó được đưa vào ổ cắm. Cái này
     cho phép máy chủ thêm nhiều khóa hơn, thay thế khóa, v.v. khi nó đang hoạt động.

(3) Địa chỉ cục bộ phải được ràng buộc::

struct sockaddr_rxrpc srx = {
		.srx_family = AF_RXRPC,
		.srx_service = VL_SERVICE_ID, /* ID dịch vụ RxRPC */
		.transport_type = SOCK_DGRAM, /* loại ổ cắm truyền tải */
		.transport.sin_family = AF_INET,
		.transport.sin_port = htons(7000), /* AFS gọi lại */
		.transport.sin_address = 0, /* tất cả giao diện cục bộ */
	};
	bind(server, &srx, sizeof(srx));

Nhiều ID dịch vụ có thể được liên kết với một ổ cắm, miễn là phương thức vận chuyển
     các thông số đều giống nhau.  Giới hạn hiện tại là hai.  Để làm điều này, hãy liên kết()
     nên được gọi hai lần.

(4) Nếu cần nâng cấp dịch vụ thì hai ID dịch vụ đầu tiên phải được
     bị ràng buộc và sau đó phải đặt tùy chọn sau ::

dịch vụ_ids ngắn chưa được ký [2] = { from_ID, to_ID };
	setsockopt(máy chủ, SOL_RXRPC, RXRPC_UPGRADEABLE_SERVICE,
		   service_ids, sizeof(service_ids));

Điều này sẽ tự động nâng cấp các kết nối trên dịch vụ từ_ID lên dịch vụ
     to_ID nếu họ yêu cầu.  Điều này sẽ được phản ánh trong msg_name thu được
     thông qua recvmsg() khi dữ liệu yêu cầu được gửi đến không gian người dùng.

(5) Sau đó, máy chủ được thiết lập để lắng nghe các cuộc gọi đến::

lắng nghe (máy chủ, 100);

(6) Hạt nhân thông báo cho máy chủ về các kết nối đến đang chờ xử lý bằng cách gửi
     đó là một thông điệp cho mỗi người.  Điều này được nhận bằng recvmsg() trên máy chủ
     ổ cắm.  Nó không có dữ liệu và có một thông báo điều khiển không có dữ liệu
     đính kèm::

RXRPC_NEW_CALL

Địa chỉ có thể được trả lại bởi recvmsg() tại thời điểm này phải là
     bị bỏ qua vì cuộc gọi mà tin nhắn được đăng có thể đã kết thúc
     thời điểm nó được chấp nhận - trong trường hợp đó cuộc gọi đầu tiên vẫn ở trong hàng đợi
     sẽ được chấp nhận.

(7) Sau đó, máy chủ chấp nhận cuộc gọi mới bằng cách phát hành một sendmsg() với hai
     phần dữ liệu kiểm soát và không có dữ liệu thực tế:

====================================================
	RXRPC_ACCEPT cho biết chấp nhận kết nối
	RXRPC_USER_CALL_ID chỉ định ID người dùng cho cuộc gọi này
	====================================================

(8) Gói dữ liệu yêu cầu đầu tiên sau đó sẽ được đăng lên ổ cắm máy chủ để
     recvmsg() để nhận.  Tại thời điểm đó, địa chỉ RxRPC cho cuộc gọi có thể
     được đọc từ các trường địa chỉ trong cấu trúc msghdr.

Dữ liệu yêu cầu tiếp theo sẽ được đăng lên ổ cắm máy chủ cho recvmsg()
     để thu thập khi nó đến.  Tất cả trừ phần cuối cùng của dữ liệu yêu cầu sẽ
     được phân phối với cờ MSG_MORE.

Tất cả dữ liệu sẽ được gửi kèm theo thông báo kiểm soát sau:


==========================================================
	RXRPC_USER_CALL_ID chỉ định ID người dùng cho cuộc gọi này
	==========================================================

(9) Sau đó, dữ liệu trả lời sẽ được đăng lên ổ cắm máy chủ bằng cách sử dụng một chuỗi
     của các cuộc gọi sendmsg(), mỗi cuộc gọi có kèm theo các thông báo điều khiển sau:

==========================================================
	RXRPC_USER_CALL_ID chỉ định ID người dùng cho cuộc gọi này
	==========================================================

MSG_MORE phải được đặt trong msghdr::msg_flags trên tất cả trừ tin nhắn cuối cùng
     cho một cuộc gọi cụ thể.

(10) ACK cuối cùng từ máy khách sẽ được đăng để recvmsg() truy xuất
     khi nó được nhận.  Nó sẽ có dạng một tin nhắn không có dữ liệu với hai
     thông báo điều khiển đính kèm:

==========================================================
	RXRPC_USER_CALL_ID chỉ định ID người dùng cho cuộc gọi này
	RXRPC_ACK biểu thị ACK cuối cùng (không có dữ liệu)
	==========================================================

MSG_EOR sẽ được gắn cờ để cho biết đây là thông báo cuối cùng dành cho
     cuộc gọi này.

(11) Cho đến thời điểm gói dữ liệu trả lời cuối cùng được gửi đi, cuộc gọi có thể được thực hiện
     bị hủy bỏ bằng cách gọi sendmsg() với một tin nhắn không có dữ liệu với nội dung sau
     thông báo điều khiển đính kèm:

==========================================================
	RXRPC_USER_CALL_ID chỉ định ID người dùng cho cuộc gọi này
	RXRPC_ABORT biểu thị mã hủy bỏ (dữ liệu 4 byte)
	==========================================================

Bất kỳ gói nào đang chờ trong hàng đợi nhận của socket sẽ bị loại bỏ nếu
     cái này được ban hành.

Lưu ý rằng tất cả các thông tin liên lạc cho một dịch vụ cụ thể diễn ra thông qua
một ổ cắm máy chủ, sử dụng các thông báo điều khiển trên sendmsg() và recvmsg() để
xác định cuộc gọi bị ảnh hưởng.


Giao diện hạt nhân AF_RXRPC
=========================

Mô-đun AF_RXRPC cũng cung cấp giao diện để sử dụng bởi các tiện ích trong kernel
chẳng hạn như hệ thống tập tin AFS.  Điều này cho phép một tiện ích như vậy:

(1) Sử dụng các khóa khác nhau trực tiếp trên các lệnh gọi của từng máy khách trên một ổ cắm
     thay vì phải mở cả đống ổ cắm, mỗi ổ cắm một phím
     có thể muốn sử dụng.

(2) Tránh thực hiện cuộc gọi RxRPC request_key() tại thời điểm phát sinh cuộc gọi hoặc
     việc mở một ổ cắm.  Thay vào đó, tiện ích có trách nhiệm yêu cầu một
     phím vào điểm thích hợp.  Ví dụ: AFS sẽ thực hiện điều này trong VFS
     các hoạt động như open() hoặc unlink().  Chìa khóa sau đó được chuyển qua
     khi cuộc gọi được bắt đầu.

(3) Yêu cầu sử dụng thứ khác ngoài GFP_KERNEL để phân bổ bộ nhớ.

(4) Tránh sử dụng lệnh gọi recvmsg().  Tin nhắn RxRPC có thể được
     bị chặn trước khi chúng được đưa vào hàng đợi socket Rx và socket
     bộ đệm được thao tác trực tiếp.

Để sử dụng cơ sở RxRPC, tiện ích kernel vẫn phải mở ổ cắm AF_RXRPC,
liên kết một địa chỉ phù hợp và lắng nghe xem đó có phải là ổ cắm máy chủ hay không, nhưng
sau đó nó chuyển cái này tới các chức năng giao diện kernel.

Các chức năng giao diện kernel như sau:

(#) Bắt đầu cuộc gọi khách hàng mới::

cấu trúc rxrpc_call *
	rxrpc_kernel_begin_call(struct socket *sock,
				cấu trúc sockaddr_rxrpc *srx,
				phím cấu trúc * phím,
				user_call_ID dài chưa được ký,
				s64 tx_total_len,
				gfp_t gfp,
				rxrpc_notify_rx_t thông báo_rx,
				nâng cấp bool,
				bool nội bộ,
				unsigned int debug_id);

Điều này phân bổ cơ sở hạ tầng để thực hiện cuộc gọi RxRPC mới và gán
     số cuộc gọi và số kết nối.  Cuộc gọi sẽ được thực hiện trên cổng UDP
     ổ cắm được liên kết với.  Cuộc gọi sẽ đi đến địa chỉ đích của một
     ổ cắm máy khách được kết nối trừ khi một giải pháp thay thế được cung cấp (srx là
     không phải NULL).

Nếu một khóa được cung cấp thì khóa này sẽ được sử dụng để bảo mật cuộc gọi thay vì
     chìa khóa được gắn vào ổ cắm bằng ổ cắm RXRPC_SECURITY_KEY.  Cuộc gọi
     được bảo mật theo cách này sẽ vẫn chia sẻ kết nối nếu có thể.

user_call_ID tương đương với giá trị được cung cấp cho sendmsg() trong
     bộ đệm dữ liệu điều khiển.  Hoàn toàn khả thi khi sử dụng điều này để chỉ ra một
     cấu trúc dữ liệu hạt nhân

tx_total_len là lượng dữ liệu người gọi dự định truyền
     với lệnh gọi này (hoặc -1 nếu không xác định tại thời điểm này).  Đặt kích thước dữ liệu
     cho phép hạt nhân mã hóa trực tiếp vào bộ đệm gói, do đó
     lưu một bản sao.  Giá trị có thể không nhỏ hơn -1.

thông báo_rx là một con trỏ tới một hàm được gọi khi các sự kiện như
     các gói dữ liệu đến hoặc việc hủy bỏ từ xa xảy ra.

nâng cấp phải được đặt thành đúng nếu hoạt động của máy khách yêu cầu điều đó
     máy chủ nâng cấp dịch vụ lên một dịch vụ tốt hơn.  ID dịch vụ kết quả
     được trả về bởi rxrpc_kernel_recv_data().

intr phải được đặt thành true nếu cuộc gọi bị gián đoạn.  Nếu điều này
     chưa được thiết lập, chức năng này có thể không quay trở lại cho đến khi một kênh được
     được phân bổ; nếu được đặt, hàm có thể trả về -ERESTARTSYS.

debug_id là ID gỡ lỗi cuộc gọi được sử dụng để theo dõi.  Đây có thể là
     thu được bằng cách tăng dần rxrpc_debug_id.

Nếu chức năng này thành công, một tham chiếu không rõ ràng tới lệnh gọi RxRPC sẽ được
     đã quay trở lại.  Người gọi bây giờ có một tham chiếu về điều này và nó phải là
     đã kết thúc đúng cách.

(#) Tắt cuộc gọi của khách hàng::

void rxrpc_kernel_shutdown_call(struct socket *sock,
					cấu trúc rxrpc_call *gọi);

Điều này được sử dụng để tắt cuộc gọi đã bắt đầu trước đó.  user_call_ID là
     đã bị xóa khỏi kiến thức của AF_RXRPC và sẽ không được nhìn thấy nữa trong
     liên kết với cuộc gọi được chỉ định.

(#) Giải phóng giới thiệu trong cuộc gọi của khách hàng::

void rxrpc_kernel_put_call(struct socket *sock,
				   cấu trúc rxrpc_call *gọi);

Điều này được sử dụng để giải phóng giới thiệu của người gọi trong cuộc gọi rxrpc.

(#) Gửi dữ liệu qua cuộc gọi::

khoảng trống typedef (*rxrpc_notify_end_tx_t)(struct sock *sk,
					      user_call_ID dài chưa được ký,
					      cấu trúc sk_buff *skb);

int rxrpc_kernel_send_data(struct socket *sock,
				   cấu trúc rxrpc_call *gọi,
				   thông điệp cấu trúc *tin nhắn,
				   size_t len,
				   rxrpc_notify_end_tx_t notification_end_rx);

Điều này được sử dụng để cung cấp phần yêu cầu của cuộc gọi máy khách hoặc
     trả lời một phần của cuộc gọi máy chủ.  msg.msg_iovlen và msg.msg_iov chỉ định
     bộ đệm dữ liệu sẽ được sử dụng.  msg_iov có thể không phải là NULL và phải trỏ
     dành riêng cho các địa chỉ ảo trong kernel.  msg.msg_flags có thể được cung cấp
     MSG_MORE nếu có dữ liệu tiếp theo được gửi cho cuộc gọi này.

Tin nhắn không được chỉ định địa chỉ đích, dữ liệu điều khiển hoặc bất kỳ cờ nào
     khác với MSG_MORE.  len là tổng lượng dữ liệu cần truyền.

thông báo_end_rx có thể là NULL hoặc nó có thể được sử dụng để chỉ định một chức năng
     được gọi khi cuộc gọi thay đổi trạng thái để kết thúc giai đoạn Tx.  Chức năng này là
     được gọi với một spinlock được giữ để ngăn gói DATA cuối cùng được
     được truyền cho đến khi hàm trả về.

(#) Nhận dữ liệu từ cuộc gọi::

int rxrpc_kernel_recv_data(struct socket *sock,
				   cấu trúc rxrpc_call *gọi,
				   vô hiệu *buf,
				   kích thước size_t,
				   kích thước_t *_bù đắp,
				   bool muốn_more,
				   u32 *_abort,
				   u16 *_service)

Điều này được sử dụng để nhận dữ liệu từ phần trả lời của cuộc gọi khách hàng
      hoặc phần yêu cầu của cuộc gọi dịch vụ.  buf và kích thước chỉ định bao nhiêu
      dữ liệu mong muốn và nơi lưu trữ nó.  *_offset được thêm vào buf và
      trừ đi kích thước nội bộ; số lượng được sao chép vào bộ đệm là
      được thêm vào *_offset trước khi quay lại.

want_more phải đúng nếu cần thêm dữ liệu sau đó
      hài lòng và sai nếu đây là mục cuối cùng của giai đoạn nhận.

Có ba kết quả trả về thông thường: 0 nếu bộ đệm được lấp đầy và want_more
      là đúng; 1 nếu bộ đệm đã được lấp đầy, gói DATA cuối cùng đã được
      trống rỗng và want_more là sai; và -EAGAIN nếu chức năng này cần được
      được gọi lại.

Nếu gói DATA cuối cùng được xử lý nhưng bộ đệm chứa ít hơn
      số tiền được yêu cầu, EBADMSG sẽ được trả lại.  Nếu muốn_more chưa được đặt, nhưng
      có nhiều dữ liệu hơn, EMSGSIZE được trả về.

Nếu phát hiện ABORT từ xa, mã hủy nhận được sẽ được lưu trong
      ZZ0000ZZ và ECONNABORTED sẽ được trả lại.

ID dịch vụ mà cuộc gọi kết thúc được trả về *_service.
      Điều này có thể được sử dụng để xem liệu cuộc gọi có được nâng cấp dịch vụ hay không.

(#) Hủy cuộc gọi??

     ::

void rxrpc_kernel_abort_call(struct socket *sock,
				     cấu trúc rxrpc_call *gọi,
				     u32 abort_code);

Lệnh này được sử dụng để hủy cuộc gọi nếu nó vẫn ở trạng thái có thể hủy.  các
     mã hủy bỏ được chỉ định sẽ được đặt trong tin nhắn ABORT được gửi.

(#) Chặn các tin nhắn RxRPC đã nhận::

khoảng trống typedef (*rxrpc_interceptor_t)(struct sock *sk,
					    user_call_ID dài chưa được ký,
					    cấu trúc sk_buff *skb);

trống rỗng
	rxrpc_kernel_intercept_rx_messages(struct socket *sock,
					   thiết bị chặn rxrpc_interceptor_t);

Thao tác này sẽ cài đặt chức năng chặn trên ổ cắm AF_RXRPC được chỉ định.
     Tất cả các tin nhắn lẽ ra sẽ xuất hiện trong hàng đợi Rx của socket đều
     sau đó chuyển hướng đến chức năng này.  Lưu ý phải cẩn thận trong quá trình xử lý
     các tin nhắn theo đúng thứ tự để duy trì tính tuần tự của tin nhắn DATA.

Bản thân chức năng chặn được cung cấp địa chỉ của ổ cắm
     và xử lý tin nhắn đến, ID được tiện ích kernel gán
     đến cuộc gọi và bộ đệm ổ cắm chứa tin nhắn.

Trường skb->mark cho biết loại thông báo:

===========================================================================
	Ý nghĩa đánh dấu
	===========================================================================
	Thông báo dữ liệu RXRPC_SKB_MARK_DATA
	RXRPC_SKB_MARK_FINAL_ACK Đã nhận được ACK cuối cùng cho cuộc gọi đến
	RXRPC_SKB_MARK_BUSY Cuộc gọi của khách hàng bị từ chối do máy chủ bận
	RXRPC_SKB_MARK_REMOTE_ABORT Cuộc gọi bị hủy ngang hàng
	RXRPC_SKB_MARK_NET_ERROR Đã phát hiện lỗi mạng
	RXRPC_SKB_MARK_LOCAL_ERROR Đã gặp lỗi cục bộ
	RXRPC_SKB_MARK_NEW_CALL Cuộc gọi đến mới đang chờ chấp nhận
	===========================================================================

Thông báo hủy bỏ từ xa có thể được thăm dò bằng rxrpc_kernel_get_abort_code().
     Hai thông báo lỗi có thể được thăm dò bằng rxrpc_kernel_get_error_number().
     Một cuộc gọi mới có thể được chấp nhận bằng rxrpc_kernel_accept_call().

Tin nhắn dữ liệu có thể được trích xuất nội dung của chúng bằng một loạt các
     chức năng thao tác bộ đệm ổ cắm.  Một thông điệp dữ liệu có thể được xác định
     là người cuối cùng trong chuỗi có rxrpc_kernel_is_data_last().  Khi một
     thông báo dữ liệu đã được sử dụng hết, rxrpc_kernel_data_consumed() sẽ là
     kêu gọi nó.

Tin nhắn phải được xử lý tới rxrpc_kernel_free_skb() để loại bỏ.  Nó
     có thể nhận thêm lượt giới thiệu cho tất cả các loại tin nhắn để giải phóng sau này,
     nhưng điều này có thể ghim trạng thái cuộc gọi cho đến khi tin nhắn cuối cùng được giải phóng.

(#) Chấp nhận cuộc gọi đến::

cấu trúc rxrpc_call *
	rxrpc_kernel_accept_call(struct socket *sock,
				 user_call_ID dài không dấu);

Điều này được sử dụng để chấp nhận cuộc gọi đến và gán cho nó ID cuộc gọi.  Cái này
     chức năng tương tự như rxrpc_kernel_begin_call() và các cuộc gọi được chấp nhận phải
     được kết thúc theo cách tương tự.

Nếu chức năng này thành công, một tham chiếu không rõ ràng tới lệnh gọi RxRPC sẽ được
     đã quay trở lại.  Người gọi bây giờ có một tham chiếu về điều này và nó phải là
     đã kết thúc đúng cách.

(#) Từ chối cuộc gọi đến::

int rxrpc_kernel_reject_call(struct socket *sock);

Điều này được sử dụng để từ chối cuộc gọi đến đầu tiên trên hàng đợi của ổ cắm với
     một tin nhắn BUSY.  -ENODATA được trả về nếu không có cuộc gọi đến.
     Các lỗi khác có thể được trả về nếu cuộc gọi bị hủy (-ECONNABORTED)
     hoặc đã hết thời gian chờ (-ETIME).

(#) Cấp phát khóa null để thực hiện bảo mật ẩn danh::

khóa cấu trúc *rxrpc_get_null_key(const char *keyname);

Điều này được sử dụng để phân bổ khóa RxRPC null có thể được sử dụng để chỉ ra
     bảo mật ẩn danh cho một tên miền cụ thể.

(#) Lấy địa chỉ ngang hàng của cuộc gọi::

void rxrpc_kernel_get_peer(struct socket *sock, struct rxrpc_call *call,
				   cấu trúc sockaddr_rxrpc *_srx);

Điều này được sử dụng để tìm địa chỉ ngang hàng từ xa của một cuộc gọi.

(#) Đặt tổng kích thước dữ liệu truyền trên một cuộc gọi::

void rxrpc_kernel_set_tx_length(struct socket *sock,
					cấu trúc rxrpc_call *gọi,
					s64 tx_total_len);

Điều này đặt lượng dữ liệu mà người gọi dự định truyền trên mạng
     gọi.  Nó dự định được sử dụng để đặt kích thước trả lời theo yêu cầu
     kích thước nên được đặt khi cuộc gọi được bắt đầu.  tx_total_len không thể ít hơn
     hơn không.

(#) Nhận cuộc gọi RTT::

u64 rxrpc_kernel_get_rtt(struct socket *sock, struct rxrpc_call *call);

Nhận thời gian RTT cho thiết bị ngang hàng đang sử dụng bằng cuộc gọi.  Giá trị trả về nằm trong
     nano giây.

(#) Kiểm tra cuộc gọi vẫn còn hoạt động::

bool rxrpc_kernel_check_life(struct socket *sock,
				     cấu trúc rxrpc_call *gọi,
				     u32 *_life);
	void rxrpc_kernel_probe_life(struct socket *sock,
				     cấu trúc rxrpc_call *gọi);

Hàm đầu tiên trả về ZZ0000ZZ một số được cập nhật khi
     ACK được nhận từ thiết bị ngang hàng (đặc biệt bao gồm PING RESPONSE ACK
     mà chúng tôi có thể gợi ra bằng cách gửi ACK PING để xem cuộc gọi có còn tồn tại không
     trên máy chủ).  Người gọi nên so sánh số lượng của hai cuộc gọi để xem
     cuộc gọi có còn tồn tại sau khi chờ một khoảng thời gian thích hợp hay không.  Nó cũng
     trả về true miễn là cuộc gọi chưa đạt đến trạng thái hoàn thành.

Điều này cho phép người gọi xác định xem máy chủ có còn liên lạc được hay không và
     nếu cuộc gọi vẫn còn tồn tại trên máy chủ trong khi chờ máy chủ thực hiện
     xử lý một hoạt động của khách hàng.

Chức năng thứ hai khiến một ping ACK được truyền đi để cố gắng kích động
     ngang hàng phản hồi, điều này sẽ khiến giá trị được trả về bởi
     chức năng đầu tiên thay đổi.  Lưu ý rằng điều này phải được gọi trong TASK_RUNNING
     trạng thái.

(#) Gắn ổ cắm RXRPC_MIN_SECURITY_LEVEL vào ổ cắm từ bên trong
     hạt nhân::

int rxrpc_sock_set_min_security_level(struct sock *sk,
					     giá trị int không dấu);

Điều này chỉ định mức độ bảo mật tối thiểu cần thiết cho các cuộc gọi trên mạng này
     ổ cắm.


Thông số có thể cấu hình
=======================

Trình điều khiển giao thức RxRPC có một số tham số có thể định cấu hình có thể được
được điều chỉnh thông qua sysctls trong /proc/net/rxrpc/:

(#) req_ack_delay

Khoảng thời gian tính bằng mili giây sau khi nhận được gói tin với
     cờ yêu cầu-ack được đặt trước khi chúng tôi tôn trọng cờ và thực sự gửi
     đã yêu cầu xác nhận.

Thông thường phía bên kia sẽ không ngừng gửi gói tin cho đến khi có thông báo
     Cửa sổ tiếp nhận đã đầy (tối đa là 255 gói), do đó việc trì hoãn
     ACK cho phép một số gói trở thành ACK trong một lần.

(#) soft_ack_delay

Lượng thời gian tính bằng mili giây sau khi nhận được gói mới trước khi chúng tôi
     tạo một ACK mềm để thông báo cho người gửi rằng nó không cần gửi lại.

(#) nhàn rỗi_ack_delay

Khoảng thời gian tính bằng mili giây sau tất cả các gói hiện có trong
     hàng đợi nhận được đã được sử dụng trước khi chúng tôi tạo ra một ACK cứng để thông báo
     người gửi có thể giải phóng bộ đệm của mình, giả sử không có lý do nào khác xảy ra
     chúng tôi sẽ gửi ACK.

(#) gửi lại_timeout

Khoảng thời gian tính bằng mili giây sau khi truyền một gói trước khi chúng ta
     truyền lại nó, giả sử không nhận được ACK nào từ máy thu thông báo
     chúng tôi họ đã hiểu nó.

(#) max_call_lifetime

Khoảng thời gian tối đa tính bằng giây mà cuộc gọi có thể diễn ra
     trước khi chúng ta giết nó trước.

(#) dead_call_expiry

Lượng thời gian tính bằng giây trước khi chúng tôi xóa cuộc gọi chết khỏi cuộc gọi
     danh sách.  Các cuộc gọi không hoạt động được lưu giữ trong một thời gian nhằm mục đích
     lặp lại các gói ACK và ABORT.

(#) kết nối_hết hạn

Lượng thời gian tính bằng giây sau khi kết nối được sử dụng lần cuối trước khi chúng tôi
     loại bỏ nó khỏi danh sách kết nối.  Trong khi một kết nối đang tồn tại,
     nó phục vụ như một phần giữ chỗ cho an ninh được đàm phán; khi nó bị xóa,
     an ninh phải được đàm phán lại.

(#) vận chuyển_hết hạn

Lượng thời gian tính bằng giây sau khi một phương tiện được sử dụng lần cuối trước khi chúng ta
     loại bỏ nó khỏi danh sách vận chuyển.  Khi một phương tiện vận tải đang tồn tại, nó
     dùng để neo dữ liệu ngang hàng và giữ bộ đếm ID kết nối.

(#) rxrpc_rx_window_size

Kích thước của cửa sổ nhận trong gói.  Đây là số lượng tối đa
     các gói đã nhận chưa được sử dụng mà chúng tôi sẵn sàng giữ trong bộ nhớ cho bất kỳ gói nào
     cuộc gọi cụ thể.

(#) rxrpc_rx_mtu

Kích thước gói MTU tối đa mà chúng tôi sẵn sàng nhận tính bằng byte.  Cái này
     cho biết liệu chúng tôi có sẵn sàng chấp nhận các gói lớn hay không.

(#) rxrpc_rx_jumbo_max

Số lượng gói tối đa mà chúng tôi sẵn sàng chấp nhận trong một gói lớn
     gói.  Các gói không đầu cuối trong gói jumbo phải chứa bốn byte
     tiêu đề cộng với chính xác 1412 byte dữ liệu.  Gói đầu cuối phải chứa
     tiêu đề bốn byte cộng với bất kỳ lượng dữ liệu nào.  Trong mọi trường hợp, một gói lớn
     kích thước không được vượt quá rxrpc_rx_mtu.


Tham khảo chức năng API
======================

.. kernel-doc:: net/rxrpc/af_rxrpc.c
.. kernel-doc:: net/rxrpc/call_object.c
.. kernel-doc:: net/rxrpc/key.c
.. kernel-doc:: net/rxrpc/oob.c
.. kernel-doc:: net/rxrpc/peer_object.c
.. kernel-doc:: net/rxrpc/recvmsg.c
.. kernel-doc:: net/rxrpc/rxgk.c
.. kernel-doc:: net/rxrpc/rxkad.c
.. kernel-doc:: net/rxrpc/sendmsg.c
.. kernel-doc:: net/rxrpc/server_key.c