.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-get-event.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_GET_EVENT:

*************
FE_GET_EVENT
*************

Tên
====

FE_GET_EVENT

.. attention:: This ioctl is deprecated.

Tóm tắt
========

.. c:macro:: FE_GET_EVENT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Trỏ đến vị trí nơi sự kiện, nếu có, sẽ được lưu trữ.

Sự miêu tả
===========

Cuộc gọi ioctl này trả về một sự kiện giao diện người dùng nếu có. Nếu một sự kiện được
không khả dụng, hành vi này phụ thuộc vào việc thiết bị có bị chặn hay không
hoặc chế độ không chặn. Trong trường hợp sau, cuộc gọi thất bại ngay lập tức
với lỗi được đặt thành ZZ0000ZZ. Trong trường hợp trước, cuộc gọi sẽ chặn cho đến khi
một sự kiện trở nên có sẵn.

Giá trị trả về
==============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  .. row 1

       -  ``EWOULDBLOCK``

       -  There is no event pending, and the device is in non-blocking mode.

    -  .. row 2

       -  ``EOVERFLOW``

       -  Overflow in event queue - one or more events were lost.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.