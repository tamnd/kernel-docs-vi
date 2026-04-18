.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/net-get-if.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.net

.. _NET_GET_IF:

****************
ioctl NET_GET_IF
****************

Tên
====

NET_GET_IF - Đọc dữ liệu cấu hình của giao diện được tạo thông qua - ZZ0000ZZ.

Tóm tắt
========

.. c:macro:: NET_GET_IF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    con trỏ tới cấu trúc ZZ0000ZZ

Sự miêu tả
===========

NET_GET_IF ioctl sử dụng số giao diện được cung cấp bởi cấu trúc
Trường ZZ0000ZZ::ifnum và điền nội dung của
cấu trúc ZZ0001ZZ với ID gói và
kiểu đóng gói được sử dụng trên giao diện đó. Nếu giao diện không
được tạo bằng ZZ0002ZZ, nó sẽ trả về -1 và điền
ZZ0003ZZ có mã lỗi ZZ0004ZZ.

Giá trị trả về
============

Khi thành công, 0 được trả về và ZZ0000ZZ được điền.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.