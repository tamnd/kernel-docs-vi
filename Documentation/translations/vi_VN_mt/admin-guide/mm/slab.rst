.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/slab.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============================================
Hướng dẫn sử dụng ngắn gọn về bộ cấp phát sàn
========================================

Bộ cấp phát bản sàn bao gồm hỗ trợ gỡ lỗi đầy đủ (khi được xây dựng với
CONFIG_SLUB_DEBUG=y) nhưng nó bị tắt theo mặc định (trừ khi được tích hợp với
CONFIG_SLUB_DEBUG_ON=y).  Bạn chỉ có thể bật gỡ lỗi cho những mục đã chọn
tấm để tránh ảnh hưởng đến hiệu suất hệ thống tổng thể
có thể làm cho lỗi khó tìm hơn.

Để chuyển đổi gỡ lỗi, người ta có thể thêm tùy chọn ZZ0000ZZ
đến dòng lệnh kernel. Điều đó sẽ cho phép gỡ lỗi đầy đủ cho
tất cả các tấm.

Thông thường người ta sẽ sử dụng lệnh ZZ0000ZZ để lấy số liệu thống kê
dữ liệu và thực hiện các thao tác trên tấm. Theo mặc định chỉ có danh sách ZZ0001ZZ
tấm có dữ liệu trong đó. Xem "slabinfo -h" để có thêm tùy chọn khi
chạy lệnh. ZZ0002ZZ có thể được biên dịch bằng
::

gcc -o công cụ phiếninfo/mm/slabinfo.c

Một số chế độ hoạt động của ZZ0000ZZ yêu cầu gỡ lỗi slub đó
được kích hoạt trên dòng lệnh. F.e. sẽ không có thông tin theo dõi
khả dụng mà không cần gỡ lỗi và xác thực chỉ có thể một phần
được thực hiện nếu việc gỡ lỗi chưa được bật.

Một số cách sử dụng phức tạp hơn của Slab_debug:
-------------------------------------------

Các tham số có thể được cung cấp cho ZZ0000ZZ. Nếu không được chỉ định thì đầy đủ
gỡ lỗi được kích hoạt. Định dạng:

tấm_debug=<Tùy chọn gỡ lỗi>
	Kích hoạt tùy chọn cho tất cả các tấm

tấm_debug=<Tùy chọn gỡ lỗi>,<tên tấm1>,<tên tấm2>,...
	Chỉ bật tùy chọn cho các tấm được chọn (không có khoảng trắng
	sau dấu phẩy)

Có thể đưa ra nhiều khối tùy chọn cho tất cả các tấm hoặc các tấm được chọn, với
khối tùy chọn được phân cách bằng dấu ';'. Khối "tất cả các tấm" cuối cùng được áp dụng
cho tất cả các phiến ngoại trừ những phiến phù hợp với một trong các khối "tấm chọn". Tùy chọn
trong số các khối "select tấm" đầu tiên khớp với tên của tấm được áp dụng.

Các tùy chọn gỡ lỗi có thể có là::

F Kiểm tra tinh thần được bật (bật SLAB_DEBUG_CONSISTENCY_CHECKS
			Xin lỗi về vấn đề di sản của SLAB)
	Z Phân vùng màu đỏ
	P Ngộ độc (vật thể và phần đệm)
	U Theo dõi người dùng (miễn phí và phân bổ)
	T Trace (vui lòng chỉ sử dụng trên các tấm đơn)
	Dấu hiệu bộ lọc Enable Faillab cho bộ nhớ đệm
	O Tắt tính năng gỡ lỗi đối với các bộ nhớ đệm có
			gây ra đơn đặt hàng tấm tối thiểu cao hơn
	- Tắt tất cả việc gỡ lỗi (hữu ích nếu kernel bị lỗi
			được cấu hình với CONFIG_SLUB_DEBUG_ON)

F.e. để khởi động chỉ với việc kiểm tra độ tỉnh táo và phân vùng màu đỏ, người ta sẽ chỉ định ::

tấm_debug=FZ

Bạn đang cố gắng tìm sự cố trong bộ nhớ đệm của nha khoa? Thử::

tấm_debug=,nha khoa

để chỉ bật gỡ lỗi trên bộ nhớ đệm của nha khoa.  Bạn có thể sử dụng dấu hoa thị ở
cuối tên phiến, để bao gồm tất cả các phiến có cùng tiền tố.  cho
Ví dụ: đây là cách bạn có thể đầu độc bộ nhớ đệm của nha khoa cũng như tất cả kmalloc
tấm::

tấm_debug=P,kmalloc-*,dentry

Phân vùng và theo dõi màu đỏ có thể sắp xếp lại tấm.  Chúng ta chỉ có thể áp dụng kiểm tra độ chính xác
vào bộ đệm nha khoa với::

tấm_debug=F,nha khoa

Các tùy chọn gỡ lỗi có thể yêu cầu thứ tự bản sàn tối thiểu có thể tăng lên khi
kết quả của việc lưu trữ siêu dữ liệu (ví dụ: bộ nhớ đệm với đối tượng PAGE_SIZE
kích thước).  Điều này có khả năng cao hơn dẫn đến lỗi phân bổ bản sàn
trong các tình huống bộ nhớ thấp hoặc nếu bộ nhớ bị phân mảnh cao.  Đến
theo mặc định, tắt gỡ lỗi cho các bộ đệm như vậy, sử dụng ::

tấm_debug=O

Bạn có thể áp dụng các tùy chọn khác nhau cho danh sách tên bản sàn khác nhau bằng cách sử dụng các khối
của các lựa chọn. Điều này sẽ cho phép phân vùng màu đỏ cho nha khoa và theo dõi người dùng
kmalloc. Tất cả các bản khác sẽ không được kích hoạt bất kỳ tính năng gỡ lỗi nào::

tấm_debug=Z,dentry;U,kmalloc-*

Bạn cũng có thể bật các tùy chọn (ví dụ: kiểm tra độ tỉnh táo và đầu độc) cho tất cả bộ nhớ đệm
ngoại trừ một số được coi là quá quan trọng về hiệu suất và không cần thiết phải
được gỡ lỗi bằng cách chỉ định các tùy chọn gỡ lỗi chung, theo sau là danh sách tên bản sàn
với "-" làm tùy chọn::

tấm_debug=FZ;-,zs_handle,zspage

Trạng thái của từng tùy chọn gỡ lỗi cho một bản sàn có thể được tìm thấy trong các tệp tương ứng
dưới::

/sys/kernel/slab/<tên phiến>/

Nếu tệp chứa 1, tùy chọn được bật, 0 có nghĩa là bị tắt. Việc gỡ lỗi
các tùy chọn từ tham số ZZ0000ZZ dịch sang các tệp sau ::

F sự tỉnh táo_checks
	Z vùng đỏ
	chất độc P
	Bạn lưu trữ_user
	dấu vết T
	Một bài kiểm tra thất bại

tập tin failedlab có thể ghi được, do đó việc ghi 1 hoặc 0 sẽ bật hoặc tắt
tùy chọn khi chạy. Viết trả về -EINVAL nếu bộ đệm là bí danh.
Cẩn thận với việc truy tìm: Nó có thể tiết ra rất nhiều thông tin và không bao giờ dừng lại nếu
được sử dụng trên tấm sai.

Sáp nhập tấm
============

Nếu không có tùy chọn gỡ lỗi nào được chỉ định thì SLUB có thể hợp nhất các tấm tương tự lại với nhau
để giảm chi phí hoạt động và tăng độ nóng của bộ nhớ đệm của các đối tượng.
ZZ0000ZZ hiển thị những tấm nào được hợp nhất với nhau.

Xác nhận tấm
===============

SLUB có thể xác thực tất cả đối tượng nếu kernel được khởi động bằng Slab_debug. trong
để làm được điều đó bạn phải có công cụ ZZ0000ZZ. Sau đó bạn có thể làm
::

thông tin phiến -v

sẽ kiểm tra tất cả các đối tượng. Đầu ra sẽ được tạo vào nhật ký hệ thống.

Điều này cũng hoạt động theo cách hạn chế hơn nếu khởi động không có bản gỡ lỗi.
Trong trường hợp đó ZZ0000ZZ chỉ kiểm tra tất cả các đối tượng có thể truy cập được. Thông thường
chúng nằm trong các tấm cpu và các tấm một phần. Tấm đầy đủ không
được theo dõi bởi SLUB trong tình huống không gỡ lỗi.

Đạt được hiệu suất cao hơn
========================

Ở một mức độ nào đó, hiệu suất của SLUB bị hạn chế do cần phải sử dụng
list_lock thỉnh thoảng để xử lý các phần phiến. Chi phí đó là
được điều chỉnh bởi thứ tự phân bổ cho mỗi tấm. Việc phân bổ
có thể bị ảnh hưởng bởi các tham số kernel:

.. slab_min_objects=x		(default: automatically scaled by number of cpus)
.. slab_min_order=x		(default 0)
.. slab_max_order=x		(default 3 (PAGE_ALLOC_COSTLY_ORDER))

ZZ0000ZZ
	cho phép chỉ định ít nhất có bao nhiêu đối tượng phải vừa với một
	Slab để thứ tự phân bổ được chấp nhận.  trong
	slub chung sẽ có thể thực hiện số lượng này
	phân bổ trên một phiến mà không cần tham khảo tài nguyên tập trung
	(list_lock) nơi tranh chấp có thể xảy ra.

ZZ0000ZZ
	chỉ định thứ tự tối thiểu của tấm. Một hiệu ứng tương tự như
	ZZ0001ZZ.

ZZ0000ZZ
	đã chỉ định thứ tự mà ZZ0001ZZ không nên
	còn được kiểm tra nữa. Điều này rất hữu ích để tránh việc SLUB cố gắng
	tạo các trang đặt hàng siêu lớn để phù hợp với ZZ0002ZZ
	của một bộ đệm phiến với kích thước đối tượng lớn thành một bậc cao
	trang. Đặt tham số dòng lệnh
	ZZ0003ZZ (N > 0), cài đặt lực
	ZZ0004ZZ thành 0, nguyên nhân gây ra thứ tự tối thiểu có thể có của
	phân bổ tấm.

ZZ0000ZZ
        Cho phép áp dụng các chính sách bộ nhớ trên mỗi
        phân bổ. Điều này dẫn đến việc đặt vị trí chính xác hơn
        các đối tượng có thể dẫn đến việc giảm quyền truy cập
        đến các nút từ xa. Mặc định là chỉ áp dụng bộ nhớ
        chính sách ở cấp độ folio khi có được một folio mới
        hoặc một folio được lấy từ danh sách. Kích hoạt tính năng này
        tùy chọn làm giảm hiệu suất đường dẫn nhanh của bộ cấp phát bản sàn.

Đầu ra gỡ lỗi SLUB
=================

Đây là mẫu đầu ra gỡ lỗi slub ::

==========================================================================
 BUG kmalloc-8: Ghi đè Redzone bên phải
 ----------------------------------------------------------------------

INFO: 0xc90f6d28-0xc90f6d2b. Byte đầu tiên 0x00 thay vì 0xcc
 INFO: Cờ 0xc528c530=0x400000c3 inuse=61 fp=0xc90f6d58
 INFO: Đối tượng 0xc90f6d20 @offset=3360 fp=0xc90f6d58
 INFO: Được phân bổ trong get_modalias+0x61/0xf5 age=53 cpu=1 pid=554

Byte b4 (0xc90f6d10): 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ........ZZZZZZZZ
 Đối tượng (0xc90f6d20): 31 30 31 39 2e 30 30 35 1019.005
 Vùng đỏ (0xc90f6d28): 00 cc cc cc .
 Phần đệm (0xc90f6d50): 5a 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZ

[<c010523d>] dump_trace+0x63/0x1eb
   [<c01053df>] show_trace_log_lvl+0x1a/0x2f
   [<c010601d>] show_trace+0x12/0x14
   [<c0106035>] dump_stack+0x16/0x18
   [<c017e0fa>] object_err+0x143/0x14b
   [<c017e2cc>] check_object+0x66/0x234
   [<c017eb43>] __slab_free+0x239/0x384
   [<c017f446>] kfree+0xa6/0xc6
   [<c02e2335>] get_modalias+0xb9/0xf5
   [<c02e23b7>] dmi_dev_uevent+0x27/0x3c
   [<c027866a>] dev_uevent+0x1ad/0x1da
   [<c0205024>] kobject_uevent_env+0x20a/0x45b
   [<c020527f>] kobject_uevent+0xa/0xf
   [<c02779f1>] store_uevent+0x4f/0x58
   [<c027758e>] dev_attr_store+0x29/0x2f
   [<c01bec4f>] sysfs_write_file+0x16e/0x19c
   [<c0183ba7>] vfs_write+0xd1/0x15a
   [<c01841d7>] sys_write+0x3d/0x72
   [<c0104112>] sysenter_past_esp+0x5f/0x99
   [<b7f7b410>] 0xb7f7b410
   ==========================

FIX kmalloc-8: Khôi phục Redzone 0xc90f6d28-0xc90f6d2b=0xcc

Nếu SLUB gặp một đối tượng bị hỏng (việc phát hiện đầy đủ cần có kernel
được khởi động bằng Slab_debug) thì kết quả đầu ra sau sẽ bị loại bỏ
vào nhật ký hệ thống:

1. Mô tả vấn đề gặp phải

Đây sẽ là một thông báo trong nhật ký hệ thống bắt đầu bằng::

====================================================
     BUG <slab cache bị ảnh hưởng>: <Đã xảy ra lỗi gì>
     -----------------------------------------------

INFO: <bắt đầu tham nhũng>-<kết thúc tham nhũng> <thông tin thêm>
     INFO: Sàn <địa chỉ> <thông tin sàn>
     INFO: Đối tượng <địa chỉ> <thông tin đối tượng>
     INFO: Được phân bổ trong <hàm hạt nhân> age=<jiffies kể từ khi được phân bổ> cpu=<được phân bổ bởi
	cpu> pid=<pid của tiến trình>
     INFO: Được giải phóng trong <hàm kernel> age=<jiffies kể từ khi miễn phí> cpu=<được giải phóng bởi cpu>
	pid=<pid của tiến trình>

(Phân bổ đối tượng / thông tin miễn phí chỉ khả dụng nếu SLAB_STORE_USER được
   thiết lập cho tấm. tấm_debug đặt tùy chọn đó)

2. Nội dung đối tượng nếu có đối tượng có liên quan.

Các loại dòng khác nhau có thể đi theo dòng BUG SLUB:

Byte b4 <địa chỉ> : <byte>
	Hiển thị một vài byte trước đối tượng nơi phát hiện sự cố.
	Có thể hữu ích nếu tham nhũng không dừng lại khi bắt đầu
	đối tượng.

Đối tượng <địa chỉ> : <byte>
	Các byte của đối tượng. Nếu đối tượng không hoạt động thì byte
	thường chứa các giá trị độc hại. Bất kỳ giá trị không độc nào đều hiển thị một
	tham nhũng bằng cách viết sau khi miễn phí.

Vùng đỏ <địa chỉ> : <byte>
	Redzone theo dõi đối tượng. Redzone được sử dụng để phát hiện
	viết sau đối tượng. Tất cả các byte phải luôn giống nhau
	giá trị. Nếu có bất kỳ sai lệch nào thì đó là do việc ghi sau
	ranh giới đối tượng.

(Thông tin Redzone chỉ khả dụng nếu SLAB_RED_ZONE được đặt.
	tấm_debug đặt tùy chọn đó)

Phần đệm <địa chỉ> : <byte>
	Dữ liệu không sử dụng để lấp đầy khoảng trống để lấy đối tượng tiếp theo
	căn chỉnh đúng cách. Trong trường hợp gỡ lỗi, chúng tôi đảm bảo rằng có
	ít nhất 4 byte đệm. Điều này cho phép phát hiện việc ghi
	trước đối tượng.

3. Một ngăn xếp

Stackdump mô tả vị trí phát hiện lỗi. Nguyên nhân
   tham nhũng có thể được tìm thấy nhiều hơn bằng cách nhìn vào chức năng
   được cấp phát hoặc giải phóng đối tượng.

4. Báo cáo cách giải quyết vấn đề nhằm đảm bảo việc tiếp tục được thực hiện
   hoạt động của hệ thống.

Đây là những thông báo trong nhật ký hệ thống bắt đầu bằng::

FIX <slab cache bị ảnh hưởng>: <đã thực hiện hành động khắc phục>

Trong mẫu SLUB ở trên nhận thấy rằng Redzone của một đối tượng đang hoạt động có
   bị ghi đè. Ở đây một chuỗi 8 ký tự được viết vào một tấm bảng
   có độ dài 8 ký tự. Tuy nhiên, chuỗi 8 ký tự cần có
   kết thúc bằng 0. Số 0 đó đã ghi đè byte đầu tiên của trường Redzone.
   Sau khi báo cáo chi tiết sự cố, FIX SLUB xuất hiện thông báo
   cho chúng tôi biết rằng SLUB đã khôi phục Redzone về giá trị phù hợp và sau đó
   hoạt động của hệ thống vẫn tiếp tục.

Hoạt động khẩn cấp
====================

Có thể bật tính năng gỡ lỗi tối thiểu (chỉ kiểm tra độ chính xác) bằng cách khởi động với ::

tấm_debug=F

Điều này nói chung là đủ để kích hoạt các tính năng phục hồi của slub
điều này sẽ giữ cho hệ thống hoạt động ngay cả khi một thành phần kernel xấu sẽ
giữ các đồ vật bị hỏng. Điều này có thể quan trọng đối với các hệ thống sản xuất.
Hiệu suất sẽ bị ảnh hưởng bởi việc kiểm tra độ chính xác và sẽ có
dòng thông báo lỗi liên tục vào nhật ký hệ thống nhưng không có bộ nhớ bổ sung
sẽ được sử dụng (không giống như gỡ lỗi hoàn toàn).

Không có đảm bảo. Thành phần kernel vẫn cần được sửa. Hiệu suất
có thể được tối ưu hóa hơn nữa bằng cách xác định vị trí tấm bị hỏng
và chỉ bật gỡ lỗi cho bộ đệm đó

Tức là::

tấm_debug=F,nha khoa

Nếu lỗi xảy ra do viết sau khi kết thúc đối tượng thì nó
có thể nên kích hoạt Redzone để tránh làm hỏng phần đầu
của các đối tượng khác::

tấm_debug=FZ,nha khoa

Chế độ và sơ đồ bản đồ mở rộng
===================================

Công cụ ZZ0000ZZ có chế độ 'mở rộng' ('-X') đặc biệt bao gồm:
 - Tổng số Slabcache
 - Các tấm được sắp xếp theo kích thước (tối đa -N <num> tấm, mặc định 1)
 - Các tấm được sắp xếp theo mức độ mất (tối đa -N <num> tấm, mặc định 1)

Ngoài ra, ở chế độ này ZZ0000ZZ không tự động chia tỷ lệ
kích thước (G/M/K) và báo cáo mọi thứ theo byte (chức năng này là
cũng có sẵn cho các chế độ thông tin phiến khác thông qua tùy chọn '-B'), điều này làm cho
báo cáo chính xác và chính xác hơn. Hơn nữa, trong ý nghĩa nào đó `-X'
Chế độ này cũng đơn giản hóa việc phân tích trạng thái của tấm, bởi vì nó
đầu ra có thể được vẽ bằng tập lệnh ZZ0001ZZ. Vì vậy nó
đẩy việc phân tích từ việc xem qua các con số (tấn số)
đến một thứ dễ dàng hơn -- phân tích trực quan.

Để tạo đồ thị:

a) thu thập các bản ghi mở rộng của Slabinfo, ví dụ::

trong khi [ 1 ]; làm thông tin phiến diện -X >> FOO_STATS; ngủ 1; xong

b) chuyển (-s) tệp thống kê sang tập lệnh ZZ0000ZZ::

phiếninfo-gnuplot.sh FOO_STATS [FOO_STATS2 .. FOO_STATSN]

Tập lệnh ZZ0000ZZ sẽ xử lý trước các bản ghi đã thu thập
   và tạo 3 tệp png (và 3 tệp bộ đệm tiền xử lý) cho mỗi STATS
   tập tin:
   - Tổng số Slabcache: FOO_STATS-totals.png
   - Các tấm được sắp xếp theo kích thước: FOO_STATS-slabs-by-size.png
   - Các tấm được sắp xếp theo mức độ mất: FOO_STATS-slabs-by-loss.png

Một trường hợp sử dụng khác khi ZZ0000ZZ có thể hữu ích là khi bạn
cần so sánh hành vi của các tấm "trước" và "sau" một số mã
sửa đổi.  Để giúp bạn, tập lệnh ZZ0001ZZ
có thể 'hợp nhất' các phần ZZ0002ZZ từ các phần khác nhau
số đo. Để so sánh trực quan N lô:

a) Thu thập bao nhiêu file STATS1, STATS2, .. STATSN tùy theo nhu cầu::

trong khi [ 1 ]; làm thông tin phiến -X >> STATS<X>; ngủ 1; xong

b) Xử lý trước các tệp STATS đó::

phiếninfo-gnuplot.sh STATS1 STATS2 .. STATSN

c) Thực thi ZZ0000ZZ ở chế độ '-t', chuyển tất cả
   đã tạo \*-totals được xử lý trước::

tấminfo-gnuplot.sh -t STATS1-tổng STATS2-tổng .. STATSN-tổng

Điều này sẽ tạo ra một âm mưu duy nhất (tệp png).

Dự kiến, các lô có thể lớn nên sẽ có một số biến động hoặc đột biến nhỏ
   có thể không được chú ý. Để giải quyết vấn đề đó, ZZ0000ZZ có hai
   các tùy chọn để 'phóng to'/'thu nhỏ':

a) ZZ0000ZZ -- ghi đè chiều rộng và chiều cao mặc định của hình ảnh
   b) ZZ0001ZZ -- chỉ định một loạt mẫu sẽ sử dụng (ví dụ:
      trong trường hợp ZZ0002ZZ, việc sử dụng phạm vi ZZ0003ZZ sẽ chỉ vẽ đồ thị các mẫu được thu thập từ thứ 40 đến
      giây thứ 60).


Tệp gỡ lỗiFS cho SLUB
======================

Để biết thêm thông tin về trạng thái hiện tại của bộ đệm SLUB với tính năng theo dõi người dùng
tùy chọn gỡ lỗi được bật, các tệp debugfs có sẵn, thường ở dưới
/sys/kernel/debug/slab/<cache>/ (chỉ được tạo cho bộ đệm có người dùng được kích hoạt
theo dõi). Có 2 loại tệp này với cách gỡ lỗi sau
thông tin:

1. phân bổ_traces::

In thông tin về dấu vết phân bổ duy nhất của hiện tại
    các đối tượng được phân bổ. Đầu ra được sắp xếp theo tần số của từng dấu vết.

Thông tin ở đầu ra:
    Số lượng đối tượng, chức năng cấp phát, khả năng lãng phí bộ nhớ của
    đối tượng kmalloc (tổng/mỗi đối tượng), tốc độ tối thiểu/trung bình/tối đa
    kể từ khi phân bổ, phạm vi pid của các quy trình phân bổ, mặt nạ cpu của
    phân bổ cpu, mặt nạ nút numa của nguồn gốc bộ nhớ và dấu vết ngăn xếp.

Ví dụ:::

338 pci_alloc_dev+0x2c/0xa0 lãng phí=521872/1544 tuổi=290837/291891/293509 pid=1 cpus=106 nút=0-1
        __kmem_cache_alloc_node+0x11f/0x4e0
        kmalloc_trace+0x26/0xa0
        pci_alloc_dev+0x2c/0xa0
        pci_scan_single_device+0xd2/0x150
        pci_scan_slot+0xf7/0x2d0
        pci_scan_child_bus_extend+0x4e/0x360
        acpi_pci_root_create+0x32e/0x3b0
        pci_acpi_scan_root+0x2b9/0x2d0
        acpi_pci_root_add.cold.11+0x110/0xb0a
        acpi_bus_attach+0x262/0x3f0
        device_for_each_child+0xb7/0x110
        acpi_dev_for_each_child+0x77/0xa0
        acpi_bus_attach+0x108/0x3f0
        device_for_each_child+0xb7/0x110
        acpi_dev_for_each_child+0x77/0xa0
        acpi_bus_attach+0x108/0x3f0

2. free_traces::

In thông tin về dấu vết giải phóng duy nhất của vùng hiện được phân bổ
    đồ vật. Do đó, dấu vết giải phóng đến từ vòng đời trước đó của
    đối tượng và được báo cáo là không có sẵn cho các đối tượng được phân bổ lần đầu tiên
    thời gian. Đầu ra được sắp xếp theo tần số của từng dấu vết.

Thông tin ở đầu ra:
    Số lượng đối tượng, chức năng giải phóng, độ giật tối thiểu/trung bình/tối đa kể từ khi rảnh rỗi,
    phạm vi pid của các quy trình giải phóng, mặt nạ CPU của CPU giải phóng và dấu vết ngăn xếp.

Ví dụ:::

1980 <không có sẵn> tuổi=4294912290 pid=0 cpus=0
    51 acpi_ut_update_ref_count+0x6a6/0x782 tuổi=236886/237027/237772 pid=1 cpus=1
	kfree+0x2db/0x420
	acpi_ut_update_ref_count+0x6a6/0x782
	acpi_ut_update_object_reference+0x1ad/0x234
	acpi_ut_remove_reference+0x7d/0x84
	acpi_rs_get_prt_method_data+0x97/0xd6
	acpi_get_irq_routing_table+0x82/0xc4
	acpi_pci_irq_find_prt_entry+0x8e/0x2e0
	acpi_pci_irq_lookup+0x3a/0x1e0
	acpi_pci_irq_enable+0x77/0x240
	pcibios_enable_device+0x39/0x40
	do_pci_enable_device.part.0+0x5d/0xe0
	pci_enable_device_flags+0xfc/0x120
	pci_enable_device+0x13/0x20
	virtio_pci_probe+0x9e/0x170
	local_pci_probe+0x48/0x80
	pci_device_probe+0x105/0x1c0

Christoph Lameter, ngày 30 tháng 5 năm 2007
Sergey Senozhatsky, ngày 23 tháng 10 năm 2015
