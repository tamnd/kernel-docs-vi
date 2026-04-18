.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/transactional_memory.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
Hỗ trợ bộ nhớ giao dịch
============================

Hỗ trợ kernel POWER cho tính năng này hiện bị giới hạn ở việc hỗ trợ
việc sử dụng nó bởi các chương trình người dùng.  Hiện tại nó không được sử dụng bởi chính kernel.

Tệp này nhằm mục đích tổng hợp cách nó được Linux hỗ trợ và hành vi của bạn.
có thể mong đợi từ các chương trình người dùng của bạn.


Tổng quan cơ bản
==============

Bộ nhớ giao dịch phần cứng được hỗ trợ trên bộ xử lý POWER8 và là một
tính năng cho phép một hình thức truy cập bộ nhớ nguyên tử khác.  Một số mới
hướng dẫn được đưa ra để phân định các giao dịch; giao dịch được
được đảm bảo hoàn thành một cách nguyên tử hoặc quay lại và hoàn tác bất kỳ phần nào
những thay đổi.

Một giao dịch đơn giản trông như thế này::

start_move_money:
    bắt đầu
    beq abort_handler

ld r4, SAVINGS_ACCT(r3)
    ld r5, CURRENT_ACCT(r3)
    subi r5, r5, 1
    thêm r4, r4, 1
    std r4, SAVINGS_ACCT(r3)
    std r5, CURRENT_ACCT(r3)

có khuynh hướng

b tiếp tục

abort_handler:
    ... test for odd failures ...

/* Thử lại giao dịch nếu thất bại do xung đột với
     *người khác: */
    b bắt đầu_di chuyển_tiền


Lệnh 'tbegin' biểu thị điểm bắt đầu và 'tend' điểm kết thúc.
Giữa những điểm này bộ xử lý ở trạng thái 'Giao dịch'; bất kỳ kỷ niệm nào
các tài liệu tham khảo sẽ hoàn thành trong một lần nếu không có xung đột với các tham chiếu khác
truy cập giao dịch hoặc phi giao dịch trong hệ thống.  Trong này
ví dụ: giao dịch hoàn thành như thể nó là mã đường thẳng thông thường
NẾU không có bộ xử lý nào khác chạm vào SAVINGS_ACCT(r3) hoặc CURRENT_ACCT(r3); một
việc chuyển tiền nguyên tử từ tài khoản vãng lai sang tài khoản tiết kiệm đã được thực hiện
được thực hiện.  Mặc dù các lệnh ld/std bình thường được sử dụng (lưu ý không
lwarx/stwcx), ZZ0000ZZ SAVINGS_ACCT(r3) và CURRENT_ACCT(r3) sẽ là
được cập nhật hoặc không cái nào sẽ được cập nhật.

Trong khi chờ đợi, nếu có xung đột với các vị trí được truy cập bởi
giao dịch, giao dịch sẽ bị CPU hủy bỏ.  Đăng ký và bộ nhớ
trạng thái sẽ quay trở lại trạng thái 'bắt đầu' và việc kiểm soát sẽ tiếp tục từ
'bắt đầu+4'.  Nhánh abort_handler sẽ được thực hiện lần thứ hai; cái
trình xử lý hủy bỏ có thể kiểm tra nguyên nhân lỗi và thử lại.

Các thanh ghi điểm kiểm tra bao gồm tất cả các GPR, FPR, VR/VSR, LR, CCR/CR, CTR, FPCSR
và một số quy định trạng thái/cờ khác; xem ISA để biết chi tiết.

Nguyên nhân giao dịch bị hủy
============================

- Xung đột với các dòng bộ đệm được sử dụng bởi các bộ xử lý khác
- Tín hiệu
- Chuyển đổi bối cảnh
- Xem ISA để biết tài liệu đầy đủ về mọi thứ sẽ hủy giao dịch.


tòa nhà chọc trời
========

Các cuộc gọi tòa nhà được thực hiện từ bên trong một giao dịch đang hoạt động sẽ không được thực hiện và
giao dịch sẽ bị hủy bởi kernel với mã lỗi TM_CAUSE_SYSCALL
| TM_CAUSE_PERSISTENT.

Các cuộc gọi hệ thống được thực hiện từ bên trong một giao dịch bị đình chỉ được thực hiện như bình thường và
giao dịch không bị hạt nhân thực hiện một cách rõ ràng.  Tuy nhiên, những gì
kernel thực hiện cuộc gọi hệ thống có thể dẫn đến giao dịch bị hủy
bởi phần cứng.  Tòa nhà được thực hiện ở chế độ treo nên bất kỳ bên nào
các hiệu ứng sẽ kéo dài, không phụ thuộc vào sự thành công hay thất bại của giao dịch.  Không
các đảm bảo được cung cấp bởi kernel về việc các cuộc gọi hệ thống nào sẽ ảnh hưởng đến
giao dịch thành công.

Phải cẩn thận khi dựa vào syscalls để hủy bỏ trong các giao dịch đang hoạt động
nếu cuộc gọi được thực hiện thông qua thư viện.  Thư viện có thể lưu trữ các giá trị (có thể
có vẻ thành công) hoặc thực hiện các hoạt động gây ra giao dịch
lỗi trước khi vào kernel (có thể tạo ra các mã lỗi khác nhau).
Ví dụ như độ phân giải biểu tượng getpid() và lười biếng của glibc.


Tín hiệu
=======

Việc phân phối tín hiệu (cả đồng bộ hóa và không đồng bộ) trong các giao dịch mang lại cơ hội thứ hai
trạng thái luồng (ucontext/mcontext) để thể hiện thanh ghi giao dịch thứ hai
trạng thái.  Việc phân phối tín hiệu 'treclaim' để nắm bắt cả hai trạng thái thanh ghi, do đó tín hiệu
hủy giao dịch.  ucontext_t thông thường được chuyển đến bộ xử lý tín hiệu
đại diện cho trạng thái đăng ký gốc/điểm kiểm tra; tín hiệu dường như có
phát sinh ở 'tbegin+4'.

Nếu ucontext của người thở dài đã được đặt uc_link thì ucontext thứ hai đã được
được giao.  Để tương thích trong tương lai, nên chọn trường MSR.TS để
xác định trạng thái giao dịch -- nếu vậy, ucontext thứ hai trong uc->uc_link
đại diện cho các thanh ghi giao dịch đang hoạt động tại điểm của tín hiệu.

Đối với các quy trình 64 bit, uc->uc_mcontext.regs->msr là MSR 64 bit đầy đủ và TS của nó
trường hiển thị chế độ giao dịch.

Đối với các quy trình 32 bit, thanh ghi MSR của mcontext chỉ có 32 bit; top 32
các bit được lưu trữ trong MSR của ucontext thứ hai, tức là trong
uc->uc_link->uc_mcontext.regs->msr.  Từ trên cùng chứa giao dịch
bang TS.

Tuy nhiên, trình xử lý tín hiệu cơ bản không cần phải biết về các giao dịch
và chỉ cần quay lại từ trình xử lý sẽ giải quyết mọi việc một cách chính xác:

Trình xử lý tín hiệu nhận biết giao dịch có thể đọc trạng thái đăng ký giao dịch
từ ucontext thứ hai.  Điều này sẽ cần thiết cho người xử lý sự cố để
xác định, ví dụ, địa chỉ của lệnh gây ra SIGSEGV.

Trình xử lý tín hiệu ví dụ::

void Crash_handler(int sig, siginfo_t *si, void *uc)
    {
      ucontext_t *ucp = uc;
      ucontext_t *transactional_ucp = ucp->uc_link;

nếu (ucp_link) {
        u64 msr = ucp->uc_mcontext.regs->msr;
        /* Có thể có ucontext giao dịch! */
  #ifndef __powerpc64__
        msr |= ((u64)transactional_ucp->uc_mcontext.regs->msr) << 32;
  #endif
        nếu (MSR_TM_ACTIVE(msr)) {
           /* Có, chúng tôi gặp sự cố trong khi giao dịch.  Ối. */
   fprintf(stderr, "Giao dịch sẽ được khởi động lại ở 0x%llx, nhưng "
                           "hướng dẫn gặp sự cố ở mức 0x%llx\n",
                           ucp->uc_mcontext.regs->nip,
                           giao dịch_ucp->uc_mcontext.regs->nip);
        }
      }

fix_the_problem(ucp->dar);
    }

Khi trong một giao dịch đang hoạt động có tín hiệu, chúng ta cần cẩn thận với
ngăn xếp.  Có thể ngăn xếp đã di chuyển trở lại sau khi bắt đầu.
Trường hợp hiển nhiên ở đây là khi tbegin được gọi bên trong một hàm
trở lại trước một xu hướng.  Trong trường hợp này, ngăn xếp là một phần của điểm kiểm tra
trạng thái bộ nhớ giao dịch.  Nếu chúng tôi viết về điều này không mang tính giao dịch hoặc bằng
tạm dừng, chúng tôi sẽ gặp rắc rối vì nếu chúng tôi bị hủy bỏ tm, bộ đếm chương trình và
con trỏ ngăn xếp sẽ quay trở lại lúc bắt đầu nhưng ngăn xếp trong bộ nhớ của chúng ta sẽ không hợp lệ
nữa.

Để tránh điều này, khi lấy tín hiệu trong một giao dịch đang hoạt động, chúng ta cần sử dụng
con trỏ ngăn xếp từ trạng thái điểm kiểm tra, thay vì trạng thái được suy đoán
trạng thái.  Điều này đảm bảo rằng ngữ cảnh tín hiệu (được viết tm bị đình chỉ) sẽ được
được viết bên dưới ngăn xếp cần thiết cho việc khôi phục.  Giao dịch bị hủy bỏ
bởi vì treclaim, nên bất kỳ ký ức nào được viết giữa tbegin và
tín hiệu sẽ được khôi phục bằng mọi cách.

Đối với các tín hiệu được lấy ở chế độ không phải TM hoặc bị treo, chúng tôi sử dụng
con trỏ ngăn xếp bình thường/không có điểm kiểm tra.

Bất kỳ giao dịch nào được thực hiện bên trong một người thở dài và bị đình chỉ khi hoàn trả
từ người thở dài đến hạt nhân sẽ bị thu hồi và loại bỏ.

Mã nguyên nhân lỗi được kernel sử dụng
==================================

Chúng được định nghĩa trong <asm/reg.h> và phân biệt các lý do khác nhau khiến
kernel đã hủy bỏ một giao dịch:

==========================================================
 Chủ đề TM_CAUSE_RESCHED đã được lên lịch lại.
 TM_CAUSE_TLBI Phần mềm TLB không hợp lệ.
 TM_CAUSE_FAC_UNAV FP/VEC/VSX bẫy không có sẵn.
 TM_CAUSE_SYSCALL Syscall từ giao dịch đang hoạt động.
 Tín hiệu TM_CAUSE_SIGNAL đã được gửi.
 TM_CAUSE_MISC Hiện chưa sử dụng.
 TM_CAUSE_ALIGNMENT Lỗi căn chỉnh.
 TM_CAUSE_EMULATE Thi đua chạm vào bộ nhớ.
 ==========================================================

Những điều này có thể được kiểm tra bởi trình xử lý hủy bỏ của chương trình người dùng dưới dạng TEXASR[0:7].  Nếu
bit 7 được đặt, nó chỉ ra rằng lỗi được coi là liên tục.  Ví dụ
TM_CAUSE_ALIGNMENT sẽ tồn tại lâu dài trong khi TM_CAUSE_RESCHED thì không.

GDB
===

GDB và ptrace hiện không nhận biết được TM.  Nếu một người dừng lại trong một giao dịch,
có vẻ như giao dịch vừa mới bắt đầu (trạng thái điểm kiểm tra là
trình bày).  Giao dịch sau đó không thể được tiếp tục và sẽ thất bại
tuyến đường xử lý.  Hơn nữa, trạng thái đăng ký giao dịch thứ 2 sẽ là
không thể truy cập được.  GDB hiện có thể được sử dụng trên các chương trình sử dụng TM, nhưng không hợp lý
trong các phần trong giao dịch.

POWER9
======

TM trên POWER9 có vấn đề với việc lưu trữ trạng thái đăng ký hoàn chỉnh. Cái này
được mô tả trong cam kết này ::

cam kết 4bb3c7a0208fc13ca70598efd109901a7cd45ae7
    Tác giả: Paul Mackerras <paulus@ozlabs.org>
    Ngày: Thứ Tư ngày 21 tháng 3 21:32:01 2018 +1100
    KVM: PPC: Book3S HV: Khắc phục các lỗi bộ nhớ giao dịch trong POWER9

Để giải thích cho điều này, các chip POWER9 khác nhau đã kích hoạt TM trong
những cách khác nhau.

Trên POWER9N DD2.01 trở xuống, TM bị tắt. tức là
HWCAP2[PPC_FEATURE2_HTM] chưa được đặt.

Trên POWER9N DD2.1 TM được cấu hình bằng chương trình cơ sở để luôn hủy bỏ
giao dịch khi tm đình chỉ xảy ra. Vì vậy tsuspend sẽ gây ra
giao dịch bị hủy bỏ và quay trở lại. Các ngoại lệ hạt nhân cũng sẽ
khiến giao dịch bị hủy bỏ và bị khôi phục và ngoại lệ
sẽ không xảy ra. Nếu không gian người dùng xây dựng một sigcontext cho phép TM
tạm dừng, sigcontext sẽ bị kernel từ chối. Chế độ này là
được quảng cáo tới người dùng có bộ HWCAP2[PPC_FEATURE2_HTM_NO_SUSPEND].
HWCAP2[PPC_FEATURE2_HTM] không được đặt ở chế độ này.

Trên POWER9N DD2.2 trở lên, KVM và POWERVM mô phỏng TM cho khách (như
được mô tả trong cam kết 4bb3c7a0208f), do đó TM được bật cho khách
tức là. HWCAP2[PPC_FEATURE2_HTM] được đặt cho không gian người dùng khách. Khách mà
việc sử dụng nhiều TM đình chỉ (tsuspend hoặc kernel đình chỉ) sẽ dẫn đến
trong bẫy vào bộ ảo hóa và do đó sẽ phải chịu hiệu suất
sự xuống cấp. Không gian người dùng máy chủ đã bị tắt TM
tức là. HWCAP2[PPC_FEATURE2_HTM] chưa được đặt. (mặc dù chúng tôi kích hoạt nó
tại một thời điểm nào đó trong tương lai nếu chúng ta đưa mô phỏng vào máy chủ
chuyển đổi ngữ cảnh không gian người dùng).

POWER9C DD1.2 trở lên chỉ khả dụng với POWERVM và do đó
Linux chỉ chạy với tư cách khách. Trên các hệ thống này TM được mô phỏng giống như trên
POWER9N DD2.2.

Việc di chuyển khách từ POWER8 sang POWER9 sẽ hoạt động với POWER9N DD2.2 và
POWER9C DD1.2. Vì bộ xử lý POWER9 trước đó không hỗ trợ TM
mô phỏng, việc di chuyển từ POWER8 sang POWER9 không được hỗ trợ ở đó.

Triển khai hạt nhân
=====================

h/rfid mtmsrd quirk
-------------------

Như được định nghĩa trong ISA, rfid có một điểm đặc biệt hữu ích trong giai đoạn đầu
xử lý ngoại lệ. Khi trong một giao dịch không gian người dùng và chúng tôi nhập
kernel thông qua một số ngoại lệ, MSR sẽ có kết quả là TM=0 và TS=01 (tức là TM=01
tắt nhưng TM bị đình chỉ). Thông thường kernel sẽ muốn thay đổi các bit trong
MSR và sẽ thực hiện rfid để thực hiện việc này. Trong trường hợp này rfid có thể
có SRR0 TM = 0 và TS = 00 (tức là tắt TM và không giao dịch) và
kết quả là MSR sẽ giữ lại TM = 0 và TS=01 từ trước đó (tức là giữ nguyên
đình chỉ). Đây là một điều kỳ quặc trong kiến trúc vì điều này thường xảy ra
là sự chuyển đổi từ TS=01 sang TS=00 (tức là tạm dừng -> không giao dịch)
đó là một sự chuyển đổi bất hợp pháp.

Điều kỳ lạ này được mô tả về kiến trúc theo định nghĩa của rfid
với những dòng này:

nếu (MSR 29:31 и = 0b010 | SRR1 29:31 и = 0b000) thì
     MSR 29:31 <- SRR1 29:31

hrfid và mtmsrd có cùng một đặc điểm.

Nhân Linux sử dụng tính năng này trong quá trình xử lý ngoại lệ ban đầu của nó.
