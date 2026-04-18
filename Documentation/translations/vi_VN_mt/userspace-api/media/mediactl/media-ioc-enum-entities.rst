.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-ioc-enum-entities.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: MC

.. _media_ioc_enum_entities:

*****************************
ioctl MEDIA_IOC_ENUM_ENTITIES
*****************************

Tên
====

MEDIA_IOC_ENUM_ENTITIES - Liệt kê các thực thể và thuộc tính của chúng

Tóm tắt
========

.. c:macro:: MEDIA_IOC_ENUM_ENTITIES

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn các thuộc tính của một thực thể, các ứng dụng sẽ đặt trường id của một thực thể
cấu trúc ZZ0000ZZ và
gọi MEDIA_IOC_ENUM_ENTITIES ioctl bằng một con trỏ tới đây
cấu trúc. Trình điều khiển lấp đầy phần còn lại của cấu trúc hoặc trả về một
Mã lỗi EINVAL khi id không hợp lệ.

.. _media-ent-id-flag-next:

Các thực thể có thể được liệt kê bằng cách hoặc thêm id với
Cờ ZZ0000ZZ. Lái xe sẽ trả lại thông tin
về thực thể có id nhỏ nhất lớn hơn id được yêu cầu
một ('thực thể tiếp theo') hoặc mã lỗi ZZ0001ZZ nếu không có.

ID thực thể có thể không liền kề. Các ứng dụng ZZ0000ZZ phải thử
liệt kê các thực thể bằng cách gọi MEDIA_IOC_ENUM_ENTITIES với mức tăng dần
id cho đến khi họ gặp lỗi.

.. c:type:: media_entity_desc

.. tabularcolumns:: |p{1.5cm}|p{1.7cm}|p{1.6cm}|p{1.5cm}|p{10.6cm}|

.. flat-table:: struct media_entity_desc
    :header-rows:  0
    :stub-columns: 0
    :widths: 2 2 1 8

    *  -  __u32
       -  ``id``
       -
       -  Entity ID, set by the application. When the ID is or'ed with
	  ``MEDIA_ENT_ID_FLAG_NEXT``, the driver clears the flag and returns
	  the first entity with a larger ID. Do not expect that the ID will
	  always be the same for each instance of the device. In other words,
	  do not hardcode entity IDs in an application.

    *  -  char
       -  ``name``\ [32]
       -
       -  Entity name as an UTF-8 NULL-terminated string. This name must be unique
          within the media topology.

    *  -  __u32
       -  ``type``
       -
       -  Entity type, see :ref:`media-entity-functions` for details.

    *  -  __u32
       -  ``revision``
       -
       -  Entity revision. Always zero (obsolete)

    *  -  __u32
       -  ``flags``
       -
       -  Entity flags, see :ref:`media-entity-flag` for details.

    *  -  __u32
       -  ``group_id``
       -
       -  Entity group ID. Always zero (obsolete)

    *  -  __u16
       -  ``pads``
       -
       -  Number of pads

    *  -  __u16
       -  ``links``
       -
       -  Total number of outbound links. Inbound links are not counted in
	  this field.

    *  -  __u32
       -  ``reserved[4]``
       -
       -  Reserved for future extensions. Drivers and applications must set
          the array to zero.

    *  -  union {
       -  (anonymous)

    *  -  struct
       -  ``dev``
       -
       -  Valid for (sub-)devices that create a single device node.

    *  -
       -  __u32
       -  ``major``
       -  Device node major number.

    *  -
       -  __u32
       -  ``minor``
       -  Device node minor number.

    *  -  __u8
       -  ``raw``\ [184]
       -
       -
    *  - }
       -

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0001ZZ
    tham chiếu đến một thực thể không tồn tại.