.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-sdr-pcu16be.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _V4L2-SDR-FMT-PCU16BE:

*******************************
V4L2_SDR_FMT_PCU16BE ('PC16')
******************************

Mẫu IQ endian lớn 16-bit phức tạp không dấu

Sự miêu tả
===========

Định dạng này chứa một chuỗi các mẫu số phức. Mỗi phức hợp
số bao gồm hai phần gọi là In-phase và Quadrature (IQ). Cả tôi
và Q được biểu diễn dưới dạng số cuối lớn không dấu 16 bit được lưu trong
không gian 32 bit. Các bit chưa sử dụng còn lại trong không gian 32 bit sẽ được
được đệm bằng 0. Giá trị I bắt đầu trước và giá trị Q bắt đầu ở phần bù
bằng một nửa kích thước bộ đệm (tức là) offset = buffersize/2. Ra khỏi
16 bit, bit 15:2 (14 bit) là dữ liệu và bit 1:0 (2 bit) có thể là bất kỳ
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
      -  I'\ :sub:`0[13:6]`
      -  I'\ :sub:`0[5:0]; B1[1:0]=pad`
      -  pad
      -  pad
    * -  start + 4:
      -  I'\ :sub:`1[13:6]`
      -  I'\ :sub:`1[5:0]; B1[1:0]=pad`
      -  pad
      -  pad
    * -  ...
    * - start + offset:
      -  Q'\ :sub:`0[13:6]`
      -  Q'\ :sub:`0[5:0]; B1[1:0]=pad`
      -  pad
      -  pad
    * - start + offset + 4:
      -  Q'\ :sub:`1[13:6]`
      -  Q'\ :sub:`1[5:0]; B1[1:0]=pad`
      -  pad
      -  pad