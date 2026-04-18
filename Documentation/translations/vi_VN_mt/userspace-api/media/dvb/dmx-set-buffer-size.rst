.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-set-buffer-size.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_SET_BUFFER_SIZE:

=====================
DMX_SET_BUFFER_SIZE
=====================

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
--------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.