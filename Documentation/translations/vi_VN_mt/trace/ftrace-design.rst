.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/ftrace-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Thiết kế theo dõi chức năng
======================

:Tác giả: Mike Frysinger

.. caution::
	This document is out of date. Some of the description below doesn't
	match current implementation now.

Giới thiệu
------------

Ở đây chúng ta sẽ đề cập đến các phần kiến trúc mà chức năng truy vết chung
mã dựa vào để hoạt động đúng.  Mọi thứ được chia thành tăng dần
phức tạp để bạn có thể bắt đầu đơn giản và ít nhất có được chức năng cơ bản.

Lưu ý rằng điều này chỉ tập trung vào chi tiết triển khai kiến ​​trúc.  Nếu bạn
muốn giải thích thêm về một tính năng theo mã chung, hãy xem lại mã chung
tập tin ftrace.txt.

Lý tưởng nhất là tất cả những ai muốn duy trì hiệu suất trong khi hỗ trợ theo dõi trong
hạt nhân của họ sẽ chuyển sang hỗ trợ ftrace động.


Điều kiện tiên quyết
-------------

Ftrace dựa vào các tính năng này đang được triển khai:
  - STACKTRACE_SUPPORT - triển khai save_stack_trace()
  - TRACE_IRQFLAGS_SUPPORT - triển khai include/asm/irqflags.h


HAVE_FUNCTION_TRACER
--------------------

Bạn sẽ cần triển khai các hàm mcount và ftrace_stub.

Tên biểu tượng mcount chính xác sẽ phụ thuộc vào chuỗi công cụ của bạn.  Một số người gọi nó
"mcount", "_mcount" hoặc thậm chí "__mcount".  Bạn có thể có thể tìm ra nó bằng cách
chạy một cái gì đó như ::

$ echo 'main(){}' ZZ0000ZZ grep mcount
	        gọi số lượng

Dưới đây chúng ta sẽ giả định rằng ký hiệu là "mcount" chỉ để giữ mọi thứ
đẹp và đơn giản trong các ví dụ.

Hãy nhớ rằng ABI có hiệu lực bên trong hàm mcount là
Kiến trúc/chuỗi công cụ cụ thể của ZZ0000ZZ.  Chúng tôi không thể giúp bạn về vấn đề này,
xin lỗi.  Tìm lại một số tài liệu cũ và/hoặc tìm ai đó quen thuộc hơn
bạn có thể loại bỏ các ý tưởng.  Thông thường, đăng ký cách sử dụng (đối số/cào/v.v ...)
là một vấn đề lớn vào thời điểm này, đặc biệt là liên quan đến vị trí của
lệnh gọi mcount (mở đầu hàm trước/sau).  Bạn cũng có thể muốn xem xét
glibc đã triển khai hàm mcount cho kiến trúc của bạn như thế nào.  Nó có thể
có liên quan (bán).

Hàm mcount nên kiểm tra con trỏ hàm ftrace_trace_function
để xem liệu nó có được đặt thành ftrace_stub không.  Nếu vậy thì bạn chẳng có việc gì phải làm cả,
vậy hãy quay lại ngay.  Nếu không thì gọi hàm đó theo cách tương tự
hàm mcount thường gọi __mcount_internal -- đối số đầu tiên là
"frompc" trong khi đối số thứ hai là "selfpc" (được điều chỉnh để loại bỏ
kích thước của lệnh gọi mcount được nhúng trong hàm).

Ví dụ, nếu hàm foo() gọi bar(), khi hàm bar() gọi
mcount(), các đối số mcount() sẽ chuyển tới bộ theo dõi là:

- "frompc" - thanh địa chỉ() sẽ sử dụng để quay lại foo()
  - "selfpc" - thanh địa chỉ() (có điều chỉnh kích thước mcount())

Ngoài ra, hãy nhớ rằng hàm mcount này sẽ được gọi là ZZ0000ZZ, vì vậy
tối ưu hóa cho trường hợp mặc định không có dấu vết sẽ giúp hoạt động trơn tru của
hệ thống của bạn khi việc theo dõi bị vô hiệu hóa.  Vì vậy, sự bắt đầu của hàm mcount là
thường là mức tối thiểu để kiểm tra mọi thứ trước khi quay lại.  Điều đó cũng
có nghĩa là luồng mã thường phải được giữ tuyến tính (tức là không phân nhánh trong nop
trường hợp).  Tất nhiên đây là một sự tối ưu hóa và không phải là một yêu cầu khó khăn.

Đây là một số mã giả có thể giúp ích (các hàm này thực sự phải được
được thực hiện trong hội)::

void ftrace_stub(void)
	{
		trở lại;
	}

void mcount(void)
	{
		/* lưu mọi trạng thái trống cần thiết để thực hiện kiểm tra ban đầu */

extern void (*ftrace_trace_function)(dài không dấu, dài không dấu);
		nếu (ftrace_trace_function != ftrace_stub)
			đi đến do_trace;

/* khôi phục mọi trạng thái trống */

trở lại;

do_trace:

/* lưu tất cả trạng thái mà ABI cần (xem đoạn trên) */

unsigned long frompc = ...;
		selfpc dài không dấu = <địa chỉ trả về> - MCOUNT_INSN_SIZE;
		ftrace_trace_function(frompc, selfpc);

/* khôi phục tất cả trạng thái cần thiết của ABI */
	}

Đừng quên xuất mcount cho các mô-đun!
::

bên ngoài void mcount(void);
	EXPORT_SYMBOL(số lượng);


HAVE_FUNCTION_GRAPH_TRACER
--------------------------

Hít thở sâu ... đã đến lúc phải làm một số công việc thực sự.  Tại đây bạn sẽ cần cập nhật
mcount để kiểm tra các con trỏ của hàm đồ thị ftrace, cũng như thực hiện
một số chức năng lưu (chiếm quyền điều khiển) và khôi phục địa chỉ trả về.

Hàm mcount sẽ kiểm tra các con trỏ hàm ftrace_graph_return
(so sánh với ftrace_stub) và ftrace_graph_entry (so sánh với
ftrace_graph_entry_stub).  Nếu một trong hai thứ đó không được đặt thành sơ khai có liên quan
hàm, lần lượt gọi hàm dành riêng cho Arch ftrace_graph_caller
gọi hàm dành riêng cho Arch là prepare_ftrace_return.  Cả hai điều này đều không
tên hàm là bắt buộc, nhưng bạn vẫn nên sử dụng chúng để duy trì
nhất quán trên các cổng kiến trúc -- dễ so sánh và tương phản hơn
mọi thứ.

Các đối số của prepare_ftrace_return hơi khác so với những gì
được chuyển tới ftrace_trace_function.  Đối số thứ hai "selfpc" cũng giống nhau,
nhưng đối số đầu tiên phải là một con trỏ tới "frompc".  Thông thường đây là
nằm trên ngăn xếp.  Điều này cho phép hàm chiếm đoạt địa chỉ trả về
tạm thời để nó trỏ đến hàm dành riêng cho Arch return_to_handler.
Hàm đó sẽ chỉ gọi hàm ftrace_return_to_handler thông thường và
sẽ trả về địa chỉ trả lại ban đầu mà bạn có thể quay lại
trang web cuộc gọi ban đầu.

Đây là mã giả mcount được cập nhật::

void mcount(void)
	{
	...
		if (ftrace_trace_function != ftrace_stub)
			goto do_trace;

+#ifdef CONFIG_FUNCTION_GRAPH_TRACER
	+ khoảng trống bên ngoài (*ftrace_graph_return)(...);
	+ khoảng trống bên ngoài (*ftrace_graph_entry)(...);
	+ if (ftrace_graph_return != ftrace_stub ||
	+ ftrace_graph_entry != ftrace_graph_entry_stub)
	+ ftrace_graph_caller();
	+#endif

/* khôi phục mọi trạng thái trống */
	...

Đây là mã giả cho hàm tập hợp ftrace_graph_caller mới ::

#ifdef CONFIG_FUNCTION_GRAPH_TRACER
	void ftrace_graph_caller(void)
	{
		/* lưu tất cả trạng thái cần thiết của ABI */

dài không dấu *frompc = &...;
		selfpc dài không dấu = <địa chỉ trả về> - MCOUNT_INSN_SIZE;
		/* chuyển con trỏ khung lên là tùy chọn -- xem bên dưới */
		prepare_ftrace_return(frompc, selfpc, frame_pointer);

/* khôi phục tất cả trạng thái cần thiết của ABI */
	}
	#endif

Để biết thông tin về cách triển khai prepare_ftrace_return(), chỉ cần xem
phiên bản x86 (việc truyền con trỏ khung là tùy chọn; xem phần tiếp theo để biết
thêm thông tin).  Phần kiến trúc cụ thể duy nhất trong đó là việc thiết lập
bảng khắc phục lỗi (mã asm(...)).  Phần còn lại phải giống nhau
xuyên suốt các kiến trúc.

Đây là mã giả cho hàm tập hợp return_to_handler mới.  Lưu ý
rằng ABI áp dụng ở đây khác với ABI áp dụng cho mcount
mã.  Vì bạn đang trở về từ một hàm (sau phần kết), bạn có thể
có thể tiết kiệm những thứ được lưu/khôi phục (thường chỉ là các thanh ghi được sử dụng để vượt qua
giá trị trả về).
::

#ifdef CONFIG_FUNCTION_GRAPH_TRACER
	void return_to_handler(void)
	{
		/* lưu tất cả trạng thái mà ABI cần (xem đoạn trên) */

void (*origin_return_point)(void) = ftrace_return_to_handler();

/* khôi phục tất cả trạng thái cần thiết của ABI */

/* đây thường là quay lại hoặc nhảy */
		original_return_point();
	}
	#endif


HAVE_FUNCTION_GRAPH_FP_TEST
---------------------------

Một vòm có thể truyền một giá trị duy nhất (con trỏ khung) cho cả phần nhập và phần
thoát khỏi một chức năng.  Khi thoát, giá trị được so sánh và nếu không
match thì nó sẽ làm kernel hoảng sợ.  Đây phần lớn là một cuộc kiểm tra tình trạng xấu
tạo mã với gcc.  Nếu gcc cho cổng của bạn cập nhật khung một cách an toàn
con trỏ ở các mức tối ưu hóa khác nhau thì hãy bỏ qua tùy chọn này.

Tuy nhiên, việc thêm hỗ trợ cho nó không quá khó khăn.  Trong mã lắp ráp của bạn
gọi prepare_ftrace_return(), chuyển con trỏ khung làm đối số thứ 3.
Sau đó, trong phiên bản C của chức năng đó, hãy thực hiện những gì cổng x86 làm và vượt qua nó
cùng với ftrace_push_return_trace() thay vì giá trị sơ khai là 0.

Tương tự, khi bạn gọi ftrace_return_to_handler(), hãy chuyển nó vào con trỏ khung.

HAVE_SYSCALL_TRACEPOINTS
------------------------

Bạn cần rất ít thứ để theo dõi các tòa nhà cao tầng trong một vòm.

- Hỗ trợ HAVE_ARCH_TRACEHOOK (xem Arch/Kconfig).
  - Có biến NR_syscalls trong <asm/unistd.h> cung cấp số
    của các tòa nhà cao tầng được hỗ trợ bởi Arch.
  - Hỗ trợ cờ chủ đề TIF_SYSCALL_TRACEPOINT.
  - Thực hiện các cuộc gọi tracepoint trace_sys_enter() và trace_sys_exit() từ ptrace
    trong đường dẫn theo dõi tòa nhà ptrace.
  - Nếu bảng gọi hệ thống trên vòm này phức tạp hơn một mảng đơn giản
    địa chỉ của các cuộc gọi hệ thống, hãy triển khai Arch_syscall_addr để trả về
    địa chỉ của một cuộc gọi hệ thống nhất định.
  - Nếu tên ký hiệu của lệnh gọi hệ thống không khớp với tên hàm trên
    vòm này, xác định ARCH_HAS_SYSCALL_MATCH_SYM_NAME trong asm/ftrace.h và
    triển khai Arch_syscall_match_sym_name với logic thích hợp để trả về
    đúng nếu tên hàm tương ứng với tên ký hiệu.
  - Gắn thẻ vòm này là HAVE_SYSCALL_TRACEPOINTS.


HAVE_DYNAMIC_FTRACE
-------------------

Xem scripts/recordmcount.pl để biết thêm thông tin.  Chỉ cần điền vào vòm cụ thể
chi tiết về cách xác định địa chỉ của các trang web cuộc gọi mcount thông qua objdump.
Tùy chọn này sẽ không có nhiều ý nghĩa nếu không triển khai ftrace động.

Trước tiên bạn sẽ cần HAVE_FUNCTION_TRACER, vì vậy hãy cuộn đầu đọc của bạn trở lại nếu bạn
đã quá háo hức.

Khi những điều đó không còn nữa, bạn sẽ cần phải triển khai:
	- asm/ftrace.h:
		-MCOUNT_ADDR
		- ftrace_call_just()
		- cấu trúc dyn_arch_ftrace{}
	- mã asm:
		- mcount() (sơ khai mới)
		- ftrace_caller()
		- ftrace_call()
		- ftrace_stub()
	- Mã C:
		- ftrace_dyn_arch_init()
		- ftrace_make_nop()
		- ftrace_make_call()
		- ftrace_update_ftrace_func()

Trước tiên, bạn sẽ cần điền một số chi tiết vòm trong asm/ftrace.h của mình.

Xác định MCOUNT_ADDR làm địa chỉ biểu tượng mcount của bạn tương tự như::

#define MCOUNT_ADDR ((dài không dấu) số lượng)

Vì không có ai khác có quyền khai báo cho chức năng đó nên bạn sẽ cần::

bên ngoài void mcount(void);

Bạn cũng sẽ cần hàm trợ giúp ftrace_call_ adjustment().  Hầu hết mọi người
sẽ có thể loại bỏ nó như vậy::

nội tuyến tĩnh không dấu dài ftrace_call_ adjustment(addr dài không dấu)
	{
		trả về địa chỉ;
	}

<chi tiết cần điền>

Cuối cùng, bạn sẽ cần cấu trúc dyn_arch_ftrace tùy chỉnh.  Nếu bạn cần
một số trạng thái bổ sung khi chạy vá các trang web cuộc gọi tùy ý, đây là
nơi.  Tuy nhiên, hiện tại, hãy tạo một cấu trúc trống::

cấu trúc dyn_arch_ftrace {
		/* Không cần thêm dữ liệu */
	};

Bỏ tiêu đề đi, chúng ta có thể điền mã lắp ráp.  Trong khi chúng tôi
đã tạo hàm mcount() trước đó, ftrace động chỉ muốn một
chức năng sơ khai.  Điều này là do mcount() sẽ chỉ được sử dụng trong quá trình khởi động
và sau đó tất cả các tham chiếu đến nó sẽ được vá đi và không bao giờ quay trở lại.  Thay vào đó,
phần cốt lõi của mcount() cũ sẽ được sử dụng để tạo ftrace_caller() mới
chức năng.  Bởi vì cả hai khó có thể hợp nhất nên rất có thể sẽ rất nhiều
dễ dàng hơn khi có hai định nghĩa riêng biệt được phân chia bởi #ifdefs.  Điều tương tự cũng xảy ra với
ftrace_stub() vì giờ đây nó sẽ được đưa vào ftrace_caller().

Trước khi chúng ta bối rối thêm nữa, hãy kiểm tra một số mã giả để bạn có thể
triển khai nội dung của riêng bạn trong hội::

void mcount(void)
	{
		trở lại;
	}

void ftrace_caller(void)
	{
		/* lưu tất cả trạng thái mà ABI cần (xem đoạn trên) */

unsigned long frompc = ...;
		selfpc dài không dấu = <địa chỉ trả về> - MCOUNT_INSN_SIZE;

ftrace_call:
		ftrace_stub(frompc, selfpc);

/* khôi phục tất cả trạng thái cần thiết của ABI */

ftrace_stub:
		trở lại;
	}

Điều này ban đầu có thể trông hơi kỳ lạ, nhưng hãy nhớ rằng chúng ta sẽ chạy
vá nhiều thứ.  Đầu tiên, chỉ những chức năng mà chúng tôi thực sự muốn theo dõi
sẽ được vá để gọi ftrace_caller().  Thứ hai, vì chúng ta chỉ có một người theo dõi
hoạt động tại một thời điểm, chúng tôi sẽ vá chính hàm ftrace_caller() để gọi
công cụ theo dõi cụ thể được đề cập.  Đó là mục đích của nhãn ftrace_call.

Với ý nghĩ đó, chúng ta hãy chuyển sang mã C sẽ thực sự thực hiện
vá thời gian chạy.  Bạn sẽ cần một chút kiến thức về các opcode của Arch trong
để có thể vượt qua phần tiếp theo.

Mỗi vòm đều có chức năng gọi lại init.  Nếu bạn cần phải làm điều gì đó sớm
để khởi tạo một số trạng thái, đây là lúc để làm điều đó.  Nếu không, điều này đơn giản
chức năng dưới đây là đủ cho hầu hết mọi người::

int __init ftrace_dyn_arch_init(void)
	{
		trả về 0;
	}

Có hai hàm được sử dụng để thực hiện vá lỗi thời gian chạy tùy ý
chức năng.  Cái đầu tiên được sử dụng để biến trang gọi mcount thành nop (mà
là yếu tố giúp chúng tôi duy trì hiệu suất thời gian chạy khi không theo dõi).  Thứ hai là
được sử dụng để biến trang web cuộc gọi mcount thành cuộc gọi đến một vị trí tùy ý (nhưng
thông thường đó là ftracer_caller()).  Xem định nghĩa hàm tổng quát ở
linux/ftrace.h cho các chức năng::

ftrace_make_nop()
	ftrace_make_call()

Giá trị rec->ip là địa chỉ của trang web cuộc gọi mcount đã được thu thập
bởi scripts/recordmcount.pl trong thời gian xây dựng.

Hàm cuối cùng được sử dụng để thực hiện vá lỗi thời gian chạy của trình theo dõi đang hoạt động.  Cái này
sẽ sửa đổi mã lắp ráp tại vị trí của biểu tượng ftrace_call
bên trong hàm ftrace_caller().  Vì vậy bạn nên có đủ phần đệm
tại vị trí đó để hỗ trợ các lệnh gọi hàm mới mà bạn sẽ chèn.  Một số
mọi người sẽ sử dụng hướng dẫn loại "gọi" trong khi những người khác sẽ sử dụng
lệnh kiểu "nhánh".  Cụ thể, chức năng là::

ftrace_update_ftrace_func()


HAVE_DYNAMIC_FTRACE + HAVE_FUNCTION_GRAPH_TRACER
------------------------------------------------

Trình vẽ đồ thị hàm cần một vài điều chỉnh để hoạt động với ftrace động.
Về cơ bản, bạn sẽ cần phải:

- cập nhật:
		- ftrace_caller()
		- ftrace_graph_call()
		- ftrace_graph_caller()
	- thực hiện:
		- ftrace_enable_ftrace_graph_caller()
		- ftrace_disable_ftrace_graph_caller()

<chi tiết cần điền>

Ghi chú nhanh:

- thêm một sơ khai nop sau vị trí ftrace_call có tên ftrace_graph_call;
	  stub cần phải đủ lớn để hỗ trợ cuộc gọi tới ftrace_graph_caller()
	- cập nhật ftrace_graph_caller() để hoạt động khi được người mới gọi
	  ftrace_caller() vì một số ngữ nghĩa có thể đã thay đổi
	- ftrace_enable_ftrace_graph_caller() sẽ vá lỗi trong thời gian chạy
	  vị trí ftrace_graph_call với lệnh gọi tới ftrace_graph_caller()
	- ftrace_disable_ftrace_graph_caller() sẽ vá lỗi trong thời gian chạy
	  vị trí ftrace_graph_call có số điểm
