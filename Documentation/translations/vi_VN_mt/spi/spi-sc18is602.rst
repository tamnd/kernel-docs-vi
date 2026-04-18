.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/spi/spi-sc18is602.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Trình điều khiển hạt nhân spi-sc18is602
===========================

Chip được hỗ trợ:

* NXP SI18IS602/602B/603

Bảng dữ liệu: ZZ0000ZZ

tác giả:
        Guenter Roeck <linux@roeck-us.net>


Sự miêu tả
-----------

Trình điều khiển này cung cấp kết nối xe buýt NXP SC18IS602/603 I2C với cầu SPI với
hệ thống con lõi SPI của kernel.

Trình điều khiển không thăm dò các chip được hỗ trợ vì SI18IS602/603 không
hỗ trợ đăng ký Chip ID. Bạn sẽ phải khởi tạo các thiết bị một cách rõ ràng.
Vui lòng xem Documentation/i2c/instantiating-devices.rst để biết chi tiết.


Ghi chú sử dụng
-----------

Trình điều khiển này yêu cầu trình điều khiển bộ chuyển đổi I2C để hỗ trợ các tin nhắn I2C thô. I2C
trình điều khiển bộ điều hợp chỉ có thể xử lý giao thức SMBus không được hỗ trợ.

Kích thước tin nhắn SPI tối đa được SC18IS602/603 hỗ trợ là 200 byte. Nỗ lực
để bắt đầu chuyển khoản dài hơn sẽ không thành công với -EINVAL. EEPROM đọc hoạt động và
các truy cập lớn tương tự phải được chia thành nhiều phần không quá
200 byte cho mỗi tin nhắn SPI (khuyên dùng 128 byte dữ liệu cho mỗi tin nhắn). Cái này
có nghĩa là các chương trình như "cp" hoặc "od", tự động sử dụng khối lớn
kích thước để truy cập thiết bị, không thể sử dụng trực tiếp để đọc dữ liệu từ EEPROM.
Nên sử dụng các chương trình như dd, nơi có thể chỉ định kích thước khối
thay vào đó.
