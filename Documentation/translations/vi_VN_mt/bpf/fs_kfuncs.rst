.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/fs_kfuncs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _fs_kfuncs-header-label:

===========================
Hệ thống tập tin BPF kfuncs
===========================

Các chương trình BPF LSM cần truy cập dữ liệu hệ thống tệp từ các hook LSM. Sau đây
BPF kfuncs có thể được sử dụng để lấy những dữ liệu này.

* ZZ0000ZZ

* ZZ0000ZZ

Để tránh đệ quy, các kfunc này tuân theo các quy tắc sau:

1. Những kfunc này chỉ được phép từ chức năng BPF LSM.
2. Các kfunc này không nên gọi vào các hook LSM khác, tức là security_*(). cho
   ví dụ: ZZ0000ZZ không sử dụng ZZ0001ZZ, bởi vì
   cái sau gọi LSM hook ZZ0002ZZ.