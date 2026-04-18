.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/irq/irqflags-tracing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Theo dõi trạng thái cờ IRQ
=======================

:Tác giả: bắt đầu bởi Ingo Molnar <mingo@redhat.com>

Tính năng "theo dõi cờ irq" có tính năng "dấu vết" trạng thái hardirq và softirq, trong
rằng nó mang lại cho các hệ thống con quan tâm cơ hội được thông báo về
mọi sự kiện hardirqs-off/hardirqs-on, softirqs-off/softirqs-on
xảy ra trong hạt nhân.

CONFIG_TRACE_IRQFLAGS_SUPPORT là cần thiết cho CONFIG_PROVE_SPIN_LOCKING
và CONFIG_PROVE_RW_LOCKING được cung cấp bằng cách gỡ lỗi khóa chung
mã. Nếu không thì chỉ có CONFIG_PROVE_MUTEX_LOCKING và
CONFIG_PROVE_RWSEM_LOCKING sẽ được cung cấp trên kiến trúc - những kiến trúc này
đang khóa các API không được sử dụng trong ngữ cảnh IRQ. (một ngoại lệ
đối với rwsems đã được xử lý)

Kiến trúc hỗ trợ cho việc này chắc chắn không hề ở mức “tầm thường”
danh mục, bởi vì rất nhiều mã lắp ráp cấp thấp xử lý cờ irq
những thay đổi trạng thái. Nhưng một kiến trúc có thể được kích hoạt theo dõi cờ irq trong một
cách khá đơn giản và không có rủi ro.

Các kiến trúc muốn hỗ trợ điều này cần phải thực hiện một số
thay đổi mã tổ chức đầu tiên:

- thêm và kích hoạt TRACE_IRQFLAGS_SUPPORT trong tệp Kconfig cấp vòm của họ

và sau đó cũng cần một vài thay đổi về chức năng để triển khai
hỗ trợ theo dõi cờ irq:

- trong mã mục nhập cấp thấp, thêm các lệnh gọi (xây dựng có điều kiện) vào
  Các hàm trace_hardirqs_off()/trace_hardirqs_on(). Trình xác nhận khóa
  bảo vệ chặt chẽ xem cờ irq 'thật' có khớp với cờ 'ảo' hay không
  trạng thái cờ irq và phàn nàn lớn tiếng (và tự tắt) nếu
  hai không khớp. Thông thường hầu hết thời gian để hỗ trợ vòm cho
  irq-flags-tracing được sử dụng ở trạng thái này: nhìn vào lockdep
  khiếu nại, hãy thử tìm ra mã lắp ráp mà chúng tôi chưa đề cập đến,
  sửa và lặp lại. Khi hệ thống đã khởi động và hoạt động mà không cần
  khiếu nại lockdep trong hỗ trợ vòm chức năng theo dõi cờ irq là
  hoàn thành.
- nếu kiến trúc có các ngắt không thể che dấu được thì những ngắt đó cần phải được
  được loại trừ khỏi cơ chế irq-tracing [và xác thực khóa] thông qua
  lockdep_off()/lockdep_on().

Nói chung, không có rủi ro nào từ việc theo dõi cờ irq không đầy đủ
triển khai trong một kiến trúc: lockdep sẽ phát hiện điều đó và sẽ
tự tắt. tức là trình xác thực khóa sẽ vẫn đáng tin cậy. Ở đó
sẽ không gặp sự cố do lỗi truy tìm irq. (trừ khi lắp ráp
thay đổi phá vỡ mã khác bằng cách sửa đổi các điều kiện hoặc đăng ký
không nên)

