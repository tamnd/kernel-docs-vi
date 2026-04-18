.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/backlight/lp855x-driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Trình điều khiển hạt nhân lp855x
====================

Trình điều khiển đèn nền cho IC LP855x

Chip được hỗ trợ:

Texas Instruments LP8550, LP8551, LP8552, LP8553, LP8555, LP8556 và
	LP8557

Tác giả: Milo(Woogyom) Kim <milo.kim@ti.com>

Sự miêu tả
-----------

* Kiểm soát độ sáng

Độ sáng có thể được điều khiển bằng đầu vào pwm hoặc lệnh i2c.
  Trình điều khiển lp855x hỗ trợ cả hai trường hợp.

* Thuộc tính thiết bị

1) bl_ctl_mode

Chế độ điều khiển đèn nền.

Giá trị: dựa trên pwm hoặc dựa trên đăng ký

2) chip_id

Mã chip lp855x.

Giá trị: lp8550/lp8551/lp8552/lp8553/lp8555/lp8556/lp8557

Dữ liệu nền tảng cho lp855x
------------------------

Để hỗ trợ dữ liệu cụ thể của nền tảng, có thể sử dụng dữ liệu nền tảng lp855x.

*tên:
	Tên trình điều khiển đèn nền. Nếu nó không được xác định, tên mặc định sẽ được đặt.
* điều khiển thiết bị:
	Giá trị của thanh ghi DEVICE CONTROL.
* độ sáng ban đầu:
	Giá trị ban đầu của độ sáng đèn nền.
* chu kỳ_ns:
	Giá trị chu kỳ PWM cụ thể của nền tảng. đơn vị là nano.
	Chỉ hợp lệ khi độ sáng ở chế độ đầu vào pwm.
* kích thước_chương trình:
	Tổng kích thước của lp855x_rom_data.
*dữ liệu rom:
	Danh sách các thanh ghi eeprom/eprom mới.

Ví dụ
========

1) dữ liệu nền tảng lp8552: chế độ đăng ký i2c với dữ liệu eeprom mới ::

#define EEPROM_A5_ADDR 0xA5
    #define EEPROM_A5_VAL 0x4f /* EN_VSYNC=0 */

cấu trúc tĩnh lp855x_rom_data lp8552_eeprom_arr[] = {
	{EEPROM_A5_ADDR, EEPROM_A5_VAL},
    };

cấu trúc tĩnh lp855x_platform_data lp8552_pdata = {
	.name = "lcd-bl",
	.device_control = I2C_CONFIG(LP8552),
	.initial_brightness = INITIAL_BRT,
	.size_program = ARRAY_SIZE(lp8552_eeprom_arr),
	.rom_data = lp8552_eeprom_arr,
    };

2) dữ liệu nền tảng lp8556: chế độ đầu vào pwm với dữ liệu rom mặc định ::

cấu trúc tĩnh lp855x_platform_data lp8556_pdata = {
	.device_control = PWM_CONFIG(LP8556),
	.initial_brightness = INITIAL_BRT,
	.thời_ns = 1000000,
    };
