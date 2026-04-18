.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/abi-stable.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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