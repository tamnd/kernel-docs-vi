.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/numa_memory_policy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Chính sách bộ nhớ NUMA
======================

Chính sách bộ nhớ NUMA là gì?
============================

Trong nhân Linux, "chính sách bộ nhớ" xác định hạt nhân sẽ từ nút nào
phân bổ bộ nhớ trong hệ thống NUMA hoặc trong hệ thống NUMA mô phỏng.  Linux có
các nền tảng được hỗ trợ với kiến trúc Truy cập bộ nhớ không đồng nhất kể từ phiên bản 2.4.?.
Hỗ trợ chính sách bộ nhớ hiện tại đã được thêm vào Linux 2.6 vào khoảng tháng 5 năm 2004. Điều này
tài liệu cố gắng mô tả các khái niệm và API của chính sách bộ nhớ 2.6
hỗ trợ.

Không nên nhầm lẫn chính sách bộ nhớ với cpuset
(ZZ0001ZZ)
đó là một cơ chế quản trị để hạn chế các nút mà từ đó
bộ nhớ có thể được phân bổ bởi một tập hợp các tiến trình. Chính sách bộ nhớ là một
giao diện lập trình mà ứng dụng nhận biết NUMA có thể tận dụng.  Khi nào
cả CPUset và chính sách đều được áp dụng cho một tác vụ, các hạn chế của CPUset
được ưu tiên.  Xem ZZ0000ZZ
bên dưới để biết thêm chi tiết.

Khái niệm chính sách bộ nhớ
======================

Phạm vi chính sách bộ nhớ
------------------------

Nhân Linux hỗ trợ _scopes_ chính sách bộ nhớ, được mô tả ở đây từ
tổng quát nhất đến cụ thể nhất:

Chính sách mặc định của hệ thống
	chính sách này được "mã hóa cứng" vào kernel.  Đó là chính sách
	điều chỉnh tất cả việc phân bổ trang không được kiểm soát bởi
	một trong những phạm vi chính sách cụ thể hơn được thảo luận dưới đây.  Khi nào
	hệ thống đang "thiết lập và chạy", chính sách mặc định của hệ thống sẽ
	sử dụng "phân bổ cục bộ" được mô tả bên dưới.  Tuy nhiên, trong quá trình khởi động
	lên, chính sách mặc định của hệ thống sẽ được đặt thành xen kẽ
	phân bổ trên tất cả các nút có bộ nhớ "đủ", do đó
	không làm quá tải nút khởi động ban đầu với thời gian khởi động
	phân bổ.

Chính sách nhiệm vụ/quy trình
	đây là chính sách tùy chọn, theo từng nhiệm vụ.  Khi được xác định cho một
	nhiệm vụ cụ thể, chính sách này kiểm soát tất cả các phân bổ trang được thực hiện
	bởi hoặc thay mặt cho nhiệm vụ không được kiểm soát bởi
	phạm vi cụ thể. Nếu một tác vụ không xác định chính sách tác vụ thì
	tất cả việc phân bổ trang lẽ ra đã được kiểm soát bởi
	chính sách tác vụ "quay trở lại" Chính sách mặc định của hệ thống.

Chính sách tác vụ áp dụng cho toàn bộ không gian địa chỉ của tác vụ. Như vậy,
	nó có thể kế thừa và thực sự được kế thừa trên cả fork()
	[clone() không có cờ CLONE_VM] và exec*().  Điều này cho phép một nhiệm vụ cha mẹ
	để thiết lập chính sách tác vụ cho một tác vụ con exec()'d từ một
	hình ảnh thực thi không có nhận thức về chính sách bộ nhớ.  Xem
	Phần ZZ0000ZZ,
	bên dưới để biết tổng quan về lệnh gọi hệ thống
	mà một tác vụ có thể sử dụng để thiết lập/thay đổi chính sách tác vụ/quy trình của nó.

Trong tác vụ đa luồng, chính sách tác vụ chỉ áp dụng cho luồng
	[Tác vụ nhân Linux] cài đặt chính sách và mọi luồng
	sau đó được tạo bởi chủ đề đó.  Bất kỳ chủ đề anh chị em hiện có
	tại thời điểm chính sách tác vụ mới được cài đặt, hãy giữ nguyên chính sách hiện tại của chúng
	chính sách.

Chính sách tác vụ chỉ áp dụng cho các trang được phân bổ sau khi chính sách được
	đã cài đặt.  Bất kỳ trang nào đã bị lỗi bởi tác vụ khi tác vụ
	thay đổi chính sách nhiệm vụ của nó vẫn giữ nguyên ở nơi chúng được phân bổ dựa trên
	chính sách tại thời điểm chúng được phân bổ.

.. _vma_policy:

Chính sách VMA
	"VMA" hoặc "Vùng bộ nhớ ảo" đề cập đến một phạm vi nhiệm vụ
	không gian địa chỉ ảo.  Một tác vụ có thể xác định một chính sách cụ thể cho một phạm vi
	không gian địa chỉ ảo của nó.   Xem
	Phần ZZ0000ZZ,
	bên dưới để biết tổng quan về lệnh gọi hệ thống mbind() được sử dụng để đặt VMA
	chính sách.

Chính sách VMA sẽ chi phối việc phân bổ các trang quay lại
	vùng này của không gian địa chỉ.  Bất kỳ khu vực nào của nhiệm vụ
	không gian địa chỉ không có chính sách VMA rõ ràng sẽ bị loại bỏ
	quay trở lại chính sách nhiệm vụ, chính sách này có thể quay trở lại
	Chính sách mặc định của hệ thống.

Chính sách của VMA có một số chi tiết phức tạp:

* Chính sách của VMA áp dụng ONLY cho các trang ẩn danh.  Chúng bao gồm
	  các trang được phân bổ cho các phân đoạn ẩn danh, chẳng hạn như tác vụ
	  ngăn xếp và đống, và bất kỳ vùng nào của không gian địa chỉ
	  mmap() được chỉnh sửa bằng cờ MAP_ANONYMOUS.  Nếu chính sách VMA là
	  được áp dụng cho ánh xạ tệp, nó sẽ bị bỏ qua nếu ánh xạ
	  đã sử dụng cờ MAP_SHARED.  Nếu ánh xạ tập tin sử dụng
	  Cờ MAP_PRIVATE, chính sách VMA sẽ chỉ được áp dụng khi
	  một trang ẩn danh được phân bổ để cố gắng ghi vào
	  ánh xạ-- tức là tại Copy-On-Write.

* Chính sách VMA được chia sẻ giữa tất cả các tác vụ có chung
	  không gian địa chỉ ảo--a.k.a. chủ đề--không phụ thuộc vào thời điểm
	  chính sách đã được cài đặt; và chúng được kế thừa qua
	  cái nĩa().  Tuy nhiên, vì các chính sách của VMA đề cập đến một
	  vùng không gian địa chỉ của tác vụ và bởi vì địa chỉ
	  không gian bị loại bỏ và được tạo lại trên các chính sách exec*(), VMA
	  NOT có thể kế thừa qua exec().  Do đó, chỉ có NUMA mới nhận biết được
	  các ứng dụng có thể sử dụng chính sách VMA.

* Một tác vụ có thể cài đặt chính sách VMA mới trên phạm vi phụ của
	  vùng đã được mmap() trước đó.  Khi điều này xảy ra, Linux sẽ chia tách
	  vùng bộ nhớ ảo hiện có thành 2 hoặc 3 VMA, mỗi VMA có
	  chính sách riêng của mình.

* Theo mặc định, chính sách VMA chỉ áp dụng cho các trang được phân bổ sau
	  chính sách đã được cài đặt.  Bất kỳ trang nào đã bị lỗi trong
	  Phạm vi VMA vẫn giữ nguyên vị trí chúng được phân bổ dựa trên
	  chính sách tại thời điểm chúng được phân bổ.  Tuy nhiên, kể từ khi
	  2.6.16, Linux hỗ trợ di chuyển trang thông qua hệ thống mbind()
	  cuộc gọi, để nội dung trang có thể được di chuyển để phù hợp với một cuộc gọi mới
	  chính sách được cài đặt.

Chính sách chia sẻ
	Về mặt khái niệm, các chính sách chia sẻ áp dụng cho "đối tượng bộ nhớ" được ánh xạ
	được chia sẻ vào không gian địa chỉ riêng biệt của một hoặc nhiều tác vụ.  Một
	ứng dụng cài đặt các chính sách chia sẻ giống như VMA
	các chính sách--sử dụng lệnh gọi hệ thống mbind() chỉ định một phạm vi
	địa chỉ ảo ánh xạ đối tượng được chia sẻ.  Tuy nhiên, không giống như
	Chính sách VMA, có thể được coi là một thuộc tính của
	phạm vi không gian địa chỉ của tác vụ, áp dụng chính sách chung
	trực tiếp tới đối tượng được chia sẻ.  Vì vậy, mọi công việc gắn liền với
	đối tượng chia sẻ chính sách và tất cả các trang được phân bổ cho
	Đối tượng dùng chung, bởi bất kỳ tác vụ nào, sẽ tuân theo chính sách dùng chung.

Kể từ phiên bản 2.6.22, chỉ các phân đoạn bộ nhớ dùng chung được tạo bởi shmget() hoặc
	mmap(MAP_ANONYMOUS|MAP_SHARED), hỗ trợ chính sách chia sẻ.  Khi được chia sẻ
	hỗ trợ chính sách đã được thêm vào Linux, các cấu trúc dữ liệu liên quan đã được
	được thêm vào các phân đoạn shmem Hugetlbfs.  Vào thời điểm đó, Hugetlbfs không
	hỗ trợ phân bổ vào thời điểm có lỗi--hay còn gọi là phân bổ lười biếng--so Hugetlbfs
	các phân đoạn shmem chưa bao giờ được "kết nối" với hỗ trợ chính sách chung.
	Mặc dù các phân đoạn Hugetlbfs hiện hỗ trợ phân bổ lười biếng, nhưng sự hỗ trợ của chúng
	cho chính sách chia sẻ chưa được hoàn thành.

Như đã đề cập ở trên trong phần ZZ0000ZZ,
	phân bổ các trang bộ đệm trang cho các tệp thông thường mmap()ed
	với MAP_SHARED bỏ qua mọi chính sách VMA được cài đặt trên máy ảo
	phạm vi địa chỉ được hỗ trợ bởi ánh xạ tệp được chia sẻ.  Đúng hơn,
	các trang bộ đệm của trang được chia sẻ, bao gồm cả các trang sao lưu riêng tư
	các ánh xạ chưa được viết bởi tác vụ, hãy làm theo
	chính sách tác vụ, nếu có, chính sách mặc định của hệ thống.

Cơ sở hạ tầng chính sách dùng chung hỗ trợ các chính sách khác nhau trên tập hợp con
	phạm vi của đối tượng được chia sẻ.  Tuy nhiên, Linux vẫn chia VMA thành
	nhiệm vụ cài đặt chính sách cho từng phạm vi chính sách riêng biệt.
	Do đó, các tác vụ khác nhau gắn vào một phân đoạn bộ nhớ dùng chung có thể có
	các cấu hình VMA khác nhau ánh xạ tới một đối tượng được chia sẻ.  Cái này
	có thể được nhìn thấy bằng cách kiểm tra /proc/<pid>/numa_maps của việc chia sẻ nhiệm vụ
	vùng bộ nhớ dùng chung, khi một tác vụ đã cài đặt chính sách dùng chung trên
	một hoặc nhiều phạm vi của khu vực.

Các thành phần của chính sách bộ nhớ
-----------------------------

Chính sách bộ nhớ NUMA bao gồm một "chế độ", các cờ chế độ tùy chọn và
một tập hợp các nút tùy chọn.  Chế độ xác định hành vi của
chính sách, các cờ chế độ tùy chọn xác định hành vi của chế độ,
và tập hợp các nút tùy chọn có thể được xem như các đối số cho
hành vi chính sách.

Trong nội bộ, các chính sách bộ nhớ được triển khai bằng một tham chiếu được tính
cấu trúc, chính sách ghi nhớ cấu trúc.  Chi tiết về cấu trúc này sẽ được
được thảo luận trong ngữ cảnh bên dưới, theo yêu cầu để giải thích hành vi.

Chính sách bộ nhớ NUMA hỗ trợ 4 chế độ hoạt động sau:

Chế độ mặc định--MPOL_DEFAULT
	Chế độ này chỉ được sử dụng trong API chính sách bộ nhớ.  Trong nội bộ,
	MPOL_DEFAULT được chuyển đổi sang chính sách bộ nhớ NULL trong tất cả
	phạm vi chính sách.  Bất kỳ chính sách không mặc định hiện có nào sẽ chỉ đơn giản là
	bị xóa khi MPOL_DEFAULT được chỉ định.  Kết quả là,
	MPOL_DEFAULT có nghĩa là "quay lại chính sách cụ thể nhất tiếp theo
	phạm vi."

Ví dụ: NULL hoặc chính sách tác vụ mặc định sẽ quay trở lại
	chính sách mặc định của hệ thống.  Chính sách NULL hoặc vma mặc định sẽ bị loại bỏ
	quay lại chính sách nhiệm vụ.

Khi được chỉ định ở một trong các API chính sách bộ nhớ, chế độ Mặc định
	không sử dụng tập hợp các nút tùy chọn.

Đó là lỗi khi tập hợp các nút được chỉ định cho chính sách này
	không được trống rỗng.

MPOL_BIND
	Chế độ này chỉ định rằng bộ nhớ phải đến từ tập hợp các
	các nút được chỉ định bởi chính sách.  Bộ nhớ sẽ được phân bổ từ
	nút trong tập hợp có đủ bộ nhớ trống
	gần nút nhất nơi việc phân bổ diễn ra.

MPOL_PREFERRED
	Chế độ này chỉ định rằng việc phân bổ phải được thử
	từ nút duy nhất được chỉ định trong chính sách.  Nếu đó
	việc phân bổ không thành công, kernel sẽ tìm kiếm các nút khác theo thứ tự
	tăng khoảng cách từ nút ưa thích dựa trên
	thông tin được cung cấp bởi phần mềm nền tảng.

Trong nội bộ, chính sách Ưu tiên sử dụng một nút duy nhất--
	thành viên ưa thích_node của cấu trúc ghi nhớ.  Khi nội bộ
	cờ chế độ MPOL_F_LOCAL được đặt, nút ưa thích bị bỏ qua
	và chính sách này được hiểu là phân bổ cục bộ.  "Địa phương"
	chính sách phân bổ có thể được xem như một chính sách ưu tiên
	bắt đầu tại nút chứa CPU nơi phân bổ
	diễn ra.

Người dùng có thể chỉ định việc phân bổ cục bộ đó
	luôn được ưu tiên bằng cách chuyển một mặt nạ nút trống với cái này
	chế độ.  Nếu một mặt nạ nút trống được thông qua, chính sách không thể sử dụng
	cờ MPOL_F_STATIC_NODES hoặc MPOL_F_RELATIVE_NODES
	được mô tả dưới đây.

MPOL_INTERLEAVE
	Chế độ này chỉ định việc phân bổ trang được xen kẽ, trên một
	mức độ chi tiết của trang, trên các nút được chỉ định trong chính sách.
	Chế độ này cũng hoạt động hơi khác một chút, dựa trên
	bối cảnh nơi nó được sử dụng:

Để phân bổ các trang ẩn danh và các trang bộ nhớ dùng chung,
	Chế độ xen kẽ lập chỉ mục tập hợp các nút được chỉ định bởi
	chính sách sử dụng offset trang của địa chỉ lỗi vào
	phân đoạn [VMA] chứa địa chỉ theo số lượng
	các nút được chỉ định bởi chính sách.  Sau đó nó cố gắng phân bổ một
	trang, bắt đầu từ nút được chọn, như thể nút đó đã được
	được chỉ định bởi chính sách Ưu tiên hoặc đã được chọn bởi một
	phân bổ địa phương.  Nghĩa là, việc phân bổ sẽ tuân theo
	danh sách vùng nút.

Để phân bổ các trang bộ đệm trang, chỉ mục chế độ xen kẽ
	tập hợp các nút được chỉ định bởi chính sách bằng cách sử dụng bộ đếm nút
	duy trì cho mỗi nhiệm vụ.  Bộ đếm này bao quanh mức thấp nhất
	nút được chỉ định sau khi nó đạt tới nút được chỉ định cao nhất.
	Điều này sẽ có xu hướng trải rộng các trang ra trên các nút
	được quy định bởi chính sách dựa trên thứ tự mà chúng được thực hiện
	được phân bổ, thay vì dựa trên bất kỳ trang nào được chuyển thành một
	dải địa chỉ hoặc tập tin.  Trong quá trình khởi động hệ thống, tạm thời
	chính sách mặc định của hệ thống xen kẽ hoạt động ở chế độ này.

MPOL_PREFERRED_MANY
	Chế độ này chỉ định rằng việc phân bổ nên được ưu tiên
	hài lòng từ nodemask được chỉ định trong chính sách. Nếu có
	áp lực bộ nhớ lên tất cả các nút trong mặt nạ nút, việc phân bổ
	có thể quay trở lại tất cả các nút numa hiện có. Điều này có hiệu quả
	MPOL_PREFERRED cho phép có mặt nạ thay vì một nút duy nhất.

MPOL_WEIGHTED_INTERLEAVE
	Chế độ này hoạt động tương tự như MPOL_INTERLEAVE, ngoại trừ
	Hành vi xen kẽ được thực hiện dựa trên các trọng số được đặt trong
	/sys/kernel/mm/mempolicy/weighted_interleave/

Interleave có trọng số phân bổ các trang trên các nút theo
	trọng lượng.  Ví dụ: nếu các nút [0,1] có trọng số [5,2], 5 trang
	sẽ được phân bổ trên nút0 cho mỗi 2 trang được phân bổ trên nút1.

Chính sách bộ nhớ NUMA hỗ trợ các cờ chế độ tùy chọn sau:

MPOL_F_STATIC_NODES
	Cờ này chỉ định rằng mặt nạ nút được truyền qua
	người dùng sẽ không được ánh xạ lại nếu tác vụ hoặc bộ VMA được phép
	các nút thay đổi sau khi chính sách bộ nhớ được xác định.

Nếu không có cờ này, bất cứ khi nào một chính sách ghi nhớ được phục hồi do một
        thay đổi trong tập hợp các nút được phép, mặt nạ nút ưu tiên (Ưu tiên
        Nhiều), nút ưa thích (Ưu tiên) hoặc nút mặt nạ (Ràng buộc, Xen kẽ) là
        được ánh xạ lại tới tập hợp các nút được phép mới.  Điều này có thể dẫn đến các nút
        đang được sử dụng mà trước đây không được mong muốn.

Với cờ này, nếu các nút do người dùng chỉ định trùng với nút
	các nút được CPUset của tác vụ cho phép thì chính sách bộ nhớ sẽ là
	áp dụng cho giao điểm của họ.  Nếu hai tập hợp nút không
	chồng chéo, chính sách Mặc định sẽ được sử dụng.

Ví dụ, hãy xem xét một tác vụ được gắn vào một CPUset có
	mems 1-3 đặt chính sách Xen kẽ trên cùng một bộ.  Nếu
	mems của cpuset thay đổi thành 3-5, Interleave sẽ diễn ra
	qua các nút 3, 4 và 5. Tuy nhiên, với cờ này, vì chỉ có nút
	3 được cho phép từ mặt nạ nút của người dùng, chỉ "xen kẽ"
	xảy ra trên nút đó.  Nếu không có nút nào từ mặt nạ nút của người dùng
	hiện được cho phép, hành vi Mặc định sẽ được sử dụng.

MPOL_F_STATIC_NODES không thể kết hợp với
	Cờ MPOL_F_RELATIVE_NODES.  Nó cũng không thể được sử dụng để
	Chính sách MPOL_PREFERRED được tạo bằng nodemask trống
	(phân bổ địa phương).

MPOL_F_RELATIVE_NODES
	Cờ này chỉ định rằng mặt nạ nút đã được thông qua
	của người dùng sẽ được ánh xạ tương ứng với tập hợp nhiệm vụ hoặc của VMA
	tập hợp các nút được phép.  Kernel lưu trữ nodemask do người dùng chuyển,
	và nếu các nút được phép thay đổi thì mặt nạ nút ban đầu đó sẽ
	được ánh xạ lại tương ứng với tập hợp các nút được phép mới.

Nếu không có cờ này (và không có MPOL_F_STATIC_NODES), bất cứ lúc nào
	chính sách ghi nhớ được phục hồi do có sự thay đổi trong tập hợp các giá trị được phép
	các nút, nút (Ưu tiên) hoặc nodemask (Liên kết, Xen kẽ) là
	được ánh xạ lại tới tập hợp các nút được phép mới.  Bản remap đó có thể không
	duy trì tính chất tương đối của mặt nạ nút được chuyển qua của người dùng đối với nó
	tập hợp các nút được phép khi khởi động lại liên tiếp: một mặt nạ nút của
	1,3,5 có thể được ánh xạ lại thành 7-9 và sau đó thành 1-3 nếu tập hợp
	các nút được phép được khôi phục về trạng thái ban đầu.

Với cờ này, việc ánh xạ lại được thực hiện sao cho số nút từ
	mặt nạ nút được thông qua của người dùng có liên quan đến tập hợp được phép
	nút.  Nói cách khác, nếu các nút 0, 2 và 4 được đặt trong
	nodemask, chính sách sẽ được thực hiện trong lần đầu tiên (và trong
	Trường hợp liên kết hoặc xen kẽ, nút thứ ba và thứ năm) trong tập hợp
	các nút được phép.  Mặt nạ nút được người dùng chuyển qua đại diện cho các nút
	liên quan đến nhiệm vụ hoặc tập hợp các nút được phép của VMA.

Nếu mặt nạ nút của người dùng bao gồm các nút nằm ngoài phạm vi
	của tập hợp các nút được phép mới (ví dụ: nút 5 được đặt trong
	nodemask của người dùng khi tập hợp các nút được phép chỉ là 0-3),
	sau đó bản remap sẽ bao quanh phần đầu của nodemask và,
	nếu chưa được đặt, hãy đặt nút trong mặt nạ nút ghi nhớ.

Ví dụ, hãy xem xét một tác vụ được gắn vào một CPUset có
	mems 2-5 đặt chính sách Xen kẽ trên cùng một bộ với
	MPOL_F_RELATIVE_NODES.  Nếu mems của cpuset thay đổi thành 3-7 thì
	sự xen kẽ bây giờ xảy ra trên các nút 3,5-7.  Nếu mems của cpuset
	sau đó thay đổi thành 0,2-3,5, khi đó sự xen kẽ xảy ra trên các nút
	0,2-3,5.

Nhờ ánh xạ lại nhất quán, các ứng dụng đang chuẩn bị
	nodemasks để chỉ định chính sách bộ nhớ bằng cờ này
	bỏ qua vị trí bộ nhớ áp đặt cpuset thực tế hiện tại của họ
	và chuẩn bị mặt nạ nút như thể chúng luôn nằm trên
	nút bộ nhớ 0 đến N-1, trong đó N là số nút bộ nhớ
	chính sách nhằm quản lý.  Hãy để kernel sau đó ánh xạ lại vào
	tập hợp các nút bộ nhớ được CPUset của tác vụ cho phép, vì điều đó có thể
	thay đổi theo thời gian.

MPOL_F_RELATIVE_NODES không thể kết hợp với
	Cờ MPOL_F_STATIC_NODES.  Nó cũng không thể được sử dụng để
	Chính sách MPOL_PREFERRED được tạo bằng nodemask trống
	(phân bổ địa phương).

Đếm tham chiếu chính sách bộ nhớ
================================

Để giải quyết các cuộc đua sử dụng/tự do, struct mempolicy chứa tham chiếu nguyên tử
trường đếm.  Giao diện nội bộ, mức tăng mpol_get()/mpol_put() và
giảm số lượng tham chiếu này tương ứng.  mpol_put() sẽ chỉ miễn phí
cấu trúc trở lại bộ nhớ đệm kmempolicy khi đếm tham chiếu
đi đến số không.

Khi một chính sách bộ nhớ mới được cấp phát, số tham chiếu của nó sẽ được khởi tạo
thành '1', thể hiện tham chiếu được giữ bởi tác vụ đang cài đặt
chính sách mới.  Khi một con trỏ tới cấu trúc chính sách bộ nhớ được lưu trữ trong một cấu trúc khác
cấu trúc, một tham chiếu khác sẽ được thêm vào vì tham chiếu của tác vụ sẽ bị loại bỏ
khi hoàn tất cài đặt chính sách.

Trong thời gian "sử dụng" chính sách này, chúng tôi cố gắng giảm thiểu các hoạt động nguyên tử
về số lượng tham chiếu, vì điều này có thể dẫn đến các dòng bộ đệm bị nảy giữa các CPU
và các nút NUMA.  "Cách sử dụng" ở đây có nghĩa là một trong những từ sau:

1) truy vấn chính sách, bằng chính tác vụ [sử dụng get_mempolicy()
   API được thảo luận bên dưới] hoặc bởi một tác vụ khác bằng cách sử dụng /proc/<pid>/numa_maps
   giao diện.

2) kiểm tra chính sách để xác định chế độ chính sách và nút liên quan
   hoặc danh sách nút, nếu có, để phân bổ trang.  Đây được coi là “nóng”
   con đường".  Lưu ý rằng đối với MPOL_BIND, "việc sử dụng" kéo dài trên toàn bộ
   quá trình phân bổ, có thể ngủ trong quá trình cải tạo trang, bởi vì
   Theo tham chiếu, mặt nạ nút chính sách BIND được sử dụng để lọc các nút không đủ điều kiện.

Chúng ta có thể tránh tham khảo thêm trong các cách sử dụng được liệt kê ở trên như
sau:

1) chúng tôi không bao giờ cần lấy/giải phóng chính sách mặc định của hệ thống vì điều này không bao giờ
   được thay đổi hoặc giải phóng khi hệ thống đã hoạt động.

2) để truy vấn chính sách, chúng tôi không cần tham khảo thêm về
   chính sách nhiệm vụ của nhiệm vụ mục tiêu cũng như chính sách vma vì chúng tôi luôn có được
   mmap_lock của nhiệm vụ mm để đọc trong khi truy vấn.  set_mempolicy() và
   API mbind() [xem bên dưới] luôn lấy mmap_lock để ghi khi
   cài đặt hoặc thay thế các chính sách tác vụ hoặc vma.  Vì vậy, không có khả năng
   của một tác vụ hoặc luồng giải phóng một chính sách trong khi một tác vụ hoặc luồng khác đang được giải phóng
   truy vấn nó.

3) Việc sử dụng nhiệm vụ hoặc chính sách vma phân bổ trang xảy ra trong đường dẫn lỗi trong đó
   chúng tôi giữ chúng mmap_lock để đọc.  Một lần nữa, vì thay thế tác vụ hoặc vma
   chính sách yêu cầu giữ mmap_lock để ghi, chính sách này không thể
   được giải phóng khỏi chúng tôi trong khi chúng tôi đang sử dụng nó để phân bổ trang.

4) Chính sách chung cần được xem xét đặc biệt.  Một nhiệm vụ có thể thay thế một
   chính sách bộ nhớ dùng chung trong khi một tác vụ khác, với mmap_lock riêng biệt, được thực hiện
   truy vấn hoặc phân bổ một trang dựa trên chính sách.  Để giải quyết vấn đề này
   cuộc đua tiềm năng, cơ sở hạ tầng chính sách dùng chung bổ sung thêm một tài liệu tham khảo
   vào chính sách được chia sẻ trong quá trình tra cứu trong khi giữ khóa xoay trên thiết bị được chia sẻ
   cơ cấu quản lý chính sách  Điều này đòi hỏi chúng ta phải bỏ thêm phần này
   tham chiếu khi chúng tôi "sử dụng" chính sách xong.  Chúng ta phải bỏ
   tham chiếu bổ sung về các chính sách được chia sẻ trong cùng đường dẫn truy vấn/phân bổ
   được sử dụng cho các chính sách không chia sẻ.  Vì lý do này, các chính sách chia sẻ được đánh dấu
   như vậy, và tham chiếu bổ sung bị loại bỏ "có điều kiện"--tức là, chỉ
   cho các chính sách được chia sẻ.

Vì việc đếm tham chiếu bổ sung này và vì chúng ta phải tra cứu
   các chính sách được chia sẻ trong cấu trúc cây theo spinlock, các chính sách được chia sẻ
   đắt hơn khi sử dụng trong đường dẫn phân bổ trang.  Điều này đặc biệt
   đúng cho các chính sách chia sẻ trên các vùng bộ nhớ dùng chung được chia sẻ bởi các tác vụ đang chạy
   trên các nút NUMA khác nhau.  Chi phí bổ sung này có thể tránh được bằng cách luôn luôn
   quay lại chính sách mặc định của tác vụ hoặc hệ thống cho các vùng bộ nhớ dùng chung,
   hoặc bằng cách cài đặt trước toàn bộ vùng bộ nhớ dùng chung vào bộ nhớ và khóa
   nó xuống.  Tuy nhiên, điều này có thể không phù hợp với tất cả các ứng dụng.

.. _memory_policy_apis:

API chính sách bộ nhớ
==================

Linux hỗ trợ 4 lệnh gọi hệ thống để kiểm soát chính sách bộ nhớ.  Những chiếc APIS này
luôn chỉ ảnh hưởng đến tác vụ gọi, không gian địa chỉ của tác vụ gọi hoặc
một số đối tượng dùng chung được ánh xạ vào không gian địa chỉ của tác vụ gọi.

.. note::
   the headers that define these APIs and the parameter data types for
   user space applications reside in a package that is not part of the
   Linux kernel.  The kernel system call interfaces, with the 'sys\_'
   prefix, are defined in <linux/syscalls.h>; the mode and flag
   definitions are defined in <linux/mempolicy.h>.

Đặt chính sách bộ nhớ [Tác vụ]::

set_mempolicy dài (chế độ int, const không dấu dài *nmask,
					maxnode dài không dấu);

Đặt "chính sách bộ nhớ tác vụ/quy trình" của tác vụ gọi thành chế độ
được chỉ định bởi đối số 'mode' và tập hợp các nút được xác định bởi
'mặt nạ'.  'nmask' trỏ tới mặt nạ bit của các id nút chứa ít nhất
Id 'maxnode'.  Cờ chế độ tùy chọn có thể được thông qua bằng cách kết hợp
đối số 'chế độ' với cờ (ví dụ: MPOL_INTERLEAVE |
MPOL_F_STATIC_NODES).

Xem trang man set_mempolicy(2) để biết thêm chi tiết


Nhận Chính sách bộ nhớ [Nhiệm vụ] hoặc Thông tin liên quan::

get_mempolicy dài (int *chế độ,
			   const dài không dấu *nmask, nút tối đa dài không dấu,
			   void *addr, cờ int);

Truy vấn "chính sách bộ nhớ tác vụ/quy trình" của tác vụ gọi hoặc
chính sách hoặc vị trí của một địa chỉ ảo được chỉ định, tùy thuộc vào
đối số 'cờ'.

Xem trang man get_mempolicy(2) để biết thêm chi tiết


Cài đặt VMA/Chính sách chia sẻ cho nhiều không gian địa chỉ của tác vụ::

mbind dài (void *bắt đầu, len dài không dấu, chế độ int,
		   const dài không dấu *nmask, nút tối đa dài không dấu,
		   cờ không dấu);

mbind() cài đặt chính sách được chỉ định bởi (mode, nmask, maxnodes) dưới dạng
Chính sách VMA cho phạm vi không gian địa chỉ của tác vụ gọi được chỉ định
bởi các đối số 'bắt đầu' và 'len'.  Các hành động bổ sung có thể được
được yêu cầu thông qua đối số 'cờ'.

Xem trang man mbind(2) để biết thêm chi tiết.

Đặt nút chính cho Phạm vi địa chỉ của tác vụ Spacec::

sys_set_mempolicy_home_node dài (bắt đầu dài không dấu, len dài không dấu,
					 home_node dài không dấu,
					 cờ dài không dấu);

sys_set_mempolicy_home_node đặt nút trang chủ cho chính sách VMA có trong
phạm vi địa chỉ của nhiệm vụ. Cuộc gọi hệ thống chỉ cập nhật nút home cho nút hiện có
phạm vi ghi nhớ. Các dải địa chỉ khác bị bỏ qua. Nút nhà là nút NUMA
gần nhất với việc phân bổ trang sẽ đến từ đâu. Chỉ định ghi đè nút home
chính sách phân bổ mặc định để phân bổ bộ nhớ gần nút cục bộ cho một
thực thi CPU.


Giao diện dòng lệnh chính sách bộ nhớ
====================================

Mặc dù không hoàn toàn là một phần của việc triển khai chính sách bộ nhớ của Linux,
một công cụ dòng lệnh, numactl(8), tồn tại cho phép một người:

+ đặt chính sách tác vụ cho một chương trình được chỉ định thông qua set_mempolicy(2), fork(2) và
  thực thi(2)

+ đặt chính sách chia sẻ cho phân đoạn bộ nhớ dùng chung thông qua mbind(2)

Công cụ numactl(8) được đóng gói cùng với phiên bản thời gian chạy của thư viện
chứa các trình bao bọc cuộc gọi hệ thống chính sách bộ nhớ.  Một số bản phân phối
đóng gói các tiêu đề và thư viện thời gian biên dịch trong một quá trình phát triển riêng biệt
gói.

.. _mem_pol_and_cpusets:

Chính sách bộ nhớ và bộ CPU
===========================

Chính sách bộ nhớ hoạt động trong bộ CPU như được mô tả ở trên.  Đối với chính sách bộ nhớ
yêu cầu một nút hoặc tập hợp các nút, các nút bị giới hạn trong tập hợp
các nút có bộ nhớ được cho phép bởi các ràng buộc cpuset.  Nếu mặt nạ nút
được chỉ định cho chính sách chứa các nút không được CPUset cho phép và
MPOL_F_RELATIVE_NODES không được sử dụng, giao điểm của tập hợp các nút
được chỉ định cho chính sách và tập hợp các nút có bộ nhớ được sử dụng.  Nếu
kết quả là tập hợp trống, chính sách được coi là không hợp lệ và không thể
đã cài đặt.  Nếu MPOL_F_RELATIVE_NODES được sử dụng, các nút của chính sách sẽ được ánh xạ
lên và xếp vào tập hợp các nút được phép của nhiệm vụ như đã mô tả trước đây.

Sự tương tác giữa các chính sách bộ nhớ và bộ vi xử lý có thể gặp vấn đề khi các tác vụ
trong hai CPUset chia sẻ quyền truy cập vào một vùng bộ nhớ, chẳng hạn như các phân đoạn bộ nhớ dùng chung
được tạo bởi shmget() của mmap() với cờ MAP_ANONYMOUS và MAP_SHARED, và
bất kỳ tác vụ nào đều cài đặt chính sách chia sẻ trên khu vực, chỉ các nút có
bộ nhớ được phép trong cả hai bộ CPU có thể được sử dụng trong chính sách.  Có được
thông tin này yêu cầu "bước ra ngoài" các API chính sách bộ nhớ để sử dụng
thông tin về cpuset và yêu cầu người ta biết tác vụ khác của cpuset có thể xảy ra như thế nào
được gắn vào khu vực chia sẻ.  Hơn nữa, nếu CPUset được phép
bộ nhớ rời rạc, phân bổ "cục bộ" là chính sách hợp lệ duy nhất.
