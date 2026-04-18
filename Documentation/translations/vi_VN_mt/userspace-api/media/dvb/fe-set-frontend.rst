.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-set-frontend.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_SET_FRONTEND:

****************
FE_SET_FRONTEND
***************

.. attention:: This ioctl is deprecated.

Tên
====

FE_SET_FRONTEND

Tóm tắt
========

.. c:macro:: FE_SET_FRONTEND

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Trỏ tới các tham số cho hoạt động điều chỉnh.

Sự miêu tả
===========

Cuộc gọi ioctl này bắt đầu thao tác điều chỉnh bằng cách sử dụng các tham số đã chỉ định.
Kết quả của cuộc gọi này sẽ thành công nếu các tham số hợp lệ
và việc điều chỉnh có thể được bắt đầu. Kết quả của hoạt động điều chỉnh trong
tuy nhiên, bản thân nó sẽ đến một cách không đồng bộ dưới dạng một sự kiện (xem
tài liệu cho ZZ0000ZZ và
FrontendEvent.) Nếu là ZZ0001ZZ mới
hoạt động được bắt đầu trước khi hoạt động trước đó hoàn thành,
hoạt động trước đó sẽ bị hủy bỏ để nhường chỗ cho hoạt động mới. Lệnh này
yêu cầu quyền truy cập đọc/ghi vào thiết bị.

Giá trị trả về
============

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

       -  Maximum supported symbol rate reached.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.