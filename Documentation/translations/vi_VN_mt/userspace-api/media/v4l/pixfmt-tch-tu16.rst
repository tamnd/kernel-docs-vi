.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-tch-tu16.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-TCH-FMT-TU16:

*******************************
V4L2_TCH_FMT_TU16 ('TU16')
********************************

ZZ0000ZZ

Dữ liệu cảm ứng thô endian nhỏ 16-bit không dấu


Sự miêu tả
===========

Định dạng này thể hiện dữ liệu 16 bit không dấu từ bộ điều khiển cảm ứng.

Điều này có thể được sử dụng làm đầu ra cho dữ liệu thô và dữ liệu tham chiếu. Các giá trị có thể dao động từ
0 đến 65535.

ZZ0000ZZ
Mỗi ô là một byte.


.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       2 1 1 1 1 1 1 1 1

    * - start + 0:
      - R'\ :sub:`00low`
      - R'\ :sub:`00high`
      - R'\ :sub:`01low`
      - R'\ :sub:`01high`
      - R'\ :sub:`02low`
      - R'\ :sub:`02high`
      - R'\ :sub:`03low`
      - R'\ :sub:`03high`
    * - start + 8:
      - R'\ :sub:`10low`
      - R'\ :sub:`10high`
      - R'\ :sub:`11low`
      - R'\ :sub:`11high`
      - R'\ :sub:`12low`
      - R'\ :sub:`12high`
      - R'\ :sub:`13low`
      - R'\ :sub:`13high`
    * - start + 16:
      - R'\ :sub:`20low`
      - R'\ :sub:`20high`
      - R'\ :sub:`21low`
      - R'\ :sub:`21high`
      - R'\ :sub:`22low`
      - R'\ :sub:`22high`
      - R'\ :sub:`23low`
      - R'\ :sub:`23high`
    * - start + 24:
      - R'\ :sub:`30low`
      - R'\ :sub:`30high`
      - R'\ :sub:`31low`
      - R'\ :sub:`31high`
      - R'\ :sub:`32low`
      - R'\ :sub:`32high`
      - R'\ :sub:`33low`
      - R'\ :sub:`33high`