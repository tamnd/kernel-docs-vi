.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sht21.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân sht21
===================

Chip được hỗ trợ:

* Sensirion SHT20

Tiền tố: 'sht20'

Địa chỉ được quét: không có

Bảng dữ liệu: Có sẵn công khai tại trang web Sensirion

ZZ0000ZZ

* Sensirion SHT21

Tiền tố: 'sht21'

Địa chỉ được quét: không có

Bảng dữ liệu: Có sẵn công khai tại trang web Sensirion

ZZ0000ZZ

* Sensirion SHT25

Tiền tố: 'sht25'

Địa chỉ được quét: không có

Bảng dữ liệu: Có sẵn công khai tại trang web Sensirion

ZZ0000ZZ

Tác giả:

Urs Fleisch <urs.fleisch@sensirion.com>

Sự miêu tả
-----------

SHT21 và SHT25 là các cảm biến độ ẩm và nhiệt độ trong gói DFN
chỉ có kích thước 3 x 3 mm và chiều cao 1,1 mm. Sự khác biệt giữa hai
thiết bị có mức độ chính xác cao hơn của SHT25 (độ ẩm tương đối 1,8%,
0,2 độ C) so với SHT21 (độ ẩm tương đối 2,0%,
0,3 độ C).

Các thiết bị giao tiếp với giao thức I2C. Tất cả các cảm biến được đặt giống nhau
Địa chỉ I2C 0x40, do đó, có thể sử dụng mục nhập có I2C_BOARD_INFO("sht21", 0x40)
trong mã thiết lập bảng.

giao diện sysfs
---------------

=================== ==================================================================
temp1_input Đầu vào nhiệt độ
độ ẩm1_input Đầu vào độ ẩm
eic Mã nhận dạng điện tử
=================== ==================================================================

Ghi chú
-----

Trình điều khiển sử dụng cài đặt độ phân giải mặc định là 12 bit cho độ ẩm và 14
bit cho nhiệt độ, dẫn đến thời gian đo điển hình là 22 ms cho
độ ẩm và 66 ms cho nhiệt độ. Để giữ nhiệt độ tự sưởi ấm dưới 0,1 độ
độ C, thiết bị không nên hoạt động quá 10% thời gian,
ví dụ: tối đa hai phép đo mỗi giây ở độ phân giải nhất định.

Các độ phân giải khác nhau, bộ gia nhiệt trên chip và sử dụng tổng kiểm tra CRC
vẫn chưa được hỗ trợ.
