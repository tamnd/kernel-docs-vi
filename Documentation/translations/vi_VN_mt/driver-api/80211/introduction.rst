.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/80211/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Giới thiệu
============

Giải thích mạng không dây 802.11 trong nhân Linux

Bản quyền 2007-2009 Johannes Berg

Những cuốn sách này cố gắng đưa ra một mô tả về các hệ thống con khác nhau
đóng vai trò trong mạng không dây 802.11 trong Linux. Vì những điều này
sách dành cho các nhà phát triển hạt nhân, họ cố gắng ghi lại
cấu trúc và chức năng được sử dụng trong kernel cũng như đưa ra một
tổng quan ở cấp độ cao hơn.

Người đọc có thể đã quen thuộc với chuẩn 802.11 như
được IEEE xuất bản vào năm 802.11-2007 (hoặc có thể là các phiên bản mới hơn).
Các tham chiếu đến tiêu chuẩn này sẽ được đưa ra là "802.11-2007 8.1.5".
