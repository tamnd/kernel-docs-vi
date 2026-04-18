.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-set-frontend-tune-mode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_SET_FRONTEND_TUNE_MODE:

*******************************
ioctl FE_SET_FRONTEND_TUNE_MODE
*******************************

Tên
====

FE_SET_FRONTEND_TUNE_MODE - Cho phép cài đặt cờ chế độ bộ điều chỉnh ở giao diện người dùng.

Tóm tắt
========

.. c:macro:: FE_SET_FRONTEND_TUNE_MODE

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Cờ hợp lệ:

- 0 - chế độ điều chỉnh bình thường

- ZZ0000ZZ - Khi được đặt, cờ này sẽ vô hiệu hóa mọi
       ngoằn ngoèo hoặc hành vi điều chỉnh "bình thường" khác. Ngoài ra,
       sẽ không có sự giám sát tự động về trạng thái khóa và
       do đó sẽ không có sự kiện giao diện người dùng nào được tạo ra. Nếu một thiết bị ngoại vi
       bị đóng, cờ này sẽ tự động tắt khi
       thiết bị được mở lại đọc-ghi.

Sự miêu tả
===========

Cho phép cài đặt cờ chế độ bộ điều chỉnh ở giao diện người dùng, trong khoảng 0 (bình thường) hoặc
Chế độ ZZ0000ZZ

Giá trị trả về
============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.