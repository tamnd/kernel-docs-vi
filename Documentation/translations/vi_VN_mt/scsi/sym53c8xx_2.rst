.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/sym53c8xx_2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Trình điều khiển SYM-2
======================

Viết bởi Gerard Roudier <groudier@free.fr>

21 Rue Carnot

95170 DEUIL LA BARRE - FRANCE

Được cập nhật bởi Matthew Wilcox <matthew@wil.cx>

2004-10-09

.. Contents

   1.  Introduction
   2.  Supported chips and SCSI features
   3.  Advantages of this driver for newer chips.
         3.1 Optimized SCSI SCRIPTS
         3.2 New features appeared with the SYM53C896
   4.  Memory mapped I/O versus normal I/O
   5.  Tagged command queueing
   6.  Parity checking
   7.  Profiling information
   8.  Control commands
         8.1  Set minimum synchronous period
         8.2  Set wide size
         8.3  Set maximum number of concurrent tagged commands
         8.4  Set debug mode
         8.5  Set flag (no_disc)
         8.6  Set verbose level
         8.7  Reset all logical units of a target
         8.8  Abort all tasks of all logical units of a target
   9.  Configuration parameters
   10. Boot setup commands
         10.1 Syntax
         10.2 Available arguments
                10.2.1  Default number of tagged commands
                10.2.2  Burst max
                10.2.3  LED support
                10.2.4  Differential mode
                10.2.5  IRQ mode
                10.2.6  Check SCSI BUS
                10.2.7  Suggest a default SCSI id for hosts
                10.2.8  Verbosity level
                10.2.9  Debug mode
                10.2.10 Settle delay
                10.2.11 Serial NVRAM
                10.2.12 Exclude a host from being attached
         10.3 Converting from old options
         10.4 SCSI BUS checking boot option
   11. SCSI problem troubleshooting
         15.1 Problem tracking
         15.2 Understanding hardware error reports
   12. Serial NVRAM support (by Richard Waltham)
         17.1 Features
         17.2 Symbios NVRAM layout
         17.3 Tekram  NVRAM layout


1. Giới thiệu
===============

Trình điều khiển này hỗ trợ toàn bộ dòng bộ điều khiển PCI-SCSI SYM53C8XX.
Nó cũng hỗ trợ tập hợp con của bộ điều khiển LSI53C10XX PCI-SCSI dựa trên
trên ngôn ngữ SYM53C8XX SCRIPTS.

Nó thay thế gói trình điều khiển sym53c8xx+ncr53c8xx và chia sẻ mã lõi của nó
với trình điều khiển FreeBSD SYM-2. 'Chất keo' cho phép driver này hoạt động
trong Linux được chứa trong 2 tệp có tên sym_glue.h và sym_glue.c.
Các tệp trình điều khiển khác được dự định không phụ thuộc vào Hệ điều hành
trên đó trình điều khiển được sử dụng.

Lịch sử của trình điều khiển này có thể được tóm tắt như sau:

1993: trình điều khiển ncr được viết cho 386bsd và FreeBSD bởi:

- Wolfgang Stanglmeier <wolf@cologne.de>
          - Stefan Esser <se@mi.Uni-Koeln.de>

1996: chuyển trình điều khiển ncr sang Linux-1.2.13 và đổi tên thành ncr53c8xx.

- Gerard Roudier

1998: trình điều khiển sym53c8xx mới cho Linux dựa trên hướng dẫn LOAD/STORE và điều đó
      bổ sung hỗ trợ đầy đủ cho 896 nhưng giảm hỗ trợ cho các thiết bị NCR đời đầu.

- Gerard Roudier

1999: chuyển trình điều khiển sym53c8xx sang FreeBSD và hỗ trợ LSI53C1010
      Bộ điều khiển Ultra-3 33 MHz và 66 MHz. Trình điều khiển mới được đặt tên là 'sym'.

- Gerard Roudier

2000: Thêm hỗ trợ cho các thiết bị NCR đời đầu vào trình điều khiển 'sym' FreeBSD.
      Chia driver thành nhiều nguồn và tách keo OS
      mã từ mã lõi có thể được chia sẻ giữa các O/S khác nhau.
      Viết mã keo cho Linux.

- Gerard Roudier

2004: Xóa mã tương thích FreeBSD.  Xóa hỗ trợ cho các phiên bản của
      Linux trước 2.6.  Bắt đầu sử dụng các cơ sở Linux.

Tệp README này đề cập đến phiên bản trình điều khiển Linux. Theo FreeBSD,
tài liệu trình điều khiển là trang man sym.8.

Thông tin về chip mới có sẵn tại máy chủ web LSILOGIC:

ZZ0000ZZ

Tài liệu tiêu chuẩn SCSI có sẵn tại trang T10:

ZZ0000ZZ

Các công cụ SCSI hữu ích được viết bởi Eric Youngdale là một phần của hầu hết Linux
phân phối:

=========================================
   công cụ dòng lệnh scsiinfo
   Công cụ scsi-config TCL/Tk sử dụng scsiinfo
   =========================================

2. Chip được hỗ trợ và tính năng SCSI
=====================================

Các tính năng sau được hỗ trợ cho tất cả các chip:

- Đàm phán đồng bộ
	- Ngắt kết nối
	- Xếp hàng lệnh được gắn thẻ
	- Kiểm tra tính chẵn lẻ SCSI
	- Kiểm tra tính chẵn lẻ của PCI Master

Các tính năng khác phụ thuộc vào khả năng của chip.

Trình điều khiển đáng chú ý sử dụng SCRIPTS được tối ưu hóa cho các thiết bị hỗ trợ
LOAD/STORE và xử lý PHASE MISMATCH từ SCRIPTS cho các thiết bị
hỗ trợ tính năng tương ứng.

Bảng sau đây cho thấy một số đặc điểm của họ chip.

+--------+----------+------+----------+-------------+-------------+----------+
ZZ0000ZZ ZZ0001ZZ |            |Tải/lưu trữ ZZ0003ZZ
|        |Trên bo mạch ZZ0005ZZ |            |scripts ZZ0007ZZ
ZZ0008ZZSDMS BIOS ZZ0009ZZSCSI tiêu chuẩn.  ZZ0010ZZ ZZ0011ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0012ZZ N ZZ0013ZZ FAST10 ZZ0014ZZ N ZZ0015ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0016ZZ N ZZ0017ZZ FAST10 ZZ0018ZZ Y ZZ0019ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0020ZZ Y ZZ0021ZZ FAST10 ZZ0022ZZ N ZZ0023ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0024ZZ Y ZZ0025ZZ FAST10 ZZ0026ZZ N ZZ0027ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0028ZZ Y ZZ0029ZZ FAST10 ZZ0030ZZ Y ZZ0031ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0032ZZ N ZZ0033ZZ FAST20 ZZ0034ZZ Y ZZ0035ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0036ZZ Y ZZ0037ZZ FAST20 ZZ0038ZZ Y ZZ0039ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0040ZZ Y ZZ0041ZZ FAST20 ZZ0042ZZ Y ZZ0043ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0044ZZ Y ZZ0045ZZ FAST20 ZZ0046ZZ Y ZZ0047ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0048ZZ Y ZZ0049ZZ FAST40 ZZ0050ZZ Y ZZ0051ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0052ZZ Y ZZ0053ZZ FAST40 ZZ0054ZZ Y ZZ0055ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0056ZZ Y ZZ0057ZZ FAST40 ZZ0058ZZ Y ZZ0059ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0060ZZ Y ZZ0061ZZ FAST40 ZZ0062ZZ Y ZZ0063ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0064ZZ Y ZZ0065ZZ FAST40 ZZ0066ZZ Y ZZ0067ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0068ZZ Y ZZ0069ZZ FAST80 ZZ0070ZZ Y ZZ0071ZZ
+--------+----------+------+----------+-------------+-------------+----------+
ZZ0072ZZ Y ZZ0073ZZ FAST80 ZZ0074ZZ Y ZZ0075ZZ
ZZ0076ZZ ZZ0077ZZ ZZ0078ZZ ZZ0079ZZ
+--------+----------+------+----------+-------------+-------------+----------+

.. [1] Chip supports 33MHz and 66MHz PCI bus clock.


Tóm tắt các tính năng được hỗ trợ khác:

:Module: cho phép tải driver
: I/O được ánh xạ bộ nhớ: tăng hiệu suất
:Lệnh điều khiển: ghi các thao tác vào hệ thống tệp Proc SCSI
:Thông tin gỡ lỗi: được ghi vào nhật ký hệ thống (chỉ dành cho chuyên gia)
:Serial NVRAM: Định dạng Symbios và Tekram

- Phân tán / tập hợp
- Chia sẻ ngắt
- Lệnh thiết lập khởi động


3. Ưu điểm của trình điều khiển này cho các chip mới hơn.
=========================================================

3.1 SCSI SCRIPTS được tối ưu hóa
--------------------------------

Tất cả các chip ngoại trừ 810, 815 và 825, đều hỗ trợ các lệnh SCSI SCRIPTS mới
được đặt tên là LOAD và STORE cho phép di chuyển tối đa 1 DWORD từ/đến một thanh ghi IO
đến/từ bộ nhớ nhanh hơn nhiều so với lệnh MOVE MEMORY được hỗ trợ
bởi họ 53c7xx và 53c8xx.

Các lệnh LOAD/STORE hỗ trợ địa chỉ tuyệt đối và tương đối DSA
chế độ. Thay vào đó, SCSI SCRIPTS đã được viết lại hoàn toàn bằng LOAD/STORE
của hướng dẫn MOVE MEMORY.

Do các chip trước đó thiếu hướng dẫn LOAD/STORE SCRIPTS, điều này
trình điều khiển cũng kết hợp một bộ SCRIPTS khác dựa trên MEMORY MOVE, trong
để cung cấp hỗ trợ cho toàn bộ dòng chip SYM53C8XX.

3.2 Tính năng mới xuất hiện với SYM53C896
--------------------------------------------

Các chip mới hơn (xem ở trên) cho phép xử lý bối cảnh không khớp pha từ
SCRIPTS (tránh gián đoạn không khớp pha làm dừng bộ xử lý SCSI
cho đến khi mã C lưu lại ngữ cảnh chuyển).

Các chip 896 và 1010 hỗ trợ các giao dịch và địa chỉ PCI 64 bit,
trong khi 895A hỗ trợ giao dịch PCI 32 bit và địa chỉ 64 bit.
Bộ xử lý SCRIPTS của các chip này không đúng 64 bit mà sử dụng phân khúc
đăng ký bit 32-63. Một tính năng thú vị khác là LOAD/STORE
các lệnh có địa chỉ RAM (8k) trên chip vẫn còn bên trong chip.

4. I/O được ánh xạ bộ nhớ so với I/O thông thường
=================================================

I/O được ánh xạ bộ nhớ có độ trễ thấp hơn I/O thông thường và được khuyên dùng
cách thực hiện IO với thiết bị PCI. I/O được ánh xạ bộ nhớ dường như hoạt động tốt trên
hầu hết các cấu hình phần cứng, nhưng một số chipset được thiết kế kém có thể bị hỏng
tính năng này. Một tùy chọn cấu hình được cung cấp cho I/O bình thường
đã sử dụng nhưng trình điều khiển mặc định là MMIO.

5. Xếp hàng lệnh được gắn thẻ
=============================

Xếp hàng nhiều lệnh cùng lúc vào một thiết bị cho phép thiết bị thực hiện
tối ưu hóa dựa trên vị trí đầu thực tế và cơ chế của nó
đặc điểm. Tính năng này cũng có thể làm giảm độ trễ lệnh trung bình.
Để thực sự tận dụng được tính năng này, các thiết bị phải có
kích thước bộ đệm hợp lý (Không có phép lạ nào được mong đợi đối với cấp thấp
đĩa cứng có dung lượng 128 KB trở xuống).

Một số thiết bị SCSI cũ đã biết không hỗ trợ xếp hàng lệnh được gắn thẻ đúng cách.
Nói chung, có sẵn các bản sửa đổi chương trình cơ sở khắc phục loại sự cố này.
tại các trang web/ftp của nhà cung cấp tương ứng.

Tất cả những gì tôi có thể nói là tôi chưa bao giờ gặp vấn đề với việc xếp hàng được gắn thẻ bằng cách sử dụng
trình điều khiển này và các trình điều khiển trước đó. Đĩa cứng hoạt động chính xác cho
tôi bằng cách sử dụng các lệnh được gắn thẻ như sau:

-IBM S12 0662
- Conner 1080S
- Atlas lượng tử I
- Atlas lượng tử II
- Seagate Cheetah tôi
- Viking lượng tử II
- IBM DRVS
- Atlas lượng tử IV
- Seagate Cheetah II

Nếu bộ điều khiển của bạn có NVRAM, bạn có thể định cấu hình tính năng này cho mỗi mục tiêu
từ công cụ thiết lập người dùng. Chương trình Tekram Setup cho phép điều chỉnh
số lượng lệnh xếp hàng tối đa lên tới 32. Cài đặt Symbios chỉ cho phép
để bật hoặc tắt tính năng này.

Số lượng lệnh được gắn thẻ đồng thời tối đa được xếp hàng đợi trên một thiết bị
hiện được đặt thành 16 theo mặc định.  Giá trị này phù hợp với hầu hết SCSI
đĩa.  Với đĩa SCSI lớn (>= 2GB, bộ đệm >= 512KB, thời gian tìm kiếm trung bình
<= 10 ms), sử dụng giá trị lớn hơn có thể mang lại hiệu suất tốt hơn.

Trình điều khiển này hỗ trợ tối đa 255 lệnh cho mỗi thiết bị và sử dụng nhiều hơn
64 thường không có giá trị, trừ khi bạn đang sử dụng một đĩa rất lớn hoặc
mảng đĩa. Điều đáng chú ý là hầu hết các đĩa cứng gần đây dường như không
chấp nhận hơn 64 lệnh đồng thời. Vì vậy, sử dụng hơn 64 hàng đợi
lệnh có lẽ chỉ là lãng phí tài nguyên.

Nếu bộ điều khiển của bạn không có NVRAM hoặc nếu nó được quản lý bởi SDMS
BIOS/SETUP, bạn có thể định cấu hình tính năng xếp hàng được gắn thẻ và hàng đợi thiết bị
độ sâu từ dòng lệnh khởi động. Ví dụ::

sym53c8xx=thẻ:4/t2t3q15-t4q7/t1u0q32

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

- Cứ 200 lệnh SCSI hoàn thành thành công, nếu được phép
  giới hạn hiện tại, số lượng lệnh có thể xếp hàng tối đa sẽ tăng lên.

Vì việc tiếp nhận và xử lý trạng thái QUEUE FULL gây lãng phí tài nguyên nên
Theo mặc định, trình điều khiển sẽ thông báo vấn đề này cho người dùng bằng cách chỉ ra thực tế
số lượng lệnh được sử dụng và trạng thái của chúng cũng như quyết định của nó về
thay đổi độ sâu hàng đợi thiết bị.
Phương pháp phỏng đoán được người lái xe sử dụng khi xử lý QUEUE FULL đảm bảo rằng
ảnh hưởng đến màn trình diễn không quá tệ. Bạn có thể loại bỏ các tin nhắn bằng cách
đặt mức chi tiết về 0, như sau:

Phương pháp thứ 1:
	    khởi động hệ thống của bạn bằng tùy chọn 'sym53c8xx=verb:0'.
Phương pháp thứ 2:
	    áp dụng lệnh điều khiển "setverbose 0" cho mục nhập proc fs
            tương ứng với bộ điều khiển của bạn sau khi khởi động.

6. Kiểm tra tính chẵn lẻ
========================

Trình điều khiển hỗ trợ kiểm tra chẵn lẻ SCSI và kiểm tra chẵn lẻ bus PCI
kiểm tra.  Những tính năng này phải được kích hoạt để đảm bảo an toàn
chuyển dữ liệu.  Một số thiết bị hoặc bo mạch chủ bị lỗi có thể gặp sự cố
với sự ngang bằng.  Các tùy chọn để đánh bại kiểm tra tính chẵn lẻ đã bị loại bỏ
từ người lái xe.

7. Thông tin hồ sơ
========================

Trình điều khiển này không cung cấp thông tin định hình như các trình điều khiển trước đó.
Tính năng này không hữu ích và làm tăng thêm độ phức tạp cho mã.
Vì mã trình điều khiển trở nên phức tạp hơn nên tôi quyết định xóa mọi thứ
điều đó dường như không thực sự hữu ích.

8. Lệnh điều khiển
===================

Các lệnh điều khiển có thể được gửi tới trình điều khiển bằng các thao tác ghi vào
hệ thống tập tin Proc SCSI. Cú pháp lệnh chung là
sau đây::

echo "<động từ> <tham số>" >/proc/scsi/sym53c8xx/0
      (giả sử số bộ điều khiển là 0)

Sử dụng tham số "all" cho "<target>" với các lệnh bên dưới sẽ
áp dụng cho tất cả các mục tiêu của chuỗi SCSI (ngoại trừ bộ điều khiển).

Các lệnh có sẵn:

8.1 Thiết lập hệ số chu kỳ đồng bộ tối thiểu
--------------------------------------------

setsync <mục tiêu> <hệ số thời gian>

:target: số mục tiêu
    :thời gian: khoảng thời gian đồng bộ tối thiểu.
               Tốc độ tối đa = 1000/(hệ số chu kỳ 4*) ngoại trừ trường hợp đặc biệt
               trường hợp dưới đây.

Chỉ định khoảng thời gian bằng 0 để buộc chế độ truyền không đồng bộ.

- 9 nghĩa là thời gian đồng bộ 12,5 nano giây
     - 10 nghĩa là thời gian đồng bộ là 25 nano giây
     - 11 nghĩa là thời gian đồng bộ 30 nano giây
     - 12 nghĩa là thời gian đồng bộ là 50 nano giây

8.2 Đặt kích thước rộng
-----------------------

toàn bộ <mục tiêu> <kích thước>

:target: số mục tiêu
    :kích thước: 0=8 bit, 1=16bit

8.3 Đặt số lượng lệnh được gắn thẻ đồng thời tối đa
----------------------------------------------------

thẻ cài đặt <mục tiêu> <thẻ>

:target: số mục tiêu
    :tags: số lệnh được gắn thẻ đồng thời
               không được lớn hơn cấu hình (mặc định: 16)

8.4 Đặt chế độ gỡ lỗi
---------------------

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


8.5 Đặt cờ (no_disc)
----------------------

đặt cờ <mục tiêu> <cờ>

:target: số mục tiêu

Hiện tại, chỉ có một lá cờ có sẵn:

no_disc: không cho phép mục tiêu ngắt kết nối.

Không chỉ định bất kỳ cờ nào để đặt lại cờ. Ví dụ:

cờ báo 4
      sẽ đặt lại cờ no_disc cho mục tiêu 4, do đó sẽ cho phép nó ngắt kết nối.
    đặt cờ tất cả
      sẽ cho phép ngắt kết nối tất cả các thiết bị trên bus SCSI.


8.6 Đặt mức độ dài dòng
-----------------------

thiết lập #level

Mức chi tiết mặc định của trình điều khiển là 1. Lệnh này cho phép thay đổi
    mức độ chi tiết của trình điều khiển sau khi khởi động.

8.7 Đặt lại tất cả các đơn vị logic của mục tiêu
------------------------------------------------

thiết lập lại <mục tiêu>

:target: số mục tiêu

Trình điều khiển sẽ cố gắng gửi tin nhắn BUS DEVICE RESET đến mục tiêu.

8.8 Hủy bỏ tất cả nhiệm vụ của tất cả các đơn vị logic của mục tiêu
-------------------------------------------------------------------

Cleardev <mục tiêu>

:target: số mục tiêu

Trình điều khiển sẽ cố gắng gửi tin nhắn ABORT tới tất cả các đơn vị logic
    của mục tiêu.


9. Thông số cấu hình
===========================

Trong các công cụ cấu hình kernel (ví dụ: tạo menuconfig), nó là
có thể thay đổi một số thông số cấu hình trình điều khiển mặc định.
Nếu chương trình cơ sở của tất cả các thiết bị của bạn đủ hoàn hảo, tất cả
các tính năng được trình điều khiển hỗ trợ có thể được kích hoạt khi khởi động. Tuy nhiên,
nếu chỉ có một lỗi đối với một số tính năng của SCSI, bạn có thể tắt tính năng này
hỗ trợ bởi trình điều khiển tính năng này khi khởi động linux và kích hoạt
tính năng này sau khi khởi động chỉ dành cho những thiết bị hỗ trợ nó một cách an toàn.

Thông số cấu hình:

Sử dụng IO bình thường (câu trả lời mặc định: n)
    Trả lời "y" nếu bạn nghi ngờ bo mạch chủ của mình không cho phép I/O được ánh xạ bộ nhớ.
    Có thể làm chậm hiệu suất một chút.

Độ sâu hàng đợi lệnh được gắn thẻ mặc định (câu trả lời mặc định: 16)
    Nhập 0 giá trị mặc định cho các lệnh được gắn thẻ không được sử dụng.
    Tham số này có thể được chỉ định từ dòng lệnh khởi động.

Số lượng lệnh xếp hàng tối đa (câu trả lời mặc định: 32)
    Tùy chọn này cho phép bạn chỉ định số lượng lệnh được gắn thẻ tối đa
    có thể được xếp hàng đợi vào một thiết bị. Giá trị được hỗ trợ tối đa là 255.

Tần số truyền đồng bộ (câu trả lời mặc định: 80)
    Tùy chọn này cho phép bạn chỉ định tần số tính bằng MHz cho trình điều khiển
    sẽ sử dụng vào lúc khởi động để đàm phán truyền dữ liệu đồng bộ.
    0 có nghĩa là "truyền dữ liệu không đồng bộ".

10. Lệnh thiết lập khởi động
============================

10.1 Cú pháp
------------

Các lệnh thiết lập có thể được chuyển tới trình điều khiển vào lúc khởi động hoặc khi
tham số cho modprobe, như được mô tả trong Documentation/admin-guide/kernel-parameters.rst

Ví dụ về lệnh thiết lập khởi động dưới dấu nhắc lilo::

lilo: linux root=/dev/sda2 sym53c8xx.cmd_per_lun=4 sym53c8xx.sync=10 sym53c8xx.debug=0x200

- kích hoạt các lệnh được gắn thẻ, tối đa 4 lệnh được gắn thẻ được xếp hàng đợi.
- đặt tốc độ đàm phán đồng bộ thành 10 lần chuyển Mega / giây.
- đặt cờ DEBUG_NEGO.

Lệnh sau sẽ cài đặt mô-đun trình điều khiển tương tự
các tùy chọn như trên::

modprobe sym53c8xx cmd_per_lun=4 sync=10 debug=0x200

10.2 Đối số có sẵn
------------------------

10.2.1 Số lệnh được gắn thẻ mặc định
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- cmd_per_lun=0 (hoặc cmd_per_lun=1) đã vô hiệu hóa hàng đợi lệnh được gắn thẻ
        - cmd_per_lun=#tags (#tags > 1) đã bật xếp hàng lệnh được gắn thẻ

#tags sẽ bị cắt bớt thành tham số cấu hình lệnh được xếp hàng đợi tối đa.

10.2.2 Nổ tối đa
^^^^^^^^^^^^^^^^

======================================================================
        cụm = 0 cụm bị vô hiệu hóa
        Burst=255 nhận độ dài cụm từ cài đặt thanh ghi IO ban đầu.
        bật=Đã bật cụm #x (tối đa 1<<#x chuyển cụm liên tục)

#x là một giá trị nguyên là log cơ số 2 của cụm
		   chuyển tối đa
	======================================================================

Theo mặc định, trình điều khiển sử dụng giá trị tối đa được chip hỗ trợ.

Hỗ trợ 10.2.3 LED
^^^^^^^^^^^^^^^^^^

===== =====================
        led=1 bật hỗ trợ LED
        led=0 tắt hỗ trợ LED
	===== =====================

Không bật hỗ trợ LED nếu bo mạch scsi của bạn không sử dụng SDMS BIOS.
  (Xem 'Thông số cấu hình')

10.2.4 Chế độ vi sai
^^^^^^^^^^^^^^^^^^^^^^^^

====== ====================================
	diff=0 không bao giờ thiết lập chế độ khác biệt
        diff=1 thiết lập chế độ khác biệt nếu BIOS thiết lập nó
        diff=2 luôn thiết lập chế độ khác biệt
        diff=3 đặt chế độ khác biệt nếu GPIO3 không được đặt
	====== ====================================

Chế độ 10.2.5 IRQ
^^^^^^^^^^^^^^^^^

====== =====================================================
        irqm=0 luôn mở cống
        irqm=1 giống như cài đặt ban đầu (cài đặt BIOS giả định)
        irqm=2 luôn là cột vật tổ
	====== =====================================================

10.2.6 Kiểm tra SCSI BUS
^^^^^^^^^^^^^^^^^^^^^^^^

buschk=<bit tùy chọn>

Các bit tùy chọn có sẵn:

=== =====================================================
        0x0 Không kiểm tra.
        0x1 Kiểm tra và không gắn bộ điều khiển nếu có lỗi.
        0x2 Kiểm tra và chỉ cảnh báo khi có lỗi.
	=== =====================================================

10.2.7 Đề xuất id SCSI mặc định cho máy chủ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

=========================================================
        Hostid=255 không có id nào được đề xuất.
        Hostid=#x (0 < x < 7) x được đề xuất cho id máy chủ SCSI.
	=========================================================

Nếu id SCSI của máy chủ có sẵn từ NVRAM, trình điều khiển sẽ bỏ qua
    bất kỳ giá trị nào được đề xuất làm tùy chọn khởi động. Mặt khác, nếu một giá trị được đề xuất
    khác với 255 đã được cung cấp thì sẽ sử dụng nó. Nếu không, nó sẽ
    cố gắng suy ra giá trị được đặt trước đó trong phần cứng và giá trị sử dụng
    7 nếu giá trị phần cứng bằng 0.

10.2.8 Mức độ chi tiết
^^^^^^^^^^^^^^^^^^^^^^^

====== =========
        động từ=0 tối thiểu
        động từ=1 bình thường
        động từ=2 quá nhiều
	====== =========

10.2.9 Chế độ gỡ lỗi
^^^^^^^^^^^^^^^^^^^^

=================================================
        debug=0 xóa cờ gỡ lỗi
        debug=#x đặt cờ gỡ lỗi

#x là một giá trị số nguyên kết hợp
		    các giá trị lũy thừa 2 sau:

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
	=================================================

Bạn có thể chơi an toàn với DEBUG_NEGO. Tuy nhiên, một số cờ này có thể
  tạo ra nhiều thông báo nhật ký hệ thống.

10.2.10 Giải quyết độ trễ
^^^^^^^^^^^^^^^^^^^^^^^^^

=============================
        giải quyết=n độ trễ trong n giây
	=============================

Sau khi thiết lập lại xe buýt, tài xế sẽ trì hoãn n giây trước khi nói chuyện
  tới bất kỳ thiết bị nào trên xe buýt.  Mặc định là 3 giây và chế độ an toàn sẽ
  mặc định là 10.

10.2.11 NVRAM nối tiếp
^^^^^^^^^^^^^^^^^^^^^^

	.. Note:: option not currently implemented.

======= =============================================
        nvram=n đừng tìm NVRAM nối tiếp
        nvram=y bộ điều khiển kiểm tra cho NVRAM nối tiếp trên bo mạch
	======= =============================================

(dạng nhị phân thay thế)

nvram=<tùy chọn bit>

==== =======================================================================
        0x01 tìm NVRAM (tương đương nvram=y)
        0x02 bỏ qua tham số "Thương lượng đồng bộ" NVRAM cho tất cả các thiết bị
        0x04 bỏ qua tham số NVRAM "Thương lượng rộng" cho tất cả các thiết bị
        0x08 bỏ qua thông số NVRAM "Quét khi khởi động" cho tất cả các thiết bị
        0x80 cũng đính kèm bộ điều khiển được đặt thành OFF trong NVRAM (chỉ sym53c8xx)
        ==== =======================================================================

10.2.12 Loại trừ máy chủ được đính kèm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

excl=<io_address>,...

Ngăn không cho máy chủ tại một địa chỉ io nhất định được đính kèm.
    Ví dụ: 'excl=0xb400,0xc000' biểu thị cho
    trình điều khiển không đính kèm máy chủ tại địa chỉ 0xb400 và 0xc000.

10.3 Chuyển đổi từ các tùy chọn kiểu cũ
---------------------------------------

Trước đây, trình điều khiển sym2 chấp nhận các đối số có dạng::

sym53c8xx=tags:4,sync:10,debug:0x200

Do các tham số mô-đun mới nên tính năng này không còn khả dụng nữa.
Hầu hết các tùy chọn vẫn giữ nguyên, nhưng thẻ đã trở thành
cmd_per_lun để phản ánh các mục đích khác nhau của nó.  Mẫu trên sẽ
được chỉ định là::

modprobe sym53c8xx cmd_per_lun=4 sync=10 debug=0x200

hoặc trên dòng khởi động kernel như::

sym53c8xx.cmd_per_lun=4 sym53c8xx.sync=10 sym53c8xx.debug=0x200

10.4 SCSI BUS kiểm tra tùy chọn khởi động
-----------------------------------------

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

15. Xử lý sự cố SCSI
================================

15.1 Theo dõi vấn đề
---------------------

Hầu hết các sự cố SCSI là do bus SCSI không phù hợp hoặc quá lỗi
thiết bị.  Nếu không may bạn gặp vấn đề với SCSI, bạn có thể kiểm tra
những điều sau đây:

- Cáp bus SCSI
- điểm cuối ở cả hai đầu của chuỗi SCSI
- tin nhắn nhật ký hệ thống linux (một số trong số chúng có thể giúp bạn)

Nếu bạn không tìm thấy nguồn gốc của vấn đề, bạn có thể cấu hình
trình điều khiển hoặc thiết bị trong NVRAM với các tính năng tối thiểu.

- chỉ truyền dữ liệu không đồng bộ
- các lệnh được gắn thẻ bị vô hiệu hóa
- không được phép ngắt kết nối

Bây giờ, nếu bus SCSI của bạn ổn, hệ thống của bạn có mọi cơ hội hoạt động
với cấu hình an toàn này nhưng hiệu năng sẽ không được tối ưu.

Nếu vẫn không thành công, bạn có thể gửi mô tả sự cố của mình tới
danh sách gửi thư hoặc nhóm tin thích hợp.  Gửi cho tôi một bản sao để
hãy chắc chắn rằng tôi sẽ nhận được nó.  Rõ ràng, một lỗi trong mã trình điều khiển là
có thể.

Địa chỉ email hiện tại của tôi: Gerard Roudier <groudier@free.fr>

Cho phép ngắt kết nối là điều quan trọng nếu bạn sử dụng nhiều thiết bị trên
bus SCSI của bạn nhưng thường gây ra sự cố với các thiết bị có lỗi.
Truyền dữ liệu đồng bộ làm tăng thông lượng của các thiết bị nhanh như
các đĩa cứng.  Đĩa cứng SCSI tốt có bộ nhớ đệm lớn sẽ có được lợi thế
xếp hàng các lệnh được gắn thẻ.

15.2 Hiểu báo cáo lỗi phần cứng
-----------------------------------------

Khi trình điều khiển phát hiện tình trạng lỗi không mong muốn, nó có thể hiển thị thông báo
thông báo theo mẫu sau::

sym0:1: ERROR (0:48) (1-21-65) (f/95/0) @ (tập lệnh 7c0:19000000).
    sym0: tập lệnh cmd = 19000000
    sym0: regdump: da 10 80 95 47 0f 01 07 75 01 81 21 80 01 09 00.

Một số trường trong thông báo như vậy có thể giúp bạn hiểu nguyên nhân của sự cố
vấn đề như sau::

sym0:1: ERROR (0:48) (1-21-65) (f/95/0) @ (tập lệnh 7c0:19000000).
    .....A.........B.C....D.E..F....G.H..I.......J.....K...L.......

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
             cho biết bộ khởi tạo SCSI rằng đã xảy ra tình trạng lỗi không thể báo cáo bằng giao thức SCSI.
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
Trường H : SCNTL3 Thanh ghi điều khiển Scsi 3
          Chứa cài đặt các giá trị thời gian cho cả không đồng bộ và
          truyền dữ liệu đồng bộ.
Trường I: Thanh ghi điều khiển SCNTL4 Scsi 4
          Chỉ có ý nghĩa đối với bộ điều khiển 53C1010 Ultra3.

Hiểu biết về các trường J, K, L và dumps đòi hỏi phải có kiến thức tốt về
Tiêu chuẩn SCSI, chức năng lõi chip và cấu trúc dữ liệu trình điều khiển bên trong.
Bạn không bắt buộc phải giải mã và hiểu chúng, trừ khi bạn muốn giúp đỡ
duy trì mã trình điều khiển.

17. Serial NVRAM (được thêm bởi Richard Waltham: ký túc xá@farsrobt.demon.co.uk)
================================================================================

17.1 Tính năng
--------------

Kích hoạt hỗ trợ NVRAM nối tiếp cho phép phát hiện NVRAM nối tiếp đi kèm
trên Symbios và một số bộ điều hợp máy chủ tương thích với Symbios cũng như bảng Tekram. các
serial NVRAM được Symbios và Tekram sử dụng để lưu giữ các tham số thiết lập cho
bộ điều hợp máy chủ và các ổ đĩa kèm theo của nó.

Symbios NVRAM cũng lưu giữ dữ liệu về thứ tự khởi động của bộ điều hợp máy chủ trong một
hệ thống có nhiều hơn một bộ điều hợp máy chủ.  Thông tin này không còn được sử dụng
vì về cơ bản nó không tương thích với mẫu hotplug PCI.

Phát hiện bo mạch Tekram sử dụng chip Symbios, DC390W/F/U, có NVRAM
và điều này được sử dụng để phân biệt giữa máy chủ tương thích Symbios và máy chủ Tekram
bộ điều hợp. Điều này được sử dụng để tắt cài đặt "khác biệt" tương thích với Symbios
đặt không chính xác trên bảng Tekram nếu CONFIG_SCSI_53C8XX_SYMBIOS_COMPAT
tham số cấu hình được thiết lập cho phép cả bo mạch Symbios và Tekram có thể hoạt động
được sử dụng cùng với thẻ Symbios bằng cách sử dụng tất cả các tính năng của chúng, bao gồm
hỗ trợ "khác biệt". Hỗ trợ ("led pin" cho thẻ tương thích Symbios có thể vẫn còn
được kích hoạt khi sử dụng thẻ Tekram. Nó không có ích gì cho máy chủ Tekram
bộ điều hợp nhưng cũng không gây ra vấn đề gì.)

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

================================
Địa chỉ NVRAM
================================
0x000-0x0ff không được sử dụng
Dữ liệu khởi tạo 0x100-0x26f
0x270-0x7ff không được sử dụng
================================

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

?? dung lượng thiết bị dự phòng (bus 32 bit ??)::

00 00 00 00 00 00 00 00 (19x8byte)
    .
    .
    00 00 00 00 00 00 00 00

thiết lập mặc định giống hệt nhau cho 53c810a và 53c875 NVRAM

đoạn phim giới thiệu::

fe fe - ? điểm đánh dấu kết thúc?
    00 00
    00 00

thiết lập mặc định giống hệt nhau cho 53c810a và 53c875 NVRAM

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