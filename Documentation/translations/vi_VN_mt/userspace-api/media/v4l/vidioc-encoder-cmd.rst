.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-encoder-cmd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_ENCODER_CMD:

*************************************************
ioctl VIDIOC_ENCODER_CMD, VIDIOC_TRY_ENCODER_CMD
*************************************************

Tên
====

VIDIOC_ENCODER_CMD - VIDIOC_TRY_ENCODER_CMD - Thực thi lệnh mã hóa

Tóm tắt
========

.. c:macro:: VIDIOC_ENCODER_CMD

ZZ0000ZZ

.. c:macro:: VIDIOC_TRY_ENCODER_CMD

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ioctls này điều khiển bộ mã hóa âm thanh/video (thường là MPEG-).
ZZ0000ZZ gửi lệnh đến bộ mã hóa,
ZZ0001ZZ có thể được sử dụng để thử lệnh mà không cần thực sự
thực hiện nó.

Để gửi lệnh, ứng dụng phải khởi tạo tất cả các trường của cấu trúc
ZZ0000ZZ và gọi
ZZ0001ZZ hoặc ZZ0002ZZ với con trỏ tới
cấu trúc này.

Trường ZZ0000ZZ phải chứa mã lệnh. Một số lệnh sử dụng
Trường ZZ0001ZZ để biết thêm thông tin.

Sau lệnh STOP, các cuộc gọi ZZ0000ZZ sẽ đọc
dữ liệu còn lại được đệm bởi trình điều khiển. Khi bộ đệm trống,
ZZ0001ZZ sẽ trả về số 0 và ZZ0002ZZ tiếp theo
cuộc gọi sẽ khởi động lại bộ mã hóa.

ZZ0000ZZ hoặc ZZ0001ZZ
cuộc gọi sẽ gửi lệnh START ngầm đến bộ mã hóa nếu nó chưa được thực hiện
đã bắt đầu chưa. Áp dụng cho cả hai hàng đợi của bộ mã hóa mem2mem.

ZZ0000ZZ hoặc ZZ0001ZZ
lệnh gọi của bộ mô tả tệp truyền trực tuyến sẽ gửi STOP ngay lập tức tới
bộ mã hóa và tất cả dữ liệu được lưu vào bộ đệm sẽ bị loại bỏ. Áp dụng cho cả hai hàng đợi của
bộ mã hóa mem2mem.

Các ioctls này là tùy chọn, không phải tất cả trình điều khiển đều có thể hỗ trợ chúng. Họ đã
được giới thiệu trong Linux 2.6.21. Tuy nhiên, chúng bắt buộc đối với mem2mem có trạng thái
bộ mã hóa (như được ghi thêm trong ZZ0000ZZ).

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_encoder_cmd

.. flat-table:: struct v4l2_encoder_cmd
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``cmd``
      - The encoder command, see :ref:`encoder-cmds`.
    * - __u32
      - ``flags``
      - Flags to go with the command, see :ref:`encoder-flags`. If no
	flags are defined for this command, drivers and applications must
	set this field to zero.
    * - __u32
      - ``data``\ [8]
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.


.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _encoder-cmds:

.. flat-table:: Encoder Commands
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_ENC_CMD_START``
      - 0
      - Start the encoder. When the encoder is already running or paused,
	this command does nothing. No flags are defined for this command.

	For a device implementing the :ref:`encoder`, once the drain sequence
	is initiated with the ``V4L2_ENC_CMD_STOP`` command, it must be driven
	to completion before this command can be invoked.  Any attempt to
	invoke the command while the drain sequence is in progress will trigger
	an ``EBUSY`` error code. See :ref:`encoder` for more details.
    * - ``V4L2_ENC_CMD_STOP``
      - 1
      - Stop the encoder. When the ``V4L2_ENC_CMD_STOP_AT_GOP_END`` flag
	is set, encoding will continue until the end of the current *Group
	Of Pictures*, otherwise encoding will stop immediately. When the
	encoder is already stopped, this command does nothing.

	For a device implementing the :ref:`encoder`, the command will initiate
	the drain sequence as documented in :ref:`encoder`. No flags or other
	arguments are accepted in this case. Any attempt to invoke the command
	again before the sequence completes will trigger an ``EBUSY`` error
	code.
    * - ``V4L2_ENC_CMD_PAUSE``
      - 2
      - Pause the encoder. When the encoder has not been started yet, the
	driver will return an ``EPERM`` error code. When the encoder is
	already paused, this command does nothing. No flags are defined
	for this command.
    * - ``V4L2_ENC_CMD_RESUME``
      - 3
      - Resume encoding after a PAUSE command. When the encoder has not
	been started yet, the driver will return an ``EPERM`` error code. When
	the encoder is already running, this command does nothing. No
	flags are defined for this command.

.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _encoder-flags:

.. flat-table:: Encoder Command Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_ENC_CMD_STOP_AT_GOP_END``
      - 0x0001
      - Stop encoding at the end of the current *Group Of Pictures*,
	rather than immediately.

        Does not apply to :ref:`encoder`.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EBUSY
    Trình tự thoát của thiết bị triển khai ZZ0000ZZ vẫn đang ở trạng thái
    tiến bộ. Không được phép đưa ra lệnh bộ mã hóa khác cho đến khi nó
    hoàn thành.

EINVAL
    Trường ZZ0000ZZ không hợp lệ.

EPERM
    Ứng dụng đã gửi lệnh PAUSE hoặc RESUME khi bộ mã hóa được
    không chạy.