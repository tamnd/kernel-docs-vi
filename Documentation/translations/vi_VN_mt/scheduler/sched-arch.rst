.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-arch.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================================
Gợi ý triển khai Trình lập lịch CPU cho mã cụ thể của kiến trúc
=======================================================================

Nick Pigin, 2005

Chuyển đổi ngữ cảnh
==============
1. Khóa hàng đợi
Theo mặc định, hàm switch_to Arch được gọi với runqueue
bị khóa. Đây thường không phải là vấn đề trừ khi switch_to có thể cần
lấy khóa runqueue. Điều này thường là do hoạt động đánh thức trong
chuyển đổi ngữ cảnh.

Để yêu cầu bộ lập lịch, hãy gọi switch_to khi đã mở khóa runqueue,
bạn phải có ZZ0000ZZ trong tệp tiêu đề
(thường là nơi switch_to được xác định).

Công tắc ngữ cảnh đã được mở khóa chỉ mang lại hiệu suất rất nhỏ
hình phạt đối với việc triển khai bộ lập lịch cốt lõi trong trường hợp CONFIG_SMP.

CPU nhàn rỗi
========
Các thói quen cpu_idle của bạn cần tuân theo các quy tắc sau:

1. Quyền ưu tiên bây giờ sẽ bị vô hiệu hóa đối với các hoạt động không hoạt động. Chỉ nên
   được kích hoạt để gọi lịch trình() sau đó lại bị vô hiệu hóa.

2. need_resched/TIF_NEED_RESCHED chỉ được thiết lập và sẽ không bao giờ
   sẽ bị xóa cho đến khi tác vụ đang chạy được gọi là lịch trình(). Nhàn rỗi
   các chủ đề chỉ cần truy vấn need_resched và không bao giờ có thể đặt hoặc
   xóa nó.

3. Khi cpu_idle tìm thấy (need_resched() == 'true'), nó sẽ gọi
   lịch(). Nếu không thì nó không nên gọi lịch trình().

4. Cần phải tắt các ngắt thời gian duy nhất khi kiểm tra
   need_resched là nếu chúng ta chuẩn bị tạm dừng bộ xử lý cho đến khi
   ngắt tiếp theo (điều này không cung cấp bất kỳ sự bảo vệ nào cho
   need_resched, nó sẽ tránh mất ngắt):

4a. Vấn đề thường gặp với kiểu ngủ này là::

local_irq_disable();
	        nếu (!need_resched()) {
	                local_irq_enable();
	                ZZ0001ZZ
	                __asm__("ngủ cho đến khi bị gián đoạn tiếp theo");
	        }

5. TIF_POLLING_NRFLAG có thể được thiết lập bằng các thói quen nhàn rỗi không
   cần một ngắt để đánh thức chúng khi Need_resched lên cao.
   Nói cách khác, họ phải thăm dò định kỳ Need_resched,
   mặc dù có thể hợp lý nếu thực hiện một số công việc nền hoặc nhập
   mức độ ưu tiên CPU thấp.

- 5a. Nếu TIF_POLLING_NRFLAG được đặt và chúng tôi quyết định nhập
	một giấc ngủ bị gián đoạn, nó cần được xóa sạch rồi một ký ức
	rào cản được ban hành (tiếp theo là kiểm tra Need_resched với
	ngắt bị vô hiệu hóa, như được giải thích trong 3).

Arch/x86/kernel/process.c có các ví dụ về cả bỏ phiếu và
ngủ chức năng nhàn rỗi.


Vòm/vấn đề có thể xảy ra
=======================

Các vấn đề về vòm có thể xảy ra mà tôi đã tìm thấy (và đã cố gắng khắc phục hoặc không):

sparc - IRQ bật tại thời điểm này(?), thay đổi local_irq_save thành _disable.
      - TODO: cần CPU phụ để vô hiệu hóa tính năng ưu tiên (Xem #1)
