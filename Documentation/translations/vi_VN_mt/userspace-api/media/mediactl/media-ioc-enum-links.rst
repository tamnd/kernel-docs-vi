.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-ioc-enum-links.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: MC

.. _media_ioc_enum_links:

**************************
ioctl MEDIA_IOC_ENUM_LINKS
**************************

Tên
====

MEDIA_IOC_ENUM_LINKS - Liệt kê tất cả các phần đệm và liên kết cho một thực thể nhất định

Tóm tắt
========

.. c:macro:: MEDIA_IOC_ENUM_LINKS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để liệt kê các phần đệm và/hoặc liên kết cho một thực thể nhất định, các ứng dụng sẽ đặt
trường thực thể của cấu trúc ZZ0000ZZ
cấu trúc và khởi tạo cấu trúc
ZZ0001ZZ và cấu trúc
Mảng cấu trúc ZZ0002ZZ được trỏ bởi
các trường ZZ0003ZZ và ZZ0004ZZ. Sau đó họ gọi
MEDIA_IOC_ENUM_LINKS ioctl với một con trỏ tới cấu trúc này.

Nếu trường ZZ0001ZZ không phải là NULL, trình điều khiển sẽ điền vào mảng ZZ0002ZZ
với thông tin về các miếng đệm của thực thể. Mảng phải có đủ
phòng để lưu trữ tất cả các miếng đệm của thực thể. Số lượng miếng đệm có thể được lấy ra
với ZZ0000ZZ.

Nếu trường ZZ0001ZZ không phải là NULL, trình điều khiển sẽ điền vào mảng ZZ0002ZZ
với thông tin về các liên kết ngoài của thực thể. Mảng phải có
đủ chỗ để lưu trữ tất cả các liên kết ra ngoài của thực thể. Số lượng
các liên kết ngoài có thể được truy xuất bằng ZZ0000ZZ.

Chỉ các liên kết chuyển tiếp bắt nguồn từ một trong các bảng nguồn của thực thể mới được
được trả về trong quá trình liệt kê.

.. c:type:: media_links_enum

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct media_links_enum
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    *  -  __u32
       -  ``entity``
       -  Entity id, set by the application.

    *  -  struct :c:type:`media_pad_desc`
       -  \*\ ``pads``
       -  Pointer to a pads array allocated by the application. Ignored if
	  NULL.

    *  -  struct :c:type:`media_link_desc`
       -  \*\ ``links``
       -  Pointer to a links array allocated by the application. Ignored if
	  NULL.

    *  -  __u32
       -  ``reserved[4]``
       -  Reserved for future extensions. Drivers and applications must set
          the array to zero.

.. c:type:: media_pad_desc

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct media_pad_desc
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    *  -  __u32
       -  ``entity``
       -  ID of the entity this pad belongs to.

    *  -  __u16
       -  ``index``
       -  Pad index, starts at 0.

    *  -  __u32
       -  ``flags``
       -  Pad flags, see :ref:`media-pad-flag` for more details.

    *  -  __u32
       -  ``reserved[2]``
       -  Reserved for future extensions. Drivers and applications must set
          the array to zero.


.. c:type:: media_link_desc

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct media_link_desc
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    *  -  struct :c:type:`media_pad_desc`
       -  ``source``
       -  Pad at the origin of this link.

    *  -  struct :c:type:`media_pad_desc`
       -  ``sink``
       -  Pad at the target of this link.

    *  -  __u32
       -  ``flags``
       -  Link flags, see :ref:`media-link-flag` for more details.

    *  -  __u32
       -  ``reserved[2]``
       -  Reserved for future extensions. Drivers and applications must set
          the array to zero.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ
    tham chiếu đến một thực thể không tồn tại.