.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-handle-get-line-values-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _GPIOHANDLE_GET_LINE_VALUES_IOCTL:

*******************************
GPIOHANDLE_GET_LINE_VALUES_IOCTL
********************************
.. warning::
    This ioctl is part of chardev_v1.rst and is obsoleted by
    gpio-v2-line-get-values-ioctl.rst.

Tên
====

GPIOHANDLE_GET_LINE_VALUES_IOCTL - Nhận giá trị của tất cả các dòng được yêu cầu.

Tóm tắt
========

.. c:macro:: GPIOHANDLE_GET_LINE_VALUES_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tập tin của thiết bị ký tự GPIO, như được trả về trong
    ZZ0000ZZ bởi gpio-get-linehandle-ioctl.rst.

ZZ0001ZZ
    ZZ0000ZZ sẽ được phổ biến.

Sự miêu tả
===========

Nhận giá trị của tất cả các dòng được yêu cầu.

Các giá trị được trả về là logic, cho biết đường dây đang hoạt động hay không hoạt động.
Cờ ZZ0000ZZ kiểm soát ánh xạ giữa các vật lý
giá trị (cao/thấp) và giá trị logic (hoạt động/không hoạt động).
Nếu ZZ0001ZZ không được đặt thì mức cao sẽ hoạt động và
thấp là không hoạt động. Nếu ZZ0002ZZ được đặt thì mức thấp sẽ hoạt động
và cao là không hoạt động.

Giá trị của cả hai dòng đầu vào và đầu ra có thể được đọc.

Đối với dòng đầu ra, giá trị trả về phụ thuộc vào trình điều khiển và cấu hình và
có thể là bộ đệm đầu ra (bộ giá trị được yêu cầu cuối cùng) hoặc đầu vào
bộ đệm (mức thực tế của dòng) và tùy thuộc vào phần cứng và
cấu hình này có thể khác nhau.

Ioctl này cũng có thể được sử dụng để đọc giá trị dòng cho các sự kiện dòng,
thay thế ZZ0000ZZ cho ZZ0001ZZ.  Vì chỉ có
một dòng được yêu cầu trong trường hợp đó, chỉ một giá trị được trả về trong ZZ0002ZZ.

Giá trị trả về
============

Khi thành công 0 và ZZ0000ZZ được điền các giá trị được đọc.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.