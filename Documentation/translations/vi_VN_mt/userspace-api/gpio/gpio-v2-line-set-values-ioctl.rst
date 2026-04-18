.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-v2-line-set-values-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _GPIO_V2_LINE_SET_VALUES_IOCTL:

*****************************
GPIO_V2_LINE_SET_VALUES_IOCTL
*****************************

Tên
====

GPIO_V2_LINE_SET_VALUES_IOCTL - Đặt giá trị của dòng đầu ra được yêu cầu.

Tóm tắt
========

.. c:macro:: GPIO_V2_LINE_SET_VALUES_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tập tin của thiết bị ký tự GPIO, như được trả về trong
    ZZ0000ZZ bởi gpio-v2-get-line-ioctl.rst.

ZZ0001ZZ
    ZZ0000ZZ được cài đặt cùng với bộ ZZ0002ZZ
    để chỉ ra tập hợp con các dòng được yêu cầu đặt và ZZ0003ZZ được đặt thành
    cho biết giá trị mới.

Sự miêu tả
===========

Đặt giá trị của dòng đầu ra được yêu cầu.

Các giá trị được đặt là logic, cho biết đường dây đang hoạt động hay không hoạt động.
Cờ ZZ0000ZZ kiểm soát ánh xạ giữa logic
giá trị (hoạt động/không hoạt động) và giá trị vật lý (cao/thấp).
Nếu ZZ0001ZZ không được đặt thì hoạt động ở mức cao và không hoạt động
thấp.  Nếu ZZ0002ZZ được đặt thì hoạt động ở mức thấp và
không hoạt động ở mức cao.

Chỉ có thể đặt giá trị của dòng đầu ra.
Cố gắng đặt giá trị của dòng đầu vào là một lỗi (ZZ0000ZZ).

Giá trị trả về
============

Về thành công 0.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.