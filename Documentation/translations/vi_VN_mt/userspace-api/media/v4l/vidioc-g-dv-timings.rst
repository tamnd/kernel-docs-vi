.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-dv-timings.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_DV_TIMINGS:

**********************************************
ioctl VIDIOC_G_DV_TIMINGS, VIDIOC_S_DV_TIMINGS
**********************************************

Tên
====

VIDIOC_G_DV_TIMINGS - VIDIOC_S_DV_TIMINGS - VIDIOC_SUBDEV_G_DV_TIMINGS - VIDIOC_SUBDEV_S_DV_TIMINGS - Nhận hoặc đặt thời gian DV cho đầu vào hoặc đầu ra

Tóm tắt
========

.. c:macro:: VIDIOC_G_DV_TIMINGS

ZZ0000ZZ

.. c:macro:: VIDIOC_S_DV_TIMINGS

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_G_DV_TIMINGS

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_S_DV_TIMINGS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để đặt thời gian DV cho đầu vào hoặc đầu ra, các ứng dụng sử dụng
ZZ0000ZZ ioctl và để có được thời gian hiện tại,
các ứng dụng sử dụng ZZ0001ZZ ioctl. Thời gian chi tiết
thông tin được điền bằng cách sử dụng cấu trúc struct
ZZ0002ZZ. Những ioctls này mất một
con trỏ tới cấu trúc ZZ0003ZZ
cấu trúc làm đối số. Nếu ioctl không được hỗ trợ hoặc thời gian
giá trị không chính xác, trình điều khiển trả về mã lỗi ZZ0004ZZ.

Gọi ZZ0000ZZ trên nút thiết bị subdev đã được
đăng ký ở chế độ chỉ đọc không được phép. Một lỗi được trả về và lỗi đó
biến được đặt thành ZZ0001ZZ.

Tiêu đề ZZ0003ZZ có thể được sử dụng để lấy thời gian của
các định dạng trong tiêu chuẩn ZZ0000ZZ và ZZ0001ZZ. Nếu
đầu vào hoặc đầu ra hiện tại không hỗ trợ định giờ DV (ví dụ: nếu
ZZ0002ZZ không đặt
ZZ0004ZZ), sau đó mã lỗi ZZ0005ZZ được trả về.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Ioctl này không được hỗ trợ hoặc ZZ0000ZZ
    tham số không phù hợp.

ENODATA
    Định giờ video kỹ thuật số không được hỗ trợ cho đầu vào hoặc đầu ra này.

EBUSY
    Máy đang bận nên không thể thay đổi thời gian được.

EPERM
    ZZ0000ZZ đã được gọi trên thiết bị con chỉ đọc.

.. c:type:: v4l2_bt_timings

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. cssclass:: longtable

.. flat-table:: struct v4l2_bt_timings
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``width``
      - Width of the active video in pixels.
    * - __u32
      - ``height``
      - Height of the active video frame in lines. So for interlaced
	formats the height of the active video in each field is
	``height``/2.
    * - __u32
      - ``interlaced``
      - Progressive (``V4L2_DV_PROGRESSIVE``) or interlaced (``V4L2_DV_INTERLACED``).
    * - __u32
      - ``polarities``
      - This is a bit mask that defines polarities of sync signals. bit 0
	(``V4L2_DV_VSYNC_POS_POL``) is for vertical sync polarity and bit
	1 (``V4L2_DV_HSYNC_POS_POL``) is for horizontal sync polarity. If
	the bit is set (1) it is positive polarity and if is cleared (0),
	it is negative polarity.
    * - __u64
      - ``pixelclock``
      - Pixel clock in Hz. Ex. 74.25MHz->74250000
    * - __u32
      - ``hfrontporch``
      - Horizontal front porch in pixels
    * - __u32
      - ``hsync``
      - Horizontal sync length in pixels
    * - __u32
      - ``hbackporch``
      - Horizontal back porch in pixels
    * - __u32
      - ``vfrontporch``
      - Vertical front porch in lines. For interlaced formats this refers
	to the odd field (aka field 1).
    * - __u32
      - ``vsync``
      - Vertical sync length in lines. For interlaced formats this refers
	to the odd field (aka field 1).
    * - __u32
      - ``vbackporch``
      - Vertical back porch in lines. For interlaced formats this refers
	to the odd field (aka field 1).
    * - __u32
      - ``il_vfrontporch``
      - Vertical front porch in lines for the even field (aka field 2) of
	interlaced field formats. Must be 0 for progressive formats.
    * - __u32
      - ``il_vsync``
      - Vertical sync length in lines for the even field (aka field 2) of
	interlaced field formats. Must be 0 for progressive formats.
    * - __u32
      - ``il_vbackporch``
      - Vertical back porch in lines for the even field (aka field 2) of
	interlaced field formats. Must be 0 for progressive formats.
    * - __u32
      - ``standards``
      - The video standard(s) this format belongs to. This will be filled
	in by the driver. Applications must set this to 0. See
	:ref:`dv-bt-standards` for a list of standards.
    * - __u32
      - ``flags``
      - Several flags giving more information about the format. See
	:ref:`dv-bt-flags` for a description of the flags.
    * - struct :c:type:`v4l2_fract`
      - ``picture_aspect``
      - The picture aspect if the pixels are not square. Only valid if the
        ``V4L2_DV_FL_HAS_PICTURE_ASPECT`` flag is set.
    * - __u8
      - ``cea861_vic``
      - The Video Identification Code according to the CEA-861 standard.
        Only valid if the ``V4L2_DV_FL_HAS_CEA861_VIC`` flag is set.
    * - __u8
      - ``hdmi_vic``
      - The Video Identification Code according to the HDMI standard.
        Only valid if the ``V4L2_DV_FL_HAS_HDMI_VIC`` flag is set.
    * - __u8
      - ``reserved[46]``
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.

.. tabularcolumns:: |p{3.5cm}|p{3.5cm}|p{7.0cm}|p{3.1cm}|

.. c:type:: v4l2_dv_timings

.. flat-table:: struct v4l2_dv_timings
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``type``
      - Type of DV timings as listed in :ref:`dv-timing-types`.
    * - union {
      - (anonymous)
    * - struct :c:type:`v4l2_bt_timings`
      - ``bt``
      - Timings defined by BT.656/1120 specifications
    * - __u32
      - ``reserved``\ [32]
      -
    * - }
      -

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. _dv-timing-types:

.. flat-table:: DV Timing types
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - Timing type
      - value
      - Description
    * -
      -
      -
    * - ``V4L2_DV_BT_656_1120``
      - 0
      - BT.656/1120 timings

.. tabularcolumns:: |p{6.5cm}|p{11.0cm}|

.. cssclass:: longtable

.. _dv-bt-standards:

.. flat-table:: DV BT Timing standards
    :header-rows:  0
    :stub-columns: 0

    * - Timing standard
      - Description
    * - ``V4L2_DV_BT_STD_CEA861``
      - The timings follow the CEA-861 Digital TV Profile standard
    * - ``V4L2_DV_BT_STD_DMT``
      - The timings follow the VESA Discrete Monitor Timings standard
    * - ``V4L2_DV_BT_STD_CVT``
      - The timings follow the VESA Coordinated Video Timings standard
    * - ``V4L2_DV_BT_STD_GTF``
      - The timings follow the VESA Generalized Timings Formula standard
    * - ``V4L2_DV_BT_STD_SDI``
      - The timings follow the SDI Timings standard.
	There are no horizontal syncs/porches at all in this format.
	Total blanking timings must be set in hsync or vsync fields only.

.. tabularcolumns:: |p{7.7cm}|p{9.8cm}|

.. cssclass:: longtable

.. _dv-bt-flags:

.. flat-table:: DV BT Timing flags
    :header-rows:  0
    :stub-columns: 0

    * - Flag
      - Description
    * - ``V4L2_DV_FL_REDUCED_BLANKING``
      - CVT/GTF specific: the timings use reduced blanking (CVT) or the
	'Secondary GTF' curve (GTF). In both cases the horizontal and/or
	vertical blanking intervals are reduced, allowing a higher
	resolution over the same bandwidth. This is a read-only flag,
	applications must not set this.
    * - ``V4L2_DV_FL_CAN_REDUCE_FPS``
      - CEA-861 specific: set for CEA-861 formats with a framerate that is
	a multiple of six. These formats can be optionally played at 1 /
	1.001 speed to be compatible with 60 Hz based standards such as
	NTSC and PAL-M that use a framerate of 29.97 frames per second. If
	the transmitter can't generate such frequencies, then the flag
	will also be cleared. This is a read-only flag, applications must
	not set this.
    * - ``V4L2_DV_FL_REDUCED_FPS``
      - CEA-861 specific: only valid for video transmitters or video
        receivers that have the ``V4L2_DV_FL_CAN_DETECT_REDUCED_FPS``
	set. This flag is cleared otherwise. It is also only valid for
	formats with the ``V4L2_DV_FL_CAN_REDUCE_FPS`` flag set, for other
	formats the flag will be cleared by the driver.

	If the application sets this flag for a transmitter, then the
	pixelclock used to set up the transmitter is divided by 1.001 to
	make it compatible with NTSC framerates. If the transmitter can't
	generate such frequencies, then the flag will be cleared.

	If a video receiver detects that the format uses a reduced framerate,
	then it will set this flag to signal this to the application.
    * - ``V4L2_DV_FL_HALF_LINE``
      - Specific to interlaced formats: if set, then the vertical
	frontporch of field 1 (aka the odd field) is really one half-line
	longer and the vertical backporch of field 2 (aka the even field)
	is really one half-line shorter, so each field has exactly the
	same number of half-lines. Whether half-lines can be detected or
	used depends on the hardware.
    * - ``V4L2_DV_FL_IS_CE_VIDEO``
      - If set, then this is a Consumer Electronics (CE) video format.
	Such formats differ from other formats (commonly called IT
	formats) in that if R'G'B' encoding is used then by default the
	R'G'B' values use limited range (i.e. 16-235) as opposed to full
	range (i.e. 0-255). All formats defined in CEA-861 except for the
	640x480p59.94 format are CE formats.
    * - ``V4L2_DV_FL_FIRST_FIELD_EXTRA_LINE``
      - Some formats like SMPTE-125M have an interlaced signal with a odd
	total height. For these formats, if this flag is set, the first
	field has the extra line. Else, it is the second field.
    * - ``V4L2_DV_FL_HAS_PICTURE_ASPECT``
      - If set, then the picture_aspect field is valid. Otherwise assume that
        the pixels are square, so the picture aspect ratio is the same as the
	width to height ratio.
    * - ``V4L2_DV_FL_HAS_CEA861_VIC``
      - If set, then the cea861_vic field is valid and contains the Video
        Identification Code as per the CEA-861 standard.
    * - ``V4L2_DV_FL_HAS_HDMI_VIC``
      - If set, then the hdmi_vic field is valid and contains the Video
        Identification Code as per the HDMI standard (HDMI Vendor Specific
	InfoFrame).
    * - ``V4L2_DV_FL_CAN_DETECT_REDUCED_FPS``
      - CEA-861 specific: only valid for video receivers, the flag is
        cleared by transmitters.
        If set, then the hardware can detect the difference between
	regular framerates and framerates reduced by 1000/1001. E.g.:
	60 vs 59.94 Hz, 30 vs 29.97 Hz or 24 vs 23.976 Hz.