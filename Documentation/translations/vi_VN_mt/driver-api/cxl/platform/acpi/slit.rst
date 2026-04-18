.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/acpi/slit.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============================================
SLIT - Bảng thông tin địa phương hệ thống
========================================

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