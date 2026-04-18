.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/timerlat-tracer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

################
Timerlat máy theo dõi
###############

Công cụ theo dõi timelat nhằm mục đích giúp các nhà phát triển hạt nhân ưu tiên
tìm nguồn gốc của độ trễ đánh thức của các luồng thời gian thực. Giống như kiểm tra chu kỳ,
trình theo dõi đặt bộ hẹn giờ định kỳ để đánh thức một luồng. Sợi dây sau đó
tính toán giá trị ZZ0000ZZ là chênh lệch giữa *hiện tại
time* và ZZ0001ZZ mà bộ hẹn giờ được đặt hết hạn. chính
Mục tiêu của timelat là truy tìm theo cách giúp các nhà phát triển hạt nhân.

Cách sử dụng
-----

Viết văn bản ASCII "timerlat" vào tệp current_tracer của
hệ thống theo dõi (thường được gắn tại /sys/kernel/tracing).

Ví dụ::

[root@f32 ~]# cd /sys/kernel/tracing/
        [truy tìm root@f32]Bộ đếm thời gian # echo > current_tracer

Có thể theo dõi dấu vết bằng cách đọc tệp dấu vết::

[truy tìm root@f32]Dấu vết # cat
  # tracer: hẹn giờ
  #
  #                              _-----=> không hoạt động
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # || /
  # ||||             ACTIVATION
  #         ZZ0005ZZ-ZZ0006ZZ CPU# ||||   TIMESTAMP ID CONTEXT LATENCY
  #            ZZ0011ZZ ZZ0001ZZ||ZZ0002ZZ ZZ0003ZZ |
          <nhàn rỗi>-0 [000] d.h1 54.029328: #1 bối cảnh irq time_latency 932 ns
           <...>-867 [000] .... 54.029339: #1 chuỗi ngữ cảnh hẹn giờ_latency 11700 ns
          <nhàn rỗi>-0 [001] dNh1 54.029346: #1 bối cảnh irq time_latency 2833 ns
           <...>-868 [001] .... 54.029353: #1 chuỗi ngữ cảnh hẹn giờ_latency 9820 ns
          <nhàn rỗi>-0 [000] d.h1 54.030328: #2 bối cảnh irq time_latency 769 ns
           <...>-867 [000] .... 54.030330: #2 chuỗi ngữ cảnh time_latency 3070 ns
          <nhàn rỗi>-0 [001] d.h1 54.030344: #2 bối cảnh irq time_latency 935 ns
           <...>-868 [001] .... 54.030347: #2 chuỗi ngữ cảnh time_latency 4351 ns


Trình theo dõi tạo luồng nhân trên mỗi CPU với mức độ ưu tiên theo thời gian thực
SCHED_FIFO:95 in hai dòng mỗi lần kích hoạt. Đầu tiên là
ZZ0000ZZ được quan sát tại bối cảnh ZZ0001ZZ trước khi kích hoạt
của sợi chỉ. Thứ hai là ZZ0002ZZ được quan sát bởi luồng.
Trường ID ACTIVATION dùng để liên kết việc thực thi ZZ0003ZZ với
thực thi ZZ0004ZZ tương ứng.

Việc phân tách ZZ0000ZZ/ZZ0001ZZ rất quan trọng để làm rõ bối cảnh nào
giá trị cao bất ngờ đang đến từ đó. Bối cảnh ZZ0002ZZ có thể
bị trì hoãn bởi các hành động liên quan đến phần cứng, chẳng hạn như SMI, NMI, IRQ,
hoặc bằng cách ngắt mặt nạ luồng. Khi bộ hẹn giờ xảy ra, độ trễ
cũng có thể bị ảnh hưởng bởi việc chặn do chủ đề gây ra. Ví dụ, bởi
hoãn việc thực thi bộ lập lịch thông qua preempt_disable(), bộ lập lịch
thực thi hoặc che dấu các ngắt. Các chủ đề cũng có thể bị trì hoãn bởi
nhiễu từ các luồng và IRQ khác.

Tùy chọn theo dõi
---------------------

Bộ theo dõi thời gian được xây dựng dựa trên bộ theo dõi tiếng ồn.
Vậy là cấu hình của nó cũng được thực hiện trong osnoise/config
thư mục. Cấu hình của bộ đếm thời gian là:

- cpus: CPU tại đó một thread clocklat sẽ thực thi.
 - timelat_ Period_us: khoảng thời gian của thread timelat.
 - stop_tracing_us: dừng việc theo dõi hệ thống nếu có
   độ trễ hẹn giờ ở bối cảnh ZZ0000ZZ cao hơn cấu hình
   giá trị xảy ra. Viết 0 sẽ vô hiệu hóa tùy chọn này.
 - stop_tracing_total_us: dừng việc theo dõi hệ thống nếu có
   độ trễ hẹn giờ ở bối cảnh ZZ0001ZZ cao hơn so với cấu hình
   giá trị xảy ra. Viết 0 sẽ vô hiệu hóa tùy chọn này.
 - print_stack: lưu ngăn xếp xảy ra IRQ. Ngăn xếp được in
   sau sự kiện ZZ0002ZZ hoặc tại trình xử lý IRQ nếu ZZ0003ZZ
   bị đánh.

hẹn giờ và osnoise
----------------------------

Bộ đếm thời gian cũng có thể tận dụng osnoise: traceevents.
Ví dụ::

[root@f32 ~]# cd /sys/kernel/tracing/
        [truy tìm root@f32]Bộ đếm thời gian # echo > current_tracer
        [truy tìm root@f32]# echo 1 > sự kiện/osnoise/bật
        [root@f32 tracing]# echo 25 > osnoise/stop_tracing_total_us
        [truy tìm root@f32]Dấu vết # tail -10
             cc1-87882 [005] d..h... 548.771078: #402268 bối cảnh irq time_latency 13585 ns
             cc1-87882 [005] dNLh1.. 548.771082: irq_noise: local_timer:236 bắt đầu 548.771077442 thời lượng 7597 ns
             cc1-87882 [005] dNLh2.. 548.771099: irq_noise: qxl:21 bắt đầu 548.771085017 thời lượng 7139 ns
             cc1-87882 [005] d...3.. 548.771102: thread_noise: cc1:87882 bắt đầu 548.771078243 thời lượng 9909 ns
      timelat/5-1035 [005] ....... 548.771104: Chủ đề ngữ cảnh #402268 time_latency 39960 ns

Trong trường hợp này, nguyên nhân cốt lõi của độ trễ của bộ định thời không chỉ ra
một nguyên nhân mà do nhiều nguyên nhân. Thứ nhất, đồng hồ bấm giờ IRQ bị trễ
cho 13 us, có thể trỏ đến phần IRQ dài bị vô hiệu hóa (xem IRQ
phần stacktrace). Sau đó, bộ đếm thời gian ngắt để đánh thức bộ đếm thời gian
luồng mất 7597 ns và thiết bị qxl:21 IRQ mất 7139 ns. Cuối cùng,
tiếng ồn của luồng cc1 mất 9909 ns thời gian trước khi chuyển ngữ cảnh.
Những bằng chứng như vậy rất hữu ích cho nhà phát triển để sử dụng các bằng chứng khác
phương pháp truy tìm để tìm ra cách gỡ lỗi và tối ưu hóa hệ thống.

Điều đáng nói là các giá trị ZZ0000ZZ được báo cáo
bởi osnoise: sự kiện là giá trị ZZ0001ZZ. Ví dụ,
thread_noise không bao gồm thời lượng chi phí gây ra
bằng cách thực thi IRQ (thực sự chiếm tới 12736 ns). Nhưng
các giá trị được báo cáo bởi bộ theo dõi timelat (timerlat_latency)
là các giá trị ZZ0002ZZ.

Hình ảnh bên dưới minh họa dòng thời gian CPU và cách thức hoạt động của bộ theo dõi thời gian
quan sát nó ở trên cùng và osnoise: events ở phía dưới. Mỗi "-"
trong dòng thời gian có nghĩa là vào khoảng 1 chúng ta, và thời gian chuyển động ==>::

Chủ đề irq hẹn giờ bên ngoài
       độ trễ đồng hồ
       sự kiện 13585 ns 39960 ns
         |             ^ ^
         v ZZ0000ZZ
         ZZ0001ZZ |
         ZZ0002ZZ
                       ^ ^
  ==============================================================================
                    [tmr irq] [dev irq]
  [một chủ đề khác...^ v..^ v.......][timerlat/ chủ đề] <-- CPU dòng thời gian
  ===============================================================================
                    ZZ0003ZZ ZZ0004ZZ
                            ZZ0005ZZ
                            ZZ0006ZZ |
                            ZZ0007ZZ + thread_noise: 9909 ns
                            |          +-> irq_noise: 6139 ns
                            +-> irq_noise: 7597 ns

Dấu vết ngăn xếp IRQ
---------------------------

Tùy chọn osnoise/print_stack hữu ích trong trường hợp một luồng
tiếng ồn gây ra yếu tố chính gây ra độ trễ của bộ định thời, do bị chiếm trước hoặc
iq bị vô hiệu hóa. Ví dụ::

[root@f32 tracing]# echo 500 > osnoise/stop_tracing_total_us
        [truy tìm root@f32]# echo 500 > osnoise/print_stack
        [truy tìm root@f32]Bộ đếm thời gian # echo > current_tracer
        [truy tìm root@f32]# tail -21 per_cpu/cpu7/trace
          insmod-1026 [007] dN.h1.. 200.201948: irq_noise: local_timer:236 bắt đầu 200.201939376 thời lượng 7872 ns
          insmod-1026 [007] d..h1.. 200.202587: #29800 bối cảnh irq time_latency 1616 ns
          insmod-1026 [007] dN.h2.. 200.202598: irq_noise: local_timer:236 bắt đầu 200.202586162 thời lượng 11855 ns
          insmod-1026 [007] dN.h3.. 200.202947: irq_noise: local_timer:236 bắt đầu 200.202939174 thời lượng 7318 ns
          insmod-1026 [007] d...3.. 200.203444: thread_noise: insmod:1026 bắt đầu 200.202586933 thời lượng 838681 ns
      timelat/7-1001 [007] ....... 200.203445: Chủ đề ngữ cảnh #29800 time_latency 859978 ns
      timelat/7-1001 [007] ....1.. 200.203446: <dấu vết ngăn xếp>
  => bộ đếm thời gian_irq
  => __hrtimer_run_queues
  => hrtimer_interrupt
  => __sysvec_apic_timer_interrupt
  => asm_call_irq_on_stack
  => sysvec_apic_timer_interrupt
  => asm_sysvec_apic_timer_interrupt
  => độ trễ_tsc
  => dummy_load_1ms_pd_init
  => do_one_initcall
  => do_init_module
  => __do_sys_finit_module
  => do_syscall_64
  => entry_SYSCALL_64_after_hwframe

Trong trường hợp này, có thể thấy rằng luồng được thêm vào cao nhất
đóng góp cho ZZ0000ZZ và dấu vết ngăn xếp, được lưu trong quá trình
trình xử lý IRQ của bộ đếm thời gian, trỏ đến một hàm có tên
dummy_load_1ms_pd_init, có mã sau (có mục đích)::

int tĩnh __init dummy_load_1ms_pd_init(void)
	{
		preempt_disable();
		mdelay(1);
		preempt_enable();
		trả về 0;

	}

Giao diện không gian người dùng
---------------------------

Timelat cho phép các luồng trong không gian người dùng sử dụng cấu trúc cơ sở hạ tầng của timelat để
đo độ trễ lập kế hoạch. Giao diện này có thể truy cập được thông qua mỗi CPU
bộ mô tả tệp bên trong $tracing_dir/osnoise/per_cpu/cpu$ID/timerlat_fd.

Giao diện này có thể truy cập được trong các điều kiện sau:

- bộ theo dõi timelat được bật
 - tùy chọn khối lượng công việc osnoise được đặt thành NO_OSNOISE_WORKLOAD
 - Luồng không gian người dùng được gắn vào một bộ xử lý duy nhất
 - Chuỗi mở tệp được liên kết với bộ xử lý đơn của nó
 - Mỗi lần chỉ có một luồng có thể truy cập tệp

Tòa nhà open() sẽ thất bại nếu bất kỳ điều kiện nào trong số này không được đáp ứng.
Sau khi mở bộ mô tả tệp, không gian người dùng có thể đọc từ nó.

Cuộc gọi hệ thống read() sẽ chạy mã hẹn giờ sẽ kích hoạt
hẹn giờ trong tương lai và đợi nó như luồng nhân thông thường.

Khi bộ đếm thời gian IRQ kích hoạt, bộ đếm thời gian IRQ sẽ thực thi, báo cáo
Độ trễ IRQ và đánh thức luồng đang chờ đọc. Chủ đề sẽ được
đã lên lịch và báo cáo độ trễ của luồng thông qua công cụ theo dõi - như đối với kernel
chủ đề.

Sự khác biệt so với bộ đếm thời gian trong kernel là ở chỗ, thay vì kích hoạt lại
bộ đếm thời gian, bộ đếm thời gian sẽ quay trở lại lệnh gọi hệ thống read(). Tại thời điểm này,
người dùng có thể chạy bất kỳ mã nào.

Nếu ứng dụng đọc lại bộ mô tả tệp tin timelat, trình theo dõi
sẽ báo cáo lợi nhuận từ độ trễ trong không gian người dùng, là tổng
độ trễ. Nếu đây là phần kết thúc của tác phẩm thì nó có thể được hiểu là
thời gian đáp ứng cho yêu cầu.

Sau khi báo cáo tổng độ trễ, bộ đếm thời gian sẽ khởi động lại chu kỳ, cánh tay
đồng hồ hẹn giờ và chuyển sang chế độ ngủ cho lần kích hoạt tiếp theo.

Nếu bất cứ lúc nào một trong các điều kiện bị phá vỡ, ví dụ: luồng di chuyển
khi ở trong không gian người dùng hoặc bộ theo dõi hẹn giờ bị tắt, SIG_KILL
tín hiệu sẽ được gửi đến luồng không gian người dùng.

Đây là một ví dụ cơ bản về mã không gian người dùng cho bộ đếm thời gian ::

int chính(void)
 {
	bộ đệm char [1024];
	int timelat_fd;
	int trả về;
	CPU dài = 0;   /* đặt trong CPU 0 */
	bộ cpu_set_t;

CPU_ZERO(&bộ);
	CPU_SET(cpu,&bộ);

if (sched_setaffinity(gettid(), sizeof(set), &set) == -1)
		trả về 1;

snprintf(bộ đệm, sizeof(bộ đệm),
		"/sys/kernel/tracing/osnoise/per_cpu/cpu%ld/timerlat_fd",
		CPU);

timelat_fd = open(bộ đệm, O_RDONLY);
	nếu (timerlat_fd < 0) {
		printf("lỗi mở %s: %s\n", buffer, strerror(errno));
		thoát (1);
	}

cho (;;) {
		retval = read(timerlat_fd, buffer, 1024);
		nếu (lấy lại < 0)
			phá vỡ;
	}

đóng(timerlat_fd);
	thoát (0);
 }
