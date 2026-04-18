.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/errata.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Những hạn chế đã biết của ảo hóa CPU
==========================================

Bất cứ khi nào việc mô phỏng hoàn hảo tính năng CPU là không thể hoặc quá khó, KVM
phải lựa chọn giữa việc không triển khai tính năng nào cả hoặc giới thiệu
sự khác biệt về hành vi giữa máy ảo và hệ thống kim loại trần.

Tệp này ghi lại một số hạn chế đã biết mà KVM có trong
ảo hóa các tính năng CPU.

x86
===

Sự cố ZZ0000ZZ
----------------------------------

tính năng x87
~~~~~~~~~~~~~

Không giống như hầu hết các bit tính năng CPUID khác, CPUID[EAX=7,ECX=0]:EBX[6]
(FDP_EXCPTN_ONLY) và CPUID[EAX=7,ECX=0]:EBX]13] (ZERO_FCS_FDS) là
rõ ràng nếu các tính năng có mặt và được đặt nếu các tính năng không có.

Việc xóa các bit này trong CPUID không ảnh hưởng đến hoạt động của khách;
nếu các bit này được đặt trên phần cứng thì các tính năng sẽ không xuất hiện trên
bất kỳ máy ảo nào chạy trên phần cứng đó.

ZZ0001ZZ Bạn nên luôn đặt các bit này trong CPUID khách.
Tuy nhiên, xin lưu ý rằng bất kỳ phần mềm nào (ví dụ ZZ0000ZZ) đều mong đợi các tính năng này
hiện diện có thể có trước các bit tính năng CPUID này và do đó
dù sao cũng không biết kiểm tra chúng.

Sự cố ZZ0000ZZ
-----------------------------

Đầu vào KVM_SET_VCPU_EVENTS không hợp lệ liên quan đến mã lỗi ZZ0000ZZ dẫn đến
VM-Entry không thành công trên CPU Intel.  CPU Intel trước CET yêu cầu ngoại lệ đó
tiêm qua VMCS đặt chính xác cờ "mã lỗi hợp lệ", ví dụ:
yêu cầu đặt cờ khi tiêm #GP, xóa khi tiêm #UD,
rõ ràng khi tiêm một ngoại lệ mềm, v.v. CPU Intel liệt kê
IA32_VMX_BASIC[56] dưới dạng '1' giúp thư giãn việc kiểm tra tính nhất quán của VMX và CPU AMD không có
hạn chế nào cả.  KVM_SET_VCPU_EVENTS không kiểm tra vector một cách tỉnh táo
so với "has_error_code", tức là ABI của KVM tuân theo hành vi của AMD.

Các tính năng ảo hóa lồng nhau
------------------------------

Trên CPU AMD, khi GIF bị xóa, các ngoại lệ hoặc bẫy #DB do điểm dừng
kết quả đăng ký bị CPU bỏ qua và loại bỏ. CPU dựa trên VMM
để ảo hóa hoàn toàn hành vi này, ngay cả khi vGIF được bật cho khách
(tức là vGIF=0 không làm cho CPU rớt #DBs khi khách đang chạy).
KVM không ảo hóa hành vi này vì độ phức tạp không được chứng minh
sự hiếm có của trường hợp sử dụng. Một cách để giải quyết vấn đề này là KVM
chặn #DB, tạm thời vô hiệu hóa điểm dừng, thực hiện một bước qua
hướng dẫn, sau đó kích hoạt lại điểm dừng.

x2APIC
------
Khi KVM_X2APIC_API_USE_32BIT_IDS được bật, KVM sẽ kích hoạt hack/quirk
cho phép gửi sự kiện tới một vCPU bằng ID x2APIC của nó ngay cả khi mục tiêu
vCPU đã bật xAPIC cũ, ví dụ: để hiển thị các vCPU được cắm nóng qua INIT-SIPI
trên máy ảo có > 255 vCPU.  Một tác dụng phụ của vấn đề này là nếu có nhiều vCPU
có cùng ID APIC vật lý, KVM sẽ phân phối các sự kiện nhắm mục tiêu ID APIC đó
chỉ tới vCPU có ID vCPU thấp nhất.  Nếu KVM_X2APIC_API_USE_32BIT_IDS là
không được bật, KVM tuân theo kiến trúc x86 khi xử lý các ngắt (tất cả vCPU
khớp với ID APIC mục tiêu sẽ nhận được ngắt).

MTRR
-----
KVM không ảo hóa các loại bộ nhớ MTRR dành cho khách.  KVM mô phỏng quyền truy cập vào MTRR
MSR, tức là {RD,WR}MSR trong máy khách sẽ hoạt động như mong đợi, nhưng KVM thì không
tôn trọng MTRR của khách khi xác định loại bộ nhớ hiệu quả và thay vào đó
coi tất cả bộ nhớ khách là có MTRR Writeback (WB).

CR0.CD
------
KVM không ảo hóa CR0.CD trên CPU Intel.  Tương tự với MTRR MSRs, KVM
mô phỏng truy cập CR0.CD để tải và lưu trữ từ/đến CR0 hoạt động như
dự kiến, nhưng cài đặt CR0.CD=1 không ảnh hưởng đến khả năng lưu vào bộ nhớ đệm của khách
trí nhớ.

Lưu ý, lỗi này không ảnh hưởng đến CPU AMD, CPU ảo hóa hoàn toàn CR0.CD trong
phần cứng, tức là đặt bộ đệm CPU vào chế độ "không điền" khi CR0.CD=1, ngay cả khi
chạy trong khách.