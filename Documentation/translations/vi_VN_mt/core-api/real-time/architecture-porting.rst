.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/real-time/architecture-porting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Chuyển một kiến trúc để hỗ trợ PREEMPT_RT
=================================================

:Tác giả: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Danh sách này phác thảo các yêu cầu cụ thể về kiến trúc phải được đáp ứng
được triển khai để kích hoạt PREEMPT_RT. Khi tất cả các tính năng cần thiết đã được
được triển khai, ARCH_SUPPORTS_RT có thể được chọn trong Kconfig của kiến trúc để thực hiện
PREEMPT_RT có thể lựa chọn.
Nhiều điều kiện tiên quyết (ví dụ hỗ trợ genirq) được thực thi theo mã chung
và được bỏ qua ở đây.

Các tính năng tùy chọn không bắt buộc phải có nhưng rất đáng để xem xét
họ.

Yêu cầu
------------

Bắt buộc ngắt luồng
  CONFIG_IRQ_FORCED_THREADING phải được chọn. Bất kỳ sự gián đoạn nào phải
  vẫn ở trong bối cảnh hard-IRQ phải được đánh dấu bằng IRQF_NO_THREAD. Cái này
  yêu cầu áp dụng ví dụ cho các ngắt sự kiện nguồn xung nhịp,
  các ngắt hoàn hảo và các trình xử lý bộ điều khiển ngắt xếp tầng.

Hỗ trợ PREEMPTION
  Quyền ưu tiên hạt nhân phải được hỗ trợ và yêu cầu
  CONFIG_ARCH_NO_PREEMPT vẫn chưa được chọn. Lập kế hoạch yêu cầu, chẳng hạn như những
  được đưa ra từ một ngắt hoặc trình xử lý ngoại lệ khác, phải được xử lý
  ngay lập tức.

Bộ hẹn giờ POSIX CPU và KVM
  Bộ định thời POSIX CPU phải hết hạn từ ngữ cảnh luồng thay vì trực tiếp bên trong
  bộ đếm thời gian bị gián đoạn. Hành vi này được kích hoạt bằng cách thiết lập cấu hình
  tùy chọn CONFIG_HAVE_POSIX_CPU_TIMERS_TASK_WORK.
  Khi hỗ trợ ảo hóa, chẳng hạn như KVM, được bật,
  CONFIG_VIRT_XFER_TO_GUEST_WORK cũng phải được thiết lập để đảm bảo
  rằng mọi công việc đang chờ xử lý, chẳng hạn như hết hạn bộ hẹn giờ POSIX, sẽ được xử lý trước
  chuyển sang chế độ khách.

Ngăn xếp Hard-IRQ và Soft-IRQ
  Các ngắt mềm được xử lý trong ngữ cảnh luồng mà chúng được nêu ra. Nếu
  một ngắt mềm được kích hoạt từ bối cảnh IRQ cứng, việc thực thi nó bị trì hoãn
  đến chủ đề ksoftirqd. Quyền ưu tiên không bao giờ bị vô hiệu hóa trong khi ngắt mềm
  xử lý, làm cho các ngắt mềm có thể được ưu tiên trước.
  Nếu một kiến trúc cung cấp triển khai __do_softirq() tùy chỉnh sử dụng
  ngăn xếp riêng biệt thì phải chọn CONFIG_HAVE_SOFTIRQ_ON_OWN_STACK. các
  chức năng chỉ nên được kích hoạt khi CONFIG_SOFTIRQ_ON_OWN_STACK được thiết lập.

Truy cập FPU và SIMD ở chế độ kernel
  Các thanh ghi FPU và SIMD thường không được sử dụng trong chế độ kernel và do đó
  không được lưu trong quá trình ưu tiên kernel. Kết quả là, bất kỳ mã hạt nhân nào sử dụng
  các thanh ghi này phải được đặt trong kernel_fpu_begin() và
  phần kernel_fpu_end().
  Hàm kernel_fpu_begin() thường gọi local_bh_disable() để ngăn chặn
  sự gián đoạn từ softirqs và vô hiệu hóa quyền ưu tiên thông thường. Điều này cho phép
  mã được bảo vệ để chạy an toàn trong cả bối cảnh luồng và softirq.
  Tuy nhiên, trên hạt nhân PREEMPT_RT, kernel_fpu_begin() không được gọi
  local_bh_disable(). Thay vào đó, nó nên sử dụng preempt_disable(), vì softirqs
  luôn được xử lý trong ngữ cảnh luồng trong PREEMPT_RT. Trong trường hợp này, vô hiệu hóa
  chỉ cần quyền ưu tiên là đủ.
  Hệ thống con mật mã hoạt động trên các trang bộ nhớ và yêu cầu người dùng "đi bộ và
  ánh xạ" các trang này trong khi xử lý yêu cầu. Hoạt động này phải xảy ra bên ngoài
  phần kernel_fpu_begin()/ kernel_fpu_end() vì nó yêu cầu quyền ưu tiên
  để được kích hoạt. Những điểm ưu tiên này nói chung là đủ để tránh
  độ trễ lập kế hoạch quá mức.

Trình xử lý ngoại lệ
  Các trình xử lý ngoại lệ, chẳng hạn như trình xử lý lỗi trang, thường cho phép các ngắt
  sớm, trước khi gọi bất kỳ mã chung nào để xử lý ngoại lệ. Đây là
  cần thiết vì việc xử lý lỗi trang có thể liên quan đến các thao tác có thể ngủ.
  Việc kích hoạt các ngắt đặc biệt quan trọng trên PREEMPT_RT, trong trường hợp nhất định
  các khóa, chẳng hạn như spinlock_t, có thể ngủ được. Ví dụ, xử lý một
  opcode không hợp lệ có thể dẫn đến việc gửi tín hiệu SIGILL đến tác vụ người dùng. A
  ngoại lệ gỡ lỗi sẽ gửi tín hiệu SIGTRAP.
  Trong cả hai trường hợp, nếu ngoại lệ xảy ra trong không gian người dùng thì việc kích hoạt là an toàn.
  ngắt quãng sớm. Gửi tín hiệu yêu cầu cả ngắt và kernel
  quyền ưu tiên được kích hoạt.

Tính năng tùy chọn
-----------------

Bộ định thời và nguồn xung nhịp
  Nên sử dụng nguồn xung nhịp và thiết bị sự kiện xung nhịp có độ phân giải cao. các
  thiết bị clockevents phải hỗ trợ tính năng CLOCK_EVT_FEAT_ONESHOT cho
  hành vi hẹn giờ tối ưu. Trong hầu hết các trường hợp, độ chính xác ở mức micro giây là
  đủ

Ưu tiên lười biếng
  Cơ chế này cho phép yêu cầu lập lịch trong kernel cho các tác vụ không theo thời gian thực
  bị trì hoãn cho đến khi tác vụ sắp quay trở lại không gian người dùng. Nó giúp tránh
  ưu tiên một nhiệm vụ có khóa ngủ tại thời điểm lập kế hoạch
  yêu cầu.
  Khi bật CONFIG_GENERIC_IRQ_ENTRY, việc hỗ trợ tính năng này yêu cầu
  xác định một chút cho TIF_NEED_RESCHED_LAZY, tốt nhất là gần TIF_NEED_RESCHED.

Bảng điều khiển nối tiếp với NBCON
  Khi bật PREEMPT_RT, tất cả đầu ra của bảng điều khiển được xử lý bởi một luồng chuyên dụng
  thay vì trực tiếp từ ngữ cảnh mà printk() được gọi. Thiết kế này
  cho phép printk() được sử dụng an toàn trong bối cảnh nguyên tử.
  Tuy nhiên, điều này cũng có nghĩa là nếu kernel gặp sự cố và không thể chuyển sang
  luồng in, sẽ không nhìn thấy đầu ra nào ngăn hệ thống in
  những tin nhắn cuối cùng của nó.
  Có những trường hợp ngoại lệ cho kết quả đầu ra ngay lập tức, chẳng hạn như trong quá trình xử lý hoảng loạn(). Đến
  hỗ trợ điều này, trình điều khiển bảng điều khiển phải triển khai xử lý khóa kiểu mới. Cái này
  liên quan đến việc thiết lập cờ CON_NBCON trong console::flags và cung cấp
  triển khai cho write_atomic, write_thread, device_lock và
  cuộc gọi lại device_unlock.