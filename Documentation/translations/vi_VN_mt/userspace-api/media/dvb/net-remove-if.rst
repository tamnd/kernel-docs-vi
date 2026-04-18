.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/net-remove-if.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.net

.. _NET_REMOVE_IF:

*******************
ioctl NET_REMOVE_IF
*******************

Tên
====

NET_REMOVE_IF - Loại bỏ giao diện mạng.

Tóm tắt
========

.. c:macro:: NET_REMOVE_IF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    số lượng giao diện cần loại bỏ

Sự miêu tả
===========

NET_REMOVE_IF ioctl xóa giao diện được tạo trước đó thông qua
ZZ0000ZZ.

Giá trị trả về
============

Khi thành công, 0 được trả về và ZZ0000ZZ được điền.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.