.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/preempt-locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================================================
Khóa đúng cách theo hạt nhân có thể ưu tiên: Giữ mã hạt nhân an toàn trước
===========================================================================

:Tác giả: Robert Love <rml@tech9.net>


Giới thiệu
============


Hạt nhân có thể ưu tiên tạo ra các vấn đề khóa mới.  Các vấn đề cũng giống như
những thứ thuộc SMP: đồng thời và truy cập lại.  Rất may, Linux đã ưu tiên
mô hình hạt nhân tận dụng các cơ chế khóa SMP hiện có.  Như vậy hạt nhân
yêu cầu khóa bổ sung rõ ràng cho rất ít trường hợp bổ sung.

Tài liệu này dành cho tất cả các hacker kernel.  Phát triển mã trong kernel
yêu cầu bảo vệ những tình huống này.
 

RULE #1: Cấu trúc dữ liệu Per-CPU cần được bảo vệ rõ ràng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Hai vấn đề tương tự phát sinh. Một đoạn mã ví dụ::

cấu trúc this_needs_locking tux[NR_CPUS];
	tux[smp_processor_id()] = some_value;
	/* nhiệm vụ được ưu tiên ở đây... */
	cái gì đó = tux[smp_processor_id()];

Đầu tiên, vì dữ liệu là trên mỗi CPU nên nó có thể không có khóa SMP rõ ràng, nhưng
yêu cầu nó khác đi.  Thứ hai, khi một nhiệm vụ được ưu tiên cuối cùng được lên lịch lại,
giá trị trước đó của smp_processor_id có thể không bằng giá trị hiện tại.  Bạn phải
bảo vệ những tình huống này bằng cách vô hiệu hóa quyền ưu tiên xung quanh chúng.

Bạn cũng có thể sử dụng put_cpu() và get_cpu(), điều này sẽ vô hiệu hóa quyền ưu tiên.


RULE #2: Trạng thái CPU phải được bảo vệ.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Theo quyền ưu tiên, trạng thái của CPU phải được bảo vệ.  Đây là vòm-
phụ thuộc, nhưng bao gồm các cấu trúc và trạng thái CPU không được bảo toàn trong ngữ cảnh
chuyển đổi.  Ví dụ: trên x86, việc nhập và thoát chế độ FPU hiện là một điều quan trọng
phần phải xảy ra khi quyền ưu tiên bị vô hiệu hóa.  Nghĩ xem điều gì sẽ xảy ra
nếu kernel đang thực thi một lệnh dấu phẩy động và sau đó được ưu tiên.
Hãy nhớ rằng, kernel không lưu trạng thái FPU ngoại trừ các tác vụ của người dùng.  Vì vậy,
theo quyền ưu tiên, sổ đăng ký FPU sẽ được bán cho người trả giá thấp nhất.  Như vậy,
quyền ưu tiên phải được vô hiệu hóa xung quanh các khu vực như vậy.

Lưu ý, một số chức năng FPU đã được ưu tiên an toàn một cách rõ ràng.  Ví dụ,
kernel_fpu_begin và kernel_fpu_end sẽ vô hiệu hóa và kích hoạt quyền ưu tiên.


RULE #3: Việc thu thập và giải phóng khóa phải được thực hiện bởi cùng một tác vụ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Khóa có được trong một tác vụ phải được giải phóng bởi tác vụ tương tự.  Cái này
có nghĩa là bạn không thể làm những việc kỳ quặc như lấy ổ khóa và đi đến
chơi trong khi một tác vụ khác giải phóng nó.  Nếu bạn muốn làm điều gì đó
như thế này, thu thập và giải phóng tác vụ trong cùng một đường dẫn mã và
yêu cầu người gọi đợi một sự kiện bằng tác vụ khác.


Giải pháp
========


Bảo vệ dữ liệu theo quyền ưu tiên đạt được bằng cách vô hiệu hóa quyền ưu tiên đối với
thời gian của vùng quan trọng.

::

preempt_enable() giảm bộ đếm ưu tiên
  preempt_disable() tăng bộ đếm ưu tiên
  giảm preempt_enable_no_resched(), nhưng không ưu tiên ngay lập tức
  preempt_check_resched() nếu cần, hãy lên lịch lại
  preempt_count() trả về bộ đếm ưu tiên

Các chức năng có thể lồng nhau.  Nói cách khác, bạn có thể gọi preempt_disable
n lần trong một đường dẫn mã và quyền ưu tiên sẽ không được kích hoạt lại cho đến lần thứ n
gọi tới preempt_enable.  Các câu lệnh ưu tiên không xác định gì nếu
quyền ưu tiên không được kích hoạt.

Lưu ý rằng bạn không cần phải ngăn chặn quyền ưu tiên một cách rõ ràng nếu bạn đang nắm giữ
mọi khóa hoặc ngắt đều bị vô hiệu hóa, vì quyền ưu tiên bị vô hiệu hóa hoàn toàn
trong những trường hợp đó.

Nhưng hãy nhớ rằng 'irqs bị vô hiệu hóa' về cơ bản là một cách không an toàn
vô hiệu hóa quyền ưu tiên - bất kỳ cond_resched() hoặc cond_resched_lock() nào cũng có thể kích hoạt
lên lịch lại nếu số lượng ưu tiên là 0. Một printk() đơn giản có thể kích hoạt
lên lịch lại. Vì vậy, chỉ sử dụng thuộc tính vô hiệu hóa quyền ưu tiên ngầm này nếu bạn
biết rằng đường dẫn mã bị ảnh hưởng không thực hiện bất kỳ điều nào trong số này. Chính sách tốt nhất là sử dụng
điều này chỉ dành cho mã nguyên tử nhỏ mà bạn đã viết và gọi là không phức tạp
chức năng.

Ví dụ::

cpucache_t ZZ0000ZZ đây là per-CPU */
	preempt_disable();
	cc = cc_data(tìm kiếmp);
	if (cc && cc->avail) {
		__free_block(searchp, cc_entry(cc), cc->avail);
		cc-> sẵn có = 0;
	}
	preempt_enable();
	trả về 0;

Lưu ý rằng các câu lệnh ưu tiên phải bao gồm mọi tham chiếu của
các biến quan trọng.  Một ví dụ khác::

int buf[NR_CPUS];
	set_cpu_val(buf);
	if (buf[smp_processor_id()] == -1) printf(KERN_INFO "wee!\n");
	spin_lock(&buf_lock);
	/* ... */

Mã này không an toàn trước, nhưng hãy xem chúng ta có thể sửa nó dễ dàng như thế nào chỉ bằng cách
di chuyển spin_lock lên hai dòng.


Ngăn chặn quyền ưu tiên bằng cách vô hiệu hóa ngắt
===============================================


Có thể ngăn chặn sự kiện ưu tiên sử dụng local_irq_disable và
local_irq_save.  Lưu ý, khi thực hiện bạn phải hết sức cẩn thận để không gây ra
một sự kiện sẽ đặt need_resched và dẫn đến việc kiểm tra quyền ưu tiên.  Khi nào
nghi ngờ, hãy dựa vào việc khóa hoặc vô hiệu hóa quyền ưu tiên rõ ràng.

Lưu ý rằng việc vô hiệu hóa ngắt 2.5 hiện chỉ áp dụng cho mỗi CPU (ví dụ: cục bộ).

Một mối quan tâm nữa là việc sử dụng local_irq_disable và local_irq_save đúng cách.
Tuy nhiên, những điều này có thể được sử dụng để bảo vệ khỏi sự ưu tiên, khi thoát ra, nếu sự ưu tiên
có thể được kích hoạt, nên tiến hành kiểm tra xem có cần thực hiện quyền ưu tiên hay không.  Nếu
chúng được gọi từ macro khóa spin_lock và đọc/ghi, điều đúng đắn
đã xong.  Tuy nhiên, chúng cũng có thể được gọi trong vùng được bảo vệ bằng khóa xoay,
nếu chúng được gọi bên ngoài bối cảnh này, thì việc kiểm tra quyền ưu tiên sẽ
được thực hiện. Xin lưu ý rằng các lệnh gọi từ ngữ cảnh ngắt hoặc nửa dưới/tác vụ
cũng được bảo vệ bằng khóa ưu tiên và do đó có thể sử dụng các phiên bản có
không kiểm tra quyền ưu tiên.
