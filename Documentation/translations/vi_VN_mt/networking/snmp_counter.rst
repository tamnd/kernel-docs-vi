.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/snmp_counter.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Bộ đếm SNMP
============

Tài liệu này giải thích ý nghĩa của bộ đếm SNMP.

Bộ đếm IPv4 chung
=====================
Tất cả các gói lớp 4 và gói ICMP sẽ thay đổi các bộ đếm này, nhưng
các bộ đếm này sẽ không bị thay đổi bởi các gói lớp 2 (chẳng hạn như STP) hoặc
Gói ARP.

* IpInNhận

Được xác định trong ZZ0000ZZ

.. _RFC1213 ipInReceives: https://tools.ietf.org/html/rfc1213#page-26

Số lượng gói tin mà lớp IP nhận được. Nó ngày càng tăng ở mức
bắt đầu của hàm ip_rcv, luôn được cập nhật cùng với
IpExtInOctets. Nó sẽ tăng lên ngay cả khi gói bị rơi
sau (ví dụ: do tiêu đề IP không hợp lệ hoặc tổng kiểm tra sai
và vân vân).  Nó cho biết số lượng phân đoạn tổng hợp sau
GRO/LRO.

* IpInGiao hàng

Được xác định trong ZZ0000ZZ

.. _RFC1213 ipInDelivers: https://tools.ietf.org/html/rfc1213#page-28

Số lượng gói gửi đến các giao thức lớp trên. Ví dụ. TCP, UDP,
ICMP, v.v. Nếu không có ai nghe trên ổ cắm thô, chỉ có kernel
các giao thức được hỗ trợ sẽ được gửi nếu ai đó nghe trực tiếp
socket, tất cả các gói IP hợp lệ sẽ được gửi.

* Yêu cầu IpOut

Được xác định trong ZZ0000ZZ

.. _RFC1213 ipOutRequests: https://tools.ietf.org/html/rfc1213#page-28

Số lượng gói được gửi qua lớp IP, cho cả truyền đơn và
các gói multicast và sẽ luôn được cập nhật cùng với
IpExtOutOctets.

* IpExtInOctets và IpExtOutOctets

Chúng là các phần mở rộng nhân Linux, không có định nghĩa RFC. Xin lưu ý,
RFC1213 thực sự định nghĩa ifInOctets và ifOutOctets, nhưng chúng
là những thứ khác nhau ifInOctets và ifOutOctets bao gồm MAC
kích thước tiêu đề lớp nhưng IpExtInOctets và IpExtOutOctets thì không, chúng
chỉ bao gồm tiêu đề lớp IP và dữ liệu lớp IP.

* IpExtInNoECTPkts, IpExtInECT1Pkts, IpExtInECT0Pkts, IpExtInCEPkts

Chúng cho biết số lượng bốn loại gói IP ECN, vui lòng tham khảo
ZZ0000ZZ để biết thêm chi tiết.

.. _Explicit Congestion Notification: https://tools.ietf.org/html/rfc3168#page-6

4 bộ đếm này tính toán số lượng gói nhận được trên mỗi ECN
trạng thái. Họ đếm số khung thực bất kể LRO/GRO. Vì vậy
đối với cùng một gói, bạn có thể thấy rằng IpInReceives đếm 1, nhưng
IpExtInNoECTPkts đếm từ 2 trở lên.

* Lỗi IpInHdr

Được xác định trong ZZ0000ZZ. Nó cho biết gói tin được
bị rớt do lỗi tiêu đề IP. Nó có thể xảy ra ở cả đầu vào IP
và đường dẫn chuyển tiếp IP.

.. _RFC1213 ipInHdrErrors: https://tools.ietf.org/html/rfc1213#page-27

* Lỗi IpInAddr

Được xác định trong ZZ0000ZZ. Nó sẽ được tăng lên trong hai
tình huống: (1) Địa chỉ IP không hợp lệ. (2) IP đích
địa chỉ không phải là địa chỉ cục bộ và chuyển tiếp IP không được bật

.. _RFC1213 ipInAddrErrors: https://tools.ietf.org/html/rfc1213#page-27

* IpExtInNoRoutes

Bộ đếm này có nghĩa là gói tin bị loại bỏ khi ngăn xếp IP nhận được một
gói và không thể tìm thấy tuyến đường cho nó từ bảng định tuyến. Nó có thể
xảy ra khi tính năng chuyển tiếp IP được bật và địa chỉ IP đích được
không phải là địa chỉ cục bộ và không có tuyến đường cho IP đích
địa chỉ.

* IpInUnknownProtos

Được xác định trong ZZ0000ZZ. Nó sẽ tăng lên nếu
Giao thức lớp 4 không được kernel hỗ trợ. Nếu một ứng dụng đang sử dụng
socket thô, kernel sẽ luôn phân phối gói đến socket thô
và bộ đếm này sẽ không được tăng lên.

.. _RFC1213 ipInUnknownProtos: https://tools.ietf.org/html/rfc1213#page-27

* IpExtInTruncatedPkts

Đối với gói IPv4, điều đó có nghĩa là kích thước dữ liệu thực tế nhỏ hơn kích thước
Trường "Tổng chiều dài" trong tiêu đề IPv4.

* IpInDiscards

Được xác định trong ZZ0000ZZ. Nó báo gói tin bị rớt
trong đường dẫn nhận IP và vì lý do nội bộ của kernel (ví dụ: không
đủ bộ nhớ).

.. _RFC1213 ipInDiscards: https://tools.ietf.org/html/rfc1213#page-28

* IpOutDiscards

Được xác định trong ZZ0000ZZ. Nó cho biết gói tin được
bị rớt trong đường dẫn gửi IP và do lý do nội bộ của kernel.

.. _RFC1213 ipOutDiscards: https://tools.ietf.org/html/rfc1213#page-28

* IpOutNoRoutes

Được xác định trong ZZ0000ZZ. Nó cho biết gói tin được
bị rơi vào đường dẫn gửi IP và không tìm thấy tuyến đường nào cho nó.

.. _RFC1213 ipOutNoRoutes: https://tools.ietf.org/html/rfc1213#page-29

Bộ đếm ICMP
=============
* IcmpInMsgs và IcmpOutMsgs

Được xác định bởi ZZ0000ZZ và ZZ0001ZZ

.. _RFC1213 icmpInMsgs: https://tools.ietf.org/html/rfc1213#page-41
.. _RFC1213 icmpOutMsgs: https://tools.ietf.org/html/rfc1213#page-43

Như đã đề cập trong RFC1213, hai bộ đếm này có lỗi, chúng
sẽ được tăng lên ngay cả khi gói ICMP có loại không hợp lệ. các
Đường dẫn đầu ra ICMP sẽ kiểm tra tiêu đề của ổ cắm thô, do đó
IcmpOutMsgs vẫn sẽ được cập nhật nếu tiêu đề IP được xây dựng bởi
một chương trình không gian người dùng.

* Các loại tên ICMP

| Các bộ đếm này bao gồm hầu hết các loại ICMP phổ biến, đó là:
| IcmpInDestUnreachs: ZZ0000ZZ
| IcmpInTimeExcds: ZZ0001ZZ
| IcmpInParmProb: ZZ0002ZZ
| IcmpInSrcQuench: ZZ0003ZZ
| IcmpInChuyển hướng: ZZ0004ZZ
| IcmpInEcho: ZZ0005ZZ
| IcmpInEchoReps: ZZ0006ZZ
| IcmpInDấu thời gian: ZZ0007ZZ
| IcmpInTimestampĐại diện: ZZ0008ZZ
| IcmpInAddrMask: ZZ0009ZZ
| IcmpInAddrMaskĐại diện: ZZ0010ZZ
| IcmpOutDestUnreachs: ZZ0011ZZ
| IcmpOutTimeExcds: ZZ0012ZZ
| IcmpOutParmProb: ZZ0013ZZ
| IcmpOutSrcQuench: ZZ0014ZZ
| IcmpOutChuyển hướng: ZZ0015ZZ
| IcmpOutEcho: ZZ0016ZZ
| IcmpOutEchoReps: ZZ0017ZZ
| IcmpOutDấu thời gian: ZZ0018ZZ
| IcmpOutTimestampĐại diện: ZZ0019ZZ
| IcmpOutAddrMask: ZZ0020ZZ
| IcmpOutAddrMaskReps: ZZ0021ZZ

.. _RFC1213 icmpInDestUnreachs: https://tools.ietf.org/html/rfc1213#page-41
.. _RFC1213 icmpInTimeExcds: https://tools.ietf.org/html/rfc1213#page-41
.. _RFC1213 icmpInParmProbs: https://tools.ietf.org/html/rfc1213#page-42
.. _RFC1213 icmpInSrcQuenchs: https://tools.ietf.org/html/rfc1213#page-42
.. _RFC1213 icmpInRedirects: https://tools.ietf.org/html/rfc1213#page-42
.. _RFC1213 icmpInEchos: https://tools.ietf.org/html/rfc1213#page-42
.. _RFC1213 icmpInEchoReps: https://tools.ietf.org/html/rfc1213#page-42
.. _RFC1213 icmpInTimestamps: https://tools.ietf.org/html/rfc1213#page-42
.. _RFC1213 icmpInTimestampReps: https://tools.ietf.org/html/rfc1213#page-43
.. _RFC1213 icmpInAddrMasks: https://tools.ietf.org/html/rfc1213#page-43
.. _RFC1213 icmpInAddrMaskReps: https://tools.ietf.org/html/rfc1213#page-43

.. _RFC1213 icmpOutDestUnreachs: https://tools.ietf.org/html/rfc1213#page-44
.. _RFC1213 icmpOutTimeExcds: https://tools.ietf.org/html/rfc1213#page-44
.. _RFC1213 icmpOutParmProbs: https://tools.ietf.org/html/rfc1213#page-44
.. _RFC1213 icmpOutSrcQuenchs: https://tools.ietf.org/html/rfc1213#page-44
.. _RFC1213 icmpOutRedirects: https://tools.ietf.org/html/rfc1213#page-44
.. _RFC1213 icmpOutEchos: https://tools.ietf.org/html/rfc1213#page-45
.. _RFC1213 icmpOutEchoReps: https://tools.ietf.org/html/rfc1213#page-45
.. _RFC1213 icmpOutTimestamps: https://tools.ietf.org/html/rfc1213#page-45
.. _RFC1213 icmpOutTimestampReps: https://tools.ietf.org/html/rfc1213#page-45
.. _RFC1213 icmpOutAddrMasks: https://tools.ietf.org/html/rfc1213#page-45
.. _RFC1213 icmpOutAddrMaskReps: https://tools.ietf.org/html/rfc1213#page-46

Mỗi loại ICMP đều có hai bộ đếm: 'Vào' và 'Ra'. Ví dụ: đối với ICMP
Gói Echo, chúng là IcmpInEchos và IcmpOutEchos. Ý nghĩa của chúng là
đơn giản. Bộ đếm 'In' có nghĩa là kernel nhận được gói như vậy
và bộ đếm 'Out' có nghĩa là kernel gửi một gói như vậy.

* Các loại số ICMP

Chúng là IcmpMsgInType[N] và IcmpMsgOutType[N], [N] biểu thị
Số loại ICMP. Các bộ đếm này theo dõi tất cả các loại gói ICMP. các
Định nghĩa số loại ICMP có thể được tìm thấy trong ZZ0000ZZ
tài liệu.

.. _ICMP parameters: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml

Ví dụ: nếu nhân Linux gửi gói Echo ICMP,
IcmpMsgOutType8 sẽ tăng 1. Và nếu kernel nhận được ICMP Echo Reply
gói, IcmpMsgInType0 sẽ tăng 1.

* IcmpInCsumErrors

Bộ đếm này cho biết tổng kiểm tra của gói ICMP là
sai. Kernel xác minh tổng kiểm tra sau khi cập nhật IcmpInMsgs và
trước khi cập nhật IcmpMsgInType[N]. Nếu một gói có tổng kiểm tra sai,
IcmpInMsgs sẽ được cập nhật nhưng không có IcmpMsgInType[N] nào được cập nhật.

* IcmpInError và IcmpOutError

Được xác định bởi ZZ0000ZZ và ZZ0001ZZ

.. _RFC1213 icmpInErrors: https://tools.ietf.org/html/rfc1213#page-41
.. _RFC1213 icmpOutErrors: https://tools.ietf.org/html/rfc1213#page-43

Khi xảy ra lỗi trong đường dẫn xử lý gói ICMP, hai lỗi này
bộ đếm sẽ được cập nhật. Đường dẫn gói nhận sử dụng IcmpInErrors
và đường dẫn gói gửi sử dụng IcmpOutErrors. Khi IcmpInCsumErrors
được tăng lên thì IcmpInErrors cũng sẽ luôn tăng lên.

mối quan hệ của bộ đếm ICMP
---------------------------------
Tổng của IcmpMsgOutType[N] luôn bằng IcmpOutMsgs, vì chúng
được cập nhật cùng một lúc. Tổng của IcmpMsgInType[N] cộng
IcmpInErrors phải bằng hoặc lớn hơn IcmpInMsgs. Khi hạt nhân
nhận được gói ICMP, kernel tuân theo logic bên dưới:

1. tăng IcmpInMsgs
2. nếu có bất kỳ lỗi nào, hãy cập nhật IcmpInErrors và hoàn tất quá trình
3. cập nhật IcmpMsgOutType[N]
4. Xử lý gói tin tùy theo loại, nếu có lỗi thì cập nhật
   IcmpInErrors và kết thúc quá trình

Vì vậy, nếu tất cả các lỗi xảy ra ở bước (2), IcmpInMsgs phải bằng
tổng của IcmpMsgOutType[N] cộng với IcmpInErrors. Nếu tất cả các lỗi xảy ra trong
bước (4), IcmpInMsgs phải bằng tổng của
IcmpMsgOutType[N]. Nếu xảy ra lỗi ở cả bước (2) và bước (4),
IcmpInMsgs phải nhỏ hơn tổng của IcmpMsgOutType[N] cộng
IcmpInErrors.

Bộ đếm chung TCP
====================
* TcpInSegs

Được xác định trong ZZ0000ZZ

.. _RFC1213 tcpInSegs: https://tools.ietf.org/html/rfc1213#page-48

Số lượng gói mà lớp TCP nhận được. Như đã đề cập ở
RFC1213, nó bao gồm các gói nhận được do lỗi, chẳng hạn như tổng kiểm tra
lỗi, tiêu đề TCP không hợp lệ, v.v. Chỉ có một lỗi sẽ không được bao gồm:
nếu địa chỉ đích của lớp 2 không phải là lớp 2 của NIC
địa chỉ. Nó có thể xảy ra nếu gói là multicast hoặc Broadcast
gói hoặc NIC đang ở chế độ lăng nhăng. Trong những tình huống này,
các gói sẽ được gửi đến lớp TCP, nhưng lớp TCP sẽ loại bỏ
các gói này trước khi tăng TcpInSegs. Bộ đếm TcpInSegs
không biết về GRO. Vì vậy, nếu hai gói được hợp nhất bởi GRO, TcpInSegs
bộ đếm sẽ chỉ tăng 1.

* TcpOutSegs

Được xác định trong ZZ0000ZZ

.. _RFC1213 tcpOutSegs: https://tools.ietf.org/html/rfc1213#page-48

Số lượng gói được gửi bởi lớp TCP. Như đã đề cập trong RFC1213,
nó loại trừ các gói được truyền lại. Nhưng nó bao gồm SYN, ACK
và các gói RST. Không thích TcpInSegs, TcpOutSegs biết đến
GSO, vì vậy nếu một gói được chia thành 2 bởi GSO, TcpOutSegs sẽ
tăng 2.

* TcpActiveMở

Được xác định trong ZZ0000ZZ

.. _RFC1213 tcpActiveOpens: https://tools.ietf.org/html/rfc1213#page-47

Điều đó có nghĩa là lớp TCP gửi SYN và đi vào SYN-SENT
trạng thái. Mỗi khi TcpActiveOpens tăng 1, TcpOutSegs sẽ luôn
tăng 1.

* Tcp Thụ độngMở

Được xác định trong ZZ0000ZZ

.. _RFC1213 tcpPassiveOpens: https://tools.ietf.org/html/rfc1213#page-47

Điều đó có nghĩa là lớp TCP nhận được SYN, trả lời SYN+ACK, đi vào
trạng thái SYN-RCVD.

* TcpExtTCPRcvCoalesce

Khi lớp TCP nhận được các gói và không được đọc bởi lớp TCP.
ứng dụng, lớp TCP sẽ cố gắng hợp nhất chúng. quầy này
cho biết có bao nhiêu gói được hợp nhất trong tình huống như vậy. Nếu GRO là
được kích hoạt, nhiều gói sẽ được hợp nhất bởi GRO, các gói này
sẽ không được tính vào TcpExtTCPRcvCoalesce.

* TcpExtTCPAutoCorking

Khi gửi các gói, lớp TCP sẽ cố gắng hợp nhất các gói nhỏ thành
một cái lớn hơn. Bộ đếm này tăng 1 cho mỗi gói được hợp nhất trong đó
tình huống. Vui lòng tham khảo bài viết LWN để biết thêm chi tiết:
ZZ0000ZZ

* TcpExtTCPOrigDataSent

Bộ đếm này được giải thích bằng kernel commit f19c29e3e391, tôi đã dán
giải thích dưới đây::

TCPOrigDataSent: số gói gửi đi có dữ liệu gốc (không bao gồm
  truyền lại nhưng bao gồm cả dữ liệu trong SYN). Bộ đếm này khác với
  TcpOutSegs vì TcpOutSegs cũng theo dõi các ACK thuần túy. TCPOrigDataSent là
  hữu ích hơn để theo dõi tốc độ truyền lại TCP.

* TCPSynRetrans

Bộ đếm này được giải thích bằng kernel commit f19c29e3e391, tôi đã dán
giải thích dưới đây::

TCPSynRetrans: số lần truyền lại SYN và SYN/ACK bị hỏng
  truyền lại vào SYN, truyền lại nhanh, truyền lại hết thời gian chờ, v.v.

* TCPFastOpenActiveFail

Bộ đếm này được giải thích bằng kernel commit f19c29e3e391, tôi đã dán
giải thích dưới đây::

TCPFastOpenActiveFail: Các lần thử mở nhanh (SYN/data) không thành công vì
  điều khiển từ xa không chấp nhận nó hoặc các lần thử đã hết thời gian.

* TcpExtListenOverflows và TcpExtListenDrops

Khi kernel nhận được SYN từ máy khách và nếu TCP chấp nhận hàng đợi
đã đầy, kernel sẽ bỏ SYN và thêm 1 vào TcpExtListenOverflows.
Đồng thời kernel cũng sẽ thêm 1 vào TcpExtListenDrops. Khi một
Ổ cắm TCP ở trạng thái LISTEN và kernel cần loại bỏ một gói,
kernel sẽ luôn thêm 1 vào TcpExtListenDrops. Vì thế tăng
TcpExtListenOverflows sẽ cho phép TcpExtListenDrops tăng theo
cùng lúc, nhưng TcpExtListenDrops cũng sẽ tăng lên mà không cần
TcpExtListenOverflow ngày càng tăng, ví dụ: việc cấp phát bộ nhớ không thành công sẽ
cũng để TcpExtListenDrops tăng lên.

Lưu ý: Giải thích ở trên dựa trên phiên bản kernel 4.10 trở lên, trên
một kernel cũ, ngăn xếp TCP có hành vi khác khi TCP chấp nhận
hàng đợi đã đầy. Trên kernel cũ, ngăn xếp TCP sẽ không loại bỏ SYN, nó
sẽ hoàn thành cái bắt tay 3 bước. Khi hàng đợi chấp nhận đã đầy, TCP
ngăn xếp sẽ giữ ổ cắm trong hàng đợi nửa mở TCP. Như nó vốn có trong
Hàng đợi mở một nửa, ngăn xếp TCP sẽ gửi SYN+ACK theo phản hồi theo cấp số nhân
hẹn giờ, sau khi khách hàng trả lời ACK, ngăn xếp TCP sẽ kiểm tra xem có chấp nhận không
hàng đợi vẫn đầy, nếu nó chưa đầy, hãy chuyển socket sang nơi chấp nhận
hàng đợi, nếu nó đầy, sẽ giữ ổ cắm ở hàng đợi nửa mở, ở lần tiếp theo
khi khách hàng trả lời ACK, ổ cắm này sẽ có cơ hội khác để di chuyển
đến hàng đợi chấp nhận.


TCP Mở Nhanh
=============
* TcpEstabReset

Được xác định trong ZZ0000ZZ.

.. _RFC1213 tcpEstabResets: https://tools.ietf.org/html/rfc1213#page-48

* TcpAttempt Thất bại

Được xác định trong ZZ0000ZZ.

.. _RFC1213 tcpAttemptFails: https://tools.ietf.org/html/rfc1213#page-48

* TcpOutRst

Được xác định trong ZZ0000ZZ. RFC cho biết bộ đếm này cho biết
'các phân đoạn được gửi có chứa cờ RST', nhưng trong nhân linux, điều này
bộ đếm cho biết hạt nhân phân đoạn đã cố gửi. Việc gửi
quá trình có thể không thành công do một số lỗi (ví dụ: cấp phát bộ nhớ không thành công).

.. _RFC1213 tcpOutRsts: https://tools.ietf.org/html/rfc1213#page-52

* TcpExtTCPSpuriousRtxHostQueues

Khi ngăn xếp TCP muốn truyền lại một gói và tìm thấy gói đó
không bị mất trong mạng nhưng gói chưa được gửi, TCP
ngăn xếp sẽ từ bỏ việc truyền lại và cập nhật bộ đếm này. Nó
có thể xảy ra nếu gói tồn tại quá lâu trong qdisc hoặc trình điều khiển
xếp hàng.

* TcpEstabReset

Ổ cắm nhận gói RST ở trạng thái Thiết lập hoặc Đóng.

* TcpExtTCPKeepAlive

Bộ đếm này cho biết nhiều gói tin lưu giữ đã được gửi đi. người giữ gìn
sẽ không được kích hoạt theo mặc định. Một chương trình không gian người dùng có thể kích hoạt nó bằng cách
cài đặt tùy chọn ổ cắm SO_KEEPALIVE.

* TcpExtTCPSpuriousRTO

Thời gian chờ truyền lại giả được phát hiện bởi ZZ0000ZZ
thuật toán.

.. _F-RTO: https://tools.ietf.org/html/rfc5682

Đường dẫn nhanh TCP
=============
Khi kernel nhận được gói TCP, nó có hai đường dẫn để xử lý
gói, một là đường dẫn nhanh, một là đường dẫn chậm. Nhận xét trong kernel
mã cung cấp lời giải thích hay về chúng, tôi đã dán chúng bên dưới ::

Nó được chia thành một con đường nhanh và một con đường chậm. Con đường nhanh là
  bị vô hiệu hóa khi:

- Một cửa sổ số 0 đã được thông báo từ chúng tôi
  - không thăm dò cửa sổ
    chỉ được xử lý đúng cách trên con đường chậm.
  - Các phân khúc không theo thứ tự đã đến.
  - Dữ liệu khẩn cấp được mong đợi.
  - Không còn dung lượng bộ đệm
  - Nhận được cờ/giá trị cửa sổ/độ dài tiêu đề TCP không mong muốn
    (được phát hiện bằng cách kiểm tra tiêu đề TCP dựa trên pred_flags)
  - Dữ liệu được gửi theo cả hai hướng. Đường dẫn nhanh chỉ hỗ trợ người gửi thuần túy
    hoặc máy thu thuần túy (điều này có nghĩa là số thứ tự hoặc số ACK
    giá trị phải không đổi)
  - Tùy chọn TCP bất ngờ.

Kernel sẽ cố gắng sử dụng đường dẫn nhanh trừ khi có bất kỳ điều kiện nào ở trên
được hài lòng. Nếu các gói không đúng thứ tự, kernel sẽ xử lý
chúng theo đường dẫn chậm, có nghĩa là hiệu suất có thể không được tốt lắm
tốt. Hạt nhân cũng sẽ đi vào tình trạng chậm nếu "ACK bị trì hoãn"
được sử dụng vì khi sử dụng "ACK bị trì hoãn", dữ liệu sẽ được gửi ở cả hai
hướng dẫn. Khi tùy chọn tỷ lệ cửa sổ TCP không được sử dụng, kernel sẽ
cố gắng kích hoạt đường dẫn nhanh ngay lập tức khi có kết nối
trạng thái đã thiết lập, nhưng nếu tùy chọn tỷ lệ cửa sổ TCP được sử dụng, kernel
lúc đầu sẽ vô hiệu hóa đường dẫn nhanh và thử kích hoạt nó sau kernel
nhận các gói tin.

* TcpExtTCPPureAcks và TcpExtTCPHPAcks

Nếu một gói đặt cờ ACK và không có dữ liệu thì đó là gói ACK thuần túy, nếu
kernel xử lý nó theo đường dẫn nhanh, TcpExtTCPHPAcks sẽ tăng 1,
nếu kernel xử lý nó theo đường dẫn chậm, TcpExtTCPPureAcks sẽ
tăng 1.

* TcpExtTCPHPHits

Nếu gói TCP có dữ liệu (có nghĩa là nó không phải là gói ACK thuần túy),
và gói này được xử lý theo đường dẫn nhanh, TcpExtTCPHPHits sẽ
tăng 1.


TCP hủy bỏ
=========
* TcpExtTCPAbortOnData

Điều đó có nghĩa là lớp TCP có dữ liệu đang hoạt động nhưng cần phải đóng
kết nối. Vì vậy, lớp TCP gửi RST sang phía bên kia, cho biết
kết nối không được đóng rất duyên dáng. Một cách dễ dàng để tăng điều này
bộ đếm đang sử dụng tùy chọn SO_LINGER. Vui lòng tham khảo SO_LINGER
phần của ZZ0000ZZ:

.. _socket man page: http://man7.org/linux/man-pages/man7/socket.7.html

Theo mặc định, khi một ứng dụng đóng kết nối, chức năng đóng
sẽ quay lại ngay lập tức và kernel sẽ cố gắng gửi dữ liệu trên máy bay
không đồng bộ. Nếu bạn sử dụng tùy chọn SO_LINGER, hãy đặt l_onoff thành 1 và l_linger
thành một số dương, hàm đóng sẽ không trả về ngay lập tức, nhưng
chờ dữ liệu trên chuyến bay được phía bên kia xác nhận, thời gian chờ tối đa
thời gian là l_nán lại giây. Nếu đặt l_onoff thành 1 và đặt l_linger thành 0,
khi ứng dụng đóng kết nối, kernel sẽ gửi RST
ngay lập tức và tăng bộ đếm TcpExtTCPAbortOnData.

* TcpExtTCPAbortOnClose

Bộ đếm này có nghĩa là ứng dụng có dữ liệu chưa đọc trong lớp TCP khi
ứng dụng muốn đóng kết nối TCP. Trong tình huống như vậy,
kernel sẽ gửi RST sang phía bên kia của kết nối TCP.

* TcpExtTCPAbortOnMemory

Khi một ứng dụng đóng kết nối TCP, kernel vẫn cần theo dõi
kết nối, hãy để nó hoàn tất quá trình ngắt kết nối TCP. Ví dụ. một
ứng dụng gọi phương thức đóng của ổ cắm, kernel gửi vây sang ổ cắm khác
bên của kết nối thì ứng dụng không có mối quan hệ nào với
socket nữa, nhưng kernel cần giữ socket, socket này
trở thành một ổ cắm mồ côi, kernel chờ phản hồi của phía bên kia,
và cuối cùng sẽ chuyển sang trạng thái TIME_WAIT. Khi kernel không có
đủ bộ nhớ để giữ ổ cắm mồ côi, kernel sẽ gửi RST tới
phía bên kia và xóa ổ cắm, trong tình huống như vậy, kernel sẽ
tăng 1 lên TcpExtTCPAbortOnMemory. Hai điều kiện sẽ kích hoạt
TcpExtTCPAbortOnMemory:

1. bộ nhớ được sử dụng bởi giao thức TCP cao hơn giá trị thứ ba của
tcp_mem. Vui lòng tham khảo phần tcp_mem trong ZZ0000ZZ:

.. _TCP man page: http://man7.org/linux/man-pages/man7/tcp.7.html

2. số lượng ổ cắm mồ côi cao hơn net.ipv4.tcp_max_orphans


* TcpExtTCPAbortOnTimeout

Bộ đếm này sẽ tăng lên khi bất kỳ bộ đếm thời gian TCP nào hết hạn. Trong đó
Trong trường hợp này, kernel sẽ không gửi RST, hãy hủy kết nối.

* TcpExtTCPAbortOnLinger

Khi kết nối TCP chuyển sang trạng thái FIN_WAIT_2, thay vì chờ đợi
đối với gói vây từ phía bên kia, kernel có thể gửi RST và
xóa ổ cắm ngay lập tức. Đây không phải là hành vi mặc định của
Ngăn xếp hạt nhân Linux TCP. Bằng cách định cấu hình tùy chọn ổ cắm TCP_LINGER2,
bạn có thể để kernel làm theo hành vi này.

* TcpExtTCPAbort Thất bại

Lớp kernel TCP sẽ gửi RST nếu ZZ0000ZZ được
hài lòng. Nếu xảy ra lỗi nội bộ trong quá trình này,
TcpExtTCPAbortFailed sẽ được tăng lên.

.. _RFC2525 2.17 section: https://tools.ietf.org/html/rfc2525#page-50

TCP Khởi động chậm lai
=====================
Thuật toán Khởi động chậm kết hợp là sự cải tiến của thuật toán truyền thống
Cửa sổ tắc nghẽn TCP Thuật toán khởi động chậm. Nó sử dụng hai phần
thông tin để phát hiện xem băng thông tối đa của đường dẫn TCP có
đã đến gần. Hai thông tin là chiều dài đoàn tàu ACK và
tăng độ trễ gói. Để biết thông tin chi tiết, vui lòng tham khảo
ZZ0000ZZ. Chiều dài tàu ACK hoặc độ trễ gói
chạm tới một ngưỡng cụ thể, thuật toán điều khiển tắc nghẽn sẽ xuất hiện
sang trạng thái tránh tắc nghẽn. Cho đến v4.20, hai tắc nghẽn
các thuật toán điều khiển đang sử dụng Khởi động chậm lai, chúng có dạng khối (
thuật toán kiểm soát tắc nghẽn mặc định) và cdg. Bốn quầy snmp
liên quan đến thuật toán Khởi động chậm kết hợp.

.. _Hybrid Slow Start paper: https://pdfs.semanticscholar.org/25e9/ef3f03315782c7f1cbcd31b587857adae7d1.pdf

* TcpExtTCPHystartTrainDetect

Đã phát hiện bao nhiêu lần ngưỡng chiều dài tàu ACK

* TcpExtTCPHystartTrainCwnd

Tổng CWND được phát hiện bởi chiều dài đoàn tàu ACK. Chia giá trị này cho
TcpExtTCPHystartTrainDetect là CWND trung bình được phát hiện bởi
Chiều dài đoàn tàu ACK.

* TcpExtTCHystartDelayDetect

Số lần ngưỡng độ trễ gói được phát hiện.

* TcpExtTCPHystartDelayCwnd

Tổng CWND được phát hiện bởi độ trễ gói. Chia giá trị này cho
TcpExtTCHystartDelayDetect là CWND trung bình được phát hiện bởi
độ trễ gói.

TCP truyền lại và kiểm soát tắc nghẽn
=========================================
Giao thức TCP có hai cơ chế truyền lại: SACK và cơ chế truyền nhanh
phục hồi. Họ độc quyền với nhau. Khi SACK được bật,
ngăn xếp kernel TCP sẽ sử dụng SACK hoặc kernel sẽ sử dụng nhanh
phục hồi. SACK là tùy chọn TCP, được xác định trong ZZ0000ZZ,
quá trình phục hồi nhanh được xác định trong ZZ0001ZZ, còn được gọi là
'Reno'.

Kiểm soát tắc nghẽn TCP là một chủ đề lớn và phức tạp. Để hiểu
bộ đếm snmp liên quan, chúng ta cần biết trạng thái tắc nghẽn
điều khiển máy trạng thái. Có 5 trạng thái: Mở, Rối loạn, CWR,
Phục hồi và mất mát. Để biết chi tiết về các trạng thái này, vui lòng tham khảo trang 5
và trang 6 của tài liệu này:
ZZ0000ZZ

.. _RFC2018: https://tools.ietf.org/html/rfc2018
.. _RFC6582: https://tools.ietf.org/html/rfc6582

* TcpExtTCPRenoRecovery và TcpExtTCPSackRecovery

Khi điều khiển tắc nghẽn chuyển sang trạng thái Recovery, nếu bao tải được
được sử dụng, TcpExtTCPSackRecovery tăng 1, nếu bao không được sử dụng,
TcpExtTCPRenoRecovery tăng 1. Hai bộ đếm này có nghĩa là TCP
ngăn xếp bắt đầu truyền lại các gói bị mất.

* TcpExtTCPSACKGia hạn

Một gói đã được xác nhận bởi SACK, nhưng người nhận đã bỏ gói này
gói tin, do đó người gửi cần truyền lại gói tin này. Trong này
tình huống, người gửi thêm 1 vào TcpExtTCPSACKReneging. Một máy thu
có thể bỏ một gói đã được xác nhận bởi SACK, mặc dù nó
bất thường, nó được cho phép bởi giao thức TCP. Người gửi thực sự không
biết điều gì đã xảy ra ở phía người nhận. Người gửi chỉ đợi cho đến khi
RTO hết hạn đối với gói này thì người gửi sẽ thừa nhận gói này
đã bị người nhận đánh rơi.

* TcpExtTCPRenoSắp xếp lại

Gói sắp xếp lại được phát hiện bằng cách phục hồi nhanh. Nó sẽ chỉ được sử dụng
nếu SACK bị tắt. Thuật toán phục hồi nhanh phát hiện máy ghi bằng cách
số ACK trùng lặp. Ví dụ: nếu quá trình truyền lại được kích hoạt và
gói được truyền lại ban đầu không bị mất, nó chỉ bị mất
lệnh, người nhận sẽ xác nhận nhiều lần, một lần cho
gói được truyền lại, một gói khác để gửi gói gốc ra khỏi
gói đặt hàng. Do đó, người gửi sẽ tìm thấy nhiều AC hơn số AC của nó.
mong đợi và người gửi biết điều đó xảy ra không đúng thứ tự.

* TcpExtTCPTSSắp xếp lại

Gói sắp xếp lại được phát hiện khi một lỗ được lấp đầy. Ví dụ: giả sử
người gửi gửi gói 1,2,3,4,5 và lệnh nhận là
1,2,4,5,3. Khi người gửi nhận được ACK của gói 3 (sẽ
lấp đầy lỗ trống), hai điều kiện sẽ cho phép TcpExtTCPTSReorder tăng
1: (1) nếu gói 3 chưa được truyền lại. (2) nếu gói
3 được truyền lại nhưng dấu thời gian của ACK của gói 3 sớm hơn
hơn dấu thời gian truyền lại.

* TcpExtTCPSACKSắp xếp lại

Gói sắp xếp lại được phát hiện bởi SACK. SACK có hai phương pháp để
phát hiện sắp xếp lại: (1) DSACK được người gửi nhận được. Nó có nghĩa là
người gửi gửi cùng một gói nhiều lần. Và lý do duy nhất
là người gửi tin rằng gói tin không đúng thứ tự đã bị mất nên sẽ gửi
gói lại. (2) Giả sử gói 1,2,3,4,5 được gửi bởi người gửi và
người gửi đã nhận được SACK cho gói 2 và 5, bây giờ người gửi
nhận được SACK cho gói 4 và người gửi không truyền lại
gói nào chưa, người gửi sẽ biết gói 4 không đúng thứ tự. TCP
ngăn xếp hạt nhân sẽ tăng TcpExtTCPSACKReorder cho cả hai
các kịch bản trên.

* TcpExtTCPSlowStartRetrans

Ngăn xếp TCP muốn truyền lại gói và kiểm soát tắc nghẽn
trạng thái là 'Mất'.

* TcpExtTCPFastRetrans

Ngăn xếp TCP muốn truyền lại gói và kiểm soát tắc nghẽn
trạng thái không phải là 'Mất'.

* TcpExtTCPLostRetransmit

SACK chỉ ra rằng gói truyền lại lại bị mất.

* TcpExtTCPRetransFail

Ngăn xếp TCP cố gắng phân phối gói truyền lại đến các lớp thấp hơn
nhưng các lớp thấp hơn trả về lỗi.

* TcpExtTCPSynRetrans

Ngăn xếp TCP truyền lại gói SYN.

DSACK
=====
DSACK được định nghĩa trong ZZ0000ZZ. Người nhận sử dụng DSACK để báo cáo
gói trùng lặp cho người gửi. Có hai loại
trùng lặp: (1) một gói đã được xác nhận là
trùng lặp. (2) một gói không đúng thứ tự bị trùng lặp. Ngăn xếp TCP
đếm hai loại trùng lặp này ở cả phía máy thu và
phía người gửi.

.. _RFC2883 : https://tools.ietf.org/html/rfc2883

* TcpExtTCPDSACKOldSent

Ngăn xếp TCP nhận được một gói trùng lặp đã được xác nhận, vì vậy nó
gửi DSACK cho người gửi.

* TcpExtTCPDSACKOfoSent

Ngăn xếp TCP nhận được một gói trùng lặp không đúng thứ tự, do đó nó sẽ gửi một
DSACK cho người gửi.

* TcpExtTCPDSACKRecv

Ngăn xếp TCP nhận được DSACK, cho biết đã xác nhận
gói trùng lặp được nhận.

* TcpExtTCPDSACKOfoRecv

Ngăn xếp TCP nhận được DSACK, cho biết không đúng thứ tự
gói trùng lặp được nhận.

SACK và DSACK không hợp lệ
======================
Khi khối SACK (hoặc DSACK) không hợp lệ, bộ đếm tương ứng sẽ
được cập nhật. Phương pháp xác thực dựa trên trình tự bắt đầu/kết thúc
số của khối SACK. Để biết thêm chi tiết, vui lòng tham khảo bình luận
của hàm tcp_is_sackblock_valid trong mã nguồn kernel. A
Tùy chọn SACK có thể có tối đa 4 khối, chúng được kiểm tra
riêng lẻ. Ví dụ: nếu 3 khối SACK không hợp lệ thì
bộ đếm tương ứng sẽ được cập nhật 3 lần. Nhận xét của cam kết
18f02545a9a1 ("[TCP] MIB: Thêm bộ đếm cho các khối SACK bị loại bỏ")
có lời giải thích thêm:

* TcpExtTCPSACKHủy bỏ

Bộ đếm này cho biết có bao nhiêu khối SACK không hợp lệ. Nếu không hợp lệ
Khối SACK là do ghi ACK, ngăn xếp TCP sẽ chỉ bỏ qua
nó và sẽ không cập nhật bộ đếm này.

* TcpExtTCPDSACKIgnoredOld và TcpExtTCPDSACKIgnoredNoUndo

Khi khối DSACK không hợp lệ, một trong hai bộ đếm này sẽ
được cập nhật. Bộ đếm nào sẽ được cập nhật tùy thuộc vào cờ undo_marker
của ổ cắm TCP. Nếu undo_marker không được đặt thì ngăn xếp TCP cũng không được đặt
có khả năng truyền lại bất kỳ gói nào và chúng tôi vẫn nhận được thông báo không hợp lệ
Khối DSACK, lý do có thể là gói bị trùng lặp trong
giữa mạng. Trong trường hợp như vậy, TcpExtTCPDSACKIgnoredNoUndo
sẽ được cập nhật. Nếu undo_marker được đặt, TcpExtTCPDSACKIgnoredOld
sẽ được cập nhật. Như ngụ ý trong tên của nó, nó có thể là một gói tin cũ.

dịch chuyển SACK
==========
Ngăn xếp mạng linux lưu trữ dữ liệu trong cấu trúc sk_buff (skb dành cho
ngắn). Nếu một khối SACK đi qua nhiều skb, ngăn xếp TCP sẽ thử
để sắp xếp lại dữ liệu trong các skb này. Ví dụ. nếu khối SACK xác nhận seq
10 đến 15, skb1 có seq 10 đến 13, skb2 có seq 14 đến 20. Seq 14 và
15 trong skb2 sẽ được chuyển sang skb1. Hoạt động này là 'shift'. Nếu một
Khối SACK xác nhận seq 10 đến 20, skb1 có seq 10 đến 13, skb2 có
seq 14 đến 20. Tất cả dữ liệu trong skb2 sẽ được chuyển sang skb1 và skb2 sẽ được chuyển sang
loại bỏ, thao tác này là 'hợp nhất'.

* TcpExtTCPSackĐã chuyển đổi

Một skb được dịch chuyển

* TcpExtTCPSackHợp nhất

Một skb được hợp nhất

* TcpExtTCPSackShiftFallback

Một skb cần được dịch chuyển hoặc hợp nhất, nhưng ngăn xếp TCP không thực hiện được điều đó
một số lý do.

TCP không còn hàng
================
* TcpExtTCPOFOQueue

Lớp TCP nhận được gói không đúng thứ tự và có đủ bộ nhớ
để xếp hàng nó.

* TcpExtTCPOFODrop

Lớp TCP nhận được gói không đúng thứ tự nhưng không có đủ
bộ nhớ, vì vậy hãy bỏ nó đi. Những gói như vậy sẽ không được tính vào
TcpExtTCPOFOQueue.

* TcpExtTCPOFOMerge

Gói nhận được không theo thứ tự có lớp phủ với gói trước đó
gói. phần lớp phủ sẽ bị loại bỏ. Tất cả TcpExtTCPOFOMerge
các gói tin cũng sẽ được tính vào TcpExtTCPOFOQueue.

TCP PAWS
========
PAWS (Bảo vệ chống lại các số thứ tự được bao bọc) là một thuật toán
được sử dụng để loại bỏ các gói tin cũ. Nó phụ thuộc vào TCP
dấu thời gian. Để biết thông tin chi tiết, vui lòng tham khảo ZZ0000ZZ
và ZZ0001ZZ.

.. _RFC of PAWS: https://tools.ietf.org/html/rfc1323#page-17
.. _timestamp wiki: https://en.wikipedia.org/wiki/Transmission_Control_Protocol#TCP_timestamps

* TcpExtPAWSHoạt động

Các gói bị PAWS loại bỏ ở trạng thái Đã gửi đồng bộ.

* TcpExtPAWSEstab

Các gói bị PAWS loại bỏ ở bất kỳ trạng thái nào khác ngoài Syn-Sent.

TCP ACK bỏ qua
============
Trong một số trường hợp, kernel cũng sẽ tránh gửi ACK trùng lặp
thường xuyên. Vui lòng tìm thêm chi tiết trong tcp_invalid_ratelimit
phần của ZZ0000ZZ. Khi kernel quyết định bỏ qua ACK
do tcp_invalid_ratelimit, kernel sẽ cập nhật một trong những thứ bên dưới
bộ đếm để cho biết ACK bị bỏ qua trong trường hợp nào. ACK
sẽ chỉ bị bỏ qua nếu gói nhận được là gói SYN hoặc
nó không có dữ liệu.

.. _sysctl document: https://www.kernel.org/doc/Documentation/networking/ip-sysctl.rst

* TcpExtTCPACKSkippedSynRecv

ACK bị bỏ qua ở trạng thái Syn-Recv. Trạng thái Syn-Recv có nghĩa là
Ngăn xếp TCP nhận được SYN và trả lời SYN+ACK. Bây giờ ngăn xếp TCP là
đang chờ ACK. Nói chung, ngăn xếp TCP không cần gửi ACK
ở trạng thái Syn-Recv. Nhưng trong một số trường hợp, ngăn xếp TCP cần
để gửi một ACK. Ví dụ: ngăn xếp TCP nhận được gói SYN tương tự
lặp đi lặp lại, gói nhận được không vượt qua kiểm tra PAWS hoặc
số thứ tự gói nhận được nằm ngoài cửa sổ. Trong những tình huống này,
ngăn xếp TCP cần gửi ACK. Nếu tần số gửi ACk cao hơn
tcp_invalid_ratelimit cho phép, ngăn xếp TCP sẽ bỏ qua việc gửi ACK và
tăng TcpExtTCPACKSkippedSynRecv.


* TcpExtTCPACKBỏ quaPAWS

ACK bị bỏ qua do PAWS (Bảo vệ chống lại trình tự được bao bọc
số) kiểm tra không thành công. Nếu kiểm tra PAWS không thành công trong Syn-Recv, Fin-Wait-2
hoặc trạng thái Thời gian chờ, ACK bị bỏ qua sẽ được tính vào
TcpExtTCPACKSkippedSynRecv, TcpExtTCPACKSkippedFinWait2 hoặc
TcpExtTCPACKSkippedTimeWait. Trong tất cả các trạng thái khác, ACK bị bỏ qua
sẽ được tính vào TcpExtTCPACKSkippedPAWS.

* TcpExtTCPACKBỏ quaSeq

Số thứ tự nằm ngoài cửa sổ và dấu thời gian vượt qua PAWS
kiểm tra và trạng thái TCP không phải là Syn-Recv, Fin-Wait-2 và Time-Wait.

* TcpExtTCPACKSkippedFinWait2

ACK bị bỏ qua ở trạng thái Fin-Wait-2, lý do có thể là
Kiểm tra PAWS không thành công hoặc số thứ tự nhận được nằm ngoài cửa sổ.

* TcpExtTCPACKSkippedTimeWait

ACK bị bỏ qua ở trạng thái Chờ thời gian, lý do có thể là do
Kiểm tra PAWS không thành công hoặc số thứ tự nhận được nằm ngoài cửa sổ.

* TcpExtTCPACKSkippedChallenge

ACK bị bỏ qua nếu ACK là một thử thách ACK. RFC 5961 xác định
3 loại thử thách ACK, vui lòng tham khảo ZZ0000ZZ,
ZZ0001ZZ và ZZ0002ZZ. Bên cạnh những điều này
ba tình huống, Trong một số trạng thái TCP, ngăn xếp TCP linux cũng sẽ
gửi ACK thử thách nếu số ACK đứng trước số đầu tiên
số chưa được thừa nhận (nghiêm ngặt hơn ZZ0003ZZ).

.. _RFC 5961 section 3.2: https://tools.ietf.org/html/rfc5961#page-7
.. _RFC 5961 section 4.2: https://tools.ietf.org/html/rfc5961#page-9
.. _RFC 5961 section 5.2: https://tools.ietf.org/html/rfc5961#page-11

Cửa sổ nhận TCP
==================
* TcpExtTCPWantZeroWindowAdv

Tùy thuộc vào mức sử dụng bộ nhớ hiện tại, ngăn xếp TCP cố gắng thiết lập nhận
cửa sổ về 0. Nhưng cửa sổ nhận có thể vẫn là số không
giá trị. Ví dụ: nếu kích thước cửa sổ trước đó là 10 và TCP
ngăn xếp nhận được 3 byte, kích thước cửa sổ hiện tại sẽ là 7 ngay cả khi
kích thước cửa sổ được tính theo mức sử dụng bộ nhớ bằng không.

* TcpExtTCPToZeroWindowAdv

Cửa sổ nhận TCP được đặt thành 0 từ giá trị bằng 0.

* TcpExtTCPFromZeroWindowAdv

Cửa sổ nhận TCP được đặt thành giá trị khác 0 từ 0.


Trì hoãn ACK
===========
TCP Delayed ACK là một kỹ thuật được sử dụng để giảm
số lượng gói tin trong mạng. Để biết thêm chi tiết, vui lòng tham khảo
ZZ0000ZZ

.. _Delayed ACK wiki: https://en.wikipedia.org/wiki/TCP_delayed_acknowledgment

* TcpExtDelayedACK

Bộ hẹn giờ ACK bị trì hoãn sẽ hết hạn. Ngăn xếp TCP sẽ gửi gói ACK thuần túy
và thoát khỏi chế độ ACK bị trì hoãn.

* TcpExtDelayedACKĐã khóa

Bộ hẹn giờ ACK bị trì hoãn hết hạn nhưng ngăn xếp TCP không thể gửi ACK
ngay lập tức do ổ cắm bị khóa bởi chương trình không gian người dùng. các
Ngăn xếp TCP sẽ gửi ACK thuần túy sau (sau chương trình không gian người dùng
mở khóa ổ cắm). Khi ngăn xếp TCP gửi ACK thuần sau đó,
Ngăn xếp TCP cũng sẽ cập nhật TcpExtDelayedACKs và thoát khỏi ACK bị trì hoãn
chế độ.

* TcpExtDelayedACKLost

Nó sẽ được cập nhật khi ngăn xếp TCP nhận được gói đã được
Đã xác nhận. Mất ACK bị trì hoãn có thể gây ra sự cố này, nhưng nó cũng có thể
được kích hoạt bởi các lý do khác, chẳng hạn như một gói bị trùng lặp trong
mạng.

Đầu dò mất đuôi (TLP)
=====================
TLP là một thuật toán được sử dụng để phát hiện mất gói TCP. Để biết thêm
chi tiết, vui lòng tham khảo ZZ0000ZZ.

.. _TLP paper: https://tools.ietf.org/html/draft-dukkipati-tcpm-tcp-loss-probe-01

* TcpExtTCPLossProbes

Một gói thăm dò TLP được gửi đi.

* Phục hồi TcpExtTCPLossProbe

Việc mất gói được TLP phát hiện và phục hồi.

Mô tả mở nhanh TCP
=========================
TCP Fast Open là công nghệ cho phép truyền dữ liệu trước
Bắt tay 3 bước hoàn tất. Vui lòng tham khảo ZZ0000ZZ để biết
mô tả chung.

.. _TCP Fast Open wiki: https://en.wikipedia.org/wiki/TCP_Fast_Open

* TcpExtTCPFastOpenActive

Khi ngăn xếp TCP nhận được gói ACK ở trạng thái SYN-SENT và
gói ACK xác nhận dữ liệu trong gói SYN, ngăn xếp TCP
hiểu rằng cookie TFO được phía bên kia chấp nhận thì nó
cập nhật bộ đếm này.

* TcpExtTCPFastOpenActiveFail

Bộ đếm này cho biết rằng ngăn xếp TCP đã khởi tạo TCP Fast Open,
nhưng nó đã thất bại. Bộ đếm này sẽ được cập nhật trong ba trường hợp: (1)
phía bên kia không thừa nhận dữ liệu trong gói SYN. (2) Cái
Gói SYN có cookie TFO đã hết thời gian chờ ít nhất một lần. (3)
sau khi bắt tay 3 bước, thời gian chờ truyền lại sẽ xảy ra
net.ipv4.tcp_retries1 lần, vì một số hộp ở giữa có thể có lỗ đen
mở nhanh sau cái bắt tay.

* TcpExtTCPFastOpenPassive

Bộ đếm này cho biết số lần ngăn xếp TCP chấp nhận tốc độ nhanh
yêu cầu mở.

* TcpExtTCPFastOpenPassiveFail

Bộ đếm này cho biết số lần ngăn xếp TCP từ chối tốc độ nhanh
yêu cầu mở. Nguyên nhân là do cookie TFO không hợp lệ hoặc
Ngăn xếp TCP tìm thấy lỗi trong quá trình tạo ổ cắm.

* TcpExtTCPFastOpenListenOverflow

Khi số yêu cầu mở nhanh đang chờ xử lý lớn hơn
fastopenq->max_qlen, ngăn xếp TCP sẽ từ chối yêu cầu mở nhanh
và cập nhật bộ đếm này. Khi bộ đếm này được cập nhật, ngăn xếp TCP
sẽ không cập nhật TcpExtTCPFastOpenPassive hoặc
TcpExtTCPFastOpenPassiveFail. Fastopenq->max_qlen được đặt bởi
Hoạt động của ổ cắm TCP_FASTOPEN và nó không thể lớn hơn
net.core.somaxconn. Ví dụ:

setsockopt(sfd, SOL_TCP, TCP_FASTOPEN, &qlen, sizeof(qlen));

* TcpExtTCPFastOpenCookieReqd

Bộ đếm này cho biết số lần khách hàng muốn yêu cầu TFO
bánh quy.

Bánh quy SYN
===========
Cookie SYN được sử dụng để giảm thiểu lũ lụt SYN, để biết chi tiết, vui lòng tham khảo
ZZ0000ZZ.

.. _SYN cookies wiki: https://en.wikipedia.org/wiki/SYN_cookies

* TcpExtSyncookiesĐã gửi

Nó cho biết có bao nhiêu cookie SYN được gửi.

* TcpExtSyncookiesRecv

Có bao nhiêu gói phản hồi của cookie SYN mà ngăn xếp TCP nhận được.

* TcpExtSyncookies không thành công

MSS được giải mã từ cookie SYN không hợp lệ. Khi bộ đếm này được
được cập nhật, gói nhận được sẽ không được coi là cookie SYN và
Bộ đếm TcpExtSyncookiesRecv sẽ không được cập nhật.

Thử thách ACK
=============
Để biết chi tiết về thử thách ACK, vui lòng tham khảo phần giải thích của
TcpExtTCPACKSkippedChallenge.

* TcpExtTCPChallengeACK

Số lượng lời mời thử thách được gửi.

* TcpExtTCPSYNCThử thách

Số lượng gói thử thách được gửi để phản hồi các gói SYN. Sau
cập nhật bộ đếm này, ngăn xếp TCP có thể gửi một thử thách ACK và
cập nhật bộ đếm TcpExtTCPChallengeACK hoặc cũng có thể chuyển sang
gửi thử thách và cập nhật TcpExtTCPACKSkippedChallenge.

cắt tỉa
=====
Khi ổ cắm chịu áp lực bộ nhớ, ngăn xếp TCP sẽ cố gắng
lấy lại bộ nhớ từ hàng đợi nhận và ngoài hàng đợi. Một trong
phương pháp thu hồi là 'thu gọn', có nghĩa là phân bổ một skb lớn,
sao chép các skb liền kề vào skb lớn duy nhất và giải phóng chúng
skbs liền kề.

* TcpExtPruneCalled

Ngăn xếp TCP cố gắng lấy lại bộ nhớ cho ổ cắm. Sau khi cập nhật cái này
bộ đếm, ngăn xếp TCP sẽ cố gắng thu gọn hàng đợi không theo thứ tự và
hàng đợi nhận. Nếu bộ nhớ vẫn không đủ, ngăn xếp TCP
sẽ cố gắng loại bỏ các gói tin khỏi hàng đợi không theo thứ tự (và cập nhật
Bộ đếm TcpExtOfoPruned)

* TcpExtOfoPruned

Ngăn xếp TCP cố gắng loại bỏ gói trên hàng đợi không đúng thứ tự.

* TcpExtRcvPruned

Sau khi 'thu gọn' và loại bỏ các gói khỏi hàng đợi không theo thứ tự, nếu
bộ nhớ được sử dụng thực tế vẫn lớn hơn bộ nhớ tối đa cho phép,
bộ đếm này sẽ được cập nhật. Nó có nghĩa là 'cắt tỉa' thất bại.

* TcpExtTCPRcvThu gọn

Bộ đếm này cho biết có bao nhiêu skbs được giải phóng trong quá trình 'sụp đổ'.

ví dụ
========

kiểm tra ping
---------
Chạy lệnh ping đối với máy chủ dns công cộng 8.8.8.8::

nstatuser@nstat-a:~$ ping 8.8.8.8 -c 1
  PING 8.8.8.8 (8.8.8.8) 56(84) byte dữ liệu.
  64 byte từ 8.8.8.8: icmp_seq=1 ttl=119 time=17,8 ms

--- Thống kê ping 8.8.8.8 ---
  1 gói được truyền, 1 gói được nhận, mất gói 0%, thời gian 0ms
  rtt phút/avg/max/mdev = 17,875/17,875/17,875/0,000 mili giây

Kết quả nstayt::

nstatuser@nstat-a:~$ nstat
  #kernel
  IpInNhận 1 0,0
  IpInCung cấp 1 0,0
  IpOutRequests 1 0.0
  IcmpInMsgs 1 0.0
  IcmpInEchoReps 1 0.0
  IcmpOutMsgs 1 0.0
  IcmpOutEchos 1 0.0
  IcmpMsgInType0 1 0.0
  IcmpMsgOutType8 1 0.0
  IpExtInOctets 84 0.0
  IpExtOutOctets 84 0.0
  IpExtInNoECTPkts 1 0,0

Máy chủ Linux đã gửi gói Echo ICMP, vì vậy IpOutRequests,
IcmpOutMsgs, IcmpOutEchos và IcmpMsgOutType8 đã được tăng lên 1.
máy chủ nhận được ICMP Echo Reply từ 8.8.8.8, do đó IpInReceives, IcmpInMsgs,
IcmpInEchoReps và IcmpMsgInType0 đã được tăng lên 1. ICMP Echo Reply
đã được chuyển tới lớp ICMP thông qua lớp IP, do đó IpInDelivers được
tăng 1. Kích thước dữ liệu ping mặc định là 48, do đó gói Echo ICMP
và gói Echo Reply tương ứng của nó được xây dựng bởi:

* Tiêu đề MAC 14 byte
* Tiêu đề IP 20 byte
* Tiêu đề ICMP 16 byte
* Dữ liệu 48 byte (giá trị mặc định của lệnh ping)

Vậy IpExtInOctets và IpExtOutOctets là 20+16+48=84.

bắt tay 3 chiều tcp
-------------------
Về phía máy chủ, chúng tôi chạy::

nstatuser@nstat-b:~$ nc -lknv 0.0.0.0 9000
  Nghe trên [0.0.0.0] (gia đình 0, cổng 9000)

Về phía khách hàng, chúng tôi chạy::

nstatuser@nstat-a:~$ nc -nv 192.168.122.251 9000
  Kết nối tới cổng 192.168.122.251 9000 [tcp/*] đã thành công!

Máy chủ lắng nghe trên cổng tcp 9000, máy khách kết nối với nó, họ
đã hoàn thành cái bắt tay 3 bên.

Về phía máy chủ, chúng ta có thể tìm thấy đầu ra nstat bên dưới ::

nstatuser@nstat-b:~$ nstat | grep -i tcp
  TcpThụ độngMở 1 0,0
  TcpInSegs 2 0.0
  TcpOutSegs 1 0.0
  TcpExtTCPPureAcks 1 0.0

Về phía khách hàng, chúng ta có thể tìm thấy đầu ra nstat bên dưới ::

nstatuser@nstat-a:~$ nstat | grep -i tcp
  TcpActiveMở 1 0,0
  TcpInSegs 1 0,0
  TcpOutSegs 2 0.0

Khi máy chủ nhận được SYN đầu tiên, nó đã trả lời SYN+ACK và chuyển sang
Trạng thái SYN-RCVD nên TcpPassiveOpens tăng 1. Máy chủ nhận được
SYN, đã gửi SYN+ACK, đã nhận được ACK, vì vậy máy chủ đã gửi 1 gói, nhận được 2 gói
gói, TcpInSegs tăng 2, TcpOutSegs tăng 1. ACK cuối cùng
bắt tay 3 chiều là ACK thuần túy không có dữ liệu, vì vậy
TcpExtTCPPureAcks tăng 1.

Khi máy khách gửi SYN, máy khách chuyển sang trạng thái SYN-SENT, do đó
TcpActiveOpens tăng 1, khách hàng gửi SYN, nhận SYN+ACK, gửi
ACK nên client gửi 2 gói, nhận 1 gói, TcpInSegs tăng
1, TcpOutSegs tăng 2.

TCP giao thông bình thường
------------------
Chạy nc trên máy chủ::

nstatuser@nstat-b:~$ nc -lkv 0.0.0.0 9000
  Nghe trên [0.0.0.0] (gia đình 0, cổng 9000)

Chạy nc trên máy khách::

nstatuser@nstat-a:~$ nc -v nstat-b 9000
  Kết nối với cổng nstat-b 9000 [tcp/*] đã thành công!

Nhập một chuỗi trong máy khách nc ('xin chào' trong ví dụ của chúng tôi)::

nstatuser@nstat-a:~$ nc -v nstat-b 9000
  Kết nối với cổng nstat-b 9000 [tcp/*] đã thành công!
  Xin chào

Đầu ra nstat phía máy khách::

nstatuser@nstat-a:~$ nstat
  #kernel
  IpInNhận 1 0,0
  IpInCung cấp 1 0,0
  IpOutRequests 1 0.0
  TcpInSegs 1 0,0
  TcpOutSegs 1 0.0
  TcpExtTCPPureAcks 1 0.0
  TcpExtTCPOrigDataSent 1 0,0
  IpExtInOctets 52 0.0
  IpExtOutOctets 58 0.0
  IpExtInNoECTPkts 1 0,0

Đầu ra nstat phía máy chủ::

nstatuser@nstat-b:~$ nstat
  #kernel
  IpInNhận 1 0,0
  IpInCung cấp 1 0,0
  IpOutRequests 1 0.0
  TcpInSegs 1 0,0
  TcpOutSegs 1 0.0
  IpExtInOctets 58 0.0
  IpExtOutOctets 52 0.0
  IpExtInNoECTPkts 1 0,0

Nhập lại một chuỗi ở phía máy khách nc ('world' trong ví dụ của chúng tôi)::

nstatuser@nstat-a:~$ nc -v nstat-b 9000
  Kết nối với cổng nstat-b 9000 [tcp/*] đã thành công!
  xin chào
  thế giới

Đầu ra nstat phía khách hàng::

nstatuser@nstat-a:~$ nstat
  #kernel
  IpInNhận 1 0,0
  IpInCung cấp 1 0,0
  IpOutRequests 1 0.0
  TcpInSegs 1 0,0
  TcpOutSegs 1 0.0
  TcpExtTCPHPAcks 1 0.0
  TcpExtTCPOrigDataSent 1 0,0
  IpExtInOctets 52 0.0
  IpExtOutOctets 58 0.0
  IpExtInNoECTPkts 1 0,0


Đầu ra nstat phía máy chủ::

nstatuser@nstat-b:~$ nstat
  #kernel
  IpInNhận 1 0,0
  IpInCung cấp 1 0,0
  IpOutRequests 1 0.0
  TcpInSegs 1 0,0
  TcpOutSegs 1 0.0
  TcpExtTCPHPHits 1 0.0
  IpExtInOctets 58 0.0
  IpExtOutOctets 52 0.0
  IpExtInNoECTPkts 1 0,0

So sánh nstat phía máy khách đầu tiên và nstat phía máy khách thứ hai,
chúng ta có thể tìm thấy một điểm khác biệt: cái đầu tiên có 'TcpExtTCPPureAcks',
nhưng cái thứ hai có 'TcpExtTCPHPAcks'. Phía máy chủ đầu tiên
nstat và nstat phía máy chủ thứ hai cũng có một điểm khác biệt:
nstat phía máy chủ thứ hai có TcpExtTCPHPHits, nhưng nstat đầu tiên
nstat phía máy chủ không có nó. Các mô hình lưu lượng mạng đã
hoàn toàn giống nhau: máy khách gửi một gói đến máy chủ, máy chủ
đã trả lời ACK. Nhưng kernel xử lý chúng theo những cách khác nhau. Khi
Tùy chọn tỷ lệ cửa sổ TCP không được sử dụng, kernel sẽ cố gắng kích hoạt nhanh
đường dẫn ngay lập tức khi kết nối đi vào trạng thái được thiết lập,
nhưng nếu tùy chọn tỷ lệ cửa sổ TCP được sử dụng, kernel sẽ vô hiệu hóa
đường dẫn nhanh lúc đầu và thử kích hoạt nó sau khi kernel nhận được
gói. Chúng ta có thể sử dụng lệnh 'ss' để xác minh xem cửa sổ có
tùy chọn tỷ lệ được sử dụng. ví dụ. chạy lệnh bên dưới trên máy chủ hoặc
khách hàng::

nstatuser@nstat-a:~$ ss -o trạng thái được thiết lập -i '( dport = :9000 hoặc sport = :9000 )
  Netid Recv-Q Send-Q Địa chỉ cục bộ: Cổng Địa chỉ ngang hàng: Cổng
  tcp 0 0 192.168.122.250:40654 192.168.122.251:9000
             ts bao khối wscale:7,7 rto:204 rtt:0,98/0,49 mss:1448 pmtu:1500 rcvmss:536 advmss:1448 cwnd:10 bytes_acked:1 segs_out:2 segs_in:1 gửi 118,2Mbps kéo dàind:46572 Lastrcv:46572 Lastack:46572 pacing_rate 236,4Mbps rcv_space:29200 rcv_ssthresh:29200 phútrtt:0,98

'wscale:7,7' có nghĩa là cả máy chủ và máy khách đều đặt tỷ lệ cửa sổ
tùy chọn thành 7. Bây giờ chúng tôi có thể giải thích đầu ra nstat trong thử nghiệm của mình:

Trong đầu ra nstat đầu tiên của phía máy khách, máy khách đã gửi một gói, máy chủ
trả lời ACK, khi kernel xử lý ACK này, đường dẫn nhanh không
được bật, do đó ACK được tính vào 'TcpExtTCPPureAcks'.

Trong đầu ra nstat thứ hai của phía máy khách, máy khách lại gửi một gói,
và nhận được một ACK khác từ máy chủ, tại thời điểm này, đường dẫn nhanh là
được bật và ACK đủ điều kiện cho đường dẫn nhanh, do đó nó được xử lý bởi
đường dẫn nhanh, do đó ACK này được tính vào TcpExtTCPHPAcks.

Trong đầu ra nstat đầu tiên của phía máy chủ, đường dẫn nhanh không được bật,
vì vậy không có 'TcpExtTCPHPHits'.

Trong đầu ra nstat thứ hai của phía máy chủ, đường dẫn nhanh đã được bật,
và gói nhận được từ máy khách đủ điều kiện cho đường dẫn nhanh, vì vậy nó
đã được tính vào 'TcpExtTCPHPHits'.

TcpExtTCPAbortOnClose
---------------------
Về phía máy chủ, chúng tôi chạy tập lệnh python bên dưới ::

ổ cắm nhập khẩu
  thời gian nhập khẩu

cổng = 9000

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.bind(('0.0.0.0', cổng))
  s.lắng nghe(1)
  sock, addr = s.accept()
  trong khi Đúng:
      thời gian.ngủ (9999999)

Tập lệnh python này nghe trên cổng 9000, nhưng không đọc bất cứ thứ gì từ
sự kết nối.

Về phía khách hàng, chúng tôi gửi chuỗi "hello" bởi nc::

nstatuser@nstat-a:~$ echo "xin chào" | nc nstat-b 9000

Sau đó, chúng ta quay lại phía server, server đã nhận được "hello"
gói và lớp TCP đã xác nhận gói này, nhưng ứng dụng thì không
đọc nó chưa. Chúng tôi gõ Ctrl-C để chấm dứt tập lệnh máy chủ. Sau đó chúng tôi
có thể tìm thấy TcpExtTCPAbortOnClose tăng 1 ở phía máy chủ ::

nstatuser@nstat-b:~$ nstat | grep -i hủy bỏ
  TcpExtTCPAbortOnClose 1 0,0

Nếu chúng ta chạy tcpdump ở phía máy chủ, chúng ta có thể thấy máy chủ đã gửi một
RST sau khi chúng ta gõ Ctrl-C.

TcpExtTCPAbortOnMemory và TcpExtTCPAbortOnTimeout
---------------------------------------------------
Dưới đây là một ví dụ cho phép số lượng ổ cắm mồ côi cao hơn
net.ipv4.tcp_max_orphans.
Thay đổi tcp_max_orphans thành giá trị nhỏ hơn trên máy khách::

sudo bash -c "echo 10 > /proc/sys/net/ipv4/tcp_max_orphans"

Mã máy khách (tạo 64 kết nối đến máy chủ)::

nstatuser@nstat-a:~$ cat client_orphan.py
  ổ cắm nhập khẩu
  thời gian nhập khẩu

máy chủ = địa chỉ 'nstat-b' # server
  cổng = 9000

đếm = 64

danh sách kết nối = []

cho tôi trong phạm vi (64):
      s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
      s.connect((máy chủ, cổng))
      kết nối_list.append(s)
      print("connection_count: %d" % len(connection_list))

trong khi Đúng:
      thời gian.ngủ (99999)

Mã máy chủ (chấp nhận kết nối 64 từ máy khách)::

nstatuser@nstat-b:~$ cat server_orphan.py
  ổ cắm nhập khẩu
  thời gian nhập khẩu

cổng = 9000
  đếm = 64

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.bind(('0.0.0.0', cổng))
  s.listen(đếm)
  danh sách kết nối = []
  trong khi Đúng:
      sock, addr = s.accept()
      Connection_list.append((sock, addr))
      print("connection_count: %d" % len(connection_list))

Chạy các tập lệnh python trên máy chủ và máy khách.

Trên máy chủ::

python3 server_orphan.py

Trên máy khách::

python3 client_orphan.py

Chạy iptables trên máy chủ::

sudo iptables -A INPUT -i ens3 -p tcp --destination-port 9000 -j DROP

Nhập Ctrl-C trên máy khách, dừng client_orphan.py.

Kiểm tra TcpExtTCPAbortOnMemory trên máy khách::

nstatuser@nstat-a:~$ nstat | grep -i hủy bỏ
  TcpExtTCPAbortOnMemory 54 0.0

Kiểm tra số lượng ổ cắm mồ côi trên máy khách::

nstatuser@nstat-a:~$ ss -s
  Tổng cộng: 131 (hạt nhân 0)
  TCP: 14 (estab 1, đóng 0, mồ côi 10, synrecv 0, timewait 0/0), cổng 0

Vận chuyển Tổng IP IPv6
  * 0 - -
  RAW 1 0 1
  UDP 1 1 0
  TCP 14 13 1
  INET 16 14 2
  FRAG 0 0 0

Giải thích về bài kiểm tra: sau khi chạy server_orphan.py và
client_orphan.py, chúng tôi thiết lập 64 kết nối giữa máy chủ và
khách hàng. Chạy lệnh iptables, máy chủ sẽ loại bỏ tất cả các gói từ
máy khách, gõ Ctrl-C trên client_orphan.py, hệ thống của máy khách
sẽ cố gắng đóng các kết nối này và trước khi chúng bị đóng
một cách duyên dáng, những kết nối này đã trở thành ổ cắm mồ côi. Như iptables
của máy chủ đã chặn các gói từ máy khách, máy chủ sẽ không nhận được tiền phạt
từ máy khách, do đó tất cả kết nối trên máy khách sẽ bị kẹt trên FIN_WAIT_1
giai đoạn, vì vậy chúng sẽ giữ nguyên như các ổ cắm mồ côi cho đến khi hết thời gian chờ. Chúng tôi có tiếng vang
10 tới /proc/sys/net/ipv4/tcp_max_orphans, do đó hệ thống máy khách sẽ
chỉ giữ 10 ổ cắm mồ côi, đối với tất cả các ổ cắm mồ côi khác, máy khách
hệ thống đã gửi RST cho họ và xóa chúng. Chúng tôi có 64 kết nối, vì vậy
lệnh 'ss -s' hiển thị hệ thống có 10 ổ cắm mồ côi và
giá trị của TcpExtTCPAbortOnMemory là 54.

Một lời giải thích bổ sung về số lượng ổ cắm mồ côi: Bạn có thể tìm thấy
chính xác số lượng ổ cắm mồ côi bằng lệnh 'ss -s', nhưng khi kernel
quyết định xem tăng TcpExtTCPAbortOnMemory ở đâu và gửi RST, kernel
không phải lúc nào cũng kiểm tra chính xác số lượng ổ cắm mồ côi. Để tăng
hiệu suất, trước tiên kernel sẽ kiểm tra số lượng gần đúng, nếu
số lượng gần đúng lớn hơn tcp_max_orphans, kernel sẽ kiểm tra
đếm chính xác lại. Vì vậy, nếu số lượng gần đúng nhỏ hơn
tcp_max_orphans, nhưng số lượng chính xác là nhiều hơn tcp_max_orphans, bạn
sẽ thấy TcpExtTCPAbortOnMemory không tăng chút nào. Nếu
tcp_max_orphans đủ lớn thì sẽ không xảy ra nhưng nếu bạn giảm
tcp_max_orphans thành một giá trị nhỏ như thử nghiệm của chúng tôi, bạn có thể tìm thấy giá trị này
vấn đề. Vì vậy, trong thử nghiệm của chúng tôi, máy khách đã thiết lập 64 kết nối mặc dù
tcp_max_orphans là 10. Nếu máy khách chỉ thiết lập 11 kết nối, chúng tôi
không thể tìm thấy sự thay đổi của TcpExtTCPAbortOnMemory.

Tiếp tục bài kiểm tra trước, chúng tôi đợi trong vài phút. Bởi vì
iptables trên máy chủ đã chặn lưu lượng, máy chủ sẽ không nhận được
vây và tất cả các ổ cắm mồ côi của khách hàng sẽ hết thời gian chờ trên
Trạng thái FIN_WAIT_1 cuối cùng. Vì vậy, chúng ta đợi trong vài phút, chúng ta có thể tìm thấy
10 thời gian chờ trên máy khách::

nstatuser@nstat-a:~$ nstat | grep -i hủy bỏ
  TcpExtTCPAbortOnTimeout 10 0.0

TcpExtTCPAbortOnLinger
----------------------
Mã phía máy chủ::

nstatuser@nstat-b:~$ cat server_linger.py
  ổ cắm nhập khẩu
  thời gian nhập khẩu

cổng = 9000

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.bind(('0.0.0.0', cổng))
  s.lắng nghe(1)
  sock, addr = s.accept()
  trong khi Đúng:
      thời gian.ngủ (9999999)

Mã phía khách hàng::

nstatuser@nstat-a:~$ cat client_linger.py
  ổ cắm nhập khẩu
  nhập cấu trúc

máy chủ = địa chỉ 'nstat-b' # server
  cổng = 9000

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER, struct.pack('ii', 1, 10))
  s.setsockopt(socket.SOL_TCP, socket.TCP_LINGER2, struct.pack('i', -1))
  s.connect((máy chủ, cổng))
  s.close()

Chạy server_linger.py trên máy chủ::

nstatuser@nstat-b:~$ python3 server_linger.py

Chạy client_linger.py trên máy khách::

nstatuser@nstat-a:~$ python3 client_linger.py

Sau khi chạy client_linger.py, hãy kiểm tra đầu ra của nstat::

nstatuser@nstat-a:~$ nstat | grep -i hủy bỏ
  TcpExtTCPAbortOnLinger 1 0.0

TcpExtTCPRcvHợp nhất
--------------------
Trên máy chủ, chúng tôi chạy một chương trình nghe trên cổng TCP 9000, nhưng
không đọc bất kỳ dữ liệu nào::

ổ cắm nhập khẩu
  thời gian nhập khẩu
  cổng = 9000
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.bind(('0.0.0.0', cổng))
  s.lắng nghe(1)
  sock, addr = s.accept()
  trong khi Đúng:
      thời gian.ngủ (9999999)

Lưu mã ở trên dưới dạng server_coalesce.py và chạy::

python3 server_coalesce.py

Trên máy khách, lưu mã bên dưới dưới dạng client_coalesce.py::

ổ cắm nhập khẩu
  máy chủ = 'nstat-b'
  cổng = 9000
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.connect((máy chủ, cổng))

Chạy::

nstatuser@nstat-a:~$ python3 -i client_coalesce.py

Chúng tôi sử dụng '-i' để chuyển sang chế độ tương tác, sau đó là gói ::

>>> s.send(b'foo')
  3

Gửi lại gói tin::

>>> s.send(b'bar')
  3

Trên máy chủ, chạy nstat::

ubuntu@nstat-b:~$ nstat
  #kernel
  IpInNhận 2 0,0
  IpInCung cấp 2 0.0
  IpOutRequests 2 0.0
  TcpInSegs 2 0.0
  TcpOutSegs 2 0.0
  TcpExtTCPRcvCoalesce 1 0.0
  IpExtInOctets 110 0.0
  IpExtOutOctets 104 0.0
  IpExtInNoECTPkts 2 0.0

Máy khách đã gửi hai gói, máy chủ không đọc bất kỳ dữ liệu nào. Khi nào
gói thứ hai đã đến máy chủ, gói đầu tiên vẫn ở đó
hàng đợi nhận. Vì vậy, lớp TCP đã hợp nhất hai gói và chúng tôi
có thể tìm thấy TcpExtTCPRcvCoalesce tăng 1.

TcpExtListenOverflows và TcpExtListenDrops
-------------------------------------------
Trên máy chủ, chạy lệnh nc, nghe trên cổng 9000::

nstatuser@nstat-b:~$ nc -lkv 0.0.0.0 9000
  Nghe trên [0.0.0.0] (gia đình 0, cổng 9000)

Trên máy khách, chạy 3 lệnh nc trong các thiết bị đầu cuối khác nhau ::

nstatuser@nstat-a:~$ nc -v nstat-b 9000
  Kết nối với cổng nstat-b 9000 [tcp/*] đã thành công!

Lệnh nc chỉ chấp nhận 1 kết nối và độ dài hàng đợi chấp nhận
là 1. Khi triển khai linux hiện tại, đặt độ dài hàng đợi thành n có nghĩa là
chiều dài hàng đợi thực tế là n+1. Bây giờ chúng tôi tạo 3 kết nối, 1 được chấp nhận
bởi nc, 2 trong hàng đợi được chấp nhận, do đó hàng đợi chấp nhận đã đầy.

Trước khi chạy nc thứ 4, chúng tôi xóa lịch sử nstat trên máy chủ::

nstatuser@nstat-b:~$ nstat -n

Chạy nc thứ 4 trên máy khách::

nstatuser@nstat-a:~$ nc -v nstat-b 9000

Nếu máy chủ nc đang chạy trên kernel 4.10 hoặc phiên bản cao hơn, bạn
sẽ không thấy thông báo "Kết nối tới... thành công!" chuỗi, bởi vì hạt nhân
sẽ loại bỏ SYN nếu hàng đợi chấp nhận đầy. Nếu máy khách nc đang chạy
trên kernel cũ, bạn sẽ thấy kết nối đã thành công,
bởi vì kernel sẽ hoàn thành quá trình bắt tay 3 bước và giữ socket
trên hàng đợi nửa mở. Tôi đã thử nghiệm trên kernel 4.15. Dưới đây là nstat
trên máy chủ::

nstatuser@nstat-b:~$ nstat
  #kernel
  IpInNhận 4 0,0
  IpInCung cấp 4 0.0
  TcpInSegs 4 0.0
  TcpExtListenOverflows 4 0.0
  TcpExtListenDrops 4 0.0
  IpExtInOctets 240 0.0
  IpExtInNoECTPkts 4 0.0

Cả TcpExtListenOverflows và TcpExtListenDrops đều là 4. Nếu đến lúc đó
giữa nc thứ 4 và nstat dài hơn, giá trị của
TcpExtListenOverflows và TcpExtListenDrops sẽ lớn hơn, bởi vì
SYN của nc thứ 4 đã bị rơi, khách hàng đang thử lại.

IpInAddrErrors, IpExtInNoRoutes và IpOutNoRoutes
-------------------------------------------------
máy chủ Địa chỉ IP A: 192.168.122.250
địa chỉ IP máy chủ B: 192.168.122.251
Chuẩn bị trên máy chủ A, thêm tuyến đến máy chủ B::

$ sudo ip tuyến thêm 8.8.8.8/32 qua 192.168.122.251

Chuẩn bị trên máy chủ B, tắt send_redirects cho tất cả các giao diện ::

$ sudo sysctl -w net.ipv4.conf.all.send_redirects=0
  $ sudo sysctl -w net.ipv4.conf.ens3.send_redirects=0
  $ sudo sysctl -w net.ipv4.conf.lo.send_redirects=0
  $ sudo sysctl -w net.ipv4.conf.default.send_redirects=0

Chúng tôi muốn để máy chủ A gửi gói đến 8.8.8.8 và định tuyến gói
đến máy chủ B. Khi máy chủ B nhận được gói như vậy, nó có thể gửi ICMP
Chuyển hướng tin nhắn đến máy chủ A, đặt send_redirects thành 0 sẽ tắt
hành vi này.

Đầu tiên, tạo InAddrErrors. Trên máy chủ B, chúng tôi tắt tính năng chuyển tiếp IP::

$ sudo sysctl -w net.ipv4.conf.all.forwarding=0

Trên máy chủ A, chúng tôi gửi gói đến 8.8.8.8::

$ nc -v 8.8.8.8 53

Trên máy chủ B, chúng tôi kiểm tra đầu ra của nstat::

$ nstat
  #kernel
  IpInNhận 3 0,0
  IpInAddrErrors 3 0.0
  IpExtInOctets 180 0.0
  IpExtInNoECTPkts 3 0.0

Vì chúng tôi đã để máy chủ A định tuyến 8.8.8.8 đến máy chủ B và chúng tôi đã tắt IP
chuyển tiếp trên máy chủ B, Máy chủ A gửi gói tin đến máy chủ B, sau đó đến máy chủ B
các gói bị rớt và IpInAddrErrors tăng lên. Như lệnh nc sẽ
gửi lại gói SYN nếu nó không nhận được SYN+ACK, chúng tôi có thể tìm thấy
nhiều lỗi IpInAddr.

Thứ hai, tạo IpExtInNoRoutes. Trên máy chủ B, chúng tôi kích hoạt IP
chuyển tiếp::

$ sudo sysctl -w net.ipv4.conf.all.forwarding=1

Kiểm tra bảng lộ trình của máy chủ B và xóa tuyến đường mặc định::

$ ip hiển thị lộ trình
  mặc định qua 192.168.122.1 dev ens3 proto static
  192.168.122.0/24 dev ens3 liên kết phạm vi hạt nhân nguyên mẫu src 192.168.122.251
  $ sudo ip tuyến xóa mặc định qua 192.168.122.1 dev ens3 proto static

Trên máy chủ A, chúng tôi liên hệ lại với 8.8.8.8::

$ nc -v 8.8.8.8 53
  nc: kết nối với 8.8.8.8 cổng 53 (tcp) không thành công: Không thể truy cập mạng

Trên máy chủ B, chạy nstat::

$ nstat
  #kernel
  IpInNhận 1 0,0
  IpOutRequests 1 0.0
  IcmpOutMsgs 1 0.0
  IcmpOutDestUnreachs 1 0.0
  IcmpMsgOutType3 1 0.0
  IpExtInNoRoutes 1 0.0
  IpExtInOctets 60 0.0
  IpExtOutOctets 88 0.0
  IpExtInNoECTPkts 1 0,0

Chúng tôi đã bật chuyển tiếp IP trên máy chủ B, khi máy chủ B nhận được gói
địa chỉ IP đích nào là 8.8.8.8, máy chủ B sẽ cố gắng chuyển tiếp
gói này. Chúng tôi đã xóa tuyến đường mặc định, không có tuyến đường nào cho
8.8.8.8, do đó máy chủ B tăng IpExtInNoRoutes và gửi "ICMP
Thông báo đích không thể truy cập" tới máy chủ A.

Thứ ba, tạo IpOutNoRoutes. Chạy lệnh ping trên máy chủ B::

$ ping -c 1 8.8.8.8
  kết nối: Mạng không thể truy cập được

Chạy nstat trên máy chủ B::

$ nstat
  #kernel
  IpOutNoRoutes 1 0.0

Chúng tôi đã xóa tuyến đường mặc định trên máy chủ B. Máy chủ B không thể tìm thấy
tuyến đường cho địa chỉ IP 8.8.8.8, do đó máy chủ B tăng lên
IpOutNoRoutes.

TcpExtTCPACKBỏ quaSynRecv
--------------------------
Trong thử nghiệm này, chúng tôi gửi 3 gói SYN giống nhau từ máy khách đến máy chủ. các
SYN đầu tiên sẽ cho phép máy chủ tạo ổ cắm, đặt nó ở trạng thái Syn-Recv,
và trả lời SYN/ACK. SYN thứ hai sẽ cho phép máy chủ trả lời SYN/ACK
một lần nữa và ghi lại thời gian trả lời (thời gian trả lời ACK trùng lặp). các
SYN thứ ba sẽ cho phép máy chủ kiểm tra thời gian trả lời ACK trùng lặp trước đó,
và quyết định bỏ qua ACK trùng lặp, sau đó tăng
Bộ đếm TcpExtTCPACKSkippedSynRecv.

Chạy tcpdump để chụp gói SYN ::

nstatuser@nstat-a:~$ sudo tcpdump -c 1 -w /tmp/syn.pcap port 9000
  tcpdump: nghe trên ens3, kiểu liên kết EN10MB (Ethernet), kích thước chụp 262144 byte

Mở terminal khác, chạy lệnh nc ::

nstatuser@nstat-a:~$ nc nstat-b 9000

Vì nstat-b không nghe trên cổng 9000 nên nó sẽ trả lời RST và
lệnh nc thoát ngay lập tức. Tcpdump thế là đủ rồi
lệnh để bắt gói SYN. Một máy chủ linux có thể sử dụng phần cứng
giảm tải cho tổng kiểm tra TCP, do đó tổng kiểm tra trong /tmp/syn.pcap
có thể không đúng. Chúng tôi gọi tcprewrite để sửa nó ::

nstatuser@nstat-a:~$ tcprewrite --infile=/tmp/syn.pcap --outfile=/tmp/syn_fixcsum.pcap --fixcsum

Trên nstat-b, chúng ta chạy nc để nghe trên cổng 9000::

nstatuser@nstat-b:~$ nc -lkv 9000
  Nghe trên [0.0.0.0] (gia đình 0, cổng 9000)

Trên nstat-a, chúng tôi đã chặn gói từ cổng 9000 hoặc nstat-a sẽ gửi
RST tới nstat-b::

nstatuser@nstat-a:~$ sudo iptables -A INPUT -p tcp --sport 9000 -j DROP

Gửi 3 SYN liên tục tới nstat-b::

nstatuser@nstat-a:~$ for i in {1..3}; làm sudo tcpreplay -i ens3 /tmp/syn_fixcsum.pcap; xong

Kiểm tra bộ đếm snmp trên nstat-b::

nstatuser@nstat-b:~$ nstat | grep -i bỏ qua
  TcpExtTCPACKBỏ quaSynRecv 1 0,0

Đúng như chúng tôi mong đợi, TcpExtTCPACKSkippedSynRecv là 1.

TcpExtTCPACKBỏ quaPAWS
-----------------------
Để kích hoạt PAWS, chúng tôi có thể gửi SYN cũ.

Trên nstat-b, để nc nghe trên cổng 9000::

nstatuser@nstat-b:~$ nc -lkv 9000
  Nghe trên [0.0.0.0] (gia đình 0, cổng 9000)

Trên nstat-a, chạy tcpdump để chụp SYN::

nstatuser@nstat-a:~$ sudo tcpdump -w /tmp/paws_pre.pcap -c 1 cổng 9000
  tcpdump: nghe trên ens3, kiểu liên kết EN10MB (Ethernet), kích thước chụp 262144 byte

Trên nstat-a, chạy nc với tư cách máy khách để kết nối nstat-b::

nstatuser@nstat-a:~$ nc -v nstat-b 9000
  Kết nối với cổng nstat-b 9000 [tcp/*] đã thành công!

Bây giờ tcpdump đã chiếm được SYN và thoát. Chúng ta nên khắc phục
tổng kiểm tra::

nstatuser@nstat-a:~$ tcprewrite --infile /tmp/paws_pre.pcap --outfile /tmp/paws.pcap --fixcsum

Gửi gói SYN hai lần::

nstatuser@nstat-a:~$ for i in {1..2}; làm sudo tcpreplay -i ens3 /tmp/paws.pcap; xong

Trên nstat-b, kiểm tra bộ đếm snmp::

nstatuser@nstat-b:~$ nstat | grep -i bỏ qua
  TcpExtTCPACKBỏ quaPAWS 1 0,0

Chúng tôi đã gửi hai chiếc SYN qua tcpreplay, cả hai đều sẽ để PAWS kiểm tra
không thành công, nstat-b đã trả lời ACK cho SYN đầu tiên, bỏ qua ACK
cho SYN thứ hai và cập nhật TcpExtTCPACKSkippedPAWS.

TcpExtTCPACKBỏ quaSeq
----------------------
Để kích hoạt TcpExtTCPACKSkippedSeq, chúng tôi gửi các gói có giá trị hợp lệ
dấu thời gian (để vượt qua kiểm tra PAWS) nhưng số thứ tự bị vượt quá
cửa sổ. Ngăn xếp TCP linux sẽ tránh bỏ qua nếu gói có
dữ liệu, vì vậy chúng tôi cần một gói ACK thuần túy. Để tạo ra một gói như vậy, chúng ta
có thể tạo hai ổ cắm: một trên cổng 9000, một trên cổng 9001. Sau đó
chúng tôi chụp ACK trên cổng 9001, thay đổi cổng nguồn/đích
số để phù hợp với ổ cắm cổng 9000. Sau đó chúng ta có thể kích hoạt
TcpExtTCPACKSkippedSeq qua gói này.

Trên nstat-b, mở hai terminal, chạy hai lệnh nc để nghe trên cả hai
cổng 9000 và cổng 9001::

nstatuser@nstat-b:~$ nc -lkv 9000
  Nghe trên [0.0.0.0] (gia đình 0, cổng 9000)

nstatuser@nstat-b:~$ nc -lkv 9001
  Nghe trên [0.0.0.0] (gia đình 0, cổng 9001)

Trên nstat-a, chạy hai máy khách nc::

nstatuser@nstat-a:~$ nc -v nstat-b 9000
  Kết nối với cổng nstat-b 9000 [tcp/*] đã thành công!

nstatuser@nstat-a:~$ nc -v nstat-b 9001
  Kết nối với cổng nstat-b 9001 [tcp/*] đã thành công!

Trên nstat-a, chạy tcpdump để chụp ACK::

nstatuser@nstat-a:~$ sudo tcpdump -w /tmp/seq_pre.pcap -c 1 cổng dst 9001
  tcpdump: nghe trên ens3, kiểu liên kết EN10MB (Ethernet), kích thước chụp 262144 byte

Trên nstat-b, gửi gói qua ổ cắm cổng 9001. Ví dụ. chúng tôi đã gửi một
chuỗi 'foo' trong ví dụ của chúng tôi::

nstatuser@nstat-b:~$ nc -lkv 9001
  Nghe trên [0.0.0.0] (gia đình 0, cổng 9001)
  Đã nhận được kết nối từ nstat-a 42132!
  foo

Trên nstat-a, tcpdump đáng lẽ phải chiếm được ACK. Chúng ta nên kiểm tra
số cổng nguồn của hai máy khách nc::

nstatuser@nstat-a:~$ ss -ta '( dport = :9000 |ZZ0000ZZ tee
  Trạng thái Recv-Q Send-Q Địa chỉ cục bộ: Cổng Địa chỉ ngang hàng: Cổng
  ESTAB 0 0 192.168.122.250:50208 192.168.122.251:9000
  ESTAB 0 0 192.168.122.250:42132 192.168.122.251:9001

Chạy tcprewrite, đổi cổng 9001 thành cổng 9000, đổi cổng 42132 thành
cổng 50208::

nstatuser@nstat-a:~$ tcprewrite --infile /tmp/seq_pre.pcap --outfile /tmp/seq.pcap -r 9001:9000 -r 42132:50208 --fixcsum

Bây giờ /tmp/seq.pcap là gói chúng ta cần. Gửi nó tới nstat-b::

nstatuser@nstat-a:~$ for i in {1..2}; làm sudo tcpreplay -i ens3 /tmp/seq.pcap; xong

Kiểm tra TcpExtTCPACKSkippedSeq trên nstat-b::

nstatuser@nstat-b:~$ nstat | grep -i bỏ qua
  TcpExtTCPACKBỏ quaSeq 1 0,0
