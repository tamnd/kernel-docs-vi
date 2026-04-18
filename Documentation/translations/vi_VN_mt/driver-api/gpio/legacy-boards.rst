.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/legacy-boards.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hỗ trợ các bảng kế thừa
========================

Nhiều trình điều khiển trong kernel, chẳng hạn như ZZ0000ZZ và ZZ0001ZZ,
chuyển từ sử dụng ZZ0002ZZ dành riêng cho bo mạch sang một thiết bị hợp nhất
giao diện thuộc tính. Giao diện này cho phép trình điều khiển đơn giản hơn và hơn thế nữa
chung chung, vì chúng có thể truy vấn các thuộc tính theo cách chuẩn hóa.

Trên các hệ thống hiện đại, các thuộc tính này được cung cấp thông qua cây thiết bị. Tuy nhiên, một số
các nền tảng cũ hơn chưa được chuyển đổi sang cây thiết bị và thay vào đó dựa vào
board để mô tả cấu hình phần cứng của chúng. Để thu hẹp khoảng cách này và
cho phép các bo mạch kế thừa này hoạt động với các trình điều khiển chung, hiện đại, kernel
cung cấp một cơ chế gọi là ZZ0000ZZ.

Tài liệu này cung cấp hướng dẫn về cách chuyển đổi một tập tin bảng kế thừa từ việc sử dụng
ZZ0000ZZ và ZZ0001ZZ đến nút phần mềm hiện đại
phương pháp mô tả các thiết bị được kết nối GPIO.

Ý tưởng cốt lõi: Nút phần mềm
-----------------------------

Các nút phần mềm cho phép mã dành riêng cho bo mạch xây dựng bộ nhớ trong,
Cấu trúc dạng cây thiết bị sử dụng struct software_node và struct
thuộc tính_entry. Cấu trúc này sau đó có thể được liên kết với một thiết bị nền tảng,
cho phép trình điều khiển sử dụng các thuộc tính thiết bị tiêu chuẩn API (ví dụ:
device_property_read_u32(), device_property_read_string()) để truy vấn
cấu hình, giống như trên ACPI hoặc hệ thống cây thiết bị.

Mã gpiolib có hỗ trợ xử lý các nút phần mềm, do đó nếu GPIO
được mô tả chính xác, như chi tiết trong phần bên dưới, sau đó là các API gpiolib thông thường,
chẳng hạn như gpiod_get(), gpiod_get_Optional() và những thứ khác sẽ hoạt động.

Yêu cầu đối với Thuộc tính GPIO
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi sử dụng các nút phần mềm để mô tả các kết nối GPIO, nội dung sau
lõi GPIO phải đáp ứng các yêu cầu để giải quyết chính xác tham chiếu:

1. **Nút phần mềm của bộ điều khiển GPIO phải được đăng ký và gắn vào
    ZZ0000ZZ của bộ điều khiển là chính hoặc phụ
    nút phần sụn.** Lõi gpiolib sử dụng địa chỉ của nút phần sụn để
    tìm ZZ0001ZZ tương ứng khi chạy.

2. ZZ0002ZZ ZZ0000ZZ
    macro xử lý việc này vì đây là bí danh của ZZ0001ZZ.

3. ZZ0000ZZ

- Đối số đầu tiên là phần bù GPIO trong bộ điều khiển.
    - Đối số thứ hai là các cờ cho dòng GPIO (ví dụ:
      GPIO_ACTIVE_HIGH, GPIO_ACTIVE_LOW).

Macro ZZ0000ZZ là cách ưa thích để xác định GPIO
thuộc tính trong các nút phần mềm.

Ví dụ chuyển đổi
------------------

Chúng ta hãy xem qua một ví dụ về chuyển đổi tệp bảng xác định GPIO-
đã kết nối LED và một nút.

Trước: Sử dụng dữ liệu nền tảng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Một tệp bảng kế thừa điển hình có thể trông như thế này:

.. code-block:: c

  #include <linux/platform_device.h>
  #include <linux/leds.h>
  #include <linux/gpio_keys.h>
  #include <linux/gpio/machine.h>

  #define MYBOARD_GPIO_CONTROLLER "gpio-foo"

  /* LED setup */
  static const struct gpio_led myboard_leds[] = {
  	{
  		.name = "myboard:green:status",
  		.default_trigger = "heartbeat",
  	},
  };

  static const struct gpio_led_platform_data myboard_leds_pdata = {
  	.num_leds = ARRAY_SIZE(myboard_leds),
  	.leds = myboard_leds,
  };

  static struct gpiod_lookup_table myboard_leds_gpios = {
  	.dev_id = "leds-gpio",
  	.table = {
  		GPIO_LOOKUP_IDX(MYBOARD_GPIO_CONTROLLER, 42, NULL, 0, GPIO_ACTIVE_HIGH),
  		{ },
  	},
  };

  /* Button setup */
  static struct gpio_keys_button myboard_buttons[] = {
  	{
  		.code = KEY_WPS_BUTTON,
  		.desc = "WPS Button",
  		.active_low = 1,
  	},
  };

  static const struct gpio_keys_platform_data myboard_buttons_pdata = {
  	.buttons = myboard_buttons,
  	.nbuttons = ARRAY_SIZE(myboard_buttons),
  };

  static struct gpiod_lookup_table myboard_buttons_gpios = {
  	.dev_id = "gpio-keys",
  	.table = {
  		GPIO_LOOKUP_IDX(MYBOARD_GPIO_CONTROLLER, 15, NULL, 0, GPIO_ACTIVE_LOW),
  		{ },
  	},
  };

  /* Device registration */
  static int __init myboard_init(void)
  {
  	struct platform_device_info pdev_info = {
  		.name = MYBOARD_GPIO_CONTROLLER,
  		.id = PLATFORM_DEVID_NONE,
  		.swnode = &gpio_controller_node
  	};

  	gpiod_add_lookup_table(&myboard_leds_gpios);
  	gpiod_add_lookup_table(&myboard_buttons_gpios);

  	platform_device_register_full(&pdev_info);
  	platform_device_register_data(NULL, "leds-gpio", -1,
  				      &myboard_leds_pdata, sizeof(myboard_leds_pdata));
  	platform_device_register_data(NULL, "gpio-keys", -1,
  				      &myboard_buttons_pdata,
  				      sizeof(myboard_buttons_pdata));

  	return 0;
  }

Sau: Sử dụng nút phần mềm
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đây là cách cấu hình tương tự có thể được thể hiện bằng cách sử dụng các nút phần mềm.

Bước 1: Xác định Nút điều khiển GPIO
***************************************

Đầu tiên, xác định nút phần mềm đại diện cho bộ điều khiển GPIO mà
Đèn LED và các nút được kết nối với. ZZ0000ZZ của nút này là tùy chọn.

.. code-block:: c

  #include <linux/property.h>
  #include <linux/gpio/property.h>

  #define MYBOARD_GPIO_CONTROLLER "gpio-foo"

  static const struct software_node myboard_gpio_controller_node = {
  	.name = MYBOARD_GPIO_CONTROLLER,
  };

Bước 2: Xác định nút và thuộc tính của thiết bị tiêu dùng
*********************************************************

Tiếp theo, xác định các nút phần mềm cho thiết bị tiêu dùng (đèn LED và nút).
Điều này liên quan đến việc tạo nút cha cho từng loại thiết bị và các nút con cho
mỗi LED hoặc nút riêng lẻ.

.. code-block:: c

  /* LED setup */
  static const struct software_node myboard_leds_node = {
  	.name = "myboard-leds",
  };

  static const struct property_entry myboard_status_led_props[] = {
  	PROPERTY_ENTRY_STRING("label", "myboard:green:status"),
  	PROPERTY_ENTRY_STRING("linux,default-trigger", "heartbeat"),
  	PROPERTY_ENTRY_GPIO("gpios", &myboard_gpio_controller_node, 42, GPIO_ACTIVE_HIGH),
  	{ }
  };

  static const struct software_node myboard_status_led_swnode = {
  	.name = "status-led",
  	.parent = &myboard_leds_node,
  	.properties = myboard_status_led_props,
  };

  /* Button setup */
  static const struct software_node myboard_keys_node = {
  	.name = "myboard-keys",
  };

  static const struct property_entry myboard_wps_button_props[] = {
  	PROPERTY_ENTRY_STRING("label", "WPS Button"),
  	PROPERTY_ENTRY_U32("linux,code", KEY_WPS_BUTTON),
  	PROPERTY_ENTRY_GPIO("gpios", &myboard_gpio_controller_node, 15, GPIO_ACTIVE_LOW),
  	{ }
  };

  static const struct software_node myboard_wps_button_swnode = {
  	.name = "wps-button",
  	.parent = &myboard_keys_node,
  	.properties = myboard_wps_button_props,
  };



Bước 3: Nhóm và đăng ký các nút
************************************

Để có khả năng bảo trì, việc nhóm tất cả các nút phần mềm thành một
mảng đơn và đăng ký chúng bằng một cuộc gọi.

.. code-block:: c

  static const struct software_node * const myboard_swnodes[] = {
  	&myboard_gpio_controller_node,
  	&myboard_leds_node,
  	&myboard_status_led_swnode,
  	&myboard_keys_node,
  	&myboard_wps_button_swnode,
  	NULL
  };

  static int __init myboard_init(void)
  {
  	int error;

  	error = software_node_register_node_group(myboard_swnodes);
  	if (error) {
  		pr_err("Failed to register software nodes: %d\n", error);
  		return error;
  	}

  	// ... platform device registration follows
  }

.. note::
  When splitting registration of nodes by devices that they represent, it is
  essential that the software node representing the GPIO controller itself
  is registered first, before any of the nodes that reference it.

Bước 4: Đăng ký thiết bị nền tảng với nút phần mềm
*****************************************************

Cuối cùng, đăng ký các thiết bị nền tảng và liên kết chúng với các thiết bị tương ứng.
các nút phần mềm sử dụng trường ZZ0000ZZ trong struct platform_device_info.

.. code-block:: c

  static struct platform_device *leds_pdev;
  static struct platform_device *keys_pdev;

  static int __init myboard_init(void)
  {
  	struct platform_device_info pdev_info;
  	int error;

  	error = software_node_register_node_group(myboard_swnodes);
  	if (error)
  		return error;

  	memset(&pdev_info, 0, sizeof(pdev_info));
  	pdev_info.name = MYBOARD_GPIO_CONTROLLER;
  	pdev_info.id = PLATFORM_DEVID_NONE;
  	pdev_info.swnode = &myboard_gpio_controller_node;
  	gpio_pdev = platform_device_register_full(&pdev_info);
  	if (IS_ERR(gpio_pdev)) {
  		error = PTR_ERR(gpio_pdev);
  		goto err_unregister_nodes;
  	}

  	memset(&pdev_info, 0, sizeof(pdev_info));
  	pdev_info.name = "leds-gpio";
  	pdev_info.id = PLATFORM_DEVID_NONE;
  	pdev_info.fwnode = software_node_fwnode(&myboard_leds_node);
  	leds_pdev = platform_device_register_full(&pdev_info);
  	if (IS_ERR(leds_pdev)) {
  		error = PTR_ERR(leds_pdev);
  		platform_device_unregister(gpio_pdev);
  		goto err_unregister_nodes;
  	}

  	memset(&pdev_info, 0, sizeof(pdev_info));
  	pdev_info.name = "gpio-keys";
  	pdev_info.id = PLATFORM_DEVID_NONE;
  	pdev_info.fwnode = software_node_fwnode(&myboard_keys_node);
  	keys_pdev = platform_device_register_full(&pdev_info);
  	if (IS_ERR(keys_pdev)) {
  		error = PTR_ERR(keys_pdev);
  		platform_device_unregister(gpio_pdev);
  		platform_device_unregister(leds_pdev);
  		goto err_unregister_nodes;
  	}

  	return 0;

  err_unregister_nodes:
  	software_node_unregister_node_group(myboard_swnodes);
  	return error;
  }

  static void __exit myboard_exit(void)
  {
  	platform_device_unregister(keys_pdev);
  	platform_device_unregister(leds_pdev);
  	platform_device_unregister(gpio_pdev);
  	software_node_unregister_node_group(myboard_swnodes);
  }

Với những thay đổi này, trình điều khiển ZZ0000ZZ và ZZ0001ZZ chung sẽ
có thể thăm dò thành công và nhận cấu hình của chúng từ các thuộc tính
được xác định trong các nút phần mềm, loại bỏ nhu cầu về nền tảng dành riêng cho bo mạch
dữ liệu.
