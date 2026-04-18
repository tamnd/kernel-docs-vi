.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-input.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_INPUT:

*************************************
ioctl VIDIOC_G_INPUT, VIDIOC_S_INPUT
*************************************

Tên
====

VIDIOC_G_INPUT - VIDIOC_S_INPUT - Truy vấn hoặc chọn đầu vào video hiện tại

Tóm tắt
========

.. c:macro:: VIDIOC_G_INPUT

ZZ0000ZZ

.. c:macro:: VIDIOC_S_INPUT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ một số nguyên có chỉ số đầu vào.

Sự miêu tả
===========

Để truy vấn các ứng dụng đầu vào video hiện tại, hãy gọi
ZZ0000ZZ ioctl với một con trỏ tới một số nguyên nơi trình điều khiển
lưu trữ số lượng đầu vào, như trong cấu trúc
Trường ZZ0001ZZ ZZ0002ZZ. Ioctl này sẽ thất bại
chỉ khi không có đầu vào video, trả về ZZ0003ZZ.

Để chọn đầu vào video, ứng dụng sẽ lưu trữ số lượng video mong muốn
nhập một số nguyên và gọi ZZ0000ZZ ioctl bằng một con trỏ
tới số nguyên này. Tác dụng phụ có thể xảy ra. Ví dụ đầu vào có thể
hỗ trợ các tiêu chuẩn video khác nhau, do đó trình điều khiển có thể ngầm chuyển đổi
tiêu chuẩn hiện hành. Vì những tác dụng phụ có thể xảy ra này
các ứng dụng phải chọn đầu vào trước khi truy vấn hoặc đàm phán bất kỳ
các thông số khác.

Thông tin về đầu vào video có sẵn bằng cách sử dụng
ZZ0000ZZ ioctl.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Số lượng đầu vào video nằm ngoài giới hạn.