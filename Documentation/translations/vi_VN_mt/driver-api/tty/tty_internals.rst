.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/tty_internals.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Bộ phận bên trong TTY
=============

.. contents:: :local:

Kopen
=====

Các hàm này dùng để mở TTY từ không gian kernel:

.. kernel-doc:: drivers/tty/tty_io.c
      :identifiers: tty_kopen_exclusive tty_kopen_shared tty_kclose

----

Các hàm nội bộ đã xuất
===========================

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_release_struct tty_dev_name_to_number tty_get_icount

----

Chức năng nội bộ
==================

.. kernel-doc:: drivers/tty/tty_io.c
   :internal: