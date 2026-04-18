.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-sdr-pcu20be.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-SDR-FMT-PCU20BE:

*******************************
V4L2_SDR_FMT_PCU20BE ('PC20')
******************************

Mẫu IQ endian lớn 20-bit phức tạp không dấu

Sự miêu tả
===========

Định dạng này chứa một chuỗi các mẫu số phức. Mỗi phức hợp
số bao gồm hai phần gọi là In-phase và Quadrature (IQ). Cả tôi
và Q được biểu diễn dưới dạng số cuối lớn không dấu 20 bit được lưu trữ trong
không gian 32 bit. Các bit chưa sử dụng còn lại trong không gian 32 bit sẽ được
được đệm bằng 0. Giá trị I bắt đầu trước và giá trị Q bắt đầu ở phần bù
bằng một nửa kích thước bộ đệm (tức là) offset = buffersize/2. Ra khỏi
20 bit, bit 19:2 (18 bit) là dữ liệu và bit 1:0 (2 bit) có thể là bất kỳ
giá trị.

ZZ0000ZZ
Mỗi ô là một byte.

.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    * -  Offset:
      -  Byte B0
      -  Byte B1
      -  Byte B2
      -  Byte B3
    * -  start + 0:
      -  I'\ :sub:`0[19:12]`
      -  I'\ :sub:`0[11:4]`
      -  I'\ :sub:`0[3:0]; B2[3:0]=pad`
      -  pad
    * -  start + 4:
      -  I'\ :sub:`1[19:12]`
      -  I'\ :sub:`1[11:4]`
      -  I'\ :sub:`1[3:0]; B2[3:0]=pad`
      -  pad
    * -  ...
    * - start + offset:
      -  Q'\ :sub:`0[19:12]`
      -  Q'\ :sub:`0[11:4]`
      -  Q'\ :sub:`0[3:0]; B2[3:0]=pad`
      -  pad
    * - start + offset + 4:
      -  Q'\ :sub:`1[19:12]`
      -  Q'\ :sub:`1[11:4]`
      -  Q'\ :sub:`1[3:0]; B2[3:0]=pad`
      -  pad