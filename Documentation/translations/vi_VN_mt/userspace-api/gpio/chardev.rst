.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/chardev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
GPIO Không gian người dùng thiết bị ký tự API
===================================

Đây là phiên bản mới nhất (v2) của thiết bị ký tự API, như được định nghĩa trong
ZZ0000ZZ

Lần đầu tiên được thêm vào trong 5.10.

.. note::
   Do NOT abuse userspace APIs to control hardware that has proper kernel
   drivers. There may already be a driver for your use case, and an existing
   kernel driver is sure to provide a superior solution to bitbashing
   from userspace.

   Read Documentation/driver-api/gpio/drivers-on-gpio.rst to avoid reinventing
   kernel wheels in userspace.

   Similarly, for multi-function lines there may be other subsystems, such as
   Documentation/spi/index.rst, Documentation/i2c/index.rst,
   Documentation/driver-api/pwm.rst, Documentation/w1/index.rst etc, that
   provide suitable drivers and APIs for your hardware.

Bạn có thể tìm thấy các ví dụ cơ bản sử dụng thiết bị ký tự API trong ZZ0000ZZ.

API dựa trên hai đối tượng chính là ZZ0000ZZ và
ZZ0001ZZ.

.. _gpio-v2-chip:

chip
====

Chip đại diện cho một chip GPIO duy nhất và được hiển thị trong không gian người dùng bằng thiết bị
các tệp có dạng ZZ0000ZZ.

Mỗi chip hỗ trợ một số dòng GPIO,
ZZ0000ZZ. Các dòng trên chip được xác định bởi một
ZZ0001ZZ trong phạm vi từ 0 đến ZZ0002ZZ, tức là ZZ0003ZZ.

Các dòng được yêu cầu từ chip bằng gpio-v2-get-line-ioctl.rst
và yêu cầu dòng kết quả được sử dụng để truy cập vào các dòng của chip GPIO hoặc
theo dõi các dòng cho các sự kiện cạnh.

Trong tài liệu này, bộ mô tả tệp được trả về bằng cách gọi ZZ0001ZZ
trên tệp thiết bị GPIO được gọi là ZZ0000ZZ.

Hoạt động
----------

Các hoạt động sau đây có thể được thực hiện trên chip:

.. toctree::
   :titlesonly:

   Get Line <gpio-v2-get-line-ioctl>
   Get Chip Info <gpio-get-chipinfo-ioctl>
   Get Line Info <gpio-v2-get-lineinfo-ioctl>
   Watch Line Info <gpio-v2-get-lineinfo-watch-ioctl>
   Unwatch Line Info <gpio-get-lineinfo-unwatch-ioctl>
   Read Line Info Changed Events <gpio-v2-lineinfo-changed-read>

.. _gpio-v2-line-request:

Yêu cầu dòng
============

Yêu cầu dòng được tạo bởi gpio-v2-get-line-ioctl.rst và cung cấp
truy cập vào một tập hợp các dòng được yêu cầu.  Yêu cầu dòng được hiển thị với không gian người dùng
thông qua bộ mô tả tệp ẩn danh được trả về trong
ZZ0000ZZ của gpio-v2-get-line-ioctl.rst.

Trong tài liệu này, bộ mô tả tệp yêu cầu dòng được đề cập đến
như ZZ0000ZZ.

Hoạt động
----------

Các hoạt động sau đây có thể được thực hiện trên yêu cầu dòng:

.. toctree::
   :titlesonly:

   Get Line Values <gpio-v2-line-get-values-ioctl>
   Set Line Values <gpio-v2-line-set-values-ioctl>
   Read Line Edge Events <gpio-v2-line-event-read>
   Reconfigure Lines <gpio-v2-line-set-config-ioctl>

Các loại
=====

Phần này chứa các cấu trúc và enum được tham chiếu bởi API v2,
như được định nghĩa trong ZZ0000ZZ.

.. kernel-doc:: include/uapi/linux/gpio.h
   :identifiers:
    gpio_v2_line_attr_id
    gpio_v2_line_attribute
    gpio_v2_line_changed_type
    gpio_v2_line_config
    gpio_v2_line_config_attribute
    gpio_v2_line_event
    gpio_v2_line_event_id
    gpio_v2_line_flag
    gpio_v2_line_info
    gpio_v2_line_info_changed
    gpio_v2_line_request
    gpio_v2_line_values
    gpiochip_info

.. toctree::
   :hidden:

   error-codes