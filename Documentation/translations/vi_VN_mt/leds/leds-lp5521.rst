.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-lp5521.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển hạt nhân cho lp5521
========================

* Chip điều khiển led LP5521 bán dẫn quốc gia
* Bảng dữ liệu: ZZ0000ZZ

Tác giả: Mathias Nyman, Yury Zaporozhets, Samu Onkalo

Liên hệ: Samu Onkalo (samu.p.onkalo-at-nokia.com)

Sự miêu tả
-----------

LP5521 có thể điều khiển tối đa 3 kênh. Đèn LED có thể được điều khiển trực tiếp thông qua
giao diện điều khiển lớp dẫn. Các kênh có tên chung:
lp5521:channelx, trong đó x là 0 .. 2

Tất cả ba kênh cũng có thể được điều khiển bằng các chương trình vi mô của động cơ.
Bạn có thể tìm thêm chi tiết về hướng dẫn từ bảng dữ liệu công khai.

LP5521 có bộ nhớ chương trình bên trong để chạy các mẫu LED khác nhau.
Có hai cách để chạy mẫu LED.

1) giao diện sysfs - enginex_mode và enginex_load
   Giao diện điều khiển cho động cơ:

x là 1 .. 3

động cơx_mode:
	bị vô hiệu hóa, tải, chạy
   động cơx_load:
	lưu trữ chương trình (chỉ hiển thị ở chế độ tải động cơ)

Ví dụ (bắt đầu nhấp nháy đèn led kênh 2)::

cd /sys/class/leds/lp5521:channel2/device
	echo "tải"> engine3_mode
	echo "037f4d0003ff6000" > engine3_load
	echo "chạy" > engine3_mode

Để dừng động cơ::

echo "bị vô hiệu hóa" > engine3_mode

2) Giao diện firmware - Giao diện chung LP55xx

Để biết chi tiết, vui lòng tham khảo phần 'firmware' trong leds-lp55xx.txt

sysfs chứa mục tự kiểm tra.

Bài kiểm tra giao tiếp với chip và kiểm tra xem
chế độ đồng hồ được tự động đặt thành chế độ được yêu cầu.

Mỗi kênh có cài đặt dòng điện dẫn riêng.

- /sys/class/leds/lp5521:channel0/led_current - RW
- /sys/class/leds/lp5521:channel0/max_current - RO

Định dạng: 10x mA tức là 10 có nghĩa là 1,0 mA

dữ liệu nền tảng mẫu::

cấu trúc tĩnh lp55xx_led_config lp5521_led_config[] = {
	  {
		.name = "đỏ",
		  .chan_nr = 0,
		  .led_current = 50,
		.max_current = 130,
	  }, {
		.name = "xanh",
		  .chan_nr = 1,
		  .led_current = 0,
		.max_current = 130,
	  }, {
		.name = "màu xanh",
		  .chan_nr = 2,
		  .led_current = 0,
		.max_current = 130,
	  }
  };

int tĩnh lp5521_setup(void)
  {
	/* thiết lập tài nguyên CTNH */
  }

khoảng trống tĩnh lp5521_release(void)
  {
	/* Giải phóng tài nguyên CTNH */
  }

static void lp5521_enable(trạng thái bool)
  {
	/* Điều khiển tín hiệu kích hoạt chip */
  }

cấu trúc tĩnh lp55xx_platform_data lp5521_platform_data = {
	  .led_config = lp5521_led_config,
	  .num_channels = ARRAY_SIZE(lp5521_led_config),
	  .clock_mode = LP55XX_CLOCK_EXT,
	  .setup_resource = lp5521_setup,
	  .release_resource = lp5521_release,
	  .enable = lp5521_enable,
  };

Lưu ý:
  chan_nr có thể có giá trị từ 0 đến 2.
  Tên của mỗi kênh có thể được cấu hình.
  Nếu trường tên không được xác định, tên mặc định sẽ được đặt thành 'xxxx:channelN'
  (XXXX : pdata->label hoặc tên máy khách i2c, N : số kênh)


Nếu dòng điện được đặt thành 0 trong dữ liệu nền tảng thì kênh đó là
bị vô hiệu hóa và nó không hiển thị trong sysfs.
