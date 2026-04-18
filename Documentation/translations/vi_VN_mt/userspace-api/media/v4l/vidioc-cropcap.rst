.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-cropcap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_CROPCAP:

********************
ioctl VIDIOC_CROPCAP
********************

Tên
====

VIDIOC_CROPCAP - Thông tin về khả năng cắt xén và chia tỷ lệ video

Tóm tắt
========

.. c:macro:: VIDIOC_CROPCAP

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ứng dụng sử dụng chức năng này để truy vấn giới hạn cắt xén, kích thước pixel
khía cạnh của hình ảnh và để tính toán các hệ số tỷ lệ. Họ đặt ZZ0001ZZ
trường của cấu trúc v4l2_cropcap vào bộ đệm (luồng) tương ứng
gõ và gọi ZZ0000ZZ ioctl bằng một con trỏ tới đây
cấu trúc. Trình điều khiển lấp đầy phần còn lại của cấu trúc. Kết quả là
không đổi ngoại trừ khi chuyển đổi tiêu chuẩn video. Hãy nhớ công tắc này
có thể xảy ra ngầm khi chuyển đổi đầu vào hoặc đầu ra video.

Ioctl này phải được triển khai cho các thiết bị quay video hoặc đầu ra
hỗ trợ cắt xén và/hoặc chia tỷ lệ và/hoặc có các pixel không vuông và cho
thiết bị lớp phủ.

.. c:type:: v4l2_cropcap

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_cropcap
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``type``
      - Type of the data stream, set by the application. Only these types
	are valid here: ``V4L2_BUF_TYPE_VIDEO_CAPTURE``, ``V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE``,
	``V4L2_BUF_TYPE_VIDEO_OUTPUT``, ``V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE`` and
	``V4L2_BUF_TYPE_VIDEO_OVERLAY``. See :c:type:`v4l2_buf_type` and the note below.
    * - struct :ref:`v4l2_rect <v4l2-rect-crop>`
      - ``bounds``
      - Defines the window within capturing or output is possible, this
	may exclude for example the horizontal and vertical blanking
	areas. The cropping rectangle cannot exceed these limits. Width
	and height are defined in pixels, the driver writer is free to
	choose origin and units of the coordinate system in the analog
	domain.
    * - struct :ref:`v4l2_rect <v4l2-rect-crop>`
      - ``defrect``
      - Default cropping rectangle, it shall cover the "whole picture".
	Assuming pixel aspect 1/1 this could be for example a 640 × 480
	rectangle for NTSC, a 768 × 576 rectangle for PAL and SECAM
	centered over the active picture area. The same coordinate system
	as for ``bounds`` is used.
    * - struct :c:type:`v4l2_fract`
      - ``pixelaspect``
      - This is the pixel aspect (y / x) when no scaling is applied, the
	ratio of the actual sampling frequency and the frequency required
	to get square pixels.

	When cropping coordinates refer to square pixels, the driver sets
	``pixelaspect`` to 1/1. Other common values are 54/59 for PAL and
	SECAM, 11/10 for NTSC sampled according to [:ref:`itu601`].

.. note::
   Unfortunately in the case of multiplanar buffer types
   (``V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE`` and ``V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE``)
   this API was messed up with regards to how the :c:type:`v4l2_cropcap` ``type`` field
   should be filled in. Some drivers only accepted the ``_MPLANE`` buffer type while
   other drivers only accepted a non-multiplanar buffer type (i.e. without the
   ``_MPLANE`` at the end).

   Starting with kernel 4.13 both variations are allowed.


.. _v4l2-rect-crop:

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_rect
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __s32
      - ``left``
      - Horizontal offset of the top, left corner of the rectangle, in
	pixels.
    * - __s32
      - ``top``
      - Vertical offset of the top, left corner of the rectangle, in
	pixels.
    * - __u32
      - ``width``
      - Width of the rectangle, in pixels.
    * - __u32
      - ``height``
      - Height of the rectangle, in pixels.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ là
    không hợp lệ.

ENODATA
    Việc cắt xén không được hỗ trợ cho đầu vào hoặc đầu ra này.