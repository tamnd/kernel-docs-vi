.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-ioc-g-topology.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: MC

.. _media_ioc_g_topology:

**************************
ioctl MEDIA_IOC_G_TOPOLOGY
**************************

Tên
====

MEDIA_IOC_G_TOPOLOGY - Liệt kê các thuộc tính cấu trúc liên kết đồ thị và phần tử đồ thị

Tóm tắt
========

.. c:macro:: MEDIA_IOC_G_TOPOLOGY

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Cách sử dụng điển hình của ioctl này là gọi nó hai lần. Trong cuộc gọi đầu tiên,
cấu trúc được xác định tại struct
ZZ0000ZZ phải bằng 0. Tại
return, nếu không có lỗi xảy ra thì ioctl này sẽ trả về
ZZ0001ZZ và tổng số thực thể, giao diện, miếng đệm
và liên kết.

Trước lệnh gọi thứ hai, không gian người dùng sẽ phân bổ các mảng để lưu trữ
các phần tử đồ thị mong muốn, đặt con trỏ tới chúng ở vị trí
ptr_entities, ptr_interfaces, ptr_links và/hoặc ptr_pads, giữ nguyên
các giá trị khác không bị ảnh hưởng.

Nếu ZZ0000ZZ vẫn giữ nguyên, ioctl sẽ điền vào
mảng mong muốn với các phần tử biểu đồ phương tiện.

.. tabularcolumns:: |p{1.6cm}|p{3.4cm}|p{12.3cm}|

.. c:type:: media_v2_topology

.. flat-table:: struct media_v2_topology
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 2 8

    *  -  __u64
       -  ``topology_version``
       -  Version of the media graph topology. When the graph is created,
	  this field starts with zero. Every time a graph element is added
	  or removed, this field is incremented.

    *  -  __u32
       -  ``num_entities``
       -  Number of entities in the graph

    *  -  __u32
       -  ``reserved1``
       -  Applications and drivers shall set this to 0.

    *  -  __u64
       -  ``ptr_entities``
       -  A pointer to a memory area where the entities array will be
	  stored, converted to a 64-bits integer. It can be zero. if zero,
	  the ioctl won't store the entities. It will just update
	  ``num_entities``

    *  -  __u32
       -  ``num_interfaces``
       -  Number of interfaces in the graph

    *  -  __u32
       -  ``reserved2``
       -  Applications and drivers shall set this to 0.

    *  -  __u64
       -  ``ptr_interfaces``
       -  A pointer to a memory area where the interfaces array will be
	  stored, converted to a 64-bits integer. It can be zero. if zero,
	  the ioctl won't store the interfaces. It will just update
	  ``num_interfaces``

    *  -  __u32
       -  ``num_pads``
       -  Total number of pads in the graph

    *  -  __u32
       -  ``reserved3``
       -  Applications and drivers shall set this to 0.

    *  -  __u64
       -  ``ptr_pads``
       -  A pointer to a memory area where the pads array will be stored,
	  converted to a 64-bits integer. It can be zero. if zero, the ioctl
	  won't store the pads. It will just update ``num_pads``

    *  -  __u32
       -  ``num_links``
       -  Total number of data and interface links in the graph

    *  -  __u32
       -  ``reserved4``
       -  Applications and drivers shall set this to 0.

    *  -  __u64
       -  ``ptr_links``
       -  A pointer to a memory area where the links array will be stored,
	  converted to a 64-bits integer. It can be zero. if zero, the ioctl
	  won't store the links. It will just update ``num_links``

.. tabularcolumns:: |p{1.6cm}|p{3.2cm}|p{12.5cm}|

.. c:type:: media_v2_entity

.. flat-table:: struct media_v2_entity
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 2 8

    *  -  __u32
       -  ``id``
       -  Unique ID for the entity. Do not expect that the ID will
	  always be the same for each instance of the device. In other words,
	  do not hardcode entity IDs in an application.

    *  -  char
       -  ``name``\ [64]
       -  Entity name as an UTF-8 NULL-terminated string. This name must be unique
          within the media topology.

    *  -  __u32
       -  ``function``
       -  Entity main function, see :ref:`media-entity-functions` for details.

    *  -  __u32
       -  ``flags``
       -  Entity flags, see :ref:`media-entity-flag` for details.
	  Only valid if ``MEDIA_V2_ENTITY_HAS_FLAGS(media_version)``
	  returns true. The ``media_version`` is defined in struct
	  :c:type:`media_device_info` and can be retrieved using
	  :ref:`MEDIA_IOC_DEVICE_INFO`.

    *  -  __u32
       -  ``reserved``\ [5]
       -  Reserved for future extensions. Drivers and applications must set
	  this array to zero.

.. tabularcolumns:: |p{1.6cm}|p{3.2cm}|p{12.5cm}|

.. c:type:: media_v2_interface

.. flat-table:: struct media_v2_interface
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 2 8

    *  -  __u32
       -  ``id``
       -  Unique ID for the interface. Do not expect that the ID will
	  always be the same for each instance of the device. In other words,
	  do not hardcode interface IDs in an application.

    *  -  __u32
       -  ``intf_type``
       -  Interface type, see :ref:`media-intf-type` for details.

    *  -  __u32
       -  ``flags``
       -  Interface flags. Currently unused.

    *  -  __u32
       -  ``reserved``\ [9]
       -  Reserved for future extensions. Drivers and applications must set
	  this array to zero.

    *  -  struct media_v2_intf_devnode
       -  ``devnode``
       -  Used only for device node interfaces. See
	  :c:type:`media_v2_intf_devnode` for details.

.. tabularcolumns:: |p{1.6cm}|p{3.2cm}|p{12.5cm}|

.. c:type:: media_v2_intf_devnode

.. flat-table:: struct media_v2_intf_devnode
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 2 8

    *  -  __u32
       -  ``major``
       -  Device node major number.

    *  -  __u32
       -  ``minor``
       -  Device node minor number.

.. tabularcolumns:: |p{1.6cm}|p{3.2cm}|p{12.5cm}|

.. c:type:: media_v2_pad

.. flat-table:: struct media_v2_pad
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 2 8

    *  -  __u32
       -  ``id``
       -  Unique ID for the pad. Do not expect that the ID will
	  always be the same for each instance of the device. In other words,
	  do not hardcode pad IDs in an application.

    *  -  __u32
       -  ``entity_id``
       -  Unique ID for the entity where this pad belongs.

    *  -  __u32
       -  ``flags``
       -  Pad flags, see :ref:`media-pad-flag` for more details.

    *  -  __u32
       -  ``index``
       -  Pad index, starts at 0. Only valid if ``MEDIA_V2_PAD_HAS_INDEX(media_version)``
	  returns true. The ``media_version`` is defined in struct
	  :c:type:`media_device_info` and can be retrieved using
	  :ref:`MEDIA_IOC_DEVICE_INFO`.

    *  -  __u32
       -  ``reserved``\ [4]
       -  Reserved for future extensions. Drivers and applications must set
	  this array to zero.

.. tabularcolumns:: |p{1.6cm}|p{3.2cm}|p{12.5cm}|

.. c:type:: media_v2_link

.. flat-table:: struct media_v2_link
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 2 8

    *  -  __u32
       -  ``id``
       -  Unique ID for the link. Do not expect that the ID will
	  always be the same for each instance of the device. In other words,
	  do not hardcode link IDs in an application.

    *  -  __u32
       -  ``source_id``
       -  On pad to pad links: unique ID for the source pad.

	  On interface to entity links: unique ID for the interface.

    *  -  __u32
       -  ``sink_id``
       -  On pad to pad links: unique ID for the sink pad.

	  On interface to entity links: unique ID for the entity.

    *  -  __u32
       -  ``flags``
       -  Link flags, see :ref:`media-link-flag` for more details.

    *  -  __u32
       -  ``reserved``\ [6]
       -  Reserved for future extensions. Drivers and applications must set
	  this array to zero.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ENOSPC
    Điều này được trả về khi một hoặc nhiều trong số num_entities,
    num_interfaces, num_links hoặc num_pads khác 0 và là
    nhỏ hơn số phần tử thực tế bên trong biểu đồ. Cái này
    có thể xảy ra nếu ZZ0000ZZ thay đổi khi so sánh với
    lần trước ioctl này đã được gọi. Không gian người dùng thường sẽ giải phóng
    khu vực dành cho con trỏ, bỏ phần tử cấu trúc về 0 và gọi đây là ioctl
    một lần nữa.