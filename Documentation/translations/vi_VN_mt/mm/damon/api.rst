.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/mm/damon/api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Tham khảo API
==============

Các chương trình không gian hạt nhân có thể sử dụng mọi tính năng của DAMON bằng các API bên dưới.  Tất cả các bạn
cần làm là bao gồm ZZ0000ZZ, nằm ở ZZ0001ZZ của
cây nguồn.

Cấu trúc
==========

.. kernel-doc:: include/linux/damon.h


Chức năng
=========

.. kernel-doc:: mm/damon/core.c