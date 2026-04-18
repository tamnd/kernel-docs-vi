.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-set-wideband-receiver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: RC

.. _lirc_set_wideband_receiver:

*******************************
ioctl LIRC_SET_WIDEBAND_RECEIVER
********************************

Tên
====

LIRC_SET_WIDEBAND_RECEIVER - cho phép thu băng rộng.

Tóm tắt
========

.. c:macro:: LIRC_SET_WIDEBAND_RECEIVER

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    kích hoạt = 1 có nghĩa là kích hoạt bộ thu băng rộng, kích hoạt = 0 có nghĩa là vô hiệu hóa
    máy thu băng rộng.

Sự miêu tả
===========

Một số máy thu được trang bị máy thu băng rộng đặc biệt.
dự định sẽ được sử dụng để tìm hiểu đầu ra của điều khiển từ xa hiện có. ioctl này
cho phép kích hoạt hoặc vô hiệu hóa nó.

Điều này có thể hữu ích với các máy thu có máy thu băng tần hẹp.
điều đó ngăn cản việc sử dụng chúng với một số điều khiển từ xa. Máy thu băng rộng có thể
cũng chính xác hơn. Mặt khác nhược điểm của nó là nó thường
giảm phạm vi tiếp nhận.

.. note::

    Wide band receiver might be implicitly enabled if you enable
    carrier reports. In that case it will be disabled as soon as you disable
    carrier reports. Trying to disable wide band receiver while carrier
    reports are active will do nothing.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.