.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-get-property.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_GET_PROPERTY:

*************************************
ioctl FE_SET_PROPERTY, FE_GET_PROPERTY
**************************************

Tên
====

FE_SET_PROPERTY - FE_GET_PROPERTY - FE_SET_PROPERTY đặt một hoặc nhiều thuộc tính giao diện người dùng. - FE_GET_PROPERTY trả về một hoặc nhiều thuộc tính giao diện người dùng.

Tóm tắt
========

.. c:macro:: FE_GET_PROPERTY

ZZ0000ZZ

.. c:macro:: FE_SET_PROPERTY

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Tất cả các thiết bị đầu cuối TV kỹ thuật số đều hỗ trợ ZZ0000ZZ và
ZZ0001ZZ ioctls. Các thuộc tính và số liệu thống kê được hỗ trợ
phụ thuộc vào hệ thống phân phối và thiết bị:

-ZZ0000ZZ

- ioctl này được sử dụng để thiết lập một hoặc nhiều thuộc tính giao diện người dùng.

- Đây là lệnh cơ bản để yêu cầu frontend điều chỉnh
      một số tần số và bắt đầu giải mã tín hiệu TV kỹ thuật số.

- Cuộc gọi này yêu cầu quyền truy cập đọc/ghi vào thiết bị.

.. note::

   At return, the values aren't updated to reflect the actual
   parameters used. If the actual parameters are needed, an explicit
   call to ``FE_GET_PROPERTY`` is needed.

-ZZ0000ZZ

- ioctl này được sử dụng để lấy các thuộc tính và số liệu thống kê từ
      lối vào.

- Không có thuộc tính nào được thay đổi và số liệu thống kê không được đặt lại.

- Cuộc gọi này chỉ yêu cầu quyền truy cập chỉ đọc vào thiết bị.

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.