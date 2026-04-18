.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-sliced-vbi-cap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_SLICED_VBI_CAP:

*****************************
ioctl VIDIOC_G_SLICED_VBI_CAP
*****************************

Tên
====

VIDIOC_G_SLICED_VBI_CAP - Truy vấn các khả năng VBI được cắt lát

Tóm tắt
========

.. c:macro:: VIDIOC_G_SLICED_VBI_CAP

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để tìm hiểu dịch vụ dữ liệu nào được hỗ trợ bởi bản chụp VBI được cắt lát hoặc
thiết bị đầu ra, các ứng dụng khởi tạo trường ZZ0002ZZ của cấu trúc
ZZ0000ZZ, xóa
Mảng ZZ0003ZZ và gọi ZZ0001ZZ ioctl. các
trình điều khiển điền vào các trường còn lại hoặc trả về mã lỗi ZZ0004ZZ nếu
VBI API được cắt lát không được hỗ trợ hoặc ZZ0005ZZ không hợp lệ.

.. note::

   The ``type`` field was added, and the ioctl changed from read-only
   to write-read, in Linux 2.6.19.

.. c:type:: v4l2_sliced_vbi_cap

.. tabularcolumns:: |p{1.4cm}|p{4.4cm}|p{4.5cm}|p{3.6cm}|p{3.6cm}|

.. flat-table:: struct v4l2_sliced_vbi_cap
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 3 2 2 2

    * - __u16
      - ``service_set``
      - :cspan:`2` A set of all data services supported by the driver.

	Equal to the union of all elements of the ``service_lines`` array.
    * - __u16
      - ``service_lines``\ [2][24]
      - :cspan:`2` Each element of this array contains a set of data
	services the hardware can look for or insert into a particular
	scan line. Data services are defined in :ref:`vbi-services`.
	Array indices map to ITU-R line numbers\ [#f1]_ as follows:
    * -
      -
      - Element
      - 525 line systems
      - 625 line systems
    * -
      -
      - ``service_lines``\ [0][1]
      - 1
      - 1
    * -
      -
      - ``service_lines``\ [0][23]
      - 23
      - 23
    * -
      -
      - ``service_lines``\ [1][1]
      - 264
      - 314
    * -
      -
      - ``service_lines``\ [1][23]
      - 286
      - 336
    * -
    * -
      -
      - :cspan:`2` The number of VBI lines the hardware can capture or
	output per frame, or the number of services it can identify on a
	given line may be limited. For example on PAL line 16 the hardware
	may be able to look for a VPS or Teletext signal, but not both at
	the same time. Applications can learn about these limits using the
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl as described in
	:ref:`sliced`.
    * -
    * -
      -
      - :cspan:`2` Drivers must set ``service_lines`` [0][0] and
	``service_lines``\ [1][0] to zero.
    * - __u32
      - ``type``
      - Type of the data stream, see :c:type:`v4l2_buf_type`. Should be
	``V4L2_BUF_TYPE_SLICED_VBI_CAPTURE`` or
	``V4L2_BUF_TYPE_SLICED_VBI_OUTPUT``.
    * - __u32
      - ``reserved``\ [3]
      - :cspan:`2` This array is reserved for future extensions.

	Applications and drivers must set it to zero.

.. [#f1]

   See also :ref:`vbi-525` and :ref:`vbi-625`.

.. raw:: latex

    \scriptsize

.. tabularcolumns:: |p{3.9cm}|p{1.0cm}|p{2.0cm}|p{3.0cm}|p{7.0cm}|

.. _vbi-services:

.. flat-table:: Sliced VBI services
    :header-rows:  1
    :stub-columns: 0
    :widths:       2 1 1 2 2

    * - Symbol
      - Value
      - Reference
      - Lines, usually
      - Payload
    * - ``V4L2_SLICED_TELETEXT_B`` (Teletext System B)
      - 0x0001
      - :ref:`ets300706`,

	:ref:`itu653`
      - PAL/SECAM line 7-22, 320-335 (second field 7-22)
      - Last 42 of the 45 byte Teletext packet, that is without clock
	run-in and framing code, lsb first transmitted.
    * - ``V4L2_SLICED_VPS``
      - 0x0400
      - :ref:`ets300231`
      - PAL line 16
      - Byte number 3 to 15 according to Figure 9 of ETS 300 231, lsb
	first transmitted.
    * - ``V4L2_SLICED_CAPTION_525``
      - 0x1000
      - :ref:`cea608`
      - NTSC line 21, 284 (second field 21)
      - Two bytes in transmission order, including parity bit, lsb first
	transmitted.
    * - ``V4L2_SLICED_WSS_625``
      - 0x4000
      - :ref:`en300294`,

	:ref:`itu1119`
      - PAL/SECAM line 23
      - See :ref:`v4l2-sliced-vbi-cap-wss-625-payload` below.
    * - ``V4L2_SLICED_VBI_525``
      - 0x1000
      - :cspan:`2` Set of services applicable to 525 line systems.
    * - ``V4L2_SLICED_VBI_625``
      - 0x4401
      - :cspan:`2` Set of services applicable to 625 line systems.


.. raw:: latex

    \normalsize

.. _v4l2-sliced-vbi-cap-wss-625-payload:

Tải trọng V4L2_SLICED_VBI_CAP WSS_625
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tải trọng cho ZZ0000ZZ là:

+------+-------------------+--------------+
	    ZZ0000ZZ 0 ZZ0001ZZ
	    +------+--------+---------+-------------+----------+
	    ZZ0002ZZ msb ZZ0003ZZ msb ZZ0004ZZ
	    |     +-+-+-+--+--+-+-+--+--+-+--+---+---+--+-+--+
	    ZZ0005ZZ7ZZ0006ZZ5ZZ0007ZZ 3|2|1|0 | x|x|13|12 | 11|10|9|8 |
	    +------+-+-+-+--+--+-+-+--+--+-+--+---+---+--+-+--+


Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Giá trị trong trường ZZ0000ZZ sai.