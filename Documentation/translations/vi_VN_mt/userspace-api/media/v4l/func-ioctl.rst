.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/func-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _func-ioctl:

*************
V4L2 ioctl()
*************

Tên
====

v4l2-ioctl - Lập trình thiết bị V4L2

Tóm tắt
========

.. code-block:: c

    #include <sys/ioctl.h>

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Mã yêu cầu ioctl V4L2 như được xác định trong tiêu đề ZZ0001ZZ
    tập tin, ví dụ VIDIOC_QUERYCAP.

ZZ0000ZZ
    Con trỏ tới một tham số hàm, thường là một cấu trúc.

Sự miêu tả
===========

Chức năng ZZ0000ZZ được sử dụng để lập trình các thiết bị V4L2. các
đối số ZZ0002ZZ phải là bộ mô tả tệp đang mở. Một ioctl ZZ0003ZZ
đã được mã hóa trong đó cho dù đối số là đầu vào, đầu ra hay đọc/ghi
tham số và kích thước của đối số ZZ0004ZZ tính bằng byte. Macro và
xác định việc chỉ định các yêu cầu ioctl V4L2 được đặt trong
Tệp tiêu đề ZZ0005ZZ. Các ứng dụng nên sử dụng bản sao của riêng mình, không
bao gồm phiên bản trong nguồn kernel trên hệ thống mà chúng biên dịch.
Tất cả các yêu cầu ioctl V4L2, chức năng và tham số tương ứng của chúng là
được chỉ định trong ZZ0001ZZ.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

Khi một ioctl nhận tham số đầu ra hoặc tham số đọc/ghi bị lỗi,
tham số vẫn không được sửa đổi.