.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-func-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: CEC

.. _cec-func-ioctl:

*************
cec ioctl()
***********

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
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

Mã lỗi dành riêng cho yêu cầu được liệt kê trong các yêu cầu riêng lẻ
mô tả.

Khi một ioctl nhận tham số đầu ra hoặc tham số đọc/ghi bị lỗi,
tham số vẫn không được sửa đổi.