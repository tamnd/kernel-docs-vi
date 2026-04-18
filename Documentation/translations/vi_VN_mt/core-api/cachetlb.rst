.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/cachetlb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Xoá bộ nhớ đệm và TLB trong Linux
==================================

:Tác giả: David S. Miller <davem@redhat.com>

Tài liệu này mô tả các giao diện xóa bộ đệm/tlb được gọi là
bởi hệ thống con Linux VM.  Nó liệt kê trên mỗi giao diện,
mô tả mục đích dự định của nó và tác dụng phụ dự kiến
sau khi giao diện được gọi.

Các tác dụng phụ được mô tả dưới đây được nêu đối với bộ xử lý đơn
việc triển khai và điều gì sẽ xảy ra trên bộ xử lý đó.  các
Vỏ SMP là một phần mở rộng đơn giản, trong đó bạn chỉ cần mở rộng
định nghĩa sao cho xảy ra tác dụng phụ cho một giao diện cụ thể
trên tất cả các bộ xử lý trong hệ thống.  Đừng để điều này làm bạn sợ hãi
nghĩ rằng việc xóa bộ nhớ đệm/tlb của SMP hẳn là không hiệu quả, điều này nằm trong
thực tế là một lĩnh vực có thể thực hiện được nhiều tối ưu hóa.  Ví dụ,
nếu có thể chứng minh được rằng không gian địa chỉ người dùng chưa bao giờ được thực thi
trên CPU (xem mm_cpumask()), người ta không cần thực hiện xóa
cho không gian địa chỉ này trên cpu đó.

Đầu tiên, giao diện xả TLB, vì chúng đơn giản nhất.  các
"TLB" được trừu tượng hóa trong Linux như thứ mà CPU sử dụng để lưu vào bộ đệm
ảo-> bản dịch địa chỉ vật lý thu được từ phần mềm
các bảng trang.  Có nghĩa là nếu bảng trang phần mềm thay đổi thì đó là
có thể tồn tại các bản dịch cũ trong bộ đệm "TLB" này.
Do đó khi xảy ra thay đổi bảng trang phần mềm, kernel sẽ
gọi một trong các phương thức xóa sau _sau_ bảng trang
xảy ra những thay đổi:

1) ZZ0000ZZ

Sự tuôn ra nghiêm trọng nhất của tất cả.  Sau khi giao diện này chạy,
	bất kỳ sửa đổi bảng trang nào trước đó sẽ được
	CPU hiển thị.

Điều này thường được gọi khi các bảng trang kernel được
	đã thay đổi, vì những bản dịch như vậy có tính chất "toàn cầu".

2) ZZ0000ZZ

Giao diện này xóa toàn bộ không gian địa chỉ người dùng từ
	TLB.  Sau khi chạy, giao diện này phải đảm bảo rằng
	mọi sửa đổi bảng trang trước đó cho không gian địa chỉ
	'mm' sẽ hiển thị với cpu.  Tức là sau khi chạy
	sẽ không có mục nào trong TLB cho 'mm'.

Giao diện này được sử dụng để xử lý toàn bộ không gian địa chỉ
	các thao tác trên bảng trang chẳng hạn như những gì xảy ra trong
	ngã ba và thực thi.

3) ZZ0000ZZ

Ở đây chúng tôi đang xóa một phạm vi cụ thể của (người dùng) ảo
	bản dịch địa chỉ từ TLB.  Sau khi chạy thì cái này
	giao diện phải đảm bảo rằng mọi bảng trang trước đó
	sửa đổi cho không gian địa chỉ 'vma->vm_mm' trong phạm vi
	'bắt đầu' đến 'kết thúc-1' sẽ hiển thị với cpu.  Tức là sau
	đang chạy, sẽ không có mục nào trong TLB cho 'mm' cho
	địa chỉ ảo trong phạm vi 'bắt đầu' đến 'kết thúc-1'.

"Vma" là cửa hàng hỗ trợ đang được sử dụng cho khu vực.
	Về cơ bản, điều này được sử dụng cho các hoạt động kiểu munmap().

Giao diện được cung cấp với hy vọng cổng có thể tìm thấy
	một phương pháp hiệu quả phù hợp để loại bỏ nhiều trang
	các bản dịch có kích thước từ TLB, thay vì có kernel
	gọi tuôn ra_tlb_page (xem bên dưới) cho mỗi mục có thể
	đã sửa đổi.

4) ZZ0000ZZ

Lần này chúng ta cần xóa bản dịch có kích thước PAGE_SIZE
	từ TLB.  'Vma' là cấu trúc hỗ trợ được sử dụng bởi
	Linux để theo dõi các vùng mmap'd cho một quy trình,
	không gian địa chỉ có sẵn thông qua vma->vm_mm.  Ngoài ra, người ta có thể
	kiểm tra (vma->vm_flags & VM_EXEC) để xem vùng này có
	có thể thực thi được (và do đó có thể nằm trong 'lệnh TLB' trong
	thiết lập kiểu chia-tlb).

Sau khi chạy, giao diện này phải đảm bảo rằng mọi giao diện trước đó
	sửa đổi bảng trang cho không gian địa chỉ 'vma->vm_mm' cho
	địa chỉ ảo của người dùng 'addr' sẽ hiển thị với cpu.  Đó
	là, sau khi chạy, sẽ không có mục nào trong TLB cho
	'vma->vm_mm' cho địa chỉ ảo 'addr'.

Điều này được sử dụng chủ yếu trong quá trình xử lý lỗi.

5) ZZ0000ZZ

Vào cuối mỗi lỗi trang, thủ tục này được gọi để thông báo
	mã cụ thể về kiến trúc mà các bản dịch hiện đã tồn tại
	trong bảng trang phần mềm cho không gian địa chỉ "vma->vm_mm"
	tại địa chỉ ảo "địa chỉ" cho "nr" trang liên tiếp.

Thói quen này cũng được gọi ở nhiều nơi khác
	một NULL "vmf".

Một cổng có thể sử dụng thông tin này theo bất kỳ cách nào nó chọn.
	Ví dụ: nó có thể sử dụng sự kiện này để tải trước TLB
	bản dịch cho các cấu hình TLB được quản lý bằng phần mềm.
	Cổng sparc64 hiện đang thực hiện việc này.

Tiếp theo, chúng ta có giao diện xóa bộ đệm.  Nói chung, khi Linux
đang thay đổi ánh xạ vật lý--> ảo hiện có thành một giá trị mới,
trình tự sẽ có một trong các dạng sau::

1) tuôn ra_cache_mm(mm);
	   thay đổi_all_page_tables_of(mm);
	   tuôn ra_tlb_mm(mm);

2) Flush_cache_range(vma, start, end);
	   thay đổi_range_of_page_tables(mm, bắt đầu, kết thúc);
	   tuôn ra_tlb_range(vma, bắt đầu, kết thúc);

3) Flush_cache_page(vma, addr, pfn);
	   set_pte(pte_pointer, new_pte_val);
	   Flush_tlb_page(vma, addr);

Việc xóa mức bộ đệm sẽ luôn được ưu tiên trước tiên vì điều này cho phép
chúng tôi xử lý đúng cách các hệ thống có bộ nhớ đệm nghiêm ngặt và yêu cầu
một bản dịch ảo-> vật lý tồn tại cho một địa chỉ ảo
khi địa chỉ ảo đó bị xóa khỏi bộ đệm.  HyperSparc
cpu là một trong những CPU có thuộc tính này.

Các quy trình xóa bộ đệm dưới đây chỉ cần xử lý việc xóa bộ đệm
đến mức cần thiết cho một CPU cụ thể.  Hầu hết,
những quy trình này phải được triển khai cho các CPU có hầu như
bộ đệm được lập chỉ mục phải được xóa khi ảo -> vật lý
bản dịch được thay đổi hoặc loại bỏ.  Vì vậy, ví dụ, về mặt vật lý
bộ nhớ đệm được gắn thẻ vật lý được lập chỉ mục của bộ xử lý IA32 không cần phải
triển khai các giao diện này vì bộ đệm được đồng bộ hóa hoàn toàn
và không phụ thuộc vào thông tin dịch thuật.

Dưới đây là các thói quen, từng cái một:

1) ZZ0000ZZ

Giao diện này xóa toàn bộ không gian địa chỉ người dùng từ
	các bộ nhớ đệm.  Tức là sau khi chạy sẽ không còn cache
	các dòng liên quan đến 'mm'.

Giao diện này được sử dụng để xử lý toàn bộ không gian địa chỉ
	các thao tác trên bảng trang chẳng hạn như những gì xảy ra trong quá trình thoát và thực thi.

2) ZZ0000ZZ

Giao diện này xóa toàn bộ không gian địa chỉ người dùng từ
	các bộ nhớ đệm.  Tức là sau khi chạy sẽ không còn cache
	các dòng liên quan đến 'mm'.

Giao diện này được sử dụng để xử lý toàn bộ không gian địa chỉ
	các hoạt động của bảng trang chẳng hạn như những gì xảy ra trong quá trình rẽ nhánh.

Tùy chọn này tách biệt với Flush_cache_mm để cho phép một số
	tối ưu hóa cho bộ đệm VIPT.

3) ZZ0000ZZ

Ở đây chúng tôi đang xóa một phạm vi cụ thể của (người dùng) ảo
	địa chỉ từ bộ đệm.  Sau khi chạy sẽ không có
	các mục trong bộ đệm cho 'vma->vm_mm' cho các địa chỉ ảo trong
	phạm vi 'bắt đầu' đến 'kết thúc-1'.

"Vma" là cửa hàng hỗ trợ đang được sử dụng cho khu vực.
	Về cơ bản, điều này được sử dụng cho các hoạt động kiểu munmap().

Giao diện được cung cấp với hy vọng cổng có thể tìm thấy
	một phương pháp hiệu quả phù hợp để loại bỏ nhiều trang
	các vùng có kích thước từ bộ đệm, thay vì có kernel
	gọi tuôn ra_cache_page (xem bên dưới) cho mỗi mục có thể
	đã sửa đổi.

4) ZZ0000ZZ

Lần này chúng ta cần xóa phạm vi có kích thước PAGE_SIZE
	từ bộ đệm.  'Vma' là cấu trúc hỗ trợ được sử dụng bởi
	Linux để theo dõi các vùng mmap'd cho một quy trình,
	không gian địa chỉ có sẵn thông qua vma->vm_mm.  Ngoài ra, người ta có thể
	kiểm tra (vma->vm_flags & VM_EXEC) để xem khu vực này có
	có thể thực thi được (và do đó có thể nằm trong 'bộ đệm hướng dẫn' trong
	Bố cục bộ đệm kiểu "Harvard").

'pfn' biểu thị khung trang vật lý (chuyển giá trị này
	được PAGE_SHIFT để lại để lấy địa chỉ vật lý) đó là 'addr'
	dịch sang.  Chính bản đồ này cần được loại bỏ khỏi
	bộ đệm.

Sau khi chạy, sẽ không có mục nào trong bộ đệm cho
	'vma->vm_mm' cho địa chỉ ảo 'addr' dịch
	thành 'pfn'.

Điều này được sử dụng chủ yếu trong quá trình xử lý lỗi.

5) ZZ0000ZZ

Quy trình này chỉ cần được thực hiện nếu nền tảng sử dụng
	caomem.  Nó sẽ được gọi ngay trước tất cả các kmmap
	bị vô hiệu.

Sau khi chạy, sẽ không có mục nào trong bộ đệm cho
	phạm vi địa chỉ ảo hạt nhân PKMAP_ADDR(0) đến
	PKMAP_ADDR(LAST_PKMAP).

Định tuyến này phải được triển khai trong asm/highmem.h

6) ZZ0000ZZ
   ZZ0001ZZ

Ở đây trong hai giao diện này, chúng tôi đang đưa ra một phạm vi cụ thể
	địa chỉ ảo (kernel) từ bộ đệm.  Sau khi chạy,
	sẽ không có mục nào trong bộ đệm cho địa chỉ kernel
	không gian cho các địa chỉ ảo trong phạm vi 'bắt đầu' đến 'kết thúc-1'.

Thủ tục đầu tiên trong số hai thủ tục này được gọi sau vmap_range()
	đã cài đặt các mục trong bảng trang.  Cái thứ hai được gọi
	trước khi vunmap_range() xóa các mục trong bảng trang.

Tồn tại một loại vấn đề về bộ đệm CPU khác hiện đang tồn tại
yêu cầu một bộ giao diện hoàn toàn khác để xử lý đúng cách.
Vấn đề lớn nhất là bí danh ảo trong bộ đệm dữ liệu
của một bộ xử lý.

Cổng của bạn có dễ bị khử răng cưa ảo trong bộ đệm D của nó không?
Chà, nếu bộ đệm D của bạn hầu như được lập chỉ mục, có kích thước lớn hơn
PAGE_SIZE và không ngăn chặn nhiều dòng bộ đệm cho cùng một
địa chỉ vật lý hiện có cùng một lúc, bạn gặp phải vấn đề này.

Nếu D-cache của bạn gặp vấn đề này, trước tiên hãy xác định asm/shmparam.h SHMLBA
đúng cách, về cơ bản nó phải có kích thước ảo của bạn
địa chỉ D-cache (hoặc nếu kích thước thay đổi thì kích thước lớn nhất có thể
kích thước).  Cài đặt này sẽ buộc lớp SYSv IPC chỉ cho phép người dùng
xử lý bộ nhớ chia sẻ mmap tại địa chỉ là bội số của
giá trị này.

.. note::

  This does not fix shared mmaps, check out the sparc64 port for
  one way to solve this (in particular SPARC_FLAG_MMAPSHARED).

Tiếp theo, bạn phải giải quyết vấn đề bí danh D-cache cho tất cả
các trường hợp khác.  Hãy ghi nhớ thực tế rằng, đối với một trang nhất định
được ánh xạ vào một số không gian địa chỉ người dùng, luôn có ít nhất một địa chỉ nữa
ánh xạ, của hạt nhân trong ánh xạ tuyến tính của nó bắt đầu từ
PAGE_OFFSET.  Vì vậy, ngay lập tức, khi người dùng đầu tiên lập bản đồ cho
trang vật lý vào không gian địa chỉ của nó, ngụ ý D-cache
vấn đề bí danh có khả năng tồn tại vì kernel đã có
ánh xạ trang này tại địa chỉ ảo của nó.

ZZ0000ZZ
  ZZ0001ZZ

Hai thói quen này lưu trữ dữ liệu trong người dùng ẩn danh hoặc COW
	trang.  Nó cho phép một cổng tránh bí danh D-cache một cách hiệu quả
	vấn đề giữa không gian người dùng và kernel.

Ví dụ: một cổng có thể ánh xạ tạm thời 'từ' và 'đến' tới
	địa chỉ ảo kernel trong quá trình sao chép.  Địa chỉ ảo
	đối với hai trang này được chọn theo cách sao cho kernel
	hướng dẫn tải/lưu trữ xảy ra với các địa chỉ ảo
	có cùng "màu" với ánh xạ người dùng của trang.  Sparc64
	ví dụ, sử dụng kỹ thuật này.

Tham số 'addr' cho biết địa chỉ ảo nơi
	cuối cùng người dùng sẽ ánh xạ trang này và 'trang'
	tham số đưa ra một con trỏ tới trang cấu trúc của mục tiêu.

Nếu bí danh D-cache không phải là vấn đề thì hai quy trình này có thể
	chỉ cần gọi trực tiếp memcpy/memset và không làm gì thêm.

ZZ0000ZZ

Thói quen này phải được gọi khi:

a) hạt nhân đã ghi vào một trang nằm trong trang bộ nhớ đệm của trang
	     và/hoặc trong bộ nhớ cao
	  b) hạt nhân sắp đọc từ trang bộ đệm trang và không gian người dùng
	     ánh xạ được chia sẻ/có thể ghi của trang này có khả năng tồn tại.  Lưu ý
	     {get,pin__user_pages{_fast} đã gọi tuôn ra_dcache_folio
	     trên bất kỳ trang nào được tìm thấy trong không gian địa chỉ người dùng và do đó trình điều khiển
	     mã hiếm khi cần tính đến điều này.

	.. note::

	      This routine need only be called for page cache pages
	      which can potentially ever be mapped into the address
	      space of a user process.  So for example, VFS layer code
	      handling vfs symlinks in the page cache need not call
	      this interface at all.

Cụ thể, cụm từ "kernel ghi vào trang bộ nhớ đệm của trang" có nghĩa là
	rằng kernel thực thi các lệnh lưu trữ dữ liệu bẩn trong đó
	trang tại ánh xạ ảo kernel của trang đó.  Điều quan trọng là phải
	tuôn ra ở đây để xử lý bí danh D-cache, để đảm bảo các kho kernel này
	hiển thị với ánh xạ không gian người dùng của trang đó.

Trường hợp tất yếu cũng quan trọng không kém, nếu có người dùng có
	ánh xạ chia sẻ+có thể ghi của tệp này, chúng ta phải đảm bảo rằng kernel
	việc đọc các trang này sẽ thấy các cửa hàng gần đây nhất do người dùng thực hiện.

Nếu bí danh D-cache không phải là vấn đề, quy trình này có thể được xác định một cách đơn giản
	như một sự thay đổi trên kiến ​​trúc đó.

Có một chút được dành riêng trong folio->flags (PG_arch_1) là "kiến trúc
	riêng tư".  Hạt nhân đảm bảo rằng, đối với các trang pagecache, nó sẽ
	xóa bit này khi một trang như vậy lần đầu tiên vào bộ đệm trang.

Điều này cho phép các giao diện này được triển khai nhiều hơn nữa
	một cách hiệu quả.  Nó cho phép người ta "trì hoãn" (có lẽ là vô thời hạn) việc
	tuôn ra thực tế nếu hiện tại không có quá trình người dùng ánh xạ này
	trang.  Xem Flush_dcache_folio và update_mmu_cache_range của sparc64
	triển khai để biết ví dụ về cách thực hiện việc này.

Ý tưởng là, đầu tiên là tại thời điểm Flush_dcache_folio(), nếu
	folio_flush_mapping() trả về một ánh xạ và maps_mapped() trên đó
	ánh xạ trả về %false, chỉ cần đánh dấu trang riêng tư về kiến trúc
	bit cờ.  Sau đó, trong update_mmu_cache_range(), việc kiểm tra được thực hiện
	của bit cờ này và nếu thiết lập thì quá trình xóa được thực hiện và bit cờ
	được xóa.

	.. important::

			It is often important, if you defer the flush,
			that the actual flush occurs on the same CPU
			as did the cpu stores into the page to make it
			dirty.  Again, see sparc64 for examples of how
			to deal with this.

  ``void copy_to_user_page(struct vm_area_struct *vma, struct page *page,
  unsigned long user_vaddr, void *dst, void *src, int len)``
  ``void copy_from_user_page(struct vm_area_struct *vma, struct page *page,
  unsigned long user_vaddr, void *dst, void *src, int len)``

Khi kernel cần copy dữ liệu vào ra tùy ý
	của các trang người dùng tùy ý (ví dụ: đối với ptrace()) nó sẽ sử dụng
	hai thói quen này.

Bất kỳ hoạt động xóa bộ đệm cần thiết nào hoặc các hoạt động kết hợp khác
	điều cần xảy ra sẽ xảy ra ở đây.  Nếu bộ xử lý
	bộ đệm lệnh không rình mò các cửa hàng cpu, nó rất
	có khả năng là bạn sẽ cần phải xóa bộ đệm hướng dẫn
	cho copy_to_user_page().

ZZ0000ZZ

Khi kernel cần truy cập nội dung của một ẩn danh
	trang, nó gọi hàm này (hiện tại chỉ
	get_user_pages()).  Lưu ý: cố tình tuôn ra_dcache_folio()
	không hoạt động đối với một trang ẩn danh.  Mặc định
	việc triển khai là không nên (và nên duy trì như vậy đối với tất cả các
	kiến trúc).  Đối với các kiến trúc không mạch lạc, nó sẽ tuôn ra
	bộ đệm của trang tại vmaddr.

ZZ0000ZZ

Khi kernel lưu vào địa chỉ mà nó sẽ thực thi
	hết (ví dụ khi tải mô-đun), hàm này được gọi.

Nếu icache không rình mò các cửa hàng thì thủ tục này sẽ cần
	để xả nó.

ZZ0000ZZ

Tất cả chức năng của Flush_icache_page có thể được triển khai trong
	Flush_dcache_folio và update_mmu_cache_range. Trong tương lai, niềm hy vọng
	là loại bỏ hoàn toàn giao diện này.

Loại API cuối cùng dành cho I/O với địa chỉ bí danh có chủ ý
phạm vi bên trong kernel.  Những bí danh như vậy được thiết lập bằng cách sử dụng
vmap/vmalloc API.  Vì I/O kernel đi qua các trang vật lý nên I/O
hệ thống con giả định rằng ánh xạ người dùng và ánh xạ offset kernel là
bí danh duy nhất.  Điều này không đúng với bí danh vmap, vì vậy mọi thứ trong
kernel đang cố gắng thực hiện I/O cho các vùng vmap phải quản lý thủ công
sự mạch lạc.  Nó phải làm điều này bằng cách xóa phạm vi vmap trước khi thực hiện
I/O và vô hiệu hóa nó sau khi I/O trả về.

ZZ0000ZZ

xóa bộ nhớ đệm kernel cho một dải địa chỉ ảo nhất định trong
       khu vực vmap.  Điều này nhằm đảm bảo rằng mọi dữ liệu trong kernel
       được sửa đổi trong phạm vi vmap được hiển thị cho vật lý
       trang.  Thiết kế nhằm làm cho khu vực này trở nên an toàn khi thực hiện I/O.
       Lưu ý rằng API này thực hiện ZZ0000ZZ cũng xóa bí danh bản đồ bù đắp
       của khu vực.

ZZ0000ZZ

bộ đệm cho một dải địa chỉ ảo nhất định trong vùng vmap
       điều này ngăn bộ xử lý làm cho bộ nhớ đệm cũ bằng cách
       đọc dữ liệu một cách suy đoán trong khi thao tác I/O đang diễn ra với
       các trang vật lý.  Điều này chỉ cần thiết cho việc đọc dữ liệu vào
       khu vực vmap.
