.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-get-info.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_GET_INFO:

*****************
ioctl FE_GET_INFO
*****************

Tên
====

FE_GET_INFO - Truy vấn khả năng giao diện người dùng TV kỹ thuật số và trả về thông tin
về - giao diện người dùng. Cuộc gọi này chỉ yêu cầu quyền truy cập chỉ đọc vào thiết bị.

Tóm tắt
========

.. c:macro:: FE_GET_INFO

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    con trỏ tới cấu trúc ZZ0000ZZ

Sự miêu tả
===========

Tất cả các thiết bị đầu cuối TV kỹ thuật số đều hỗ trợ ZZ0000ZZ ioctl. Đó là
được sử dụng để xác định các thiết bị hạt nhân tương thích với thông số kỹ thuật này và để
có được thông tin về trình điều khiển và khả năng phần cứng. ioctl
lấy một con trỏ tới dvb_frontend_info được trình điều khiển điền vào.
Khi trình điều khiển không tương thích với thông số kỹ thuật này, ioctl
trả về một lỗi.

khả năng giao diện người dùng
=====================

Khả năng mô tả những gì một giao diện người dùng có thể làm. Một số khả năng được
chỉ được hỗ trợ trên một số loại giao diện người dùng cụ thể.

Các khả năng của giao diện người dùng được mô tả tại ZZ0000ZZ.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.