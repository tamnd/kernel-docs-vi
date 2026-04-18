.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-func-close.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: MC

.. _media-func-close:

*************
phương tiện đóng()
*************

Tên
====

media-close - Đóng thiết bị đa phương tiện

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

Đóng thiết bị đa phương tiện. Tài nguyên được liên kết với bộ mô tả tệp
được giải thoát. Cấu hình thiết bị không thay đổi.

Giá trị trả về
============

ZZ0000ZZ trả về 0 nếu thành công. Nếu có lỗi, -1 được trả về và
ZZ0001ZZ được đặt phù hợp. Các mã lỗi có thể xảy ra là:

EBADF
    ZZ0000ZZ không phải là bộ mô tả tệp mở hợp lệ.