.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/driver-model/devres.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Devres - Tài nguyên thiết bị được quản lý
================================

Tejun Heo <teheo@suse.de>

Bản thảo đầu tiên ngày 10 tháng 1 năm 2007

.. contents

   1. Intro			: Huh? Devres?
   2. Devres			: Devres in a nutshell
   3. Devres Group		: Group devres'es and release them together
   4. Details			: Life time rules, calling context, ...
   5. Overhead			: How much do we have to pay for this?
   6. List of managed interfaces: Currently implemented managed interfaces


1. Giới thiệu
--------

devres đã nghĩ ra khi cố gắng chuyển đổi libata để sử dụng iomap.  Mỗi
Địa chỉ iomapped phải được giữ lại và không được ánh xạ khi tách trình điều khiển.  cho
ví dụ: bộ điều khiển SFF ATA đơn giản (nghĩa là PCI IDE cũ tốt) trong
chế độ gốc sử dụng 5 THANH PCI và tất cả chúng phải
được duy trì.

Giống như nhiều trình điều khiển thiết bị khác, trình điều khiển cấp thấp libata có
có đủ lỗi trong -> loại bỏ và -> thăm dò đường dẫn lỗi.  Vâng, vâng,
đó có thể là do các nhà phát triển trình điều khiển cấp thấp libata lười biếng
rất nhiều, nhưng không phải tất cả đều là nhà phát triển trình điều khiển cấp thấp sao?  Sau khi chi tiêu một
ngày loay hoay với phần cứng bị hư hỏng mà không có tài liệu hoặc
tài liệu bị hỏng não, nếu cuối cùng nó cũng hoạt động được, thì nó đang hoạt động.

Vì lý do này hay lý do khác, người lái xe cấp thấp không nhận được nhiều
chú ý hoặc kiểm tra dưới dạng mã lõi và các lỗi trên trình điều khiển tách hoặc
lỗi khởi tạo không xảy ra thường xuyên đến mức đáng chú ý.
Đường dẫn thất bại ban đầu còn tệ hơn vì nó ít được di chuyển hơn trong khi
cần xử lý nhiều điểm vào.

Vì vậy, nhiều trình điều khiển cấp thấp cuối cùng bị rò rỉ tài nguyên khi tách trình điều khiển
và việc triển khai đường dẫn lỗi bị hỏng một nửa trong ->probe()
sẽ rò rỉ tài nguyên hoặc thậm chí gây ra lỗi khi xảy ra lỗi.  bản đồ iomap
thêm nhiều hơn vào hỗn hợp này.  msi và msix cũng vậy.


2. Devres
---------

devres về cơ bản là danh sách liên kết của các vùng bộ nhớ có kích thước tùy ý
liên kết với một thiết bị cấu trúc.  Mỗi mục devres được liên kết với
một chức năng phát hành.  Một devres có thể được phát hành theo nhiều cách.  Không
dù thế nào đi chăng nữa, tất cả các mục dành cho nhà phát triển đều được phát hành khi tách trình điều khiển.  Bật
phát hành, hàm phát hành liên quan sẽ được gọi và sau đó
mục nhập devres được giải phóng.

Giao diện được quản lý được tạo cho các tài nguyên thường được thiết bị sử dụng
trình điều khiển sử dụng devres.  Ví dụ: thu được bộ nhớ DMA nhất quán
sử dụng dma_alloc_coherent().  Phiên bản được quản lý được gọi là
dmam_alloc_coherent().  Nó giống hệt với dma_alloc_coherent() ngoại trừ
đối với bộ nhớ DMA được phân bổ bằng cách sử dụng nó sẽ được quản lý và sẽ được
tự động phát hành khi tách trình điều khiển.  Việc thực hiện trông giống như
sau đây::

cấu trúc dma_devres {
	kích thước size_t;
	void *vaddr;
	dma_addr_t dma_handle;
  };

static void dmam_coherent_release(thiết bị cấu trúc *dev, void *res)
  {
	struct dma_devres *this = res;

dma_free_coherent(dev, this->size, this->vaddr, this->dma_handle);
  }

dmam_alloc_coherent(dev, size, dma_handle, gfp)
  {
	cấu trúc dma_devres *dr;
	void *vaddr;

dr = devres_alloc(dmam_coherent_release, sizeof(*dr), gfp);
	...

/* cấp phát bộ nhớ DMA như bình thường */
	vaddr = dma_alloc_coherent(...);
	...

/* kích thước bản ghi, vaddr, dma_handle trong dr */
	dr->vaddr = vaddr;
	...

devres_add(dev, dr);

trả lại vaddr;
  }

Nếu người lái xe sử dụng dmam_alloc_coherent(), khu vực này được đảm bảo là
được giải phóng dù quá trình khởi tạo bị lỗi nửa chừng hay thiết bị bị
tách ra.  Nếu hầu hết các tài nguyên được lấy bằng giao diện được quản lý,
trình điều khiển có thể có mã khởi tạo và mã thoát đơn giản hơn nhiều.  Đường dẫn ban đầu về cơ bản
trông giống như sau::

my_init_one()
  {
	struct mydev *d;

d = devm_kzalloc(dev, sizeof(*d), GFP_KERNEL);
	nếu (!d)
		trả về -ENOMEM;

d->ring = dmam_alloc_coherent(...);
	nếu (!d->ring)
		trả về -ENOMEM;

nếu (kiểm tra cái gì đó)
		trả về -EINVAL;
	...

trả về register_to_upper_layer(d);
  }

Và đường dẫn thoát::

my_remove_one()
  {
	hủy đăng ký_from_upper_layer(d);
	tắt máy_my_hardware();
  }

Như đã trình bày ở trên, trình điều khiển cấp thấp có thể được đơn giản hóa rất nhiều bằng cách sử dụng
devres.  Sự phức tạp được chuyển từ các trình điều khiển cấp thấp ít được bảo trì hơn
để duy trì tốt hơn lớp cao hơn.  Ngoài ra, vì đường dẫn lỗi init là
được chia sẻ với đường dẫn thoát, cả hai đều có thể nhận được nhiều thử nghiệm hơn.

Tuy nhiên, hãy lưu ý rằng khi chuyển đổi cuộc gọi hoặc nhiệm vụ hiện tại sang
phiên bản devm_* được quản lý, bạn có quyền kiểm tra xem các hoạt động nội bộ có
như phân bổ bộ nhớ, đã thất bại. Các tài nguyên được quản lý liên quan đến
giải phóng các tài nguyên này ZZ0000ZZ - tất cả các kiểm tra cần thiết khác vẫn được thực hiện
vào bạn. Trong một số trường hợp, điều này có thể có nghĩa là đưa ra các séc không được
cần thiết trước khi chuyển sang lệnh gọi devm_* được quản lý.


3. Nhóm Devres
---------------

Các mục Devres có thể được nhóm lại bằng nhóm devres.  Khi một nhóm được
được phát hành, tất cả đều chứa các mục devres bình thường và được lồng đúng cách
các nhóm được thả ra.  Một cách sử dụng là khôi phục hàng loạt dữ liệu đã mua
nguồn lực khi thất bại.  Ví dụ::

nếu (!devres_open_group(dev, NULL, GFP_KERNEL))
	trả về -ENOMEM;

có được A;
  nếu (thất bại)
	nhầm rồi;

có được B;
  nếu (thất bại)
	nhầm rồi;
  ...

devres_remove_group(dev, NULL);
  trả về 0;

lỗi:
  devres_release_group(dev, NULL);
  trả về err_code;

Vì lỗi thu thập tài nguyên thường có nghĩa là lỗi thăm dò, nên các cấu trúc
như trên thường hữu ích trong trình điều khiển lớp giữa (ví dụ: lõi libata
layer) trong đó chức năng giao diện sẽ không có tác dụng phụ khi lỗi.
Đối với LLD, chỉ cần trả về mã lỗi trong hầu hết các trường hợp là đủ.

Mỗi nhóm được xác định bởi ZZ0000ZZ.  Nó có thể được rõ ràng
được chỉ định bởi đối số @id cho devres_open_group() hoặc tự động
được tạo bằng cách chuyển NULL dưới dạng @id như trong ví dụ trên.  Ở cả hai
trường hợp, devres_open_group() trả về id của nhóm.  Id được trả về
có thể được chuyển đến các hàm phát triển khác để chọn nhóm mục tiêu.
Nếu NULL được cấp cho các chức năng đó thì nhóm mở mới nhất là
đã chọn.

Ví dụ: bạn có thể làm một cái gì đó như sau ::

int my_midlayer_create_something()
  {
	if (!devres_open_group(dev, my_midlayer_create_something, GFP_KERNEL))
		trả về -ENOMEM;

	...

devres_close_group(dev, my_midlayer_create_something);
	trả về 0;
  }

void my_midlayer_destroy_something()
  {
	devres_release_group(dev, my_midlayer_create_something);
  }


4. Chi tiết
----------

Thời gian tồn tại của một mục nhập dành cho nhà phát triển bắt đầu từ việc phân bổ và kết thúc dành cho nhà phát triển
khi nó được giải phóng hoặc bị phá hủy (loại bỏ và giải phóng) - không có tài liệu tham khảo
đếm.

lõi devres đảm bảo tính nguyên tử cho tất cả các hoạt động cơ bản của devres và
có hỗ trợ cho các loại nhà phát triển đơn lẻ (nguyên tử
tra cứu và thêm-nếu-không tìm thấy).  Ngoài ra, việc đồng bộ hóa
quyền truy cập đồng thời vào dữ liệu nhà phát triển được phân bổ là của người gọi
trách nhiệm.  Điều này thường không thành vấn đề vì các hoạt động xe buýt và
việc phân bổ nguồn lực đã thực hiện được công việc.

Để biết ví dụ về loại nhà phát triển đơn phiên bản, hãy đọc pcim_iomap_table()
trong lib/devres.c.

Tất cả các hàm giao diện devres có thể được gọi mà không cần ngữ cảnh nếu
mặt nạ gfp bên phải được đưa ra.


5. Chi phí chung
-----------

Thông tin kế toán của mỗi nhà phát triển được phân bổ cùng với dữ liệu được yêu cầu
khu vực.  Khi tắt tùy chọn gỡ lỗi, thông tin sổ sách kế toán chiếm 16
byte trên máy 32bit và 24 byte trên máy 64bit (ba con trỏ được làm tròn
cho đến khi căn chỉnh tối đa).  Nếu sử dụng danh sách liên kết đơn thì có thể
giảm xuống còn hai con trỏ (8 byte trên 32bit, 16 byte trên 64bit).

Mỗi nhóm devres chiếm 8 con trỏ.  Nó có thể giảm xuống còn 6 nếu
danh sách liên kết đơn được sử dụng.

Dung lượng bộ nhớ trên bộ điều khiển ahci có hai cổng nằm trong khoảng 300
và 400 byte trên máy 32bit sau khi chuyển đổi đơn giản (chúng ta có thể
chắc chắn đầu tư thêm một chút công sức vào lớp lõi libata).


6. Danh sách các giao diện được quản lý
-----------------------------

CLOCK
  devm_clk_get()
  devm_clk_get_Optional()
  devm_clk_put()
  devm_clk_bulk_get()
  devm_clk_bulk_get_all()
  devm_clk_bulk_get_Optional()
  devm_get_clk_from_child()
  devm_clk_hw_register()
  devm_of_clk_add_hw_provider()
  devm_clk_hw_register_clkdev()

DMA
  dmaenginem_async_device_register()
  dmam_alloc_coherent()
  dmam_alloc_attrs()
  dmam_free_coherent()
  dmam_pool_create()
  dmam_pool_destroy()

DRM
  devm_drm_dev_alloc()

GPIO
  devm_gpiod_get()
  devm_gpiod_get_array()
  devm_gpiod_get_array_Optional()
  devm_gpiod_get_index()
  devm_gpiod_get_index_Optional()
  devm_gpiod_get_Optional()
  devm_gpiod_put()
  devm_gpiod_unhinge()
  devm_gpiochip_add_data()
  devm_gpio_request_one()

I2C
  devm_i2c_add_adapter()
  devm_i2c_new_dummy_device()

IIO
  devm_iio_device_alloc()
  devm_iio_device_register()
  devm_iio_dmaengine_buffer_setup()
  devm_iio_kfifo_buffer_setup()
  devm_iio_kfifo_buffer_setup_ext()
  devm_iio_map_array_register()
  devm_iio_triggered_buffer_setup()
  devm_iio_triggered_buffer_setup_ext()
  devm_iio_trigger_alloc()
  devm_iio_trigger_register()
  devm_iio_channel_get()
  devm_iio_channel_get_all()
  devm_iio_hw_consumer_alloc()
  devm_fwnode_iio_channel_get_by_name()

INPUT
  devm_input_allocate_device()

vùng IO
  devm_release_mem_khu vực()
  devm_release_zone()
  devm_release_resource()
  devm_request_mem_khu vực()
  devm_request_free_mem_khu vực()
  devm_request_zone()
  devm_request_resource()

IOMAP
  devm_ioport_map()
  devm_ioport_unmap()
  devm_ioremap()
  devm_ioremap_uc()
  devm_ioremap_wc()
  devm_ioremap_resource() : kiểm tra tài nguyên, yêu cầu vùng bộ nhớ, ioremaps
  devm_ioremap_resource_wc()
  devm_platform_ioremap_resource() : gọi devm_ioremap_resource() cho thiết bị nền tảng
  devm_platform_ioremap_resource_byname()
  devm_platform_get_and_ioremap_resource()
  devm_iounmap()

Lưu ý: Đối với các thiết bị PCI, các hàm pcim_*() cụ thể có thể được sử dụng, xem bên dưới.

IRQ
  devm_free_irq()
  devm_request_any_context_irq()
  devm_request_irq()
  devm_request_threaded_irq()
  devm_irq_alloc_descs()
  devm_irq_alloc_desc()
  devm_irq_alloc_desc_at()
  devm_irq_alloc_desc_from()
  devm_irq_alloc_descs_from()
  devm_irq_alloc_generic_chip()
  devm_irq_setup_generic_chip()
  devm_irq_domain_create_sim()

LED
  devm_led_classdev_register()
  devm_led_classdev_register_ext()
  devm_led_classdev_unregister()
  devm_led_trigger_register()
  devm_of_led_get()

MDIO
  devm_mdiobus_alloc()
  devm_mdiobus_alloc_size()
  devm_mdiobus_register()
  devm_of_mdiobus_register()

MEM
  devm_free_pages()
  devm_get_free_pages()
  devm_kasprintf()
  devm_kcalloc()
  devm_kfree()
  devm_kmalloc()
  devm_kmalloc_array()
  devm_kemdup()
  devm_krealloc()
  devm_krealloc_array()
  devm_kstrdup()
  devm_kstrdup_const()
  devm_kvasprintf()
  devm_kzalloc()

MFD
  devm_mfd_add_devices()

MUX
  devm_mux_chip_alloc()
  devm_mux_chip_register()
  devm_mux_control_get()
  devm_mux_state_get()

NET
  devm_alloc_etherdev()
  devm_alloc_etherdev_mqs()
  devm_register_netdev()

PER-CPU MEM
  devm_alloc_percpu()

PCI
  devm_pci_alloc_host_bridge() : quản lý phân bổ cầu nối máy chủ PCI
  devm_pci_remap_cfgspace() : không gian cấu hình ioremap PCI
  devm_pci_remap_cfg_resource() : tài nguyên không gian cấu hình ioremap PCI

pcim_enable_device() : sau khi thành công, thiết bị PCI sẽ tự động bị vô hiệu hóa khi tách trình điều khiển
  pcim_iomap() : thực hiện iomap() trên một BAR
  pcim_iomap_khu vực() : thực hiện request_khu vực() và iomap() trên nhiều BAR
  pcim_iomap_table() : mảng địa chỉ được ánh xạ được lập chỉ mục bởi BAR
  pcim_iounmap() : thực hiện iounmap() trên một BAR
  pcim_pin_device() : duy trì kích hoạt thiết bị PCI sau khi phát hành
  pcim_set_mwi() : kích hoạt giao dịch PCI ghi nhớ không hợp lệ

PHY
  devm_usb_get_phy()
  devm_usb_get_phy_by_node()
  devm_usb_get_phy_by_phandle()

PINCTRL
  devm_pinctrl_get()
  devm_pinctrl_put()
  devm_pinctrl_get_select()
  devm_pinctrl_register()
  devm_pinctrl_register_and_init()

POWER
  devm_reboot_mode_register()
  devm_reboot_mode_unregister()

PWM
  devm_pwmchip_alloc()
  devm_pwmchip_add()
  devm_pwm_get()
  devm_fwnode_pwm_get()

REGULATOR
  devm_regulator_bulk_register_supply_alias()
  devm_regulator_bulk_get()
  devm_regulator_bulk_get_const()
  devm_regulator_bulk_get_enable()
  devm_regulator_bulk_put()
  devm_regulator_get()
  devm_regulator_get_enable()
  devm_regulator_get_enable_read_vol thế()
  devm_regulator_get_enable_Optional()
  devm_regulator_get_exclusive()
  devm_regulator_get_Optional()
  devm_regulator_irq_helper()
  devm_regulator_put()
  devm_regulator_register()
  devm_regulator_register_notifier()
  devm_regulator_register_supply_alias()
  devm_regulator_unregister_notifier()

RESET
  devm_reset_control_get()
  devm_reset_controller_register()

RTC
  devm_rtc_device_register()
  devm_rtc_allocate_device()
  devm_rtc_register_device()
  devm_rtc_nvmem_register()

SERDEV
  devm_serdev_device_open()

SLAVE DMA ENGINE
  devm_acpi_dma_controller_register()

SPI
  devm_spi_alloc_host()
  devm_spi_alloc_target()
  devm_spi_optimize_message()
  devm_spi_register_controller()
  devm_spi_register_host()
  devm_spi_register_target()

WATCHDOG
  devm_watchdog_register_device()

WORKQUEUE
  devm_alloc_workqueue()
  devm_alloc_ordered_workqueue()
