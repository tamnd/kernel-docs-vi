.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/cpuid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Các bit KVM CPUID
=================

:Tác giả: Glauber Costa <glommer@gmail.com>

Một khách đang chạy trên máy chủ kvm, có thể kiểm tra một số tính năng của nó bằng cách sử dụng
cpuid. Điều này không phải lúc nào cũng được đảm bảo hoạt động vì không gian người dùng có thể
che giấu một số hoặc thậm chí tất cả các tính năng cpuid liên quan đến KVM trước khi khởi chạy
một vị khách.

Các chức năng cpuid của KVM là:

chức năng: KVM_CPUID_SIGNATURE (0x40000000)

trả về::

eax = 0x40000001
   ebx = 0x4b4d564b
   ecx = 0x564b4d56
   edx = 0x4d

Lưu ý rằng giá trị này trong ebx, ecx và edx tương ứng với chuỗi "KVMKVMKVM".
Giá trị trong eax tương ứng với hàm cpuid tối đa có trong lá này,
và sẽ được cập nhật nếu có thêm nhiều chức năng hơn trong tương lai.
Cũng lưu ý rằng các máy chủ cũ đặt giá trị eax thành 0x0. Điều này nên
được hiểu như thể giá trị là 0x40000001.
Hàm này truy vấn sự hiện diện của các lá cpuid KVM.

chức năng: xác định KVM_CPUID_FEATURES (0x40000001)

trả về::

ebx, ecx
          eax = một nhóm OR'ed của (cờ 1 <<)

trong đó ZZ0000ZZ được định nghĩa như sau:

============================================== ====================================
ý nghĩa giá trị cờ
============================================== ====================================
KVM_FEATURE_CLOCKSOURCE 0 kvmclock có sẵn tại msrs
                                               0x11 và 0x12

KVM_FEATURE_NOP_IO_DELAY 1 không cần thiết để thực hiện độ trễ
                                               về hoạt động PIO

KVM_FEATURE_MMU_OP 2 không được dùng nữa

KVM_FEATURE_CLOCKSOURCE2 3 kvmclock có sẵn tại msrs
                                               0x4b564d00 và 0x4b564d01

KVM_FEATURE_ASYNC_PF 4 async pf có thể được kích hoạt bởi
                                               viết thư cho msr 0x4b564d02

Thời gian đánh cắp KVM_FEATURE_STEAL_TIME 5 có thể được kích hoạt bởi
                                               viết thư cho msr 0x4b564d03

KVM_FEATURE_PV_EOI 6 kết thúc ngắt ảo hóa
                                               trình xử lý có thể được kích hoạt bởi
                                               viết thư cho msr 0x4b564d04

KVM_FEATURE_PV_UNHALT 7 khách kiểm tra tính năng này chút
                                               trước khi kích hoạt ảo hóa song song
                                               hỗ trợ spinlock

KVM_FEATURE_PV_TLB_FLUSH 9 khách kiểm tra tính năng này chút
                                               trước khi kích hoạt ảo hóa song song
                                               tlb tuôn ra

KVM_FEATURE_ASYNC_PF_VMEXIT 10 PF VM không đồng bộ ảo hóa song song EXIT
                                               có thể được kích hoạt bằng cách cài đặt bit 2
                                               khi ghi vào msr 0x4b564d02

KVM_FEATURE_PV_SEND_IPI 11 khách kiểm tra tính năng này chút
                                               trước khi kích hoạt ảo hóa song song
                                               gửi IPI

KVM_FEATURE_POLL_CONTROL 12 có thể bỏ phiếu phía máy chủ trên HLT
                                               bị vô hiệu hóa bằng cách viết
                                               tới msr 0x4b564d05.

KVM_FEATURE_PV_SCHED_YIELD 13 khách kiểm tra tính năng này chút
                                               trước khi sử dụng ảo hóa
                                               sản lượng theo kế hoạch.

KVM_FEATURE_ASYNC_PF_INT 14 khách kiểm tra tính năng này chút
                                               trước khi sử dụng async thứ hai
                                               điều khiển pf msr 0x4b564d06 và
                                               msr xác nhận pf không đồng bộ
                                               0x4b564d07.

KVM_FEATURE_MSI_EXT_DEST_ID 15 khách kiểm tra tính năng này chút
                                               trước khi sử dụng đích mở rộng
                                               Các bit ID trong các bit địa chỉ MSI 11-5.

KVM_FEATURE_HC_MAP_GPA_RANGE 16 khách kiểm tra tính năng này trước
                                               sử dụng hypercall phạm vi gpa của bản đồ
                                               để thông báo thay đổi trạng thái trang

KVM_FEATURE_MIGRATION_CONTROL 17 khách kiểm tra tính năng này trước
                                               sử dụng MSR_KVM_MIGRATION_CONTROL

Máy chủ KVM_FEATURE_CLOCKSOURCE_STABLE_BIT 24 sẽ cảnh báo nếu không có phía khách
                                               hiện tượng cong vênh trên mỗi CPU được mong đợi trong
                                               kvmclock
============================================== ====================================

::

edx = một nhóm OR'ed của (1 << cờ)

Trong đó ZZ0000ZZ ở đây được định nghĩa như sau:

====================================================================
ý nghĩa giá trị cờ
====================================================================
KVM_HINTS_REALTIME 0 khách kiểm tra tính năng này để
                                xác định rằng vCPU không bao giờ
                                được ưu tiên trong thời gian không giới hạn
                                cho phép tối ưu hóa
====================================================================