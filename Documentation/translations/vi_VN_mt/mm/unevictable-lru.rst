.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/unevictable-lru.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Cơ sở hạ tầng LRU không thể tránh khỏi
==============================

.. contents:: :local:


Giới thiệu
============

Tài liệu này mô tả "LRU không thể tránh khỏi" của trình quản lý bộ nhớ Linux
cơ sở hạ tầng và việc sử dụng cơ sở hạ tầng này để quản lý một số loại "không thể tránh khỏi"
folio.

Tài liệu cố gắng cung cấp lý do tổng thể đằng sau cơ chế này
và lý do cơ bản cho một số quyết định thiết kế đã thúc đẩy
thực hiện.  Cơ sở lý luận của thiết kế sau này được thảo luận trong bối cảnh của một
mô tả thực hiện.  Phải thừa nhận rằng, người ta có thể có được việc thực hiện
chi tiết - "nó làm gì?" - bằng cách đọc mã.  Người ta hy vọng rằng
các mô tả bên dưới sẽ tăng thêm giá trị bằng cách cung cấp câu trả lời cho "tại sao nó lại làm như vậy?".



LRU không thể tránh khỏi
===================

Cơ sở LRU không thể tránh khỏi bổ sung thêm danh sách LRU để theo dõi những điều không thể tránh khỏi
folios và ẩn các folios này khỏi vmscan.  Cơ chế này dựa trên một bản vá
của Larry Woodman của Red Hat để giải quyết một số vấn đề về khả năng mở rộng với folio
đòi lại trong Linux.  Các vấn đề đã được quan sát thấy tại các địa điểm của khách hàng trên diện rộng
hệ thống bộ nhớ x86_64.

Để minh họa điều này bằng một ví dụ, nền tảng x86_64 không phải NUMA có 128GB
bộ nhớ chính sẽ có hơn 32 triệu trang 4k trong một nút.  Khi một lượng lớn
một phần trong số các trang này không thể bị xóa vì bất kỳ lý do gì [xem bên dưới], vmscan
sẽ dành nhiều thời gian để quét danh sách LRU để tìm phần nhỏ
của các trang có thể bị loại bỏ.  Điều này có thể dẫn đến tình huống trong đó tất cả các CPU đều
dành 100% thời gian của họ cho vmscan hàng giờ hoặc hàng ngày liên tục, với hệ thống
hoàn toàn không phản hồi.

Danh sách không thể xóa được đề cập đến các loại trang không thể xóa sau đây:

* Những người thuộc sở hữu của ramfs.

* Những thứ thuộc sở hữu của tmpfs với tùy chọn gắn kết noswap.

* Những vùng được ánh xạ vào các vùng bộ nhớ dùng chung của SHM_LOCK.

* Những thứ được ánh xạ vào VM_LOCKED [mlock()ed] VMAs.

Cơ sở hạ tầng cũng có thể xử lý các điều kiện khác khiến cho các trang
không thể tránh khỏi, theo định nghĩa hoặc theo hoàn cảnh, trong tương lai.


Danh sách Folio LRU không thể tránh khỏi
------------------------------

Danh sách folio LRU không thể tránh khỏi là một lời nói dối.  Nó chưa bao giờ được đặt hàng LRU
danh sách, nhưng là người bạn đồng hành với tệp và tệp ẩn danh theo thứ tự LRU, hoạt động và
danh sách folio không hoạt động; và bây giờ nó thậm chí còn không phải là một danh sách folio.  Nhưng theo sau
quy ước quen thuộc, ở đây trong tài liệu này và trong nguồn, chúng tôi thường
hãy tưởng tượng nó như một danh sách folio LRU thứ năm.

Cơ sở hạ tầng LRU không thể tránh khỏi bao gồm danh sách LRU bổ sung, trên mỗi nút
được gọi là danh sách "không thể tránh khỏi" và cờ folio liên quan, PG_unevictable, để
chỉ ra rằng folio đang được quản lý trong danh sách không thể hủy bỏ.

Cờ PG_unevictable tương tự và loại trừ lẫn nhau với cờ
Cờ PG_active ở chỗ nó cho biết một folio nằm trong danh sách LRU nào khi
PG_lru được đặt.

Cơ sở hạ tầng LRU không thể tránh khỏi duy trì các folio không thể tránh khỏi như thể chúng là
trên danh sách LRU bổ sung vì một số lý do:

(1) Chúng ta phải "xử lý những lá bài không thể tránh khỏi giống như cách chúng ta đối xử với những lá bài khác trong
     hệ thống - có nghĩa là chúng ta có thể sử dụng cùng một mã để thao tác với chúng,
     cùng một mã để cô lập chúng (để di chuyển, v.v.), cùng một mã để theo dõi
     về số liệu thống kê, v.v..." [Rik van Riel]

(2) Chúng tôi muốn có thể di chuyển các folios không thể tránh khỏi giữa các nút để lấy bộ nhớ
     chống phân mảnh, quản lý khối lượng công việc và cắm nóng bộ nhớ.  Nhân Linux
     chỉ có thể di chuyển các folio mà nó có thể tách biệt thành công khỏi LRU
     danh sách (hoặc các folio "Có thể di chuyển": không được xem xét ở đây).  Nếu chúng ta muốn
     duy trì các folio ở nơi khác ngoài danh sách giống LRU, nơi chúng có thể
     được phát hiện bởi folio_isolate_lru(), chúng tôi sẽ ngăn chặn việc di chuyển của chúng.

Danh sách không thể cưỡng lại không phân biệt giữa sao lưu tập tin và
folio ẩn danh, được hỗ trợ trao đổi.  Sự khác biệt này chỉ quan trọng
trong khi các folio trên thực tế có thể bị trục xuất.

Danh sách không thể tránh khỏi được hưởng lợi từ việc "phân mảng" LRU trên mỗi nút
danh sách và số liệu thống kê ban đầu được đề xuất và đăng tải bởi Christoph Lameter.


Tương tác nhóm kiểm soát bộ nhớ
--------------------------------

Cơ sở LRU không thể tránh khỏi tương tác với nhóm kiểm soát bộ nhớ [còn gọi là
bộ điều khiển bộ nhớ; xem Tài liệu/admin-guide/cgroup-v1/memory.rst] của
mở rộng lru_list enum.

Cấu trúc dữ liệu của bộ điều khiển bộ nhớ tự động nhận được một nút không thể xóa được
danh sách là kết quả của việc "phân mảng" các danh sách LRU trên mỗi nút (một cho mỗi
phần tử enum lru_list).  Bộ điều khiển bộ nhớ theo dõi chuyển động của các trang tới
và khỏi danh sách không thể tránh khỏi.

Khi nhóm điều khiển bộ nhớ chịu áp lực bộ nhớ, bộ điều khiển sẽ
không cố gắng lấy lại các trang trong danh sách không thể hủy bỏ.  Cái này có một vài
tác dụng:

(1) Bởi vì các trang bị "ẩn" khỏi việc lấy lại trong danh sách không thể hủy bỏ, nên
     quá trình lấy lại có thể hiệu quả hơn, chỉ xử lý các trang có
     cơ hội được thu hồi.

(2) Mặt khác, nếu có quá nhiều trang được tính vào nhóm kiểm soát
     không thể loại bỏ được, phần có thể loại bỏ được của tập hợp các nhiệm vụ trong
     nhóm điều khiển có thể không vừa với bộ nhớ khả dụng.  Điều này có thể gây ra
     nhóm điều khiển thực hiện các nhiệm vụ tiêu diệt hoặc tiêu diệt OOM.


.. _mark_addr_space_unevict:

Đánh dấu các không gian địa chỉ không thể tránh khỏi
----------------------------------

Đối với các cơ sở như ramfs, không có trang nào được đính kèm vào không gian địa chỉ
có thể bị đuổi ra khỏi nhà.  Để ngăn chặn việc trục xuất bất kỳ trang nào như vậy, AS_UNEVICTABLE
cờ không gian địa chỉ được cung cấp và điều này có thể được xử lý bởi hệ thống tập tin
sử dụng một số hàm bao bọc:

* ZZ0000ZZ

Đánh dấu không gian địa chỉ là hoàn toàn không thể xóa được.

* ZZ0000ZZ

Đánh dấu không gian địa chỉ là có thể bị trục xuất.

* ZZ0000ZZ

Truy vấn không gian địa chỉ và trả về true nếu nó hoàn toàn
	không thể tránh khỏi.

Chúng hiện được sử dụng ở ba nơi trong kernel:

(1) Bằng các ramf để đánh dấu không gian địa chỉ của các nút của nó khi chúng được tạo,
     và dấu này tồn tại suốt đời của inode.

(2) Bằng SYSV SHM để đánh dấu các không gian địa chỉ của SHM_LOCK cho đến khi SHM_UNLOCK được gọi.
     Lưu ý rằng SHM_LOCK không bắt buộc phải đánh trang vào các trang bị khóa nếu chúng
     đổi chỗ; ứng dụng phải chạm vào các trang theo cách thủ công nếu muốn
     đảm bảo chúng có trong bộ nhớ.

(3) Bằng trình điều khiển i915 để đánh dấu không gian địa chỉ được ghim cho đến khi được bỏ ghim. các
     lượng bộ nhớ không thể xóa được đánh dấu bởi trình điều khiển i915 gần như bị giới hạn
     kích thước đối tượng trong debugfs/dri/0/i915_gem_objects.


Phát hiện các trang không thể tránh khỏi
---------------------------

Hàm folio_evictable() trong mm/internal.h xác định xem một folio có phải là
có thể bị trục xuất hoặc không sử dụng chức năng truy vấn được nêu ở trên [xem phần
ZZ0000ZZ]
để kiểm tra cờ AS_UNEVICTABLE.

Đối với các không gian địa chỉ được đánh dấu sau khi được điền (dưới dạng vùng SHM
có thể), hành động khóa (ví dụ SHM_LOCK) có thể lười biếng và không cần phải điền
các bảng trang cho vùng cũng vậy, ví dụ như mlock(), cũng như không cần tạo
bất kỳ nỗ lực đặc biệt nào nhằm đẩy bất kỳ trang nào trong khu vực SHM_LOCK'd vào trạng thái không thể xóa được
danh sách.  Thay vào đó, vmscan sẽ thực hiện việc này nếu và khi nó gặp các folio trong quá trình
một cuộc quét cải tạo.

Khi thực hiện hành động mở khóa (chẳng hạn như SHM_UNLOCK), trình mở khóa (ví dụ: shmctl()) phải quét
các trang trong khu vực và “giải cứu” chúng khỏi danh sách không thể tránh khỏi nếu không có cách nào khác
tình trạng đang khiến họ không thể bị trục xuất.  Nếu một khu vực không thể tránh khỏi bị phá hủy,
các trang cũng được “giải cứu” khỏi danh sách không thể tránh khỏi trong quá trình
giải phóng họ.

folio_evictable() cũng kiểm tra các folio bị khóa bằng cách gọi
folio_test_mlocked(), được thiết lập khi một folio bị lỗi thành một
VM_LOCKED VMA hoặc được tìm thấy trong VMA là VM_LOCKED.


Cách xử lý các Folio không thể tránh khỏi của Vmscan
---------------------------------------

Nếu các folio không thể tránh khỏi bị loại bỏ trong đường dẫn lỗi hoặc được chuyển đến các danh mục không thể tránh khỏi
list tại thời điểm mlock() hoặc mmap(), vmscan sẽ không gặp các folio cho đến khi chúng
lại có thể bị trục xuất (thông qua munlock() chẳng hạn) và đã được "giải cứu"
khỏi danh sách không thể tránh khỏi.  Tuy nhiên, có thể có những tình huống mà chúng ta quyết định,
vì lợi ích thiết thực, hãy để lại một tờ giấy không thể cưỡng lại được trên một trong những tờ giấy thường xuyên
Danh sách LRU đang hoạt động/không hoạt động để vmscan xử lý.  vmscan kiểm tra như vậy
folios trong tất cả các hàm thu nhỏ_{active|inactive|folio__list() và sẽ
"tiêu hủy" những folio mà nó gặp phải: nghĩa là nó chuyển hướng những folio đó sang
danh sách không thể xóa được cho nhóm bộ nhớ và nút đang được quét.

Có thể có trường hợp một folio được ánh xạ vào VM_LOCKED VMA,
nhưng folio không có bộ cờ bị khóa.  Những folio như vậy sẽ làm cho
tất cả đều hướng tới thu nhỏ_active_list() hoặc thu nhỏ_folio_list() nơi họ
sẽ được phát hiện khi vmscan đi trên bản đồ ngược lại trong folio_referenced()
hoặc try_to_unmap().  Folio sẽ bị loại vào danh sách không thể tránh khỏi khi nó
được giải phóng bởi máy thu nhỏ.

Để "loại bỏ" một folio không thể tránh khỏi, vmscan chỉ cần đặt folio đó trở lại
danh sách LRU sử dụng folio_putback_lru() - thao tác nghịch đảo với
folio_isolate_lru() - sau khi bỏ khóa folio.  Bởi vì
điều kiện làm cho folio không thể bị loại bỏ có thể thay đổi một khi folio
được mở khóa, __pagevec_lru_add_fn() sẽ kiểm tra lại trạng thái không thể tránh khỏi
của một folio trước khi đặt nó vào danh sách không thể tránh khỏi.


Trang MLOCKED
=============

Danh sách folio không thể tránh khỏi cũng hữu ích cho mlock(), ngoài ramfs và
SYSV SHM.  Lưu ý rằng mlock() chỉ khả dụng trong các tình huống CONFIG_MMU=y; trong
Trong các trường hợp NOMMU, tất cả ánh xạ đều được khóa hiệu quả.


Lịch sử
-------

Cơ sở hạ tầng "Các trang bị khóa không thể tránh khỏi" dựa trên công việc ban đầu
được đăng bởi Nick Pigin trong bản vá RFC có tựa đề "mm: các trang đã bị khóa khỏi LRU".
Nick đã đăng bản vá của mình để thay thế cho bản vá do Christoph Lameter đăng
để đạt được mục tiêu tương tự: ẩn các trang bị khóa khỏi vmscan.

Trong bản vá của Nick, anh ấy đã sử dụng một trong các trường liên kết danh sách LRU của trang cấu trúc làm số đếm
trong số VM_LOCKED VMAs ánh xạ trang (Rik van Riel đã có cùng ý tưởng này ba năm
trước đó).  Nhưng việc sử dụng trường liên kết để đếm đã ngăn cản việc quản lý
của các trang trong danh sách LRU và do đó các trang bị khóa không thể di chuyển được như
folio_isolate_lru() không thể phát hiện ra chúng và trường liên kết danh sách LRU cũng không
có sẵn cho hệ thống con di chuyển.

Nick đã giải quyết vấn đề này bằng cách đưa các trang bị khóa trở lại danh sách LRU trước đó
cố gắng cô lập chúng, do đó bỏ đi số lượng VMA VM_LOCKED.  Khi nào
Bản vá của Nick đã được tích hợp với tác phẩm LRU không thể tránh khỏi, số lượng là
được thay thế bằng cách đi theo bản đồ ngược lại khi khóa cửa, để xác định xem có bất kỳ
các VMA VM_LOCKED khác vẫn ánh xạ trang.

Tuy nhiên, việc đi theo bản đồ ngược cho từng trang khi khóa munlock là điều không tốt và
không hiệu quả và có thể dẫn đến tranh chấp nghiêm trọng về khóa rmap của tệp,
khi nhiều quá trình bị khóa đang cố gắng thoát ra.  Trong phiên bản 5.18,
ý tưởng giữ mlock_count trong trường liên kết danh sách LRU không thể tránh khỏi đã được hồi sinh và
đưa vào hoạt động mà không ngăn cản việc di chuyển các trang bị khóa.  Đây là lý do tại sao
"Danh sách LRU không thể tránh khỏi" hiện không thể là danh sách các trang được liên kết; nhưng đã có
dù sao thì danh sách liên kết đó cũng không được sử dụng - mặc dù kích thước của nó được duy trì cho meminfo.


Quản lý cơ bản
----------------

các trang bị khóa - các trang được ánh xạ vào VM_LOCKED VMA - là một loại không thể tránh khỏi
trang.  Khi một trang như vậy được hệ thống con quản lý bộ nhớ "chú ý",
folio được đánh dấu bằng cờ PG_mlocked.  Điều này có thể được thao tác bằng cách sử dụng
Các hàm folio_set_mlocked() và folio_clear_mlocked().

Một trang PG_mlocked sẽ được đưa vào danh sách không thể hủy bỏ khi nó được thêm vào
LRU.  Những trang như vậy có thể được quản lý bộ nhớ "chú ý" ở một số nơi:

(1) trong trình xử lý cuộc gọi hệ thống mlock()/mlock2()/mlockall();

(2) trong trình xử lý cuộc gọi hệ thống mmap() khi mmap một vùng bằng
     Cờ MAP_LOCKED;

(3) ánh xạ một vùng trong tác vụ có tên mlockall() bằng MCL_FUTURE
     cờ;

(4) trong đường dẫn lỗi và khi phân đoạn ngăn xếp VM_LOCKED được mở rộng; hoặc

(5) như đã đề cập ở trên, trong vmscan:shrink_folio_list() khi cố gắng
     lấy lại một trang trong VM_LOCKED VMA bằng folio_referenced() hoặc try_to_unmap().

các trang bị khóa sẽ được mở khóa và giải cứu khỏi danh sách không thể gỡ bỏ khi:

(1) được ánh xạ trong phạm vi được mở khóa thông qua lệnh gọi hệ thống munlock()/munlockall();

(2) munmap()'d trong số VM_LOCKED VMA cuối cùng ánh xạ trang, bao gồm
     hủy ánh xạ khi thoát nhiệm vụ;

(3) khi trang bị cắt bớt khỏi VM_LOCKED VMA cuối cùng của tệp được mmapped;
     hoặc

(4) trước một trang là COW'd trong VM_LOCKED VMA.


mlock()/mlock2()/mlockall() Xử lý cuộc gọi hệ thống
------------------------------------------------

Trình xử lý cuộc gọi hệ thống mlock(), mlock2() và mlockall() tiến tới mlock_fixup()
cho mỗi VMA trong phạm vi được chỉ định bởi cuộc gọi.  Trong trường hợp mlockall(),
đây là toàn bộ không gian địa chỉ hoạt động của tác vụ.  Lưu ý rằng mlock_fixup()
được sử dụng cho cả việc khóa và khóa một phạm vi bộ nhớ.  Cuộc gọi đến mlock()
một VM_LOCKED VMA đã có, hoặc tới munlock() một VMA không phải là VM_LOCKED, là
được coi là không hoạt động và mlock_fixup() chỉ đơn giản trả về.

Nếu VMA vượt qua một số bộ lọc như được mô tả trong "Lọc VMA đặc biệt"
bên dưới, mlock_fixup() sẽ cố gắng hợp nhất VMA với các hàng xóm của nó hoặc tách
tắt một tập hợp con của VMA nếu phạm vi không bao phủ toàn bộ VMA.  Bất kỳ trang nào
đã có trong VMA sau đó được đánh dấu là bị khóa bởi mlock_folio() thông qua
mlock_pte_range() qua walk_page_range() qua mlock_vma_pages_range().

Trước khi quay lại từ cuộc gọi hệ thống, do_mlock() hoặc mlockall() sẽ gọi
__mm_populate() bị lỗi ở các trang còn lại thông qua get_user_pages() và
đánh dấu những trang đó là bị khóa vì chúng bị lỗi.

Lưu ý rằng VMA đang bị khóa có thể được ánh xạ với PROT_NONE.  Trong trường hợp này,
get_user_pages() sẽ không thể xảy ra lỗi trên các trang.  Không sao đâu.  Nếu trang
cuối cùng có bị lỗi ở VM_LOCKED VMA này không, chúng sẽ được xử lý theo
đường dẫn lỗi - đó cũng là cách xử lý các vùng MLOCK_ONFAULT của mlock2().

Đối với mỗi PTE (hoặc PMD) bị lỗi thành VMA, trang thêm chức năng rmap
gọi mlock_vma_folio(), gọi mlock_folio() khi VMA là VM_LOCKED
(trừ khi đó là ánh xạ PTE của một phần của một trang lớn trong suốt).  Hoặc khi
đó là một trang ẩn danh mới được phân bổ, các cuộc gọi folio_add_lru_vma()
thay vào đó, mlock_new_folio(): tương tự như mlock_folio(), nhưng có thể cải tiến hơn
phán quyết, vì trang này được tổ chức độc quyền và được biết là chưa có trên LRU.

mlock_folio() đặt PG_mlocked ngay lập tức, sau đó đặt trang vào CPU
mlock folio batch, để sắp xếp các phần công việc còn lại sẽ được thực hiện trong lru_lock bởi
__mlock_folio().  __mlock_folio() đặt PG_unevictable, khởi tạo mlock_count
và chuyển trang sang trạng thái không thể xóa được ("LRU không thể xóa được", nhưng với
mlock_count thay cho luồng LRU).  Hoặc nếu trang đã có PG_lru
và PG_unevictable và PG_mlocked, nó chỉ đơn giản tăng mlock_count.

Nhưng trên thực tế, điều đó có thể không hoạt động lý tưởng: trang có thể chưa có trên LRU hoặc
nó có thể đã được cách ly tạm thời khỏi LRU.  Trong những trường hợp như vậy, mlock_count
trường không thể chạm vào nhưng sẽ được đặt thành 0 sau khi __munlock_folio()
trả lại trang về "LRU".  Các cuộc đua cấm mlock_count được đặt thành 1 thì:
thay vì có nguy cơ mắc kẹt một trang vô thời hạn vì không thể tránh khỏi, luôn mắc lỗi
mlock_count ở mức thấp, để khi khóa trang, trang sẽ được giải cứu
một LRU có thể bị trục xuất, sau đó có thể bị khóa lại sau nếu vmscan tìm thấy nó trong một
VM_LOCKED VMA.


Lọc các VMA đặc biệt
----------------------

mlock_fixup() lọc một số loại VMA "đặc biệt":

1) VMAs có bộ VM_IO hoặc VM_PFNMAP bị bỏ qua hoàn toàn.  Những trang đằng sau
   những ánh xạ này vốn đã được ghim nên chúng ta không cần đánh dấu chúng là
   mlocked.  Trong mọi trường hợp, hầu hết các trang đều không có trang cấu trúc để làm như vậy.
   đánh dấu trang.  Vì lý do này, get_user_pages() sẽ không thành công đối với các VMA này,
   vì vậy không có ý nghĩa gì khi cố gắng đến thăm họ.

2) Trang Hugetlbfs ánh xạ VMAs đã được ghim vào bộ nhớ một cách hiệu quả.  Chúng tôi
   không cần cũng không muốn mlock() những trang này.  Nhưng __mm_populate() bao gồm
   phạm vi Hugetlbfs, phân bổ các trang lớn và điền PTE.

3) VMAs với VM_DONTEXPAND nói chung là ánh xạ không gian người dùng của các trang kernel,
   chẳng hạn như trang VDSO, các trang kênh chuyển tiếp, v.v. Những trang này vốn là
   không thể tránh khỏi và không được quản lý trong danh sách LRU.  __mm_populate() bao gồm
   các phạm vi này, điền PTE nếu chưa được điền.

4) VMAs có bộ VM_MIXEDMAP không được đánh dấu là VM_LOCKED, nhưng __mm_populate()
   bao gồm các phạm vi này, điền PTE nếu chưa được điền.

Lưu ý rằng đối với tất cả các VMA đặc biệt này, mlock_fixup() không đặt
Cờ VM_LOCKED.  Vì vậy, chúng ta sẽ không phải giải quyết chúng sau này trong quá trình
munlock(), munmap() hoặc thoát tác vụ.  mlock_fixup() cũng không tính đến những điều này
VMAs đối với "locked_vm" của nhiệm vụ.


munlock()/munlockall() Xử lý cuộc gọi hệ thống
-------------------------------------------

Lệnh gọi hệ thống munlock() và munlockall() được xử lý giống nhau
mlock_fixup() hoạt động giống như các lệnh gọi hệ thống mlock(), mlock2() và mlockall().
Nếu được gọi để khóa một VMA đã được khóa, mlock_fixup() chỉ cần trả về.
Do tính năng lọc VMA đã thảo luận ở trên nên VM_LOCKED sẽ không được đặt trong
bất kỳ VMA "đặc biệt" nào.  Vì vậy, những VMA đó sẽ bị bỏ qua đối với munlock.

Nếu VMA là VM_LOCKED, mlock_fixup() lại cố gắng hợp nhất hoặc tách
phạm vi quy định.  Sau đó, tất cả các trang trong VMA sẽ được khóa bởi munlock_folio() thông qua
mlock_pte_range() qua walk_page_range() qua mlock_vma_pages_range() - giống nhau
chức năng được sử dụng khi khóa phạm vi VMA, với các cờ mới cho VMA biểu thị
rằng đó là munlock() đang được thực hiện.

munlock_folio() sử dụng mlock pagevec để sắp xếp các công việc cần thực hiện
dưới lru_lock bởi __munlock_folio().  __munlock_folio() giảm
mlock_count của folio và khi giá trị đó về 0, nó sẽ xóa cờ bị khóa
và xóa cờ không thể xóa, chuyển folio từ trạng thái không thể xóa
đến LRU không hoạt động.

Nhưng trong thực tế điều đó có thể không hoạt động lý tưởng: folio có thể chưa đạt tới
"LRU không thể tránh khỏi" hoặc có thể nó đã tạm thời bị cô lập khỏi nó.  trong
những trường hợp đó trường mlock_count của nó không sử dụng được và phải được coi là 0: vì vậy
rằng folio sẽ được giải cứu vào LRU có thể bị trục xuất, sau đó có thể bị khóa
một lần nữa nếu vmscan tìm thấy nó trong VM_LOCKED VMA.


Di chuyển các trang MLOCKED
-----------------------

Một trang đang được di chuyển đã bị tách biệt khỏi danh sách LRU và được giữ lại
bị khóa khi hủy ánh xạ trang, cập nhật mục nhập không gian địa chỉ của trang
và sao chép nội dung và trạng thái cho đến khi mục nhập bảng trang được
được thay thế bằng một mục đề cập đến trang mới.  Linux hỗ trợ di chuyển
của các trang bị khóa và các trang không thể gỡ bỏ khác.  PG_mlocked bị xóa khỏi
trang cũ khi nó chưa được ánh xạ khỏi VM_LOCKED VMA cuối cùng và được đặt khi
trang mới được ánh xạ thay cho mục nhập di chuyển trong VM_LOCKED VMA.  Nếu trang
không thể bị loại bỏ vì bị khóa, PG_unevictable theo sau PG_mlocked; nhưng nếu
trang không thể bị loại bỏ vì những lý do khác, PG_unevictable được sao chép một cách rõ ràng.

Lưu ý rằng việc di chuyển trang có thể chạy đua với việc khóa hoặc khóa của cùng một trang.
Hầu như không có vấn đề gì vì việc di chuyển trang yêu cầu hủy ánh xạ tất cả PTE của
trang cũ (bao gồm cả munlock trong đó VM_LOCKED), sau đó ánh xạ vào trang mới
(bao gồm cả mlock nơi VM_LOCKED).  Các khóa bảng trang cung cấp đủ
đồng bộ hóa.

Tuy nhiên, vì mlock_vma_pages_range() bắt đầu bằng cách đặt VM_LOCKED trên VMA,
trước khi khóa bất kỳ trang nào đã có, nếu một trong những trang đó đã được di chuyển
trước khi mlock_pte_range() đạt đến nó, nó sẽ được tính hai lần trong mlock_count.
Để ngăn chặn điều đó, mlock_vma_pages_range() tạm thời đánh dấu VMA là VM_IO,
để mlock_vma_folio() sẽ bỏ qua nó.

Để hoàn tất việc di chuyển trang, chúng tôi đặt các trang cũ và mới vào LRU
sau đó.  Trang "không cần thiết" - trang cũ về thành công, trang mới về thất bại -
được giải phóng khi số lượng tham chiếu do quá trình di chuyển nắm giữ được giải phóng.


Nén các trang MLOCKED
------------------------

Bản đồ bộ nhớ có thể được quét để tìm các vùng có thể nén và hành vi mặc định
là cho phép di chuyển những trang không thể tránh khỏi.  /proc/sys/vm/compact_unevictable_allowed
kiểm soát hành vi này (xem Tài liệu/admin-guide/sysctl/vm.rst).  công việc
quá trình nén chủ yếu được xử lý bởi mã di chuyển trang và công việc tương tự
quy trình như được mô tả trong Di chuyển trang MLOCKED sẽ được áp dụng.


MLOCKING Trang lớn trong suốt
-------------------------------

Một trang lớn trong suốt được thể hiện bằng một mục duy nhất trong danh sách LRU.
Do đó, chúng tôi chỉ có thể tạo ra toàn bộ trang ghép không thể thu hồi được chứ không phải
các trang con riêng lẻ.

Nếu người dùng cố gắng mlock() một phần của một trang lớn và không có người dùng nào mlock()
toàn bộ trang lớn, chúng tôi muốn phần còn lại của trang có thể được lấy lại.

Chúng ta không thể chia trang thành một phần mlock() như chia_huge_page() có thể
thất bại và chế độ lỗi gián đoạn mới cho cuộc gọi hệ thống là điều không mong muốn.

Chúng tôi xử lý vấn đề này bằng cách giữ các trang lớn đã được khóa PTE trong danh sách LRU có thể bị trục xuất:
PMD trên đường viền của VM_LOCKED VMA sẽ được chia thành bảng PTE.

Bằng cách này, vmscan có thể truy cập được trang lớn.  Dưới áp lực của bộ nhớ,
trang sẽ được chia nhỏ, các trang con thuộc về VM_LOCKED VMAs sẽ được di chuyển
đến LRU không thể cưỡng lại được và phần còn lại có thể được lấy lại.

Số tiền không thể tránh khỏi và bị khóa của /proc/meminfo không bao gồm các phần đó
của một trang lớn trong suốt chỉ được ánh xạ bởi PTE trong VM_LOCKED VMA.


mmap(MAP_LOCKED) Xử lý cuộc gọi hệ thống
-------------------------------------

Ngoài các lệnh gọi hệ thống mlock(), mlock2() và mlockall(), một ứng dụng
có thể yêu cầu khóa một vùng bộ nhớ bằng cách cung cấp cờ MAP_LOCKED
đến cuộc gọi mmap().  Tuy nhiên, có một sự khác biệt quan trọng và tinh tế ở đây.
mmap() + mlock() sẽ thất bại nếu phạm vi không thể bị lỗi (ví dụ: vì
mm_populate không thành công) và trả về với ENOMEM trong khi mmap(MAP_LOCKED) sẽ không thất bại.
Vùng được mmp vẫn sẽ có các thuộc tính của vùng bị khóa - các trang sẽ không
bị tráo đổi - nhưng lỗi trang lớn đối với bộ nhớ bị lỗi vẫn có thể xảy ra.

Hơn nữa, bất kỳ lệnh gọi mmap() hoặc brk() nào đều mở rộng vùng heap bằng một tác vụ
mà trước đó đã gọi mlockall() với cờ MCL_FUTURE sẽ dẫn đến
trong bộ nhớ mới được ánh xạ đang bị khóa.  Trước điều không thể tránh khỏi/mlock
thay đổi, kernel chỉ đơn giản gọi là make_pages_ Present() để phân bổ các trang
và điền vào bảng trang.

Để khóa một phạm vi bộ nhớ trong cơ sở hạ tầng không thể tránh khỏi/mlock,
lệnh gọi hàm xử lý mmap() và mở rộng không gian địa chỉ tác vụ
populate_vma_page_range() chỉ định vma và dải địa chỉ cho mlock.


munmap()/exit()/exec() Xử lý cuộc gọi hệ thống
-------------------------------------------

Khi hủy ánh xạ một vùng bộ nhớ bị khóa, dù bằng lệnh gọi rõ ràng tới
munmap() hoặc thông qua việc hủy bản đồ nội bộ từ quá trình xử lý exit() hoặc exec(), chúng ta phải
khóa các trang nếu chúng tôi xóa VM_LOCKED VMA cuối cùng ánh xạ các trang.
Trước những thay đổi không thể tránh khỏi/mlock, mlocking không đánh dấu các trang theo bất kỳ cách nào.
theo cách này, vì vậy việc hủy ánh xạ chúng không cần xử lý.

Đối với mỗi PTE (hoặc PMD) không được ánh xạ khỏi các lệnh gọi VMA, folio_remove_rmap_*()
munlock_vma_folio(), gọi munlock_folio() khi VMA là VM_LOCKED
(trừ khi đó là ánh xạ PTE của một phần của trang lớn trong suốt).

munlock_folio() sử dụng mlock pagevec để sắp xếp các công việc cần thực hiện
dưới lru_lock bởi __munlock_folio().  __munlock_folio() giảm
mlock_count của folio và khi giá trị đó về 0, nó sẽ xóa cờ bị khóa
và xóa cờ không thể xóa, chuyển folio từ trạng thái không thể xóa
đến LRU không hoạt động.

Nhưng trong thực tế điều đó có thể không hoạt động lý tưởng: folio có thể chưa đạt tới
"LRU không thể tránh khỏi" hoặc có thể nó đã tạm thời bị cô lập khỏi nó.  trong
những trường hợp đó trường mlock_count của nó không sử dụng được và phải được coi là 0: vì vậy
rằng folio sẽ được giải cứu vào LRU có thể bị trục xuất, sau đó có thể bị khóa
một lần nữa nếu vmscan tìm thấy nó trong VM_LOCKED VMA.


Cắt bớt các trang MLOCKED
------------------------

Việc cắt bớt hoặc đục lỗ tập tin buộc phải hủy ánh xạ các trang đã xóa khỏi
không gian người dùng; cắt bớt thậm chí hủy bản đồ và xóa bất kỳ trang ẩn danh riêng tư nào
đã được Sao chép-Trên-Ghi từ các trang tệp hiện đang bị cắt bớt.

Các trang bị khóa có thể được khóa và xóa theo cách này: như với munmap(),
đối với mỗi PTE (hoặc PMD) không được ánh xạ khỏi các lệnh gọi VMA, folio_remove_rmap_*()
munlock_vma_folio(), gọi munlock_folio() khi VMA là VM_LOCKED
(trừ khi đó là ánh xạ PTE của một phần của trang lớn trong suốt).

Tuy nhiên, nếu có cuộc đua munlock(), vì mlock_vma_pages_range() bắt đầu
khóa khóa bằng cách xóa VM_LOCKED khỏi VMA, trước khi khóa tất cả các trang
hiện tại, nếu một trong những trang đó không được ánh xạ bằng cách cắt bớt hoặc đục lỗ trước đó
mlock_pte_range() đã đạt đến nó, nó sẽ không được VMA này công nhận là đã khóa,
và sẽ không được tính trong mlock_count.  Trong trường hợp hiếm gặp này, một trang có thể
vẫn xuất hiện dưới dạng PG_mlocked sau khi nó chưa được ánh xạ hoàn toàn: và nó được để lại
Release_pages() (hoặc __page_cache_release()) để xóa nó và cập nhật số liệu thống kê
trước khi giải phóng (sự kiện này được tính trong /proc/vmstat unevictable_pgs_cleared,
thường là 0).


Lấy lại trang trong thu nhỏ_*_list()
-------------------------------

Shrink_active_list() của vmscan sẽ loại bỏ mọi trang rõ ràng là không thể tránh khỏi -
tức là các trang !page_evictable(page) - chuyển những trang đó vào danh sách không thể tránh khỏi.
Tuy nhiên, shr_active_list() chỉ thấy các trang không thể xóa được đã xuất hiện trên
danh sách LRU hoạt động/không hoạt động.  Lưu ý rằng những trang này không có PG_unevictable
set - nếu không chúng sẽ nằm trong danh sách không thể tránh khỏi và shr_active_list()
sẽ không bao giờ nhìn thấy chúng.

Một số ví dụ về các trang không thể xóa được trong danh sách LRU là:

(1) các trang ramf đã được đặt trong danh sách LRU khi được phân bổ lần đầu.

(2) Các trang bộ nhớ được chia sẻ của SHM_LOCK.  shmctl(SHM_LOCK) không cố gắng
     phân bổ hoặc lỗi trong các trang trong vùng bộ nhớ dùng chung.  Điều này xảy ra
     khi một ứng dụng truy cập trang lần đầu tiên sau SHM_LOCK'ing
     phân khúc.

(3) các trang vẫn được ánh xạ vào VM_LOCKED VMA, cần được đánh dấu là đã khóa,
     nhưng các sự kiện khiến mlock_count quá thấp nên chúng bị khóa quá sớm.

thu nhỏ_inactive_list() và thu nhỏ_folio_list() của vmscan cũng chuyển hướng rõ ràng
các trang không thể xóa được tìm thấy trong danh sách không hoạt động vào nhóm bộ nhớ thích hợp
và danh sách nút không thể tránh khỏi.

folio_referenced_one() của rmap, được gọi thông qua shr_active_list() của vmscan hoặc
thu nhỏ_folio_list() và try_to_unmap_one() của rmap được gọi thông qua thu nhỏ_folio_list(),
kiểm tra (3) trang vẫn được ánh xạ vào VM_LOCKED VMA và gọi mlock_vma_folio()
để sửa chúng.  Những trang như vậy sẽ bị loại vào danh sách không thể thu hồi khi được phát hành
bởi máy thu nhỏ.
