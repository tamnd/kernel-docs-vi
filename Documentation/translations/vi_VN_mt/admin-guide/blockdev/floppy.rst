.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/blockdev/floppy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Trình điều khiển đĩa mềm
=============

Danh sách FAQ:
=========

Danh sách FAQ có thể được tìm thấy trong gói fdutils (xem bên dưới) và cả
tại <ZZ0000ZZ


Tùy chọn cấu hình LILO (Người dùng Thinkpad, đọc phần này)
======================================================

Trình điều khiển đĩa mềm được cấu hình bằng tùy chọn 'floppy=' trong
lilo. Tùy chọn này có thể được gõ tại dấu nhắc khởi động hoặc được nhập vào
tập tin cấu hình lilo.

Ví dụ: Nếu kernel của bạn có tên linux-2.6.9, hãy nhập dòng sau
tại dấu nhắc khởi động lilo (nếu bạn có thinkpad)::

đĩa mềm linux-2.6.9=thinkpad

Bạn cũng có thể nhập dòng sau vào /etc/lilo.conf, trong phần mô tả
của linux-2.6.9::

nối thêm = "đĩa mềm=thinkpad"

Một số tùy chọn liên quan đến đĩa mềm có thể được đưa ra, ví dụ::

linux-2.6.9 floppy=đĩa mềm táo bạo=two_fdc
 chắp thêm = "đĩa mềm=đĩa mềm táo bạo=two_fdc"

Nếu bạn đưa ra các tùy chọn cả trong tập tin cấu hình lilo và khi khởi động
dấu nhắc, chuỗi tùy chọn của cả hai vị trí được nối với nhau, lệnh khởi động
các tùy chọn nhắc nhở sắp tới cuối cùng. Đó là lý do tại sao cũng có những lựa chọn để
khôi phục hành vi mặc định.


Tùy chọn cấu hình mô-đun
============================

Nếu bạn sử dụng trình điều khiển đĩa mềm làm mô-đun, hãy sử dụng cú pháp sau::

đĩa mềm modprobe = "<options>"

Ví dụ::

modprobe floppy floppy="tin nhắn omnibook"

Nếu bạn cần bật một số tùy chọn nhất định mỗi khi tải trình điều khiển đĩa mềm,
bạn có thể đặt::

tùy chọn đĩa mềm =="tin nhắn omnibook"

trong tệp cấu hình trong /etc/modprobe.d/.


Các tùy chọn liên quan đến trình điều khiển đĩa mềm là:

đĩa mềm=asus_pci
	Đặt mặt nạ bit để chỉ cho phép các đơn vị 0 và 1. (mặc định)

đĩa mềm=táo bạo
	Báo cho trình điều khiển đĩa mềm biết rằng bạn có bộ điều khiển đĩa mềm hoạt động tốt.
	Điều này cho phép hoạt động hiệu quả hơn và mượt mà hơn, nhưng có thể không hoạt động được.
	một số bộ điều khiển nhất định. Điều này có thể tăng tốc độ hoạt động nhất định.

đĩa mềm=0, táo bạo
	Báo cho trình điều khiển đĩa mềm rằng bộ điều khiển đĩa mềm của bạn nên được sử dụng
	một cách thận trọng.

đĩa mềm=one_fdc
	Báo cho trình điều khiển đĩa mềm rằng bạn chỉ có một bộ điều khiển đĩa mềm.
	(mặc định)

đĩa mềm=two_fdc / đĩa mềm=<địa chỉ>,two_fdc
	Báo cho trình điều khiển đĩa mềm biết rằng bạn có hai bộ điều khiển đĩa mềm.
	Bộ điều khiển đĩa mềm thứ hai được giả định là ở <địa chỉ>.
	Tùy chọn này không cần thiết nếu bộ điều khiển thứ hai ở địa chỉ
	0x370 và nếu bạn sử dụng tùy chọn 'cmos'.

đĩa mềm=thinkpad
	Báo cho trình điều khiển đĩa mềm rằng bạn có Thinkpad. Thinkpad sử dụng một
	quy ước đảo ngược cho dòng thay đổi đĩa.

đĩa mềm=0, thinkpad
	Báo cho trình điều khiển đĩa mềm rằng bạn không có Thinkpad.

đĩa mềm=omnibook / đĩa mềm=gật đầu
	Yêu cầu trình điều khiển đĩa mềm không sử dụng Dma để truyền dữ liệu.
	Điều này cần thiết trên HP Omnibooks, vốn không có tính khả thi
	Kênh DMA cho trình điều khiển đĩa mềm. Tùy chọn này cũng hữu ích
	nếu bạn thường xuyên nhận được thông báo "Không thể phân bổ bộ nhớ DMA".
	Thật vậy, bộ nhớ dma cần phải liên tục trong bộ nhớ vật lý,
	và do đó khó tìm hơn, trong khi các bộ đệm không phải dma có thể
	được phân bổ trong bộ nhớ ảo. Tuy nhiên, tôi khuyên bạn không nên làm điều này nếu
	bạn có FDC không có FIFO (8272A hoặc 82072). 82072A và
	sau này thì ổn. Bạn cũng cần ít nhất 486 để sử dụng gật đầu.
	Nếu bạn sử dụng chế độ gật đầu, tôi khuyên bạn cũng nên đặt FIFO
	ngưỡng 10 hoặc thấp hơn, để giới hạn số lượng dữ liệu
	chuyển giao bị gián đoạn.

Nếu bạn có FIFO có khả năng FDC, trình điều khiển đĩa mềm sẽ tự động
	quay trở lại chế độ không phải DMA nếu không tìm thấy bộ nhớ hỗ trợ DMA.
	Nếu bạn muốn tránh điều này, hãy yêu cầu 'yesdma' một cách rõ ràng.

đĩa mềm=yesdma
	Thông báo cho trình điều khiển đĩa mềm rằng có sẵn kênh DMA khả thi.
	(mặc định)

đĩa mềm=nofifo
	Vô hiệu hóa hoàn toàn FIFO. Điều này là cần thiết nếu bạn nhận được "Bus
	thông báo lỗi trọng tài chính" từ thẻ Ethernet của bạn (hoặc
	từ các thiết bị khác) trong khi truy cập vào đĩa mềm.

đĩa mềm=usefifo
	Kích hoạt FIFO. (mặc định)

đĩa mềm=<ngưỡng>,fifo_deep
	Đặt ngưỡng FIFO. Điều này chủ yếu có liên quan trong DMA
	chế độ. Nếu giá trị này cao hơn, trình điều khiển đĩa mềm sẽ chịu được nhiều
	độ trễ ngắt, nhưng nó gây ra nhiều ngắt hơn (tức là nó
	áp đặt nhiều tải hơn cho phần còn lại của hệ thống). Nếu đây là
	thấp hơn thì độ trễ ngắt cũng sẽ thấp hơn (nhanh hơn
	bộ xử lý). Lợi ích của ngưỡng thấp hơn là ít hơn
	ngắt quãng.

Để điều chỉnh ngưỡng fifo, hãy bật tin nhắn chạy quá/chạy chậm
	sử dụng 'floppycontrol --messages'. Sau đó truy cập vào đĩa mềm
	đĩa. Nếu bạn nhận được số lượng lớn "Over/Underrun - đang thử lại"
	tin nhắn thì ngưỡng fifo quá thấp. Hãy thử với một
	giá trị cao hơn, cho đến khi bạn chỉ thỉnh thoảng nhận được Vượt/Thiếu.
	Bạn nên biên dịch trình điều khiển đĩa mềm thành một mô-đun
	khi thực hiện điều chỉnh này. Thật vậy, nó cho phép thử các cách khác nhau
	giá trị fifo mà không cần khởi động lại máy cho mỗi lần kiểm tra. Lưu ý
	rằng bạn cần thực hiện 'floppycontrol --messages' mỗi khi bạn
	chèn lại mô-đun.

Thông thường, không cần điều chỉnh ngưỡng fifo, vì
	mặc định (0xa) là hợp lý.

đĩa mềm=<ổ>,<loại>,cmos
	Đặt loại CMOS của <drive> thành <type>. Điều này là bắt buộc nếu
	bạn có nhiều hơn hai ổ đĩa mềm (chỉ có thể có hai ổ đĩa
	được mô tả trong CMOS vật lý) hoặc nếu BIOS của bạn sử dụng
	các loại CMOS không chuẩn. Các loại CMOS là:

=======================================
		0 Sử dụng giá trị của CMOS vật lý
		1 5 1/4 đ
		2 5 1/4 HD
		3 3 1/2 đ
		4 3 1/2HD
		5 3 1/2 ED
		6 3 1/2 ED
	       16 không rõ hoặc chưa được cài đặt
	       =======================================

	(Note: there are two valid types for ED drives. This is because 5 was
	initially chosen to represent floppy *tapes*, and 6 for ED drives.
	AMI ignored this, and used 5 for ED drives. That's why the floppy
	driver handles both.)

 floppy=unexpected_interrupts
	Print a warning message when an unexpected interrupt is received.
	(default)

 floppy=no_unexpected_interrupts / floppy=L40SX
	Don't print a message when an unexpected interrupt is received. This
	is needed on IBM L40SX laptops in certain video modes. (There seems
	to be an interaction between video and floppy. The unexpected
	interrupts affect only performance, and can be safely ignored.)

 floppy=broken_dcl
	Don't use the disk change line, but assume that the disk was
	changed whenever the device node is reopened. Needed on some
	boxes where the disk change line is broken or unsupported.
	This should be regarded as a stopgap measure, indeed it makes
	floppy operation less efficient due to unneeded cache
	flushings, and slightly more unreliable. Please verify your
	cable, connection and jumper settings if you have any DCL
	problems. However, some older drives, and also some laptops
	are known not to have a DCL.

 floppy=debug
	Print debugging messages.

 floppy=messages
	Print informational messages for some operations (disk change
	notifications, warnings about over and underruns, and about
	autodetection).

 floppy=silent_dcl_clear
	Uses a less noisy way to clear the disk change line (which
	doesn't involve seeks). Implied by 'daring' option.

 floppy=<nr>,irq
	Sets the floppy IRQ to <nr> instead of 6.

 floppy=<nr>,dma
	Sets the floppy DMA channel to <nr> instead of 2.

 floppy=slow
	Use PS/2 stepping rate::

	   PS/2 floppies have much slower step rates than regular floppies.
	   It's been recommended that take about 1/4 of the default speed
	   in some more extreme cases.


Supporting utilities and additional documentation:
==================================================

Additional parameters of the floppy driver can be configured at
runtime. Utilities which do this can be found in the fdutils package.
This package also contains a new version of mtools which allows to
access high capacity disks (up to 1992K on a high density 3 1/2 disk!).
It also contains additional documentation about the floppy driver.

The latest version can be found at fdutils homepage:

 https://fdutils.linux.lu

The fdutils releases can be found at:

 https://fdutils.linux.lu/download.html

 http://www.tux.org/pub/knaff/fdutils/

 ftp://metalab.unc.edu/pub/Linux/utils/disk-management/

Reporting problems about the floppy driver
==========================================

If you have a question or a bug report about the floppy driver, mail
me at Alain.Knaff@poboxes.com . If you post to Usenet, preferably use
comp.os.linux.hardware. As the volume in these groups is rather high,
be sure to include the word "floppy" (or "FLOPPY") in the subject
line.  If the reported problem happens when mounting floppy disks, be
sure to mention also the type of the filesystem in the subject line.

Be sure to read the FAQ before mailing/posting any bug reports!

Alain

Changelog
=========

10-30-2004 :
		Cleanup, updating, add reference to module configuration.
		James Nelson <james4765@gmail.com>

6-3-2000 :
		Original Document
