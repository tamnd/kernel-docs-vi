.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-enable-high-lnb-voltage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_ENABLE_HIGH_LNB_VOLTAGE:

*******************************
ioctl FE_ENABLE_HIGH_LNB_VOLTAGE
********************************

Tên
====

FE_ENABLE_HIGH_LNB_VOLTAGE - Chọn mức DC đầu ra giữa điện áp LNBf bình thường hoặc điện áp LNBf cao hơn.

Tóm tắt
========

.. c:macro:: FE_ENABLE_HIGH_LNB_VOLTAGE

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Cờ hợp lệ:

- 0 - bình thường 13V và 18V.

- >0 - cho phép điện áp cao hơn một chút thay vì 13/18V, theo thứ tự
       để bù đắp cho cáp ăng-ten dài.

Sự miêu tả
===========

Chọn mức DC đầu ra giữa điện áp LNBf bình thường hoặc LNBf cao hơn
điện áp trong khoảng 0 (bình thường) hoặc giá trị cao hơn 0 đối với mức cao hơn
điện áp.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.