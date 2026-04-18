.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-enum-frameintervals.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_ENUM_FRAMEINTERVALS:

*******************************
ioctl VIDIOC_ENUM_FRAMEINTERVALS
********************************

Tên
====

VIDIOC_ENUM_FRAMEINTERVALS - Liệt kê các khoảng khung

Tóm tắt
========

.. c:macro:: VIDIOC_ENUM_FRAMEINTERVALS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ
    chứa định dạng và kích thước pixel và nhận được khoảng thời gian khung.

Sự miêu tả
===========

Ioctl này cho phép các ứng dụng liệt kê tất cả các khoảng thời gian khung mà
thiết bị hỗ trợ định dạng pixel và kích thước khung hình nhất định.

Bạn có thể lấy được các định dạng pixel và kích thước khung hình được hỗ trợ bằng cách sử dụng
ZZ0000ZZ và
Chức năng ZZ0001ZZ.

Giá trị trả về và nội dung của trường ZZ0000ZZ
phụ thuộc vào loại khoảng thời gian khung hình mà thiết bị hỗ trợ. Đây là
ngữ nghĩa của hàm cho các trường hợp khác nhau:

- ZZ0004ZZ Hàm trả về thành công nếu giá trị chỉ số đã cho
   (dựa trên số 0) là hợp lệ. Ứng dụng sẽ tăng chỉ số lên
   một cho mỗi cuộc gọi cho đến khi ZZ0000ZZ được trả về. các
   Trường ZZ0001ZZ được đặt thành
   ZZ0002ZZ của người lái xe. Chỉ của công đoàn
   thành viên ZZ0003ZZ là hợp lệ.

- ZZ0004ZZ Hàm trả về thành công nếu giá trị chỉ số đã cho
   bằng 0 và ZZ0000ZZ cho bất kỳ giá trị chỉ mục nào khác. các
   Trường ZZ0001ZZ được đặt thành
   ZZ0002ZZ của người lái xe. Trong công đoàn chỉ có
   Thành viên ZZ0003ZZ là hợp lệ.

- ZZ0005ZZ Đây là trường hợp đặc biệt của loại step-wise ở trên.
   Hàm trả về thành công nếu giá trị chỉ mục đã cho bằng 0 và
   ZZ0000ZZ cho bất kỳ giá trị chỉ mục nào khác. ZZ0001ZZ
   trường được trình điều khiển đặt thành ZZ0002ZZ. của
   liên minh chỉ có thành viên ZZ0003ZZ là hợp lệ và ZZ0004ZZ
   giá trị được đặt thành 1.

Khi ứng dụng gọi hàm có chỉ số 0, nó phải kiểm tra
trường ZZ0000ZZ để xác định loại liệt kê khoảng thời gian khung
thiết bị hỗ trợ. Chỉ dành cho loại ZZ0001ZZ
việc tăng giá trị chỉ mục để nhận được nhiều khung hình hơn có hợp lý không
khoảng thời gian.

.. note::

   The order in which the frame intervals are returned has no
   special meaning. In particular does it not say anything about potential
   default frame intervals.

Các ứng dụng có thể cho rằng dữ liệu liệt kê không thay đổi
mà không có bất kỳ sự tương tác nào từ chính ứng dụng. Điều này có nghĩa là
dữ liệu liệt kê nhất quán nếu ứng dụng không thực hiện bất kỳ
các lệnh gọi ioctl khác trong khi nó chạy phép liệt kê khoảng thời gian khung.

.. note::

   **Frame intervals and frame rates:** The V4L2 API uses frame
   intervals instead of frame rates. Given the frame interval the frame
   rate can be computed as follows:

   ::

       frame_rate = 1 / frame_interval

Cấu trúc
=======

Trong các cấu trúc bên dưới, ZZ0000ZZ biểu thị một giá trị phải được điền bởi
ứng dụng, ZZ0001ZZ biểu thị các giá trị mà trình điều khiển điền vào.
ứng dụng sẽ loại bỏ tất cả các thành viên ngoại trừ các trường ZZ0002ZZ.

.. c:type:: v4l2_frmival_stepwise

.. flat-table:: struct v4l2_frmival_stepwise
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - struct :c:type:`v4l2_fract`
      - ``min``
      - Minimum frame interval [s].
    * - struct :c:type:`v4l2_fract`
      - ``max``
      - Maximum frame interval [s].
    * - struct :c:type:`v4l2_fract`
      - ``step``
      - Frame interval step size [s].


.. c:type:: v4l2_frmivalenum

.. tabularcolumns:: |p{4.9cm}|p{3.3cm}|p{9.1cm}|

.. flat-table:: struct v4l2_frmivalenum
    :header-rows:  0
    :stub-columns: 0

    * - __u32
      - ``index``
      - IN: Index of the given frame interval in the enumeration.
    * - __u32
      - ``pixel_format``
      - IN: Pixel format for which the frame intervals are enumerated.
    * - __u32
      - ``width``
      - IN: Frame width for which the frame intervals are enumerated.
    * - __u32
      - ``height``
      - IN: Frame height for which the frame intervals are enumerated.
    * - __u32
      - ``type``
      - OUT: Frame interval type the device supports.
    * - union {
      - (anonymous)
      - OUT: Frame interval with the given index.
    * - struct :c:type:`v4l2_fract`
      - ``discrete``
      - Frame interval [s].
    * - struct :c:type:`v4l2_frmival_stepwise`
      - ``stepwise``
      -
    * - }
      -
      -
    * - __u32
      - ``reserved[2]``
      - Reserved space for future use. Must be zeroed by drivers and
	applications.


Enum
=====

.. c:type:: v4l2_frmivaltypes

.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. flat-table:: enum v4l2_frmivaltypes
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_FRMIVAL_TYPE_DISCRETE``
      - 1
      - Discrete frame interval.
    * - ``V4L2_FRMIVAL_TYPE_CONTINUOUS``
      - 2
      - Continuous frame interval.
    * - ``V4L2_FRMIVAL_TYPE_STEPWISE``
      - 3
      - Step-wise defined frame interval.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.