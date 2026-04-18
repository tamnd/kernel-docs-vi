.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Tổng quan về khóa KVM
=====================

1. Lệnh mua lại
---------------------

Các đơn đặt hàng mua lại mutexes như sau:

- cpus_read_lock() được đưa ra ngoài kvm_lock

- kvm_usage_lock được đưa ra ngoài cpus_read_lock()

- kvm->lock được đưa ra ngoài vcpu->mutex

- kvm->lock được lấy ra bên ngoài kvm->slots_lock và kvm->irq_lock

- vcpu->mutex được đưa ra ngoài kvm->slots_lock và kvm->slots_arch_lock

- kvm->slots_lock được đưa ra ngoài kvm->irq_lock, mặc dù có được
  chúng cùng nhau là khá hiếm.

- kvm->mn_active_invalidate_count đảm bảo rằng các cặp
  các cuộc gọi lại không hợp lệ_range_start() và không hợp lệ_range_end()
  sử dụng cùng một mảng memslots.  kvm->slots_lock và kvm->slots_arch_lock
  được đưa vào trạng thái chờ khi sửa đổi các khe ghi nhớ, vì vậy trình thông báo MMU
  không được lấy kvm->slots_lock hoặc kvm->slots_arch_lock.

cpus_read_lock() so với kvm_lock:

- Mặc dù vậy, việc đưa cpus_read_lock() ra ngoài kvm_lock là có vấn đề
  là lệnh chính thức, vì nó khá dễ vô tình kích hoạt
  cpus_read_lock() trong khi giữ kvm_lock.  Hãy thận trọng khi đi vm_list,
  ví dụ: tránh các hoạt động phức tạp khi có thể.

Đối với SRCU:

- ZZ0000ZZ được gọi bên trong các phần quan trọng
  cho kvm->lock, vcpu->mutex và kvm->slots_lock.  Những ổ khóa này _không thể_
  được đưa vào bên trong phần quan trọng phía đọc kvm->srcu; nghĩa là,
  sau đây bị hỏng::

srcu_read_lock(&kvm->srcu);
      mutex_lock(&kvm->slots_lock);

- thay vào đó, kvm->slots_arch_lock được giải phóng trước lệnh gọi tới
  ZZ0000ZZ.  Do đó, nó _can_ có thể được đưa vào bên trong một
  kvm->srcu phần quan trọng phía đọc, ví dụ như trong khi xử lý
  một vmexit.

Trên x86:

- vcpu->mutex được đưa ra ngoài kvm->arch.hyperv.hv_lock và kvm->arch.xen.xen_lock

- kvm->arch.mmu_lock là một rwlock; phần quan trọng cho
  kvm->arch.tdp_mmu_pages_lock và kvm->arch.mmu_unsync_pages_lock phải
  cũng lấy kvm->arch.mmu_lock

Mọi thứ khác đều là một chiếc lá: không có khóa nào khác được lấy bên trong phần quan trọng
phần.

2. Ngoại lệ
------------

Lỗi trang nhanh:

Lỗi trang nhanh là đường dẫn nhanh giúp khắc phục lỗi trang khách
khóa mmu trên x86. Hiện tại, lỗi trang có thể xảy ra nhanh ở một trong các
hai trường hợp sau:

1. Theo dõi truy cập: SPTE không có mặt nhưng được đánh dấu để truy cập
   theo dõi. Điều đó có nghĩa là chúng ta cần khôi phục các bit R/X đã lưu. Đây là
   được mô tả chi tiết hơn ở phần sau bên dưới.

2. Bảo vệ ghi: SPTE hiện diện và lỗi xảy ra do
   bảo vệ ghi. Nghĩa là chúng ta chỉ cần thay đổi bit W của spte.

Thứ chúng tôi sử dụng để tránh tất cả các cuộc đua là bit có thể ghi trên máy chủ và bit có thể ghi MMU
trên spte:

- Có thể ghi trên máy chủ có nghĩa là gfn có thể ghi được trong các bảng trang nhân của máy chủ và trong
  khe nhớ KVM của nó.
- MMU-có thể ghi có nghĩa là gfn có thể ghi trong mmu của khách và không phải vậy
  được bảo vệ chống ghi bằng tính năng chống ghi trang ẩn.

Trên đường dẫn lỗi trang nhanh, chúng tôi sẽ sử dụng cmpxchg để đặt nguyên tử spte W
bit nếu spte.HOST_WRITEABLE = 1 và spte.WRITE_PROTECT = 1, để khôi phục dữ liệu đã lưu
Các bit R/X nếu dành cho spte theo dõi truy cập hoặc cả hai. Điều này an toàn vì bất cứ khi nào
việc thay đổi các bit này có thể được phát hiện bởi cmpxchg.

Nhưng chúng ta cần kiểm tra cẩn thận những trường hợp sau:

1) Ánh xạ từ gfn sang pfn

Ánh xạ từ gfn sang pfn có thể bị thay đổi vì chúng ta chỉ có thể đảm bảo pfn
không bị thay đổi trong cmpxchg. Đây là sự cố ABA, ví dụ như trường hợp bên dưới
sẽ xảy ra:

+--------------------------------------------------------------------------------------- +
ZZ0000ZZ
ZZ0001ZZ
ZZ0002ZZ
ZZ0003ZZ
ZZ0004ZZ
ZZ0005ZZ
+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
+-----------------------------------+-----------------------------------+
ZZ0007ZZ CPU 1: |
+-----------------------------------+-----------------------------------+
ZZ0008ZZ |
ZZ0009ZZ |
ZZ0010ZZ |
+-----------------------------------+-----------------------------------+
ZZ0011ZZ pfn1 bị tráo đổi :: |
ZZ0012ZZ |
ZZ0013ZZ spte = 0;                      |
ZZ0014ZZ |
ZZ0015ZZ pfn1 được phân bổ lại cho gfn2.      |
ZZ0016ZZ |
ZZ0017ZZ gte được đổi thành trỏ tới |
ZZ0018ZZ gfn2 của khách:: |
ZZ0019ZZ |
ZZ0020ZZ spte = pfn1;                   |
+-----------------------------------+-----------------------------------+
ZZ0021ZZ
ZZ0022ZZ
ZZ0023ZZ
ZZ0024ZZ
ZZ0025ZZ
+--------------------------------------------------------------------------------------- +

Chúng tôi ghi nhật ký bẩn cho gfn1, điều đó có nghĩa là gfn2 bị mất trong dirty-bitmap.

Đối với sp trực tiếp, chúng ta có thể dễ dàng tránh nó vì spte của sp trực tiếp đã được cố định
tới bạn gái.  Đối với sp gián tiếp, chúng tôi đã tắt lỗi trang nhanh để đơn giản.

Một giải pháp cho sp gián tiếp có thể là ghim gfn trước cmpxchg.  Sau
việc ghim:

- Chúng tôi đã tổ chức việc đếm lại pfn; điều đó có nghĩa là pfn không thể được giải phóng và
  được tái sử dụng cho một gfn khác.
- Pfn có thể ghi được và do đó nó không thể được chia sẻ giữa các gfn khác nhau
  của KSM.

Sau đó, chúng tôi có thể đảm bảo các bitmap bẩn được đặt chính xác cho gfn.

2) Theo dõi bit bẩn

Trong mã gốc, spte có thể được cập nhật nhanh chóng (phi nguyên tử) nếu
spte ở chế độ chỉ đọc và bit Truy cập đã được thiết lập kể từ
Bit truy cập và bit bẩn không thể bị mất.

Nhưng điều đó không đúng sau lỗi trang nhanh vì spte có thể được đánh dấu
có thể ghi giữa việc đọc spte và cập nhật spte. Giống như trường hợp dưới đây:

+--------------------------------------------------------------------------------------- +
ZZ0000ZZ
ZZ0001ZZ
ZZ0002ZZ
ZZ0003ZZ
+--------------------------------------+-----------------------------------+
ZZ0004ZZ CPU 1: |
+--------------------------------------+-----------------------------------+
ZZ0005ZZ |
ZZ0006ZZ |
ZZ0007ZZ |
ZZ0008ZZ |
ZZ0009ZZ |
ZZ0010ZZ |
ZZ0011ZZ |
ZZ0012ZZ |
ZZ0013ZZ |
+--------------------------------------+-----------------------------------+
ZZ0014ZZ trên đường dẫn lỗi trang nhanh:: |
ZZ0015ZZ |
ZZ0016ZZ spte.W = 1 |
ZZ0017ZZ |
Bộ nhớ ZZ0018ZZ ghi trên spte:: |
ZZ0019ZZ |
ZZ0020ZZ spte.Dirty = 1 |
+--------------------------------------+-----------------------------------+
ZZ0021ZZ |
ZZ0022ZZ |
ZZ0023ZZ |
ZZ0024ZZ |
ZZ0025ZZ |
ZZ0026ZZ |
ZZ0027ZZ |
ZZ0028ZZ |
ZZ0029ZZ |
ZZ0030ZZ |
ZZ0031ZZ |
+--------------------------------------+-----------------------------------+

Bit bẩn bị mất trong trường hợp này.

Để tránh loại vấn đề này, chúng tôi luôn coi spte là "không ổn định"
liệu nó có thể được cập nhật ngoài mmu-lock [xem spte_needs_atomic_update()]; nó có nghĩa là
spte luôn được cập nhật nguyên tử trong trường hợp này.

3) xóa tlbs do cập nhật spte

Nếu spte được cập nhật từ chỉ có thể ghi sang chỉ đọc, chúng ta nên xóa tất cả TLB,
nếu không thì rmap_write_protect sẽ tìm thấy một spte chỉ đọc, mặc dù
spte có thể ghi có thể được lưu vào bộ nhớ đệm trên TLB của CPU.

Như đã đề cập trước đó, spte có thể được cập nhật để có thể ghi được nhờ mmu-lock trên
đường dẫn lỗi trang nhanh. Để dễ dàng kiểm tra đường dẫn, chúng tôi xem liệu TLB có cần
bị xóa gây ra lý do này trong mmu_spte_update() vì đây là lý do phổ biến
chức năng cập nhật spte (hiện tại -> hiện tại).

Vì spte "không ổn định" nếu nó có thể được cập nhật ngoài mmu-lock, nên chúng tôi luôn
cập nhật nguyên tử spte và có thể tránh được cuộc đua do lỗi trang nhanh.
Xem nhận xét trong spte_needs_atomic_update() và mmu_spte_update().

Theo dõi truy cập không khóa:

Điều này được sử dụng cho các CPU Intel đang sử dụng EPT nhưng không hỗ trợ EPT A/D
bit. Trong trường hợp này, PTE được gắn thẻ là bị vô hiệu hóa A/D (sử dụng các bit bị bỏ qua) và
khi trình thông báo KVM MMU được gọi để theo dõi các truy cập vào một trang (thông qua
kvm_mmu_notifier_clear_flush_young), nó đánh dấu PTE không có trong phần cứng
bằng cách xóa các bit RWX trong PTE và lưu trữ các bit R & X gốc trong nhiều hơn
bit không được sử dụng/bỏ qua. Khi VM cố gắng truy cập trang sau này, sẽ xảy ra lỗi
được tạo ra và cơ chế lỗi trang nhanh được mô tả ở trên được sử dụng để
khôi phục nguyên tử PTE về trạng thái Hiện tại. Bit W không được lưu khi
PTE được đánh dấu để theo dõi truy cập và trong quá trình khôi phục về trạng thái Hiện tại,
bit W được đặt tùy thuộc vào việc đó có phải là quyền truy cập ghi hay không. Nếu nó
không, thì bit W sẽ vẫn trống cho đến khi xảy ra truy cập ghi, lúc đó
thời gian nó sẽ được thiết lập bằng cơ chế theo dõi Bẩn được mô tả ở trên.

3. Tài liệu tham khảo
------------

ZZ0000ZZ
^^^^^^^^^^^^

:Loại: mutex
:Arch: bất kỳ
:Bảo vệ: - vm_list

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^

:Loại: mutex
:Arch: bất kỳ
:Bảo vệ: - kvm_usage_count
		- bật/tắt ảo hóa phần cứng
:Nhận xét: Tồn tại để cho phép sử dụng cpus_read_lock() trong khi kvm_usage_count thì có
		được bảo vệ, giúp đơn giản hóa logic kích hoạt ảo hóa.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^

:Loại: spinlock_t
:Arch: bất kỳ
:Bảo vệ: mn_active_invalidate_count, mn_memslots_update_rcuwait

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:Loại: raw_spinlock_t
:Arch: x86
:Bảo vệ: - kvm_arch::{last_tsc_write,last_tsc_nsec,last_tsc_offset}
		- bù tsc trong vmcb
:Nhận xét: 'thô' vì việc cập nhật phần bù tsc không được ưu tiên.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^
:Loại: spinlock_t hoặc rwlock_t
:Arch: bất kỳ
:Bảo vệ: -trang bóng/mục tlb bóng
:Nhận xét: nó là một spinlock vì nó được sử dụng trong trình thông báo mmu.

ZZ0000ZZ
^^^^^^^^^^^^^
:Type: khóa srcu
:Arch: bất kỳ
: Bảo vệ: - kvm->memslots
		- kvm->xe buýt
:Nhận xét: Phải giữ khóa đọc srcu trong khi truy cập các khe ghi nhớ (ví dụ:
		khi sử dụng các hàm gfn_to_*) và khi truy cập vào kernel
		Địa chỉ MMIO/PIO->ánh xạ cấu trúc thiết bị (kvm->bus).
		Chỉ mục srcu có thể được lưu trữ trong kvm_vcpu->srcu_idx mỗi vcpu
		nếu nó cần thiết cho nhiều chức năng.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^
:Loại: mutex
:Arch: bất kỳ (chỉ cần trên x86)
:Bảo vệ: mọi trường vùng ghi nhớ dành riêng cho Arch cần được sửa đổi
                trong phần quan trọng phía đọc ZZ0000ZZ.
:Nhận xét: phải được giữ trước khi đọc con trỏ tới vùng ghi nhớ hiện tại,
                cho đến khi tất cả các thay đổi đối với memslots hoàn tất

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
:Loại: spinlock_t
:Arch: x86
: Bảo vệ: Wakeup_vcpus_on_cpu
:Nhận xét: Đây là khóa trên mỗi CPU và nó được sử dụng cho các ngắt được đăng VT-d.
		Khi hỗ trợ ngắt đăng VT-d và VM đã chỉ định
		thiết bị, chúng tôi đưa vCPU bị chặn vào danh sách Blocked_vcpu_on_cpu
		được bảo vệ bởi Block_vcpu_on_cpu_lock. Khi phần cứng VT-d gặp sự cố
		sự kiện thông báo đánh thức do các ngắt bên ngoài từ
		thiết bị được chỉ định xảy ra, chúng tôi sẽ tìm vCPU trong danh sách để
		thức dậy.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^
:Loại: mutex
:Arch: x86
:Bảo vệ: tải mô-đun nhà cung cấp (kvm_amd hoặc kvm_intel)
:Nhận xét: Tồn tại vì sử dụng kvm_lock dẫn đến bế tắc.  kvm_lock đã bị lấy
    trong trình thông báo, ví dụ: __kvmclock_cpufreq_notifier(), có thể được gọi trong khi
    cpu_hotplug_lock được giữ, ví dụ: từ cpufreq_boost_trigger_state(), và nhiều
    các hoạt động cần thực hiện cpu_hotplug_lock khi tải mô-đun nhà cung cấp, ví dụ:
    cập nhật các cuộc gọi tĩnh.