.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-ioc-request-alloc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: MC

.. _media_ioc_request_alloc:

*****************************
ioctl MEDIA_IOC_REQUEST_ALLOC
*****************************

Tên
====

MEDIA_IOC_REQUEST_ALLOC - Phân bổ yêu cầu

Tóm tắt
========

.. c:macro:: MEDIA_IOC_REQUEST_ALLOC

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới một số nguyên.

Sự miêu tả
===========

Nếu thiết bị đa phương tiện hỗ trợ ZZ0000ZZ thì
ioctl này có thể được sử dụng để phân bổ một yêu cầu. Nếu nó không được hỗ trợ thì
ZZ0001ZZ được đặt thành ZZ0002ZZ. Một yêu cầu được truy cập thông qua một bộ mô tả tập tin
được trả về trong ZZ0003ZZ.

Nếu yêu cầu được phân bổ thành công thì bộ mô tả tệp yêu cầu
có thể được chuyển đến ZZ0000ZZ,
ZZ0001ZZ,
ZZ0002ZZ và
ZZ0003ZZ ioctls.

Ngoài ra, yêu cầu có thể được xếp hàng đợi bằng cách gọi
ZZ0000ZZ và khởi tạo lại bằng cách gọi
ZZ0001ZZ.

Cuối cùng, bộ mô tả tập tin có thể là ZZ0000ZZ để chờ
để yêu cầu hoàn thành.

Yêu cầu sẽ vẫn được phân bổ cho đến khi tất cả các bộ mô tả tệp được liên kết
với nó được đóng bởi ZZ0000ZZ và trình điều khiển không
sử dụng yêu cầu nội bộ lâu hơn. Xem thêm
ZZ0001ZZ để biết thêm thông tin.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ENOTTY
    Trình điều khiển không có hỗ trợ cho các yêu cầu.