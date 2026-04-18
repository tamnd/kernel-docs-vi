.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-querystd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_QUERYSTD:

**********************************************
ioctl VIDIOC_QUERYSTD, VIDIOC_SUBDEV_QUERYSTD
*********************************************

Tên
====

VIDIOC_QUERYSTD - VIDIOC_SUBDEV_QUERYSTD - Nhận biết tiêu chuẩn video mà đầu vào hiện tại nhận được

Tóm tắt
========

.. c:macro:: VIDIOC_QUERYSTD

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_QUERYSTD

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới ZZ0000ZZ.

Sự miêu tả
===========

Phần cứng có thể phát hiện được tiêu chuẩn video hiện tại
tự động. Để làm như vậy, các ứng dụng gọi ZZ0000ZZ bằng một
con trỏ tới loại ZZ0001ZZ. Người lái xe
lưu trữ ở đây một tập hợp các ứng cử viên, đây có thể là một lá cờ hoặc một tập hợp
các tiêu chuẩn được hỗ trợ, ví dụ như nếu phần cứng chỉ có thể phân biệt
giữa các hệ thống 50 và 60 Hz. Nếu không phát hiện thấy tín hiệu thì người lái xe
sẽ trả về V4L2_STD_UNKNOWN. Khi việc phát hiện là không thể hoặc không thành công,
bộ này phải chứa tất cả các tiêu chuẩn được hỗ trợ bởi đầu vào video hiện tại
hoặc đầu ra.

.. note::

   Drivers shall *not* switch the video standard
   automatically if a new video standard is detected. Instead, drivers
   should send the ``V4L2_EVENT_SOURCE_CHANGE`` event (if they support
   this) and expect that userspace will take action by calling
   :ref:`VIDIOC_QUERYSTD`. The reason is that a new video standard can mean
   different buffer sizes as well, and you cannot change buffer sizes on
   the fly. In general, applications that receive the Source Change event
   will have to call :ref:`VIDIOC_QUERYSTD`, and if the detected video
   standard is valid they will have to stop streaming, set the new
   standard, allocate new buffers and start streaming again.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ENODATA
    Định giờ video tiêu chuẩn không được hỗ trợ cho đầu vào hoặc đầu ra này.