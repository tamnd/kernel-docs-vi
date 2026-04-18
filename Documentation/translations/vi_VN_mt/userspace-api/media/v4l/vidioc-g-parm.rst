.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-parm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_PARM:

**********************************
ioctl VIDIOC_G_PARM, VIDIOC_S_PARM
**********************************

Tên
====

VIDIOC_G_PARM - VIDIOC_S_PARM - Nhận hoặc đặt tham số phát trực tuyến

Tóm tắt
========

.. c:macro:: VIDIOC_G_PARM

ZZ0000ZZ

.. c:macro:: VIDIOC_S_PARM

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ứng dụng có thể yêu cầu khoảng thời gian khung khác. Việc bắt giữ hoặc
thiết bị đầu ra sẽ được cấu hình lại để hỗ trợ khung được yêu cầu
khoảng cách nếu có thể. Tùy chọn người lái xe có thể chọn bỏ qua hoặc
lặp lại các khung để đạt được khoảng thời gian khung được yêu cầu.

Đối với bộ mã hóa trạng thái (xem ZZ0000ZZ), điều này thể hiện
khoảng thời gian khung thường được nhúng trong luồng video được mã hóa.

Việc thay đổi khoảng thời gian khung sẽ không bao giờ thay đổi định dạng. Thay đổi
mặt khác, định dạng có thể thay đổi khoảng thời gian khung.

Hơn nữa, những ioctls này có thể được sử dụng để xác định số lượng bộ đệm được sử dụng
bên trong bởi trình điều khiển ở chế độ đọc/ghi. Để biết ý nghĩa, hãy xem
phần thảo luận về chức năng ZZ0000ZZ.

Để nhận và thiết lập các thông số phát trực tuyến, các ứng dụng hãy gọi
ZZ0000ZZ và
ZZ0001ZZ ioctl tương ứng. Họ lấy một
con trỏ tới cấu trúc ZZ0002ZZ chứa một
liên kết giữ các thông số riêng biệt cho các thiết bị đầu vào và đầu ra.

.. tabularcolumns:: |p{3.7cm}|p{3.5cm}|p{10.1cm}|

.. c:type:: v4l2_streamparm

.. flat-table:: struct v4l2_streamparm
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``type``
      - The buffer (stream) type, same as struct
	:c:type:`v4l2_format` ``type``, set by the
	application. See :c:type:`v4l2_buf_type`.
    * - union {
      - ``parm``
    * - struct :c:type:`v4l2_captureparm`
      - ``capture``
      - Parameters for capture devices, used when ``type`` is
	``V4L2_BUF_TYPE_VIDEO_CAPTURE`` or
	``V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE``.
    * - struct :c:type:`v4l2_outputparm`
      - ``output``
      - Parameters for output devices, used when ``type`` is
	``V4L2_BUF_TYPE_VIDEO_OUTPUT`` or ``V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE``.
    * - __u8
      - ``raw_data``\ [200]
      - A place holder for future extensions.
    * - }


.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_captureparm

.. flat-table:: struct v4l2_captureparm
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``capability``
      - See :ref:`parm-caps`.
    * - __u32
      - ``capturemode``
      - Set by drivers and applications, see :ref:`parm-flags`.
    * - struct :c:type:`v4l2_fract`
      - ``timeperframe``
      - This is the desired period between successive frames captured by
	the driver, in seconds.
    * - :cspan:`2`

	This will configure the speed at which the video source (e.g. a sensor)
	generates video frames. If the speed is fixed, then the driver may
	choose to skip or repeat frames in order to achieve the requested
	frame rate.

	For stateful encoders (see :ref:`encoder`) this represents the
	frame interval that is typically embedded in the encoded video stream.

	Applications store here the desired frame period, drivers return
	the actual frame period.

	Changing the video standard (also implicitly by switching
	the video input) may reset this parameter to the nominal frame
	period. To reset manually applications can just set this field to
	zero.

	Drivers support this function only when they set the
	``V4L2_CAP_TIMEPERFRAME`` flag in the ``capability`` field.
    * - __u32
      - ``extendedmode``
      - Custom (driver specific) streaming parameters. When unused,
	applications and drivers must set this field to zero. Applications
	using this field should check the driver name and version, see
	:ref:`querycap`.
    * - __u32
      - ``readbuffers``
      - Applications set this field to the desired number of buffers used
	internally by the driver in :c:func:`read()` mode.
	Drivers return the actual number of buffers. When an application
	requests zero buffers, drivers should just return the current
	setting rather than the minimum or an error code. For details see
	:ref:`rw`.
    * - __u32
      - ``reserved``\ [4]
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.


.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_outputparm

.. flat-table:: struct v4l2_outputparm
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``capability``
      - See :ref:`parm-caps`.
    * - __u32
      - ``outputmode``
      - Set by drivers and applications, see :ref:`parm-flags`.
    * - struct :c:type:`v4l2_fract`
      - ``timeperframe``
      - This is the desired period between successive frames output by the
	driver, in seconds.
    * - :cspan:`2`

	The field is intended to repeat frames on the driver side in
	:c:func:`write()` mode (in streaming mode timestamps
	can be used to throttle the output), saving I/O bandwidth.

	For stateful encoders (see :ref:`encoder`) this represents the
	frame interval that is typically embedded in the encoded video stream
	and it provides a hint to the encoder of the speed at which raw
	frames are queued up to the encoder.

	Applications store here the desired frame period, drivers return
	the actual frame period.

	Changing the video standard (also implicitly by switching
	the video output) may reset this parameter to the nominal frame
	period. To reset manually applications can just set this field to
	zero.

	Drivers support this function only when they set the
	``V4L2_CAP_TIMEPERFRAME`` flag in the ``capability`` field.
    * - __u32
      - ``extendedmode``
      - Custom (driver specific) streaming parameters. When unused,
	applications and drivers must set this field to zero. Applications
	using this field should check the driver name and version, see
	:ref:`querycap`.
    * - __u32
      - ``writebuffers``
      - Applications set this field to the desired number of buffers used
	internally by the driver in :c:func:`write()` mode. Drivers
	return the actual number of buffers. When an application requests
	zero buffers, drivers should just return the current setting
	rather than the minimum or an error code. For details see
	:ref:`rw`.
    * - __u32
      - ``reserved``\ [4]
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.


.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _parm-caps:

.. flat-table:: Streaming Parameters Capabilities
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_CAP_TIMEPERFRAME``
      - 0x1000
      - The frame period can be modified by setting the ``timeperframe``
	field.


.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _parm-flags:

.. flat-table:: Capture Parameters Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_MODE_HIGHQUALITY``
      - 0x0001
      - High quality imaging mode. High quality mode is intended for still
	imaging applications. The idea is to get the best possible image
	quality that the hardware can deliver. It is not defined how the
	driver writer may achieve that; it will depend on the hardware and
	the ingenuity of the driver writer. High quality mode is a
	different mode from the regular motion video capture modes. In
	high quality mode:

	-  The driver may be able to capture higher resolutions than for
	   motion capture.

	-  The driver may support fewer pixel formats than motion capture
	   (eg; true color).

	-  The driver may capture and arithmetically combine multiple
	   successive fields or frames to remove color edge artifacts and
	   reduce the noise in the video data.

	-  The driver may capture images in slices like a scanner in order
	   to handle larger format images than would otherwise be
	   possible.

	-  An image capture operation may be significantly slower than
	   motion capture.

	-  Moving objects in the image might have excessive motion blur.

	-  Capture might only work through the :c:func:`read()` call.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.