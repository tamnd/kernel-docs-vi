.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/sysctl/vm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Tài liệu cho /proc/sys/vm/
===============================

phiên bản hạt nhân 2.6.29

Bản quyền (c) 1998, 1999, Rik van Riel <riel@nl.linux.org>

Bản quyền (c) 2008 Peter W. Morreale <pmorreale@novell.com>

Để biết thông tin chung và giới thiệu pháp lý, vui lòng xem trong index.rst.

------------------------------------------------------------------------------

Tệp này chứa tài liệu cho các tệp sysctl trong
/proc/sys/vm và hợp lệ cho nhân Linux phiên bản 2.6.29.

Các tập tin trong thư mục này có thể được sử dụng để điều chỉnh hoạt động
của hệ thống con bộ nhớ ảo (VM) của nhân Linux và
việc ghi dữ liệu bẩn vào đĩa.

Các giá trị mặc định và quy trình khởi tạo cho hầu hết các giá trị này
các tập tin có thể được tìm thấy trong mm/swap.c.

Hiện tại, các tệp này nằm trong /proc/sys/vm:

- admin_reserve_kbytes
- bộ nhớ nhỏ gọn
- tính nén_chủ động
- compact_unevtable_allowed
- chế độ chống phân mảnh
- dirty_background_bytes
- dirty_background_ratio
- bẩn_byte
- dirty_expire_centisecs
- tỷ lệ bẩn
- dirtytime_expire_seconds
- dirty_writeback_centisecs
- drop_caches
- kích hoạt_soft_offline
- extfrag_threshold
- highmem_is_dirtyable
- Hugetlb_shm_group
- di sản_va_layout
- lowmem_reserve_ratio
- max_map_count
- mem_profiling (chỉ khi CONFIG_MEM_ALLOC_PROFILING=y)
- bộ nhớ_failure_early_kill
- bộ nhớ_failure_recovery
- min_free_kbyte
- min_slab_ratio
- min_unmapped_ratio
- mmap_min_addr
- mmap_rnd_bits
- mmap_rnd_compat_bits
- movable_gigantic_pages
- nr_hugepages
- nr_hugepages_mempolicy
- nr_overcommit_hugepages
- nr_trim_pages (chỉ khi CONFIG_MMU=n)
- numa_zonelist_order
- oom_dump_tasks
- oom_kill_allocate_task
- vượt quá_kbyte
- vượt mức_memory
- vượt quá_ratio
- cụm trang
- page_lock_unfairness
- hoảng_on_oom
- percpu_pagelist_high_section
- stat_interval
- stat_refresh
- số_stat
- sự tráo đổi
- không có đặc quyền_userfaultfd
- user_reserve_kbyte
- vfs_cache_áp lực
- vfs_cache_ Pressure_denom
- hình mờ_boost_factor
- hình mờ_scale_factor
- vùng_reclaim_mode


admin_reserve_kbytes
====================

Dung lượng bộ nhớ trống trong hệ thống cần được dành riêng cho người dùng
với khả năng cap_sys_admin.

admin_reserve_kbytes mặc định là tối thiểu (3% trang miễn phí, 8MB)

Điều đó sẽ cung cấp đủ để quản trị viên đăng nhập và hủy một tiến trình,
nếu cần, ở chế độ 'đoán' mặc định.

Các hệ thống chạy dưới mức cam kết quá mức 'không bao giờ' sẽ tăng mức này vào tài khoản
để biết Kích thước bộ nhớ ảo đầy đủ của các chương trình được sử dụng để khôi phục. Nếu không,
root có thể không đăng nhập được để khôi phục hệ thống.

Làm thế nào để bạn tính toán một khoản dự trữ hữu ích tối thiểu?

sshd hoặc login + bash (hoặc một số shell khác) + top (hoặc ps, kill, v.v.)

Để 'đoán' quá mức, chúng tôi có thể tính tổng các kích thước tập hợp thường trú (RSS).
Trên x86_64 dung lượng này là khoảng 8 MB.

Để xác nhận quá mức 'không bao giờ', chúng tôi có thể tận dụng tối đa kích thước ảo của chúng (VSZ)
và cộng tổng RSS của họ.
Trên x86_64 dung lượng này là khoảng 128MB.

Thay đổi này có hiệu lực bất cứ khi nào ứng dụng yêu cầu bộ nhớ.


bộ nhớ nhỏ gọn
==============

Chỉ khả dụng khi cài đặt CONFIG_COMPACTION. Khi 1 được ghi vào tập tin,
tất cả các vùng được nén sao cho bộ nhớ trống có sẵn trong các vùng liền kề
khối nếu có thể. Điều này có thể quan trọng, ví dụ như trong việc phân bổ
các trang lớn mặc dù các tiến trình cũng sẽ trực tiếp nén bộ nhớ theo yêu cầu.

tính nén_chủ động
========================

Điều chỉnh này nhận giá trị trong phạm vi [0, 100] với giá trị mặc định là
20. Điều chỉnh này xác định mức độ nén chặt được thực hiện trong
nền. Việc ghi giá trị khác 0 vào điều chỉnh này sẽ ngay lập tức
kích hoạt quá trình nén chủ động. Đặt nó thành 0 sẽ tắt tính năng nén chủ động.

Lưu ý rằng việc nén có tác động không hề nhỏ trên toàn hệ thống vì các trang
thuộc các quy trình khác nhau được di chuyển xung quanh, điều này cũng có thể dẫn đến
đến độ trễ tăng đột biến trong các ứng dụng không ngờ tới. Hạt nhân sử dụng
các phương pháp phỏng đoán khác nhau để tránh lãng phí chu trình CPU nếu phát hiện ra điều đó
việc chủ động đầm nén không có hiệu quả.

Việc đặt giá trị trên 80 sẽ, ngoài việc hạ thấp mức chấp nhận được
phân mảnh, làm cho mã nén nhạy cảm hơn với sự gia tăng
phân mảnh, tức là quá trình nén sẽ kích hoạt thường xuyên hơn nhưng giảm
phân mảnh với số lượng nhỏ hơn.
Điều này làm cho mức độ phân mảnh ổn định hơn theo thời gian.

Hãy cẩn thận khi đặt nó ở các giá trị cực đoan như 100, vì điều đó có thể
gây ra hoạt động nén nền quá mức.

nhỏ gọn_unevtable_allowed
===========================

Chỉ khả dụng khi cài đặt CONFIG_COMPACTION. Khi được đặt thành 1, độ nén được
được phép kiểm tra lru (trang bị khóa) không thể tránh khỏi để thu gọn các trang.
Điều này nên được sử dụng trên các hệ thống mà việc ngừng hoạt động do lỗi trang nhỏ là một
giao dịch có thể chấp nhận được đối với bộ nhớ trống liền kề lớn.  Đặt thành 0 để ngăn chặn
nén từ các trang di chuyển không thể tránh khỏi.  Giá trị mặc định là 1.
Trên CONFIG_PREEMPT_RT, giá trị mặc định là 0 để tránh lỗi trang, do
nén, điều này sẽ ngăn tác vụ hoạt động cho đến khi xảy ra lỗi
được giải quyết.

chế độ chống phân mảnh
===========

Khi được đặt thành 1, bộ cấp phát trang sẽ cố gắng hơn để tránh bị phân mảnh
và duy trì khả năng tạo ra các trang lớn/trang có thứ tự cao hơn.

Nên kích hoạt tính năng này ngay sau khi khởi động, vì phân mảnh,
một khi nó đã xảy ra, nó có thể tồn tại lâu dài hoặc thậm chí vĩnh viễn.

dirty_background_bytes
======================

Chứa lượng bộ nhớ bẩn mà kernel nền
chủ đề tuôn ra sẽ bắt đầu viết lại.

Lưu ý:
  dirty_background_bytes là bản sao của dirty_background_ratio. Chỉ
  một trong số chúng có thể được chỉ định tại một thời điểm. Khi một sysctl được viết nó là
  được tính đến ngay lập tức để đánh giá giới hạn bộ nhớ bẩn và
  khác xuất hiện là 0 khi đọc.


dirty_background_ratio
======================

Chứa, dưới dạng phần trăm của tổng bộ nhớ khả dụng có chứa các trang trống
và các trang có thể lấy lại được, số trang mà tại đó hạt nhân nền
các luồng của trình dọn dẹp sẽ bắt đầu ghi ra dữ liệu bẩn.

Tổng bộ nhớ khả dụng không bằng tổng bộ nhớ hệ thống.


bẩn_byte
===========

Chứa lượng bộ nhớ bẩn mà đĩa tạo tiến trình ghi vào đó
chính nó sẽ bắt đầu viết lại.

Lưu ý: dirty_bytes là bản sao của dirty_ratio. Chỉ có một trong số họ có thể
được chỉ định tại một thời điểm. Khi một sysctl được viết, nó ngay lập tức được đưa vào
tài khoản để đánh giá giới hạn bộ nhớ bẩn và tài khoản còn lại xuất hiện là 0 khi
đọc.

Lưu ý: giá trị tối thiểu được phép cho dirty_bytes là hai trang (tính bằng byte); bất kỳ
giá trị thấp hơn giới hạn này sẽ bị bỏ qua và cấu hình cũ sẽ được
được giữ lại.


dirty_expire_centisecs
======================

Khả năng điều chỉnh này được sử dụng để xác định khi nào dữ liệu bẩn đủ cũ để đủ điều kiện
để ghi lại bởi các luồng trình dọn dẹp hạt nhân.  Nó được thể hiện ở phần 100
một giây.  Dữ liệu đã bị bẩn trong bộ nhớ lâu hơn thế này
khoảng thời gian sẽ được viết ra vào lần tiếp theo khi chuỗi trình khởi động thức dậy.


tỷ lệ bẩn
===========

Chứa, dưới dạng phần trăm của tổng bộ nhớ khả dụng có chứa các trang trống
và các trang có thể lấy lại được, số trang mà tại đó một tiến trình được
việc tạo đĩa ghi sẽ tự bắt đầu ghi dữ liệu bẩn.

Tổng bộ nhớ khả dụng không bằng tổng bộ nhớ hệ thống.


dirtytime_expire_seconds
========================

Khi một inode lười biếng liên tục làm các trang của nó bị bẩn, thì inode đó có
dấu thời gian được cập nhật sẽ không bao giờ có cơ hội được viết ra.  Và, nếu
điều duy nhất đã xảy ra trên hệ thống tập tin là một nút thời gian bẩn gây ra
bằng một bản cập nhật theo thời gian, một công nhân sẽ được lên lịch để đảm bảo rằng inode
cuối cùng được đẩy ra đĩa.  Điều chỉnh này được sử dụng để xác định khi bẩn
inode đã đủ cũ để đủ điều kiện ghi lại bởi các luồng trình xử lý hạt nhân.
Và, nó cũng được sử dụng làm khoảng thời gian để đánh thức chuỗi dirtytime_writeback.

Đặt giá trị này thành 0 sẽ vô hiệu hóa việc ghi lại thời gian bẩn định kỳ.


dirty_writeback_centisecs
=========================

Các luồng xử lý kernel sẽ định kỳ thức dậy và ghi dữ liệu ZZ0000ZZ
ra đĩa.  Điều chỉnh này thể hiện khoảng thời gian giữa những lần thức dậy đó, trong
100 phần giây.

Đặt giá trị này thành 0 sẽ vô hiệu hóa hoàn toàn việc ghi lại định kỳ.


drop_caches
===========

Việc ghi vào đây sẽ khiến kernel xóa bộ nhớ đệm sạch, cũng như
các đối tượng tấm có thể thu hồi được như răng giả và nút.  Sau khi bị rơi, họ
bộ nhớ trở nên miễn phí.

Để giải phóng bộ đệm trang::

echo 1 > /proc/sys/vm/drop_caches

Để giải phóng các đối tượng tấm có thể lấy lại được (bao gồm các răng và nút)::

echo 2 > /proc/sys/vm/drop_caches

Để giải phóng các đối tượng và bộ đệm trang:

echo 3 > /proc/sys/vm/drop_caches

Đây là một hoạt động không phá hủy và sẽ không giải phóng bất kỳ vật thể bẩn nào.
Để tăng số lượng đối tượng được giải phóng bằng thao tác này, người dùng có thể chạy
ZZ0000ZZ trước khi ghi vào /proc/sys/vm/drop_caches.  Điều này sẽ giảm thiểu sự
số lượng đối tượng bẩn trên hệ thống và tạo ra nhiều ứng viên hơn
bị rơi.

Tệp này không phải là phương tiện để kiểm soát sự phát triển của các bộ đệm kernel khác nhau
(inodes, dentries, pagecache, v.v...) Những đối tượng này được tự động
được kernel lấy lại khi cần bộ nhớ ở nơi khác trên hệ thống.

Việc sử dụng tệp này có thể gây ra vấn đề về hiệu suất.  Vì nó loại bỏ bộ nhớ đệm
các đối tượng, có thể tốn một lượng I/O và CPU đáng kể để tạo lại
đồ vật bị rơi, đặc biệt nếu chúng được sử dụng nhiều.  Vì điều này,
không nên sử dụng bên ngoài môi trường thử nghiệm hoặc gỡ lỗi.

Bạn có thể thấy các thông báo thông tin trong nhật ký kernel của mình khi tập tin này được
đã sử dụng::

mèo (1234): drop_caches: 3

Đây chỉ là thông tin.  Họ không có nghĩa là có điều gì đó không ổn
với hệ thống của bạn.  Để tắt chúng, hãy echo 4 (bit 2) vào drop_caches.

kích hoạt_soft_offline
===================
Lỗi bộ nhớ có thể sửa được rất phổ biến trên các máy chủ. Soft-offline là của kernel
giải pháp cho các trang bộ nhớ có (quá nhiều) lỗi bộ nhớ đã được sửa.

Đối với các loại trang khác nhau, soft-offline có các hành vi/chi phí khác nhau.

- Đối với trang lỗi thô, tính năng ngoại tuyến mềm sẽ di chuyển nội dung của trang đang sử dụng sang
  một trang thô mới.

- Đối với một trang là một phần của trang lớn trong suốt, tính năng ngoại tuyến mềm sẽ chia tách
  trang lớn thành các trang thô, sau đó chỉ di chuyển trang lỗi thô.
  Kết quả là người dùng được hỗ trợ một cách minh bạch bởi ít hơn 1 trang lớn, ảnh hưởng đến
  hiệu suất truy cập bộ nhớ.

- Đối với một trang là một phần của trang HugeTLB, tính năng ngoại tuyến mềm trước tiên sẽ được di chuyển
  toàn bộ trang lớn HugeTLB, trong đó một trang lớn miễn phí sẽ được sử dụng
  làm mục tiêu di cư.  Sau đó, trang lớn ban đầu được hòa tan thành dạng thô
  các trang không được bồi thường, làm giảm dung lượng của nhóm HugeTLB xuống 1.

Lời kêu gọi của người dùng là lựa chọn giữa độ tin cậy (tránh xa các thiết bị dễ vỡ
bộ nhớ vật lý) so với ý nghĩa về hiệu suất/dung lượng trong tính minh bạch và
Các trường hợp TLB lớn.

Đối với tất cả các kiến trúc, Enable_soft_offline kiểm soát xem có chuyển sang chế độ ngoại tuyến mềm hay không
trang ký ức.  Khi được đặt thành 1, kernel sẽ cố gắng làm mềm các trang ngoại tuyến
bất cứ khi nào nó thấy cần thiết.  Khi được đặt thành 0, kernel trả về EOPNOTSUPP cho
yêu cầu soft offline các trang.  Giá trị mặc định của nó là 1.

Điều đáng nói là sau khi đặt Enable_soft_offline thành 0,
các yêu cầu sau tới các trang ngoại tuyến mềm sẽ không được thực hiện:

- Yêu cầu các trang ngoại tuyến mềm từ RAS Correctable Errors Collector.

- Trên ARM, yêu cầu các trang offline mềm từ driver GHES.

- Trên PARISC, yêu cầu các trang offline mềm từ Bảng Deallocation Trang.

extfrag_threshold
=================

Tham số này ảnh hưởng đến việc kernel sẽ thu gọn bộ nhớ hay chỉ đạo
đòi lại để đáp ứng phân bổ bậc cao. Tệp extfrag/extfrag_index trong
debugfs hiển thị chỉ số phân mảnh cho mỗi đơn hàng trong mỗi vùng trong
hệ thống. Các giá trị có xu hướng về 0 ngụ ý việc phân bổ sẽ thất bại do thiếu
của bộ nhớ, các giá trị hướng tới 1000 ngụ ý lỗi là do phân mảnh và -1
ngụ ý rằng việc phân bổ sẽ thành công miễn là các hình mờ được đáp ứng.

Hạt nhân sẽ không nén bộ nhớ trong một vùng nếu
chỉ số phân mảnh là <= extfrag_threshold. Giá trị mặc định là 500.


highmem_is_dirtyable
====================

Chỉ khả dụng cho các hệ thống đã bật CONFIG_HIGHMEM (hệ thống 32b).

Tham số này kiểm soát xem bộ nhớ cao có bị coi là bẩn hay không.
nhà văn điều tiết.  Đây không phải là trường hợp mặc định có nghĩa là
chỉ lượng bộ nhớ mà kernel có thể nhìn thấy/sử dụng trực tiếp mới có thể
bị bẩn. Kết quả là, trên các hệ thống có lượng bộ nhớ lớn và
về cơ bản, các nhà văn đã cạn kiệt lowmem có thể bị hạn chế quá sớm và
việc ghi trực tuyến có thể rất chậm.

Thay đổi giá trị thành khác 0 sẽ làm bẩn nhiều bộ nhớ hơn
và do đó cho phép người viết ghi nhiều dữ liệu hơn có thể được chuyển vào
lưu trữ hiệu quả hơn. Lưu ý điều này cũng đi kèm với nguy cơ trưởng thành sớm
OOM sát thủ vì một số tác giả (ví dụ: ghi thiết bị khối trực tiếp) có thể
chỉ sử dụng bộ nhớ thấp và họ có thể lấp đầy nó bằng dữ liệu bẩn mà không cần
bất kỳ sự điều tiết nào.


Hugetlb_shm_group
=================

Hugetlb_shm_group chứa id nhóm được phép tạo SysV
phân đoạn bộ nhớ chia sẻ sử dụng trang Hugetlb.


di sản_va_layout
================

Nếu khác 0, sysctl này sẽ vô hiệu hóa bố cục mmap 32 bit mới - kernel
sẽ sử dụng bố cục cũ (2.4) cho tất cả các quy trình.


lowmem_reserve_ratio
====================

Đối với một số khối lượng công việc chuyên biệt trên máy highmem, điều này rất nguy hiểm cho
kernel để cho phép bộ nhớ tiến trình được phân bổ từ "lowmem"
khu.  Điều này là do bộ nhớ đó có thể được ghim thông qua mlock()
cuộc gọi hệ thống hoặc do không có sẵn vùng trao đổi.

Và trên các máy highmem lớn, việc thiếu bộ nhớ lowmem có thể lấy lại được
có thể gây tử vong.

Vì vậy, bộ cấp phát trang Linux có cơ chế ngăn chặn việc phân bổ
ZZ0000ZZ sử dụng highmem do sử dụng quá nhiều lowmem.  Điều này có nghĩa là
một lượng lowmem nhất định được bảo vệ khỏi khả năng bị
được ghi vào bộ nhớ người dùng được ghim.

(Lập luận tương tự áp dụng cho vùng ISA DMA 16 megabyte cũ. Điều này
cơ chế cũng sẽ bảo vệ khu vực đó khỏi sự phân bổ có thể sử dụng
highmem hoặc lowmem).

ZZ0000ZZ có thể điều chỉnh xác định mức độ tích cực của kernel
trong việc bảo vệ các khu vực thấp hơn này.

Nếu bạn có máy sử dụng highmem hoặc ISA DMA và
các ứng dụng đang sử dụng mlock() hoặc nếu bạn đang chạy không có trao đổi thì
có lẽ bạn nên thay đổi cài đặt lowmem_reserve_ratio.

lowmem_reserve_ratio là một mảng. Bạn có thể nhìn thấy chúng bằng cách đọc tập tin này::

% mèo /proc/sys/vm/lowmem_reserve_ratio
	256 256 32

Tuy nhiên, những giá trị này không được sử dụng trực tiếp. Kernel tính toán bảo vệ # of
các trang cho từng khu vực từ chúng. Chúng được hiển thị dưới dạng mảng các trang bảo vệ
trong /proc/zoneinfo như sau. (Đây là ví dụ về hộp x86-64).
Mỗi vùng có một loạt các trang bảo vệ như thế này::

Nút 0, vùng DMA
    trang miễn phí 1355
          phút 3
          thấp 3
          cao 4
	:
	:
      num_other 0
          bảo vệ: (0, 2004, 2004, 2004)
	^^ ^^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^
    trang trang
      CPU: 0 PCP: 0
          :

Các biện pháp bảo vệ này được thêm vào để chấm điểm để đánh giá xem có nên sử dụng vùng này hay không
để phân bổ trang hoặc cần được thu hồi.

Trong ví dụ này, nếu các trang thông thường (chỉ mục=2) được yêu cầu đối với vùng DMA này và
hình mờ[WMARK_HIGH] được sử dụng cho hình mờ, hạt nhân sẽ đánh giá vùng này
không được sử dụng vì pages_free(1355) nhỏ hơn hình mờ + bảo vệ[2]
(4 + 2004 = 2008). Nếu giá trị bảo vệ này là 0, vùng này sẽ được sử dụng cho
yêu cầu trang bình thường. Nếu yêu cầu là vùng DMA(chỉ số=0), bảo vệ[0]
(=0) được sử dụng.

mức độ bảo vệ của vùng [i] [j] được tính bằng biểu thức sau ::

(tôi < j):
    vùng[i]->bảo vệ[j]
    = (tổng số trang được quản lý từ vùng[i+1] đến vùng[j] trên nút)
      / lowmem_reserve_ratio[i];
  (i = j):
     (không nên được bảo vệ. = 0;
  (i > j):
     (không cần thiết, nhưng trông như 0)

Các giá trị mặc định của lowmem_reserve_ratio[i] là

=== =======================================
    256 (nếu vùng [i] có nghĩa là vùng DMA hoặc DMA32)
    32 (khác)
    === =======================================

Như biểu thức trên, chúng là số tỉ lệ nghịch đảo.
256 có nghĩa là 1/256. Các trang bảo vệ # of chiếm khoảng "0,39%" tổng số trang được quản lý
các trang của vùng cao hơn trên nút.

Nếu bạn muốn bảo vệ nhiều trang hơn, giá trị nhỏ hơn sẽ có hiệu quả.
Giá trị tối thiểu là 1 (1/1 -> 100%). Giá trị nhỏ hơn 1 hoàn toàn
vô hiệu hóa bảo vệ các trang.


max_map_count
=============

Tệp này chứa số vùng bản đồ bộ nhớ tối đa mà một tiến trình
có thể có. Các khu vực bản đồ bộ nhớ được sử dụng như một tác dụng phụ của việc gọi
malloc, trực tiếp bởi mmap, mprotect và madvise, cũng như khi tải
các thư viện chia sẻ.

Trong khi hầu hết các ứng dụng cần ít hơn một nghìn bản đồ, một số
các chương trình, đặc biệt là trình gỡ lỗi malloc, có thể sử dụng rất nhiều chương trình,
ví dụ: tối đa một hoặc hai bản đồ cho mỗi lần phân bổ.

Giá trị mặc định là 65530.


mem_profile
==============

Bật cấu hình bộ nhớ (khi CONFIG_MEM_ALLOC_PROFILING=y)

1: Kích hoạt tính năng cấu hình bộ nhớ.

0: Tắt cấu hình bộ nhớ.

Việc kích hoạt tính năng lập hồ sơ bộ nhớ sẽ gây ra một chi phí nhỏ về hiệu suất cho tất cả
phân bổ bộ nhớ.

Giá trị mặc định phụ thuộc vào CONFIG_MEM_ALLOC_PROFILING_ENABLED_BY_DEFAULT.

Khi CONFIG_MEM_ALLOC_PROFILING_DEBUG=y, điều khiển này ở chế độ chỉ đọc để tránh
cảnh báo được tạo bởi phân bổ được thực hiện trong khi hồ sơ bị vô hiệu hóa và giải phóng
khi nó được kích hoạt.


bộ nhớ_failure_early_kill
=========================

Kiểm soát cách tắt tiến trình khi lỗi bộ nhớ chưa được sửa (thường là
lỗi 2bit trong mô-đun bộ nhớ) được phát hiện ở chế độ nền bằng phần cứng
mà kernel không thể xử lý được. Trong một số trường hợp (như trang
vẫn còn bản sao hợp lệ trên đĩa) kernel sẽ xử lý lỗi
một cách minh bạch mà không ảnh hưởng đến bất kỳ ứng dụng nào. Nhưng nếu có
không có bản sao dữ liệu cập nhật nào khác mà nó sẽ hủy để ngăn chặn bất kỳ dữ liệu nào
tham nhũng từ việc tuyên truyền.

1: Tiêu diệt tất cả các quy trình có ánh xạ trang bị hỏng và không thể tải lại
ngay khi phát hiện ra tham nhũng.  Lưu ý điều này không được hỗ trợ
đối với một số loại trang, như dữ liệu được phân bổ nội bộ trong kernel hoặc
bộ đệm trao đổi, nhưng hoạt động với phần lớn các trang của người dùng.

0: Chỉ hủy ánh xạ trang bị hỏng khỏi tất cả các quy trình và chỉ hủy một quy trình
người cố gắng truy cập nó.

Việc tiêu diệt được thực hiện bằng cách sử dụng SIGBUS có thể bắt được với BUS_MCEERR_AO, vì vậy các quy trình có thể
xử lý việc này nếu họ muốn.

Điều này chỉ hoạt động trên kiến trúc/nền tảng với máy tiên tiến
kiểm tra xử lý và phụ thuộc vào khả năng phần cứng.

Các ứng dụng có thể ghi đè cài đặt này riêng lẻ bằng chương trình PR_MCE_KILL


bộ nhớ_failure_recovery
=======================

Cho phép khôi phục lỗi bộ nhớ (khi được nền tảng hỗ trợ)

1: Cố gắng phục hồi.

0: Luôn hoảng sợ khi bộ nhớ bị lỗi.


phút_free_kbyte
===============

Điều này được sử dụng để buộc máy ảo Linux giữ số lượng tối thiểu
kilobyte miễn phí.  VM sử dụng số này để tính toán
giá trị hình mờ[WMARK_MIN] cho từng vùng lowmem trong hệ thống.
Mỗi vùng lowmem nhận được một số trang miễn phí dành riêng dựa trên
tỷ lệ thuận với kích thước của nó.

Cần một lượng bộ nhớ tối thiểu để đáp ứng PF_MEMALLOC
phân bổ; nếu bạn đặt giá trị này thấp hơn 1024KB, hệ thống của bạn sẽ
trở nên dễ bị hỏng và dễ bị bế tắc khi chịu tải cao.

Đặt mức này quá cao sẽ khiến máy của bạn OOM ngay lập tức.


min_slab_ratio
==============

Tính năng này chỉ có trên hạt nhân NUMA.

Một tỷ lệ phần trăm của tổng số trang trong mỗi khu vực.  Trên vùng đòi lại
(xảy ra dự phòng từ vùng cục bộ) các phiến sẽ được thu hồi nếu có thêm
hơn tỷ lệ phần trăm trang này trong một vùng là các trang phiến có thể lấy lại được.
Điều này đảm bảo rằng sự tăng trưởng của tấm vẫn được kiểm soát ngay cả trong NUMA
các hệ thống hiếm khi thực hiện việc thu hồi toàn cục.

Mặc định là 5 phần trăm.

Lưu ý rằng việc thu hồi bản sàn được kích hoạt theo kiểu từng vùng/nút.
Quá trình lấy lại bộ nhớ phiến hiện không dành riêng cho nút nào
và có thể không nhanh.


min_unmapped_ratio
==================

Tính năng này chỉ có trên hạt nhân NUMA.

Đây là tỷ lệ phần trăm của tổng số trang trong mỗi vùng. Khu vực đòi lại sẽ
chỉ xảy ra nếu nhiều hơn tỷ lệ phần trăm này của các trang ở trạng thái
Zone_reclaim_mode cho phép được thu hồi.

Nếu vùng_reclaim_mode có giá trị 4 OR'd thì tỷ lệ phần trăm sẽ được so sánh
chống lại tất cả các trang chưa được ánh xạ được hỗ trợ bằng tệp bao gồm các trang swapcache và tmpfs
tập tin. Mặt khác, chỉ các trang chưa được ánh xạ được hỗ trợ bởi các tệp thông thường chứ không phải tmpfs
các tập tin và tương tự được xem xét.

Mặc định là 1 phần trăm.


mmap_min_addr
=============

Tệp này cho biết lượng không gian địa chỉ mà quy trình người dùng sẽ
bị hạn chế từ mmapping.  Vì lỗi vô hiệu hóa kernel null có thể
vô tình hoạt động dựa trên thông tin trong vài trang đầu tiên
của các tiến trình không gian người dùng bộ nhớ không được phép ghi vào chúng.  Bởi
mặc định giá trị này được đặt thành 0 và sẽ không có biện pháp bảo vệ nào được thực thi bởi
mô-đun bảo mật.  Đặt giá trị này thành khoảng 64k sẽ cho phép
phần lớn các ứng dụng hoạt động chính xác và cung cấp khả năng bảo vệ chuyên sâu
chống lại các lỗi kernel tiềm ẩn trong tương lai.


mmap_rnd_bits
=============

Giá trị này có thể được sử dụng để chọn số bit cần sử dụng để
xác định độ lệch ngẫu nhiên cho địa chỉ cơ sở của vùng vma
kết quả từ việc phân bổ mmap trên các kiến trúc hỗ trợ
điều chỉnh ngẫu nhiên không gian địa chỉ.  Giá trị này sẽ được giới hạn
bởi các giá trị được hỗ trợ tối thiểu và tối đa của kiến trúc.

Giá trị này có thể được thay đổi sau khi khởi động bằng cách sử dụng
/proc/sys/vm/mmap_rnd_bits có thể điều chỉnh


mmap_rnd_compat_bits
====================

Giá trị này có thể được sử dụng để chọn số bit cần sử dụng để
xác định độ lệch ngẫu nhiên cho địa chỉ cơ sở của vùng vma
kết quả từ việc phân bổ mmap cho các ứng dụng chạy trong
chế độ tương thích trên các kiến trúc hỗ trợ địa chỉ điều chỉnh
ngẫu nhiên hóa không gian.  Giá trị này sẽ được giới hạn bởi
giá trị được hỗ trợ tối thiểu và tối đa của kiến trúc.

Giá trị này có thể được thay đổi sau khi khởi động bằng cách sử dụng
/proc/sys/vm/mmap_rnd_compat_bits có thể điều chỉnh


di chuyển_gigantic_pages
======================

Tham số này kiểm soát xem các trang khổng lồ có thể được phân bổ từ
ZONE_MOVABLE. Nếu được đặt thành khác 0, các trang khổng lồ có thể được phân bổ
từ ZONE_MOVABLE. Bộ nhớ ZONE_MOVABLE có thể được tạo thông qua kernel
tham số khởi động ZZ0000ZZ hoặc thông qua cắm nóng bộ nhớ như đã thảo luận trong
Tài liệu/admin-guide/mm/memory-hotplug.rst.

Hỗ trợ có thể phụ thuộc vào kiến ​​trúc cụ thể.

Lưu ý rằng việc sử dụng các trang khổng lồ ZONE_MOVABLE sẽ khiến bộ nhớ hotremove không đáng tin cậy.

Hoạt động xóa nóng bộ nhớ sẽ bị chặn vô thời hạn cho đến khi quản trị viên bảo lưu
đủ các trang khổng lồ để phục vụ các yêu cầu di chuyển liên quan đến
quá trình ngoại tuyến bộ nhớ.  Vì việc đặt trước trang khổng lồ HugeTLB là một hướng dẫn
quá trình (thông qua giao diện ZZ0000ZZ) điều này có thể không
rõ ràng khi chỉ cố gắng ngoại tuyến một khối bộ nhớ.

Ngoài ra, vì nhiều trang khổng lồ có thể được đặt trước trên một khối duy nhất,
có vẻ như các trang khổng lồ có sẵn để di chuyển trong khi thực tế
chúng đang trong quá trình được gỡ bỏ. Ví dụ: nếu ZZ0000ZZ chứa
hai trang khổng lồ, một trang dành riêng và một trang được phân bổ, và một quản trị viên cố gắng
ngoại tuyến khối đó, hoạt động này có thể bị treo vô thời hạn trừ khi có khối khác
trang khổng lồ dành riêng có sẵn trên một khối khác ZZ0001ZZ.


nr_hugepages
============

Thay đổi kích thước tối thiểu của nhóm trang lớn.

Xem Tài liệu/admin-guide/mm/hugetlbpage.rst


Hugetlb_optimize_vmemmap
========================

Núm này không khả dụng khi kích thước của 'trang cấu trúc' (cấu trúc được xác định
trong include/linux/mm_types.h) không phải là lũy thừa của hai (một cấu hình hệ thống bất thường có thể
dẫn đến việc này).

Bật (đặt thành 1) hoặc tắt (đặt thành 0) Tối ưu hóa HugeTLB Vmemmap (HVO).

Sau khi được bật, các trang vmemmap của lần phân bổ tiếp theo của các trang HugeTLB từ
công cụ phân bổ bạn bè sẽ được tối ưu hóa (7 trang trên mỗi trang HugeTLB 2MB và 4095 trang
trên mỗi trang HugeTLB 1GB), trong khi các trang HugeTLB đã được phân bổ sẽ không
được tối ưu hóa.  Khi các trang HugeTLB được tối ưu hóa đó được giải phóng khỏi nhóm HugeTLB
đối với người cấp phát bạn bè, các trang vmemmap đại diện cho phạm vi đó cần phải được
được ánh xạ lại và các trang vmemmap bị loại bỏ trước đó cần được sắp xếp lại
một lần nữa.  Nếu trường hợp sử dụng của bạn là các trang HugeTLB được phân bổ 'nhanh chóng' (ví dụ:
không bao giờ phân bổ rõ ràng các trang HugeTLB bằng 'nr_hugepages' mà chỉ đặt
'nr_overcommit_hugepages', những trang HugeTLB được cam kết quá mức sẽ được phân bổ 'trên
con ruồi') thay vì bị kéo ra khỏi nhóm HugeTLB, bạn nên cân nhắc
lợi ích của việc tiết kiệm bộ nhớ so với chi phí cao hơn (chậm hơn ~ 2 lần so với trước đây)
phân bổ hoặc giải phóng các trang HugeTLB giữa nhóm HugeTLB và bạn bè
người cấp phát.  Một hành vi khác cần lưu ý là nếu hệ thống có bộ nhớ nặng
áp lực, nó có thể ngăn người dùng giải phóng các trang HugeTLB khỏi HugeTLB
gộp vào bộ cấp phát bạn bè vì việc phân bổ các trang vmemmap có thể
không thành công, bạn phải thử lại sau nếu hệ thống của bạn gặp phải tình trạng này.

Sau khi bị tắt, các trang vmemmap của lần phân bổ tiếp theo của các trang HugeTLB từ
công cụ phân bổ bạn bè sẽ không được tối ưu hóa, nghĩa là chi phí bổ sung khi phân bổ
thời gian từ công cụ phân bổ bạn bè biến mất, trong khi các trang HugeTLB đã được tối ưu hóa
sẽ không bị ảnh hưởng.  Nếu bạn muốn đảm bảo không có HugeTLB nào được tối ưu hóa
trang, trước tiên bạn có thể đặt "nr_hugepages" thành 0 rồi tắt tính năng này.  Lưu ý rằng
ghi 0 vào nr_hugepages sẽ khiến mọi trang HugeTLB "đang được sử dụng" trở nên dư thừa
trang.  Vì vậy, những trang thừa đó vẫn được tối ưu hóa cho đến khi không còn
đang sử dụng.  Bạn sẽ phải đợi những trang dư thừa đó được phát hành trước khi
không có trang nào được tối ưu hóa trong hệ thống.


nr_hugepages_mempolicy
======================

Thay đổi kích thước của nhóm trang lớn trong thời gian chạy trên một trang cụ thể
tập hợp các nút NUMA.

Xem Tài liệu/admin-guide/mm/hugetlbpage.rst


nr_overcommit_hugepages
=======================

Thay đổi kích thước tối đa của nhóm trang lớn. Tối đa là
nr_hugepages + nr_overcommit_hugepages.

Xem Tài liệu/admin-guide/mm/hugetlbpage.rst


nr_trim_pages
=============

Tính năng này chỉ có trên hạt nhân NOMMU.

Giá trị này điều chỉnh hành vi cắt trang thừa của căn chỉnh lũy thừa 2
Phân bổ mmap NOMMU.

Giá trị 0 sẽ vô hiệu hóa hoàn toàn việc cắt bớt phân bổ, trong khi giá trị 1
cắt bớt các trang thừa một cách mạnh mẽ. Bất kỳ giá trị nào >= 1 đóng vai trò là hình mờ trong đó
việc cắt giảm phân bổ được bắt đầu.

Giá trị mặc định là 1.

Xem Tài liệu/admin-guide/mm/nommu-mmap.rst để biết thêm thông tin.


numa_zonelist_order
===================

Sysctl này chỉ dành cho NUMA và nó không được dùng nữa. Bất cứ điều gì nhưng
Thứ tự nút sẽ thất bại!

'Nơi bộ nhớ được phân bổ từ' được kiểm soát bởi các danh sách vùng.

(Tài liệu này bỏ qua ZONE_HIGHMEM/ZONE_DMA32 để giải thích đơn giản.
bạn có thể đọc ZONE_DMA là ZONE_DMA32...)

Trong trường hợp không phải NUMA, danh sách vùng cho GFP_KERNEL được sắp xếp như sau.
ZONE_NORMAL -> ZONE_DMA
Điều này có nghĩa là yêu cầu cấp phát bộ nhớ cho GFP_KERNEL sẽ
chỉ lấy bộ nhớ từ ZONE_DMA khi ZONE_NORMAL không có sẵn.

Trong trường hợp NUMA, bạn có thể nghĩ đến 2 loại thứ tự sau.
Giả sử 2 nút NUMA trở xuống là danh sách vùng của GFP_KERNEL của Nút (0)::

(A) Nút (0) ZONE_NORMAL -> Nút (0) ZONE_DMA -> Nút (1) ZONE_NORMAL
  (B) Nút (0) ZONE_NORMAL -> Nút (1) ZONE_NORMAL -> Nút (0) ZONE_DMA.

Loại (A) cung cấp vị trí tốt nhất cho các quy trình trên Nút (0), nhưng ZONE_DMA
sẽ được sử dụng trước khi ZONE_NORMAL cạn kiệt. Điều này làm tăng khả năng
hết bộ nhớ (OOM) của ZONE_DMA vì ZONE_DMA có xu hướng nhỏ.

Loại (B) không thể cung cấp địa phương tốt nhất nhưng mạnh hơn so với OOM của
vùng DMA.

Loại (A) được gọi là thứ tự "Nút". Loại (B) là thứ tự "Vùng".

"Thứ tự nút" sắp xếp danh sách vùng theo nút, sau đó theo vùng trong mỗi nút.
Chỉ định "[Nn]ode" cho thứ tự nút

"Thứ tự vùng" sắp xếp các danh sách vùng theo loại vùng, sau đó theo nút trong mỗi vùng
khu.  Chỉ định "[Zz]one" cho thứ tự vùng.

Chỉ định "[Dd]efault" để yêu cầu cấu hình tự động.

Trên 32 bit, vùng Bình thường cần được giữ nguyên để có thể truy cập phân bổ
bởi kernel, do đó thứ tự "vùng" sẽ được chọn.

Trên 64-bit, các thiết bị yêu cầu DMA32/DMA tương đối hiếm, vì vậy "nút"
thứ tự sẽ được chọn.

Thứ tự mặc định được khuyến nghị trừ khi điều này gây ra vấn đề cho
hệ thống/ứng dụng.


oom_dump_tasks
==============

Cho phép tạo kết xuất tác vụ trên toàn hệ thống (không bao gồm các luồng nhân)
khi kernel thực hiện việc tiêu diệt OOM và bao gồm các thông tin như
pid, uid, tgid, kích thước vm, rss, pgtables_bytes, hoán đổi, oom_score_adj
điểm và tên.  Điều này rất hữu ích để xác định lý do tại sao kẻ giết người OOM lại bị
được gọi, để xác định tác vụ sai trái đã gây ra nó và xác định lý do tại sao
sát thủ OOM đã chọn nhiệm vụ mà nó thực hiện để tiêu diệt.

Nếu giá trị này được đặt thành 0, thông tin này sẽ bị chặn.  Trên rất
các hệ thống lớn với hàng nghìn tác vụ có thể không khả thi để kết xuất
thông tin trạng thái bộ nhớ cho mỗi người.  Những hệ thống như vậy không nên
bị buộc phải chịu một hình phạt về hiệu suất trong điều kiện OOM khi
thông tin có thể không được mong muốn.

Nếu giá trị này được đặt thành khác 0, thông tin này sẽ được hiển thị bất cứ khi nào
OOM sát thủ thực sự tiêu diệt một nhiệm vụ ngốn bộ nhớ.

Giá trị mặc định là 1 (đã bật).


oom_kill_allocate_task
========================

Điều này cho phép hoặc vô hiệu hóa việc hủy tác vụ kích hoạt OOM trong
tình huống hết bộ nhớ.

Nếu giá trị này được đặt thành 0, sát thủ OOM sẽ quét toàn bộ
danh sách nhiệm vụ và chọn một nhiệm vụ dựa trên chẩn đoán để tiêu diệt.  Điều này bình thường
chọn một tác vụ ngốn bộ nhớ giả để giải phóng một lượng lớn
ký ức khi bị giết.

Nếu giá trị này được đặt thành khác 0, sát thủ OOM chỉ đơn giản là giết chết nhiệm vụ
gây ra tình trạng hết bộ nhớ.  Điều này tránh được sự tốn kém
quét danh sách nhiệm vụ.

Nếu chọn Panic_on_oom, nó sẽ được ưu tiên hơn bất kỳ giá trị nào
được sử dụng trong oom_kill_allocate_task.

Giá trị mặc định là 0.


vượt quá_kbyte
=================

Khi overcommit_memory được đặt thành 2, không gian địa chỉ đã cam kết không còn nữa
được phép vượt quá trao đổi cộng với số lượng RAM vật lý này. Xem bên dưới.

Lưu ý: overcommit_kbytes là bản sao của overcommit_ratio. Chỉ có một
trong số chúng có thể được chỉ định tại một thời điểm. Đặt cái này sẽ vô hiệu hóa cái kia (cái này
sau đó xuất hiện là 0 khi đọc).


overcommit_memory
=================

Giá trị này chứa cờ cho phép cam kết vượt mức bộ nhớ.

Khi cờ này bằng 0, kernel sẽ so sánh yêu cầu bộ nhớ vùng người dùng
kích thước so với tổng bộ nhớ cộng với trao đổi và từ chối các cam kết quá mức rõ ràng.

Khi cờ này bằng 1, kernel giả vờ như luôn có đủ
bộ nhớ cho đến khi nó thực sự hết.

Khi cờ này là 2, kernel sử dụng "không bao giờ vượt quá"
chính sách cố gắng ngăn chặn bất kỳ sự vượt quá nào của bộ nhớ.
Lưu ý rằng user_reserve_kbytes ảnh hưởng đến chính sách này.

Tính năng này có thể rất hữu ích vì có rất nhiều
các chương trình malloc() có lượng bộ nhớ khổng lồ "dự phòng"
và không sử dụng nhiều.

Giá trị mặc định là 0.

Xem Tài liệu/mm/overcommit-accounting.rst và
mm/util.c::__vm_enough_memory() để biết thêm thông tin.


vượt quá_ratio
================

Khi overcommit_memory được đặt thành 2, địa chỉ đã cam kết
không gian không được phép vượt quá trao đổi cộng với tỷ lệ phần trăm này
của RAM vật lý.  Xem ở trên.


cụm trang
============

cụm trang kiểm soát số trang cho đến các trang liên tiếp
được đọc từ trao đổi trong một lần thử. Đây là đối tác trao đổi
để đọc trước bộ đệm trang.
Tính liên tục được đề cập không liên quan đến địa chỉ ảo/vật lý,
nhưng liên tiếp trên không gian hoán đổi - điều đó có nghĩa là chúng được hoán đổi cùng nhau.

Đó là một giá trị logarit - đặt nó về 0 có nghĩa là "1 trang", cài đặt
nó thành 1 nghĩa là "2 trang", đặt thành 2 nghĩa là "4 trang", v.v.
Zero vô hiệu hóa hoàn toàn việc đọc trước trao đổi.

Giá trị mặc định là ba (tám trang một lần).  Có thể có một số
những lợi ích nhỏ trong việc điều chỉnh giá trị này thành một giá trị khác nếu khối lượng công việc của bạn
trao đổi chuyên sâu.

Giá trị thấp hơn có nghĩa là độ trễ thấp hơn đối với các lỗi ban đầu, nhưng đồng thời
các lỗi bổ sung và độ trễ I/O cho các lỗi tiếp theo nếu chúng là một phần của
những trang liên tiếp được đọc trước sẽ mang lại kết quả.


trang_lock_sự không công bằng
====================

Giá trị này xác định số lần khóa trang có thể được thực hiện
bị đánh cắp từ dưới một người phục vụ. Sau khi khóa bị đánh cắp số lần
được chỉ định trong tệp này (mặc định là 5), ngữ nghĩa "chuyển giao khóa công bằng"
sẽ được áp dụng và người phục vụ sẽ chỉ được đánh thức nếu có thể lấy được khóa.

hoảng loạn_on_oom
============

Điều này cho phép hoặc vô hiệu hóa sự hoảng loạn về tính năng hết bộ nhớ.

Nếu giá trị này được đặt thành 0, kernel sẽ giết một số tiến trình giả mạo,
được gọi là oom_killer.  Thông thường, oom_killer có thể tiêu diệt các tiến trình giả mạo và
hệ thống sẽ tồn tại.

Nếu giá trị này được đặt thành 1, kernel sẽ hoảng loạn khi hết bộ nhớ.
Tuy nhiên, nếu một quá trình giới hạn việc sử dụng các nút theo mempolicy/cpusets,
và các nút đó trở thành trạng thái cạn kiệt bộ nhớ, một quá trình
có thể bị giết bởi oom-killer. Không có sự hoảng loạn xảy ra trong trường hợp này.
Bởi vì bộ nhớ của các nút khác có thể trống. Điều này có nghĩa là tổng trạng thái của hệ thống
có thể vẫn chưa gây tử vong.

Nếu giá trị này được đặt thành 2, kernel bắt buộc phải hoảng loạn ngay cả trên
đã đề cập ở trên. Ngay cả oom cũng xảy ra trong nhóm bộ nhớ, toàn bộ
hệ thống hoảng loạn.

Giá trị mặc định là 0.

1 và 2 dành cho chuyển đổi dự phòng của phân cụm. Vui lòng chọn một trong hai
theo chính sách chuyển đổi dự phòng của bạn.

Panic_on_oom=2+kdump cung cấp cho bạn công cụ rất mạnh để điều tra
tại sao om lại xảy ra. Bạn có thể có được ảnh chụp nhanh.


percpu_pagelist_high_section
=============================

Đây là phần số trang trong mỗi vùng có thể được lưu trữ vào
danh sách trang trên mỗi CPU. Đó là ranh giới trên được phân chia tùy theo
về số lượng CPU trực tuyến. Giá trị tối thiểu cho điều này là 8 có nghĩa là
rằng chúng tôi không cho phép lưu trữ quá 1/8 trang trong mỗi vùng
trên danh sách trang trên mỗi CPU. Mục này chỉ thay đổi giá trị của hot per-cpu
danh sách trang. Người dùng có thể chỉ định một số như 100 để phân bổ 1/100 của
từng vùng giữa các danh sách trên mỗi CPU.

Giá trị lô của mỗi danh sách trang trên mỗi CPU vẫn giữ nguyên bất kể
giá trị của phần cao nên độ trễ phân bổ không bị ảnh hưởng.

Giá trị ban đầu bằng không. Kernel sử dụng giá trị này để đặt pcp cao->cao
đánh dấu dựa trên hình mờ thấp cho vùng và số lượng địa phương
CPU trực tuyến.  Nếu người dùng viết '0' vào sysctl này, nó sẽ trở lại
hành vi mặc định này.


stat_interval
=============

Khoảng thời gian mà số liệu thống kê vm được cập nhật.  Mặc định
là 1 giây.


stat_refresh
============

Bất kỳ thao tác đọc hoặc ghi nào (chỉ bằng root) sẽ xóa tất cả số liệu thống kê vm trên mỗi CPU
vào tổng số toàn cầu của họ để có báo cáo chính xác hơn khi thử nghiệm
ví dụ: mèo /proc/sys/vm/stat_refresh /proc/meminfo

Là một tác dụng phụ, nó cũng kiểm tra tổng số âm (được báo cáo ở nơi khác
là 0) và "không thành công" với EINVAL nếu tìm thấy bất kỳ thứ gì, kèm theo cảnh báo trong dmesg.
(Tại thời điểm viết bài, một số số liệu thống kê đôi khi được cho là tiêu cực,
không có ảnh hưởng xấu: lỗi và cảnh báo về các số liệu thống kê này bị loại bỏ.)


số_stat
=========

Giao diện này cho phép cấu hình thời gian chạy của số liệu thống kê numa.

Khi hiệu suất phân bổ trang trở thành nút cổ chai và bạn có thể chịu đựng được
một số công cụ có thể bị hỏng và độ chính xác của bộ đếm numa giảm, bạn có thể
làm::

echo 0 > /proc/sys/vm/numa_stat

Khi hiệu suất phân bổ trang không phải là điểm nghẽn cổ chai và bạn muốn tất cả
dụng cụ để làm việc, bạn có thể làm::

echo 1 > /proc/sys/vm/numa_stat


sự tráo đổi
==========

Kiểm soát này được sử dụng để xác định chi phí IO tương đối thô của việc hoán đổi
và phân trang hệ thống tập tin, có giá trị từ 0 đến 200. Ở mức 100, VM
giả định chi phí IO bằng nhau và do đó sẽ áp dụng áp lực bộ nhớ lên trang
bộ đệm và các trang được hỗ trợ trao đổi như nhau; giá trị thấp hơn biểu thị nhiều hơn
IO trao đổi đắt tiền, giá trị cao hơn cho thấy rẻ hơn.

Hãy nhớ rằng các mẫu IO của hệ thống tập tin dưới áp lực bộ nhớ có xu hướng
hiệu quả hơn IO ngẫu nhiên của trao đổi. Một giá trị tối ưu sẽ yêu cầu
thử nghiệm và cũng sẽ phụ thuộc vào khối lượng công việc.

Giá trị mặc định là 60.

Đối với trao đổi trong bộ nhớ, như zram hoặc zswap, cũng như các thiết lập kết hợp
có trao đổi trên các thiết bị nhanh hơn hệ thống tập tin, các giá trị vượt quá 100 có thể
được xem xét. Ví dụ: nếu IO ngẫu nhiên đối với thiết bị trao đổi
trung bình nhanh hơn gấp 2 lần so với IO từ hệ thống tập tin, tính dễ thay đổi sẽ
là 133 (x + 2x = 200, 2x = 133,33).

Ở mức 0, kernel sẽ không bắt đầu trao đổi cho đến khi lượng còn trống và
các trang được hỗ trợ bằng tệp nhỏ hơn hình mờ cao trong một vùng.


không có đặc quyền_userfaultfd
========================

Cờ này kiểm soát chế độ trong đó người dùng không có đặc quyền có thể sử dụng
cuộc gọi hệ thống userfaultfd. Đặt giá trị này thành 0 để hạn chế người dùng không có đặc quyền
chỉ xử lý lỗi trang ở chế độ người dùng. Trong trường hợp này, người dùng không có
SYS_CAP_PTRACE phải vượt qua UFFD_USER_MODE_ONLY để userfaultfd
thành công. Cấm sử dụng userfaultfd để xử lý lỗi từ kernel
chế độ này có thể làm cho một số lỗ hổng nhất định khó khai thác hơn.

Đặt giá trị này thành 1 để cho phép người dùng không có đặc quyền sử dụng hệ thống userfaultfd
cuộc gọi mà không có bất kỳ hạn chế nào.

Giá trị mặc định là 0.

Một cách khác để kiểm soát quyền đối với userfaultfd là sử dụng
/dev/userfaultfd thay vì userfaultfd(2). Xem
Tài liệu/admin-guide/mm/userfaultfd.rst.

user_reserve_kbytes
===================

Khi overcommit_memory được đặt thành 2, chế độ "không bao giờ vượt quá", hãy dự trữ
tối thiểu (3% kích thước quy trình hiện tại, user_reserve_kbyte) bộ nhớ trống.
Điều này nhằm mục đích ngăn người dùng bắt đầu chiếm dụng một bộ nhớ
đến mức chúng không thể phục hồi (giết con lợn).

user_reserve_kbytes mặc định là tối thiểu (3% kích thước quy trình hiện tại, 128 MB).

Nếu giá trị này giảm xuống 0 thì người dùng sẽ được phép phân bổ
tất cả bộ nhớ trống chỉ với một quy trình, trừ admin_reserve_kbytes.
Bất kỳ nỗ lực tiếp theo nào để thực hiện lệnh sẽ dẫn đến
"ngã ba: Không thể phân bổ bộ nhớ".

Thay đổi này có hiệu lực bất cứ khi nào ứng dụng yêu cầu bộ nhớ.


vfs_cache_áp lực
==================

Giá trị phần trăm này kiểm soát xu hướng lấy lại hạt nhân
bộ nhớ được sử dụng để lưu trữ các đối tượng thư mục và inode.

Ở giá trị mặc định của vfs_cache_ Pressure=vfs_cache_ Pressure_denom kernel
sẽ cố gắng lấy lại các răng cưa và nút in ở mức "công bằng" đối với
lấy lại pagecache và swapcache.  Việc giảm vfs_cache_ Pressure gây ra
kernel thích giữ lại bộ đệm nha khoa và inode hơn. Khi vfs_cache_ Pressure=0,
hạt nhân sẽ không bao giờ lấy lại được các răng cưa và nút in do áp lực bộ nhớ và
điều này có thể dễ dàng dẫn đến tình trạng hết bộ nhớ. Tăng vfs_cache_áp lực
ngoài vfs_cache_ Pressure_denom khiến kernel thích lấy lại răng giả hơn
và inode.

Có thể tăng vfs_cache_ Pressure vượt quá vfs_cache_ Pressure_denom một cách đáng kể
có tác động tiêu cực đến hiệu suất. Mã đòi lại cần phải có nhiều khóa khác nhau để
tìm các đối tượng thư mục và inode có thể giải phóng. Khi vfs_cache_ Pressure bằng
(10 * vfs_cache_ Pressure_denom), nó sẽ tìm kiếm khả năng giải phóng cao hơn gấp mười lần
các đối tượng hơn có.

Lưu ý: Cài đặt này phải luôn được sử dụng cùng với vfs_cache_ Pressure_denom.

vfs_cache_ Pressure_denom
========================

Mặc định là 100 (giá trị tối thiểu được phép). Yêu cầu tương ứng
cài đặt vfs_cache_ Pressure có hiệu lực.

hình mờ_boost_factor
======================

Yếu tố này kiểm soát mức độ lấy lại khi bộ nhớ bị phân mảnh.
Nó xác định tỷ lệ phần trăm hình mờ cao của một vùng sẽ được
được lấy lại nếu các trang có tính di động khác nhau đang được trộn lẫn trong các khối trang.
Mục đích là việc nén chặt sẽ có ít việc phải làm hơn trong tương lai và để
tăng tỷ lệ thành công của việc phân bổ đơn hàng cao trong tương lai như SLUB
phân bổ, trang THP và Hugetlbfs.

Để làm cho nó hợp lý đối với Watermark_scale_factor
tham số, đơn vị là phân số của 10.000. Giá trị mặc định của
15.000 có nghĩa là có tới 150% hình mờ cao sẽ được thu hồi trong
sự kiện khối trang bị trộn lẫn do bị phân mảnh. Mức độ thu hồi
được xác định bởi số lượng các sự kiện phân mảnh xảy ra trong
vừa qua. Nếu giá trị này nhỏ hơn một khối trang thì một khối trang
giá trị của các trang sẽ được lấy lại (ví dụ: 2 MB trên x86 64 bit). Yếu tố thúc đẩy
bằng 0 sẽ vô hiệu hóa tính năng này.


hình mờ_scale_factor
======================

Yếu tố này kiểm soát tính hung hăng của kswapd. Nó định nghĩa
lượng bộ nhớ còn lại trong một nút/hệ thống trước khi kswapd được đánh thức và
cần bao nhiêu bộ nhớ trống trước khi kswapd chuyển sang chế độ ngủ.

Đơn vị là phân số của 10.000. Giá trị mặc định là 10 có nghĩa là
khoảng cách giữa các hình mờ là 0,1% bộ nhớ khả dụng trong
nút/hệ thống. Giá trị tối đa là 3000 hoặc 30% bộ nhớ.

Tỷ lệ cao các luồng tham gia thu hồi trực tiếp (allocstall) hoặc kswapd
đi ngủ sớm (kswapd_low_wmark_hit_quickly) có thể cho thấy
số lượng trang miễn phí mà kswapd duy trì vì lý do độ trễ là
quá nhỏ đối với các đợt phân bổ xảy ra trong hệ thống. Núm này
sau đó có thể được sử dụng để điều chỉnh mức độ hung hãn của kswapd cho phù hợp.


vùng_reclaim_mode
=================

Zone_reclaim_mode cho phép ai đó thiết lập các cách tiếp cận tích cực hơn hoặc ít hơn để
lấy lại bộ nhớ khi một vùng hết bộ nhớ. Nếu nó được đặt thành 0 thì không
việc thu hồi vùng xảy ra. Việc phân bổ sẽ được đáp ứng từ các vùng/nút khác
trong hệ thống.

Đây là giá trị HOẶC cùng nhau của

= ======================================
Bật thu hồi 1 vùng
2 Zone lấy lại ghi các trang bẩn
4 trang hoán đổi lấy lại vùng
= ======================================

Zone_reclaim_mode bị tắt theo mặc định.  Đối với máy chủ tệp hoặc khối lượng công việc
được hưởng lợi từ việc lưu trữ dữ liệu của họ, Zone_reclaim_mode sẽ là
bị vô hiệu hóa vì hiệu ứng bộ nhớ đệm có thể quan trọng hơn
địa phương dữ liệu.

Hãy cân nhắc việc kích hoạt một hoặc nhiều bit chế độ Zone_reclaim nếu biết rằng
khối lượng công việc được phân vùng sao cho mỗi phân vùng vừa với nút NUMA
và việc truy cập bộ nhớ từ xa sẽ gây ra hiệu suất có thể đo lường được
giảm bớt.  Bộ cấp phát trang sẽ thực hiện các hành động bổ sung trước khi
phân bổ các trang nút.

Cho phép lấy lại vùng để ghi ra các trang sẽ dừng các quá trình
ghi một lượng lớn dữ liệu từ các trang bẩn trên các nút khác. Khu vực
reclaim sẽ viết ra các trang bẩn nếu một vùng được lấp đầy và hiệu quả như vậy
điều tiết quá trình. Điều này có thể làm giảm hiệu suất của một quá trình
vì nó không thể sử dụng tất cả bộ nhớ hệ thống để đệm các lần ghi đi
nữa nhưng nó bảo toàn bộ nhớ trên các nút khác để hiệu suất
của các tiến trình khác đang chạy trên các nút khác sẽ không bị ảnh hưởng.

Cho phép trao đổi thường xuyên hạn chế hiệu quả việc phân bổ cho địa phương
nút trừ khi bị ghi đè rõ ràng bởi chính sách bộ nhớ hoặc cpuset
cấu hình.
