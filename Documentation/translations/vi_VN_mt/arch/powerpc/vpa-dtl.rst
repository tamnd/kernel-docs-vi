.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/vpa-dtl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _vpa-dtl:

======================================
DTL (Nhật ký theo dõi công văn)
===================================

Athira Rajeev, ngày 19 tháng 4 năm 2025

.. contents::
    :depth: 3


Tổng quan cơ bản
==============

Các máy Phân vùng logic bộ xử lý dùng chung (SPLPAR) pseries có thể
truy xuất nhật ký gửi đi và các sự kiện ưu tiên từ trình ảo hóa
sử dụng dữ liệu từ bộ đệm Disptach Trace Log(DTL). Với thông tin này,
người dùng có thể truy xuất thời điểm và lý do mỗi lần gửi và ưu tiên xảy ra.
Vpa-dtl PMU hiển thị bộ đếm DTL của Vùng xử lý ảo (VPA)
thông qua sự hoàn hảo.

Cơ sở hạ tầng được sử dụng
===================

Bộ đếm VPA DTL PMU không làm gián đoạn khi tràn hoặc tạo ra bất kỳ
PMI ngắt. Do đó, hrtimer được sử dụng để thăm dò dữ liệu DTL. Đồng hồ bấm giờ
nterval có thể được người dùng cung cấp thông qua trường sample_ Period tính bằng nano giây.
vpa dtl pmu có một giờ được thêm vào mỗi luồng vpa-dtl pmu. DTL (Công văn
Nhật ký theo dõi) chứa thông tin về việc gửi đi/ưu tiên, thời gian xếp hàng, v.v.
Chúng tôi sao chép trực tiếp dữ liệu bộ đệm DTL như một phần của bộ đệm phụ và nó
sẽ được xử lý sau. Điều này sẽ tránh được thời gian thực hiện để tạo mẫu
trong không gian hạt nhân. Trình điều khiển PMU thu thập Nhật ký theo dõi công văn (DTL)
các mục sử dụng hỗ trợ AUX trong cơ sở hạ tầng hoàn hảo. Về mặt công cụ,
dữ liệu này được cung cấp dưới dạng bản ghi PERF_RECORD_AUXTRACE.

Để tương quan từng mục nhập DTL với các sự kiện khác trên CPU, hãy sử dụng auxtrace_queue
được tạo cho mỗi CPU. Mỗi hàng đợi auxtrace có một mảng/danh sách các bộ đệm auxtrace.
Tất cả các hàng đợi auxtrace được duy trì trong đống auxtrace. Các hàng đợi được sắp xếp
dựa trên dấu thời gian. Khi các bản ghi PERF_RECORD_XX khác nhau được xử lý,
so sánh dấu thời gian của bản ghi hoàn hảo với dấu thời gian của phần tử trên cùng trong
auxtrace heap để các sự kiện DTL có thể liên kết với các sự kiện khác
Xử lý hàng đợi auxtrace nếu dấu thời gian của phần tử từ heap là
thấp hơn dấu thời gian từ mục nhập trong bản ghi hiệu suất. Đôi khi điều đó có thể xảy ra
một bộ đệm chỉ được xử lý một phần. nếu dấu thời gian xảy ra của
một sự kiện khác nhiều hơn phần tử hiện đang được xử lý trong hàng đợi, nó sẽ
chuyển sang bản ghi hoàn hảo tiếp theo. Vì vậy hãy theo dõi vị trí của bộ đệm để tiếp tục
xử lý lần sau. Cập nhật dấu thời gian của vùng auxtrace bằng dấu thời gian
của mục được xử lý cuối cùng từ bộ đệm auxtrace.

Cơ sở hạ tầng này đảm bảo các mục nhật ký theo dõi công văn có thể tương quan với nhau
và trình bày cùng với các sự kiện khác như lịch trình.

Ví dụ sử dụng vpa-dtl PMU
=========================

.. code-block:: sh

  # ls /sys/devices/vpa_dtl/
  events  format  perf_event_mux_interval_ms  power  subsystem  type  uevent


Để thu thập dữ liệu DTL bằng bản ghi hoàn hảo:
.. code-block:: sh

  # ./perf record -a -e sched:\*,vpa_dtl/dtl_all/ -c 1000000000 sleep 1

Kết quả có thể được diễn giải bằng cách sử dụng bản ghi perf. Đoạn báo cáo hiệu suất -D

.. code-block:: sh

  # ./perf report -D

Có các bản ghi PERF_RECORD_XX khác nhau. Trong đó hồ sơ tương ứng với
bộ đệm auxtrace bao gồm:

1. PERF_RECORD_AUX
   Truyền đạt rằng dữ liệu mới có sẵn trong khu vực AUX

2. PERF_RECORD_AUXTRACE_INFO
   Mô tả độ lệch và kích thước của dữ liệu auxtrace trong bộ đệm

3. PERF_RECORD_AUXTRACE
   Đây là bản ghi xác định dữ liệu auxtrace ở đây trong trường hợp
   vpa-dtl pmu đang gửi dữ liệu nhật ký theo dõi.

Đoạn trích từ báo cáo hoàn hảo -D hiển thị kết xuất PERF_RECORD_AUXTRACE

.. code-block:: sh

0 0 0x39b10 [0x30]: Kích thước PERF_RECORD_AUXTRACE: 0x690 offset: 0 ref: 0 idx: 0 tid: -1 cpu: 0
.
. ... VPA DTL PMU data: size 1680 bytes, entries is 35
.  00000000: boot_tb: 21349649546353231, tb_freq: 512000000
.  00000030: công văn_reason:ngắt giảm dần, preempt_reason:H_CEDE, enqueue_to_dispatch_time:7064,ready_to_enqueue_time:187, wait_to_ready_time:6611773
.  00000060: công văn_reason:chuông cửa riêng, preempt_reason:H_CEDE, enqueue_to_dispatch_time:146,ready_to_enqueue_time:0, wait_to_ready_time:15359437
.  00000090: công văn_reason:ngắt giảm dần, preempt_reason:H_CEDE, enqueue_to_dispatch_time:4868,ready_to_enqueue_time:232, wait_to_ready_time:5100709
.  000000c0: công văn_reason:chuông cửa riêng, preempt_reason:H_CEDE, enqueue_to_dispatch_time:179,ready_to_enqueue_time:0, wait_to_ready_time:30714243
.  000000f0: công văn_reason:chuông cửa riêng, preempt_reason:H_CEDE, enqueue_to_dispatch_time:197,ready_to_enqueue_time:0, wait_to_ready_time:15350648
.  00000120: công văn_reason:chuông cửa riêng, preempt_reason:H_CEDE, enqueue_to_dispatch_time:213,ready_to_enqueue_time:0, wait_to_ready_time:15353446
.  00000150: công văn_reason:chuông cửa riêng, preempt_reason:H_CEDE, enqueue_to_dispatch_time:212,ready_to_enqueue_time:0, wait_to_ready_time:15355126
.  00000180: công văn_reason:ngắt giảm dần, preempt_reason:H_CEDE, enqueue_to_dispatch_time:6368,ready_to_enqueue_time:164, wait_to_ready_time:5104665

Trên đây là phần trình bày của mục nhập dtl có định dạng bên dưới:

cấu trúc dtl_entry {
        u8      dispatch_reason;
        u8 preempt_reason;
        u16 bộ xử lý_id;
        u32 enqueue_to_dispatch_time;
        u32 sẵn sàng_to_enqueue_time;
        u32 wait_to_ready_time;
        cơ sở thời gian u64;
        lỗi u64_addr;
        u64 srr0;
        u64 srr1;

};

Hai trường đầu tiên thể hiện lý do gửi đi và lý do ưu tiên. bài đăng
việc xử lý các bản ghi PERF_RECORD_AUXTRACE sẽ chuyển thành dữ liệu có ý nghĩa
để người dùng tiêu thụ.

Trực quan hóa các mục nhật ký theo dõi công văn bằng báo cáo hiệu suất
=========================================================

.. code-block:: sh

  # ./perf record -a -e sched:*,vpa_dtl/dtl_all/ -c 1000000000 sleep 1
  [ perf record: Woken up 1 times to write data ]
  [ perf record: Captured and wrote 0.300 MB perf.data ]

  # ./perf report
  # Samples: 321  of event 'vpa-dtl'
  # Event count (approx.): 321
  #
  # Children      Self  Command  Shared Object      Symbol
  # ........  ........  .......  .................  ..............................
  #
     100.00%   100.00%  swapper  [kernel.kallsyms]  [k] plpar_hcall_norets_notrace

Trực quan hóa các mục nhật ký theo dõi công văn bằng tập lệnh hoàn hảo
=========================================================

.. code-block:: sh

   # ./perf script
     migration/9      67 [009] 105373.359903:                     sched:sched_waking: comm=perf pid=13418 prio=120 target_cpu=009
     migration/9      67 [009] 105373.359904:               sched:sched_migrate_task: comm=perf pid=13418 prio=120 orig_cpu=9 dest_cpu=10
     migration/9      67 [009] 105373.359907:               sched:sched_stat_runtime: comm=migration/9 pid=67 runtime=4050 [ns]
     migration/9      67 [009] 105373.359908:                     sched:sched_switch: prev_comm=migration/9 prev_pid=67 prev_prio=0 prev_state=S ==> next_comm=swapper/9 next_pid=0 next_prio=120
            :256     256 [016] 105373.359913:                                vpa-dtl: timebase: 21403600706628832 dispatch_reason:decrementer interrupt, preempt_reason:H_CEDE, enqueue_to_dispatch_time:4854,                        ready_to_enqueue_time:139, waiting_to_ready_time:511842115 c0000000000fcd28 plpar_hcall_norets_notrace+0x18 ([kernel.kallsyms])
            :256     256 [017] 105373.360012:                                vpa-dtl: timebase: 21403600706679454 dispatch_reason:priv doorbell, preempt_reason:H_CEDE, enqueue_to_dispatch_time:236,                         ready_to_enqueue_time:0, waiting_to_ready_time:133864583 c0000000000fcd28 plpar_hcall_norets_notrace+0x18 ([kernel.kallsyms])
            perf   13418 [010] 105373.360048:               sched:sched_stat_runtime: comm=perf pid=13418 runtime=139748 [ns]
            perf   13418 [010] 105373.360052:                     sched:sched_waking: comm=migration/10 pid=72 prio=0 target_cpu=010