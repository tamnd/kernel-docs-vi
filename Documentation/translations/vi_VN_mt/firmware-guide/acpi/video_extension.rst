.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/video_extension.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Tiện ích mở rộng video ACPI
===========================

Trình điều khiển này triển khai Tiện ích mở rộng ACPI cho Bộ điều hợp hiển thị cho
thiết bị đồ họa tích hợp trên bo mạch chủ, như được chỉ định trong ACPI 2.0
Thông số kỹ thuật, Phụ lục B, cho phép thực hiện một số điều khiển cơ bản như
xác định thiết bị video POST, truy xuất thông tin EDID hoặc để
thiết lập đầu ra video, v.v. Lưu ý rằng đây là tài liệu tham khảo. thực hiện
chỉ.  Nó có thể hoạt động hoặc không hoạt động đối với thiết bị video tích hợp của bạn.

Trình điều khiển video ACPI thực hiện 3 việc liên quan đến điều khiển đèn nền.

Xuất giao diện sysfs cho không gian người dùng để kiểm soát mức độ đèn nền
==================================================================

Nếu bảng ACPI có thiết bị video và kernel acpi_backlight=vendor
dòng lệnh không có, trình điều khiển sẽ đăng ký thiết bị đèn nền
và thiết lập cấu trúc hoạt động đèn nền cần thiết cho nó cho sysfs
điều khiển giao diện. Đối với mỗi thiết bị lớp đã đăng ký, sẽ có một
thư mục có tên acpi_videoX trong /sys/class/backlight.

Giao diện sysfs đèn nền có định nghĩa tiêu chuẩn ở đây:
Tài liệu/ABI/ổn định/sysfs-class-backlight.

Và những gì trình điều khiển video ACPI làm là:

độ sáng thực tế:
  khi đọc, phương thức điều khiển _BQC sẽ được đánh giá là
  lấy mức độ sáng mà phần sụn cho rằng nó ở mức đó;
bl_power:
  không được triển khai, thay vào đó sẽ đặt độ sáng hiện tại;
độ sáng:
  khi ghi, phương thức điều khiển _BCM sẽ chạy để đặt mức độ sáng được yêu cầu;
độ sáng tối đa:
  Bắt nguồn từ gói _BCL (xem bên dưới);
gõ:
  phần sụn

Lưu ý rằng trình điều khiển đèn nền video ACPI sẽ luôn sử dụng chỉ mục cho
độ sáng, độ sáng thực tế và độ sáng tối đa. Vì vậy nếu chúng ta có
gói _BCL sau đây::

Phương thức (_BCL, 0, Không được tuần tự hóa)
	{
		Trả lại (Gói (0x0C)
		{
			0x64,
			0x32,
			0x0A,
			0x14,
			0x1E,
			0x28,
			0x32,
			0x3C,
			0x46,
			0x50,
			0x5A,
			0x64
		})
	}

Hai cấp độ đầu tiên dành cho khi máy tính xách tay sử dụng nguồn AC hoặc pin và
hiện tại không được Linux sử dụng. 10 cấp độ còn lại là cấp độ được hỗ trợ
mà chúng ta có thể lựa chọn. Các giá trị chỉ số có thể áp dụng là từ 0 (tức là
tương ứng với giá trị độ sáng 0x0A) đến 9 (tương ứng với
bao gồm giá trị độ sáng 0x64). Mỗi giá trị chỉ số đó được coi là
như một chỉ báo "mức độ sáng". Do đó, từ góc độ không gian người dùng
phạm vi mức độ sáng khả dụng là từ 0 đến 9 (độ sáng tối đa)
bao gồm.

Thông báo cho không gian người dùng về sự kiện phím nóng
====================================

Nhìn chung có hai trường hợp để báo cáo sự kiện phím nóng:

i) Đối với một số máy tính xách tay, khi người dùng nhấn phím nóng, mã quét sẽ được hiển thị
   được tạo và gửi đến không gian người dùng thông qua thiết bị đầu vào được tạo bởi
   trình điều khiển bàn phím dưới dạng sự kiện nhập loại khóa, với bản sửa đổi phù hợp,
   mã khóa sau sẽ xuất hiện trong không gian người dùng::

EV_KEY, KEY_BRIGHTNESSUP
	EV_KEY, KEY_BRIGHTNESSDOWN
	v.v.

Trong trường hợp này, trình điều khiển video ACPI không cần phải làm gì cả (thực ra,
nó thậm chí không biết điều này đã xảy ra).

ii) Đối với một số máy tính xách tay, việc nhấn phím nóng sẽ không tạo ra
    scancode, thay vào đó, phần sụn sẽ thông báo cho nút ACPI của thiết bị video
    về sự kiện này. Giá trị sự kiện được xác định trong thông số ACPI. ACPI
    trình điều khiển video sẽ tạo ra sự kiện nhập loại khóa theo
    thông báo giá trị nó nhận được và gửi sự kiện đến không gian người dùng thông qua
    thiết bị đầu vào mà nó tạo ra:

===== ====================
	mã khóa sự kiện
	===== ====================
	0x86 KEY_BRIGHTNESSUP
	0x87 KEY_BRIGHTNESSDOWN
	v.v.
	===== ====================

vì vậy điều này sẽ dẫn đến tác động tương tự như trường hợp i) bây giờ.

Khi công cụ không gian người dùng nhận được sự kiện này, nó có thể sửa đổi đèn nền
cấp độ thông qua giao diện sysfs.

Thay đổi mức độ đèn nền trong kernel
====================================

Điều này áp dụng cho các máy thuộc trường hợp ii) ở Phần 2. Sau khi trình điều khiển
nhận được thông báo, nó sẽ đặt mức độ đèn nền tương ứng. Điều này không
không ảnh hưởng đến việc gửi sự kiện đến không gian người dùng, chúng luôn được gửi tới người dùng
không gian bất kể mô-đun video có kiểm soát mức độ đèn nền hay không
trực tiếp. Hành vi này có thể được kiểm soát thông qua Bright_switch_enabled
tham số mô-đun như được ghi lại trong admin-guide/kernel-parameters.rst. Đó là
nên tắt hành vi này khi môi trường GUI khởi động và
muốn có toàn quyền kiểm soát mức độ đèn nền.