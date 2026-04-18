.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-domains.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Tên miền lập lịch
=================

Mỗi CPU có miền lập kế hoạch "cơ sở" (struct sched_domain). Tên miền
hệ thống phân cấp được xây dựng từ các miền cơ sở này thông qua con trỏ ->parent. ->cha mẹ
MUST sẽ bị chấm dứt NULL và các cấu trúc miền phải theo CPU như hiện tại
được cập nhật không khóa.

Mỗi miền lập kế hoạch trải rộng trên một số CPU (được lưu trữ trong trường ->span).
Khoảng thời gian MUST của một miền là tập hợp lớn hơn khoảng thời gian con của miền đó (hạn chế này có thể
hãy thoải mái nếu có nhu cầu) và miền cơ sở cho CPU i MUST ít nhất phải trải dài
tôi. Tên miền hàng đầu cho mỗi CPU thường sẽ bao trùm tất cả các CPU trong hệ thống
mặc dù thực ra là không cần thiết, nhưng điều này có thể dẫn đến trường hợp một số
CPU sẽ không bao giờ được giao nhiệm vụ để chạy trừ khi mặt nạ được phép của CPU được
được thiết lập một cách rõ ràng. Khoảng thời gian của miền được lập lịch có nghĩa là "cân bằng tải quy trình giữa các
CPU".

Mỗi miền lập lịch phải có một hoặc nhiều nhóm CPU (struct sched_group)
được tổ chức dưới dạng danh sách liên kết một chiều vòng tròn từ các nhóm ->
con trỏ. Sự kết hợp của cpumasks của các nhóm MUST này giống như
phạm vi của tên miền. Nhóm được trỏ tới bởi ->con trỏ nhóm MUST chứa CPU
mà miền đó thuộc về. Các nhóm có thể được chia sẻ giữa các CPU vì chúng chứa
chỉ đọc dữ liệu sau khi chúng đã được thiết lập. Giao điểm của cpumasks từ
bất kỳ hai nhóm nào trong số này có thể không trống. Nếu đúng như vậy thì SD_OVERLAP
cờ được đặt trên miền lập kế hoạch tương ứng và các nhóm của nó có thể không được
được chia sẻ giữa các CPU.

Cân bằng trong một miền được lập lịch xảy ra giữa các nhóm. Tức là mỗi nhóm
được coi là một thực thể. Tải của một nhóm được định nghĩa là tổng của
tải của từng CPU thành viên của nó và chỉ khi tải của một nhóm trở nên
mất cân bằng là các nhiệm vụ được chuyển giao giữa các nhóm.

Trong kernel/sched/core.c, sched_balance_trigger() được chạy định kỳ trên mỗi CPU
thông qua sched_tick(). Nó tăng một softirq sau lịch trình thường xuyên tiếp theo
sự kiện tái cân bằng cho runqueue hiện tại đã đến. Tải thực tế
cân bằng công việc, sched_balance_softirq()->sched_balance_domains(), sau đó được chạy
trong bối cảnh softirq (SCHED_SOFTIRQ).

Hàm sau có hai đối số: runqueue của CPU hiện tại và liệu
CPU không hoạt động vào thời điểm sched_tick() xảy ra và lặp lại tất cả
các miền đã lập lịch mà CPU của chúng tôi đang sử dụng, bắt đầu từ miền cơ sở và đi lên ->cha mẹ
chuỗi. Trong khi thực hiện việc đó, nó sẽ kiểm tra xem miền hiện tại đã hết chưa
khoảng thời gian tái cân bằng. Nếu vậy, nó sẽ chạy sched_balance_rq() trên miền đó. Sau đó nó kiểm tra
sched_domain gốc (nếu nó tồn tại) và cha mẹ của cha mẹ, v.v.
ra.

Ban đầu, sched_balance_rq() tìm nhóm bận rộn nhất trong miền được lập lịch hiện tại.
Nếu thành công, nó sẽ tìm hàng đợi bận rộn nhất trong số tất cả các hàng chạy của CPU trong
nhóm đó. Nếu nó tìm được một runqueue như vậy, nó sẽ khóa cả
Hàng đợi của CPU và hàng đợi bận rộn nhất mới được tìm thấy và bắt đầu chuyển các nhiệm vụ từ nó
đến hàng đợi của chúng tôi. Số lượng nhiệm vụ chính xác dẫn đến sự mất cân bằng trước đây
được tính toán trong khi duyệt qua các nhóm của miền được lập lịch này.

Triển khai các miền theo lịch trình
==========================

Miền "cơ sở" sẽ "trải rộng" cấp độ đầu tiên của hệ thống phân cấp. Trong trường hợp
của SMT, bạn sẽ mở rộng tất cả các anh chị em của CPU vật lý, với mỗi nhóm là
một CPU ảo duy nhất.

Trong SMP, tên miền gốc của miền cơ sở sẽ trải rộng trên tất cả các CPU vật lý trong
nút. Mỗi nhóm là một CPU vật lý duy nhất. Sau đó với NUMA, cha mẹ
của miền SMP sẽ trải rộng trên toàn bộ máy, với mỗi nhóm có
cpumask của một nút. Hoặc, bạn có thể thực hiện NUMA hoặc Opteron đa cấp, chẳng hạn:
có thể chỉ có một miền bao trùm một cấp NUMA của nó.

Người triển khai nên đọc các nhận xét trong include/linux/sched/sd_flags.h:
SD_* để có ý tưởng về các chi tiết cụ thể và nội dung cần điều chỉnh cho cờ SD
của một sched_domain.

Kiến trúc có thể ghi đè trình tạo miền chung và cờ SD mặc định
cho một cấp độ cấu trúc liên kết nhất định bằng cách tạo một mảng sched_domain_topology_level và
gọi set_sched_topology() với mảng này làm tham số.

Cơ sở hạ tầng gỡ lỗi tên miền theo lịch trình có thể được kích hoạt bởi 'sched_verbose'
vào cmdline của bạn. Nếu bạn quên điều chỉnh dòng cmdline của mình, bạn cũng có thể lật
/sys/kernel/debug/sched/verbose núm. Điều này cho phép phân tích cú pháp kiểm tra lỗi của
các miền được lập lịch sẽ phát hiện hầu hết các lỗi có thể xảy ra (được mô tả ở trên). Nó
cũng in ra cấu trúc miền ở định dạng trực quan.
