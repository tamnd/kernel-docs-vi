.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/monreader.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================
Linux API để truy cập đọc vào Bản ghi màn hình z/VM
=====================================================

Ngày : 2004-Nov-26

Tác giả: Gerald Schaefer (geraldsc@de.ibm.com)




Sự miêu tả
===========
Mặt hàng này cung cấp một Linux API mới dưới dạng một thiết bị char linh tinh
có thể sử dụng từ không gian người dùng và cho phép truy cập đọc vào Bản ghi màn hình z/VM
được thu thập bởi Dịch vụ hệ thống ZZ0000ZZ của z/VM.


Yêu cầu của người dùng
======================
Máy khách z/VM mà bạn muốn truy cập API này cần phải được cấu hình trong
để cho phép kết nối IUCV với dịch vụ ZZ0000ZZ, tức là nó cần
Tuyên bố IUCV ZZ0001ZZ trong mục nhập của người dùng. Nếu màn hình DCSS được sử dụng là
bị hạn chế (có thể), bạn cũng cần câu lệnh NAMESAVE <DCSS NAME>.
Mục này sẽ sử dụng trình điều khiển thiết bị IUCV để truy cập các dịch vụ z/VM, vì vậy bạn
cần kernel có hỗ trợ IUCV. Bạn cũng cần z/VM phiên bản 4.4 hoặc 5.1.

Có hai tùy chọn để có thể tải màn hình DCSS (ví dụ giả sử
rằng màn hình DCSS bắt đầu ở mức 144 MB và kết thúc ở mức 152 MB). Bạn có thể truy vấn
vị trí của màn hình DCSS với lệnh CP đặc quyền Loại E Q NSS MAP
(các giá trị BEGPAG và ENDPAG được tính theo đơn vị trang 4K).

Xem thêm "Tham khảo lệnh và tiện ích CP" (SC24-6081-00) để biết thêm thông tin
trên các lệnh DEF STOR và Q NSS MAP, cũng như "Lập kế hoạch phân đoạn đã lưu
và Quản trị" (SC24-6116-00) để biết thêm thông tin về DCSS.

Tùy chọn thứ 1:
---------------
Bạn có thể sử dụng lệnh CP DEF STOR CONFIG để xác định "lỗ bộ nhớ" trong
lưu trữ ảo của khách xung quanh dải địa chỉ của DCSS.

Ví dụ: DEF STOR CONFIG 0,140M 200M.200M

Điều này xác định hai khối lưu trữ, khối đầu tiên có kích thước 140MB và bắt đầu tại
địa chỉ 0 MB, địa chỉ thứ hai có kích thước 200 MB và bắt đầu ở địa chỉ 200 MB,
dẫn đến tổng dung lượng lưu trữ là 340 MB. Lưu ý rằng khối đầu tiên nên
luôn bắt đầu từ 0 và có kích thước tối thiểu 64 MB.

Tùy chọn thứ 2:
---------------
Bộ nhớ ảo khách của bạn phải kết thúc bên dưới địa chỉ bắt đầu của DCSS
và bạn phải chỉ định tham số kernel "mem=" trong parmfile của mình bằng một
giá trị lớn hơn địa chỉ kết thúc của DCSS.

Ví dụ::

DEF STOR 140M

Điều này xác định kích thước lưu trữ 140 MB cho khách của bạn, tham số "mem=160M" là
được thêm vào parmfile.


Giao diện người dùng
====================
Thiết bị char được triển khai dưới dạng mô-đun hạt nhân có tên là "monreader",
có thể được tải thông qua lệnh modprobe hoặc có thể được biên dịch thành
thay vào đó là hạt nhân. Có một tham số mô-đun (hoặc kernel) tùy chọn, "mondcss",
để chỉ định tên của màn hình DCSS. Nếu mô-đun được biên dịch thành
kernel, tham số kernel "monreader.mondcss=<DCSS NAME>" có thể được chỉ định
trong tệp parmfile.

Tên mặc định cho DCSS là "MONDCSS" nếu không có tên nào được chỉ định. Trong trường hợp đó
có những người dùng khác đã kết nối với dịch vụ ZZ0000ZZ (ví dụ:
Bộ công cụ Hiệu suất), màn hình DCSS đã được xác định và bạn phải sử dụng
DCSS tương tự. Lệnh CP Q MONITOR (Đặc quyền lớp E) hiển thị tên
của màn hình DCSS, nếu đã được xác định và người dùng được kết nối với
Dịch vụ ZZ0001ZZ.
Tham khảo sách "z/VM Performance" (SC24-6109-00) về cách tạo màn hình
DCSS nếu z/VM của bạn chưa có, bạn cần có đặc quyền Loại E để
xác định và lưu DCSS.

Ví dụ:
--------

::

modprobe monreader mondcss=MYDCSS

Thao tác này sẽ tải mô-đun và đặt tên DCSS thành "MYDCSS".

NOTE:
-----
API này không cung cấp giao diện để điều khiển dịch vụ ZZ0000ZZ, ví dụ: chỉ định
dữ liệu nào cần được thu thập. Điều này có thể được thực hiện bằng lệnh CP MONITOR
(Đặc quyền của Lớp E), xem "Tham khảo Lệnh và Tiện ích CP".

Các nút thiết bị có udev:
-------------------------
Sau khi tải mô-đun, một thiết bị char sẽ được tạo cùng với thiết bị
nút /<thư mụcudev>/monreader.

Các nút thiết bị không có udev:
-------------------------------
Nếu bản phân phối của bạn không hỗ trợ udev, nút thiết bị sẽ không được tạo
tự động và bạn phải tạo thủ công sau khi tải mô-đun.
Vì vậy bạn cần phải biết số chính và số phụ của thiết bị. Những cái này
các số có thể được tìm thấy trong /sys/class/misc/monreader/dev.

Gõ cat /sys/class/misc/monreader/dev sẽ cho ra kết quả có dạng
<chính>:<nhỏ>. Nút thiết bị có thể được tạo thông qua lệnh mknod, nhập
mknod <name> c <major> <minor>, trong đó <name> là tên của nút thiết bị
được tạo ra.

Ví dụ:
--------

::

Trình đọc đơn vị # modprobe
	# cat /sys/class/misc/monreader/dev
	10:63
	# mknod /dev/monreader c 10 63

Thao tác này sẽ tải mô-đun với màn hình mặc định DCSS (MONDCSS) và tạo một
nút thiết bị.

Thao tác với tập tin:
---------------------
Các thao tác tệp sau được hỗ trợ: mở, phát hành, đọc, thăm dò ý kiến.
Có hai phương pháp thay thế để đọc: hoặc đọc vào không chặn
kết hợp với bỏ phiếu, hoặc chặn đọc mà không bỏ phiếu. IOCTL không phải
được hỗ trợ.

Đọc:
-----
Việc đọc từ thiết bị cung cấp phần tử điều khiển màn hình 12 Byte (MCE),
theo sau là một tập hợp một hoặc nhiều bản ghi giám sát liền kề (tương tự như
đầu ra của tiện ích CMS MONWRITE không có khối điều khiển 4K). MCE
chứa thông tin về loại bộ bản ghi sau (mẫu/sự kiện
data), các miền giám sát chứa trong đó và địa chỉ bắt đầu và kết thúc
của bản ghi được thiết lập trong màn hình DCSS. Địa chỉ bắt đầu và kết thúc có thể được sử dụng
để xác định kích thước của tập bản ghi, địa chỉ cuối cùng là địa chỉ của
byte dữ liệu cuối cùng. Cần có địa chỉ bắt đầu để xử lý các bản ghi "cuối khung"
chính xác (tên miền 1, bản ghi 13), tức là nó có thể được sử dụng để xác định bản ghi
phần bù bắt đầu tương ứng với ranh giới trang (khung) 4K.

Xem "Phụ lục A: ZZ0000ZZ" trong tài liệu "Hiệu suất z/VM" để biết mô tả
của cách bố trí phần tử điều khiển màn hình. Bố cục của các bản ghi giám sát có thể
được tìm thấy ở đây (z/VM 5.1): ZZ0001ZZ

Bố cục của luồng dữ liệu được cung cấp bởi thiết bị monreader như sau::

	...
<đọc 0 byte>
	<MCE đầu tiên> \
	<bộ hồ sơ đầu tiên> |
	...                       |- data set
<MCE cuối cùng> |
	<bộ bản ghi cuối cùng> /
	<đọc 0 byte>
	...

Có thể có nhiều hơn một sự kết hợp của MCE và bộ bản ghi tương ứng
trong một tập dữ liệu và phần cuối của mỗi tập dữ liệu được biểu thị bằng một tín hiệu thành công
đọc với giá trị trả về là 0 (đọc 0 byte).
Mọi dữ liệu nhận được phải được coi là không hợp lệ cho đến khi một bộ hoàn chỉnh được
đọc thành công, bao gồm cả việc đọc 0 byte đóng. Vì thế bạn nên
luôn đọc toàn bộ vào bộ đệm trước khi xử lý dữ liệu.

Kích thước tối đa của tập dữ liệu có thể lớn bằng kích thước của
giám sát DCSS, do đó hãy thiết kế bộ đệm phù hợp hoặc sử dụng phân bổ bộ nhớ động.
Kích thước của màn hình DCSS sẽ được in vào nhật ký hệ thống sau khi tải
mô-đun. Bạn cũng có thể sử dụng lệnh CP (đặc quyền của Lớp E) Q NSS MAP để
liệt kê tất cả các phân đoạn có sẵn và thông tin về chúng.

Như với hầu hết các thiết bị char, điều kiện lỗi được biểu thị bằng cách trả về một
giá trị âm cho số byte được đọc. Trong trường hợp này, biến errno
cho biết tình trạng lỗi:

EIO:
     trả lời không thành công, dữ liệu đọc không hợp lệ và ứng dụng
     nên loại bỏ dữ liệu đã đọc kể từ lần đọc thành công cuối cùng với kích thước 0.
EFAULT:
	copy_to_user không thành công, dữ liệu đọc không hợp lệ và ứng dụng sẽ
	loại bỏ dữ liệu đã đọc kể từ lần đọc thành công cuối cùng với kích thước 0.
EAGAIN:
	xảy ra khi đọc không chặn nếu không có sẵn dữ liệu tại
	khoảnh khắc. Không có dữ liệu nào bị thiếu hoặc bị hỏng, chỉ cần thử lại hoặc đúng hơn
	sử dụng bỏ phiếu cho các lần đọc không chặn.
EOVERFLOW:
	   đã đạt đến giới hạn tin nhắn, dữ liệu đã đọc kể từ lần thành công cuối cùng
	   đọc với kích thước 0 là hợp lệ nhưng các bản ghi tiếp theo có thể bị thiếu.

Trong trường hợp cuối cùng (EOVERFLOW) có thể thiếu dữ liệu, trong hai trường hợp đầu tiên
(EIO, EFAULT) sẽ bị thiếu dữ liệu. Tùy thuộc vào ứng dụng nếu nó sẽ
tiếp tục đọc dữ liệu tiếp theo hay đúng hơn là thoát ra.

Mở:
-----
Chỉ một người dùng được phép mở thiết bị char. Nếu nó đã được sử dụng rồi thì
chức năng mở sẽ không thành công (trả về giá trị âm) và đặt errno thành EBUSY.
Chức năng mở cũng có thể không thành công nếu kết nối IUCV với dịch vụ ZZ0000ZZ
không thể được thành lập. Trong trường hợp này errno sẽ được đặt thành EIO và xảy ra lỗi
tin nhắn có mã IPUSER SEVER sẽ được in vào nhật ký hệ thống. IPUSER SEVER
mã được mô tả trong sách "Hiệu suất z/VM", Phụ lục A.

NOTE:
-----
Ngay khi mở thiết bị, các tin nhắn đến sẽ được chấp nhận và chúng
sẽ chiếm giới hạn tin nhắn, tức là mở thiết bị mà không đọc
từ đó sẽ gây ra lỗi "đạt đến giới hạn tin nhắn" (mã lỗi EOVERFLOW)
cuối cùng.
