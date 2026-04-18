.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-enum-frame-interval.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_ENUM_FRAME_INTERVAL:

****************************************
ioctl VIDIOC_SUBDEV_ENUM_FRAME_INTERVAL
****************************************

Tên
====

VIDIOC_SUBDEV_ENUM_FRAME_INTERVAL - Liệt kê các khoảng khung

Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_ENUM_FRAME_INTERVAL

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này cho phép các ứng dụng liệt kê các khoảng thời gian khung hình có sẵn trên một
miếng đệm thiết bị phụ được cung cấp. Khoảng thời gian khung hình chỉ có ý nghĩa đối với các thiết bị phụ
có thể tự kiểm soát thời gian khung hình. Điều này bao gồm, đối với
ví dụ, cảm biến hình ảnh và bộ điều chỉnh TV.

Đối với trường hợp sử dụng thông thường của cảm biến hình ảnh, khoảng thời gian khung hình có sẵn
trên bảng đầu ra của thiết bị phụ tùy thuộc vào định dạng và kích thước khung hình trên
cùng một miếng đệm. Do đó, các ứng dụng phải chỉ định định dạng và kích thước mong muốn
khi liệt kê các khoảng khung.

Để liệt kê các khoảng thời gian khung, các ứng dụng hãy khởi tạo ZZ0002ZZ,
Các trường ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ và ZZ0007ZZ của cấu trúc
ZZ0000ZZ
và gọi ZZ0001ZZ ioctl bằng một con trỏ
đến cấu trúc này. Trình điều khiển lấp đầy phần còn lại của cấu trúc hoặc trả về một
Mã lỗi EINVAL nếu một trong các trường nhập không hợp lệ. Tất cả khung hình
các khoảng có thể đếm được bằng cách bắt đầu từ chỉ số 0 và tăng dần theo
một cho đến khi ZZ0008ZZ được trả lại.

Khoảng thời gian khung có sẵn có thể phụ thuộc vào định dạng 'thử' hiện tại tại
các miếng đệm khác của thiết bị phụ, cũng như trên các liên kết hoạt động hiện tại.
Xem ZZ0000ZZ để biết thêm
thông tin về các định dạng thử.

Các thiết bị phụ hỗ trợ ioctl liệt kê khoảng thời gian khung
thực hiện nó chỉ trên một bảng duy nhất. Hành vi của nó khi được hỗ trợ trên
nhiều miếng đệm của cùng một thiết bị phụ không được xác định.

.. c:type:: v4l2_subdev_frame_interval_enum

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_subdev_frame_interval_enum
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``index``
      - Number of the format in the enumeration, set by the application.
    * - __u32
      - ``pad``
      - Pad number as reported by the media controller API.
    * - __u32
      - ``code``
      - The media bus format code, as defined in
	:ref:`v4l2-mbus-format`.
    * - __u32
      - ``width``
      - Frame width, in pixels.
    * - __u32
      - ``height``
      - Frame height, in pixels.
    * - struct :c:type:`v4l2_fract`
      - ``interval``
      - Period, in seconds, between consecutive video frames.
    * - __u32
      - ``which``
      - Frame intervals to be enumerated, from enum
	:ref:`v4l2_subdev_format_whence <v4l2-subdev-format-whence>`.
    * - __u32
      - ``stream``
      - Stream identifier.
    * - __u32
      - ``reserved``\ [7]
      - Reserved for future extensions. Applications and drivers must set
	the array to zero.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ tham chiếu đến một
    phần đệm không tồn tại, trường ZZ0002ZZ có giá trị không được hỗ trợ, một trong những
    Các trường ZZ0003ZZ, ZZ0004ZZ hoặc ZZ0005ZZ không hợp lệ đối với bảng đã cho hoặc
    trường ZZ0006ZZ nằm ngoài giới hạn.