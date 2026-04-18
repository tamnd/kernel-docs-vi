.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/ioctl/cdrom.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Tổng hợp các cuộc gọi ioctl CDROM
=================================

- Edward A. Falk <efalk@google.com>

Tháng 11 năm 2004

Tài liệu này cố gắng mô tả các lệnh gọi ioctl(2) được hỗ trợ bởi
lớp CDROM.  Chúng được triển khai rộng rãi (kể từ Linux 2.6)
trong trình điều khiển/cdrom/cdrom.c và trình điều khiển/block/scsi_ioctl.c

các giá trị ioctl được liệt kê trong <linux/cdrom.h>.  Khi viết bài này, họ
như sau:

=============================================================================
	CDROMPAUSE Tạm dừng hoạt động âm thanh
	CDROMRESUME Tiếp tục hoạt động âm thanh bị tạm dừng
	CDROMPLAYMSF Phát âm thanh MSF (struct cdrom_msf)
	CDROMPLAYTRKIND Phát bản nhạc/chỉ mục âm thanh (struct cdrom_ti)
	CDROMREADTOCHDR Đọc tiêu đề TOC (struct cdrom_tochdr)
	CDROMREADTOCENTRY Đọc mục TOC (struct cdrom_tocentry)
	CDROMSTOP Dừng ổ đĩa cdrom
	CDROMSTART Khởi động ổ đĩa cdrom
	CDROMEJECT Đẩy phương tiện cdrom ra
	CDROMVOLCTRL Điều khiển âm lượng đầu ra (struct cdrom_volctrl)
	CDROMSUBCHNL Đọc dữ liệu kênh con (struct cdrom_subchnl)
	CDROMREADMODE2 Đọc dữ liệu CDROM chế độ 2 (2336 Byte)
				  (cấu trúc cdrom_read)
	CDROMREADMODE1 Đọc dữ liệu CDROM chế độ 1 (2048 Byte)
				  (cấu trúc cdrom_read)
	CDROMREADAUDIO (cấu trúc cdrom_read_audio)
	CDROMEJECT_SW bật(1)/tắt(0) tự động đẩy ra
	CDROMMULTISESSION Lấy điểm bắt đầu của phiên cuối cùng
				  địa chỉ của đĩa nhiều phiên
				  (cấu trúc cdrom_multisession)
	CDROM_GET_MCN Nhận "Mã sản phẩm chung"
				  nếu có (struct cdrom_mcn)
	CDROM_GET_UPC Không được dùng nữa, thay vào đó hãy sử dụng CDROM_GET_MCN.
	CDROMRESET hard reset ổ đĩa
	CDROMVOLREAD Nhận cài đặt âm lượng của ổ đĩa
				  (cấu trúc cdrom_volctrl)
	CDROMREADRAW đọc dữ liệu ở chế độ thô (2352 Byte)
				  (cấu trúc cdrom_read)
	CDROMREADCOOKED đọc dữ liệu ở chế độ nấu chín
	CDROMSEEK tìm kiếm địa chỉ msf
	CDROMPLAYBLK chỉ scsi-cd, (struct cdrom_blk)
	CDROMREADALL đọc tất cả 2646 byte
	CDROMGETSPINDOWN trả về giá trị spindown 4 bit
	CDROMSETSPINDOWN đặt giá trị spindown 4 bit
	Mặt dây chuyền CDROMCLOSETRAY của CDROMEJECT
	CDROM_SET_OPTIONS Đặt tùy chọn hành vi
	CDROM_CLEAR_OPTIONS Tùy chọn hành vi rõ ràng
	CDROM_SELECT_SPEED Đặt tốc độ CD-ROM
	CDROM_SELECT_DISC Chọn đĩa (dành cho máy hát tự động)
	CDROM_MEDIA_CHANGED Kiểm tra phương tiện đã thay đổi chưa
	CDROM_TIMED_MEDIA_CHANGE Kiểm tra xem phương tiện có thay đổi không
				  kể từ thời điểm nhất định
				  (cấu trúc cdrom_timed_media_change_info)
	CDROM_DRIVE_STATUS Nhận vị trí khay, v.v.
	CDROM_DISC_STATUS Nhận loại đĩa, v.v.
	CDROM_CHANGER_NSLOTS Nhận số lượng vị trí
	CDROM_LOCKDOOR khóa hoặc mở khóa cửa
	CDROM_DEBUG Bật/tắt thông báo gỡ lỗi
	CDROM_GET_CAPABILITY có được khả năng
	CDROMAUDIOBUFSIZ đặt kích thước bộ đệm âm thanh
	DVD_READ_STRUCT Đọc cấu trúc
	DVD_WRITE_STRUCT Viết cấu trúc
	Xác thực DVD_AUTH
	CDROM_SEND_PACKET gửi gói đến ổ đĩa
	CDROM_NEXT_WRITABLE nhận khối có thể ghi tiếp theo
	CDROM_LAST_WRITTEN lấy khối cuối cùng được ghi trên đĩa
	=============================================================================


Thông tin sau đây được xác định từ việc đọc nguồn kernel
mã.  Có khả năng một số điều chỉnh sẽ được thực hiện theo thời gian.

------------------------------------------------------------------------------

Tổng quan:

Trừ khi có quy định khác, tất cả các lệnh gọi ioctl đều trả về 0 nếu thành công
	và -1 với errno được đặt thành giá trị thích hợp khi có lỗi.  (Một số
	ioctls trả về giá trị dữ liệu không âm.)

Trừ khi có quy định khác, tất cả lệnh gọi ioctl đều trả về -1 và được đặt
	lỗi với EFAULT khi sao chép dữ liệu đến hoặc từ người dùng không thành công
	không gian địa chỉ.

Trình điều khiển riêng lẻ có thể trả về mã lỗi không được liệt kê ở đây.

Trừ khi có quy định khác, tất cả các cấu trúc dữ liệu và hằng số
	được định nghĩa trong <linux/cdrom.h>

------------------------------------------------------------------------------


CDROMPAUSE
	Tạm dừng hoạt động âm thanh


cách sử dụng::

ioctl(fd, CDROMPAUSE, 0);


đầu vào:
		không có


đầu ra:
		không có


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.


CDROMRESUME
	Tiếp tục hoạt động âm thanh bị tạm dừng


cách sử dụng::

ioctl(fd, CDROMRESUME, 0);


đầu vào:
		không có


đầu ra:
		không có


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.


CDROMPLAYMSF
	Phát âm thanh MSF

(cấu trúc cdrom_msf)


cách sử dụng::

cấu trúc cdrom_msf msf;

ioctl(fd, CDROMPLAYMSF, &msf);

đầu vào:
		Cấu trúc cdrom_msf, mô tả một đoạn nhạc sẽ phát


đầu ra:
		không có


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.

ghi chú:
		- MSF là viết tắt của phút-giây-khung hình
		- LBA là viết tắt của địa chỉ khối logic
		- Phân đoạn được mô tả là thời gian bắt đầu và kết thúc, trong đó mỗi lần
		  được mô tả là phút:giây:khung.
		  Một khung hình là 1/75 giây.


CDROMPLAYTRKIND
	Phát bản nhạc/chỉ mục âm thanh

(cấu trúc cdrom_ti)


cách sử dụng::

struct cdrom_ti ti;

ioctl(fd, CDROMPLAYTRKIND, &ti);

đầu vào:
		Cấu trúc cdrom_ti, mô tả một đoạn nhạc sẽ phát


đầu ra:
		không có


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.

ghi chú:
		- Phân đoạn được mô tả là thời gian bắt đầu và kết thúc, trong đó mỗi lần
		  được mô tả như một bản nhạc và một chỉ mục.



CDROMREADTOCHDR
	Đọc tiêu đề TOC

(cấu trúc cdrom_tochdr)


cách sử dụng::

tiêu đề cdrom_tochdr;

ioctl(fd, CDROMREADTOCHDR, &tiêu đề);

đầu vào:
		cấu trúc cdrom_tochdr


đầu ra:
		cấu trúc cdrom_tochdr


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.



CDROMREADTOCENTRY
	Đọc mục TOC

(cấu trúc cdrom_tocentry)


cách sử dụng::

mục nhập struct cdrom_tocentry;

ioctl(fd, CDROMREADTOCENTRY, &entry);

đầu vào:
		cấu trúc cdrom_tocentry


đầu ra:
		cấu trúc cdrom_tocentry


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.
	  - EINVAL entry.cdte_format không phải CDROM_MSF hay CDROM_LBA
	  - EINVAL yêu cầu bài hát vượt quá giới hạn
	  - Lỗi đọc I/O EIO TOC

ghi chú:
		- TOC là viết tắt của Mục lục
		- MSF là viết tắt của phút-giây-khung hình
		- LBA là viết tắt của địa chỉ khối logic



CDROMSTOP
	Dừng ổ đĩa cdrom


cách sử dụng::

ioctl(fd, CDROMSTOP, 0);


đầu vào:
		không có


đầu ra:
		không có


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.

ghi chú:
	  - Giải thích chính xác về ioctl này phụ thuộc vào thiết bị,
	    nhưng hầu hết dường như làm ổ đĩa quay xuống.


CDROMSTART
	Khởi động ổ đĩa cdrom


cách sử dụng::

ioctl(fd, CDROMSTART, 0);


đầu vào:
		không có


đầu ra:
		không có


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.

ghi chú:
	  - Giải thích chính xác về ioctl này phụ thuộc vào thiết bị,
	    nhưng hầu hết dường như đều quay ổ đĩa lên và/hoặc đóng khay.
	    Các thiết bị khác hoàn toàn bỏ qua ioctl.


CDROMEJECT
	- Đẩy ổ đĩa cdrom ra


cách sử dụng::

ioctl(fd, CDROMEJECT, 0);


đầu vào:
		không có


đầu ra:
		không có


lỗi trả về:
	  - Ổ đĩa cd ENOSYS không có khả năng đẩy ra
	  - EBUSY các tiến trình khác đang truy cập ổ đĩa hoặc cửa bị khóa

ghi chú:
		- Xem CDROM_LOCKDOOR bên dưới.




CDROMCLOSETRAY
	mặt dây chuyền của CDROMEJECT


cách sử dụng::

ioctl(fd, CDROMCLOSETRAY, 0);


đầu vào:
		không có


đầu ra:
		không có


lỗi trả về:
	  - Ổ đĩa CD ENOSYS không đóng được khay
	  - EBUSY các tiến trình khác đang truy cập ổ đĩa hoặc cửa bị khóa

ghi chú:
		- Xem CDROM_LOCKDOOR bên dưới.




CDROMVOLCTRL
	Kiểm soát âm lượng đầu ra (struct cdrom_volctrl)


cách sử dụng::

cấu trúc khối lượng cdrom_volctrl;

ioctl(fd, CDROMVOLCTRL, &volume);

đầu vào:
		Cấu trúc cdrom_volctrl chứa khối lượng lên tới 4
		các kênh.

đầu ra:
		không có


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.



CDROMVOLREAD
	Nhận cài đặt âm lượng của ổ đĩa

(cấu trúc cdrom_volctrl)


cách sử dụng::

cấu trúc khối lượng cdrom_volctrl;

ioctl(fd, CDROMVOLREAD, &volume);

đầu vào:
		không có


đầu ra:
		Cài đặt âm lượng hiện tại.


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.



CDROMSUBCHNL
	Đọc dữ liệu kênh con

(cấu trúc cdrom_subchnl)


cách sử dụng::

struct cdrom_subchnl q;

ioctl(fd, CDROMSUBCHNL, &q);

đầu vào:
		cấu trúc cdrom_subchnl


đầu ra:
		cấu trúc cdrom_subchnl


trả về lỗi:
	  - Ổ đĩa cd ENOSYS không có khả năng phát âm thanh.
	  - Định dạng EINVAL không phải CDROM_MSF hoặc CDROM_LBA

ghi chú:
		- Định dạng được chuyển đổi thành CDROM_MSF hoặc CDROM_LBA
		  theo yêu cầu của người dùng khi trả lại



CDROMREADRAW
	đọc dữ liệu ở chế độ thô (2352 Byte)

(cấu trúc cdrom_read)

cách sử dụng::

công đoàn {

cấu trúc cdrom_msf msf;		/*đầu vào*/
	    bộ đệm char [CD_FRAMESIZE_RAW];	/*trở về*/
	  } đối số;
	  ioctl(fd, CDROMREADRAW, &arg);

đầu vào:
		Cấu trúc cdrom_msf cho biết địa chỉ cần đọc.

Chỉ có giá trị bắt đầu là đáng kể.

đầu ra:
		Dữ liệu được ghi vào địa chỉ do người dùng cung cấp.


trả về lỗi:
	  - Địa chỉ EINVAL nhỏ hơn 0 hoặc msf nhỏ hơn 0:2:0
	  - ENOMEM hết bộ nhớ

ghi chú:
		- Kể từ phiên bản 2.6.8.1, các nhận xét trong <linux/cdrom.h> chỉ ra rằng điều này
		  ioctl chấp nhận cấu trúc cdrom_read, nhưng mã nguồn thực tế
		  đọc cấu trúc cdrom_msf và ghi bộ đệm dữ liệu vào
		  cùng một địa chỉ.

- Giá trị MSF được chuyển đổi thành giá trị LBA thông qua công thức sau::

lba = (((m * CD_SECS) + s) * CD_FRAMES + f) - CD_MSF_OFFSET;




CDROMREADMODE1
	Đọc dữ liệu CDROM chế độ 1 (2048 Byte)

(cấu trúc cdrom_read)

ghi chú:
		Giống hệt CDROMREADRAW ngoại trừ kích thước khối là
		CD_FRAMESIZE (2048) byte



CDROMREADMODE2
	Đọc dữ liệu CDROM chế độ 2 (2336 Byte)

(cấu trúc cdrom_read)

ghi chú:
		Giống hệt CDROMREADRAW ngoại trừ kích thước khối là
		CD_FRAMESIZE_RAW0 (2336) byte



CDROMREADAUDIO
	(cấu trúc cdrom_read_audio)

cách sử dụng::

struct cdrom_read_audio ra;

ioctl(fd, CDROMREADAUDIO, &ra);

đầu vào:
		Cấu trúc cdrom_read_audio chứa bắt đầu đọc
		điểm và độ dài

đầu ra:
		dữ liệu âm thanh, được trả về bộ đệm được biểu thị bằng ra


trả về lỗi:
	  - Định dạng EINVAL không phải CDROM_MSF hoặc CDROM_LBA
	  - Các khung EINVAL không nằm trong phạm vi [1 75]
	  - Ổ ENXIO không có hàng đợi (có thể có nghĩa là fd không hợp lệ)
	  - ENOMEM hết bộ nhớ


CDROMEJECT_SW
	bật(1)/tắt(0) tự động đẩy ra


cách sử dụng::

int giá trị;

ioctl(fd, CDROMEJECT_SW, val);

đầu vào:
		Cờ chỉ định cờ tự động đẩy ra.


đầu ra:
		không có


trả về lỗi:
	  - ENOSYS Drive không có khả năng đẩy ra.
	  - EBUSY Cửa bị khóa




CDROMMULTISESSION
	Lấy địa chỉ bắt đầu của phiên cuối cùng của đĩa nhiều phiên

(cấu trúc cdrom_multisession)

cách sử dụng::

cấu trúc cdrom_multisession ms_info;

ioctl(fd, CDROMMULTISESSION, &ms_info);

đầu vào:
		cấu trúc cdrom_multisession chứa mong muốn

định dạng.

đầu ra:
		Cấu trúc cdrom_multisession chứa đầy Last_session
		thông tin.

trả về lỗi:
	  - Định dạng EINVAL không phải CDROM_MSF hoặc CDROM_LBA


CDROM_GET_MCN
	Nhận "Mã sản phẩm chung"
	nếu có

(cấu trúc cdrom_mcn)


cách sử dụng::

struct cdrom_mcn mcn;

ioctl(fd, CDROM_GET_MCN, &mcn);

đầu vào:
		không có


đầu ra:
		Mã sản phẩm phổ quát


trả về lỗi:
	  - ENOSYS Drive không có khả năng đọc dữ liệu MCN.

ghi chú:
		- Trạng thái nhận xét mã nguồn::

Chức năng sau đây được triển khai, mặc dù rất ít
		    đĩa âm thanh cung cấp thông tin Mã sản phẩm chung, thông tin này
		    chỉ nên là Số danh mục trung bình trên hộp.  Lưu ý,
		    rằng cách mã được viết trên đĩa CD là /không/ thống nhất
		    trên tất cả các đĩa!




CDROM_GET_UPC
	CDROM_GET_MCN (không dùng nữa)


Chưa được triển khai kể từ phiên bản 2.6.8.1



CDROMRESET
	reset cứng ổ đĩa


cách sử dụng::

ioctl(fd, CDROMRESET, 0);


đầu vào:
		không có


đầu ra:
		không có


trả về lỗi:
	  - Truy cập EACCES bị từ chối: yêu cầu CAP_SYS_ADMIN
	  - ENOSYS Drive không có khả năng reset.




CDROMREADCOOKED
	đọc dữ liệu ở chế độ nấu chín


cách sử dụng::

Bộ đệm u8 [CD_FRAMESIZE]

ioctl(fd, CDROMREADCOOKED, bộ đệm);

đầu vào:
		không có


đầu ra:
		2048 byte dữ liệu, chế độ "nấu chín".


ghi chú:
		Không được triển khai trên tất cả các ổ đĩa.





CDROMREADALL
	đọc tất cả 2646 byte


Tương tự như CDROMREADCOOKED nhưng đọc được 2646 byte.



CDROMSEEK
	tìm kiếm địa chỉ msf


cách sử dụng::

cấu trúc cdrom_msf msf;

ioctl(fd, CDROMSEEK, &msf);

đầu vào:
		Địa chỉ MSF để tìm kiếm.


đầu ra:
		không có




CDROMPLAYBLK
	chỉ scsi-cd

(cấu trúc cdrom_blk)


cách sử dụng::

struct cdrom_blk blk;

ioctl(fd, CDROMPLAYBLK, &blk);

đầu vào:
		Khu vực để chơi


đầu ra:
		không có




CDROMGETSPINDOWN
	Đã lỗi thời, chỉ là ide-cd


cách sử dụng::

char spindown;

ioctl(fd, CDROMGETSPINDOWN, &spindown);

đầu vào:
		không có


đầu ra:
		Giá trị của giá trị spindown 4-bit hiện tại.





CDROMSETSPINDOWN
	Đã lỗi thời, chỉ là ide-cd


cách sử dụng::

spindown char

ioctl(fd, CDROMSETSPINDOWN, &spindown);

đầu vào:
		Giá trị 4 bit được sử dụng để điều khiển spindown (TODO: chi tiết hơn tại đây)


đầu ra:
		không có






CDROM_SET_OPTIONS
	Đặt tùy chọn hành vi


cách sử dụng::

tùy chọn int;

ioctl(fd, CDROM_SET_OPTIONS, tùy chọn);

đầu vào:
		Giá trị mới cho các tùy chọn ổ đĩa.  Logic 'hoặc' của:

====================================================
	    CDO_AUTO_CLOSE đóng khay vào lần mở đầu tiên(2)
	    Khay mở CDO_AUTO_EJECT ở lần phát hành gần đây nhất
	    CDO_USE_FFLAGS sử dụng thông tin O_NONBLOCK khi mở
	    Khay khóa CDO_LOCK trên các tập tin đang mở
	    Loại kiểm tra CDO_CHECK_TYPE khi mở dữ liệu
	    ====================================================

đầu ra:
		Trả về cài đặt tùy chọn kết quả trong
		giá trị trả về ioctl.  Trả về -1 nếu có lỗi.

trả về lỗi:
	  - (Các) tùy chọn đã chọn ENOSYS không được ổ đĩa hỗ trợ.




CDROM_CLEAR_OPTIONS
	Tùy chọn hành vi rõ ràng


Tương tự như CDROM_SET_OPTIONS, ngoại trừ các tùy chọn được chọn là
	đã tắt.



CDROM_SELECT_SPEED
	Đặt tốc độ CD-ROM


cách sử dụng::

tốc độ int;

ioctl(fd, CDROM_SELECT_SPEED, tốc độ);

đầu vào:
		Tốc độ ổ đĩa mới.


đầu ra:
		không có


trả về lỗi:
	  - Lựa chọn tốc độ ENOSYS không được ổ đĩa hỗ trợ.



CDROM_SELECT_DISC
	Chọn đĩa (đối với máy hát tự động)


cách sử dụng::

đĩa int;

ioctl(fd, CDROM_SELECT_DISC, đĩa);

đầu vào:
		Đĩa để tải vào ổ đĩa.


đầu ra:
		không có


trả về lỗi:
	  - EINVAL Số đĩa vượt quá dung lượng ổ đĩa



CDROM_MEDIA_CHANGED
	Kiểm tra xem phương tiện đã thay đổi chưa


cách sử dụng::

khe int;

ioctl(fd, CDROM_MEDIA_CHANGED, khe cắm);

đầu vào:
		Số vị trí cần kiểm tra, luôn bằng 0 ngoại trừ máy hát tự động.

Cũng có thể là các giá trị đặc biệt CDSL_NONE hoặc CDSL_CURRENT

đầu ra:
		Giá trị trả về Ioctl là 0 hoặc 1 tùy thuộc vào phương tiện

đã được thay đổi hoặc -1 do lỗi.

lỗi trả về:
	  - ENOSYS Drive không thể phát hiện thay đổi phương tiện
	  - EINVAL Số Slot vượt quá dung lượng ổ đĩa
	  - ENOMEM Hết bộ nhớ



CDROM_DRIVE_STATUS
	Nhận vị trí khay, v.v.


cách sử dụng::

khe int;

ioctl(fd, CDROM_DRIVE_STATUS, khe cắm);

đầu vào:
		Số vị trí cần kiểm tra, luôn bằng 0 ngoại trừ máy hát tự động.

Cũng có thể là các giá trị đặc biệt CDSL_NONE hoặc CDSL_CURRENT

đầu ra:
		Giá trị trả về Ioctl sẽ là một trong các giá trị sau

từ <linux/cdrom.h>:

=================================================
	    CDS_NO_INFO Không có thông tin.
	    CDS_NO_DISC
	    CDS_TRAY_OPEN
	    CDS_DRIVE_NOT_READY
	    CDS_DISC_OK
	    -1 lỗi
	    =================================================

lỗi trả về:
	  - ENOSYS Drive không thể phát hiện trạng thái ổ đĩa
	  - EINVAL Số Slot vượt quá dung lượng ổ đĩa
	  - ENOMEM Hết bộ nhớ




CDROM_DISC_STATUS
	Nhận loại đĩa, v.v.


cách sử dụng::

ioctl(fd, CDROM_DISC_STATUS, 0);


đầu vào:
		không có


đầu ra:
		Giá trị trả về Ioctl sẽ là một trong các giá trị sau

từ <linux/cdrom.h>:

-CDS_NO_INFO
	    -CDS_AUDIO
	    -CDS_MIXED
	    -CDS_XA_2_2
	    -CDS_XA_2_1
	    -CDS_DATA_1

lỗi trả về:
		hiện tại không có

ghi chú:
	    - Trạng thái nhận xét mã nguồn::


Được rồi, đây là lúc vấn đề bắt đầu.  Giao diện hiện tại cho
		ioctl CDROM_DISC_STATUS bị lỗi.  Nó làm cho sự giả dối
		giả định rằng tất cả các đĩa CD đều là CDS_DATA_1 hoặc tất cả CDS_AUDIO, v.v.
		Thật không may, mặc dù điều này thường xảy ra nhưng nó cũng
		rất phổ biến đối với các đĩa CD có một số bản nhạc chứa dữ liệu và một số
		bài hát có âm thanh.	Chỉ vì tôi thấy thích nên tôi tuyên bố
		sau đây là cách tốt nhất để đối phó.  Nếu đĩa CD có
		ANY theo dõi dữ liệu trên đó, nó sẽ được trả về dưới dạng CD dữ liệu.
		Nếu nó có bài XA nào thì tôi sẽ trả lại như vậy.	Bây giờ tôi
		có thể đơn giản hóa giao diện này bằng cách kết hợp các kết quả trả về này với
		ở trên, nhưng điều này thể hiện rõ hơn vấn đề
		với giao diện hiện tại.  Tiếc là cái này không được thiết kế
		để sử dụng bitmasks... -Erik

Chà, bây giờ chúng ta có tùy chọn CDS_MIXED: một đĩa CD loại hỗn hợp.
		Các lập trình viên ở cấp độ người dùng có thể cảm thấy ioctl không phù hợp lắm
		hữu ích.
				---David




CDROM_CHANGER_NSLOTS
	Nhận số lượng vị trí


cách sử dụng::

ioctl(fd, CDROM_CHANGER_NSLOTS, 0);


đầu vào:
		không có


đầu ra:
		Giá trị trả về ioctl sẽ là số lượng vị trí trong một
		Bộ đổi đĩa CD.  Thông thường là 1 cho các thiết bị không có nhiều đĩa.

lỗi trả về:
		không có



CDROM_LOCKDOOR
	khóa hoặc mở khóa cửa


cách sử dụng::

khóa int;

ioctl(fd, CDROM_LOCKDOOR, khóa);

đầu vào:
		Cờ khóa cửa, 1=khóa, 0=mở khóa


đầu ra:
		không có


lỗi trả về:
	  -EDRIVE_CANT_DO_THIS

Chức năng khóa cửa không được hỗ trợ.
	  -EBUSY

Cố gắng mở khóa khi có nhiều người dùng
				mở ổ đĩa chứ không phải CAP_SYS_ADMIN

ghi chú:
		Kể từ phiên bản 2.6.8.1, cờ khóa là khóa toàn cục, nghĩa là
		tất cả các ổ đĩa CD sẽ bị khóa hoặc mở khóa cùng nhau.  Đây là
		có lẽ là một lỗi.

Giá trị EDRIVE_CANT_DO_THIS được xác định trong <linux/cdrom.h>
		và hiện tại (2.6.8.1) giống với EOPNOTSUPP



CDROM_DEBUG
	Bật/tắt thông báo gỡ lỗi


cách sử dụng::

gỡ lỗi int;

ioctl(fd, CDROM_DEBUG, gỡ lỗi);

đầu vào:
		Cờ gỡ lỗi Cdrom, 0=vô hiệu hóa, 1=bật


đầu ra:
		Giá trị trả về ioctl sẽ là cờ gỡ lỗi mới.


trả về lỗi:
	  - Truy cập EACCES bị từ chối: yêu cầu CAP_SYS_ADMIN



CDROM_GET_CAPABILITY
	có được khả năng


cách sử dụng::

ioctl(fd, CDROM_GET_CAPABILITY, 0);


đầu vào:
		không có


đầu ra:
		Giá trị trả về ioctl là khả năng của thiết bị hiện tại
		cờ.  Xem CDC_CLOSE_TRAY, CDC_OPEN_TRAY, v.v.



CDROMAUDIOBUFSIZ
	đặt kích thước bộ đệm âm thanh


cách sử dụng::

int arg;

ioctl(fd, CDROMAUDIOBUFSIZ, val);

đầu vào:
		Kích thước bộ đệm âm thanh mới


đầu ra:
		Giá trị trả về ioctl là kích thước bộ đệm âm thanh mới hoặc -1
		về lỗi.

trả về lỗi:
	  - ENOSYS Không được trình điều khiển này hỗ trợ.

ghi chú:
		Không được hỗ trợ bởi tất cả các trình điều khiển.




DVD_READ_STRUCT Đọc cấu trúc

cách sử dụng::

dvd_struct s;

ioctl(fd, DVD_READ_STRUCT, &s);

đầu vào:
		Cấu trúc dvd_struct, chứa:

===================================================================
	    loại chỉ định thông tin mong muốn, một trong những
				DVD_STRUCT_PHYSICAL, DVD_STRUCT_COPYRIGHT,
				DVD_STRUCT_DISCKEY, DVD_STRUCT_BCA,
				DVD_STRUCT_MANUFACT
	    lớp vật lý.layer_num mong muốn, được lập chỉ mục từ 0
	    lớp bản quyền.layer_num mong muốn, được lập chỉ mục từ 0
	    diskkey.agid
	    ===================================================================

đầu ra:
		Cấu trúc dvd_struct, chứa:

=======================================================
	    vật lý cho loại == DVD_STRUCT_PHYSICAL
	    bản quyền cho loại == DVD_STRUCT_COPYRIGHT
	    disckey.value cho loại == DVD_STRUCT_DISCKEY
	    bca.{len,value} cho loại == DVD_STRUCT_BCA
	    sản xuất.{len,valu} cho loại == DVD_STRUCT_MANUFACT
	    =======================================================

lỗi trả về:
	  - EINVAL vật lý.layer_num vượt quá số lớp
	  - EIO Nhận được phản hồi không hợp lệ từ ổ đĩa



Cấu trúc ghi DVD_WRITE_STRUCT

Chưa được triển khai kể từ phiên bản 2.6.8.1



Xác thực DVD_AUTH

cách sử dụng::

dvd_authinfo ai;

ioctl(fd, DVD_AUTH, &ai);

đầu vào:
		cấu trúc dvd_authinfo.  Xem <linux/cdrom.h>


đầu ra:
		cấu trúc dvd_authinfo.


trả về lỗi:
	  - ENOTTY ai.type không được công nhận.



CDROM_SEND_PACKET
	gửi một gói đến ổ đĩa


cách sử dụng::

struct cdrom_generic_command cgc;

ioctl(fd, CDROM_SEND_PACKET, &cgc);

đầu vào:
		Cấu trúc cdrom_generic_command chứa gói tin cần gửi.


đầu ra:
		không có

Cấu trúc cdrom_generic_command chứa kết quả.

trả về lỗi:
	  -EIO

lệnh không thành công.
	  -EPERM

Hoạt động không được phép, bởi vì một
			lệnh ghi đã được thử trên một ổ đĩa
			được mở ở chế độ chỉ đọc hoặc do lệnh
			yêu cầu CAP_SYS_RAWIO
	  -EINVAL

cgc.data_direction chưa được đặt



CDROM_NEXT_WRITABLE
	lấy khối có thể ghi tiếp theo


cách sử dụng::

tiếp theo lâu dài;

ioctl(fd, CDROM_NEXT_WRITABLE, &next);

đầu vào:
		không có


đầu ra:
		Khối có thể ghi tiếp theo.


ghi chú:
		Nếu thiết bị không hỗ trợ trực tiếp ioctl này,

ioctl sẽ trả về CDROM_LAST_WRITTEN + 7.



CDROM_LAST_WRITTEN
	lấy khối cuối cùng được ghi trên đĩa


cách sử dụng::

kéo dài;

ioctl(fd, CDROM_LAST_WRITTEN, &last);

đầu vào:
		không có


đầu ra:
		Khối cuối cùng được ghi trên đĩa


ghi chú:
		Nếu thiết bị không hỗ trợ trực tiếp ioctl này,
		kết quả được lấy từ mục lục của đĩa.  Nếu
		không thể đọc được mục lục, ioctl này trả về một
		lỗi.
