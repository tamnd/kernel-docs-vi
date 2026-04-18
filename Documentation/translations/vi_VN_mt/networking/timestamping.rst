.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/timestamping.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Dấu thời gian
============


1. Giao diện điều khiển
=====================

Các giao diện để nhận dấu thời gian của gói mạng là:

SO_TIMESTAMP
  Tạo dấu thời gian cho mỗi gói đến (không nhất thiết phải
  đơn điệu) thời gian hệ thống. Báo cáo dấu thời gian qua recvmsg() trong
  thông báo điều khiển ở độ phân giải usec.
  SO_TIMESTAMP được định nghĩa là SO_TIMESTAMP_NEW hoặc SO_TIMESTAMP_OLD
  dựa trên kiểu kiến trúc và biểu diễn time_t của libc.
  Định dạng thông báo điều khiển có trong struct __kernel_old_timeval cho
  SO_TIMESTAMP_OLD và trong struct __kernel_sock_timeval cho
  Tùy chọn SO_TIMESTAMP_NEW tương ứng.

SO_TIMESTAMPNS
  Cơ chế đánh dấu thời gian tương tự như SO_TIMESTAMP, nhưng báo cáo
  dấu thời gian dưới dạng struct timespec ở độ phân giải nsec.
  SO_TIMESTAMPNS được định nghĩa là SO_TIMESTAMPNS_NEW hoặc SO_TIMESTAMPNS_OLD
  dựa trên kiểu kiến trúc và biểu diễn time_t của libc.
  Định dạng thông báo điều khiển nằm trong struct timespec cho SO_TIMESTAMPNS_OLD
  và trong struct __kernel_timespec cho các tùy chọn SO_TIMESTAMPNS_NEW
  tương ứng.

IP_MULTICAST_LOOP + SO_TIMESTAMP[NS]
  Chỉ dành cho multicast:dấu thời gian truyền gần đúng thu được bởi
  đọc gói lặp nhận dấu thời gian.

SO_TIMESTAMPING
  Tạo dấu thời gian khi nhận, truyền hoặc cả hai. Hỗ trợ
  nhiều nguồn dấu thời gian, bao gồm cả phần cứng. Hỗ trợ tạo
  dấu thời gian cho ổ cắm luồng.


1.1 SO_TIMESTAMP (cũng là SO_TIMESTAMP_OLD và SO_TIMESTAMP_NEW)
-------------------------------------------------------------

Tùy chọn ổ cắm này cho phép đánh dấu thời gian của các datagram khi nhận
con đường. Bởi vì socket đích, nếu có, không được biết sớm trong
ngăn xếp mạng, tính năng này phải được bật cho tất cả các gói. các
điều tương tự cũng đúng với tất cả các tùy chọn dấu thời gian nhận sớm.

Để biết chi tiết về giao diện, xem ZZ0000ZZ.

Luôn sử dụng dấu thời gian SO_TIMESTAMP_NEW để luôn nhận được dấu thời gian
định dạng cấu trúc __kernel_sock_timeval.

SO_TIMESTAMP_OLD trả về dấu thời gian không chính xác sau năm 2038
trên máy 32 bit.

1.2 SO_TIMESTAMPNS (cũng là SO_TIMESTAMPNS_OLD và SO_TIMESTAMPNS_NEW)
-------------------------------------------------------------------

Tùy chọn này giống hệt với SO_TIMESTAMP ngoại trừ kiểu dữ liệu được trả về.
Cấu trúc thời gian của nó cho phép dấu thời gian có độ phân giải (ns) cao hơn so với
khoảng thời gian của SO_TIMESTAMP (ms).

Luôn sử dụng dấu thời gian SO_TIMESTAMPNS_NEW để luôn nhận được dấu thời gian
định dạng cấu trúc __kernel_timespec.

SO_TIMESTAMPNS_OLD trả về dấu thời gian không chính xác sau năm 2038
trên máy 32 bit.

1.3 SO_TIMESTAMPING (cũng là SO_TIMESTAMPING_OLD và SO_TIMESTAMPING_NEW)
----------------------------------------------------------------------

Hỗ trợ nhiều loại yêu cầu dấu thời gian. Kết quả là, điều này
tùy chọn socket lấy một bitmap của cờ, không phải boolean. TRONG::

err = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING, &val, sizeof(val));

val là một số nguyên với bất kỳ bit nào sau đây được đặt. Cài đặt khác
bit trả về EINVAL và không thay đổi trạng thái hiện tại.

Tùy chọn ổ cắm định cấu hình việc tạo dấu thời gian cho từng cá nhân
sk_buffs (1.3.1), dấu thời gian báo cáo lỗi của ổ cắm
hàng đợi (1.3.2) và tùy chọn (1.3.3). Việc tạo dấu thời gian cũng có thể
được bật cho các cuộc gọi gửi tin nhắn riêng lẻ bằng cmsg (1.3.4).


1.3.1 Tạo dấu thời gian
^^^^^^^^^^^^^^^^^^^^^^^^^^

Một số bit được yêu cầu tới ngăn xếp để cố gắng tạo dấu thời gian. bất kỳ
sự kết hợp của chúng là hợp lệ. Những thay đổi đối với các bit này áp dụng cho các bit mới
các gói đã tạo chứ không phải các gói đã có trong ngăn xếp. Kết quả là, nó
có thể yêu cầu có chọn lọc dấu thời gian cho một tập hợp con các gói
(ví dụ: để lấy mẫu) bằng cách nhúng lệnh gọi send() trong hai setsockopt
cuộc gọi, một cuộc gọi để kích hoạt việc tạo dấu thời gian và một cuộc gọi để vô hiệu hóa nó.
Dấu thời gian cũng có thể được tạo ra vì những lý do khác ngoài việc
được yêu cầu bởi một ổ cắm cụ thể, chẳng hạn như khi nhận được dấu thời gian
kích hoạt toàn hệ thống, như đã giải thích trước đó.

SOF_TIMESTAMPING_RX_HARDWARE:
  Yêu cầu dấu thời gian rx do bộ điều hợp mạng tạo ra.

SOF_TIMESTAMPING_RX_SOFTWARE:
  Yêu cầu dấu thời gian rx khi dữ liệu vào kernel. Những dấu thời gian này
  được tạo ra ngay sau khi trình điều khiển thiết bị chuyển gói tin tới
  kernel nhận ngăn xếp.

SOF_TIMESTAMPING_TX_HARDWARE:
  Yêu cầu dấu thời gian tx do bộ điều hợp mạng tạo ra. Lá cờ này
  có thể được kích hoạt thông qua cả tùy chọn ổ cắm và thông báo điều khiển.

SOF_TIMESTAMPING_TX_SOFTWARE:
  Yêu cầu dấu thời gian tx khi dữ liệu rời khỏi kernel. Những dấu thời gian này
  được tạo trong trình điều khiển thiết bị càng gần càng tốt, nhưng luôn luôn
  trước đó, chuyển gói đến giao diện mạng. Do đó, họ
  yêu cầu hỗ trợ trình điều khiển và có thể không có sẵn cho tất cả các thiết bị.
  Cờ này có thể được kích hoạt thông qua cả tùy chọn ổ cắm và thông báo điều khiển.

SOF_TIMESTAMPING_TX_SCHED:
  Yêu cầu dấu thời gian tx trước khi vào bộ lập lịch gói. hạt nhân
  độ trễ truyền, nếu dài, thường bị chi phối bởi độ trễ hàng đợi. các
  sự khác biệt giữa dấu thời gian này và dấu thời gian được chụp vào lúc
  SOF_TIMESTAMPING_TX_SOFTWARE sẽ hiển thị độ trễ này một cách độc lập
  của việc xử lý giao thức. Độ trễ phát sinh trong giao thức
  việc xử lý, nếu có, có thể được tính bằng cách trừ đi một không gian người dùng
  dấu thời gian được lấy ngay trước khi gửi() từ dấu thời gian này. Bật
  máy có thiết bị ảo nơi gói được truyền đi
  thông qua nhiều thiết bị và do đó có nhiều bộ lập lịch gói,
  một dấu thời gian được tạo ra ở mỗi lớp. Điều này cho phép phạt tiền
  phép đo chi tiết về độ trễ xếp hàng. Cờ này có thể được kích hoạt
  thông qua cả tùy chọn ổ cắm và thông báo điều khiển.

SOF_TIMESTAMPING_TX_ACK:
  Yêu cầu dấu thời gian tx khi tất cả dữ liệu trong bộ đệm gửi đã được
  thừa nhận. Điều này chỉ có ý nghĩa đối với các giao thức đáng tin cậy. Đó là
  hiện chỉ được triển khai cho TCP. Đối với giao thức đó, nó có thể
  đo lường báo cáo quá mức, vì dấu thời gian được tạo khi tất cả
  dữ liệu lên đến và bao gồm cả bộ đệm tại send() đã được xác nhận:
  sự thừa nhận tích lũy. Cơ chế bỏ qua SACK và FACK.
  Cờ này có thể được kích hoạt thông qua cả tùy chọn ổ cắm và thông báo điều khiển.

SOF_TIMESTAMPING_TX_COMPLETION:
  Yêu cầu dấu thời gian tx khi hoàn thành gói tx.  Việc hoàn thành
  dấu thời gian được tạo bởi kernel khi nó nhận được gói a
  báo cáo hoàn thành từ phần cứng. Phần cứng có thể báo cáo nhiều
  các gói cùng một lúc và dấu thời gian hoàn thành phản ánh thời gian của
  báo cáo và không phải thời gian tx thực tế. Cờ này có thể được kích hoạt thông qua cả hai
  tùy chọn ổ cắm và thông báo điều khiển.


1.3.2 Báo cáo về dấu thời gian
^^^^^^^^^^^^^^^^^^^^^^^^^

Ba bit còn lại kiểm soát dấu thời gian nào sẽ được báo cáo trong một
thông báo điều khiển được tạo ra. Những thay đổi đối với các bit diễn ra ngay lập tức
có hiệu lực tại các vị trí báo cáo dấu thời gian trong ngăn xếp. Dấu thời gian
chỉ được báo cáo cho các gói cũng có dấu thời gian liên quan
tập yêu cầu tạo.

SOF_TIMESTAMPING_SOFTWARE:
  Báo cáo bất kỳ dấu thời gian phần mềm nào khi có sẵn.

SOF_TIMESTAMPING_SYS_HARDWARE:
  Tùy chọn này không được dùng nữa và bị bỏ qua.

SOF_TIMESTAMPING_RAW_HARDWARE:
  Báo cáo dấu thời gian phần cứng được tạo bởi
  SOF_TIMESTAMPING_TX_HARDWARE hoặc SOF_TIMESTAMPING_RX_HARDWARE
  khi có sẵn.


1.3.3 Tùy chọn dấu thời gian
^^^^^^^^^^^^^^^^^^^^^^^

Giao diện hỗ trợ các tùy chọn

SOF_TIMESTAMPING_OPT_ID:
  Tạo một mã định danh duy nhất cùng với mỗi gói. Một quá trình có thể
  có nhiều yêu cầu đánh dấu thời gian đồng thời chưa được xử lý. Gói
  có thể được sắp xếp lại trong đường truyền, ví dụ như trong gói
  lịch trình. Trong trường hợp đó dấu thời gian sẽ được xếp hàng vào lỗi
  xếp hàng không theo thứ tự từ các lệnh gọi send() ban đầu. Không phải lúc nào cũng vậy
  có thể khớp duy nhất các dấu thời gian với các lệnh gọi send() ban đầu
  sau đó chỉ dựa vào thứ tự dấu thời gian hoặc kiểm tra tải trọng.

Tùy chọn này liên kết mỗi gói tại send() với một địa chỉ duy nhất
  định danh và trả về cùng với dấu thời gian. Mã định danh
  có nguồn gốc từ bộ đếm u32 trên mỗi ổ cắm (bao bọc). Đối với datagram
  socket, bộ đếm sẽ tăng theo mỗi gói được gửi. Đối với luồng
  socket, nó tăng dần theo từng byte. Đối với ổ cắm luồng, cũng được đặt
  SOF_TIMESTAMPING_OPT_ID_TCP, xem phần bên dưới.

Bộ đếm bắt đầu từ số 0. Nó được khởi tạo lần đầu tiên
  tùy chọn ổ cắm được kích hoạt. Nó được thiết lập lại mỗi khi tùy chọn được thực hiện
  được kích hoạt sau khi đã bị vô hiệu hóa. Việc đặt lại bộ đếm không
  thay đổi định danh của các gói hiện có trong hệ thống.

Tùy chọn này chỉ được thực hiện cho dấu thời gian truyền. Ở đó,
  dấu thời gian luôn được lặp cùng với cấu trúc sock_extends_err.
  Tùy chọn sửa đổi trường ee_data để chuyển một id duy nhất
  trong số tất cả các yêu cầu về dấu thời gian có thể xảy ra đồng thời cho
  ổ cắm đó.

Quá trình có thể tùy ý ghi đè ID được tạo mặc định, bằng cách
  chuyển một ID cụ thể với thông báo điều khiển SCM_TS_OPT_ID (không phải
  được hỗ trợ cho ổ cắm TCP)::

thông điệp cấu trúc *tin nhắn;
    ...
cmsg = CMSG_FIRSTHDR(tin nhắn);
    cmsg->cmsg_level = SOL_SOCKET;
    cmsg->cmsg_type = SCM_TS_OPT_ID;
    cmsg->cmsg_len = CMSG_LEN(sizeof(__u32));
    ZZ0000ZZ) CMSG_DATA(cmsg)) = opt_id;
    err = sendmsg(fd, msg, 0);


SOF_TIMESTAMPING_OPT_ID_TCP:
  Chuyển công cụ sửa đổi này cùng với SOF_TIMESTAMPING_OPT_ID cho TCP mới
  các ứng dụng đánh dấu thời gian. SOF_TIMESTAMPING_OPT_ID định nghĩa cách
  bộ đếm tăng dần cho các ổ cắm luồng, nhưng điểm bắt đầu của nó là
  không hoàn toàn tầm thường. Tùy chọn này khắc phục điều đó.

Đối với các ổ cắm luồng, nếu SOF_TIMESTAMPING_OPT_ID được đặt, điều này sẽ
  luôn luôn được thiết lập quá. Trên ổ cắm datagram, tùy chọn này không có hiệu lực.

Một kỳ vọng hợp lý là bộ đếm được đặt lại về 0 với
  lệnh gọi hệ thống để tạo ra một lệnh ghi() N byte tiếp theo
  dấu thời gian có bộ đếm N-1. SOF_TIMESTAMPING_OPT_ID_TCP
  thực hiện hành vi này trong mọi điều kiện.

SOF_TIMESTAMPING_OPT_ID không có công cụ sửa đổi thường báo cáo tương tự,
  đặc biệt là khi tùy chọn ổ cắm được đặt khi không có dữ liệu
  truyền tải. Nếu dữ liệu đang được truyền đi, nó có thể bị tắt bởi
  độ dài của hàng đợi đầu ra (SIOCOUTQ).

Sự khác biệt là do dựa trên snd_una so với write_seq.
  snd_una là phần bù trong luồng được thiết bị ngang hàng thừa nhận. Cái này
  phụ thuộc vào các yếu tố bên ngoài kiểm soát quá trình, chẳng hạn như mạng RTT.
  write_seq là byte cuối cùng được ghi bởi tiến trình. Sự bù đắp này là
  không bị ảnh hưởng bởi các yếu tố đầu vào bên ngoài.

Sự khác biệt rất nhỏ và khó có thể nhận thấy khi định cấu hình
  lúc tạo socket ban đầu, khi không có dữ liệu nào được xếp hàng hoặc gửi. Nhưng
  Hành vi của SOF_TIMESTAMPING_OPT_ID_TCP mạnh mẽ hơn bất kể
  khi tùy chọn ổ cắm được đặt.

SOF_TIMESTAMPING_OPT_CMSG:
  Hỗ trợ cmsg recv() cho tất cả các gói có dấu thời gian. Kiểm soát tin nhắn
  đã được hỗ trợ vô điều kiện trên tất cả các gói có nhận
  dấu thời gian và trên các gói IPv6 có dấu thời gian truyền. Tùy chọn này
  mở rộng chúng sang các gói IPv4 có dấu thời gian truyền. Một trường hợp sử dụng
  là để tương quan các gói với thiết bị đầu ra của chúng, bằng cách kích hoạt ổ cắm
  tùy chọn IP_PKTINFO đồng thời.


SOF_TIMESTAMPING_OPT_TSONLY:
  Chỉ áp dụng cho việc truyền dấu thời gian. Làm cho kernel trả về
  dấu thời gian dưới dạng cmsg bên cạnh một gói trống, trái ngược với
  cùng với gói tin gốc. Điều này làm giảm dung lượng bộ nhớ
  được tính vào ngân sách nhận của ổ cắm (SO_RCVBUF) và cung cấp
  dấu thời gian ngay cả khi sysctl net.core.tstamp_allow_data là 0.
  Tùy chọn này vô hiệu hóa SOF_TIMESTAMPING_OPT_CMSG.

SOF_TIMESTAMPING_OPT_STATS:
  Số liệu thống kê tùy chọn thu được cùng với dấu thời gian truyền.
  Nó phải được sử dụng cùng với SOF_TIMESTAMPING_OPT_TSONLY. Khi
  dấu thời gian truyền có sẵn, số liệu thống kê có sẵn trong
  bản tin điều khiển riêng biệt thuộc loại SCM_TIMESTAMPING_OPT_STATS, dưới dạng
  danh sách các loại TLV (struct nlattr). Những số liệu thống kê này cho phép
  ứng dụng để liên kết các số liệu thống kê lớp vận chuyển khác nhau với
  dấu thời gian truyền, chẳng hạn như một khối dữ liệu nhất định kéo dài bao lâu
  dữ liệu bị giới hạn bởi cửa sổ nhận của ngang hàng.

SOF_TIMESTAMPING_OPT_PKTINFO:
  Kích hoạt thông báo điều khiển SCM_TIMESTAMPING_PKTINFO cho các cuộc gọi đến
  các gói có dấu thời gian phần cứng. Thông báo chứa cấu trúc
  scm_ts_pktinfo, cung cấp chỉ mục của giao diện thực
  đã nhận được gói và độ dài của nó ở lớp 2. Hợp lệ (khác 0)
  chỉ mục giao diện sẽ chỉ được trả về nếu CONFIG_NET_RX_BUSY_POLL
  được bật và trình điều khiển đang sử dụng NAPI. Cấu trúc cũng chứa hai
  các trường khác, nhưng chúng được bảo lưu và không được xác định.

SOF_TIMESTAMPING_OPT_TX_SWHW:
  Yêu cầu cả dấu thời gian phần cứng và phần mềm cho các gói gửi đi
  khi SOF_TIMESTAMPING_TX_HARDWARE và SOF_TIMESTAMPING_TX_SOFTWARE
  được kích hoạt cùng một lúc. Nếu cả hai dấu thời gian được tạo,
  hai thông báo riêng biệt sẽ được lặp vào hàng đợi lỗi của ổ cắm,
  mỗi cái chỉ chứa một dấu thời gian.

SOF_TIMESTAMPING_OPT_RX_FILTER:
  Lọc ra dấu thời gian nhận giả: báo cáo dấu thời gian nhận
  chỉ khi cờ tạo dấu thời gian phù hợp được bật.

Dấu thời gian nhận được tạo sớm trong đường dẫn vào, trước khi
  Ổ cắm đích của gói đã được biết. Nếu bất kỳ ổ cắm nào cho phép nhận
  dấu thời gian, các gói cho tất cả ổ cắm sẽ nhận được các gói có dấu thời gian.
  Bao gồm những người yêu cầu báo cáo dấu thời gian với
  SOF_TIMESTAMPING_SOFTWARE và/hoặc SOF_TIMESTAMPING_RAW_HARDWARE, nhưng
  không yêu cầu nhận việc tạo dấu thời gian. Điều này có thể xảy ra khi
  chỉ yêu cầu dấu thời gian truyền.

Việc nhận được dấu thời gian giả nói chung là bình thường. Một quá trình có thể
  bỏ qua giá trị khác 0 không mong muốn. Nhưng nó làm cho hành vi trở nên tinh tế
  phụ thuộc vào các socket khác. Cờ này cô lập ổ cắm để biết thêm
  hành vi xác định.

Các ứng dụng mới được khuyến khích chuyển SOF_TIMESTAMPING_OPT_ID tới
phân biệt dấu thời gian và SOF_TIMESTAMPING_OPT_TSONLY để hoạt động
bất kể cài đặt của sysctl net.core.tstamp_allow_data.

Một ngoại lệ là khi một tiến trình cần thêm dữ liệu cmsg, ví dụ:
instance SOL_IP/IP_PKTINFO để phát hiện giao diện mạng đầu ra.
Sau đó chuyển tùy chọn SOF_TIMESTAMPING_OPT_CMSG. Tùy chọn này phụ thuộc vào
có quyền truy cập vào nội dung của gói gốc, do đó không thể
kết hợp với SOF_TIMESTAMPING_OPT_TSONLY.


1.3.4. Kích hoạt dấu thời gian thông qua thông báo điều khiển
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ngoài các tùy chọn ổ cắm, có thể yêu cầu tạo dấu thời gian
mỗi lần ghi qua cmsg, chỉ dành cho SOF_TIMESTAMPING_TX_* (xem Phần 1.3.1).
Bằng cách sử dụng tính năng này, các ứng dụng có thể lấy mẫu dấu thời gian trên mỗi lần gửi tin nhắn()
mà không phải trả phí cho việc bật và tắt dấu thời gian thông qua
setockopt::

thông điệp cấu trúc *tin nhắn;
  ...
cmsg = CMSG_FIRSTHDR(tin nhắn);
  cmsg->cmsg_level = SOL_SOCKET;
  cmsg->cmsg_type = SO_TIMESTAMPING;
  cmsg->cmsg_len = CMSG_LEN(sizeof(__u32));
  ZZ0000ZZ) CMSG_DATA(cmsg)) = SOF_TIMESTAMPING_TX_SCHED |
				 SOF_TIMESTAMPING_TX_SOFTWARE |
				 SOF_TIMESTAMPING_TX_ACK;
  err = sendmsg(fd, msg, 0);

Cờ SOF_TIMESTAMPING_TX_* được đặt qua cmsg sẽ ghi đè
cờ SOF_TIMESTAMPING_TX_* được đặt qua setsockopt.

Hơn nữa, các ứng dụng vẫn phải kích hoạt tính năng báo cáo dấu thời gian thông qua
setsockopt để nhận dấu thời gian::

__u32 val = SOF_TIMESTAMPING_SOFTWARE |
	      SOF_TIMESTAMPING_OPT_ID /* hoặc bất kỳ cờ nào khác */;
  err = setsockopt(fd, SOL_SOCKET, SO_TIMESTAMPING, &val, sizeof(val));


1.4 Dấu thời gian dòng byte
-------------------------

Giao diện SO_TIMESTAMPING hỗ trợ đánh dấu thời gian của byte trong
dòng byte. Mỗi yêu cầu được hiểu là một yêu cầu về thời điểm
toàn bộ nội dung của bộ đệm đã vượt qua điểm đánh dấu thời gian. Đó
là, đối với các luồng, tùy chọn SOF_TIMESTAMPING_TX_SOFTWARE sẽ ghi lại
khi tất cả byte đã đến trình điều khiển thiết bị, bất kể bằng cách nào
nhiều gói dữ liệu đã được chuyển đổi thành.

Nói chung, dòng byte không có dấu phân cách tự nhiên và do đó
mối tương quan giữa dấu thời gian với dữ liệu là không hề nhỏ. Một phạm vi byte
có thể được chia thành các phân đoạn, bất kỳ phân đoạn nào cũng có thể được hợp nhất (có thể
các phần kết hợp của bộ đệm được phân đoạn trước đó được liên kết với
các cuộc gọi send() độc lập). Các phân đoạn có thể được sắp xếp lại và giống nhau
phạm vi byte có thể cùng tồn tại trong nhiều phân đoạn cho các giao thức
thực hiện việc truyền lại.

Điều cần thiết là tất cả các dấu thời gian đều thực hiện cùng một ngữ nghĩa,
bất kể những biến đổi có thể xảy ra này, nếu không thì chúng
không thể so sánh được. Xử lý các trường hợp góc “hiếm” khác với
trường hợp đơn giản (ánh xạ 1:1 từ bộ đệm sang skb) là không đủ
bởi vì việc gỡ lỗi hiệu suất thường cần tập trung vào các ngoại lệ như vậy.

Trong thực tế, dấu thời gian có thể tương quan với các phân đoạn của
dòng byte một cách nhất quán, nếu cả ngữ nghĩa của dấu thời gian và
thời điểm đo được chọn chính xác. Thử thách này là không
khác với việc quyết định chiến lược phân mảnh IP. Ở đó,
định nghĩa là chỉ đoạn đầu tiên được đánh dấu thời gian. cho
dòng byte, chúng tôi đã chọn rằng dấu thời gian chỉ được tạo khi tất cả
byte đã vượt qua một điểm. SOF_TIMESTAMPING_TX_ACK như được định nghĩa là dễ dàng
thực hiện và lý do về. Việc triển khai phải tính đến
tài khoản SACK sẽ phức tạp hơn do có thể có lỗ hổng truyền tải
và đến không theo thứ tự.

Trên máy chủ, TCP cũng có thể phá vỡ ánh xạ 1:1 đơn giản từ bộ đệm sang
skbuff do Nagle, nút chai, nút chai tự động, phân đoạn và GSO. các
Việc thực hiện đảm bảo tính đúng đắn trong mọi trường hợp bằng cách theo dõi
từng byte cuối cùng được truyền tới send(), ngay cả khi nó không còn là byte
byte cuối cùng sau thao tác mở rộng hoặc hợp nhất skbuff. Nó lưu trữ
số thứ tự có liên quan trong skb_shinfo(skb)->tskey. Bởi vì một kẻ skbuff
chỉ có một trường như vậy thì chỉ có thể tạo một dấu thời gian.

Trong một số ít trường hợp, một yêu cầu dấu thời gian có thể bị bỏ lỡ nếu có hai yêu cầu
sụp đổ trên cùng một skb. Một tiến trình có thể phát hiện tình huống này bằng cách
bật SOF_TIMESTAMPING_OPT_ID và so sánh độ lệch byte tại
gửi thời gian với giá trị được trả về cho mỗi dấu thời gian. Nó có thể ngăn chặn
tình huống bằng cách luôn xóa ngăn xếp TCP giữa các yêu cầu,
ví dụ bằng cách bật TCP_NODELAY và tắt TCP_CORK và
autocork. Sau linux-4.7, cách tốt hơn để ngăn chặn sự kết hợp là
để sử dụng cờ MSG_EOR tại thời điểm sendmsg().

Những biện pháp phòng ngừa này đảm bảo rằng dấu thời gian chỉ được tạo khi tất cả
byte đã vượt qua điểm dấu thời gian, giả sử rằng ngăn xếp mạng
chính nó không sắp xếp lại các phân đoạn. Ngăn xếp thực sự cố gắng tránh
sắp xếp lại. Một ngoại lệ nằm dưới sự kiểm soát của quản trị viên: đó là
có thể xây dựng một cấu hình lập lịch gói để trì hoãn
các phân đoạn từ cùng một luồng khác nhau. Một thiết lập như vậy sẽ là
bất thường.


2 giao diện dữ liệu
==================

Dấu thời gian được đọc bằng tính năng dữ liệu phụ trợ của recvmsg().
Xem ZZ0000ZZ để biết chi tiết về giao diện này. Hướng dẫn sử dụng ổ cắm
trang (ZZ0001ZZ) mô tả cách tạo dấu thời gian bằng
Có thể truy xuất các bản ghi SO_TIMESTAMP và SO_TIMESTAMPNS.


2.1 Bản ghi SCM_TIMESTAMPING
----------------------------

Các dấu thời gian này được trả về trong thông báo điều khiển có cmsg_level
SOL_SOCKET, cmsg_type SCM_TIMESTAMPING và loại tải trọng

Đối với SO_TIMESTAMPING_OLD::

cấu trúc scm_timestamping {
		cấu trúc timespec ts[3];
	};

Đối với SO_TIMESTAMPING_NEW::

cấu trúc scm_timestamping64 {
		cấu trúc __kernel_timespec ts[3];

Luôn sử dụng dấu thời gian SO_TIMESTAMPING_NEW để luôn nhận được dấu thời gian
định dạng cấu trúc scm_timestamping64.

SO_TIMESTAMPING_OLD trả về dấu thời gian không chính xác sau năm 2038
trên máy 32 bit.

Cấu trúc có thể trả về tối đa ba dấu thời gian. Đây là một di sản
tính năng. Ít nhất một trường khác 0 bất cứ lúc nào. Hầu hết các dấu thời gian
được truyền vào ts[0]. Dấu thời gian phần cứng được chuyển trong ts[2].

ts[1] được sử dụng để giữ dấu thời gian phần cứng được chuyển đổi thành thời gian hệ thống.
Thay vào đó, hãy hiển thị trực tiếp thiết bị đồng hồ phần cứng trên NIC dưới dạng
nguồn đồng hồ HW PTP, để cho phép chuyển đổi thời gian trong không gian người dùng và
tùy chọn đồng bộ hóa thời gian hệ thống với ngăn xếp PTP của không gian người dùng, chẳng hạn như
như linuxptp. Đối với đồng hồ PTP API, hãy xem Tài liệu/driver-api/ptp.rst.

Lưu ý rằng nếu tùy chọn SO_TIMESTAMP hoặc SO_TIMESTAMPNS được bật
cùng với SO_TIMESTAMPING sử dụng SOF_TIMESTAMPING_SOFTWARE, sai
dấu thời gian phần mềm sẽ được tạo trong lệnh gọi recvmsg() và được chuyển
trong ts[0] khi thiếu dấu thời gian phần mềm thực. Điều này cũng xảy ra
trên dấu thời gian truyền phần cứng.

2.1.1 Truyền dấu thời gian với MSG_ERRQUEUE
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Đối với dấu thời gian truyền, gói gửi đi được lặp lại
hàng đợi lỗi của socket có đính kèm (các) dấu thời gian gửi. Một quá trình
nhận dấu thời gian bằng cách gọi recvmsg() với cờ MSG_ERRQUEUE
được thiết lập và với bộ đệm msg_control đủ lớn để nhận
cấu trúc siêu dữ liệu có liên quan. Cuộc gọi recvmsg trả về bản gốc
gói dữ liệu gửi đi có kèm theo hai tin nhắn phụ.

Thông báo cm_level SOL_IP(V6) và cm_type IP(V6)_RECVERR
nhúng cấu trúc sock_extends_err. Điều này xác định loại lỗi. cho
dấu thời gian, trường ee_errno là ENOMSG. Tin nhắn phụ khác
sẽ có cm_level SOL_SOCKET và cm_type SCM_TIMESTAMPING. Cái này
nhúng cấu trúc scm_timestamping.


2.1.1.2 Các loại dấu thời gian
~~~~~~~~~~~~~~~~~~~~~~~

Ngữ nghĩa của ba cấu trúc timespec được xác định theo trường
ee_info trong cấu trúc lỗi mở rộng. Nó chứa một giá trị là
gõ SCM_TSTAMP_* để xác định dấu thời gian thực tế được truyền vào
scm_timestamping.

Các loại SCM_TSTAMP_* tương ứng 1:1 với SOF_TIMESTAMPING_*
các trường điều khiển đã thảo luận trước đó, với một ngoại lệ. Đối với di sản
lý do, SCM_TSTAMP_SND bằng 0 và có thể được đặt cho cả hai
SOF_TIMESTAMPING_TX_HARDWARE và SOF_TIMESTAMPING_TX_SOFTWARE. Nó
là giá trị đầu tiên nếu ts[2] khác 0, giá trị thứ hai nếu ngược lại, trong đó
trường hợp dấu thời gian được lưu trữ trong ts[0].


2.1.1.3 Phân mảnh
~~~~~~~~~~~~~~~~~~~~~

Sự phân mảnh của các datagram gửi đi là rất hiếm, nhưng có thể xảy ra, ví dụ, bằng cách
vô hiệu hóa rõ ràng việc khám phá PMTU. Nếu gói gửi đi bị phân mảnh,
sau đó chỉ đoạn đầu tiên được đánh dấu thời gian và quay lại gửi
ổ cắm.


2.1.1.4 Tải trọng gói
~~~~~~~~~~~~~~~~~~~~~~

Ứng dụng gọi điện thường không quan tâm đến việc nhận toàn bộ
tải trọng gói ban đầu được truyền vào ngăn xếp: ổ cắm
cơ chế xếp hàng lỗi chỉ là một phương pháp để ghi lại dấu thời gian.
Trong trường hợp này, ứng dụng có thể chọn đọc datagram với
bộ đệm nhỏ hơn, thậm chí có thể có độ dài bằng 0. Tải trọng bị cắt bớt
tương ứng. Cho đến khi quá trình gọi recvmsg() trên hàng đợi lỗi,
tuy nhiên, gói đầy đủ được xếp hàng đợi, chiếm ngân sách từ SO_RCVBUF.


2.1.1.5 Chặn đọc
~~~~~~~~~~~~~~~~~~~~~

Đọc từ hàng đợi lỗi luôn là thao tác không bị chặn. Đến
chặn chờ dấu thời gian, sử dụng cuộc thăm dò hoặc chọn. thăm dò ý kiến() sẽ trở lại
POLLERR trong pollfd.revents nếu có bất kỳ dữ liệu nào sẵn sàng trên hàng đợi lỗi.
Không cần phải chuyển cờ này trong pollfd.events. Lá cờ này là
bỏ qua theo yêu cầu. Xem thêm ZZ0000ZZ.


2.1.2 Nhận dấu thời gian
^^^^^^^^^^^^^^^^^^^^^^^^

Khi tiếp nhận, không có lý do gì để đọc từ hàng đợi lỗi ổ cắm.
Dữ liệu phụ trợ SCM_TIMESTAMPING được gửi cùng với dữ liệu gói
trên một recvmsg() bình thường. Vì đây không phải là lỗi socket nên không phải
kèm theo thông báo SOL_IP(V6)/IP(V6)_RECVERROR. Trong trường hợp này,
ý nghĩa của ba trường trong struct scm_timestamping là
được ngầm định nghĩa. ts[0] giữ dấu thời gian phần mềm nếu được đặt, ts[1]
lại không được dùng nữa và ts[2] giữ dấu thời gian phần cứng nếu được đặt.


3. Cấu hình Dấu thời gian phần cứng: ETHTOOL_MSG_TSCONFIG_SET/GET
====================================================================

Việc dán nhãn thời gian phần cứng cũng phải được khởi tạo cho từng trình điều khiển thiết bị
dự kiến ​​sẽ thực hiện việc dán nhãn thời gian phần cứng. Tham số được xác định trong
bao gồm/uapi/linux/net_tstamp.h dưới dạng::

cấu trúc hwtstamp_config {
		cờ int;	/* hiện tại chưa có cờ nào được xác định, phải bằng 0 */
		int tx_type;	/*HWTSTAMP_TX_* */
		int rx_filter;	/*HWTSTAMP_FILTER_* */
	};

Hành vi mong muốn được truyền vào kernel và tới một thiết bị cụ thể bằng cách
gọi ổ cắm netlink tsconfig ZZ0000ZZ.
ZZ0001ZZ, ZZ0002ZZ và
Các thuộc tính liên kết mạng ZZ0003ZZ sau đó được sử dụng để thiết lập
cấu trúc hwtstamp_config tương ứng.

Thuộc tính lồng nhau của liên kết mạng ZZ0000ZZ được sử dụng
để chọn nguồn dập thời gian phần cứng. Nó bao gồm một chỉ mục
cho nguồn thiết bị và một bộ định tính cho kiểu ghi thời gian.

Trình điều khiển có thể tự do sử dụng cấu hình dễ dãi hơn yêu cầu
cấu hình. Dự kiến, các tài xế chỉ nên thực hiện trực tiếp các
chế độ chung nhất có thể được hỗ trợ. Ví dụ: nếu phần cứng có thể
hỗ trợ HWTSTAMP_FILTER_PTP_V2_EVENT, thì nói chung nó phải luôn nâng cấp
HWTSTAMP_FILTER_PTP_V2_L2_SYNC, v.v., như HWTSTAMP_FILTER_PTP_V2_EVENT
chung chung hơn (và hữu ích hơn cho các ứng dụng).

Trình điều khiển hỗ trợ ghi thời gian phần cứng sẽ cập nhật cấu trúc
với cấu hình thực tế, có thể dễ dàng hơn. Nếu
các gói được yêu cầu không thể được đánh dấu thời gian thì không nên có gì
đã thay đổi và ERANGE sẽ được trả lại (ngược lại với EINVAL,
chỉ ra rằng SIOCSHWTSTAMP hoàn toàn không được hỗ trợ).

Chỉ những tiến trình có quyền quản trị mới có thể thay đổi cấu hình. người dùng
space có trách nhiệm đảm bảo rằng nhiều tiến trình không can thiệp vào
với nhau và các cài đặt được đặt lại.

Bất kỳ quá trình nào cũng có thể đọc cấu hình thực tế bằng cách yêu cầu tsconfig netlink
ổ cắm ZZ0000ZZ.

Cấu hình cũ là sử dụng ioctl(SIOCSHWTSTAMP) với một con trỏ
tới cấu trúc ifreq có ifr_data trỏ đến cấu trúc hwtstamp_config.
tx_type và rx_filter là những gợi ý cho người lái xe những gì nó phải làm.
Nếu việc lọc chi tiết được yêu cầu cho các gói đến không được thực hiện
được hỗ trợ, trình điều khiển có thể đánh dấu thời gian nhiều hơn các loại được yêu cầu
của các gói. ioctl(SIOCGHWTSTAMP) được sử dụng theo cách tương tự như
ioctl(SIOCSHWTSTAMP). Tuy nhiên, điều này chưa được thực hiện ở tất cả các trình điều khiển.

::

/* các giá trị có thể có cho hwtstamp_config->tx_type */
    liệt kê {
	    /*
	    * không có gói gửi đi nào sẽ cần đóng dấu thời gian phần cứng;
	    * nếu một gói đến được yêu cầu, không có phần cứng
	    * việc dán tem thời gian sẽ được thực hiện
	    */
	    HWTSTAMP_TX_OFF,

/*
	    * cho phép dán nhãn thời gian phần cứng cho các gói gửi đi;
	    * người gửi gói quyết định gói nào sẽ được gửi
	    * đóng dấu thời gian bằng cách cài đặt SOF_TIMESTAMPING_TX_SOFTWARE
	    * trước khi gửi gói
	    */
	    HWTSTAMP_TX_ON,
    };

/* các giá trị có thể có cho hwtstamp_config->rx_filter */
    liệt kê {
	    /* dấu thời gian không có gói tin nào đến */
	    HWTSTAMP_FILTER_NONE,

/* đánh dấu thời gian cho bất kỳ gói tin nào đến */
	    HWTSTAMP_FILTER_ALL,

/* giá trị trả về: dấu thời gian của tất cả các gói được yêu cầu cộng với một số gói khác */
	    HWTSTAMP_FILTER_SOME,

/* PTP v1, UDP, bất kỳ loại gói sự kiện nào */
	    HWTSTAMP_FILTER_PTP_V1_L4_EVENT,

/* để biết danh sách đầy đủ các giá trị, vui lòng kiểm tra
	    * tệp bao gồm include/uapi/linux/net_tstamp.h
	    */
    };

3.1 Triển khai đánh dấu thời gian phần cứng: Trình điều khiển thiết bị
--------------------------------------------------------

Trình điều khiển hỗ trợ tính năng ghi thời gian phần cứng phải hỗ trợ
ndo_hwtstamp_set NDO và cập nhật cấu trúc hwtstamp_config được cung cấp với
các giá trị thực tế như được mô tả trong phần trên SIOCSHWTSTAMP. Nó
cũng nên hỗ trợ ndo_hwtstamp_get NDO để truy xuất cấu hình.

Dấu thời gian cho các gói đã nhận phải được lưu trữ trong skb. Để có được một con trỏ
đến cấu trúc dấu thời gian được chia sẻ của lệnh gọi skb skb_hwtstamps(). Sau đó
đặt dấu thời gian trong cấu trúc::

cấu trúc skb_shared_hwtstamps {
	    /* dấu thời gian phần cứng được chuyển thành thời lượng
	    * kể từ thời điểm tùy ý
	    */
	    ktime_t hwtstamp;
    };

Dấu thời gian cho các gói gửi đi sẽ được tạo như sau:

- Trong hard_start_xmit(), kiểm tra xem (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)
  được đặt bằng không. Nếu có thì trình điều khiển dự kiến sẽ thực hiện thời gian phần cứng
  dập.
- Nếu điều này là có thể đối với skb và được yêu cầu thì hãy khai báo
  rằng người lái xe đang thực hiện tính thời gian bằng cách đặt cờ
  SKBTX_IN_PROGRESS trong skb_shinfo(skb)->tx_flags , ví dụ: với::

skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;

Bạn có thể muốn giữ một con trỏ tới skb được liên kết cho bước tiếp theo
  và không giải phóng skb. Trình điều khiển không hỗ trợ tính năng ghi thời gian phần cứng thì không
  làm điều đó. Người lái xe không bao giờ được chạm vào sk_buff::tstamp! Nó được dùng để lưu trữ
  phần mềm tạo ra dấu thời gian bởi hệ thống con mạng.
- Trình điều khiển nên gọi skb_tx_timestamp() khi gần chuyển sk_buff sang phần cứng
  càng tốt. skb_tx_timestamp() cung cấp dấu thời gian phần mềm nếu được yêu cầu
  và không thể gắn dấu thời gian phần cứng (SKBTX_IN_PROGRESS chưa được đặt).
- Ngay sau khi trình điều khiển đã gửi gói tin và/hoặc nhận được
  dấu thời gian phần cứng cho nó, nó chuyển dấu thời gian trở lại
  gọi skb_tstamp_tx() bằng skb gốc, bản thô
  dấu thời gian phần cứng. skb_tstamp_tx() sao chép skb gốc và
  thêm dấu thời gian, do đó skb ban đầu phải được giải phóng ngay bây giờ.
  Nếu việc lấy dấu thời gian phần cứng bằng cách nào đó không thành công thì trình điều khiển
  không nên quay lại việc đóng dấu thời gian của phần mềm. Lý do là thế
  điều này sẽ xảy ra muộn hơn trong đường ống xử lý so với các thời điểm khác
  việc dán nhãn thời gian phần mềm và do đó có thể dẫn đến các vùng đồng bằng không mong muốn
  giữa các dấu thời gian.

3.2 Những lưu ý đặc biệt đối với Đồng hồ phần cứng PTP xếp chồng
----------------------------------------------------------

Có những trường hợp có thể có nhiều hơn một PHC (Đồng hồ phần cứng PTP)
trong đường dẫn dữ liệu của gói. Hạt nhân không có cơ chế rõ ràng để cho phép
người dùng chọn PHC nào sẽ sử dụng cho các khung Ethernet đánh dấu thời gian. Thay vào đó,
giả định là PHC ngoài cùng luôn được ưu tiên nhất và điều đó
trình điều khiển hạt nhân cộng tác để đạt được mục tiêu đó. Hiện nay có 3
trường hợp PHC xếp chồng lên nhau, chi tiết dưới đây:

3.2.1 Bộ chuyển mạch DSA (Kiến trúc chuyển mạch phân tán)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Đây là các bộ chuyển mạch Ethernet có một trong các cổng được kết nối với một
(nếu không thì hoàn toàn không biết) lưu trữ giao diện Ethernet và thực hiện vai trò
một hệ số cổng với các tính năng tăng tốc chuyển tiếp tùy chọn.  Mỗi DSA
cổng chuyển đổi được hiển thị cho người dùng dưới dạng giao diện mạng độc lập (ảo),
và I/O mạng của nó được thực hiện một cách bí mật, gián tiếp thông qua máy chủ
giao diện (chuyển hướng đến cổng máy chủ trên TX và chặn khung trên RX).

Khi bộ chuyển mạch DSA được gắn vào cổng máy chủ, việc đồng bộ hóa PTP phải được thực hiện
bị ảnh hưởng, vì độ trễ xếp hàng thay đổi của switch gây ra độ trễ đường dẫn
jitter giữa cổng máy chủ và đối tác PTP của nó. Vì lý do này, một số DSA
công tắc bao gồm đồng hồ đánh dấu thời gian của riêng chúng và có khả năng
thực hiện đánh dấu thời gian mạng trên MAC của riêng họ, sao cho đường dẫn chỉ bị trễ
đo độ trễ lan truyền của dây và PHY. Công tắc DSA đánh dấu thời gian là
được hỗ trợ trong Linux và hiển thị ABI giống như bất kỳ giao diện mạng nào khác (lưu
vì thực tế là các giao diện DSA trên thực tế là ảo về mặt mạng
I/O, họ có PHC của riêng mình).  Đó là điển hình nhưng không bắt buộc đối với tất cả mọi người.
giao diện của một switch DSA để chia sẻ cùng một PHC.

Theo thiết kế, việc đánh dấu thời gian PTP bằng công tắc DSA không cần bất kỳ điều gì đặc biệt
xử lý trong trình điều khiển cho cổng máy chủ mà nó được gắn vào.  Tuy nhiên, khi
cổng máy chủ cũng hỗ trợ đánh dấu thời gian PTP, DSA sẽ đảm nhiệm việc chặn
ZZ0000ZZ gọi tới cổng máy chủ và chặn các nỗ lực kích hoạt
đánh dấu thời gian phần cứng trên đó. Điều này là do SO_TIMESTAMPING API không
cho phép phân phối nhiều dấu thời gian phần cứng cho cùng một gói, do đó
bất kỳ ai khác ngoại trừ cổng chuyển đổi DSA đều phải bị ngăn chặn làm như vậy.

Trong lớp chung, DSA cung cấp cơ sở hạ tầng sau cho PTP
đánh dấu thời gian:

- ZZ0000ZZ: hook được gọi trước khi truyền
  các gói có yêu cầu đánh dấu thời gian TX phần cứng từ không gian người dùng.
  Điều này là cần thiết cho việc đánh dấu thời gian hai bước, vì phần cứng
  dấu thời gian sẽ khả dụng sau khi truyền MAC thực tế, do đó
  người lái xe phải chuẩn bị để đối chiếu dấu thời gian với bản gốc
  gói để nó có thể xếp lại gói vào hàng đợi của ổ cắm.
  hàng đợi lỗi. Để lưu gói tin khi dấu thời gian trở thành
  có sẵn, người lái xe có thể gọi ZZ0001ZZ, lưu con trỏ nhân bản
  trong skb->cb và xếp hàng đợi tx skb. Thông thường, một switch sẽ có
  Thanh ghi dấu thời gian PTP TX (hoặc đôi khi là FIFO) trong đó dấu thời gian
  trở nên có sẵn. Trong trường hợp FIFO, phần cứng có thể lưu trữ
  cặp khóa-giá trị của chuỗi ID/loại thông báo/số miền PTP và
  dấu thời gian thực tế. Để thực hiện chính xác mối tương quan giữa
  các gói trong hàng chờ đánh dấu thời gian và dấu thời gian thực tế,
  trình điều khiển có thể sử dụng bộ phân loại BPF (ZZ0002ZZ) để xác định
  loại truyền tải PTP và ZZ0003ZZ để diễn giải PTP
  các trường tiêu đề. Có thể có một IRQ được nâng lên dựa trên điều này
  tính khả dụng của dấu thời gian hoặc người lái xe có thể phải thăm dò sau
  gọi ZZ0004ZZ tới giao diện máy chủ.
  Đánh dấu thời gian TX một bước không yêu cầu sao chép gói vì có
  giao thức PTP không yêu cầu thông báo tiếp theo (vì
  Dấu thời gian TX được MAC nhúng vào gói) và do đó
  không gian người dùng không mong đợi gói được chú thích bằng dấu thời gian TX
  được xếp lại vào hàng đợi lỗi của socket của nó.

- ZZ0000ZZ: Trên RX, bộ phân loại BPF được điều hành bởi DSA để
  xác định các thông báo sự kiện PTP (bất kỳ gói nào khác, bao gồm cả gói chung PTP
  tin nhắn, không được đánh dấu thời gian). Dấu thời gian ban đầu (và duy nhất)
  skb được cung cấp cho trình điều khiển để chú thích nó bằng dấu thời gian,
  nếu điều đó có sẵn ngay lập tức, hoặc hoãn lại sau. Khi tiếp nhận,
  dấu thời gian có thể có sẵn trong băng tần (thông qua siêu dữ liệu trong
  Tiêu đề DSA hoặc được đính kèm theo các cách khác vào gói) hoặc ngoài băng tần
  (thông qua một dấu thời gian RX khác FIFO). Trì hoãn trên RX thường là
  cần thiết khi truy xuất dấu thời gian cần có bối cảnh có thể ngủ được. trong
  trong trường hợp đó, người lái xe DSA có trách nhiệm gọi
  ZZ0001ZZ trên skb mới được đánh dấu thời gian.

3.2.2 Ethernet PHY
^^^^^^^^^^^^^^^^^^^

Đây là những thiết bị thường hoàn thành vai trò Lớp 1 trong ngăn xếp mạng,
do đó chúng không có đại diện về mặt giao diện mạng như DSA
công tắc làm được. Tuy nhiên, PHY có thể phát hiện và đánh dấu thời gian các gói PTP, ví dụ:
lý do hiệu suất: dấu thời gian được lấy càng gần dây càng tốt
tiềm năng mang lại sự đồng bộ ổn định và chính xác hơn.

Trình điều khiển PHY hỗ trợ tính năng đánh dấu thời gian PTP phải tạo ZZ0000ZZ và thêm con trỏ tới nó trong ZZ0001ZZ. Sự hiện diện
của con trỏ này sẽ được kiểm tra bởi ngăn xếp mạng.

Vì PHY không có biểu diễn giao diện mạng nên việc đánh dấu thời gian và
Các hoạt động ethtool ioctl đối với chúng cần được trung gian bởi MAC tương ứng của chúng
người lái xe.  Do đó, trái ngược với các công tắc DSA, cần phải sửa đổi
tới từng trình điều khiển MAC riêng lẻ để hỗ trợ đánh dấu thời gian cho PHY. Điều này đòi hỏi:

- Kiểm tra, trong ZZ0000ZZ, xem ZZ0001ZZ
  có đúng hay không. Nếu đúng như vậy thì trình điều khiển MAC sẽ không xử lý yêu cầu này
  nhưng thay vào đó hãy chuyển nó tới PHY bằng ZZ0002ZZ.

- Trên RX, có thể cần hoặc không cần can thiệp đặc biệt, tùy thuộc vào
  chức năng được sử dụng để phân phối skb lên ngăn xếp mạng. Trong trường hợp đơn giản
  ZZ0000ZZ và tương tự, trình điều khiển MAC phải kiểm tra xem
  ZZ0001ZZ có cần thiết hay không - và nếu có thì không
  gọi ZZ0002ZZ chút nào.  Nếu ZZ0003ZZ là
  được bật và ZZ0004ZZ tồn tại, móc ZZ0005ZZ của nó
  sẽ được gọi ngay bây giờ, để xác định, sử dụng logic rất giống với DSA, xem liệu
  trì hoãn việc dán nhãn thời gian RX là cần thiết.  Một lần nữa giống như DSA, nó trở thành
  Trình điều khiển PHY có trách nhiệm gửi gói lên ngăn xếp khi
  dấu thời gian có sẵn.

Đối với các chức năng nhận skb khác, chẳng hạn như ZZ0000ZZ và
  ZZ0001ZZ, ngăn xếp sẽ tự động kiểm tra xem
  ZZ0002ZZ là cần thiết nên không cần kiểm tra bên trong
  người lái xe.

- Trên TX, một lần nữa, có thể cần hoặc không cần can thiệp đặc biệt.  các
  hàm gọi hook ZZ0000ZZ được đặt tên
  ZZ0001ZZ. Hàm này có thể được gọi trực tiếp
  (trường hợp thực sự cần hỗ trợ trình điều khiển MAC rõ ràng), nhưng
  chức năng cũng cõng từ cuộc gọi ZZ0002ZZ, mà nhiều MAC
  trình điều khiển đã hoạt động cho mục đích đánh dấu thời gian của phần mềm. Vì vậy, nếu một
  MAC hỗ trợ tính năng timestamping phần mềm, không cần làm gì thêm
  ở giai đoạn này.

3.2.3 Thiết bị theo dõi xe buýt MII
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Chúng thực hiện vai trò tương tự như các PHY Ethernet đánh dấu thời gian, thực tế là
rằng chúng là các thiết bị riêng biệt và do đó có thể được sử dụng cùng với
bất kỳ PHY nào ngay cả khi nó không hỗ trợ tính năng đánh dấu thời gian. Trong Linux, chúng
có thể phát hiện và gắn vào ZZ0000ZZ thông qua Cây thiết bị và
phần còn lại, họ sử dụng cơ sở hạ tầng mii_ts giống như những cơ sở hạ tầng đó. Xem
Documentation/devicetree/binds/ptp/timestamper.txt để biết thêm chi tiết.

3.2.4 Những lưu ý khác dành cho trình điều khiển MAC
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Việc sử dụng PHC xếp chồng lên nhau có thể phát hiện ra các lỗi trình điều khiển MAC không thể khắc phục được
kích hoạt mà không có chúng. Một ví dụ liên quan đến dòng mã này
đã trình bày trước đó::

skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;

Bất kỳ logic đánh dấu thời gian TX nào, có thể là trình điều khiển MAC đơn giản, trình điều khiển chuyển mạch DSA, PHY
trình điều khiển hoặc trình điều khiển thiết bị theo dõi xe buýt MII nên đặt cờ này.
Nhưng trình điều khiển MAC không biết về việc xếp chồng PHC có thể bị vấp ngã bởi
ai đó không phải là người đặt cờ này và gửi một bản sao
dấu thời gian.
Ví dụ, một thiết kế trình điều khiển điển hình cho việc đánh dấu thời gian TX có thể là chia
phần truyền động thành 2 phần:

1. "TX": kiểm tra xem dấu thời gian PTP đã được bật trước đó chưa thông qua
   ZZ0000ZZ ("ZZ0001ZZ") và
   skb hiện tại yêu cầu dấu thời gian TX ("ZZ0002ZZ"). Nếu điều này đúng, nó sẽ đặt
   Cờ "ZZ0003ZZ". Lưu ý: như
   được mô tả ở trên, trong trường hợp hệ thống PHC xếp chồng, điều kiện này sẽ
   không bao giờ kích hoạt, vì MAC này chắc chắn không phải là PHC ngoài cùng. Nhưng đây là
   không phải vấn đề điển hình ở đâu.  Quá trình truyền tiếp tục với gói này.

2. "Xác nhận TX": Quá trình truyền đã kết thúc. Người lái xe kiểm tra xem có
   là cần thiết để thu thập bất kỳ dấu thời gian TX nào cho nó. Đây là nơi điển hình
   vấn đề là: trình điều khiển MAC sử dụng phím tắt và chỉ kiểm tra xem
   "ZZ0000ZZ" đã được đặt. Với xếp chồng lên nhau
   Hệ thống PHC, điều này không chính xác vì trình điều khiển MAC này không phải là thực thể duy nhất
   trong đường dẫn dữ liệu TX ai có thể đã kích hoạt SKBTX_IN_PROGRESS trong lần đầu tiên
   nơi.

Giải pháp chính xác cho vấn đề này là trình điều khiển MAC có một hợp chất
kiểm tra phần "Xác nhận TX" của họ, không chỉ đối với
"ZZ0000ZZ", nhưng cũng dành cho
"ZZ0001ZZ". Bởi vì phần còn lại của hệ thống đảm bảo
dấu thời gian PTP không được bật cho bất kỳ thứ gì ngoài PHC ngoài cùng,
kiểm tra nâng cao này sẽ tránh cung cấp dấu thời gian TX trùng lặp cho người dùng
không gian.