.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-sdr-cu16le.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-SDR-FMT-CU16LE:

****************************
V4L2_SDR_FMT_CU16LE ('CU16')
****************************


Mẫu IQ endian nhỏ 16 bit không dấu phức tạp


Sự miêu tả
===========

Định dạng này chứa chuỗi các mẫu số phức. Mỗi phức hợp
số bao gồm hai phần, được gọi là Cùng pha và Cầu phương (IQ). Cả tôi
và Q được biểu diễn dưới dạng số endian nhỏ không dấu 16 bit. tôi đánh giá cao
đến trước và giá trị Q sau đó.

ZZ0000ZZ
Mỗi ô là một byte.


.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - I'\ :sub:`0[7:0]`
      - I'\ :sub:`0[15:8]`
    * - start + 2:
      - Q'\ :sub:`0[7:0]`
      - Q'\ :sub:`0[15:8]`