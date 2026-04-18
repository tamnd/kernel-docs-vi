.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-rt-group.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Lập lịch nhóm theo thời gian thực
==========================

.. CONTENTS

   0. WARNING
   1. Overview
     1.1 The problem
     1.2 The solution
   2. The interface
     2.1 System-wide settings
     2.2 Default behaviour
     2.3 Basis for grouping tasks
   3. Future plans


0. WARNING
==========

Việc thay đổi các cài đặt này có thể dẫn đến hệ thống không ổn định, các nút bấm bị
 chỉ root và cho rằng root biết mình đang làm gì.

Đáng chú ý nhất:

* các giá trị rất nhỏ trong sched_rt_ Period_us có thể dẫn đến tình trạng không ổn định
   hệ thống khi khoảng thời gian nhỏ hơn thời gian có sẵn
   độ phân giải hoặc thời gian cần thiết để xử lý việc làm mới ngân sách.

* các giá trị rất nhỏ trong sched_rt_runtime_us có thể dẫn đến tình trạng không ổn định
   hệ thống khi thời gian chạy quá nhỏ nên hệ thống gặp khó khăn trong việc thực hiện
   tiến trình chuyển tiếp (NOTE: cả luồng di chuyển và kstopmachine
   là các quá trình thời gian thực).

1. Tổng quan
===========


1.1 Vấn đề
---------------

Lập kế hoạch theo thời gian thực là tất cả về tính quyết định, một nhóm phải có khả năng dựa vào
lượng băng thông (ví dụ: thời gian CPU) không đổi. Để lên lịch
nhiều nhóm nhiệm vụ theo thời gian thực, mỗi nhóm phải được phân công một phần cố định
trong số thời gian CPU có sẵn.  Nếu không có sự đảm bảo tối thiểu, một nhóm thời gian thực có thể
rõ ràng là hụt hẫng. Giới hạn trên mờ sẽ không có tác dụng vì nó không thể
dựa vào. Điều này khiến chúng ta chỉ còn lại một phần cố định duy nhất.

1.2 Giải pháp
----------------

Thời gian CPU được chia bằng cách chỉ định lượng thời gian có thể dành cho việc chạy
trong một khoảng thời gian nhất định. Chúng tôi phân bổ "thời gian chạy" này cho từng nhóm thời gian thực
các nhóm thời gian thực khác sẽ không được phép sử dụng.

Bất kỳ thời gian nào không được phân bổ cho nhóm thời gian thực sẽ được sử dụng để chạy mức độ ưu tiên thông thường
nhiệm vụ (SCHED_OTHER). Bất kỳ thời gian chạy được phân bổ nào không được sử dụng cũng sẽ được chọn bởi
SCHED_OTHER.

Hãy xem xét một ví dụ: trình kết xuất thời gian thực cố định khung phải cung cấp 25
khung hình một giây, mang lại khoảng thời gian 0,04 giây trên mỗi khung hình. Bây giờ nói nó cũng sẽ
phải phát một số bản nhạc và phản hồi đầu vào, để lại khoảng 80% CPU
thời gian dành riêng cho đồ họa. Sau đó chúng tôi có thể cho nhóm này thời gian chạy là 0,8
* 0,04 giây = 0,032 giây.

Bằng cách này, nhóm đồ họa sẽ có khoảng thời gian 0,04 giây với thời gian chạy 0,032 giây
giới hạn. Bây giờ nếu luồng âm thanh cần nạp lại bộ đệm DMA cứ sau 0,005 giây, nhưng
chỉ cần khoảng 3% thời gian CPU để làm như vậy, nó có thể thực hiện với 0,03 * 0,005 giây =
0,00015 giây. Vì vậy, nhóm này có thể được lên lịch với khoảng thời gian 0,005 giây và thời gian chạy
là 0,00015s.

Thời gian CPU còn lại sẽ được sử dụng cho việc nhập dữ liệu của người dùng và các tác vụ khác. Bởi vì
các tác vụ thời gian thực đã phân bổ rõ ràng thời gian CPU mà chúng cần để thực hiện
nhiệm vụ của họ, các lỗi chạy dưới bộ đệm trong đồ họa hoặc âm thanh có thể được loại bỏ.

NOTE: ví dụ trên chưa được triển khai đầy đủ. Chúng tôi vẫn
thiếu bộ lập lịch EDF để tạo ra các khoảng thời gian không đồng nhất có thể sử dụng được.


2. Giao diện
================


2.1 Cài đặt toàn hệ thống
------------------------

Cài đặt toàn hệ thống được định cấu hình trong hệ thống tệp ảo /proc:

/proc/sys/kernel/sched_rt_ Period_us:
  Khoảng thời gian lập kế hoạch tương đương với 100% băng thông CPU.

/proc/sys/kernel/sched_rt_runtime_us:
  Giới hạn toàn cầu về lượng thời gian lập kế hoạch theo thời gian thực có thể sử dụng. Điều này luôn luôn
  nhỏ hơn hoặc bằng khoảng thời gian_us, vì nó biểu thị thời gian được phân bổ từ
  Period_us cho các tác vụ thời gian thực. Nếu không kích hoạt CONFIG_RT_GROUP_SCHED,
  điều này chỉ phục vụ cho việc kiểm soát việc tiếp nhận các nhiệm vụ đúng thời hạn. Với
  CONFIG_RT_GROUP_SCHED=y nó cũng biểu thị tổng băng thông có sẵn cho
  tất cả các nhóm thời gian thực.

* Thời gian được chỉ định trong chúng tôi vì giao diện là s32. Điều này mang lại một
    phạm vi hoạt động từ 1us đến khoảng 35 phút.
  * sched_rt_ Period_us nhận các giá trị từ 1 đến INT_MAX.
  * sched_rt_runtime_us nhận các giá trị từ -1 đến sched_rt_ Period_us.
  * Thời gian chạy -1 chỉ định thời gian chạy == khoảng thời gian, tức là. không có giới hạn.
  * sched_rt_runtime_us/sched_rt_ Period_us > 0,05 để bảo toàn
    băng thông cho dl_server công bằng. Để kiểm tra giá trị chính xác trung bình của
    thời gian chạy/thời gian trong /sys/kernel/debug/sched/fair_server/cpuX/


2.2 Hành vi mặc định
---------------------

Các giá trị mặc định cho sched_rt_ Period_us (1000000 hoặc 1 giây) và
sched_rt_runtime_us (950000 hoặc 0,95 giây).  Điều này mang lại 0,05 giây để sử dụng bởi
SCHED_OTHER (nhiệm vụ không phải RT). Những giá trị mặc định này đã được chọn để một cuộc chạy trốn
các tác vụ thời gian thực sẽ không bị khóa máy mà để lại một ít thời gian để phục hồi
nó.  Bằng cách đặt thời gian chạy thành -1, bạn sẽ lấy lại được hành vi cũ.

Theo mặc định, tất cả băng thông được gán cho nhóm gốc và các nhóm mới sẽ nhận được
khoảng thời gian từ /proc/sys/kernel/sched_rt_ Period_us và thời gian chạy là 0. Nếu bạn
muốn gán băng thông cho nhóm khác, giảm băng thông của nhóm gốc
và gán một phần hoặc toàn bộ sự khác biệt cho nhóm khác.

Lập lịch nhóm theo thời gian thực có nghĩa là bạn phải chỉ định một phần trong tổng số CPU
băng thông cho nhóm trước khi nó chấp nhận các tác vụ thời gian thực. Vì vậy bạn sẽ
không thể chạy các tác vụ thời gian thực như bất kỳ người dùng nào khác ngoài root cho đến khi bạn có
thực hiện điều đó, ngay cả khi người dùng có quyền chạy các quy trình với thời gian thực
ưu tiên!


2.3 Cơ sở phân nhóm nhiệm vụ
----------------------------

Kích hoạt CONFIG_RT_GROUP_SCHED cho phép bạn phân bổ rõ ràng
Băng thông CPU cho các nhóm nhiệm vụ.

Điều này sử dụng hệ thống tệp ảo cgroup và "<cgroup>/cpu.rt_runtime_us"
để kiểm soát thời gian CPU dành riêng cho mỗi nhóm điều khiển.

Để biết thêm thông tin về cách làm việc với các nhóm kiểm soát, bạn nên đọc
Documentation/admin-guide/cgroup-v1/cgroups.rst cũng vậy.

Cài đặt nhóm được kiểm tra theo các giới hạn sau để duy trì
có thể lập lịch cấu hình:

\Sum_{i} thời gian chạy_{i} / toàn cầu_thời kỳ <= toàn cầu_runtime / toàn cầu_thời kỳ

Hiện tại, điều này có thể được đơn giản hóa thành những điều sau (nhưng hãy xem các kế hoạch trong tương lai):

\Sum_{i} thời gian chạy_{i} <= toàn cầu_runtime


3. Kế hoạch tương lai
===============

Đang tiến hành công việc để sắp xếp thời gian lập kế hoạch cho mỗi nhóm
("<cgroup>/cpu.rt_ Period_us") cũng có thể định cấu hình được.

Ràng buộc về khoảng thời gian là một nhóm con phải có số nhỏ hơn hoặc
khoảng thời gian bằng với cha mẹ của nó. Nhưng thực tế thì nó không hữu ích lắm _chưa_
vì nó dễ bị đói nếu không có lịch trình thời hạn.

Xét hai nhóm anh chị em A và B; cả hai đều có băng thông 50%, nhưng A
chu kỳ dài gấp đôi chu kỳ B.

* nhóm A: chu kỳ=100000us, thời gian chạy=50000us

- cái này chạy trong 0,05 giây cứ sau 0,1 giây

* nhóm B: chu kỳ= 50000us, thời gian chạy=25000us

- cái này chạy trong 0,025 giây hai lần cứ sau 0,1 giây (hoặc cứ sau 0,05 giây một lần).

Điều này có nghĩa là hiện tại vòng lặp while (1) trong A sẽ chạy trong toàn bộ thời gian
B và có thể bỏ đói nhiệm vụ của B (giả sử chúng có mức độ ưu tiên thấp hơn) trong suốt thời gian
kỳ.

Dự án tiếp theo sẽ là SCHED_EDF (Lập kế hoạch sớm nhất trước tiên) để mang lại
lập kế hoạch thời hạn đầy đủ cho nhân linux. Lập deadline như trên
các nhóm và coi việc kết thúc giai đoạn là thời hạn sẽ đảm bảo rằng cả hai đều
có được thời gian được phân bổ của họ.

Việc triển khai SCHED_EDF có thể mất một thời gian để hoàn thành. Kế thừa ưu tiên là
thách thức lớn nhất khi cơ sở hạ tầng PI linux hiện tại hướng tới
mức độ ưu tiên tĩnh giới hạn 0-99. Với việc lập kế hoạch thời hạn, bạn cần phải
thực hiện kế thừa thời hạn (vì mức độ ưu tiên tỷ lệ nghịch với
thời hạn delta (thời hạn - bây giờ)).

Điều này có nghĩa là toàn bộ máy móc PI sẽ phải được làm lại - và đó là một trong những
những đoạn mã phức tạp nhất mà chúng tôi có.
