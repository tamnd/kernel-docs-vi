.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/events-nmi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Sự kiện theo dõi NMI
================

Những sự kiện này thường hiển thị ở đây:

/sys/kernel/tracing/sự kiện/nmi


nmi_handler
-----------

Bạn có thể muốn sử dụng điểm theo dõi này nếu bạn nghi ngờ rằng
Trình xử lý NMI đang ngốn rất nhiều thời gian của CPU.  Hạt nhân
sẽ cảnh báo nếu nó thấy các trình xử lý chạy dài ::

INFO: Trình xử lý NMI mất quá nhiều thời gian để chạy: 9,207 mili giây

và điểm theo dõi này sẽ cho phép bạn đi sâu hơn và có được một số
biết thêm chi tiết.

Giả sử bạn nghi ngờ rằng perf_event_nmi_handler() đang gây ra
bạn có một số vấn đề và bạn chỉ muốn theo dõi trình xử lý đó
cụ thể.  Bạn cần tìm địa chỉ của nó::

$ grep perf_event_nmi_handler /proc/kallsyms
	ffffffff81625600 t perf_event_nmi_handler

Giả sử bạn chỉ quan tâm khi chức năng đó được
thực sự ngốn rất nhiều thời gian của CPU, giống như một phần nghìn giây mỗi lần.
Lưu ý rằng đầu ra của kernel tính bằng mili giây, nhưng đầu vào
đến bộ lọc tính bằng nano giây!  Bạn có thể lọc trên 'delta_ns'::

cd /sys/kernel/tracing/events/nmi/nmi_handler
	echo 'handler==0xffffffff81625600 && delta_ns>1000000' > bộ lọc
	echo 1 > kích hoạt

Đầu ra của bạn sau đó sẽ trông giống như::

$ cat /sys/kernel/tracing/trace_pipe
	<nhàn rỗi>-0 [000] d.h3 505.397558: nmi_handler: perf_event_nmi_handler() delta_ns: 3236765 đã xử lý: 1
	<nhàn rỗi>-0 [000] d.h3 505.805893: nmi_handler: perf_event_nmi_handler() delta_ns: 3174234 đã xử lý: 1
	<nhàn rỗi>-0 [000] d.h3 506.158206: nmi_handler: perf_event_nmi_handler() delta_ns: 3084642 đã xử lý: 1
	<nhàn rỗi>-0 [000] d.h3 506.334346: nmi_handler: perf_event_nmi_handler() delta_ns: 3080351 đã xử lý: 1

