.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/htu31.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân HTU31
===============================

Chip được hỗ trợ:

* Chuyên ngành đo lường HTU31

Tiền tố: 'htu31'

Địa chỉ được quét: -

Bảng dữ liệu: Có sẵn công khai từ ZZ0000ZZ

Tác giả:

- Andrei Lalaev <andrey.lalaev@gmail.com>

Sự miêu tả
-----------

HTU31 là cảm biến nhiệt độ và độ ẩm.

Phạm vi nhiệt độ được hỗ trợ là từ -40 đến 125 độ C.

Giao tiếp với thiết bị được thực hiện thông qua giao thức I2C. Địa chỉ mặc định của cảm biến
là 0x40.

giao diện sysfs
---------------

======================================
temp1_input: đầu vào nhiệt độ
độ ẩm1_input: đầu vào độ ẩm
heater_enable: điều khiển máy sưởi
======================================