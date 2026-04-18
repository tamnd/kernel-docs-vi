.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-jpegcomp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_JPEGCOMP:

*******************************************
ioctl VIDIOC_G_JPEGCOMP, VIDIOC_S_JPEGCOMP
******************************************

Tên
====

VIDIOC_G_JPEGCOMP - VIDIOC_S_JPEGCOMP

Tóm tắt
========

.. c:macro:: VIDIOC_G_JPEGCOMP

ZZ0000ZZ

.. c:macro:: VIDIOC_S_JPEGCOMP

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Những ioctl này là ZZ0001ZZ. Trình điều khiển và ứng dụng mới nên sử dụng
ZZ0000ZZ cho chất lượng hình ảnh và JPEG
điều khiển đánh dấu.

[làm gì]

Ronald Bultje giải thích:

APP là một số thông tin dành riêng cho ứng dụng. Ứng dụng có thể thiết lập nó
chính nó và nó sẽ được lưu trữ trong các trường được mã hóa JPEG (ví dụ: xen kẽ
thông tin trong AVI hoặc hơn). COM cũng vậy, nhưng đó là nhận xét,
như 'được mã hóa bởi tôi' hoặc tương tự.

jpeg_markers mô tả các bảng huffman, bảng lượng tử hóa
và thông tin về khoảng thời gian khởi động lại (tất cả nội dung dành riêng cho JPEG) phải là
được lưu trữ trong các trường được mã hóa JPEG. Những điều này xác định trường JPEG như thế nào
được mã hóa. Nếu bạn bỏ qua chúng, các ứng dụng sẽ cho rằng bạn đã sử dụng tiêu chuẩn
mã hóa. Bạn thường muốn thêm chúng.

.. tabularcolumns:: |p{1.2cm}|p{3.0cm}|p{13.1cm}|

.. c:type:: v4l2_jpegcompression

.. flat-table:: struct v4l2_jpegcompression
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - int
      - ``quality``
      - Deprecated. If
	:ref:`V4L2_CID_JPEG_COMPRESSION_QUALITY <jpeg-quality-control>`
	control is exposed by a driver applications should use it instead
	and ignore this field.
    * - int
      - ``APPn``
      -
    * - int
      - ``APP_len``
      -
    * - char
      - ``APP_data``\ [60]
      -
    * - int
      - ``COM_len``
      -
    * - char
      - ``COM_data``\ [60]
      -
    * - __u32
      - ``jpeg_markers``
      - See :ref:`jpeg-markers`. Deprecated. If
	:ref:`V4L2_CID_JPEG_ACTIVE_MARKER <jpeg-active-marker-control>`
	control is exposed by a driver applications should use it instead
	and ignore this field.

.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _jpeg-markers:

.. flat-table:: JPEG Markers Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_JPEG_MARKER_DHT``
      - (1<<3)
      - Define Huffman Tables
    * - ``V4L2_JPEG_MARKER_DQT``
      - (1<<4)
      - Define Quantization Tables
    * - ``V4L2_JPEG_MARKER_DRI``
      - (1<<5)
      - Define Restart Interval
    * - ``V4L2_JPEG_MARKER_COM``
      - (1<<6)
      - Comment segment
    * - ``V4L2_JPEG_MARKER_APP``
      - (1<<7)
      - App segment, driver will always use APP0

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.