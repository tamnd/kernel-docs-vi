.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-g-crop.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_G_CROP:

*************************************************
ioctl VIDIOC_SUBDEV_G_CROP, VIDIOC_SUBDEV_S_CROP
************************************************

Tên
====

VIDIOC_SUBDEV_G_CROP - VIDIOC_SUBDEV_S_CROP - Nhận hoặc đặt hình chữ nhật cắt trên bảng điều khiển phụ

Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_G_CROP

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_S_CROP

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

.. note::

    This is an :ref:`obsolete` interface and may be removed in the future. It is
    superseded by :ref:`the selection API <VIDIOC_SUBDEV_G_SELECTION>`. No new
    extensions to the :c:type:`v4l2_subdev_crop` structure will be accepted.

Để truy xuất các ứng dụng hình chữ nhật cắt xén hiện tại, hãy đặt ZZ0001ZZ
trường của cấu trúc ZZ0000ZZ tới
số pad mong muốn được báo cáo bởi phương tiện truyền thông API và trường ZZ0002ZZ
tới ZZ0003ZZ. Sau đó họ gọi
ZZ0004ZZ ioctl với một con trỏ tới cấu trúc này. các
trình điều khiển điền các thành viên của trường ZZ0005ZZ hoặc trả về lỗi ZZ0006ZZ
mã nếu đối số đầu vào không hợp lệ hoặc nếu việc cắt xén không được hỗ trợ
trên pad nhất định.

Để thay đổi các ứng dụng cắt hình chữ nhật hiện tại, hãy đặt cả ZZ0001ZZ
và các trường ZZ0002ZZ cũng như tất cả các thành viên của trường ZZ0003ZZ. Sau đó họ
gọi ZZ0004ZZ ioctl bằng một con trỏ tới đây
cấu trúc. Trình điều khiển xác minh hình chữ nhật cắt được yêu cầu, điều chỉnh nó
dựa trên khả năng phần cứng và cấu hình thiết bị. Khi
trả về cấu trúc ZZ0000ZZ
chứa định dạng hiện tại sẽ được trả về bởi một
Cuộc gọi ZZ0005ZZ.

Các ứng dụng có thể truy vấn khả năng của thiết bị bằng cách đặt ZZ0000ZZ
tới ZZ0001ZZ. Khi được đặt, 'thử' cắt hình chữ nhật không
được trình điều khiển áp dụng cho thiết bị nhưng được đọc sai chính xác là hoạt động
cắt hình chữ nhật và lưu trữ trong phần xử lý tệp của thiết bị phụ. Hai
do đó các ứng dụng truy vấn cùng một thiết bị phụ sẽ không tương tác với
lẫn nhau.

Nếu nút thiết bị subdev đã được đăng ký ở chế độ chỉ đọc, hãy gọi tới
ZZ0000ZZ chỉ hợp lệ nếu trường ZZ0001ZZ được đặt thành
ZZ0002ZZ, nếu không sẽ trả về lỗi và lỗi sẽ xảy ra.
biến được đặt thành ZZ0003ZZ.

Trình điều khiển không được trả về lỗi chỉ vì phần cắt được yêu cầu
hình chữ nhật không phù hợp với khả năng của thiết bị. Thay vào đó họ phải
sửa đổi hình chữ nhật để phù hợp với những gì phần cứng có thể cung cấp. các
định dạng đã sửa đổi phải càng giống với yêu cầu ban đầu càng tốt.

.. c:type:: v4l2_subdev_crop

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_subdev_crop
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``pad``
      - Pad number as reported by the media framework.
    * - __u32
      - ``which``
      - Crop rectangle to get or set, from enum
	:ref:`v4l2_subdev_format_whence <v4l2-subdev-format-whence>`.
    * - struct :c:type:`v4l2_rect`
      - ``rect``
      - Crop rectangle boundaries, in pixels.
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

EBUSY
    Không thể thay đổi hình chữ nhật cắt vì phần đệm hiện đang được
    bận rộn. Ví dụ: điều này có thể xảy ra do luồng video đang hoạt động trên
    cái đệm. Không được thử lại ioctl mà không thực hiện thao tác khác
    hành động để khắc phục vấn đề đầu tiên. Chỉ được trả lại bởi
    ZZ0000ZZ

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ tham chiếu đến một phần đệm không tồn tại,
    trường ZZ0002ZZ có giá trị không được hỗ trợ hoặc việc cắt xén không được hỗ trợ
    trên bảng subdev nhất định.

EPERM
    ZZ0000ZZ ioctl đã được gọi trên một thiết bị con chỉ đọc
    và trường ZZ0001ZZ được đặt thành ZZ0002ZZ.