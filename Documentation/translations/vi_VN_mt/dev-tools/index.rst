.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Công cụ phát triển kernel
================================

Tài liệu này là tập hợp các tài liệu về các công cụ phát triển có thể
được sử dụng để làm việc trên kernel. Hiện tại tài liệu đã được rút ra
với nhau mà không cần bất kỳ nỗ lực đáng kể nào để tích hợp chúng thành một hệ thống mạch lạc
toàn bộ; chào mừng các bản vá lỗi!

Bạn có thể tìm thấy tổng quan ngắn gọn về các công cụ dành riêng cho thử nghiệm trong
Tài liệu/dev-tools/testing-overview.rst

Bạn có thể tìm thấy các công cụ dành riêng cho việc gỡ lỗi trong
Tài liệu/quy trình/gỡ lỗi/index.rst

.. toctree::
   :caption: Table of contents
   :maxdepth: 2

   testing-overview
   checkpatch
   clang-format
   coccinelle
   context-analysis
   sparse
   kcov
   gcov
   kasan
   kmsan
   ubsan
   kmemleak
   kcsan
   lkmm/index
   kfence
   kselftest
   kunit/index
   ktap
   checkuapi
   gpio-sloppy-logic-analyzer
   autofdo
   propeller
   container
