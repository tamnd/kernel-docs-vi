.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/colorspaces-details.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

********************************
Mô tả chi tiết về không gian màu
********************************


.. _col-smpte-170m:

Không gian màu SMPTE 170M (V4L2_COLORSPACE_SMPTE170M)
=================================================

Tiêu chuẩn ZZ0000ZZ xác định không gian màu được sử dụng bởi NTSC và
PAL và SDTV nói chung. Hàm truyền mặc định là
ZZ0001ZZ. Mã hóa Y'CbCr mặc định là
ZZ0002ZZ. Lượng tử hóa Y'CbCr mặc định bị hạn chế
phạm vi. Màu sắc của màu cơ bản và màu trắng tham chiếu
là:

.. flat-table:: SMPTE 170M Chromaticities
    :header-rows:  1
    :stub-columns: 0
    :widths:       1 1 2

    * - Color
      - x
      - y
    * - Red
      - 0.630
      - 0.340
    * - Green
      - 0.310
      - 0.595
    * - Blue
      - 0.155
      - 0.070
    * - White Reference (D65)
      - 0.3127
      - 0.3290


Các màu sắc đỏ, lục và lam cũng thường được gọi là
Bộ SMPTE C nên không gian màu này đôi khi còn được gọi là SMPTE C.

Hàm truyền được xác định cho SMPTE 170M giống như hàm truyền
được xác định trong Rec. 709.

.. math::

    L' = -1.099(-L)^{0.45} + 0.099 \text{, for } L \le-0.018

    L' = 4.5L \text{, for } -0.018 < L < 0.018

    L' = 1.099L^{0.45} - 0.099 \text{, for } L \ge 0.018

Hàm chuyển nghịch đảo:

.. math::

    L = -\left( \frac{L' - 0.099}{-1.099} \right) ^{\frac{1}{0.45}} \text{, for } L' \le -0.081

    L = \frac{L'}{4.5} \text{, for } -0.081 < L' < 0.081

    L = \left(\frac{L' + 0.099}{1.099}\right)^{\frac{1}{0.45} } \text{, for } L' \ge 0.081

Độ chói (Y') và độ chênh lệch màu (Cb và Cr) thu được bằng
mã hóa ZZ0000ZZ sau:

.. math::

    Y' = 0.2990R' + 0.5870G' + 0.1140B'

    Cb = -0.1687R' - 0.3313G' + 0.5B'

    Cr = 0.5R' - 0.4187G' - 0.0813B'

Y' được kẹp trong phạm vi [0…1] và Cb và Cr được kẹp trong phạm vi
[-0,5…0,5]. Việc chuyển đổi sang Y'CbCr này giống hệt với chuyển đổi được xác định trong
tiêu chuẩn ZZ0000ZZ và không gian màu này đôi khi được gọi là
BT.601 cũng vậy, mặc dù BT.601 không đề cập đến bất kỳ màu cơ bản nào.

Lượng tử hóa mặc định là phạm vi giới hạn, nhưng có thể phạm vi đầy đủ
mặc dù hiếm thấy.


.. _col-rec709:

Không gian màu Rec. 709 (V4L2_COLORSPACE_REC709)
============================================

Tiêu chuẩn ZZ0000ZZ xác định không gian màu được HDTV sử dụng trong
chung. Chức năng truyền mặc định là ZZ0001ZZ. các
Mã hóa Y'CbCr mặc định là ZZ0002ZZ. Y'CbCr mặc định
lượng tử hóa là phạm vi hạn chế. Sắc độ của các màu cơ bản
và tham chiếu màu trắng là:

.. flat-table:: Rec. 709 Chromaticities
    :header-rows:  1
    :stub-columns: 0
    :widths:       1 1 2

    * - Color
      - x
      - y
    * - Red
      - 0.640
      - 0.330
    * - Green
      - 0.300
      - 0.600
    * - Blue
      - 0.150
      - 0.060
    * - White Reference (D65)
      - 0.3127
      - 0.3290


Tên đầy đủ của tiêu chuẩn này là Rec. ITU-R BT.709-5.

Chức năng chuyển giao. Thông thường L nằm trong khoảng [0…1], nhưng đối với
cho phép các giá trị mã hóa gam màu xvYCC mở rộng ngoài phạm vi đó.

.. math::

    L' = -1.099(-L)^{0.45} + 0.099 \text{, for } L \le -0.018

    L' = 4.5L \text{, for } -0.018 < L < 0.018

    L' = 1.099L^{0.45} - 0.099 \text{, for } L \ge 0.018

Hàm chuyển nghịch đảo:

.. math::

    L = -\left( \frac{L' - 0.099}{-1.099} \right)^\frac{1}{0.45} \text{, for } L' \le -0.081

    L = \frac{L'}{4.5}\text{, for } -0.081 < L' < 0.081

    L = \left(\frac{L' + 0.099}{1.099}\right)^{\frac{1}{0.45} } \text{, for } L' \ge 0.081

Độ chói (Y') và độ chênh lệch màu (Cb và Cr) thu được bằng
mã hóa ZZ0000ZZ sau:

.. math::

    Y' = 0.2126R' + 0.7152G' + 0.0722B'

    Cb = -0.1146R' - 0.3854G' + 0.5B'

    Cr = 0.5R' - 0.4542G' - 0.0458B'

Y' được kẹp trong phạm vi [0…1] và Cb và Cr được kẹp trong phạm vi
[-0,5…0,5].

Lượng tử hóa mặc định là phạm vi giới hạn, nhưng có thể phạm vi đầy đủ
mặc dù hiếm thấy.

Mã hóa ZZ0000ZZ được mô tả ở trên là mặc định cho
không gian màu này, nhưng nó có thể được ghi đè bằng ZZ0001ZZ,
trong trường hợp đó mã hóa BT.601 Y'CbCr được sử dụng.

Hai mã hóa gam màu Y'CbCr mở rộng bổ sung cũng có thể được thực hiện với
không gian màu này:

Mã hóa xvYCC 709 (ZZ0001ZZ, ZZ0000ZZ) là
tương tự như Rec. Mã hóa 709, nhưng nó cho phép các giá trị R', G' và B'
nằm ngoài phạm vi [0…1]. Các giá trị Y', Cb và Cr thu được là
được chia tỷ lệ và bù theo công thức phạm vi giới hạn:

.. math::

    Y' = \frac{219}{256} * (0.2126R' + 0.7152G' + 0.0722B') + \frac{16}{256}

    Cb = \frac{224}{256} * (-0.1146R' - 0.3854G' + 0.5B')

    Cr = \frac{224}{256} * (0.5R' - 0.4542G' - 0.0458B')

Mã hóa xvYCC 601 (ZZ0001ZZ, ZZ0000ZZ) là
tương tự như mã hóa BT.601, nhưng nó cho phép các giá trị R', G' và B'
nằm ngoài phạm vi [0…1]. Các giá trị Y', Cb và Cr thu được là
được chia tỷ lệ và bù theo công thức phạm vi giới hạn:

.. math::

    Y' = \frac{219}{256} * (0.2990R' + 0.5870G' + 0.1140B') + \frac{16}{256}

    Cb = \frac{224}{256} * (-0.1687R' - 0.3313G' + 0.5B')

    Cr = \frac{224}{256} * (0.5R' - 0.4187G' - 0.0813B')

Y' được kẹp trong phạm vi [0…1] và Cb và Cr được kẹp trong phạm vi
[-0,5…0,5] và được lượng tử hóa mà không cần chia tỷ lệ hoặc bù thêm.
Mã hóa xvYCC 709 hoặc xvYCC 601 không chuẩn có thể
được sử dụng bằng cách chọn ZZ0000ZZ hoặc ZZ0001ZZ.
Như đã thấy trong các công thức xvYCC, các mã hóa này luôn sử dụng lượng tử hóa phạm vi giới hạn,
không có biến thể đầy đủ. Toàn bộ mục đích của việc mã hóa gam màu mở rộng này
là các giá trị nằm ngoài phạm vi giới hạn vẫn hợp lệ, mặc dù chúng
ánh xạ tới các giá trị R', G' và B' nằm ngoài phạm vi [0…1] và do đó nằm ngoài
Rec. Gam màu không gian 709.


.. _col-srgb:

Không gian màu sRGB (V4L2_COLORSPACE_SRGB)
======================================

Tiêu chuẩn ZZ0000ZZ xác định không gian màu được hầu hết các webcam sử dụng
và đồ họa máy tính. Hàm truyền mặc định là
ZZ0001ZZ. Mã hóa Y'CbCr mặc định là
ZZ0002ZZ. Lượng tử hóa Y'CbCr mặc định có phạm vi giới hạn.

Lưu ý rằng tiêu chuẩn ZZ0000ZZ chỉ định lượng tử hóa toàn dải,
tuy nhiên tất cả phần cứng chụp hiện tại được kernel hỗ trợ đều chuyển đổi
R'G'B' đến phạm vi giới hạn Y'CbCr. Vì vậy, chọn phạm vi đầy đủ làm mặc định
sẽ phá vỡ cách các ứng dụng diễn giải phạm vi lượng tử hóa.

Màu sắc của màu cơ bản và màu trắng tham chiếu là:

.. flat-table:: sRGB Chromaticities
    :header-rows:  1
    :stub-columns: 0
    :widths:       1 1 2

    * - Color
      - x
      - y
    * - Red
      - 0.640
      - 0.330
    * - Green
      - 0.300
      - 0.600
    * - Blue
      - 0.150
      - 0.060
    * - White Reference (D65)
      - 0.3127
      - 0.3290


Những màu sắc này giống hệt với Rec. Không gian màu 709.

Chức năng chuyển giao. Lưu ý rằng các giá trị âm của L chỉ được sử dụng bởi
chuyển đổi Y'CbCr.

.. math::

    L' = -1.055(-L)^{\frac{1}{2.4} } + 0.055\text{, for }L < -0.0031308

    L' = 12.92L\text{, for }-0.0031308 \le L \le 0.0031308

    L' = 1.055L ^{\frac{1}{2.4} } - 0.055\text{, for }0.0031308 < L \le 1

Hàm chuyển nghịch đảo:

.. math::

    L = -((-L' + 0.055) / 1.055) ^{2.4}\text{, for }L' < -0.04045

    L = L' / 12.92\text{, for }-0.04045 \le L' \le 0.04045

    L = ((L' + 0.055) / 1.055) ^{2.4}\text{, for }L' > 0.04045

Độ chói (Y') và độ chênh lệch màu (Cb và Cr) thu được bằng
mã hóa ZZ0001ZZ sau đây được xác định bởi ZZ0000ZZ:

.. math::

    Y' = 0.2990R' + 0.5870G' + 0.1140B'

    Cb = -0.1687R' - 0.3313G' + 0.5B'

    Cr = 0.5R' - 0.4187G' - 0.0813B'

Y' được kẹp trong phạm vi [0…1] và Cb và Cr được kẹp trong phạm vi
[-0,5…0,5]. Biến đổi này giống hệt với biến đổi được xác định trong SMPTE
170M/BT.601. Lượng tử hóa Y'CbCr có phạm vi hạn chế.


.. _col-oprgb:

Không gian màu opRGB (V4L2_COLORSPACE_OPRGB)
===============================================

Tiêu chuẩn ZZ0000ZZ xác định không gian màu được máy tính sử dụng
đồ họa sử dụng không gian màu opRGB. Hàm truyền mặc định là
ZZ0001ZZ. Mã hóa Y'CbCr mặc định là
ZZ0002ZZ. Lượng tử hóa Y'CbCr mặc định bị hạn chế
phạm vi.

Lưu ý rằng tiêu chuẩn ZZ0000ZZ chỉ định lượng tử hóa toàn dải,
tuy nhiên tất cả phần cứng chụp hiện tại được kernel hỗ trợ đều chuyển đổi
R'G'B' đến phạm vi giới hạn Y'CbCr. Vì vậy, chọn phạm vi đầy đủ làm mặc định
sẽ phá vỡ cách các ứng dụng diễn giải phạm vi lượng tử hóa.

Màu sắc của màu cơ bản và màu trắng tham chiếu là:

.. flat-table:: opRGB Chromaticities
    :header-rows:  1
    :stub-columns: 0
    :widths:       1 1 2

    * - Color
      - x
      - y
    * - Red
      - 0.6400
      - 0.3300
    * - Green
      - 0.2100
      - 0.7100
    * - Blue
      - 0.1500
      - 0.0600
    * - White Reference (D65)
      - 0.3127
      - 0.3290



Hàm chuyển:

.. math::

    L' = L ^{\frac{1}{2.19921875}}

Hàm chuyển nghịch đảo:

.. math::

    L = L'^{(2.19921875)}

Độ chói (Y') và độ chênh lệch màu (Cb và Cr) thu được bằng
mã hóa ZZ0000ZZ sau:

.. math::

    Y' = 0.2990R' + 0.5870G' + 0.1140B'

    Cb = -0.1687R' - 0.3313G' + 0.5B'

    Cr = 0.5R' - 0.4187G' - 0.0813B'

Y' được kẹp trong phạm vi [0…1] và Cb và Cr được kẹp trong phạm vi
[-0,5…0,5]. Biến đổi này giống hệt với biến đổi được xác định trong SMPTE
170M/BT.601. Lượng tử hóa Y'CbCr có phạm vi hạn chế.


.. _col-bt2020:

Không gian màu BT.2020 (V4L2_COLORSPACE_BT2020)
===========================================

Tiêu chuẩn ZZ0000ZZ xác định không gian màu được sử dụng bởi Ultra-high
truyền hình độ nét (UHDTV). Hàm truyền mặc định là
ZZ0001ZZ. Mã hóa Y'CbCr mặc định là
ZZ0002ZZ. Lượng tử hóa Y'CbCr mặc định có phạm vi giới hạn.
Màu sắc của màu cơ bản và màu trắng tham chiếu là:

.. flat-table:: BT.2020 Chromaticities
    :header-rows:  1
    :stub-columns: 0
    :widths:       1 1 2

    * - Color
      - x
      - y
    * - Red
      - 0.708
      - 0.292
    * - Green
      - 0.170
      - 0.797
    * - Blue
      - 0.131
      - 0.046
    * - White Reference (D65)
      - 0.3127
      - 0.3290



Hàm truyền (giống như Rec. 709):

.. math::

    L' = 4.5L\text{, for }0 \le L < 0.018

    L' = 1.099L ^{0.45} - 0.099\text{, for } 0.018 \le L \le 1

Hàm chuyển nghịch đảo:

.. math::

    L = L' / 4.5\text{, for } L' < 0.081

    L = \left( \frac{L' + 0.099}{1.099}\right) ^{\frac{1}{0.45} }\text{, for } L' \ge 0.081

Xin lưu ý rằng mặc dù Rec. 709 được định nghĩa là hàm truyền mặc định
theo tiêu chuẩn ZZ0000ZZ, trong thực tế không gian màu này thường được sử dụng
với ZZ0001ZZ. Đặc biệt đĩa Blu-ray Ultra HD sử dụng
sự kết hợp này.

Độ chói (Y') và độ chênh lệch màu (Cb và Cr) thu được bằng
mã hóa ZZ0000ZZ sau:

.. math::

    Y' = 0.2627R' + 0.6780G' + 0.0593B'

    Cb = -0.1396R' - 0.3604G' + 0.5B'

    Cr = 0.5R' - 0.4598G' - 0.0402B'

Y' được kẹp trong phạm vi [0…1] và Cb và Cr được kẹp trong phạm vi
[-0,5…0,5]. Lượng tử hóa Y'CbCr có phạm vi hạn chế.

Ngoài ra còn có độ chói không đổi thay thế R'G'B' đến Yc'CbcCrc
(ZZ0000ZZ) mã hóa:

Luma:

.. math::
    :nowrap:

    \begin{align*}
    Yc' = (0.2627R + 0.6780G + 0.0593B)'& \\
    B' - Yc' \le 0:& \\
        &Cbc = (B' - Yc') / 1.9404 \\
    B' - Yc' > 0: & \\
        &Cbc = (B' - Yc') / 1.5816 \\
    R' - Yc' \le 0:& \\
        &Crc = (R' - Y') / 1.7184 \\
    R' - Yc' > 0:& \\
        &Crc = (R' - Y') / 0.9936
    \end{align*}

Yc' được kẹp trong phạm vi [0…1] và Cbc và Crc được kẹp trong phạm vi
phạm vi [-0,5…0,5]. Lượng tử hóa Yc'CbcCrc có phạm vi hạn chế.


.. _col-dcip3:

Không gian màu DCI-P3 (V4L2_COLORSPACE_DCI_P3)
==========================================

Tiêu chuẩn ZZ0000ZZ xác định không gian màu được sử dụng bởi rạp chiếu phim
máy chiếu sử dụng không gian màu DCI-P3. Chức năng chuyển mặc định
là ZZ0001ZZ. Mã hóa Y'CbCr mặc định là
ZZ0002ZZ. Lượng tử hóa Y'CbCr mặc định có phạm vi giới hạn.

.. note::

   Note that this colorspace standard does not specify a
   Y'CbCr encoding since it is not meant to be encoded to Y'CbCr. So this
   default Y'CbCr encoding was picked because it is the HDTV encoding.

Màu sắc của màu cơ bản và màu trắng tham chiếu là:


.. flat-table:: DCI-P3 Chromaticities
    :header-rows:  1
    :stub-columns: 0
    :widths:       1 1 2

    * - Color
      - x
      - y
    * - Red
      - 0.6800
      - 0.3200
    * - Green
      - 0.2650
      - 0.6900
    * - Blue
      - 0.1500
      - 0.0600
    * - White Reference
      - 0.3140
      - 0.3510



Hàm chuyển:

.. math::

    L' = L^{\frac{1}{2.6}}

Hàm chuyển nghịch đảo:

.. math::

    L = L'^{(2.6)}

Mã hóa Y'CbCr không được chỉ định. V4L2 mặc định là Rec. 709.


.. _col-smpte-240m:

Không gian màu SMPTE 240M (V4L2_COLORSPACE_SMPTE240M)
=================================================

Tiêu chuẩn ZZ0000ZZ là tiêu chuẩn tạm thời được sử dụng trong
những ngày đầu của HDTV (1988-1998). Nó đã được thay thế bởi Rec. 709. Các
chức năng truyền mặc định là ZZ0001ZZ. Mặc định
Mã hóa Y'CbCr là ZZ0002ZZ. Y'CbCr mặc định
lượng tử hóa là phạm vi hạn chế. Sắc độ của các màu cơ bản
và tham chiếu màu trắng là:


.. flat-table:: SMPTE 240M Chromaticities
    :header-rows:  1
    :stub-columns: 0
    :widths:       1 1 2

    * - Color
      - x
      - y
    * - Red
      - 0.630
      - 0.340
    * - Green
      - 0.310
      - 0.595
    * - Blue
      - 0.155
      - 0.070
    * - White Reference (D65)
      - 0.3127
      - 0.3290


Các sắc độ này giống hệt với không gian màu SMPTE 170M.

Hàm chuyển:

.. math::

    L' = 4L\text{, for } 0 \le L < 0.0228

    L' = 1.1115L ^{0.45} - 0.1115\text{, for } 0.0228 \le L \le 1

Hàm chuyển nghịch đảo:

.. math::

    L = \frac{L'}{4}\text{, for } 0 \le L' < 0.0913

    L = \left( \frac{L' + 0.1115}{1.1115}\right) ^{\frac{1}{0.45} }\text{, for } L' \ge 0.0913

Độ chói (Y') và độ chênh lệch màu (Cb và Cr) thu được bằng
mã hóa ZZ0000ZZ sau:

.. math::

    Y' = 0.2122R' + 0.7013G' + 0.0865B'

    Cb = -0.1161R' - 0.3839G' + 0.5B'

    Cr = 0.5R' - 0.4451G' - 0.0549B'

Y' được kẹp trong phạm vi [0…1] và Cb và Cr được kẹp trong phạm vi
phạm vi [-0,5…0,5]. Lượng tử hóa Y'CbCr có phạm vi hạn chế.


.. _col-sysm:

Không gian màu NTSC 1953 (V4L2_COLORSPACE_470_SYSTEM_M)
===================================================

Tiêu chuẩn này xác định không gian màu được NTSC sử dụng vào năm 1953. Trong thực tế
không gian màu này đã lỗi thời và nên sử dụng SMPTE 170M để thay thế. các
chức năng truyền mặc định là ZZ0000ZZ. Y'CbCr mặc định
mã hóa là ZZ0001ZZ. Lượng tử hóa Y'CbCr mặc định là
phạm vi hạn chế. Sắc độ của màu cơ bản và màu trắng
tham khảo là:


.. flat-table:: NTSC 1953 Chromaticities
    :header-rows:  1
    :stub-columns: 0
    :widths:       1 1 2

    * - Color
      - x
      - y
    * - Red
      - 0.67
      - 0.33
    * - Green
      - 0.21
      - 0.71
    * - Blue
      - 0.14
      - 0.08
    * - White Reference (C)
      - 0.310
      - 0.316


.. note::

   This colorspace uses Illuminant C instead of D65 as the white
   reference. To correctly convert an image in this colorspace to another
   that uses D65 you need to apply a chromatic adaptation algorithm such as
   the Bradford method.

Hàm truyền chưa bao giờ được xác định chính xác cho NTSC 1953. Rec.
Hàm truyền 709 được khuyến nghị trong tài liệu:

.. math::

    L' = 4.5L\text{, for } 0 \le L < 0.018

    L' = 1.099L ^{0.45} - 0.099\text{, for } 0.018 \le L \le 1

Hàm chuyển nghịch đảo:

.. math::

    L = \frac{L'}{4.5} \text{, for } L' < 0.081

    L = \left( \frac{L' + 0.099}{1.099}\right) ^{\frac{1}{0.45} }\text{, for } L' \ge 0.081

Độ chói (Y') và độ chênh lệch màu (Cb và Cr) thu được bằng
mã hóa ZZ0000ZZ sau:

.. math::

    Y' = 0.2990R' + 0.5870G' + 0.1140B'

    Cb = -0.1687R' - 0.3313G' + 0.5B'

    Cr = 0.5R' - 0.4187G' - 0.0813B'

Y' được kẹp trong phạm vi [0…1] và Cb và Cr được kẹp trong phạm vi
[-0,5…0,5]. Lượng tử hóa Y'CbCr có phạm vi hạn chế. Sự biến đổi này là
giống hệt với định nghĩa trong SMPTE 170M/BT.601.


.. _col-sysbg:

Không gian màu EBU Tech. 3213 (V4L2_COLORSPACE_470_SYSTEM_BG)
=========================================================

Tiêu chuẩn ZZ0000ZZ xác định không gian màu được sử dụng bởi PAL/SECAM
vào năm 1975. Lưu ý rằng không gian màu này không được giao diện HDMI hỗ trợ.
Thay vào đó ZZ0001ZZ khuyến nghị Rec. 709 được sử dụng thay thế cho HDMI.
Hàm truyền mặc định là
ZZ0002ZZ. Mã hóa Y'CbCr mặc định là
ZZ0003ZZ. Lượng tử hóa Y'CbCr mặc định bị hạn chế
phạm vi. Màu sắc của màu cơ bản và màu trắng tham chiếu
là:


.. flat-table:: EBU Tech. 3213 Chromaticities
    :header-rows:  1
    :stub-columns: 0
    :widths:       1 1 2

    * - Color
      - x
      - y
    * - Red
      - 0.64
      - 0.33
    * - Green
      - 0.29
      - 0.60
    * - Blue
      - 0.15
      - 0.06
    * - White Reference (D65)
      - 0.3127
      - 0.3290



Hàm truyền chưa bao giờ được xác định chính xác cho không gian màu này.
Rec. Hàm truyền 709 được khuyến nghị trong tài liệu:

.. math::

    L' = 4.5L\text{, for } 0 \le L < 0.018

    L' = 1.099L ^{0.45} - 0.099\text{, for } 0.018 \le L \le 1

Hàm chuyển nghịch đảo:

.. math::

    L = \frac{L'}{4.5} \text{, for } L' < 0.081

    L = \left(\frac{L' + 0.099}{1.099} \right) ^{\frac{1}{0.45} }\text{, for } L' \ge 0.081

Độ chói (Y') và độ chênh lệch màu (Cb và Cr) thu được bằng
mã hóa ZZ0000ZZ sau:

.. math::

    Y' = 0.2990R' + 0.5870G' + 0.1140B'

    Cb = -0.1687R' - 0.3313G' + 0.5B'

    Cr = 0.5R' - 0.4187G' - 0.0813B'

Y' được kẹp trong phạm vi [0…1] và Cb và Cr được kẹp trong phạm vi
[-0,5…0,5]. Lượng tử hóa Y'CbCr có phạm vi hạn chế. Sự biến đổi này là
giống hệt với định nghĩa trong SMPTE 170M/BT.601.


.. _col-jpeg:

Không gian màu JPEG (V4L2_COLORSPACE_JPEG)
======================================

Không gian màu này xác định không gian màu được sử dụng bởi hầu hết (Motion-)JPEG
các định dạng. Sắc độ của màu cơ bản và màu trắng
tham chiếu giống hệt với sRGB. Việc sử dụng hàm truyền là
ZZ0000ZZ. Mã hóa Y'CbCr là ZZ0001ZZ
với lượng tử hóa toàn dải trong đó Y' được chia tỷ lệ thành [0…255] và Cb/Cr là
được chia tỷ lệ thành [-128…128] và sau đó cắt bớt thành [-128…127].

.. note::

   The JPEG standard does not actually store colorspace
   information. So if something other than sRGB is used, then the driver
   will have to set that information explicitly. Effectively
   ``V4L2_COLORSPACE_JPEG`` can be considered to be an abbreviation for
   ``V4L2_COLORSPACE_SRGB``, ``V4L2_XFER_FUNC_SRGB``, ``V4L2_YCBCR_ENC_601``
   and ``V4L2_QUANTIZATION_FULL_RANGE``.

****************************************
Mô tả chức năng chuyển chi tiết
****************************************

.. _xf-smpte-2084:

Chức năng truyền SMPTE 2084 (V4L2_XFER_FUNC_SMPTE2084)
=======================================================

Tiêu chuẩn ZZ0000ZZ xác định hàm truyền được sử dụng bởi
Nội dung Dải động cao.

Hằng số:
    m1 = (2610/4096)/4

m2 = (2523/4096) * 128

c1 = 3424/4096

c2 = (2413/4096) * 32

c3 = (2392/4096) * 32

Hàm chuyển:
    L' = ((c1 + c2 * L\ ZZ0000ZZ) / (1 + c3 * L\ ZZ0001ZZ))\ ZZ0002ZZ

Hàm chuyển nghịch đảo:
    L = (max(L'ZZ0000ZZ - c1, 0) / (c2 - c3 *
    L'\ ZZ0001ZZ))\ ZZ0002ZZ

Hãy cẩn thận khi chuyển đổi giữa chức năng truyền này và truyền không phải HDR
chức năng: các giá trị RGB tuyến tính [0…1] của nội dung HDR ánh xạ tới phạm vi độ chói
từ 0 đến 10000 cd/m\ ZZ0000ZZ trong khi các giá trị RGB tuyến tính của không phải HDR (còn gọi là
Dải động tiêu chuẩn hoặc SDR) ánh xạ tới phạm vi độ chói từ 0 đến 100 cd/m\ ZZ0001ZZ.

Để đi từ SDR đến HDR, trước tiên bạn phải chia L cho 100. Để đi vào cái khác
hướng bạn sẽ phải nhân L với 100. Tất nhiên, điều này kẹp tất cả
giá trị độ chói trên 100 cd/m\ ZZ0000ZZ đến 100 cd/m\ ZZ0001ZZ.

Có những phương pháp tốt hơn, xem ví dụ: ZZ0000ZZ để biết thêm thông tin chi tiết
về điều này.