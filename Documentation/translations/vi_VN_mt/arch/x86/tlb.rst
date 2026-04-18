.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/tlb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======
TLB
=======

Khi kernel hủy ánh xạ hoặc sửa đổi các thuộc tính của một phạm vi
bộ nhớ, nó có hai lựa chọn:

1. Xả toàn bộ TLB bằng trình tự hai lệnh.  Đây là
    một hoạt động nhanh chóng, nhưng nó gây ra thiệt hại tài sản thế chấp: các mục TLB
    từ các khu vực khác ngoài khu vực chúng tôi đang cố gắng xả sẽ
    bị phá hủy và phải được nạp lại sau đó với một mức giá nào đó.
 2. Sử dụng lệnh invlpg để vô hiệu hóa một trang tại một thời điểm
    thời gian.  Điều này có thể tốn nhiều hướng dẫn hơn, nhưng
    đó là một hoạt động chính xác hơn nhiều, không có tài sản thế chấp
    thiệt hại cho các mục TLB khác.

Phương pháp nào để thực hiện phụ thuộc vào một số điều:

1. Kích thước của lần xả được thực hiện.  Một sự tuôn ra của toàn bộ
    không gian địa chỉ rõ ràng được thực hiện tốt hơn bằng cách xóa
    toàn bộ TLB thay vì thực hiện 2^48/PAGE_SIZE lần xả riêng lẻ.
 2. Nội dung của TLB.  Nếu TLB trống thì sẽ có
    không có thiệt hại tài sản thế chấp do thực hiện việc xả toàn cầu và
    tất cả các lần xả riêng lẻ sẽ bị lãng phí
    làm việc.
 3. Kích thước của TLB.  TLB càng lớn thì càng có nhiều tài sản thế chấp
    thiệt hại chúng ta gây ra khi xả nước hoàn toàn.  Vì vậy, TLB càng lớn thì
    hấp dẫn hơn một vẻ ngoài cá tính.  Dữ liệu và
    hướng dẫn có TLB riêng biệt, cũng như các kích thước trang khác nhau.
 4. Vi kiến ​​trúc.  TLB đã trở thành thiết bị đa cấp
    bộ nhớ đệm trên các CPU hiện đại và việc xóa toàn bộ dữ liệu đã trở nên phổ biến hơn.
    đắt tiền so với việc xóa một trang.

Rõ ràng là không có cách nào mà kernel có thể biết tất cả những điều này,
đặc biệt là nội dung của TLB trong một lần xả nhất định.  các
kích thước của quá trình xả sẽ thay đổi rất nhiều tùy thuộc vào khối lượng công việc cũng như
tốt.  Về cơ bản không có điểm "đúng" để lựa chọn.

Bạn có thể đang thực hiện quá nhiều lần vô hiệu hóa riêng lẻ nếu bạn thấy
hướng dẫn invlpg (hoặc hướng dẫn _gần_ nó) hiển thị ở vị trí cao
hồ sơ.  Nếu bạn tin rằng sự vô hiệu của cá nhân
được gọi quá thường xuyên, bạn có thể hạ thấp mức điều chỉnh::

/sys/kernel/debug/x86/tlb_single_page_flush_ceiling

Điều này sẽ khiến chúng tôi phải thực hiện việc thanh lọc toàn cầu cho nhiều trường hợp hơn.
Việc giảm nó xuống 0 sẽ vô hiệu hóa việc sử dụng các lần xả riêng lẻ.
Đặt nó thành 1 là một cài đặt rất thận trọng và nó nên
không bao giờ cần phải bằng 0 trong trường hợp bình thường.

Mặc dù thực tế là một lần xả riêng lẻ trên x86 là
được đảm bảo xả đầy đủ 2MB [1]_, Hugetlbfs luôn sử dụng toàn bộ
đỏ bừng.  THP được xử lý giống hệt như bộ nhớ thông thường.

Bạn có thể thấy invlpg bên trong Flush_tlb_mm_range() hiển thị trong
profile hoặc bạn có thể sử dụng các điểm theo dõi trace_tlb_flush(). để
xác định thời gian thực hiện các thao tác xả.

Về cơ bản, bạn đang cân bằng các chu kỳ bạn thực hiện invlpg.
với chu kỳ bạn đổ đầy TLB sau này.

Bạn có thể đo mức độ đắt tiền của việc nạp TLB bằng cách sử dụng
bộ đếm hiệu suất và 'chỉ số hiệu suất', như thế này::

trạng thái hoàn hảo -e
    cpu/sự kiện=0x8,umask=0x84,name=dtlb_load_misses_walk_duration/,
    cpu/sự kiện=0x8,umask=0x82,name=dtlb_load_misses_walk_completed/,
    cpu/sự kiện=0x49,umask=0x4,name=dtlb_store_misses_walk_duration/,
    cpu/sự kiện=0x49,umask=0x2,name=dtlb_store_misses_walk_completed/,
    cpu/sự kiện=0x85,umask=0x4,name=itlb_misses_walk_duration/,
    cpu/sự kiện=0x85,umask=0x2,name=itlb_misses_walk_completed/

Tính năng này hoạt động trên CPU thời IvyBridge (i5-3320M).  CPU khác nhau
có thể có các bộ đếm được đặt tên khác nhau, nhưng ít nhất chúng phải
ở đó dưới một hình thức nào đó.  Bạn có thể sử dụng 'danh sách ocperf' của công cụ pmu
(ZZ0000ZZ để tìm đúng
bộ đếm cho một CPU nhất định.

.. [1] A footnote in Intel's SDM "4.10.4.2 Recommended Invalidation"
   says: "One execution of INVLPG is sufficient even for a page
   with size greater than 4 KBytes."