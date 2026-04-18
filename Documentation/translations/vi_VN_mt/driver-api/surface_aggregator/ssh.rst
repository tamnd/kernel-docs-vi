.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/ssh.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. |u8| replace:: :c:type:`u8 <u8>`
.. |u16| replace:: :c:type:`u16 <u16>`
.. |TYPE| replace:: ``TYPE``
.. |LEN| replace:: ``LEN``
.. |SEQ| replace:: ``SEQ``
.. |SYN| replace:: ``SYN``
.. |NAK| replace:: ``NAK``
.. |ACK| replace:: ``ACK``
.. |DATA| replace:: ``DATA``
.. |DATA_SEQ| replace:: ``DATA_SEQ``
.. |DATA_NSQ| replace:: ``DATA_NSQ``
.. |TC| replace:: ``TC``
.. |TID| replace:: ``TID``
.. |SID| replace:: ``SID``
.. |IID| replace:: ``IID``
.. |RQID| replace:: ``RQID``
.. |CID| replace:: ``CID``

==============================
Giao thức trung tâm nối tiếp bề mặt
===========================

Surface Serial Hub (SSH) là giao diện truyền thông trung tâm cho
Bộ điều khiển Mô-đun tổng hợp bề mặt được nhúng (SAM hoặc EC), được tìm thấy trên phiên bản mới hơn
Các thế hệ bề mặt Chúng tôi sẽ đề cập đến giao thức và giao diện này như
SAM-over-SSH, trái ngược với SAM-over-HID của các thế hệ cũ.

Trên các thiết bị Surface có SAM-over-SSH, SAM được kết nối với máy chủ thông qua UART
và được xác định trong ACPI là thiết bị có ID ZZ0000ZZ. Trên các thiết bị này,
chức năng quan trọng được cung cấp thông qua SAM, bao gồm cả quyền truy cập vào pin
và thông tin và sự kiện về nguồn điện, các sự kiện và thông số đọc nhiệt, cùng nhiều thông tin khác
nhiều hơn nữa. Đối với Máy tính xách tay Surface, đầu vào bàn phím được xử lý thông qua hướng dẫn HID
thông qua SAM, trên Surface Laptop 3 và Surface Book 3, điều này cũng bao gồm
đầu vào bàn di chuột.

Lưu ý rằng tuyên bố từ chối trách nhiệm tiêu chuẩn cho hệ thống con này cũng áp dụng cho hệ thống con này.
tài liệu: Tất cả những điều này đã được thiết kế ngược và do đó có thể sai sót
và/hoặc không đầy đủ.

Tất cả các CRC được sử dụng sau đây là ZZ0000ZZ hai byte.
Tất cả các giá trị nhiều byte đều là little-endian, không có khoảng đệm ngầm giữa
các giá trị.


Giao thức gói SSH: Định nghĩa
================================

Đơn vị giao tiếp cơ bản của giao thức SSH là một khung
(ZZ0000ZZ). Một khung bao gồm những điều sau đây
các trường, được đóng gói cùng nhau và theo thứ tự:

.. flat-table:: SSH Frame
   :widths: 1 1 4
   :header-rows: 1

   * - Field
     - Type
     - Description

   * - |TYPE|
     - |u8|
     - Type identifier of the frame.

   * - |LEN|
     - |u16|
     - Length of the payload associated with the frame.

   * - |SEQ|
     - |u8|
     - Sequence ID (see explanation below).

Mỗi cấu trúc khung được theo sau bởi CRC trên cấu trúc này. CRC đã hết
cấu trúc khung (các trường ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ) được đặt trực tiếp
sau cấu trúc khung và trước tải trọng. Tải trọng được theo sau bởi
CRC của chính nó (trên tất cả các byte tải trọng). Nếu tải trọng không có mặt (tức là
khung có ZZ0000ZZ), CRC của tải trọng vẫn tồn tại và sẽ
đánh giá thành ZZ0001ZZ. Trường ZZ0005ZZ không bao gồm bất kỳ CRC nào, nó
bằng số byte giữa CRC của khung và CRC của khung
tải trọng.

Ngoài ra, các chuỗi hai byte cố định sau đây được sử dụng:

.. flat-table:: SSH Byte Sequences
   :widths: 1 1 4
   :header-rows: 1

   * - Name
     - Value
     - Description

   * - |SYN|
     - ``[0xAA, 0x55]``
     - Synchronization bytes.

Một thông báo bao gồm ZZ0001ZZ, theo sau là khung (ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và
CRC) và, nếu được chỉ định trong khung (tức là ZZ0000ZZ), byte tải trọng,
cuối cùng được theo sau, bất kể tải trọng có hiện diện hay không, tải trọng CRC. các
các thông điệp tương ứng với một cuộc trao đổi, một phần, được xác định bằng cách có
cùng một ID trình tự (ZZ0005ZZ), được lưu trữ bên trong khung (thông tin thêm về điều này trong phần tiếp theo
phần). ID trình tự là một bộ đếm gói.

Một khung có thể có các loại sau
(ZZ0000ZZ):

.. flat-table:: SSH Frame Types
   :widths: 1 1 4
   :header-rows: 1

   * - Name
     - Value
     - Short Description

   * - |NAK|
     - ``0x04``
     - Sent on error in previously received message.

   * - |ACK|
     - ``0x40``
     - Sent to acknowledge receival of |DATA| frame.

   * - |DATA_SEQ|
     - ``0x80``
     - Sent to transfer data. Sequenced.

   * - |DATA_NSQ|
     - ``0x00``
     - Same as |DATA_SEQ|, but does not need to be ACKed.

Cả hai loại khung ZZ0000ZZ- và ZZ0001ZZ đều được sử dụng để kiểm soát luồng tin nhắn và
do đó không mang tải trọng. Các khung loại ZZ0002ZZ- và ZZ0003ZZ trên
mặt khác phải mang tải trọng. Trình tự dòng chảy và sự tương tác của
các loại khung khác nhau sẽ được mô tả sâu hơn trong phần tiếp theo.


Giao thức gói SSH: Trình tự luồng
==================================

Mỗi trao đổi bắt đầu bằng ZZ0000ZZ, theo sau là ZZ0001ZZ- hoặc
Khung loại ZZ0002ZZ, tiếp theo là CRC, tải trọng và tải trọng CRC. trong
trường hợp khung loại ZZ0003ZZ, quá trình trao đổi sẽ kết thúc. Trong trường hợp một
Khung loại ZZ0004ZZ, bên nhận phải xác nhận đã nhận được
khung bằng cách phản hồi bằng thông báo chứa khung loại ZZ0005ZZ có
ID trình tự giống nhau của khung ZZ0006ZZ. Nói cách khác, ID trình tự của
khung ZZ0007ZZ chỉ định khung ZZ0008ZZ được xác nhận. Trong trường hợp một
lỗi, ví dụ: CRC không hợp lệ, bên nhận sẽ phản hồi bằng tin nhắn
chứa khung loại ZZ0009ZZ. Là ID trình tự của dữ liệu trước đó
khung có lỗi được chỉ định thông qua khung ZZ0010ZZ, không thể tin cậy được
khi đó, ID chuỗi của khung ZZ0011ZZ không được sử dụng và được đặt thành
không. Sau khi nhận được khung ZZ0012ZZ, bên gửi phải gửi lại tất cả
các tin nhắn chưa được xử lý (không được ACKed).

ID trình tự không được đồng bộ hóa giữa hai bên, nghĩa là chúng
được quản lý độc lập cho mỗi bên. Nhận dạng tin nhắn
tương ứng với một trao đổi duy nhất do đó dựa vào ID chuỗi cũng như
loại thông điệp và ngữ cảnh. Cụ thể, ID trình tự là
được sử dụng để liên kết ZZ0000ZZ với khung loại ZZ0001ZZ của nó, nhưng không
Các khung loại ZZ0002ZZ- hoặc ZZ0003ZZ với các khung loại ZZ0004ZZ khác.

Một ví dụ trao đổi có thể trông như thế này:

::

tx: -- SYN FRAME(D) CRC(F) PAYLOAD CRC(P) -----------------------------
    rx: ------------------------------------- SYN FRAME(A) CRC(F) CRC(P) --

trong đó cả hai khung có cùng ID chuỗi (ZZ0000ZZ). Đây, ZZ0001ZZ
biểu thị khung loại ZZ0006ZZ, ZZ0002ZZ khung loại ZZ0003ZZ,
ZZ0004ZZ CRC trên khung trước, ZZ0005ZZ CRC trên khung trước
tải trọng trước đó. Trong trường hợp có lỗi, quá trình trao đổi sẽ như thế này:

::

tx: -- SYN FRAME(D) CRC(F) PAYLOAD CRC(P) -----------------------------
    rx: ------------------------------------- SYN FRAME(N) CRC(F) CRC(P) --

theo đó người gửi sẽ gửi lại tin nhắn. ZZ0000ZZ biểu thị một
Khung kiểu ZZ0001ZZ. Lưu ý rằng ID trình tự của khung loại ZZ0002ZZ được cố định
về không. Đối với các khung loại ZZ0003ZZ, cả hai trao đổi đều giống nhau:

::

tx: -- SYN FRAME(DATA_NSQ) CRC(F) PAYLOAD CRC(P) ----------------------
    rx: -------------------------------------------------------------------

Ở đây, một lỗi có thể được phát hiện nhưng không được sửa chữa hoặc thông báo cho người dùng.
bên gửi. Các trao đổi này có tính đối xứng, tức là chuyển đổi ZZ0000ZZ và
ZZ0001ZZ lại cho kết quả trao đổi hợp lệ. Hiện tại không còn sàn giao dịch nào nữa
được biết đến.


Lệnh: Yêu cầu, Phản hồi và Sự kiện
=========================================

Các lệnh được gửi dưới dạng tải trọng bên trong khung dữ liệu. Hiện nay, đây là
loại tải trọng duy nhất được biết đến của các khung ZZ0002ZZ, với giá trị loại tải trọng là
ZZ0001ZZ (ZZ0000ZZ).

Tải trọng loại lệnh (ZZ0000ZZ)
bao gồm một cấu trúc lệnh 8 byte, theo sau là tùy chọn và
dữ liệu lệnh có độ dài thay đổi. Độ dài của dữ liệu tùy chọn này được lấy từ
từ độ dài tải trọng khung được đưa ra trong khung tương ứng, tức là
ZZ0001ZZ. Cấu trúc lệnh chứa
các trường sau đây, được đóng gói cùng nhau và theo thứ tự:

.. flat-table:: SSH Command
   :widths: 1 1 4
   :header-rows: 1

   * - Field
     - Type
     - Description

   * - |TYPE|
     - |u8|
     - Type of the payload. For commands always ``0x80``.

   * - |TC|
     - |u8|
     - Target category.

   * - |TID|
     - |u8|
     - Target ID for commands/messages.

   * - |SID|
     - |u8|
     - Source ID for commands/messages.

   * - |IID|
     - |u8|
     - Instance ID.

   * - |RQID|
     - |u16|
     - Request ID.

   * - |CID|
     - |u8|
     - Command ID.

Cấu trúc lệnh và dữ liệu nói chung không chứa bất kỳ lỗi nào
cơ chế phát hiện (ví dụ CRC), việc này chỉ được thực hiện ở cấp độ khung.

Tải trọng loại lệnh được máy chủ sử dụng để gửi lệnh và yêu cầu tới
EC cũng như EC gửi phản hồi và sự kiện về máy chủ.
Chúng tôi phân biệt giữa các yêu cầu (được gửi bởi máy chủ), các phản hồi (được gửi bởi máy chủ).
EC để đáp ứng yêu cầu) và các sự kiện (do EC gửi mà không có thông báo trước
yêu cầu).

Các lệnh và sự kiện được xác định duy nhất theo danh mục mục tiêu của chúng
(ZZ0000ZZ) và ID lệnh (ZZ0001ZZ). Danh mục mục tiêu chỉ định một mục tiêu chung
danh mục cho lệnh (ví dụ: hệ thống nói chung, so với pin và AC, so với.
nhiệt độ, v.v.), trong khi ID lệnh chỉ định lệnh bên trong
thể loại đó. Chỉ có sự kết hợp giữa ZZ0005ZZ + ZZ0006ZZ là duy nhất. Ngoài ra,
các lệnh có ID phiên bản (ZZ0002ZZ), được sử dụng để phân biệt
giữa các thiết bị phụ khác nhau. Ví dụ ZZ0003ZZ ZZ0004ZZ là một
yêu cầu lấy nhiệt độ trên cảm biến nhiệt, trong đó ZZ0007ZZ chỉ định
cảm biến tương ứng. Nếu ID cá thể không được sử dụng thì nó phải được đặt thành
không. Nếu sử dụng ID phiên bản thì nhìn chung chúng sẽ bắt đầu bằng giá trị là một,
trong khi số 0 có thể được sử dụng cho các truy vấn độc lập, nếu có. A
phản hồi cho một yêu cầu phải có cùng loại mục tiêu, ID lệnh và
ID cá thể làm yêu cầu tương ứng.

Các phản hồi được khớp với yêu cầu tương ứng của chúng thông qua ID yêu cầu
(ZZ0000ZZ). Đây là bộ đếm gói 16 bit tương tự như dãy
ID trên khung. Lưu ý rằng ID trình tự của các khung cho một
cặp yêu cầu-phản hồi không khớp. Chỉ có ID yêu cầu phải khớp.
Về mặt giao thức khung, đây là hai trao đổi riêng biệt và thậm chí có thể
tách ra, ví dụ: bởi một sự kiện được gửi sau yêu cầu nhưng trước
phản hồi. Không phải tất cả các lệnh đều tạo ra phản hồi và điều này không thể được phát hiện bởi
ZZ0002ZZ + ZZ0003ZZ. Trách nhiệm của bên phát hành là chờ đợi
phản hồi (hoặc báo hiệu điều này đến khung giao tiếp, như được thực hiện trong
SAN/ACPI thông qua cờ ZZ0001ZZ).

Các sự kiện được xác định bằng ID yêu cầu duy nhất và dành riêng. Những ID này nên
máy chủ không được sử dụng khi gửi yêu cầu mới. Chúng được sử dụng trên
lưu trữ để, trước tiên, phát hiện các sự kiện và, thứ hai, kết hợp chúng với một địa chỉ đã đăng ký
xử lý sự kiện. ID yêu cầu cho các sự kiện được chủ nhà chọn và chuyển đến
EC khi thiết lập và kích hoạt nguồn sự kiện (thông qua
yêu cầu kích hoạt-sự kiện-nguồn). EC sau đó sử dụng ID yêu cầu được chỉ định cho
các sự kiện được gửi từ nguồn tương ứng. Lưu ý rằng một sự kiện vẫn phải được
được xác định bởi danh mục mục tiêu, ID lệnh và, nếu có, phiên bản
ID, vì một nguồn sự kiện có thể gửi nhiều loại sự kiện khác nhau. trong
tuy nhiên, nói chung, một danh mục mục tiêu duy nhất sẽ ánh xạ tới một danh mục dành riêng
ID yêu cầu sự kiện.

Hơn nữa, các yêu cầu, phản hồi và sự kiện có ID mục tiêu liên quan
(ZZ0001ZZ) và ID nguồn (ZZ0002ZZ). Hai trường này cho biết vị trí của thông báo
bắt nguồn từ (ZZ0003ZZ) và mục tiêu dự định của tin nhắn là gì
(ZZ0004ZZ). Lưu ý rằng phản hồi cho một yêu cầu cụ thể do đó có nguồn
và ID mục tiêu được hoán đổi khi so sánh với yêu cầu ban đầu (tức là yêu cầu
target là nguồn phản hồi và nguồn yêu cầu là mục tiêu phản hồi).
Xem (ZZ0000ZZ) để biết các giá trị có thể có của
cả hai.

Lưu ý rằng, mặc dù các yêu cầu và sự kiện phải được nhận dạng duy nhất bởi
Chỉ riêng danh mục mục tiêu và ID lệnh, EC có thể yêu cầu ID mục tiêu cụ thể và
giá trị ID cá thể để chấp nhận lệnh. Một lệnh được chấp nhận cho
Ví dụ: ZZ0000ZZ có thể không được chấp nhận cho ZZ0001ZZ và ngược lại. Trong khi
điều này có thể không phải lúc nào cũng đúng trong thực tế, bạn có thể nghĩ đến mục tiêu/nguồn khác
ID cho biết các EC vật lý khác nhau với các bộ tính năng có thể khác nhau.


Hạn chế và quan sát
============================

Về mặt lý thuyết, giao thức có thể xử lý song song các khung ZZ0000ZZ,
với các yêu cầu đang chờ xử lý lên tới ZZ0001ZZ (bỏ qua ID yêu cầu dành riêng cho
sự kiện). Tuy nhiên, trên thực tế, điều này còn hạn chế hơn. Từ thử nghiệm của chúng tôi
(mặc dù thông qua python và do đó là chương trình không gian người dùng), có vẻ như EC
có thể xử lý song song tối đa bốn yêu cầu (hầu hết) một cách đáng tin cậy tại một thời điểm nhất định
thời gian. Với năm yêu cầu trở lên song song, việc loại bỏ nhất quán
các lệnh (khung ACK nhưng không có phản hồi lệnh) đã được quan sát. Trong năm
các lệnh đồng thời, điều này có thể lặp lại dẫn đến một lệnh được
bị loại bỏ và bốn lệnh đang được xử lý.

Tuy nhiên, cũng cần lưu ý rằng, ngay cả khi có ba yêu cầu song song,
tình trạng rớt khung hình thỉnh thoảng xảy ra. Ngoài ra, với giới hạn là ba
yêu cầu đang chờ xử lý, không có lệnh bị bỏ (tức là lệnh bị bỏ nhưng khung
mang lệnh được ACKed) đã được quan sát thấy. Trong mọi trường hợp, khung (và
cũng có thể là lệnh) sẽ được máy chủ gửi lại nếu hết thời gian chờ nhất định
bị vượt quá. Việc này được EC thực hiện đối với các khung có thời gian chờ là một giây,
tối đa hai lần thử lại (tức là tổng cộng ba lần truyền). Giới hạn của
việc thử lại cũng áp dụng cho các NAK đã nhận và trong trường hợp xấu nhất có thể
dẫn đến toàn bộ tin nhắn bị loại bỏ.

Mặc dù điều này dường như cũng hoạt động tốt đối với các khung dữ liệu đang chờ xử lý miễn là không
xảy ra lỗi truyền dẫn, việc thực hiện và xử lý những lỗi này dường như
phụ thuộc vào giả định rằng chỉ có một khung dữ liệu không được xác nhận.
Đặc biệt, việc phát hiện các khung lặp lại dựa vào chuỗi cuối cùng
số. Điều này có nghĩa là nếu một khung được nhận thành công bởi
EC được gửi lại, ví dụ: do máy chủ không nhận được ZZ0008ZZ, EC
sẽ chỉ phát hiện điều này nếu nó có ID chuỗi của khung cuối cùng nhận được
bởi EC. Ví dụ: Gửi hai khung với ZZ0000ZZ và ZZ0001ZZ
tiếp theo là sự lặp lại của ZZ0002ZZ sẽ không phát hiện được ZZ0003ZZ thứ hai
frame như vậy, và do đó thực thi lệnh trong khung này mỗi khi nó có
đã được nhận, tức là hai lần trong ví dụ này. Gửi ZZ0004ZZ, ZZ0005ZZ và
sau đó lặp lại ZZ0006ZZ sẽ phát hiện ZZ0007ZZ thứ hai là sự lặp lại của
cái đầu tiên và bỏ qua nó, do đó chỉ thực hiện lệnh được chứa một lần.

Tóm lại, điều này gợi ý giới hạn tối đa là một khung chưa được ACK đang chờ xử lý
(mỗi bên, dẫn đến việc trao đổi thông tin đồng bộ một cách hiệu quả về
khung) và tối đa ba lệnh đang chờ xử lý. Giới hạn khung đồng bộ
chuyển giao dường như phù hợp với hành vi được quan sát trên Windows.