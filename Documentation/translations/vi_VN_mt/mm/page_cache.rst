.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/page_cache.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
Bộ đệm trang
==========

Bộ đệm trang là cách chính mà người dùng và phần còn lại của kernel
tương tác với các hệ thống tập tin.  Nó có thể được bỏ qua (ví dụ với O_DIRECT),
nhưng các lần đọc, ghi và mmap bình thường sẽ đi qua bộ đệm trang.

Folios
======

Folio là đơn vị quản lý bộ nhớ trong bộ đệm trang.
Hoạt động