.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-set-rec-carrier.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: RC

.. _lirc_set_rec_carrier:

**************************
ioctl LIRC_SET_REC_CARRIER
**************************

Tên
====

LIRC_SET_REC_CARRIER - Đặt sóng mang được sử dụng để điều chỉnh nhận IR.

Tóm tắt
========

.. c:macro:: LIRC_SET_REC_CARRIER

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Tần số của sóng mang điều chỉnh dữ liệu PWM, tính bằng Hz.

Sự miêu tả
===========

Đặt sóng mang nhận được sử dụng để điều chỉnh các xung và khoảng trống IR PWM.

.. note::

   If called together with :ref:`LIRC_SET_REC_CARRIER_RANGE`, this ioctl
   sets the upper bound frequency that will be recognized by the device.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.