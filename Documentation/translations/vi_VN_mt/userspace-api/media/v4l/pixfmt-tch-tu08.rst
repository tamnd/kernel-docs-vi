.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-tch-tu08.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-TCH-FMT-TU08:

**************************
V4L2_TCH_FMT_TU08 ('TU08')
**************************

ZZ0000ZZ

Dữ liệu cảm ứng thô không dấu 8 bit

Sự miêu tả
===========

Định dạng này thể hiện dữ liệu 8 bit không dấu từ bộ điều khiển cảm ứng.

Điều này có thể được sử dụng làm đầu ra cho dữ liệu thô và dữ liệu tham chiếu. Các giá trị có thể dao động từ
0 đến 255.

ZZ0000ZZ
Mỗi ô là một byte.



.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       2 1 1 1 1

    * - start + 0:
      - R'\ :sub:`00`
      - R'\ :sub:`01`
      - R'\ :sub:`02`
      - R'\ :sub:`03`
    * - start + 4:
      - R'\ :sub:`10`
      - R'\ :sub:`11`
      - R'\ :sub:`12`
      - R'\ :sub:`13`
    * - start + 8:
      - R'\ :sub:`20`
      - R'\ :sub:`21`
      - R'\ :sub:`22`
      - R'\ :sub:`23`
    * - start + 12:
      - R'\ :sub:`30`
      - R'\ :sub:`31`
      - R'\ :sub:`32`
      - R'\ :sub:`33`