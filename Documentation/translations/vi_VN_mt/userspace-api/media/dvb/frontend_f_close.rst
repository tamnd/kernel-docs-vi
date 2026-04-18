.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/frontend_f_close.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.fe

.. _frontend_f_close:

****************************
Giao diện TV kỹ thuật số đóng()
***************************

Tên
====

fe-close - Đóng thiết bị giao diện người dùng

Tóm tắt
========

.. code-block:: c

    #include <unistd.h>

.. c:function:: int close( int fd )

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

Sự miêu tả
===========

Cuộc gọi hệ thống này sẽ đóng một thiết bị ngoại vi đã mở trước đó. Sau
đóng một thiết bị ngoại vi, phần cứng tương ứng của nó có thể được cấp nguồn
tự động xuống.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.