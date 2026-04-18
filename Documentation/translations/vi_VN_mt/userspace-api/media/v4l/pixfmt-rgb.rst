.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-rgb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _pixfmt-rgb:

*************
Định dạng RGB
*************

Các định dạng này mã hóa từng pixel dưới dạng bộ ba giá trị RGB. Chúng được đóng gói
định dạng, nghĩa là các giá trị RGB cho một pixel được lưu trữ liên tiếp trong
bộ nhớ và mỗi pixel tiêu thụ một số nguyên byte. Khi số lượng
các bit cần thiết để lưu trữ một pixel không được căn chỉnh theo ranh giới byte, dữ liệu được
được đệm thêm các bit để lấp đầy byte còn lại.

Các định dạng khác nhau về số bit trên mỗi thành phần RGB (thông thường nhưng không
luôn giống nhau đối với tất cả các thành phần), thứ tự của các thành phần trong bộ nhớ và
sự hiện diện của thành phần alpha hoặc các bit đệm bổ sung.

Cách sử dụng và giá trị của các bit alpha trong các định dạng hỗ trợ chúng (được đặt tên là ARGB
hoặc một hoán vị của chúng, gọi chung là định dạng alpha) phụ thuộc vào
loại thiết bị và hoạt động của phần cứng. Thiết bị ZZ0000ZZ
(bao gồm hàng đợi chụp của thiết bị mem-to-mem) điền thành phần alpha vào
trí nhớ. Khi thiết bị bắt được kênh alpha, thành phần alpha sẽ có
một giá trị có ý nghĩa. Ngược lại, khi thiết bị không thu được kênh alpha
nhưng có thể đặt bit alpha thành giá trị do người dùng định cấu hình,
Điều khiển ZZ0001ZZ được sử dụng để
chỉ định giá trị alpha đó và thành phần alpha của tất cả các pixel sẽ được đặt thành
giá trị được chỉ định bởi điều khiển đó. Nếu không thì một định dạng tương ứng không có
phải sử dụng thành phần alpha (XRGB hoặc XBGR) thay vì định dạng alpha.

Thiết bị ZZ0000ZZ (bao gồm hàng đợi đầu ra của thiết bị mem-to-mem
và thiết bị ZZ0001ZZ) đọc thành phần alpha từ
trí nhớ. Khi thiết bị xử lý kênh alpha, thành phần alpha phải được
chứa đầy các giá trị có ý nghĩa bởi các ứng dụng. Nếu không thì một định dạng tương ứng
không có thành phần alpha (XRGB hoặc XBGR) phải được sử dụng thay vì thành phần alpha
định dạng.

Các định dạng chứa bit đệm được đặt tên là XRGB (hoặc hoán vị của nó).
Các bit đệm chứa các giá trị không xác định và phải được các ứng dụng bỏ qua,
thiết bị và trình điều khiển cho cả thiết bị ZZ0000ZZ và ZZ0001ZZ.

.. note::

   - In all the tables that follow, bit 7 is the most significant bit in a byte.
   - 'r', 'g' and 'b' denote bits of the red, green and blue components
     respectively. 'a' denotes bits of the alpha component (if supported by the
     format), and 'x' denotes padding bits.


Ít hơn 8 bit cho mỗi thành phần
===============================

Các định dạng này lưu trữ bộ ba RGB trong một, hai hoặc bốn byte. Họ được đặt tên
dựa trên thứ tự của các thành phần RGB như được thấy trong từ 8, 16 hoặc 32 bit,
sau đó được lưu trữ trong bộ nhớ theo thứ tự byte endian nhỏ (trừ khi có cách khác
được ghi nhận bởi sự hiện diện của bit 31 trong giá trị 4CC) và số lượng bit
cho từng thành phần. Ví dụ: định dạng RGB565 lưu trữ một pixel ở dạng 16 bit
từ [15:0] được trình bày ở dạng [R\ ZZ0000ZZ R\ ZZ0001ZZ R\ ZZ0002ZZ R\ ZZ0003ZZ
R\ ZZ0004ZZ G\ ZZ0005ZZ G\ ZZ0006ZZ G\ ZZ0007ZZ G\ ZZ0008ZZ G\ ZZ0009ZZ
G\ ZZ0010ZZ B\ ZZ0011ZZ B\ ZZ0012ZZ B\ ZZ0013ZZ B\ ZZ0014ZZ B\ ZZ0015ZZ] và
được lưu trữ trong bộ nhớ ở dạng hai byte, [R\ ZZ0016ZZ R\ ZZ0017ZZ R\ ZZ0018ZZ R\ ZZ0019ZZ
R\ ZZ0020ZZ G\ ZZ0021ZZ G\ ZZ0022ZZ G\ ZZ0023ZZ] theo sau là [G\ ZZ0024ZZ
G\ ZZ0025ZZ G\ ZZ0026ZZ B\ ZZ0027ZZ B\ ZZ0028ZZ B\ ZZ0029ZZ B\ ZZ0030ZZ
B\ZZ0031ZZ].

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{2.8cm}|p{2.0cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|


.. flat-table:: RGB Formats With Less Than 8 Bits Per Component
    :header-rows:  2
    :stub-columns: 0

    * - Identifier
      - Code
      - :cspan:`7` Byte 0 in memory
      - :cspan:`7` Byte 1
      - :cspan:`7` Byte 2
      - :cspan:`7` Byte 3
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
    * .. _V4L2-PIX-FMT-RGB332:

      - ``V4L2_PIX_FMT_RGB332``
      - 'RGB1'

      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`1`
      - b\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-ARGB444:

      - ``V4L2_PIX_FMT_ARGB444``
      - 'AR12'

      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-XRGB444:

      - ``V4L2_PIX_FMT_XRGB444``
      - 'XR12'

      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

      - x
      - x
      - x
      - x
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-RGBA444:

      - ``V4L2_PIX_FMT_RGBA444``
      - 'RA12'

      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`

      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-RGBX444:

      - ``V4L2_PIX_FMT_RGBX444``
      - 'RX12'

      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - x
      - x
      - x
      - x

      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-ABGR444:

      - ``V4L2_PIX_FMT_ABGR444``
      - 'AB12'

      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`

      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-XBGR444:

      - ``V4L2_PIX_FMT_XBGR444``
      - 'XB12'

      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`

      - x
      - x
      - x
      - x
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-BGRA444:

      - ``V4L2_PIX_FMT_BGRA444``
      - 'BA12'

      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`

      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-BGRX444:

      - ``V4L2_PIX_FMT_BGRX444``
      - 'BX12'

      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - x
      - x
      - x
      - x

      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-ARGB555:

      - ``V4L2_PIX_FMT_ARGB555``
      - 'AR15'

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

      - a
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
      -
    * .. _V4L2-PIX-FMT-XRGB555:

      - ``V4L2_PIX_FMT_XRGB555``
      - 'XR15'

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

      - x
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
      -
    * .. _V4L2-PIX-FMT-RGBA555:

      - ``V4L2_PIX_FMT_RGBA555``
      - 'RA15'

      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - a

      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      -
    * .. _V4L2-PIX-FMT-RGBX555:

      - ``V4L2_PIX_FMT_RGBX555``
      - 'RX15'

      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - x

      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      -
    * .. _V4L2-PIX-FMT-ABGR555:

      - ``V4L2_PIX_FMT_ABGR555``
      - 'AB15'

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`

      - a
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
      -
    * .. _V4L2-PIX-FMT-XBGR555:

      - ``V4L2_PIX_FMT_XBGR555``
      - 'XB15'

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`

      - x
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
      -
    * .. _V4L2-PIX-FMT-BGRA555:

      - ``V4L2_PIX_FMT_BGRA555``
      - 'BA15'

      - g\ :sub:`1`
      - g\ :sub:`0`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - a

      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      -
    * .. _V4L2-PIX-FMT-BGRX555:

      - ``V4L2_PIX_FMT_BGRX555``
      - 'BX15'

      - g\ :sub:`1`
      - g\ :sub:`0`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - x

      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      -
    * .. _V4L2-PIX-FMT-RGB565:

      - ``V4L2_PIX_FMT_RGB565``
      - 'RGBP'

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      -
    * .. _V4L2-PIX-FMT-ARGB555X:

      - ``V4L2_PIX_FMT_ARGB555X``
      - 'AR15' | (1 << 31)

      - a
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-XRGB555X:

      - ``V4L2_PIX_FMT_XRGB555X``
      - 'XR15' | (1 << 31)

      - x
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-RGB565X:

      - ``V4L2_PIX_FMT_RGB565X``
      - 'RGBR'

      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-BGR666:

      - ``V4L2_PIX_FMT_BGR666``
      - 'BGRH'

      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - g\ :sub:`5`
      - g\ :sub:`4`

      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`

      - r\ :sub:`1`
      - r\ :sub:`0`
      - x
      - x
      - x
      - x
      - x
      - x

      - x
      - x
      - x
      - x
      - x
      - x
      - x
      - x

.. raw:: latex

    \endgroup


8 bit cho mỗi thành phần
========================

Các định dạng này lưu trữ bộ ba RGB trong ba hoặc bốn byte. Chúng được đặt tên dựa
theo thứ tự của các thành phần RGB được lưu trong bộ nhớ và trên tổng số
số bit trên mỗi pixel. Ví dụ: định dạng RGB24 lưu trữ một pixel có [R\ ZZ0000ZZ
R\ ZZ0001ZZ R\ ZZ0002ZZ R\ ZZ0003ZZ R\ ZZ0004ZZ R\ ZZ0005ZZ R\ ZZ0006ZZ
R\ ZZ0007ZZ] trong byte đầu tiên, [G\ ZZ0008ZZ G\ ZZ0009ZZ G\ ZZ0010ZZ G\ ZZ0011ZZ
G\ ZZ0012ZZ G\ ZZ0013ZZ G\ ZZ0014ZZ G\ ZZ0015ZZ] trong byte thứ hai và
[B\ ZZ0016ZZ B\ ZZ0017ZZ B\ ZZ0018ZZ B\ ZZ0019ZZ B\ ZZ0020ZZ B\ ZZ0021ZZ
B\ ZZ0022ZZ B\ ZZ0023ZZ] ở byte thứ ba. Điều này khác với định dạng DRM
danh pháp thay vào đó sử dụng thứ tự của các thành phần như được thấy trong 24- hoặc
Từ endian nhỏ 32-bit.

.. raw:: latex

    \small

.. flat-table:: RGB Formats With 8 Bits Per Component
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Code
      - Byte 0 in memory
      - Byte 1
      - Byte 2
      - Byte 3
    * .. _V4L2-PIX-FMT-BGR24:

      - ``V4L2_PIX_FMT_BGR24``
      - 'BGR3'

      - B\ :sub:`7-0`
      - G\ :sub:`7-0`
      - R\ :sub:`7-0`
      -
    * .. _V4L2-PIX-FMT-RGB24:

      - ``V4L2_PIX_FMT_RGB24``
      - 'RGB3'

      - R\ :sub:`7-0`
      - G\ :sub:`7-0`
      - B\ :sub:`7-0`
      -
    * .. _V4L2-PIX-FMT-ABGR32:

      - ``V4L2_PIX_FMT_ABGR32``
      - 'AR24'

      - B\ :sub:`7-0`
      - G\ :sub:`7-0`
      - R\ :sub:`7-0`
      - A\ :sub:`7-0`
    * .. _V4L2-PIX-FMT-XBGR32:

      - ``V4L2_PIX_FMT_XBGR32``
      - 'XR24'

      - B\ :sub:`7-0`
      - G\ :sub:`7-0`
      - R\ :sub:`7-0`
      - X\ :sub:`7-0`
    * .. _V4L2-PIX-FMT-BGRA32:

      - ``V4L2_PIX_FMT_BGRA32``
      - 'RA24'

      - A\ :sub:`7-0`
      - B\ :sub:`7-0`
      - G\ :sub:`7-0`
      - R\ :sub:`7-0`
    * .. _V4L2-PIX-FMT-BGRX32:

      - ``V4L2_PIX_FMT_BGRX32``
      - 'RX24'

      - X\ :sub:`7-0`
      - B\ :sub:`7-0`
      - G\ :sub:`7-0`
      - R\ :sub:`7-0`
    * .. _V4L2-PIX-FMT-RGBA32:

      - ``V4L2_PIX_FMT_RGBA32``
      - 'AB24'

      - R\ :sub:`7-0`
      - G\ :sub:`7-0`
      - B\ :sub:`7-0`
      - A\ :sub:`7-0`
    * .. _V4L2-PIX-FMT-RGBX32:

      - ``V4L2_PIX_FMT_RGBX32``
      - 'XB24'

      - R\ :sub:`7-0`
      - G\ :sub:`7-0`
      - B\ :sub:`7-0`
      - X\ :sub:`7-0`
    * .. _V4L2-PIX-FMT-ARGB32:

      - ``V4L2_PIX_FMT_ARGB32``
      - 'BA24'

      - A\ :sub:`7-0`
      - R\ :sub:`7-0`
      - G\ :sub:`7-0`
      - B\ :sub:`7-0`
    * .. _V4L2-PIX-FMT-XRGB32:

      - ``V4L2_PIX_FMT_XRGB32``
      - 'BX24'

      - X\ :sub:`7-0`
      - R\ :sub:`7-0`
      - G\ :sub:`7-0`
      - B\ :sub:`7-0`

.. raw:: latex

    \normalsize


10 bit cho mỗi thành phần
=========================

Các định dạng này lưu trữ bộ ba RGB 30 bit với alpha 2 bit tùy chọn trong bốn
byte. Chúng được đặt tên dựa trên thứ tự của các thành phần RGB như được thấy trong
Từ 32 bit, sau đó được lưu trong bộ nhớ theo thứ tự byte endian nhỏ
(trừ khi có ghi chú khác bởi sự hiện diện của bit 31 trong giá trị 4CC) và trên
số bit cho mỗi thành phần.

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{3.2cm}|p{0.8cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|


.. flat-table:: RGB Formats 10 Bits Per Color Component
    :header-rows:  2
    :stub-columns: 0

    * - Identifier
      - Code
      - :cspan:`7` Byte 0 in memory
      - :cspan:`7` Byte 1
      - :cspan:`7` Byte 2
      - :cspan:`7` Byte 3
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
    * .. _V4L2-PIX-FMT-RGBX1010102:

      - ``V4L2_PIX_FMT_RGBX1010102``
      - 'RX30'

      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - x
      - x

      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`9`
      - b\ :sub:`8`
      - b\ :sub:`7`
      - b\ :sub:`6`

      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`

      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
    * .. _V4L2-PIX-FMT-RGBA1010102:

      - ``V4L2_PIX_FMT_RGBA1010102``
      - 'RA30'

      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - a\ :sub:`1`
      - a\ :sub:`0`

      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`9`
      - b\ :sub:`8`
      - b\ :sub:`7`
      - b\ :sub:`6`

      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`

      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
    * .. _V4L2-PIX-FMT-ARGB2101010:

      - ``V4L2_PIX_FMT_ARGB2101010``
      - 'AR30'

      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`9`
      - b\ :sub:`8`

      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`

      - a\ :sub:`1`
      - a\ :sub:`0`
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`

.. raw:: latex

    \endgroup

12 bit cho mỗi thành phần
==============================

Các định dạng này lưu trữ bộ ba RGB trong sáu hoặc tám byte, với 12 bit cho mỗi thành phần.
Mở rộng số bit trên mỗi thành phần lên 16 bit, dữ liệu ở bit cao, số 0 ở bit thấp,
sắp xếp theo thứ tự endian nhỏ.

.. raw:: latex

    \small

.. flat-table:: RGB Formats With 12 Bits Per Component
    :header-rows:  1

    * - Identifier
      - Code
      - Byte 1-0
      - Byte 3-2
      - Byte 5-4
      - Byte 7-6
    * .. _V4L2-PIX-FMT-BGR48-12:

      - ``V4L2_PIX_FMT_BGR48_12``
      - 'B312'

      - B\ :sub:`15-4`
      - G\ :sub:`15-4`
      - R\ :sub:`15-4`
      -
    * .. _V4L2-PIX-FMT-ABGR64-12:

      - ``V4L2_PIX_FMT_ABGR64_12``
      - 'B412'

      - B\ :sub:`15-4`
      - G\ :sub:`15-4`
      - R\ :sub:`15-4`
      - A\ :sub:`15-4`

.. raw:: latex

    \normalsize

16 bit cho mỗi thành phần
=========================

Các định dạng này lưu trữ bộ ba RGB trong sáu byte, với 16 bit cho mỗi thành phần
được lưu trữ trong bộ nhớ theo thứ tự byte endian nhỏ. Chúng được đặt tên dựa trên thứ tự
của các thành phần RGB được lưu trữ trong bộ nhớ. Chẳng hạn, RGB48 lưu trữ R\
ZZ0000ZZ và R\ ZZ0001ZZ lần lượt ở byte 0 và 1. Điều này khác với
danh pháp định dạng DRM thay vào đó sử dụng thứ tự các thành phần như được thấy trong
từ cuối nhỏ 48-bit.

.. raw:: latex

    \small

.. flat-table:: RGB Formats With 16 Bits Per Component
    :header-rows:  1

    * - Identifier
      - Code
      - Byte 0
      - Byte 1
      - Byte 2
      - Byte 3
      - Byte 4
      - Byte 5

    * .. _V4L2-PIX-FMT-BGR48:

      - ``V4L2_PIX_FMT_BGR48``
      - 'BGR6'

      - B\ :sub:`7-0`
      - B\ :sub:`15-8`
      - G\ :sub:`7-0`
      - G\ :sub:`15-8`
      - R\ :sub:`7-0`
      - R\ :sub:`15-8`

    * .. _V4L2-PIX-FMT-RGB48:

      - ``V4L2_PIX_FMT_RGB48``
      - 'RGB6'

      - R\ :sub:`7-0`
      - R\ :sub:`15-8`
      - G\ :sub:`7-0`
      - G\ :sub:`15-8`
      - B\ :sub:`7-0`
      - B\ :sub:`15-8`

.. raw:: latex

    \normalsize

Định dạng RGB không được dùng nữa
=================================

Các định dạng được xác định trong ZZ0000ZZ không được dùng nữa và không được
được sử dụng bởi trình điều khiển mới. Chúng được ghi lại ở đây để tham khảo. Ý nghĩa của
các bit alpha ZZ0001ZZ của chúng không được xác định rõ ràng và chúng được hiểu theo một trong hai cách sau:
định dạng ARGB hoặc XRGB tương ứng, tùy thuộc vào trình điều khiển.

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{2.6cm}|p{0.70cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _pixfmt-rgb-deprecated:

.. flat-table:: Deprecated Packed RGB Image Formats
    :header-rows:  2
    :stub-columns: 0

    * - Identifier
      - Code
      - :cspan:`7` Byte 0 in memory

      - :cspan:`7` Byte 1

      - :cspan:`7` Byte 2

      - :cspan:`7` Byte 3
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
    * .. _V4L2-PIX-FMT-RGB444:

      - ``V4L2_PIX_FMT_RGB444``
      - 'R444'

      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-RGB555:

      - ``V4L2_PIX_FMT_RGB555``
      - 'RGBO'

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

      - a
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
      -
    * .. _V4L2-PIX-FMT-RGB555X:

      - ``V4L2_PIX_FMT_RGB555X``
      - 'RGBQ'

      - a
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`

      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      -
    * .. _V4L2-PIX-FMT-BGR32:

      - ``V4L2_PIX_FMT_BGR32``
      - 'BGR4'

      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`

      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`

      - a\ :sub:`7`
      - a\ :sub:`6`
      - a\ :sub:`5`
      - a\ :sub:`4`
      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`
    * .. _V4L2-PIX-FMT-RGB32:

      - ``V4L2_PIX_FMT_RGB32``
      - 'RGB4'

      - a\ :sub:`7`
      - a\ :sub:`6`
      - a\ :sub:`5`
      - a\ :sub:`4`
      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`

      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`

      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`

      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`

.. raw:: latex

    \endgroup

Tiện ích kiểm tra để xác định định dạng RGB nào mà trình điều khiển thực sự hỗ trợ
có sẵn từ kho lưu trữ LinuxTV v4l-dvb. Xem
ZZ0000ZZ để truy cập
hướng dẫn.