.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-v2-line-set-config-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _GPIO_V2_LINE_SET_CONFIG_IOCTL:

*****************************
GPIO_V2_LINE_SET_CONFIG_IOCTL
*****************************

Tên
====

GPIO_V2_LINE_SET_CONFIG_IOCTL - Cập nhật cấu hình của các dòng được yêu cầu trước đó.

Tóm tắt
========

.. c:macro:: GPIO_V2_LINE_SET_CONFIG_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tập tin của thiết bị ký tự GPIO, như được trả về trong
    ZZ0000ZZ bởi gpio-v2-get-line-ioctl.rst.

ZZ0001ZZ
    ZZ0000ZZ mới được áp dụng cho
    các dòng được yêu cầu.

Sự miêu tả
===========

Cập nhật cấu hình của các dòng được yêu cầu trước đó mà không giải phóng
dòng hoặc giới thiệu các trục trặc tiềm ẩn.

Cấu hình mới phải chỉ định cấu hình cho tất cả các dòng được yêu cầu.

ZZ0000ZZ tương tự và
ZZ0001ZZ áp dụng khi yêu cầu xếp hàng
cũng áp dụng khi cập nhật cấu hình đường truyền, với phần bổ sung
hạn chế rằng cờ định hướng phải được đặt để cho phép cấu hình lại.
Nếu không có cờ định hướng nào được đặt trong cấu hình cho một đường nhất định thì
cấu hình cho dòng đó không thay đổi.

Trường hợp sử dụng thúc đẩy cho lệnh này là thay đổi hướng của
đường hai chiều giữa đầu vào và đầu ra, nhưng nó cũng có thể được sử dụng để
điều khiển linh hoạt việc phát hiện cạnh hoặc nói chung là di chuyển các đường một cách liền mạch
từ trạng thái cấu hình này sang trạng thái cấu hình khác.

Để chỉ thay đổi giá trị của dòng đầu ra, hãy sử dụng
gpio-v2-line-set-values-ioctl.rst.

Giá trị trả về
============

Về thành công 0.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.