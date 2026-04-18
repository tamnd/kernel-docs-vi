.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb14.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SRGGB14:
.. _v4l2-pix-fmt-sbggr14:
.. _v4l2-pix-fmt-sgbrg14:
.. _v4l2-pix-fmt-sgrbg14:


***********************************************************************************************************************************
V4L2_PIX_FMT_SRGGB14 ('RG14'), V4L2_PIX_FMT_SGRBG14 ('GR14'), V4L2_PIX_FMT_SGBRG14 ('GB14'), V4L2_PIX_FMT_SBGGR14 ('BG14'),
***********************************************************************************************************************************


====================================================
Các định dạng Bayer 14 bit được mở rộng thành 16 bit
====================================================


Sự miêu tả
===========

Bốn định dạng pixel này là định dạng sRGB / Bayer thô với 14 bit trên mỗi
màu sắc. Mỗi mẫu được lưu trữ trong một từ 16 bit, với hai mức cao chưa được sử dụng.
các bit chứa đầy số không. Mỗi hàng n-pixel chứa n/2 mẫu màu xanh lá cây
và n/2 mẫu xanh hoặc đỏ, với các hàng đỏ và xanh xen kẽ. Byte
được lưu trữ trong bộ nhớ theo thứ tự endian nhỏ. Họ theo quy ước
được mô tả là GRGR... BGBG..., RGRG... GBGB..., v.v. Dưới đây là một
ví dụ về hình ảnh V4L2_PIX_FMT_SBGGR14 nhỏ:

ZZ0000ZZ
Mỗi ô là một byte, hai bit quan trọng nhất trong byte cao là
không.



.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       2 1 1 1 1 1 1 1 1


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