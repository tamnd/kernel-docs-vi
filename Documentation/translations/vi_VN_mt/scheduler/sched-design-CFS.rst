.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-design-CFS.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _sched_design_CFS:

===============
Bộ lập lịch CFS
===============


1. OVERVIEW
============

CFS là viết tắt của "Bộ lập lịch hoàn toàn công bằng" và là quy trình "máy tính để bàn"
bộ lập lịch do Ingo Molnar triển khai và hợp nhất trong Linux 2.6.23. Khi nào
ban đầu được sáp nhập, nó là sự thay thế cho vanilla trước đó
mã tương tác SCHED_OTHER của bộ lập lịch. Ngày nay, CFS đang nhường chỗ
đối với EEVDF, có thể tìm thấy tài liệu này trong
Tài liệu/lịch trình/sched-eevdf.rst.

80% thiết kế của CFS có thể tóm tắt trong một câu duy nhất: CFS về cơ bản là mô hình
một "CPU đa tác vụ chính xác, lý tưởng" trên phần cứng thực.

"CPU đa tác vụ lý tưởng" là một CPU (không tồn tại :-)) có 100% vật lý
sức mạnh và có thể chạy từng tác vụ ở tốc độ chính xác bằng nhau, song song, mỗi tác vụ ở
1/nr_tốc độ chạy.  Ví dụ: có 2 task đang chạy thì nó chạy
mỗi cái ở mức 50% sức mạnh vật lý --- tức là thực sự song song.

Trên phần cứng thực, chúng ta chỉ có thể chạy một tác vụ duy nhất cùng một lúc, vì vậy chúng ta phải
giới thiệu khái niệm "thời gian chạy ảo".  Thời gian chạy ảo của một tác vụ
chỉ định thời điểm thời gian tiếp theo của nó sẽ bắt đầu thực thi trên lý tưởng
đa tác vụ CPU được mô tả ở trên.  Trong thực tế, thời gian chạy ảo của một tác vụ
thời gian chạy thực tế của nó có được chuẩn hóa thành tổng số tác vụ đang chạy hay không.



2. FEW IMPLEMENTATION DETAILS
==============================

Trong CFS, thời gian chạy ảo được thể hiện và theo dõi thông qua mỗi tác vụ
Giá trị p->se.vruntime (đơn vị nanosec).  Bằng cách này, có thể xác định chính xác
dấu thời gian và đo "thời gian CPU dự kiến" mà một nhiệm vụ đáng lẽ phải nhận được.

Chi tiết nhỏ: trên phần cứng "lý tưởng", mọi tác vụ sẽ giống nhau vào bất kỳ lúc nào
   p->se.vruntime value --- tức là các tác vụ sẽ thực thi đồng thời và không có tác vụ nào
   sẽ bị "mất cân bằng" từ phần thời gian "lý tưởng" của CPU.

Logic chọn nhiệm vụ của CFS dựa trên giá trị p->se.vruntime này và do đó nó là
rất đơn giản: nó luôn cố gắng chạy tác vụ với p->se.vruntime nhỏ nhất
giá trị (tức là tác vụ được thực thi ít nhất cho đến nay).  CFS luôn cố gắng phân chia
tăng thời gian CPU giữa các tác vụ có thể chạy gần bằng "phần cứng đa nhiệm lý tưởng" như
có thể.

Hầu hết phần còn lại của thiết kế CFS đều nằm ngoài ý tưởng thực sự đơn giản này,
với một vài phần tô điểm bổ sung như cấp độ đẹp, đa xử lý và nhiều tiện ích khác nhau
các biến thể thuật toán để nhận biết tà vẹt.



3. THE RBTREE
==============

Thiết kế của CFS khá cấp tiến: nó không sử dụng cấu trúc dữ liệu cũ cho
runqueues, nhưng nó sử dụng rbtree theo thứ tự thời gian để xây dựng một "dòng thời gian" của tương lai
thực thi tác vụ và do đó không có tạo phẩm "chuyển đổi mảng" (theo đó cả
bộ lập lịch vanilla trước đó và RSDL/SD bị ảnh hưởng).

CFS cũng duy trì giá trị rq->cfs.min_vruntime, giá trị này đơn điệu
tăng giá trị theo dõi thời gian chạy nhỏ nhất trong số tất cả các tác vụ trong
runqueue.  Tổng khối lượng công việc được thực hiện bởi hệ thống được theo dõi bằng cách sử dụng
min_vruntime; giá trị đó được sử dụng để đặt các thực thể mới được kích hoạt ở bên trái
bên cây càng nhiều càng tốt.

Tổng số tác vụ đang chạy trong runqueue được tính thông qua
Giá trị rq->cfs.load, là tổng trọng số của các tác vụ được xếp hàng đợi trên
runqueue.

CFS duy trì một rbtree theo thứ tự thời gian, trong đó tất cả các tác vụ có thể chạy được sắp xếp theo
khóa p->se.vruntime. CFS chọn nhiệm vụ "ngoài cùng bên trái" từ cây này và bám vào nó.
Khi hệ thống tiến lên phía trước, các tác vụ đã thực hiện sẽ được đưa vào cây
ngày càng nhiều về bên phải --- chậm rãi nhưng chắc chắn tạo cơ hội cho mọi nhiệm vụ
để trở thành "nhiệm vụ ngoài cùng bên trái" và do đó có được CPU trong phạm vi xác định
lượng thời gian.

Tóm lại, CFS hoạt động như thế này: nó chạy một tác vụ một chút và khi tác vụ đó
lịch trình (hoặc đánh dấu vào lịch trình xảy ra) việc sử dụng CPU của nhiệm vụ được "tính
for": thời gian (nhỏ) mà nó vừa sử dụng CPU vật lý được thêm vào
p->se.vruntime.  Khi p->se.vruntime đủ cao để thực hiện một nhiệm vụ khác
trở thành "nhiệm vụ ngoài cùng bên trái" của rbtree theo thứ tự thời gian mà nó duy trì (cộng với một
một lượng nhỏ khoảng cách "chi tiết" so với tác vụ ngoài cùng bên trái để chúng ta
không lên lịch quá mức cho các tác vụ và dọn sạch bộ đệm), thì tác vụ ngoài cùng bên trái mới là
được chọn và nhiệm vụ hiện tại được ưu tiên.



4. SOME FEATURES CỦA CFS
========================

CFS sử dụng tính toán chi tiết nano giây và không dựa vào bất kỳ sự thay đổi nhanh chóng hoặc
chi tiết HZ khác.  Do đó, bộ lập lịch CFS không có khái niệm về "lát thời gian" trong
theo cách mà bộ lập lịch trước đó đã có và không có bất kỳ phương pháp phỏng đoán nào.  có
chỉ có một điều chỉnh trung tâm:

/sys/kernel/debug/sched/base_slice_ns

có thể được sử dụng để điều chỉnh bộ lập lịch từ "máy tính để bàn" (tức là độ trễ thấp) sang
khối lượng công việc "máy chủ" (tức là phân khối tốt).  Nó mặc định có cài đặt phù hợp
cho khối lượng công việc trên máy tính để bàn.  SCHED_BATCH cũng được xử lý bởi mô-đun lập lịch CFS.

Trong trường hợp CONFIG_HZ cho kết quả base_slice_ns < TICK_NSEC, giá trị của
base_slice_ns sẽ ít hoặc không ảnh hưởng đến khối lượng công việc.

Do thiết kế của nó, bộ lập lịch CFS không dễ bị bất kỳ "cuộc tấn công" nào
tồn tại ngày nay chống lại các phương pháp phỏng đoán của bộ lập lịch chứng khoán: 50p.c, thud.c,
Chew.c, Ring-test.c, Mass_intr.c đều hoạt động tốt và không ảnh hưởng
tương tác và tạo ra hành vi mong đợi.

Bộ lập lịch CFS có khả năng xử lý các cấp độ đẹp mạnh mẽ hơn nhiều và SCHED_BATCH
so với bộ lập lịch chuẩn trước đó: cả hai loại khối lượng công việc đều bị cô lập nhiều
quyết liệt hơn.

Cân bằng tải SMP đã được làm lại/làm sạch: việc chạy hàng đợi
các giả định hiện đã biến mất khỏi mã cân bằng tải và các trình vòng lặp của
module lập kế hoạch được sử dụng.  Mã cân bằng trở nên đơn giản hơn một chút vì
kết quả.



5. Chính sách lập kế hoạch
==========================

CFS thực hiện ba chính sách lập lịch:

- SCHED_NORMAL (theo truyền thống gọi là SCHED_OTHER): Lập kế hoạch
    chính sách được sử dụng cho các nhiệm vụ thông thường.

- SCHED_BATCH: Không chiếm ưu thế thường xuyên như các tác vụ thông thường
    sẽ, do đó cho phép các tác vụ chạy lâu hơn và tận dụng tốt hơn
    bộ nhớ đệm nhưng phải trả giá bằng tính tương tác. Điều này rất phù hợp cho
    công việc hàng loạt.

- SCHED_IDLE: Điều này thậm chí còn yếu hơn cả Nice 19, nhưng nó không đúng
    lập lịch hẹn giờ nhàn rỗi để tránh được ưu tiên
    vấn đề đảo ngược sẽ làm máy bị bế tắc.

SCHED_FIFO/_RR được triển khai trong sched/rt.c và được chỉ định bởi
POSIX.

Lệnh chrt từ util-linux-ng 2.13.1.1 có thể đặt tất cả những thứ này ngoại trừ
SCHED_IDLE.



6. SCHEDULING CLASSES
======================

Bộ lập lịch CFS mới đã được thiết kế theo cách để giới thiệu "Lập lịch
Các lớp", một hệ thống phân cấp có thể mở rộng của các mô-đun lập lịch.  Các mô-đun này
đóng gói các chi tiết chính sách lập lịch và được xử lý bởi lõi lập lịch
không có mã lõi giả định quá nhiều về chúng.

sched/fair.c triển khai bộ lập lịch CFS được mô tả ở trên.

sched/rt.c triển khai ngữ nghĩa SCHED_FIFO và SCHED_RR, theo cách đơn giản hơn
bộ lập lịch vanilla trước đó đã làm.  Nó sử dụng 100 runqueues (cho tất cả 100 RT
mức độ ưu tiên, thay vì 140 trong bộ lập lịch trước đó) và nó không cần
mảng hết hạn.

Các lớp lập kế hoạch được triển khai thông qua cấu trúc sched_class, trong đó
chứa các hook tới các hàm phải được gọi bất cứ khi nào có một sự kiện thú vị
xảy ra.

Đây là danh sách (một phần) của các hook:

- enqueue_task(...)

Được gọi khi một tác vụ chuyển sang trạng thái có thể chạy được.
   Nó đặt thực thể lập kế hoạch (nhiệm vụ) vào cây đỏ đen và
   tăng biến nr_running.

- dequeue_task(...)

Khi một tác vụ không thể chạy được nữa, hàm này được gọi để giữ nguyên
   thực thể lập kế hoạch tương ứng từ cây đỏ đen.  Nó giảm đi
   biến nr_running.

- năng suất_task(...)

Hàm này mang lại CPU bằng cách di chuyển vị trí của tác vụ hiện đang chạy trở lại
   trong runqueue, để các tác vụ có thể chạy khác được lên lịch trước.

- Wakeup_preempt(...)

Hàm này kiểm tra xem một tác vụ đã vào trạng thái có thể chạy được có nên
   ưu tiên tác vụ hiện đang chạy.

- pick_next_task(...)

Hàm này chọn tác vụ thích hợp nhất đủ điều kiện để chạy tiếp theo.

- set_next_task(...)

Hàm này được gọi khi một tác vụ thay đổi lớp lập kế hoạch của nó, thay đổi
   nhóm nhiệm vụ của nó hoặc được lên lịch.

- nhiệm vụ_tick(...)

Hàm này chủ yếu được gọi từ các hàm đánh dấu thời gian; nó có thể dẫn đến
   chuyển đổi quá trình.  Điều này thúc đẩy quyền ưu tiên chạy.




7. GROUP SCHEDULER EXTENSIONS ĐẾN CFS
=====================================

Thông thường, bộ lập lịch hoạt động trên các nhiệm vụ riêng lẻ và cố gắng cung cấp
CPU có thời gian hợp lý cho từng nhiệm vụ.  Đôi khi, có thể nên nhóm các nhiệm vụ và
cung cấp thời gian CPU công bằng cho mỗi nhóm nhiệm vụ như vậy.  Ví dụ, nó có thể là
mong muốn trước tiên là cung cấp thời gian CPU công bằng cho mỗi người dùng trên hệ thống và sau đó
mỗi tác vụ thuộc về một người dùng.

CONFIG_CGROUP_SCHED cố gắng đạt được chính xác điều đó.  Nó cho phép các nhiệm vụ được thực hiện
nhóm và phân chia thời gian CPU một cách công bằng giữa các nhóm như vậy.

CONFIG_RT_GROUP_SCHED cho phép nhóm thời gian thực (ví dụ: SCHED_FIFO và
nhiệm vụ SCHED_RR).

CONFIG_FAIR_GROUP_SCHED cho phép nhóm CFS (tức là SCHED_NORMAL và
nhiệm vụ SCHED_BATCH).

Các tùy chọn này cần phải xác định CONFIG_CGROUPS và cho phép quản trị viên
   tạo các nhóm tác vụ tùy ý, sử dụng hệ thống tệp giả "cgroup".  Xem
   Documentation/admin-guide/cgroup-v1/cgroups.rst để biết thêm thông tin về hệ thống tập tin này.

Khi CONFIG_FAIR_GROUP_SCHED được xác định, tệp "cpu.shares" sẽ được tạo cho mỗi
nhóm được tạo bằng hệ thống tập tin giả.  Xem các bước ví dụ bên dưới để tạo
các nhóm nhiệm vụ và sửa đổi chia sẻ CPU của họ bằng cách sử dụng hệ thống tệp giả "cgroups" ::

# mount -t tmpfs cgroup_root /sys/fs/cgroup
	# mkdir /sys/fs/cgroup/cpu
	# mount -t cgroup -ocpu none /sys/fs/cgroup/cpu
	# cd /sys/fs/cgroup/cpu

# mkdir đa phương tiện Nhóm nhiệm vụ "đa phương tiện" # create
	Trình duyệt # mkdir Nhóm tác vụ "trình duyệt" # create

# #Configure nhóm đa phương tiện để nhận gấp đôi băng thông CPU
	##that của nhóm trình duyệt

# echo 2048 > đa phương tiện/cpu.shares
	# echo 1024 > trình duyệt/cpu.shares

# firefox & # Launch firefox và di chuyển nó vào nhóm "trình duyệt"
	# echo <firefox_pid> > trình duyệt/tác vụ

# #Launch gmplayer (hoặc trình phát phim yêu thích của bạn)
	# echo <movie_player_pid> > đa phương tiện/tác vụ
