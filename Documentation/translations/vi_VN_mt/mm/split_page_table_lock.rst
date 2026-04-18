.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/split_page_table_lock.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Khóa bảng chia trang
=====================

Ban đầu, spinlock mm->page_table_lock bảo vệ tất cả các bảng trang của
mm_struct. Nhưng cách tiếp cận này dẫn đến khả năng mở rộng lỗi trang kém của
các ứng dụng đa luồng do có sự tranh chấp cao về khóa. Để cải thiện
khả năng mở rộng, khóa bảng chia trang đã được giới thiệu.

Với khóa bảng chia trang, chúng tôi có khóa mỗi bảng riêng biệt để tuần tự hóa
truy cập vào bảng. Hiện tại chúng tôi sử dụng khóa chia đôi cho PTE và PMD
các bảng. Truy cập vào các bảng cấp cao hơn được bảo vệ bởi mm->page_table_lock.

Có những người trợ giúp để khóa/mở khóa bảng và các chức năng truy cập khác:

- pte_offset_map_lock()
	ánh xạ PTE và lấy khóa bảng PTE, trả về con trỏ tới PTE với
	con trỏ tới khóa bảng PTE của nó hoặc trả về NULL nếu không có bảng PTE;
 - pte_offset_map_ro_nolock()
	ánh xạ PTE, trả về con trỏ tới PTE với con trỏ tới bảng PTE của nó
	khóa (không lấy) hoặc trả về NULL nếu không có bảng PTE;
 - pte_offset_map_rw_nolock()
	ánh xạ PTE, trả về con trỏ tới PTE với con trỏ tới bảng PTE của nó
	lock (không được lấy) và giá trị của mục nhập pmd của nó hoặc trả về NULL
	nếu không có bảng PTE;
 - pte_offset_map()
	ánh xạ PTE, trả về con trỏ tới PTE hoặc trả về NULL nếu không có bảng PTE;
 - pte_unmap()
	hủy bản đồ bảng PTE;
 - pte_unmap_unlock()
	mở khóa và hủy bản đồ bảng PTE;
 - pte_alloc_map_lock()
	phân bổ bảng PTE nếu cần và khóa nó, trả về con trỏ tới
	PTE với con trỏ tới khóa của nó hoặc trả về NULL nếu phân bổ không thành công;
 - pmd_lock()
	lấy khóa bảng PMD, trả về con trỏ tới khóa đã lấy;
 - pmd_lockptr()
	trả về con trỏ tới khóa bảng PMD;

Khóa bảng chia trang cho các bảng PTE được bật trong thời gian biên dịch nếu
CONFIG_SPLIT_PTLOCK_CPUS (thường là 4) nhỏ hơn hoặc bằng NR_CPUS.
Nếu khóa chia tách bị tắt, tất cả các bảng sẽ được bảo vệ bởi mm->page_table_lock.

Khóa bảng chia trang cho các bảng PMD được bật, nếu nó được bật cho PTE
các bảng và kiến trúc hỗ trợ nó (xem bên dưới).

Hugetlb và khóa bảng chia trang
=================================

Hugetlb có thể hỗ trợ nhiều kích cỡ trang. Chúng tôi chỉ sử dụng khóa chia cho PMD
cấp độ, nhưng không dành cho PUD.

Người trợ giúp dành riêng cho Hugetlb:

- Huge_pte_lock()
	lấy khóa chia pmd cho trang PMD_SIZE, mm->page_table_lock
	mặt khác;
 - Huge_pte_lockptr()
	trả về con trỏ tới khóa bảng;

Hỗ trợ khóa bảng chia trang theo kiến ​​trúc
===================================================

Không cần kích hoạt đặc biệt khóa bảng chia trang PTE: mọi thứ
yêu cầu được thực hiện bởi pagetable_pte_ctor() và pagetable_dtor(),
phải được gọi khi phân bổ/giải phóng bảng PTE.

Đảm bảo kiến trúc không sử dụng bộ cấp phát bản cho bảng trang
phân bổ: tấm sử dụng trang->slab_cache cho các trang của nó.
Trường này chia sẻ bộ nhớ với trang->ptl.

Khóa chia PMD chỉ có ý nghĩa nếu bạn có nhiều hơn hai bảng trang
cấp độ.

Việc bật khóa chia PMD yêu cầu lệnh gọi pagetable_pmd_ctor() trên bảng PMD
phân bổ và pagetable_dtor() khi giải phóng.

Việc phân bổ thường diễn ra trong pmd_alloc_one(), giải phóng trong pmd_free() và
pmd_free_tlb(), nhưng hãy đảm bảo bạn bao gồm tất cả việc phân bổ/giải phóng bảng PMD
đường dẫn: tức là X86_PAE phân bổ trước một số PMD trên pgd_alloc().

Với mọi thứ đã sẵn sàng, bạn có thể đặt CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK.

NOTE: pagetable_pte_ctor() và pagetable_pmd_ctor() có thể thất bại -- nó phải
được xử lý đúng cách.

trang->ptl
=========

page->ptl được sử dụng để truy cập khóa bảng chia trang, trong đó 'trang' là cấu trúc
trang của trang chứa bảng. Nó chia sẻ lưu trữ với trang-> riêng tư
(và một số lĩnh vực khác trong liên minh).

Để tránh tăng kích thước trang struct và có hiệu suất tốt nhất, chúng tôi sử dụng
thủ thuật:

- nếu spinlock_t vừa dài, chúng tôi sử dụng page->ptr làm spinlock, vì vậy chúng tôi
   có thể tránh truy cập gián tiếp và lưu một dòng bộ đệm.
 - nếu kích thước của spinlock_t lớn hơn kích thước của long, chúng ta sử dụng page->ptl làm
   con trỏ tới spinlock_t và phân bổ nó một cách linh hoạt. Điều này cho phép sử dụng
   khóa chia đôi với DEBUG_SPINLOCK hoặc DEBUG_LOCK_ALLOC được bật, nhưng chi phí
   thêm một dòng bộ đệm để truy cập gián tiếp;

Spinlock_t được phân bổ trong pagetable_pte_ctor() cho bảng PTE và trong
pagetable_pmd_ctor() cho bảng PMD.

Vui lòng không bao giờ truy cập trực tiếp vào trang->ptl - hãy sử dụng trình trợ giúp thích hợp.
