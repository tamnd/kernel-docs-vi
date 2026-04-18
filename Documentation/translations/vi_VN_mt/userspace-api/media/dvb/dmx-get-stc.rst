.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-get-stc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_GET_STC:

============
DMX_GET_STC
===========

Tên
----

DMX_GET_STC

Tóm tắt
--------

.. c:macro:: DMX_GET_STC

ZZ0000ZZ

Đối số
---------

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới ZZ0000ZZ nơi lưu trữ dữ liệu stc.

Sự miêu tả
-----------

Lệnh gọi ioctl này trả về giá trị hiện tại của bộ đếm thời gian hệ thống
(được điều khiển bởi bộ lọc PES thuộc loại ZZ0000ZZ).
Một số phần cứng hỗ trợ nhiều STC, vì vậy bạn phải chỉ định cái nào bằng cách
thiết lập trường ZZ0001ZZ của stc trước ioctl (phạm vi 0...n).
Kết quả trả về dưới dạng tỉ số với tử số 64 bit
và mẫu số 32 bit, do đó giá trị STC 90kHz thực là
ZZ0002ZZ.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 16

    -  .. row 1

       -  ``EINVAL``

       -  Invalid stc number.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.