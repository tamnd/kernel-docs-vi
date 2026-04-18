.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-sdr-ru12le.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-SDR-FMT-RU12LE:

****************************
V4L2_SDR_FMT_RU12LE ('RU12')
****************************


Mẫu endian nhỏ 12 bit không dấu thực


Sự miêu tả
===========

Định dạng này chứa chuỗi các mẫu số thực. Mỗi mẫu là
được biểu diễn dưới dạng số endian nhỏ không dấu 12 bit. Mẫu được lưu trữ
trong không gian 16 bit với các bit cao chưa được sử dụng được đệm bằng 0.

ZZ0000ZZ
Mỗi ô là một byte.




.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - I'\ :sub:`0[7:0]`
      - I'\ :sub:`0[11:8]`