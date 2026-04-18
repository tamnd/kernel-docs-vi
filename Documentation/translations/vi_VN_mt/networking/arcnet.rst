.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/arcnet.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
ARCnet
======

:Tác giả: Avery Pennarun <apenwarr@worldvisions.ca>

.. note::

   See also arcnet-hardware.txt in this directory for jumper-setting
   and cabling information if you're like many of us and didn't happen to get a
   manual with your ARCnet card.

Bởi vì dường như không có ai lắng nghe tôi, có lẽ một bài thơ sẽ giúp bạn
chú ý::

Người lái xe này ngày càng béo và lực lưỡng,
		Nhưng con mèo của tôi vẫn tên là Fifi.

Hmm, tôi nghĩ tôi được phép gọi đó là một bài thơ, mặc dù nó chỉ có hai bài thôi.
dòng.  Này, tôi học Khoa học Máy tính, không phải tiếng Anh.  Hãy cho tôi nghỉ ngơi.

Vấn đề là: Tôi REALLY REALLY REALLY REALLY REALLY muốn nghe ý kiến của bạn nếu
bạn kiểm tra điều này và làm cho nó hoạt động.  Hoặc nếu bạn không.  Hoặc bất cứ điều gì.

ARCnet 0.32 ALPHA lần đầu tiên được đưa vào nhân Linux 1.1.80 - đây là
hay đấy, nhưng sau đó ngay cả FEWER mọi người cũng bắt đầu viết thư cho tôi vì họ
thậm chí không phải cài đặt bản vá.  <thở dài>

Thôi nào, hãy là một môn thể thao!  Gửi cho tôi một báo cáo thành công!

(này, nó thậm chí còn hay hơn bài thơ gốc của tôi... bài này đang trở nên tệ hơn!)

----

Đây là các trình điều khiển ARCnet dành cho Linux.

Bản phát hành mới này (2.91) đã được David Woodhouse tổng hợp lại
<dwmw2@infradead.org>, trong nỗ lực dọn dẹp trình điều khiển sau khi thêm hỗ trợ
cho một chipset khác. Bây giờ hỗ trợ chung đã được tách ra khỏi
trình điều khiển chipset riêng lẻ và các tệp nguồn không chứa đầy
#ifdefs! Tôi đã thay đổi tập tin này một chút nhưng vẫn giữ nó ở ngôi thứ nhất từ
Avery, vì tôi không muốn viết lại nó hoàn toàn.

Bản phát hành trước đó là kết quả của nhiều tháng nỗ lực không ngừng nghỉ của tôi
(Avery Pennarun), nhiều báo cáo/sửa lỗi và đề xuất từ người khác, và trong
đặc biệt có rất nhiều thông tin đầu vào và mã hóa từ Tomasz Motylewski.  Bắt đầu với
ARCnet 2.10 ALPHA, hỗ trợ RFC1051 hoàn toàn mới và được cải tiến của Tomasz đã được
bao gồm và dường như đang hoạt động tốt!


.. _arcnet-netdev:

Tôi có thể thảo luận về các trình điều khiển này ở đâu?
-------------------------------------------------------

Các cuộc thảo luận ARCnet diễn ra trên netdev. Chỉ cần gửi email của bạn đến
netdev@vger.kernel.org và đảm bảo Cc: người bảo trì được liệt kê trong
Tiêu đề "ARCNET NETWORK LAYER" của Documentation/process/maintainers.rst.

Trình điều khiển và thông tin khác
----------------------------------

Bạn có thể thử trang ARCNET của tôi trên World Wide Web tại:

ZZ0000ZZ

Ngoài ra, SMC (một trong những công ty sản xuất thẻ ARCnet) có trang WWW mà bạn
có thể quan tâm, bao gồm một số trình điều khiển cho các loại thẻ khác nhau
bao gồm cả ARCnet.  Thử:

ZZ0000ZZ

Performance Technologies tạo ra nhiều phần mềm mạng hỗ trợ
ARCnet:

ZZ0000ZZ hoặc ftp tới ftp.perftech.com.

Novell tạo một ngăn xếp mạng cho DOS bao gồm trình điều khiển ARCnet.  Hãy thử
FTP tới ftp.novell.com.

Bạn có thể lấy bộ sưu tập trình điều khiển gói Crynwr (bao gồm arcether.com,
một cái bạn sẽ muốn sử dụng với thẻ ARCnet) từ
oak.oakland.edu:/simtel/msdos/pktdrvr. Nó sẽ không hoạt động hoàn hảo trên 386+
Tuy nhiên, không có bản vá và cũng không thích nhiều thẻ.  Đã sửa
các phiên bản có sẵn trên trang WWW của tôi hoặc qua e-mail nếu bạn không có WWW
truy cập.


Cài đặt trình điều khiển
------------------------

Tất cả những gì bạn cần làm để cài đặt trình điều khiển là::

tạo cấu hình
		(đảm bảo chọn ARCnet trong các thiết bị mạng
		và ít nhất một trình điều khiển chipset.)
	làm sạch
	tạo zImage

Nếu bạn nhận được gói ARCnet này dưới dạng bản nâng cấp cho trình điều khiển ARCnet trong
kernel hiện tại của bạn, trước tiên bạn cần sao chép arcnet.c qua kernel trong
thư mục linux/drivers/net.

Bạn sẽ biết trình điều khiển đã được cài đặt đúng cách nếu bạn có một số ARCnet
thông báo khi bạn khởi động lại vào nhân Linux mới.

Có bốn tùy chọn chipset:

1. Chipset ARCnet COM90xx tiêu chuẩn.

Đây là thẻ ARCnet thông thường mà bạn có thể có. Đây là lần duy nhất
trình điều khiển chipset sẽ tự động thăm dò nếu không được cho biết thẻ ở đâu.
Nó theo các tùy chọn trên dòng lệnh ::

com90xx=[<io>[,<irq>[,<shmem>]]][,<name>] | <tên>

Nếu bạn tải hỗ trợ chipset dưới dạng mô-đun, các tùy chọn là::

io=<io> irq=<irq> shmem=<shmem> thiết bị=<name>

Để tắt trình thăm dò tự động, chỉ cần chỉ định "com90xx=" trên dòng lệnh kernel.
Để chỉ định tên nhưng cho phép tự động thăm dò, chỉ cần đặt "com90xx=<name>"

2. Chipset ARCnet COM20020.

Đây là chipset mới của SMC có hỗ trợ chế độ lăng nhăng (gói
đánh hơi), thông tin chẩn đoán bổ sung, v.v. Thật không may, không có
phương pháp hợp lý để tự động thăm dò các thẻ này. Bạn phải chỉ định I/O
địa chỉ trên dòng lệnh kernel.

Các tùy chọn dòng lệnh là::

com20020=<io>[,<irq>[,<node_ID>[,backplane[,CKP[,timeout]]]]][,name]

Nếu bạn tải hỗ trợ chipset dưới dạng mô-đun, các tùy chọn là::

io=<io> irq=<irq> nút=<node_ID> bảng nối đa năng=<backplane> clock=<CKP>
 hết thời gian=<thời gian chờ> thiết bị=<tên>

Chipset COM20020 cho phép bạn đặt ID nút trong phần mềm, ghi đè
mặc định vẫn được đặt trong DIP sẽ chuyển mạch trên thẻ. Nếu bạn không có
Bảng dữ liệu COM20020 và bạn không biết ba tùy chọn còn lại đề cập đến điều gì
đến, thì họ sẽ không làm bạn quan tâm - hãy quên họ đi.

3. Chipset ARCnet COM90xx ở chế độ ánh xạ IO.

Điều này cũng sẽ hoạt động với thẻ ARCnet thông thường nhưng không sử dụng thẻ chia sẻ
trí nhớ. Nó hoạt động kém hơn trình điều khiển trên nhưng được cung cấp trong trường hợp
bạn có thẻ không hỗ trợ bộ nhớ dùng chung hoặc (kỳ lạ) trong trường hợp
bạn có quá nhiều thẻ ARCnet trong máy đến nỗi hết khe cắm shmem.
Nếu bạn không cung cấp địa chỉ IO trên dòng lệnh kernel thì trình điều khiển
sẽ không tìm thấy thẻ.

Các tùy chọn dòng lệnh là::

com90io=<io>[,<irq>][,<name>]

Nếu bạn tải hỗ trợ chipset dưới dạng mô-đun, các tùy chọn là:
 io=<io> irq=<irq> thiết bị=<name>

4. Thẻ ARCnet RIM I.

Đây là các chip COM90xx được ánh xạ bộ nhớ _hoàn toàn_. Sự hỗ trợ cho
những thứ này không được thử nghiệm. Nếu bạn có, vui lòng gửi thư cho tác giả thành công
báo cáo. Tất cả các tùy chọn phải được chỉ định, ngoại trừ tên thiết bị.
Tùy chọn dòng lệnh::

arcrimi=<shmem>,<irq>,<node_ID>[,<name>]

Nếu bạn tải hỗ trợ chipset dưới dạng mô-đun, các tùy chọn là::

shmem=<shmem> irq=<irq> nút=<node_ID> thiết bị=<tên>


Hỗ trợ mô-đun có thể tải
------------------------

Cấu hình và xây dựng lại Linux.  Khi được hỏi, hãy trả lời 'm' cho "ARCnet chung
support" và hỗ trợ cho chipset ARCnet của bạn nếu bạn muốn sử dụng
mô-đun có thể tải Bạn cũng có thể nói 'y' với "Hỗ trợ ARCnet chung" và 'm'
để hỗ trợ chipset nếu bạn muốn.

::

tạo cấu hình
	làm sạch
	tạo zImage
	làm mô-đun

Nếu bạn đang sử dụng mô-đun có thể tải, bạn cần sử dụng insmod để tải mô-đun đó và
bạn có thể chỉ định các đặc điểm khác nhau của thẻ của mình bằng lệnh
dòng.  (Trong các phiên bản trình điều khiển gần đây, tính năng tự động thăm dò đáng tin cậy hơn nhiều
và hoạt động như một mô-đun, vì vậy hầu hết những điều này hiện không cần thiết.)

Ví dụ::

cd /usr/src/linux/mô-đun
	insmod arcnet.o
	insmod com90xx.o
	insmod com20020.o io=0x2e0 thiết bị=eth1


Sử dụng trình điều khiển
------------------------

Nếu bạn xây dựng hạt nhân của mình có hỗ trợ ARCnet COM90xx đi kèm, thì hạt nhân đó sẽ
tự động thăm dò thẻ của bạn khi bạn khởi động. Nếu bạn sử dụng một cách khác
trình điều khiển chipset tuân theo kernel, bạn phải cung cấp các tùy chọn cần thiết
trên dòng lệnh kernel, như chi tiết ở trên.

Hãy đọc NET-2-HOWTO và ETHERNET-HOWTO cho Linux; họ nên như vậy
có sẵn nơi bạn chọn trình điều khiển này.  Hãy coi ARCnet của bạn như một
Card Ethernet đã được cải tiến (hoặc bị hỏng, tùy từng trường hợp).

Nhân tiện, hãy nhớ thay đổi tất cả các tham chiếu từ "eth0" thành "arc0" trong
HOWTO.  Hãy nhớ rằng ARCnet không phải là Ethernet "thực sự" và tên thiết bị
là DIFFERENT.


Nhiều thẻ trong một máy tính
------------------------------

Linux hiện đã hỗ trợ khá tốt cho việc này, nhưng vì tôi bận nên
Trình điều khiển ARCnet phần nào bị ảnh hưởng về mặt này. Hỗ trợ COM90xx, nếu
được biên dịch vào kernel, sẽ (cố gắng) tự động phát hiện tất cả các thẻ đã cài đặt.

Nếu bạn có các thẻ khác, có hỗ trợ được biên dịch vào kernel, thì bạn có thể
chỉ cần lặp lại các tùy chọn trên dòng lệnh kernel, ví dụ:::

LILO: linux com20020=0x2e0 com20020=0x380 com90io=0x260

Nếu bạn có hỗ trợ chipset được xây dựng dưới dạng mô-đun có thể tải được thì bạn cần phải
làm một cái gì đó như thế này::

insmod -o arc0 com90xx
	insmod -o arc1 com20020 io=0x2e0
	insmod -o arc2 com90xx

Trình điều khiển ARCnet bây giờ sẽ tự động sắp xếp tên của chúng.


Làm cách nào để nó hoạt động với...?
------------------------------------

NFS:
	Sẽ ổn thôi linux->linux, chỉ cần giả vờ như bạn đang sử dụng thẻ Ethernet.
	oak.oakland.edu:/simtel/msdos/nfs có một số ứng dụng khách DOS thú vị.  Ở đó
	cũng là máy chủ NFS dựa trên DOS có tên SOSS.  Nó không đa nhiệm
	hoàn toàn giống như cách Linux làm (thực ra, nó không đa nhiệm ở AT ALL) nhưng
	bạn không bao giờ biết những gì bạn có thể cần.

Với AmiTCP (và có thể cả các loại khác), bạn có thể cần đặt các thông số sau
	các tùy chọn trong Amiga nfstab của bạn: MD 1024 MR 1024 MW 1024
	(Cảm ơn Christian Gottschling <ferksy@indigo.tng.oche.de>
	cho việc này.)

Có lẽ những điều này đề cập đến kích thước khối dữ liệu/đọc/ghi tối đa của NFS.  tôi
	không biết tại sao các cài đặt mặc định trên Amiga không hoạt động; viết thư cho tôi nếu
	bạn biết nhiều hơn

DOS:
	Nếu bạn đang sử dụng phần mềm miễn phí arcether.com, bạn có thể muốn cài đặt
	bản vá trình điều khiển từ trang web của tôi.  Nó giúp với PC/TCP, và cả
	có thể tải archer nếu hết thời gian quá nhanh trong khi
	khởi tạo.  Trên thực tế, nếu bạn sử dụng nó trên 386+ thì bạn cần REALLY
	bản vá, thực sự.

Windows:
	Xem DOS :) Trumpet Winsock hoạt động tốt với Novell hoặc
	Máy khách Arcether, tất nhiên là giả sử bạn nhớ tải winpkt.

Trình quản lý LAN và Windows dành cho nhóm làm việc:
	Các chương trình này sử dụng các giao thức
	không tương thích với tiêu chuẩn Internet.  Họ cố gắng giả vờ
	các thẻ là Ethernet và gây nhầm lẫn cho mọi người khác trên mạng.

Tuy nhiên, trình điều khiển Linux ARCnet v2.00 trở lên hỗ trợ điều này
	giao thức thông qua thiết bị 'arc0e'.  Xem phần "Đa giao thức
	Hỗ trợ" để biết thêm thông tin.

Bằng cách sử dụng máy chủ và máy khách Samba miễn phí dành cho Linux, giờ đây bạn có thể
	giao diện khá độc đáo với TCP/IP-based WfWg hoặc Lan Manager
	mạng.

Windows95:
	Các công cụ đi kèm với Win95 cho phép bạn sử dụng LANMAN
	trình điều khiển mạng kiểu (NDIS) hoặc trình điều khiển Novell (ODI) để xử lý
	gói ARCnet.  Nếu bạn sử dụng ODI, bạn sẽ cần sử dụng 'arc0'
	thiết bị có Linux.  Nếu bạn sử dụng NDIS thì hãy thử thiết bị 'arc0e'.
	Xem phần "Hỗ trợ đa giao thức" bên dưới nếu bạn cần arc0e,
	bạn hoàn toàn điên rồ và/hoặc bạn cần xây dựng một loại
	mạng lai sử dụng cả hai kiểu đóng gói.

Hệ điều hành/2:
	Tôi được biết nó hoạt động theo Warp Connect với trình điều khiển ARCnet từ
	SMC.  Bạn cần sử dụng giao diện 'arc0e' cho việc này.  Nếu bạn nhận được
	trình điều khiển SMC để hoạt động với nội dung TCP/IP có trong
	Gói thưởng Warp "bình thường", hãy cho tôi biết.

ftp.microsoft.com cũng có ứng dụng khách "Lan Manager for OS/2" phần mềm miễn phí
	nên sử dụng giao thức tương tự như WfWg.  Tôi đã không gặp may mắn
	Tuy nhiên, cài đặt nó dưới Warp.  Xin vui lòng gửi cho tôi bất kỳ kết quả nào.

NetBSD/AmiTCP:
	Chúng sử dụng phiên bản cũ của chuẩn Internet ARCnet
	giao thức (RFC1051) tương thích với trình điều khiển Linux v2.10
	ALPHA trở lên sử dụng thiết bị arc0s. (Xem "ARCnet đa giao thức"
	bên dưới.) ** Các phiên bản mới hơn của NetBSD dường như hỗ trợ RFC1201.


Sử dụng ARCnet đa giao thức
---------------------------

Trình điều khiển ARCnet v2.10 ALPHA hỗ trợ ba giao thức, mỗi giao thức riêng
"thiết bị mạng ảo":

==========================================================================
	giao thức arc0 RFC1201, tiêu chuẩn Internet chính thức vừa được
		tương thích 100% với trình điều khiển TRXNET của Novell.
		Phiên bản 1.00 của trình điều khiển ARCnet được hỗ trợ _chỉ_ cái này
		giao thức.  arc0 là giao thức nhanh nhất trong ba giao thức (đối với
		bất kể lý do gì) và cho phép sử dụng các gói lớn hơn
		bởi vì nó hỗ trợ các hoạt động "tách gói" RFC1201.
		Trừ khi bạn có nhu cầu cụ thể cần sử dụng một giao thức khác,
		Tôi thực sự khuyên bạn nên gắn bó với điều này.

arc0e "Ethernet-Encapsulation" gửi gói qua ARCnet
		thực sự rất giống các gói Ethernet, bao gồm cả
		Địa chỉ phần cứng 6 byte.  Giao thức này tương thích với
		Trình điều khiển NDIS ARCnet của Microsoft, giống như trình điều khiển trong WfWg và
		LANMAN.  Bởi vì MTU của 493 thực sự nhỏ hơn MTU
		một "bắt buộc" bởi TCP/IP (576), có khả năng một số
		hoạt động mạng sẽ không hoạt động đúng.  Linux
		Tuy nhiên, lớp TCP/IP có thể bù trong hầu hết các trường hợp bằng cách
		tự động phân mảnh các gói TCP/IP để tạo thành chúng
		phù hợp.  arc0e cũng hoạt động chậm hơn một chút so với arc0, vì
		lý do vẫn chưa được xác định.  (Có lẽ nó nhỏ hơn
		MTU làm được điều đó.)

arc0s Giao thức RFC1051 "[s]imple" là Internet "trước đây"
		tiêu chuẩn hoàn toàn không tương thích với tiêu chuẩn mới
		tiêu chuẩn.  Tuy nhiên, một số phần mềm ngày nay vẫn tiếp tục
		hỗ trợ tiêu chuẩn cũ (và chỉ tiêu chuẩn cũ)
		bao gồm NetBSD và AmiTCP.  RFC1051 cũng không hỗ trợ
		Việc chia gói của RFC1201 và MTU của 507 vẫn
		nhỏ hơn "yêu cầu" của Internet, vì vậy nó khá
		có thể bạn sẽ gặp phải vấn đề.  Nó cũng chậm hơn
		hơn RFC1201 khoảng 25%, với lý do tương tự như arc0e.

Sự hỗ trợ của arc0 được đóng góp bởi Tomasz Motylewski
		và được tôi sửa đổi phần nào.  Lỗi có lẽ là lỗi của tôi.
	==========================================================================

Bạn có thể chọn không biên dịch arc0e và arc0s vào trình điều khiển nếu muốn -
điều này sẽ giúp bạn tiết kiệm một chút bộ nhớ và tránh nhầm lẫn khi ví dụ. cố gắng
sử dụng nội dung "NFS-root" trong các nhân Linux gần đây.

Các thiết bị arc0e và arc0s được tạo tự động khi bạn lần đầu tiên
ifconfig thiết bị arc0.  Tuy nhiên, để thực sự sử dụng chúng, bạn cũng cần phải
ifconfig các thiết bị ảo khác mà bạn cần.  Có một số cách bạn
có thể thiết lập mạng của bạn sau đó:


1. Giao thức đơn.

Đây là cách đơn giản nhất để cấu hình mạng của bạn: chỉ sử dụng một trong các
   hai giao thức có sẵn.  Như đã đề cập ở trên, bạn nên sử dụng
   chỉ arc0 trừ khi bạn có lý do chính đáng (như một số phần mềm khác, ví dụ:
   WfWg, nó chỉ hoạt động với arc0e).

Nếu bạn chỉ cần arc0, thì các lệnh sau sẽ giúp bạn thực hiện ::

ifconfig arc0 MY.IP.ADD.RESS
	định tuyến thêm MY.IP.ADD.RESS arc0
	tuyến thêm -net SUB.NET.ADD.RESS arc0
	[thêm các tuyến đường địa phương khác tại đây]

Nếu bạn cần arc0e (và chỉ arc0e), thì sẽ hơi khác một chút ::

ifconfig arc0 MY.IP.ADD.RESS
	ifconfig arc0e MY.IP.ADD.RESS
	định tuyến thêm MY.IP.ADD.RESS arc0e
	tuyến thêm -net SUB.NET.ADD.RESS arc0e

arc0s hoạt động tương tự như arc0e.


2. Nhiều giao thức trên cùng một dây.

Bây giờ mọi thứ bắt đầu trở nên khó hiểu.  Để thử nó, bạn có thể cần phải
   có phần điên rồ.  Đây là những gì ZZ0000ZZ đã làm. :) Lưu ý rằng tôi không bao gồm arc0 trong
   mạng gia đình của tôi; Tôi không có máy tính NetBSD hay AmiTCP nào nên tôi chỉ
   sử dụng arc0 trong quá trình thử nghiệm hạn chế.

Tôi có ba máy tính trên mạng gia đình; hai hộp Linux (ưu tiên
   Giao thức RFC1201, vì những lý do được liệt kê ở trên) và một XT không thể chạy
   Linux nhưng thay vào đó lại chạy Microsoft LANMAN Client miễn phí.

Tệ hơn nữa, một trong những máy tính Linux (tự do) còn có modem và hoạt động như
   một bộ định tuyến tới nhà cung cấp Internet của tôi.  Hộp Linux khác (cái nhìn sâu sắc) cũng có
   địa chỉ IP riêng của nó và cần sử dụng quyền tự do làm cổng mặc định.  các
   Tuy nhiên, XT (patience) không có địa chỉ IP Internet riêng và do đó
   Tôi đã gán nó trên một "mạng con riêng tư" (như được xác định bởi RFC1597).

Để bắt đầu, hãy sử dụng một mạng lưới đơn giản chỉ với sự hiểu biết sâu sắc và tự do.
   Cái nhìn sâu sắc cần phải:

- nói chuyện với tự do thông qua giao thức RFC1201 (arc0), vì tôi thích nó
	  nhiều hơn và nó nhanh hơn.
	- sử dụng quyền tự do làm cổng Internet.

Điều đó khá dễ thực hiện.  Thiết lập thông tin chi tiết như thế này::

thông tin chi tiết về ifconfig arc0
	tuyến đường thêm cái nhìn sâu sắc arc0
	Route add Freedom arc0 /* Tôi sẽ sử dụng mạng con ở đây (như tôi đã nói
					trong "giao thức đơn" ở trên),
					nhưng phần còn lại của mạng con
					không may lại nằm ngang qua PPP
					liên kết về tự do, điều này gây nhầm lẫn
					mọi thứ. */
	tuyến đường thêm tự do gw mặc định

Và sự tự do được cấu hình như vậy ::

ifconfig arc0 tự do
	tuyến đường thêm tự do arc0
	tuyến đường thêm cái nhìn sâu sắc arc0
	/* và cổng mặc định được cấu hình bởi pppd */

Tuyệt vời, giờ đây cái nhìn sâu sắc đã nói chuyện trực tiếp với sự tự do trên arc0 và gửi các gói
   vào Internet một cách tự do.  Nếu bạn không biết cách thực hiện những điều trên,
   có lẽ bạn nên ngừng đọc phần này ngay bây giờ vì nó chỉ
   tệ hơn.

Bây giờ, làm cách nào để thêm sự kiên nhẫn vào mạng?  Nó sẽ sử dụng LANMAN
   Client, nghĩa là tôi cần thiết bị arc0e.  Nó cần có khả năng nói chuyện
   đến cả cái nhìn sâu sắc và sự tự do, đồng thời sử dụng tự do như một cửa ngõ vào
   Internet.  (Hãy nhớ rằng kiên nhẫn có một "địa chỉ IP riêng" sẽ không
   làm việc trên Internet; không sao đâu, tôi đã cấu hình giả mạo IP Linux
   tự do cho mạng con này).

Vì vậy hãy kiên nhẫn (nhất thiết phải có; tôi không có số IP nào khác từ
   nhà cung cấp) có địa chỉ IP trên một mạng con khác với mạng tự do và
   cái nhìn sâu sắc, nhưng cần sử dụng quyền tự do như một cổng Internet.  Tệ hơn nữa, hầu hết
   Các chương trình mạng DOS, bao gồm LANMAN, có mạng braindead
   các kế hoạch dựa hoàn toàn vào mặt nạ mạng và một 'cổng mặc định' để
   xác định cách định tuyến các gói.  Điều này có nghĩa là để có được tự do hoặc
   hiểu biết sâu sắc, kiên nhẫn WILL gửi qua cổng mặc định của nó, bất kể
   thực tế là cả sự tự do và cái nhìn sâu sắc (nhờ có thiết bị arc0e)
   có thể hiểu được sự truyền tải trực tiếp.

Tôi bù đắp bằng cách cấp cho tự do một địa chỉ IP bổ sung - bí danh là 'người gác cổng' -
   đó là trên mạng con riêng tư của tôi, cùng mạng con mà sự kiên nhẫn đang có.  tôi
   sau đó xác định người gác cổng là cổng mặc định cho sự kiên nhẫn.

Để định cấu hình quyền tự do (ngoài các lệnh trên)::

người gác cổng ifconfig arc0e
	tuyến đường thêm người gác cổng arc0e
	tuyến đường thêm kiên nhẫn arc0e

Bằng cách này, Freedom sẽ gửi tất cả các gói tin cho kiên nhẫn thông qua arc0e,
   cung cấp địa chỉ IP của nó làm người gác cổng (trên mạng con riêng).  Khi nó
   nói chuyện với cái nhìn sâu sắc hoặc Internet, nó sẽ sử dụng IP Internet "tự do" của nó
   địa chỉ.

Bạn sẽ nhận thấy rằng chúng tôi chưa định cấu hình thiết bị arc0e trên Insight.
   Điều này sẽ hiệu quả, nhưng không thực sự cần thiết và đòi hỏi tôi phải
   chỉ định cái nhìn sâu sắc về một số IP đặc biệt khác từ mạng con riêng tư của tôi.  Kể từ khi
   cả cái nhìn sâu sắc và sự kiên nhẫn đều sử dụng tự do làm cửa ngõ mặc định của họ,
   hai người đã có thể nói chuyện với nhau.

Thật may mắn khi lần đầu tiên tôi sắp xếp mọi việc như thế này (khụ
   ho) vì nó thực sự tiện dụng khi tôi khởi động cái nhìn sâu sắc về DOS.  Ở đó, nó
   chạy ngăn xếp giao thức Novell ODI, chỉ hoạt động với RFC1201 ARCnet.
   Trong chế độ này, cái nhìn sâu sắc sẽ không thể giao tiếp trực tiếp
   hãy kiên nhẫn vì ngăn xếp Novell không tương thích với Microsoft
   Ethernet-Encap.  Không thay đổi bất kỳ cài đặt nào về tự do hay kiên nhẫn, tôi
   chỉ cần đặt tự do làm cổng mặc định để hiểu rõ hơn (hiện có trong DOS,
   nhớ) và tất cả việc chuyển tiếp diễn ra "tự động" giữa hai
   các máy chủ thường không thể giao tiếp được.

Đối với những người thích sơ đồ, tôi đã tạo hai "mạng con ảo" trên
   cùng một dây ARCnet vật lý.  Bạn có thể hình dung nó như thế này::


[RFC1201 NETWORK] [ETHER-ENCAP NETWORK]
      (Mạng con Internet đã đăng ký) (Mạng con riêng RFC1597)

(IP hóa trang)
	  /--------------\ * /--------------\
	  ZZ0000ZZ * ZZ0001ZZ
	  ZZ0002ZZ
	  ZZ0003ZZ ZZ0004ZZ |
	  \-------+-------/ |    * \-------+-------/
		  ZZ0005ZZ |
	       Cái nhìn sâu sắc |                      kiên nhẫn
			   (Internet)



Nó hoạt động: bây giờ thì sao?
------------------------------

Gửi thư sau ZZ0000ZZ. Tốt nhất là mô tả thiết lập của bạn
bao gồm phiên bản trình điều khiển, phiên bản kernel, model thẻ ARCnet, loại CPU, số
của các hệ thống trên mạng của bạn và danh sách phần mềm đang được sử dụng.

Nó không hoạt động: bây giờ thì sao?
------------------------------------

Thực hiện tương tự như trên nhưng cũng bao gồm đầu ra của ifconfig và tuyến đường
lệnh, cũng như bất kỳ mục nhật ký thích hợp nào (tức là bất cứ điều gì bắt đầu
bằng "arcnet:" và đã hiển thị kể từ lần khởi động lại gần đây nhất) trong thư của bạn.

Nếu bạn muốn thử tự mình sửa nó (tôi thực sự khuyên bạn nên gửi thư cho tôi
về vấn đề trước tiên, vì nó có thể đã được giải quyết) bạn có thể
muốn thử một số cấp độ gỡ lỗi có sẵn.  Để thử nghiệm nặng trên
D_DURING trở lên, REALLY sẽ là một ý tưởng hay nếu tiêu diệt daemon klogd của bạn
đầu tiên!  D_DURING hiển thị 4-5 dòng cho mỗi gói được gửi hoặc nhận.  D_TX,
D_RX và D_SKB thực tế là DISPLAY mỗi gói khi nó được gửi hoặc nhận,
rõ ràng là khá lớn.

Bắt đầu với v2.40 ALPHA, quy trình thăm dò tự động đã thay đổi
đáng kể.  Đặc biệt, họ sẽ không cho bạn biết tại sao thẻ không được
được tìm thấy trừ khi bạn bật cờ gỡ lỗi D_INIT_REASONS.

Khi trình điều khiển đang chạy, bạn có thể chạy tập lệnh shell arcdump (có sẵn
từ tôi hoặc trong gói ARCnet đầy đủ, nếu bạn có) với quyền root để liệt kê
nội dung của bộ đệm arcnet bất cứ lúc nào.  Để có ý nghĩa gì cả
này, bạn nên lấy RFC thích hợp. (một số được liệt kê gần đầu
arcnet.c).  arcdump giả sử thẻ của bạn ở mức 0xD0000.  Nếu không, hãy chỉnh sửa
kịch bản.

Bộ đệm 0 và 1 được sử dụng để nhận và Bộ đệm 2 và 3 được sử dụng để gửi.
Bộ đệm bóng bàn được thực hiện theo cả hai cách.

Nếu mức gỡ lỗi của bạn bao gồm D_DURING và bạn đã xác định NOT SLOW_XMIT_COPY,
bộ đệm được xóa về giá trị không đổi 0x42 mỗi lần thẻ được
đặt lại (điều này chỉ xảy ra khi bạn thực hiện cài đặt ifconfig hoặc khi Linux
quyết định rằng trình điều khiển bị hỏng).  Trong quá trình truyền, các phần không được sử dụng của
bộ đệm cũng sẽ bị xóa về 0x42.  Điều này là để dễ hình dung hơn
biết byte nào đang được gói sử dụng.

Bạn có thể thay đổi mức gỡ lỗi mà không cần biên dịch lại kernel bằng cách gõ::

ifconfig arc0 giảm số liệu 1xxx
	/etc/rc.d/rc.inet1

trong đó "xxx" là mức gỡ lỗi bạn muốn.  Ví dụ: "số liệu 1015" sẽ đặt
bạn ở cấp độ gỡ lỗi 15. Cấp độ gỡ lỗi 7 hiện là mặc định.

Lưu ý rằng mức gỡ lỗi là (bắt đầu bằng v1.90 ALPHA) ở dạng nhị phân
sự kết hợp của các cờ gỡ lỗi khác nhau; vì vậy mức độ gỡ lỗi 7 thực sự là 1+2+4 hoặc
D_NORMAL+D_EXTRA+D_INIT.  Để bao gồm D_DURING, bạn sẽ thêm 16 vào đây,
dẫn đến mức gỡ lỗi 23.

Nếu bạn không hiểu điều đó, có lẽ bạn cũng không muốn biết.
Gửi email cho tôi về vấn đề của bạn.


Tôi muốn gửi tiền: làm sao bây giờ?
-----------------------------------

Đi ngủ trưa hay gì đó đi.  Bạn sẽ cảm thấy tốt hơn vào buổi sáng.