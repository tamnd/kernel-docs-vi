.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/parser.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Trình phân tích cú pháp chung
=============================

Tổng quan
========

Trình phân tích cú pháp chung là một trình phân tích cú pháp đơn giản để phân tích các tùy chọn gắn kết,
tùy chọn hệ thống tập tin, tùy chọn trình điều khiển, tùy chọn hệ thống con, v.v.

Trình phân tích cú pháp API
==========

.. kernel-doc:: lib/parser.c
   :export: