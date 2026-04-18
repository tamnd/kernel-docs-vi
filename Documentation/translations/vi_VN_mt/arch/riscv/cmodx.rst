.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/cmodx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================================================
Sửa đổi đồng thời và thực hiện các hướng dẫn (CMODX) cho RISC-V Linux
====================================================================================

CMODX là một kỹ thuật lập trình trong đó chương trình thực thi các lệnh đã được
được sửa đổi bởi chính chương trình. Lưu trữ lệnh và bộ đệm lệnh
(icache) không được đảm bảo đồng bộ hóa trên phần cứng RISC-V. Vì vậy,
chương trình phải thực thi đồng bộ hóa của chính nó với hàng rào không có đặc quyền.i
hướng dẫn.

CMODX trong không gian hạt nhân
-------------------------

ftrace động
---------------------

Về cơ bản, ftrace động điều khiển luồng điều khiển bằng cách chèn một hàm
gọi mỗi mục chức năng có thể vá và vá nó một cách linh hoạt trong thời gian chạy để
kích hoạt hoặc vô hiệu hóa chuyển hướng. Trong trường hợp RISC-V, 2 hướng dẫn,
AUIPC + JALR, được yêu cầu để soạn lệnh gọi hàm. Tuy nhiên, điều đó là không thể
để vá 2 lệnh và hy vọng rằng một bên đọc đồng thời sẽ thực thi chúng
không có điều kiện chủng tộc. Loạt bài này giúp cho việc vá mã atmoic trở nên khả thi trong
RISC-V ftrace. Quyền ưu tiên hạt nhân khiến mọi thứ thậm chí còn tồi tệ hơn vì nó cho phép cái cũ
trạng thái duy trì trong suốt quá trình vá lỗi bằng stop_machine().

Để loại bỏ stop_machine() và chạy ftrace động với kernel đầy đủ
quyền ưu tiên, chúng tôi khởi tạo một phần từng mục nhập chức năng có thể vá vào lúc khởi động,
đặt lệnh đầu tiên thành AUIPC và lệnh thứ hai thành NOP. Bây giờ, atmoic
có thể vá lỗi vì kernel chỉ phải cập nhật một lệnh.
Theo Ziccif, miễn là lệnh được căn chỉnh một cách tự nhiên, ISA
đảm bảo cập nhật nguyên tử.

Bằng cách sửa lệnh đầu tiên, AUIPC, phạm vi của tấm bạt lò xo ftrace
bị giới hạn ở mức +-2K từ mục tiêu được xác định trước, ftrace_caller, do thiếu
không gian mã hóa ngay lập tức trong RISC-V. Để giải quyết vấn đề chúng tôi giới thiệu
CALL_OPS, trong đó siêu dữ liệu căn chỉnh tự nhiên 8B được thêm vào trước mỗi siêu dữ liệu
chức năng có thể ghép nối. Siêu dữ liệu được giải quyết ở tấm bạt lò xo đầu tiên, sau đó là
việc thực hiện có thể được chuyển sang một tấm bạt lò xo tùy chỉnh khác.

CMODX trong không gian người dùng
-----------------------

Mặc dù Fence.i là một hướng dẫn không có đặc quyền, Linux ABI mặc định lại cấm
việc sử dụng Fence.i trong các ứng dụng không gian người dùng. Tại bất kỳ thời điểm nào, bộ lập lịch có thể
di chuyển một nhiệm vụ sang một hart mới. Nếu quá trình di chuyển xảy ra sau vùng người dùng
đã đồng bộ hóa icache và lưu trữ lệnh với fence.i, icache trên
con hươu mới sẽ không còn sạch nữa. Điều này là do hành vi của hàng rào.i chỉ
ảnh hưởng đến con hươu mà nó được kêu gọi. Vì vậy, điều khó khăn mà nhiệm vụ đã được thực hiện
được di chuyển đến có thể không có bộ nhớ lệnh và icache được đồng bộ hóa.

Có hai cách để giải quyết vấn đề này: sử dụng tòa nhà riscv_flush_icache(),
hoặc sử dụng ZZ0000ZZ prctl() và phát ra hàng rào.i trong
không gian người dùng. Tòa nhà cao tầng thực hiện thao tác xóa icache một lần. công việc
thay đổi Linux ABI để cho phép không gian người dùng phát ra các thao tác xóa icache.

Bên cạnh đó, việc xóa icache "hoãn lại" đôi khi có thể được kích hoạt trong kernel.
Tại thời điểm viết bài, điều này chỉ xảy ra trong tòa nhà riscv_flush_icache()
và khi kernel sử dụng copy_to_user_page(). Những lần xả chậm này chỉ xảy ra
khi bản đồ bộ nhớ được sử dụng bởi Hart thay đổi. Nếu bối cảnh prctl() gây ra
một lần xóa icache, việc xóa icache bị trì hoãn này sẽ bị bỏ qua vì nó dư thừa.
Do đó, sẽ không có thao tác xả bổ sung khi sử dụng riscv_flush_icache()
syscall bên trong ngữ cảnh prctl().

Giao diện prctl()
---------------------

Gọi prctl() với ZZ0000ZZ làm đối số đầu tiên. các
các đối số còn lại sẽ được ủy quyền cho riscv_set_icache_flush_ctx
chức năng chi tiết dưới đây.

.. kernel-doc:: arch/riscv/mm/cacheflush.c
	:identifiers: riscv_set_icache_flush_ctx

Cách sử dụng ví dụ:

Các tệp sau đây được biên dịch và liên kết với nhau. các
Hàm Modify_instruction() thay thế phép cộng bằng 0 bằng phép cộng bằng một,
làm cho chuỗi lệnh trong get_value() thay đổi từ việc trả về số 0
để trả lại một cái.

cmodx.c::

#include <stdio.h>
	#include <sys/prctl.h>

int bên ngoài get_value();
	bên ngoài void sửa đổi_instruction();

int chính()
	{
		giá trị int = get_value();
		printf("Giá trị trước cmodx: %d\n", value);

// Gọi prctl trước hàng rào đầu tiên.i được gọi bên trong Modify_instruction
		prctl(PR_RISCV_SET_ICACHE_FLUSH_CTX, PR_RISCV_CTX_SW_FENCEI_ON, PR_RISCV_SCOPE_PER_PROCESS);
		sửa đổi_instruction();
		// Gọi prctl sau hàng rào cuối cùng.i được gọi trong quá trình
		prctl(PR_RISCV_SET_ICACHE_FLUSH_CTX, PR_RISCV_CTX_SW_FENCEI_OFF, PR_RISCV_SCOPE_PER_PROCESS);

giá trị = get_value();
		printf("Giá trị sau cmodx: %d\n", value);
		trả về 0;
	}

cmodx.S::

.option norvc

.text
	.global sửa đổi_instruction
	sửa đổi_instruction:
	lw a0, new_insn
	lui a5,%hi(old_insn)
	sw a0,%lo(old_insn)(a5)
	hàng rào.i
	về lại

.section có thể sửa đổi, "awx"
	.global get_value
	get_value:
	lý a0, 0
	old_insn:
	cộng a0, a0, 0
	về lại

.data
	new_insn:
	cộng a0, a0, 1