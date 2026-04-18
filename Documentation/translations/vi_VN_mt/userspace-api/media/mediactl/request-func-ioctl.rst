.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/request-func-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: MC

.. _request-func-ioctl:

****************
yêu cầu ioctl()
***************

Tên
====

request-ioctl - Kiểm soát bộ mô tả tệp yêu cầu

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
    Mã lệnh ioctl yêu cầu như được xác định trong tệp tiêu đề media.h, dành cho
    ví dụ ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới một cấu trúc theo yêu cầu cụ thể.

Sự miêu tả
===========

Hàm ZZ0000ZZ xử lý yêu cầu
các thông số. Đối số ZZ0001ZZ phải là một bộ mô tả tệp đang mở.

Mã ioctl ZZ0000ZZ chỉ định hàm yêu cầu sẽ được gọi. Nó
đã được mã hóa trong đó cho dù đối số là đầu vào, đầu ra hay đọc/ghi
tham số và kích thước của đối số ZZ0001ZZ tính bằng byte.

Định nghĩa macro và cấu trúc chỉ định các lệnh ioctl yêu cầu và
các tham số của chúng nằm trong tệp tiêu đề media.h. Tất cả yêu cầu ioctl
các lệnh, chức năng và tham số tương ứng của chúng được chỉ định trong
ZZ0000ZZ.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

Mã lỗi dành riêng cho lệnh được liệt kê trong lệnh riêng lẻ
mô tả.

Khi một ioctl nhận tham số đầu ra hoặc tham số đọc/ghi bị lỗi,
tham số vẫn không được sửa đổi.