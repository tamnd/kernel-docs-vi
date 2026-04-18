.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/ibmvmc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================
Trình điều khiển hạt nhân kênh quản lý ảo IBM (IBMVMC)
===========================================================

:Tác giả:
	Dave Engebretsen <engebret@us.ibm.com>,
	Adam Reznechek <adreznec@linux.vnet.ibm.com>,
	Steven Royer <seroyer@linux.vnet.ibm.com>,
	Bryant G. Ly <bryantly@linux.vnet.ibm.com>,

Giới thiệu
============

Lưu ý: Cần có kiến thức về công nghệ ảo hóa để hiểu
tài liệu này.

Một tài liệu tham khảo tốt sẽ là:

ZZ0000ZZ

Kênh quản lý ảo (VMC) là một thiết bị logic cung cấp
giao diện giữa hypervisor và phân vùng quản lý. Giao diện này
giống như một giao diện truyền tin nhắn. Phân vùng quản lý này được thiết kế
để cung cấp giải pháp thay thế cho các hệ thống sử dụng Quản lý phần cứng
Quản lý hệ thống dựa trên Console (HMC).

Giải pháp quản lý phần cứng chính được phát triển bởi IBM dựa trên
trên máy chủ thiết bị có tên Bảng điều khiển quản lý phần cứng (HMC),
được đóng gói như một tháp bên ngoài hoặc máy tính cá nhân gắn trên giá. trong một
Môi trường Hệ thống điện, một HMC duy nhất có thể quản lý nhiều POWER
các hệ thống dựa trên bộ xử lý.

Ứng dụng quản lý
----------------------

Trong phân vùng quản lý tồn tại một ứng dụng quản lý cho phép
quản trị viên hệ thống để định cấu hình phân vùng của hệ thống
đặc điểm thông qua giao diện dòng lệnh (CLI) hoặc Đại diện
Đơn xin chuyển bang (REST API's).

Ứng dụng quản lý chạy trên phân vùng logic Linux trên một
POWER8 hoặc máy chủ dựa trên bộ xử lý mới hơn được ảo hóa bởi PowerVM.
Các chức năng cấu hình, bảo trì và điều khiển hệ thống
theo truyền thống yêu cầu HMC có thể được triển khai trong quản lý
ứng dụng sử dụng kết hợp HMC với giao diện ảo hóa và
phương pháp hệ điều hành hiện có. Công cụ này cung cấp một tập hợp con của
các chức năng được HMC triển khai và cho phép cấu hình phân vùng cơ bản.
Tập hợp các thông báo HMC tới bộ ảo hóa được quản lý hỗ trợ
thành phần ứng dụng được chuyển tới bộ ảo hóa qua giao diện VMC,
được định nghĩa dưới đây.

VMC cho phép phân vùng quản lý cung cấp phân vùng cơ bản
chức năng:

- Cấu hình phân vùng logic
- Bắt đầu và dừng hành động cho các phân vùng riêng lẻ
- Hiển thị trạng thái phân vùng
- Quản lý Ethernet ảo
- Quản lý lưu trữ ảo
- Quản lý hệ thống cơ bản

Kênh quản lý ảo (VMC)
--------------------------------

Một thiết bị logic, được gọi là Kênh quản lý ảo (VMC), được xác định
để liên lạc giữa ứng dụng quản lý và bộ ảo hóa. Nó
về cơ bản tạo ra các đường dẫn cho phép quản lý ảo hóa
phần mềm. Thiết bị này được đưa vào một phân vùng quản lý được chỉ định dưới dạng
một thiết bị ảo.

Thiết bị liên lạc này sử dụng Hàng đợi Lệnh/Phản hồi (CRQ) và
Giao diện truy cập bộ nhớ trực tiếp từ xa (RDMA). Bắt tay ba chiều là
được xác định phải diễn ra để chứng minh rằng cả hypervisor và
các phân vùng quản lý của kênh đang chạy trước
gửi/nhận bất kỳ tin nhắn giao thức nào.

Trình điều khiển này cũng sử dụng CRQ sự kiện vận chuyển. Tin nhắn CRQ được gửi
khi trình ảo hóa phát hiện một trong các phân vùng ngang hàng có lỗi bất thường
chấm dứt, hoặc một bên đã gọi H_FREE_CRQ để đóng CRQ của họ.
Hai loại tin nhắn CRQ mới được giới thiệu cho thiết bị VMC. VMC
Thông báo quản trị được sử dụng cho mỗi phân vùng bằng VMC để
truyền đạt khả năng cho đối tác của họ. Thông báo giao diện HMC được sử dụng
đối với luồng tin nhắn HMC thực tế giữa phân vùng quản lý và
siêu giám sát. Vì hầu hết các tin nhắn HMC đều vượt xa kích thước của bộ đệm CRQ,
một DMA (RMDA) ảo của dữ liệu tin nhắn HMC được thực hiện trước mỗi HMC
Giao diện tin nhắn CRQ. Chỉ có phân vùng quản lý ổ đĩa RDMA
hoạt động; trình ảo hóa không bao giờ trực tiếp gây ra sự chuyển động của dữ liệu tin nhắn.


Thuật ngữ
-----------
RDMA
        Truy cập bộ nhớ trực tiếp từ xa là chuyển DMA từ máy chủ sang máy chủ của nó
        client hoặc từ máy chủ tới phân vùng đối tác của nó. DMA đề cập đến
        cho cả hoạt động I/O vật lý đến và từ bộ nhớ cũng như tới bộ nhớ
        đến các thao tác di chuyển bộ nhớ.
CRQ
        Hàng đợi Lệnh/Phản hồi một cơ sở được sử dụng để liên lạc
        giữa các phân vùng đối tác. Sự kiện vận chuyển được báo hiệu
        từ bộ ảo hóa đến phân vùng cũng được báo cáo trong hàng đợi này.

Ví dụ về quản lý phân vùng VMC Giao diện trình điều khiển
=========================================================

Phần này cung cấp một ví dụ về ứng dụng quản lý
triển khai trong đó trình điều khiển thiết bị được sử dụng để giao tiếp với VMC
thiết bị. Trình điều khiển này bao gồm một thiết bị mới, ví dụ /dev/ibmvmc,
cung cấp các giao diện để mở, đóng, đọc, viết và thực hiện
ioctl chống lại thiết bị VMC.

Khởi tạo giao diện VMC
----------------------------

Trình điều khiển thiết bị chịu trách nhiệm khởi tạo VMC khi trình điều khiển
được tải. Đầu tiên nó tạo và khởi tạo CRQ. Tiếp theo là trao đổi
Khả năng của VMC được thực hiện để chỉ ra phiên bản mã và số lượng
tài nguyên có sẵn trong cả phân vùng quản lý và bộ ảo hóa.
Cuối cùng, trình ảo hóa yêu cầu phân vùng quản lý tạo một
nhóm bộ đệm VMC ban đầu, một bộ đệm cho mỗi kết nối HMC có thể,
sẽ được sử dụng để khởi tạo phiên ứng dụng quản lý.
Trước khi hoàn thành trình tự khởi tạo này, thiết bị sẽ trả về
EBUSY để mở cuộc gọi(). EIO được trả về cho tất cả các lỗi open().

::

Quản lý phân vùng ảo hóa
                        CRQ INIT
        ----------------------------------------->
        	   CRQ INIT COMPLETE
        <----------------------------------------
        	      CAPABILITIES
        ----------------------------------------->
        	 CAPABILITIES RESPONSE
        <----------------------------------------
              ADD BUFFER (HMC IDX=0,1,..) _
        <---------------------------------------- |
        	  ADD BUFFER RESPONSE | - Thực hiện các lần lặp # HMCs
        ----------------------------------------> -

Giao diện VMC mở
------------------

Sau khi kênh VMC cơ bản được khởi tạo, cấp phiên HMC
kết nối có thể được thiết lập. Lớp ứng dụng thực hiện open() để
thiết bị VMC và thực thi ioctl() đối với thiết bị đó, cho biết ID HMC
(32 byte dữ liệu) cho phiên này. Nếu thiết bị VMC ở trạng thái không hợp lệ
trạng thái, EIO sẽ được trả về cho ioctl(). Trình điều khiển thiết bị tạo ra một
giá trị phiên HMC mới (từ 1 đến 255) và giá trị chỉ mục HMC (bắt đầu
ở chỉ số 0 và dao động đến 254) cho ID HMC này. Người lái xe sau đó thực hiện một
RDMA của ID HMC tới bộ điều khiển ảo hóa, sau đó gửi Giao diện mở
thông báo tới bộ điều khiển ảo hóa để thiết lập phiên qua VMC. Sau khi
bộ ảo hóa nhận được thông tin này, nó sẽ gửi thông báo Thêm bộ đệm tới
phân vùng quản lý để tạo nhóm bộ đệm ban đầu cho HMC mới
kết nối. Cuối cùng, trình ảo hóa gửi Phản hồi mở giao diện
thông báo, để cho biết rằng nó đã sẵn sàng cho việc nhắn tin trong thời gian chạy bình thường. các
sau đây minh họa luồng VMC này:

::

Quản lý phân vùng ảo hóa
        	      ID RDMA HMC
        ----------------------------------------->
        	    Giao diện mở
        ----------------------------------------->
        	      Thêm bộ đệm _
        <---------------------------------------- |
        	  Thêm phản hồi bộ đệm | - Thực hiện N lần lặp
        ----------------------------------------> -
        	Giao diện phản hồi mở
        <----------------------------------------

Thời gian chạy giao diện VMC
----------------------------

Trong thời gian chạy bình thường, ứng dụng quản lý và bộ ảo hóa
trao đổi tin nhắn HMC thông qua tin nhắn Signal VMC và các hoạt động RDMA. Khi nào
gửi dữ liệu đến bộ ảo hóa, ứng dụng quản lý sẽ thực hiện một
write() vào thiết bị VMC và dữ liệu của trình điều khiển RDMA tới bộ ảo hóa
và sau đó gửi một Tin nhắn Tín hiệu. Nếu thử ghi() trước VMC
bộ đệm thiết bị đã được cung cấp bởi bộ ảo hóa hoặc không có bộ đệm
hiện có sẵn, EBUSY được trả về để phản hồi lệnh ghi(). A
write() sẽ trả về EIO cho tất cả các lỗi khác, chẳng hạn như thiết bị không hợp lệ
trạng thái. Khi hypervisor gửi tin nhắn đến ban quản lý, dữ liệu sẽ được
đưa vào bộ đệm VMC và Tin nhắn tín hiệu được gửi đến trình điều khiển VMC trong
phân vùng quản lý. Driver RDMA đưa bộ đệm vào phân vùng
và chuyển dữ liệu đến ứng dụng quản lý thích hợp thông qua một
read() vào thiết bị VMC. Khối yêu cầu read() nếu không có bộ đệm
có sẵn để đọc. Ứng dụng quản lý có thể sử dụng select() để chờ
thiết bị VMC sẵn sàng với dữ liệu để đọc.

::

Quản lý phân vùng ảo hóa
        		MSG RDMA
        ----------------------------------------->
        		SIGNAL MSG
        ----------------------------------------->
        		SIGNAL MSG
        <----------------------------------------
        		MSG RDMA
        <----------------------------------------

Giao diện VMC Đóng
-------------------

Các kết nối cấp phiên HMC bị đóng bởi phân vùng quản lý khi
lớp ứng dụng thực hiện đóng() đối với thiết bị. Hành động này
dẫn đến một thông báo Đóng giao diện được gửi tới bộ điều khiển ảo hóa, thông báo này
khiến phiên kết thúc. Trình điều khiển thiết bị phải giải phóng mọi
bộ nhớ được phân bổ cho bộ đệm cho kết nối HMC này.

::

Quản lý phân vùng ảo hóa
        	     INTERFACE CLOSE
        ----------------------------------------->
                INTERFACE CLOSE RESPONSE
        <----------------------------------------

Thông tin bổ sung
======================

Để biết thêm thông tin về tài liệu dành cho Tin nhắn CRQ, Tin nhắn VMC,
Bộ đệm giao diện HMC và các thông báo tín hiệu vui lòng tham khảo Linux trên
Tài liệu tham khảo nền tảng kiến trúc sức mạnh. Phần F.