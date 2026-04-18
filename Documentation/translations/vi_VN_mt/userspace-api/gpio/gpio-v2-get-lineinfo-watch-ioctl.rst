.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-v2-get-lineinfo-watch-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _GPIO_V2_GET_LINEINFO_WATCH_IOCTL:

********************************
GPIO_V2_GET_LINEINFO_WATCH_IOCTL
********************************

Tên
====

GPIO_V2_GET_LINEINFO_WATCH_IOCTL - Cho phép xem một dòng để biết các thay đổi đối với nó
yêu cầu thông tin trạng thái và cấu hình.

Tóm tắt
========

.. c:macro:: GPIO_V2_GET_LINEINFO_WATCH_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp của thiết bị ký tự GPIO được trả về bởi ZZ0001ZZ.

ZZ0001ZZ
    Cấu trúc ZZ0000ZZ được điền vào, với
    ZZ0002ZZ được đặt để chỉ dòng cần xem

Sự miêu tả
===========

Cho phép xem một dòng để biết các thay đổi về trạng thái yêu cầu và cấu hình của nó
thông tin. Những thay đổi về thông tin dòng bao gồm một dòng được yêu cầu, được phát hành
hoặc được cấu hình lại.

.. note::
    Watching line info is not generally required, and would typically only be
    used by a system monitoring component.

    The line info does NOT include the line value.
    The line must be requested using gpio-v2-get-line-ioctl.rst to access
    its value, and the line request can monitor a line for events using
    gpio-v2-line-event-read.rst.

Theo mặc định, tất cả các dòng đều không được xem khi chip GPIO được mở.

Nhiều dòng có thể được xem đồng thời bằng cách thêm một chiếc đồng hồ cho mỗi dòng.

Khi đồng hồ được đặt, mọi thay đổi đối với thông tin dòng sẽ tạo ra các sự kiện có thể
đọc từ ZZ0000ZZ như được mô tả trong
gpio-v2-lineinfo-changed-read.rst.

Việc thêm đồng hồ vào dòng đã được xem là một lỗi (ZZ0000ZZ).

Đồng hồ dành riêng cho ZZ0000ZZ và độc lập với đồng hồ
trên cùng một chip GPIO được mở bằng lệnh gọi riêng tới ZZ0001ZZ.

Giá trị trả về
============

Khi thành công 0 và ZZ0000ZZ được điền thông tin dòng hiện tại.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.