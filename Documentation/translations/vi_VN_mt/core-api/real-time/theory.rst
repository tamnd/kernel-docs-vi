.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/real-time/theory.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Lý thuyết hoạt động
=======================

:Tác giả: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Lời nói đầu
=======

PREEMPT_RT biến nhân Linux thành nhân thời gian thực. Nó đạt được
điều này bằng cách thay thế các khóa nguyên thủy, chẳng hạn như spinlock_t, bằng một quyền ưu tiên
và triển khai nhận thức về quyền kế thừa ưu tiên được gọi là rtmutex và bằng cách thực thi
việc sử dụng các ngắt theo luồng. Kết quả là kernel trở nên đầy đủ
có thể được ưu tiên trước, ngoại trừ một số đường dẫn mã quan trọng, bao gồm cả mục nhập
mã, bộ lập lịch và các thủ tục xử lý ngắt ở mức độ thấp.

Sự chuyển đổi này đặt phần lớn các bối cảnh thực thi kernel dưới
kiểm soát bộ lập lịch và tăng đáng kể số lượng quyền ưu tiên
điểm. Do đó, nó làm giảm độ trễ giữa một tác vụ có mức độ ưu tiên cao
trở thành có thể chạy được và thực thi nó trên CPU.

Lên lịch
==========

Các nguyên tắc cốt lõi của lập kế hoạch Linux và không gian người dùng liên quan API là
được ghi lại trong trang man (7)
ZZ0000ZZ.
Theo mặc định, nhân Linux sử dụng chính sách lập lịch SCHED_OTHER. Dưới
chính sách này, một tác vụ sẽ được ưu tiên khi bộ lập lịch xác định rằng nó có
đã tiêu tốn một lượng lớn thời gian CPU so với các tác vụ có thể chạy khác. Tuy nhiên,
chính sách này không đảm bảo quyền ưu tiên ngay lập tức khi có nhiệm vụ SCHED_OTHER mới
trở nên có thể chạy được. Tác vụ hiện đang chạy có thể tiếp tục thực thi.

Hành vi này khác với hành vi của các chính sách lập kế hoạch thời gian thực như
SCHED_FIFO. Khi một tác vụ có chính sách thời gian thực có thể chạy được,
bộ lập lịch ngay lập tức chọn nó để thực thi nếu nó có mức độ ưu tiên cao hơn
tác vụ hiện đang chạy. Nhiệm vụ tiếp tục chạy cho đến khi nó tự nguyện
mang lại CPU, thường bằng cách chặn một sự kiện.

Khóa quay khi ngủ
===================

Các loại khóa khác nhau và hành vi của chúng trong cấu hình thời gian thực là
được mô tả chi tiết trong Documentation/locking/locktypes.rst.
Trong cấu hình không phải PREEMPT_RT, spinlock_t có được bằng cách tắt lần đầu
quyền ưu tiên và sau đó chủ động quay cho đến khi có khóa. Một lần
khóa được giải phóng, quyền ưu tiên được kích hoạt. Từ góc độ thời gian thực,
Cách tiếp cận này là không mong muốn vì việc vô hiệu hóa quyền ưu tiên sẽ ngăn cản
bộ lập lịch chuyển sang nhiệm vụ có mức độ ưu tiên cao hơn, có khả năng tăng
độ trễ.

Để giải quyết vấn đề này, PREEMPT_RT thay thế khóa quay bằng khóa quay ngủ
không vô hiệu hóa quyền ưu tiên. Trên PREEMPT_RT, spinlock_t được triển khai bằng cách sử dụng
rtmutex. Thay vì quay vòng, một nhiệm vụ cố gắng giành được một khóa dự kiến
vô hiệu hóa việc di chuyển CPU, dành quyền ưu tiên của nó cho chủ sở hữu khóa (ưu tiên
thừa kế), và tự nguyện lên lịch trong khi chờ khóa
trở nên có sẵn.

Việc vô hiệu hóa di chuyển CPU mang lại tác dụng tương tự như vô hiệu hóa quyền ưu tiên, trong khi
vẫn cho phép quyền ưu tiên và đảm bảo rằng tác vụ tiếp tục chạy trên
giống CPU khi đang cầm khóa ngủ.

Kế thừa ưu tiên
====================

Các loại khóa như spinlock_t và mutex_t trong hạt nhân hỗ trợ PREEMPT_RT là
được triển khai trên rtmutex, cung cấp hỗ trợ cho việc kế thừa ưu tiên
(PI). Khi một tác vụ chặn một khóa như vậy, cơ chế PI tạm thời
truyền các tham số lập kế hoạch của tác vụ bị chặn tới chủ sở hữu khóa.

Ví dụ: nếu tác vụ SCHED_FIFO A chặn trên khóa hiện được giữ bởi
SCHED_OTHER nhiệm vụ B, chính sách lập kế hoạch và mức độ ưu tiên của nhiệm vụ A tạm thời
được kế thừa bởi nhiệm vụ B. Sau sự kế thừa này, nhiệm vụ A được chuyển sang chế độ ngủ trong khi
chờ khóa và nhiệm vụ B thực sự trở thành nhiệm vụ có mức độ ưu tiên cao nhất
trong hệ thống. Điều này cho phép B tiếp tục thực hiện, đạt được tiến bộ và
cuối cùng nhả khóa.

Khi B nhả khóa, nó sẽ trở lại các tham số lập kế hoạch ban đầu và
nhiệm vụ A có thể tiếp tục thực hiện.

Ngắt theo luồng
===================

Trình xử lý ngắt là một nguồn mã khác thực thi với quyền ưu tiên
bị vô hiệu hóa và nằm ngoài tầm kiểm soát của bộ lập lịch. Để xử lý ngắt
dưới sự kiểm soát của bộ lập lịch, PREEMPT_RT thực thi các trình xử lý ngắt theo luồng.

Với phân luồng cưỡng bức, việc xử lý ngắt được chia thành hai giai đoạn. đầu tiên
giai đoạn, trình xử lý chính, được thực thi trong ngữ cảnh IRQ với các ngắt bị vô hiệu hóa.
Trách nhiệm duy nhất của nó là đánh thức trình xử lý luồng liên quan. thứ hai
giai đoạn, trình xử lý luồng, là hàm được truyền cho request_irq() dưới dạng
trình xử lý ngắt. Nó chạy trong ngữ cảnh tiến trình, được lập lịch bởi kernel.

Từ khi đánh thức luồng ngắt cho đến khi xử lý luồng hoàn tất,
nguồn ngắt được che giấu trong bộ điều khiển ngắt. Điều này đảm bảo rằng
ngắt thiết bị vẫn đang chờ xử lý nhưng không kích hoạt lại CPU, cho phép
hệ thống để thoát khỏi ngữ cảnh IRQ và xử lý ngắt trong luồng đã lên lịch.

Theo mặc định, trình xử lý luồng thực thi với chính sách lập lịch SCHED_FIFO
và mức độ ưu tiên là 50 (MAX_RT_PRIO / 2), nằm giữa mức tối thiểu và
ưu tiên thời gian thực tối đa.

Nếu trình xử lý ngắt theo luồng tạo ra bất kỳ ngắt mềm nào trong quá trình xử lý
thực thi, các thủ tục ngắt mềm đó sẽ được gọi sau trình xử lý luồng
hoàn thành, trong cùng một chủ đề. Quyền ưu tiên vẫn được bật trong thời gian
thực hiện trình xử lý ngắt mềm.

Bản tóm tắt
=======

Bằng cách sử dụng khóa ngủ và ngắt theo luồng cưỡng bức, PREEMPT_RT
giảm đáng kể các phần mã nơi bị gián đoạn hoặc ưu tiên
bị vô hiệu hóa, cho phép bộ lập lịch ưu tiên bối cảnh thực thi hiện tại và
chuyển sang một nhiệm vụ có mức độ ưu tiên cao hơn.