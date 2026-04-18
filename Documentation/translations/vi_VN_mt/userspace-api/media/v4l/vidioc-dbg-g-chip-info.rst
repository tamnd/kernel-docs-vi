.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-dbg-g-chip-info.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_DBG_G_CHIP_INFO:

****************************
ioctl VIDIOC_DBG_G_CHIP_INFO
****************************

Tên
====

VIDIOC_DBG_G_CHIP_INFO - Nhận dạng chip trên card TV

Tóm tắt
========

.. c:macro:: VIDIOC_DBG_G_CHIP_INFO

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

Với mục đích gỡ lỗi trình điều khiển, ioctl này cho phép các ứng dụng thử nghiệm
truy vấn trình điều khiển về các con chip có trên card TV. thường xuyên
các ứng dụng không được sử dụng nó. Khi bạn tìm thấy một lỗi cụ thể của chip, vui lòng
liên hệ với danh sách gửi thư linux-media
(ZZ0000ZZ)
vì vậy nó có thể được sửa chữa.

Ngoài ra, nhân Linux phải được biên dịch bằng
Tùy chọn ZZ0000ZZ để kích hoạt ioctl này.

Để truy vấn các ứng dụng trình điều khiển phải khởi tạo ZZ0002ZZ và
Các trường ZZ0003ZZ hoặc ZZ0004ZZ của cấu trúc
ZZ0000ZZ và gọi
ZZ0001ZZ với một con trỏ tới cấu trúc này. Về thành công
trình điều khiển lưu trữ thông tin về chip đã chọn trong ZZ0005ZZ
và các trường ZZ0006ZZ.

Khi ZZ0001ZZ là ZZ0002ZZ, ZZ0003ZZ
chọn 'chip' cầu nối thứ n trên card TV. Bạn có thể liệt kê tất cả
chip bằng cách bắt đầu từ 0 và tăng dần ZZ0004ZZ lên một cho đến khi
ZZ0000ZZ không thành công với mã lỗi ZZ0005ZZ. số
zero luôn chọn chính chip cầu, e. g. con chip được kết nối với
xe buýt PCI hoặc USB. Các số khác 0 xác định các phần cụ thể của
chip cầu chẳng hạn như khối thanh ghi AC97.

Khi ZZ0000ZZ là ZZ0001ZZ, ZZ0002ZZ
chọn thiết bị phụ thứ n. Điều này cho phép bạn liệt kê tất cả
các thiết bị phụ.

Nếu thành công, trường ZZ0000ZZ sẽ chứa tên chip và
Trường ZZ0001ZZ sẽ chứa ZZ0002ZZ nếu trình điều khiển
hỗ trợ đọc các thanh ghi từ thiết bị hoặc ZZ0003ZZ
nếu trình điều khiển hỗ trợ ghi các thanh ghi vào thiết bị.

Chúng tôi đã đề xuất tiện ích v4l2-dbg thay vì gọi trực tiếp ioctl này. Nó
có sẵn từ kho lưu trữ LinuxTV v4l-dvb; xem
ZZ0000ZZ để truy cập
hướng dẫn.

.. tabularcolumns:: |p{3.5cm}|p{3.5cm}|p{3.5cm}|p{6.6cm}|

.. _name-v4l2-dbg-match:

.. flat-table:: struct v4l2_dbg_match
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``type``
      - See :ref:`name-chip-match-types` for a list of possible types.
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


.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. c:type:: v4l2_dbg_chip_info

.. flat-table:: struct v4l2_dbg_chip_info
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - struct v4l2_dbg_match
      - ``match``
      - How to match the chip, see :ref:`name-v4l2-dbg-match`.
    * - char
      - ``name[32]``
      - The name of the chip.
    * - __u32
      - ``flags``
      - Set by the driver. If ``V4L2_CHIP_FL_READABLE`` is set, then the
	driver supports reading registers from the device. If
	``V4L2_CHIP_FL_WRITABLE`` is set, then it supports writing
	registers.
    * - __u32
      - ``reserved[8]``
      - Reserved fields, both application and driver must set these to 0.


.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. _name-chip-match-types:

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
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    ZZ0000ZZ không hợp lệ hoặc không có thiết bị nào có thể khớp.