.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/stallwarn.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Sử dụng Máy dò gian hàng CPU của RCU
==============================

Tài liệu này lần đầu tiên thảo luận về các loại vấn đề RCU của gian hàng CPU
trình phát hiện có thể xác định vị trí và sau đó thảo luận về các tham số kernel và Kconfig
các tùy chọn có thể được sử dụng để tinh chỉnh hoạt động của máy dò.  Cuối cùng,
tài liệu này giải thích định dạng "splat" của bộ phát hiện gian hàng.


Nguyên nhân gây ra cảnh báo ngừng hoạt động của RCU CPU?
===================================

Vì vậy, hạt nhân của bạn đã in cảnh báo ngừng hoạt động RCU CPU.  Câu hỏi tiếp theo là
"Điều gì đã gây ra nó?"  Các sự cố sau đây có thể dẫn đến RCU CPU bị treo
cảnh báo:

- Vòng lặp CPU trong phần quan trọng phía đọc RCU.

- Vòng lặp CPU bị vô hiệu hóa các ngắt.

- Vòng lặp CPU bị vô hiệu hóa quyền ưu tiên.

- Vòng lặp CPU bị vô hiệu hóa nửa dưới.

- Đối với hạt nhân !CONFIG_PREEMPTION, vòng lặp CPU ở bất kỳ đâu trong
	kernel mà không có khả năng gọi lịch trình().  Nếu vòng lặp
	trong kernel là hành vi thực sự được mong đợi và mong muốn, bạn
	có thể cần thêm một số lệnh gọi vào cond_resched().

- Khởi động Linux bằng kết nối console quá chậm để
	theo kịp tốc độ tin nhắn bảng điều khiển thời gian khởi động.  Ví dụ,
	bảng điều khiển nối tiếp 115Kbaud có thể khiến ZZ0000ZZ quá chậm để theo kịp
	với tốc độ tin nhắn lúc khởi động và thường sẽ dẫn đến
	Thông báo cảnh báo ngừng hoạt động của RCU CPU.  Đặc biệt nếu bạn đã thêm
	gỡ lỗi printk()s.

- Bất kỳ điều gì ngăn cản kthread trong thời gian gia hạn của RCU chạy.
	Điều này có thể dẫn đến thông báo nhật ký bảng điều khiển "Tất cả các QS đã thấy".
	Thông báo này sẽ bao gồm thông tin về thời điểm kthread cuối cùng
	đã chạy và tần suất dự kiến sẽ chạy.  Nó cũng có thể
	dẫn đến thông báo nhật ký bảng điều khiển ZZ0000ZZ,
	sẽ bao gồm thông tin gỡ lỗi bổ sung.

- Một tác vụ thời gian thực gắn với CPU trong nhân CONFIG_PREEMPTION, có thể
	tình cờ ưu tiên một tác vụ có mức độ ưu tiên thấp ở giữa RCU
	phần quan trọng phía đọc.   Điều này đặc biệt có hại nếu
	tác vụ có mức độ ưu tiên thấp đó không được phép chạy trên bất kỳ CPU nào khác,
	trong trường hợp đó, thời gian gia hạn RCU tiếp theo không bao giờ có thể hoàn thành, điều này
	cuối cùng sẽ khiến hệ thống hết bộ nhớ và bị treo.
	Trong khi hệ thống đang trong quá trình tự hết
	bộ nhớ, bạn có thể thấy thông báo cảnh báo ngừng hoạt động.

- Một tác vụ thời gian thực gắn với CPU trong nhân CONFIG_PREEMPT_RT
	đang chạy ở mức ưu tiên cao hơn các luồng softirq RCU.
	Điều này sẽ ngăn việc gọi lại RCU,
	và trong kernel CONFIG_PREEMPT_RCU sẽ ngăn chặn hơn nữa
	Thời gian gia hạn RCU kể từ khi hoàn thành.  Dù thế nào đi nữa,
	hệ thống cuối cùng sẽ hết bộ nhớ và treo.  trong
	Vỏ CONFIG_PREEMPT_RCU, bạn có thể thấy cảnh báo ngừng hoạt động
	tin nhắn.

Bạn có thể sử dụng tham số khởi động kernel rcutree.kthread_prio để
	tăng mức độ ưu tiên lập lịch của kthread của RCU, có thể
	giúp tránh vấn đề này.  Tuy nhiên, xin lưu ý rằng việc làm này
	có thể tăng tốc độ chuyển đổi ngữ cảnh của hệ thống và do đó làm suy giảm
	hiệu suất.

- Một ngắt định kỳ mà việc xử lý nó mất nhiều thời gian hơn
	khoảng thời gian giữa các cặp ngắt liên tiếp.  Điều này có thể
	ngăn không cho trình xử lý kthread và softirq của RCU chạy.
	Lưu ý rằng một số tùy chọn gỡ lỗi có chi phí cao nhất định, chẳng hạn như
	trình theo dõi function_graph, có thể dẫn đến việc xử lý ngắt
	lâu hơn đáng kể so với bình thường, điều này có thể dẫn đến
	Cảnh báo ngừng hoạt động của RCU CPU.

- Kiểm tra khối lượng công việc trên hệ thống nhanh, điều chỉnh cảnh báo ngừng hoạt động
	hết thời gian chờ để tránh được các cảnh báo ngừng hoạt động của RCU CPU, sau đó
	chạy cùng một khối lượng công việc với cùng thời gian chờ cảnh báo ngừng hoạt động trên một
	hệ thống chậm.  Lưu ý rằng bộ điều chỉnh nhiệt và bộ điều tốc theo yêu cầu
	có thể khiến một hệ thống đôi khi nhanh và đôi khi chậm!

- Sự cố phần cứng hoặc phần mềm làm tắt đồng hồ lập lịch
	ngắt trên CPU không ở chế độ không hoạt động.  Cái này
	vấn đề thực sự đã xảy ra và dường như có nhiều khả năng xảy ra nhất
	dẫn đến cảnh báo ngừng hoạt động RCU CPU cho hạt nhân CONFIG_NO_HZ_COMMON=n.

- Sự cố phần cứng hoặc phần mềm ngăn cản việc đánh thức theo thời gian
	khỏi xảy ra.  Những vấn đề này có thể bao gồm từ việc định cấu hình sai hoặc
	phần cứng hẹn giờ có lỗi thông qua các lỗi trong ngắt hoặc ngoại lệ
	đường dẫn (dù là phần cứng, chương trình cơ sở hay phần mềm) thông qua lỗi
	trong hệ thống con hẹn giờ của Linux thông qua các lỗi trong bộ lập lịch và,
	có, thậm chí bao gồm cả lỗi trong chính RCU.  Nó cũng có thể dẫn đến
	thông báo nhật ký bảng điều khiển ZZ0000ZZ,
	sẽ bao gồm thông tin gỡ lỗi bổ sung.

- Sự cố hẹn giờ khiến thời gian dường như nhảy về phía trước, do đó RCU
	tin rằng đã vượt quá thời gian chờ cảnh báo ngừng hoạt động của RCU CPU
	trong khi thực tế thời gian trôi qua còn ít hơn nhiều.  Điều này có thể là do
	lỗi phần cứng hẹn giờ, lỗi trình điều khiển hẹn giờ hoặc thậm chí lỗi của
	biến toàn cục "jiffies".	Những loại phần cứng hẹn giờ này
	và lỗi trình điều khiển không phải là hiếm khi thử nghiệm phần cứng mới.

- Sự cố hạt nhân cấp thấp không thể gọi được một trong các
	các biến thể của rcu_eqs_enter(true), rcu_eqs_exit(true), ct_idle_enter(),
	ct_idle_exit(), ct_irq_enter() hoặc ct_irq_exit() trên một
	tay, hoặc điều đó gọi một trong số chúng quá nhiều lần.
	Trong lịch sử, vấn đề thường gặp nhất là sự thiếu sót
	của irq_enter() hoặc irq_exit(), lần lượt gọi
	lần lượt là ct_irq_enter() hoặc ct_irq_exit().  Xây dựng của bạn
	kernel với CONFIG_RCU_EQS_DEBUG=y có thể giúp theo dõi các loại này
	các vấn đề đôi khi phát sinh trong mã dành riêng cho kiến trúc.

- Lỗi trong quá trình triển khai RCU.

- Lỗi phần cứng.  Điều này rất khó xảy ra, nhưng hoàn toàn không
	không phổ biến ở trung tâm dữ liệu lớn.  Trong một trường hợp đáng nhớ cách đây vài thập kỷ
	quay lại, CPU bị lỗi trong hệ thống đang chạy, không phản hồi,
	nhưng không gây ra sự cố ngay lập tức.  Điều này dẫn đến một loạt
	của cảnh báo ngừng hoạt động của RCU CPU, cuối cùng dẫn đến hiện thực hóa
	rằng CPU đã thất bại.

Việc triển khai RCU, RCU-sched, RCU-task và RCU-tasks-trace có
Cảnh báo ngừng hoạt động CPU.  Lưu ý rằng SRCU ZZ0000ZZ có cảnh báo ngừng hoạt động CPU.
Xin lưu ý rằng RCU chỉ phát hiện các gian hàng của CPU khi có thời gian gia hạn
đang được tiến hành.  Không có thời gian gia hạn, không có cảnh báo ngừng hoạt động của CPU.

Để chẩn đoán nguyên nhân gây ra tình trạng ngừng hoạt động, hãy kiểm tra dấu vết ngăn xếp.
Hàm vi phạm thường sẽ ở gần đầu ngăn xếp.
Nếu bạn có một loạt cảnh báo ngừng hoạt động từ một lần ngừng hoạt động kéo dài,
so sánh dấu vết ngăn xếp thường có thể giúp xác định vị trí ngăn xếp
đang xảy ra, thường sẽ ở hàm gần đỉnh nhất của
phần đó của ngăn xếp được giữ nguyên từ dấu vết này sang dấu vết khác.
Nếu bạn có thể kích hoạt tình trạng ngừng hoạt động một cách đáng tin cậy, thì ftrace có thể khá hữu ích.

Lỗi RCU thường có thể được sửa lỗi với sự trợ giúp của CONFIG_RCU_TRACE
và với tính năng theo dõi sự kiện của RCU.  Để biết thông tin về việc theo dõi sự kiện của RCU,
xem bao gồm/trace/event/rcu.h.


Tinh chỉnh máy dò gian hàng RCU CPU
======================================

Tham số mô-đun rcuupdate.rcu_cpu_stall_suppress vô hiệu hóa RCU
Máy dò gian hàng CPU, phát hiện các điều kiện làm trì hoãn quá mức thời gian gia hạn RCU
thời kỳ.  Tham số mô-đun này cho phép phát hiện gian hàng CPU theo mặc định,
nhưng có thể bị ghi đè thông qua tham số thời gian khởi động hoặc khi chạy thông qua sysfs.
Ý tưởng của máy phát hiện gian hàng về những gì tạo nên "sự chậm trễ quá mức" là
được điều khiển bởi một tập hợp các biến cấu hình kernel và macro cpp:

CONFIG_RCU_CPU_STALL_TIMEOUT
----------------------------

Tham số cấu hình kernel này xác định khoảng thời gian
	RCU đó sẽ đợi từ khi bắt đầu thời gian gia hạn cho đến khi
	đưa ra cảnh báo ngừng hoạt động RCU CPU.  Khoảng thời gian này thường
	21 giây.

Tham số cấu hình này có thể được thay đổi trong thời gian chạy thông qua
	Tuy nhiên, /sys/module/rcupdate/parameters/rcu_cpu_stall_timeout
	tham số này chỉ được kiểm tra khi bắt đầu một chu kỳ.
	Vì vậy, nếu bạn đang ở trong tình trạng dừng 40 giây trong 10 giây, hãy đặt cài đặt này
	tham số sysfs thành (giả sử) năm sẽ rút ngắn thời gian chờ cho
	Gian hàng ZZ0000ZZ hoặc cảnh báo sau cho gian hàng hiện tại
	(giả sử gian hàng tồn tại đủ lâu).  Nó sẽ không ảnh hưởng đến
	thời điểm cảnh báo tiếp theo cho tình trạng ngừng hoạt động hiện tại.

Thông báo cảnh báo ngừng hoạt động có thể được bật và tắt hoàn toàn thông qua
	/sys/module/rcupdate/parameters/rcu_cpu_stall_suppress.

CONFIG_RCU_EXP_CPU_STALL_TIMEOUT
--------------------------------

Tương tự như tham số CONFIG_RCU_CPU_STALL_TIMEOUT nhưng chỉ dành cho
	thời gian ân hạn cấp tốc. Tham số này xác định khoảng thời gian
	thời gian mà RCU sẽ đợi từ khi bắt đầu một quá trình cấp tốc
	thời gian gia hạn cho đến khi nó đưa ra cảnh báo ngừng hoạt động RCU CPU. Lần này
	khoảng thời gian thường là 20 mili giây trên thiết bị Android.	số không
	value khiến giá trị CONFIG_RCU_CPU_STALL_TIMEOUT được sử dụng,
	sau khi chuyển đổi sang mili giây.

Tham số cấu hình này có thể được thay đổi trong thời gian chạy thông qua
	Tuy nhiên, /sys/module/rcupdate/parameters/rcu_exp_cpu_stall_timeout
	tham số này chỉ được kiểm tra khi bắt đầu một chu kỳ. Nếu bạn
	đang trong chu kỳ dừng hiện tại, việc đặt nó thành một giá trị mới sẽ thay đổi
	thời gian chờ cho gian hàng -next-.

Thông báo cảnh báo ngừng hoạt động có thể được bật và tắt hoàn toàn thông qua
	/sys/module/rcupdate/parameters/rcu_cpu_stall_suppress.

RCU_STALL_DELAY_DELTA
---------------------

Mặc dù cơ sở lockdep cực kỳ hữu ích nhưng nó bổ sung thêm
	một số chi phí.  Do đó, theo CONFIG_PROVE_RCU,
	Macro RCU_STALL_DELAY_DELTA cho phép thêm năm giây trước
	đưa ra thông báo cảnh báo ngừng hoạt động RCU CPU.  (Đây là cpp
	macro, không phải tham số cấu hình kernel.)

RCU_STALL_RAT_DELAY
-------------------

Trình phát hiện gian hàng CPU cố gắng làm cho CPU vi phạm in ra
	cảnh báo riêng, vì điều này thường mang lại dấu vết ngăn xếp chất lượng tốt hơn.
	Tuy nhiên, nếu CPU vi phạm không phát hiện ra tình trạng ngừng hoạt động của chính nó trong
	số lượng jiffies được chỉ định bởi RCU_STALL_RAT_DELAY, sau đó
	một số CPU khác sẽ phàn nàn.  Độ trễ này thường được đặt thành
	hai giây lát.  (Đây là macro cpp, không phải cấu hình kernel
	tham số.)

RCupdate.rcu_task_stall_timeout
-------------------------------

Tham số boot/sysfs này điều khiển các tác vụ RCU và
	Khoảng thời gian cảnh báo ngừng theo dõi nhiệm vụ RCU.  Giá trị bằng 0 hoặc ít hơn
	chặn các cảnh báo dừng tác vụ RCU.  Một giá trị dương thiết lập
	khoảng thời gian cảnh báo ngừng hoạt động tính bằng giây.  Cảnh báo dừng tác vụ RCU
	bắt đầu bằng dòng:

INFO: rcu_tasks đã phát hiện thấy các tác vụ bị treo:

Và tiếp tục với đầu ra của sched_show_task() cho mỗi
	nhiệm vụ trì hoãn thời gian gia hạn nhiệm vụ RCU hiện tại.

Cảnh báo ngừng theo dõi nhiệm vụ RCU bắt đầu (và tiếp tục) tương tự:

INFO: rcu_tasks_trace đã phát hiện thấy các tác vụ bị đình trệ


Giải thích "Tấm chắn" RCU của RCU
==============================================

Đối với các phiên bản nhiệm vụ không phải RCU của RCU, khi CPU phát hiện ra một số nhiệm vụ khác
CPU đang bị treo, nó sẽ in thông báo tương tự như sau::

INFO: rcu_sched đã phát hiện tình trạng ngừng hoạt động trên CPU/tác vụ:
	2-...: (3 GP phía sau) nhàn rỗi=06c/0/0 softirq=1453/1455 fqs=0
	16-...: (0 tích tắc GP này) Idle=81c/0/0 softirq=764/764 fqs=0
	(được phát hiện bởi 32, t=2603 jiffies, g=7075, q=625)

Thông báo này cho biết CPU 32 đã phát hiện thấy cả CPU 2 và 16 đều
gây ra tình trạng ngừng hoạt động và việc ngừng hoạt động đã ảnh hưởng đến lịch trình RCU.  Tin nhắn này
thông thường sẽ được theo sau bởi các kết xuất ngăn xếp cho mỗi CPU.  Xin lưu ý rằng
Các bản dựng PREEMPT_RCU có thể bị đình trệ bởi các tác vụ cũng như CPU và điều đó
các nhiệm vụ sẽ được chỉ định bởi PID, ví dụ: "P3421".  Nó thậm chí còn
có thể xảy ra lỗi dừng rcu_state do tác vụ ZZ0000ZZ của cả hai CPU,
trong trường hợp đó, tất cả các CPU và tác vụ vi phạm sẽ bị đưa ra danh sách.
Trong một số trường hợp, CPU sẽ tự phát hiện mình bị đình trệ, điều này sẽ dẫn đến
trong một gian hàng tự phát hiện.

"(3 GP phía sau)" của CPU 2 cho biết rằng CPU này chưa tương tác với
lõi RCU trong ba thời gian gia hạn vừa qua.  Ngược lại, CPU 16 của "(0
đánh dấu GP này)" chỉ ra rằng CPU này chưa thực hiện bất kỳ đồng hồ lập lịch nào
bị gián đoạn trong thời gian gia hạn bị đình trệ hiện tại.

Phần "idle=" của thông báo in trạng thái dyntick-idle.
Số hex trước "/" đầu tiên là 16 bit bậc thấp của
bộ đếm dynticks, sẽ có giá trị số chẵn nếu CPU
đang ở chế độ dyntick-idle và ngược lại là giá trị số lẻ.  Lục giác
số giữa hai "/" là giá trị của phần lồng nhau, sẽ là
một số không âm nhỏ nếu ở vòng lặp nhàn rỗi (như được hiển thị ở trên) và một
ngược lại thì số dương rất lớn.  Con số sau trận chung kết
"/" là tổ NMI, đây sẽ là một số không âm nhỏ.

Phần "softirq=" của tin nhắn theo dõi số lượng softirq RCU
các trình xử lý mà CPU bị đình trệ đã thực thi.  Số trước dấu "/"
là số đã thực thi kể từ khi khởi động tại thời điểm CPU này
lần cuối ghi nhận sự bắt đầu của thời gian gia hạn, có thể là thời gian hiện tại
(bị đình trệ) thời gian gia hạn hoặc có thể là thời gian gia hạn sớm hơn (đối với
ví dụ: nếu CPU có thể đã ở chế độ không tải trong thời gian dài
khoảng thời gian).  Số sau dấu "/" là số đã thực thi
kể từ khi khởi động cho đến thời điểm hiện tại.  Nếu số sau này không đổi
qua các thông báo cảnh báo ngừng hoạt động lặp đi lặp lại, có thể phần mềm của RCU
trình xử lý không còn có thể thực thi trên CPU này nữa.  Điều này có thể xảy ra nếu
CPU bị đình trệ đang quay với các ngắt bị vô hiệu hóa hoặc, trong -rt
hạt nhân, nếu một tiến trình có mức độ ưu tiên cao đang thiếu trình xử lý softirq của RCU.

"fqs=" hiển thị số lượng trạng thái không hoạt động/ngoại tuyến
quá trình phát hiện mà kthread trong thời gian gia hạn đã thực hiện qua điều này
CPU kể từ lần cuối cùng CPU này ghi nhận sự khởi đầu của một ân sủng
kỳ.

Dòng "được phát hiện bởi" cho biết CPU nào đã phát hiện ra tình trạng ngừng hoạt động (trong trường hợp này
trường hợp, CPU 32), bao nhiêu khoảnh khắc đã trôi qua kể từ khi bắt đầu ân sủng
khoảng thời gian (trong trường hợp này là 2603), số thứ tự thời gian gia hạn (7075) và
ước tính tổng số lệnh gọi lại RCU được xếp hàng đợi trên tất cả các CPU
(625 trong trường hợp này).

Nếu thời gian gia hạn kết thúc ngay khi cảnh báo ngừng hoạt động bắt đầu in,
sẽ có một thông báo cảnh báo ngừng hoạt động giả mạo, bao gồm
sau đây::

INFO: Tình trạng ngừng hoạt động đã kết thúc trước khi bắt đầu kết xuất trạng thái

Điều này rất hiếm nhưng thỉnh thoảng vẫn xảy ra trong cuộc sống thực.  Nó cũng là
có thể gắn cờ tình trạng ngừng hoạt động ngay lập tức trong trường hợp này, tùy thuộc vào
về cách xảy ra cảnh báo ngừng hoạt động và khởi tạo thời gian gia hạn
tương tác.  Xin lưu ý rằng không thể loại bỏ hoàn toàn điều này
loại dương tính giả mà không cần dùng đến những thứ như stop_machine(),
đó là quá mức cần thiết cho loại vấn đề này.

Nếu tất cả CPU và tác vụ đã chuyển qua trạng thái không hoạt động, nhưng
Tuy nhiên, thời gian gia hạn vẫn chưa kết thúc, biểu tượng cảnh báo ngừng hoạt động
sẽ bao gồm một cái gì đó như sau::

Tất cả các QS đã thấy, hoạt động kthread rcu_preempt cuối cùng 23807 (4297905177-4297881370), jiffies_till_next_fqs=3, root ->qsmask 0x0

Số "23807" cho biết đã hơn 23 nghìn giây phút
kể từ khi kthread thời gian gia hạn chạy.  "jiffies_till_next_fqs"
cho biết tần suất chạy kthread đó, đưa ra số
trong khoảng thời gian ngắn giữa các lần quét ở trạng thái tĩnh, trong trường hợp này là ba,
nhỏ hơn 23807. Cuối cùng, cấu trúc rcu_node gốc
-> Trường qsmask được in, thông thường sẽ bằng 0.

Nếu kthread trong thời gian gia hạn có liên quan không thể chạy trước
cảnh báo ngừng hoạt động, như trường hợp trong dòng "Tất cả các QS đã thấy" ở trên,
dòng bổ sung sau được in::

rcu_sched kthread bị bỏ đói trong 23807 giây phút! g7075 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1 ->cpu=5
	Trừ khi rcu_sched kthread có đủ thời gian CPU, OOM hiện là hành vi được mong đợi.

Tất nhiên, việc bỏ đói kthread thời gian gia hạn của CPU có thể dẫn đến kết quả
trong RCU CPU cảnh báo ngừng hoạt động ngay cả khi tất cả CPU và tác vụ đã hoàn thành
qua các trạng thái tĩnh cần thiết.  Số "g" hiển thị hiện tại
số thứ tự thời gian gia hạn, "f" đứng trước lệnh ->gp_flags
đối với kthread trong thời gian gia hạn, "RCU_GP_WAIT_FQS" chỉ ra rằng
kthread đang chờ một khoảng thời gian chờ ngắn, "trạng thái" đứng trước giá trị của
task_struct ->trường trạng thái và "cpu" cho biết thời gian gia hạn
kthread chạy lần cuối trên CPU 5.

Nếu kthread trong thời gian gia hạn có liên quan không hoạt động từ FQS, hãy đợi trong một
thời gian hợp lý thì dòng bổ sung sau sẽ được in::

Việc đánh thức bộ hẹn giờ kthread đã không xảy ra trong 23804 giây phút! g7076 f0x0 RCU_GP_WAIT_FQS(5) ->state=0x402

"23804" cho biết bộ đếm thời gian của kthread đã hết hạn hơn 23 nghìn
cách đây không lâu.  Phần còn lại của dòng có ý nghĩa tương tự như kthread
trường hợp chết đói

Ngoài ra, dòng sau được in::

Sự cố xử lý hẹn giờ có thể xảy ra trên cpu=4 clock-softirq=11142

Ở đây "cpu" chỉ ra rằng kthread trong thời gian gia hạn đã chạy lần cuối trên CPU 4,
nơi nó xếp hàng bộ đếm thời gian fqs.  Số theo sau "timer-softirq"
là số lượng ZZ0000ZZ hiện tại trên cpu 4. Nếu giá trị này không
thay đổi trong các cảnh báo ngừng hoạt động liên tiếp của RCU CPU, thì có thêm lý do để
nghi ngờ có vấn đề về bộ đếm thời gian.

Những thông báo này thường được theo sau bởi các kết xuất ngăn xếp của CPU và tác vụ
tham gia vào gian hàng.  Những dấu vết ngăn xếp này có thể giúp bạn xác định nguyên nhân
của gian hàng, hãy nhớ rằng CPU phát hiện gian hàng sẽ có
một khung ngắt chủ yếu dành cho việc phát hiện tình trạng ngừng hoạt động.


Nhiều cảnh báo từ một gian hàng
================================

Nếu tình trạng ngừng hoạt động đủ lâu, nhiều thông báo cảnh báo tình trạng ngừng hoạt động sẽ
được in cho nó.  Tin nhắn thứ hai và các tin nhắn tiếp theo được in tại
khoảng thời gian dài hơn, do đó thời gian giữa (ví dụ) lần đầu tiên và lần thứ hai
tin nhắn sẽ gấp khoảng ba lần khoảng thời gian giữa lúc bắt đầu
của gian hàng và tin nhắn đầu tiên.  Nó có thể hữu ích để so sánh các
xếp chồng các tin nhắn khác nhau trong cùng một khoảng thời gian gia hạn bị đình trệ.


Cảnh báo ngừng hoạt động trong thời gian gia hạn nhanh
==========================================

Nếu thời gian gia hạn nhanh phát hiện tình trạng ngừng hoạt động, nó sẽ đặt một thông báo
như sau trong dmesg ::

INFO: rcu_sched đã phát hiện tình trạng ngừng hoạt động nhanh trên CPU/tác vụ: { 7-... } 21119 jiffies s: 73 root: 0x2/.

Điều này cho thấy CPU 7 đã không phản hồi với việc lên lịch lại IPI.
Ba dấu chấm (".") theo sau số CPU cho biết CPU
đang trực tuyến (nếu không thì tiết đầu tiên sẽ là "O"),
rằng CPU đã trực tuyến khi bắt đầu thời gian gia hạn cấp tốc
(nếu không thì tiết thứ hai sẽ là "o"), và đó
CPU đã trực tuyến ít nhất một lần kể từ khi khởi động (nếu không, lần thứ ba
thay vào đó, dấu chấm sẽ là "N").  Con số trước "jiffies"
chỉ ra rằng thời gian gia hạn nhanh đã diễn ra trong 21.119
nháy mắt.  Số theo sau "s:" biểu thị rằng thời gian thực hiện nhanh
bộ đếm chuỗi thời gian gia hạn là 73. Thực tế là giá trị cuối cùng này là
số lẻ chỉ ra rằng thời gian gia hạn nhanh đang được triển khai.  số
"root:" sau đây là một bitmask cho biết con nào của root
Cấu trúc rcu_node tương ứng với CPU và/hoặc tác vụ đang chặn
thời gian ân hạn cấp tốc hiện tại.  Nếu cây có nhiều hơn một cấp độ,
số hex bổ sung sẽ được in cho các trạng thái khác
cấu trúc rcu_node trong cây.

Giống như thời gian gia hạn thông thường, các bản dựng PREEMPT_RCU có thể bị đình trệ bởi
các tác vụ cũng như của CPU và các tác vụ đó sẽ được chỉ định bởi PID,
ví dụ: "P3421".

Hoàn toàn có thể thấy cảnh báo chết máy từ bình thường và từ
thời gian gia hạn nhanh vào cùng thời điểm trong cùng một lần chạy.

RCU_CPU_STALL_CPUTIME
=====================

Trong các hạt nhân được xây dựng bằng CONFIG_RCU_CPU_STALL_CPUTIME=y hoặc được khởi động bằng
rcupdate.rcu_cpu_stall_cputime=1, thông tin bổ sung sau
được cung cấp cùng với mỗi cảnh báo ngừng hoạt động RCU CPU::

rcu: hardirqs softirqs csw/system
  rcu: số: 624 45 0
  rcu: cputime: 69 1 2425 ==> 2500(ms)

Những số liệu thống kê này được thu thập trong thời gian lấy mẫu. Các giá trị
trong hàng "số:" là số lượng ngắt cứng, số lượng ngắt mềm
ngắt và số lượng công tắc ngữ cảnh trên CPU bị đình trệ. các
ba giá trị đầu tiên trong hàng "cputime:" cho biết thời gian CPU trong
mili giây được tiêu tốn bởi các ngắt cứng, ngắt mềm và các tác vụ
trên CPU bị đình trệ.  Số cuối cùng là khoảng thời gian đo
tính bằng mili giây.  Bởi vì các tác vụ ở chế độ người dùng thông thường không gây ra RCU CPU
bị đình trệ, những tác vụ này thường là các tác vụ cốt lõi, đó là lý do tại sao chỉ có
hệ thống CPU thời gian được xem xét.

Khoảng thời gian lấy mẫu được thể hiện như sau::

ZZ0000ZZ<------thời gian chờ thứ hai----->|
  ZZ0001ZZ<-thời gian chờ một nửa -->ZZ0002ZZ
  ZZ0003ZZ<-tiết đầu tiên-->ZZ0004ZZ
  ZZ0005ZZ<-------------thời gian lấy mẫu thứ hai---------->|
  ZZ0006ZZ ZZ0007ZZ
             điểm thời gian chụp nhanh

Sau đây mô tả bốn tình huống điển hình:

1. Vòng lặp CPU bị vô hiệu hóa các ngắt.

   ::

rcu: hardirqs softirqs csw/system
     rcu: số: 0 0 0
     rcu: cputime: 0 0 0 ==> 2500(ms)

Bởi vì các ngắt đã bị vô hiệu hóa trong suốt quá trình đo
   khoảng thời gian, không có ngắt và không có chuyển đổi ngữ cảnh.
   Hơn nữa, vì mức tiêu thụ thời gian của CPU được đo bằng cách sử dụng ngắt
   trình xử lý, mức tiêu thụ CPU của hệ thống được đo lường sai lệch bằng 0.
   Kịch bản này thường sẽ có dòng chữ "(0 đánh dấu GP này)" được in trên
   dòng tóm tắt của CPU này.

2. Vòng lặp CPU với nửa dưới bị vô hiệu hóa.

Điều này tương tự như ví dụ trước, nhưng với số lượng khác 0
   và thời gian CPU bị tiêu tốn bởi các ngắt cứng, cùng với CPU khác 0
   thời gian tiêu thụ khi thực thi trong kernel::

rcu: hardirqs softirqs csw/system
     rcu: số: 624 0 0
     rcu: cputime: 49 0 2446 ==> 2500(ms)

Thực tế là không có softirq nào cho thấy đây là
   bị vô hiệu hóa, có thể thông qua local_bh_disable().  Tất nhiên là có thể
   rằng không có softirq, có lẽ bởi vì tất cả các sự kiện sẽ
   dẫn đến việc thực thi softirq bị giới hạn ở các CPU khác.  Trong trường hợp này,
   chẩn đoán sẽ tiếp tục như trong ví dụ tiếp theo.

3. Vòng lặp CPU bị vô hiệu hóa quyền ưu tiên.

Ở đây, chỉ có số lượng chuyển đổi ngữ cảnh là 0::

rcu: hardirqs softirqs csw/system
     rcu: số: 624 45 0
     rcu: cputime: 69 1 2425 ==> 2500(ms)

Tình huống này gợi ý rằng CPU bị đình trệ đang lặp lại với quyền ưu tiên
   bị vô hiệu hóa.

4. Không lặp, nhưng ngắt quãng cứng và mềm lớn.

   ::

rcu: hardirqs softirqs csw/system
     rcu: số: xx xx 0
     rcu: cputime: xx xx 0 ==> 2500(ms)

Ở đây, số lượng và thời gian CPU của các ngắt cứng đều khác 0,
   nhưng số lần chuyển ngữ cảnh và thời gian CPU trong kernel đã tiêu thụ
   là số không. Số lượng và thời gian CPU của các ngắt mềm thường sẽ là
   khác 0, nhưng có thể bằng 0, ví dụ: nếu CPU đang quay
   trong một trình xử lý ngắt cứng duy nhất.

Nếu loại cảnh báo ngừng hoạt động RCU CPU này có thể được sao chép, bạn có thể
   thu hẹp nó bằng cách xem /proc/interrupts hoặc bằng cách viết mã vào
   Ví dụ: theo dõi từng ngắt bằng cách tham khảo show_interrupts().