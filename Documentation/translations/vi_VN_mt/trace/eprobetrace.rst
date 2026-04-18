.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/eprobetrace.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Eprobe - Truy tìm thăm dò dựa trên sự kiện
==================================

:Tác giả: Steven Rostedt <rostedt@goodmis.org>

- Viết cho v6.17

Tổng quan
========

Eprobes là các sự kiện động được đặt trên các sự kiện hiện có để
hủy đăng ký một trường là một con trỏ hoặc đơn giản là giới hạn những trường nào
được ghi lại trong sự kiện theo dõi.

Eprobes phụ thuộc vào các sự kiện kprobe vì vậy để kích hoạt tính năng này, hãy xây dựng kernel của bạn
với CONFIG_EPROBE_EVENTS=y.

Eprobe được tạo thông qua tệp /sys/kernel/tracing/dynamic_events.

Tóm tắt của eprobe_events
-------------------------
::

e[:[EGRP/][EEVENT]] GRP.EVENT [FETCHARGS] : Đặt đầu dò
  -:[EGRP/][EEVENT] : Xóa đầu dò

EGRP : Tên nhóm của sự kiện mới. Nếu bỏ qua, hãy sử dụng "eprobes" cho nó.
 EEVENT : Tên sự kiện. Nếu bị bỏ qua, tên sự kiện sẽ được tạo và sẽ
		  có cùng tên sự kiện với sự kiện mà nó đính kèm.
 GRP : Tên nhóm của sự kiện cần đính kèm.
 EVENT : Tên sự kiện của sự kiện cần đính kèm.

FETCHARGS : Đối số. Mỗi đầu dò có thể có tới 128 đối số.
  $FIELD : Tìm nạp giá trị của trường sự kiện có tên FIELD.
  @ADDR : Tìm nạp bộ nhớ tại ADDR (ADDR phải có trong kernel)
  @SYM[+ZZ0001ZZ- tắt (SYM phải là ký hiệu dữ liệu)
  $comm : Tìm nạp nhiệm vụ hiện tại comm.
  +ZZ0002ZZ- Địa chỉ OFFS.(\ZZ0000ZZ4)
  \IMM : Lưu trữ giá trị ngay lập tức cho đối số.
  NAME=FETCHARG : Đặt NAME làm tên đối số của FETCHARG.
  FETCHARG:TYPE : Đặt TYPE làm loại FETCHARG. Hiện nay, các loại cơ bản
		  (u8/u16/u32/u64/s8/s16/s32/s64), loại thập lục phân
		  (x8/x16/x32/x64), loại phổ biến của lớp VFS(%pd/%pD), "char",
                  "chuỗi", "ustring", "biểu tượng", "symstr" và "bitfield" là
                  được hỗ trợ.

Các loại
-----
FETCHARGS ở trên rất giống với các sự kiện kprobe như được mô tả trong
Tài liệu/trace/kprobetrace.rst.

Sự khác biệt giữa eprobes và kprobes FETCHARGS là eprobes có một
Lệnh $FIELD trả về nội dung của trường sự kiện của sự kiện
được đính kèm. Eprobes không có quyền truy cập vào các thanh ghi, ngăn xếp và chức năng
đối số mà kprobes có.

Nếu đối số trường là một con trỏ, nó có thể bị hủy đăng ký giống như bộ nhớ
địa chỉ bằng cú pháp FETCHARGS.


Gắn vào các sự kiện động
---------------------------

Eprobes có thể gắn vào các sự kiện động cũng như các sự kiện thông thường. Nó có thể
đính kèm vào sự kiện kprobe, sự kiện tổng hợp hoặc sự kiện fprobe. Điều này rất hữu ích
nếu loại trường cần được thay đổi. Xem ví dụ 2 bên dưới.

Ví dụ sử dụng
==============

Ví dụ 1
---------

Cách sử dụng cơ bản của eprobes là giới hạn dữ liệu được ghi vào
bộ đệm theo dõi. Ví dụ: một sự kiện phổ biến cần theo dõi là sched_switch
sự kiện dấu vết. Có định dạng::

trường:unsigned short common_type;	bù đắp: 0;	kích thước:2;	đã ký: 0;
	trường: char không dấu common_flags;	bù đắp:2;	kích thước: 1;	đã ký: 0;
	trường: char không dấu common_preempt_count;	bù đắp:3;	kích thước: 1;	đã ký: 0;
	trường:int common_pid;	bù đắp:4;	kích thước:4;	đã ký: 1;

trường:char prev_comm[16];	bù đắp: 8;	kích thước:16;	đã ký: 0;
	trường:pid_t prev_pid;	bù đắp:24;	kích thước:4;	đã ký: 1;
	trường:int prev_prio;	bù đắp:28;	kích thước:4;	đã ký: 1;
	trường:prev_state dài;	bù đắp:32;	kích thước:8;	đã ký: 1;
	trường:char next_comm[16];	bù đắp:40;	kích thước:16;	đã ký: 0;
	trường:pid_t next_pid;	bù đắp:56;	kích thước:4;	đã ký: 1;
	trường:int next_prio;	bù đắp:60;	kích thước:4;	đã ký: 1;

Bốn trường đầu tiên là chung cho tất cả các sự kiện và không thể bị giới hạn. Nhưng
phần còn lại của sự kiện có 60 byte thông tin. Nó ghi lại tên của
các nhiệm vụ trước và tiếp theo được lên kế hoạch vào và ra, cũng như các pid và
những ưu tiên. Nó cũng ghi lại trạng thái của nhiệm vụ trước đó. Nếu chỉ có pids
trong số các nhiệm vụ được quan tâm, tại sao lại lãng phí bộ đệm vòng với tất cả các nhiệm vụ khác
lĩnh vực?

Một eprobe có thể giới hạn những gì được ghi lại. Lưu ý, nó không giúp ích gì về hiệu suất,
vì tất cả các trường được ghi vào bộ đệm tạm thời để xử lý eprobe.
::

# echo 'e:sched/switch sched.sched_switch prev=$prev_pid:u32 next=$next_pid:u32' >> /sys/kernel/tracing/dynamic_events
 # echo 1 > /sys/kernel/tracing/events/sched/switch/bật
 # cat /sys/kernel/truy tìm/dấu vết

# tracer: không
 #
 # entries-in-buffer/mục viết: 2721/2721 #P:8
 #
 #                                _-----=> irqs-off/BH-vô hiệu hóa
 # / _---=> cần được chỉnh sửa lại
 # | / _---=> hardirq/softirq
 # || / _--=> ưu tiên độ sâu
 # ||| / _-=> di chuyển-vô hiệu hóa
 # |||| / trì hoãn
 #           ZZ0003ZZ-ZZ0004ZZ CPU# |||||  TIMESTAMP FUNCTION
 #              ZZ0008ZZ ZZ0001ZZ|||ZZ0002ZZ |
     sshd-session-1082 [004] d..4.  5041.239906: switch: (sched.sched_switch) prev=1082 next=0
             bash-1085 [001] d..4.  5041.240198: switch: (sched.sched_switch) prev=1085 next=141
    kworker/u34:5-141 [001] d..4.  5041.240259: switch: (sched.sched_switch) prev=141 next=1085
           <nhàn rỗi>-0 [004] d..4.  5041.240354: switch: (sched.sched_switch) prev=0 next=1082
             bash-1085 [001] d..4.  5041.240385: switch: (sched.sched_switch) prev=1085 next=141
    kworker/u34:5-141 [001] d..4.  5041.240410: switch: (sched.sched_switch) prev=141 next=1085
             bash-1085 [001] d..4.  5041.240478: switch: (sched.sched_switch) prev=1085 next=0
     sshd-session-1082 [004] d..4.  5041.240526: switch: (sched.sched_switch) prev=1082 next=0
           <nhàn rỗi>-0 [001] d..4.  5041.247524: switch: (sched.sched_switch) prev=0 next=90
           <nhàn rỗi>-0 [002] d..4.  5041.247545: switch: (sched.sched_switch) prev=0 next=16
      kworker/1:1-90 [001] d..4.  5041.247580: switch: (sched.sched_switch) prev=90 next=0
        rcu_sched-16 [002] d..4.  5041.247591: switch: (sched.sched_switch) prev=16 next=0
           <nhàn rỗi>-0 [002] d..4.  5041.257536: switch: (sched.sched_switch) prev=0 next=16
        rcu_sched-16 [002] d..4.  5041.257573: switch: (sched.sched_switch) prev=16 next=0

Lưu ý, không thêm "u32" sau prev_pid và next_pid, các giá trị
sẽ mặc định hiển thị ở dạng thập lục phân.

Ví dụ 2
---------

Nếu một cuộc gọi hệ thống cụ thể được ghi lại nhưng các sự kiện của cuộc gọi hệ thống thì không
được bật, raw_syscalls vẫn có thể được sử dụng (syscalls là cuộc gọi hệ thống
sự kiện không phải là sự kiện bình thường mà được tạo từ sự kiện raw_syscalls
trong hạt nhân). Để theo dõi cuộc gọi hệ thống openat, người ta có thể tạo
một thăm dò sự kiện bên cạnh sự kiện raw_syscalls:
::

# cd /sys/kernel/truy tìm
 Sự kiện # cat/raw_syscalls/sys_enter/format
 tên: sys_enter
 Mã số: 395
 định dạng:
	trường:unsigned short common_type;	bù đắp: 0;	kích thước:2;	đã ký: 0;
	trường: char không dấu common_flags;	bù đắp:2;	kích thước: 1;	đã ký: 0;
	trường: char không dấu common_preempt_count;	bù đắp:3;	kích thước: 1;	đã ký: 0;
	trường:int common_pid;	bù đắp:4;	kích thước:4;	đã ký: 1;

trường:id dài;	bù đắp: 8;	kích thước:8;	đã ký: 1;
	trường: đối số dài không dấu [6];	bù đắp:16;	kích thước:48;	đã ký: 0;

in fmt: "NR %ld (%lx, %lx, %lx, %lx, %lx, %lx)", REC->id, REC->args[0], REC->args[1], REC->args[2], REC->args[3], REC->args[4], REC->args[5]

Từ mã nguồn, sys_openat() có:
::

int sys_openat(int dirfd, const char *path, int flags, chế độ mode_t)
 {
	return my_syscall4(__NR_openat, dirfd, path, flags, mode);
 }

Đường dẫn là tham số thứ hai và đó là điều mong muốn.
::

# echo 'e:openat raw_syscalls.sys_enter nr=$id filename=+8($args):ustring' >> Dynamic_events

Điều này đang được chạy trên x86_64 trong đó kích thước từ là 8 byte và openat
cuộc gọi hệ thống __NR_openat được đặt ở 257.
::

# echo 'nr == 257' > sự kiện/eprobes/openat/bộ lọc

Bây giờ hãy kích hoạt sự kiện và xem dấu vết.
::

# echo 1 > sự kiện/eprobes/openat/kích hoạt
 Dấu vết # cat

# tracer: không
 #
 # entries-in-buffer/mục viết: 4/4 #P:8
 #
 #                                _-----=> irqs-off/BH-vô hiệu hóa
 # / _---=> cần được chỉnh sửa lại
 # | / _---=> hardirq/softirq
 # || / _--=> ưu tiên độ sâu
 # ||| / _-=> di chuyển-vô hiệu hóa
 # |||| / trì hoãn
 #           ZZ0003ZZ-ZZ0004ZZ CPU# |||||  TIMESTAMP FUNCTION
 #              ZZ0008ZZ ZZ0001ZZ|||ZZ0002ZZ |
              cat-1298 [003] ...2.  2060.875970: openat: (raw_syscalls.sys_enter) nr=0x101 filename=(fault)
              cat-1298 [003] ...2.  2060.876197: openat: (raw_syscalls.sys_enter) nr=0x101 filename=(fault)
              cat-1298 [003] ...2.  2060.879126: openat: (raw_syscalls.sys_enter) nr=0x101 filename=(fault)
              cat-1298 [003] ...2.  2060.879639: openat: (raw_syscalls.sys_enter) nr=0x101 filename=(fault)

Tên tệp hiển thị "(lỗi)". Điều này có thể là do tên tập tin chưa được
đã được đưa vào bộ nhớ và hiện tại các sự kiện theo dõi không thể bị lỗi trong bộ nhớ
không có mặt. Khi một eprobe cố đọc bộ nhớ không bị lỗi
Tuy nhiên, nó sẽ hiển thị văn bản "(lỗi)".

Để giải quyết vấn đề này, vì kernel có thể sẽ lấy tên tệp này và tạo
nó hiện diện, gắn nó vào một sự kiện tổng hợp có thể truyền địa chỉ của
tên tệp từ khi bắt đầu sự kiện cho đến khi kết thúc sự kiện, tên này có thể được sử dụng
để hiển thị tên tệp khi cuộc gọi hệ thống trả về.

Xóa epro cũ::

# echo 1 > sự kiện/eprobes/openat/kích hoạt
 # echo '-:openat' >> Dynamic_events

Lần này hãy tạo một eprobe nơi lưu địa chỉ của tên tệp ::

# echo 'e:openat_start raw_syscalls.sys_enter nr=$id filename=+8($args):x64' >> Dynamic_events

Tạo một sự kiện tổng hợp chuyển địa chỉ của tên tệp tới
kết thúc sự kiện::

# echo 's:tên tệp u64 file' >> Dynamic_events
 # echo 'hist:keys=common_pid:f=filename if nr == 257' > events/eprobes/openat_start/trigger
 # echo 'hist:keys=common_pid:file=$f:onmatch(eprobes.openat_start).trace(filename,$file) if id == 257' > events/raw_syscalls/sys_exit/trigger

Bây giờ địa chỉ của tên tệp đã được chuyển đến cuối
cuộc gọi hệ thống, hãy tạo một eprobe khác để đính kèm vào sự kiện thoát để hiển thị
chuỗi::

# echo 'e:openat tổng hợp.tên tệp tên tệp=+0($file):ustring' >> Dynamic_events
 # echo 1 > sự kiện/eprobes/openat/kích hoạt
 Dấu vết # cat

# tracer: không
 #
 # entries-in-buffer/mục viết: 4/4 #P:8
 #
 #                                _-----=> irqs-off/BH-vô hiệu hóa
 # / _---=> cần được chỉnh sửa lại
 # | / _---=> hardirq/softirq
 # || / _--=> ưu tiên độ sâu
 # ||| / _-=> di chuyển-vô hiệu hóa
 # |||| / trì hoãn
 #           ZZ0003ZZ-ZZ0004ZZ CPU# |||||  TIMESTAMP FUNCTION
 #              ZZ0008ZZ ZZ0001ZZ|||ZZ0002ZZ |
              cat-1331 [001] ...5.  2944.787977: openat: (synthetic.filename) filename="/etc/ld.so.cache"
              cat-1331 [001] ...5.  2944.788480: openat: (synthetic.filename) filename="/lib/x86_64-linux-gnu/libc.so.6"
              cat-1331 [001] ...5.  2944.793426: openat: (synthetic.filename) filename="/usr/lib/locale/locale-archive"
              cat-1331 [001] ...5.  2944.831362: openat: (synthetic.filename) filename="trace"

Ví dụ 3
---------

Nếu có sẵn các sự kiện theo dõi cuộc gọi tòa nhà thì những sự kiện trên sẽ không cần sự kiện đầu tiên
eprobe, nhưng nó vẫn cần cái cuối cùng::

# echo 's:tên tệp u64 file' >> Dynamic_events
 # echo 'hist:keys=common_pid:f=filename' > sự kiện/syscalls/sys_enter_openat/trigger
 # echo 'hist:keys=common_pid:file=$f:onmatch(syscalls.sys_enter_openat).trace(filename,$file)' > sự kiện/syscalls/sys_exit_openat/trigger
 # echo 'e:openat tổng hợp.tên tệp tên tệp=+0($file):ustring' >> Dynamic_events
 # echo 1 > sự kiện/eprobes/openat/kích hoạt

Và điều này sẽ tạo ra kết quả tương tự như Ví dụ 2.