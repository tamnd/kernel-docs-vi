.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/classic_vs_extended.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.


=======================
BPF cổ điển so với eBPF
=======================

eBPF được thiết kế để JITed với ánh xạ 1-1, điều này cũng có thể mở ra
khả năng trình biên dịch GCC/LLVM tạo mã eBPF được tối ưu hóa thông qua
một chương trình phụ trợ eBPF hoạt động nhanh gần như mã được biên dịch nguyên gốc.

Một số thay đổi cốt lõi của định dạng eBPF từ BPF cổ điển:

- Số lượng thanh ghi tăng từ 2 lên 10:

Định dạng cũ có hai thanh ghi A và X và một con trỏ khung ẩn. các
  bố cục mới mở rộng thành 10 thanh ghi nội bộ và khung chỉ đọc
  con trỏ. Vì CPU 64 bit đang truyền đối số cho các hàm thông qua các thanh ghi
  số lượng đối số từ chương trình eBPF đến hàm trong kernel bị hạn chế
  đến 5 và một thanh ghi được sử dụng để chấp nhận giá trị trả về từ hạt nhân
  chức năng. Về cơ bản, x86_64 chuyển 6 đối số đầu tiên trong sổ đăng ký, aarch64/
  sparcv9/mips64 có 7 - 8 thanh ghi cho đối số; x86_64 đã lưu 6 callee
  các thanh ghi và aarch64/sparcv9/mips64 có 11 thanh ghi được lưu trở lên.

Do đó, tất cả các thanh ghi eBPF ánh xạ 1-1 tới các thanh ghi CTNH trên x86_64, aarch64,
  v.v. và quy ước gọi eBPF ánh xạ trực tiếp tới ABI được kernel sử dụng trên
  Kiến trúc 64-bit.

Trên kiến trúc 32 bit, JIT có thể ánh xạ các chương trình chỉ sử dụng số học 32 bit
  và có thể cho phép các chương trình phức tạp hơn được diễn giải.

R0 - R5 là các thanh ghi cào và chương trình eBPF cần đổ/điền chúng nếu
  cần thiết qua các cuộc gọi. Lưu ý rằng chỉ có một chương trình eBPF (== một
  thủ tục chính của eBPF) và nó không thể gọi các hàm eBPF khác, nó chỉ có thể
  Tuy nhiên, hãy gọi các hàm trong kernel được xác định trước.

- Độ rộng thanh ghi tăng từ 32-bit lên 64-bit:

Tuy nhiên, ngữ nghĩa của các hoạt động ALU 32 bit ban đầu vẫn được giữ nguyên
  thông qua các thanh ghi con 32-bit. Tất cả các thanh ghi eBPF đều là 64 bit với 32 bit thấp hơn
  các thanh ghi con không mở rộng thành 64-bit nếu chúng được ghi vào.
  Hành vi đó ánh xạ trực tiếp đến định nghĩa đăng ký con x86_64 và arm64, nhưng
  làm cho các JIT khác trở nên khó khăn hơn.

Kiến trúc 32 bit chạy chương trình eBPF 64 bit thông qua trình thông dịch.
  JIT của họ có thể chuyển đổi các chương trình BPF chỉ sử dụng các thanh ghi con 32 bit thành
  tập lệnh gốc và để phần còn lại được diễn giải.

Hoạt động là 64-bit, vì trên kiến trúc 64-bit, con trỏ cũng
  Rộng 64 bit và chúng tôi muốn chuyển các giá trị 64 bit vào/ra các hàm kernel,
  vì vậy, các thanh ghi eBPF 32 bit sẽ yêu cầu xác định cặp thanh ghi
  Do đó, ABI sẽ không thể sử dụng thanh ghi eBPF trực tiếp để đăng ký CTNH
  ánh xạ và JIT sẽ cần thực hiện các thao tác kết hợp/tách/di chuyển cho mọi
  đăng ký vào và ra khỏi chức năng, chức năng này phức tạp, dễ bị lỗi và chậm.
  Một lý do khác là việc sử dụng bộ đếm nguyên tử 64-bit.

- Mục tiêu jt/jf có điều kiện được thay thế bằng jt/fall-through:

Mặc dù thiết kế ban đầu có các cấu trúc như ZZ0000ZZ nhưng chúng đang được thay thế bằng các cấu trúc thay thế như
  ZZ0001ZZ.

- Giới thiệu bpf_call insn và đăng ký quy ước chuyển giao với chi phí bằng 0
  các cuộc gọi từ/đến các hàm kernel khác:

Trước khi gọi hàm trong kernel, chương trình eBPF cần
  đặt các đối số hàm vào các thanh ghi R1 đến R5 để đáp ứng việc gọi
  quy ước, sau đó thông dịch viên sẽ lấy chúng từ sổ đăng ký và chuyển
  đến chức năng trong kernel. Nếu các thanh ghi R1 - R5 được ánh xạ tới các thanh ghi CPU
  được sử dụng để truyền đối số trên kiến trúc đã cho, trình biên dịch JIT
  không cần thực hiện thêm động tác. Các đối số của hàm sẽ đúng
  các thanh ghi và lệnh BPF_CALL sẽ được JITed dưới dạng HW 'gọi' duy nhất
  hướng dẫn. Quy ước gọi điện này đã được chọn để bao gồm cuộc gọi thông thường
  các tình huống không bị phạt hiệu suất.

Sau lệnh gọi hàm trong kernel, R1 - R5 được đặt lại thành không thể đọc được và R0 có
  giá trị trả về của hàm. Vì R6 - R9 được lưu lại nên trạng thái của chúng
  được bảo toàn trong suốt cuộc gọi.

Ví dụ: hãy xem xét ba hàm C::

u64 f1() { return (*_f2)(1); }
    u64 f2(u64 a) { return f3(a + 1, a); }
    u64 f3(u64 a, u64 b) { return a - b; }

GCC có thể biên dịch f1, f3 thành x86_64::

f1:
	di chuyển $1, %edi
	movq _f2(%rip), %rax
	jmp *%rax
    f3:
	movq %rdi, %rax
	subq %rsi, %rax
	về lại

Hàm f2 trong eBPF có thể trông giống như::

f2:
	bpf_mov R2, R1
	bpf_add R1, 1
	bpf_call f3
	bpf_exit

Nếu f2 được JITed và con trỏ được lưu vào ZZ0000ZZ. Các lệnh gọi f1 -> f2 -> f3 và
  lợi nhuận sẽ được liền mạch. Nếu không có JIT, trình thông dịch __bpf_prog_run() cần phải
  được sử dụng để gọi vào f2.

Vì những lý do thực tế, tất cả các chương trình eBPF chỉ có một đối số 'ctx', đó là
  đã được đặt vào R1 (ví dụ: khi khởi động __bpf_prog_run()) và các chương trình
  có thể gọi các hàm kernel với tối đa 5 đối số. Cuộc gọi có 6 đối số trở lên
  hiện không được hỗ trợ, nhưng những hạn chế này có thể được dỡ bỏ nếu cần thiết
  trong tương lai.

Trên kiến ​​trúc 64-bit, tất cả các bản đồ đăng ký vào các thanh ghi CTNH từng cái một. cho
  ví dụ: trình biên dịch x86_64 JIT có thể ánh xạ chúng dưới dạng ...

  ::

R0 - rax
    R1 - rdi
    R2 - rsi
    R3 - rdx
    R4 - RCx
    R5 - r8
    R6 - rbx
    R7 - r13
    R8 - r14
    R9 - r15
    R10 - rbp

  ... since x86_64 ABI mandates rdi, rsi, rdx, rcx, r8, r9 for argument passing
và rbx, r12 - r15 được lưu lại.

Sau đó, chương trình giả eBPF sau::

bpf_mov R6, R1 /* lưu ctx */
    bpf_mov R2, 2
    bpf_mov R3, 3
    bpf_mov R4, 4
    bpf_mov R5, 5
    bpf_call foo
    bpf_mov R7, R0 /* lưu giá trị trả về foo() */
    bpf_mov R1, R6 /* khôi phục ctx cho cuộc gọi tiếp theo */
    bpf_mov R2, 6
    bpf_mov R3, 7
    bpf_mov R4, 8
    bpf_mov R5, 9
    thanh bpf_call
    bpf_add R0, R7
    bpf_exit

Sau JIT tới x86_64 có thể trông giống như::

đẩy %rbp
    di chuyển %rsp,%rbp
    phụ $0x228,%rsp
    di chuyển %rbx,-0x228(%rbp)
    di chuyển %r13,-0x220(%rbp)
    di chuyển %rdi,%rbx
    di chuyển $0x2,%esi
    di chuyển $0x3,%edx
    di chuyển $0x4,%ecx
    di chuyển $0x5,%r8d
    callq foo
    di chuyển %rax,%r13
    di chuyển %rbx,%rdi
    di chuyển $0x6,%esi
    di chuyển $0x7,%edx
    di chuyển $0x8,%ecx
    di chuyển $0x9,%r8d
    thanh callq
    thêm %r13,%rax
    mov -0x228(%rbp),%rbx
    mov -0x220(%rbp),%r13
    nghỉ phép
    retq

Trong ví dụ này tương đương trong C với::

u64 bpf_filter(u64 ctx)
    {
	return foo(ctx, 2, 3, 4, 5) + bar(ctx, 6, 7, 8, 9);
    }

Các hàm trong kernel foo() và bar() với nguyên mẫu: u64 (*)(u64 arg1, u64
  arg2, u64 arg3, u64 arg4, u64 arg5); sẽ nhận được các đối số phù hợp
  đăng ký và đặt giá trị trả về của chúng vào ZZ0000ZZ là R0 trong eBPF.
  Đoạn mở đầu và đoạn kết được phát ra bởi JIT và ẩn chứa trong
  thông dịch viên. R0-R5 là các thanh ghi cào, vì vậy chương trình eBPF cần bảo toàn
  chúng qua các cuộc gọi như được xác định bằng cách gọi quy ước.

Ví dụ: chương trình sau không hợp lệ::

bpf_mov R1, 1
    bpf_call foo
    bpf_mov R0, R1
    bpf_exit

Sau cuộc gọi, các thanh ghi R1-R5 chứa các giá trị rác và không thể đọc được.
  Verifier.rst trong kernel được sử dụng để xác thực các chương trình eBPF.

Cũng trong thiết kế mới, eBPF bị giới hạn ở 4096 insns, có nghĩa là bất kỳ
chương trình sẽ kết thúc nhanh chóng và sẽ chỉ gọi một số kernel cố định
chức năng. BPF và eBPF gốc là hai lệnh toán hạng,
giúp thực hiện ánh xạ một-một giữa eBPF insn và x86 insn trong JIT.

Con trỏ ngữ cảnh đầu vào để gọi hàm thông dịch là chung,
nội dung của nó được xác định bởi một trường hợp sử dụng cụ thể. Đối với seccomp đăng ký điểm R1
tới seccomp_data, đối với các bộ lọc BPF đã chuyển đổi thì R1 trỏ tới skb.

Một chương trình được dịch nội bộ bao gồm các phần tử sau::

op:16, jt:8, jf:8, k:32 ==> op:8, dst_reg:4, src_reg:4, off:16, imm:32

Cho đến nay 87 hướng dẫn eBPF đã được triển khai. Trường opcode 8-bit 'op'
có chỗ cho những hướng dẫn mới. Một số trong số chúng có thể sử dụng mã hóa 16/24/32 byte. Mới
hướng dẫn phải là bội số của 8 byte để duy trì khả năng tương thích ngược.

eBPF là tập lệnh RISC có mục đích chung. Không phải mọi đăng ký và
mọi lệnh đều được sử dụng trong quá trình dịch từ BPF gốc sang eBPF.
Ví dụ: bộ lọc ổ cắm không sử dụng lệnh ZZ0000ZZ, nhưng
Ví dụ: các bộ lọc theo dõi có thể thực hiện để duy trì bộ đếm sự kiện. Đăng ký R9
cũng không được sử dụng bởi các bộ lọc ổ cắm, nhưng các bộ lọc phức tạp hơn có thể đang chạy
hết sổ đăng ký và sẽ phải dùng đến cách đổ/đổ đầy vào ngăn xếp.

eBPF có thể được sử dụng như một trình biên dịch chung cho hiệu suất ở bước cuối cùng
tối ưu hóa, bộ lọc ổ cắm và seccomp đang sử dụng nó làm trình biên dịch mã. Truy tìm
các bộ lọc có thể sử dụng nó làm trình biên dịch mã để tạo mã từ kernel. Trong cách sử dụng kernel
có thể không bị giới hạn bởi các cân nhắc về bảo mật vì mã eBPF được tạo
có thể tối ưu hóa đường dẫn mã nội bộ và không bị lộ ra không gian người dùng.
Sự an toàn của eBPF có thể đến từ verifier.rst. Trong những trường hợp sử dụng như
được mô tả, nó có thể được sử dụng như tập lệnh an toàn.

Giống như BPF ban đầu, eBPF chạy trong môi trường được kiểm soát,
mang tính quyết định và hạt nhân có thể dễ dàng chứng minh điều đó. Tính an toàn của chương trình
có thể được xác định theo hai bước: bước đầu tiên thực hiện tìm kiếm theo chiều sâu để không cho phép
vòng lặp và xác nhận CFG khác; bước thứ hai bắt đầu từ quán trọ đầu tiên và
đi xuống tất cả các con đường có thể. Nó mô phỏng việc thực hiện mọi hoạt động và quan sát
sự thay đổi trạng thái của các thanh ghi và ngăn xếp.

mã hóa opcode
===============

eBPF đang sử dụng lại hầu hết mã hóa opcode từ cổ điển để đơn giản hóa việc chuyển đổi
của BPF cổ điển sang eBPF.

Đối với các lệnh số học và lệnh nhảy, trường 'mã' 8 bit được chia thành ba
bộ phận::

++-------+--------+----------------------+
  ZZ0000ZZ 1 bit ZZ0001ZZ
  Nguồn ZZ0002ZZ ZZ0003ZZ
  ++-------+--------+----------------------+
  (MSB) (LSB)

Ba bit LSB lưu trữ lớp lệnh là một trong:

====================================
  Lớp BPF cổ điển Lớp eBPF
  ====================================
  BPF_LD 0x00 BPF_LD 0x00
  BPF_LDX 0x01 BPF_LDX 0x01
  BPF_ST 0x02 BPF_ST 0x02
  BPF_STX 0x03 BPF_STX 0x03
  BPF_ALU 0x04 BPF_ALU 0x04
  BPF_JMP 0x05 BPF_JMP 0x05
  BPF_RET 0x06 BPF_JMP32 0x06
  BPF_MISC 0x07 BPF_ALU64 0x07
  ====================================

Bit thứ 4 mã hóa toán hạng nguồn ...

    ::

BPF_K 0x00
	BPF_X 0x08

* trong BPF cổ điển, điều này có nghĩa::

BPF_SRC(code) == BPF_X - sử dụng thanh ghi X làm toán hạng nguồn
	BPF_SRC(code) == BPF_K - sử dụng 32-bit ngay lập tức làm toán hạng nguồn

* trong eBPF, điều này có nghĩa là::

BPF_SRC(code) == BPF_X - sử dụng thanh ghi 'src_reg' làm toán hạng nguồn
	BPF_SRC(code) == BPF_K - sử dụng 32-bit ngay lập tức làm toán hạng nguồn

... and four MSB bits store operation code.

Nếu BPF_CLASS(code) == BPF_ALU hoặc BPF_ALU64 [ trong eBPF ], BPF_OP(code) là một trong::

BPF_ADD 0x00
  BPF_SUB 0x10
  BPF_MUL 0x20
  BPF_DIV 0x30
  BPF_OR 0x40
  BPF_AND 0x50
  BPF_LSH 0x60
  BPF_RSH 0x70
  BPF_NEG 0x80
  BPF_MOD 0x90
  BPF_XOR 0xa0
  BPF_MOV 0xb0 /* chỉ eBPF: chuyển reg sang reg */
  BPF_ARSH 0xc0 /* chỉ eBPF: dấu mở rộng dịch chuyển sang phải */
  BPF_END 0xd0 /* chỉ eBPF: chuyển đổi độ bền */

Nếu BPF_CLASS(code) == BPF_JMP hoặc BPF_JMP32 [ trong eBPF ], BPF_OP(code) là một trong::

BPF_JA 0x00 /* chỉ BPF_JMP */
  BPF_JEQ 0x10
  BPF_JGT 0x20
  BPF_JGE 0x30
  BPF_JSET 0x40
  BPF_JNE 0x50 /* chỉ eBPF: nhảy != */
  BPF_JSGT 0x60 /* chỉ eBPF: đã ký '>' */
  BPF_JSGE 0x70 /* chỉ eBPF: đã ký '>=' */
  BPF_CALL 0x80 /* eBPF Chỉ BPF_JMP: gọi hàm */
  BPF_EXIT 0x90 /* eBPF Chỉ BPF_JMP: hàm trả về */
  BPF_JLT 0xa0 /* chỉ eBPF: không dấu '<' */
  BPF_JLE 0xb0 /* chỉ eBPF: không dấu '<=' */
  BPF_JSLT 0xc0 /* chỉ eBPF: đã ký '<' */
  BPF_JSLE 0xd0 /* chỉ eBPF: đã ký '<=' */

Vì vậy BPF_ADD ZZ0000ZZ BPF_ALU có nghĩa là bổ sung 32-bit trong cả BPF cổ điển
và eBPF. Chỉ có hai thanh ghi trong BPF cổ điển, vì vậy nó có nghĩa là A += X.
Trong eBPF nó có nghĩa là dst_reg = (u32) dst_reg + (u32) src_reg; tương tự,
BPF_XOR ZZ0001ZZ BPF_ALU có nghĩa là A ^= imm32 trong BPF cổ điển và tương tự
src_reg = (u32) src_reg ^ (u32) imm32 trong eBPF.

BPF cổ điển đang sử dụng lớp BPF_MISC để biểu diễn các nước đi A = X và X = A.
Thay vào đó, eBPF đang sử dụng mã BPF_MOV ZZ0000ZZ BPF_ALU. Vì không có
Các hoạt động BPF_MISC trong eBPF, lớp 7 được sử dụng làm BPF_ALU64 có nghĩa là
hoạt động chính xác giống như BPF_ALU, nhưng với toán hạng rộng 64-bit
thay vào đó. Vì vậy BPF_ADD ZZ0001ZZ BPF_ALU64 có nghĩa là bổ sung 64 bit, tức là:
dst_reg = dst_reg + src_reg

BPF cổ điển lãng phí toàn bộ lớp BPF_RET để đại diện cho một ZZ0000ZZ duy nhất
hoạt động. BPF_RET cổ điển | BPF_K có nghĩa là sao chép imm32 vào thanh ghi trả lại
và thực hiện thoát chức năng. eBPF được mô hình hóa để khớp với CPU, vì vậy BPF_JMP | BPF_EXIT
trong eBPF có nghĩa là chỉ thoát chức năng. Chương trình eBPF cần lưu trữ lợi nhuận
giá trị vào thanh ghi R0 trước khi thực hiện BPF_EXIT. Lớp 6 trong eBPF được sử dụng làm
BPF_JMP32 có nghĩa chính xác là các hoạt động tương tự như BPF_JMP, nhưng có độ rộng 32-bit
thay vào đó là các toán hạng để so sánh.

Đối với các lệnh tải và lưu trữ, trường 'mã' 8 bit được chia thành::

+--------+--------+-------------------+
  ZZ0000ZZ 2 bit ZZ0001ZZ
  ZZ0002ZZ kích thước ZZ0003ZZ
  +--------+--------+-------------------+
  (MSB) (LSB)

Công cụ sửa đổi kích thước là một trong ...

::

BPF_W 0x00 /* từ */
  BPF_H 0x08 /* nửa từ */
  BPF_B 0x10 /* byte */
  BPF_DW 0x18 /* chỉ eBPF, từ kép */

... which encodes size of load/store operation::

 B  - 1 byte
 H  - 2 byte
 W  - 4 byte
 DW - 8 byte (eBPF only)

Công cụ sửa đổi chế độ là một trong::

BPF_IMM 0x00 /* được sử dụng cho chuyển động 32 bit trong BPF cổ điển và 64-bit trong eBPF */
  BPF_ABS 0x20
  BPF_IND 0x40
  BPF_MEM 0x60
  BPF_LEN 0x80 /* chỉ BPF cổ điển, được bảo lưu trong eBPF */
  BPF_MSH 0xa0 /* chỉ BPF cổ điển, được bảo lưu trong eBPF */
  BPF_ATOMIC 0xc0 /* chỉ eBPF, hoạt động nguyên tử */
