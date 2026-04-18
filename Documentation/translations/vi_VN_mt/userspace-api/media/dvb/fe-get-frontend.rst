.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-get-frontend.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_GET_FRONTEND:

****************
FE_GET_FRONTEND
***************

Tên
====

FE_GET_FRONTEND

.. attention:: This ioctl is deprecated.

Tóm tắt
========

.. c:macro:: FE_GET_FRONTEND

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Trỏ tới các tham số cho hoạt động điều chỉnh.

Sự miêu tả
===========

Cuộc gọi ioctl này truy vấn các tham số giao diện người dùng hiện có hiệu lực. cho
lệnh này, quyền truy cập chỉ đọc vào thiết bị là đủ.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  .. row 1

       -  ``EINVAL``

       -  Maximum supported symbol rate reached.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.