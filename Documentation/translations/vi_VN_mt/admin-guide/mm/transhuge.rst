.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/transhuge.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
Hỗ trợ Hugepage minh bạch
============================

Khách quan
=========

Các ứng dụng tính toán quan trọng về hiệu suất xử lý bộ nhớ lớn
các bộ làm việc đã chạy trên libhugetlbfs và đến lượt nó
Hugetlbfs. Hỗ trợ HugePage trong suốt (THP) là một phương tiện thay thế
sử dụng các trang lớn để hỗ trợ bộ nhớ ảo với các trang lớn
hỗ trợ việc tự động thăng cấp và hạ cấp kích thước trang và
không có những thiếu sót của Hugetlbfs.

Hiện tại THP chỉ hoạt động đối với ánh xạ bộ nhớ ẩn danh và tmpfs/shmem.
Nhưng trong tương lai nó có thể mở rộng sang các hệ thống tập tin khác.

.. note::
   in the examples below we presume that the basic page size is 4K and
   the huge page size is 2M, although the actual numbers may vary
   depending on the CPU architecture.

Lý do ứng dụng chạy nhanh hơn là vì hai
các yếu tố. Yếu tố đầu tiên gần như hoàn toàn không liên quan và nó không
được quan tâm đáng kể vì nó cũng sẽ có nhược điểm là
yêu cầu bản sao trang rõ ràng lớn hơn trong các lỗi trang, đây là một
tác động tiêu cực tiềm ẩn. Yếu tố đầu tiên bao gồm việc thực hiện một
lỗi trang đơn cho mỗi vùng ảo 2M mà vùng người dùng chạm tới (vì vậy
giảm tần số hạt nhân vào/ra theo hệ số 512 lần). Cái này
chỉ quan trọng vào lần đầu tiên bộ nhớ được truy cập trong suốt thời gian tồn tại của
một bản đồ bộ nhớ. Điều thứ hai lâu dài và quan trọng hơn nhiều
yếu tố này sẽ ảnh hưởng đến tất cả các lần truy cập tiếp theo vào bộ nhớ trong toàn bộ
thời gian chạy của ứng dụng. Yếu tố thứ hai gồm có hai
thành phần:

1) lỗi TLB sẽ chạy nhanh hơn (đặc biệt khi sử dụng ảo hóa
   các bảng phân trang lồng nhau nhưng hầu như luôn luôn có trên kim loại trần mà không có
   ảo hóa)

2) một mục TLB duy nhất sẽ ánh xạ số lượng ảo lớn hơn nhiều
   bộ nhớ lần lượt giảm số lượng TLB bị bỏ lỡ. Với
   ảo hóa và các bảng phân trang lồng nhau mà TLB có thể được ánh xạ
   kích thước lớn hơn chỉ khi cả KVM và máy khách Linux đều đang sử dụng
   Hugepages nhưng tốc độ tăng tốc đáng kể đã xảy ra nếu chỉ một trong
   cả hai đang sử dụng trang lớn chỉ vì thực tế là cô TLB
   sẽ chạy nhanh hơn.

Các hạt nhân hiện đại hỗ trợ "THP đa kích thước" (mTHP), giới thiệu
khả năng phân bổ bộ nhớ theo khối lớn hơn trang cơ sở
nhưng nhỏ hơn kích thước PMD truyền thống (như được mô tả ở trên), trong
số trang tăng lũy thừa 2. mTHP có thể ẩn danh
bộ nhớ (ví dụ: 16K, 32K, 64K, v.v.). Những THP này tiếp tục được
PTE được ánh xạ, nhưng trong nhiều trường hợp vẫn có thể mang lại lợi ích tương tự như
những điều đã nêu ở trên: Lỗi trang được giảm đáng kể (bằng một
yếu tố ví dụ 4, 8, 16, v.v.), nhưng độ trễ tăng đột biến ít hơn nhiều
nổi bật vì kích thước của mỗi trang không lớn bằng kích thước PMD
biến thể và có ít bộ nhớ hơn để xóa trong mỗi lỗi trang. Một số
kiến trúc cũng sử dụng cơ chế nén TLB để nén nhiều hơn
các mục nhập khi một tập hợp PTE gần như và liền kề về mặt vật lý
và căn chỉnh phù hợp. Trong trường hợp này, việc trượt TLB sẽ xảy ra ít hơn
thường xuyên.

THP có thể được kích hoạt trên toàn hệ thống hoặc bị hạn chế ở một số tác vụ nhất định hoặc thậm chí
phạm vi bộ nhớ bên trong không gian địa chỉ của tác vụ. Trừ khi THP hoàn toàn
bị vô hiệu hóa, có daemon ZZ0000ZZ quét bộ nhớ và
thu gọn chuỗi các trang cơ bản thành các trang lớn có kích thước PMD.

Hành vi THP được điều khiển thông qua ZZ0000ZZ
giao diện và sử dụng các lệnh gọi hệ thống madvise(2) và prctl(2).

Hỗ trợ Hugepage trong suốt tối đa hóa tính hữu ích của bộ nhớ trống
nếu so với phương pháp bảo lưu của Hugetlbfs bằng cách cho phép tất cả
bộ nhớ không được sử dụng sẽ được sử dụng làm bộ nhớ đệm hoặc bộ nhớ di động khác (hoặc thậm chí không thể di chuyển được).
các thực thể). Nó không yêu cầu đặt trước để ngăn chặn trang lớn
lỗi phân bổ có thể nhận thấy được từ vùng người dùng. Nó cho phép phân trang
và tất cả các tính năng VM nâng cao khác sẽ có sẵn trên
Hugepages. Nó không yêu cầu sửa đổi để các ứng dụng có thể thực hiện
lợi thế của nó.

Tuy nhiên, các ứng dụng có thể được tối ưu hóa hơn nữa để tận dụng
tính năng này, chẳng hạn như trước đây chúng đã được tối ưu hóa để tránh
một loạt hệ thống mmap yêu cầu mọi malloc(4k). Tối ưu hóa vùng người dùng
cho đến nay vẫn chưa bắt buộc và khugepaged đã có thể xử lý được lâu dài
phân bổ trang trực tiếp ngay cả đối với các ứng dụng không biết trang lớn
xử lý một lượng lớn bộ nhớ.

Trong một số trường hợp nhất định khi các trang lớn được kích hoạt trên toàn hệ thống, ứng dụng
cuối cùng có thể phân bổ nhiều tài nguyên bộ nhớ hơn. Một ứng dụng có thể mmap một
vùng lớn nhưng chỉ chạm vào 1 byte của nó, trong trường hợp đó một trang 2M có thể
được phân bổ thay vì một trang 4k là không tốt. Đây là lý do tại sao nó
có thể vô hiệu hóa các trang lớn trên toàn hệ thống và chỉ đặt chúng bên trong
MADV_HUGEPAGE vùng điên cuồng.

Các hệ thống nhúng chỉ nên kích hoạt các trang lớn bên trong các vùng madvise
để loại bỏ mọi nguy cơ lãng phí bất kỳ byte bộ nhớ quý giá nào và để
chỉ chạy nhanh hơn.

Các ứng dụng nhận được nhiều lợi ích từ các trang lớn nhưng không
nguy cơ mất bộ nhớ khi sử dụng Hugepages, nên sử dụng
madvise(MADV_HUGEPAGE) trên các vùng được ánh xạ quan trọng của chúng.

.. _thp_sysfs:

sysfs
=====

Điều khiển THP toàn cầu
-------------------

Hỗ trợ Hugepage trong suốt cho bộ nhớ ẩn danh có thể bị tắt
(chủ yếu nhằm mục đích gỡ lỗi) hoặc chỉ được kích hoạt bên trong MADV_HUGEPAGE
vùng (để tránh nguy cơ tiêu tốn nhiều tài nguyên bộ nhớ) hoặc kích hoạt
toàn hệ thống. Điều này có thể đạt được theo kích thước THP được hỗ trợ bằng một trong::

echo luôn >/sys/kernel/mm/transparent_hugepage/hugepages-<size>kB/enabled
	echo madvise >/sys/kernel/mm/transparent_hugepage/hugepages-<size>kB/enabled
	echo never >/sys/kernel/mm/transparent_hugepage/hugepages-<size>kB/enabled

trong đó <size> là kích thước trang lớn đang được xử lý, các kích thước có sẵn
mà thay đổi tùy theo hệ thống.

.. note:: Setting "never" in all sysfs THP controls does **not** disable
          Transparent Huge Pages globally. This is because ``madvise(...,
          MADV_COLLAPSE)`` ignores these settings and collapses ranges to
          PMD-sized huge pages unconditionally.

Ví dụ::

echo luôn >/sys/kernel/mm/transparent_hugepage/hugepages-2048kB/enabled

Ngoài ra, có thể chỉ định rằng kích thước trang lớn nhất định
sẽ kế thừa giá trị "được bật" cấp cao nhất::

echo kế thừa >/sys/kernel/mm/transparent_hugepage/hugepages-<size>kB/enabled

Ví dụ::

echo kế thừa >/sys/kernel/mm/transparent_hugepage/hugepages-2048kB/enabled

Cài đặt cấp cao nhất (để sử dụng với "kế thừa") có thể được đặt bằng cách đưa ra
một trong các lệnh sau::

echo luôn >/sys/kernel/mm/transparent_hugepage/enabled
	echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
	echo never >/sys/kernel/mm/transparent_hugepage/enabled

Theo mặc định, các trang lớn có kích thước PMD đã kích hoạt="inherit" và tất cả các trang khác
kích thước trang lớn đã bật="không bao giờ". Nếu kích hoạt nhiều trang lớn
kích thước, kernel sẽ chọn kích thước được kích hoạt phù hợp nhất cho
sự phân bổ nhất định.

Cũng có thể hạn chế các nỗ lực chống phân mảnh trong VM để tạo ra
các trang khổng lồ ẩn danh trong trường hợp chúng không được tự do phát điên ngay lập tức
vùng hoặc không bao giờ cố gắng chống phân mảnh bộ nhớ và chỉ đơn giản là dự phòng về chế độ thông thường
các trang trừ khi các trang lớn có sẵn ngay lập tức. Rõ ràng nếu chúng ta chi tiêu CPU
đã đến lúc chống phân mảnh bộ nhớ, chúng ta thậm chí còn mong đợi đạt được nhiều hơn bởi thực tế là chúng ta
sau này hãy sử dụng các trang lớn thay vì các trang thông thường. Điều này không phải lúc nào cũng
được đảm bảo, nhưng có thể có nhiều khả năng xảy ra hơn trong trường hợp việc phân bổ dành cho một
Vùng MADV_HUGEPAGE.

::

echo luôn >/sys/kernel/mm/transparent_hugepage/defrag
	echo defer >/sys/kernel/mm/transparent_hugepage/defrag
	echo defer+madvise >/sys/kernel/mm/transparent_hugepage/defrag
	echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
	echo never >/sys/kernel/mm/transparent_hugepage/defrag

luôn luôn
	có nghĩa là ứng dụng yêu cầu THP sẽ ngừng hoạt động
	lỗi phân bổ và thu hồi trực tiếp các trang và thu gọn
	bộ nhớ trong nỗ lực phân bổ THP ngay lập tức. Đây có thể là
	mong muốn đối với các máy ảo được hưởng lợi nhiều từ THP
	sử dụng và sẵn sàng trì hoãn việc VM bắt đầu sử dụng chúng.

trì hoãn
	có nghĩa là ứng dụng sẽ đánh thức kswapd ở chế độ nền
	để lấy lại các trang và đánh thức kcompactd vào bộ nhớ nhỏ gọn để
	THP sẽ ra mắt trong thời gian sắp tới. Đó là trách nhiệm
	của khugepaged để sau đó cài đặt các trang THP.

trì hoãn + điên cuồng
	sẽ tiến hành thu hồi và nén trực tiếp như ZZ0000ZZ, nhưng
	chỉ dành cho các khu vực đã sử dụng madvise(MADV_HUGEPAGE); tất cả
	các khu vực khác sẽ đánh thức kswapd ở chế độ nền để lấy lại
	trang và đánh thức kcompactd vào bộ nhớ nhỏ gọn để THP được
	có sẵn trong tương lai gần.

sự điên cuồng
	sẽ tiến hành thu hồi trực tiếp như ZZ0000ZZ nhưng chỉ dành cho các khu vực
	đã sử dụng madvise(MADV_HUGEPAGE). Đây là mặc định
	hành vi.

không bao giờ
	nên tự giải thích. Lưu ý rằng ZZ0000ZZ vẫn có thể khiến các trang lớn trong suốt bị
	thu được ngay cả khi chế độ này được chỉ định ở mọi nơi.

Theo mặc định, kernel cố gắng sử dụng trang 0 khổng lồ, có thể ánh xạ PMD khi đọc
lỗi trang đối với ánh xạ ẩn danh. Có thể vô hiệu hóa số 0 lớn
trang bằng cách viết 0 hoặc bật lại bằng cách viết 1::

echo 0 >/sys/kernel/mm/transparent_hugepage/use_zero_page
	echo 1 >/sys/kernel/mm/transparent_hugepage/use_zero_page

Một số không gian người dùng (chẳng hạn như chương trình thử nghiệm hoặc bộ nhớ được tối ưu hóa)
thư viện phân bổ) có thể muốn biết kích thước (tính bằng byte) của
Trang lớn trong suốt có thể ánh xạ PMD::

mèo /sys/kernel/mm/transparent_hugepage/hpage_pmd_size

Tất cả các THP có lỗi và thời gian sập sẽ được thêm vào _deferred_list,
và do đó sẽ được phân chia theo áp lực bộ nhớ nếu chúng được xem xét
"không được sử dụng". THP không được sử dụng đúng mức nếu số lượng trang trống trong
THP ở trên max_ptes_none (xem bên dưới). Có thể vô hiệu hóa
hành vi này bằng cách viết 0 vào shr_underused và kích hoạt nó bằng cách viết
1 cho nó::

echo 0 > /sys/kernel/mm/transparent_hugepage/shrink_underused
	echo 1 > /sys/kernel/mm/transparent_hugepage/shrink_underused

khugepaged sẽ tự động khởi động khi THP cỡ PMD được bật
(điều khiển anon theo kích thước hoặc điều khiển cấp cao nhất được đặt
thành "luôn luôn" hoặc "madvise") và nó sẽ tự động tắt khi
PMD THP có kích thước PMD bị vô hiệu hóa (khi cả điều khiển anon theo kích thước và
kiểm soát cấp cao nhất là "không bao giờ")

xử lý điều khiển THP
--------------------

Một tiến trình có thể kiểm soát hành vi THP của chính nó bằng ZZ0000ZZ
và cặp cuộc gọi prctl(2) ZZ0001ZZ. Bộ hành vi THP sử dụng
ZZ0002ZZ được kế thừa qua fork(2) và execve(2). Những cuộc gọi này
hỗ trợ các đối số sau::

prctl(PR_SET_THP_DISABLE, 1, 0, 0, 0):
		Điều này sẽ vô hiệu hóa hoàn toàn THP trong quá trình, bất kể
		của các điều khiển THP toàn cầu hoặc madvise(..., MADV_COLLAPSE) đang được sử dụng.

prctl(PR_SET_THP_DISABLE, 1, PR_THP_DISABLE_EXCEPT_ADVISED, 0, 0):
		Điều này sẽ vô hiệu hóa THP cho quá trình trừ khi việc sử dụng THP bị hạn chế.
		khuyên nhủ. Do đó, THP sẽ chỉ được sử dụng khi:
		- Điều khiển THP toàn cầu được đặt thành "luôn luôn" hoặc "madvise" và
		  madvise(..., MADV_HUGEPAGE) hoặc madvise(..., MADV_COLLAPSE) được sử dụng.
		- Điều khiển THP toàn cầu được đặt thành "never" và madvise(..., MADV_COLLAPSE)
		  được sử dụng. Đây là hành vi tương tự như khi THP không bị vô hiệu hóa trên
		  một mức độ quá trình
		Lưu ý rằng MADV_COLLAPSE hiện luôn bị từ chối nếu
		madvise(..., MADV_NOHUGEPAGE) được đặt trên một khu vực.

prctl(PR_SET_THP_DISABLE, 0, 0, 0, 0):
		Điều này sẽ kích hoạt lại THP cho quy trình, như thể chúng chưa bao giờ bị vô hiệu hóa.
		Liệu THP có thực sự được sử dụng hay không tùy thuộc vào các điều khiển THP toàn cầu và
		cuộc gọi madvise().

prctl(PR_GET_THP_DISABLE, 0, 0, 0, 0):
		Điều này trả về một giá trị có các bit cho biết cách định cấu hình tính năng vô hiệu hóa THP:
		Bit
		 1 0 Giá trị Mô tả
		ZZ0000ZZ0|   0 Không có hành vi vô hiệu hóa THP nào được chỉ định.
		ZZ0001ZZ1|   1 THP bị vô hiệu hóa hoàn toàn đối với quá trình này.
		ZZ0002ZZ1|   3 Chế độ THP-ngoại trừ được khuyên dùng được đặt cho quá trình này.

Điều khiển được phân trang
-------------------

.. note::
   khugepaged currently only searches for opportunities to collapse to
   PMD-sized THP and no attempt is made to collapse to other THP
   sizes.

khugepaged thường chạy ở tần số thấp nên người ta có thể không muốn
gọi các thuật toán chống phân mảnh một cách đồng bộ khi xảy ra lỗi trang, nó
ít nhất nên sử dụng tính năng chống phân mảnh trong khugepaged. Tuy nhiên nó
cũng có thể tắt tính năng chống phân mảnh trong khugepaged bằng cách viết 0 hoặc bật
chống phân mảnh trong khugepaged bằng cách viết 1::

echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
	echo 1 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag

Bạn cũng có thể kiểm soát số lượng trang khugepaged nên quét mỗi lần
vượt qua::

/sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan

và bao nhiêu mili giây phải chờ trong khugepaged giữa mỗi lần chuyển (bạn
có thể đặt giá trị này thành 0 để chạy khugepaged với mức sử dụng 100% một lõi)::

/sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs

và phải đợi bao nhiêu mili giây trong khugepaged nếu có một trang lớn
lỗi phân bổ để điều tiết nỗ lực phân bổ tiếp theo::

/sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs

Tiến trình khugepaged có thể được nhìn thấy qua số trang được thu gọn (lưu ý
rằng bộ đếm này có thể không phải là số đếm chính xác của số trang
đã sụp đổ, vì "sụp đổ" có thể có nhiều nghĩa: (1) Ánh xạ PTE
được thay thế bằng ánh xạ PMD hoặc (2) Tất cả các trang vật lý 4K được thay thế bằng
một trang lớn 2M. Mỗi sự việc có thể xảy ra độc lập hoặc cùng nhau, tùy thuộc vào
loại bộ nhớ và các lỗi xảy ra. Như vậy, giá trị này phải
được hiểu đại khái là dấu hiệu của sự tiến bộ và bộ đếm trong /proc/vmstat
được tư vấn để hạch toán chính xác hơn)::

/sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed

cho mỗi lần vượt qua::

/sys/kernel/mm/transparent_hugepage/khugepaged/full_scans

ZZ0000ZZ chỉ định có bao nhiêu trang nhỏ bổ sung (tức là
chưa được ánh xạ) có thể được phân bổ khi thu gọn một nhóm
các trang nhỏ thành một trang lớn::

/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none

Giá trị cao hơn dẫn đến việc sử dụng thêm bộ nhớ cho các chương trình.
Giá trị thấp hơn dẫn đến hiệu suất đạt được ít hơn. Giá trị của
max_ptes_none có thể lãng phí rất ít thời gian của CPU, bạn có thể
bỏ qua nó.

ZZ0000ZZ chỉ định số lượng trang có thể được đưa vào từ
trao đổi khi thu gọn một nhóm trang thành một trang lớn trong suốt::

/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap

Giá trị cao hơn có thể gây ra sự trao đổi IO quá mức và lãng phí
trí nhớ. Giá trị thấp hơn có thể ngăn không cho THP bị
bị thu gọn, dẫn đến có ít trang được thu gọn vào
THP và hiệu suất truy cập bộ nhớ thấp hơn.

ZZ0000ZZ chỉ định số lượng trang có thể được chia sẻ trên nhiều trang
quá trình. khugepaged có thể coi các trang của THP là được chia sẻ nếu bất kỳ trang nào của
THP đó được chia sẻ. Vượt quá số lượng sẽ chặn sự sụp đổ::

/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_shared

Giá trị cao hơn có thể tăng dung lượng bộ nhớ cho một số khối lượng công việc.

Thông số khởi động
===============

Bạn có thể thay đổi mặc định thời gian khởi động sysfs cho "đã bật" cấp cao nhất
điều khiển bằng cách truyền tham số ZZ0000ZZ hoặc
ZZ0001ZZ hoặc ZZ0002ZZ cho
dòng lệnh hạt nhân.

Ngoài ra, mỗi kích thước THP ẩn danh được hỗ trợ có thể được kiểm soát bởi
vượt qua ZZ0000ZZ,
trong đó ZZ0001ZZ là kích thước THP (phải là lũy thừa của 2 của PAGE_SIZE và
được hỗ trợ THP ẩn danh) và ZZ0002ZZ là một trong những ZZ0003ZZ, ZZ0004ZZ,
ZZ0005ZZ hoặc ZZ0006ZZ.

Ví dụ: phần sau đây sẽ đặt 16K, 32K, 64K THP thành ZZ0000ZZ,
đặt 128K, 512K thành ZZ0001ZZ, đặt 256K thành ZZ0002ZZ và 1M, 2M
tới ZZ0003ZZ::

thp_anon=16K-64K:luôn luôn;128K,512K:kế thừa;256K:madvise;1M-2M:không bao giờ

ZZ0000ZZ có thể được chỉ định nhiều lần để định cấu hình tất cả các kích thước THP như
được yêu cầu. Nếu ZZ0001ZZ được chỉ định ít nhất một lần, mọi kích thước THP của anon
không được cấu hình rõ ràng trên dòng lệnh được đặt ngầm thành
ZZ0002ZZ.

Cài đặt ZZ0000ZZ chỉ ảnh hưởng đến chuyển đổi chung. Nếu
ZZ0001ZZ không được chỉ định, PMD_ORDER THP sẽ mặc định là ZZ0002ZZ.
Tuy nhiên, nếu người dùng cung cấp cài đặt ZZ0003ZZ hợp lệ,
Chính sách PMD_ORDER THP sẽ bị ghi đè. Nếu chính sách dành cho PMD_ORDER
không được xác định trong ZZ0004ZZ hợp lệ, chính sách của nó sẽ mặc định là
ZZ0005ZZ.

Tương tự như ZZ0000ZZ, bạn có thể kiểm soát trang lớn
chính sách phân bổ cho mount shmem nội bộ bằng cách sử dụng tham số kernel
ZZ0001ZZ, trong đó ZZ0002ZZ là một trong những
bảy chính sách hợp lệ cho shmem (ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ,
ZZ0006ZZ, ZZ0007ZZ và ZZ0008ZZ).

Tương tự như ZZ0000ZZ, bạn có thể điều khiển mặc định
chính sách phân bổ Hugepage cho mount tmpfs bằng cách sử dụng tham số kernel
ZZ0001ZZ, trong đó ZZ0002ZZ là một trong những
bốn chính sách hợp lệ cho tmpfs (ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ,
ZZ0006ZZ). Chính sách mặc định gắn kết tmpfs là ZZ0007ZZ.

Ngoài ra, các tùy chọn Kconfig có sẵn để đặt trang lớn mặc định
chính sách cho shmem (ZZ0000ZZ) và tmpfs
(ZZ0001ZZ) tại thời điểm xây dựng. Tham khảo
Trợ giúp Kconfig để biết thêm chi tiết.

Theo cách tương tự như ZZ0000ZZ kiểm soát từng THP ẩn danh được hỗ trợ
kích thước, ZZ0001ZZ kiểm soát từng kích thước shmem THP được hỗ trợ. ZZ0002ZZ
có cùng định dạng với ZZ0003ZZ, nhưng cũng hỗ trợ chính sách
ZZ0004ZZ.

ZZ0000ZZ có thể được chỉ định nhiều lần để định cấu hình tất cả các kích thước THP
theo yêu cầu. Nếu ZZ0001ZZ được chỉ định ít nhất một lần, bất kỳ shmem THP nào
kích thước không được cấu hình rõ ràng trên dòng lệnh được đặt ngầm thành
ZZ0002ZZ.

Cài đặt ZZ0000ZZ chỉ ảnh hưởng đến chuyển đổi chung. Nếu
ZZ0001ZZ không được chỉ định, trang lớn PMD_ORDER sẽ mặc định là
ZZ0002ZZ. Tuy nhiên, nếu cài đặt ZZ0003ZZ hợp lệ được cung cấp bởi
người dùng, chính sách trang lớn PMD_ORDER sẽ bị ghi đè. Nếu chính sách dành cho
PMD_ORDER không được xác định trong ZZ0004ZZ hợp lệ, chính sách của nó sẽ
mặc định là ZZ0005ZZ.

Các trang lớn trong tmpfs/shmem
========================

Theo truyền thống, tmpfs chỉ hỗ trợ một kích thước trang lớn ("PMD"). Hôm nay,
nó cũng hỗ trợ các kích thước nhỏ hơn giống như bộ nhớ ẩn danh, thường được gọi
thành "THP đa kích thước" (mTHP). Các trang lớn có kích thước bất kỳ thường được
được thể hiện trong kernel dưới dạng "folio lớn".

Mặc dù có khả năng kiểm soát tốt đối với kích thước trang lớn để sử dụng cho nội bộ
gắn kết shmem (xem bên dưới), các gắn kết tmpfs thông thường sẽ tận dụng tất cả các giá trị có sẵn
kích thước trang khổng lồ mà không có bất kỳ sự kiểm soát nào đối với kích thước chính xác, hoạt động giống như
các hệ thống tập tin khác.

gắn kết tmpfs
------------

Chính sách phân bổ THP cho các mount tmpfs có thể được điều chỉnh bằng cách sử dụng mount
tùy chọn: ZZ0000ZZ. Nó có thể có các giá trị sau:

luôn luôn
    Cố gắng phân bổ các trang lớn mỗi khi chúng ta cần một trang mới;
    Trước tiên, hãy luôn thử các trang lớn có kích thước PMD và quay lại các trang có kích thước nhỏ hơn.
    các trang lớn nếu việc phân bổ trang lớn có kích thước PMD không thành công;

không bao giờ
    Không phân bổ các trang lớn. Lưu ý rằng ZZ0000ZZ
    vẫn có thể tạo ra các trang lớn trong suốt ngay cả khi chế độ này
    được chỉ định ở mọi nơi;

trong_size
    Chỉ phân bổ trang lớn nếu nó hoàn toàn nằm trong i_size;
    Trước tiên, hãy luôn thử các trang lớn có kích thước PMD và quay lại các trang có kích thước nhỏ hơn.
    các trang lớn nếu việc phân bổ trang lớn có kích thước PMD không thành công;
    Cũng tôn trọng gợi ý madvise();

khuyên nhủ
    Chỉ phân bổ các trang lớn nếu được yêu cầu với madvise();

Hãy nhớ rằng hạt nhân có thể sử dụng các trang lớn ở mọi kích cỡ có sẵn và
không có khả năng kiểm soát tốt đối với giá treo tmpfs bên trong.

Chính sách mặc định trước đây là ZZ0000ZZ, nhưng giờ đây nó có thể được điều chỉnh
sử dụng tham số kernel ZZ0001ZZ.

ZZ0000ZZ hoạt động tốt sau khi gắn kết: gắn lại
ZZ0001ZZ sẽ không cố gắng chia nhỏ các trang lớn mà chỉ dừng lại
khỏi bị phân bổ.

Ngoài các chính sách được liệt kê ở trên, nút sysfs
/sys/kernel/mm/transparent_hugepage/shmem_enabled sẽ ảnh hưởng đến
chính sách phân bổ của các mount tmpfs, khi được đặt thành các giá trị sau:

phủ nhận
    Để sử dụng trong trường hợp khẩn cấp, để tắt tùy chọn lớn khỏi
    tất cả các thú cưỡi;
lực lượng
    Buộc bật tùy chọn lớn cho tất cả - rất hữu ích cho việc thử nghiệm;

shmem / tmpfs nội bộ
----------------------
Mount tmpfs nội bộ được sử dụng cho SysV SHM, memfds, chia sẻ ẩn danh
mmaps (của /dev/zero hoặc MAP_ANONYMOUS), đối tượng DRM của trình điều khiển GPU, Ashmem.

Để kiểm soát chính sách phân bổ THP cho mount tmpfs nội bộ này,
núm sysfs /sys/kernel/mm/transparent_hugepage/shmem_enabled và các nút bấm
mỗi kích thước THP trong
'/sys/kernel/mm/transparent_hugepage/hugepages-<size>kB/shmem_enabled'
có thể được sử dụng

Núm chung có cùng ngữ nghĩa với các tùy chọn gắn ZZ0000ZZ
đối với các mount tmpfs, ngoại trừ việc có thể kiểm soát được các kích thước trang lớn khác nhau
riêng lẻ và sẽ chỉ sử dụng cài đặt của núm chung khi
núm theo kích thước được đặt thành 'kế thừa'.

Các tùy chọn 'bắt buộc' và 'từ chối' bị loại bỏ đối với các kích thước riêng lẻ,
đúng hơn là đang thử nghiệm các hiện vật từ thời xa xưa.

luôn luôn
    Cố gắng phân bổ <size> các trang lớn mỗi khi chúng ta cần một trang mới;

kế thừa
    Kế thừa giá trị "shmem_enabled" cấp cao nhất. Theo mặc định, các trang lớn có kích thước PMD
    đã kích hoạt="inherit" và tất cả các kích thước trang lớn khác đã kích hoạt="never";

không bao giờ
    Không phân bổ <size> trang lớn. Lưu ý rằng ZZ0000ZZ vẫn có thể tạo ra các trang lớn trong suốt
    ngay cả khi chế độ này được chỉ định ở mọi nơi;

trong_size
    Chỉ phân bổ trang lớn <size> nếu nó hoàn toàn nằm trong i_size.
    Cũng tôn trọng gợi ý madvise();

khuyên nhủ
    Chỉ phân bổ <size> các trang lớn nếu được yêu cầu với madvise();

Cần khởi động lại ứng dụng
===========================

Transparent_hugepage/enabled và
các giá trị trong suốt_hugepage/hugepages-<size>kB/enabled và tmpfs mount
tùy chọn chỉ ảnh hưởng đến hành vi trong tương lai. Vì vậy để chúng có hiệu quả bạn cần
để khởi động lại bất kỳ ứng dụng nào có thể đang sử dụng Hugepages. Cái này
cũng áp dụng cho các khu vực đã đăng ký tại khugepaged.

Giám sát việc sử dụng
================

Số lượng trang lớn trong suốt ẩn danh có kích thước PMD hiện đang được sử dụng
hệ thống có sẵn bằng cách đọc trường AnonHugePages trong ZZ0000ZZ.
Để xác định những ứng dụng nào đang sử dụng kích thước lớn trong suốt ẩn danh PMD
trang, cần phải đọc ZZ0001ZZ và đếm AnonHugePages
các trường cho mỗi ánh xạ. (Lưu ý AnonHugePages chỉ áp dụng cho truyền thống
PMD có kích thước THP vì lý do lịch sử và đáng lẽ phải được gọi
AnonHugePmdMapped).

Số lượng trang lớn trong suốt được ánh xạ tới không gian người dùng có sẵn
bằng cách đọc các trường ShmemPmdMapped và ShmemHugePages trong ZZ0000ZZ.
Để xác định ứng dụng nào đang ánh xạ tập tin trong các trang lớn, nó
cần thiết để đọc ZZ0001ZZ và đếm các trường FilePmdMapped
cho mỗi bản đồ.

Lưu ý rằng việc đọc tệp smaps rất tốn kém và đọc nó
thường xuyên sẽ phải chịu chi phí chung.

Có một số bộ đếm trong ZZ0000ZZ có thể được sử dụng để
theo dõi mức độ thành công của hệ thống trong việc cung cấp các trang lớn để sử dụng.

thp_fault_alloc
	được tăng lên mỗi khi một trang lớn thành công
	được phân bổ và tính phí để xử lý lỗi trang.

thp_collapse_alloc
	được tăng lên bởi khugepaged khi nó tìm thấy
	một loạt các trang để thu gọn lại thành một trang lớn và có
	đã phân bổ thành công một trang lớn mới để lưu trữ dữ liệu.

thp_fault_fallback
	được tăng lên nếu lỗi trang không phân bổ hoặc tính phí
	một trang lớn và thay vào đó quay trở lại sử dụng các trang nhỏ.

thp_fault_fallback_charge
	được tăng lên nếu lỗi trang không tính được một trang lớn và
	thay vào đó quay lại sử dụng các trang nhỏ mặc dù
	phân bổ đã thành công.

thp_collapse_alloc_failed
	được tăng lên nếu khugepaged tìm thấy một phạm vi
	số trang cần được thu gọn thành một trang lớn nhưng không thành công
	sự phân bổ.

thp_file_alloc
	được tăng lên mỗi khi một trang lớn shmem thành công
	được phân bổ (Lưu ý rằng mặc dù được đặt tên theo "file", bộ đếm
	biện pháp chỉ shmem).

thp_file_fallback
	được tăng lên nếu một trang lớn shmem được cố gắng phân bổ
	nhưng không thành công và thay vào đó lại quay lại sử dụng các trang nhỏ. (Lưu ý rằng
	mặc dù được đặt tên theo "file", bộ đếm chỉ đo shmem).

thp_file_fallback_charge
	được tăng lên nếu không thể tính phí một trang lớn shmem và thay vào đó
	quay trở lại sử dụng các trang nhỏ mặc dù việc phân bổ đã được thực hiện
	thành công. (Lưu ý rằng mặc dù được đặt tên theo "file", nhưng
	biện pháp đối phó chỉ shmem).

thp_file_mapped
	được tăng lên mỗi khi một tệp hoặc trang lớn shmem được ánh xạ vào
	không gian địa chỉ người dùng.

thp_split_page
	được tăng lên mỗi khi một trang lớn được chia thành cơ sở
	trang. Điều này có thể xảy ra vì nhiều lý do nhưng có một nguyên nhân chung
	lý do là một trang lớn đã cũ và đang được thu hồi.
	Hành động này ngụ ý chia tách tất cả PMD mà trang được ánh xạ.

thp_split_page_failed
	được tăng lên nếu kernel không chia nhỏ được
	trang. Điều này có thể xảy ra nếu trang bị ai đó ghim.

thp_deferred_split_page
	được tăng lên khi một trang lớn được chia nhỏ
	xếp hàng. Điều này xảy ra khi một trang lớn chưa được ánh xạ một phần và
	chia tách nó sẽ giải phóng một số bộ nhớ. Các trang trên hàng đợi phân chia là
	sẽ bị phân chia dưới áp lực bộ nhớ.

thp_underused_split_page
	được tăng lên khi một trang lớn trên hàng đợi phân chia được chia
	bởi vì nó đã không được sử dụng. THP không được sử dụng đúng mức nếu số lượng
	không có trang nào trong THP vượt quá ngưỡng nhất định
	(/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none).

thp_split_pmd
	được tăng lên mỗi khi PMD được chia thành bảng PTE.
	Điều này có thể xảy ra, ví dụ, khi ứng dụng gọi mprotect() hoặc
	munmap() trên một phần của trang lớn. Nó không chia trang lớn, chỉ
	mục nhập bảng trang.

thp_zero_page_alloc
	được tăng lên mỗi khi có một trang số 0 lớn được sử dụng cho thp
	được phân bổ thành công. Lưu ý, nó không tính mọi bản đồ của
	trang số 0 khổng lồ, chỉ có sự phân bổ của nó.

thp_zero_page_alloc_failed
	được tăng lên nếu kernel không phân bổ được
	trang số 0 lớn và quay trở lại sử dụng các trang nhỏ.

thp_swpout
	được tăng lên mỗi khi một trang lớn được hoán đổi thành một
	mảnh mà không bị tách rời.

thp_swpout_fallback
	được tăng lên nếu một trang lớn phải được chia nhỏ trước khi hoán đổi.
	Thông thường là do không phân bổ được một số không gian trao đổi liên tục
	cho trang lớn.

Trong /sys/kernel/mm/transparent_hugepage/hugepages-<size>kB/stats, có
cũng có các bộ đếm riêng cho từng kích thước trang lớn, có thể được sử dụng để
giám sát hiệu quả của hệ thống trong việc cung cấp các trang lớn để sử dụng. Mỗi
bộ đếm có tập tin tương ứng của riêng nó.

anon_fault_alloc
	được tăng lên mỗi khi một trang lớn thành công
	được phân bổ và tính phí để xử lý lỗi trang.

anon_fault_fallback
	được tăng lên nếu lỗi trang không phân bổ hoặc tính phí
	một trang lớn và thay vào đó quay trở lại sử dụng các trang lớn với
	đơn hàng thấp hơn hoặc trang nhỏ.

anon_fault_fallback_charge
	được tăng lên nếu lỗi trang không tính được một trang lớn và
	thay vào đó quay lại sử dụng các trang lớn với thứ tự thấp hơn hoặc
	trang nhỏ mặc dù việc phân bổ đã thành công.

zswpout
	được tăng lên mỗi khi một trang lớn được hoán đổi thành zswap trong một
	mảnh mà không bị tách rời.

quay vòng
	được tăng lên mỗi khi một trang lớn được hoán đổi từ một trang không phải zswap
	trao đổi thiết bị trong một mảnh.

swpin_fallback
	được tăng lên nếu swapin không phân bổ hoặc tính phí một trang lớn
	và thay vào đó quay lại sử dụng các trang lớn với thứ tự thấp hơn hoặc
	các trang nhỏ.

swpin_fallback_charge
	được tăng lên nếu swapin không tính phí được một trang lớn và thay vào đó
	quay trở lại sử dụng các trang lớn với đơn hàng thấp hơn hoặc các trang nhỏ
	mặc dù việc phân bổ đã thành công.

chảy ra
	được tăng lên mỗi khi một trang lớn được hoán đổi sang một trang không phải zswap
	trao đổi thiết bị thành một mảnh mà không cần chia tách.

swpout_fallback
	được tăng lên nếu một trang lớn phải được chia nhỏ trước khi hoán đổi.
	Thông thường là do không phân bổ được một số không gian trao đổi liên tục
	cho trang lớn.

shmem_alloc
	được tăng lên mỗi khi một trang lớn shmem thành công
	được phân bổ.

shmem_fallback
	được tăng lên nếu một trang lớn shmem được cố gắng phân bổ
	nhưng không thành công và thay vào đó lại quay lại sử dụng các trang nhỏ.

shmem_fallback_charge
	được tăng lên nếu không thể tính phí một trang lớn shmem và thay vào đó
	quay trở lại sử dụng các trang nhỏ mặc dù việc phân bổ đã được thực hiện
	thành công.

chia đôi
	được tăng lên mỗi khi một trang lớn được chia thành công
	những đơn đặt hàng nhỏ hơn. Điều này có thể xảy ra vì nhiều lý do nhưng
	lý do phổ biến là một trang lớn đã cũ và đang được thu hồi.

chia_thất bại
	được tăng lên nếu kernel không chia nhỏ được
	trang. Điều này có thể xảy ra nếu trang bị ai đó ghim.

chia_deferred
        được tăng lên khi một trang lớn được đưa vào hàng đợi phân chia.
        Điều này xảy ra khi một trang lớn không được ánh xạ một phần và bị chia tách
        nó sẽ giải phóng một số bộ nhớ. Các trang trong hàng đợi phân chia sẽ được chuyển đến
        được phân chia dưới áp lực bộ nhớ, nếu có thể chia tách.

nr_anon
       số lượng THP ẩn danh mà chúng tôi có trong toàn hệ thống. Những THP này
       hiện tại có thể đã được ánh xạ hoàn toàn hoặc chưa được ánh xạ một phần/chưa sử dụng
       các trang con.

nr_anon_partial_mapped
       số THP ẩn danh có khả năng được ánh xạ một phần, có thể
       lãng phí bộ nhớ và đã được xếp hàng đợi để thu hồi bộ nhớ bị trì hoãn.
       Lưu ý rằng trong một số trường hợp (ví dụ: di chuyển không thành công), chúng tôi có thể phát hiện
       một THP ẩn danh được "ánh xạ một phần" và tính nó ở đây, mặc dù nó
       thực tế không còn được ánh xạ một phần nữa.

Khi hệ thống cũ đi, việc phân bổ các trang lớn có thể tốn kém vì
hệ thống sử dụng việc nén bộ nhớ để sao chép dữ liệu xung quanh bộ nhớ nhằm giải phóng một
trang lớn để sử dụng. Có một số bộ đếm trong ZZ0000ZZ để trợ giúp
giám sát chi phí này.

nhỏ gọn_gian hàng
	được tăng lên mỗi khi một quá trình ngừng chạy
	nén bộ nhớ để có thể sử dụng miễn phí một trang lớn.

nhỏ gọn_thành công
	được tăng lên nếu hệ thống nén bộ nhớ và
	giải phóng một trang lớn để sử dụng.

nhỏ gọn_fail
	được tăng lên nếu hệ thống cố gắng nén bộ nhớ
	nhưng đã thất bại.

Có thể xác định các quầy hàng đã sử dụng chức năng này trong bao lâu
công cụ theo dõi để ghi lại thời gian đã sử dụng trong __alloc_pages() và
sử dụng điểm theo dõi mm_page_alloc để xác định phân bổ nào được thực hiện
cho các trang lớn.

Tối ưu hóa các ứng dụng
===========================

Để được đảm bảo rằng kernel sẽ ánh xạ THP ngay lập tức trong bất kỳ
vùng bộ nhớ, vùng mmap phải là trang lớn một cách tự nhiên
căn chỉnh. posix_memalign() có thể cung cấp sự đảm bảo đó.

lớntlbfs
=========

Bạn có thể sử dụng Hugetlbfs trên kernel có trang lớn trong suốt
hỗ trợ được kích hoạt vẫn tốt như mọi khi. Không có sự khác biệt có thể được ghi nhận trong
Hugetlbfs khác ngoài sẽ có ít sự phân mảnh tổng thể hơn. Tất cả
các tính năng thông thường thuộc về Hugetlbfs được bảo tồn và
không bị ảnh hưởng. libhugetlbfs cũng sẽ hoạt động tốt như bình thường.
