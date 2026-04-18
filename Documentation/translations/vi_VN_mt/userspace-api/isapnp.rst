.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/isapnp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Hỗ trợ Plug & Play ISA
=======================

Giao diện /proc/isapnp
======================

Giao diện đã bị xóa trong kernel 2.5.53. Xem pnp.rst để biết thêm chi tiết.

Giao diện /proc/bus/isapnp
==========================

Thư mục này cho phép truy cập vào thẻ PnP ISA và các thiết bị logic.
Các tệp thông thường chứa nội dung của các thanh ghi ISA PnP cho
một thiết bị logic.
