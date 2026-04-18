.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-lp5523.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Trình điều khiển hạt nhân cho lp5523
====================================

* Chip điều khiển led LP5523 bán dẫn quốc gia
* Bảng dữ liệu: ZZ0000ZZ

Tác giả: Mathias Nyman, Yury Zaporozhets, Samu Onkalo
Liên hệ: Samu Onkalo (samu.p.onkalo-at-nokia.com)

Sự miêu tả
-----------
LP5523 có thể điều khiển tới 9 kênh. Đèn LED có thể được điều khiển trực tiếp thông qua
giao diện điều khiển lớp dẫn.
Tên của mỗi kênh có thể được cấu hình trong dữ liệu nền tảng - tên và nhãn.
Có ba tùy chọn để đặt tên kênh.

a) Xác định 'tên' trong dữ liệu nền tảng

Để đặt tên kênh cụ thể, hãy sử dụng dữ liệu nền tảng 'tên'.

- /sys/class/leds/R1 (tên: 'R1')
- /sys/class/leds/B1 (tên: 'B1')

b) Sử dụng 'nhãn' không có trường 'tên'

Đối với một tên thiết bị có số kênh thì hãy sử dụng 'nhãn'.
- /sys/class/leds/RGB:channelN (nhãn: 'RGB', N: 0 ~ 8)

c) Mặc định

Nếu cả hai trường đều là NULL, 'lp5523' được sử dụng theo mặc định.
- /sys/class/leds/lp5523:channelN (N: 0 ~ 8)

LP5523 có bộ nhớ chương trình bên trong để chạy các mẫu LED khác nhau.
Có hai cách để chạy mẫu LED.

1) giao diện sysfs - enginex_mode, enginex_load và enginex_leds

Giao diện điều khiển cho động cơ:

x là 1 .. 3

động cơx_mode:
	bị vô hiệu hóa, tải, chạy
  động cơx_load:
	tải vi mã
  động cơx_leds:
	điều khiển mux led

  ::

cd /sys/class/leds/lp5523:channel2/device
	echo "tải"> engine3_mode
	echo "9d80400004ff05ff437f0000"> engine3_load
	echo "111111111"> engine3_leds
	echo "chạy" > engine3_mode

Để dừng động cơ::

echo "bị vô hiệu hóa" > engine3_mode

2) Giao diện firmware - Giao diện chung LP55xx

Để biết chi tiết, vui lòng tham khảo phần 'firmware' trong leds-lp55xx.txt

LP5523 có ba fader chính. Nếu một kênh được ánh xạ tới một trong
các fader chính, đầu ra của nó bị mờ đi dựa trên giá trị của master
fader.

Ví dụ::

echo "123000123"> master_fader_leds

tạo các ánh xạ fader kênh sau::

kênh 0,6 đến master_fader1
  kênh 1,7 đến master_fader2
  kênh 2,8 đến master_fader3

Sau đó, để có 25% đầu ra ban đầu trên kênh 0,6::

echo 64 > master_fader1

Để có 0% đầu ra ban đầu (tức là không có đầu ra) kênh 1,7::

echo 0 > master_fader2

Để có 100% đầu ra ban đầu (tức là không bị mờ) trên kênh 2,8::

echo 255 > master_fader3

Để xóa tất cả các điều khiển fader chính::

echo "000000000" > master_fader_leds

Selftest luôn sử dụng dữ liệu hiện tại từ nền tảng.

Mỗi kênh chứa các cài đặt hiện tại của đèn LED.
- /sys/class/leds/lp5523:channel2/led_current - RW
- /sys/class/leds/lp5523:channel2/max_current - RO

Định dạng: 10x mA tức là 10 có nghĩa là 1,0 mA

Dữ liệu nền tảng mẫu::

cấu trúc tĩnh lp55xx_led_config lp5523_led_config[] = {
		{
			.name = "D1",
			.chan_nr = 0,
			.led_current = 50,
			.max_current = 130,
		},
	...
		{
			.chan_nr        = 8,
			.led_current    = 50,
			.max_current    = 130,
		}
	};

int tĩnh lp5523_setup(void)
	{
		/* Thiết lập tài nguyên CTNH */
	}

khoảng trống tĩnh lp5523_release(void)
	{
		/* Giải phóng tài nguyên CTNH */
	}

static void lp5523_enable(trạng thái bool)
	{
		/* Tín hiệu kích hoạt chip điều khiển */
	}

cấu trúc tĩnh lp55xx_platform_data lp5523_platform_data = {
		.led_config = lp5523_led_config,
		.num_channels = ARRAY_SIZE(lp5523_led_config),
		.clock_mode = LP55XX_CLOCK_EXT,
		.setup_resource = lp5523_setup,
		.release_resource = lp5523_release,
		.enable = lp5523_enable,
	};

Lưu ý
  chan_nr có thể có giá trị từ 0 đến 8.
