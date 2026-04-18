.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-packed-yuv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _packed-yuv:

*******************
Các định dạng YUV được đóng gói
******************

Tương tự như các định dạng RGB được đóng gói, các định dạng YUV được đóng gói lưu trữ Y, Cb và
Các thành phần Cr liên tiếp trong bộ nhớ. Họ có thể áp dụng việc lấy mẫu con cho sắc độ
các thành phần và do đó khác nhau về cách chúng đan xen ba thành phần đó.

.. note::

   - In all the tables that follow, bit 7 is the most significant bit in a byte.
   - 'Y', 'Cb' and 'Cr' denote bits of the luma, blue chroma (also known as
     'U') and red chroma (also known as 'V') components respectively. 'A'
     denotes bits of the alpha component (if supported by the format), and 'X'
     denotes padding bits.


Lấy mẫu con 4:4:4
=================

Các định dạng này không lấy mẫu con các thành phần sắc độ và lưu trữ từng pixel dưới dạng
đầy đủ bộ ba giá trị Y, Cb và Cr.

Bảng tiếp theo liệt kê các định dạng YUV 4:4:4 được đóng gói với ít hơn 8 bit mỗi
thành phần. Chúng được đặt tên dựa vào thứ tự các thành phần Y, Cb và Cr như sau:
được thấy trong một từ 16 bit, sau đó được lưu trữ trong bộ nhớ theo byte endian nhỏ
thứ tự và số lượng bit cho mỗi thành phần. Ví dụ YUV565
định dạng lưu trữ một pixel trong từ 16 bit [15:0] được trình bày dưới dạng [Y'\ ZZ0000ZZ
Cb\ ZZ0001ZZ Cr\ ZZ0002ZZ] và được lưu trong bộ nhớ ở dạng hai byte,
[Cb\ ZZ0003ZZ Cr\ ZZ0004ZZ] tiếp theo là [Y'\ ZZ0005ZZ Cb\ ZZ0006ZZ].

.. raw:: latex

    \begingroup
    \scriptsize
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{3.5cm}|p{0.96cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|p{0.52cm}|

.. flat-table:: Packed YUV 4:4:4 Image Formats (less than 8bpc)
    :header-rows:  2
    :stub-columns: 0

    * - Identifier
      - Code

      - :cspan:`7` Byte 0 in memory

      - :cspan:`7` Byte 1

    * -
      -
      - 7
      - 6
      - 5
      - 4
      - 3
      - 2
      - 1
      - 0

      - 7
      - 6
      - 5
      - 4
      - 3
      - 2
      - 1
      - 0

    * .. _V4L2-PIX-FMT-YUV444:

      - ``V4L2_PIX_FMT_YUV444``
      - 'Y444'

      - Cb\ :sub:`3`
      - Cb\ :sub:`2`
      - Cb\ :sub:`1`
      - Cb\ :sub:`0`
      - Cr\ :sub:`3`
      - Cr\ :sub:`2`
      - Cr\ :sub:`1`
      - Cr\ :sub:`0`

      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`
      - Y'\ :sub:`3`
      - Y'\ :sub:`2`
      - Y'\ :sub:`1`
      - Y'\ :sub:`0`

    * .. _V4L2-PIX-FMT-YUV555:

      - ``V4L2_PIX_FMT_YUV555``
      - 'YUVO'

      - Cb\ :sub:`2`
      - Cb\ :sub:`1`
      - Cb\ :sub:`0`
      - Cr\ :sub:`4`
      - Cr\ :sub:`3`
      - Cr\ :sub:`2`
      - Cr\ :sub:`1`
      - Cr\ :sub:`0`

      - a
      - Y'\ :sub:`4`
      - Y'\ :sub:`3`
      - Y'\ :sub:`2`
      - Y'\ :sub:`1`
      - Y'\ :sub:`0`
      - Cb\ :sub:`4`
      - Cb\ :sub:`3`

    * .. _V4L2-PIX-FMT-YUV565:

      - ``V4L2_PIX_FMT_YUV565``
      - 'YUVP'

      - Cb\ :sub:`2`
      - Cb\ :sub:`1`
      - Cb\ :sub:`0`
      - Cr\ :sub:`4`
      - Cr\ :sub:`3`
      - Cr\ :sub:`2`
      - Cr\ :sub:`1`
      - Cr\ :sub:`0`

      - Y'\ :sub:`4`
      - Y'\ :sub:`3`
      - Y'\ :sub:`2`
      - Y'\ :sub:`1`
      - Y'\ :sub:`0`
      - Cb\ :sub:`5`
      - Cb\ :sub:`4`
      - Cb\ :sub:`3`

.. raw:: latex

    \endgroup

.. note::

    For the YUV444 and YUV555 formats, the value of alpha bits is undefined
    when reading from the driver, ignored when writing to the driver, except
    when alpha blending has been negotiated for a :ref:`Video Overlay
    <overlay>` or :ref:`Video Output Overlay <osd>`.


Bảng tiếp theo liệt kê các định dạng YUV 4:4:4 được đóng gói với 8 bit cho mỗi thành phần.
Chúng được đặt tên dựa trên thứ tự của các thành phần Y, Cb và Cr được lưu trữ trong
bộ nhớ và tổng số bit trên mỗi pixel. Ví dụ: VUYX32
định dạng lưu trữ một pixel có Cr\ ZZ0000ZZ trong byte đầu tiên, Cb\ ZZ0001ZZ trong byte đầu tiên
byte thứ hai và Y'\ ZZ0002ZZ ở byte thứ ba.

.. flat-table:: Packed YUV Image Formats (8bpc)
    :header-rows: 1
    :stub-columns: 0

    * - Identifier
      - Code
      - Byte 0
      - Byte 1
      - Byte 2
      - Byte 3

    * .. _V4L2-PIX-FMT-YUV32:

      - ``V4L2_PIX_FMT_YUV32``
      - 'YUV4'

      - A\ :sub:`7-0`
      - Y'\ :sub:`7-0`
      - Cb\ :sub:`7-0`
      - Cr\ :sub:`7-0`

    * .. _V4L2-PIX-FMT-AYUV32:

      - ``V4L2_PIX_FMT_AYUV32``
      - 'AYUV'

      - A\ :sub:`7-0`
      - Y'\ :sub:`7-0`
      - Cb\ :sub:`7-0`
      - Cr\ :sub:`7-0`

    * .. _V4L2-PIX-FMT-XYUV32:

      - ``V4L2_PIX_FMT_XYUV32``
      - 'XYUV'

      - X\ :sub:`7-0`
      - Y'\ :sub:`7-0`
      - Cb\ :sub:`7-0`
      - Cr\ :sub:`7-0`

    * .. _V4L2-PIX-FMT-VUYA32:

      - ``V4L2_PIX_FMT_VUYA32``
      - 'VUYA'

      - Cr\ :sub:`7-0`
      - Cb\ :sub:`7-0`
      - Y'\ :sub:`7-0`
      - A\ :sub:`7-0`

    * .. _V4L2-PIX-FMT-VUYX32:

      - ``V4L2_PIX_FMT_VUYX32``
      - 'VUYX'

      - Cr\ :sub:`7-0`
      - Cb\ :sub:`7-0`
      - Y'\ :sub:`7-0`
      - X\ :sub:`7-0`

    * .. _V4L2-PIX-FMT-YUVA32:

      - ``V4L2_PIX_FMT_YUVA32``
      - 'YUVA'

      - Y'\ :sub:`7-0`
      - Cb\ :sub:`7-0`
      - Cr\ :sub:`7-0`
      - A\ :sub:`7-0`

    * .. _V4L2-PIX-FMT-YUVX32:

      - ``V4L2_PIX_FMT_YUVX32``
      - 'YUVX'

      - Y'\ :sub:`7-0`
      - Cb\ :sub:`7-0`
      - Cr\ :sub:`7-0`
      - X\ :sub:`7-0`

    * .. _V4L2-PIX-FMT-YUV24:

      - ``V4L2_PIX_FMT_YUV24``
      - 'YUV3'

      - Y'\ :sub:`7-0`
      - Cb\ :sub:`7-0`
      - Cr\ :sub:`7-0`
      - -\

.. note::

    - The alpha component is expected to contain a meaningful value that can be
      used by drivers and applications.
    - The padding bits contain undefined values that must be ignored by all
      applications and drivers.

Bảng tiếp theo liệt kê các định dạng YUV 4:4:4 được đóng gói với 12 bit cho mỗi thành phần.
Mở rộng số bit trên mỗi thành phần lên 16 bit, dữ liệu ở bit cao, số 0 ở bit thấp,
được sắp xếp theo thứ tự endian nhỏ, lưu trữ 1 pixel trong 6 byte.

.. flat-table:: Packed YUV 4:4:4 Image Formats (12bpc)
    :header-rows: 1
    :stub-columns: 0

    * - Identifier
      - Code
      - Byte 1-0
      - Byte 3-2
      - Byte 5-4
      - Byte 7-6
      - Byte 9-8
      - Byte 11-10

    * .. _V4L2-PIX-FMT-YUV48-12:

      - ``V4L2_PIX_FMT_YUV48_12``
      - 'Y312'

      - Y'\ :sub:`0`
      - Cb\ :sub:`0`
      - Cr\ :sub:`0`
      - Y'\ :sub:`1`
      - Cb\ :sub:`1`
      - Cr\ :sub:`1`

Lấy mẫu con 4:2:2
=================

Các định dạng này, thường được gọi là YUYV hoặc YUY2, lấy mẫu màu
các thành phần theo chiều ngang bằng 2, lưu trữ 2 pixel trong một thùng chứa. thùng chứa
là 32 bit cho định dạng 8 bit và 64 bit cho định dạng 10 bit trở lên.

Các định dạng YUYV được đóng gói với hơn 8 bit cho mỗi thành phần được lưu trữ dưới dạng bốn
Từ nhỏ 16-bit. Các bit quan trọng nhất của mỗi từ chứa một
thành phần và các bit có ý nghĩa nhỏ nhất là phần đệm bằng 0.

.. raw:: latex

    \footnotesize

.. tabularcolumns:: |p{3.4cm}|p{1.2cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|

.. flat-table:: Packed YUV 4:2:2 Formats in 32-bit container
    :header-rows: 1
    :stub-columns: 0

    * - Identifier
      - Code
      - Byte 0
      - Byte 1
      - Byte 2
      - Byte 3
      - Byte 4
      - Byte 5
      - Byte 6
      - Byte 7
    * .. _V4L2-PIX-FMT-UYVY:

      - ``V4L2_PIX_FMT_UYVY``
      - 'UYVY'

      - Cb\ :sub:`0`
      - Y'\ :sub:`0`
      - Cr\ :sub:`0`
      - Y'\ :sub:`1`
      - Cb\ :sub:`2`
      - Y'\ :sub:`2`
      - Cr\ :sub:`2`
      - Y'\ :sub:`3`
    * .. _V4L2-PIX-FMT-VYUY:

      - ``V4L2_PIX_FMT_VYUY``
      - 'VYUY'

      - Cr\ :sub:`0`
      - Y'\ :sub:`0`
      - Cb\ :sub:`0`
      - Y'\ :sub:`1`
      - Cr\ :sub:`2`
      - Y'\ :sub:`2`
      - Cb\ :sub:`2`
      - Y'\ :sub:`3`
    * .. _V4L2-PIX-FMT-YUYV:

      - ``V4L2_PIX_FMT_YUYV``
      - 'YUYV'

      - Y'\ :sub:`0`
      - Cb\ :sub:`0`
      - Y'\ :sub:`1`
      - Cr\ :sub:`0`
      - Y'\ :sub:`2`
      - Cb\ :sub:`2`
      - Y'\ :sub:`3`
      - Cr\ :sub:`2`
    * .. _V4L2-PIX-FMT-YVYU:

      - ``V4L2_PIX_FMT_YVYU``
      - 'YVYU'

      - Y'\ :sub:`0`
      - Cr\ :sub:`0`
      - Y'\ :sub:`1`
      - Cb\ :sub:`0`
      - Y'\ :sub:`2`
      - Cr\ :sub:`2`
      - Y'\ :sub:`3`
      - Cb\ :sub:`2`

.. tabularcolumns:: |p{3.4cm}|p{1.2cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|p{0.8cm}|

.. flat-table:: Packed YUV 4:2:2 Formats in 64-bit container
    :header-rows: 1
    :stub-columns: 0

    * - Identifier
      - Code
      - Word 0
      - Word 1
      - Word 2
      - Word 3
    * .. _V4L2-PIX-FMT-Y210:

      - ``V4L2_PIX_FMT_Y210``
      - 'Y210'

      - Y'\ :sub:`0` (bits 15-6)
      - Cb\ :sub:`0` (bits 15-6)
      - Y'\ :sub:`1` (bits 15-6)
      - Cr\ :sub:`0` (bits 15-6)
    * .. _V4L2-PIX-FMT-Y212:

      - ``V4L2_PIX_FMT_Y212``
      - 'Y212'

      - Y'\ :sub:`0` (bits 15-4)
      - Cb\ :sub:`0` (bits 15-4)
      - Y'\ :sub:`1` (bits 15-4)
      - Cr\ :sub:`0` (bits 15-4)
    * .. _V4L2-PIX-FMT-Y216:

      - ``V4L2_PIX_FMT_Y216``
      - 'Y216'

      - Y'\ :sub:`0` (bits 15-0)
      - Cb\ :sub:`0` (bits 15-0)
      - Y'\ :sub:`1` (bits 15-0)
      - Cr\ :sub:`0` (bits 15-0)

.. raw:: latex

    \normalsize

ZZ0001ZZ
Mẫu sắc độ là ZZ0000ZZ
theo chiều ngang.


Lấy mẫu con 4:1:1
=================

Định dạng này lấy mẫu con các thành phần sắc độ theo chiều ngang bằng 4, lưu trữ 8
pixel trong 12 byte.

.. raw:: latex

    \scriptsize

.. tabularcolumns:: |p{2.9cm}|p{0.8cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|p{0.5cm}|

.. flat-table:: Packed YUV 4:1:1 Formats
    :header-rows: 1
    :stub-columns: 0

    * - Identifier
      - Code
      - Byte 0
      - Byte 1
      - Byte 2
      - Byte 3
      - Byte 4
      - Byte 5
      - Byte 6
      - Byte 7
      - Byte 8
      - Byte 9
      - Byte 10
      - Byte 11
    * .. _V4L2-PIX-FMT-Y41P:

      - ``V4L2_PIX_FMT_Y41P``
      - 'Y41P'

      - Cb\ :sub:`0`
      - Y'\ :sub:`0`
      - Cr\ :sub:`0`
      - Y'\ :sub:`1`
      - Cb\ :sub:`4`
      - Y'\ :sub:`2`
      - Cr\ :sub:`4`
      - Y'\ :sub:`3`
      - Y'\ :sub:`4`
      - Y'\ :sub:`5`
      - Y'\ :sub:`6`
      - Y'\ :sub:`7`

.. raw:: latex

    \normalsize

.. note::

    Do not confuse ``V4L2_PIX_FMT_Y41P`` with
    :ref:`V4L2_PIX_FMT_YUV411P <V4L2-PIX-FMT-YUV411P>`. Y41P is derived from
    "YUV 4:1:1 **packed**", while YUV411P stands for "YUV 4:1:1 **planar**".

ZZ0001ZZ
Mẫu sắc độ là ZZ0000ZZ
theo chiều ngang.