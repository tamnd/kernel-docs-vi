.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-set-rec-carrier.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: RC

.. _lirc_set_rec_carrier:

**************************
ioctl LIRC_SET_REC_CARRIER
**************************

Tên
====

LIRC_SET_REC_CARRIER - Đặt sóng mang được sử dụng để điều chỉnh nhận IR.

Tóm tắt
========

.. c:macro:: LIRC_SET_REC_CARRIER

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Tần số của sóng mang điều chỉnh dữ liệu PWM, tính bằng Hz.

Sự miêu tả
===========

Đặt sóng mang nhận được sử dụng để điều chỉnh các xung và khoảng trống IR PWM.

.. note::

   If called together with :ref:`LIRC_SET_REC_CARRIER_RANGE`, this ioctl
   sets the upper bound frequency that will be recognized by the device.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.