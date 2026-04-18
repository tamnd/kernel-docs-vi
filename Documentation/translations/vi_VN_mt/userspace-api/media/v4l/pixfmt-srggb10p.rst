.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb10p.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SRGGB10P:
.. _v4l2-pix-fmt-sbggr10p:
.. _v4l2-pix-fmt-sgbrg10p:
.. _v4l2-pix-fmt-sgrbg10p:

**************************************************************************************************************************************
V4L2_PIX_FMT_SRGGB10P ('pRAA'), V4L2_PIX_FMT_SGRBG10P ('pgAA'), V4L2_PIX_FMT_SGBRG10P ('pGAA'), V4L2_PIX_FMT_SBGGR10P ('pBAA'),
*******************************************************************************************************************************


V4L2_PIX_FMT_SGRBG10P
V4L2_PIX_FMT_SGBRG10P
V4L2_PIX_FMT_SBGGR10P
Các định dạng Bayer được đóng gói 10 bit


Sự miêu tả
===========

Bốn định dạng pixel này được đóng gói dưới dạng định dạng sRGB / Bayer thô với 10
bit trên mỗi mẫu. Cứ bốn mẫu liên tiếp được đóng gói thành 5
byte. Mỗi byte trong số 4 byte đầu tiên chứa 8 bit bậc cao
của các pixel và byte thứ 5 chứa 2 giá trị nhỏ nhất
bit của mỗi pixel, theo cùng một thứ tự.

Mỗi hàng n-pixel chứa n/2 mẫu màu xanh lá cây và n/2 mẫu màu xanh lam hoặc đỏ,
với các hàng xanh-đỏ và xanh-xanh xen kẽ. Họ theo quy ước
được mô tả là GRGR... BGBG..., RGRG... GBGB..., v.v. Dưới đây là một ví dụ
của một hình ảnh V4L2_PIX_FMT_SBGGR10P nhỏ:

ZZ0000ZZ
Mỗi ô là một byte.

.. tabularcolumns:: |p{2.4cm}|p{1.4cm}|p{1.2cm}|p{1.2cm}|p{1.2cm}|p{9.3cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 12 8 8 8 8 68

    * - start + 0:
      - B\ :sub:`00high`
      - G\ :sub:`01high`
      - B\ :sub:`02high`
      - G\ :sub:`03high`
      - G\ :sub:`03low`\ (bits 7--6) B\ :sub:`02low`\ (bits 5--4)

	G\ :sub:`01low`\ (bits 3--2) B\ :sub:`00low`\ (bits 1--0)
    * - start + 5:
      - G\ :sub:`10high`
      - R\ :sub:`11high`
      - G\ :sub:`12high`
      - R\ :sub:`13high`
      - R\ :sub:`13low`\ (bits 7--6) G\ :sub:`12low`\ (bits 5--4)

	R\ :sub:`11low`\ (bits 3--2) G\ :sub:`10low`\ (bits 1--0)
    * - start + 10:
      - B\ :sub:`20high`
      - G\ :sub:`21high`
      - B\ :sub:`22high`
      - G\ :sub:`23high`
      - G\ :sub:`23low`\ (bits 7--6) B\ :sub:`22low`\ (bits 5--4)

	G\ :sub:`21low`\ (bits 3--2) B\ :sub:`20low`\ (bits 1--0)
    * - start + 15:
      - G\ :sub:`30high`
      - R\ :sub:`31high`
      - G\ :sub:`32high`
      - R\ :sub:`33high`
      - R\ :sub:`33low`\ (bits 7--6) G\ :sub:`32low`\ (bits 5--4)

	R\ :sub:`31low`\ (bits 3--2) G\ :sub:`30low`\ (bits 1--0)