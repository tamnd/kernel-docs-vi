.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-diseqc-send-burst.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_DISEQC_SEND_BURST:

**************************
ioctl FE_DISEQC_SEND_BURST
**************************

Tên
====

FE_DISEQC_SEND_BURST - Gửi chùm âm thanh 22KHz để lựa chọn vệ tinh DiSEqC mini 2x1.

Tóm tắt
========

.. c:macro:: FE_DISEQC_SEND_BURST

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Một giá trị liệt kê số nguyên được mô tả tại ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này được sử dụng để thiết lập việc tạo ra xung âm 22kHz cho mini
Lựa chọn vệ tinh DiSEqC cho thiết bị chuyển mạch 2x1. Cuộc gọi này yêu cầu
quyền đọc/ghi.

Nó cung cấp hỗ trợ cho những gì được chỉ định tại
ZZ0000ZZ

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.