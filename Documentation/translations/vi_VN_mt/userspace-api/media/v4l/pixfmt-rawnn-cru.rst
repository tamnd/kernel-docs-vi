.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-rawnn-cru.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _v4l2-pix-fmt-raw-cru10:
.. _v4l2-pix-fmt-raw-cru12:
.. _v4l2-pix-fmt-raw-cru14:
.. _v4l2-pix-fmt-raw-cru20:

********************************************************************************************************************************************
V4L2_PIX_FMT_RAW_CRU10 ('CR10'), V4L2_PIX_FMT_RAW_CRU12 ('CR12'), V4L2_PIX_FMT_RAW_CRU14 ('CR14'), V4L2_PIX_FMT_RAW_CRU20 ('CR20')
********************************************************************************************************************************************

=====================================================================
Bộ thu camera Renesas RZ/V2H Định dạng pixel đóng gói 64-bit
=====================================================================

| V4L2_PIX_FMT_RAW_CRU10 (CR10)
| V4L2_PIX_FMT_RAW_CRU12 (CR12)
| V4L2_PIX_FMT_RAW_CRU14 (CR14)
| V4L2_PIX_FMT_RAW_CRU20 (CR20)

Sự miêu tả
===========

Các định dạng pixel này là một số đầu ra RAW cho Bộ thu camera trong
SoC Renesas RZ/V2H. Chúng là các định dạng thô đóng gói các pixel liên tục vào
Đơn vị 64 bit, với 4 hoặc 8 bit quan trọng nhất được đệm.

ZZ0000ZZ

.. flat-table:: RAW formats
    :header-rows:  2
    :stub-columns: 0
    :widths: 36 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    :fill-cells:

    * - :rspan:`1` Pixel Format Code
      - :cspan:`63` Data organization
    * - 63
      - 62
      - 61
      - 60
      - 59
      - 58
      - 57
      - 56
      - 55
      - 54
      - 53
      - 52
      - 51
      - 50
      - 49
      - 48
      - 47
      - 46
      - 45
      - 44
      - 43
      - 42
      - 41
      - 40
      - 39
      - 38
      - 37
      - 36
      - 35
      - 34
      - 33
      - 32
      - 31
      - 30
      - 29
      - 28
      - 27
      - 26
      - 25
      - 24
      - 23
      - 22
      - 21
      - 20
      - 19
      - 18
      - 17
      - 16
      - 15
      - 14
      - 13
      - 12
      - 11
      - 10
      - 9
      - 8
      - 7
      - 6
      - 5
      - 4
      - 3
      - 2
      - 1
      - 0
    * - V4L2_PIX_FMT_RAW_CRU10
      - 0
      - 0
      - 0
      - 0
      - :cspan:`9` P5
      - :cspan:`9` P4
      - :cspan:`9` P3
      - :cspan:`9` P2
      - :cspan:`9` P1
      - :cspan:`9` P0
    * - V4L2_PIX_FMT_RAW_CRU12
      - 0
      - 0
      - 0
      - 0
      - :cspan:`11` P4
      - :cspan:`11` P3
      - :cspan:`11` P2
      - :cspan:`11` P1
      - :cspan:`11` P0
    * - V4L2_PIX_FMT_RAW_CRU14
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - :cspan:`13` P3
      - :cspan:`13` P2
      - :cspan:`13` P1
      - :cspan:`13` P0
    * - V4L2_PIX_FMT_RAW_CRU20
      - 0
      - 0
      - 0
      - 0
      - :cspan:`19` P2
      - :cspan:`19` P1
      - :cspan:`19` P0