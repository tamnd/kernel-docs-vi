.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-cnf4.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. -*- coding: utf-8; mode: rst -*-
.. c:namespace:: V4L

.. _V4L2-PIX-FMT-CNF4:

*******************************
V4L2_PIX_FMT_CNF4 ('CNF4')
******************************

Thông tin về độ tin cậy của cảm biến độ sâu dưới dạng mảng được đóng gói 4 bit trên mỗi pixel

Sự miêu tả
===========

Định dạng độc quyền được sử dụng bởi máy ảnh Độ sâu Intel RealSense chứa độ sâu
thông tin độ tin cậy trong phạm vi 0-15 với 0 cho biết cảm biến đã được
không thể giải quyết bất kỳ tín hiệu nào và 15 biểu thị mức độ tin cậy tối đa cho
cảm biến cụ thể (biên độ lỗi thực tế có thể thay đổi từ cảm biến này sang cảm biến khác).

Cứ hai pixel liên tiếp được đóng gói thành một byte.
Các bit 0-3 của byte n đề cập đến giá trị độ tin cậy của pixel độ sâu 2*n,
bit 4-7 đến giá trị tin cậy của pixel độ sâu 2*n+1.

ZZ0000ZZ

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 64 64

    * - Y'\ :sub:`01[3:0]`\ (bits 7--4) Y'\ :sub:`00[3:0]`\ (bits 3--0)
      - Y'\ :sub:`03[3:0]`\ (bits 7--4) Y'\ :sub:`02[3:0]`\ (bits 3--0)
