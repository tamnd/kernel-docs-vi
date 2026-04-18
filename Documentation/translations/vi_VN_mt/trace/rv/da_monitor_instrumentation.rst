.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/da_monitor_instrumentation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thiết bị tự động xác định
======================================

Tệp màn hình RV được tạo bởi dot2k, có tên "$MODEL_NAME.c"
bao gồm một phần dành riêng cho thiết bị đo đạc.

Trong ví dụ về màn hình wip.dot được tạo trên [1], nó sẽ trông giống như::

/*
   * Đây là phần thiết bị của màn hình.
   *
   * Đây là phần yêu cầu phải làm việc thủ công. Ở đây các sự kiện hạt nhân
   * được dịch sang sự kiện của mô hình.
   *
   */
  static void hand_preempt_disable(void ZZ0000ZZ XXX: điền tiêu đề */)
  {
	da_handle_event_wip(preempt_disable_wip);
  }

static void hand_preempt_enable(void ZZ0000ZZ XXX: điền tiêu đề */)
  {
	da_handle_event_wip(preempt_enable_wip);
  }

static void hand_sched_waking(void ZZ0000ZZ XXX: điền tiêu đề */)
  {
	da_handle_event_wip(lịch_waking_wip);
  }

int tĩnh Enable_wip(void)
  {
	int trả về;

retval = da_monitor_init_wip();
	nếu (retval)
		trả lại;

rv_attach_trace_probe("wip", /* XXX: tracepoint */, hand_preempt_disable);
	rv_attach_trace_probe("wip", /* XXX: tracepoint */, hand_preempt_enable);
	rv_attach_trace_probe("wip", /* XXX: tracepoint */, hand_sched_waking);

trả về 0;
  }

Nhận xét ở đầu phần này giải thích ý tưởng chung:
phần thiết bị đo đạc chuyển ZZ0000ZZ sang *model
sự kiện*.

Truy tìm các chức năng gọi lại
--------------------------

Ba hàm đầu tiên là điểm bắt đầu của trình xử lý *gọi lại
các chức năng* cho từng sự kiện trong số ba sự kiện từ mô hình xóa sạch. Nhà phát triển
không nhất thiết phải sử dụng chúng: chúng chỉ là điểm khởi đầu.

Sử dụng ví dụ về::

void hand_preempt_disable(void ZZ0000ZZ XXX: điền tiêu đề */)
 {
        da_handle_event_wip(preempt_disable_wip);
 }

Sự kiện preempt_disable từ mô hình kết nối trực tiếp với
ưu tiên: ưu tiên_disable. Sự kiện preemptirq:preempt_disable
có chữ ký sau, từ include/trace/events/preemptirq.h::

TP_PROTO(ip dài không dấu, parent_ip dài không dấu)

Do đó, hàm hand_preempt_disable() sẽ có dạng::

void hand_preempt_disable(void *data, unsigned long ip, unsigned long parent_ip)

Trong trường hợp này, sự kiện kernel dịch từng cái một bằng automata
sự kiện, và thực sự, không có thay đổi nào khác được yêu cầu cho chức năng này.

Hàm xử lý tiếp theo, hand_preempt_enable() có cùng đối số
danh sách từ hand_preempt_disable(). Sự khác biệt là ở chỗ
Sự kiện preempt_enable sẽ được dùng để đồng bộ hệ thống với model.

Ban đầu, ZZ0000ZZ được đặt ở trạng thái ban đầu. Tuy nhiên, ZZ0001ZZ
có thể ở trạng thái ban đầu hoặc không. Màn hình không thể khởi động
xử lý các sự kiện cho đến khi biết hệ thống đã đạt đến trạng thái ban đầu.
Nếu không, màn hình và hệ thống có thể không đồng bộ.

Nhìn vào định nghĩa automata, có thể thấy rằng hệ thống
và mô hình dự kiến sẽ trở lại trạng thái ban đầu sau
preempt_enable thực thi. Do đó, nó có thể được sử dụng để đồng bộ hóa
hệ thống và mô hình khi khởi tạo phần giám sát.

Việc bắt đầu được thông báo thông qua một chức năng xử lý đặc biệt,
"da_handle_start_event_$(MONITOR_NAME)(event)", trong trường hợp này::

da_handle_start_event_wip(preempt_enable_wip);

Vì vậy, hàm gọi lại sẽ có dạng::

void hand_preempt_enable(void *data, unsigned long ip, unsigned long parent_ip)
  {
        da_handle_start_event_wip(preempt_enable_wip);
  }

Cuối cùng, "handle_sched_waking()" sẽ có dạng::

void xử lý_sched_waking(void *data, struct task_struct *task)
  {
        da_handle_event_wip(lịch_waking_wip);
  }

Và lời giải thích dành cho người đọc như một bài tập.

kích hoạt và vô hiệu hóa chức năng
----------------------------

dot2k tự động tạo hai hàm đặc biệt::

Enable_$(MONITOR_NAME)()
  vô hiệu hóa_$(MONITOR_NAME)()

Các chức năng này được gọi khi màn hình được bật và tắt,
tương ứng.

Chúng nên được sử dụng cho ZZ0000ZZ và ZZ0001ZZ thiết bị đo đạc để chạy
hệ thống. Nhà phát triển phải thêm vào chức năng tương đối tất cả những gì cần thiết để
ZZ0002ZZ và ZZ0003ZZ màn hình của nó vào hệ thống.

Đối với trường hợp wip, các hàm này được đặt tên::

kích hoạt_wip()
 vô hiệu hóa_wip()

Nhưng không cần thay đổi vì: theo mặc định, các chức năng này ZZ0000ZZ và
ZZ0001ZZ tracepoints_to_attach, đủ cho trường hợp này.

Người trợ giúp thiết bị
-----------------------

Để hoàn thiện thiết bị đo, ZZ0000ZZ cần được gắn vào một
sự kiện kernel, ở giai đoạn kích hoạt giám sát.

Giao diện RV cũng hỗ trợ bước này. Ví dụ: macro "rv_attach_trace_probe()"
được sử dụng để kết nối các sự kiện mô hình wip với sự kiện kernel tương đối. dot2k tự động
thêm lệnh gọi hàm "rv_attach_trace_probe()" cho từng sự kiện mô hình trong giai đoạn kích hoạt, như
một gợi ý.

Ví dụ: từ mô hình mẫu wip ::

int tĩnh Enable_wip(void)
  {
        int trả về;

retval = da_monitor_init_wip();
        nếu (retval)
                trả lại;

rv_attach_trace_probe("wip", /* XXX: tracepoint */, hand_preempt_enable);
        rv_attach_trace_probe("wip", /* XXX: tracepoint */, hand_sched_waking);
        rv_attach_trace_probe("wip", /* XXX: tracepoint */, hand_preempt_disable);

trả về 0;
  }

Sau đó, các đầu dò cần được tháo ra ở giai đoạn vô hiệu hóa.

[1] Mô hình wip được trình bày trong:

Tài liệu/trace/rv/deterministic_automata.rst

Màn hình wip được trình bày trong:

Tài liệu/trace/rv/monitor_synt tổng hợp.rst
