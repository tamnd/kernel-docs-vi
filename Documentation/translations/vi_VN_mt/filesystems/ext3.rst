.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Hệ thống tập tin Ext3
===============

Ext3 ban đầu được phát hành vào tháng 9 năm 1999. Viết bởi Stephen Tweedie
cho nhánh 2.2 và được chuyển sang hạt nhân 2.4 bởi Peter Braam, Andreas Dilger,
Andrew Morton, Alexander Viro, Ted Ts'o và Stephen Tweedie.

Ext3 là hệ thống tập tin ext2 được cải tiến với khả năng ghi nhật ký. các
hệ thống tập tin là tập hợp con của hệ thống tập tin ext4 vì vậy hãy sử dụng trình điều khiển ext4 để truy cập
hệ thống tập tin ext3.
