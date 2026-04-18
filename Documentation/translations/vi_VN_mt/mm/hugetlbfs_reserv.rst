.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/hugetlbfs_reserv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Đặt chỗ Hugetlbfs
=======================

Tổng quan
=========

Các trang lớn như được mô tả tại Documentation/admin-guide/mm/hugetlbpage.rst là
thường được phân bổ trước để sử dụng ứng dụng.  Những trang lớn này được khởi tạo
trong không gian địa chỉ của tác vụ tại thời điểm lỗi trang nếu VMA biểu thị các trang lớn
sẽ được sử dụng.  Nếu không có trang lớn tồn tại tại thời điểm trang bị lỗi, tác vụ sẽ được gửi
một chiếc SIGBUS và thường chết một cách bất hạnh.  Ngay sau khi hỗ trợ trang lớn
đã được thêm vào, người ta xác định rằng sẽ tốt hơn nếu phát hiện sự thiếu hụt
của các trang lớn tại thời điểm mmap().  Ý tưởng là nếu không có đủ
các trang lớn để che phủ bản đồ, mmap() sẽ thất bại.  Đây là lần đầu tiên
được thực hiện bằng cách kiểm tra mã đơn giản tại thời điểm mmap() để xác định xem có
có đủ các trang lớn miễn phí để bao phủ bản đồ.  Giống như hầu hết mọi thứ trong
kernel, mã đã phát triển theo thời gian.  Tuy nhiên, ý tưởng cơ bản là
'dự trữ' các trang lớn vào thời điểm mmap() để đảm bảo rằng các trang lớn sẽ được
có sẵn cho các lỗi trang trong ánh xạ đó.  Mô tả dưới đây cố gắng
mô tả cách xử lý dự trữ trang lớn được thực hiện trong kernel v4.10.


Khán giả
========
Mô tả này chủ yếu nhắm vào các nhà phát triển kernel đang sửa đổi
mã Hugetlbfs.


Cấu trúc dữ liệu
===================

resv_huge_pages
	Đây là số lượng trang lớn được dành riêng trên toàn cầu (mỗi hstate).  Đã đặt trước
	các trang lớn chỉ có sẵn cho nhiệm vụ dành riêng cho chúng.
	Do đó, số lượng trang lớn thường có sẵn được tính toán
	như (ZZ0000ZZ).
Bản đồ dự trữ
	Bản đồ dự trữ được mô tả theo cấu trúc::

cấu trúc resv_map {
			struct kref ref;
			khóa spinlock_t;
			cấu trúc vùng list_head;
			thêm_in_progress dài;
			cấu trúc list_head vùng_cache;
			vùng_cache_count dài;
		};

Có một bản đồ dự trữ cho mỗi bản đồ trang lớn trong hệ thống.
	Danh sách vùng trong resv_map mô tả các vùng trong
	bản đồ.  Một khu vực được mô tả là::

cấu trúc tập tin_khu vực {
			liên kết struct list_head;
			từ lâu ;
			lâu tới ;
		};

Các trường 'từ' và 'đến' của cấu trúc vùng tệp là một trang lớn
	các chỉ số vào bản đồ.  Tùy thuộc vào loại bản đồ, một
	khu vực trong reserv_map có thể cho biết có sự đặt chỗ trước cho
	phạm vi, hoặc đặt chỗ không tồn tại.
Cờ cho đặt chỗ MAP_PRIVATE
	Chúng được lưu trữ ở các bit dưới cùng của con trỏ bản đồ đặt trước.

ZZ0000ZZ
		Cho biết nhiệm vụ này là chủ sở hữu của các đặt phòng
		liên quan đến việc lập bản đồ.
	ZZ0001ZZ
		Cho biết tác vụ ban đầu ánh xạ phạm vi này (và tạo
		dự trữ) đã ánh xạ một trang khỏi nhiệm vụ này (đứa trẻ)
		do COW bị lỗi.
Cờ trang
	Cờ trang PagePrivate được sử dụng để chỉ ra rằng một trang lớn
	đặt chỗ phải được khôi phục khi trang lớn được giải phóng.  Thêm
	chi tiết sẽ được thảo luận trong phần "Giải phóng các trang lớn".


Bản đồ đặt chỗ Vị trí (Riêng tư hoặc Chia sẻ)
=============================================

Một phân đoạn hoặc ánh xạ trang lớn là riêng tư hoặc được chia sẻ.  Nếu riêng tư,
nó thường chỉ có sẵn cho một không gian địa chỉ (tác vụ) duy nhất.  Nếu được chia sẻ,
nó có thể được ánh xạ vào nhiều không gian địa chỉ (tác vụ).  Vị trí và
ngữ nghĩa của bản đồ đặt chỗ khác nhau đáng kể đối với hai loại
của các bản đồ.  Sự khác biệt về vị trí là:

- Đối với các ánh xạ riêng tư, bản đồ đặt trước nằm ngoài cấu trúc VMA.
  Cụ thể là vma->vm_private_data.  Bản đồ dự trữ này được tạo ra tại
  thời điểm ánh xạ (mmap(MAP_PRIVATE)) được tạo.
- Đối với ánh xạ được chia sẻ, bản đồ dành riêng sẽ treo ở nút inode.  Cụ thể,
  inode->i_mapping->private_data.  Vì ánh xạ chia sẻ luôn được hỗ trợ
  bởi các tập tin trong hệ thống tập tin Hugetlbfs, mã Hugetlbfs đảm bảo mỗi inode
  chứa một bản đồ đặt phòng.  Kết quả là bản đồ đặt chỗ được phân bổ
  khi inode được tạo.


Tạo đặt chỗ
=====================
Việc đặt trước được tạo khi một phân đoạn bộ nhớ chia sẻ được hỗ trợ trang lớn được
đã tạo (shmget(SHM_HUGETLB)) hoặc ánh xạ được tạo thông qua mmap(MAP_HUGETLB).
Các thao tác này dẫn đến lệnh gọi tới quy trình Hugetlb_reserve_pages()::

int Hugetlb_reserve_pages(struct inode *inode,
				  từ lâu đến, dài đến,
				  cấu trúc vm_area_struct *vma,
				  vm_flags_t vm_flags)

Điều đầu tiên Hugetlb_reserve_pages() làm là kiểm tra xem NORESERVE có
cờ đã được chỉ định trong lệnh gọi shmget() hoặc mmap().  Nếu NORESERVE
đã được chỉ định thì thủ tục này sẽ trả về ngay lập tức khi không có sự đặt trước nào
được mong muốn.

Các đối số 'từ' và 'đến' là các chỉ mục trang lớn trong ánh xạ hoặc
tập tin cơ bản.  Đối với shmget(), 'from' luôn là 0 và 'to' tương ứng với
độ dài của phân đoạn/ánh xạ.  Đối với mmap(), đối số offset có thể
được sử dụng để chỉ định phần bù vào tệp cơ bản.  Trong trường hợp như vậy,
các đối số 'từ' và 'đến' đã được điều chỉnh bởi phần bù này.

Một trong những khác biệt lớn giữa ánh xạ PRIVATE và SHARED là cách
trong đó các đặt chỗ được thể hiện trên bản đồ đặt chỗ.

- Đối với ánh xạ được chia sẻ, một mục trong bản đồ đặt chỗ cho biết việc đặt chỗ
  tồn tại hoặc đã tồn tại cho trang tương ứng.  Vì đã đặt chỗ trước
  đã sử dụng, bản đồ đặt chỗ không được sửa đổi.
- Đối với các bản đồ riêng tư, việc thiếu mục trong bản đồ đặt chỗ cho thấy
  đã có đặt chỗ cho trang tương ứng.  Vì đã đặt chỗ trước
  tiêu thụ, các mục sẽ được thêm vào bản đồ đặt chỗ.  Vì vậy,
  bản đồ đặt chỗ cũng có thể được sử dụng để xác định chỗ đặt chỗ nào có
  đã được tiêu thụ.

Đối với ánh xạ riêng tư, Hugetlb_reserve_pages() tạo bản đồ đặt chỗ và
treo nó khỏi cấu trúc VMA.  Ngoài ra, cờ HPAGE_RESV_OWNER được đặt
để cho biết VMA này sở hữu các đặt chỗ.

Bản đồ đặt chỗ được tham khảo để xác định có bao nhiêu trang đặt chỗ lớn
là cần thiết cho ánh xạ/phân đoạn hiện tại.  Đối với ánh xạ riêng tư, đây là
luôn là giá trị (đến - từ).  Tuy nhiên, đối với ánh xạ chia sẻ, có thể
một số đặt chỗ có thể đã tồn tại trong phạm vi (đến - từ).  Xem
phần ZZ0000ZZ
để biết chi tiết về cách thực hiện việc này.

Ánh xạ có thể được liên kết với một nhóm con.  Nếu vậy, subpool được tham khảo
để đảm bảo có đủ không gian cho việc lập bản đồ.  Có thể là
subpool đã dành riêng các chỗ đặt trước có thể được sử dụng để lập bản đồ.  Xem
phần ZZ0000ZZ để biết thêm chi tiết.

Sau khi tham khảo bản đồ đặt chỗ và nhóm phụ, số lượng chỗ mới cần thiết
đặt chỗ đã được biết.  Thủ tục Hugetlb_acct_memory() được gọi để kiểm tra
cho và nhận số lượng đặt phòng được yêu cầu.  Hugetlb_acct_memory()
gọi vào các quy trình có khả năng phân bổ và điều chỉnh số lượng trang dư thừa.
Tuy nhiên, trong những quy trình đó, mã chỉ đơn giản là kiểm tra để đảm bảo có
có đủ các trang lớn miễn phí để đáp ứng việc đặt trước.  Nếu có,
số lượng đặt chỗ toàn cầu resv_huge_pages được điều chỉnh giống như
sau đây::

if (resv_ Need <= (free_huge_pages - resv_huge_pages)
		resv_huge_pages += resv_ Need;

Lưu ý rằng khóa chung Hugetlb_lock được giữ khi kiểm tra và điều chỉnh
những quầy này.

Nếu có đủ số trang lớn miễn phí và số lượng toàn cầu resv_huge_pages
được điều chỉnh thì bản đồ đặt chỗ liên kết với bản đồ là
được sửa đổi để phản ánh sự bảo lưu.  Trong trường hợp ánh xạ được chia sẻ, một
file_zone sẽ tồn tại bao gồm phạm vi 'từ' - 'đến'.  Dành cho riêng tư
bản đồ, không có sửa đổi nào được thực hiện đối với bản đồ đặt chỗ vì thiếu
mục nhập cho biết có đặt chỗ trước.

Nếu Hugetlb_reserve_pages() thành công, số lượng đặt chỗ toàn cầu và
bản đồ đặt chỗ liên quan đến bản đồ sẽ được sửa đổi theo yêu cầu để
đảm bảo tồn tại các đặt chỗ trong phạm vi 'từ' - 'đến'.

.. _consume_resv:

Sử dụng đặt trước/Phân bổ một trang lớn
=============================================

Đặt chỗ được sử dụng khi các trang lớn liên quan đến đặt chỗ
được phân bổ và khởi tạo trong ánh xạ tương ứng.  Việc phân bổ
được thực hiện trong quy trình alloc_hugetlb_folio()::

cấu trúc folio *alloc_hugetlb_folio(struct vm_area_struct *vma,
				     địa chỉ dài không dấu, int tránh_reserve)

alloc_hugetlb_folio được chuyển qua một con trỏ VMA và một địa chỉ ảo, vì vậy nó có thể
tham khảo bản đồ đặt chỗ để xác định xem có đặt chỗ hay không.  Ngoài ra,
alloc_hugetlb_folio lấy đối số tránh_reserve biểu thị lượng dự trữ
không nên được sử dụng ngay cả khi có vẻ như chúng đã được dành riêng cho
địa chỉ được chỉ định.  Đối số tránh_reserve được sử dụng thường xuyên nhất trong trường hợp
của Bản sao khi Di chuyển Viết và Trang trong đó các bản sao bổ sung của một bản sao hiện có
trang đang được phân bổ.

Thủ tục trợ giúp vma_needs_reservation() được gọi để xác định xem một
tồn tại sự đặt chỗ cho địa chỉ trong ánh xạ (vma).  Xem phần
ZZ0000ZZ để biết chi tiết
thông tin về những gì thói quen này làm.
Giá trị được trả về từ vma_needs_reservation() thường là
0 hoặc 1. 0 nếu có đặt chỗ trước cho địa chỉ, 1 nếu không có đặt chỗ nào tồn tại.
Nếu việc đặt trước không tồn tại và có một nhóm con được liên kết với
ánh xạ nhóm con được tham khảo để xác định xem nó có chứa các đặt chỗ hay không.
Nếu nhóm con chứa các đặt chỗ, một nhóm có thể được sử dụng cho việc phân bổ này.
Tuy nhiên, trong mọi trường hợp, đối sốvoid_reserve sẽ ghi đè việc sử dụng
một sự bảo lưu cho việc phân bổ.  Sau khi xác định liệu việc đặt chỗ có
tồn tại và có thể được sử dụng để phân bổ, quy trình dequeue_huge_page_vma()
được gọi.  Thủ tục này có hai đối số liên quan đến việc đặt chỗ:

- tránh_reserve, đây là cùng một giá trị/đối số được truyền cho
  alloc_hugetlb_folio().
- chg, mặc dù đối số này thuộc loại dài nhưng chỉ có giá trị 0 hoặc 1
  được chuyển đến dequeue_huge_page_vma.  Nếu giá trị là 0, nó biểu thị một
  tồn tại việc đặt chỗ trước (xem phần "Chính sách bộ nhớ và việc đặt chỗ trước" để biết
  các vấn đề có thể xảy ra).  Nếu giá trị là 1, nó cho biết việc đặt trước không
  tồn tại và trang phải được lấy từ nhóm miễn phí toàn cầu nếu có thể.

Danh sách trống liên quan đến chính sách bộ nhớ của VMA được tìm kiếm
một trang miễn phí.  Nếu tìm thấy một trang, giá trị free_huge_pages sẽ giảm đi
khi trang bị xóa khỏi danh sách miễn phí.  Nếu có đặt chỗ
được liên kết với trang, những điều chỉnh sau sẽ được thực hiện::

SetPagePrivate(trang);	/* Cho biết việc phân bổ trang này đã được sử dụng
				 * đặt chỗ và nếu có lỗi
				 * gặp phải trường hợp này nên trang này phải
				 * được giải phóng, việc đặt chỗ sẽ được khôi phục. */
	resv_huge_pages--;	/* Giảm số lượng đặt trước toàn cầu */

Lưu ý, nếu không tìm thấy trang lớn nào đáp ứng chính sách bộ nhớ của VMA
một nỗ lực sẽ được thực hiện để phân bổ một người bằng cách sử dụng công cụ cấp phát bạn bè.  Cái này
đưa ra vấn đề về các trang khổng lồ dư thừa và cam kết quá mức vượt quá
phạm vi bảo lưu.  Ngay cả khi một trang dư thừa được phân bổ, điều tương tự
các điều chỉnh dựa trên đặt chỗ như trên sẽ được thực hiện: SetPagePrivate(page) và
resv_huge_pages--.

Sau khi có được folio Hugetlb mới, (folio)->_hugetlb_subpool được đặt thành
giá trị của nhóm con được liên kết với trang nếu nó tồn tại.  Điều này sẽ được sử dụng
để tính toán nhóm con khi folio được giải phóng.

Sau đó, thủ tục vma_commit_reservation() được gọi để điều chỉnh mức dự trữ
bản đồ dựa trên mức tiêu thụ của đặt phòng.  Nói chung, điều này bao gồm
đảm bảo trang được thể hiện trong cấu trúc file_khu vực của khu vực
bản đồ.  Đối với các ánh xạ được chia sẻ có đặt trước, một mục nhập
trong bản đồ dự trữ đã tồn tại nên không có thay đổi nào được thực hiện.  Tuy nhiên, nếu có
không có sự đặt trước nào trong bản đồ được chia sẻ hoặc đây là bản đồ riêng tư của một bản đồ mới
mục nhập phải được tạo ra.

Có thể bản đồ dự trữ đã được thay đổi giữa cuộc gọi
tới vma_needs_reservation() ở đầu alloc_hugetlb_folio() và
gọi tới vma_commit_reservation() sau khi folio được phân bổ.  Điều này sẽ
có thể thực hiện được nếu Hugetlb_reserve_pages được gọi cho cùng một trang trong một trang được chia sẻ
lập bản đồ.  Trong những trường hợp như vậy, số lượng đặt trước và số lượng trang miễn phí của nhóm con
sẽ tắt một lần.  Tình trạng hiếm gặp này có thể được xác định bằng cách so sánh
giá trị trả về từ vma_needs_reservation và vma_commit_reservation.  Nếu như vậy
một cuộc đua được phát hiện, số lượng dự trữ con và toàn cầu được điều chỉnh thành
bù đắp.  Xem phần
ZZ0000ZZ để biết thêm
thông tin về các thói quen này.


Khởi tạo các trang lớn
======================

Sau khi phân bổ trang lớn, trang này thường được thêm vào bảng trang
của nhiệm vụ phân bổ.  Trước đó, các trang trong bản đồ chia sẻ sẽ được thêm vào
vào bộ đệm trang và các trang trong ánh xạ riêng tư được thêm vào ẩn danh
lập bản đồ ngược.  Trong cả hai trường hợp, cờ PagePrivate đều bị xóa.  Vì vậy,
khi một trang lớn đã được khởi tạo được giải phóng thì không có sự điều chỉnh nào được thực hiện
đến số lượng đặt chỗ toàn cầu (resv_huge_pages).


Giải phóng các trang lớn
========================

Các trang lớn được giải phóng bởi free_huge_folio().  Nó chỉ được truyền qua một con trỏ
vào folio vì nó được gọi từ mã MM chung.  Khi một trang lớn
được giải phóng, việc hạch toán đặt trước có thể cần phải được thực hiện.  Điều này sẽ
trong trường hợp trang được liên kết với một nhóm con chứa
dự trữ hoặc trang đang được giải phóng trên một đường dẫn lỗi trong đó toàn cầu
số lượng dự trữ phải được khôi phục.

Trường trang->riêng tư trỏ đến bất kỳ nhóm con nào được liên kết với trang.
Nếu cờ PagePrivate được đặt, nó cho biết số lượng dự trữ toàn cầu sẽ
được điều chỉnh (xem phần
ZZ0000ZZ
để biết thông tin về cách thiết lập chúng).

Quy trình đầu tiên gọi Hugepage_subpool_put_pages() cho trang.  Nếu điều này
thường trình trả về giá trị 0 (không bằng giá trị được truyền 1)
cho biết dự trữ được liên kết với nhóm con và trang mới miễn phí này
phải được sử dụng để giữ số lượng dự trữ nhóm con trên kích thước tối thiểu.
Do đó, bộ đếm resv_huge_pages toàn cầu được tăng lên trong trường hợp này.

Nếu cờ PagePrivate được đặt trong trang, bộ đếm resv_huge_pages toàn cầu
sẽ luôn được tăng lên.

.. _sub_pool_resv:

Đặt chỗ nhóm phụ
====================

Có một trạng thái cấu trúc được liên kết với mỗi kích thước trang lớn.  trạng thái
theo dõi tất cả các trang lớn có kích thước được chỉ định.  Một nhóm con đại diện cho một tập hợp con
của các trang trong một hstate được liên kết với một Hugetlbfs được gắn kết
hệ thống tập tin.

Khi hệ thống tập tin Hugetlbfs được gắn kết, có thể chỉ định tùy chọn min_size
cho biết số lượng trang lớn tối thiểu mà hệ thống tập tin yêu cầu.
Nếu tùy chọn này được chỉ định, số lượng trang lớn tương ứng với
min_size được dành riêng cho hệ thống tập tin sử dụng.  Con số này được theo dõi trong
trường min_hpages của cấu trúc Hugepage_subpool.  Vào thời điểm gắn kết,
Hugetlb_acct_memory(min_hpages) được gọi để dự trữ số lượng đã chỉ định
những trang khổng lồ.  Nếu chúng không thể được đặt trước, quá trình gắn kết sẽ thất bại.

Các thủ tục Hugepage_subpool_get/put_pages() được gọi khi các trang được
thu được từ hoặc được giải phóng trở lại một nhóm con.  Họ thực hiện tất cả các nhóm con
kế toán và theo dõi mọi đặt chỗ liên quan đến nhóm phụ.
Hugepage_subpool_get/put_pages được thông qua số lượng trang lớn mà qua đó
để điều chỉnh số lượng 'trang đã sử dụng' của nhóm con (xuống để lấy, lên để đặt).  Thông thường,
chúng trả về cùng một giá trị đã được chuyển hoặc có lỗi nếu không đủ trang
tồn tại trong subpool.

Tuy nhiên, nếu dự trữ được liên kết với phân nhóm thì giá trị trả về sẽ nhỏ hơn
hơn giá trị được thông qua có thể được trả lại.  Giá trị trả về này cho biết
số lượng điều chỉnh nhóm toàn cầu bổ sung phải được thực hiện.  Ví dụ,
giả sử một nhóm con chứa 3 trang lớn dành riêng và ai đó yêu cầu 5 trang.
3 trang dành riêng được liên kết với nhóm con có thể được sử dụng để đáp ứng một phần
của yêu cầu.  Tuy nhiên, phải lấy được 2 trang từ nhóm toàn cầu.  Đến
chuyển tiếp thông tin này đến người gọi, giá trị 2 sẽ được trả về.  người gọi
sau đó chịu trách nhiệm cố gắng lấy thêm hai trang từ
các nhóm toàn cầu.


COW và đặt chỗ
====================

Vì các ánh xạ được chia sẻ đều trỏ tới và sử dụng cùng các trang cơ bản, nên
mối quan tâm đặt trước lớn nhất đối với COW là ánh xạ riêng tư.  Trong trường hợp này,
hai tác vụ có thể trỏ đến cùng một trang được phân bổ trước đó.  Một nhiệm vụ
cố gắng ghi vào trang, do đó một trang mới phải được cấp phát sao cho mỗi trang
nhiệm vụ trỏ đến trang riêng của nó.

Khi trang ban đầu được phân bổ, việc đặt chỗ cho trang đó là
tiêu thụ.  Khi nỗ lực phân bổ một trang mới được thực hiện do
COW, có thể không có trang lớn miễn phí nào là miễn phí và việc phân bổ
sẽ thất bại.

Khi ánh xạ riêng tư ban đầu được tạo, chủ sở hữu của ánh xạ
được ghi chú bằng cách đặt bit HPAGE_RESV_OWNER trong con trỏ tới phần đặt trước
bản đồ của chủ sở hữu.  Vì chủ sở hữu đã tạo bản đồ nên chủ sở hữu sở hữu tất cả
các đặt phòng liên quan đến việc lập bản đồ.  Vì vậy, khi có lỗi ghi
xảy ra và không có sẵn trang nào, chủ sở hữu sẽ có hành động khác
và không phải là chủ sở hữu đặt phòng.

Trong trường hợp tác vụ sửa lỗi không phải là chủ sở hữu thì lỗi sẽ bị lỗi và
nhiệm vụ thường sẽ nhận được SIGBUS.

Nếu chủ sở hữu là nhiệm vụ bị lỗi, chúng tôi muốn nó thành công vì nó sở hữu
đặt phòng ban đầu.  Để thực hiện điều này, trang này sẽ được tách khỏi bản đồ
nhiệm vụ không sở hữu.  Theo cách này, tham chiếu duy nhất là từ tác vụ sở hữu.
Ngoài ra, bit HPAGE_RESV_UNMAPPED được đặt trong con trỏ bản đồ đặt trước
của nhiệm vụ không sở hữu.  Nhiệm vụ không sở hữu có thể nhận được SIGBUS nếu sau đó
lỗi trên một trang không có mặt.  Tuy nhiên, chủ sở hữu ban đầu của
ánh xạ/đặt chỗ sẽ hoạt động như mong đợi.


.. _resv_map_modifications:

Sửa đổi bản đồ đặt chỗ
=============================

Các thủ tục cấp thấp sau đây được sử dụng để thực hiện sửa đổi một
bản đồ đặt chỗ.  Thông thường, những thói quen này không được gọi trực tiếp.  Đúng hơn,
một quy trình trợ giúp bản đồ đặt chỗ được gọi để gọi một trong những cấp độ thấp này
thói quen.  Những thói quen cấp thấp này được ghi lại khá đầy đủ trong nguồn
mã (mm/hugetlb.c).  Những thói quen này là::

vùng dài_chg(struct resv_map *resv, long f, long t);
	vùng dài_add (struct resv_map *resv, dài f, dài t);
	void vùng_abort(struct resv_map *resv, long f, long t);
	vùng_count dài (struct resv_map *resv, dài f, dài t);

Các thao tác trên bản đồ đặt chỗ thường bao gồm hai thao tác:

1) vùng_chg() được gọi để kiểm tra bản đồ dự trữ và xác định cách thức
   nhiều trang trong phạm vi được chỉ định [f, t) hiện được đại diện bởi NOT.

Mã gọi thực hiện kiểm tra và phân bổ toàn cục để xác định xem
   có đủ các trang lớn để hoạt động thành công.

2)
  a) Nếu thao tác có thể thành công, vùng_add() được gọi để thực sự sửa đổi
     bản đồ đặt chỗ cho cùng phạm vi [f, t) trước đó được chuyển tới
     vùng_chg().
  b) Nếu thao tác không thành công, vùng_abort được gọi tương tự
     phạm vi [f, t) để hủy bỏ thao tác.

Lưu ý rằng đây là quy trình gồm hai bước trong đó Region_add() và Region_abort()
được đảm bảo thành công sau lệnh gọi trước tới vùng_chg() cho cùng một
phạm vi.  Region_chg() chịu trách nhiệm phân bổ trước mọi cấu trúc dữ liệu
cần thiết để đảm bảo các hoạt động tiếp theo (cụ thể là vùng_add()))
sẽ thành công.

Như đã đề cập ở trên, Region_chg() xác định số lượng trang trong phạm vi
NOT hiện được đại diện trên bản đồ.  Con số này được trả về
người gọi.  Region_add() trả về số trang trong phạm vi được thêm vào
bản đồ.  Trong hầu hết các trường hợp, giá trị trả về của Region_add() giống với giá trị
giá trị trả về của vùng_chg().  Tuy nhiên, trong trường hợp ánh xạ chia sẻ thì
có thể thực hiện các thay đổi đối với bản đồ đặt chỗ giữa các cuộc gọi tới
vùng_chg() và vùng_add().  Trong trường hợp này, giá trị trả về của vùng_add()
sẽ không khớp với giá trị trả về của vùng_chg().  Rất có thể trong hoàn cảnh như vậy
trường hợp số lượng toàn cầu và kế toán nhóm con sẽ không chính xác và cần
điều chỉnh.  Trách nhiệm của người gọi là kiểm tra tình trạng này
và có những điều chỉnh phù hợp.

Thủ tục Region_del() được gọi để xóa các vùng khỏi bản đồ đặt chỗ.
Nó thường được gọi trong các tình huống sau:

- Khi một tập tin trong hệ thống tập tin Hugetlbfs bị xóa, inode sẽ
  được phát hành và bản đồ đặt chỗ được giải phóng.  Trước khi giải phóng đặt chỗ
  bản đồ, tất cả các cấu trúc file_khu vực riêng lẻ phải được giải phóng.  Trong trường hợp này
  vùng_del được vượt qua phạm vi [0, LONG_MAX).
- Khi một tập tin Hugetlbfs đang bị cắt bớt.  Trong trường hợp này, tất cả các trang được phân bổ
  sau khi kích thước tập tin mới phải được giải phóng.  Ngoài ra, mọi mục nhập file_khu vực
  trong bản đồ đặt chỗ qua phần cuối mới của tập tin phải được xóa.  Trong này
  trường hợp, vùng_del được chuyển qua phạm vi [new_end_of_file, LONG_MAX).
- Khi một lỗ được đục lỗ trong tập tin Hugetlbfs.  Trong trường hợp này, các trang lớn
  lần lượt bị xóa khỏi giữa tập tin.  Như các trang
  bị xóa, vùng_del() được gọi để xóa mục nhập tương ứng khỏi
  bản đồ đặt chỗ.  Trong trường hợp này, vùng_del được vượt qua phạm vi
  [trang_idx, trang_idx + 1).

Trong mọi trường hợp, Region_del() sẽ trả về số trang bị xóa khỏi
bản đồ đặt chỗ.  Trong các trường hợp hiếm gặp của VERY, vùng_del() có thể thất bại.  Điều này chỉ có thể
xảy ra trong trường hợp đục lỗ khi nó phải chia một file_zone hiện có
mục nhập và không thể phân bổ một cấu trúc mới.  Trong trường hợp lỗi này, Region_del()
sẽ trả về -ENOMEM.  Vấn đề ở đây là bản đồ đặt chỗ sẽ
cho biết rằng có một sự đặt chỗ cho trang này.  Tuy nhiên, nhóm con và
số lượng đặt chỗ toàn cầu sẽ không phản ánh việc đặt chỗ.  Để xử lý việc này
Trong trường hợp này, quy trình Hugetlb_fix_reserve_counts() được gọi để điều chỉnh
các bộ đếm sao cho chúng tương ứng với mục nhập bản đồ đặt chỗ có thể
không được xóa.

Region_count() được gọi khi hủy ánh xạ một trang lớn riêng tư.  trong
ánh xạ riêng tư, việc thiếu mục trong bản đồ đặt chỗ cho thấy rằng
một đặt phòng tồn tại.  Vì vậy, bằng cách đếm số lượng mục trong
bản đồ đặt chỗ, chúng tôi biết có bao nhiêu lượt đặt chỗ đã được sử dụng và bao nhiêu lượt đặt chỗ
nổi bật (nổi bật = (kết thúc - bắt đầu) - vùng_count(resv, bắt đầu, kết thúc)).
Vì tính năng ánh xạ không còn nữa nên số lượng đặt chỗ chung và nhóm con sẽ được tính
được giảm dần theo số lượng đặt phòng chưa thanh toán.

.. _resv_map_helpers:

Quy trình của người trợ giúp bản đồ đặt chỗ
===========================================

Một số quy trình trợ giúp tồn tại để truy vấn và sửa đổi bản đồ đặt chỗ.
Những thói quen này chỉ quan tâm đến việc đặt chỗ cho một số lượng lớn cụ thể
trang, vì vậy họ chỉ chuyển vào một địa chỉ thay vì một dải ô.  Ngoài ra,
họ chuyển vào VMA được liên kết.  Từ VMA, loại ánh xạ (riêng tư
hoặc chia sẻ) và vị trí của bản đồ đặt chỗ (inode hoặc VMA) có thể được
xác định.  Những thói quen này chỉ đơn giản gọi các thói quen cơ bản được mô tả
trong phần "Sửa đổi bản đồ đặt chỗ".  Tuy nhiên, họ có tính đến
tính đến ý nghĩa 'ngược lại' của các mục bản đồ đặt chỗ cho cá nhân và
ánh xạ được chia sẻ và ẩn chi tiết này với người gọi::

vma_needs_reservation dài (struct hstate *h,
				   cấu trúc vm_area_struct *vma,
				   địa chỉ dài không dấu)

Quy trình này gọi vùng_chg() cho trang được chỉ định.  Nếu không đặt trước
tồn tại, 1 được trả về.  Nếu đặt chỗ tồn tại, 0 được trả về::

vma_commit_reservation dài (struct hstate *h,
				    cấu trúc vm_area_struct *vma,
				    địa chỉ dài không dấu)

Điều này gọi vùng_add() cho trang được chỉ định.  Như trong trường hợp của vùng_chg
và vùng_add, quy trình này sẽ được gọi sau lệnh gọi trước đó tới
vma_needs_reservation.  Nó sẽ thêm một mục đặt chỗ cho trang.  Nó
trả về 1 nếu đặt chỗ đã được thêm và 0 nếu không.  Giá trị trả về sẽ
được so sánh với giá trị trả về của lệnh gọi trước đó tới
vma_needs_reservation.  Một sự khác biệt không mong đợi cho thấy việc đặt chỗ
bản đồ đã được sửa đổi giữa các cuộc gọi::

void vma_end_reservation(struct hstate *h,
				 cấu trúc vm_area_struct *vma,
				 địa chỉ dài không dấu)

Điều này gọi vùng_abort() cho trang được chỉ định.  Như trong trường hợp của vùng_chg
và vùng_abort, thủ tục này sẽ được gọi sau lệnh gọi trước đó tới
vma_needs_reservation.  Nó sẽ hủy bỏ/kết thúc quá trình thêm đặt chỗ đang diễn ra
hoạt động::

vma_add_reservation dài (struct hstate *h,
				 cấu trúc vm_area_struct *vma,
				 địa chỉ dài không dấu)

Đây là một quy trình bao bọc đặc biệt để giúp tạo điều kiện thuận lợi cho việc dọn dẹp đặt trước
trên các đường dẫn lỗi.  Nó chỉ được gọi từ thường trình recovery_reserve_on_error().
Thói quen này được sử dụng cùng với vma_needs_reservation trong một nỗ lực
để thêm đặt chỗ vào bản đồ đặt chỗ.  Nó có tính đến
ngữ nghĩa bản đồ dành riêng khác nhau cho ánh xạ riêng tư và ánh xạ chia sẻ.  Do đó,
vùng_add được gọi cho ánh xạ chia sẻ (dưới dạng mục nhập có trong bản đồ
biểu thị sự đặt chỗ) và Region_del được gọi cho ánh xạ riêng tư (như
sự vắng mặt của một mục trong bản đồ cho thấy sự đặt chỗ).  Xem phần
"Dọn dẹp đặt chỗ trong đường dẫn lỗi" để biết thêm thông tin về những gì cần làm
được thực hiện trên các đường dẫn lỗi.


Dọn dẹp đặt trước trong đường dẫn lỗi
=====================================

Như đã đề cập ở phần
ZZ0000ZZ, đặt chỗ
sửa đổi bản đồ được thực hiện theo hai bước.  vma_needs_reservation đầu tiên
được gọi trước khi một trang được phân bổ.  Nếu việc phân bổ thành công,
sau đó vma_commit_reservation được gọi.  Nếu không, vma_end_reservation sẽ được gọi.
Số lượng đặt trước chung và nhóm phụ được điều chỉnh dựa trên thành công hay thất bại
của hoạt động và tất cả đều tốt.

Ngoài ra, sau khi một trang lớn được khởi tạo, cờ PagePrivate sẽ
được xóa để việc tính toán khi trang cuối cùng được giải phóng là chính xác.

Tuy nhiên, có một số trường hợp gặp phải lỗi sau một lượng lớn
trang được phân bổ nhưng trước khi nó được khởi tạo.  Trong trường hợp này, trang
phân bổ đã sử dụng phần đặt trước và tạo nhóm con thích hợp,
bản đồ đặt chỗ và điều chỉnh số lượng toàn cầu.  Nếu trang được giải phóng tại thời điểm này
thời gian (trước khi khởi tạo và xóa PagePrivate), sau đó free_huge_folio
sẽ tăng số lượng đặt phòng toàn cầu.  Tuy nhiên, bản đồ đặt chỗ
cho biết đặt chỗ đã được sử dụng.  Điều này dẫn đến trạng thái không nhất quán
sẽ gây ra sự 'rò rỉ' của một trang lớn dành riêng.  Số lượng dự trữ toàn cầu sẽ
cao hơn mức cần thiết và ngăn chặn việc phân bổ trang được phân bổ trước.

Quy trình recovery_reserve_on_error() cố gắng xử lý tình huống này.  Nó
được ghi lại khá tốt.  Mục đích của thói quen này là để khôi phục
bản đồ đặt chỗ giống như trước khi phân bổ trang.   Trong này
theo cách này, trạng thái của bản đồ đặt chỗ sẽ tương ứng với đặt chỗ toàn cầu
đếm sau khi trang được giải phóng.

Bản thân quy trình recovery_reserve_on_error có thể gặp lỗi trong khi
đang cố gắng khôi phục mục nhập bản đồ đặt chỗ.  Trong trường hợp này, nó sẽ
chỉ cần xóa cờ PagePrivate của trang.  Bằng cách này, toàn cầu
số lượng dự trữ sẽ không được tăng lên khi trang được giải phóng.  Tuy nhiên,
bản đồ đặt chỗ sẽ tiếp tục trông như thể việc đặt chỗ đã được sử dụng.
Một trang vẫn có thể được phân bổ cho địa chỉ, nhưng nó sẽ không sử dụng địa chỉ dành riêng
trang như dự định ban đầu.

Có một số mã (đáng chú ý nhất là userfaultfd) không thể gọi
khôi phục_reserve_on_error.  Trong trường hợp này, nó chỉ sửa đổi PagePrivate
để việc đặt chỗ sẽ không bị rò rỉ khi trang khổng lồ được giải phóng.


Chính sách đặt chỗ và bộ nhớ
==============================
Danh sách trang lớn trên mỗi nút tồn tại trong struct hstate khi git được sử dụng lần đầu tiên
để quản lý mã Linux.  Khái niệm đặt chỗ đã được thêm vào một thời gian sau đó.
Khi việc đặt trước được thêm vào, không có nỗ lực nào được thực hiện để thực hiện chính sách bộ nhớ
tính đến.  Mặc dù cpuset không hoàn toàn giống với chính sách bộ nhớ, nhưng điều này
bình luận trong Hugetlb_acct_memory tổng hợp sự tương tác giữa các đặt phòng
và chính sách bộ nhớ/bộ nhớ::

/*
	 * Khi cpuset được cấu hình, nó sẽ phá vỡ trang Hugetlb nghiêm ngặt
	 * đặt trước vì việc tính toán được thực hiện trên một biến toàn cục. Như vậy
	 * việc đặt trước hoàn toàn vô nghĩa khi có cpuset vì
	 * việc đặt chỗ không được kiểm tra dựa trên tính khả dụng của trang đối với
	 * bộ CPU hiện tại. Ứng dụng vẫn có khả năng bị OOM'ed bởi kernel
	 * thiếu trang htlb miễn phí trong cpuset chứa tác vụ.
	 * Nỗ lực thực thi kế toán chặt chẽ với cpuset gần như là
	 * không thể (hoặc quá xấu) vì cpuset quá lỏng nên
	 * tác vụ hoặc nút bộ nhớ có thể được di chuyển linh hoạt giữa các bộ CPU.
	 *
	 * Sự thay đổi ngữ nghĩa của ánh xạ Hugetlb được chia sẻ với CPUset là
	 * không mong muốn. Tuy nhiên, để bảo tồn một số ngữ nghĩa,
	 * chúng tôi quay lại kiểm tra tính khả dụng của trang miễn phí hiện tại vì
	 * một nỗ lực tốt nhất và hy vọng sẽ giảm thiểu tác động của việc thay đổi
	 * ngữ nghĩa mà cpuset có.
	 */

Đặt chỗ trang lớn đã được thêm vào để ngăn chặn việc phân bổ trang không mong muốn
lỗi (OOM) tại thời điểm lỗi trang.  Tuy nhiên, nếu một ứng dụng sử dụng
của bộ vi xử lý hoặc chính sách bộ nhớ, không có gì đảm bảo rằng các trang lớn sẽ
có sẵn trên các nút được yêu cầu.  Điều này đúng ngay cả khi có đủ
số lượng đặt phòng toàn cầu.

Kiểm tra hồi quy Hugetlbfs
============================

Bộ thử nghiệm Hugetlb đầy đủ nhất nằm trong kho lưu trữ libhugetlbfs.
Nếu bạn sửa đổi bất kỳ mã nào liên quan đến Hugetlb, hãy sử dụng bộ kiểm tra libhugetlbfs
để kiểm tra sự hồi quy.  Ngoài ra, nếu bạn thêm bất kỳ Hugetlb mới nào
chức năng, vui lòng thêm các bài kiểm tra thích hợp vào libhugetlbfs.

--
Mike Kravetz, ngày 7 tháng 4 năm 2017
