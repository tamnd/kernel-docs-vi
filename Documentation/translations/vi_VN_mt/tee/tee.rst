.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/tee/tee.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
TEE (Môi trường thực thi đáng tin cậy)
===================================

Tài liệu này mô tả hệ thống con TEE trong Linux.

Tổng quan
========

TEE là một hệ điều hành đáng tin cậy chạy trong một số môi trường an toàn, chẳng hạn như
TrustZone trên CPU ARM hoặc bộ đồng xử lý bảo mật riêng biệt, v.v. Trình điều khiển TEE
xử lý các chi tiết cần thiết để liên lạc với TEE.

Hệ thống con này xử lý:

- Đăng ký driver TEE

- Quản lý bộ nhớ dùng chung giữa Linux và TEE

- Cung cấp API chung cho TEE