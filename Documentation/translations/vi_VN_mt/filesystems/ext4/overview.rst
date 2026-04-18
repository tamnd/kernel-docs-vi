.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Thiết kế cấp cao
=================

Hệ thống tệp ext4 được chia thành một loạt các nhóm khối. Để giảm
khó khăn về hiệu suất do bị phân mảnh, bộ cấp phát khối sẽ cố gắng
rất khó để giữ các khối của mỗi tập tin trong cùng một nhóm, do đó
giảm thời gian tìm kiếm. Kích thước của một nhóm khối được chỉ định trong
Khối ZZ0000ZZ, mặc dù nó cũng có thể được tính là 8 *
ZZ0001ZZ. Với kích thước khối mặc định là 4KiB, mỗi nhóm
sẽ chứa 32.768 khối, có chiều dài 128MiB. Số khối
nhóm là kích thước của thiết bị chia cho kích thước của một nhóm khối.

Tất cả các trường trong ext4 được ghi vào đĩa theo thứ tự endian nhỏ. HOWEVER,
tất cả các trường trong jbd2 (tạp chí) được ghi vào đĩa ở dạng big-endian
đặt hàng.

.. toctree::

   blocks
   blockgroup
   special_inodes
   allocators
   checksums
   bigalloc
   inlinedata
   eainode
   verity
   atomic_writes