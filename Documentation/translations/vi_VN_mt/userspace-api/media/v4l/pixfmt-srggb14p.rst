.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb14p.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SRGGB14P:
.. _v4l2-pix-fmt-sbggr14p:
.. _v4l2-pix-fmt-sgbrg14p:
.. _v4l2-pix-fmt-sgrbg14p:

**************************************************************************************************************************************
V4L2_PIX_FMT_SRGGB14P ('pREE'), V4L2_PIX_FMT_SGRBG14P ('pgEE'), V4L2_PIX_FMT_SGBRG14P ('pGEE'), V4L2_PIX_FMT_SBGGR14P ('pBEE'),
*******************************************************************************************************************************

ZZ0000ZZ

V4L2_PIX_FMT_SGRBG14P
V4L2_PIX_FMT_SGBRG14P
V4L2_PIX_FMT_SBGGR14P
Các định dạng Bayer được đóng gói 14 bit


Sự miêu tả
===========

Bốn định dạng pixel này được đóng gói dưới dạng định dạng sRGB / Bayer thô với 14
bit cho mỗi màu. Cứ bốn mẫu liên tiếp được đóng gói thành bảy
byte. Mỗi byte trong số bốn byte đầu tiên chứa tám bit bậc cao
của các pixel và ba byte tiếp theo chứa sáu byte nhỏ nhất
các bit quan trọng của mỗi pixel, theo cùng một thứ tự.

Mỗi hàng n-pixel chứa n/2 mẫu màu xanh lá cây và n/2 mẫu màu xanh lam hoặc đỏ,
với các hàng xanh-đỏ và xanh-xanh xen kẽ. Họ theo quy ước
được mô tả là GRGR... BGBG..., RGRG... GBGB..., v.v. Dưới đây là một ví dụ
của một trong các định dạng sau:

ZZ0000ZZ
Mỗi ô là một byte.

.. raw:: latex

    \begingroup
    \footnotesize
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{1.6cm}|p{1.0cm}|p{1.0cm}|p{1.0cm}|p{1.0cm}|p{3.5cm}|p{3.5cm}|p{3.5cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       2 1 1 1 1 3 3 3


    -  .. row 1

       -  start + 0

       -  B\ :sub:`00high`

       -  G\ :sub:`01high`

       -  B\ :sub:`02high`

       -  G\ :sub:`03high`

       -  G\ :sub:`01low bits 1--0`\ (bits 7--6)

	  B\ :sub:`00low bits 5--0`\ (bits 5--0)

       -  B\ :sub:`02low bits 3--0`\ (bits 7--4)

	  G\ :sub:`01low bits 5--2`\ (bits 3--0)

       -  G\ :sub:`03low bits 5--0`\ (bits 7--2)

	  B\ :sub:`02low bits 5--4`\ (bits 1--0)

    -  .. row 2

       -  start + 7

       -  G\ :sub:`10high`

       -  R\ :sub:`11high`

       -  G\ :sub:`12high`

       -  R\ :sub:`13high`

       -  R\ :sub:`11low bits 1--0`\ (bits 7--6)

	  G\ :sub:`10low bits 5--0`\ (bits 5--0)

       -  G\ :sub:`12low bits 3--0`\ (bits 7--4)

	  R\ :sub:`11low bits 5--2`\ (bits 3--0)

       -  R\ :sub:`13low bits 5--0`\ (bits 7--2)

	  G\ :sub:`12low bits 5--4`\ (bits 1--0)

    -  .. row 3

       -  start + 14

       -  B\ :sub:`20high`

       -  G\ :sub:`21high`

       -  B\ :sub:`22high`

       -  G\ :sub:`23high`

       -  G\ :sub:`21low bits 1--0`\ (bits 7--6)

	  B\ :sub:`20low bits 5--0`\ (bits 5--0)

       -  B\ :sub:`22low bits 3--0`\ (bits 7--4)

	  G\ :sub:`21low bits 5--2`\ (bits 3--0)

       -  G\ :sub:`23low bits 5--0`\ (bits 7--2)

	  B\ :sub:`22low bits 5--4`\ (bits 1--0)

    -  .. row 4

       -  start + 21

       -  G\ :sub:`30high`

       -  R\ :sub:`31high`

       -  G\ :sub:`32high`

       -  R\ :sub:`33high`

       -  R\ :sub:`31low bits 1--0`\ (bits 7--6)
	  G\ :sub:`30low bits 5--0`\ (bits 5--0)

       -  G\ :sub:`32low bits 3--0`\ (bits 7--4)
	  R\ :sub:`31low bits 5--2`\ (bits 3--0)

       -  R\ :sub:`33low bits 5--0`\ (bits 7--2)
	  G\ :sub:`32low bits 5--4`\ (bits 1--0)

.. raw:: latex

    \endgroup
