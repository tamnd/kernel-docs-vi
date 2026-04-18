.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-set-send-duty-cycle.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: RC

.. _lirc_set_send_duty_cycle:

*******************************
ioctl LIRC_SET_SEND_DUTY_CYCLE
******************************

Tên
====

LIRC_SET_SEND_DUTY_CYCLE - Đặt chu kỳ hoạt động của tín hiệu sóng mang cho
truyền hồng ngoại.

Tóm tắt
========

.. c:macro:: LIRC_SET_SEND_DUTY_CYCLE

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Chu kỳ nhiệm vụ, mô tả độ rộng xung theo phần trăm (từ 1 đến 99) của
    tổng chu kỳ. Giá trị 0 và 100 được bảo lưu.

Sự miêu tả
===========

Nhận/đặt chu kỳ nhiệm vụ của tín hiệu sóng mang để truyền IR.

Hiện tại, không có ý nghĩa đặc biệt nào được xác định cho 0 hoặc 100, nhưng điều này
có thể được sử dụng để tắt việc tạo sóng mang trong tương lai, vì vậy
những giá trị này nên được bảo lưu.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.