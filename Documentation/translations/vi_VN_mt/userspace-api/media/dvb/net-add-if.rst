.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/net-add-if.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.net

.. _NET_ADD_IF:

****************
ioctl NET_ADD_IF
****************

Tên
====

NET_ADD_IF - Tạo giao diện mạng mới cho ID gói nhất định.

Tóm tắt
========

.. c:macro:: NET_ADD_IF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    con trỏ tới cấu trúc ZZ0000ZZ

Sự miêu tả
===========

Cuộc gọi hệ thống ioctl NET_ADD_IF chọn ID gói (PID)
chứa lưu lượng TCP/IP, loại đóng gói sẽ được sử dụng (MPE hoặc
ULE) và số giao diện cho giao diện mới sẽ được tạo. Khi nào
cuộc gọi hệ thống trở lại thành công, giao diện mạng ảo mới được
được tạo ra.

Trường struct ZZ0000ZZ::ifnum sẽ là
chứa đầy số lượng giao diện đã tạo.

Giá trị trả về
============

Khi thành công, 0 được trả về và ZZ0000ZZ được điền.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.