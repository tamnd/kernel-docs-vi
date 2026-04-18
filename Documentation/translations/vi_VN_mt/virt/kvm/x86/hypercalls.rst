.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/hypercalls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Siêu cuộc gọi Linux KVM
===================

X86:
 KVM Hypercall có chuỗi ba byte của vmcall hoặc vmmcall
 hướng dẫn. Trình ảo hóa có thể thay thế nó bằng các hướng dẫn
 đảm bảo được hỗ trợ.

Tối đa bốn đối số có thể được truyền lần lượt trong rbx, RCx, rdx và rsi.
 Số siêu cuộc gọi phải được đặt trong rax và giá trị trả về sẽ là
 được đặt trong rax.  Không có sổ đăng ký nào khác sẽ bị ghi đè trừ khi được nêu rõ ràng
 bởi hypercall cụ thể.

S390:
  R2-R7 được sử dụng cho các tham số 1-6. Ngoài ra, R1 còn được sử dụng cho hypercall
  số. Giá trị trả về được ghi vào R2.

S390 sử dụng lệnh chẩn đoán dưới dạng hypercall (0x500) cùng với hypercall
  số trong R1.

Để biết thêm thông tin về cuộc gọi chẩn đoán S390 được KVM hỗ trợ,
  tham khảo Tài liệu/virt/kvm/s390/s390-diag.rst.

PowerPC:
  Nó sử dụng R3-R10 và số siêu cuộc gọi trong R11. R4-R11 được sử dụng làm thanh ghi đầu ra.
  Giá trị trả về được đặt trong R3.

Siêu lệnh gọi KVM sử dụng mã opcode 4 byte, được vá bằng 'hướng dẫn siêu lệnh'
  thuộc tính bên trong nút /hypervisor của cây thiết bị.
  Để biết thêm thông tin, hãy tham khảo Tài liệu/virt/kvm/ppc-pv.rst

MIPS:
  Siêu cuộc gọi KVM sử dụng lệnh HYPCALL với mã 0 và siêu cuộc gọi
  số tính bằng $2 (v0). Có thể đặt tối đa bốn đối số trong $4-$7 (a0-a3) và
  giá trị trả về được đặt trong $2 (v0).

Tài liệu về siêu cuộc gọi KVM
============================

Mẫu cho mỗi hypercall là:
1. Tên siêu cuộc gọi.
2. Kiến trúc
3. Trạng thái (không dùng nữa, lỗi thời, đang hoạt động)
4. Mục đích

1. KVM_HC_VAPIC_POLL_IRQ
------------------------

:Kiến trúc: x86
:Trạng thái: đang hoạt động
:Mục đích: Kích hoạt lối thoát của khách để chủ nhà có thể kiểm tra trạng thái chờ xử lý
          gián đoạn khi vào lại.

2. KVM_HC_MMU_OP
----------------

:Kiến trúc: x86
:Trạng thái: không dùng nữa.
:Mục đích: Hỗ trợ các hoạt động của MMU như ghi vào PTE,
          xả TLB, nhả PT.

3. KVM_HC_FEATURES
------------------

:Kiến trúc: PPC
:Trạng thái: đang hoạt động
:Mục đích: Hiển thị tính khả dụng của siêu cuộc gọi cho khách. Trên nền tảng x86, cpuid
          được sử dụng để liệt kê những siêu cuộc gọi nào có sẵn. Trên PPC, hoặc
	  tra cứu dựa trên cây thiết bị (đó cũng là những gì EPAPR ra lệnh)
	  HOẶC cơ chế liệt kê cụ thể KVM (là hypercall này)
	  có thể được sử dụng

4. KVM_HC_PPC_MAP_MAGIC_PAGE
----------------------------

:Kiến trúc: PPC
:Trạng thái: đang hoạt động
: Mục đích: Để cho phép giao tiếp giữa người ảo hóa và khách, có một
	  trang được chia sẻ có chứa các phần của trạng thái đăng ký hiển thị của người giám sát.
	  Khách có thể ánh xạ trang chia sẻ này để truy cập vào sổ đăng ký giám sát của nó
	  thông qua bộ nhớ bằng cách sử dụng hypercall này.

5. KVM_HC_KICK_CPU
------------------

:Kiến trúc: x86
:Trạng thái: đang hoạt động
:Mục đích: Hypercall dùng để đánh thức vcpu từ trạng thái HLT
:Ví dụ sử dụng:
  Một vcpu của một vị khách ảo hóa đang bận chờ đợi trong khách
  chế độ kernel để một sự kiện xảy ra (ví dụ: một spinlock khả dụng) có thể
  thực hiện lệnh HLT khi nó đã bận chờ hơn một ngưỡng
  khoảng thời gian. Việc thực thi lệnh HLT sẽ khiến trình ảo hóa đặt
  vcpu chuyển sang chế độ ngủ cho đến khi xảy ra sự kiện thích hợp. Một vcpu khác của
  cùng một vị khách có thể đánh thức vcpu đang ngủ bằng cách phát ra siêu lệnh KVM_HC_KICK_CPU,
  chỉ định ID APIC (a1) của vcpu sẽ được đánh thức. Một đối số bổ sung (a0)
  được sử dụng trong hypercall để sử dụng trong tương lai.


6. KVM_HC_CLOCK_PAIRING
-----------------------
:Kiến trúc: x86
:Trạng thái: đang hoạt động
:Mục đích: Hypercall dùng để đồng bộ đồng hồ máy chủ và máy khách.

Cách sử dụng:

a0: địa chỉ vật lý của khách nơi lưu trữ bản sao
Cấu trúc "struct kvm_clock_offset".

a1: clock_type, ATM chỉ KVM_CLOCK_PAIRING_WALLCLOCK (0)
được hỗ trợ (tương ứng với đồng hồ CLOCK_REALTIME của máy chủ).

       ::

cấu trúc kvm_clock_pairing {
			__s64 giây;
			__s64 nsec;
			__u64 tsc;
			__u32 cờ;
			__u32 đệm[9];
		};

Ở đâu:
               * sec: giây từ đồng hồ clock_type.
               * nsec: nano giây tính từ đồng hồ clock_type.
               * tsc: giá trị TSC của khách dùng để tính cặp giây/nsec
               * flags: cờ, hiện tại chưa được sử dụng (0).

Hypercall cho phép khách tính toán dấu thời gian chính xác trên
chủ và khách.  Khách có thể sử dụng giá trị TSC được trả về để
tính toán CLOCK_REALTIME cho đồng hồ của nó ngay lập tức.

Trả về KVM_EOPNOTSUPP nếu máy chủ không sử dụng nguồn xung nhịp TSC,
hoặc nếu loại đồng hồ khác với KVM_CLOCK_PAIRING_WALLCLOCK.

7. KVM_HC_SEND_IPI
------------------

:Kiến trúc: x86
:Trạng thái: đang hoạt động
:Mục đích: Gửi IPI tới nhiều vCPU.

- a0: phần dưới của bitmap của ID APIC đích
- a1: phần cao hơn của bitmap của ID APIC đích
- a2: ID APIC thấp nhất trong bitmap
- a3: APIC ICR

Hypercall cho phép khách gửi IP multicast, với tối đa 128
128 điểm đích cho mỗi siêu cuộc gọi ở chế độ 64 bit và 64 vCPU mỗi
hypercall ở chế độ 32-bit.  Các điểm đến được thể hiện bằng một
bitmap chứa trong hai đối số đầu tiên (a0 và a1). Bit 0 của
a0 tương ứng với ID APIC trong đối số thứ ba (a2), bit 1
tương ứng với APIC ID a2+1, v.v.

Trả về số lượng CPU mà IPI đã được phân phối thành công.

8. KVM_HC_SCHED_YIELD
---------------------

:Kiến trúc: x86
:Trạng thái: đang hoạt động
:Mục đích: Hypercall được sử dụng để mang lại nếu vCPU mục tiêu IPI bị chiếm trước

a0: ID APIC đích

:Ví dụ về cách sử dụng: Khi gửi hàm gọi IPI-many tới vCPU, hãy mang lại nếu
	        bất kỳ vCPU mục tiêu IPI nào đều được ưu tiên.

9. KVM_HC_MAP_GPA_RANGE
-------------------------
:Kiến trúc: x86
:Trạng thái: đang hoạt động
:Mục đích: Yêu cầu KVM ánh xạ phạm vi GPA với các thuộc tính được chỉ định.

a0: địa chỉ vật lý của khách của trang bắt đầu
a1: số trang (4kb) (phải liền nhau trong không gian GPA)
a2: thuộc tính

Trong đó 'thuộc tính':
        * bit 3:0 - mã hóa kích thước trang ưa thích 0 = 4kb, 1 = 2mb, 2 = 1gb, v.v...
        * bit 4 - bản rõ = 0, mã hóa = 1
        * bit 63:5 - dành riêng (phải bằng 0)

ZZ0000ZZ: siêu cuộc gọi này được triển khai trong không gian người dùng thông qua
khả năng KVM_CAP_EXIT_HYPERCALL. Không gian người dùng phải kích hoạt khả năng đó
trước khi quảng cáo KVM_FEATURE_HC_MAP_GPA_RANGE trong CPUID của khách.  trong
Ngoài ra, nếu khách hỗ trợ KVM_FEATURE_MIGRATION_CONTROL, không gian người dùng
cũng phải thiết lập bộ lọc MSR để xử lý việc ghi vào MSR_KVM_MIGRATION_CONTROL.