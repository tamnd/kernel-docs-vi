.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/kdump/vmcoreinfo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
VMCOREINFO
==========

Nó là gì?
===========

VMCOREINFO là phần ghi chú ELF đặc biệt. Nó chứa nhiều
thông tin từ kernel như kích thước cấu trúc, kích thước trang, ký hiệu
giá trị, độ lệch trường, v.v. Những dữ liệu này được đóng gói trong ghi chú ELF
và được sử dụng bởi các công cụ trong không gian người dùng như Crash và makedumpfile để
phân tích bố cục bộ nhớ của kernel.

Biến chung
================

init_uts_ns.name.release
------------------------

Phiên bản của nhân Linux. Dùng để tìm nguồn tương ứng
mã mà hạt nhân đã được xây dựng. Ví dụ: sự cố sử dụng nó để
tìm vmlinux tương ứng để xử lý vmcore.

PAGE_SIZE
---------

Kích thước của một trang. Đây là đơn vị dữ liệu nhỏ nhất được bộ nhớ sử dụng
cơ sở vật chất quản lý. Nó thường có kích thước 4096 byte và một trang
căn chỉnh trên 4096 byte. Được sử dụng để tính toán địa chỉ trang.

init_uts_ns
-----------

Không gian tên UTS được sử dụng để tách biệt hai thành phần cụ thể của
system liên quan đến lệnh gọi hệ thống uname(2). Nó được đặt tên theo
cấu trúc dữ liệu được sử dụng để lưu trữ thông tin được trả về bởi hệ thống uname(2)
gọi.

Công cụ không gian người dùng có thể lấy tên kernel, tên máy chủ, bản phát hành kernel
số, phiên bản kernel, tên kiến trúc và loại hệ điều hành từ nó.

(uts_namespace, tên)
---------------------

Offset của tên thành viên. Crash Utility và Makedumpfile nhận được
địa chỉ bắt đầu của init_uts_ns.name từ đây.

nút_online_map
---------------

Một mảng node_states[N_ONLINE] đại diện cho tập hợp các nút trực tuyến
trong một hệ thống, một vị trí bit cho mỗi số nút. Dùng để theo dõi
các nút nào trong hệ thống và trực tuyến.

swapper_pg_dir
--------------

Con trỏ thư mục trang chung của kernel. Dùng để dịch
địa chỉ ảo sang địa chỉ vật lý.

_văn bản
------

Xác định phần đầu của phần văn bản. Nói chung, _stext chỉ ra
địa chỉ bắt đầu kernel. Được sử dụng để chuyển đổi một địa chỉ ảo từ
bản đồ hạt nhân trực tiếp tới một địa chỉ vật lý.

VMALLOC_START
-------------

Lưu trữ địa chỉ cơ sở của khu vực vmalloc. makedumpfile nhận giá trị này
vì cần thiết cho bản dịch vmalloc.

mem_map
-------

Địa chỉ vật lý được dịch sang các trang cấu trúc bằng cách xử lý chúng như
một chỉ mục vào mảng mem_map. Dịch chuyển phải một địa chỉ vật lý
Các bit PAGE_SHIFT chuyển đổi nó thành số khung trang là một chỉ mục
vào mảng mem_map đó.

Được sử dụng để ánh xạ một địa chỉ tới trang cấu trúc tương ứng.

contig_page_data
----------------

Makedumpfile lấy cấu trúc pglist_data từ biểu tượng này, đó là
được sử dụng để mô tả cách bố trí bộ nhớ.

Công cụ không gian người dùng sử dụng tính năng này để loại trừ các trang trống khi sử dụng bộ nhớ.

mem_section|(mem_section, NR_SECTION_ROOTS)|(mem_section, part_mem_map)
--------------------------------------------------------------------------

Địa chỉ của mảng mem_section, độ dài, kích thước cấu trúc và
phần bù phần_mem_map.

Nó tồn tại trong mô hình ánh xạ bộ nhớ thưa và nó cũng có phần
tương tự như biến mem_map, cả hai đều được sử dụng để dịch một
địa chỉ.

MAX_PHYSMEM_BITS
----------------

Xác định bộ nhớ không gian địa chỉ vật lý được hỗ trợ tối đa.

trang
----

Kích thước của cấu trúc trang. trang struct là một cấu trúc dữ liệu quan trọng
và nó được sử dụng rộng rãi để tính toán bộ nhớ liền kề.

pglist_data
-----------

Kích thước của cấu trúc pglist_data. Giá trị này được sử dụng để kiểm tra xem
cấu trúc pglist_data là hợp lệ. Nó cũng được sử dụng để kiểm tra bộ nhớ
loại.

vùng
----

Kích thước của một cấu trúc vùng. Giá trị này được sử dụng để kiểm tra xem vùng
cấu trúc đã được tìm thấy. Nó cũng được sử dụng để loại trừ các trang miễn phí.

khu vực miễn phí
---------

Kích thước của cấu trúc free_area. Nó cho biết liệu free_area
cấu trúc có hợp lệ hay không. Hữu ích khi loại trừ các trang miễn phí.

danh sách_head
---------

Kích thước của cấu trúc list_head. Được sử dụng khi lặp lại danh sách trong một
phiên phân tích sau khi chết.

nútmask_t
----------

Kích thước của loại nodemask_t. Dùng để tính số lượng trực tuyến
nút.

(trang, flags|_refcount|mapping|lru|_mapcount|private|comound_order|comound_info)
----------------------------------------------------------------------------------

Các công cụ trong không gian người dùng tính toán các giá trị của chúng dựa trên độ lệch của các giá trị này
các biến. Các biến được sử dụng khi loại trừ các trang không cần thiết.

(pglist_data, node_zones|nr_zones|node_mem_map|node_start_pfn|node_spanned_pages|node_id)
-----------------------------------------------------------------------------------------

Trên các máy NUMA, mỗi nút NUMA có pg_data_t để mô tả bộ nhớ của nó
bố cục. Trên các máy UMA có một pglist_data mô tả
toàn bộ bộ nhớ.

Những giá trị này được sử dụng để kiểm tra loại bộ nhớ và tính toán
địa chỉ ảo cho bản đồ bộ nhớ.

(vùng, free_area|vm_stat|spanned_pages)
---------------------------------------

Mỗi nút được chia thành một số khối gọi là vùng
đại diện cho phạm vi trong bộ nhớ. Một vùng được mô tả bằng một vùng cấu trúc.

Công cụ không gian người dùng tính toán các giá trị cần thiết dựa trên độ lệch của các giá trị này
các biến.

(free_area, free_list)
----------------------

Phần bù của thành viên free_list. Giá trị này được sử dụng để tính số
của các trang miễn phí.

Mỗi vùng có một mảng cấu trúc free_area được gọi là free_area[NR_PAGE_ORDERS].
free_list đại diện cho một danh sách liên kết các khối trang miễn phí.

(list_head, tiếp theo|trước)
----------------------

Độ lệch của các thành viên list_head. list_head được sử dụng để xác định một
danh sách liên kết vòng. Các công cụ trong không gian người dùng cần những công cụ này để duyệt qua
danh sách.

(vmap_area, va_start|danh sách)
--------------------------

Phần bù của các thành viên vmap_area. Họ mang theo vmalloc cụ thể
thông tin. Makedumpfile lấy địa chỉ bắt đầu của vùng vmalloc
từ đây.

(zone.free_area, NR_PAGE_ORDERS)
--------------------------------

Mô tả khu vực miễn phí. Công cụ không gian người dùng sử dụng giá trị này để lặp lại
phạm vi free_area. NR_PAGE_ORDERS được sử dụng bởi bộ cấp phát bạn bè vùng.

prb
---

Một con trỏ tới bộ đệm vòng printk (struct printk_ringbuffer). Cái này
có thể trỏ đến bộ đệm khởi động tĩnh hoặc động
bộ đệm vòng được phân bổ, tùy thuộc vào thời điểm xảy ra kết xuất lõi.
Được sử dụng bởi các công cụ không gian người dùng để đọc bộ đệm nhật ký kernel đang hoạt động.

printk_rb_static
----------------

Một con trỏ tới bộ đệm vòng printk khởi động tĩnh. Nếu @prb có
giá trị khác nhau, điều này rất hữu ích để xem các thông báo khởi động ban đầu,
có thể đã bị ghi đè trong phần được phân bổ động
ringbuffer.

Clear_seq
---------

Số thứ tự của bản ghi printk() sau lần xóa cuối cùng
lệnh. Nó chỉ ra bản ghi đầu tiên sau bản ghi cuối cùng
SYSLOG_ACTION_CLEAR, giống như do 'dmesg -c' phát hành. Được sử dụng bởi không gian người dùng
công cụ để kết xuất một tập hợp con của nhật ký dmesg.

printk_ringbuffer
-----------------

Kích thước của cấu trúc printk_ringbuffer. Cấu trúc này chứa tất cả
thông tin cần thiết để truy cập các thành phần khác nhau của
bộ đệm nhật ký kernel.

(printk_ringbuffer, desc_ring|text_data_ring|dict_data_ring|thất bại)
-----------------------------------------------------------------

Độ lệch cho các thành phần khác nhau của bộ đệm vòng printk. Được sử dụng bởi
công cụ không gian người dùng để xem bộ đệm nhật ký kernel mà không yêu cầu
khai báo cấu trúc.

prb_desc_ring
-------------

Kích thước của cấu trúc prb_desc_ring. Cấu trúc này chứa
thông tin về tập hợp các mô tả bản ghi.

(prb_desc_ring, count_bits|descs|head_id|tail_id)
-------------------------------------------------

Độ lệch cho các trường mô tả bộ mô tả bản ghi. đã qua sử dụng
bằng các công cụ không gian người dùng để có thể duyệt qua các bộ mô tả mà không cần
yêu cầu khai báo cấu trúc.

prb_desc
--------

Kích thước của cấu trúc prb_desc. Cấu trúc này chứa
thông tin về một bộ mô tả bản ghi duy nhất.

(prb_desc, info|state_var|text_blk_lpos|dict_blk_lpos)
------------------------------------------------------

Giá trị chênh lệch cho các trường mô tả bộ mô tả bản ghi. Được sử dụng bởi
công cụ không gian người dùng để có thể đọc mô tả mà không cần
sự khai báo của cấu trúc.

prb_data_blk_lpos
-----------------

Kích thước của cấu trúc prb_data_blk_lpos. Cấu trúc này chứa
thông tin về vị trí của dữ liệu văn bản hoặc từ điển (khối dữ liệu)
nằm trong vòng dữ liệu tương ứng.

(prb_data_blk_lpos, bắt đầu|tiếp theo)
-------------------------------

Độ lệch cho các trường mô tả vị trí của khối dữ liệu. đã qua sử dụng
bằng các công cụ không gian người dùng để có thể định vị các khối dữ liệu mà không cần
yêu cầu khai báo cấu trúc.

printk_info
-----------

Kích thước của cấu trúc printk_info. Cấu trúc này chứa tất cả
siêu dữ liệu cho một bản ghi.

(printk_info, seq|ts_nsec|text_len|dict_len|caller_id)
------------------------------------------------------

Giá trị chênh lệch cho các trường cung cấp siêu dữ liệu cho bản ghi. Được sử dụng bởi
công cụ không gian người dùng để có thể đọc thông tin mà không cần
sự khai báo của cấu trúc.

prb_data_ring
-------------

Kích thước của cấu trúc prb_data_ring. Cấu trúc này chứa
thông tin về một tập hợp các khối dữ liệu.

(prb_data_ring, size_bits|data|head_lpos|tail_lpos)
---------------------------------------------------

Độ lệch cho các trường mô tả một tập hợp các khối dữ liệu. Được sử dụng bởi
công cụ không gian người dùng để có thể truy cập các khối dữ liệu mà không cần
yêu cầu khai báo cấu trúc.

nguyên tử_long_t
-------------

Kích thước của cấu trúc Atomic_long_t. Được sử dụng bởi các công cụ không gian người dùng để
có thể sao chép toàn bộ cấu trúc, bất kể nó
triển khai theo kiến trúc cụ thể.

(atomic_long_t, bộ đếm)
------------------------

Bù đắp cho giá trị dài của biến Atomic_long_t. Được sử dụng bởi
công cụ không gian người dùng để truy cập giá trị dài mà không yêu cầu
khai báo kiến trúc cụ thể.

(free_area.free_list, MIGRATE_TYPES)
------------------------------------

Số lượng loại di chuyển cho các trang. free_list được mô tả bởi
mảng. Được sử dụng bởi các công cụ để tính toán số lượng trang miễn phí.

NR_FREE_PAGES
-------------

Trên linux-2.6.21 trở lên, số lượng trang miễn phí nằm trong
vm_stat[NR_FREE_PAGES]. Được sử dụng để lấy số lượng trang miễn phí.

PG_lru|PG_private|PG_swapcache|PG_swapbacked|PG_hwpoison|PG_head_mask
--------------------------------------------------------------------------

Thuộc tính trang. Những lá cờ này được sử dụng để lọc những thứ không cần thiết cho
trang bán phá giá.

PAGE_SLAB_MAPCOUNT_VALUEZZ0000ZZPAGE_OFFLINE_MAPCOUNT_VALUEZZ0001ZZPAGE_UNACCEPTED_MAPCOUNT_VALUE
------------------------------------------------------------------------------------------------------------------------------------------

Nhiều thuộc tính trang hơn. Những lá cờ này được sử dụng để lọc những thứ không cần thiết cho
trang bán phá giá.


x86_64
======

cơ sở vật lý
---------

Được sử dụng để chuyển đổi địa chỉ ảo của biểu tượng hạt nhân đã xuất sang địa chỉ ảo của nó
địa chỉ vật lý tương ứng.

init_top_pgt
------------

Được sử dụng để duyệt toàn bộ bảng trang và chuyển đổi địa chỉ ảo
tới các địa chỉ vật lý. init_top_pgt có phần giống với
swapper_pg_dir, nhưng nó chỉ được sử dụng trong x86_64.

pgtable_l5_enabled
------------------

Các công cụ trong không gian người dùng cần biết liệu kernel bị lỗi có ở cấp độ 5 hay không
chế độ phân trang.

dữ liệu nút
---------

Đây là mảng cấu trúc pglist_data và lưu trữ tất cả các nút NUMA
thông tin. Makedumpfile lấy cấu trúc pglist_data từ nó.

(node_data, MAX_NUMNODES)
-------------------------

Số lượng nút tối đa trong hệ thống.

KERNELOFFSET
------------

Phần bù ngẫu nhiên hạt nhân. Được sử dụng để tính toán độ lệch trang. Nếu
KASLR bị vô hiệu hóa, giá trị này bằng 0.

KERNEL_IMAGE_SIZE
-----------------

Hiện không được Makedumpfile sử dụng. Dùng để tính toán module ảo
địa chỉ của Crash.

sme_mask
--------

Dành riêng cho AMD có hỗ trợ SME: nó biểu thị mã hóa bộ nhớ an toàn
mặt nạ. Các công cụ Makedumpfile cần biết liệu kernel bị lỗi có phải là
được mã hóa. Nếu SME được bật trong kernel đầu tiên, kernel bị lỗi
các mục trong bảng trang (pgd/pud/pmd/pte) chứa mã hóa bộ nhớ
mặt nạ. Điều này được sử dụng để loại bỏ mặt nạ SME và có được vật lý thực sự
địa chỉ.

Hiện tại, sme_mask lưu trữ giá trị của vị trí bit C. Nếu cần,
thông tin bổ sung liên quan đến SME có thể được đặt trong biến đó.

Ví dụ::

[ linh tinh ][ bit enc ][ thông tin SME linh tinh khác ]
  0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_..._0000
  63 59 55 51 47 43 39 35 31 27 ... 3

x86_32
======

X86_PAE
-------

Biểu thị xem tiện ích mở rộng địa chỉ vật lý có được bật hay không. Nó có chi phí
chi phí tra cứu bảng trang cao hơn và cũng tiêu tốn nhiều trang hơn
không gian bảng trên mỗi tiến trình. Được sử dụng để kiểm tra xem PAE có được bật trong
hỏng kernel khi chuyển đổi địa chỉ ảo thành địa chỉ vật lý.

ARM64
=====

VA_BITS
-------

Số bit tối đa cho địa chỉ ảo. Dùng để tính toán
phạm vi bộ nhớ ảo.

kimage_voffset
--------------

Sự chênh lệch giữa ánh xạ ảo và vật lý của kernel. Đã từng
dịch địa chỉ ảo sang địa chỉ vật lý.

PHYS_OFFSET
-----------

Cho biết địa chỉ vật lý của nơi bắt đầu bộ nhớ. Tương tự như
kimage_voffset, được sử dụng để dịch ảo sang vật lý
địa chỉ.

KERNELOFFSET
------------

Phần bù ngẫu nhiên hạt nhân. Được sử dụng để tính toán độ lệch trang. Nếu
KASLR bị vô hiệu hóa, giá trị này bằng 0.

KERNELPACMASK
-------------

Mặt nạ để trích xuất Mã xác thực con trỏ từ hạt nhân ảo
địa chỉ.

TCR_EL1.T1SZ
------------

Cho biết độ lệch kích thước của vùng bộ nhớ được xử lý bởi TTBR1_EL1.
Kích thước vùng là 2^(64-T1SZ) byte.

TTBR1_EL1 là thanh ghi địa chỉ cơ sở bảng được chỉ định bởi ARMv8-A
kiến trúc được sử dụng để tra cứu các bảng trang cho Virtual
địa chỉ trong phạm vi VA cao hơn (tham khảo tài liệu ARMv8 ARM để biết
biết thêm chi tiết).

MODULES_VADDRZZ0000ZZVMALLOC_STARTZZ0001ZZVMEMMAP_START|VMEMMAP_END
-----------------------------------------------------------------------------

Được sử dụng để có được phạm vi chính xác:
	MODULES_VADDR ~ MODULES_END-1 : Không gian mô-đun hạt nhân.
	VMALLOC_START ~ VMALLOC_END-1 : không gian vmalloc() / ioremap().
	VMEMMAP_START ~ VMEMMAP_END-1 : vùng vmemmap, dùng cho mảng trang struct.

cánh tay
===

ARM_LPAE
--------

Nó cho biết liệu kernel bị lỗi có hỗ trợ địa chỉ vật lý lớn hay không
phần mở rộng. Được sử dụng để dịch địa chỉ ảo sang địa chỉ vật lý.

s390
====

lowcore_ptr
-----------

Một mảng có con trỏ tới lõi thấp của mọi CPU. Được sử dụng để in
psw và tất cả thông tin đăng ký.

bộ nhớ cao
-----------

Được sử dụng để lấy địa chỉ vmalloc_start từ biểu tượng high_memory.

(lowcore_ptr, NR_CPUS)
----------------------

Số lượng CPU tối đa.

máy tính điện
=======


nút_data|(node_data, MAX_NUMNODES)
-----------------------------------

Xem ở trên.

contig_page_data
----------------

Xem ở trên.

vmemmap_list
------------

vmemmap_list duy trì toàn bộ ánh xạ vật lý vmemmap. đã qua sử dụng
để lấy số lượng danh sách vmemmap và thông tin khu vực vmemmap đông dân. Nếu
Thông tin dịch địa chỉ vmemmap được lưu trữ trong kernel bị lỗi,
nó được sử dụng để dịch các địa chỉ ảo kernel vmemmap.

mmu_vmemmap_psize
-----------------

Kích thước của một trang. Được sử dụng để dịch địa chỉ ảo sang địa chỉ vật lý.

mmu_psize_defs
--------------

Định nghĩa kích thước trang, tức là 4k, 64k hoặc 16M.

Dùng để thực hiện các bản dịch vtop.

vmemmap_backing|(vmemmap_backing, list)|(vmemmap_backing, Phys)|(vmemmap_backing, virt_addr)
--------------------------------------------------------------------------------------------

Việc quản lý không gian địa chỉ ảo vmemmap không có cách quản lý truyền thống
bảng trang để theo dõi những trang cấu trúc ảo nào được hỗ trợ bởi một trang vật lý
lập bản đồ. Ánh xạ ảo đến vật lý được theo dõi trong một liên kết đơn giản
định dạng danh sách.

Các công cụ trong không gian người dùng cần biết phần bù của danh sách, vật lý và virt_addr
khi tính toán số vùng vmemmap.

mmu_psize_def|(mmu_psize_def, shift)
------------------------------------

Kích thước của cấu trúc mmu_psize_def và độ lệch của mmu_psize_def
thành viên.

Được sử dụng trong các bản dịch vtop.

sh
==

nút_data|(node_data, MAX_NUMNODES)
-----------------------------------

Xem ở trên.

X2TLB
-----

Cho biết liệu hạt nhân bị hỏng có bật chế độ mở rộng SH hay không.

RISCV64
=======

VA_BITS
-------

Số bit tối đa cho địa chỉ ảo. Dùng để tính toán
phạm vi bộ nhớ ảo.

PAGE_OFFSET
-----------

Cho biết địa chỉ bắt đầu hạt nhân ảo của vùng RAM được ánh xạ trực tiếp.

cơ sở vật lý_ram_base
-------------

Cho biết địa chỉ RAM vật lý bắt đầu.

MODULES_VADDRZZ0000ZZVMALLOC_STARTZZ0001ZZVMEMMAP_STARTZZ0002ZZKERNEL_LINK_ADDR
----------------------------------------------------------------------------------------------

Được sử dụng để có được phạm vi chính xác:

* MODULES_VADDR ~ MODULES_END : Không gian mô-đun hạt nhân.
  * VMALLOC_START ~ VMALLOC_END : không gian vmalloc() / ioremap().
  * VMEMMAP_START ~ VMEMMAP_END : không gian vmemmap, dùng cho mảng trang struct.
  * KERNEL_LINK_ADDR: địa chỉ bắt đầu của Kernel link và BPF

va_kernel_pa_offset
-------------------

Cho biết độ lệch giữa ánh xạ ảo và vật lý của kernel.
Được sử dụng để dịch địa chỉ ảo sang địa chỉ vật lý.
