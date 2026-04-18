.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-diseqc-send-master-cmd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_DISEQC_SEND_MASTER_CMD:

*******************************
ioctl FE_DISEQC_SEND_MASTER_CMD
*******************************

Tên
====

FE_DISEQC_SEND_MASTER_CMD - Gửi lệnh DiSEqC

Tóm tắt
========

.. c:macro:: FE_DISEQC_SEND_MASTER_CMD

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    con trỏ tới cấu trúc
    ZZ0000ZZ

Sự miêu tả
===========

Gửi lệnh DiSEqC được trỏ bởi ZZ0000ZZ
tới hệ thống con anten.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.
