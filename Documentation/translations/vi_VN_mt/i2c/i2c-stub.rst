.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/i2c-stub.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========
sơ khai i2c
========

Sự miêu tả
===========

Mô-đun này là trình điều khiển I2C/SMBus giả rất đơn giản.  Nó thực hiện sáu
các loại lệnh SMBus: ghi nhanh, (r/w) byte, (r/w) byte data, (r/w)
dữ liệu từ, (r/w) dữ liệu khối I2C và (r/w) dữ liệu khối SMBus.

Bạn cần cung cấp địa chỉ chip làm tham số mô-đun khi tải cái này
trình điều khiển, sau đó sẽ chỉ phản ứng với các lệnh SMBus tới các địa chỉ này.

Không cần phần cứng cũng như không liên quan đến mô-đun này.  Nó sẽ chấp nhận viết
lệnh nhanh đến các địa chỉ được chỉ định; nó sẽ phản hồi lại cái kia
lệnh (cũng tới các địa chỉ được chỉ định) bằng cách đọc từ hoặc ghi vào
mảng trong bộ nhớ.  Nó cũng sẽ spam nhật ký kernel cho mỗi lệnh nó
tay cầm.

Một thanh ghi con trỏ có khả năng tăng tự động được triển khai cho tất cả byte
hoạt động.  Điều này cho phép đọc byte liên tục giống như được hỗ trợ bởi
EEPROM, trong số những thứ khác.

Hỗ trợ lệnh chặn SMBus bị tắt theo mặc định và phải được bật
rõ ràng bằng cách đặt các bit tương ứng (0x03000000) trong chức năng
tham số mô-đun.

Các lệnh khối SMBus phải được viết để cấu hình lệnh SMBus cho
Hoạt động khối SMBus. Viết có thể là một phần. Chặn lệnh đọc luôn
trả về số byte được chọn với số lần ghi lớn nhất cho đến nay.

Trường hợp sử dụng điển hình là như thế này:

1. tải mô-đun này
	2. sử dụng i2cset (từ dự án i2c-tools) để tải trước một số dữ liệu
	3. tải mô-đun trình điều khiển chip mục tiêu
	4. quan sát hành vi của nó trong nhật ký kernel

Có một tập lệnh có tên i2c-stub-from-dump trong gói i2c-tools.
có thể tự động tải các giá trị đăng ký từ kết xuất chip.

Thông số
==========

int chip_addr[10]:
	Các địa chỉ SMBus để mô phỏng chip tại.

chức năng dài không dấu:
	Ghi đè chức năng, để vô hiệu hóa một số lệnh. Xem I2C_FUNC_*
	các hằng số trong <linux/i2c.h> để có các giá trị phù hợp. Ví dụ,
	giá trị 0x1f0000 sẽ chỉ kích hoạt dữ liệu nhanh, byte và byte
	lệnh.

u8 Bank_reg[10], u8 Bank_mask[10], u8 Bank_start[10], u8 Bank_end[10]:
	Cài đặt ngân hàng tùy chọn. Họ cho biết bit nào trong thanh ghi nào
	chọn ngân hàng đang hoạt động, cũng như phạm vi của các thanh ghi được ngân hàng.

Hãy cẩn thận
=======

Nếu trình điều khiển mục tiêu của bạn thăm dò một số byte hoặc từ đang chờ nó thay đổi,
sơ khai có thể khóa nó lại.  Sử dụng i2cset để mở khóa.

Nếu bạn spam nó đủ mạnh, printk có thể bị mất.  Mô-đun này thực sự muốn
một cái gì đó giống như chuyển tiếp.
