.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/allocation-profiling.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================
MEMORY ALLOCATION PROFILING
===========================

Tính toán chi phí thấp (phù hợp cho sản xuất) đối với tất cả việc phân bổ bộ nhớ,
được theo dõi bởi tập tin và số dòng.

Cách sử dụng:
tùy chọn kconfig:
-CONFIG_MEM_ALLOC_PROFILING

-CONFIG_MEM_ALLOC_PROFILING_ENABLED_BY_DEFAULT

-CONFIG_MEM_ALLOC_PROFILING_DEBUG
  thêm cảnh báo cho các phân bổ không được tính vì một
  chú thích bị thiếu

Tham số khởi động:
  sysctl.vm.mem_profiling={0|1|never[,đã nén]

Khi được đặt thành "không bao giờ", chi phí lập hồ sơ cấp phát bộ nhớ sẽ được giảm thiểu và nó
  không thể được kích hoạt trong thời gian chạy (sysctl trở thành chỉ đọc).
  Khi CONFIG_MEM_ALLOC_PROFILING_ENABLED_BY_DEFAULT=y, giá trị mặc định là "1".
  Khi CONFIG_MEM_ALLOC_PROFILING_ENABLED_BY_DEFAULT=n, giá trị mặc định là "không bao giờ".
  Tham số tùy chọn "nén" sẽ cố gắng lưu trữ các tham chiếu thẻ trang trong một
  định dạng nhỏ gọn, tránh mở rộng trang. Điều này dẫn đến hiệu suất được cải thiện
  và mức tiêu thụ bộ nhớ, tuy nhiên nó có thể bị lỗi tùy thuộc vào cấu hình hệ thống.
  Nếu quá trình nén không thành công, một cảnh báo sẽ được đưa ra và hồ sơ phân bổ bộ nhớ sẽ được thực hiện.
  bị vô hiệu hóa.

sysctl:
  /proc/sys/vm/mem_profiling

1: Kích hoạt tính năng cấu hình bộ nhớ.

0: Tắt cấu hình bộ nhớ.

Giá trị mặc định phụ thuộc vào CONFIG_MEM_ALLOC_PROFILING_ENABLED_BY_DEFAULT.

Khi CONFIG_MEM_ALLOC_PROFILING_DEBUG=y, điều khiển này ở chế độ chỉ đọc để tránh
  cảnh báo được tạo bởi phân bổ được thực hiện trong khi hồ sơ bị vô hiệu hóa và giải phóng
  khi nó được kích hoạt.

Thông tin thời gian chạy:
  /proc/allocinfo

Đầu ra ví dụ::

root@moria-kvm:~# sort -g /proc/allocinfo|tail|numfmt --to=iec
        2,8M 22648 fs/kernfs/dir.c:615 func:__kernfs_new_node
        3,8M 953 mm/bộ nhớ.c:4214 func:alloc_anon_folio
        Trình điều khiển 4.0M 1010/staging/ctagmod/ctagmod.c:20 [ctagmod] func:ctagmod_start
        4.1M 4 mạng/netfilter/nf_conntrack_core.c:2567 func:nf_ct_alloc_hashtable
        6.0M 1532 mm/filemap.c:1919 func:__filemap_get_folio
        8,8M 2785 kernel/fork.c:307 func:alloc_thread_stack_node
         Khối 13M 234/blk-mq.c:3421 func:blk_mq_alloc_rqs
         14M 3520 mm/mm_init.c:2530 func:alloc_large_system_hash
         15M 3656 mm/readahead.c:247 func:page_cache_ra_unbounded
         55M 4887 mm/slub.c:2259 func:alloc_slab_page
        122M 31168 mm/page_ext.c:270 func:alloc_page_ext

Lý thuyết hoạt động
===================

Hồ sơ phân bổ bộ nhớ được xây dựng dựa trên việc gắn thẻ mã, đây là thư viện dành cho
khai báo các cấu trúc tĩnh (thường mô tả một tệp và số dòng trong
theo một cách nào đó, do đó gắn thẻ mã) rồi tìm và thao tác trên chúng khi chạy,
- tức là lặp lại chúng để in chúng trong debugfs/procfs.

Để thêm tính năng kế toán cho lệnh gọi phân bổ, chúng tôi thay thế nó bằng macro
lời gọi, alloc_hooks(), đó
- khai báo một thẻ mã
- lưu trữ một con trỏ tới nó trong task_struct
- gọi hàm phân bổ thực
- và cuối cùng, khôi phục con trỏ thẻ cấp phát task_struct về giá trị trước đó của nó.

Điều này cho phép các lệnh gọi alloc_hooks() được lồng vào nhau, với lệnh gọi gần đây nhất
có hiệu lực. Điều này rất quan trọng đối với việc phân bổ nội bộ cho mm/mã mà
không thuộc về bối cảnh phân bổ bên ngoài một cách chính xác và cần được tính
riêng biệt: ví dụ, vectơ mở rộng đối tượng bản sàn, hoặc khi bản sàn
phân bổ các trang từ bộ cấp phát trang.

Vì vậy, việc sử dụng hợp lý đòi hỏi phải xác định chức năng nào trong lệnh gọi phân bổ
ngăn xếp nên được gắn thẻ. Có nhiều chức năng trợ giúp về cơ bản bao bọc
ví dụ: kmalloc() và thực hiện thêm một chút công việc, sau đó được gọi ở nhiều nơi;
nói chung chúng ta sẽ muốn việc tính toán diễn ra ở những người gọi đến những người trợ giúp này,
không phải ở chính những người giúp đỡ.

Để sửa một trình trợ giúp nhất định, ví dụ như foo(), hãy làm như sau:
- chuyển cuộc gọi phân bổ của nó sang phiên bản _noprof(), ví dụ: kmalloc_noprof()

- đổi tên nó thành foo_noprof()

- xác định phiên bản macro của foo() như vậy:

#define foo(...) alloc_hooks(foo_noprof(__VA_ARGS__))

Bạn cũng có thể đặt con trỏ tới thẻ cấp phát trong cấu trúc dữ liệu của riêng mình.

Thực hiện việc này khi bạn đang triển khai cấu trúc dữ liệu chung có chức năng phân bổ
"thay mặt" một số mã khác - ví dụ: mã rhashtable. Lối này,
thay vì nhìn thấy một dòng lớn trong /proc/allocinfo cho rhashtable.c, chúng ta có thể
chia nó ra theo loại rhashtable.

Để làm như vậy:
- Kết nối hàm init của cấu trúc dữ liệu của bạn, giống như bất kỳ hàm phân bổ nào khác.

- Trong hàm init của bạn, hãy sử dụng macro tiện lợi alloc_tag_record() để
  ghi lại thẻ phân bổ trong cấu trúc dữ liệu của bạn.

- Sau đó, sử dụng mẫu sau để phân bổ:
  alloc_hooks_tag(ht->your_saved_tag, kmalloc_noprof(...))