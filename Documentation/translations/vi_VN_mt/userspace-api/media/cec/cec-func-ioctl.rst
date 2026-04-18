.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-func-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: CEC

.. _cec-func-ioctl:

*************
cec ioctl()
*************

Tên
====

cec-ioctl - Điều khiển thiết bị cec

Tóm tắt
========

.. code-block:: c

    #include <sys/ioctl.h>

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Mã yêu cầu ioctl CEC như được xác định trong tệp tiêu đề cec.h, dành cho
    ví dụ ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới một cấu trúc theo yêu cầu cụ thể.

Sự miêu tả
===========

Hàm ZZ0000ZZ thao tác các tham số của thiết bị cec. các
đối số ZZ0001ZZ phải là bộ mô tả tệp đang mở.

Mã ioctl ZZ0000ZZ chỉ định hàm cec sẽ được gọi. Nó
đã được mã hóa trong đó cho dù đối số là đầu vào, đầu ra hay đọc/ghi
tham số và kích thước của đối số ZZ0001ZZ tính bằng byte.

Định nghĩa macro và cấu trúc chỉ định các yêu cầu cec ioctl và
các tham số của chúng nằm trong tệp tiêu đề cec.h. Tất cả cec ioctl
các yêu cầu, chức năng và tham số tương ứng của chúng được chỉ định trong
ZZ0000ZZ.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

Mã lỗi dành riêng cho yêu cầu được liệt kê trong các yêu cầu riêng lẻ
mô tả.

Khi một ioctl nhận tham số đầu ra hoặc tham số đọc/ghi bị lỗi,
tham số vẫn không được sửa đổi.