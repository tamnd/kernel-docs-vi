.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/page_cache.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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