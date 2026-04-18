.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/api/of.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Cây thiết bị (OF) API
======================

Cây thiết bị KUnit API được sử dụng để kiểm tra mã phụ thuộc của cây thiết bị (of_*).

.. kernel-doc:: include/kunit/of.h
   :internal:

.. kernel-doc:: drivers/of/of_kunit_helpers.c
   :export: