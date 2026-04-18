.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/n_tty.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====
N_TTY
=====

.. contents:: :local:

ZZ0000ZZ mặc định (và dự phòng). Nó cố gắng
xử lý các ký tự theo POSIX.

Chức năng bên ngoài
===================

.. kernel-doc:: drivers/tty/n_tty.c
   :export:

Chức năng nội bộ
==================

.. kernel-doc:: drivers/tty/n_tty.c
   :internal: