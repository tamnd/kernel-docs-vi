.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/subdev-formats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-mbus-format:

Định dạng xe buýt đa phương tiện
================================

.. c:type:: v4l2_mbus_framefmt

.. tabularcolumns:: |p{2.0cm}|p{4.0cm}|p{11.3cm}|

.. cssclass:: longtable

.. flat-table:: struct v4l2_mbus_framefmt
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``width``
      - Image width in pixels.
    * - __u32
      - ``height``
      - Image height in pixels. If ``field`` is one of ``V4L2_FIELD_TOP``,
	``V4L2_FIELD_BOTTOM`` or ``V4L2_FIELD_ALTERNATE`` then height
	refers to the number of lines in the field, otherwise it refers to
	the number of lines in the frame (which is twice the field height
	for interlaced formats).
    * - __u32
      - ``code``
      - Format code, from enum
	:ref:`v4l2_mbus_pixelcode <v4l2-mbus-pixelcode>`.
    * - __u32
      - ``field``
      - Field order, from enum :c:type:`v4l2_field`. See
	:ref:`field-order` for details. Zero for metadata mbus codes.
    * - __u32
      - ``colorspace``
      - Image colorspace, from enum :c:type:`v4l2_colorspace`.
        Must be set by the driver for subdevices. If the application sets the
	flag ``V4L2_MBUS_FRAMEFMT_SET_CSC`` then the application can set this
	field on the source pad to request a specific colorspace for the media
	bus data. If the driver cannot handle the requested conversion, it will
	return another supported colorspace. The driver indicates that colorspace
	conversion is supported by setting the flag
	V4L2_SUBDEV_MBUS_CODE_CSC_COLORSPACE in the corresponding struct
	:c:type:`v4l2_subdev_mbus_code_enum` during enumeration.
	See :ref:`v4l2-subdev-mbus-code-flags`. Zero for metadata mbus codes.
    * - union {
      - (anonymous)
    * - __u16
      - ``ycbcr_enc``
      - Y'CbCr encoding, from enum :c:type:`v4l2_ycbcr_encoding`.
        This information supplements the ``colorspace`` and must be set by
	the driver for subdevices, see :ref:`colorspaces`. If the application
	sets the flag ``V4L2_MBUS_FRAMEFMT_SET_CSC`` then the application can set
	this field on a source pad to request a specific Y'CbCr encoding
	for the media bus data. If the driver cannot handle the requested
	conversion, it will return another supported encoding.
	This field is ignored for HSV media bus formats. The driver indicates
	that ycbcr_enc conversion is supported by setting the flag
	V4L2_SUBDEV_MBUS_CODE_CSC_YCBCR_ENC in the corresponding struct
	:c:type:`v4l2_subdev_mbus_code_enum` during enumeration.
	See :ref:`v4l2-subdev-mbus-code-flags`. Zero for metadata mbus codes.
    * - __u16
      - ``hsv_enc``
      - HSV encoding, from enum :c:type:`v4l2_hsv_encoding`.
        This information supplements the ``colorspace`` and must be set by
	the driver for subdevices, see :ref:`colorspaces`. If the application
	sets the flag ``V4L2_MBUS_FRAMEFMT_SET_CSC`` then the application can set
	this field on a source pad to request a specific HSV encoding
	for the media bus data. If the driver cannot handle the requested
	conversion, it will return another supported encoding.
	This field is ignored for Y'CbCr media bus formats. The driver indicates
	that hsv_enc conversion is supported by setting the flag
	V4L2_SUBDEV_MBUS_CODE_CSC_HSV_ENC in the corresponding struct
	:c:type:`v4l2_subdev_mbus_code_enum` during enumeration.
	See :ref:`v4l2-subdev-mbus-code-flags`. Zero for metadata mbus codes.
    * - }
      -
    * - __u16
      - ``quantization``
      - Quantization range, from enum :c:type:`v4l2_quantization`.
        This information supplements the ``colorspace`` and must be set by
	the driver for subdevices, see :ref:`colorspaces`. If the application
	sets the flag ``V4L2_MBUS_FRAMEFMT_SET_CSC`` then the application can set
	this field on a source pad to request a specific quantization
	for the media bus data. If the driver cannot handle the requested
	conversion, it will return another supported quantization.
	The driver indicates that quantization conversion is supported by
	setting the flag V4L2_SUBDEV_MBUS_CODE_CSC_QUANTIZATION in the
	corresponding struct :c:type:`v4l2_subdev_mbus_code_enum`
	during enumeration. See :ref:`v4l2-subdev-mbus-code-flags`. Zero for
	metadata mbus codes.
    * - __u16
      - ``xfer_func``
      - Transfer function, from enum :c:type:`v4l2_xfer_func`.
        This information supplements the ``colorspace`` and must be set by
	the driver for subdevices, see :ref:`colorspaces`. If the application
	sets the flag ``V4L2_MBUS_FRAMEFMT_SET_CSC`` then the application can set
	this field on a source pad to request a specific transfer
	function for the media bus data. If the driver cannot handle the requested
	conversion, it will return another supported transfer function.
	The driver indicates that the transfer function conversion is supported by
	setting the flag V4L2_SUBDEV_MBUS_CODE_CSC_XFER_FUNC in the
	corresponding struct :c:type:`v4l2_subdev_mbus_code_enum`
	during enumeration. See :ref:`v4l2-subdev-mbus-code-flags`. Zero for
	metadata mbus codes.
    * - __u16
      - ``flags``
      - flags See:  :ref:v4l2-mbus-framefmt-flags
    * - __u16
      - ``reserved``\ [10]
      - Reserved for future extensions. Applications and drivers must set
	the array to zero.

.. _v4l2-mbus-framefmt-flags:

.. tabularcolumns:: |p{6.5cm}|p{1.6cm}|p{9.2cm}|

.. flat-table:: v4l2_mbus_framefmt Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * .. _`mbus-framefmt-set-csc`:

      - ``V4L2_MBUS_FRAMEFMT_SET_CSC``
      - 0x0001
      - Set by the application. It is only used for source pads and is
	ignored for sink pads. If set, then request the subdevice to do
	colorspace conversion from the received colorspace to the requested
	colorspace values. If the colorimetry field (``colorspace``, ``xfer_func``,
	``ycbcr_enc``, ``hsv_enc`` or ``quantization``) is set to ``*_DEFAULT``,
	then that colorimetry setting will remain unchanged from what was received.
	So in order to change the quantization, only the ``quantization`` field shall
	be set to non default value (``V4L2_QUANTIZATION_FULL_RANGE`` or
	``V4L2_QUANTIZATION_LIM_RANGE``) and all other colorimetry fields shall
	be set to ``*_DEFAULT``.

	To check which conversions are supported by the hardware for the current
	media bus frame format, see :ref:`v4l2-subdev-mbus-code-flags`.


.. _v4l2-mbus-pixelcode:

Mã pixel của phương tiện truyền thông
-------------------------------------

Mã pixel bus phương tiện mô tả các định dạng hình ảnh chuyển qua
các bus vật lý (cả giữa các thành phần vật lý riêng biệt và bên trong
thiết bị SoC). Không nên nhầm lẫn điều này với các định dạng pixel V4L2
mô tả, sử dụng bốn mã ký tự, định dạng hình ảnh được lưu trữ trong
trí nhớ.

Mặc dù có mối quan hệ giữa các định dạng hình ảnh trên xe buýt và hình ảnh
định dạng trong bộ nhớ (hình ảnh thô của Bayer sẽ không được chuyển đổi một cách kỳ diệu thành
JPEG chỉ bằng cách lưu trữ vào bộ nhớ), không có một đối một
thư từ giữa chúng.

Mặc dù mã pixel bus phương tiện được đặt tên dựa trên cách thức các pixel
được truyền trên các bus song song, các bus nối tiếp không xác định các bus riêng biệt
mã. Theo quy ước, họ sử dụng các mã để chuyển mẫu trên một
chu kỳ xung nhịp đơn và có thứ tự bit từ LSB đến MSB tương ứng với
thứ tự các thành phần màu được truyền trên bus nối tiếp.
Ví dụ: định dạng MIPI CSI-2 24-bit RGB (RGB888) sử dụng định dạng
Mã bus phương tiện MEDIA_BUS_FMT_RGB888_1X24 vì CSI-2 truyền
thành phần màu xanh lam đầu tiên, tiếp theo là xanh lục và đỏ, và
MEDIA_BUS_FMT_RGB888_1X24 xác định bit màu xanh đầu tiên ở bit 0.
Khi được sử dụng cho dữ liệu RGB 24 bit trên các bus song song,
Không được có mã MEDIA_BUS_FMT_RGB888_3X8 hoặc MEDIA_BUS_FMT_BGR888_1X24
được sử dụng cho CSI-2.

Các định dạng RGB được đóng gói
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các định dạng đó truyền dữ liệu pixel dưới dạng các thành phần màu đỏ, xanh lục và xanh lam. các
mã định dạng được tạo từ các thông tin sau.

- Mã thứ tự các thành phần màu đỏ, xanh lá cây và xanh lam, được mã hóa bằng pixel
   mẫu. Các giá trị có thể có là RGB và BGR.

- Số bit trên mỗi thành phần, cho từng thành phần. Các giá trị có thể
   khác nhau đối với tất cả các thành phần. Giá trị phổ biến là 555 và 565.

- Số lượng mẫu xe buýt trên mỗi pixel. Các pixel rộng hơn
   chiều rộng bus phải được chuyển trong nhiều mẫu. Các giá trị chung là
   1 và 2.

- Chiều rộng xe buýt.

- Đối với các định dạng có tổng số bit trên mỗi pixel nhỏ hơn
   số lượng mẫu bus trên mỗi pixel nhân với chiều rộng bus, phần đệm
   giá trị cho biết liệu các byte có được đệm ở các bit có thứ tự cao nhất hay không
   (PADHI) hoặc bit thứ tự thấp (PADLO). Tiền tố "C" được sử dụng cho
   đệm theo thành phần ở các bit có thứ tự cao nhất (CPADHI) hoặc thấp
   bit thứ tự (CPADLO) của từng thành phần riêng biệt.

- Đối với các định dạng có số lượng mẫu bus trên mỗi pixel lớn hơn
   1, giá trị độ bền cho biết liệu pixel có được truyền MSB trước không
   (BE) hoặc LSB trước (LE).

Ví dụ: định dạng trong đó pixel được mã hóa thành 5 bit màu đỏ, 5 bit
các giá trị xanh lục và 5 bit xanh lam được đệm ở bit cao, được chuyển thành 2
Các mẫu 8 bit trên mỗi pixel với các bit quan trọng nhất (đệm, đỏ và
một nửa giá trị màu xanh) được chuyển trước sẽ được đặt tên
ZZ0000ZZ.

Các bảng sau liệt kê các định dạng RGB được đóng gói hiện có.

.. HACK: ideally, we would be using adjustbox here. However, Sphinx
.. is a very bad behaviored guy: if the table has more than 30 cols,
.. it switches to long table, and there's no way to override it.


.. tabularcolumns:: |p{5.0cm}|p{0.7cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _v4l2-mbus-pixelcode-rgb:

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. flat-table:: RGB formats
    :header-rows:  2
    :stub-columns: 0
    :widths: 36 7 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

    * - Identifier
      - Code
      -
      - :cspan:`31` Data organization
    * -
      -
      - Bit
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
    * .. _MEDIA-BUS-FMT-RGB444-1X12:

      - MEDIA_BUS_FMT_RGB444_1X12
      - 0x1016
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB444-2X8-PADHI-BE:

      - MEDIA_BUS_FMT_RGB444_2X8_PADHI_BE
      - 0x1001
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - 0
      - 0
      - 0
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB444-2X8-PADHI-LE:

      - MEDIA_BUS_FMT_RGB444_2X8_PADHI_LE
      - 0x1002
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - 0
      - 0
      - 0
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB555-2X8-PADHI-BE:

      - MEDIA_BUS_FMT_RGB555_2X8_PADHI_BE
      - 0x1003
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB555-2X8-PADHI-LE:

      - MEDIA_BUS_FMT_RGB555_2X8_PADHI_LE
      - 0x1004
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`4`
      - g\ :sub:`3`
    * .. _MEDIA-BUS-FMT-RGB565-1X16:

      - MEDIA_BUS_FMT_RGB565_1X16
      - 0x1017
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * .. _MEDIA-BUS-FMT-BGR565-2X8-BE:

      - MEDIA_BUS_FMT_BGR565_2X8_BE
      - 0x1005
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-BGR565-2X8-LE:

      - MEDIA_BUS_FMT_BGR565_2X8_LE
      - 0x1006
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
    * .. _MEDIA-BUS-FMT-RGB565-2X8-BE:

      - MEDIA_BUS_FMT_RGB565_2X8_BE
      - 0x1007
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB565-2X8-LE:

      - MEDIA_BUS_FMT_RGB565_2X8_LE
      - 0x1008
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
    * .. _MEDIA-BUS-FMT-RGB666-1X18:

      - MEDIA_BUS_FMT_RGB666_1X18
      - 0x1009
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`5`
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
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB666-2X9-BE:

      - MEDIA_BUS_FMT_RGB666_2X9_BE
      - 0x1025
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-BGR666-1X18:

      - MEDIA_BUS_FMT_BGR666_1X18
      - 0x1023
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * .. _MEDIA-BUS-FMT-RBG888-1X24:

      - MEDIA_BUS_FMT_RBG888_1X24
      - 0x100e
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
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
    * .. _MEDIA-BUS-FMT-RGB666-1X24_CPADHI:

      - MEDIA_BUS_FMT_RGB666_1X24_CPADHI
      - 0x1015
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - 0
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - 0
      - 0
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - 0
      - 0
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-BGR666-1X24_CPADHI:

      - MEDIA_BUS_FMT_BGR666_1X24_CPADHI
      - 0x1024
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - 0
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - 0
      - 0
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - 0
      - 0
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB565-1X24_CPADHI:

      - MEDIA_BUS_FMT_RGB565_1X24_CPADHI
      - 0x1022
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - 0
      - 0
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - 0
      - 0
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - 0
      - 0
      - 0
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-BGR888-1X24:

      - MEDIA_BUS_FMT_BGR888_1X24
      - 0x1013
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * .. _MEDIA-BUS-FMT-BGR888-3X8:

      - MEDIA_BUS_FMT_BGR888_3X8
      - 0x101b
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-GBR888-1X24:

      - MEDIA_BUS_FMT_GBR888_1X24
      - 0x1014
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB888-1X24:

      - MEDIA_BUS_FMT_RGB888_1X24
      - 0x100a
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * .. _MEDIA-BUS-FMT-RGB888-2X12-BE:

      - MEDIA_BUS_FMT_RGB888_2X12_BE
      - 0x100b
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * .. _MEDIA-BUS-FMT-RGB888-2X12-LE:

      - MEDIA_BUS_FMT_RGB888_2X12_LE
      - 0x100c
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * .. _MEDIA-BUS-FMT-RGB888-3X8:

      - MEDIA_BUS_FMT_RGB888_3X8
      - 0x101c
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB666-1X30-CPADLO:

      - MEDIA_BUS_FMT_RGB666_1X30-CPADLO
      - 0x101e
      -
      -
      -
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
    * .. _MEDIA-BUS-FMT-RGB888-1X30-CPADLO:

      - MEDIA_BUS_FMT_RGB888_1X30-CPADLO
      - 0x101f
      -
      -
      -
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - 0
      - 0
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - 0
      - 0
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - 0
      - 0
    * .. _MEDIA-BUS-FMT-ARGB888-1X32:

      - MEDIA_BUS_FMT_ARGB888_1X32
      - 0x100d
      -
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
    * .. _MEDIA-BUS-FMT-RGB888-1X32-PADHI:

      - MEDIA_BUS_FMT_RGB888_1X32_PADHI
      - 0x100f
      -
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
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
    * .. _MEDIA-BUS-FMT-RGB101010-1X30:

      - MEDIA_BUS_FMT_RGB101010_1X30
      - 0x1018
      -
      -
      -
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`9`
      - b\ :sub:`8`
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


Bảng sau liệt kê các định dạng RGB rộng 36 bit hiện có.

.. tabularcolumns:: |p{4.0cm}|p{0.7cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _v4l2-mbus-pixelcode-rgb-36:

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. flat-table:: 36bit RGB formats
    :header-rows:  2
    :stub-columns: 0
    :widths: 36 7 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

    * - Identifier
      - Code
      -
      - :cspan:`35` Data organization
    * -
      -
      - Bit
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
    * .. _MEDIA-BUS-FMT-RGB666-1X36-CPADLO:

      - MEDIA_BUS_FMT_RGB666_1X36_CPADLO
      - 0x1020
      -
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
    * .. _MEDIA-BUS-FMT-RGB888-1X36-CPADLO:

      - MEDIA_BUS_FMT_RGB888_1X36_CPADLO
      - 0x1021
      -
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
    * .. _MEDIA-BUS-FMT-RGB121212-1X36:

      - MEDIA_BUS_FMT_RGB121212_1X36
      - 0x1019
      -
      - r\ :sub:`11`
      - r\ :sub:`10`
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`11`
      - b\ :sub:`10`
      - b\ :sub:`9`
      - b\ :sub:`8`
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


Bảng sau liệt kê các định dạng RGB rộng 48 bit hiện có.

.. tabularcolumns:: |p{4.0cm}|p{0.7cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _v4l2-mbus-pixelcode-rgb-48:

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. flat-table:: 48bit RGB formats
    :header-rows:  3
    :stub-columns: 0
    :widths: 36 7 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

    * - Identifier
      - Code
      -
      - :cspan:`31` Data organization
    * -
      -
      - Bit
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * -
      -
      -
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
    * .. _MEDIA-BUS-FMT-RGB161616-1X48:

      - MEDIA_BUS_FMT_RGB161616_1X48
      - 0x101a
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`15`
      - r\ :sub:`14`
      - r\ :sub:`13`
      - r\ :sub:`12`
      - r\ :sub:`11`
      - r\ :sub:`10`
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * -
      -
      -
      - g\ :sub:`15`
      - g\ :sub:`14`
      - g\ :sub:`13`
      - g\ :sub:`12`
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`15`
      - b\ :sub:`14`
      - b\ :sub:`13`
      - b\ :sub:`12`
      - b\ :sub:`11`
      - b\ :sub:`10`
      - b\ :sub:`9`
      - b\ :sub:`8`
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

Bảng sau liệt kê các định dạng RGB rộng 60 bit được đóng gói hiện có.

.. tabularcolumns:: |p{4.0cm}|p{0.7cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _v4l2-mbus-pixelcode-rgb-60:

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. flat-table:: 60bit RGB formats
    :header-rows:  3
    :stub-columns: 0
    :widths: 36 7 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

    * - Identifier
      - Code
      -
      - :cspan:`31` Data organization
    * -
      -
      - Bit
      -
      -
      -
      -
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
    * -
      -
      -
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
    * .. _MEDIA-BUS-FMT-RGB202020-1X60:

      - MEDIA_BUS_FMT_RGB202020_1X60
      - 0x1026
      -
      -
      -
      -
      -
      - r\ :sub:`19`
      - r\ :sub:`18`
      - r\ :sub:`17`
      - r\ :sub:`16`
      - r\ :sub:`15`
      - r\ :sub:`14`
      - r\ :sub:`13`
      - r\ :sub:`12`
      - r\ :sub:`11`
      - r\ :sub:`10`
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
      - g\ :sub:`19`
      - g\ :sub:`18`
      - g\ :sub:`17`
      - g\ :sub:`16`
      - g\ :sub:`15`
      - g\ :sub:`14`
      - g\ :sub:`13`
      - g\ :sub:`12`
    * -
      -
      -
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
      - b\ :sub:`19`
      - b\ :sub:`18`
      - b\ :sub:`17`
      - b\ :sub:`16`
      - b\ :sub:`15`
      - b\ :sub:`14`
      - b\ :sub:`13`
      - b\ :sub:`12`
      - b\ :sub:`11`
      - b\ :sub:`10`
      - b\ :sub:`9`
      - b\ :sub:`8`
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

Trên các bus LVDS, thông thường mỗi mẫu được chuyển theo thứ tự thành bảy
các khe thời gian trên mỗi đồng hồ pixel, trên ba (18 bit) hoặc bốn (24 bit) hoặc năm (30 bit)
cặp dữ liệu khác biệt cùng một lúc. Các bit còn lại được sử dụng
cho các tín hiệu điều khiển được xác định theo tiêu chuẩn SPWG/PSWG/VESA hoặc JEIDA. các
Định dạng RGB 24 bit được tuần tự hóa thành bảy khe thời gian trên bốn làn bằng cách sử dụng
Ánh xạ bit được xác định JEIDA sẽ được đặt tên
ZZ0000ZZ chẳng hạn.

.. raw:: latex

    \small

.. _v4l2-mbus-pixelcode-rgb-lvds:

.. flat-table:: LVDS RGB formats
    :header-rows:  2
    :stub-columns: 0

    * - Identifier
      - Code
      -
      -
      - :cspan:`4` Data organization
    * -
      -
      - Timeslot
      - Lane
      - 4
      - 3
      - 2
      - 1
      - 0
    * .. _MEDIA-BUS-FMT-RGB666-1X7X3-SPWG:

      - MEDIA_BUS_FMT_RGB666_1X7X3_SPWG
      - 0x1010
      - 0
      -
      -
      -
      - d
      - b\ :sub:`1`
      - g\ :sub:`0`
    * -
      -
      - 1
      -
      -
      -
      - d
      - b\ :sub:`0`
      - r\ :sub:`5`
    * -
      -
      - 2
      -
      -
      -
      - d
      - g\ :sub:`5`
      - r\ :sub:`4`
    * -
      -
      - 3
      -
      -
      -
      - b\ :sub:`5`
      - g\ :sub:`4`
      - r\ :sub:`3`
    * -
      -
      - 4
      -
      -
      -
      - b\ :sub:`4`
      - g\ :sub:`3`
      - r\ :sub:`2`
    * -
      -
      - 5
      -
      -
      -
      - b\ :sub:`3`
      - g\ :sub:`2`
      - r\ :sub:`1`
    * -
      -
      - 6
      -
      -
      -
      - b\ :sub:`2`
      - g\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB888-1X7X4-SPWG:

      - MEDIA_BUS_FMT_RGB888_1X7X4_SPWG
      - 0x1011
      - 0
      -
      -
      - d
      - d
      - b\ :sub:`1`
      - g\ :sub:`0`
    * -
      -
      - 1
      -
      -
      - b\ :sub:`7`
      - d
      - b\ :sub:`0`
      - r\ :sub:`5`
    * -
      -
      - 2
      -
      -
      - b\ :sub:`6`
      - d
      - g\ :sub:`5`
      - r\ :sub:`4`
    * -
      -
      - 3
      -
      -
      - g\ :sub:`7`
      - b\ :sub:`5`
      - g\ :sub:`4`
      - r\ :sub:`3`
    * -
      -
      - 4
      -
      -
      - g\ :sub:`6`
      - b\ :sub:`4`
      - g\ :sub:`3`
      - r\ :sub:`2`
    * -
      -
      - 5
      -
      -
      - r\ :sub:`7`
      - b\ :sub:`3`
      - g\ :sub:`2`
      - r\ :sub:`1`
    * -
      -
      - 6
      -
      -
      - r\ :sub:`6`
      - b\ :sub:`2`
      - g\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB888-1X7X4-JEIDA:

      - MEDIA_BUS_FMT_RGB888_1X7X4_JEIDA
      - 0x1012
      - 0
      -
      -
      - d
      - d
      - b\ :sub:`3`
      - g\ :sub:`2`
    * -
      -
      - 1
      -
      -
      - b\ :sub:`1`
      - d
      - b\ :sub:`2`
      - r\ :sub:`7`
    * -
      -
      - 2
      -
      -
      - b\ :sub:`0`
      - d
      - g\ :sub:`7`
      - r\ :sub:`6`
    * -
      -
      - 3
      -
      -
      - g\ :sub:`1`
      - b\ :sub:`7`
      - g\ :sub:`6`
      - r\ :sub:`5`
    * -
      -
      - 4
      -
      -
      - g\ :sub:`0`
      - b\ :sub:`6`
      - g\ :sub:`5`
      - r\ :sub:`4`
    * -
      -
      - 5
      -
      -
      - r\ :sub:`1`
      - b\ :sub:`5`
      - g\ :sub:`4`
      - r\ :sub:`3`
    * -
      -
      - 6
      -
      -
      - r\ :sub:`0`
      - b\ :sub:`4`
      - g\ :sub:`3`
      - r\ :sub:`2`
    * .. _MEDIA-BUS-FMT-RGB101010-1X7X5-SPWG:

      - MEDIA_BUS_FMT_RGB101010_1X7X5_SPWG
      - 0x1026
      - 0
      -
      - d
      - d
      - d
      - b\ :sub:`1`
      - g\ :sub:`0`
    * -
      -
      - 1
      -
      - b\ :sub:`9`
      - b\ :sub:`7`
      - d
      - b\ :sub:`0`
      - r\ :sub:`5`
    * -
      -
      - 2
      -
      - b\ :sub:`8`
      - b\ :sub:`6`
      - d
      - g\ :sub:`5`
      - r\ :sub:`4`
    * -
      -
      - 3
      -
      - g\ :sub:`9`
      - g\ :sub:`7`
      - b\ :sub:`5`
      - g\ :sub:`4`
      - r\ :sub:`3`
    * -
      -
      - 4
      -
      - g\ :sub:`8`
      - g\ :sub:`6`
      - b\ :sub:`4`
      - g\ :sub:`3`
      - r\ :sub:`2`
    * -
      -
      - 5
      -
      - r\ :sub:`9`
      - r\ :sub:`7`
      - b\ :sub:`3`
      - g\ :sub:`2`
      - r\ :sub:`1`
    * -
      -
      - 6
      -
      - r\ :sub:`8`
      - r\ :sub:`6`
      - b\ :sub:`2`
      - g\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-RGB101010-1X7X5-JEIDA:

      - MEDIA_BUS_FMT_RGB101010_1X7X5_JEIDA
      - 0x1027
      - 0
      -
      - d
      - d
      - d
      - b\ :sub:`5`
      - g\ :sub:`4`
    * -
      -
      - 1
      -
      - b\ :sub:`1`
      - b\ :sub:`3`
      - d
      - b\ :sub:`4`
      - r\ :sub:`9`
    * -
      -
      - 2
      -
      - b\ :sub:`0`
      - b\ :sub:`2`
      - d
      - g\ :sub:`9`
      - r\ :sub:`8`
    * -
      -
      - 3
      -
      - g\ :sub:`1`
      - g\ :sub:`3`
      - b\ :sub:`9`
      - g\ :sub:`8`
      - r\ :sub:`7`
    * -
      -
      - 4
      -
      - g\ :sub:`0`
      - g\ :sub:`2`
      - b\ :sub:`8`
      - g\ :sub:`7`
      - r\ :sub:`6`
    * -
      -
      - 5
      -
      - r\ :sub:`1`
      - r\ :sub:`3`
      - b\ :sub:`7`
      - g\ :sub:`6`
      - r\ :sub:`5`
    * -
      -
      - 6
      -
      - r\ :sub:`0`
      - r\ :sub:`2`
      - b\ :sub:`6`
      - g\ :sub:`5`
      - r\ :sub:`4`

.. raw:: latex

    \normalsize


Định dạng của Bayer
^^^^^^^^^^^^^^^^^^^

Các định dạng đó truyền dữ liệu pixel dưới dạng các thành phần màu đỏ, xanh lục và xanh lam. các
mã định dạng được tạo từ các thông tin sau.

- Mã thứ tự các thành phần màu đỏ, xanh lá cây và xanh lam, được mã hóa bằng pixel
   mẫu. Các giá trị có thể được hiển thị trong ZZ0000ZZ.

- Số bit trên mỗi thành phần pixel. Tất cả các thành phần đều
   được truyền trên cùng một số bit. Các giá trị phổ biến là 8, 10 và
   12.

- Việc nén (tùy chọn). Nếu các thành phần pixel là ALAW- hoặc
   DPCM-nén, đề cập đến sơ đồ nén và số lượng
   số bit trên mỗi thành phần pixel được nén.

- Số lượng mẫu xe buýt trên mỗi pixel. Các pixel rộng hơn
   chiều rộng bus phải được chuyển trong nhiều mẫu. Các giá trị chung là
   1 và 2.

- Chiều rộng xe buýt.

- Đối với các định dạng có tổng số bit trên mỗi pixel nhỏ hơn
   số lượng mẫu bus trên mỗi pixel nhân với chiều rộng bus, phần đệm
   giá trị cho biết liệu các byte có được đệm ở các bit có thứ tự cao nhất hay không
   (PADHI) hoặc bit thứ tự thấp (PADLO).

- Đối với các định dạng có số lượng mẫu bus trên mỗi pixel lớn hơn
   1, giá trị độ bền cho biết liệu pixel có được truyền MSB trước không
   (BE) hoặc LSB trước (LE).

Ví dụ: một định dạng có các thành phần Bayer 10 bit không nén
được sắp xếp theo mẫu màu đỏ, lục, lục, lam được chuyển thành 2 8 bit
mẫu trên mỗi pixel có bit ít quan trọng nhất được truyền trước sẽ
được đặt tên là ZZ0000ZZ.


.. _bayer-patterns:

.. kernel-figure:: bayer.svg
    :alt:    bayer.svg
    :align:  center

    Bayer Patterns

Bảng sau liệt kê các định dạng Bayer được đóng gói hiện có. Dữ liệu
tổ chức chỉ được đưa ra làm ví dụ cho pixel đầu tiên.


.. HACK: ideally, we would be using adjustbox here. However, Sphinx
.. is a very bad behaviored guy: if the table has more than 30 cols,
.. it switches to long table, and there's no way to override it.


.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{6.0cm}|p{0.7cm}|p{0.3cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _v4l2-mbus-pixelcode-bayer:

.. cssclass: longtable

.. flat-table:: Bayer Formats
    :header-rows:  2
    :stub-columns: 0

    * - Identifier
      - Code
      -
      - :cspan:`19` Data organization
    * -
      -
      - Bit
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
    * .. _MEDIA-BUS-FMT-SBGGR8-1X8:

      - MEDIA_BUS_FMT_SBGGR8_1X8
      - 0x3001
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGBRG8-1X8:

      - MEDIA_BUS_FMT_SGBRG8_1X8
      - 0x3013
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGRBG8-1X8:

      - MEDIA_BUS_FMT_SGRBG8_1X8
      - 0x3002
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SRGGB8-1X8:

      - MEDIA_BUS_FMT_SRGGB8_1X8
      - 0x3014
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SBGGR10-ALAW8-1X8:

      - MEDIA_BUS_FMT_SBGGR10_ALAW8_1X8
      - 0x3015
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGBRG10-ALAW8-1X8:

      - MEDIA_BUS_FMT_SGBRG10_ALAW8_1X8
      - 0x3016
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGRBG10-ALAW8-1X8:

      - MEDIA_BUS_FMT_SGRBG10_ALAW8_1X8
      - 0x3017
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SRGGB10-ALAW8-1X8:

      - MEDIA_BUS_FMT_SRGGB10_ALAW8_1X8
      - 0x3018
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SBGGR10-DPCM8-1X8:

      - MEDIA_BUS_FMT_SBGGR10_DPCM8_1X8
      - 0x300b
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGBRG10-DPCM8-1X8:

      - MEDIA_BUS_FMT_SGBRG10_DPCM8_1X8
      - 0x300c
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGRBG10-DPCM8-1X8:

      - MEDIA_BUS_FMT_SGRBG10_DPCM8_1X8
      - 0x3009
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SRGGB10-DPCM8-1X8:

      - MEDIA_BUS_FMT_SRGGB10_DPCM8_1X8
      - 0x300d
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SBGGR10-2X8-PADHI-BE:

      - MEDIA_BUS_FMT_SBGGR10_2X8_PADHI_BE
      - 0x3003
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - b\ :sub:`9`
      - b\ :sub:`8`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SBGGR10-2X8-PADHI-LE:

      - MEDIA_BUS_FMT_SBGGR10_2X8_PADHI_LE
      - 0x3004
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - b\ :sub:`9`
      - b\ :sub:`8`
    * .. _MEDIA-BUS-FMT-SBGGR10-2X8-PADLO-BE:

      - MEDIA_BUS_FMT_SBGGR10_2X8_PADLO_BE
      - 0x3005
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`9`
      - b\ :sub:`8`
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`1`
      - b\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
    * .. _MEDIA-BUS-FMT-SBGGR10-2X8-PADLO-LE:

      - MEDIA_BUS_FMT_SBGGR10_2X8_PADLO_LE
      - 0x3006
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`1`
      - b\ :sub:`0`
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`9`
      - b\ :sub:`8`
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
    * .. _MEDIA-BUS-FMT-SBGGR10-1X10:

      - MEDIA_BUS_FMT_SBGGR10_1X10
      - 0x3007
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`9`
      - b\ :sub:`8`
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGBRG10-1X10:

      - MEDIA_BUS_FMT_SGBRG10_1X10
      - 0x300e
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGRBG10-1X10:

      - MEDIA_BUS_FMT_SGRBG10_1X10
      - 0x300a
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SRGGB10-1X10:

      - MEDIA_BUS_FMT_SRGGB10_1X10
      - 0x300f
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SBGGR12-1X12:

      - MEDIA_BUS_FMT_SBGGR12_1X12
      - 0x3008
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`11`
      - b\ :sub:`10`
      - b\ :sub:`9`
      - b\ :sub:`8`
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGBRG12-1X12:

      - MEDIA_BUS_FMT_SGBRG12_1X12
      - 0x3010
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGRBG12-1X12:

      - MEDIA_BUS_FMT_SGRBG12_1X12
      - 0x3011
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SRGGB12-1X12:

      - MEDIA_BUS_FMT_SRGGB12_1X12
      - 0x3012
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`11`
      - r\ :sub:`10`
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SBGGR14-1X14:

      - MEDIA_BUS_FMT_SBGGR14_1X14
      - 0x3019
      -
      -
      -
      -
      -
      -
      -
      - b\ :sub:`13`
      - b\ :sub:`12`
      - b\ :sub:`11`
      - b\ :sub:`10`
      - b\ :sub:`9`
      - b\ :sub:`8`
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGBRG14-1X14:

      - MEDIA_BUS_FMT_SGBRG14_1X14
      - 0x301a
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`13`
      - g\ :sub:`12`
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGRBG14-1X14:

      - MEDIA_BUS_FMT_SGRBG14_1X14
      - 0x301b
      -
      -
      -
      -
      -
      -
      -
      - g\ :sub:`13`
      - g\ :sub:`12`
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SRGGB14-1X14:

      - MEDIA_BUS_FMT_SRGGB14_1X14
      - 0x301c
      -
      -
      -
      -
      -
      -
      -
      - r\ :sub:`13`
      - r\ :sub:`12`
      - r\ :sub:`11`
      - r\ :sub:`10`
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SBGGR16-1X16:

      - MEDIA_BUS_FMT_SBGGR16_1X16
      - 0x301d
      -
      -
      -
      -
      -
      - b\ :sub:`15`
      - b\ :sub:`14`
      - b\ :sub:`13`
      - b\ :sub:`12`
      - b\ :sub:`11`
      - b\ :sub:`10`
      - b\ :sub:`9`
      - b\ :sub:`8`
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGBRG16-1X16:

      - MEDIA_BUS_FMT_SGBRG16_1X16
      - 0x301e
      -
      -
      -
      -
      -
      - g\ :sub:`15`
      - g\ :sub:`14`
      - g\ :sub:`13`
      - g\ :sub:`12`
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGRBG16-1X16:

      - MEDIA_BUS_FMT_SGRBG16_1X16
      - 0x301f
      -
      -
      -
      -
      -
      - g\ :sub:`15`
      - g\ :sub:`14`
      - g\ :sub:`13`
      - g\ :sub:`12`
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SRGGB16-1X16:

      - MEDIA_BUS_FMT_SRGGB16_1X16
      - 0x3020
      -
      -
      -
      -
      -
      - r\ :sub:`15`
      - r\ :sub:`14`
      - r\ :sub:`13`
      - r\ :sub:`12`
      - r\ :sub:`11`
      - r\ :sub:`10`
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SBGGR20-1X20:

      - MEDIA_BUS_FMT_SBGGR20_1X20
      - 0x3021
      -
      - b\ :sub:`19`
      - b\ :sub:`18`
      - b\ :sub:`17`
      - b\ :sub:`16`
      - b\ :sub:`15`
      - b\ :sub:`14`
      - b\ :sub:`13`
      - b\ :sub:`12`
      - b\ :sub:`11`
      - b\ :sub:`10`
      - b\ :sub:`9`
      - b\ :sub:`8`
      - b\ :sub:`7`
      - b\ :sub:`6`
      - b\ :sub:`5`
      - b\ :sub:`4`
      - b\ :sub:`3`
      - b\ :sub:`2`
      - b\ :sub:`1`
      - b\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGBRG20-1X20:

      - MEDIA_BUS_FMT_SGBRG20_1X20
      - 0x3022
      -
      - g\ :sub:`19`
      - g\ :sub:`18`
      - g\ :sub:`17`
      - g\ :sub:`16`
      - g\ :sub:`15`
      - g\ :sub:`14`
      - g\ :sub:`13`
      - g\ :sub:`12`
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SGRBG20-1X20:

      - MEDIA_BUS_FMT_SGRBG20_1X20
      - 0x3023
      -
      - g\ :sub:`19`
      - g\ :sub:`18`
      - g\ :sub:`17`
      - g\ :sub:`16`
      - g\ :sub:`15`
      - g\ :sub:`14`
      - g\ :sub:`13`
      - g\ :sub:`12`
      - g\ :sub:`11`
      - g\ :sub:`10`
      - g\ :sub:`9`
      - g\ :sub:`8`
      - g\ :sub:`7`
      - g\ :sub:`6`
      - g\ :sub:`5`
      - g\ :sub:`4`
      - g\ :sub:`3`
      - g\ :sub:`2`
      - g\ :sub:`1`
      - g\ :sub:`0`
    * .. _MEDIA-BUS-FMT-SRGGB20-1X20:

      - MEDIA_BUS_FMT_SRGGB20_1X20
      - 0x3024
      -
      - r\ :sub:`19`
      - r\ :sub:`18`
      - r\ :sub:`17`
      - r\ :sub:`16`
      - r\ :sub:`15`
      - r\ :sub:`14`
      - r\ :sub:`13`
      - r\ :sub:`12`
      - r\ :sub:`11`
      - r\ :sub:`10`
      - r\ :sub:`9`
      - r\ :sub:`8`
      - r\ :sub:`7`
      - r\ :sub:`6`
      - r\ :sub:`5`
      - r\ :sub:`4`
      - r\ :sub:`3`
      - r\ :sub:`2`
      - r\ :sub:`1`
      - r\ :sub:`0`

.. raw:: latex

    \endgroup


Các định dạng YUV được đóng gói
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các định dạng dữ liệu đó truyền dữ liệu pixel dưới dạng (có thể được lấy mẫu xuống) Y, U
và thành phần V. Một số định dạng bao gồm các bit giả trong một số
các mẫu và được gọi chung là "YDYC" (Y-Dummy-Y-Chroma)
các định dạng. Người ta không thể dựa vào giá trị của các bit giả này vì chúng
không xác định.

Mã định dạng được tạo từ các thông tin sau.

- Mã thứ tự linh kiện Y, U, V được chuyển trên bus.
   Các giá trị có thể là YUYV, UYVY, YVYU và VYUY cho các định dạng không có
   bit giả và YDYUYDYV, YDYVYDYU, YUYDYVYD và YVYDYUYD cho YDYC
   các định dạng.

- Số bit trên mỗi thành phần pixel. Tất cả các thành phần đều
   được truyền trên cùng một số bit. Các giá trị phổ biến là 8, 10 và
   12.

- Số lượng mẫu xe buýt trên mỗi pixel. Các pixel rộng hơn
   chiều rộng bus phải được chuyển trong nhiều mẫu. Các giá trị chung là
   0,5 (được mã hóa là 0_5; trong trường hợp này hai pixel được truyền trên mỗi bus
   sample), 1, 1.5 (được mã hóa thành 1_5) và 2.

- Chiều rộng xe buýt. Khi độ rộng bus lớn hơn số bit
   trên mỗi thành phần pixel, một số thành phần được đóng gói trong một bus duy nhất
   mẫu. Các thành phần được đặt hàng theo quy định của mã đặt hàng,
   với các thành phần bên trái của mã được chuyển theo thứ tự cao
   bit. Giá trị chung là 8 và 16.

Ví dụ: định dạng trong đó pixel được mã hóa thành giá trị YUV 8 bit
được giảm tỷ lệ xuống 4:2:2 và được truyền dưới dạng 2 mẫu bus 8 bit cho mỗi pixel trong
thứ tự U, Y, V, Y sẽ được đặt tên là ZZ0000ZZ.

ZZ0000ZZ liệt kê các định dạng YUV được đóng gói hiện có và
mô tả cách tổ chức của từng dữ liệu pixel trong mỗi mẫu. Khi một
mẫu định dạng được chia thành nhiều mẫu, mỗi mẫu trong
mô hình được mô tả.

Vai trò của mỗi bit được truyền qua bus được xác định bởi một trong
các mã sau đây.

- y\ ZZ0000ZZ cho số bit thành phần độ sáng x

- u\ ZZ0000ZZ cho số bit thành phần sắc độ xanh x

- v\ ZZ0000ZZ cho số bit thành phần sắc độ đỏ x

- a\ZZ0000ZZ cho số bit thành phần alpha x

- đối với các bit không khả dụng (đối với các vị trí cao hơn độ rộng bus)

- d cho các bit giả

.. HACK: ideally, we would be using adjustbox here. However, this
.. will never work for this table, as, even with tiny font, it is
.. to big for a single page. So, we need to manually adjust the
.. size.

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{5.0cm}|p{0.7cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _v4l2-mbus-pixelcode-yuv8:

.. flat-table:: YUV Formats
    :header-rows:  2
    :stub-columns: 0
    :widths: 36 7 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

    * - Identifier
      - Code
      -
      - :cspan:`31` Data organization
    * -
      -
      - Bit
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
      - 10
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
    * .. _MEDIA-BUS-FMT-Y8-1X8:

      - MEDIA_BUS_FMT_Y8_1X8
      - 0x2001
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UV8-1X8:

      - MEDIA_BUS_FMT_UV8_1X8
      - 0x2015
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UYVY8-1_5X8:

      - MEDIA_BUS_FMT_UYVY8_1_5X8
      - 0x2002
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-VYUY8-1_5X8:

      - MEDIA_BUS_FMT_VYUY8_1_5X8
      - 0x2003
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUYV8-1_5X8:

      - MEDIA_BUS_FMT_YUYV8_1_5X8
      - 0x2004
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YVYU8-1_5X8:

      - MEDIA_BUS_FMT_YVYU8_1_5X8
      - 0x2005
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UYVY8-2X8:

      - MEDIA_BUS_FMT_UYVY8_2X8
      - 0x2006
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-VYUY8-2X8:

      - MEDIA_BUS_FMT_VYUY8_2X8
      - 0x2007
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUYV8-2X8:

      - MEDIA_BUS_FMT_YUYV8_2X8
      - 0x2008
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YVYU8-2X8:

      - MEDIA_BUS_FMT_YVYU8_2X8
      - 0x2009
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * .. _MEDIA-BUS-FMT-Y10-1X10:

      - MEDIA_BUS_FMT_Y10_1X10
      - 0x200a
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-Y10-2X8-PADHI_LE:

      - MEDIA_BUS_FMT_Y10_2X8_PADHI_LE
      - 0x202c
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - 0
      - 0
      - 0
      - 0
      - 0
      - 0
      - y\ :sub:`9`
      - y\ :sub:`8`
    * .. _MEDIA-BUS-FMT-UYVY10-2X10:

      - MEDIA_BUS_FMT_UYVY10_2X10
      - 0x2018
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-VYUY10-2X10:

      - MEDIA_BUS_FMT_VYUY10_2X10
      - 0x2019
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUYV10-2X10:

      - MEDIA_BUS_FMT_YUYV10_2X10
      - 0x200b
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YVYU10-2X10:

      - MEDIA_BUS_FMT_YVYU10_2X10
      - 0x200c
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * .. _MEDIA-BUS-FMT-Y12-1X12:

      - MEDIA_BUS_FMT_Y12_1X12
      - 0x2013
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UYVY12-2X12:

      - MEDIA_BUS_FMT_UYVY12_2X12
      - 0x201c
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-VYUY12-2X12:

      - MEDIA_BUS_FMT_VYUY12_2X12
      - 0x201d
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUYV12-2X12:

      - MEDIA_BUS_FMT_YUYV12_2X12
      - 0x201e
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YVYU12-2X12:

      - MEDIA_BUS_FMT_YVYU12_2X12
      - 0x201f
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * .. _MEDIA-BUS-FMT-Y14-1X14:

      - MEDIA_BUS_FMT_Y14_1X14
      - 0x202d
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`13`
      - y\ :sub:`12`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-Y16-1X16:

      - MEDIA_BUS_FMT_Y16_1X16
      - 0x202e
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`15`
      - y\ :sub:`14`
      - y\ :sub:`13`
      - y\ :sub:`12`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UYVY8-1X16:

      - MEDIA_BUS_FMT_UYVY8_1X16
      - 0x200f
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-VYUY8-1X16:

      - MEDIA_BUS_FMT_VYUY8_1X16
      - 0x2010
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUYV8-1X16:

      - MEDIA_BUS_FMT_YUYV8_1X16
      - 0x2011
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YVYU8-1X16:

      - MEDIA_BUS_FMT_YVYU8_1X16
      - 0x2012
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YDYUYDYV8-1X16:

      - MEDIA_BUS_FMT_YDYUYDYV8_1X16
      - 0x2014
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - d
      - d
      - d
      - d
      - d
      - d
      - d
      - d
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - d
      - d
      - d
      - d
      - d
      - d
      - d
      - d
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UYVY10-1X20:

      - MEDIA_BUS_FMT_UYVY10_1X20
      - 0x201a
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-VYUY10-1X20:

      - MEDIA_BUS_FMT_VYUY10_1X20
      - 0x201b
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUYV10-1X20:

      - MEDIA_BUS_FMT_YUYV10_1X20
      - 0x200d
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YVYU10-1X20:

      - MEDIA_BUS_FMT_YVYU10_1X20
      - 0x200e
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * .. _MEDIA-BUS-FMT-VUY8-1X24:

      - MEDIA_BUS_FMT_VUY8_1X24
      - 0x201a
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUV8-1X24:

      - MEDIA_BUS_FMT_YUV8_1X24
      - 0x2025
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UYYVYY8-0-5X24:

      - MEDIA_BUS_FMT_UYYVYY8_0_5X24
      - 0x2026
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UYVY12-1X24:

      - MEDIA_BUS_FMT_UYVY12_1X24
      - 0x2020
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-VYUY12-1X24:

      - MEDIA_BUS_FMT_VYUY12_1X24
      - 0x2021
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUYV12-1X24:

      - MEDIA_BUS_FMT_YUYV12_1X24
      - 0x2022
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YVYU12-1X24:

      - MEDIA_BUS_FMT_YVYU12_1X24
      - 0x2023
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUV10-1X30:

      - MEDIA_BUS_FMT_YUV10_1X30
      - 0x2016
      -
      -
      -
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UYYVYY10-0-5X30:

      - MEDIA_BUS_FMT_UYYVYY10_0_5X30
      - 0x2027
      -
      -
      -
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-AYUV8-1X32:

      - MEDIA_BUS_FMT_AYUV8_1X32
      - 0x2017
      -
      - a\ :sub:`7`
      - a\ :sub:`6`
      - a\ :sub:`5`
      - a\ :sub:`4`
      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`


.. raw:: latex

	\endgroup


Bảng sau liệt kê các định dạng YUV rộng 36 bit hiện có.

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{4.1cm}|p{0.7cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _v4l2-mbus-pixelcode-yuv8-36bit:

.. flat-table:: 36bit YUV Formats
    :header-rows:  2
    :stub-columns: 0
    :widths: 36 7 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

    * - Identifier
      - Code
      -
      - :cspan:`35` Data organization
    * -
      -
      - Bit
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
      - 10
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
    * .. _MEDIA-BUS-FMT-UYYVYY12-0-5X36:

      - MEDIA_BUS_FMT_UYYVYY12_0_5X36
      - 0x2028
      -
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * .. _MEDIA-BUS-FMT-YUV12-1X36:

      - MEDIA_BUS_FMT_YUV12_1X36
      - 0x2029
      -
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`


.. raw:: latex

	\endgroup


Bảng sau liệt kê các định dạng YUV rộng 48 bit hiện có.

.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{5.6cm}|p{0.7cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _v4l2-mbus-pixelcode-yuv8-48bit:

.. flat-table:: 48bit YUV Formats
    :header-rows:  3
    :stub-columns: 0
    :widths: 36 7 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

    * - Identifier
      - Code
      -
      - :cspan:`31` Data organization
    * -
      -
      - Bit
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
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
    * -
      -
      -
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
      - 10
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
    * .. _MEDIA-BUS-FMT-YUV16-1X48:

      - MEDIA_BUS_FMT_YUV16_1X48
      - 0x202a
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - y\ :sub:`15`
      - y\ :sub:`14`
      - y\ :sub:`13`
      - y\ :sub:`12`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`8`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      - u\ :sub:`15`
      - u\ :sub:`14`
      - u\ :sub:`13`
      - u\ :sub:`12`
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
      - v\ :sub:`15`
      - v\ :sub:`14`
      - v\ :sub:`13`
      - v\ :sub:`12`
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * .. _MEDIA-BUS-FMT-UYYVYY16-0-5X48:

      - MEDIA_BUS_FMT_UYYVYY16_0_5X48
      - 0x202b
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - u\ :sub:`15`
      - u\ :sub:`14`
      - u\ :sub:`13`
      - u\ :sub:`12`
      - u\ :sub:`11`
      - u\ :sub:`10`
      - u\ :sub:`9`
      - u\ :sub:`8`
      - u\ :sub:`7`
      - u\ :sub:`6`
      - u\ :sub:`5`
      - u\ :sub:`4`
      - u\ :sub:`3`
      - u\ :sub:`2`
      - u\ :sub:`1`
      - u\ :sub:`0`
    * -
      -
      -
      - y\ :sub:`15`
      - y\ :sub:`14`
      - y\ :sub:`13`
      - y\ :sub:`12`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - y\ :sub:`15`
      - y\ :sub:`14`
      - y\ :sub:`13`
      - y\ :sub:`12`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`8`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
    * -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - v\ :sub:`15`
      - v\ :sub:`14`
      - v\ :sub:`13`
      - v\ :sub:`12`
      - v\ :sub:`11`
      - v\ :sub:`10`
      - v\ :sub:`9`
      - v\ :sub:`8`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`
    * -
      -
      -
      - y\ :sub:`15`
      - y\ :sub:`14`
      - y\ :sub:`13`
      - y\ :sub:`12`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`9`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`
      - y\ :sub:`15`
      - y\ :sub:`14`
      - y\ :sub:`13`
      - y\ :sub:`12`
      - y\ :sub:`11`
      - y\ :sub:`10`
      - y\ :sub:`8`
      - y\ :sub:`8`
      - y\ :sub:`7`
      - y\ :sub:`6`
      - y\ :sub:`5`
      - y\ :sub:`4`
      - y\ :sub:`3`
      - y\ :sub:`2`
      - y\ :sub:`1`
      - y\ :sub:`0`


.. raw:: latex

	\endgroup

Định dạng HSV/HSL
^^^^^^^^^^^^^^^^^

Các định dạng đó truyền dữ liệu pixel dưới dạng giá trị RGB trong một
hệ tọa độ trụ sử dụng Hue-Saturation-Value hoặc
Các thành phần Hue-Saturation-Lightness. Mã định dạng được làm bằng
thông tin sau.

- Màu sắc, độ bão hòa, giá trị hoặc độ sáng và các thành phần alpha tùy chọn
   mã đơn hàng, như được mã hóa trong mẫu pixel. Hiện tại duy nhất
   giá trị được hỗ trợ là AHSV.

- Số bit trên mỗi thành phần, cho từng thành phần. Các giá trị có thể
   khác nhau đối với tất cả các thành phần. Giá trị duy nhất hiện được hỗ trợ
   là 8888.

- Số lượng mẫu xe buýt trên mỗi pixel. Các pixel rộng hơn
   chiều rộng bus phải được chuyển trong nhiều mẫu. Hiện tại duy nhất
   giá trị được hỗ trợ là 1.

- Chiều rộng xe buýt.

- Đối với các định dạng có tổng số bit trên mỗi pixel nhỏ hơn
   số lượng mẫu bus trên mỗi pixel nhân với chiều rộng bus, phần đệm
   giá trị cho biết liệu các byte có được đệm ở các bit có thứ tự cao nhất hay không
   (PADHI) hoặc bit thứ tự thấp (PADLO).

- Đối với các định dạng có số lượng mẫu bus trên mỗi pixel lớn hơn
   1, giá trị độ bền cho biết liệu pixel có được truyền MSB trước không
   (BE) hoặc LSB trước (LE).

Bảng sau liệt kê các định dạng HSV/HSL hiện có.


.. raw:: latex

    \begingroup
    \tiny
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{3.9cm}|p{0.73cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|p{0.22cm}|

.. _v4l2-mbus-pixelcode-hsv:

.. flat-table:: HSV/HSL formats
    :header-rows:  2
    :stub-columns: 0
    :widths: 28 7 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2

    * - Identifier
      - Code
      -
      - :cspan:`31` Data organization
    * -
      -
      - Bit
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
    * .. _MEDIA-BUS-FMT-AHSV8888-1X32:

      - MEDIA_BUS_FMT_AHSV8888_1X32
      - 0x6001
      -
      - a\ :sub:`7`
      - a\ :sub:`6`
      - a\ :sub:`5`
      - a\ :sub:`4`
      - a\ :sub:`3`
      - a\ :sub:`2`
      - a\ :sub:`1`
      - a\ :sub:`0`
      - h\ :sub:`7`
      - h\ :sub:`6`
      - h\ :sub:`5`
      - h\ :sub:`4`
      - h\ :sub:`3`
      - h\ :sub:`2`
      - h\ :sub:`1`
      - h\ :sub:`0`
      - s\ :sub:`7`
      - s\ :sub:`6`
      - s\ :sub:`5`
      - s\ :sub:`4`
      - s\ :sub:`3`
      - s\ :sub:`2`
      - s\ :sub:`1`
      - s\ :sub:`0`
      - v\ :sub:`7`
      - v\ :sub:`6`
      - v\ :sub:`5`
      - v\ :sub:`4`
      - v\ :sub:`3`
      - v\ :sub:`2`
      - v\ :sub:`1`
      - v\ :sub:`0`

.. raw:: latex

    \endgroup


Định dạng nén JPEG
^^^^^^^^^^^^^^^^^^^^^^^

Các định dạng dữ liệu đó bao gồm một chuỗi byte 8 bit có thứ tự
thu được từ quá trình nén JPEG. Ngoài ZZ0000ZZ
postfix mã định dạng được tạo từ các thông tin sau.

- Số lượng mẫu bus trên mỗi byte được mã hóa entropy.

- Chiều rộng xe buýt.

Ví dụ: đối với quy trình cơ sở JPEG và độ rộng bus 8 bit,
định dạng sẽ được đặt tên là ZZ0000ZZ.

Bảng sau liệt kê các định dạng nén JPEG hiện có.


.. _v4l2-mbus-pixelcode-jpeg:

.. tabularcolumns:: |p{6.0cm}|p{1.4cm}|p{9.9cm}|

.. flat-table:: JPEG Formats
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Code
      - Remarks
    * .. _MEDIA-BUS-FMT-JPEG-1X8:

      - MEDIA_BUS_FMT_JPEG_1X8
      - 0x4001
      - Besides of its usage for the parallel bus this format is
	recommended for transmission of JPEG data over MIPI CSI bus using
	the User Defined 8-bit Data types.



.. _v4l2-mbus-vendor-spec-fmts:

Định dạng cụ thể của nhà cung cấp và thiết bị
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Phần này liệt kê các định dạng dữ liệu phức tạp của nhà cung cấp hoặc thiết bị
cụ thể.

Bảng sau liệt kê cụ thể nhà cung cấp và thiết bị hiện có
các định dạng.


.. _v4l2-mbus-pixelcode-vendor-specific:

.. tabularcolumns:: |p{8.0cm}|p{1.4cm}|p{7.9cm}|

.. flat-table:: Vendor and device specific formats
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Code
      - Comments
    * .. _MEDIA-BUS-FMT-S5C-UYVY-JPEG-1X8:

      - MEDIA_BUS_FMT_S5C_UYVY_JPEG_1X8
      - 0x5001
      - Interleaved raw UYVY and JPEG image format with embedded meta-data
	used by Samsung S3C73MX camera sensors.

.. _v4l2-mbus-metadata-fmts:

Định dạng siêu dữ liệu
^^^^^^^^^^^^^^^^^^^^^^

Phần này liệt kê tất cả các định dạng siêu dữ liệu.

Bảng sau liệt kê các định dạng siêu dữ liệu hiện có.

.. tabularcolumns:: |p{8.0cm}|p{1.4cm}|p{7.9cm}|

.. flat-table:: Metadata formats
    :header-rows:  1
    :stub-columns: 0

    * - Identifier
      - Code
      - Comments
    * .. _MEDIA-BUS-FMT-METADATA-FIXED:

      - MEDIA_BUS_FMT_METADATA_FIXED
      - 0x7001
      - This format should be used when the same driver handles
	both sides of the link and the bus format is a fixed
	metadata format that is not configurable from userspace.
	Width and height will be set to 0 for this format.

Định dạng siêu dữ liệu nối tiếp chung
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các định dạng siêu dữ liệu nối tiếp chung được sử dụng trên các bus nối tiếp nơi dữ liệu thực tế
nội dung ít nhiều cụ thể theo thiết bị nhưng dữ liệu được truyền và nhận
bởi nhiều thiết bị không xử lý dữ liệu theo bất kỳ cách nào, chỉ cần viết
nó vào bộ nhớ hệ thống để xử lý trong phần mềm ở cuối quy trình.

"b" trong ô mảng biểu thị một byte dữ liệu, theo sau là số bit
và cuối cùng là số bit trong chỉ số dưới. "x" biểu thị bit đệm.

.. _media-bus-format-generic-meta:

.. cssclass: longtable

.. flat-table:: Generic Serial Metadata Formats
    :header-rows:  2
    :stub-columns: 0

    * - Identifier
      - Code
      -
      - :cspan:`23` Data organization within bus :term:`Data Unit`
    * -
      -
      - Bit
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
    * .. _MEDIA-BUS-FMT-META-8:

      - MEDIA_BUS_FMT_META_8
      - 0x8001
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b0\ :sub:`7`
      - b0\ :sub:`6`
      - b0\ :sub:`5`
      - b0\ :sub:`4`
      - b0\ :sub:`3`
      - b0\ :sub:`2`
      - b0\ :sub:`1`
      - b0\ :sub:`0`
    * .. _MEDIA-BUS-FMT-META-10:

      - MEDIA_BUS_FMT_META_10
      - 0x8002
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b0\ :sub:`7`
      - b0\ :sub:`6`
      - b0\ :sub:`5`
      - b0\ :sub:`4`
      - b0\ :sub:`3`
      - b0\ :sub:`2`
      - b0\ :sub:`1`
      - b0\ :sub:`0`
      - x
      - x
    * .. _MEDIA-BUS-FMT-META-12:

      - MEDIA_BUS_FMT_META_12
      - 0x8003
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b0\ :sub:`7`
      - b0\ :sub:`6`
      - b0\ :sub:`5`
      - b0\ :sub:`4`
      - b0\ :sub:`3`
      - b0\ :sub:`2`
      - b0\ :sub:`1`
      - b0\ :sub:`0`
      - x
      - x
      - x
      - x
    * .. _MEDIA-BUS-FMT-META-14:

      - MEDIA_BUS_FMT_META_14
      - 0x8004
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b0\ :sub:`7`
      - b0\ :sub:`6`
      - b0\ :sub:`5`
      - b0\ :sub:`4`
      - b0\ :sub:`3`
      - b0\ :sub:`2`
      - b0\ :sub:`1`
      - b0\ :sub:`0`
      - x
      - x
      - x
      - x
      - x
      - x
    * .. _MEDIA-BUS-FMT-META-16:

      - MEDIA_BUS_FMT_META_16
      - 0x8005
      -
      -
      -
      -
      -
      -
      -
      -
      -
      - b0\ :sub:`7`
      - b0\ :sub:`6`
      - b0\ :sub:`5`
      - b0\ :sub:`4`
      - b0\ :sub:`3`
      - b0\ :sub:`2`
      - b0\ :sub:`1`
      - b0\ :sub:`0`
      - x
      - x
      - x
      - x
      - x
      - x
      - x
      - x
    * .. _MEDIA-BUS-FMT-META-20:

      - MEDIA_BUS_FMT_META_20
      - 0x8006
      -
      -
      -
      -
      -
      - b0\ :sub:`7`
      - b0\ :sub:`6`
      - b0\ :sub:`5`
      - b0\ :sub:`4`
      - b0\ :sub:`3`
      - b0\ :sub:`2`
      - b0\ :sub:`1`
      - b0\ :sub:`0`
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
    * .. _MEDIA-BUS-FMT-META-24:

      - MEDIA_BUS_FMT_META_24
      - 0x8007
      -
      - b0\ :sub:`7`
      - b0\ :sub:`6`
      - b0\ :sub:`5`
      - b0\ :sub:`4`
      - b0\ :sub:`3`
      - b0\ :sub:`2`
      - b0\ :sub:`1`
      - b0\ :sub:`0`
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
      - x
      - x