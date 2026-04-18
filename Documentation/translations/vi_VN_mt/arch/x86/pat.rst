.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/pat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
PAT (Bảng thuộc tính trang)
==========================

Bảng thuộc tính trang x86 (PAT) cho phép thiết lập thuộc tính bộ nhớ ở
mức độ chi tiết ở cấp độ trang. PAT bổ sung cho cài đặt MTRR cho phép
để thiết lập các loại bộ nhớ trên phạm vi địa chỉ vật lý. Tuy nhiên, PAT là
linh hoạt hơn MTRR do khả năng đặt thuộc tính ở cấp trang
và cũng do thực tế là không có giới hạn phần cứng về số lượng
cài đặt thuộc tính như vậy được cho phép. Tính linh hoạt được bổ sung đi kèm với các hướng dẫn dành cho
không có bí danh loại bộ nhớ cho cùng một bộ nhớ vật lý với nhiều
các địa chỉ ảo

PAT cho phép các loại thuộc tính bộ nhớ khác nhau. Được sử dụng phổ biến nhất
những cái sẽ được hỗ trợ tại thời điểm này là:

=== ================
WB Viết lại
UC chưa được lưu vào bộ nhớ đệm
WC Viết kết hợp
Viết qua WT
UC- Điểm trừ không được lưu vào bộ nhớ cache
=== ================


API PAT
========

Có nhiều API khác nhau trong kernel cho phép thiết lập bộ nhớ
thuộc tính ở cấp độ trang. Để tránh hiện tượng răng cưa, các giao diện này
nên sử dụng một cách chu đáo. Dưới đây là bảng giao diện có sẵn,
mục đích sử dụng dự định và mối quan hệ thuộc tính bộ nhớ của chúng. Trong nội bộ,
các API này sử dụng giao diện Reserve_memtype()/free_memtype() trên vật lý
phạm vi địa chỉ để tránh bất kỳ bí danh nào.

+---------------+----------+--------------+-------------------+
ZZ0000ZZ RAM ZZ0001ZZ Dự trữ/Lỗ |
+---------------+----------+--------------+-------------------+
ZZ0002ZZ -- ZZ0003ZZ UC- |
+---------------+----------+--------------+-------------------+
ZZ0004ZZ -- ZZ0005ZZ WB |
+---------------+----------+--------------+-------------------+
ZZ0006ZZ -- ZZ0007ZZ UC |
+---------------+----------+--------------+-------------------+
ZZ0008ZZ - Nhà vệ sinh ZZ0009ZZ |
+---------------+----------+--------------+-------------------+
ZZ0010ZZ -- ZZ0011ZZ WT |
+---------------+----------+--------------+-------------------+
ZZ0012ZZ UC- ZZ0013ZZ -- |
ZZ0014ZZ ZZ0015ZZ |
+---------------+----------+--------------+-------------------+
ZZ0016ZZ WC ZZ0017ZZ -- |
ZZ0018ZZ ZZ0019ZZ |
+---------------+----------+--------------+-------------------+
ZZ0020ZZ WT ZZ0021ZZ -- |
ZZ0022ZZ ZZ0023ZZ |
+---------------+----------+--------------+-------------------+
ZZ0024ZZ -- ZZ0025ZZ UC- |
+---------------+----------+--------------+-------------------+
ZZ0026ZZ -- Bồn cầu ZZ0027ZZ |
ZZ0028ZZ ZZ0029ZZ |
+---------------+----------+--------------+-------------------+
ZZ0030ZZ -- ZZ0031ZZ UC- |
ZZ0032ZZ ZZ0033ZZ |
+---------------+----------+--------------+-------------------+
ZZ0034ZZ -- Bồn cầu ZZ0035ZZ |
ZZ0036ZZ ZZ0037ZZ |
+---------------+----------+--------------+-------------------+
ZZ0038ZZ -- ZZ0039ZZ WB/WC/UC- |
ZZ0040ZZ ZZ0041ZZ |
+---------------+----------+--------------+-------------------+
ZZ0042ZZ -- ZZ0043ZZ UC- |
ZZ0044ZZ ZZ0045ZZ |
+---------------+----------+--------------+-------------------+
ZZ0046ZZ -- ZZ0047ZZ WB/WC/UC- |
ZZ0048ZZ ZZ0049ZZ |
ZZ0050ZZ ZZ0051ZZ (từ |
Bí danh ZZ0052ZZ ZZ0053ZZ) |
+---------------+----------+--------------+-------------------+
ZZ0054ZZ -- ZZ0055ZZ WB |
ZZ0056ZZ ZZ0057ZZ |
ZZ0058ZZ ZZ0059ZZ |
ZZ0060ZZ ZZ0061ZZ |
ZZ0062ZZ ZZ0063ZZ |
+---------------+----------+--------------+-------------------+
ZZ0064ZZ -- ZZ0065ZZ UC- |
ZZ0066ZZ ZZ0067ZZ |
ZZ0068ZZ ZZ0069ZZ |
ZZ0070ZZ ZZ0071ZZ |
ZZ0072ZZ ZZ0073ZZ |
+---------------+----------+--------------+-------------------+


API nâng cao cho trình điều khiển
=========================

A. Xuất trang cho người dùng với remap_pfn_range, io_remap_pfn_range,
vmf_insert_pfn.

Trình điều khiển muốn xuất một số trang sang không gian người dùng hãy thực hiện điều đó bằng cách sử dụng mmap
giao diện và sự kết hợp của:

1) pgrot_noncached()
  2) io_remap_pfn_range() hoặc remap_pfn_range() hoặc vmf_insert_pfn()

Với sự hỗ trợ của PAT, một pgprot_writecombine API mới đang được thêm vào. Vì vậy, người lái xe có thể
tiếp tục sử dụng trình tự trên, với pgrot_noncached() hoặc
pgprot_writecombine() ở bước 1, tiếp theo là bước 2.

Ngoài ra, bước 2 theo dõi nội bộ vùng dưới dạng UC hoặc WC trong memtype
list để đảm bảo không có ánh xạ xung đột.

Lưu ý rằng bộ API này chỉ hoạt động với các vùng IO (không phải RAM). Nếu lái xe
muốn xuất vùng RAM, nó phải thực hiện set_memory_uc() hoặc set_memory_wc()
như bước 0 ở trên và cũng theo dõi việc sử dụng các trang đó và sử dụng set_memory_wb()
trước khi trang được giải phóng vào nhóm miễn phí.

Hiệu ứng MTRR trên hệ thống PAT / không phải PAT
=====================================

Bảng sau đây cung cấp các tác động của việc sử dụng MTRR kết hợp ghi khi
sử dụng lệnh gọi ioremap*() trên x86 cho cả hệ thống không phải PAT và PAT. Lý tưởng nhất
Việc sử dụng mtrr_add() sẽ được loại bỏ dần để chuyển sang sử dụng Arch_phys_wc_add().
không hoạt động trên các hệ thống hỗ trợ PAT. Vùng mà trên đó Arch_phys_wc_add()
được tạo, lẽ ra đã được ánh xạ với các thuộc tính WC hoặc mục nhập PAT,
điều này có thể được thực hiện bằng cách sử dụng ioremap_wc() / set_memory_wc().  Thiết bị mà
kết hợp các vùng bộ nhớ IO mong muốn không thể lưu vào bộ nhớ đệm với các vùng có
kết hợp ghi là mong muốn nên xem xét việc sử dụng ioremap_uc() theo sau
set_memory_wc() vào danh sách trắng các khu vực kết hợp ghi hiệu quả.  Việc sử dụng như vậy là
tuy nhiên không được khuyến khích vì loại bộ nhớ hiệu quả được coi là
đã xác định việc triển khai nhưng chiến lược này có thể được sử dụng như là phương sách cuối cùng trên các thiết bị
với các vùng bị giới hạn kích thước trong đó việc kết hợp ghi MTRR sẽ
nếu không sẽ không có hiệu quả.
::

==== ======= === ========================== ========================
  MTRR Non-PAT PAT Giá trị ioremap Linux Loại bộ nhớ hiệu quả
  ==== ======= === ========================== ========================
        PAT Không phải PAT |  PAT
        ZZ0000ZZ
        |ZZ0001ZZ
        ||ZZ0002ZZ
  WC 000 WB _PAGE_CACHE_MODE_WB WC |   nhà vệ sinh
  WC 001 WC _PAGE_CACHE_MODE_WC WC* |   nhà vệ sinh
  WC 010 UC- _PAGE_CACHE_MODE_UC_MINUS WC* |   UC
  WC 011 UC _PAGE_CACHE_MODE_UC UC |   UC
  ==== ======= === ========================== ========================

(*) biểu thị việc triển khai được xác định và không được khuyến khích

.. note:: -- in the above table mean "Not suggested usage for the API". Some
  of the --'s are strictly enforced by the kernel. Some others are not really
  enforced today, but may be enforced in future.

Để truy cập ioremap và pci thông qua/sys hoặc/proc - Kiểu thực tế được trả về
có thể hạn chế hơn, trong trường hợp có bất kỳ bí danh nào hiện có cho địa chỉ đó.
Ví dụ: Nếu có một ánh xạ chưa được lưu vào bộ nhớ đệm hiện có, ioremap_wc mới có thể
trả về ánh xạ không được lưu trong bộ nhớ đệm thay cho yêu cầu kết hợp ghi.

set_memory_[uc|wc|wt] và set_memory_wb nên được sử dụng theo cặp, trong đó trình điều khiển
đầu tiên sẽ tạo một vùng uc, wc hoặc wt và chuyển nó trở lại wb sau khi sử dụng.

Theo thời gian, việc ghi vào /proc/mtrr sẽ không được dùng nữa để sử dụng dựa trên PAT
giao diện. Người dùng viết thư tới /proc/mtrr được đề xuất sử dụng các giao diện trên.

Trình điều khiển nên sử dụng quyền truy cập ioremap_[uc|wc] to access PCI BARs with [uc|wc]
các loại.

Trình điều khiển nên sử dụng set_memory_[uc|wc|wt] để đặt loại truy cập cho phạm vi RAM.


Gỡ lỗi PAT
=============

Khi bật CONFIG_DEBUG_FS, danh sách memtype PAT có thể được kiểm tra bằng cách::

# mount -t debugfs debugfs/sys/kernel/debug
  # cat/sys/kernel/debug/x86/pat_memtype_list
  Danh sách loại ghi nhớ PAT:
  uncached-trừ @ 0x7fadf000-0x7fae0000
  uncached-trừ @ 0x7fb19000-0x7fb1a000
  uncached-trừ @ 0x7fb1a000-0x7fb1b000
  uncached-trừ @ 0x7fb1b000-0x7fb1c000
  không được lưu vào bộ nhớ đệm @ 0x7fb1c000-0x7fb1d000
  uncached-trừ @ 0x7fb1d000-0x7fb1e000
  uncached-trừ @ 0x7fb1e000-0x7fb25000
  uncached-trừ @ 0x7fb25000-0x7fb26000
  uncached-trừ @ 0x7fb26000-0x7fb27000
  uncached-trừ @ 0x7fb27000-0x7fb28000
  uncached-trừ @ 0x7fb28000-0x7fb2e000
  uncached-trừ @ 0x7fb2e000-0x7fb2f000
  uncached-trừ @ 0x7fb2f000-0x7fb30000
  uncached-trừ @ 0x7fb31000-0x7fb32000
  không được lưu trữ-trừ @ 0x80000000-0x90000000

Danh sách này hiển thị các dải địa chỉ vật lý và các cài đặt PAT khác nhau được sử dụng để
truy cập các dải địa chỉ vật lý đó.

Một cách khác dài dòng hơn để nhận các thông báo gỡ lỗi liên quan đến PAT là dùng
tham số khởi động "gỡ lỗi". Với tham số này, nhiều thông báo gỡ lỗi khác nhau sẽ được
được in ra nhật ký dmesg.

Khởi tạo PAT
==================

Bảng sau đây mô tả cách PAT được khởi tạo trong các điều kiện khác nhau
cấu hình. PAT MSR phải được Linux cập nhật để hỗ trợ WC
và thuộc tính WT. Mặt khác, PAT MSR có giá trị được lập trình trong đó
bởi phần sụn. Lưu ý, Xen bật thuộc tính WC trong PAT MSR cho khách.

==== ================================ ========= ========
 MTRR PAT Trình tự cuộc gọi PAT Trạng thái PAT MSR
 ==== ================================ ========= ========
 E E MTRR -> PAT đã kích hoạt hệ điều hành ban đầu
 E D MTRR -> PAT ban đầu bị vô hiệu hóa -
 D E MTRR -> PAT vô hiệu hóa BIOS bị vô hiệu hóa
 D D MTRR -> tắt PAT Đã tắt -
 - np/E PAT -> PAT vô hiệu hóa BIOS bị vô hiệu hóa
 - np/D PAT -> tắt PAT Đã tắt -
 E !P/E MTRR -> PAT ban đầu Bị vô hiệu hóa BIOS
 D !P/E MTRR -> PAT tắt Đã tắt BIOS
 !M !P/E MTRR sơ khai -> PAT tắt Đã tắt BIOS
 ==== ================================ ========= ========

Huyền thoại

=====================================================
 E Tính năng được kích hoạt trong CPU
 D Tính năng bị tắt/không được hỗ trợ trong CPU
 tùy chọn khởi động np "nopat" được chỉ định
 !P Tùy chọn CONFIG_X86_PAT chưa được đặt
 Tùy chọn !M CONFIG_MTRR chưa được đặt
 Trạng thái PAT đã bật được đặt thành đã bật
 Trạng thái PAT đã tắt được đặt thành bị tắt
 OS PAT khởi tạo PAT MSR với cài đặt hệ điều hành
 BIOS PAT giữ PAT MSR với cài đặt BIOS
 =====================================================
