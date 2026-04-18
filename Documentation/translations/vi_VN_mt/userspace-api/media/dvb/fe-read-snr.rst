.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-read-snr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_READ_SNR:

*************
FE_READ_SNR
***********

Tên
====

FE_READ_SNR

.. attention:: This ioctl is deprecated.

Tóm tắt
========

.. c:macro:: FE_READ_SNR

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Tỷ lệ tín hiệu trên nhiễu được lưu vào \*snr.

Sự miêu tả
===========

Lệnh gọi ioctl này trả về tỷ lệ tín hiệu trên tạp âm cho tín hiệu
hiện được nhận bởi giao diện người dùng. Đối với lệnh này, quyền truy cập chỉ đọc
vào thiết bị là đủ.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.