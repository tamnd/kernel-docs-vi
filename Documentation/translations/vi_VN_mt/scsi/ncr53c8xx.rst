.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/ncr53c8xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Trình điều khiển NCR53C8XX/SYM53C8XX
===========================

Viết bởi Gerard Roudier <groudier@free.fr>

21 Rue Carnot

95170 DEUIL LA BARRE - FRANCE

29 tháng 5 năm 1999

.. Contents:

   1.  Introduction
   2.  Supported chips and SCSI features
   3.  Advantages of the enhanced 896 driver
         3.1 Optimized SCSI SCRIPTS
         3.2 New features of the SYM53C896 (64 bit PCI dual LVD SCSI controller)
   4.  Memory mapped I/O versus normal I/O
   5.  Tagged command queueing
   6.  Parity checking
   7.  Profiling information
   8.  Control commands
         8.1  Set minimum synchronous period
         8.2  Set wide size
         8.3  Set maximum number of concurrent tagged commands
         8.4  Set order type for tagged command
         8.5  Set debug mode
         8.6  Clear profile counters
         8.7  Set flag (no_disc)
         8.8  Set verbose level
         8.9  Reset all logical units of a target
         8.10 Abort all tasks of all logical units of a target
   9.  Configuration parameters
   10. Boot setup commands
         10.1 Syntax
         10.2 Available arguments
                10.2.1  Master parity checking
                10.2.2  Scsi parity checking
                10.2.3  Scsi disconnections
                10.2.4  Special features
                10.2.5  Ultra SCSI support
                10.2.6  Default number of tagged commands
                10.2.7  Default synchronous period factor
                10.2.8  Negotiate synchronous with all devices
                10.2.9  Verbosity level
                10.2.10 Debug mode
                10.2.11 Burst max
                10.2.12 LED support
                10.2.13 Max wide
                10.2.14 Differential mode
                10.2.15 IRQ mode
                10.2.16 Reverse probe
                10.2.17 Fix up PCI configuration space
                10.2.18 Serial NVRAM
                10.2.19 Check SCSI BUS
                10.2.20 Exclude a host from being attached
                10.2.21 Suggest a default SCSI id for hosts
                10.2.22 Enable use of IMMEDIATE ARBITRATION
         10.3 Advised boot setup commands
         10.4 PCI configuration fix-up boot option
         10.5 Serial NVRAM support boot option
         10.6 SCSI BUS checking boot option
         10.7 IMMEDIATE ARBITRATION boot option
   11. Some constants and flags of the ncr53c8xx.h header file
   12. Installation
   13. Architecture dependent features
   14. Known problems
         14.1 Tagged commands with Iomega Jaz device
         14.2 Device names change when another controller is added
         14.3 Using only 8 bit devices with a WIDE SCSI controller.
         14.4 Possible data corruption during a Memory Write and Invalidate
         14.5 IRQ sharing problems
   15. SCSI problem troubleshooting
         15.1 Problem tracking
         15.2 Understanding hardware error reports
   16. Synchronous transfer negotiation tables
         16.1 Synchronous timings for 53C875 and 53C860 Ultra-SCSI controllers
         16.2 Synchronous timings for fast SCSI-2 53C8XX controllers
   17. Serial NVRAM support (by Richard Waltham)
         17.1 Features
         17.2 Symbios NVRAM layout
         17.3 Tekram  NVRAM layout
   18. Support for Big Endian
         18.1 Big Endian CPU
         18.2 NCR chip in Big Endian mode of operations

1. Giới thiệu
===============

Trình điều khiển ncr53c8xx ban đầu của Linux là một cổng của trình điều khiển ncr từ
FreeBSD đã đạt được vào tháng 11 năm 1995 bởi:

- Gerard Roudier <groudier@free.fr>

Trình điều khiển gốc được viết cho 386bsd và FreeBSD bởi:

- Wolfgang Stanglmeier <wolf@cologne.de>
        - Stefan Esser <se@mi.Uni-Koeln.de>

Hiện tại nó có sẵn dưới dạng gói gồm 2 trình điều khiển:

- Trình điều khiển chung ncr53c8xx hỗ trợ tất cả dòng SYM53C8XX bao gồm
  vòng quay 810 sớm nhất. 1, 896 mới nhất (bộ điều khiển LVD SCSI 2 kênh) và
  895A mới (bộ điều khiển LVD SCSI 1 kênh).
- trình điều khiển nâng cao sym53c8xx (còn gọi là trình điều khiển 896) không còn hỗ trợ phiên bản cũ nhất
  chip để tận dụng các tính năng mới, như hướng dẫn LOAD/STORE
  có sẵn kể từ 810A và pha phần cứng không khớp với
  896 và 895A.

Bạn có thể tìm thấy thông tin kỹ thuật về dòng NCR 8xx trong
PCI-HOWTO được viết bởi Michael Will và trong SCSI-HOWTO được viết bởi
Drew Eckhardt.

Thông tin về chip mới có sẵn tại máy chủ web LSILOGIC:

-ZZ0000ZZ

Tài liệu tiêu chuẩn SCSI có sẵn tại máy chủ ftp SYMBIOS:

- ftp://ftp.symbios.com/

Các công cụ SCSI hữu ích do Eric Youngdale viết có sẵn tại tsx-11:

- ftp://tsx-11.mit.edu/pub/linux/ALPHA/scsi/scsiinfo-X.Y.tar.gz
          - ftp://tsx-11.mit.edu/pub/linux/ALPHA/scsi/scsidev-X.Y.tar.gz

Những công cụ này không phải là ALPHA nhưng khá sạch sẽ và hoạt động khá tốt.
Điều cần thiết là bạn phải có gói 'scsiinfo'.

Tài liệu ngắn này mô tả các tính năng chung và nâng cao
trình điều khiển, thông số cấu hình và lệnh điều khiển có sẵn thông qua
các hoạt động đọc / ghi hệ thống tệp Proc SCSI.

Trình điều khiển này đã được thử nghiệm OK với linux/i386, Linux/Alpha và Linux/PPC.

Phiên bản driver và bản vá lỗi mới nhất hiện có tại:

- ftp://ftp.tux.org/pub/people/gerard-roudier

hoặc

- ftp://ftp.symbios.com/mirror/ftp.tux.org/pub/tux/roudier/drivers

Tôi không phải là người nói tiếng Anh bản xứ và có lẽ có rất nhiều
lỗi trong tệp README này. Mọi trợ giúp sẽ được chào đón.


2. Chip được hỗ trợ và tính năng SCSI
====================================

Các tính năng sau được hỗ trợ cho tất cả các chip:

- Đàm phán đồng bộ
	- Ngắt kết nối
	- Xếp hàng lệnh được gắn thẻ
	- Kiểm tra tính chẵn lẻ SCSI
	- Kiểm tra tính chẵn lẻ chính

"Đàm phán rộng rãi" được hỗ trợ cho các chip cho phép điều đó.  các
bảng sau đây cho thấy một số đặc điểm của dòng chip NCR 8xx
và những trình điều khiển nào hỗ trợ chúng.

+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0000ZZ ZZ0001ZZ |            |Được hỗ trợ bởi|Supported by|
|        |OTrên bo mạch ZZ0005ZZ |            |the chung ZZ0007ZZ
ZZ0008ZZSDMS BIOS ZZ0009ZZSCSI tiêu chuẩn.  | Max. sync  |driver ZZ0011ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0012ZZ N ZZ0013ZZ FAST10 ZZ0014ZZ Y ZZ0015ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0016ZZ N ZZ0017ZZ FAST10 ZZ0018ZZ Y ZZ0019ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0020ZZ Y ZZ0021ZZ FAST10 ZZ0022ZZ Y ZZ0023ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0024ZZ Y ZZ0025ZZ FAST10 ZZ0026ZZ Y ZZ0027ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0028ZZ Y ZZ0029ZZ FAST10 ZZ0030ZZ Y ZZ0031ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0032ZZ N ZZ0033ZZ FAST20 ZZ0034ZZ Y ZZ0035ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0036ZZ Y ZZ0037ZZ FAST20 ZZ0038ZZ Y ZZ0039ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0040ZZ Y ZZ0041ZZ FAST20 ZZ0042ZZ Y ZZ0043ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0044ZZ Y ZZ0045ZZ FAST40 ZZ0046ZZ Y ZZ0047ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0048ZZ Y ZZ0049ZZ FAST40 ZZ0050ZZ Y ZZ0051ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0052ZZ Y ZZ0053ZZ FAST40 ZZ0054ZZ Y ZZ0055ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0056ZZ Y ZZ0057ZZ FAST40 ZZ0058ZZ Y ZZ0059ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0060ZZ Y ZZ0061ZZ FAST40 ZZ0062ZZ Y ZZ0063ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0064ZZ Y ZZ0065ZZ FAST80 ZZ0066ZZ N ZZ0067ZZ
+--------+----------+------+----------+-------------+-------------+-------------+
ZZ0068ZZ Y ZZ0069ZZ FAST80 ZZ0070ZZ N ZZ0071ZZ
ZZ0072ZZ ZZ0073ZZ ZZ0074ZZ ZZ0075ZZ
+--------+----------+------+----------+-------------+-------------+-------------+

.. [1] Chip supports 33MHz and 66MHz PCI buses.


Tóm tắt các tính năng được hỗ trợ khác:

:Module: cho phép tải driver
: I/O được ánh xạ bộ nhớ: tăng hiệu suất
:Thông tin hồ sơ: đọc các thao tác từ hệ thống tệp Proc SCSI
:Lệnh điều khiển: ghi các thao tác vào hệ thống tệp Proc SCSI
:Thông tin gỡ lỗi: được ghi vào nhật ký hệ thống (chỉ dành cho chuyên gia)
:Serial NVRAM: Định dạng Symbios và Tekram

- Phân tán / tập hợp
- Chia sẻ ngắt
- Lệnh thiết lập khởi động


3. Ưu điểm của driver 896 nâng cao
========================================

3.1 SCSI SCRIPTS được tối ưu hóa
--------------------------

810A, 825A, 875, 895, 896 và 895A hỗ trợ các hướng dẫn SCSI SCRIPTS mới
được đặt tên là LOAD và STORE cho phép di chuyển tối đa 1 DWORD từ/đến một thanh ghi IO
đến/từ bộ nhớ nhanh hơn nhiều so với lệnh MOVE MEMORY được hỗ trợ
bởi họ 53c7xx và 53c8xx.
Các lệnh LOAD/STORE hỗ trợ địa chỉ tuyệt đối và tương đối DSA
chế độ.  Thay vào đó, SCSI SCRIPTS đã được viết lại hoàn toàn bằng LOAD/STORE
của hướng dẫn MOVE MEMORY.

3.2 Các tính năng mới của SYM53C896 (bộ điều khiển PCI kép LVD SCSI 64 bit)
-----------------------------------------------------------------------

896 và 895A cho phép xử lý bối cảnh không khớp pha từ
SCRIPTS (tránh gián đoạn không khớp pha làm dừng bộ xử lý SCSI
cho đến khi mã C lưu lại ngữ cảnh chuyển).
Việc thực hiện điều này mà không sử dụng hướng dẫn LOAD/STORE sẽ rất khó khăn
và tôi thậm chí còn không muốn thử nó.

Chip 896 hỗ trợ các giao dịch và địa chỉ PCI 64 bit, trong khi
895A hỗ trợ giao dịch PCI 32 bit và địa chỉ 64 bit.
Bộ xử lý SCRIPTS của các chip này không đúng 64 bit mà sử dụng phân khúc
đăng ký bit 32-63. Một tính năng thú vị khác là LOAD/STORE
các lệnh có địa chỉ RAM (8k) trên chip vẫn còn bên trong chip.

Do sử dụng các hướng dẫn LOAD/STORE SCRIPTS, trình điều khiển này không
hỗ trợ các chip sau:

- Bản sửa đổi SYM53C810 < 0x10 (16)
- SYM53C815 tất cả các phiên bản
- Bản sửa đổi SYM53C825 < 0x10 (16)

4. I/O được ánh xạ bộ nhớ so với I/O thông thường
======================================

I/O được ánh xạ bộ nhớ có độ trễ ít hơn I/O thông thường.  Kể từ khi
linux-1.3.x, I/O ánh xạ bộ nhớ được sử dụng thay vì I/O thông thường.  Bộ nhớ
I/O được ánh xạ dường như hoạt động tốt trên hầu hết các cấu hình phần cứng, nhưng
một số bo mạch chủ được thiết kế kém có thể phá vỡ tính năng này.

Tùy chọn cấu hình CONFIG_SCSI_NCR53C8XX_IOMAPPED buộc
driver sử dụng I/O bình thường trong mọi trường hợp.


5. Xếp hàng lệnh được gắn thẻ
==========================

Xếp hàng nhiều lệnh cùng lúc vào một thiết bị cho phép thiết bị thực hiện
tối ưu hóa dựa trên vị trí đầu thực tế và cơ chế của nó
đặc điểm. Tính năng này cũng có thể làm giảm độ trễ lệnh trung bình.
Để thực sự tận dụng được tính năng này, các thiết bị phải có
kích thước bộ đệm hợp lý (Không có phép lạ nào được mong đợi đối với cấp thấp
đĩa cứng có dung lượng 128 KB trở xuống).
Một số thiết bị SCSI đã biết không hỗ trợ xếp hàng lệnh được gắn thẻ đúng cách.
Nói chung, có sẵn các bản sửa đổi chương trình cơ sở khắc phục loại sự cố này.
tại các trang web/ftp của nhà cung cấp tương ứng.
Tất cả những gì tôi có thể nói là các đĩa cứng tôi sử dụng trên máy của mình hoạt động tốt với
trình điều khiển này đã bật tính năng xếp hàng lệnh được gắn thẻ:

-IBM S12 0662
- Conner 1080S
- Atlas lượng tử I
- Atlas lượng tử II

Nếu bộ điều khiển của bạn có NVRAM, bạn có thể định cấu hình tính năng này cho mỗi mục tiêu
từ công cụ thiết lập người dùng. Chương trình Tekram Setup cho phép điều chỉnh
số lượng lệnh xếp hàng tối đa lên tới 32. Cài đặt Symbios chỉ cho phép
để bật hoặc tắt tính năng này.

Số lượng lệnh được gắn thẻ đồng thời tối đa được xếp hàng đợi trên một thiết bị
hiện được đặt thành 8 theo mặc định.  Giá trị này phù hợp với hầu hết SCSI
đĩa.  Với đĩa SCSI lớn (>= 2GB, bộ đệm >= 512KB, thời gian tìm kiếm trung bình
<= 10 ms), sử dụng giá trị lớn hơn có thể mang lại hiệu suất tốt hơn.

Trình điều khiển sym53c8xx hỗ trợ tới 255 lệnh cho mỗi thiết bị và
trình điều khiển ncr53c8xx chung hỗ trợ tối đa 64, nhưng sử dụng nhiều hơn 32 thì
nói chung là không có giá trị, trừ khi bạn đang sử dụng một hoặc nhiều đĩa rất lớn
mảng. Điều đáng chú ý là hầu hết các đĩa cứng gần đây dường như không chấp nhận
hơn 64 lệnh đồng thời. Vì vậy, sử dụng hơn 64 lệnh xếp hàng đợi
có lẽ chỉ là lãng phí tài nguyên.

Nếu bộ điều khiển của bạn không có NVRAM hoặc nếu nó được quản lý bởi SDMS
BIOS/SETUP, bạn có thể định cấu hình tính năng xếp hàng được gắn thẻ và hàng đợi thiết bị
độ sâu từ dòng lệnh khởi động. Ví dụ::

ncr53c8xx=thẻ:4/t2t3q15-t4q7/t1u0q32

sẽ đặt độ sâu hàng đợi lệnh được gắn thẻ như sau:

- target 2 tất cả lun trên bộ điều khiển 0 --> 15
- target 3 tất cả lun trên bộ điều khiển 0 --> 15
- target 4 tất cả lun trên bộ điều khiển 0 --> 7
- target 1 lun 0 trên bộ điều khiển 1 --> 32
- tất cả mục tiêu/lun khác --> 4

Trong một số điều kiện đặc biệt, một số phần mềm đĩa SCSI có thể trả về một
Trạng thái QUEUE FULL cho lệnh SCSI. Hành vi này được quản lý bởi
điều khiển bằng cách sử dụng heuristic sau:

- Mỗi lần trạng thái QUEUE FULL được trả về, độ sâu hàng đợi được gắn thẻ sẽ giảm
  với số lượng lệnh bị ngắt kết nối thực tế.

- Cứ 1000 lệnh SCSI hoàn thành thành công, nếu được phép
  giới hạn hiện tại, số lượng lệnh có thể xếp hàng tối đa sẽ tăng lên.

Vì việc tiếp nhận và xử lý trạng thái QUEUE FULL gây lãng phí tài nguyên nên
Theo mặc định, trình điều khiển sẽ thông báo vấn đề này cho người dùng bằng cách chỉ ra thực tế
số lượng lệnh được sử dụng và trạng thái của chúng cũng như quyết định của nó về
thay đổi độ sâu hàng đợi thiết bị.
Phương pháp phỏng đoán được người lái xe sử dụng khi xử lý QUEUE FULL đảm bảo rằng
ảnh hưởng đến màn trình diễn không quá tệ. Bạn có thể loại bỏ các tin nhắn bằng cách
đặt mức chi tiết về 0, như sau:

Phương pháp thứ 1:
	    khởi động hệ thống của bạn bằng tùy chọn 'ncr53c8xx=verb:0'.

Phương pháp thứ 2:
	    áp dụng lệnh điều khiển "setverbose 0" cho mục nhập proc fs
            tương ứng với bộ điều khiển của bạn sau khi khởi động.

6. Kiểm tra tính chẵn lẻ
==================

Trình điều khiển hỗ trợ kiểm tra chẵn lẻ SCSI và kiểm tra chẵn lẻ bus PCI
kiểm tra.  Các tính năng này phải được kích hoạt để đảm bảo dữ liệu an toàn
chuyển khoản.  Tuy nhiên, một số thiết bị hoặc bo mạch chủ bị lỗi sẽ có
vấn đề về tính chẵn lẻ. Bạn có thể vô hiệu hóa tính chẵn lẻ PCI hoặc tính chẵn lẻ SCSI
kiểm tra bằng cách nhập các tùy chọn thích hợp từ dòng lệnh khởi động.
(Xem 10: Lệnh thiết lập khởi động).

7. Thông tin hồ sơ
========================

Thông tin hồ sơ có sẵn thông qua hệ thống tệp Proc SCSI.
Vì việc thu thập thông tin lập hồ sơ có thể ảnh hưởng đến hiệu suất, điều này
tính năng này bị tắt theo mặc định và yêu cầu cấu hình biên dịch
tùy chọn được đặt thành Y.

Thiết bị được liên kết với máy chủ có tên đường dẫn sau::

/proc/scsi/ncr53c8xx/N (N=0,1,2 ....)

Nói chung, chỉ có 1 bo mạch được sử dụng trên cấu hình phần cứng và thiết bị đó là::

/proc/scsi/ncr53c8xx/0

Tuy nhiên, nếu trình điều khiển được tạo dưới dạng mô-đun, số lượng
máy chủ được tăng lên mỗi khi trình điều khiển được tải.

Để hiển thị thông tin hồ sơ, chỉ cần nhập::

mèo /proc/scsi/ncr53c8xx/0

và bạn sẽ nhận được một cái gì đó giống như văn bản sau ::

Thông tin chung:
    Chip NCR53C810, id thiết bị 0x1, id sửa đổi 0x2
    Địa chỉ cổng IO 0x6000, IRQ số 10
    Sử dụng bộ nhớ ánh xạ IO tại địa chỉ ảo 0x282c000
    Thời gian truyền đồng bộ 25, số lệnh tối đa mỗi lun 4
    Thông tin hồ sơ:
    num_trans = 18014
    num_kbyte = 671314
    num_disc = 25763
    num_break = 1673
    num_int = 1685
    num_fly = 18038
    ms_setup = 4940
    ms_data = 369940
    ms_disc = 183090
    ms_post = 1320

Thông tin chung rất dễ hiểu. ID thiết bị và
ID sửa đổi xác định chip SCSI như sau:

======= =========================
Id bản sửa đổi id thiết bị chip
======= =========================
810 0x1 < 0x10
810A 0x1 >= 0x10
815 0x4
825 0x3 < 0x10
860 0x6
825A 0x3 >= 0x10
875 0xf
895 0xc
======= =========================

Thông tin hồ sơ được cập nhật sau khi hoàn thành các lệnh SCSI.
Cấu trúc dữ liệu được phân bổ và về 0 khi bộ điều hợp máy chủ được
đính kèm. Vì vậy, nếu trình điều khiển là một mô-đun, bộ đếm hồ sơ sẽ là
được xóa mỗi lần tải trình điều khiển.  Lệnh "clearprof"
cho phép bạn xóa các quầy này bất cứ lúc nào.

Có sẵn các bộ đếm sau:

Tiền tố ("num" có nghĩa là "số lượng",
"ms" có nghĩa là mili giây)

num_trans
	Số lệnh đã hoàn thành
	Ví dụ trên: 18014 lệnh đã hoàn thành

num_kbyte
	Số kbyte được chuyển
	Ví dụ trên: 671 MB đã được chuyển

num_disc
	Số lần ngắt kết nối SCSI
	Ví dụ trên: 25763 ngắt kết nối SCSI

num_break
	số lần gián đoạn tập lệnh (pha không khớp)
	Ví dụ trên: 1673 đoạn script bị gián đoạn

số_int
	Số lần ngắt không phải là "đang di chuyển"
	Ví dụ trên: 1685 gián đoạn không phải "đang hoạt động"

số_bay
	Số lần ngắt "đang di chuyển"
	Ví dụ trên: 18038 gián đoạn "đang hoạt động"

ms_setup
	Thời gian đã trôi qua để thiết lập lệnh SCSI
	Ví dụ trên: 4,94 giây

dữ liệu ms
	Thời gian đã trôi qua để truyền dữ liệu
	Ví dụ trên: 369,94 giây dành cho truyền dữ liệu

ms_đĩa
	Thời gian đã trôi qua cho việc ngắt kết nối SCSI
	Ví dụ trên: 183,09 giây bị ngắt kết nối

ms_post
	Thời gian đã trôi qua để xử lý bài đăng lệnh
	(thời gian từ trạng thái SCSI nhận đến lệnh gọi hoàn thành lệnh)
	Ví dụ trên: 1,32 giây dành cho xử lý bài đăng

Do đồng hồ hệ thống đếm 1/100 giây nên thời gian "ms_post" có thể
có thể sai.

Trong ví dụ trên, chúng tôi nhận được 18038 ngắt "nhanh chóng" và chỉ
Tập lệnh 1673 thường bị hỏng do ngắt kết nối bên trong một phân đoạn
của danh sách phân tán.


8. Lệnh điều khiển
===================

Các lệnh điều khiển có thể được gửi tới trình điều khiển bằng các thao tác ghi vào
hệ thống tập tin Proc SCSI. Cú pháp lệnh chung là
sau đây::

echo "<động từ> <tham số>" >/proc/scsi/ncr53c8xx/0
      (giả sử số bộ điều khiển là 0)

Sử dụng tham số "all" cho "<target>" với các lệnh bên dưới sẽ
áp dụng cho tất cả các mục tiêu của chuỗi SCSI (ngoại trừ bộ điều khiển).

Các lệnh có sẵn:

8.1 Thiết lập hệ số chu kỳ đồng bộ tối thiểu
-----------------------------------------

setsync <mục tiêu> <hệ số thời gian>

:target: số mục tiêu
    :thời gian: khoảng thời gian đồng bộ tối thiểu.
               Tốc độ tối đa = 1000/(hệ số chu kỳ 4*) ngoại trừ trường hợp đặc biệt
               trường hợp dưới đây.

Chỉ định khoảng thời gian là 255 để buộc chế độ truyền không đồng bộ.

- 10 nghĩa là thời gian đồng bộ là 25 nano giây
      - 11 nghĩa là thời gian đồng bộ 30 nano giây
      - 12 nghĩa là thời gian đồng bộ là 50 nano giây

8.2 Đặt kích thước rộng
-----------------

toàn bộ <mục tiêu> <kích thước>

:target: số mục tiêu
    :kích thước: 0=8 bit, 1=16bit

8.3 Đặt số lượng lệnh được gắn thẻ đồng thời tối đa
----------------------------------------------------

thẻ cài đặt <mục tiêu> <thẻ>

:target: số mục tiêu
    :tags: số lệnh được gắn thẻ đồng thời
               không được lớn hơn SCSI_NCR_MAX_TAGS (mặc định: 8)

8.4 Đặt loại lệnh cho lệnh được gắn thẻ
-------------------------------------

đặt hàng <đặt hàng>

:order: 3 giá trị có thể:

đơn giản:
			sử dụng SIMPLE TAG cho mọi thao tác (đọc và ghi)

ra lệnh:
			sử dụng ORDERED TAG cho mọi hoạt động

mặc định:
			sử dụng loại thẻ mặc định,
                        SIMPLE TAG cho hoạt động đọc
                        ORDERED TAG cho thao tác ghi


8.5 Đặt chế độ gỡ lỗi
------------------

setdebug <danh sách các cờ gỡ lỗi>

Cờ gỡ lỗi có sẵn:

======================================================================
        phân bổ thông tin in về phân bổ bộ nhớ (ccb, lcb)
        hàng đợi in thông tin về các phần chèn vào hàng đợi bắt đầu lệnh
        kết quả in dữ liệu cảm nhận về trạng thái CHECK CONDITION
        thông tin in phân tán về quá trình phân tán
        tập lệnh in thông tin về quá trình liên kết tập lệnh
	thông tin gỡ lỗi tối thiểu được in nhỏ
	thông tin thời gian in thời gian của chip NCR
	thông tin in nego về đàm phán SCSI
	thông tin in giai đoạn về sự gián đoạn của tập lệnh
	======================================================================

Sử dụng "setdebug" không có đối số để đặt lại cờ gỡ lỗi.


8.6 Xóa bộ đếm hồ sơ
--------------------------

rõ ràng

Bộ đếm hồ sơ sẽ tự động bị xóa khi số lượng
    dữ liệu được truyền đạt 1000 GB để tránh tràn.
    Lệnh "clearprof" cho phép bạn xóa các bộ đếm này bất kỳ lúc nào.


8.7 Đặt cờ (no_disc)
----------------------

đặt cờ <mục tiêu> <cờ>

mục tiêu: số mục tiêu

Hiện tại, chỉ có một lá cờ có sẵn:

no_disc: không cho phép mục tiêu ngắt kết nối.

Không chỉ định bất kỳ cờ nào để đặt lại cờ. Ví dụ:

cờ báo 4
      sẽ đặt lại cờ no_disc cho mục tiêu 4, do đó sẽ cho phép nó ngắt kết nối.

đặt cờ tất cả
      sẽ cho phép ngắt kết nối tất cả các thiết bị trên bus SCSI.


8.8 Đặt mức độ dài dòng
---------------------

thiết lập #level

Mức chi tiết mặc định của trình điều khiển là 1. Lệnh này cho phép thay đổi
    mức độ chi tiết của trình điều khiển sau khi khởi động.

8.9 Đặt lại tất cả các đơn vị logic của mục tiêu
---------------------------------------

thiết lập lại <mục tiêu>

:target: số mục tiêu

Trình điều khiển sẽ cố gắng gửi tin nhắn BUS DEVICE RESET đến mục tiêu.
    (Chỉ được hỗ trợ bởi trình điều khiển SYM53C8XX và được cung cấp cho mục đích thử nghiệm)

8.10 Hủy bỏ tất cả nhiệm vụ của tất cả các đơn vị logic của mục tiêu
-----------------------------------------------------

Cleardev <mục tiêu>

:target: số mục tiêu

Trình điều khiển sẽ cố gắng gửi tin nhắn ABORT tới tất cả các đơn vị logic
    của mục tiêu.

(Chỉ được hỗ trợ bởi trình điều khiển SYM53C8XX và được cung cấp cho mục đích thử nghiệm)


9. Thông số cấu hình
===========================

Nếu chương trình cơ sở của tất cả các thiết bị của bạn đủ hoàn hảo, tất cả
các tính năng được trình điều khiển hỗ trợ có thể được kích hoạt khi khởi động.  Tuy nhiên,
nếu chỉ có một lỗi đối với một số tính năng của SCSI, bạn có thể tắt tính năng này
hỗ trợ bởi trình điều khiển tính năng này khi khởi động linux và kích hoạt
tính năng này sau khi khởi động chỉ dành cho những thiết bị hỗ trợ nó một cách an toàn.

CONFIG_SCSI_NCR53C8XX_IOMAPPED (câu trả lời mặc định: n)
    Trả lời "y" nếu bạn nghi ngờ bo mạch chủ của mình không cho phép I/O được ánh xạ bộ nhớ.

Có thể làm chậm hiệu suất một chút.  Tùy chọn này được yêu cầu bởi
    Linux/PPC và được sử dụng bất kể bạn chọn gì ở đây.  Linux/PPC
    không bị giảm hiệu suất với tùy chọn này vì tất cả IO đều là bộ nhớ
    dù sao cũng được lập bản đồ.

CONFIG_SCSI_NCR53C8XX_DEFAULT_TAGS (câu trả lời mặc định: 8)
    Độ sâu hàng đợi lệnh được gắn thẻ mặc định.

CONFIG_SCSI_NCR53C8XX_MAX_TAGS (câu trả lời mặc định: 8)
    Tùy chọn này cho phép bạn chỉ định số lượng lệnh được gắn thẻ tối đa
    có thể được xếp hàng đợi vào một thiết bị. Giá trị được hỗ trợ tối đa là 32.

CONFIG_SCSI_NCR53C8XX_SYNC (câu trả lời mặc định: 5)
    Tùy chọn này cho phép bạn chỉ định tần số tính bằng MHz cho trình điều khiển
    sẽ sử dụng vào lúc khởi động để đàm phán truyền dữ liệu đồng bộ.
    Tần số này có thể được thay đổi sau bằng lệnh điều khiển "setsync".
    0 có nghĩa là "truyền dữ liệu không đồng bộ".

CONFIG_SCSI_NCR53C8XX_FORCE_SYNC_NEGO (câu trả lời mặc định: n)
    Buộc đàm phán đồng bộ cho tất cả các thiết bị SCSI-2.

Một số thiết bị SCSI-2 không báo cáo tính năng này trong byte 7 của yêu cầu
    phản hồi nhưng có hỗ trợ nó đúng cách (ví dụ máy quét TAMARACK).

CONFIG_SCSI_NCR53C8XX_NO_DISCONNECT (câu trả lời mặc định và duy nhất hợp lý: n)
    Nếu bạn nghi ngờ thiết bị của mình không hỗ trợ ngắt kết nối đúng cách,
    bạn có thể trả lời "y". Khi đó, tất cả các thiết bị SCSI sẽ không bao giờ ngắt kết nối bus
    ngay cả khi thực hiện các thao tác SCSI dài.

CONFIG_SCSI_NCR53C8XX_SYMBIOS_COMPAT
    Bo mạch SYMBIOS chính hãng sử dụng đầu ra GPIO0 cho bộ điều khiển LED và GPIO3
    bit làm cờ biểu thị giao diện đơn/kết thúc khác nhau.
    Nếu tất cả bo mạch trong hệ thống của bạn là bo mạch SYMBIOS chính hãng hoặc sử dụng
    BIOS và trình điều khiển từ SYMBIOS, bạn sẽ muốn bật tùy chọn này.

Tùy chọn này phải được bật NOT nếu hệ thống của bạn có ít nhất một 53C8XX
    bo mạch scsi dựa trên BIOS dành riêng cho nhà cung cấp.
    Ví dụ: bộ điều khiển scsi Tekram DC-390/U, DC-390/W và DC-390/F
    sử dụng BIOS dành riêng cho nhà cung cấp và được biết là không sử dụng SYMBIOS tương thích
    Hệ thống dây điện GPIO. Vì vậy, tùy chọn này không được kích hoạt nếu hệ thống của bạn có
    một bảng như vậy được cài đặt.

CONFIG_SCSI_NCR53C8XX_NVRAM_DETECT
    Cho phép hỗ trợ đọc dữ liệu NVRAM nối tiếp trên Symbios và
    một số thẻ tương thích với Symbios và thẻ Tekram DC390W/U/F. Hữu ích cho
    các hệ thống có nhiều bộ điều khiển tương thích Symbios trong đó ít nhất
    một có NVRAM nối tiếp hoặc cho hệ thống có sự kết hợp của Symbios và
    Thẻ Tekram. Cho phép thiết lập thứ tự khởi động của bộ điều hợp máy chủ
    sang thứ gì đó khác với thứ tự mặc định hoặc thứ tự "thăm dò ngược".
    Đồng thời cho phép phân biệt thẻ Symbios và Tekram để
    CONFIG_SCSI_NCR53C8XX_SYMBIOS_COMPAT có thể được đặt trong hệ thống có
    hỗn hợp thẻ Symbios và Tekram để thẻ Symbios có thể sử dụng
    đầy đủ các tính năng của Symbios, vi sai, chốt led, không có
    gây ra sự cố cho (các) thẻ Tekram.

10. Lệnh thiết lập khởi động
=======================

10.1 Cú pháp
-----------

Các lệnh thiết lập có thể được chuyển tới trình điều khiển vào lúc khởi động hoặc dưới dạng
biến chuỗi bằng cách sử dụng 'insmod'.

Lệnh thiết lập khởi động cho trình điều khiển ncr53c8xx (sym53c8xx) bắt đầu bằng
tên trình điều khiển "ncr53c8xx="(sym53c8xx). Trình phân tích cú pháp hạt nhân sẽ mong đợi
một danh sách tùy chọn gồm các số nguyên được phân tách bằng dấu phẩy, theo sau là một tùy chọn
danh sách các chuỗi được phân tách bằng dấu phẩy. Ví dụ về lệnh thiết lập khởi động trong lilo
nhắc nhở::

lilo: linux root=/dev/hda2 ncr53c8xx=tags:4,sync:10,debug:0x200

- kích hoạt các lệnh được gắn thẻ, tối đa 4 lệnh được gắn thẻ được xếp hàng đợi.
- đặt tốc độ đàm phán đồng bộ thành 10 lần chuyển Mega / giây.
- đặt cờ DEBUG_NEGO.

Vì dấu phẩy dường như không được phép khi xác định biến chuỗi bằng cách sử dụng
'insmod', trình điều khiển cũng chấp nhận <dấu cách> làm dấu phân cách tùy chọn.
Lệnh sau sẽ cài đặt mô-đun trình điều khiển với các tùy chọn tương tự như
ở trên::

insmod ncr53c8xx.o ncr53c8xx="tags:4 đồng bộ:10 gỡ lỗi:0x200"

Hiện tại, danh sách số nguyên các đối số sẽ bị trình điều khiển loại bỏ.
Nó sẽ được sử dụng trong tương lai để cho phép thiết lập từng bộ điều khiển.

Mỗi đối số chuỗi phải được chỉ định là "từ khóa:giá trị". Chỉ viết thường
ký tự và chữ số được cho phép.

Trong hệ thống có nhiều bộ điều hợp 53C8xx, insmod sẽ cài đặt
trình điều khiển được chỉ định trên mỗi bộ chuyển đổi. Để loại trừ một chip, hãy sử dụng từ khóa 'excl'.

Chuỗi lệnh::

insmod sym53c8xx sym53c8xx=excl:0x1400
    insmod ncr53c8xx

cài đặt trình điều khiển sym53c8xx trên tất cả các bộ điều hợp ngoại trừ bộ điều hợp ở cổng IO
địa chỉ 0x1400 rồi cài driver ncr53c8xx vào adapter tại IO
địa chỉ cổng 0x1400.


10.2 Đối số có sẵn
------------------------

10.2.1 Kiểm tra tính chẵn lẻ chính
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

====== =========
        đã bật mpar:y
        mpar:n bị vô hiệu hóa
	====== =========

10.2.2 Kiểm tra chẵn lẻ Scsi
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

====== =========
        spar:y đã bật
        spar:n bị vô hiệu hóa
	====== =========

10.2.3 Ngắt kết nối Scsi
^^^^^^^^^^^^^^^^^^^^^^^^^^^

====== =========
        đĩa:y đã được bật
        đĩa:n bị vô hiệu hóa
	====== =========

10.2.4 Tính năng đặc biệt
^^^^^^^^^^^^^^^^^^^^^^^^

Chỉ áp dụng cho bộ điều khiển 810A, 825A, 860, 875 và 895.
   Không có tác dụng với những cái khác.

======= =======================================================
        đã bật specf:y (hoặc 1)
        specf:n (hoặc 0) bị vô hiệu hóa
        specf:3 được bật ngoại trừ Ghi bộ nhớ và không hợp lệ
	======= =======================================================

Thiết lập trình điều khiển mặc định là 'specf:3'. Kết quả là, tùy chọn 'specf:y'
   phải được chỉ định trong lệnh thiết lập khởi động để kích hoạt Memory Write And
   Vô hiệu.

Hỗ trợ 10.2.5 Ultra SCSI
^^^^^^^^^^^^^^^^^^^^^^^^^^

Chỉ áp dụng cho bộ điều khiển 860, 875, 895, 895a, 896, 1010 và 1010_66.
   Không có tác dụng với những cái khác.

======= ===========================
        ultra:n Đã bật tất cả tốc độ cực cao
        siêu:2 Đã bật Ultra2
        cực:1 cực kích hoạt
        ultra:0 Tốc độ cực cao bị vô hiệu hóa
	======= ===========================

10.2.6 Số lượng lệnh được gắn thẻ mặc định
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

==========================================================
        tags:0 (hoặc tags:1 ) hàng đợi lệnh được gắn thẻ bị vô hiệu hóa
        tags:#tags (#tags > 1) đã bật hàng đợi lệnh được gắn thẻ
	==========================================================

#tags sẽ bị cắt bớt thành tham số cấu hình lệnh được xếp hàng đợi tối đa.
  Tùy chọn này cũng cho phép chỉ định độ sâu hàng đợi lệnh cho từng thiết bị
  hỗ trợ xếp hàng lệnh được gắn thẻ.

Ví dụ::

ncr53c8xx=thẻ:10/t2t3q16-t5q24/t1u2q32

sẽ đặt độ sâu hàng đợi của thiết bị như sau:

- bộ điều khiển #0 nhắm mục tiêu #2 và nhắm mục tiêu #3 -> 16 lệnh,
      - bộ điều khiển #0 đích #5 -> 24 lệnh,
      - bộ điều khiển #1 nhắm mục tiêu #1 đơn vị logic #2 -> 32 lệnh,
      - tất cả các đơn vị logic khác (tất cả mục tiêu, tất cả bộ điều khiển) -> 10 lệnh.

10.2.7 Hệ số chu kỳ đồng bộ mặc định
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

============= =============================================================
đồng bộ hóa: 255 bị vô hiệu hóa (chế độ truyền không đồng bộ)
đồng bộ hóa:#factor
	     =======================================================
	     #factor = 10 Ultra-2 SCSI 40 lần chuyển Mega / giây
	     #factor = 11 Ultra-2 SCSI 33 lần chuyển Mega / giây
	     #factor < 25 Ultra SCSI 20 lần truyền Mega / giây
	     #factor < 50 SCSI-2 nhanh
	     =======================================================
============= =============================================================

Trong mọi trường hợp, người lái xe sẽ sử dụng khoảng thời gian chuyển tối thiểu được hỗ trợ bởi
  bộ điều khiển theo loại chip NCR53C8XX.

10.2.8 Đàm phán đồng bộ với tất cả các thiết bị
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
(buộc đồng bộ hóa bắt buộc)

===== ==========
        đã bật fsn:y
        fsn:n bị vô hiệu hóa
        ===== ==========

10.2.9 Mức độ chi tiết
^^^^^^^^^^^^^^^^^^^^^^^

====== ==========
        động từ:0 tối thiểu
        động từ:1 bình thường
        động từ:2 quá nhiều
        ====== ==========

10.2.10 Chế độ gỡ lỗi
^^^^^^^^^^^^^^^^^^

================================================================================
gỡ lỗi: 0 xóa cờ gỡ lỗi
gỡ lỗi:#x đặt cờ gỡ lỗi

#x là một giá trị số nguyên kết hợp các giá trị lũy thừa 2 sau:

============== ======
	    DEBUG_ALLOC 0x1
	    DEBUG_PHASE 0x2
	    DEBUG_POLL 0x4
	    DEBUG_QUEUE 0x8
	    DEBUG_RESULT 0x10
	    DEBUG_SCATTER 0x20
	    DEBUG_SCRIPT 0x40
	    DEBUG_TINY 0x80
	    DEBUG_TIMING 0x100
	    DEBUG_NEGO 0x200
	    DEBUG_TAGS 0x400
	    DEBUG_FREEZE 0x800
	    DEBUG_RESTART 0x1000
	    ============== ======
================================================================================

Bạn có thể chơi an toàn với DEBUG_NEGO. Tuy nhiên, một số cờ này có thể
  tạo ra nhiều thông báo nhật ký hệ thống.

10.2.11 Nổ tối đa
^^^^^^^^^^^^^^^^^

=================================================================================
cụm: 0 cụm bị vô hiệu hóa
cluster:255 nhận độ dài cụm từ cài đặt thanh ghi IO ban đầu.
cụm: Đã bật cụm #x (tối đa 1<<#x chuyển cụm liên tục)

#x là một giá trị nguyên là log cơ số 2 của quá trình truyền cụm
	   tối đa.

NCR53C875 và NCR53C825A hỗ trợ lên tới 128 lần truyền liên tục
	   (#x = 7).

Các chip khác chỉ hỗ trợ tối đa 16 (#x = 4).

Đây là một giá trị tối đa. Trình điều khiển đặt độ dài cụm theo
	   vào chip và id sửa đổi. Theo mặc định trình điều khiển sử dụng tối đa
	   giá trị được hỗ trợ bởi chip.
=================================================================================

Hỗ trợ 10.2.12 LED
^^^^^^^^^^^^^^^^^^^

===== =====================
        led:1 bật hỗ trợ LED
        led:0 tắt hỗ trợ LED
        ===== =====================

Không bật hỗ trợ LED nếu bo mạch scsi của bạn không sử dụng SDMS BIOS.
  (Xem 'Thông số cấu hình')

10.2.13 Chiều rộng tối đa
^^^^^^^^^^^^^^^^

===========================
        rộng: Đã bật 1 scsi rộng
        rộng: 0 scsi rộng bị vô hiệu hóa
        ===========================

Một số bo mạch scsi sử dụng 875 (siêu rộng) và chỉ cung cấp các đầu nối hẹp.
  Nếu bạn đã kết nối một thiết bị rộng bằng cáp 50 chân đến 68 chân
  chuyển đổi, bất kỳ cuộc đàm phán rộng rãi nào được chấp nhận sẽ phá vỡ việc truyền dữ liệu tiếp theo.
  Trong trường hợp như vậy, sử dụng "wide:0" trong lệnh khởi động sẽ hữu ích.

10.2.14 Chế độ vi sai
^^^^^^^^^^^^^^^^^^^^^^^^^

====== ====================================
        diff:0 không bao giờ thiết lập chế độ khác biệt
        diff:1 thiết lập chế độ khác biệt nếu BIOS thiết lập nó
        diff:2 luôn thiết lập chế độ khác biệt
        diff:3 đặt chế độ khác biệt nếu GPIO3 không được đặt
	====== ====================================

Chế độ 10.2.15 IRQ
^^^^^^^^^^^^^^^^

=======================================================================
        irqm:0 luôn mở cống
        irqm:1 giống như cài đặt ban đầu (cài đặt BIOS giả định)
        irqm:2 luôn là cột vật tổ
        Trình điều khiển irqm:0x10 sẽ không sử dụng cờ IRQF_SHARED khi yêu cầu irq
	=======================================================================

(Bit 0x10 và 0x20 có thể được kết hợp với tùy chọn chế độ irq phần cứng)

10.2.16 Đầu dò ngược
^^^^^^^^^^^^^^^^^^^^^

=======================================================================
        revprob:n thăm dò id chip từ cấu hình PCI theo thứ tự sau:
                    810, 815, 820, 860, 875, 885, 895, 896
        revprob:y thăm dò id chip theo thứ tự ngược lại.
	=======================================================================

10.2.17 Sửa không gian cấu hình PCI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
pcifix:<bit tùy chọn>

Các bit tùy chọn có sẵn:

=== =====================================================================
        0x0 Không cố gắng sửa các giá trị thanh ghi không gian cấu hình PCI.
        0x1 Đặt thanh ghi kích thước dòng bộ đệm PCI nếu không được đặt.
        0x2 Đặt bit ghi và vô hiệu hóa trong thanh ghi lệnh PCI.
        0x4 Tăng nếu cần Bộ hẹn giờ độ trễ PCI theo mức tối đa của cụm.
	=== =====================================================================

Sử dụng 'pcifix:7' để cho phép trình điều khiển khắc phục tất cả các tính năng của PCI.

10.2.18 NVRAM nối tiếp
^^^^^^^^^^^^^^^^^^^^

======= =============================================
        nvram:n đừng tìm NVRAM nối tiếp
        bộ điều khiển kiểm tra nvram:y cho NVRAM nối tiếp trên bo mạch
	======= =============================================

(dạng nhị phân thay thế)
        mvram=<tùy chọn bit>

==== =======================================================================
        0x01 tìm NVRAM (tương đương nvram=y)
        0x02 bỏ qua tham số "Thương lượng đồng bộ" NVRAM cho tất cả các thiết bị
        0x04 bỏ qua tham số NVRAM "Thương lượng rộng" cho tất cả các thiết bị
        0x08 bỏ qua thông số NVRAM "Quét khi khởi động" cho tất cả các thiết bị
        0x80 cũng đính kèm bộ điều khiển được đặt thành OFF trong NVRAM (chỉ sym53c8xx)
        ==== =======================================================================

10.2.19 Kiểm tra SCSI BUS
^^^^^^^^^^^^^^^^^^^^^^

buschk:<bit tùy chọn>

Các bit tùy chọn có sẵn:

==== =====================================================
        0x0: Không kiểm tra.
        0x1: Kiểm tra và không gắn bộ điều khiển khi có lỗi.
        0x2: Kiểm tra và chỉ cảnh báo khi có lỗi.
        0x4: Tắt kiểm tra tính toàn vẹn của bus SCSI.
        ==== =====================================================

10.2.20 Loại trừ máy chủ được đính kèm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

loại trừ=<io_address>

Ngăn không cho máy chủ tại một địa chỉ io nhất định được đính kèm.
    Ví dụ: 'ncr53c8xx=excl:0xb400,excl:0xc000' biểu thị cho
    Trình điều khiển ncr53c8xx không đính kèm máy chủ tại địa chỉ 0xb400 và 0xc000.

10.2.21 Đề xuất id SCSI mặc định cho máy chủ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

=========================================================
        Hostid:255 không có id nào được đề xuất.
        Hostid:#x (0 < x < 7) x được đề xuất cho id máy chủ SCSI.
	=========================================================

Nếu id SCSI của máy chủ có sẵn từ NVRAM, trình điều khiển sẽ bỏ qua
    bất kỳ giá trị nào được đề xuất làm tùy chọn khởi động. Mặt khác, nếu một giá trị được đề xuất
    khác với 255 đã được cung cấp thì sẽ sử dụng nó. Nếu không, nó sẽ
    cố gắng suy ra giá trị được đặt trước đó trong phần cứng và giá trị sử dụng
    7 nếu giá trị phần cứng bằng 0.

10.2.22 Cho phép sử dụng IMMEDIATE ARBITRATION
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

(chỉ được hỗ trợ bởi trình điều khiển sym53c8xx. Xem 10.7 để biết thêm chi tiết)

======= =======================================================================
iarb:0 không sử dụng tính năng này.
iarb:#x sử dụng tính năng này theo các trường bit như sau:

======================================================================
	  bit 0 (1) bật IARB mỗi khi bộ khởi tạo được chọn lại
		    khi nó phân xử cho SCSI BUS.
	  (#x >> 4) số lượng cài đặt liên tiếp tối đa của IARB nếu
		    người khởi xướng thắng trọng tài và nó có các lệnh khác
		    để gửi đến một thiết bị.
	  ======================================================================
======= =======================================================================

Khởi động không an toàn
    safe:y tải thiết lập ban đầu giả định không an toàn sau đây

============================================================
  tính chẵn lẻ chính bị vô hiệu hóa mpar:n
  spar kích hoạt tính chẵn lẻ scsi:y
  đĩa không được phép ngắt kết nối:n
  tính năng đặc biệt bị vô hiệu hóa specf:n
  ultra scsi bị vô hiệu hóa ultra:n
  buộc đàm phán đồng bộ hóa bị vô hiệu hóa fsn:n
  đầu dò ngược bị vô hiệu hóa revprob:n
  PCI khắc phục pcifix bị vô hiệu hóa: 0
  nối tiếp NVRAM kích hoạt nvram:y
  mức độ dài dòng 2 động từ:2
  xếp hàng lệnh được gắn thẻ bị vô hiệu hóa:0
  đồng bộ hóa đã vô hiệu hóa đàm phán đồng bộ: 255
  cờ gỡ lỗi không gỡ lỗi: 0
  độ dài cụm từ cài đặt BIOS cụm: 255
  LED hỗ trợ đèn led bị tắt: 0
  hỗ trợ rộng bị vô hiệu hóa rộng:0
  thời gian giải quyết 10 giây giải quyết: 10
  hỗ trợ khác biệt từ cài đặt BIOS khác biệt:1
  chế độ irq từ cài đặt BIOS irqm:1
  SCSI BUS kiểm tra không gắn vào lỗi buschk:1
  trọng tài ngay lập tức bị vô hiệu hóa irb:0
  ============================================================

10.3 Các lệnh thiết lập khởi động được khuyên dùng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Nếu trình điều khiển đã được cấu hình với các tùy chọn mặc định, thì tương đương
thiết lập khởi động là::

ncr53c8xx=mpar:y,spar:y,disc:y,specf:3,fsn:n,ultra:2,fsn:n,revprob:n,verb:1\
             tags:0,đồng bộ:50,gỡ lỗi:0,bùng nổ:7,led:0,rộng:1,giải quyết:2,diff:0,irqm:0

Đối với một đĩa cài đặt hoặc một hệ thống an toàn nhưng không nhanh,
thiết lập khởi động có thể là::

ncr53c8xx=safe:y,mpar:y,disc:y
    ncr53c8xx=an toàn:y,đĩa:y
    ncr53c8xx=safe:y,mpar:y
    ncr53c8xx=an toàn:y

Hệ thống cá nhân của tôi hoạt động hoàn hảo với thiết lập tương đương sau::

ncr53c8xx=mpar:y,spar:y,disc:y,specf:1,fsn:n,ultra:2,fsn:n,revprob:n,verb:1\
             tags:32,đồng bộ:12,gỡ lỗi:0,bùng nổ:7,led:1,rộng:1,giải quyết:2,diff:0,irqm:0

Trình điều khiển in thiết lập thực tế của nó khi mức độ chi tiết là 2. Bạn có thể thử
"ncr53c8xx=verb:2" để nhận thiết lập "tĩnh" của trình điều khiển hoặc thêm "động từ:2"
vào lệnh thiết lập khởi động của bạn để kiểm tra thiết lập thực tế của trình điều khiển
sử dụng.

Tùy chọn khởi động sửa lỗi cấu hình 10.4 PCI
-----------------------------------------

pcifix:<bit tùy chọn>

Các bit tùy chọn có sẵn:

=== ===========================================================
    0x1 Đặt thanh ghi kích thước dòng bộ đệm PCI nếu không được đặt.
    0x2 Đặt bit ghi và vô hiệu hóa trong thanh ghi lệnh PCI.
    === ===========================================================

Sử dụng 'pcifix:3' để cho phép trình điều khiển khắc phục cả hai tính năng của PCI.

Các tùy chọn này chỉ áp dụng cho chip SYMBIOS mới 810A, 825A, 860, 875
và 895 và chỉ được hỗ trợ cho bộ xử lý lớp Pentium và 486.
Bộ xử lý scsi SYMBIOS 53C8XX gần đây có thể sử dụng PCI đọc nhiều
và PCI ghi và vô hiệu hóa các lệnh. Những tính năng này yêu cầu
thanh ghi kích thước dòng bộ đệm phải được đặt chính xác trong cấu hình PCI
không gian của các chip. Mặt khác, chip sẽ sử dụng PCI ghi và
chỉ vô hiệu hóa các lệnh nếu bit tương ứng được đặt thành 1 trong
Thanh ghi lệnh PCI.

Không phải tất cả các bioses PCI đều thiết lập thanh ghi dòng bộ đệm PCI và ghi và ghi PCI
bit vô hiệu trong không gian cấu hình PCI của chip 53C8XX.
Truy cập PCI được tối ưu hóa có thể bị hỏng đối với một số bộ điều khiển bộ nhớ/PCI hoặc
gây ra sự cố với một số bảng PCI.

Bản sửa lỗi này hoạt động hoàn hảo trên hệ thống trước đây của tôi.
(MB Triton HX/53C875/53C810A)
Tôi tự chịu rủi ro khi sử dụng các tùy chọn này như bạn sẽ làm nếu bạn quyết định
sử dụng chúng quá.


10.5 Tùy chọn khởi động hỗ trợ Serial NVRAM
-------------------------------------

======= =============================================
nvram:n đừng tìm NVRAM nối tiếp
bộ điều khiển kiểm tra nvram:y cho NVRAM nối tiếp trên bo mạch
======= =============================================

Tùy chọn này cũng có thể được nhập dưới dạng giá trị thập lục phân cho phép
để kiểm soát thông tin nào người lái xe sẽ nhận được từ NVRAM và những thông tin gì
thông tin nó sẽ bỏ qua.
Để biết chi tiết, xem '17. Hỗ trợ nối tiếp NVRAM'.

Khi tùy chọn này được bật, trình điều khiển sẽ cố gắng phát hiện tất cả các bảng bằng cách sử dụng
một NVRAM nối tiếp. Bộ nhớ này được sử dụng để lưu giữ các thông số thiết lập của người dùng.

Các thông số mà trình điều khiển có thể nhận được từ NVRAM tùy thuộc vào
định dạng dữ liệu được sử dụng, như sau:

+------------------------------+-------------------+--------------+
|                               |Tekram định dạng ZZ0001ZZ
+------------------------------+-------------------+--------------+
ZZ0002ZZ ZZ0003ZZ
+------------------------------+-------------------+--------------+
ZZ0004ZZ và ZZ0005ZZ
+------------------------------+-------------------+--------------+
ZZ0006ZZ và ZZ0007ZZ
+------------------------------+-------------------+--------------+
ZZ0008ZZ và ZZ0009ZZ
+------------------------------+-------------------+--------------+
ZZ0010ZZ và ZZ0011ZZ
+------------------------------+-------------------+--------------+
ZZ0012ZZ
+------------------------------+-------------------+--------------+
ZZ0013ZZ và ZZ0014ZZ
+------------------------------+-------------------+--------------+
ZZ0015ZZ và ZZ0016ZZ
+------------------------------+-------------------+--------------+
ZZ0017ZZ và ZZ0018ZZ
ZZ0019ZZ ZZ0020ZZ
+------------------------------+-------------------+--------------+
ZZ0021ZZ và ZZ0022ZZ
+------------------------------+-------------------+--------------+
ZZ0023ZZ và ZZ0024ZZ
+------------------------------+-------------------+--------------+

Để tăng tốc độ khởi động hệ thống, đối với mỗi thiết bị được cấu hình không có
tùy chọn "quét khi khởi động", trình điều khiển sẽ gây ra lỗi trên
lệnh TEST UNIT READY đầu tiên nhận được cho thiết bị này.

Một số phiên bản SDMS BIOS dường như không thể khởi động sạch với tốc độ rất nhanh
các đĩa cứng. Trong tình huống như vậy, bạn không thể định cấu hình NVRAM bằng
giá trị tham số tối ưu.

Tùy chọn khởi động 'nvram' có thể được nhập ở dạng thập lục phân để
để bỏ qua một số tùy chọn được định cấu hình trong NVRAM, như sau:

mvram=<tùy chọn bit>

==== =======================================================================
      0x01 tìm NVRAM (tương đương nvram=y)
      0x02 bỏ qua tham số "Thương lượng đồng bộ" NVRAM cho tất cả các thiết bị
      0x04 bỏ qua tham số NVRAM "Thương lượng rộng" cho tất cả các thiết bị
      0x08 bỏ qua thông số NVRAM "Quét khi khởi động" cho tất cả các thiết bị
      0x80 cũng đính kèm bộ điều khiển được đặt thành OFF trong NVRAM (chỉ sym53c8xx)
      ==== =======================================================================

Tùy chọn 0x80 chỉ được hỗ trợ bởi trình điều khiển sym53c8xx và bị tắt bởi
mặc định. Kết quả là, theo mặc định (tùy chọn không được đặt), trình điều khiển sym53c8xx
sẽ không đính kèm bộ điều khiển được đặt thành OFF trong NVRAM.

Ncr53c8xx luôn cố gắng gắn tất cả các bộ điều khiển. Tùy chọn 0x80 có
chưa được thêm vào trình điều khiển ncr53c8xx vì nó đã được báo cáo cho
gây nhầm lẫn cho người dùng sử dụng trình điều khiển này từ lâu. Nếu bạn mong muốn một
bộ điều khiển không được gắn bởi trình điều khiển ncr53c8xx khi khởi động Linux, bạn
phải sử dụng tùy chọn khởi động trình điều khiển 'excl'.

10.6 SCSI BUS kiểm tra tùy chọn khởi động.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Khi tùy chọn này được đặt thành giá trị khác 0, trình điều khiển sẽ kiểm tra các dòng SCSI
trạng thái logic, 100 micro giây sau khi xác nhận dòng SCSI RESET.
Trình điều khiển chỉ đọc các dòng SCSI và kiểm tra tất cả các dòng đã đọc FALSE ngoại trừ RESET.
Vì các thiết bị SCSI sẽ giải phóng BUS tối đa 800 nano giây sau SCSI
RESET đã được xác nhận, bất kỳ tín hiệu nào tới TRUE đều có thể chỉ ra sự cố SCSI BUS.
Thật không may, các sự cố SCSI BUS phổ biến sau đây không được phát hiện:

- Chỉ cài đặt 1 thiết bị đầu cuối.
- Thiết bị đầu cuối đặt sai vị trí.
- Thiết bị đầu cuối kém chất lượng.

Mặt khác, cáp kém, thiết bị hỏng, không phù hợp
các thiết bị,... có thể khiến tín hiệu SCSI bị sai khi driver đọc.

Tùy chọn khởi động 10.7 IMMEDIATE ARBITRATION
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Tùy chọn này chỉ được hỗ trợ bởi trình điều khiển SYM53C8XX (không phải bởi NCR53C8XX).

Các chip SYMBIOS 53C8XX có thể phân xử cho SCSI BUS ngay khi chúng
đã phát hiện sự ngắt kết nối dự kiến (BUS FREE PHASE). Đối với quá trình này
để bắt đầu, bit 1 của thanh ghi IO SCNTL1 phải được đặt khi chip
được kết nối với SCSI BUS.

Khi tính năng này được kích hoạt cho kết nối hiện tại, chip sẽ
mọi cơ hội giành chiến thắng trong trọng tài nếu chỉ những thiết bị có mức độ ưu tiên thấp hơn mới được
cạnh tranh cho SCSI BUS. Nhân tiện, khi chip đang sử dụng SCSI id 7,
thì chắc chắn nó sẽ thắng trong cuộc trọng tài SCSI BUS tiếp theo.

Vì không có cách nào để biết thiết bị nào đang cố gắng phân xử cho
BUS, sử dụng tính năng này có thể cực kỳ không công bằng. Vì vậy, bạn không được khuyên
để kích hoạt nó, hoặc cùng lắm là kích hoạt tính năng này đối với trường hợp mất chip
trọng tài trước đó (tùy chọn khởi động 'iarb:1').

Tính năng này có những ưu điểm sau:

a) Cho phép người khởi xướng có ID 7 thắng trọng tài khi họ muốn.
b) Chồng chéo ít nhất 4 micro giây thời gian phân xử với việc thực hiện
   của SCRIPTS xử lý việc kết thúc kết nối hiện tại và điều đó
   bắt đầu công việc tiếp theo.

Hmmm... Nhưng (a) có thể chỉ ngăn các thiết bị khác chọn lại bộ khởi tạo,
và trì hoãn việc truyền dữ liệu hoặc trạng thái/hoàn thành và (b) có thể lãng phí
Băng thông SCSI BUS nếu quá trình thực thi SCRIPTS kéo dài hơn 4 micro giây.

Việc sử dụng IARB cần phải xác định tùy chọn SCSI_NCR_IARB_SUPPORT
tại thời điểm biên dịch và tùy chọn khởi động 'iarb' đã được đặt thành khác 0
giá trị lúc khởi động. Nó không hữu ích cho công việc thực tế nhưng có thể được sử dụng
để nhấn mạnh các thiết bị SCSI hoặc cho một số ứng dụng có thể tận dụng lợi thế của
nó. Nhân tiện, nếu bạn gặp phải những vấn đề tồi tệ như 'ngắt kết nối không mong muốn',
'các lựa chọn lại không hợp lệ', v.v... khi sử dụng IARB khi tải IO nặng, bạn không nên
hãy ngạc nhiên, vì ép ăn bất cứ thứ gì và chặn mông nó ở
cùng một lúc không thể làm việc trong một thời gian dài. :-))


11. Một số hằng số và flag của file header ncr53c8xx.h
===========================================================

Một số trong số này được xác định từ các tham số cấu hình.  Đến
thay đổi "định nghĩa" khác, bạn phải chỉnh sửa tệp tiêu đề.  Chỉ làm điều đó
nếu bạn biết bạn đang làm gì.

SCSI_NCR_SETUP_SPECIAL_FEATURES (mặc định: đã xác định)
	Nếu được xác định, trình điều khiển sẽ kích hoạt một số tính năng đặc biệt theo
	vào chip và id sửa đổi.

Đối với các chip scsi 810A, 860, 825A, 875 và 895, tùy chọn này cho phép
	hỗ trợ các tính năng giúp giảm tải truy cập bộ nhớ và bus PCI
	trong quá trình xử lý truyền scsi: tìm nạp mã op-code liên tục, đọc nhiều lần,
        đọc dòng, tìm nạp trước, dòng bộ đệm, ghi và vô hiệu hóa,
        cụm 128 (chỉ 875), dma fifo lớn (chỉ 875), offset 16 (chỉ 875).
	Có thể thay đổi bằng lệnh thiết lập khởi động sau ::

ncr53c8xx=specf:n

SCSI_NCR_IOMAPPED (mặc định: không được xác định)
	Nếu được xác định, I/O bình thường sẽ bị ép buộc.

SCSI_NCR_SHARE_IRQ (mặc định: đã xác định)
	Nếu được xác định, yêu cầu chia sẻ IRQ.

SCSI_NCR_MAX_TAGS (mặc định: 8)
	Số lượng lệnh được gắn thẻ đồng thời tối đa cho một thiết bị.

Có thể thay đổi bằng "settags <target> <maxtags>"

SCSI_NCR_SETUP_DEFAULT_SYNC (mặc định: 50)
	Hệ số thời gian truyền mà trình điều khiển sẽ sử dụng lúc khởi động để đồng bộ hóa
	đàm phán. 0 có nghĩa là không đồng bộ.

Có thể thay đổi bằng "setsync <target> <yếu tố thời gian>"

SCSI_NCR_SETUP_DEFAULT_TAGS (mặc định: 8)
	Số lượng lệnh được gắn thẻ đồng thời mặc định cho một thiết bị.

< 1 có nghĩa là hàng đợi lệnh được gắn thẻ bị vô hiệu hóa khi khởi động.

SCSI_NCR_ALWAYS_SIMPLE_TAG (mặc định: đã xác định)
	Sử dụng SIMPLE TAG để đọc và ghi lệnh.

Có thể thay đổi bằng "setorder <ordered|simple|default>"

SCSI_NCR_SETUP_DISCONNECTION (mặc định: đã xác định)
	Nếu được xác định, mục tiêu được phép ngắt kết nối.

SCSI_NCR_SETUP_FORCE_SYNC_NEGO (mặc định: không được xác định)
	Nếu được xác định, việc đàm phán đồng bộ sẽ được thử cho tất cả các thiết bị SCSI-2.

Có thể thay đổi bằng "setsync <target> < Period>"

SCSI_NCR_SETUP_MASTER_PARITY (mặc định: đã xác định)
	Nếu được xác định, việc kiểm tra tính chẵn lẻ chính sẽ được bật.

SCSI_NCR_SETUP_SCSI_PARITY (mặc định: đã xác định)
	Nếu được xác định, việc kiểm tra tính chẵn lẻ của SCSI sẽ được bật.

SCSI_NCR_PROFILE_SUPPORT (mặc định: không được xác định)
	Nếu được xác định, thông tin hồ sơ sẽ được thu thập.

SCSI_NCR_MAX_SCATTER (mặc định: 128)
	Kích thước danh sách phân tán của trình điều khiển ccb.

SCSI_NCR_MAX_TARGET (mặc định: 16)
	Số lượng mục tiêu tối đa trên mỗi máy chủ.

SCSI_NCR_MAX_HOST (mặc định: 2)
	Số lượng bộ điều khiển máy chủ tối đa.

SCSI_NCR_SETTLE_TIME (mặc định: 2)
	Số giây trình điều khiển sẽ đợi sau khi thiết lập lại.

SCSI_NCR_TIMEOUT_ALERT (mặc định: 3)
	Nếu lệnh đang chờ xử lý sẽ hết thời gian chờ sau khoảng thời gian này,
	một thẻ có thứ tự được sử dụng cho lệnh tiếp theo.

Tránh thời gian chờ cho các lệnh được gắn thẻ không có thứ tự.

SCSI_NCR_CAN_QUEUE (mặc định: 7*SCSI_NCR_MAX_TAGS)
	Số lượng lệnh tối đa có thể được xếp hàng đợi vào máy chủ.

SCSI_NCR_CMD_PER_LUN (mặc định: SCSI_NCR_MAX_TAGS)
	Số lượng lệnh tối đa được xếp hàng đợi vào máy chủ cho một thiết bị.

SCSI_NCR_SG_TABLESIZE (mặc định: SCSI_NCR_MAX_SCATTER-1)
	Kích thước tối đa của danh sách phân tán/thu thập Linux.

SCSI_NCR_MAX_LUN (mặc định: 8)
	Số LUN tối đa cho mỗi mục tiêu.


12. Cài đặt
================

Trình điều khiển này là một phần của bản phân phối kernel linux.
Các tập tin trình điều khiển được đặt trong thư mục con "drivers/scsi" của
cây nguồn hạt nhân.

Tập tin trình điều khiển::

README.ncr53c8xx : tập tin này
	ChangeLog.ncr53c8xx : nhật ký thay đổi
	ncr53c8xx.h : định nghĩa
	ncr53c8xx.c : mã trình điều khiển

Các phiên bản trình điều khiển mới được cung cấp riêng để cho phép thử nghiệm
những thay đổi và tính năng mới trước khi đưa chúng vào nhân linux
phân phối. URL sau đây cung cấp thông tin mới nhất hiện có
bản vá lỗi:

ftp://ftp.tux.org/pub/people/gerard-roudier/README


13. Tính năng phụ thuộc vào kiến ​​trúc
===================================

<Chưa viết>


14. Các vấn đề đã biết
==================

14.1 Các lệnh được gắn thẻ với thiết bị Iomega Jaz
-------------------------------------------

Tôi chưa thử thiết bị này, tuy nhiên nó đã được báo cáo cho tôi
sau: Thiết bị này có khả năng xếp hàng lệnh được gắn thẻ. Tuy nhiên
trong khi quay lên, nó từ chối các lệnh được gắn thẻ. Hành vi này là
phù hợp với 6.8.2 của thông số kỹ thuật SCSI-2. Hành vi hiện tại của
người lái xe trong tình huống đó không hài lòng. Vì thế không kích hoạt
Xếp hàng lệnh được gắn thẻ cho các thiết bị có khả năng quay xuống.  các
vấn đề khác có thể xuất hiện là thời gian chờ. Cách duy nhất để tránh
thời gian chờ dường như chỉnh sửa linux/drivers/scsi/sd.c và để tăng
giá trị thời gian chờ hiện tại.

14.2 Tên thiết bị thay đổi khi thêm bộ điều khiển khác
---------------------------------------------------------

Khi bạn thêm bộ điều khiển dựa trên chip NCR53C8XX mới vào hệ thống đã có sẵn
có một hoặc nhiều bộ điều khiển thuộc họ này, có thể xảy ra trường hợp lệnh
trình điều khiển đăng ký chúng vào kernel gây ra sự cố do thiết bị
thay đổi tên.
Khi có ít nhất một bộ điều khiển sử dụng NvRAM, SDMS BIOS phiên bản 4 cho phép bạn
xác định thứ tự BIOS sẽ quét các bảng scsi. Người lái xe đính kèm
bộ điều khiển theo thông tin BIOS nếu tùy chọn phát hiện NvRAM được đặt.

Nếu bộ điều khiển của bạn không có NvRAM, bạn có thể:

- Yêu cầu driver thăm dò id chip theo thứ tự ngược với lệnh khởi động
  dòng: ncr53c8xx=revprob:y
- Thực hiện các thay đổi phù hợp trong fstab.
- Sử dụng công cụ 'scsidev' của Eric Youngdale.

14.3 Chỉ sử dụng các thiết bị 8 bit có bộ điều khiển WIDE SCSI
---------------------------------------------------------

Khi chỉ có thiết bị NARROW 8 bit được kết nối với bộ điều khiển WIDE SCSI 16 bit,
bạn phải đảm bảo rằng các đường của phần rộng của SCSI BUS được kéo lên.
Điều này có thể đạt được bằng ENABLING, phần WIDE TERMINATOR của SCSI
thẻ điều khiển.

Bản sửa đổi tài liệu TYAN 1365 1.2 không chính xác về các cài đặt như vậy.
(trang 10, hình 3.3).

14.4 Dữ liệu có thể bị hỏng trong quá trình Ghi bộ nhớ và vô hiệu hóa
------------------------------------------------------------------

Sự cố này được mô tả trong SYMBIOS DEL 397, Mã sản phẩm 69-039241, ITEM 4.

Trong một số tình huống phức tạp, phiên bản chip 53C875 <= 3 có thể khởi động PCI
Viết và vô hiệu hóa lệnh ở ranh giới 4 DWORDS không được căn chỉnh theo dòng bộ đệm.
Điều này chỉ có thể thực hiện được khi Kích thước dòng bộ đệm là 8 DWORDS trở lên.
Các hệ thống Pentium sử dụng kích thước dòng bộ đệm 8 DWORDS và do đó được quan tâm bởi
lỗi chip này, không giống như các hệ thống i486 sử dụng kích thước dòng bộ đệm 4 DWORDS.

Khi tình huống này xảy ra, chip có thể hoàn thành quá trình Ghi và Vô hiệu hóa
lệnh sau khi chỉ điền một phần của dòng bộ đệm cuối cùng liên quan đến
quá trình chuyển giao, khiến dữ liệu bị hỏng phần còn lại của dòng bộ nhớ đệm này.

Không sử dụng Write And Invalidate rõ ràng sẽ loại bỏ được lỗi chip này, và do đó
bây giờ nó là cài đặt mặc định của trình điều khiển.
Tuy nhiên, đối với những người như tôi muốn kích hoạt tính năng này, tôi đã thêm
một phần của giải pháp được đề xuất bởi SYMBIOS. Cách giải quyết này sẽ đặt lại
xử lý logic khi pha DATA IN được nhập và do đó ngăn ngừa lỗi
được kích hoạt cho SCSI MOVE đầu tiên của giai đoạn. Cách giải quyết này
là đủ theo quy định sau:

Cấu trúc dữ liệu nội bộ của trình điều khiển duy nhất lớn hơn 8 DWORDS và
được bộ xử lý SCRIPTS di chuyển là 'Tiêu đề CCB' chứa
bối cảnh của việc chuyển giao SCSI. Cấu trúc dữ liệu này được căn chỉnh trên 8 DWORDS
ranh giới (Kích thước dòng bộ đệm Pentium), và do đó không bị ảnh hưởng bởi lỗi chip này, tại
ít nhất là trên hệ thống Pentium.

Nhưng các điều kiện của lỗi này có thể được đáp ứng khi lệnh đọc SCSI được thực hiện
được thực hiện bằng cách sử dụng bộ đệm 4 DWORDS nhưng không được căn chỉnh theo dòng bộ đệm.
Điều này không thể xảy ra trong Linux khi sử dụng danh sách phân tán/thu thập vì
chúng chỉ đề cập đến bộ đệm hệ thống được căn chỉnh tốt. Vì vậy, một công việc xung quanh
có thể chỉ cần thiết trong Linux khi danh sách phân tán/thu thập không được sử dụng và
khi pha SCSI DATA IN được nhập lại sau khi pha không khớp.

15. Xử lý sự cố SCSI
================================

15.1 Theo dõi vấn đề
---------------------

Hầu hết các sự cố SCSI là do bus SCSI không phù hợp hoặc do lỗi
thiết bị.  Nếu không may bạn gặp vấn đề với SCSI, bạn có thể kiểm tra
những điều sau đây:

- Cáp bus SCSI
- điểm cuối ở cả hai đầu của chuỗi SCSI
- tin nhắn nhật ký hệ thống linux (một số trong số chúng có thể giúp bạn)

Nếu bạn không tìm thấy nguồn gốc của vấn đề, bạn có thể cấu hình
trình điều khiển không có tính năng nào được kích hoạt.

- chỉ truyền dữ liệu không đồng bộ
- các lệnh được gắn thẻ bị vô hiệu hóa
- không được phép ngắt kết nối

Bây giờ, nếu bus SCSI của bạn ổn, hệ thống của bạn có mọi cơ hội hoạt động
với cấu hình an toàn này nhưng hiệu năng sẽ không được tối ưu.

Nếu vẫn không thành công, bạn có thể gửi mô tả sự cố của mình tới
danh sách gửi thư hoặc nhóm tin thích hợp.  Gửi cho tôi một bản sao để
hãy chắc chắn rằng tôi sẽ nhận được nó.  Rõ ràng, một lỗi trong mã trình điều khiển là
có thể.

Địa chỉ email của tôi: Gerard Roudier <groudier@free.fr>

Cho phép ngắt kết nối là điều quan trọng nếu bạn sử dụng nhiều thiết bị trên
bus SCSI của bạn nhưng thường gây ra sự cố với các thiết bị có lỗi.
Truyền dữ liệu đồng bộ làm tăng thông lượng của các thiết bị nhanh như
các đĩa cứng.  Đĩa cứng SCSI tốt có bộ nhớ đệm lớn sẽ có được lợi thế
xếp hàng các lệnh được gắn thẻ.

Cố gắng bật từng tính năng một bằng các lệnh điều khiển.  Ví dụ:

::

echo "setsync all 25" >/proc/scsi/ncr53c8xx/0

Sẽ cho phép đàm phán truyền dữ liệu đồng bộ nhanh chóng cho tất cả các mục tiêu.

::

echo "setflag 3" >/proc/scsi/ncr53c8xx/0

Sẽ đặt lại cờ (no_disc) cho mục tiêu 3 và do đó sẽ cho phép nó ngắt kết nối
Xe buýt SCSI.

::

echo "settags 3 8" >/proc/scsi/ncr53c8xx/0

Sẽ kích hoạt hàng đợi lệnh được gắn thẻ cho mục tiêu 3 nếu thiết bị đó hỗ trợ.

Khi bạn đã tìm thấy thiết bị và tính năng gây ra sự cố, chỉ cần
tắt tính năng đó cho thiết bị đó.

15.2 Hiểu báo cáo lỗi phần cứng
-----------------------------------------

Khi trình điều khiển phát hiện tình trạng lỗi không mong muốn, nó có thể hiển thị thông báo
thông báo theo mẫu sau::

sym53c876-0:1: ERROR (0:48) (1-21-65) (f/95) @ (tập lệnh 7c0:19000000).
    sym53c876-0: tập lệnh cmd = 19000000
    sym53c876-0: regdump: da 10 80 95 47 0f 01 07 75 01 81 21 80 01 09 00.

Một số trường trong thông báo như vậy có thể giúp bạn hiểu nguyên nhân của sự cố
vấn đề như sau::

sym53c876-0:1: ERROR (0:48) (1-21-65) (f/95) @ (tập lệnh 7c0:19000000).
    ............A.........B.C....D.E..F....G.H.......I.....J...K.......

Trường A: số mục tiêu.
  SCSI ID của thiết bị mà bộ điều khiển đang sử dụng vào thời điểm đó
  xảy ra lỗi.

Trường B: Thanh ghi DSTAT io (DMA STATUS)
  ===========================================================================
  Lỗi chẵn lẻ dữ liệu chính bit 0x40 MDPE
             Đã phát hiện lỗi chẵn lẻ dữ liệu trên PCI BUS.
  Lỗi bus bit 0x20 BF
             Đã phát hiện tình trạng lỗi bus PCI
  Đã phát hiện hướng dẫn bất hợp pháp Bit 0x01 IID
             Được thiết lập bởi chip khi phát hiện định dạng Lệnh bất hợp pháp
             với một số điều kiện khiến cho một chỉ dẫn trở thành bất hợp pháp.
  Bit 0x80 DFE Dma Fifo trống
             Bit trạng thái thuần túy không biểu thị lỗi.
  ===========================================================================

Nếu giá trị DSTAT được báo cáo chứa kết hợp MDPE (0x40),
  BF (0x20), thì nguyên nhân có thể là do sự cố PCI BUS.

Trường C: Thanh ghi SIST io (Trạng thái ngắt SCSI)
  ================================================================================
  Bit 0x08 SGE SCSI GROSS ERROR
             Cho biết chip đã phát hiện tình trạng lỗi nghiêm trọng
             trên SCSI BUS ngăn giao thức SCSI hoạt động
             đúng cách.
  Bit 0x04 UDC Ngắt kết nối bất ngờ
             Cho biết thiết bị đã phát hành SCSI BUS khi chip
             đã không mong đợi điều này xảy ra. Một thiết bị có thể hoạt động như vậy
             cho biết bộ khởi tạo SCSI rằng tình trạng lỗi không thể báo cáo được
             sử dụng giao thức SCSI đã xảy ra.
  Bit 0x02 RST SCSI BUS Đặt lại
             Nói chung các mục tiêu SCSI không đặt lại SCSI BUS, mặc dù bất kỳ
             thiết bị trên BUS có thể đặt lại bất kỳ lúc nào.
  Bit 0x01 PAR Chẵn lẻ
             Đã phát hiện lỗi chẵn lẻ SCSI.
  ================================================================================

Trên SCSI BUS bị lỗi, bất kỳ tình trạng lỗi nào trong số SGE (0x08), UDC (0x04) và
  PAR (0x01) có thể được chip phát hiện. Nếu hệ thống SCSI của bạn đôi khi
  gặp tình trạng lỗi như vậy, đặc biệt là SCSI GROSS ERROR, sau đó là SCSI
  Sự cố BUS có thể là nguyên nhân gây ra những lỗi này.

Đối với các trường D, E, F, G và H, bạn có thể xem tệp sym53c8xx_defs.h
có chứa một số nhận xét tối thiểu về các bit thanh ghi IO.

Trường D : Chốt điều khiển đầu ra SOCL Scsi
          Thanh ghi này phản ánh trạng thái của các dòng điều khiển SCSI
          chip muốn lái xe hoặc so sánh với.

Trường E : Dây điều khiển xe buýt SBCL Scsi
          Giá trị thực tế của các dòng điều khiển trên SCSI BUS.

Trường F : Đường dữ liệu bus SBDL Scsi
          Giá trị thực tế của các dòng dữ liệu trên SCSI BUS.

Trường G : Chuyển SXFER SCSI
          Chứa cài đặt Thời gian đồng bộ cho đầu ra và
          phần bù đồng bộ hiện tại (độ lệch 0 có nghĩa là không đồng bộ).

Trường H : Thanh ghi điều khiển SCNTL3 Scsi 3
          Chứa cài đặt các giá trị thời gian cho cả không đồng bộ và
          truyền dữ liệu đồng bộ.

Hiểu biết về các trường I, J, K và dumps đòi hỏi phải có kiến thức tốt về
Tiêu chuẩn SCSI, chức năng lõi chip và cấu trúc dữ liệu trình điều khiển bên trong.
Bạn không bắt buộc phải giải mã và hiểu chúng, trừ khi bạn muốn giúp đỡ
duy trì mã trình điều khiển.

16. Bảng đàm phán chuyển giao đồng bộ
===========================================

Các bảng bên dưới đã được tạo bằng cách gọi thủ tục mà trình điều khiển sử dụng
để tính toán thời gian đàm phán đồng bộ hóa và cài đặt chip.
Bảng đầu tiên tương ứng với chip Ultra 53875 và 53C860 80 MHz
đồng hồ và 5 bộ chia đồng hồ.
Cái thứ hai đã được tính toán bằng cách đặt xung nhịp scsi thành 40 Mhz
và sử dụng 4 bộ chia xung nhịp và do đó áp dụng nhanh cho tất cả các chip NCR53C8XX
Chế độ SCSI-2.

Các khoảng thời gian tính bằng nano giây và tốc độ tính bằng số lần truyền Mega mỗi giây.
1 lần truyền Mega/giây có nghĩa là 1 MB/s với 8 bit SCSI và 2 MB/s với
Rộng16 SCSI.

16.1 Định giờ đồng bộ cho bộ điều khiển 53C895, 53C875 và 53C860 SCSI

+-----------------------------+--------+-------+--------------+
Cài đặt ZZ0000ZZNCR ZZ0001ZZ
+-------+--------+-------------+--------+-------+ |
|Factor |Period |Speed       |Period ZZ0004ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0005ZZ 25 ZZ0006ZZ 25 ZZ0007ZZ (chỉ 53C895)|
+-------+--------+-------------+--------+-------+--------------+
ZZ0008ZZ 30.2 ZZ0009ZZ 31.25 ZZ0010ZZ (chỉ 53C895)|
+-------+--------+-------------+--------+-------+--------------+
ZZ0011ZZ 50 ZZ0012ZZ 50 ZZ0013ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0014ZZ 52 ZZ0015ZZ 62 ZZ0016ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0017ZZ 56 ZZ0018ZZ 62 ZZ0019ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0020ZZ 60 ZZ0021ZZ 62 ZZ0022ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0023ZZ 64 ZZ0024ZZ 75 ZZ0025ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0026ZZ 68 ZZ0027ZZ 75 ZZ0028ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0029ZZ 72 ZZ0030ZZ 75 ZZ0031ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0032ZZ 76 ZZ0033ZZ 87 ZZ0034ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0035ZZ 80 ZZ0036ZZ 87 ZZ0037ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0038ZZ 84 ZZ0039ZZ 87 ZZ0040ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0041ZZ 88 ZZ0042ZZ 93 ZZ0043ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0044ZZ 92 ZZ0045ZZ 93 ZZ0046ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0047ZZ 96 ZZ0048ZZ100 ZZ0049ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0050ZZ100 ZZ0051ZZ100 ZZ0052ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0053ZZ104 ZZ0054ZZ112 ZZ0055ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0056ZZ108 ZZ0057ZZ112 ZZ0058ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0059ZZ112 ZZ0060ZZ112 ZZ0061ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0062ZZ116 ZZ0063ZZ125 ZZ0064ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0065ZZ120 ZZ0066ZZ125 ZZ0067ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0068ZZ124 ZZ0069ZZ125 ZZ0070ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0071ZZ128 ZZ0072ZZ131 ZZ0073ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0074ZZ132 ZZ0075ZZ150 ZZ0076ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0077ZZ136 ZZ0078ZZ150 ZZ0079ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0080ZZ140 ZZ0081ZZ150 ZZ0082ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0083ZZ144 ZZ0084ZZ150 ZZ0085ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0086ZZ148 ZZ0087ZZ150 ZZ0088ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0089ZZ152 ZZ0090ZZ175 ZZ0091ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0092ZZ156 ZZ0093ZZ175 ZZ0094ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0095ZZ160 ZZ0096ZZ175 ZZ0097ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0098ZZ164 ZZ0099ZZ175 ZZ0100ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0101ZZ168 ZZ0102ZZ175 ZZ0103ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0104ZZ172 ZZ0105ZZ175 ZZ0106ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0107ZZ176 ZZ0108ZZ187 ZZ0109ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0110ZZ180 ZZ0111ZZ187 ZZ0112ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0113ZZ184 ZZ0114ZZ187 ZZ0115ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0116ZZ188 ZZ0117ZZ200 ZZ0118ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0119ZZ192 ZZ0120ZZ200 ZZ0121ZZ |
+-------+--------+-------------+--------+-------+--------------+
ZZ0122ZZ196 ZZ0123ZZ200 ZZ0124ZZ |
+-------+--------+-------------+--------+-------+--------------+

16.2 Định giờ đồng bộ cho bộ điều khiển SCSI-2 53C8XX nhanh

+------------------------------------------++---+
Cài đặt ZZ0000ZZNCR |
+-------+--------+-------------+--------+-------+
|Factor |Giai đoạn |Speed       |Giai đoạn ZZ0003ZZ
+-------+--------+-------------+--------+-------+
ZZ0004ZZ100 ZZ0005ZZ100 ZZ0006ZZ
+-------+--------+-------------+--------+-------+
ZZ0007ZZ104 ZZ0008ZZ125 ZZ0009ZZ
+-------+--------+-------------+--------+-------+
ZZ0010ZZ108 ZZ0011ZZ125 ZZ0012ZZ
+-------+--------+-------------+--------+-------+
ZZ0013ZZ112 ZZ0014ZZ125 ZZ0015ZZ
+-------+--------+-------------+--------+-------+
ZZ0016ZZ116 ZZ0017ZZ125 ZZ0018ZZ
+-------+--------+-------------+--------+-------+
ZZ0019ZZ120 ZZ0020ZZ125 ZZ0021ZZ
+-------+--------+-------------+--------+-------+
ZZ0022ZZ124 ZZ0023ZZ125 ZZ0024ZZ
+-------+--------+-------------+--------+-------+
ZZ0025ZZ128 ZZ0026ZZ131 ZZ0027ZZ
+-------+--------+-------------+--------+-------+
ZZ0028ZZ132 ZZ0029ZZ150 ZZ0030ZZ
+-------+--------+-------------+--------+-------+
ZZ0031ZZ136 ZZ0032ZZ150 ZZ0033ZZ
+-------+--------+-------------+--------+-------+
ZZ0034ZZ140 ZZ0035ZZ150 ZZ0036ZZ
+-------+--------+-------------+--------+-------+
ZZ0037ZZ144 ZZ0038ZZ150 ZZ0039ZZ
+-------+--------+-------------+--------+-------+
ZZ0040ZZ148 ZZ0041ZZ150 ZZ0042ZZ
+-------+--------+-------------+--------+-------+
ZZ0043ZZ152 ZZ0044ZZ175 ZZ0045ZZ
+-------+--------+-------------+--------+-------+
ZZ0046ZZ156 ZZ0047ZZ175 ZZ0048ZZ
+-------+--------+-------------+--------+-------+
ZZ0049ZZ160 ZZ0050ZZ175 ZZ0051ZZ
+-------+--------+-------------+--------+-------+
ZZ0052ZZ164 ZZ0053ZZ175 ZZ0054ZZ
+-------+--------+-------------+--------+-------+
ZZ0055ZZ168 ZZ0056ZZ175 ZZ0057ZZ
+-------+--------+-------------+--------+-------+
ZZ0058ZZ172 ZZ0059ZZ175 ZZ0060ZZ
+-------+--------+-------------+--------+-------+
ZZ0061ZZ176 ZZ0062ZZ187 ZZ0063ZZ
+-------+--------+-------------+--------+-------+
ZZ0064ZZ180 ZZ0065ZZ187 ZZ0066ZZ
+-------+--------+-------------+--------+-------+
ZZ0067ZZ184 ZZ0068ZZ187 ZZ0069ZZ
+-------+--------+-------------+--------+-------+
ZZ0070ZZ188 ZZ0071ZZ200 ZZ0072ZZ
+-------+--------+-------------+--------+-------+
ZZ0073ZZ192 ZZ0074ZZ200 ZZ0075ZZ
+-------+--------+-------------+--------+-------+
ZZ0076ZZ196 ZZ0077ZZ200 ZZ0078ZZ
+-------+--------+-------------+--------+-------+


17. Nối tiếp NVRAM
================

(được thêm bởi Richard Waltham: ký túc xá@farsrobt.demon.co.uk)

17.1 Tính năng
-------------

Kích hoạt hỗ trợ NVRAM nối tiếp cho phép phát hiện NVRAM nối tiếp đi kèm
trên Symbios và một số bộ điều hợp máy chủ tương thích với Symbios cũng như bảng Tekram. các
serial NVRAM được Symbios và Tekram sử dụng để lưu giữ các tham số thiết lập cho
bộ điều hợp máy chủ và các ổ đĩa kèm theo của nó.

Symbios NVRAM cũng lưu giữ dữ liệu về thứ tự khởi động của bộ điều hợp máy chủ trong một
hệ thống có nhiều hơn một bộ điều hợp máy chủ. Điều này cho phép thứ tự quét
thẻ dành cho các ổ đĩa được thay đổi từ mặc định được sử dụng trong bộ điều hợp máy chủ
phát hiện.

Điều này có thể được thực hiện ở một mức độ hạn chế vào lúc này bằng cách sử dụng "thăm dò ngược" nhưng
điều này chỉ thay đổi thứ tự phát hiện các loại thẻ khác nhau. các
Cài đặt thứ tự khởi động NVRAM có thể thực hiện việc này cũng như thay đổi thứ tự tương tự
các loại thẻ được quét vào, điều mà "thăm dò ngược" không thể làm được.

Phát hiện bo mạch Tekram sử dụng chip Symbios, DC390W/F/U, có NVRAM
và điều này được sử dụng để phân biệt giữa máy chủ tương thích Symbios và máy chủ Tekram
bộ điều hợp. Điều này được sử dụng để tắt cài đặt "khác biệt" tương thích với Symbios
đặt không chính xác trên bảng Tekram nếu CONFIG_SCSI_53C8XX_SYMBIOS_COMPAT
tham số cấu hình được thiết lập cho phép cả bo mạch Symbios và Tekram có thể hoạt động
được sử dụng cùng với thẻ Symbios bằng cách sử dụng tất cả các tính năng của chúng, bao gồm
hỗ trợ "khác biệt". Hỗ trợ ("led pin" cho thẻ tương thích Symbios có thể vẫn còn
được kích hoạt khi sử dụng thẻ Tekram. Nó không có ích gì cho máy chủ Tekram
bộ điều hợp nhưng cũng không gây ra vấn đề gì.)


17.2 Bố cục Symbios NVRAM
-------------------------

dữ liệu điển hình tại địa chỉ NVRAM 0x100 (53c810a NVRAM)::

00 00
    64 01
    8e 0b

00 30 00 00 00 00 07 00 00 00 00 00 00 00 07 04 10 04 00 00

04 00 0f 00 00 10 00 50 00 00 01 00 00 62
    04 00 03 00 00 10 00 58 00 00 01 00 00 63
    04 00 01 00 00 10 00 48 00 00 01 00 00 61
    00 00 00 00 00 00 00 00 00 00 00 00 00 00

0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00

0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00

00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00

00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00

00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00

fe fe
    00 00
    00 00

Chi tiết bố cục NVRAM

============== ==================
Địa chỉ NVRAM
============== ==================
0x000-0x0ff không được sử dụng
Dữ liệu khởi tạo 0x100-0x26f
0x270-0x7ff không được sử dụng
============== ==================

bố cục chung::

tiêu đề - 6 byte,
        dữ liệu - 356 byte (tổng kiểm tra là tổng byte của dữ liệu này)
        đoạn giới thiệu - 6 byte
                  ---
        tổng cộng 368 byte

bố trí vùng dữ liệu::

thiết lập bộ điều khiển - 20 byte
        cấu hình khởi động - 56 byte (4x14 byte)
        thiết lập thiết bị - 128 byte (16x8 byte)
        không sử dụng (dự phòng?) - 152 byte (19x8 byte)
                             ---
        tổng cộng 356 byte

tiêu đề::

00 00 - ?? điểm bắt đầu
    64 01 - số byte (lsb/msb không bao gồm tiêu đề/đoạn giới thiệu)
    8e 0b - tổng kiểm tra (lsb/msb không bao gồm tiêu đề/đoạn giới thiệu)

thiết lập bộ điều khiển::

00 30 00 00 00 00 07 00 00 00 00 00 00 00 07 04 10 04 00 00
		    ZZ0000ZZ ZZ0001ZZ
		    ZZ0002ZZ |      -- ID máy chủ
		    ZZ0003ZZ |
		    ZZ0004ZZ --Hỗ trợ phương tiện có thể tháo rời
		    ZZ0005ZZ 0x00 = không
		    ZZ0006ZZ 0x01 = Thiết bị có thể khởi động
		    ZZ0007ZZ 0x02 = Tất cả có phương tiện
		    ZZ0008ZZ
		    |      --cờ bit 2
		    |        0x00000001= thứ tự quét hi->thấp
		    |            (mặc định 0x00 - quét ở mức thấp->hi)
			--cờ bit 1
			Kích hoạt lừa đảo 0x00000001
			Kích hoạt tính chẵn lẻ 0x00000010
			0x00000100 thông báo khởi động dài dòng

các byte còn lại không xác định - chúng dường như không thay đổi trong
thiết lập hiện tại cho bất kỳ bộ điều khiển nào.

thiết lập mặc định giống hệt nhau cho 53c810a và 53c875 NVRAM
(Removable Media thêm Symbios BIOS phiên bản 4.09)

cấu hình khởi động

Thứ tự khởi động được đặt theo thứ tự của các thiết bị trong bảng này::

04 00 0f 00 00 10 00 50 00 00 01 00 00 62 -- Bộ điều khiển thứ nhất
    04 00 03 00 00 10 00 58 00 00 01 00 00 63 Bộ điều khiển thứ 2
    04 00 01 00 00 10 00 48 00 00 01 00 00 61 Bộ điều khiển thứ 3
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 Bộ điều khiển thứ 4
	ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
	ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ---- PCI cổng io adr
	ZZ0007ZZ ZZ0008ZZ |         --0x01 init/quét lúc khởi động
	ZZ0009ZZ ZZ0010ZZ --PCI số thiết bị/chức năng (0xdddddfff)
	ZZ0011ZZ ----- ?? ID nhà cung cấp PCI (lsb/msb)
	    ----PCI ID thiết bị (lsb/msb)

?? việc sử dụng dữ liệu này chỉ là phỏng đoán nhưng có vẻ hợp lý

các byte còn lại không xác định - chúng dường như không thay đổi trong
thiết lập hiện tại

thiết lập mặc định giống hệt nhau cho 53c810a và 53c875 NVRAM
--------------------------------------------------------

thiết lập thiết bị (tối đa 16 thiết bị - bao gồm bộ điều khiển)::

0f 00 08 08 64 00 0a 00 - id 0
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00

0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00
    0f 00 08 08 64 00 0a 00 - id 15
    ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
    ZZ0003ZZ ZZ0004ZZ ---- hết thời gian chờ (lsb/msb)
    ZZ0005ZZ |   --thời gian đồng bộ (0x?? 40 Mtrans/giây- nhanh 40) (có thể là 0x28)
    ZZ0006ZZ |                  (0x30 20 Mtrans/giây-nhanh 20)
    ZZ0007ZZ |                  (0x64 10 Mtrans/giây-nhanh)
    ZZ0008ZZ |                  (0xc8 5 Mtrans/giây)
    ZZ0009ZZ |                  (0x00 không đồng bộ)
    ZZ0010ZZ -- ?? độ lệch đồng bộ tối đa (0x08 trong NVRAM trên 53c810a)
    ZZ0011ZZ (0x10 trong NVRAM trên 53c875)
    |      --chiều rộng bus thiết bị (hẹp 0x08)
    |                         (0x10 rộng 16 bit)
    --bit cờ
	0x00000001 - đã bật ngắt kết nối
	0x00000010 - quét khi khởi động
	0x00000100 - quét lun
	0x00001000 - đã bật thẻ hàng đợi

các byte còn lại không xác định - chúng dường như không thay đổi trong
thiết lập hiện tại

?? việc sử dụng dữ liệu này chỉ là phỏng đoán nhưng có vẻ hợp lý
(nhưng nó có thể là chiều rộng bus tối đa)

thiết lập mặc định cho 53c810a NVRAM
thiết lập mặc định cho 53c875 NVRAM

- chiều rộng xe buýt - 0x10
                                - bù đồng bộ? - 0x10
                                - thời gian đồng bộ hóa - 0x30

?? không gian thiết bị dự phòng (bus 32 bit ??)

::

00 00 00 00 00 00 00 00 (19x8byte)
    .
    .
    00 00 00 00 00 00 00 00

thiết lập mặc định giống hệt nhau cho 53c810a và 53c875 NVRAM
--------------------------------------------------------

đoạn phim giới thiệu::

fe fe - ? điểm đánh dấu kết thúc?
    00 00
    00 00

thiết lập mặc định giống hệt nhau cho 53c810a và 53c875 NVRAM
-----------------------------------------------------------



Bố cục 17.3 Tekram NVRAM
------------------------

nvram 64x16 (1024bit)

Cài đặt ổ đĩa::

ID ổ đĩa 0-15 (addr 0x0yyyy0 = thiết lập thiết bị, yyyy = ID)
		(thêm 0x0yyyy1 = 0x0000)

x x x x x x x x x x x x x x x
		ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ |
		ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ----- kiểm tra chẵn lẻ 0 - tắt
		ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ 1 - bật
		ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ
		ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ |  ------- đồng bộ phủ định 0 - tắt
		ZZ0019ZZ ZZ0020ZZ ZZ0021ZZ |                         1 - trên
		ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ |
		ZZ0025ZZ ZZ0026ZZ ZZ0027ZZ --------- ngắt kết nối 0 - tắt
		ZZ0028ZZ ZZ0029ZZ ZZ0030ZZ 1 - bật
		ZZ0031ZZ ZZ0032ZZ ZZ0033ZZ
		ZZ0034ZZ ZZ0035ZZ |   ----------- bắt đầu cmd 0 - tắt
		ZZ0036ZZ ZZ0037ZZ |                              1 - trên
		ZZ0038ZZ ZZ0039ZZ |
		ZZ0040ZZ ZZ0041ZZ -------------- được gắn thẻ cmds 0 - tắt
		ZZ0042ZZ ZZ0043ZZ 1 - bật
		ZZ0044ZZ ZZ0045ZZ
		ZZ0046ZZ |       ---------------- rộng âm 0 - tắt
		ZZ0047ZZ |                                       1 - trên
		ZZ0048ZZ |
		    --------------------------- tốc độ đồng bộ 0 - 10,0 Mtrans/giây
							    1 - 8,0
							    2 - 6,6
							    3 - 5,7
							    4 - 5,0
							    5 - 4.0
							    6 - 3.0
							    7 - 2.0
							    7 - 2.0
							    8 - 20,0
							    9 - 16.7
							    một - 13,9
							    b - 11.9

Cài đặt chung

Cờ máy chủ 0 (addr 0x100000, 32)::

x x x x x x x x x x x x x x x
    ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ
    ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ ----------- ID máy chủ 0x00 - 0x0f
    ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ
    ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ |  -------------- hỗ trợ 0 - tắt
    ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ |                          > 2 ổ 1 - bật
    ZZ0020ZZ ZZ0021ZZ ZZ0022ZZ |
    ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ ------------------------- hỗ trợ ổ đĩa 0 - tắt
    ZZ0026ZZ ZZ0027ZZ ZZ0028ZZ > 1Gbyte 1 - bật
    ZZ0029ZZ ZZ0030ZZ ZZ0031ZZ
    ZZ0032ZZ ZZ0033ZZ |  --------------------------- thiết lập lại xe buýt trên 0 - tắt
    ZZ0034ZZ ZZ0035ZZ |                                bật nguồn 1 - bật
    ZZ0036ZZ ZZ0037ZZ |
    ZZ0038ZZ ZZ0039ZZ ----------------------------- hoạt động phủ định 0 - tắt
    ZZ0040ZZ ZZ0041ZZ 1 - bật
    ZZ0042ZZ ZZ0043ZZ
    ZZ0044ZZ |  -------------------------------- tôi đang tìm kiếm 0 - tắt
    ZZ0045ZZ |                                                  1 - trên
    ZZ0046ZZ |
    ZZ0047ZZ ---------------------------------- quét luns 0 - tắt
    ZZ0048ZZ 1 - bật
    ZZ0049ZZ
     -------------------------------------- có thể tháo rời 0 - tắt
                                            như BIOS dev 1 - thiết bị khởi động
                                                           2 - tất cả

Cờ máy chủ 1 (addr 0x100001, 33)::

x x x x x x x x x x x x x x x
               ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
               ZZ0003ZZ |              --------- độ trễ khởi động 0 - 3 giây
               ZZ0004ZZ |                                       1 - 5
               ZZ0005ZZ |                                       2 - 10
               ZZ0006ZZ |                                       3 - 20
               ZZ0007ZZ |                                       4 - 30
               ZZ0008ZZ |                                       5 - 60
               ZZ0009ZZ |                                       6 - 120
               ZZ0010ZZ |
                --------------------------- thẻ cmds tối đa 0 - 2
                                                           1 - 4
                                                           2 - 8
                                                           3 - 16
                                                           4 - 32

Cờ máy chủ 2 (addr 0x100010, 34)::

x x x x x x x x x x x x x x x
                                     |
                                      ----- F2/F6 bật 0 - tắt ???
                                                           1 - trên ???

tổng kiểm tra (addr 0x111111)

tổng kiểm tra = 0x1234 - (tổng cộng 0-63)

-----------------------------------------------------------------------------------------

dữ liệu nvram mặc định::

0x0037 0x0000 0x0037 0x0000 0x0037 0x0000 0x0037 0x0000
    0x0037 0x0000 0x0037 0x0000 0x0037 0x0000 0x0037 0x0000
    0x0037 0x0000 0x0037 0x0000 0x0037 0x0000 0x0037 0x0000
    0x0037 0x0000 0x0037 0x0000 0x0037 0x0000 0x0037 0x0000

0x0f07 0x0400 0x0001 0x0000 0x0000 0x0000 0x0000 0x0000
    0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000
    0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000
    0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0xfbbc


18. Hỗ trợ cho Big Endian
==========================

Bus cục bộ PCI được thiết kế chủ yếu cho kiến ​​trúc x86.
Do đó, các thiết bị PCI thường mong đợi DWORDS sử dụng ít endian
thứ tự byte.

18.1 CPU lớn cuối cùng
-------------------

Để hỗ trợ chip NCR trên kiến trúc Big Endian, trình điều khiển phải
thực hiện sắp xếp lại byte mỗi khi cần thiết. Tính năng này đã được
được thêm vào trình điều khiển bởi Cort <cort@cs.nmt.edu> và có sẵn trong trình điều khiển
phiên bản 2.5 trở lên. Hiện tại, hỗ trợ của Big Endian chỉ có
đã được thử nghiệm trên Linux/PPC (PowerPC).

Chip 18.2 NCR ở chế độ hoạt động Big Endian
----------------------------------------------

Có thể đọc trong tài liệu SYMBIOS rằng một số chip hỗ trợ đặc biệt
Chế độ Big Endian, trên giấy: 53C815, 53C825A, 53C875, 53C875N, 53C895.
Chế độ hoạt động này không thể lựa chọn bằng phần mềm nhưng cần có tên pin
BigLit được kéo lên. Sử dụng chế độ này, hầu hết việc sắp xếp lại byte sẽ
có thể tránh khi trình điều khiển đang chạy trên Big Endian CPU.
Về lý thuyết, phiên bản trình điều khiển 2.5 cũng đã sẵn sàng cho tính năng này.