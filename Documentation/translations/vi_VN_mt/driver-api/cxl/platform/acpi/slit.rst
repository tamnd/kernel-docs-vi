.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/acpi/slit.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
SLIT - Bảng thông tin địa phương hệ thống
============================================

Bảng thông tin vị trí hệ thống cung cấp “khoảng cách trừu tượng” giữa
các nút truy cập và bộ nhớ.  Nút không có bộ khởi tạo (cpus) là vô hạn (FF)
khoảng cách từ tất cả các nút khác.

Khoảng cách trừu tượng được mô tả trong bảng này không mô tả bất kỳ khoảng cách thực tế nào.
độ trễ của thông tin băng thông.

Ví dụ ::

Chữ ký: "SLIT" [Bảng thông tin vị trí hệ thống]
   Địa phương : 0000000000000004
 Địa phương 0 : 10 20 20 30
 Địa phương 1 : 20 10 30 20
 Địa phương 2 : FF FF 0A FF
 Địa phương 3 : FF FF FF 0A