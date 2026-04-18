.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/tee/tee.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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