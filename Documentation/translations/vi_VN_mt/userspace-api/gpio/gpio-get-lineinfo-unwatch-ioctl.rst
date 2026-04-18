.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-get-lineinfo-unwatch-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _GPIO_GET_LINEINFO_UNWATCH_IOCTL:

*******************************
GPIO_GET_LINEINFO_UNWATCH_IOCTL
*******************************

Tên
====

GPIO_GET_LINEINFO_UNWATCH_IOCTL - Vô hiệu hóa việc xem một dòng để biết các thay đổi đối với nó
thông tin trạng thái và cấu hình được yêu cầu.

Tóm tắt
========

.. c:macro:: GPIO_GET_LINEINFO_UNWATCH_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp của thiết bị ký tự GPIO được trả về bởi ZZ0001ZZ.

ZZ0000ZZ
    Sự bù đắp của dòng để không còn xem.

Sự miêu tả
===========

Xóa dòng này khỏi danh sách các dòng đang được xem trên ZZ0000ZZ này.

Đây là mặt trái của gpio-v2-get-lineinfo-watch-ioctl.rst (v2) và
gpio-get-lineinfo-watch-ioctl.rst (v1).

Việc bỏ xem một dòng chưa được xem là một lỗi (ZZ0000ZZ).

Lần đầu tiên được thêm vào trong 5.7.

Giá trị trả về
============

Về thành công 0.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.