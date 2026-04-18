.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/lockdep-splat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Tấm Lockdep-RCU
=================

Lockdep-RCU đã được thêm vào nhân Linux vào đầu năm 2010
(ZZ0000ZZ Cơ sở này kiểm tra một số thông thường
lạm dụng RCU API, đáng chú ý nhất là sử dụng một trong các rcu_dereference()
gia đình để truy cập vào con trỏ được bảo vệ RCU mà không có sự bảo vệ thích hợp.
Khi phát hiện hành vi lạm dụng như vậy, biểu tượng lockdep-RCU sẽ được phát ra.

Nguyên nhân thông thường của biểu tượng lockdep-RCU là do ai đó truy cập vào
Cấu trúc dữ liệu được bảo vệ RCU mà không có (1) đúng loại
RCU phần quan trọng bên đọc hoặc (2) giữ khóa bên cập nhật bên phải.
Do đó, vấn đề này có thể nghiêm trọng: nó có thể dẫn đến bộ nhớ ngẫu nhiên
ghi đè hoặc tệ hơn.  Tất nhiên có thể có kết quả dương tính giả, điều này
là thế giới thực và tất cả những thứ đó.

Vì vậy, hãy xem một ví dụ về biểu tượng lockdep RCU từ 3.0-rc5, một biểu tượng
đã được sửa từ lâu rồi ::

================================
    WARNING: việc sử dụng RCU đáng ngờ
    -----------------------------
    block/cfq-iosched.c:2776 việc sử dụng rcu_dereference_protected() đáng ngờ!

thông tin khác có thể giúp chúng tôi gỡ lỗi này::

rcu_scheduler_active = 1, debug_locks = 0
    3 ổ khóa được giữ bởi scsi_scan_6/1552:
    #0: (&shost->scan_mutex){+.+.}, tại: [<ffffffff8145efca>]
    scsi_scan_host_selected+0x5a/0x150
    #1: (&eq->sysfs_lock){+.+.}, tại: [<ffffffff812a5032>]
    thang máy_exit+0x22/0x60
    #2: (&(&q->__queue_lock)->rlock){-.-.}, tại: [<ffffffff812b6233>]
    cfq_exit_queue+0x43/0x190

dấu vết ngăn xếp ngược:
    Pid: 1552, comm: scsi_scan_6 Không bị nhiễm độc 3.0.0-rc5 #17
    Theo dõi cuộc gọi:
    [<ffffffff810abb9b>] lockdep_rcu_dereference+0xbb/0xc0
    [<ffffffff812b6139>] __cfq_exit_single_io_context+0xe9/0x120
    [<ffffffff812b626c>] cfq_exit_queue+0x7c/0x190
    [<ffffffff812a5046>] Elevator_exit+0x36/0x60
    [<ffffffff812a802a>] blk_cleanup_queue+0x4a/0x60
    [<ffffffff8145cc09>] scsi_free_queue+0x9/0x10
    [<ffffffff81460944>] __scsi_remove_device+0x84/0xd0
    [<ffffffff8145dca3>] scsi_probe_and_add_lun+0x353/0xb10
    [<ffffffff817da069>] ? error_exit+0x29/0xb0
    [<ffffffff817d98ed>] ? _raw_spin_unlock_irqrestore+0x3d/0x80
    [<ffffffff8145e722>] __scsi_scan_target+0x112/0x680
    [<ffffffff812c690d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
    [<ffffffff817da069>] ? error_exit+0x29/0xb0
    [<ffffffff812bcc60>] ? kobject_del+0x40/0x40
    [<ffffffff8145ed16>] scsi_scan_channel+0x86/0xb0
    [<ffffffff8145f0b0>] scsi_scan_host_selected+0x140/0x150
    [<ffffffff8145f149>] do_scsi_scan_host+0x89/0x90
    [<ffffffff8145f170>] do_scan_async+0x20/0x160
    [<ffffffff8145f150>] ? do_scsi_scan_host+0x90/0x90
    [<ffffffff810975b6>] kthread+0xa6/0xb0
    [<ffffffff817db154>] kernel_thread_helper+0x4/0x10
    [<ffffffff81066430>] ? kết thúc_task_switch+0x80/0x110
    [<ffffffff817d9c04>] ? retint_restore_args+0xe/0xe
    [<ffffffff81097510>] ? __kthread_init_worker+0x70/0x70
    [<ffffffff817db150>] ? gs_change+0xb/0xb

Dòng 2776 của block/cfq-iosched.c trong v3.0-rc5 như sau ::

if (rcu_dereference(ioc->ioc_data) == cic) {

Biểu mẫu này nói rằng nó phải ở dạng vani đơn giản RCU phía đọc quan trọng
nhưng danh sách "thông tin khác" ở trên cho thấy đây không phải là
trường hợp.  Thay vào đó, chúng tôi giữ ba ổ khóa, một trong số đó có thể liên quan đến RCU.
Và có lẽ chiếc khóa đó thực sự bảo vệ được tài liệu tham khảo này.  Nếu vậy thì cách khắc phục
là để thông báo cho RCU, có lẽ bằng cách thay đổi __cfq_exit_single_io_context() thành
lấy cấu trúc request_queue "q" từ cfq_exit_queue() làm đối số,
điều này sẽ cho phép chúng tôi gọi rcu_dereference_protected như sau::

if (rcu_dereference_protected(ioc->ioc_data,
				      lockdep_is_held(&q->queue_lock)) == cic) {

Với thay đổi này, sẽ không có biểu tượng lockdep-RCU nào được phát ra nếu điều này
mã được gọi từ bên trong phần quan trọng phía đọc RCU
hoặc với ->queue_lock được giữ.  Đặc biệt, điều này sẽ ngăn chặn
biểu tượng lockdep-RCU ở trên vì ->queue_lock được giữ (xem #2 trong
danh sách trên).

Mặt khác, có lẽ chúng ta thực sự cần một công cụ quan trọng phía đọc RCU
phần.  Trong trường hợp này, phần quan trọng phải mở rộng việc sử dụng
giá trị trả về từ rcu_dereference(), hoặc ít nhất là cho đến khi có một số giá trị
số lượng tham chiếu tăng lên hoặc một số như vậy.  Một cách để xử lý việc này là
thêm rcu_read_lock() và rcu_read_unlock() như sau ::

rcu_read_lock();
	if (rcu_dereference(ioc->ioc_data) == cic) {
		spin_lock(&ioc->lock);
		rcu_sign_pointer(ioc->ioc_data, NULL);
		spin_unlock(&ioc->lock);
	}
	rcu_read_unlock();

Với thay đổi này, rcu_dereference() luôn nằm trong RCU
phần quan trọng phía đọc, điều này một lần nữa sẽ ngăn chặn
phía trên biểu tượng lockdep-RCU.

Nhưng trong trường hợp cụ thể này, chúng tôi không thực sự hủy đăng ký con trỏ
được trả về từ rcu_dereference().  Thay vào đó, con trỏ đó chỉ được so sánh
tới con trỏ cic, điều đó có nghĩa là rcu_dereference() có thể được thay thế
bởi rcu_access_pointer() như sau ::

if (rcu_access_pointer(ioc->ioc_data) == cic) {

Bởi vì việc gọi rcu_access_pointer() mà không cần bảo vệ là hợp pháp,
thay đổi này cũng sẽ loại bỏ biểu tượng lockdep-RCU ở trên.