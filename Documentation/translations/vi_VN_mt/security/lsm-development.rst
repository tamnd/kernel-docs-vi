.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/lsm-development.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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
