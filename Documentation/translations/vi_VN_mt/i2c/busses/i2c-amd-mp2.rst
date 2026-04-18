.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-amd-mp2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Trình điều khiển hạt nhân i2c-amd-mp2
=====================================

Bộ điều hợp được hỗ trợ:
  * Giao diện PCIe AMD MP2

Bảng dữ liệu: không có sẵn công khai.

tác giả:
	- Shyam Sundar S K <Shyam-sundar.S-k@amd.com>
	- Nehal Shah <nehal-bakulchandra.shah@amd.com>
	- Elie Morisse <syniurge@gmail.com>

Sự miêu tả
-----------

MP2 là bộ xử lý ARM được lập trình dưới dạng bộ điều khiển I2C và giao tiếp
với máy chủ x86 thông qua PCI.

Nếu bạn thấy một cái gì đó như thế này ::

03:00.7 Bộ điều khiển MP2 I2C: Advanced Micro Devices, Inc. [AMD] Thiết bị 15e6

trong ZZ0000ZZ thì trình điều khiển này là dành cho thiết bị của bạn.
