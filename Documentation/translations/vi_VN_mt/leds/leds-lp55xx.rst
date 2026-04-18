.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-lp55xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================
Trình điều khiển chung LP5521/LP5523/LP55231/LP5562/LP8501
=================================================

Tác giả: Milo(Woogyom) Kim <milo.kim@ti.com>

Sự miêu tả
-----------
LP5521, LP5523/55231, LP5562 và LP8501 có các tính năng phổ biến như dưới đây.

Đăng ký quyền truy cập qua I2C
  Khởi tạo/hủy khởi tạo thiết bị
  Tạo thiết bị lớp LED cho nhiều kênh đầu ra
  Thuộc tính thiết bị cho giao diện không gian người dùng
  Bộ nhớ chương trình để chạy các mẫu LED

Trình điều khiển chung LP55xx cung cấp các tính năng này bằng cách sử dụng các hàm được xuất.

lp55xx_init_device() / lp55xx_deinit_device()
  lp55xx_register_leds() / lp55xx_unregister_leds()
  lp55xx_regsister_sysfs() / lp55xx_unregister_sysfs()

(Dữ liệu cấu trúc trình điều khiển)

Trong trình điều khiển chung lp55xx, hai cấu trúc dữ liệu khác nhau được sử dụng.

*lp55xx_led
    điều khiển các kênh LED đa đầu ra như dòng điện led, chỉ số kênh.
*lp55xx_chip
    điều khiển chip chung như I2C và dữ liệu nền tảng.

Ví dụ: LP5521 có tối đa 3 kênh LED.
LP5523/55231 có 9 kênh đầu ra::

lp55xx_chip cho LP5521... lp55xx_led #1
			     lp55xx_led #2
			     lp55xx_led #3

lp55xx_chip cho LP5523... lp55xx_led #1
			     lp55xx_led #2
				   .
				   .
			     lp55xx_led #9

(Mã phụ thuộc chip)

Để hỗ trợ cấu hình cụ thể của thiết bị, cấu trúc đặc biệt
'lpxx_device_config' được sử dụng.

- Số lượng kênh tối đa
  - Lệnh reset, lệnh kích hoạt chip
  - Khởi tạo cụ thể của chip
  - Truy cập đăng ký kiểm soát độ sáng
  - Cài đặt dòng điện đầu ra LED
  - Truy cập địa chỉ bộ nhớ chương trình cho các mẫu đang chạy
  - Thuộc tính cụ thể của thiết bị bổ sung

(Giao diện phần mềm)

Các thiết bị thuộc dòng LP55xx có bộ nhớ chương trình bên trong để chạy
các mẫu LED khác nhau.

Dữ liệu mẫu này được lưu dưới dạng tệp trong vùng đất người dùng hoặc
chuỗi byte hex được ghi vào bộ nhớ thông qua I2C.

Trình điều khiển phổ biến LP55xx hỗ trợ giao diện phần sụn.

Chip LP55xx có ba công cụ chương trình.

Để tải và chạy mẫu, trình tự lập trình như sau.

(1) Chọn số động cơ (1/2/3)
  (2) Thay đổi chế độ để tải
  (3) Ghi dữ liệu mẫu may vào vùng đã chọn
  (4) Thay đổi chế độ để chạy

Trình điều khiển chung LP55xx cung cấp các giao diện đơn giản như dưới đây.

chọn_engine:
	Chọn công cụ nào được sử dụng để chạy chương trình
run_engine:
	Bắt đầu chương trình được tải qua giao diện phần sụn
phần sụn:
	Tải dữ liệu chương trình

Trong trường hợp LP5523, cần thêm một lệnh nữa, 'enginex_leds'.
Nó được sử dụng để chọn (các) đầu ra LED ở mỗi số động cơ.
Để biết thêm chi tiết, vui lòng tham khảo 'leds-lp5523.txt'.

Ví dụ chạy kiểu nhấp nháy ở động cơ #1 của LP5521::

echo 1 > /sys/bus/i2c/devices/xxxx/select_engine
	echo 1 > /sys/class/firmware/lp5521/đang tải
	echo "4000600040FF6000" > /sys/class/firmware/lp5521/data
	echo 0 > /sys/class/firmware/lp5521/đang tải
	echo 1 > /sys/bus/i2c/devices/xxxx/run_engine

Ví dụ chạy kiểu nhấp nháy ở động cơ #3 của LP55231

Hai đèn LED được cấu hình làm kênh đầu ra mẫu::

echo 3 > /sys/bus/i2c/devices/xxxx/select_engine
	echo 1 > /sys/class/firmware/lp55231/đang tải
	echo "9d0740ff7e0040007e00a0010000" > /sys/class/firmware/lp55231/data
	echo 0 > /sys/class/firmware/lp55231/đang tải
	echo "000001100" > /sys/bus/i2c/devices/xxxx/engine3_leds
	echo 1 > /sys/bus/i2c/devices/xxxx/run_engine

Để bắt đầu đồng thời các kiểu nhấp nháy trong động cơ #2 và #3::

cho idx trong 2 3
	làm
	echo $idx > /sys/class/leds/red/device/select_engine
	ngủ 0,1
	echo 1 > /sys/class/firmware/lp5521/đang tải
	echo "4000600040FF6000" > /sys/class/firmware/lp5521/data
	echo 0 > /sys/class/firmware/lp5521/đang tải
	xong
	echo 1 > /sys/class/leds/red/device/run_engine

Đây là một ví dụ khác cho LP5523.

Chuỗi LED đầy đủ được chọn bởi 'engine2_leds'::

echo 2 > /sys/bus/i2c/devices/xxxx/select_engine
	echo 1 > /sys/class/firmware/lp5523/đang tải
	echo "9d80400004ff05ff437f0000" > /sys/class/firmware/lp5523/data
	echo 0 > /sys/class/firmware/lp5523/đang tải
	echo "111111111" > /sys/bus/i2c/devices/xxxx/engine2_leds
	echo 1 > /sys/bus/i2c/devices/xxxx/run_engine

Ngay khi 'tải' được đặt thành 0, cuộc gọi lại đã đăng ký sẽ được gọi.
Bên trong lệnh gọi lại, công cụ đã chọn sẽ được tải và bộ nhớ được cập nhật.
Để chạy mẫu được lập trình, thuộc tính 'run_engine' phải được bật.

Trình tự mẫu của LP8501 tương tự như LP5523.

Tuy nhiên dữ liệu mẫu là cụ thể.

Ví dụ 1) Động cơ 1 được sử dụng::

echo 1 > /sys/bus/i2c/devices/xxxx/select_engine
	echo 1 > /sys/class/firmware/lp8501/đang tải
	echo "9d0140ff7e0040007e00a001c000" > /sys/class/firmware/lp8501/data
	echo 0 > /sys/class/firmware/lp8501/đang tải
	echo 1 > /sys/bus/i2c/devices/xxxx/run_engine

Ví dụ 2) Động cơ 2 và 3 được sử dụng cùng lúc::

echo 2 > /sys/bus/i2c/devices/xxxx/select_engine
	ngủ 1
	echo 1 > /sys/class/firmware/lp8501/đang tải
	echo "9d0140ff7e0040007e00a001c000" > /sys/class/firmware/lp8501/data
	echo 0 > /sys/class/firmware/lp8501/đang tải
	ngủ 1
	echo 3 > /sys/bus/i2c/devices/xxxx/select_engine
	ngủ 1
	echo 1 > /sys/class/firmware/lp8501/đang tải
	echo "9d0340ff7e0040007e00a001c000" > /sys/class/firmware/lp8501/data
	echo 0 > /sys/class/firmware/lp8501/đang tải
	ngủ 1
	echo 1 > /sys/class/leds/d1/device/run_engine

( 'run_engine' và 'firmware_cb' )

Trình tự chạy dữ liệu chương trình là phổ biến.

Nhưng mỗi thiết bị đều có địa chỉ đăng ký cụ thể cho các lệnh.

Để hỗ trợ điều này, 'run_engine' và 'firmware_cb' có thể được cấu hình trong mỗi trình điều khiển.

run_engine:
	Điều khiển động cơ đã chọn
phần vững_cb:
	Chức năng gọi lại sau khi tải firmware đã xong.

Các lệnh cụ thể của chip để tải và cập nhật bộ nhớ chương trình.

(Dữ liệu mẫu được xác định trước)

Nếu không có giao diện phần sụn, trình điều khiển LP55xx sẽ cung cấp một phương pháp khác để
đang tải mẫu LED. Đó là mẫu 'được xác định trước'.

Một mẫu được xác định trước được xác định trong dữ liệu nền tảng và tải nó (hoặc chúng)
thông qua sysfs nếu cần.

Để sử dụng khái niệm mẫu được xác định trước, 'mẫu' và 'num_patterns' phải là
được cấu hình.

Ví dụ về dữ liệu mẫu được xác định trước::

/* mode_1: dữ liệu nhấp nháy */
  const tĩnh u8 mode_1[] = {
		0x40, 0x00, 0x60, 0x00, 0x40, 0xFF, 0x60, 0x00,
		};

/* mode_2: luôn bật */
  const tĩnh u8 mode_2[] = { 0x40, 0xFF, };

cấu trúc lp55xx_predef_pattern board_led_patterns[] = {
	{
		.r = chế độ_1,
		.size_r = ARRAY_SIZE(mode_1),
	},
	{
		.b = chế độ_2,
		.size_b = ARRAY_SIZE(mode_2),
	},
  }

cấu trúc lp55xx_platform_data lp5562_pdata = {
  ...
.patterns = board_led_patterns,
	.num_patterns = ARRAY_SIZE(board_led_patterns),
  };

Sau đó, mode_1 và mode_2 có thể được chạy qua sysfs::

echo 1 > /sys/bus/i2c/devices/xxxx/led_pattern # red nhấp nháy kiểu LED
  echo 2 > /sys/bus/i2c/devices/xxxx/led_pattern # blue LED luôn bật

Để ngừng chạy mẫu::

echo 0 > /sys/bus/i2c/devices/xxxx/led_pattern
