.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/input.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hệ thống con đầu vào
====================

Lõi đầu vào
-----------

.. kernel-doc:: include/linux/input.h
   :internal:

.. kernel-doc:: drivers/input/input.c
   :export:

.. kernel-doc:: drivers/input/ff-core.c
   :export:

.. kernel-doc:: drivers/input/ff-memless.c
   :export:

Thư viện cảm ứng đa điểm
------------------------

.. kernel-doc:: include/linux/input/mt.h
   :internal:

.. kernel-doc:: drivers/input/input-mt.c
   :export:

Bàn phím/bàn phím ma trận
-------------------------

.. kernel-doc:: include/linux/input/matrix_keypad.h
   :internal:

Hỗ trợ sơ đồ bàn phím thưa thớt
-------------------------------

.. kernel-doc:: include/linux/input/sparse-keymap.h
   :internal:

.. kernel-doc:: drivers/input/sparse-keymap.c
   :export:

Hỗ trợ giao thức PS/2
---------------------
.. kernel-doc:: include/linux/libps2.h
   :internal:

.. kernel-doc:: drivers/input/serio/libps2.c
   :export:
