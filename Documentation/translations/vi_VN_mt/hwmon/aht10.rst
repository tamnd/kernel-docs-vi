.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/aht10.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân aht10
===============================

Chip được hỗ trợ:

* Aosong AHT10/AHT20

Tiền tố: 'aht10'

Địa chỉ được quét: Không có

Bảng dữ liệu(AHT10):

Tiếng Trung: ZZ0000ZZ
      Tiếng Anh: ZZ0001ZZ

Bảng dữ liệu(AHT20):

Tiếng Anh: ZZ0000ZZ

* Aosong DHT20

Tiền tố: 'dht20'

Địa chỉ được quét: Không có

Bảng dữ liệu: ZZ0000ZZ

Tác giả: Johannes Cornelis Draaijer <jcdra1@gmail.com>


Sự miêu tả
-----------

AHT10/AHT20 là cảm biến nhiệt độ và độ ẩm

Địa chỉ của thiết bị i2c này chỉ có thể là 0x38

Tính năng đặc biệt
------------------

AHT20, DHT20 có hỗ trợ CRC8 bổ sung được gửi dưới dạng byte cuối cùng của cảm biến
các giá trị.

Ghi chú sử dụng
---------------

Trình điều khiển này không thăm dò các thiết bị AHT10/ATH20 vì không có trình điều khiển đáng tin cậy.
cách để xác định xem chip i2c có phải là AHT10/AHT20 hay không. Thiết bị có
được khởi tạo rõ ràng với địa chỉ 0x38. Xem
Documentation/i2c/instantiating-devices.rst để biết chi tiết.

Mục nhập hệ thống
-----------------

================================================================
temp1_input Nhiệt độ đo được tính bằng mili độ C
độ ẩm1_input Độ ẩm đo được bằng %H
update_interval Khoảng thời gian tối thiểu để thăm dò cảm biến,
                tính bằng mili giây. Có thể viết được. Phải ở
                ít nhất là 2000
================================================================