.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb8.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SRGGB8:
.. _v4l2-pix-fmt-sbggr8:
.. _v4l2-pix-fmt-sgbrg8:
.. _v4l2-pix-fmt-sgrbg8:

***********************************************************************************************************************************
V4L2_PIX_FMT_SRGGB8 ('RGGB'), V4L2_PIX_FMT_SGRBG8 ('GRBG'), V4L2_PIX_FMT_SGBRG8 ('GBRG'), V4L2_PIX_FMT_SBGGR8 ('BA81'),
***************************************************************************************************************************


=====================
Định dạng Bayer 8 bit
===================

Sự miêu tả
===========

Bốn định dạng pixel này là định dạng sRGB / Bayer thô với 8 bit mỗi
mẫu. Mỗi mẫu được lưu trữ trong một byte. Mỗi hàng n-pixel chứa n/2
mẫu màu xanh lá cây và n/2 mẫu màu xanh lam hoặc đỏ, với các mẫu màu đỏ và đỏ xen kẽ
hàng màu xanh. Chúng được mô tả theo quy ước là GRGR... BGBG...,
RGRG... GBGB..., v.v. Dưới đây là ví dụ về hình ảnh V4L2_PIX_FMT_SBGGR8 nhỏ:

ZZ0000ZZ
Mỗi ô là một byte.




.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - B\ :sub:`00`
      - G\ :sub:`01`
      - B\ :sub:`02`
      - G\ :sub:`03`
    * - start + 4:
      - G\ :sub:`10`
      - R\ :sub:`11`
      - G\ :sub:`12`
      - R\ :sub:`13`
    * - start + 8:
      - B\ :sub:`20`
      - G\ :sub:`21`
      - B\ :sub:`22`
      - G\ :sub:`23`
    * - start + 12:
      - G\ :sub:`30`
      - R\ :sub:`31`
      - G\ :sub:`32`
      - R\ :sub:`33`