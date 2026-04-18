.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/rapidio/rapidio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Giới thiệu
=============

Chuẩn RapidIO là một chuẩn kết nối vải dựa trên gói được thiết kế cho
sử dụng trong các hệ thống nhúng. Việc phát triển tiêu chuẩn RapidIO được chỉ đạo bởi
Hiệp hội Thương mại RapidIO (RTA). Phiên bản hiện tại của thông số RapidIO
có sẵn công khai để tải xuống từ trang web RTA [1].

Tài liệu này mô tả những điều cơ bản của hệ thống con Linux RapidIO và cung cấp
thông tin về các thành phần chính của nó.

1 Tổng quan
==========

Bởi vì hệ thống con RapidIO tuân theo mô hình thiết bị Linux nên nó được tích hợp
vào kernel tương tự như các bus khác bằng cách xác định thiết bị dành riêng cho RapidIO và
các loại xe buýt và đăng ký chúng trong kiểu thiết bị.

Hệ thống con Linux RapidIO độc lập về kiến trúc và do đó xác định
giao diện dành riêng cho kiến trúc cung cấp hỗ trợ cho RapidIO chung
hoạt động của hệ thống con.

2. Thành phần cốt lõi
==================

Mạng RapidIO điển hình là sự kết hợp giữa điểm cuối và bộ chuyển mạch.
Mỗi thành phần này được thể hiện trong hệ thống con bằng một dữ liệu liên quan
cấu trúc. Các thành phần logic cốt lõi của hệ thống con RapidIO được xác định
trong tệp include/linux/rio.h.

2.1 Cổng chính
---------------

Cổng chính (hoặc mport) là bộ điều khiển giao diện RapidIO cục bộ trên
bộ xử lý thực thi mã Linux. Cổng chính tạo và nhận RapidIO
gói (giao dịch). Trong hệ thống con RapidIO, mỗi cổng chính được thể hiện
bởi cấu trúc dữ liệu rio_mport. Cấu trúc này chứa cổng chính cụ thể
các tài nguyên như hộp thư và chuông cửa. rio_mport cũng bao gồm một
ID thiết bị chủ hợp lệ khi cổng chính được định cấu hình làm cổng liệt kê
chủ nhà.

Cổng chính RapidIO được phục vụ bởi trình điều khiển thiết bị nhập khẩu cụ thể của hệ thống con
cung cấp chức năng được xác định cho hệ thống con này. Để cung cấp một phần cứng
giao diện độc lập cho các hoạt động của hệ thống con RapidIO, cấu trúc rio_mport
bao gồm cấu trúc dữ liệu rio_ops chứa các con trỏ tới phần cứng cụ thể
triển khai các chức năng RapidIO.

2.2 Thiết bị
----------

Thiết bị RapidIO là bất kỳ điểm cuối nào (trừ mport) hoặc chuyển đổi trong mạng.
Tất cả các thiết bị được trình bày trong hệ thống con RapidIO bằng dữ liệu rio_dev tương ứng
cấu trúc. Các thiết bị tạo thành một danh sách thiết bị toàn cầu và danh sách thiết bị trên mỗi mạng
(tùy thuộc vào số lượng cổng và mạng có sẵn).

2.3 Chuyển đổi
----------

Bộ chuyển mạch RapidIO là một loại thiết bị đặc biệt định tuyến các gói giữa nó
cảng hướng tới đích cuối cùng. Cổng đích gói trong
switch được xác định bởi một bảng định tuyến nội bộ. Một công tắc được trình bày trong
Hệ thống con RapidIO theo cấu trúc dữ liệu rio_dev được mở rộng bằng rio_switch bổ sung
cấu trúc dữ liệu, chứa thông tin cụ thể về chuyển đổi, chẳng hạn như bản sao của
bảng định tuyến và các con trỏ để chuyển đổi các chức năng cụ thể.

Hệ thống con RapidIO xác định định dạng và phương thức khởi tạo cho hệ thống con
trình điều khiển chuyển đổi cụ thể được thiết kế để cung cấp phần cứng cụ thể
thực hiện các thủ tục quản lý chuyển mạch chung.

2.4 Mạng
-----------

Mạng RapidIO là sự kết hợp giữa các thiết bị chuyển mạch và điểm cuối được kết nối với nhau.
Mỗi mạng RapidIO mà hệ thống biết được đại diện bởi rio_net tương ứng
cấu trúc dữ liệu. Cấu trúc này bao gồm danh sách tất cả các thiết bị và địa chỉ chính
các cổng tạo thành cùng một mạng. Nó cũng chứa một con trỏ tới mặc định
cổng chính được sử dụng để giao tiếp với các thiết bị trong mạng.

2.5 Trình điều khiển thiết bị
------------------

Trình điều khiển dành riêng cho thiết bị RapidIO tuân theo Mô hình trình điều khiển hạt nhân Linux và
nhằm hỗ trợ các thiết bị RapidIO cụ thể được gắn vào mạng RapidIO.

2.6 Giao diện hệ thống con
------------------------

Đặc tả kết nối RapidIO xác định các tính năng có thể được sử dụng để cung cấp
một hoặc nhiều lớp dịch vụ chung cho tất cả các thiết bị RapidIO tham gia. Những cái này
các dịch vụ thông thường có thể hoạt động riêng biệt với trình điều khiển dành riêng cho thiết bị hoặc được sử dụng bởi
trình điều khiển dành riêng cho thiết bị. Ví dụ về nhà cung cấp dịch vụ như vậy là trình điều khiển RIONET
thực hiện giao diện Ethernet-over-RapidIO. Bởi vì chỉ có một người lái xe có thể
đã đăng ký cho một thiết bị, tất cả các dịch vụ RapidIO thông thường phải được đăng ký là
các giao diện hệ thống con. Điều này cho phép có nhiều dịch vụ phổ biến gắn liền với
cùng một thiết bị mà không chặn việc đính kèm trình điều khiển dành riêng cho thiết bị.

3. Khởi tạo hệ thống con
===========================

Để khởi tạo hệ thống con RapidIO, nền tảng phải khởi tạo và
đăng ký ít nhất một cổng chính trong mạng RapidIO. Để đăng ký nhập khẩu
trong chức năng gọi mã khởi tạo của trình điều khiển hệ thống con
rio_register_mport() cho mỗi cổng chính có sẵn.

Sau khi tất cả các cổng chính đang hoạt động được đăng ký với hệ thống con RapidIO,
một thói quen liệt kê và/hoặc khám phá có thể được gọi tự động hoặc
bằng lệnh không gian người dùng.

Hệ thống con RapidIO có thể được cấu hình để xây dựng dưới dạng liên kết tĩnh hoặc
thành phần mô-đun của hạt nhân (xem chi tiết bên dưới).

4. Đếm và khám phá
============================

4.1 Tổng quan
------------

Tùy chọn cấu hình hệ thống con RapidIO cho phép người dùng xây dựng bảng liệt kê và
phương pháp khám phá dưới dạng các thành phần được liên kết tĩnh hoặc các mô-đun có thể tải được.
Triển khai phương pháp liệt kê/khám phá và các tham số đầu vào có sẵn
xác định cách gắn bất kỳ phương thức cụ thể nào vào các cổng RapidIO có sẵn:
chỉ đơn giản là cho tất cả các lần nhập có sẵn HOẶC riêng lẻ cho thiết bị nhập được chỉ định.

Tùy thuộc vào cấu hình bản dựng liệt kê/khám phá đã chọn, có
một số phương pháp để bắt đầu quá trình liệt kê và/hoặc khám phá:

(a) Quá trình liệt kê và khám phá liên kết tĩnh có thể được bắt đầu
  tự động trong thời gian khởi tạo kernel bằng mô-đun tương ứng
  các thông số. Đây là phương pháp ban đầu được sử dụng kể từ khi giới thiệu RapidIO
  hệ thống con. Bây giờ phương pháp này dựa vào tham số mô-đun điều tra viên
  'rio-scan.scan' cho phương pháp liệt kê/khám phá cơ bản hiện có.
  Khi sử dụng tính năng bắt đầu liệt kê/khám phá tự động, người dùng phải đảm bảo
  rằng tất cả các điểm cuối khám phá đều được bắt đầu trước điểm cuối liệt kê
  và đang chờ việc liệt kê hoàn tất.
  Tùy chọn cấu hình CONFIG_RAPIDIO_DISC_TIMEOUT xác định thời gian khám phá
  điểm cuối chờ liệt kê được hoàn thành. Nếu hết thời gian quy định
  hết hạn quá trình khám phá bị chấm dứt mà không có được mạng RapidIO
  thông tin. NOTE: quá trình phát hiện đã hết thời gian chờ có thể được khởi động lại sau bằng cách sử dụng
  lệnh không gian người dùng như được mô tả bên dưới (nếu điểm cuối đã cho là
  liệt kê thành công).

(b) Quá trình liệt kê và khám phá liên kết tĩnh có thể được bắt đầu bằng
  một lệnh từ không gian người dùng. Phương pháp khởi tạo này mang lại sự linh hoạt hơn
  để khởi động hệ thống so với tùy chọn (a) ở trên. Sau tất cả việc tham gia
  điểm cuối đã được khởi động thành công, quá trình liệt kê sẽ được thực hiện
  bắt đầu trước tiên bằng cách đưa ra lệnh không gian người dùng, sau khi liệt kê xong
  đã hoàn thành, quá trình khám phá có thể được bắt đầu trên tất cả các điểm cuối còn lại.

(c) Quá trình liệt kê và khám phá mô-đun có thể được bắt đầu bằng lệnh từ
  không gian người dùng. Sau khi mô-đun liệt kê/khám phá được tải, quá trình quét mạng
  quá trình có thể được bắt đầu bằng cách đưa ra lệnh không gian người dùng.
  Tương tự như tùy chọn (b) ở trên, điều tra viên phải được bắt đầu trước.

(d) Quá trình liệt kê và khám phá mô-đun có thể được bắt đầu bởi một mô-đun
  thủ tục khởi tạo. Trong trường hợp này, một mô-đun liệt kê sẽ được tải
  đầu tiên.

Khi quá trình quét mạng được bắt đầu, nó sẽ gọi một phép liệt kê hoặc khám phá
thường lệ tùy thuộc vào vai trò được cấu hình của cổng chính: máy chủ hoặc tác nhân.

Việc liệt kê được thực hiện bởi một cổng chính nếu nó được cấu hình như một cổng máy chủ bởi
chỉ định ID đích của máy chủ lớn hơn hoặc bằng 0. chủ nhà
ID đích có thể được gán cho cổng chính bằng nhiều phương pháp khác nhau tùy thuộc vào
trên cấu hình xây dựng hệ thống con RapidIO:

(a) Đối với lõi hệ thống con RapidIO được liên kết tĩnh, hãy sử dụng tham số dòng lệnh
  "rapidio.hdid=" với danh sách gán ID đích theo thứ tự nhập
  đăng ký thiết bị. Ví dụ: trong một hệ thống có hai bộ điều khiển RapidIO
  tham số dòng lệnh "rapidio.hdid=-1,7" sẽ dẫn đến việc gán
  ID đích của máy chủ = 7 đến bộ điều khiển RapidIO thứ hai, trong khi bộ điều khiển đầu tiên
  một sẽ được chỉ định ID đích=-1.

(b) Nếu lõi hệ thống con RapidIO được xây dựng dưới dạng mô-đun có thể tải, ngoài ra
  theo phương pháp hiển thị ở trên, (các) ID đích của máy chủ có thể được chỉ định bằng cách sử dụng
  các phương pháp truyền thống để truyền tham số mô-đun "hdid=" trong quá trình tải:

- từ dòng lệnh: "modprobe rapidio hdid=-1,7", hoặc
  - từ tệp cấu hình modprobe bằng lệnh cấu hình "options",
    như trong ví dụ này: "options rapidio hdid=-1,7". Một ví dụ về modprobe
    tập tin cấu hình được cung cấp trong phần dưới đây.

NOTES:
  (i) nếu tham số "hdid=" bị bỏ qua, tất cả mport có sẵn sẽ được chỉ định
  ID đích = -1;

(ii) tham số "hdid=" trong các hệ thống có nhiều cổng có thể có
  Việc gán ID đích bị bỏ qua ở cuối danh sách (mặc định = -1).

Nếu ID thiết bị chủ cho một cổng chính cụ thể được đặt thành -1 thì việc phát hiện
quá trình sẽ được thực hiện cho nó.

Các thói quen liệt kê và khám phá sử dụng các giao dịch bảo trì RapidIO
để truy cập không gian cấu hình của thiết bị.

NOTE: Nếu trình điều khiển thiết bị dành riêng cho bộ chuyển đổi RapidIO được xây dựng dưới dạng mô-đun có thể tải
chúng phải được tải trước khi quá trình liệt kê/khám phá bắt đầu.
Yêu cầu này được đưa ra bởi thực tế là các phương pháp liệt kê/khám phá gọi
cuộc gọi lại dành riêng cho nhà cung cấp ở giai đoạn đầu.

4.2 Tự động bắt đầu đếm và khám phá
------------------------------------------------

Phương pháp bắt đầu liệt kê/khám phá tự động chỉ được áp dụng cho các phương thức tích hợp sẵn
lựa chọn cấu hình RapidIO liệt kê/khám phá. Để kích hoạt tính năng tự động
bắt đầu liệt kê/khám phá bằng bộ phương thức liệt kê cơ bản hiện có sử dụng boot
tham số dòng lệnh "rio-scan.scan=1".

Cấu hình này yêu cầu bắt đầu đồng bộ hóa tất cả các điểm cuối RapidIO
tạo thành một mạng lưới sẽ được liệt kê/khám phá. Khám phá điểm cuối có
được bắt đầu trước khi việc liệt kê bắt đầu để đảm bảo rằng tất cả RapidIO
bộ điều khiển đã được khởi tạo và sẵn sàng để được khám phá. Cấu hình
tham số CONFIG_RAPIDIO_DISC_TIMEOUT xác định thời gian (tính bằng giây)
một điểm cuối khám phá sẽ chờ việc liệt kê được hoàn thành.

Khi bắt đầu liệt kê/khám phá tự động được chọn, phương pháp cơ bản
thủ tục khởi tạo gọi rio_init_mports() để thực hiện phép liệt kê hoặc
khám phá tất cả các thiết bị nhập khẩu đã biết.

Tùy thuộc vào kích thước và cấu hình mạng RapidIO, tính năng này tự động
Phương pháp bắt đầu liệt kê/khám phá có thể khó sử dụng do
yêu cầu bắt đầu đồng bộ hóa tất cả các điểm cuối.

4.3 Bắt đầu liệt kê và khám phá không gian người dùng
-------------------------------------------------

Việc bắt đầu liệt kê và khám phá không gian người dùng có thể được sử dụng với các tính năng tích hợp và
cấu hình xây dựng mô-đun. Đối với hệ thống con RapidIO khởi động được kiểm soát bởi không gian người dùng
tạo tệp thuộc tính chỉ ghi sysfs '/sys/bus/rapidio/scan'. Để bắt đầu
quá trình liệt kê hoặc khám phá trên thiết bị nhập khẩu cụ thể, người dùng cần phải
ghi mport_ID (không phải ID đích RapidIO) vào tệp đó. import_ID là một
số thứ tự (0 ... RIO_MAX_MPORTS) được chỉ định trong quá trình nhập thiết bị
đăng ký. Ví dụ: đối với máy có bộ điều khiển RapidIO đơn, mport_ID
đối với bộ điều khiển đó sẽ luôn bằng 0.

Để bắt đầu liệt kê/khám phá RapidIO trên tất cả các cổng có sẵn, người dùng có thể
ghi '-1' (hoặc RIO_MPORT_ANY) vào tệp thuộc tính quét.

4.4 Phương pháp đếm cơ bản
----------------------------

Đây là một phương pháp liệt kê/khám phá ban đầu có sẵn kể từ
bản phát hành đầu tiên của mã hệ thống con RapidIO. Quá trình điều tra là
được thực hiện theo thuật toán liệt kê được nêu trong RapidIO
Thông số kỹ thuật kết nối: Phụ lục I [1].

Phương pháp này có thể được cấu hình dưới dạng mô-đun được liên kết tĩnh hoặc có thể tải.
Tham số "quét" duy nhất của phương thức cho phép kích hoạt việc liệt kê/khám phá
quá trình từ thói quen khởi tạo mô-đun.

Phương pháp liệt kê/khám phá này chỉ có thể được bắt đầu một lần và không hỗ trợ
dỡ tải nếu nó được xây dựng như một mô-đun.

Quá trình liệt kê đi qua mạng bằng cách sử dụng đệ quy theo chiều sâu
thuật toán. Khi tìm thấy một thiết bị mới, điều tra viên sẽ sở hữu thiết bị đó
thiết bị bằng cách ghi vào Khóa ID thiết bị chủ CSR. Nó làm điều này để đảm bảo rằng
điều tra viên có toàn quyền liệt kê thiết bị. Nếu quyền sở hữu thiết bị
được thu thập thành công, điều tra viên sẽ phân bổ cấu trúc rio_dev mới và
khởi tạo nó theo khả năng của thiết bị.

Nếu thiết bị là điểm cuối, ID thiết bị duy nhất sẽ được gán cho thiết bị đó và giá trị của nó
được ghi vào ID thiết bị cơ sở CSR của thiết bị.

Nếu thiết bị là switch thì điều tra viên sẽ phân bổ thêm rio_switch
Cấu trúc để lưu trữ thông tin cụ thể của switch. Sau đó, ID nhà cung cấp của switch và
ID thiết bị được truy vấn dựa vào bảng các công tắc RapidIO đã biết. Mỗi công tắc
mục trong bảng chứa một con trỏ tới một thủ tục khởi tạo dành riêng cho switch
khởi tạo con trỏ tới phần còn lại của các hoạt động cụ thể của switch và thực hiện
khởi tạo phần cứng nếu cần thiết. Công tắc RapidIO không có địa chỉ duy nhất
ID thiết bị; nó dựa vào số bước nhảy và định tuyến cho ID thiết bị của một thiết bị đính kèm
điểm cuối nếu cần truy cập vào các thanh ghi cấu hình của nó. Nếu một công tắc (hoặc
chuỗi chuyển mạch) không có bất kỳ điểm cuối nào (ngoại trừ điều tra viên) được gắn vào
nó, ID thiết bị giả sẽ được chỉ định để định cấu hình tuyến đường đến bộ chuyển mạch đó.
Trong trường hợp chuỗi switch không có điểm cuối, một ID thiết bị giả sẽ được sử dụng
để định cấu hình tuyến đường xuyên qua toàn bộ chuỗi và các thiết bị chuyển mạch được phân biệt bằng
giá trị hopcount của chúng.

Đối với cả hai điểm cuối và thiết bị chuyển mạch, điều tra viên ghi một thẻ thành phần duy nhất
vào Thẻ thành phần CSR của thiết bị. Giá trị duy nhất đó được sử dụng bởi lỗi
cơ chế thông báo quản lý để xác định thiết bị đang báo cáo sự cố
sự kiện quản lý lỗi.

Việc liệt kê ngoài một switch được hoàn thành bằng cách lặp qua từng đầu ra đang hoạt động
cổng của switch đó. Đối với mỗi liên kết hoạt động, một tuyến đến ID thiết bị mặc định
(0xFF cho hệ thống 8 bit và 0xFFFF cho hệ thống 16 bit) được ghi tạm thời
vào bảng định tuyến. Thuật toán lặp lại bằng cách gọi chính nó với hopcount + 1
và ID thiết bị mặc định để truy cập thiết bị trên cổng hoạt động.

Sau khi máy chủ hoàn thành việc liệt kê toàn bộ mạng, nó sẽ giải phóng
thiết bị bằng cách xóa khóa ID thiết bị (gọi rio_clear_locks()). Đối với mỗi điểm cuối
trong hệ thống, nó đặt bit Đã khám phá trong Cổng điều khiển chung CSR
để chỉ ra rằng việc liệt kê đã hoàn thành và các tác nhân được phép thực thi
khám phá thụ động của mạng.

Quá trình khám phá được thực hiện bởi các tác nhân và tương tự như việc liệt kê
quá trình được mô tả ở trên. Tuy nhiên, quá trình khám phá được thực hiện
không thay đổi định tuyến hiện tại vì các tác nhân chỉ thu thập thông tin
về cấu trúc mạng RapidIO và đang xây dựng bản đồ nội bộ về các
thiết bị. Bằng cách này, mỗi thành phần dựa trên Linux của hệ thống con RapidIO có
một cái nhìn toàn diện về mạng. Quá trình khám phá có thể được thực hiện
đồng thời bởi nhiều đại lý. Sau khi khởi tạo cổng chính RapidIO của nó
mỗi tác nhân chờ máy chủ hoàn thành việc liệt kê trong thời gian chờ được định cấu hình
khoảng thời gian. Nếu khoảng thời gian chờ đợi này hết hạn trước khi việc liệt kê hoàn tất,
một tác nhân bỏ qua việc khám phá RapidIO và tiếp tục với kernel còn lại
khởi tạo.

4.5 Thêm phương pháp liệt kê/khám phá mới
-------------------------------------------

Tổ chức mã hệ thống con RapidIO cho phép bổ sung bảng liệt kê/khám phá mới
các phương thức như các tùy chọn cấu hình mới mà không ảnh hưởng đáng kể đến lõi
Mã RapidIO.

Một phương pháp liệt kê/khám phá mới phải được gắn vào một hoặc nhiều lần nhập
thiết bị trước khi quá trình liệt kê/khám phá có thể được bắt đầu. Thông thường,
Quy trình khởi tạo mô-đun của phương thức gọi rio_register_scan() để đính kèm
một điều tra viên cho một thiết bị (hoặc các thiết bị) nhập được chỉ định. Điều tra viên cơ bản
việc thực hiện thể hiện quá trình này.

4.6 Sử dụng trình điều khiển chuyển đổi RapidIO có thể tải
-----------------------------------------

Trong trường hợp khi trình điều khiển chuyển đổi RapidIO được xây dựng dưới dạng mô-đun có thể tải, người dùng
phải đảm bảo rằng chúng được tải trước khi bắt đầu liệt kê/khám phá.
Quá trình này có thể được tự động hóa bằng cách chỉ định các phần phụ thuộc trước hoặc sau trong
Tệp cấu hình modprobe dành riêng cho RapidIO như trong ví dụ bên dưới.

Tệp /etc/modprobe.d/rapidio.conf::

Mô-đun hệ thống con # Configure RapidIO

ID đích của máy chủ liệt kê # Set (ghi đè tùy chọn dòng lệnh kernel)
  tùy chọn rapidio hdid=-1,2

Trình điều khiển chuyển đổi RapidIO # Load ngay sau khi tải mô-đun lõi rapidio
  bài đăng softdep rapidio: idt_gen2 idtcps tsi57x

# OR :

Trình điều khiển chuyển đổi RapidIO # Load ngay trước khi tải mô-đun liệt kê rio-scan
  softdep rio-scan trước: idt_gen2 idtcps tsi57x

-----------------

NOTE:
  Trong ví dụ trên, một trong các lệnh "softdep" phải được loại bỏ hoặc
  đã nhận xét để giữ trình tự tải mô-đun cần thiết.

5. Tài liệu tham khảo
=============

[1] Hiệp hội thương mại RapidIO. Thông số kỹ thuật kết nối RapidIO.
    ZZ0000ZZ

[2] Rapidio TA. So sánh công nghệ.
    ZZ0000ZZ

[3] Hỗ trợ RapidIO cho Linux.
    ZZ0000ZZ

[4] Matt Porter. RapidIO cho Linux. Hội nghị chuyên đề Ottawa Linux, 2005
    ZZ0000ZZ
