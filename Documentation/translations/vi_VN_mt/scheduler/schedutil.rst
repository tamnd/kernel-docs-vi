.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/schedutil.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
lịch trình
=========

.. note::

   All this assumes a linear relation between frequency and work capacity,
   we know this is flawed, but it is the best workable approximation.


PELT (Theo dõi tải trên mỗi thực thể)
===============================

Với PELT, chúng tôi theo dõi một số số liệu trên các thực thể lập lịch khác nhau, từ
nhiệm vụ riêng lẻ cho nhóm nhiệm vụ cắt thành hàng đợi CPU. Là cơ sở cho việc này
chúng tôi sử dụng Đường trung bình động có trọng số theo cấp số nhân (EWMA), mỗi kỳ (1024us)
bị phân rã sao cho y^32 = 0,5. Nghĩa là, đóng góp 32ms gần đây nhất
một nửa, trong khi phần còn lại của lịch sử đóng góp nửa còn lại.

Cụ thể:

ewma_sum(u) := u_0 + u_1*y + u_2*y^2 + ...

ewma(u) = ewma_sum(u) / ewma_sum(1)

Vì đây thực chất là một cấp số của một chuỗi hình học vô hạn, nên
kết quả có thể kết hợp được, tức là ewma(A) + ewma(B) = ewma(A+B). Tài sản này
là chìa khóa, vì nó mang lại khả năng sắp xếp lại mức trung bình khi nhiệm vụ di chuyển
xung quanh.

Lưu ý rằng các tác vụ bị chặn vẫn đóng góp vào tổng hợp (các lát nhóm tác vụ
và hàng đợi CPU), phản ánh sự đóng góp dự kiến của họ khi họ
tiếp tục chạy.

Bằng cách sử dụng tính năng này, chúng tôi theo dõi 2 số liệu chính: 'đang chạy' và 'có thể chạy được'. 'Chạy'
phản ánh thời gian một thực thể dành cho CPU, trong khi 'có thể chạy được' phản ánh
thời gian một thực thể dành cho runqueue. Khi chỉ có một nhiệm vụ duy nhất
hai số liệu giống nhau, nhưng một khi có sự tranh cãi về việc CPU 'đang chạy'
sẽ giảm để phản ánh phần thời gian mà mỗi tác vụ dành cho CPU
trong khi 'có thể chạy được' sẽ tăng lên để phản ánh mức độ tranh chấp.

Để biết thêm chi tiết, xem: kernel/sched/pelt.c


Tần số / CPU Bất biến
==========================

Bởi vì việc tiêu thụ CPU ở mức 50% ở tốc độ 1GHz không giống như việc tiêu thụ CPU
với tốc độ 50% ở tần số 2GHz, việc chạy 50% trên LITTLE CPU cũng không giống như chạy 50% trên
một CPU lớn, chúng tôi cho phép các kiến trúc mở rộng đồng bằng thời gian với hai tỷ lệ, một
Tỷ lệ mở rộng điện áp và tần số động (DVFS) và một tỷ lệ vi mô.

Đối với các kiến trúc DVFS đơn giản (trong đó phần mềm có toàn quyền kiểm soát), chúng tôi thường
tính tỉ số như sau:

f_cur
  r_dvfs := -----
            f_max

Đối với các hệ thống năng động hơn trong đó phần cứng kiểm soát DVFS, chúng tôi sử dụng
bộ đếm phần cứng (Intel APERF/MPERF, ARMv8.4-AMU) để cung cấp cho chúng tôi tỷ lệ này.
Đối với Intel cụ thể, chúng tôi sử dụng::

APERF
  f_cur := ----- * P0
	   MPERF

4C-tăng áp;	nếu có và bật turbo
  f_max := { 1C-turbo;	nếu bật turbo
	     P0;	nếu không thì

f_cur
  r_dvfs := phút( 1, ----- )
                    f_max

Chúng tôi chọn turbo 4C thay vì turbo 1C để làm cho nó bền vững hơn một chút.

r_cpu được xác định là tỷ lệ mức hiệu suất cao nhất của hiện tại
CPU so với mức hiệu suất cao nhất của bất kỳ CPU nào khác trong hệ thống.

r_tot = r_dvfs * r_cpu

Kết quả là các số liệu “đang chạy” và “có thể chạy được” ở trên trở nên bất biến
thuộc loại DVFS và CPU. IOW. chúng ta có thể chuyển và so sánh chúng giữa các CPU.

Để biết thêm chi tiết xem:

- kernel/sched/pelt.h:update_rq_clock_pelt()
 - Arch/x86/kernel/smpboot.c:"Tính toán tỷ lệ tần số APERF/MPERF."
 - Documentation/Scheduler/sched-capacity.rst:"1. CPU Dung lượng + 2. Sử dụng tác vụ"


UTIL_EST
========

Bởi vì các nhiệm vụ định kỳ có điểm trung bình giảm dần khi họ ngủ, thậm chí
mặc dù khi chạy mức sử dụng dự kiến của họ sẽ như nhau, họ phải chịu một
(DVFS) tăng tốc sau khi chạy lại.

Để giảm bớt điều này (tùy chọn được bật mặc định) UTIL_EST điều khiển Infinite
Phản hồi xung (IIR) EWMA với giá trị 'đang chạy' trên dequeue -- khi nó được
cao nhất. Bộ lọc UTIL_EST để tăng ngay lập tức và chỉ phân rã khi giảm.

Tổng rộng hơn nữa của runqueue (của các tác vụ có thể chạy) được duy trì:

util_est := \Sum_t max( t_running, t_util_est_ewma )

Để biết thêm chi tiết, hãy xem: kernel/sched/fair.c:util_est_dequeue()


UCLAMP
======

Có thể đặt các kẹp u_min và u_max hiệu quả trên mỗi tác vụ CFS hoặc RT;
runqueue giữ tổng hợp tối đa các kẹp này cho tất cả các tác vụ đang chạy.

Để biết thêm chi tiết, hãy xem: include/uapi/linux/sched/types.h


Lịch trình / DVFS
================

Mỗi lần theo dõi tải của bộ lập lịch được cập nhật (đánh thức tác vụ, thực hiện tác vụ
di chuyển, tiến trình thời gian), chúng tôi yêu cầu schedutil cập nhật phần cứng
Trạng thái DVFS.

Cơ sở là số liệu 'đang chạy' của CPU runqueue, theo số liệu ở trên thì nó là
ước tính mức sử dụng bất biến tần số của CPU. Từ đó chúng ta tính toán
tần số mong muốn như::

max(đang chạy, util_est );	nếu UTIL_EST
  u_cfs := { đang chạy;			nếu không thì

kẹp( u_cfs + u_rt , u_min, u_max );	nếu UCLAMP_TASK
  u_clamp := { u_cfs + u_rt;				nếu không thì

u := u_clamp + u_irq + u_dl;		[khoảng. xem nguồn để biết thêm chi tiết]

f_des := phút( f_max, 1,25 u * f_max )

XXX IO-wait: khi cập nhật do tác vụ được đánh thức sau khi hoàn thành IO, chúng tôi
tăng 'u' ở trên.

Tần số này sau đó được sử dụng để chọn trạng thái P/OPP hoặc được ghép trực tiếp vào
Yêu cầu kiểu CPPC cho phần cứng.

XXX: nhiệm vụ thời hạn (Mô hình nhiệm vụ lẻ tẻ) cho phép chúng tôi tính toán f_min cứng
cần thiết để đáp ứng khối lượng công việc.

Vì các cuộc gọi lại này được thực hiện trực tiếp từ bộ lập lịch nên phần cứng DVFS
tương tác phải 'nhanh' và không bị chặn. Hỗ trợ lịch trình
yêu cầu DVFS giới hạn tốc độ khi tương tác phần cứng chậm và
đắt tiền, điều này làm giảm hiệu quả.

Để biết thêm thông tin, hãy xem: kernel/sched/cpufreq_schedutil.c


NOTES
=====

- Trong các tình huống tải thấp, trong đó DVFS phù hợp nhất, các số 'đang chạy'
   sẽ phản ánh chặt chẽ việc sử dụng.

- Trong các kịch bản bão hòa, việc di chuyển nhiệm vụ sẽ gây ra một số sụt giảm nhất thời,
   giả sử chúng ta có một CPU bão hòa với 4 tác vụ thì khi chúng ta di chuyển một tác vụ
   đối với CPU không hoạt động, CPU cũ sẽ có giá trị 'đang chạy' là 0,75 trong khi
   CPU mới sẽ tăng 0,25. Điều này là tất yếu và sự tiến triển theo thời gian sẽ
   sửa lỗi này. XXX chúng tôi vẫn đảm bảo f_max do không có thời gian nhàn rỗi phải không?

- Phần lớn nội dung ở trên là nhằm tránh sự sụt giảm của DVFS và các miền DVFS độc lập
   phải học lại/tăng tốc khi tải thay đổi.

