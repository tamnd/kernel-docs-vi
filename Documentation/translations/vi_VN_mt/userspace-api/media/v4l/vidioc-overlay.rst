.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-overlay.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_OVERLAY:

********************
ioctl VIDIOC_OVERLAY
********************

Tên
====

VIDIOC_OVERLAY - Bắt đầu hoặc dừng lớp phủ video

Tóm tắt
========

.. c:macro:: VIDIOC_OVERLAY

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới một số nguyên.

Sự miêu tả
===========

Ioctl này là một phần của phương thức I/O ZZ0000ZZ.
Ứng dụng gọi ZZ0001ZZ để bắt đầu hoặc dừng lớp phủ. Nó
đưa một con trỏ tới một số nguyên phải được đặt bằng 0 bởi
ứng dụng dừng lớp phủ, đến một để bắt đầu.

Trình điều khiển không hỗ trợ ZZ0000ZZ hoặc
ZZ0001ZZ với
ZZ0002ZZ.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Các tham số lớp phủ chưa được thiết lập. Xem ZZ0000ZZ
    cho các bước cần thiết.