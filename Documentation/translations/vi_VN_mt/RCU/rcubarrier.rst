.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/rcubarrier.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _rcu_barrier:

RCU và các mô-đun không thể tải được
====================================

[Được xuất bản lần đầu trên LWN ngày 14 tháng 1 năm 2007: ZZ0000ZZ

Trình cập nhật RCU đôi khi sử dụng call_rcu() để bắt đầu chờ đợi không đồng bộ
một thời gian ân hạn sẽ trôi qua.  Nguyên thủy này lấy một con trỏ tới rcu_head
struct được đặt trong cấu trúc dữ liệu được bảo vệ RCU và một con trỏ khác
tới một chức năng có thể được gọi sau này để giải phóng cấu trúc đó. Mã tới
khi đó việc xóa phần tử p khỏi danh sách liên kết khỏi ngữ cảnh IRQ có thể là
như sau::

list_del_rcu(p);
	call_rcu(&p->rcu, p_callback);

Vì call_rcu() không bao giờ chặn nên mã này có thể được sử dụng một cách an toàn từ bên trong
Bối cảnh IRQ. Hàm p_callback() có thể được định nghĩa như sau::

static void p_callback(struct rcu_head *rp)
	{
		struct pstruct *p = container_of(rp, struct pstruct, rcu);

kfree(p);
	}


Đang tải các mô-đun sử dụng call_rcu()
--------------------------------------

Nhưng điều gì sẽ xảy ra nếu hàm p_callback() được xác định trong một mô-đun không thể tải được?

Nếu chúng tôi dỡ mô-đun trong khi một số lệnh gọi lại RCU đang chờ xử lý,
các CPU thực hiện các cuộc gọi lại này sẽ bị ảnh hưởng nghiêm trọng
thất vọng khi sau này chúng được viện dẫn, như được mô tả một cách huyền ảo tại
ZZ0000ZZ

Chúng ta có thể thử đặt một sync_rcu() trong đường dẫn mã thoát mô-đun,
nhưng điều này là không đủ. Mặc dù sync_rcu() có chờ một
thời gian gia hạn đã trôi qua, nó không đợi lệnh gọi lại hoàn tất.

Người ta có thể muốn thử vài lần sync_rcu() liên tiếp
cuộc gọi, nhưng điều này vẫn không được đảm bảo để hoạt động. Nếu có rất
tải gọi lại RCU nặng, thì một số lệnh gọi lại có thể bị trì hoãn trong
để cho phép quá trình xử lý khác tiếp tục. Chỉ có một ví dụ, chẳng hạn
trì hoãn là cần thiết trong hạt nhân thời gian thực để tránh quá nhiều
lập kế hoạch độ trễ.


rcu_barrier()
-------------

Tình huống này có thể được xử lý bằng hàm nguyên thủy rcu_barrier().  đúng hơn
thay vì chờ thời gian gia hạn trôi qua, rcu_barrier() sẽ đợi tất cả
các cuộc gọi lại RCU chưa hoàn thành.  Xin lưu ý rằng rcu_barrier()
ZZ0000ZZ có ngụ ý đồng bộ hóa_rcu() không, đặc biệt, nếu không có RCU
các cuộc gọi lại được xếp hàng đợi ở bất cứ đâu, rcu_barrier() có quyền trả lại
ngay lập tức, không cần chờ đợi điều gì chứ đừng nói đến thời gian ân hạn.

Mã giả sử dụng rcu_barrier() như sau:

1. Ngăn không cho đăng bất kỳ lệnh gọi lại RCU mới nào.
   2. Thực thi rcu_barrier().
   3. Cho phép dỡ mô-đun xuống.

Ngoài ra còn có hàm srcu_barrier() cho SRCU, và tất nhiên là bạn
phải phù hợp với hương vị của srcu_barrier() với call_srcu().
Nếu mô-đun của bạn sử dụng nhiều cấu trúc srcu_struct thì nó cũng phải
sử dụng nhiều lệnh gọi srcu_barrier() khi dỡ bỏ mô-đun đó.
Ví dụ: nếu nó sử dụng call_rcu(), call_srcu() trên srcu_struct_1 và
call_srcu() trên srcu_struct_2, sau đó là ba dòng mã sau
sẽ được yêu cầu khi dỡ hàng::

1 rcu_barrier();
  2 srcu_barrier(&srcu_struct_1);
  3 srcu_barrier(&srcu_struct_2);

Nếu độ trễ là điều cốt yếu thì hàng đợi công việc có thể được sử dụng để chạy những
đồng thời ba chức năng.

Một phiên bản cổ của mô-đun rcutorture sử dụng rcu_barrier()
trong chức năng thoát của nó như sau ::

1 khoảng trống tĩnh
  2 rcu_torture_cleanup(void)
  3 {
  4 int tôi;
  5
  6 dấu chấm = 1;
  7 if (shuffler_task != NULL) {
  8 VERBOSE_PRINTK_STRING("Dừng tác vụ rcu_torture_shuffle");
  9 kthread_stop(shuffler_task);
 10 }
 11 nhiệm vụ xáo trộn = NULL;
 12
 13 nếu (writer_task != NULL) {
 14 VERBOSE_PRINTK_STRING("Dừng tác vụ rcu_torture_writer");
 15 kthread_stop(writer_task);
 16 }
 17 writer_task = NULL;
 18
 19 if (reader_tasks != NULL) {
 20 cho (i = 0; i < nrealreaders; i++) {
 21 if (reader_tasks[i] != NULL) {
 22 VERBOSE_PRINTK_STRING(
 23 "Dừng tác vụ rcu_torture_reader");
 24 kthread_stop(reader_tasks[i]);
 25 }
 26 reader_tasks[i] = NULL;
 27 }
 28 kfree(reader_tasks);
 29 reader_tasks = NULL;
 30 }
 31 rcu_torture_current = NULL;
 32
 33 if (fakewriter_tasks != NULL) {
 34 cho (i = 0; i < nfakewriters; i++) {
 35 if (fakewriter_tasks[i] != NULL) {
 36 VERBOSE_PRINTK_STRING(
 37 "Dừng tác vụ rcu_torture_fakewriter");
 38 kthread_stop(fakewriter_tasks[i]);
 39 }
 40 fakewriter_tasks[i] = NULL;
 41 }
 42 kfree(fakewriter_tasks);
 43 fakewriter_tasks = NULL;
 44 }
 45
 46 nếu (stats_task != NULL) {
 47 VERBOSE_PRINTK_STRING("Dừng nhiệm vụ rcu_torture_stats");
 48 kthread_stop(stats_task);
 49 }
 50 số liệu thống kê_task = NULL;
 51
 52 /* Đợi tất cả lệnh gọi lại RCU kích hoạt. */
 53 rcu_barrier();
 54
 55 rcu_torture_stats_print(); /* -Sau- luồng thống kê bị dừng! */
 56
 57 if (cur_ops->dọn dẹp != NULL)
 58 cur_ops->dọn dẹp();
 59 if (atomic_read(&n_rcu_torture_error))
 60 rcu_torture_print_module_parms("Kết thúc kiểm tra: FAILURE");
 61 cái khác
 62 rcu_torture_print_module_parms("Kết thúc kiểm tra: SUCCESS");
 63 }

Dòng 6 đặt một biến toàn cục để ngăn chặn bất kỳ cuộc gọi lại RCU nào từ
tự đăng lại. Điều này sẽ không cần thiết trong hầu hết các trường hợp, vì
Lệnh gọi lại RCU hiếm khi bao gồm lệnh gọi tới call_rcu(). Tuy nhiên, cơ cấu
mô-đun là một ngoại lệ đối với quy tắc này và do đó cần phải đặt quy tắc này
biến toàn cục.

Các dòng 7-50 dừng tất cả các tác vụ kernel liên quan đến rcutorture
mô-đun. Do đó, khi thực thi đến dòng 53, sẽ không còn lệnh xử lý nữa
Các cuộc gọi lại RCU sẽ được đăng. Cuộc gọi rcu_barrier() trên dòng 53 đang chờ
để hoàn tất mọi lệnh gọi lại có sẵn.

Sau đó, dòng 55-62 in trạng thái và thực hiện dọn dẹp theo hoạt động cụ thể, đồng thời
sau đó quay lại, cho phép hoàn thành thao tác dỡ mô-đun.

.. _rcubarrier_quiz_1:

Câu đố nhanh #1:
	Có tình huống nào khác mà rcu_barrier() có thể
	được yêu cầu?

ZZ0000ZZ

Mô-đun của bạn có thể có thêm sự phức tạp. Ví dụ, nếu bạn
mô-đun gọi call_rcu() từ bộ tính giờ, trước tiên bạn cần phải kiềm chế
từ việc đăng bộ hẹn giờ mới, hãy hủy (hoặc chờ) tất cả những bộ tính giờ đã được đăng
bộ hẹn giờ và chỉ sau đó gọi rcu_barrier() để đợi mọi thứ còn lại
Cuộc gọi lại RCU đã hoàn tất.

Tất nhiên, nếu mô-đun của bạn sử dụng call_rcu(), bạn sẽ cần gọi
rcu_barrier() trước khi dỡ tải.  Tương tự, nếu mô-đun của bạn sử dụng
call_srcu(), bạn sẽ cần gọi srcu_barrier() trước khi dỡ tải,
và trên cùng cấu trúc srcu_struct.  Nếu mô-đun của bạn sử dụng call_rcu()
ZZ0000ZZ call_srcu(), thì (như đã lưu ý ở trên) bạn sẽ cần gọi
rcu_barrier() ZZ0001ZZ srcu_barrier().


Triển khai rcu_barrier()
--------------------------

Việc triển khai rcu_barrier() của Dipankar Sarma tận dụng thực tế
các cuộc gọi lại RCU không bao giờ được sắp xếp lại sau khi được xếp hàng đợi trên một trong các CPU
hàng đợi. Việc triển khai của anh ấy xếp hàng một lệnh gọi lại RCU trên mỗi CPU
hàng đợi gọi lại và sau đó đợi cho đến khi tất cả chúng bắt đầu thực thi, tại
tại thời điểm đó, tất cả các cuộc gọi lại RCU trước đó được đảm bảo đã hoàn thành.

Mã ban đầu cho rcu_barrier() đại khái như sau::

1 khoảng trống rcu_barrier(void)
  2 {
  3 BUG_ON(in_interrupt());
  4 /* Sử dụng cpucontrol mutex để bảo vệ khỏi hotplug CPU */
  5 mutex_lock(&rcu_barrier_mutex);
  6 init_completion(&rcu_barrier_completion);
  7 Atomic_set(&rcu_barrier_cpu_count, 1);
  8 on_each_cpu(rcu_barrier_func, NULL, 0, 1);
  9 nếu (atomic_dec_and_test(&rcu_barrier_cpu_count))
 10 hoàn thành(&rcu_barrier_completion);
 11 wait_for_completion(&rcu_barrier_completion);
 12 mutex_unlock(&rcu_barrier_mutex);
 13 }

Dòng 3 xác minh rằng người gọi đang ở trong ngữ cảnh quá trình và dòng 5 và 12
sử dụng rcu_barrier_mutex để đảm bảo rằng chỉ có một rcu_barrier() đang sử dụng
hoàn thành toàn cục và bộ đếm tại một thời điểm, được khởi tạo trên các dòng
6 và 7. Dòng 8 khiến mỗi CPU gọi rcu_barrier_func(), nghĩa là
hiển thị dưới đây. Lưu ý rằng số "1" cuối cùng trong danh sách đối số của on_each_cpu()
đảm bảo rằng tất cả các lệnh gọi tới rcu_barrier_func() sẽ hoàn thành
trước khi on_each_cpu() trả về. Dòng 9 xóa số đếm ban đầu khỏi
rcu_barrier_cpu_count và nếu số lượng này bây giờ bằng 0, dòng 10 sẽ hoàn tất
việc hoàn thành, ngăn dòng 11 bị chặn.  Dù thế nào đi nữa,
dòng 11 sau đó đợi (nếu cần) để hoàn thành.

.. _rcubarrier_quiz_2:

Câu đố nhanh #2:
	Tại sao dòng 8 không khởi tạo rcu_barrier_cpu_count về 0,
	do đó tránh được sự cần thiết của dòng 9 và 10?

ZZ0000ZZ

Mã này đã được viết lại vào năm 2008 và nhiều lần sau đó, nhưng mã này
vẫn đưa ra ý tưởng chung.

rcu_barrier_func() chạy trên mỗi CPU, nơi nó gọi call_rcu()
để đăng lệnh gọi lại RCU, như sau::

1 khoảng trống tĩnh rcu_barrier_func(void *không được sử dụng)
  2 {
  3 int cpu = smp_processor_id();
  4 cấu trúc rcu_data *rdp = &per_cpu(rcu_data, cpu);
  5 cấu trúc rcu_head *head;
  6
  7 đầu = &rdp->rào chắn;
  8 nguyên tử_inc(&rcu_barrier_cpu_count);
  9 call_rcu(head, rcu_barrier_callback);
 10 }

Dòng 3 và 4 định vị cấu trúc per-CPU rcu_data bên trong của RCU,
chứa cấu trúc rcu_head cần thiết cho cuộc gọi sau tới
call_rcu(). Dòng 7 chọn một con trỏ tới cấu trúc rcu_head này và dòng
8 tăng bộ đếm toàn cầu. Bộ đếm này sau đó sẽ được giảm đi
bởi cuộc gọi lại. Dòng 9 sau đó đăng ký rcu_barrier_callback() trên
hàng đợi của CPU hiện tại.

Hàm rcu_barrier_callback() chỉ đơn giản là giảm giá trị nguyên tử
biến rcu_barrier_cpu_count và hoàn tất quá trình hoàn thành khi nó
đạt tới 0, như sau::

1 khoảng trống tĩnh rcu_barrier_callback(struct rcu_head *notused)
  2 {
  3 nếu (atomic_dec_and_test(&rcu_barrier_cpu_count))
  4 hoàn thành(&rcu_barrier_completion);
  5 }

.. _rcubarrier_quiz_3:

Câu đố nhanh #3:
	Điều gì xảy ra nếu rcu_barrier_func() của CPU 0 thực thi
	ngay lập tức (do đó tăng rcu_barrier_cpu_count lên
	giá trị một), nhưng các lời gọi rcu_barrier_func() khác của CPU
	có bị trì hoãn trong thời gian gia hạn đầy đủ không? Điều này không thể dẫn đến
	rcu_barrier() quay lại sớm?

ZZ0000ZZ

Việc triển khai rcu_barrier() hiện tại phức tạp hơn do nhu cầu
để tránh làm phiền các CPU nhàn rỗi (đặc biệt là trên các hệ thống chạy bằng pin)
và nhu cầu làm phiền tối thiểu các CPU không hoạt động trong các hệ thống thời gian thực.
Ngoài ra, rất nhiều tối ưu hóa đã được áp dụng.  Tuy nhiên,
đoạn mã trên minh họa các khái niệm.


rcu_barrier() Tóm tắt
---------------------

Hàm nguyên thủy rcu_barrier() được sử dụng tương đối ít, vì hầu hết
mã sử dụng RCU nằm trong kernel lõi chứ không phải trong các mô-đun. Tuy nhiên, nếu
bạn đang sử dụng RCU từ mô-đun không thể tải được, bạn cần sử dụng rcu_barrier()
để mô-đun của bạn có thể được dỡ xuống một cách an toàn.


Đáp án các câu đố nhanh
------------------------

.. _answer_rcubarrier_quiz_1:

Câu đố nhanh #1:
	Có tình huống nào khác mà rcu_barrier() có thể
	được yêu cầu?

Trả lời:
	Điều thú vị là rcu_barrier() ban đầu không phải
	được thực hiện để dỡ tải mô-đun. Nikita Danilov đã sử dụng
	RCU trong một hệ thống tập tin, dẫn đến tình huống tương tự tại
	thời gian ngắt kết nối hệ thống tập tin. Dipankar Sarma đã mã hóa rcu_barrier()
	để đáp lại, để Nikita có thể gọi nó trong suốt quá trình
	quá trình ngắt kết nối hệ thống tập tin.

Mãi về sau, máy của bạn mới thực sự gặp phải sự cố dỡ mô-đun RCU khi
	triển khai rcutorture và thấy rằng rcu_barrier() giải quyết được
	vấn đề này nữa.

ZZ0000ZZ

.. _answer_rcubarrier_quiz_2:

Câu đố nhanh #2:
	Tại sao dòng 8 không khởi tạo rcu_barrier_cpu_count về 0,
	do đó tránh được sự cần thiết của dòng 9 và 10?

Trả lời:
	Giả sử hàm on_each_cpu() hiển thị ở dòng 8 là
	bị trì hoãn, do đó rcu_barrier_func() của CPU 0 được thực thi và
	thời gian gia hạn tương ứng đã trôi qua, tất cả đều trước CPU 1
	rcu_barrier_func() đã bắt đầu thực thi.  Điều này sẽ dẫn đến
	rcu_barrier_cpu_count bị giảm xuống 0, vì vậy dòng đó
	Wait_for_completion() của số 11 sẽ quay trở lại ngay lập tức, không thành công
	đợi lệnh gọi lại của CPU 1 được gọi.

Lưu ý rằng đây không phải là vấn đề khi mã rcu_barrier()
	được thêm vào lần đầu tiên vào năm 2005. Điều này là do on_each_cpu()
	vô hiệu hóa quyền ưu tiên, hoạt động như một thông báo quan trọng phía đọc RCU
	phần này, do đó ngăn không cho thời gian gia hạn của CPU 0 hoàn thành
	cho đến khi on_each_cpu() xử lý xong tất cả CPU.

Tuy nhiên, với việc hợp nhất hương vị RCU vào khoảng v4.20, điều này
	khả năng một lần nữa bị loại trừ, bởi vì hợp nhất
	RCU một lần nữa chờ đợi các vùng mã không thể chiếm được.

Tuy nhiên, số lượng bổ sung đó vẫn có thể là một ý tưởng hay.
	Dựa vào những loại tai nạn thực hiện này có thể dẫn đến
	về các lỗi bất ngờ sau này khi việc triển khai thay đổi.

ZZ0000ZZ

.. _answer_rcubarrier_quiz_3:

Câu đố nhanh #3:
	Điều gì xảy ra nếu rcu_barrier_func() của CPU 0 thực thi
	ngay lập tức (do đó tăng rcu_barrier_cpu_count lên
	giá trị một), nhưng các lời gọi rcu_barrier_func() khác của CPU
	có bị trì hoãn trong thời gian gia hạn đầy đủ không? Điều này không thể dẫn đến
	rcu_barrier() quay lại sớm?

Trả lời:
	Điều này không thể xảy ra. Lý do là on_each_cpu() có cái cuối cùng
	đối số, cờ chờ, được đặt thành "1". Cờ này được chuyển qua
	tới smp_call_function() và xa hơn nữa là smp_call_function_on_cpu(),
	làm cho cái sau này quay cho đến khi lệnh gọi CPU chéo của
	rcu_barrier_func() đã hoàn thành. Điều này tự nó sẽ ngăn cản
	thời gian gia hạn kể từ khi hoàn thành trên các hạt nhân không phải CONFIG_PREEMPTION,
	vì mỗi CPU phải trải qua quá trình chuyển đổi ngữ cảnh (hoặc chuyển đổi ngữ cảnh khác
	state) trước khi thời gian gia hạn có thể hoàn tất. Tuy nhiên, đây là
	không được sử dụng trong hạt nhân CONFIG_PREEMPTION.

Do đó, on_each_cpu() vô hiệu hóa quyền ưu tiên trong cuộc gọi của nó
	tới smp_call_function() và cả cuộc gọi cục bộ tới
	rcu_barrier_func(). Bởi vì việc triển khai RCU gần đây xử lý
	các vùng mã bị vô hiệu hóa quyền ưu tiên dưới dạng quan trọng phía đọc RCU
	các phần, điều này ngăn không cho thời gian gia hạn hoàn thành. Cái này
	có nghĩa là tất cả các CPU đã thực thi rcu_barrier_func() trước đó
	lần lượt rcu_barrier_callback() đầu tiên có thể thực thi
	ngăn rcu_barrier_cpu_count sớm về 0.

Nhưng nếu on_each_cpu() quyết định từ bỏ việc vô hiệu hóa quyền ưu tiên,
	điều này cũng có thể xảy ra do cân nhắc về độ trễ theo thời gian thực,
	khởi tạo rcu_barrier_cpu_count thành một sẽ tiết kiệm được thời gian.

ZZ0000ZZ
