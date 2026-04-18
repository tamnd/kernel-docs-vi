.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-set-rec-carrier-range.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: RC

.. _lirc_set_rec_carrier_range:

********************************
ioctl LIRC_SET_REC_CARRIER_RANGE
********************************

Name
====

LIRC_SET_REC_CARRIER_RANGE - Set lower bound of the carrier used to modulate
IR receive.

Synopsis
========

.. c:macro:: LIRC_SET_REC_CARRIER_RANGE

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Tần số của sóng mang điều chỉnh dữ liệu PWM, tính bằng Hz.

Sự miêu tả
===========

Ioctl này đặt dải tần số sóng mang trên sẽ được nhận dạng
bởi bộ thu IR.

.. note::

   To set a range use :ref:`LIRC_SET_REC_CARRIER_RANGE
   <LIRC_SET_REC_CARRIER_RANGE>` with the lower bound first and later call
   :ref:`LIRC_SET_REC_CARRIER <LIRC_SET_REC_CARRIER>` with the upper bound.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.