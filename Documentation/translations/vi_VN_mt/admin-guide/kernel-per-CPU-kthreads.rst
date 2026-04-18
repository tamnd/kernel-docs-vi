.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/kernel-per-CPU-kthreads.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================================
Giảm hiện tượng giật hệ điều hành do kthread trên mỗi CPU
==========================================

Tài liệu này liệt kê các kthread trên mỗi CPU trong nhân Linux và trình bày
các tùy chọn để kiểm soát jitter hệ điều hành của họ.  Lưu ý rằng các kthread không phải theo CPU là
không được liệt kê ở đây.  Để giảm hiện tượng jitter của hệ điều hành khỏi các kthread không phải trên mỗi CPU, hãy liên kết
họ đến một "người dọn phòng" CPU chuyên làm công việc đó.

Tài liệu tham khảo
==========

- Documentation/core-api/irq/irq-affinity.rst: Liên kết các ngắt với các bộ CPU.

- Documentation/admin-guide/cgroup-v1: Sử dụng cgroups để liên kết các tác vụ với các bộ CPU.

- man tasket: Sử dụng lệnh tasket để liên kết các tác vụ với các tập hợp
	của CPU.

- man sched_setaffinity: Sử dụng hệ thống sched_setaffinity()
	gọi để liên kết các tác vụ với các bộ CPU.

- /sys/devices/system/cpu/cpuN/online: Kiểm soát trạng thái cắm nóng của CPU N,
	viết "0" vào ngoại tuyến và "1" vào trực tuyến.

- Để xác định vị trí jitter hệ điều hành do kernel tạo trên CPU N:

cd /sys/kernel/truy tìm
		echo 1 > max_graph_deep # Increase the "1" để biết thêm chi tiết
		hàm echo_graph > current_tracer
		Khối lượng công việc # run
		mèo per_cpu/cpuN/dấu vết

kthreads
========

Tên:
  ehca_comp/%u

Mục đích:
  Định kỳ xử lý các công việc liên quan đến Infiniband.

Để giảm hiện tượng giật hệ điều hành, hãy thực hiện bất kỳ thao tác nào sau đây:

1. Không sử dụng phần cứng eHCA Infiniband, thay vào đó hãy chọn phần cứng
	không yêu cầu kthread trên mỗi CPU.  Điều này sẽ ngăn chặn những
	kthreads khỏi được tạo ngay từ đầu.  (Điều này sẽ
	làm việc cho hầu hết mọi người, vì phần cứng này, mặc dù quan trọng,
	tương đối cũ và được sản xuất với số lượng đơn vị tương đối thấp.)
2. Thực hiện tất cả công việc liên quan đến eHCA-Infiniband trên các CPU khác, bao gồm
	ngắt quãng.
3. Làm lại trình điều khiển eHCA sao cho các luồng kthread trên mỗi CPU của nó
	chỉ được cung cấp trên các CPU được chọn.


Tên:
  irq/%d-%s

Mục đích:
  Xử lý các ngắt theo luồng.

Để giảm hiện tượng giật hệ điều hành, hãy làm như sau:

1. Sử dụng ái lực irq để buộc các luồng irq thực thi trên
	một số CPU khác.

Tên:
  kcmtpd_ctr_%d

Mục đích:
  Xử lý công việc Bluetooth.

Để giảm hiện tượng giật hệ điều hành, hãy thực hiện một trong các thao tác sau:

1. Không sử dụng Bluetooth, trong trường hợp đó các kthread này sẽ không hoạt động
	được tạo ra ngay từ đầu.
2. Sử dụng ái lực irq để buộc các ngắt liên quan đến Bluetooth
	xảy ra trên một số CPU khác và hơn nữa còn bắt đầu tất cả
	Hoạt động Bluetooth trên một số CPU khác.

Tên:
  ksoftirqd/%u

Mục đích:
  Thực thi các trình xử lý softirq khi phân luồng hoặc khi tải nặng.

Để giảm jitter hệ điều hành của nó, mỗi vectơ softirq phải được xử lý
riêng biệt như sau:

TIMER_SOFTIRQ
-------------

Thực hiện tất cả những điều sau:

1. Trong phạm vi có thể, hãy loại CPU ra khỏi kernel khi nó
	không ở trạng thái rảnh rỗi, chẳng hạn như bằng cách tránh các cuộc gọi hệ thống và bằng cách buộc
	cả các luồng nhân và các ngắt để thực thi ở nơi khác.
2. Xây dựng với CONFIG_HOTPLUG_CPU=y.  Sau khi khởi động xong, buộc
	CPU ngoại tuyến, sau đó đưa nó trở lại trực tuyến.  Lực lượng này
	bộ tính giờ định kỳ để di chuyển đi nơi khác.	Nếu bạn quan tâm
	với nhiều CPU, hãy buộc tất cả chúng ngoại tuyến trước khi đưa
	đầu tiên trở lại trực tuyến.  Khi bạn đã kết nối trực tuyến các CPU được đề cập,
	không ngoại tuyến bất kỳ CPU nào khác vì làm như vậy có thể buộc
	hẹn giờ trở lại một trong các CPU được đề cập.

NET_TX_SOFTIRQ và NET_RX_SOFTIRQ
---------------------------------

Thực hiện tất cả những điều sau:

1. Buộc ngắt mạng trên các CPU khác.
2. Bắt đầu bất kỳ I/O mạng nào trên các CPU khác.
3. Khi ứng dụng của bạn đã khởi động, hãy ngăn chặn các hoạt động cắm nóng CPU
	từ việc được bắt đầu từ các tác vụ có thể chạy trên CPU đến
	được bớt bồn chồn.  (Bạn buộc CPU này ngoại tuyến là được rồi
	mang nó trở lại trực tuyến trước khi bạn bắt đầu ứng dụng của mình.)

BLOCK_SOFTIRQ
-------------

Thực hiện tất cả những điều sau:

1. Buộc ngắt thiết bị khối trên một số CPU khác.
2. Bắt đầu bất kỳ khối I/O nào trên các CPU khác.
3. Khi ứng dụng của bạn đã khởi động, hãy ngăn chặn các hoạt động cắm nóng CPU
	từ việc được bắt đầu từ các tác vụ có thể chạy trên CPU đến
	được bớt bồn chồn.  (Bạn buộc CPU này ngoại tuyến là được rồi
	mang nó trở lại trực tuyến trước khi bạn bắt đầu ứng dụng của mình.)

IRQ_POLL_SOFTIRQ
----------------

Thực hiện tất cả những điều sau:

1. Buộc ngắt thiết bị khối trên một số CPU khác.
2. Bắt đầu bất kỳ hoạt động thăm dò khối I/O và khối I/O nào trên các CPU khác.
3. Khi ứng dụng của bạn đã khởi động, hãy ngăn chặn các hoạt động cắm nóng CPU
	từ việc được bắt đầu từ các tác vụ có thể chạy trên CPU đến
	được bớt bồn chồn.  (Bạn buộc CPU này ngoại tuyến là được rồi
	mang nó trở lại trực tuyến trước khi bạn bắt đầu ứng dụng của mình.)

TASKLET_SOFTIRQ
---------------

Thực hiện một hoặc nhiều thao tác sau:

1. Tránh sử dụng trình điều khiển sử dụng tasklets.  (Các trình điều khiển như vậy sẽ chứa
	gọi những thứ như tasklet_schedule().)
2. Chuyển đổi tất cả các trình điều khiển mà bạn phải sử dụng từ tác vụ nhỏ sang hàng công việc.
3. Buộc ngắt đối với trình điều khiển sử dụng tasklet trên các CPU khác,
	và cũng thực hiện I/O liên quan đến các trình điều khiển này trên các CPU khác.

SCHED_SOFTIRQ
-------------

Thực hiện tất cả những điều sau:

1. Tránh gửi IPI của bộ lập lịch tới CPU để khử nhiễu,
	ví dụ: đảm bảo rằng có nhiều nhất một kthread có thể chạy được
	trên chiếc CPU đó.  Nếu một luồng dự kiến sẽ chạy trên nền tảng không bị xáo trộn
	CPU thức tỉnh, bộ lập lịch sẽ gửi một IPI có thể dẫn đến
	một chiếc SCHED_SOFTIRQ tiếp theo.
2. CONFIG_NO_HZ_FULL=y và đảm bảo rằng CPU không bị biến dạng
	được đánh dấu là dấu tích thích ứng CPU bằng cách sử dụng "nohz_full="
	tham số khởi động.  Điều này làm giảm số lượng đồng hồ lập lịch
	ngắt mà CPU đã khử jitter nhận được, giảm thiểu
	cơ hội được chọn để thực hiện công việc cân bằng tải
	chạy trong ngữ cảnh SCHED_SOFTIRQ.
3. Trong phạm vi có thể, hãy loại CPU ra khỏi kernel khi nó
	không ở chế độ rảnh, ví dụ như bằng cách tránh các cuộc gọi hệ thống và bằng cách
	buộc cả luồng nhân và ngắt phải thực thi ở nơi khác.
	Điều này càng làm giảm số lần ngắt đồng hồ lập lịch
	được nhận bởi CPU đã khử jitter.

HRTIMER_SOFTIRQ
---------------

Thực hiện tất cả những điều sau:

1. Trong phạm vi có thể, hãy loại CPU ra khỏi kernel khi nó
	không nhàn rỗi.  Ví dụ: tránh các cuộc gọi hệ thống và buộc cả hai
	các luồng nhân và các ngắt để thực thi ở nơi khác.
2. Xây dựng với CONFIG_HOTPLUG_CPU=y.  Sau khi khởi động xong, buộc
	CPU ngoại tuyến, sau đó đưa nó trực tuyến trở lại.  Lực lượng này tái diễn
	bộ tính giờ để di chuyển đi nơi khác.  Nếu bạn quan tâm đến nhiều
	CPU, buộc tất cả ngoại tuyến trước khi mang cái đầu tiên
	trở lại trực tuyến.  Khi bạn đã kết nối trực tuyến các CPU được đề cập, đừng
	ngoại tuyến bất kỳ CPU nào khác, vì làm như vậy có thể buộc bộ hẹn giờ
	trở lại một trong các CPU được đề cập.

RCU_SOFTIRQ
-----------

Thực hiện ít nhất một trong những điều sau:

1. Giảm tải các cuộc gọi lại và giữ CPU ở chế độ không hoạt động hoặc
	trạng thái Adaptive-Tick bằng cách thực hiện tất cả những điều sau:

Một.	CONFIG_NO_HZ_FULL=y và đảm bảo rằng CPU
		khử jittered được đánh dấu là CPU thích ứng bằng cách sử dụng
		tham số khởi động "nohz_full=".  Rcuo kthreads liên kết với
		CPU vệ sinh, có thể chịu được hiện tượng giật hệ điều hành.
	b.	Trong phạm vi có thể, hãy loại bỏ CPU khỏi kernel
		khi nó không ở chế độ rảnh, ví dụ, bằng cách tránh hệ thống
		các cuộc gọi và bằng cách buộc cả các luồng nhân và các ngắt
		để thực hiện ở nơi khác.

2. Cho phép RCU thực hiện xử lý từ xa thông qua dyntick-idle bằng cách
	thực hiện tất cả những điều sau đây:

Một.	Xây dựng với CONFIG_NO_HZ=y.
	b.	Đảm bảo rằng CPU thường xuyên không hoạt động, cho phép các thiết bị khác
		CPU để phát hiện rằng nó đã đi qua trạng thái không hoạt động RCU
		trạng thái.	Nếu kernel được xây dựng với CONFIG_NO_HZ_FULL=y,
		Việc thực thi vùng người dùng cũng cho phép các CPU khác phát hiện ra điều đó
		CPU được đề cập đã chuyển qua trạng thái không hoạt động.
	c.	Trong phạm vi có thể, hãy loại bỏ CPU khỏi kernel
		khi nó không ở chế độ rảnh, ví dụ, bằng cách tránh hệ thống
		các cuộc gọi và bằng cách buộc cả các luồng nhân và các ngắt
		để thực hiện ở nơi khác.

Tên:
  kworker/%u:%d%s (cpu, id, mức độ ưu tiên)

Mục đích:
  Thực hiện các yêu cầu hàng đợi công việc

Để giảm hiện tượng giật hệ điều hành, hãy thực hiện bất kỳ thao tác nào sau đây:

1. Chạy khối lượng công việc của bạn ở mức độ ưu tiên theo thời gian thực, điều này sẽ cho phép
	ưu tiên các daemon kworker.
2. Một hàng công việc nhất định có thể được hiển thị trong hệ thống tệp sysfs
	bằng cách chuyển WQ_SYSFS tới alloc_workqueue() của hàng đợi công việc đó.
	Hàng đợi công việc như vậy có thể được giới hạn trong một tập hợp con nhất định của
	CPU sử dụng hệ thống ZZ0000ZZ
	tập tin.	Tập hợp các hàng công việc WQ_SYSFS có thể được hiển thị bằng cách sử dụng
	"ls/sys/thiết bị/ảo/hàng công việc".  Điều đó nói lên rằng, hàng đợi công việc
	người bảo trì muốn cảnh báo mọi người chống lại việc sử dụng bừa bãi
	rải WQ_SYSFS trên tất cả các hàng công việc.	Lý do cho
	cần lưu ý rằng việc thêm WQ_SYSFS rất dễ dàng, nhưng vì sysfs là
	một phần của người dùng/kernel chính thức API, điều đó gần như không thể
	để loại bỏ nó, ngay cả khi việc bổ sung nó là một sai lầm.
3. Thực hiện bất kỳ thao tác nào sau đây cần thiết để tránh hiện tượng giật hình
	ứng dụng không thể chịu đựng được:

Một.	Tránh sử dụng oprofile, do đó tránh được tình trạng jitter hệ điều hành từ
		wq_sync_buffer().
	b.	Giới hạn tần số CPU của bạn để tần số CPU
		thống đốc là không cần thiết, có thể tranh thủ sự trợ giúp của
		tản nhiệt đặc biệt hoặc các công nghệ làm mát khác.  Nếu xong
		chính xác và nếu kiến trúc CPU cho phép, bạn nên
		có thể xây dựng kernel của bạn với CONFIG_CPU_FREQ=n để
		tránh chạy định kỳ bộ điều chỉnh tần số CPU
		trên mỗi CPU, bao gồm cs_dbs_timer() và od_dbs_timer().

WARNING: Vui lòng kiểm tra thông số kỹ thuật CPU của bạn để
		đảm bảo rằng điều này an toàn trên hệ thống cụ thể của bạn.
	c.	Kể từ v3.18, nhân viên vmstat theo yêu cầu của Christoph Lameter
		cam kết ngăn chặn tình trạng jitter hệ điều hành do bật vmstat_update()
		Hệ thống CONFIG_SMP=y.  Trước v3.18, không thể thực hiện được
		để loại bỏ hoàn toàn tình trạng chập chờn của hệ điều hành, nhưng bạn có thể
		giảm tần số của nó bằng cách viết một giá trị lớn vào
		/proc/sys/vm/stat_interval.  Giá trị mặc định là HZ,
		trong khoảng thời gian một giây.	Tất nhiên, giá trị lớn hơn
		sẽ làm cho số liệu thống kê bộ nhớ ảo của bạn cập nhật nhiều hơn
		từ từ.  Tất nhiên, bạn cũng có thể chạy khối lượng công việc của mình tại
		mức độ ưu tiên theo thời gian thực, do đó ưu tiên vmstat_update(),
		nhưng nếu khối lượng công việc của bạn bị ràng buộc bởi CPU thì đây là một ý tưởng tồi.
		Tuy nhiên, có bản vá RFC từ Christoph Lameter
		(dựa trên câu chuyện trước đó của Gilad Ben-Yossef)
		giảm hoặc thậm chí loại bỏ chi phí vmstat cho một số
		khối lượng công việc tại ZZ0000ZZ
	d.	Nếu chạy trên máy chủ powerpc cao cấp, hãy xây dựng với
		CONFIG_PPC_RTAS_DAEMON=n.  Điều này ngăn cản RTAS
		daemon chạy trên mỗi CPU mỗi giây hoặc lâu hơn.
		(Điều này sẽ yêu cầu chỉnh sửa các tập tin Kconfig và sẽ đánh bại
		chức năng RAS của nền tảng này.) Điều này tránh hiện tượng giật hình
		do hàm rtas_event_scan().
		WARNING: Vui lòng kiểm tra thông số kỹ thuật CPU của bạn để
		đảm bảo rằng điều này an toàn trên hệ thống cụ thể của bạn.
	đ.	Nếu chạy trên PowerMAC, hãy xây dựng kernel của bạn bằng
		CONFIG_PMAC_RACKMETER=n để vô hiệu hóa máy đo CPU,
		tránh hiện tượng giật hệ điều hành từ rackmeter_do_timer().

Tên:
  rcuc/%u

Mục đích:
  Thực hiện lệnh gọi lại RCU trong hạt nhân CONFIG_RCU_BOOST=y.

Để giảm hiện tượng giật hệ điều hành, hãy thực hiện ít nhất một trong các thao tác sau:

1. Xây dựng kernel với CONFIG_PREEMPT=n.  Điều này ngăn cản những
	kthreads khỏi được tạo ngay từ đầu và cũng ngăn chặn
	nhu cầu tăng cường mức độ ưu tiên của RCU.  Cách tiếp cận này khả thi
	dành cho những khối lượng công việc không yêu cầu mức độ đáp ứng cao.
2. Xây dựng kernel với CONFIG_RCU_BOOST=n.  Điều này ngăn cản những
	kthreads khỏi được tạo ngay từ đầu.  Cách tiếp cận này
	chỉ khả thi nếu khối lượng công việc của bạn không bao giờ yêu cầu mức độ ưu tiên RCU
	tăng tốc, ví dụ: nếu bạn đảm bảo thời gian nhàn rỗi thường xuyên trên tất cả
	CPU có thể thực thi trong kernel.
3. Xây dựng với CONFIG_RCU_NOCB_CPU=y và khởi động bằng rcu_nocbs=
	giảm tải tham số khởi động lệnh gọi lại RCU từ tất cả các CPU dễ bị ảnh hưởng
	đến jitter hệ điều hành.  Cách tiếp cận này ngăn không cho các luồng RCuc/%u kthread
	có việc gì phải làm, để họ không bao giờ bị đánh thức.
4. Đảm bảo rằng CPU không bao giờ xâm nhập vào kernel và đặc biệt là
	tránh thực hiện bất kỳ thao tác cắm nóng CPU nào trên CPU này.  Đây là
	một cách khác để ngăn chặn bất kỳ lệnh gọi lại nào được xếp hàng đợi trên
	CPU, một lần nữa lại ngăn cản kthread rcuc/%u thực hiện bất kỳ công việc nào
	để làm.

Tên:
  rcuop/%d, rcuos/%d và rcuog/%d

Mục đích:
  Giảm tải các lệnh gọi lại RCU từ CPU tương ứng.

Để giảm hiện tượng giật hệ điều hành, hãy thực hiện ít nhất một trong các thao tác sau:

1. Sử dụng ái lực, nhóm hoặc cơ chế khác để buộc các kthread này
	để thực thi trên một số CPU khác.
2. Xây dựng với CONFIG_RCU_NOCB_CPU=n, điều này sẽ ngăn chặn những điều này
	kthreads khỏi được tạo ngay từ đầu.  Tuy nhiên, xin vui lòng
	lưu ý rằng điều này sẽ không loại bỏ hiện tượng giật hệ điều hành mà thay vào đó sẽ
	chuyển nó sang RCU_SOFTIRQ.
