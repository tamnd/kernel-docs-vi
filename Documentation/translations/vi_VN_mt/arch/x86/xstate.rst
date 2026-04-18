.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/xstate.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Sử dụng các tính năng XSTATE trong các ứng dụng không gian người dùng
================================================

Kiến trúc x86 hỗ trợ các phần mở rộng dấu phẩy động
được liệt kê thông qua CPUID. Ứng dụng tham khảo CPUID và sử dụng XGETBV để
đánh giá những tính năng nào đã được kích hoạt bởi kernel XCR0.

Lên đến trạng thái AVX-512 và PKRU, các tính năng này được bật tự động bởi
hạt nhân nếu có. Các tính năng như AMX TILE_DATA (XSTATE thành phần 18)
cũng được kích hoạt bởi XCR0, nhưng việc sử dụng lệnh liên quan đầu tiên là
bị kernel giữ lại vì theo mặc định, bộ đệm XSTATE lớn cần thiết
không được phân bổ tự động.

Mục đích của các tính năng động
--------------------------------

Các thư viện không gian người dùng cũ thường có kích thước tĩnh, được mã hóa cứng cho
ngăn xếp tín hiệu thay thế, thường sử dụng MINSIGSTKSZ, thường là 2KB.
Ngăn xếp đó phải có khả năng lưu trữ tại ZZ0000ZZ khung tín hiệu mà
kernel thiết lập trước khi chuyển sang bộ xử lý tín hiệu. Khung tín hiệu đó
phải bao gồm bộ đệm XSAVE được xác định bởi CPU.

Tuy nhiên, điều đó có nghĩa là kích thước của ngăn xếp tín hiệu là động chứ không phải tĩnh,
bởi vì các CPU khác nhau có bộ đệm XSAVE có kích thước khác nhau. Một bản biên soạn sẵn
kích thước 2KB với các ứng dụng hiện có là quá nhỏ đối với các tính năng CPU mới
như AMX. Thay vì yêu cầu ngăn xếp lớn hơn một cách phổ biến, với tính năng động
cho phép, kernel có thể buộc các ứng dụng trong không gian người dùng phải có
các ngăn xếp có kích thước phù hợp.

Sử dụng các tính năng XSTATE được kích hoạt động trong các ứng dụng không gian người dùng
--------------------------------------------------------------------

Hạt nhân cung cấp cơ chế dựa trên Arch_prctl(2) cho các ứng dụng
yêu cầu sử dụng các tính năng đó. Các tùy chọn Arch_prctl(2) liên quan đến
đây là:

-ARCH_GET_XCOMP_SUPP

Arch_prctl(ARCH_GET_XCOMP_SUPP, &tính năng);

ARCH_GET_XCOMP_SUPP lưu trữ các tính năng được hỗ trợ trong bộ nhớ không gian người dùng của
 gõ uint64_t. Đối số thứ hai là một con trỏ tới bộ lưu trữ đó.

-ARCH_GET_XCOMP_PERM

Arch_prctl(ARCH_GET_XCOMP_PERM, &tính năng);

ARCH_GET_XCOMP_PERM lưu trữ các tính năng mà quá trình xử lý không gian người dùng
 có quyền lưu trữ vùng người dùng thuộc loại uint64_t. Đối số thứ hai
 là một con trỏ tới bộ lưu trữ đó.

-ARCH_REQ_XCOMP_PERM

Arch_prctl(ARCH_REQ_XCOMP_PERM, feature_nr);

ARCH_REQ_XCOMP_PERM cho phép yêu cầu quyền kích hoạt động
 tính năng hoặc một bộ tính năng. Một bộ tính năng có thể được ánh xạ tới một cơ sở, ví dụ:
 AMX và có thể yêu cầu bật một hoặc nhiều thành phần XSTATE.

Đối số tính năng là số lượng thành phần XSTATE cao nhất
 là cần thiết để cơ sở hoạt động.

Khi yêu cầu quyền cho một tính năng, kernel sẽ kiểm tra
sự sẵn có. Hạt nhân đảm bảo rằng các sigaltstacks trong các tác vụ của tiến trình
đủ lớn để chứa khung tín hiệu lớn thu được. Nó
thực thi điều này cả trong ARCH_REQ_XCOMP_SUPP và trong bất kỳ lần tiếp theo nào
sigaltstack(2) cuộc gọi. Nếu sigaltstack được cài đặt nhỏ hơn
tạo ra kích thước sigframe, ARCH_REQ_XCOMP_SUPP cho kết quả -ENOSUPP. Ngoài ra,
sigaltstack(2) dẫn đến -ENOMEM nếu altstack được yêu cầu quá nhỏ
đối với các tính năng được phép.

Quyền, khi được cấp, có giá trị cho mỗi quy trình. Quyền được kế thừa
trên fork(2) và bị xóa trên exec(3).

Việc sử dụng lệnh đầu tiên liên quan đến tính năng được kích hoạt động là
bị mắc kẹt bởi hạt nhân. Trình xử lý bẫy kiểm tra xem quy trình có
quyền sử dụng tính năng này. Nếu quá trình không có sự cho phép thì
kernel gửi SIGILL tới ứng dụng. Nếu quá trình có sự cho phép thì
trình xử lý phân bổ bộ đệm xstate lớn hơn cho tác vụ sao cho kích thước lớn
trạng thái có thể được chuyển đổi ngữ cảnh. Trong những trường hợp hiếm hoi việc phân bổ
không thành công, kernel sẽ gửi SIGSEGV.

Ví dụ về kích hoạt AMX TILE_DATA
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Dưới đây là ví dụ về cách kích hoạt các ứng dụng không gian người dùng
TILE_DATA động:

1. Trước tiên, ứng dụng cần truy vấn kernel để tìm AMX
     hỗ trợ::

#include <asm/prctl.h>
        #include <sys/syscall.h>
        #include <stdio.h>
        #include <unistd.h>

#ifndef ARCH_GET_XCOMP_SUPP
        #define ARCH_GET_XCOMP_SUPP 0x1021
        #endif

#ifndef ARCH_XCOMP_TILECFG
        #define ARCH_XCOMP_TILECFG 17
        #endif

#ifndef ARCH_XCOMP_TILEDATA
        #define ARCH_XCOMP_TILEDATA 18
        #endif

#define MASK_XCOMP_TILE ((1 << ARCH_XCOMP_TILECFG) | \
                                      (1 << ARCH_XCOMP_TILEDATA))

tính năng dài không dấu;
        RC dài;

        ...

rc = syscall(SYS_arch_prctl, ARCH_GET_XCOMP_SUPP, &features);

if (!rc && (tính năng & MASK_XCOMP_TILE) == MASK_XCOMP_TILE)
            printf("AMX có sẵn.\n");

2. Sau đó, khi xác định hỗ trợ cho AMX, ứng dụng phải
     yêu cầu quyền sử dụng nó một cách rõ ràng::

#ifndef ARCH_REQ_XCOMP_PERM
        #define ARCH_REQ_XCOMP_PERM 0x1023
        #endif

        ...

rc = syscall(SYS_arch_prctl, ARCH_REQ_XCOMP_PERM, ARCH_XCOMP_TILEDATA);

nếu (!rc)
            printf("AMX đã sẵn sàng để sử dụng.\n");

Lưu ý ví dụ này không bao gồm việc chuẩn bị sigaltstack.

Tính năng động trong khung tín hiệu
---------------------------------

Các tính năng được kích hoạt động không được ghi vào khung tín hiệu theo tín hiệu
entry nếu tính năng này ở cấu hình ban đầu.  Điều này khác với
các tính năng không động luôn được viết bất kể chúng
cấu hình.  Bộ xử lý tín hiệu có thể kiểm tra XSTATE_BV của bộ đệm XSAVE
trường để xác định xem một tính năng đã được viết hay chưa.

Tính năng động cho máy ảo
-------------------------------------

Quyền đối với thành phần trạng thái khách cần được quản lý riêng
từ máy chủ, vì chúng độc quyền với nhau. Một loạt các tùy chọn
được mở rộng để kiểm soát quyền của khách:

-ARCH_GET_XCOMP_GUEST_PERM

Arch_prctl(ARCH_GET_XCOMP_GUEST_PERM, &tính năng);

ARCH_GET_XCOMP_GUEST_PERM là một biến thể của ARCH_GET_XCOMP_PERM. Vì vậy nó
 cung cấp cùng ngữ nghĩa và chức năng nhưng đối với khách
 thành phần.

-ARCH_REQ_XCOMP_GUEST_PERM

Arch_prctl(ARCH_REQ_XCOMP_GUEST_PERM, feature_nr);

ARCH_REQ_XCOMP_GUEST_PERM là một biến thể của ARCH_REQ_XCOMP_PERM. Nó có
 ngữ nghĩa tương tự cho sự cho phép của khách. Trong khi cung cấp một dịch vụ tương tự
 chức năng, điều này đi kèm với một hạn chế. Quyền bị đóng băng khi
 VCPU đầu tiên được tạo. Mọi nỗ lực thay đổi quyền sau thời điểm đó
 sẽ bị từ chối. Vì vậy, phải xin phép trước khi
 sáng tạo VCPU đầu tiên.

Lưu ý rằng một số VMM có thể đã thiết lập một tập hợp trạng thái được hỗ trợ
thành phần. Các tùy chọn này không được cho là hỗ trợ bất kỳ VMM cụ thể nào.
