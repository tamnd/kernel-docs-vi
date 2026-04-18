.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/udplite.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Giao thức UDP-Lite (RFC 3828)
================================


UDP-Lite là giao thức truyền tải IETF theo dõi tiêu chuẩn có đặc tính
  là một tổng kiểm tra có độ dài thay đổi. Điều này có lợi thế cho việc truyền tải đa phương tiện
  (video, VoIP) qua mạng không dây, vì các gói bị hỏng một phần vẫn có thể được
  được đưa vào codec thay vì bị loại bỏ do kiểm tra tổng kiểm tra không thành công.

Tệp này mô tả ngắn gọn sự hỗ trợ kernel hiện có và ổ cắm API.
  Để biết thông tin chuyên sâu, bạn có thể tham khảo:

- Trang chủ UDP-Lite:
     ZZ0000ZZ

Từ đây bạn cũng có thể tải xuống một số mã nguồn ứng dụng mẫu.

- Bật UDP-Lite HOWTO
     ZZ0000ZZ

- Wireshark UDP-Lite WiKi (có file chụp):
     ZZ0000ZZ

- Thông số giao thức, RFC 3828, ZZ0000ZZ


1. Ứng dụng
===============

Một số ứng dụng đã được chuyển thành công sang UDP-Lite. thanh tao
  (hiện được gọi là wireshark) có hỗ trợ UDP-Litev4/v6 theo mặc định.

Việc chuyển các ứng dụng sang UDP-Lite rất đơn giản: chỉ ở cấp độ ổ cắm và
  IPPROTO cần được thay đổi; người gửi cũng thiết lập phạm vi tổng kiểm tra
  độ dài (mặc định = độ dài tiêu đề = 8). Chi tiết có ở phần tiếp theo.

2. Lập trình API
==================

UDP-Lite cung cấp dịch vụ datagram không kết nối, không đáng tin cậy và do đó
  sử dụng cùng loại ổ cắm như UDP. Trên thực tế, việc chuyển từ UDP sang UDP-Lite là
  rất dễ dàng: chỉ cần thêm ZZ0000ZZ làm đối số cuối cùng của
  socket(2) để câu lệnh trông giống như ::

s = ổ cắm (PF_INET, SOCK_DGRAM, IPPROTO_UDPLITE);

hoặc, tương ứng,

  ::

s = ổ cắm (PF_INET6, SOCK_DGRAM, IPPROTO_UDPLITE);

Chỉ với thay đổi ở trên, bạn có thể chạy các dịch vụ UDP-Lite hoặc kết nối
  đến máy chủ UDP-Lite. Kernel sẽ cho rằng bạn không quan tâm đến
  sử dụng phạm vi bao phủ tổng kiểm tra một phần và do đó mô phỏng chế độ UDP (phạm vi bao phủ toàn bộ).

Để sử dụng các cơ sở bao phủ tổng kiểm tra một phần đòi hỏi phải thiết lập một
  tùy chọn ổ cắm đơn, lấy một số nguyên chỉ định độ dài vùng phủ sóng:

* Phạm vi tổng kiểm tra người gửi: UDPLITE_SEND_CSCOV

Ví dụ::

int giá trị = 20;
	setsockopt(s, SOL_UDPLITE, UDPLITE_SEND_CSCOV, &val, sizeof(int));

đặt độ dài phạm vi tổng kiểm tra thành 20 byte (dữ liệu 12b + tiêu đề 8b).
      Trong mỗi gói chỉ có 20 byte đầu tiên (cộng với tiêu đề giả) sẽ được
      đã được kiểm tra. Điều này hữu ích cho các ứng dụng RTP có 12 byte
      tiêu đề cơ sở.


* Phạm vi tổng kiểm tra người nhận: UDPLITE_RECV_CSCOV

Tùy chọn này là tín hiệu tương tự phía máy thu. Nó thực sự là tùy chọn, tức là không
      cần thiết để cho phép lưu lượng truy cập có phạm vi bao phủ tổng kiểm tra một phần. Chức năng của nó là
      của bộ lọc lưu lượng: khi được bật, nó sẽ hướng dẫn kernel loại bỏ
      tất cả các gói có phạm vi phủ sóng _less_ hơn giá trị này. Ví dụ, nếu
      Các tiêu đề RTP và UDP phải được bảo vệ, người nhận chỉ có thể thực thi điều đó
      các gói có phạm vi bao phủ tối thiểu là 20 được chấp nhận::

int tối thiểu = 20;
	setsockopt(s, SOL_UDPLITE, UDPLITE_RECV_CSCOV, &min, sizeof(int));

Lệnh gọi getsockopt(2) cũng tương tự. Là một phần mở rộng chứ không phải là một chỗ đứng
  giao thức riêng, tất cả các tùy chọn ổ cắm được biết đến từ UDP có thể được sử dụng chính xác trong
  theo cách tương tự như trước đây, ví dụ: UDP_CORK hoặc UDP_ENCAP.

Thảo luận chi tiết về các tùy chọn bao phủ tổng kiểm tra UDP-Lite nằm trong phần IV.

3. Tệp tiêu đề
===============

Ổ cắm API yêu cầu hỗ trợ thông qua các tệp tiêu đề trong /usr/include:

* /usr/include/netinet/in.h
      để xác định IPPROTO_UDPLITE

* /usr/include/netinet/udplite.h
      cho các trường tiêu đề và hằng số giao thức UDP-Lite

Đối với mục đích thử nghiệm, tệp sau có thể dùng làm tệp tiêu đề ZZ0000ZZ::

#define IPPROTO_UDPLITE 136
    #define SOL_UDPLITE 136
    #define UDPLITE_SEND_CSCOV 10
    #define UDPLITE_RECV_CSCOV 11

Các tệp tiêu đề được tạo sẵn cho nhiều bản phân phối khác nhau có trong tarball UDP-Lite.

4. Hành vi hạt nhân liên quan đến các tùy chọn ổ cắm khác nhau
==============================================================


Để bật thông báo gỡ lỗi, cấp độ nhật ký cần được đặt thành 8, vì hầu hết
  tin nhắn sử dụng mức KERN_DEBUG (7).

1) Tùy chọn ổ cắm người gửi

Nếu người gửi chỉ định giá trị 0 làm độ dài vùng phủ sóng, mô-đun
  giả định vùng phủ sóng đầy đủ, truyền một gói có độ dài vùng phủ sóng là 0
  và theo tổng kiểm tra.  Nếu người gửi chỉ định phạm vi bảo hiểm < 8 và
  khác 0, kernel lấy 8 làm giá trị mặc định.  Cuối cùng,
  nếu độ dài vùng phủ sóng được chỉ định vượt quá độ dài gói, gói
  thay vào đó, độ dài được sử dụng làm độ dài vùng phủ sóng.

2) Tùy chọn ổ cắm máy thu

Máy thu chỉ định giá trị tối thiểu của độ dài vùng phủ sóng mà nó
  sẵn sàng chấp nhận.  Giá trị 0 ở đây chỉ ra rằng người nhận
  luôn muốn toàn bộ gói được bao phủ. Trong trường hợp này, tất cả
  các gói được che phủ một phần sẽ bị loại bỏ và một lỗi được ghi lại.

Không thể chỉ định các giá trị không hợp lệ (<0 và <8); trong này
  trường hợp mặc định là 8.

Tất cả các gói đến có giá trị vùng phủ sóng nhỏ hơn giá trị được chỉ định
  ngưỡng bị loại bỏ, những sự kiện này cũng được ghi lại.

3) Vô hiệu hóa tính toán tổng kiểm tra

Trên cả người gửi và người nhận, việc kiểm tra tổng sẽ luôn được thực hiện
  và không thể tắt bằng SO_NO_CHECK. Như vậy::

setsockopt(sockfd, SOL_SOCKET, SO_NO_CHECK, ... );

sẽ luôn bị bỏ qua, trong khi giá trị của::

getockopt(sockfd, SOL_SOCKET, SO_NO_CHECK, &value, ...);

là vô nghĩa (như trong TCP). Các gói có trường tổng kiểm tra bằng 0 được
  bất hợp pháp (xem RFC 3828, phần 3.1) và sẽ bị âm thầm loại bỏ.

4) Phân mảnh

Tính toán tổng kiểm tra tôn trọng cả kích thước bộ đệm và MTU. Kích thước
  của gói UDP-Lite được xác định bởi kích thước của bộ đệm gửi. các
  kích thước tối thiểu của bộ đệm gửi là 2048 (được định nghĩa là SOCK_MIN_SNDBUF
  trong include/net/sock.h), giá trị mặc định có thể định cấu hình là
  net.core.wmem_default hoặc thông qua cài đặt ổ cắm SO_SNDBUF(7)
  tùy chọn. Giới hạn trên tối đa cho bộ đệm gửi được xác định
  bởi net.core.wmem_max.

Với kích thước tải trọng lớn hơn kích thước bộ đệm gửi, UDP-Lite sẽ
  chia tải trọng thành nhiều gói riêng lẻ, lấp đầy
  gửi kích thước bộ đệm trong từng trường hợp.

Giá trị chính xác cũng phụ thuộc vào giao diện MTU. Giao diện MTU,
  ngược lại, có thể gây ra sự phân mảnh IP. Trong trường hợp này, dữ liệu được tạo ra
  Gói UDP-Lite được chia thành nhiều gói IP, trong đó chỉ có gói
  cái đầu tiên chứa tiêu đề L4.

Kích thước bộ đệm gửi có ý nghĩa đối với độ dài phạm vi tổng kiểm tra.
  Hãy xem xét ví dụ sau::

Tải trọng: 1536 byte Bộ đệm gửi: 1024 byte
    MTU: 1500 byte Độ dài vùng phủ sóng: 856 byte

UDP-Lite sẽ gửi 1536 byte thành hai gói riêng biệt::

Gói 1: Tải trọng 1024 + tiêu đề 8 byte + tiêu đề IP 20 byte = 1052 byte
    Gói 2: Tải trọng 512 + tiêu đề 8 byte + tiêu đề IP 20 byte = 540 byte

Gói bảo hiểm bao gồm tiêu đề UDP-Lite và 848 byte của
  tải trọng trong gói đầu tiên, gói thứ hai được bao phủ hoàn toàn. Lưu ý
  đối với gói thứ hai, độ dài vùng phủ sóng vượt quá gói
  chiều dài. Hạt nhân luôn điều chỉnh lại độ dài vùng phủ sóng cho gói
  chiều dài trong những trường hợp như vậy.

Ví dụ về điều gì xảy ra khi một gói UDP-Lite được chia thành
  một số mảnh nhỏ, hãy xem xét ví dụ sau::

Tải trọng: 1024 byte Kích thước bộ đệm gửi: 1024 byte
    MTU: 300 byte Độ dài vùng phủ sóng: 575 byte

++---------------+--------------+--------------+--------------+
    ZZ0002ZZ 272 ZZ0003ZZ 280 ZZ0004ZZ
    ++---------------+--------------+--------------+--------------+
		280 560 840 1032
					^
    **ZZ0001ZZ************

Mô-đun UDP-Lite tạo ra một gói 1032 byte (1024 + 8 byte
  tiêu đề). Theo giao diện MTU, chúng được chia thành 4 IP
  các gói (tải trọng IP 280 byte + tiêu đề IP 20 byte). Mô-đun hạt nhân
  tổng hợp nội dung của toàn bộ hai gói đầu tiên, cộng với 15 byte
  gói cuối cùng trước khi giải phóng các mảnh tới mô-đun IP.

Để xem trường hợp tương tự về phân mảnh IPv6, hãy xem xét một liên kết
  MTU có dung lượng 1280 byte và bộ đệm ghi 3356 byte. Nếu tổng kiểm tra
  phạm vi phủ sóng nhỏ hơn 1232 byte (MTU trừ IPv6/tiêu đề đoạn
  dài), chỉ đoạn đầu tiên cần được xem xét. Khi sử dụng
  độ dài bao phủ tổng kiểm tra lớn hơn, mỗi đoạn đủ điều kiện cần phải được
  đã được kiểm tra. Giả sử chúng ta có phạm vi tổng kiểm tra là 3062. Bộ đệm
  3356 byte sẽ được chia thành các đoạn sau::

Đoạn 1: 1280 byte mang 1232 byte dữ liệu UDP-Lite
    Đoạn 2: 1280 byte mang 1232 byte dữ liệu UDP-Lite
    Đoạn 3: 948 byte mang 900 byte dữ liệu UDP-Lite

Hai đoạn đầu tiên phải được kiểm tra đầy đủ, đoạn cuối cùng
  chỉ có 598 byte (= 3062 - 2*1232) byte được kiểm tra.

Mặc dù điều quan trọng là những trường hợp như vậy phải được giải quyết một cách chính xác, nhưng chúng
  rất hiếm (khó chịu): UDP-Lite được thiết kế để tối ưu hóa đa phương tiện
  hiệu suất qua các liên kết không dây (hoặc nói chung là ồn ào) và do đó nhỏ hơn
  độ dài bảo hiểm có thể được mong đợi.

5. Thống kê thời gian chạy UDP-Lite và ý nghĩa của chúng
================================================

Các điều kiện ngoại lệ và lỗi được ghi vào nhật ký hệ thống tại KERN_DEBUG
  cấp độ.  Số liệu thống kê trực tiếp về UDP-Lite có sẵn trong /proc/net/snmp
  và có thể (với các phiên bản mới hơn của netstat) có thể được xem bằng cách sử dụng ::

netstat -svu

Điều này hiển thị các biến thống kê UDP-Lite, có ý nghĩa như sau.

======================================================================
   InDatagrams Tổng số datagram được phân phối tới người dùng.

NoPorts Số lượng gói nhận được tới một cổng không xác định.
		    Những trường hợp này được tính riêng (không phải là InErrors).

InErrors Số lượng gói UDP-Lite bị lỗi. Các lỗi bao gồm:

* lỗi nhận hàng đợi ổ cắm nội bộ
		      * gói quá ngắn (nhỏ hơn 8 byte hoặc được nêu
			độ dài vùng phủ sóng vượt quá độ dài nhận được)
		      * xfrm4_policy_check() trả về có lỗi
		      * ứng dụng đã chỉ định mức tối thiểu lớn hơn. bảo hiểm
			dài hơn gói đến
		      * phạm vi bảo hiểm tổng kiểm tra bị vi phạm
		      * tổng kiểm tra xấu

OutDatagrams Tổng số datagram đã gửi.
   ======================================================================

Những số liệu thống kê này bắt nguồn từ UDP MIB (RFC 2013).

6. Bảng IP
===========

Có hỗ trợ khớp gói cho UDP-Lite cũng như hỗ trợ cho mục tiêu LOG.
  Nếu bạn sao chép và dán dòng sau vào /etc/protocols::

udplite 136 UDP-Lite # ZZ0001ZZ-Lite [RFC 3828]

sau đó::

iptables -A INPUT -p udplite -j LOG

sẽ tạo đầu ra ghi nhật ký vào syslog. Thả và từ chối các gói cũng hoạt động.

7. Địa chỉ người bảo trì
=====================

Bản vá UDP-Lite được phát triển tại

Đại học Aberdeen
		    Nhóm nghiên cứu điện tử
		    Khoa Kỹ thuật
		    Tòa nhà Fraser Noble
		    Aberdeen AB24 3UE; Vương quốc Anh

Người bảo trì hiện tại là Gerrit Renker, <gerrit@erg.abdn.ac.uk>. ban đầu
  mã được phát triển bởi William Stanislaus, <william@erg.abdn.ac.uk>.