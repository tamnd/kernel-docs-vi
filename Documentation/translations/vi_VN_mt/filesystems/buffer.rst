.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/buffer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Đầu đệm
============

Linux sử dụng các đầu bộ đệm để duy trì trạng thái của các khối hệ thống tập tin riêng lẻ.
Đầu bộ đệm không được dùng nữa và thay vào đó, các hệ thống tệp mới nên sử dụng iomap.

Chức năng
---------

.. kernel-doc:: include/linux/buffer_head.h
.. kernel-doc:: fs/buffer.c
   :export:
