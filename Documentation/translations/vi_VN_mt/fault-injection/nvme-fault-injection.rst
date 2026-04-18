.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fault-injection/nvme-fault-injection.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Tiêm lỗi NVMe
====================
Khung tiêm lỗi của Linux cung cấp một cách có hệ thống để hỗ trợ
chèn lỗi thông qua debugfs trong thư mục /sys/kernel/debug. Khi nào
được bật, NVME_SC_INVALID_OPCODE mặc định không thử lại sẽ là
được đưa vào nvme_try_complete_req. Người dùng có thể thay đổi trạng thái mặc định
mã và không có cờ thử lại thông qua debugfs. Danh sách lệnh chung
Trạng thái có thể được tìm thấy trong include/linux/nvme.h

Các ví dụ sau đây cho thấy cách đưa lỗi vào nvme.

Đầu tiên, kích hoạt cấu hình kernel CONFIG_FAULT_INJECTION_DEBUG_FS,
biên dịch lại kernel. Sau khi khởi động kernel, hãy thực hiện
theo dõi.

Ví dụ 1: Chèn mã trạng thái mặc định mà không cần thử lại
---------------------------------------------------

::

gắn kết/dev/nvme0n1/mnt
  echo 1 > /sys/kernel/debug/nvme0n1/fault_inject/times
  echo 100 > /sys/kernel/debug/nvme0n1/fault_inject/xác suất
  cp a.file /mnt

Kết quả mong đợi::

cp: không thể stat ‘/mnt/a.file’: Lỗi đầu vào/đầu ra

Tin nhắn từ dmesg::

FAULT_INJECTION: buộc phải thất bại.
  tên error_inject, khoảng 1, xác suất 100, khoảng trắng 0, lần 1
  CPU: 0 PID: 0 Comm: bộ trao đổi/0 Không bị nhiễm bẩn 4.15.0-rc8+ #2
  Tên phần cứng: innotek GmbH VirtualBox/VirtualBox,
  BIOS VirtualBox 01/12/2006
  Theo dõi cuộc gọi:
    <IRQ>
    dump_stack+0x5c/0x7d
    nên_fail+0x148/0x170
    nvme_ Should_fail+0x2f/0x50 [nvme_core]
    nvme_process_cq+0xe7/0x1d0 [nvme]
    nvme_irq+0x1e/0x40 [nvme]
    __handle_irq_event_percpu+0x3a/0x190
    xử lý_irq_event_percpu+0x30/0x70
    hand_irq_event+0x36/0x60
    xử lý_fasteoi_irq+0x78/0x120
    xử lý_irq+0xa7/0x130
    ? tick_irq_enter+0xa8/0xc0
    do_IRQ+0x43/0xc0
    common_interrupt+0xa2/0xa2
    </IRQ>
  RIP: 0010:native_safe_halt+0x2/0x10
  RSP: 0018:ffffffff82003e90 EFLAGS: 00000246 ORIG_RAX: ffffffffffffffdd
  RAX: ffffffff817a10c0 RBX: ffffffff82012480 RCX: 00000000000000000
  RDX: 0000000000000000 RSI: 00000000000000000 RDI: 0000000000000000
  RBP: 00000000000000000 R08: 000000008e38ce64 R09: 0000000000000000
  R10: 0000000000000000 R11: 00000000000000000 R12: ffffffff82012480
  R13: ffffffff82012480 R14: 0000000000000000 R15: 00000000000000000
    ? __sched_text_end+0x4/0x4
    default_idle+0x18/0xf0
    do_idle+0x150/0x1d0
    cpu_startup_entry+0x6f/0x80
    start_kernel+0x4c4/0x4e4
    ? set_init_arg+0x55/0x55
    thứ cấp_startup_64+0xa5/0xb0
    print_req_error: Lỗi I/O, dev nvme0n1, khu vực 9240
  Lỗi EXT4-fs (thiết bị nvme0n1): ext4_find_entry:1436:
  inode #2: comm cp: đọc thư mục lblock 0

Ví dụ 2: Chèn mã trạng thái mặc định bằng thử lại
------------------------------------------------

::

gắn kết/dev/nvme0n1/mnt
  echo 1 > /sys/kernel/debug/nvme0n1/fault_inject/times
  echo 100 > /sys/kernel/debug/nvme0n1/fault_inject/xác suất
  echo 1 > /sys/kernel/debug/nvme0n1/fault_inject/status
  echo 0 > /sys/kernel/debug/nvme0n1/fault_inject/dont_retry

cp a.file /mnt

Kết quả mong đợi::

lệnh thành công không có lỗi

Tin nhắn từ dmesg::

FAULT_INJECTION: buộc phải thất bại.
  tên error_inject, khoảng 1, xác suất 100, khoảng trắng 0, lần 1
  CPU: 1 PID: 0 Comm: bộ trao đổi/1 Không bị nhiễm độc 4.15.0-rc8+ #4
  Tên phần cứng: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 01/12/2006
  Theo dõi cuộc gọi:
    <IRQ>
    dump_stack+0x5c/0x7d
    nên_fail+0x148/0x170
    nvme_ Should_fail+0x30/0x60 [nvme_core]
    nvme_loop_queue_response+0x84/0x110 [nvme_loop]
    nvmet_req_complete+0x11/0x40 [nvmet]
    nvmet_bio_done+0x28/0x40 [nvmet]
    blk_update_request+0xb0/0x310
    blk_mq_end_request+0x18/0x60
    Flush_smp_call_function_queue+0x3d/0xf0
    smp_call_function_single_interrupt+0x2c/0xc0
    call_function_single_interrupt+0xa2/0xb0
    </IRQ>
  RIP: 0010:native_safe_halt+0x2/0x10
  RSP: 0018:ffffc9000068bec0 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff04
  RAX: ffffffff817a10c0 RBX: ffff88011a3c9680 RCX: 00000000000000000
  RDX: 0000000000000000 RSI: 00000000000000000 RDI: 0000000000000000
  RBP: 00000000000000001 R08: 000000008e38c131 R09: 0000000000000000
  R10: 0000000000000000 R11: 00000000000000000 R12: ffff88011a3c9680
  R13: ffff88011a3c9680 R14: 0000000000000000 R15: 0000000000000000
    ? __sched_text_end+0x4/0x4
    default_idle+0x18/0xf0
    do_idle+0x150/0x1d0
    cpu_startup_entry+0x6f/0x80
    start_secondary+0x187/0x1e0
    thứ cấp_startup_64+0xa5/0xb0

Ví dụ 3: Chèn lỗi vào lệnh quản trị viên thứ 10
------------------------------------------------------

::

echo 100 > /sys/kernel/debug/nvme0/fault_inject/xác suất
  echo 10 > /sys/kernel/debug/nvme0/fault_inject/space
  echo 1 > /sys/kernel/debug/nvme0/fault_inject/times
  thiết lập lại nvme/dev/nvme0

Kết quả mong đợi::

Sau khi đặt lại bộ điều khiển NVMe, quá trình khởi tạo lại có thể thành công hoặc không.
  Nó phụ thuộc vào lệnh quản trị nào thực sự bị buộc phải thất bại.

Tin nhắn từ dmesg::

nvme nvme0: đặt lại bộ điều khiển
  FAULT_INJECTION: buộc phải thất bại.
  tên error_inject, khoảng 1, xác suất 100, khoảng trắng 1, lần 1
  CPU: 0 PID: 0 Comm: bộ chuyển đổi/0 Không bị nhiễm bẩn 5.2.0-rc2+ #2
  Tên phần cứng: MSI MS-7A45/B150M MORTAR ARCTIC (MS-7A45), BIOS 1.50 25/04/2017
  Theo dõi cuộc gọi:
   <IRQ>
   dump_stack+0x63/0x85
   nên_fail+0x14a/0x170
   nvme_ Should_fail+0x38/0x80 [nvme_core]
   nvme_irq+0x129/0x280 [nvme]
   ? blk_mq_end_request+0xb3/0x120
   __handle_irq_event_percpu+0x84/0x1a0
   xử lý_irq_event_percpu+0x32/0x80
   hand_irq_event+0x3b/0x60
   xử lý_edge_irq+0x7f/0x1a0
   xử lý_irq+0x20/0x30
   do_IRQ+0x4e/0xe0
   common_interrupt+0xf/0xf
   </IRQ>
  RIP: 0010:cpuidle_enter_state+0xc5/0x460
  Mã: ff e8 8f 5f 86 ff 80 7d c7 00 74 17 9c 58 0f 1f 44 00 00 f6 c4 02 0f 85 69 03 00 00 31 ff e8 62 aa 8c ff fb 66 0f 1f 44 00 00 <45> 85 ed 0f 88 37 03 00 00 4c 8b 45 d0 4c 2b 45 b8 48 ba cf f7 53
  RSP: 0018:ffffffff88c03dd0 EFLAGS: 00000246 ORIG_RAX: ffffffffffffffdc
  RAX: ffff9dac25a2ac80 RBX: ffffffff88d53760 RCX: 0000000000000001f
  RDX: 0000000000000000 RSI: 000000002d958403 RDI: 0000000000000000
  RBP: ffffffff88c03e18 R08: fffffff75e35ffb7 R09: 00000a49a56c0b48
  R10: ffffffff88c03da0 R11: 0000000000001b0c R12: ffff9dac25a34d00
  R13: 0000000000000006 R14: 00000000000000006 R15: ffffffff88d53760
   cpuidle_enter+0x2e/0x40
   call_cpuidle+0x23/0x40
   do_idle+0x201/0x280
   cpu_startup_entry+0x1d/0x20
   phần còn lại_init+0xaa/0xb0
   Arch_call_rest_init+0xe/0x1b
   start_kernel+0x51c/0x53b
   x86_64_start_reservations+0x24/0x26
   x86_64_start_kernel+0x74/0x77
   thứ cấp_startup_64+0xa4/0xb0
  nvme nvme0: Không thể đặt số lượng hàng đợi (16385)
  nvme nvme0: Hàng đợi IO chưa được tạo
