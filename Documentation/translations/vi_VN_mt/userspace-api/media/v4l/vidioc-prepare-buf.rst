.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-prepare-buf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_PREPARE_BUF:

*************************
ioctl VIDIOC_PREPARE_BUF
*************************

Tên
====

VIDIOC_PREPARE_BUF - Chuẩn bị bộ đệm cho I/O

Tóm tắt
========

.. c:macro:: VIDIOC_PREPARE_BUF

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
chuyển quyền sở hữu bộ đệm cho trình điều khiển trước khi thực sự xếp nó vào hàng đợi,
bằng cách sử dụng ZZ0001ZZ ioctl và để chuẩn bị cho I/O trong tương lai. Như vậy
việc chuẩn bị có thể bao gồm việc vô hiệu hóa hoặc dọn dẹp bộ đệm. Thực hiện chúng
trước giúp tiết kiệm thời gian trong quá trình I/O thực tế.

Cấu trúc ZZ0000ZZ được chỉ định trong
ZZ0001ZZ.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EBUSY
    Tệp I/O đang được tiến hành.

EINVAL
    Bộ đệm ZZ0000ZZ không được hỗ trợ hoặc ZZ0001ZZ đã hết
    giới hạn hoặc chưa có bộ đệm nào được phân bổ hoặc ZZ0002ZZ hoặc
    ZZ0003ZZ không hợp lệ.