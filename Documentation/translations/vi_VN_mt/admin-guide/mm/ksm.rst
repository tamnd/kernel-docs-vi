.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/ksm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Hợp nhất cùng một trang hạt nhân
=======================

Tổng quan
========

KSM là tính năng khử trùng lặp tiết kiệm bộ nhớ, được kích hoạt bởi CONFIG_KSM=y,
được thêm vào nhân Linux trong 2.6.32.  Xem ZZ0000ZZ để biết cách triển khai,
và ZZ0001ZZ và ZZ0002ZZ

KSM ban đầu được phát triển để sử dụng với KVM (nơi nó được gọi là
Bộ nhớ chia sẻ hạt nhân), để phù hợp với nhiều máy ảo hơn vào bộ nhớ vật lý,
bằng cách chia sẻ dữ liệu chung giữa chúng.  Nhưng nó có thể hữu ích cho bất kỳ ai
ứng dụng tạo ra nhiều phiên bản của cùng một dữ liệu.

Daemon KSM ksmd quét định kỳ các vùng bộ nhớ người dùng đó
đã được đăng ký với nó, tìm kiếm các trang giống hệt nhau
nội dung có thể được thay thế bằng một trang được bảo vệ chống ghi (trang này
được sao chép tự động nếu một quá trình sau đó muốn cập nhật nó
nội dung). Số lượng trang mà daemon KSM quét trong một lần
và thời gian giữa các lượt được định cấu hình bằng ZZ0000ZZ

KSM chỉ hợp nhất các trang ẩn danh (riêng tư), không bao giờ hợp nhất các trang (tệp) pagecache.
Các trang được hợp nhất của KSM ban đầu bị khóa vào bộ nhớ kernel, nhưng giờ đây có thể
được hoán đổi giống như các trang người dùng khác (nhưng việc chia sẻ bị hỏng khi họ
được hoán đổi trở lại: ksmd phải khám phá lại danh tính của họ và hợp nhất lại).

Điều khiển KSM bằng madvise
============================

KSM chỉ hoạt động trên những vùng không gian địa chỉ mà ứng dụng
đã khuyên nên trở thành ứng cử viên cho việc sáp nhập, bằng cách sử dụng madvise(2)
cuộc gọi hệ thống::

int madvise(addr, chiều dài, MADV_MERGEABLE)

Ứng dụng có thể gọi

::

int madvise(addr, chiều dài, MADV_UNMERGEABLE)

để hủy lời khuyên đó và khôi phục các trang không được chia sẻ: sau đó KSM
hủy hợp nhất bất cứ thứ gì nó hợp nhất trong phạm vi đó.  Lưu ý: cuộc gọi không hợp nhất này
đột nhiên có thể cần nhiều bộ nhớ hơn mức có sẵn - có thể bị lỗi
với EAGAIN, nhưng nhiều khả năng sẽ kích động kẻ giết người hết bộ nhớ.

Nếu KSM không được cấu hình trong kernel đang chạy, madvise MADV_MERGEABLE
và MADV_UNMERGEABLE đơn giản là thất bại với EINVAL.  Nếu kernel đang chạy
được xây dựng với CONFIG_KSM=y, những cuộc gọi đó thường sẽ thành công: ngay cả khi
Daemon KSM hiện không chạy, MADV_MERGEABLE vẫn đăng ký
phạm vi cho bất cứ khi nào daemon KSM được khởi động; ngay cả khi phạm vi
không thể chứa bất kỳ trang nào mà KSM thực sự có thể hợp nhất; ngay cả khi
MADV_UNMERGEABLE được áp dụng cho phạm vi chưa bao giờ là MADV_MERGEABLE.

Nếu một vùng bộ nhớ phải được chia thành ít nhất một MADV_MERGEABLE mới
hoặc vùng MADV_UNMERGEABLE, madvise có thể trả về ENOMEM nếu quá trình
sẽ vượt quá ZZ0000ZZ (xem Tài liệu/admin-guide/sysctl/vm.rst).

Giống như các cuộc gọi madvise khác, chúng được thiết kế để sử dụng trên các khu vực được lập bản đồ của
không gian địa chỉ người dùng: họ sẽ báo cáo ENOMEM nếu phạm vi được chỉ định
bao gồm các khoảng trống chưa được lập bản đồ (mặc dù đang làm việc trên các khu vực được lập bản đồ can thiệp),
và có thể bị lỗi với EAGAIN nếu không đủ bộ nhớ cho các cấu trúc bên trong.

Các ứng dụng nên cân nhắc khi sử dụng MADV_MERGEABLE,
hạn chế sử dụng nó ở những lĩnh vực có thể có lợi.  Bản quét của KSM có thể sử dụng rất nhiều
về sức mạnh xử lý: một số cài đặt sẽ vô hiệu hóa KSM vì lý do đó.

.. _ksm_sysfs:

Giao diện sysfs daemon KSM
==========================

Daemon KSM được điều khiển bởi các tệp sysfs trong ZZ0000ZZ,
tất cả đều có thể đọc được nhưng chỉ có thể ghi bằng root:

trang_để_quét
        cần quét bao nhiêu trang trước khi ksmd đi ngủ
        ví dụ: ZZ0000ZZ.

Giá trị pages_to_scan không thể thay đổi nếu ZZ0000ZZ có
        được đặt thành thời gian quét.

Mặc định: 100 (được chọn cho mục đích trình diễn)

ngủ_millsecs
        ksmd nên ngủ bao nhiêu mili giây trước lần quét tiếp theo
        ví dụ: ZZ0000ZZ

Mặc định: 20 (được chọn cho mục đích trình diễn)

hợp nhất_across_nodes
        chỉ định xem các trang từ các nút NUMA khác nhau có thể được hợp nhất hay không.
        Khi được đặt thành 0, ksm chỉ hợp nhất các trang nằm trên thực tế
        trong vùng bộ nhớ của cùng một nút NUMA. Điều đó mang lại thấp hơn
        độ trễ để truy cập các trang được chia sẻ. Các hệ thống có nhiều nút hơn, tại
        khoảng cách NUMA đáng kể, có thể được hưởng lợi từ
        độ trễ thấp hơn của cài đặt 0. Các hệ thống nhỏ hơn cần
        giảm thiểu việc sử dụng bộ nhớ, có khả năng được hưởng lợi từ việc sử dụng nhiều hơn
        chia sẻ cài đặt 1 (mặc định). Bạn có thể muốn so sánh cách
        hệ thống của bạn hoạt động theo từng cài đặt trước khi quyết định
        sử dụng cái nào Chỉ có thể thay đổi cài đặt ZZ0000ZZ
        khi không có trang chia sẻ ksm trong hệ thống: đặt run 2 thành
        hủy hợp nhất các trang trước, sau đó thành 1 sau khi thay đổi
        ZZ0001ZZ, để kết hợp lại theo cài đặt mới.

Mặc định: 1 (hợp nhất giữa các nút như trong các bản phát hành trước đó)

chạy
        * đặt thành 0 để ngăn ksmd chạy nhưng vẫn giữ các trang được hợp nhất,
        * đặt thành 1 để chạy ksmd, vd ZZ0000ZZ,
        * đặt thành 2 để dừng ksmd và hủy hợp nhất tất cả các trang hiện được hợp nhất, nhưng
	  để lại các khu vực có thể hợp nhất được đăng ký cho lần chạy tiếp theo.

Mặc định: 0 (phải đổi thành 1 để kích hoạt KSM, trừ khi
        CONFIG_SYSFS bị vô hiệu hóa)

use_zero_pages
        chỉ định xem các trang trống (tức là các trang được phân bổ chỉ
        chứa số 0) nên được xử lý đặc biệt.  Khi đặt thành 1,
        các trang trống được hợp nhất với (các) trang kernel zero thay vì
        với nhau như chuyện bình thường. Điều này có thể cải thiện
        hiệu suất trên các kiến trúc có trang không màu,
        tùy theo khối lượng công việc. Cần thận trọng khi kích hoạt
        cài đặt này, vì nó có thể làm giảm hiệu suất của
        KSM cho một số khối lượng công việc, ví dụ: nếu tổng kiểm tra các trang
        ứng viên hợp nhất khớp với tổng kiểm tra của một khoảng trống
        trang. Cài đặt này có thể được thay đổi bất cứ lúc nào, nó chỉ
        có hiệu lực đối với các trang được hợp nhất sau khi thay đổi.

Mặc định: 0 (hoạt động KSM bình thường như trong các phiên bản trước)

max_page_sharing
        Chia sẻ tối đa được phép cho mỗi trang KSM. Điều này thực thi một
        giới hạn chống trùng lặp để tránh độ trễ cao cho bộ nhớ ảo
        các hoạt động liên quan đến việc truyền tải các ánh xạ ảo
        chia sẻ trang KSM. Giá trị tối thiểu là 2 khi mới được tạo
        Trang KSM sẽ có ít nhất hai người chia sẻ. Giá trị này càng cao
        KSM sẽ hợp nhất bộ nhớ càng nhanh và tốc độ càng cao
        hệ số khử trùng lặp sẽ lớn, nhưng trường hợp xấu nhất sẽ chậm hơn
        truyền tải ánh xạ ảo có thể dành cho bất kỳ KSM nào
        trang. Làm chậm quá trình truyền tải này có nghĩa là sẽ có tốc độ cao hơn
        độ trễ cho một số hoạt động bộ nhớ ảo nhất định xảy ra trong
        hoán đổi, nén, cân bằng NUMA và di chuyển trang, trong
        lần lượt giảm khả năng phản hồi cho người gọi ảo đó
        các thao tác bộ nhớ. Độ trễ của bộ lập lịch của các tác vụ khác không
        liên quan đến các hoạt động VM thực hiện ánh xạ ảo
        truyền tải không bị ảnh hưởng bởi tham số này vì những
        bản thân việc truyền tải luôn thân thiện với lịch trình.

ổn định_node_chains_prune_millisecs
        chỉ định tần suất KSM kiểm tra siêu dữ liệu của các trang
        đã đạt đến giới hạn chống trùng lặp đối với thông tin cũ.
        Giá trị mili giây nhỏ hơn sẽ giải phóng siêu dữ liệu KSM với
        độ trễ thấp hơn, nhưng chúng sẽ khiến ksmd sử dụng nhiều CPU hơn trong thời gian
        quét. Sẽ là vô ích nếu không có một trang KSM nào được truy cập
        ZZ0000ZZ chưa.

quét thông minh
        Trước đây KSM đã kiểm tra mọi trang ứng viên cho mỗi lần quét. Nó đã làm
        không tính đến thông tin lịch sử.  Khi quét thông minh được
        được bật, các trang trước đây chưa được loại bỏ trùng lặp sẽ nhận được
        bỏ qua. Tần suất các trang này bị bỏ qua tùy thuộc vào mức độ thường xuyên
        việc khử trùng lặp đã được thử và thất bại. Theo mặc định cái này
        tối ưu hóa được kích hoạt.  Số liệu ZZ0000ZZ cho thấy cách
        cài đặt có hiệu quả.

cố vấn_mode
        ZZ0000ZZ chọn cố vấn hiện tại. Hai chế độ là
        được hỗ trợ: không có và thời gian quét. Mặc định là không có. Bằng cách thiết lập
        ZZ0001ZZ sang thời gian quét, trình tư vấn thời gian quét được bật.
        Phần về ZZ0002ZZ giải thích chi tiết về thời gian quét
        cố vấn làm việc.

adivsor_max_cpu
        chỉ định giới hạn trên của việc sử dụng phần trăm CPU của ksmd
        sợi nền. Mặc định là 70.

cố vấn_target_scan_time
        chỉ định thời gian quét mục tiêu tính bằng giây để quét tất cả ứng viên
        trang. Giá trị mặc định là 200 giây.

cố vấn_min_pages_to_scan
        chỉ định giới hạn dưới của tham số ZZ0000ZZ của
        cố vấn thời gian quét. Mặc định là 500.

adivsor_max_pages_to_scan
        chỉ định giới hạn trên của tham số ZZ0000ZZ của
        cố vấn thời gian quét. Mặc định là 30000.

Hiệu quả của KSM và MADV_MERGEABLE được thể hiện trong ZZ0000ZZ:

chung_lợi nhuận
        KSM hiệu quả như thế nào. Việc tính toán được giải thích dưới đây.
trang_quét
        có bao nhiêu trang đang được quét cho ksm
trang_shared
        có bao nhiêu trang chia sẻ đang được sử dụng
trang_chia sẻ
        có thêm bao nhiêu trang web đang chia sẻ chúng, tức là đã tiết kiệm được bao nhiêu
trang_unshared
        có bao nhiêu trang duy nhất nhưng được kiểm tra nhiều lần để hợp nhất
trang_không ổn định
        có bao nhiêu trang thay đổi quá nhanh để có thể xếp thành một cái cây
trang_bỏ qua
        thuật toán quét trang "thông minh" đã bỏ qua bao nhiêu trang
quét đầy đủ
        bao nhiêu lần tất cả các khu vực có thể hợp nhất đã được quét
ổn định_node_chains
        số lượng trang KSM đạt đến giới hạn ZZ0000ZZ
ổn định_node_dups
        số trang KSM trùng lặp
ksm_zero_pages
        có bao nhiêu trang 0 vẫn được ánh xạ vào các quy trình đã được ánh xạ bởi
        KSM khi sao chép.

Khi ZZ0000ZZ được bật/bật, tổng của ZZ0001ZZ +
ZZ0002ZZ thể hiện số trang thực tế được KSM lưu.
nếu ZZ0003ZZ chưa bao giờ được bật thì ZZ0004ZZ là 0.

Tỷ lệ ZZ0000ZZ trên ZZ0001ZZ cao cho thấy tốt
chia sẻ, nhưng tỷ lệ ZZ0002ZZ so với ZZ0003ZZ cao
cho thấy nỗ lực lãng phí.  ZZ0004ZZ bao gồm một số
các loại hoạt động khác nhau, nhưng một tỷ lệ cao cũng sẽ có
cho thấy việc sử dụng madvise MADV_MERGEABLE không tốt.

Tỷ lệ ZZ0000ZZ tối đa có thể bị giới hạn bởi
ZZ0001ZZ có thể điều chỉnh được. Để tăng tỷ lệ ZZ0002ZZ phải
được tăng lên tương ứng.

Theo dõi lợi nhuận KSM
=====================

KSM có thể tiết kiệm bộ nhớ bằng cách hợp nhất các trang giống hệt nhau nhưng cũng có thể tiêu tốn
bộ nhớ bổ sung, vì nó cần tạo ra một số rmap_items để
lưu thông tin rmap ngắn gọn của mỗi trang được quét. Một số trang này có thể
được hợp nhất, nhưng một số có thể không thể hợp nhất sau khi được kiểm tra
nhiều lần, đó là bộ nhớ không có lợi được tiêu thụ.

1) Cách xác định xem KSM có tiết kiệm bộ nhớ hay tiêu thụ bộ nhớ trên toàn hệ thống hay không
   phạm vi? Đây là một phép tính gần đúng đơn giản để tham khảo::

General_profit =~ ksm_saved_pages * sizeof(page) - (all_rmap_items) *
			  sizeof(rmap_item);

trong đó ksm_saved_pages bằng tổng của ZZ0000ZZ +
   ZZ0001ZZ của hệ thống và all_rmap_items có thể dễ dàng
   thu được bằng cách tính tổng ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ
   và ZZ0005ZZ.

2) Lợi nhuận KSM trong một quy trình duy nhất có thể thu được tương tự bằng cách
   phép tính gần đúng sau::

process_profit =~ ksm_saved_pages * sizeof(page) -
			  ksm_rmap_items * sizeof(rmap_item).

trong đó ksm_saved_pages bằng tổng của ZZ0000ZZ và
   ZZ0001ZZ, cả hai đều được hiển thị trong thư mục
   ZZ0002ZZ và ksm_rmap_items cũng được hiển thị trong
   ZZ0003ZZ. Lợi nhuận của quá trình cũng được thể hiện trong
   ZZ0004ZZ là ksm_process_profit.

Từ góc độ ứng dụng, tỷ lệ ZZ0000ZZ so với
ZZ0001ZZ có nghĩa là một chính sách được áp dụng sai lầm, vì vậy các nhà phát triển hoặc
quản trị viên phải suy nghĩ lại cách thay đổi chính sách madvise. Đưa ra một ví dụ
để tham khảo, kích thước của trang thường là 4K và kích thước của rmap_item là
riêng biệt 32B trên kiến trúc CPU 32 bit và 64B trên kiến trúc CPU 64 bit.
vì vậy nếu tỷ lệ ZZ0002ZZ vượt quá 64 trên CPU 64-bit
hoặc vượt quá 128 trên CPU 32 bit thì chính sách madvise của ứng dụng sẽ bị hủy,
vì lợi nhuận ksm xấp xỉ bằng 0 hoặc âm.

Giám sát các sự kiện KSM
=====================

Có một số bộ đếm trong /proc/vmstat có thể được sử dụng để theo dõi các sự kiện KSM.
KSM có thể giúp tiết kiệm bộ nhớ, đó là sự đánh đổi bằng cách có thể bị trễ trên KSM COW
hoặc khi trao đổi trong bản sao. Những sự kiện đó có thể giúp người dùng đánh giá xem liệu
để sử dụng KSM. Ví dụ: nếu cow_ksm tăng quá nhanh, người dùng có thể giảm
phạm vi của madvise(, , MADV_MERGEABLE).

bò_ksm
	được tăng lên mỗi khi trang KSM kích hoạt sao chép khi ghi (COW)
	khi người dùng cố gắng ghi vào trang KSM, chúng tôi phải tạo một bản sao.

ksm_swpin_copy
	được tăng lên mỗi khi trang KSM được sao chép khi hoán đổi trong
	lưu ý rằng trang KSM có thể được sao chép khi hoán đổi vì do_swap_page()
	không thể thực hiện tất cả các thao tác khóa cần thiết để khôi phục trang KSM cross-anon_vma.

cố vấn
=======

Số lượng trang ứng cử cho KSM rất linh hoạt. Nó có thể được quan sát thường xuyên
rằng trong quá trình khởi động ứng dụng, cần có nhiều trang ứng viên hơn
đã xử lý. Nếu không có cố vấn, tham số ZZ0000ZZ cần phải được
có kích thước cho số lượng trang ứng viên tối đa. Cố vấn thời gian quét có thể
thay đổi tham số ZZ0001ZZ dựa trên nhu cầu.

Trình cố vấn có thể được bật để KSM có thể tự động thích ứng với những thay đổi trong
số lượng trang ứng viên cần quét. Hai cố vấn được thực hiện: không có và
thời gian quét. Không có, không có cố vấn nào được kích hoạt. Mặc định là không có.

Trình cố vấn thời gian quét thay đổi tham số ZZ0000ZZ dựa trên
thời gian quét được quan sát. Các giá trị có thể có cho tham số ZZ0001ZZ là
bị giới hạn bởi tham số ZZ0002ZZ. Ngoài ra còn có
Thông số ZZ0003ZZ. Tham số này đặt thời gian đích thành
quét tất cả các trang ứng viên KSM. Thông số ZZ0004ZZ
quyết định mức độ tích cực của cố vấn thời gian quét khi quét các trang ứng viên. Hạ xuống
các giá trị làm cho trình cố vấn thời gian quét quét tích cực hơn. Đây là nhiều nhất
tham số quan trọng cho cấu hình của trình cố vấn thời gian quét.

Giá trị ban đầu và giá trị tối đa có thể được thay đổi bằng
ZZ0000ZZ và ZZ0001ZZ. Mặc định
các giá trị là đủ cho hầu hết khối lượng công việc và trường hợp sử dụng.

Tham số ZZ0000ZZ được tính lại sau khi quét xong.


--
Izik Eidus,
Hugh Dickins, ngày 17 tháng 11 năm 2009
