.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-fmt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_FMT:

*************************************************
ioctl VIDIOC_G_FMT, VIDIOC_S_FMT, VIDIOC_TRY_FMT
************************************************

Tên
====

VIDIOC_G_FMT - VIDIOC_S_FMT - VIDIOC_TRY_FMT - Nhận hoặc đặt định dạng dữ liệu, thử định dạng

Tóm tắt
========

.. c:macro:: VIDIOC_G_FMT

ZZ0000ZZ

.. c:macro:: VIDIOC_S_FMT

ZZ0000ZZ

.. c:macro:: VIDIOC_TRY_FMT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ioctls này được sử dụng để đàm phán định dạng dữ liệu (thường là hình ảnh
format) được trao đổi giữa trình điều khiển và ứng dụng.

Để truy vấn các ứng dụng tham số hiện tại, hãy đặt trường ZZ0004ZZ của
struct ZZ0000ZZ vào bộ đệm (luồng) tương ứng
loại. Ví dụ: thiết bị quay video sử dụng
ZZ0005ZZ hoặc
ZZ0006ZZ. Khi ứng dụng gọi
ZZ0001ZZ ioctl với một con trỏ tới cấu trúc này mà trình điều khiển điền vào
thành viên tương ứng của liên minh ZZ0007ZZ. Trường hợp quay video
các thiết bị là cấu trúc
ZZ0002ZZ ZZ0008ZZ hoặc cấu trúc
ZZ0003ZZ ZZ0009ZZ
thành viên. Khi loại bộ đệm được yêu cầu không được hỗ trợ, trình điều khiển sẽ quay lại
mã lỗi ZZ0010ZZ.

Để thay đổi các tham số định dạng hiện tại, các ứng dụng hãy khởi tạo
Trường ZZ0008ZZ và tất cả các trường của thành viên liên minh ZZ0009ZZ tương ứng.
Để biết chi tiết, hãy xem tài liệu về các loại thiết bị khác nhau trong
ZZ0000ZZ. Thực hành tốt là truy vấn các tham số hiện tại
đầu tiên và chỉ sửa đổi những tham số không phù hợp với
ứng dụng. Khi ứng dụng gọi ioctl ZZ0001ZZ với
một con trỏ tới cấu trúc struct ZZ0002ZZ của trình điều khiển
kiểm tra và điều chỉnh các thông số theo khả năng của phần cứng. Trình điều khiển
không nên trả lại mã lỗi trừ khi trường ZZ0010ZZ không hợp lệ,
đây là một cơ chế để tìm hiểu khả năng của thiết bị và tiếp cận
các thông số có thể chấp nhận được cho cả ứng dụng và trình điều khiển. Về thành công
trình điều khiển có thể lập trình phần cứng, phân bổ tài nguyên và nói chung
chuẩn bị trao đổi dữ liệu. Cuối cùng ZZ0003ZZ ioctl cũng trở lại
các tham số định dạng hiện tại như ZZ0004ZZ. Rất đơn giản,
các thiết bị không linh hoạt thậm chí có thể bỏ qua tất cả đầu vào và luôn trả về
các thông số mặc định. Tuy nhiên, tất cả các thiết bị V4L2 trao đổi dữ liệu với
ứng dụng phải triển khai ZZ0005ZZ và ZZ0006ZZ
ioctl. Khi loại bộ đệm được yêu cầu không được hỗ trợ, trình điều khiển sẽ trả về một
Mã lỗi EINVAL khi thử ZZ0007ZZ. Khi I/O đã có sẵn
tiến trình hoặc tài nguyên không có sẵn vì lý do khác trình điều khiển
trả về mã lỗi ZZ0011ZZ.

ZZ0000ZZ ioctl tương đương với ZZ0001ZZ với một
ngoại lệ: nó không thay đổi trạng thái trình điều khiển. Nó cũng có thể được gọi bất cứ lúc nào
thời gian, không bao giờ trả lại ZZ0002ZZ. Chức năng này được cung cấp để đàm phán
tham số, để tìm hiểu về các giới hạn phần cứng mà không cần tắt I/O
hoặc có thể tốn thời gian chuẩn bị phần cứng. Dù mạnh mẽ
trình điều khiển được đề xuất không bắt buộc phải triển khai ioctl này.

Định dạng được ZZ0000ZZ trả về phải giống với định dạng
ZZ0001ZZ trả về cùng một đầu vào hoặc đầu ra.

.. c:type:: v4l2_format

.. tabularcolumns::  |p{7.4cm}|p{4.4cm}|p{5.5cm}|

.. flat-table:: struct v4l2_format
    :header-rows:  0
    :stub-columns: 0

    * - __u32
      - ``type``
      - Type of the data stream, see :c:type:`v4l2_buf_type`.
    * - union {
      - ``fmt``
    * - struct :c:type:`v4l2_pix_format`
      - ``pix``
      - Definition of an image format, see :ref:`pixfmt`, used by video
	capture and output devices.
    * - struct :c:type:`v4l2_pix_format_mplane`
      - ``pix_mp``
      - Definition of an image format, see :ref:`pixfmt`, used by video
	capture and output devices that support the
	:ref:`multi-planar version of the API <planar-apis>`.
    * - struct :c:type:`v4l2_window`
      - ``win``
      - Definition of an overlaid image, see :ref:`overlay`, used by
	video overlay devices.
    * - struct :c:type:`v4l2_vbi_format`
      - ``vbi``
      - Raw VBI capture or output parameters. This is discussed in more
	detail in :ref:`raw-vbi`. Used by raw VBI capture and output
	devices.
    * - struct :c:type:`v4l2_sliced_vbi_format`
      - ``sliced``
      - Sliced VBI capture or output parameters. See :ref:`sliced` for
	details. Used by sliced VBI capture and output devices.
    * - struct :c:type:`v4l2_sdr_format`
      - ``sdr``
      - Definition of a data format, see :ref:`pixfmt`, used by SDR
	capture and output devices.
    * - struct :c:type:`v4l2_meta_format`
      - ``meta``
      - Definition of a metadata format, see :ref:`meta-formats`, used by
	metadata capture devices.
    * - __u8
      - ``raw_data``\ [200]
      - Place holder for future extensions.
    * - }
      -

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Trường cấu trúc ZZ0000ZZ ZZ0001ZZ là
    không hợp lệ hoặc loại bộ đệm được yêu cầu không được hỗ trợ.

EBUSY
    Máy bận và không thể thay đổi định dạng. Đây có thể là
    bởi vì hoặc thiết bị đang phát trực tuyến hoặc bộ đệm được phân bổ hoặc
    xếp hàng chờ tài xế. Chỉ liên quan đến ZZ0000ZZ.