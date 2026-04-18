.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-diolan-u2c.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
Trình điều khiển hạt nhân i2c-diolan-u2c
============================

Bộ điều hợp được hỗ trợ:
  * Bộ chuyển đổi Diolan U2C-12 I2C-USB

Tài liệu:
	ZZ0000ZZ

Tác giả: Guenter Roeck <linux@roeck-us.net>

Sự miêu tả
-----------

Đây là trình điều khiển cho bộ chuyển đổi Diolan U2C-12 USB-I2C.

Bộ chuyển đổi Diolan U2C-12 I2C-USB cung cấp giải pháp kết nối chi phí thấp
một máy tính đến các thiết bị phụ I2C sử dụng giao diện USB. Nó cũng hỗ trợ
kết nối với các thiết bị SPI.

Trình điều khiển này chỉ hỗ trợ giao diện I2C của U2C-12. Người lái xe không sử dụng
ngắt quãng.


Thông số mô-đun
-----------------

* tần số: tần số xe buýt I2C
