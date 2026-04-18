.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/proc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Hệ thống tập tin /proc
====================

====================== ========================================== ==================
/proc/sys Terrehon Bowden <terrehon@pacbell.net>, ngày 7 tháng 10 năm 1999
                       Bodo Bauer <bb@ricochet.net>
Cập nhật 2.4.x Jorge Nerin <comandante@zaralinux.com> 14 tháng 11 năm 2000
di chuyển /proc/sys Shen Feng <shen@cn.fujitsu.com> Ngày 1 tháng 4 năm 2009
sửa/cập nhật phần 1.1 Stefani Seibold <stefani@seibold.net> 9 tháng 6 năm 2009
====================== ========================================== ==================



.. Table of Contents

  0     Preface
  0.1	Introduction/Credits
  0.2	Legal Stuff

  1	Collecting System Information
  1.1	Process-Specific Subdirectories
  1.2	Kernel data
  1.3	IDE devices in /proc/ide
  1.4	Networking info in /proc/net
  1.5	SCSI info
  1.6	Parallel port info in /proc/parport
  1.7	TTY info in /proc/tty
  1.8	Miscellaneous kernel statistics in /proc/stat
  1.9	Ext4 file system parameters

  2	Modifying System Parameters

  3	Per-Process Parameters
  3.1	/proc/<pid>/oom_adj & /proc/<pid>/oom_score_adj - Adjust the oom-killer
								score
  3.2	/proc/<pid>/oom_score - Display current oom-killer score
  3.3	/proc/<pid>/io - Display the IO accounting fields
  3.4	/proc/<pid>/coredump_filter - Core dump filtering settings
  3.5	/proc/<pid>/mountinfo - Information about mounts
  3.6	/proc/<pid>/comm  & /proc/<pid>/task/<tid>/comm
  3.7   /proc/<pid>/task/<tid>/children - Information about task children
  3.8   /proc/<pid>/fdinfo/<fd> - Information about opened file
  3.9   /proc/<pid>/map_files - Information about memory mapped files
  3.10  /proc/<pid>/timerslack_ns - Task timerslack value
  3.11	/proc/<pid>/patch_state - Livepatch patch operation state
  3.12	/proc/<pid>/arch_status - Task architecture specific information
  3.13  /proc/<pid>/fd - List of symlinks to open files
  3.14  /proc/<pid>/ksm_stat - Information about the process's ksm status.

  4	Configuring procfs
  4.1	Mount options

  5	Filesystem behavior

Lời nói đầu
=======

0.1 Giới thiệu/Tín dụng
------------------------

Chúng tôi xin cảm ơn Alan Cox, Rik van Riel, Alexey Kuznetsov và rất nhiều
người khác để được giúp đỡ biên soạn tài liệu này. Chúng tôi cũng muốn mở rộng một
đặc biệt cảm ơn Andi Kleen về tài liệu mà chúng tôi đã dựa vào rất nhiều
để tạo ra tài liệu này cũng như những thông tin bổ sung mà ông đã cung cấp.
Cảm ơn tất cả những người đã đóng góp nguồn hoặc tài liệu cho nhân Linux
và đã giúp tạo ra một phần mềm tuyệt vời... :)

Phiên bản mới nhất của tài liệu này có sẵn trực tuyến tại
ZZ0000ZZ

0.2 Nội dung pháp lý
---------------

Chúng tôi không đảm bảo tính chính xác của tài liệu này và nếu bạn đến với chúng tôi
phàn nàn về việc bạn đã làm hỏng hệ thống của mình như thế nào do sử dụng sai
tài liệu, chúng tôi sẽ không cảm thấy có trách nhiệm...

Chương 1: Thu thập thông tin hệ thống
========================================

Trong chương này
---------------
* Điều tra các thuộc tính của hệ thống tập tin giả /proc và của nó
  khả năng cung cấp thông tin về hệ thống Linux đang chạy
* Kiểm tra cấu trúc của /proc
* Khám phá nhiều thông tin khác nhau về kernel và các tiến trình đang chạy
  trên hệ thống

------------------------------------------------------------------------------

Hệ thống tệp Proc hoạt động như một giao diện cho các cấu trúc dữ liệu nội bộ trong
hạt nhân. Nó có thể được sử dụng để lấy thông tin về hệ thống và thay đổi
một số tham số kernel nhất định khi chạy (sysctl).

Đầu tiên, chúng ta sẽ xem xét các phần chỉ đọc của /proc. Trong Chương 2, chúng tôi
chỉ cho bạn cách bạn có thể sử dụng /proc/sys để thay đổi cài đặt.

1.1 Thư mục con dành riêng cho quy trình
-----------------------------------

Thư mục /proc chứa (trong số những thứ khác) một thư mục con cho mỗi thư mục
tiến trình đang chạy trên hệ thống, được đặt tên theo ID tiến trình (PID).

Liên kết 'tự' trỏ đến quá trình đọc hệ thống tập tin. Mỗi quá trình
thư mục con có các mục được liệt kê trong Bảng 1-1.

Một tiến trình có thể đọc thông tin của chính nó từ /proc/PID/* mà không cần thêm thông tin nào
quyền. Khi đọc thông tin /proc/PID/* cho các quy trình khác, việc đọc
quy trình được yêu cầu phải có khả năng CAP_SYS_PTRACE với
Quyền truy cập PTRACE_MODE_READ hoặc cách khác là CAP_PERFMON
khả năng. Điều này áp dụng cho tất cả thông tin chỉ đọc như ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, v.v. Ngoại lệ duy nhất là tệp ZZ0003ZZ do tính chất đọc-ghi của nó,
đòi hỏi khả năng của CAP_SYS_PTRACE với mức nâng cao hơn
Quyền PTRACE_MODE_ATTACH; Khả năng CAP_PERFMON không cấp quyền truy cập
đến /proc/PID/mem cho các quy trình khác.

Lưu ý rằng bộ mô tả tệp đang mở tới /proc/<pid> hoặc bất kỳ phần nào của nó
các tệp hoặc thư mục con được chứa không ngăn <pid> được sử dụng lại
cho một số quy trình khác trong trường hợp <pid> thoát. Hoạt động trên
mở bộ mô tả tệp /proc/<pid> tương ứng với các tiến trình chết
không bao giờ hành động trên bất kỳ quy trình mới nào mà kernel có thể có được một cách tình cờ.
cũng được gán ID tiến trình <pid>. Thay vào đó, các thao tác trên các FD này
thường thất bại với ESRCH.

.. table:: Table 1-1: Process specific entries in /proc

 =============  ===============================================================
 File		Content
 =============  ===============================================================
 clear_refs	Clears page referenced bits shown in smaps output
 cmdline	Command line arguments
 cpu		Current and last cpu in which it was executed	(2.4)(smp)
 cwd		Link to the current working directory
 environ	Values of environment variables
 exe		Link to the executable of this process
 fd		Directory, which contains all file descriptors
 maps		Memory maps to executables and library files	(2.4)
 mem		Memory held by this process
 root		Link to the root directory of this process
 stat		Process status
 statm		Process memory status information
 status		Process status in human readable form
 wchan		Present with CONFIG_KALLSYMS=y: it shows the kernel function
		symbol the task is blocked in - or "0" if not blocked.
 pagemap	Page table
 stack		Report full stack trace, enable via CONFIG_STACKTRACE
 smaps		An extension based on maps, showing the memory consumption of
		each mapping and flags associated with it
 smaps_rollup	Accumulated smaps stats for all mappings of the process.  This
		can be derived from smaps, but is faster and more convenient
 numa_maps	An extension based on maps, showing the memory locality and
		binding policy as well as mem usage (in pages) of each mapping.
 =============  ===============================================================

Ví dụ: để có được thông tin trạng thái của một quy trình, tất cả những gì bạn phải làm là
đọc tệp /proc/PID/status::

>mèo /proc/self/status
  Tên: mèo
  Trạng thái: R (đang chạy)
  Tgid: 5452
  Giá trị: 5452
  PPid: 743
  TracerPid: 0 (2.4)
  Mã: 501 501 501 501
  Gid: 100 100 100 100
  Kích thước FD: 256
  Nhóm: 100 14 16
  Chủ đề: 0
  VmPeak: 5004 kB
  Kích thước Vm: 5004 kB
  VmLck: 0 kB
  VmHWM: 476 kB
  VmRSS: 476 kB
  RssAnon: 352 kB
  RssFile: 120 kB
  RssShmem: 4 kB
  Dữ liệu Vm: 156 kB
  VmStk: 88 kB
  VmExe: 68 kB
  VmLib: 1412 kB
  VmPTE: 20 kb
  Hoán đổi Vm: 0 kB
  HugetlbPages: 0 kB
  Bán phá giá lõi: 0
  THP_enabled: 1
  Chủ đề: 1
  SigQ: 0/28578
  Dấu hiệu: 0000000000000000
  ShdPnd: 00000000000000000
  Dấu hiệu: 0000000000000000
  Ký hiệu: 00000000000000000
  SigCgt: 00000000000000000
  CapInh: 00000000ffffeff
  CapPrm: 0000000000000000
  Vốn hóa: 0000000000000000
  CapBnd: ffffffffffffffff
  CapAmb: 0000000000000000
  Không có NewPrivs: 0
  Bí mật: 0
  Speculation_Store_Bypass: luồng dễ bị tổn thương
  SpeculationIndirectBranch: kích hoạt có điều kiện
  tự nguyện_ctxt_switches: 0
  nonvoluntary_ctxt_switches: 1

Điều này hiển thị cho bạn thông tin gần giống như bạn sẽ nhận được nếu bạn xem nó bằng
lệnh ps.  Trên thực tế, ps sử dụng hệ thống tệp Proc để lấy
thông tin.  Nhưng bạn sẽ có được cái nhìn chi tiết hơn về quy trình bằng cách đọc
tập tin /proc/PID/status. Các trường của nó được mô tả trong bảng 1-2.

Tệp statm chứa thông tin chi tiết hơn về quy trình
sử dụng bộ nhớ. Bảy trường của nó được giải thích trong Bảng 1-3.  Tệp thống kê
chứa thông tin chi tiết về chính quá trình đó.  Các trường của nó là
được giải thích trong Bảng 1-4.

(dành cho người dùng SMP CONFIG)

Để có thể mở rộng kế toán, thông tin liên quan đến RSS được xử lý theo cách
cách không đồng bộ và giá trị có thể không chính xác lắm. Để xem chính xác
chụp nhanh một khoảnh khắc, bạn có thể thấy tệp /proc/<pid>/smaps và quét bảng trang.
Nó chậm nhưng rất chính xác.

.. table:: Table 1-2: Contents of the status fields (as of 4.19)

 ==========================  ===================================================
 Field                       Content
 ==========================  ===================================================
 Name                        filename of the executable
 Umask                       file mode creation mask
 State                       state (R is running, S is sleeping, D is sleeping
                             in an uninterruptible wait, Z is zombie,
			     T is traced or stopped)
 Tgid                        thread group ID
 Ngid                        NUMA group ID (0 if none)
 Pid                         process id
 PPid                        process id of the parent process
 TracerPid                   PID of process tracing this process (0 if not, or
                             the tracer is outside of the current pid namespace)
 Uid                         Real, effective, saved set, and  file system UIDs
 Gid                         Real, effective, saved set, and  file system GIDs
 FDSize                      number of file descriptor slots currently allocated
 Groups                      supplementary group list
 NStgid                      descendant namespace thread group ID hierarchy
 NSpid                       descendant namespace process ID hierarchy
 NSpgid                      descendant namespace process group ID hierarchy
 NSsid                       descendant namespace session ID hierarchy
 Kthread                     kernel thread flag, 1 is yes, 0 is no
 VmPeak                      peak virtual memory size
 VmSize                      total program size
 VmLck                       locked memory size
 VmPin                       pinned memory size
 VmHWM                       peak resident set size ("high water mark")
 VmRSS                       size of memory portions. It contains the three
                             following parts
                             (VmRSS = RssAnon + RssFile + RssShmem)
 RssAnon                     size of resident anonymous memory
 RssFile                     size of resident file mappings
 RssShmem                    size of resident shmem memory (includes SysV shm,
                             mapping of tmpfs and shared anonymous mappings)
 VmData                      size of private data segments
 VmStk                       size of stack segments
 VmExe                       size of text segment
 VmLib                       size of shared library code
 VmPTE                       size of page table entries
 VmSwap                      amount of swap used by anonymous private data
                             (shmem swap usage is not included)
 HugetlbPages                size of hugetlb memory portions
 CoreDumping                 process's memory is currently being dumped
                             (killing the process may lead to a corrupted core)
 THP_enabled                 process is allowed to use THP (returns 0 when
                             PR_SET_THP_DISABLE is set on the process to disable
                             THP completely, not just partially)
 Threads                     number of threads
 SigQ                        number of signals queued/max. number for queue
 SigPnd                      bitmap of pending signals for the thread
 ShdPnd                      bitmap of shared pending signals for the process
 SigBlk                      bitmap of blocked signals
 SigIgn                      bitmap of ignored signals
 SigCgt                      bitmap of caught signals
 CapInh                      bitmap of inheritable capabilities
 CapPrm                      bitmap of permitted capabilities
 CapEff                      bitmap of effective capabilities
 CapBnd                      bitmap of capabilities bounding set
 CapAmb                      bitmap of ambient capabilities
 NoNewPrivs                  no_new_privs, like prctl(PR_GET_NO_NEW_PRIV, ...)
 Seccomp                     seccomp mode, like prctl(PR_GET_SECCOMP, ...)
 Speculation_Store_Bypass    speculative store bypass mitigation status
 SpeculationIndirectBranch   indirect branch speculation mode
 Cpus_allowed                mask of CPUs on which this process may run
 Cpus_allowed_list           Same as previous, but in "list format"
 Mems_allowed                mask of memory nodes allowed to this process
 Mems_allowed_list           Same as previous, but in "list format"
 voluntary_ctxt_switches     number of voluntary context switches
 nonvoluntary_ctxt_switches  number of non voluntary context switches
 ==========================  ===================================================


.. table:: Table 1-3: Contents of the statm fields (as of 2.6.8-rc3)

 ======== ===============================	==============================
 Field    Content
 ======== ===============================	==============================
 size     total program size (pages)		(same as VmSize in status)
 resident size of memory portions (pages)	(same as VmRSS in status)
 shared   number of pages that are shared	(i.e. backed by a file, same
						as RssFile+RssShmem in status)
 trs      number of pages that are 'code'	(not including libs; broken,
						includes data segment)
 lrs      number of pages of library		(always 0 on 2.6)
 drs      number of pages of data/stack		(including libs; broken,
						includes library text)
 dt       number of dirty pages			(always 0 on 2.6)
 ======== ===============================	==============================


.. table:: Table 1-4: Contents of the stat fields (as of 2.6.30-rc7)

  ============= ===============================================================
  Field         Content
  ============= ===============================================================
  pid           process id
  tcomm         filename of the executable
  state         state (R is running, S is sleeping, D is sleeping in an
                uninterruptible wait, Z is zombie, T is traced or stopped)
  ppid          process id of the parent process
  pgrp          pgrp of the process
  sid           session id
  tty_nr        tty the process uses
  tty_pgrp      pgrp of the tty
  flags         task flags
  min_flt       number of minor faults
  cmin_flt      number of minor faults with child's
  maj_flt       number of major faults
  cmaj_flt      number of major faults with child's
  utime         user mode jiffies
  stime         kernel mode jiffies
  cutime        user mode jiffies with child's
  cstime        kernel mode jiffies with child's
  priority      priority level
  nice          nice level
  num_threads   number of threads
  it_real_value	(obsolete, always 0)
  start_time    time the process started after system boot
  vsize         virtual memory size
  rss           resident set memory size
  rsslim        current limit in bytes on the rss
  start_code    address above which program text can run
  end_code      address below which program text can run
  start_stack   address of the start of the main process stack
  esp           current value of ESP
  eip           current value of EIP
  pending       bitmap of pending signals
  blocked       bitmap of blocked signals
  sigign        bitmap of ignored signals
  sigcatch      bitmap of caught signals
  0		(place holder, used to be the wchan address,
		use /proc/PID/wchan instead)
  0             (place holder)
  0             (place holder)
  exit_signal   signal to send to parent thread on exit
  task_cpu      which CPU the task is scheduled on
  rt_priority   realtime priority
  policy        scheduling policy (man sched_setscheduler)
  blkio_ticks   time spent waiting for block IO
  gtime         guest time of the task in jiffies
  cgtime        guest time of the task children in jiffies
  start_data    address above which program data+bss is placed
  end_data      address below which program data+bss is placed
  start_brk     address above which program heap can be expanded with brk()
  arg_start     address above which program command line is placed
  arg_end       address below which program command line is placed
  env_start     address above which program environment is placed
  env_end       address below which program environment is placed
  exit_code     the thread's exit_code in the form reported by the waitpid
		system call
  ============= ===============================================================

Tệp /proc/PID/maps chứa các vùng bộ nhớ hiện được ánh xạ và
quyền truy cập của họ.

Định dạng là::

địa chỉ perms offset tên đường dẫn inode dev

08048000-08049000 r-xp 00000000 03:00 8312 /opt/test
    08049000-0804a000 rw-p 00001000 03:00 8312 /opt/test
    0804a000-0806b000 rw-p 00000000 00:00 0 [đống]
    a7cb1000-a7cb2000 ---p 00000000 00:00 0
    a7cb2000-a7eb2000 rw-p 00000000 00:00 0
    a7eb2000-a7eb3000 ---p 00000000 00:00 0
    a7eb3000-a7ed5000 rw-p 00000000 00:00 0
    a7ed5000-a8008000 r-xp 00000000 03:00 4222 /lib/libc.so.6
    a8008000-a800a000 r--p 00133000 03:00 4222 /lib/libc.so.6
    a800a000-a800b000 rw-p 00135000 03:00 4222 /lib/libc.so.6
    a800b000-a800e000 rw-p 00000000 00:00 0
    a800e000-a8022000 r-xp 00000000 03:00 14462 /lib/libpthread.so.0
    a8022000-a8023000 r--p 00013000 03:00 14462 /lib/libpthread.so.0
    a8023000-a8024000 rw-p 00014000 03:00 14462 /lib/libpthread.so.0
    a8024000-a8027000 rw-p 00000000 00:00 0
    a8027000-a8043000 r-xp 00000000 03:00 8317 /lib/ld-linux.so.2
    a8043000-a8044000 r--p 0001b000 03:00 8317 /lib/ld-linux.so.2
    a8044000-a8045000 rw-p 0001c000 03:00 8317 /lib/ld-linux.so.2
    aff35000-aff4a000 rw-p 00000000 00:00 0 [ngăn xếp]
    ffffe000-fffff000 r-xp 00000000 00:00 0 [vdso]

trong đó "địa chỉ" là không gian địa chỉ trong quá trình mà nó chiếm giữ, "perms"
là một tập hợp các quyền::

r = đọc
 w = viết
 x = thực hiện
 s = chia sẻ
 p = riêng tư (sao chép trên ghi)

"offset" là phần bù trong ánh xạ, "dev" là thiết bị (chính: phụ) và
"inode" là inode trên thiết bị đó.  0 chỉ ra rằng không có nút nào được liên kết
với vùng bộ nhớ, như trường hợp của BSS (dữ liệu chưa được khởi tạo).
"Tên đường dẫn" hiển thị tên tệp được liên kết cho ánh xạ này.  Nếu việc lập bản đồ
không được liên kết với một tập tin:

====================================================================
 [heap] đống của chương trình
 [ngăn xếp] ngăn xếp của tiến trình chính
 [vdso] "đối tượng chia sẻ động ảo",
                            trình xử lý cuộc gọi hệ thống kernel
 [anon:<name>] một bản đồ ẩn danh riêng tư đã được
                            được đặt tên theo không gian người dùng
 [anon_shmem:<name>] một ánh xạ bộ nhớ chia sẻ ẩn danh có
                            được đặt tên theo không gian người dùng
 ====================================================================

hoặc nếu trống, ánh xạ sẽ ẩn danh.

Bắt đầu với kernel 6.11, /proc/PID/maps cung cấp một giải pháp thay thế
API dựa trên ioctl() mang lại khả năng truy vấn và
lọc các VMA riêng lẻ. Giao diện này là nhị phân và có nghĩa là để biết thêm
sử dụng chương trình một cách hiệu quả và dễ dàng. ZZ0000ZZ, được định nghĩa trong
tiêu đề linux/fs.h UAPI, đóng vai trò là đối số đầu vào/đầu ra cho
Lệnh ZZ0001ZZ ioctl(). Xem nhận xét trong tiêu đề Linus/fs.h UAPI để biết
chi tiết về ngữ nghĩa truy vấn, cờ được hỗ trợ, dữ liệu được trả về và API chung
thông tin sử dụng.

/proc/PID/smaps là phần mở rộng dựa trên bản đồ, hiển thị bộ nhớ
mức tiêu thụ cho mỗi ánh xạ của quá trình. Đối với mỗi ánh xạ (còn gọi là ảo
Vùng nhớ, hay VMA) có một loạt các dòng như sau::

08048000-080bc000 r-xp 00000000 03:02 13130/bin/bash

Kích thước: 1084 kB
    KernelPageSize: 4 kB
    MMUPageSize: 4 kB
    Rs: 892 kB
    Pss: 374 kB
    Pss_Dirty: 0 kB
    Shared_Clean: 892 kB
    Shared_Dirty: 0 kB
    Riêng tư_Clean: 0 kB
    Riêng tư_Bẩn: 0 kB
    Tham chiếu: 892 kB
    Ẩn danh: 0 kB
    KSM: 0 kB
    Lười biếng: 0 kB
    AnonHugePages: 0 kB
    FilePmdMapped: 0 kB
    ShmemPmdĐã ánh xạ: 0 kB
    Shared_Hugetlb: 0 kB
    Riêng tư_Hugetlb: 0 kB
    Hoán đổi: 0 kB
    Hoán đổi Pss: 0 kB
    Đã khóa: 0 kB
    THĐủ điều kiện: 0
    VmFlags: rd ex mr mw me dw

Dòng đầu tiên hiển thị thông tin tương tự như được hiển thị cho
ánh xạ trong /proc/PID/maps.  Các dòng tiếp theo hiển thị kích thước của
ánh xạ (kích thước); kích thước trang nhỏ nhất có thể được phân bổ khi sao lưu một
VMA (KernelPageSize), là mức độ chi tiết trong đó VMA sửa đổi
có thể được thực hiện; kích thước trang nhỏ nhất có thể được sử dụng bởi
MMU (MMUPageSize) khi sao lưu VMA; số lượng bản đồ đó là
hiện đang cư trú tại RAM (RSS); tỷ lệ phần trăm của quá trình này
ánh xạ (PSS); và số lượng trang chia sẻ và riêng tư sạch và bẩn
trong bản đồ.

"KernelPageSize" luôn tương ứng với "MMUPageSize", ngoại trừ khi kích thước lớn hơn
kích thước trang kernel được mô phỏng trên một hệ thống có kích thước trang nhỏ hơn được sử dụng bởi
MMU, trường hợp này xảy ra với một số thiết lập PPC64 có Hugetlb.  Hơn nữa,
"KernelPageSize" và "MMUPageSize" luôn tương ứng với kích thước nhỏ nhất
mức độ chi tiết có thể có (dự phòng) có thể gặp trong VMA xuyên suốt
cuộc đời của nó.  Các giá trị này không bị ảnh hưởng bởi Trang lớn trong suốt
đang có hiệu lực hoặc bất kỳ việc sử dụng kích thước trang MMU lớn hơn nào (thông qua
ánh xạ trang lớn về kiến trúc hoặc sự kết hợp rõ ràng/ngầm khác của
phạm vi ảo được thực hiện bởi MMU).  "AnonHugePages", "ShmemPmdMapped" và
"FilePmdMapped" cung cấp cái nhìn sâu sắc về cách sử dụng kiến trúc cấp PMD
ánh xạ trang lớn.

"Kích thước đặt theo tỷ lệ" (PSS) của một quy trình là số lượng trang mà nó có
trong bộ nhớ, trong đó mỗi trang được chia cho số tiến trình chia sẻ nó.
Vì vậy, nếu một quy trình có tất cả 1000 trang và 1000 trang được chia sẻ với nhau
quá trình, PSS của nó sẽ là 1500. "Pss_Dirty" là phần của PSS mà
bao gồm các trang bẩn.  ("Pss_Clean" không được bao gồm nhưng có thể
được tính bằng cách trừ "Pss_Dirty" khỏi "Pss".)

Theo truyền thống, một trang được coi là "riêng tư" nếu nó được ánh xạ chính xác một lần,
và một trang được coi là "được chia sẻ" khi được ánh xạ nhiều lần, ngay cả khi
được ánh xạ trong cùng một quá trình nhiều lần. Lưu ý rằng việc hạch toán này
độc lập với MAP_SHARED.

Trong một số cấu hình hạt nhân, ngữ nghĩa của các trang là một phần của một phần lớn hơn
phân bổ (ví dụ: THP) có thể khác nhau: một trang được coi là "riêng tư" nếu tất cả
phần trang của phân bổ lớn tương ứng được ZZ0000ZZ ánh xạ trong
cùng một quy trình, ngay cả khi trang được ánh xạ nhiều lần trong quy trình đó. A
trang được tính là "được chia sẻ" nếu trang nào có phân bổ lớn hơn
ZZ0001ZZ được ánh xạ trong một quy trình khác. Trong một số trường hợp, một sự phân bổ lớn
có thể được coi là "có thể được ánh xạ bởi nhiều quy trình" mặc dù điều này
không còn là trường hợp nữa.

Một số cấu hình kernel không theo dõi số lần chính xác của một phần trang
phân bổ lớn hơn được ánh xạ. Trong trường hợp này, khi tính toán PSS,
số ánh xạ trung bình trên mỗi trang trong phân bổ lớn hơn này có thể được sử dụng
như một xấp xỉ cho số lượng ánh xạ của một trang. Tính toán PSS
sẽ không chính xác trong trường hợp này.

"Được tham chiếu" cho biết dung lượng bộ nhớ hiện được đánh dấu là được tham chiếu hoặc
đã truy cập.

"Ẩn danh" hiển thị dung lượng bộ nhớ không thuộc về bất kỳ tệp nào.  Thậm chí
ánh xạ được liên kết với một tệp có thể chứa các trang ẩn danh: khi MAP_PRIVATE
và một trang được sửa đổi, trang tệp được thay thế bằng một bản sao ẩn danh riêng tư.

"KSM" báo cáo có bao nhiêu trang là trang KSM. Lưu ý rằng các trang số 0 được đặt ở KSM
không được bao gồm, chỉ có các trang KSM thực tế.

"LazyFree" hiển thị dung lượng bộ nhớ được đánh dấu bằng madvise(MADV_FREE).
Bộ nhớ không được giải phóng ngay lập tức bằng madvise(). Nó được giải phóng trong bộ nhớ
áp lực nếu bộ nhớ sạch. Xin lưu ý rằng giá trị được in có thể
thấp hơn giá trị thực do tối ưu hóa được sử dụng trong hiện tại
thực hiện. Nếu điều này không được mong muốn, vui lòng gửi báo cáo lỗi.

"AnonHugePages", "ShmemPmdMapped" và "FilePmdMapped" hiển thị số lượng
bộ nhớ được hỗ trợ bởi các Trang lớn trong suốt hiện được ánh xạ bởi
ánh xạ trang lớn về kiến trúc ở cấp độ PMD. "AnonHugePages"
tương ứng với bộ nhớ không thuộc về một tập tin, "ShmemPmdMapped" tới
bộ nhớ dùng chung (shmem/tmpfs) và "FilePmdMapped" vào bộ nhớ được hỗ trợ bằng tệp
(không bao gồm shmem/tmpfs).

Không có mục dành riêng cho Trang lớn trong suốt (hoặc các khái niệm tương tự)
không được ánh xạ bằng ánh xạ trang lớn về kiến trúc ở cấp độ PMD.

"Shared_Hugetlb" và "Private_Hugetlb" hiển thị lượng bộ nhớ được hỗ trợ bởi
trang Hugetlbfs là ZZ0000ZZ được tính trong trường "RSS" hoặc "PSS" cho lịch sử
lý do. Và những thứ này không được bao gồm trong trường {Shared,Private__{Clean,Dirty}.

"Hoán đổi" cho biết lượng bộ nhớ ẩn danh cũng được sử dụng nhưng đã hết khi trao đổi.

Đối với ánh xạ shmem, "Hoán đổi" cũng bao gồm kích thước của ánh xạ (chứ không phải
được thay thế bằng phần sao chép khi ghi) của đối tượng shmem cơ bản khi trao đổi.
"SwapPss" hiển thị tỷ lệ hoán đổi theo tỷ lệ của ánh xạ này. Không giống như "Hoán đổi", điều này
không tính đến trang bị tráo đổi của các đối tượng shmem cơ bản.
"Đã khóa" cho biết liệu ánh xạ có bị khóa trong bộ nhớ hay không.

"THPeligible" cho biết liệu ánh xạ có đủ điều kiện để phân bổ hay không
Các trang THP được căn chỉnh tự nhiên ở bất kỳ kích thước nào hiện được kích hoạt. 1 nếu đúng, 0
mặt khác.

Trường "VmFlags" xứng đáng được mô tả riêng. Thành viên này đại diện cho
cờ hạt nhân được liên kết với vùng bộ nhớ ảo cụ thể trong hai chữ cái
cách được mã hóa. Các mã như sau:

====================================================================
    thứ có thể đọc được
    có thể viết được
    có thể thực thi được
    sh đã chia sẻ
    ông có thể đọc
    tôi có thể viết
    tôi có thể thi hành
    ms có thể chia sẻ
    phân đoạn ngăn xếp gd phát triển xuống
    phạm vi PFN thuần túy pf
    lo các trang bị khóa trong bộ nhớ
    vùng I/O được ánh xạ trong bộ nhớ io
    tư vấn đọc tuần tự sr được cung cấp
    rr cung cấp lời khuyên đọc ngẫu nhiên
    dc không sao chép vùng trên ngã ba
    de không mở rộng khu vực khi ánh xạ lại
    khu vực ac có trách nhiệm
    không gian trao đổi nr không được dành riêng cho khu vực
    khu vực ht sử dụng các trang tlb lớn
    lỗi trang đồng bộ sf
    cờ cụ thể của kiến trúc ar
    lau trên nĩa
    dd không bao gồm khu vực vào kết xuất lõi
    cờ bẩn mềm sd
    mm khu vực bản đồ hỗn hợp
    cờ tư vấn trang lớn hg
    nh không có cờ tư vấn trang lớn
    cờ tư vấn có thể hợp nhất mg
    trang được bảo vệ bt arm64 BTI
    Thẻ phân bổ mt arm64 MTE được bật
    ừ userfaultfd thiếu theo dõi
    theo dõi userfaultfd wr-protect
    ui userfaultfd lỗi nhỏ
    trang ngăn xếp điều khiển bóng/bảo vệ ss
    sl niêm phong
    lf khóa trên các trang lỗi
    dp luôn có thể tự do lập bản đồ một cách lười biếng
    gu có thể chứa các vùng bảo vệ (nếu không được đặt thì chắc chắn là không)
    ====================================================================

Lưu ý rằng không có gì đảm bảo rằng mọi lá cờ và từ gợi nhớ liên quan sẽ
có mặt trong tất cả các bản phát hành kernel tiếp theo. Mọi thứ thay đổi, những lá cờ có thể
biến mất hoặc ngược lại - mới được thêm vào. Giải thích ý nghĩa của chúng
cũng có thể thay đổi trong tương lai. Vì vậy, mỗi người tiêu dùng những lá cờ này phải
theo dõi từng phiên bản kernel cụ thể để biết ngữ nghĩa chính xác.

Tệp này chỉ xuất hiện nếu tùy chọn cấu hình kernel CONFIG_MMU được cài đặt
đã bật.

Lưu ý: việc đọc /proc/PID/maps hoặc /proc/PID/smaps vốn đã không phù hợp (nhất quán
đầu ra chỉ có thể đạt được trong lệnh gọi đọc duy nhất).

Điều này thường biểu hiện khi thực hiện đọc một phần các tệp này trong khi
bản đồ bộ nhớ đang được sửa đổi.  Bất chấp các cuộc đua, chúng tôi cung cấp những điều sau đây
đảm bảo:

1) Các địa chỉ được ánh xạ không bao giờ quay ngược lại, nghĩa là không có hai
   các khu vực sẽ chồng chéo lên nhau.
2) Nếu có điều gì đó xảy ra tại một vaddr nhất định trong toàn bộ thời gian
   vòng đời của bản đồ/bản đồ đi bộ, sẽ có một số đầu ra cho nó.

Tệp /proc/PID/smaps_rollup bao gồm các trường giống như /proc/PID/smaps,
nhưng giá trị của chúng là tổng của các giá trị tương ứng cho tất cả ánh xạ của
quá trình này.  Ngoài ra, nó còn chứa các trường này:

- Pss_Anon
- Tệp Pss_File
- Pss_Shmem

Chúng đại diện cho tỷ lệ chia sẻ của các trang ẩn danh, tệp và trang shmem, như
được mô tả cho các bản đồ ở trên.  Các trường này bị bỏ qua trong bản đồ vì mỗi
ánh xạ xác định loại (anon, tệp hoặc shmem) của tất cả các trang chứa trong đó.
Do đó tất cả thông tin trong smaps_rollup có thể được lấy từ smaps, nhưng ở một mức độ nào đó.
chi phí cao hơn đáng kể.

/proc/PID/clear_refs được sử dụng để đặt lại PG_Referenced và ACCESSED/YOUNG
các bit trên cả trang vật lý và trang ảo được liên kết với một quy trình và
bit bẩn mềm trên pte (xem Tài liệu/admin-guide/mm/soft-dirty.rst
để biết chi tiết).
Để xóa các bit cho tất cả các trang được liên kết với quy trình::

> echo 1 > /proc/PID/clear_refs

Để xóa các bit cho các trang ẩn danh được liên kết với quy trình::

> echo 2 > /proc/PID/clear_refs

Để xóa các bit cho các trang được ánh xạ tệp được liên kết với quy trình::

> echo 3 > /proc/PID/clear_refs

Để xóa bit bẩn mềm::

> echo 4 > /proc/PID/clear_refs

Để đặt lại kích thước cài đặt thường trú cao nhất ("dấu nước cao") thành quy trình
giá trị hiện tại::

> echo 5 > /proc/PID/clear_refs

Bất kỳ giá trị nào khác được ghi vào /proc/PID/clear_refs sẽ không có hiệu lực.

/proc/pid/pagemap cung cấp PFN, có thể được sử dụng để tìm cờ trang
sử dụng /proc/kpageflags và số lần một trang được ánh xạ bằng cách sử dụng
/proc/kpagecount. Để được giải thích chi tiết, xem
Tài liệu/admin-guide/mm/pagemap.rst.

/proc/pid/numa_maps là tiện ích mở rộng dựa trên bản đồ, hiển thị bộ nhớ
chính sách cục bộ và ràng buộc, cũng như việc sử dụng bộ nhớ (tính bằng trang) của
mỗi bản đồ. Đầu ra tuân theo một định dạng chung trong đó các chi tiết ánh xạ được lấy
được tóm tắt cách nhau bằng khoảng trống, một ánh xạ trên mỗi dòng tệp ::

chi tiết ánh xạ chính sách địa chỉ

00400000 tệp mặc định=/usr/local/bin/app mapped=1 active=0 N3=1 kernelpagesize_kB=4
    00600000 tệp mặc định=/usr/local/bin/app anon=1 dirty=1 N3=1 kernelpagesize_kB=4
    3206000000 tệp mặc định=/lib64/ld-2.12.so mapped=26 mapmax=6 N0=24 N3=2 kernelpagesize_kB=4
    320621f000 tệp mặc định=/lib64/ld-2.12.so anon=1 dirty=1 N3=1 kernelpagesize_kB=4
    3206220000 tệp mặc định=/lib64/ld-2.12.so anon=1 dirty=1 N3=1 kernelpagesize_kB=4
    3206221000 mặc định anon=1 dirty=1 N3=1 kernelpagesize_kB=4
    3206800000 tệp mặc định=/lib64/libc-2.12.so mapped=59 mapmax=21 active=55 N0=41 N3=18 kernelpagesize_kB=4
    320698b000 tệp mặc định=/lib64/libc-2.12.so
    3206b8a000 tệp mặc định=/lib64/libc-2.12.so anon=2 dirty=2 N3=2 kernelpagesize_kB=4
    3206b8e000 tệp mặc định=/lib64/libc-2.12.so anon=1 dirty=1 N3=1 kernelpagesize_kB=4
    3206b8f000 mặc định anon=3 dirty=3 active=1 N3=3 kernelpagesize_kB=4
    7f4dc10a2000 mặc định anon=3 dirty=3 N3=3 kernelpagesize_kB=4
    7f4dc10b4000 mặc định anon=2 dirty=2 active=1 N3=2 kernelpagesize_kB=4
    7f4dc1200000 tệp mặc định=/anon_hugepage\040(đã xóa) anon lớn=1 dirty=1 N3=1 kernelpagesize_kB=2048
    7fff335f0000 ngăn xếp mặc định anon=3 dirty=3 N3=3 kernelpagesize_kB=4
    7fff3369d000 ánh xạ mặc định=1 mapmax=35 hoạt động=0 N3=1 kernelpagesize_kB=4

Ở đâu:

"địa chỉ" là địa chỉ bắt đầu cho việc ánh xạ;

"chính sách" báo cáo chính sách bộ nhớ NUMA được đặt cho ánh xạ (xem Tài liệu/admin-guide/mm/numa_memory_policy.rst);

"chi tiết ánh xạ" tóm tắt dữ liệu ánh xạ như loại ánh xạ, bộ đếm sử dụng trang,
bộ đếm trang cục bộ của nút (N0 == node0, N1 == node1, ...) và trang kernel
kích thước, tính bằng KB, đang sao lưu ánh xạ.

Lưu ý rằng một số cấu hình kernel không theo dõi số lần chính xác
một phần trang của phân bổ lớn hơn (ví dụ: THP) được ánh xạ. Trong này
cấu hình, "mapmax" có thể tương ứng với số lượng ánh xạ trung bình
trên mỗi trang với mức phân bổ lớn hơn.

1.2 Dữ liệu hạt nhân
---------------

Tương tự như các mục tiến trình, các tệp dữ liệu hạt nhân cung cấp thông tin về
kernel đang chạy. Các tập tin được sử dụng để có được thông tin này được chứa trong
/proc và được liệt kê trong Bảng 1-5. Không phải tất cả những thứ này sẽ có mặt trong
hệ thống. Nó phụ thuộc vào cấu hình kernel và các mô-đun được tải,
các tập tin ở đó và những tập tin bị thiếu.

.. table:: Table 1-5: Kernel info in /proc

 ============ ===============================================================
 File         Content
 ============ ===============================================================
 allocinfo    Memory allocations profiling information
 apm          Advanced power management info
 bootconfig   Kernel command line obtained from boot config,
 	      and, if there were kernel parameters from the
	      boot loader, a "# Parameters from bootloader:"
	      line followed by a line containing those
	      parameters prefixed by "# ".			(5.5)
 buddyinfo    Kernel memory allocator information (see text)	(2.5)
 bus          Directory containing bus specific information
 cmdline      Kernel command line, both from bootloader and embedded
              in the kernel image
 cpuinfo      Info about the CPU
 devices      Available devices (block and character)
 dma          Used DMA channels
 filesystems  Supported filesystems
 driver       Various drivers grouped here, currently rtc	(2.4)
 execdomains  Execdomains, related to security			(2.4)
 fb 	      Frame Buffer devices				(2.4)
 fs 	      File system parameters, currently nfs/exports	(2.4)
 ide          Directory containing info about the IDE subsystem
 interrupts   Interrupt usage
 iomem 	      Memory map					(2.4)
 ioports      I/O port usage
 irq 	      Masks for irq to cpu affinity			(2.4)(smp?)
 isapnp       ISA PnP (Plug&Play) Info				(2.4)
 kcore        Kernel core image (can be ELF or A.OUT(deprecated in 2.4))
 kmsg         Kernel messages
 ksyms        Kernel symbol table
 loadavg      Load average of last 1, 5 & 15 minutes;
                number of processes currently runnable (running or on ready queue);
                total number of processes in system;
                last pid created.
                All fields are separated by one space except "number of
                processes currently runnable" and "total number of processes
                in system", which are separated by a slash ('/'). Example:
                0.61 0.61 0.55 3/828 22084
 locks        Kernel locks
 meminfo      Memory info
 misc         Miscellaneous
 modules      List of loaded modules
 mounts       Mounted filesystems
 net          Networking info (see text)
 pagetypeinfo Additional page allocator information (see text)  (2.5)
 partitions   Table of partitions known to the system
 pci 	      Deprecated info of PCI bus (new way -> /proc/bus/pci/,
              decoupled by lspci				(2.4)
 rtc          Real time clock
 scsi         SCSI info (see text)
 slabinfo     Slab pool info
 softirqs     softirq usage
 stat         Overall statistics
 swaps        Swap space utilization
 sys          See chapter 2
 sysvipc      Info of SysVIPC Resources (msg, sem, shm)		(2.4)
 tty 	      Info of tty drivers
 uptime       Wall clock since boot, combined idle time of all cpus
 version      Kernel version
 video 	      bttv info of video resources			(2.4)
 vmallocinfo  Show vmalloced areas
 ============ ===============================================================

Ví dụ, bạn có thể kiểm tra xem ngắt nào hiện đang được sử dụng và ngắt nào
chúng được sử dụng bằng cách tìm trong tệp /proc/interrupts::

> mèo /proc/ngắt
             CPU0
    0: 8728810 XT-PIC hẹn giờ
    Bàn phím 1: 895 XT-PIC
    Tầng 2: 0 XT-PIC
    3: 531695 XT-PIC aha152x
    4: 2014133 XT-PIC nối tiếp
    5: 44401 XT-PIC pcnet_cs
    8: 2 XT-PIC rtc
   11:8 XT-PIC i82365
   12: 182918 XT-PIC Chuột PS/2
   13:1 XT-PIC fpu
   14: 1232265 XT-PIC ide0
   15:7 XT-PIC ide1
  NMI: 0

Trong 2.4.* một vài dòng được thêm vào tệp này LOC & ERR (lần này là
đầu ra của máy SMP)::

> mèo /proc/ngắt

CPU0 CPU1
    0: 1243498 1214548 IO-APIC-cạnh hẹn giờ
    1: 8949 8958 Bàn phím cạnh IO-APIC
    Tầng 2: 0 0 XT-PIC
    5: 11286 10161 Máy phát âm thanh cạnh IO-APIC
    8: 1 0 IO-APIC cạnh rtc
    9: 27422 27407 IO-APIC-cạnh 3c503
   12: 113645 113873 Chuột PS/2 IO-APIC-edge
   13: 0 0 XT-PIC fpu
   14: 22491 24012 IO-APIC-cạnh ide0
   15: 2183 2415 IO-APIC-cạnh ide1
   17: 30564 30414 IO-APIC cấp eth0
   18: 177 164 IO-APIC cấp bttv
  NMI: 2457961 2457959
  LOC: 2457882 2457881
  ERR: 2155

NMI được tăng lên trong trường hợp này vì mỗi lần ngắt hẹn giờ đều tạo ra NMI
(Non Maskable Interrupt) được NMI Watchdog sử dụng để phát hiện tình trạng khóa.

LOC là bộ đếm ngắt cục bộ của APIC bên trong của mọi CPU.

ERR được tăng lên trong trường hợp có lỗi trên bus IO-APIC (bus mà
kết nối các CPU trong hệ thống SMP. Điều này có nghĩa là một lỗi đã được phát hiện,
IO-APIC tự động thử lại quá trình truyền, vì vậy đây không phải là vấn đề lớn
vấn đề, nhưng bạn nên đọc SMP-FAQ.

Trong 2.6.2* /proc/interrupts lại được mở rộng.  Lần này mục tiêu là dành cho
/proc/ngắt để hiển thị mọi vectơ IRQ đang được hệ thống sử dụng, không phải
chỉ những thứ được coi là 'quan trọng nhất'.  Các vectơ mới là:

THR
  ngắt xảy ra khi bộ đếm ngưỡng kiểm tra máy
  (thường tính các lỗi đã sửa của ECC về bộ nhớ hoặc bộ đệm) vượt quá
  một ngưỡng có thể cấu hình được.  Chỉ có sẵn trên một số hệ thống.

TRM
  một sự gián đoạn nhiệt xảy ra khi ngưỡng nhiệt độ
  đã bị vượt quá đối với CPU.  Ngắt này cũng có thể được tạo ra
  khi nhiệt độ giảm trở lại bình thường.

SPU
  một ngắt giả là một số ngắt được nâng lên rồi hạ xuống
  bởi một số thiết bị IO trước khi nó có thể được APIC xử lý hoàn toàn.  Do đó
  APIC nhìn thấy ngắt nhưng không biết nó đến từ thiết bị nào.
  Trong trường hợp này, APIC sẽ tạo ra ngắt bằng vectơ IRQ
  của 0xff. Điều này cũng có thể được tạo ra bởi lỗi chipset.

RES, CAL, TLB
  sắp xếp lại lịch trình, cuộc gọi và ngắt xả TLB
  được gửi từ CPU này sang CPU khác theo nhu cầu của HĐH.  Thông thường,
  số liệu thống kê của họ được các nhà phát triển kernel và người dùng quan tâm sử dụng để
  xác định sự xuất hiện của các loại ngắt đã cho.

Các vectơ IRQ ở trên chỉ được hiển thị khi có liên quan.  Ví dụ,
vectơ ngưỡng không tồn tại trên nền tảng x86_64.  Những người khác là
bị chặn khi hệ thống là một bộ xử lý đơn.  Tính đến thời điểm viết bài này, chỉ
Nền tảng i386 và x86_64 hỗ trợ màn hình vector IRQ mới.

Điều đáng quan tâm là việc đưa thư mục /proc/irq lên phiên bản 2.4.
Nó có thể được sử dụng để đặt mối quan hệ IRQ thành CPU. Điều này có nghĩa là bạn có thể "nối" một
IRQ thành chỉ một CPU hoặc loại trừ CPU xử lý IRQ. Nội dung của
thư mục con irq là một thư mục con cho mỗi IRQ và default_smp_affinity.

Ví dụ::

> ls /proc/irq/
  0 10 12 14 16 18 2 4 6 8 default_smp_affinity
  1 11 13 15 17 19 3 5 7 9
  > ls /proc/irq/0/
  smp_affinity

smp_affinity là một bitmask, trong đó bạn có thể chỉ định CPU nào có thể xử lý
IRQ. Bạn có thể thiết lập nó bằng cách thực hiện::

> echo 1 > /proc/irq/10/smp_affinity

Điều này có nghĩa là chỉ CPU đầu tiên mới xử lý IRQ, nhưng bạn cũng có thể lặp lại
5, điều đó có nghĩa là chỉ CPU thứ nhất và thứ ba mới có thể xử lý IRQ.

Nội dung của mỗi tệp smp_affinity theo mặc định giống nhau ::

> mèo /proc/irq/0/smp_affinity
  ffffffff

Có một giao diện thay thế, smp_affinity_list cho phép chỉ định
phạm vi CPU thay vì bitmask::

> mèo /proc/irq/0/smp_affinity_list
  1024-1031

Mặt nạ default_smp_affinity áp dụng cho tất cả các IRQ không hoạt động, đó là
Các IRQ chưa được phân bổ/kích hoạt và do đó thiếu
thư mục /proc/irq/[0-9]*.

Tệp nút trên hệ thống SMP hiển thị nút mà thiết bị sử dụng IRQ kết nối tới
báo cáo chính nó như được đính kèm. Thông tin vị trí phần cứng này không
bao gồm thông tin về bất kỳ ưu tiên địa phương nào có thể có của người lái xe.

Cách định tuyến IRQ được xử lý bởi IO-APIC và đó là Round Robin
giữa tất cả các CPU được phép xử lý nó. Như thường lệ kernel có
nhiều thông tin hơn bạn và làm việc tốt hơn bạn, vì vậy giá trị mặc định là
sự lựa chọn tốt nhất cho hầu hết mọi người.  [Lưu ý điều này chỉ áp dụng cho những IO-APIC đó
hỗ trợ phân phối ngắt "Round Robin".]

Có ba thư mục con quan trọng hơn trong /proc: net, scsi và sys.
Nguyên tắc chung là nội dung hoặc thậm chí sự tồn tại của những nội dung này
thư mục, tùy thuộc vào cấu hình kernel của bạn. Nếu SCSI không được kích hoạt,
thư mục scsi có thể không tồn tại. Điều này cũng đúng với mạng, ở đó
chỉ khi có hỗ trợ mạng trong kernel đang chạy.

Tệp Slabinfo cung cấp thông tin về việc sử dụng bộ nhớ ở cấp độ bản sàn.
Linux sử dụng nhóm phiến để quản lý bộ nhớ trên cấp trang trong phiên bản 2.2.
Các đối tượng thường được sử dụng đều có nhóm phiến riêng (chẳng hạn như bộ đệm mạng,
bộ đệm thư mục, v.v.).

::

> mèo /proc/buddyinfo

Nút 0, vùng DMA 0 4 5 4 4 3 ...
    Nút 0, vùng Bình thường 1 0 0 1 101 8 ...
    Nút 0, vùng HighMem 2 0 0 1 1 0 ...

Phân mảnh bên ngoài là một vấn đề đối với một số khối lượng công việc và thông tin bạn thân là một
công cụ hữu ích để giúp chẩn đoán những vấn đề này.  Buddyinfo sẽ cung cấp cho bạn một
manh mối về diện tích mà bạn có thể phân bổ một cách an toàn lớn đến mức nào hoặc tại sao
phân bổ không thành công.

Mỗi cột thể hiện số trang của một thứ tự nhất định
có sẵn.  Trong trường hợp này, có 0 khối 2^0*PAGE_SIZE có sẵn trong
ZONE_DMA, 4 khối 2^1*PAGE_SIZE in ZONE_DMA, 101 chunks of 2^4*PAGE_SIZE
có sẵn trong ZONE_NORMAL, v.v...

Thông tin thêm liên quan đến phân mảnh bên ngoài có thể được tìm thấy trong
thông tin loại trang::

> mèo /proc/pagetypeinfo
    Thứ tự khối trang: 9
    Số trang trên mỗi khối: 512

Số trang miễn phí cho mỗi loại di chuyển theo thứ tự 0 1 2 3 4 5 6 7 8 9 10
    Nút 0, vùng DMA, loại Không thể di chuyển 0 0 0 1 1 1 1 1 1 1 0
    Nút 0, vùng DMA, loại Có thể thu hồi lại 0 0 0 0 0 0 0 0 0 0 0
    Nút 0, vùng DMA, loại Di chuyển được 1 1 2 1 2 1 1 0 1 0 2
    Nút 0, vùng DMA, loại Dự trữ 0 0 0 0 0 0 0 0 0 1 0
    Nút 0, vùng DMA, loại Cô lập 0 0 0 0 0 0 0 0 0 0 0
    Nút 0, vùng DMA32, loại Không thể di chuyển 103 54 77 1 1 1 11 8 7 1 9
    Nút 0, vùng DMA32, loại Có thể thu hồi lại 0 0 2 1 0 0 0 0 1 0 0
    Nút 0, vùng DMA32, loại Di chuyển được 169 152 113 91 77 54 39 13 6 1 452
    Nút 0, vùng DMA32, loại Dự trữ 1 2 2 2 2 0 1 1 1 1 0
    Nút 0, vùng DMA32, loại Cô lập 0 0 0 0 0 0 0 0 0 0 0

Số loại khối Không thể di chuyển Có thể thu hồi Có thể di chuyển Dự trữ có thể di chuyển
    Nút 0, vùng DMA 2 0 5 1 0
    Nút 0, vùng DMA32 41 6 967 2 0

Việc tránh phân mảnh trong kernel hoạt động bằng cách nhóm các trang có
di chuyển các loại vào cùng vùng bộ nhớ liền kề được gọi là khối trang.
Khối trang thường có kích thước bằng kích thước trang lớn mặc định, ví dụ: 2 MB trên
X86-64. Bằng cách giữ các trang được nhóm dựa trên khả năng di chuyển của chúng, kernel
có thể lấy lại các trang trong khối trang để đáp ứng phân bổ bậc cao.

Thông tin trang bắt đầu bằng thông tin về kích thước của khối trang. Nó
sau đó cung cấp cùng loại thông tin như bạn thông tin ngoại trừ việc chia nhỏ
bằng loại di chuyển và kết thúc bằng thông tin chi tiết về số lượng khối trang của mỗi loại
loại tồn tại.

Nếu min_free_kbytes đã được điều chỉnh chính xác (đề xuất của Hugeadm
từ libhugetlbfs ZZ0000ZZ người ta có thể
ước tính số lượng trang lớn có thể được phân bổ
tại một thời điểm nhất định Tất cả các khối "Có thể di chuyển" phải được phân bổ
trừ khi bộ nhớ đã bị mlock()'d. Một số khối có thể thu hồi lại sẽ
cũng có thể được phân bổ mặc dù rất nhiều siêu dữ liệu hệ thống tập tin có thể phải được phân bổ
được thu hồi để đạt được điều này.


thông tin cấp phát
~~~~~~~~~

Cung cấp thông tin về phân bổ bộ nhớ ở tất cả các vị trí trong mã
cơ sở. Mỗi phân bổ trong mã được xác định bởi tệp nguồn, dòng
số, mô-đun (nếu bắt nguồn từ mô-đun có thể tải) và lệnh gọi hàm
sự phân bổ. Số lượng byte được phân bổ và số lượng cuộc gọi tại mỗi byte
vị trí được báo cáo. Dòng đầu tiên cho biết phiên bản của tập tin,
dòng thứ hai là các trường liệt kê tiêu đề trong tệp.
Nếu phiên bản tệp là 2.0 hoặc cao hơn thì mỗi dòng có thể chứa thêm
Cặp <key>:<value> thể hiện thông tin bổ sung về trang web cuộc gọi.
Ví dụ: nếu bộ đếm không chính xác, dòng sẽ được thêm vào
cặp "chính xác:không".

Các điểm đánh dấu được hỗ trợ trong v2:
chính xác: không

Giá trị tuyệt đối của bộ đếm ở dòng này không chính xác
              do không phân bổ được bộ nhớ để theo dõi một số
              phân bổ được thực hiện tại vị trí này.  Delta trong các quầy này là
              chính xác, do đó bộ đếm có thể được sử dụng để theo dõi kích thước phân bổ
              và đếm các thay đổi.

Đầu ra ví dụ.

::

> tail -n +3 /proc/allocinfo | sắp xếp -rn
   127664128 31168 mm/page_ext.c:270 func:alloc_page_ext
    56373248 4737 mm/slub.c:2259 func:alloc_slab_page
    14880768 3633 mm/readahead.c:247 func:page_cache_ra_unbounded
    14417920 3520 mm/mm_init.c:2530 func:alloc_large_system_hash
    13377536 234 khối/blk-mq.c:3421 func:blk_mq_alloc_rqs
    11718656 2861 mm/filemap.c:1919 func:__filemap_get_folio
     9192960 2800 kernel/fork.c:307 func:alloc_thread_stack_node
     4206592 4 net/netfilter/nf_conntrack_core.c:2567 func:nf_ct_alloc_hashtable
     4136960 1010 trình điều khiển/dàn dựng/ctagmod/ctagmod.c:20 [ctagmod] func:ctagmod_start
     3940352 962 mm/memory.c:4214 func:alloc_anon_folio
     2894464 22613 fs/kernfs/dir.c:615 func:__kernfs_new_node
     ...


thông tin ghi nhớ
~~~~~~~

Cung cấp thông tin về phân bổ và sử dụng bộ nhớ.  Cái này
thay đổi tùy theo kiến trúc và các tùy chọn biên dịch.  Một số quầy báo cáo
ở đây chồng chéo lên nhau.  Bộ nhớ được báo cáo bởi các bộ đếm không chồng chéo có thể không
thêm vào mức sử dụng bộ nhớ tổng thể và sự khác biệt đối với một số khối lượng công việc
có thể là đáng kể.  Trong nhiều trường hợp có những cách khác để tìm hiểu
bộ nhớ bổ sung bằng cách sử dụng các giao diện cụ thể của hệ thống con, ví dụ
/proc/net/sockstat để phân bổ bộ nhớ TCP.

Đầu ra ví dụ. Bạn có thể không có tất cả các trường này.

::

> mèo /proc/meminfo

Tổng số Mem: 32858820 kB
    MemFree: 21001236 kB
    MemCó sẵn: 27214312 kB
    Bộ đệm: 581092 kB
    Đã lưu vào bộ nhớ đệm: 5587612 kB
    Hoán đổi bộ đệm: 0 kB
    Đang hoạt động: 3237152 kB
    Không hoạt động: 7586256 kB
    Đang hoạt động(anon): 94064 kB
    Không hoạt động(anon): 4570616 kB
    Đang hoạt động (tệp): 3143088 kB
    Không hoạt động(tệp): 3015640 kB
    Không thể tránh khỏi: 0 kB
    Đã khóa: 0 kB
    Tổng số hoán đổi: 0 kB
    Hoán đổi miễn phí: 0 kB
    Trao đổi Z: 1904 kB
    Đã hoán đổi: 7792 kB
    Bẩn: 12 kB
    Ghi lại: 0 kB
    Trang Anon: 4654780 kB
    Đã ánh xạ: 266244 kB
    Shmem: 9976 kB
    KCó thể thu hồi lại: 517708 kB
    Tấm: 660044 kB
    SReclaimable: 517708 kB
    SUKhông được yêu cầu lại: 142336 kB
    KernelStack: 11168 kB
    Bảng trang: 20540 kB
    SecPageTables: 0 kB
    NFS_Không ổn định: 0 kB
    Trả lại: 0 kB
    WritebackTmp: 0 kB
    Giới hạn cam kết: 16429408 kB
    Đã cam kết_AS: 7715148 kB
    VmallocTotal: 34359738367 kB
    VmallocĐã sử dụng: 40444 kB
    VmallocChunk: 0 kB
    Bộ nguồn: 29312 kB
    EarlyMemtestXấu: 0 kB
    Phần cứng bị hỏng: 0 kB
    AnonHugePages: 4149248 kB
    ShmemHugePages: 0 kB
    ShmemPmdĐã ánh xạ: 0 kB
    FileHugePages: 0 kB
    FilePmdMapped: 0 kB
    CmaTotal: 0 kB
    CmaFree: 0 kB
    Không được chấp nhận: 0 kB
    Bong bóng: 0 kB
    GPUHoạt động: 0 kB
    GPUĐòi lại: 0 kB
    HugePages_Total: 0
    HugePages_Free: 0
    HugePages_Rsvd: 0
    HugePages_Surp: 0
    Kích thước trang lớn: 2048 kB
    Hugetlb: 0 kB
    DirectMap4k: 401152 kB
    DirectMap2M: 10008576 kB
    DirectMap1G: 24117248 kB

MemTotal
              Total usable RAM (i.e. physical RAM minus a few reserved
              bits and the kernel binary code)
MemFree
              Total free RAM. On highmem systems, the sum of LowFree+HighFree
MemAvailable
              An estimate of how much memory is available for starting new
              applications, without swapping. Calculated from MemFree,
              SReclaimable, the size of the file LRU lists, and the low
              watermarks in each zone.
              The estimate takes into account that the system needs some
              page cache to function well, and that not all reclaimable
              slab will be reclaimable, due to items being in use. The
              impact of those factors will vary from system to system.
Buffers
              Relatively temporary storage for raw disk blocks
              shouldn't get tremendously large (20MB or so)
Cached
              In-memory cache for files read from the disk (the
              pagecache) as well as tmpfs & shmem.
              Doesn't include SwapCached.
SwapCached
              Memory that once was swapped out, is swapped back in but
              still also is in the swapfile (if memory is needed it
              doesn't need to be swapped out AGAIN because it is already
              in the swapfile. This saves I/O)
Active
              Memory that has been used more recently and usually not
              reclaimed unless absolutely necessary.
Inactive
              Memory which has been less recently used.  It is more
              eligible to be reclaimed for other purposes
Unevictable
              Memory allocated for userspace which cannot be reclaimed, such
              as mlocked pages, ramfs backing pages, secret memfd pages etc.
Mlocked
              Memory locked with mlock().
HighTotal, HighFree
              Highmem is all memory above ~860MB of physical memory.
              Highmem areas are for use by userspace programs, or
              for the pagecache.  The kernel must use tricks to access
              this memory, making it slower to access than lowmem.
LowTotal, LowFree
              Lowmem is memory which can be used for everything that
              highmem can be used for, but it is also available for the
              kernel's use for its own data structures.  Among many
              other things, it is where everything from the Slab is
              allocated.  Bad things happen when you're out of lowmem.
SwapTotal
              total amount of swap space available
SwapFree
              Memory which has been evicted from RAM, and is temporarily
              on the disk
Zswap
              Memory consumed by the zswap backend (compressed size)
Zswapped
              Amount of anonymous memory stored in zswap (original size)
Dirty
              Memory which is waiting to get written back to the disk
Writeback
              Memory which is actively being written back to the disk
AnonPages
              Non-file backed pages mapped into userspace page tables. Note that
              some kernel configurations might consider all pages part of a
              larger allocation (e.g., THP) as "mapped", as soon as a single
              page is mapped.
Mapped
              files which have been mmapped, such as libraries. Note that some
              kernel configurations might consider all pages part of a larger
              allocation (e.g., THP) as "mapped", as soon as a single page is
              mapped.
Shmem
              Total memory used by shared memory (shmem) and tmpfs
KReclaimable
              Kernel allocations that the kernel will attempt to reclaim
              under memory pressure. Includes SReclaimable (below), and other
              direct allocations with a shrinker.
Slab
              in-kernel data structures cache
SReclaimable
              Part of Slab, that might be reclaimed, such as caches
SUnreclaim
              Part of Slab, that cannot be reclaimed on memory pressure
KernelStack
              Memory consumed by the kernel stacks of all tasks
PageTables
              Memory consumed by userspace page tables
SecPageTables
              Memory consumed by secondary page tables, this currently includes
              KVM mmu and IOMMU allocations on x86 and arm64.
NFS_Unstable
              Always zero. Previously counted pages which had been written to
              the server, but has not been committed to stable storage.
Bounce
              Always zero. Previously memory used for block device
              "bounce buffers".
WritebackTmp
              Always zero. Previously memory used by FUSE for temporary
              writeback buffers.
CommitLimit
              Based on the overcommit ratio ('vm.overcommit_ratio'),
              this is the total amount of  memory currently available to
              be allocated on the system. This limit is only adhered to
              if strict overcommit accounting is enabled (mode 2 in
              'vm.overcommit_memory').

CommitLimit được tính theo công thức sau::

CommitLimit = ([tổng số trang RAM] - [tổng số trang TLB lớn]) *
                               overcommit_ratio / 100 + [tổng số trang trao đổi]

Ví dụ: trên hệ thống có 1G RAM vật lý và 7G
              trao đổi với ZZ0000ZZ là 30 thì sẽ
              mang lại CommitLimit là 7,3G.

Để biết thêm chi tiết, hãy xem tài liệu về vượt quá bộ nhớ
              tính bằng mm/overcommit-accounting.
Đã cam kết_AS
              Dung lượng bộ nhớ hiện được phân bổ trên hệ thống.
              Bộ nhớ đã cam kết là tổng của tất cả bộ nhớ được
              đã được phân bổ bởi các tiến trình, ngay cả khi nó chưa được
              vẫn được họ “sử dụng”. Một quá trình có 1G của malloc()
              bộ nhớ, nhưng chỉ chạm vào 300M bộ nhớ sẽ hiển thị dưới dạng
              sử dụng 1G. 1G này là bộ nhớ đã được "cam kết"
              bởi VM và có thể được sử dụng bất cứ lúc nào bằng cách cấp phát
              ứng dụng. Với tính năng vượt mức nghiêm ngặt được kích hoạt trên hệ thống
              (chế độ 2 trong 'vm.overcommit_memory'), phân bổ sẽ
              vượt quá CommitLimit (chi tiết ở trên) sẽ không được phép.
              Điều này rất hữu ích nếu người ta cần đảm bảo rằng các quy trình sẽ
              không bị lỗi do thiếu bộ nhớ một khi bộ nhớ đó đã bị xóa
              được phân bổ thành công.
Tổng số Vmalloc
              tổng kích thước của không gian địa chỉ ảo vmalloc
VmallocĐã sử dụng
              số lượng diện tích vmalloc được sử dụng
VmallocChunk
              khối liền kề lớn nhất của khu vực vmalloc miễn phí
Percpu
              Bộ nhớ được phân bổ cho bộ cấp phát percpu được sử dụng để sao lưu percpu
              phân bổ. Chỉ số này không bao gồm chi phí siêu dữ liệu.
ĐầuMemtestXấu
              Lượng RAM/bộ nhớ tính bằng kB, được xác định là bị hỏng
              bởi memtest sớm. Nếu memtest không được chạy, trường này sẽ không
              đều được hiển thị. Kích thước không bao giờ được làm tròn xuống 0 kB.
              Điều đó có nghĩa là nếu 0 kB được báo cáo, bạn có thể giả định một cách an toàn
              có ít nhất một lượt memtest và không có lượt nào
              đã tìm thấy một byte bị lỗi của RAM.
Phần cứngHỏng
              Lượng RAM/bộ nhớ tính bằng KB, kernel xác định là
              bị hỏng.
AnonTrang lớn
              Các trang lớn không được sao lưu bằng tệp được ánh xạ vào các bảng trang không gian người dùng
ShmemTrang lớn
              Bộ nhớ được sử dụng bởi bộ nhớ dùng chung (shmem) và tmpfs được phân bổ
              với những trang khổng lồ
ShmemPmdĐã ánh xạ
              Bộ nhớ dùng chung được ánh xạ vào không gian người dùng với các trang lớn
TệpLớnTrang
              Bộ nhớ được sử dụng cho dữ liệu hệ thống tập tin (bộ đệm trang) được phân bổ
              với những trang khổng lồ
TệpPmdĐã ánh xạ
              Bộ đệm trang được ánh xạ vào không gian người dùng với các trang lớn
CmaTotal
              Bộ nhớ dành riêng cho Bộ cấp phát bộ nhớ liền kề (CMA)
CmaMiễn phí
              Bộ nhớ còn trống trong kho dự trữ CMA
Không được chấp nhận
              Ký ức chưa được khách chấp nhận
Bóng bay
              Bộ nhớ được VM Balloon Driver trả về Máy chủ
GPUHoạt động
              Bộ nhớ hệ thống được phân bổ cho các đối tượng GPU đang hoạt động
GPUĐòi lại
              Bộ nhớ hệ thống được lưu trữ trong nhóm GPU để tái sử dụng. Ký ức này không
              được tính trong GPUActive. Đó là bộ nhớ có thể thu hồi được, được giữ lại để tái sử dụng
              pool vì nó có các thuộc tính bảng trang không chuẩn, như WC hoặc UC.
HugePages_Total, HugePages_Free, HugePages_Rsvd, HugePages_Surp, Hugepagesize, Hugetlb
              Xem Tài liệu/admin-guide/mm/hugetlbpage.rst.
DirectMap4k, DirectMap2M, DirectMap1G
              Phân tích kích thước bảng trang được sử dụng trong kernel
              ánh xạ nhận dạng của RAM

thông tin vmalloc
~~~~~~~~~~~

Cung cấp thông tin về các khu vực vmalloced/vmaped. Một dòng cho mỗi khu vực,
chứa phạm vi địa chỉ ảo của khu vực, kích thước tính bằng byte,
thông tin người gọi của người tạo và thông tin tùy chọn tùy thuộc vào
về loại diện tích:

===================================================================
 trang=nr số trang
 Phys=addr nếu địa chỉ vật lý được chỉ định
 Ánh xạ I/O ioremap (ioremap() và bạn bè)
 khu vực vmalloc vmalloc()
 trang vmap vmap() ed
 người dùng khu vực VM_USERMAP
 Bộ đệm vpages cho con trỏ trang bị vmalloced (diện tích rất lớn)
 N<node>=nr (Chỉ trên hạt nhân NUMA)
             Số lượng trang được phân bổ trên nút bộ nhớ <node>
 ===================================================================

::

> mèo /proc/vmallocinfo
    0xffffc20000000000-0xffffc20000201000 2101248 alloc_large_system_hash+0x204 ...
    /0x2c0 trang=512 vmalloc N0=128 N1=128 N2=128 N3=128
    0xffffc20000201000-0xffffc20000302000 1052672 alloc_large_system_hash+0x204 ...
    /0x2c0 trang=256 vmalloc N0=64 N1=64 N2=64 N3=64
    0xffffc20000302000-0xffffc20000304000 8192 acpi_tb_verify_table+0x21/0x4f...
    Phys=7fee8000 ioremap
    0xffffc20000304000-0xffffc20000307000 12288 acpi_tb_verify_table+0x21/0x4f...
    Phys=7fee7000 ioremap
    0xffffc2000031d000-0xffffc2000031f000 8192 init_vdso_vars+0x112/0x210
    0xffffc2000031f000-0xffffc2000032b000 49152 cramfs_uncompress_init+0x2e ...
    /0x80 trang=11 vmalloc N0=3 N1=3 N2=2 N3=3
    0xffffc2000033a000-0xffffc2000033d000 12288 sys_swapon+0x640/0xac0 ...
    trang=2 vmalloc N1=2
    0xffffc20000347000-0xffffc2000034c000 20480 xt_alloc_table_info+0xfe ...
    /0x130 [x_tables] pages=4 vmalloc N0=4
    0xffffffffa0000000-0xffffffffa000f000 61440 sys_init_module+0xc27/0x1d00 ...
    trang=14 vmalloc N2=14
    0xffffffffa000f000-0xffffffffa0014000 20480 sys_init_module+0xc27/0x1d00 ...
    trang=4 vmalloc N1=4
    0xffffffffa0014000-0xffffffffa0017000 12288 sys_init_module+0xc27/0x1d00 ...
    trang=2 vmalloc N1=2
    0xffffffffa0017000-0xffffffffa0022000 45056 sys_init_module+0xc27/0x1d00 ...
    trang=10 vmalloc N0=10


phần mềm
~~~~~~~~

Cung cấp số lượng trình xử lý softirq được phục vụ kể từ thời điểm khởi động, cho mỗi CPU.

::

> mèo /proc/softirqs
		  CPU0 CPU1 CPU2 CPU3
	Chào: 0 0 0 0
    TIMER: 27166 27120 27097 27034
    NET_TX: 0 0 0 17
    NET_RX: 42 0 0 39
    BLOCK: 0 0 107 1121
    TASKLET: 0 0 0 290
    SCHED: 27035 26983 26971 26746
    HRTIMER: 0 0 0 0
	RCU: 1678 1769 2178 2250

1.3 Thông tin mạng trong /proc/net
--------------------------------

Thư mục con /proc/net tuân theo mẫu thông thường. Bảng 1-8 cho thấy
các giá trị bổ sung bạn nhận được cho IP phiên bản 6 nếu bạn định cấu hình kernel thành
ủng hộ điều này. Bảng 1-9 liệt kê các tập tin và ý nghĩa của chúng.


.. table:: Table 1-8: IPv6 info in /proc/net

 ========== =====================================================
 File       Content
 ========== =====================================================
 udp6       UDP sockets (IPv6)
 tcp6       TCP sockets (IPv6)
 raw6       Raw device statistics (IPv6)
 igmp6      IP multicast addresses, which this host joined (IPv6)
 if_inet6   List of IPv6 interface addresses
 ipv6_route Kernel routing table for IPv6
 rt6_stats  Global IPv6 routing tables statistics
 sockstat6  Socket statistics (IPv6)
 snmp6      Snmp data (IPv6)
 ========== =====================================================

.. table:: Table 1-9: Network info in /proc/net

 ============= ================================================================
 File          Content
 ============= ================================================================
 arp           Kernel  ARP table
 dev           network devices with statistics
 dev_mcast     the Layer2 multicast groups a device is listening too
               (interface index, label, number of references, number of bound
               addresses).
 dev_stat      network device status
 ip_fwchains   Firewall chain linkage
 ip_fwnames    Firewall chain names
 ip_masq       Directory containing the masquerading tables
 ip_masquerade Major masquerading table
 netstat       Network statistics
 raw           raw device statistics
 route         Kernel routing table
 rpc           Directory containing rpc info
 rt_cache      Routing cache
 snmp          SNMP data
 sockstat      Socket statistics
 softnet_stat  Per-CPU incoming packets queues statistics of online CPUs
 tcp           TCP  sockets
 udp           UDP sockets
 unix          UNIX domain sockets
 wireless      Wireless interface data (Wavelan etc)
 igmp          IP multicast addresses, which this host joined
 psched        Global packet scheduler parameters.
 netlink       List of PF_NETLINK sockets
 ip_mr_vifs    List of multicast virtual interfaces
 ip_mr_cache   List of multicast routing cache
 ============= ================================================================

Bạn có thể sử dụng thông tin này để xem thiết bị mạng nào có sẵn trong
hệ thống của bạn và lưu lượng truy cập được định tuyến qua các thiết bị đó::

> mèo /proc/net/dev
  Liên ZZ0000ZZ[...
   mặt ZZ0001ZZ[...
      lo: 908188 5596 0 0 0 0 0 0 [...
    ppp0:15475140 20721 410 0 0 410 0 0 [...
    eth0: 614530 7085 0 0 0 0 0 1 [...

  ...] Transmit
  ...] bytes    packets errs drop fifo colls carrier compressed
  ...]  908188     5596    0    0    0     0       0          0
  ...] 1375103    17405    0    0    0     0       0          0
  ...] 1703981     5535    0    0    0     3       0          0

Ngoài ra, mỗi giao diện Channel Bond đều có thư mục riêng.  cho
ví dụ: thiết bị bond0 sẽ có thư mục có tên /proc/net/bond0/.
Nó sẽ chứa thông tin cụ thể cho trái phiếu đó, chẳng hạn như
nô lệ hiện tại của liên kết, trạng thái liên kết của các nô lệ và cách thức
nhiều lần liên kết nô lệ đã thất bại.

1.4 Thông tin SCSI
-------------

Nếu bạn có bộ điều hợp máy chủ SCSI hoặc ATA trong hệ thống của mình, bạn sẽ tìm thấy một
thư mục con được đặt tên theo trình điều khiển cho bộ điều hợp này trong /proc/scsi.
Bạn cũng sẽ thấy danh sách tất cả các thiết bị SCSI được nhận dạng trong /proc/scsi::

>mèo /proc/scsi/scsi
  Các thiết bị kèm theo:
  Máy chủ: scsi0 Kênh: 00 Id: 00 Lun: 00
    Nhà cung cấp: IBM Model: DGHS09U Rev: 03E0
    Loại: Truy cập trực tiếp ANSI SCSI Bản sửa đổi: 03
  Máy chủ: scsi0 Kênh: 00 Id: 06 Lun: 00
    Nhà cung cấp: PIONEER Model: CD-ROM DR-U06S Phiên bản: 1.04
    Loại: CD-ROM ANSI SCSI bản sửa đổi: 02


Thư mục được đặt tên theo trình điều khiển có một tệp cho mỗi bộ điều hợp được tìm thấy trong
hệ thống.  Những tập tin này chứa thông tin về bộ điều khiển, bao gồm
IRQ đã sử dụng và dải địa chỉ IO. Lượng thông tin hiển thị là
phụ thuộc vào bộ chuyển đổi bạn sử dụng. Ví dụ hiển thị đầu ra của Adaptec
Bộ chuyển đổi AHA-2940 SCSI::

> mèo /proc/scsi/aic7xxx/0

Phiên bản trình điều khiển Adaptec AIC7xxx: 5.1.19/3.2.4
  Tùy chọn biên dịch:
    TCQ Được bật theo mặc định: Đã tắt
    AIC7XXX_PROC_STATS : Đã tắt
    AIC7XXX_RESET_DELAY : 5
  Cấu hình bộ điều hợp:
             Bộ điều hợp SCSI: Bộ điều hợp máy chủ Adaptec AHA-294X Ultra SCSI
                             Bộ điều khiển siêu rộng
      Cơ sở I/O được MMAPed PCI: 0xeb001000
   Bộ điều hợp SEEPROM Cấu hình: SEEPROM đã tìm thấy và sử dụng.
        Adaptec SCSI BIOS: Đã bật
                      IRQ: 10
                     SCB: Hoạt động 0, Hoạt động tối đa 2,
                           Phân bổ 15, CTNH 16, Trang 255
               Ngắt: 160328
        Từ điều khiển BIOS: 0x18b6
     Từ điều khiển bộ chuyển đổi: 0x005b
     Bản dịch mở rộng: Đã bật
  Ngắt kết nối cờ kích hoạt: 0xffff
       Cờ kích hoạt cực cao: 0x0001
   Cờ kích hoạt hàng đợi thẻ: 0x0000
  Cờ thẻ hàng đợi được đặt hàng: 0x0000
  Độ sâu hàng đợi thẻ mặc định: 8
      Được gắn thẻ Hàng đợi theo thiết bị cho phiên bản máy chủ aic7xxx 0:
        {255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255}
      Độ sâu hàng đợi thực tế trên mỗi thiết bị cho phiên bản máy chủ aic7xxx 0:
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  Thống kê:
  (scsi0:0:0:0)
    Thiết bị sử dụng truyền dữ liệu Wide/Sync ở tốc độ 40,0 MByte/giây, offset 8
    Cài đặt thông tin chuyển đổi: hiện tại (12/8/1/0), mục tiêu (12/8/1/0), người dùng (15/12/1/0)
    Tổng số lần chuyển 160151 (74577 lần đọc và 85574 lần ghi)
  (scsi0:0:6:0)
    Thiết bị sử dụng truyền Thu hẹp/Đồng bộ hóa ở tốc độ 5,0 MByte/giây, độ lệch 15
    Cài đặt chuyển đổi thông tin: hiện tại (50/15/0/0), mục tiêu (50/15/0/0), người dùng (50/15/0/0)
    Tổng số lần chuyển 0 (0 lần đọc và 0 lần ghi)


1.5 Thông tin cổng song song trong /proc/parport
---------------------------------------

Thư mục /proc/parport chứa thông tin về các cổng song song của
hệ thống của bạn.  Nó có một thư mục con cho mỗi cổng, được đặt tên theo cổng
số (0,1,2,...).

Những thư mục này chứa bốn tệp được hiển thị trong Bảng 1-10.


.. table:: Table 1-10: Files in /proc/parport

 ========= ====================================================================
 File      Content
 ========= ====================================================================
 autoprobe Any IEEE-1284 device ID information that has been acquired.
 devices   list of the device drivers using that port. A + will appear by the
           name of the device currently using the port (it might not appear
           against any).
 hardware  Parallel port's base address, IRQ line and DMA channel.
 irq       IRQ that parport is using for that port. This is in a separate
           file to allow you to alter it by writing a new value in (IRQ
           number or none).
 ========= ====================================================================

1.6 Thông tin TTY trong /proc/tty
-------------------------

Thông tin về các tty có sẵn và thực sự được sử dụng có thể được tìm thấy trong
thư mục /proc/tty. Bạn sẽ tìm thấy các mục dành cho người lái xe và kỷ luật đường trong
thư mục này, như thể hiện trong Bảng 1-11.


.. table:: Table 1-11: Files in /proc/tty

 ============= ==============================================
 File          Content
 ============= ==============================================
 drivers       list of drivers and their usage
 ldiscs        registered line disciplines
 driver/serial usage statistic and status of single tty lines
 ============= ==============================================

Để xem tty nào hiện đang được sử dụng, bạn chỉ cần nhìn vào tệp
/proc/tty/drivers::

> mèo /proc/tty/drivers
  pty_slave /dev/pts 136 0-255 pty:slave
  pty_master /dev/ptm 128 0-255 pty:master
  pty_slave/dev/ttyp 3 0-255 pty:nô lệ
  pty_master/dev/pty 2 0-255 pty:master
  serial /dev/cua 5 64-67 serial: chú thích
  nối tiếp/dev/ttyS 4 64-67 nối tiếp
  /dev/tty0 /dev/tty0 4 0 hệ thống:vtmaster
  /dev/ptmx/dev/ptmx 5 2 hệ thống
  /dev/console /dev/console 5 1 hệ thống:console
  /dev/tty /dev/tty 5 0 hệ thống:/dev/tty
  bảng điều khiển không xác định/dev/tty 4 1-63


1.7 Thống kê hạt nhân khác trong /proc/stat
-------------------------------------------------

Nhiều thông tin khác nhau về hoạt động của hạt nhân có sẵn trong
tập tin /proc/stat.  Tất cả các số được báo cáo trong tệp này là tổng hợp
kể từ khi hệ thống khởi động lần đầu tiên.  Để xem nhanh, chỉ cần gửi tệp::

> mèo /proc/stat
  CPU 237902850 368826709 106375398 1873517540 1135548 0 14507935 0 0 0
  cpu0 60045249 91891769 26331539 468411416 495718 0 5739640 0 0 0
  cpu1 59746288 91759249 26609887 468860630 312281 0 4384817 0 0 0
  cpu2 59489247 92985423 26904446 467808813 171668 0 2268998 0 0 0
  cpu3 58622065 92190267 26529524 468436680 155879 0 2114478 0 0 0
  intr 8688370575 8 3373 0 0 0 0 0 0 1 40791 0 0 353317 0 0 0 0 224789828 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 190974333 41958554 123983334 43 0 224593 0 0 0 <thêm 0 đã bị xóa>
  ctxt 22848221062
  btime 1605316999
  quy trình 746787147
  procs_running 2
  procs_blocked 0
  phần mềm 12121874454 100099120 3938138295 127375644 2795979 187870761 0 173808342 3072582055 52608 224184354

Dòng "cpu" đầu tiên tổng hợp các số trong tất cả các "cpuN" khác
dòng.  Những con số này xác định lượng thời gian CPU đã dành để thực hiện
các loại công việc khác nhau.  Đơn vị thời gian ở USER_HZ (thường là một phần trăm của một
thứ hai).  Ý nghĩa các cột như sau, từ trái qua phải:

- người dùng: các tiến trình bình thường thực thi ở chế độ người dùng
- nice: các tiến trình được xử lý tốt đẹp đang thực thi ở chế độ người dùng
- hệ thống: các tiến trình thực thi ở chế độ kernel
- nhàn rỗi: vặn ngón tay cái
- iowait: Nói một cách dễ hiểu, iowait là viết tắt của việc chờ I/O hoàn thành. Nhưng ở đó
  có một số vấn đề:

1. CPU sẽ không đợi I/O hoàn thành, iowait là thời gian thực hiện một tác vụ
     đang chờ I/O hoàn tất. Khi CPU chuyển sang trạng thái không hoạt động trong
     nhiệm vụ I/O chưa hoàn thành, một nhiệm vụ khác sẽ được lên lịch trên CPU này.
  2. Trong CPU đa lõi, tác vụ chờ I/O hoàn thành không chạy
     trên bất kỳ CPU nào, vì vậy iowait của mỗi CPU rất khó tính toán.
  3. Giá trị của trường iowait trong /proc/stat sẽ giảm trong một số trường hợp nhất định
     điều kiện.

Vì vậy, iowait không đáng tin cậy khi đọc từ/proc/stat.
- irq: ngắt dịch vụ
- softirq: phục vụ softirqs
- trộm: vô tình chờ đợi
- guest: chạy client bình thường
- guest_nice: điều hành một vị khách tốt bụng

Dòng "intr" cung cấp số lần ngắt được phục vụ kể từ thời điểm khởi động, cho mỗi lần ngắt.
về các ngắt hệ thống có thể xảy ra.   Cột đầu tiên là tổng số
các ngắt được phục vụ bao gồm các ngắt cụ thể về kiến trúc không được đánh số;
mỗi cột tiếp theo là tổng số của ngắt được đánh số cụ thể đó.
Các ngắt không được đánh số không được hiển thị, chỉ được tính tổng thành tổng.

Dòng "ctxt" cung cấp tổng số lần chuyển ngữ cảnh trên tất cả các CPU.

Dòng "btime" cho biết thời gian hệ thống khởi động, tính bằng giây kể từ khi
kỷ nguyên Unix.

Dòng "process" cho biết số lượng tiến trình và luồng được tạo, trong đó
bao gồm (nhưng không giới hạn) những thứ được tạo bởi các lệnh gọi tới fork() và
cuộc gọi hệ thống clone().

Dòng "procs_running" cung cấp tổng số luồng được
đang chạy hoặc sẵn sàng chạy (tức là tổng số luồng có thể chạy được).

Dòng "procs_blocked" cho biết số lượng tiến trình hiện bị chặn,
đang chờ I/O hoàn tất.

Dòng "softirq" cung cấp số lượng softirq được phục vụ kể từ thời điểm khởi động, cho mỗi
của các phần mềm hệ thống có thể có. Cột đầu tiên là tổng số
phần mềm phục vụ; mỗi cột tiếp theo là tổng của cột đó
softirq.


1.8 Tham số hệ thống tệp Ext4
-------------------------------

Thông tin về hệ thống tập tin ext4 được gắn có thể được tìm thấy trong
/proc/fs/ext4.  Mỗi hệ thống tập tin được gắn sẽ có một thư mục trong
/proc/fs/ext4 dựa trên tên thiết bị của nó (tức là /proc/fs/ext4/hdc hoặc
/proc/fs/ext4/sda9 hoặc /proc/fs/ext4/dm-0).   Các tập tin trong mỗi thiết bị
thư mục được hiển thị trong Bảng 1-12 bên dưới.

.. table:: Table 1-12: Files in /proc/fs/ext4/<devname>

 ==============  ==========================================================
 File            Content
 mb_groups       details of multiblock allocator buddy cache of free blocks
 ==============  ==========================================================

1.9 /proc/bảng điều khiển
-------------------
Hiển thị các dòng bảng điều khiển hệ thống đã đăng ký.

Để xem dòng thiết bị ký tự nào hiện đang được sử dụng cho bảng điều khiển hệ thống
/dev/console, bạn có thể chỉ cần xem xét tệp /proc/consoles::

> mèo /proc/bàn điều khiển
  tty0 -WU (ECp) 4:7
  ttyS0 -W- (Tập) 4:64

Các cột là:

+-------------------++-------------------------------------------------------+
ZZ0000ZZ tên thiết bị |
+=====================================================================================================================
ZZ0001ZZ * R = có thể thực hiện các thao tác đọc |
ZZ0002ZZ * W = có thể thực hiện thao tác ghi |
ZZ0003ZZ * U = có thể bỏ trống |
+-------------------++-------------------------------------------------------+
ZZ0004ZZ * E = nó được kích hoạt |
ZZ0005ZZ * C = nó là bảng điều khiển ưa thích |
ZZ0006ZZ * B = đây là bảng điều khiển khởi động chính |
ZZ0007ZZ * p = nó được sử dụng cho bộ đệm printk |
ZZ0008ZZ * b = nó không phải là TTY mà là một thiết bị chữ nổi |
ZZ0009ZZ * a = sử dụng an toàn khi cpu ngoại tuyến |
+-------------------++-------------------------------------------------------+
ZZ0010ZZ số chính và số phụ của thiết bị được phân tách bằng dấu |
ZZ0011ZZ dấu hai chấm |
+-------------------++-------------------------------------------------------+

Bản tóm tắt
-------

Hệ thống tập tin /proc cung cấp thông tin về hệ thống đang chạy. Nó không chỉ
cho phép truy cập vào xử lý dữ liệu nhưng cũng cho phép bạn yêu cầu trạng thái kernel
bằng cách đọc các tập tin trong hệ thống phân cấp.

Cấu trúc thư mục của /proc phản ánh các loại thông tin và tạo nên
thật dễ dàng, nếu không rõ ràng, nơi để tìm dữ liệu cụ thể.

Chương 2: Sửa đổi tham số hệ thống
======================================

Trong chương này
---------------

* Sửa đổi các tham số kernel bằng cách ghi vào các tệp được tìm thấy trong /proc/sys
* Khám phá các tập tin sửa đổi các tham số nhất định
* Xem lại cây tập tin /proc/sys

------------------------------------------------------------------------------

Một phần rất thú vị của /proc là thư mục /proc/sys. Đây không chỉ là
một nguồn thông tin, nó cũng cho phép bạn thay đổi các tham số trong
hạt nhân. Hãy thật cẩn thận khi thử điều này. Bạn có thể tối ưu hóa hệ thống của mình,
nhưng bạn cũng có thể khiến nó bị hỏng.  Không bao giờ thay đổi các tham số kernel trên một
hệ thống sản xuất.  Thiết lập một máy phát triển và kiểm tra để đảm bảo rằng
mọi thứ đều hoạt động theo cách bạn muốn. Bạn có thể không có lựa chọn nào khác ngoài việc
khởi động lại máy khi xảy ra lỗi.

Để thay đổi một giá trị, chỉ cần lặp lại giá trị mới vào tệp.
Bạn cần phải root để làm điều này. Bạn có thể tạo tập lệnh khởi động của riêng mình
để thực hiện việc này mỗi khi hệ thống của bạn khởi động.

Các tập tin trong /proc/sys có thể được sử dụng để tinh chỉnh và giám sát các hoạt động linh tinh và
những điều chung trong hoạt động của nhân Linux. Vì một số tập tin
có thể vô tình làm gián đoạn hệ thống của bạn, bạn nên đọc cả hai
tài liệu và nguồn trước khi thực sự điều chỉnh. Trong mọi trường hợp, hãy
rất cẩn thận khi ghi vào bất kỳ tập tin nào trong số này. Các mục trong /proc có thể
thay đổi một chút giữa hạt nhân 2.1.* và hạt nhân 2.2, vì vậy nếu có bất kỳ nghi ngờ nào
xem lại tài liệu kernel trong thư mục linux/Documentation.
Chương này chủ yếu dựa vào tài liệu có trong phiên bản 2.2 trước
hạt nhân và trở thành một phần của nó trong phiên bản 2.2.1 của hạt nhân Linux.

Vui lòng xem: Thư mục Documentation/admin-guide/sysctl/ để biết mô tả về
những mục này.

Bản tóm tắt
-------

Một số khía cạnh nhất định của hành vi kernel có thể được sửa đổi trong thời gian chạy mà không cần
cần phải biên dịch lại kernel hoặc thậm chí khởi động lại hệ thống. Các tập tin trong
Cây /proc/sys không chỉ có thể đọc mà còn có thể sửa đổi. Bạn có thể sử dụng tiếng vang
lệnh ghi giá trị vào các tệp này, từ đó thay đổi cài đặt mặc định
của hạt nhân.


Chương 3: Tham số trên mỗi quy trình
=================================

3.1 /proc/<pid>/oom_adj & /proc/<pid>/oom_score_adj- Điều chỉnh điểm oom-killer
--------------------------------------------------------------------------------

Những tập tin này có thể được sử dụng để điều chỉnh heuristic xấu được sử dụng để chọn cái nào
quá trình bị hủy trong điều kiện hết bộ nhớ (oom).

Heuristic xấu chỉ định một giá trị cho mỗi nhiệm vụ ứng cử viên trong khoảng từ 0
(không bao giờ giết) đến 1000 (luôn luôn giết) để xác định quá trình nào được nhắm mục tiêu.  các
đơn vị gần như là một tỷ lệ dọc theo phạm vi bộ nhớ được phép đó
có thể phân bổ dựa trên ước tính về việc sử dụng bộ nhớ hiện tại và trao đổi.
Ví dụ: nếu một tác vụ đang sử dụng hết bộ nhớ cho phép thì điểm xấu của tác vụ đó sẽ là
1000. Nếu nó đang sử dụng một nửa bộ nhớ cho phép thì điểm của nó sẽ là 500.

Lượng bộ nhớ "được phép" phụ thuộc vào bối cảnh mà kẻ giết người oom
đã được gọi.  Nếu là do bộ nhớ được gán cho cpuset của tác vụ cấp phát
cạn kiệt, bộ nhớ được phép biểu thị tập hợp các mem được gán cho bộ nhớ đó
cpuset.  Nếu đó là do (các) nút của mempolicy đã cạn kiệt, thì giá trị được phép
bộ nhớ đại diện cho tập hợp các nút mempolicy.  Nếu là do trí nhớ
đạt đến giới hạn (hoặc giới hạn trao đổi), bộ nhớ được phép được cấu hình
giới hạn.  Cuối cùng, nếu do toàn bộ hệ thống hết bộ nhớ,
bộ nhớ được phép đại diện cho tất cả các tài nguyên có thể phân bổ.

Giá trị của /proc/<pid>/oom_score_adj được thêm vào điểm xấu trước nó
được sử dụng để xác định nhiệm vụ nào cần loại bỏ.  Giá trị được chấp nhận nằm trong khoảng từ -1000
(OOM_SCORE_ADJ_MIN) đến +1000 (OOM_SCORE_ADJ_MAX).  Điều này cho phép không gian người dùng
phân cực sở thích giết oom bằng cách luôn ưu tiên một mục tiêu nhất định
nhiệm vụ hoặc vô hiệu hóa hoàn toàn nó.  Giá trị thấp nhất có thể, -1000, là
tương đương với việc vô hiệu hóa hoàn toàn tính năng tiêu diệt oom cho nhiệm vụ đó vì nó sẽ luôn
báo cáo điểm xấu là 0.

Do đó, không gian người dùng rất đơn giản để xác định dung lượng bộ nhớ cần
xem xét từng nhiệm vụ.  Đặt giá trị /proc/<pid>/oom_score_adj là +500 cho
Ví dụ, gần tương đương với việc cho phép phần còn lại của nhiệm vụ chia sẻ
cùng một tài nguyên hệ thống, cpuset, mempolicy hoặc bộ điều khiển bộ nhớ để sử dụng ít nhất
Bộ nhớ nhiều hơn 50%.  Mặt khác, giá trị -500 sẽ gần như
tương đương với việc giảm 50% bộ nhớ cho phép của tác vụ khỏi bị xem xét
như ghi điểm vào nhiệm vụ.

Để tương thích ngược với các hạt nhân trước đó, /proc/<pid>/oom_adj cũng có thể
được sử dụng để điều chỉnh điểm xấu.  Giá trị chấp nhận được của nó nằm trong khoảng từ -16
(OOM_ADJUST_MIN) đến +15 (OOM_ADJUST_MAX) và giá trị đặc biệt là -17
(OOM_DISABLE) để tắt hoàn toàn tính năng tiêu diệt oom cho tác vụ đó.  Giá trị của nó là
được chia tỷ lệ tuyến tính với /proc/<pid>/oom_score_adj.

Giá trị của /proc/<pid>/oom_score_adj có thể giảm không thấp hơn giá trị cuối cùng
giá trị được đặt bởi quy trình CAP_SYS_RESOURCE. Để giảm giá trị xuống thấp hơn
yêu cầu CAP_SYS_RESOURCE.


3.2 /proc/<pid>/oom_score - Hiển thị điểm oom-killer hiện tại
-------------------------------------------------------------

Tập tin này có thể được sử dụng để kiểm tra điểm hiện tại được sử dụng bởi oom-killer cho
bất kỳ <pid> nào đã cho. Sử dụng nó cùng với /proc/<pid>/oom_score_adj để điều chỉnh
quá trình sẽ bị hủy trong tình huống hết bộ nhớ.

Xin lưu ý rằng giá trị được xuất bao gồm oom_score_adj nên nó là
hiệu quả trong phạm vi [0,2000].


3.3 /proc/<pid>/io - Hiển thị các trường kế toán IO
-------------------------------------------------------

Tệp này chứa số liệu thống kê IO cho mỗi tiến trình đang chạy.

Ví dụ
~~~~~~~

::

test:/tmp # dd if=/dev/zero of=/tmp/test.dat &
    [1] 3828

kiểm tra:/tmp # cat/proc/3828/io
    rchar: 323934931
    wchar: 323929600
    syscr: 632687
    syscw: 632675
    read_byte: 0
    write_byte: 323932160
    hủy_write_bytes: 0


Sự miêu tả
~~~~~~~~~~~

rchar
^^^^^

Bộ đếm I/O: đọc ký tự
Số byte mà tác vụ này đã khiến được đọc từ bộ lưu trữ. Cái này
chỉ đơn giản là tổng số byte mà quá trình này chuyển tới read() và pread().
Nó bao gồm những thứ như tty IO và nó không bị ảnh hưởng bởi việc có thực tế hay không
IO đĩa vật lý được yêu cầu (việc đọc có thể đã được thỏa mãn từ
bộ đệm trang).


wchar
^^^^^

Bộ đếm I/O: ký tự được viết
Số byte mà tác vụ này đã tạo ra hoặc sẽ được ghi
vào đĩa. Hãy cẩn thận tương tự áp dụng ở đây như với rchar.


syscr
^^^^^

Bộ đếm I/O: đọc syscalls
Cố gắng đếm số lượng thao tác I/O đã đọc, tức là các cuộc gọi tổng hợp như read()
và preread().


syscw
^^^^^

Bộ đếm I/O: ghi các cuộc gọi hệ thống
Cố gắng đếm số lượng thao tác ghi I/O, tức là các cuộc gọi tổng hợp như
viết() và pwrite().


read_byte
^^^^^^^^^^

Bộ đếm I/O: đọc byte
Cố gắng đếm số byte mà quá trình này thực sự đã gây ra
được lấy từ lớp lưu trữ. Hoàn thành ở cấp submit_bio(), vậy là xong
chính xác cho các hệ thống tập tin được hỗ trợ theo khối. <vui lòng thêm trạng thái liên quan đến NFS và
CIFS sau này>


ghi_byte
^^^^^^^^^^^

Bộ đếm I/O: byte được ghi
Cố gắng đếm số byte mà quá trình này đã gửi tới
lớp lưu trữ. Việc này được thực hiện tại thời điểm làm bẩn trang.


đã hủy_write_byte
^^^^^^^^^^^^^^^^^^^^^

Sự thiếu chính xác lớn ở đây là cắt ngắn. Nếu một tiến trình ghi 1 MB vào một tập tin và
sau đó xóa tập tin, trên thực tế nó sẽ không ghi dữ liệu. Nhưng nó sẽ có
được tính là đã gây ra 1 MB ghi.
Nói cách khác: Số byte mà quá trình này khiến cho không xảy ra,
bằng cách cắt bớt bộ đệm trang. Một tác vụ cũng có thể gây ra IO "âm". Nếu nhiệm vụ này
cắt bớt một số bộ đệm trang bẩn, một số IO mà một tác vụ khác đã được giải quyết
for (trong write_bytes) sẽ không xảy ra. Chúng ta _có thể_ chỉ cần trừ đi điều đó
khỏi write_bytes của tác vụ cắt ngắn, nhưng sẽ bị mất thông tin khi thực hiện
đó.


.. Note::

   At its current implementation state, this is a bit racy on 32-bit machines:
   if process A reads process B's /proc/pid/io while process B is updating one
   of those 64-bit counters, process A could see an intermediate result.


Thông tin thêm về điều này có thể được tìm thấy trong tài liệu taskstats trong
Tài liệu/kế toán.

3.4 /proc/<pid>/coredump_filter - Cài đặt lọc kết xuất lõi
---------------------------------------------------------------
Khi một tiến trình bị kết xuất, tất cả bộ nhớ ẩn danh sẽ được ghi vào tệp lõi dưới dạng
miễn là kích thước của tệp lõi không bị giới hạn. Nhưng đôi khi chúng ta không muốn
để kết xuất một số phân đoạn bộ nhớ, ví dụ: bộ nhớ dùng chung lớn hoặc DAX.
Ngược lại, đôi khi chúng ta muốn lưu các phân đoạn bộ nhớ dựa trên tệp vào lõi
tập tin, không chỉ các tập tin riêng lẻ.

/proc/<pid>/coredump_filter cho phép bạn tùy chỉnh các phân đoạn bộ nhớ
sẽ bị hủy bỏ khi quá trình <pid> bị hủy bỏ. coredump_filter là một mặt nạ bit
của các loại bộ nhớ. Nếu một bit của mặt nạ bit được đặt, các phân đoạn bộ nhớ của
loại bộ nhớ tương ứng sẽ bị kết xuất, nếu không thì chúng sẽ không bị kết xuất.

9 loại bộ nhớ sau được hỗ trợ:

- (bit 0) bộ nhớ riêng ẩn danh
  - (bit 1) bộ nhớ chia sẻ ẩn danh
  - (bit 2) bộ nhớ riêng được hỗ trợ bằng tệp
  - (bit 3) bộ nhớ chia sẻ được hỗ trợ bằng tệp
  - (bit 4) Các trang tiêu đề ELF trong các vùng bộ nhớ riêng được sao lưu bằng tệp (đó là
    chỉ có hiệu lực nếu bit 2 bị xóa)
  - (bit 5) bộ nhớ riêng lớn
  - (bit 6) bộ nhớ chia sẻ Hugetlb
  - (bit 7) Bộ nhớ riêng DAX
  - (bit 8) Bộ nhớ chia sẻ DAX

Lưu ý rằng các trang MMIO như bộ đệm khung không bao giờ bị kết xuất và các trang vDSO
  luôn bị loại bỏ bất kể trạng thái bitmask.

Lưu ý rằng các bit 0-4 không ảnh hưởng đến bộ nhớ Hugetlb hoặc DAX. bộ nhớ lớn là
  chỉ bị ảnh hưởng bởi bit 5-6 và DAX chỉ bị ảnh hưởng bởi bit 7-8.

Giá trị mặc định của coredump_filter là 0x33; điều này có nghĩa là tất cả bộ nhớ ẩn danh
phân đoạn, trang tiêu đề ELF và bộ nhớ riêng Hugetlb bị kết xuất.

Nếu bạn không muốn kết xuất tất cả các phân đoạn bộ nhớ dùng chung được gắn vào pid 1234,
ghi 0x31 vào tệp Proc của tiến trình::

$ echo 0x31 > /proc/1234/coredump_filter

Khi một tiến trình mới được tạo, tiến trình đó sẽ kế thừa trạng thái mặt nạ bit từ nó.
cha mẹ. Sẽ rất hữu ích nếu thiết lập coredump_filter trước khi chương trình chạy.
Ví dụ::

$ echo 0x7 > /proc/self/coredump_filter
  $ ./some_program

3.5 /proc/<pid>/mountinfo - Thông tin về thú cưỡi
--------------------------------------------------------

Tệp này chứa các dòng có dạng::

36 35 98:0 /mnt1 /mnt2 rw,noatime master:1 - ext3 /dev/root rw,errors=continue
    (1)(2)(3) (4) (5) (6) (n…m) (m+1)(m+2) (m+3) (m+4)

(1) ID gắn kết: mã định danh duy nhất của gắn kết (có thể được sử dụng lại sau umount)
    (2) ID gốc: ID của cha mẹ (hoặc của chính nó đối với đỉnh cây gắn kết)
    (3) Major:minor: giá trị của st_dev cho các tập tin trên hệ thống tập tin
    (4) root: root của mount trong hệ thống tập tin
    (5) điểm gắn kết: điểm gắn kết tương ứng với gốc của tiến trình
    (6) tùy chọn gắn kết: mỗi tùy chọn gắn kết
    (n…m) trường tùy chọn: không hoặc nhiều trường có dạng "tag[:value]"
    (m+1) dấu phân cách: đánh dấu sự kết thúc của các trường tùy chọn
    (m+2) loại hệ thống tập tin: tên hệ thống tập tin có dạng "type[.subtype]"
    (m+3) nguồn gắn kết: thông tin cụ thể về hệ thống tập tin hoặc "không có"
    (m+4) siêu tùy chọn: mỗi tùy chọn siêu khối

Trình phân tích cú pháp nên bỏ qua tất cả các trường tùy chọn không được nhận dạng.  Hiện nay
các trường tùy chọn có thể là:

=====================================================================================
đã chia sẻ:X mount được chia sẻ trong nhóm ngang hàng X
master:X mount là nô lệ cho nhóm ngang hàng X
tuyên truyền_from:X mount là nô lệ và nhận được sự lan truyền từ nhóm ngang hàng X [#]_
gắn kết không thể liên kết là không thể liên kết
=====================================================================================

.. [#] X is the closest dominant peer group under the process's root.  If
       X is the immediate master of the mount, or if there's no dominant peer
       group under the same root, then only the "master:X" field is present
       and not the "propagate_from:X" field.

Để biết thêm thông tin về truyền lan gắn kết, hãy xem:

Tài liệu/hệ thống tập tin/sharedsubtree.rst


3.6 /proc/<pid>/comm & /proc/<pid>/task/<tid>/comm
--------------------------------------------------------
Các tệp này cung cấp một phương thức để truy cập giá trị comm của tác vụ. Nó cũng cho phép
một nhiệm vụ để đặt giá trị comm của riêng nó hoặc một trong các giá trị comm của chủ đề anh chị em của nó. Giá trị liên lạc
bị giới hạn về kích thước so với giá trị cmdline, vì vậy việc viết bất cứ điều gì dài hơn
sau đó là TASK_COMM_LEN của kernel (hiện có 16 ký tự, bao gồm NUL
terminator) sẽ dẫn đến giá trị comm bị cắt ngắn.


3.7 /proc/<pid>/task/<tid>/children - Thông tin về nhiệm vụ con
-------------------------------------------------------------------------
Tệp này cung cấp một cách nhanh chóng để truy xuất các pid cấp độ con đầu tiên
của một nhiệm vụ được chỉ định bởi cặp <pid>/<tid>. Định dạng được phân tách bằng dấu cách
dòng pid.

Hãy lưu ý "cấp độ đầu tiên" ở đây -- nếu một đứa trẻ có con riêng thì chúng sẽ
không được liệt kê ở đây; người ta cần đọc /proc/<children-pid>/task/<tid>/children
để có được con cháu.

Vì giao diện này nhằm mục đích nhanh và rẻ nên nó không
đảm bảo cung cấp kết quả chính xác và một số trẻ em có thể
bị bỏ qua, đặc biệt nếu họ thoát ngay sau khi chúng tôi in
pids, vì vậy người ta cần dừng hoặc đóng băng các quy trình đang được kiểm tra
nếu cần kết quả chính xác.


3.8 /proc/<pid>/fdinfo/<fd> - Thông tin về tệp đã mở
---------------------------------------------------------------
Tệp này cung cấp thông tin liên quan đến một tệp đã mở. thường xuyên
các tệp có ít nhất bốn trường -- 'pos', 'flags', 'mnt_id' và 'ino'.
'pos' biểu thị phần bù hiện tại của tệp đã mở ở dạng thập phân
dạng [xem lseek(2) để biết chi tiết], 'cờ' biểu thị mặt nạ bát phân O_xxx
tệp đã được tạo bằng [xem open(2) để biết chi tiết] và 'mnt_id' đại diện
ID gắn kết của hệ thống tệp chứa tệp đã mở [xem 3.5
/proc/<pid>/mountinfo để biết chi tiết]. 'ino' đại diện cho số inode của
tập tin.

Một đầu ra điển hình là::

vị trí: 0
	cờ: 0100002
	mnt_id: 19
	vào: 63107

Tất cả các khóa được liên kết với bộ mô tả tệp cũng được hiển thị trong fdinfo của nó::

khóa: 1: FLOCK ADVISORY WRITE 359 00:13:11691 0 EOF

Các tập tin như eventfd, fsnotify, signalfd, epoll trong số các pos/flags thông thường
cặp cung cấp thông tin bổ sung cụ thể cho các đối tượng mà chúng đại diện.

tập tin sự kiện
~~~~~~~~~~~~~

::

vị trí: 0
	cờ: 04002
	mnt_id: 9
	vào: 63107
	số sự kiệnfd: 5a

trong đó 'eventfd-count' là giá trị hex của bộ đếm.

tập tin tín hiệu
~~~~~~~~~~~~~~

::

vị trí: 0
	cờ: 04002
	mnt_id: 9
	vào: 63107
	dấu hiệu: 0000000000000200

trong đó 'sigmask' là giá trị hex của mặt nạ tín hiệu được liên kết
với một tập tin.

Tệp Epoll
~~~~~~~~~~~

::

vị trí: 0
	cờ: 02
	mnt_id: 9
	vào: 63107
	tfd: 5 sự kiện: Dữ liệu 1d: ffffffffffffffff pos:0 ino:61af sdev:7

trong đó 'tfd' là số mô tả tệp đích ở dạng thập phân,
'sự kiện' là mặt nạ sự kiện đang được theo dõi và 'dữ liệu' là dữ liệu
được liên kết với mục tiêu [xem epoll(7) để biết thêm chi tiết].

'pos' là phần bù hiện tại của tệp mục tiêu ở dạng thập phân
[xem lseek(2)], 'ino' và 'sdev' là số inode và số thiết bị
nơi chứa tệp mục tiêu, tất cả đều ở định dạng hex.

tập tin thông báo
~~~~~~~~~~~~~~
Đối với các tệp inotify, định dạng như sau ::

vị trí: 0
	cờ: 02000000
	mnt_id: 9
	vào: 63107
	inotify wd:3 ino:9e7e sdev:800013 mặt nạ:800afce bị bỏ qua_mask:0 fhandle-byte:8 fhandle-type:1 f_handle:7e9e0000640d1b6d

trong đó 'wd' là bộ mô tả đồng hồ ở dạng thập phân, tức là tệp đích
số mô tả, 'ino' và 'sdev' là inode và thiết bị nơi
tệp mục tiêu nằm trong đó và 'mặt nạ' là mặt nạ của các sự kiện, tất cả đều ở dạng hex
biểu mẫu [xem inotify(7) để biết thêm chi tiết].

Nếu hạt nhân được xây dựng với sự hỗ trợ xuất khẩu, đường dẫn đến đích
tập tin được mã hóa dưới dạng xử lý tập tin.  Việc xử lý tập tin được cung cấp bởi ba
các trường 'fhandle-byte', 'fhandle-type' và 'f_handle', tất cả đều ở dạng hex
định dạng.

Nếu hạt nhân được xây dựng mà không có hỗ trợ xuất khẩu thì việc xử lý tệp sẽ không được thực hiện
được in ra.

Nếu không có dấu inotify đính kèm thì dòng 'inotify' sẽ bị bỏ qua.

Đối với các tệp fanotify, định dạng là::

vị trí: 0
	cờ: 02
	mnt_id: 9
	vào: 63107
	cờ fanotify:10 cờ sự kiện:0
	fanotify mnt_id:12 mflags:40 mặt nạ:38 bị bỏ qua_mask:40000003
	fanotify ino:4f969 sdev:800013 mflags:0 mặt nạ:3b bị bỏ qua_mask:40000000 fhandle-byte:8 fhandle-type:1 f_handle:69f90400c275b5b4

trong đó fanotify 'flag' và 'event-flag' là các giá trị được sử dụng trong fanotify_init
gọi, 'mnt_id' là mã định danh điểm gắn kết, 'mflags' là giá trị của
cờ liên quan đến nhãn hiệu được theo dõi riêng biệt với các sự kiện
mặt nạ. 'ino' và 'sdev' là inode và thiết bị đích, 'mặt nạ' là sự kiện
mặt nạ và 'ignored_mask' là mặt nạ của các sự kiện cần bỏ qua.
Tất cả đều ở định dạng hex. Kết hợp 'mflags', 'mask' và 'ignored_mask'
cung cấp thông tin về cờ và mặt nạ được sử dụng trong fanotify_mark
hãy gọi [xem trang chủ fsnotify để biết chi tiết].

Mặc dù ba dòng đầu tiên là bắt buộc và luôn được in, các dòng còn lại là
tùy chọn và có thể được bỏ qua nếu chưa có điểm nào được tạo.

tập tin hẹn giờ
~~~~~~~~~~~~~

::

vị trí: 0
	cờ: 02
	mnt_id: 9
	vào: 63107
	đồng hồ: 0
	tích tắc: 0
	cờ thời gian thiết lập: 01
	it_value: (0, 49406829)
	it_interval: (1, 0)

trong đó 'clockid' là loại đồng hồ và 'tick' là số lần hết hạn của bộ đếm thời gian
đã xảy ra [xem timerfd_create(2) để biết chi tiết]. 'cờ thời gian cố định' là
cờ ở dạng bát phân được sử dụng để thiết lập bộ đếm thời gian [xem timerfd_settime(2) để biết
chi tiết]. 'it_value' là thời gian còn lại cho đến khi hết giờ.
'it_interval' là khoảng thời gian dành cho bộ hẹn giờ. Lưu ý bộ hẹn giờ có thể được thiết lập
với tùy chọn TIMER_ABSTIME sẽ được hiển thị trong 'cờ thời gian cài đặt', nhưng 'it_value'
vẫn hiển thị thời gian còn lại của bộ đếm thời gian.

Tệp đệm DMA
~~~~~~~~~~~~~~~~

::

vị trí: 0
	cờ: 04002
	mnt_id: 9
	vào: 63107
	kích thước: 32768
	đếm: 2
	exp_name: đống hệ thống

trong đó 'size' là kích thước của bộ đệm DMA tính bằng byte. 'đếm' là số lượng tập tin của
tệp đệm DMA. 'exp_name' là tên của trình xuất bộ đệm DMA.

Tệp thiết bị VFIO
~~~~~~~~~~~~~~~~~

::

vị trí: 0
	cờ: 02000002
	mnt_id: 17
	vào: 5122
	vfio-device-syspath: /sys/devices/pci0000:e0/0000:e0:01.1/0000:e1:00.0/0000:e2:05.0/0000:e8:00.0

trong đó 'vfio-device-syspath' là đường dẫn sysfs tương ứng với thiết bị VFIO
tập tin.

3.9 /proc/<pid>/map_files - Thông tin về các tệp ánh xạ bộ nhớ
---------------------------------------------------------------------
Thư mục này chứa các liên kết tượng trưng đại diện cho các tệp ánh xạ bộ nhớ
quá trình đang được duy trì.  Đầu ra ví dụ::

| lr-------- 1 gốc gốc 64 ngày 27 tháng 1 11:24 333c600000-333c620000 -> /usr/lib64/ld-2.18.so
     | lr-------- 1 gốc gốc 64 ngày 27 tháng 1 11:24 333c81f000-333c820000 -> /usr/lib64/ld-2.18.so
     | lr-------- 1 gốc gốc 64 ngày 27 tháng 1 11:24 333c820000-333c821000 -> /usr/lib64/ld-2.18.so
     | ...
     | lr-------- 1 gốc gốc 64 Ngày 27 tháng 1 11:24 35d0421000-35d0422000 -> /usr/lib64/libselinux.so.1
     | lr-------- 1 gốc gốc 64 Ngày 27 tháng 1 11:24 400000-41a000 -> /usr/bin/ls

Tên của một liên kết đại diện cho giới hạn bộ nhớ ảo của ánh xạ, tức là.
vm_area_struct::vm_start-vm_area_struct::vm_end.

Mục đích chính của map_files là truy xuất một tập hợp bộ nhớ được ánh xạ
các tệp một cách nhanh chóng thay vì phân tích cú pháp /proc/<pid>/maps hoặc
/proc/<pid>/smaps, cả hai đều chứa nhiều bản ghi hơn.  Đồng thời
thời gian người ta có thể mở (2) ánh xạ từ danh sách của hai quy trình và
so sánh số inode của chúng để tìm ra vùng bộ nhớ ẩn danh nào
thực sự được chia sẻ.

3.10 /proc/<pid>/timerslack_ns - Giá trị trễ của bộ đếm thời gian tác vụ
---------------------------------------------------------
Tệp này cung cấp giá trị thời gian trễ của tác vụ tính bằng nano giây.
Giá trị này chỉ định khoảng thời gian mà bộ hẹn giờ thông thường có thể bị trì hoãn
để kết hợp các bộ tính giờ và tránh việc đánh thức không cần thiết.

Điều này cho phép sự cân bằng giữa tính tương tác và mức tiêu thụ điện năng của một tác vụ được thực hiện
đã điều chỉnh.

Việc ghi 0 vào tệp sẽ đặt bộ đếm thời gian của tác vụ thành giá trị mặc định.

Các giá trị hợp lệ là từ 0 - ULLONG_MAX

Ứng dụng cài đặt giá trị phải có mức PTRACE_MODE_ATTACH_FSCREDS
quyền đối với tác vụ được chỉ định để thay đổi giá trị timeslack_ns của nó.

3.11 /proc/<pid>/patch_state - Trạng thái hoạt động của bản vá Livepatch
-----------------------------------------------------------------
Khi CONFIG_LIVEPATCH được bật, tệp này sẽ hiển thị giá trị của
trạng thái bản vá cho nhiệm vụ.

Giá trị '-1' cho biết không có bản vá nào đang được chuyển đổi.

Giá trị '0' chỉ ra rằng một bản vá đang trong quá trình chuyển đổi và tác vụ đang được thực hiện
chưa được vá.  Nếu bản vá đang được bật thì tác vụ chưa được thực hiện
đã vá chưa.  Nếu bản vá đang bị vô hiệu hóa thì tác vụ đã được thực hiện
chưa được vá.

Giá trị '1' chỉ ra rằng một bản vá đang trong quá trình chuyển đổi và tác vụ đang được thực hiện
đã vá.  Nếu bản vá đang được bật thì tác vụ đã được thực hiện
đã vá.  Nếu bản vá bị vô hiệu hóa thì tác vụ chưa được thực hiện
chưa được vá.

3.12 /proc/<pid>/arch_status - trạng thái cụ thể của kiến ​​trúc tác vụ
-------------------------------------------------------------------
Khi CONFIG_PROC_PID_ARCH_STATUS được bật, tệp này sẽ hiển thị
kiến trúc trạng thái cụ thể của nhiệm vụ.

Ví dụ
~~~~~~~

::

$ cat /proc/6753/arch_status
 AVX512_elapsed_ms: 8

Sự miêu tả
~~~~~~~~~~~

các mục cụ thể x86
~~~~~~~~~~~~~~~~~~~~~

AVX512_elapsed_ms
^^^^^^^^^^^^^^^^^^

Nếu AVX512 được hỗ trợ trên máy, mục này hiển thị mili giây
  đã trôi qua kể từ lần cuối cùng việc sử dụng AVX512 được ghi lại. Bản ghi âm
  xảy ra trên cơ sở nỗ lực tốt nhất khi một nhiệm vụ được lên kế hoạch. Điều này có nghĩa
  rằng giá trị phụ thuộc vào hai yếu tố:

1) Thời gian mà tác vụ được thực hiện trên CPU mà không được lên lịch
       ra ngoài. Với cách ly CPU và một tác vụ có thể chạy được, việc này có thể thực hiện
       vài giây.

2) Thời gian kể từ khi nhiệm vụ được lên kế hoạch lần cuối. Tùy thuộc vào
       lý do bị lên lịch (hết thời gian, syscall ...)
       điều này có thể tùy ý trong thời gian dài.

Kết quả là giá trị không thể được coi là chính xác và có thẩm quyền
  thông tin. Ứng dụng sử dụng thông tin này phải nhận thức được
  của kịch bản tổng thể trên hệ thống để xác định liệu một
  task có phải là người dùng AVX512 thực sự hay không. Thông tin chính xác có thể được lấy
  với bộ đếm hiệu suất.

Giá trị đặc biệt '-1' cho biết rằng không có việc sử dụng AVX512 nào được ghi lại, do đó
  tác vụ này khó có thể xảy ra với người dùng AVX512 mà phụ thuộc vào khối lượng công việc và
  kịch bản lập kế hoạch, nó cũng có thể là một kết quả âm tính giả đã đề cập ở trên.

3.13 /proc/<pid>/fd - Danh sách các liên kết tượng trưng để mở tệp
-------------------------------------------------------
Thư mục này chứa các liên kết tượng trưng đại diện cho các tệp đang mở
quá trình đang được duy trì.  Đầu ra ví dụ::

lr-x------ 1 gốc gốc 64 20 tháng 9 17:53 0 -> /dev/null
  l-wx------ 1 gốc gốc 64 20 tháng 9 17:53 1 -> /dev/null
  lrwx------ 1 root root 64 20/09 17:53 10 -> 'socket:[12539]'
  lrwx------ 1 root root 64 20/09 17:53 11 -> 'socket:[12540]'
  lrwx------ 1 root root 64 20 tháng 9 17:53 12 -> 'socket:[12542]'

Số lượng file đang mở cho tiến trình được lưu trữ trong thành viên 'size'
của đầu ra stat() cho /proc/<pid>/fd để truy cập nhanh.
-------------------------------------------------------

3.14 /proc/<pid>/ksm_stat - Thông tin về trạng thái ksm của quy trình
----------------------------------------------------------------------
Khi CONFIG_KSM được bật, mỗi quy trình sẽ có tệp này hiển thị
thông tin về trạng thái hợp nhất ksm.

Ví dụ
~~~~~~~

::

/ # cat /proc/self/ksm_stat
    ksm_rmap_items 0
    ksm_zero_pages 0
    ksm_merging_pages 0
    ksm_process_profit 0
    ksm_merge_any: không
    ksm_mergeable: không

Sự miêu tả
~~~~~~~~~~~

ksm_rmap_items
^^^^^^^^^^^^^^

Số lượng cấu trúc ksm_rmap_item đang sử dụng.  Cấu trúc
ksm_rmap_item lưu trữ thông tin ánh xạ ngược cho ảo
địa chỉ.  KSM sẽ tạo ksm_rmap_item cho mỗi trang được quét ksm của
quá trình này.

ksm_zero_pages
^^^^^^^^^^^^^^

Khi /sys/kernel/mm/ksm/use_zero_pages được bật, nó biểu thị số lượng
các trang trống được KSM hợp nhất với các trang kernel zero.

ksm_merging_pages
^^^^^^^^^^^^^^^^^

Nó biểu thị có bao nhiêu trang của quá trình này liên quan đến việc hợp nhất KSM
(không bao gồm ksm_zero_pages). Nó cũng tương tự với những gì
/proc/<pid>/ksm_merging_pages hiển thị.

ksm_process_profit
^^^^^^^^^^^^^^^^^^

Lợi nhuận mà KSM mang lại (Số byte đã lưu). KSM có thể tiết kiệm bộ nhớ bằng cách hợp nhất
các trang giống hệt nhau nhưng cũng có thể tiêu tốn thêm bộ nhớ vì nó cần
để tạo một số rmap_items để lưu rmap tóm tắt của mỗi trang được quét
thông tin. Một số trang trong số này có thể được hợp nhất, nhưng một số trang có thể không thực hiện được
được sáp nhập sau khi được kiểm tra nhiều lần, không có lãi
bộ nhớ tiêu thụ.

ksm_merge_any
^^^^^^^^^^^^^

Nó chỉ rõ liệu 'mm của tiến trình có được thêm bởi prctl() vào
danh sách ứng cử viên của KSM hay không, và liệu tính năng quét KSM có được bật hoàn toàn tại
cấp độ quá trình.

ksm_mergeable
^^^^^^^^^^^^^

Nó chỉ định liệu có bất kỳ VMA nào của mm của quy trình hiện đang được
áp dụng cho KSM.

Thông tin thêm về KSM có thể được tìm thấy trong
Tài liệu/admin-guide/mm/ksm.rst.


Chương 4: Cấu hình Procfs
=============================

4.1 Tùy chọn gắn kết
---------------------

Các tùy chọn gắn kết sau được hỗ trợ:

=======================================================================
	Hidepid= Đặt chế độ truy cập /proc/<pid>/.
	gid= Đặt nhóm được ủy quyền để tìm hiểu thông tin quy trình.
	subset= Chỉ hiển thị tập hợp con được chỉ định của Procfs.
	pidns= Chỉ định không gian tên được sử dụng bởi giao dịch này.
	=======================================================================

Hidepid=off hoặc Hidepid=0 có nghĩa là chế độ cổ điển - mọi người đều có thể truy cập tất cả
/proc/<pid>/ thư mục (mặc định).

Hidepid=noaccess hoặc Hidepid=1 có nghĩa là người dùng không được truy cập bất kỳ /proc/<pid>/ nào
thư mục nhưng của riêng họ.  Các tệp nhạy cảm như cmdline, sched*, status hiện đã được lưu trữ
được bảo vệ khỏi những người dùng khác.  Điều này làm cho không thể biết được liệu có
người dùng chạy chương trình cụ thể (do chương trình không tự hiển thị bằng
hành vi).  Là một phần thưởng bổ sung, vì /proc/<pid>/cmdline không thể truy cập được đối với
những người dùng khác, các chương trình được viết kém truyền thông tin nhạy cảm qua chương trình
các đối số hiện được bảo vệ chống lại những kẻ nghe lén cục bộ.

Hidepid=invisible hoặc Hidepid=2 có nghĩa là Hidepid=1 cộng với tất cả /proc/<pid>/ sẽ
hoàn toàn vô hình đối với người dùng khác.  Điều đó không có nghĩa là nó che giấu một sự thật cho dù
tồn tại một quy trình có giá trị pid cụ thể (có thể học được bằng các phương tiện khác, ví dụ:
bằng "kill -0 $PID"), nhưng nó ẩn uid và gid của tiến trình, mà có thể được học bởi
stat()'ing /proc/<pid>/ nếu không.  Nó làm phức tạp đáng kể nhiệm vụ của kẻ xâm nhập
thu thập thông tin về các tiến trình đang chạy, liệu một số daemon có chạy với
đặc quyền nâng cao, liệu người dùng khác có chạy một số chương trình nhạy cảm hay không, liệu
những người dùng khác chạy bất kỳ chương trình nào, v.v.

Hidepid=ptraceable hoặc Hidepid=4 có nghĩa là các procf chỉ nên chứa
/proc/<pid>/ thư mục mà người gọi có thể truy cập.

gid= xác định một nhóm được ủy quyền để tìm hiểu thông tin xử lý nếu không
bị cấm bởi Hidepid=.  Nếu bạn sử dụng một số daemon như identd cần tìm hiểu
thông tin về thông tin quy trình, chỉ cần thêm identd vào nhóm này.

subset=pid ẩn tất cả các tệp và thư mục cấp cao nhất trong các Procfs
không liên quan đến nhiệm vụ.

pidns= chỉ định một không gian tên pid (dưới dạng đường dẫn chuỗi tới một cái gì đó như
ZZ0000ZZ hoặc bộ mô tả tệp khi sử dụng ZZ0001ZZ)
sẽ được phiên bản Procfs sử dụng khi dịch pids. Theo mặc định, procfs
sẽ sử dụng không gian tên pid hoạt động của quá trình gọi. Lưu ý rằng pid
không thể sửa đổi không gian tên của một phiên bản Procfs hiện có (cố gắng thực hiện
vì vậy sẽ báo lỗi ZZ0002ZZ).

Chương 5: Hành vi của hệ thống tập tin
==============================

Ban đầu, trước khi có không gian tên pid, Procfs là một tệp toàn cục
hệ thống. Điều đó có nghĩa là chỉ có một phiên bản Procfs trong hệ thống.

Khi không gian tên pid được thêm vào, một phiên bản Procfs riêng biệt được gắn vào
mỗi không gian tên pid. Vì vậy, các tùy chọn gắn kết Procfs mang tính toàn cầu trong số tất cả
điểm gắn kết trong cùng một không gian tên::

# grep ^proc /proc/mount
	proc /proc proc rw,relatime,hidepid=2 0 0

# strace -e mount mount -o Hidepid=1 -t proc proc /tmp/proc
	mount("proc", "/tmp/proc", "proc", 0, "hidepid=1") = 0
	+++ đã thoát với 0 +++

# grep ^proc /proc/mount
	proc /proc proc rw,relatime,hidepid=2 0 0
	proc /tmp/proc proc rw,relatime,hidepid=2 0 0

và chỉ sau khi kể lại các tùy chọn gắn kết của Procfs mới hoàn toàn thay đổi
điểm gắn kết::

# mount -o kể lại,hidepid=1 -t proc proc /tmp/proc

# grep ^proc /proc/mount
	proc /proc proc rw,relatime,hidepid=1 0 0
	proc /tmp/proc proc rw,relatime,hidepid=1 0 0

Hành vi này khác với hành vi của các hệ thống tập tin khác.

Hành vi của Procfs mới giống các hệ thống tập tin khác hơn. Mỗi procfs gắn kết
tạo một phiên bản Procfs mới. Tùy chọn gắn kết ảnh hưởng đến phiên bản Procfs của riêng bạn.
Điều đó có nghĩa là có thể có một số phiên bản Procfs
hiển thị các tác vụ với các tùy chọn lọc khác nhau trong một không gian tên pid::

# mount -o Hidepid=vô hình -t proc proc /proc
	# mount -o Hidepid=noaccess -t proc proc /tmp/proc
	# grep ^proc /proc/mounts
	proc /proc proc rw,relatime,hidepid=vô hình 0 0
	proc /tmp/proc proc rw,relatime,hidepid=noaccess 0 0