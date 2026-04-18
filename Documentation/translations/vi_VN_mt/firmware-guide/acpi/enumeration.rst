.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/enumeration.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Bảng liệt kê thiết bị dựa trên ACPI
=============================

ACPI 5 đã giới thiệu một bộ tài nguyên mới (UartTSerialBus, I2cSerialBus,
SpiSerialBus, GpioIo và GpioInt) có thể được sử dụng để liệt kê nô lệ
các thiết bị đằng sau bộ điều khiển bus nối tiếp.

Ngoài ra chúng ta đang bắt đầu thấy các thiết bị ngoại vi được tích hợp trong
SoC/Chipset chỉ xuất hiện trong không gian tên ACPI. Đây thường là những thiết bị
được truy cập thông qua các thanh ghi được ánh xạ bộ nhớ.

Để hỗ trợ điều này và tái sử dụng các trình điều khiển hiện có càng nhiều càng tốt.
có thể chúng tôi quyết định làm như sau:

- Các thiết bị không có tài nguyên kết nối bus được biểu diễn dưới dạng
    các thiết bị nền tảng.

- Các thiết bị đằng sau các bus thực có tài nguyên kết nối
    được biểu diễn dưới dạng struct spi_device hoặc struct i2c_client. Lưu ý
    UART tiêu chuẩn không phải là bus nên không có cấu trúc uart_device,
    mặc dù một số trong số chúng có thể được đại diện bởi struct serdev_device.

Vì cả ACPI và Cây thiết bị đều đại diện cho một cây thiết bị (và
tài nguyên) việc triển khai này tuân theo cách của Cây thiết bị nhiều như
có thể.

Việc triển khai ACPI liệt kê các thiết bị phía sau bus (nền tảng, SPI,
I2C và trong một số trường hợp là UART), tạo ra các thiết bị vật lý và liên kết chúng
vào mã điều khiển ACPI của chúng trong không gian tên ACPI.

Điều này có nghĩa là khi ACPI_HANDLE(dev) trả về không phải NULL thì thiết bị đã bị
được liệt kê từ không gian tên ACPI. Tay cầm này có thể được sử dụng để trích xuất khác
cấu hình dành riêng cho thiết bị. Có một ví dụ về điều này dưới đây.

Hỗ trợ xe buýt nền tảng
====================

Vì chúng ta đang sử dụng các thiết bị nền tảng để đại diện cho các thiết bị không
được kết nối với bất kỳ xe buýt vật lý nào, chúng tôi chỉ cần triển khai trình điều khiển nền tảng
cho thiết bị và thêm ID ACPI được hỗ trợ. Nếu khối IP tương tự này được sử dụng trên
một số nền tảng không phải ACPI khác, trình điều khiển có thể hoạt động tốt hoặc cần
một số thay đổi nhỏ.

Việc thêm hỗ trợ ACPI cho trình điều khiển hiện có sẽ khá tuyệt vời
đơn giản. Đây là ví dụ đơn giản nhất::

const tĩnh struct acpi_device_id mydrv_acpi_match[] = {
		/* ID ACPI ở đây */
		{ }
	};
	MODULE_DEVICE_TABLE(acpi, mydrv_acpi_match);

cấu trúc tĩnh platform_driver my_driver = {
		...
.driver = {
			.acpi_match_table = mydrv_acpi_match,
		},
	};

Nếu trình điều khiển cần thực hiện việc khởi tạo phức tạp hơn như nhận và
định cấu hình GPIO, nó có thể lấy bộ điều khiển ACPI và trích xuất thông tin này
từ các bảng ACPI.

Đối tượng thiết bị ACPI
===================

Nói chung, có hai loại thiết bị trong một hệ thống, trong đó
ACPI được sử dụng làm giao diện giữa phần sụn nền tảng và HĐH: Thiết bị
có thể được phát hiện và liệt kê một cách tự nhiên, thông qua một giao thức được xác định cho
bus cụ thể mà chúng đang sử dụng (ví dụ: không gian cấu hình trong PCI),
không có sự hỗ trợ của phần mềm nền tảng và các thiết bị cần được mô tả
bởi phần sụn nền tảng để chúng có thể được phát hiện.  Tuy nhiên, đối với mọi thiết bị
được biết đến với phần sụn nền tảng, bất kể nó thuộc loại nào,
có thể có một đối tượng thiết bị ACPI tương ứng trong Không gian tên ACPI trong đó
trong trường hợp nhân Linux sẽ tạo một đối tượng struct acpi_device dựa trên nó để
thiết bị đó.

Các đối tượng struct acpi_device đó không bao giờ được sử dụng để liên kết các trình điều khiển với
các thiết bị có thể khám phá được vì chúng được đại diện bởi các loại thiết bị khác
các đối tượng (ví dụ: struct pci_dev cho thiết bị PCI) được liên kết bởi
trình điều khiển thiết bị (đối tượng struct acpi_device tương ứng sau đó được sử dụng làm
một nguồn thông tin bổ sung về cấu hình của thiết bị nhất định).
Hơn nữa, mã liệt kê thiết bị ACPI cốt lõi tạo ra struct platform_device
đối tượng cho phần lớn các thiết bị được phát hiện và liệt kê bằng
sự trợ giúp của phần sụn nền tảng và các đối tượng thiết bị nền tảng đó có thể bị ràng buộc với
bởi trình điều khiển nền tảng tương tự trực tiếp với các thiết bị có thể đếm được
trường hợp.  Do đó, nó không nhất quán về mặt logic và do đó thường không hợp lệ để liên kết
trình điều khiển để cấu trúc các đối tượng acpi_device, bao gồm trình điều khiển cho các thiết bị
được phát hiện với sự trợ giúp của phần sụn nền tảng.

Về mặt lịch sử, trình điều khiển ACPI liên kết trực tiếp với các đối tượng struct acpi_device
đã được triển khai cho một số thiết bị được liệt kê với sự trợ giúp của nền tảng
firmware, nhưng điều này không được khuyến khích cho bất kỳ trình điều khiển mới nào.  Như đã giải thích ở trên,
các đối tượng thiết bị nền tảng được tạo cho các thiết bị đó theo quy tắc (với một vài
ngoại lệ không liên quan ở đây) và do đó nên sử dụng trình điều khiển nền tảng
để xử lý chúng, mặc dù các đối tượng thiết bị ACPI tương ứng là
nguồn thông tin cấu hình thiết bị duy nhất trong trường hợp đó.

Đối với mọi thiết bị có đối tượng struct acpi_device tương ứng, con trỏ
nó được trả về bởi macro ACPI_COMPANION(), do đó luôn có thể
lấy thông tin cấu hình thiết bị được lưu trữ trong đối tượng thiết bị ACPI
cách này.  Theo đó, struct acpi_device có thể được coi là một phần của
giao diện giữa kernel và Không gian tên ACPI, trong khi các đối tượng thiết bị của
các loại khác (ví dụ: struct pci_dev hoặc struct platform_device) được sử dụng
để tương tác với phần còn lại của hệ thống.

Hỗ trợ DMA
===========

Bộ điều khiển DMA được liệt kê qua ACPI phải được đăng ký trong hệ thống để
cung cấp quyền truy cập chung vào tài nguyên của họ. Ví dụ, một người lái xe sẽ
muốn có thể truy cập được vào các thiết bị nô lệ thông qua lệnh gọi API chung
dma_request_chan() phải tự đăng ký ở cuối hàm thăm dò như
cái này::

err = devm_acpi_dma_controller_register(dev, xlate_func, dw);
	/* Xử lý lỗi nếu không phải trường hợp !CONFIG_ACPI */

và triển khai chức năng xlate tùy chỉnh nếu cần (thường là acpi_dma_simple_xlate()
là đủ) để chuyển đổi tài nguyên Cố địnhDMA được cung cấp bởi struct
acpi_dma_spec vào kênh DMA tương ứng. Một đoạn mã cho trường hợp đó
có thể trông giống như::

#ifdef CONFIG_ACPI
	cấu trúc bộ lọc_args {
		/* Cung cấp thông tin cần thiết cho filter_func */
		...
	};

bộ lọc bool tĩnh_func(struct dma_chan *chan, void *param)
	{
		/*Chọn kênh phù hợp*/
		...
	}

cấu trúc tĩnh dma_chan *xlate_func(struct acpi_dma_spec *dma_spec,
			cấu trúc acpi_dma *adma)
	{
		mũ dma_cap_mask_t;
		struct filter_args args;

/* Chuẩn bị đối số cho filter_func */
		...
trả về dma_request_channel(cap, filter_func, &args);
	}
	#else
	cấu trúc tĩnh dma_chan *xlate_func(struct acpi_dma_spec *dma_spec,
			cấu trúc acpi_dma *adma)
	{
		trả lại NULL;
	}
	#endif

dma_request_chan() sẽ gọi xlate_func() cho mỗi bộ điều khiển DMA đã đăng ký.
Trong chức năng xlate, kênh thích hợp phải được chọn dựa trên
thông tin trong struct acpi_dma_spec và các thuộc tính của bộ điều khiển
được cung cấp bởi struct acpi_dma.

Khách hàng phải gọi dma_request_chan() với tham số chuỗi tương ứng
tới một tài nguyên cố định DMA cụ thể. Theo mặc định "tx" có nghĩa là mục nhập đầu tiên của
Mảng tài nguyên Cố địnhDMA, "rx" có nghĩa là mục nhập thứ hai. Bảng dưới đây cho thấy một
bố cục::

Thiết bị (I2C0)
	{
		...
Phương thức (_CRS, 0, Không được tuần tự hóa)
		{
			Tên (DBUF, ResourceTemplate ()
			{
				Đã sửa lỗiDMA (0x0018, 0x0004, Chiều rộng32bit, _Y48)
				Đã sửa lỗiDMA (0x0019, 0x0005, Chiều rộng32bit,)
			})
		...
		}
	}

Vì vậy, Cố địnhDMA với dòng yêu cầu 0x0018 là "tx" và dòng tiếp theo là "rx" trong
ví dụ này

Trong những trường hợp mạnh mẽ, rất tiếc khách hàng cần gọi
trực tiếp acpi_dma_request_slave_chan_by_index() và do đó chọn
tài nguyên Cố địnhDMA cụ thể theo chỉ mục của nó.

Ngắt được đặt tên
================

Các trình điều khiển được liệt kê qua ACPI có thể có tên để ngắt trong bảng ACPI
có thể được sử dụng để lấy số IRQ trong trình điều khiển.

Tên ngắt có thể được liệt kê trong _DSD dưới dạng 'tên ngắt'. Những cái tên
phải được liệt kê dưới dạng một chuỗi các chuỗi sẽ ánh xạ tới Interrupt()
tài nguyên trong bảng ACPI tương ứng với chỉ mục của nó.

Bảng dưới đây cho thấy một ví dụ về cách sử dụng nó::

Thiết bị (DEV0) {
        ...
Tên (_CRS, ResourceTemplate() {
            ...
Ngắt (ResourceConsumer, Level, ActiveHigh, Exclusive) {
                0x20,
                0x24
            }
        })

Tên (_DSD, Gói () {
            ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
            Gói () {
                Gói () { "tên ngắt", Gói () { "mặc định", "cảnh báo" } },
            }
        ...
        })
    }

Tên ngắt 'mặc định' sẽ tương ứng với 0x20 trong Interrupt()
tài nguyên và 'cảnh báo' thành 0x24. Lưu ý rằng chỉ có tài nguyên Interrupt()
được ánh xạ chứ không phải GpioInt() hoặc tương tự.

Trình điều khiển có thể gọi hàm - fwnode_irq_get_byname() bằng fwnode
và ngắt tên làm đối số để lấy số IRQ tương ứng.

Hỗ trợ bus nối tiếp SPI
======================

Các thiết bị phụ phía sau xe buýt SPI có tài nguyên SpiSerialBus được đính kèm với chúng.
Điều này được trích xuất tự động bởi lõi SPI và các thiết bị phụ được
được liệt kê sau khi tài xế xe buýt gọi spi_register_master().

Đây là không gian tên ACPI dành cho nô lệ SPI có thể trông như thế nào::

Thiết bị (EEP0)
	{
		Tên (_ADR, 1)
		Tên (_CID, Gói () {
			"ATML0025",
			"AT25",
		})
		...
Phương thức (_CRS, 0, Không được tuần tự hóa)
		{
			SPISerialBus(1, PolarityLow, FourWireMode, 8,
				Bộ điều khiển được khởi tạo, 1000000, ClockPolarityLow,
				ClockPhaseFirst, "\\_SB.PCI0.SPI1",)
		}
		...

Trình điều khiển thiết bị SPI chỉ cần thêm ID ACPI theo cách tương tự như
trình điều khiển thiết bị nền tảng. Dưới đây là ví dụ về việc chúng tôi thêm hỗ trợ ACPI
đến trình điều khiển eeprom at25 SPI (điều này dành cho đoạn mã ACPI ở trên)::

const tĩnh struct acpi_device_id at25_acpi_match[] = {
		{ "AT25", 0 },
		{ }
	};
	MODULE_DEVICE_TABLE(acpi, at25_acpi_match);

cấu trúc tĩnh spi_driver at25_driver = {
		.driver = {
			...
.acpi_match_table = at25_acpi_match,
		},
	};

Lưu ý rằng trình điều khiển này thực sự cần thêm thông tin như kích thước trang của
eeprom, v.v. Thông tin này có thể được truyền qua phương thức _DSD như::

Thiết bị (EEP0)
	{
		...
Tên (_DSD, Gói ()
		{
			ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
			Gói ()
			{
				Gói () { "size", 1024 },
				Gói () { "pagesize", 32 },
				Gói () { "địa chỉ rộng", 16 },
			}
		})
	}

Sau đó, trình điều khiển at25 SPI có thể nhận cấu hình này bằng cách gọi thuộc tính thiết bị
API trong giai đoạn ->probe() như::

err = device_property_read_u32(dev, "size", &size);
	nếu (err)
		...error handling...

err = device_property_read_u32(dev, "pagesize", &page_size);
	nếu (err)
		...error handling...

err = device_property_read_u32(dev, "address-width", &addr_width);
	nếu (err)
		...error handling...

Hỗ trợ bus nối tiếp I2C
======================

Các nô lệ đằng sau bộ điều khiển bus I2C chỉ cần thêm ID ACPI như
với nền tảng và trình điều khiển SPI. Lõi I2C tự động liệt kê
bất kỳ thiết bị phụ nào phía sau thiết bị điều khiển sau khi bộ chuyển đổi được kết nối
đã đăng ký.

Dưới đây là ví dụ về cách thêm hỗ trợ ACPI vào mpu3050 hiện có
trình điều khiển đầu vào::

cấu trúc const tĩnh acpi_device_id mpu3050_acpi_match[] = {
		{ "MPU3050", 0 },
		{ }
	};
	MODULE_DEVICE_TABLE(acpi, mpu3050_acpi_match);

cấu trúc tĩnh i2c_driver mpu3050_i2c_driver = {
		.driver = {
			.name = "mpu3050",
			.pm = &mpu3050_pm,
			.of_match_table = mpu3050_of_match,
			.acpi_match_table = mpu3050_acpi_match,
		},
		.probe = mpu3050_probe,
		.remove = mpu3050_remove,
		.id_table = mpu3050_ids,
	};
	module_i2c_driver(mpu3050_i2c_driver);

Tham khảo thiết bị PWM
=======================

Đôi khi một thiết bị có thể là người tiêu dùng của kênh PWM. Rõ ràng hệ điều hành muốn
để biết cái nào. Để cung cấp ánh xạ này, thuộc tính đặc biệt đã được
được giới thiệu, tức là::

Thiết bị (DEV)
    {
        Tên (_DSD, Gói ()
        {
            ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
            Gói () {
                Gói () { "tương thích", Gói () { "pwm-led" } },
                Gói () { "nhãn", "đèn báo động" },
                Gói () { "pwms",
                    Gói () {
                        "\\_SB.PCI0.PWM", // <PWM tham chiếu thiết bị>
                        0, // <chỉ số PWM>
                        600000000, // <PWM kỳ>
                        0, // <Cờ PWM>
                    }
                }
            }
        })
        ...
    }

Trong ví dụ trên, trình điều khiển LED dựa trên PWM tham chiếu đến kênh PWM 0
của thiết bị \_SB.PCI0.PWM với cài đặt khoảng thời gian ban đầu bằng 600 ms (lưu ý rằng
giá trị được tính bằng nano giây).

Hỗ trợ GPIO
============

ACPI 5 đã giới thiệu hai tài nguyên mới để mô tả các kết nối GPIO: GpioIo
và GpioInt. Những tài nguyên này có thể được sử dụng để chuyển các số GPIO được sử dụng bởi
thiết bị tới người lái xe. ACPI 5.1 đã mở rộng điều này với _DSD (Thiết bị
Dữ liệu cụ thể) giúp có thể đặt tên GPIO trong số những thứ khác.

Ví dụ::

Thiết bị (DEV)
	{
		Phương thức (_CRS, 0, Không được tuần tự hóa)
		{
			Tên (SBUF, ResourceTemplate()
			{
				// Dùng để bật/tắt nguồn thiết bị
				GpioIo (Độc quyền, PullNone, 0, 0, IoRestrictionOutputOnly,
					"\\_SB.PCI0.GPI0", 0, ResourceConsumer) { 85 }

// Ngắt cho thiết bị
				GpioInt (Edge, ActiveHigh, ExclusiveAndWake, PullNone, 0,
					 "\\_SB.PCI0.GPI0", 0, ResourceConsumer) { 88 }
			}

Trả lại (SBUF)
		}

// ACPI 5.1 _DSD dùng để đặt tên cho GPIO
		Tên (_DSD, Gói ()
		{
			ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
			Gói ()
			{
				Gói () { "power-gpios", Gói () { ^DEV, 0, 0, 0 } },
				Gói () { "irq-gpios", Gói () { ^DEV, 1, 0, 0 } },
			}
		})
		...
	}

Các số GPIO này là số tương đối của bộ điều khiển và đường dẫn "\\_SB.PCI0.GPI0"
chỉ định đường dẫn đến bộ điều khiển. Để sử dụng các GPIO này trong Linux
chúng ta cần dịch chúng sang các bộ mô tả Linux GPIO tương ứng.

Có một GPIO API tiêu chuẩn cho điều đó và nó được ghi lại trong
Tài liệu/admin-guide/gpio/.

Trong ví dụ trên, chúng ta có thể nhận được hai bộ mô tả GPIO tương ứng với
một mã như thế này::

#include <linux/gpio/consumer.h>
	...

cấu trúc gpio_desc *irq_desc, *power_desc;

irq_desc = gpiod_get(dev, "irq");
	nếu (IS_ERR(irq_desc))
		/*xử lý lỗi */

power_desc = gpiod_get(dev, "power");
	nếu (IS_ERR(power_desc))
		/*xử lý lỗi */

/* Bây giờ chúng ta có thể sử dụng bộ mô tả GPIO */

Ngoài ra còn có phiên bản devm_* của các hàm này phát hành
mô tả sau khi thiết bị được phát hành.

Xem Tài liệu/firmware-guide/acpi/gpio-properties.rst để biết thêm thông tin
về ràng buộc _DSD liên quan đến GPIO.

Hỗ trợ RS-485
==============

ACPI _DSD (Dữ liệu cụ thể của thiết bị) có thể được sử dụng để mô tả khả năng RS-485
của UART.

Ví dụ::

Thiết bị (DEV)
	{
		...

// ACPI 5.1 _DSD được sử dụng cho khả năng RS-485
		Tên (_DSD, Gói ()
		{
			ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
			Gói ()
			{
				Gói () {"rs485-rts-active-low", Zero},
				Gói () {"rs485-rx-active-high", Zero},
				Gói () {"rs485-rx-during-tx", Zero},
			}
		})
		...

Thiết bị MFD
===========

Các thiết bị MFD đăng ký các thiết bị con của chúng làm thiết bị nền tảng. Đối với đứa trẻ
các thiết bị cần phải có bộ điều khiển ACPI để chúng có thể sử dụng để tham khảo
các phần của không gian tên ACPI có liên quan đến chúng. Trong hệ thống con Linux MFD
chúng tôi cung cấp hai cách:

- Con cái dùng chung tay cầm ACPI của cha mẹ.
  - Ô MFD có thể chỉ định id ACPI của thiết bị.

Đối với trường hợp đầu tiên, trình điều khiển MFD không cần phải làm gì cả. các
thiết bị nền tảng con kết quả sẽ có ACPI_COMPANION() được đặt thành điểm
tới thiết bị mẹ.

Nếu không gian tên ACPI có một thiết bị mà chúng tôi có thể so khớp bằng id ACPI hoặc ACPI
adr, ô phải được đặt như sau::

cấu trúc tĩnh mfd_cell_acpi_match my_subdevice_cell_acpi_match = {
		.pnpid = "XYZ0001",
		.adr = 0,
	};

cấu trúc tĩnh mfd_cell my_subdevice_cell = {
		.name = "my_subdevice",
		/* thiết lập các tài nguyên tương ứng với tài nguyên gốc */
		.acpi_match = &my_subdevice_cell_acpi_match,
	};

Id ACPI "XYZ0001" sau đó được sử dụng để tra cứu thiết bị ACPI ngay bên dưới
thiết bị MFD và nếu được tìm thấy, thiết bị đồng hành ACPI đó sẽ được liên kết với
kết quả là thiết bị nền tảng con.

ID thiết bị liên kết không gian tên cây thiết bị
====================================

Giao thức Cây thiết bị sử dụng nhận dạng thiết bị dựa trên "tương thích"
thuộc tính có giá trị là một chuỗi hoặc một mảng chuỗi được nhận dạng là thiết bị
định danh của trình điều khiển và lõi trình điều khiển.  Tập hợp tất cả các chuỗi đó có thể là
được coi là không gian tên nhận dạng thiết bị tương tự như thiết bị ACPI/PNP
Không gian tên ID.  Do đó, về nguyên tắc không cần thiết phải phân bổ
ID thiết bị ACPI/PNP mới (và được cho là dư thừa) cho các thiết bị có mã hiện có
chuỗi nhận dạng trong không gian tên Cây thiết bị (DT), đặc biệt nếu ID đó
chỉ cần thiết để chỉ ra rằng một thiết bị nhất định tương thích với một thiết bị khác,
có lẽ đã có trình điều khiển phù hợp trong kernel rồi.

Trong ACPI, đối tượng nhận dạng thiết bị có tên _CID (ID tương thích) được sử dụng để
liệt kê ID của các thiết bị mà thiết bị đó tương thích, nhưng những ID đó phải
thuộc về một trong các không gian tên được quy định bởi đặc tả ACPI (xem
Phần 6.1.2 của ACPI 6.0 để biết chi tiết) và không gian tên DT không phải là một trong số đó.
Hơn nữa, thông số kỹ thuật yêu cầu mã nhận dạng _HID hoặc _ADR
đối tượng có mặt cho tất cả các đối tượng ACPI đại diện cho thiết bị (Phần 6.1 của ACPI
6.0).  Đối với các loại bus không thể đếm được, đối tượng đó phải là _HID và giá trị của nó phải
cũng là ID thiết bị từ một trong các không gian tên được quy định bởi thông số kỹ thuật.

ID thiết bị liên kết không gian tên DT đặc biệt, PRP0001, cung cấp phương tiện để sử dụng
nhận dạng thiết bị tương thích DT hiện có trong ACPI và để đáp ứng các yêu cầu trên
các yêu cầu tuân theo đặc tả ACPI cùng một lúc.  Cụ thể là,
nếu PRP0001 được _HID trả về, hệ thống con ACPI sẽ tìm kiếm
thuộc tính "tương thích" trong _DSD của đối tượng thiết bị và sẽ sử dụng giá trị của thuộc tính đó
thuộc tính để nhận dạng thiết bị tương ứng tương tự với DT gốc
thuật toán nhận dạng thiết bị.  Nếu thuộc tính "tương thích" không có
hoặc giá trị của nó không hợp lệ, thiết bị sẽ không được ACPI liệt kê
hệ thống con.  Nếu không, nó sẽ được liệt kê tự động dưới dạng thiết bị nền tảng
(trừ khi có liên kết I2C hoặc SPI từ thiết bị tới thiết bị mẹ của nó, trong
trong trường hợp đó, lõi ACPI sẽ để lại việc liệt kê thiết bị cho thiết bị gốc
driver) và các chuỗi nhận dạng từ giá trị thuộc tính "tương thích" sẽ
được sử dụng để tìm trình điều khiển cho thiết bị cùng với ID thiết bị được liệt kê bởi _CID
(nếu có).

Tương tự, nếu PRP0001 có trong danh sách ID thiết bị được _CID trả về,
các chuỗi nhận dạng được liệt kê theo giá trị thuộc tính "tương thích" (nếu có
và hợp lệ) sẽ được sử dụng để tìm kiếm trình điều khiển phù hợp với thiết bị, nhưng trong đó
trường hợp mức độ ưu tiên tương đối của chúng đối với các ID thiết bị khác được liệt kê bởi
_HID và _CID phụ thuộc vào vị trí của PRP0001 trong gói hoàn trả _CID.
Cụ thể, ID thiết bị được trả về bởi _HID và PRP0001 trước đó trong _CID
gói trả lại sẽ được kiểm tra đầu tiên.  Cũng trong trường hợp đó, loại xe buýt thiết bị
sẽ được liệt kê tùy thuộc vào ID thiết bị được trả về bởi _HID.

Ví dụ: mẫu ACPI sau đây có thể được sử dụng để liệt kê loại lm75
Cảm biến nhiệt độ I2C và khớp nó với trình điều khiển bằng Cây thiết bị
liên kết không gian tên::

Thiết bị (TMP0)
	{
		Tên (_HID, "PRP0001")
		Tên (_DSD, Gói () {
			ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
			Gói () {
				Gói () { "tương thích", "ti,tmp75" },
			}
		})
		Phương thức (_CRS, 0, được tuần tự hóa)
		{
			Tên (SBUF, ResourceTemplate ()
			{
				I2cSerialBusV2 (0x48, Bộ điều khiển được khởi tạo,
					400000, Địa chỉMode7Bit,
					"\\_SB.PCI0.I2C1", 0x00,
					ResourceConsumer, , Độc quyền,)
			})
			Trả lại (SBUF)
		}
	}

Việc xác định các đối tượng thiết bị có _HID trả về PRP0001 và không có
thuộc tính "tương thích" trong _DSD hoặc _CID miễn là một trong các thuộc tính đó
tổ tiên cung cấp cho _DSD một thuộc tính "tương thích" hợp lệ.  Thiết bị như vậy
các đối tượng sau đó được coi đơn giản là các "khối" bổ sung cung cấp khả năng phân cấp
thông tin cấu hình tới trình điều khiển của thiết bị tổ tiên tổng hợp.

Tuy nhiên, PRP0001 chỉ có thể được trả lại từ _HID hoặc _CID của thiết bị
đối tượng nếu tất cả các thuộc tính được trả về bởi _DSD được liên kết với nó (hoặc
_DSD của chính đối tượng thiết bị hoặc _DSD của tổ tiên của nó trong
trường hợp "thiết bị tổng hợp" được mô tả ở trên) có thể được sử dụng trong môi trường ACPI.
Mặt khác, bản thân _DSD được coi là không hợp lệ và do đó "tương thích"
tài sản được nó trả lại là vô nghĩa.

Tham khảo Tài liệu/firmware-guide/acpi/DSD-properties-rules.rst để biết thêm
thông tin.

Biểu diễn phân cấp PCI
============================

Đôi khi có thể hữu ích khi liệt kê một thiết bị PCI, biết vị trí của nó trên
xe buýt PCI.

Ví dụ: một số hệ thống sử dụng thiết bị PCI được hàn trực tiếp trên bo mạch chủ,
ở một vị trí cố định (ethernet, Wi-Fi, cổng nối tiếp, v.v.). Trong điều kiện này nó
có thể tham khảo các thiết bị PCI này để biết vị trí của chúng trên bus PCI
cấu trúc liên kết.

Để xác định thiết bị PCI, cần có mô tả phân cấp đầy đủ, từ
cổng gốc của chipset tới thiết bị cuối cùng, thông qua tất cả các cổng trung gian
cầu/công tắc của bảng.

Ví dụ: giả sử chúng ta có một hệ thống có cổng nối tiếp PCIe, một
Exar XR17V3521, được hàn trên bo mạch chính. Chip UART này cũng bao gồm
16 GPIO và chúng tôi muốn thêm thuộc tính ZZ0000ZZ [1]_ vào các chân này.
Trong trường hợp này, đầu ra ZZ0001ZZ cho thành phần này là::

07:00.0 Bộ điều khiển nối tiếp: Exar Corp. XR17V3521 Dual PCIe UART (rev 03)

Đầu ra ZZ0000ZZ hoàn chỉnh (được giảm độ dài theo cách thủ công) là::

00:00.0 Cầu nối máy chủ: Tập đoàn Intel... Cầu nối máy chủ (rev 0d)
	...
00:13.0 Cầu PCI: Tập đoàn Intel... PCI Express Port A #1 (rev fd)
	00:13.1 Cầu PCI: Tập đoàn Intel... PCI Express Port A #2 (rev fd)
	00:13.2 Cầu PCI: Tập đoàn Intel... PCI Express Port A #3 (rev fd)
	00:14.0 Cầu PCI: Intel Corp... PCI Express Port B #1 (rev fd)
	00:14.1 Cầu PCI: Intel Corp... PCI Express Port B #2 (rev fd)
	...
05:00.0 Cầu PCI: Thiết bị bán dẫn Pericom 2404 (rev 05)
	06:01.0 Cầu PCI: Thiết bị bán dẫn Pericom 2404 (rev 05)
	06:02.0 Cầu PCI: Thiết bị bán dẫn Pericom 2404 (rev 05)
	06:03.0 Cầu PCI: Thiết bị bán dẫn Pericom 2404 (rev 05)
	07:00.0 Bộ điều khiển nối tiếp: Exar Corp. XR17V3521 Dual PCIe UART (rev 03) <- Exar
	...

Cấu trúc liên kết xe buýt là::

-[0000:00]-+-00.0
	           ...
+-13.0-[01]----00.0
	           +-13.1-[02]----00.0
	           +-13.2-[03]--
	           +-14.0-[04]----00.0
	           +-14.1-[05-09]----00.0-[06-09]--+-01.0-[07]----00.0 <-- Exar
	           |                               +-02.0-[08]----00.0
	           |                               \-03.0-[09]--
	           ...
\-1f.1

Để mô tả thiết bị Exar này trên bus PCI, chúng ta phải bắt đầu từ tên ACPI
của cầu chipset (còn gọi là "cổng gốc") có địa chỉ::

Bus: 0 - Thiết bị: 14 - Chức năng: 1

Để tìm được thông tin này, cần phải tháo rời các bảng BIOS ACPI,
đặc biệt là DSDT (xem thêm [2]_)::

mkdir ~/tables/
	cd ~/bảng/
	acpidump > acpidump
	acpixtract -a acpidump
	iasl -e ssdt?.* -d dsdt.dat

Bây giờ, trong dsdt.dsl, chúng ta phải tìm kiếm thiết bị có địa chỉ liên quan đến
0x14 (thiết bị) và 0x01 (chức năng). Trong trường hợp này chúng ta có thể tìm thấy những điều sau đây
thiết bị::

Phạm vi (_SB.PCI0)
	{
	... other definitions follow ...
		Device (RP02)
		{
			Method (_ADR, 0, NotSerialized)  // _ADR: Address
			{
				If ((RPA2 != Zero))
				{
					Return (RPA2) /* \RPA2 */
				}
				Else
				{
					Return (0x00140001)
				}
			}
	... other definitions follow ...

và phương thức _ADR [3]_ trả về chính xác cặp thiết bị/chức năng
chúng tôi đang tìm kiếm. Với thông tin này và phân tích ZZ0000ZZ ở trên
đầu ra (cả danh sách thiết bị và cây thiết bị), chúng ta có thể viết như sau
Mô tả ACPI cho Exar PCIe UART, đồng thời bổ sung thêm danh sách dòng GPIO của nó
tên::

Phạm vi (_SB.PCI0.RP02)
	{
		Thiết bị (BRG1) //Cầu nối
		{
			Tên (_ADR, 0x0000)

Thiết bị (BRG2) //Cầu nối
			{
				Tên (_ADR, 0x00010000)

Thiết bị (EXAR)
				{
					Tên (_ADR, 0x0000)

Tên (_DSD, Gói ()
					{
						ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
						Gói ()
						{
							Gói ()
							{
								"tên dòng gpio",
								Gói ()
								{
									"chế độ_232",
									"chế độ_422",
									"chế độ_485",
									"linh tinh_1",
									"linh tinh_2",
									"linh tinh_3",
									"",
									"",
									"phụ_1",
									"phụ_2",
									"phụ_3",
								}
							}
						}
					})
				}
			}
		}
	}

Vị trí "_SB.PCI0.RP02" có được nhờ điều tra ở trên trong
bảng dsdt.dsl, trong khi tên thiết bị "BRG1", "BRG2" và "EXAR" là
đã tạo phân tích vị trí của Exar UART trong cấu trúc liên kết bus PCI.

Tài liệu tham khảo
==========

.. [1] Documentation/firmware-guide/acpi/gpio-properties.rst

.. [2] Documentation/admin-guide/acpi/initrd_table_override.rst

.. [3] ACPI Specifications, Version 6.3 - Paragraph 6.1.1 _ADR Address)
    https://uefi.org/sites/default/files/resources/ACPI_6_3_May16.pdf,
    referenced 2020-11-18