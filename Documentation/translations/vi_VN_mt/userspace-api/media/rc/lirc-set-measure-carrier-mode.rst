.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-set-measure-carrier-mode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: RC

.. _lirc_set_measure_carrier_mode:

***********************************
ioctl LIRC_SET_MEASURE_CARRIER_MODE
***********************************

Name
====

LIRC_SET_MEASURE_CARRIER_MODE - enable or disable measure mode

Synopsis
========

.. c:macro:: LIRC_SET_MEASURE_CARRIER_MODE

``int ioctl(int fd, LIRC_SET_MEASURE_CARRIER_MODE, __u32 *enable)``

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    kích hoạt = 1 nghĩa là bật chế độ đo, kích hoạt = 0 nghĩa là tắt chế độ đo
    chế độ.

Sự miêu tả
===========

.. _lirc-mode2-frequency:

Bật hoặc tắt chế độ đo. Nếu được bật, từ khóa tiếp theo
nhấn vào, trình điều khiển sẽ gửi các gói ZZ0000ZZ. Bởi
mặc định điều này nên được tắt.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.