.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cgroup-v1/memory.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Bộ điều khiển tài nguyên bộ nhớ
===============================

.. caution::
      This document is hopelessly outdated and it asks for a complete
      rewrite. It still contains a useful information so we are keeping it
      here but make sure to check the current code if you need a deeper
      understanding.

.. note::
      The Memory Resource Controller has generically been referred to as the
      memory controller in this document. Do not confuse memory controller
      used here with the memory controller that is used in hardware.

.. hint::
      When we mention a cgroup (cgroupfs's directory) with memory controller,
      we call it "memory cgroup". When you see git-log and source code, you'll
      see patch's title and function names tend to use "memcg".
      In this document, we avoid using it.

Lợi ích và mục đích của bộ điều khiển bộ nhớ
=============================================

Bộ điều khiển bộ nhớ cô lập hành vi bộ nhớ của một nhóm tác vụ
từ phần còn lại của hệ thống. Bài viết trên LWN [12]_ đề cập đến một số khả năng
sử dụng bộ điều khiển bộ nhớ. Bộ điều khiển bộ nhớ có thể được sử dụng để

Một. Cô lập một ứng dụng hoặc một nhóm ứng dụng
   Các ứng dụng ngốn bộ nhớ có thể bị cô lập và giới hạn ở một phạm vi nhỏ hơn
   lượng bộ nhớ.
b. Tạo một nhóm với số lượng bộ nhớ hạn chế; cái này có thể được sử dụng
   như một giải pháp thay thế tốt cho việc khởi động bằng mem=XXXX.
c. Giải pháp ảo hóa có thể kiểm soát dung lượng bộ nhớ mong muốn
   để gán cho một phiên bản máy ảo.
d. Ổ ghi CD/DVD có thể kiểm soát dung lượng bộ nhớ được sử dụng bởi
   phần còn lại của hệ thống để đảm bảo quá trình ghi không bị lỗi do thiếu
   của bộ nhớ sẵn có.
đ. Có một số trường hợp sử dụng khác; tìm một hoặc chỉ sử dụng bộ điều khiển
   cho vui (để tìm hiểu và hack trên hệ thống con VM).

Trạng thái hiện tại: linux-2.6.34-mmotm(phiên bản phát triển 2010/tháng 4)

Đặc trưng:

- tính toán các trang ẩn danh, bộ đệm tệp, cách sử dụng bộ đệm trao đổi và giới hạn chúng.
 - các trang được liên kết riêng với mỗi memcg LRU và không có LRU toàn cầu.
 - tùy chọn, việc sử dụng bộ nhớ + trao đổi có thể được tính toán và giới hạn.
 - kế toán theo cấp bậc
 - giới hạn mềm
 - có thể lựa chọn tài khoản di chuyển (nạp tiền) khi di chuyển một nhiệm vụ.
 - thông báo ngưỡng sử dụng
 - thông báo áp suất bộ nhớ
 - núm vô hiệu hóa oom-killer và trình thông báo oom
 - Root cgroup không có điều khiển giới hạn.

Hỗ trợ bộ nhớ hạt nhân đang được tiến hành và phiên bản hiện tại cung cấp
 về cơ bản chức năng. (Xem ZZ0000ZZ)

Tóm tắt ngắn gọn về các tập tin kiểm soát.

====================================================================================
 nhiệm vụ đính kèm một nhiệm vụ (luồng) và hiển thị danh sách
				     chủ đề
 cgroup.procs hiển thị danh sách các tiến trình
 cgroup.event_control một giao diện cho event_fd()
				     Núm này không có trên hệ thống CONFIG_PREEMPT_RT.
 Memory.usage_in_bytes hiển thị mức sử dụng hiện tại của bộ nhớ
				     (Xem phần 5.5 để biết chi tiết)
 Memory.memsw.usage_in_bytes hiển thị mức sử dụng hiện tại cho bộ nhớ+Swap
				     (Xem phần 5.5 để biết chi tiết)
 Memory.limit_in_bytes đặt/hiển thị giới hạn sử dụng bộ nhớ
 Memory.memsw.limit_in_bytes đặt/hiển thị giới hạn bộ nhớ+Swap sử dụng
 Memory.failcnt hiển thị số lần truy cập sử dụng bộ nhớ giới hạn
 Memory.memsw.failcnt hiển thị số lượng bộ nhớ+Giới hạn lượt truy cập hoán đổi
 Memory.max_usage_in_bytes hiển thị mức sử dụng bộ nhớ tối đa được ghi lại
 Memory.memsw.max_usage_in_bytes hiển thị bộ nhớ tối đa+Ghi lại mức sử dụng trao đổi
 Memory.soft_limit_in_bytes đặt/hiển thị giới hạn sử dụng bộ nhớ mềm
				     Núm này không có trên hệ thống CONFIG_PREEMPT_RT.
                                     Núm này không được dùng nữa và không nên
                                     đã sử dụng.
 Memory.stat hiển thị số liệu thống kê khác nhau
 Memory.use_hierarchy đã bật/hiển thị tài khoản phân cấp
                                     Núm này không được dùng nữa và không nên
                                     đã sử dụng.
 bộ nhớ.force_empty kích hoạt buộc phải lấy lại trang
 bộ nhớ.áp lực_level đặt thông báo áp suất bộ nhớ
                                     Núm này không được dùng nữa và không nên
                                     đã sử dụng.
 bộ nhớ.swappiness thiết lập/hiển thị tham số swappiness của vmscan
				     (Xem vm.swappiness của sysctl)
				     Mỗi núm memcg không tồn tại trong cgroup v2.
 Memory.move_charge_at_immigrate Núm này không được dùng nữa.
 bộ nhớ.oom_control đặt/hiển thị các điều khiển oom.
                                     Núm này không được dùng nữa và không nên
                                     đã sử dụng.
 Memory.numa_stat hiển thị số lượng bộ nhớ sử dụng trên mỗi numa
				     nút
 Memory.kmem.limit_in_bytes Nút không dùng nữa để thiết lập và đọc kernel
                                     giới hạn cứng bộ nhớ. Giới hạn cứng của hạt nhân không
                                     được hỗ trợ kể từ 5.16. Viết bất kỳ giá trị nào vào
                                     do tập tin sẽ không có bất kỳ tác dụng nào giống như nếu
                                     tham số kernel nokmem đã được chỉ định.
                                     Bộ nhớ hạt nhân vẫn được sạc và báo cáo
                                     bởi bộ nhớ.kmem.usage_in_bytes.
 Memory.kmem.usage_in_bytes hiển thị phân bổ bộ nhớ kernel hiện tại
 Memory.kmem.failcnt hiển thị số lượng sử dụng bộ nhớ kernel
				     lượt truy cập giới hạn
 Memory.kmem.max_usage_in_bytes hiển thị mức sử dụng bộ nhớ kernel tối đa được ghi lại

Memory.kmem.tcp.limit_in_bytes đặt/hiển thị giới hạn cứng cho bộ nhớ buf tcp
                                     Núm này không được dùng nữa và không nên
                                     đã sử dụng.
 Memory.kmem.tcp.usage_in_bytes hiển thị phân bổ bộ nhớ tcp buf hiện tại
                                     Núm này không được dùng nữa và không nên
                                     đã sử dụng.
 Memory.kmem.tcp.failcnt hiển thị số lượng sử dụng bộ nhớ buf tcp
				     lượt truy cập giới hạn
                                     Núm này không được dùng nữa và không nên
                                     đã sử dụng.
 Memory.kmem.tcp.max_usage_in_bytes hiển thị mức sử dụng bộ nhớ buf tcp tối đa được ghi lại
                                     Núm này không được dùng nữa và không nên
                                     đã sử dụng.
====================================================================================

1. Lịch sử
==========

Bộ điều khiển bộ nhớ có một lịch sử lâu dài. Yêu cầu bình luận cho bộ nhớ
bộ điều khiển được đăng bởi Balbir Singh [1]_. Vào thời điểm RFC được đăng
đã có một số triển khai để kiểm soát bộ nhớ. Mục tiêu của
RFC nhằm xây dựng sự đồng thuận và thống nhất về các tính năng tối thiểu cần có
để kiểm soát bộ nhớ. Bộ điều khiển RSS đầu tiên được đăng bởi Balbir Singh [2]_
vào tháng 2 năm 2007. Pavel Emelianov [3]_ [4]_ [5]_ kể từ đó đã đăng ba phiên bản
của bộ điều khiển RSS. Tại OLS, tại BoF quản lý tài nguyên mọi người nhé
đề nghị chúng tôi xử lý cả bộ đệm trang và RSS cùng nhau. Một yêu cầu khác là
được nâng lên để cho phép xử lý không gian người dùng của OOM. Bộ điều khiển bộ nhớ hiện tại là
ở phiên bản 6; nó kết hợp cả Trang được ánh xạ (RSS) và Trang chưa được ánh xạ
Kiểm soát bộ đệm [11]_.

2. Kiểm soát bộ nhớ
=================

Trí nhớ là một nguồn tài nguyên duy nhất theo nghĩa là nó hiện diện trong một giới hạn
số tiền. Nếu một tác vụ yêu cầu xử lý CPU nhiều, tác vụ đó có thể lan rộng
quá trình xử lý của nó trong khoảng thời gian hàng giờ, ngày, tháng hoặc năm, nhưng với
bộ nhớ, bộ nhớ vật lý tương tự cần được sử dụng lại để hoàn thành nhiệm vụ.

Việc thực hiện bộ điều khiển bộ nhớ đã được chia thành các giai đoạn. Những cái này
là:

1. Bộ điều khiển bộ nhớ
2. bộ điều khiển mlock(2)
3. Kiểm soát bộ nhớ người dùng hạt nhân và kiểm soát bản sàn
4. bộ điều khiển độ dài ánh xạ người dùng

Bộ điều khiển bộ nhớ là bộ điều khiển đầu tiên được phát triển.

2.1. Thiết kế
-----------

Cốt lõi của thiết kế là một bộ đếm được gọi là page_counter. các
page_counter theo dõi mức sử dụng bộ nhớ hiện tại và giới hạn của nhóm
các tiến trình liên quan đến bộ điều khiển. Mỗi cgroup có một bộ điều khiển bộ nhớ
cấu trúc dữ liệu cụ thể (mem_cgroup) được liên kết với nó.

2.2. Kế toán
---------------

.. code-block::
   :caption: Figure 1: Hierarchy of Accounting

		+--------------------+
		|  mem_cgroup        |
		|  (page_counter)    |
		+--------------------+
		 /            ^      \
		/             |       \
           +---------------+  |        +---------------+
           | mm_struct     |  |....    | mm_struct     |
           |               |  |        |               |
           +---------------+  |        +---------------+
                              |
                              + --------------+
                                              |
           +---------------+           +------+--------+
           | page          +---------->  page_cgroup|
           |               |           |               |
           +---------------+           +---------------+



Hình 1 thể hiện các khía cạnh quan trọng của bộ điều khiển

1. Việc hạch toán được thực hiện theo từng nhóm
2. Mỗi mm_struct biết nó thuộc nhóm nào
3. Mỗi trang có một con trỏ tới page_cgroup, từ đó biết được
   cgroup nó thuộc về

Việc tính toán được thực hiện như sau: mem_cgroup_charge_common() được gọi tới
thiết lập các cấu trúc dữ liệu cần thiết và kiểm tra xem cgroup đang được
tính phí là vượt quá giới hạn của nó. Nếu đúng như vậy thì lệnh đòi lại sẽ được gọi trên cgroup.
Thông tin chi tiết có thể được tìm thấy trong phần lấy lại của tài liệu này.
Nếu mọi việc suôn sẻ, một cấu trúc siêu dữ liệu trang có tên page_cgroup sẽ được
được cập nhật. page_cgroup có LRU riêng trên cgroup.
(*) cấu trúc page_cgroup được phân bổ tại thời điểm khởi động/cắm nóng bộ nhớ.

2.2.1 Chi tiết kế toán
------------------------

Tất cả các trang anon được ánh xạ (RSS) và các trang bộ đệm (Bộ đệm trang) đều được tính.
Một số trang không bao giờ có thể lấy lại được và sẽ không có trên LRU
không được tính. Chúng tôi chỉ quản lý các trang tài khoản dưới sự quản lý VM thông thường.

Các trang RSS được tính tại page_fault trừ khi chúng đã được tính
cho trước đó. Một trang tệp sẽ được coi là Bộ đệm trang khi nó
được chèn vào inode (xarray). Trong khi nó được ánh xạ vào các bảng trang của
quy trình, kế toán trùng lặp được tránh một cách cẩn thận.

Trang RSS không được tính khi nó chưa được ánh xạ hoàn toàn. Một trang PageCache là
không được tính khi nó bị xóa khỏi xarray. Ngay cả khi các trang RSS có đầy đủ
chưa được ánh xạ (bởi kswapd), chúng có thể tồn tại dưới dạng SwapCache trong hệ thống cho đến khi chúng
thực sự được giải phóng. SwapCaches như vậy cũng được tính.
Trang được hoán đổi sẽ được tính sau khi thêm vào swapcache.

Lưu ý: Kernel thực hiện swapin-readahead và đọc nhiều lần hoán đổi cùng một lúc.
Vì memcg của trang được ghi vào trao đổi bất kỳ memsw nào được kích hoạt, trang sẽ
được tính sau khi swapin.

Khi di chuyển trang, thông tin kế toán được lưu giữ.

Lưu ý: chúng tôi chỉ tài khoản các trang trên LRU vì mục đích của chúng tôi là kiểm soát số lượng
của các trang đã sử dụng; Các trang không có trên LRU có xu hướng nằm ngoài tầm kiểm soát từ chế độ xem VM.

2.3 Kế toán trang chia sẻ
--------------------------

Các trang được chia sẻ được tính dựa trên cách tiếp cận lần chạm đầu tiên. các
cgroup chạm vào trang đầu tiên sẽ được tính cho trang đó. Nguyên tắc
đằng sau cách tiếp cận này là một nhóm tích cực sử dụng
trang cuối cùng sẽ bị tính phí cho nó (một khi nó không bị tính phí từ
nhóm đã đưa nó vào -- điều này sẽ xảy ra do áp lực bộ nhớ).

2.4 Gia hạn Hoán đổi
--------------------------------------

Việc sử dụng Swap luôn được ghi lại cho mỗi nhóm. Tiện ích mở rộng hoán đổi cho phép bạn
đọc và giới hạn nó.

Khi CONFIG_SWAP được bật, các tệp sau sẽ được thêm vào.

- bộ nhớ.memsw.usage_in_bytes.
 - bộ nhớ.memsw.limit_in_bytes.

memsw có nghĩa là bộ nhớ + trao đổi. Việc sử dụng bộ nhớ + trao đổi bị giới hạn bởi
memsw.limit_in_bytes.

Ví dụ: Giả sử một hệ thống có 4G trao đổi. Một tác vụ phân bổ 6G bộ nhớ
(do nhầm lẫn) dưới giới hạn bộ nhớ 2G sẽ sử dụng tất cả trao đổi.
Trong trường hợp này, cài đặt memsw.limit_in_bytes=3G sẽ ngăn việc sử dụng trao đổi không đúng cách.
Bằng cách sử dụng giới hạn memsw, bạn có thể tránh được hệ thống OOM có thể do trao đổi gây ra
sự thiếu hụt.

2.4.1 tại sao 'bộ nhớ+hoán đổi' thay vì trao đổi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LRU(kswapd) toàn cầu có thể hoán đổi các trang tùy ý. Phương tiện hoán đổi
để di chuyển tài khoản từ bộ nhớ sang trao đổi...không có thay đổi nào trong cách sử dụng
bộ nhớ + trao đổi. Nói cách khác, khi chúng ta muốn hạn chế việc sử dụng trao đổi mà không cần
ảnh hưởng đến LRU toàn cầu, giới hạn bộ nhớ+trao đổi sẽ tốt hơn là chỉ giới hạn trao đổi từ
một quan điểm hệ điều hành.

2.4.2. Điều gì xảy ra khi một nhóm truy cập vào bộ nhớ.memsw.limit_in_bytes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi một nhóm truy cập vào bộ nhớ.memsw.limit_in_bytes, việc trao đổi là vô ích
trong nhóm này. Khi đó, việc hoán đổi sẽ không được thực hiện bởi tập tin và thường trình cgroup
bộ nhớ đệm bị loại bỏ. Nhưng như đã đề cập ở trên, LRU toàn cầu có thể thực hiện trao đổi bộ nhớ
từ đó đảm bảo trạng thái quản lý bộ nhớ của hệ thống được ổn định. Bạn không thể cấm
nó bởi cgroup.

2.5 Thu hồi
-----------

Mỗi nhóm duy trì một LRU cho mỗi nhóm có cấu trúc tương tự như
VM toàn cầu. Khi một nhóm vượt quá giới hạn, trước tiên chúng tôi sẽ thử
để lấy lại bộ nhớ từ nhóm để tạo khoảng trống cho nhóm mới
những trang mà cgroup đã chạm tới. Nếu việc thu hồi không thành công,
một quy trình OOM được gọi để chọn và loại bỏ tác vụ lớn nhất trong
cgroup. (Xem ZZ0000ZZ bên dưới.)

Thuật toán lấy lại chưa được sửa đổi cho các nhóm, ngoại trừ
các trang được chọn để thu hồi đến từ LRU trên mỗi nhóm
danh sách.

.. note::
   Reclaim does not work for the root cgroup, since we cannot set any
   limits on the root cgroup.

.. note::
   When panic_on_oom is set to "2", the whole system will panic.

Khi đăng ký trình thông báo sự kiện oom, sự kiện sẽ được gửi.
(Xem phần ZZ0000ZZ)

2.6 Khóa
-----------

Thứ tự khóa như sau::

folio_lock
    mm->page_table_lock hoặc chia pte_lock
      ánh xạ-> khóa i_page
        lruvec->lru_lock.

Per-node-per-memcgroup LRU (LRU riêng của nhóm) được bảo vệ bởi
lruvec->lru_lock; cờ folio LRU bị xóa trước
cách ly một trang khỏi LRU của nó dưới lruvec->lru_lock.

.. _cgroup-v1-memory-kernel-extension:

2.7 Mở rộng bộ nhớ hạt nhân
-----------------------------------------------

Với phần mở rộng bộ nhớ hạt nhân, Bộ điều khiển bộ nhớ có thể giới hạn
dung lượng bộ nhớ kernel được hệ thống sử dụng. Bộ nhớ hạt nhân về cơ bản là
khác với bộ nhớ người dùng, vì nó không thể bị hoán đổi, điều này làm cho nó
có thể DoS hệ thống bằng cách tiêu thụ quá nhiều tài nguyên quý giá này.

Theo mặc định, việc tính toán bộ nhớ hạt nhân được bật cho tất cả các nhóm bộ nhớ. Nhưng
nó có thể bị vô hiệu hóa trên toàn hệ thống bằng cách chuyển cgroup.memory=nokmem vào kernel
lúc khởi động. Trong trường hợp này, bộ nhớ kernel hoàn toàn không được tính đến.

Giới hạn bộ nhớ hạt nhân không được áp đặt cho nhóm gốc. Cách sử dụng cho root
cgroup có thể được tính hoặc không. Bộ nhớ được sử dụng được tích lũy vào
Memory.kmem.usage_in_bytes hoặc trong một bộ đếm riêng khi có ý nghĩa.
(hiện chỉ dành cho tcp).

Bộ đếm kmem chính được đưa vào bộ đếm chính nên phí kmem sẽ
cũng được hiển thị từ bộ đếm người dùng.

Hiện tại không có giới hạn mềm nào được triển khai cho bộ nhớ kernel. Đó là công việc tương lai
để kích hoạt thu hồi bản sàn khi đạt đến các giới hạn đó.

2.7.1 Tài nguyên bộ nhớ hạt nhân hiện tại được chiếm
-----------------------------------------------

ngăn xếp trang:
  mọi quá trình đều tiêu tốn một số trang ngăn xếp. Bằng cách hạch toán vào
  bộ nhớ kernel, chúng tôi ngăn không cho các tiến trình mới được tạo khi kernel
  mức sử dụng bộ nhớ quá cao.

trang phiến:
  các trang được phân bổ bởi bộ cấp phát SLAB hoặc SLUB đều được theo dõi. Một bản sao
  của mỗi kmem_cache được tạo mỗi lần chạm vào bộ đệm lần đầu tiên
  từ bên trong memcg. Việc tạo được thực hiện một cách lười biếng, vì vậy một số đối tượng vẫn có thể được
  bị bỏ qua trong khi bộ đệm đang được tạo. Tất cả các đối tượng trong một trang phiến nên
  thuộc về cùng một memcg. Điều này chỉ không giữ được khi một tác vụ được di chuyển sang một
  memcg khác nhau trong quá trình phân bổ trang bằng bộ đệm.

áp suất bộ nhớ ổ cắm:
  một số giao thức ổ cắm có áp lực bộ nhớ
  ngưỡng. Bộ điều khiển bộ nhớ cho phép chúng được điều khiển riêng lẻ
  mỗi cgroup, thay vì trên toàn cầu.

áp lực bộ nhớ tcp:
  áp lực bộ nhớ ổ cắm cho giao thức tcp.

2.7.2 Các trường hợp sử dụng phổ biến
----------------------

Vì bộ đếm "kmem" được nạp vào bộ đếm người dùng chính nên bộ nhớ kernel có thể
không bao giờ bị giới hạn hoàn toàn độc lập với bộ nhớ người dùng. Nói "U" là người dùng
giới hạn và "K" giới hạn kernel. Có ba cách có thể giới hạn
đặt:

U != 0, K = không giới hạn:
    Đây là cơ chế hạn chế memcg tiêu chuẩn đã có trước kmem
    kế toán. Bộ nhớ hạt nhân hoàn toàn bị bỏ qua.

U != 0, K < U:
    Bộ nhớ hạt nhân là một tập hợp con của bộ nhớ người dùng. Thiết lập này hữu ích trong
    triển khai trong đó tổng dung lượng bộ nhớ trên mỗi nhóm bị vượt quá.
    Việc vượt quá giới hạn bộ nhớ kernel chắc chắn không được khuyến khích, vì
    hộp vẫn có thể hết bộ nhớ không thể lấy lại được.
    Trong trường hợp này, quản trị viên có thể thiết lập K sao cho tổng của tất cả các nhóm là
    không bao giờ lớn hơn tổng bộ nhớ và tự do đặt U với cái giá phải trả là
    QoS.

    .. warning::
       In the current implementation, memory reclaim will NOT be triggered for
       a cgroup when it hits K while staying below U, which makes this setup
       impractical.

U != 0, K >= U:
    Vì phí kmem cũng sẽ được đưa đến bộ đếm của người dùng và việc thu hồi sẽ được thực hiện
    được kích hoạt cho cgroup cho cả hai loại bộ nhớ. Thiết lập này mang lại cho
    quản trị viên một cái nhìn thống nhất về bộ nhớ và nó cũng hữu ích cho những người chỉ
    muốn theo dõi việc sử dụng bộ nhớ kernel.

3. Giao diện người dùng
=================

Để sử dụng giao diện người dùng:

1. Kích hoạt tùy chọn CONFIG_CGROUPS và CONFIG_MEMCG
2. Chuẩn bị các nhóm (xem ZZ0000ZZ để biết thông tin cơ bản)::

# mount -t tmpfs không /sys/fs/cgroup
	# mkdir/sys/fs/cgroup/bộ nhớ
	# mount -t cgroup none /sys/fs/cgroup/memory -o bộ nhớ

3. Tạo nhóm mới và chuyển bash vào đó::

# mkdir /sys/fs/cgroup/bộ nhớ/0
	# echo $$ > /sys/fs/cgroup/memory/0/tasks

4. Vì bây giờ chúng ta đang ở trong nhóm 0 nên chúng ta có thể thay đổi giới hạn bộ nhớ::

# echo 4M > /sys/fs/cgroup/memory/0/memory.limit_in_bytes

Giới hạn bây giờ có thể được truy vấn::

# cat /sys/fs/cgroup/memory/0/memory.limit_in_bytes
	4194304

.. note::
   We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
   mega or gigabytes. (Here, Kilo, Mega, Giga are Kibibytes, Mebibytes,
   Gibibytes.)

.. note::
   We can write "-1" to reset the ``*.limit_in_bytes(unlimited)``.

.. note::
   We cannot set limits on the root cgroup any more.


Chúng tôi có thể kiểm tra việc sử dụng::

# cat /sys/fs/cgroup/memory/0/memory.usage_in_bytes
  1216512

Việc ghi thành công vào tệp này không đảm bảo cài đặt thành công
giới hạn này đối với giá trị được ghi vào tệp. Điều này có thể là do một
số yếu tố, chẳng hạn như làm tròn đến ranh giới trang hoặc tổng số
sự sẵn có của bộ nhớ trên hệ thống. Người dùng được yêu cầu đọc lại
tệp này sau khi ghi để đảm bảo giá trị được kernel cam kết ::

# echo 1 > bộ nhớ.limit_in_bytes
  Bộ nhớ # cat.limit_in_bytes
  4096

Trường Memory.failcnt cho biết số lần giới hạn cgroup là
vượt quá.

Tệp Memory.stat cung cấp thông tin kế toán. Bây giờ, số lượng
bộ đệm, RSS và các trang Hoạt động/Trang không hoạt động được hiển thị.

4. Kiểm tra
==========

Để kiểm tra các tính năng và cách triển khai, hãy xem memcg_test.txt.

Kiểm tra hiệu suất cũng rất quan trọng. Để xem chi phí hoạt động của bộ điều khiển bộ nhớ thuần túy,
thử nghiệm trên tmpfs sẽ cung cấp cho bạn số lượng chi phí nhỏ.
Ví dụ: tạo kernel trên tmpfs.

Khả năng mở rộng lỗi trang cũng rất quan trọng. Khi đo song song
kiểm tra lỗi trang, kiểm tra đa tiến trình có thể tốt hơn đa luồng
test vì nó có nhiễu của các đối tượng/trạng thái được chia sẻ.

Nhưng hai điều trên đang thử nghiệm những tình huống cực đoan.
Thử kiểm tra thông thường trong bộ điều khiển bộ nhớ luôn hữu ích.

.. _cgroup-v1-memory-test-troubleshoot:

4.1 Khắc phục sự cố
-------------------

Đôi khi người dùng có thể thấy rằng ứng dụng trong cgroup
bị chấm dứt bởi sát thủ OOM. Có một số nguyên nhân cho việc này:

1. Giới hạn nhóm quá thấp (quá thấp để làm bất cứ điều gì hữu ích)
2. Người dùng đang sử dụng bộ nhớ ẩn danh và tính năng trao đổi bị tắt hoặc quá thấp

Đồng bộ hóa theo sau echo 1 > /proc/sys/vm/drop_caches sẽ giúp loại bỏ
một số trang được lưu trong bộ đệm trong cgroup (trang bộ đệm trang).

Để biết điều gì xảy ra, hãy tắt OOM_Kill theo ZZ0000ZZ (bên dưới) và xem điều gì sẽ xảy ra
hữu ích.

.. _cgroup-v1-memory-test-task-migration:

4.2 Di chuyển tác vụ
------------------

Khi một tác vụ di chuyển từ nhóm này sang nhóm khác, phí của nó không
được chuyển tiếp theo mặc định. Các trang được phân bổ từ cgroup ban đầu vẫn
vẫn được tính phí cho nó, khoản phí sẽ bị giảm khi trang được giải phóng hoặc
được thu hồi.

Bạn có thể di chuyển các chi phí của một nhiệm vụ cùng với việc di chuyển nhiệm vụ.
Xem ZZ0000ZZ

4.3 Xóa một nhóm
---------------------

Một cgroup có thể bị xóa bởi rmdir, nhưng như đã thảo luận trong ZZ0000ZZ và ZZ0001ZZ, một cgroup có thể phải chịu một số phí
liên kết với nó, mặc dù tất cả các nhiệm vụ đã di chuyển khỏi nó. (vì
chúng tôi tính phí theo trang chứ không phải theo nhiệm vụ.)

Chúng tôi chuyển số liệu thống kê sang cấp độ gốc và không thay đổi khoản phí nào ngoại trừ việc không sạc
từ đứa trẻ.

Các khoản phí ghi trong thông tin hoán đổi không được cập nhật khi xóa cgroup.
Thông tin đã ghi sẽ bị loại bỏ và một nhóm sử dụng trao đổi (swapcache)
sẽ bị tính phí như chủ sở hữu mới của nó.

5. Linh tinh. giao diện
===================

5.1 lực_trống
---------------
Giao diện Memory.force_empty được cung cấp để làm trống việc sử dụng bộ nhớ của cgroup.
  Khi viết bất cứ điều gì vào đây::

# echo 0 > bộ nhớ.force_empty

cgroup sẽ được thu hồi và càng nhiều trang được thu hồi càng tốt.

Trường hợp sử dụng điển hình cho giao diện này là trước khi gọi rmdir().
  Mặc dù rmdir() ngoại tuyến memcg, nhưng memcg có thể vẫn ở đó do
  bộ nhớ đệm tập tin bị tính phí. Một số bộ đệm trang không còn sử dụng có thể tiếp tục bị tính phí cho đến khi
  áp lực bộ nhớ xảy ra. Nếu bạn muốn tránh điều đó, Force_empty sẽ hữu ích.

tập tin thống kê 5.2
-------------

Tệp Memory.stat bao gồm các số liệu thống kê sau:

* trạng thái cục bộ của nhóm trên mỗi bộ nhớ

=====================================================================================
    bộ đệm # of byte của bộ nhớ đệm trang.
    rss # of byte của bộ nhớ đệm trao đổi và ẩn danh (bao gồm
                    các trang lớn trong suốt).
    rss_huge # of byte của các trang lớn trong suốt ẩn danh.
    mapped_file # of byte của tệp được ánh xạ (bao gồm tmpfs/shmem)
    sự kiện sạc pgpgin # of vào nhóm bộ nhớ. Việc sạc
                    sự kiện xảy ra mỗi khi một trang được coi là được ánh xạ
                    trang anon (RSS) hoặc trang bộ đệm (Bộ đệm trang) vào nhóm.
    sự kiện giải nén pgpgout # of vào nhóm bộ nhớ. Việc sạc
                    sự kiện xảy ra mỗi khi một trang không được tính từ
                    cgroup.
    trao đổi # of byte sử dụng trao đổi
    đã hoán đổi # of byte trao đổi được lưu trong bộ nhớ
    byte # of bẩn đang chờ được ghi lại vào đĩa.
    ghi lại # of byte của tệp/bộ nhớ đệm ẩn danh được xếp hàng đợi để đồng bộ hóa với
                    đĩa.
    inactive_anon # of byte bộ nhớ đệm ẩn danh và trao đổi khi không hoạt động
                    Danh sách LRU.
    active_anon # of byte bộ nhớ đệm ẩn danh và trao đổi khi đang hoạt động
                    Danh sách LRU.
    inactive_file # of byte bộ nhớ được hỗ trợ bởi tệp và ẩn danh MADV_FREE
                    bộ nhớ (trang LazyFree) trên danh sách LRU không hoạt động.
    active_file # of byte của bộ nhớ được hỗ trợ bởi tệp trên danh sách LRU đang hoạt động.
    byte bộ nhớ # of không thể lấy lại được (mlocked, v.v.).
    =====================================================================================

* trạng thái xem xét thứ bậc (xem cài đặt bộ nhớ.use_hierarchy):

=================================================================================
    hierarchical_memory_limit # of giới hạn bộ nhớ liên quan đến
                              thứ bậc
                              trong đó nhóm bộ nhớ nằm
    hierarchical_memsw_limit # of byte bộ nhớ+giới hạn trao đổi liên quan đến
                              hệ thống phân cấp mà nhóm bộ nhớ nằm trong đó.

Total_<counter> Phiên bản # hierarchical của <counter>, trong đó
                              ngoài giá trị riêng của nhóm bao gồm
                              tổng của tất cả các giá trị phân cấp của trẻ em
                              <bộ đếm>, tức là tổng_cache
    =================================================================================

* tham số vm bổ sung (tùy thuộc vào CONFIG_DEBUG_VM):

======================================================================
    tham số nội bộ VM gần đây_rotated_anon. (xem mm/vmscan.c)
    tham số nội bộ VM gần đây_rotated_file. (xem mm/vmscan.c)
    tham số nội bộ VM gần đây_scanned_anon. (xem mm/vmscan.c)
    tham số nội bộ VM gần đây_scanned_file. (xem mm/vmscan.c)
    ======================================================================

.. hint::
	recent_rotated means recent frequency of LRU rotation.
	recent_scanned means recent # of scans to LRU.
	showing for better debug please see the code for meanings.

.. note::
	Only anonymous and swap cache memory is listed as part of 'rss' stat.
	This should not be confused with the true 'resident set size' or the
	amount of physical memory used by the cgroup.

	'rss + mapped_file" will give you resident set size of cgroup.

	Note that some kernel configurations might account complete larger
	allocations (e.g., THP) towards 'rss' and 'mapped_file', even if
	only some, but not all that memory is mapped.

	(Note: file and shmem may be shared among other cgroups. In that case,
	mapped_file is accounted only when the memory cgroup is owner of page
	cache.)

5.3 sự tráo đổi
--------------

Ghi đè /proc/sys/vm/swappiness cho nhóm cụ thể. Điều chỉnh được
trong nhóm gốc tương ứng với cài đặt hoán đổi chung.

Xin lưu ý rằng không giống như trong quá trình thu hồi toàn cầu, thu hồi giới hạn
buộc rằng 0 sự hoán đổi thực sự ngăn cản bất kỳ sự hoán đổi nào ngay cả khi
có một bộ lưu trữ trao đổi có sẵn. Điều này có thể dẫn đến sát thủ memcg OOM
nếu không có trang tập tin nào để lấy lại.

5.4 không thành công
-----------

Một nhóm bộ nhớ cung cấp các tệp bộ nhớ.failcnt và bộ nhớ.memsw.failcnt.
Failcnt(== số lần thất bại) này hiển thị số lần bộ đếm mức sử dụng
đạt đến giới hạn của nó. Khi một nhóm bộ nhớ đạt đến giới hạn, lỗi sẽ tăng lên và
bộ nhớ bên dưới nó sẽ được lấy lại.

Bạn có thể đặt lại Failcnt bằng cách ghi 0 vào tệp Failcnt::

# echo 0 > .../memory.failcnt

5,5 mức sử dụng_in_byte
------------------

Để đạt hiệu quả, giống như các thành phần kernel khác, cgroup bộ nhớ sử dụng một số tối ưu hóa
để tránh việc chia sẻ sai cacheline không cần thiết. use_in_bytes bị ảnh hưởng bởi
phương thức và không hiển thị giá trị 'chính xác' của việc sử dụng bộ nhớ (và trao đổi), đó là một lỗi mờ
giá trị để truy cập hiệu quả. (Tất nhiên, khi cần thiết, nó sẽ được đồng bộ hóa.)
Nếu bạn muốn biết mức sử dụng bộ nhớ chính xác hơn, bạn nên sử dụng RSS+CACHE(+SWAP)
giá trị trong bộ nhớ.stat (xem 5.2).

5,6 số_stat
-------------

Điều này tương tự như numa_maps nhưng hoạt động trên cơ sở mỗi memcg.  Đây là
hữu ích cho việc cung cấp khả năng hiển thị thông tin địa phương numa trong
một memcg vì các trang được phép phân bổ từ bất kỳ thiết bị vật lý nào
nút.  Một trong những trường hợp sử dụng là đánh giá hiệu suất ứng dụng bằng cách
kết hợp thông tin này với phân bổ CPU của ứng dụng.

Tệp numa_stat của mỗi memcg bao gồm "tổng", "tệp", "anon" và "không thể thu hồi"
số lượng trang trên mỗi nút bao gồm "hierarchical_<counter>" tổng hợp tất cả
các giá trị phân cấp của trẻ em ngoài giá trị riêng của memcg.

Định dạng đầu ra của Memory.numa_stat là::

tổng=<tổng số trang> N0=<nút 0 trang> N1=<nút 1 trang> ...
  file=<tổng số trang tệp> N0=<nút 0 trang> N1=<nút 1 trang> ...
  anon=<tổng số trang anon> N0=<nút 0 trang> N1=<nút 1 trang> ...
  unevictable=<tổng số trang anon> N0=<nút 0 trang> N1=<nút 1 trang> ...
  hierarchical_<counter>=<trang truy cập> N0=<nút 0 trang> N1=<nút 1 trang> ...

Tổng số "tổng" là tổng của tệp + anon + không thể thu hồi được.

6. Hỗ trợ phân cấp
====================

Bộ điều khiển bộ nhớ hỗ trợ hệ thống phân cấp sâu và tính toán phân cấp.
Hệ thống phân cấp được tạo bằng cách tạo các nhóm thích hợp trong
hệ thống tập tin cgroup. Ví dụ, hãy xem xét hệ thống tập tin cgroup sau
hệ thống phân cấp::

gốc
	     / |   \
            / |    \
	   a b c
		      | \
		      |  \
		      d e

Trong sơ đồ trên, khi tính năng tính toán phân cấp được kích hoạt, tất cả bộ nhớ
Việc sử dụng e, được tính từ tổ tiên của nó cho đến tận gốc (tức là c và gốc).
Nếu một trong các tổ tiên vượt quá giới hạn của nó, thuật toán lấy lại sẽ lấy lại
từ những công việc của tổ tiên và con cái của tổ tiên.

6.1 Kế toán và thu hồi thứ bậc
---------------------------------------

Kế toán phân cấp được bật theo mặc định. Vô hiệu hóa phân cấp
kế toán không còn được dùng nữa. Một nỗ lực để làm điều đó sẽ dẫn đến thất bại
và một cảnh báo được in ra dmesg.

Vì lý do tương thích, việc ghi 1 vào bộ nhớ.use_hierarchy sẽ luôn vượt qua ::

# echo 1 > bộ nhớ.use_hierarchy

7. Giới hạn mềm (DEPRECATED)
===========================

THIS LÀ DEPRECATED!

Giới hạn mềm cho phép chia sẻ bộ nhớ nhiều hơn. Ý tưởng đằng sau giới hạn mềm
là cho phép các nhóm điều khiển sử dụng nhiều bộ nhớ nếu cần, miễn là

Một. Không có tranh chấp về bộ nhớ
b. Họ không vượt quá giới hạn cứng của họ

Khi hệ thống phát hiện xung đột bộ nhớ hoặc bộ nhớ thấp, các nhóm điều khiển
bị đẩy trở lại giới hạn mềm của chúng. Nếu giới hạn mềm của mỗi điều khiển
nhóm rất cao, họ bị đẩy lùi càng nhiều càng tốt để thực hiện
đảm bảo rằng một nhóm điều khiển không làm các nhóm khác bị thiếu bộ nhớ.

Xin lưu ý rằng giới hạn mềm là tính năng cần nỗ lực tối đa; nó đi kèm với
không có gì đảm bảo, nhưng sẽ cố gắng hết sức để đảm bảo rằng khi bộ nhớ được
bị tranh cãi gay gắt, bộ nhớ được phân bổ dựa trên giới hạn mềm
gợi ý/thiết lập. Hiện tại việc thu hồi dựa trên giới hạn mềm được thiết lập sao cho
nó được gọi từ Balance_pgdat (kswapd).

7.1 Giao diện
-------------

Giới hạn mềm có thể được thiết lập bằng cách sử dụng các lệnh sau (trong ví dụ này chúng tôi
giả sử giới hạn mềm là 256 MiB)::

# echo 256M > bộ nhớ.soft_limit_in_bytes

Nếu chúng tôi muốn thay đổi điều này thành 1G, chúng tôi có thể sử dụng bất cứ lúc nào ::

# echo 1G > bộ nhớ.soft_limit_in_bytes

.. note::
       Soft limits take effect over a long period of time, since they involve
       reclaiming memory for balancing between memory cgroups

.. note::
       It is recommended to set the soft limit always below the hard limit,
       otherwise the hard limit will take precedence.

.. _cgroup-v1-memory-move-charges:

8. Di chuyển phí khi di chuyển nhiệm vụ (DEPRECATED!)
===============================================

THIS LÀ DEPRECATED!

Đọc bộ nhớ.move_charge_at_immigrate sẽ luôn trả về 0 và ghi
với nó sẽ luôn trả về -EINVAL.

9. Ngưỡng bộ nhớ
====================

Nhóm bộ nhớ thực hiện ngưỡng bộ nhớ bằng cách sử dụng thông báo cgroups
API (xem cgroups.txt). Nó cho phép đăng ký nhiều bộ nhớ và memsw
ngưỡng và nhận được thông báo khi nó vượt qua.

Để đăng ký một ngưỡng, ứng dụng phải:

- tạo một sự kiệnfd bằng cách sử dụng sự kiệnfd(2);
- mở bộ nhớ.usage_in_bytes hoặc bộ nhớ.memsw.usage_in_bytes;
- ghi chuỗi như "<event_fd> <fd of Memory.usage_in_bytes> <threshold>" vào
  cgroup.event_control.

Ứng dụng sẽ được thông báo qua sự kiện khi vượt quá mức sử dụng bộ nhớ
ngưỡng theo bất kỳ hướng nào.

Nó có thể áp dụng cho cgroup root và không root.

.. _cgroup-v1-memory-oom-control:

10. Điều khiển OOM (DEPRECATED)
============================

THIS LÀ DEPRECATED!

Tệp Memory.oom_control dành cho thông báo OOM và các điều khiển khác.

Nhóm bộ nhớ triển khai trình thông báo OOM bằng thông báo cgroup
API (Xem cgroups.txt). Nó cho phép đăng ký nhiều thông báo OOM
giao hàng và nhận được thông báo khi OOM xảy ra.

Để đăng ký trình thông báo, ứng dụng phải:

- tạo một sự kiệnfd bằng cách sử dụng sự kiệnfd(2)
 - mở tập tin bộ nhớ.oom_control
 - ghi chuỗi như "<event_fd> <fd of Memory.oom_control>" vào
   cgroup.event_control

Ứng dụng sẽ được thông báo qua eventfd khi OOM xảy ra.
Thông báo OOM không hoạt động đối với nhóm gốc.

Bạn có thể vô hiệu hóa OOM-killer bằng cách ghi "1" vào tệp Memory.oom_control, như:

#echo 1 > bộ nhớ.oom_control

Nếu OOM-killer bị tắt, các tác vụ trong cgroup sẽ bị treo/ngủ
trong hàng chờ đợi OOM của bộ nhớ cgroup khi họ yêu cầu bộ nhớ có trách nhiệm.

Để chạy chúng, bạn phải giảm trạng thái OOM của nhóm bộ nhớ bằng cách

* mở rộng giới hạn hoặc giảm mức sử dụng.

Để giảm mức sử dụng,

* giết một số nhiệm vụ.
	* chuyển một số nhiệm vụ sang nhóm khác bằng cách di chuyển tài khoản.
	* xóa một số tệp (trên tmpfs?)

Sau đó, các tác vụ đã dừng sẽ hoạt động trở lại.

Khi đọc, trạng thái hiện tại của OOM được hiển thị.

- oom_kill_disable 0 hoặc 1
	  (nếu 1, oom-killer bị tắt)
	- under_oom 0 hoặc 1
	  (nếu 1, nhóm bộ nhớ nằm dưới OOM, các tác vụ có thể bị dừng.)
        - bộ đếm số nguyên oom_kill
          Số lượng tiến trình thuộc nhóm này bị giết bởi bất kỳ
          loại sát thủ OOM.

11. Áp suất bộ nhớ (DEPRECATED)
================================

THIS LÀ DEPRECATED!

Thông báo mức áp suất có thể được sử dụng để theo dõi bộ nhớ
chi phí phân bổ; dựa trên áp lực, các ứng dụng có thể thực hiện
các chiến lược khác nhau để quản lý tài nguyên bộ nhớ của họ. Áp lực
cấp được xác định như sau:

Mức "thấp" có nghĩa là hệ thống đang lấy lại bộ nhớ cho bộ nhớ mới
phân bổ. Giám sát hoạt động thu hồi này có thể hữu ích cho
duy trì mức độ bộ đệm. Sau khi được thông báo, chương trình (thường
"Trình quản lý hoạt động") có thể phân tích vmstat và hành động trước (tức là.
tắt sớm các dịch vụ không quan trọng).

Mức "trung bình" có nghĩa là hệ thống đang sử dụng bộ nhớ trung bình
áp lực, hệ thống có thể đang thực hiện trao đổi, phân trang các bộ đệm tệp đang hoạt động,
v.v. Khi sự kiện này các ứng dụng có thể quyết định phân tích sâu hơn
vmstat/zoneinfo/memcg hoặc thống kê sử dụng bộ nhớ trong và giải phóng mọi
tài nguyên có thể dễ dàng được xây dựng lại hoặc đọc lại từ đĩa.

Mức "nghiêm trọng" có nghĩa là hệ thống đang hoạt động tích cực, đó là
sắp hết bộ nhớ (OOM) hoặc thậm chí sát thủ OOM trong kernel đang có mặt
cách để kích hoạt. Các ứng dụng nên làm bất cứ điều gì có thể để giúp
hệ thống. Có thể đã quá muộn để tham khảo vmstat hoặc bất kỳ nơi nào khác
số liệu thống kê, vì vậy bạn nên hành động ngay lập tức.

Theo mặc định, các sự kiện được truyền lên trên cho đến khi sự kiện được xử lý, tức là
các sự kiện không được truyền qua. Ví dụ: bạn có ba nhóm: A->B->C. bây giờ
bạn thiết lập trình xử lý sự kiện trên các nhóm A, B và C và giả sử nhóm C
gặp phải một số áp lực. Trong tình huống này, chỉ có nhóm C mới nhận được
thông báo, tức là nhóm A và B sẽ không nhận được. Điều này được thực hiện để tránh
việc "phát" tin nhắn quá mức, làm xáo trộn hệ thống và gây
đặc biệt tệ nếu chúng ta thiếu bộ nhớ hoặc bị đập. Nhóm B sẽ nhận được
chỉ thông báo nếu không có người xử lý sự kiện cho nhóm C.

Có ba chế độ tùy chọn chỉ định hành vi lan truyền khác nhau:

- "mặc định": đây là hành vi mặc định được chỉ định ở trên. Chế độ này là chế độ
   tương tự như việc bỏ qua tham số chế độ tùy chọn, được giữ nguyên bằng cách ngược lại
   khả năng tương thích.

- "hierarchy": các sự kiện luôn được truyền lên gốc, tương tự như mặc định
   hành vi, ngoại trừ việc truyền bá tiếp tục bất kể có
   trình xử lý sự kiện ở mỗi cấp độ, với chế độ "phân cấp". Ở trên
   ví dụ: nhóm A, B và C sẽ nhận được thông báo về áp lực bộ nhớ.

- "cục bộ": các sự kiện được truyền qua, tức là chúng chỉ nhận được thông báo khi
   áp lực bộ nhớ xảy ra trong memcg mà thông báo được đưa ra
   đã đăng ký. Trong ví dụ trên, nhóm C sẽ nhận được thông báo nếu
   đã đăng ký thông báo "cục bộ" và nhóm trải nghiệm bộ nhớ
   áp lực. Tuy nhiên, nhóm B sẽ không bao giờ nhận được thông báo, bất kể
   có trình xử lý sự kiện cho nhóm C hay không, nếu nhóm B được đăng ký
   thông báo địa phương.

Chế độ thông báo cấp độ và sự kiện ("phân cấp" hoặc "cục bộ", nếu cần) là
được chỉ định bởi một chuỗi được phân cách bằng dấu phẩy, tức là "thấp, phân cấp" chỉ định
phân cấp, chuyển tiếp, thông báo cho tất cả các memcgs tổ tiên. Thông báo
đó là hành vi mặc định, không chuyển tiếp, không chỉ định chế độ.
"trung bình, cục bộ" chỉ định thông báo chuyển qua cho cấp trung bình.

Tệp Memory. Pressure_level chỉ được sử dụng để thiết lập một sự kiệnfd. Đến
đăng ký một thông báo, một ứng dụng phải:

- tạo một sự kiệnfd bằng cách sử dụng sự kiệnfd(2);
- mở bộ nhớ.áp lực_level;
- ghi chuỗi dưới dạng "<event_fd> <fd của bộ nhớ. Pressure_level> <level[,mode]>"
  tới cgroup.event_control.

Ứng dụng sẽ được thông báo qua sự kiệnfd khi áp suất bộ nhớ ở mức
mức độ cụ thể (hoặc cao hơn). Các thao tác đọc/ghi vào
Memory. Pressure_level không được triển khai.

Bài kiểm tra:

Đây là một ví dụ về tập lệnh nhỏ để tạo một nhóm mới, thiết lập một
   giới hạn bộ nhớ, thiết lập thông báo trong cgroup và sau đó tạo thông báo con
   cgroup trải qua áp lực nghiêm trọng::

# cd /sys/fs/cgroup/bộ nhớ/
	# mkdir foo
	# cd foo
	Bộ nhớ # cgroup_event_listener.áp suất_mức thấp, phân cấp &
	# echo 8000000 > bộ nhớ.limit_in_bytes
	# echo 8000000 > bộ nhớ.memsw.limit_in_bytes
	# echo $$ > nhiệm vụ
	# dd if=/dev/zero | đọc x

(Hãy chờ đợi một loạt thông báo và cuối cùng, kẻ giết người sẽ
   kích hoạt.)

12. TODO
========

1. Trước tiên, hãy quét từng nhóm để lấy lại các trang không được chia sẻ
2. Hướng dẫn người điều khiển cách tính toán các trang chia sẻ
3. Bắt đầu cải tạo ở chế độ nền khi đạt đến giới hạn
   chưa đạt nhưng mức sử dụng đang ngày càng gần hơn

Bản tóm tắt
=======

Nhìn chung, bộ điều khiển bộ nhớ là một bộ điều khiển ổn định và đã được
được bình luận và thảo luận khá rộng rãi trong cộng đồng.

Tài liệu tham khảo
==========

.. [1] Singh, Balbir. RFC: Memory Controller, http://lwn.net/Articles/206697/
.. [2] Singh, Balbir. Memory Controller (RSS Control),
   http://lwn.net/Articles/222762/
.. [3] Emelianov, Pavel. Resource controllers based on process cgroups
   https://lore.kernel.org/r/45ED7DEC.7010403@sw.ru
.. [4] Emelianov, Pavel. RSS controller based on process cgroups (v2)
   https://lore.kernel.org/r/461A3010.90403@sw.ru
.. [5] Emelianov, Pavel. RSS controller based on process cgroups (v3)
   https://lore.kernel.org/r/465D9739.8070209@openvz.org

6. Menage, Paul. Nhóm điều khiển v10, ZZ0000ZZ
7. Vaidyanathan, Srinivasan, Nhóm kiểm soát: Kế toán và kiểm soát Pagecache
   hệ thống con (v3), ZZ0001ZZ
8. Singh, Balbir. Kết quả kiểm tra bộ điều khiển RSS v2 (lmbench),
   ZZ0002ZZ
9. Singh, Balbir. Kết quả bộ điều khiển RSS v2 AIM9
   ZZ0003ZZ
10. Singh, Balbir. Kết quả kiểm tra bộ điều khiển bộ nhớ v6,
    ZZ0004ZZ

.. [11] Singh, Balbir. Memory controller introduction (v6),
   https://lore.kernel.org/r/20070817084228.26003.12568.sendpatchset@balbir-laptop
.. [12] Corbet, Jonathan, Controlling memory use in cgroups,
   http://lwn.net/Articles/243795/
