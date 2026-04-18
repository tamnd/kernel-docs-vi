.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/i2c.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hệ thống con I\ ZZ0000ZZ\ C và SMBus
====================================

I\ ZZ0000ZZ\ C (hoặc không có kiểu chữ hoa mỹ, "I2C") là từ viết tắt của
bus "Inter-IC", một giao thức bus đơn giản được sử dụng rộng rãi ở những nơi có tốc độ thấp
truyền thông tốc độ dữ liệu đủ. Vì đây cũng là nhãn hiệu được cấp phép,
một số nhà cung cấp sử dụng tên khác (chẳng hạn như "Giao diện hai dây", TWI) cho
cùng một xe buýt. I2C chỉ cần hai tín hiệu (SCL cho đồng hồ, SDA cho dữ liệu),
bảo tồn diện tích bo mạch và giảm thiểu các vấn đề về chất lượng tín hiệu. Hầu hết
Thiết bị I2C sử dụng địa chỉ bảy bit và tốc độ bus lên tới 400 kHz;
có phần mở rộng tốc độ cao (3,4 MHz) vẫn chưa được sử dụng rộng rãi.
I2C là bus đa chủ; tín hiệu cống mở được sử dụng để phân xử
giữa các chủ, cũng như bắt tay và đồng bộ hóa đồng hồ từ
khách hàng chậm hơn.

Giao diện lập trình Linux I2C hỗ trợ phía chính của bus
tương tác và phía nô lệ. Giao diện lập trình là
được cấu trúc xung quanh hai loại trình điều khiển và hai loại thiết bị. Một chiếc I2C
"Trình điều khiển bộ điều hợp" tóm tắt phần cứng bộ điều khiển; nó liên kết với một
thiết bị vật lý (có thể là thiết bị PCI hoặc platform_device) và hiển thị một
ZZ0000ZZ đại diện cho mỗi
Đoạn xe buýt I2C do nó quản lý. Trên mỗi đoạn bus I2C sẽ có các thiết bị I2C
được đại diện bởi ZZ0001ZZ.
Những thiết bị đó sẽ được liên kết với ZZ0002ZZ, tuân theo mô hình trình điều khiển Linux tiêu chuẩn. Ở đó
là các chức năng để thực hiện các hoạt động giao thức I2C khác nhau; lúc viết bài này
tất cả các chức năng như vậy chỉ có thể sử dụng được từ ngữ cảnh nhiệm vụ.

Bus quản lý hệ thống (SMBus) là một giao thức anh chị em. Hầu hết SMBus
hệ thống cũng tuân thủ I2C. Các ràng buộc về điện ngày càng chặt chẽ hơn
dành cho SMBus và nó chuẩn hóa các thông điệp và thành ngữ giao thức cụ thể.
Bộ điều khiển hỗ trợ I2C cũng có thể hỗ trợ hầu hết các hoạt động SMBus, nhưng
Bộ điều khiển SMBus không hỗ trợ tất cả các tùy chọn giao thức mà I2C
bộ điều khiển sẽ. Có các chức năng để thực hiện các giao thức SMBus khác nhau
hoạt động, bằng cách sử dụng các nguyên hàm I2C hoặc bằng cách phát lệnh SMBus để
các thiết bị i2c_adapter không hỗ trợ các hoạt động I2C đó.

.. kernel-doc:: include/linux/i2c.h
   :internal:

.. kernel-doc:: drivers/i2c/i2c-boardinfo.c
   :functions: i2c_register_board_info

.. kernel-doc:: drivers/i2c/i2c-core-base.c
   :export:

.. kernel-doc:: drivers/i2c/i2c-core-smbus.c
   :export:
