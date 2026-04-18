.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/wmi/devices/wmi-bmof.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Trình điều khiển MOF nhị phân nhúng WMI
==============================

Giới thiệu
============

Nhiều máy nhúng siêu dữ liệu WMI nhị phân MOF (Định dạng đối tượng được quản lý) được sử dụng để
mô tả chi tiết về giao diện ACPI WMI của họ. Dữ liệu có thể được giải mã
bằng các công cụ như ZZ0000ZZ để có được
Mô tả giao diện WMI mà con người có thể đọc được, rất hữu ích cho việc phát triển
trình điều khiển WMI mới.

Dữ liệu MOF nhị phân có thể được lấy từ thuộc tính sysfs ZZ0000ZZ của
thiết bị WMI liên quan. Xin lưu ý rằng nhiều thiết bị WMI chứa hệ nhị phân
Dữ liệu MOF có thể tồn tại trên một hệ thống nhất định.

Giao diện WMI
=============

Thiết bị MOF WMI nhị phân được xác định bởi WMI GUID ZZ0000ZZ.
Có thể lấy được MOF nhị phân bằng cách thực hiện truy vấn khối dữ liệu WMI. Kết quả là
sau đó được trả về dưới dạng bộ đệm ACPI với kích thước thay đổi.