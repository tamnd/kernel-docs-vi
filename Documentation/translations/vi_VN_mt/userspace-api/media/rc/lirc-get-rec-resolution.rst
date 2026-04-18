.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-get-rec-resolution.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: RC

.. _lirc_get_rec_resolution:

*****************************
ioctl LIRC_GET_REC_RESOLUTION
*****************************

Tên
====

LIRC_GET_REC_RESOLUTION - Lấy giá trị độ phân giải nhận, tính bằng micro giây.

Tóm tắt
========

.. c:macro:: LIRC_GET_REC_RESOLUTION

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Độ phân giải, tính bằng micro giây.

Sự miêu tả
===========

Một số máy thu có độ phân giải tối đa được xác định bởi nội bộ
tốc độ mẫu hoặc giới hạn định dạng dữ liệu. Ví dụ. chuyện đó là bình thường
tín hiệu chỉ có thể được báo cáo trong các bước 50 micro giây.

Ioctl này trả về giá trị số nguyên với độ phân giải như vậy, có thể là
được sử dụng bởi các ứng dụng không gian người dùng như lircd để tự động điều chỉnh
giá trị dung sai.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.