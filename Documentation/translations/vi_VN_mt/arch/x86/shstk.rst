.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/shstk.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================
Công nghệ thực thi luồng điều khiển (CET) Shadow Stack
======================================================

Nền CET
==============

Công nghệ thực thi luồng điều khiển (CET) bao gồm một số bộ xử lý x86 có liên quan
các tính năng cung cấp sự bảo vệ chống lại các cuộc tấn công chiếm quyền điều khiển luồng. CET
có thể bảo vệ cả ứng dụng và kernel.

CET giới thiệu ngăn xếp bóng và theo dõi nhánh gián tiếp (IBT). Một ngăn xếp bóng
là ngăn xếp thứ cấp được cấp phát từ bộ nhớ và không thể sửa đổi trực tiếp bằng
ứng dụng. Khi thực hiện lệnh CALL, bộ xử lý sẽ đẩy
trả lại địa chỉ cho cả ngăn xếp bình thường và ngăn xếp bóng. Khi
trả về hàm, bộ xử lý sẽ mở bản sao ngăn xếp bóng và so sánh nó
vào bản sao ngăn xếp thông thường. Nếu hai cái này khác nhau, bộ xử lý sẽ tăng một
lỗi bảo vệ điều khiển. IBT xác minh các mục tiêu CALL/JMP gián tiếp được dự định
được đánh dấu bởi trình biên dịch bằng mã opcode 'ENDBR'. Không phải tất cả CPU đều có cả Shadow
Theo dõi chi nhánh và ngăn xếp gián tiếp. Ngày nay trong kernel 64-bit, chỉ có không gian người dùng
hỗ trợ ngăn xếp bóng và kernel IBT.

Yêu cầu sử dụng Shadow Stack
================================

Để sử dụng ngăn xếp bóng không gian người dùng, bạn cần có CTNH hỗ trợ nó, một kernel
được cấu hình với nó và các thư viện không gian người dùng được biên dịch cùng với nó.

Tùy chọn kernel Kconfig là X86_USER_SHADOW_STACK.  Khi được biên dịch, bóng
ngăn xếp có thể bị vô hiệu hóa khi chạy với tham số kernel: nousershstk.

Để xây dựng kernel hỗ trợ ngăn xếp bóng người dùng, Binutils v2.29 hoặc LLVM v6 trở lên
được yêu cầu.

Trong thời gian chạy, /proc/cpuinfo hiển thị các tính năng của CET nếu bộ xử lý hỗ trợ
CET. "user_shstk" có nghĩa là ngăn xếp bóng không gian người dùng được hỗ trợ trên hiện tại
hạt nhân và CTNH.

Kích hoạt ứng dụng
====================

Khả năng CET của ứng dụng được đánh dấu trong ghi chú ELF của ứng dụng đó và có thể được xác minh
từ đầu ra readelf/llvm-readelf::

readelf -n <ứng dụng> | grep -a SHSTK
        thuộc tính: tính năng x86: SHSTK

Hạt nhân không xử lý trực tiếp các dấu hiệu ứng dụng này. Ứng dụng
hoặc trình tải phải kích hoạt các tính năng CET bằng giao diện được mô tả trong phần 4.
Thông thường, điều này sẽ được thực hiện trong các đối tượng trình tải động hoặc thời gian chạy tĩnh, cũng như
trường hợp trong GLIBC.

Kích hoạt Arch_prctl()'s
=======================

Các tính năng của Elf phải được trình tải kích hoạt bằng cách sử dụng Arch_prctl's bên dưới. Họ
chỉ được hỗ trợ trong các ứng dụng người dùng 64 bit. Chúng hoạt động trên các tính năng
trên cơ sở mỗi luồng. Trạng thái kích hoạt được kế thừa trên bản sao, vì vậy nếu
tính năng được bật trên luồng đầu tiên, nó sẽ lan truyền tới tất cả các luồng
trong một ứng dụng.

Arch_prctl(ARCH_SHSTK_ENABLE, tính năng dài không dấu)
    Kích hoạt một tính năng duy nhất được chỉ định trong 'tính năng'. Chỉ có thể hoạt động trên
    một tính năng tại một thời điểm

Arch_prctl(ARCH_SHSTK_DISABLE, tính năng dài không dấu)
    Vô hiệu hóa một tính năng được chỉ định trong 'tính năng'. Chỉ có thể hoạt động trên
    một tính năng tại một thời điểm

Arch_prctl(ARCH_SHSTK_LOCK, tính năng dài không dấu)
    Khóa các tính năng ở trạng thái bật hoặc tắt hiện tại. 'tính năng'
    là một mặt nạ của tất cả các tính năng để khóa. Tất cả các bit được đặt đều được xử lý, các bit không được đặt
    bị bỏ qua. Mặt nạ được ORed với giá trị hiện có. Vì vậy, bất kỳ bit tính năng nào
    đặt ở đây không thể được bật hoặc tắt sau đó.

Arch_prctl(ARCH_SHSTK_UNLOCK, tính năng dài không dấu)
    Mở khóa các tính năng. 'Tính năng' là mặt nạ của tất cả các tính năng cần mở khóa. Tất cả
    các bit đã đặt sẽ được xử lý, các bit chưa đặt sẽ bị bỏ qua. Chỉ hoạt động thông qua ptrace.

Arch_prctl(ARCH_SHSTK_STATUS, địa chỉ dài không dấu)
    Sao chép các tính năng hiện được kích hoạt vào địa chỉ được truyền trong addr. các
    các tính năng được mô tả bằng cách sử dụng các bit được truyền vào các bit khác trong
    'tính năng'.

Các giá trị trả về như sau. Nếu thành công, trả về 0. Nếu có lỗi, không thể
được::

-EPERM nếu bất kỳ tính năng nào được thông qua bị khóa.
        -ENOTSUPP nếu tính năng này không được phần cứng hỗ trợ hoặc
         hạt nhân.
        -EINVAL đối số (tính năng không tồn tại, v.v.)
        -EFAULT nếu không thể sao chép thông tin trở lại vùng người dùng

Các bit của tính năng được hỗ trợ là::

ARCH_SHSTK_SHSTK - Ngăn xếp bóng
    ARCH_SHSTK_WRSS - WRSS

Hiện tại, ngăn xếp bóng và WRSS được hỗ trợ thông qua giao diện này. WRSS
chỉ có thể được bật bằng ngăn xếp bóng và sẽ tự động bị tắt
nếu ngăn xếp bóng bị vô hiệu hóa.

Trạng thái tiến trình
===========
Để kiểm tra xem một ứng dụng có thực sự chạy với ngăn xếp bóng hay không,
người dùng có thể đọc tệp /proc/$PID/status. Nó sẽ báo "wrss" hoặc "shstk"
tùy thuộc vào những gì được kích hoạt. Các dòng trông như thế này::

x86_Thread_features: shstk wrss
    x86_Thread_features_locked: shstk wrss

Triển khai Shadow Stack
==================================

Kích thước ngăn xếp bóng
-----------------

Ngăn xếp bóng của một tác vụ được phân bổ từ bộ nhớ đến một kích thước cố định là
MIN(RLIMIT_STACK, 4 GB). Nói cách khác, ngăn xếp bóng được phân bổ cho
kích thước tối đa của ngăn xếp thông thường nhưng bị giới hạn ở mức 4 GB. Trong trường hợp
của tòa nhà cao tầng clone3, có kích thước ngăn xếp được truyền vào và ngăn xếp bóng
sử dụng cái này thay vì rlimit.

Tín hiệu
------

Chương trình chính và các bộ xử lý tín hiệu của nó sử dụng cùng một ngăn xếp bóng. Bởi vì
ngăn xếp bóng chỉ lưu trữ địa chỉ trả về, ngăn xếp bóng lớn sẽ bao phủ
điều kiện là cả ngăn xếp chương trình và ngăn xếp tín hiệu thay thế đều chạy
ra ngoài.

Khi có tín hiệu xảy ra, trạng thái tiền tín hiệu cũ sẽ được đẩy lên ngăn xếp. Khi nào
ngăn xếp bóng được bật, trạng thái cụ thể của ngăn xếp bóng được đẩy lên
chồng bóng. Ngày nay đây chỉ là SSP cũ (con trỏ ngăn xếp bóng), được đẩy
ở định dạng đặc biệt với bộ bit 63. Khi sigreturn mã thông báo SSP cũ này là
được xác minh và khôi phục bởi kernel. Kernel cũng sẽ đẩy bình thường
địa chỉ khôi phục vào ngăn xếp bóng để giúp không gian người dùng tránh được ngăn xếp bóng
vi phạm đường dẫn sigreturn đi qua trình khôi phục.

Vì vậy, định dạng khung tín hiệu ngăn xếp bóng như sau ::

ZZ0000ZZ - Con trỏ tới ssp tiền tín hiệu cũ ở định dạng mã thông báo sigframe
                    (bit 63 được đặt thành 1)
    ZZ0001ZZ - Trạng thái khác có thể được thêm vào trong tương lai


Tín hiệu ABI 32 bit không được hỗ trợ trong quy trình ngăn xếp bóng. Linux ngăn chặn
Thực thi 32 bit trong khi ngăn xếp bóng được kích hoạt bằng ngăn xếp bóng phân bổ
bên ngoài không gian địa chỉ 32 bit. Khi thực thi ở chế độ 32 bit,
thông qua cuộc gọi xa hoặc quay lại không gian người dùng, #GP được tạo bởi phần cứng
cái nào sẽ được gửi đến quy trình dưới dạng một segfault. Khi chuyển sang
không gian người dùng, trạng thái của sổ đăng ký sẽ như thể ip không gian người dùng được trả về
gây ra lỗi segfault.

Cái nĩa
----

Vma của ngăn xếp bóng có bộ cờ VM_SHADOW_STACK; PTE của nó là bắt buộc
ở chế độ chỉ đọc và bẩn. Khi ngăn xếp bóng PTE không bị RO và bị bẩn,
quyền truy cập bóng gây ra lỗi trang với bộ bit truy cập ngăn xếp bóng
trong mã lỗi trang.

Khi một tác vụ phân tách một tác vụ con, các PTE ngăn xếp bóng của nó sẽ được sao chép và cả
PTE ngăn xếp bóng của cha mẹ và con cái sẽ bị xóa bit bẩn.
Khi truy cập ngăn xếp bóng tiếp theo, kết quả là lỗi trang ngăn xếp bóng
được xử lý bằng cách sao chép/tái sử dụng trang.

Khi một pthread con được tạo, kernel sẽ phân bổ một ngăn xếp bóng mới
cho chủ đề mới. Việc tạo ngăn xếp bóng mới hoạt động giống như mmap() một cách tôn trọng
đến hành vi ASLR. Tương tự, khi thoát khỏi luồng, ngăn xếp bóng của luồng là
bị vô hiệu hóa.

Thực thi
----

Trên exec, các tính năng của ngăn xếp bóng bị kernel vô hiệu hóa. Tại thời điểm đó,
không gian người dùng có thể chọn bật lại hoặc khóa chúng.