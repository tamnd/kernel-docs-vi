.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/vmemmap_dedup.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Chế độ ăn vmemmap dành cho HugeTLB và Thiết bị DAX
=========================================

TLB lớn
=======

Phần này giải thích cách hoạt động của HugeTLB Vmemmap Optimization (HVO).

Cấu trúc ZZ0000ZZ được sử dụng để mô tả khung trang vật lý. Bởi
mặc định, có một ánh xạ một-một từ khung trang tới khung trang tương ứng
ZZ0001ZZ.

Các trang HugeTLB bao gồm nhiều trang có kích thước trang cơ sở và được nhiều trang hỗ trợ.
kiến trúc. Xem Tài liệu/admin-guide/mm/hugetlbpage.rst để biết thêm
chi tiết. Trên kiến trúc x86-64, các trang HugeTLB có kích thước 2MB và 1GB được
hiện được hỗ trợ. Vì kích thước trang cơ sở trên x86 là 4KB nên trang HugeTLB có dung lượng 2 MB
bao gồm 512 trang cơ sở và trang HugeTLB 1GB bao gồm 262144 trang cơ sở.
Đối với mỗi trang cơ sở, có một ZZ0000ZZ tương ứng.

Trong hệ thống con HugeTLB, chỉ có 4 ZZ0000ZZ đầu tiên được sử dụng để
chứa thông tin duy nhất về trang HugeTLB. ZZ0001ZZ cung cấp
giới hạn trên này. Thông tin “hữu ích” duy nhất trong ZZ0002ZZ còn lại
là trường thông tin phức hợp và trường này giống nhau cho tất cả các trang đuôi.

Bằng cách loại bỏ ZZ0000ZZ dư thừa cho các trang HugeTLB, bộ nhớ có thể được trả lại
tới người cấp phát bạn bè cho các mục đích sử dụng khác.

Các kiến ​​trúc khác nhau hỗ trợ các trang HugeTLB khác nhau. Ví dụ,
bảng sau đây là kích thước trang HugeTLB được x86 và arm64 hỗ trợ
kiến trúc. Bởi vì arm64 hỗ trợ các trang cơ sở 4k, 16k và 64k và
hỗ trợ các mục liền kề, vì vậy nó hỗ trợ nhiều loại kích thước HugeTLB
trang.

+--------------+----------++----------------------------------------------+
ZZ0000ZZ Kích thước trang ZZ0001ZZ
+--------------+----------+-------------+----------+----------+----------+
ZZ0002ZZ 4KB ZZ0003ZZ 1GB ZZ0004ZZ |
+--------------+----------+-------------+----------+----------+----------+
ZZ0005ZZ 4KB ZZ0006ZZ 2MB ZZ0007ZZ 1GB |
|              +----------+-----------+-------------+----------+----------+
ZZ0008ZZ 16KB ZZ0009ZZ 32 MB ZZ0010ZZ |
|              +----------+-----------+-------------+----------+----------+
ZZ0011ZZ 64KB ZZ0012ZZ 512MB ZZ0013ZZ |
+--------------+----------+-------------+----------+----------+----------+

Khi hệ thống khởi động, mỗi trang HugeTLB có nhiều hơn một ZZ0000ZZ
cấu trúc có kích thước là (đơn vị: trang)::

struct_size = HugeTLB_Size / PAGE_SIZE * sizeof(trang cấu trúc) / PAGE_SIZE

Trong đó HugeTLB_Size là kích thước của trang HugeTLB. Chúng tôi biết rằng kích thước
của trang HugeTLB luôn là n lần PAGE_SIZE. Vì vậy, chúng ta có thể nhận được những điều sau đây
mối quan hệ::

HugeTLB_Size = n * PAGE_SIZE

Sau đó::

struct_size = n * PAGE_SIZE / PAGE_SIZE * sizeof(trang cấu trúc) / PAGE_SIZE
               = n * sizeof(trang cấu trúc) / PAGE_SIZE

Chúng tôi có thể sử dụng ánh xạ lớn ở cấp độ pud/pmd cho trang HugeTLB.

Đối với trang HugeTLB của ánh xạ cấp độ pmd, thì::

struct_size = n * sizeof(trang cấu trúc) / PAGE_SIZE
               = PAGE_SIZE / sizeof(pte_t) * sizeof(struct page) / PAGE_SIZE
               = sizeof(trang cấu trúc) / sizeof(pte_t)
               = 64/8
               = 8 (trang)

Trong đó n là số lượng mục pte mà một trang có thể chứa. Vì vậy giá trị của
n là (PAGE_SIZE / sizeof(pte_t)).

Tối ưu hóa này chỉ hỗ trợ hệ thống 64-bit, vì vậy giá trị của sizeof(pte_t)
là 8. Và sự tối ưu hóa này cũng chỉ áp dụng được khi kích thước của ZZ0000ZZ
là sức mạnh của hai. Trong hầu hết các trường hợp, kích thước của ZZ0001ZZ là 64 byte (ví dụ:
x86-64 và arm64). Vì vậy, nếu chúng tôi sử dụng ánh xạ mức độ pmd cho trang HugeTLB, thì
kích thước của cấu trúc ZZ0002ZZ của nó là 8 khung trang, kích thước phụ thuộc vào
kích thước của trang cơ sở.

Đối với trang HugeTLB của ánh xạ cấp độ pud, thì::

struct_size = PAGE_SIZE / sizeof(pmd_t) * struct_size(pmd)
               = PAGE_SIZE / 8 * 8 (trang)
               = PAGE_SIZE (trang)

Trong đó struct_size(pmd) là kích thước của cấu trúc ZZ0000ZZ của một
Trang HugeTLB của bản đồ cấp độ pmd.

Ví dụ: Trang HugeTLB 2MB trên x86_64 bao gồm 8 khung trang trong khi 1GB
Trang HugeTLB bao gồm 4096.

Tiếp theo, chúng tôi lấy ánh xạ cấp độ pmd của trang HugeTLB làm ví dụ cho
cho thấy việc thực hiện nội bộ của tối ưu hóa này. Có 8 trang
Các cấu trúc ZZ0000ZZ được liên kết với trang HugeTLB được ánh xạ pmd.

Đây là cách mọi thứ trông như thế nào trước khi tối ưu hóa::

Khung trang cấu trúc HugeTLB (8 trang) (8 trang)
 +----------+ ---virt_to_page---> +----------+ ánh xạ tới +-----------+
 ZZ0000ZZ ZZ0001ZZ -------------> ZZ0002ZZ
 ZZ0003ZZ +-------------+ +-------------+
 ZZ0004ZZ ZZ0005ZZ -------------> ZZ0006ZZ
 ZZ0007ZZ +-------------+ +----------+
 ZZ0008ZZ ZZ0009ZZ -------------> ZZ0010ZZ
 ZZ0011ZZ +-------------+ +----------+
 ZZ0012ZZ ZZ0013ZZ -------------> ZZ0014ZZ
 ZZ0015ZZ +-------------+ +----------+
 ZZ0016ZZ ZZ0017ZZ -------------> ZZ0018ZZ
 ZZ0019ZZ +-------------+ +-------------+
 ZZ0020ZZ ZZ0021ZZ -------------> ZZ0022ZZ
 ZZ0023ZZ +-------------+ +-------------+
 ZZ0024ZZ ZZ0025ZZ -------------> ZZ0026ZZ
 ZZ0027ZZ +-------------+ +----------+
 ZZ0028ZZ ZZ0029ZZ -------------> ZZ0030ZZ
 ZZ0031ZZ +-------------+ +----------+
 ZZ0032ZZ
 ZZ0033ZZ
 ZZ0034ZZ
 +----------+

Trang đầu tiên của ZZ0000ZZ (trang 0) được liên kết với trang HugeTLB
chứa 4 ZZ0001ZZ cần thiết để mô tả HugeTLB. Phần còn lại
các trang của ZZ0002ZZ (trang 1 đến trang 7) là trang đuôi.

Việc tối ưu hóa chỉ được áp dụng khi kích thước của trang cấu trúc là lũy thừa
của 2. Trong trường hợp này, tất cả các trang đuôi có cùng thứ tự đều giống hệt nhau. Xem
ghép_head(). Điều này cho phép chúng tôi ánh xạ lại các trang đuôi của vmemmap thành một
trang được chia sẻ, chỉ đọc. Trang đầu cũng được ánh xạ lại sang một trang mới. Cái này
cho phép các trang vmemmap gốc được giải phóng.

Đây là cách mọi thứ trông như thế nào sau khi ánh xạ lại::

Khung trang cấu trúc HugeTLB (8 trang) (mới)
 +----------+ ---virt_to_page---> +----------+ ánh xạ tới +----------------+
 ZZ0000ZZ ZZ0001ZZ -------------> ZZ0002ZZ
 ZZ0003ZZ +-------------+ +----------------+
 ZZ0004ZZ ZZ0005ZZ ------┐
 ZZ0006ZZ +-------------+ |
 ZZ0007ZZ ZZ0008ZZ ------┼ +-----------------------------+
 ZZ0009ZZ +-------------+ ZZ0010ZZ Một trang duy nhất cho mỗi khu vực |
 ZZ0011ZZ ZZ0012ZZ ------┼------> ZZ0013ZZ
 ZZ0014ZZ +-------------+ ZZ0015ZZ các trang lớn cùng kích thước |
 ZZ0016ZZ ZZ0017ZZ ------┼ +-----------------------------+
 ZZ0018ZZ +-------------+ |
 ZZ0019ZZ ZZ0020ZZ ------┼
 ZZ0021ZZ +-------------+ |
 ZZ0022ZZ ZZ0023ZZ ------┼
 ZZ0024ZZ +-------------+ |
 ZZ0025ZZ ZZ0026ZZ ------┘
 ZZ0027ZZ +-----------+
 ZZ0028ZZ
 ZZ0029ZZ
 ZZ0030ZZ
 +----------+

Khi HugeTLB được giải phóng vào hệ thống bạn bè, chúng ta nên phân bổ 7 trang cho
trang vmemmap và khôi phục mối quan hệ ánh xạ trước đó.

Đối với trang HugeTLB của bản đồ cấp độ pud. Nó tương tự như trước đây.
Chúng tôi cũng có thể sử dụng phương pháp này cho các trang vmemmap miễn phí (PAGE_SIZE - 1).

Ngoài trang HugeTLB của ánh xạ mức pmd/pud, một số kiến trúc
(ví dụ: aarch64) cung cấp một bit liền kề trong các mục trong bảng dịch
gợi ý cho MMU để chỉ ra rằng nó là một trong những tập hợp liền kề
các mục có thể được lưu vào bộ đệm trong một mục TLB.

Bit liền kề được sử dụng để tăng kích thước ánh xạ tại pmd và pte
(cuối cùng) cấp độ. Vì vậy, loại trang HugeTLB này chỉ có thể được tối ưu hóa khi nó
kích thước của cấu trúc ZZ0000ZZ lớn hơn trang ZZ0001ZZ.

Thiết bị DAX
==========

Giao diện device-dax sử dụng kỹ thuật loại bỏ trùng lặp đuôi tương tự như đã giải thích
trong chương trước, ngoại trừ khi được sử dụng với vmemmap trong
thiết bị (altmap).

Các kích thước trang sau được hỗ trợ trong DAX: PAGE_SIZE (4K trên x86_64),
PMD_SIZE (2M trên x86_64) và PUD_SIZE (1G trên x86_64).
Để biết chi tiết tương đương về powerpc, hãy xem Tài liệu/arch/powerpc/vmemmap_dedup.rst

Sự khác biệt với HugeTLB là tương đối nhỏ.

Nó chỉ sử dụng 3 ZZ0000ZZ để lưu trữ tất cả thông tin trái ngược
đến 4 trên các trang HugeTLB.

Không có ánh xạ lại vmemmap vì bộ nhớ dax của thiết bị không phải là một phần của
Phạm vi hệ thống RAM được khởi tạo khi khởi động. Do đó việc trùng lặp trang đuôi
xảy ra ở giai đoạn sau khi chúng tôi điền vào các phần. HugeTLB tái sử dụng
trang vmemmap đầu đại diện, trong khi device-dax sử dụng lại phần đuôi
trang vmemmap. Điều này dẫn đến mức tiết kiệm chỉ bằng một nửa so với HugeTLB.

Các trang đuôi bị trùng lặp không được ánh xạ ở chế độ chỉ đọc.

Đây là cách mọi thứ trông như thế nào trên device-dax sau khi các phần được điền::

+----------+ ---virt_to_page---> +----------+ ánh xạ tới +-----------+
 ZZ0000ZZ ZZ0001ZZ -------------> ZZ0002ZZ
 ZZ0003ZZ +-------------+ +----------+
 ZZ0004ZZ ZZ0005ZZ -------------> ZZ0006ZZ
 ZZ0007ZZ +-------------+ +----------+
 ZZ0008ZZ ZZ0009ZZ ----------------^ ^ ^ ^ ^ ^
 ZZ0010ZZ +-------------+ ZZ0011ZZ ZZ0012ZZ |
 ZZ0013ZZ ZZ0014ZZ -------------------+ ZZ0015ZZ ZZ0016ZZ
 ZZ0017ZZ +-------------+ ZZ0018ZZ ZZ0019ZZ
 ZZ0020ZZ ZZ0021ZZ ----------------------+ ZZ0022ZZ |
 ZZ0023ZZ +-------------+ ZZ0024ZZ |
 ZZ0025ZZ ZZ0026ZZ ----------------------+ ZZ0027ZZ
 ZZ0028ZZ +-------------+ ZZ0029ZZ
 ZZ0030ZZ ZZ0031ZZ ---------------+ |
 ZZ0032ZZ +-------------+ |
 ZZ0033ZZ ZZ0034ZZ -----------------+
 ZZ0035ZZ +-----------+
 ZZ0036ZZ
 ZZ0037ZZ
 ZZ0038ZZ
 +----------+