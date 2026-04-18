.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-enum-mbus-code.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_ENUM_MBUS_CODE:

**********************************
ioctl VIDIOC_SUBDEV_ENUM_MBUS_CODE
**********************************

Tên
====

VIDIOC_SUBDEV_ENUM_MBUS_CODE - Liệt kê các định dạng bus đa phương tiện

Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_ENUM_MBUS_CODE

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Cuộc gọi này được ứng dụng sử dụng để truy cập vào bảng liệt kê
các định dạng bus đa phương tiện cho bảng đã chọn.

Các bảng liệt kê được xác định bởi trình điều khiển và được lập chỉ mục bằng trường ZZ0001ZZ
của cấu trúc ZZ0000ZZ.
Mỗi bảng liệt kê bắt đầu bằng ZZ0002ZZ bằng 0 và
chỉ số không hợp lệ thấp nhất đánh dấu sự kết thúc của phép liệt kê.

Do đó, để liệt kê các định dạng bus đa phương tiện có sẵn trên một thiết bị phụ nhất định,
khởi tạo các trường ZZ0001ZZ và ZZ0002ZZ thành các giá trị mong muốn,
và đặt ZZ0003ZZ thành 0.
Sau đó gọi ZZ0000ZZ ioctl
với một con trỏ tới cấu trúc này.

Cuộc gọi thành công sẽ trở lại với trường ZZ0000ZZ được điền vào
với giá trị mã mbus.
Lặp lại với việc tăng ZZ0001ZZ cho đến khi nhận được ZZ0002ZZ.
ZZ0003ZZ có nghĩa là ZZ0004ZZ không hợp lệ,
hoặc không còn mã nào ở bảng này nữa.

Trình điều khiển không được trả về cùng một giá trị ZZ0000ZZ cho các chỉ số khác nhau
ở cùng một miếng đệm.

Các định dạng bus đa phương tiện có sẵn có thể phụ thuộc vào các định dạng 'thử' hiện tại tại
các miếng đệm khác của thiết bị phụ, cũng như trên các liên kết hoạt động hiện tại.
Xem ZZ0000ZZ để biết thêm
thông tin về các định dạng thử.

.. c:type:: v4l2_subdev_mbus_code_enum

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_subdev_mbus_code_enum
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``pad``
      - Pad number as reported by the media controller API. Filled in by the
        application.
    * - __u32
      - ``index``
      - Index of the mbus code in the enumeration belonging to the given pad.
        Filled in by the application.
    * - __u32
      - ``code``
      - The media bus format code, as defined in
	:ref:`v4l2-mbus-format`. Filled in by the driver.
    * - __u32
      - ``which``
      - Media bus format codes to be enumerated, from enum
	:ref:`v4l2_subdev_format_whence <v4l2-subdev-format-whence>`.
    * - __u32
      - ``flags``
      - See :ref:`v4l2-subdev-mbus-code-flags`
    * - __u32
      - ``stream``
      - Stream identifier.
    * - __u32
      - ``reserved``\ [6]
      - Reserved for future extensions. Applications and drivers must set
	the array to zero.



.. raw:: latex

   \footnotesize

.. tabularcolumns:: |p{8.8cm}|p{2.2cm}|p{6.3cm}|

.. _v4l2-subdev-mbus-code-flags:

.. flat-table:: Subdev Media Bus Code Enumerate Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - V4L2_SUBDEV_MBUS_CODE_CSC_COLORSPACE
      - 0x00000001
      - The driver allows the application to try to change the default colorspace
	encoding. The application can ask to configure the colorspace of the
	subdevice when calling the :ref:`VIDIOC_SUBDEV_S_FMT <VIDIOC_SUBDEV_G_FMT>`
	ioctl with :ref:`V4L2_MBUS_FRAMEFMT_SET_CSC <mbus-framefmt-set-csc>` set.
	See :ref:`v4l2-mbus-format` on how to do this.
    * - V4L2_SUBDEV_MBUS_CODE_CSC_XFER_FUNC
      - 0x00000002
      - The driver allows the application to try to change the default transform function.
	The application can ask to configure the transform function of
	the subdevice when calling the :ref:`VIDIOC_SUBDEV_S_FMT <VIDIOC_SUBDEV_G_FMT>`
	ioctl with :ref:`V4L2_MBUS_FRAMEFMT_SET_CSC <mbus-framefmt-set-csc>` set.
	See :ref:`v4l2-mbus-format` on how to do this.
    * - V4L2_SUBDEV_MBUS_CODE_CSC_YCBCR_ENC
      - 0x00000004
      - The driver allows the application to try to change the default Y'CbCr
	encoding. The application can ask to configure the Y'CbCr encoding of the
	subdevice when calling the :ref:`VIDIOC_SUBDEV_S_FMT <VIDIOC_SUBDEV_G_FMT>`
	ioctl with :ref:`V4L2_MBUS_FRAMEFMT_SET_CSC <mbus-framefmt-set-csc>` set.
	See :ref:`v4l2-mbus-format` on how to do this.
    * - V4L2_SUBDEV_MBUS_CODE_CSC_HSV_ENC
      - 0x00000004
      - The driver allows the application to try to change the default HSV
	encoding. The application can ask to configure the HSV encoding of the
	subdevice when calling the :ref:`VIDIOC_SUBDEV_S_FMT <VIDIOC_SUBDEV_G_FMT>`
	ioctl with :ref:`V4L2_MBUS_FRAMEFMT_SET_CSC <mbus-framefmt-set-csc>` set.
	See :ref:`v4l2-mbus-format` on how to do this.
    * - V4L2_SUBDEV_MBUS_CODE_CSC_QUANTIZATION
      - 0x00000008
      - The driver allows the application to try to change the default
	quantization. The application can ask to configure the quantization of
	the subdevice when calling the :ref:`VIDIOC_SUBDEV_S_FMT <VIDIOC_SUBDEV_G_FMT>`
	ioctl with :ref:`V4L2_MBUS_FRAMEFMT_SET_CSC <mbus-framefmt-set-csc>` set.
	See :ref:`v4l2-mbus-format` on how to do this.

.. raw:: latex

   \normalsize

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ tham chiếu đến một
    phần đệm không tồn tại, trường ZZ0002ZZ có giá trị không được hỗ trợ hoặc
    Trường ZZ0003ZZ nằm ngoài giới hạn.