.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-y16i.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-Y16I:

**************************
V4L2_PIX_FMT_Y16I ('Y16I')
**************************

Hình ảnh thang màu xám xen kẽ, ví dụ: từ một cặp âm thanh nổi


Sự miêu tả
===========

Đây là hình ảnh có thang màu xám với độ sâu 16 bit trên mỗi pixel, nhưng có pixel
từ 2 nguồn xen kẽ và giải nén. Mỗi pixel được lưu trữ trong một từ 16 bit
theo thứ tự little-endian. Pixel đầu tiên là từ nguồn bên trái.

ZZ0000ZZ
Pixel trái/phải được giải nén 16 bit - 16 bit cho mỗi pixel xen kẽ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - Y'\ :sub:`0L[7:0]`
      - Y'\ :sub:`0L[15:8]`
      - Y'\ :sub:`0R[7:0]`
      - Y'\ :sub:`0R[15:8]`

ZZ0000ZZ
Mỗi ô là một byte.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00Llow`
      - Y'\ :sub:`00Lhigh`
      - Y'\ :sub:`00Rlow`
      - Y'\ :sub:`00Rhigh`
      - Y'\ :sub:`01Llow`
      - Y'\ :sub:`01Lhigh`
      - Y'\ :sub:`01Rlow`
      - Y'\ :sub:`01Rhigh`
    * - start + 8:
      - Y'\ :sub:`10Llow`
      - Y'\ :sub:`10Lhigh`
      - Y'\ :sub:`10Rlow`
      - Y'\ :sub:`10Rhigh`
      - Y'\ :sub:`11Llow`
      - Y'\ :sub:`11Lhigh`
      - Y'\ :sub:`11Rlow`
      - Y'\ :sub:`11Rhigh`
    * - start + 16:
      - Y'\ :sub:`20Llow`
      - Y'\ :sub:`20Lhigh`
      - Y'\ :sub:`20Rlow`
      - Y'\ :sub:`20Rhigh`
      - Y'\ :sub:`21Llow`
      - Y'\ :sub:`21Lhigh`
      - Y'\ :sub:`21Rlow`
      - Y'\ :sub:`21Rhigh`
    * - start + 24:
      - Y'\ :sub:`30Llow`
      - Y'\ :sub:`30Lhigh`
      - Y'\ :sub:`30Rlow`
      - Y'\ :sub:`30Rhigh`
      - Y'\ :sub:`31Llow`
      - Y'\ :sub:`31Lhigh`
      - Y'\ :sub:`31Rlow`
      - Y'\ :sub:`31Rhigh`