.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/page_migration.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Di chuyển trang
==============

Di chuyển trang cho phép di chuyển vị trí vật lý của các trang giữa
các nút trong hệ thống NUMA trong khi quá trình đang chạy. Điều này có nghĩa là
địa chỉ ảo mà tiến trình nhìn thấy không thay đổi. Tuy nhiên,
hệ thống sắp xếp lại vị trí vật lý của các trang đó.

Đồng thời xem Documentation/mm/hmm.rst để di chuyển các trang đến hoặc từ thiết bị
ký ức riêng tư.

Mục đích chính của việc di chuyển trang là giảm độ trễ khi truy cập bộ nhớ
bằng cách di chuyển các trang gần bộ xử lý nơi quá trình truy cập bộ nhớ đó
đang chạy.

Di chuyển trang cho phép một tiến trình di chuyển thủ công nút mà nó đang ở trên đó.
các trang được định vị thông qua các tùy chọn MF_MOVE và MF_MOVE_ALL trong khi cài đặt
chính sách bộ nhớ mới thông qua mbind(). Các trang của một tiến trình cũng có thể được di chuyển
từ một quy trình khác bằng cách sử dụng lệnh gọi hàm sys_migrate_pages(). các
Lệnh gọi hàm Migrate_pages() lấy hai tập hợp nút và di chuyển các trang của một
quá trình được đặt trên các nút từ đến nút đích.
Các chức năng di chuyển trang được cung cấp bởi gói numactl của Andi Kleen
(cần có phiên bản mới hơn 0.9.3. Tải phiên bản này từ
ZZ0001ZZ numactl cung cấp libnuma
cung cấp giao diện tương tự như chức năng NUMA khác cho trang
di cư.  cat ZZ0000ZZ cho phép dễ dàng xem lại vị trí của
các trang của một tiến trình được định vị. Xem thêm tài liệu về numa_maps trong
trang man proc(5).

Di chuyển thủ công rất hữu ích nếu bộ lập lịch đã di dời
một tiến trình đến bộ xử lý trên một nút ở xa. Một bộ lập lịch hàng loạt hoặc một
quản trị viên có thể phát hiện tình huống và di chuyển các trang của quy trình
gần hơn với bộ xử lý mới. Bản thân kernel chỉ cung cấp
hỗ trợ di chuyển trang thủ công. Di chuyển trang tự động có thể được thực hiện
thông qua các quy trình không gian người dùng di chuyển các trang. Lời gọi hàm đặc biệt
"move_pages" cho phép di chuyển các trang riêng lẻ trong một quy trình.
Ví dụ: trình lược tả NUMA có thể lấy nhật ký hiển thị nút tắt thường xuyên
truy cập và có thể sử dụng kết quả để di chuyển các trang đến nơi thuận lợi hơn
địa điểm.

Các cài đặt lớn hơn thường phân vùng hệ thống bằng CPUset thành
các phần của nút. Paul Jackson đã trang bị cho CPUset khả năng
di chuyển các trang khi một tác vụ được chuyển sang một bộ xử lý khác (Xem
ZZ0000ZZ).
Cpusets cho phép tự động hóa quy trình cục bộ. Nếu một nhiệm vụ được chuyển đến
một bộ xử lý mới thì tất cả các trang của nó cũng được di chuyển cùng với nó để
hiệu suất của quá trình không giảm đáng kể. Ngoài ra các trang
của các tiến trình trong một CPUset được di chuyển nếu các nút bộ nhớ được phép của một
cpuset được thay đổi.

Di chuyển trang cho phép bảo toàn vị trí tương đối của các trang
trong một nhóm nút cho tất cả các kỹ thuật di chuyển sẽ duy trì một
mẫu cấp phát bộ nhớ cụ thể được tạo ngay cả sau khi di chuyển một
quá trình. Điều này là cần thiết để duy trì độ trễ của bộ nhớ.
Các quy trình sẽ chạy với hiệu suất tương tự sau khi di chuyển.

Di chuyển trang xảy ra trong một số bước. Đầu tiên là cấp độ cao
mô tả cho những người đang cố gắng sử dụng Migrate_pages() từ kernel
(để biết cách sử dụng không gian người dùng, hãy xem gói numactl của Andi Kleen được đề cập ở trên)
và sau đó là mô tả cấp thấp về cách hoạt động của các chi tiết cấp thấp.

Trong kernel sử dụng Migrate_pages()
================================

1. Xóa folio khỏi LRU.

Danh sách các folio cần di chuyển được tạo bằng cách quét qua
   folios và chuyển chúng vào danh sách. Việc này được thực hiện bởi
   gọi folio_isolate_lru().
   Gọi folio_isolate_lru() làm tăng các tham chiếu đến folio
   để nó không thể biến mất trong khi di chuyển folio xảy ra.
   Nó cũng ngăn chặn việc trao đổi hoặc quét khác gặp phải
   tờ giấy.

2. Chúng ta cần có một hàm kiểu new_folio_t có thể
   được chuyển tới Migrate_pages(). Chức năng này sẽ tìm ra
   cách phân bổ đúng folio mới cho folio cũ.

3. Hàm Migrate_pages() được gọi để thử
   để thực hiện việc di chuyển. Nó sẽ gọi hàm để phân bổ
   folio mới cho mỗi folio được xem xét để di chuyển.

Cách hoạt động của Migify_pages()
=========================

Migrate_pages() thực hiện một số lần duyệt qua danh sách các folio của nó. Một folio đã được di chuyển
nếu tất cả các tham chiếu đến một folio có thể được gỡ bỏ vào thời điểm đó. Folio có
đã bị xóa khỏi LRU thông qua folio_isolate_lru() và việc đếm lại
được tăng lên để folio không thể được giải phóng trong khi di chuyển folio xảy ra.

Các bước:

1. Khóa trang cần di chuyển.

2. Đảm bảo rằng việc viết lại đã hoàn tất.

3. Khóa trang mới mà chúng ta muốn chuyển đến. Nó bị khóa để truy cập vào
   trang này (chưa cập nhật) sẽ chặn ngay lập tức khi quá trình di chuyển đang diễn ra.

4. Tất cả các tham chiếu bảng trang tới trang đều được chuyển đổi thành di chuyển
   mục nhập. Điều này làm giảm số lượng bản đồ của một trang. Nếu kết quả
   số bản đồ không bằng 0 thì chúng tôi không di chuyển trang. Tất cả không gian người dùng
   các quy trình cố gắng truy cập trang bây giờ sẽ chờ khóa trang
   hoặc đợi mục nhập bảng trang di chuyển bị xóa.

5. Khóa i_pages đã được thực hiện. Điều này sẽ khiến tất cả các quá trình cố gắng
   để truy cập trang thông qua ánh xạ để chặn trên spinlock.

6. Việc đếm lại trang được kiểm tra và chúng tôi rút lui nếu vẫn còn tài liệu tham khảo.
   Nếu không, chúng tôi biết rằng chúng tôi là người duy nhất tham khảo trang này.

7. Cây cơ số được kiểm tra và nếu nó không chứa con trỏ tới
   trang sau đó chúng tôi quay lại vì người khác đã sửa đổi cây cơ số.

8. Trang mới được chuẩn bị sẵn một số cài đặt từ trang cũ để
   truy cập vào trang mới sẽ khám phá một trang có cài đặt chính xác.

9. Cây cơ số được thay đổi để trỏ tới trang mới.

10. Số lượng tham chiếu của trang cũ bị bỏ do không gian địa chỉ
    tài liệu tham khảo đã biến mất. Một tham chiếu đến trang mới được thiết lập vì
    trang mới được tham chiếu bởi không gian địa chỉ.

11. Khóa i_pages bị hủy. Với việc tra cứu đó trong bản đồ
    lại trở nên khả thi Các quy trình sẽ chuyển từ quay trên khóa
    ngủ trên trang mới bị khóa.

12. Nội dung trang được sao chép sang trang mới.

13. Các cờ trang còn lại được sao chép sang trang mới.

14. Cờ của trang cũ bị xóa để cho biết rằng trang đó không
    không cung cấp thêm thông tin gì nữa.

15. Việc ghi lại hàng đợi trên trang mới được kích hoạt.

16. Nếu các mục nhập di chuyển đã được chèn vào bảng trang thì hãy thay thế chúng
    với pt thực sự. Làm như vậy sẽ cho phép truy cập vào các quy trình không gian người dùng không
    đang chờ khóa trang.

17. Khóa trang bị loại bỏ khỏi trang cũ và trang mới.
    Các tiến trình đang chờ khóa trang sẽ làm lại lỗi trang của chúng
    và sẽ đến trang mới.

18. Trang mới được chuyển đến LRU và có thể được quét bởi bộ chuyển đổi,
    v.v. một lần nữa.

di chuyển trang movable_ops
==========================

Các trang không phải folio được đánh máy đã chọn (ví dụ: các trang được thổi phồng trong bong bóng bộ nhớ,
trang zsmalloc) có thể được di chuyển bằng khung di chuyển movable_ops.

"struct movable_Operations" cung cấp các lệnh gọi lại cụ thể cho một loại trang
để cách ly, di chuyển và hủy cách ly (đặt lại) các trang này.

Khi một trang được biểu thị là có movable_ops, điều kiện đó không được
thay đổi cho đến khi trang được giải phóng trở lại bạn nhé. Điều này bao gồm không
thay đổi/xóa loại trang và không thay đổi/xóa trang
Cờ trang PG_movable_ops.

Trình điều khiển tùy ý hiện không thể sử dụng khung này vì nó
yêu cầu:

(a) một loại trang
(b) cho biết họ có thể có movable_ops trong page_has_movable_ops()
    dựa trên loại trang
(c) trả về movable_ops từ page_movable_ops() dựa trên trang
    loại
(d) không sử dụng lại cờ trang PG_movable_ops và PG_movable_ops_isosol
    cho các mục đích khác

Ví dụ: người điều khiển khinh khí cầu có thể sử dụng khung này thông qua
cơ sở hạ tầng nén bong bóng nằm trong lõi lõi.

Giám sát di chuyển
=====================

Các sự kiện (bộ đếm) sau đây có thể được sử dụng để theo dõi quá trình di chuyển trang.

1. PGMIGRATE_SUCCESS: Di chuyển trang thành công bình thường. Mỗi lần đếm có nghĩa là một
   trang đã được di chuyển. Nếu trang đó không phải là trang THP và không phải Hugetlb thì
   bộ đếm này được tăng lên một. Nếu trang đó là THP hoặc Hugetlb thì
   bộ đếm này được tăng lên theo số lượng trang con THP hoặc Hugetlb.
   Ví dụ: di chuyển một THP 2 MB có các trang cơ sở kích thước 4KB
   (trang con) sẽ khiến bộ đếm này tăng thêm 512.

2. PGMIGRATE_FAIL: Lỗi di chuyển trang thông thường. Quy tắc tính tương tự như đối với
   PGMIGRATE_SUCCESS, ở trên: số lượng trang con này sẽ tăng lên,
   nếu đó là THP hoặc Hugetlb.

3. THP_MIGRATION_SUCCESS: THP đã được di chuyển mà không bị chia tách.

4. THP_MIGRATION_FAIL: Không thể di chuyển THP cũng như không thể chia tách.

5. THP_MIGRATION_SPLIT: THP đã được di chuyển, nhưng không phải như vậy: đầu tiên, THP đã có
   bị chia cắt. Sau khi tách, thử lại di chuyển đã được sử dụng cho các trang phụ của nó.

Các sự kiện THP_MIGRATION_* cũng cập nhật PGMIGRATE_SUCCESS hoặc
Sự kiện PGMIGRATE_FAIL. Ví dụ: lỗi di chuyển THP sẽ gây ra cả hai
THP_MIGRATION_FAIL và PGMIGRATE_FAIL tăng lên.

Christoph Lameter, ngày 8 tháng 5 năm 2006.
Minchan Kim, ngày 28 tháng 3 năm 2016.

.. kernel-doc:: include/linux/migrate.h
