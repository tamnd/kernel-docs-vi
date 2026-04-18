.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/hamradio/baycom.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Trình điều khiển Linux cho Modem Baycom
===============================

Thomas M. Sailer, HB9JNX/AE4WA, <sailer@ife.ee.ethz.ch>

Trình điều khiển cho modem baycom đã được chia thành
các trình điều khiển riêng biệt vì chúng không chia sẻ bất kỳ mã nào và trình điều khiển
và tên thiết bị đã thay đổi.

Tài liệu này mô tả Trình điều khiển hạt nhân Linux cho kiểu Baycom đơn giản
modem vô tuyến nghiệp dư.

Các trình điều khiển sau đây có sẵn:
====================================

baycom_ser_fdx:
  Trình điều khiển này hỗ trợ các modem SER12 ở chế độ song công hoàn toàn hoặc bán song công.
  Tốc độ truyền của nó có thể được thay đổi thông qua tham số mô-đun ZZ0000ZZ,
  do đó nó hỗ trợ gần như mọi modem bit bang trên một
  cổng nối tiếp. Các thiết bị của nó được gọi là bcsf0 đến bcsf3.
  Đây là trình điều khiển được khuyên dùng cho modem loại SER12,
  tuy nhiên nếu bạn có bản sao UART bị hỏng và không hoạt động
  bit trạng thái delta, bạn có thể thử baycom_ser_hdx.

baycom_ser_hdx:
  Đây là trình điều khiển thay thế cho modem loại SER12.
  Nó chỉ hỗ trợ bán song công và chỉ 1200 baud. Thiết bị của nó
  được gọi là bcsh0 đến bcsh3. Chỉ sử dụng trình điều khiển này nếu baycom_ser_fdx
  không hoạt động với UART của bạn.

baycom_par:
  Trình điều khiển này hỗ trợ modem par96 và picpar.
  Các thiết bị của nó được gọi là bcp0 đến bcp3.

baycom_epp:
  Trình điều khiển này hỗ trợ modem EPP.
  Các thiết bị của nó được gọi là bce0 đến bce3.
  Trình điều khiển này đang được hoàn thiện.

Các modem sau được hỗ trợ:

=====================================================================================
ser12 Đây là modem AFSK 1200 baud rất đơn giản. Modem chỉ bao gồm
	của chip điều chế/giải điều chế, thường là TI TCM3105. Máy tính
	chịu trách nhiệm tái tạo đồng hồ bit của máy thu, cũng như
	để xử lý giao thức HDLC. Modem kết nối với một cổng nối tiếp,
	do đó có tên. Vì cổng nối tiếp không được sử dụng làm cổng nối tiếp không đồng bộ
	port, trình điều khiển kernel cho cổng nối tiếp không thể được sử dụng và điều này
	trình điều khiển chỉ hỗ trợ phần cứng nối tiếp tiêu chuẩn (8250, 16450, 16550)

par96 Đây là modem có tốc độ 9600 baud FSK tương thích với tiêu chuẩn G3RUH.
	Modem thực hiện tất cả việc lọc và tạo lại đồng hồ máy thu.
	Dữ liệu được truyền từ và đến PC thông qua một thanh ghi thay đổi.
	Thanh ghi dịch chứa đầy 16 bit và tín hiệu ngắt được báo hiệu.
	Sau đó, PC sẽ xóa thanh ghi thay đổi một cách liên tục. Modem này kết nối
	đến cổng song song, do đó có tên. Modem rời khỏi
	triển khai giao thức HDLC và đa thức mã hóa để
	máy tính.

picpar Đây là bản thiết kế lại modem par96 của Henning Rech, DF9IC. modem
	là giao thức tương thích với par96, nhưng chỉ sử dụng ba IC công suất thấp
	và do đó có thể được cấp dữ liệu từ cổng song song và không yêu cầu
	một nguồn điện bổ sung. Hơn nữa, nó kết hợp một nhà cung cấp dịch vụ
	phát hiện mạch điện

EPP Đây là bộ chuyển đổi modem tốc độ cao kết nối với mạng song song nâng cao
	cổng.

Đối tượng mục tiêu của nó là người dùng làm việc trên một trung tâm tốc độ cao (76,8kbit/s).

eppfpga Đây là thiết kế lại của bộ chuyển đổi EPP.
=====================================================================================

Tất cả các modem trên chỉ hỗ trợ giao tiếp song công. Tuy nhiên,
trình điều khiển hỗ trợ lệnh fullduplex KISS (xem bên dưới). Sau đó nó chỉ đơn giản là
bắt đầu gửi ngay khi có gói cần truyền và không quan tâm
về DCD, tức là nó bắt đầu gửi ngay cả khi có người khác trên kênh.
Lệnh này được yêu cầu bởi một số triển khai của kênh DAMA
giao thức truy cập.


Giao diện của các trình điều khiển
============================

Không giống như các trình điều khiển trước đây, các trình điều khiển này không còn là thiết bị ký tự nữa,
nhưng giờ đây chúng là giao diện mạng hạt nhân thực sự. Do đó, việc cài đặt là
đơn giản. Sau khi cài đặt, bốn giao diện có tên bc{sf,sh,p,e[0-3] sẽ có sẵn.
sethdlc từ tiện ích ax25 có thể được sử dụng để đặt trạng thái trình điều khiển, v.v.
Người dùng ngăn xếp AX.25 của vùng người dùng có thể sử dụng tiện ích net2kiss (cũng có sẵn
trong gói tiện ích ax25) để chuyển đổi các gói của giao diện mạng
tới luồng KISS trên một tty giả. Ngoài ra còn có một bản vá có sẵn từ
me cho WAMPES cho phép gắn trực tiếp giao diện mạng kernel.


Cấu hình trình điều khiển
======================

Mỗi khi một trình điều khiển được chèn vào kernel, nó phải biết cái nào
modem nó sẽ truy cập vào cổng nào. Điều này có thể được thực hiện với setbaycom
tiện ích. Nếu bạn chỉ sử dụng một modem, bạn cũng có thể cấu hình
trình điều khiển từ dòng lệnh insmod (hoặc bằng dòng tùy chọn trong
ZZ0000ZZ).

Ví dụ::

modprobe baycom_ser_fdx mode="ser12*" iobase=0x3f8 irq=4
  sethdlc -i bcsf0 -p chế độ "ser12*" io 0x3f8 irq 4

Cả hai dòng đều cấu hình cổng đầu tiên để điều khiển modem ser12 lúc đầu
cổng nối tiếp (COM1 dưới DOS). Dấu * trong tham số chế độ sẽ hướng dẫn người lái xe
sử dụng phần mềm thuật toán DCD (xem bên dưới)::

insmod baycom_par mode="picpar" iobase=0x378
  sethdlc -i bcp0 -p chế độ "picpar" io 0x378

Cả hai dòng đều cấu hình cổng đầu tiên để điều khiển modem picpar tại
cổng song song đầu tiên (LPT1 trong DOS). (Lưu ý: picpar ngụ ý
phần cứng DCD, par96 ngụ ý phần mềm DCD).

Các tham số truy cập kênh có thể được đặt bằng sethdlc -a hoặc kissparms.
Lưu ý rằng cả hai tiện ích đều diễn giải các giá trị hơi khác nhau.


Phần cứng DCD so với Phần mềm DCD
================================

Để tránh va chạm trên không, người lái xe phải biết khi nào kênh đang hoạt động
bận rộn. Đây là nhiệm vụ của mạch/phần mềm DCD. Người lái xe có thể
sử dụng thuật toán DCD phần mềm (tùy chọn=1) hoặc sử dụng tín hiệu DCD từ
phần cứng (tùy chọn = 0).

======= =======================================================================
ser12 nếu sử dụng phần mềm DCD, âm thanh của đài phải luôn ở mức
	mở. Rất khuyến khích sử dụng thuật toán DCD của phần mềm,
	vì nó nhanh hơn nhiều so với hầu hết các mạch tắt phần cứng. các
	Nhược điểm là tải hệ thống cao hơn một chút.

par96 thuật toán DCD của phần mềm dành cho loại modem này khá kém.
	Đơn giản là modem không cung cấp đủ thông tin để thực hiện
	một thuật toán DCD hợp lý trong phần mềm. Vì vậy, nếu đài phát thanh của bạn
	cung cấp đầu vào DCD của modem PAR96, việc sử dụng phần cứng
	Nên sử dụng mạch DCD.

picpar modem picpar có phần cứng DCD tích hợp, có hiệu suất cao
	đề nghị.
======= =======================================================================



Khả năng tương thích với phần còn lại của nhân Linux
===============================================

Trình điều khiển nối tiếp và trình điều khiển nối tiếp baycom cạnh tranh
cho cùng một tài nguyên phần cứng. Tất nhiên chỉ có một người lái xe có thể truy cập vào một địa chỉ nhất định
giao diện tại một thời điểm. Trình điều khiển nối tiếp lấy tất cả các giao diện mà nó có thể tìm thấy tại
thời gian khởi động. Do đó, trình điều khiển baycom sau đó sẽ không thể
truy cập vào một cổng nối tiếp. Do đó, bạn có thể thấy cần thiết phải phát hành
một cổng thuộc sở hữu của trình điều khiển nối tiếp có 'setserial /dev/ttyS# uart none', trong đó
# is số lượng giao diện. Trình điều khiển baycom không đặt trước bất kỳ
cổng khi khởi động, trừ khi một cổng được chỉ định trên dòng lệnh 'insmod'. Khác
Phương pháp giải quyết vấn đề là biên dịch tất cả các trình điều khiển dưới dạng mô-đun và
để kmod tải đúng driver tùy ứng dụng nhé.

Trình điều khiển cổng song song (baycom_par, baycom_epp) hiện sử dụng hệ thống con parport
để phân xử các cổng giữa các trình điều khiển máy khách khác nhau.

vy 73s de

Tom Sailer, thủy thủ@ife.ee.ethz.ch

hb9jnx @ hb9w.ampr.org