.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/vga-switcheroo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _vga_switcheroo:

=================
Bộ chuyển đổi VGA
=================

.. kernel-doc:: drivers/gpu/vga/vga_switcheroo.c
   :doc: Overview

Phương thức sử dụng
============

Chuyển đổi thủ công và điều khiển nguồn thủ công
-----------------------------------------

.. kernel-doc:: drivers/gpu/vga/vga_switcheroo.c
   :doc: Manual switching and manual power control

Điều khiển công suất điều khiển
--------------------

.. kernel-doc:: drivers/gpu/vga/vga_switcheroo.c
   :doc: Driver power control

API
===

Chức năng công cộng
----------------

.. kernel-doc:: drivers/gpu/vga/vga_switcheroo.c
   :export:

Công trình công cộng
-----------------

.. kernel-doc:: include/linux/vga_switcheroo.h
   :functions: vga_switcheroo_handler

.. kernel-doc:: include/linux/vga_switcheroo.h
   :functions: vga_switcheroo_client_ops

Hằng số công khai
----------------

.. kernel-doc:: include/linux/vga_switcheroo.h
   :functions: vga_switcheroo_handler_flags_t

.. kernel-doc:: include/linux/vga_switcheroo.h
   :functions: vga_switcheroo_client_id

.. kernel-doc:: include/linux/vga_switcheroo.h
   :functions: vga_switcheroo_state

Công trình riêng
------------------

.. kernel-doc:: drivers/gpu/vga/vga_switcheroo.c
   :functions: vgasr_priv

.. kernel-doc:: drivers/gpu/vga/vga_switcheroo.c
   :functions: vga_switcheroo_client

Trình xử lý
========

Trình xử lý apple-gmux
------------------

.. kernel-doc:: drivers/platform/x86/apple-gmux.c
   :doc: Overview

.. kernel-doc:: drivers/platform/x86/apple-gmux.c
   :doc: Interrupt

Đồ họa mux
~~~~~~~~~~~~

.. kernel-doc:: drivers/platform/x86/apple-gmux.c
   :doc: Graphics mux

Kiểm soát quyền lực
~~~~~~~~~~~~~

.. kernel-doc:: drivers/platform/x86/apple-gmux.c
   :doc: Power control

Kiểm soát đèn nền
~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/platform/x86/apple-gmux.c
   :doc: Backlight control

Chức năng công cộng
~~~~~~~~~~~~~~~~

.. kernel-doc:: include/linux/apple-gmux.h
   :internal:
