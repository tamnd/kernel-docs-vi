.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-ioc-device-info.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: MC

.. _media_ioc_device_info:

****************************
ioctl MEDIA_IOC_DEVICE_INFO
****************************

Tên
====

MEDIA_IOC_DEVICE_INFO - Truy vấn thông tin thiết bị

Tóm tắt
========

.. c:macro:: MEDIA_IOC_DEVICE_INFO

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Tất cả các thiết bị đa phương tiện phải hỗ trợ ZZ0001ZZ ioctl. Đến
truy vấn thông tin thiết bị, các ứng dụng gọi ioctl bằng con trỏ tới
một cấu trúc ZZ0000ZZ. Người lái xe
điền vào cấu trúc và trả về thông tin cho ứng dụng. các
ioctl không bao giờ thất bại.

.. c:type:: media_device_info

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct media_device_info
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    *  -  char
       -  ``driver``\ [16]
       -  Name of the driver implementing the media API as a NUL-terminated
	  ASCII string. The driver version is stored in the
	  ``driver_version`` field.

	  Driver specific applications can use this information to verify
	  the driver identity. It is also useful to work around known bugs,
	  or to identify drivers in error reports.

    *  -  char
       -  ``model``\ [32]
       -  Device model name as a NUL-terminated UTF-8 string. The device
	  version is stored in the ``device_version`` field and is not be
	  appended to the model name.

    *  -  char
       -  ``serial``\ [40]
       -  Serial number as a NUL-terminated ASCII string.

    *  -  char
       -  ``bus_info``\ [32]
       -  Location of the device in the system as a NUL-terminated ASCII
	  string. This includes the bus type name (PCI, USB, ...) and a
	  bus-specific identifier.

    *  -  __u32
       -  ``media_version``
       -  Media API version, formatted with the ``KERNEL_VERSION()`` macro.

    *  -  __u32
       -  ``hw_revision``
       -  Hardware device revision in a driver-specific format.

    *  -  __u32
       -  ``driver_version``
       -  Media device driver version, formatted with the
	  ``KERNEL_VERSION()`` macro. Together with the ``driver`` field
	  this identifies a particular driver.

    *  -  __u32
       -  ``reserved``\ [31]
       -  Reserved for future extensions. Drivers and applications must set
	  this array to zero.

Các trường ZZ0000ZZ và ZZ0001ZZ có thể được sử dụng để phân biệt
giữa nhiều phiên bản của phần cứng giống hệt nhau. nối tiếp
số được ưu tiên khi được cung cấp và có thể được coi là duy nhất.
Nếu số sê-ri là một chuỗi trống, trường ZZ0002ZZ có thể
được sử dụng thay thế. Trường ZZ0003ZZ được đảm bảo là duy nhất, nhưng có thể
khác nhau khi khởi động lại hoặc rút/cắm lại thiết bị.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.