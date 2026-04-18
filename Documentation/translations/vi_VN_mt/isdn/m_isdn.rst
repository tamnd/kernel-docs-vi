.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/isdn/m_isdn.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Trình điều khiển mISDN
============

mISDN là trình điều khiển ISDN mô-đun mới, về lâu dài nó sẽ thay thế
kiến trúc trình điều khiển I4L cũ cho thẻ ISDN thụ động.
Nó được thiết kế để cho phép một loạt các ứng dụng và giao diện
nhưng chỉ có chức năng cơ bản trong kernel, giao diện cho người dùng
không gian dựa trên các ổ cắm có họ địa chỉ riêng AF_ISDN.
