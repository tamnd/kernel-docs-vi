.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb10dpcm8.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-SBGGR10DPCM8:
.. _v4l2-pix-fmt-sgbrg10dpcm8:
.. _v4l2-pix-fmt-sgrbg10dpcm8:
.. _v4l2-pix-fmt-srggb10dpcm8:


********************************************************************************************************************************************************
V4L2_PIX_FMT_SBGGR10DPCM8 ('bBA8'), V4L2_PIX_FMT_SGBRG10DPCM8 ('bGA8'), V4L2_PIX_FMT_SGRBG10DPCM8 ('BD10'), V4L2_PIX_FMT_SRGGB10DPCM8 ('bRA8'),
***********************************************************************************************************************************************

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