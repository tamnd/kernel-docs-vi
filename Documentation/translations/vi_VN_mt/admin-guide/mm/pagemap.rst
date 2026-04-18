.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/pagemap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Kiểm tra bảng trang quy trình
================================

sơ đồ trang là một bộ giao diện mới (kể từ 2.6.25) trong kernel cho phép
chương trình không gian người dùng để kiểm tra các bảng trang và thông tin liên quan bằng cách
đọc tập tin trong ZZ0000ZZ.

Có bốn thành phần trong sơ đồ trang:

* ZZ0000ZZ.  Tệp này cho phép quá trình không gian người dùng tìm ra
   khung vật lý mà mỗi trang ảo được ánh xạ tới.  Nó chứa một 64-bit
   giá trị cho mỗi trang ảo, chứa dữ liệu sau (từ
   ZZ0001ZZ, phía trên pagemap_read):

* Số khung trang bit 0-54 (PFN) nếu có
    * Loại hoán đổi bit 0-4 nếu hoán đổi
    * Bù hoán đổi bit 5-54 nếu hoán đổi
    * Bit 55 pte bị bẩn mềm (xem
      Tài liệu/admin-guide/mm/soft-dirty.rst)
    * Trang Bit 56 được ánh xạ riêng (kể từ 4.2)
    * Bit 57 pte được bảo vệ chống ghi uffd-wp (kể từ 5.13) (xem
      Tài liệu/admin-guide/mm/userfaultfd.rst)
    * Bit 58 pte là vùng bảo vệ (kể từ 6.15) (xem trang man madvise (2))
    * Bit 59-60 không
    * Trang bit 61 là trang file hoặc trang chia sẻ (kể từ 3.5)
    * Trang bit 62 được hoán đổi
    * Trang bit 63 hiện tại

Vì Linux 4.0, chỉ những người dùng có khả năng CAP_SYS_ADMIN mới có thể nhận được PFN.
   Trong 4.0 và 4.1 mở do lỗi không có đặc quyền với -EPERM.  Bắt đầu từ
   4.2 trường PFN sẽ bằng 0 nếu người dùng không có CAP_SYS_ADMIN.
   Lý do: thông tin về PFN giúp khai thác lỗ hổng Rowhammer.

Nếu trang này không tồn tại nhưng được trao đổi thì PFN chứa một
   mã hóa số tập tin hoán đổi và phần bù của trang vào
   trao đổi. Các trang chưa được ánh xạ trả về PFN rỗng. Điều này cho phép xác định
   chính xác những trang nào được ánh xạ (hoặc hoán đổi) và so sánh được ánh xạ
   trang giữa các tiến trình.

Theo truyền thống, bit 56 chỉ ra rằng một trang được ánh xạ chính xác một lần và bit
   56 rõ ràng khi một trang được ánh xạ nhiều lần, ngay cả khi được ánh xạ trong
   cùng một quá trình nhiều lần. Trong một số cấu hình hạt nhân, ngữ nghĩa
   đối với các trang, phần phân bổ lớn hơn (ví dụ: THP) có thể khác: bit 56 được đặt
   nếu tất cả các trang thuộc phân bổ lớn tương ứng là ZZ0000ZZ
   được ánh xạ trong cùng một quy trình, ngay cả khi trang được ánh xạ nhiều lần trong quy trình đó
   quá trình. Bit 56 được xóa khi trang nào được phân bổ lớn hơn
   ZZ0001ZZ được ánh xạ trong một quy trình khác. Trong một số trường hợp, một sự phân bổ lớn
   có thể được coi là "có thể được ánh xạ bởi nhiều quy trình" mặc dù điều này
   không còn là trường hợp nữa.

Người dùng hiệu quả của giao diện này sẽ sử dụng ZZ0000ZZ để
   xác định vùng bộ nhớ nào thực sự được ánh xạ và tìm kiếm
   bỏ qua các khu vực chưa được ánh xạ.

*ZZ0000ZZ.  Tệp này chứa số lượng 64-bit của số lượng
   số lần mỗi trang được ánh xạ, lập chỉ mục bởi PFN. Một số cấu hình kernel thực hiện
   không theo dõi số lần chính xác của một phần trang của phân bổ lớn hơn
   (ví dụ: THP) được ánh xạ. Trong các cấu hình này, số lượng trung bình của
   thay vào đó, ánh xạ trên mỗi trang trong phân bổ lớn hơn này sẽ được trả về. Tuy nhiên,
   nếu bất kỳ trang nào của phân bổ lớn được ánh xạ, giá trị trả về sẽ
   ít nhất là 1.

Công cụ loại trang trong thư mục tools/mm có thể được sử dụng để truy vấn
số lần một trang được ánh xạ.

*ZZ0000ZZ.  Tệp này chứa một bộ cờ 64 bit cho mỗi
   trang, được lập chỉ mục bởi PFN.

Các cờ là (từ ZZ0000ZZ, phía trên kpageflags_read):

0. LOCKED
    1. ERROR
    2. REFERENCED
    3. UPTODATE
    4. DIRTY
    5. LRU
    6. ACTIVE
    7. SLAB
    8. WRITEBACK
    9. RECLAIM
    10. BUDDY
    11. MMAP
    12. ANON
    13. SWAPCACHE
    14. SWAPBACKED
    15. COMPOUND_HEAD
    16. COMPOUND_TAIL
    17. HUGE
    18. UNEVICTABLE
    19. HWPOISON
    20. NOPAGE
    21. KSM
    22. THP
    23. OFFLINE
    24. ZERO_PAGE
    25. IDLE
    26. PGTABLE

*ZZ0000ZZ.  Tệp này chứa số inode 64 bit của
   nhóm bộ nhớ mà mỗi trang được tính phí, được lập chỉ mục bởi PFN. Chỉ có sẵn khi
   CONFIG_MEMCG được thiết lập.

Mô tả ngắn cho cờ trang
====================================

0 - LOCKED
   Trang này đang bị khóa để truy cập độc quyền, ví dụ: bằng cách đọc/ghi
   IO.
7 - SLAB
   Trang này được quản lý bởi bộ cấp phát bộ nhớ hạt nhân SLAB/SLUB.
   Khi sử dụng trang ghép, một trong hai trang sẽ chỉ đặt cờ này trên đầu
   trang.
10 - BUDDY
    Khối bộ nhớ trống được quản lý bởi bộ cấp phát hệ thống bạn bè.
    Hệ thống bạn bè sắp xếp bộ nhớ trống theo các khối có thứ tự khác nhau.
    Khối N đơn hàng có 2^N trang liền kề về mặt vật lý, với cờ BUDDY
    đặt cho tất cả các trang.
    Trước 4.6 chỉ có trang đầu tiên của khối được đặt cờ.
15 - COMPOUND_HEAD
    Một trang ghép có thứ tự N bao gồm 2^N trang liền kề về mặt vật lý.
    Một trang ghép với thứ tự 2 có dạng "HTTT", trong đó H tặng nó
    trang đầu và T tặng (các) trang đuôi của nó.  Người tiêu dùng chính của hợp chất
    các trang là các trang TLB lớn (Documentation/admin-guide/mm/hugetlbpage.rst),
    bộ cấp phát bộ nhớ SLUB, v.v. và các trình điều khiển thiết bị khác nhau.
    Tuy nhiên, trong giao diện này, chỉ các trang lớn/giga mới được hiển thị
    tới người dùng cuối.
16 - COMPOUND_TAIL
    Đuôi trang ghép (xem mô tả ở trên).
17 - HUGE
    Đây là một phần không thể thiếu của trang HugeTLB.
19 - HWPOISON
    Phần cứng đã phát hiện hỏng bộ nhớ trên trang này: đừng chạm vào dữ liệu!
20 - NOPAGE
    Không có khung trang tồn tại ở địa chỉ được yêu cầu.
21 - KSM
    Các trang bộ nhớ giống hệt nhau được chia sẻ động giữa một hoặc nhiều tiến trình.
22 - THP
    Các trang liền kề xây dựng THP ở mọi kích thước và được ánh xạ theo bất kỳ mức độ chi tiết nào.
23 - OFFLINE
    Trang này ngoại tuyến một cách hợp lý.
24 - ZERO_PAGE
    Không có trang nào cho trang pfn_zero hoặc Huge_zero.
25 - IDLE
    Trang này chưa được truy cập vì nó được đánh dấu là không hoạt động (xem
    Tài liệu/admin-guide/mm/idle_page_tracking.rst).
    Lưu ý rằng cờ này có thể cũ trong trường hợp trang được truy cập qua
    một chiếc PTE. Để đảm bảo cờ được cập nhật, người ta phải đọc
    ZZ0000ZZ đầu tiên.
26 - PGTABLE
    Trang này được sử dụng như một bảng trang.

Cờ trang liên quan đến IO
---------------------

1 - ERROR
   Đã xảy ra lỗi IO.
3 - UPTODATE
   Trang này có dữ liệu cập nhật.
   tức là. đối với trang được sao lưu bằng tệp: (sửa đổi dữ liệu trong bộ nhớ>= một trên đĩa)
4 - DIRTY
   Trang này đã được ghi vào, do đó chứa dữ liệu mới.
   tức là đối với trang được sao lưu tệp: (sửa đổi dữ liệu trong bộ nhớ> trang trên đĩa)
8 - WRITEBACK
   Trang đang được đồng bộ hóa vào đĩa.

Cờ trang liên quan đến LRU
----------------------

5 - LRU
   Trang này nằm trong một trong các danh sách LRU.
6 - ACTIVE
   Trang này nằm trong danh sách LRU đang hoạt động.
18 - UNEVICTABLE
   Trang này nằm trong danh sách LRU không thể xóa được (không phải) Nó được ghim và
   không phải là ứng cử viên cho việc xác nhận lại trang LRU, ví dụ: trang ramfs,
   phân đoạn bộ nhớ shmctl(SHM_LOCK) và mlock().
2 - REFERENCED
   Trang này đã được tham chiếu kể từ danh sách LRU cuối cùng trong hàng đợi/yêu cầu.
9 - RECLAIM
   Trang này sẽ được thu hồi ngay sau khi IO phân trang của nó hoàn tất.
11 - MMAP
   Một trang ánh xạ bộ nhớ.
12 - ANON
   Một trang được ánh xạ bộ nhớ không phải là một phần của tệp.
13 - SWAPCACHE
   Trang được ánh xạ tới không gian hoán đổi, tức là có mục trao đổi liên quan.
14 - SWAPBACKED
   Trang này được hỗ trợ bởi trao đổi/RAM.

Công cụ loại trang trong thư mục tools/mm có thể được sử dụng để truy vấn
trên các lá cờ.

Ngoại lệ cho bộ nhớ dùng chung
============================

Các mục trong bảng trang cho các trang được chia sẻ sẽ bị xóa khi các trang bị cắt hoặc
bị tráo đổi. Điều này làm cho các trang bị tráo đổi không thể phân biệt được với các trang chưa bao giờ được phân bổ
những cái đó.

Trong không gian kernel, vị trí trao đổi vẫn có thể được lấy từ bộ đệm trang.
Tuy nhiên, các giá trị chỉ được lưu trữ trên PTE bình thường sẽ bị mất không thể phục hồi được khi
trang bị hoán đổi (tức là SOFT_DIRTY).

Trong không gian người dùng, có thể suy ra được trang đó có hiện diện, bị hoán đổi hay không bằng
sự trợ giúp của các lệnh gọi hệ thống lseek và/hoặc mincore.

lseek() có thể phân biệt giữa các trang được truy cập (hiện tại hoặc đã hoán đổi) và
lỗ (không có/không được phân bổ) bằng cách chỉ định cờ SEEK_DATA trên tệp nơi
các trang được hỗ trợ. Đối với các trang chia sẻ ẩn danh, tập tin có thể được tìm thấy trong
ZZ0000ZZ.

mincore() có thể phân biệt giữa các trang trong bộ nhớ (hiện tại, bao gồm trao đổi
cache) và hết bộ nhớ (bị tráo đổi hoặc không có/không được phân bổ).

Ghi chú khác
===========

Việc đọc từ bất kỳ tệp nào sẽ trả về -EINVAL nếu bạn không bắt đầu
việc đọc trên ranh giới 8 byte (ví dụ: nếu bạn tìm kiếm số byte lẻ
vào tệp) hoặc nếu kích thước của lần đọc không phải là bội số của 8 byte.

Trước Linux 3.11, các bit sơ đồ trang 55-60 được sử dụng cho "dịch chuyển trang" (nghĩa là
luôn luôn là 12 ở hầu hết các kiến trúc). Kể từ Linux 3.11, ý nghĩa của chúng thay đổi
sau lần đầu tiên loại bỏ các bit bẩn mềm. Kể từ Linux 4.2, chúng được sử dụng cho
cờ vô điều kiện.

Quét sơ đồ trang IOCTL
==================

ZZ0000ZZ IOCTL trên tệp bản đồ trang có thể được sử dụng để lấy hoặc tùy chọn
xóa thông tin về các mục trong bảng trang. Các hoạt động sau đây được hỗ trợ
trong IOCTL này:

- Quét phạm vi địa chỉ và lấy phạm vi bộ nhớ phù hợp với tiêu chí được cung cấp.
  Điều này được thực hiện khi bộ đệm đầu ra được chỉ định.
- Viết-bảo vệ các trang. ZZ0000ZZ được sử dụng để bảo vệ ghi
  các trang quan tâm. ZZ0001ZZ hủy bỏ hoạt động nếu
  tìm thấy các trang được bảo vệ chống ghi không Async. ZZ0002ZZ có thể
  được sử dụng có hoặc không có ZZ0003ZZ.
- Cả hai thao tác đó có thể được kết hợp thành một thao tác nguyên tử mà chúng ta có thể
  get và write cũng bảo vệ các trang.

Các cờ sau về các trang hiện được hỗ trợ:

- ZZ0000ZZ - Trang đã bật tính năng bảo vệ ghi không đồng bộ
- ZZ0001ZZ - Trang đã được ghi từ thời điểm nó được bảo vệ chống ghi
- ZZ0002ZZ - Trang được hỗ trợ tập tin
- ZZ0003ZZ - Trang có trong bộ nhớ
- ZZ0004ZZ - Trang đang được hoán đổi
- ZZ0005ZZ - Trang không có PFN
- ZZ0006ZZ - Trang được hỗ trợ bởi THP hoặc Hugetlb được ánh xạ bởi PMD
- ZZ0007ZZ - Trang bị bẩn mềm
- ZZ0008ZZ - Trang là một phần của vùng bảo vệ

ZZ0000ZZ được sử dụng làm đối số của IOCTL.

1. Kích thước của ZZ0000ZZ phải được chỉ định trong ZZ0001ZZ
    lĩnh vực. Trường này sẽ hữu ích trong việc nhận dạng cấu trúc nếu phần mở rộng
    được thực hiện sau này.
 2. Các cờ có thể được chỉ định trong trường ZZ0002ZZ. ZZ0003ZZ
    và ZZ0004ZZ là những lá cờ được thêm vào duy nhất tại thời điểm này. nhận được
    hoạt động được thực hiện tùy chọn tùy thuộc vào việc bộ đệm đầu ra có
    được cung cấp hay không.
 3. Phạm vi được chỉ định thông qua ZZ0005ZZ và ZZ0006ZZ.
 4. Quá trình đi bộ có thể bị hủy bỏ trước khi truy cập toàn bộ phạm vi, chẳng hạn như bộ đệm người dùng
    có thể nhận được đầy đủ, v.v. Địa chỉ kết thúc chuyến đi được chỉ định trong``end_walk``.
 5. Bộ đệm đầu ra của mảng và kích thước ZZ0008ZZ được chỉ định trong
    ZZ0009ZZ và ZZ0010ZZ.
 6. Số trang được yêu cầu tối đa tùy chọn được chỉ định trong ZZ0011ZZ.
 7. Mặt nạ được chỉ định trong ZZ0012ZZ, ZZ0013ZZ,
    ZZ0014ZZ và ZZ0015ZZ.

Tìm các trang đã được viết và WP chúng ::

cấu trúc pm_scan_arg arg = {
   .size = sizeof(arg),
   .flags = PM_SCAN_CHECK_WPASYNC | PM_SCAN_CHECK_WPASYNC,
   ..
.category_mask = PAGE_IS_WRITTEN,
   .return_mask = PAGE_IS_WRITTEN,
   };

Tìm các trang đã được viết, được sao lưu tập tin, không bị hoán đổi và cả
hiện tại hoặc rất lớn::

cấu trúc pm_scan_arg arg = {
   .size = sizeof(arg),
   .flags = 0,
   ..
.category_mask = PAGE_IS_WRITTEN | PAGE_IS_SWAPPED,
   .category_inverted = PAGE_IS_SWAPPED,
   .category_anyof_mask = PAGE_IS_PRESENT | PAGE_IS_HUGE,
   .return_mask = PAGE_IS_WRITTEN ZZ0000ZZ
                  PAGE_IS_PRESENT | PAGE_IS_HUGE,
   };

Cờ ZZ0000ZZ có thể được coi là một giải pháp thay thế hoạt động tốt hơn
của lá cờ bẩn mềm. Nó không bị ảnh hưởng bởi việc hợp nhất kernel VMA và do đó
người dùng có thể tìm thấy các trang bẩn mềm thực sự trong trường hợp các trang bình thường. (Có thể có
vẫn là các trang bẩn bổ sung được báo cáo cho các trang THP hoặc Hugetlb.)

Danh mục "PAGE_IS_WRITTEN" được sử dụng với phạm vi kích hoạt tính năng bảo vệ ghi uffd để
triển khai theo dõi lỗi bộ nhớ trong không gian người dùng:

1. Bộ mô tả tệp userfaultfd được tạo bằng syscall ZZ0000ZZ.
 2. Tính năng ZZ0001ZZ và ZZ0002ZZ
    được thiết lập bởi ZZ0003ZZ IOCTL.
 3. Phạm vi bộ nhớ được đăng ký với chế độ ZZ0004ZZ
    thông qua ZZ0005ZZ IOCTL.
 4. Sau đó, bất kỳ phần nào của bộ nhớ đã đăng ký hoặc toàn bộ vùng bộ nhớ phải
    được bảo vệ ghi bằng ZZ0006ZZ IOCTL có cờ ZZ0007ZZ
    hoặc có thể sử dụng ZZ0008ZZ IOCTL. Cả hai đều thực hiện
    hoạt động tương tự. Cái trước tốt hơn về mặt hiệu suất.
 5. Bây giờ ZZ0009ZZ IOCTL có thể được sử dụng để tìm các trang
    đã được ghi vào kể từ khi chúng được đánh dấu lần cuối và/hoặc tùy chọn viết bảo vệ
    các trang cũng vậy.
