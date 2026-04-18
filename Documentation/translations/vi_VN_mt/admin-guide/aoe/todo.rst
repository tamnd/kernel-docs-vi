.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/aoe/todo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

TODO
====

There is a potential for deadlock when allocating a struct sk_buff for
data that needs to be written out to aoe storage.  If the data is
being written from a dirty page in order to free that page, and if
there are no other pages available, then deadlock may occur when a
free page is needed for the sk_buff allocation.  This situation has
not been observed, but it would be nice to eliminate any potential for
deadlock under memory pressure.

Because ATA over Ethernet is not fragmented by the kernel's IP code,
the destructor member of the struct sk_buff is available to the aoe
driver.  By using a mempool for allocating all but the first few
sk_buffs, and by registering a destructor, we should be able to
efficiently allocate sk_buffs without introducing any potential for
deadlock.
