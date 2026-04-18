.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-frequency.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_FREQUENCY:

********************************************
ioctl VIDIOC_G_FREQUENCY, VIDIOC_S_FREQUENCY
********************************************

Tên
====

VIDIOC_G_FREQUENCY - VIDIOC_S_FREQUENCY - Nhận hoặc đặt tần số vô tuyến của bộ điều chỉnh hoặc bộ điều biến

Tóm tắt
========

.. c:macro:: VIDIOC_G_FREQUENCY

ZZ0000ZZ

.. c:macro:: VIDIOC_S_FREQUENCY

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để cài đặt các ứng dụng tần số vô tuyến của bộ điều chỉnh hoặc bộ điều biến hiện tại
trường ZZ0002ZZ của cấu trúc
ZZ0000ZZ vào bộ chỉnh tương ứng hoặc
số bộ điều biến (chỉ thiết bị đầu vào mới có bộ điều chỉnh, chỉ thiết bị đầu ra
có bộ điều biến), loại bỏ mảng ZZ0003ZZ và gọi
ZZ0001ZZ ioctl với một con trỏ tới cấu trúc này. các
trình điều khiển lưu trữ tần số hiện tại trong trường ZZ0004ZZ.

Để thay đổi các ứng dụng tần số vô tuyến của bộ điều chỉnh hoặc bộ điều biến hiện tại
khởi tạo các trường ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ và
Mảng ZZ0006ZZ của cấu trúc ZZ0000ZZ
và gọi ZZ0001ZZ ioctl bằng một con trỏ tới đây
cấu trúc. Khi không thể thực hiện được tần số yêu cầu, trình điều khiển
giả định giá trị gần nhất có thể. Tuy nhiên ZZ0002ZZ là một
ioctl chỉ ghi, nó không trả về tần số mới thực tế.

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_frequency

.. flat-table:: struct v4l2_frequency
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``tuner``
      - The tuner or modulator index number. This is the same value as in
	the struct :c:type:`v4l2_input` ``tuner`` field and
	the struct :c:type:`v4l2_tuner` ``index`` field, or
	the struct :c:type:`v4l2_output` ``modulator`` field
	and the struct :c:type:`v4l2_modulator` ``index``
	field.
    * - __u32
      - ``type``
      - The tuner type. This is the same value as in the struct
	:c:type:`v4l2_tuner` ``type`` field. The type must be
	set to ``V4L2_TUNER_RADIO`` for ``/dev/radioX`` device nodes, and
	to ``V4L2_TUNER_ANALOG_TV`` for all others. Set this field to
	``V4L2_TUNER_RADIO`` for modulators (currently only radio
	modulators are supported). See :c:type:`v4l2_tuner_type`
    * - __u32
      - ``frequency``
      - Tuning frequency in units of 62.5 kHz, or if the struct
	:c:type:`v4l2_tuner` or struct
	:c:type:`v4l2_modulator` ``capability`` flag
	``V4L2_TUNER_CAP_LOW`` is set, in units of 62.5 Hz. A 1 Hz unit is
	used when the ``capability`` flag ``V4L2_TUNER_CAP_1HZ`` is set.
    * - __u32
      - ``reserved``\ [8]
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Chỉ số ZZ0000ZZ nằm ngoài giới hạn hoặc giá trị trong ZZ0001ZZ
    trường sai.

EBUSY
    Một cuộc tìm kiếm phần cứng đang được tiến hành.