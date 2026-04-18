.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-m420.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-M420:

**************************
V4L2_PIX_FMT_M420 ('M420')
**************************

Định dạng có độ phân giải ½ sắc độ ngang và dọc, còn được gọi là
YUV 4:2:0. Bố trí mặt phẳng lai xen kẽ.


Sự miêu tả
===========

M420 là định dạng YUV với ½ mẫu phụ sắc độ ngang và dọc
(YUV 4:2:0). Các điểm ảnh được tổ chức dưới dạng các mặt phẳng độ sáng và sắc độ xen kẽ.
Hai dòng dữ liệu độ sáng được theo sau bởi một dòng dữ liệu sắc độ.

Mặt phẳng luma có một byte cho mỗi pixel. Mặt phẳng sắc độ chứa
các pixel CbCr xen kẽ được lấy mẫu phụ theo ½ theo chiều ngang và chiều dọc
hướng dẫn. Mỗi cặp CbCr thuộc về bốn pixel. Ví dụ,
Cb\ ZZ0000ZZ/Cr\ ZZ0001ZZ thuộc về Y'\ ZZ0002ZZ, Y'\ ZZ0003ZZ,
Y'\ ZZ0004ZZ, Y'\ ZZ0005ZZ.

Tất cả độ dài dòng đều giống nhau: nếu dòng Y bao gồm byte đệm thì cũng vậy
dòng CbCr.

ZZ0000ZZ
Mỗi ô là một byte.


.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 8:
      - Cb\ :sub:`00`
      - Cr\ :sub:`00`
      - Cb\ :sub:`01`
      - Cr\ :sub:`01`
    * - start + 16:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 20:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 24:
      - Cb\ :sub:`10`
      - Cr\ :sub:`10`
      - Cb\ :sub:`11`
      - Cr\ :sub:`11`


ZZ0001ZZ
Mẫu sắc độ là ZZ0000ZZ
chiều ngang và chiều dọc.