.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/inode_table.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Bảng Inode
-----------

Các bảng inode được phân bổ tĩnh tại thời điểm mkfs.  Mỗi nhóm khối
bộ mô tả trỏ đến đầu bảng và các bản ghi siêu khối
số lượng nút trên mỗi nhóm.  Xem ZZ0000ZZ
để biết thêm thông tin về cách bố trí bảng inode.