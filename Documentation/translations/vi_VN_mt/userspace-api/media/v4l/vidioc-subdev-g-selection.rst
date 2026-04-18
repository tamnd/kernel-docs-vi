.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-g-selection.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_G_SELECTION:

*************************************************************
ioctl VIDIOC_SUBDEV_G_SELECTION, VIDIOC_SUBDEV_S_SELECTION
*************************************************************

Tên
====

VIDIOC_SUBDEV_G_SELECTION - VIDIOC_SUBDEV_S_SELECTION - Nhận hoặc đặt các hình chữ nhật lựa chọn trên bảng phụ

Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_G_SELECTION

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_S_SELECTION

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các lựa chọn được sử dụng để định cấu hình xử lý hình ảnh khác nhau
chức năng được thực hiện bởi các nhà phát triển phụ ảnh hưởng đến kích thước hình ảnh. Cái này
hiện bao gồm cắt xén, chia tỷ lệ và thành phần.

Lựa chọn API thay thế
ZZ0000ZZ. Tất cả
chức năng cắt xén API, v.v., được hỗ trợ bởi các lựa chọn API.

Xem ZZ0000ZZ để biết thêm thông tin về cách lựa chọn từng mục tiêu
ảnh hưởng đến đường ống xử lý hình ảnh bên trong thiết bị con.

Nếu nút thiết bị subdev đã được đăng ký ở chế độ chỉ đọc, hãy gọi tới
ZZ0000ZZ chỉ hợp lệ nếu trường ZZ0001ZZ được đặt thành
ZZ0002ZZ, nếu không sẽ trả về lỗi và lỗi sẽ xảy ra.
biến được đặt thành ZZ0003ZZ.

Các loại mục tiêu lựa chọn
--------------------------

Có hai loại mục tiêu lựa chọn: thực tế và giới hạn. thực tế
mục tiêu là các mục tiêu cấu hình phần cứng. Mục tiêu BOUNDS
sẽ trả về một hình chữ nhật chứa tất cả các hình chữ nhật thực tế có thể có.

Khám phá các tính năng được hỗ trợ
------------------------------

Để khám phá mục tiêu nào được hỗ trợ, người dùng có thể thực hiện
ZZ0000ZZ trên chúng. Bất kỳ mục tiêu nào không được hỗ trợ sẽ
trả lại ZZ0001ZZ.

Mục tiêu lựa chọn và cờ được ghi lại trong
ZZ0000ZZ.

.. c:type:: v4l2_subdev_selection

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_subdev_selection
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``which``
      - Active or try selection, from enum
	:ref:`v4l2_subdev_format_whence <v4l2-subdev-format-whence>`.
    * - __u32
      - ``pad``
      - Pad number as reported by the media framework.
    * - __u32
      - ``target``
      - Target selection rectangle. See :ref:`v4l2-selections-common`.
    * - __u32
      - ``flags``
      - Flags. See :ref:`v4l2-selection-flags`.
    * - struct :c:type:`v4l2_rect`
      - ``r``
      - Selection rectangle, in pixels.
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
    Không thể thay đổi hình chữ nhật lựa chọn vì phần đệm được
    hiện đang bận. Ví dụ: điều này có thể xảy ra do một video đang hoạt động
    phát trực tiếp trên pad. Không được thử lại ioctl mà không thực hiện
    hành động khác để khắc phục vấn đề trước tiên. Chỉ được trả lại bởi
    ZZ0000ZZ

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ tham chiếu đến một
    phần đệm không tồn tại, trường ZZ0002ZZ có giá trị không được hỗ trợ hoặc
    mục tiêu lựa chọn không được hỗ trợ trên bảng subdev đã cho.

EPERM
    ZZ0000ZZ ioctl đã được gọi trên chế độ chỉ đọc
    thiết bị con và trường ZZ0001ZZ được đặt thành ZZ0002ZZ.