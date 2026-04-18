.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-set-send-carrier.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: RC

.. _lirc_set_send_carrier:

****************************
ioctl LIRC_SET_SEND_CARRIER
***************************

Tên
====

LIRC_SET_SEND_CARRIER - Đặt sóng mang gửi được sử dụng để điều chỉnh IR TX.

Tóm tắt
========

.. c:macro:: LIRC_SET_SEND_CARRIER

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Tần số của sóng mang được điều chế, tính bằng Hz.

Sự miêu tả
===========

Đặt sóng mang gửi được sử dụng để điều chỉnh các xung và khoảng trống IR PWM.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.