.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-enumoutput.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_ENUMOUTPUT:

***********************
ioctl VIDIOC_ENUMOUTPUT
***********************

Tên
====

VIDIOC_ENUMOUTPUT - Liệt kê đầu ra video

Tóm tắt
========

.. c:macro:: VIDIOC_ENUMOUTPUT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn các thuộc tính của ứng dụng đầu ra video, hãy khởi tạo
Trường ZZ0002ZZ của cấu trúc ZZ0000ZZ và gọi
ZZ0001ZZ có con trỏ tới cấu trúc này.
Trình điều khiển lấp đầy phần còn lại của cấu trúc hoặc trả về mã lỗi ZZ0003ZZ
khi chỉ số nằm ngoài giới hạn. Để liệt kê tất cả các ứng dụng đầu ra
sẽ bắt đầu ở chỉ số 0, tăng dần một cho đến khi trình điều khiển quay trở lại
ZZ0004ZZ.

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_output

.. flat-table:: struct v4l2_output
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``index``
      - Identifies the output, set by the application.
    * - __u8
      - ``name``\ [32]
      - Name of the video output, a NUL-terminated ASCII string, for
	example: "Vout". This information is intended for the user,
	preferably the connector label on the device itself.
    * - __u32
      - ``type``
      - Type of the output, see :ref:`output-type`.
    * - __u32
      - ``audioset``
      - Drivers can enumerate up to 32 video and audio outputs. This field
	shows which audio outputs were selectable as the current output if
	this was the currently selected video output. It is a bit mask.
	The LSB corresponds to audio output 0, the MSB to output 31. Any
	number of bits can be set, or none.

	When the driver does not enumerate audio outputs no bits must be
	set. Applications shall not interpret this as lack of audio
	support. Drivers may automatically select audio outputs without
	enumerating them.

	For details on audio outputs and how to select the current output
	see :ref:`audio`.
    * - __u32
      - ``modulator``
      - Output devices can have zero or more RF modulators. When the
	``type`` is ``V4L2_OUTPUT_TYPE_MODULATOR`` this is an RF connector
	and this field identifies the modulator. It corresponds to struct
	:c:type:`v4l2_modulator` field ``index``. For
	details on modulators see :ref:`tuner`.
    * - :ref:`v4l2_std_id <v4l2-std-id>`
      - ``std``
      - Every video output supports one or more different video standards.
	This field is a set of all supported standards. For details on
	video standards and how to switch see :ref:`standard`.
    * - __u32
      - ``capabilities``
      - This field provides capabilities for the output. See
	:ref:`output-capabilities` for flags.
    * - __u32
      - ``reserved``\ [3]
      - Reserved for future extensions. Drivers must set the array to
	zero.


.. tabularcolumns:: |p{7.5cm}|p{0.6cm}|p{9.2cm}|

.. _output-type:

.. flat-table:: Output Type
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_OUTPUT_TYPE_MODULATOR``
      - 1
      - This output is an analog TV modulator.
    * - ``V4L2_OUTPUT_TYPE_ANALOG``
      - 2
      - Any non-modulator video output, for example Composite Video,
	S-Video, HDMI. The naming as ``_TYPE_ANALOG`` is historical,
	today we would have called it ``_TYPE_VIDEO``.
    * - ``V4L2_OUTPUT_TYPE_ANALOGVGAOVERLAY``
      - 3
      - The video output will be copied to a :ref:`video overlay <overlay>`.


.. tabularcolumns:: |p{6.4cm}|p{2.4cm}|p{8.5cm}|

.. _output-capabilities:

.. flat-table:: Output capabilities
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_OUT_CAP_DV_TIMINGS``
      - 0x00000002
      - This output supports setting video timings by using
	``VIDIOC_S_DV_TIMINGS``.
    * - ``V4L2_OUT_CAP_STD``
      - 0x00000004
      - This output supports setting the TV standard by using
	``VIDIOC_S_STD``.
    * - ``V4L2_OUT_CAP_NATIVE_SIZE``
      - 0x00000008
      - This output supports setting the native size using the
	``V4L2_SEL_TGT_NATIVE_SIZE`` selection target, see
	:ref:`v4l2-selections-common`.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ đã hết
    giới hạn.