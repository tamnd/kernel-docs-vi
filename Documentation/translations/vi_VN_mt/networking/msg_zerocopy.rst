.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/msg_zerocopy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.


=============
MSG_ZEROCOPY
=============

giới thiệu
==========

Cờ MSG_ZEROCOPY cho phép tránh sao chép đối với các cuộc gọi gửi ổ cắm.
Tính năng này hiện được triển khai cho TCP, UDP và VSOCK (với
ổ cắm vận chuyển virtio).


Cơ hội và những lưu ý
-----------------------

Việc sao chép các bộ đệm lớn giữa tiến trình người dùng và kernel có thể
đắt tiền. Linux hỗ trợ nhiều giao diện khác nhau tránh sao chép,
chẳng hạn như sendfile và mối nối. Cờ MSG_ZEROCOPY mở rộng
cơ chế tránh sao chép cơ bản đối với các cuộc gọi gửi ổ cắm thông thường.

Tránh sao chép không phải là bữa trưa miễn phí. Như đã triển khai, với tính năng ghim trang,
nó thay thế chi phí sao chép trên mỗi byte bằng việc tính toán và hoàn thành trang
chi phí thông báo. Kết quả là, MSG_ZEROCOPY nói chung chỉ
hiệu quả khi ghi trên khoảng 10 KB.

Việc ghim trang cũng thay đổi ngữ nghĩa của lệnh gọi hệ thống. Nó tạm thời chia sẻ
vùng đệm giữa tiến trình và ngăn xếp mạng. Không giống như việc sao chép,
quá trình không thể ghi đè lên bộ đệm ngay lập tức sau cuộc gọi hệ thống
quay trở lại mà không thể sửa đổi dữ liệu trong chuyến bay. Tính toàn vẹn của hạt nhân
không bị ảnh hưởng, nhưng một chương trình có lỗi có thể làm hỏng dữ liệu của chính nó
suối.

Kernel trả về thông báo khi việc sửa đổi dữ liệu là an toàn.
Việc chuyển đổi một ứng dụng hiện có sang MSG_ZEROCOPY không phải lúc nào cũng như
vậy thì tầm thường như việc chuyền cờ thôi.


Thêm thông tin
--------------

Phần lớn tài liệu này được lấy từ một bài báo dài hơn được trình bày tại
netdev 2.1. Để biết thêm thông tin sâu hơn, hãy xem bài báo đó và nói chuyện,
báo cáo tuyệt vời tại LWN.net hoặc đọc mã gốc.

giấy, slide, video
    ZZ0000ZZ

Bài viết LWN
    ZZ0000ZZ

bộ vá
    [PATCH net-next v4 0/9] ổ cắm gửi tin nhắn MSG_ZEROCOPY
    ZZ0000ZZ


Giao diện
=========

Chuyển cờ MSG_ZEROCOPY là bước rõ ràng nhất để kích hoạt tính năng sao chép
tránh né, nhưng không phải là duy nhất.

Thiết lập ổ cắm
---------------

Hạt nhân được cho phép khi các ứng dụng chuyển các cờ không xác định tới
gửi cuộc gọi hệ thống. Theo mặc định, nó chỉ đơn giản là bỏ qua những điều này. Để tránh kích hoạt
chế độ tránh sao chép cho các quy trình cũ vô tình đã vượt qua
cờ này, trước tiên một quy trình phải báo hiệu ý định bằng cách đặt tùy chọn ổ cắm:

::

if (setsockopt(fd, SOL_SOCKET, SO_ZEROCOPY, &one, sizeof(one)))
		error(1, errno, "setsockopt zerocopy");

Quá trình lây truyền
--------------------

Bản thân sự thay đổi để gửi (hoặc sendto, sendmsg, sendmmsg) là không đáng kể.
Vượt qua lá cờ mới.

::

ret = send(fd, buf, sizeof(buf), MSG_ZEROCOPY);

Lỗi zerocopy sẽ trả về -1 với lỗi ENOBUFS. Điều này xảy ra nếu
ổ cắm vượt quá giới hạn optmem của nó hoặc người dùng vượt quá giới hạn của họ trên
các trang bị khóa.


Trộn lẫn tránh sao chép và sao chép
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nhiều khối lượng công việc có sự kết hợp giữa bộ đệm lớn và nhỏ. Bởi vì sao chép
việc tránh né tốn kém hơn so với việc sao chép các gói nhỏ,
tính năng được thực hiện như một lá cờ. Việc kết hợp cuộc gọi với cờ là an toàn
với những người không có.


Thông báo
-------------

Kernel phải thông báo cho tiến trình khi thấy an toàn để sử dụng lại
bộ đệm được thông qua trước đó. Nó xếp hàng thông báo hoàn thành trên
hàng đợi lỗi ổ cắm, giống như giao diện đánh dấu thời gian truyền.

Bản thân thông báo là một giá trị vô hướng đơn giản. Mỗi ổ cắm
duy trì bộ đếm 32 bit không dấu bên trong. Mỗi cuộc gọi gửi với
MSG_ZEROCOPY gửi dữ liệu thành công sẽ tăng bộ đếm. các
bộ đếm không tăng khi thất bại hoặc nếu được gọi với độ dài bằng 0.
Bộ đếm đếm các lời gọi hệ thống chứ không phải byte. Nó kết thúc sau
Cuộc gọi UINT_MAX.


Tiếp nhận thông báo
~~~~~~~~~~~~~~~~~~~~~~

Đoạn mã dưới đây minh họa API. Trong trường hợp đơn giản nhất, mỗi
gửi syscall được theo sau bởi một cuộc thăm dò và recvmsg trên hàng đợi lỗi.

Đọc từ hàng đợi lỗi luôn là thao tác không bị chặn. các
cuộc gọi thăm dò ý kiến ​​sẽ bị chặn cho đến khi xảy ra lỗi. Nó sẽ thiết lập
POLLERR trong cờ đầu ra của nó. Cờ đó không nhất thiết phải được đặt trong
trường sự kiện. Lỗi được báo hiệu vô điều kiện.

::

pfd.fd = fd;
	pfd.events = 0;
	if (thăm dò ý kiến(&pfd, 1, -1) != 1 || pfd.revents & POLLERR == 0)
		error(1, errno, "thăm dò ý kiến");

ret = recvmsg(fd, &msg, MSG_ERRQUEUE);
	nếu (ret == -1)
		error(1, errno, "recvmsg");

read_notification(tin nhắn);

Ví dụ chỉ nhằm mục đích trình diễn. Trong thực tế, nó còn hơn thế nữa
hiệu quả để không phải chờ thông báo mà đọc mà không bị chặn
mỗi vài cuộc gọi gửi.

Thông báo có thể được xử lý không theo thứ tự bằng các thao tác khác trên
ổ cắm. Ổ cắm có lỗi được xếp hàng thường sẽ chặn
các hoạt động khác cho đến khi lỗi được đọc. Thông báo Zerocopy có
Tuy nhiên, mã lỗi bằng 0 để không chặn các cuộc gọi gửi và nhận.


Lô thông báo
~~~~~~~~~~~~~~~~~~~~~

Có thể đọc nhiều gói chưa xử lý cùng một lúc bằng cách sử dụng recvmmsg
gọi. Điều này thường không cần thiết. Trong mỗi tin nhắn kernel không trả về
một giá trị duy nhất, nhưng là một phạm vi. Nó kết hợp các thông báo liên tiếp
trong khi một cái chưa được xử lý để tiếp nhận trên hàng đợi lỗi.

Khi một thông báo mới sắp được xếp vào hàng đợi, nó sẽ kiểm tra xem
giá trị mới mở rộng phạm vi thông báo ở phần cuối của
xếp hàng. Nếu vậy, nó sẽ loại bỏ gói thông báo mới và thay vào đó sẽ tăng
giá trị trên của phạm vi thông báo chưa xử lý.

Đối với các giao thức xác nhận dữ liệu theo thứ tự, như TCP, mỗi giao thức
thông báo có thể được nén vào thông báo trước đó để không còn
hơn một thông báo chưa được xử lý tại bất kỳ thời điểm nào.

Đặt hàng giao hàng là trường hợp phổ biến nhưng không đảm bảo. Thông báo
có thể không theo thứ tự khi truyền lại và tháo ổ cắm.


Phân tích thông báo
~~~~~~~~~~~~~~~~~~~~

Đoạn mã dưới đây trình bày cách phân tích thông báo điều khiển:
read_notification() trong đoạn mã trước đó. Một thông báo
được mã hóa ở định dạng lỗi tiêu chuẩn, sock_extends_err.

Các trường cấp độ và loại trong dữ liệu điều khiển là họ giao thức
cụ thể, IP_RECVERR hoặc IPV6_RECVERR (đối với ổ cắm TCP hoặc UDP).
Đối với ổ cắm VSOCK, cmsg_level sẽ là SOL_VSOCK và cmsg_type sẽ là
VSOCK_RECVERR.

Nguồn gốc lỗi là loại SO_EE_ORIGIN_ZEROCOPY mới. ee_errno bằng 0,
như đã giải thích trước đó, để tránh chặn các lệnh gọi hệ thống đọc và ghi trên
ổ cắm.

Phạm vi thông báo 32 bit được mã hóa thành [ee_info, ee_data]. Cái này
phạm vi là bao gồm. Các trường khác trong cấu trúc phải được coi là
không xác định, thanh dành cho ee_code, như được thảo luận bên dưới.

::

struct sock_extends_err *serr;
	cấu trúc cmsghdr *cm;

cm = CMSG_FIRSTHDR(tin nhắn);
	nếu (cm->cmsg_level != SOL_IP &&
	    cm->cmsg_type != IP_RECVERR)
		lỗi(1, 0, "cmsg");

serr = (void *) CMSG_DATA(cm);
	if (serr->ee_errno != 0 ||
	    serr->ee_origin != SO_EE_ORIGIN_ZEROCOPY)
		lỗi(1, 0, "serr");

printf("đã hoàn thành: %u..%u\n", serr->ee_info, serr->ee_data);


Bản sao hoãn lại
~~~~~~~~~~~~~~~~

Truyền cờ MSG_ZEROCOPY là một gợi ý cho kernel để áp dụng bản sao
tránh và một hợp đồng rằng kernel sẽ xếp hàng hoàn thành
thông báo. Nó không đảm bảo rằng bản sao sẽ được loại bỏ.

Việc tránh sao chép không phải lúc nào cũng khả thi. Các thiết bị không hỗ trợ
I/O phân tán-thu thập không thể gửi các gói được tạo từ kernel được tạo
tiêu đề giao thức cộng với dữ liệu người dùng zerocopy. Một gói có thể cần phải
được chuyển đổi thành bản sao dữ liệu riêng tư nằm sâu trong ngăn xếp, chẳng hạn như để tính toán
một tổng kiểm tra.

Trong tất cả các trường hợp này, kernel trả về thông báo hoàn thành khi
nó giải phóng quyền sở hữu của nó trên các trang được chia sẻ. Thông báo đó có thể đến
trước khi dữ liệu (được sao chép) được truyền đi đầy đủ. Hoàn thành zerocopy
do đó, thông báo không phải là thông báo hoàn thành truyền.

Các bản sao trả chậm có thể đắt hơn một bản sao ngay trong
cuộc gọi hệ thống, nếu dữ liệu không còn ấm trong bộ đệm. quá trình
cũng phải chịu chi phí xử lý thông báo mà không mang lại lợi ích gì. Vì điều này
lý do, kernel báo hiệu nếu dữ liệu được hoàn thành bằng một bản sao, bởi
cờ cài đặt SO_EE_CODE_ZEROCOPY_COPIED trong trường ee_code khi trả về.
Một tiến trình có thể sử dụng tín hiệu này để dừng chuyển cờ MSG_ZEROCOPY trên
các yêu cầu tiếp theo trên cùng một ổ cắm.


Thực hiện
==============

Quay lại
--------

Đối với TCP và UDP:
Dữ liệu được gửi đến ổ cắm cục bộ có thể được xếp hàng vô thời hạn nếu nhận được
quá trình không đọc ổ cắm của nó. Độ trễ thông báo không bị ràng buộc là không
chấp nhận được. Vì lý do này, tất cả các gói được tạo bằng MSG_ZEROCOPY
được lặp vào ổ cắm cục bộ sẽ phải chịu một bản sao bị trì hoãn. Cái này
bao gồm việc lặp vào các ổ cắm gói (ví dụ: tcpdump) và các thiết bị điều chỉnh.

Đối với VSOCK:
Đường dẫn dữ liệu được gửi đến ổ cắm cục bộ giống như đối với ổ cắm không cục bộ.

Kiểm tra
========

Mã ví dụ thực tế hơn có thể được tìm thấy trong nguồn kernel bên dưới
công cụ/kiểm tra/selftests/net/msg_zerocopy.c.

Hãy nhận thức được ràng buộc loopback. Bài kiểm tra có thể được chạy giữa
một cặp máy chủ. Nhưng nếu chạy giữa một cặp tiến trình cục bộ, đối với
ví dụ khi chạy với msg_zerocopy.sh giữa một cặp veth
không gian tên, thử nghiệm sẽ không cho thấy bất kỳ cải thiện nào. Để thử nghiệm,
hạn chế vòng lặp có thể được nới lỏng tạm thời bằng cách thực hiện
skb_orphan_frags_rx giống hệt skb_orphan_frags.

Ví dụ về loại ổ cắm VSOCK có thể được tìm thấy trong
công cụ/kiểm tra/vsock/vsock_test_zerocopy.c.
