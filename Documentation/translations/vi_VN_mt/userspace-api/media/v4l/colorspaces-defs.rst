.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/colorspaces-defs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

****************************
Xác định không gian màu trong V4L2
****************************

Trong không gian màu V4L2 được xác định bởi bốn giá trị. Đầu tiên là
mã định danh không gian màu (enum ZZ0000ZZ)
trong đó xác định màu sắc, hàm truyền mặc định,
mã hóa Y'CbCr mặc định và phương pháp lượng tử hóa mặc định. thứ hai
là định danh hàm truyền (enum
ZZ0001ZZ) để chỉ định không chuẩn
các hàm truyền. Thứ ba là mã định danh mã hóa Y'CbCr (enum
ZZ0002ZZ) để chỉ định
mã hóa Y'CbCr không chuẩn và thứ tư là lượng tử hóa
mã định danh (enum ZZ0003ZZ) thành
chỉ định các phương pháp lượng tử hóa không chuẩn. Hầu hết thời gian chỉ có
trường không gian màu của cấu trúc ZZ0004ZZ
hoặc cấu trúc ZZ0005ZZ
cần phải điền vào.

.. _hsv-colorspace:

Trên ZZ0000ZZ ZZ0002ZZ được định nghĩa là góc trên
biểu diễn màu hình trụ. Thông thường góc này được đo bằng
độ, tức là 0-360. Khi chúng ta ánh xạ giá trị góc này thành 8 bit, có
hai cách cơ bản để thực hiện: Chia giá trị góc cho 2 (0-179) hoặc sử dụng
toàn bộ phạm vi, 0-255, chia giá trị góc cho 1,41. enum
ZZ0001ZZ chỉ định mã hóa nào được sử dụng.

.. note:: The default R'G'B' quantization is full range for all
   colorspaces. HSV formats are always full range.

.. tabularcolumns:: |p{6.7cm}|p{10.8cm}|

.. c:type:: v4l2_colorspace

.. flat-table:: V4L2 Colorspaces
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Details
    * - ``V4L2_COLORSPACE_DEFAULT``
      - The default colorspace. This can be used by applications to let
	the driver fill in the colorspace.
    * - ``V4L2_COLORSPACE_SMPTE170M``
      - See :ref:`col-smpte-170m`.
    * - ``V4L2_COLORSPACE_REC709``
      - See :ref:`col-rec709`.
    * - ``V4L2_COLORSPACE_SRGB``
      - See :ref:`col-srgb`.
    * - ``V4L2_COLORSPACE_OPRGB``
      - See :ref:`col-oprgb`.
    * - ``V4L2_COLORSPACE_BT2020``
      - See :ref:`col-bt2020`.
    * - ``V4L2_COLORSPACE_DCI_P3``
      - See :ref:`col-dcip3`.
    * - ``V4L2_COLORSPACE_SMPTE240M``
      - See :ref:`col-smpte-240m`.
    * - ``V4L2_COLORSPACE_470_SYSTEM_M``
      - See :ref:`col-sysm`.
    * - ``V4L2_COLORSPACE_470_SYSTEM_BG``
      - See :ref:`col-sysbg`.
    * - ``V4L2_COLORSPACE_JPEG``
      - See :ref:`col-jpeg`.
    * - ``V4L2_COLORSPACE_RAW``
      - The raw colorspace. This is used for raw image capture where the
	image is minimally processed and is using the internal colorspace
	of the device. The software that processes an image using this
	'colorspace' will have to know the internals of the capture
	device.



.. c:type:: v4l2_xfer_func

.. tabularcolumns:: |p{5.5cm}|p{12.0cm}|

.. flat-table:: V4L2 Transfer Function
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Details
    * - ``V4L2_XFER_FUNC_DEFAULT``
      - Use the default transfer function as defined by the colorspace.
    * - ``V4L2_XFER_FUNC_709``
      - Use the Rec. 709 transfer function.
    * - ``V4L2_XFER_FUNC_SRGB``
      - Use the sRGB transfer function.
    * - ``V4L2_XFER_FUNC_OPRGB``
      - Use the opRGB transfer function.
    * - ``V4L2_XFER_FUNC_SMPTE240M``
      - Use the SMPTE 240M transfer function.
    * - ``V4L2_XFER_FUNC_NONE``
      - Do not use a transfer function (i.e. use linear RGB values).
    * - ``V4L2_XFER_FUNC_DCI_P3``
      - Use the DCI-P3 transfer function.
    * - ``V4L2_XFER_FUNC_SMPTE2084``
      - Use the SMPTE 2084 transfer function. See :ref:`xf-smpte-2084`.



.. c:type:: v4l2_ycbcr_encoding

.. tabularcolumns:: |p{7.2cm}|p{10.3cm}|

.. flat-table:: V4L2 Y'CbCr Encodings
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Details
    * - ``V4L2_YCBCR_ENC_DEFAULT``
      - Use the default Y'CbCr encoding as defined by the colorspace.
    * - ``V4L2_YCBCR_ENC_601``
      - Use the BT.601 Y'CbCr encoding.
    * - ``V4L2_YCBCR_ENC_709``
      - Use the Rec. 709 Y'CbCr encoding.
    * - ``V4L2_YCBCR_ENC_XV601``
      - Use the extended gamut xvYCC BT.601 encoding.
    * - ``V4L2_YCBCR_ENC_XV709``
      - Use the extended gamut xvYCC Rec. 709 encoding.
    * - ``V4L2_YCBCR_ENC_BT2020``
      - Use the default non-constant luminance BT.2020 Y'CbCr encoding.
    * - ``V4L2_YCBCR_ENC_BT2020_CONST_LUM``
      - Use the constant luminance BT.2020 Yc'CbcCrc encoding.
    * - ``V4L2_YCBCR_ENC_SMPTE_240M``
      - Use the SMPTE 240M Y'CbCr encoding.



.. c:type:: v4l2_hsv_encoding

.. tabularcolumns:: |p{6.5cm}|p{11.0cm}|

.. flat-table:: V4L2 HSV Encodings
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Details
    * - ``V4L2_HSV_ENC_180``
      - For the Hue, each LSB is two degrees.
    * - ``V4L2_HSV_ENC_256``
      - For the Hue, the 360 degrees are mapped into 8 bits, i.e. each
	LSB is roughly 1.41 degrees.



.. c:type:: v4l2_quantization

.. tabularcolumns:: |p{6.5cm}|p{11.0cm}|

.. flat-table:: V4L2 Quantization Methods
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Details
    * - ``V4L2_QUANTIZATION_DEFAULT``
      - Use the default quantization encoding as defined by the
	colorspace. This is always full range for R'G'B' and HSV.
	It is usually limited range for Y'CbCr.
    * - ``V4L2_QUANTIZATION_FULL_RANGE``
      - Use the full range quantization encoding. I.e. the range [0…1] is
	mapped to [0…255] (with possible clipping to [1…254] to avoid the
	0x00 and 0xff values). Cb and Cr are mapped from [-0.5…0.5] to
	[0…255] (with possible clipping to [1…254] to avoid the 0x00 and
	0xff values).
    * - ``V4L2_QUANTIZATION_LIM_RANGE``
      - Use the limited range quantization encoding. I.e. the range [0…1]
	is mapped to [16…235]. Cb and Cr are mapped from [-0.5…0.5] to
	[16…240]. Limited Range cannot be used with HSV.