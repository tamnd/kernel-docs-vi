.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-priority.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_PRIORITY:

*******************************************
ioctl VIDIOC_G_PRIORITY, VIDIOC_S_PRIORITY
*******************************************

Tên
====

VIDIOC_G_PRIORITY - VIDIOC_S_PRIORITY - Truy vấn hoặc yêu cầu mức độ ưu tiên truy cập được liên kết với bộ mô tả tệp

Tóm tắt
========

.. c:macro:: VIDIOC_G_PRIORITY

ZZ0000ZZ

.. c:macro:: VIDIOC_S_PRIORITY

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới loại enum ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn các ứng dụng ưu tiên truy cập hiện tại, hãy gọi
ZZ0000ZZ ioctl với con trỏ tới enum v4l2_priority
biến nơi trình điều khiển lưu trữ mức độ ưu tiên hiện tại.

Để yêu cầu mức độ ưu tiên truy cập, các ứng dụng sẽ lưu trữ mức độ ưu tiên mong muốn trong
một biến enum v4l2_priority và gọi ZZ0000ZZ ioctl
với một con trỏ tới biến này.

.. c:type:: v4l2_priority

.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. flat-table:: enum v4l2_priority
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_PRIORITY_UNSET``
      - 0
      -
    * - ``V4L2_PRIORITY_BACKGROUND``
      - 1
      - Lowest priority, usually applications running in background, for
	example monitoring VBI transmissions. A proxy application running
	in user space will be necessary if multiple applications want to
	read from a device at this priority.
    * - ``V4L2_PRIORITY_INTERACTIVE``
      - 2
      -
    * - ``V4L2_PRIORITY_DEFAULT``
      - 2
      - Medium priority, usually applications started and interactively
	controlled by the user. For example TV viewers, Teletext browsers,
	or just "panel" applications to change the channel or video
	controls. This is the default priority unless an application
	requests another.
    * - ``V4L2_PRIORITY_RECORD``
      - 3
      - Highest priority. Only one file descriptor can have this priority,
	it blocks any other fd from changing device properties. Usually
	applications which must not be interrupted, like video recording.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Giá trị ưu tiên được yêu cầu không hợp lệ.

EBUSY
    Một ứng dụng khác đã yêu cầu mức độ ưu tiên cao hơn.