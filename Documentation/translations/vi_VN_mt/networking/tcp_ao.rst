.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tcp_ao.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================
Tùy chọn xác thực TCP Triển khai Linux (RFC5925)
=============================================================

Tùy chọn xác thực TCP (TCP-AO) cung cấp tiện ích mở rộng TCP nhằm mục đích xác minh
phân đoạn giữa các đồng nghiệp đáng tin cậy. Nó bổ sung thêm tùy chọn tiêu đề TCP mới với
Mã xác thực tin nhắn (MAC). MAC được tạo ra từ nội dung
của phân đoạn TCP sử dụng hàm băm với mật khẩu được cả hai thiết bị ngang hàng biết.
Mục đích của TCP-AO là không dùng TCP-MD5 để cung cấp bảo mật tốt hơn,
xoay vòng khóa và hỗ trợ nhiều thuật toán băm khác nhau.

1. Giới thiệu
===============

.. table:: Short and Limited Comparison of TCP-AO and TCP-MD5

 +----------------------+------------------------+-----------------------+
 |                      |       TCP-MD5          |         TCP-AO        |
 +======================+========================+=======================+
 |Supported hashing     |MD5                     |Must support HMAC-SHA1 |
 |algorithms            |(cryptographically weak)|(chosen-prefix attacks)|
 |                      |                        |and CMAC-AES-128 (only |
 |                      |                        |side-channel attacks). |
 |                      |                        |May support any hashing|
 |                      |                        |algorithm.             |
 +----------------------+------------------------+-----------------------+
 |Length of MACs (bytes)|16                      |Typically 12-16.       |
 |                      |                        |Other variants that fit|
 |                      |                        |TCP header permitted.  |
 +----------------------+------------------------+-----------------------+
 |Number of keys per    |1                       |Many                   |
 |TCP connection        |                        |                       |
 +----------------------+------------------------+-----------------------+
 |Possibility to change |Non-practical (both     |Supported by protocol  |
 |an active key         |peers have to change    |                       |
 |                      |them during MSL)        |                       |
 +----------------------+------------------------+-----------------------+
 |Protection against    |No                      |Yes: ignoring them     |
 |ICMP 'hard errors'    |                        |by default on          |
 |                      |                        |established connections|
 +----------------------+------------------------+-----------------------+
 |Protection against    |No                      |Yes: pseudo-header     |
 |traffic-crossing      |                        |includes TCP ports.    |
 |attack                |                        |                       |
 +----------------------+------------------------+-----------------------+
 |Protection against    |No                      |Sequence Number        |
 |replayed TCP segments |                        |Extension (SNE) and    |
 |                      |                        |Initial Sequence       |
 |                      |                        |Numbers (ISNs)         |
 +----------------------+------------------------+-----------------------+
 |Supports              |Yes                     |No. ISNs+SNE are needed|
 |Connectionless Resets |                        |to correctly sign RST. |
 +----------------------+------------------------+-----------------------+
 |Standards             |RFC 2385                |RFC 5925, RFC 5926     |
 +----------------------+------------------------+-----------------------+


1.1 Câu hỏi thường gặp (FAQ) có tham chiếu đến RFC 5925
----------------------------------------------------------------

Câu hỏi: SendID hoặc RecvID có thể không phải là duy nhất cho cùng 4 bộ dữ liệu không?
(srcaddr, srcport, dstaddr, dstport)?

Đ: Không [3.1]::

>> ID của MKT MUST NOT trùng nhau ở nơi kết nối TCP của chúng
   định danh trùng lặp.

Câu hỏi: Có thể xóa Master Key Tuple (MKT) cho một kết nối đang hoạt động không?

Đáp: Không, trừ khi nó được sao chép vào Khối điều khiển vận chuyển (TCB) [3.1]::

Người ta cho rằng MKT ảnh hưởng đến một kết nối cụ thể không thể
   bị hủy trong một kết nối đang hoạt động -- hoặc, tương đương, điều đó
   các tham số của nó được sao chép vào một khu vực cục bộ của kết nối (tức là,
   được khởi tạo) và do đó những thay đổi sẽ chỉ ảnh hưởng đến các kết nối mới.

Hỏi: Nếu cần xóa một chiếc MKT cũ thì trình tự thực hiện như thế nào?
để không loại bỏ nó cho một kết nối hoạt động? (Vì nó vẫn có thể được sử dụng
bất cứ lúc nào sau đó)

Trả lời: RFC 5925 không được chỉ định, có vẻ như đó là một vấn đề đối với việc quản lý khóa
để đảm bảo rằng không ai sử dụng MKT đó trước khi thử gỡ bỏ nó.

Hỏi: MKT cũ có thể tồn tại mãi mãi và được sử dụng bởi một thiết bị ngang hàng khác không?

Trả lời: Có thể, nhiệm vụ quản lý khóa là quyết định thời điểm xóa khóa cũ [6.1]::

Quyết định khi nào bắt đầu sử dụng khóa là một vấn đề về hiệu suất. Quyết định
   khi nào cần xóa MKT là vấn đề bảo mật. Dự kiến MKT không hợp lệ
   cần được gỡ bỏ. TCP-AO không cung cấp cơ chế phối hợp loại bỏ chúng,
   vì chúng tôi coi đây là một hoạt động quản lý quan trọng.

cũng [6.1]::

Cách duy nhất để tránh sử dụng lại MKT đã sử dụng trước đó là xóa MKT
   khi nó không còn được coi là được phép nữa.

Linux TCP-AO sẽ cố gắng hết sức để ngăn bạn xóa khóa
đang được sử dụng, coi đó là lỗi quản lý khóa. Nhưng từ khi giữ
một khóa lỗi thời có thể trở thành một vấn đề bảo mật và như một khóa ngang hàng có thể
vô tình ngăn chặn việc xóa khóa cũ bằng cách luôn đặt
nó dưới dạng RNextKeyID - một cơ chế loại bỏ khóa bắt buộc được cung cấp, trong đó
không gian người dùng phải cung cấp KeyID để sử dụng thay vì khóa đang bị xóa
và hạt nhân sẽ xóa khóa cũ một cách nguyên tử, ngay cả khi khóa ngang hàng
vẫn yêu cầu nó. Không có đảm bảo nào cho việc buộc xóa như ngang hàng
có thể chưa có khóa mới - kết nối TCP có thể bị hỏng.
Ngoài ra, người ta có thể chọn tắt ổ cắm.

Hỏi: Điều gì xảy ra khi một gói được nhận trên một kết nối mới mà không xác định được
RecvID của MKT?

Trả lời: RFC 5925 chỉ định rằng theo mặc định, nó được chấp nhận với cảnh báo được ghi lại, nhưng
người dùng có thể cấu hình hành vi này [7.5.1.a]::

Nếu phân đoạn là SYN thì đây là phân đoạn đầu tiên của một phân đoạn mới
   kết nối. Tìm MKT phù hợp cho phân đoạn này bằng cách sử dụng
   cặp ổ cắm và KeyID TCP-AO của nó, khớp với kết nối TCP của MKT
   mã định danh và RecvID của MKT.

Tôi. Nếu không có MKT phù hợp, hãy xóa TCP-AO khỏi phân đoạn.
         Tiếp tục xử lý TCP tiếp theo của phân đoạn.
         NOTE: điều này giả định rằng các kết nối không khớp với bất kỳ MKT nào
         nên được âm thầm chấp nhận, như đã lưu ý trong Phần 7.3.

[7.3]::

>> Triển khai TCP-AO MUST cho phép cấu hình hành vi
   phân đoạn có TCP-AO nhưng không khớp với MKT. Mặc định ban đầu
   của cấu hình này SHOULD sẽ âm thầm chấp nhận các kết nối như vậy.
   Nếu đây không phải là trường hợp mong muốn, có thể đưa vào MKT để phù hợp với trường hợp đó
   kết nối hoặc kết nối có thể chỉ ra rằng TCP-AO là bắt buộc.
   Ngoài ra, cấu hình có thể được thay đổi để loại bỏ các phân đoạn có
   tùy chọn AO không khớp với MKT.

[10.2.b]::

Các kết nối không khớp với bất kỳ MKT nào không yêu cầu TCP-AO. Hơn nữa, đến
   các phân đoạn có TCP-AO không bị loại bỏ chỉ vì chúng bao gồm
   tùy chọn, miễn là chúng không khớp với bất kỳ MKT nào.

Lưu ý rằng việc triển khai Linux TCP-AO khác ở khía cạnh này. Hiện tại, TCP-AO
các phân đoạn có chữ ký khóa không xác định sẽ bị loại bỏ cùng với các cảnh báo được ghi lại.

Câu hỏi: RFC có ngụ ý quản lý khóa hạt nhân tập trung theo bất kỳ cách nào không?
(tức là một phím trên tất cả các kết nối MUST có thể được xoay cùng lúc?)

Đáp: Không được chỉ định. MKT có thể được quản lý trong không gian người dùng, phần duy nhất có liên quan đến
những thay đổi chính là [7.3]::

>> Tất cả các phân đoạn TCP MUST được kiểm tra dựa trên bộ MKT để khớp
   Mã định danh kết nối TCP.

Câu hỏi: Điều gì xảy ra khi RNextKeyID được yêu cầu bởi một máy ngang hàng không xác định? nên
kết nối có được thiết lập lại không?

Trả lời: Không nên, không cần thực hiện hành động nào [7.5.2.e]::

ii. Nếu chúng khác nhau, hãy xác định xem RNextKeyID MKT đã sẵn sàng chưa.

1. Nếu MKT tương ứng với cặp socket của đoạn và RNextKeyID
       không có sẵn, không cần thực hiện hành động nào (RNextKeyID của gói đã nhận
       phân đoạn cần khớp với SendID của MKT).

Câu hỏi: Current_key được đặt như thế nào và khi nào nó thay đổi? Đây có phải là do người dùng kích hoạt không
thay đổi hay nó được kích hoạt bởi một yêu cầu từ thiết bị ngang hàng từ xa? Nó được thiết lập bởi
người dùng một cách rõ ràng hoặc theo quy tắc phù hợp?

Đáp: current_key được thiết lập bởi RNextKeyID [6.1]::

Rnext_key chỉ được thay đổi khi có sự can thiệp thủ công của người dùng hoặc quản lý MKT
   hoạt động giao thức. Nó không bị thao túng bởi TCP-AO. Current_key được cập nhật
   bởi TCP-AO khi xử lý các phân đoạn TCP nhận được như đã thảo luận trong phân đoạn
   mô tả xử lý trong Phần 7.5. Lưu ý rằng thuật toán cho phép
   current_key để thay đổi thành MKT mới, sau đó đổi lại thành MKT trước đó
   đã sử dụng MKT (được gọi là "sao lưu"). Điều này có thể xảy ra trong quá trình thay đổi MKT khi
   các phân đoạn được nhận không theo thứ tự và được coi là một tính năng của TCP-AO,
   bởi vì sắp xếp lại không dẫn đến giảm.

[7.5.2.e.ii]::

2. Nếu MKT phù hợp tương ứng với cặp ổ cắm của phân khúc và
   RNextKeyID có sẵn:

Một. Đặt current_key thành RNextKeyID MKT.

Câu hỏi: Nếu cả hai thiết bị ngang hàng có nhiều MKT khớp với cặp ổ cắm của kết nối
(với các KeyID khác nhau), người gửi/người nhận nên chọn KeyID để sử dụng như thế nào?

Trả lời: Một số cơ chế nên chọn MKT "mong muốn" [3.3]::

Nhiều MKT có thể khớp với một phân đoạn gửi đi, ví dụ: khi MKT
   đang được thay đổi. Những MKT đó không được có ID xung đột (như đã lưu ý
   ở nơi khác) và một số cơ chế phải xác định MKT nào sẽ sử dụng cho mỗi
   phân khúc đi nhất định.

>> Phân đoạn TCP gửi đi MUST khớp nhiều nhất với một MKT mong muốn, được chỉ định
   bởi cặp ổ cắm của phân khúc. Phân đoạn MAY khớp với nhiều MKT, được cung cấp
   chính xác một MKT được chỉ định như mong muốn. Thông tin khác trong
   phân đoạn MAY được sử dụng để xác định MKT mong muốn khi có nhiều MKT
   trận đấu; thông tin đó MUST NOT bao gồm các giá trị trong bất kỳ trường tùy chọn TCP nào.

Câu hỏi: Kết nối TCP-MD5 có thể di chuyển sang TCP-AO (và ngược lại):

Đ: Không [1]::

Không thể di chuyển các kết nối được bảo vệ TCP MD5 sang TCP-AO vì TCP MD5
   không hỗ trợ bất kỳ thay đổi nào đối với thuật toán bảo mật của kết nối
   một khi được thành lập.

Câu hỏi: Nếu tất cả MKT bị xóa trên một kết nối, nó có thể trở thành kết nối không phải TCP-AO được ký không?
kết nối?

Trả lời: [7.5.2] không có lựa chọn giống như xử lý gói SYN trong [7.5.1.i]
điều đó sẽ cho phép chấp nhận các phân đoạn không có dấu hiệu (điều này sẽ không an toàn).
Mặc dù việc chuyển sang kết nối không phải TCP-AO không bị cấm trực tiếp, nhưng có vẻ như
RFC có nghĩa là gì. Ngoài ra, còn có yêu cầu về kết nối TCP-AO để
luôn có một current_key [3.3]::

TCP-AO yêu cầu mọi phân đoạn TCP được bảo vệ phải khớp chính xác với một MKT.

[3.3]::

>> Phân đoạn TCP đến bao gồm TCP-AO MUST khớp chính xác với một MKT,
   chỉ được biểu thị bằng cặp ổ cắm của phân khúc và KeyID TCP-AO của nó.

[4.4]::

Một hoặc nhiều MKT. Đây là những MKT phù hợp với kết nối này
   cặp ổ cắm.

Câu hỏi: Kết nối không phải TCP-AO có thể trở thành kết nối hỗ trợ TCP-AO không?

Trả lời: Không: đối với kết nối không phải TCP-AO đã được thiết lập thì điều đó là không thể
để chuyển sang sử dụng TCP-AO, vì việc tạo khóa lưu lượng yêu cầu thông tin ban đầu
số thứ tự. Diễn giải, bắt đầu sử dụng TCP-AO sẽ yêu cầu
thiết lập lại kết nối TCP.

2. Cơ sở dữ liệu MKT trong kernel và cơ sở dữ liệu trong không gian người dùng
===================================================

Hỗ trợ Linux TCP-AO được triển khai bằng ZZ0000ZZ, theo cách tương tự
tới TCP-MD5. Điều đó có nghĩa là ứng dụng không gian người dùng muốn sử dụng TCP-AO
nên thực hiện ZZ0001ZZ trên ổ cắm TCP khi muốn thêm,
loại bỏ hoặc xoay MKT. Cách tiếp cận này chuyển trách nhiệm quản lý chủ chốt
đối với không gian người dùng cũng như các quyết định về các trường hợp góc, tức là phải làm gì nếu
ngang hàng không tôn trọng RNextKeyID; di chuyển nhiều mã hơn vào không gian người dùng, đặc biệt là
chịu trách nhiệm về các quyết định chính sách. Ngoài ra, nó linh hoạt và có quy mô tốt
(cần ít khóa hơn so với trường hợp cơ sở dữ liệu trong kernel). Một cũng
nên nhớ rằng người dùng dự định chủ yếu là các quy trình BGP, không phải bất kỳ
các ứng dụng ngẫu nhiên, có nghĩa là so với các đường hầm IPsec,
không thực sự cần sự minh bạch và các daemon BGP hiện đại đã có
ZZ0002ZZ để hỗ trợ TCP-MD5.

.. table:: Considered pros and cons of the approaches

 +----------------------+------------------------+-----------------------+
 |                      |    ``setsockopt()``    |      in-kernel DB     |
 +======================+========================+=======================+
 | Extendability        | ``setsockopt()``       | Netlink messages are  |
 |                      | commands should be     | simple and extendable |
 |                      | extendable syscalls    |                       |
 +----------------------+------------------------+-----------------------+
 | Required userspace   | BGP or any application | could be transparent  |
 | changes              | that wants TCP-AO needs| as tunnels, providing |
 |                      | to perform             | something like        |
 |                      | ``setsockopt()s``      | ``ip tcpao add key``  |
 |                      | and do key management  | (delete/show/rotate)  |
 +----------------------+------------------------+-----------------------+
 |MKTs removal or adding| harder for userspace   | harder for kernel     |
 +----------------------+------------------------+-----------------------+
 | Dump-ability         | ``getsockopt()``       | Netlink .dump()       |
 |                      |                        | callback              |
 +----------------------+------------------------+-----------------------+
 | Limits on kernel     |                      equal                     |
 | resources/memory     |                                                |
 +----------------------+------------------------+-----------------------+
 | Scalability          | contention on          | contention on         |
 |                      | ``TCP_LISTEN`` sockets | the whole database    |
 +----------------------+------------------------+-----------------------+
 | Monitoring & warnings| ``TCP_DIAG``           | same Netlink socket   |
 +----------------------+------------------------+-----------------------+
 | Matching of MKTs     | half-problem: only     | hard                  |
 |                      | listen sockets         |                       |
 +----------------------+------------------------+-----------------------+


3. uAPI
=======

Linux cung cấp một bộ ZZ0000ZZ và ZZ0001ZZ cho phép
quản lý không gian người dùng TCP-AO trên cơ sở từng ổ cắm. Để thêm/xóa MKT
Phải sử dụng tùy chọn ổ cắm ZZ0002ZZ và ZZ0003ZZ TCP.
Không được phép thêm khóa trên kết nối không phải TCP-AO đã thiết lập
cũng như xóa khóa cuối cùng khỏi kết nối TCP-AO.

Lệnh ZZ0000ZZ có thể chỉ định ZZ0001ZZ
+ ZZ0002ZZ và/hoặc ZZ0003ZZ
+ ZZ0004ZZ khiến việc xóa đó bị "ép buộc": nó
cung cấp cho không gian người dùng một cách để xóa khóa đang được sử dụng và được thiết lập nguyên tử
một cái khác thay thế. Điều này không dành cho mục đích sử dụng thông thường và nên được sử dụng
chỉ khi thiết bị ngang hàng bỏ qua RNextKeyID và tiếp tục yêu cầu/sử dụng khóa cũ.
Nó cung cấp một cách để buộc xóa một khóa không đáng tin cậy nhưng có thể bị hỏng
kết nối TCP-AO.

Việc xoay phím thông thường/thông thường có thể được thực hiện với ZZ0000ZZ.
Nó cũng cung cấp uAPI để thay đổi cài đặt TCP-AO trên mỗi ổ cắm, chẳng hạn như
bỏ qua ICMP, cũng như xóa bộ đếm gói TCP-AO trên mỗi ổ cắm.
ZZ0001ZZ tương ứng có thể được sử dụng để lấy những thứ đó
cài đặt TCP-AO trên mỗi ổ cắm.

Một lệnh hữu ích khác là ZZ0000ZZ. Người ta có thể sử dụng nó
để liệt kê tất cả MKT trên ổ cắm TCP hoặc sử dụng bộ lọc để lấy khóa cho một ổ cắm cụ thể
ngang hàng và/hoặc sndid/rcvid, giao diện VRF L3 hoặc lấy current_key/rnext_key.

Để sửa chữa các kết nối TCP-AO ZZ0000ZZ có sẵn,
với điều kiện là người dùng trước đó đã kiểm tra/kết xuất ổ cắm bằng
ZZ0001ZZ.

Mẹo ở đây dành cho các ổ cắm TCP_LISTEN được chia tỷ lệ, có thể có hàng nghìn TCP-AO
phím, là: sử dụng các bộ lọc trong ZZ0000ZZ và không đồng bộ
xóa bằng ZZ0001ZZ.

Linux TCP-AO cũng cung cấp một loạt bộ đếm phân đoạn có thể hữu ích
với các vấn đề khắc phục sự cố/gỡ lỗi. Mỗi MKT đều có bộ đếm tốt/xấu
phản ánh số lượng gói đã vượt qua/xác minh không thành công.
Mỗi ổ cắm TCP-AO có các bộ đếm sau:
- cho các phân đoạn tốt (được ký hợp lệ)
- đối với các phân đoạn xấu (xác minh TCP-AO không thành công)
- đối với các phân đoạn có khóa không xác định
- đối với các phân đoạn được mong đợi có chữ ký AO nhưng không tìm thấy
- về số lượng ICMP bị bỏ qua

Bộ đếm trên mỗi ổ cắm TCP-AO cũng được nhân đôi với bộ đếm trên mỗi mạng,
tiếp xúc với SNMP. Đó là ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ và ZZ0004ZZ.

Nhằm mục đích giám sát, có các sự kiện theo dõi TCP-AO sau:
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ,
ZZ0006ZZ, ZZ0007ZZ, ZZ0008ZZ,
ZZ0009ZZ. Có thể kích hoạt riêng bất kỳ trong số chúng và
người ta có thể lọc chúng theo không gian tên mạng, 4-tuple, họ, chỉ mục L3 và tiêu đề TCP
cờ. Nếu một phân đoạn có tiêu đề TCP-AO, các bộ lọc cũng có thể bao gồm
keyid, rnext và maclen. Các bản cập nhật SNE bao gồm các số được chuyển qua.

RFC 5925 chỉ định rất dễ dàng cách thực hiện khớp cổng TCP cho
MKT::

Mã định danh kết nối TCP. Một cặp ổ cắm TCP, tức là một IP cục bộ
   địa chỉ, địa chỉ IP từ xa, cổng cục bộ TCP và cổng từ xa TCP.
   Các giá trị có thể được chỉ định một phần bằng cách sử dụng phạm vi (ví dụ: 2-30), mặt nạ
   (ví dụ: 0xF0), ký tự đại diện (ví dụ: "*") hoặc bất kỳ dấu hiệu phù hợp nào khác.

Hiện tại việc triển khai Linux TCP-AO không cung cấp bất kỳ cổng TCP nào phù hợp.
Có lẽ, phạm vi cổng là linh hoạt nhất đối với uAPI, nhưng cho đến nay
không được thực hiện.

4. Cuộc đua ZZ0000ZZ vs ZZ0001ZZ
========================================

Ngược lại với kết nối TCP-MD5 đã được thiết lập chỉ có một khóa,
Các kết nối TCP-AO có thể có nhiều khóa, điều đó có nghĩa là các kết nối được chấp nhận
trên ổ cắm nghe cũng có thể có số lượng khóa bất kỳ. Khi sao chép tất cả những thứ đó
các phím trên SYN được ký hợp lệ đầu tiên sẽ làm cho ổ cắm yêu cầu lớn hơn, điều đó
sẽ là điều không mong muốn. Hiện tại, việc triển khai không sao chép khóa
để yêu cầu ổ cắm mà thay vào đó hãy tra cứu chúng trên ổ cắm trình nghe "cha mẹ".

Kết quả là khi không gian người dùng xóa các khóa TCP-AO, điều đó có thể bị hỏng
các kết nối chưa được thiết lập trên các ổ cắm yêu cầu cũng như không xóa
các khóa từ các ổ cắm đã được thiết lập nhưng chưa được ZZ0000ZZ'ed,
treo trong hàng đợi chấp nhận.

Điều ngược lại cũng đúng: nếu vùng người dùng thêm một khóa mới cho một thiết bị ngang hàng trên
một ổ cắm người nghe, các ổ cắm đã thiết lập trong hàng đợi chấp nhận sẽ không
có chìa khóa mới.

Tại thời điểm này, độ phân giải cho hai cuộc đua:
ZZ0000ZZ so với ZZ0001ZZ
và ZZ0002ZZ so với ZZ0003ZZ được ủy quyền cho không gian người dùng.
Điều này có nghĩa là người dùng dự kiến sẽ kiểm tra MKT trên ổ cắm
đã được ZZ0004ZZ trả về để xác minh rằng bất kỳ thao tác xoay khóa nào
đã xảy ra trên ổ cắm nghe sẽ được phản ánh trên kết nối mới được thiết lập.

Đây là cách tiếp cận "không làm gì" tương tự với TCP-MD5 từ phía kernel và
có thể được thay đổi sau này bằng cách giới thiệu các cờ mới cho ZZ0000ZZ
và ZZ0001ZZ.

Lưu ý rằng cuộc đua này rất hiếm vì nó cần xoay phím TCP-AO để diễn ra
trong quá trình bắt tay 3 chiều cho kết nối TCP mới.

5. Tương tác với TCP-MD5
===========================

Kết nối TCP không thể di chuyển giữa các tùy chọn TCP-AO và TCP-MD5. các
ổ cắm đã thiết lập có khóa AO hoặc MD5 bị hạn chế đối với
thêm phím của tùy chọn khác.

Đối với ổ cắm nghe, hình ảnh sẽ khác: Máy chủ BGP có thể muốn nhận
cả máy khách TCP-AO và (không dùng nữa) TCP-MD5. Kết quả là cả hai loại khóa
có thể được thêm vào ổ cắm TCP_CLOSED hoặc TCP_LISTEN. Không được phép thêm
các loại khóa khác nhau cho cùng một thiết bị ngang hàng.

6. Triển khai SNE Linux
===========================

RFC 5925 [6.2] mô tả thuật toán về cách mở rộng số thứ tự TCP
với SNE.  Nói tóm lại: TCP phải theo dõi các số thứ tự trước đó và đặt
sne_flag khi số SEQ hiện tại chuyển sang. Cờ sẽ bị xóa khi
cả số SEQ hiện tại và trước đó đều vượt qua 0x7fff, tức là 32Kb.

Trong những thời điểm sne_flag được đặt, thuật toán sẽ so sánh SEQ cho mỗi gói với
0x7fff và nếu nó cao hơn 32Kb, nó giả định rằng gói đó phải là
được xác minh bằng SNE trước khi tăng. Kết quả là, có
cái này [0; 32Kb], khi các gói có (SNE - 1) có thể được chấp nhận.

Việc triển khai Linux đơn giản hóa việc này một chút: vì ngăn xếp mạng đã theo dõi
byte SEQ đầu tiên mà ACK muốn có (snd_una) và byte SEQ tiếp theo mà
đang bị truy nã (rcv_nxt) - đó là đủ thông tin để ước tính sơ bộ
cả người gửi và người nhận đều ở đâu trong không gian số SEQ 4GB.
Khi chúng chuyển về 0, SNE tương ứng sẽ tăng lên.

tcp_ao_compute_sne() được gọi cho mỗi phân đoạn TCP-AO. Nó so sánh số SEQ
từ phân đoạn có snd_una hoặc rcv_nxt và khớp kết quả vào cửa sổ 2GB xung quanh chúng,
phát hiện số SEQ lăn qua. Điều đó đơn giản hóa mã rất nhiều và chỉ
yêu cầu số SNE được lưu trữ trên mọi ổ cắm TCP-AO.

Cửa sổ 2GB thoạt nhìn có vẻ dễ dãi hơn nhiều so với
RFC 5926. Nhưng cái đó chỉ dùng để chọn đúng SNE trước/sau
một lần tái đầu tư. Nó cho phép phát lại nhiều phân đoạn TCP hơn, nhưng tất cả đều thường xuyên
Kiểm tra TCP trong tcp_sequence() được áp dụng trên phân đoạn đã xác minh.
Vì vậy, nó đánh đổi sự chấp nhận dễ dàng hơn một chút đối với việc phát lại/truyền lại
các phân đoạn vì sự đơn giản của thuật toán và những gì có vẻ hoạt động tốt hơn
cho các cửa sổ TCP lớn.

7. Liên kết
========

RFC 5925 Tùy chọn xác thực TCP
   ZZ0000ZZ

Thuật toán mã hóa RFC 5926 cho tùy chọn xác thực TCP (TCP-AO)
   ZZ0000ZZ

Bản nháp "Thuật toán SHA-2 cho tùy chọn xác thực TCP (TCP-AO)"
   ZZ0000ZZ

RFC 2385 Bảo vệ các phiên BGP thông qua Tùy chọn Chữ ký TCP MD5
   ZZ0000ZZ

:Tác giả: Dmitry Safonov <dima@arista.com>