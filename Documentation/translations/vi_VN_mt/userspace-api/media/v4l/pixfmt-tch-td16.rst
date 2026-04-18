.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-tch-td16.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-TCH-FMT-DELTA-TD16:

********************************
V4L2_TCH_FMT_DELTA_TD16 ('TD16')
********************************

ZZ0000ZZ

Touch Delta nhỏ có chữ ký 16-bit


Sự miêu tả
===========

Định dạng này thể hiện dữ liệu delta từ bộ điều khiển cảm ứng.

Giá trị Delta có thể nằm trong khoảng từ -32768 đến 32767. Thông thường, các giá trị này sẽ thay đổi
trong một phạm vi nhỏ tùy thuộc vào việc cảm biến có được chạm vào hay không. các
có thể thấy giá trị đầy đủ nếu một trong các nút màn hình cảm ứng bị lỗi hoặc đường
không được kết nối.

ZZ0000ZZ
Mỗi ô là một byte.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       2 1 1 1 1 1 1 1 1

    * - start + 0:
      - D'\ :sub:`00low`
      - D'\ :sub:`00high`
      - D'\ :sub:`01low`
      - D'\ :sub:`01high`
      - D'\ :sub:`02low`
      - D'\ :sub:`02high`
      - D'\ :sub:`03low`
      - D'\ :sub:`03high`
    * - start + 8:
      - D'\ :sub:`10low`
      - D'\ :sub:`10high`
      - D'\ :sub:`11low`
      - D'\ :sub:`11high`
      - D'\ :sub:`12low`
      - D'\ :sub:`12high`
      - D'\ :sub:`13low`
      - D'\ :sub:`13high`
    * - start + 16:
      - D'\ :sub:`20low`
      - D'\ :sub:`20high`
      - D'\ :sub:`21low`
      - D'\ :sub:`21high`
      - D'\ :sub:`22low`
      - D'\ :sub:`22high`
      - D'\ :sub:`23low`
      - D'\ :sub:`23high`
    * - start + 24:
      - D'\ :sub:`30low`
      - D'\ :sub:`30high`
      - D'\ :sub:`31low`
      - D'\ :sub:`31high`
      - D'\ :sub:`32low`
      - D'\ :sub:`32high`
      - D'\ :sub:`33low`
      - D'\ :sub:`33high`