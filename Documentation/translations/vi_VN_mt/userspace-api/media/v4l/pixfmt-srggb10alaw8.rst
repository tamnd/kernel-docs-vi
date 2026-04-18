.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb10alaw8.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SBGGR10ALAW8:
.. _v4l2-pix-fmt-sgbrg10alaw8:
.. _v4l2-pix-fmt-sgrbg10alaw8:
.. _v4l2-pix-fmt-srggb10alaw8:

********************************************************************************************************************************************************
V4L2_PIX_FMT_SBGGR10ALAW8 ('aBA8'), V4L2_PIX_FMT_SGBRG10ALAW8 ('aGA8'), V4L2_PIX_FMT_SGRBG10ALAW8 ('agA8'), V4L2_PIX_FMT_SRGGB10ALAW8 ('aRA8'),
***********************************************************************************************************************************************

V4L2_PIX_FMT_SGBRG10ALAW8
V4L2_PIX_FMT_SGRBG10ALAW8
V4L2_PIX_FMT_SRGGB10ALAW8
Các định dạng Bayer 10 bit được nén thành 8 bit


Sự miêu tả
===========

Bốn định dạng pixel này là định dạng sRGB / Bayer thô với 10 bit mỗi
mỗi màu được nén thành 8 bit, sử dụng thuật toán A-LAW. Mỗi màu
thành phần tiêu thụ 8 bit bộ nhớ. Ở các khía cạnh khác, định dạng này là
tương tự như ZZ0000ZZ.