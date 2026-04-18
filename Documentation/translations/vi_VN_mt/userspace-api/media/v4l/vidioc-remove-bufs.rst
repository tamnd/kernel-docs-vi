.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-remove-bufs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_REMOVE_BUFS:

*************************
ioctl VIDIOC_REMOVE_BUFS
************************

Tên
====

VIDIOC_REMOVE_BUFS - Xóa bộ đệm khỏi hàng đợi

Tóm tắt
========

.. c:macro:: VIDIOC_REMOVE_BUFS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ứng dụng có thể tùy chọn gọi ZZ0000ZZ ioctl tới
loại bỏ bộ đệm khỏi hàng đợi.
Hỗ trợ ioctl ZZ0001ZZ là bắt buộc để kích hoạt ZZ0002ZZ.
Ioctl này khả dụng nếu khả năng ZZ0005ZZ
được đặt trên hàng đợi khi ZZ0003ZZ hoặc ZZ0004ZZ
được gọi.

.. c:type:: v4l2_remove_buffers

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_remove_buffers
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``index``
      - The starting buffer index to remove. This field is ignored if count == 0.
    * - __u32
      - ``count``
      - The number of buffers to be removed with indices 'index' until 'index + count - 1'.
        All buffers in this range must be valid and in DEQUEUED state.
        :ref:`VIDIOC_REMOVE_BUFS` will always check the validity of ``type``, if it is
        invalid it returns ``EINVAL`` error code.
        If count is set to 0 :ref:`VIDIOC_REMOVE_BUFS` will do nothing and return 0.
    * - __u32
      - ``type``
      - Type of the stream or buffers, this is the same as the struct
	:c:type:`v4l2_format` ``type`` field. See
	:c:type:`v4l2_buf_type` for valid values.
    * - __u32
      - ``reserved``\ [13]
      - A place holder for future extensions. Drivers and applications
	must set the array to zero.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ. Nếu xảy ra lỗi thì không
bộ đệm sẽ được giải phóng và một trong các mã lỗi bên dưới sẽ được trả về:

EBUSY
    Tệp I/O đang được tiến hành.
    Một hoặc nhiều bộ đệm trong phạm vi ZZ0000ZZ đến ZZ0001ZZ thì không
    ở trạng thái DEQUEUED.

EINVAL
    Một hoặc nhiều bộ đệm trong phạm vi ZZ0000ZZ đến ZZ0001ZZ không
    tồn tại trong hàng đợi.
    Loại bộ đệm (trường ZZ0002ZZ) không hợp lệ.