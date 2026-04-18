.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-decoder-cmd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_DECODER_CMD:

*************************************************
ioctl VIDIOC_DECODER_CMD, VIDIOC_TRY_DECODER_CMD
*************************************************

Tên
====

VIDIOC_DECODER_CMD - VIDIOC_TRY_DECODER_CMD - Thực thi lệnh giải mã

Tóm tắt
========

.. c:macro:: VIDIOC_DECODER_CMD

ZZ0000ZZ

.. c:macro:: VIDIOC_TRY_DECODER_CMD

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ioctls này điều khiển bộ giải mã âm thanh/video (thường là MPEG-).
ZZ0001ZZ gửi lệnh đến bộ giải mã,
ZZ0002ZZ có thể được sử dụng để thử lệnh mà không cần thực sự
thực hiện nó. Để gửi lệnh, ứng dụng phải khởi tạo tất cả các trường
của một cấu trúc ZZ0000ZZ và gọi
ZZ0003ZZ hoặc ZZ0004ZZ với con trỏ tới
cấu trúc này.

Trường ZZ0000ZZ phải chứa mã lệnh. Một số lệnh sử dụng
Trường ZZ0001ZZ để biết thêm thông tin.

ZZ0000ZZ hoặc ZZ0001ZZ
cuộc gọi sẽ gửi lệnh START tiềm ẩn tới bộ giải mã nếu nó chưa được thực hiện
đã bắt đầu chưa. Áp dụng cho cả hai hàng đợi của bộ giải mã mem2mem.

ZZ0000ZZ hoặc ZZ0001ZZ
lệnh gọi của bộ mô tả tệp phát trực tuyến sẽ gửi STOP ngay lập tức
lệnh tới bộ giải mã và tất cả dữ liệu được lưu vào bộ đệm sẽ bị loại bỏ. Áp dụng cho cả hai
hàng đợi của bộ giải mã mem2mem.

Về nguyên tắc, các ioctls này là tùy chọn, không phải trình điều khiển nào cũng có thể hỗ trợ chúng. Họ đã
được giới thiệu trong Linux 3.3. Tuy nhiên, chúng bắt buộc đối với bộ giải mã mem2mem có trạng thái
(như được ghi lại trong ZZ0000ZZ).

.. tabularcolumns:: |p{2.0cm}|p{1.1cm}|p{2.2cm}|p{11.8cm}|

.. c:type:: v4l2_decoder_cmd

.. cssclass:: longtable

.. flat-table:: struct v4l2_decoder_cmd
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 1 1 3

    * - __u32
      - ``cmd``
      -
      - The decoder command, see :ref:`decoder-cmds`.
    * - __u32
      - ``flags``
      -
      - Flags to go with the command. If no flags are defined for this
	command, drivers and applications must set this field to zero.
    * - union {
      - (anonymous)
    * - struct
      - ``start``
      -
      - Structure containing additional data for the
	``V4L2_DEC_CMD_START`` command.
    * -
      - __s32
      - ``speed``
      - Playback speed and direction. The playback speed is defined as
	``speed``/1000 of the normal speed. So 1000 is normal playback.
	Negative numbers denote reverse playback, so -1000 does reverse
	playback at normal speed. Speeds -1, 0 and 1 have special
	meanings: speed 0 is shorthand for 1000 (normal playback). A speed
	of 1 steps just one frame forward, a speed of -1 steps just one
	frame back.
    * -
      - __u32
      - ``format``
      - Format restrictions. This field is set by the driver, not the
	application. Possible values are ``V4L2_DEC_START_FMT_NONE`` if
	there are no format restrictions or ``V4L2_DEC_START_FMT_GOP`` if
	the decoder operates on full GOPs (*Group Of Pictures*). This is
	usually the case for reverse playback: the decoder needs full
	GOPs, which it can then play in reverse order. So to implement
	reverse playback the application must feed the decoder the last
	GOP in the video file, then the GOP before that, etc. etc.
    * - struct
      - ``stop``
      -
      - Structure containing additional data for the ``V4L2_DEC_CMD_STOP``
	command.
    * -
      - __u64
      - ``pts``
      - Stop playback at this ``pts`` or immediately if the playback is
	already past that timestamp. Leave to 0 if you want to stop after
	the last frame was decoded.
    * - struct
      - ``raw``
    * -
      - __u32
      - ``data``\ [16]
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.
    * - }
      -


.. tabularcolumns:: |p{5.6cm}|p{0.6cm}|p{11.1cm}|

.. cssclass:: longtable

.. _decoder-cmds:

.. flat-table:: Decoder Commands
    :header-rows:  0
    :stub-columns: 0
    :widths: 56 6 113

    * - ``V4L2_DEC_CMD_START``
      - 0
      - Start the decoder. When the decoder is already running or paused,
	this command will just change the playback speed. That means that
	calling ``V4L2_DEC_CMD_START`` when the decoder was paused will
	*not* resume the decoder. You have to explicitly call
	``V4L2_DEC_CMD_RESUME`` for that. This command has one flag:
	``V4L2_DEC_CMD_START_MUTE_AUDIO``. If set, then audio will be
	muted when playing back at a non-standard speed.

	For a device implementing the :ref:`decoder`, once the drain sequence
	is initiated with the ``V4L2_DEC_CMD_STOP`` command, it must be driven
	to completion before this command can be invoked.  Any attempt to
	invoke the command while the drain sequence is in progress will trigger
	an ``EBUSY`` error code.  The command may be also used to restart the
	decoder in case of an implicit stop initiated by the decoder itself,
	without the ``V4L2_DEC_CMD_STOP`` being called explicitly. See
	:ref:`decoder` for more details.
    * - ``V4L2_DEC_CMD_STOP``
      - 1
      - Stop the decoder. When the decoder is already stopped, this
	command does nothing. This command has two flags: if
	``V4L2_DEC_CMD_STOP_TO_BLACK`` is set, then the decoder will set
	the picture to black after it stopped decoding. Otherwise the last
	image will repeat. If
	``V4L2_DEC_CMD_STOP_IMMEDIATELY`` is set, then the decoder stops
	immediately (ignoring the ``pts`` value), otherwise it will keep
	decoding until timestamp >= pts or until the last of the pending
	data from its internal buffers was decoded.

	For a device implementing the :ref:`decoder`, the command will initiate
	the drain sequence as documented in :ref:`decoder`.  No flags or other
	arguments are accepted in this case. Any attempt to invoke the command
	again before the sequence completes will trigger an ``EBUSY`` error
	code.
    * - ``V4L2_DEC_CMD_PAUSE``
      - 2
      - Pause the decoder. When the decoder has not been started yet, the
	driver will return an ``EPERM`` error code. When the decoder is
	already paused, this command does nothing. This command has one
	flag: if ``V4L2_DEC_CMD_PAUSE_TO_BLACK`` is set, then set the
	decoder output to black when paused.
    * - ``V4L2_DEC_CMD_RESUME``
      - 3
      - Resume decoding after a PAUSE command. When the decoder has not
	been started yet, the driver will return an ``EPERM`` error code. When
	the decoder is already running, this command does nothing. No
	flags are defined for this command.
    * - ``V4L2_DEC_CMD_FLUSH``
      - 4
      - Flush any held capture buffers. Only valid for stateless decoders.
	This command is typically used when the application reached the
	end of the stream and the last output buffer had the
	``V4L2_BUF_FLAG_M2M_HOLD_CAPTURE_BUF`` flag set. This would prevent
	dequeueing the capture buffer containing the last decoded frame.
	So this command can be used to explicitly flush that final decoded
	frame. This command does nothing if there are no held capture buffers.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EBUSY
    Trình tự thoát của thiết bị triển khai ZZ0000ZZ vẫn đang ở trạng thái
    tiến bộ. Không được phép đưa ra lệnh giải mã khác cho đến khi nó
    hoàn thành.

EINVAL
    Trường ZZ0000ZZ không hợp lệ.

EPERM
    Ứng dụng đã gửi lệnh PAUSE hoặc RESUME khi bộ giải mã được
    không chạy.