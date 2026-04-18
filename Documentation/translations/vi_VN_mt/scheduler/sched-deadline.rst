.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-deadline.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Lập kế hoạch nhiệm vụ thời hạn
==============================

.. CONTENTS

    0. WARNING
    1. Overview
    2. Scheduling algorithm
      2.1 Main algorithm
      2.2 Bandwidth reclaiming
    3. Scheduling Real-Time Tasks
      3.1 Definitions
      3.2 Schedulability Analysis for Uniprocessor Systems
      3.3 Schedulability Analysis for Multiprocessor Systems
      3.4 Relationship with SCHED_DEADLINE Parameters
    4. Bandwidth management
      4.1 System-wide settings
      4.2 Task interface
      4.3 Default behavior
      4.4 Behavior of sched_yield()
    5. Tasks CPU affinity
      5.1 Using cgroup v1 cpuset controller
      5.2 Using cgroup v2 cpuset controller
    6. Future plans
    A. Test suite
    B. Minimal main()


0. WARNING
==========

Việc thay đổi các cài đặt này có thể dẫn đến kết quả không thể đoán trước hoặc thậm chí không ổn định.
 hành vi hệ thống. Đối với việc lập lịch -rt (nhóm), giả định rằng người dùng root
 biết họ đang làm gì.


1. Tổng quan
===========

Chính sách SCHED_DEADLINE có trong lớp lập kế hoạch sched_dl là
 về cơ bản là triển khai lập kế hoạch Thời hạn sớm nhất trước tiên (EDF)
 thuật toán, được tăng cường với một cơ chế (được gọi là Máy chủ băng thông không đổi, CBS)
 điều đó giúp có thể tách biệt hành vi của các nhiệm vụ với nhau.


2. Thuật toán lập kế hoạch
=======================

2.1 Thuật toán chính
------------------

SCHED_DEADLINE [18] sử dụng ba tham số, được đặt tên là "thời gian chạy", "thời gian" và
 "thời hạn", để sắp xếp nhiệm vụ. Một tác vụ SCHED_DEADLINE sẽ nhận được
 "thời gian chạy" micro giây của thời gian thực hiện mỗi micro giây "thời gian" và
 những micro giây "thời gian chạy" này có sẵn trong micro giây "thời hạn"
 từ đầu kỳ.  Để thực hiện hành vi này,
 mỗi khi tác vụ thức dậy, người lập lịch sẽ tính toán "thời hạn lập lịch"
 phù hợp với bảo đảm (sử dụng thuật toán CBS[2,3]). Khi đó nhiệm vụ là
 được lên lịch bằng cách sử dụng EDF[1] vào những thời hạn lập lịch này (nhiệm vụ với
 thời hạn lập kế hoạch sớm nhất được chọn để thực hiện). Lưu ý rằng
 nhiệm vụ thực sự nhận được đơn vị thời gian "thời gian chạy" trong "thời hạn" nếu thích hợp
 Chiến lược "kiểm soát truy cập" (xem Phần "4. Quản lý băng thông") được sử dụng
 (rõ ràng, nếu hệ thống bị quá tải thì lời đảm bảo này không thể được tôn trọng).

Tóm lại, thuật toán CBS[2,3] ấn định thời hạn lập kế hoạch cho các nhiệm vụ sao cho
 rằng mỗi tác vụ chạy tối đa trong thời gian chạy của nó trong mỗi khoảng thời gian, tránh bất kỳ
 nhiễu giữa các tác vụ khác nhau (cách ly băng thông), trong khi EDF[1]
 Thuật toán chọn nhiệm vụ có thời hạn lập kế hoạch sớm nhất làm nhiệm vụ
 sẽ được thực hiện tiếp theo. Nhờ tính năng này, những công việc không tuân thủ nghiêm ngặt
 với mô hình nhiệm vụ thời gian thực "truyền thống" (xem Phần 3) có thể
 sử dụng chính sách mới.

Chi tiết hơn, thuật toán CBS chỉ định thời hạn lập kế hoạch cho
 nhiệm vụ theo cách sau:

- Mỗi tác vụ SCHED_DEADLINE được đặc trưng bởi "thời gian chạy",
    các tham số "thời hạn" và "thời gian";

- Trạng thái của nhiệm vụ được mô tả bằng “thời hạn lập kế hoạch” và
    một "thời gian chạy còn lại". Hai tham số này ban đầu được đặt thành 0;

- Khi tác vụ SCHED_DEADLINE thức dậy (sẵn sàng thực thi),
    bộ lập lịch kiểm tra xem::

thời gian chạy còn lại
        ---------------------------------- > ---------
        thời hạn lập kế hoạch - khoảng thời gian hiện tại

sau đó, nếu thời hạn lập kế hoạch nhỏ hơn thời gian hiện tại, hoặc
    điều kiện này đã được xác minh, thời hạn lập kế hoạch và
    thời gian chạy còn lại được khởi tạo lại dưới dạng

thời hạn lập kế hoạch = thời gian hiện tại + thời hạn
         thời gian chạy còn lại = thời gian chạy

nếu không thì thời hạn lập kế hoạch và thời gian chạy còn lại là
    không thay đổi;

- Khi tác vụ SCHED_DEADLINE thực thi trong khoảng thời gian t, nó
    thời gian chạy còn lại giảm khi::

thời gian chạy còn lại = thời gian chạy còn lại - t

(về mặt kỹ thuật, thời gian chạy sẽ giảm ở mỗi tích tắc hoặc khi
    nhiệm vụ được hủy lịch/được ưu tiên);

- Khi thời gian chạy còn lại nhỏ hơn hoặc bằng 0, tác vụ sẽ được thực hiện
    được cho là "cạn kiệt" (còn được gọi là "cạn kiệt" trong văn học thời gian thực)
    và không thể được lên lịch cho đến thời hạn lập lịch của nó. Việc “bổ sung
    time" cho tác vụ này (xem mục tiếp theo) được đặt bằng với thời gian hiện tại
    giá trị thời hạn lập kế hoạch;

- Khi thời gian hiện tại bằng thời gian bổ sung của một
    nhiệm vụ được điều chỉnh, thời hạn lập kế hoạch và thời gian chạy còn lại là
    được cập nhật dưới dạng::

thời hạn lập kế hoạch = thời hạn lập kế hoạch + thời gian
         thời gian chạy còn lại = thời gian chạy còn lại + thời gian chạy

Cờ SCHED_FLAG_DL_OVERRUN trong trường sched_flags của sched_attr cho phép thực hiện một tác vụ
 để được thông báo về việc vượt quá thời gian chạy thông qua việc phân phối SIGXCPU
 tín hiệu.


2.2 Thu hồi băng thông
------------------------

Việc thu hồi băng thông cho các tác vụ đúng thời hạn dựa trên GRUB (Greedy
 Thuật toán Reclaim of Unused Bandwidth) [15, 16, 17] và đã được kích hoạt
 khi cờ SCHED_FLAG_RECLAIM được đặt.

Sơ đồ sau minh họa tên trạng thái của các tác vụ được xử lý bởi GRUB::

------------
                 (d) ZZ0000ZZ
              ------------->ZZ0001ZZ
              ZZ0002ZZ Tranh Tài |
              |              ------------
              ZZ0003ZZ
          ---------- ZZ0004ZZ
         ZZ0005ZZ ZZ0006ZZ
         ZZ0007ZZ ZZ0008ZZ (một)
         ZZ0009ZZ ZZ0010ZZ
          ---------- ZZ0011ZZ
              A |      V.
              |              ------------
              ZZ0012ZZ Hoạt động |
              --------------ZZ0013ZZ
                 (c) ZZ0014ZZ
                             ------------

Một tác vụ có thể ở một trong các trạng thái sau:

- ActiveContending: nếu nó đã sẵn sàng để thực thi (hoặc đang thực thi);

- ActiveNonContending: nếu vừa bị chặn và chưa vượt qua mức 0-lag
    thời gian;

- Không hoạt động: nếu bị chặn và đã vượt quá thời gian 0 lag.

Các chuyển đổi trạng thái:

(a) Khi một tác vụ bị chặn, nó sẽ không trở nên không hoạt động ngay lập tức vì nó
      băng thông không thể được lấy lại ngay lập tức mà không phá vỡ
      đảm bảo thời gian thực. Do đó nó đi vào trạng thái chuyển tiếp gọi là
      ActiveNonContending. Bộ lập lịch kích hoạt "bộ hẹn giờ không hoạt động" để kích hoạt
      thời gian trễ 0, khi băng thông của tác vụ có thể được lấy lại mà không cần
      phá vỡ các đảm bảo thời gian thực.

Thời gian trễ 0 cho một tác vụ chuyển sang trạng thái ActiveNonContending là
      được tính như sau::

(thời gian chạy * dl_thời gian)
             thời hạn - ---------------------
                             dl_runtime

trong đó thời gian chạy là thời gian chạy còn lại, trong khi dl_runtime và dl_ Period
      là các tham số đặt trước.

(b) Nếu tác vụ thức dậy trước khi bộ hẹn giờ không hoạt động kích hoạt, tác vụ sẽ được thực hiện lại
      trạng thái ActiveContending và "bộ hẹn giờ không hoạt động" bị hủy.
      Ngoài ra, nếu tác vụ bắt đầu ở một hàng đợi khác thì
      việc sử dụng nhiệm vụ phải được loại bỏ khỏi hoạt động của runqueue trước đó
      việc sử dụng và phải được thêm vào việc sử dụng hoạt động của runqueue mới.
      Để tránh các cuộc chạy đua giữa một nhiệm vụ bị đánh thức trong hàng chờ trong khi
      "bộ hẹn giờ không hoạt động" đang chạy trên một CPU khác, "dl_non_contending"
      cờ được sử dụng để chỉ ra rằng một tác vụ không nằm trong hàng đợi nhưng đang hoạt động
      (vì vậy, cờ được đặt khi nhiệm vụ chặn và bị xóa khi
      "bộ hẹn giờ không hoạt động" kích hoạt hoặc khi tác vụ thức dậy).

(c) Khi "bộ hẹn giờ không hoạt động" kích hoạt, tác vụ sẽ chuyển sang trạng thái Không hoạt động và
      việc sử dụng nó bị loại bỏ khỏi việc sử dụng hoạt động của runqueue.

(d) Khi một tác vụ không hoạt động thức dậy, nó sẽ chuyển sang trạng thái ActiveContending và
      việc sử dụng nó được thêm vào việc sử dụng tích cực của runqueue trong đó
      nó đã được xếp hàng đợi.

Đối với mỗi runqueue, thuật toán GRUB theo dõi hai băng thông khác nhau:

- Băng thông hoạt động (running_bw): đây là tổng băng thông của tất cả
    nhiệm vụ ở trạng thái hoạt động (tức là ActiveContending hoặc ActiveNonContending);

- Tổng băng thông (this_bw): đây là tổng của tất cả các tác vụ “thuộc về”
    runqueue, bao gồm cả các tác vụ ở trạng thái Không hoạt động.

- Băng thông tối đa có thể sử dụng (max_bw): Đây là băng thông tối đa có thể sử dụng bởi
    nhiệm vụ đúng thời hạn và hiện được đặt thành công suất RT.


Thuật toán lấy lại băng thông của các tác vụ ở trạng thái Không hoạt động.
 Nó làm như vậy bằng cách giảm thời gian chạy của tác vụ đang thực thi Ti với tốc độ bằng
 để

dq = -(max{ Ui, (Umax - Uinact - Uextra) } / Umax) dt

Ở đâu:

- Ui là băng thông của tác vụ Ti;
  - Umax là mức sử dụng tối đa có thể thu hồi được (tuân theo điều tiết RT
    giới hạn);
  - Uinact là mức sử dụng không hoạt động (trên mỗi hàng đợi), được tính bằng
    (this_bq - Running_bw);
  - Uextra là mức sử dụng có thể thu hồi thêm (trên mỗi runqueue)
    (tuân theo giới hạn điều tiết RT).


Bây giờ chúng ta hãy xem một ví dụ đơn giản về hai nhiệm vụ có thời hạn bằng nhau
 đến 4 và chu kỳ bằng 8 (tức là băng thông bằng 0,5)::

Nhiệm vụ T1
         |
         ZZ0000ZZ
         ZZ0001ZZ
         ZZ0002ZZ----
         ZZ0003ZZ V
         ZZ0004ZZ---ZZ0005ZZ---ZZ0006ZZ---ZZ0007ZZ---|--------->t
         0 1 2 3 4 5 6 7 8


Nhiệm vụ T2
         |
         ZZ0000ZZ
         ZZ0001ZZ
         ZZ0002ZZ
         ZZ0003ZZ V
         ZZ0004ZZ---ZZ0005ZZ---ZZ0006ZZ---ZZ0007ZZ---|--------->t
         0 1 2 3 4 5 6 7 8


Một_bw đang chạy
         |
       1 ------------------ ------
         ZZ0000ZZ |
      0,5- -----------------
         ZZ0001ZZ
         ZZ0002ZZ---ZZ0003ZZ---ZZ0004ZZ---ZZ0005ZZ---|--------->t
         0 1 2 3 4 5 6 7 8


- Thời điểm t=0:

Cả hai tác vụ đều sẵn sàng để thực thi và do đó ở trạng thái ActiveContending.
    Giả sử Nhiệm vụ T1 là nhiệm vụ đầu tiên bắt đầu thực thi.
    Vì không có tác vụ nào không hoạt động nên thời gian chạy của nó giảm xuống dq = -1 dt.

- Thời gian t=2:

Giả sử rằng nhiệm vụ T1 chặn
    Do đó, nhiệm vụ T1 chuyển sang trạng thái ActiveNonContending. Vì nó còn lại
    thời gian chạy bằng 2, thời gian trễ 0 của nó bằng t = 4.
    Nhiệm vụ T2 bắt đầu thực thi, với thời gian chạy vẫn giảm do dq = -1 dt kể từ
    không có nhiệm vụ không hoạt động.

- Thời điểm t=4:

Đây là thời gian trễ 0 cho Nhiệm vụ T1. Vì nó không thức dậy trong
    trong khi đó, nó chuyển sang trạng thái Không hoạt động. Băng thông của nó bị loại bỏ khỏi
    đang chạy_bw.
    Nhiệm vụ T2 tiếp tục thực hiện. Tuy nhiên, thời gian chạy của nó bây giờ đã giảm đi do
    dq = - 0,5 dt vì Uinact = 0,5.
    Do đó, Nhiệm vụ T2 lấy lại băng thông mà Nhiệm vụ T1 chưa sử dụng.

- Thời điểm t=8:

Nhiệm vụ T1 thức dậy. Nó lại chuyển sang trạng thái ActiveContending và
    Running_bw được tăng lên.


2.3 Lập kế hoạch nhận biết năng lượng
---------------------------

Khi bộ điều chỉnh lịch trình của cpufreq được chọn, SCHED_DEADLINE sẽ thực hiện
 Thuật toán GRUB-PA [19], giảm tần số hoạt động của CPU xuống mức tối thiểu
 giá trị mà vẫn cho phép đáp ứng thời hạn. Hành vi này hiện đang
 chỉ được triển khai cho kiến trúc ARM.

Phải đặc biệt cẩn thận trong trường hợp thời gian cần thiết để thay đổi tần số
 có cùng thứ tự về độ lớn của thời gian bảo lưu. Trong những trường hợp như vậy,
 việc đặt tần số CPU cố định sẽ giúp giảm thời hạn trễ hơn.


3. Lên lịch các tác vụ theo thời gian thực
=============================



 ..  BIG FAT WARNING ******************************************************

 .. warning::

   This section contains a (not-thorough) summary on classical deadline
   scheduling theory, and how it applies to SCHED_DEADLINE.
   The reader can "safely" skip to Section 4 if only interested in seeing
   how the scheduling policy can be used. Anyway, we strongly recommend
   to come back here and continue reading (once the urge for testing is
   satisfied :P) to be sure of fully understanding all technical details.

 .. ************************************************************************

Không có giới hạn về loại nhiệm vụ nào có thể khai thác tính năng mới này
 lập kế hoạch kỷ luật, ngay cả khi phải nói rằng điều đó đặc biệt
 phù hợp cho các nhiệm vụ thời gian thực định kỳ hoặc lẻ tẻ cần sự đảm bảo về
 hành vi định thời, ví dụ: đa phương tiện, phát trực tuyến, ứng dụng điều khiển, v.v.

3.1 Định nghĩa
------------------------

Một tác vụ thời gian thực điển hình bao gồm sự lặp lại của các giai đoạn tính toán
 (các trường hợp nhiệm vụ hoặc công việc) được kích hoạt định kỳ hoặc lẻ tẻ
 thời trang.
 Mỗi công việc J_j (trong đó J_j là công việc thứ j của nhiệm vụ) được đặc trưng bởi một
 thời gian đến r_j (thời điểm công việc bắt đầu), khối lượng tính toán
 thời gian c_j cần thiết để hoàn thành công việc và thời hạn tuyệt đối của công việc d_j, trong đó
 là thời gian mà công việc phải được hoàn thành. Việc thực hiện tối đa
 time max{c_j} được gọi là "Thời gian thực thi trường hợp xấu nhất" (WCET) cho tác vụ.
 Một tác vụ thời gian thực có thể tuần hoàn với chu kỳ P nếu r_{j+1} = r_j + P, hoặc
 lẻ tẻ với thời gian giữa các lần đến tối thiểu P là r_{j+1} >= r_j + P. Cuối cùng,
 d_j = r_j + D, trong đó D là thời hạn tương đối của nhiệm vụ.
 Tóm lại, một tác vụ thời gian thực có thể được mô tả như sau:

Nhiệm vụ = (WCET, D, P)

Việc sử dụng một tác vụ thời gian thực được định nghĩa là tỷ lệ giữa
 WCET và khoảng thời gian của nó (hoặc thời gian giữa các lần đến tối thiểu) và đại diện cho
 phần thời gian CPU cần thiết để thực hiện nhiệm vụ.

Nếu tổng mức sử dụng U=sum(WCET_i/P_i) lớn hơn M (với M bằng
 vào số lượng CPU), thì bộ lập lịch không thể đáp ứng tất cả
 thời hạn.
 Lưu ý rằng tổng mức sử dụng được định nghĩa là tổng số lần sử dụng
 WCET_i/P_i trên tất cả các tác vụ thời gian thực trong hệ thống. Khi xem xét
 nhiều tác vụ thời gian thực, các tham số của tác vụ thứ i được chỉ định
 với hậu tố "_i".
 Hơn nữa, nếu tổng mức sử dụng lớn hơn M thì chúng ta có nguy cơ chết đói
 nhiệm vụ phi thời gian thực bằng các nhiệm vụ thời gian thực.
 Thay vào đó, nếu tổng mức sử dụng nhỏ hơn M thì không có thời gian thực
 nhiệm vụ sẽ không bị bỏ đói và hệ thống có thể tôn trọng tất cả
 thời hạn.
 Trên thực tế, trong trường hợp này có thể đưa ra giới hạn trên
 đối với độ trễ (được định nghĩa là mức tối đa giữa 0 và chênh lệch
 giữa thời điểm hoàn thành công việc và thời hạn tuyệt đối của công việc đó).
 Chính xác hơn, có thể chứng minh rằng việc sử dụng bộ lập lịch EDF toàn cầu
 độ trễ tối đa của mỗi nhiệm vụ nhỏ hơn hoặc bằng

((M − 1) · WCET_max − WCET_min)/(M − (M − 2) · U_max) + WCET_max

trong đó WCET_max = max{WCET_i} là WCET tối đa, WCET_min=min{WCET_i}
 là WCET tối thiểu và U_max = max{WCET_i/P_i} là mức tối đa
 sử dụng [12].

3.2 Phân tích khả năng lập lịch cho các hệ thống đơn xử lý
----------------------------------------------------

Nếu M=1 (hệ thống đơn bộ xử lý), hoặc trong trường hợp lập lịch phân vùng (mỗi
 nhiệm vụ thời gian thực được gán tĩnh cho một và chỉ một CPU), đó là
 có thể kiểm tra chính thức xem tất cả các thời hạn có được tôn trọng hay không.
 Nếu D_i = P_i cho tất cả nhiệm vụ thì EDF có thể tôn trọng tất cả thời hạn
 của tất cả các tác vụ thực thi trên CPU khi và chỉ khi tổng mức sử dụng
 trong số các tác vụ chạy trên CPU đó nhỏ hơn hoặc bằng 1.
 Nếu D_i != P_i cho một số tác vụ thì có thể xác định mật độ của
 một nhiệm vụ như WCET_i/min{D_i,P_i} và EDF có thể tôn trọng mọi thời hạn
 của tất cả các tác vụ đang chạy trên CPU nếu tổng mật độ của các tác vụ
 chạy trên CPU như vậy nhỏ hơn hoặc bằng 1:

tổng(WCET_i / phút{D_i, P_i}) <= 1

Điều quan trọng cần lưu ý là điều kiện này chỉ đủ chứ không phải
 cần thiết: có những nhóm nhiệm vụ có thể lập kế hoạch nhưng không tôn trọng
 điều kiện. Ví dụ: hãy xem xét tập tác vụ {Task_1,Task_2} được tạo bởi
 Nhiệm vụ_1=(50ms,50ms,100ms) và Nhiệm vụ_2=(10ms,100ms,100ms).
 EDF rõ ràng có thể lên lịch cho hai nhiệm vụ mà không bỏ lỡ bất kỳ thời hạn nào
 (Nhiệm vụ_1 được lên lịch ngay khi nó được phát hành và kết thúc đúng lúc
 tôn trọng thời hạn của nó; Nhiệm vụ_2 được lên lịch ngay sau Nhiệm vụ_1, do đó
 thời gian phản hồi của nó không thể lớn hơn 50ms + 10ms = 60ms) ngay cả khi

50/phút{50.100} + 10/phút{100, 100} = 50/50 + 10/100 = 1,1

Tất nhiên có thể kiểm tra khả năng lập kế hoạch chính xác của các nhiệm vụ với
 D_i != P_i (kiểm tra một điều kiện vừa đủ vừa cần),
 nhưng điều này không thể thực hiện được bằng cách so sánh tổng mức sử dụng hoặc mật độ với
 một hằng số. Thay vào đó, có thể sử dụng phương pháp được gọi là "nhu cầu bộ xử lý",
 tính toán tổng lượng thời gian CPU h(t) cần thiết cho tất cả các nhiệm vụ để
 tôn trọng tất cả các thời hạn của họ trong một khoảng thời gian có kích thước t và so sánh
 một thời điểm như vậy với kích thước khoảng t. Nếu h(t) nhỏ hơn t (nghĩa là
 lượng thời gian cần thiết cho các nhiệm vụ trong khoảng thời gian có kích thước t là
 nhỏ hơn kích thước của khoảng) với tất cả các giá trị có thể có của t, thì
 EDF có thể lên lịch các nhiệm vụ theo đúng thời hạn của chúng. Kể từ khi
 việc thực hiện việc kiểm tra này với tất cả các giá trị có thể có của t là không thể, nó đã được thực hiện
 đã chứng minh[4,5,6] rằng việc thực hiện kiểm tra các giá trị của t là đủ
 trong khoảng từ 0 đến giá trị tối đa L. Các tài liệu được trích dẫn chứa tất cả các
 chi tiết toán học và giải thích cách tính h(t) và L.
 Trong mọi trường hợp, loại phân tích này quá phức tạp và quá
 tốn nhiều thời gian khi thực hiện trực tuyến. Do đó, như đã giải thích ở phần
 4 Linux sử dụng bài kiểm tra đầu vào dựa trên mức độ sử dụng của nhiệm vụ.

3.3 Phân tích khả năng lập lịch cho các hệ thống đa bộ xử lý
------------------------------------------------------

Trên các hệ thống đa bộ xử lý có lập lịch EDF toàn cầu (không phân vùng
 hệ thống), một bài kiểm tra đầy đủ về khả năng lập kế hoạch không thể dựa trên
 mức độ sử dụng hoặc mật độ: có thể chỉ ra rằng ngay cả khi nhiệm vụ D_i = P_i
 các bộ có mức sử dụng lớn hơn 1 một chút có thể bị trễ thời hạn bất kể
 về số lượng CPU.

Hãy xem xét một tập hợp {Task_1,...Task_{M+1}} gồm M+1 tác vụ trên hệ thống có M
 CPU, với nhiệm vụ đầu tiên Task_1=(P,P,P) có thời gian, thời hạn tương đối
 và WCET bằng P. M nhiệm vụ còn lại Task_i=(e,P-1,P-1) có
 thời gian thực hiện trường hợp xấu nhất nhỏ tùy ý (được biểu thị là "e" ở đây) và
 thời gian nhỏ hơn thời gian của nhiệm vụ đầu tiên. Vì vậy, nếu tất cả các nhiệm vụ
 kích hoạt cùng lúc t, EDF toàn cầu lên lịch cho M tác vụ này trước
 (vì thời hạn tuyệt đối của chúng bằng t + P - 1 nên chúng là
 nhỏ hơn thời hạn tuyệt đối của Nhiệm vụ_1, là t + P). Như một
 kết quả là Nhiệm vụ_1 chỉ có thể được lên lịch vào thời điểm t + e và sẽ kết thúc vào lúc
 thời điểm t + e + P, sau thời hạn tuyệt đối của nó. Tổng mức sử dụng của
 tập nhiệm vụ là U = M · e / (P - 1) + P / P = M · e / (P - 1) + 1, và dành cho nhỏ
 giá trị của e giá trị này có thể trở nên rất gần với 1. Giá trị này được gọi là "Dhall's
 hiệu ứng”[7]. Lưu ý: ví dụ trong bài báo gốc của Dhall đã được
 ở đây được đơn giản hóa một chút (ví dụ, Dhall tính toán chính xác hơn
 lim_{e->0}U).

Các thử nghiệm về khả năng lập kế hoạch phức tạp hơn cho EDF toàn cầu đã được phát triển trong
 văn học thời gian thực[8,9], nhưng chúng không dựa trên sự so sánh đơn giản
 giữa tổng mức sử dụng (hoặc mật độ) và một hằng số cố định. Nếu mọi nhiệm vụ
 có D_i = P_i, điều kiện lập lịch đủ có thể được biểu thị bằng
 một cách đơn giản:

tổng(WCET_i / P_i) <= M - (M - 1) · U_max

trong đó U_max = max{WCET_i / P_i[10]. Lưu ý rằng với U_max = 1,
 M - (M - 1) · U_max trở thành M - M + 1 = 1 và điều kiện lập lịch trình này
 vừa xác nhận tác dụng của Dhall. Một cuộc khảo sát đầy đủ hơn về văn học
 về các bài kiểm tra khả năng lập lịch để lập lịch theo thời gian thực của nhiều bộ xử lý có thể
 tìm thấy trong [11].

Như đã thấy, việc ép buộc tổng mức sử dụng nhỏ hơn M không
 đảm bảo rằng EDF toàn cầu lên lịch cho các nhiệm vụ mà không bỏ lỡ bất kỳ thời hạn nào
 (nói cách khác, EDF toàn cầu không phải là thuật toán lập lịch tối ưu). Tuy nhiên,
 tổng mức sử dụng nhỏ hơn M là đủ để đảm bảo rằng không có thời gian thực
 các nhiệm vụ không bị bỏ đói và độ trễ của các nhiệm vụ theo thời gian thực chiếm ưu thế hơn
 ràng buộc[12] (như đã lưu ý trước đó). Các giới hạn khác nhau về độ trễ tối đa
 trải nghiệm bởi các nhiệm vụ thời gian thực đã được phát triển trong nhiều bài báo khác nhau [13,14],
 nhưng kết quả lý thuyết quan trọng đối với SCHED_DEADLINE là nếu
 tổng mức sử dụng nhỏ hơn hoặc bằng M thì thời gian đáp ứng của
 các nhiệm vụ bị hạn chế.

3.4 Mối quan hệ với các thông số SCHED_DEADLINE
-----------------------------------------------

Cuối cùng, điều quan trọng là phải hiểu mối quan hệ giữa
 Các tham số lập kế hoạch SCHED_DEADLINE được mô tả trong Phần 2 (thời gian chạy,
 thời hạn và thời gian) và các tham số nhiệm vụ thời gian thực (WCET, D, P)
 được mô tả trong phần này. Lưu ý rằng các ràng buộc về thời gian của nhiệm vụ là
 được biểu thị bằng thời hạn tuyệt đối d_j = r_j + D được mô tả ở trên, trong khi
 SCHED_DEADLINE lên lịch các nhiệm vụ theo thời hạn lập kế hoạch (xem
 Mục 2).
 Nếu bài kiểm tra đầu vào được sử dụng để đảm bảo rằng thời hạn lập kế hoạch
 được tôn trọng thì SCHED_DEADLINE có thể được sử dụng để lên lịch các tác vụ theo thời gian thực
 đảm bảo rằng mọi thời hạn của công việc đều được tôn trọng.
 Để thực hiện việc này, một tác vụ phải được lên lịch bằng cách cài đặt:

- thời gian chạy >= WCET
  - thời hạn = D
  - kỳ <= P

IOW, nếu thời gian chạy >= WCET và nếu khoảng thời gian là <= P thì thời hạn lập lịch trình
 và thời hạn tuyệt đối (d_j) trùng nhau, do đó việc kiểm soát nhập học phù hợp
 cho phép tôn trọng thời hạn tuyệt đối của công việc đối với nhiệm vụ này (đây là điều
 được gọi là "thuộc tính lập lịch cứng" và là phần mở rộng của Bổ đề 1 của [2]).
 Lưu ý rằng nếu thời gian chạy> thời hạn, kiểm soát nhập học chắc chắn sẽ từ chối
 nhiệm vụ này, vì không thể tôn trọng những ràng buộc về thời gian của nó.

Tài liệu tham khảo:

1 - C. L. Liu và J. W. Layland. Các thuật toán lập lịch cho đa chương trình-
      hòa nhập trong môi trường thời gian thực khó khăn. Tạp chí của Hiệp hội
      Máy tính, 20(1), 1973.
  2 - L. Abeni, G. Buttazzo. Tích hợp ứng dụng đa phương tiện trong cứng
      Hệ thống thời gian thực. Kỷ yếu của Hệ thống thời gian thực IEEE lần thứ 19
      Hội nghị chuyên đề, 1998. ZZ0000ZZ
  3 - L. Abeni. Cơ chế máy chủ cho các ứng dụng đa phương tiện. Phòng thí nghiệm ReTiS
      Báo cáo kỹ thuật. ZZ0001ZZ
  4 - J. Y. Leung và M.L. Merril. Lưu ý về việc lập kế hoạch ưu tiên
      Nhiệm vụ định kỳ, thời gian thực. Thư xử lý thông tin, tập. 11,
      không. 3, trang 115-118, 1980.
  5 - S. K. Baruah, A. K. Mok và L. E. Rosier. Lên lịch trước
      Các tác vụ lẻ tẻ theo thời gian thực khó trên một bộ xử lý. Thủ tục tố tụng của
      Hội nghị chuyên đề về hệ thống thời gian thực IEEE lần thứ 11, 1990.
  6 - S. K. Baruah, L. E. Rosier và R. R. Howell. Thuật toán và độ phức tạp
      Liên quan đến việc lập kế hoạch ưu tiên cho các nhiệm vụ theo thời gian thực định kỳ trên
      Một bộ xử lý. Tạp chí hệ thống thời gian thực, tập. 4, không. 2, trang 301-324,
      1990.
  7 - S. J. Dhall và C. L. Liu. Về vấn đề lập kế hoạch thời gian thực. Hoạt động
      nghiên cứu, tập. 26, không. 1, trang 127-140, 1978.
  8 - T. Baker. Bộ đa xử lý EDF và khả năng lập kế hoạch đơn điệu thời hạn
      Phân tích. Kỷ yếu của Hội nghị chuyên đề về hệ thống thời gian thực IEEE lần thứ 24, 2003.
  9 - T. Baker. Phân tích khả năng lập lịch EDF trên bộ đa xử lý.
      Giao dịch IEEE trên hệ thống song song và phân tán, tập. 16, không. 8,
      trang 760-768, 2005.
  10 - J. Goossens, S. Funk và S. Baruah, Lập lịch trình theo ưu tiên
       Hệ thống tác vụ định kỳ trên bộ đa xử lý. Tạp chí hệ thống thời gian thực,
       tập. 25, không. 2–3, trang 187–205, 2003.
  11 - R. Davis và A. Burns. Khảo sát về việc lập kế hoạch cứng theo thời gian thực cho
       Hệ thống đa bộ xử lý. Khảo sát máy tính ACM, tập. 43, không. 4, 2011.
       ZZ0002ZZ
  12 - U. C. Devi và J. H. Anderson. Giới hạn độ trễ theo EDF toàn cầu
       Lập lịch trên bộ xử lý đa năng. Tạp chí hệ thống thời gian thực, tập. 32,
       không. 2, trang 133-189, 2008.
  13 - P. Valente và G. Lipari. Giới hạn trên cho độ trễ của sự mềm mại
       Nhiệm vụ thời gian thực được EDF lên lịch trên nhiều bộ xử lý. Thủ tục tố tụng của
       Hội nghị chuyên đề về hệ thống thời gian thực IEEE lần thứ 26, 2005.
  14 - J. Erickson, U. Devi và S. Baruah. Cải thiện giới hạn độ trễ cho
       Toàn cầu EDF. Kỷ yếu của Hội nghị Euromicro lần thứ 22 về
       Hệ thống thời gian thực, 2010.
  15 - G. Lipari, S. Baruah, Tham lam thu hồi băng thông chưa sử dụng ở
       máy chủ băng thông không đổi, Hội nghị Euromicro IEEE lần thứ 12 về thời gian thực
       Hệ thống, 2000.
  16 - L. Abeni, J. Lelli, C. Scordino, L. Palopoli, CPU tham lam đòi lại
       SCHED DEADLINE. Trong Kỷ yếu của Hội thảo Linux thời gian thực (RTLWS),
       Dusseldorf, Đức, 2014.
  17 - L. Abeni, G. Lipari, A. Parri, Y. Sun, Multicore CPU Khai hoang: song song
       hoặc tuần tự?. Trong Kỷ yếu của Hội nghị chuyên đề ACM thường niên lần thứ 31 về ứng dụng
       Máy tính, 2016.
  18 - J. Lelli, C. Scordino, L. Abeni, D. Faggioli, Lập kế hoạch thời hạn trong
       Nhân Linux, Phần mềm: Thực hành và Trải nghiệm, 46(6): 821-839, Tháng 6
       2016.
  19 - C. Scordino, L. Abeni, J. Lelli, Lập kế hoạch thời gian thực nhận biết năng lượng trong
       Nhân Linux, Hội nghị chuyên đề ACM/SIGAPP lần thứ 33 về máy tính ứng dụng (SAC
       2018), Pau, Pháp, tháng 4 năm 2018.


4. Quản lý băng thông
=======================

Như đã đề cập trước đó, để lập kế hoạch -thời hạn được
 hiệu quả và hữu ích (nghĩa là có thể cung cấp các đơn vị thời gian "thời gian chạy"
 trong "thời hạn"), điều quan trọng là phải có một số phương pháp để duy trì việc phân bổ
 phân số thời gian có sẵn của CPU cho các nhiệm vụ khác nhau được kiểm soát.
 Điều này thường được gọi là "kiểm soát đầu vào" và nếu nó không được thực hiện thì
 không có sự đảm bảo nào có thể được đưa ra về lịch trình thực tế của các nhiệm vụ theo thời hạn.

Như đã nêu trong Phần 3, một điều kiện cần thiết phải được tôn trọng để
 lập kế hoạch chính xác cho một tập hợp các nhiệm vụ thời gian thực là tổng mức sử dụng
 nhỏ hơn M. Khi nói về các nhiệm vụ -deadline, điều này đòi hỏi rằng
 tổng tỷ lệ giữa thời gian chạy và thời gian cho tất cả các tác vụ nhỏ hơn
 hơn M. Lưu ý rằng tỷ lệ thời gian chạy/thời gian tương đương với việc sử dụng
 của một nhiệm vụ thời gian thực "truyền thống" và cũng thường được gọi là
 "băng thông".
 Giao diện được sử dụng để kiểm soát băng thông CPU có thể được phân bổ
 các tác vụ tới -deadline tương tự như tác vụ đã được sử dụng cho -rt
 nhiệm vụ lập kế hoạch nhóm theo thời gian thực (còn gọi là điều chỉnh RT - xem
 Documentation/scheduler/sched-rt-group.rst) và dựa trên readable/
 các tệp điều khiển có thể ghi nằm trong Procfs (đối với cài đặt toàn hệ thống).
 Lưu ý rằng cài đặt cho mỗi nhóm (được điều khiển thông qua cgroupfs) vẫn chưa được
 được xác định cho các nhiệm vụ -thời hạn, vì cần thảo luận thêm để
 tìm ra cách chúng tôi muốn quản lý băng thông SCHED_DEADLINE tại nhóm tác vụ
 cấp độ.

Sự khác biệt chính giữa quản lý băng thông theo thời hạn và điều chỉnh RT
 có phải các tác vụ -deadline có băng thông riêng (trong khi các tác vụ -rt thì không!),
 và do đó chúng tôi không cần cơ chế điều tiết cấp cao hơn để thực thi
 băng thông mong muốn. Nói cách khác, điều này có nghĩa là các tham số giao diện được
 chỉ được sử dụng tại thời điểm kiểm soát tiếp nhận (tức là khi người dùng gọi
 lịch_setattr()). Việc lập kế hoạch sau đó được thực hiện có tính đến các nhiệm vụ thực tế'
 tham số, để băng thông CPU được phân bổ cho các tác vụ SCHED_DEADLINE
 tôn trọng nhu cầu của họ về mặt chi tiết. Vì vậy, sử dụng đơn giản này
 giao diện, chúng ta có thể đặt giới hạn cho tổng mức sử dụng các nhiệm vụ -thời hạn (tức là
 \Sum (runtime_i / Period_i) < Global_dl_utilization_cap).

4.1 Cài đặt toàn hệ thống
------------------------

Cài đặt toàn hệ thống được định cấu hình trong hệ thống tệp ảo /proc.

Hiện tại, các nút -rt được sử dụng để kiểm soát thời hạn nhập học và với
 CONFIG_RT_GROUP_SCHED thời gian chạy -deadline được tính vào (root)
 -rt thời gian chạy. Với !CONFIG_RT_GROUP_SCHED, núm chỉ phục vụ cho -dl
 kiểm soát nhập học. Chúng tôi nhận ra rằng điều này không hoàn toàn mong muốn; tuy nhiên, nó
 tốt hơn là bây giờ nên có một giao diện nhỏ và có thể thay đổi nó một cách dễ dàng
 sau này. Tình huống lý tưởng (xem 5.) là chạy các tác vụ -rt từ -deadline
 máy chủ; trong trường hợp đó băng thông -rt là tập con trực tiếp của dl_bw.

Điều này có nghĩa là, đối với một root_domain bao gồm M CPU, các tác vụ -thời hạn
 có thể được tạo trong khi tổng băng thông của chúng vẫn ở mức dưới:

M * (sched_rt_runtime_us / sched_rt_ Period_us)

Cũng có thể vô hiệu hóa logic quản lý băng thông này và
 do đó không được đăng ký quá mức hệ thống ở bất kỳ mức độ tùy ý nào.
 Điều này được thực hiện bằng cách viết -1 vào /proc/sys/kernel/sched_rt_runtime_us.


4.2 Giao diện tác vụ
------------------

Chỉ định một tác vụ định kỳ/không thường xuyên thực hiện trong một lượng thời gian nhất định
 thời gian chạy ở mỗi phiên bản và được lên lịch tùy theo mức độ khẩn cấp của
 nói chung, các ràng buộc về thời gian của nó cần một cách khai báo:

- thời gian thực hiện phiên bản (tối đa/điển hình),
  - khoảng thời gian tối thiểu giữa các lần liên tiếp,
  - một hạn chế về thời gian mà mỗi trường hợp phải được hoàn thành.

Vì thế:

* một cấu trúc sched_attr mới, chứa tất cả các trường cần thiết là
    cung cấp;
  * các cuộc gọi tổng hợp liên quan đến lịch trình mới thao túng nó, tức là,
    sched_setattr() và sched_getattr() được triển khai.

Thời gian chạy còn lại và thời hạn tuyệt đối của tác vụ SCHED_DEADLINE có thể là
 đọc bằng cách sử dụng tòa nhà sched_getattr(), thiết lập tham số tòa nhà cuối cùng
 gắn cờ tới giá trị SCHED_GETATTR_FLAG_DL_DYNAMIC=1. Điều này cập nhật
 thời gian chạy còn lại, chuyển đổi thời hạn tuyệt đối trong tham chiếu CLOCK_MONOTONIC,
 sau đó trả về các tham số này cho không gian người dùng. Thời hạn tuyệt đối là
 được trả về dưới dạng số nano giây kể từ thời điểm CLOCK_MONOTONIC
 tham chiếu (khởi động tức thì), dưới dạng u64 trong trường sched_deadline của sched_attr,
 có thể đại diện cho gần 585 năm kể từ thời điểm khởi động (gọi sched_getattr()
 thay vào đó, với flags=0 sẽ truy xuất các tham số tĩnh).

Với mục đích gỡ lỗi, các tham số này cũng có thể được truy xuất thông qua
 /proc/<pid>/sched (các mục dl.runtime và dl.deadline, cả hai giá trị đều tính bằng ns),
 nhưng: điều này rất kém hiệu quả; thời gian chạy trả về còn lại không được cập nhật dưới dạng
 được thực hiện bởi sched_getattr(); thời hạn được cung cấp trong kernel rq_clock time
 tài liệu tham khảo, không thể sử dụng trực tiếp từ không gian người dùng.


4.3 Hành vi mặc định
---------------------

Giá trị mặc định cho băng thông SCHED_DEADLINE là có rt_runtime bằng
 950000. Với rt_ Period bằng 1000000, theo mặc định, điều đó có nghĩa là -deadline
 các tác vụ có thể sử dụng tối đa 95%, nhân với số lượng CPU tạo nên
 root_domain, cho mỗi root_domain.
 Điều này có nghĩa là các nhiệm vụ không có thời hạn sẽ nhận được ít nhất 5% thời gian CPU,
 và các tác vụ -deadline đó sẽ nhận được thời gian chạy với thời gian bảo đảm
 độ trễ trong trường hợp xấu nhất liên quan đến tham số "thời hạn". Nếu "thời hạn" = "thời gian"
 và cơ chế cpuset được sử dụng để thực hiện lập kế hoạch phân vùng (xem
 Phần 5), thì cài đặt quản lý băng thông đơn giản này có thể
 đảm bảo chắc chắn rằng các tác vụ -deadline sẽ nhận được thời gian chạy của chúng
 trong một thời kỳ.

Cuối cùng, lưu ý rằng để không gây nguy hiểm cho việc kiểm soát nhập học,
 -thời hạn nhiệm vụ không thể phân nhánh.


4.4 Hành vi của sched_yield()
-----------------------------

Khi một tác vụ SCHED_DEADLINE gọi sched_yield(), nó sẽ từ bỏ
 thời gian chạy còn lại và được điều chỉnh ngay lập tức cho đến lần tiếp theo
 khoảng thời gian, khi thời gian chạy của nó sẽ được bổ sung (một lá cờ đặc biệt
 dl_yielded được đặt và sử dụng để xử lý điều chỉnh và thời gian chạy chính xác
 bổ sung sau cuộc gọi tới sched_yield()).

Hành vi này của sched_yield() cho phép tác vụ thức dậy chính xác vào lúc
 đầu kỳ tiếp theo. Ngoài ra, điều này có thể hữu ích trong
 tương lai với cơ chế thu hồi băng thông, trong đó sched_yield() sẽ
 cung cấp thời gian chạy còn lại để người khác thu hồi
 Nhiệm vụ SCHED_DEADLINE.


5. Nhiệm vụ có quan hệ CPU
=====================

Nhiệm vụ thời hạn không thể có mặt nạ đồng dạng cpu nhỏ hơn tên miền gốc mà chúng
 được tạo trên. Vì vậy, sử dụng ZZ0002ZZ sẽ không hiệu quả. Thay vào đó,
 nhiệm vụ thời hạn phải được tạo trong miền gốc bị hạn chế. Đây có thể là
 được thực hiện bằng bộ điều khiển cpuset của cgroup v1 (không dùng nữa) hoặc cgroup v2.
 Xem ZZ0000ZZ và
 ZZ0001ZZ để biết thêm thông tin.

5.1 Sử dụng bộ điều khiển cpuset cgroup v1
-------------------------------------

Một ví dụ về cấu hình đơn giản (ghim tác vụ -deadline vào CPU0) như sau::

mkdir/dev/cpuset
   mount -t cgroup -o cpuset cpuset /dev/cpuset
   cd /dev/cpuset
   mkdir cpu0
   echo 0 > cpu0/cpuset.cpus
   echo 0 > cpu0/cpuset.mems
   echo 1 > cpuset.cpu_exclusive
   echo 0 > cpuset.sched_load_balance
   echo 1 > cpu0/cpuset.cpu_exclusive
   echo 1 > cpu0/cpuset.mem_exclusive
   echo $$ > cpu0/tác vụ
   chrt --sched-runtime 100000 --sched-thời gian 200000 --deadline 0 có > /dev/null

5.2 Sử dụng bộ điều khiển cpuset cgroup v2
-------------------------------------

Giả sử root cgroup v2 được gắn ở ZZ0000ZZ, một ví dụ về
 cấu hình đơn giản (ghim tác vụ -deadline vào CPU0) như sau ::

cd /sys/fs/cgroup
   echo '+cpuset' > cgroup.subtree_control
   mkdir thời hạn_group
   echo 0 > deadline_group/cpuset.cpus
   echo 'root' > deadline_group/cpuset.cpus.partition
   echo $$ > deadline_group/cgroup.procs
   chrt --sched-runtime 100000 --sched-thời gian 200000 --deadline 0 có > /dev/null

6. Kế hoạch tương lai
===============

Vẫn còn thiếu:

- cách lập trình để truy xuất thời gian chạy hiện tại và thời hạn tuyệt đối
  - sàng lọc kế thừa thời hạn, đặc biệt là về khả năng
    duy trì sự cách ly băng thông giữa các tác vụ không tương tác. Đây là
    được nghiên cứu cả về mặt lý luận và thực tiễn,
    hy vọng chúng tôi có thể sớm tạo ra một số mã trình diễn;
  - (c) quản lý băng thông dựa trên nhóm và có thể lập kế hoạch;
  - kiểm soát quyền truy cập cho người dùng không phải root (và các vấn đề bảo mật liên quan đến
    địa chỉ), đây là cách tốt nhất để cho phép sử dụng các cơ chế không có đặc quyền
    và làm cách nào để ngăn chặn người dùng không root "lừa đảo" hệ thống?

Như đã thảo luận, chúng tôi cũng đang có kế hoạch hợp nhất công việc này với EDF
 các bản vá điều chỉnh [ZZ0000ZZ nhưng chúng tôi vẫn đang ở trong
 các giai đoạn sơ bộ của việc hợp nhất và chúng tôi thực sự tìm kiếm phản hồi có thể
 giúp chúng tôi quyết định hướng đi cần thực hiện.

Phụ lục A. Bộ thử nghiệm
======================

Chính sách SCHED_DEADLINE có thể được kiểm tra dễ dàng bằng hai ứng dụng
 là một phần của bộ xác thực Bộ lập lịch Linux rộng hơn. Bộ phần mềm là
 có sẵn dưới dạng kho lưu trữ GitHub: ZZ0000ZZ

Ứng dụng thử nghiệm đầu tiên được gọi là rt-app và có thể được sử dụng để
 bắt đầu nhiều chủ đề với các thông số cụ thể. hỗ trợ ứng dụng rt
 Các chính sách lập kế hoạch SCHED_{OTHER,FIFO,RR,DEADLINE} và các chính sách liên quan
 các tham số (ví dụ: mức độ tốt, mức độ ưu tiên, thời gian chạy/thời hạn/thời gian). ứng dụng rt
 là một công cụ có giá trị vì nó có thể được sử dụng để tái tạo một cách tổng hợp một số
 khối lượng công việc (có thể bắt chước các trường hợp sử dụng thực tế) và đánh giá cách người lập lịch trình
 hoạt động dưới khối lượng công việc như vậy. Bằng cách này, kết quả có thể dễ dàng tái tạo.
 ứng dụng rt có sẵn tại: ZZ0000ZZ

rt-app không chấp nhận đối số dòng lệnh và thay vào đó đọc từ JSON
 tập tin cấu hình. Đây là một ví dụ ZZ0000ZZ:

 .. code-block:: json

  {
    "tasks": {
      "dl_task": {
        "policy": "SCHED_DEADLINE",
        "priority": 0,
        "dl-runtime": 10000,
        "dl-period": 100000,
        "dl-deadline": 100000
      },
      "fifo_task": {
        "policy": "SCHED_FIFO",
        "priority": 10,
        "runtime": 20000,
        "sleep": 130000
      }
    },
    "global": {
      "duration": 5
    }
  }

Khi chạy ZZ0000ZZ, nó tạo ra 2 luồng. Cái đầu tiên,
 được lên lịch bởi SCHED_DEADLINE, thực thi trong 10 mili giây cứ sau 100 mili giây. Cái thứ hai,
 được lên lịch ở mức ưu tiên 10 của SCHED_FIFO, thực thi trong 20 mili giây sau mỗi 150 mili giây. Bài kiểm tra
 sẽ chạy tổng cộng 5 giây.

Vui lòng tham khảo tài liệu rt-app để biết lược đồ JSON và nhiều ví dụ khác.

Ứng dụng thử nghiệm thứ hai được thực hiện bằng chrt có hỗ trợ
 cho SCHED_DEADLINE.

Việc sử dụng rất đơn giản::

# chrt -d -T 10000000 -D 100000000 0 ./my_cpuhog_app

Với điều này, my_cpuhog_app được đưa vào chạy bên trong khu đặt trước SCHED_DEADLINE
 là 10 mili giây cứ sau 100 mili giây (lưu ý rằng các tham số được biểu thị bằng nano giây).
 Bạn cũng có thể sử dụng chrt để tạo đặt chỗ cho một chương trình đang chạy.
 ứng dụng, vì bạn biết pid của nó ::

# chrt -d -T 10000000 -D 100000000 -p 0 my_app_pid

Phụ lục B. Hàm main() tối thiểu
==========================

Chúng tôi cung cấp những gì theo sau một đoạn mã độc lập đơn giản (xấu xí)
 cho thấy cách đặt chỗ SCHED_DEADLINE có thể được tạo bằng thời gian thực
 nhà phát triển ứng dụng::

#define _GNU_SOURCE
   #include <unistd.h>
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>
   #include <thời gian.h>
   #include <linux/unistd.h>
   #include <linux/kernel.h>
   #include <linux/types.h>
   #include <sys/syscall.h>
   #include <pthread.h>

#define gettid() cuộc gọi tòa nhà(__NR_gettid)

#define SCHED_DEADLINE 6

/* XXX sử dụng số tòa nhà thích hợp */
   #ifdef __x86_64__
   #define __NR_sched_setattr 314
   #define __NR_sched_getattr 315
   #endif

#ifdef __i386__
   #define __NR_sched_setattr 351
   #define __NR_sched_getattr 352
   #endif

#ifdef __cánh tay__
   #define __NR_sched_setattr 380
   #define __NR_sched_getattr 381
   #endif

int biến động tĩnh được thực hiện;

cấu trúc lịch_attr {
	__u32 kích thước;

__u32 lịch_chính sách;
	__u64 lịch_flags;

/* SCHED_NORMAL, SCHED_BATCH */
	__s32 lịch_nice;

/* SCHED_FIFO, SCHED_RR */
	__u32 lịch_priority;

/* SCHED_DEADLINE (nsec) */
	__u64 lịch_runtime;
	__u64 lịch_thời hạn;
	__u64 lịch_thời gian;
   };

int sched_setattr(pid_t pid,
		  const struct sched_attr *attr,
		  cờ int không dấu)
   {
	trả về syscall(__NR_sched_setattr, pid, attr, flags);
   }

int sched_getattr(pid_t pid,
		  cấu trúc sched_attr *attr,
		  kích thước int không dấu,
		  cờ int không dấu)
   {
	trả về syscall(__NR_sched_getattr, pid, attr, size, flags);
   }

làm mất dữ liệu *run_deadline(void *)
   {
	struct sched_attr attr;
	int x = 0;
	int ret;
	cờ int không dấu = 0;

printf("thời hạn chủ đề đã bắt đầu [%ld]\n", gettid());

attr.size = sizeof(attr);
	attr.sched_flags = 0;
	attr.sched_nice = 0;
	attr.sched_priority = 0;

/* Điều này tạo ra một khoảng dự trữ 10ms/30ms */
	attr.sched_policy = SCHED_DEADLINE;
	attr.sched_runtime = 10 * 1000 * 1000;
	attr.sched_ Period = attr.sched_deadline = 30 * 1000 * 1000;

ret = sched_setattr(0, &attr, flags);
	nếu (ret < 0) {
		xong = 0;
		perror("sched_setattr");
		thoát (-1);
	}

trong khi (! xong) {
		x++;
	}

printf("hết thời hạn của luồng [%ld]\n", gettid());
	trả lại NULL;
   }

int chính (int argc, char **argv)
   {
	chủ đề pthread_t;

printf("luồng chính [%ld]\n", gettid());

pthread_create(&thread, NULL, run_deadline, NULL);

ngủ(10);

xong = 1;
	pthread_join(luồng, NULL);

printf("chết chính [%ld]\n", gettid());
	trả về 0;
   }
