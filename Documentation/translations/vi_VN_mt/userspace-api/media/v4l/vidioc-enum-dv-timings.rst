.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-enum-dv-timings.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_ENUM_DV_TIMINGS:

*************************************************************
ioctl VIDIOC_ENUM_DV_TIMINGS, VIDIOC_SUBDEV_ENUM_DV_TIMINGS
*************************************************************

Tên
====

VIDIOC_ENUM_DV_TIMINGS - VIDIOC_SUBDEV_ENUM_DV_TIMINGS - Liệt kê thời gian Video kỹ thuật số được hỗ trợ

Tóm tắt
========

.. c:macro:: VIDIOC_ENUM_DV_TIMINGS

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_ENUM_DV_TIMINGS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Trong khi một số máy thu hoặc máy phát DV hỗ trợ nhiều loại thời gian,
những người khác chỉ hỗ trợ một số thời gian giới hạn. Với ioctl này
các ứng dụng có thể liệt kê danh sách các khoảng thời gian được hỗ trợ đã biết. Gọi
ZZ0000ZZ để kiểm tra xem nó có
cũng hỗ trợ các tiêu chuẩn khác hoặc thậm chí cả thời gian tùy chỉnh không có trong
danh sách này.

Để truy vấn thời gian có sẵn, các ứng dụng khởi tạo ZZ0001ZZ
trường, đặt trường ZZ0002ZZ thành 0, bằng 0 mảng dành riêng của cấu trúc
ZZ0000ZZ và gọi
ZZ0003ZZ ioctl trên nút video có con trỏ tới đây
cấu trúc. Trình điều khiển lấp đầy phần còn lại của cấu trúc hoặc trả về ZZ0004ZZ
mã lỗi khi chỉ số nằm ngoài giới hạn. Để liệt kê tất cả được hỗ trợ
Định thời DV, các ứng dụng sẽ bắt đầu ở chỉ số 0, tăng dần một
cho đến khi tài xế trả về ZZ0005ZZ.

.. note::

   Drivers may enumerate a different set of DV timings after
   switching the video input or output.

Khi được trình điều khiển triển khai, thời gian DV của các thiết bị phụ có thể được truy vấn
bằng cách gọi trực tiếp ZZ0001ZZ ioctl trên
nút thiết bị phụ. Thời gian DV dành riêng cho đầu vào (đối với máy thu DV)
hoặc đầu ra (đối với máy phát DV), ứng dụng phải chỉ định kết quả mong muốn
số pad trong cấu trúc
Trường ZZ0000ZZ ZZ0002ZZ.
Những nỗ lực liệt kê thời gian trên một bảng không hỗ trợ chúng sẽ
trả về mã lỗi ZZ0003ZZ.

.. c:type:: v4l2_enum_dv_timings

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_enum_dv_timings
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``index``
      - Number of the DV timings, set by the application.
    * - __u32
      - ``pad``
      - Pad number as reported by the media controller API. This field is
	only used when operating on a subdevice node. When operating on a
	video node applications must set this field to zero.
    * - __u32
      - ``reserved``\ [2]
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.
    * - struct :c:type:`v4l2_dv_timings`
      - ``timings``
      - The timings.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ
    ZZ0001ZZ nằm ngoài giới hạn hoặc số ZZ0002ZZ không hợp lệ.

ENODATA
    Các cài đặt trước video kỹ thuật số không được hỗ trợ cho đầu vào hoặc đầu ra này.