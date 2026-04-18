.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb10alaw8.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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