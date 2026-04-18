.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-set-buffer-size.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_SET_BUFFER_SIZE:

=====================
DMX_SET_BUFFER_SIZE
===================

Tên
----

DMX_SET_BUFFER_SIZE

Tóm tắt
--------

.. c:macro:: DMX_SET_BUFFER_SIZE

ZZ0000ZZ

Đối số
---------

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Kích thước dài không dấu

Sự miêu tả
-----------

Lệnh gọi ioctl này được sử dụng để đặt kích thước của bộ đệm tròn được sử dụng cho
dữ liệu được lọc. Kích thước mặc định là hai phần có kích thước tối đa, tức là nếu
chức năng này không được gọi là kích thước bộ đệm của byte ZZ0000ZZ sẽ là
đã sử dụng.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.