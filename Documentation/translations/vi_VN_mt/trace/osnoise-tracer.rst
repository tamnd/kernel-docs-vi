.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/osnoise-tracer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Máy theo dõi OSNOISE
==============

Trong bối cảnh điện toán hiệu năng cao (HPC), Hệ điều hành
Tiếng ồn (ZZ0000ZZ) đề cập đến sự can thiệp mà ứng dụng gặp phải
do các hoạt động bên trong hệ điều hành. Trong bối cảnh của Linux,
NMI, IRQ, SoftIRQ và bất kỳ luồng hệ thống nào khác có thể gây nhiễu cho
hệ thống. Hơn nữa, các công việc liên quan đến phần cứng cũng có thể gây ra tiếng ồn, ví dụ như
thông qua SMI.

hwlat_Detector là một trong những công cụ được sử dụng để xác định những vấn đề phức tạp nhất
nguồn tiếng ồn: ZZ0000ZZ.

Tóm lại, hwlat_Detector tạo một luồng chạy
định kỳ trong một khoảng thời gian nhất định. Vào đầu một thời kỳ, sợi chỉ
vô hiệu hóa ngắt và bắt đầu lấy mẫu. Trong khi chạy, hwlatd
thread đọc thời gian trong một vòng lặp. Khi các ngắt bị vô hiệu hóa, các luồng,
IRQ và SoftIRQ không thể can thiệp vào luồng hwlatd. Do đó,
nguyên nhân của bất kỳ khoảng cách nào giữa hai lần đọc gốc thời gian khác nhau trên
NMI hoặc trong chính phần cứng. Vào cuối giai đoạn, hwlatd kích hoạt
làm gián đoạn và báo cáo khoảng cách quan sát tối đa giữa các lần đọc. Nó cũng
in bộ đếm lần xuất hiện NMI. Nếu đầu ra không báo cáo NMI
thực thi, người dùng có thể kết luận rằng phần cứng là thủ phạm gây ra
độ trễ. Hwlat phát hiện việc thực thi NMI bằng cách quan sát
lối vào và lối ra của NMI.

Trình theo dõi tiếng ồn tận dụng hwlat_Detector bằng cách chạy một
vòng lặp tương tự với quyền ưu tiên, SoftIRQ và IRQ được bật, do đó cho phép
tất cả các nguồn của ZZ0000ZZ trong quá trình thực thi. Sử dụng cùng một cách tiếp cận
của hwlat, osnoise lưu ý điểm vào và ra của bất kỳ
nguồn gây nhiễu, tăng bộ đếm nhiễu trên mỗi CPU. các
Bộ theo dõi tiếng ồn cũng lưu lại bộ đếm nhiễu cho từng nguồn
sự can thiệp. Bộ đếm nhiễu cho NMI, IRQ, SoftIRQ và
các luồng được tăng lên bất cứ lúc nào công cụ quan sát mục nhập của các nhiễu này
sự kiện. Khi có tiếng ồn xảy ra mà không có sự can thiệp nào từ hoạt động
cấp độ hệ thống, bộ đếm tiếng ồn phần cứng tăng lên, trỏ tới một
tiếng ồn liên quan đến phần cứng. Bằng cách này, osnoise có thể giải thích bất kỳ
nguồn gây nhiễu. Vào cuối thời kỳ, máy theo dõi tiếng ồn
in tổng của tất cả tiếng ồn, tiếng ồn đơn tối đa, tỷ lệ phần trăm của CPU
có sẵn cho luồng và bộ đếm cho các nguồn nhiễu.

Cách sử dụng
-----

Viết văn bản ASCII "osnoise" vào tệp current_tracer của
hệ thống theo dõi (thường được gắn tại /sys/kernel/tracing).

Ví dụ::

[root@f32 ~]# cd /sys/kernel/tracing/
        [truy tìm root@f32] nhiễu # echo > current_tracer

Có thể theo dõi dấu vết bằng cách đọc tệp dấu vết::

[truy tìm root@f32]Dấu vết # cat
        # tracer: tiếng ồn
        #
        #                                _-----=> tắt irqs
        # / _---=> cần được chỉnh sửa lại
        # | / _---=> hardirq/softirq
        # || / _--=> MAX có độ sâu ưu tiên
        # || / Bộ đếm nhiễu SINGLE:
        # ||||               RUNTIME NOISE % CỦA CPU NOISE +-----------------------------+
        #           ZZ0013ZZ-ZZ0014ZZ CPU# ||||   TIMESTAMP TẠI MỸ TẠI MỸ AVAILABLE TẠI MỸ HW NMI IRQ SIRQ THREAD
        #              ZZ0022ZZ ZZ0001ZZ||ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ |
                   <...>-859 [000] .... 81.637220: 1000000 190 99.98100 9 18 0 1007 18 1
                   <...>-860 [001] .... 81.638154: 1000000 656 99.93440 74 23 0 1006 16 3
                   <...>-861 [002] .... 81.638193: 1000000 5675 99.43250 202 6 0 1013 25 21
                   <...>-862 [003] .... 81.638242: 1000000 125 99.98750 45 1 0 1011 23 0
                   <...>-863 [004] .... 81.638260: 1000000 1721 99.82790 168 7 0 1002 49 41
                   <...>-864 [005] .... 81.638286: 1000000 263 99.97370 57 6 0 1006 26 2
                   <...>-865 [006] .... 81.638302: 1000000 109 99.98910 21 3 0 1006 18 1
                   <...>-866 [007] .... 81.638326: 1000000 7816 99.21840 107 8 0 1016 39 19

Ngoài các trường theo dõi thông thường (từ TASK-PID đến TIMESTAMP),
tracer in một thông báo vào cuối mỗi giai đoạn cho mỗi CPU
chạy một osnoise/ thread. Báo cáo các trường cụ thể về osnoise:

- RUNTIME TẠI Hoa Kỳ báo cáo lượng thời gian tính bằng micro giây
   chuỗi osnoise tiếp tục lặp lại việc đọc thời gian.
 - NOISE IN US báo cáo tổng lượng nhiễu tính bằng micro giây được quan sát
   bởi bộ theo dõi tiếng ồn trong thời gian chạy liên quan.
 - % OF CPU AVAILABLE báo cáo tỷ lệ phần trăm CPU có sẵn cho
   luồng osnoise trong cửa sổ thời gian chạy.
 - MAX SINGLE NOISE TẠI Mỹ báo cáo tiếng ồn đơn tối đa quan sát được
   trong cửa sổ thời gian chạy.
 - Bộ đếm nhiễu hiển thị số lượng mỗi bộ đếm tương ứng
   sự can thiệp đã xảy ra trong cửa sổ thời gian chạy.

Lưu ý rằng ví dụ trên cho thấy số lượng lớn mẫu tiếng ồn CTNH.
Lý do là mẫu này được lấy trên máy ảo,
và sự can thiệp của máy chủ được phát hiện là sự can thiệp của phần cứng.

Cấu hình theo dõi
--------------------

Trình theo dõi có một tập hợp các tùy chọn bên trong thư mục osnoise, đó là:

- osnoise/cpus: CPU mà tại đó luồng osnoise sẽ thực thi.
 - osnoise/ Period_us: chu kỳ của thread osnoise.
 - osnoise/runtime_us: một luồng osnoise sẽ tìm kiếm tiếng ồn trong bao lâu.
 - osnoise/stop_tracing_us: dừng việc theo dõi hệ thống nếu có một tiếng ồn
   cao hơn giá trị được cấu hình sẽ xảy ra. Viết 0 vô hiệu hóa điều này
   tùy chọn.
 - osnoise/stop_tracing_total_us: dừng quá trình dò tìm hệ thống nếu có tổng nhiễu
   cao hơn giá trị được cấu hình sẽ xảy ra. Viết 0 vô hiệu hóa điều này
   tùy chọn.
 - tracing_threshold: giá trị delta tối thiểu giữa hai lần đọc là
   được coi là tiếng ồn, trong chúng ta. Khi được đặt thành 0, giá trị mặc định sẽ
   được sử dụng, hiện tại là 1 us.
 - osnoise/options: một tập hợp các tùy chọn bật/tắt có thể được bật bởi
   ghi tên tùy chọn vào tệp hoặc bị vô hiệu hóa bằng cách viết tùy chọn
   tên có tiền tố 'NO\_' đứng trước. Ví dụ, viết
   NO_OSNOISE_WORKLOAD vô hiệu hóa tùy chọn OSNOISE_WORKLOAD. các
   tùy chọn DEAFAULTS đặc biệt sẽ đặt lại tất cả các tùy chọn về giá trị mặc định.

Tùy chọn theo dõi
--------------

Tệp osnoise/options hiển thị một tập hợp các tùy chọn cấu hình bật/tắt cho
máy theo dõi tiếng ồn. Các tùy chọn này là:

- DEFAULTS: reset các tùy chọn về giá trị mặc định.
 - OSNOISE_WORKLOAD: không gửi khối lượng công việc gây nhiễu (xem phần chuyên dụng
   phần bên dưới).
 - PANIC_ON_STOP: gọi hoảng loạn() nếu dấu vết dừng lại. Tùy chọn này phục vụ cho
   chụp một vmcore.
 - OSNOISE_PREEMPT_DISABLE: vô hiệu hóa quyền ưu tiên trong khi chạy osnoise
   khối lượng công việc, chỉ cho phép IRQ và tiếng ồn liên quan đến phần cứng.
 - OSNOISE_IRQ_DISABLE: tắt IRQ trong khi chạy khối lượng công việc nhiễu,
   chỉ cho phép NMI và tiếng ồn liên quan đến phần cứng, như hwlat tracer.

Truy tìm bổ sung
------------------

Ngoài bộ theo dõi, một tập hợp các điểm theo dõi đã được thêm vào
tạo điều kiện thuận lợi cho việc xác định nguồn nhiễu.

- osnoise:sample_threshold: được in bất cứ khi nào có tiếng ồn cao hơn
   dung sai có thể định cấu hình_ns.
 - osnoise:nmi_noise: tiếng ồn từ NMI, bao gồm cả thời lượng.
 - osnoise:irq_noise: tiếng ồn từ IRQ, bao gồm cả thời lượng.
 - osnoise:softirq_noise: nhiễu từ SoftIRQ, bao gồm cả
   thời lượng.
 - osnoise:thread_noise: tiếng ồn từ một luồng, bao gồm cả thời lượng.

Lưu ý rằng tất cả các giá trị là ZZ0000ZZ. Ví dụ: nếu trong khi osnoise
đang chạy, một luồng khác chiếm ưu thế trước luồng osnoise, nó sẽ bắt đầu một luồng
thời lượng thread_noise khi bắt đầu. Sau đó, một IRQ diễn ra, chiếm ưu thế
thread_noise, bắt đầu một irq_noise. Khi IRQ kết thúc quá trình thực thi,
nó sẽ tính toán thời lượng của nó và thời lượng này sẽ được trừ vào
thread_noise, theo cách tránh tính toán kép của
Thực thi IRQ. Logic này đúng cho tất cả các nguồn nhiễu.

Đây là một ví dụ về việc sử dụng các điểm theo dõi này::

osnoise/8-961 [008] d.h.  5789.857532: irq_noise: local_timer:236 bắt đầu 5789.857529929 thời lượng 1845 ns
       osnoise/8-961 [008] dNh.  5789.858408: irq_noise: local_timer:236 bắt đầu 5789.858404871 thời lượng 2848 ns
     di chuyển/8-54 [008] d... 5789.858413: thread_noise: di chuyển/8:54 bắt đầu 5789.858409300 thời lượng 3068 ns
       osnoise/8-961 [008] .... 5789.858413: sample_threshold: bắt đầu 5789.858404555 thời lượng 8812 ns nhiễu 2

Trong ví dụ này, một mẫu nhiễu 8 micro giây đã được báo cáo trong lần cuối cùng.
đường thẳng, chỉ ra hai điểm giao thoa. Nhìn lại dấu vết,
hai mục trước nói về luồng di chuyển chạy sau một
thực thi bộ đếm thời gian IRQ. Sự kiện đầu tiên không phải là một phần của tiếng ồn vì
nó diễn ra một phần nghìn giây trước đó.

Điều đáng chú ý là tổng thời lượng được báo cáo trong
tracepoints nhỏ hơn 8 chúng tôi đã báo cáo trong sample_threshold.
Lý do bắt nguồn từ chi phí của mã vào và ra xảy ra
trước và sau khi thực hiện bất kỳ sự can thiệp nào. Điều này biện minh cho sự kép
cách tiếp cận: đo chủ đề và truy tìm.

Chạy bộ theo dõi osnoise mà không cần khối lượng công việc
---------------------------------------

Bằng cách bật trình theo dõi tiếng ồn với bộ tùy chọn NO_OSNOISE_WORKLOAD,
osnoise: tracepoint dùng để đo thời gian thực hiện của
bất kỳ loại tác vụ Linux nào, không bị can thiệp bởi các tác vụ khác.
