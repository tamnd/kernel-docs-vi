.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/boottime-trace.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================
Theo dõi thời gian khởi động
============================

:Tác giả: Masami Hiramatsu <mhiramat@kernel.org>

Tổng quan
========

Theo dõi thời gian khởi động cho phép người dùng theo dõi quá trình thời gian khởi động bao gồm
khởi tạo thiết bị với đầy đủ tính năng của ftrace bao gồm mỗi sự kiện
bộ lọc và hành động, biểu đồ, sự kiện kprobe và sự kiện tổng hợp,
và theo dõi các trường hợp.
Vì dòng lệnh kernel không đủ để kiểm soát các tính năng phức tạp này,
cái này sử dụng tệp bootconfig để mô tả lập trình tính năng theo dõi.

Các tùy chọn trong Boot Config
==========================

Đây là danh sách các tùy chọn có sẵn để theo dõi thời gian khởi động trong
tập tin cấu hình khởi động [1]_. Tất cả các tùy chọn đều nằm trong "ftrace." hoặc "hạt nhân."
tiền tố. Xem các tham số kernel để biết các tùy chọn bắt đầu
với "hạt nhân." tiền tố [2]_.

.. [1] See :ref:`Documentation/admin-guide/bootconfig.rst <bootconfig>`
.. [2] See :ref:`Documentation/admin-guide/kernel-parameters.rst <kernelparameters>`

Tùy chọn toàn cầu Ftrace
---------------------

Các tùy chọn toàn cầu của Ftrace có "kernel". tiền tố trong cấu hình khởi động, có nghĩa là
các tùy chọn này được chuyển như một phần của dòng lệnh kế thừa kernel.

kernel.tp_printk
   Xuất dữ liệu sự kiện theo dõi trên bộ đệm printk.

kernel.dump_on_oops [= MODE]
   Kết xuất ftrace trên Rất tiếc. Nếu MODE = 1 hoặc bị bỏ qua, hãy đổ bộ đệm theo dõi
   trên tất cả các CPU. Nếu MODE = 2, hãy đổ bộ đệm vào CPU, điều này sẽ gây ra Lỗi.

kernel.traceoff_on_warning
   Dừng truy tìm nếu WARN_ON() xảy ra.

kernel.fgraph_max_deep = MAX_DEPTH
   Đặt MAX_DEPTH ở độ sâu tối đa của bộ theo dõi đồ thị.

kernel.fgraph_filters = FILTER[, FILTER2...]
   Thêm bộ lọc chức năng theo dõi fgraph.

kernel.fgraph_notraces = FILTER[, FILTER2...]
   Thêm các bộ lọc chức năng không theo dõi fgraph.


Tùy chọn Ftrace cho mỗi phiên bản
---------------------------

Các tùy chọn này có thể được sử dụng cho từng phiên bản bao gồm nút ftrace toàn cầu.

ftrace.[instance.INSTANCE.]options = OPT1[, OPT2[...]]
   Kích hoạt các tùy chọn ftrace nhất định.

ftrace.[instance.INSTANCE.]tracing_on = 0|1
   Bật/Tắt tính năng theo dõi trong trường hợp này khi bắt đầu theo dõi thời gian khởi động.
   (bạn có thể kích hoạt nó bằng hành động kích hoạt sự kiện "traceon")

ftrace.[instance.INSTANCE.]trace_clock = CLOCK
   Đặt CLOCK đã cho thành trace_clock của ftrace.

ftrace.[instance.INSTANCE.]buffer_size = SIZE
   Định cấu hình kích thước bộ đệm ftrace thành SIZE. Bạn có thể sử dụng "KB" hoặc "MB"
   cho chiếc SIZE đó.

ftrace.[instance.INSTANCE.]alloc_snapshot
   Phân bổ bộ đệm chụp nhanh.

ftrace.[instance.INSTANCE.]cpumask = CPUMASK
   Đặt CPUMASK làm mặt nạ cpu theo dõi.

ftrace.[instance.INSTANCE.]events = EVENT[, EVENT2[...]]
   Kích hoạt các sự kiện nhất định khi khởi động. Bạn có thể sử dụng thẻ đại diện trong EVENT.

ftrace.[instance.INSTANCE.]tracer = TRACER
   Đặt TRACER thành bộ theo dõi hiện tại khi khởi động. (ví dụ: chức năng)

ftrace.[instance.INSTANCE.]ftrace.filters
   Điều này sẽ lấy một loạt các quy tắc lọc chức năng theo dõi.

ftrace.[instance.INSTANCE.]ftrace.notraces
   Điều này sẽ lấy một loạt các quy tắc lọc chức năng theo dõi NON.


Tùy chọn Ftrace cho mỗi sự kiện
------------------------

Các tùy chọn này đang thiết lập các tùy chọn cho mỗi sự kiện.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.enable
   Kích hoạt tính năng theo dõi GROUP:EVENT.

ftrace.[instance.INSTANCE.]event.GROUP.enable
   Kích hoạt tất cả theo dõi sự kiện trong GROUP.

ftrace.[instance.INSTANCE.]event.enable
   Kích hoạt tất cả theo dõi sự kiện.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.filter = FILTER
   Đặt quy tắc FILTER thành GROUP:EVENT.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.actions = ACTION[, ACTION2[...]]
   Đặt HÀNH ĐỘNG thành GROUP:EVENT.

ftrace.[instance.INSTANCE.]event.kprobes.EVENT.probes = PROBE[, PROBE2[...]]
   Xác định sự kiện kprobe mới dựa trên PROBE. Nó có thể định nghĩa
   nhiều thăm dò trên một sự kiện, nhưng chúng phải có cùng loại
   lý lẽ. Tùy chọn này chỉ có sẵn cho sự kiện
   tên nhóm là "kprobes".

ftrace.[instance.INSTANCE.]event.synthetic.EVENT.fields = FIELD[, FIELD2[...]]
   Xác định sự kiện tổng hợp mới bằng FIELD. Mỗi trường nên được
   "gõ tên biến".

Lưu ý rằng các định nghĩa sự kiện tổng hợp và kprobe có thể được viết dưới
nút phiên bản, nhưng chúng cũng có thể nhìn thấy được từ các phiên bản khác. Vì vậy làm ơn
chú ý đến xung đột tên sự kiện.

Tùy chọn biểu đồ Ftrace
------------------------

Vì quá dài để viết một hành động biểu đồ dưới dạng chuỗi cho mỗi sự kiện
tùy chọn hành động, có các tùy chọn kiểu cây trong khóa con 'lịch sử' cho mỗi sự kiện
cho các hành động biểu đồ. Để biết chi tiết từng tham số,
vui lòng đọc tài liệu biểu đồ sự kiện (Documentation/trace/histogram.rst)

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]keys = KEY1[, KEY2[...]]
  Đặt các tham số chính của biểu đồ. (Bắt buộc)
  'N' là một chuỗi chữ số cho biểu đồ bội số. Bạn có thể bỏ qua nó
  nếu có một biểu đồ về sự kiện này.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]values = VAL1[, VAL2[...]]
  Đặt tham số giá trị biểu đồ.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]sort = SORT1[, SORT2[...]]
  Đặt tùy chọn tham số sắp xếp biểu đồ.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]size = NR_ENTRIES
  Đặt kích thước biểu đồ (số lượng mục nhập).

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]name = NAME
  Đặt tên biểu đồ.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]var.VARIABLE = EXPR
  Xác định VARIABLE mới bằng biểu thức EXPR.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]<pause|continue|clear>
  Đặt tham số kiểm soát biểu đồ. Bạn có thể thiết lập một trong số họ.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]onmatch.[M.]event = GROUP.EVENT
  Đặt tham số sự kiện khớp với trình xử lý 'onmatch' biểu đồ.
  'M' là một chuỗi chữ số cho trình xử lý nhiều 'onmatch'. Bạn có thể bỏ qua nó
  nếu có một trình xử lý 'onmatch' trên biểu đồ này.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]onmatch.[M.]trace = EVENT[, ARG1[...]]
  Đặt hành động 'theo dõi' biểu đồ cho 'onmatch'.
  EVENT phải là tên sự kiện tổng hợp và ARG1... là thông số
  cho sự kiện đó. Bắt buộc nếu tùy chọn 'onmatch.event' được đặt.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]onmax.[M.]var = VAR
  Đặt tham số biến trình xử lý biểu đồ 'onmax'.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]onchange.[M.]var = VAR
  Đặt tham số biến trình xử lý biểu đồ 'onchange'.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]<onmax|onchange>.[M.]save = ARG1[, ARG2[...]]
  Đặt tham số hành động 'lưu' biểu đồ cho trình xử lý 'onmax' hoặc 'onchange'.
  Tùy chọn này hoặc tùy chọn 'snapshot' bên dưới là bắt buộc nếu 'onmax.var' hoặc
  Tùy chọn 'onchange.var' được đặt.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.[N.]<onmax|onchange>.[M.]snapshot
  Đặt hành động 'ảnh chụp nhanh' biểu đồ cho trình xử lý 'onmax' hoặc 'onchange'.
  Tùy chọn này hoặc tùy chọn 'lưu' ở trên là bắt buộc nếu 'onmax.var' hoặc
  Tùy chọn 'onchange.var' được đặt.

ftrace.[instance.INSTANCE.]event.GROUP.EVENT.hist.filter = FILTER_EXPR
  Đặt biểu thức lọc biểu đồ. Bạn không cần 'nếu' trong FILTER_EXPR.

Lưu ý rằng tùy chọn 'lịch sử' này có thể xung đột với 'hành động' trên mỗi sự kiện
tùy chọn nếu tùy chọn 'hành động' có hành động biểu đồ.


Khi nào bắt đầu
=============

Tất cả các tùy chọn theo dõi thời gian khởi động bắt đầu bằng ZZ0000ZZ sẽ được bật tại
kết thúc core_initcall. Điều này có nghĩa là bạn có thể theo dõi các sự kiện từ postcore_initcall.
Hầu hết các hệ thống con và trình điều khiển phụ thuộc vào kiến trúc sẽ được khởi tạo
sau đó (arch_initcall hoặc subsys_initcall). Vì vậy, bạn có thể theo dõi những người có
theo dõi thời gian khởi động.
Nếu bạn muốn theo dõi các sự kiện trước core_initcall, bạn có thể sử dụng các tùy chọn
bắt đầu với ZZ0001ZZ. Một số trong số chúng sẽ được kích hoạt sớm hơn initcall
xử lý (ví dụ: ZZ0002ZZ và ZZ0003ZZ
sẽ bắt đầu trước initcall.)


Ví dụ
========

Ví dụ: để thêm bộ lọc và hành động cho từng sự kiện, hãy xác định kprobe
sự kiện và sự kiện tổng hợp có biểu đồ, hãy viết cấu hình khởi động như
dưới đây::

ftrace.event {
        nhiệm vụ.task_newtask {
                bộ lọc = "pid < 128"
                kích hoạt
        }
        kprobes.vfs_read {
                thăm dò = "vfs_read $arg1 $arg2"
                bộ lọc = "common_pid < 200"
                kích hoạt
        }
        tổng hợp.initcall_latency {
                field = "unsign long func", "u64 lat"
                lịch sử {
                        phím = func.sym, lat
                        giá trị = vĩ độ
                        sắp xếp = vĩ độ
                }
        }
        initcall.initcall_start.hist {
                phím = chức năng
                var.ts0 = common_timestamp.usecs
        }
        initcall.initcall_finish.hist {
                phím = chức năng
                var.lat = common_timestamp.usecs - $ts0
                trận đấu {
                        sự kiện = initcall.initcall_start
                        dấu vết = initcall_latency, func, $lat
                }
        }
  }

Ngoài ra, tính năng theo dõi thời gian khởi động hỗ trợ nút "phiên bản", cho phép chúng tôi chạy
một số công cụ theo dõi cho các mục đích khác nhau cùng một lúc. Ví dụ, một người theo dõi
dành cho các hàm theo dõi bắt đầu bằng "user\_" và các hàm khác theo dõi
với các hàm "kernel\_", bạn có thể viết cấu hình khởi động như bên dưới::

ftrace.instance {
        foo {
                người theo dõi = "chức năng"
                ftrace.filters = "user_*"
        }
        thanh {
                người theo dõi = "chức năng"
                ftrace.filters = "kernel_*"
        }
  }

Nút phiên bản cũng chấp nhận các nút sự kiện để mỗi phiên bản
có thể tùy chỉnh theo dõi sự kiện của nó.

Với hành động kích hoạt và đầu dò k, bạn có thể theo dõi đồ thị hàm số trong khi
một chức năng được gọi. Ví dụ: điều này sẽ theo dõi tất cả các lệnh gọi hàm trong
pci_proc_init()::

ftrace {
        truy tìm_on = 0
        dấu vết = hàm_graph
        sự kiện.kprobes {
                sự kiện bắt đầu {
                        thăm dò = "pci_proc_init"
                        hành động = "traceon"
                }
                sự kiện cuối cùng {
                        thăm dò = "pci_proc_init%return"
                        hành động = "dấu vết"
                }
        }
  }


Việc theo dõi thời gian khởi động này cũng hỗ trợ các tham số kernel ftrace thông qua boot
config.
Ví dụ: các tham số kernel sau::

trace_options=sym-addr trace_event=initcall:* tp_printk trace_buf_size=1M ftrace=function ftrace_filter="vfs*"

Điều này có thể được viết trong cấu hình khởi động như bên dưới ::

hạt nhân {
        trace_options = sym-addr
        trace_event = "initcall:*"
        tp_printk
        trace_buf_size = 1M
        ftrace = chức năng
        ftrace_filter = "vfs*"
  }

Lưu ý rằng các tham số bắt đầu bằng tiền tố "kernel" thay vì "ftrace".