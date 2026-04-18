.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/lis3lv02d.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Trình điều khiển hạt nhân lis3lv02d
=======================

Chip được hỗ trợ:

* STMicroelectronics LIS3LV02DL, LIS3LV02DQ (độ chính xác 12 bit)
  * STMicroelectronics LIS302DL, LIS3L02DQ, LIS331DL (8 bit) và
    LIS331DLH (16 bit)

tác giả:
        - Yan Burman <burman.yan@gmail.com>
	- Eric Piel <eric.piel@tremplin-utc.net>


Sự miêu tả
-----------

Trình điều khiển này cung cấp hỗ trợ cho gia tốc kế có trong nhiều máy tính xách tay HP
sử dụng tính năng có tên chính thức là "Hệ thống bảo vệ dữ liệu di động HP 3D" hoặc
"HP 3D DriveGuard". Nó tự động phát hiện máy tính xách tay với cảm biến này. Đã biết
các mô hình (có thể tìm thấy danh sách đầy đủ trong trình điều khiển/nền tảng/x86/hp_accel.c) sẽ có
trục của chúng được định hướng tự động theo cách tiêu chuẩn (ví dụ: bạn có thể trực tiếp chơi
không bao giờ bóng). Dữ liệu gia tốc kế có thể đọc được thông qua
/sys/devices/faux/lis3lv02d. Các giá trị được báo cáo được chia tỷ lệ
đến giá trị mg (1/1000 trọng lực trái đất).

Thuộc tính Sysfs trong /sys/devices/faux/lis3lv02d/:

vị trí
      - Vị trí 3D mà gia tốc kế báo cáo. Định dạng: "(x,y,z)"
tỷ lệ
      - đọc báo cáo tốc độ lấy mẫu của thiết bị gia tốc kế ở HZ.
	ghi các thay đổi tốc độ lấy mẫu của thiết bị gia tốc.
	Chỉ những giá trị được HW hỗ trợ mới được chấp nhận.
tự kiểm tra
      - thực hiện tự kiểm tra chip theo quy định của nhà sản xuất chip.

Trình điều khiển này cũng cung cấp một thiết bị lớp đầu vào tuyệt đối, cho phép
máy tính xách tay hoạt động như một cần điều khiển giống như máy pinball. Thiết bị cần điều khiển có thể
đã hiệu chuẩn. Thiết bị cần điều khiển có thể ở hai chế độ khác nhau.
Theo mặc định, giá trị đầu ra được chia tỷ lệ trong khoảng -32768 .. 32767. Trong phím điều khiển thô
chế độ, phím điều khiển và mục nhập vị trí sysfs có cùng tỷ lệ. có thể có
sự khác biệt nhỏ do tính năng mờ của hệ thống đầu vào.
Sự kiện cũng có sẵn dưới dạng thiết bị sự kiện đầu vào.

Selftest chỉ nhằm mục đích chẩn đoán phần cứng. Nó không có nghĩa là
sử dụng trong quá trình hoạt động bình thường. Dữ liệu vị trí không bị hỏng trong quá trình tự kiểm tra
nhưng hành vi ngắt không được đảm bảo hoạt động đáng tin cậy. Ở chế độ thử nghiệm,
phần tử cảm biến được di chuyển bên trong một chút. Selftest đo lường sự khác biệt
giữa chế độ bình thường và chế độ kiểm tra. Thông số kỹ thuật của chip cho biết sự chấp nhận
giới hạn cho từng loại chip. Giới hạn được cung cấp thông qua dữ liệu nền tảng
để cho phép điều chỉnh các giới hạn mà không cần thay đổi trình điều khiển thực tế.
Seltest trả về "OK x y z" hoặc "FAIL x y z" trong đó x, y và z là
đo được sự khác biệt giữa các chế độ. Các trục không được ánh xạ lại ở chế độ tự kiểm tra.
Các giá trị đo được cung cấp để giúp các ứng dụng chẩn đoán CTNH thực hiện
quyết định cuối cùng.

Trên máy tính xách tay HP, nếu cơ sở hạ tầng led được kích hoạt, hỗ trợ đèn led
cho biết tính năng bảo vệ ổ đĩa sẽ được cung cấp dưới dạng /sys/class/leds/hp::hddprotect.

Một tính năng khác của trình điều khiển là thiết bị linh tinh gọi là "rơi tự do"
hoạt động tương tự như /dev/rtc và phản ứng khi nhận được các ngắt rơi tự do
từ thiết bị. Nó hỗ trợ các hoạt động chặn, thăm dò/chọn và
chế độ hoạt động fasync. Bạn phải đọc 1 byte từ thiết bị.  các
kết quả là số lần ngắt rơi tự do kể từ lần thành công cuối cùng
đọc (hoặc 255 nếu số lượng ngắt không phù hợp). Xem sự rơi tự do.c
tập tin ví dụ về cách sử dụng thiết bị.


Hướng trục
----------------

Để tương thích tốt hơn giữa các máy tính xách tay khác nhau. Các giá trị được báo cáo bởi
gia tốc kế được chuyển đổi thành một tổ chức "tiêu chuẩn" của các trục
(còn gọi là "có thể chơi Neverball ngay lập tức"):

* Khi laptop nằm ngang vị trí báo cáo là khoảng 0 cho X và Y
   và một giá trị dương cho Z
 * Nếu bên trái nâng lên thì X tăng (trở thành dương)
 * Nếu mặt trước (nơi đặt bàn di chuột) được nâng lên, Y sẽ giảm
   (trở nên tiêu cực)
 * Nếu đặt ngược laptop thì Z trở thành âm

Nếu mẫu máy tính xách tay của bạn không được nhận dạng (cf "dmesg"), bạn có thể gửi một
gửi email cho người bảo trì để thêm nó vào cơ sở dữ liệu.  Khi báo cáo một thông tin mới
máy tính xách tay, vui lòng bao gồm đầu ra của "dmidecode" cộng với giá trị của
/sys/devices/faux/lis3lv02d/position trong bốn trường hợp này.

Hỏi đáp
---

Hỏi: Làm cách nào để mô phỏng rơi tự do một cách an toàn? Tôi có một chiếc HP "xách tay"
máy trạm" nặng khoảng 3,5kg và có vỏ nhựa nên để nó
rơi xuống đất là điều không thể....

Đáp: Cảm biến khá nhạy nên tay bạn có thể làm được. Nâng nó lên
vào không gian trống, dùng tay theo dõi cú rơi trong khoảng 10
cm. Điều đó là đủ để kích hoạt phát hiện.
