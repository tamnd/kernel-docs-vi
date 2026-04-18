.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-pca-isa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển hạt nhân i2c-pca-isa
=========================

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
