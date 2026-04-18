.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-class-flash.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Xử lý Flash LED trong Linux
=================================

Một số thiết bị LED cung cấp hai chế độ - đèn pin và đèn flash. Trong hệ thống con LED
các chế độ đó được lớp LED hỗ trợ (xem Tài liệu/leds/leds-class.rst)
và lớp Flash LED tương ứng. Các tính năng liên quan đến chế độ đèn pin được bật
theo mặc định và chỉ flash nếu trình điều khiển khai báo nó bằng cách cài đặt
Cờ LED_DEV_CAP_FLASH.

Để kích hoạt tính năng hỗ trợ đèn flash LED, biểu tượng CONFIG_LEDS_CLASS_FLASH
phải được xác định trong cấu hình kernel. Phải có trình điều khiển loại LED Flash
đã đăng ký trong hệ thống con LED với chức năng led_classdev_flash_register.

Các thuộc tính sysfs sau được hiển thị để điều khiển các thiết bị flash LED:
(xem Tài liệu/ABI/thử nghiệm/sysfs-class-led-flash)

- flash_brightness
	- độ sáng tối đa_flash_brightness
	- flash_timeout
	- max_flash_timeout
	- flash_strobe
	- flash_fault


Trình bao bọc đèn flash V4L2 cho đèn flash LED
==============================================

Trình điều khiển hệ thống con LED cũng có thể được điều khiển từ cấp độ VideoForLinux2
hệ thống con. Để kích hoạt biểu tượng CONFIG_V4L2_FLASH_LED_CLASS này phải
được xác định trong cấu hình kernel.

Trình điều khiển phải gọi hàm v4l2_flash_init để được đăng ký trong
Hệ thống con V4L2. Hàm này có sáu đối số:

- nhà phát triển:
	thiết bị flash, ví dụ: thiết bị I2C
- of_node:
	of_node của LED, có thể là NULL nếu giống với thiết bị
- run_cdev:
	Thiết bị lớp flash LED để bọc
- iled_cdev:
	Thiết bị loại flash LED đại diện cho chỉ báo LED được liên kết với
	run_cdev, có thể là NULL
- ôi:
	Hoạt động cụ thể của V4L2

* external_strobe_set
		xác định nguồn của đèn flash LED nhấp nháy -
		Điều khiển V4L2_CID_FLASH_STROBE hoặc nguồn bên ngoài, thông thường
		một cảm biến cho phép đồng bộ hóa đèn flash
		bắt đầu nhấp nháy với bắt đầu phơi sáng,
	* cường độ_to_led_brightness và led_brightness_to_intensity
		biểu diễn
		enum led_brightness <-> Chuyển đổi cường độ V4L2 trong thiết bị
		theo cách cụ thể - chúng có thể được sử dụng cho các thiết bị có phi tuyến tính
		Cân hiện tại LED.
- cấu hình:
	cấu hình cho thiết bị phụ V4L2 Flash

* tên_dev
		tên của thực thể truyền thông, duy nhất trong hệ thống,
	* flash_faults
		bitmask của lỗi flash mà lớp flash LED
		thiết bị có thể báo cáo; định nghĩa bit LED_FAULT* tương ứng là
		có sẵn trong <linux/led-class-flash.h>,
	* ngọn đuốc_cường độ
		các ràng buộc đối với LED ở chế độ TORCH
		tính bằng microampe,
	* chỉ số_cường độ
		các ràng buộc cho chỉ báo LED
		tính bằng microampe,
	* has_external_strobe
		xác định xem nguồn nhấp nháy flash có
		có thể được chuyển sang bên ngoài,

Khi xóa, hàm v4l2_flash_release phải được gọi, thao tác này cần một
đối số - con trỏ struct v4l2_flash được v4l2_flash_init trả về trước đó.
Hàm này có thể được gọi một cách an toàn với NULL hoặc đối số con trỏ lỗi.

Vui lòng tham khảo trình điều khiển/leds/leds-max77693.c để biết cách sử dụng mẫu của
trình bao bọc flash v4l2.

Sau khi thiết bị phụ V4L2 được đăng ký bởi trình điều khiển đã tạo Phương tiện
thiết bị điều khiển, nút thiết bị phụ hoạt động giống như nút của V4L2 gốc
flash thiết bị API sẽ. Các cuộc gọi được định tuyến đơn giản đến đèn flash LED API.

Việc mở thiết bị phụ flash V4L2 sẽ tạo giao diện sysfs của hệ thống con LED
không có sẵn. Giao diện được kích hoạt lại sau thiết bị phụ flash V4L2
đã đóng cửa.
