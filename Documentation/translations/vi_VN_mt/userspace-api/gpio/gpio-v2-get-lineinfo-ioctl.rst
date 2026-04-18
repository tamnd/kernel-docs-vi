.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-v2-get-lineinfo-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _GPIO_V2_GET_LINEINFO_IOCTL:

**************************
GPIO_V2_GET_LINEINFO_IOCTL
**************************

Tên
====

GPIO_V2_GET_LINEINFO_IOCTL - Nhận thông tin có sẵn công khai cho một đường dây.

Tóm tắt
========

.. c:macro:: GPIO_V2_GET_LINEINFO_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp của thiết bị ký tự GPIO được trả về bởi ZZ0001ZZ.

ZZ0001ZZ
    ZZ0000ZZ sẽ được điền vào, với
    Trường ZZ0002ZZ được đặt để cho biết dòng sẽ được thu thập.

Sự miêu tả
===========

Nhận thông tin có sẵn công khai cho một dòng.

Thông tin này có sẵn độc lập với việc đường dây có được sử dụng hay không.

.. note::
    The line info does not include the line value.

    The line must be requested using gpio-v2-get-line-ioctl.rst to access its
    value.

Giá trị trả về
============

Khi thành công 0 và ZZ0000ZZ được điền thông tin chip.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.