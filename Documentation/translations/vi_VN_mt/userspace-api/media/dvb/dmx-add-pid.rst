.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-add-pid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_ADD_PID:

============
DMX_ADD_PID
============

Tên
----

DMX_ADD_PID

Tóm tắt
--------

.. c:macro:: DMX_ADD_PID

ZZ0000ZZ

Đối số
---------

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
   Số PID cần lọc.

Sự miêu tả
-----------

Cuộc gọi ioctl này cho phép thêm nhiều PID vào bộ lọc luồng truyền tải
được thiết lập trước đó với ZZ0000ZZ và đầu ra bằng
ZZ0001ZZ.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.