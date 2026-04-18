.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/fs_kfuncs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _fs_kfuncs-header-label:

=======================
Hệ thống tập tin BPF kfuncs
=====================

Các chương trình BPF LSM cần truy cập dữ liệu hệ thống tệp từ các hook LSM. Sau đây
BPF kfuncs có thể được sử dụng để lấy những dữ liệu này.

* ZZ0000ZZ

* ZZ0000ZZ

Để tránh đệ quy, các kfunc này tuân theo các quy tắc sau:

1. Những kfunc này chỉ được phép từ chức năng BPF LSM.
2. Các kfunc này không nên gọi vào các hook LSM khác, tức là security_*(). cho
   ví dụ: ZZ0000ZZ không sử dụng ZZ0001ZZ, bởi vì
   cái sau gọi LSM hook ZZ0002ZZ.