.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-v2-line-get-values-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _GPIO_V2_LINE_GET_VALUES_IOCTL:

*****************************
GPIO_V2_LINE_GET_VALUES_IOCTL
*****************************

Tên
====

GPIO_V2_LINE_GET_VALUES_IOCTL - Nhận giá trị của các dòng được yêu cầu.

Tóm tắt
========

.. c:macro:: GPIO_V2_LINE_GET_VALUES_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tập tin của thiết bị ký tự GPIO, như được trả về trong
    ZZ0000ZZ bởi gpio-v2-get-line-ioctl.rst.

ZZ0001ZZ
    ZZ0000ZZ đi kèm với bộ ZZ0002ZZ
    để chỉ ra tập hợp con của các dòng được yêu cầu nhận.

Sự miêu tả
===========

Nhận các giá trị của dòng được yêu cầu.

Các giá trị được trả về là logic, cho biết đường dây đang hoạt động hay không hoạt động.
Cờ ZZ0000ZZ kiểm soát ánh xạ giữa các vật lý
giá trị (cao/thấp) và giá trị logic (hoạt động/không hoạt động).
Nếu ZZ0001ZZ không được đặt thì mức cao sẽ hoạt động và mức thấp sẽ hoạt động
không hoạt động.  Nếu ZZ0002ZZ được đặt thì mức thấp sẽ hoạt động và
cao là không hoạt động.

Giá trị của cả hai dòng đầu vào và đầu ra có thể được đọc.

Đối với dòng đầu ra, giá trị trả về phụ thuộc vào trình điều khiển và cấu hình và
có thể là bộ đệm đầu ra (bộ giá trị được yêu cầu cuối cùng) hoặc đầu vào
bộ đệm (mức thực tế của dòng) và tùy thuộc vào phần cứng và
cấu hình này có thể khác nhau.

Giá trị trả về
============

Khi thành công 0 và ZZ0000ZZ tương ứng
chứa giá trị đã đọc.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.