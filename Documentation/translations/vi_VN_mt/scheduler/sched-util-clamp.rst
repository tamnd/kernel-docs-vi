.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-util-clamp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Kẹp sử dụng
======================

1. Giới thiệu
===============

Kẹp sử dụng, còn được gọi là kẹp tiện ích hoặc uclamp, là một bộ lập lịch
tính năng cho phép không gian người dùng giúp quản lý yêu cầu hiệu suất
của các nhiệm vụ. Nó được giới thiệu trong phiên bản v5.3. Bộ phận hỗ trợ của CGroup đã được sáp nhập vào
v5.4.

Uclamp là một cơ chế gợi ý cho phép người lập lịch trình hiểu được
yêu cầu thực hiện và hạn chế của các nhiệm vụ, do đó nó giúp
lập kế hoạch để đưa ra quyết định tốt hơn. Và khi thống đốc schedutil cpufreq là
được sử dụng, kẹp util cũng sẽ ảnh hưởng đến việc lựa chọn tần số CPU.

Vì bộ lập lịch và schedutil đều được điều khiển bởi tín hiệu PELT (util_avg),
util kẹp hành động dựa trên điều đó để đạt được mục tiêu bằng cách kẹp tín hiệu ở một mức nhất định
điểm; do đó có tên. Nghĩa là, bằng cách hạn chế việc sử dụng, chúng ta đang tạo ra
hệ thống chạy ở một điểm hiệu suất nhất định.

Cách đúng đắn để xem util kẹp là sử dụng một cơ chế để đưa ra yêu cầu hoặc gợi ý về
hạn chế về hiệu suất. Nó bao gồm hai điều chỉnh:

* UCLAMP_MIN, đặt giới hạn dưới.
        * UCLAMP_MAX, đặt giới hạn trên.

Hai giới hạn này sẽ đảm bảo một tác vụ sẽ hoạt động trong phạm vi hiệu suất này
của hệ thống. UCLAMP_MIN ngụ ý thúc đẩy một nhiệm vụ, trong khi UCLAMP_MAX ngụ ý
giới hạn một nhiệm vụ.

Người ta có thể nói với hệ thống (bộ lập lịch) rằng một số tác vụ yêu cầu thời gian tối thiểu
điểm hiệu suất để hoạt động nhằm mang lại trải nghiệm người dùng mong muốn. Hoặc một
có thể cho hệ thống biết rằng một số nhiệm vụ cũng nên bị hạn chế tiêu thụ
nhiều tài nguyên và không nên vượt quá một điểm hiệu suất cụ thể. Đang xem
các giá trị uclamp như điểm hiệu suất thay vì sử dụng là tốt hơn
trừu tượng từ quan điểm không gian người dùng.

Ví dụ: một trò chơi có thể sử dụng util kẹp để tạo thành một vòng phản hồi với
Số khung hình được cảm nhận mỗi giây (FPS). Nó có thể tự động tăng mức tối thiểu
điểm hiệu suất được yêu cầu bởi đường dẫn hiển thị của nó để đảm bảo không có khung nào bị
bị rơi. Nó cũng có thể tự động 'khởi động' các nhiệm vụ này nếu nó biết trong
Vài trăm mili giây sắp tới, một cảnh tính toán chuyên sâu sắp diễn ra
xảy ra.

Trên phần cứng di động nơi khả năng của các thiết bị thay đổi rất nhiều, điều này
vòng phản hồi động mang lại sự linh hoạt tuyệt vời để đảm bảo trải nghiệm người dùng tốt nhất
dựa trên khả năng của bất kỳ hệ thống nào.

Tất nhiên cũng có thể cấu hình tĩnh. Việc sử dụng chính xác sẽ phụ thuộc
về hệ thống, ứng dụng và kết quả mong muốn.

Một ví dụ khác là trong Android nơi các tác vụ được phân loại ở chế độ nền,
tiền cảnh, ứng dụng trên cùng, v.v. Có thể sử dụng kẹp Util để hạn chế mức độ
các tác vụ nền đang tiêu thụ tài nguyên bằng cách giới hạn điểm hiệu suất mà chúng
có thể chạy vào. Ràng buộc này giúp dự trữ tài nguyên cho các nhiệm vụ quan trọng, như
những ứng dụng thuộc ứng dụng hiện đang hoạt động (nhóm ứng dụng hàng đầu). Bên cạnh này
giúp hạn chế lượng điện năng họ tiêu thụ. Điều này có thể rõ ràng hơn trong
hệ thống không đồng nhất (ví dụ: Arm big.LITTLE); ràng buộc sẽ giúp thiên vị
các tác vụ nền được duy trì trên các lõi nhỏ để đảm bảo rằng:

1. Các lõi lớn có thể tự do chạy các tác vụ ứng dụng hàng đầu ngay lập tức. ứng dụng hàng đầu
           nhiệm vụ là những nhiệm vụ mà người dùng hiện đang tương tác, do đó
           nhiệm vụ quan trọng nhất trong hệ thống.
        2. Chúng không chạy bằng lõi ngốn điện và gây hao pin ngay cả khi chúng
           là những nhiệm vụ chuyên sâu của CPU.

.. note::
  **little cores**:
    CPUs with capacity < 1024

  **big cores**:
    CPUs with capacity = 1024

Bằng cách thực hiện các yêu cầu về hiệu suất uclamp này, hay đúng hơn là gợi ý, không gian người dùng có thể
đảm bảo tài nguyên hệ thống được sử dụng tối ưu để cung cấp cho người dùng tốt nhất có thể
kinh nghiệm.

Một trường hợp sử dụng khác là giúp **khắc phục được vấn đề kế thừa độ trễ tăng cao trong
cách tính toán tín hiệu sử dụng bộ lập lịch**.

Mặt khác, chẳng hạn, một tác vụ bận rộn đòi hỏi phải chạy ở mức tối đa
điểm hiệu suất sẽ chịu độ trễ ~200ms (PELT HALFIFE = 32ms) đối với
lịch trình để nhận ra điều đó. Điều này được biết là ảnh hưởng đến khối lượng công việc như chơi game trên
thiết bị di động nơi khung hình sẽ giảm do thời gian phản hồi chậm để chọn
tần suất cao hơn cần thiết để các nhiệm vụ hoàn thành công việc của họ đúng thời hạn. Cài đặt
UCLAMP_MIN=1024 sẽ đảm bảo những tác vụ như vậy sẽ luôn đạt hiệu suất cao nhất
cấp độ khi họ bắt đầu chạy.

Hiệu ứng nhìn thấy tổng thể vượt xa khả năng cảm nhận của người dùng tốt hơn
kinh nghiệm/hiệu suất và nỗ lực để giúp đạt được kết quả tổng thể tốt hơn
hiệu suất/watt nếu sử dụng hiệu quả.

Không gian người dùng cũng có thể tạo thành một vòng phản hồi với hệ thống con nhiệt để đảm bảo
thiết bị không nóng lên đến mức phải tăng ga.

Cả SCHED_NORMAL/OTHER và SCHED_FIFO/RR đều tôn trọng các yêu cầu/gợi ý uclamp.

Trong trường hợp SCHED_FIFO/RR, uclamp cung cấp tùy chọn chạy các tác vụ RT bất kỳ lúc nào.
điểm hiệu suất thay vì luôn bị ràng buộc với tần số MAX. Cái nào
có thể hữu ích trên các hệ thống có mục đích chung chạy trên các thiết bị chạy bằng pin.

Lưu ý rằng theo thiết kế, các tác vụ RT không có tín hiệu PELT trên mỗi tác vụ và phải luôn
chạy ở tần số không đổi để chống lại độ trễ tăng tốc DVFS không xác định.

Lưu ý rằng việc sử dụng schedutil luôn hàm ý một độ trễ duy nhất để sửa đổi tần số
khi một tác vụ RT thức dậy. Chi phí này không thay đổi khi sử dụng uclamp. chỉ có kẹp
giúp chọn tần suất yêu cầu thay vì lịch trình luôn yêu cầu
MAX cho tất cả các tác vụ RT.

Xem ZZ0000ZZ để biết các giá trị mặc định và
ZZ0001ZZ về cách thay đổi tác vụ RT
giá trị mặc định.

2. Thiết kế
=========

Kẹp Util là thuộc tính của mọi tác vụ trong hệ thống. Nó đặt ra ranh giới của
tín hiệu sử dụng của nó; hoạt động như một cơ chế thiên vị ảnh hưởng đến một số
các quyết định trong bộ lập lịch.

Tín hiệu sử dụng thực tế của một nhiệm vụ không bao giờ bị hạn chế trong thực tế. Nếu bạn
kiểm tra tín hiệu PELT bất cứ lúc nào bạn nên tiếp tục xem chúng như
chúng còn nguyên vẹn. Việc kẹp chỉ xảy ra khi cần thiết, ví dụ: khi một tác vụ được thức dậy
và bộ lập lịch cần chọn CPU phù hợp để nó chạy tiếp.

Vì mục tiêu của util kẹp là cho phép yêu cầu mức tối thiểu và tối đa
điểm hiệu suất để một tác vụ có thể chạy tiếp, nó phải có khả năng ảnh hưởng đến
lựa chọn tần suất cũng như bố trí công việc sao cho hiệu quả nhất. Cả hai
có tác động đến giá trị sử dụng tại runqueue CPU (viết tắt là rq)
cấp độ, điều này đưa chúng ta đến thách thức thiết kế chính.

Khi một tác vụ thức dậy trên rq, tín hiệu sử dụng của rq sẽ là
bị ảnh hưởng bởi cài đặt uclamp của tất cả các tác vụ được xếp hàng trên đó. Ví dụ nếu
một tác vụ yêu cầu chạy ở UTIL_MIN = 512 thì tín hiệu hữu dụng của rq cần
tôn trọng yêu cầu này cũng như tất cả các yêu cầu khác từ tất cả các bên
nhiệm vụ xếp hàng.

Để có thể tổng hợp giá trị kẹp sử dụng của tất cả các tác vụ gắn liền với
rq, uclamp phải thực hiện một số công việc quản lý tại mỗi enqueue/dequeue, đó là
đường dẫn nóng của lịch trình. Do đó cần phải cẩn thận vì bất kỳ sự chậm lại nào cũng sẽ có
tác động đáng kể đến nhiều trường hợp sử dụng và có thể cản trở khả năng sử dụng của nó trong
luyện tập.

Cách xử lý vấn đề này là chia phạm vi sử dụng thành các nhóm
(struct uclamp_bucket) cho phép chúng ta giảm không gian tìm kiếm từ mọi
nhiệm vụ trên rq thành một tập hợp con các nhiệm vụ ở nhóm trên cùng.

Khi một tác vụ được xếp vào hàng đợi, bộ đếm trong nhóm phù hợp sẽ tăng lên,
và trên dequeue nó bị giảm đi. Điều này giúp theo dõi hiệu quả
giá trị uclamp ở mức rq dễ dàng hơn rất nhiều.

Khi các tác vụ được xếp vào hàng đợi và được loại bỏ khỏi hàng đợi, chúng tôi theo dõi hiệu quả hiện tại
giá trị uclamp của rq. Xem ZZ0000ZZ để biết chi tiết về
cái này hoạt động thế nào

Sau này tại bất kỳ đường dẫn nào muốn xác định giá trị uclamp hiệu dụng của rq,
nó chỉ cần đọc giá trị uclamp hiệu dụng này của rq tại thời điểm đó
đến lúc cần phải đưa ra quyết định.

Đối với trường hợp bố trí nhiệm vụ, chỉ Lập kế hoạch nhận biết năng lượng và nhận biết năng lực
(EAS/CAS) hiện sử dụng uclamp, ngụ ý rằng nó được áp dụng trên
chỉ có các hệ thống không đồng nhất.
Khi một tác vụ thức dậy, người lập lịch sẽ xem uclamp hiệu quả hiện tại
giá trị của mỗi rq và so sánh nó với giá trị mới tiềm năng nếu nhiệm vụ được thực hiện
được xếp hàng ở đó. Ưu tiên rq sẽ mang lại nhiều năng lượng nhất
sự kết hợp hiệu quả.

Tương tự như vậy trong schedutil, khi cần cập nhật tần suất, nó sẽ trông như thế này.
tại giá trị uclamp hiệu dụng hiện tại của rq chịu ảnh hưởng của tập hợp
của các nhiệm vụ hiện đang được xử lý ở đó và chọn tần suất thích hợp
sẽ đáp ứng các ràng buộc từ các yêu cầu.

Các đường dẫn khác như cài đặt trạng thái sử dụng quá mức (vô hiệu hóa EAS một cách hiệu quả)
sử dụng uclamp là tốt. Những trường hợp như vậy được coi là việc dọn phòng cần thiết để
cho phép 2 trường hợp sử dụng chính ở trên và sẽ không đề cập chi tiết ở đây vì chúng
có thể thay đổi với các chi tiết thực hiện.

.. _uclamp-buckets:

2.1. Xô
------------

::

[cấu trúc rq]

(dưới cùng) (trên cùng)

0 1024
    ZZ0000ZZ
    +----------+----------+-------------+---- ----+----------+
    ZZ0001ZZ Xô 1 ZZ0002ZZ ... ZZ0003ZZ
    +----------+----------+-------------+---- ----+----------+
       : : :
       +- p0 +- p3 +- p4
       : :
       +- p1 +- p5
       :
       +- p2


.. note::
  The diagram above is an illustration rather than a true depiction of the
  internal data structure.

Để giảm không gian tìm kiếm khi cố gắng quyết định giá trị uclamp hiệu dụng của
một rq khi các tác vụ được xếp vào hàng đợi/xóa hàng đợi, toàn bộ phạm vi sử dụng được chia
vào N nhóm trong đó N được định cấu hình tại thời điểm biên dịch bằng cách cài đặt
CONFIG_UCLAMP_BUCKETS_COUNT. Theo mặc định, nó được đặt thành 5.

Rq có một nhóm cho mỗi điều chỉnh uclamp_id: [UCLAMP_MIN, UCLAMP_MAX].

Phạm vi của mỗi thùng là 1024/N. Ví dụ: đối với giá trị mặc định của
5 sẽ có 5 nhóm, mỗi nhóm sẽ bao gồm phạm vi sau:

::

DELTA = vòng_gần nhất (1024/5) = 204,8 = 205

Nhóm 0: [0:204]
        Nhóm 1: [205:409]
        Nhóm 2: [410:614]
        Nhóm 3: [615:819]
        Nhóm 4: [820:1024]

Khi một tác vụ p với các tham số có thể điều chỉnh sau

::

p->uclamp[UCLAMP_MIN] = 300
        p->uclamp[UCLAMP_MAX] = 1024

được xếp vào hàng rq, nhóm 1 sẽ được tăng lên cho UCLAMP_MIN và nhóm
4 sẽ được tăng lên cho UCLAMP_MAX để phản ánh thực tế rq có nhiệm vụ trong
phạm vi này.

Sau đó, rq theo dõi giá trị uclamp hiệu dụng hiện tại của nó cho mỗi
uclamp_id.

Khi một tác vụ p được xếp vào hàng đợi, giá trị rq thay đổi thành:

::

// cập nhật logic nhóm ở đây
        rq->uclamp[UCLAMP_MIN] = max(rq->uclamp[UCLAMP_MIN], p->uclamp[UCLAMP_MIN])
        // lặp lại cho UCLAMP_MAX

Tương tự, khi p bị loại bỏ, giá trị rq thay đổi thành:

::

// cập nhật logic nhóm ở đây
        rq->uclamp[UCLAMP_MIN] = search_top_bucket_for_highest_value()
        // lặp lại cho UCLAMP_MAX

Khi tất cả các nhóm trống, các giá trị rq uclamp được đặt lại về giá trị mặc định của hệ thống.
Xem ZZ0000ZZ để biết chi tiết về các giá trị mặc định.


2.2. Tổng hợp tối đa
--------------------

Kẹp sử dụng được điều chỉnh để đáp ứng yêu cầu cho nhiệm vụ đòi hỏi
điểm hiệu suất cao nhất.

Khi có nhiều tác vụ được gắn vào cùng một rq thì util kẹp phải đảm bảo
nhiệm vụ cần điểm hiệu suất cao nhất sẽ được thực hiện ngay cả khi có
một nhiệm vụ khác không cần đến nó hoặc không được phép đạt đến điểm này.

Ví dụ: nếu có nhiều nhiệm vụ gắn liền với một rq với các mục sau
giá trị:

::

p0->uclamp[UCLAMP_MIN] = 300
        p0->uclamp[UCLAMP_MAX] = 900

p1->uclamp[UCLAMP_MIN] = 500
        p1->uclamp[UCLAMP_MAX] = 500

sau đó giả sử cả p0 và p1 đều được xếp vào cùng một rq, cả UCLAMP_MIN
và UCLAMP_MAX trở thành:

::

rq->uclamp[UCLAMP_MIN] = tối đa(300, 500) = 500
        rq->uclamp[UCLAMP_MAX] = tối đa(900, 500) = 900

Như chúng ta sẽ thấy trong ZZ0000ZZ, mức tối đa này
tập hợp là nguyên nhân gây ra một trong những hạn chế khi sử dụng util kẹp, trong
đặc biệt dành cho gợi ý UCLAMP_MAX khi không gian người dùng muốn tiết kiệm năng lượng.

2.3. Tổng hợp phân cấp
-----------------------------

Như đã nêu trước đó, util kẹp là thuộc tính của mọi tác vụ trong hệ thống. Nhưng
giá trị áp dụng thực tế (hiệu quả) có thể bị ảnh hưởng bởi nhiều thứ hơn là chỉ
yêu cầu được thực hiện bởi tác vụ hoặc tác nhân khác thay mặt nó (thư viện phần mềm trung gian).

Giá trị kẹp sử dụng hiệu quả của bất kỳ nhiệm vụ nào được giới hạn như sau:

1. Bằng cài đặt uclamp được xác định bởi bộ điều khiển cgroup CPU, nó được đính kèm
     đến, nếu có.
  2. Giá trị hạn chế trong (1) sau đó bị hạn chế hơn nữa bởi toàn hệ thống
     cài đặt uclamp.

ZZ0000ZZ thảo luận về các giao diện và sẽ mở rộng
hơn nữa về điều đó.

Bây giờ đủ để nói rằng nếu một nhiệm vụ đưa ra một yêu cầu, hiệu quả thực tế của nó
giá trị sẽ phải tuân theo một số hạn chế do cgroup và hệ thống áp đặt
cài đặt rộng.

Hệ thống vẫn sẽ chấp nhận yêu cầu ngay cả khi hiệu quả vượt xa
các ràng buộc, nhưng ngay khi tác vụ chuyển sang một nhóm khác hoặc một quản trị viên hệ thống
sửa đổi cài đặt hệ thống, yêu cầu sẽ chỉ được đáp ứng nếu nó được
trong những ràng buộc mới.

Nói cách khác, việc tổng hợp này sẽ không gây ra lỗi khi một tác vụ thay đổi
giá trị uclamp của nó, nhưng đúng hơn là hệ thống có thể không đáp ứng được yêu cầu
dựa trên những yếu tố đó.

2.4. Phạm vi
----------

Yêu cầu hiệu suất Uclamp có phạm vi từ 0 đến 1024.

Đối với phần trăm giao diện cgroup được sử dụng (bao gồm từ 0 đến 100).
Cũng giống như các giao diện cgroup khác, bạn có thể sử dụng 'max' thay vì 100.

.. _uclamp-interfaces:

3. Giao diện
=============

3.1. Mỗi giao diện nhiệm vụ
-----------------------

sched_setattr() syscall đã được mở rộng để chấp nhận hai trường mới:

* sched_util_min: yêu cầu điểm hiệu suất tối thiểu mà hệ thống sẽ chạy
  khi tác vụ này đang chạy. Hoặc giới hạn hiệu suất thấp hơn.
* sched_util_max: yêu cầu điểm hiệu suất tối đa mà hệ thống sẽ chạy
  khi tác vụ này đang chạy. Hoặc giới hạn hiệu suất cao hơn.

Ví dụ: kịch bản sau có giới hạn sử dụng từ 40% đến 80%:

::

attr->sched_util_min = 40% * 1024;
        attr->sched_util_max = 80% * 1024;

Khi tác vụ @p đang chạy, **người lập lịch nên cố gắng hết sức để đảm bảo điều đó
bắt đầu ở mức hiệu suất 40%**. Nếu tác vụ chạy trong một thời gian đủ dài thì
rằng mức sử dụng thực tế của nó vượt quá 80%, mức sử dụng hoặc hiệu suất
cấp sẽ bị giới hạn.

Giá trị đặc biệt -1 được sử dụng để đặt lại cài đặt uclamp cho hệ thống
mặc định.

Lưu ý rằng việc đặt lại giá trị uclamp về mặc định của hệ thống bằng -1 là không giống nhau
như cài đặt thủ công giá trị uclamp thành mặc định của hệ thống. Sự phân biệt này là
quan trọng vì như chúng ta sẽ thấy trong giao diện hệ thống, giá trị mặc định cho
RT có thể được thay đổi. SCHED_NORMAL/OTHER cũng có thể có các nút bấm tương tự trong
tương lai.

3.2. giao diện cgroup
---------------------

Có hai giá trị liên quan đến uclamp trong bộ điều khiển nhóm CPU:

* cpu.uclamp.min
* cpu.uclamp.max

Khi một tác vụ được gắn vào bộ điều khiển CPU, các giá trị uclamp của nó sẽ bị ảnh hưởng
như sau:

* cpu.uclamp.min là một biện pháp bảo vệ như được mô tả trong ZZ0000ZZ.

Nếu giá trị uclamp_min của tác vụ thấp hơn cpu.uclamp.min thì tác vụ sẽ
  kế thừa giá trị cgroup cpu.uclamp.min.

Trong hệ thống phân cấp nhóm, cpu.uclamp.min hiệu quả là giá trị tối đa của (con,
  cha mẹ).

* cpu.uclamp.max là giới hạn như được mô tả trong ZZ0000ZZ.

Nếu giá trị uclamp_max của tác vụ cao hơn cpu.uclamp.max thì tác vụ sẽ
  kế thừa giá trị cgroup cpu.uclamp.max.

Trong hệ thống phân cấp nhóm, cpu.uclamp.max hiệu quả là giá trị tối thiểu của (con,
  cha mẹ).

Ví dụ: cho các tham số sau:

::

p0->uclamp[UCLAMP_MIN] = // mặc định hệ thống;
        p0->uclamp[UCLAMP_MAX] = // mặc định hệ thống;

p1->uclamp[UCLAMP_MIN] = 40% * 1024;
        p1->uclamp[UCLAMP_MAX] = 50% * 1024;

cgroup0->cpu.uclamp.min = 20% * 1024;
        cgroup0->cpu.uclamp.max = 60% * 1024;

cgroup1->cpu.uclamp.min = 60% * 1024;
        cgroup1->cpu.uclamp.max = 100% * 1024;

khi p0 và p1 được gắn vào cgroup0, các giá trị sẽ trở thành:

::

p0->uclamp[UCLAMP_MIN] = cgroup0->cpu.uclamp.min = 20% * 1024;
        p0->uclamp[UCLAMP_MAX] = cgroup0->cpu.uclamp.max = 60% * 1024;

p1->uclamp[UCLAMP_MIN] = 40% * 1024; // nguyên vẹn
        p1->uclamp[UCLAMP_MAX] = 50% * 1024; // nguyên vẹn

khi p0 và p1 được gắn vào cgroup1, thay vào đó chúng sẽ trở thành:

::

p0->uclamp[UCLAMP_MIN] = cgroup1->cpu.uclamp.min = 60% * 1024;
        p0->uclamp[UCLAMP_MAX] = cgroup1->cpu.uclamp.max = 100% * 1024;

p1->uclamp[UCLAMP_MIN] = cgroup1->cpu.uclamp.min = 60% * 1024;
        p1->uclamp[UCLAMP_MAX] = 50% * 1024; // nguyên vẹn

Lưu ý rằng giao diện cgroup cho phép giá trị cpu.uclamp.max thấp hơn
cpu.uclamp.min. Các giao diện khác không cho phép điều đó.

3.3. Giao diện hệ thống
---------------------

3.3.1 lịch_util_clamp_min
--------------------------

Giới hạn toàn hệ thống của phạm vi UCLAMP_MIN được phép. Theo mặc định, nó được đặt thành 1024,
điều đó có nghĩa là phạm vi UCLAMP_MIN hiệu quả được phép cho các tác vụ là [0:1024].
Ví dụ, bằng cách thay đổi nó thành 512, phạm vi giảm xuống [0:512]. Điều này rất hữu ích
để hạn chế số lượng nhiệm vụ tăng cường được phép nhận.

Yêu cầu từ các tác vụ vượt quá giá trị núm này sẽ vẫn thành công, nhưng
họ sẽ không hài lòng cho đến khi nó lớn hơn p->uclamp[UCLAMP_MIN].

Giá trị phải nhỏ hơn hoặc bằng sched_util_clamp_max.

3.3.2 lịch_util_clamp_max
--------------------------

Giới hạn toàn hệ thống của phạm vi UCLAMP_MAX được phép. Theo mặc định, nó được đặt thành 1024,
điều đó có nghĩa là phạm vi UCLAMP_MAX hiệu quả được phép cho các tác vụ là [0:1024].

Ví dụ, bằng cách thay đổi nó thành 512, phạm vi cho phép hiệu quả sẽ giảm xuống
[0:512]. Điều này có nghĩa là không có tác vụ nào có thể chạy trên 512, ngụ ý rằng tất cả
rqs cũng bị hạn chế. IOW, toàn bộ hệ thống bị giới hạn ở một nửa hiệu suất
năng lực.

Điều này rất hữu ích để hạn chế điểm hiệu suất tối đa tổng thể của hệ thống.
Ví dụ: có thể hữu ích để hạn chế hiệu suất khi sắp hết pin
hoặc khi hệ thống muốn hạn chế quyền truy cập vào hiệu suất ngốn nhiều năng lượng hơn
mức khi nó ở trạng thái không hoạt động hoặc màn hình tắt.

Các yêu cầu từ các tác vụ vượt quá giá trị núm này sẽ vẫn thành công, nhưng chúng
sẽ không được thỏa mãn cho đến khi nó lớn hơn p->uclamp[UCLAMP_MAX].

Giá trị phải lớn hơn hoặc bằng sched_util_clamp_min.

.. _uclamp-default-values:

3.4. Giá trị mặc định
-------------------

Theo mặc định, tất cả các tác vụ SCHED_NORMAL/SCHED_OTHER được khởi tạo thành:

::

p_fair->uclamp[UCLAMP_MIN] = 0
        p_fair->uclamp[UCLAMP_MAX] = 1024

Nghĩa là, theo mặc định, chúng được tăng cường để chạy ở điểm hiệu suất tối đa là
thay đổi khi khởi động hoặc khi chạy. Chưa có tranh luận nào được đưa ra về lý do tại sao chúng ta nên
cung cấp điều này, nhưng có thể được thêm vào trong tương lai.

Đối với nhiệm vụ SCHED_FIFO/SCHED_RR:

::

p_rt->uclamp[UCLAMP_MIN] = 1024
        p_rt->uclamp[UCLAMP_MAX] = 1024

Theo mặc định, chúng được tăng cường để chạy ở điểm hiệu suất tối đa là
hệ thống duy trì hành vi lịch sử của các nhiệm vụ RT.

Giá trị uclamp_min mặc định của tác vụ RT có thể được sửa đổi khi khởi động hoặc chạy thông qua
sysctl. Xem phần bên dưới.

.. _sched-util-clamp-min-rt-default:

3.4.1 lịch_util_clamp_min_rt_default
-------------------------------------

Chạy các tác vụ RT ở điểm hiệu suất tối đa rất tốn kém khi chạy bằng pin
thiết bị và không cần thiết. Để cho phép nhà phát triển hệ thống cung cấp hiệu suất tốt
đảm bảo cho những nhiệm vụ này mà không cần đẩy nó đến mức tối đa
điểm hiệu suất, núm sysctl này cho phép điều chỉnh giá trị tăng cường tốt nhất để
giải quyết yêu cầu hệ thống mà không đốt điện khi chạy ở mức tối đa
điểm hiệu suất mọi lúc.

Nhà phát triển ứng dụng được khuyến khích sử dụng giao diện kẹp cho mỗi tác vụ
để đảm bảo họ nhận thức được hiệu suất và sức mạnh. Tốt nhất nên đặt núm này
về 0 bởi các nhà thiết kế hệ thống và để lại nhiệm vụ quản lý hiệu suất
yêu cầu đối với các ứng dụng.

4. Cách sử dụng kẹp tiện ích
========================

Kẹp Util thúc đẩy khái niệm về hiệu suất và sức mạnh hỗ trợ không gian người dùng
quản lý. Ở cấp độ người lập lịch, không có thông tin cần thiết để thực hiện tốt nhất
quyết định. Tuy nhiên, với util, không gian người dùng có thể gợi ý cho bộ lập lịch để thực hiện
quyết định tốt hơn về vị trí nhiệm vụ và lựa chọn tần suất.

Kết quả tốt nhất đạt được bằng cách không đưa ra bất kỳ giả định nào về hệ thống
ứng dụng đang chạy và sử dụng nó cùng với vòng phản hồi để
theo dõi và điều chỉnh một cách linh hoạt. Cuối cùng, điều này sẽ cho phép người dùng tốt hơn
trải nghiệm ở mức hoàn hảo/watt tốt hơn.

Đối với một số hệ thống và trường hợp sử dụng, thiết lập tĩnh sẽ giúp đạt được kết quả tốt.
Tính di động sẽ là một vấn đề trong trường hợp này. Một người có thể làm được bao nhiêu công việc ở tuổi 100,
200 hoặc 1024 là khác nhau đối với mỗi hệ thống. Trừ khi có mục tiêu cụ thể
hệ thống, nên tránh thiết lập tĩnh.

Có đủ khả năng để tạo toàn bộ khung dựa trên util kẹp
hoặc ứng dụng độc lập sử dụng nó trực tiếp.

4.1. Tăng cường các tác vụ quan trọng và nhạy cảm với độ trễ DVFS
-----------------------------------------------------

Tác vụ GUI có thể không bận để đảm bảo điều khiển tần số cao khi nó
thức dậy. Tuy nhiên, nó yêu cầu phải hoàn thành công việc của mình trong một khoảng thời gian cụ thể
để mang lại trải nghiệm người dùng mong muốn. Tần số phù hợp nó yêu cầu ở
việc thức dậy sẽ phụ thuộc vào hệ thống. Trên một số hệ thống yếu, nó sẽ cao,
trên những cái bị áp đảo khác, nó sẽ ở mức thấp hoặc 0.

Nhiệm vụ này có thể tăng giá trị UCLAMP_MIN của nó mỗi khi trễ thời hạn
để đảm bảo vào lần thức dậy tiếp theo, nó sẽ chạy ở điểm hiệu suất cao hơn. Nó nên thử
để đạt đến giá trị UCLAMP_MIN thấp nhất cho phép đáp ứng thời hạn của nó trên bất kỳ
hệ thống cụ thể để đạt được hiệu suất/watt tốt nhất có thể cho hệ thống đó.

Trên các hệ thống không đồng nhất, điều quan trọng là tác vụ này phải chạy trên
CPU nhanh hơn.

**Nói chung, bạn nên coi đầu vào là mức hiệu suất hoặc điểm
điều này sẽ bao hàm cả vị trí nhiệm vụ và lựa chọn tần suất**.

4.2. Giới hạn các tác vụ nền
-------------------------

Giống như đã giải thích cho trường hợp Android trong phần giới thiệu. Ứng dụng nào cũng có thể hạ thấp
UCLAMP_MAX cho một số tác vụ nền không quan tâm đến hiệu suất nhưng
cuối cùng có thể bận rộn và tiêu tốn tài nguyên hệ thống không cần thiết trên hệ thống.

4.3. Chế độ tiết kiệm năng lượng
-------------------

Giao diện toàn hệ thống sched_util_clamp_max có thể được sử dụng để giới hạn tất cả các tác vụ từ
hoạt động ở các điểm hiệu suất cao hơn thường là năng lượng
không hiệu quả.

Điều này không phải là duy nhất đối với uclamp vì người ta có thể đạt được điều tương tự bằng cách giảm tối đa
tần số của thống đốc cpufreq. Nó có thể được coi là thuận tiện hơn
giao diện thay thế.

4.4. Hạn chế hiệu suất trên mỗi ứng dụng
------------------------------------

Middleware/Utility có thể cung cấp cho người dùng tùy chọn để đặt UCLAMP_MIN/MAX cho một
app mỗi khi nó được thực thi để đảm bảo điểm hiệu suất tối thiểu và/hoặc
hạn chế nó khỏi việc tiêu hao năng lượng của hệ thống với cái giá phải trả là giảm hiệu suất cho
những ứng dụng này.

Nếu bạn muốn ngăn máy tính xách tay của mình nóng lên khi đang di chuyển
biên dịch kernel và vui vẻ hy sinh hiệu năng để tiết kiệm điện năng, nhưng
vẫn muốn giữ nguyên hiệu suất trình duyệt của bạn, uclamp làm cho nó
có thể.

5. Hạn chế
==============

.. _uclamp-capping-fail:

5.1. Giới hạn tần suất với uclamp_max không thành công trong một số điều kiện nhất định
---------------------------------------------------------------------

Nếu tác vụ p0 bị giới hạn chạy ở mức 512:

::

p0->uclamp[UCLAMP_MAX] = 512

và nó chia sẻ rq với p1, chạy miễn phí ở bất kỳ điểm hiệu suất nào:

::

p1->uclamp[UCLAMP_MAX] = 1024

sau đó do tổng hợp tối đa nên rq sẽ được phép đạt hiệu suất tối đa
điểm:

::

rq->uclamp[UCLAMP_MAX] = max(512, 1024) = 1024

Giả sử cả p0 và p1 đều có UCLAMP_MIN = 0 thì việc chọn tần số cho
rq sẽ phụ thuộc vào giá trị sử dụng thực tế của nhiệm vụ.

Nếu p1 là một nhiệm vụ nhỏ nhưng p0 là một nhiệm vụ chuyên sâu của CPU, thì do thực tế là
cả hai đều chạy ở cùng một rq, p1 sẽ khiến giới hạn tần số bị bỏ lại
từ rq mặc dù p1, được phép chạy ở bất kỳ điểm hiệu suất nào,
thực sự không cần phải chạy ở tần số đó.

5.2. UCLAMP_MAX có thể ngắt tín hiệu PELT (util_avg)
------------------------------------------------

PELT giả định rằng tần số sẽ luôn tăng khi tín hiệu tăng để đảm bảo
luôn có một khoảng thời gian nhàn rỗi trên CPU. Nhưng với UCLAMP_MAX, tần số này
sự gia tăng sẽ bị ngăn chặn, điều này có thể dẫn đến không có thời gian nhàn rỗi ở một số nơi
hoàn cảnh. Khi không có thời gian nhàn rỗi, một nhiệm vụ sẽ bị mắc kẹt trong một vòng lặp bận rộn,
điều này sẽ dẫn đến util_avg là 1024.

Kết hợp với sự cố được mô tả bên dưới, điều này có thể dẫn đến tần suất tăng đột biến không mong muốn
khi các nhiệm vụ bị giới hạn nghiêm trọng, hãy chia sẻ rq với một nhiệm vụ nhỏ không bị giới hạn.

Ví dụ: nếu nhiệm vụ p, có:

::

p0->util_avg = 300
        p0->uclamp[UCLAMP_MAX] = 0

thức dậy trên một chiếc CPU đang rảnh rỗi, sau đó nó sẽ chạy ở tần số tối thiểu (Fmin)
CPU có khả năng. Tần số CPU tối đa (Fmax) cũng quan trọng ở đây,
vì nó chỉ định thời gian tính toán ngắn nhất để hoàn thành nhiệm vụ
làm việc trên CPU này.

::

rq->uclamp[UCLAMP_MAX] = 0

Nếu tỷ số Fmax/Fmin là 3 thì giá trị cực đại sẽ là:

::

300 * (Fmax/Fmin) = 900

điều này cho biết CPU vẫn sẽ có thời gian không hoạt động vì 900 là < 1024.
_actual_ util_avg sẽ không phải là 900 mà là khoảng từ 300 đến 900. Như
miễn là còn thời gian rảnh, các bản cập nhật p->util_avg sẽ bị tắt một chút,
nhưng không tỷ lệ với Fmax/Fmin.

::

p0->util_avg = 300 + small_error

Bây giờ nếu tỷ số Fmax/Fmin là 4 thì giá trị lớn nhất sẽ là:

::

300 * (Fmax/Fmin) = 1200

cao hơn 1024 và cho biết CPU không có thời gian rảnh. Khi nào
điều này xảy ra thì _actual_util_avg sẽ trở thành:

::

p0->util_avg = 1024

Nếu tác vụ p1 thức dậy trên CPU này, có:

::

p1->util_avg = 200
        p1->uclamp[UCLAMP_MAX] = 1024

thì UCLAMP_MAX hiệu quả cho CPU sẽ là 1024 theo mức tối đa
quy tắc tổng hợp. Nhưng vì tác vụ p0 bị giới hạn đang chạy và được điều chỉnh
nghiêm túc thì rq->util_avg sẽ là:

::

p0->util_avg = 1024
        p1->util_avg = 200

rq->util_avg = 1024
        rq->uclamp[UCLAMP_MAX] = 1024

Do đó dẫn đến tần số tăng đột biến vì nếu p0 không được điều chỉnh, chúng ta sẽ nhận được:

::

p0->util_avg = 300
        p1->util_avg = 200

rq->util_avg = 500

và chạy ở đâu đó gần điểm hiệu suất trung bình của CPU đó, không phải Fmax mà chúng tôi nhận được.

5.3. Vấn đề về thời gian phản hồi của Scheduleutil
-----------------------------------

schedutil có ba hạn chế:

1. Phần cứng cần có thời gian khác 0 để đáp ứng với bất kỳ sự thay đổi tần số nào
           yêu cầu. Trên một số nền tảng có thể theo thứ tự vài mili giây.
        2. Các hệ thống không chuyển đổi nhanh yêu cầu luồng thời hạn của công nhân để thức dậy
           và thực hiện thay đổi tần số, bổ sung thêm chi phí có thể đo lường được.
        3. schedutil rate_limit_us loại bỏ mọi yêu cầu trong rate_limit_us này
           cửa sổ.

Nếu một nhiệm vụ tương đối nhỏ đang thực hiện công việc quan trọng và đòi hỏi một mức độ nhất định
điểm hiệu suất khi nó thức dậy và bắt đầu chạy, thì tất cả những điều này
những hạn chế sẽ ngăn cản nó đạt được điều nó muốn trong khoảng thời gian nó
mong đợi.

Hạn chế này không chỉ ảnh hưởng khi sử dụng uclamp mà còn ảnh hưởng nhiều hơn
phổ biến khi chúng ta không còn tăng hoặc giảm dần dần nữa. Chúng ta có thể dễ dàng trở thành
nhảy giữa các tần số tùy thuộc vào thứ tự các nhiệm vụ thức dậy và
giá trị uclamp tương ứng.

Chúng tôi coi đó là một hạn chế về khả năng của hệ thống cơ bản
chính nó.

Có chỗ cần cải thiện hoạt động của schedutil rate_limit_us, nhưng không nhiều
được thực hiện cho 1 hoặc 2. Chúng được coi là những hạn chế cứng của hệ thống.