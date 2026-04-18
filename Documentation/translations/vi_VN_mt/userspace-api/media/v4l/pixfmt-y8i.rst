.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-y8i.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-Y8I:

*************************
V4L2_PIX_FMT_Y8I ('Y8I')
*************************


Hình ảnh thang màu xám xen kẽ, ví dụ: từ một cặp âm thanh nổi


Sự miêu tả
===========

Đây là hình ảnh thang màu xám có độ sâu 8 bit trên mỗi pixel, nhưng có
pixel từ 2 nguồn xen kẽ. Mỗi pixel được lưu trữ dưới dạng 16 bit
từ. Ví dụ. máy ảnh R200 RealSense lưu trữ pixel từ cảm biến bên trái
ở mức thấp hơn và từ cảm biến bên phải ở 8 bit cao hơn.

ZZ0000ZZ
Mỗi ô là một byte.




.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00left`
      - Y'\ :sub:`00right`
      - Y'\ :sub:`01left`
      - Y'\ :sub:`01right`
      - Y'\ :sub:`02left`
      - Y'\ :sub:`02right`
      - Y'\ :sub:`03left`
      - Y'\ :sub:`03right`
    * - start + 8:
      - Y'\ :sub:`10left`
      - Y'\ :sub:`10right`
      - Y'\ :sub:`11left`
      - Y'\ :sub:`11right`
      - Y'\ :sub:`12left`
      - Y'\ :sub:`12right`
      - Y'\ :sub:`13left`
      - Y'\ :sub:`13right`
    * - start + 16:
      - Y'\ :sub:`20left`
      - Y'\ :sub:`20right`
      - Y'\ :sub:`21left`
      - Y'\ :sub:`21right`
      - Y'\ :sub:`22left`
      - Y'\ :sub:`22right`
      - Y'\ :sub:`23left`
      - Y'\ :sub:`23right`
    * - start + 24:
      - Y'\ :sub:`30left`
      - Y'\ :sub:`30right`
      - Y'\ :sub:`31left`
      - Y'\ :sub:`31right`
      - Y'\ :sub:`32left`
      - Y'\ :sub:`32right`
      - Y'\ :sub:`33left`
      - Y'\ :sub:`33right`