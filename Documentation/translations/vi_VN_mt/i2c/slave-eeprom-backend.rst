.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/slave-eeprom-backend.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Phần phụ trợ I2C phụ trợ EEPROM của Linux
==============================

bởi Wolfram Sang <wsa@sang-engineering.com> vào năm 2014-20

Phần phụ trợ này mô phỏng EEPROM trên bus I2C được kết nối. Nội dung bộ nhớ của nó
có thể được truy cập từ không gian người dùng thông qua tệp này nằm trong sysfs::

/sys/bus/i2c/devices/<device-directory>/slave-eeprom

Có các loại sau: 24c02, 24c32, 24c64 và 24c512. Chỉ đọc
các biến thể cũng được hỗ trợ. Tên cần thiết để khởi tạo có dạng
'nô lệ-<type>[ro]'. Ví dụ sau:

24c02, đọc/ghi, địa chỉ 0x64:
  # echo nô lệ-24c02 0x1064 > /sys/bus/i2c/devices/i2c-1/new_device

24c512, chỉ đọc, địa chỉ 0x42:
  # echo nô lệ-24c512ro 0x1042 > /sys/bus/i2c/devices/i2c-1/new_device

Bạn cũng có thể tải trước dữ liệu trong khi khởi động nếu thuộc tính thiết bị có tên
'tên chương trình cơ sở' chứa tên tệp hợp lệ (chỉ DT hoặc ACPI).

Kể từ năm 2015, Linux không hỗ trợ thăm dò ý kiến trên các tệp sysfs nhị phân, do đó không có
thông báo khi chủ khác thay đổi nội dung.
