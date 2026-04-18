.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/listRCU.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _list_rcu_doc:

Sử dụng RCU để bảo vệ danh sách liên kết đọc chủ yếu
=============================================

Một trong những cách sử dụng phổ biến nhất của RCU là bảo vệ các danh sách liên kết đọc chủ yếu
(ZZ0000ZZ trong danh sách.h).  Một ưu điểm lớn của phương pháp này là
rằng tất cả thứ tự bộ nhớ cần thiết đều được cung cấp bởi macro danh sách.
Tài liệu này mô tả một số trường hợp sử dụng RCU dựa trên danh sách.

Khi lặp lại một danh sách trong khi giữ rcu_read_lock(), người viết có thể
sửa đổi danh sách.  Người đọc được đảm bảo nhìn thấy tất cả các yếu tố
đã được thêm vào danh sách trước khi họ có được rcu_read_lock()
và vẫn còn trong danh sách khi họ thả rcu_read_unlock().
Các phần tử được thêm vào hoặc xóa khỏi danh sách có thể có hoặc không
được nhìn thấy.  Nếu người viết gọi list_replace_rcu(), người đọc có thể thấy
phần tử cũ hoặc phần tử mới; họ sẽ không nhìn thấy cả hai,
họ cũng sẽ không nhìn thấy.


Ví dụ 1: Danh sách đọc chủ yếu: Phá hủy hoãn lại
-------------------------------------------------

Một usecase được sử dụng rộng rãi cho danh sách RCU trong kernel là phép lặp không khóa
tất cả các tiến trình trong hệ thống. ZZ0000ZZ đại diện cho nút danh sách
liên kết tất cả các quá trình. Danh sách có thể được duyệt song song với bất kỳ danh sách nào
bổ sung hoặc loại bỏ.

Việc duyệt danh sách được thực hiện bằng ZZ0000ZZ được xác định
bởi 2 macro::

#define next_task(p) \
		list_entry_rcu((p)->tasks.next, struct task_struct, task)

#define for_each_process(p) \
		cho (p = &init_task ; (p = next_task(p)) != &init_task ; )

Mã duyệt qua danh sách tất cả các quy trình thường trông giống như::

rcu_read_lock();
	for_each_process(p) {
		/* Làm gì đó với p */
	}
	rcu_read_unlock();

Mã được đơn giản hóa và được nội tuyến nhiều để xóa một quy trình khỏi một
danh sách nhiệm vụ là::

void Release_task(struct task_struct *p)
	{
		write_lock(&tasklist_lock);
		list_del_rcu(&p->task);
		write_unlock(&tasklist_lock);
		call_rcu(&p->rcu, delay_put_task_struct);
	}

Khi một quá trình thoát ra, ZZ0000ZZ gọi ZZ0001ZZ
thông qua __exit_signal() và __unhash_process() trong ZZ0002ZZ
bảo vệ khóa nhà văn.  Lệnh gọi list_del_rcu() sẽ loại bỏ
nhiệm vụ từ danh sách tất cả các nhiệm vụ. ZZ0003ZZ
ngăn chặn việc thêm/xóa danh sách đồng thời làm hỏng
danh sách. Đầu đọc sử dụng ZZ0004ZZ không được bảo vệ bằng
ZZ0005ZZ. Để tránh người đọc nhận thấy những thay đổi trong danh sách
con trỏ, đối tượng ZZ0006ZZ chỉ được giải phóng sau một hoặc nhiều
thời gian gia hạn trôi qua, với sự trợ giúp của call_rcu(), được gọi thông qua
put_task_struct_rcu_user(). Việc trì hoãn việc hủy diệt này đảm bảo rằng
bất kỳ người đọc nào duyệt qua danh sách sẽ thấy các con trỏ ZZ0007ZZ hợp lệ
và việc xóa/giải phóng có thể xảy ra song song với việc duyệt danh sách.
Mẫu này còn được gọi là ZZ0009ZZ, vì RCU kiềm chế
từ việc gọi hàm gọi lại delay_put_task_struct() cho đến khi
tất cả các đầu đọc hiện có đều hoàn thành, điều này đảm bảo rằng ZZ0008ZZ
đối tượng được đề cập sẽ tồn tại cho đến sau khi hoàn thành
của tất cả các trình đọc RCU có thể có tham chiếu đến đối tượng đó.


Ví dụ 2: Hành động bên đọc được thực hiện bên ngoài khóa: Không có bản cập nhật tại chỗ
----------------------------------------------------------------------

Một số trường hợp sử dụng khóa đầu đọc-ghi tính toán một giá trị trong khi giữ
khóa bên đọc, nhưng vẫn tiếp tục sử dụng giá trị đó sau khi khóa đó được
được thả ra.  Những trường hợp sử dụng này thường là ứng cử viên tốt cho việc chuyển đổi
tới RCU.  Một ví dụ nổi bật liên quan đến việc định tuyến gói tin mạng.
Vì dữ liệu định tuyến gói theo dõi trạng thái của thiết bị bên ngoài
của máy tính, đôi khi nó sẽ chứa dữ liệu cũ.  Vì thế, một lần
tuyến đường đã được tính toán, không cần phải giữ bảng định tuyến
tĩnh trong quá trình truyền gói tin.  Rốt cuộc, bạn có thể giữ
bảng định tuyến là tất cả những gì bạn muốn, nhưng điều đó sẽ không giữ được cấu hình bên ngoài.
Internet thay đổi và đó là trạng thái của Internet bên ngoài
điều đó thực sự quan trọng  Ngoài ra, các mục định tuyến thường được thêm vào
hoặc bị xóa thay vì được sửa đổi tại chỗ.  Đây là một ví dụ hiếm hoi
về tốc độ hữu hạn của ánh sáng và kích thước khác không của các nguyên tử thực sự
giúp việc đồng bộ hóa trở nên nhẹ nhàng hơn.

Bạn có thể tìm thấy một ví dụ đơn giản về loại trường hợp sử dụng RCU này trong
hỗ trợ kiểm tra cuộc gọi hệ thống.  Ví dụ, một reader-writer bị khóa
việc triển khai ZZ0000ZZ có thể như sau::

kiểm toán enum tĩnh_state kiểm toán_filter_task (khóa struct task_struct ZZ0000ZZ*)
	{
		cấu trúc Audit_entry *e;
		trạng thái enum Audit_state;

read_lock(&auditsc_lock);
		/* Lưu ý: Audit_filter_mutex do người gọi giữ. */
		list_for_each_entry(e, &audit_tsklist, list) {
			if (audit_filter_rules(tsk, &e->rule, NULL, &state)) {
				nếu (trạng thái == AUDIT_STATE_RECORD)
					*key = kstrdup(e->rule.filterkey, GFP_ATOMIC);
				read_unlock(&auditsc_lock);
				trạng thái trả về;
			}
		}
		read_unlock(&auditsc_lock);
		trả lại AUDIT_BUILD_CONTEXT;
	}

Ở đây danh sách được tìm kiếm dưới khóa, nhưng khóa bị loại bỏ trước
giá trị tương ứng được trả về.  Vào thời điểm giá trị này được thực hiện
vào, danh sách có thể đã được sửa đổi.  Điều này có ý nghĩa, vì nếu
bạn đang tắt tính năng kiểm tra, bạn có thể kiểm tra một vài lệnh gọi hệ thống bổ sung.

Điều này có nghĩa là RCU có thể dễ dàng được áp dụng cho mặt đọc, như sau::

kiểm toán enum tĩnh_state kiểm toán_filter_task (khóa struct task_struct ZZ0000ZZ*)
	{
		cấu trúc Audit_entry *e;
		trạng thái enum Audit_state;

rcu_read_lock();
		/* Lưu ý: Audit_filter_mutex do người gọi giữ. */
		list_for_each_entry_rcu(e, &audit_tsklist, list) {
			if (audit_filter_rules(tsk, &e->rule, NULL, &state)) {
				nếu (trạng thái == AUDIT_STATE_RECORD)
					*key = kstrdup(e->rule.filterkey, GFP_ATOMIC);
				rcu_read_unlock();
				trạng thái trả về;
			}
		}
		rcu_read_unlock();
		trả lại AUDIT_BUILD_CONTEXT;
	}

Các lệnh gọi read_lock() và read_unlock() đã trở thành rcu_read_lock()
và rcu_read_unlock() tương ứng và list_for_each_entry()
đã trở thành list_for_each_entry_rcu().  Truyền tải danh sách ZZ0000ZZ
nguyên thủy thêm READ_ONCE() và kiểm tra chẩn đoán khi sử dụng không chính xác
bên ngoài phần quan trọng phía đọc RCU.

Những thay đổi về mặt cập nhật cũng rất đơn giản. Khóa đầu đọc-ghi
có thể được sử dụng như sau để xóa và chèn vào các đơn giản hóa này
phiên bản của Audit_del_rule() và Audit_add_rule()::

int nội tuyến tĩnh Audit_del_rule(struct Audit_rule *rule,
					 cấu trúc list_head *list)
	{
		cấu trúc Audit_entry *e;

write_lock(&auditsc_lock);
		list_for_each_entry(e, danh sách, danh sách) {
			if (!audit_compare_rule(rule, &e->rule)) {
				list_del(&e->list);
				write_unlock(&auditsc_lock);
				trả về 0;
			}
		}
		write_unlock(&auditsc_lock);
		trả về -EFAULT;		/* Không có quy tắc nào phù hợp */
	}

int tĩnh nội tuyến Audit_add_rule(struct Audit_entry *entry,
					 cấu trúc list_head *list)
	{
		write_lock(&auditsc_lock);
		if (entry->rule.flags & AUDIT_PREPEND) {
			mục->rule.flags &= ~AUDIT_PREPEND;
			list_add(&entry->list, list);
		} khác {
			list_add_tail(&entry->list, list);
		}
		write_unlock(&auditsc_lock);
		trả về 0;
	}

Sau đây là các giá trị tương đương RCU cho hai chức năng này::

int nội tuyến tĩnh Audit_del_rule(struct Audit_rule *rule,
					 cấu trúc list_head *list)
	{
		cấu trúc Audit_entry *e;

/* Không cần sử dụng trình vòng lặp _rcu ở đây, vì đây là trình vòng lặp duy nhất
		 * thói quen xóa. */
		list_for_each_entry(e, danh sách, danh sách) {
			if (!audit_compare_rule(rule, &e->rule)) {
				list_del_rcu(&e->list);
				call_rcu(&e->rcu, Audit_free_rule);
				trả về 0;
			}
		}
		trả về -EFAULT;		/* Không có quy tắc nào phù hợp */
	}

int tĩnh nội tuyến Audit_add_rule(struct Audit_entry *entry,
					 cấu trúc list_head *list)
	{
		if (entry->rule.flags & AUDIT_PREPEND) {
			mục->rule.flags &= ~AUDIT_PREPEND;
			list_add_rcu(&entry->list, list);
		} khác {
			list_add_tail_rcu(&entry->list, list);
		}
		trả về 0;
	}

Thông thường, write_lock() và write_unlock() sẽ được thay thế bằng
spin_lock() và spin_unlock(). Nhưng trong trường hợp này, tất cả người gọi giữ
ZZ0000ZZ nên không cần khóa thêm. các
do đó, Auditsc_lock có thể bị loại bỏ vì việc sử dụng RCU sẽ loại bỏ
nhà văn cần phải loại trừ độc giả.

Các dạng nguyên hàm list_del(), list_add() và list_add_tail() đã được
được thay thế bằng list_del_rcu(), list_add_rcu() và list_add_tail_rcu().
Các nguyên hàm thao tác danh sách ZZ0000ZZ thêm các rào cản bộ nhớ
cần thiết trên các CPU có thứ tự yếu.  Nguyên hàm list_del_rcu() bỏ qua
mã hỗ trợ gỡ lỗi đầu độc con trỏ có thể gây ra sự cố đồng thời
độc giả thất bại một cách ngoạn mục.

Vì vậy, khi người đọc có thể chấp nhận dữ liệu cũ và khi các mục được thêm vào hoặc
đã xóa mà không cần sửa đổi tại chỗ, RCU rất dễ sử dụng!


Ví dụ 3: Xử lý cập nhật tại chỗ
------------------------------------

Mã kiểm tra cuộc gọi hệ thống không cập nhật các quy tắc kiểm tra tại chỗ.  Tuy nhiên,
nếu đúng như vậy thì mã khóa trình đọc-ghi để làm như vậy có thể trông như sau
(giả sử chỉ ZZ0000ZZ được cập nhật, nếu không, các trường được thêm sẽ
cần điền)::

int nội tuyến tĩnh Audit_upd_rule(struct Audit_rule *rule,
					 cấu trúc list_head * danh sách,
					 __u32 hành động mới,
					 __u32 newfield_count)
	{
		cấu trúc Audit_entry *e;
		cấu trúc Audit_entry *ne;

write_lock(&auditsc_lock);
		/* Lưu ý: Audit_filter_mutex do người gọi giữ. */
		list_for_each_entry(e, danh sách, danh sách) {
			if (!audit_compare_rule(rule, &e->rule)) {
				e->rule.action = newaction;
				e->rule.field_count = newfield_count;
				write_unlock(&auditsc_lock);
				trả về 0;
			}
		}
		write_unlock(&auditsc_lock);
		trả về -EFAULT;		/* Không có quy tắc nào phù hợp */
	}

Phiên bản RCU tạo bản sao, cập nhật bản sao, sau đó thay thế bản cũ
entry với mục mới được cập nhật.  Chuỗi hành động này, cho phép
đọc đồng thời trong khi tạo bản sao để thực hiện cập nhật, là điều mang lại
RCU (ZZ0000ZZ) tên của nó.

Phiên bản RCU của Audit_upd_rule() như sau ::

int nội tuyến tĩnh Audit_upd_rule(struct Audit_rule *rule,
					 cấu trúc list_head * danh sách,
					 __u32 hành động mới,
					 __u32 newfield_count)
	{
		cấu trúc Audit_entry *e;
		cấu trúc Audit_entry *ne;

list_for_each_entry(e, danh sách, danh sách) {
			if (!audit_compare_rule(rule, &e->rule)) {
				ne = kmalloc(sizeof(*entry), GFP_ATOMIC);
				nếu (ne == NULL)
					trả về -ENOMEM;
				kiểm toán_copy_rule(&ne->quy tắc, &e->quy tắc);
				ne->rule.action = newaction;
				ne->rule.field_count = newfield_count;
				list_replace_rcu(&e->list, &ne->list);
				call_rcu(&e->rcu, Audit_free_rule);
				trả về 0;
			}
		}
		trả về -EFAULT;		/* Không có quy tắc nào phù hợp */
	}

Một lần nữa, điều này giả định rằng người gọi giữ ZZ0000ZZ.  Thông thường,
khóa nhà văn sẽ trở thành một khóa xoay trong loại mã này.

update_lsm_rule() thực hiện điều gì đó rất tương tự, đối với những người muốn
thích xem mã hạt nhân Linux thực hơn.

Một cách sử dụng khác của mẫu này có thể được tìm thấy trong kết nối * của trình điều khiển openswitch
bảng theo dõi* mã trong ZZ0000ZZ.  Bảng giữ theo dõi kết nối
các mục và có giới hạn về số mục tối đa.  Có một cái bàn như thế
mỗi vùng và do đó một ZZ0002ZZ cho mỗi vùng.  Các vùng được ánh xạ tới giới hạn của chúng
thông qua bảng băm bằng cách sử dụng danh sách hlist do RCU quản lý cho chuỗi băm. Khi mới
giới hạn được đặt, một đối tượng giới hạn mới được phân bổ và ZZ0001ZZ được gọi
để thay thế đối tượng giới hạn cũ bằng đối tượng giới hạn mới bằng list_replace_rcu().
Đối tượng giới hạn cũ sau đó sẽ được giải phóng sau một thời gian gia hạn bằng cách sử dụng kfree_rcu().


Ví dụ 4: Loại bỏ dữ liệu cũ
---------------------------------

Ví dụ kiểm tra ở trên chấp nhận dữ liệu cũ, cũng như hầu hết các thuật toán
đang theo dõi trạng thái bên ngoài.  Rốt cuộc, do có sự chậm trễ
kể từ thời điểm trạng thái bên ngoài thay đổi trước khi Linux nhận thức được
của sự thay đổi, và như đã lưu ý trước đó, một lượng nhỏ bổ sung
Độ cứng do RCU gây ra nói chung không phải là vấn đề.

Tuy nhiên, có nhiều ví dụ về việc dữ liệu cũ không thể được chấp nhận.
Một ví dụ trong nhân Linux là System V IPC (xem shm_lock()
chức năng trong ipc/shm.c).  Mã này kiểm tra cờ ZZ0000ZZ dưới
spinlock cho mỗi mục nhập và nếu cờ ZZ0001ZZ được đặt, hãy giả vờ rằng
mục nhập không tồn tại.  Để điều này hữu ích, chức năng tìm kiếm phải
quay lại giữ spinlock cho mỗi mục nhập, như shm_lock() trên thực tế đã làm.

.. _quick_quiz:

Câu đố nhanh:
	Để kỹ thuật xóa cờ có ích, tại sao lại cần thiết
	để giữ khóa mỗi mục trong khi quay lại từ chức năng tìm kiếm?

ZZ0000ZZ

Nếu mô-đun kiểm tra cuộc gọi hệ thống cần từ chối dữ liệu cũ, một cách
để thực hiện điều này sẽ là thêm cờ ZZ0000ZZ và khóa quay ZZ0001ZZ vào
Cấu trúc ZZ0002ZZ và sửa đổi Audit_filter_task() như sau ::

cấu trúc tĩnh Audit_entry *audit_filter_task(struct task_struct *tsk, char **key)
	{
		cấu trúc Audit_entry *e;
		trạng thái enum Audit_state;

rcu_read_lock();
		list_for_each_entry_rcu(e, &audit_tsklist, list) {
			if (audit_filter_rules(tsk, &e->rule, NULL, &state)) {
				spin_lock(&e->lock);
				if (e->đã xóa) {
					spin_unlock(&e->lock);
					rcu_read_unlock();
					trả lại NULL;
				}
				rcu_read_unlock();
				nếu (trạng thái == AUDIT_STATE_RECORD)
					*key = kstrdup(e->rule.filterkey, GFP_ATOMIC);
				/* Miễn là e->lock được giữ, e hợp lệ và
				 * giá trị của nó không cũ */
				trả lại e;
			}
		}
		rcu_read_unlock();
		trả lại NULL;
	}

Hàm ZZ0000ZZ sẽ cần đặt cờ ZZ0001ZZ bên dưới
spinlock như sau::

int nội tuyến tĩnh Audit_del_rule(struct Audit_rule *rule,
					 cấu trúc list_head *list)
	{
		cấu trúc Audit_entry *e;

/* Không cần sử dụng _rcu iterator ở đây, vì điều này
		 * là thói quen xóa duy nhất. */
		list_for_each_entry(e, danh sách, danh sách) {
			if (!audit_compare_rule(rule, &e->rule)) {
				spin_lock(&e->lock);
				list_del_rcu(&e->list);
				e->đã xóa = 1;
				spin_unlock(&e->lock);
				call_rcu(&e->rcu, Audit_free_rule);
				trả về 0;
			}
		}
		trả về -EFAULT;		/* Không có quy tắc nào phù hợp */
	}

Điều này cũng giả định rằng người gọi giữ ZZ0000ZZ.

Lưu ý rằng ví dụ này giả định rằng các mục chỉ được thêm và xóa.
Cần có cơ chế bổ sung để xử lý chính xác việc cập nhật tại chỗ
được thực hiện bởi Audit_upd_rule().  Đầu tiên, Audit_upd_rule() sẽ
cần giữ ổ khóa của cả ZZ0000ZZ cũ và ổ khóa thay thế
trong khi thực thi list_replace_rcu().


Ví dụ 5: Bỏ qua các đối tượng cũ
---------------------------------

Đối với một số trường hợp sử dụng, hiệu suất của trình đọc có thể được cải thiện bằng cách bỏ qua
các đối tượng cũ trong quá trình duyệt danh sách bên đọc, trong đó các đối tượng cũ
là những thứ sẽ bị loại bỏ và phá hủy sau một hoặc nhiều lần ân hạn
thời kỳ. Một ví dụ như vậy có thể được tìm thấy trong hệ thống con timerfd. Khi một
Đồng hồ ZZ0000ZZ được lập trình lại (ví dụ do cài đặt
của thời gian hệ thống) thì tất cả ZZ0001ZZ được lập trình phụ thuộc vào
đồng hồ này được kích hoạt và các tiến trình đang chờ chúng được đánh thức trong
trước thời hạn dự kiến của họ. Để tạo điều kiện thuận lợi cho việc này, tất cả các bộ tính giờ như vậy
được thêm vào ZZ0002ZZ do RCU quản lý khi chúng được thiết lập trong
ZZ0003ZZ::

static void timerfd_setup_cancel(struct timerfd_ctx *ctx, cờ int)
	{
		spin_lock(&ctx->cancel_lock);
		if ((ctx->clockid == CLOCK_REALTIME ||
		     ctx->clockid == CLOCK_REALTIME_ALARM) &&
		    (cờ & TFD_TIMER_ABSTIME) && (cờ & TFD_TIMER_CANCEL_ON_SET)) {
			if (!ctx->might_cancel) {
				ctx->might_cancel = true;
				spin_lock(&cancel_lock);
				list_add_rcu(&ctx->clist, &cancel_list);
				spin_unlock(&cancel_lock);
			}
		} khác {
			__timerfd_remove_cancel(ctx);
		}
		spin_unlock(&ctx->cancel_lock);
	}

Khi một timerfd được giải phóng (fd bị đóng), thì ZZ0000ZZ
cờ của đối tượng timerfd bị xóa, đối tượng bị xóa khỏi
ZZ0001ZZ và bị phá hủy, như thể hiện trong phần đơn giản hóa và nội tuyến này
phiên bản của timerfd_release()::

int timerfd_release(tệp struct inode *inode, struct file *)
	{
		struct timerfd_ctx *ctx = file->private_data;

spin_lock(&ctx->cancel_lock);
		if (ctx->might_cancel) {
			ctx->might_cancel = false;
			spin_lock(&cancel_lock);
			list_del_rcu(&ctx->clist);
			spin_unlock(&cancel_lock);
		}
		spin_unlock(&ctx->cancel_lock);

nếu (isalarm(ctx))
			Alarm_cancel(&ctx->t.alarm);
		khác
			hrtimer_cancel(&ctx->t.tmr);
		kfree_rcu(ctx, rcu);
		trả về 0;
	}

Nếu đồng hồ ZZ0000ZZ được đặt, chẳng hạn như bởi máy chủ thời gian, thì
khung hrtimer gọi ZZ0001ZZ để hướng dẫn
ZZ0002ZZ và đánh thức các tiến trình đang chờ trên timerfd. Trong khi lặp lại
ZZ0003ZZ, cờ ZZ0004ZZ được tư vấn để bỏ qua lỗi cũ
đối tượng::

void timerfd_clock_was_set(void)
	{
		ktime_t moffs = ktime_mono_to_real(0);
		cấu trúc bộ đếm thời gian_ctx *ctx;
		cờ dài không dấu;

rcu_read_lock();
		list_for_each_entry_rcu(ctx, &cancel_list, clist) {
			if (!ctx->might_cancel)
				tiếp tục;
			spin_lock_irqsave(&ctx->wqh.lock, cờ);
			if (ctx->moffs != moffs) {
				ctx->moffs = KTIME_MAX;
				ctx->tick++;
				Wake_up_locked_poll(&ctx->wqh, EPOLLIN);
			}
			spin_unlock_irqrestore(&ctx->wqh.lock, flag);
		}
		rcu_read_unlock();
	}

Điểm mấu chốt là do quá trình truyền tải được bảo vệ bởi RCU của
ZZ0000ZZ xảy ra đồng thời với việc thêm và xóa đối tượng,
đôi khi quá trình truyền tải có thể truy cập một đối tượng đã bị xóa khỏi
danh sách. Trong ví dụ này, cờ được sử dụng để bỏ qua các đối tượng đó.


Bản tóm tắt
-------

Cấu trúc dữ liệu dựa trên danh sách chủ yếu đọc có thể chấp nhận dữ liệu cũ
dễ sử dụng nhất của RCU.  Trường hợp đơn giản nhất là nơi các mục được
được thêm hoặc xóa khỏi cấu trúc dữ liệu (hoặc được sửa đổi nguyên tử
tại chỗ), nhưng các sửa đổi tại chỗ không nguyên tử có thể được xử lý bằng cách thực hiện
một bản sao, cập nhật bản sao, sau đó thay thế bản gốc bằng bản sao.
Nếu dữ liệu cũ không thể được chấp nhận thì có thể sử dụng cờ ZZ0000ZZ
kết hợp với khóa xoay cho mỗi mục nhập để cho phép tìm kiếm
Chức năng từ chối dữ liệu mới bị xóa.

.. _quick_quiz_answer:

Trả lời câu đố nhanh:
	Để kỹ thuật xóa cờ có ích, tại sao lại cần thiết
	để giữ khóa mỗi mục trong khi quay lại từ chức năng tìm kiếm?

Nếu chức năng tìm kiếm bỏ khóa mỗi mục nhập trước khi quay lại,
	thì người gọi sẽ xử lý dữ liệu cũ trong mọi trường hợp.  Nếu nó
	thực sự ổn khi xử lý dữ liệu cũ, thì bạn không cần
	Cờ ZZ0000ZZ.  Nếu việc xử lý dữ liệu cũ thực sự là một vấn đề,
	thì bạn cần giữ khóa mỗi mục nhập trên tất cả mã
	sử dụng giá trị được trả về.

ZZ0000ZZ
