.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/splice.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
mối nối và đường ống
====================

mối nối API
==========

mối nối là một phương pháp để di chuyển các khối dữ liệu xung quanh bên trong kernel,
mà không liên tục chuyển chúng giữa kernel và không gian người dùng.

.. kernel-doc:: fs/splice.c

ống API
=========

Tất cả các giao diện ống đều được sử dụng trong kernel (hình ảnh dựng sẵn). Họ không phải
được xuất để sử dụng bởi các mô-đun.

.. kernel-doc:: include/linux/pipe_fs_i.h
   :internal:

.. kernel-doc:: fs/pipe.c
