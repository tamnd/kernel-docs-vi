.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-pca-isa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Trình điều khiển hạt nhân i2c-pca-isa
=====================================

Bộ điều hợp được hỗ trợ:

Trình điều khiển này hỗ trợ các bo mạch ISA sử dụng Philips PCA 9564
Bus song song với bộ điều khiển bus I2C

Tác giả: Ian Campbell <icampbell@arcom.com>, Hệ thống điều khiển Arcom

Thông số mô-đun
-----------------

* cơ sở int
    Địa chỉ cơ sở I/O
* irq int
    Ngắt IRQ
* đồng hồ int
    Tốc độ xung nhịp như được mô tả trong bảng 1 của bảng dữ liệu PCA9564

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ các bo mạch ISA sử dụng Philips PCA 9564
Bus song song với bộ điều khiển bus I2C
