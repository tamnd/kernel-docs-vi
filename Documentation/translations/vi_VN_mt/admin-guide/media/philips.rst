.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/philips.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Webcam Philips (trình điều khiển pwc)
=====================================

Tệp này chứa một số thông tin bổ sung cho webcam Philips và OEM.
E-mail: webcam@smcc.demon.nl Cập nhật lần cuối: 19-01-2004
Trang web: ZZ0000ZZ

Tính đến thời điểm này, các máy ảnh sau được hỗ trợ:

* Philips PCA645
 * Philips PCA646
 * Philips PCVC675
 * Philips PCVC680
 * Philips PCVC690
 * Philips PCVC720/40
 * Philips PCVC730
 * Philips PCVC740
 * Philips PCVC750
 * Askey VC010
 * Webcam phòng thí nghiệm sáng tạo 5
 * Creative Labs Webcam Pro Ex
 * Logitech QuickCam 3000 Pro
 * Logitech QuickCam 4000 Pro
 * Logitech QuickCam Notebook Pro
 * Thu phóng QuickCam của Logitech
 * Quỹ đạo QuickCam của Logitech
 * Quả cầu QuickCam của Logitech
 * Samsung MPC-C10
 * Samsung MPC-C30
 * Mắt Sotec Afina
 * AME CU-001
 * Tầm nhìn VCS-UM100
 * Visionite VCS-UC300

Trang web chính của trình điều khiển Philips có tại địa chỉ trên. Nó chứa
nhiều thông tin bổ sung, FAQ và plugin nhị phân 'PWCX'. Plugin này
chứa các quy trình giải nén cho phép bạn sử dụng kích thước hình ảnh cao hơn và
tốc độ khung hình; ngoài ra, webcam sử dụng ít băng thông hơn trên bus USB (tiện dụng
nếu bạn muốn chạy nhiều hơn 1 camera cùng lúc). Những thói quen này rơi
theo NDA và do đó có thể không được phân phối dưới dạng nguồn; tuy nhiên, công dụng của nó
là hoàn toàn tùy chọn.

Bạn có thể xây dựng mã này vào kernel của mình hoặc dưới dạng mô-đun. tôi khuyên bạn nên
cái sau, vì nó giúp việc khắc phục sự cố dễ dàng hơn rất nhiều. Tích hợp sẵn
micrô được hỗ trợ thông qua lớp Âm thanh USB.

Khi bạn tải mô-đun, bạn có thể đặt một số cài đặt mặc định cho
máy ảnh; một số chương trình phụ thuộc vào kích thước hoặc định dạng hình ảnh cụ thể và
không biết cài đặt thế nào cho đúng trong driver. Các tùy chọn là:

kích thước
   Có thể là một trong các 'sqcif', 'qsif', 'qcif', 'sif', 'cif' hoặc
   'vga', dành cho kích thước hình ảnh tương ứng. 128x96, 160x120, 176x144,
   320x240, 352x288 và 640x480 (tất nhiên, chỉ dành cho những máy ảnh
   ủng hộ các nghị quyết này).

khung hình/giây
   Chỉ định tốc độ khung hình mong muốn. Là một số nguyên trong khoảng 4-30.

fbuf
   Tham số này chỉ định số lượng bộ đệm bên trong được sử dụng để lưu trữ
   khung hình từ cam. Điều này sẽ giúp ích nếu quá trình đọc hình ảnh từ
   cam hơi chậm hoặc nhất thời bận. Tuy nhiên, trên các máy chậm, nó
   chỉ giới thiệu độ trễ, vì vậy hãy lựa chọn cẩn thận. Mặc định là 3, tức là
   hợp lý. Bạn có thể đặt nó trong khoảng từ 2 đến 5.

ngu ngốc
   Đây là một số nguyên từ 1 đến 10. Nó sẽ cho mô-đun biết số lượng
   bộ đệm để dành cho mmap(), VIDIOCCGMBUF, VIDIOCMCAPTURE và bạn bè.
   Giá trị mặc định là 2, đủ cho hầu hết các ứng dụng (gấp đôi
   đệm).

Nếu bạn gặp nhiều thông báo 'Đổ khung...' trong quá trình
   lấy bằng công cụ sử dụng mmap(), bạn có thể muốn tăng if.
   Tuy nhiên, nó không thực sự đệm hình ảnh, nó chỉ cung cấp cho bạn thêm một chút
   chùng xuống khi chương trình của bạn ở phía sau. Nhưng bạn cần một hệ thống đa luồng hoặc
   chương trình rẽ nhánh để thực sự tận dụng được các bộ đệm này.

Mức tối đa tuyệt đối là 10, nhưng đừng đặt nó quá cao!  Mỗi bộ đệm mất
   lên tới 460 KB của RAM, vì vậy trừ khi bạn có nhiều bộ nhớ, hãy đặt cài đặt này thành
   nhiều hơn 4 là một sự lãng phí tuyệt đối.  Bộ nhớ này chỉ
   được phân bổ trong khi open(), do đó không có gì bị lãng phí khi máy ảnh không ở chế độ
   sử dụng.

power_save
   Khi power_save được bật (đặt thành 1), mô-đun sẽ cố gắng tắt
   cam đóng() và kích hoạt lại khi mở(). Điều này sẽ tiết kiệm điện và
   tắt LED. Tuy nhiên, không phải tất cả các máy ảnh đều hỗ trợ điều này (645 và 646
   hoàn toàn không có tính năng tiết kiệm điện) và một số kiểu máy cũng không hoạt động (chúng
   sẽ tắt, nhưng không bao giờ thức dậy). Hãy xem xét thử nghiệm này. Bởi
   mặc định tùy chọn này bị tắt.

nén (chỉ hữu ích với plugin)
   Với tùy chọn này bạn có thể kiểm soát hệ số nén mà máy ảnh
   sử dụng để nén hình ảnh qua bus USB. Bạn có thể thiết lập
   tham số trong khoảng từ 0 đến 3::

0 = thích hình ảnh không nén hơn; nếu chế độ được yêu cầu không có sẵn
	 ở định dạng không nén, trình điều khiển sẽ âm thầm chuyển về mức thấp
	 nén.
     1 = độ nén thấp.
     2 = nén trung bình.
     3 = độ nén cao.

Tất nhiên, độ nén cao sẽ tiêu tốn ít băng thông hơn, nhưng nó cũng có thể
   giới thiệu một số đồ tạo tác không mong muốn. Mặc định là 2, nén trung bình.
   Xem FAQ trên trang web để biết tổng quan về các chế độ yêu cầu
   nén.

Thông số nén không áp dụng cho camera 645 và 646
   và các mẫu OEM có nguồn gốc từ những mẫu đó (chỉ một số ít). Hầu hết các máy quay đều tôn vinh điều này
   tham số.

đèn led
   Cài đặt này lấy 2 số nguyên xác định thời gian bật/tắt cho LED
   (tính bằng mili giây). Một trong những điều thú vị mà bạn có thể làm với
   điều này là để LED nhấp nháy khi đang sử dụng máy ảnh. Cái này::

led=500.500

sẽ nhấp nháy LED mỗi giây một lần. Nhưng với::

đèn led=0,0

LED không bao giờ hoạt động, khiến nó phù hợp để giám sát im lặng.

Theo mặc định, LED của máy ảnh ở trạng thái ổn định khi đang sử dụng và đã tắt
   khi máy ảnh không được sử dụng nữa.

Thông số này chỉ hoạt động với dòng camera ToUCam (720, 730, 740,
   750) và OEM. Đối với các máy ảnh khác, lệnh này được âm thầm bỏ qua và
   không thể điều khiển được LED.

Cuối cùng: thông số này không có hiệu lực UNTIL trong lần đầu tiên bạn
   mở thiết bị camera. Cho đến lúc đó, LED vẫn bật.

dev_hint
   Một vấn đề tồn tại lâu dài với các thiết bị USB là tính chất động của chúng: bạn
   không bao giờ biết máy ảnh được chỉ định cho thiết bị nào; nó phụ thuộc vào tải mô-đun
   thứ tự, cấu hình trung tâm, thứ tự cắm thiết bị,
   và giai đoạn của mặt trăng (tức là nó có thể là ngẫu nhiên). Với tùy chọn này bạn
   có thể gợi ý cho trình điều khiển về nút thiết bị video (/dev/videoX)
   nên sử dụng với một máy ảnh cụ thể. Điều này cũng hữu ích nếu bạn có hai
   máy ảnh cùng model.

Máy ảnh được chỉ định theo loại của nó (số từ kiểu máy ảnh,
   như PCA645, PCVC750VC, v.v.) và tùy chọn số sê-ri (hiển thị
   trong/sys/kernel/gỡ lỗi/usb/thiết bị). Một gợi ý bao gồm một chuỗi có
   định dạng sau::

[loại[.serialnumber]:]nút

Dấu ngoặc vuông có nghĩa là cả loại và số sê-ri đều
   tùy chọn, nhưng không thể chỉ định số sê-ri mà không có loại (mà
   sẽ khá vô nghĩa). Số sê-ri được tách ra khỏi loại
   bởi một '.'; số nút bằng dấu ':'.

Cú pháp hơi khó hiểu này được giải thích rõ nhất bằng một vài ví dụ::

dev_hint=3,5 Cam được phát hiện đầu tiên sẽ được chỉ định
			       /dev/video3, /dev/video5 thứ hai. bất kỳ
			       những máy ảnh khác sẽ được miễn phí đầu tiên
			       khe cắm có sẵn (xem bên dưới).

dev_hint=645:1,680:2 Máy ảnh PCA645 sẽ nhận được /dev/video1,
			       và PCVC680 /dev/video2.

dev_hint=645.0123:3,645.4567:0 Máy ảnh PCA645 có số sê-ri
					0123 đi đến/dev/video3, tương tự
					mẫu máy ảnh với sê-ri 4567
					nhận được /dev/video0.

dev_hint=750:1,4,5,6 Máy ảnh PCVC750 sẽ nhận được /dev/video1,
				3 máy quay Philips tiếp theo sẽ sử dụng /dev/video4
				thông qua /dev/video6.

Một số điểm đáng biết:

- Số sê-ri có phân biệt chữ hoa chữ thường và phải được viết đầy đủ, bao gồm cả
     các số 0 đứng đầu (nó được coi là một chuỗi).
   - Nếu nút thiết bị đã bị chiếm dụng, việc đăng ký sẽ không thành công và
     webcam không có sẵn.
   - Bạn có thể có tối đa 64 thiết bị video; hãy đảm bảo có đủ thiết bị
     các nút trong /dev nếu bạn muốn trải rộng các con số.
     Sau /dev/video9 là /dev/video10 (không phải /dev/videoA).
   - Nếu một camera không khớp với bất kỳ dev_hint nào, nó sẽ được chỉ định
     nút thiết bị khả dụng đầu tiên, giống như trước đây.

dấu vết
   Để phát hiện vấn đề tốt hơn, giờ đây bạn có thể bật một
   'dấu vết' của một số lệnh gọi mà mô-đun thực hiện; nó ghi lại tất cả các mục trong của bạn
   nhật ký kernel ở mức gỡ lỗi.

Biến theo dõi là một bitmask; mỗi bit đại diện cho một tính năng nhất định.
   Nếu bạn muốn theo dõi thứ gì đó, hãy tra cứu (các) giá trị bit trong bảng
   bên dưới, cộng các giá trị lại với nhau và cung cấp giá trị đó cho biến theo dõi.

============= =================================================== ========
   Giá trị Giá trị Mô tả Mặc định
   (tháng 12) (hex)
   ============= =================================================== ========
       1 0x1 Khởi tạo mô-đun; điều này sẽ ghi lại tin nhắn Bật
		  trong khi tải và dỡ mô-đun

2 dấu vết thăm dò() và ngắt kết nối() 0x2 Bật

4 0x4 Theo dõi lệnh gọi open() và close() Tắt

8 lệnh gọi 0x8 read(), mmap() và ioctl() liên quan Tắt

16 0x10 Phân bổ bộ nhớ của bộ đệm, v.v. Tắt

32 0x20 Hiển thị khung tràn, tràn và đổ tràn Bật
		  tin nhắn

64 0x40 Hiển thị kích thước khung nhìn và hình ảnh Tắt

128 0x80 PWCX gỡ lỗi Tắt
   ============= =================================================== ========

Ví dụ: để theo dõi các hàm open() & read(), tổng 8 + 4 = 12,
   vì vậy bạn sẽ cung cấp trace=12 trong quá trình insmod hoặc modprobe. Nếu
   bạn muốn tắt việc khởi tạo và theo dõi thăm dò, hãy đặt trace=0.
   Giá trị mặc định cho dấu vết là 35 (0x23).



Ví dụ::

Kích thước pwc # modprobe=cif fps=15 power_save=1

Các tham số fbuf, mbuf và trace là toàn cục và áp dụng cho tất cả các kết nối
máy ảnh. Mỗi máy ảnh có bộ đệm riêng.

kích thước và khung hình/giây chỉ xác định giá trị mặc định khi bạn mở() thiết bị; đây là để
chứa một số công cụ không đặt kích thước. Bạn có thể thay đổi những điều này
cài đặt sau open() bằng lệnh gọi Video4Linux ioctl(). Mặc định của
mặc định là kích thước QCIF ở tốc độ 10 khung hình / giây.

Tham số nén là bán toàn cầu; nó đặt mức nén ban đầu
ưu tiên cho tất cả các máy ảnh, nhưng thông số này có thể được đặt cho mỗi máy ảnh bằng
lệnh gọi VIDIOCPWCSCQUAL ioctl().

Tất cả các tham số là tùy chọn.
