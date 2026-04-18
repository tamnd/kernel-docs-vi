.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/abi-stable.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Ký hiệu ổn định ABI
==================

Ghi lại các giao diện mà nhà phát triển đã xác định là ổn định.

Các chương trình không gian người dùng được tự do sử dụng các giao diện này mà không cần
hạn chế và khả năng tương thích ngược cho chúng sẽ được đảm bảo
trong ít nhất 2 năm.

Hầu hết các giao diện (như cuộc gọi chung) được cho là sẽ không bao giờ thay đổi và luôn luôn
sẵn sàng.

.. kernel-abi:: stable
   :no-files: