.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/boot-time-mm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Quản lý bộ nhớ thời gian khởi động
==================================

Khởi tạo hệ thống sớm không thể sử dụng quản lý bộ nhớ "bình thường"
đơn giản vì nó chưa được thiết lập. Nhưng vẫn cần phải
cấp phát bộ nhớ cho các cấu trúc dữ liệu khác nhau, ví dụ như cho
bộ cấp phát trang vật lý.

Một bộ cấp phát chuyên dụng có tên ZZ0002ZZ thực hiện
quản lý bộ nhớ thời gian khởi động. Khởi tạo cụ thể của kiến trúc
phải thiết lập nó trong ZZ0000ZZ và phá bỏ nó trong
Chức năng ZZ0001ZZ.

Khi có sẵn tính năng quản lý bộ nhớ sớm, nó sẽ cung cấp nhiều loại
các chức năng và macro để phân bổ bộ nhớ. Yêu cầu phân bổ
có thể được chuyển hướng tới nút đầu tiên (và có thể là nút duy nhất) hoặc tới một nút
nút cụ thể trong hệ thống NUMA. Có những biến thể API gây hoảng sợ
khi phân bổ không thành công và phân bổ không thành công.

Memblock cũng cung cấp nhiều API kiểm soát hành vi của chính nó.

Tổng quan về Memblock
=====================

.. kernel-doc:: mm/memblock.c
   :doc: memblock overview


Chức năng và cấu trúc
========================

Dưới đây là mô tả về cấu trúc, chức năng và cấu trúc dữ liệu memblock
macro. Một số trong số chúng thực sự là nội bộ, nhưng vì chúng
được ghi lại sẽ là ngớ ngẩn nếu bỏ qua chúng. Ngoài ra, việc đọc
mô tả cho các chức năng nội bộ có thể giúp hiểu được những gì
thực sự xảy ra dưới mui xe.

.. kernel-doc:: include/linux/memblock.h
.. kernel-doc:: mm/memblock.c
   :functions:
