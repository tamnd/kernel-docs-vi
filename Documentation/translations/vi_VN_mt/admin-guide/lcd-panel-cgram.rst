.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/lcd-panel-cgram.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Hỗ trợ cổng song song LCD/Bảng điều khiển bàn phím
==================================================

Một số màn hình LCD cho phép bạn xác định tối đa 8 ký tự, được ánh xạ tới ASCII
ký tự từ 0 đến 7. Mã thoát để xác định ký tự mới là
'\e[LG' theo sau là một chữ số từ 0 đến 7, đại diện cho ký tự
số và tối đa 8 cặp chữ số hex được kết thúc bằng dấu chấm phẩy
(';'). Mỗi cặp chữ số đại diện cho một dòng, mỗi chữ số có 1 bit
pixel được chiếu sáng với LSB ở bên phải. Các dòng được đánh số từ
trên cùng của ký tự xuống dưới cùng. Trên ma trận 5x7, chỉ có 5 số thấp hơn
các bit của 7 byte đầu tiên được sử dụng cho mỗi ký tự. Nếu chuỗi
không đầy đủ, chỉ những dòng hoàn chỉnh mới được xác định lại. Đây là một số
ví dụ::

printf "\e[LG0010101050D1F0C04;"  => 0 = [nhập]
  printf "\e[LG1040E1F0000000000;"  => 1 = [lên]
  printf "\e[LG2000000001F0E0400;"  => 2 = [xuống]
  printf "\e[LG3040E1F001F0E0400;"  => 3 = [lên-xuống]
  printf "\e[LG40002060E1E0E0602;"  => 4 = [trái]
  printf "\e[LG500080C0E0F0E0C08;"  => 5 = [đúng]
  printf "\e[LG60016051516141400;"  => 6 = "IP"

printf "\e[LG00103071F1F070301;"  => loa lớn
  printf "\e[LG00002061E1E060200;"  => loa nhỏ

Willy
