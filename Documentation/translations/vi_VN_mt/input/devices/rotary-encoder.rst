.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/rotary-encoder.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================================================
bộ mã hóa quay - trình điều khiển chung cho các thiết bị được kết nối GPIO
==========================================================================

:Tác giả: Daniel Mack <daniel@caiaq.de>, tháng 2 năm 2009

Chức năng
---------

Bộ mã hóa quay là thiết bị được kết nối với CPU hoặc thiết bị khác
thiết bị ngoại vi có hai dây. Các đầu ra được dịch pha 90 độ
và bằng cách kích hoạt các cạnh giảm và tăng, hướng rẽ có thể
được xác định.

Một số bộ mã hóa có cả hai đầu ra ở mức thấp ở trạng thái ổn định, một số khác cũng có
trạng thái ổn định với cả hai đầu ra ở mức cao (chế độ nửa chu kỳ) và một số có
trạng thái ổn định ở tất cả các bước (chế độ một phần tư).

Sơ đồ pha của hai đầu ra này trông như thế này ::

_____ _____ _____
                 ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
  Kênh A ____ZZ0003ZZ_____ZZ0004ZZ_____ZZ0005ZZ____

: : : : : : : : : : : :
            __ _____ _____ _____
              ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ |
  Kênh B ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ |__

: : : : : : : : : : : :
  Sự kiện a b c d a b c d a b c d

ZZ0000ZZ
	          một bước

ZZ0000ZZ
	          một bước (chế độ nửa chu kỳ)

ZZ0000ZZ
	          một bước (chế độ quý)

Để biết thêm thông tin, vui lòng xem
	ZZ0000ZZ


Máy sự kiện/trạng thái
----------------------

Trong chế độ nửa chu kỳ, trạng thái a) và c) ở trên được sử dụng để xác định
hướng quay dựa trên trạng thái ổn định cuối cùng. Các sự kiện được báo cáo trong
trạng thái b) và d) vì trạng thái ổn định mới khác với trạng thái ổn định trước đó
(tức là vòng quay không bị đảo ngược nửa chừng).

Nếu không, áp dụng như sau:

a) Cạnh tăng trên kênh A, kênh B ở trạng thái thấp
	Trạng thái này được sử dụng để nhận biết lượt rẽ theo chiều kim đồng hồ

b) Cạnh tăng trên kênh B, kênh A ở trạng thái cao
	Khi vào trạng thái này, bộ mã hóa được đưa vào trạng thái 'vũ trang',
	có nghĩa là ở đó nó đã đi được một nửa chặng đường của quá trình chuyển đổi một bước.

c) Cạnh rơi trên kênh A, kênh B ở trạng thái cao
	Trạng thái này được sử dụng để nhận biết chuyển động quay ngược chiều kim đồng hồ

d) Cạnh rơi trên kênh B, kênh A ở trạng thái thấp
	Vị trí đỗ xe. Nếu bộ mã hóa chuyển sang trạng thái này, quá trình chuyển đổi hoàn toàn
	đáng lẽ phải xảy ra, trừ khi nó bị lật lại giữa chừng. các
	trạng thái 'vũ trang' cho chúng ta biết về điều đó.

Yêu cầu nền tảng
---------------------

Vì không có lệnh gọi phụ thuộc vào phần cứng trong trình điều khiển này nên nền tảng của nó
được sử dụng với phải hỗ trợ gpiolib. Một yêu cầu khác là IRQ phải được
có thể bắn ở cả hai cạnh.


Tích hợp bảng
-----------------

Để sử dụng trình điều khiển này trong hệ thống của bạn, hãy đăng ký platform_device với
đặt tên là 'bộ mã hóa quay' và liên kết IRQ và một số nền tảng cụ thể
dữ liệu với nó. Bởi vì trình điều khiển sử dụng các thuộc tính thiết bị chung nên điều này có thể
được thực hiện thông qua cây thiết bị, ACPI hoặc sử dụng các tệp bảng tĩnh, như trong
ví dụ dưới đây:

::

/* ví dụ về tập tin hỗ trợ bảng */

#include <linux/input.h>
	#include <linux/gpio/machine.h>
	#include <linux/property.h>

#define GPIO_ROTARY_A 1
	#define GPIO_ROTARY_B 2

cấu trúc tĩnh gpiod_lookup_table quay_encode_gpios = {
		.dev_id = "bộ mã hóa quay.0",
		.bảng = {
			GPIO_LOOKUP_IDX("gpio-0",
					GPIO_ROTARY_A, NULL, 0, GPIO_ACTIVE_LOW),
			GPIO_LOOKUP_IDX("gpio-0",
					GPIO_ROTARY_B, NULL, 1, GPIO_ACTIVE_HIGH),
			{ },
		},
	};

const tĩnh struct property_entry quay_encode_properties[] = {
		PROPERTY_ENTRY_U32("bộ mã hóa quay, từng bước trong khoảng thời gian", 24),
		PROPERTY_ENTRY_U32("linux,trục", ABS_X),
		PROPERTY_ENTRY_U32("bộ mã hóa quay,trục tương đối", 0),
		{ },
	};

cấu trúc const tĩnh phần mềm_node quay_encode_node = {
		.properties = quay_encode_properties,
	};

cấu trúc tĩnh platform_device quay_encode_device = {
		.name = "bộ mã hóa quay",
		.id = 0,
	};

	...

gpiod_add_lookup_table(&rotary_encoding_gpios);
	device_add_software_node(&rotary_encoding_device.dev, &rotary_encoding_node);
	platform_device_register(&rotary_encoding_device);

	...

Vui lòng tham khảo tài liệu liên kết cây thiết bị để xem tất cả các thuộc tính
được tài xế hỗ trợ.
