.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/spi/butterfly.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================================
spi_butterfly - trình điều khiển bộ chuyển đổi parport-to-butterfly
===================================================================

Đây là một dự án phần cứng và phần mềm bao gồm việc xây dựng và sử dụng
cáp bộ chuyển đổi cổng song song, cùng với "AVR Butterfly" để chạy
chương trình cơ sở để giao tiếp với người dùng và/hoặc cảm biến.  Một con bướm có giá $US20
thẻ chạy bằng pin với bộ vi điều khiển AVR và rất nhiều tính năng hấp dẫn:
cảm biến, LCD, đèn flash, thanh chuyển đổi, v.v.  Bạn có thể sử dụng AVR-GCC để
phát triển chương trình cơ sở cho việc này và flash nó bằng cáp bộ chuyển đổi này.

Bạn có thể tạo bộ chuyển đổi này từ cáp máy in cũ và hàn các thứ
trực tiếp đến Bướm.  Hoặc (nếu bạn có đủ năng lực và kỹ năng) bạn
có thể nghĩ ra thứ gì đó thú vị hơn, cung cấp khả năng bảo vệ mạch điện cho
Butterfly và cổng máy in, hoặc với nguồn điện tốt hơn hai
các chân tín hiệu từ cổng máy in.  Hoặc đối với vấn đề đó, bạn có thể sử dụng
các loại cáp tương tự để giao tiếp với nhiều bảng AVR, thậm chí cả bảng mạch bánh mì.

Cáp này mạnh hơn cáp "lập trình ISP" vì nó cho phép kernel
Trình điều khiển giao thức SPI tương tác với AVR và thậm chí có thể cho phép AVR
đưa ra các ngắt cho họ.  Sau này, trình điều khiển giao thức của bạn sẽ hoạt động
dễ dàng với "bộ điều khiển SPI thực sự", thay vì bitbanger này.


Các kết nối cáp đầu tiên sẽ kết nối Linux với một bus SPI, với
AVR và chip DataFlash; và đến dòng đặt lại AVR.  Đây là tất cả bạn
cần phải khởi động lại chương trình cơ sở và các chân là Atmel tiêu chuẩn "ISP"
các chân kết nối (cũng được sử dụng trên các bo mạch AVR không phải Butterfly).  Trên sân bay
bên này giống như cáp lập trình "sp12".

====== ===================================
	Sân bay tín hiệu bướm (DB-25)
	====== ===================================
	SCK J403.PB1/SCK chân 2/D0
	Chân RESET J403.nRST 3/D1
	VCC J403.VCC_EXT chân 8/D6
	MOSI J403.PB2/MOSI chân 9/D7
	MISO J403.PB3/MISO chân 11/S7,nBUSY
	GND J403.GND chân 23/GND
	====== ===================================

Sau đó, để Linux làm chủ bus đó để giao tiếp với chip DataFlash, bạn phải
(a) flash chương trình cơ sở mới để vô hiệu hóa SPI (đặt PRR.2 và vô hiệu hóa pullups
bằng cách xóa PORTB.[0-3]); (b) định cấu hình trình điều khiển mtd_dataflash; và
(c) cáp trong chipselect.

=======================================
	Sân bay tín hiệu bướm (DB-25)
	=======================================
	VCC J400.VCC_EXT chân 7/D5
	SELECT J400.PB0/nSS chân 17/C3,nSELECT
	GND J400.GND chân 24/GND
	=======================================

Hoặc bạn có thể flash firmware biến AVR thành SPI nô lệ (giữ nguyên
DataFlash trong quá trình thiết lập lại) và điều chỉnh trình điều khiển spi_butterfly để liên kết với
trình điều khiển cho giao thức dựa trên SPI tùy chỉnh của bạn.

Bộ điều khiển "USI", sử dụng J405, cũng có thể được sử dụng cho bus SPI thứ hai.
Điều đó sẽ cho phép bạn nói chuyện với AVR bằng chương trình cơ sở SPI-with-USI tùy chỉnh,
trong khi cho phép Linux hoặc AVR sử dụng DataFlash.  Có rất nhiều
của các chân parport dự phòng để nối dây này lên, chẳng hạn như:

====== ===================================
	Sân bay tín hiệu bướm (DB-25)
	====== ===================================
	SCK J403.PE4/USCK chân 5/D3
	MOSI J403.PE5/DI chân 6/D4
	MISO J403.PE6/DO chân 12/S5,nPAPEROUT
	GND J403.GND chân 22/GND

IRQ J402.PF4 chân 10/S6,ACK
	Chân GND J402.GND(P2) 25/GND
	====== ===================================
