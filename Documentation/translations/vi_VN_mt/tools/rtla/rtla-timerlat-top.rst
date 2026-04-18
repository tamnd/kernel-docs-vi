.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/tools/rtla/rtla-timerlat-top.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. |tool| replace:: timerlat top

======================
rtla-timerlat-top
====================
-------------------------------------------
Đo độ trễ hẹn giờ của hệ điều hành
-------------------------------------------

:Phần hướng dẫn sử dụng: 1

SYNOPSIS
========
ZZ0000ZZ [ZZ0001ZZ] ...

DESCRIPTION
===========

.. include:: common_timerlat_description.txt

ZZ0000ZZ hiển thị bản tóm tắt đầu ra định kỳ
từ thiết bị theo dõi ZZ0003ZZ. Nó cũng cung cấp thông tin cho từng
tiếng ồn của hệ điều hành thông qua các điểm theo dõi ZZ0001ZZ có thể được
được thấy với tùy chọn ZZ0002ZZ.

OPTIONS
=======

.. include:: common_timerlat_options.txt

.. include:: common_top_options.txt

.. include:: common_options.txt

.. include:: common_timerlat_aa.txt

ZZ0000ZZ ZZ0001ZZ

Đặt điều kiện dừng theo dõi và chạy mà không thu thập và hiển thị số liệu thống kê.
        In bản phân tích tự động nếu hệ thống đạt đến điều kiện dừng theo dõi. Tùy chọn này
        rất hữu ích để giảm rtla timelat CPU, cho phép gỡ lỗi mà không cần tốn phí
        thu thập số liệu thống kê.

EXAMPLE
=======

Trong ví dụ bên dưới, bộ theo dõi timelat được gửi đi trong CPU ZZ0000ZZ trong
chế độ theo dõi tự động, hướng dẫn bộ theo dõi dừng nếu độ trễ ZZ0001ZZ hoặc
cao hơn được tìm thấy::

# timerlat -a 40 -c 1-23 -q
                                     Độ trễ hẹn giờ
    0 00:00:12 ZZ0000ZZ Độ trễ hẹn giờ chủ đề (chúng tôi)
  CPU COUNT ZZ0001ZZ tối thiểu trung bình tối đa
    1 #12322 ZZ0002ZZ 10 3 9 31
    2 #12322 ZZ0003ZZ 10 3 9 23
    3 #12322 ZZ0004ZZ 8 2 8 34
    4 #12322 ZZ0005ZZ 10 2 11 33
    5 #12322 ZZ0006ZZ 8 3 8 25
    6 #12322 ZZ0007ZZ 16 3 11 35
    7 #12322 ZZ0008ZZ 9 2 8 29
    8 #12322 ZZ0009ZZ 9 3 9 34
    9 #12322 ZZ0010ZZ 8 2 8 24
   10 #12322 ZZ0011ZZ 9 3 8 24
   11 #12322 ZZ0012ZZ 6 2 7 29
   12 #12321 ZZ0013ZZ 5 3 8 23
   13 #12319 ZZ0014ZZ 9 3 9 26
   14 #12321 ZZ0015ZZ 6 2 8 24
   15 #12321 ZZ0016ZZ 12 3 11 27
   16 #12318 ZZ0017ZZ 7 3 10 24
   17 #12319 ZZ0018ZZ 11 3 9 25
   18 #12318 ZZ0019ZZ 8 2 8 20
   19 #12319 ZZ0020ZZ 10 2 9 28
   20 #12317 ZZ0021ZZ 9 3 8 34
   21 #12318 ZZ0022ZZ 8 3 8 28
   22 #12319 ZZ0023ZZ 8 3 10 22
   23 #12320 ZZ0024ZZ 41 3 11 41
  rtla timelat nhấn dừng theo dõi
  ## ZZ0052ZZ 23 lần truy tìm điểm dừng, phân tích nó ##
  ZZ0053ZZ độ trễ của trình xử lý: 27,49 us (65,52 %)
  Độ trễ IRQ: 28,13 us
  Thời lượng của Timelat IRQ: 9,59 us (22,85 %)
  Chủ đề chặn: 3,79 us (9,03 %)
                         objtool:49256 3,79 chúng tôi
    Chặn ngăn xếp luồng
                -> bộ đếm thời gian_irq
                -> __hrtimer_run_queues
                -> hrtimer_interrupt
                -> __sysvec_apic_timer_interrupt
                -> sysvec_apic_timer_interrupt
                -> asm_sysvec_apic_timer_interrupt
                -> _raw_spin_unlock_irqrestore
                -> cgroup_rstat_flush_locked
                -> cgroup_rstat_flush_irqsafe
                -> mem_cgroup_flush_stats
                -> mem_cgroup_wb_stats
                -> Balance_dirty_pages
                -> Balance_dirty_pages_ratelimited_flags
                -> btrfs_buffered_write
                -> btrfs_do_write_iter
                -> vfs_write
                -> __x64_sys_pwrite64
                -> do_syscall_64
                -> entry_SYSCALL_64_after_hwframe
  -------------------------------------------------------------------------
    Độ trễ luồng: 41,96 us (100%)

Hệ thống đã thoát khỏi độ trễ nhàn rỗi!
    Độ trễ IRQ tối đa của bộ đếm thời gian từ lúc không hoạt động: 17,48 us trong cpu 4
  Lưu dấu vết vào timelat_trace.txt

Trong trường hợp này, yếu tố chính là độ trễ của ZZ0001ZZ
xử lý việc đánh thức ZZ0000ZZ: ZZ0002ZZ. Điều này có thể được gây ra bởi
các ngắt che dấu luồng hiện tại, có thể được nhìn thấy trong phần chặn
thread stacktrace: luồng hiện tại (ZZ0003ZZ) bị ngắt
thông qua các hoạt động ZZ0004ZZ bên trong nhóm mem, trong khi thực hiện ghi
syscall trong hệ thống tệp btrfs.

Dấu vết thô được lưu trong tệp ZZ0000ZZ để phân tích thêm.

Lưu ý rằng ZZ0000ZZ đã được gửi đi mà không thay đổi chất đánh dấu ZZ0001ZZ
mức độ ưu tiên của chủ đề. Điều đó thường không cần thiết vì những chủ đề này có
ưu tiên ZZ0002ZZ theo mặc định, đây là mức ưu tiên phổ biến được sử dụng theo thời gian thực
các nhà phát triển hạt nhân để phân tích sự chậm trễ trong việc lập kế hoạch.

SEE ALSO
--------
ZZ0000ZZ\(1), ZZ0001ZZ\(1)

ZZ0000ZZ

AUTHOR
------
Viết bởi Daniel Bristot de Oliveira <bristot@kernel.org>

.. include:: common_appendix.txt
