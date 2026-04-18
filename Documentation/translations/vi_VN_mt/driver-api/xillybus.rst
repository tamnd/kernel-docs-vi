.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/xillybus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Trình điều khiển Xillybus cho giao diện FPGA chung
==================================================

:Tác giả: Eli Billauer, Xillybus Ltd. (ZZ0000ZZ
:Email: eli.billauer@gmail.com hoặc như được quảng cáo trên trang Xillybus.

.. Contents:

 - Introduction
  -- Background
  -- Xillybus Overview

 - Usage
  -- User interface
  -- Synchronization
  -- Seekable pipes

 - Internals
  -- Source code organization
  -- Pipe attributes
  -- Host never reads from the FPGA
  -- Channels, pipes, and the message channel
  -- Data streaming
  -- Data granularity
  -- Probing
  -- Buffer allocation
  -- The "nonempty" message (supporting poll)


Giới thiệu
============

Lý lịch
----------

FPGA (Mảng cổng lập trình trường) là một phần cứng logic,
có thể được lập trình để trở thành hầu như bất cứ thứ gì thường được tìm thấy dưới dạng
chipset chuyên dụng: Ví dụ: bộ điều hợp hiển thị, thẻ giao diện mạng,
hoặc thậm chí một bộ xử lý với các thiết bị ngoại vi của nó. FPGA là LEGO của phần cứng:
Dựa trên những khối xây dựng nhất định, bạn có thể tự làm đồ chơi theo cách mình thích
họ. Thông thường việc thực hiện lại một cái gì đó đã có sẵn là vô nghĩa.
có sẵn trên thị trường dưới dạng chipset, vì vậy FPGA chủ yếu được sử dụng khi một số
cần có chức năng đặc biệt và khối lượng sản xuất tương đối thấp
(do đó không biện minh cho sự phát triển của ASIC).

Thách thức với FPGA là mọi thứ được thực hiện ở tốc độ rất thấp.
cấp độ, thậm chí còn thấp hơn cả hợp ngữ. Để cho phép các nhà thiết kế FPGA
tập trung vào dự án cụ thể của họ và không phát minh đi phát minh lại bánh xe
một lần nữa, các khối xây dựng được thiết kế sẵn, lõi IP, thường được sử dụng. Đây là những
FPGA tương đương với các chức năng thư viện. Lõi IP có thể triển khai một số
các hàm toán học, một đơn vị chức năng (ví dụ: giao diện USB), toàn bộ
bộ xử lý (ví dụ: ARM) hoặc bất cứ thứ gì có thể hữu ích. Hãy nghĩ về họ như một
khối xây dựng, có dây điện lủng lẳng ở hai bên để kết nối với
các khối khác.

Một trong những nhiệm vụ khó khăn trong thiết kế FPGA là giao tiếp với toàn bộ
hệ điều hành (thực ra là với bộ xử lý đang chạy nó): Triển khai
giao thức bus cấp thấp và giao diện cấp cao hơn một chút với máy chủ
(thanh ghi, ngắt, DMA, v.v.) bản thân nó là một dự án. Khi FPGA
là một chức năng phổ biến (ví dụ: thẻ bộ điều hợp video hoặc NIC), nó có thể
nên thiết kế logic giao diện của FPGA dành riêng cho dự án.
Sau đó, một trình điều khiển đặc biệt được viết để hiển thị FPGA như một giao diện nổi tiếng
vào kernel và/hoặc không gian người dùng. Trong trường hợp đó, không có lý do gì để điều trị
FPGA khác biệt so với bất kỳ thiết bị nào trên xe buýt.

Tuy nhiên, điều phổ biến là việc giao tiếp dữ liệu mong muốn không phù hợp chút nào-
chức năng ngoại vi đã biết. Ngoài ra, nỗ lực thiết kế một vẻ ngoài trang nhã
sự trừu tượng hóa cho việc trao đổi dữ liệu thường được coi là quá lớn. Trong những trường hợp đó,
một giải pháp nhanh hơn và có thể kém tinh tế hơn được tìm kiếm: Người lái xe
được viết một cách hiệu quả như một chương trình không gian người dùng, để lại phần không gian kernel
chỉ với việc vận chuyển dữ liệu cơ bản. Điều này vẫn đòi hỏi phải thiết kế một số
logic giao diện cho FPGA và viết trình điều khiển đặc biệt đơn giản cho kernel.

Tổng quan về Xillybus
-----------------

Xillybus là lõi IP và trình điều khiển Linux. Cùng nhau, chúng tạo thành một bộ dành cho
truyền tải dữ liệu cơ bản giữa FPGA và máy chủ, cung cấp dịch vụ giống như đường ống
luồng dữ liệu với giao diện người dùng đơn giản. Nó được dự định là thấp-
giải pháp nỗ lực cho các dự án máy chủ FPGA hỗn hợp, điều này rất hợp lý
có phần trình điều khiển dành riêng cho dự án đang chạy trong chương trình không gian người dùng.

Vì các yêu cầu liên lạc có thể thay đổi đáng kể so với một FPGA
dự án khác (số lượng ống dữ liệu cần thiết theo từng hướng và
thuộc tính của chúng), không có một đoạn logic cụ thể nào là Xillybus
lõi IP. Đúng hơn, lõi IP được cấu hình và xây dựng dựa trên một
đặc điểm kỹ thuật được đưa ra bởi người dùng cuối của nó.

Xillybus trình bày các luồng dữ liệu độc lập, giống với các đường ống hoặc TCP/IP
giao tiếp tới người dùng. Ở phía máy chủ, một tệp thiết bị ký tự được sử dụng
giống như bất kỳ tập tin đường ống nào. Về phía FPGA, FIFO phần cứng được sử dụng để truyền phát
dữ liệu. Điều này trái với phương thức liên lạc thông thường thông qua mạng cố định.
bộ đệm có kích thước (mặc dù bộ đệm như vậy được Xillybus sử dụng dưới mui xe).
Có thể có hơn một trăm luồng như vậy trên một lõi IP, nhưng
cũng không nhiều hơn một, tùy thuộc vào cấu hình.

Để dễ dàng triển khai lõi IP Xillybus, nó chứa một
cấu trúc dữ liệu xác định hoàn toàn cấu hình của lõi. Linux
trình điều khiển tìm nạp cấu trúc dữ liệu này trong quá trình khởi tạo và đặt
nâng cấp bộ đệm DMA và thiết bị ký tự tương ứng. Kết quả là, một đơn
trình điều khiển được sử dụng để hoạt động ngay lập tức với bất kỳ lõi IP Xillybus nào.

Không nên nhầm lẫn cấu trúc dữ liệu vừa đề cập với cấu trúc dữ liệu của PCI
không gian cấu hình hoặc Cây thiết bị phẳng.

Cách sử dụng
=====

Giao diện người dùng
--------------

Trên máy chủ, tất cả giao diện với Xillybus được thực hiện thông qua /dev/xillybus_*
các tập tin thiết bị, được tạo tự động khi tải trình điều khiển. các
tên của các tệp này phụ thuộc vào lõi IP được tải trong FPGA (xem
Thăm dò bên dưới). Để giao tiếp với FPGA, hãy mở tệp thiết bị
tương ứng với phần cứng FIFO mà bạn muốn gửi dữ liệu hoặc nhận dữ liệu từ đó,
và sử dụng các lệnh gọi write() hoặc read() đơn giản, giống như với một đường ống thông thường. trong
đặc biệt, sẽ rất hợp lý khi đi::

$ cat mydata > /dev/xillybus_thisfifo

$ cat /dev/xillybus_thatfifo > dữ liệu của anh ấy

có thể nhấn CTRL-C như một giai đoạn nào đó, mặc dù các ống xillybus_* có
khả năng gửi EOF (nhưng không thể sử dụng nó).

Trình điều khiển và phần cứng được thiết kế để hoạt động hợp lý như các đường ống, bao gồm:

* Hỗ trợ I/O không chặn (bằng cách đặt O_NONBLOCK trên open() ).

* Hỗ trợ poll() và select().

* Băng thông hiệu quả khi tải (sử dụng DMA) nhưng cũng có thể xử lý các băng thông nhỏ
  các phần dữ liệu được gửi qua (như TCP/IP) bằng cách tự động xóa.

Một tập tin thiết bị có thể chỉ đọc, chỉ ghi hoặc hai chiều. hai chiều
các tập tin thiết bị được xử lý như hai đường ống độc lập (ngoại trừ việc chia sẻ một
cấu trúc "kênh" trong mã triển khai).

Đồng bộ hóa
---------------

Các ống Xillybus được cấu hình (trên lõi IP) ở chế độ đồng bộ hoặc
không đồng bộ. Đối với một đường dẫn đồng bộ, write() chỉ trả về thành công sau
một số dữ liệu đã được FPGA gửi và xác nhận. Điều này làm chậm lại
truyền dữ liệu số lượng lớn và gần như không thể sử dụng được với các luồng
yêu cầu dữ liệu ở tốc độ không đổi: Không có dữ liệu nào được truyền tới FPGA
giữa các cuộc gọi write(), đặc biệt khi quá trình mất CPU.

Khi một đường ống được cấu hình không đồng bộ, write() sẽ trả về nếu có đủ
chỗ trong bộ đệm để lưu trữ bất kỳ dữ liệu nào trong bộ đệm.

Để FPGA lưu trữ các đường ống, các đường ống không đồng bộ cho phép truyền dữ liệu từ FPGA
ngay khi tệp thiết bị tương ứng được mở, bất kể dữ liệu có
đã được yêu cầu bởi lệnh gọi read(). Trên các đường ống đồng bộ, chỉ có lượng
dữ liệu được yêu cầu bởi lệnh gọi read() sẽ được truyền đi.

Tóm lại, đối với các đường ống đồng bộ, dữ liệu giữa máy chủ và FPGA là
chỉ được truyền để đáp ứng lệnh gọi read() hoặc write() hiện đang được xử lý
bởi người lái xe và những cuộc gọi đó sẽ đợi quá trình truyền hoàn tất trước khi
đang quay trở lại.

Lưu ý rằng thuộc tính đồng bộ hóa không liên quan gì đến khả năng
read() hoặc write() hoàn thành ít byte hơn yêu cầu. có một
cờ cấu hình riêng biệt ("allowpartial") xác định liệu một phần như vậy có
được phép hoàn thành một phần.

Ống có thể tìm kiếm
--------------

Một đường ống đồng bộ có thể được cấu hình để hiển thị vị trí của luồng
tới logic người dùng tại FPGA. Một đường ống như vậy cũng có thể được tìm kiếm trên máy chủ API.
Với tính năng này, giao diện bộ nhớ hoặc thanh ghi có thể được gắn vào
FPGA bên cạnh luồng có thể tìm kiếm. Đọc hoặc viết tới một địa chỉ nhất định trong
bộ nhớ đính kèm được thực hiện bằng cách tìm kiếm địa chỉ mong muốn và gọi
read() hoặc write() theo yêu cầu.


Nội bộ
=========

Tổ chức mã nguồn
------------------------

Trình điều khiển Xillybus bao gồm một mô-đun lõi, xillybus_core.c và các mô-đun
phụ thuộc vào giao diện bus cụ thể (xillybus_of.c và xillybus_pcie.c).

Các mô-đun cụ thể của xe buýt là những mô-đun được thăm dò khi tìm thấy thiết bị phù hợp bởi
hạt nhân. Do chức năng ánh xạ và đồng bộ hóa DMA là bus
phụ thuộc vào bản chất của chúng, được sử dụng bởi mô-đun lõi, một
Cấu trúc xilly_endpoint_hardware được chuyển tới mô-đun lõi trên
khởi tạo. Cấu trúc này được điền với các con trỏ tới các hàm bao bọc
thực hiện các hoạt động liên quan đến DMA trên xe buýt.

Thuộc tính ống
---------------

Mỗi ống có một số thuộc tính được đặt khi thành phần FPGA
(Lõi IP) được xây dựng. Chúng được lấy từ IDT (cấu trúc dữ liệu
xác định cấu hình của lõi, xem Thăm dò bên dưới) bởi xilly_setupchannels()
trong xillybus_core.c như sau:

* is_writebuf: Hướng của đường ống. Giá trị khác 0 có nghĩa là FPGA
  ống chủ (FPGA "ghi").

*channelnum: Số nhận dạng của đường ống trong giao tiếp giữa
  máy chủ và FPGA.

* định dạng: Độ rộng dữ liệu cơ bản. Xem mức độ chi tiết của dữ liệu bên dưới.

* allowpartial: Giá trị khác 0 có nghĩa là read() hoặc write() (tùy theo giá trị nào
  áp dụng) có thể trả về với số byte ít hơn số byte được yêu cầu. Cái chung
  lựa chọn là giá trị khác 0, để phù hợp với hành vi UNIX tiêu chuẩn.

* đồng bộ: Giá trị khác 0 có nghĩa là đường ống đồng bộ. Xem
  Đồng bộ hóa ở trên.

* bufsize: Kích thước của mỗi bộ đệm DMA. Luôn là sức mạnh của hai.

* bufnum: Số lượng bộ đệm được phân bổ cho pipe này. Luôn là sức mạnh của hai.

* Exclusive_open: Giá trị khác 0 buộc phải mở độc quyền của liên kết
  tập tin thiết bị. Nếu tệp thiết bị là hai chiều và chỉ được mở trong
  một hướng, hướng ngược lại có thể được mở một lần.

* có thể tìm kiếm: Giá trị khác 0 cho biết đường ống có thể tìm kiếm được. Xem
  Có thể tìm kiếm các đường ống ở trên.

* hỗ trợ_nonempty: Giá trị khác 0 (điển hình) cho biết rằng
  phần cứng sẽ gửi các thông báo cần thiết để hỗ trợ select() và
  poll() cho đường ống này.

Máy chủ không bao giờ đọc từ FPGA
------------------------------

Mặc dù PCI Express nói chung có khả năng cắm nóng, nhưng một bo mạch chủ điển hình
không mong đợi một tấm thẻ sẽ biến mất đột ngột. Nhưng vì thẻ PCIe
dựa trên logic có thể lập trình lại, sự biến mất đột ngột khỏi xe buýt là
rất có thể là do việc lập trình lại FPGA một cách tình cờ trong khi
máy chủ đang hoạt động. Trong thực tế, không có gì xảy ra ngay lập tức trong tình huống như vậy. Nhưng
nếu máy chủ cố đọc từ một địa chỉ được ánh xạ tới PCI Express
thiết bị, dẫn đến tình trạng đóng băng ngay lập tức hệ thống trên một số bo mạch chủ,
mặc dù tiêu chuẩn PCIe yêu cầu sự phục hồi nhẹ nhàng.

Để tránh tình trạng đóng băng này, người lái xe Xillybus hoàn toàn hạn chế
đọc từ không gian đăng ký của thiết bị. Tất cả thông tin liên lạc từ FPGA đến
máy chủ được thực hiện thông qua DMA. Đặc biệt, Quy trình dịch vụ ngắt
không tuân theo thông lệ chung là kiểm tra sổ đăng ký trạng thái khi nó
được gọi. Đúng hơn, FPGA chuẩn bị một bộ đệm nhỏ chứa các
thông báo cho máy chủ biết sự gián đoạn là gì.

Cơ chế này cũng được sử dụng trên các bus không phải PCIe vì mục đích đồng nhất.


Kênh, đường ống và kênh tin nhắn
----------------------------------------

Mỗi ống (có thể là hai chiều) được trình bày cho người dùng được phân bổ
kênh dữ liệu giữa FPGA và máy chủ. Sự khác biệt giữa các kênh
và các đường ống chỉ cần thiết vì kênh 0, được sử dụng để ngắt
các tin nhắn liên quan từ FPGA và không có đường ống nào gắn vào nó.

Truyền dữ liệu
--------------

Mặc dù luồng dữ liệu không được phân đoạn được hiển thị cho người dùng ở cả hai
mặt khác, việc triển khai dựa trên một bộ bộ đệm DMA được phân bổ
cho mỗi kênh. Để minh họa chúng ta hãy lấy FPGA làm hosting
hướng: Khi dữ liệu truyền vào giao diện của kênh tương ứng trong
FPGA, lõi IP Xillybus ghi nó vào một trong các bộ đệm DMA. Khi
bộ đệm đã đầy, FPGA sẽ thông báo cho máy chủ về điều đó (thêm một
XILLYMSG_OPCODE_RELEASEBUF gửi tin nhắn kênh 0 và gửi ngắt nếu
cần thiết). Máy chủ phản hồi bằng cách cung cấp dữ liệu để đọc qua
thiết bị nhân vật. Khi tất cả dữ liệu đã được đọc, máy chủ sẽ ghi vào
Thanh ghi điều khiển bộ đệm của FPGA, cho phép ghi đè bộ đệm. Dòng chảy
cơ chế kiểm soát tồn tại ở cả hai bên để chống tràn và tràn.

Điều này không đủ tốt để tạo luồng giống TCP/IP: Nếu luồng dữ liệu
dừng lại trong giây lát trước khi bộ đệm DMA được lấp đầy, kỳ vọng trực quan là
rằng một phần dữ liệu trong bộ đệm sẽ đến dù thế nào đi nữa, mặc dù bộ đệm không
đang được hoàn thành. Điều này được thực hiện bằng cách thêm một trường vào
Tin nhắn XILLYMSG_OPCODE_RELEASEBUF, qua đó FPGA không chỉ thông báo
bộ đệm nào được gửi, nhưng nó chứa bao nhiêu dữ liệu.

Nhưng FPGA sẽ chỉ gửi bộ đệm được lấp đầy một phần nếu được hướng dẫn làm như vậy
bởi chủ nhà. Tình huống này xảy ra khi phương thức read() bị chặn
đối với các khoảng thời gian ngắn của XILLY_RX_TIMEOUT (hiện tại là 10 ms), sau đó máy chủ ra lệnh
FPGA để gửi bộ đệm DMA ngay khi có thể. Cơ chế hết thời gian này
cân bằng giữa hiệu quả băng thông bus (ngăn chặn nhiều sự cố một phần
bộ đệm đã được điền sẽ được gửi) và độ trễ được giữ ở mức khá thấp đối với các phần cuối của dữ liệu.

Cài đặt tương tự được sử dụng trong máy chủ theo hướng FPGA. Việc xử lý
Tuy nhiên, bộ đệm DMA một phần có phần khác biệt. Người dùng có thể cho biết
trình điều khiển gửi tất cả dữ liệu có trong bộ đệm tới FPGA, bằng cách đưa ra một lệnh
write() với số byte được đặt thành 0. Điều này tương tự như một yêu cầu tuôn ra,
nhưng nó không chặn. Ngoài ra còn có một cơ chế tự động xả, kích hoạt
một lần xả tương đương xảy ra khoảng XILLY_RX_TIMEOUT sau lần ghi() cuối cùng.
Điều này cho phép người dùng không biết gì về cơ chế đệm cơ bản
nhưng vẫn tận hưởng giao diện giống như luồng.

Lưu ý rằng vấn đề xả bộ đệm một phần không liên quan đến các đường ống có
thuộc tính "đồng bộ" khác 0, vì các đường dẫn đồng bộ không cho phép dữ liệu
dù sao đi nữa, hãy đặt xung quanh bộ đệm DMA giữa read() và write().

Độ chi tiết của dữ liệu
----------------

Dữ liệu đến hoặc được gửi tại FPGA dưới dạng các từ có độ rộng 8, 16 hoặc 32 bit, như
được cấu hình bởi thuộc tính "format". Bất cứ khi nào có thể, người lái xe cố gắng
để ẩn điều này khi đường ống được truy cập khác với cách căn chỉnh tự nhiên của nó.
Ví dụ: đọc các byte đơn từ một đường ống có độ chi tiết 32 bit hoạt động
không có vấn đề gì Ghi các byte đơn vào các đường ống có độ chi tiết 16 hoặc 32 bit
cũng sẽ hoạt động, nhưng trình điều khiển không thể gửi các từ đã hoàn thành một phần tới
FPGA, do đó việc truyền tối đa một từ có thể được giữ lại cho đến khi hoàn thành
bị chiếm giữ với dữ liệu người dùng.

Điều này phần nào làm phức tạp việc xử lý máy chủ đối với các luồng FPGA, bởi vì
khi bộ đệm bị xóa, nó có thể chứa tối đa 3 byte, không tạo thành một từ trong
FPGA và do đó không thể gửi được. Để tránh mất dữ liệu, những dữ liệu còn sót lại này
byte cần được chuyển sang bộ đệm tiếp theo. Các bộ phận trong xillybus_core.c
việc đề cập đến "thức ăn thừa" theo một cách nào đó có liên quan đến sự phức tạp này.

Để thăm dò
-------

Như đã đề cập trước đó, số lượng ống được tạo ra khi trình điều khiển
tải và thuộc tính của chúng phụ thuộc vào lõi IP Xillybus trong FPGA. Trong thời gian
quá trình khởi tạo của trình điều khiển, một đốm màu chứa thông tin cấu hình,
Bảng mô tả giao diện (IDT), được gửi từ FPGA đến máy chủ. các
Quá trình bootstrap được thực hiện theo ba giai đoạn:

1. Lấy chiều dài của IDT để có thể phân bổ bộ đệm cho nó. Cái này
   được thực hiện bằng cách gửi lệnh dừng tới thiết bị, vì xác nhận
   đối với lệnh này chứa độ dài bộ đệm của IDT.

2. Nhận chính IDT.

3. Tạo giao diện theo IDT.

Phân bổ bộ đệm
-----------------

Để đơn giản hóa logic ngăn chặn việc vượt biên trái phép
Với các gói PCIe, quy tắc sau sẽ được áp dụng: Nếu bộ đệm nhỏ hơn 4kB,
nó không được vượt qua ranh giới 4kB. Nếu không, nó phải được căn chỉnh 4kB. các
Các hàm xilly_setupchannels() phân bổ các bộ đệm này bằng cách yêu cầu toàn bộ
các trang từ kernel và đưa chúng vào bộ đệm DMA nếu cần. Kể từ khi
tất cả kích thước của bộ đệm đều là lũy thừa của hai, có thể đóng gói bất kỳ bộ nào như vậy
bộ đệm, với mức lãng phí tối đa một trang bộ nhớ.

Tất cả các bộ đệm được phân bổ khi trình điều khiển được tải. Điều này là cần thiết,
vì các phân đoạn bộ nhớ vật lý lớn liên tục đôi khi được yêu cầu,
có nhiều khả năng sẵn sàng hơn khi hệ thống mới được khởi động.

Việc phân bổ bộ nhớ đệm diễn ra theo đúng thứ tự chúng xuất hiện trong
IDT. Người lái xe dựa vào quy tắc các đường ống được sắp xếp theo thứ tự giảm dần
kích thước bộ đệm trong IDT. Nếu bộ đệm được yêu cầu lớn hơn hoặc bằng một trang,
số lượng trang cần thiết được yêu cầu từ kernel và đây là
được sử dụng cho bộ đệm này. Nếu bộ đệm được yêu cầu nhỏ hơn một trang, một
một trang được yêu cầu từ kernel và trang đó được sử dụng một phần.
Hoặc, nếu đã có sẵn một trang được sử dụng một phần, bộ đệm sẽ được đóng gói
vào trang đó. Có thể thấy rằng tất cả các trang được yêu cầu từ kernel
(có thể ngoại trừ cái cuối cùng) được sử dụng 100% theo cách này.

Thông báo "không trống" (hỗ trợ cuộc thăm dò ý kiến)
----------------------------------------

Để hỗ trợ phương pháp "thăm dò ý kiến" (và do đó select() ), có một yêu cầu nhỏ
lưu ý về hướng FPGA tới máy chủ: FPGA có thể đã lấp đầy DMA
đệm với một số dữ liệu, nhưng không gửi bộ đệm đó. Nếu chủ nhà đợi
việc gửi bộ đệm bởi FPGA, sẽ có khả năng là
Phía FPGA đã gửi dữ liệu nhưng lệnh gọi select() vẫn sẽ chặn vì
máy chủ chưa nhận được bất kỳ thông báo nào về việc này. Điều này được giải quyết với
Tin nhắn XILLYMSG_OPCODE_NONEMPTY được gửi bởi FPGA khi một kênh chuyển từ
hoàn toàn trống rỗng để chứa một số dữ liệu.

Những thông báo này chỉ được sử dụng để hỗ trợ poll() và select(). Lõi IP có thể
được cấu hình để không gửi chúng để giảm băng thông một chút.
