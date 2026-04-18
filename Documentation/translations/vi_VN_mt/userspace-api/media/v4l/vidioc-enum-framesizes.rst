.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-enum-framesizes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_ENUM_FRAMESIZES:

****************************
ioctl VIDIOC_ENUM_FRAMESIZES
****************************

Tên
====

VIDIOC_ENUM_FRAMESIZES - Liệt kê kích thước khung hình

Tóm tắt
========

.. c:macro:: VIDIOC_ENUM_FRAMESIZES

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ
    chứa định dạng chỉ mục và pixel và nhận được độ rộng khung
    và chiều cao.

Sự miêu tả
===========

Ioctl này cho phép các ứng dụng liệt kê tất cả các kích thước khung hình (tức là chiều rộng
và chiều cao tính bằng pixel) mà thiết bị hỗ trợ cho pixel nhất định
định dạng.

Các định dạng pixel được hỗ trợ có thể thu được bằng cách sử dụng
Chức năng ZZ0000ZZ.

Giá trị trả về và nội dung của trường ZZ0000ZZ
phụ thuộc vào loại kích thước khung hình mà thiết bị hỗ trợ. Đây là
ngữ nghĩa của hàm cho các trường hợp khác nhau:

- ZZ0004ZZ Hàm trả về thành công nếu giá trị chỉ số đã cho
   (dựa trên số 0) là hợp lệ. Ứng dụng sẽ tăng chỉ số lên
   một cho mỗi cuộc gọi cho đến khi ZZ0000ZZ được trả về. các
   Trường ZZ0001ZZ được đặt thành
   ZZ0002ZZ của người lái xe. Trong công đoàn chỉ có
   Thành viên ZZ0003ZZ là hợp lệ.

- ZZ0004ZZ Hàm trả về thành công nếu giá trị chỉ số đã cho
   bằng 0 và ZZ0000ZZ cho bất kỳ giá trị chỉ mục nào khác. các
   Trường ZZ0001ZZ được đặt thành
   ZZ0002ZZ của người lái xe. Trong công đoàn chỉ có
   Thành viên ZZ0003ZZ là hợp lệ.

- ZZ0006ZZ Đây là trường hợp đặc biệt của kiểu step-wise ở trên.
   Hàm trả về thành công nếu giá trị chỉ mục đã cho bằng 0 và
   ZZ0000ZZ cho bất kỳ giá trị chỉ mục nào khác. ZZ0001ZZ
   trường được trình điều khiển đặt thành ZZ0002ZZ. của
   liên minh chỉ có thành viên ZZ0003ZZ hợp lệ và
   Giá trị ZZ0004ZZ và ZZ0005ZZ được đặt thành 1.

Khi ứng dụng gọi hàm có chỉ số 0, nó phải kiểm tra
trường ZZ0000ZZ để xác định loại liệt kê kích thước khung
thiết bị hỗ trợ. Chỉ dành cho loại ZZ0001ZZ
việc tăng giá trị chỉ mục để nhận được nhiều kích thước khung hình hơn là điều hợp lý.

.. note::

   The order in which the frame sizes are returned has no special
   meaning. In particular does it not say anything about potential default
   format sizes.

Các ứng dụng có thể cho rằng dữ liệu liệt kê không thay đổi
mà không có bất kỳ sự tương tác nào từ chính ứng dụng. Điều này có nghĩa là
dữ liệu liệt kê nhất quán nếu ứng dụng không thực hiện bất kỳ
các lệnh gọi ioctl khác trong khi nó chạy bảng liệt kê kích thước khung hình.

Cấu trúc
========

Trong các cấu trúc bên dưới, ZZ0000ZZ biểu thị một giá trị phải được điền bởi
ứng dụng, ZZ0001ZZ biểu thị các giá trị mà trình điều khiển điền vào.
ứng dụng sẽ loại bỏ tất cả các thành viên ngoại trừ các trường ZZ0002ZZ.

.. c:type:: v4l2_frmsize_discrete

.. flat-table:: struct v4l2_frmsize_discrete
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``width``
      - Width of the frame [pixel].
    * - __u32
      - ``height``
      - Height of the frame [pixel].


.. c:type:: v4l2_frmsize_stepwise

.. flat-table:: struct v4l2_frmsize_stepwise
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``min_width``
      - Minimum frame width [pixel].
    * - __u32
      - ``max_width``
      - Maximum frame width [pixel].
    * - __u32
      - ``step_width``
      - Frame width step size [pixel].
    * - __u32
      - ``min_height``
      - Minimum frame height [pixel].
    * - __u32
      - ``max_height``
      - Maximum frame height [pixel].
    * - __u32
      - ``step_height``
      - Frame height step size [pixel].


.. c:type:: v4l2_frmsizeenum

.. tabularcolumns:: |p{6.4cm}|p{2.8cm}|p{8.1cm}|

.. flat-table:: struct v4l2_frmsizeenum
    :header-rows:  0
    :stub-columns: 0

    * - __u32
      - ``index``
      - IN: Index of the given frame size in the enumeration.
    * - __u32
      - ``pixel_format``
      - IN: Pixel format for which the frame sizes are enumerated.
    * - __u32
      - ``type``
      - OUT: Frame size type the device supports.
    * - union {
      - (anonymous)
      - OUT: Frame size with the given index.
    * - struct :c:type:`v4l2_frmsize_discrete`
      - ``discrete``
      -
    * - struct :c:type:`v4l2_frmsize_stepwise`
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

.. c:type:: v4l2_frmsizetypes

.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. flat-table:: enum v4l2_frmsizetypes
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_FRMSIZE_TYPE_DISCRETE``
      - 1
      - Discrete frame size.
    * - ``V4L2_FRMSIZE_TYPE_CONTINUOUS``
      - 2
      - Continuous frame size.
    * - ``V4L2_FRMSIZE_TYPE_STEPWISE``
      - 3
      - Step-wise defined frame size.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.