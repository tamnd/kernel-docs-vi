.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Hệ thống tập tin Ext3
===============

Ext3 ban đầu được phát hành vào tháng 9 năm 1999. Viết bởi Stephen Tweedie
cho nhánh 2.2 và được chuyển sang hạt nhân 2.4 bởi Peter Braam, Andreas Dilger,
Andrew Morton, Alexander Viro, Ted Ts'o và Stephen Tweedie.

Ext3 là hệ thống tập tin ext2 được cải tiến với khả năng ghi nhật ký. các
hệ thống tập tin là tập hợp con của hệ thống tập tin ext4 vì vậy hãy sử dụng trình điều khiển ext4 để truy cập
hệ thống tập tin ext3.
