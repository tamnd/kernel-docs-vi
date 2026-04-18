.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/openvswitch.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================
Mở tài liệu dành cho nhà phát triển đường dẫn dữ liệu vSwitch
=============================================================

Mô-đun hạt nhân Open vSwitch cho phép kiểm soát không gian người dùng linh hoạt
xử lý gói cấp luồng trên các thiết bị mạng được chọn.  Nó có thể
được sử dụng để thực hiện chuyển mạch Ethernet đơn giản, liên kết thiết bị mạng,
Xử lý VLAN, kiểm soát truy cập mạng, kiểm soát mạng dựa trên luồng,
và vân vân.

Mô-đun hạt nhân triển khai nhiều "đường dẫn dữ liệu" (tương tự như
bridge), mỗi cầu có thể có nhiều "vport" (tương tự như các cổng
trong một cây cầu).  Mỗi đường dẫn dữ liệu cũng được liên kết với nó một "luồng
table" mà không gian người dùng chứa "luồng" bản đồ đó từ các khóa dựa trên
trên tiêu đề gói và siêu dữ liệu cho các tập hợp hành động.  Phổ biến nhất
hành động chuyển tiếp gói đến một vport khác; các hành động khác cũng
được thực hiện.

Khi một gói đến vport, mô-đun hạt nhân sẽ xử lý nó bằng cách
trích xuất khóa luồng của nó và tra cứu nó trong bảng luồng.  Nếu có
là một luồng phù hợp, nó sẽ thực thi các hành động liên quan.  Nếu có
không khớp, nó xếp gói tin vào không gian người dùng để xử lý (như một phần của
quá trình xử lý của nó, không gian người dùng có thể sẽ thiết lập một luồng để xử lý thêm
các gói cùng loại hoàn toàn nằm trong kernel).


Khả năng tương thích của phím luồng
-----------------------------------

Các giao thức mạng phát triển theo thời gian.  Các giao thức mới trở nên quan trọng
và các giao thức hiện có mất đi sự nổi bật của chúng.  Đối với vSwitch mở
mô-đun hạt nhân vẫn phù hợp thì các mô-đun hạt nhân mới hơn phải có khả năng thực hiện được
các phiên bản để phân tích các giao thức bổ sung như một phần của khóa luồng.  Nó
thậm chí có thể được mong muốn, một ngày nào đó, bỏ hỗ trợ phân tích cú pháp
các giao thức đã trở nên lỗi thời.  Vì vậy, giao diện Netlink
to Open vSwitch được thiết kế để cho phép không gian người dùng được viết cẩn thận
các ứng dụng hoạt động với bất kỳ phiên bản nào của khóa luồng, quá khứ hoặc tương lai.

Để hỗ trợ khả năng tương thích tiến và lùi này, bất cứ khi nào
mô-đun hạt nhân chuyển một gói đến không gian người dùng, nó cũng chuyển theo
khóa luồng mà nó phân tích từ gói.  Không gian người dùng sau đó trích xuất nó
khái niệm riêng về khóa luồng từ gói và so sánh nó với
phiên bản do kernel cung cấp:

- Nếu khái niệm của không gian người dùng về khóa luồng cho gói khớp với
      kernel thì không cần gì đặc biệt cả.

- Nếu khóa luồng của kernel bao gồm nhiều trường hơn không gian người dùng
      phiên bản của khóa luồng, ví dụ: nếu kernel đã giải mã IPv6
      tiêu đề nhưng không gian người dùng đã dừng ở loại Ethernet (vì nó
      không hiểu IPv6), thì cũng không có gì đặc biệt cả
      cần thiết.  Không gian người dùng vẫn có thể thiết lập luồng theo cách thông thường,
      miễn là nó sử dụng khóa luồng do kernel cung cấp để thực hiện.

- Nếu khóa luồng không gian người dùng bao gồm nhiều trường hơn khóa
      kernel, chẳng hạn nếu không gian người dùng giải mã tiêu đề IPv6 nhưng
      hạt nhân dừng ở loại Ethernet thì không gian người dùng có thể
      chuyển tiếp gói theo cách thủ công mà không cần thiết lập luồng trong
      hạt nhân.  Trường hợp này không tốt cho hiệu suất vì mọi gói
      mà kernel coi là một phần của luồng phải đi tới không gian người dùng,
      nhưng hành vi chuyển tiếp là chính xác.  (Nếu không gian người dùng có thể
      xác định rằng giá trị của các trường bổ sung sẽ không ảnh hưởng
      hành vi chuyển tiếp thì dù sao nó cũng có thể thiết lập một luồng.)

Cách các khóa luồng phát triển theo thời gian là điều quan trọng để thực hiện công việc này, vì vậy
các phần sau đây đi vào chi tiết.


Định dạng khóa luồng
--------------------

Khóa luồng được truyền qua ổ cắm Netlink dưới dạng một chuỗi Netlink
thuộc tính.  Một số thuộc tính đại diện cho siêu dữ liệu gói, được định nghĩa là bất kỳ
thông tin về một gói không thể trích xuất được từ gói
chính nó, ví dụ vport mà gói tin được nhận.  Hầu hết
Tuy nhiên, các thuộc tính được trích xuất từ các tiêu đề trong gói,
ví dụ: địa chỉ nguồn và đích từ Ethernet, IP hoặc TCP
tiêu đề.

Tệp tiêu đề <linux/openvswitch.h> xác định định dạng chính xác của
thuộc tính khóa luồng.  Với mục đích giải thích không chính thức ở đây, chúng tôi viết
chúng dưới dạng các chuỗi được phân tách bằng dấu phẩy, có dấu ngoặc đơn biểu thị các đối số
và làm tổ.  Ví dụ: phần sau đây có thể đại diện cho khóa luồng
tương ứng với gói TCP đến trên vport 1::

in_port(1), eth(src=e0:91:f5:21:d0:b2, dst=00:02:e3:0f:80:a4),
    eth_type(0x0800), ipv4(src=172.16.0.20, dst=172.18.0.52, proto=17, tos=0,
    frag=no), tcp(src=49163, dst=80)

Thông thường, chúng tôi gạch bỏ các lập luận không quan trọng đối với cuộc thảo luận, ví dụ:::

in_port(1), eth(...), eth_type(0x0800), ipv4(...), tcp(...)


Định dạng khóa luồng ký tự đại diện
-----------------------------------

Luồng ký tự đại diện được mô tả bằng hai chuỗi thuộc tính Netlink
được chuyển qua ổ cắm Netlink. Một khóa luồng, chính xác như được mô tả ở trên, và một
mặt nạ dòng tương ứng tùy chọn.

Luồng ký tự đại diện có thể đại diện cho một nhóm luồng khớp chính xác. Mỗi bit '1'
trong mặt nạ chỉ định khớp chính xác với bit tương ứng trong khóa luồng.
Bit '0' chỉ định bit không quan tâm, bit này sẽ khớp với bit '1' hoặc '0'
của một gói tin đến. Việc sử dụng luồng ký tự đại diện có thể cải thiện tốc độ thiết lập luồng
bằng cách giảm số lượng luồng mới cần được xử lý bởi chương trình không gian người dùng.

Hỗ trợ cho thuộc tính mặt nạ Netlink là tùy chọn cho cả kernel và người dùng
chương trình không gian. Hạt nhân có thể bỏ qua thuộc tính mặt nạ, cài đặt chính xác
khớp luồng hoặc giảm số lượng bit không quan tâm trong kernel xuống ít hơn
những gì đã được chỉ định bởi chương trình không gian người dùng. Trong trường hợp này, các biến thể về bit
mà kernel không triển khai sẽ chỉ dẫn đến việc thiết lập luồng bổ sung.
Mô-đun hạt nhân cũng sẽ hoạt động với các chương trình không gian người dùng không hỗ trợ
cũng không cung cấp các thuộc tính mặt nạ luồng.

Vì hạt nhân có thể bỏ qua hoặc sửa đổi các bit ký tự đại diện nên có thể khó khăn cho
chương trình không gian người dùng để biết chính xác những gì phù hợp được cài đặt. có
hai cách tiếp cận khả thi: các luồng cài đặt phản ứng khi chúng thiếu kernel
bảng luồng (và do đó không cố gắng xác định các thay đổi ký tự đại diện)
hoặc sử dụng thông báo phản hồi của kernel để xác định các ký tự đại diện đã cài đặt.

Khi tương tác với không gian người dùng, kernel phải duy trì phần khớp
của khóa chính xác như được cài đặt ban đầu. Điều này sẽ cung cấp một xử lý để
xác định luồng cho tất cả các hoạt động trong tương lai. Tuy nhiên, khi báo cáo các
mặt nạ của luồng đã cài đặt, mặt nạ phải bao gồm mọi hạn chế được áp đặt
bởi hạt nhân.

Hành vi khi sử dụng các luồng ký tự đại diện chồng chéo là không xác định. Đó là
trách nhiệm của chương trình không gian người dùng để đảm bảo rằng mọi gói tin đến
có thể khớp nhiều nhất với một luồng, có ký tự đại diện hay không. Việc thực hiện hiện tại
thực hiện phát hiện nỗ lực tốt nhất các luồng ký tự đại diện chồng chéo và có thể từ chối
một số nhưng không phải tất cả trong số họ. Tuy nhiên, hành vi này có thể thay đổi trong các phiên bản sau.


Mã định danh luồng duy nhất
---------------------------

Một cách thay thế cho việc sử dụng phần khớp ban đầu của khóa làm tay cầm cho
nhận dạng luồng là mã định danh luồng duy nhất hoặc "UFID". UFID là tùy chọn
cho cả chương trình kernel và không gian người dùng.

Các chương trình không gian người dùng hỗ trợ UFID dự kiến sẽ cung cấp nó trong quá trình truyền tải
thiết lập ngoài quy trình, sau đó tham khảo quy trình bằng UFID cho tất cả
hoạt động trong tương lai. Hạt nhân không bắt buộc phải lập chỉ mục các luồng theo bản gốc
phím luồng nếu UFID được chỉ định.


Quy tắc cơ bản để phát triển các khóa luồng
-------------------------------------------

Cần phải cẩn thận để thực sự duy trì tiến và lùi
khả năng tương thích cho các ứng dụng tuân theo các quy tắc được liệt kê bên dưới
"Khả năng tương thích của khóa luồng" ở trên.

Nguyên tắc cơ bản là hiển nhiên::

=======================================================================
    Hỗ trợ giao thức mạng mới chỉ phải bổ sung cho luồng hiện có
    các thuộc tính quan trọng.  Nó không được thay đổi ý nghĩa của đã được xác định
    thuộc tính khóa luồng.
    =======================================================================

Quy tắc này có những hậu quả ít rõ ràng hơn nên nó đáng để thực hiện
qua một số ví dụ.  Ví dụ, giả sử rằng mô-đun hạt nhân
chưa triển khai phân tích cú pháp VLAN.  Thay vào đó, nó chỉ diễn giải
802.1Q TPID (0x8100) làm Ethertype sau đó đã ngừng phân tích cú pháp
gói.  Khóa luồng cho bất kỳ gói nào có tiêu đề 802.1Q sẽ trông giống như
về cơ bản là như thế này, bỏ qua siêu dữ liệu ::

eth(...), eth_type(0x8100)

Ngây thơ, để thêm hỗ trợ VLAN, việc thêm luồng "vlan" mới là điều hợp lý
thuộc tính khóa để chứa thẻ VLAN, sau đó tiếp tục giải mã
các tiêu đề được đóng gói ngoài thẻ VLAN bằng cách sử dụng trường hiện có
các định nghĩa.  Với thay đổi này, gói TCP trong VLAN 10 sẽ có
phím luồng giống như thế này::

eth(...), vlan(vid=10, pcp=0), eth_type(0x0800), ip(proto=6, ...), tcp(...)

Nhưng thay đổi này sẽ ảnh hưởng tiêu cực đến ứng dụng không gian người dùng
chưa được cập nhật để hiểu thuộc tính khóa luồng "vlan" mới.
Ứng dụng có thể, tuân theo các quy tắc tương thích luồng ở trên,
bỏ qua thuộc tính "vlan" mà nó không hiểu và do đó
giả định rằng luồng chứa các gói IP.  Đây là một giả định tồi
(luồng chỉ chứa các gói IP nếu phân tích cú pháp và bỏ qua
802.1Q) và nó có thể khiến hoạt động của ứng dụng thay đổi
trên các phiên bản kernel mặc dù nó tuân theo các quy tắc tương thích.

Giải pháp là sử dụng một tập hợp các thuộc tính lồng nhau.  Đây là, đối với
ví dụ: tại sao hỗ trợ 802.1Q lại sử dụng các thuộc tính lồng nhau.  Một gói TCP trong
VLAN 10 thực tế được thể hiện dưới dạng::

eth(...), eth_type(0x8100), vlan(vid=10, pcp=0), encap(eth_type(0x0800),
    ip(proto=6, ...), tcp(...)))

Lưu ý cách các thuộc tính khóa luồng "eth_type", "ip" và "tcp"
được lồng bên trong thuộc tính "encap".  Vì vậy, một ứng dụng thực hiện
không hiểu phím "vlan" sẽ không thấy một trong các thuộc tính đó
và do đó sẽ không hiểu sai chúng.  (Ngoài ra, eth_type bên ngoài
vẫn là 0x8100, không đổi thành 0x0800.)

Xử lý các gói không đúng định dạng
----------------------------------

Đừng bỏ các gói trong kernel vì các tiêu đề giao thức không đúng định dạng, xấu
tổng kiểm tra, v.v. Điều này sẽ ngăn không gian người dùng triển khai
chuyển mạch Ethernet đơn giản chuyển tiếp mọi gói tin.

Thay vào đó, trong trường hợp như vậy, hãy bao gồm một thuộc tính có nội dung "trống".
Sẽ không có vấn đề gì nếu nội dung trống có thể là các giá trị giao thức hợp lệ,
miễn là những giá trị đó hiếm khi được thấy trong thực tế, bởi vì không gian người dùng
luôn có thể chuyển tiếp tất cả các gói có giá trị đó tới không gian người dùng và
xử lý chúng một cách riêng lẻ.

Ví dụ: hãy xem xét một gói chứa tiêu đề IP
biểu thị giao thức 6 cho TCP, nhưng bị cắt bớt ngay sau IP
tiêu đề, do đó tiêu đề TCP bị thiếu.  Chìa khóa quy trình cho việc này
gói sẽ bao gồm một thuộc tính tcp với src và dst hoàn toàn bằng 0, như
cái này::

eth(...), eth_type(0x0800), ip(proto=6, ...), tcp(src=0, dst=0)

Một ví dụ khác, hãy xem xét gói có loại Ethernet là 0x8100,
chỉ ra rằng VLAN TCI sẽ tuân theo, nhưng nó chỉ bị cắt bớt
sau loại Ethernet.  Khóa luồng cho gói này sẽ bao gồm
một vlan hoàn toàn bằng 0 bit và thuộc tính encap trống, như thế này ::

eth(...), eth_type(0x8100), vlan(0), encap()

Không giống như gói TCP có cổng nguồn và cổng đích 0, gói
VLAN TCI toàn số 0 không phải là hiếm, vì vậy bit CFI (còn gọi là
VLAN_TAG_PRESENT bên trong kernel) thường được đặt trong vlan
thuộc tính rõ ràng để cho phép phân biệt tình huống này.
Do đó, khóa luồng trong ví dụ thứ hai này chỉ ra rõ ràng một
VLAN TCI bị thiếu hoặc không đúng định dạng.

Các quy tắc khác
----------------

Các quy tắc khác cho khóa luồng ít tinh tế hơn nhiều:

- Các thuộc tính trùng lặp không được phép ở cấp độ lồng nhau nhất định.

- Thứ tự các thuộc tính không đáng kể.

- Khi hạt nhân gửi một khóa luồng nhất định tới không gian người dùng, nó luôn
      soạn nó theo cùng một cách.  Điều này cho phép không gian người dùng băm và
      so sánh toàn bộ các khóa luồng mà nó có thể không thể thực hiện đầy đủ
      giải thích.