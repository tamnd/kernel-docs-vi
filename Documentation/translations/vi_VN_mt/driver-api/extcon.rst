.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/extcon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Hệ thống con thiết bị Extcon
=======================

Tổng quan
========

Hệ thống con Extcon (External Connector) cung cấp một khuôn khổ thống nhất cho
quản lý các kết nối bên ngoài trong hệ thống Linux. Nó cho phép người lái xe báo cáo
trạng thái của các đầu nối bên ngoài và cung cấp giao diện chuẩn hóa cho
không gian người dùng để truy vấn và giám sát các trạng thái này.

Extcon đặc biệt hữu ích trong các thiết bị hiện đại có nhiều kết nối
tùy chọn, chẳng hạn như điện thoại thông minh, máy tính bảng và máy tính xách tay. Nó giúp quản lý nhiều
các loại đầu nối, bao gồm:

1. Đầu nối USB (ví dụ: USB-C, micro-USB)
2. Cổng sạc (ví dụ: sạc nhanh, sạc không dây)
3. Giắc cắm âm thanh (ví dụ: giắc cắm tai nghe 3,5 mm)
4. Đầu ra video (ví dụ: HDMI, DisplayPort)
5. Trạm nối

Ví dụ thực tế:

1. Cổng điện thoại thông minh USB-C:
   Một cổng USB-C duy nhất trên điện thoại thông minh có thể phục vụ nhiều chức năng. Extcon
   có thể quản lý các trạng thái khác nhau của cổng này, chẳng hạn như:
   - Kết nối dữ liệu USB
   - Sạc (nhiều loại như sạc nhanh, USB Power Delivery)
   - Đầu ra âm thanh (tai nghe USB-C)
   - Đầu ra video (bộ chuyển đổi USB-C sang HDMI)

2. Đế cắm laptop:
   Khi một máy tính xách tay được kết nối với một trạm nối, nhiều kết nối sẽ được thực hiện
   được thực hiện đồng thời. Extcon có thể xử lý các thay đổi trạng thái cho:
   - Cung cấp điện
   - Màn hình ngoài
   - Kết nối trung tâm USB
   - Kết nối Ethernet

3. Tấm sạc không dây:
   Extcon có thể quản lý trạng thái kết nối sạc không dây, cho phép
   hệ thống sẽ phản hồi thích hợp khi thiết bị được đặt vào hoặc tháo ra
   từ miếng sạc.

4. Các cổng kết nối Smart Tivi HDMI:
   Trong TV thông minh, Extcon có thể quản lý nhiều cổng HDMI, phát hiện khi nào
   các thiết bị được kết nối hoặc ngắt kết nối và có khả năng xác định
   loại thiết bị (ví dụ: máy chơi game, hộp giải mã tín hiệu, đầu phát Blu-ray).

Khung Extcon đơn giản hóa việc phát triển trình điều khiển cho các hệ thống phức tạp này
các tình huống bằng cách cung cấp một cách chuẩn hóa để báo cáo và kết nối truy vấn
trạng thái, xử lý các kết nối loại trừ lẫn nhau và quản lý trình kết nối
tài sản. Điều này cho phép xử lý mạnh mẽ và linh hoạt hơn các tác vụ bên ngoài.
kết nối trong các thiết bị hiện đại.

Thành phần chính
==============

extcon_dev
----------

Cấu trúc cốt lõi đại diện cho một thiết bị Extcon::

cấu trúc extcon_dev {
        const char *tên;
        const unsigned int *supported_cable;
        const u32 *mutually_exclusive;

/*Dữ liệu nội bộ */
        nhà phát triển thiết bị cấu trúc;
        id int không dấu;
        struct raw_notifier_head nh_all;
        struct raw_notifier_head *nh;
        mục nhập struct list_head;
        int max_supported;
        khóa spinlock_t;
        trạng thái u32;

/* Liên quan đến hệ thống */
        cấu trúc device_type extcon_dev_type;
        struct extcon_cable *cáp;
        struct attribute_group attr_g_muex;
        thuộc tính cấu trúc **attrs_muex;
        cấu trúc device_attribute *d_attrs_muex;
    };

Các trường chính:

- ZZ0000ZZ: Tên thiết bị Extcon
- ZZ0001ZZ: Mảng các loại cáp được hỗ trợ
- ZZ0002ZZ: Mảng xác định các loại cáp loại trừ lẫn nhau
  Trường này rất quan trọng để thực thi các ràng buộc phần cứng. Đó là một mảng
  Số nguyên không dấu 32 bit, trong đó mỗi phần tử đại diện cho một tập hợp các
  các loại cáp độc quyền. Mảng phải được kết thúc bằng số 0.

Ví dụ:

  ::

const tĩnh u32 lẫn nhau_exclusive[] = {
          BIT(0) | BIT(1), /* Cáp 0 và 1 loại trừ lẫn nhau */
          BIT(2) ZZ0000ZZ BIT(4), /* Cáp 2, 3 và 4 loại trừ lẫn nhau */
          0 /* Kẻ hủy diệt */
      };

Trong ví dụ này, cáp 0 và 1 không thể được kết nối đồng thời và
  cáp 2, 3 và 4 cũng loại trừ lẫn nhau. Điều này hữu ích cho
  các tình huống như một cổng duy nhất có thể là USB hoặc HDMI, nhưng không phải cả hai
  cùng một lúc.

Lõi Extcon sử dụng thông tin này để ngăn chặn sự kết hợp không hợp lệ của
  trạng thái cáp, đảm bảo rằng các trạng thái được báo cáo luôn nhất quán
  với khả năng phần cứng.

- ZZ0000ZZ: Trạng thái hiện tại của thiết bị (bitmap của cáp được kết nối)


extcon_cable
------------

Đại diện cho một cáp riêng lẻ được quản lý bởi thiết bị Extcon::

cấu trúc extcon_cable {
        cấu trúc extcon_dev *edev;
        int cable_index;
        struct attribute_group attr_g;
        cấu trúc device_attribute attr_name;
        cấu trúc device_attribute attr_state;
        thuộc tính cấu trúc *attrs[3];
        liên minh extcon_property_value usb_propval[EXTCON_PROP_USB_CNT];
        liên minh extcon_property_value chg_propval[EXTCON_PROP_CHG_CNT];
        liên minh extcon_property_value jack_propval[EXTCON_PROP_JACK_CNT];
        liên minh extcon_property_value disp_propval[EXTCON_PROP_DISP_CNT];
        DECLARE_BITMAP(usb_bit, EXTCON_PROP_USB_CNT);
        DECLARE_BITMAP(chg_bits, EXTCON_PROP_CHG_CNT);
        DECLARE_BITMAP(jack_bits, EXTCON_PROP_JACK_CNT);
        DECLARE_BITMAP(disp_bits, EXTCON_PROP_DISP_CNT);
    };

Chức năng cốt lõi
==============

.. kernel-doc:: drivers/extcon/extcon.c
   :identifiers: extcon_get_state

.. kernel-doc:: drivers/extcon/extcon.c
   :identifiers: extcon_set_state

.. kernel-doc:: drivers/extcon/extcon.c
   :identifiers: extcon_set_state_sync

.. kernel-doc:: drivers/extcon/extcon.c
   :identifiers: extcon_get_property


Giao diện hệ thống
===============

Các thiết bị Extcon hiển thị các thuộc tính sysfs sau:

- ZZ0000ZZ: Tên thiết bị Extcon
- ZZ0001ZZ: Trạng thái hiện tại của tất cả các loại cáp được hỗ trợ
- ZZ0002ZZ: Tên cáp được hỗ trợ thứ N
- ZZ0003ZZ: Trạng thái của cáp được hỗ trợ thứ N

Ví dụ sử dụng
-------------

.. code-block:: c

    #include <linux/module.h>
    #include <linux/platform_device.h>
    #include <linux/extcon.h>

    struct my_extcon_data {
        struct extcon_dev *edev;
        struct device *dev;
    };

    static const unsigned int my_extcon_cable[] = {
        EXTCON_USB,
        EXTCON_USB_HOST,
        EXTCON_NONE,
    };

    static int my_extcon_probe(struct platform_device *pdev)
    {
        struct my_extcon_data *data;
        int ret;

        data = devm_kzalloc(&pdev->dev, sizeof(*data), GFP_KERNEL);
        if (!data)
            return -ENOMEM;

        data->dev = &pdev->dev;

        /* Initialize extcon device */
        data->edev = devm_extcon_dev_allocate(data->dev, my_extcon_cable);
        if (IS_ERR(data->edev)) {
            dev_err(data->dev, "Failed to allocate extcon device\n");
            return PTR_ERR(data->edev);
        }

        /* Register extcon device */
        ret = devm_extcon_dev_register(data->dev, data->edev);
        if (ret < 0) {
            dev_err(data->dev, "Failed to register extcon device\n");
            return ret;
        }

        platform_set_drvdata(pdev, data);

        /* Example: Set initial state */
        extcon_set_state_sync(data->edev, EXTCON_USB, true);

        dev_info(data->dev, "My extcon driver probed successfully\n");
        return 0;
    }

    static int my_extcon_remove(struct platform_device *pdev)
    {
        struct my_extcon_data *data = platform_get_drvdata(pdev);

        /* Example: Clear state before removal */
        extcon_set_state_sync(data->edev, EXTCON_USB, false);

        dev_info(data->dev, "My extcon driver removed\n");
        return 0;
    }

    static const struct of_device_id my_extcon_of_match[] = {
        { .compatible = "my,extcon-device", },
        { },
    };
    MODULE_DEVICE_TABLE(of, my_extcon_of_match);

    static struct platform_driver my_extcon_driver = {
        .driver = {
            .name = "my-extcon-driver",
            .of_match_table = my_extcon_of_match,
        },
        .probe = my_extcon_probe,
        .remove = my_extcon_remove,
    };

    module_platform_driver(my_extcon_driver);

Ví dụ này chứng tỏ:
---------------------------

- Xác định các loại cáp được hỗ trợ (USB và USB Host trong trường hợp này).
- Cấp phát và đăng ký thiết bị extcon.
- Đặt trạng thái ban đầu cho cáp (USB được kết nối trong ví dụ này).
- Xóa trạng thái khi gỡ bỏ driver.
