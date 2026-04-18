.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/tty_struct.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
Cấu trúc TTY
==========

.. contents:: :local:

struct tty_struct được phân bổ bởi lớp TTY khi mở TTY lần đầu tiên
thiết bị và được giải phóng sau lần đóng cuối cùng. Lớp TTY vượt qua cấu trúc này
với hầu hết các hook của struct tty_Operation. Các thành viên của tty_struct được ghi lại
trong ZZ0000ZZ ở phía dưới.

Khởi tạo
==============

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_init_termios

Tên
====

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_name

Đếm tham chiếu
==================

.. kernel-doc:: include/linux/tty.h
   :identifiers: tty_kref_get

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_kref_put

Cài đặt
=======

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_standard_install

Đọc & Viết
============

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_put_char

Bắt đầu & Dừng
============

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: start_tty stop_tty

Thức dậy
======

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_wakeup

Cúp máy
======

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_hangup tty_vhangup tty_hung_up_p

linh tinh
====

.. kernel-doc:: drivers/tty/tty_io.c
   :identifiers: tty_do_resize

Cờ cấu trúc TTY
================

.. kernel-doc:: include/linux/tty.h
   :identifiers: tty_struct_flags

Tham khảo cấu trúc TTY
====================

.. kernel-doc:: include/linux/tty.h
   :identifiers: tty_struct