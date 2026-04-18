.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-set-pes-filter.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_SET_PES_FILTER:

====================
DMX_SET_PES_FILTER
==================

Tên
----

DMX_SET_PES_FILTER

Tóm tắt
--------

.. c:macro:: DMX_SET_PES_FILTER

ZZ0000ZZ

Đối số
---------

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới cấu trúc chứa tham số bộ lọc.

Sự miêu tả
-----------

Lệnh gọi ioctl này thiết lập bộ lọc PES theo các tham số
được cung cấp. Bộ lọc PES có nghĩa là bộ lọc chỉ dựa trên
mã định danh gói (PID), tức là không có tiêu đề PES hoặc lọc tải trọng
khả năng được hỗ trợ.

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

       -  ``EBUSY``

       -  This error code indicates that there are conflicting requests.
	  There are active filters filtering data from another input source.
	  Make sure that these filters are stopped before starting this
	  filter.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.