.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-lp3944.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Trình điều khiển hạt nhân lp3944
====================

* Chip ánh sáng vui nhộn LP3944 bán dẫn quốc gia

Tiền tố: 'lp3944'

Địa chỉ được quét: Không có (xem phần Ghi chú bên dưới)

Bảng dữ liệu:

Có sẵn công khai tại trang web National Semiconductor
	ZZ0000ZZ

tác giả:
	Antonio Ospite <ospite@studenti.unina.it>


Sự miêu tả
-----------
LP3944 là một con chip trợ giúp có thể điều khiển tới 8 đèn led, với hai đèn LED có thể lập trình được.
Chế độ DIM; nó thậm chí có thể được sử dụng như một thiết bị mở rộng gpio nhưng trình điều khiển này thừa nhận nó
được sử dụng làm bộ điều khiển led.

Các chế độ DIM được sử dụng để đặt các mẫu _blink_ cho đèn led, mẫu này là
được chỉ định cung cấp hai tham số:

- kỳ:
	từ 0 giây đến 1,6 giây
  - chu kỳ nhiệm vụ:
	phần trăm thời gian đèn led bật, từ 0 đến 100

Đặt đèn led ở chế độ DIM0 hoặc DIM1 sẽ làm cho đèn led nhấp nháy theo mẫu.
Xem bảng dữ liệu để biết chi tiết.

LP3944 có thể được tìm thấy trên điện thoại thông minh Motorola A910, nơi nó điều khiển rgb
đèn led, đèn flash của máy ảnh và nguồn màn hình LCD.


Ghi chú
-----
Con chip này được sử dụng chủ yếu trong các bối cảnh nhúng, vì vậy trình điều khiển này mong đợi nó
đã đăng ký bằng cơ chế i2c_board_info.

Để đăng ký chip tại địa chỉ 0x60 trên bộ chuyển đổi 0, hãy đặt dữ liệu nền tảng
theo include/linux/leds-lp3944.h, đặt thông tin bảng i2c ::

cấu trúc tĩnh i2c_board_info a910_i2c_board_info[] __initdata = {
		{
			I2C_BOARD_INFO("lp3944", 0x60),
			.platform_data = &a910_lp3944_leds,
		},
	};

và đăng ký nó trong hàm khởi tạo nền tảng::

i2c_register_board_info(0, a910_i2c_board_info,
			ARRAY_SIZE(a910_i2c_board_info));
