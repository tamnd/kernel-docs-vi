.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-enum-fmt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_ENUM_FMT:

**********************
ioctl VIDIOC_ENUM_FMT
**********************

Tên
====

VIDIOC_ENUM_FMT - Liệt kê các định dạng hình ảnh

Tóm tắt
========

.. c:macro:: VIDIOC_ENUM_FMT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để liệt kê các ứng dụng định dạng hình ảnh, hãy khởi tạo ZZ0002ZZ, ZZ0003ZZ
và các trường ZZ0004ZZ của cấu trúc ZZ0000ZZ và gọi
ZZ0001ZZ ioctl với một con trỏ tới cấu trúc này. Trình điều khiển
điền vào phần còn lại của cấu trúc hoặc trả về mã lỗi ZZ0005ZZ. Tất cả
các định dạng có thể đếm được bằng cách bắt đầu từ chỉ số 0 và tăng dần theo
một cho đến khi ZZ0006ZZ được trả lại. Nếu có, tài xế sẽ quay lại
các định dạng theo thứ tự ưu tiên, trong đó các định dạng ưa thích được trả về trước
(nghĩa là với giá trị ZZ0007ZZ thấp hơn) các định dạng ít được ưa thích hơn.

Tùy thuộc vào ZZ0001ZZ ZZ0000ZZ,
trường ZZ0002ZZ được xử lý khác nhau:

1) ZZ0000ZZ chưa được đặt (còn được gọi là trình điều khiển 'tập trung vào nút video')

Các ứng dụng sẽ khởi tạo trường ZZ0000ZZ về 0 và trình điều khiển
   sẽ bỏ qua giá trị của trường.

Trình điều khiển sẽ liệt kê tất cả các định dạng hình ảnh.

   .. note::

      After switching the input or output the list of enumerated image
      formats may be different.

2) ZZ0000ZZ được thiết lập (còn được gọi là trình điều khiển 'MC lấy trung tâm')

Nếu trường ZZ0000ZZ bằng 0 thì tất cả các định dạng hình ảnh
   sẽ được liệt kê.

Nếu trường ZZ0001ZZ được khởi tạo thành giá trị hợp lệ (khác 0)
   ZZ0000ZZ, sau đó là trình điều khiển
   sẽ hạn chế việc liệt kê chỉ các định dạng hình ảnh có thể tạo ra
   (đối với thiết bị đầu ra video) hoặc được sản xuất từ (đối với thiết bị quay video
   thiết bị) mã bus phương tiện đó. Nếu ZZ0002ZZ không được hỗ trợ bởi
   trình điều khiển thì ZZ0003ZZ sẽ được trả lại.

Bất kể giá trị của trường ZZ0000ZZ, hình ảnh được liệt kê
   các định dạng sẽ không phụ thuộc vào cấu hình hoạt động của thiết bị video
   hoặc đường dẫn thiết bị.

.. c:type:: v4l2_fmtdesc

.. cssclass:: longtable

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_fmtdesc
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``index``
      - Number of the format in the enumeration, set by the application.
        This is in no way related to the ``pixelformat`` field.
        When the index is ORed with ``V4L2_FMTDESC_FLAG_ENUM_ALL`` the
        driver clears the flag and enumerates all the possible formats,
        ignoring any limitations from the current configuration. Drivers
        which do not support this flag always return an ``EINVAL``
        error code without clearing this flag.
        Formats enumerated when using ``V4L2_FMTDESC_FLAG_ENUM_ALL`` flag
        shouldn't be used when calling :c:func:`VIDIOC_ENUM_FRAMESIZES`
        or :c:func:`VIDIOC_ENUM_FRAMEINTERVALS`.
        ``V4L2_FMTDESC_FLAG_ENUM_ALL`` should only be used by drivers that
        can return different format list depending on this flag.
    * - __u32
      - ``type``
      - Type of the data stream, set by the application. Only these types
	are valid here: ``V4L2_BUF_TYPE_VIDEO_CAPTURE``,
	``V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE``,
	``V4L2_BUF_TYPE_VIDEO_OUTPUT``,
	``V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE``,
	``V4L2_BUF_TYPE_VIDEO_OVERLAY``,
	``V4L2_BUF_TYPE_SDR_CAPTURE``,
	``V4L2_BUF_TYPE_SDR_OUTPUT``,
	``V4L2_BUF_TYPE_META_CAPTURE`` and
	``V4L2_BUF_TYPE_META_OUTPUT``.
	See :c:type:`v4l2_buf_type`.
    * - __u32
      - ``flags``
      - See :ref:`fmtdesc-flags`
    * - __u8
      - ``description``\ [32]
      - Description of the format, a NUL-terminated ASCII string. This
	information is intended for the user, for example: "YUV 4:2:2".
    * - __u32
      - ``pixelformat``
      - The image format identifier. This is a four character code as
	computed by the v4l2_fourcc() macro:
    * - :cspan:`2`

	.. _v4l2-fourcc:

	``#define v4l2_fourcc(a,b,c,d)``

	``(((__u32)(a)<<0)|((__u32)(b)<<8)|((__u32)(c)<<16)|((__u32)(d)<<24))``

	Several image formats are already defined by this specification in
	:ref:`pixfmt`.

	.. attention::

	   These codes are not the same as those used
	   in the Windows world.
    * - __u32
      - ``mbus_code``
      - Media bus code restricting the enumerated formats, set by the
        application. Only applicable to drivers that advertise the
        ``V4L2_CAP_IO_MC`` :ref:`capability <device-capabilities>`, shall be 0
        otherwise.
    * - __u32
      - ``reserved``\ [3]
      - Reserved for future extensions. Drivers must set the array to
	zero.


.. tabularcolumns:: |p{8.4cm}|p{1.8cm}|p{7.1cm}|

.. cssclass:: longtable

.. _fmtdesc-flags:

.. flat-table:: Image Format Description Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_FMT_FLAG_COMPRESSED``
      - 0x0001
      - This is a compressed format.
    * - ``V4L2_FMT_FLAG_EMULATED``
      - 0x0002
      - This format is not native to the device but emulated through
	software (usually libv4l2), where possible try to use a native
	format instead for better performance.
    * - ``V4L2_FMT_FLAG_CONTINUOUS_BYTESTREAM``
      - 0x0004
      - The hardware decoder for this compressed bytestream format (aka coded
	format) is capable of parsing a continuous bytestream. Applications do
	not need to parse the bytestream themselves to find the boundaries
	between frames/fields.

	This flag can only be used in combination with the
	``V4L2_FMT_FLAG_COMPRESSED`` flag, since this applies to compressed
	formats only. This flag is valid for stateful decoders only.
    * - ``V4L2_FMT_FLAG_DYN_RESOLUTION``
      - 0x0008
      - Dynamic resolution switching is supported by the device for this
	compressed bytestream format (aka coded format). It will notify the user
	via the event ``V4L2_EVENT_SOURCE_CHANGE`` when changes in the video
	parameters are detected.

	This flag can only be used in combination with the
	``V4L2_FMT_FLAG_COMPRESSED`` flag, since this applies to
	compressed formats only. This flag is valid for stateful codecs only.
    * - ``V4L2_FMT_FLAG_ENC_CAP_FRAME_INTERVAL``
      - 0x0010
      - The hardware encoder supports setting the ``CAPTURE`` coded frame
	interval separately from the ``OUTPUT`` raw frame interval.
	Setting the ``OUTPUT`` raw frame interval with :ref:`VIDIOC_S_PARM <VIDIOC_G_PARM>`
	also sets the ``CAPTURE`` coded frame interval to the same value.
	If this flag is set, then the ``CAPTURE`` coded frame interval can be
	set to a different value afterwards. This is typically used for
	offline encoding where the ``OUTPUT`` raw frame interval is used as
	a hint for reserving hardware encoder resources and the ``CAPTURE`` coded
	frame interval is the actual frame rate embedded in the encoded video
	stream.

	This flag can only be used in combination with the
	``V4L2_FMT_FLAG_COMPRESSED`` flag, since this applies to
        compressed formats only. This flag is valid for stateful encoders only.
    * - ``V4L2_FMT_FLAG_CSC_COLORSPACE``
      - 0x0020
      - The driver allows the application to try to change the default
	colorspace. This flag is relevant only for capture devices.
	The application can ask to configure the colorspace of the capture device
	when calling the :ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl with
	:ref:`V4L2_PIX_FMT_FLAG_SET_CSC <v4l2-pix-fmt-flag-set-csc>` set.
    * - ``V4L2_FMT_FLAG_CSC_XFER_FUNC``
      - 0x0040
      - The driver allows the application to try to change the default
	transfer function. This flag is relevant only for capture devices.
	The application can ask to configure the transfer function of the capture
	device when calling the :ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl with
	:ref:`V4L2_PIX_FMT_FLAG_SET_CSC <v4l2-pix-fmt-flag-set-csc>` set.
    * - ``V4L2_FMT_FLAG_CSC_YCBCR_ENC``
      - 0x0080
      - The driver allows the application to try to change the default
	Y'CbCr encoding. This flag is relevant only for capture devices.
	The application can ask to configure the Y'CbCr encoding of the capture device
	when calling the :ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl with
	:ref:`V4L2_PIX_FMT_FLAG_SET_CSC <v4l2-pix-fmt-flag-set-csc>` set.
    * - ``V4L2_FMT_FLAG_CSC_HSV_ENC``
      - 0x0080
      - The driver allows the application to try to change the default
	HSV encoding. This flag is relevant only for capture devices.
	The application can ask to configure the HSV encoding of the capture device
	when calling the :ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl with
	:ref:`V4L2_PIX_FMT_FLAG_SET_CSC <v4l2-pix-fmt-flag-set-csc>` set.
    * - ``V4L2_FMT_FLAG_CSC_QUANTIZATION``
      - 0x0100
      - The driver allows the application to try to change the default
	quantization. This flag is relevant only for capture devices.
	The application can ask to configure the quantization of the capture
	device when calling the :ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl with
	:ref:`V4L2_PIX_FMT_FLAG_SET_CSC <v4l2-pix-fmt-flag-set-csc>` set.
    * - ``V4L2_FMT_FLAG_META_LINE_BASED``
      - 0x0200
      - The metadata format is line-based. In this case the ``width``,
	``height`` and ``bytesperline`` fields of :c:type:`v4l2_meta_format` are
	valid. The buffer consists of ``height`` lines, each having ``width``
	Data Units of data and the offset (in bytes) between the beginning of
	each two consecutive lines is ``bytesperline``.
    * - ``V4L2_FMTDESC_FLAG_ENUM_ALL``
      - 0x80000000
      - When the applications ORs ``index`` with ``V4L2_FMTDESC_FLAG_ENUM_ALL`` flag
        the driver enumerates all the possible pixel formats without taking care
        of any already set configuration. Drivers which do not support this flag,
        always return ``EINVAL`` without clearing this flag.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ thì không
    được hỗ trợ hoặc ZZ0002ZZ nằm ngoài giới hạn.

Nếu ZZ0000ZZ được đặt và ZZ0001ZZ được chỉ định
    không được hỗ trợ thì cũng trả về mã lỗi này.