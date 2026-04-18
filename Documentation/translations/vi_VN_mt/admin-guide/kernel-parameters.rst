.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/kernel-parameters.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _kernelparameters:

Các tham số dòng lệnh của kernel
====================================

Sau đây là danh sách tổng hợp các tham số kernel đã được triển khai
bởi các macro __setup(), Early_param(), core_param() và module_param()
và sắp xếp theo thứ tự Từ điển tiếng Anh (được định nghĩa là bỏ qua tất cả
dấu câu và sắp xếp các chữ số trước các chữ cái trong trường hợp không phân biệt chữ hoa chữ thường
cách) và với các mô tả nếu biết.

Hạt nhân phân tích các tham số từ dòng lệnh hạt nhân lên tới "ZZ0000ZZ";
nếu nó không nhận ra một tham số và nó không chứa '.', thì
tham số được chuyển tới init: tham số có '=' đi vào init
môi trường, những cái khác được chuyển dưới dạng đối số dòng lệnh cho init.
Mọi thứ sau "ZZ0001ZZ" được chuyển làm đối số cho init.

Các tham số mô-đun có thể được chỉ định theo hai cách: thông qua lệnh kernel
dòng có tiền tố tên mô-đun hoặc thông qua modprobe, ví dụ::

	(kernel command line) usbcore.blinkenlights=1
	(modprobe command line) modprobe usbcore blinkenlights=1

Parameters for modules which are built into the kernel need to be
specified on the kernel command line.  modprobe looks through the
kernel command line (/proc/cmdline) and collects module parameters
when it loads a module, so the kernel command line can be used for
loadable modules too.

This document may not be entirely up to date and comprehensive. The command
"modinfo -p ${modulename}" shows a current list of all parameters of a loadable
module. Loadable modules, after being loaded into the running kernel, also
reveal their parameters in /sys/module/${modulename}/parameters/. Some of these
parameters may be changed at runtime by the command
``echo -n ${value} > /sys/module/${modulename}/parameters/${parm}``.

Special handling
----------------

Hyphens (dashes) and underscores are equivalent in parameter names, so::

	log_buf_len=1M print-fatal-signals=1

can also be entered as::

	log-buf-len=1M print_fatal_signals=1

Double-quotes can be used to protect spaces in values, e.g.::

	param="spaces in here"

cpu lists
~~~~~~~~~

Some kernel parameters take a list of CPUs as a value, e.g.  isolcpus,
nohz_full, irqaffinity, rcu_nocbs.  The format of this list is:

	<cpu number>,...,<cpu number>

or

	<cpu number>-<cpu number>
	(must be a positive range in ascending order)

or a mixture

<cpu number>,...,<cpu number>-<cpu number>

Note that for the special case of a range one can split the range into equal
sized groups and for each group use some amount from the beginning of that
group:

	<cpu number>-<cpu number>:<used size>/<group size>

For example one can add to the command line following parameter:

	isolcpus=1,2,10-20,100-2000:2/25

where the final item represents CPUs 100,101,125,126,150,151,...

The value "N" can be used to represent the numerically last CPU on the system,
i.e "foo_cpus=16-N" would be equivalent to "16-31" on a 32 core system.

Keep in mind that "N" is dynamic, so if system changes cause the bitmap width
to change, such as less cores in the CPU list, then N and any ranges using N
will also change.  Use the same on a small 4 core system, and "16-N" becomes
"16-3" and now the same boot input will be flagged as invalid (start > end).

The special case-tolerant group name "all" has a meaning of selecting all CPUs,
so that "nohz_full=all" is the equivalent of "nohz_full=0-N".

The semantics of "N" and "all" is supported on a level of bitmaps and holds for
all users of bitmap_parselist().

Metric suffixes
~~~~~~~~~~~~~~~

The [KMG] suffix is commonly described after a number of kernel
parameter values. 'K', 'M', 'G', 'T', 'P', and 'E' suffixes are allowed.
These letters represent the _binary_ multipliers 'Kilo', 'Mega', 'Giga',
'Tera', 'Peta', and 'Exa', equaling 2^10, 2^20, 2^30, 2^40, 2^50, and
2^60 bytes respectively. Such letter suffixes can also be entirely omitted.

Kernel Build Options
--------------------

The parameters listed below are only valid if certain kernel build options
were enabled and if respective hardware is present. This list should be kept
in alphabetical order. The text in square brackets at the beginning
of each description states the restrictions within which a parameter
is applicable.

Parameters denoted with BOOT are actually interpreted by the boot
loader, and have no meaning to the kernel directly.
Do not modify the syntax of boot loader parameters without extreme
need or coordination with <Documentation/arch/x86/boot.rst>.

There are also arch-specific kernel-parameters not documented here.

Note that ALL kernel parameters listed below are CASE SENSITIVE, and that
a trailing = on the name of any parameter states that the parameter will
be entered as an environment variable, whereas its absence indicates that
it will appear as a kernel argument readable via /proc/cmdline by programs
running once the system is up.

The number of kernel parameters is not limited, but the length of the
complete command line (parameters including spaces etc.) is limited to
a fixed number of characters. This limit depends on the architecture
and is between 256 and 4096 characters. It is defined in the file
./include/uapi/asm-generic/setup.h as COMMAND_LINE_SIZE.

.. include:: kernel-parameters.txt
   :literal: