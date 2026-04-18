.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-dv-timings-cap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_DV_TIMINGS_CAP:

**********************************************************
ioctl VIDIOC_DV_TIMINGS_CAP, VIDIOC_SUBDEV_DV_TIMINGS_CAP
*********************************************************

Tên
====

VIDIOC_DV_TIMINGS_CAP - VIDIOC_SUBDEV_DV_TIMINGS_CAP - Khả năng của bộ thu/phát Video kỹ thuật số

Tóm tắt
========

.. c:macro:: VIDIOC_DV_TIMINGS_CAP

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_DV_TIMINGS_CAP

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn khả năng của các ứng dụng thu/phát DV
khởi tạo trường ZZ0001ZZ thành 0, bằng 0 mảng dành riêng của cấu trúc
ZZ0000ZZ và gọi
ZZ0002ZZ ioctl trên nút video và trình điều khiển sẽ lấp đầy
trong cấu trúc.

.. note::

   Drivers may return different values after
   switching the video input or output.

Khi được triển khai bởi trình điều khiển DV, khả năng của các thiết bị phụ có thể được
được truy vấn bằng cách gọi trực tiếp ZZ0001ZZ ioctl
trên một nút thiết bị phụ. Các khả năng dành riêng cho đầu vào (đối với DV
thu) hoặc đầu ra (đối với máy phát DV), ứng dụng phải chỉ định
số pad mong muốn trong cấu trúc
Trường ZZ0000ZZ ZZ0002ZZ và
bằng không mảng ZZ0003ZZ. Cố gắng truy vấn các khả năng trên bảng
không hỗ trợ chúng sẽ trả về mã lỗi ZZ0004ZZ.

.. tabularcolumns:: |p{1.2cm}|p{3.2cm}|p{12.9cm}|

.. c:type:: v4l2_bt_timings_cap

.. flat-table:: struct v4l2_bt_timings_cap
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``min_width``
      - Minimum width of the active video in pixels.
    * - __u32
      - ``max_width``
      - Maximum width of the active video in pixels.
    * - __u32
      - ``min_height``
      - Minimum height of the active video in lines.
    * - __u32
      - ``max_height``
      - Maximum height of the active video in lines.
    * - __u64
      - ``min_pixelclock``
      - Minimum pixelclock frequency in Hz.
    * - __u64
      - ``max_pixelclock``
      - Maximum pixelclock frequency in Hz.
    * - __u32
      - ``standards``
      - The video standard(s) supported by the hardware. See
	:ref:`dv-bt-standards` for a list of standards.
    * - __u32
      - ``capabilities``
      - Several flags giving more information about the capabilities. See
	:ref:`dv-bt-cap-capabilities` for a description of the flags.
    * - __u32
      - ``reserved``\ [16]
      - Reserved for future extensions.
	Drivers must set the array to zero.


.. tabularcolumns:: |p{4.4cm}|p{3.6cm}|p{9.3cm}|

.. c:type:: v4l2_dv_timings_cap

.. flat-table:: struct v4l2_dv_timings_cap
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``type``
      - Type of DV timings as listed in :ref:`dv-timing-types`.
    * - __u32
      - ``pad``
      - Pad number as reported by the media controller API. This field is
	only used when operating on a subdevice node. When operating on a
	video node applications must set this field to zero.
    * - __u32
      - ``reserved``\ [2]
      - Reserved for future extensions.

	Drivers and applications must set the array to zero.
    * - union {
      - (anonymous)
    * - struct :c:type:`v4l2_bt_timings_cap`
      - ``bt``
      - BT.656/1120 timings capabilities of the hardware.
    * - __u32
      - ``raw_data``\ [32]
    * - }
      -

.. tabularcolumns:: |p{7.2cm}|p{10.3cm}|

.. _dv-bt-cap-capabilities:

.. flat-table:: DV BT Timing capabilities
    :header-rows:  0
    :stub-columns: 0

    * - Flag
      - Description
    * -
      -
    * - ``V4L2_DV_BT_CAP_INTERLACED``
      - Interlaced formats are supported.
    * - ``V4L2_DV_BT_CAP_PROGRESSIVE``
      - Progressive formats are supported.
    * - ``V4L2_DV_BT_CAP_REDUCED_BLANKING``
      - CVT/GTF specific: the timings can make use of reduced blanking
	(CVT) or the 'Secondary GTF' curve (GTF).
    * - ``V4L2_DV_BT_CAP_CUSTOM``
      - Can support non-standard timings, i.e. timings not belonging to
	the standards set in the ``standards`` field.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.