.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/80211/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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
