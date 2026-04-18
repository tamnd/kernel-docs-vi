.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-yuv-planar.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. planar-yuv:

*******************
Định dạng phẳng YUV
*******************

Các định dạng phẳng phân chia dữ liệu độ sáng và sắc độ trong các vùng bộ nhớ riêng biệt. Họ
tồn tại trong hai biến thể:

- Dạng bán phẳng sử dụng hai mặt phẳng. Mặt phẳng đầu tiên là mặt phẳng luma và
  lưu trữ các thành phần Y. Mặt phẳng thứ hai là mặt phẳng màu và lưu trữ
  Các thành phần Cb và Cr xen kẽ nhau.

- Định dạng phẳng hoàn toàn sử dụng ba mặt phẳng để lưu trữ các thành phần Y, Cb và Cr
  riêng biệt.

Trong một mặt phẳng, các thành phần được lưu trữ theo thứ tự pixel, có thể là tuyến tính hoặc
lát gạch. Phần đệm có thể được hỗ trợ ở cuối dòng và sải chân của dòng
các mặt phẳng sắc độ có thể bị hạn chế bởi đường thẳng của mặt phẳng độ sáng.

Một số định dạng phẳng cho phép các mặt phẳng được đặt ở các vị trí bộ nhớ độc lập.
Chúng được xác định bằng hậu tố 'M' trong tên của chúng (chẳng hạn như trong
ZZ0001ZZ). Những định dạng đó chỉ được sử dụng trong trình điều khiển
và các ứng dụng hỗ trợ API đa mặt phẳng, được mô tả trong
ZZ0000ZZ. Trừ khi được ghi lại rõ ràng là hỗ trợ không liền kề
các mặt phẳng, định dạng yêu cầu các mặt phẳng phải nối tiếp nhau ngay trong bộ nhớ.


Định dạng YUV bán phẳng
=======================

Các định dạng này thường được gọi là định dạng NV (NV12, NV16, ...). Họ
sử dụng hai mặt phẳng và lưu trữ các thành phần độ sáng trong mặt phẳng đầu tiên và sắc độ
các thành phần trong mặt phẳng thứ hai. Các thành phần Cb và Cr xen kẽ trong
mặt phẳng sắc độ, với Cb và Cr luôn được lưu trữ theo cặp. Thứ tự sắc độ là
được trình bày dưới các định dạng khác nhau.

Đối với các định dạng liền kề bộ nhớ, số lượng pixel đệm ở cuối
các đường sắc độ giống hệt với phần đệm của các đường luma. Không có chiều ngang
lấy mẫu con, do đó, bước sắc độ (tính bằng byte) bằng hai lần độ sáng
sải bước. Với lấy mẫu con theo chiều ngang bằng 2, bước sắc độ bằng nhau
đến sải chân của dòng luma. Lấy mẫu con dọc không ảnh hưởng đến sải chân.

Đối với các định dạng không liền kề, không có ràng buộc nào được thực thi bởi định dạng trên
mối quan hệ giữa phần đệm đường luma và sắc độ và sải chân.

Tất cả các thành phần được lưu trữ với cùng số bit cho mỗi thành phần.

.. raw:: latex

    \footnotesize

.. tabularcolumns:: |p{5.2cm}|p{1.0cm}|p{1.5cm}|p{1.9cm}|p{1.2cm}|p{1.8cm}|p{2.7cm}|

.. flat-table:: Overview of Semi-Planar YUV Formats
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Code
      - Bits per component
      - Subsampling
      - Chroma order [1]_
      - Contiguous [2]_
      - Tiling [3]_
    * - V4L2_PIX_FMT_NV12
      - 'NV12'
      - 8
      - 4:2:0
      - Cb, Cr
      - Yes
      - Linear
    * - V4L2_PIX_FMT_NV21
      - 'NV21'
      - 8
      - 4:2:0
      - Cr, Cb
      - Yes
      - Linear
    * - V4L2_PIX_FMT_NV12M
      - 'NM12'
      - 8
      - 4:2:0
      - Cb, Cr
      - No
      - Linear
    * - V4L2_PIX_FMT_NV21M
      - 'NM21'
      - 8
      - 4:2:0
      - Cr, Cb
      - No
      - Linear
    * - V4L2_PIX_FMT_NV12MT
      - 'TM12'
      - 8
      - 4:2:0
      - Cb, Cr
      - No
      - 64x32 tiles

        Horizontal Z order
    * - V4L2_PIX_FMT_NV12MT_16X16
      - 'VM12'
      - 8
      - 4:2:2
      - Cb, Cr
      - No
      - 16x16 tiles
    * - V4L2_PIX_FMT_P010
      - 'P010'
      - 10
      - 4:2:0
      - Cb, Cr
      - Yes
      - Linear
    * - V4L2_PIX_FMT_P010_4L4
      - 'T010'
      - 10
      - 4:2:0
      - Cb, Cr
      - Yes
      - 4x4 tiles
    * - V4L2_PIX_FMT_P012
      - 'P012'
      - 12
      - 4:2:0
      - Cb, Cr
      - Yes
      - Linear
    * - V4L2_PIX_FMT_P012M
      - 'PM12'
      - 12
      - 4:2:0
      - Cb, Cr
      - No
      - Linear
    * - V4L2_PIX_FMT_NV15
      - 'NV15'
      - 10
      - 4:2:0
      - Cb, Cr
      - Yes
      - Linear
    * - V4L2_PIX_FMT_NV15_4L4
      - 'VT15'
      - 15
      - 4:2:0
      - Cb, Cr
      - Yes
      - 4x4 tiles
    * - V4L2_PIX_FMT_MT2110T
      - 'MT2T'
      - 15
      - 4:2:0
      - Cb, Cr
      - No
      - 16x32 / 16x16 tiles tiled low bits
    * - V4L2_PIX_FMT_MT2110R
      - 'MT2R'
      - 15
      - 4:2:0
      - Cb, Cr
      - No
      - 16x32 / 16x16 tiles raster low bits
    * - V4L2_PIX_FMT_NV16
      - 'NV16'
      - 8
      - 4:2:2
      - Cb, Cr
      - Yes
      - Linear
    * - V4L2_PIX_FMT_NV61
      - 'NV61'
      - 8
      - 4:2:2
      - Cr, Cb
      - Yes
      - Linear
    * - V4L2_PIX_FMT_NV16M
      - 'NM16'
      - 8
      - 4:2:2
      - Cb, Cr
      - No
      - Linear
    * - V4L2_PIX_FMT_NV61M
      - 'NM61'
      - 8
      - 4:2:2
      - Cr, Cb
      - No
      - Linear
    * - V4L2_PIX_FMT_NV20
      - 'NV20'
      - 10
      - 4:2:2
      - Cb, Cr
      - Yes
      - Linear
    * - V4L2_PIX_FMT_NV24
      - 'NV24'
      - 8
      - 4:4:4
      - Cb, Cr
      - Yes
      - Linear
    * - V4L2_PIX_FMT_NV42
      - 'NV42'
      - 8
      - 4:4:4
      - Cr, Cb
      - Yes
      - Linear

.. raw:: latex

    \normalsize

.. [1] Order of chroma samples in the second plane
.. [2] Indicates if planes have to be contiguous in memory or can be
       disjoint
.. [3] Macroblock size in pixels


ZZ0001ZZ
Mẫu sắc độ là ZZ0000ZZ
theo chiều ngang.


.. _V4L2-PIX-FMT-NV12:
.. _V4L2-PIX-FMT-NV21:
.. _V4L2-PIX-FMT-NV12M:
.. _V4L2-PIX-FMT-NV21M:
.. _V4L2-PIX-FMT-P010:

NV12, NV21, NV12M và NV21M
---------------------------

Định dạng bán phẳng YUV 4:2:0. Mặt phẳng sắc độ được lấy mẫu con 2 trong mỗi
hướng. Các dòng Chroma chứa một nửa số pixel và cùng một số
byte dưới dạng các dòng luma và mặt phẳng sắc độ chứa một nửa số dòng
của mặt phẳng luma.

.. flat-table:: Sample 4x4 NV12 Image
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 16:
      - Cb\ :sub:`00`
      - Cr\ :sub:`00`
      - Cb\ :sub:`01`
      - Cr\ :sub:`01`
    * - start + 20:
      - Cb\ :sub:`10`
      - Cr\ :sub:`10`
      - Cb\ :sub:`11`
      - Cr\ :sub:`11`

.. flat-table:: Sample 4x4 NV12M Image
    :header-rows:  0
    :stub-columns: 0

    * - start0 + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start0 + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start0 + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start0 + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * -
    * - start1 + 0:
      - Cb\ :sub:`00`
      - Cr\ :sub:`00`
      - Cb\ :sub:`01`
      - Cr\ :sub:`01`
    * - start1 + 4:
      - Cb\ :sub:`10`
      - Cr\ :sub:`10`
      - Cb\ :sub:`11`
      - Cr\ :sub:`11`


.. _V4L2-PIX-FMT-NV15:

NV15
----

Định dạng YUV 4:2:0 bán phẳng 10 bit tương tự NV12, sử dụng các thành phần 10 bit
không có phần đệm giữa mỗi thành phần. Một nhóm gồm 4 thành phần được lưu trữ trên
5 byte theo thứ tự endian nhỏ.

.. flat-table:: Sample 4x4 NV15 Image (1 byte per cell)
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00[7:0]`
      - Y'\ :sub:`01[5:0]`\ Y'\ :sub:`00[9:8]`
      - Y'\ :sub:`02[3:0]`\ Y'\ :sub:`01[9:6]`
      - Y'\ :sub:`03[1:0]`\ Y'\ :sub:`02[9:4]`
      - Y'\ :sub:`03[9:2]`
    * - start + 5:
      - Y'\ :sub:`10[7:0]`
      - Y'\ :sub:`11[5:0]`\ Y'\ :sub:`10[9:8]`
      - Y'\ :sub:`12[3:0]`\ Y'\ :sub:`11[9:6]`
      - Y'\ :sub:`13[1:0]`\ Y'\ :sub:`12[9:4]`
      - Y'\ :sub:`13[9:2]`
    * - start + 10:
      - Y'\ :sub:`20[7:0]`
      - Y'\ :sub:`21[5:0]`\ Y'\ :sub:`20[9:8]`
      - Y'\ :sub:`22[3:0]`\ Y'\ :sub:`21[9:6]`
      - Y'\ :sub:`23[1:0]`\ Y'\ :sub:`22[9:4]`
      - Y'\ :sub:`23[9:2]`
    * - start + 15:
      - Y'\ :sub:`30[7:0]`
      - Y'\ :sub:`31[5:0]`\ Y'\ :sub:`30[9:8]`
      - Y'\ :sub:`32[3:0]`\ Y'\ :sub:`31[9:6]`
      - Y'\ :sub:`33[1:0]`\ Y'\ :sub:`32[9:4]`
      - Y'\ :sub:`33[9:2]`
    * - start + 20:
      - Cb\ :sub:`00[7:0]`
      - Cr\ :sub:`00[5:0]`\ Cb\ :sub:`00[9:8]`
      - Cb\ :sub:`01[3:0]`\ Cr\ :sub:`00[9:6]`
      - Cr\ :sub:`01[1:0]`\ Cb\ :sub:`01[9:4]`
      - Cr\ :sub:`01[9:2]`
    * - start + 25:
      - Cb\ :sub:`10[7:0]`
      - Cr\ :sub:`10[5:0]`\ Cb\ :sub:`10[9:8]`
      - Cb\ :sub:`11[3:0]`\ Cr\ :sub:`10[9:6]`
      - Cr\ :sub:`11[1:0]`\ Cb\ :sub:`11[9:4]`
      - Cr\ :sub:`11[9:2]`


.. _V4L2-PIX-FMT-NV12MT:
.. _V4L2-PIX-FMT-NV12MT-16X16:
.. _V4L2-PIX-FMT-NV12-4L4:
.. _V4L2-PIX-FMT-NV12-16L16:
.. _V4L2-PIX-FMT-NV12-32L32:
.. _V4L2-PIX-FMT-NV12M-8L128:
.. _V4L2-PIX-FMT-NV12-8L128:
.. _V4L2-PIX-FMT-MM21:

Lát gạch NV12
-------------

Các định dạng YUV 4:2:0 bán phẳng, sử dụng ốp lát macroblock. Mặt phẳng sắc độ là
lấy mẫu phụ theo 2 theo mỗi hướng. Các vạch Chroma chứa một nửa số
pixel và cùng số byte như các dòng luma và mặt phẳng sắc độ
chứa một nửa số đường thẳng của mặt phẳng luma. Mỗi ô xếp theo
cái trước một cách tuyến tính trong bộ nhớ (từ trái sang phải, từ trên xuống dưới).

ZZ0000ZZ tương tự ZZ0001ZZ nhưng lưu trữ
pixel trong các ô 2D 16x16 và lưu trữ các ô một cách tuyến tính trong bộ nhớ.
Khoảng cách của dòng và chiều cao của hình ảnh phải được căn chỉnh theo bội số của 16.
Bố cục của mặt phẳng độ sáng và sắc độ giống hệt nhau.

ZZ0000ZZ tương tự ZZ0001ZZ nhưng lưu trữ
pixel trong các ô 2D 64x32 và lưu trữ các nhóm ô 2x2 trong
Thứ tự Z trong bộ nhớ, xen kẽ các hình chữ Z và hình chữ Z được phản chiếu theo chiều ngang.
Sải bước phải là bội số của 128 pixel để đảm bảo
số nguyên của hình Z. Chiều cao của hình ảnh phải là bội số của 32 pixel.
Nếu độ phân giải dọc là số ô lẻ thì hàng cuối cùng của
gạch được lưu trữ theo thứ tự tuyến tính. Bố cục của độ sáng và sắc độ
mặt phẳng giống hệt nhau.

.. _nv12mt:

.. kernel-figure:: nv12mt.svg
    :alt:    nv12mt.svg
    :align:  center

    V4L2_PIX_FMT_NV12MT macroblock Z shape memory layout

.. _nv12mt_ex:

.. kernel-figure:: nv12mt_example.svg
    :alt:    nv12mt_example.svg
    :align:  center

    Example V4L2_PIX_FMT_NV12MT memory layout of tiles

ZZ0000ZZ lưu trữ pixel ở dạng ô 4x4 và lưu trữ
xếp tuyến tính trong bộ nhớ. Khoảng cách của dòng và chiều cao của hình ảnh phải là
căn chỉnh theo bội số của 4. Bố cục của mặt phẳng độ sáng và sắc độ là
giống hệt nhau.

ZZ0000ZZ lưu trữ các pixel ở dạng ô 16x16 và lưu trữ
xếp tuyến tính trong bộ nhớ. Khoảng cách của dòng và chiều cao của hình ảnh phải là
căn chỉnh theo bội số của 16. Bố cục của mặt phẳng độ sáng và sắc độ là
giống hệt nhau.

ZZ0000ZZ lưu trữ các pixel ở dạng ô 32x32 và lưu trữ
xếp tuyến tính trong bộ nhớ. Khoảng cách của dòng và chiều cao của hình ảnh phải là
căn chỉnh theo bội số của 32. Bố cục của mặt phẳng độ sáng và sắc độ là
giống hệt nhau.

ZZ0000ZZ tương tự ZZ0001ZZ nhưng lưu trữ
pixel trong các ô 2D 8x128 và lưu trữ các ô một cách tuyến tính trong bộ nhớ.
Chiều cao của hình ảnh phải được căn chỉnh theo bội số của 128.
Bố cục của mặt phẳng độ sáng và sắc độ giống hệt nhau.

ZZ0000ZZ tương tự ZZ0001ZZ nhưng lưu trữ
hai mặt phẳng trong một bộ nhớ.

ZZ0000ZZ lưu trữ pixel luma ở dạng ô 16x32 và pixel sắc độ
trong gạch 16x16. Sải chân của dòng phải được căn chỉnh theo bội số của 16 và
chiều cao của hình ảnh phải được căn chỉnh theo bội số của 32. Số lượng độ sáng và sắc độ
gạch giống hệt nhau, mặc dù kích thước gạch khác nhau. Hình ảnh được tạo thành từ
hai mặt phẳng không kề nhau.


.. _V4L2-PIX-FMT-NV15-4L4:
.. _V4L2-PIX-FMT-NV12M-10BE-8L128:
.. _V4L2-PIX-FMT-NV12-10BE-8L128:
.. _V4L2-PIX-FMT-MT2110T:
.. _V4L2-PIX-FMT-MT2110R:

Lát gạch NV15
-------------

ZZ0000ZZ Định dạng YUV 4:2:0 10 bit bán phẳng, sử dụng ô xếp 4x4.
Tất cả các thành phần được đóng gói mà không có bất kỳ phần đệm nào giữa nhau.
Là một tác dụng phụ, mỗi nhóm gồm 4 thành phần được lưu trữ trên 5 byte
(YYYY hoặc UVUV = 4 * 10 bit = 40 bit = 5 byte).

ZZ0000ZZ tương tự ZZ0001ZZ nhưng lưu trữ
Các pixel 10 bit ở dạng ô 2D 8x128 và lưu trữ các ô một cách tuyến tính trong bộ nhớ.
dữ liệu được sắp xếp theo thứ tự big endian.
Chiều cao của hình ảnh phải được căn chỉnh theo bội số của 128.
Bố cục của mặt phẳng độ sáng và sắc độ giống hệt nhau.
Lưu ý kích thước ô là 8byte nhân với 128 byte,
điều đó có nghĩa là các bit thấp và bit cao của một pixel có thể nằm ở các ô khác nhau.
Các pixel 10 bit được đóng gói, vì vậy 5 byte chứa 4 bố cục pixel 10 bit như
cái này (đối với luma):
byte 0: Y0(bit 9-2)
byte 1: Y0(bit 1-0) Y1(bit 9-4)
byte 2: Y1(bit 3-0) Y2(bit 9-6)
byte 3: Y2(bit 5-0) Y3(bit 9-8)
byte 4: Y3 (bit 7-0)

ZZ0000ZZ tương tự ZZ0001ZZ nhưng lưu trữ
hai mặt phẳng trong một bộ nhớ.

ZZ0000ZZ là một trong những định dạng 10bit YUV 4:2:0 được Mediatek đóng gói.
Nó được đóng gói đầy đủ định dạng 10bit 4:2:0 như NV15 (15 bit mỗi pixel), ngoại trừ
dữ liệu hai bit thấp hơn được lưu trữ trong các phân vùng riêng biệt. Định dạng là
bao gồm các ô luma 16x32 và các ô màu 16x16. Mỗi ô là 640 byte
dài, chia thành 8 phân vùng 80 byte.  16 byte đầu tiên của
phân vùng đại diện cho 2 bit dữ liệu pixel ít quan trọng nhất. Phần còn lại
64 byte đại diện cho 8 bit dữ liệu pixel quan trọng nhất.

.. kernel-figure:: mt2110t.svg
    :alt:    mt2110t.svg
    :align:  center

    Layout of MT2110T Chroma Tile

Việc lọc phần trên của mỗi phân vùng sẽ cho kết quả hợp lệ
Khung ZZ0000ZZ. Một phân vùng là một ô con có kích thước 16 x 4.
hai bit thấp hơn được cho là được xếp chồng lên nhau vì mỗi byte chứa hai bit thấp hơn
các bit của cột dành cho pixel khớp với cùng một chỉ mục. Gạch màu
chỉ có 4 phân vùng.

.. flat-table:: MT2110T LSB bits layout
    :header-rows:  1
    :stub-columns: 1

    * -
      - start + 0:
      - start + 1:
      - . . .
      - start\ +\ 15:
    * - Bits 1:0
      - Y'\ :sub:`0:0`
      - Y'\ :sub:`0:1`
      - . . .
      - Y'\ :sub:`0:15`
    * - Bit 3:2
      - Y'\ :sub:`1:0`
      - Y'\ :sub:`1:1`
      - . . .
      - Y'\ :sub:`1:15`
    * - Bits 5:4
      - Y'\ :sub:`2:0`
      - Y'\ :sub:`2:1`
      - . . .
      - Y'\ :sub:`2:15`
    * - Bits 7:6
      - Y'\ :sub:`3:0`
      - Y'\ :sub:`3:1`
      - . . .
      - Y'\ :sub:`3:15`

ZZ0000ZZ giống hệt ZZ0001ZZ ngoại trừ
bố cục hai bit ít quan trọng nhất là theo thứ tự raster. Điều này có nghĩa là byte đầu tiên
chứa 4 pixel của hàng đầu tiên, với 4 byte trên mỗi dòng.

.. flat-table:: MT2110R LSB bits layout
    :header-rows:  2
    :stub-columns: 1

    * -
      - :cspan:`3` Byte 0
      - ...
      - :cspan:`3` Byte 3
    * -
      - 7:6
      - 5:4
      - 3:2
      - 1:0
      - ...
      - 7:6
      - 5:4
      - 3:2
      - 1:0
    * - start + 0:
      - Y'\ :sub:`0:3`
      - Y'\ :sub:`0:2`
      - Y'\ :sub:`0:1`
      - Y'\ :sub:`0:0`
      - ...
      - Y'\ :sub:`0:15`
      - Y'\ :sub:`0:14`
      - Y'\ :sub:`0:13`
      - Y'\ :sub:`0:12`
    * - start + 4:
      - Y'\ :sub:`1:3`
      - Y'\ :sub:`1:2`
      - Y'\ :sub:`1:1`
      - Y'\ :sub:`1:0`
      - ...
      - Y'\ :sub:`1:15`
      - Y'\ :sub:`1:14`
      - Y'\ :sub:`1:13`
      - Y'\ :sub:`1:12`
    * - start + 8:
      - Y'\ :sub:`2:3`
      - Y'\ :sub:`2:2`
      - Y'\ :sub:`2:1`
      - Y'\ :sub:`2:0`
      - ...
      - Y'\ :sub:`2:15`
      - Y'\ :sub:`2:14`
      - Y'\ :sub:`2:13`
      - Y'\ :sub:`2:12`
    * - start\ +\ 12:
      - Y'\ :sub:`3:3`
      - Y'\ :sub:`3:2`
      - Y'\ :sub:`3:1`
      - Y'\ :sub:`3:0`
      - ...
      - Y'\ :sub:`3:15`
      - Y'\ :sub:`3:14`
      - Y'\ :sub:`3:13`
      - Y'\ :sub:`3:12`


.. _V4L2-PIX-FMT-NV16:
.. _V4L2-PIX-FMT-NV61:
.. _V4L2-PIX-FMT-NV16M:
.. _V4L2-PIX-FMT-NV61M:

NV16, NV61, NV16M và NV61M
---------------------------

Định dạng bán phẳng YUV 4:2:2. Mặt phẳng sắc độ được lấy mẫu con bằng 2 trong
hướng ngang. Các dòng Chroma chứa một nửa số pixel và
cùng số byte như các dòng luma và mặt phẳng sắc độ chứa cùng
số đường thẳng như mặt phẳng luma.

.. flat-table:: Sample 4x4 NV16 Image
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 16:
      - Cb\ :sub:`00`
      - Cr\ :sub:`00`
      - Cb\ :sub:`01`
      - Cr\ :sub:`01`
    * - start + 20:
      - Cb\ :sub:`10`
      - Cr\ :sub:`10`
      - Cb\ :sub:`11`
      - Cr\ :sub:`11`
    * - start + 24:
      - Cb\ :sub:`20`
      - Cr\ :sub:`20`
      - Cb\ :sub:`21`
      - Cr\ :sub:`21`
    * - start + 28:
      - Cb\ :sub:`30`
      - Cr\ :sub:`30`
      - Cb\ :sub:`31`
      - Cr\ :sub:`31`

.. flat-table:: Sample 4x4 NV16M Image
    :header-rows:  0
    :stub-columns: 0

    * - start0 + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start0 + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start0 + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start0 + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * -
    * - start1 + 0:
      - Cb\ :sub:`00`
      - Cr\ :sub:`00`
      - Cb\ :sub:`02`
      - Cr\ :sub:`02`
    * - start1 + 4:
      - Cb\ :sub:`10`
      - Cr\ :sub:`10`
      - Cb\ :sub:`12`
      - Cr\ :sub:`12`
    * - start1 + 8:
      - Cb\ :sub:`20`
      - Cr\ :sub:`20`
      - Cb\ :sub:`22`
      - Cr\ :sub:`22`
    * - start1 + 12:
      - Cb\ :sub:`30`
      - Cr\ :sub:`30`
      - Cb\ :sub:`32`
      - Cr\ :sub:`32`


.. _V4L2-PIX-FMT-NV20:

NV20
----

Định dạng YUV 4:2:2 bán phẳng 10 bit tương tự NV16, sử dụng các thành phần 10 bit
không có phần đệm giữa mỗi thành phần. Một nhóm gồm 4 thành phần được lưu trữ trên
5 byte theo thứ tự endian nhỏ.

.. flat-table:: Sample 4x4 NV20 Image (1 byte per cell)
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00[7:0]`
      - Y'\ :sub:`01[5:0]`\ Y'\ :sub:`00[9:8]`
      - Y'\ :sub:`02[3:0]`\ Y'\ :sub:`01[9:6]`
      - Y'\ :sub:`03[1:0]`\ Y'\ :sub:`02[9:4]`
      - Y'\ :sub:`03[9:2]`
    * - start + 5:
      - Y'\ :sub:`10[7:0]`
      - Y'\ :sub:`11[5:0]`\ Y'\ :sub:`10[9:8]`
      - Y'\ :sub:`12[3:0]`\ Y'\ :sub:`11[9:6]`
      - Y'\ :sub:`13[1:0]`\ Y'\ :sub:`12[9:4]`
      - Y'\ :sub:`13[9:2]`
    * - start + 10:
      - Y'\ :sub:`20[7:0]`
      - Y'\ :sub:`21[5:0]`\ Y'\ :sub:`20[9:8]`
      - Y'\ :sub:`22[3:0]`\ Y'\ :sub:`21[9:6]`
      - Y'\ :sub:`23[1:0]`\ Y'\ :sub:`22[9:4]`
      - Y'\ :sub:`23[9:2]`
    * - start + 15:
      - Y'\ :sub:`30[7:0]`
      - Y'\ :sub:`31[5:0]`\ Y'\ :sub:`30[9:8]`
      - Y'\ :sub:`32[3:0]`\ Y'\ :sub:`31[9:6]`
      - Y'\ :sub:`33[1:0]`\ Y'\ :sub:`32[9:4]`
      - Y'\ :sub:`33[9:2]`
    * - start + 20:
      - Cb\ :sub:`00[7:0]`
      - Cr\ :sub:`00[5:0]`\ Cb\ :sub:`00[9:8]`
      - Cb\ :sub:`01[3:0]`\ Cr\ :sub:`00[9:6]`
      - Cr\ :sub:`01[1:0]`\ Cb\ :sub:`01[9:4]`
      - Cr\ :sub:`01[9:2]`
    * - start + 25:
      - Cb\ :sub:`10[7:0]`
      - Cr\ :sub:`10[5:0]`\ Cb\ :sub:`10[9:8]`
      - Cb\ :sub:`11[3:0]`\ Cr\ :sub:`10[9:6]`
      - Cr\ :sub:`11[1:0]`\ Cb\ :sub:`11[9:4]`
      - Cr\ :sub:`11[9:2]`
    * - start + 30:
      - Cb\ :sub:`20[7:0]`
      - Cr\ :sub:`20[5:0]`\ Cb\ :sub:`20[9:8]`
      - Cb\ :sub:`21[3:0]`\ Cr\ :sub:`20[9:6]`
      - Cr\ :sub:`21[1:0]`\ Cb\ :sub:`21[9:4]`
      - Cr\ :sub:`21[9:2]`
    * - start + 35:
      - Cb\ :sub:`30[7:0]`
      - Cr\ :sub:`30[5:0]`\ Cb\ :sub:`30[9:8]`
      - Cb\ :sub:`31[3:0]`\ Cr\ :sub:`30[9:6]`
      - Cr\ :sub:`31[1:0]`\ Cb\ :sub:`31[9:4]`
      - Cr\ :sub:`31[9:2]`


.. _V4L2-PIX-FMT-NV24:
.. _V4L2-PIX-FMT-NV42:

NV24 và NV42
-------------

Định dạng bán phẳng YUV 4:4:4. Mặt phẳng sắc độ không được lấy mẫu phụ.
Các dòng màu chứa cùng số pixel và gấp đôi
số byte dưới dạng các dòng luma và mặt phẳng sắc độ chứa cùng
số đường thẳng như mặt phẳng luma.

.. flat-table:: Sample 4x4 NV24 Image
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 16:
      - Cb\ :sub:`00`
      - Cr\ :sub:`00`
      - Cb\ :sub:`01`
      - Cr\ :sub:`01`
      - Cb\ :sub:`02`
      - Cr\ :sub:`02`
      - Cb\ :sub:`03`
      - Cr\ :sub:`03`
    * - start + 24:
      - Cb\ :sub:`10`
      - Cr\ :sub:`10`
      - Cb\ :sub:`11`
      - Cr\ :sub:`11`
      - Cb\ :sub:`12`
      - Cr\ :sub:`12`
      - Cb\ :sub:`13`
      - Cr\ :sub:`13`
    * - start + 32:
      - Cb\ :sub:`20`
      - Cr\ :sub:`20`
      - Cb\ :sub:`21`
      - Cr\ :sub:`21`
      - Cb\ :sub:`22`
      - Cr\ :sub:`22`
      - Cb\ :sub:`23`
      - Cr\ :sub:`23`
    * - start + 40:
      - Cb\ :sub:`30`
      - Cr\ :sub:`30`
      - Cb\ :sub:`31`
      - Cr\ :sub:`31`
      - Cb\ :sub:`32`
      - Cr\ :sub:`32`
      - Cb\ :sub:`33`
      - Cr\ :sub:`33`

.. _V4L2_PIX_FMT_P010:
.. _V4L2-PIX-FMT-P010-4L4:

P010 và P010 lát gạch
---------------------

P010 giống như NV12 với 10 bit cho mỗi thành phần, được mở rộng thành 16 bit.
Dữ liệu ở 10 bit cao, số 0 ở 6 bit thấp, được sắp xếp theo thứ tự endian nhỏ.

.. flat-table:: Sample 4x4 P010 Image
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 8:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 16:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 24:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 32:
      - Cb\ :sub:`00`
      - Cr\ :sub:`00`
      - Cb\ :sub:`01`
      - Cr\ :sub:`01`
    * - start + 40:
      - Cb\ :sub:`10`
      - Cr\ :sub:`10`
      - Cb\ :sub:`11`
      - Cr\ :sub:`11`

.. _V4L2-PIX-FMT-P012:
.. _V4L2-PIX-FMT-P012M:

P012 và P012M
--------------

P012 giống NV12 với 12 bit cho mỗi thành phần, được mở rộng thành 16 bit.
Dữ liệu ở 12 bit cao, số 0 ở 4 bit thấp, được sắp xếp theo thứ tự endian nhỏ.

.. flat-table:: Sample 4x4 P012 Image
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 8:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 16:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 24:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 32:
      - Cb\ :sub:`00`
      - Cr\ :sub:`00`
      - Cb\ :sub:`01`
      - Cr\ :sub:`01`
    * - start + 40:
      - Cb\ :sub:`10`
      - Cr\ :sub:`10`
      - Cb\ :sub:`11`
      - Cr\ :sub:`11`

.. flat-table:: Sample 4x4 P012M Image
    :header-rows:  0
    :stub-columns: 0

    * - start0 + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start0 + 8:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start0 + 16:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start0 + 24:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * -
    * - start1 + 0:
      - Cb\ :sub:`00`
      - Cr\ :sub:`00`
      - Cb\ :sub:`01`
      - Cr\ :sub:`01`
    * - start1 + 8:
      - Cb\ :sub:`10`
      - Cr\ :sub:`10`
      - Cb\ :sub:`11`
      - Cr\ :sub:`11`


Định dạng YUV phẳng hoàn toàn
=============================

Các định dạng này lưu trữ các thành phần Y, Cb và Cr trong ba mặt phẳng riêng biệt. các
mặt phẳng độ sáng xuất hiện trước và thứ tự của hai mặt phẳng sắc độ khác nhau giữa
các định dạng. Hai mặt phẳng sắc độ luôn sử dụng cùng một mẫu con.

Đối với các định dạng liền kề bộ nhớ, số lượng pixel đệm ở cuối
các đường sắc độ giống hệt với phần đệm của các đường luma. Đường màu
sải chân (tính bằng byte) do đó bằng với độ sáng dòng sải chân chia cho
hệ số lấy mẫu con theo chiều ngang. Lấy mẫu con dọc không ảnh hưởng đến dòng
sải bước.

Đối với các định dạng không liền kề, không có ràng buộc nào được thực thi bởi định dạng trên
mối quan hệ giữa phần đệm đường luma và sắc độ và sải chân.

Tất cả các thành phần được lưu trữ với cùng số bit cho mỗi thành phần.

ZZ0000ZZ lưu trữ pixel trong các ô 4x4 và lưu trữ các ô một cách tuyến tính
trong bộ nhớ. Sải chân của dòng phải được căn chỉnh theo bội số của 8 và chiều cao của hình ảnh phải
bội số của 4. Bố cục của mặt phẳng độ sáng và sắc độ giống hệt nhau.

.. raw:: latex

    \small

.. tabularcolumns:: |p{5.0cm}|p{1.1cm}|p{1.5cm}|p{2.2cm}|p{1.2cm}|p{3.7cm}|

.. flat-table:: Overview of Fully Planar YUV Formats
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Code
      - Bits per component
      - Subsampling
      - Planes order [4]_
      - Contiguous [5]_

    * - V4L2_PIX_FMT_YUV410
      - 'YUV9'
      - 8
      - 4:1:0
      - Y, Cb, Cr
      - Yes
    * - V4L2_PIX_FMT_YVU410
      - 'YVU9'
      - 8
      - 4:1:0
      - Y, Cr, Cb
      - Yes
    * - V4L2_PIX_FMT_YUV411P
      - '411P'
      - 8
      - 4:1:1
      - Y, Cb, Cr
      - Yes
    * - V4L2_PIX_FMT_YUV420M
      - 'YM12'
      - 8
      - 4:2:0
      - Y, Cb, Cr
      - No
    * - V4L2_PIX_FMT_YVU420M
      - 'YM21'
      - 8
      - 4:2:0
      - Y, Cr, Cb
      - No
    * - V4L2_PIX_FMT_YUV420
      - 'YU12'
      - 8
      - 4:2:0
      - Y, Cb, Cr
      - Yes
    * - V4L2_PIX_FMT_YVU420
      - 'YV12'
      - 8
      - 4:2:0
      - Y, Cr, Cb
      - Yes
    * - V4L2_PIX_FMT_YUV422P
      - '422P'
      - 8
      - 4:2:2
      - Y, Cb, Cr
      - Yes
    * - V4L2_PIX_FMT_YUV422M
      - 'YM16'
      - 8
      - 4:2:2
      - Y, Cb, Cr
      - No
    * - V4L2_PIX_FMT_YVU422M
      - 'YM61'
      - 8
      - 4:2:2
      - Y, Cr, Cb
      - No
    * - V4L2_PIX_FMT_YUV444M
      - 'YM24'
      - 8
      - 4:4:4
      - Y, Cb, Cr
      - No
    * - V4L2_PIX_FMT_YVU444M
      - 'YM42'
      - 8
      - 4:4:4
      - Y, Cr, Cb
      - No

.. raw:: latex

    \normalsize

.. [4] Order of luma and chroma planes
.. [5] Indicates if planes have to be contiguous in memory or can be
       disjoint


ZZ0001ZZ
Mẫu sắc độ là ZZ0000ZZ
theo chiều ngang.

.. _V4L2-PIX-FMT-YUV410:
.. _V4L2-PIX-FMT-YVU410:

YUV410 và YVU410
-----------------

Định dạng phẳng YUV 4:1:0. Các mặt phẳng sắc độ được lấy mẫu con 4 trong mỗi
hướng. Các dòng Chroma chứa một phần tư số pixel và byte của
các đường luma và các mặt phẳng sắc độ chứa một phần tư số đường
của mặt phẳng luma.

.. flat-table:: Sample 4x4 YUV410 Image
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 16:
      - Cr\ :sub:`00`
    * - start + 17:
      - Cb\ :sub:`00`


.. _V4L2-PIX-FMT-YUV411P:

YUV411P
-------

Định dạng phẳng YUV 4:1:1. Các mặt phẳng sắc độ được lấy mẫu con bằng 4 trong
hướng ngang. Các dòng Chroma chứa một phần tư số pixel
và byte của các dòng độ sáng và các mặt phẳng sắc độ chứa cùng số lượng
các đường thẳng như mặt phẳng luma.

.. flat-table:: Sample 4x4 YUV411P Image
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 16:
      - Cb\ :sub:`00`
    * - start + 17:
      - Cb\ :sub:`10`
    * - start + 18:
      - Cb\ :sub:`20`
    * - start + 19:
      - Cb\ :sub:`30`
    * - start + 20:
      - Cr\ :sub:`00`
    * - start + 21:
      - Cr\ :sub:`10`
    * - start + 22:
      - Cr\ :sub:`20`
    * - start + 23:
      - Cr\ :sub:`30`


.. _V4L2-PIX-FMT-YUV420:
.. _V4L2-PIX-FMT-YVU420:
.. _V4L2-PIX-FMT-YUV420M:
.. _V4L2-PIX-FMT-YVU420M:

YUV420, YVU420, YUV420M và YVU420M
-----------------------------------

Định dạng phẳng YUV 4:2:0. Các mặt phẳng sắc độ được lấy mẫu con 2 trong mỗi
hướng. Các dòng Chroma chứa một nửa số pixel và byte của
các đường luma và các mặt phẳng sắc độ chứa một nửa số đường của
mặt phẳng luma.

.. flat-table:: Sample 4x4 YUV420 Image
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 16:
      - Cr\ :sub:`00`
      - Cr\ :sub:`01`
    * - start + 18:
      - Cr\ :sub:`10`
      - Cr\ :sub:`11`
    * - start + 20:
      - Cb\ :sub:`00`
      - Cb\ :sub:`01`
    * - start + 22:
      - Cb\ :sub:`10`
      - Cb\ :sub:`11`

.. flat-table:: Sample 4x4 YUV420M Image
    :header-rows:  0
    :stub-columns: 0

    * - start0 + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start0 + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start0 + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start0 + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * -
    * - start1 + 0:
      - Cb\ :sub:`00`
      - Cb\ :sub:`01`
    * - start1 + 2:
      - Cb\ :sub:`10`
      - Cb\ :sub:`11`
    * -
    * - start2 + 0:
      - Cr\ :sub:`00`
      - Cr\ :sub:`01`
    * - start2 + 2:
      - Cr\ :sub:`10`
      - Cr\ :sub:`11`


.. _V4L2-PIX-FMT-YUV422P:
.. _V4L2-PIX-FMT-YUV422M:
.. _V4L2-PIX-FMT-YVU422M:

YUV422P, YUV422M và YVU422M
----------------------------

Định dạng phẳng YUV 4:2:2. Các mặt phẳng sắc độ được lấy mẫu con bằng 2 trong
hướng ngang. Các dòng Chroma chứa một nửa số pixel và
byte của các dòng luma và các mặt phẳng sắc độ chứa cùng số dòng
như mặt phẳng luma.

.. flat-table:: Sample 4x4 YUV422P Image
    :header-rows:  0
    :stub-columns: 0

    * - start + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * - start + 16:
      - Cb\ :sub:`00`
      - Cb\ :sub:`01`
    * - start + 18:
      - Cb\ :sub:`10`
      - Cb\ :sub:`11`
    * - start + 20:
      - Cb\ :sub:`20`
      - Cb\ :sub:`21`
    * - start + 22:
      - Cb\ :sub:`30`
      - Cb\ :sub:`31`
    * - start + 24:
      - Cr\ :sub:`00`
      - Cr\ :sub:`01`
    * - start + 26:
      - Cr\ :sub:`10`
      - Cr\ :sub:`11`
    * - start + 28:
      - Cr\ :sub:`20`
      - Cr\ :sub:`21`
    * - start + 30:
      - Cr\ :sub:`30`
      - Cr\ :sub:`31`

.. flat-table:: Sample 4x4 YUV422M Image
    :header-rows:  0
    :stub-columns: 0

    * - start0 + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start0 + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start0 + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start0 + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * -
    * - start1 + 0:
      - Cb\ :sub:`00`
      - Cb\ :sub:`01`
    * - start1 + 2:
      - Cb\ :sub:`10`
      - Cb\ :sub:`11`
    * - start1 + 4:
      - Cb\ :sub:`20`
      - Cb\ :sub:`21`
    * - start1 + 6:
      - Cb\ :sub:`30`
      - Cb\ :sub:`31`
    * -
    * - start2 + 0:
      - Cr\ :sub:`00`
      - Cr\ :sub:`01`
    * - start2 + 2:
      - Cr\ :sub:`10`
      - Cr\ :sub:`11`
    * - start2 + 4:
      - Cr\ :sub:`20`
      - Cr\ :sub:`21`
    * - start2 + 6:
      - Cr\ :sub:`30`
      - Cr\ :sub:`31`


.. _V4L2-PIX-FMT-YUV444M:
.. _V4L2-PIX-FMT-YVU444M:

YUV444M và YVU444M
-------------------

Định dạng phẳng YUV 4:4:4. Các mặt phẳng sắc độ không có mẫu phụ. Đường màu
chứa cùng số lượng pixel và byte của các dòng luma và sắc độ
các mặt phẳng chứa cùng số đường như mặt phẳng luma.

.. flat-table:: Sample 4x4 YUV444M Image
    :header-rows:  0
    :stub-columns: 0

    * - start0 + 0:
      - Y'\ :sub:`00`
      - Y'\ :sub:`01`
      - Y'\ :sub:`02`
      - Y'\ :sub:`03`
    * - start0 + 4:
      - Y'\ :sub:`10`
      - Y'\ :sub:`11`
      - Y'\ :sub:`12`
      - Y'\ :sub:`13`
    * - start0 + 8:
      - Y'\ :sub:`20`
      - Y'\ :sub:`21`
      - Y'\ :sub:`22`
      - Y'\ :sub:`23`
    * - start0 + 12:
      - Y'\ :sub:`30`
      - Y'\ :sub:`31`
      - Y'\ :sub:`32`
      - Y'\ :sub:`33`
    * -
    * - start1 + 0:
      - Cb\ :sub:`00`
      - Cb\ :sub:`01`
      - Cb\ :sub:`02`
      - Cb\ :sub:`03`
    * - start1 + 4:
      - Cb\ :sub:`10`
      - Cb\ :sub:`11`
      - Cb\ :sub:`12`
      - Cb\ :sub:`13`
    * - start1 + 8:
      - Cb\ :sub:`20`
      - Cb\ :sub:`21`
      - Cb\ :sub:`22`
      - Cb\ :sub:`23`
    * - start1 + 12:
      - Cb\ :sub:`20`
      - Cb\ :sub:`21`
      - Cb\ :sub:`32`
      - Cb\ :sub:`33`
    * -
    * - start2 + 0:
      - Cr\ :sub:`00`
      - Cr\ :sub:`01`
      - Cr\ :sub:`02`
      - Cr\ :sub:`03`
    * - start2 + 4:
      - Cr\ :sub:`10`
      - Cr\ :sub:`11`
      - Cr\ :sub:`12`
      - Cr\ :sub:`13`
    * - start2 + 8:
      - Cr\ :sub:`20`
      - Cr\ :sub:`21`
      - Cr\ :sub:`22`
      - Cr\ :sub:`23`
    * - start2 + 12:
      - Cr\ :sub:`30`
      - Cr\ :sub:`31`
      - Cr\ :sub:`32`
      - Cr\ :sub:`33`