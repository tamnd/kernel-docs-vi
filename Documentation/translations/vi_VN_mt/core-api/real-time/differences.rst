.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/real-time/differences.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Hạt nhân thời gian thực khác nhau như thế nào
=============================================

:Tác giả: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Lời nói đầu
===========

Với các ngắt theo luồng bắt buộc và các khóa quay đang ngủ, các đường dẫn mã
độ trễ lập kế hoạch dài gây ra trước đây đã được thực hiện trước và
chuyển sang bối cảnh quá trình. Điều này cho phép người lập lịch quản lý chúng nhiều hơn
hiệu quả và đáp ứng các nhiệm vụ có mức độ ưu tiên cao hơn với độ trễ giảm.

Các chương sau đây cung cấp cái nhìn tổng quan về những khác biệt chính giữa một
Hạt nhân PREEMPT_RT và hạt nhân tiêu chuẩn, không phải PREEMPT_RT.

Khóa
=======

Các khóa quay như spinlock_t được sử dụng để cung cấp sự đồng bộ hóa dữ liệu
các cấu trúc được truy cập từ cả bối cảnh ngắt và bối cảnh quá trình. Vì điều này
lý do, chức năng khóa cũng có sẵn với _irq() hoặc _irqsave()
hậu tố, vô hiệu hóa các ngắt trước khi lấy khóa. Điều này đảm bảo rằng
khóa có thể được lấy một cách an toàn trong bối cảnh quy trình khi các ngắt được bật.

Tuy nhiên, trên hệ thống PREEMPT_RT, các ngắt được phân luồng cưỡng bức và không còn
chạy trong bối cảnh IRQ cứng. Kết quả là không cần phải vô hiệu hóa các ngắt vì
một phần của quy trình khóa khi sử dụng spinlock_t.

Đối với các thành phần cốt lõi cấp thấp như xử lý ngắt, bộ lập lịch hoặc
hệ thống con hẹn giờ kernel sử dụng raw_spinlock_t. Loại khóa này bảo tồn
ngữ nghĩa truyền thống: nó vô hiệu hóa quyền ưu tiên và khi được sử dụng với _irq() hoặc
_irqsave(), cũng vô hiệu hóa các ngắt. Điều này đảm bảo sự đồng bộ hóa thích hợp trong
các phần quan trọng phải không được ưu tiên trước hoặc bị vô hiệu hóa các ngắt.

Bối cảnh thực thi
=================

Xử lý ngắt trong hệ thống PREEMPT_RT được gọi trong ngữ cảnh quy trình thông qua
việc sử dụng các ngắt theo luồng. Các phần khác của kernel cũng thay đổi
thực hiện vào bối cảnh luồng bằng các cơ chế khác nhau. Mục tiêu là giữ
đường dẫn thực thi được ưu tiên trước, cho phép bộ lập lịch ngắt chúng khi
nhiệm vụ có mức độ ưu tiên cao hơn cần phải chạy.

Dưới đây là tổng quan về các hệ thống con kernel liên quan đến quá trình chuyển đổi này sang
thực hiện theo luồng, ưu tiên.

Xử lý ngắt
------------------

Tất cả các ngắt đều được phân luồng cưỡng bức trong hệ thống PREEMPT_RT. Các trường hợp ngoại lệ là
các ngắt được yêu cầu với IRQF_NO_THREAD, IRQF_PERCPU hoặc
Cờ IRQF_ONESHOT.

Cờ IRQF_ONESHOT được sử dụng cùng với các ngắt theo luồng, nghĩa là chúng
đã đăng ký bằng request_threaded_irq() và chỉ cung cấp trình xử lý theo luồng.
Mục đích của nó là giữ cho dòng ngắt bị che đi cho đến khi trình xử lý luồng
hoàn thành.

Nếu một trình xử lý chính cũng được cung cấp trong trường hợp này thì điều cần thiết là
trình xử lý không thu được bất kỳ khóa ngủ nào vì nó sẽ không được phân luồng. các
trình xử lý phải ở mức tối thiểu và phải tránh gây ra sự chậm trễ, chẳng hạn như
đang bận chờ trên các thanh ghi phần cứng.


Ngắt mềm, xử lý nửa dưới
-------------------------------------

Các ngắt mềm được đưa ra bởi bộ xử lý ngắt và được thực thi sau lệnh
trình xử lý trả về. Vì chúng chạy trong ngữ cảnh luồng nên chúng có thể bị ưu tiên bởi
chủ đề khác. Đừng cho rằng bối cảnh softirq chạy với quyền ưu tiên
bị vô hiệu hóa. Điều này có nghĩa là bạn không được dựa vào các cơ chế như local_bh_disable() trong
xử lý bối cảnh để bảo vệ các biến trên mỗi CPU. Bởi vì trình xử lý softirq là
được ưu tiên theo PREEMPT_RT, phương pháp này không cung cấp độ tin cậy
đồng bộ hóa.

Nếu loại bảo vệ này là cần thiết vì lý do hiệu suất, hãy cân nhắc sử dụng
local_lock_nested_bh(). Trên các hạt nhân không phải PREEMPT_RT, điều này cho phép lockdep
xác minh rằng nửa dưới bị vô hiệu hóa. Trên các hệ thống PREEMPT_RT, nó bổ sung thêm
khóa cần thiết để đảm bảo bảo vệ thích hợp.

Sử dụng local_lock_nested_bh() cũng giúp phạm vi khóa rõ ràng và dễ dàng hơn
để người đọc và người bảo trì hiểu được.


các biến trên mỗi CPU
---------------------

Việc bảo vệ quyền truy cập vào các biến trên mỗi CPU chỉ bằng cách sử dụng preempt_disable() sẽ
tránh được, đặc biệt nếu phần quan trọng có thời gian chạy không giới hạn hoặc có thể
gọi các API có thể ngủ.

Nếu việc sử dụng spinlock_t được coi là quá tốn kém vì lý do hiệu suất,
hãy cân nhắc sử dụng local_lock_t. Trên các cấu hình không phải PREEMPT_RT, điều này giới thiệu
không có chi phí thời gian chạy khi lockdep bị tắt. Khi bật lockdep, nó sẽ xác minh
rằng khóa chỉ được lấy trong ngữ cảnh quy trình và không bao giờ từ softirq hoặc
bối cảnh IRQ cứng.

Trên hạt nhân PREEMPT_RT, local_lock_t được triển khai bằng cách sử dụng spinlock_t per-CPU,
cung cấp khả năng bảo vệ cục bộ an toàn cho dữ liệu trên mỗi CPU trong khi vẫn giữ cho hệ thống
có thể được ưu tiên.

Vì spinlock_t trên PREEMPT_RT không vô hiệu hóa quyền ưu tiên nên không thể sử dụng được
để bảo vệ dữ liệu trên mỗi CPU bằng cách dựa vào việc vô hiệu hóa quyền ưu tiên ngầm. Nếu điều này
Việc vô hiệu hóa quyền ưu tiên kế thừa là điều cần thiết và nếu không thể sử dụng local_lock_t
do những hạn chế về hiệu suất, độ ngắn của mã hoặc ranh giới trừu tượng
trong API thì preempt_disable_nested() có thể là một giải pháp thay thế phù hợp. Bật
hạt nhân không phải PREEMPT_RT, nó sẽ xác minh bằng lockdep rằng quyền ưu tiên đã được thực hiện
bị vô hiệu hóa. Trên PREEMPT_RT, nó vô hiệu hóa quyền ưu tiên một cách rõ ràng.

Bộ hẹn giờ
----------

Theo mặc định, bộ đếm thời gian được thực thi trong ngữ cảnh ngắt cứng. Ngoại lệ là
bộ định thời được khởi tạo bằng cờ HRTIMER_MODE_SOFT, được thực thi trong
bối cảnh softirq.

Trên hạt nhân PREEMPT_RT, hành vi này bị đảo ngược: bộ đếm thời gian được thực thi trong
bối cảnh softirq theo mặc định, thường là trong chuỗi ktimersd. Chủ đề này
chạy ở mức ưu tiên thời gian thực thấp nhất, đảm bảo nó thực thi trước bất kỳ
Nhiệm vụ SCHED_OTHER nhưng không can thiệp vào thời gian thực có mức độ ưu tiên cao hơn
chủ đề. Để yêu cầu thực thi một cách rõ ràng trong bối cảnh ngắt cứng trên
PREEMPT_RT, bộ hẹn giờ phải được đánh dấu bằng cờ HRTIMER_MODE_HARD.

Phân bổ bộ nhớ
-----------------

Các API cấp phát bộ nhớ, chẳng hạn như kmalloc() và alloc_pages(), yêu cầu
cờ gfp_t để biểu thị bối cảnh phân bổ. Trên các hạt nhân không phải PREEMPT_RT, nó là
cần thiết phải sử dụng GFP_ATOMIC khi cấp phát bộ nhớ từ ngữ cảnh ngắt hoặc
từ những phần mà quyền ưu tiên bị vô hiệu hóa. Điều này là do người cấp phát phải
không ngủ trong những bối cảnh này để chờ bộ nhớ có sẵn.

Tuy nhiên, cách tiếp cận này không hoạt động trên kernel PREEMPT_RT. Bộ nhớ
bộ cấp phát trong PREEMPT_RT sử dụng khóa ngủ bên trong, không thể
có được khi quyền ưu tiên bị vô hiệu hóa. May mắn thay, đây thường không phải là một
vấn đề, bởi vì PREEMPT_RT di chuyển hầu hết các bối cảnh thường chạy
với quyền ưu tiên hoặc các ngắt bị vô hiệu hóa trong ngữ cảnh theo luồng, trong đó chế độ ngủ được thực hiện
được phép.

Vấn đề còn lại là mã vô hiệu hóa quyền ưu tiên hoặc
ngắt quãng. Trong những trường hợp như vậy, việc cấp phát bộ nhớ phải được thực hiện bên ngoài
phần quan trọng.

Hạn chế này cũng áp dụng cho các thủ tục cấp phát bộ nhớ như kfree()
và free_pages(), cũng có thể liên quan đến khóa bên trong và không được phép
được gọi từ các bối cảnh không được ưu tiên trước.

IRQ hoạt động
-------------

Irq_work API cung cấp cơ chế lên lịch gọi lại khi bị gián đoạn
bối cảnh. Nó được thiết kế để sử dụng trong những bối cảnh không thể lập kế hoạch truyền thống.
có thể, chẳng hạn như từ bên trong bộ xử lý NMI hoặc từ bên trong bộ lập lịch, trong đó
sử dụng hàng đợi công việc sẽ không an toàn.

Trên các hệ thống không phải PREEMPT_RT, tất cả các mục irq_work được thực thi ngay lập tức trong
làm gián đoạn bối cảnh. Các mục được đánh dấu bằng IRQ_WORK_LAZY sẽ được hoãn lại cho đến lần tiếp theo
đánh dấu bộ đếm thời gian nhưng vẫn được thực thi trong ngữ cảnh ngắt.

Trên hệ thống PREEMPT_RT, mô hình thực thi thay đổi. Bởi vì các cuộc gọi lại irq_work
có thể có được khóa ngủ hoặc có thời gian thực thi không giới hạn, chúng sẽ được xử lý
trong ngữ cảnh luồng bằng luồng hạt nhân per-CPU irq_work. Chủ đề này chạy ở
mức độ ưu tiên thời gian thực thấp nhất, đảm bảo nó thực thi trước mọi tác vụ SCHED_OTHER
nhưng không can thiệp vào các luồng thời gian thực có mức độ ưu tiên cao hơn.

Ngoại lệ là các mục công việc được đánh dấu bằng IRQ_WORK_HARD_IRQ, vẫn còn
được thực thi trong bối cảnh ngắt cứng. Đồ lười (IRQ_WORK_LAZY) tiếp tục được ra mắt
được trì hoãn cho đến thời điểm hẹn giờ tiếp theo và cũng được thực thi bởi irq_work/
chủ đề.

Cuộc gọi lại RCU
----------------

Lệnh gọi lại RCU được gọi theo mặc định trong ngữ cảnh softirq. Việc thực hiện của họ là
quan trọng vì tùy thuộc vào trường hợp sử dụng, chúng có thể giải phóng bộ nhớ hoặc đảm bảo
tiến bộ trong quá trình chuyển đổi trạng thái. Chạy các cuộc gọi lại này như một phần của softirq
chuỗi có thể dẫn đến các tình huống không mong muốn, chẳng hạn như tranh chấp tài nguyên CPU
với các tác vụ SCHED_OTHER khác khi được thực thi trong ksoftirqd.

Để tránh chạy các lệnh gọi lại trong ngữ cảnh softirq, hệ thống con RCU cung cấp một
thay vào đó là cơ chế thực thi chúng trong ngữ cảnh quy trình. Hành vi này có thể
được bật bằng cách đặt tham số dòng lệnh khởi động rcutree.use_softirq=0. Cái này
cài đặt được thực thi trong các hạt nhân được định cấu hình bằng PREEMPT_RT.

Quay cho đến khi sẵn sàng
=========================

Mẫu "quay cho đến khi sẵn sàng" liên quan đến việc kiểm tra (quay) liên tục
trạng thái của cấu trúc dữ liệu cho đến khi nó sẵn sàng. Mẫu này giả định rằng
quyền ưu tiên, ngắt mềm hoặc ngắt đều bị vô hiệu hóa. Nếu cấu trúc dữ liệu
được đánh dấu là bận, nó được cho là đang được sử dụng bởi CPU khác và việc quay sẽ
cuối cùng đã thành công khi CPU tiến bộ.

Một số ví dụ là hrtimer_cancel() hoặctimer_delete_sync(). Những chức năng này
hủy bộ định thời thực thi khi ngắt hoặc ngắt mềm bị vô hiệu hóa. Nếu một
luồng cố gắng hủy bộ hẹn giờ và thấy nó đang hoạt động, quay cho đến khi
cuộc gọi lại hoàn tất là an toàn vì cuộc gọi lại chỉ có thể chạy trên một CPU khác và
cuối cùng sẽ kết thúc.

Tuy nhiên, trên hạt nhân PREEMPT_RT, lệnh gọi lại hẹn giờ chạy trong ngữ cảnh luồng. Cái này
đưa ra một thách thức: một luồng có mức độ ưu tiên cao hơn đang cố gắng hủy bộ đếm thời gian
có thể ưu tiên chuỗi gọi lại hẹn giờ. Vì bộ lập lịch không thể di chuyển
chuỗi gọi lại đến một CPU khác do hạn chế về ái lực, có thể dẫn đến việc quay vòng
trong livelock ngay cả trên các hệ thống đa bộ xử lý.

Để tránh điều này, cả bên hủy và bên gọi lại đều phải sử dụng bắt tay
cơ chế hỗ trợ kế thừa ưu tiên. Điều này cho phép hủy chủ đề
tạm dừng cho đến khi cuộc gọi lại hoàn tất, đảm bảo tiến trình chuyển tiếp mà không cần
đang gặp nguy hiểm.

Để giải quyết vấn đề ở cấp độ API, khóa trình tự đã được mở rộng
để cho phép chuyển giao thích hợp giữa đầu đọc quay và thiết bị có thể
nhà văn bị chặn.

Khóa trình tự
--------------

Bộ đếm trình tự và khóa tuần tự được ghi lại trong
Tài liệu/khóa/seqlock.rst.

Giao diện đã được mở rộng để đảm bảo trạng thái ưu tiên thích hợp cho
bối cảnh của nhà văn và người đọc quay vòng. Điều này đạt được bằng cách nhúng người viết
khóa tuần tự hóa trực tiếp vào loại bộ đếm trình tự, dẫn đến
các loại tổng hợp như seqcount_spinlock_t hoặc seqcount_mutex_t.

Những kiểu kết hợp này cho phép người đọc phát hiện việc ghi đang diễn ra và chủ động
tăng mức độ ưu tiên của người viết để giúp họ hoàn thành bản cập nhật thay vì quay vòng
và chờ đợi nó hoàn thành.

Nếu sử dụng seqcount_t đơn giản, phải cẩn thận hơn để đồng bộ hóa
người đọc với người viết trong quá trình cập nhật. Người viết phải đảm bảo cập nhật của nó là
được đăng nhiều kỳ và không được ưu tiên trước đối với người đọc. Điều này không thể đạt được
sử dụng spinlock_t thông thường vì spinlock_t trên PREEMPT_RT không tắt
quyền ưu tiên. Trong những trường hợp như vậy, sử dụng seqcount_spinlock_t là giải pháp ưu tiên.

Tuy nhiên, nếu không có thao tác quay, tức là nếu người đọc chỉ cần
phát hiện xem quá trình ghi đã bắt đầu chưa và không tuần tự hóa nó sau đó sử dụng
seqcount_t là hợp lý.