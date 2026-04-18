.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/scsi-changer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Trình điều khiển bộ thay đổi phương tiện SCSI
=============================================

Đây là trình điều khiển cho các thiết bị Medium Changer SCSI, được liệt kê
với "Loại: Bộ thay đổi trung bình" trong /proc/scsi/scsi.

Cái này dành cho ZZ0000ZZ Jukebox.  Nó được hỗ trợ ZZ0001ZZ để làm việc với
Bộ đổi CD-ROM nhỏ phổ biến, không phải bộ đổi SCSI một ổ đĩa trên mỗi khe cắm
cũng như ổ IDE.

Công cụ Userland có sẵn từ đây:
	ZZ0000ZZ


Thông tin chung
-------------------

Đầu tiên là vài lời về cách hoạt động của bộ thay đổi: Bộ thay đổi có 2 (có thể
thêm) ID SCSI. Một cho thiết bị thay đổi điều khiển robot,
và một cho thiết bị thực sự đọc và ghi dữ liệu. các
sau này có thể là bất cứ thứ gì, MOD, CD-ROM, băng hoặc bất cứ thứ gì. Đối với
thiết bị thay đổi này là "không quan tâm", anh ấy ZZ0000ZZ di chuyển xung quanh
phương tiện truyền thông, không có gì khác.


Mô hình bộ thay đổi SCSI rất phức tạp, so với - ví dụ - IDE-CD
người thay đổi. Nhưng nó cho phép xử lý gần như tất cả các trường hợp có thể xảy ra. Nó biết
4 loại yếu tố thay đổi khác nhau:

======================================================================
  phương tiện truyền thông vận chuyển cái này xáo trộn xung quanh phương tiện truyền thông, tức là
                    cánh tay vận chuyển.  Còn được gọi là "người chọn".
  lưu trữ một khe có thể chứa phương tiện truyền thông.
  nhập/xuất giống như trên, nhưng có thể truy cập được từ bên ngoài,
                    tức là ở đó người vận hành (bạn!) có thể sử dụng điều này để
                    điền và loại bỏ phương tiện khỏi bộ thay đổi.
		    Đôi khi được đặt tên là "khe thư".
  truyền dữ liệu đây là thiết bị đọc/ghi, tức là
		    CD-ROM / Băng / bất kỳ ổ đĩa nào.
  ======================================================================

Không cái nào trong số này bị giới hạn ở một: Một Jukebox khổng lồ có thể có các khe cắm cho
123 CD-ROM, 5 đầu đọc CD-ROM (và do đó 6 ID SCSI: bộ thay đổi
và mỗi CD-ROM) và 2 cần vận chuyển. Không có vấn đề gì để xử lý.


Nó được thực hiện như thế nào
-----------------------------

Tôi đã triển khai trình điều khiển làm trình điều khiển thiết bị ký tự giống NetBSD
giao diện ioctl Vừa lấy tệp tiêu đề của NetBSD và một trong các
trình điều khiển thiết bị linux SCSI khác làm điểm bắt đầu. Giao diện
phải có mã nguồn tương thích với NetBSD. Vì vậy nếu có bất kỳ
phần mềm (có ai biết ???) hỗ trợ trình điều khiển thay đổi BSDish,
nó cũng sẽ hoạt động với trình điều khiển này.

Theo thời gian, một số ioctls khác đã được thêm vào, chẳng hạn như hỗ trợ thẻ âm lượng
không được NetBSD ioctl API bao phủ.


Trạng thái hiện tại
-------------------

Hỗ trợ cho nhiều nhánh vận chuyển chưa được triển khai (và
không ai yêu cầu nó cho đến nay...).

Tôi tự mình kiểm tra và sử dụng trình điều khiển với máy hát tự động cdrom 35 khe từ
Grundig.  Tôi nhận được một số báo cáo cho biết nó hoạt động tốt với trình tải băng tự động
(Exabyte, HP và DEC).  Một số người sử dụng trình điều khiển này với Amanda.  Nó
hoạt động tốt với loại nhỏ (11 khe) và loại lớn (4 MO, 88 khe)
Jukebox quang từ.  Có lẽ với rất nhiều thay đổi khác nữa, hầu hết
(nhưng không phải tất cả :-) mọi người chỉ gửi thư cho tôi nếu ZZ0000ZZ hoạt động...

Tôi không có bất kỳ danh sách thiết bị nào, cả danh sách đen lẫn danh sách trắng.  Như vậy
thật vô ích khi hỏi tôi bất cứ khi nào một thiết bị cụ thể được hỗ trợ hoặc
không.  Về lý thuyết, mọi thiết bị thay đổi hỗ trợ phương tiện SCSI-2
bộ lệnh thay đổi sẽ hoạt động tốt với trình điều khiển này.  Nếu nó
không, đó là một lỗi.  Trong trình điều khiển hoặc trong phần sụn
của thiết bị biến đổi.


Sử dụng nó
----------

Đây là thiết bị ký tự có số chính là 86 nên hãy sử dụng
"mknod /dev/sch0 c 86 0" để tạo tệp đặc biệt cho trình điều khiển.

Nếu mô-đun tìm thấy bộ thay đổi, nó sẽ in một số thông báo về
thiết bị [ thử "dmesg" nếu bạn không thấy gì cả] và sẽ hiển thị trong
/proc/thiết bị. Nếu không.... một số người thay đổi sử dụng ID? / LUN 0 cho
thiết bị và ID? / LUN 1 cho cơ chế robot. Nhưng Linux có ZZ0000ZZ
tìm kiếm các LUN khác 0 làm mặc định vì có quá nhiều
các thiết bị bị hỏng. Vì vậy bạn có thể thử:

1) echo "scsi add-single-device 0 0 ID 1" > /proc/scsi/scsi
     (thay ID bằng SCSI-ID của thiết bị)
  2) khởi động kernel bằng "max_scsi_luns=1" trên dòng lệnh
     (append="max_scsi_luns=1" trong lilo.conf sẽ thực hiện thủ thuật này)


Rắc rối?
--------

Nếu bạn cập nhật trình điều khiển bằng "insmod debug=1", nó sẽ dài dòng và
in rất nhiều thứ vào nhật ký hệ thống.  Biên dịch kernel với
CONFIG_SCSI_CONSTANTS=y cải thiện rất nhiều chất lượng của thông báo lỗi
bởi vì kernel sẽ dịch mã lỗi thành dạng con người có thể đọc được
dây rồi.

Bạn có thể hiển thị các thông báo này bằng lệnh dmesg (hoặc kiểm tra
logfile).  Nếu bạn gửi email cho tôi một số câu hỏi vì một vấn đề với
lái xe, vui lòng bao gồm những tin nhắn này.


Tùy chọn Insmod
---------------

gỡ lỗi=0/1
	Bật thông báo gỡ lỗi (xem ở trên, mặc định: 0).

dài dòng=0/1
	Hãy dài dòng (mặc định: 1).

init=0/1
	Gửi lệnh INITIALIZE ELEMENT STATUS tới bộ đổi
	tại thời điểm insmod (mặc định: 1).

timeout_init=<giây>
	hết thời gian chờ cho lệnh INITIALIZE ELEMENT STATUS
	(mặc định: 3600).

timeout_move=<giây>
	hết thời gian chờ cho tất cả các lệnh khác (mặc định: 120).

dt_id=<id1>,<id2>,... / dt_lun=<lun1>,<lun2>,...
	Hai cái này cho phép chỉ định ID SCSI và LUN cho dữ liệu
	các yếu tố chuyển giao.  Bạn có thể không cần cái này làm máy hát tự động
	nên cung cấp thông tin này.  Nhưng một số thiết bị không...

nhà cung cấp_firsts=, nhà cung cấp_counts=, nhà cung cấp_labels=
	Các tùy chọn insmod này có thể được sử dụng để báo cho người lái xe biết rằng có
	là một số loại phần tử dành riêng cho nhà cung cấp.  Grundig chẳng hạn
	thực hiện điều này.  Một số máy hát tự động có máy in để ghi nhãn mới được ghi
	CD, được đánh địa chỉ là phần tử 0xc000 (loại 5).  Để nói với
	trình điều khiển về phần tử dành riêng cho nhà cung cấp này, hãy sử dụng phần tử này ::

$ insmod ch \
			nhà cung cấp_firsts=0xc000 \
			nhà cung cấp_counts=1 \
			nhà cung cấp_nhãn=máy in

Tất cả ba tùy chọn insmod đều chấp nhận tối đa bốn dấu phẩy được phân tách bằng dấu phẩy
	các giá trị, bằng cách này bạn có thể định cấu hình các loại phần tử 5-8.
	Bạn có thể cần thông số kỹ thuật SCSI cho thiết bị được đề cập để
	tìm các giá trị chính xác vì chúng không được SCSI-2 bao phủ
	tiêu chuẩn.


Tín dụng
--------

Tôi đã viết trình điều khiển này bằng cách sử dụng bản vá gửi thư nổi tiếng trên toàn thế giới
phương pháp.  Với (ít nhiều) sự trợ giúp từ:

- Daniel Moehwald <moehwald@hdg.de>
	- Dane Jasper <dane@sonic.net>
	- R. Scott Bailey <sbailey@dsddi.eds.com>
	- Jonathan Corbet <corbet@lwn.net>

Lời cảm ơn đặc biệt tới

- Martin Kuehne <martin.kuehne@bnbt.de>

cho một máy hát tự động cdrom cũ, đã qua sử dụng (nhưng đầy đủ chức năng) mà tôi sử dụng
để phát triển/kiểm tra trình điều khiển và công cụ ngay bây giờ.

Chúc vui vẻ,

Gerd

Gerd Knorr <kraxel@bytesex.org>