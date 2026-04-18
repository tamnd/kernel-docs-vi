.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-set-voltage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_SET_VOLTAGE:

********************
ioctl FE_SET_VOLTAGE
********************

Tên
====

FE_SET_VOLTAGE - Cho phép cài đặt mức DC gửi tới hệ thống con ăng-ten.

Tóm tắt
========

.. c:macro:: FE_SET_VOLTAGE

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Một giá trị liệt kê số nguyên được mô tả tại ZZ0000ZZ

Sự miêu tả
===========

Ioctl này cho phép đặt mức điện áp DC được gửi qua ăng-ten
cáp sang 13V, 18V hoặc tắt.

Thông thường, hệ thống con ăng-ten vệ tinh yêu cầu TV kỹ thuật số
thiết bị gửi điện áp DC để cấp nguồn cho LNBf. Tùy thuộc vào
Loại LNBf, độ phân cực hoặc tần số trung gian (IF) của
LNBf có thể được điều khiển bằng cấp điện áp. Các thiết bị khác (ví dụ:
những cái triển khai DISEqC và LNBf đa điểm không cần
kiểm soát mức điện áp, với điều kiện là 13V hoặc 18V được gửi tới
cấp nguồn cho LNBf.

.. attention:: if more than one device is connected to the same antenna,
   setting a voltage level may interfere on other devices, as they may lose
   the capability of setting polarization or IF. So, on those cases, setting
   the voltage to SEC_VOLTAGE_OFF while the device is not is used is
   recommended.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.