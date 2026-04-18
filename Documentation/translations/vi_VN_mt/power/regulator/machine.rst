.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/power/regulator/machine.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Giao diện trình điều khiển máy điều chỉnh
=========================================

Giao diện trình điều khiển máy điều chỉnh dành cho bo mạch/máy cụ thể
mã khởi tạo để cấu hình hệ thống con điều chỉnh.

Hãy xem xét máy sau::

Bộ điều chỉnh-1 -+-> Bộ điều chỉnh-2 --> [Người tiêu dùng A @ 1.8 - 2.0V]
               |
               +-> [Người tiêu dùng B @ 3.3V]

Trình điều khiển cho người tiêu dùng A & B phải được ánh xạ tới bộ điều chỉnh chính xác trong
để kiểm soát nguồn cung cấp năng lượng của họ. Ánh xạ này có thể đạt được trong máy
mã khởi tạo bằng cách tạo cấu trúc điều chỉnh_consumer_supply cho
mỗi bộ điều chỉnh::

cấu trúc điều chỉnh_consumer_supply {
	const char ZZ0000ZZ người tiêu dùng dev_name() */
	const char ZZ0001ZZ nguồn cung cấp cho người tiêu dùng - ví dụ: "vcc" */
  };

ví dụ. cho máy trên::

cấu trúc tĩnh điều chỉnh_consumer_supply điều chỉnh1_consumers[] = {
	REGULATOR_SUPPLY("Vcc", "người tiêu dùng B"),
  };

cấu trúc tĩnh điều chỉnh_consumer_supply điều chỉnh2_consumers[] = {
	REGULATOR_SUPPLY("Vcc", "người tiêu dùng A"),
  };

Điều này ánh xạ Bộ điều chỉnh-1 tới nguồn cung cấp 'Vcc' cho Người tiêu dùng B và ánh xạ Bộ điều chỉnh-2
tới nguồn cung cấp 'Vcc' cho Người tiêu dùng A.

Các ràng buộc hiện có thể được đăng ký bằng cách xác định cấu trúc điều chỉnh_init_data
cho mỗi miền công suất điều chỉnh. Cấu trúc này cũng lập bản đồ người tiêu dùng
tới cơ quan quản lý cung cấp của họ::

cấu trúc tĩnh điều chỉnh_init_data điều chỉnh1_data = {
	.ràng buộc = {
		.name = "Bộ điều chỉnh-1",
		.min_uV = 3300000,
		.max_uV = 3300000,
		.valid_modes_mask = REGULATOR_MODE_NORMAL,
	},
	.num_consumer_supplies = ARRAY_SIZE(regulator1_consumers),
	.consumer_supplies = cơ quan quản lý1_consumers,
  };

Trường tên phải được đặt thành một cái gì đó mang tính mô tả hữu ích
cho hội đồng để cấu hình nguồn cung cấp cho các cơ quan quản lý khác và
để sử dụng trong việc ghi nhật ký và đầu ra chẩn đoán khác.  Thông thường tên
được sử dụng cho đường ray cung cấp trong sơ đồ là một lựa chọn tốt.  Nếu không
tên được cung cấp thì hệ thống con sẽ chọn một tên.

Bộ điều chỉnh-1 cung cấp năng lượng cho Bộ điều chỉnh-2. Mối quan hệ này phải được đăng ký
với lõi để Bộ điều chỉnh-1 cũng được bật khi Người tiêu dùng A kích hoạt
cung cấp (Bộ điều chỉnh-2). Bộ điều chỉnh nguồn cung cấp được thiết lập bởi Supply_regulator
trường bên dưới và co::

cấu trúc tĩnh điều chỉnh_init_data điều chỉnh2_data = {
	.supply_regulator = "Bộ điều chỉnh-1",
	.ràng buộc = {
		.min_uV = 1800000,
		.max_uV = 2000000,
		.valid_ops_mask = REGULATOR_CHANGE_VOLTAGE,
		.valid_modes_mask = REGULATOR_MODE_NORMAL,
	},
	.num_consumer_supplies = ARRAY_SIZE(regulator2_consumers),
	.consumer_supplies = cơ quan quản lý2_consumers,
  };

Cuối cùng, các thiết bị điều chỉnh phải được đăng ký theo cách thông thường::

cấu trúc tĩnh platform_device điều chỉnh_devices[] = {
	{
		.name = "bộ điều chỉnh",
		.id = DCDC_1,
		.dev = {
			.platform_data = &regulator1_data,
		},
	},
	{
		.name = "bộ điều chỉnh",
		.id = DCDC_2,
		.dev = {
			.platform_data = &regulator2_data,
		},
	},
  };
  /*đăng ký bộ điều chỉnh 1 thiết bị */
  platform_device_register(&regulator_devices[0]);

/*đăng ký thiết bị điều chỉnh 2 */
  platform_device_register(&regulator_devices[1]);
