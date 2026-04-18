.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-lp5562.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Trình điều khiển hạt nhân cho lp5562
========================

* Trình điều khiển TI LP5562 LED

Tác giả: Milo(Woogyom) Kim <milo.kim@ti.com>

Sự miêu tả
===========

LP5562 có thể điều khiển tối đa 4 kênh. R/G/B và Trắng.
  Đèn LED có thể được điều khiển trực tiếp thông qua giao diện điều khiển lớp led.

Tất cả bốn kênh cũng có thể được điều khiển bằng các chương trình vi mô của động cơ.
  LP5562 có bộ nhớ chương trình bên trong để chạy các mẫu LED khác nhau.
  Để biết chi tiết, vui lòng tham khảo phần 'firmware' trong leds-lp55xx.txt

Thuộc tính thiết bị
================

động cơ_mux
  3 Động cơ được phân bổ trong LP5562, nhưng số lượng kênh là 4.
  Do đó, mỗi kênh phải được ánh xạ tới số động cơ.

Giá trị: RGB hoặc W

Thuộc tính này được sử dụng để lập trình dữ liệu LED với giao diện phần sụn.
  Không giống như LP5521/LP5523/55231, LP5562 có tính năng độc đáo cho mux động cơ,
  vì vậy cần có sysfs bổ sung

Bản đồ LED

===== === ==================================
  Đỏ... Động cơ 1 (đã sửa)
  Xanh ... Động cơ 2 (đã sửa)
  Màu xanh ... Động cơ 3 (đã sửa)
  Trắng ... Động cơ 1 hoặc 2 hoặc 3 (có chọn lọc)
  ===== === ==================================

Cách tải dữ liệu chương trình bằng engine_mux
=============================================

Trước khi tải dữ liệu chương trình LP5562, engine_mux phải được ghi giữa
  việc lựa chọn động cơ và tải phần sụn.
  Mux động cơ có hai chế độ khác nhau là RGB và W.
  RGB được sử dụng để tải dữ liệu chương trình RGB, W được sử dụng cho dữ liệu chương trình W.

Ví dụ: chạy mẫu kênh màu xanh lục nhấp nháy::

echo 2 > /sys/bus/i2c/devices/xxxx/select_engine # 2 dành cho kênh màu xanh lá cây
    echo "RGB" > /sys/bus/i2c/devices/xxxx/engine_mux # engine mux cho RGB
    echo 1 > /sys/class/firmware/lp5562/đang tải
    echo "4000600040FF6000" > /sys/class/firmware/lp5562/data
    echo 0 > /sys/class/firmware/lp5562/đang tải
    echo 1 > /sys/bus/i2c/devices/xxxx/run_engine

Để chạy mẫu màu trắng nhấp nháy::

echo 1 hoặc 2 hoặc 3 > /sys/bus/i2c/devices/xxxx/select_engine
    echo "W" > /sys/bus/i2c/devices/xxxx/engine_mux
    echo 1 > /sys/class/firmware/lp5562/đang tải
    echo "4000600040FF6000" > /sys/class/firmware/lp5562/data
    echo 0 > /sys/class/firmware/lp5562/đang tải
    echo 1 > /sys/bus/i2c/devices/xxxx/run_engine

Cách tải các mẫu được xác định trước
===================================

Vui lòng tham khảo 'leds-lp55xx.txt"

Cài đặt dòng điện của từng kênh
===============================

Giống như LP5521 và LP5523/55231, LP5562 cung cấp các cài đặt hiện tại của LED.
  'led_current' và 'max_current' được sử dụng.

Ví dụ về dữ liệu Nền tảng
========================

::

cấu trúc tĩnh lp55xx_led_config lp5562_led_config[] = {
		{
			.name = "R",
			.chan_nr = 0,
			.led_current = 20,
			.max_current = 40,
		},
		{
			.name = "G",
			.chan_nr = 1,
			.led_current = 20,
			.max_current = 40,
		},
		{
			.name = "B",
			.chan_nr = 2,
			.led_current = 20,
			.max_current = 40,
		},
		{
			.name = "W",
			.chan_nr = 3,
			.led_current = 20,
			.max_current = 40,
		},
	};

int tĩnh lp5562_setup(void)
	{
		/* thiết lập tài nguyên CTNH */
	}

khoảng trống tĩnh lp5562_release(void)
	{
		/* Giải phóng tài nguyên CTNH */
	}

static void lp5562_enable(trạng thái bool)
	{
		/* Điều khiển tín hiệu kích hoạt chip */
	}

cấu trúc tĩnh lp55xx_platform_data lp5562_platform_data = {
		.led_config = lp5562_led_config,
		.num_channels = ARRAY_SIZE(lp5562_led_config),
		.setup_resource = lp5562_setup,
		.release_resource = lp5562_release,
		.enable = lp5562_enable,
	};

Để định cấu hình dữ liệu cụ thể của nền tảng, cấu trúc lp55xx_platform_data được sử dụng


Nếu dòng điện được đặt thành 0 trong dữ liệu nền tảng thì kênh đó là
bị vô hiệu hóa và nó không hiển thị trong sysfs.
