.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-set-rec-timeout.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: RC

.. _lirc_set_rec_timeout:
.. _lirc_get_rec_timeout:

****************************************************
ioctl LIRC_GET_REC_TIMEOUT và LIRC_SET_REC_TIMEOUT
***************************************************

Tên
====

LIRC_GET_REC_TIMEOUT/LIRC_SET_REC_TIMEOUT - Nhận/đặt giá trị số nguyên cho thời gian chờ không hoạt động IR.

Tóm tắt
========

.. c:macro:: LIRC_GET_REC_TIMEOUT

ZZ0000ZZ

.. c:macro:: LIRC_SET_REC_TIMEOUT

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Thời gian chờ, tính bằng micro giây.

Sự miêu tả
===========

Nhận và đặt giá trị số nguyên cho thời gian chờ IR không hoạt động.

Nếu được phần cứng hỗ trợ, việc đặt thành 0 sẽ tắt tất cả thời gian chờ của phần cứng
và dữ liệu phải được báo cáo càng sớm càng tốt. Nếu giá trị chính xác
không thể được đặt thì giá trị có thể tiếp theo _lớn_ hơn giá trị
giá trị nhất định phải được đặt.

.. note::

   The range of supported timeout is given by :ref:`LIRC_GET_MIN_TIMEOUT`.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.