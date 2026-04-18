.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb10dpcm8.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SBGGR10DPCM8:
.. _v4l2-pix-fmt-sgbrg10dpcm8:
.. _v4l2-pix-fmt-sgrbg10dpcm8:
.. _v4l2-pix-fmt-srggb10dpcm8:


********************************************************************************************************************************************************
V4L2_PIX_FMT_SBGGR10DPCM8 ('bBA8'), V4L2_PIX_FMT_SGBRG10DPCM8 ('bGA8'), V4L2_PIX_FMT_SGRBG10DPCM8 ('BD10'), V4L2_PIX_FMT_SRGGB10DPCM8 ('bRA8'),
********************************************************************************************************************************************************

ZZ0000ZZ

V4L2_PIX_FMT_SGBRG10DPCM8
V4L2_PIX_FMT_SGRBG10DPCM8
V4L2_PIX_FMT_SRGGB10DPCM8
Các định dạng Bayer 10 bit được nén thành 8 bit


Sự miêu tả
===========

Bốn định dạng pixel này là định dạng sRGB / Bayer thô với 10 bit mỗi
mỗi màu được nén thành 8 bit, sử dụng nén DPCM. DPCM,
điều chế mã xung vi sai bị mất mát. Mỗi thành phần màu
tiêu thụ 8 bit bộ nhớ. Ở các khía cạnh khác, định dạng này tương tự như
ZZ0000ZZ.