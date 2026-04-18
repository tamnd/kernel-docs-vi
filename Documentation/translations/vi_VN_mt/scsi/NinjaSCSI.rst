.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/NinjaSCSI.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================
Trình điều khiển WorkBiT NinjaSCSI-3/32Bi cho Linux
===================================================

1. Bình luận
==========

Đây là công ty Workbit (ZZ0000ZZ NinjaSCSI-3
cho Linux.

2. Môi trường Linux của tôi
=======================

:Nhân Linux: 2.4.7 / 2.2.19
:pcmcia-cs: 3.1.27
:gcc: gcc-2.95.4
:Thẻ PC: Dữ liệu I-O PCSC-F (NinjaSCSI-3),
               Dữ liệu I-O CBSC-II ở chế độ 16 bit (NinjaSCSI-32Bi)
:Thiết bị SCSI: Dữ liệu I-O CDPS-PX24 (ổ đĩa CD-ROM),
               Media Intelligence MMO-640GT (Ổ đĩa quang)

3. Cài đặt
==========

(a) Kiểm tra thẻ PC của bạn có đúng là thẻ "NinjaSCSI-3" hay không.

Nếu bạn đã cài đặt pcmcia-cs, pcmcia sẽ báo cáo thẻ của bạn là UNKNOWN
    thẻ và viết ["WBT", "NinjaSCSI-3", "R1.0"] hoặc một số chuỗi khác vào
    bảng điều khiển hoặc tệp nhật ký của bạn.

Bạn cũng có thể sử dụng chương trình "cardctl" (chương trình này có trong nguồn pcmcia-cs
    mã) để biết thêm thông tin.

    ::

# cat /var/log/tin nhắn
	...
Ngày 2 tháng 1 03:45:06 lindberg cardmgr[78]: thẻ không được hỗ trợ trong ổ cắm 1
	2 tháng 1 03:45:06 lindberg cardmgr[78]: thông tin sản phẩm: "WBT", "NinjaSCSI-3", "R1.0"
	...
Nhận dạng # cardctl
	Ổ cắm 0:
	  không có thông tin sản phẩm
	Ổ cắm 1:
	  Thông tin sản phẩm: "IO DATA", "CBSC16", "1"


(b) Lấy nguồn nhân Linux và giải nén nó vào /usr/src.
    Bởi vì trình điều khiển NinjaSCSI yêu cầu một số tệp tiêu đề SCSI trong Linux 
    nguồn kernel, tôi khuyên bạn nên xây dựng lại kernel của mình; điều này giúp loại bỏ 
    một số vấn đề về phiên bản.

    ::

$ cd /usr/src
	$ tar -zxvf linux-x.x.x.tar.gz
	$ cd linux
	$ tạo cấu hình
	...

(c) Nếu bạn sử dụng trình điều khiển này với Kernel 2.2, hãy giải nén pcmcia-cs trong một thư mục nào đó
    và thực hiện & cài đặt. Trình điều khiển này yêu cầu tệp tiêu đề pcmcia-cs.

    ::

$ cd /usr/src
	$ tar zxvf cs-pcmcia-cs-3.x.x.tar.gz
	...

(d) Giải nén kho lưu trữ của trình điều khiển này ở đâu đó và chỉnh sửa Makefile, sau đó thực hiện ::

$ tar -zxvf nsp_cs-x.x.tar.gz
	$ cd nsp_cs-x.x
	$ emacs Makefile
	...
$ kiếm được

(e) Sao chép nsp_cs.ko đến nơi thích hợp, như /lib/modules/<Kernel version>/pcmcia/ .

(f) Thêm những dòng này vào /etc/pcmcia/config .

Nếu bạn sử dụng pcmcia-cs-3.1.8 trở lên, chúng tôi có thể sử dụng tệp "nsp_cs.conf".
    Vì vậy, bạn không cần phải chỉnh sửa tập tin. Chỉ cần sao chép vào /etc/pcmcia/ .

    ::

thiết bị "nsp_cs"
	  mô-đun lớp "scsi" "nsp_cs"

thẻ "WorkBit NinjaSCSI-3"
	  phiên bản "WBT", "NinjaSCSI-3", "R1.0"
	  liên kết "nsp_cs"

thẻ "WorkBit NinjaSCSI-32Bi (16bit)"
	  phiên bản "WORKBIT", "UltraNinja-16", "1"
	  liên kết "nsp_cs"

# ZZ0000ZZ
	thẻ "WorkBit NinjaSCSI-32Bi (16bit) / IO-DATA"
	  phiên bản "IO DATA", "CBSC16", "1"
	  liên kết "nsp_cs"

# ZZ0000ZZ
	thẻ "WorkBit NinjaSCSI-32Bi (16bit) / KME-1"
	  phiên bản "KME", "SCSI-CARD-001", "1"
	  liên kết "nsp_cs"
	thẻ "WorkBit NinjaSCSI-32Bi (16bit) / KME-2"
	  phiên bản "KME", "SCSI-CARD-002", "1"
	  liên kết "nsp_cs"
	thẻ "WorkBit NinjaSCSI-32Bi (16bit) / KME-3"
	  phiên bản "KME", "SCSI-CARD-003", "1"
	  liên kết "nsp_cs"
	thẻ "WorkBit NinjaSCSI-32Bi (16bit) / KME-4"
	  phiên bản "KME", "SCSI-CARD-004", "1"
	  liên kết "nsp_cs"

(f) Bắt đầu (hoặc khởi động lại) pcmcia-cs::

# /etc/rc.d/rc.pcmcia bắt đầu (kiểu BSD)

hoặc::

# /etc/init.d/pcmcia start (kiểu SYSV)


4. Lịch sử
==========

Xem README.nin_cs .

5. Thận trọng
==========

Nếu bạn đẩy thẻ ra khi thực hiện một số thao tác cho thiết bị SCSI của mình hoặc tạm dừng
máy tính của bạn, bạn gặp phải một số lỗi ZZ0000ZZ như hỏng đĩa.

Nó hoạt động tốt khi tôi sử dụng trình điều khiển này đúng cách. Nhưng tôi không đảm bảo
dữ liệu của bạn. Vui lòng sao lưu dữ liệu của bạn khi bạn sử dụng trình điều khiển này.

6. Lỗi đã biết
=============

Trong kernel 2.4, bạn không thể sử dụng đĩa quang 640 MB. Lỗi này xuất phát từ
Trình điều khiển SCSI cấp cao.

7. Kiểm tra
==========

Vui lòng gửi cho tôi một số báo cáo (báo cáo lỗi, v.v.) của phần mềm này.
Khi bạn gửi báo cáo, xin vui lòng cho tôi biết những điều này hoặc nhiều hơn nữa.

- tên thẻ
	- phiên bản hạt nhân
	- tên thiết bị SCSI của bạn (ổ cứng, CD-ROM, v.v.)

8. Bản quyền
============

Xem GPL.


2001/08/08 yokota@netlab.is.tsukuba.ac.jp <YOKOTA Hiroshi>