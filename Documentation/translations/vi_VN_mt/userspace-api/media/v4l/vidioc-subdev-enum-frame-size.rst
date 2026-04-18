.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-enum-frame-size.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_ENUM_FRAME_SIZE:

***********************************
ioctl VIDIOC_SUBDEV_ENUM_FRAME_SIZE
***********************************

Tên
====

VIDIOC_SUBDEV_ENUM_FRAME_SIZE - Liệt kê kích thước khung bus phương tiện

Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_ENUM_FRAME_SIZE

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này cho phép các ứng dụng truy cập vào bảng liệt kê kích thước khung
được hỗ trợ bởi một thiết bị phụ trên bảng được chỉ định
cho định dạng bus phương tiện được chỉ định.
Các định dạng được hỗ trợ có thể được truy xuất bằng
ZZ0000ZZ
ioctl.

Các bảng liệt kê được xác định bởi trình điều khiển và được lập chỉ mục bằng trường ZZ0001ZZ
của cấu trúc ZZ0000ZZ.
Mỗi cặp ZZ0002ZZ và ZZ0003ZZ tương ứng với một bảng liệt kê riêng biệt.
Mỗi bảng liệt kê bắt đầu bằng ZZ0004ZZ bằng 0 và
chỉ số không hợp lệ thấp nhất đánh dấu sự kết thúc của phép liệt kê.

Vì vậy, để liệt kê các kích thước khung hình được phép trên pad được chỉ định
và sử dụng định dạng mbus đã chỉ định, khởi tạo
Các trường ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ thành các giá trị mong muốn,
và đặt ZZ0004ZZ thành 0.
Sau đó gọi ZZ0000ZZ ioctl bằng một con trỏ tới
cấu trúc.

Cuộc gọi thành công sẽ trở lại với kích thước khung hình tối thiểu và tối đa được điền vào.
Lặp lại với việc tăng ZZ0000ZZ cho đến khi nhận được ZZ0001ZZ.
ZZ0002ZZ có nghĩa là không có thêm mục nào trong bảng liệt kê,
hoặc tham số đầu vào không hợp lệ.

Các thiết bị phụ chỉ hỗ trợ các kích thước khung hình riêng biệt (chẳng hạn như hầu hết
cảm biến) sẽ trả về một hoặc nhiều kích thước khung hình với mức tối thiểu và
các giá trị tối đa.

Không phải tất cả các kích thước có thể có trong phạm vi [tối thiểu, tối đa] nhất định đều cần phải được
được hỗ trợ. Ví dụ: bộ chia tỷ lệ sử dụng tỷ lệ chia tỷ lệ điểm cố định
có thể không thể tạo ra mọi kích thước khung hình từ mức tối thiểu đến
các giá trị tối đa. Các ứng dụng phải sử dụng
ZZ0000ZZ ioctl để dùng thử
thiết bị phụ để có kích thước khung hình được hỗ trợ chính xác.

Kích thước khung có sẵn có thể phụ thuộc vào định dạng 'thử' hiện tại ở các định dạng khác
các miếng đệm của thiết bị phụ, cũng như trên các liên kết hoạt động hiện tại và
giá trị hiện tại của bộ điều khiển V4L2. Xem
ZZ0000ZZ để biết thêm
thông tin về các định dạng thử.

.. c:type:: v4l2_subdev_frame_size_enum

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_subdev_frame_size_enum
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``index``
      - Index of the frame size in the enumeration belonging to the given pad
	and format. Filled in by the application.
    * - __u32
      - ``pad``
      - Pad number as reported by the media controller API.
	Filled in by the application.
    * - __u32
      - ``code``
      - The media bus format code, as defined in
	:ref:`v4l2-mbus-format`. Filled in by the application.
    * - __u32
      - ``min_width``
      - Minimum frame width, in pixels. Filled in by the driver.
    * - __u32
      - ``max_width``
      - Maximum frame width, in pixels. Filled in by the driver.
    * - __u32
      - ``min_height``
      - Minimum frame height, in pixels. Filled in by the driver.
    * - __u32
      - ``max_height``
      - Maximum frame height, in pixels. Filled in by the driver.
    * - __u32
      - ``which``
      - Frame sizes to be enumerated, from enum
	:ref:`v4l2_subdev_format_whence <v4l2-subdev-format-whence>`.
    * - __u32
      - ``stream``
      - Stream identifier.
    * - __u32
      - ``reserved``\ [7]
      - Reserved for future extensions. Applications and drivers must set
	the array to zero.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ tham chiếu đến một
    phần đệm không tồn tại, trường ZZ0002ZZ có giá trị không được hỗ trợ, ZZ0003ZZ
    không hợp lệ đối với bảng đã cho hoặc trường ZZ0004ZZ nằm ngoài giới hạn.