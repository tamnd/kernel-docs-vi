.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/events-kmem.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
Điểm theo dõi hệ thống con: kmem
============================

Hệ thống theo dõi kmem nắm bắt các sự kiện liên quan đến phân bổ đối tượng và trang
bên trong hạt nhân. Nói rộng ra có năm phân nhóm chính.

- Phân bổ phiến các đối tượng nhỏ không xác định loại (kmalloc)
  - Phân bổ tấm của các đối tượng nhỏ thuộc loại đã biết
  - Phân bổ trang
  - Hoạt động phân bổ Per-CPU
  - Phân mảnh bên ngoài

Tài liệu này mô tả từng điểm theo dõi là gì và tại sao chúng
có thể hữu ích.

1. Phân bổ phiến của các đối tượng nhỏ không xác định loại
===================================================
::

kmalloc call_site=%lx ptr=%p bytes_req=%zu bytes_alloc=%zu gfp_flags=%s
  kmalloc_node call_site=%lx ptr=%p bytes_req=%zu bytes_alloc=%zu gfp_flags=%s nút=%d
  kfree call_site=%lx ptr=%p

Hoạt động mạnh mẽ đối với những sự kiện này có thể cho thấy rằng một bộ nhớ đệm cụ thể đã bị hỏng.
hợp lý, đặc biệt nếu các trang phiến kmalloc đang trở nên đáng kể
bị phân mảnh nội bộ do mô hình phân bổ. Bằng cách tương quan
kmalloc với kfree, có thể xác định rò rỉ bộ nhớ và vị trí
các trang web phân bổ được.


2. Phân bổ phiến của các đối tượng nhỏ thuộc loại đã biết
=================================================
::

kmem_cache_alloc call_site=%lx ptr=%p bytes_req=%zu bytes_alloc=%zu gfp_flags=%s
  kmem_cache_alloc_node call_site=%lx ptr=%p bytes_req=%zu bytes_alloc=%zu gfp_flags=%s nút=%d
  kmem_cache_free call_site=%lx ptr=%p

Các sự kiện này có cách sử dụng tương tự như các sự kiện liên quan đến kmalloc ngoại trừ việc
việc ghim sự kiện vào một bộ đệm cụ thể có thể dễ dàng hơn. Vào thời điểm đó
bằng văn bản, không có thông tin nào về tấm sàn nào được phân bổ từ đó,
nhưng call_site thường có thể được sử dụng để ngoại suy thông tin đó.

3. Phân bổ trang
==================
::

mm_page_alloc page=%p pfn=%lu order=%d Migratetype=%d gfp_flags=%s
  mm_page_alloc_zone_locked page=%p pfn=%lu order=%u Migratetype=%d cpu=%d percpu_refill=%d
  mm_page_free page=%p pfn=%lu order=%d
  mm_page_free_batched trang=%p pfn=%lu đơn hàng=%d lạnh=%d

Bốn sự kiện này liên quan đến việc phân bổ và giải phóng trang. mm_page_alloc là
một chỉ báo đơn giản về hoạt động cấp phát trang. Các trang có thể được phân bổ từ
bộ cấp phát per-CPU (hiệu suất cao) hoặc bộ cấp phát bạn bè.

Nếu các trang được phân bổ trực tiếp từ công cụ cấp phát bạn bè,
sự kiện mm_page_alloc_zone_locked được kích hoạt. Sự kiện này có tầm quan trọng cao
số lượng hoạt động ngụ ý hoạt động cao trên vùng-> khóa. Lấy ổ khóa này
làm giảm hiệu suất bằng cách vô hiệu hóa các ngắt, làm bẩn các dòng bộ đệm giữa
CPU và nối tiếp nhiều CPU.

Khi một trang được giải phóng trực tiếp bởi người gọi, sự kiện mm_page_free duy nhất
được kích hoạt. Số lượng hoạt động đáng kể ở đây có thể chỉ ra rằng
người gọi nên sắp xếp các hoạt động của họ.

Khi các trang được giải phóng hàng loạt, mm_page_free_batched cũng được kích hoạt.
Nói rộng ra, các trang được gỡ bỏ khỏi khóa LRU hàng loạt và
được giải phóng hàng loạt với một danh sách trang. Số lượng hoạt động đáng kể ở đây có thể
chỉ ra rằng hệ thống đang chịu áp lực bộ nhớ và cũng có thể chỉ ra
tranh chấp trên lruvec->lru_lock.

4. Hoạt động phân bổ Per-CPU
=============================
::

mm_page_alloc_zone_locked page=%p pfn=%lu order=%u Migratetype=%d cpu=%d percpu_refill=%d
  mm_page_pcpu_drain page=%p pfn=%lu order=%d cpu=%d Migratetype=%d

Phía trước bộ cấp phát trang là bộ cấp phát trang theo CPU. Nó chỉ tồn tại
đối với các trang order-0, giảm sự tranh chấp trên vùng->khóa và giảm
số lượng văn bản trên trang cấu trúc.

Khi danh sách trên mỗi CPU trống hoặc các trang không đúng loại được phân bổ,
khóa vùng-> sẽ được thực hiện một lần và danh sách mỗi CPU được nạp lại. Sự kiện
được kích hoạt là mm_page_alloc_zone_locked cho mỗi trang được phân bổ bằng
sự kiện cho biết liệu nó có dành cho percpu_refill hay không.

Khi danh sách mỗi CPU quá đầy, một số trang sẽ được giải phóng, mỗi trang sẽ được giải phóng
kích hoạt sự kiện mm_page_pcpu_drain.

Bản chất riêng của các sự kiện là để có thể theo dõi các trang
giữa phân bổ và giải phóng. Xảy ra một số trang thoát hoặc nạp lại
liên tiếp ngụ ý vùng-> khóa được thực hiện một lần. Số lượng lớn trên mỗi CPU
việc nạp và xả có thể hàm ý sự mất cân bằng giữa các CPU khi làm việc quá nhiều
đang được tập trung ở một nơi. Nó cũng có thể chỉ ra rằng mỗi CPU
danh sách phải có kích thước lớn hơn. Cuối cùng, số lượng nạp lớn trên một CPU
và thoát trên thiết bị khác có thể là nguyên nhân gây ra lượng lớn bộ nhớ đệm
dòng bị trả lại do ghi giữa các CPU và đáng để điều tra xem các trang có
có thể được phân bổ và giải phóng trên cùng một CPU thông qua một số thay đổi thuật toán.

5. Phân mảnh bên ngoài
=========================
::

mm_page_alloc_extfrag page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d phân mảnh=%d Change_ownership=%d

Phân mảnh bên ngoài ảnh hưởng đến việc liệu việc phân bổ bậc cao có được thực hiện hay không
thành công hay không. Đối với một số loại phần cứng, điều này rất quan trọng mặc dù
nó được tránh nếu có thể. Nếu hệ thống đang sử dụng các trang lớn và cần
để có thể thay đổi kích thước nhóm trong suốt vòng đời của hệ thống, giá trị này
là quan trọng.

Số lượng lớn sự kiện này ngụ ý rằng bộ nhớ đang bị phân mảnh và
phân bổ bậc cao sẽ bắt đầu thất bại vào một thời điểm nào đó trong tương lai. một
phương tiện để giảm sự xuất hiện của sự kiện này là tăng quy mô của
min_free_kbytes theo gia số 3*pageblock_size*nr_online_nodes trong đó
pageblock_size thường là kích thước của kích thước trang lớn mặc định.
