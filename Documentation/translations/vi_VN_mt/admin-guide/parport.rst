.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/parport.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Sân đậu xe
++++++++++

Mã ZZ0000ZZ cung cấp hỗ trợ cổng song song trong Linux.  Cái này
bao gồm khả năng chia sẻ một cổng giữa nhiều thiết bị
trình điều khiển.

Bạn có thể truyền tham số cho mã ZZ0000ZZ để ghi đè tự động
phát hiện phần cứng của bạn.  Điều này đặc biệt hữu ích nếu bạn muốn
để sử dụng IRQ, vì nhìn chung chúng không thể được tự động thăm dò thành công.
Theo mặc định, IRQ không được sử dụng ngay cả khi chúng được thăm dò ZZ0001ZZ.  Đây là
bởi vì có rất nhiều người sử dụng cùng một IRQ cho
cổng song song và card âm thanh hoặc card mạng.

Mã ZZ0000ZZ được chia thành hai phần: chung (liên quan đến
chia sẻ cổng) và phụ thuộc vào kiến trúc (liên quan đến việc thực sự
sử dụng cổng).


Parport dưới dạng mô-đun
========================

Nếu bạn tải mã ZZ0000ZZ` dưới dạng mô-đun, hãy nói::

Sân bay # insmod

để tải mã ZZ0000ZZ chung.  Sau đó bạn phải tải
mã phụ thuộc vào kiến ​​trúc với (ví dụ)::

# insmod parport_pc io=0x3bc,0x378,0x278 irq=none,7,auto

để cho mã ZZ0000ZZ biết rằng bạn muốn có ba cổng kiểu PC, một ở
0x3bc không có IRQ, một ở 0x378 sử dụng IRQ 7 và một ở 0x278 có
tự động phát hiện IRQ.  Hiện tại, kiểu PC (ZZ0001ZZ), Sun ZZ0002ZZ,
Phần cứng Amiga, Atari và MFC3 được hỗ trợ.

Hỗ trợ thẻ I/O song song PCI đến từ ZZ0000ZZ.  I/O cơ sở
không nên chỉ định địa chỉ cho thẻ PCI được hỗ trợ vì chúng
được tự động phát hiện.


máy dò mod
----------

Nếu bạn sử dụng modprobe, bạn sẽ thấy hữu ích khi thêm các dòng như bên dưới vào
tệp cấu hình trong thư mục /etc/modprobe.d/::

bí danh parport_lowlevel parport_pc
	tùy chọn parport_pc io=0x378,0x278 irq=7,tự động

modprobe sẽ tải ZZ0000ZZ (với các tùy chọn ZZ0001ZZ)
bất cứ khi nào trình điều khiển thiết bị cổng song song (chẳng hạn như ZZ0002ZZ) được tải.

Lưu ý rằng đây chỉ là những dòng ví dụ!  Nói chung bạn không nên cần
để chỉ định bất kỳ tùy chọn nào cho ZZ0000ZZ để có thể sử dụng
cổng song song.


Thăm dò Parport [tùy chọn]
--------------------------

Trong nhân 2.2 có một mô-đun tên là ZZ0000ZZ, được sử dụng
để thu thập thông tin ID thiết bị IEEE 1284.  Điều này bây giờ đã được
được cải tiến và hiện đang hoạt động với sự hỗ trợ của IEEE 1284.  Khi song song
cổng được phát hiện, các thiết bị được kết nối với nó sẽ được phân tích,
và thông tin được ghi lại như thế này::

parport0: Máy in, BJC-210 (Canon)

Thông tin thăm dò có sẵn từ các tệp trong ZZ0000ZZ.


Parport được liên kết tĩnh vào kernel
=========================================

Nếu bạn biên dịch mã ZZ0000ZZ vào kernel thì bạn có thể sử dụng
tham số khởi động kernel để có được hiệu ứng tương tự.  Thêm một cái gì đó như
theo dòng lệnh LILO của bạn ::

parport=0x3bc parport=0x378,7 parport=0x278,auto,nofifo

Bạn có thể có nhiều câu lệnh ZZ0000ZZ, một câu lệnh cho mỗi cổng bạn muốn
để thêm vào.  Thêm ZZ0001ZZ vào dòng lệnh kernel sẽ vô hiệu hóa
hỗ trợ parport hoàn toàn.  Thêm ZZ0002ZZ vào kernel
dòng lệnh sẽ làm cho ZZ0003ZZ sử dụng bất kỳ dòng IRQ hoặc kênh DMA nào
nó tự động phát hiện.


Các tập tin trong /proc
=======================

Nếu bạn đã cấu hình hệ thống tập tin ZZ0000ZZ vào kernel của mình, bạn sẽ
xem mục thư mục mới: ZZ0001ZZ.  Trong đó sẽ có một
mục nhập thư mục cho mỗi cổng song song mà parport được sử dụng
được cấu hình.  Trong mỗi thư mục đó là một tập hợp các tập tin
mô tả cổng song song đó.

Cây thư mục ZZ0000ZZ trông giống như::

sân bay
	|-- mặc định
	ZZ0004ZZ-- thời gian quay
	|   ZZ0000ZZ-- lp
	ZZ0005ZZ ZZ0001ZZ-- thời gian quay
	ZZ0002ZZ-- ppa
	|       ZZ0003ZZ-- thời gian quay

.. tabularcolumns:: |p{4.0cm}|p{13.5cm}|

====================================================================================
Nội dung tệp
====================================================================================
ZZ0000ZZ Danh sách trình điều khiển thiết bị sử dụng cổng đó.  Một dấu "+"
			sẽ xuất hiện theo tên thiết bị hiện đang sử dụng
			cổng (nó có thể không xuất hiện đối với bất kỳ cổng nào).  các
			chuỗi "không" có nghĩa là không có trình điều khiển thiết bị
			sử dụng cổng đó.

ZZ0000ZZ Địa chỉ cơ sở của cổng song song hoặc địa chỉ nếu cổng
			có nhiều hơn một trong trường hợp đó chúng được tách ra
			với các tab.  Những giá trị này có thể không có bất kỳ ý nghĩa hợp lý nào
			ý nghĩa đối với một số cổng.

ZZ0000ZZ IRQ của cổng song song hoặc -1 nếu không có cổng nào được sử dụng.

ZZ0000ZZ Kênh DMA của cổng song song hoặc -1 nếu không có kênh nào
			đã sử dụng.

ZZ0000ZZ Chế độ phần cứng của cổng song song, được phân tách bằng dấu phẩy,
			ý nghĩa:

-PCSPP
				Có sẵn các thanh ghi SPP kiểu PC.

-TRISTATE
				Cổng là hai chiều.

-COMPAT
				Tăng tốc phần cứng cho máy in là
				sẵn có và sẽ được sử dụng.

-EPP
				Tăng tốc phần cứng cho giao thức EPP
				có sẵn và sẽ được sử dụng.

-ECP
				Tăng tốc phần cứng cho giao thức ECP
				có sẵn và sẽ được sử dụng.

-DMA
				DMA có sẵn và sẽ được sử dụng.

Lưu ý rằng việc triển khai hiện tại sẽ chỉ mất
			lợi thế của chế độ COMPAT và ECP nếu nó có IRQ
			dòng để sử dụng.

ZZ0000ZZ Bất kỳ thông tin ID thiết bị IEEE-1284 nào đã được
			được lấy từ thiết bị (không phải IEEE 1284.3).

ZZ0000ZZ IEEE 1284 thông tin ID thiết bị được lấy từ
			các thiết bị chuỗi nối tiếp phù hợp với IEEE 1284.3.

ZZ0000ZZ Số micro giây cho vòng lặp bận trong khi chờ đợi
			để thiết bị ngoại vi phản hồi.  Bạn có thể tìm thấy điều đó
			việc điều chỉnh điều này sẽ cải thiện hiệu suất, tùy thuộc vào
			thiết bị ngoại vi.  Đây là cài đặt trên toàn cổng, tức là nó
			áp dụng cho tất cả các thiết bị trên một cổng cụ thể.

ZZ0000ZZ Số mili giây mà trình điều khiển thiết bị có
			được phép giữ một cảng được yêu cầu.  Đây là lời khuyên,
			và người lái xe có thể bỏ qua nó nếu cần thiết.

ZZ0000ZZ Giá trị mặc định cho thời gian quay và thời gian. Khi mới
			cổng được đăng ký, nó sẽ chọn thời gian quay mặc định.
			Khi một thiết bị mới được đăng ký, nó sẽ nhận
			khoảng thời gian mặc định.
====================================================================================

Trình điều khiển thiết bị
=========================

Khi mã parport được khởi tạo, bạn có thể đính kèm trình điều khiển thiết bị vào
các cổng cụ thể.  Thông thường điều này xảy ra một cách tự động; nếu trình điều khiển lp
được tải, nó sẽ tạo một thiết bị lp cho mỗi cổng được tìm thấy.  bạn có thể
Tuy nhiên, hãy ghi đè điều này bằng cách sử dụng các tham số khi bạn tải lp
tài xế::

Sân bay # insmod lp=0,2

hoặc trên dòng lệnh LILO ::

lp=parport0 lp=parport2

Cả hai ví dụ trên sẽ thông báo cho lp rằng bạn muốn ZZ0000ZZ trở thành
cổng song song đầu tiên và /dev/lp1 là cổng song song ZZ0003ZZ,
không có thiết bị lp nào được liên kết với cổng thứ hai (parport1).  Lưu ý
rằng điều này khác với cách hoạt động của các hạt nhân cũ hơn; đã từng ở đó
là một liên kết tĩnh giữa địa chỉ cổng I/O và thiết bị
tên, vì vậy ZZ0001ZZ luôn là cổng ở mức 0x3bc.  Đây không còn là
trường hợp - nếu bạn chỉ có một cổng, nó sẽ mặc định là ZZ0002ZZ,
bất kể địa chỉ cơ sở.

Cũng:

* Nếu bạn chọn hỗ trợ IEEE 1284 tại thời điểm biên dịch, bạn có thể nói
   ZZ0000ZZ trên dòng lệnh kernel và lp sẽ tạo các thiết bị
   chỉ dành cho những cổng dường như có gắn máy in.

* Nếu bạn cung cấp cho PLIP tham số ZZ0000ZZ, với ZZ0001ZZ được bật
   dòng lệnh hoặc với ZZ0002ZZ khi sử dụng mô-đun,
   nó sẽ tránh mọi cổng dường như đang được các thiết bị khác sử dụng.

* Tính năng tự động thăm dò IRQ hiện chỉ hoạt động với một số loại cổng.

Báo cáo sự cố máy in với parport
=======================================

Nếu bạn gặp vấn đề khi in, vui lòng thực hiện các bước sau để
cố gắng thu hẹp khu vực có vấn đề.

Khi báo cáo vấn đề với parport, thực sự bạn cần phải cung cấp tất cả
các thông báo mà ZZ0000ZZ đưa ra khi khởi tạo.  có
một số đường dẫn mã:

- bỏ phiếu
- điều khiển ngắt, giao thức trong phần mềm
- giao thức điều khiển ngắt trong phần cứng sử dụng PIO
- giao thức điều khiển ngắt trong phần cứng sử dụng DMA

Các thông báo kernel mà ZZ0000ZZ ghi lại sẽ cho biết thông báo nào
đường dẫn mã đang được sử dụng. (Thực ra họ có thể tốt hơn rất nhiều ..)

Đối với giao thức máy in thông thường, có bật chế độ IEEE 1284 hay không
không nên tạo ra sự khác biệt.

Để tắt đường dẫn mã 'giao thức trong phần cứng', hãy tắt
ZZ0000ZZ.  Lưu ý rằng khi chúng được kích hoạt, chúng sẽ không
nhất thiết phải là ZZ0001ZZ; nó phụ thuộc vào việc phần cứng có sẵn hay không,
được kích hoạt bởi BIOS và được trình điều khiển phát hiện.

Vì vậy, để bắt đầu, hãy tắt ZZ0000ZZ và tải ZZ0001ZZ
với ZZ0002ZZ. Xem nếu việc in ấn hoạt động sau đó.  Nó thực sự nên,
vì đây là đường dẫn mã đơn giản nhất.

Nếu cách đó hoạt động tốt, hãy thử với ZZ0000ZZ (điều chỉnh cho phù hợp với bạn
phần cứng), để làm cho nó sử dụng giao thức trong phần mềm điều khiển ngắt.

Nếu ZZ0001ZZ hoạt động tốt thì một trong các chế độ phần cứng không hoạt động
đúng.  Kích hoạt ZZ0000ZZ (không, đây không phải là tùy chọn mô-đun,
và đúng vậy), hãy đặt cổng thành chế độ ECP trong BIOS và lưu ý
kênh DMA và thử với::

io=0x378 irq=7 dma=none (đối với PIO)
    io=0x378 irq=7 dma=3 (đối với DMA)

----------

philb@gnu.org
tim@cyberelk.net
