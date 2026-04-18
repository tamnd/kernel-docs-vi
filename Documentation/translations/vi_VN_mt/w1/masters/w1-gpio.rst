.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/w1/masters/w1-gpio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Trình điều khiển hạt nhân w1-gpio
=====================

Tác giả: Ville Syrjala <syrjala@sci.fi>


Sự miêu tả
-----------

Trình điều khiển chính xe buýt 1 dây GPIO. Người lái xe sử dụng GPIO API để điều khiển
dây và chân GPIO có thể được chỉ định bằng cách sử dụng bảng mô tả máy GPIO.
Cũng có thể xác định chủ bằng cây thiết bị, xem
Tài liệu/devicetree/binds/w1/w1-gpio.yaml


Ví dụ (mach-at91)
-------------------

::

#include <linux/gpio/machine.h>
  #include <linux/w1-gpio.h>

cấu trúc tĩnh gpiod_lookup_table foo_w1_gpiod_table = {
	.dev_id = "w1-gpio",
	.bảng = {
		GPIO_LOOKUP_IDX("at91-gpio", AT91_PIN_PB20, NULL, 0,
			GPIO_ACTIVE_HIGH|GPIO_OPEN_DRAIN),
	},
  };

cấu trúc tĩnh w1_gpio_platform_data foo_w1_gpio_pdata = {
	.ext_pullup_enable_pin = -EINVAL,
  };

cấu trúc tĩnh platform_device foo_w1_device = {
	.name = "w1-gpio",
	.id = -1,
	.dev.platform_data = &foo_w1_gpio_pdata,
  };

  ...
at91_set_GPIO_periph(foo_w1_gpio_pdata.pin, 1);
	at91_set_multi_drive(foo_w1_gpio_pdata.pin, 1);
	gpiod_add_lookup_table(&foo_w1_gpiod_table);
	platform_device_register(&foo_w1_device);
