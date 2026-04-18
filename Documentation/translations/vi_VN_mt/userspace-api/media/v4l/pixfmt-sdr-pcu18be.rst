.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-sdr-pcu18be.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-SDR-FMT-PCU18BE:

*******************************
V4L2_SDR_FMT_PCU18BE ('PC18')
******************************

Mẫu IQ endian lớn 18-bit phức tạp không dấu

Sự miêu tả
===========

Định dạng này chứa một chuỗi các mẫu số phức. Mỗi phức hợp
số bao gồm hai phần gọi là In-phase và Quadrature (IQ). Cả tôi
và Q được biểu diễn dưới dạng số endian lớn không dấu 18 bit được lưu trong
không gian 32 bit. Các bit chưa sử dụng còn lại trong không gian 32 bit sẽ được
được đệm bằng 0. Giá trị I bắt đầu trước và giá trị Q bắt đầu ở phần bù
bằng một nửa kích thước bộ đệm (tức là) offset = buffersize/2. Ra khỏi
18 bit, bit 17:2 (16 bit) là dữ liệu và bit 1:0 (2 bit) có thể là bất kỳ
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
      -  I'\ :sub:`0[17:10]`
      -  I'\ :sub:`0[9:2]`
      -  I'\ :sub:`0[1:0]; B2[5:0]=pad`
      -  pad
    * -  start + 4:
      -  I'\ :sub:`1[17:10]`
      -  I'\ :sub:`1[9:2]`
      -  I'\ :sub:`1[1:0]; B2[5:0]=pad`
      -  pad
    * -  ...
    * - start + offset:
      -  Q'\ :sub:`0[17:10]`
      -  Q'\ :sub:`0[9:2]`
      -  Q'\ :sub:`0[1:0]; B2[5:0]=pad`
      -  pad
    * - start + offset + 4:
      -  Q'\ :sub:`1[17:10]`
      -  Q'\ :sub:`1[9:2]`
      -  Q'\ :sub:`1[1:0]; B2[5:0]=pad`
      -  pad