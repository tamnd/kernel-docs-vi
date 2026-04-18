.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb12.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SRGGB12:
.. _v4l2-pix-fmt-sbggr12:
.. _v4l2-pix-fmt-sgbrg12:
.. _v4l2-pix-fmt-sgrbg12:


***********************************************************************************************************************************
V4L2_PIX_FMT_SRGGB12 ('RG12'), V4L2_PIX_FMT_SGRBG12 ('BA12'), V4L2_PIX_FMT_SGBRG12 ('GB12'), V4L2_PIX_FMT_SBGGR12 ('BG12'),
***************************************************************************************************************************


V4L2_PIX_FMT_SGRBG12
V4L2_PIX_FMT_SGBRG12
V4L2_PIX_FMT_SBGGR12
Các định dạng Bayer 12 bit được mở rộng lên 16 bit


Sự miêu tả
===========

Bốn định dạng pixel này là định dạng sRGB / Bayer thô với 12 bit trên mỗi
màu sắc. Mỗi thành phần màu được lưu trữ trong một từ 16 bit, trong đó có 4 thành phần màu chưa được sử dụng.
bit cao chứa đầy số không. Mỗi hàng n-pixel chứa n/2 mẫu màu xanh lá cây
và n/2 mẫu xanh hoặc đỏ, với các hàng đỏ và xanh xen kẽ. Byte
được lưu trữ trong bộ nhớ theo thứ tự endian nhỏ. Họ theo quy ước
được mô tả là GRGR... BGBG..., RGRG... GBGB..., v.v. Dưới đây là một ví dụ
của một hình ảnh V4L2_PIX_FMT_SBGGR12 nhỏ:

ZZ0000ZZ
Mỗi ô là một byte, 4 bit quan trọng nhất trong byte cao là
0.




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