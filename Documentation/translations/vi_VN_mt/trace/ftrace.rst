.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/ftrace.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
ftrace - Trình theo dõi chức năng
=================================

Bản quyền 2008 Red Hat Inc.

:Tác giả: Steven Rostedt <srostedt@redhat.com>
:Giấy phép: Giấy phép Tài liệu Miễn phí GNU, Phiên bản 1.2
          (được cấp phép kép theo GPL v2)
:Người đánh giá gốc: Elias Oltmanns, Randy Dunlap, Andrew Morton,
		      John Kacur và David Teigland.

- Viết cho: 2.6.28-rc2
- Cập nhật cho: 3.10
- Đã cập nhật cho: 4.13 - Bản quyền 2017 VMware Inc. Steven Rostedt
- Đã chuyển đổi sang định dạng đầu tiên - Changbin Du <changbin.du@intel.com>

Giới thiệu
------------

Ftrace là một công cụ theo dõi nội bộ được thiết kế để giúp các nhà phát triển và
người thiết kế hệ thống để tìm ra điều gì đang diễn ra bên trong hạt nhân.
Nó có thể được sử dụng để gỡ lỗi hoặc phân tích độ trễ và
các vấn đề về hiệu suất diễn ra bên ngoài không gian người dùng.

Mặc dù ftrace thường được coi là công cụ theo dõi hàm, nhưng nó
thực sự là một khuôn khổ của một số tiện ích theo dõi các loại.
Có tính năng theo dõi độ trễ để kiểm tra điều gì xảy ra giữa các lần ngắt
bị vô hiệu hóa và được kích hoạt, cũng như để giành quyền ưu tiên và từ một thời điểm
một nhiệm vụ được đánh thức khi nhiệm vụ đó thực sự được lên lịch.

Một trong những ứng dụng phổ biến nhất của ftrace là theo dõi sự kiện.
Xuyên suốt kernel là hàng trăm điểm sự kiện tĩnh
có thể được kích hoạt thông qua hệ thống tệp tracefs để xem những gì
đang diễn ra trong một số phần của kernel.

Xem events.rst để biết thêm thông tin.


Chi tiết triển khai
----------------------

Xem Documentation/trace/ftrace-design.rst để biết chi tiết về các porter vòm và những thứ tương tự.


Hệ thống tập tin
----------------

Ftrace sử dụng hệ thống tệp tracefs để giữ các tệp điều khiển dưới dạng
cũng như các tập tin để hiển thị đầu ra.

Khi tracefs được cấu hình vào kernel (chọn bất kỳ ftrace nào
tùy chọn sẽ làm) thư mục /sys/kernel/tracing sẽ được tạo. Để gắn kết
thư mục này, bạn có thể thêm vào tệp /etc/fstab của mình::

tracefs/sys/kernel/tracing tracefs mặc định 0 0

Hoặc bạn có thể gắn kết nó trong thời gian chạy với ::

mount -t tracefs nodev/sys/kernel/tracing

Để truy cập nhanh hơn vào thư mục đó, bạn có thể muốn tạo một liên kết mềm tới
nó::

ln -s/sys/kernel/truy tìm/truy tìm

.. attention::

  Before 4.1, all ftrace tracing control files were within the debugfs
  file system, which is typically located at /sys/kernel/debug/tracing.
  For backward compatibility, when mounting the debugfs file system,
  the tracefs file system will be automatically mounted at:

  /sys/kernel/debug/tracing

  All files located in the tracefs file system will be located in that
  debugfs file system directory as well.

.. attention::

  Any selected ftrace option will also create the tracefs file system.
  The rest of the document will assume that you are in the ftrace directory
  (cd /sys/kernel/tracing) and will only concentrate on the files within that
  directory and not distract from the content with the extended
  "/sys/kernel/tracing" path name.

Thế thôi! (giả sử rằng bạn đã cấu hình ftrace trong kernel của mình)

Sau khi gắn tracefs, bạn sẽ có quyền truy cập vào các tệp điều khiển và đầu ra
của ftrace. Dưới đây là danh sách một số tập tin chính:


Lưu ý: tất cả các giá trị thời gian được tính bằng micro giây.

current_tracer:

Điều này được sử dụng để thiết lập hoặc hiển thị công cụ theo dõi hiện tại
	đó đã được cấu hình. Thay đổi xóa dấu vết hiện tại
	nội dung bộ đệm vòng cũng như bộ đệm "ảnh chụp nhanh".

có sẵn_tracers:

Điều này chứa các loại công cụ theo dõi khác nhau
	đã được biên dịch vào kernel. các
	các công cụ theo dõi được liệt kê ở đây có thể được cấu hình bởi
	lặp lại tên của họ vào current_tracer.

truy tìm_on:

Điều này đặt hoặc hiển thị việc ghi vào dấu vết
	bộ đệm vòng được kích hoạt. Echo 0 vào file này để vô hiệu hóa
	dấu vết hoặc 1 để kích hoạt nó. Lưu ý, điều này chỉ vô hiệu hóa
	ghi vào bộ đệm vòng, chi phí theo dõi có thể
	vẫn đang xảy ra.

Hàm kernel tracing_off() có thể được sử dụng trong
	kernel để vô hiệu hóa việc ghi vào bộ đệm vòng, điều này sẽ
	đặt tập tin này thành "0". Không gian người dùng có thể kích hoạt lại tính năng theo dõi bằng cách
	lặp lại "1" vào tập tin.

Lưu ý, chức năng và sự kiện kích hoạt "theo dõi" cũng sẽ
	đặt tập tin này về 0 và dừng theo dõi. Mà cũng có thể
	được kích hoạt lại bởi không gian người dùng bằng tệp này.

dấu vết:

Tập tin này chứa đầu ra của dấu vết trong một con người
	dạng có thể đọc được (được mô tả bên dưới). Mở tập tin này cho
	ghi bằng cờ O_TRUNC sẽ xóa nội dung bộ đệm vòng.
        Lưu ý, tập tin này không phải là một người tiêu dùng. Nếu theo dõi bị tắt
        (không có dấu vết nào đang chạy hoặc tracing_on bằng 0), nó sẽ tạo ra
        cùng một đầu ra mỗi lần nó được đọc. Khi tính năng theo dõi được bật,
        nó có thể tạo ra kết quả không nhất quán khi nó cố đọc
        toàn bộ bộ đệm mà không tiêu tốn nó.

trace_pipe:

Đầu ra giống như tệp "dấu vết" nhưng tệp này
	tập tin có nghĩa là được phát trực tuyến với tính năng theo dõi trực tiếp.
	Việc đọc từ tệp này sẽ bị chặn cho đến khi có dữ liệu mới
	đã lấy lại.  Không giống như tệp "dấu vết", tệp này là một
	người tiêu dùng. Điều này có nghĩa là việc đọc từ tập tin này sẽ gây ra
	đọc tuần tự để hiển thị nhiều dữ liệu hiện tại hơn. Một lần
	dữ liệu được đọc từ tập tin này, nó được sử dụng và
	sẽ không được đọc lại bằng cách đọc tuần tự. các
	Tệp "dấu vết" là tĩnh và nếu trình theo dõi không
	thêm nhiều dữ liệu hơn, nó sẽ hiển thị tương tự
	thông tin mỗi khi nó được đọc.

trace_options:

Tệp này cho phép người dùng kiểm soát lượng dữ liệu
	được hiển thị ở một trong những kết quả đầu ra ở trên
	tập tin. Các tùy chọn cũng tồn tại để sửa đổi cách thức đánh dấu
	hoặc sự kiện hoạt động (dấu vết ngăn xếp, dấu thời gian, v.v.).

tùy chọn:

Đây là một thư mục có một tập tin cho mọi
	tùy chọn theo dõi (cũng có trong trace_options). Tùy chọn cũng có thể được đặt
	hoặc xóa bằng cách viết số "1" hoặc "0" tương ứng vào
	tập tin tương ứng với tên tùy chọn.

tracing_max_latency:

Một số công cụ theo dõi ghi lại độ trễ tối đa.
	Ví dụ: thời gian tối đa mà các ngắt bị vô hiệu hóa.
	Thời gian tối đa được lưu trong tập tin này. Dấu vết tối đa cũng sẽ là
	được lưu trữ và hiển thị bởi "dấu vết". Một dấu vết tối đa mới sẽ chỉ
	được ghi lại nếu độ trễ lớn hơn giá trị trong tệp này
	(tính bằng micro giây).

Bằng cách lặp lại một thời gian vào tệp này, sẽ không có độ trễ nào được ghi lại
	trừ khi nó lớn hơn thời gian trong tập tin này.

tracing_thresh:

Một số công cụ theo dõi độ trễ sẽ ghi lại dấu vết bất cứ khi nào
	độ trễ lớn hơn con số trong tệp này.
	Chỉ hoạt động khi tệp chứa số lớn hơn 0.
	(tính bằng micro giây)

bộ đệm_percent:

Đây là hình mờ cho biết bộ đệm vòng cần được lấp đầy bao nhiêu
	trước khi người phục vụ thức dậy. Nghĩa là, nếu một ứng dụng gọi một
	chặn lệnh đọc tòa nhà trên một trong các tệp per_cpu trace_pipe_raw, nó
	sẽ chặn cho đến khi lượng dữ liệu nhất định được chỉ định bởi buffer_percent
	nằm trong bộ đệm vòng trước khi nó đánh thức đầu đọc. Điều này cũng
	kiểm soát cách các lệnh gọi hệ thống mối nối bị chặn trên tệp này::

0 - có nghĩa là thức dậy ngay khi có bất kỳ dữ liệu nào trong bộ đệm vòng.
	  50 - có nghĩa là thức dậy khi khoảng một nửa bộ đệm phụ của bộ đệm vòng
	        đã đầy.
	  100 - có nghĩa là chặn cho đến khi bộ đệm vòng hoàn toàn đầy và
	        sắp bắt đầu ghi đè lên dữ liệu cũ hơn.

đệm_size_kb:

Điều này đặt hoặc hiển thị số kilobyte mỗi CPU
	bộ đệm giữ. Theo mặc định, bộ đệm theo dõi có cùng kích thước
	cho mỗi CPU. Số hiển thị là kích thước của
	Bộ đệm CPU chứ không phải tổng kích thước của tất cả các bộ đệm. các
	bộ đệm theo dõi được phân bổ trong các trang (khối bộ nhớ
	mà kernel sử dụng để phân bổ, thường có kích thước 4 KB).
	Một vài trang bổ sung có thể được phân bổ để phù hợp với việc quản lý bộ đệm
	siêu dữ liệu. Nếu trang cuối cùng được phân bổ có chỗ cho nhiều byte hơn
	hơn yêu cầu, phần còn lại của trang sẽ được sử dụng,
	làm cho phân bổ thực tế lớn hơn yêu cầu hoặc hiển thị.
	(Lưu ý, kích thước có thể không phải là bội số của kích thước trang
	do siêu dữ liệu quản lý bộ đệm. )

Kích thước bộ đệm cho từng CPU có thể khác nhau
	(xem "per_cpu/cpu0/buffer_size_kb" bên dưới) và nếu có
	tập tin này sẽ hiển thị "X".

đệm_total_size_kb:

Điều này hiển thị tổng kích thước kết hợp của tất cả các bộ đệm theo dõi.

đệm_subbuf_size_kb:

Điều này đặt hoặc hiển thị kích thước bộ đệm phụ. Bộ đệm vòng bị hỏng
	thành nhiều "bộ đệm phụ" có cùng kích thước. Một sự kiện không thể lớn hơn
	kích thước của bộ đệm phụ. Thông thường, bộ đệm phụ có kích thước bằng
	trang kiến trúc (4K trên x86). Bộ đệm phụ cũng chứa dữ liệu meta
	khi bắt đầu, điều này cũng giới hạn quy mô của sự kiện.  Điều đó có nghĩa là khi
	bộ đệm phụ là kích thước trang, không có sự kiện nào có thể lớn hơn trang
	kích thước trừ đi dữ liệu meta bộ đệm phụ.

Lưu ý, buffer_subbuf_size_kb là cách để người dùng chỉ định
	kích thước tối thiểu của bộ đệm con. Hạt nhân có thể làm cho nó lớn hơn do
	chi tiết triển khai hoặc đơn giản là thao tác không thành công nếu kernel có thể
	không xử lý yêu cầu.

Việc thay đổi kích thước bộ đệm phụ cho phép các sự kiện lớn hơn kích thước bộ đệm phụ.
	kích thước trang.

Lưu ý: Khi thay đổi kích thước bộ đệm phụ, việc theo dõi sẽ dừng lại và mọi
	dữ liệu trong bộ đệm vòng và bộ đệm chụp nhanh sẽ bị loại bỏ.

free_buffer:

Nếu một quá trình đang thực hiện theo dõi và bộ đệm vòng phải được
	bị thu nhỏ "giải phóng" khi quá trình kết thúc, ngay cả khi nó được
	bị tín hiệu giết chết, tập tin này có thể được sử dụng cho mục đích đó. Gần gũi
	của tệp này, bộ đệm vòng sẽ được thay đổi kích thước về kích thước tối thiểu.
	Có một quy trình đang theo dõi cũng mở tệp này, khi quy trình đó
	thoát khỏi bộ mô tả tệp của nó cho tệp này sẽ bị đóng và khi làm như vậy,
	bộ đệm vòng sẽ được "giải phóng".

Nó cũng có thể ngừng truy tìm nếu tùy chọn vô hiệu hóa_on_free được đặt.

tracing_cpumask:

Đây là mặt nạ cho phép người dùng chỉ theo dõi trên các CPU được chỉ định.
	Định dạng là một chuỗi hex đại diện cho CPU.

set_ftrace_filter:

Khi ftrace động được cấu hình trong (xem phần
	phần bên dưới "ftrace động"), mã sẽ tự động
	đã sửa đổi (viết lại văn bản mã) để vô hiệu hóa việc gọi
	trình lược tả chức năng (mcount). Điều này cho phép cấu hình theo dõi
	với thực tế không có chi phí hoạt động.  Điều này cũng
	có tác dụng phụ là bật hoặc tắt các chức năng cụ thể
	để được truy tìm. Lặp lại tên của các chức năng vào tập tin này
	sẽ giới hạn dấu vết chỉ ở những chức năng đó.
	Điều này ảnh hưởng đến "chức năng" và "function_graph" của bộ theo dõi
	và do đó cũng có chức năng định hình (xem "function_profile_enabled").

Các chức năng được liệt kê trong "available_filter_functions" là những gì
	có thể được ghi vào tập tin này.

Giao diện này cũng cho phép sử dụng các lệnh. Xem
	Phần "Lọc lệnh" để biết thêm chi tiết.

Để tăng tốc độ, vì việc xử lý chuỗi có thể khá tốn kém
	và yêu cầu kiểm tra tất cả các chức năng đã đăng ký để theo dõi, thay vào đó
	một chỉ mục có thể được ghi vào tập tin này. Một số (bắt đầu bằng "1")
	thay vào đó sẽ chọn tương ứng ở vị trí dòng
	của tệp "available_filter_functions".

set_ftrace_notrace:

Điều này có tác dụng ngược lại với
	set_ftrace_filter. Bất kỳ chức năng nào được thêm vào đây sẽ không
	được truy tìm. Nếu một hàm tồn tại trong cả set_ftrace_filter
	và set_ftrace_notrace, hàm sẽ _not_ được truy tìm.

set_ftrace_pid:

Yêu cầu trình theo dõi chức năng chỉ theo dõi các luồng có PID
	được liệt kê trong tập tin này.

Nếu tùy chọn "function-fork" được đặt thì khi một tác vụ có
	PID được liệt kê trong các nhánh tệp này, PID của trẻ em sẽ
	tự động được thêm vào tập tin này và đứa trẻ sẽ được
	cũng được theo dõi bởi chức năng theo dõi. Tùy chọn này cũng sẽ
	khiến PID của các tác vụ thoát ra khỏi tệp bị xóa.

set_ftrace_notrace_pid:

Yêu cầu trình theo dõi hàm bỏ qua các luồng có PID được liệt kê trong
        tập tin này.

Nếu tùy chọn "function-fork" được đặt thì khi một tác vụ có
	PID được liệt kê trong các nhánh tệp này, PID của trẻ em sẽ
	tự động được thêm vào tập tin này và đứa trẻ sẽ không bị
	cũng được theo dõi bởi chức năng theo dõi. Tùy chọn này cũng sẽ
	khiến PID của các tác vụ thoát ra khỏi tệp bị xóa.

Nếu PID có trong cả tệp này và "set_ftrace_pid", thì tệp này
        tập tin được ưu tiên và luồng sẽ không được theo dõi.

set_event_pid:

Yêu cầu các sự kiện chỉ theo dõi một tác vụ có PID được liệt kê trong tệp này.
	Lưu ý, sched_switch và sched_wake_up cũng sẽ theo dõi các sự kiện
	được liệt kê trong tập tin này.

Để có PID của nhiệm vụ con với PID của chúng trong tệp này
	được thêm vào fork, hãy bật tùy chọn "event-fork". Tùy chọn đó cũng sẽ
	khiến các PID của tác vụ bị xóa khỏi tệp này khi tác vụ
	thoát ra.

set_event_notrace_pid:

Yêu cầu các sự kiện không theo dõi tác vụ có PID được liệt kê trong tệp này.
	Lưu ý, sched_switch và sched_wakeup sẽ theo dõi các chủ đề không được liệt kê
	trong tệp này, ngay cả khi PID của luồng có trong tệp nếu
        Các sự kiện sched_switch hoặc sched_wakeup cũng theo dõi một chuỗi cần
        được truy tìm.

Để có PID của nhiệm vụ con với PID của chúng trong tệp này
	được thêm vào fork, hãy bật tùy chọn "event-fork". Tùy chọn đó cũng sẽ
	khiến các PID của tác vụ bị xóa khỏi tệp này khi tác vụ
	thoát ra.

set_graph_function:

Các hàm được liệt kê trong tệp này sẽ khiến đồ thị hàm số
	công cụ theo dõi chỉ theo dõi các chức năng này và các chức năng
	họ gọi. (Xem phần "ftrace động" để biết thêm chi tiết).
	Lưu ý, set_ftrace_filter và set_ftrace_notrace vẫn ảnh hưởng
	những chức năng nào đang được truy tìm.

set_graph_notrace:

Tương tự như set_graph_function, nhưng sẽ tắt đồ thị hàm
	truy tìm khi chức năng được nhấn cho đến khi nó thoát khỏi chức năng.
	Điều này làm cho nó có thể bỏ qua các chức năng theo dõi được gọi là
	theo một chức năng cụ thể.

có sẵn_filter_functions:

Phần này liệt kê các chức năng mà ftrace đã xử lý và có thể theo dõi.
	Đây là tên hàm mà bạn có thể chuyển tới
	"set_ftrace_filter", "set_ftrace_notrace",
	"set_graph_function" hoặc "set_graph_notrace".
	(Xem phần "ftrace động" bên dưới để biết thêm chi tiết.)

có sẵn_filter_functions_addrs:

Tương tự như available_filter_functions nhưng có hiển thị địa chỉ
	cho từng chức năng. Địa chỉ được hiển thị là địa chỉ trang vá
	và có thể khác với địa chỉ /proc/kallsyms.

syscall_user_buf_size:

Một số sự kiện theo dõi cuộc gọi hệ thống sẽ ghi lại dữ liệu từ người dùng
	địa chỉ không gian mà một trong các tham số trỏ tới. Số lượng của
	dữ liệu cho mỗi sự kiện bị hạn chế. Tệp này chứa số byte tối đa
	sẽ được ghi vào bộ đệm vòng để chứa dữ liệu này.
	Giá trị tối đa hiện tại là 165.

dyn_ftrace_total_info:

Tập tin này là dành cho mục đích gỡ lỗi. Số lượng chức năng đó
	đã được chuyển đổi thành nops và có sẵn để truy tìm.

đã bật_functions:

Tệp này dùng để gỡ lỗi ftrace nhiều hơn nhưng cũng có thể hữu ích
	để xem liệu có chức năng nào có hàm gọi lại gắn liền với nó hay không.
	Cơ sở hạ tầng theo dõi không chỉ sử dụng chức năng ftrace
	tiện ích theo dõi, nhưng các hệ thống con khác cũng có thể như vậy. tập tin này
	hiển thị tất cả các chức năng có một cuộc gọi lại kèm theo chúng
	cũng như số lượng lệnh gọi lại đã được đính kèm.
	Lưu ý, lệnh gọi lại cũng có thể gọi nhiều hàm, điều này sẽ
	không được liệt kê vào số này.

Nếu lệnh gọi lại được đăng ký để được theo dõi bởi một hàm có
	thuộc tính "lưu quy định" (do đó thậm chí còn tốn nhiều chi phí hơn), 'R'
	sẽ được hiển thị trên cùng dòng với hàm
	đang trả lại các thanh ghi.

Nếu lệnh gọi lại được đăng ký để được theo dõi bởi một hàm có
	thuộc tính "sửa đổi ip" (do đó, regs->ip có thể được thay đổi),
	chữ 'I' sẽ được hiển thị trên cùng dòng với hàm
	có thể bị ghi đè.

Nếu gắn tấm bạt lò xo không có ftrace (BPF), chữ 'D' sẽ được hiển thị.
	Lưu ý, các tấm bạt lò xo ftrace bình thường cũng có thể được gắn vào, nhưng chỉ có một
	Tấm bạt lò xo "trực tiếp" có thể được gắn vào một chức năng nhất định tại một thời điểm.

Một số kiến trúc không thể gọi các tấm bạt lò xo trực tiếp mà thay vào đó có
	hàm ftrace ops nằm phía trên điểm vào hàm. trong
	những trường hợp như vậy chữ 'O' sẽ được hiển thị.

Nếu một hàm có lệnh gọi "sửa đổi ip" hoặc lệnh gọi "trực tiếp" được đính kèm
	trong quá khứ, chữ 'M' sẽ được hiển thị. Cờ này không bao giờ bị xóa. Đó là
	được sử dụng để biết liệu một chức năng có từng được sửa đổi bởi cơ sở hạ tầng ftrace hay không,
	và có thể được sử dụng để gỡ lỗi.

Nếu kiến trúc hỗ trợ nó, nó cũng sẽ hiển thị cuộc gọi lại nào
	đang được gọi trực tiếp bởi hàm. Nếu số lượng lớn hơn
	hơn 1 thì rất có thể nó sẽ là ftrace_ops_list_func().

Nếu lệnh gọi lại của một hàm nhảy tới tấm bạt lò xo
	dành riêng cho lệnh gọi lại và không phải là tấm bạt lò xo tiêu chuẩn,
	địa chỉ của nó sẽ được in cũng như chức năng của nó
	cuộc gọi tấm bạt lò xo.

touch_functions:

Tệp này chứa tất cả các hàm từng có hàm gọi lại
	tới nó thông qua cơ sở hạ tầng ftrace. Nó có định dạng tương tự như
	Enable_functions nhưng hiển thị tất cả các chức năng đã từng có
	truy tìm.

Để xem bất kỳ chức năng nào đã được sửa đổi bởi "sửa đổi ip" hoặc
	tấm bạt lò xo trực tiếp, người ta có thể thực hiện lệnh sau:

grep ' M ' /sys/kernel/tracing/touched_functions

function_profile_enabled:

Khi được thiết lập, nó sẽ kích hoạt tất cả các chức năng với chức năng
	công cụ theo dõi hoặc nếu được định cấu hình, công cụ theo dõi đồ thị hàm số. Nó sẽ
	giữ một biểu đồ về số lượng các chức năng được gọi
	và nếu trình theo dõi biểu đồ hàm đã được định cấu hình, nó cũng sẽ giữ nguyên
	theo dõi thời gian dành cho các chức năng đó. Biểu đồ
	nội dung có thể được hiển thị trong các tập tin:

trace_stat/function<cpu> ( function0, function1, v.v.).

dấu vết_stat:

Một thư mục chứa các số liệu thống kê theo dõi khác nhau.

kprobe_events:

Kích hoạt điểm theo dõi động. Xem kprobetrace.rst.

kprobe_profile:

Thống kê điểm theo dõi động. Xem kprobetrace.rst.

max_graph_deep:

Được sử dụng với công cụ theo dõi đồ thị hàm số. Đây là độ sâu tối đa
	nó sẽ theo dõi một chức năng. Đặt giá trị này thành giá trị của
	người ta sẽ chỉ hiển thị hàm kernel đầu tiên được gọi
	từ không gian người dùng.

printk_formats:

Cái này dành cho các công cụ đọc các tập tin định dạng thô. Nếu một sự kiện ở
	bộ đệm vòng tham chiếu một chuỗi, chỉ một con trỏ tới chuỗi
	được ghi vào bộ đệm chứ không phải chính chuỗi đó. Điều này ngăn cản
	công cụ biết chuỗi đó là gì. Tập tin này hiển thị chuỗi
	và địa chỉ cho chuỗi cho phép các công cụ ánh xạ các con trỏ tới chuỗi
	các dây đã được.

đã lưu_cmdlines:

Chỉ pid của tác vụ được ghi lại trong sự kiện theo dõi trừ khi
	sự kiện này cũng đặc biệt lưu nhiệm vụ comm. Ftrace
	tạo một bộ đệm chứa các ánh xạ pid tới các liên lạc để cố gắng hiển thị
	liên lạc cho các sự kiện. Nếu pid cho một liên lạc không được liệt kê thì
	"<...>" được hiển thị ở đầu ra.

Nếu tùy chọn "record-cmd" được đặt thành "0", thì sẽ giao tiếp với các tác vụ
	sẽ không được lưu trong quá trình ghi. Theo mặc định, nó được kích hoạt.

đã lưu_cmdlines_size:

Theo mặc định, 128 liên lạc được lưu (xem "saved_cmdlines" ở trên). Đến
	tăng hoặc giảm số lượng liên lạc được lưu trong bộ nhớ đệm, echo
	số lượng giao tiếp cần lưu vào bộ đệm vào tệp này.

đã lưu_tgids:

Nếu tùy chọn "record-tgid" được đặt, trên mỗi chuyển đổi ngữ cảnh lập lịch
	ID nhóm tác vụ của một tác vụ được lưu trong bảng ánh xạ PID của
	luồng tới TGID của nó. Theo mặc định, tùy chọn "record-tgid" là
	bị vô hiệu hóa.

ảnh chụp nhanh:

Điều này hiển thị bộ đệm "ảnh chụp nhanh" và cũng cho phép người dùng
	chụp ảnh nhanh dấu vết đang chạy.
	Xem phần "Ảnh chụp nhanh" bên dưới để biết thêm chi tiết.

stack_max_size:

Khi trình theo dõi ngăn xếp được kích hoạt, nó sẽ hiển thị
	kích thước ngăn xếp tối đa mà nó đã gặp phải.
	Xem phần "Dấu vết ngăn xếp" bên dưới.

stack_trace:

Điều này hiển thị dấu vết ngăn xếp ngược của ngăn xếp lớn nhất
	đã gặp phải khi trình theo dõi ngăn xếp được kích hoạt.
	Xem phần "Dấu vết ngăn xếp" bên dưới.

stack_trace_filter:

Điều này tương tự như "set_ftrace_filter" nhưng nó giới hạn những gì
	các chức năng mà trình theo dõi ngăn xếp sẽ kiểm tra.

trace_clock:

Bất cứ khi nào một sự kiện được ghi vào bộ đệm vòng, một
	"dấu thời gian" được thêm vào. Con tem này đến từ một địa chỉ cụ thể
	đồng hồ. Theo mặc định, ftrace sử dụng đồng hồ "cục bộ". Cái này
	đồng hồ rất nhanh và đúng theo CPU, nhưng trên một số
	các hệ thống có thể không đơn điệu so với các hệ thống khác
	CPU. Nói cách khác, đồng hồ địa phương có thể không đồng bộ
	với đồng hồ cục bộ trên các CPU khác.

Đồng hồ thông thường để truy tìm::

# cat trace_clock
	  [cục bộ] bộ đếm toàn cầu x86-tsc

Đồng hồ có dấu ngoặc vuông xung quanh là đồng hồ có hiệu lực.

địa phương:
		Đồng hồ mặc định nhưng có thể không đồng bộ giữa các CPU

toàn cầu:
		Đồng hồ này đồng bộ với tất cả các CPU nhưng có thể
		chậm hơn một chút so với đồng hồ địa phương.

truy cập:
		Đây hoàn toàn không phải là một chiếc đồng hồ, mà theo nghĩa đen là một chiếc đồng hồ nguyên tử.
		quầy. Nó đếm từng cái một nhưng đồng bộ
		với tất cả các CPU. Điều này rất hữu ích khi bạn cần
		biết chính xác các sự kiện thứ tự xảy ra đối với
		nhau trên các CPU khác nhau.

thời gian hoạt động:
		Điều này sử dụng bộ đếm jiffies và dấu thời gian
		tương đối so với thời gian kể từ khi khởi động.

hoàn hảo:
		Điều này làm cho ftrace sử dụng cùng một đồng hồ mà perf sử dụng.
		Cuối cùng perf sẽ có thể đọc bộ đệm ftrace
		và điều này sẽ giúp ích trong việc xen kẽ dữ liệu.

x86-tsc:
		Kiến trúc có thể xác định đồng hồ của riêng họ. cho
		ví dụ: x86 sử dụng đồng hồ chu kỳ TSC của riêng nó ở đây.

ppc-tb:
		Điều này sử dụng giá trị đăng ký cơ sở thời gian powerpc.
		Điều này được đồng bộ hóa giữa các CPU và cũng có thể được sử dụng
		để tương quan các sự kiện giữa hypervisor/khách nếu
		tb_offset đã được biết.

đơn âm:
		Điều này sử dụng đồng hồ đơn điệu nhanh (CLOCK_MONOTONIC)
		đơn điệu và có thể điều chỉnh tỷ lệ NTP.

đơn_raw:
		Đây là đồng hồ đơn điệu thô (CLOCK_MONOTONIC_RAW)
		đơn điệu nhưng không chịu bất kỳ sự điều chỉnh tỷ lệ nào
		và tích tắc ở cùng tốc độ với nguồn xung nhịp phần cứng.

khởi động:
		Đây là đồng hồ khởi động (CLOCK_BOOTTIME) và dựa trên
		đồng hồ đơn điệu nhanh nhưng cũng chiếm thời gian dành cho
		đình chỉ. Vì truy cập đồng hồ được thiết kế để sử dụng trong
		truy tìm đường dẫn tạm dừng, có thể xảy ra một số tác dụng phụ
		nếu đồng hồ được truy cập sau khi thời gian tạm dừng được tính trước
		đồng hồ mono nhanh được cập nhật. Trong trường hợp này, cập nhật đồng hồ
		dường như xảy ra sớm hơn một chút so với bình thường.
		Ngoài ra, trên hệ thống 32 bit, có thể phần bù khởi động 64 bit
		thấy một bản cập nhật một phần. Những hiệu ứng này rất hiếm và sau
		quá trình xử lý sẽ có thể xử lý chúng. Xem bình luận ở
		ktime_get_boot_fast_ns() để biết thêm thông tin.

tai:
		Đây là chiếc đồng hồ tai (CLOCK_TAI) và có nguồn gốc từ chiếc đồng hồ treo tường-
		đồng hồ thời gian. Tuy nhiên, đồng hồ này không có kinh nghiệm
		sự gián đoạn và nhảy lùi do NTP chèn bước nhảy
		giây. Vì quyền truy cập đồng hồ được thiết kế để sử dụng trong việc theo dõi,
		tác dụng phụ là có thể. Việc truy cập đồng hồ có thể mang lại kết quả sai
		kết quả đọc trong trường hợp phần bù TAI bên trong được cập nhật, ví dụ: gây ra
		bằng cách đặt thời gian hệ thống hoặc sử dụng adjtimex() với phần bù.
		Những hiệu ứng này rất hiếm và quá trình xử lý sau có thể
		xử lý chúng. Xem bình luận trong ktime_get_tai_fast_ns()
		chức năng để biết thêm thông tin.

Để đặt đồng hồ, chỉ cần lặp lại tên đồng hồ vào tệp này ::

# echo toàn cầu > trace_clock

Việc đặt đồng hồ sẽ xóa nội dung bộ đệm vòng cũng như
	bộ đệm "ảnh chụp nhanh".

dấu vết_marker:

Đây là một file rất hữu ích cho việc đồng bộ không gian người dùng
	với các sự kiện xảy ra trong kernel. Viết chuỗi vào
	tập tin này sẽ được ghi vào bộ đệm ftrace.

Nó rất hữu ích trong các ứng dụng để mở tập tin này khi bắt đầu
	của ứng dụng và chỉ tham khảo bộ mô tả tập tin
	cho tập tin::

void trace_write(const char *fmt, ...)
		{
			va_list ap;
			char buf[256];
			int n;

nếu (trace_fd < 0)
				trở lại;

va_start(ap, fmt);
			n = vsnprintf(buf, 256, fmt, ap);
			va_end(ap);

write(trace_fd, buf, n);
		}

bắt đầu::

trace_fd = open("trace_marker", O_WRONLY);

Lưu ý: Việc ghi vào tệp trace_marker cũng có thể kích hoạt trình kích hoạt
	      được ghi vào /sys/kernel/tracing/events/ftrace/print/trigger
	      Xem "Trình kích hoạt sự kiện" trong Tài liệu/trace/events.rst và
              ví dụ trong Documentation/trace/histogram.rst (Phần 3.)

trace_marker_raw:

Điều này tương tự như trace_marker ở trên, nhưng dành cho dữ liệu nhị phân
	được ghi vào nó, nơi một công cụ có thể được sử dụng để phân tích dữ liệu
	từ trace_pipe_raw.

uprobe_events:

Thêm dấu vết động trong chương trình.
	Xem uprobetracer.rst

uprobe_profile:

Thống kê Uprobe. Xem uprobetrace.txt

trường hợp:

Đây là một cách để tạo nhiều bộ đệm theo dõi ở những nơi khác nhau
	các sự kiện có thể được ghi lại trong các bộ đệm khác nhau.
	Xem phần "Trường hợp" bên dưới.

sự kiện:

Đây là thư mục sự kiện theo dõi. Nó chứa các dấu vết sự kiện
	(còn được gọi là điểm theo dõi tĩnh) đã được biên dịch
	vào hạt nhân. Nó cho thấy những dấu vết sự kiện nào tồn tại
	và cách chúng được nhóm theo hệ thống. Có "kích hoạt"
	các tệp ở nhiều cấp độ khác nhau có thể kích hoạt các điểm theo dõi
	khi số "1" được viết cho họ.

Xem events.rst để biết thêm thông tin.

set_event:

Bằng cách lặp lại sự kiện vào tệp này, sẽ kích hoạt sự kiện đó.

Xem events.rst để biết thêm thông tin.

show_event_filters:

Danh sách các sự kiện có bộ lọc. Điều này cho thấy
	cặp hệ thống/sự kiện cùng với bộ lọc được gắn vào
	sự kiện.

Xem events.rst để biết thêm thông tin.

show_event_triggers:

Danh sách các sự kiện có trình kích hoạt. Điều này cho thấy
	cặp hệ thống/sự kiện cùng với trình kích hoạt được gắn vào
	sự kiện.

Xem events.rst để biết thêm thông tin.

có sẵn_sự kiện:

Danh sách các sự kiện có thể được kích hoạt trong quá trình theo dõi.

Xem events.rst để biết thêm thông tin.

dấu thời gian_mode:

Một số công cụ theo dõi có thể thay đổi chế độ dấu thời gian được sử dụng khi
	ghi nhật ký các sự kiện theo dõi vào bộ đệm sự kiện.  Sự kiện với
	các chế độ khác nhau có thể cùng tồn tại trong một bộ đệm nhưng chế độ trong
	hiệu ứng khi một sự kiện được ghi lại sẽ xác định chế độ dấu thời gian nào
	được sử dụng cho sự kiện đó.  Chế độ dấu thời gian mặc định là
	'đồng bằng'.

Các chế độ dấu thời gian thông thường để theo dõi:

Chế độ dấu thời gian # cat
	  [delta] tuyệt đối

Chế độ dấu thời gian có dấu ngoặc vuông xung quanh là chế độ
	  một có hiệu lực.

delta: Chế độ dấu thời gian mặc định - dấu thời gian là một delta so với
	         dấu thời gian trên mỗi bộ đệm.

tuyệt đối: Dấu thời gian là dấu thời gian đầy đủ, không phải dấu delta
                 chống lại một số giá trị khác.  Như vậy sẽ tốn nhiều hơn
                 không gian và kém hiệu quả hơn.

hwlat_Detector:

Thư mục dành cho Trình phát hiện độ trễ phần cứng.
	Xem phần "Trình phát hiện độ trễ phần cứng" bên dưới.

mỗi_cpu:

Đây là thư mục chứa thông tin theo dõi per_cpu.

mỗi_cpu/cpu0/buffer_size_kb:

Bộ đệm ftrace được xác định per_cpu. Tức là có một sự riêng biệt
	bộ đệm cho mỗi CPU để cho phép việc ghi được thực hiện nguyên tử,
	và không bị nảy bộ nhớ đệm. Những bộ đệm này có thể khác nhau
	bộ đệm kích thước. Tệp này tương tự như buffer_size_kb
	nhưng nó chỉ hiển thị hoặc đặt kích thước bộ đệm cho
	CPU cụ thể. (ở đây là cpu0).

per_cpu/cpu0/dấu vết:

Điều này tương tự như tệp "dấu vết", nhưng nó sẽ chỉ hiển thị
	dữ liệu cụ thể cho CPU. Nếu được viết vào, nó chỉ xóa
	bộ đệm CPU cụ thể.

per_cpu/cpu0/trace_pipe

Điều này tương tự như tệp "trace_pipe" và tốn nhiều công sức
	đọc, nhưng nó sẽ chỉ hiển thị (và sử dụng) dữ liệu cụ thể
	dành cho CPU.

per_cpu/cpu0/trace_pipe_raw

Đối với các công cụ có thể phân tích cú pháp định dạng nhị phân của bộ đệm vòng ftrace,
	tệp trace_pipe_raw có thể được sử dụng để trích xuất dữ liệu
	trực tiếp từ bộ đệm vòng. Với việc sử dụng mối nối()
	cuộc gọi hệ thống, dữ liệu bộ đệm có thể được chuyển nhanh chóng tới
	một tập tin hoặc vào mạng nơi máy chủ đang thu thập thông tin
	dữ liệu.

Giống như trace_pipe, đây là một trình đọc tốn nhiều công sức, trong đó có nhiều
	lần đọc sẽ luôn tạo ra dữ liệu khác nhau.

per_cpu/cpu0/ảnh chụp nhanh:

Điều này tương tự như tệp "ảnh chụp nhanh" chính, nhưng sẽ chỉ
	chụp nhanh CPU hiện tại (nếu được hỗ trợ). Nó chỉ hiển thị
	nội dung của ảnh chụp nhanh cho một CPU nhất định và nếu
	được ghi vào, chỉ xóa bộ đệm CPU này.

mỗi_cpu/cpu0/snapshot_raw:

Tương tự như trace_pipe_raw nhưng sẽ đọc định dạng nhị phân
	từ bộ đệm chụp nhanh cho CPU đã cho.

per_cpu/cpu0/số liệu thống kê:

Điều này hiển thị số liệu thống kê nhất định về bộ đệm vòng:

mục:
		Số lượng sự kiện vẫn còn trong bộ đệm.

tràn ngập:
		Số sự kiện bị mất do ghi đè khi
		bộ đệm đã đầy.

cam kết tràn ngập:
		Phải luôn luôn bằng không.
		Điều này được thiết lập nếu có quá nhiều sự kiện xảy ra trong một
		sự kiện (bộ đệm vòng được nhập lại), nó sẽ lấp đầy
		đệm và bắt đầu loại bỏ các sự kiện.

byte:
		Byte thực sự đọc (không bị ghi đè).

sự kiện lâu đời nhất ts:
		Dấu thời gian cũ nhất trong bộ đệm

bây giờ ts:
		Dấu thời gian hiện tại

sự kiện bị bỏ:
		Sự kiện bị mất do tùy chọn ghi đè bị tắt.

đọc sự kiện:
		Số lượng sự kiện được đọc.

Người theo dõi
--------------

Đây là danh sách các công cụ theo dõi hiện tại có thể được cấu hình.

"chức năng"

Trình theo dõi lệnh gọi hàm để theo dõi tất cả các hàm kernel.

"hàm_đồ thị"

Tương tự như chức năng theo dõi ngoại trừ việc
	trình theo dõi chức năng thăm dò các chức năng trên mục nhập của chúng
	trong khi dấu vết của đồ thị hàm số trên cả hai mục nhập
	và thoát khỏi các chức năng. Sau đó nó cung cấp khả năng
	để vẽ biểu đồ các lệnh gọi hàm tương tự như mã C
	nguồn.

Lưu ý rằng biểu đồ hàm tính toán thời điểm khi
	hàm bắt đầu và trả về nội bộ và cho từng trường hợp. Nếu
	có hai trường hợp chạy hàm tracer và trace
	các chức năng tương tự, độ dài của thời gian có thể hơi lệch một chút vì
	mỗi người đọc dấu thời gian riêng biệt và không cùng lúc.

"khối"

Máy dò khối. Công cụ theo dõi được người dùng blktrace sử dụng
	ứng dụng.

"Ồ"

Công cụ theo dõi độ trễ phần cứng được sử dụng để phát hiện xem phần cứng có
	tạo ra bất kỳ độ trễ nào. Xem phần "Trình phát hiện độ trễ phần cứng"
	bên dưới.

"không ổn"

Theo dõi các khu vực vô hiệu hóa ngắt và lưu
	dấu vết có độ trễ tối đa dài nhất.
	Xem tracing_max_latency. Khi mức tối đa mới được ghi lại,
	nó thay thế dấu vết cũ. Tốt nhất nên xem cái này
	theo dõi với tùy chọn định dạng độ trễ được bật,
	tự động xảy ra khi bộ theo dõi được chọn.

"ưu tiên"

Tương tự như irqsoff nhưng theo dõi và ghi lại số lượng
	thời điểm quyền ưu tiên bị vô hiệu hóa.

"preemptirqsoff"

Tương tự như irqsoff và preemptoff, nhưng dấu vết và
	ghi lại thời gian lớn nhất mà irq và/hoặc quyền ưu tiên
	bị vô hiệu hóa.

"thức dậy"

Theo dõi và ghi lại độ trễ tối đa cần thiết
	nhiệm vụ có mức độ ưu tiên cao nhất cần được lên lịch sau
	nó đã được đánh thức.
        Theo dõi tất cả các nhiệm vụ như một nhà phát triển bình thường mong đợi.

"thức dậy_rt"

Theo dõi và ghi lại độ trễ tối đa cần thiết cho
        Nhiệm vụ RT (như cách "đánh thức" hiện tại thực hiện). Điều này rất hữu ích
        dành cho những người quan tâm đến thời gian đánh thức các tác vụ RT.

"Thức dậy_dl"

Theo dõi và ghi lại độ trễ tối đa cần thiết
	một nhiệm vụ SCHED_DEADLINE cần được đánh thức (dưới dạng "đánh thức" và
	"wakeup_rt" thì có).

"mmiotrace"

Một công cụ theo dõi đặc biệt được sử dụng để theo dõi các mô-đun nhị phân.
	Nó sẽ theo dõi tất cả các cuộc gọi mà một mô-đun thực hiện tới
	phần cứng. Mọi thứ nó ghi và đọc từ I/O
	cũng vậy.

"chi nhánh"

Trình theo dõi này có thể được cấu hình khi theo dõi khả năng/không thể
	các cuộc gọi bên trong kernel. Nó sẽ theo dõi khi nào có khả năng và
	nhánh không chắc chắn sẽ bị tấn công và nếu dự đoán của nó đúng
	là đúng.

"không"

Đây là công cụ theo dõi "không có dấu vết". Để loại bỏ tất cả
	công cụ theo dõi từ việc truy tìm chỉ đơn giản là lặp lại "nop" vào
	current_tracer.

Điều kiện lỗi
----------------

Đối với hầu hết các lệnh ftrace, các chế độ lỗi đều rõ ràng và được truyền đạt
  sử dụng mã trả lại tiêu chuẩn.

Đối với các lệnh liên quan khác, thông tin lỗi mở rộng có thể
  có sẵn thông qua tệp tracing/error_log.  Đối với các lệnh đó
  hỗ trợ nó, việc đọc tệp tra cứu/error_log sau khi xảy ra lỗi sẽ
  hiển thị thông tin chi tiết hơn về những gì đã xảy ra, nếu
  thông tin có sẵn.  Tệp tra cứu/error_log là một tệp hình tròn
  nhật ký lỗi hiển thị một số lượng nhỏ (hiện tại là 8) lỗi ftrace
  cho (8) lệnh thất bại cuối cùng.

Thông tin lỗi mở rộng và cách sử dụng có dạng hiển thị trong
  ví dụ này::

# echo xxx > /sys/kernel/tracing/events/sched/sched_wakeup/trigger
    echo: lỗi ghi: Đối số không hợp lệ

# cat/sys/kernel/tracing/error_log
    [ 5348.887237] vị trí: lỗi: Không thể yyy: zzz
      Lệnh: xxx
               ^
    [ 7517.023364] vị trí: lỗi: Bad rrr: sss
      Lệnh: ppp qqq
                   ^

Để xóa nhật ký lỗi, hãy lặp lại chuỗi trống vào đó ::

# echo > /sys/kernel/tracing/error_log

Ví dụ về việc sử dụng công cụ theo dõi
--------------------------------------

Dưới đây là những ví dụ điển hình về việc sử dụng bộ theo dõi khi điều khiển
chúng chỉ với giao diện tracefs (không sử dụng bất kỳ
tiện ích đất của người sử dụng).

Định dạng đầu ra:
-----------------

Đây là ví dụ về định dạng đầu ra của tệp "trace"::

# tracer: chức năng
  #
  # entries-in-buffer/mục viết: 140080/250280 #P:4
  #
  #                              _-----=> tắt irqs
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
              bash-1977 [000] .... 17284.993652: sys_close <-system_call_fastpath
              bash-1977 [000] .... 17284.993653: __close_fd <-sys_close
              bash-1977 [000] .... 17284.993653: _raw_spin_lock <-__close_fd
              sshd-1974 [003] .... 17284.993653: __srcu_read_unlock <-fsnotify
              bash-1977 [000] .... 17284.993654: add_preempt_count <-_raw_spin_lock
              bash-1977 [000] ...1 17284.993655: _raw_spin_unlock <-__close_fd
              bash-1977 [000] ...1 17284.993656: sub_preempt_count <-_raw_spin_unlock
              bash-1977 [000] .... 17284.993657: filp_close <-__close_fd
              bash-1977 [000] .... 17284.993657: dnotify_flush <-filp_close
              sshd-1974 [003] .... 17284.993658: sys_select <-system_call_fastpath
              ....

Một tiêu đề được in với tên theo dõi được đại diện bởi
dấu vết. Trong trường hợp này, dấu vết là "chức năng". Sau đó nó hiển thị
số sự kiện trong bộ đệm cũng như tổng số mục
đã được viết. Sự khác biệt là số lượng mục được
bị mất do bộ đệm đầy (250280 - 140080 = 110200 sự kiện
bị mất).

Tiêu đề giải thích nội dung của sự kiện. Tên nhiệm vụ "bash", nhiệm vụ
PID "1977", CPU đang chạy trên "000", định dạng độ trễ
(được giải thích bên dưới), dấu thời gian ở định dạng <secs>.<usecs>,
tên hàm được truy tìm "sys_close" và hàm cha được theo dõi
gọi hàm này là "system_call_fastpath". Dấu thời gian là thời gian
tại đó chức năng được nhập vào.

Định dạng theo dõi độ trễ
-------------------------

Khi tùy chọn định dạng độ trễ được bật hoặc khi một trong các độ trễ
bộ theo dõi được thiết lập, tệp theo dõi sẽ cung cấp thêm thông tin để xem
tại sao lại xảy ra độ trễ. Đây là một dấu vết điển hình::

# tracer: không ổn
  #
  Dấu vết độ trễ # irqsoff v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 259 chúng tôi, #4/4, CPU#2 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: ps-6143 (uid:0 nice:0 chính sách:0 rt_prio:0)
  #    -----------------
  # => bắt đầu lúc: __lock_task_sighand
  # => kết thúc lúc: _raw_spin_unlock_irqrestore
  #
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
        ps-6143 2d... 0us!: trace_hardirqs_off <-__lock_task_sighand
        ps-6143 2d..1 259us+: trace_hardirqs_on <-_raw_spin_unlock_irqrestore
        ps-6143 2d..1 263us+: time_hardirqs_on <-_raw_spin_unlock_irqrestore
        ps-6143 2d..1 306us : <dấu vết ngăn xếp>
   => trace_hardirqs_on_caller
   => trace_hardirqs_on
   => _raw_spin_unlock_irqrestore
   => do_task_stat
   => proc_tgid_stat
   => proc_single_show
   => seq_read
   => vfs_read
   => sys_read
   => system_call_fastpath


Điều này cho thấy bộ theo dõi hiện tại đang "irqsoff" theo dõi thời gian
mà các ngắt đã bị vô hiệu hóa. Nó cung cấp phiên bản theo dõi (mà
không bao giờ thay đổi) và phiên bản kernel mà lệnh này được thực thi trên đó
(3.8). Sau đó, nó hiển thị độ trễ tối đa tính bằng micro giây (259 us). số
của các mục theo dõi được hiển thị và tổng số (cả hai đều là bốn: #4/4).
VP, KP, SP và HP luôn bằng 0 và được dành để sử dụng sau.
#P là số lượng CPU trực tuyến (#P:4).

Tác vụ là quá trình đang chạy khi độ trễ
đã xảy ra. (ps pid: 6143).

Sự bắt đầu và kết thúc (các chức năng trong đó các ngắt được thực hiện
bị vô hiệu hóa và kích hoạt tương ứng) gây ra độ trễ:

- __lock_task_sighand là nơi các ngắt bị vô hiệu hóa.
  - _raw_spin_unlock_irqrestore là nơi chúng được kích hoạt lại.

Các dòng tiếp theo sau tiêu đề chính là dấu vết. Tiêu đề
giải thích cái nào là cái nào

cmd: Tên của tiến trình trong dấu vết.

pid: PID của quá trình đó.

CPU#: CPU mà tiến trình đang chạy.

irqs-off: ngắt 'd' bị vô hiệu hóa. '.' nếu không thì.

cần thiết lập lại:
	- Tất cả đều là 'B', TIF_NEED_RESCHED, PREEMPT_NEED_RESCHED và TIF_RESCHED_LAZY,
	- 'N' cả TIF_NEED_RESCHED và PREEMPT_NEED_RESCHED đều được đặt,
	- 'n' chỉ có TIF_NEED_RESCHED được đặt,
	- 'p' chỉ có PREEMPT_NEED_RESCHED được đặt,
	- 'L' cả PREEMPT_NEED_RESCHED và TIF_RESCHED_LAZY đều được đặt,
	- 'b' cả TIF_NEED_RESCHED và TIF_RESCHED_LAZY đều được đặt,
	- 'l' chỉ có TIF_RESCHED_LAZY được đặt
	- '.' nếu không thì.

hardirq/softirq:
	- 'Z' - NMI xảy ra bên trong hardirq
	- 'z' - NMI đang chạy
	- 'H' - irq cứng xảy ra bên trong softirq.
	- 'h' - irq cứng đang chạy
	- 's' - irq mềm đang chạy
	- '.' - bối cảnh bình thường.

preempt-deep: Mức độ preempt_disabled

Những điều trên hầu hết có ý nghĩa đối với các nhà phát triển kernel.

thời gian:
	Khi tùy chọn định dạng độ trễ được bật, tệp theo dõi
	đầu ra bao gồm dấu thời gian liên quan đến thời điểm bắt đầu
	dấu vết. Điều này khác với đầu ra khi định dạng độ trễ
	bị vô hiệu hóa, bao gồm dấu thời gian tuyệt đối.

trì hoãn:
	Điều này chỉ để giúp bạn bắt mắt hơn một chút. Và
	cần được sửa để chỉ tương đối với cùng một CPU.
	Điểm số được xác định bởi sự khác biệt giữa điều này
	dấu vết hiện tại và dấu vết tiếp theo.

- '$' - lớn hơn 1 giây
	  - '@' - lớn hơn 100 mili giây
	  - '*' - lớn hơn 10 mili giây
	  - '#' - lớn hơn 1000 micro giây
	  - '!' - lớn hơn 100 micro giây
	  - '+' - lớn hơn 10 micro giây
	  - '' - nhỏ hơn hoặc bằng 10 micro giây.

Phần còn lại giống như file 'dấu vết'.

Lưu ý, dấu vết độ trễ thường sẽ kết thúc bằng dấu vết ngược
  để dễ dàng tìm ra nơi xảy ra độ trễ.

trace_options
-------------

Tệp trace_options (hoặc thư mục tùy chọn) được sử dụng để kiểm soát
những gì được in trong đầu ra của dấu vết hoặc thao tác với các dấu vết.
Để xem những gì có sẵn, chỉ cần gửi tệp::

dấu vết mèo_options
	cha mẹ in
	nosym-bù đắp
	nosym-addr
	noverbose
	bây giờ
	nohex
	nobin
	không chặn
	trường vô hướng
	dấu vết_printk
	chú thích
	nouserstacktrace
	nosym-userobj
	chỉ noprintk-tin nhắn
	thông tin ngữ cảnh
	định dạng không có độ trễ
	ghi-cmd
	norecord-tgid
	ghi đè lên
	gật đầu_on_free
	thông tin irq
	đánh dấu
	noevent-fork
	dấu vết chức năng
	ngã ba không có chức năng
	biểu đồ không hiển thị
	dấu vết ngăn xếp
	không có nhánh

Để tắt một trong các tùy chọn, hãy lặp lại tùy chọn được thêm vào trước
"không"::

echo noprint-parent > trace_options

Để bật một tùy chọn, hãy bỏ chọn "no"::

echo sym-offset > trace_options

Dưới đây là các tùy chọn có sẵn:

cha mẹ in
	Trên dấu vết hàm, hiển thị lệnh gọi (cha mẹ)
	chức năng cũng như chức năng được truy tìm.
	::

print-parent:
	   bash-4000 [01] 1477.606694: simple_strtoul <-kstrtoul

noprint-parent:
	   bash-4000 [01] 1477.606694: simple_strtoul


sym-offset
	Hiển thị không chỉ tên chức năng mà còn cả
	offset trong hàm. Ví dụ, thay vì
	chỉ cần nhìn thấy "ktime_get", bạn sẽ thấy
	"ktime_get+0xb/0x20".
	::

sym-offset:
	   bash-4000 [01] 1477.606694: simple_strtoul+0x6/0xa0

sym-addr
	Điều này cũng sẽ hiển thị địa chỉ chức năng
	như tên hàm.
	::

sym-addr:
	   bash-4000 [01] 1477.606694: simple_strtoul <c0339346>

dài dòng
	Điều này xử lý tệp theo dõi khi
        tùy chọn định dạng độ trễ được bật.
	::

bash 4000 1 0 00000000 00010a95 [58127d26] 1720.415ms \
	    (+0,000ms): simple_strtoul (kstrtoul)

thô
	Điều này sẽ hiển thị số nguyên. Tùy chọn này là tốt nhất cho
	sử dụng với các ứng dụng người dùng có thể dịch thô
	số tốt hơn là thực hiện nó trong kernel.

thập lục phân
	Tương tự như raw nhưng các số sẽ ở định dạng thập lục phân.

cái thùng
	Điều này sẽ in ra các định dạng ở dạng nhị phân thô.

khối
	Khi được đặt, việc đọc trace_pipe sẽ không bị chặn khi thăm dò ý kiến.

lĩnh vực
	In các trường như được mô tả theo loại của chúng. Cái này tốt hơn
	tùy chọn hơn là sử dụng hex, bin hoặc raw, vì nó mang lại khả năng phân tích cú pháp tốt hơn
	về nội dung của sự kiện.

dấu vết_printk
	Có thể vô hiệu hóa trace_printk() ghi vào bộ đệm.

trace_printk_dest
	Đặt để có trace_printk() và các chức năng theo dõi nội bộ tương tự
	viết vào trường hợp này. Lưu ý, chỉ có một phiên bản dấu vết có thể có
	bộ này. Bằng cách đặt cờ này, nó sẽ xóa cờ trace_printk_dest
	của phiên bản đã được thiết lập trước đó. Theo mặc định, trên cùng
	dấu vết cấp độ đã được thiết lập và sẽ được thiết lập lại nếu một dấu vết khác
	instance đã thiết lập xong rồi xóa nó.

Cờ này không thể bị xóa bởi cá thể cấp cao nhất, vì nó là
	trường hợp mặc định. Cách duy nhất mà cá thể cấp cao nhất có cờ này
	bị xóa, là do nó được đặt trong một phiên bản khác.

sao chép_trace_marker
	Nếu có những ứng dụng viết mã cứng vào cấp cao nhất
	tệp trace_marker (/sys/kernel/tracing/trace_marker hoặc trace_marker_raw),
	và công cụ muốn nó đi vào một phiên bản, tùy chọn này có thể
	được sử dụng. Tạo một phiên bản và đặt tùy chọn này, sau đó ghi tất cả
	vào tệp trace_marker cấp cao nhất cũng sẽ được chuyển hướng vào tệp này
	ví dụ.

Lưu ý, theo mặc định, tùy chọn này được đặt cho phiên bản cấp cao nhất. Nếu nó
	bị tắt, sau đó ghi vào tệp trace_marker hoặc trace_marker_raw
	sẽ không được ghi vào tập tin cấp cao nhất. Nếu không có trường hợp nào có điều này
	được đặt thì quá trình ghi sẽ xảy ra lỗi với lỗi ENODEV.

chú thích
	Đôi khi khó hiểu khi bộ đệm CPU đầy
	và một bộ đệm CPU gần đây có rất nhiều sự kiện, do đó
	khung thời gian ngắn hơn, nếu CPU khác có thể chỉ có
	một vài sự kiện, cho phép nó có các sự kiện cũ hơn. Khi nào
	dấu vết được báo cáo, nó hiển thị các sự kiện cũ nhất trước tiên,
	và có vẻ như chỉ có một chiếc CPU chạy (cái có
	sự kiện lâu đời nhất). Khi tùy chọn chú thích được thiết lập, nó sẽ
	hiển thị khi bộ đệm CPU mới bắt đầu::

<nhàn rỗi>-0 [001] dNs4 21169.031481: Wake_up_idle_cpu <-add_timer_on
			  <nhàn rỗi>-0 [001] dNs4 21169.031482: _raw_spin_unlock_irqrestore <-add_timer_on
			  <nhàn rỗi>-0 [001] .Ns4 21169.031484: sub_preempt_count <-_raw_spin_unlock_irqrestore
		####Bộ đệm # ZZ0000ZZ 2 đã bắt đầu ####
			  <nhàn rỗi>-0 [002] .N.1 21169.031484: rcu_idle_exit <-cpu_idle
			  <nhàn rỗi>-0 [001] .Ns3 21169.031484: _raw_spin_unlock <-clocksource_watchdog
			  <nhàn rỗi>-0 [001] .Ns3 21169.031485: sub_preempt_count <-_raw_spin_unlock

userstacktrace
	Tùy chọn này thay đổi dấu vết. Nó ghi lại một
	stacktrace của luồng không gian người dùng hiện tại sau
	mỗi sự kiện theo dõi.

sym-userobj
	khi người dùng stacktrace được bật, hãy tra cứu cái nào
	đối tượng địa chỉ thuộc về và in một
	địa chỉ tương đối Điều này đặc biệt hữu ích khi
	ASLR đang bật, nếu không bạn sẽ không có cơ hội
	giải quyết địa chỉ thành đối tượng/tập tin/dòng sau
	ứng dụng không còn chạy nữa

Việc tra cứu được thực hiện khi bạn đọc
	dấu vết, trace_pipe. Ví dụ::

a.out-1623 [000] 40874.465068: /root/a.out[+0x480] <-/root/a.out[+0
		  x494] <- /root/a.out[+0x4a8] <- /lib/libc-2.7.so[+0x1e1a6]


chỉ printk-tin nhắn
	Khi được đặt, trace_printk()s sẽ chỉ hiển thị định dạng
	chứ không phải tham số của chúng (nếu trace_bprintk() hoặc
	trace_bputs() đã được sử dụng để lưu trace_printk()).

thông tin ngữ cảnh
	Chỉ hiển thị dữ liệu sự kiện. Ẩn liên lạc, PID,
	dấu thời gian, CPU và các dữ liệu hữu ích khác.

định dạng độ trễ
	Tùy chọn này thay đổi đầu ra theo dõi. Khi nó được kích hoạt,
	dấu vết hiển thị thông tin bổ sung về
	độ trễ, như được mô tả trong "Định dạng theo dõi độ trễ".

tạm dừng theo dõi
	Khi được thiết lập, việc mở tệp theo dõi để đọc sẽ tạm dừng
	ghi vào bộ đệm vòng (như thể tracing_on được đặt thành 0).
	Điều này mô phỏng hành vi ban đầu của tệp theo dõi.
	Khi tệp được đóng, tính năng theo dõi sẽ được bật lại.

băm-ptr
        Khi được đặt, "%p" ở định dạng printk sự kiện sẽ hiển thị
        giá trị con trỏ băm thay vì địa chỉ thực.
        Điều này sẽ hữu ích nếu bạn muốn tìm ra giá trị băm nào
        giá trị tương ứng với giá trị thực trong nhật ký theo dõi.

danh sách bitmask
        Khi được bật, mặt nạ bit được hiển thị dưới dạng danh sách có thể đọc được
        phạm vi (ví dụ: 0,2-5,7) bằng cách sử dụng công cụ xác định định dạng printk "%*pbl".
        Khi bị tắt (mặc định), mặt nạ bit sẽ được hiển thị trong
        biểu diễn bitmap thập lục phân truyền thống. Định dạng danh sách là
        đặc biệt hữu ích để theo dõi mặt nạ CPU và các mặt nạ bit lớn khác
        trong đó các vị trí bit riêng lẻ có ý nghĩa hơn vị trí của chúng
        mã hóa thập lục phân.

ghi-cmd
	Khi bất kỳ sự kiện hoặc trình theo dõi nào được bật, hook sẽ được bật
	trong điểm theo dõi sched_switch để điền vào bộ đệm comm
	với pids và comms được ánh xạ. Nhưng điều này có thể gây ra một số
	chi phí chung và nếu bạn chỉ quan tâm đến pids chứ không phải
	tên của tác vụ, việc tắt tùy chọn này có thể làm giảm
	tác động của việc truy vết. Xem "saved_cmdlines".

ghi-tgid
	Khi bất kỳ sự kiện hoặc trình theo dõi nào được bật, hook sẽ được bật
	trong điểm theo dõi sched_switch để điền vào bộ đệm của
	ánh xạ ID nhóm chủ đề (TGID) tới pids. Xem
	"đã lưu_tgids".

ghi đè lên
	Điều này kiểm soát những gì xảy ra khi bộ đệm theo dõi được
	đầy đủ. Nếu "1" (mặc định), các sự kiện cũ nhất là
	bị loại bỏ và ghi đè. Nếu "0" thì mới nhất
	các sự kiện bị loại bỏ.
	(xem per_cpu/cpu0/stats để biết lỗi tràn và bị rớt)

vô hiệu hóa_on_free
	Khi free_buffer bị đóng, quá trình theo dõi sẽ
	dừng (tracing_on được đặt thành 0).

thông tin irq
	Hiển thị ngắt, số lần ưu tiên, cần đặt lại dữ liệu.
	Khi bị tắt, dấu vết trông giống như::

# tracer: chức năng
		#
		# entries-in-buffer/mục viết: 144405/9452052 #P:4
		#
		#           ZZ0002ZZ-ZZ0003ZZ CPU#      ZZ0005ZZ FUNCTION
		#              ZZ0007ZZ ZZ0001ZZ |
			  <nhàn rỗi>-0 [002] 23636.756054: ttwu_do_activate.constprop.89 <-try_to_wake_up
			  <nhàn rỗi>-0 [002] 23636.756054: activate_task <-ttwu_do_activate.constprop.89
			  <nhàn rỗi>-0 [002] 23636.756055: enqueue_task <-activate_task


đánh dấu
	Khi được đặt, trace_marker có thể ghi được (chỉ bằng root).
	Khi bị tắt, trace_marker sẽ báo lỗi EINVAL
	về viết.

ngã ba sự kiện
	Khi được đặt, các tác vụ có PID được liệt kê trong set_event_pid sẽ có
	PID của con cái họ được thêm vào set_event_pid khi chúng
	ngã ba nhiệm vụ. Ngoài ra, khi thoát các tác vụ có PID trong set_event_pid,
	PID của họ sẽ bị xóa khỏi tệp.

Điều này cũng ảnh hưởng đến các PID được liệt kê trong set_event_notrace_pid.

dấu vết chức năng
	Trình theo dõi độ trễ sẽ cho phép theo dõi chức năng
	nếu tùy chọn này được bật (mặc định là như vậy). Khi nào
	nó bị vô hiệu hóa, công cụ theo dõi độ trễ không theo dõi
	chức năng. Điều này giúp giảm chi phí của bộ theo dõi
	khi thực hiện kiểm tra độ trễ.

ngã ba chức năng
	Khi được đặt, các tác vụ có PID được liệt kê trong set_ftrace_pid sẽ
	đã thêm PID của con họ vào set_ftrace_pid
	khi những nhiệm vụ đó rẽ nhánh. Ngoài ra, khi các tác vụ có PID trong
	thoát set_ftrace_pid, PID của họ sẽ bị xóa khỏi
	tập tin.

Điều này cũng ảnh hưởng đến PID trong set_ftrace_notrace_pid.

biểu đồ hiển thị
	Khi được đặt, các công cụ theo dõi độ trễ (irqsoff, Wakeup, v.v.) sẽ
	sử dụng theo dõi đồ thị hàm thay vì theo dõi hàm.

dấu vết ngăn xếp
	Khi được đặt, dấu vết ngăn xếp sẽ được ghi lại sau bất kỳ sự kiện theo dõi nào
	được ghi lại.

chi nhánh
	Kích hoạt tính năng theo dõi nhánh bằng công cụ theo dõi. Điều này cho phép chi nhánh
	tracer cùng với tracer hiện được thiết lập. Kích hoạt tính năng này
	với trình theo dõi "nop" cũng giống như việc chỉ kích hoạt
	máy theo dõi "nhánh".

.. tip:: Some tracers have their own options. They only appear in this
       file when the tracer is active. They always appear in the
       options directory.


Dưới đây là các tùy chọn cho mỗi người theo dõi:

Tùy chọn cho chức năng theo dõi:

func_stack_trace
	Khi được thiết lập, dấu vết ngăn xếp sẽ được ghi lại sau mỗi lần
	chức năng được ghi lại. NOTE! Giới hạn chức năng
	được ghi lại trước khi kích hoạt tính năng này, với
	"set_ftrace_filter" nếu không thì hiệu suất hệ thống
	sẽ bị xuống cấp trầm trọng. Nhớ tắt
	tùy chọn này trước khi xóa bộ lọc chức năng.

Các tùy chọn cho hàm theo dõi function_graph:

Vì hàm theo dõi function_graph có đầu ra hơi khác một chút
 nó có các tùy chọn riêng để kiểm soát những gì được hiển thị.

tràn hàm
	Khi được đặt, mức "tràn" của ngăn xếp biểu đồ là
	hiển thị sau mỗi chức năng được truy tìm. các
	tràn ngập, là khi độ sâu ngăn xếp của các cuộc gọi
	lớn hơn mức dành riêng cho mỗi nhiệm vụ.
	Mỗi nhiệm vụ có một mảng chức năng cố định để
	theo dõi trong biểu đồ cuộc gọi. Nếu độ sâu của
	các cuộc gọi vượt quá mức đó, chức năng không được truy tìm.
	Sự vượt mức là số lượng chức năng bị bỏ lỡ
	do vượt quá mảng này.

funcgraph-cpu
	Khi được đặt, số CPU của CPU nơi dấu vết
	xảy ra được hiển thị.

chi phí chức năng
	Khi được thiết lập, nếu chức năng này mất nhiều thời gian hơn
	Một lượng nhất định thì điểm đánh dấu độ trễ sẽ là
	được hiển thị. Xem phần "trì hoãn" ở trên, bên dưới
	mô tả tiêu đề.

funcgraph-proc
	Không giống như các công cụ theo dõi khác, dòng lệnh của quy trình
	không được hiển thị theo mặc định mà thay vào đó chỉ
	khi một nhiệm vụ được truy tìm vào và ra trong một bối cảnh
	chuyển đổi. Kích hoạt tùy chọn này có lệnh
	của mỗi quá trình được hiển thị ở mỗi dòng.

thời lượng funcgraph
	Ở cuối mỗi chức năng (trả về)
	khoảng thời gian trong
	chức năng được hiển thị trong micro giây.

funcgraph-abstime
	Khi được đặt, dấu thời gian sẽ được hiển thị ở mỗi dòng.

funcgraph-irqs
	Khi bị vô hiệu hóa, các chức năng xảy ra bên trong
	ngắt sẽ không được theo dõi.

đuôi funcgraph
	Khi được đặt, sự kiện trả về sẽ bao gồm hàm
	mà nó đại diện. Theo mặc định, tính năng này bị tắt và
	chỉ có dấu ngoặc nhọn đóng "}" được hiển thị cho
	sự trở lại của một hàm.

funcgraph-retval
	Khi được đặt, giá trị trả về của từng hàm được theo dõi
	sẽ được in sau dấu bằng "=". Theo mặc định
	cái này tắt rồi

funcgraph-retval-hex
	Khi được đặt, giá trị trả về sẽ luôn được in
	ở định dạng thập lục phân. Nếu tùy chọn này không được đặt và
	giá trị trả về là mã lỗi, nó sẽ được in
	ở định dạng thập phân có dấu; nếu không thì nó cũng sẽ như vậy
	được in ở định dạng thập lục phân. Theo mặc định, tùy chọn này
	đã tắt.

giờ ngủ
	Khi chạy trình theo dõi đồ thị hàm, phải bao gồm
	thời gian một nhiệm vụ được lên lịch trong chức năng của nó.
	Khi được bật, nó sẽ tính thời gian nhiệm vụ đã được thực hiện
	được lên lịch như một phần của lệnh gọi hàm.

thời gian biểu đồ
	Khi chạy trình lược tả hàm bằng trình theo dõi biểu đồ hàm,
	để bao gồm thời gian gọi các hàm lồng nhau. Khi đây là
	không được thiết lập, thời gian được báo cáo cho chức năng sẽ chỉ
	bao gồm thời gian mà hàm đó được thực thi chứ không phải thời gian
	thời gian cho các chức năng mà nó gọi.

Tùy chọn cho blk tracer:

blk_classic
	Hiển thị đầu ra tối giản hơn.


khó chịu
--------

Khi ngắt bị vô hiệu hóa, CPU không thể phản ứng với bất kỳ ngắt nào khác
sự kiện bên ngoài (ngoài NMI và SMI). Điều này ngăn chặn bộ đếm thời gian
gián đoạn kích hoạt hoặc chuột bị gián đoạn khi cho phép
kernel biết về một sự kiện chuột mới. Kết quả là độ trễ
với thời gian phản ứng.

Trình theo dõi irqsoff theo dõi thời gian ngắt
bị vô hiệu hóa. Khi đạt đến độ trễ tối đa mới, bộ theo dõi sẽ lưu
dấu vết dẫn đến điểm trễ đó để mỗi lần
đạt đến mức tối đa mới, dấu vết đã lưu cũ sẽ bị loại bỏ và
dấu vết mới được lưu.

Để đặt lại mức tối đa, hãy lặp 0 vào tracing_max_latency. Đây là
một ví dụ::

# echo 0 > tùy chọn/dấu vết chức năng
  # echo irqsoff > current_tracer
  # echo 1 > truy tìm_on
  # echo 0 > tracing_max_latency
  # ls -ltr
  […]
  # echo 0 > truy tìm_on
  Dấu vết # cat
  # tracer: không ổn
  #
  Dấu vết độ trễ # irqsoff v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 16 chúng tôi, #4/4, CPU#0 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: swapper/0-0 (uid:0 nice:0 chính sách:0 rt_prio:0)
  #    -----------------
  # => bắt đầu lúc: run_timer_softirq
  # => kết thúc lúc: run_timer_softirq
  #
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
    <nhàn rỗi>-0 0d.s2 0us+: _raw_spin_lock_irq <-run_timer_softirq
    <nhàn rỗi>-0 0dNs3 17us : _raw_spin_unlock_irq <-run_timer_softirq
    <nhàn rỗi>-0 0dNs3 17us+: trace_hardirqs_on <-run_timer_softirq
    <nhàn rỗi>-0 0dNs3 25us : <dấu vết ngăn xếp>
   => _raw_spin_unlock_irq
   => run_timer_softirq
   => __do_softirq
   => call_softirq
   => do_softirq
   => irq_exit
   => smp_apic_timer_interrupt
   => apic_timer_interrupt
   => rcu_idle_exit
   => cpu_idle
   => nghỉ_init
   => hạt nhân bắt đầu
   => x86_64_start_reservations
   => x86_64_start_kernel

Ở đây chúng ta thấy rằng chúng ta có độ trễ là 16 micro giây (tức là
rất tốt). _raw_spin_lock_irq trong run_timer_softirq bị vô hiệu hóa
ngắt quãng. Sự khác biệt giữa 16 và hiển thị
dấu thời gian 25us xảy ra do đồng hồ đã tăng lên
giữa thời điểm ghi độ trễ tối đa và thời điểm
ghi lại chức năng có độ trễ đó.

Lưu ý ví dụ trên chưa đặt chức năng theo dõi. Nếu chúng ta đặt
theo dõi hàm, chúng ta nhận được kết quả đầu ra lớn hơn nhiều ::

với echo 1 > tùy chọn/dấu vết chức năng

# tracer: không ổn
  #
  Dấu vết độ trễ # irqsoff v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 71 chúng tôi, #168/168, CPU#3 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: bash-2042 (uid:0 nice:0 chính sách:0 rt_prio:0)
  #    -----------------
  # => bắt đầu tại: ata_scsi_queuecmd
  # => kết thúc tại: ata_scsi_queuecmd
  #
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
      bash-2042 3d... 0us : _raw_spin_lock_irqsave <-ata_scsi_queuecmd
      bash-2042 3d... 0us : add_preempt_count <-_raw_spin_lock_irqsave
      bash-2042 3d..1 1us : ata_scsi_find_dev <-ata_scsi_queuecmd
      bash-2042 3d..1 1us : __ata_scsi_find_dev <-ata_scsi_find_dev
      bash-2042 3d..1 2us : ata_find_dev.part.14 <-__ata_scsi_find_dev
      bash-2042 3d..1 2us : ata_qc_new_init <-__ata_scsi_queuecmd
      bash-2042 3d..1 3us : ata_sg_init <-__ata_scsi_queuecmd
      bash-2042 3d..1 4us : ata_scsi_rw_xlat <-__ata_scsi_queuecmd
      bash-2042 3d..1 4us : ata_build_rw_tf <-ata_scsi_rw_xlat
  […]
      bash-2042 3d..1 67us : delay_tsc <-__delay
      bash-2042 3d..1 67us : add_preempt_count <-delay_tsc
      bash-2042 3d..2 67us : sub_preempt_count <-delay_tsc
      bash-2042 3d..1 67us : add_preempt_count <-delay_tsc
      bash-2042 3d..2 68us : sub_preempt_count <-delay_tsc
      bash-2042 3d..1 68us+: ata_bmdma_start <-ata_bmdma_qc_issue
      bash-2042 3d..1 71us : _raw_spin_unlock_irqrestore <-ata_scsi_queuecmd
      bash-2042 3d..1 71us : _raw_spin_unlock_irqrestore <-ata_scsi_queuecmd
      bash-2042 3d..1 72us+: trace_hardirqs_on <-ata_scsi_queuecmd
      bash-2042 3d..1 120us : <dấu vết ngăn xếp>
   => _raw_spin_unlock_irqrestore
   => ata_scsi_queuecmd
   => scsi_dispatch_cmd
   => scsi_request_fn
   => __blk_run_queue_uncond
   => __blk_run_queue
   => blk_queue_bio
   => submit_bio_noacct
   => gửi_bio
   => gửi_bh
   => __ext3_get_inode_loc
   => ext3_iget
   => ext3_lookup
   => tra cứu_real
   => __lookup_hash
   => walk_comComponent
   => tra cứu_cuối cùng
   => đường dẫn_lookupat
   => tên tệp_lookup
   => user_path_at_empty
   => user_path_at
   => vfs_fstatat
   => vfs_stat
   => sys_newstat
   => system_call_fastpath


Ở đây chúng tôi theo dõi độ trễ 71 micro giây. Nhưng chúng ta cũng thấy tất cả
các chức năng được gọi trong thời gian đó. Lưu ý rằng bởi
cho phép theo dõi chức năng, chúng tôi phải chịu thêm chi phí. Cái này
chi phí có thể kéo dài thời gian trễ. Nhưng tuy nhiên, điều này
trace đã cung cấp một số thông tin gỡ lỗi rất hữu ích.

Nếu chúng ta thích đầu ra đồ thị hàm thay vì hàm, chúng ta có thể đặt
tùy chọn hiển thị đồ thị::

với echo 1 > tùy chọn/đồ thị hiển thị

# tracer: không ổn
  #
  Dấu vết độ trễ # irqsoff v1.1.5 trên 4.20.0-rc6+
  # --------------------------------------------------------------------
  # latency: 3751 chúng tôi, #274/274, CPU#0 | (M:máy tính để bàn VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: bash-1507 (uid:0 nice:0 chính sách:0 rt_prio:0)
  #    -----------------
  # => bắt đầu tại: free_debug_processing
  # => kết thúc lúc: return_to_handler
  #
  #
  #                                       _-----=> không hoạt động
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| /
  #   ZZ0030ZZ TIME CPU TASK/PID ||||     DURATION FUNCTION CALLS
  #      ZZ0038ZZ ZZ0001ZZ |||ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ |
          0 chúng tôi ZZ0005ZZ d... ZZ0006ZZ _raw_spin_lock_irqsave();
          0 chúng tôi ZZ0007ZZ d..1 ZZ0008ZZ do_raw_spin_trylock();
          1 chúng tôi ZZ0009ZZ d..2 ZZ0010ZZ set_track() {
          2 chúng tôi ZZ0011ZZ d..2 ZZ0012ZZ save_stack_trace() {
          2 chúng tôi ZZ0013ZZ d..2 ZZ0014ZZ __save_stack_trace() {
          3 chúng tôi ZZ0015ZZ d..2 ZZ0016ZZ __unwind_start() {
          3 chúng tôi ZZ0017ZZ d..2 ZZ0018ZZ get_stack_info() {
          3 chúng tôi ZZ0019ZZ d..2 ZZ0020ZZ in_task_stack();
          4 chúng tôi ZZ0021ZZ d..2 ZZ0022ZZ }
  […]
       3750 us ZZ0023ZZ d..1 ZZ0024ZZ do_raw_spin_unlock();
       3750 chúng tôi ZZ0025ZZ d..1 ZZ0026ZZ _raw_spin_unlock_irqrestore();
       3764 us ZZ0027ZZ d..1 ZZ0028ZZ tracer_hardirqs_on();
      bash-1507 0d..1 3792us : <dấu vết ngăn xếp>
   => free_debug_processing
   => __slab_free
   => kmem_cache_free
   => vm_area_free
   => xóa_vma
   => exit_mmap
   => đầu ra mm
   => bắt đầu_new_exec
   => Load_elf_binary
   => search_binary_handler
   => __do_execve_file.isra.32
   => __x64_sys_execve
   => do_syscall_64
   => entry_SYSCALL_64_after_hwframe

ưu tiên
----------

Khi quyền ưu tiên bị vô hiệu hóa, chúng tôi có thể nhận được
bị gián đoạn nhưng nhiệm vụ không thể được ưu tiên và mức cao hơn
nhiệm vụ ưu tiên phải đợi quyền ưu tiên được kích hoạt lại
trước khi nó có thể ưu tiên một nhiệm vụ có mức độ ưu tiên thấp hơn.

Trình theo dõi quyền ưu tiên theo dõi những vị trí vô hiệu hóa quyền ưu tiên.
Giống như công cụ theo dõi irqsoff, nó ghi lại độ trễ tối đa cho
quyền ưu tiên nào đã bị vô hiệu hóa. Việc kiểm soát chất đánh dấu ưu tiên
rất giống với công cụ theo dõi irqsoff.
:::::::::::::::::::::::::::::::::::::::

# echo 0 > tùy chọn/dấu vết chức năng
  Ưu tiên trước # echo > current_tracer
  # echo 1 > truy tìm_on
  # echo 0 > tracing_max_latency
  # ls -ltr
  […]
  # echo 0 > truy tìm_on
  Dấu vết # cat
  # tracer: ưu tiên
  #
  Dấu vết độ trễ # preemptoff v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 46 chúng tôi, #4/4, CPU#1 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: sshd-1991 (uid:0 nice:0 chính sách:0 rt_prio:0)
  #    -----------------
  # => bắt đầu tại: do_IRQ
  # => kết thúc tại: do_IRQ
  #
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
      sshd-1991 1d.h.    0us+: irq_enter <-do_IRQ
      sshd-1991 1d..1 46us : irq_exit <-do_IRQ
      sshd-1991 1d..1 47us+: trace_preempt_on <-do_IRQ
      sshd-1991 1d..1 52us : <dấu vết ngăn xếp>
   => sub_preempt_count
   => irq_exit
   => do_IRQ
   => ret_from_intr


Điều này có thêm một số thay đổi. Quyền ưu tiên đã bị vô hiệu hóa khi một
ngắt xuất hiện (chú ý 'h') và được bật khi thoát.
Nhưng chúng ta cũng thấy rằng các ngắt đã bị vô hiệu hóa khi vào
phần ưu tiên và để lại nó ('d'). Chúng tôi không biết liệu
các ngắt đã được kích hoạt trong thời gian đó hoặc ngay sau đó
đã kết thúc.
::::::::::::

# tracer: ưu tiên
  #
  Dấu vết độ trễ # preemptoff v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 83 chúng tôi, #241/241, CPU#1 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: bash-1994 (uid:0 nice:0 chính sách:0 rt_prio:0)
  #    -----------------
  # => bắt đầu lúc: Wake_up_new_task
  # => kết thúc lúc: task_rq_unlock
  #
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
      bash-1994 1d..1 0us : _raw_spin_lock_irqsave <-wake_up_new_task
      bash-1994 1d..1 0us : select_task_rq_fair <-select_task_rq
      bash-1994 1d..1 1us : __rcu_read_lock <-select_task_rq_fair
      bash-1994 1d..1 1us : source_load <-select_task_rq_fair
      bash-1994 1d..1 1us : source_load <-select_task_rq_fair
  […]
      bash-1994 1d..1 12us : irq_enter <-smp_apic_timer_interrupt
      bash-1994 1d..1 12us : rcu_irq_enter <-irq_enter
      bash-1994 1d..1 13us : add_preempt_count <-irq_enter
      bash-1994 1d.h1 13us : exit_idle <-smp_apic_timer_interrupt
      bash-1994 1d.h1 13us : hrtimer_interrupt <-smp_apic_timer_interrupt
      bash-1994 1d.h1 13us : _raw_spin_lock <-hrtimer_interrupt
      bash-1994 1d.h1 14us : add_preempt_count <-_raw_spin_lock
      bash-1994 1d.h2 14us : ktime_get_update_offsets <-hrtimer_interrupt
  […]
      bash-1994 1d.h1 35us : lapic_next_event <-clockevents_program_event
      bash-1994 1d.h1 35us : irq_exit <-smp_apic_timer_interrupt
      bash-1994 1d.h1 36us : sub_preempt_count <-irq_exit
      bash-1994 1d..2 36us : do_softirq <-irq_exit
      bash-1994 1d..2 36us : __do_softirq <-call_softirq
      bash-1994 1d..2 36us : __local_bh_disable <-__do_softirq
      bash-1994 1d.s2 37us : add_preempt_count <-_raw_spin_lock_irq
      bash-1994 1d.s3 38us : _raw_spin_unlock <-run_timer_softirq
      bash-1994 1d.s3 39us : sub_preempt_count <-_raw_spin_unlock
      bash-1994 1d.s2 39us : call_timer_fn <-run_timer_softirq
  […]
      bash-1994 1dNs2 81us : cpu_needs_another_gp <-rcu_process_callbacks
      bash-1994 1dNs2 82us : __local_bh_enable <-__do_softirq
      bash-1994 1dNs2 82us : sub_preempt_count <-__local_bh_enable
      bash-1994 1dN.2 82us : Idle_cpu <-irq_exit
      bash-1994 1dN.2 83us : rcu_irq_exit <-irq_exit
      bash-1994 1dN.2 83us : sub_preempt_count <-irq_exit
      bash-1994 1.N.1 84us : _raw_spin_unlock_irqrestore <-task_rq_unlock
      bash-1994 1.N.1 84us+: trace_preempt_on <-task_rq_unlock
      bash-1994 1.N.1 104us : <dấu vết ngăn xếp>
   => sub_preempt_count
   => _raw_spin_unlock_irqrestore
   => task_rq_unlock
   => Wake_up_new_task
   => do_fork
   => sys_clone
   => còn sơ khai


Trên đây là một ví dụ về dấu vết ưu tiên với
bộ theo dõi chức năng. Ở đây chúng ta thấy rằng các ngắt không bị vô hiệu hóa
toàn bộ thời gian. Mã irq_enter cho chúng tôi biết rằng chúng tôi đã nhập
một ngắt 'h'. Trước đó, các chức năng được truy tìm vẫn
cho thấy rằng nó không bị gián đoạn, nhưng chúng ta có thể thấy từ
tự nó hoạt động rằng đây không phải là trường hợp.

ưu tiên
--------------

Biết các vị trí bị vô hiệu hóa ngắt hoặc
quyền ưu tiên bị vô hiệu hóa trong thời gian dài nhất là hữu ích. Nhưng
đôi khi chúng tôi muốn biết khi nào quyền ưu tiên và/hoặc
ngắt bị vô hiệu hóa.

Hãy xem xét đoạn mã sau::

local_irq_disable();
    call_function_with_irqs_off();
    preempt_disable();
    call_function_with_irqs_and_preemption_off();
    local_irq_enable();
    call_function_with_preemption_off();
    preempt_enable();

Trình theo dõi irqsoff sẽ ghi lại tổng chiều dài của
call_function_with_irqs_off() và
call_function_with_irqs_and_preemption_off().

Bộ theo dõi ưu tiên sẽ ghi lại tổng chiều dài của
call_function_with_irqs_and_preemption_off() và
call_function_with_preemption_off().

Nhưng cả hai sẽ không theo dõi thời gian bị gián đoạn và/hoặc
quyền ưu tiên bị vô hiệu hóa. Tổng thời gian này là thời gian mà chúng ta có thể
không lên lịch. Để ghi lại thời gian này, hãy sử dụng preemptirqsoff
người đánh dấu.

Một lần nữa, việc sử dụng dấu vết này cũng giống như irqsoff và preemptoff
người theo dõi.
:::::::::::::::

# echo 0 > tùy chọn/dấu vết chức năng
  # echo ưu tiên tắt > current_tracer
  # echo 1 > truy tìm_on
  # echo 0 > tracing_max_latency
  # ls -ltr
  […]
  # echo 0 > truy tìm_on
  Dấu vết # cat
  # tracer: ưu tiên
  #
  Dấu vết độ trễ # preemptirqsoff v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 100 chúng tôi, #4/4, CPU#3 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: ls-2230 (uid:0 nice:0 chính sách:0 rt_prio:0)
  #    -----------------
  # => bắt đầu tại: ata_scsi_queuecmd
  # => kết thúc tại: ata_scsi_queuecmd
  #
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
        ls-2230 3d... 0us+: _raw_spin_lock_irqsave <-ata_scsi_queuecmd
        ls-2230 3...1 100us : _raw_spin_unlock_irqrestore <-ata_scsi_queuecmd
        ls-2230 3...1 101us+: trace_preempt_on <-ata_scsi_queuecmd
        ls-2230 3...1 111us : <dấu vết ngăn xếp>
   => sub_preempt_count
   => _raw_spin_unlock_irqrestore
   => ata_scsi_queuecmd
   => scsi_dispatch_cmd
   => scsi_request_fn
   => __blk_run_queue_uncond
   => __blk_run_queue
   => blk_queue_bio
   => submit_bio_noacct
   => gửi_bio
   => gửi_bh
   => ext3_bread
   => ext3_dir_bread
   => htree_dirblock_to_tree
   => ext3_htree_fill_tree
   => ext3_readdir
   => vfs_readdir
   => sys_getdents
   => system_call_fastpath


trace_hardirqs_off_thunk được gọi từ tập hợp trên x86 khi
các ngắt bị vô hiệu hóa trong mã lắp ráp. Nếu không có
theo dõi chức năng, chúng tôi không biết liệu các ngắt có được bật hay không
trong các điểm ưu tiên. Chúng tôi thấy rằng nó bắt đầu với
đã bật quyền ưu tiên.

Đây là dấu vết với bộ dấu vết chức năng ::

# tracer: ưu tiên
  #
  Dấu vết độ trễ # preemptirqsoff v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 161 chúng tôi, #339/339, CPU#3 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: ls-2269 (uid:0 nice:0 chính sách:0 rt_prio:0)
  #    -----------------
  # => bắt đầu lúc: lịch trình
  # => kết thúc lúc: mutex_unlock
  #
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
  kworker/-59 3...1 0us : __schedule <-schedule
  kworker/-59 3d..1 0us : rcu_preempt_qs <-rcu_note_context_switch
  kworker/-59 3d..1 1us : add_preempt_count <-_raw_spin_lock_irq
  kworker/-59 3d..2 1us : vô hiệu hóa_task <-__schedule
  kworker/-59 3d..2 1us : dequeue_task <-deactivate_task
  kworker/-59 3d..2 2us : update_rq_clock <-dequeue_task
  kworker/-59 3d..2 2us : dequeue_task_fair <-dequeue_task
  kworker/-59 3d..2 2us : update_curr <-dequeue_task_fair
  kworker/-59 3d..2 2us : update_min_vruntime <-update_curr
  kworker/-59 3d..2 3us : cpuacct_charge <-update_curr
  kworker/-59 3d..2 3us : __rcu_read_lock <-cpuacct_charge
  kworker/-59 3d..2 3us : __rcu_read_unlock <-cpuacct_charge
  kworker/-59 3d..2 3us : update_cfs_rq_blocked_load <-dequeue_task_fair
  kworker/-59 3d..2 4us : clear_buddies <-dequeue_task_fair
  kworker/-59 3d..2 4us : account_entity_dequeue <-dequeue_task_fair
  kworker/-59 3d..2 4us : update_min_vruntime <-dequeue_task_fair
  kworker/-59 3d..2 4us : update_cfs_shares <-dequeue_task_fair
  kworker/-59 3d..2 5us : hrtick_update <-dequeue_task_fair
  kworker/-59 3d..2 5us : wq_worker_sleeping <-__schedule
  kworker/-59 3d..2 5us : kthread_data <-wq_worker_sleeping
  kworker/-59 3d..2 5us : put_prev_task_fair <-__schedule
  kworker/-59 3d..2 6us : pick_next_task_fair <-pick_next_task
  kworker/-59 3d..2 6us : clear_buddies <-pick_next_task_fair
  kworker/-59 3d..2 6us : set_next_entity <-pick_next_task_fair
  kworker/-59 3d..2 6us : update_stats_wait_end <-set_next_entity
        ls-2269 3d..2 7us : finish_task_switch <-__schedule
        ls-2269 3d..2 7us : _raw_spin_unlock_irq <-finish_task_switch
        ls-2269 3d..2 8us : do_IRQ <-ret_from_intr
        ls-2269 3d..2 8us : irq_enter <-do_IRQ
        ls-2269 3d..2 8us : rcu_irq_enter <-irq_enter
        ls-2269 3d..2 9us : add_preempt_count <-irq_enter
        ls-2269 3d.h2 9us : exit_idle <-do_IRQ
  […]
        ls-2269 3d.h3 20us : sub_preempt_count <-_raw_spin_unlock
        ls-2269 3d.h2 20us : irq_exit <-do_IRQ
        ls-2269 3d.h2 21us : sub_preempt_count <-irq_exit
        ls-2269 3d..3 21us : do_softirq <-irq_exit
        ls-2269 3d..3 21us : __do_softirq <-call_softirq
        ls-2269 3d..3 21us+: __local_bh_disable <-__do_softirq
        ls-2269 3d.s4 29us : sub_preempt_count <-_local_bh_enable_ip
        ls-2269 3d.s5 29us : sub_preempt_count <-_local_bh_enable_ip
        ls-2269 3d.s5 31us : do_IRQ <-ret_from_intr
        ls-2269 3d.s5 31us : irq_enter <-do_IRQ
        ls-2269 3d.s5 31us : rcu_irq_enter <-irq_enter
  […]
        ls-2269 3d.s5 31us : rcu_irq_enter <-irq_enter
        ls-2269 3d.s5 32us : add_preempt_count <-irq_enter
        ls-2269 3d.H5 32us : exit_idle <-do_IRQ
        ls-2269 3d.H5 32us : hand_irq <-do_IRQ
        ls-2269 3d.H5 32us : irq_to_desc <-handle_irq
        ls-2269 3d.H5 33us : hand_fasteoi_irq <-handle_irq
  […]
        ls-2269 3d.s5 158us : _raw_spin_unlock_irqrestore <-rtl8139_poll
        ls-2269 3d.s3 158us : net_rps_action_and_irq_enable.isra.65 <-net_rx_action
        ls-2269 3d.s3 159us : __local_bh_enable <-__do_softirq
        ls-2269 3d.s3 159us : sub_preempt_count <-__local_bh_enable
        ls-2269 3d..3 159us : Idle_cpu <-irq_exit
        ls-2269 3d..3 159us : rcu_irq_exit <-irq_exit
        ls-2269 3d..3 160us : sub_preempt_count <-irq_exit
        ls-2269 3d... 161us : __mutex_unlock_slowpath <-mutex_unlock
        ls-2269 3d... 162us+: trace_hardirqs_on <-mutex_unlock
        ls-2269 3d... 186us : <dấu vết ngăn xếp>
   => __mutex_unlock_slowpath
   => mutex_unlock
   => quá trình_output
   => n_tty_write
   => tty_write
   => vfs_write
   => sys_write
   => system_call_fastpath

Đây là một dấu vết thú vị. Nó bắt đầu với việc kworker đang chạy và
lên kế hoạch và tôi sẽ tiếp quản. Nhưng ngay sau khi tôi phát hành
khóa rq và các ngắt được kích hoạt (nhưng không được ưu tiên) một ngắt
được kích hoạt. Khi ngắt kết thúc, nó bắt đầu chạy softirqs.
Nhưng trong khi softirq đang chạy, một ngắt khác được kích hoạt.
Khi một ngắt đang chạy bên trong softirq, chú thích là 'H'.


thức dậy
--------

Một trường hợp phổ biến mà mọi người quan tâm truy tìm là
thời gian cần thiết để một tác vụ được đánh thức thực sự thức dậy.
Bây giờ đối với các tác vụ không phải Thời gian thực, điều này có thể tùy ý. Nhưng truy tìm
Tuy nhiên nó có thể rất thú vị.

Không có dấu vết chức năng::

# echo 0 > tùy chọn/dấu vết chức năng
  Đánh thức # echo > current_tracer
  # echo 1 > truy tìm_on
  # echo 0 > tracing_max_latency
  # chrt -f 5 ngủ 1
  # echo 0 > truy tìm_on
  Dấu vết # cat
  # tracer: thức dậy
  #
  Dấu vết độ trễ # wakeup v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 15 chúng tôi, #4/4, CPU#3 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: kworker/3:1H-312 (uid:0 đẹp:-20 chính sách:0 rt_prio:0)
  #    -----------------
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
    <nhàn rỗi>-0 3dNs7 0us : 0:120:R + [003] 312:100:R kworker/3:1H
    <nhàn rỗi>-0 3dNs7 1us+: ttwu_do_activate.constprop.87 <-try_to_wake_up
    <nhàn rỗi>-0 3d..3 15us : __ lịch trình <-lịch trình
    <nhàn rỗi>-0 3d..3 15us : 0:120:R ==> [003] 312:100:R kworker/3:1H

Trình theo dõi chỉ theo dõi nhiệm vụ có mức độ ưu tiên cao nhất trong hệ thống
để tránh truy tìm những trường hợp bình thường. Ở đây chúng ta thấy rằng
kworker có mức độ ưu tiên cao là -20 (không đẹp lắm), đã lấy
chỉ 15 micro giây kể từ khi nó thức dậy cho đến khi nó
đã chạy.

Các tác vụ không theo thời gian thực không thú vị lắm. Thú vị hơn
trace là chỉ tập trung vào các tác vụ Thời gian thực.

Wakeup_rt
---------

Trong môi trường thời gian thực, điều quan trọng là phải biết
thời gian đánh thức cần thiết cho nhiệm vụ có mức độ ưu tiên cao nhất được đánh thức
cho đến thời điểm nó thực thi. Điều này còn được gọi là "lịch trình
độ trễ". Tôi nhấn mạnh rằng đây là về nhiệm vụ RT. Đó là
điều quan trọng nữa là phải biết độ trễ lập kế hoạch của các tác vụ không phải RT,
nhưng độ trễ lịch trình trung bình sẽ tốt hơn đối với các tác vụ không phải RT.
Các công cụ như LatencyTop phù hợp hơn cho những trường hợp như vậy
số đo.

Môi trường thời gian thực quan tâm đến độ trễ trong trường hợp xấu nhất.
Đó là khoảng thời gian chờ đợi lâu nhất để điều gì đó xảy ra,
và không phải là mức trung bình. Chúng ta có thể có một bộ lập lịch rất nhanh có thể
thỉnh thoảng chỉ có độ trễ lớn, nhưng điều đó sẽ không
hoạt động tốt với các tác vụ Thời gian thực.  Trình theo dõi Wakeup_rt được thiết kế
để ghi lại các lần đánh thức trong trường hợp xấu nhất của nhiệm vụ RT. Nhiệm vụ không phải RT là
không được ghi lại vì người theo dõi chỉ ghi lại một trường hợp xấu nhất và
việc truy tìm các tác vụ không phải RT không thể đoán trước sẽ ghi đè lên
độ trễ trong trường hợp xấu nhất của tác vụ RT (chỉ cần chạy đánh thức bình thường
tracer một lúc để thấy hiệu ứng đó).

Vì trình theo dõi này chỉ xử lý các tác vụ RT nên chúng tôi sẽ chạy nó
hơi khác so với những gì chúng tôi đã làm với các công cụ theo dõi trước đó.
Thay vì thực hiện 'ls', chúng tôi sẽ chạy 'ngủ 1' bên dưới
'chrt' làm thay đổi mức độ ưu tiên của tác vụ.
::::::::::::::::::::::::::::::::::::::::::::::

# echo 0 > tùy chọn/dấu vết chức năng
  # echo Wakeup_rt > current_tracer
  # echo 1 > truy tìm_on
  # echo 0 > tracing_max_latency
  # chrt -f 5 ngủ 1
  # echo 0 > truy tìm_on
  Dấu vết # cat
  # tracer: thức dậy
  #
  # tracer: Wakeup_rt
  #
  Dấu vết độ trễ # wakeup_rt v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 5 chúng tôi, #4/4, CPU#3 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: ngủ-2389 (uid:0 nice:0 chính sách:1 rt_prio:5)
  #    -----------------
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
    <nhàn rỗi>-0 3d.h4 0us : 0:120:R + [003] 2389: 94:R ngủ
    <nhàn rỗi>-0 3d.h4 1us+: ttwu_do_activate.constprop.87 <-try_to_wake_up
    <nhàn rỗi>-0 3d..3 5us : __ lịch trình <-lịch trình
    <nhàn rỗi>-0 3d..3 5us : 0:120:R ==> [003] 2389: 94:R ngủ


Chạy cái này trên một hệ thống nhàn rỗi, chúng tôi thấy rằng nó chỉ mất 5 micro giây
để thực hiện chuyển đổi nhiệm vụ.  Lưu ý, vì điểm theo dõi trong lịch trình
trước khi "chuyển đổi" thực tế, chúng tôi dừng việc theo dõi khi tác vụ đã ghi
sắp lên lịch. Điều này có thể thay đổi nếu chúng tôi thêm điểm đánh dấu mới tại
kết thúc của bộ lập lịch.

Lưu ý tác vụ ghi là “ngủ” với PID là 2389
và nó có rt_prio là 5. Mức độ ưu tiên này là mức độ ưu tiên của không gian người dùng
chứ không phải mức độ ưu tiên của kernel bên trong. Chính sách là 1 dành cho
SCHED_FIFO và 2 cho SCHED_RR.

Lưu ý rằng dữ liệu theo dõi hiển thị mức độ ưu tiên bên trong (99 - rtprio).
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

<nhàn rỗi>-0 3d..3 5us : 0:120:R ==> [003] 2389: 94:R ngủ

0:120:R có nghĩa là không hoạt động đang chạy với mức ưu tiên tốt là 0 (120 - 120)
và ở trạng thái chạy 'R'. Nhiệm vụ ngủ đã được lên lịch với
2389: 94: R. Đó là mức độ ưu tiên của kernel rtprio (99 - 5 = 94)
và nó cũng đang ở trạng thái chạy.

Làm tương tự với chrt -r 5 và bộ theo dõi chức năng.
::::::::::::::::::::::::::::::::::::::::::::::::::::

echo 1 > tùy chọn/dấu vết chức năng

  # tracer: wakeup_rt
  #
  # wakeup_rt latency trace v1.1.5 on 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 29 us, #85/85, CPU#3 | (M:preempt VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  #    | task: sleep-2448 (uid:0 nice:0 policy:1 rt_prio:5)
  #    -----------------
  #
  #                  _------=> CPU#            
  #                 / _-----=> irqs-off        
  #                | / _----=> need-resched    
  #                || / _---=> hardirq/softirq 
  #                ||| / _--=> preempt-depth   
  #                |||| /     delay             
  #  cmd     pid   ||||| time  |   caller      
  #     \   /      |||||  \    |   /           
    <idle>-0       3d.h4    1us+:      0:120:R   + [003]  2448: 94:R sleep
    <idle>-0       3d.h4    2us : ttwu_do_activate.constprop.87 <-try_to_wake_up
    <idle>-0       3d.h3    3us : check_preempt_curr <-ttwu_do_wakeup
    <idle>-0       3d.h3    3us : resched_curr <-check_preempt_curr
    <idle>-0       3dNh3    4us : task_woken_rt <-ttwu_do_wakeup
    <idle>-0       3dNh3    4us : _raw_spin_unlock <-try_to_wake_up
    <idle>-0       3dNh3    4us : sub_preempt_count <-_raw_spin_unlock
    <idle>-0       3dNh2    5us : ttwu_stat <-try_to_wake_up
    <idle>-0       3dNh2    5us : _raw_spin_unlock_irqrestore <-try_to_wake_up
    <idle>-0       3dNh2    6us : sub_preempt_count <-_raw_spin_unlock_irqrestore
    <idle>-0       3dNh1    6us : _raw_spin_lock <-__run_hrtimer
    <idle>-0       3dNh1    6us : add_preempt_count <-_raw_spin_lock
    <idle>-0       3dNh2    7us : _raw_spin_unlock <-hrtimer_interrupt
    <idle>-0       3dNh2    7us : sub_preempt_count <-_raw_spin_unlock
    <idle>-0       3dNh1    7us : tick_program_event <-hrtimer_interrupt
    <idle>-0       3dNh1    7us : clockevents_program_event <-tick_program_event
    <idle>-0       3dNh1    8us : ktime_get <-clockevents_program_event
    <idle>-0       3dNh1    8us : lapic_next_event <-clockevents_program_event
    <idle>-0       3dNh1    8us : irq_exit <-smp_apic_timer_interrupt
    <idle>-0       3dNh1    9us : sub_preempt_count <-irq_exit
    <idle>-0       3dN.2    9us : idle_cpu <-irq_exit
    <idle>-0       3dN.2    9us : rcu_irq_exit <-irq_exit
    <idle>-0       3dN.2   10us : rcu_eqs_enter_common.isra.45 <-rcu_irq_exit
    <idle>-0       3dN.2   10us : sub_preempt_count <-irq_exit
    <idle>-0       3.N.1   11us : rcu_idle_exit <-cpu_idle
    <idle>-0       3dN.1   11us : rcu_eqs_exit_common.isra.43 <-rcu_idle_exit
    <idle>-0       3.N.1   11us : tick_nohz_idle_exit <-cpu_idle
    <idle>-0       3dN.1   12us : menu_hrtimer_cancel <-tick_nohz_idle_exit
    <idle>-0       3dN.1   12us : ktime_get <-tick_nohz_idle_exit
    <idle>-0       3dN.1   12us : tick_do_update_jiffies64 <-tick_nohz_idle_exit
    <idle>-0       3dN.1   13us : cpu_load_update_nohz <-tick_nohz_idle_exit
    <idle>-0       3dN.1   13us : _raw_spin_lock <-cpu_load_update_nohz
    <idle>-0       3dN.1   13us : add_preempt_count <-_raw_spin_lock
    <idle>-0       3dN.2   13us : __cpu_load_update <-cpu_load_update_nohz
    <idle>-0       3dN.2   14us : sched_avg_update <-__cpu_load_update
    <idle>-0       3dN.2   14us : _raw_spin_unlock <-cpu_load_update_nohz
    <idle>-0       3dN.2   14us : sub_preempt_count <-_raw_spin_unlock
    <idle>-0       3dN.1   15us : calc_load_nohz_stop <-tick_nohz_idle_exit
    <idle>-0       3dN.1   15us : touch_softlockup_watchdog <-tick_nohz_idle_exit
    <idle>-0       3dN.1   15us : hrtimer_cancel <-tick_nohz_idle_exit
    <idle>-0       3dN.1   15us : hrtimer_try_to_cancel <-hrtimer_cancel
    <idle>-0       3dN.1   16us : lock_hrtimer_base.isra.18 <-hrtimer_try_to_cancel
    <idle>-0       3dN.1   16us : _raw_spin_lock_irqsave <-lock_hrtimer_base.isra.18
    <idle>-0       3dN.1   16us : add_preempt_count <-_raw_spin_lock_irqsave
    <idle>-0       3dN.2   17us : __remove_hrtimer <-remove_hrtimer.part.16
    <idle>-0       3dN.2   17us : hrtimer_force_reprogram <-__remove_hrtimer
    <idle>-0       3dN.2   17us : tick_program_event <-hrtimer_force_reprogram
    <idle>-0       3dN.2   18us : clockevents_program_event <-tick_program_event
    <idle>-0       3dN.2   18us : ktime_get <-clockevents_program_event
    <idle>-0       3dN.2   18us : lapic_next_event <-clockevents_program_event
    <idle>-0       3dN.2   19us : _raw_spin_unlock_irqrestore <-hrtimer_try_to_cancel
    <idle>-0       3dN.2   19us : sub_preempt_count <-_raw_spin_unlock_irqrestore
    <idle>-0       3dN.1   19us : hrtimer_forward <-tick_nohz_idle_exit
    <idle>-0       3dN.1   20us : ktime_add_safe <-hrtimer_forward
    <idle>-0       3dN.1   20us : ktime_add_safe <-hrtimer_forward
    <idle>-0       3dN.1   20us : hrtimer_start_range_ns <-hrtimer_start_expires.constprop.11
    <idle>-0       3dN.1   20us : __hrtimer_start_range_ns <-hrtimer_start_range_ns
    <idle>-0       3dN.1   21us : lock_hrtimer_base.isra.18 <-__hrtimer_start_range_ns
    <idle>-0       3dN.1   21us : _raw_spin_lock_irqsave <-lock_hrtimer_base.isra.18
    <idle>-0       3dN.1   21us : add_preempt_count <-_raw_spin_lock_irqsave
    <idle>-0       3dN.2   22us : ktime_add_safe <-__hrtimer_start_range_ns
    <idle>-0       3dN.2   22us : enqueue_hrtimer <-__hrtimer_start_range_ns
    <idle>-0       3dN.2   22us : tick_program_event <-__hrtimer_start_range_ns
    <idle>-0       3dN.2   23us : clockevents_program_event <-tick_program_event
    <idle>-0       3dN.2   23us : ktime_get <-clockevents_program_event
    <idle>-0       3dN.2   23us : lapic_next_event <-clockevents_program_event
    <idle>-0       3dN.2   24us : _raw_spin_unlock_irqrestore <-__hrtimer_start_range_ns
    <idle>-0       3dN.2   24us : sub_preempt_count <-_raw_spin_unlock_irqrestore
    <idle>-0       3dN.1   24us : account_idle_ticks <-tick_nohz_idle_exit
    <idle>-0       3dN.1   24us : account_idle_time <-account_idle_ticks
    <idle>-0       3.N.1   25us : sub_preempt_count <-cpu_idle
    <idle>-0       3.N..   25us : schedule <-cpu_idle
    <idle>-0       3.N..   25us : __schedule <-preempt_schedule
    <idle>-0       3.N..   26us : add_preempt_count <-__schedule
    <idle>-0       3.N.1   26us : rcu_note_context_switch <-__schedule
    <idle>-0       3.N.1   26us : rcu_sched_qs <-rcu_note_context_switch
    <idle>-0       3dN.1   27us : rcu_preempt_qs <-rcu_note_context_switch
    <idle>-0       3.N.1   27us : _raw_spin_lock_irq <-__schedule
    <idle>-0       3dN.1   27us : add_preempt_count <-_raw_spin_lock_irq
    <idle>-0       3dN.2   28us : put_prev_task_idle <-__schedule
    <idle>-0       3dN.2   28us : pick_next_task_stop <-pick_next_task
    <idle>-0       3dN.2   28us : pick_next_task_rt <-pick_next_task
    <idle>-0       3dN.2   29us : dequeue_pushable_task <-pick_next_task_rt
    <idle>-0       3d..3   29us : __schedule <-preempt_schedule
    <idle>-0       3d..3   30us :      0:120:R ==> [003]  2448: 94:R sleep

Đây không phải là dấu vết lớn, ngay cả khi bật tính năng dò tìm chức năng,
vì vậy tôi đã bao gồm toàn bộ dấu vết.

Sự gián đoạn đã tắt khi hệ thống không hoạt động. Ở đâu đó
trước khi task_woken_rt() được gọi, cờ NEED_RESCHED đã được đặt,
điều này được biểu thị bằng sự xuất hiện đầu tiên của cờ 'N'.

Theo dõi độ trễ và sự kiện
--------------------------
Vì việc dò tìm hàm có thể gây ra độ trễ lớn hơn nhiều nhưng không
nhìn thấy những gì xảy ra trong thời gian trễ thật khó để biết điều gì
gây ra nó. Có một nền tảng trung gian, đó là việc cho phép
sự kiện.
::::::::

# echo 0 > tùy chọn/dấu vết chức năng
  # echo Wakeup_rt > current_tracer
  # echo 1 > sự kiện/kích hoạt
  # echo 1 > truy tìm_on
  # echo 0 > tracing_max_latency
  # chrt -f 5 ngủ 1
  # echo 0 > truy tìm_on
  Dấu vết # cat
  # tracer: Wakeup_rt
  #
  Dấu vết độ trễ # wakeup_rt v1.1.5 trên 3.8.0-test+
  # --------------------------------------------------------------------
  # latency: 6 chúng tôi, #12/12, CPU#2 | (M:đánh chiếm trước VP:0, KP:0, SP:0 HP:0 #P:4)
  #    -----------------
  # | nhiệm vụ: ngủ-5882 (uid:0 nice:0 chính sách:1 rt_prio:5)
  #    -----------------
  #
  #                  _------=> CPU#            
  # / __---=> irqs-tắt        
  # | / __---=> cần được chỉnh sửa lại    
  # || / _---=> hardirq/softirq 
  # ||| / _--=> ưu tiên độ sâu   
  # |||| / trì hoãn             
  #  cmd pid ||||ZZ0000ZZ người gọi      
  # \ / ||||ZZ0001ZZ /           
    <nhàn rỗi>-0 2d.h4 0us : 0:120:R + [002] 5882: 94:R ngủ
    <nhàn rỗi>-0 2d.h4 0us : ttwu_do_activate.constprop.87 <-try_to_wake_up
    <nhàn rỗi>-0 2d.h4 1us : sched_wakeup: comm=sleep pid=5882 prio=94 thành công=1 target_cpu=002
    <nhàn rỗi>-0 2dNh2 1us : hrtimer_expire_exit: hrtimer=ffff88007796feb8
    <nhàn rỗi>-0 2.N.2 2us : power_end: cpu_id=2
    <nhàn rỗi>-0 2.N.2 3us : cpu_idle: state=4294967295 cpu_id=2
    <nhàn rỗi>-0 2dN.3 4us : hrtimer_cancel: hrtimer=ffff88007d50d5e0
    <nhàn rỗi>-0 2dN.3 4us : hrtimer_start: hrtimer=ffff88007d50d5e0 function=tick_sched_timer hết hạn=34311211000000 softexpires=34311211000000
    <idle>-0 2.N.2 5us : rcu_utilization: Bắt đầu chuyển ngữ cảnh
    <idle>-0 2.N.2 5us : rcu_utilization: Kết thúc chuyển đổi ngữ cảnh
    <nhàn rỗi>-0 2d..3 6us : __ lịch trình <-lịch trình
    <nhàn rỗi>-0 2d..3 6us : 0:120:R ==> [002] 5882: 94:R ngủ


Trình phát hiện độ trễ phần cứng
--------------------------------

Trình phát hiện độ trễ phần cứng được thực thi bằng cách bật trình theo dõi "hwlat".

NOTE, chất đánh dấu này sẽ ảnh hưởng đến hiệu suất của hệ thống vì nó sẽ
định kỳ làm cho CPU liên tục bận và tắt các ngắt.
:::::::::::::::::::::::::::::::::::::::::::::::::

# echo hwlat > current_tracer
  # sleep 100
  Dấu vết # cat
  # tracer: hwlat
  #
  # entries-in-buffer/mục viết: 13/13 #P:8
  #
  #                              _-----=> không hoạt động
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
             <...>-1729 [001] d... 678.473449: #1 bên trong/bên ngoài(us): 12/11 ts:1581527483.343962693 đếm:6
             <...>-1729 [004] d... 689.556542: #2 bên trong/bên ngoài(us): 16/9 ts:1581527494.889008092 đếm:1
             <...>-1729 [005] d... 714.756290: #3 bên trong/bên ngoài(us): 16/16 ts:1581527519.678961629 đếm:5
             <...>-1729 [001] d... 718.788247: #4 bên trong/bên ngoài(us): 17/9 ts:1581527523.889012713 đếm:1
             <...>-1729 [002] d... 719.796341: #5 bên trong/bên ngoài(us): 13/9 ts:1581527524.912872606 đếm:1
             <...>-1729 [006] d... 844.787091: #6 bên trong/bên ngoài(us): 12/9 ts:1581527649.889048502 đếm:2
             <...>-1729 [003] d... 849.827033: #7 bên trong/bên ngoài(us): 18/9 ts:1581527654.889013793 đếm:1
             <...>-1729 [007] d... 853.859002: #8 bên trong/bên ngoài(us): 12/9 ts:1581527658.889065736 đếm:1
             <...>-1729 [001] d... 855.874978: #9 bên trong/bên ngoài(us): 11/9 ts:1581527660.861991877 đếm:1
             <...>-1729 [001] d... 863.938932: #10 bên trong/bên ngoài(us): 11/9 ts:1581527668.970010500 số lượng:1 nmi-total:7 nmi-count:1
             <...>-1729 [007] d... 878.050780: #11 bên trong/bên ngoài(us): 12/9 ts:1581527683.385002600 số lượng:1 nmi-total:5 nmi-count:1
             <...>-1729 [007] d... 886.114702: #12 bên trong/bên ngoài(us): 12/9 ts:1581527691.385001600 đếm:1


Đầu ra ở trên có phần giống nhau trong tiêu đề. Tất cả các sự kiện sẽ có
ngắt bị vô hiệu hóa 'd'. Dưới tiêu đề FUNCTION có:

#1
	Đây là số lượng sự kiện được ghi lại lớn hơn số lượng sự kiện
	tracing_threshold (Xem bên dưới).

bên trong/bên ngoài (chúng ta): 11/11

Điều này hiển thị hai số là "độ trễ bên trong" và "độ trễ bên ngoài". Bài kiểm tra
      chạy trong một vòng lặp kiểm tra dấu thời gian hai lần. Độ trễ được phát hiện trong
      hai dấu thời gian là "độ trễ bên trong" và độ trễ được phát hiện
      sau dấu thời gian trước đó và dấu thời gian tiếp theo trong vòng lặp là
      "độ trễ bên ngoài".

ts:1581527483.343962693

Dấu thời gian tuyệt đối mà độ trễ đầu tiên được ghi lại trong cửa sổ.

đếm: 6

Số lần độ trễ được phát hiện trong cửa sổ.

tổng nmi:7 nmi-đếm:1

Trên các kiến trúc hỗ trợ nó, nếu NMI xuất hiện trong quá trình
      kiểm tra, thời gian dành cho NMI được báo cáo dưới dạng "nmi-total" (trong
      micro giây).

Tất cả các kiến trúc có NMI sẽ hiển thị "nmi-count" nếu một
      NMI xuất hiện trong quá trình thử nghiệm.

tập tin hwlat:

tracing_threshold
	Điều này được tự động đặt thành "10" để đại diện cho 10
	micro giây. Đây là ngưỡng độ trễ mà
	cần phải được phát hiện trước khi dấu vết được ghi lại.

Lưu ý, khi hwlat tracer kết thúc (một tracer khác được
	được viết vào "current_tracer"), giá trị ban đầu cho
	tracing_threshold được đặt lại vào tệp này.

hwlat_Detector/chiều rộng
	Khoảng thời gian chạy thử nghiệm với các ngắt bị vô hiệu hóa.

hwlat_Detector/cửa sổ
	Khoảng thời gian của cửa sổ mà bài kiểm tra
	chạy. Nghĩa là, bài kiểm tra sẽ chạy với "chiều rộng"
	micro giây trên mỗi "cửa sổ" micro giây

tracing_cpumask
	Khi bài kiểm tra bắt đầu. Một luồng hạt nhân được tạo ra
	chạy thử nghiệm. Chủ đề này sẽ luân phiên giữa các CPU
	được liệt kê trong tracing_cpumask giữa mỗi kỳ
	(một "cửa sổ"). Để giới hạn thử nghiệm ở các CPU cụ thể
	đặt mặt nạ trong tệp này chỉ cho các CPU được kiểm tra
	nên chạy tiếp.

chức năng
---------

Công cụ theo dõi này là công cụ theo dõi chức năng. Kích hoạt chức năng theo dõi chức năng
có thể được thực hiện từ hệ thống tập tin gỡ lỗi. Hãy chắc chắn rằng
ftrace_enabled được đặt; nếu không thì công cụ đánh dấu này là không có.
Xem phần "ftrace_enabled" bên dưới.
:::::::::::::::::::::::::::::::::::

# sysctl kernel.ftrace_enabled=1
  Hàm # echo > current_tracer
  # echo 1 > truy tìm_on
  # usleep 1
  # echo 0 > truy tìm_on
  Dấu vết # cat
  # tracer: chức năng
  #
  # entries-in-buffer/mục viết: 24799/24799 #P:4
  #
  #                              _-----=> không hoạt động
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
              bash-1994 [002] .... 3082.063030: mutex_unlock <-rb_simple_write
              bash-1994 [002] .... 3082.063031: __mutex_unlock_slowpath <-mutex_unlock
              bash-1994 [002] .... 3082.063031: __fsnotify_parent <-fsnotify_modify
              bash-1994 [002] .... 3082.063032: fsnotify <-fsnotify_modify
              bash-1994 [002] .... 3082.063032: __srcu_read_lock <-fsnotify
              bash-1994 [002] .... 3082.063032: add_preempt_count <-__srcu_read_lock
              bash-1994 [002] ...1 3082.063032: sub_preempt_count <-__srcu_read_lock
              bash-1994 [002] .... 3082.063033: __srcu_read_unlock <-fsnotify
  […]


Lưu ý: hàm tracer sử dụng bộ đệm vòng để lưu trữ thông tin trên
mục nhập. Dữ liệu mới nhất có thể ghi đè lên dữ liệu cũ nhất.
Đôi khi sử dụng tiếng vang để dừng dấu vết là không đủ vì
việc theo dõi có thể đã ghi đè lên dữ liệu mà bạn muốn
ghi lại. Vì lý do này, đôi khi tốt hơn là nên tắt
truy tìm trực tiếp từ một chương trình. Điều này cho phép bạn dừng việc
truy tìm điểm mà bạn chạm vào phần mà bạn đang có
quan tâm. Để tắt tính năng theo dõi trực tiếp từ chương trình C,
có thể sử dụng đoạn mã như sau ::

int trace_fd;
	[…]
	int main(int argc, char *argv[]) {
		[…]
		trace_fd = open(tracing_file("tracing_on"), O_WRONLY);
		[…]
		nếu (điều kiện_hit()) {
			write(trace_fd, "0", 1);
		}
		[…]
	}


Truy tìm chủ đề đơn
---------------------

Bằng cách viết vào set_ftrace_pid bạn có thể theo dõi
sợi đơn. Ví dụ::

# cat set_ftrace_pid
  không có pid
  # echo 3111 > set_ftrace_pid
  # cat set_ftrace_pid
  3111
  Hàm # echo > current_tracer
  Dấu vết # cat | cái đầu
  # tracer: chức năng
  #
  #           ZZ0004ZZ-ZZ0005ZZ CPU#    ZZ0007ZZ FUNCTION
  #              ZZ0009ZZ ZZ0001ZZ |
      yum-updatesd-3111 [003] 1637.254676: finish_task_switch <-thread_return
      yum-updatesd-3111 [003] 1637.254681: hrtimer_cancel <-schedule_hrtimeout_range
      yum-updatesd-3111 [003] 1637.254682: hrtimer_try_to_cancel <-hrtimer_cancel
      yum-updatesd-3111 [003] 1637.254683: lock_hrtimer_base <-hrtimer_try_to_cancel
      yum-updatesd-3111 [003] 1637.254685: fget_light <-do_sys_poll
      yum-updatesd-3111 [003] 1637.254686: pipe_poll <-do_sys_poll
  # echo > set_ftrace_pid
  Dấu vết # cat | đầu
  # tracer: chức năng
  #
  #           ZZ0011ZZ-ZZ0012ZZ CPU#    ZZ0014ZZ FUNCTION
  #              ZZ0016ZZ ZZ0003ZZ |
  ####Bộ đệm # ZZ0018ZZ 3 đã bắt đầu ####
      yum-updatesd-3111 [003] 1701.957688: free_poll_entry <-poll_freewait
      yum-updatesd-3111 [003] 1701.957689: Remove_wait_queue <-free_poll_entry
      yum-updatesd-3111 [003] 1701.957691: fput <-free_poll_entry
      yum-updatesd-3111 [003] 1701.957692: kiểm toán_syscall_exit <-sysret_audit
      yum-updatesd-3111 [003] 1701.957693: path_put <-audit_syscall_exit

Nếu bạn muốn theo dõi một hàm khi thực thi, bạn có thể sử dụng
một cái gì đó giống như chương trình đơn giản này.
::::::::::::::::::::::::::::::::::::::::::::::::::

#include <stdio.h>
	#include <stdlib.h>
	#include <sys/types.h>
	#include <sys/stat.h>
	#include <fcntl.h>
	#include <unistd.h>
	#include <string.h>

#define _STR(x) #x
	#define STR(x) _STR(x)
	#define MAX_PATH 256

const char *find_tracefs(void)
	{
	       dấu vết char tĩnh [MAX_PATH+1];
	       int tĩnh tracefs_found;
	       kiểu char[100];
	       FILE *fp;

nếu (tracefs_found)
		       trả lại dấu vết;

if ((fp = fopen("/proc/mounts","r")) == NULL) {
		       perror("/proc/mounts");
		       trả lại NULL;
	       }

trong khi (fscanf(fp, "%*s %"
		             STR(MAX_PATH)
		             "s %99s %*s %*d %*d\n",
		             dấu vết, loại) == 2) {
		       if (strcmp(type, "tracefs") == 0)
		               phá vỡ;
	       }
	       fclose(fp);

if (strcmp(type, "tracefs") != 0) {
		       fprintf(stderr, "dấu vết chưa được gắn kết");
		       trả lại NULL;
	       }

strcat(tracefs, "/tracing/");
	       tracefs_found = 1;

trả lại dấu vết;
	}

const char *tracing_file(const char *file_name)
	{
	       char tĩnh trace_file[MAX_PATH+1];
	       snprintf(trace_file, MAX_PATH, "%s/%s", find_tracefs(), file_name);
	       trả về trace_file;
	}

int chính (int argc, char **argv)
	{
		nếu (argc < 1)
		        thoát (-1);

nếu (ngã ba() > 0) {
		        int fd, ffd;
		        dòng char[64];
		        int s;

ffd = open(tracing_file("current_tracer"), O_WRONLY);
		        nếu (ffd < 0)
		                thoát (-1);
		        write(ffd, "nop", 3);

fd = open(tracing_file("set_ftrace_pid"), O_WRONLY);
		        s = sprintf(line, "%d\n", getpid());
		        write(fd, line, s);

write(ffd, "hàm", 8);

đóng(fd);
		        đóng(ffd);

execvp(argv[1], argv+1);
		}

trả về 0;
	}

Hoặc kịch bản đơn giản này!
:::::::::::::::::::::::::::

#!/bin/bash

tracefs=ZZ0000ZZ
  echo 0 > $tracefs/tracing_on
  echo $$ > $tracefs/set_ftrace_pid
  hàm echo > $ tracefs/current_tracer
  echo 1 > $tracefs/tracing_on
  thực thi "$@"


công cụ theo dõi đồ thị hàm số
------------------------------

Công cụ theo dõi này tương tự như công cụ theo dõi chức năng ngoại trừ việc nó
thăm dò một chức năng trên lối vào và lối ra của nó. Việc này được thực hiện bởi
bằng cách sử dụng một chồng địa chỉ trả về được phân bổ động trong mỗi
nhiệm vụ_struct. Khi nhập hàm, trình theo dõi sẽ ghi đè kết quả trả về
địa chỉ của từng chức năng được truy tìm để đặt đầu dò tùy chỉnh. Vì thế
địa chỉ trả lại ban đầu được lưu trữ trên ngăn xếp địa chỉ trả lại
trong task_struct.

Việc thăm dò ở cả hai đầu của hàm dẫn đến các tính năng đặc biệt
chẳng hạn như:

- thước đo thời gian thực hiện của một hàm
- có một ngăn xếp cuộc gọi đáng tin cậy để vẽ biểu đồ cuộc gọi hàm

Công cụ theo dõi này hữu ích trong một số trường hợp:

- bạn muốn tìm lý do của một hành vi lạ của kernel và
  cần xem điều gì xảy ra chi tiết trên bất kỳ lĩnh vực nào (hoặc cụ thể
  những cái).

- bạn đang gặp phải độ trễ kỳ lạ nhưng thật khó để
  tìm ra nguồn gốc của nó.

- bạn muốn tìm nhanh con đường nào được đi bởi một người cụ thể
  chức năng

- bạn chỉ muốn nhìn vào bên trong một hạt nhân đang hoạt động và muốn xem
  những gì xảy ra ở đó

::

# tracer: hàm_graph
  #
  # ZZ0003ZZ DURATION FUNCTION CALLS
  # ZZ0007ZZ ZZ0001ZZ ZZ0002ZZ |

0) |  sys_open() {
   0) |    do_sys_open() {
   0) |      lấy tên() {
   0) |        kmem_cache_alloc() {
   0) 1.382 chúng tôi |          __might_sleep();
   0) 2.478 chúng tôi |        }
   0) |        strncpy_from_user() {
   0) |          may_fault() {
   0) 1.389 chúng tôi |            __might_sleep();
   0) 2.553 chúng tôi |          }
   0) 3.807 chúng tôi |        }
   0) 7.876 chúng tôi |      }
   0) |      cấp phát_fd() {
   0) 0,668 chúng tôi |        _spin_lock();
   0) 0,570 chúng tôi |        bung_files();
   0) 0,586 chúng tôi |        _spin_unlock();


Có một số cột có thể được tự động
kích hoạt/vô hiệu hóa. Bạn có thể sử dụng mọi sự kết hợp của các tùy chọn mà bạn
muốn, tùy theo nhu cầu của bạn.

- Số CPU mà hàm được thực thi là mặc định
  đã bật.  Đôi khi tốt hơn là chỉ theo dõi một CPU (xem
  tracing_cpumask) hoặc đôi khi bạn có thể thấy không có thứ tự
  gọi hàm trong khi chuyển đổi theo dõi cpu.

- ẩn: echo nofuncgraph-cpu > trace_options
	- hiển thị: echo funcgraph-cpu > trace_options

- Thời lượng (thời gian thực hiện của hàm) được hiển thị trên
  dòng dấu ngoặc đóng của một hàm hoặc trên cùng một dòng
  hơn chức năng hiện tại trong trường hợp của một chiếc lá. Đó là mặc định
  đã bật.

- ẩn: echo nofuncgraph-duration > trace_options
	- hiển thị: echo funcgraph-duration > trace_options

- Trường overhead đứng trước trường thời lượng trong trường hợp
  đã đạt đến ngưỡng thời lượng.

- ẩn: echo nofuncgraph-overhead > trace_options
	- hiển thị: echo funcgraph-overhead > trace_options
	- phụ thuộc vào: funcgraph-duration

tức là::

3) # 1837.709 chúng tôi |          } /* __switch_to */
    3) |          kết thúc_task_switch() {
    3) 0,313 chúng tôi |            _raw_spin_unlock_irq();
    3) 3.177 chúng tôi |          }
    3) # 1889.063 chúng tôi |        } /* __lên lịch */
    3) ! 140.417 chúng tôi |      } /* __lên lịch */
    3) # 2034.948 chúng tôi |    } /* lên lịch */
    3) * 33998,59 chúng tôi |  } /* lịch_preempt_disabled */

[…]

1) 0,260 chúng tôi |              msecs_to_jiffies();
    1) 0,313 chúng tôi |              __rcu_read_unlock();
    1) + 61.770 chúng tôi |            }
    1) + 64.479 chúng tôi |          }
    1) 0,313 chúng tôi |          rcu_bh_qs();
    1) 0,313 chúng tôi |          __local_bh_enable();
    1) ! 217.240 chúng tôi |        }
    1) 0,365 chúng tôi |        nhàn rỗi_cpu();
    1) |        rcu_irq_exit() {
    1) 0,417 chúng tôi |          rcu_eqs_enter_common.isra.47();
    1) 3.125 chúng tôi |        }
    1) ! 227.812 chúng tôi |      }
    1) ! 457.395 chúng tôi |    }
    1) @ 119760.2 chúng tôi |  }

[…]

2) |    xử lý_IPI() {
    1) 6.979 chúng tôi |                  }
    2) 0,417 chúng tôi |      lịch trình_ipi();
    1) 9.791 chúng tôi |                }
    1) + 12.917 chúng tôi |              }
    2) 3.490 chúng tôi |    }
    1) + 15.729 chúng tôi |            }
    1) + 18.542 chúng tôi |          }
    2) $ 3594274 cho chúng tôi |  }

Cờ::

+ có nghĩa là chức năng vượt quá 10 usecs.
  ! có nghĩa là hàm đã vượt quá 100 usecs.
  # means rằng chức năng này đã vượt quá 1000 usec.
  * có nghĩa là hàm vượt quá 10 mili giây.
  @ có nghĩa là hàm vượt quá 100 mili giây.
  $ có nghĩa là hàm vượt quá 1 giây.


- Trường task/pid hiển thị cmdline và pid của thread
  đã thực hiện chức năng. Nó được tắt mặc định.

- ẩn: echo nofuncgraph-proc > trace_options
	- hiển thị: echo funcgraph-proc > trace_options

tức là::

# tracer: hàm_graph
    #
    # ZZ0013ZZ TASK/PID DURATION FUNCTION CALLS
    # ZZ0019ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ |
    0) sh-4802 ZZ0004ZZ d_free() {
    0) sh-4802 ZZ0005ZZ call_rcu() {
    0) sh-4802 ZZ0006ZZ __call_rcu() {
    0) sh-4802 ZZ0007ZZ rcu_process_gp_end();
    0) sh-4802 ZZ0008ZZ check_for_new_grace_ Period();
    0) sh-4802 ZZ0009ZZ }
    0) sh-4802 ZZ0010ZZ }
    0) sh-4802 ZZ0011ZZ }
    0) sh-4802 ZZ0012ZZ }


- Trường thời gian tuyệt đối là dấu thời gian tuyệt đối được đưa ra bởi
  đồng hồ hệ thống kể từ khi nó bắt đầu. Ảnh chụp nhanh thời gian này là
  được đưa ra trên mỗi lần vào/ra của chức năng

- ẩn: echo nofuncgraph-abstime > trace_options
	- hiển thị: echo funcgraph-abstime > trace_options

tức là::

#
    #      ZZ0017ZZ CPU DURATION FUNCTION CALLS
    #       ZZ0022ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
    360.774522 ZZ0004ZZ }
    360.774522 ZZ0005ZZ }
    360.774523 ZZ0006ZZ __wake_up_bit();
    360.774524 ZZ0007ZZ }
    360.774524 ZZ0008ZZ }
    360.774525 ZZ0009ZZ }
    360.774525 ZZ0010ZZ tạp chí_mark_dirty();
    360.774527 ZZ0011ZZ __brelse();
    360.774528 ZZ0012ZZ reiserfs_prepare_for_journal() {
    360.774528 ZZ0013ZZ unlock_buffer() {
    360.774529 ZZ0014ZZ Wake_up_bit() {
    360.774529 ZZ0015ZZ bit_waitqueue() {
    360.774530 ZZ0016ZZ __phys_addr();


Tên hàm luôn được hiển thị sau dấu ngoặc đóng
đối với một hàm nếu điểm bắt đầu của hàm đó không nằm trong
bộ đệm dấu vết.

Việc hiển thị tên hàm sau dấu ngoặc đóng có thể
được bật cho các chức năng có điểm bắt đầu trong bộ đệm theo dõi,
cho phép tìm kiếm dễ dàng hơn với grep trong thời lượng chức năng.
Nó được tắt mặc định.

- ẩn: echo nofuncgraph-tail > trace_options
	- hiển thị: echo funcgraph-tail > trace_options

Ví dụ với nofuncgraph-tail (mặc định)::

0) |      tên đặt () {
    0) |        kmem_cache_free() {
    0) 0,518 chúng tôi |          __phys_addr();
    0) 1.757 chúng tôi |        }
    0) 2.861 chúng tôi |      }

Ví dụ với funcgraph-tail::

0) |      tên đặt () {
    0) |        kmem_cache_free() {
    0) 0,518 chúng tôi |          __phys_addr();
    0) 1.757 chúng tôi |        } /* kmem_cache_free() */
    0) 2.861 chúng tôi |      } /* đặt tên() */

Giá trị trả về của mỗi hàm theo dõi có thể được hiển thị sau
dấu bằng "=". Khi gặp lỗi cuộc gọi hệ thống, nó
có thể rất hữu ích để nhanh chóng xác định chức năng đầu tiên
trả về một mã lỗi.

- ẩn: echo nofuncgraph-retval > trace_options
	- hiển thị: echo funcgraph-retval > trace_options

Ví dụ với funcgraph-retval::

1) |    cgroup_migrate() {
    1) 0,651 chúng tôi |      cgroup_migrate_add_task(); /* = 0xffff93fcfd346c00 */
    1) |      cgroup_migrate_execute() {
    1) |        cpu_cgroup_can_attach() {
    1) |          cgroup_taskset_first() {
    1) 0,732 chúng tôi |            cgroup_taskset_next(); /* = 0xffff93fc8fb20000 */
    1) 1.232 chúng tôi |          } /* cgroup_taskset_first = 0xffff93fc8fb20000 */
    1) 0,380 chúng tôi |          lịch_rt_can_attach(); /* = 0x0 */
    1) 2.335 chúng tôi |        } /* cpu_cgroup_can_attach = -22 */
    1) 4.369 chúng tôi |      } /* cgroup_migrate_execute = -22 */
    1) 7.143 chúng tôi |    } /* cgroup_migrate = -22 */

Ví dụ trên cho thấy hàm cpu_cgroup_can_attach
trước tiên trả về mã lỗi -22, sau đó chúng ta có thể đọc mã
của chức năng này để có được nguyên nhân gốc rễ.

Khi tùy chọn funcgraph-retval-hex không được đặt, giá trị trả về có thể
được hiển thị một cách thông minh. Cụ thể, nếu đó là mã lỗi,
nó sẽ được in ở định dạng thập phân có dấu, nếu không nó sẽ
được in ở định dạng thập lục phân.

- thông minh: echo nofuncgraph-retval-hex > trace_options
	- hệ thập lục phân: echo funcgraph-retval-hex > trace_options

Ví dụ với funcgraph-retval-hex::

1) |      cgroup_migrate() {
    1) 0,651 chúng tôi |        cgroup_migrate_add_task(); /* = 0xffff93fcfd346c00 */
    1) |        cgroup_migrate_execute() {
    1) |          cpu_cgroup_can_attach() {
    1) |            cgroup_taskset_first() {
    1) 0,732 chúng tôi |              cgroup_taskset_next(); /* = 0xffff93fc8fb20000 */
    1) 1.232 chúng tôi |            } /* cgroup_taskset_first = 0xffff93fc8fb20000 */
    1) 0,380 chúng tôi |            lịch_rt_can_attach(); /* = 0x0 */
    1) 2.335 chúng tôi |          } /* cpu_cgroup_can_attach = 0xffffffea */
    1) 4.369 chúng tôi |        } /* cgroup_migrate_execute = 0xffffffea */
    1) 7.143 chúng tôi |      } /* cgroup_migrate = 0xffffffea */

Hiện tại, có một số hạn chế khi sử dụng funcgraph-retval
tùy chọn và những hạn chế này sẽ được loại bỏ trong tương lai:

- Ngay cả khi kiểu trả về của hàm là void, giá trị trả về vẫn sẽ
  được in và bạn có thể bỏ qua nó.

- Ngay cả khi các giá trị trả về được lưu trữ trong nhiều thanh ghi, chỉ có
  giá trị chứa trong thanh ghi đầu tiên sẽ được ghi lại và in ra.
  Để minh họa, trong kiến trúc x86, eax và edx được sử dụng để lưu trữ
  giá trị trả về 64 bit, với 32 bit thấp hơn được lưu trong eax và
  32 bit trên được lưu trong edx. Tuy nhiên, chỉ có giá trị được lưu trữ trong eax
  sẽ được ghi lại và in ra.

- Trong một số tiêu chuẩn gọi thủ tục nhất định, chẳng hạn như AAPCS64 của arm64, khi một
  loại nhỏ hơn GPR thì đó là trách nhiệm của người tiêu dùng
  để thực hiện việc thu hẹp và các bit trên có thể chứa các giá trị UNKNOWN.
  Vì vậy, nên kiểm tra mã cho những trường hợp như vậy. Ví dụ,
  khi sử dụng u8 trong GPR 64 bit, các bit [63:8] có thể chứa các giá trị tùy ý,
  đặc biệt là khi các loại lớn hơn bị cắt ngắn, dù rõ ràng hay ngầm định.
  Dưới đây là một số trường hợp cụ thể minh họa cho quan điểm này:

ZZ0000ZZ:

Hàm thu hẹp_to_u8 được định nghĩa như sau ::

u8 thu hẹp_to_u8(u64 val)
	{
		// bị cắt ngắn ngầm
		trả lại giá trị;
	}

Nó có thể được biên dịch thành::

thu hẹp_to_u8:
		< ... thiết bị ftrace ... >
		RET

Nếu bạn chuyển 0x123456789abcdef cho hàm này và muốn thu hẹp nó,
  nó có thể được ghi là 0x123456789abcdef thay vì 0xef.

ZZ0000ZZ:

Hàm error_if_not_4g_aligned được định nghĩa như sau::

int error_if_not_4g_aligned(u64 val)
	{
		nếu (giá trị & GENMASK(31, 0))
			trả về -EINVAL;

trả về 0;
	}

Nó có thể được biên dịch thành ::

error_if_not_4g_aligned:
		CBNZ w0, .Lnot_aligned
		RET // bit [31:0] bằng 0, bit
					// [63:32] là UNKNOWN
	.Lnot_aligned:
		MOV x0, #-ZZ0004ZZ
		RET

Khi truyền 0x2_0000_0000 cho nó, giá trị trả về có thể được ghi là
  0x2_0000_0000 thay vì 0.

Bạn có thể đưa ra một số nhận xét về các chức năng cụ thể bằng cách sử dụng
trace_printk() Ví dụ: nếu bạn muốn đặt nhận xét bên trong
hàm __might_sleep(), bạn chỉ cần đưa vào
<linux/ftrace.h> và gọi trace_printk() bên trong __might_sleep()::

trace_printk("Tôi đang bình luận!\n")

sẽ sản xuất::

1) |             __might_sleep() {
   1) |                /* Tôi là một bình luận! */
   1) 1.449 chúng tôi |             }


Bạn có thể tìm thấy các tính năng hữu ích khác cho công cụ theo dõi này trong
theo dõi phần "ftrace động" chẳng hạn như chỉ theo dõi cụ thể
chức năng hoặc nhiệm vụ.

ftrace năng động
----------------

Nếu CONFIG_DYNAMIC_FTRACE được đặt, hệ thống sẽ chạy với
hầu như không có chi phí hoạt động khi tính năng theo dõi chức năng bị vô hiệu hóa. Con đường
công việc này là lệnh gọi hàm mcount (được đặt ở đầu
mọi hàm kernel, được tạo bởi khóa chuyển -pg trong gcc),
bắt đầu trỏ đến một sự trở lại đơn giản. (Bật FTRACE sẽ
bao gồm khóa chuyển -pg trong quá trình biên dịch kernel.)

Tại thời điểm biên dịch, mọi đối tượng tệp C đều được chạy qua
chương trình recordmcount (nằm trong thư mục scripts). Cái này
chương trình sẽ phân tích các tiêu đề ELF trong đối tượng C để tìm tất cả
các vị trí trong phần .text gọi mcount. Bắt đầu
với gcc phiên bản 4.6, -mfentry đã được thêm cho x86,
gọi "__fentry__" thay vì "mcount". Được gọi trước
việc tạo ra khung ngăn xếp.

Lưu ý, không phải tất cả các phần đều được theo dõi. Chúng có thể được ngăn chặn bằng một trong hai
một notrace hoặc bị chặn theo cách khác và tất cả các hàm nội tuyến đều không
truy tìm. Kiểm tra tệp "available_filter_functions" để xem những chức năng nào
có thể được theo dõi.

Một phần có tên "__mcount_loc" được tạo để chứa
tham chiếu đến tất cả các trang gọi mcount/fentry trong phần .text.
Chương trình recordmcount liên kết lại phần này vào
đối tượng ban đầu. Giai đoạn liên kết cuối cùng của kernel sẽ thêm tất cả những thứ này
tham chiếu vào một bảng duy nhất.

Khi khởi động, trước khi SMP được khởi tạo, mã ftrace động
quét bảng này và cập nhật tất cả các vị trí thành nops. Nó
cũng ghi lại các vị trí được thêm vào
danh sách available_filter_functions.  Các mô-đun được xử lý khi chúng
được tải và trước khi chúng được thực thi.  Khi một mô-đun được
chưa được tải, nó cũng loại bỏ các chức năng của nó khỏi hàm ftrace
danh sách. Điều này là tự động trong mã dỡ mô-đun và
tác giả module không cần phải lo lắng về điều đó.

Khi tính năng theo dõi được bật, quá trình sửa đổi chức năng
tracepoints phụ thuộc vào kiến trúc. Phương pháp cũ là sử dụng
kstop_machine để ngăn chặn các cuộc chạy đua với mã thực thi của CPU
đã được sửa đổi (có thể khiến CPU thực hiện những điều không mong muốn, đặc biệt là
nếu mã được sửa đổi vượt qua ranh giới bộ đệm (hoặc trang)) và các nops là
vá lại các cuộc gọi. Nhưng lần này họ không gọi mcount
(đó chỉ là một sơ khai chức năng). Bây giờ họ gọi vào ftrace
cơ sở hạ tầng.

Phương pháp mới để sửa đổi hàm tracepoint là đặt
điểm dừng tại vị trí cần sửa đổi, đồng bộ hóa tất cả CPU, sửa đổi
phần còn lại của lệnh không nằm trong điểm dừng. Đồng bộ hóa
tất cả các CPU một lần nữa, sau đó loại bỏ điểm dừng khi hoàn thành
phiên bản tới trang web cuộc gọi ftrace.

Một số vòm thậm chí không cần phải thực hiện đồng bộ hóa,
và chỉ có thể đặt mã mới lên trên mã cũ mà không cần bất kỳ
vấn đề với các CPU khác thực hiện nó cùng một lúc.

Một tác dụng phụ đặc biệt đối với việc ghi lại các chức năng đang được
theo dõi là bây giờ chúng ta có thể chọn lọc một cách có chọn lọc những chức năng mà chúng ta
muốn theo dõi và những gì chúng tôi muốn các lệnh gọi mcount duy trì
như không.

Hai tệp được sử dụng, một để bật và một để tắt
truy tìm các chức năng được chỉ định. Họ là:

set_ftrace_filter

Và

set_ftrace_notrace

Danh sách các chức năng có sẵn mà bạn có thể thêm vào các tệp này là
được liệt kê trong:

có sẵn_filter_functions

::

# cat có sẵn_filter_functions
  put_prev_task_idle
  kmem_cache_create
  pick_next_task_rt
  cpu_read_lock
  pick_next_task_fair
  mutex_lock
  […]

Nếu tôi chỉ quan tâm đến sys_nanosleep và hrtimer_interrupt::

# echo sys_nanosleep hrtimer_interrupt > set_ftrace_filter
  Hàm # echo > current_tracer
  # echo 1 > truy tìm_on
  # usleep 1
  # echo 0 > truy tìm_on
  Dấu vết # cat
  # tracer: chức năng
  #
  # entries-in-buffer/mục viết: 5/5 #P:4
  #
  #                              _-----=> không hoạt động
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
            usleep-2665 [001] .... 4186.475355: sys_nanosleep <-system_call_fastpath
            <nhàn rỗi>-0 [001] d.h1 4186.475409: hrtimer_interrupt <-smp_apic_timer_interrupt
            usleep-2665 [001] d.h1 4186.475426: hrtimer_interrupt <-smp_apic_timer_interrupt
            <nhàn rỗi>-0 [003] d.h1 4186.475426: hrtimer_interrupt <-smp_apic_timer_interrupt
            <nhàn rỗi>-0 [002] d.h1 4186.475427: hrtimer_interrupt <-smp_apic_timer_interrupt

Để xem chức năng nào đang được theo dõi, bạn có thể cat tệp:
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# cat set_ftrace_filter
  hrtimer_interrupt
  sys_nanongủ


Có lẽ điều này là không đủ. Các bộ lọc cũng cho phép kết hợp toàn cầu (7).

ZZ0000ZZ
	sẽ khớp với các hàm bắt đầu bằng <match>
  ZZ0001ZZ
	sẽ khớp với các hàm kết thúc bằng <match>
  ZZ0002ZZ
	sẽ khớp với các hàm có <match> trong đó
  ZZ0003ZZ
	sẽ khớp với các hàm bắt đầu bằng <match1> và kết thúc bằng <match2>

.. note::
      It is better to use quotes to enclose the wild cards,
      otherwise the shell may expand the parameters into names
      of files in the local directory.

::

# echo 'hrtimer_*' > set_ftrace_filter

Sản xuất::

# tracer: chức năng
  #
  # entries-in-buffer/mục viết: 897/897 #P:4
  #
  #                              _-----=> tắt irqs
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
            <nhàn rỗi>-0 [003] dN.1 4228.547803: hrtimer_cancel <-tick_nohz_idle_exit
            <nhàn rỗi>-0 [003] dN.1 4228.547804: hrtimer_try_to_cancel <-hrtimer_cancel
            <nhàn rỗi>-0 [003] dN.2 4228.547805: hrtimer_force_reprogram <-__remove_hrtimer
            <nhàn rỗi>-0 [003] dN.1 4228.547805: hrtimer_forward <-tick_nohz_idle_exit
            <nhàn rỗi>-0 [003] dN.1 4228.547805: hrtimer_start_range_ns <-hrtimer_start_expires.constprop.11
            <nhàn rỗi>-0 [003] d..1 4228.547858: hrtimer_get_next_event <-get_next_timer_interrupt
            <nhàn rỗi>-0 [003] d..1 4228.547859: hrtimer_start <-__tick_nohz_idle_enter
            <nhàn rỗi>-0 [003] d..2 4228.547860: hrtimer_force_reprogram <-__rem

Lưu ý rằng chúng tôi đã mất sys_nanosleep.
::::::::::::::::::::::::::::::::::::::::::

# cat set_ftrace_filter
  giờ_run_queues
  giờ_run_pending
  giờ_setup
  giờ_hủy
  hrtimer_try_to_cancel
  hrtimer_forward
  giờ_bắt đầu
  giờ_reprogram
  hrtimer_force_reprogram
  giờ_get_next_event
  hrtimer_interrupt
  hrtimer_nanosleep
  hrtimer_wakeup
  giờ_get_remaining
  giờ_get_res
  hrtimer_init_sleeper


Điều này là do '>' và '>>' hoạt động giống như trong bash.
Để viết lại các bộ lọc, hãy sử dụng '>'
Để thêm vào bộ lọc, hãy sử dụng '>>'

Để xóa bộ lọc để tất cả các chức năng sẽ được ghi lại
lần nữa::

# echo > set_ftrace_filter
 # cat set_ftrace_filter
 #

Một lần nữa, bây giờ chúng tôi muốn nối thêm.

::

# echo sys_nanosleep > set_ftrace_filter
  # cat set_ftrace_filter
  sys_nanongủ
  # echo 'hrtimer_*' >> set_ftrace_filter
  # cat set_ftrace_filter
  giờ_run_queues
  giờ_run_pending
  giờ_setup
  giờ_hủy
  hrtimer_try_to_cancel
  hrtimer_forward
  giờ_bắt đầu
  giờ_reprogram
  hrtimer_force_reprogram
  giờ_get_next_event
  hrtimer_interrupt
  sys_nanongủ
  hrtimer_nanosleep
  hrtimer_wakeup
  giờ_get_remaining
  giờ_get_res
  hrtimer_init_sleeper


set_ftrace_notrace ngăn chặn các chức năng đó
truy tìm.
:::::::::

# echo 'ZZ0000ZZ' 'ZZ0001ZZ' > set_ftrace_notrace

Sản xuất::

# tracer: chức năng
  #
  # entries-in-buffer/mục viết: 39608/39608 #P:4
  #
  #                              _-----=> tắt irqs
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
              bash-1994 [000] .... 4342.324896: file_ra_state_init <-do_dentry_open
              bash-1994 [000] .... 4342.324897: open_check_o_direct <-do_last
              bash-1994 [000] .... 4342.324897: ima_file_check <-do_last
              bash-1994 [000] .... 4342.324898: process_measurement <-ima_file_check
              bash-1994 [000] .... 4342.324898: ima_get_action <-process_measurement
              bash-1994 [000] .... 4342.324898: ima_match_policy <-ima_get_action
              bash-1994 [000] .... 4342.324899: do_truncate <-do_last
              bash-1994 [000] .... 4342.324899: setattr_ Should_drop_suidgid <-do_truncate
              bash-1994 [000] .... 4342.324899: notification_change <-do_truncate
              bash-1994 [000] .... 4342.324900: current_fs_time <-notify_change
              bash-1994 [000] .... 4342.324900: current_kernel_time <-current_fs_time
              bash-1994 [000] .... 4342.324900: timespec_trunc <-current_fs_time

Chúng ta có thể thấy rằng không còn việc truy tìm khóa hoặc truy tìm trước nữa.

Chọn bộ lọc chức năng thông qua chỉ mục
---------------------------------------

Bởi vì việc xử lý chuỗi rất tốn kém (địa chỉ của hàm
cần tra cứu trước khi so sánh với chuỗi được truyền vào),
một chỉ mục cũng có thể được sử dụng để kích hoạt các chức năng. Điều này hữu ích trong
trường hợp thiết lập hàng ngàn chức năng cụ thể cùng một lúc. Bằng cách vượt qua
trong một danh sách các số, sẽ không có quá trình xử lý chuỗi nào xảy ra. Thay vào đó, hàm
tại vị trí cụ thể trong mảng bên trong (tương ứng với
các hàm trong tệp "available_filter_functions") được chọn.

::

# echo 1 > set_ftrace_filter

Sẽ chọn chức năng đầu tiên được liệt kê trong "available_filter_functions"

::

# head -1 có sẵn_filter_functions
  trace_initcall_finish_cb

# cat set_ftrace_filter
  trace_initcall_finish_cb

# head -50 chức năng_filter_filter có sẵn | đuôi -1
  x86_pmu_commit_txn

# echo 1 50 > set_ftrace_filter
  # cat set_ftrace_filter
  trace_initcall_finish_cb
  x86_pmu_commit_txn

FTrace động với công cụ theo dõi đồ thị hàm số
----------------------------------------------

Mặc dù những gì đã được giải thích ở trên liên quan đến cả
công cụ theo dõi hàm và công cụ theo dõi đồ thị hàm số, có một số
các tính năng đặc biệt chỉ có trong công cụ theo dõi đồ thị hàm số.

Nếu bạn chỉ muốn theo dõi một hàm và tất cả các hàm con của nó,
bạn chỉ cần lặp lại tên của nó vào set_graph_function::

echo __do_fault > set_graph_function

sẽ tạo ra dấu vết "mở rộng" sau đây của __do_fault()
chức năng::

0) |  __do_fault() {
   0) |    tập tin_fault() {
   0) |      find_lock_page() {
   0) 0,804 chúng tôi |        find_get_page();
   0) |        __might_sleep() {
   0) 1.329 chúng tôi |        }
   0) 3.904 chúng tôi |      }
   0) 4.979 chúng tôi |    }
   0) 0,653 chúng tôi |    _spin_lock();
   0) 0,578 chúng tôi |    page_add_file_rmap();
   0) 0,525 chúng tôi |    bản địa_set_pte_at();
   0) 0,585 chúng tôi |    _spin_unlock();
   0) |    unlock_page() {
   0) 0,541 chúng tôi |      page_waitqueue();
   0) 0,639 chúng tôi |      __wake_up_bit();
   0) 2.786 chúng tôi |    }
   0) + 14.237 chúng tôi |  }
   0) |  __do_fault() {
   0) |    tập tin_fault() {
   0) |      find_lock_page() {
   0) 0,698 chúng tôi |        find_get_page();
   0) |        __might_sleep() {
   0) 1.412 chúng tôi |        }
   0) 3.950 chúng tôi |      }
   0) 5.098 chúng tôi |    }
   0) 0,631 chúng tôi |    _spin_lock();
   0) 0,571 chúng tôi |    page_add_file_rmap();
   0) 0,526 chúng tôi |    bản địa_set_pte_at();
   0) 0,586 chúng tôi |    _spin_unlock();
   0) |    unlock_page() {
   0) 0,533 chúng tôi |      page_waitqueue();
   0) 0,638 chúng tôi |      __wake_up_bit();
   0) 2.793 chúng tôi |    }
   0) + 14.012 chúng tôi |  }

Bạn cũng có thể mở rộng một số chức năng cùng một lúc::

echo sys_open > set_graph_function
 echo sys_close >> set_graph_function

Bây giờ nếu bạn muốn quay lại để theo dõi tất cả các chức năng, bạn có thể xóa
bộ lọc đặc biệt này thông qua::

echo > set_graph_function


ftrace_enabled
--------------

Lưu ý, proc sysctl ftrace_enable là một công tắc bật/tắt lớn cho
người theo dõi chức năng Theo mặc định, nó được bật (khi tính năng dò tìm chức năng được bật
được kích hoạt trong kernel). Nếu nó bị vô hiệu hóa, tất cả việc dò tìm chức năng sẽ bị
bị vô hiệu hóa. Điều này không chỉ bao gồm các công cụ theo dõi chức năng cho ftrace mà còn bao gồm
cũng cho bất kỳ mục đích sử dụng nào khác (perf, kprobes, theo dõi ngăn xếp, lập hồ sơ, v.v.). Nó
không thể tắt nếu có lệnh gọi lại với bộ FTRACE_OPS_FL_PERMANENT
đã đăng ký.

Hãy vô hiệu hóa điều này một cách cẩn thận.

Điều này có thể được vô hiệu hóa (và kích hoạt) với::

sysctl kernel.ftrace_enabled=0
  sysctl kernel.ftrace_enabled=1

hoặc

echo 0 > /proc/sys/kernel/ftrace_enabled
  echo 1 > /proc/sys/kernel/ftrace_enabled


Lệnh lọc
---------------

Một số lệnh được hỗ trợ bởi giao diện set_ftrace_filter.
Lệnh theo dõi có định dạng sau::

<chức năng>:<lệnh>:<tham số>

Các lệnh sau được hỗ trợ:

- chế độ:
  Lệnh này cho phép lọc chức năng trên mỗi mô-đun. các
  tham số xác định mô-đun. Ví dụ: nếu chỉ viết*
  mong muốn các chức năng trong mô-đun ext3, hãy chạy:

echo 'write*:mod:ext3' > set_ftrace_filter

Lệnh này tương tác với bộ lọc theo cách tương tự như
  lọc dựa trên tên hàm. Vì vậy, việc bổ sung thêm nhiều chức năng
  trong một mô-đun khác được thực hiện bằng cách thêm (>>) vào
  tập tin lọc. Xóa các chức năng mô-đun cụ thể bằng cách thêm vào trước
  '!'::

echo '!writeback*:mod:ext3' >> set_ftrace_filter

Lệnh Mod hỗ trợ mô-đun toàn cầu hóa. Tắt tính năng theo dõi cho tất cả
  chức năng ngoại trừ một mô-đun cụ thể::

echo '!*:mod:!ext3' >> set_ftrace_filter

Tắt tính năng theo dõi cho tất cả các mô-đun nhưng vẫn theo dõi kernel::

echo '!ZZ0000ZZ' >> set_ftrace_filter

Chỉ bật bộ lọc cho kernel::

echo 'ZZ0000ZZ:mod:!*' >> set_ftrace_filter

Bật bộ lọc cho mô-đun toàn cầu::

echo 'ZZ0000ZZ:mod:ZZ0001ZZ' >> set_ftrace_filter

- dấu vết/dấu vết:
  Các lệnh này bật và tắt theo dõi khi được chỉ định
  chức năng được nhấn. Tham số xác định số lần
  hệ thống truy tìm được bật và tắt. Nếu không xác định thì có
  không có giới hạn. Ví dụ: để tắt tính năng theo dõi khi có lỗi lịch trình
  bị đánh 5 lần đầu tiên, chạy ::

echo '__schedule_bug:traceoff:5' > set_ftrace_filter

Để luôn tắt tính năng theo dõi khi gặp __schedule_bug::

echo '__schedule_bug:traceoff' > set_ftrace_filter

Các lệnh này được tích lũy cho dù chúng có được thêm vào hay không
  tới set_ftrace_filter. Để xóa một lệnh, hãy thêm nó vào trước '!'
  và thả tham số::

echo '!__schedule_bug:traceoff:0' > set_ftrace_filter

Ở trên loại bỏ lệnh theo dõi cho __schedule_bug
  có một bộ đếm. Để xóa các lệnh không có bộ đếm::

echo '!__schedule_bug:traceoff' > set_ftrace_filter

- ảnh chụp nhanh:
  Sẽ khiến ảnh chụp nhanh được kích hoạt khi chức năng được nhấn.
  ::

echo 'native_flush_tlb_others:snapshot' > set_ftrace_filter

Để chỉ chụp nhanh một lần:
  ::

echo 'native_flush_tlb_others:snapshot:1' > set_ftrace_filter

Để loại bỏ các lệnh trên::

echo '!native_flush_tlb_others:snapshot' > set_ftrace_filter
   echo '!native_flush_tlb_others:snapshot:0' > set_ftrace_filter

- Enable_event/disable_event:
  Các lệnh này có thể kích hoạt hoặc vô hiệu hóa một sự kiện theo dõi. Lưu ý, vì
  lệnh gọi lại theo dõi hàm rất nhạy cảm, khi các lệnh này
  được đăng ký, điểm theo dõi được kích hoạt nhưng bị vô hiệu hóa trong
  chế độ "mềm". Nghĩa là, tracepoint sẽ được gọi, nhưng
  sẽ không bị truy tìm. Điểm theo dõi sự kiện vẫn ở chế độ này
  miễn là có lệnh kích hoạt nó.
  ::

echo 'try_to_wake_up:enable_event:sched:sched_switch:2' > \
   	 set_ftrace_filter

Định dạng là::

<function>:enable_event:<system>:<event>[:count]
    <function>:disable_event:<system>:<event>[:count]

Để xóa các lệnh sự kiện::

echo '!try_to_wake_up:enable_event:sched:sched_switch:0' > \
   	 set_ftrace_filter
   echo '!schedule:disable_event:sched:sched_switch' > \
   	 set_ftrace_filter

- đổ:
  Khi chức năng được nhấn, nó sẽ kết xuất nội dung của ftrace
  vòng đệm vào bàn điều khiển. Điều này rất hữu ích nếu bạn cần gỡ lỗi
  một cái gì đó và muốn xóa dấu vết khi một chức năng nhất định
  bị đánh. Có lẽ đó là một hàm được gọi trước bộ ba
  lỗi xảy ra và không cho phép bạn nhận kết xuất thông thường.

- cpudump:
  Khi chức năng được nhấn, nó sẽ kết xuất nội dung của ftrace
  bộ đệm vòng cho CPU hiện tại vào bảng điều khiển. Không giống như "bãi rác"
  lệnh, nó chỉ in ra nội dung của bộ đệm vòng cho
  CPU đã thực thi chức năng kích hoạt kết xuất.

- dấu vết ngăn xếp:
  Khi nhấn chức năng, dấu vết ngăn xếp sẽ được ghi lại.

dấu vết_pipe
------------

trace_pipe xuất ra nội dung giống như tệp theo dõi, nhưng
hiệu ứng trên dấu vết là khác nhau. Mỗi lần đọc từ
trace_pipe được tiêu thụ. Điều này có nghĩa là những lần đọc tiếp theo sẽ được
khác nhau. Dấu vết đang hoạt động.
::::::::::::::::::::::::::::::::::

Hàm # echo > current_tracer
  # cat trace_pipe > /tmp/trace.out &
  [1] 4153
  # echo 1 > truy tìm_on
  # usleep 1
  # echo 0 > truy tìm_on
  Dấu vết # cat
  # tracer: chức năng
  #
  # entries-in-buffer/mục viết: 0/0 #P:4
  #
  #                              _-----=> không hoạt động
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |

#
  # cat /tmp/trace.out
             bash-1994 [000] .... 5281.568961: mutex_unlock <-rb_simple_write
             bash-1994 [000] .... 5281.568963: __mutex_unlock_slowpath <-mutex_unlock
             bash-1994 [000] .... 5281.568963: __fsnotify_parent <-fsnotify_modify
             bash-1994 [000] .... 5281.568964: fsnotify <-fsnotify_modify
             bash-1994 [000] .... 5281.568964: __srcu_read_lock <-fsnotify
             bash-1994 [000] .... 5281.568964: add_preempt_count <-__srcu_read_lock
             bash-1994 [000] ...1 5281.568965: sub_preempt_count <-__srcu_read_lock
             bash-1994 [000] .... 5281.568965: __srcu_read_unlock <-fsnotify
             bash-1994 [000] .... 5281.568967: sys_dup2 <-system_call_fastpath


Lưu ý, việc đọc tệp trace_pipe sẽ bị chặn cho đến khi có thêm đầu vào
đã thêm vào. Điều này trái với tập tin theo dõi. Nếu bất kỳ quá trình nào được mở
tệp theo dõi để đọc, nó thực sự sẽ vô hiệu hóa việc theo dõi và
ngăn không cho các mục mới được thêm vào. Tệp trace_pipe thực hiện
không có hạn chế này.

mục theo dõi
-------------

Có quá nhiều hoặc không đủ dữ liệu có thể gây rắc rối trong
chẩn đoán một vấn đề trong kernel. Tệp buffer_size_kb là
được sử dụng để sửa đổi kích thước của bộ đệm theo dõi bên trong. các
số được liệt kê là số lượng mục có thể được ghi lại mỗi
CPU. Để biết kích thước đầy đủ, hãy nhân số lượng CPU có thể
với số lượng bài viết.
::::::::::::::::::::::

Bộ đệm # cat_size_kb
  1408 (đơn vị kilobyte)

Hoặc đơn giản là đọc buffer_total_size_kb
:::::::::::::::::::::::::::::::::::::::::

Bộ đệm # cat_total_size_kb 
  5632

Để sửa đổi bộ đệm, hãy lặp lại đơn giản một số (trong các phân đoạn 1024 byte).
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# echo 10000 > đệm_size_kb
  # cat đệm_size_kb
  10000 (đơn vị kilobyte)

Nó sẽ cố gắng phân bổ càng nhiều càng tốt. Nếu bạn phân bổ quá
nhiều, nó có thể gây ra tình trạng hết bộ nhớ.
::::::::::::::::::::::::::::::::::::::::::::::

# echo 1000000000000 > đệm_size_kb
  -bash: echo: lỗi ghi: Không thể cấp phát bộ nhớ
  # cat đệm_size_kb
  85

Bộ đệm per_cpu cũng có thể được thay đổi riêng lẻ:
::::::::::::::::::::::::::::::::::::::::::::::::::

# echo 10000 > per_cpu/cpu0/buffer_size_kb
  # echo 100 > per_cpu/cpu1/buffer_size_kb

Khi bộ đệm per_cpu không giống nhau, buffer_size_kb
ở cấp cao nhất sẽ chỉ hiển thị X
::::::::::::::::::::::::::::::::

Bộ đệm # cat_size_kb
  X

Đây là lúc buffer_total_size_kb hữu ích:
::::::::::::::::::::::::::::::::::::::::

Bộ đệm # cat_total_size_kb 
  12916

Việc ghi vào buffer_size_kb cấp cao nhất sẽ thiết lập lại tất cả các bộ đệm
lại như cũ.

Ảnh chụp nhanh
--------------
CONFIG_TRACER_SNAPSHOT tạo tính năng chụp nhanh chung
có sẵn cho tất cả các công cụ theo dõi không có độ trễ. (Bộ theo dõi độ trễ
ghi lại độ trễ tối đa, chẳng hạn như "irqsoff" hoặc "wakeup", không thể sử dụng
tính năng này, vì những tính năng này đã sử dụng ảnh chụp nhanh
cơ chế nội bộ.)

Ảnh chụp nhanh bảo tồn bộ đệm theo dõi hiện tại tại một điểm cụ thể
kịp thời mà không ngừng truy tìm. Ftrace hoán đổi hiện tại
bộ đệm bằng bộ đệm dự phòng và việc truy tìm tiếp tục trong bộ đệm mới
bộ đệm hiện tại (= dự phòng trước đó).

Các tệp tracefs sau đây trong "tracing" có liên quan đến điều này
tính năng:

ảnh chụp nhanh:

Điều này được sử dụng để chụp ảnh nhanh và đọc kết quả đầu ra
	của ảnh chụp nhanh. Echo 1 vào tập tin này để phân bổ một
	đệm dự phòng và để chụp ảnh nhanh (trao đổi), sau đó đọc
	ảnh chụp nhanh từ tệp này có cùng định dạng với
	"dấu vết" (được mô tả ở trên trong phần "Tệp
	Hệ thống"). Cả ảnh chụp nhanh và theo dõi đều có thể thực thi được
	song song. Khi bộ đệm dự phòng được phân bổ, tiếng vang
	0 giải phóng nó và lặp lại các giá trị khác (dương) sẽ xóa
	nội dung ảnh chụp nhanh.
	Thông tin chi tiết hơn được hiển thị trong bảng dưới đây.

+--------------+-------------+-------------+-------------+
	ZZ0000ZZ 0 ZZ0001ZZ khác |
	+==============================================================================================================================
	ZZ0002ZZ(không làm gì)ZZ0003ZZ(không làm gì)|
	+--------------+-------------+-------------+-------------+
	ZZ0004ZZ miễn phí ZZ0005ZZ rõ ràng |
	+--------------+-------------+-------------+-------------+

Đây là một ví dụ về việc sử dụng tính năng chụp nhanh.
::::::::::::::::::::::::::::::::::::::::::::::::::::::

# echo 1 > sự kiện/lịch trình/bật
  # echo 1 > ảnh chụp nhanh
  Ảnh chụp nhanh # cat
  # tracer: không
  #
  # entries-in-buffer/mục viết: 71/71 #P:8
  #
  #                              _-----=> không hoạt động
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
            <idle>-0 [005] d... 2440.603828: sched_switch: prev_comm=swapper/5 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=snapshot-test-2 next_pid=2242 next_prio=120
             sleep-2242 [005] d... 2440.603846: sched_switch: prev_comm=snapshot-test-2 prev_pid=2242 prev_prio=120 prev_state=R ==> next_comm=kworker/5:1 next_pid=60 next_prio=120
  […]
          <nhàn rỗi>-0 [002] d... 2440.707230: sched_switch: prev_comm=swapper/2 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=snapshot-test-2 next_pid=2229 next_prio=120

Dấu vết # cat  
  # tracer: không
  #
  # entries-in-buffer/mục viết: 77/77 #P:8
  #
  #                              _-----=> tắt irqs
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
            <idle>-0 [007] d... 2440.707395: sched_switch: prev_comm=swapper/7 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=snapshot-test-2 next_pid=2243 next_prio=120
   snapshot-test-2-2229 [002] d... 2440.707438: sched_switch: prev_comm=snapshot-test-2 prev_pid=2229 prev_prio=120 prev_state=S ==> next_comm=swapper/2 next_pid=0 next_prio=120
  […]


Nếu bạn cố gắng sử dụng tính năng chụp nhanh này khi bộ theo dõi hiện tại đang hoạt động.
một trong những công cụ theo dõi độ trễ, bạn sẽ nhận được kết quả sau.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Đánh thức # echo > current_tracer
  # echo 1 > ảnh chụp nhanh
  bash: echo: lỗi ghi: Thiết bị hoặc tài nguyên đang bận
  Ảnh chụp nhanh # cat
  cat: ảnh chụp nhanh: Thiết bị hoặc tài nguyên đang bận


trường hợp
----------
Trong thư mục theo dõi tracefs có một thư mục tên là "instances".
Thư mục này có thể có các thư mục mới được tạo bên trong nó bằng cách sử dụng
mkdir và xóa thư mục bằng rmdir. Thư mục đã được tạo
với mkdir trong thư mục này sẽ chứa các tệp và các tệp khác
thư mục sau khi được tạo.
:::::::::::::::::::::::::

Phiên bản # mkdir/foo
  Phiên bản # ls/foo
  sự kiện buffer_size_kb buffer_total_size_kb free_buffer mỗi_cpu
  set_event ảnh chụp nhanh dấu vết trace_clock trace_marker trace_options
  trace_pipe tracing_on

Như bạn có thể thấy, thư mục mới trông giống như thư mục theo dõi
chính nó. Trên thực tế, nó rất giống nhau, ngoại trừ bộ đệm và
các sự kiện là bất khả tri từ thư mục chính hoặc từ bất kỳ sự kiện nào khác
các trường hợp được tạo ra.

Các tập tin trong thư mục mới hoạt động giống như các tập tin có
cùng tên trong thư mục theo dõi ngoại trừ bộ đệm được sử dụng
là một bộ đệm riêng biệt và mới. Các tập tin ảnh hưởng đến bộ đệm đó nhưng không
ảnh hưởng đến bộ đệm chính ngoại trừ trace_options. Hiện tại,
trace_options ảnh hưởng đến tất cả các phiên bản và bộ đệm cấp cao nhất
giống nhau, nhưng điều này có thể thay đổi trong các phiên bản tương lai. Nghĩa là, các tùy chọn
có thể trở nên cụ thể đối với trường hợp họ cư trú.

Lưu ý rằng không có tệp theo dõi chức năng nào ở đó, cũng như không có
current_tracer và available_tracers. Điều này là do bộ đệm
hiện chỉ có thể kích hoạt sự kiện cho họ.
:::::::::::::::::::::::::::::::::::::::::

Phiên bản # mkdir/foo
  Phiên bản/thanh # mkdir
  Phiên bản/zoot # mkdir
  # echo 100000 > đệm_size_kb
  # echo 1000 > instance/foo/buffer_size_kb
  # echo 5000 > phiên bản/bar/per_cpu/cpu1/buffer_size_kb
  Hàm # echo > current_trace
  # echo 1 > instance/foo/events/sched/sched_wakeup/enable
  # echo 1 > instance/foo/events/sched/sched_wakeup_new/enable
  # echo 1 > phiên bản/foo/sự kiện/lịch trình/sched_switch/bật
  # echo 1 > phiên bản/thanh/sự kiện/irq/bật
  # echo 1 > phiên bản/zoot/sự kiện/tòa nhà/bật
  # cat trace_pipe
  CPU:2 [LOST 11745 EVENTS]
              bash-2044 [002] .... 10594.481032: _raw_spin_lock_irqsave <-get_page_from_freelist
              bash-2044 [002] d... 10594.481032: add_preempt_count <-_raw_spin_lock_irqsave
              bash-2044 [002] d..1 10594.481032: __rmqueue <-get_page_from_freelist
              bash-2044 [002] d..1 10594.481033: _raw_spin_unlock <-get_page_from_freelist
              bash-2044 [002] d..1 10594.481033: sub_preempt_count <-_raw_spin_unlock
              bash-2044 [002] d... 10594.481033: get_pageblock_flags_group <-get_pageblock_migratetype
              bash-2044 [002] d... 10594.481034: __mod_zone_page_state <-get_page_from_freelist
              bash-2044 [002] d... 10594.481034: Zone_statistics <-get_page_from_freelist
              bash-2044 [002] d... 10594.481034: __inc_zone_state <-zone_statistics
              bash-2044 [002] d... 10594.481034: __inc_zone_state <-zone_statistics
              bash-2044 [002] .... 10594.481035: Arch_dup_task_struct <-copy_process
  […]

Phiên bản # cat/foo/trace_pipe
              bash-1998 [000] d..4 136.676759: sched_wakeup: comm=kworker/0:1 pid=59 prio=120 thành công=1 target_cpu=000
              bash-1998 [000] dN.4 136.676760: sched_wakeup: comm=bash pid=1998 prio=120 thành công=1 target_cpu=000
            <nhàn rỗi>-0 [003] d.h3 136.676906: sched_wakeup: comm=rcu_preempt pid=9 prio=120 thành công=1 target_cpu=003
            <nhàn rỗi>-0 [003] d..3 136.676909: sched_switch: prev_comm=swapper/3 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=rcu_preempt next_pid=9 next_prio=120
       rcu_preempt-9 [003] d..3 136.676916: sched_switch: prev_comm=rcu_preempt prev_pid=9 prev_prio=120 prev_state=S ==> next_comm=swapper/3 next_pid=0 next_prio=120
              bash-1998 [000] d..4 136.677014: sched_wakeup: comm=kworker/0:1 pid=59 prio=120 thành công=1 target_cpu=000
              bash-1998 [000] dN.4 136.677016: sched_wakeup: comm=bash pid=1998 prio=120 thành công=1 target_cpu=000
              bash-1998 [000] d..3 136.677018: sched_switch: prev_comm=bash prev_pid=1998 prev_prio=120 prev_state=R+ ==> next_comm=kworker/0:1 next_pid=59 next_prio=120
       kworker/0:1-59 [000] d..4 136.677022: sched_wakeup: comm=sshd pid=1995 prio=120 thành công=1 target_cpu=001
       kworker/0:1-59 [000] d..3 136.677025: sched_switch: prev_comm=kworker/0:1 prev_pid=59 prev_prio=120 prev_state=S ==> next_comm=bash next_pid=1998 next_prio=120
  […]

Phiên bản/bar/trace_pipe # cat
       di chuyển/1-14 [001] d.h3 138.732674: softirq_raise: vec=3 [action=NET_RX]
            <nhàn rỗi>-0 [001] dNh3 138.732725: softirq_raise: vec=3 [action=NET_RX]
              bash-1998 [000] d.h1 138.733101: softirq_raise: vec=1 [action=TIMER]
              bash-1998 [000] d.h1 138.733102: softirq_raise: vec=9 [action=RCU]
              bash-1998 [000] ..s2 138.733105: softirq_entry: vec=1 [action=TIMER]
              bash-1998 [000] ..s2 138.733106: softirq_exit: vec=1 [action=TIMER]
              bash-1998 [000] ..s2 138.733106: softirq_entry: vec=9 [action=RCU]
              bash-1998 [000] ..s2 138.733109: softirq_exit: vec=9 [action=RCU]
              sshd-1995 [001] d.h1 138.733278: irq_handler_entry: irq=21 name=uhci_hcd:usb4
              sshd-1995 [001] d.h1 138.733280: irq_handler_exit: irq=21 ret=unhandled
              sshd-1995 [001] d.h1 138.733281: irq_handler_entry: irq=21 name=eth0
              sshd-1995 [001] d.h1 138.733283: irq_handler_exit: irq=21 ret=handled
  […]

Phiên bản/zoot/dấu vết # cat
  # tracer: không
  #
  # entries-in-buffer/mục viết: 18996/18996 #P:4
  #
  #                              _-----=> tắt irqs
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
              bash-1998 [000] d... 140.733501: sys_write -> 0x2
              bash-1998 [000] d... 140.733504: sys_dup2(oldfd: a, newfd: 1)
              bash-1998 [000] d... 140.733506: sys_dup2 -> 0x1
              bash-1998 [000] d... 140.733508: sys_fcntl(fd: a, cmd: 1, arg: 0)
              bash-1998 [000] d... 140.733509: sys_fcntl -> 0x1
              bash-1998 [000] d... 140.733510: sys_close(fd: a)
              bash-1998 [000] d... 140.733510: sys_close -> 0x0
              bash-1998 [000] d... 140.733514: sys_rt_sigprocmask(how: 0, nset: 0, oset: 6e2768, sigsetsize: 8)
              bash-1998 [000] d... 140.733515: sys_rt_sigprocmask -> 0x0
              bash-1998 [000] d... 140.733516: sys_rt_sigaction(sig: 2, act: 7fff718846f0, oact: 7fff71884650, sigsetsize: 8)
              bash-1998 [000] d... 140.733516: sys_rt_sigaction -> 0x0

Bạn có thể thấy rằng dấu vết của bộ đệm dấu vết trên cùng chỉ hiển thị
việc truy tìm chức năng. Ví dụ foo hiển thị các lần đánh thức và tác vụ
công tắc.

Để xóa các phiên bản, chỉ cần xóa thư mục của chúng:
::::::::::::::::::::::::::::::::::::::::::::::::::::

Phiên bản # rmdir/foo
  Phiên bản/thanh # rmdir
  Phiên bản/zoot # rmdir

Lưu ý, nếu một quy trình có tệp theo dõi được mở trong một trong các phiên bản
thư mục, rmdir sẽ thất bại với EBUSY.


Dấu vết ngăn xếp
----------------
Vì hạt nhân có một ngăn xếp có kích thước cố định nên điều quan trọng là không
lãng phí nó trong các chức năng. Một nhà phát triển hạt nhân phải có ý thức về
những gì họ phân bổ trên ngăn xếp. Nếu họ thêm quá nhiều, hệ thống
có thể có nguy cơ tràn ngăn xếp và xảy ra hỏng hóc,
thường dẫn đến sự hoảng loạn của hệ thống.

Có một số công cụ kiểm tra điều này, thường có ngắt
định kỳ kiểm tra việc sử dụng. Nhưng nếu bạn có thể thực hiện kiểm tra
tại mọi cuộc gọi chức năng sẽ trở nên rất hữu ích. Như ftrace cung cấp
một công cụ theo dõi hàm, giúp việc kiểm tra kích thước ngăn xếp trở nên thuận tiện
tại mọi cuộc gọi chức năng. Điều này được kích hoạt thông qua trình theo dõi ngăn xếp.

CONFIG_STACK_TRACER kích hoạt chức năng theo dõi ngăn xếp ftrace.
Để kích hoạt nó, hãy viết số '1' vào /proc/sys/kernel/stack_tracer_enabled.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# echo 1 > /proc/sys/kernel/stack_tracer_enabled

Bạn cũng có thể kích hoạt nó từ dòng lệnh kernel để theo dõi
kích thước ngăn xếp của kernel trong khi khởi động, bằng cách thêm "stacktrace"
đến tham số dòng lệnh kernel.

Sau khi chạy nó được vài phút, kết quả trông như sau:
:::::::::::::::::::::::::::::::::::::::::::::::::::::

# cat stack_max_size
  2928

# cat stack_trace
          Vị trí kích thước độ sâu (18 mục)
          ----- ---- --------
    0) 2928 224 cập nhật_sd_lb_stats+0xbc/0x4ac
    1) 2704 160 find_busiest_group+0x31/0x1f1
    2) 2544 256 tải_cân bằng+0xd9/0x662
    3) 2288 80 nhàn rỗi_balance+0xbb/0x130
    4) 2208 128 __ lịch+0x26e/0x5b9
    5) Lịch trình 2080 16+0x64/0x66
    6) 2064 128 lịch_timeout+0x34/0xe0
    7) 1936 112 wait_for_common+0x97/0xf1
    8) 1824 16 wait_for_completion+0x1d/0x1f
    9) 1808 128 tuôn ra_work+0xfe/0x119
   10) 1680 16 tty_flush_to_ldisc+0x1e/0x20
   11) 1664 48 input_available_p+0x1d/0x5c
   12) 1616 48 n_tty_poll+0x6d/0x134
   13) 1568 64 tty_poll+0x64/0x7f
   14) 1504 880 do_select+0x31e/0x511
   15) 624 400 core_sys_select+0x177/0x216
   16) 224 96 sys_select+0x91/0xb9
   17) 128 128 system_call_fastpath+0x16/0x1b

Lưu ý, nếu -mfentry đang được gcc sử dụng, các hàm sẽ được truy tìm trước
họ thiết lập khung ngăn xếp. Điều này có nghĩa là chức năng cấp độ lá
không được kiểm tra bởi trình theo dõi ngăn xếp khi sử dụng -mfentry.

Hiện tại, -mfentry chỉ được sử dụng bởi gcc 4.6.0 trở lên trên x86.

Hơn
----
Thông tin chi tiết có thể được tìm thấy trong mã nguồn, trong các tệp ZZ0000ZZ.
