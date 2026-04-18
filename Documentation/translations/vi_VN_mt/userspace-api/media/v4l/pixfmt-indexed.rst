.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-indexed.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _pixfmt-indexed:

**************************
Định dạng được lập chỉ mục
**************************

Ở định dạng này, mỗi pixel được biểu thị bằng chỉ số 8 bit thành 256
mục bảng màu ARGB. Nó được dành cho
Chỉ ZZ0000ZZ. Không có ioctls để truy cập
bảng màu, việc này phải được thực hiện bằng ioctls của bộ đệm khung Linux API.



.. flat-table:: Indexed Image Format
    :header-rows:  2
    :stub-columns: 0

    * - Identifier
      - Code
      -
      - :cspan:`7` Byte 0
    * -
      -
      - Bit
      - 7
      - 6
      - 5
      - 4
      - 3
      - 2
      - 1
      - 0
    * .. _V4L2-PIX-FMT-PAL8:

      - ``V4L2_PIX_FMT_PAL8``
      - 'PAL8'
      -
      - i\ :sub:`7`
      - i\ :sub:`6`
      - i\ :sub:`5`
      - i\ :sub:`4`
      - i\ :sub:`3`
      - i\ :sub:`2`
      - i\ :sub:`1`
      - i\ :sub:`0`