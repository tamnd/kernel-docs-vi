.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-diseqc-recv-slave-reply.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_DISEQC_RECV_SLAVE_REPLY:

*******************************
ioctl FE_DISEQC_RECV_SLAVE_REPLY
********************************

Tên
====

FE_DISEQC_RECV_SLAVE_REPLY - Nhận phản hồi từ lệnh DiSEqC 2.0

Tóm tắt
========

.. c:macro:: FE_DISEQC_RECV_SLAVE_REPLY

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Nhận phản hồi từ lệnh DiSEqC 2.0.

Tin nhắn nhận được được lưu trữ tại bộ đệm được chỉ định bởi ZZ0000ZZ.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.