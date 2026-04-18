.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-get-rec-mode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: RC

.. _lirc_get_rec_mode:
.. _lirc_set_rec_mode:

**********************************************
ioctls LIRC_GET_REC_MODE và LIRC_SET_REC_MODE
**********************************************

Tên
====

LIRC_GET_REC_MODE/LIRC_SET_REC_MODE - Nhận/đặt chế độ nhận hiện tại.

Tóm tắt
========

.. c:macro:: LIRC_GET_REC_MODE

ZZ0000ZZ

.. c:macro:: LIRC_SET_REC_MODE

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Chế độ được sử dụng để nhận.

Sự miêu tả
===========

Nhận và thiết lập chế độ nhận hiện tại. Chỉ
ZZ0000ZZ và
ZZ0001ZZ được hỗ trợ.
Sử dụng ZZ0002ZZ để tìm hiểu xem trình điều khiển hỗ trợ chế độ nào.

Giá trị trả về
============

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  .. row 1

       -  ``ENODEV``

       -  Device not available.

    -  .. row 2

       -  ``ENOTTY``

       -  Device does not support receiving.

    -  .. row 3

       -  ``EINVAL``

       -  Invalid mode or invalid mode for this device.