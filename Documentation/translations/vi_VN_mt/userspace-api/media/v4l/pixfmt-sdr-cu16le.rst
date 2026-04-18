.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-sdr-cu16le.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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