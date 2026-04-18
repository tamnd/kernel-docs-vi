.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/nzxt-kraken2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân nzxt-kraken2
==========================

Các thiết bị được hỗ trợ:

* NZXT Kraken X42
* NZXT Kraken X52
* NZXT Kraken X62
* NZXT Kraken X72

Tác giả: Jonas Malaco

Sự miêu tả
-----------

Trình điều khiển này cho phép hỗ trợ giám sát phần cứng cho NZXT Kraken X42/X52/X62/X72
bộ làm mát chất lỏng CPU tất cả trong một.  Có sẵn ba cảm biến: tốc độ quạt, bơm
tốc độ và nhiệt độ nước làm mát.

Điều khiển quạt và máy bơm, mặc dù được phần sụn hỗ trợ nhưng hiện không được hỗ trợ
bị lộ.  Đèn LED RGB có thể định địa chỉ, có trong khối nước CPU tích hợp
và đầu bơm cũng không được hỗ trợ.  Nhưng cả hai tính năng có thể được tìm thấy trong
các công cụ không gian người dùng hiện có (ví dụ ZZ0000ZZ).

.. _liquidctl: https://github.com/liquidctl/liquidctl

Ghi chú sử dụng
-----------

Vì đây là các USB HID nên trình điều khiển có thể được tải tự động bởi kernel và
hỗ trợ trao đổi nóng.

Mục nhập hệ thống
-------------

=====================================================================================
fan1_input Tốc độ quạt (tính bằng vòng/phút)
fan2_input Tốc độ bơm (tính bằng vòng/phút)
temp1_input Nhiệt độ nước làm mát (tính bằng mili độ C)
=====================================================================================