.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/tty_port.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========
Cổng TTY
========

.. contents:: :local:

Trình điều khiển TTY nên sử dụng trình trợ giúp struct tty_port càng nhiều càng tốt.
Nếu trình điều khiển triển khai ZZ0000ZZ và
ZZ0001ZZ, họ có thể sử dụng tty_port_open(),
tty_port_close() và tty_port_hangup() tương ứng
Móc ZZ0002ZZ.

Tài liệu tham khảo và chi tiết có trong phần ZZ0000ZZ và ZZ0001ZZ ở phía dưới.

Chức năng cổng TTY
==================

Khởi tạo và hủy diệt
--------------------

.. kernel-doc::  drivers/tty/tty_port.c
   :identifiers: tty_port_init tty_port_destroy
        tty_port_get tty_port_put

Người trợ giúp mở/đóng/gác máy
------------------------------

.. kernel-doc::  drivers/tty/tty_port.c
   :identifiers: tty_port_install tty_port_open tty_port_block_til_ready
        tty_port_close tty_port_close_start tty_port_close_end tty_port_hangup
        tty_port_shutdown

Tái chiết khấu TTY
------------------

.. kernel-doc::  drivers/tty/tty_port.c
   :identifiers: tty_port_tty_get tty_port_tty_set

Người trợ giúp TTY
------------------

.. kernel-doc::  include/linux/tty_port.h
   :identifiers: tty_port_tty_hangup tty_port_tty_vhangup
.. kernel-doc::  drivers/tty/tty_port.c
   :identifiers: tty_port_tty_wakeup

Tín hiệu modem
--------------

.. kernel-doc::  drivers/tty/tty_port.c
   :identifiers: tty_port_carrier_raised tty_port_raise_dtr_rts
        tty_port_lower_dtr_rts

----

Tham khảo cổng TTY
==================

.. kernel-doc:: include/linux/tty_port.h
   :identifiers: tty_port

----

Tham khảo hoạt động cổng TTY
=============================

.. kernel-doc:: include/linux/tty_port.h
   :identifiers: tty_port_operations