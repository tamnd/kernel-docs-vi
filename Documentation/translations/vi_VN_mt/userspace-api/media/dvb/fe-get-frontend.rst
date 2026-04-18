.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-get-frontend.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_GET_FRONTEND:

****************
FE_GET_FRONTEND
****************

Tên
====

FE_GET_FRONTEND

.. attention:: This ioctl is deprecated.

Tóm tắt
========

.. c:macro:: FE_GET_FRONTEND

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Trỏ tới các tham số cho hoạt động điều chỉnh.

Sự miêu tả
===========

Cuộc gọi ioctl này truy vấn các tham số giao diện người dùng hiện có hiệu lực. cho
lệnh này, quyền truy cập chỉ đọc vào thiết bị là đủ.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  .. row 1

       -  ``EINVAL``

       -  Maximum supported symbol rate reached.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.