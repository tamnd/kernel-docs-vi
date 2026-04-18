.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/transhuge.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Hỗ trợ Hugepage minh bạch
============================

Tài liệu này mô tả các nguyên tắc thiết kế cho Transparent Hugepage (THP)
hỗ trợ và tương tác của nó với các phần khác của quản lý bộ nhớ
hệ thống.

Nguyên tắc thiết kế
=================

- "dự phòng duyên dáng": các thành phần mm không có trang lớn trong suốt
  kiến thức quay trở lại việc chia ánh xạ pmd khổng lồ vào bảng ptes và,
  nếu cần, hãy chia một trang lớn trong suốt. Vì vậy các thành phần này
  có thể tiếp tục làm việc trên các trang thông thường hoặc ánh xạ pte thông thường.

- nếu việc phân bổ trang lớn không thành công do phân mảnh bộ nhớ,
  thay vào đó, các trang thông thường nên được phân bổ một cách duyên dáng và trộn lẫn vào
  cùng một vma mà không có bất kỳ lỗi hoặc độ trễ đáng kể nào và không có
  thông báo về người dùng

- nếu một số tác vụ bị hủy và có thêm nhiều trang lớn hơn (hoặc
  ngay trong bạn bè hoặc thông qua VM), bộ nhớ vật lý của khách
  được hỗ trợ bởi các trang thông thường nên được di chuyển trên các trang lớn
  tự động (với khugepaged)

- nó không yêu cầu đặt trước bộ nhớ và do đó nó sử dụng các trang lớn
  bất cứ khi nào có thể (việc đặt chỗ duy nhất có thể có ở đây là kernelcore=
  để tránh các trang không thể di chuyển được sẽ phân mảnh toàn bộ bộ nhớ nhưng chỉnh sửa như vậy
  không dành riêng cho việc hỗ trợ trang khổng lồ minh bạch và nó là một cách chung
  tính năng áp dụng cho tất cả các phân bổ bậc cao động trong
  hạt nhân)

get_user_pages và pin_user_pages
=================================

get_user_pages và pin_user_pages nếu chạy trên một trang lớn, sẽ trả về
trang đầu hoặc trang đuôi như thường lệ (chính xác như họ vẫn làm trên
Hugetlbfs). Hầu hết người dùng GUP sẽ chỉ quan tâm đến cấu hình vật lý thực tế
địa chỉ của trang và việc ghim tạm thời của nó để phát hành sau I/O
đã hoàn tất nên họ sẽ không bao giờ nhận thấy thực tế là trang này rất lớn. Nhưng
nếu bất kỳ trình điều khiển nào định xử lý cấu trúc trang của phần đuôi
trang (như để kiểm tra trang->ánh xạ hoặc các bit khác có liên quan
đối với trang đầu chứ không phải trang đuôi), cần cập nhật để nhảy
để kiểm tra trang đầu thay thế. Việc tham khảo trên bất kỳ trang đầu/đuôi nào sẽ
ngăn chặn trang bị chia tách bởi bất kỳ ai.

.. note::
   these aren't new constraints to the GUP API, and they match the
   same constraints that apply to hugetlbfs too, so any driver capable
   of handling GUP on hugetlbfs will also work fine on transparent
   hugepage backed mappings.

Dự phòng duyên dáng
=================

Các bảng phân trang đi bộ mã nhưng không biết về các pmds lớn có thể chỉ cần gọi
Split_huge_pmd(vma, pmd, addr) trong đó pmd là cái được trả về bởi
pmd_offset. Việc làm cho mã lớn được nhận biết là điều đơn giản
chỉ bằng cách tìm kiếm "pmd_offset" và thêm Split_huge_pmd vào đâu
thiếu sau pmd_offset trả về pmd. Nhờ sự duyên dáng
thiết kế dự phòng, với một thay đổi một lớp lót, bạn có thể tránh viết
hàng trăm, nếu không phải hàng nghìn dòng mã phức tạp để tạo mã của bạn
trang lớn biết.

Nếu bạn không truy cập bảng phân trang nhưng bạn gặp phải một trang lớn thực tế
mà bạn không thể xử lý nguyên bản trong mã của mình, bạn có thể chia nó thành
gọi chia_huge_page(trang). Đây là những gì máy ảo Linux thực hiện trước đây
nó cố gắng hoán đổi trang lớn chẳng hạn. Split_huge_page() có thể thất bại
nếu trang được ghim và bạn phải xử lý việc này một cách chính xác.

Ví dụ để nhận biết trang khổng lồ trong suốt của mremap.c bằng một lớp lót
thay đổi::

khác biệt --git a/mm/mremap.c b/mm/mremap.c
	--- a/mm/mremap.c
	+++ b/mm/mremap.c
	@@ -41,6 +41,7 @@ tĩnh pmd_t *get_old_pmd(struct mm_stru
			trả lại NULL;

pmd = pmd_offset(pud, addr);
	+ chia_huge_pmd(vma, pmd, addr);
		nếu (pmd_none_or_clear_bad(pmd))
			trả lại NULL;

Khóa mã nhận biết trang lớn
==============================

Chúng tôi muốn nhận biết được nhiều mã nhất có thể, cũng như việc gọi
chia_huge_page() hoặc chia_huge_pmd() có chi phí.

Để làm cho các bước đi có thể phân trang được nhận biết về pmd lớn, tất cả những gì bạn cần làm là gọi
pmd_trans_huge() trên pmd được trả về bởi pmd_offset. Bạn phải nắm giữ
mmap_lock ở chế độ đọc (hoặc ghi) để đảm bảo không thể có một pmd lớn
được tạo từ bên dưới bạn bởi khugepaged (khugepaged thu gọn_huge_page
lấy mmap_lock ở chế độ ghi ngoài khóa anon_vma). Nếu
pmd_trans_huge trả về sai, bạn chỉ cần dự phòng mã cũ
những con đường. Thay vào đó, nếu pmd_trans_huge trả về true, bạn phải thực hiện
khóa bảng trang (pmd_lock()) và chạy lại pmd_trans_huge. Lấy
khóa bảng trang sẽ ngăn chặn việc chuyển đổi pmd lớn thành một
pmd thông thường từ bên dưới bạn (split_huge_pmd có thể chạy song song với
đi bộ có thể phân trang). Nếu pmd_trans_huge thứ hai trả về sai, bạn
chỉ nên bỏ khóa bảng trang và dự phòng mã cũ như
trước đây. Nếu không, bạn có thể tiến hành xử lý pmd khổng lồ và
trang lớn nguyên bản. Sau khi hoàn tất, bạn có thể thả khóa bảng trang.

Hoàn tiền và các trang lớn minh bạch
====================================

Việc tính lại trên THP hầu như phù hợp với việc tính lại trên hợp chất khác
trang:

- get_page()/put_page() và GUP hoạt động trên folio->_refcount.

- ->_refcount ở các trang đuôi luôn bằng 0: get_page_unless_zero() không bao giờ
    thành công trên các trang đuôi.

- ánh xạ/hủy ánh xạ mục nhập PMD cho toàn bộ mức tăng/giảm THP
    folio->_toàn bộ_mapcount và folio->_large_mapcount.

Chúng tôi cũng duy trì hai vị trí để theo dõi chủ sở hữu MM (MM ID và
    số bản đồ tương ứng) và trạng thái hiện tại ("có thể được chia sẻ được ánh xạ" so với được chia sẻ).
    "được ánh xạ độc quyền").

Với CONFIG_PAGE_MAPCOUNT, chúng tôi cũng tăng/giảm
    folio->_nr_pages_mapped bởi ENTIRELY_MAPPED khi _toàn bộ_mapcount biến mất
    từ -1 đến 0 hoặc 0 đến -1.

- ánh xạ/hủy ánh xạ các trang riêng lẻ với mức tăng/giảm mục nhập PTE
    folio->_large_mapcount.

Chúng tôi cũng duy trì hai vị trí để theo dõi chủ sở hữu MM (MM ID và
    số bản đồ tương ứng) và trạng thái hiện tại ("có thể được chia sẻ được ánh xạ" so với được chia sẻ).
    "được ánh xạ độc quyền").

Với CONFIG_PAGE_MAPCOUNT, chúng tôi cũng tăng/giảm
    page->_mapcount và folio tăng/giảm->_nr_pages_mapped khi
    page->_mapcount đi từ -1 đến 0 hoặc 0 đến -1 vì điều này đếm số
    số trang được ánh xạ bởi PTE.

Split_huge_page nội bộ phải phân phối số tiền hoàn lại trong phần đầu
trang tới các trang đuôi trước khi xóa tất cả các bit PG_head/tail khỏi trang
các cấu trúc. Nó có thể được thực hiện dễ dàng cho việc hoàn tiền được thực hiện theo bảng trang
mục nhập, nhưng chúng tôi không có đủ thông tin về cách phân phối bất kỳ
các chân bổ sung (tức là từ get_user_pages). Split_huge_page() không thành công
yêu cầu chia nhỏ các trang lớn được ghim: nó dự kiến số lượng trang sẽ bằng
tổng số bản đồ của tất cả các trang con cộng với một (người gọi Split_huge_page phải
có tham chiếu đến trang đầu).

Split_huge_page sử dụng các mục nhập di chuyển để ổn định trang->_refcount và
trang->_mapcount của các trang ẩn danh. Các trang tệp không được ánh xạ.

Chúng tôi cũng an toàn trước các máy quét bộ nhớ vật lý: cách hợp pháp duy nhất
máy quét có thể lấy tham chiếu đến một trang là get_page_unless_zero().

Tất cả các trang đuôi đều có số 0 ->_refcount cho đến khi Atomic_add(). Điều này ngăn cản sự
scanner không nhận được tham chiếu đến trang đuôi cho đến thời điểm đó. Sau khi
Atomic_add() chúng tôi không quan tâm đến giá trị ->_refcount. Chúng tôi đã biết cách
nhiều tài liệu tham khảo nên được loại bỏ khỏi trang đầu.

Đối với trang đầu get_page_unless_zero() sẽ thành công và chúng tôi không bận tâm. Đó là
làm rõ vị trí các tài liệu tham khảo sau khi tách: nó sẽ ở lại trang đầu.

Lưu ý rằng Split_huge_pmd() không có bất kỳ hạn chế nào đối với việc đếm lại:
pmd có thể được chia nhỏ bất cứ lúc nào và không bao giờ bị lỗi.

Unmap một phần và deferred_split_folio() (chỉ dành cho THP)
========================================================

Việc hủy ánh xạ một phần của THP (bằng munmap() hoặc cách khác) sẽ không miễn phí
bộ nhớ ngay lập tức. Thay vào đó, chúng tôi phát hiện thấy một trang con của THP không được sử dụng
trong folio_remove_rmap_*() và xếp hàng THP để phân tách nếu áp lực bộ nhớ
đến. Việc chia nhỏ sẽ giải phóng các trang con không sử dụng.

Việc chia trang ngay lập tức không phải là một lựa chọn do ngữ cảnh bị khóa trong
nơi mà chúng tôi có thể phát hiện một phần bản đồ. Nó cũng có thể là
phản tác dụng vì trong nhiều trường hợp việc hủy bản đồ một phần xảy ra trong khi thoát (2) nếu
THP vượt qua ranh giới VMA.

Hàm deferred_split_folio() được sử dụng để sắp xếp một folio để phân chia.
Việc phân tách sẽ tự xảy ra khi chúng ta gặp áp lực bộ nhớ thông qua bộ thu nhỏ
giao diện.

Với CONFIG_PAGE_MAPCOUNT, chúng tôi phát hiện ánh xạ một phần một cách đáng tin cậy dựa trên
folio->_nr_pages_mapped.

Với CONFIG_NO_PAGE_MAPCOUNT, chúng tôi phát hiện ánh xạ một phần dựa trên
số bản đồ trung bình trên mỗi trang trong THP: nếu mức trung bình < 1 thì THP anon là
chắc chắn được lập bản đồ một phần. Miễn là chỉ có một quy trình duy nhất ánh xạ THP,
phát hiện này là đáng tin cậy. Với các tiến trình con chạy dài, có thể
là các tình huống mà hiện tại không thể phát hiện được ánh xạ một phần và
có thể cần phát hiện không đồng bộ trong quá trình lấy lại bộ nhớ trong tương lai.
