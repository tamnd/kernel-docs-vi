.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-diseqc-recv-slave-reply.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_DISEQC_RECV_SLAVE_REPLY:

********************************
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