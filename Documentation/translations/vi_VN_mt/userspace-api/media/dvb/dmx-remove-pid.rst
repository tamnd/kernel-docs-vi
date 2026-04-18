.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-remove-pid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_REMOVE_PID:

================
DMX_REMOVE_PID
================

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