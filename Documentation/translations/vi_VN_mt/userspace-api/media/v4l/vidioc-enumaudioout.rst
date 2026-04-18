.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-enumaudioout.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_ENUMAUDOUT:

***********************
ioctl VIDIOC_ENUMAUDOUT
***********************

Tên
====

VIDIOC_ENUMAUDOUT - Liệt kê đầu ra âm thanh

Tóm tắt
========

.. c:macro:: VIDIOC_ENUMAUDOUT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để truy vấn các thuộc tính của ứng dụng đầu ra âm thanh, hãy khởi tạo
Trường ZZ0001ZZ và loại bỏ mảng ZZ0002ZZ của cấu trúc
ZZ0000ZZ và gọi ZZ0003ZZ
ioctl bằng một con trỏ tới cấu trúc này. Trình điều khiển lấp đầy phần còn lại của
cấu trúc hoặc trả về mã lỗi ZZ0004ZZ khi hết chỉ mục
giới hạn. Để liệt kê tất cả các ứng dụng đầu ra âm thanh sẽ bắt đầu ở chỉ mục
0, tăng dần một cho đến khi trình điều khiển trả về ZZ0005ZZ.

.. note::

    Connectors on a TV card to loop back the received audio signal
    to a sound card are not audio outputs in this sense.

Xem ZZ0000ZZ để biết mô tả về cấu trúc
ZZ0001ZZ.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Số lượng đầu ra âm thanh nằm ngoài giới hạn.