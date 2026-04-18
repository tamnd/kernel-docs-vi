.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-uvc-msxu-1-5.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _v4l2-meta-fmt-uvc-msxu-1-5:

**********************************
V4L2_META_FMT_UVC_MSXU_1_5 ('UVCM')
***********************************

Siêu dữ liệu tải trọng UVC của Microsoft(R).


Sự miêu tả
===========

Bộ đệm V4L2_META_FMT_UVC_MSXU_1_5 tuân theo bố cục bộ đệm siêu dữ liệu của
V4L2_META_FMT_UVC với điểm khác biệt duy nhất là nó bao gồm tất cả UVC
siêu dữ liệu trong trường ZZ0000ZZ, không chỉ 2-12 byte đầu tiên.

Định dạng siêu dữ liệu tuân theo thông số kỹ thuật từ Microsoft(R) [1].

.. _1:

[1] ZZ0000ZZ