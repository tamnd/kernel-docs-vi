.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/NMI-RCU.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _NMI_rcu_doc:

Sử dụng RCU để bảo vệ Trình xử lý NMI động
=========================================


Mặc dù RCU thường được sử dụng để bảo vệ cấu trúc dữ liệu chủ yếu đọc,
có thể sử dụng RCU để cung cấp ngắt động không thể che dấu
trình xử lý cũng như trình xử lý irq động.  Tài liệu này mô tả
cách thực hiện điều này, vẽ lỏng lẻo từ NMI-timer của Zwane Mwaikambo
hoạt động trong phiên bản cũ của "arch/x86/kernel/traps.c".

Các đoạn mã liên quan được liệt kê dưới đây, theo sau mỗi đoạn là một
giải thích ngắn gọn::

int tĩnh dummy_nmi_callback(struct pt_regs *regs, int cpu)
	{
		trả về 0;
	}

Hàm dummy_nmi_callback() là một trình xử lý NMI "giả" thực hiện
không có gì, nhưng trả về 0, do đó nói rằng nó không làm gì cả, cho phép
trình xử lý NMI để thực hiện hành động mặc định dành riêng cho máy::

nmi_callback_t nmi_callback = dummy_nmi_callback tĩnh;

Biến nmi_callback này là một con trỏ hàm toàn cục tới hiện tại
Trình xử lý NMI::

void do_nmi(struct pt_regs * regs, error_code dài)
	{
		intcpu;

nmi_enter();

cpu = smp_processor_id();
		++nmi_count(cpu);

if (!rcu_dereference_sched(nmi_callback)(regs, cpu))
			default_do_nmi(reg);

nmi_exit();
	}

Hàm do_nmi() xử lý từng NMI.  Đầu tiên nó vô hiệu hóa quyền ưu tiên
theo cách tương tự như irq phần cứng, sau đó tăng per-CPU
số lượng NMI.  Sau đó nó gọi trình xử lý NMI được lưu trữ trong nmi_callback
con trỏ hàm  Nếu trình xử lý này trả về 0, do_nmi() sẽ gọi phương thức
default_do_nmi() để xử lý NMI dành riêng cho máy.  Cuối cùng,
quyền ưu tiên được khôi phục.

Về lý thuyết, rcu_dereference_sched() là không cần thiết vì mã này chạy
chỉ có trên i386, theo lý thuyết thì không cần rcu_dereference_sched()
dù sao đi nữa.  Tuy nhiên, trong thực tế nó là một công cụ hỗ trợ tài liệu tốt, đặc biệt
dành cho bất kỳ ai đang cố gắng thực hiện điều gì đó tương tự trên Alpha hoặc trên hệ thống
với trình biên dịch tối ưu hóa tích cực.

Câu đố nhanh:
		Tại sao rcu_dereference_sched() lại cần thiết trên Alpha, vì mã được con trỏ tham chiếu là mã chỉ đọc?

ZZ0000ZZ

Quay lại cuộc thảo luận về NMI và RCU::

void set_nmi_callback(nmi_callback_t gọi lại)
	{
		rcu_sign_pointer(nmi_callback, gọi lại);
	}

Hàm set_nmi_callback() đăng ký trình xử lý NMI.  Lưu ý rằng bất kỳ
dữ liệu được sử dụng bởi lệnh gọi lại phải được khởi tạo -trước-
lệnh gọi tới set_nmi_callback().  Trên các kiến trúc không có trật tự
ghi, rcu_sign_pointer() đảm bảo rằng trình xử lý NMI nhìn thấy
giá trị khởi tạo::

void unset_nmi_callback(void)
	{
		rcu_sign_pointer(nmi_callback, dummy_nmi_callback);
	}

Chức năng này hủy đăng ký trình xử lý NMI, khôi phục bản gốc
dummy_nmi_handler().  Tuy nhiên, cũng có thể có trình xử lý NMI
hiện đang thực thi trên một số CPU khác.  Vì thế chúng ta không thể giải phóng
nâng cấp mọi cấu trúc dữ liệu được trình xử lý NMI cũ sử dụng cho đến khi thực thi
của nó hoàn thành trên tất cả các CPU khác.

Một cách để thực hiện điều này là thông qua sync_rcu(), có lẽ như
sau::

unset_nmi_callback();
	đồng bộ hóa_rcu();
	kfree(my_nmi_data);

Điều này hoạt động vì (kể từ v4.20) chặn sync_rcu() cho đến khi tất cả
CPU hoàn thành mọi đoạn mã bị vô hiệu hóa quyền ưu tiên mà chúng đã có
thực hiện.
Vì trình xử lý NMI vô hiệu hóa quyền ưu tiên, nên sync_rcu() được đảm bảo
không quay lại cho đến khi tất cả các trình xử lý NMI đang diễn ra đều thoát.  Vì thế nó an toàn
để giải phóng dữ liệu của trình xử lý ngay khi sync_rcu() trả về.

Lưu ý quan trọng: để tính năng này hoạt động, kiến trúc được đề cập phải
gọi nmi_enter() và nmi_exit() khi vào và ra NMI tương ứng.

.. _answer_quick_quiz_NMI:

Trả lời câu đố nhanh:
	Tại sao rcu_dereference_sched() lại cần thiết trên Alpha, vì mã được con trỏ tham chiếu là mã chỉ đọc?

Người gọi set_nmi_callback() có thể có
	đã khởi tạo một số dữ liệu sẽ được NMI mới sử dụng
	người xử lý.  Trong trường hợp này, rcu_dereference_sched() sẽ
	là cần thiết, vì nếu không thì CPU đã nhận được NMI
	ngay sau khi trình xử lý mới được đặt có thể thấy con trỏ
	sang trình xử lý NMI mới, nhưng trình xử lý cũ được khởi tạo trước
	phiên bản dữ liệu của trình xử lý.

Câu chuyện đáng buồn tương tự này có thể xảy ra trên các CPU khác khi sử dụng
	một trình biên dịch với khả năng suy đoán giá trị con trỏ linh hoạt
	tối ưu hóa.  (Nhưng làm ơn đừng!)

Quan trọng hơn, rcu_dereference_sched() làm cho nó
	rõ ràng cho người đọc mã rằng con trỏ là
	được bảo vệ bởi RCU-sched.
