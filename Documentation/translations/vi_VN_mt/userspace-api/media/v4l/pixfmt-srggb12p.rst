.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb12p.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SRGGB12P:
.. _v4l2-pix-fmt-sbggr12p:
.. _v4l2-pix-fmt-sgbrg12p:
.. _v4l2-pix-fmt-sgrbg12p:

**************************************************************************************************************************************
V4L2_PIX_FMT_SRGGB12P ('pRCC'), V4L2_PIX_FMT_SGRBG12P ('pgCC'), V4L2_PIX_FMT_SGBRG12P ('pGCC'), V4L2_PIX_FMT_SBGGR12P ('pBCC')
*******************************************************************************************************************************


Các định dạng Bayer được đóng gói 12 bit
---------------------------


Sự miêu tả
===========

Bốn định dạng pixel này được đóng gói dưới dạng định dạng sRGB / Bayer thô với 12
bit cho mỗi màu. Cứ hai mẫu liên tiếp được đóng gói thành ba
byte. Mỗi byte trong số hai byte đầu tiên chứa 8 bit bậc cao của
các pixel và byte thứ ba chứa bốn giá trị nhỏ nhất
bit của mỗi pixel, theo cùng một thứ tự.

Mỗi hàng n-pixel chứa n/2 mẫu màu xanh lá cây và n/2 mẫu màu xanh lam hoặc đỏ
các mẫu, với các hàng xanh-đỏ và xanh-xanh xen kẽ. Họ là
thường được mô tả là GRGR... BGBG..., RGRG... GBGB..., v.v.
Dưới đây là ví dụ về hình ảnh V4L2_PIX_FMT_SBGGR12P nhỏ:

ZZ0000ZZ
Mỗi ô là một byte.

.. tabularcolumns:: |p{2.2cm}|p{1.2cm}|p{1.2cm}|p{3.1cm}|p{1.2cm}|p{1.2cm}|p{6.4cm}|


.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       2 1 1 1 1 1 1


    -  -  start + 0:
       -  B\ :sub:`00high`
       -  G\ :sub:`01high`
       -  G\ :sub:`01low`\ (bits 7--4)

          B\ :sub:`00low`\ (bits 3--0)
       -  B\ :sub:`02high`
       -  G\ :sub:`03high`
       -  G\ :sub:`03low`\ (bits 7--4)

          B\ :sub:`02low`\ (bits 3--0)

    -  -  start + 6:
       -  G\ :sub:`10high`
       -  R\ :sub:`11high`
       -  R\ :sub:`11low`\ (bits 7--4)

          G\ :sub:`10low`\ (bits 3--0)
       -  G\ :sub:`12high`
       -  R\ :sub:`13high`
       -  R\ :sub:`13low`\ (bits 7--4)

          G\ :sub:`12low`\ (bits 3--0)
    -  -  start + 12:
       -  B\ :sub:`20high`
       -  G\ :sub:`21high`
       -  G\ :sub:`21low`\ (bits 7--4)

          B\ :sub:`20low`\ (bits 3--0)
       -  B\ :sub:`22high`
       -  G\ :sub:`23high`
       -  G\ :sub:`23low`\ (bits 7--4)

          B\ :sub:`22low`\ (bits 3--0)
    -  -  start + 18:
       -  G\ :sub:`30high`
       -  R\ :sub:`31high`
       -  R\ :sub:`31low`\ (bits 7--4)

          G\ :sub:`30low`\ (bits 3--0)
       -  G\ :sub:`32high`
       -  R\ :sub:`33high`
       -  R\ :sub:`33low`\ (bits 7--4)

          G\ :sub:`32low`\ (bits 3--0)