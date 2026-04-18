.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/rcar-fdp1.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển Bộ xử lý màn hình mịn Renesas R-Car (FDP1)
==================================================

Trình điều khiển R-Car FDP1 thực hiện các điều khiển dành riêng cho người lái như sau.

ZZ0000ZZ
    Chế độ khử xen kẽ video (chẳng hạn như Bob, Weave, ...). R-Car FDP1
    trình điều khiển thực hiện các chế độ sau.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 4

    * - ``"Progressive" (0)``
      - The input image video stream is progressive (not interlaced). No
        deinterlacing is performed. Apart from (optional) format and encoding
        conversion output frames are identical to the input frames.
    * - ``"Adaptive 2D/3D" (1)``
      - Motion adaptive version of 2D and 3D deinterlacing. Use 3D deinterlacing
        in the presence of fast motion and 2D deinterlacing with diagonal
        interpolation otherwise.
    * - ``"Fixed 2D" (2)``
      - The current field is scaled vertically by averaging adjacent lines to
        recover missing lines. This method is also known as blending or Line
        Averaging (LAV).
    * - ``"Fixed 3D" (3)``
      - The previous and next fields are averaged to recover lines missing from
        the current field. This method is also known as Field Averaging (FAV).
    * - ``"Previous field" (4)``
      - The current field is weaved with the previous field, i.e. the previous
        field is used to fill missing lines from the current field. This method
        is also known as weave deinterlacing.
    * - ``"Next field" (5)``
      - The current field is weaved with the next field, i.e. the next field is
        used to fill missing lines from the current field. This method is also
        known as weave deinterlacing.