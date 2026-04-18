.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/fprobetrace.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Theo dõi sự kiện dựa trên Fprobe
================================

.. Author: Masami Hiramatsu <mhiramat@kernel.org>

Tổng quan
--------

Sự kiện Fprobe tương tự như sự kiện kprobe nhưng bị giới hạn ở việc thăm dò trên
chỉ có chức năng vào và ra. Nó đủ tốt cho nhiều trường hợp sử dụng
mà chỉ theo dõi một số chức năng cụ thể.

Tài liệu này cũng bao gồm các sự kiện thăm dò dấu vết (tprobe) vì điều này
cũng chỉ hoạt động trên mục tracepoint. Người dùng có thể theo dõi một phần của
đối số tracepoint hoặc tracepoint không có sự kiện theo dõi, đó là
không được hiển thị trên tracefs.

Giống như các sự kiện động khác, sự kiện fprobe và thăm dò tracepoint
các sự kiện được xác định thông qua tệp giao diện ZZ0000ZZ trên tracefs.

Tóm tắt sự kiện fprobe
-------------------------
::

f[:[GRP1/][EVENT1]] SYM [FETCHARGS] : Thăm dò khi nhập chức năng
  f[MAXACTIVE][:[GRP1/][EVENT1]] SYM%return [FETCHARGS] : Thăm dò khi thoát khỏi chức năng
  t[:[GRP2/][EVENT2]] TRACEPOINT [FETCHARGS] : Thăm dò trên tracepoint

GRP1 : Tên nhóm cho fprobe. Nếu bị bỏ qua, hãy sử dụng "fprobes" cho nó.
 GRP2 : Tên nhóm cho tprobe. Nếu bỏ qua, hãy sử dụng "tracepoints" cho nó.
 EVENT1 : Tên sự kiện cho fprobe. Nếu bỏ qua, tên sự kiện là
                  "SYM__entry" hoặc "SYM__exit".
 EVENT2 : Tên sự kiện của tprobe. Nếu bỏ qua, tên sự kiện là
                  giống như "TRACEPOINT", nhưng nếu "TRACEPOINT" khởi động
                  với ký tự chữ số, "_TRACEPOINT" được sử dụng.
 MAXACTIVE : Số phiên bản tối đa của hàm được chỉ định
                  có thể được thăm dò đồng thời hoặc 0 cho giá trị mặc định
                  như được định nghĩa trong Tài liệu/trace/fprobe.rst

FETCHARGS : Đối số. Mỗi đầu dò có thể có tới 128 đối số.
  ARG : Tìm nạp đối số hàm "ARG" bằng BTF (chỉ dành cho hàm
                  mục nhập hoặc điểm theo dõi.) (\*1)
  @ADDR : Tìm nạp bộ nhớ tại ADDR (ADDR phải có trong kernel)
  @SYM[+ZZ0001ZZ- offs (SYM phải là ký hiệu dữ liệu)
  $stackN : Tìm nạp mục nhập thứ N của ngăn xếp (N >= 0)
  $stack : Lấy địa chỉ ngăn xếp.
  $argN : Tìm nạp đối số hàm thứ N. (N >= 1) (\*2)
  $retval : Tìm nạp giá trị trả về.(\*3)
  $comm : Tìm nạp nhiệm vụ hiện tại comm.
  +ZZ0002ZZ- Địa chỉ OFFS.(\ZZ0000ZZ5)
  \IMM : Lưu trữ giá trị ngay lập tức cho đối số.
  NAME=FETCHARG : Đặt NAME làm tên đối số của FETCHARG.
  FETCHARG:TYPE : Đặt TYPE làm loại FETCHARG. Hiện nay, các loại cơ bản
                  (u8/u16/u32/u64/s8/s16/s32/s64), loại thập lục phân
                  (x8/x16/x32/x64), "char", "chuỗi", "ustring", "ký hiệu", "symstr"
                  và bitfield được hỗ trợ.

(\*1) Tính năng này chỉ khả dụng khi BTF được bật.
  (\*2) chỉ dành cho thăm dò khi nhập hàm (tắt == 0). Lưu ý, quyền truy cập đối số này
        là nỗ lực tốt nhất, vì tùy thuộc vào loại đối số, nó có thể được chuyển tiếp
        ngăn xếp. Nhưng điều này chỉ hỗ trợ các đối số thông qua sổ đăng ký.
  (\*3) chỉ dành cho thăm dò trở lại. Lưu ý rằng đây cũng là nỗ lực tốt nhất. Tùy thuộc vào
        kiểu giá trị trả về, nó có thể được truyền qua một cặp thanh ghi. Nhưng điều này chỉ
        truy cập vào một thanh ghi.
  (\*4) điều này rất hữu ích để tìm nạp một trường cấu trúc dữ liệu.
  (\*5) "u" có nghĩa là vô hiệu hóa không gian người dùng.

Để biết chi tiết về TYPE, hãy xem ZZ0000ZZ.

Đối số chức năng khi thoát
--------------------------
Các đối số của hàm có thể được truy cập tại đầu dò thoát bằng cách sử dụng $arg<N>fetcharg. Cái này
rất hữu ích để ghi lại tham số hàm và giá trị trả về cùng một lúc, và
theo dõi sự khác biệt của các trường cấu trúc (để gỡ lỗi một hàm cho dù nó
có cập nhật chính xác cấu trúc dữ liệu đã cho hay không)
Xem ZZ0000ZZ bên dưới để biết cách hoạt động.

Đối số BTF
-------------
Đối số BTF (Định dạng loại BPF) cho phép người dùng theo dõi chức năng và dấu vết
tham số theo tên của nó thay vì ZZ0000ZZ. Tính năng này khả dụng nếu
kernel được cấu hình với CONFIG_BPF_SYSCALL và CONFIG_DEBUG_INFO_BTF.
Nếu người dùng chỉ chỉ định đối số BTF thì tên đối số của sự kiện cũng là
tự động đặt theo tên đã cho. ::

# echo 'f:myprobe vfs_read đếm pos' >> Dynamic_events
 # cat động_sự kiện
 f:fprobes/myprobe vfs_read count=count pos=pos

Nó cũng chọn kiểu tìm nạp từ thông tin BTF. Ví dụ như ở phần trên
ví dụ: ZZ0000ZZ có chiều dài không dấu và ZZ0001ZZ là một con trỏ. Như vậy,
cả hai đều được chuyển đổi thành 64bit dài không dấu, nhưng chỉ ZZ0002ZZ có "%Lx"
định dạng in như sau ::

Sự kiện # cat/fprobes/myprobe/định dạng
 Tên: myprobe
 Mã số: 1313
 định dạng:
	trường:unsigned short common_type;	bù đắp: 0;	kích thước:2;	đã ký: 0;
	trường: char không dấu common_flags;	bù đắp:2;	kích thước: 1;	đã ký: 0;
	trường: char không dấu common_preempt_count;	bù đắp:3;	kích thước: 1;	đã ký: 0;
	trường:int common_pid;	bù đắp:4;	kích thước:4;	đã ký: 1;

trường:không dấu dài __probe_ip;	bù đắp: 8;	kích thước:8;	đã ký: 0;
	trường: số lượng u64;	bù đắp:16;	kích thước:8;	đã ký: 0;
	trường:u64 pos;	bù đắp:24;	kích thước:8;	đã ký: 0;

in fmt: "(%lx) count=%Lu pos=0x%Lx", REC->__probe_ip, REC->count, REC->pos

Nếu người dùng không chắc chắn về tên của đối số, ZZ0000ZZ sẽ hữu ích. ZZ0001ZZ
được mở rộng cho tất cả các đối số hàm của hàm hoặc điểm theo dõi. ::

# echo 'f:myprobe vfs_read $arg*' >> Dynamic_events
 # cat động_sự kiện
 f:fprobes/myprobe vfs_read file=file buf=buf count=count pos=pos

BTF cũng ảnh hưởng đến ZZ0000ZZ. Nếu người dùng không đặt bất kỳ loại nào, giá trị trả lại
loại được tự động chọn từ BTF. Nếu hàm trả về ZZ0001ZZ,
ZZ0002ZZ bị từ chối.

Bạn có thể truy cập các trường dữ liệu của cấu trúc dữ liệu bằng cách sử dụng toán tử cho phép ZZ0000ZZ
(đối với kiểu con trỏ) và toán tử dấu chấm ZZ0001ZZ (đối với kiểu cấu trúc dữ liệu.)::

# echo 't sched_switch ưu tiên prev_pid=prev->pid next_pid=next->pid' >> Dynamic_events

Các toán tử truy cập trường, ZZ0000ZZ và ZZ0001ZZ có thể được kết hợp để truy cập sâu hơn
thành viên và các thành viên cấu trúc khác do thành viên chỉ định. ví dụ. ZZ0002ZZ
Nếu có thành viên liên minh không có tên, bạn có thể truy cập trực tiếp vào nó như mã C.
Ví dụ::

cấu trúc {
	công đoàn {
	int một;
	int b;
	};
 } *foo;

Để truy cập ZZ0000ZZ và ZZ0001ZZ, hãy sử dụng ZZ0002ZZ và ZZ0003ZZ trong trường hợp này.

Quyền truy cập trường dữ liệu này có sẵn cho giá trị trả về thông qua ZZ0000ZZ,
ví dụ: ZZ0001ZZ.

Đối với các đối số và trường BTF này, ZZ0000ZZ và ZZ0001ZZ thay đổi
hành vi. Nếu chúng được sử dụng cho đối số hoặc trường BTF, nó sẽ kiểm tra xem
loại BTF của đối số hoặc trường dữ liệu là ZZ0002ZZ hoặc ZZ0003ZZ,
hay không.  Nếu không, nó sẽ từ chối áp dụng các loại chuỗi. Ngoài ra, với BTF
hỗ trợ, bạn không cần toán tử quy chiếu bộ nhớ (ZZ0004ZZ) cho
truy cập chuỗi được trỏ bởi ZZ0005ZZ. Nó tự động thêm bộ nhớ
toán tử dereference theo kiểu BTF. ví dụ. ::

# echo 't sched_switch prev->comm:string' >> Dynamic_events
# echo 'f getname_flags%return $retval->name:string' >> Dynamic_events

ZZ0000ZZ là một mảng char được nhúng trong cấu trúc dữ liệu và
ZZ0001ZZ là con trỏ char trong cấu trúc dữ liệu. Nhưng ở cả hai
trường hợp, bạn có thể sử dụng loại ZZ0002ZZ để lấy chuỗi.


Ví dụ sử dụng
--------------
Dưới đây là một ví dụ để thêm các sự kiện fprobe trên mục nhập hàm ZZ0000ZZ
và thoát, với các đối số BTF.
::

# echo 'f vfs_read $arg*' >> Dynamic_events
  # echo 'f vfs_read%return $retval' >> Dynamic_events
  # cat động_sự kiện
 f:fprobes/vfs_read__entry vfs_read file=file buf=buf count=count pos=pos
 f:fprobes/vfs_read__exit vfs_read%return arg1=$retval
  # echo 1 > sự kiện/fprobes/bật
  # head -n 20 dấu vết | đuôi
 #           ZZ0003ZZ-ZZ0004ZZ CPU# |||||  TIMESTAMP FUNCTION
 #              ZZ0008ZZ ZZ0001ZZ|||ZZ0002ZZ |
               sh-70 [000] ...1.   335.883195: vfs_read__entry: (vfs_read+0x4/0x340) file=0xffff888005cf9a80 buf=0x7ffef36c6879 count=1 pos=0xffffc900005aff08
               sh-70 [000]..... 335.883208: vfs_read__exit: (ksys_read+0x75/0x100 <- vfs_read) arg1=1
               sh-70 [000] ...1.   335.883220: vfs_read__entry: (vfs_read+0x4/0x340) file=0xffff888005cf9a80 buf=0x7ffef36c6879 count=1 pos=0xffffc900005aff08
               sh-70 [000]..... 335.883224: vfs_read__exit: (ksys_read+0x75/0x100 <- vfs_read) arg1=1
               sh-70 [000] ...1.   335.883232: vfs_read__entry: (vfs_read+0x4/0x340) file=0xffff888005cf9a80 buf=0x7ffef36c687a count=1 pos=0xffffc900005aff08
               sh-70 [000]..... 335.883237: vfs_read__exit: (ksys_read+0x75/0x100 <- vfs_read) arg1=1
               sh-70 [000] ...1.   336.050329: vfs_read__entry: (vfs_read+0x4/0x340) file=0xffff888005cf9a80 buf=0x7ffef36c6879 count=1 pos=0xffffc900005aff08
               sh-70 [000]..... 336.050343: vfs_read__exit: (ksys_read+0x75/0x100 <- vfs_read) arg1=1

Bạn có thể thấy tất cả các đối số và giá trị trả về của hàm được ghi dưới dạng int đã ký.

Ngoài ra, đây là ví dụ về các sự kiện điểm theo dõi trên điểm theo dõi ZZ0000ZZ.
Để so sánh kết quả, điều này cũng cho phép sự kiện theo dõi ZZ0001ZZ.
::

# echo 't sched_switch $arg*' >> Dynamic_events
  # echo 1 > sự kiện/lịch biểu/sched_switch/bật
  # echo 1 > sự kiện/tracepoints/sched_switch/bật
  # echo > dấu vết
  # head -n 20 dấu vết | đuôi
 #           ZZ0003ZZ-ZZ0004ZZ CPU# |||||  TIMESTAMP FUNCTION
 #              ZZ0008ZZ ZZ0001ZZ|||ZZ0002ZZ |
               sh-70 [000] d..2.  3912.083993: sched_switch: prev_comm=sh prev_pid=70 prev_prio=120 prev_state=S ==> next_comm=swapper/0 next_pid=0 next_prio=120
               sh-70 [000] d..3.  3912.083995: sched_switch: (__probesub_sched_switch+0x4/0x10) preempt=0 prev=0xffff88800664e100 next=0xffffffff828229c0 prev_state=1
           <nhàn rỗi>-0 [000] d..2.  3912.084183: sched_switch: prev_comm=swapper/0 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=rcu_preempt next_pid=16 next_prio=120
           <nhàn rỗi>-0 [000] d..3.  3912.084184: sched_switch: (__probesub_sched_switch+0x4/0x10) preempt=0 prev=0xffffffff828229c0 next=0xffff888004208000 prev_state=0
      rcu_preempt-16 [000] d..2.  3912.084196: sched_switch: prev_comm=rcu_preempt prev_pid=16 prev_prio=120 prev_state=I ==> next_comm=swapper/0 next_pid=0 next_prio=120
      rcu_preempt-16 [000] d..3.  3912.084196: sched_switch: (__probesub_sched_switch+0x4/0x10) preempt=0 prev=0xffff888004208000 next=0xffffffff828229c0 prev_state=1026
           <nhàn rỗi>-0 [000] d..2.  3912.085191: sched_switch: prev_comm=swapper/0 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=rcu_preempt next_pid=16 next_prio=120
           <nhàn rỗi>-0 [000] d..3.  3912.085191: sched_switch: (__probesub_sched_switch+0x4/0x10) preempt=0 prev=0xffffffff828229c0 next=0xffff888004208000 prev_state=0

Như bạn có thể thấy, sự kiện theo dõi ZZ0000ZZ hiển thị các tham số ZZ0004ZZ, trên
mặt khác, sự kiện thăm dò dấu vết ZZ0001ZZ cho thấy ZZ0005ZZ
các thông số. Điều này có nghĩa là bạn có thể truy cập bất kỳ giá trị trường nào trong tác vụ
cấu trúc được trỏ bởi các đối số ZZ0002ZZ và ZZ0003ZZ.

Ví dụ: thông thường ZZ0000ZZ không được truy tìm, nhưng với điều này
sự kiện traceprobe, bạn có thể theo dõi trường đó như bên dưới.
::

# echo 't sched_switch comm=next->comm:string next->start_time' > Dynamic_events
  # head -n 20 dấu vết | đuôi
 #           ZZ0003ZZ-ZZ0004ZZ CPU# |||||  TIMESTAMP FUNCTION
 #              ZZ0008ZZ ZZ0001ZZ|||ZZ0002ZZ |
               sh-70 [000] d..3.  5606.686577: sched_switch: (__probesub_sched_switch+0x4/0x10) comm="rcu_preempt" use=1 start_time=245000000
      rcu_preempt-16 [000] d..3.  5606.686602: sched_switch: (__probesub_sched_switch+0x4/0x10) comm="sh" Usage=1 start_time=1596095526
               sh-70 [000] d..3.  5606.686637: sched_switch: (__probesub_sched_switch+0x4/0x10) comm="swapper/0" Usage=2 start_time=0
           <nhàn rỗi>-0 [000] d..3.  5606.687190: sched_switch: (__probesub_sched_switch+0x4/0x10) comm="rcu_preempt" use=1 start_time=245000000
      rcu_preempt-16 [000] d..3.  5606.687202: sched_switch: (__probesub_sched_switch+0x4/0x10) comm="swapper/0" Usage=2 start_time=0
           <nhàn rỗi>-0 [000] d..3.  5606.690317: sched_switch: (__probesub_sched_switch+0x4/0x10) comm="kworker/0:1" use=1 start_time=137000000
      kworker/0:1-14 [000] d..3.  5606.690339: sched_switch: (__probesub_sched_switch+0x4/0x10) comm="swapper/0" Usage=2 start_time=0
           <nhàn rỗi>-0 [000] d..3.  5606.692368: sched_switch: (__probesub_sched_switch+0x4/0x10) comm="kworker/0:1" use=1 start_time=137000000

.. _fprobetrace_exit_args_sample:

Thăm dò trả về cho phép chúng ta truy cập kết quả của một số hàm, trả về
mã lỗi và kết quả của nó được truyền qua tham số hàm, chẳng hạn như
chức năng khởi tạo cấu trúc.

Ví dụ: vfs_open() sẽ liên kết cấu trúc tệp với inode và cập nhật
chế độ. Bạn có thể theo dõi những thay đổi đó bằng đầu dò quay lại.
::

# echo 'f vfs_open mode=file->f_mode:x32 inode=file->f_inode:x64' >> Dynamic_events
 # echo 'f vfs_open%%return mode=file->f_mode:x32 inode=file->f_inode:x64' >> Dynamic_events
 # echo 1 > sự kiện/fprobes/bật
 Dấu vết # cat
              sh-131 [006] ...1.  1945.714346: vfs_open__entry: (vfs_open+0x4/0x40) mode=0x2 inode=0x0
              sh-131 [006] ...1.  1945.714358: vfs_open__exit: (do_open+0x274/0x3d0 <- vfs_open) mode=0x4d801e inode=0xffff888008470168
             mèo-143 [007] ...1.  1945.717949: vfs_open__entry: (vfs_open+0x4/0x40) mode=0x1 inode=0x0
             mèo-143 [007] ...1.  1945.717956: vfs_open__exit: (do_open+0x274/0x3d0 <- vfs_open) mode=0x4a801d inode=0xffff888005f78d28
             mèo-143 [007] ...1.  1945.720616: vfs_open__entry: (vfs_open+0x4/0x40) mode=0x1 inode=0x0
             mèo-143 [007] ...1.  1945.728263: vfs_open__exit: (do_open+0x274/0x3d0 <- vfs_open) mode=0xa800d inode=0xffff888004ada8d8

Bạn có thể thấy ZZ0000ZZ và ZZ0001ZZ được cập nhật trong ZZ0002ZZ.