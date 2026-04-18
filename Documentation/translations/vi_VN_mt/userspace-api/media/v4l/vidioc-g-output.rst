.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-output.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_OUTPUT:

**************************************
ioctl VIDIOC_G_OUTPUT, VIDIOC_S_OUTPUT
**************************************

Tên
====

VIDIOC_G_OUTPUT - VIDIOC_S_OUTPUT - Truy vấn hoặc chọn đầu ra video hiện tại

Tóm tắt
========

.. c:macro:: VIDIOC_G_OUTPUT

ZZ0000ZZ

.. c:macro:: VIDIOC_S_OUTPUT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới một số nguyên có chỉ số đầu ra.

Sự miêu tả
===========

Để truy vấn các ứng dụng đầu ra video hiện tại, hãy gọi
ZZ0000ZZ ioctl với một con trỏ tới một số nguyên nơi trình điều khiển
lưu trữ số lượng đầu ra, như trong cấu trúc
Trường ZZ0001ZZ ZZ0002ZZ. Ioctl này sẽ
chỉ thất bại khi không có đầu ra video, trả về lỗi ZZ0003ZZ
mã.

Để chọn ứng dụng đầu ra video, hãy lưu trữ số lượng video mong muốn
xuất ra một số nguyên và gọi ZZ0000ZZ ioctl bằng một
con trỏ tới số nguyên này. Tác dụng phụ có thể xảy ra. Ví dụ đầu ra
có thể hỗ trợ các tiêu chuẩn video khác nhau, do đó trình điều khiển có thể ngầm
chuyển đổi tiêu chuẩn hiện tại. Vì những mặt có thể này
các ứng dụng hiệu ứng phải chọn đầu ra trước khi truy vấn hoặc
đàm phán bất kỳ thông số nào khác.

Thông tin về đầu ra video có sẵn bằng cách sử dụng
ZZ0000ZZ ioctl.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Số lượng đầu ra video vượt quá giới hạn hoặc không có
    đầu ra video nào cả.