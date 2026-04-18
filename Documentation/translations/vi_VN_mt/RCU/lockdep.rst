.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/lockdep.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Kiểm tra RCU và lockdep
========================

Tất cả các phiên bản của RCU đều có tính năng kiểm tra lockdep, vì vậy lockdep là
nhận thức được thời điểm mỗi tác vụ được thực hiện và để lại bất kỳ hương vị nào của phần đọc RCU
phần quan trọng.  Mỗi hương vị của RCU được theo dõi riêng biệt (nhưng lưu ý
rằng đây không phải là trường hợp trong 2.6.32 trở về trước).  Điều này cho phép lockdep's
theo dõi để bao gồm trạng thái RCU, đôi khi có thể hữu ích khi gỡ lỗi
bế tắc và những thứ tương tự.

Ngoài ra, RCU còn cung cấp các nguyên hàm sau để kiểm tra lockdep
tiểu bang::

rcu_read_lock_held() cho RCU bình thường.
	rcu_read_lock_bh_held() cho RCU-bh.
	rcu_read_lock_sched_held() dành cho RCU-sched.
	rcu_read_lock_any_held() cho bất kỳ RCU, RCU-bh và RCU-schede thông thường nào.
	srcu_read_lock_held() cho SRCU.
	rcu_read_lock_trace_held() cho Dấu vết nhiệm vụ RCU.

Các hàm này là bảo thủ và do đó sẽ trả về 1 nếu chúng
không chắc chắn (ví dụ: nếu CONFIG_DEBUG_LOCK_ALLOC không được đặt).
Điều này ngăn những thứ như WARN_ON(!rcu_read_lock_held()) đưa ra kết quả sai
tích cực khi lockdep bị vô hiệu hóa.

Ngoài ra, tham số cấu hình kernel riêng CONFIG_PROVE_RCU cho phép
kiểm tra nguyên hàm rcu_dereference():

rcu_dereference(p):
		Kiểm tra phần quan trọng phía đọc RCU.
	rcu_dereference_bh(p):
		Kiểm tra phần quan trọng phía đọc RCU-bh.
	rcu_dereference_sched(p):
		Kiểm tra phần quan trọng phía đọc được lập lịch trình RCU.
	srcu_dereference(p, sp):
		Kiểm tra phần quan trọng phía đọc SRCU.
	rcu_dereference_check(p, c):
		Sử dụng biểu thức kiểm tra rõ ràng "c" cùng với
		rcu_read_lock_held().  Điều này rất hữu ích trong mã
		được gọi bởi cả trình đọc và trình cập nhật RCU.
	rcu_dereference_bh_check(p, c):
		Sử dụng biểu thức kiểm tra rõ ràng "c" cùng với
		rcu_read_lock_bh_held().  Điều này rất hữu ích trong mã
		được gọi bởi cả trình đọc và trình cập nhật RCU-bh.
	rcu_dereference_sched_check(p, c):
		Sử dụng biểu thức kiểm tra rõ ràng "c" cùng với
		rcu_read_lock_sched_held().  Điều này rất hữu ích trong mã
		được gọi bởi cả trình đọc và trình cập nhật theo lịch trình RCU.
	srcu_dereference_check(p, c):
		Sử dụng biểu thức kiểm tra rõ ràng "c" cùng với
		srcu_read_lock_held().  Điều này rất hữu ích trong mã
		được gọi bởi cả trình đọc và trình cập nhật SRCU.
	rcu_dereference_raw(p):
		Đừng kiểm tra.  (Sử dụng một cách tiết kiệm, nếu có.)
	rcu_dereference_raw_check(p):
		Đừng làm lockdep gì cả.  (Sử dụng một cách tiết kiệm, nếu có.)
	rcu_dereference_protected(p, c):
		Sử dụng biểu thức kiểm tra rõ ràng "c" và bỏ qua mọi rào cản
		và các ràng buộc của trình biên dịch.  Điều này rất hữu ích khi dữ liệu
		cấu trúc không thể thay đổi, ví dụ như trong mã
		chỉ được gọi bởi các trình cập nhật.
	rcu_access_pointer(p):
		Trả về giá trị của con trỏ và bỏ qua mọi rào cản,
		nhưng vẫn giữ lại các ràng buộc của trình biên dịch nhằm tránh việc sao chép
		hoặc kết tụ.  Điều này rất hữu ích khi kiểm tra
		giá trị của chính con trỏ, ví dụ, so với NULL.

Biểu thức kiểm tra rcu_dereference_check() có thể là bất kỳ boolean nào
biểu thức, nhưng thường sẽ bao gồm biểu thức lockdep.  Đối với một
ví dụ trang trí công phu vừa phải, hãy xem xét những điều sau::

tập tin = rcu_dereference_check(fdt->fd[fd],
				     lockdep_is_held(&files->file_lock) ||
				     Atomic_read(&files->count) == 1);

Biểu thức này chọn con trỏ "fdt->fd[fd]" theo cách an toàn RCU,
và nếu CONFIG_PROVE_RCU được định cấu hình, hãy xác minh rằng biểu thức này
được sử dụng trong:

1. Phần quan trọng phía đọc RCU (ngầm) hoặc
2. với các tập tin->file_lock được giữ hoặc
3. trên một file_struct không được chia sẻ.

Trong trường hợp (1), con trỏ được chọn theo cách an toàn RCU cho vanilla
Các phần quan trọng phía đọc RCU, trong trường hợp (2) ->file_lock ngăn cản
bất kỳ thay đổi nào diễn ra và cuối cùng, trong trường hợp (3) nhiệm vụ hiện tại
là tác vụ duy nhất truy cập vào file_struct, một lần nữa ngăn chặn mọi thay đổi
từ khi diễn ra.  Nếu câu lệnh trên chỉ được gọi từ trình cập nhật
mã, thay vào đó nó có thể được viết như sau::

tập tin = rcu_dereference_protected(fdt->fd[fd],
					 lockdep_is_held(&files->file_lock) ||
					 Atomic_read(&files->count) == 1);

Điều này sẽ xác minh các trường hợp #2 và #3 ở trên, và hơn nữa lockdep sẽ
khiếu nại ngay cả khi điều này được sử dụng trong phần quan trọng bên đọc RCU trừ khi
một trong hai trường hợp này được tổ chức.  Bởi vì rcu_dereference_protected() bỏ qua
tất cả các rào cản và ràng buộc của trình biên dịch, nó tạo ra mã tốt hơn
các hương vị khác của rcu_dereference().  Mặt khác, nó là bất hợp pháp
để sử dụng rcu_dereference_protected() nếu con trỏ được bảo vệ RCU
hoặc dữ liệu được bảo vệ RCU mà nó trỏ tới có thể thay đổi đồng thời.

Giống như rcu_dereference(), khi lockdep được bật, danh sách và hlist RCU
nguyên thủy truyền tải kiểm tra xem có được gọi từ bên trong RCU không
phần quan trọng.  Tuy nhiên, một biểu thức lockdep có thể được truyền cho họ
như một đối số tùy chọn bổ sung.  Với biểu thức lockdep này, những
nguyên thủy truyền tải sẽ chỉ phàn nàn nếu biểu thức lockdep là
sai và chúng được gọi từ bên ngoài bất kỳ phần quan trọng nào của phía đọc RCU.

Ví dụ: macro công việc for_each_pwq() dự định sẽ được sử dụng
trong phần quan trọng phía đọc RCU hoặc với wq->mutex được giữ.
Do đó, nó được thực hiện như sau::

#define for_each_pwq(pwq, wq)
		list_for_each_entry_rcu((pwq), &(wq)->pwqs, pwqs_node,
					lock_is_held(&(wq->mutex).dep_map))