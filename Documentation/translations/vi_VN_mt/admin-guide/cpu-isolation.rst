.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cpu-isolation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Cách ly CPU
=============

Giới thiệu
============

"Cách ly CPU" có nghĩa là để CPU độc quyền cho một khối lượng công việc nhất định
không có bất kỳ sự can thiệp mã không mong muốn nào từ kernel.

Những sự can thiệp đó, thường được gọi là "tiếng ồn", có thể được kích hoạt
bởi các sự kiện không đồng bộ (ngắt, bộ định thời, quyền ưu tiên của bộ lập lịch bằng cách
hàng công việc và kthread, ...) hoặc các sự kiện đồng bộ (các cuộc gọi hệ thống và trang
lỗi).

Tiếng ồn như vậy thường không được chú ý. Xét cho cùng, các sự kiện đồng bộ là một
thành phần của dịch vụ hạt nhân được yêu cầu. Và các sự kiện không đồng bộ là
được bộ lập lịch phân phối đủ tốt khi được thực thi
như các nhiệm vụ hoặc nhanh chóng hợp lý khi được thực thi dưới dạng ngắt. Đồng hồ bấm giờ
ngắt thậm chí có thể thực hiện 1024 lần mỗi giây mà không có sự thay đổi đáng kể
và tác động có thể đo lường được hầu hết thời gian.

Tuy nhiên, một số khối lượng công việc hiếm và cực lớn có thể khá nhạy cảm với
những loại tiếng ồn đó. Đây là trường hợp, ví dụ, với mức cao
xử lý mạng băng thông không thể để mất một gói nào
hoặc xử lý mạng có độ trễ rất thấp. Thông thường những trường hợp sử dụng đó
liên quan đến DPDK, bỏ qua ngăn xếp mạng hạt nhân và thực hiện
truy cập trực tiếp vào thiết bị mạng từ không gian người dùng.

Để chạy CPU mà không có hoặc có nhiễu hạt nhân hạn chế,
công việc dọn phòng liên quan cần phải ngừng hoạt động, di chuyển hoặc
đã giảm tải.

dọn phòng
============

Trong thuật ngữ cách ly CPU, công việc dọn phòng thường là
không đồng bộ, hạt nhân cần xử lý để duy trì
tất cả các dịch vụ của nó. Nó phù hợp với những tiếng ồn và sự xáo trộn được liệt kê
ở trên ngoại trừ khi có ít nhất một CPU bị cô lập. Sau đó công việc dọn phòng có thể
tận dụng các cơ chế đối phó tiếp theo nếu công việc gắn liền với CPU phải được thực hiện
đã giảm tải.

CPU vệ sinh là CPU không bị cô lập, nơi có tiếng ồn hạt nhân
được di chuyển khỏi các CPU bị cô lập.

Việc cách ly có thể được thực hiện theo nhiều cách tùy thuộc vào
bản chất của tiếng ồn:

- Công việc không bị ràng buộc, trong đó "không bị ràng buộc" có nghĩa là không bị ràng buộc với bất kỳ CPU nào, có thể
  chỉ đơn giản là di chuyển từ các CPU bị cô lập sang các CPU quản lý.
  Đây là trường hợp của hàng đợi công việc, kthread và bộ hẹn giờ không bị ràng buộc.

- Công việc bị ràng buộc, trong đó "ràng buộc" có nghĩa là được gắn với một CPU cụ thể, thường là
  không thể di chuyển đi như vốn có. Hoặc:

- Công việc phải chuyển sang thực hiện bị khóa. Ví dụ:
	  Đây là trường hợp của RCU với CONFIG_RCU_NOCB_CPU.

- Tính năng liên quan phải được tắt và xem xét
	  không tương thích với các CPU bị cô lập. Ví dụ: Cơ quan giám sát khóa,
	  nguồn đồng hồ không đáng tin cậy, v.v ...

- Một cơ chế đối phó phức tạp và nặng nề được coi là một
	  thay thế. Ví dụ: đồng hồ hẹn giờ đã tắt trên nohz_full
	  CPU nhưng bị hạn chế trong việc chạy một tác vụ duy nhất trên
	  họ. Một hình phạt chi phí đáng kể được thêm vào khi vào/ra kernel
	  và một dấu tích còn lại của bộ lập lịch 1Hz sẽ được chuyển cho công việc dọn phòng
	  CPU.

Trong mọi trường hợp, công việc dọn phòng đều phải được xử lý, đó là lý do tại sao
phải có ít nhất một CPU dọn phòng trong hệ thống, tốt nhất là nhiều hơn
nếu máy chạy nhiều CPU. Ví dụ: một nút trên mỗi nút trên NUMA
hệ thống.

Ngoài ra, cách ly CPU thường có nghĩa là sự cân bằng giữa cách ly không tiếng ồn
CPU và chi phí bổ sung cho CPU quản lý, đôi khi thậm chí trên
CPU bị cô lập đi vào kernel.

Tính năng cách ly
==================

Các mức độ cô lập khác nhau có thể được cấu hình trong kernel, mỗi mức độ
có những hạn chế và sự đánh đổi riêng.

Cách ly miền lập lịch
--------------------------

Tính năng này tách biệt CPU khỏi cấu trúc liên kết của bộ lập lịch. Kết quả là,
mục tiêu không phải là một phần của cân bằng tải. Nhiệm vụ sẽ không di chuyển
từ hoặc tới nó trừ khi được liên kết một cách rõ ràng.

Là một tác dụng phụ, CPU cũng bị cô lập khỏi hàng đợi công việc không liên kết và
kthread không bị ràng buộc.

Yêu cầu
~~~~~~~~~~~~

- CONFIG_CPUSETS=y cho giao diện dựa trên cpuset

sự đánh đổi
~~~~~~~~~

Về bản chất, tải hệ thống nhìn chung ít được phân bổ hơn do một số CPU
được trích xuất từ cân bằng tải toàn cầu.

Giao diện
~~~~~~~~~~

- Nên sử dụng tài liệu/admin-guide/cgroup-v2.rst phân vùng cách ly cpuset
  bởi vì chúng có thể điều chỉnh được trong thời gian chạy.

- Tham số khởi động kernel 'isolcpus=' với cờ 'domain' là một
  giải pháp thay thế kém linh hoạt hơn không cho phép chạy
  cấu hình lại.

Cách ly IRQ
--------------

Cô lập các IRQ bất cứ khi nào có thể để chúng không bắn vào
CPU mục tiêu.

Giao diện
~~~~~~~~~~

- Tệp /proc/irq/\*/smp_affinity như được giải thích chi tiết trong
  Trang tài liệu/core-api/irq/irq-affinity.rst.

- Tham số khởi động kernel "irqaffinity=" cho cài đặt mặc định.

- Cờ "managed_irq" trong tham số khởi động kernel "isolcpus="
  thử ghi đè mối quan hệ nỗ lực tối đa cho các IRQ được quản lý.

Dynticks đầy đủ (còn gọi là nohz_full)
-----------------------------

dynticks đầy đủ mở rộng chế độ không tải của dynticks, chế độ này sẽ dừng tích tắc khi
CPU không hoạt động, đối với các CPU đang chạy một tác vụ duy nhất trong không gian người dùng. Đó là,
đánh dấu bộ đếm thời gian sẽ dừng lại nếu môi trường cho phép.

Lệnh gọi lại hẹn giờ toàn cầu cũng được tách biệt khỏi CPU nohz_full.

Yêu cầu
~~~~~~~~~~~~

- CONFIG_NO_HZ_FULL=y

Hạn chế
~~~~~~~~~~~

- Các CPU bị cô lập chỉ được chạy một tác vụ duy nhất. Đa nhiệm yêu cầu
  đánh dấu để duy trì quyền ưu tiên. Điều này thường ổn vì
  khối lượng công việc thường không thể chịu được độ trễ của việc chuyển ngữ cảnh ngẫu nhiên.

- Không có lệnh gọi tới kernel từ các CPU bị cô lập, có nguy cơ kích hoạt
  tiếng ồn ngẫu nhiên.

- Không sử dụng bộ hẹn giờ POSIX CPU trên các CPU bị cô lập.

- Kiến trúc phải có nguồn xung nhịp ổn định và đáng tin cậy (không
  TSC không đáng tin cậy cần có cơ quan giám sát).


sự đánh đổi
~~~~~~~~~

Về mặt chi phí, đây là tính năng cách ly xâm lấn nhất. Đó là
được cho là được sử dụng khi khối lượng công việc dành phần lớn thời gian của nó trong
không gian người dùng và không dựa vào kernel ngoại trừ phần chuẩn bị
làm việc vì:

- RCU bổ sung thêm chi phí do khóa, giảm tải và phân luồng
  xử lý cuộc gọi lại (điều tương tự sẽ thu được với "rcu_nocbs"
  tham số khởi động).

- Nhập/ra hạt nhân thông qua các tòa nhà cao tầng, các ngoại lệ và IRQ còn nhiều hơn thế
  tốn kém do các hoạt động RmW được đặt hàng đầy đủ để duy trì không gian người dùng
  khi RCU mở rộng trạng thái không hoạt động. Ngoài ra, thời gian CPU cũng được tính vào
  ranh giới hạt nhân thay vì định kỳ từ tích tắc.

- CPU Housekeeping phải chạy tích tắc lập lịch từ xa còn lại 1Hz
  thay mặt cho các CPU bị cô lập.

Danh sách kiểm tra
=========

Bạn đã thiết lập từng tính năng cách ly trên nhưng vẫn
quan sát những cảm giác bồn chồn làm hỏng khối lượng công việc của bạn? Hãy chắc chắn kiểm tra một số
các phần tử trước khi tiến hành.

Một số mục trong danh sách kiểm tra này tương tự như các mục trong danh sách kiểm tra thời gian thực.
khối lượng công việc:

- Sử dụng mlock() để ngăn các trang của bạn bị tráo đổi. Trang
  các lỗi thường không tương thích với khối lượng công việc nhạy cảm với jitter.

- Tránh SMT để tránh tình trạng thread phần cứng của bạn bị "chiếm trước"
  bởi một cái khác.

- Sự thay đổi tần số CPU có thể gây ra các loại jitter tinh tế trong
  khối lượng công việc. Cpufreq nên được sử dụng và điều chỉnh một cách thận trọng.

- Trạng thái C sâu có thể dẫn đến các vấn đề về độ trễ khi thức dậy. Nếu điều này
  tình cờ xảy ra sự cố, trạng thái C có thể bị giới hạn thông qua khởi động kernel
  các tham số như bộ xử lý.max_cstate hoặc intel_idle.max_cstate.
  Các điều chỉnh chi tiết hơn được mô tả trong
  Trang tài liệu/admin-guide/pm/cpuidle.rst

- Hệ thống của bạn có thể bị gián đoạn do phần mềm cơ sở - x86 có
  Ví dụ: Ngắt quản lý hệ thống (SMI). Kiểm tra hệ thống của bạn BIOS
  để vô hiệu hóa sự can thiệp đó và nếu may mắn thì nhà cung cấp của bạn sẽ có
  hướng dẫn điều chỉnh BIOS cho các hoạt động có độ trễ thấp.


Ví dụ cách ly hoàn toàn
======================

Trong ví dụ này, hệ thống có 8 CPU và CPU thứ 8 được trang bị đầy đủ
bị cô lập. Vì CPU bắt đầu từ 0 nên CPU thứ 8 là CPU 7.

Thông số hạt nhân
-----------------

Đặt các tham số khởi động kernel sau để tắt SMT và đánh dấu thiết lập
và cách ly IRQ:

- Dyntick đầy đủ: nohz_full=7

- Cách ly IRQ: irqaffinity=0-6

- Cách ly IRQ được quản lý: isolcpus=managed_irq,7

- Ngăn chặn SMT: nosmt

Dòng lệnh đầy đủ là:

nohz_full=7 irqaffinity=0-6 isolcpus=managed_irq,7 nosmt

Cấu hình CPUSET (cgroup v2)
--------------------------------

Giả sử cgroup v2 được gắn vào/sys/fs/cgroup, đoạn script sau
cách ly CPU 7 khỏi các miền lập lịch.

::

cd /sys/fs/cgroup
  # Activate hệ thống con cpuset
  echo +cpuset > cgroup.subtree_control
  Phân vùng # Create được cách ly
  kiểm tra mkdir
  kiểm tra đĩa CD
  echo +cpuset > cgroup.subtree_control
  # Isolate CPU 7
  echo 7 > cpuset.cpus
  echo "bị cô lập" > cpuset.cpus.partition

Khối lượng công việc của không gian người dùng
----------------------

Giả mạo khối lượng công việc thuần túy của không gian người dùng, chương trình bên dưới chạy một hình nộm
vòng lặp không gian người dùng trên CPU bị cô lập 7.

::

#include <stdio.h>
  #include <fcntl.h>
  #include <unistd.h>
  #include <errno.h>
  int chính(void)
  {
      // Di chuyển tác vụ hiện tại sang cpuset bị cô lập (liên kết với CPU 7)
      int fd = open("/sys/fs/cgroup/test/cgroup.procs", O_WRONLY);
      nếu (fd < 0) {
          perror("Không thể mở tập tin cpuset...\n");
          trả về 0;
      }

write(fd, "0\n", 2);
      đóng(fd);

// Chạy một vòng lặp giả vô tận cho đến khi trình khởi chạy giết chết chúng ta
      trong khi (1)
      ;

trả về 0;
  }

Xây dựng nó và lưu cho bước sau:

::

# gcc user_loop.c -o user_loop

Trình khởi chạy
------------

Trình khởi chạy bên dưới chạy chương trình trên trong 10 giây và theo dõi
tiếng ồn phát sinh từ các nhiệm vụ ưu tiên và IRQ.

::

TRACING=/sys/kernel/tracing/
  # Make chắc chắn tính năng theo dõi hiện đã tắt
  echo 0 > $TRACING/tracing_on
  # Flush dấu vết trước đó
  echo > $TRACING/dấu vết
  # Record nhiễu loạn từ các nhiệm vụ khác
  echo 1 > $TRACING/events/sched/sched_switch/enable
  # Record nhiễu loạn do ngắt
  echo 1 > $TRACING/sự kiện/irq_vectors/bật
  # Now chúng ta có thể bắt đầu truy tìm
  echo 1 > $TRACING/tracing_on
  # Run user_loop giả trong 10 giây trên CPU 7
  ./user_loop &
  USER_LOOP_PID=$!
  ngủ 10
  giết $USER_LOOP_PID
  # Disable truy tìm và lưu dấu vết từ CPU 7 vào một tệp
  echo 0 > $TRACING/tracing_on
  mèo $TRACING/per_cpu/cpu7/trace > trace.7

Nếu không có vấn đề cụ thể nào phát sinh, đầu ra của trace.7 sẽ giống như
sau đây:

::

<nhàn rỗi>-0 [007] d..2. 1980.976624: sched_switch: prev_comm=swapper/7 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=user_loop next_pid=1553 next_prio=120
  user_loop-1553 [007] d.h.. 1990.946593: reschedule_entry: vector=253
  user_loop-1553 [007] d.h.. 1990.946593: reschedule_exit: vector=253

Nghĩa là, không có tiếng ồn cụ thể nào được kích hoạt giữa dấu vết đầu tiên và dấu vết đầu tiên.
giây trong 10 giây khi user_loop đang chạy.

Gỡ lỗi
=========

Tất nhiên mọi việc không bao giờ dễ dàng như vậy, đặc biệt là về vấn đề này.
Rất có thể tiếng ồn thực tế sẽ được quan sát thấy trong trường hợp nói trên
tập tin trace.7.

Cách tốt nhất để điều tra sâu hơn là kích hoạt tính năng chi tiết hơn
các điểm theo dõi chẳng hạn như các điểm của các hệ thống con tạo ra không đồng bộ
sự kiện: hàng làm việc, bộ đếm thời gian, irq_vector, v.v... Nó cũng có thể
thật thú vị khi kích hoạt sự kiện tick_stop để chẩn đoán lý do tại sao có dấu tích
được giữ lại khi điều đó xảy ra.

Một số công cụ cũng có thể hữu ích cho việc phân tích ở cấp độ cao hơn:

- Documentation/tools/rtla/rtla.rst cung cấp bộ công cụ để phân tích
  độ trễ và tiếng ồn trong hệ thống. Ví dụ: Documentation/tools/rtla/rtla-osnoise.rst
  chạy trình theo dõi hạt nhân để phân tích và đưa ra bản tóm tắt về tiếng ồn.

- dynticks-testing thực hiện điều tương tự như rtla-osnoise nhưng trong không gian người dùng. Nó có sẵn
  tại git://git.kernel.org/pub/scm/linux/kernel/git/frederic/dynticks-testing.git