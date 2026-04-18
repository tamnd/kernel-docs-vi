.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb10.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SRGGB10:
.. _v4l2-pix-fmt-sbggr10:
.. _v4l2-pix-fmt-sgbrg10:
.. _v4l2-pix-fmt-sgrbg10:

***********************************************************************************************************************************
V4L2_PIX_FMT_SRGGB10 ('RG10'), V4L2_PIX_FMT_SGRBG10 ('BA10'), V4L2_PIX_FMT_SGBRG10 ('GB10'), V4L2_PIX_FMT_SBGGR10 ('BG10'),
***********************************************************************************************************************************


V4L2_PIX_FMT_SGRBG10
V4L2_PIX_FMT_SGBRG10
V4L2_PIX_FMT_SBGGR10
Các định dạng Bayer 10 bit được mở rộng lên 16 bit


Sự miêu tả
===========

Bốn định dạng pixel này là định dạng sRGB / Bayer thô với 10 bit mỗi
mẫu. Mỗi mẫu được lưu trữ trong một từ 16 bit, trong đó có 6 mẫu chưa được sử dụng.
bit cao chứa đầy số không. Mỗi hàng n-pixel chứa n/2 mẫu màu xanh lá cây và
n/2 mẫu xanh hoặc đỏ, xen kẽ các hàng đỏ và xanh. Byte là
được lưu trữ trong bộ nhớ theo thứ tự endian nhỏ. Chúng được mô tả một cách thông thường
như GRGR... BGBG..., RGRG... GBGB..., v.v. Dưới đây là ví dụ về một trong những
các định dạng này:

ZZ0000ZZ
Mỗi ô là một byte, 6 bit quan trọng nhất trong byte cao
là 0.




.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - B\ :sub:`00low`
      - B\ :sub:`00high`
      - G\ :sub:`01low`
      - G\ :sub:`01high`
      - B\ :sub:`02low`
      - B\ :sub:`02high`
      - G\ :sub:`03low`
      - G\ :sub:`03high`
    * - start + 8:
      - G\ :sub:`10low`
      - G\ :sub:`10high`
      - R\ :sub:`11low`
      - R\ :sub:`11high`
      - G\ :sub:`12low`
      - G\ :sub:`12high`
      - R\ :sub:`13low`
      - R\ :sub:`13high`
    * - start + 16:
      - B\ :sub:`20low`
      - B\ :sub:`20high`
      - G\ :sub:`21low`
      - G\ :sub:`21high`
      - B\ :sub:`22low`
      - B\ :sub:`22high`
      - G\ :sub:`23low`
      - G\ :sub:`23high`
    * - start + 24:
      - G\ :sub:`30low`
      - G\ :sub:`30high`
      - R\ :sub:`31low`
      - R\ :sub:`31high`
      - G\ :sub:`32low`
      - G\ :sub:`32high`
      - R\ :sub:`33low`
      - R\ :sub:`33high`