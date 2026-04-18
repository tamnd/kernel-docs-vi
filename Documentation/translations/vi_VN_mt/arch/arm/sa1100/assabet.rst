.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/sa1100/assabet.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Bo mạch Intel Assabet (đánh giá SA-1110)
============================================

Xin vui lòng xem:
ZZ0000ZZ

Ngoài ra một số ghi chú của John G Dorsey <jd5q@andrew.cmu.edu>:
ZZ0000ZZ


Xây dựng hạt nhân
-------------------

Để xây dựng kernel với giá trị mặc định hiện tại::

tạo assabet_defconfig
	tạo cấu hình cũ
	tạo zImage

Hình ảnh hạt nhân thu được sẽ có sẵn trong linux/arch/arm/boot/zImage.


Cài đặt bộ nạp khởi động
-----------------------

Hiện có một số bộ tải khởi động có thể khởi động Linux trên Assabet:

BLOB (ZZ0000ZZ

BLOB là bộ tải khởi động được sử dụng trong dự án LART.  Một số đóng góp
   các bản vá đã được hợp nhất vào BLOB để thêm hỗ trợ cho Assabet.

Bản vá Bootldr của Compaq + John Dorsey để hỗ trợ Assabet
(ZZ0000ZZ
(ZZ0001ZZ

Bootldr là bộ nạp khởi động được Compaq phát triển cho Pocket PC iPAQ.
   John Dorsey đã tạo ra các bản vá bổ sung để hỗ trợ thêm cho Assabet và
   hệ thống tập tin JFFS.

RedBoot (ZZ0000ZZ

RedBoot là bộ nạp khởi động được phát triển bởi Red Hat dựa trên eCos RTOS
   lớp trừu tượng phần cứng  Nó hỗ trợ Assabet trong số nhiều thứ khác
   nền tảng phần cứng.

RedBoot hiện là lựa chọn được khuyên dùng vì đây là lựa chọn duy nhất có
hỗ trợ mạng và được duy trì tích cực nhất.

Các ví dụ ngắn gọn về cách khởi động Linux bằng RedBoot được trình bày bên dưới.  Nhưng trước tiên
bạn cần cài đặt RedBoot trong bộ nhớ flash của mình.  Một người biết làm việc
nhị phân RedBoot được biên dịch sẵn có sẵn từ vị trí sau:

- ftp://ftp.netwinder.org/users/n/nico/
- ftp://ftp.arm.linux.org.uk/pub/linux/arm/people/nico/
- ftp://ftp.handhelds.org/pub/linux/arm/sa-1100-patches/

Hãy tìm redboot-assabet*.tgz.  Một số thông tin cài đặt được cung cấp trong
redboot-assabet*.txt.


Cấu hình RedBoot ban đầu
-----------------------------

Các lệnh được sử dụng ở đây được giải thích trong Hướng dẫn sử dụng RedBoot có sẵn
trực tuyến tại ZZ0000ZZ
Hãy tham khảo nó để được giải thích.

Nếu bạn có card mạng CF (bộ Assabet của tôi chứa CF+ LP-E từ
Socket Communications Inc.), bạn nên cân nhắc sử dụng nó cho TFTP
chuyển tập tin.  Bạn phải chèn nó trước khi RedBoot chạy vì nó không thể phát hiện được
nó một cách năng động.

Để khởi tạo thư mục flash::

fis init -f

Để khởi tạo cài đặt không thay đổi, chẳng hạn như bạn muốn sử dụng BOOTP hay
một địa chỉ IP tĩnh, v.v., hãy sử dụng lệnh này ::

fconfig -i


Viết hình ảnh hạt nhân vào flash
---------------------------------

Đầu tiên, ảnh kernel phải được tải vào RAM.  Nếu bạn có tệp zImage
có sẵn trên máy chủ TFTP::

tải zImage -r -b 0x100000

Nếu bạn muốn sử dụng tải lên Y-Modem qua cổng nối tiếp ::

tải -m ymodem -r -b 0x100000

Để ghi nó vào flash::

fis tạo "nhân Linux" -b 0x100000 -l 0xc0000


Khởi động kernel
------------------

Kernel vẫn yêu cầu hệ thống tập tin để khởi động.  Một hình ảnh ramdisk có thể được tải
như sau::

tải ramdisk_image.gz -r -b 0x800000

Một lần nữa, tải lên Y-Modem có thể được sử dụng thay cho TFTP bằng cách thay thế tên tệp
bởi '-y ymodem'.

Bây giờ kernel có thể được lấy từ flash như thế này ::

fis tải "nhân Linux"

hoặc được tải như mô tả trước đây.  Để khởi động kernel::

thực thi -b 0x100000 -l 0xc0000

Hình ảnh đĩa RAM cũng có thể được lưu vào flash, nhưng có những cách tốt hơn
giải pháp cho hệ thống tập tin trên flash như được đề cập dưới đây.


Sử dụng JFFS2
-----------

Sử dụng JFFS2 (Hệ thống tệp Flash nhật ký thứ hai) có lẽ là cách tốt nhất
cách thuận tiện để lưu trữ hệ thống tập tin có thể ghi vào flash.  JFFS2 được sử dụng trong
kết hợp với lớp MTD chịu trách nhiệm về đèn flash ở mức độ thấp
quản lý.  Thông tin thêm về Linux MTD có thể được tìm thấy trực tuyến tại:
Cách thực hiện ZZ0000ZZ A JFFS với một số thông tin về
việc tạo hình ảnh JFFS/JFFS2 có sẵn trên cùng một trang.

Ví dụ: một hình ảnh JFFS2 mẫu có thể được lấy từ cùng một trang FTP
được đề cập bên dưới cho hình ảnh RedBoot được biên dịch trước.

Để tải tập tin này::

tải sample_img.jffs2 -r -b 0x100000

Kết quả sẽ giống như::

RedBoot> tải sample_img.jffs2 -r -b 0x100000
	Tệp thô được tải 0x00100000-0x00377424

Bây giờ chúng ta phải biết kích thước của flash chưa được phân bổ ::

miễn phí

Kết quả::

RedBoot> miễn phí
	  0x500E0000 .. 0x503C0000

Các giá trị trên có thể khác nhau tùy thuộc vào kích thước của hệ thống tập tin và
loại đèn flash.  Xem cách sử dụng của họ dưới đây làm ví dụ và quan tâm đến
thay thế của bạn một cách thích hợp.

Chúng ta phải xác định một số giá trị::

kích thước của flash chưa được phân bổ: 0x503c0000 - 0x500e0000 = 0x2e0000
	kích thước của hình ảnh hệ thống tập tin: 0x00377424 - 0x00100000 = 0x277424

Tất nhiên, chúng tôi muốn phù hợp với hình ảnh hệ thống tập tin, nhưng chúng tôi cũng muốn cung cấp tất cả
không gian flash còn lại là tốt.  Để viết nó::

mở khóa fis -f 0x500E0000 -l 0x2e0000
	fis xóa -f 0x500E0000 -l 0x2e0000
	ghi fis -b 0x100000 -l 0x277424 -f 0x500E0000
	fis tạo "JFFS2" -n -f 0x500E0000 -l 0x2e0000

Bây giờ hệ thống tập tin được liên kết với "phân vùng" MTD sau khi Linux phát hiện ra
chúng là gì trong quá trình khởi động.  Từ Redboot, lệnh 'fis list'
hiển thị chúng::

RedBoot> danh sách fis
	Tên FLASH địa chỉ Mem địa chỉ Chiều dài Điểm vào
	RedBoot 0x50000000 0x50000000 0x00020000 0x00000000
	Cấu hình RedBoot 0x503C0000 0x503C0000 0x00020000 0x00000000
	Thư mục FIS 0x503E0000 0x503E0000 0x00020000 0x00000000
	Nhân Linux 0x50020000 0x00100000 0x000C0000 0x00000000
	JFFS2 0x500E0000 0x500E0000 0x002E0000 0x00000000

Tuy nhiên Linux sẽ hiển thị một cái gì đó như ::

Đèn flash SA1100: thăm dò bus flash 32 bit
	Đèn flash SA1100: Đã tìm thấy 2 thiết bị x16 ở 0x0 ở chế độ 32 bit
	Sử dụng định nghĩa phân vùng RedBoot
	Tạo 5 phân vùng MTD trên "SA1100 flash":
	0x00000000-0x00020000 : "RedBoot"
	0x00020000-0x000e0000 : "Nhân Linux"
	0x000e0000-0x003c0000 : "JFFS2"
	0x003c0000-0x003e0000 : "Cấu hình RedBoot"
	0x003e0000-0x00400000 : "Thư mục FIS"

Điều quan trọng ở đây là vị trí của phân vùng mà chúng ta quan tâm,
đó là cái thứ ba  Trong Linux, điều này tương ứng với /dev/mtdblock2.
Do đó, để khởi động Linux bằng kernel và hệ thống tập tin gốc của nó trong flash, chúng ta
cần lệnh RedBoot này::

fis tải "nhân Linux"
	thực thi -b 0x100000 -l 0xc0000 -c "root=/dev/mtdblock2"

Tất nhiên, các hệ thống tệp khác ngoài JFFS có thể được sử dụng, chẳng hạn như cramfs.
Bạn có thể muốn khởi động bằng hệ thống tập tin gốc trên NFS, v.v. Nó cũng
có thể, và đôi khi thuận tiện hơn, để flash hệ thống tập tin trực tiếp từ
trong Linux khi được khởi động từ đĩa RAM hoặc NFS.  Kho lưu trữ Linux MTD có
nhiều công cụ để xử lý bộ nhớ flash, chẳng hạn như xóa nó.  JFFS2
sau đó có thể được gắn trực tiếp vào một phân vùng mới bị xóa và các tập tin có thể được
sao chép trực tiếp.  Vân vân...


Kịch bản RedBoot
-----------------

Tất cả các lệnh trên sẽ không hữu ích lắm nếu chúng phải được gõ vào mỗi lần
thời điểm Assabet được khởi động lại.  Vì vậy có thể tự động khởi động
xử lý bằng khả năng viết kịch bản của RedBoot.

Ví dụ: tôi sử dụng cái này để khởi động Linux bằng cả kernel và ramdisk
hình ảnh được lấy từ máy chủ TFTP trên mạng::

RedBoot> fconfig
	Chạy tập lệnh khi khởi động: sai đúng
	Kịch bản khởi động:
	Nhập script, kết thúc bằng dòng trống
	>> tải zImage -r -b 0x100000
	>> tải ramdisk_ks.gz -r -b 0x800000
	>> thực thi -b 0x100000 -l 0xc0000
	>>
	Hết thời gian chờ tập lệnh khởi động (độ phân giải 1000ms): 3
	Sử dụng BOOTP cho cấu hình mạng: đúng
	Cổng kết nối GDB: 9000
	Gỡ lỗi mạng khi khởi động: sai
	Cập nhật cấu hình không thay đổi RedBoot - bạn có chắc chắn không (y/n)? y

Sau đó, việc khởi động lại Assabet chỉ là chờ lời nhắc đăng nhập.



Nicolas Pitre
nico@fluxnic.net

Ngày 12 tháng 6 năm 2001


Trạng thái các thiết bị ngoại vi trong cây -rmk (cập nhật 10/14/2001)
-------------------------------------------------------

Assabet:
 Cổng nối tiếp:
  Đài phát thanh: TX, RX, CTS, DSR, DCD, RI
   - Chiều: Chưa kiểm tra.
   - COM: TX, RX, CTS, DSR, DCD, RTS, DTR, PM
   - Chiều: Chưa kiểm tra.
   - I2C: Đã triển khai, chưa kiểm tra đầy đủ.
   - L3: Đã test đầy đủ, đạt.
   - Chiều: Chưa kiểm tra.

Video:
  - LCD: Đã được kiểm tra đầy đủ.  Thủ tướng

(LCD không thích bị làm trống khi kết nối neponset)

- Video out: Chưa đầy đủ

Âm thanh:
  UDA1341:
  - Phát lại: Đã kiểm tra đầy đủ, đạt.
  - Ghi chép: Đã thực hiện, chưa kiểm tra.
  - Chiều: Chưa kiểm tra.

UCB1200:
  - Phát âm thanh: Đã triển khai, chưa thử nghiệm nhiều.
  - Audio rec: Đã triển khai, chưa thử nghiệm nhiều.
  - Phát âm thanh Telco: Đã triển khai, chưa thử nghiệm nhiều.
  - Telco audio rec: Đã triển khai, chưa thử nghiệm nhiều.
  - Điều khiển POTS: Không
  - Màn hình cảm ứng: Có
  - Chiều: Chưa kiểm tra.

Khác:
  -PCMCIA:
  - LPE: Đã kiểm tra đầy đủ, đạt.
  -USB: Không
  -IRDA:
  - SIR: Đã kiểm tra đầy đủ, đạt.
  - FIR: Đã kiểm tra đầy đủ, đạt.
  - Chiều: Chưa kiểm tra.

Neponset:
 Cổng nối tiếp:
  - COM1,2: TX, RX, CTS, DSR, DCD, RTS, DTR
  - Chiều: Chưa kiểm tra.
  - USB: Đã triển khai, chưa thử nghiệm nhiều.
  - PCMCIA: Đã triển khai, chưa thử nghiệm nhiều.
  - CF: Đã triển khai, chưa thử nghiệm nhiều.
  - Chiều: Chưa kiểm tra.

Nhiều thứ khác có thể được tìm thấy trong cây -np (Nicolas Pitre).
