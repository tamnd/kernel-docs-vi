.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-ocores.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển hạt nhân i2c-ocores
========================

Bộ điều hợp được hỗ trợ:
  * Bộ điều khiển OpenCores.org I2C của Richard Herveille (xem liên kết biểu dữ liệu)
    ZZ0000ZZ

Tác giả: Peter Korsgaard <peter@korsgaard.com>

Sự miêu tả
-----------

i2c-ocores là trình điều khiển bus i2c cho bộ điều khiển OpenCores.org I2C
Lõi IP của Richard Herveille.

Cách sử dụng
-----

i2c-ocores sử dụng bus nền tảng, vì vậy bạn cần cung cấp cấu trúc
platform_device với địa chỉ cơ sở và số ngắt. các
dev.platform_data của thiết bị cũng phải trỏ đến một cấu trúc
ocores_i2c_platform_data (xem linux/platform_data/i2c-ocores.h) mô tả
khoảng cách giữa các thanh ghi và tốc độ xung nhịp đầu vào.
Ngoài ra còn có khả năng đính kèm danh sách i2c_board_info
trình điều khiển i2c-ocores sẽ thêm vào bus khi tạo.

VÍ DỤ. đại loại như::

tài nguyên cấu trúc tĩnh ocores_resources[] = {
	[0] = {
		.start = MYI2C_BASEADDR,
		.end = MYI2C_BASEADDR + 8,
		.flags = IORESOURCE_MEM,
	},
	[1] = {
		.start = MYI2C_IRQ,
		.end = MYI2C_IRQ,
		.flags = IORESOURCE_IRQ,
	},
  };

/*thông tin bảng tùy chọn */
  cấu trúc i2c_board_info ocores_i2c_board_info[] = {
	{
		I2C_BOARD_INFO("tsc2003", 0x48),
		.platform_data = &tsc2003_platform_data,
		.irq = TSC_IRQ
	},
	{
		I2C_BOARD_INFO("adv7180", 0x42 >> 1),
		.irq = ADV_IRQ
	}
  };

cấu trúc tĩnh ocores_i2c_platform_data myi2c_data = {
	.regstep = 2, /* hai byte giữa các thanh ghi */
	.clock_khz = 50000, /* xung nhịp đầu vào 50 MHz */
	.devices = ocores_i2c_board_info, /* bảng thiết bị tùy chọn */
	.num_devices = ARRAY_SIZE(ocores_i2c_board_info), /* kích thước bảng */
  };

cấu trúc tĩnh platform_device myi2c = {
	.name = "ocores-i2c",
	.dev = {
		.platform_data = &myi2c_data,
	},
	.num_resources = ARRAY_SIZE(ocores_resources),
	.resource = ocores_resource,
  };
