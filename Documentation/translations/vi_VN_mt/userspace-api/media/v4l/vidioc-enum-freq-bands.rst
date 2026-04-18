.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-enum-freq-bands.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_ENUM_FREQ_BANDS:

****************************
ioctl VIDIOC_ENUM_FREQ_BANDS
****************************

Tên
====

VIDIOC_ENUM_FREQ_BANDS - Liệt kê các dải tần được hỗ trợ

Tóm tắt
========

.. c:macro:: VIDIOC_ENUM_FREQ_BANDS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Liệt kê các dải tần mà bộ điều chỉnh hoặc bộ điều biến hỗ trợ. để làm
ứng dụng này khởi tạo ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ
các trường và loại bỏ mảng ZZ0005ZZ của cấu trúc
ZZ0000ZZ và gọi
ZZ0001ZZ ioctl với một con trỏ tới cấu trúc này.

Ioctl này được hỗ trợ nếu khả năng ZZ0000ZZ
của bộ điều chỉnh/điều biến tương ứng được thiết lập.

.. tabularcolumns:: |p{2.9cm}|p{2.9cm}|p{5.8cm}|p{2.9cm}|p{2.4cm}|

.. c:type:: v4l2_frequency_band

.. flat-table:: struct v4l2_frequency_band
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2 1 1

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
      - ``index``
      - Identifies the frequency band, set by the application.
    * - __u32
      - ``capability``
      - :cspan:`2` The tuner/modulator capability flags for this
	frequency band, see :ref:`tuner-capability`. The
	``V4L2_TUNER_CAP_LOW`` or ``V4L2_TUNER_CAP_1HZ`` capability must
	be the same for all frequency bands of the selected
	tuner/modulator. So either all bands have that capability set, or
	none of them have that capability.
    * - __u32
      - ``rangelow``
      - :cspan:`2` The lowest tunable frequency in units of 62.5 kHz, or
	if the ``capability`` flag ``V4L2_TUNER_CAP_LOW`` is set, in units
	of 62.5 Hz, for this frequency band. A 1 Hz unit is used when the
	``capability`` flag ``V4L2_TUNER_CAP_1HZ`` is set.
    * - __u32
      - ``rangehigh``
      - :cspan:`2` The highest tunable frequency in units of 62.5 kHz,
	or if the ``capability`` flag ``V4L2_TUNER_CAP_LOW`` is set, in
	units of 62.5 Hz, for this frequency band. A 1 Hz unit is used
	when the ``capability`` flag ``V4L2_TUNER_CAP_1HZ`` is set.
    * - __u32
      - ``modulation``
      - :cspan:`2` The supported modulation systems of this frequency
	band. See :ref:`band-modulation`.

	.. note::

	   Currently only one modulation system per frequency band
	   is supported. More work will need to be done if multiple
	   modulation systems are possible. Contact the linux-media
	   mailing list
	   (`https://linuxtv.org/lists.php <https://linuxtv.org/lists.php>`__)
	   if you need such functionality.
    * - __u32
      - ``reserved``\ [9]
      - Reserved for future extensions.

	Applications and drivers must set the array to zero.


.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _band-modulation:

.. flat-table:: Band Modulation Systems
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_BAND_MODULATION_VSB``
      - 0x02
      - Vestigial Sideband modulation, used for analog TV.
    * - ``V4L2_BAND_MODULATION_FM``
      - 0x04
      - Frequency Modulation, commonly used for analog radio.
    * - ``V4L2_BAND_MODULATION_AM``
      - 0x08
      - Amplitude Modulation, commonly used for analog radio.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    ZZ0000ZZ hoặc ZZ0001ZZ nằm ngoài giới hạn hoặc trường ZZ0002ZZ nằm ngoài giới hạn
    sai.