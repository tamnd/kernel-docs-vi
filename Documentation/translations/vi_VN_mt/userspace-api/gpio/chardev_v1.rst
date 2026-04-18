.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/chardev_v1.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
GPIO Không gian người dùng thiết bị ký tự API (v1)
==================================================

.. warning::
   This API is obsoleted by chardev.rst (v2).

   New developments should use the v2 API, and existing developments are
   encouraged to migrate as soon as possible, as this API will be removed
   in the future. The v2 API is a functional superset of the v1 API so any
   v1 call can be directly translated to a v2 equivalent.

   This interface will continue to be maintained for the migration period,
   but new features will only be added to the new API.

Lần đầu tiên được thêm vào trong 4.8.

API dựa trên ba đối tượng chính, ZZ0000ZZ,
ZZ0001ZZ và ZZ0002ZZ.

Khi "sự kiện dòng" được sử dụng trong tài liệu này, nó đề cập đến yêu cầu có thể
giám sát một dòng để biết các sự kiện biên chứ không phải bản thân các sự kiện biên.

.. _gpio-v1-chip:

chip
====

Chip đại diện cho một chip GPIO duy nhất và được hiển thị trong không gian người dùng bằng thiết bị
các tệp có dạng ZZ0000ZZ.

Mỗi chip hỗ trợ một số dòng GPIO,
ZZ0000ZZ. Các dòng trên chip được xác định bởi một
ZZ0001ZZ trong phạm vi từ 0 đến ZZ0002ZZ, tức là ZZ0003ZZ.

Các dòng được yêu cầu từ chip bằng cách sử dụng gpio-get-linehandle-ioctl.rst
và bộ điều khiển dòng kết quả được sử dụng để truy cập các dòng của chip GPIO hoặc
gpio-get-lineevent-ioctl.rst và sự kiện dòng kết quả được sử dụng để giám sát
dòng GPIO dành cho các sự kiện biên.

Trong tài liệu này, bộ mô tả tệp được trả về bằng cách gọi ZZ0001ZZ
trên tệp thiết bị GPIO được gọi là ZZ0000ZZ.

Hoạt động
----------

Các hoạt động sau đây có thể được thực hiện trên chip:

.. toctree::
   :titlesonly:

   Nhận xử lý dòng <gpio-get-linehandle-ioctl>
   Nhận sự kiện dòng <gpio-get-lineevent-ioctl>
   Nhận thông tin chip <gpio-get-chipinfo-ioctl>
   Nhận thông tin dòng <gpio-get-lineinfo-ioctl>
   Thông tin dòng xem <gpio-get-lineinfo-watch-ioctl>
   Thông tin dòng bỏ xem <gpio-get-lineinfo-unwatch-ioctl>
   Đọc thông tin dòng Sự kiện đã thay đổi <gpio-lineinfo-changed-read>

.. _gpio-v1-line-handle:

Xử lý dòng
===========

Các điều khiển dòng được tạo bởi gpio-get-linehandle-ioctl.rst và cung cấp
truy cập vào một tập hợp các dòng được yêu cầu.  Tay cầm dòng được hiển thị với không gian người dùng
thông qua bộ mô tả tệp ẩn danh được trả về trong
ZZ0000ZZ bởi gpio-get-linehandle-ioctl.rst.

Trong tài liệu này, bộ mô tả tệp xử lý dòng được đề cập đến
như ZZ0000ZZ.

Hoạt động
----------

Các thao tác sau đây có thể được thực hiện trên bộ điều khiển dòng:

.. toctree::
   :titlesonly:

   Nhận giá trị dòng <gpio-handle-get-line-values-ioctl>
   Đặt giá trị dòng <gpio-handle-set-line-values-ioctl>
   Cấu hình lại dòng <gpio-handle-set-config-ioctl>

.. _gpio-v1-line-event:

Sự kiện dòng
============

Các sự kiện dòng được tạo bởi gpio-get-lineevent-ioctl.rst và cung cấp
truy cập vào một dòng được yêu cầu.  Sự kiện dòng được hiển thị với không gian người dùng
thông qua bộ mô tả tệp ẩn danh được trả về trong
ZZ0000ZZ của gpio-get-lineevent-ioctl.rst.

Trong tài liệu này, bộ mô tả tệp sự kiện dòng được đề cập đến
như ZZ0000ZZ.

Hoạt động
----------

Các thao tác sau có thể được thực hiện trên sự kiện dòng:

.. toctree::
   :titlesonly:

   Nhận giá trị dòng <gpio-handle-get-line-values-ioctl>
   Đọc sự kiện cạnh dòng <gpio-lineevent-data-read>

Các loại
========

Phần này chứa các cấu trúc được tham chiếu bởi ABI v1.

ZZ0000ZZ chung cho ABI v1 và v2.

.. kernel-doc:: include/uapi/linux/gpio.h
   :identifiers:
    gpioevent_data
    gpioevent_request
    gpiohandle_config
    gpiohandle_data
    gpiohandle_request
    gpioline_info
    gpioline_info_changed

.. toctree::
   :hidden:

   error-codes
