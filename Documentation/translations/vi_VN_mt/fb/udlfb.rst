.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/udlfb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
udlfb - Trình điều khiển DisplayLink USB 2.0
==================================

Đây là driver cho chip đồ họa DisplayLink USB 2.0.

Chip DisplayLink cung cấp các thao tác hline/blit đơn giản với một số thao tác nén,
ghép nối nó với bộ đệm khung phần cứng (16MB) ở đầu bên kia của
Dây USB.  Bộ đệm khung phần cứng đó có thể điều khiển VGA, DVI hoặc HDMI
màn hình không có sự tham gia của CPU cho đến khi một pixel phải thay đổi.

CPU hoặc tài nguyên cục bộ khác thực hiện tất cả việc hiển thị; tùy ý so sánh
kết quả là có bóng cục bộ của bộ đệm khung phần cứng từ xa để xác định
tập hợp pixel tối thiểu đã thay đổi; rồi nén và gửi chúng
pixel theo từng dòng thông qua chuyển số lượng lớn USB.

Do hiệu quả của việc chuyển số lượng lớn và giao thức trên đó
không yêu cầu bất kỳ ack nào - hiệu quả là độ trễ rất thấp
có thể hỗ trợ độ phân giải cao đáng ngạc nhiên với hiệu suất tốt cho
các ứng dụng không phải trò chơi và không phải video.

Cài đặt chế độ, đọc EDID, v.v. là các hoạt động chuyển số lượng lớn hoặc điều khiển khác. Chế độ
cài đặt rất linh hoạt - có thể đặt các chế độ gần như tùy ý từ bất kỳ thời điểm nào.

Ưu điểm của đồ họa USB nói chung:

* Khả năng thêm số lượng màn hình gần như tùy ý vào bất kỳ USB 2.0 nào
   hệ thống có khả năng. Trên Linux, số lượng màn hình bị giới hạn bởi giao diện fbdev
   (FB_MAX hiện 32 tuổi). Tất nhiên, tất cả các thiết bị USB đều giống nhau
   bộ điều khiển máy chủ chia sẻ cùng giao diện 480Mbs USB 2.0.

Ưu điểm của việc hỗ trợ chip DisplayLink với giao diện bộ đệm khung kernel:

* Chức năng phần cứng thực tế của chip DisplayLink gần như phù hợp
   1-1 với giao diện fbdev, khiến trình điều khiển khá nhỏ và
   chặt chẽ so với chức năng mà nó cung cấp.
 * Máy chủ X và các ứng dụng khác có thể sử dụng giao diện fbdev tiêu chuẩn
   từ chế độ người dùng để nói chuyện với thiết bị mà không cần biết gì
   về USB hoặc giao thức của DisplayLink. Trình điều khiển X "displaylink"
   và trình điều khiển X "fbdev" được sửa đổi một chút nằm trong số những trình điều khiển đã làm được điều đó.

Nhược điểm:

* Giao diện mmap của Fbdev giả sử bộ đệm khung phần cứng thực được ánh xạ.
   Trong trường hợp đồ họa USB, nó chỉ là một bộ đệm (ảo) được phân bổ.
   Các thao tác ghi cần được phát hiện và mã hóa thành chuyển số lượng lớn USB bằng CPU.
   Thông báo khu vực bị thay đổi/thiệt hại chính xác có tác dụng giải quyết vấn đề này.
   Trong tương lai hy vọng fbdev sẽ được nâng cao với một tiêu chuẩn nhỏ
   giao diện cho phép khách hàng mmap báo cáo thiệt hại, vì lợi ích
   của bộ đệm khung ảo hoặc từ xa.
 * Fbdev không phân xử tốt quyền sở hữu của khách hàng đối với bộ đệm khung.
 * Fbcon giả định bộ đệm khung đầu tiên mà nó tìm thấy sẽ được sử dụng cho bảng điều khiển.
 * Không rõ tương lai của fbdev sẽ như thế nào trước sự nổi lên của KMS/DRM.

Làm thế nào để sử dụng nó?
==============

Udlfb, khi được tải dưới dạng mô-đun, sẽ phù hợp với tất cả thế hệ USB 2.0
Chip DisplayLink (dòng Alex và Ollie). Sau đó nó sẽ cố gắng đọc EDID
của màn hình và đặt chế độ chung tốt nhất giữa thiết bị DisplayLink
và khả năng của màn hình.

Nếu thiết bị DisplayLink thành công, nó sẽ hiển thị "màn hình xanh"
có nghĩa là từ góc độ phần cứng và phần mềm fbdev, mọi thứ đều tốt.

Tại thời điểm đó, /dev/fb? giao diện sẽ có mặt cho các ứng dụng ở chế độ người dùng
để mở và bắt đầu ghi vào bộ đệm khung của thiết bị DisplayLink bằng cách sử dụng
cuộc gọi fbdev tiêu chuẩn.  Lưu ý rằng nếu mmap() được sử dụng, theo mặc định, chế độ người dùng
ứng dụng phải gửi thông báo hư hỏng để kích hoạt việc sơn lại
các vùng đã thay đổi.  Ngoài ra, udlfb có thể được biên dịch lại bằng thử nghiệm
đã bật hỗ trợ defio để hỗ trợ cơ chế phát hiện lỗi trang
có thể hoạt động mà không cần thông báo rõ ràng.

Ứng dụng khách phổ biến nhất của udlfb là xf86-video-displaylink hoặc một ứng dụng đã được sửa đổi
máy chủ xf86-video-fbdev X. Các máy chủ này không có DisplayLink thực sự cụ thể
mã. Họ ghi vào giao diện bộ đệm khung tiêu chuẩn và dựa vào udlfb
để làm việc của nó  Một tính năng bổ sung mà họ có là khả năng báo cáo
hình chữ nhật từ phần mở rộng giao thức X DAMAGE xuống udlfb thông qua udlfb
giao diện bị hư hỏng (hy vọng sẽ được chuẩn hóa cho tất cả các giao diện ảo
bộ đệm khung cần thông tin thiệt hại). Những thông báo thiệt hại này cho phép
udlfb để xử lý hiệu quả các pixel đã thay đổi.

Tùy chọn mô-đun
==============

Cấu hình đặc biệt cho udlfb thường không cần thiết. Có một vài
tùy chọn, tuy nhiên.

Từ dòng lệnh, chuyển các tùy chọn tới modprobe::

modprobe udlfb fb_defio=0 console=1 bóng=1

Hoặc thay đổi tùy chọn một cách nhanh chóng bằng cách chỉnh sửa
/sys/mô-đun/udlfb/tham số/PARAMETER_NAME ::

cd /sys/mô-đun/udlfb/tham số
  ls # to xem danh sách tên tham số
  sudo nano PARAMETER_NAME
  # change đặt tham số tại chỗ và lưu tệp.

Rút/cắm lại thiết bị USB để áp dụng các cài đặt mới.

Hoặc để áp dụng các tùy chọn vĩnh viễn, hãy tạo tệp cấu hình modprobe
như /etc/modprobe.d/udlfb.conf với văn bản::

tùy chọn udlfb fb_defio=0 console=1 Shadow=1

Các tùy chọn boolean được chấp nhận:

======================================================================================
fb_defio Sử dụng kernel fb_defio (CONFIG_FB_DEFERRED_IO)
		mô-đun để theo dõi các khu vực đã thay đổi của bộ đệm khung theo lỗi trang.
		Các ứng dụng fbdev tiêu chuẩn sử dụng mmap nhưng không
		báo cáo thiệt hại, sẽ có thể hoạt động với tính năng này được kích hoạt.
		Tắt khi chạy với máy chủ X hỗ trợ báo cáo
		đã thay đổi vùng thông qua ioctl, vì phương pháp này đơn giản hơn,
		ổn định hơn và hiệu suất cao hơn.
		mặc định: fb_defio=1

bảng điều khiển Cho phép fbcon đính kèm vào bộ đệm khung do udlfb cung cấp.
		Có thể bị vô hiệu hóa nếu fbcon và các ứng dụng khách khác
		(ví dụ: X với --shared-vt) đang xung đột.
		mặc định: bàn điều khiển = 1

bóng Phân bổ bộ đệm khung thứ 2 để tạo bóng cho những gì hiện đang chạy qua
		bus USB trong bộ nhớ thiết bị. Nếu có bất kỳ pixel nào không thay đổi,
		không truyền tải. Dành bộ nhớ máy chủ để lưu chuyển USB.
		Được bật theo mặc định. Chỉ vô hiệu hóa trên các hệ thống có bộ nhớ rất thấp.
		mặc định: bóng=1
======================================================================================

Thuộc tính Sysfs
================

Udlfb tạo một số tệp trong /sys/class/graphics/fb?
Ở đâu ? là id bộ đệm khung tuần tự của thiết bị DisplayLink cụ thể

=======================================================================================
edid Nếu blob EDID hợp lệ được ghi vào tệp này (thường
			 theo quy tắc udev), thì udlfb sẽ sử dụng EDID này làm
			 sao lưu trong trường hợp đọc EDID thực tế của màn hình
			 gắn vào thiết bị DisplayLink không thành công. Đây là
			 đặc biệt hữu ích cho các bảng cố định, v.v. không thể
			 truyền đạt khả năng của họ thông qua EDID. Đọc
			 tập tin này trả về EDID hiện tại của tệp đính kèm
			 màn hình (hoặc giá trị sao lưu cuối cùng được ghi). Đây là
			 hữu ích để có được EDID của màn hình đính kèm,
			 có thể được chuyển đến các tiện ích như phân tích cú pháp-edid.

số liệu_bytes_rendered Số byte pixel 32 bit được hiển thị

số liệu_bytes_identical Số đếm 32 bit cho biết có bao nhiêu byte trong số đó được tìm thấy
			 không thay đổi, dựa trên kiểm tra bộ đệm khung bóng

số liệu_bytes_sent Số lượng 32 bit cho biết có bao nhiêu byte được truyền qua
			 USB để truyền đạt các pixel đã thay đổi đến
			 phần cứng. Bao gồm chi phí nén và giao thức

số liệu_cpu_kcycles_sử dụng Số lượng chu kỳ CPU 32 bit được sử dụng để xử lý
			 trên các pixel (tính theo hàng nghìn chu kỳ).

số liệu_reset Chỉ ghi. Bất kỳ thao tác ghi nào vào tệp này sẽ đặt lại tất cả các số liệu
			 trên về không.  Lưu ý rằng bộ đếm 32 bit ở trên
			 lăn qua rất nhanh. Để có được kết quả đáng tin cậy, hãy thiết kế
			 kiểm tra hiệu suất để bắt đầu và kết thúc trong thời gian rất ngắn
			 khoảng thời gian (một phút hoặc ít hơn là an toàn).
=======================================================================================

Bernie Thompson <bernie@plugable.com>
