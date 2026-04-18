.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/tracepoints.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Sử dụng Điểm theo dõi hạt nhân Linux
=====================================

:Tác giả: Mathieu Desnoyers


Tài liệu này giới thiệu Tracepoint hạt nhân Linux và cách sử dụng chúng. Nó
cung cấp các ví dụ về cách chèn dấu vết vào kernel và
kết nối các chức năng thăm dò với chúng và cung cấp một số ví dụ về thăm dò
chức năng.


Mục đích của dấu vết
----------------------
Một dấu vết được đặt trong mã cung cấp một cái móc để gọi hàm (thăm dò)
mà bạn có thể cung cấp trong thời gian chạy. Một điểm theo dõi có thể được "bật" (một đầu dò được
được kết nối với nó) hoặc "tắt" (không gắn đầu dò). Khi có một điểm theo dõi
"tắt" nó không có tác dụng gì, ngoại trừ việc thêm một hình phạt thời gian nhỏ
(kiểm tra điều kiện cho một nhánh) và phạt khoảng trống (thêm một vài
byte cho lệnh gọi hàm ở cuối hàm được điều chỉnh
và thêm cấu trúc dữ liệu vào một phần riêng biệt).  Khi một dấu vết
là "bật", chức năng bạn cung cấp sẽ được gọi mỗi khi điểm theo dõi
được thực thi, trong bối cảnh thực thi của người gọi. Khi chức năng
với điều kiện kết thúc quá trình thực thi của nó, nó sẽ trả về cho người gọi (tiếp tục từ
trang web tracepoint).

Bạn có thể đặt dấu vết tại các vị trí quan trọng trong mã. Họ là
móc nhẹ có thể truyền một số lượng tham số tùy ý,
nguyên mẫu của nó được mô tả trong một khai báo tracepoint được đặt trong một
tập tin tiêu đề.

Chúng có thể được sử dụng để theo dõi và tính toán hiệu suất.


Cách sử dụng
------------
Hai yếu tố cần thiết cho tracepoint:

- Định nghĩa tracepoint, được đặt trong tệp tiêu đề.
- Câu lệnh tracepoint, bằng mã C.

Để sử dụng tracepoint, bạn nên bao gồm linux/tracepoint.h.

Trong bao gồm/trace/event/subsys.h::

#undef TRACE_SYSTEM
	Hệ thống con #define TRACE_SYSTEM

#if !được xác định(_TRACE_SUBSYS_H) || được xác định (TRACE_HEADER_MULTI_READ)
	#define _TRACE_SUBSYS_H

#include <linux/tracepoint.h>

DECLARE_TRACE(tên sự kiện phụ,
		TP_PROTO(int firstarg, struct task_struct *p),
		TP_ARGS(đầu tiên, p));

#endif /*_TRACE_SUBSYS_H */

/*Phần này phải được bảo vệ bên ngoài */
	#include <trace/define_trace.h>

Trong subsys/file.c (nơi phải thêm câu lệnh theo dõi)::

#include <trace/events/subsys.h>

#define CREATE_TRACE_POINTS
	DEFINE_TRACE(tên sự kiện phụ);

void somefct(void)
	{
		...
trace_subsys_eventname_tp(arg, task);
		...
	}

Ở đâu:
  - subsys_eventname là mã định danh duy nhất cho sự kiện của bạn

- subsys là tên hệ thống con của bạn.
    - tên sự kiện là tên của sự kiện cần theo dõi.

- ZZ0000ZZ là nguyên mẫu của
    chức năng được gọi bởi tracepoint này.

- ZZ0000ZZ là tên các tham số, giống như được tìm thấy trong
    nguyên mẫu.

- nếu bạn sử dụng tiêu đề trong nhiều tệp nguồn, ZZ0000ZZ
    chỉ nên xuất hiện trong một tệp nguồn.

Việc kết nối một chức năng (đầu dò) với một điểm theo dõi được thực hiện bằng cách cung cấp một
thăm dò (chức năng gọi) cho tracepoint cụ thể thông qua
register_trace_subsys_eventname().  Việc loại bỏ đầu dò được thực hiện thông qua
hủy đăng ký_trace_subsys_eventname(); nó sẽ loại bỏ đầu dò.

tracepoint_synchronize_unregister() phải được gọi trước khi kết thúc
chức năng thoát mô-đun để đảm bảo không còn người gọi nào sử dụng
máy dò. Điều này và thực tế là quyền ưu tiên bị vô hiệu hóa xung quanh
cuộc gọi thăm dò, hãy đảm bảo rằng việc tháo đầu dò và dỡ mô-đun được an toàn.

Cơ chế theo dõi hỗ trợ chèn nhiều phiên bản của
cùng một điểm theo dõi, nhưng một định nghĩa duy nhất phải được tạo thành từ một định nghĩa nhất định
tên tracepoint trên toàn bộ kernel để đảm bảo sẽ không có xung đột kiểu
xảy ra. Việc xáo trộn tên của các điểm theo dõi được thực hiện bằng cách sử dụng các nguyên mẫu
để đảm bảo gõ là chính xác. Xác minh tính chính xác của loại đầu dò
được thực hiện tại nơi đăng ký bởi trình biên dịch. Dấu vết có thể được
đưa vào các hàm nội tuyến, các hàm tĩnh nội tuyến và các vòng lặp không được kiểm soát
cũng như các chức năng thông thường.

Sơ đồ đặt tên "subsys_event" được đề xuất ở đây như một quy ước
nhằm hạn chế va chạm. Tên dấu vết có tính chất toàn cầu đối với
kernel: chúng được coi là giống nhau cho dù chúng ở trong
hình ảnh hạt nhân lõi hoặc trong các mô-đun.

Nếu điểm theo dõi phải được sử dụng trong các mô-đun hạt nhân,
EXPORT_TRACEPOINT_SYMBOL_GPL() hoặc EXPORT_TRACEPOINT_SYMBOL() có thể
được sử dụng để xuất các dấu vết đã xác định.

Nếu bạn cần thực hiện một chút công việc cho tham số tracepoint và
công việc đó chỉ dùng cho tracepoint, công việc đó có thể được gói gọn
trong câu lệnh if với nội dung sau::

nếu (trace_foo_bar_enabled()) {
		int tôi;
		int tot = 0;

cho (i = 0; i < đếm; i++)
			tot += tính_nuggets();

trace_foo_bar_tp(tot);
	}

Tất cả các lệnh gọi trace_<tracepoint>_tp() đều có trace_<tracepoint>_enabled() phù hợp
hàm được xác định sẽ trả về true nếu tracepoint được bật và
sai nếu không. trace_<tracepoint>_tp() phải luôn nằm trong
khối if (trace_<tracepoint>_enabled()) để ngăn chặn các cuộc đua giữa
điểm theo dõi đang được kích hoạt và kiểm tra đang được nhìn thấy.

Ưu điểm của việc sử dụng trace_<tracepoint>_enabled() là nó sử dụng
static_key của tracepoint để cho phép thực hiện câu lệnh if
với nhãn nhảy và tránh các nhánh có điều kiện.

.. note:: The convenience macro TRACE_EVENT provides an alternative way to
      define tracepoints. Note, DECLARE_TRACE(foo) creates a function
      "trace_foo_tp()" whereas TRACE_EVENT(foo) creates a function
      "trace_foo()", and also exposes the tracepoint as a trace event in
      /sys/kernel/tracing/events directory.  Check http://lwn.net/Articles/379903,
      http://lwn.net/Articles/381064 and http://lwn.net/Articles/383362
      for a series of articles with more details.

Nếu bạn yêu cầu gọi một điểm theo dõi từ một tệp tiêu đề thì không phải vậy.
nên gọi trực tiếp hoặc sử dụng trace_<tracepoint>_enabled()
lệnh gọi hàm, vì các điểm theo dõi trong các tệp tiêu đề có thể có tác dụng phụ nếu
tiêu đề được bao gồm từ một tệp có bộ CREATE_TRACE_POINTS, như
cũng như trace_<tracepoint>() không phải là một nội tuyến nhỏ
và có thể làm phồng kernel nếu được sử dụng bởi các hàm nội tuyến khác. Thay vào đó,
bao gồm tracepoint-defs.h và sử dụng tracepoint_enabled().

Trong tệp C::

void do_trace_foo_bar_wrapper(args)
	{
		trace_foo_bar_tp(args); // cho các điểm theo dõi được tạo thông qua DECLARE_TRACE
					// hoặc
		trace_foo_bar(args);    // cho các điểm theo dõi được tạo thông qua TRACE_EVENT
	}

Trong tệp tiêu đề::

DECLARE_TRACEPOINT(foo_bar);

nội tuyến tĩnh void some_inline_function()
	{
		[..]
		nếu (tracepoint_enabled(foo_bar))
			do_trace_foo_bar_wrapper(args);
		[..]
	}
