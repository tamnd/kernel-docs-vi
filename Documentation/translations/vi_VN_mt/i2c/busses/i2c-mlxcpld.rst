.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-mlxcpld.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================
Trình điều khiển i2c-mlxcpld
==================

Tác giả: Michael Shych <michaelsh@mellanox.com>

Đây là logic bộ điều khiển Mellanox I2C, được triển khai trong Lattice CPLD
thiết bị.

Hỗ trợ thiết bị:
 - Chế độ chính.
 - Một xe buýt vật lý.
 - Chế độ bỏ phiếu.

Bộ điều khiển này được trang bị trong các hệ thống Mellanox tiếp theo:
"msx6710", "msx6720", "msb7700", "msn2700", "msx1410", "msn2410", "msb7800",
"msn2740", "msn2100".

Các loại giao dịch tiếp theo được hỗ trợ:
 - Nhận Byte/Khối.
 - Gửi Byte/Khối.
 - Đọc Byte/Khối.
 - Viết Byte/Khối.

Đăng ký:

================ === ==============================================================================
CPBLTY 0x0 - khả năng đăng ký.
			Bit [6:5] - độ dài giao dịch. b01 - 72B được hỗ trợ,
			36B trong trường hợp khác.
			Bit 7 - Hỗ trợ đọc khối SMBus.
CTRL 0x1 - điều khiển reg.
			Đặt lại tất cả các thanh ghi.
HALF_CYC 0x4 - chu kỳ reg.
			Định cấu hình độ rộng của nửa chu kỳ I2C SCL (trong 4 LPC_CLK
			đơn vị).
I2C_HOLD 0x5 - giữ reg.
			OE (cho phép đầu ra) bị trễ bởi giá trị được đặt cho thanh ghi này
			(tính theo đơn vị LPC_CLK)
CMD 0x6 - lệnh reg.
			Bit 0, 0 = ghi, 1 = đọc.
			Bits [7:1] - Địa chỉ 7bit của thiết bị I2C.
			Nó nên được viết cuối cùng vì nó kích hoạt giao dịch I2C.
NUM_DATA 0x7 - quy định kích thước dữ liệu.
			Số byte dữ liệu cần ghi trong giao dịch đọc
NUM_ADDR 0x8 - địa chỉ reg.
			Số byte địa chỉ cần ghi trong giao dịch đọc.
STATUS 0x9 - trạng thái reg.
			Bit 0 - giao dịch hoàn tất.
			Bit 4 - ACK/NACK.
DATAx 0xa - 0x54 - reg reg bộ đệm dữ liệu 68 byte.
			Đối với địa chỉ giao dịch ghi được chỉ định trong bốn byte đầu tiên
			(DATA1 - DATA4), dữ liệu bắt đầu từ DATA4.
			Đối với địa chỉ giao dịch đã đọc được gửi trong một giao dịch riêng biệt và
			được chỉ định trong bốn byte đầu tiên (DATA0 - DATA3). Dữ liệu được đọc
			bắt đầu từ DATA0.
================ === ==============================================================================
