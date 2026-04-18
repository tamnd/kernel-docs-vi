.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/ELF.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================
Đặc điểm riêng của ELF dành riêng cho Linux
===========================================

định nghĩa
===========

Tiêu đề chương trình "Đầu tiên" là tiêu đề có độ lệch nhỏ nhất trong tệp:
e_phoff.

Tiêu đề chương trình "Cuối cùng" là tiêu đề có phần bù lớn nhất trong tệp:
e_phoff + (e_phnum - 1) * sizeof(Elf_Phdr).

PT_INTERP
=========

Tiêu đề chương trình PT_INTERP đầu tiên được sử dụng để định vị tên tệp của ELF
thông dịch viên. Các tiêu đề PT_INTERP khác bị bỏ qua (kể từ Linux 2.4.11).

PT_GNU_STACK
============

Tiêu đề chương trình PT_GNU_STACK cuối cùng xác định khả năng thực thi ngăn xếp không gian người dùng
(kể từ Linux 2.6.6). Các tiêu đề PT_GNU_STACK khác bị bỏ qua.

PT_GNU_PROPERTY
===============

Tiêu đề chương trình PT_GNU_PROPERTY cuối cùng của trình thông dịch ELF được sử dụng (vì
Linux 5.8). Nếu trình thông dịch không có thì PT_GNU_PROPERTY cuối cùng
tiêu đề chương trình của tệp thực thi được sử dụng. Các tiêu đề PT_GNU_PROPERTY khác
bị bỏ qua.