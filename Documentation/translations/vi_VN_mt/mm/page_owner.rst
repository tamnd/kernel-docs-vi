.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/page_owner.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================
chủ sở hữu trang: Theo dõi người đã phân bổ từng trang
======================================================

Giới thiệu
============

chủ sở hữu trang dùng để theo dõi ai đã phân bổ từng trang.
Nó có thể được sử dụng để gỡ lỗi rò rỉ bộ nhớ hoặc tìm kiếm bộ nhớ bị chiếm dụng.
Khi phân bổ xảy ra, thông tin về phân bổ như ngăn xếp cuộc gọi
và thứ tự các trang được lưu vào bộ nhớ nhất định cho mỗi trang.
Khi cần biết về trạng thái của tất cả các trang, chúng tôi có thể lấy và phân tích
thông tin này.

Mặc dù chúng tôi đã có tracepoint để theo dõi việc phân bổ/miễn phí trang,
việc sử dụng nó để phân tích ai phân bổ từng trang khá phức tạp. Chúng tôi cần
để phóng to bộ đệm theo dõi nhằm ngăn chặn sự chồng chéo cho đến khi không gian người dùng
chương trình đã ra mắt. Và chương trình được tung ra liên tục để lại dấu vết
đệm để phân tích sau này và nó sẽ thay đổi hành vi của hệ thống với nhiều
khả năng thay vì chỉ giữ nó trong bộ nhớ, rất tệ cho việc gỡ lỗi.

chủ sở hữu trang cũng có thể được sử dụng cho nhiều mục đích khác nhau. Ví dụ, chính xác
số liệu thống kê phân mảnh có thể thu được thông qua thông tin cờ gfp của
mỗi trang. Nó đã được triển khai và kích hoạt nếu chủ sở hữu trang
đã bật. Các cách sử dụng khác đều được chào đón nhiều hơn.

Nó cũng có thể được sử dụng để hiển thị tất cả các ngăn xếp và số lượng hiện tại của chúng
các trang cơ sở được phân bổ, cung cấp cho chúng tôi cái nhìn tổng quan nhanh về vị trí bộ nhớ
sẽ diễn ra mà không cần phải sàng lọc qua tất cả các trang và khớp với
phân bổ và hoạt động tự do. Cũng có thể chỉ hiển thị một số
mã định danh của tất cả các ngăn xếp (không có dấu vết ngăn xếp) và số lượng của chúng
các trang cơ sở được phân bổ (đọc và phân tích nhanh hơn, ví dụ như để theo dõi)
có thể được khớp với các ngăn xếp sau này (show_handles và show_stacks_handles).

chủ sở hữu trang bị tắt theo mặc định. Vì vậy, nếu bạn muốn sử dụng nó, bạn cần
để thêm "page_owner=on" vào dòng lệnh khởi động của bạn. Nếu kernel được xây dựng
với chủ sở hữu trang và chủ sở hữu trang bị tắt trong thời gian chạy do không bật
tùy chọn khởi động, chi phí thời gian chạy là không đáng kể. Nếu bị vô hiệu hóa trong thời gian chạy, nó
không yêu cầu bộ nhớ để lưu trữ thông tin chủ sở hữu, do đó không có thời gian chạy
chi phí bộ nhớ. Và chủ sở hữu trang chỉ chèn hai nhánh không chắc chắn vào
đường dẫn nóng của bộ cấp phát trang và nếu không được bật thì việc phân bổ sẽ hoàn tất
giống như kernel không có chủ sở hữu trang. Hai nhánh không chắc chắn này sẽ
không ảnh hưởng đến hiệu suất phân bổ, đặc biệt nếu các phím tĩnh nhảy
chức năng vá nhãn có sẵn. Sau đây là mã của kernel
thay đổi kích thước do cơ sở này.

Mặc dù việc kích hoạt chủ sở hữu trang sẽ tăng kích thước hạt nhân lên vài kilobyte,
hầu hết mã này là bộ cấp phát trang bên ngoài và đường dẫn nóng của nó. tòa nhà
kernel với chủ trang và bật nó lên nếu cần thì tuyệt vời
tùy chọn để gỡ lỗi vấn đề bộ nhớ kernel.

Có một thông báo là do chi tiết thực hiện. chủ sở hữu trang
lưu trữ thông tin vào bộ nhớ từ phần mở rộng trang cấu trúc. Ký ức này
được khởi tạo muộn hơn một thời gian so với thời điểm bộ cấp phát trang đó bắt đầu thưa thớt
hệ thống bộ nhớ, do đó, cho đến khi khởi tạo, nhiều trang có thể được cấp phát và
họ sẽ không có thông tin về chủ sở hữu. Để khắc phục, những việc này được phân bổ sớm
các trang được điều tra và đánh dấu là được phân bổ trong giai đoạn khởi tạo.
Mặc dù điều đó không có nghĩa là họ có thông tin đúng về chủ sở hữu,
ít nhất chúng ta có thể biết trang đó có được phân bổ hay không,
chính xác hơn. Trên bộ nhớ 2GB x86-64 VM box, 13343 trang được phân bổ sớm
bị bắt và đánh dấu, mặc dù chúng chủ yếu được phân bổ từ struct
tính năng mở rộng trang. Dù sao thì sau đó cũng không còn trang nào nữa
trạng thái không theo dõi.

Cách sử dụng
============

1) Xây dựng trình trợ giúp không gian người dùng::

công cụ cd/mm
	tạo page_owner_sort

2) Kích hoạt chủ sở hữu trang: thêm "page_owner=on" vào cmdline khởi động.

3) Thực hiện công việc mà bạn muốn gỡ lỗi.

4) Phân tích thông tin từ chủ trang::

cat /sys/kernel/debug/page_owner_stacks/show_stacks > stacks.txt
	mèo stacks.txt
	 post_alloc_hook+0x177/0x1a0
	 get_page_from_freelist+0xd01/0xd80
	 __alloc_pages+0x39e/0x7e0
	 phân bổ_slab+0xbc/0x3f0
	 ___slab_alloc+0x528/0x8a0
	 kmem_cache_alloc+0x224/0x3b0
	 sk_prot_alloc+0x58/0x1a0
	 sk_alloc+0x32/0x4f0
	 inet_create+0x427/0xb50
	 __sock_create+0x2e4/0x650
	 inet_ctl_sock_create+0x30/0x180
	 igmp_net_init+0xc1/0x130
	 ops_init+0x167/0x410
	 setup_net+0x304/0xa60
	 copy_net_ns+0x29b/0x4a0
	 create_new_namespaces+0x4a1/0x820
	nr_base_pages: 16
	...
	...
echo 7000 > /sys/kernel/debug/page_owner_stacks/count_threshold
	cat /sys/kernel/debug/page_owner_stacks/show_stacks> stacks_7000.txt
	ngăn xếp mèo_7000.txt
	 post_alloc_hook+0x177/0x1a0
	 get_page_from_freelist+0xd01/0xd80
	 __alloc_pages+0x39e/0x7e0
	 alloc_pages_mpol+0x22e/0x490
	 folio_alloc+0xd5/0x110
	 filemap_alloc_folio+0x78/0x230
	 page_cache_ra_order+0x287/0x6f0
	 filemap_get_pages+0x517/0x1160
	 filemap_read+0x304/0x9f0
	 xfs_file_buffered_read+0xe6/0x1d0 [xfs]
	 xfs_file_read_iter+0x1f0/0x380 [xfs]
	 __kernel_read+0x3b9/0x730
	 kernel_read_file+0x309/0x4d0
	 __do_sys_finit_module+0x381/0x730
	 do_syscall_64+0x8d/0x150
	 entry_SYSCALL_64_after_hwframe+0x62/0x6a
	nr_base_pages: 20824
	...

cat /sys/kernel/debug/page_owner_stacks/show_handles > Handles_7000.txt
	tay cầm mèo_7000.txt
	tay cầm: 42
	nr_base_pages: 20824
	...

cat /sys/kernel/debug/page_owner_stacks/show_stacks_handles > stacks_handles.txt
	mèo stacks_handles.txt
	 post_alloc_hook+0x177/0x1a0
	 get_page_from_freelist+0xd01/0xd80
	 __alloc_pages+0x39e/0x7e0
	 alloc_pages_mpol+0x22e/0x490
	 folio_alloc+0xd5/0x110
	 filemap_alloc_folio+0x78/0x230
	 page_cache_ra_order+0x287/0x6f0
	 filemap_get_pages+0x517/0x1160
	 filemap_read+0x304/0x9f0
	 xfs_file_buffered_read+0xe6/0x1d0 [xfs]
	 xfs_file_read_iter+0x1f0/0x380 [xfs]
	 __kernel_read+0x3b9/0x730
	 kernel_read_file+0x309/0x4d0
	 __do_sys_finit_module+0x381/0x730
	 do_syscall_64+0x8d/0x150
	 entry_SYSCALL_64_after_hwframe+0x62/0x6a
	tay cầm: 42
	...

cat /sys/kernel/debug/page_owner > page_owner_full.txt
	./page_owner_sort page_owner_full.txt được sắp xếp_page_owner.txt

Đầu ra chung của ZZ0000ZZ như sau::

Trang được phân bổ theo thứ tự XXX, ...
	PFN XXX ...
	// ngăn xếp chi tiết

Trang được phân bổ theo thứ tự XXX, ...
	PFN XXX ...
	// ngăn xếp chi tiết
    Theo mặc định, nó sẽ thực hiện kết xuất pfn đầy đủ, để bắt đầu với một pfn nhất định,
    page_owner hỗ trợ fseek.

FILE *fp = fopen("/sys/kernel/debug/page_owner", "r");
    fseek(fp, pfn_start, SEEK_SET);

Công cụ ZZ0000ZZ bỏ qua các hàng ZZ0001ZZ, đặt các hàng còn lại
   trong buf, sử dụng regrec để trích xuất giá trị thứ tự trang, đếm số lần
   và các trang của buf, rồi cuối cùng sắp xếp chúng theo (các) tham số.

Xem kết quả về người phân bổ từng trang
   trong ZZ0000ZZ. Đầu ra chung::

XXX lần, XXX trang:
	Trang được phân bổ theo thứ tự XXX, ...
	// ngăn xếp chi tiết

Theo mặc định, ZZ0000ZZ được sắp xếp theo thời gian buf.
   Nếu bạn muốn sắp xếp theo số trang của buf, hãy sử dụng tham số ZZ0001ZZ.
   Các thông số chi tiết là:

chức năng cơ bản::

Sắp xếp:
		-a Sắp xếp theo thời gian cấp phát bộ nhớ.
		-m Sắp xếp theo tổng bộ nhớ.
		-p Sắp xếp theo pid.
		-P Sắp xếp theo tgid.
		-n Sắp xếp theo tên lệnh tác vụ.
		-r Sắp xếp theo thời gian giải phóng bộ nhớ.
		-s Sắp xếp theo dấu vết ngăn xếp.
		-t Sắp xếp theo thời gian (mặc định).
		--sort <order> Chỉ định thứ tự sắp xếp.  Cú pháp sắp xếp là [+ZZ0001ZZ-]key[,...]].
				Chọn một khóa từ phần ZZ0000ZZ. Dấu "+" là
				tùy chọn vì hướng mặc định đang tăng dần theo số hoặc từ điển
				đặt hàng. Được phép sử dụng hỗn hợp các dạng khóa viết tắt và dạng đầy đủ.

Ví dụ:
				./page_owner_sort <input> <output> --sort=n,+pid,-tgid
				./page_owner_sort <input> <output> --sort=at

chức năng bổ sung::

Chọn lọc:
		--cull <quy tắc>
				Chỉ định quy tắc loại bỏ. Cú pháp loại bỏ là key[,key[,...]].Chọn một
				phím nhiều chữ cái từ phần ZZ0000ZZ.

<rules> là một đối số duy nhất ở dạng danh sách được phân tách bằng dấu phẩy,
		cung cấp một cách để chỉ định các quy tắc loại bỏ riêng lẻ.  Được công nhận
		từ khóa được mô tả trong phần ZZ0000ZZ bên dưới.
		<quy tắc> có thể được chỉ định bởi chuỗi các khóa k1,k2, ..., như được mô tả trong
		phần STANDARD SORT KEYS bên dưới. Sử dụng hỗn hợp các từ viết tắt và
		hình thức hoàn chỉnh của các phím được cho phép.

Ví dụ:
				./page_owner_sort <input> <output> --cull=stacktrace
				./page_owner_sort <input> <output> --cull=st,pid,name
				./page_owner_sort <input> <output> --cull=n,f

Bộ lọc:
		-f Lọc thông tin của các khối có bộ nhớ đã được giải phóng.

chọn:
		--pid <pidlist> Chọn theo pid. Việc này chọn các khối có ID tiến trình
					số xuất hiện trong <pidlist>.
		--tgid <tgidlist> Chọn theo tgid. Điều này chọn các khối có chủ đề
					số ID nhóm xuất hiện trong <tgidlist>.
		--name <cmdlist> Chọn theo tên lệnh tác vụ. Việc này chọn các khối có
					tên lệnh tác vụ xuất hiện trong <cmdlist>.

<pidlist>, <tgidlist>, <cmdlist> là các đối số đơn ở dạng danh sách được phân tách bằng dấu phẩy,
		cung cấp một cách để chỉ định các quy tắc lựa chọn riêng lẻ.


Ví dụ:
				./page_owner_sort <input> <output> --pid=1
				./page_owner_sort <input> <output> --tgid=1,2,3
				./page_owner_sort <input> <output> --name name1,name2

STANDARD FORMAT SPECIFIERS
==========================
::

Đối với tùy chọn --sort:

KEY LONG DESCRIPTION
	ID tiến trình p pid
	ID nhóm chủ đề tg tgid
	n tên nhiệm vụ tên lệnh
	dấu vết ngăn xếp st stacktrace của việc phân bổ trang
	T txt toàn văn của khối
	ft free_ts dấu thời gian của trang khi nó được phát hành
	tại dấu thời gian alloc_ts của trang khi nó được phân bổ
	bộ cấp phát ator bộ cấp phát bộ nhớ cho các trang

Đối với tùy chọn --cull:

KEY LONG DESCRIPTION
	ID tiến trình p pid
	ID nhóm chủ đề tg tgid
	n tên nhiệm vụ tên lệnh
	f miễn phí dù trang đã được phát hành hay chưa
	dấu vết ngăn xếp st stacktrace của việc phân bổ trang
	bộ cấp phát ator bộ cấp phát bộ nhớ cho các trang
