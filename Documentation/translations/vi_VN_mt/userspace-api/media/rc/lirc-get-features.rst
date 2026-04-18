.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-get-features.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: RC

.. _lirc_get_features:

***********************
ioctl LIRC_GET_FEATURES
***********************

Tên
====

LIRC_GET_FEATURES - Nhận các tính năng của thiết bị phần cứng cơ bản

Tóm tắt
========

.. c:macro:: LIRC_GET_FEATURES

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp được trả về bởi open().

ZZ0000ZZ
    Bitmask với các tính năng LIRC.

Sự miêu tả
===========

Nhận các tính năng của thiết bị phần cứng cơ bản. Nếu người lái xe không
thông báo hỗ trợ một số tính năng nhất định, gọi ioctls tương ứng
không được xác định.

Tính năng LIRC
=============

.. _LIRC-CAN-REC-RAW:

ZZ0000ZZ

Chưa sử dụng. Giữ chỉ để tránh phá vỡ uAPI.

.. _LIRC-CAN-REC-PULSE:

ZZ0000ZZ

Chưa sử dụng. Giữ chỉ để tránh phá vỡ uAPI.
    ZZ0000ZZ chỉ có thể được sử dụng để truyền.

.. _LIRC-CAN-REC-MODE2:

ZZ0000ZZ

Đây là trình điều khiển IR thô để nhận. Điều này có nghĩa là
    ZZ0000ZZ được sử dụng. Điều này cũng hàm ý
    ZZ0001ZZ cũng được hỗ trợ,
    miễn là kernel đủ mới. Sử dụng
    ZZ0002ZZ để chuyển đổi chế độ.

.. _LIRC-CAN-REC-LIRCCODE:

ZZ0000ZZ

Chưa sử dụng. Giữ chỉ để tránh phá vỡ uAPI.

.. _LIRC-CAN-REC-SCANCODE:

ZZ0000ZZ

Đây là trình điều khiển scancode để nhận. Điều này có nghĩa là
    ZZ0000ZZ được sử dụng.

.. _LIRC-CAN-SET-SEND-CARRIER:

ZZ0000ZZ

Trình điều khiển hỗ trợ thay đổi tần số điều chế thông qua
    ZZ0000ZZ.

.. _LIRC-CAN-SET-SEND-DUTY-CYCLE:

ZZ0000ZZ

Trình điều khiển hỗ trợ thay đổi chu kỳ làm việc bằng cách sử dụng
    ZZ0000ZZ.

.. _LIRC-CAN-SET-TRANSMITTER-MASK:

ZZ0000ZZ

    The driver supports changing the active transmitter(s) using
    :ref:`ioctl LIRC_SET_TRANSMITTER_MASK <LIRC_SET_TRANSMITTER_MASK>`.

.. _LIRC-CAN-SET-REC-CARRIER:

``LIRC_CAN_SET_REC_CARRIER``

    The driver supports setting the receive carrier frequency using
    :ref:`ioctl LIRC_SET_REC_CARRIER <LIRC_SET_REC_CARRIER>`.

.. _LIRC-CAN-SET-REC-CARRIER-RANGE:

``LIRC_CAN_SET_REC_CARRIER_RANGE``

    The driver supports
    :ref:`ioctl LIRC_SET_REC_CARRIER_RANGE <LIRC_SET_REC_CARRIER_RANGE>`.

.. _LIRC-CAN-GET-REC-RESOLUTION:

``LIRC_CAN_GET_REC_RESOLUTION``

    The driver supports
    :ref:`ioctl LIRC_GET_REC_RESOLUTION <LIRC_GET_REC_RESOLUTION>`.

.. _LIRC-CAN-SET-REC-TIMEOUT:

``LIRC_CAN_SET_REC_TIMEOUT``

    The driver supports
    :ref:`ioctl LIRC_SET_REC_TIMEOUT <LIRC_SET_REC_TIMEOUT>`.

.. _LIRC-CAN-MEASURE-CARRIER:

ZZ0000ZZ

Trình điều khiển hỗ trợ đo tần số điều chế bằng cách sử dụng
    ZZ0000ZZ.

.. _LIRC-CAN-USE-WIDEBAND-RECEIVER:

ZZ0000ZZ

Trình điều khiển hỗ trợ chế độ học tập bằng cách sử dụng
    ZZ0000ZZ.

.. _LIRC-CAN-SEND-RAW:

ZZ0000ZZ

Chưa sử dụng. Giữ chỉ để tránh phá vỡ uAPI.

.. _LIRC-CAN-SEND-PULSE:

ZZ0000ZZ

Trình điều khiển hỗ trợ gửi (còn gọi là IR blasting hoặc IR TX) bằng cách sử dụng
    ZZ0000ZZ. Điều này ngụ ý rằng
    ZZ0001ZZ cũng được hỗ trợ cho
    truyền đi, miễn là kernel đủ mới. Sử dụng
    ZZ0002ZZ để chuyển đổi chế độ.

.. _LIRC-CAN-SEND-MODE2:

ZZ0000ZZ

Chưa sử dụng. Giữ chỉ để tránh phá vỡ uAPI.
    ZZ0000ZZ chỉ có thể được sử dụng để nhận.

.. _LIRC-CAN-SEND-LIRCCODE:

ZZ0000ZZ

Chưa sử dụng. Giữ chỉ để tránh phá vỡ uAPI.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.