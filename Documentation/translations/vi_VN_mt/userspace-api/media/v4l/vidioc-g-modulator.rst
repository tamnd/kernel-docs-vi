.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-modulator.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_MODULATOR:

*******************************************
ioctl VIDIOC_G_MODULATOR, VIDIOC_S_MODULATOR
********************************************

Tên
====

VIDIOC_G_MODULATOR - VIDIOC_S_MODULATOR - Nhận hoặc đặt thuộc tính bộ điều biến

Tóm tắt
========

.. c:macro:: VIDIOC_G_MODULATOR

ZZ0000ZZ

.. c:macro:: VIDIOC_S_MODULATOR

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn các thuộc tính của ứng dụng bộ điều biến, hãy khởi tạo
Trường ZZ0002ZZ và loại bỏ mảng ZZ0003ZZ của cấu trúc
ZZ0000ZZ và gọi
ZZ0001ZZ ioctl với một con trỏ tới cấu trúc này. Trình điều khiển
điền vào phần còn lại của cấu trúc hoặc trả về mã lỗi ZZ0004ZZ khi
chỉ số nằm ngoài giới hạn. Để liệt kê tất cả các ứng dụng điều biến sẽ
bắt đầu ở chỉ số 0, tăng dần một cho đến khi trình điều khiển quay trở lại
EINVAL.

Bộ điều biến có hai thuộc tính có thể ghi, bộ điều chế âm thanh và
tần số vô tuyến. Để thay đổi các chương trình con âm thanh được điều chế, các ứng dụng
khởi tạo các trường ZZ0001ZZ và ZZ0002ZZ và ZZ0003ZZ
mảng và gọi ZZ0000ZZ ioctl. Người lái xe có thể chọn một
điều chế âm thanh khác nếu yêu cầu không thể được đáp ứng. Tuy nhiên
đây là ioctl chỉ ghi, nó không trả về âm thanh thực
điều chế đã chọn.

Các loại bộ điều biến cụ thể của ZZ0000ZZ là ZZ0001ZZ và
ZZ0002ZZ. Đối với các thiết bị SDR, trường ZZ0003ZZ phải là
được khởi tạo về 0. Thuật ngữ 'bộ điều biến' có nghĩa là bộ phát SDR trong này
bối cảnh.

Để thay đổi tần số vô tuyến,
ZZ0000ZZ ioctl có sẵn.

.. tabularcolumns:: |p{2.9cm}|p{2.9cm}|p{5.8cm}|p{2.9cm}|p{2.4cm}|

.. c:type:: v4l2_modulator

.. flat-table:: struct v4l2_modulator
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2 1 1

    * - __u32
      - ``index``
      - Identifies the modulator, set by the application.
    * - __u8
      - ``name``\ [32]
      - Name of the modulator, a NUL-terminated ASCII string.

	This information is intended for the user.
    * - __u32
      - ``capability``
      - Modulator capability flags. No flags are defined for this field,
	the tuner flags in struct :c:type:`v4l2_tuner` are
	used accordingly. The audio flags indicate the ability to encode
	audio subprograms. They will *not* change for example with the
	current video standard.
    * - __u32
      - ``rangelow``
      - The lowest tunable frequency in units of 62.5 KHz, or if the
	``capability`` flag ``V4L2_TUNER_CAP_LOW`` is set, in units of
	62.5 Hz, or if the ``capability`` flag ``V4L2_TUNER_CAP_1HZ`` is
	set, in units of 1 Hz.
    * - __u32
      - ``rangehigh``
      - The highest tunable frequency in units of 62.5 KHz, or if the
	``capability`` flag ``V4L2_TUNER_CAP_LOW`` is set, in units of
	62.5 Hz, or if the ``capability`` flag ``V4L2_TUNER_CAP_1HZ`` is
	set, in units of 1 Hz.
    * - __u32
      - ``txsubchans``
      - With this field applications can determine how audio sub-carriers
	shall be modulated. It contains a set of flags as defined in
	:ref:`modulator-txsubchans`.

	.. note::

	   The tuner ``rxsubchans`` flags  are reused, but the
	   semantics are different. Video output devices
	   are assumed to have an analog or PCM audio input with 1-3
	   channels. The ``txsubchans`` flags select one or more channels
	   for modulation, together with some audio subprogram indicator,
	   for example, a stereo pilot tone.
    * - __u32
      - ``type``
      - :cspan:`2` Type of the modulator, see :c:type:`v4l2_tuner_type`.
    * - __u32
      - ``reserved``\ [3]
      - Reserved for future extensions.

	Drivers and applications must set the array to zero.

.. tabularcolumns:: |p{6.0cm}|p{2.0cm}|p{9.3cm}|

.. cssclass:: longtable

.. _modulator-txsubchans:

.. flat-table:: Modulator Audio Transmission Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_TUNER_SUB_MONO``
      - 0x0001
      - Modulate channel 1 as mono audio, when the input has more
	channels, a down-mix of channel 1 and 2. This flag does not
	combine with ``V4L2_TUNER_SUB_STEREO`` or
	``V4L2_TUNER_SUB_LANG1``.
    * - ``V4L2_TUNER_SUB_STEREO``
      - 0x0002
      - Modulate channel 1 and 2 as left and right channel of a stereo
	audio signal. When the input has only one channel or two channels
	and ``V4L2_TUNER_SUB_SAP`` is also set, channel 1 is encoded as
	left and right channel. This flag does not combine with
	``V4L2_TUNER_SUB_MONO`` or ``V4L2_TUNER_SUB_LANG1``. When the
	driver does not support stereo audio it shall fall back to mono.
    * - ``V4L2_TUNER_SUB_LANG1``
      - 0x0008
      - Modulate channel 1 and 2 as primary and secondary language of a
	bilingual audio signal. When the input has only one channel it is
	used for both languages. It is not possible to encode the primary
	or secondary language only. This flag does not combine with
	``V4L2_TUNER_SUB_MONO``, ``V4L2_TUNER_SUB_STEREO`` or
	``V4L2_TUNER_SUB_SAP``. If the hardware does not support the
	respective audio matrix, or the current video standard does not
	permit bilingual audio the :ref:`VIDIOC_S_MODULATOR <VIDIOC_G_MODULATOR>` ioctl shall
	return an ``EINVAL`` error code and the driver shall fall back to mono
	or stereo mode.
    * - ``V4L2_TUNER_SUB_LANG2``
      - 0x0004
      - Same effect as ``V4L2_TUNER_SUB_SAP``.
    * - ``V4L2_TUNER_SUB_SAP``
      - 0x0004
      - When combined with ``V4L2_TUNER_SUB_MONO`` the first channel is
	encoded as mono audio, the last channel as Second Audio Program.
	When the input has only one channel it is used for both audio
	tracks. When the input has three channels the mono track is a
	down-mix of channel 1 and 2. When combined with
	``V4L2_TUNER_SUB_STEREO`` channel 1 and 2 are encoded as left and
	right stereo audio, channel 3 as Second Audio Program. When the
	input has only two channels, the first is encoded as left and
	right channel and the second as SAP. When the input has only one
	channel it is used for all audio tracks. It is not possible to
	encode a Second Audio Program only. This flag must combine with
	``V4L2_TUNER_SUB_MONO`` or ``V4L2_TUNER_SUB_STEREO``. If the
	hardware does not support the respective audio matrix, or the
	current video standard does not permit SAP the
	:ref:`VIDIOC_S_MODULATOR <VIDIOC_G_MODULATOR>` ioctl shall return an ``EINVAL`` error code and
	driver shall fall back to mono or stereo mode.
    * - ``V4L2_TUNER_SUB_RDS``
      - 0x0010
      - Enable the RDS encoder for a radio FM transmitter.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ là
    ngoài giới hạn.