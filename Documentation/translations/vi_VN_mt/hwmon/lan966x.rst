.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/lan966x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân lan966x-hwmon
===========================

Chip được hỗ trợ:

* Microchip LAN9668 (cảm biến trong SoC)

Tiền tố: 'lan9668-hwmon'

Bảng dữ liệu: ZZ0000ZZ

tác giả:

Michael Walle <michael@walle.cc>

Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ cho chip Microchip LAN9668 trên chip
cảm biến nhiệt độ cũng như bộ điều khiển quạt của nó. Nó cung cấp một
cảm biến nhiệt độ và một bộ điều khiển quạt. Phạm vi nhiệt độ
của cảm biến được chỉ định từ -40 đến +125 độ C và
độ chính xác của nó là +/- 5 độ C. Bộ điều khiển quạt có
đầu vào tacho và đầu ra PWM với đầu ra PWM có thể tùy chỉnh
tần số dao động từ ~ 20Hz đến ~ 650kHz.

Không có cảnh báo nào được SoC hỗ trợ.

Trình điều khiển xuất các giá trị nhiệt độ, đầu vào tốc độ quạt và PWM
cài đặt thông qua các tệp sysfs sau:

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ