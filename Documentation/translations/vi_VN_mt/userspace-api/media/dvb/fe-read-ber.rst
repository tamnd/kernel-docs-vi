.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-read-ber.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_READ_BER:

*************
FE_READ_BER
***********

Tên
====

FE_READ_BER

.. attention:: This ioctl is deprecated.

Tóm tắt
========

.. c:macro:: FE_READ_BER

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Tỷ lệ lỗi bit được lưu vào \*ber.

Sự miêu tả
===========

Lệnh gọi ioctl này trả về tỷ lệ lỗi bit cho tín hiệu hiện tại
được nhận/giải điều chế bởi giao diện người dùng. Đối với lệnh này, chỉ đọc
truy cập vào thiết bị là đủ.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.