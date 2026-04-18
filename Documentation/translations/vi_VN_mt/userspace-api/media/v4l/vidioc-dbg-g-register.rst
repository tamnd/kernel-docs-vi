.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-dbg-g-register.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_DBG_G_REGISTER:

****************************************************
ioctl VIDIOC_DBG_G_REGISTER, VIDIOC_DBG_S_REGISTER
**************************************************

Tên
====

VIDIOC_DBG_G_REGISTER - VIDIOC_DBG_S_REGISTER - Đọc hoặc ghi các thanh ghi phần cứng

Tóm tắt
========

.. c:macro:: VIDIOC_DBG_G_REGISTER

ZZ0000ZZ

.. c:macro:: VIDIOC_DBG_S_REGISTER

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

    This is an :ref:`experimental` interface and may
    change in the future.

Với mục đích gỡ lỗi trình điều khiển, các ioctls này cho phép các ứng dụng thử nghiệm
truy cập trực tiếp vào các thanh ghi phần cứng. Các ứng dụng thông thường không được sử dụng
họ.

Vì việc ghi hoặc thậm chí đọc các thanh ghi có thể gây nguy hiểm cho hệ thống
bảo mật, tính ổn định và làm hỏng phần cứng, cả hai ioctls đều yêu cầu
đặc quyền siêu người dùng. Ngoài ra nhân Linux phải được biên dịch
với tùy chọn ZZ0000ZZ để kích hoạt các ioctls này.

Để ghi một ứng dụng đăng ký phải khởi tạo tất cả các trường của một cấu trúc
ZZ0000ZZ ngoại trừ ZZ0001ZZ và
gọi ZZ0002ZZ bằng một con trỏ tới cấu trúc này. các
Các trường ZZ0003ZZ và ZZ0004ZZ hoặc ZZ0005ZZ chọn một chip
trên thẻ TV, trường ZZ0006ZZ chỉ định số thanh ghi và
Trường ZZ0007ZZ giá trị được ghi vào thanh ghi.

Để đọc ứng dụng đăng ký phải khởi tạo ZZ0000ZZ,
Các trường ZZ0001ZZ hoặc ZZ0002ZZ và ZZ0003ZZ và gọi
ZZ0004ZZ với một con trỏ tới cấu trúc này. Về thành công
trình điều khiển lưu trữ giá trị thanh ghi trong trường ZZ0005ZZ và kích thước
(tính bằng byte) của giá trị trong ZZ0006ZZ.

Khi ZZ0001ZZ là ZZ0002ZZ, ZZ0003ZZ
chọn chip không phải thiết bị phụ thứ n trên thẻ TV. Số 0
luôn chọn chip chủ, e. g. con chip được kết nối với PCI hoặc USB
xe buýt. Bạn có thể tìm ra những con chip nào hiện diện với
ZZ0000ZZ ioctl.

Khi ZZ0000ZZ là ZZ0001ZZ, ZZ0002ZZ
chọn thiết bị phụ thứ n.

Các ioctls này là tùy chọn, không phải tất cả trình điều khiển đều có thể hỗ trợ chúng. Tuy nhiên
khi một trình điều khiển hỗ trợ các ioctls này thì nó cũng phải hỗ trợ
ZZ0000ZZ. Ngược lại
nó có thể hỗ trợ ZZ0001ZZ nhưng không hỗ trợ các ioctls này.

ZZ0000ZZ và ZZ0001ZZ đã được giới thiệu
trong Linux 2.6.21, nhưng API của họ đã được thay đổi thành phiên bản được mô tả ở đây trong
hạt nhân 2.6.29.

Chúng tôi đã đề xuất tiện ích v4l2-dbg thay vì gọi trực tiếp các ioctls này.
Nó có sẵn từ kho lưu trữ LinuxTV v4l-dvb; xem
ZZ0000ZZ để truy cập
hướng dẫn.

.. tabularcolumns:: |p{3.5cm}|p{3.5cm}|p{3.5cm}|p{6.6cm}|

.. c:type:: v4l2_dbg_match

.. flat-table:: struct v4l2_dbg_match
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``type``
      - See :ref:`chip-match-types` for a list of possible types.
    * - union {
      - (anonymous)
    * - __u32
      - ``addr``
      - Match a chip by this number, interpreted according to the ``type``
	field.
    * - char
      - ``name[32]``
      - Match a chip by this name, interpreted according to the ``type``
	field. Currently unused.
    * - }
      -


.. c:type:: v4l2_dbg_register

.. flat-table:: struct v4l2_dbg_register
    :header-rows:  0
    :stub-columns: 0

    * - struct v4l2_dbg_match
      - ``match``
      - How to match the chip, see :c:type:`v4l2_dbg_match`.
    * - __u32
      - ``size``
      - The register size in bytes.
    * - __u64
      - ``reg``
      - A register number.
    * - __u64
      - ``val``
      - The value read from, or to be written into the register.


.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _chip-match-types:

.. flat-table:: Chip Match Types
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_CHIP_MATCH_BRIDGE``
      - 0
      - Match the nth chip on the card, zero for the bridge chip. Does not
	match sub-devices.
    * - ``V4L2_CHIP_MATCH_SUBDEV``
      - 4
      - Match the nth sub-device.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EPERM
    Không đủ quyền. Cần có quyền root để thực thi
    những ioctl này.