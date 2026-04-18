.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-read-uncorrected-blocks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _FE_READ_UNCORRECTED_BLOCKS:

**************************
FE_READ_UNCORRECTED_BLOCKS
**************************

Tên
====

FE_READ_UNCORRECTED_BLOCKS

.. attention:: This ioctl is deprecated.

Tóm tắt
========

.. c:macro:: FE_READ_UNCORRECTED_BLOCKS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Tổng số khối chưa được chỉnh sửa mà người lái xe đã nhìn thấy cho đến nay.

Sự miêu tả
===========

Lệnh gọi ioctl này trả về số khối chưa được sửa được phát hiện bởi
trình điều khiển thiết bị trong suốt thời gian tồn tại của nó. Đối với các phép đo có ý nghĩa,
mức tăng số khối trong một khoảng thời gian cụ thể sẽ là
tính toán. Đối với lệnh này, quyền truy cập chỉ đọc vào thiết bị là
đủ.

Giá trị trả về
==============

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.