.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/spi/spi-lm70llp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
spi_lm70llp : Bộ chuyển đổi chuyển đổi LM70-LLP sang SPI
==============================================

Bo mạch/chip được hỗ trợ:

* Hội đồng đánh giá chất bán dẫn quốc gia LM70 LLP

Bảng dữ liệu: ZZ0000ZZ

tác giả:
        Kaiwan N Billimoria <kaiwan@designergraphix.com>

Sự miêu tả
-----------
Trình điều khiển này cung cấp mã keo kết nối Bán dẫn Quốc gia LM70 LLP
bảng đánh giá cảm biến nhiệt độ cho hệ thống con lõi SPI của hạt nhân.

Đây là trình điều khiển bộ điều khiển chính SPI. Nó có thể được sử dụng kết hợp với
(được xếp bên dưới) trình điều khiển logic LM70 ("trình điều khiển giao thức SPI").
Trong thực tế, trình điều khiển này biến giao diện cổng song song trên bảng eval
vào xe buýt SPI bằng một thiết bị duy nhất, thiết bị này sẽ được điều khiển bởi thiết bị chung
Trình điều khiển LM70 (trình điều khiển/hwmon/lm70.c).


Giao diện phần cứng
--------------------
Sơ đồ cho bảng cụ thể này (LM70EVAL-LLP) là
có sẵn (trên trang 4) tại đây:

ZZ0000ZZ

Giao diện phần cứng trên bảng eval LM70 LLP như sau:

======== == ====================
   Song song LM70 LLP
     Cảng .  Tiêu đề định hướng JP2
   ======== == ====================
      D0 2 - -
      D1 3 --> V+ 5
      D2 4 --> V+ 5
      D3 5 --> V+ 5
      D4 6 --> V+ 5
      D5 7 --> nCS 8
      D6 8 --> SCLK 3
      D7 9 --> SI/O 5
     GND 25 - GND 7
    Chọn 13 <-- SI/O 1
   ======== == ====================

Lưu ý rằng do LM70 sử dụng biến thể "3 dây" của SPI nên chân SI/SO
được kết nối với cả hai chân D7 (như Master Out) và Select (như Master In)
bằng cách sử dụng một sự sắp xếp cho phép parport hoặc LM70 kéo
ghim thấp.  Điều này không thể được chia sẻ với các thiết bị SPI thực sự, nhưng các thiết bị 3 dây khác
các thiết bị có thể chia sẻ cùng một chân SI/SO.

Quy trình bitbanger trong trình điều khiển này (lm70_txrx) được gọi lại từ
trình điều khiển giao thức "hwmon/lm70" bị ràng buộc thông qua hook sysfs của nó, sử dụng
cuộc gọi spi_write_then_read().  Nó thực hiện bitbanging Chế độ 0 (SPI/Microwire).
Trình điều khiển lm70 sau đó diễn giải giá trị nhiệt độ kỹ thuật số thu được
và xuất nó thông qua sysfs.

Một "gotcha": Sơ đồ mạch điện tử LM70 LLP của National Semiconductor
cho thấy đường SI/O từ chip LM70 được kết nối với đế của một
bóng bán dẫn Q1 (cũng như một pullup và một diode zener đến D7); trong khi
bộ thu được gắn với VCC.

Giải thích mạch này, khi đường SI/O LM70 ở mức Cao (hoặc tristate
và không được nối đất bởi máy chủ thông qua D7), bóng bán dẫn sẽ dẫn và chuyển mạch
bộ thu về 0, được phản ánh trên chân 13 của cổng DB25
đầu nối.  Khi SI/O ở mức Thấp (được điều khiển bởi LM70 hoặc máy chủ) ở mặt khác
tay, bóng bán dẫn bị cắt và điện áp gắn với bộ thu của nó là
được phản ánh trên chân 13 ở mức Cao.

Vì vậy: quy trình nội tuyến getmiso trong trình điều khiển này có tính đến thực tế này,
đảo ngược giá trị đọc ở chân 13.


Nhờ có
---------

- David Brownell đã hướng dẫn phát triển trình điều khiển bên SPI.
- Dr.Craig Hollabaugh cho phiên bản trình điều khiển bitbanging "thủ công" (sớm).
- Nadir Billimoria đã giúp giải thích sơ đồ mạch điện.
