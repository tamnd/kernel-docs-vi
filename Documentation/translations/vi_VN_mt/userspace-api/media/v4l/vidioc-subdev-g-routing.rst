.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-g-routing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_G_ROUTING:

**********************************************************
ioctl VIDIOC_SUBDEV_G_ROUTING, VIDIOC_SUBDEV_S_ROUTING
**********************************************************

Tên
====

VIDIOC_SUBDEV_G_ROUTING - VIDIOC_SUBDEV_S_ROUTING - Nhận hoặc đặt định tuyến giữa các luồng của phần phương tiện trong thực thể phương tiện.


Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_G_ROUTING

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_S_ROUTING

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.


Sự miêu tả
===========

Các ioctl này được sử dụng để nhận và đặt định tuyến trong thực thể phương tiện.
Cấu hình định tuyến xác định luồng dữ liệu bên trong một thực thể.

Trình điều khiển báo cáo bảng định tuyến hiện tại của họ bằng cách sử dụng
ZZ0001ZZ ioctl và ứng dụng có thể bật hoặc tắt các tuyến đường
với ZZ0002ZZ ioctl, bằng cách thêm hoặc xóa các tuyến đường và
thiết lập hoặc xóa cờ của trường ZZ0003ZZ của cấu trúc
ZZ0000ZZ. Tương tự như ZZ0004ZZ, cũng
ZZ0005ZZ trả lại các tuyến đường cho người dùng.

Tất cả cấu hình luồng được đặt lại khi ZZ0000ZZ được gọi.
Điều này có nghĩa là không gian người dùng phải cấu hình lại tất cả các lựa chọn và định dạng luồng
sau khi gọi ioctl bằng ví dụ: ZZ0001ZZ.

Chỉ những thiết bị con có cả phần đệm nguồn và phần chìm mới có thể hỗ trợ định tuyến.

Trường ZZ0000ZZ cho biết số lượng tuyến đường có thể phù hợp với
Mảng ZZ0001ZZ được phân bổ theo không gian người dùng. Nó được thiết lập bởi các ứng dụng cho cả hai
ioctls để cho biết kernel có thể quay lại bao nhiêu tuyến đường và không bao giờ được sửa đổi
bởi hạt nhân.

Trường ZZ0000ZZ cho biết số lượng tuyến đường trong định tuyến
cái bàn. Đối với ZZ0001ZZ, nó được không gian người dùng đặt thành số lượng
định tuyến mà ứng dụng được lưu trữ trong mảng ZZ0002ZZ. Đối với cả ioctls, nó
được hạt nhân trả về và cho biết có bao nhiêu tuyến đường được lưu trữ trong
bảng định tuyến thiết bị phụ. Giá trị này có thể nhỏ hơn hoặc lớn hơn giá trị của
ZZ0003ZZ được thiết lập bởi ứng dụng dành cho ZZ0004ZZ, như
trình điều khiển có thể điều chỉnh bảng định tuyến được yêu cầu.

Hạt nhân có thể trả về giá trị ZZ0000ZZ lớn hơn ZZ0001ZZ từ
cả ioctls. Điều này cho thấy có nhiều tuyến đường trong bảng định tuyến hơn mức phù hợp
mảng ZZ0002ZZ. Trong trường hợp này, mảng ZZ0003ZZ được lấp đầy bởi kernel
với các mục ZZ0004ZZ đầu tiên của bảng định tuyến thiết bị con. Đây là
không được coi là lỗi và cuộc gọi ioctl thành công. Nếu các ứng dụng
muốn lấy lại các tuyến đường còn thiếu, nó có thể đưa ra một tuyến đường mới
Cuộc gọi ZZ0005ZZ với mảng ZZ0006ZZ đủ lớn.

ZZ0000ZZ có thể trả về nhiều tuyến đường hơn người dùng đã cung cấp trong
Trường ZZ0001ZZ do ví dụ: thuộc tính phần cứng.

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.7cm}|

.. c:type:: v4l2_subdev_routing

.. flat-table:: struct v4l2_subdev_routing
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``which``
      - Routing table to be accessed, from enum
        :ref:`v4l2_subdev_format_whence <v4l2-subdev-format-whence>`.
    * - __u32
      - ``len_routes``
      - The length of the array (as in memory reserved for the array)
    * - struct :c:type:`v4l2_subdev_route`
      - ``routes[]``
      - Array of struct :c:type:`v4l2_subdev_route` entries
    * - __u32
      - ``num_routes``
      - Number of entries of the routes array
    * - __u32
      - ``reserved``\ [11]
      - Reserved for future extensions. Applications and drivers must set
	the array to zero.

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.7cm}|

.. c:type:: v4l2_subdev_route

.. flat-table:: struct v4l2_subdev_route
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``sink_pad``
      - Sink pad number.
    * - __u32
      - ``sink_stream``
      - Sink pad stream number.
    * - __u32
      - ``source_pad``
      - Source pad number.
    * - __u32
      - ``source_stream``
      - Source pad stream number.
    * - __u32
      - ``flags``
      - Route enable/disable flags
	:ref:`v4l2_subdev_routing_flags <v4l2-subdev-routing-flags>`.
    * - __u32
      - ``reserved``\ [5]
      - Reserved for future extensions. Applications and drivers must set
	the array to zero.

.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.7cm}|

.. _v4l2-subdev-routing-flags:

.. flat-table:: enum v4l2_subdev_routing_flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - V4L2_SUBDEV_ROUTE_FL_ACTIVE
      - 0x0001
      - The route is enabled. Set by applications.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
   Mã định danh phần chìm hoặc phần nguồn tham chiếu phần đệm hoặc phần tham chiếu không tồn tại
   các loại miếng đệm khác nhau (ví dụ: số nhận dạng sink_pad đề cập đến một nguồn
   pad), trường ZZ0000ZZ có giá trị không được hỗ trợ hoặc, đối với
   ZZ0001ZZ, trường num_routes do ứng dụng đặt là
   lớn hơn giá trị trường len_routes.

ENXIO
   Không thể tạo các tuyến đường yêu cầu ứng dụng hoặc trạng thái của
   các tuyến đường được chỉ định không thể được sửa đổi. Chỉ trả lại cho
   ZZ0000ZZ.

E2BIG
   Ứng dụng được cung cấp ZZ0000ZZ cho ZZ0001ZZ là
   lớn hơn số lượng tuyến đường mà người lái xe có thể xử lý.