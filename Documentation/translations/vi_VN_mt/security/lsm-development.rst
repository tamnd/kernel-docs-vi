.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/lsm-development.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Phát triển mô-đun bảo mật Linux
=================================

Dựa trên ZZ0001ZZ
LSM mới được chấp nhận vào kernel khi mục đích của nó (mô tả về
nó cố gắng bảo vệ chống lại điều gì và trong trường hợp nào người ta mong đợi
sử dụng nó) đã được ghi lại một cách thích hợp trong ZZ0000ZZ.
Điều này cho phép dễ dàng so sánh mã của LSM với mục tiêu của nó và do đó
rằng người dùng cuối và nhà phân phối có thể đưa ra quyết định sáng suốt hơn về việc
LSM phù hợp với yêu cầu của họ.

Để có tài liệu mở rộng về các giao diện móc LSM có sẵn, vui lòng
xem ZZ0000ZZ và các cấu trúc liên quan:

.. kernel-doc:: security/security.c
   :export:
