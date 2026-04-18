.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/inode_table.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Bảng Inode
-----------

Các bảng inode được phân bổ tĩnh tại thời điểm mkfs.  Mỗi nhóm khối
bộ mô tả trỏ đến đầu bảng và các bản ghi siêu khối
số lượng nút trên mỗi nhóm.  Xem ZZ0000ZZ
để biết thêm thông tin về cách bố trí bảng inode.