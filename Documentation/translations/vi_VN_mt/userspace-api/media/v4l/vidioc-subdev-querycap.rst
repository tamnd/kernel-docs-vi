.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-querycap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_QUERYCAP:

****************************
ioctl VIDIOC_SUBDEV_QUERYCAP
****************************

Tên
====

VIDIOC_SUBDEV_QUERYCAP - Khả năng truy vấn của thiết bị phụ

Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_QUERYCAP

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Tất cả các thiết bị phụ V4L2 đều hỗ trợ ZZ0001ZZ ioctl. Nó được sử dụng để
xác định các thiết bị hạt nhân tương thích với thông số kỹ thuật này và để có được
thông tin về trình điều khiển và khả năng phần cứng. ioctl lấy một con trỏ tới
một cấu trúc ZZ0000ZZ được trình điều khiển điền vào. Khi nào
trình điều khiển không tương thích với thông số kỹ thuật này, ioctl trả về
Mã lỗi ZZ0002ZZ.

.. tabularcolumns:: |p{1.5cm}|p{2.9cm}|p{12.9cm}|

.. c:type:: v4l2_subdev_capability

.. flat-table:: struct v4l2_subdev_capability
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 4 20

    * - __u32
      - ``version``
      - Version number of the driver.

	The version reported is provided by the V4L2 subsystem following the
	kernel numbering scheme. However, it may not always return the same
	version as the kernel if, for example, a stable or
	distribution-modified kernel uses the V4L2 stack from a newer kernel.

	The version number is formatted using the ``KERNEL_VERSION()``
	macro:
    * - :cspan:`2`

	``#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))``

	``__u32 version = KERNEL_VERSION(0, 8, 1);``

	``printf ("Version: %u.%u.%u\\n",``

	``(version >> 16) & 0xFF, (version >> 8) & 0xFF, version & 0xFF);``
    * - __u32
      - ``capabilities``
      - Sub-device capabilities of the opened device, see
	:ref:`subdevice-capabilities`.
    * - __u32
      - ``reserved``\ [14]
      - Reserved for future extensions. Set to 0 by the V4L2 core.

.. tabularcolumns:: |p{6.8cm}|p{2.4cm}|p{8.1cm}|

.. _subdevice-capabilities:

.. cssclass:: longtable

.. flat-table:: Sub-Device Capabilities Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - V4L2_SUBDEV_CAP_RO_SUBDEV
      - 0x00000001
      - The sub-device device node is registered in read-only mode.
	Access to the sub-device ioctls that modify the device state is
	restricted. Refer to each individual subdevice ioctl documentation
	for a description of which restrictions apply to a read-only sub-device.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ENOTTY
    Nút thiết bị không phải là thiết bị phụ V4L2.