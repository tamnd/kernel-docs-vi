.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-sdr-ru12le.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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