.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-y12i.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _V4L2-PIX-FMT-Y12I:

**************************
V4L2_PIX_FMT_Y12I ('Y12I')
**************************

Hình ảnh thang màu xám xen kẽ, ví dụ: từ một cặp âm thanh nổi


Sự miêu tả
===========

Đây là hình ảnh thang màu xám có độ sâu 12 bit trên mỗi pixel, nhưng có
pixel từ 2 nguồn được xen kẽ và đóng gói theo bit. Mỗi pixel được lưu trữ
trong một từ 24-bit theo thứ tự little-endian. Trên một máy endian nhỏ
những pixel này có thể được khử xen kẽ bằng cách sử dụng

.. code-block:: c

    __u8 *buf;
    left0 = 0xfff & *(__u16 *)buf;
    right0 = *(__u16 *)(buf + 1) >> 4;

ZZ0000ZZ
các pixel vượt qua ranh giới byte và có tỷ lệ 3 byte cho mỗi pixel
pixel xen kẽ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - Y'\ :sub:`0left[7:0]`
      - Y'\ :sub:`0right[3:0]`\ Y'\ :sub:`0left[11:8]`
      - Y'\ :sub:`0right[11:4]`