.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/clang-notes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. contents::
.. sectnum::

=============================
Ghi chú triển khai Clang
==========================

Tài liệu này cung cấp thêm chi tiết cụ thể về cách triển khai Clang/LLVM của tập lệnh eBPF.

Phiên bản
========

Clang đã xác định các phiên bản "CPU", trong đó phiên bản CPU gồm 3 tương ứng với eBPF ISA hiện tại.

Clang có thể chọn phiên bản eBPF ISA sử dụng ZZ0000ZZ chẳng hạn để chọn phiên bản 3.

Hướng dẫn số học
=======================

Đối với các phiên bản CPU trước 3, Clang v7.0 trở lên có thể bật hỗ trợ ZZ0000ZZ với
ZZ0001ZZ.  Trong CPU phiên bản 3, hỗ trợ được tự động đưa vào.

Hướng dẫn nhảy
=================

Nếu ZZ0000ZZ được sử dụng, Clang sẽ tạo ZZ0001ZZ (0x8d)
hướng dẫn không được trình xác minh nhân Linux hỗ trợ.

Hoạt động nguyên tử
=================

Clang có thể tạo các hướng dẫn nguyên tử theo mặc định khi ZZ0000ZZ
đã bật. Nếu phiên bản thấp hơn cho ZZ0001ZZ được đặt, lệnh nguyên tử duy nhất
Clang có thể tạo ra là ZZ0002ZZ ZZ0006ZZ ZZ0003ZZ. Nếu bạn cần kích hoạt
các tính năng nguyên tử, trong khi vẫn giữ phiên bản ZZ0004ZZ thấp hơn, bạn có thể sử dụng
ZZ0005ZZ.
