.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/tainted-kernels.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

hạt bị nhiễm độc
---------------

Hạt nhân sẽ tự đánh dấu là 'bị nhiễm độc' khi có điều gì đó xảy ra có thể là
có liên quan sau này khi điều tra vấn đề. Đừng lo lắng quá về điều này,
trong hầu hết các trường hợp, việc chạy hạt nhân bị nhiễm độc không phải là vấn đề; thông tin là
chủ yếu được quan tâm khi ai đó muốn điều tra một số vấn đề, vì nó thực sự
nguyên nhân có thể là sự kiện khiến kernel bị nhiễm độc. Đó là lý do tại sao báo cáo lỗi
từ các hạt nhân bị nhiễm độc thường sẽ bị các nhà phát triển bỏ qua, do đó hãy cố gắng tái tạo
vấn đề với một hạt nhân không bị nhiễm độc.

Lưu ý rằng kernel sẽ vẫn bị nhiễm bẩn ngay cả sau khi bạn hoàn tác những gì đã gây ra vết bẩn
(tức là dỡ bỏ mô-đun hạt nhân độc quyền), để cho biết hạt nhân vẫn chưa
đáng tin cậy. Đó cũng là lý do tại sao kernel sẽ in trạng thái bị nhiễm độc khi nó
nhận thấy một vấn đề nội bộ ('lỗi hạt nhân'), một lỗi có thể phục hồi được
("kernel oops") hoặc lỗi không thể khôi phục ("kernel hoảng loạn") và ghi lỗi
thông tin về điều này vào đầu ra nhật ký ZZ0000ZZ. Cũng có thể
kiểm tra trạng thái bị nhiễm độc trong thời gian chạy thông qua tệp trong ZZ0001ZZ.


Cờ bị nhiễm độc trong các thông báo lỗi, lỗi hoặc hoảng loạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bạn tìm thấy trạng thái bị nhiễm độc ở gần đầu dòng bắt đầu bằng 'CPU:'; nếu hoặc
lý do hạt nhân bị nhiễm độc được hiển thị sau ID tiến trình ('PID:') và phần rút gọn
tên của lệnh ('Comm:') đã kích hoạt sự kiện::

BUG: không thể xử lý tham chiếu con trỏ NULL ở 00000000000000000
	Rất tiếc: 0002 [#1] SMP PTI
	CPU: 0 PID: 4424 Comm: insmod Bị nhiễm độc: P W O 4.20.0-0.rc6.fc30 #1
	Tên phần cứng: Red Hat KVM, BIOS 0.5.1 01/01/2011
	RIP: 0010:my_oops_init+0x13/0x1000 [kpanic]
	[…]

Bạn sẽ tìm thấy thông báo 'Không bị nhiễm độc' ở đó nếu hạt nhân không bị nhiễm độc ở
thời gian diễn ra sự kiện; nếu đúng thì nó sẽ in 'Tainted: ' và các ký tự
chữ cái hoặc khoảng trống. Trong ví dụ trên nó trông như thế này::

Bị nhiễm độc: P W O

Ý nghĩa của các ký tự đó được giải thích trong bảng dưới đây. Trong trường hợp này
hạt nhân trước đó đã bị nhiễm độc do Mô-đun độc quyền (ZZ0000ZZ) đã được tải,
đã xảy ra cảnh báo (ZZ0001ZZ) và mô-đun được chế tạo bên ngoài đã được tải (ZZ0002ZZ).
Để giải mã các chữ cái khác, hãy sử dụng bảng dưới đây.


Giải mã trạng thái bị nhiễm độc trong thời gian chạy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trong thời gian chạy, bạn có thể truy vấn trạng thái bị nhiễm độc bằng cách đọc
ZZ0000ZZ. Nếu điều đó trả về ZZ0001ZZ thì kernel không
bị nhiễm độc; bất kỳ con số nào khác cho biết lý do tại sao. Cách dễ nhất để
giải mã con số đó là tập lệnh ZZ0002ZZ, mà bạn
việc phân phối có thể được vận chuyển như một phần của gói có tên ZZ0003ZZ hoặc
ZZ0004ZZ; nếu không, bạn có thể tải xuống tập lệnh từ
ZZ0006ZZ
và thực thi nó bằng ZZ0005ZZ, nó sẽ in một cái gì đó như
cái này trên máy có các câu lệnh trong nhật ký được trích dẫn trước đó::

	Kernel is Tainted for following reasons:
	 * Proprietary module was loaded (#0)
	 * Kernel issued warning (#9)
	 * Externally-built ('out-of-tree') module was loaded  (#12)
	See Documentation/admin-guide/tainted-kernels.rst in the Linux kernel or
	 https://www.kernel.org/doc/html/latest/admin-guide/tainted-kernels.html for
	 a more details explanation of the various taint flags.
	Raw taint value as int/string: 4609/'P        W  O     '

You can try to decode the number yourself. That's easy if there was only one
reason that got your kernel tainted, as in this case you can find the number
with the table below. If there were multiple reasons you need to decode the
number, as it is a bitfield, where each bit indicates the absence or presence of
a particular type of taint. It's best to leave that to the aforementioned
script, but if you need something quick you can use this shell command to check
which bits are set::

	$ for i in $(seq 20); do echo $(($i-1)) $(($(cat /proc/sys/kernel/tainted)>>($i-1)&1));done

Table for decoding tainted state
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

===  ===  ======  ========================================================
Bit  Log  Number  Reason that got the kernel tainted
===  ===  ======  ========================================================
  0  G/P       1  proprietary module was loaded
  1  _/F       2  module was force loaded
  2  _/S       4  kernel running on an out of specification system
  3  _/R       8  module was force unloaded
  4  _/M      16  processor reported a Machine Check Exception (MCE)
  5  _/B      32  bad page referenced or some unexpected page flags
  6  _/U      64  taint requested by userspace application
  7  _/D     128  kernel died recently, i.e. there was an OOPS or BUG
  8  _/A     256  ACPI table overridden by user
  9  _/W     512  kernel issued warning
 10  _/C    1024  staging driver was loaded
 11  _/I    2048  workaround for bug in platform firmware applied
 12  _/O    4096  externally-built ("out-of-tree") module was loaded
 13  _/E    8192  unsigned module was loaded
 14  _/L   16384  soft lockup occurred
 15  _/K   32768  kernel has been live patched
 16  _/X   65536  auxiliary taint, defined for and used by distros
 17  _/T  131072  kernel was built with the struct randomization plugin
 18  _/N  262144  an in-kernel test has been run
 19  _/J  524288  userspace used a mutating debug operation in fwctl
===  ===  ======  ========================================================

Note: The character ``_`` is representing a blank in this table to make reading
easier.

More detailed explanation for tainting
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 0)  ``G`` if all modules loaded have a GPL or compatible license, ``P`` if
     any proprietary module has been loaded.  Modules without a
     MODULE_LICENSE or with a MODULE_LICENSE that is not recognised by
     insmod as GPL compatible are assumed to be proprietary.

 1)  ``F`` if any module was force loaded by ``insmod -f``, ``' '`` if all
     modules were loaded normally.

 2)  ``S`` if the kernel is running on a processor or system that is out of
     specification: hardware has been put into an unsupported configuration,
     therefore proper execution cannot be guaranteed.
     Kernel will be tainted if, for example:

     - on x86: PAE is forced through forcepae on intel CPUs (such as Pentium M)
       which do not report PAE but may have a functional implementation, an SMP
       kernel is running on non officially capable SMP Athlon CPUs, MSRs are
       being poked at from userspace.
     - on arm: kernel running on certain CPUs (such as Keystone 2) without
       having certain kernel features enabled.
     - on arm64: there are mismatched hardware features between CPUs, the
       bootloader has booted CPUs in different modes.
     - certain drivers are being used on non supported architectures (such as
       scsi/snic on something else than x86_64, scsi/ips on non
       x86/x86_64/itanium, have broken firmware settings for the
       irqchip/irq-gic on arm64 ...).
     - x86/x86_64: Microcode late loading is dangerous and will result in
       tainting the kernel. It requires that all CPUs rendezvous to make sure
       the update happens when the system is as quiescent as possible. However,
       a higher priority MCE/SMI/NMI can move control flow away from that
       rendezvous and interrupt the update, which can be detrimental to the
       machine.

 3)  ``R`` if a module was force unloaded by ``rmmod -f``, ``' '`` if all
     modules were unloaded normally.

 4)  ``M`` if any processor has reported a Machine Check Exception,
     ``' '`` if no Machine Check Exceptions have occurred.

 5)  ``B`` If a page-release function has found a bad page reference or some
     unexpected page flags. This indicates a hardware problem or a kernel bug;
     there should be other information in the log indicating why this tainting
     occurred.

 6)  ``U`` if a user or user application specifically requested that the
     Tainted flag be set, ``' '`` otherwise.

 7)  ``D`` if the kernel has died recently, i.e. there was an OOPS or BUG.

 8)  ``A`` if an ACPI table has been overridden.

 9)  ``W`` if a warning has previously been issued by the kernel.
     (Though some warnings may set more specific taint flags.)

 10) ``C`` if a staging driver has been loaded.

 11) ``I`` if the kernel is working around a severe bug in the platform
     firmware (BIOS or similar).

 12) ``O`` if an externally-built ("out-of-tree") module has been loaded.

 13) ``E`` if an unsigned module has been loaded in a kernel supporting
     module signature.

 14) ``L`` if a soft lockup has previously occurred on the system.

 15) ``K`` if the kernel has been live patched.

 16) ``X`` Auxiliary taint, defined for and used by Linux distributors.

 17) ``T`` Kernel was build with the randstruct plugin, which can intentionally
     produce extremely unusual kernel structure layouts (even performance
     pathological ones), which is important to know when debugging. Set at
     build time.

 18) ``N`` if an in-kernel test, such as a KUnit test, has been run.

 19) ``J`` if userspace opened /dev/fwctl/* and performed a FWTCL_RPC_DEBUG_WRITE
     to use the devices debugging features. Device debugging features could
     cause the device to malfunction in undefined ways.
