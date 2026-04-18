.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/muxes/i2c-mux-gpio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Trình điều khiển hạt nhân i2c-mux-gpio
======================================

Tác giả: Peter Korsgaard <peter.korsgaard@barco.com>

Sự miêu tả
-----------

i2c-mux-gpio là trình điều khiển mux i2c cung cấp quyền truy cập vào các đoạn xe buýt I2C
từ bus I2C chính và MUX phần cứng được điều khiển thông qua các chân GPIO.

VÍ DỤ.::

---------- ---------- Xe buýt chặng 1 - - - - -
 ZZ0000ZZ SCL/SDA ZZ0001ZZ-------------- ZZ0002ZZ
 ZZ0003ZZ-------------ZZ0004ZZ
 ZZ0005ZZ ZZ0006ZZ Xe buýt đoạn 2 ZZ0007ZZ
 ZZ0008ZZ GPIO 1..N ZZ0009ZZ-------------- Thiết bị
 ZZ0010ZZ-------------ZZ0011ZZ ZZ0012ZZ
 ZZ0013ZZ ZZ0014ZZ Đoạn xe buýt M
 ZZ0015ZZ ZZ0016ZZ--------------ZZ0017ZZ
  ---------- ---------- - - - - -

SCL/SDA của bus I2C chính được ghép kênh thành đoạn bus 1..M
theo cài đặt của các chân GPIO 1..N.

Cách sử dụng
-----

i2c-mux-gpio sử dụng bus nền tảng, vì vậy bạn cần cung cấp cấu trúc
platform_device với platform_data trỏ đến một cấu trúc
i2c_mux_gpio_platform_data với số bộ điều hợp I2C của máy chủ
bus, số lượng đoạn bus cần tạo và các chân GPIO được sử dụng
để kiểm soát nó. Xem include/linux/platform_data/i2c-mux-gpio.h để biết chi tiết.

VÍ DỤ. điều tương tự như thế này đối với MUX cung cấp 4 đoạn xe buýt
được điều khiển thông qua 3 chân GPIO::

#include <linux/platform_data/i2c-mux-gpio.h>
  #include <linux/platform_device.h>

const tĩnh không dấu myboard_gpiomux_gpios[] = {
	AT91_PIN_PC26, AT91_PIN_PC25, AT91_PIN_PC24
  };

hằng số tĩnh không dấu myboard_gpiomux_values[] = {
	0, 1, 2, 3
  };

cấu trúc tĩnh i2c_mux_gpio_platform_data myboard_i2cmux_data = {
	.parent = 1,
	.base_nr = 2, /* tùy chọn */
	.values = myboard_gpiomux_values,
	.n_values = ARRAY_SIZE(myboard_gpiomux_values),
	.gpios = myboard_gpiomux_gpios,
	.n_gpios = ARRAY_SIZE(myboard_gpiomux_gpios),
	.idle = 4, /* tùy chọn */
  };

cấu trúc tĩnh platform_device myboard_i2cmux = {
	.name = "i2c-mux-gpio",
	.id = 0,
	.dev = {
		.platform_data = &myboard_i2cmux_data,
	},
  };

Nếu bạn không biết số pin GPIO tuyệt đối tại thời điểm đăng ký,
thay vào đó bạn có thể cung cấp tên chip (.chip_name) và mã pin GPIO tương đối
số và trình điều khiển i2c-mux-gpio sẽ thực hiện công việc cho bạn,
bao gồm cả việc trì hoãn việc thăm dò nếu chip GPIO không hoạt động ngay lập tức
có sẵn.

Đăng ký thiết bị
-------------------

Khi đăng ký thiết bị i2c-mux-gpio, bạn nên chuyển số
của bất kỳ chân GPIO nào mà nó sử dụng làm ID thiết bị. Điều này đảm bảo rằng mọi
instance có ID khác.

Ngoài ra, nếu bạn không cần tên thiết bị ổn định, bạn có thể chỉ cần
chuyển PLATFORM_DEVID_AUTO làm ID thiết bị và lõi nền tảng sẽ
gán ID động cho thiết bị của bạn. Nếu bạn không biết sự tuyệt đối
Số pin GPIO tại thời điểm đăng ký, đây thậm chí là lựa chọn duy nhất.
