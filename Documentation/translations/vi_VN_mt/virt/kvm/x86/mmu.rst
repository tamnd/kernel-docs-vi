.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/mmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Bóng x86 kvm mmu
======================

Mmu (trong Arch/x86/kvm, tệp mmu.[ch] và paging_tmpl.h) chịu trách nhiệm
để trình bày x86 mmu tiêu chuẩn cho khách, đồng thời dịch cho khách
địa chỉ vật lý để lưu trữ địa chỉ vật lý.

Mã mmu cố gắng đáp ứng các yêu cầu sau:

- tính đúng đắn:
	       khách sẽ không thể xác định rằng nó đang chạy
               trên mmu mô phỏng ngoại trừ thời gian (chúng tôi cố gắng tuân thủ
               với đặc điểm kỹ thuật, không mô phỏng các đặc điểm của
               một triển khai cụ thể như kích thước tlb)
- an ninh:
	       khách không thể chạm vào bộ nhớ máy chủ không được chỉ định
               với nó
- hiệu suất:
               giảm thiểu hình phạt hiệu suất do mmu áp đặt
- chia tỷ lệ:
               cần mở rộng quy mô tới bộ nhớ lớn và lượng khách vcpu lớn
- phần cứng:
               hỗ trợ đầy đủ phần cứng ảo hóa x86
- hội nhập:
               Mã quản lý bộ nhớ Linux phải kiểm soát bộ nhớ khách
               do đó việc hoán đổi, di chuyển trang, hợp nhất trang, minh bạch
               các trang lớn và các tính năng tương tự hoạt động mà không thay đổi
- theo dõi bẩn:
               báo cáo ghi vào bộ nhớ khách để cho phép di chuyển trực tiếp
               và hiển thị dựa trên bộ đệm khung
- dấu chân:
               giữ lượng bộ nhớ hạt nhân được ghim ở mức thấp (hầu hết bộ nhớ
               nên có thể co lại)
- độ tin cậy:
               tránh phân bổ nhiều trang hoặc GFP_ATOMIC

Từ viết tắt
========

==== ==========================================================================
số khung trang chủ pfn
địa chỉ vật lý của máy chủ hpa
địa chỉ ảo máy chủ hva
số khung hình khách gfn
địa chỉ vật lý của khách gpa
địa chỉ ảo của khách gva
địa chỉ vật lý của khách lồng nhau ngpa
địa chỉ ảo của khách lồng nhau ngva
Mục nhập bảng trang pte (cũng được dùng để chỉ một cách khái quát về cấu trúc phân trang
      mục)
gpte guest pte (đề cập đến gfns)
spte bóng pte (ám chỉ pfns)
phân trang hai chiều tdp (thuật ngữ trung lập của nhà cung cấp cho NPT và EPT)
==== ==========================================================================

Hỗ trợ phần cứng ảo và thực
===================================

Mmu hỗ trợ phần cứng mmu thế hệ đầu tiên, cho phép chuyển đổi nguyên tử
của chế độ phân trang hiện tại và cr3 trong quá trình nhập cảnh của khách, cũng như
phân trang hai chiều (AMD của AMD và EPT của Intel).  Phần cứng mô phỏng
nó hiển thị là x86 mmu cấp 2/3/4 truyền thống, với sự hỗ trợ cho toàn cầu
các trang, pae, pse, pse36, cr0.wp và các trang 1GB. Phần cứng mô phỏng cũng
có thể hiển thị phần cứng có khả năng NPT trên các máy chủ có khả năng NPT.

Dịch thuật
===========

Công việc chính của mmu là lập trình mmu của bộ xử lý để dịch
địa chỉ cho khách.  Những bản dịch khác nhau được yêu cầu ở những thời điểm khác nhau
lần:

- khi tính năng phân trang dành cho khách bị vô hiệu hóa, chúng tôi sẽ dịch địa chỉ vật lý của khách sang
  địa chỉ vật lý của máy chủ (gpa->hpa)
- khi bật phân trang cho khách, chúng tôi sẽ dịch địa chỉ ảo của khách sang
  địa chỉ vật lý của khách, để lưu trữ địa chỉ vật lý (gva->gpa->hpa)
- khi khách khởi chạy một khách riêng, chúng tôi dịch khách lồng nhau
  địa chỉ ảo, đến địa chỉ vật lý của khách lồng nhau, đến địa chỉ vật lý của khách
  địa chỉ, để lưu trữ địa chỉ vật lý (ngva->ngpa->gpa->hpa)

Thách thức chính là mã hóa từ 1 đến 3 bản dịch thành phần cứng
chỉ hỗ trợ 1 bản dịch (truyền thống) và 2 bản dịch (tdp).  Khi
số lượng bản dịch cần thiết phù hợp với phần cứng, mmu hoạt động trong
chế độ trực tiếp; nếu không nó sẽ hoạt động ở chế độ bóng tối (xem bên dưới).

Ký ức
======

Bộ nhớ khách (gpa) là một phần của không gian địa chỉ người dùng của tiến trình được
sử dụng kvm.  Không gian người dùng xác định bản dịch giữa địa chỉ của khách và người dùng
địa chỉ (gpa->hva); lưu ý rằng hai gpas có thể có bí danh là cùng một hva, nhưng không
ngược lại.

Những hvas này có thể được hỗ trợ bằng bất kỳ phương thức nào có sẵn cho máy chủ: ẩn danh
bộ nhớ, bộ nhớ hỗ trợ tập tin và bộ nhớ thiết bị.  Bộ nhớ có thể được phân trang bởi
chủ bất cứ lúc nào.

Sự kiện
======

Mmu được điều khiển bởi các sự kiện, một số từ khách, một số từ chủ nhà.

Sự kiện do khách tạo:

- ghi vào các thanh ghi điều khiển (đặc biệt là cr3)
- thực thi lệnh invlpg/invlpga
- truy cập vào các bản dịch bị thiếu hoặc được bảo vệ

Sự kiện do máy chủ tạo:

- thay đổi trong bản dịch gpa->hpa (hoặc thông qua thay đổi gpa->hva hoặc
  thông qua thay đổi hva->hpa)
- áp suất bộ nhớ (máy thu nhỏ)

Trang bóng
============

Cấu trúc dữ liệu chính là trang bóng, 'struct kvm_mmu_page'.  A
trang bóng chứa 512 spte, có thể là spte lá hoặc không lá.  A
trang bóng có thể chứa sự kết hợp của các spte lá và không lá.

Một spte không có lá cho phép mmu phần cứng tiếp cận các trang lá và
không liên quan trực tiếp đến bản dịch.  Nó trỏ đến các trang bóng khác.

Một spte lá tương ứng với một hoặc hai bản dịch được mã hóa thành
một mục cấu trúc phân trang.  Đây luôn là mức thấp nhất của
ngăn xếp dịch thuật, với các bản dịch cấp cao hơn tùy chọn được để lại cho NPT/EPT.
Lá ptes trỏ vào trang khách.

Bảng sau đây hiển thị các bản dịch được mã hóa bởi ptes lá, với cấp độ cao hơn
bản dịch trong ngoặc:

Khách không lồng nhau::

không phân trang: gpa->hpa
  phân trang: gva->gpa->hpa
  phân trang, tdp: (gva->)gpa->hpa

Khách lồng nhau::

không phải tdp: ngva->gpa->hpa (*)
  tdp: (ngva->)ngpa->gpa->hpa

(*) trình ảo hóa khách sẽ mã hóa bản dịch ngva->gpa vào trang của nó
      bảng nếu không có npt

Shadow pages contain the following information:
  role.level:
    The level in the shadow paging hierarchy that this shadow page belongs to.
    1=4k sptes, 2=2M sptes, 3=1G sptes, etc.
  role.direct:
    If set, leaf sptes reachable from this page are for a linear range.
    Examples include real mode translation, large guest pages backed by small
    host pages, and gpa->hpa translations when NPT or EPT is active.
    The linear range starts at (gfn << PAGE_SHIFT) and its size is determined
    by role.level (2MB for first level, 1GB for second level, 0.5TB for third
    level, 256TB for fourth level)
    If clear, this page corresponds to a guest page table denoted by the gfn
    field.
  role.quadrant:
    When role.has_4_byte_gpte=1, the guest uses 32-bit gptes while the host uses 64-bit
    sptes.  That means a guest page table contains more ptes than the host,
    so multiple shadow pages are needed to shadow one guest page.
    For first-level shadow pages, role.quadrant can be 0 or 1 and denotes the
    first or second 512-gpte block in the guest page table.  For second-level
    page tables, each 32-bit gpte is converted to two 64-bit sptes
    (since each first-level guest page is shadowed by two first-level
    shadow pages) so role.quadrant takes values in the range 0..3.  Each
    quadrant maps 1GB virtual address space.
  role.access:
    Inherited guest access permissions from the parent ptes in the form uwx.
    Note execute permission is positive, not negative.
  role.invalid:
    The page is invalid and should not be used.  It is a root page that is
    currently pinned (by a cpu hardware register pointing to it); once it is
    unpinned it will be destroyed.
  role.has_4_byte_gpte:
    Reflects the size of the guest PTE for which the page is valid, i.e. '0'
    if direct map or 64-bit gptes are in use, '1' if 32-bit gptes are in use.
  role.efer_nx:
    Contains the value of efer.nx for which the page is valid.
  role.cr0_wp:
    Contains the value of cr0.wp for which the page is valid.
  role.smep_andnot_wp:
    Contains the value of cr4.smep && !cr0.wp for which the page is valid
    (pages for which this is true are different from other pages; see the
    treatment of cr0.wp=0 below).
  role.smap_andnot_wp:
    Contains the value of cr4.smap && !cr0.wp for which the page is valid
    (pages for which this is true are different from other pages; see the
    treatment of cr0.wp=0 below).
  role.smm:
    Is 1 if the page is valid in system management mode.  This field
    determines which of the kvm_memslots array was used to build this
    shadow page; it is also used to go back from a struct kvm_mmu_page
    to a memslot, through the kvm_memslots_for_spte_role macro and
    __gfn_to_memslot.
  role.ad_disabled:
    Is 1 if the MMU instance cannot use A/D bits.  EPT did not have A/D
    bits before Haswell; shadow EPT page tables also cannot use A/D bits
    if the L1 hypervisor does not enable them.
  role.guest_mode:
    Indicates the shadow page is created for a nested guest.
  role.passthrough:
    The page is not backed by a guest page table, but its first entry
    points to one.  This is set if NPT uses 5-level page tables (host
    CR4.LA57=1) and is shadowing L1's 4-level NPT (L1 CR4.LA57=0).
  mmu_valid_gen:
    The MMU generation of this page, used to fast zap of all MMU pages within a
    VM without blocking vCPUs too long. Specifically, KVM updates the per-VM
    valid MMU generation which causes the mismatch of mmu_valid_gen for each mmu
    page. This makes all existing MMU pages obsolete. Obsolete pages can't be
    used. Therefore, vCPUs must load a new, valid root before re-entering the
    guest. The MMU generation is only ever '0' or '1'. Note, the TDP MMU doesn't
    use this field as non-root TDP MMU pages are reachable only from their
    owning root. Thus it suffices for TDP MMU to use role.invalid in root pages
    to invalidate all MMU pages.
  gfn:
    Either the guest page table containing the translations shadowed by this
    page, or the base page frame for linear translations.  See role.direct.
  spt:
    A pageful of 64-bit sptes containing the translations for this page.
    Accessed by both kvm and hardware.
    The page pointed to by spt will have its page->private pointing back
    at the shadow page structure.
    sptes in spt point either at guest pages, or at lower-level shadow pages.
    Specifically, if sp1 and sp2 are shadow pages, then sp1->spt[n] may point
    at __pa(sp2->spt).  sp2 will point back at sp1 through parent_pte.
    The spt array forms a DAG structure with the shadow page as a node, and
    guest pages as leaves.
  shadowed_translation:
    An array of 512 shadow translation entries, one for each present pte. Used
    to perform a reverse map from a pte to a gfn as well as its access
    permission. When role.direct is set, the shadow_translation array is not
    allocated. This is because the gfn contained in any element of this array
    can be calculated from the gfn field when used.  In addition, when
    role.direct is set, KVM does not track access permission for each of the
    gfn. See role.direct and gfn.
  root_count / tdp_mmu_root_count:
     root_count is a reference counter for root shadow pages in Shadow MMU.
     vCPUs elevate the refcount when getting a shadow page that will be used as
     a root page, i.e. page that will be loaded into hardware directly (CR3,
     PDPTRs, nCR3 EPTP). Root pages cannot be destroyed while their refcount is
     non-zero. See role.invalid. tdp_mmu_root_count is similar but exclusively
     used in TDP MMU as an atomic refcount.
  parent_ptes:
    The reverse mapping for the pte/ptes pointing at this page's spt. If
    parent_ptes bit 0 is zero, only one spte points at this page and
    parent_ptes points at this single spte, otherwise, there exists multiple
    sptes pointing at this page and (parent_ptes & ~0x1) points at a data
    structure with a list of parent sptes.
  ptep:
    The kernel virtual address of the SPTE that points at this shadow page.
    Used exclusively by the TDP MMU, this field is a union with parent_ptes.
  unsync:
    If true, then the translations in this page may not match the guest's
    translation.  This is equivalent to the state of the tlb when a pte is
    changed but before the tlb entry is flushed.  Accordingly, unsync ptes
    are synchronized when the guest executes invlpg or flushes its tlb by
    other means.  Valid for leaf pages.
  unsync_children:
    How many sptes in the page point at pages that are unsync (or have
    unsynchronized children).
  unsync_child_bitmap:
    A bitmap indicating which sptes in spt point (directly or indirectly) at
    pages that may be unsynchronized.  Used to quickly locate all unsynchronized
    pages reachable from a given page.
  clear_spte_count:
    Only present on 32-bit hosts, where a 64-bit spte cannot be written
    atomically.  The reader uses this while running out of the MMU lock
    to detect in-progress updates and retry them until the writer has
    finished the write.
  write_flooding_count:
    A guest may write to a page table many times, causing a lot of
    emulations if the page needs to be write-protected (see "Synchronized
    and unsynchronized pages" below).  Leaf pages can be unsynchronized
    so that they do not trigger frequent emulation, but this is not
    possible for non-leafs.  This field counts the number of emulations
    since the last time the page table was actually used; if emulation
    is triggered too frequently on this page, KVM will unmap the page
    to avoid emulation in the future.
  tdp_mmu_page:
    Is 1 if the shadow page is a TDP MMU page. This variable is used to
    bifurcate the control flows for KVM when walking any data structure that
    may contain pages from both TDP MMU and shadow MMU.

Bản đồ ngược
===========

Mmu duy trì ánh xạ ngược, nhờ đó tất cả các điểm ánh xạ một trang có thể được
đạt được gfn của nó.  Điều này được sử dụng, ví dụ, khi hoán đổi một trang.

Các trang được đồng bộ hóa và không đồng bộ hóa
=====================================

Khách sử dụng hai sự kiện để đồng bộ hóa bảng tlb và bảng trang của mình: tlb tuôn ra
và vô hiệu hóa trang (invlpg).

Việc xóa tlb có nghĩa là chúng ta cần đồng bộ hóa tất cả các sp có thể truy cập được từ
cr3 của khách.  Điều này rất tốn kém, vì vậy chúng tôi ghi lại tất cả các bảng của trang khách
được bảo vệ và đồng bộ hóa sptes với gptes khi gte được ghi.

Một trường hợp đặc biệt là khi có thể truy cập được bảng trang khách từ trang hiện tại
khách cr3.  Trong trường hợp này, khách có nghĩa vụ đưa ra hướng dẫn invlpg
trước khi sử dụng bản dịch.  Chúng tôi tận dụng điều đó bằng cách loại bỏ ghi
bảo vệ khỏi trang khách và cho phép khách sửa đổi nó một cách tự do.
Chúng tôi đồng bộ hóa các gptes đã sửa đổi khi khách gọi invlpg.  Điều này làm giảm
số lượng mô phỏng chúng tôi phải thực hiện khi khách sửa đổi nhiều gptes,
hoặc khi trang khách không còn được sử dụng làm bảng trang nữa và được sử dụng cho
dữ liệu khách ngẫu nhiên.

Là một tác dụng phụ, chúng tôi phải đồng bộ hóa lại tất cả các bóng không đồng bộ có thể truy cập được
các trang trên một tlb tuôn ra.


Phản ứng với các sự kiện
==================

- lỗi trang khách (hoặc lỗi trang npt, hoặc vi phạm ept)

Đây là sự kiện phức tạp nhất.  Nguyên nhân gây ra lỗi trang có thể là:

- lỗi thực sự của khách (bản dịch của khách sẽ không cho phép truy cập) (*)
  - truy cập vào một bản dịch bị thiếu
  - truy cập vào một bản dịch được bảo vệ
    - khi ghi lại các trang bẩn, bộ nhớ được bảo vệ ghi
    - các trang ẩn được đồng bộ hóa được bảo vệ chống ghi (*)
  - truy cập vào bộ nhớ không thể dịch được (mmio)

(*) không áp dụng ở chế độ trực tiếp

Việc xử lý lỗi trang được thực hiện như sau:

- nếu bit RSV của mã lỗi được đặt thì lỗi trang là do khách
   truy cập MMIO và thông tin MMIO được lưu trong bộ nhớ cache có sẵn.

- bảng trang bóng đi bộ
   - kiểm tra số thế hệ hợp lệ trong spte (xem phần "Vô hiệu hóa nhanh của
     MMIO sptes" bên dưới)
   - lưu trữ thông tin vào vcpu->arch.mmio_gva, vcpu->arch.mmio_access và
     vcpu->arch.mmio_gfn và gọi trình mô phỏng

- Nếu cả mã lỗi P và bit R/W đều được đặt thì điều này có thể xảy ra
   được xử lý như "lỗi trang nhanh" (đã sửa mà không cần lấy khóa MMU).  Xem
   mô tả trong Documentation/virt/kvm/locking.rst.

- nếu cần, hãy xem bảng trang của khách để xác định bản dịch của khách
   (gva->gpa hoặc ngpa->gpa)

- nếu quyền không đủ, hãy phản ánh lại lỗi cho khách

- xác định trang chủ

- nếu đây là yêu cầu mmio thì không có trang lưu trữ; lưu trữ thông tin vào
     vcpu->arch.mmio_gva, vcpu->arch.mmio_access và vcpu->arch.mmio_gfn

- đi qua bảng trang bóng để tìm spte cho bản dịch,
   khởi tạo các bảng trang trung gian bị thiếu khi cần thiết

- Nếu đây là yêu cầu mmio, hãy lưu thông tin mmio vào spte và đặt một số
     bit dành riêng trên spte (xem người gọi kvm_mmu_set_mmio_spte_mask)

- cố gắng hủy đồng bộ hóa trang

- nếu thành công, chúng ta có thể để khách tiếp tục và sửa đổi gte

- bắt chước lời dạy

- nếu thất bại, hãy làm mờ trang và để khách tiếp tục

- cập nhật mọi bản dịch đã được sửa đổi theo hướng dẫn

xử lý invlpg:

- đi theo hệ thống phân cấp trang bóng và loại bỏ các bản dịch bị ảnh hưởng
  - cố gắng khôi phục bản dịch được chỉ định với hy vọng rằng
    khách sẽ sử dụng nó trong tương lai gần

Cập nhật đăng ký kiểm soát khách:

- chuyển sang cr3

- tra cứu rễ bóng mới
  - đồng bộ hóa các trang bóng mới có thể truy cập

- chuyển sang cr0/cr4/efer

- thiết lập bối cảnh mmu cho chế độ phân trang mới
  - tra cứu rễ bóng mới
  - đồng bộ hóa các trang bóng mới có thể truy cập

Cập nhật bản dịch máy chủ:

- trình thông báo mmu được gọi với hva cập nhật
  - tra cứu các sp bị ảnh hưởng thông qua bản đồ ngược
  - thả (hoặc cập nhật) bản dịch

Giả lập cr0.wp
================

Nếu tdp không được bật, máy chủ phải giữ cr0.wp=1 để bảo vệ chống ghi trang
hoạt động cho kernel khách chứ không phải không gian người dùng khách.  Khi khách
cr0.wp=1, điều này không gây ra vấn đề gì.  Tuy nhiên khi khách cr0.wp=0,
chúng tôi không thể ánh xạ các quyền của gte.u=1, gpte.w=0 tới bất kỳ spte nào (
ngữ nghĩa yêu cầu cho phép mọi quyền truy cập kernel của khách cộng với quyền truy cập đọc của người dùng).

Chúng tôi xử lý vấn đề này bằng cách ánh xạ các quyền tới hai spte có thể, tùy thuộc vào
về loại lỗi:

- lỗi ghi kernel: spte.u=0, spte.w=1 (cho phép truy cập kernel đầy đủ,
  không cho phép người dùng truy cập)
- lỗi đọc: spte.u=1, spte.w=0 (cho phép truy cập đọc đầy đủ, không cho phép kernel
  truy cập ghi)

(lỗi ghi của người dùng tạo ra #PF)

Trong trường hợp đầu tiên có thêm hai biến chứng:

- nếu CR4.SMEP được bật: vì chúng tôi đã biến trang này thành trang kernel,
  hạt nhân bây giờ có thể thực thi nó.  Chúng tôi xử lý vấn đề này bằng cách cài đặt spte.nx.
  Nếu chúng tôi gặp lỗi tìm nạp hoặc đọc của người dùng, chúng tôi sẽ thay đổi spte.u=1 và
  spte.nx=gte.nx quay lại.  Để tính năng này hoạt động, KVM buộc EFER.NX lên 1 khi
  phân trang bóng đang được sử dụng.
- nếu CR4.SMAP bị tắt: vì trang đã được thay đổi thành kernel
  trang này, nó không thể được sử dụng lại khi CR4.SMAP được bật. Chúng tôi thiết lập
  CR4.SMAP && !CR0.WP vào vai trò của trang bóng để tránh trường hợp này. Lưu ý,
  ở đây chúng tôi không quan tâm đến trường hợp CR4.SMAP được bật vì KVM sẽ
  trực tiếp tiêm #PF cho khách do kiểm tra quyền không thành công.

Để ngăn chặn một spte được chuyển đổi thành trang kernel với cr0.wp=0
từ việc được ghi bởi kernel sau khi cr0.wp thay đổi thành 1, chúng ta tạo
giá trị của cr0.wp một phần của vai trò trang.  Điều này có nghĩa là một spte được tạo
với một giá trị cr0.wp không thể được sử dụng khi cr0.wp có giá trị khác -
nó sẽ đơn giản bị bỏ qua bởi mã tra cứu trang bóng.  Một vấn đề tương tự
tồn tại khi một spte được tạo bằng cr0.wp=0 và cr4.smep=0 được sử dụng sau
thay đổi cr4.smep thành 1. Để tránh điều này, giá trị của !cr0.wp && cr4.smep
cũng được coi là một phần của vai trò trang.

Trang lớn
===========

Mmu hỗ trợ tất cả các kết hợp của trang khách và trang chủ lớn và nhỏ.
Kích thước trang được hỗ trợ bao gồm 4k, 2M, 4M và 1G.  Các trang 4 triệu được coi là
hai trang 2M riêng biệt, trên cả máy khách và máy chủ, vì mmu luôn sử dụng PAE
phân trang.

Để khởi tạo một spte lớn, phải thỏa mãn bốn ràng buộc:

- spte phải trỏ tới một trang chủ lớn
- pte khách phải là pte lớn có kích thước ít nhất tương đương (nếu tdp là
  được bật, không có pte khách và điều kiện này được thỏa mãn)
- nếu spte có thể ghi được, khung trang lớn có thể không chồng lên nhau bất kỳ
  trang được bảo vệ chống ghi
- trang khách phải được chứa hoàn toàn bởi một khe cắm bộ nhớ duy nhất

Để kiểm tra hai điều kiện cuối cùng, mmu duy trì một bộ ->disallow_lpage gồm
mảng cho từng khe nhớ và kích thước trang lớn.  Mỗi trang được bảo vệ ghi
làm cho disallow_lpage của nó tăng lên, do đó ngăn chặn việc khởi tạo
một spte lớn.  Các khung ở cuối khe nhớ chưa được căn chỉnh có
tăng cao một cách giả tạo ->disallow_lpages để chúng không bao giờ có thể được khởi tạo.

Vô hiệu hóa nhanh chóng các sptes MMIO
===============================

Như đã đề cập trong phần "Phản ứng với các sự kiện" ở trên, kvm sẽ lưu vào bộ nhớ đệm MMIO
thông tin trong lá sptes.  Khi một khe nhớ mới được thêm vào hoặc một khe nhớ hiện có
memslot bị thay đổi, thông tin này có thể trở nên cũ và cần được
vô hiệu.  Điều này cũng cần phải giữ khóa MMU trong khi đi bộ
các trang bóng tối và được mở rộng hơn bằng kỹ thuật tương tự.

Các spte MMIO có một vài bit dự phòng, được sử dụng để lưu trữ
số thế hệ  Số thế hệ toàn cầu được lưu trữ trong
kvm_memslots(kvm)->tạo và tăng bất cứ khi nào có thông tin bộ nhớ khách
những thay đổi.

Khi KVM tìm thấy spte MMIO, nó sẽ kiểm tra số thế hệ của spte.
Nếu số thế hệ của spte không bằng thế hệ toàn cầu
số, nó sẽ bỏ qua thông tin MMIO được lưu trong bộ nhớ cache và xử lý trang
lỗi thông qua con đường chậm.

Vì chỉ có 18 bit được sử dụng để lưu trữ số thế hệ trên mmio spte nên tất cả
các trang bị cắt khi có tràn.

Thật không may, một lần truy cập bộ nhớ có thể truy cập nhiều bộ nhớ kvm_memslots(kvm)
lần cuối cùng xảy ra khi số thế hệ được lấy ra và
được lưu trữ vào spte MMIO.  Do đó, spte MMIO có thể được tạo dựa trên
thông tin lỗi thời nhưng có số thế hệ cập nhật.

Để tránh điều này, số thế hệ được tăng lại sau khi sync_srcu
trả lại; do đó, bit 63 của kvm_memslots(kvm)->generation chỉ được đặt thành 1 trong một
memslot cập nhật, trong khi một số trình đọc SRCU có thể đang sử dụng bản sao cũ.  chúng tôi không
muốn sử dụng sptes MMIO được tạo bằng số thế hệ lẻ và chúng tôi có thể làm
điều này mà không mất đi một chút nào trong spte MMIO.  Bit "đang cập nhật" của
thế hệ không được lưu trữ trong MMIO spte và do đó hoàn toàn bằng 0 khi
thế hệ được trích xuất ra khỏi spte.  Nếu KVM không may mắn và tạo ra MMIO
spte trong khi quá trình cập nhật đang diễn ra, lần truy cập tiếp theo vào spte sẽ luôn là
thiếu bộ nhớ đệm.  Ví dụ: lần truy cập tiếp theo trong cửa sổ cập nhật sẽ
bị bỏ lỡ do cờ đang tiến hành phân kỳ, trong khi quyền truy cập sau khi cập nhật
cửa sổ đóng sẽ có số thế hệ cao hơn (so với spte).


Đọc thêm
===============

- Bài thuyết trình NPT từ Diễn đàn KVM 2008
  ZZ0000ZZ