.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/usb-serial.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
nối tiếp USB
==========

Giới thiệu
============

Trình điều khiển nối tiếp USB hiện hỗ trợ một số USB khác nhau để
  các sản phẩm bộ chuyển đổi nối tiếp, cũng như một số thiết bị sử dụng bộ chuyển đổi nối tiếp
  giao diện từ không gian người dùng để nói chuyện với thiết bị.

Xem phần sản phẩm riêng lẻ bên dưới để biết thông tin cụ thể về
  các thiết bị khác nhau.


Cấu hình
=============

Hiện tại trình điều khiển có thể xử lý tới 256 giao diện nối tiếp khác nhau tại
  một lần.

Số chính mà trình điều khiển sử dụng là 188 vì vậy để sử dụng trình điều khiển,
    tạo các nút sau::

mknod /dev/ttyUSB0 c 188 0
	mknod /dev/ttyUSB1 c 188 1
	mknod /dev/ttyUSB2 c 188 2
	mknod /dev/ttyUSB3 c 188 3
		.
		.
		.
	mknod /dev/ttyUSB254 c 188 254
	mknod /dev/ttyUSB255 c 188 255

Khi thiết bị được kết nối và được trình điều khiển nhận dạng, trình điều khiển sẽ
  sẽ in ra nhật ký hệ thống, (các) nút nào thiết bị đã bị ràng buộc
  đến.


Các thiết bị cụ thể được hỗ trợ
==========================


Bộ chuyển đổi ConnectTech WhiteHEAT 4 cổng
--------------------------------------

ConnectTech đã rất sẵn sàng cung cấp thông tin về
  thiết bị, bao gồm cả việc cung cấp một thiết bị để kiểm tra.

Trình điều khiển được hỗ trợ chính thức bởi Connect Tech Inc.
  ZZ0000ZZ

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ
  Phòng Hỗ trợ của Connect Tech tại support@connecttech.com


Trình điều khiển HandSpring Visor, Palm USB và Clié USB
-----------------------------------------------

Trình điều khiển này hoạt động với tất cả HandSpring USB, Palm USB và Sony Clié USB
  thiết bị.

Chỉ khi thiết bị cố gắng kết nối với máy chủ, thiết bị mới hiển thị
  lên đến máy chủ dưới dạng thiết bị USB hợp lệ. Khi điều này xảy ra, thiết bị sẽ
  được liệt kê chính xác, gán một cổng và sau đó giao tiếp _nên_ được thực hiện
  có thể. Trình điều khiển dọn dẹp đúng cách khi tháo thiết bị hoặc
  kết nối bị hủy trên thiết bị.

NOTE:
    Điều này có nghĩa là để nói chuyện với thiết bị, nút đồng bộ phải được
    nhấn BEFORE để cố gắng kết nối bất kỳ chương trình nào với thiết bị.
    Điều này đi ngược lại với tài liệu hiện tại dành cho Pilot-xfer và các tài liệu khác
    gói, nhưng là cách duy nhất để nó hoạt động do phần cứng
    trong thiết bị.

Khi thiết bị được kết nối, hãy thử nói chuyện với thiết bị trên cổng thứ hai
  (thường là /dev/ttyUSB1 nếu bạn không có bất kỳ cổng USB nối tiếp nào khác
  thiết bị trong hệ thống.) Nhật ký hệ thống sẽ cho bạn biết cổng nào được
  cổng được sử dụng để truyền HotSync. Cổng "Chung" có thể được sử dụng
  để liên lạc với thiết bị khác, chẳng hạn như liên kết PPP.

Đối với một số thiết bị Sony Clié, /dev/ttyUSB0 phải được sử dụng để giao tiếp với
  thiết bị.  Điều này đúng với tất cả các thiết bị có hệ điều hành phiên bản 3.5 và hầu hết các thiết bị
  đã nâng cấp flash lên phiên bản hệ điều hành mới hơn.  Xem
  nhật ký hệ thống kernel để biết thông tin về cổng chính xác để sử dụng.

Nếu sau khi nhấn nút đồng bộ, không có gì hiển thị trong nhật ký hệ thống,
  hãy thử đặt lại thiết bị, trước tiên là thiết lập lại nóng, sau đó là thiết lập lại nguội nếu
  cần thiết.  Một số thiết bị cần điều này trước khi có thể giao tiếp với cổng USB
  đúng cách.

Các thiết bị không được biên dịch vào kernel có thể được chỉ định bằng mô-đun
  các thông số.  ví dụ. nhà cung cấp tấm che modprobe=0x54c sản phẩm=0x66

Có một trang web và danh sách gửi thư cho phần này của trình điều khiển tại:
  ZZ0000ZZ

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với Greg
  Kroah-Hartman tại greg@kroah.com


Trình điều khiển PocketPC PDA
-------------------

Driver này có thể dùng để kết nối với Compaq iPAQ, HP Jornada, Casio EM500
  và các PDA khác chạy Windows CE 3.0 hoặc PocketPC 2002 sử dụng USB
  cáp/giá đỡ.
  Hầu hết các thiết bị được ActiveSync hỗ trợ đều được hỗ trợ ngay lập tức.
  Đối với những người khác, vui lòng sử dụng các tham số mô-đun để chỉ định sản phẩm và nhà cung cấp
  id. ví dụ. nhà cung cấp modprobe ipaq=0x3f0 sản phẩm=0x1125

Trình điều khiển hiển thị giao diện nối tiếp (thường là trên /dev/ttyUSB0) trên
  cái nào có thể chạy ppp và thiết lập liên kết TCP/IP tới PDA. Một lần này
  hoàn tất, bạn có thể chuyển tập tin, sao lưu, tải xuống email, v.v.
  lợi thế đáng kể của việc sử dụng USB là tốc độ - Tôi có thể nhận được 73 đến 113
  kbyte/giây để tải xuống/tải lên iPAQ của tôi.

Trình điều khiển này chỉ là một trong số các thành phần cần thiết để sử dụng
  kết nối USB. Vui lòng truy cập ZZ0000ZZ
  chứa các gói cần thiết và cách thực hiện từng bước đơn giản.

Sau khi kết nối, bạn có thể sử dụng các chương trình Win CE như ftpView, Pocket Outlook
  từ PDA và xcerdisp, đồng bộ hóa các tiện ích từ phía Linux.

Để sử dụng Pocket IE, hãy làm theo hướng dẫn tại
  ZZ0000ZZ để đạt được điều tương tự
  trên Win98. Bỏ qua phần máy chủ proxy; Linux hoàn toàn có khả năng chuyển tiếp
  các gói không giống như Win98. Một sửa đổi khác được yêu cầu ít nhất là đối với
  iPAQ - tắt tính năng tự động đồng bộ hóa bằng cách đi tới menu Bắt đầu/Cài đặt/Kết nối
  và bỏ chọn hộp "Tự động đồng bộ hóa ...". đi đến
  Bắt đầu/Chương trình/Kết nối, kết nối cáp và chọn "usbdial" (hoặc
  bất cứ tên nào bạn đặt cho kết nối USB mới của mình). Cuối cùng bạn nên gió
  xuất hiện cửa sổ "Đã kết nối với usbdial" với trạng thái hiển thị là đã kết nối.
  Bây giờ hãy khởi động PIE và duyệt đi.

Nếu vì lý do nào đó nó không hoạt động, hãy tải cả mô-đun usbserial và ipaq
  với tham số mô-đun "gỡ lỗi" được đặt thành 1 và kiểm tra nhật ký hệ thống.
  Bạn cũng có thể thử đặt lại mềm PDA của mình trước khi thử kết nối.

Chức năng khác có thể có tùy thuộc vào PDA của bạn. Theo
  Wes Cilldhaire <billybobjoehenrybob@hotmail.com>, với Toshiba E570,
  ...if you boot into the bootloader (hold down the power when hitting the
nút reset, tiếp tục giữ nguồn cho đến khi màn hình bootloader
  được hiển thị), sau đó đặt nó vào giá đỡ với trình điều khiển ipaq đã được tải, mở
  một thiết bị đầu cuối trên /dev/ttyUSB0, nó sẽ cung cấp cho bạn một thiết bị đầu cuối "USB Reflash", có thể
  được sử dụng để flash ROM, cũng như mã microP.. rất nhiều cho nhu cầu
  Cáp nối tiếp trị giá 350 USD của Toshiba để nhấp nháy!! :D
  NOTE: NOT này đã được thử nghiệm. Sử dụng có nguy cơ của riêng bạn.

Mọi thắc mắc hoặc vấn đề về driver vui lòng liên hệ Ganesh
  Varadarajan <ganesh@veritas.com>


Bộ chuyển đổi nối tiếp Keyspan PDA
--------------------------

Bộ điều hợp nối tiếp DB-9 một cổng, được đẩy dưới dạng bộ điều hợp PDA cho iMac (chủ yếu
  được bán trong danh mục Macintosh, có dạng dongle màu trắng/xanh mờ).
  Thiết bị khá đơn giản. Firmware là homebrew.
  Trình điều khiển này cũng hoạt động cho bộ điều hợp nối tiếp một cổng Xircom/Entrega.

Tình trạng hiện tại:

Những thứ hoạt động:
     - đầu vào/đầu ra cơ bản (được thử nghiệm với 'cu')
     - chặn ghi khi dòng nối tiếp không thể theo kịp
     - thay đổi tốc độ truyền (lên tới 115200)
     - nhận/cài đặt các chân điều khiển modem (TIOCM{GET,SET,BIS,BIC})
     - gửi ngắt (mặc dù thời lượng có vẻ đáng ngờ)

Những điều không:
     - chuỗi thiết bị (được ghi bởi kernel) có rác nhị phân ở cuối
     - ID thiết bị không đúng, có thể xung đột với các sản phẩm Keyspan khác
     - thay đổi tốc độ truyền phải xóa tx/rx để tránh một nửa ký tự bị đọc sai

Những điều lớn lao trong danh sách việc cần làm:
     - tính chẵn lẻ, 7 so với 8 bit trên mỗi ký tự, 1 hoặc 2 bit dừng
     - Kiểm soát dòng chảy CTNH
     - không phải tất cả các bộ mô tả USB tiêu chuẩn đều được xử lý:
       Get_Status, Set_Feature, O_NONBLOCK, chọn()

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với Brian
  Warner tại Warner@lothar.com


Bộ điều hợp nối tiếp dòng Keyspan USA
----------------------------------

Bộ điều hợp cổng đơn, kép và bốn cổng - trình điều khiển sử dụng Keyspan được cung cấp
  firmware và đang được phát triển với sự hỗ trợ của họ.

Tình trạng hiện tại:

USA-18X, USA-28X, USA-19, USA-19W và USA-49W được hỗ trợ và
    đã được kiểm tra khá kỹ lưỡng ở nhiều tốc độ truyền khác nhau với 8-N-1
    cài đặt ký tự.  Độ dài ký tự và thiết lập chẵn lẻ khác là
    hiện chưa được kiểm tra.

USA-28 chưa được hỗ trợ mặc dù làm như vậy sẽ khá tốt
    đơn giản.  Liên hệ với người bảo trì nếu bạn yêu cầu điều này
    chức năng.

Thêm thông tin có sẵn tại:

ZZ0000ZZ

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với Hugh
  Nhược điểm tại Hugh@misc.nu


Trình điều khiển nối tiếp cổng đơn FTDI
------------------------------

Đây là bộ chuyển đổi nối tiếp DB-25 một cổng.

Các thiết bị được hỗ trợ bao gồm:

- TripNav TN-200 USB GPS
                - Cục Kỹ thuật Navis CH-4711 USB GPS

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với Bill Ryder.


Màn hình LCD ZyXEL omni.net cộng với ISDN TA
-------------------------------

Đây là ISDN TA. Hãy báo cáo cả những thành công và rắc rối cho
  azummo@towertech.it


Trình điều khiển nối tiếp gia đình Cypress M8 CY4601
--------------------------------------

Trình điều khiển này phần lớn được phát triển bởi Neil "koyama" Whelchel.  Nó
  đã được cải thiện kể từ hình thức trước đó để hỗ trợ nối tiếp động
  cài đặt dòng và xử lý dòng được cải thiện.  Người lái xe là chủ yếu nhất
  một phần ổn định và đã được thử nghiệm trên máy smp. (p2 kép)

Các chipset được hỗ trợ thuộc dòng CY4601:

CY7C63723, CY7C63742, CY7C63743, CY7C64013

Các thiết bị được hỗ trợ:

- USB Earthmate GPS của DeLorme (vòm lp SiRF Star II)
		- Bộ chuyển đổi Cypress HID->COM RS232

Lưu ý:
			Cypress Semiconductor tuyên bố không có liên kết với
			thiết bị ẩn->com.

Hầu hết các thiết bị sử dụng chipset thuộc dòng CY4601 đều phải
     làm việc với tài xế.  Miễn là chúng vẫn đúng với CY4601
     đặc điểm kỹ thuật usbserial.

Ghi chú kỹ thuật:

Earthmate bắt đầu ở 4800 8N1 theo mặc định... trình điều khiển sẽ
	khi bắt đầu cài đặt này.  lõi usbserial cung cấp phần còn lại
	của cài đặt thuật ngữ, cùng với một số thuật ngữ tùy chỉnh để
	đầu ra có định dạng phù hợp và có thể phân tích cú pháp.

Thiết bị có thể được đưa vào chế độ sirf bằng cách đưa ra lệnh NMEA ::

$PSRF100,<giao thức>,<baud>,<databits>,<stopbits>,<chẵn lẻ>*CHECKSUM
		$PSRF100,0,9600,8,1,0*0C

Sau đó chỉ cần thay đổi thuật ngữ cổng để phù hợp với điều này là đủ
		để bắt đầu giao tiếp.

Theo như tôi có thể nói thì nó hỗ trợ khá nhiều lệnh sirf như
	tài liệu trực tuyến có sẵn với phần sụn 2.31, với một số chưa biết
	id tin nhắn.

Bộ điều hợp hid->com có ​​thể chạy ở tốc độ truyền tối đa 115200bps.  Xin lưu ý
	rằng thiết bị gặp sự cố hoặc không có khả năng tăng điện áp đường dây đúng cách.
	Sẽ ổn thôi với các liên kết modem rỗng, miễn là bạn không cố gắng liên kết hai
	với nhau mà không cần hack bộ chuyển đổi để đặt đường dây lên cao.

Người lái xe an toàn.  Hiệu suất với driver khá thấp khi sử dụng
	nó để truyền tập tin.  Việc này đang được thực hiện, nhưng tôi sẵn lòng
	chấp nhận các bản vá.  Hàng đợi đô thị hoặc bộ đệm gói có thể phù hợp ở đây.

Nếu bạn có bất kỳ câu hỏi, vấn đề, bản vá, yêu cầu tính năng, v.v., bạn có thể
	liên hệ với tôi ở đây qua email:

dignome@gmail.com

(các vấn đề/bản vá lỗi của bạn có thể được gửi luân phiên tới usb-devel)


Trình điều khiển Digi AccelePort
----------------------

Trình điều khiển này hỗ trợ các thiết bị Digi AccelePort USB 2 và 4, 2 cổng
  (cộng với một cổng song song) và bộ chuyển đổi nối tiếp 4 cổng USB.  Người lái xe
  NOT chưa hỗ trợ Digi AccelePort USB 8.

Trình điều khiển này hoạt động theo SMP với trình điều khiển usb-uhci.  Nó không
  hoạt động theo SMP với trình điều khiển uhci.

Trình điều khiển nói chung đang hoạt động, mặc dù chúng tôi vẫn còn một vài ioctls nữa
  để thực hiện và kiểm tra và gỡ lỗi lần cuối.  Cổng song song
  trên USB 2 được hỗ trợ dưới dạng bộ chuyển đổi nối tiếp sang song song; ở nơi khác
  nói cách khác, nó xuất hiện dưới dạng một cổng nối tiếp USB khác trên Linux, mặc dù
  về mặt vật lý nó thực sự là một cổng song song.  Digi Acceleport USB 8
  vẫn chưa được hỗ trợ.

Vui lòng liên hệ với Peter Berger (pberger@brimson.com) hoặc Al Borchers
  (alborchers@steinerpoint.com) nếu có thắc mắc hoặc vấn đề về vấn đề này
  người lái xe.


Bộ chuyển đổi nối tiếp Belkin USB F5U103
--------------------------------

Bộ điều hợp nối tiếp DB-9/PS-2 một cổng của Belkin với chương trình cơ sở của eTEK Labs.
  Bộ điều hợp nối tiếp một cổng Peracom cũng hoạt động với trình điều khiển này, như
  cũng như bộ chuyển đổi GoHubs.

Tình trạng hiện tại:

Những điều sau đây đã được thử nghiệm và hoạt động:

- Tốc độ truyền 300-230400
      - Bit dữ liệu 5-8
      - Dừng bit 1-2
      - Tính chẵn lẻ N,E,O,M,S
      - Bắt tay Không, Phần mềm (XON/XOFF), Phần cứng (CTSRTS,CTSDTR) [1]_
      - Break Set và xóa
      - Điều khiển đường dây Truy vấn và điều khiển đầu vào/đầu ra [2]_

  .. [1]
         Hardware input flow control is only enabled for firmware
         levels above 2.06.  Read source code comments describing Belkin
         firmware errata.  Hardware output flow control is working for all
         firmware versions.

  .. [2]
         Queries of inputs (CTS,DSR,CD,RI) show the last
         reported state.  Queries of outputs (DTR,RTS) show the last
         requested state and may not reflect current state as set by
         automatic hardware flow control.

Danh sách việc cần làm:
    - Thêm khả năng truy vấn dòng điều khiển modem thực sự.  Hiện đang theo dõi
      các trạng thái được báo cáo bởi ngắt và các trạng thái được yêu cầu.
    - Thêm tính năng báo lỗi trở lại ứng dụng đối với tình trạng lỗi UART.
    - Thêm hỗ trợ cho ioctls tuôn ra.
    - Thêm mọi thứ còn thiếu :)

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với William
  Nhà lớn tại wgreathouse@smva.com


Empeg empeg-car Mark I/II Driver
--------------------------------

Đây là trình điều khiển thử nghiệm để cung cấp hỗ trợ kết nối cho
  công cụ đồng bộ hóa máy khách cho máy nghe nhạc mp3 empeg-car Empeg.

Lời khuyên:
    * Đừng quên tạo các nút thiết bị cho ttyUSB{0,1,2,...}
    * modprobe empeg (modprobe là bạn của bạn)
    * emptool --usb /dev/ttyUSB0 (hoặc bất cứ tên nào bạn đặt tên cho nút thiết bị của mình)

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với Gary
  Brubaker tại xavyer@ix.netcom.com


MCT USB Bộ điều hợp nối tiếp một cổng U232
---------------------------------------

Trình điều khiển này dành cho Bộ chuyển đổi MCT USB-RS232 (25 pin, Model No.
  U232-P25) từ Magic Control Technology Corp. (cũng có loại 9 chân
  Mẫu số U232-P9). Thông tin thêm về thiết bị này có thể được tìm thấy tại
  trang web của nhà sản xuất: ZZ0000ZZ

Trình điều khiển nhìn chung vẫn hoạt động nhưng vẫn cần thử nghiệm thêm.
  Nó có nguồn gốc từ trình điều khiển Bộ điều hợp nối tiếp Belkin USB F5U103 và của nó
  Danh sách TODO cũng hợp lệ cho trình điều khiển này.

Trình điều khiển này cũng được phát hiện là có thể hoạt động với các sản phẩm khác có
  cùng một ID nhà cung cấp nhưng ID sản phẩm khác nhau. Sê-ri U232-P25 của Sitecom
  trình chuyển đổi sử dụng ID sản phẩm 0x230 và ID nhà cung cấp 0x711 và hoạt động với điều này
  người lái xe. Ngoài ra, DU-H3SP USB BAY của D-Link cũng hoạt động với trình điều khiển này.

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với Wolfgang
  Grandegger tại Wolfgang@ces.ch


Trình điều khiển Edgeport của Inside Out Networks
-----------------------------------

Trình điều khiển này hỗ trợ tất cả các thiết bị do Inside Out Networks sản xuất, cụ thể
  các mô hình sau:

- Edgeport/4
       - Cảng nhanh/4
       - Edgeport/4t
       - Edgeport/2
       - Edgeport/4i
       - Edgeport/2i
       - Edgeport/421
       - Edgeport/21
       - Edgeport/8
       - Edgeport/8 kép
       - Edgeport/2D8
       - Edgeport/4D8
       - Edgeport/8i
       - Edgeport/2 DIN
       - Edgeport/4 DIN
       - Edgeport/16 kép

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với Greg
  Kroah-Hartman tại greg@kroah.com


REINER SCT cyberJack pinpad/e-com Đầu đọc thẻ chip USB
-----------------------------------------------------

Giao diện với thẻ chip dựa trên tiếp xúc tương thích ISO 7816, ví dụ: SIM GSM.

Tình trạng hiện tại:

Đây là phần kernel của driver cho đầu đọc thẻ USB này.
    Ngoài ra còn có sẵn phần dành cho người dùng cho trình điều khiển CT-API. Một trang web
    để tải xuống là TBA. Hiện tại, bạn có thể yêu cầu nó từ
    người bảo trì (linux-usb@sii.li).

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ
  linux-usb@sii.li


Trình điều khiển PL2303 phong phú
----------------------

Trình điều khiển này hỗ trợ mọi thiết bị có chip PL2303 của Prolific
  trong đó.  Điều này bao gồm một số bộ chuyển đổi cổng đơn USB sang nối tiếp,
  hơn 70% thiết bị USB GPS (năm 2010) và một số UPS USB. Thiết bị
  từ Aten (UC-232) và IO-Data cũng hoạt động với trình điều khiển này
  cáp điện thoại di động DCU-11.

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với Greg
  Kroah-Hartman tại greg@kroah.com


Chipset KL5KUSB105 / Bộ chuyển đổi một cổng PalmConnect USB
--------------------------------------------------------

Tình trạng hiện tại:

Trình điều khiển được ghép lại bằng cách xem các giao dịch bus usb
  được thực hiện bởi trình điều khiển của Palm trong Windows, vì vậy rất nhiều chức năng được
  vẫn còn thiếu.  Đáng chú ý, ioctls nối tiếp đôi khi bị làm giả hoặc chưa
  được thực hiện.  Hỗ trợ tìm hiểu về trạng thái dòng DSR và CTS là
  tuy nhiên được triển khai (mặc dù không đẹp mắt), vì vậy chế độ lái tự động yêu thích của bạn(1)
  và các cuộc gọi Pilot-manager -daemon sẽ hoạt động.  Tốc độ truyền lên tới 115200
  đều được hỗ trợ, nhưng bắt tay (phần mềm hoặc phần cứng) thì không, đó là
  tại sao việc cắt giảm tỷ lệ sử dụng là khôn ngoan đối với các doanh nghiệp lớn
  chuyển nhượng cho đến khi việc này được giải quyết.

Xem ZZ0000ZZ để biết thông tin cập nhật
  thông tin về trình điều khiển này.

Trình điều khiển Winchiphead CH341
------------------------

Trình điều khiển này dành cho Bộ chuyển đổi Winchiphead CH341 USB-RS232. Con chip này
  cũng triển khai cổng song song IEEE 1284, I2C và SPI, nhưng điều đó không phải
  được tài xế hỗ trợ. Giao thức được phân tích từ hành vi
  của trình điều khiển Windows, hiện tại không có bảng dữ liệu nào.

Trang web của nhà sản xuất: ZZ0000ZZ

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ
  frank@kingswood-consulting.co.uk.

Trình điều khiển Moschip MCS7720, MCS7715
-------------------------------

Những con chip này có mặt trong các thiết bị được bán bởi nhiều nhà sản xuất khác nhau, chẳng hạn như Syba
  và Cáp không giới hạn.  Có thể có những người khác.  7720 cung cấp hai cổng nối tiếp
  cổng và 7715 cung cấp một cổng song song nối tiếp và một cổng PC tiêu chuẩn.
  Hỗ trợ cổng song song của 7715 được kích hoạt bằng một tùy chọn riêng.
  sẽ không xuất hiện trừ khi hỗ trợ cổng song song được bật lần đầu tiên ở cấp cao nhất
  của menu cấu hình Trình điều khiển Thiết bị.  Hiện tại chỉ có chế độ tương thích là
  được hỗ trợ trên cổng song song (không có ECP/EPP).

TODO:
    - Triển khai các chế độ ECP/EPP cho cổng song song.
    - Tốc độ Baud cao hơn 115200 hiện đang bị hỏng.
    - Các thiết bị có một cổng nối tiếp dựa trên Moschip MCS7703 có thể hoạt động
      với trình điều khiển này với một bổ sung đơn giản vào bảng usb_device_id.  tôi
      không có một trong những thiết bị này nên tôi không thể nói chắc chắn.

Trình điều khiển nối tiếp chung
---------------------

Nếu thiết bị của bạn không phải là một trong những thiết bị được liệt kê ở trên, tương thích với
  các mô hình trên, bạn có thể thử giao diện "chung". Cái này
  giao diện không cung cấp bất kỳ loại thông báo điều khiển nào được gửi đến
  thiết bị và không hỗ trợ bất kỳ loại điều khiển luồng thiết bị nào. Tất cả điều đó
  thiết bị của bạn được yêu cầu là nó có ít nhất một số lượng lớn ở điểm cuối,
  hoặc một điểm cuối số lượng lớn.

Để cho phép trình điều khiển chung nhận dạng thiết bị của bạn, hãy cung cấp::

echo <vid> <pid> >/sys/bus/usb-serial/drivers/generic/new_id

trong đó <vid> và <pid> được thay thế bằng biểu diễn hex của bạn
  id nhà cung cấp và id sản phẩm của thiết bị.
  Nếu trình điều khiển được biên dịch dưới dạng mô-đun, bạn cũng có thể cung cấp một id khi
  đang tải mô-đun::

nhà cung cấp usbserial insmod=0x#### product=0x####

Driver này đã được sử dụng thành công để kết nối với NetChip USB
  bảng phát triển, cung cấp cách phát triển phần mềm USB mà không cần
  phải viết một trình điều khiển tùy chỉnh.

Nếu có bất kỳ câu hỏi hoặc vấn đề nào với trình điều khiển này, vui lòng liên hệ với Greg
  Kroah-Hartman tại greg@kroah.com


Liên hệ
=======

Nếu bất kỳ ai gặp bất kỳ vấn đề nào khi sử dụng các trình điều khiển này, với bất kỳ điều nào ở trên
  sản phẩm được chỉ định, vui lòng liên hệ với tác giả trình điều khiển cụ thể được liệt kê
  ở trên hoặc tham gia danh sách gửi thư Linux-USB (thông tin về việc tham gia
  danh sách gửi thư, cũng như liên kết đến kho lưu trữ có thể tìm kiếm của nó có tại
  ZZ0000ZZ )


Greg Kroah-Hartman
greg@kroah.com
