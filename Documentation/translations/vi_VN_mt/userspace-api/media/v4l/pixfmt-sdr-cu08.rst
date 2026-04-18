.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-sdr-cu08.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-sdr-fmt-cu8:

*************************
V4L2_SDR_FMT_CU8 ('CU08')
*************************

Mẫu IQ 8 bit không dấu phức tạp


Sự miêu tả
===========

Định dạng này chứa chuỗi các mẫu số phức. Mỗi phức hợp
số bao gồm hai phần, được gọi là Cùng pha và Cầu phương (IQ). Cả tôi
và Q được biểu diễn dưới dạng số không dấu 8 bit. Tôi đánh giá cao nhất
và giá trị Q sau đó.

ZZ0000ZZ
Mỗi ô là một byte.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - I'\ :sub:`0`
    * - start + 1:
      - Q'\ :sub:`0`