.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kernel-hacking/false-sharing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Chia sẻ sai
==============

Chia sẻ sai là gì
=====================
Chia sẻ sai có liên quan đến cơ chế bộ nhớ đệm để duy trì dữ liệu
sự gắn kết của một dòng bộ đệm được lưu trữ trong nhiều bộ đệm của CPU; sau đó
định nghĩa học thuật cho nó là trong [1]_. Hãy xem xét một cấu trúc với một
đếm lại và một chuỗi::

cấu trúc foo {
		refcount_t hoàn tiền;
		...
tên char[16];
	} ____cacheline_internodealigned_in_smp;

Thành viên 'refcount'(A) và 'name'(B) _share_ một dòng bộ nhớ cache như bên dưới::

+----------+ +-----------+
                ZZ0000ZZ ZZ0001ZZ
                +----------+ +-----------+
               / |
              / |
             V V
         +----------------------+ +----------------------+
         Bộ đệm ZZ0002ZZ 0 Bộ đệm ZZ0003ZZ 1
         +----------------------+ +----------------------+
                             ZZ0004ZZ
  --------------------------+-------------------+-----------------------------
                             ZZ0005ZZ
                           +----------------------+
                           ZZ0006ZZ
                           +----------------------+
              Bộ nhớ chính ZZ0007ZZ
                           +----------------------+

'số tiền hoàn lại' được sửa đổi thường xuyên, nhưng 'tên' được đặt một lần tại đối tượng
thời gian tạo và không bao giờ được sửa đổi.  Khi nhiều CPU truy cập 'foo' tại
đồng thời, với việc 'hoàn tiền' chỉ thường xuyên gặp một CPU
và 'tên' được đọc bởi các CPU khác, tất cả các CPU đọc đó phải
tải đi tải lại toàn bộ dòng cache do 'chia sẻ', thậm chí
mặc dù 'tên' không bao giờ thay đổi.

Có rất nhiều trường hợp thực tế về sự hồi quy hiệu suất do
chia sẻ sai sự thật.  Một trong số đó là rw_semaphore 'mmap_lock' bên trong
cấu trúc mm_struct, việc thay đổi bố cục dòng bộ đệm của nó đã kích hoạt một
hồi quy và Linus được phân tích trong [2]_.

Có hai yếu tố chính dẫn đến việc chia sẻ sai sự thật có hại:

* Dữ liệu toàn cầu được nhiều CPU truy cập (chia sẻ)
* Trong các lần truy cập đồng thời vào dữ liệu, có ít nhất một lần ghi
  hoạt động: ghi/ghi hoặc viết/đọc trường hợp.

Việc chia sẻ có thể đến từ các thành phần hạt nhân hoàn toàn không liên quan, hoặc
các đường dẫn mã khác nhau của cùng một thành phần hạt nhân.


Cạm bẫy chia sẻ sai
======================
Quay ngược thời gian khi một nền tảng chỉ có một hoặc một vài CPU, dữ liệu nóng
các thành viên có thể được cố tình đặt vào cùng một dòng bộ đệm để làm cho chúng
cache nóng và lưu cacheline/TLB, giống như một chiếc khóa và dữ liệu được bảo vệ
bởi nó.  Nhưng đối với hệ thống lớn gần đây có hàng trăm CPU, điều này có thể
không hoạt động khi khóa bị tranh chấp nhiều, như chủ sở hữu khóa CPU
có thể ghi vào dữ liệu trong khi các CPU khác đang bận quay khóa.

Nhìn vào các trường hợp trong quá khứ, có một số mô hình thường xuyên xảy ra
vì chia sẻ sai sự thật:

* khóa (spinlock/mutex/semaphore) và dữ liệu được bảo vệ bởi nó
  cố tình đặt vào một dòng bộ đệm.
* dữ liệu toàn cầu được đặt cùng nhau trong một dòng bộ đệm. Một số hạt nhân
  các hệ thống con có nhiều tham số toàn cục có kích thước nhỏ (4 byte),
  có thể dễ dàng được nhóm lại với nhau và đưa vào một dòng bộ đệm.
* các thành viên dữ liệu của cấu trúc dữ liệu lớn ngồi ngẫu nhiên cùng nhau
  mà không được chú ý (dòng bộ đệm thường là 64 byte trở lên),
  giống như cấu trúc 'mem_cgroup'.

Phần 'giảm thiểu' sau đây cung cấp các ví dụ thực tế.

Việc chia sẻ sai sự thật có thể dễ dàng xảy ra trừ khi họ cố tình
đã được kiểm tra và việc chạy các công cụ cụ thể để đạt hiệu suất là rất có giá trị
khối lượng công việc quan trọng để phát hiện việc chia sẻ sai ảnh hưởng đến trường hợp hiệu suất
và tối ưu hóa cho phù hợp.


Cách phát hiện và phân tích Chia sẻ sai
========================================
bản ghi/báo cáo/thống kê hoàn hảo được sử dụng rộng rãi để điều chỉnh hiệu suất và
khi các điểm nóng được phát hiện, các công cụ như 'perf-c2c' và 'pahole' có thể
được tiếp tục sử dụng để phát hiện và xác định việc chia sẻ sai có thể xảy ra
các cấu trúc dữ liệu.  'addr2line' cũng giỏi hướng dẫn giải mã
con trỏ khi có nhiều lớp hàm nội tuyến.

perf-c2c có thể ghi lại các dòng bộ nhớ đệm có hầu hết các lần truy cập chia sẻ sai,
các chức năng được giải mã (số dòng của tệp) truy cập dòng bộ đệm đó,
và bù đắp nội tuyến của dữ liệu. Các lệnh đơn giản là::

$ hoàn hảo bản ghi c2c -ag ngủ 3
  $ hoàn hảo báo cáo c2c --call-graph none -k vmlinux

Khi chạy ở trên trong quá trình kiểm tra trường hợp tlb_flush1 của will-it-scale,
perf báo cáo một cái gì đó như ::

Tổng số hồ sơ : 1658231
  Hoạt động tải/lưu trữ bị khóa: 89439
  Hoạt động tải: 623219
  Tải HITM cục bộ : 92117
  Tải từ xa HITM : 139

#----------------------------------------------------------------------
      4 0 2374 0 0 0 0xff1100088366d880
  #----------------------------------------------------------------------
    0,00% 42,29% 0,00% 0,00% 0,00% 0x8 1 1 0xffffffff81373b7b 0 231 129 5312 64 [k] __mod_lruvec_page_state [kernel.vmlinux] memcontrol.h:752 1
    0,00% 13,10% 0,00% 0,00% 0,00% 0x8 1 1 0xffffffff81374718 0 226 97 3551 64 [k] folio_lruvec_lock_irqsave [kernel.vmlinux] memcontrol.h:752 1
    0,00% 11,20% 0,00% 0,00% 0,00% 0x8 1 1 0xffffffff812c29bf 0 170 136 555 64 [k] lru_add_fn [kernel.vmlinux] mm_inline.h:41 1
    0,00% 7,62% 0,00% 0,00% 0,00% 0x8 1 1 0xffffffff812c3ec5 0 175 108 632 64 [k] Release_pages [kernel.vmlinux] mm_inline.h:41 1
    0,00% 23,29% 0,00% 0,00% 0,00% 0x10 1 1 0xffffffff81372d0a 0 234 279 1051 64 [k] __mod_memcg_lruvec_state [kernel.vmlinux] memcontrol.c:736 1

Phần giới thiệu hay cho perf-c2c là [3]_.

'pahole' giải mã bố cục cấu trúc dữ liệu được phân tách trong dòng bộ đệm
độ chi tiết.  Người dùng có thể khớp phần bù trong đầu ra perf-c2c với
giải mã của pahole để xác định vị trí các thành viên dữ liệu chính xác.  Đối với toàn cầu
data, người dùng có thể tìm kiếm địa chỉ dữ liệu trong System.map.


Giảm thiểu có thể
====================
Việc chia sẻ sai trái không phải lúc nào cũng cần được giảm thiểu.  Chia sẻ sai
các biện pháp giảm thiểu cần cân bằng giữa lợi ích hiệu suất với độ phức tạp và
tiêu thụ không gian.  Đôi khi, hiệu suất thấp hơn cũng không sao, và đó là điều bình thường.
không cần thiết phải siêu tối ưu hóa mọi cấu trúc dữ liệu hiếm khi được sử dụng hoặc
một đường dẫn dữ liệu lạnh.

Các trường hợp chia sẻ sai làm tổn hại đến hiệu suất được thấy thường xuyên hơn với
số lượng lõi ngày càng tăng.  Vì những tác động bất lợi này, nhiều
các bản vá đã được đề xuất trên nhiều hệ thống con khác nhau (như
quản lý mạng và bộ nhớ) và được sáp nhập.  Một số biện pháp giảm thiểu phổ biến
(có ví dụ) là:

* Tách riêng dữ liệu nóng toàn cầu trong dòng bộ đệm chuyên dụng của riêng nó, ngay cả khi nó
  chỉ là một loại 'ngắn'. Nhược điểm là tiêu tốn nhiều bộ nhớ hơn,
  dòng bộ đệm và các mục TLB.

- Cam kết 91b6d3256356 ("net: căn chỉnh bộ đệm tcp_memory_allocated, tcp_sockets_allocated")

* Tổ chức lại cấu trúc dữ liệu, tách các thành phần gây nhiễu để
  dòng bộ đệm khác nhau.  Một nhược điểm là nó có thể đưa ra những sai sót mới
  chia sẻ của các thành viên khác.

- Cam kết 802f1d522d5f ("mm: page_counter: cấu trúc lại bố cục để giảm việc chia sẻ sai")

* Thay thế 'ghi' bằng 'đọc' khi có thể, đặc biệt là trong các vòng lặp.
  Giống như đối với một số biến toàn cục, thay vào đó hãy sử dụng so sánh (đọc)-then-write
  viết vô điều kiện. Ví dụ: sử dụng::

nếu (!test_bit(XXX))
		set_bit(XXX);

thay vì trực tiếp "set_bit(XXX);", tương tự đối với dữ liệu Atomic_t::

nếu (atomic_read(XXX) == AAA)
		Atomic_set(XXX, BBB);

- Cam kết 7b1002f7cfe5 ("bcache: fixup bcache_dev_sectors_dirty_add() chia sẻ sai CPU đa luồng")
  - Cam kết 292648ac5cf1 ("mm: gup: cho phép FOLL_PIN mở rộng quy mô trong SMP")

* Biến dữ liệu toàn cầu nóng thành 'dữ liệu trên mỗi CPU + dữ liệu toàn cầu' khi có thể,
  hoặc tăng ngưỡng hợp lý để đồng bộ hóa dữ liệu trên mỗi CPU với
  dữ liệu toàn cầu, để giảm hoặc trì hoãn việc 'ghi' vào dữ liệu toàn cầu đó.

- Cam kết 520f897a3554 ("ext4: sử dụng percpu_counters cho các lần truy cập/lỡ bộ nhớ cache của range_status")
  - Cam kết 56f3547bfa4d ("mm: điều chỉnh vm_commed_as_batch theo chính sách vượt mức của vm")

Chắc chắn mọi biện pháp giảm nhẹ đều phải được xác minh cẩn thận để không gây ra tác dụng phụ.
hiệu ứng.  Để tránh đưa ra chia sẻ sai khi mã hóa thì tốt hơn
đến:

* Hãy nhận biết ranh giới dòng bộ đệm
* Nhóm hầu hết các trường chỉ đọc lại với nhau
* Nhóm những thứ được viết cùng lúc lại với nhau
* Tách biệt các trường thường xuyên đọc và viết thường xuyên trên
  dòng bộ đệm khác nhau.

và tốt hơn là thêm một nhận xét nêu rõ việc xem xét chia sẻ sai.

Một lưu ý là, đôi khi ngay cả sau khi phát hiện ra việc chia sẻ sai nghiêm trọng
và được giải quyết, hiệu suất có thể vẫn không có sự cải thiện rõ ràng vì
điểm phát sóng chuyển sang địa điểm mới.


Linh tinh
=============
Một vấn đề mở là kernel có cấu trúc dữ liệu tùy chọn
cơ chế ngẫu nhiên hóa, cũng ngẫu nhiên hóa tình trạng bộ đệm
chia sẻ đường truyền giữa các thành viên dữ liệu.


.. [1] https://en.wikipedia.org/wiki/False_sharing
.. [2] https://lore.kernel.org/lkml/CAHk-=whoqV=cX5VC80mmR9rr+Z+yQ6fiQZm36Fb-izsanHg23w@mail.gmail.com/
.. [3] https://joemario.github.io/blog/2016/09/01/c2c-blog/