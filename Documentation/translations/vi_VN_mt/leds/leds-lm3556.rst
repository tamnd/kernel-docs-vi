.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-lm3556.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Trình điều khiển hạt nhân cho lm3556
========================

* Nhạc cụ Texas:
  1.5 Trình điều khiển Flash LED tăng cường đồng bộ với nguồn hiện tại phía cao
* Bảng dữ liệu: ZZ0000ZZ

tác giả:
      - Daniel Jeong

Liên hệ: Daniel Jeong(daniel.jeong-at-ti.com, gshark.jeong-at-gmail.com)

Sự miêu tả
-----------
Có 3 chức năng trong LM3556, Flash, Torch và Indicator.

Chế độ đèn nháy
^^^^^^^^^^

Ở Chế độ Flash, nguồn dòng LED (LED) cung cấp 16 mức dòng mục tiêu
từ 93,75 mA đến 1500 mA. Dòng điện Flash được điều chỉnh thông qua CURRENT
CONTROL REGISTER(0x09).Chế độ flash được kích hoạt bởi ENABLE REGISTER(0x0A),
hoặc bằng cách kéo chốt STROBE HIGH.

LM3556 Flash có thể được điều khiển thông qua tệp /sys/class/leds/flash/brightness

* nếu chân STROBE được bật, ví dụ bên dưới chỉ kiểm soát độ sáng và
  ON/OFF sẽ được điều khiển bởi chân STROBE.

Ví dụ về đèn flash:

OFF::

#echo 0 > /sys/class/leds/flash/độ sáng

93,75 mA::

#echo 1 > /sys/class/leds/flash/độ sáng

...

1500 mA::

#echo 16 > /sys/class/leds/flash/độ sáng

Chế độ đèn pin
^^^^^^^^^^

Ở Chế độ đèn pin, nguồn hiện tại (LED) được lập trình thông qua CURRENT CONTROL
REGISTER(0x09).Chế độ đèn pin được kích hoạt bởi ENABLE REGISTER(0x0A) hoặc bởi
đầu vào phần cứng TORCH.

Đèn pin LM3556 có thể được điều khiển thông qua tệp /sys/class/leds/torch/brightness.
* nếu chân TORCH được bật, ví dụ bên dưới chỉ kiểm soát độ sáng,
và ON/OFF sẽ được điều khiển bởi chân TORCH.

Ví dụ về ngọn đuốc:

OFF::

#echo 0 > /sys/class/leds/đèn pin/độ sáng

46,88 mA::

#echo 1 > /sys/class/leds/đèn pin/độ sáng

...

375 mA::

#echo 8 > /sys/class/leds/đèn pin/độ sáng

Chế độ chỉ báo
^^^^^^^^^^^^^^

Mẫu chỉ báo có thể được đặt thông qua tệp /sys/class/leds/indicator/pattern,
và 4 mẫu được xác định trước trong mảng Indicator_pattern.

Theo các giá trị N-lank, Thời gian xung và Khoảng thời gian N, mẫu khác nhau sẽ
được tạo. Nếu bạn muốn các mẫu mới cho thiết bị của mình, hãy thay đổi
mảng Indicator_pattern với các giá trị của riêng bạn và INDIC_PATTERN_SIZE.

Vui lòng tham khảo bảng dữ liệu để biết thêm chi tiết về N-Blank, Thời gian xung và Chu kỳ N.

Ví dụ về mẫu chỉ báo:

mẫu 0::

#echo 0 > /sys/class/leds/chỉ báo/mẫu

...

mẫu 3::

#echo 3 > /sys/class/leds/chỉ báo/mẫu

Độ sáng của đèn báo có thể được kiểm soát thông qua
sys/class/leds/chỉ báo/độ sáng.

Ví dụ:

OFF::

#echo 0 > /sys/class/leds/chỉ báo/độ sáng

5,86 mA::

#echo 1 > /sys/class/leds/chỉ báo/độ sáng

...

46,875mA::

#echo 8 > /sys/class/leds/chỉ báo/độ sáng

Ghi chú
-----
Trình điều khiển hy vọng nó được đăng ký bằng cơ chế i2c_board_info.
Để đăng ký chip tại địa chỉ 0x63 trên bộ điều hợp cụ thể, hãy đặt dữ liệu nền tảng
theo include/linux/platform_data/leds-lm3556.h, đặt thông tin bảng i2c

Ví dụ::

cấu trúc tĩnh i2c_board_info board_i2c_ch4[] __initdata = {
		{
			 I2C_BOARD_INFO(LM3556_NAME, 0x63),
			 .platform_data = &lm3556_pdata,
		 },
	};

và đăng ký nó trong hàm khởi tạo nền tảng

Ví dụ::

board_register_i2c_bus(4, 400,
				board_i2c_ch4, ARRAY_SIZE(board_i2c_ch4));
