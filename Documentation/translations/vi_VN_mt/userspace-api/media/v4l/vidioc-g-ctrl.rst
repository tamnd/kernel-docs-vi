.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-ctrl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_CTRL:

**********************************
ioctl VIDIOC_G_CTRL, VIDIOC_S_CTRL
**********************************

Tên
====

VIDIOC_G_CTRL - VIDIOC_S_CTRL - Nhận hoặc đặt giá trị của điều khiển

Tóm tắt
========

.. c:macro:: VIDIOC_G_CTRL

ZZ0000ZZ

.. c:macro:: VIDIOC_S_CTRL

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để nhận giá trị hiện tại của ứng dụng điều khiển, hãy khởi tạo ZZ0004ZZ
trường của cấu trúc ZZ0000ZZ và gọi
ZZ0001ZZ ioctl với một con trỏ tới cấu trúc này. Để thay đổi
giá trị của ứng dụng điều khiển khởi tạo ZZ0005ZZ và ZZ0006ZZ
các trường của cấu trúc ZZ0002ZZ và gọi
ZZ0003ZZ ioctl.

Khi ZZ0001ZZ trình điều khiển không hợp lệ sẽ trả về mã lỗi ZZ0002ZZ. Khi
ZZ0003ZZ nằm ngoài giới hạn, người lái xe có thể chọn lấy giá trị gần nhất
giá trị hoặc trả về mã lỗi ZZ0004ZZ, bất cứ điều gì có vẻ phù hợp hơn.
Tuy nhiên, ZZ0000ZZ là ioctl chỉ ghi, nó không trả về giá trị
giá trị thực tế mới. Nếu ZZ0005ZZ không phù hợp để điều khiển
(ví dụ: nếu nó đề cập đến chỉ mục menu không được hỗ trợ của điều khiển menu), thì
Mã lỗi EINVAL cũng được trả về.

Các ioctls này chỉ hoạt động với các điều khiển của người dùng. Đối với các lớp điều khiển khác,
ZZ0000ZZ,
ZZ0001ZZ hoặc
Phải sử dụng ZZ0002ZZ.

.. c:type:: v4l2_control

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_control
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``id``
      - Identifies the control, set by the application.
    * - __s32
      - ``value``
      - New value or current value.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0002ZZ không hợp lệ
    hoặc ZZ0003ZZ không phù hợp với điều khiển nhất định (tức là nếu
    mục menu được chọn không được trình điều khiển hỗ trợ theo
    đến ZZ0001ZZ).

ERANGE
    Cấu trúc ZZ0000ZZ ZZ0001ZZ đã hết
    giới hạn.

EBUSY
    Việc điều khiển tạm thời không thể thay đổi được, có thể do nguyên nhân khác
    các ứng dụng đã chiếm quyền kiểm soát chức năng của thiết bị điều khiển này
    thuộc về.

EACCES
    Cố gắng đặt điều khiển chỉ đọc hoặc lấy điều khiển chỉ ghi.

Hoặc nếu có nỗ lực thiết lập một điều khiển không hoạt động và trình điều khiển
    không có khả năng lưu vào bộ đệm giá trị mới cho đến khi điều khiển được kích hoạt trở lại.