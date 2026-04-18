.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/buffer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Đầu đệm
============

Linux sử dụng các đầu bộ đệm để duy trì trạng thái của các khối hệ thống tập tin riêng lẻ.
Đầu bộ đệm không được dùng nữa và thay vào đó, các hệ thống tệp mới nên sử dụng iomap.

Chức năng
---------

.. kernel-doc:: include/linux/buffer_head.h
.. kernel-doc:: fs/buffer.c
   :export:
