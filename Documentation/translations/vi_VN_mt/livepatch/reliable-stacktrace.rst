.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/livepatch/reliable-stacktrace.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Stacktrace đáng tin cậy
=======================

Tài liệu này phác thảo thông tin cơ bản về phương pháp dò tìm ngăn xếp đáng tin cậy.

.. Table of Contents:

.. contents:: :local:

1. Giới thiệu
===============

Mô hình nhất quán của livepatch kernel dựa vào việc xác định chính xác cái nào
các chức năng có thể có trạng thái hoạt động và do đó có thể không an toàn để vá. Một chiều
để xác định chức năng nào đang hoạt động là sử dụng stacktrace.

Mã stacktrace hiện tại có thể không phải lúc nào cũng đưa ra một bức tranh chính xác về tất cả
hoạt động với trạng thái trực tiếp và các phương pháp nỗ lực tốt nhất có thể hữu ích cho
việc gỡ lỗi không có cơ sở cho việc vá lỗi trực tiếp. Livepatching phụ thuộc vào kiến trúc
để cung cấp một stacktrace ZZ0000ZZ để đảm bảo nó không bao giờ bỏ sót bất kỳ hoạt động trực tiếp nào
hoạt động từ một dấu vết.


2. Yêu cầu
===============

Kiến trúc phải triển khai một trong các chức năng stacktrace đáng tin cậy.
Kiến trúc sử dụng CONFIG_ARCH_STACKWALK phải triển khai
'arch_stack_walk_reliable' và các kiến trúc khác phải triển khai
'save_stack_trace_tsk_reliable'.

Về cơ bản, hàm stacktrace đáng tin cậy phải đảm bảo rằng:

* Dấu vết bao gồm tất cả các chức năng mà tác vụ có thể được trả về và
  mã trả về bằng 0 để cho biết dấu vết là đáng tin cậy.

* Mã trả về khác 0 để biểu thị rằng dấu vết không đáng tin cậy.

.. note::
   In some cases it is legitimate to omit specific functions from the trace,
   but all other functions must be reported. These cases are described in
   further detail below.

Thứ hai, hàm stacktrace đáng tin cậy phải mạnh mẽ trong trường hợp
ngăn xếp hoặc trạng thái thư giãn khác bị hỏng hoặc không đáng tin cậy. các
hàm nên cố gắng phát hiện những trường hợp như vậy và trả về lỗi khác 0
mã và không bị kẹt trong vòng lặp vô hạn hoặc truy cập bộ nhớ trong
một cách không an toàn.  Các trường hợp cụ thể được mô tả chi tiết hơn dưới đây.


3. Phân tích thời gian biên dịch
========================

Để đảm bảo rằng mã hạt nhân có thể được giải phóng chính xác trong mọi trường hợp,
kiến trúc có thể cần xác minh rằng mã đã được biên dịch theo cách
được mong đợi bởi người giải nén. Ví dụ, một người tháo gỡ có thể mong đợi rằng
các hàm thao tác con trỏ ngăn xếp theo một cách hạn chế, hoặc tất cả
các chức năng sử dụng trình tự mở đầu và kết thúc cụ thể. Kiến trúc
với những yêu cầu như vậy nên xác minh việc biên dịch kernel bằng cách sử dụng
objtool.

Trong một số trường hợp, trình giải nén có thể yêu cầu siêu dữ liệu để giải nén một cách chính xác.
Khi cần thiết, siêu dữ liệu này sẽ được tạo tại thời điểm xây dựng bằng cách sử dụng
objtool.


4. Cân nhắc
=================

Quá trình tháo gỡ khác nhau giữa các kiến trúc, quy trình tương ứng của chúng
tiêu chuẩn cuộc gọi và cấu hình kernel. Phần này mô tả chung
chi tiết mà kiến trúc nên xem xét.

4.1 Xác định việc chấm dứt thành công
--------------------------------------

Việc hủy cuộn có thể chấm dứt sớm vì một số lý do, bao gồm:

* Ngăn xếp hoặc tham nhũng con trỏ khung.

* Thiếu hỗ trợ thư giãn cho một tình huống không phổ biến hoặc lỗi trong trình thư giãn.

* Mã được tạo động (ví dụ: eBPF) hoặc mã nước ngoài (ví dụ: thời gian chạy EFI
  dịch vụ) không tuân theo các quy ước mà người tháo gỡ mong đợi.

Để đảm bảo rằng điều này không dẫn đến việc các hàm bị bỏ sót khỏi dấu vết,
ngay cả khi không bị các cuộc kiểm tra khác phát hiện, chúng tôi đặc biệt khuyến nghị rằng
kiến trúc xác minh rằng dấu vết ngăn xếp kết thúc tại một vị trí dự kiến, ví dụ:

* Trong một hàm cụ thể là điểm vào kernel.

* Tại một vị trí cụ thể trên ngăn xếp dự kiến ​​có điểm vào kernel.

* Trên một ngăn xếp cụ thể dự kiến có điểm vào kernel (ví dụ: nếu
  kiến trúc có nhiệm vụ riêng biệt và ngăn xếp IRQ).

4.2 Xác định mã có thể tháo rời
-------------------------------

Việc giải nén thường dựa vào mã theo các quy ước cụ thể (ví dụ:
thao tác với con trỏ khung), nhưng có thể có mã không tuân theo những điều này
quy ước và có thể yêu cầu xử lý đặc biệt trong bộ tháo cuộn, ví dụ:

* Các vectơ ngoại lệ và tập hợp mục nhập.

* Các mục nhập Bảng liên kết thủ tục (PLT) và các chức năng veneer.

* Lắp ráp tấm bạt lò xo (ví dụ ftrace, kprobes).

* Mã được tạo động (ví dụ: eBPF, trampolines optprobe).

* Mã nước ngoài (ví dụ: dịch vụ thời gian chạy EFI).

Để đảm bảo rằng những trường hợp như vậy không dẫn đến việc các hàm bị bỏ sót trong một
dấu vết, chúng tôi đặc biệt khuyên các kiến trúc nên xác định mã một cách tích cực
được biết là đáng tin cậy để gỡ bỏ và từ chối việc gỡ bỏ tất cả
mã khác.

Mã hạt nhân bao gồm các mô-đun và eBPF có thể được phân biệt với mã nước ngoài
sử dụng '__kernel_text_address()'. Kiểm tra điều này cũng giúp phát hiện ngăn xếp
tham nhũng.

Có một số cách mà một kiến trúc có thể xác định mã hạt nhân được coi là
không đáng tin cậy để thư giãn, ví dụ:

* Đặt mã đó vào các phần liên kết đặc biệt và từ chối việc tháo gỡ khỏi
  bất kỳ mã nào trong các phần này.

* Xác định các phần mã cụ thể bằng cách sử dụng thông tin giới hạn.

4.3 Giải quyết các ngắt và ngoại lệ
----------------------------------------------

Tại ranh giới của lệnh gọi hàm, ngăn xếp và trạng thái thư giãn khác dự kiến sẽ là
ở trạng thái nhất quán phù hợp để tháo cuộn đáng tin cậy, nhưng đây có thể không phải là
trường hợp một phần thông qua một chức năng. Ví dụ: trong phần mở đầu chức năng hoặc
phần kết, con trỏ khung có thể tạm thời không hợp lệ hoặc trong quá trình thực hiện chức năng
body, địa chỉ trả về có thể được giữ trong một thanh ghi mục đích chung tùy ý.
Đối với một số kiến trúc, điều này có thể thay đổi trong thời gian chạy do tính năng động
thiết bị đo đạc.

Nếu một ngắt hoặc ngoại lệ khác được thực hiện trong khi ngăn xếp hoặc giải phóng khác
trạng thái đang ở trạng thái không nhất quán, có thể không thể gỡ bỏ một cách đáng tin cậy,
và có thể không xác định được liệu việc tháo gỡ như vậy có đáng tin cậy hay không.
Xem bên dưới để biết ví dụ.

Kiến trúc không thể xác định khi nào là đáng tin cậy để giải quyết các trường hợp như vậy
(hoặc ở nơi không bao giờ đáng tin cậy) phải từ chối việc tháo gỡ ngoại lệ
ranh giới. Lưu ý rằng có thể đáng tin cậy để thư giãn trên một số
ngoại lệ (ví dụ: IRQ) nhưng không đáng tin cậy để giải quyết các ngoại lệ khác
(ví dụ: NMI).

Kiến trúc có thể xác định khi nào đáng tin cậy để giải quyết các trường hợp đó (hoặc
không có trường hợp nào như vậy) nên cố gắng vượt qua các ranh giới ngoại lệ, vì
làm như vậy có thể ngăn chặn việc trì hoãn không cần thiết việc kiểm tra tính nhất quán của bản vá trực tiếp và
cho phép quá trình chuyển đổi livepatch hoàn thành nhanh hơn.

4.4 Viết lại địa chỉ trả lại
---------------------------------

Một số tấm bạt lò xo tạm thời sửa đổi địa chỉ trả về của một hàm để
để chặn khi chức năng đó quay trở lại với một tấm bạt lò xo quay trở lại, ví dụ:

* Tấm bạt lò xo ftrace có thể sửa đổi địa chỉ trả về để biểu đồ hàm số đó
  việc truy tìm có thể chặn lợi nhuận.

* Tấm bạt lò xo kprobes (hoặc optprobes) có thể sửa đổi địa chỉ trả lại để
  kretprobes có thể chặn lợi nhuận.

Khi điều này xảy ra, địa chỉ trả lại ban đầu sẽ không còn ở địa chỉ thông thường nữa.
vị trí. Đối với các tấm bạt lò xo không được vá trực tiếp, trong đó
người tháo gỡ có thể xác định một cách đáng tin cậy địa chỉ trả lại ban đầu và không có trạng thái trả lại
bị thay đổi bởi tấm bạt lò xo, người tháo cuộn có thể báo cáo sự trở lại ban đầu
địa chỉ thay cho tấm bạt lò xo và báo cáo điều này là đáng tin cậy. Nếu không, một
người giải quyết phải báo cáo những trường hợp này là không đáng tin cậy.

Cần phải đặc biệt cẩn thận khi xác định địa chỉ trả lại ban đầu, vì điều này
thông tin không ở một vị trí nhất quán trong suốt thời gian nhập
tấm bạt lò xo hoặc tấm bạt lò xo trả lại. Ví dụ: xem xét x86_64
'return_to_handler' trả lại tấm bạt lò xo:

.. code-block:: none

   SYM_CODE_START(return_to_handler)
           UNWIND_HINT_UNDEFINED
           subq  $24, %rsp

           /* Save the return values */
           movq %rax, (%rsp)
           movq %rdx, 8(%rsp)
           movq %rbp, %rdi

           call ftrace_return_to_handler

           movq %rax, %rdi
           movq 8(%rsp), %rdx
           movq (%rsp), %rax
           addq $24, %rsp
           JMP_NOSPEC rdi
   SYM_CODE_END(return_to_handler)

Trong khi hàm theo dõi chạy địa chỉ trả về của nó trên ngăn xếp trỏ tới
điểm bắt đầu của return_to_handler và địa chỉ trả lại ban đầu được lưu trong
nhiệm vụ là cur_ret_stack. Trong thời gian này, người tháo cuộn có thể tìm thấy sự trở lại
địa chỉ sử dụng ftrace_graph_ret_addr().

Khi hàm truy tìm trở về return_to_handler, không còn
địa chỉ trả về trên ngăn xếp, mặc dù địa chỉ trả về ban đầu vẫn được lưu trữ
trong cur_ret_stack của nhiệm vụ. Trong phạm vi ftrace_return_to_handler(), bản gốc
địa chỉ trả về bị xóa khỏi cur_ret_stack và được di chuyển tạm thời
trình biên dịch tùy ý trước khi được trả về trong rax. Return_to_handler
tấm bạt lò xo di chuyển cái này vào rdi trước khi nhảy tới nó.

Kiến trúc có thể không phải lúc nào cũng có khả năng giải phóng các chuỗi như vậy, chẳng hạn như khi
ftrace_return_to_handler() đã xóa địa chỉ khỏi cur_ret_stack và
vị trí của địa chỉ trả lại không thể được xác định một cách đáng tin cậy.

Kiến trúc nên giải quyết các trường hợp return_to_handler có
chưa được trả lại, nhưng các kiến trúc không bắt buộc phải thoát ra khỏi
ở giữa return_to_handler và có thể báo cáo điều này là không đáng tin cậy. Kiến trúc
không bắt buộc phải bung ra khỏi các tấm bạt lò xo khác làm thay đổi lợi nhuận
địa chỉ.

4.5 Che giấu địa chỉ trả lại
---------------------------------

Một số tấm bạt lò xo không viết lại địa chỉ trả lại để chặn
trả về, nhưng tạm thời ghi đè địa chỉ trả lại hoặc trạng thái thư giãn khác.

Ví dụ: việc triển khai x86_64 của optprobe sẽ vá chức năng được thăm dò
với lệnh JMP nhắm vào tấm bạt lò xo thăm dò quang liên quan. Khi nào
đầu dò bị tấn công, CPU sẽ phân nhánh tới tấm bạt lò xo optprobe và
địa chỉ của hàm được thăm dò không được giữ trong bất kỳ thanh ghi nào hoặc trên ngăn xếp.

Tương tự, việc triển khai arm64 của các bản vá DYNAMIC_FTRACE_WITH_REGS được theo dõi
có chức năng như sau:

.. code-block:: none

   MOV X9, X30
   BL <trampoline>

MOV lưu thanh ghi liên kết (X30) vào X9 để giữ địa chỉ trả về
trước khi BL chặn thanh ghi liên kết và phân nhánh tới tấm bạt lò xo. Tại
bắt đầu tấm bạt lò xo, địa chỉ của chức năng truy tìm nằm ở X9
hơn thanh ghi liên kết như thường lệ.

Kiến trúc phải đảm bảo rằng bộ tháo cuộn có thể được tháo ra một cách đáng tin cậy
những trường hợp như vậy, hoặc báo cáo việc tháo gỡ là không đáng tin cậy.

4.6 Liên kết đăng ký không đáng tin cậy
-------------------------------

Trên một số kiến trúc khác, lệnh 'gọi' đặt địa chỉ trả về vào một
thanh ghi liên kết và lệnh 'return' sử dụng địa chỉ trả về từ
liên kết đăng ký mà không sửa đổi đăng ký. Trên các phần mềm kiến trúc này
phải lưu địa chỉ trả về vào ngăn xếp trước khi thực hiện lệnh gọi hàm. Kết thúc
trong suốt thời gian của một lệnh gọi hàm, địa chỉ trả về có thể được giữ trong liên kết
đăng ký một mình, một mình trên ngăn xếp hoặc ở cả hai vị trí.

Người giải nén thường cho rằng thanh ghi liên kết luôn hoạt động, nhưng điều này
giả định có thể dẫn đến dấu vết ngăn xếp không đáng tin cậy. Ví dụ, hãy xem xét
lắp ráp arm64 sau đây cho một chức năng đơn giản:

.. code-block:: none

   function:
           STP X29, X30, [SP, -16]!
           MOV X29, SP
           BL <other_function>
           LDP X29, X30, [SP], #16
           RET

Khi vào hàm, thanh ghi liên kết (x30) trỏ đến người gọi và
con trỏ khung (X29) trỏ tới khung của người gọi bao gồm cả sự quay lại của người gọi
địa chỉ. Hai lệnh đầu tiên tạo một stackframe mới và cập nhật
con trỏ khung, và tại thời điểm này cả thanh ghi liên kết và con trỏ khung đều
mô tả địa chỉ trả về của hàm này. Một dấu vết tại thời điểm này có thể mô tả
hàm này hai lần và nếu hàm trả về đang được theo dõi, trình tháo gỡ
có thể sử dụng hai mục từ ngăn xếp trả về của biểu đồ thay vì một mục nhập.

BL gọi 'other_function' với thanh ghi liên kết trỏ đến đây
LDR của hàm và con trỏ khung trỏ tới khung ngăn xếp của hàm này.
Khi 'other_function' trả về, thanh ghi liên kết sẽ trỏ vào BL,
và do đó, dấu vết tại thời điểm này có thể dẫn đến 'hàm' xuất hiện hai lần trong
dấu vết ngược lại.

Tương tự, một chức năng có thể cố tình chặn LR, ví dụ:

.. code-block:: none

   caller:
           STP X29, X30, [SP, -16]!
           MOV X29, SP
           ADR LR, <callee>
           BLR LR
           LDP X29, X30, [SP], #16
           RET

ADR đặt địa chỉ của 'callee' vào LR, trước khi BLR phân nhánh tới
địa chỉ này. Nếu dấu vết được thực hiện ngay sau ADR, 'callee' sẽ
dường như là cha mẹ của 'người gọi', chứ không phải là đứa trẻ.

Do những trường hợp như trên, chỉ có thể tiêu thụ một cách đáng tin cậy một
giá trị thanh ghi liên kết tại ranh giới lệnh gọi hàm. Kiến trúc nơi đây
trường hợp phải từ chối việc tháo gỡ qua các ranh giới ngoại lệ trừ khi họ có thể
xác định một cách đáng tin cậy khi nào nên sử dụng giá trị LR hoặc ngăn xếp (ví dụ: sử dụng
siêu dữ liệu được tạo bởi objtool).
