.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/suspend-and-interrupts.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Tạm dừng hệ thống và ngắt thiết bị
========================================

Bản quyền (C) 2014 Intel Corp.
Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Tạm dừng và tiếp tục IRQ của thiết bị
-----------------------------------

Các dòng yêu cầu ngắt thiết bị (IRQ) thường bị vô hiệu hóa trong quá trình hệ thống
tạm dừng sau giai đoạn "muộn" của việc tạm dừng thiết bị (nghĩa là sau tất cả các
->prepare, ->suspend và ->suspend_late callback đã được thực thi cho tất cả
thiết bị).  Việc đó được thực hiện bằng cách đình chỉ_device_irqs().

Lý do để làm như vậy là sau giai đoạn "trễ" của thiết bị, việc tạm dừng
không có lý do chính đáng nào giải thích tại sao bất kỳ sự gián đoạn nào từ các thiết bị bị treo sẽ
kích hoạt và nếu bất kỳ thiết bị nào chưa được tạm dừng đúng cách, tốt hơn là nên
chặn các ngắt từ chúng.  Ngoài ra, trước đây chúng tôi cũng gặp vấn đề với
trình xử lý ngắt cho các IRQ được chia sẻ mà trình điều khiển thiết bị triển khai chúng là
không chuẩn bị cho việc kích hoạt ngắt sau khi thiết bị của họ bị treo.
Trong một số trường hợp, họ sẽ cố gắng truy cập, chẳng hạn như không gian địa chỉ bộ nhớ
của các thiết bị bị đình chỉ và kết quả là gây ra hành vi không thể đoán trước.
Thật không may, những vấn đề như vậy rất khó gỡ lỗi và việc giới thiệu
của đình chỉ_device_irqs(), cùng với giai đoạn "noirq" của việc tạm dừng thiết bị và
sơ yếu lý lịch, là cách thực tế duy nhất để giảm thiểu chúng.

IRQ của thiết bị được bật lại trong quá trình hệ thống tiếp tục, ngay trước giai đoạn "sớm"
của việc tiếp tục các thiết bị (nghĩa là trước khi bắt đầu thực thi ->resume_early
cuộc gọi lại cho các thiết bị).  Hàm thực hiện điều đó là sơ yếu lý lịch_device_irqs().


Cờ IRQF_NO_SUSPEND
------------------------

Có những ngắt có thể kích hoạt hợp pháp trong toàn bộ hệ thống
chu trình tạm dừng-tiếp tục, bao gồm các giai đoạn tạm dừng và tiếp tục "noirq"
các thiết bị cũng như trong thời gian CPU không khởi động được ngoại tuyến và
đưa trở lại trực tuyến.  Điều đó áp dụng cho việc ngắt hẹn giờ ngay từ đầu,
mà còn đối với IPI và một số ngắt có mục đích đặc biệt khác.

Cờ IRQF_NO_SUSPEND được sử dụng để chỉ ra điều đó cho hệ thống con IRQ khi
yêu cầu một ngắt có mục đích đặc biệt.  Nó khiến cho đình chỉ_device_irqs()
để IRQ tương ứng được kích hoạt để cho phép ngắt hoạt động như
dự kiến trong chu kỳ tạm dừng-tiếp tục, nhưng không đảm bảo rằng
ngắt sẽ đánh thức hệ thống từ trạng thái treo - đối với những trường hợp như vậy thì
cần thiết phải sử dụng allow_irq_wake().

Lưu ý rằng cờ IRQF_NO_SUSPEND ảnh hưởng đến toàn bộ IRQ chứ không chỉ một
người sử dụng nó.  Do đó, nếu IRQ được chia sẻ, tất cả các trình xử lý ngắt được cài đặt
vì nó sẽ được thực thi như bình thường sau khi đình chỉ_device_irqs(), ngay cả khi
Cờ IRQF_NO_SUSPEND không được chuyển tới request_irq() (hoặc tương đương) bởi một số
người dùng IRQ.  Vì lý do này, việc sử dụng IRQF_NO_SUSPEND và IRQF_SHARED tại
cùng một lúc nên tránh.


Ngắt đánh thức hệ thống, allow_irq_wake() và vô hiệu hóa_irq_wake()
------------------------------------------------------------------

Các ngắt đánh thức hệ thống thường cần được cấu hình để đánh thức hệ thống
khỏi trạng thái ngủ, đặc biệt nếu chúng được sử dụng cho các mục đích khác nhau (ví dụ như
ngắt I/O) ở trạng thái làm việc.

Điều đó có thể liên quan đến việc bật logic xử lý tín hiệu đặc biệt trong nền tảng
(chẳng hạn như SoC) để tín hiệu từ một đường truyền nhất định được định tuyến theo một cách khác
trong khi hệ thống ngủ để kích hoạt đánh thức hệ thống khi cần thiết.  Ví dụ,
nền tảng có thể bao gồm một bộ điều khiển ngắt chuyên dụng được sử dụng riêng cho
xử lý các sự kiện đánh thức hệ thống.  Sau đó, nếu một đường ngắt nhất định được cho là
đánh thức hệ thống khỏi trạng thái ngủ, đầu vào tương ứng của ngắt đó
bộ điều khiển cần được kích hoạt để nhận tín hiệu từ đường dây được đề cập.
Sau khi thức dậy, tốt hơn hết bạn nên tắt đầu vào đó để ngăn chặn
bộ điều khiển chuyên dụng khỏi kích hoạt các ngắt không cần thiết.

Hệ thống con IRQ cung cấp hai chức năng trợ giúp được trình điều khiển thiết bị sử dụng để
những mục đích đó.  Cụ thể là, Enable_irq_wake() bật logic của nền tảng cho
xử lý IRQ đã cho dưới dạng dòng ngắt đánh thức hệ thống và vô hiệu hóa_irq_wake()
tắt logic đó đi.

Gọi Enable_irq_wake() khiến cho đình chỉ_device_irqs() xử lý IRQ đã cho
một cách đặc biệt.  Cụ thể, IRQ vẫn được bật, nhưng ở lần ngắt đầu tiên
nó sẽ bị vô hiệu hóa, được đánh dấu là đang chờ xử lý và "bị treo" để nó sẽ được
được kích hoạt lại bởi sơ yếu lý lịch_device_irqs() trong quá trình tiếp tục hệ thống tiếp theo.  Ngoài ra
lõi PM được thông báo về sự kiện khiến hệ thống tạm dừng trong
tiến trình bị hủy bỏ (điều đó không nhất thiết phải xảy ra ngay lập tức, nhưng tại một thời điểm
trong số các điểm mà luồng tạm dừng tìm kiếm các sự kiện đánh thức đang chờ xử lý).

Bằng cách này, mọi ngắt từ nguồn ngắt đánh thức sẽ gây ra
hệ thống đang tạm dừng hiện tại sẽ bị hủy bỏ hoặc đánh thức hệ thống nếu
đã bị đình chỉ rồi.  Tuy nhiên, sau khi xử lý ngắt Suspend_device_irqs() là
không được thực thi đối với các IRQ đánh thức hệ thống.  Chúng chỉ được thực thi cho IRQF_NO_SUSPEND
IRQ tại thời điểm đó, nhưng những IRQ đó không nên được cấu hình để đánh thức hệ thống
sử dụng Enable_irq_wake().


Ngắt và tạm dừng để không hoạt động
------------------------------

Tạm dừng ở trạng thái không hoạt động (còn được gọi là trạng thái ngủ "đóng băng") là một trạng thái tương đối mới
trạng thái ngủ của hệ thống hoạt động bằng cách cho tất cả các bộ xử lý chạy không tải và chờ đợi
ngắt ngay sau giai đoạn "noirq" của thiết bị treo.

Tất nhiên, điều này có nghĩa là tất cả các ngắt có cờ IRQF_NO_SUSPEND
được thiết lập sẽ khiến CPU không hoạt động khi ở trạng thái đó, nhưng chúng sẽ không gây ra
Hệ thống con IRQ để kích hoạt đánh thức hệ thống.

Ngược lại, các ngắt đánh thức hệ thống sẽ kích hoạt đánh thức từ trạng thái tạm dừng sang không hoạt động trong
tương tự với những gì họ làm trong trường hợp tạm dừng toàn bộ hệ thống.  Sự khác biệt duy nhất
là việc đánh thức từ trạng thái tạm dừng sang không hoạt động được báo hiệu bằng cách sử dụng phương pháp làm việc thông thường
cơ chế phân phối ngắt trạng thái và không yêu cầu nền tảng sử dụng
bất kỳ logic xử lý ngắt đặc biệt nào để nó hoạt động.


IRQF_NO_SUSPEND và Enable_irq_wake()
-------------------------------------

Có rất ít lý do hợp lệ để sử dụng cả Enable_irq_wake() và
Cờ IRQF_NO_SUSPEND trên cùng một IRQ và việc sử dụng cả hai cho
cùng một thiết bị.

Trước hết, nếu IRQ không được chia sẻ thì quy tắc xử lý IRQF_NO_SUSPEND
các ngắt (trình xử lý ngắt được gọi sau khi đình chỉ_device_irqs()) là
mâu thuẫn trực tiếp với các quy tắc xử lý các ngắt đánh thức hệ thống (ngắt
trình xử lý không được gọi sau khi đình chỉ_device_irqs()).

Thứ hai, cả Enable_irq_wake() và IRQF_NO_SUSPEND đều áp dụng cho toàn bộ IRQ chứ không phải
tới các trình xử lý ngắt riêng lẻ, do đó việc chia sẻ IRQ giữa quá trình đánh thức hệ thống
nguồn ngắt và nguồn ngắt IRQF_NO_SUSPEND thường không
có ý nghĩa.

Trong một số trường hợp hiếm hoi, IRQ có thể được chia sẻ giữa trình điều khiển thiết bị đánh thức và
Người dùng IRQF_NO_SUSPEND. Để việc này được an toàn, trình điều khiển thiết bị đánh thức
phải có khả năng phân biệt các IRQ giả với các sự kiện đánh thức thực sự (báo hiệu
cái sau vào lõi với pm_system_wakeup()), phải sử dụng Enable_irq_wake() để
đảm bảo rằng IRQ sẽ hoạt động như một nguồn đánh thức và phải yêu cầu IRQ
với IRQF_COND_SUSPEND để thông báo với lõi rằng nó đáp ứng các yêu cầu này. Nếu
những yêu cầu này không được đáp ứng, việc sử dụng IRQF_COND_SUSPEND là không hợp lệ.
