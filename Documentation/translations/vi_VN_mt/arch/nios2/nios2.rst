.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/nios2/nios2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Linux trên kiến trúc Nios II
=================================

Đây là một bản port của bộ xử lý Linux sang Nios II (nios2).

Để biên dịch cho Nios II, bạn cần có phiên bản GCC có hỗ trợ chung
hệ thống gọi ABI. Vui lòng xem liên kết này để biết thêm thông tin về cách biên dịch và khởi động
phần mềm cho nền tảng Nios II:
ZZ0000ZZ

Để tham khảo, vui lòng xem liên kết sau:
ZZ0000ZZ

Nios II là gì?
================
Nios II là kiến trúc bộ xử lý nhúng 32-bit được thiết kế đặc biệt cho
Họ Altera của FPGA. Để hỗ trợ Linux, Nios II cần được cấu hình
với MMU và kích hoạt hệ số nhân phần cứng.

Nios II ABI
===========
Vui lòng tham khảo chương "Giao diện nhị phân ứng dụng" trong Tài liệu tham khảo bộ xử lý Nios II
Sổ tay.
