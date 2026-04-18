.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/board.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Ánh xạ GPIO
=============

Tài liệu này giải thích cách GPIO có thể được gán cho các thiết bị và chức năng nhất định.

Tất cả các nền tảng đều có thể kích hoạt thư viện GPIO, nhưng nếu nền tảng đó nghiêm ngặt
yêu cầu phải có chức năng GPIO, nó cần chọn GPIOLIB từ
Kconfig. Sau đó, cách ánh xạ GPIO tùy thuộc vào nền tảng sử dụng để làm gì.
mô tả cách bố trí phần cứng của nó. Hiện tại, ánh xạ có thể được xác định thông qua thiết bị
cây, ACPI và dữ liệu nền tảng.

Cây thiết bị
-----------
GPIO có thể dễ dàng được ánh xạ tới các thiết bị và chức năng trong cây thiết bị. các
cách chính xác để thực hiện điều đó phụ thuộc vào bộ điều khiển GPIO cung cấp GPIO, xem phần
ràng buộc cây thiết bị cho bộ điều khiển của bạn.

Ánh xạ GPIO được xác định trong nút của thiết bị tiêu dùng, trong thuộc tính có tên
<function>-gpios, trong đó <function> là chức năng mà trình điều khiển sẽ yêu cầu
thông qua gpiod_get(). Ví dụ::

foo_device {
		tương thích = "acme,foo";
		...
led-gpios = <&gpio 15 GPIO_ACTIVE_HIGH>, /* đỏ */
			    <&gpio 16 GPIO_ACTIVE_HIGH>, /* xanh */
			    <&gpio 17 GPIO_ACTIVE_HIGH>; /* màu xanh da trời */

power-gpios = <&gpio 1 GPIO_ACTIVE_LOW>;
	};

Các thuộc tính có tên <function>-gpio cũng được coi là hợp lệ và sử dụng các ràng buộc cũ
nhưng chỉ được hỗ trợ vì lý do tương thích và không nên được sử dụng cho
các ràng buộc mới hơn vì nó không còn được dùng nữa.

Thuộc tính này sẽ cung cấp GPIO 15, 16 và 17 cho người lái xe theo
chức năng "led" và GPIO 1 là "nguồn" GPIO::

cấu trúc gpio_desc *red, *green, *blue, *power;

đỏ = gpiod_get_index(dev, "led", 0, GPIOD_OUT_HIGH);
	xanh = gpiod_get_index(dev, "led", 1, GPIOD_OUT_HIGH);
	xanh = gpiod_get_index(dev, "led", 2, GPIOD_OUT_HIGH);

power = gpiod_get(dev, "power", GPIOD_OUT_HIGH);

Các GPIO led sẽ hoạt động ở mức cao, trong khi nguồn GPIO sẽ hoạt động ở mức thấp (tức là.
gpiod_is_active_low(power) sẽ đúng).

Tham số thứ hai của hàm gpiod_get(), chuỗi con_id, phải là
tiền tố <function> của hậu tố GPIO ("gpios" hoặc "gpio", tự động
được tra cứu bởi các hàm gpiod nội bộ) được sử dụng trong cây thiết bị. Với ở trên
Ví dụ "led-gpios", hãy sử dụng tiền tố không có dấu "-" làm tham số con_id: "led".

Trong nội bộ, hệ thống con GPIO có tiền tố hậu tố GPIO ("gpios" hoặc "gpio")
với chuỗi được truyền vào con_id để lấy chuỗi kết quả
(ZZ0000ZZ).

ACPI
----
ACPI cũng hỗ trợ tên hàm cho GPIO theo cách tương tự như DT.
Ví dụ DT ở trên có thể được chuyển đổi thành mô tả ACPI tương đương
với sự trợ giúp của _DSD (Dữ liệu cụ thể của thiết bị), được giới thiệu trong ACPI 5.1::

Thiết bị (FOO) {
		Tên (_CRS, ResourceTemplate () {
			GpioIo (Độc quyền, PullUp, 0, 0, IoRestrictionOutputOnly,
				"\\_SB.GPI0", 0, ResourceConsumer) { 15 } // đỏ
			GpioIo (Độc quyền, PullUp, 0, 0, IoRestrictionOutputOnly,
				"\\_SB.GPI0", 0, ResourceConsumer) { 16 } // màu xanh lá cây
			GpioIo (Độc quyền, PullUp, 0, 0, IoRestrictionOutputOnly,
				"\\_SB.GPI0", 0, ResourceConsumer) { 17 } // màu xanh
			GpioIo (Độc quyền, PullNone, 0, 0, IoRestrictionOutputOnly,
				"\\_SB.GPI0", 0, ResourceConsumer) { 1 } // nguồn
		})

Tên (_DSD, Gói () {
			ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
			Gói () {
				Gói () {
					"led-gpios",
					Gói () {
						^FOO, 0, 0, 1,
						^FOO, 1, 0, 1,
						^FOO, 2, 0, 1,
					}
				},
				Gói () { "power-gpios", Gói () { ^FOO, 3, 0, 0 } },
			}
		})
	}

Để biết thêm thông tin về các ràng buộc ACPI GPIO, hãy xem
Tài liệu/firmware-guide/acpi/gpio-properties.rst.

Nút phần mềm
--------------

Các nút phần mềm cho phép mã dành riêng cho bo mạch xây dựng bộ nhớ trong,
Cấu trúc dạng cây thiết bị sử dụng struct software_node và struct
thuộc tính_entry. Cấu trúc này sau đó có thể được liên kết với một thiết bị nền tảng,
cho phép trình điều khiển sử dụng thuộc tính thiết bị tiêu chuẩn API để truy vấn
cấu hình, giống như trên ACPI hoặc hệ thống cây thiết bị.

GPIO được hỗ trợ bằng nút phần mềm được mô tả bằng ZZ0000ZZ
macro, liên kết nút phần mềm đại diện cho bộ điều khiển GPIO với
thiết bị tiêu dùng. Nó cho phép người tiêu dùng sử dụng API gpiolib thông thường, chẳng hạn như
gpiod_get(), gpiod_get_Optional().

Nút phần mềm đại diện cho bộ điều khiển GPIO phải được gắn vào
Thiết bị điều khiển GPIO - dưới dạng nút chương trình cơ sở chính hoặc phụ.

Ví dụ: đây là cách mô tả một LED được kết nối với GPIO. Đây là một
thay thế cho việc sử dụng platform_data trên các hệ thống cũ.

.. code-block:: c

	#include <linux/property.h>
	#include <linux/gpio/machine.h>
	#include <linux/gpio/property.h>

	/*
	 * 1. Define a node for the GPIO controller.
	 */
	static const struct software_node gpio_controller_node = {
		.name = "gpio-foo",
	};

	/* 2. Define the properties for the LED device. */
	static const struct property_entry led_device_props[] = {
		PROPERTY_ENTRY_STRING("label", "myboard:green:status"),
		PROPERTY_ENTRY_STRING("linux,default-trigger", "heartbeat"),
		PROPERTY_ENTRY_GPIO("gpios", &gpio_controller_node, 42, GPIO_ACTIVE_HIGH),
		{ }
	};

	/* 3. Define the software node for the LED device. */
	static const struct software_node led_device_swnode = {
		.name = "status-led",
		.properties = led_device_props,
	};

	/*
	 * 4. Register the software nodes and the platform device.
	 */
	const struct software_node *swnodes[] = {
		&gpio_controller_node,
		&led_device_swnode,
		NULL
	};
	software_node_register_node_group(swnodes);

	/*
	 * 5. Attach the GPIO controller's software node to the device and
	 *    register it.
	 */
	 static void gpio_foo_register(void)
	 {
		struct platform_device_info pdev_info = {
			.name = "gpio-foo",
			.id = PLATFORM_DEVID_NONE,
			.swnode = &gpio_controller_node
		};

		platform_device_register_full(&pdev_info);
	 }

	// Then register a platform_device for "leds-gpio" and associate
	// it with &led_device_swnode via .fwnode.

Để có hướng dẫn đầy đủ về cách chuyển đổi tập tin bảng để sử dụng các nút phần mềm, hãy xem
Tài liệu/driver-api/gpio/legacy-boards.rst.

Dữ liệu nền tảng
-------------
Cuối cùng, GPIO có thể được liên kết với các thiết bị và chức năng sử dụng dữ liệu nền tảng. Ban
các tệp muốn làm như vậy cần phải bao gồm tiêu đề sau::

#include <linux/gpio/machine.h>

GPIO được ánh xạ bằng các bảng tra cứu, chứa các phiên bản của
cấu trúc gpiod_lookup. Hai macro được xác định để giúp khai báo các ánh xạ đó ::

GPIO_LOOKUP(khóa, chip_hwnum, con_id, cờ)
	GPIO_LOOKUP_IDX(khóa, chip_hwnum, con_id, idx, cờ)

Ở đâu

- key là nhãn của phiên bản gpiod_chip cung cấp GPIO hoặc
    tên dòng GPIO
  - chip_hwnum là số phần cứng của GPIO bên trong chip, hay U16_MAX
    để cho biết khóa đó là tên dòng GPIO
  - con_id là tên của hàm GPIO theo quan điểm của thiết bị. Nó
	có thể là NULL, trong trường hợp đó nó sẽ khớp với bất kỳ chức năng nào.
  - idx là chỉ mục của GPIO trong hàm.
  - cờ được xác định để chỉ định các thuộc tính sau:
	* GPIO_ACTIVE_HIGH - Dòng GPIO đang hoạt động ở mức cao
	* GPIO_ACTIVE_LOW - Dòng GPIO đang hoạt động ở mức thấp
	* GPIO_OPEN_DRAIN - Dòng GPIO được setup dạng cống hở
	* GPIO_OPEN_SOURCE - Dòng GPIO được thiết lập dưới dạng mã nguồn mở
	* GPIO_PERSISTENT - Dòng GPIO liên tục trong thời gian
				  tạm dừng/tiếp tục và duy trì giá trị của nó
	* Dòng GPIO_TRANSITORY - GPIO chỉ mang tính chất tạm thời và có thể mất hiệu lực
				  trạng thái điện trong khi tạm dừng/tiếp tục

Trong tương lai, những lá cờ này có thể được mở rộng để hỗ trợ nhiều thuộc tính hơn.

Lưu ý rằng:
  1. Tên dòng GPIO không được đảm bảo là duy nhất trên toàn cầu, vì vậy tên dòng đầu tiên
     trận đấu tìm thấy sẽ được sử dụng.
  2. GPIO_LOOKUP() chỉ là lối tắt của GPIO_LOOKUP_IDX() trong đó idx = 0.

Khi đó, một bảng tra cứu có thể được định nghĩa như sau, với một mục trống xác định
kết thúc. Trường 'dev_id' của bảng là mã định danh của thiết bị sẽ
sử dụng các GPIO này. Nó có thể là NULL, trong trường hợp đó nó sẽ được khớp với
gọi tới gpiod_get() bằng thiết bị NULL.

.. code-block:: c

        struct gpiod_lookup_table gpios_table = {
                .dev_id = "foo.0",
                .table = {
                        GPIO_LOOKUP_IDX("gpio.0", 15, "led", 0, GPIO_ACTIVE_HIGH),
                        GPIO_LOOKUP_IDX("gpio.0", 16, "led", 1, GPIO_ACTIVE_HIGH),
                        GPIO_LOOKUP_IDX("gpio.0", 17, "led", 2, GPIO_ACTIVE_HIGH),
                        GPIO_LOOKUP("gpio.0", 1, "power", GPIO_ACTIVE_LOW),
                        { },
                },
        };

Và bảng có thể được thêm bằng mã bảng như sau::

gpiod_add_lookup_table(&gpios_table);

Sau đó, trình điều khiển điều khiển "foo.0" sẽ có thể lấy GPIO của nó như sau::

cấu trúc gpio_desc *red, *green, *blue, *power;

đỏ = gpiod_get_index(dev, "led", 0, GPIOD_OUT_HIGH);
	xanh = gpiod_get_index(dev, "led", 1, GPIOD_OUT_HIGH);
	xanh = gpiod_get_index(dev, "led", 2, GPIOD_OUT_HIGH);

power = gpiod_get(dev, "power", GPIOD_OUT_HIGH);

Vì các GPIO "led" được ánh xạ ở mức hoạt động cao nên ví dụ này sẽ chuyển đổi chúng
tín hiệu lên 1, tức là bật đèn LED. Và đối với GPIO "sức mạnh", được ánh xạ
ở mức hoạt động thấp, tín hiệu thực tế của nó sẽ là 0 sau mã này. Trái ngược với
giao diện số nguyên GPIO kế thừa, thuộc tính mức hoạt động thấp được xử lý trong
ánh xạ và do đó minh bạch đối với người tiêu dùng GPIO.

Một tập hợp các hàm như gpiod_set_value() có sẵn để làm việc với
giao diện hướng mô tả mới.

Mảng ghim
--------------
Ngoài việc yêu cầu từng chân một của một chức năng, thiết bị có thể
cũng yêu cầu một mảng các chân được gán cho hàm.  Cách những chiếc ghim đó
được ánh xạ tới thiết bị sẽ xác định xem mảng có đủ điều kiện cho bitmap nhanh hay không
xử lý.  Nếu có, một bitmap sẽ được truyền trực tiếp qua các hàm mảng get/set
giữa người gọi và lệnh gọi lại .get/set_multiple() tương ứng của chip GPIO.

Để đủ điều kiện xử lý bitmap nhanh, mảng phải đáp ứng
yêu cầu sau:

- số phần cứng chân của thành viên mảng 0 cũng phải là 0,
- ghim số phần cứng của các thành viên mảng liên tiếp thuộc về cùng một
  chip như thành viên 0 cũng phải khớp với chỉ số mảng của chúng.

Nếu không, đường dẫn xử lý bitmap nhanh không được sử dụng để tránh liên tiếp
các chân thuộc cùng một chip nhưng không theo thứ tự phần cứng đang được xử lý
riêng biệt.

Nếu mảng áp dụng cho đường dẫn xử lý bitmap nhanh, các chân thuộc về
các chip khác với thành viên 0, cũng như các chip có chỉ mục khác với
số chân phần cứng của chúng, bị loại khỏi đường dẫn nhanh, cả đầu vào và
đầu ra.  Hơn nữa, các chân cống mở và nguồn mở được loại trừ khỏi bitmap nhanh
xử lý đầu ra.
