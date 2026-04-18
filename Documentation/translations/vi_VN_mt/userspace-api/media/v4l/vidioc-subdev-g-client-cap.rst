.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-subdev-g-client-cap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_SUBDEV_G_CLIENT_CAP:

****************************************************************
ioctl VIDIOC_SUBDEV_G_CLIENT_CAP, VIDIOC_SUBDEV_S_CLIENT_CAP
************************************************************

Tên
====

VIDIOC_SUBDEV_G_CLIENT_CAP - VIDIOC_SUBDEV_S_CLIENT_CAP - Nhận hoặc đặt ứng dụng khách
khả năng.

Tóm tắt
========

.. c:macro:: VIDIOC_SUBDEV_G_CLIENT_CAP

ZZ0000ZZ

.. c:macro:: VIDIOC_SUBDEV_S_CLIENT_CAP

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ioctls này được sử dụng để lấy và thiết lập ứng dụng khách (ứng dụng sử dụng
khả năng của thiết bị phụ ioctls). Các khả năng của máy khách được lưu trữ trong tập tin
xử lý của nút thiết bị subdev đã mở và máy khách phải đặt
khả năng cho từng subdev được mở riêng biệt.

Theo mặc định, không có khả năng nào của máy khách được đặt khi nút thiết bị con được mở.

Mục đích của các khả năng của máy khách là thông báo cho lõi về hành vi
của khách hàng, chủ yếu liên quan đến việc duy trì khả năng tương thích với các
phiên bản kernel và không gian người dùng.

ZZ0000ZZ ioctl trả về các khả năng hiện tại của máy khách
được liên kết với phần xử lý tệp ZZ0001ZZ.

ZZ0000ZZ ioctl đặt khả năng của máy khách cho tệp
xử lý ZZ0001ZZ. Các khả năng mới thay thế hoàn toàn các khả năng hiện tại,
do đó ioctl cũng có thể được sử dụng để loại bỏ các khả năng trước đây
đã được thiết lập.

ZZ0001ZZ sửa đổi cấu trúc
ZZ0000ZZ để phản ánh các khả năng có
đã được chấp nhận. Một trường hợp phổ biến về việc kernel không chấp nhận một khả năng là
kernel cũ hơn các tiêu đề mà không gian người dùng sử dụng và do đó khả năng
kernel chưa biết.

.. tabularcolumns:: |p{1.5cm}|p{2.9cm}|p{12.9cm}|

.. c:type:: v4l2_subdev_client_capability

.. flat-table:: struct v4l2_subdev_client_capability
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 4 20

    * - __u64
      - ``capabilities``
      - Sub-device client capabilities of the opened device.

.. tabularcolumns:: |p{6.8cm}|p{2.4cm}|p{8.1cm}|

.. flat-table:: Client Capabilities
    :header-rows:  1

    * - Capability
      - Description
    * - ``V4L2_SUBDEV_CLIENT_CAP_STREAMS``
      - The client is aware of streams. Setting this flag enables the use
        of 'stream' fields (referring to the stream number) with various
        ioctls. If this is not set (which is the default), the 'stream' fields
        will be forced to 0 by the kernel.
    * - ``V4L2_SUBDEV_CLIENT_CAP_INTERVAL_USES_WHICH``
      - The client is aware of the :c:type:`v4l2_subdev_frame_interval`
        ``which`` field. If this is not set (which is the default), the
        ``which`` field is forced to ``V4L2_SUBDEV_FORMAT_ACTIVE`` by the
        kernel.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ENOIOCTLCMD
   Kernel không hỗ trợ ioctl này.