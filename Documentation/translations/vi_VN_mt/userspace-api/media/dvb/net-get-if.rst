.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/net-get-if.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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