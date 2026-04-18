.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-request-ioc-reinit.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: MC

.. _media_request_ioc_reinit:

*******************************
ioctl MEDIA_REQUEST_IOC_REINIT
******************************

Tên
====

MEDIA_REQUEST_IOC_REINIT - Khởi tạo lại yêu cầu

Tóm tắt
========

.. c:macro:: MEDIA_REQUEST_IOC_REINIT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

Sự miêu tả
===========

Nếu thiết bị đa phương tiện hỗ trợ ZZ0000ZZ thì
yêu cầu ioctl này có thể được sử dụng để khởi tạo lại địa chỉ được phân bổ trước đó
yêu cầu.

Việc khởi tạo lại một yêu cầu sẽ xóa mọi dữ liệu hiện có khỏi yêu cầu.
Điều này tránh việc phải hoàn thành ZZ0000ZZ
yêu cầu và phân bổ một yêu cầu mới. Thay vào đó, yêu cầu đã hoàn thành chỉ có thể
được khởi tạo lại và sẵn sàng để sử dụng lại.

Một yêu cầu chỉ có thể được khởi tạo lại nếu nó chưa được xếp hàng đợi
chưa, hoặc nếu nó đã được xếp hàng đợi và hoàn thành. Nếu không nó sẽ đặt ZZ0000ZZ
tới ZZ0001ZZ. Không có mã lỗi nào khác có thể được trả lại.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0000ZZ được đặt
một cách thích hợp.

EBUSY
    Yêu cầu được xếp hàng đợi nhưng chưa được hoàn thành.