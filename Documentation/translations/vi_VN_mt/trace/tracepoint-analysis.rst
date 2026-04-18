.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/tracepoint-analysis.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================================================
Lưu ý về phân tích hành vi bằng cách sử dụng sự kiện và điểm theo dõi
=========================================================
:Tác giả: Mel Gorman (thông tin PCL chủ yếu dựa vào email từ Ingo Molnar)

1. Giới thiệu
===============

Tracepoint (xem Tài liệu/trace/tracepoints.rst) có thể được sử dụng mà không cần
tạo các mô-đun hạt nhân tùy chỉnh để đăng ký các hàm thăm dò bằng sự kiện
truy tìm cơ sở hạ tầng.

Nói một cách đơn giản, các điểm theo dõi thể hiện các sự kiện quan trọng có thể
được thực hiện cùng với các điểm theo dõi khác để xây dựng một "Bức tranh lớn" về
những gì đang xảy ra trong hệ thống. Có một số lượng lớn các phương pháp để
thu thập và giải thích những sự kiện này. Thiếu bất kỳ phương pháp thực hành tốt nhất hiện tại nào,
tài liệu này mô tả một số phương pháp có thể được sử dụng.

Tài liệu này giả định rằng các debugf được cài đặt trên /sys/kernel/debug và
các tùy chọn theo dõi thích hợp đã được cấu hình trong kernel. Đó là
giả định rằng công cụ/hoàn thiện công cụ PCL đã được cài đặt và nằm trong đường dẫn của bạn.

2. Liệt kê các sự kiện có sẵn
===========================

2.1 Tiện ích tiêu chuẩn
----------------------

Tất cả các sự kiện có thể xảy ra đều được hiển thị từ /sys/kernel/tracing/events. Đơn giản thôi
đang gọi::

$ tìm /sys/kernel/tracing/events -type d

sẽ đưa ra một dấu hiệu hợp lý về số lượng sự kiện có sẵn.

2.2 PCL (Bộ đếm hiệu suất cho Linux)
----------------------------------------

Khám phá và liệt kê tất cả các bộ đếm và sự kiện, bao gồm cả dấu vết,
có sẵn với công cụ hoàn hảo. Lấy một danh sách các sự kiện có sẵn là một
trường hợp đơn giản của::

danh sách hoàn hảo $ 2>&1 | dấu vết grep
  ext4:ext4_free_inode [Sự kiện theo dõi]
  ext4:ext4_request_inode [Sự kiện theo dõi]
  ext4:ext4_allocate_inode [Sự kiện Tracepoint]
  ext4:ext4_write_begin [Sự kiện theo dõi]
  ext4:ext4_ordered_write_end [Sự kiện theo dõi]
  [ .... đầu ra còn lại bị cắt .... ]


3. Kích hoạt sự kiện
==================

3.1 Kích hoạt sự kiện trên toàn hệ thống
------------------------------

Xem Documentation/trace/events.rst để biết mô tả thích hợp về cách các sự kiện diễn ra
có thể được kích hoạt trên toàn hệ thống. Một ví dụ ngắn về việc kích hoạt tất cả các sự kiện liên quan
để phân bổ trang sẽ trông giống như::

$ cho tôi trong ZZ0000ZZ; làm echo 1 > $i; xong

3.2 Kích hoạt sự kiện toàn hệ thống bằng SystemTap
---------------------------------------------

Trong SystemTap, có thể truy cập các dấu vết bằng hàm kernel.trace()
gọi. Sau đây là ví dụ báo cáo cứ 5 giây một lần những quy trình nào
đang phân bổ các trang.
::

trang toàn cầu_allocs

thăm dò kernel.trace("mm_page_alloc") {
  	page_allocs[execname()]++
  }

hàm print_count() {
  	printf ("%-25s %-s\n", "#Pages được phân bổ", "Tên quy trình")
  	foreach (proc trong page_allocs-)
  		printf("%-25d %s\n", page_allocs[proc], proc)
  	printf ("\n")
  	xóa trang_allocs
  }

bộ đếm thời gian thăm dò.s(5) {
          print_count()
  }

3.3 Kích hoạt sự kiện trên toàn hệ thống với PCL
---------------------------------------

Bằng cách chỉ định khóa chuyển -a và phân tích giấc ngủ, các sự kiện trên toàn hệ thống
trong một khoảng thời gian có thể được kiểm tra.
::

$ chỉ số hoàn hảo -a \
	-e kmem:mm_page_alloc -e kmem:mm_page_free \
	-e kmem:mm_page_free_batched \
	ngủ 10
 Thống kê bộ đếm hiệu suất cho 'ngủ 10':

9630 km:mm_page_alloc
           2143 km:mm_page_free
           7424 km:mm_page_free_batched

10,002577764 giây đã trôi qua

Tương tự, người ta có thể thực thi shell và thoát nó theo ý muốn để nhận báo cáo
tại thời điểm đó

3.4 Kích hoạt sự kiện cục bộ
------------------------

Documentation/trace/ftrace.rst mô tả cách bật các sự kiện trên mỗi luồng
cơ sở sử dụng set_ftrace_pid.

3.5 Hỗ trợ sự kiện địa phương với PCL
-----------------------------------

Các sự kiện có thể được kích hoạt và theo dõi trong suốt thời gian của một quá trình trên thiết bị cục bộ
cơ sở sử dụng PCL như sau.
::

$ chỉ số hoàn hảo -e kmem:mm_page_alloc -e kmem:mm_page_free \
		 -e kmem:mm_page_free_batched ./hackbench 10
  Thời gian: 0,909

Thống kê bộ đếm hiệu suất cho './hackbench 10':

17803 km:mm_page_alloc
          12398 km:mm_page_free
           4827 km:mm_page_free_batched

Thời gian trôi qua 0,973913387 giây

4. Lọc sự kiện
==================

Documentation/trace/ftrace.rst trình bày chi tiết về cách lọc các sự kiện trong
ftrace.  Rõ ràng sử dụng grep và awk của trace_pipe cũng là một lựa chọn
như bất kỳ tập lệnh nào đọc trace_pipe.

5. Phân tích phương sai sự kiện với PCL
=====================================

Bất kỳ khối lượng công việc nào cũng có thể thể hiện sự khác biệt giữa các lần chạy và điều đó có thể quan trọng
biết độ lệch chuẩn là gì. Nhìn chung, việc này được giao phó cho
nhà phân tích hiệu suất để làm điều đó bằng tay. Trong trường hợp sự kiện rời rạc
những lần xuất hiện sẽ hữu ích cho nhà phân tích hiệu suất thì có thể sử dụng tính hoàn hảo.
::

$ chỉ số hoàn hảo --repeat 5 -e kmem:mm_page_alloc -e kmem:mm_page_free
			-e kmem:mm_page_free_batched ./hackbench 10
  Thời gian: 0,890
  Thời gian: 0,895
  Thời gian: 0,915
  Thời gian: 1,001
  Thời gian: 0,899

Thống kê bộ đếm hiệu suất cho './hackbench 10' (5 lần chạy):

16630 km:mm_page_alloc (+- 3,542% )
          11486 km:mm_page_free (+- 4,771% )
           4730 km:mm_page_free_batched (+- 2,325% )

Thời gian trôi qua 0,982653002 giây (+- 1,448%)

Trong trường hợp cần có một số sự kiện cấp cao hơn phụ thuộc vào một số
tổng hợp các sự kiện rời rạc thì cần phải phát triển một kịch bản.

Sử dụng --repeat, cũng có thể xem các sự kiện đang biến động như thế nào
thời gian trên toàn hệ thống bằng cách sử dụng -a và ngủ.
::

$ chỉ số hoàn hảo -e kmem:mm_page_alloc -e kmem:mm_page_free \
		-e kmem:mm_page_free_batched \
		-a --repeat 10 \
		ngủ 1
  Thống kê bộ đếm hiệu suất cho 'ngủ 1' (10 lần chạy):

1066 km:mm_page_alloc (+- 26,148% )
            182 km:mm_page_free (+- 5,464% )
            890 km:mm_page_free_batched (+- 30,079% )

Thời gian đã trôi qua là 1,002251757 giây (+- 0,005%)

6. Phân tích cấp cao hơn với tập lệnh trợ giúp
============================================

Khi sự kiện được bật, các sự kiện đang kích hoạt có thể được đọc từ
/sys/kernel/tracing/trace_pipe ở định dạng mà con người có thể đọc được mặc dù là nhị phân
các tùy chọn cũng tồn tại. Bằng cách xử lý hậu kỳ đầu ra, thông tin thêm có thể
được thu thập trực tuyến khi thích hợp. Ví dụ về xử lý hậu kỳ có thể bao gồm

- Đọc thông tin từ /proc cho PID đã kích hoạt sự kiện
  - Bắt nguồn một sự kiện cấp cao hơn từ một chuỗi các sự kiện cấp thấp hơn.
  - Tính toán độ trễ giữa hai sự kiện

Tài liệu/trace/postprocess/trace-pagealloc-postprocess.pl là một ví dụ
tập lệnh có thể đọc trace_pipe từ STDIN hoặc bản sao của dấu vết. Khi sử dụng
trực tuyến, nó có thể bị gián đoạn một lần để tạo báo cáo mà không cần thoát
và hai lần để thoát.

Nói một cách đơn giản, tập lệnh chỉ đọc STDIN và đếm các sự kiện nhưng nó
cũng có thể làm nhiều hơn như

- Rút ra các sự kiện cấp cao từ nhiều sự kiện cấp thấp. Nếu một số trang
    được giải phóng cho bộ cấp phát chính khỏi danh sách trên mỗi CPU, nó sẽ nhận ra
    đó là một cống cho mỗi CPU mặc dù không có dấu vết cụ thể
    cho sự kiện đó
  - Nó có thể tổng hợp dựa trên PID hoặc số tiến trình riêng lẻ
  - Trong trường hợp bộ nhớ bị phân mảnh bên ngoài, nó sẽ báo cáo
    về việc sự kiện phân mảnh là nghiêm trọng hay trung bình.
  - Khi nhận được sự kiện về PID, nó có thể ghi lại cha mẹ là ai
    rằng nếu số lượng lớn các sự kiện xảy ra trong thời gian rất ngắn
    quy trình, quy trình cha chịu trách nhiệm tạo ra tất cả các trình trợ giúp
    có thể được xác định

7. Phân tích cấp độ thấp hơn với PCL
================================

Cũng có thể có yêu cầu xác định những chức năng nào trong một chương trình
đang tạo ra các sự kiện trong kernel. Để bắt đầu kiểu phân tích này,
dữ liệu phải được ghi lại. Tại thời điểm viết bài, yêu cầu root này:
::

$ bản ghi hoàn hảo -c 1 \
	-e kmem:mm_page_alloc -e kmem:mm_page_free \
	-e kmem:mm_page_free_batched \
	./hackbench 10
  Thời gian: 0,894
  [ bản ghi hoàn hảo: Đã chụp và ghi 0,733 MB perf.data (~ 32010 mẫu) ]

Lưu ý việc sử dụng '-c 1' để đặt khoảng thời gian sự kiện thành mẫu. Mẫu mặc định
khoảng thời gian khá cao để giảm thiểu chi phí nhưng thông tin được thu thập có thể
kết quả là rất thô.

Bản ghi này xuất ra một tệp có tên perf.data có thể được phân tích bằng cách sử dụng
báo cáo hoàn hảo.
::

báo cáo hiệu suất $
  # Samples: 30922
  #
  Đối tượng chia sẻ lệnh # Overhead
  # ............. ............
  Hackbench #
      87.27% [vdso]
       6,85% hackbench /lib/i686/cmov/libc-2.9.so
       2,62% hackbench /lib/ld-2.9.so
       Hiệu suất 1,52% [vdso]
       1,22% hackbench ./hackbench
       Hackbench 0,48% [hạt nhân]
       Hiệu suất 0,02% /lib/i686/cmov/libc-2.9.so
       Hiệu suất 0,01% /usr/bin/perf
       Hiệu suất 0,01% /lib/ld-2.9.so
       0,00% hackbench /lib/i686/cmov/libpthread-2.9.so
  #
  # (Để biết thêm chi tiết, hãy thử: perf report --sort comm,dso,symbol)
  #

Theo đó, phần lớn các sự kiện được kích hoạt trên các sự kiện
trong VDSO. Với các tệp nhị phân đơn giản, điều này thường xảy ra vì vậy chúng ta hãy
lấy một ví dụ hơi khác một chút. Trong quá trình viết bài này, nó đã
nhận thấy rằng X đang tạo ra một lượng phân bổ trang điên rồ, vì vậy hãy xem
vào đó:
::

$ bản ghi hoàn hảo -c 1 -f \
		-e kmem:mm_page_alloc -e kmem:mm_page_free \
		-e kmem:mm_page_free_batched \
		-p ZZ0000ZZ

Quá trình này bị gián đoạn sau vài giây và
::

báo cáo hiệu suất $
  # Samples: 27666
  #
  Đối tượng chia sẻ lệnh # Overhead
  # ......... ........... ............
  #
      51.95% Xorg [vdso]
      47,95% Xorg /opt/gfx-test/lib/libpixman-1.so.0.13.1
       0,09% Xorg /lib/i686/cmov/libc-2.9.so
       0,01% Xorg [hạt nhân]
  #
  # (Để biết thêm chi tiết, hãy thử: perf report --sort comm,dso,symbol)
  #

Vì vậy, gần một nửa số sự kiện đang diễn ra trong thư viện. Để có được một ý tưởng
biểu tượng:
::

$ báo cáo hoàn hảo --sắp xếp comm,dso,biểu tượng
  # Samples: 27666
  #
  Biểu tượng đối tượng chia sẻ lệnh # Overhead
  # ......... .................................................................
  #
      51.95% Xorg [vdso] [.] 0x000000ffffe424
      47,93% Xorg /opt/gfx-test/lib/libpixman-1.so.0.13.1 [.] pixmanFillsse2
       0,09% Xorg /lib/i686/cmov/libc-2.9.so [.] _int_malloc
       0,01% Xorg /opt/gfx-test/lib/libpixman-1.so.0.13.1 [.] pixman_khu vực32_copy_f
       0,01% Xorg [hạt nhân] [k] read_hpet
       0,01% Xorg /opt/gfx-test/lib/libpixman-1.so.0.13.1 [.] get_fast_path
       0,00% Xorg [hạt nhân] [k] ftrace_trace_userstack

Để xem mọi thứ đang sai ở đâu trong hàm pixmanFillsse2:
::

$ hoàn hảo chú thích pixmanFillsse2
  [ ... ]
    0,00 : 34eeb: 0f 18 08 tìm nạp trước0 (%eax)
         : }
         :
         : bên ngoài __inline void __attribute__((__gnu_inline__, __always_inline__, _
         : _mm_store_si128 (__m128i *__P, __m128i __B) : {
         : *__P = __B;
   12,40 : 34eee: 66 0f 7f 80 40 ff ff movdqa %xmm0,-0xc0(%eax)
    0,00 : 34ef5: ff
   12,40 : 34ef6: 66 0f 7f 80 50 ff ff movdqa %xmm0,-0xb0(%eax)
    0,00 : 34efd: ff
   12,39 : 34efe: 66 0f 7f 80 60 ff ff movdqa %xmm0,-0xa0(%eax)
    0.00 : 34f05: ff
   12,67 : 34f06: 66 0f 7f 80 70 ff movdqa %xmm0,-0x90(%eax)
    0.00 : 34f0d: ff
   12,58 : 34f0e: 66 0f 7f 40 80 movdqa %xmm0,-0x80(%eax)
   12,31 : 34f13: 66 0f 7f 40 90 movdqa %xmm0,-0x70(%eax)
   12,40 : 34f18: 66 0f 7f 40 a0 movdqa %xmm0,-0x60(%eax)
   12,31 : 34f1d: 66 0f 7f 40 b0 movdqa %xmm0,-0x50(%eax)

Nhìn thoáng qua, có vẻ như thời gian đang được sử dụng để sao chép ảnh pixmap sang
cái thẻ.  Cần phải điều tra thêm để xác định lý do tại sao pixmaps
đang được sao chép rất nhiều nhưng điểm khởi đầu sẽ là thực hiện một
bản dựng libpixmap cổ xưa nằm ngoài đường dẫn thư viện, nơi nó hoàn toàn
đã bị lãng quên từ nhiều tháng trước!
