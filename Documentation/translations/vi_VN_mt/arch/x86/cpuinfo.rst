.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/cpuinfo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Cờ tính năng x86
===================

Giới thiệu
============

Danh sách các cờ tính năng trong /proc/cpuinfo chưa đầy đủ và
đại diện cho một nỗ lực xấu xa từ lâu nhằm đặt cờ tính năng
ở một nơi dễ tìm cho không gian người dùng.

Tuy nhiên, số lượng cờ tính năng đang tăng lên theo từng thế hệ CPU,
dẫn đến /proc/cpuinfo không thể phân tích cú pháp và khó sử dụng.

Hơn nữa, những cờ tính năng đó thậm chí không cần phải có trong tệp đó
bởi vì không gian người dùng không quan tâm đến chúng - glibc et al đã sử dụng
CPUID để tìm hiểu những gì máy mục tiêu hỗ trợ và những gì không.

Và ngay cả khi nó không hiển thị cờ tính năng cụ thể - mặc dù CPU
vẫn có hỗ trợ cho chức năng phần cứng tương ứng và
cho biết CPU hỗ trợ lỗi CPUID - không gian người dùng có thể chỉ cần thăm dò lỗi
tính năng và tìm hiểu xem nó có được hỗ trợ hay không, bất kể
nó đang được quảng cáo ở đâu đó.

Hơn nữa, những chuỗi cờ đó sẽ trở thành ABI ngay khi chúng xuất hiện
ở đó và duy trì chúng mãi mãi khi không có gì sử dụng chúng là nhiều
của nỗ lực lãng phí.

Vì vậy, việc sử dụng /proc/cpuinfo hiện tại là để hiển thị các tính năng mà
hạt nhân có ZZ0000ZZ và ZZ0001ZZ. Như trong: cờ tính năng CPUID là
ở đó, có một thiết lập bổ sung mà kernel đã thực hiện trong khi
khởi động và chức năng đã sẵn sàng để sử dụng. Một ví dụ hoàn hảo cho
đó là "user_shstk" nơi hỗ trợ mã bổ sung có trong
kernel để hỗ trợ ngăn xếp bóng cho các chương trình người dùng.

Vì vậy, nếu người dùng muốn biết liệu một tính năng có sẵn trên một hệ thống nhất định hay không,
họ cố gắng tìm cờ trong /proc/cpuinfo. Nếu có một lá cờ nhất định,
nó có nghĩa là

* kernel biết về tính năng này đủ để có bit X86_FEATURE

* kernel hỗ trợ nó và hiện đang cung cấp nó cho
  không gian người dùng hoặc một số phần khác của kernel

* nếu cờ đại diện cho một tính năng phần cứng thì phần cứng đó sẽ hỗ trợ nó.

Bản thân việc không có cờ trong /proc/cpuinfo hầu như không có ý nghĩa gì đối với
một người dùng cuối.

Một mặt, một tính năng như "vaes" có thể được cung cấp đầy đủ cho người dùng
các ứng dụng trên kernel chưa được xác định X86_FEATURE_VAES và do đó
không có "vaes" trong /proc/cpuinfo.

Mặt khác, kernel mới chạy trên phần cứng không phải VAES cũng sẽ
không có "vaes" trong /proc/cpuinfo.  Không có cách nào cho một ứng dụng hoặc
người dùng có thể nhận ra sự khác biệt.

Kết quả cuối cùng là trường cờ trong /proc/cpuinfo hơi nhỏ
hữu ích cho việc gỡ lỗi kernel, nhưng không thực sự hữu ích cho bất kỳ mục đích nào khác.
Thay vào đó, các ứng dụng nên sử dụng những thứ như tiện ích glibc cho
truy vấn hỗ trợ CPU.  Người dùng nên dựa vào các công cụ như
công cụ/arch/x86/kcpuid và cpuid(1).

Về việc triển khai, các cờ xuất hiện trong /proc/cpuinfo có
Định nghĩa X86_FEATURE trong Arch/x86/include/asm/cpufeatures.h. Những lá cờ này
đại diện cho các tính năng phần cứng cũng như các tính năng phần mềm.

Nếu kernel quan tâm đến một tính năng hoặc KVM muốn hiển thị tính năng đó
là khách KVM thì chỉ nên đưa nó cho khách khi khách
cần phân tích /proc/cpuinfo. Điều này, như đã đề cập ở trên, rất
khó có thể xảy ra. KVM có thể tổng hợp bit CPUID và khách KVM có thể chỉ cần
truy vấn CPUID và tìm hiểu xem hypervisor hỗ trợ cái gì và cái gì không. Như
đã được nêu rõ, /proc/cpuinfo không phải là bãi rác vô dụng
cờ đặc trưng.


Cờ tính năng được tạo ra như thế nào?
=====================================

Cờ tính năng có thể được lấy từ nội dung của các lá CPUID
--------------------------------------------------------------

Các định nghĩa tính năng này được sắp xếp theo bố cục của CPUID
lá và được nhóm thành các từ có độ lệch như được ánh xạ trong enum cpuid_leafs
trong cpufeatures.h (xem Arch/x86/include/asm/cpufeatures.h để biết chi tiết).
Nếu một đối tượng được xác định bằng định nghĩa X86_FEATURE_<name> trong
cpufeatures.h và nếu nó được phát hiện trong thời gian chạy, các cờ sẽ là
được hiển thị tương ứng trong /proc/cpuinfo. Ví dụ: cờ "avx2"
đến từ X86_FEATURE_AVX2 trong cpufeatures.h.

Cờ có thể từ các tính năng dựa trên CPUID rải rác
-------------------------------------------------

Các tính năng phần cứng được liệt kê trong các lá CPUID dân cư thưa thớt có được
các giá trị do phần mềm xác định. Tuy nhiên, CPUID cần được truy vấn để xác định
nếu một tính năng nhất định có mặt. Việc này được thực hiện trong init_scattered_cpuid_features().
Ví dụ: X86_FEATURE_CQM_LLC được định nghĩa là 11*32 + 0 và sự hiện diện của nó là
được kiểm tra trong thời gian chạy trong lá CPUID tương ứng [EAX=f, ECX=0] bit EDX[1].

Mục đích của việc phân tán lá CPUID là để không làm phồng cấu trúc
cpuinfo_x86.x86_capability[] một cách không cần thiết. Ví dụ: lá CPUID
[EAX=7, ECX=0] có 30 tính năng và dày đặc, nhưng lá CPUID [EAX=7, EAX=1]
chỉ có một tính năng và sẽ lãng phí 31 bit dung lượng trong x86_capability[]
mảng. Vì có một cấu trúc cpuinfo_x86 cho mỗi CPU có thể, nên lãng phí
trí nhớ không hề tầm thường.

Cờ có thể được tạo tổng hợp trong các điều kiện nhất định đối với các tính năng phần cứng
-----------------------------------------------------------------------------------------

Ví dụ về các điều kiện bao gồm liệu các tính năng nhất định có hiện diện trong
MSR_IA32_CORE_CAPS hoặc các mẫu CPU cụ thể được xác định. Nếu cần thiết
điều kiện được đáp ứng, các tính năng được kích hoạt bởi set_cpu_cap hoặc
macro setup_force_cpu_cap. Ví dụ: nếu bit 5 được đặt trong MSR_IA32_CORE_CAPS,
tính năng X86_FEATURE_SPLIT_LOCK_DETECT sẽ được kích hoạt và
"split_lock_Detect" sẽ được hiển thị. Cờ "ring3mwait" sẽ là
chỉ hiển thị khi chạy trên bộ xử lý INTEL_XEON_PHI_[KNL|KNM].

Cờ có thể đại diện cho các tính năng phần mềm thuần túy
-------------------------------------------------------
Những lá cờ này không đại diện cho các tính năng phần cứng. Thay vào đó, họ đại diện cho một
tính năng phần mềm được triển khai trong kernel. Ví dụ: Bảng trang hạt nhân
Cách ly hoàn toàn là tính năng phần mềm và cờ tính năng X86_FEATURE_PTI của nó là
cũng được định nghĩa trong cpufeatures.h.

Đặt tên các lá cờ
=================

Tập lệnh Arch/x86/kernel/cpu/mkcapflags.sh xử lý
#define X86_FEATURE_<name> từ cpufeatures.h và tạo
mảng x86_cap/bug_flags[] trong kernel/cpu/capflags.c. Những cái tên trong
kết quả x86_cap/bug_flags[] được sử dụng để điền vào /proc/cpuinfo. Việc đặt tên
của các cờ trong x86_cap/bug_flags[] như sau:

Cờ không xuất hiện theo mặc định trong /proc/cpuinfo
----------------------------------------------------

Theo mặc định, các cờ tính năng bị bỏ qua khỏi /proc/cpuinfo vì nó không tạo ra
có ý nghĩa để tính năng này được hiển thị trong không gian người dùng trong hầu hết các trường hợp. Ví dụ,
X86_FEATURE_ALWAYS được định nghĩa trong cpufeatures.h nhưng cờ đó là cờ nội bộ
tính năng kernel được sử dụng trong chức năng vá lỗi thời gian chạy thay thế. Vì vậy
cờ không xuất hiện trong /proc/cpuinfo.

Chỉ định tên cờ nếu thực sự cần thiết
----------------------------------------

Nếu nhận xét trên dòng dành cho #define X86_FEATURE_* bắt đầu bằng một
ký tự dấu ngoặc kép (""), chuỗi bên trong ký tự dấu ngoặc kép
sẽ là tên của những lá cờ. Ví dụ: cờ "sse4_1" xuất phát từ
nhận xét "sse4_1" theo định nghĩa X86_FEATURE_XMM4_1.

Có những tình huống trong đó việc ghi đè tên hiển thị của cờ là
cần thiết. Ví dụ: /proc/cpuinfo là giao diện không gian người dùng và phải được giữ nguyên
hằng số. Nếu vì lý do nào đó, việc đặt tên của X86_FEATURE_<name> thay đổi, một
sẽ ghi đè cách đặt tên mới bằng tên đã được sử dụng trong /proc/cpuinfo.

Cờ bị thiếu khi một hoặc nhiều trong số này xảy ra
==================================================

Phần cứng không liệt kê hỗ trợ cho nó
----------------------------------------------

Ví dụ: khi hạt nhân mới đang chạy trên phần cứng cũ hoặc tính năng này bị lỗi
không được kích hoạt bởi phần sụn khởi động. Ngay cả khi phần cứng là mới, vẫn có thể có một
sự cố khi bật tính năng này trong thời gian chạy, cờ sẽ không được hiển thị.

Kernel không biết về cờ
---------------------------------------

Ví dụ: khi kernel cũ đang chạy trên phần cứng mới.

Kernel đã vô hiệu hóa hỗ trợ cho nó tại thời điểm biên dịch
-----------------------------------------------------------

Ví dụ: nếu Mặt nạ địa chỉ tuyến tính (LAM) không được bật khi xây dựng (tức là
CONFIG_ADDRESS_MASKING không được chọn) cờ "lam" sẽ không hiển thị.
Mặc dù tính năng này vẫn được phát hiện qua CPUID nhưng kernel sẽ vô hiệu hóa
nó bằng cách xóa thông qua setup_clear_cpu_cap(X86_FEATURE_LAM).

Tính năng này bị tắt khi khởi động
------------------------------------
Một tính năng có thể bị vô hiệu hóa bằng cách sử dụng tham số dòng lệnh hoặc do
nó không được kích hoạt. Tham số dòng lệnh clearcpuid= có thể được sử dụng
để tắt các tính năng bằng cách sử dụng số tính năng như được xác định trong
/arch/x86/include/asm/cpufeatures.h. Ví dụ: Hướng dẫn chế độ người dùng
Bảo vệ có thể bị vô hiệu hóa bằng cách sử dụng clearcpuid=514. Con số 514 được tính
từ #define X86_FEATURE_UMIP (16*32 + 2).

Ngoài ra, còn tồn tại nhiều tham số dòng lệnh tùy chỉnh
vô hiệu hóa các tính năng cụ thể. Danh sách các tham số bao gồm nhưng không giới hạn
to, nofsgsbase, nosgx, noxsave, v.v. Phân trang 5 cấp cũng có thể bị vô hiệu hóa bằng cách sử dụng
"no5lvl".

Tính năng này được biết là không hoạt động
------------------------------------------

Tính năng này được biết là không hoạt động vì có một phần phụ thuộc
bị thiếu trong thời gian chạy. Ví dụ: cờ AVX sẽ không hiển thị nếu tính năng XSAVE
bị vô hiệu hóa vì chúng phụ thuộc vào tính năng XSAVE. Một ví dụ khác sẽ bị hỏng
CPU và chúng thiếu các bản vá vi mã. Do đó, kernel quyết định không
kích hoạt một tính năng.