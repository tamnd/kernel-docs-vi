.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/isdn/m_isdn.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Trình điều khiển mISDN
============

mISDN là trình điều khiển ISDN mô-đun mới, về lâu dài nó sẽ thay thế
kiến trúc trình điều khiển I4L cũ cho thẻ ISDN thụ động.
Nó được thiết kế để cho phép một loạt các ứng dụng và giao diện
nhưng chỉ có chức năng cơ bản trong kernel, giao diện cho người dùng
không gian dựa trên các ổ cắm có họ địa chỉ riêng AF_ISDN.
