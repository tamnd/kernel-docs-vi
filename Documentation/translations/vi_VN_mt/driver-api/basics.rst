.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/basics.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thông tin cơ bản về trình điều khiển
=============

Điểm vào và ra của tài xế
----------------------------

.. kernel-doc:: include/linux/module.h
   :internal:

Bảng thiết bị điều khiển
-------------------

.. kernel-doc:: include/linux/mod_devicetable.h
   :internal:
   :no-identifiers: pci_device_id


Trì hoãn và lên lịch các thói quen
--------------------------------

.. kernel-doc:: include/linux/sched.h
   :internal:

.. kernel-doc:: kernel/sched/core.c
   :export:

.. kernel-doc:: kernel/sched/cpupri.c
   :internal:

.. kernel-doc:: kernel/sched/fair.c
   :internal:

.. kernel-doc:: include/linux/completion.h
   :internal:

Thời gian và thói quen hẹn giờ
-----------------------

.. kernel-doc:: include/linux/jiffies.h
   :internal:

.. kernel-doc:: kernel/time/time.c
   :export:

.. kernel-doc:: kernel/time/timer.c
   :export:

Bộ hẹn giờ có độ phân giải cao
----------------------

.. kernel-doc:: include/linux/ktime.h
   :internal:

.. kernel-doc:: include/linux/hrtimer.h
   :internal:

.. kernel-doc:: kernel/time/hrtimer.c
   :export:

Hàng chờ và sự kiện Wake
---------------------------

.. kernel-doc:: include/linux/wait.h
   :internal:

.. kernel-doc:: kernel/sched/wait.c
   :export:

Chức năng nội bộ
------------------

.. kernel-doc:: kernel/exit.c
   :internal:

.. kernel-doc:: kernel/signal.c
   :internal:

.. kernel-doc:: include/linux/kthread.h
   :internal:

.. kernel-doc:: kernel/kthread.c
   :export:

Đếm tham chiếu
------------------

.. kernel-doc:: include/linux/refcount.h
   :internal:

.. kernel-doc:: lib/refcount.c
   :export:

nguyên tử
-------

.. kernel-doc:: include/linux/atomic/atomic-instrumented.h
   :internal:

.. kernel-doc:: include/linux/atomic/atomic-arch-fallback.h
   :internal:

.. kernel-doc:: include/linux/atomic/atomic-long.h
   :internal:

Thao tác đối tượng hạt nhân
---------------------------

.. kernel-doc:: lib/kobject.c
   :export:

.. kernel-doc:: lib/kobject_uevent.c
   :export:

Chức năng tiện ích hạt nhân
------------------------

.. kernel-doc:: include/linux/array_size.h
   :internal:

.. kernel-doc:: include/linux/container_of.h
   :internal:

.. kernel-doc:: include/linux/kstrtox.h
   :internal:
   :no-identifiers: kstrtol kstrtoul

.. kernel-doc:: include/linux/stddef.h
   :internal:

.. kernel-doc:: include/linux/util_macros.h
   :internal:

.. kernel-doc:: include/linux/wordpart.h
   :internal:

.. kernel-doc:: kernel/printk/printk.c
   :export:
   :no-identifiers: printk

.. kernel-doc:: kernel/panic.c
   :export:

Quản lý tài nguyên thiết bị
--------------------------

.. kernel-doc:: drivers/base/devres.c
   :export:

