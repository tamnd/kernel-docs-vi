.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/kcm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Bộ ghép kênh kết nối hạt nhân
=============================

Bộ ghép kênh kết nối hạt nhân (KCM) là một cơ chế cung cấp thông báo dựa trên
giao diện trên TCP cho các giao thức ứng dụng chung. Với KCM một ứng dụng
có thể gửi và nhận tin nhắn giao thức ứng dụng một cách hiệu quả qua TCP bằng cách sử dụng
ổ cắm datagram.

KCM triển khai bộ ghép kênh NxM trong kernel như sơ đồ bên dưới ::

+-------------+ +-------------+ +-------------+ +-------------+
    ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
    +-------------+ +-------------+ +-------------+ +-------------+
	ZZ0004ZZ ZZ0005ZZ
	+----------+ ZZ0006ZZ +----------+
		    ZZ0007ZZ ZZ0008ZZ
		+-----------------------------------+
		ZZ0009ZZ
		+-----------------------------------+
		    ZZ0010ZZ ZZ0011ZZ |
	+----------+ ZZ0012ZZ |  ------------+
	ZZ0013ZZ ZZ0014ZZ |
    +----------+ +----------+ +----------+ +----------+ +----------+
    ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ
    +----------+ +----------+ +----------+ +----------+ +----------+
	ZZ0020ZZ ZZ0021ZZ |
    +----------+ +----------+ +----------+ +----------+ +----------+
    ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ ZZ0026ZZ
    +----------+ +----------+ +----------+ +----------+ +----------+

Ổ cắm KCM
===========

Ổ cắm KCM cung cấp giao diện người dùng cho bộ ghép kênh. Tất cả các ổ cắm KCM
được liên kết với bộ ghép kênh được coi là có chức năng tương đương và I/O
các hoạt động trong các ổ cắm khác nhau có thể được thực hiện song song mà không cần
đồng bộ hóa giữa các luồng trong không gian người dùng.

Bộ ghép kênh
===========

Bộ ghép kênh cung cấp khả năng điều khiển thông điệp. Trên đường truyền, các thông điệp
được ghi trên ổ cắm KCM được gửi nguyên tử trên ổ cắm TCP thích hợp.
Tương tự, trong đường dẫn nhận, các tin nhắn được xây dựng trên mỗi ổ cắm TCP
(Psock) và các tin nhắn hoàn chỉnh được chuyển đến ổ cắm KCM.

Ổ cắm & Psock TCP
====================

Ổ cắm TCP có thể được liên kết với bộ ghép kênh KCM. Cấu trúc Psock được phân bổ
đối với mỗi ổ cắm TCP bị ràng buộc, cấu trúc này giữ trạng thái để xây dựng
tin nhắn khi nhận cũng như thông tin cụ thể về kết nối khác dành cho KCM.

Ngữ nghĩa của chế độ kết nối
========================

Mỗi bộ ghép kênh giả định rằng tất cả các kết nối TCP được đính kèm đều giống nhau
đích và có thể sử dụng các kết nối khác nhau để cân bằng tải khi
truyền tải. Các cuộc gọi gửi và nhận thông thường (bao gồm sendmmsg và recvmmsg)
có thể được sử dụng để gửi và nhận tin nhắn từ ổ cắm KCM.

Các loại ổ cắm
============

KCM hỗ trợ các loại ổ cắm SOCK_DGRAM và SOCK_SEQPACKET.

Phân định tin nhắn
-------------------

Tin nhắn được gửi qua luồng TCP với một số tin nhắn giao thức ứng dụng
định dạng thường bao gồm tiêu đề đóng khung các thông báo. chiều dài
của một tin nhắn nhận được có thể được suy ra từ tiêu đề giao thức ứng dụng
(thường chỉ là một trường có độ dài đơn giản).

Luồng TCP phải được phân tích cú pháp để xác định ranh giới thông báo. Gói Berkeley
Bộ lọc (BPF) được sử dụng cho việc này. Khi gắn ổ cắm TCP vào bộ ghép kênh,
Chương trình BPF phải được chỉ định. Chương trình được gọi khi bắt đầu nhận
một tin nhắn mới và được cấp một skbuff chứa các byte đã nhận được cho đến nay.
Nó phân tích tiêu đề thư và trả về độ dài của thư. Đưa ra điều này
thông tin, KCM sẽ xây dựng thông báo có độ dài đã nêu và gửi nó
vào ổ cắm KCM.

Quản lý ổ cắm TCP
---------------------

Khi ổ cắm TCP được gắn vào bộ ghép kênh KCM đã sẵn sàng dữ liệu (POLLIN) và
Các sự kiện không gian ghi có sẵn (POLLOUT) được xử lý bởi bộ ghép kênh. Nếu có
là sự thay đổi trạng thái (ngắt kết nối) hoặc lỗi khác trên ổ cắm TCP, lỗi là
được đăng trên ổ cắm TCP để sự kiện POLLERR xảy ra và KCM ngừng hoạt động
sử dụng ổ cắm. Khi ứng dụng nhận được thông báo lỗi về một
Ổ cắm TCP, cần tháo ổ cắm khỏi KCM rồi xử lý lỗi
điều kiện (phản ứng điển hình là đóng ổ cắm và tạo một ổ cắm mới
kết nối nếu cần thiết).

KCM giới hạn kích thước tin nhắn nhận tối đa là kích thước của tin nhắn nhận
bộ đệm ổ cắm trên ổ cắm TCP đính kèm (kích thước bộ đệm ổ cắm có thể được đặt bằng cách
SO_RCVBUF). Nếu độ dài của tin nhắn mới được chương trình BPF báo cáo là
lớn hơn giới hạn này, một lỗi tương ứng (EMSGSIZE) được đăng trên TCP
ổ cắm. Chương trình BPF cũng có thể thực thi kích thước tin nhắn tối đa và báo cáo
lỗi khi vượt quá.

Thời gian chờ có thể được đặt để tập hợp các tin nhắn trên ổ cắm nhận. Thời gian chờ
giá trị được lấy từ thời gian chờ nhận của ổ cắm TCP đính kèm (giá trị này được đặt
bởi SO_RCVTIMEO). Nếu hết thời gian trước khi quá trình lắp ráp hoàn tất thì có lỗi
(ETIMEDOUT) được đăng trên ổ cắm.

Giao diện người dùng
==============

Tạo bộ ghép kênh
----------------------

Bộ ghép kênh mới và ổ cắm KCM ban đầu được tạo bằng lệnh gọi ổ cắm ::

ổ cắm (AF_KCM, loại, giao thức)

- loại là SOCK_DGRAM hoặc SOCK_SEQPACKET
- giao thức là KCMPROTO_CONNECTED

Nhân bản ổ cắm KCM
-------------------

Sau khi ổ cắm KCM đầu tiên được tạo bằng cách sử dụng lệnh gọi ổ cắm như mô tả
ở trên, các ổ cắm bổ sung cho bộ ghép kênh có thể được tạo bằng cách nhân bản
ổ cắm KCM. Điều này được thực hiện bằng ioctl trên ổ cắm KCM ::

/* Từ linux/kcm.h */
  cấu trúc kcm_clone {
	int fd;
  };

thông tin cấu trúc kcm_clone;

memset(&info, 0, sizeof(info));

err = ioctl(kcmfd, SIOCKCMCLONE, &info);

nếu (! err)
    newkcmfd = info.fd;

Gắn ổ cắm vận chuyển
------------------------

Việc gắn các ổ cắm truyền tải vào bộ ghép kênh được thực hiện bằng cách gọi một
ioctl trên ổ cắm KCM cho bộ ghép kênh. ví dụ.::

/* Từ linux/kcm.h */
  cấu trúc kcm_attach {
	int fd;
	int bpf_fd;
  };

struct kcm_attach thông tin;

memset(&info, 0, sizeof(info));

thông tin.fd = tcpfd;
  thông tin.bpf_fd = bpf_prog_fd;

ioctl(kcmfd, SIOCKCMATTACH, &thông tin);

Cấu trúc kcm_attach chứa:

- fd: mô tả tập tin cho ổ cắm TCP đang được đính kèm
  - bpf_prog_fd: mô tả tệp cho chương trình BPF đã biên dịch được tải xuống

Tháo ổ cắm vận chuyển
--------------------------

Việc tháo ổ cắm truyền tải khỏi bộ ghép kênh rất đơn giản. Một
"unattach" ioctl được thực hiện với cấu trúc kcm_unattach làm đối số::

/* Từ linux/kcm.h */
  cấu trúc kcm_unattach {
	int fd;
  };

thông tin struct kcm_unattach;

memset(&info, 0, sizeof(info));

thông tin.fd = cfd;

ioctl(fd, SIOCKCMUNATTACH, &thông tin);

Vô hiệu hóa nhận trên ổ cắm KCM
-------------------------------

setsockopt được sử dụng để vô hiệu hóa hoặc cho phép nhận trên ổ cắm KCM.
Khi tính năng nhận bị tắt, mọi tin nhắn đang chờ xử lý trong ổ cắm
bộ đệm nhận được chuyển sang các ổ cắm khác. Tính năng này hữu ích
nếu một luồng ứng dụng biết rằng nó sẽ thực hiện rất nhiều
làm việc theo yêu cầu và sẽ không thể phục vụ tin nhắn mới trong một thời gian
trong khi. Ví dụ sử dụng::

int giá trị = 1;

setsockopt(kcmfd, SOL_KCM, KCM_RECV_DISABLE, &val, sizeof(val))

Các chương trình BPF để phân định tin nhắn
------------------------------------

Các chương trình BPF có thể được biên dịch bằng chương trình phụ trợ BPF LLVM. Ví dụ,
chương trình BPF để phân tích cú pháp Thrift là::

#include "bpf.h" /* cho __sk_buff */
  #include "bpf_helpers.h" /* cho nội tại của Load_word */

SEC("socket_kcm")
  int bpf_prog1(struct __sk_buff *skb)
  {
       trả về Load_word(skb, 0) + 4;
  }

char _license[] SEC("giấy phép") = "GPL";

Sử dụng trong các ứng dụng
===================

KCM tăng tốc các giao thức lớp ứng dụng. Cụ thể là nó cho phép
các ứng dụng sử dụng giao diện dựa trên tin nhắn để gửi và nhận
tin nhắn. Hạt nhân cung cấp những đảm bảo cần thiết rằng tin nhắn được gửi
và nhận được về mặt nguyên tử. Điều này làm giảm bớt phần lớn gánh nặng mà các ứng dụng có
trong việc ánh xạ giao thức dựa trên thông báo vào luồng TCP. KCM cũng làm
Lớp ứng dụng thông báo một đơn vị công việc trong kernel nhằm mục đích
chỉ đạo và lập kế hoạch, từ đó cho phép một mô hình mạng đơn giản hơn trong
các ứng dụng đa luồng.

Cấu hình
--------------

Trong cấu hình Nx1, KCM cung cấp nhiều tay cầm ổ cắm một cách hợp lý
đến cùng một kết nối TCP. Điều này cho phép sự song song giữa trong I/O
các hoạt động trên ổ cắm TCP (ví dụ: sao chép và sao chép dữ liệu được thực hiện
song song). Trong một ứng dụng, ổ cắm KCM có thể được mở cho mỗi
xử lý luồng và chèn vào epoll (tương tự như cách SO_REUSEPORT
được sử dụng để cho phép nhiều ổ cắm nghe trên cùng một cổng).

Trong cấu hình MxN, nhiều kết nối được thiết lập tới
cùng một điểm đến. Chúng được sử dụng để cân bằng tải đơn giản.

Phân nhóm tin nhắn
----------------

Mục đích chính của KCM là cân bằng tải giữa các ổ cắm KCM và do đó
chủ đề trong một trường hợp sử dụng danh nghĩa. Cân bằng tải hoàn hảo, đó là lái
mỗi tin nhắn nhận được đến một ổ cắm hoặc bộ điều khiển KCM khác nhau được gửi đi
gửi tin nhắn tới ổ cắm TCP khác, có thể tác động tiêu cực đến hiệu suất
vì điều này không cho phép thiết lập mối quan hệ. Cân bằng
dựa trên các nhóm hoặc lô tin nhắn có thể mang lại lợi ích cho hiệu suất.

Khi truyền, có ba cách để ứng dụng có thể xử lý hàng loạt (đường ống)
tin nhắn trên ổ cắm KCM.

1) Gửi nhiều tin nhắn trong một lần gửimmsg.
  2) Gửi một nhóm tin nhắn bằng một lệnh gọi sendmsg, trong đó tất cả các tin nhắn
     ngoại trừ cái cuối cùng có MSG_BATCH trong cờ của cuộc gọi sendmsg.
  3) Tạo "siêu tin nhắn" gồm nhiều tin nhắn và gửi tin nhắn này
     với một tin nhắn gửi duy nhất.

Khi nhận được, mô-đun KCM cố gắng xếp hàng các tin nhắn nhận được trên
cùng một ổ cắm KCM trong mỗi lần gọi lại sẵn sàng cho TCP. Ổ cắm KCM được nhắm mục tiêu
thay đổi ở mỗi lần nhận lệnh gọi lại sẵn sàng trên ổ cắm KCM. ứng dụng
không cần phải cấu hình điều này.

Xử lý lỗi
--------------

Một ứng dụng nên bao gồm một luồng để theo dõi các lỗi phát sinh trên
kết nối TCP. Thông thường, việc này sẽ được thực hiện bằng cách đặt mỗi
Ổ cắm TCP được gắn vào bộ ghép kênh KCM trong bộ epoll cho POLLERR
sự kiện. Nếu xảy ra lỗi trên ổ cắm TCP đính kèm, KCM sẽ đặt EPIPE
trên ổ cắm do đó đánh thức luồng ứng dụng. Khi ứng dụng
thấy lỗi (có thể chỉ là lỗi ngắt kết nối), nó sẽ hủy đính kèm
socket từ KCM rồi đóng nó lại. Người ta giả định rằng một khi xảy ra lỗi
được đăng trên ổ cắm TCP, luồng dữ liệu không thể phục hồi được (tức là có lỗi
có thể đã xảy ra trong lúc nhận tin nhắn).

Giám sát kết nối TCP
-------------------------

Trong KCM không có phương tiện nào để liên kết một thông báo với ổ cắm TCP
được sử dụng để gửi hoặc nhận tin nhắn (trừ trường hợp có
chỉ có một ổ cắm TCP kèm theo). Tuy nhiên, ứng dụng vẫn giữ lại
một bộ mô tả tệp đang mở vào ổ cắm để nó có thể lấy số liệu thống kê
từ ổ cắm có thể được sử dụng để phát hiện các sự cố (chẳng hạn như tốc độ cao
truyền lại trên socket).