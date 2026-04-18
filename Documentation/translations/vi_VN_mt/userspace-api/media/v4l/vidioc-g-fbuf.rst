.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-fbuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_FBUF:

**********************************
ioctl VIDIOC_G_FBUF, VIDIOC_S_FBUF
**********************************

Tên
====

VIDIOC_G_FBUF - VIDIOC_S_FBUF - Nhận hoặc đặt tham số lớp phủ bộ đệm khung

Tóm tắt
========

.. c:macro:: VIDIOC_G_FBUF

ZZ0000ZZ

.. c:macro:: VIDIOC_S_FBUF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ứng dụng có thể sử dụng ZZ0000ZZ và ZZ0001ZZ ioctl
để lấy và thiết lập các thông số bộ đệm khung cho một
ZZ0002ZZ hoặc ZZ0003ZZ
(OSD). Loại lớp phủ được ngụ ý bởi loại thiết bị (chụp hoặc
thiết bị đầu ra) và có thể được xác định bằng
ZZ0004ZZ ioctl. Một ZZ0005ZZ
thiết bị không được hỗ trợ cả hai loại lớp phủ.

V4L2 API phân biệt lớp phủ phá hủy và không phá hủy. A
lớp phủ phá hoại sao chép hình ảnh video đã chụp vào bộ nhớ video
của một card đồ họa. Lớp phủ không phá hủy sẽ trộn các hình ảnh video thành một
Tín hiệu hoặc đồ họa VGA thành tín hiệu video. ZZ0000ZZ là
luôn không phá hoại.

Hỗ trợ lớp phủ phá hủy đã bị xóa: với GPU và CPU hiện đại
điều này không còn cần thiết nữa và nó luôn là một tính năng rất nguy hiểm.

Để có được các thông số hiện tại, các ứng dụng hãy gọi ZZ0000ZZ
ioctl với một con trỏ tới cấu trúc ZZ0001ZZ
cấu trúc. Trình điều khiển điền vào tất cả các trường của cấu trúc hoặc trả về một
Mã lỗi EINVAL khi lớp phủ không được hỗ trợ.

Để đặt tham số cho ZZ0004ZZ, các ứng dụng phải
khởi tạo trường ZZ0003ZZ của cấu trúc
ZZ0000ZZ. Vì bộ đệm khung là
được thực hiện trên card TV, tất cả các thông số khác được xác định bởi
người lái xe. Khi một ứng dụng gọi ZZ0001ZZ bằng một con trỏ tới
cấu trúc này, trình điều khiển chuẩn bị cho lớp phủ và trả về
tham số bộ đệm khung như ZZ0002ZZ thực hiện hoặc nó sẽ trả về lỗi
mã.

Để cài đặt thông số cho ZZ0004ZZ
các ứng dụng phải khởi tạo trường ZZ0002ZZ, ZZ0003ZZ
cấu trúc con và gọi ZZ0000ZZ. Một lần nữa người lái xe chuẩn bị cho
lớp phủ và trả về các tham số bộ đệm khung dưới dạng ZZ0001ZZ
có, hoặc nó trả về một mã lỗi.

.. tabularcolumns:: |p{3.5cm}|p{3.5cm}|p{3.5cm}|p{6.6cm}|

.. c:type:: v4l2_framebuffer

.. cssclass:: longtable

.. flat-table:: struct v4l2_framebuffer
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 1 2

    * - __u32
      - ``capability``
      -
      - Overlay capability flags set by the driver, see
	:ref:`framebuffer-cap`.
    * - __u32
      - ``flags``
      -
      - Overlay control flags set by application and driver, see
	:ref:`framebuffer-flags`
    * - void *
      - ``base``
      -
      - Physical base address of the framebuffer, that is the address of
	the pixel in the top left corner of the framebuffer.
	For :ref:`VIDIOC_S_FBUF <VIDIOC_G_FBUF>` this field is no longer supported
	and the kernel will always set this to NULL.
	For *Video Output Overlays*
	the driver will return a valid base address, so applications can
	find the corresponding Linux framebuffer device (see
	:ref:`osd`). For *Video Capture Overlays* this field will always be
	NULL.
    * - struct
      - ``fmt``
      -
      - Layout of the frame buffer.
    * -
      - __u32
      - ``width``
      - Width of the frame buffer in pixels.
    * -
      - __u32
      - ``height``
      - Height of the frame buffer in pixels.
    * -
      - __u32
      - ``pixelformat``
      - The pixel format of the framebuffer.
    * -
      -
      -
      - For *non-destructive Video Overlays* this field only defines a
	format for the struct :c:type:`v4l2_window`
	``chromakey`` field.
    * -
      -
      -
      - For *Video Output Overlays* the driver must return a valid
	format.
    * -
      -
      -
      - Usually this is an RGB format (for example
	:ref:`V4L2_PIX_FMT_RGB565 <V4L2-PIX-FMT-RGB565>`) but YUV
	formats (only packed YUV formats when chroma keying is used, not
	including ``V4L2_PIX_FMT_YUYV`` and ``V4L2_PIX_FMT_UYVY``) and the
	``V4L2_PIX_FMT_PAL8`` format are also permitted. The behavior of
	the driver when an application requests a compressed format is
	undefined. See :ref:`pixfmt` for information on pixel formats.
    * -
      - enum :c:type:`v4l2_field`
      - ``field``
      - Drivers and applications shall ignore this field. If applicable,
	the field order is selected with the
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl, using the ``field``
	field of struct :c:type:`v4l2_window`.
    * -
      - __u32
      - ``bytesperline``
      - Distance in bytes between the leftmost pixels in two adjacent
	lines.
    * - :cspan:`3`

	This field is irrelevant to *non-destructive Video Overlays*.

	For *Video Output Overlays* the driver must return a valid value.

	Video hardware may access padding bytes, therefore they must
	reside in accessible memory. Consider for example the case where
	padding bytes after the last line of an image cross a system page
	boundary. Capture devices may write padding bytes, the value is
	undefined. Output devices ignore the contents of padding bytes.

	When the image format is planar the ``bytesperline`` value applies
	to the first plane and is divided by the same factor as the
	``width`` field for the other planes. For example the Cb and Cr
	planes of a YUV 4:2:0 image have half as many padding bytes
	following each line as the Y plane. To avoid ambiguities drivers
	must return a ``bytesperline`` value rounded up to a multiple of
	the scale factor.
    * -
      - __u32
      - ``sizeimage``
      - This field is irrelevant to *non-destructive Video Overlays*.
	For *Video Output Overlays* the driver must return a valid
	format.

	Together with ``base`` it defines the framebuffer memory
	accessible by the driver.
    * -
      - enum :c:type:`v4l2_colorspace`
      - ``colorspace``
      - This information supplements the ``pixelformat`` and must be set
	by the driver, see :ref:`colorspaces`.
    * -
      - __u32
      - ``priv``
      - Reserved. Drivers and applications must set this field to zero.

.. tabularcolumns:: |p{7.4cm}|p{1.6cm}|p{8.3cm}|

.. _framebuffer-cap:

.. flat-table:: Frame Buffer Capability Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_FBUF_CAP_EXTERNOVERLAY``
      - 0x0001
      - The device is capable of non-destructive overlays. When the driver
	clears this flag, only destructive overlays are supported. There
	are no drivers yet which support both destructive and
	non-destructive overlays. Video Output Overlays are in practice
	always non-destructive.
    * - ``V4L2_FBUF_CAP_CHROMAKEY``
      - 0x0002
      - The device supports clipping by chroma-keying the images. That is,
	image pixels replace pixels in the VGA or video signal only where
	the latter assume a certain color. Chroma-keying makes no sense
	for destructive overlays.
    * - ``V4L2_FBUF_CAP_LIST_CLIPPING``
      - 0x0004
      - The device supports clipping using a list of clip rectangles.
        Note that this is no longer supported.
    * - ``V4L2_FBUF_CAP_BITMAP_CLIPPING``
      - 0x0008
      - The device supports clipping using a bit mask.
        Note that this is no longer supported.
    * - ``V4L2_FBUF_CAP_LOCAL_ALPHA``
      - 0x0010
      - The device supports clipping/blending using the alpha channel of
	the framebuffer or VGA signal. Alpha blending makes no sense for
	destructive overlays.
    * - ``V4L2_FBUF_CAP_GLOBAL_ALPHA``
      - 0x0020
      - The device supports alpha blending using a global alpha value.
	Alpha blending makes no sense for destructive overlays.
    * - ``V4L2_FBUF_CAP_LOCAL_INV_ALPHA``
      - 0x0040
      - The device supports clipping/blending using the inverted alpha
	channel of the framebuffer or VGA signal. Alpha blending makes no
	sense for destructive overlays.
    * - ``V4L2_FBUF_CAP_SRC_CHROMAKEY``
      - 0x0080
      - The device supports Source Chroma-keying. Video pixels with the
	chroma-key colors are replaced by framebuffer pixels, which is
	exactly opposite of ``V4L2_FBUF_CAP_CHROMAKEY``

.. tabularcolumns:: |p{7.4cm}|p{1.6cm}|p{8.3cm}|

.. _framebuffer-flags:

.. cssclass:: longtable

.. flat-table:: Frame Buffer Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_FBUF_FLAG_PRIMARY``
      - 0x0001
      - The framebuffer is the primary graphics surface. In other words,
	the overlay is destructive. This flag is typically set by any
	driver that doesn't have the ``V4L2_FBUF_CAP_EXTERNOVERLAY``
	capability and it is cleared otherwise.
    * - ``V4L2_FBUF_FLAG_OVERLAY``
      - 0x0002
      - If this flag is set for a video capture device, then the driver
	will set the initial overlay size to cover the full framebuffer
	size, otherwise the existing overlay size (as set by
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>`) will be used. Only one
	video capture driver (bttv) supports this flag. The use of this
	flag for capture devices is deprecated. There is no way to detect
	which drivers support this flag, so the only reliable method of
	setting the overlay size is through
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>`. If this flag is set for a
	video output device, then the video output overlay window is
	relative to the top-left corner of the framebuffer and restricted
	to the size of the framebuffer. If it is cleared, then the video
	output overlay window is relative to the video output display.
    * - ``V4L2_FBUF_FLAG_CHROMAKEY``
      - 0x0004
      - Use chroma-keying. The chroma-key color is determined by the
	``chromakey`` field of struct :c:type:`v4l2_window`
	and negotiated with the :ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>`
	ioctl, see :ref:`overlay` and :ref:`osd`.
    * - :cspan:`2` There are no flags to enable clipping using a list of
	clip rectangles or a bitmap. These methods are negotiated with the
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl, see :ref:`overlay`
	and :ref:`osd`.
    * - ``V4L2_FBUF_FLAG_LOCAL_ALPHA``
      - 0x0008
      - Use the alpha channel of the framebuffer to clip or blend
	framebuffer pixels with video images. The blend function is:
	output = framebuffer pixel * alpha + video pixel * (1 - alpha).
	The actual alpha depth depends on the framebuffer pixel format.
    * - ``V4L2_FBUF_FLAG_GLOBAL_ALPHA``
      - 0x0010
      - Use a global alpha value to blend the framebuffer with video
	images. The blend function is: output = (framebuffer pixel * alpha
	+ video pixel * (255 - alpha)) / 255. The alpha value is
	determined by the ``global_alpha`` field of struct
	:c:type:`v4l2_window` and negotiated with the
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl, see :ref:`overlay`
	and :ref:`osd`.
    * - ``V4L2_FBUF_FLAG_LOCAL_INV_ALPHA``
      - 0x0020
      - Like ``V4L2_FBUF_FLAG_LOCAL_ALPHA``, use the alpha channel of the
	framebuffer to clip or blend framebuffer pixels with video images,
	but with an inverted alpha value. The blend function is: output =
	framebuffer pixel * (1 - alpha) + video pixel * alpha. The actual
	alpha depth depends on the framebuffer pixel format.
    * - ``V4L2_FBUF_FLAG_SRC_CHROMAKEY``
      - 0x0040
      - Use source chroma-keying. The source chroma-key color is
	determined by the ``chromakey`` field of struct
	:c:type:`v4l2_window` and negotiated with the
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl, see :ref:`overlay`
	and :ref:`osd`. Both chroma-keying are mutual exclusive to each
	other, so same ``chromakey`` field of struct
	:c:type:`v4l2_window` is being used.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EPERM
    ZZ0000ZZ chỉ có thể được gọi bởi người dùng đặc quyền
    đàm phán các tham số cho lớp phủ phá hoại.

EINVAL
    Các thông số ZZ0000ZZ không phù hợp.