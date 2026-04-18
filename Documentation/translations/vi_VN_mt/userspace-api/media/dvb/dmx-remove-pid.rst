.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-remove-pid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_REMOVE_PID:

================
DMX_REMOVE_PID
==============

Tên
----

DMX_REMOVE_PID

Tóm tắt
--------

.. c:macro:: DMX_REMOVE_PID

ZZ0000ZZ

Đối số
---------

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    PID của bộ lọc PES cần được loại bỏ.

Sự miêu tả
-----------

Lệnh gọi ioctl này cho phép xóa PID khi nhiều PID được đặt trên một
bộ lọc luồng vận chuyển, e. g. một bộ lọc được thiết lập trước đó với đầu ra
bằng ZZ0000ZZ, được tạo thông qua một trong hai
ZZ0001ZZ hoặc ZZ0002ZZ.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.