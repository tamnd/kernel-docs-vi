.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/damon/lru_sort.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Sắp xếp danh sách LRU dựa trên DAMON
====================================

Sắp xếp danh sách LRU dựa trên DAMON (DAMON_LRU_SORT) là một mô-đun hạt nhân tĩnh
nhằm mục đích được sử dụng để dựa trên mẫu truy cập dữ liệu nhẹ và chủ động
(de)ưu tiên các trang trong danh sách LRU của họ để làm cho danh sách LRU trở nên hiệu quả hơn
nguồn mẫu truy cập dữ liệu đáng tin cậy.

Cần phải sắp xếp danh sách LRU chủ động ở đâu?
==============================================

Vì chi phí kiểm tra quyền truy cập chi tiết của trang có thể rất đáng kể trên
các hệ thống, danh sách LRU thường không được sắp xếp chủ động mà một phần và
được sắp xếp một cách linh hoạt cho các sự kiện đặc biệt bao gồm các yêu cầu cụ thể của người dùng, hệ thống
cuộc gọi và áp lực bộ nhớ.  Kết quả là danh sách LRU đôi khi không được như vậy
được chuẩn bị hoàn hảo để được sử dụng làm nguồn mẫu truy cập đáng tin cậy cho một số
các tình huống bao gồm việc lựa chọn các trang mục tiêu cải tạo trong bộ nhớ đột ngột
áp lực.

Bởi vì DAMON có thể xác định các mẫu truy cập có độ chính xác cao nhất trong khi
chỉ tạo ra phạm vi chi phí do người dùng chỉ định, chủ động chạy
DAMON_LRU_SORT có thể hữu ích để làm cho danh sách LRU có quyền truy cập đáng tin cậy hơn
nguồn mẫu với chi phí thấp và được kiểm soát.

Nó hoạt động như thế nào?
=========================

DAMON_LRU_SORT tìm các trang nóng (các trang trong vùng bộ nhớ hiển thị quyền truy cập
đánh giá cao hơn ngưỡng do người dùng chỉ định) và các trang lạnh (trang của
vùng bộ nhớ hiển thị không có quyền truy cập trong thời gian dài hơn một
ngưỡng do người dùng chỉ định) bằng DAMON và ưu tiên các trang nóng trong khi
loại bỏ các trang lạnh trong danh sách LRU của họ.  Để tránh tiêu tốn quá nhiều
CPU để ưu tiên, có thể định cấu hình giới hạn thời gian sử dụng CPU.  Dưới
giới hạn, trước tiên, nó ưu tiên và loại bỏ nhiều trang nóng và lạnh hơn,
tương ứng.  Quản trị viên hệ thống cũng có thể định cấu hình trong tình huống nào
sơ đồ này sẽ tự động được kích hoạt và hủy kích hoạt với ba bộ nhớ
hình mờ áp lực.

Các tham số mặc định của nó cho ngưỡng nóng/lạnh và giới hạn hạn ngạch CPU là
được lựa chọn một cách thận trọng.  Nghĩa là, mô-đun theo các tham số mặc định của nó có thể
được sử dụng rộng rãi mà không gây hại cho các tình huống thông thường đồng thời cung cấp mức độ
lợi ích cho các hệ thống có kiểu truy cập nóng/lạnh rõ ràng trong bộ nhớ
áp lực trong khi chỉ tiêu tốn một phần nhỏ thời gian của CPU.

Giao diện: Thông số mô-đun
============================

Để sử dụng tính năng này, trước tiên bạn phải đảm bảo hệ thống của mình đang chạy trên kernel
được xây dựng với ZZ0000ZZ.

Để cho phép quản trị viên hệ thống bật hoặc tắt nó và điều chỉnh cho hệ thống nhất định,
DAMON_LRU_SORT sử dụng các tham số mô-đun.  Tức là bạn có thể đặt
ZZ0000ZZ trên dòng lệnh khởi động kernel hoặc ghi
giá trị thích hợp cho các tệp ZZ0001ZZ.

Dưới đây là mô tả của từng thông số.

đã bật
-------

Bật hoặc tắt DAMON_LRU_SORT.

Bạn có thể kích hoạt DAMON_LRU_SORT bằng cách đặt giá trị của tham số này là ZZ0000ZZ.
Đặt nó là ZZ0001ZZ sẽ tắt DAMON_LRU_SORT.  Lưu ý rằng DAMON_LRU_SORT có thể làm được
không có giám sát thực sự và sắp xếp danh sách LRU do kích hoạt dựa trên hình mờ
điều kiện.  Tham khảo các mô tả bên dưới để biết thông số hình mờ cho việc này.

cam kết_input
-------------

Làm cho DAMON_LRU_SORT đọc lại các tham số đầu vào, ngoại trừ ZZ0000ZZ.

Các tham số đầu vào được cập nhật trong khi DAMON_LRU_SORT đang chạy không được áp dụng
theo mặc định.  Khi tham số này được đặt thành ZZ0000ZZ, DAMON_LRU_SORT sẽ đọc các giá trị
của các tham số ngoại trừ ZZ0001ZZ một lần nữa.  Sau khi đọc lại xong, điều này
tham số được đặt là ZZ0002ZZ.  Nếu tìm thấy các tham số không hợp lệ trong khi
đọc lại, DAMON_LRU_SORT sẽ bị vô hiệu hóa.

hoạt động_mem_bp
----------------

Tỷ lệ bộ nhớ hoạt động mong muốn trên [trong]bộ nhớ hoạt động tính bằng bp (1/10.000).

Trong khi vẫn giữ giới hạn do các hạn ngạch khác đặt ra, DAMON_LRU_SORT sẽ tự động
tăng và giảm mức hạn ngạch hiệu quả nhằm vào LRU
[de]ưu tiên bộ nhớ nóng và lạnh dẫn đến hoạt động này
[in]tỷ lệ bộ nhớ hoạt động.  Giá trị 0 nghĩa là vô hiệu hóa tính năng tự động điều chỉnh này.

Bị tắt theo mặc định.

autotune_monitoring_intervals
-----------------------------

Nếu tham số này được đặt là ZZ0000ZZ, DAMON_LRU_SORT sẽ tự động điều chỉnh DAMON
khoảng thời gian lấy mẫu và tổng hợp.  Việc tự động điều chỉnh nhằm mục đích nắm bắt ý nghĩa
số lượng sự kiện truy cập trong mỗi ảnh chụp nhanh DAMON, trong khi vẫn giữ nguyên mẫu
khoảng thời gian tối thiểu là 5 mili giây và tối đa là 10 giây.  Đặt cái này thành
ZZ0001ZZ tắt tính năng tự động điều chỉnh.

Bị tắt theo mặc định.

filter_young_pages
------------------

Lọc các trang [không] còn non trẻ để có mức độ ưu tiên LRU [de].

Nếu điều này được đặt, hãy kiểm tra lại quyền truy cập cấp độ trang (độ trẻ) một lần nữa trước mỗi
LRU [de]hoạt động ưu tiên.  Hoạt động ưu tiên LRU bị bỏ qua
nếu trang chưa được truy cập kể từ lần kiểm tra cuối cùng (không còn trẻ).  LRU
thao tác loại bỏ mức độ ưu tiên bị bỏ qua nếu trang đã được truy cập kể từ
kiểm tra lần cuối (trẻ).  Tính năng này được bật hoặc tắt nếu tham số này được
được đặt tương ứng là ZZ0000ZZ hoặc ZZ0001ZZ.

Bị tắt theo mặc định.

hot_thres_access_freq
---------------------

Ngưỡng tần số truy cập để nhận dạng vùng bộ nhớ nóng trong permil.

Nếu vùng bộ nhớ được truy cập ở tần số này hoặc cao hơn, DAMON_LRU_SORT
xác định vùng là nóng và đánh dấu vùng đó là được truy cập trong danh sách LRU, để
nó không thể được lấy lại dưới áp lực bộ nhớ.  50% theo mặc định.

lạnh_min_age
------------

Ngưỡng thời gian để xác định vùng bộ nhớ lạnh tính bằng micro giây.

Nếu vùng bộ nhớ không được truy cập trong thời gian này hoặc lâu hơn, DAMON_LRU_SORT
xác định khu vực là lạnh và đánh dấu khu vực đó là không thể truy cập được trong danh sách LRU, vì vậy
rằng nó có thể được lấy lại trước tiên dưới áp lực của bộ nhớ.  120 giây trước
mặc định.

hạn ngạch_ms
------------

Giới hạn thời gian để thử sắp xếp danh sách LRU tính bằng mili giây.

DAMON_LRU_SORT cố gắng chỉ sử dụng đến thời điểm này trong một khoảng thời gian
(quota_reset_interval_ms) để thử sắp xếp danh sách LRU.  Điều này có thể được sử dụng
để hạn chế mức tiêu thụ CPU của DAMON_LRU_SORT.  Nếu giá trị bằng 0 thì
giới hạn bị vô hiệu hóa.

10 mili giây theo mặc định.

hạn ngạch_reset_interval_ms
---------------------------

Khoảng thời gian đặt lại phí hạn ngạch tính bằng mili giây.

Khoảng thời gian đặt lại phí cho hạn mức thời gian (quota_ms).  Đó là,
DAMON_LRU_SORT không thử sắp xếp danh sách LRU nhiều hơn hạn ngạch_ms
mili giây hoặc Quota_sz byte trong hạn ngạch_reset_interval_ms mili giây.

1 giây theo mặc định.

wmarks_interval
---------------

Khoảng thời gian kiểm tra hình mờ tính bằng micro giây.

Thời gian chờ đợi tối thiểu trước khi kiểm tra hình mờ, khi DAMON_LRU_SORT
được bật nhưng không hoạt động do quy tắc hình mờ của nó.  5 giây theo mặc định.

wmark_high
-----------

Tỷ lệ bộ nhớ trống (trên một nghìn) cho hình mờ cao.

Nếu bộ nhớ trống của hệ thống tính bằng byte trên nghìn byte cao hơn mức này,
DAMON_LRU_SORT trở nên không hoạt động nên nó không làm gì ngoài việc kiểm tra định kỳ
hình mờ.  200 (20%) theo mặc định.

wmarks_mid
----------

Tỷ lệ bộ nhớ trống (trên một nghìn) cho hình mờ ở giữa.

Nếu bộ nhớ trống của hệ thống tính bằng byte trên một nghìn byte nằm giữa giá trị này và
hình mờ thấp, DAMON_LRU_SORT sẽ hoạt động, do đó bắt đầu giám sát và
sắp xếp danh sách LRU.  150 (15%) theo mặc định.

wmark_thấp
----------

Tỷ lệ bộ nhớ trống (trên một nghìn) cho hình mờ thấp.

Nếu bộ nhớ trống của hệ thống tính bằng byte trên nghìn byte thấp hơn mức này,
DAMON_LRU_SORT trở nên không hoạt động nên nó không làm gì ngoài việc kiểm tra định kỳ
hình mờ.  50 (5%) theo mặc định.

sample_interval
---------------

Khoảng thời gian lấy mẫu để theo dõi tính bằng micro giây.

Khoảng thời gian lấy mẫu của DAMON để theo dõi bộ nhớ nguội.  Vui lòng tham khảo
tài liệu DAMON (ZZ0000ZZ) để biết thêm chi tiết.  5ms theo mặc định.

aggr_interval
-------------

Khoảng thời gian tổng hợp để theo dõi tính bằng micro giây.

Khoảng thời gian tổng hợp của DAMON để theo dõi bộ nhớ nguội.  làm ơn
tham khảo tài liệu DAMON (ZZ0000ZZ) để biết thêm chi tiết.  100 mili giây bởi
mặc định.

phút_nr_khu vực
---------------

Số lượng khu vực giám sát tối thiểu.

Số vùng giám sát tối thiểu của DAMON cho bộ nhớ nguội
giám sát.  Điều này có thể được sử dụng để đặt giới hạn dưới của chất lượng giám sát.
Tuy nhiên, việc đặt mức này quá cao có thể dẫn đến tăng chi phí giám sát.
Vui lòng tham khảo tài liệu DAMON (ZZ0000ZZ) để biết thêm chi tiết.  10 bởi
mặc định.

Lưu ý rằng điều này phải là 3 hoặc cao hơn. Vui lòng tham khảo phần ZZ0000ZZ của tài liệu thiết kế để biết lý do
đằng sau giới hạn dưới này.

max_nr_khu vực
--------------

Số lượng vùng giám sát tối đa.

Số vùng giám sát tối đa của DAMON cho bộ nhớ nguội
giám sát.  Điều này có thể được sử dụng để đặt giới hạn trên của chi phí giám sát.
Tuy nhiên, cài đặt mức này quá thấp có thể dẫn đến chất lượng giám sát kém.  làm ơn
tham khảo tài liệu DAMON (ZZ0000ZZ) để biết thêm chi tiết.  1000 bởi
mặc định.

màn hình_khu vực_start
----------------------

Bắt đầu vùng nhớ đích trong địa chỉ vật lý.

Địa chỉ vật lý bắt đầu của vùng bộ nhớ mà DAMON_LRU_SORT sẽ hoạt động
chống lại.  Theo mặc định, Hệ thống RAM lớn nhất được sử dụng làm khu vực.

màn hình_khu vực_end
--------------------

Kết thúc vùng bộ nhớ đích trong địa chỉ vật lý.

Địa chỉ vật lý cuối cùng của vùng bộ nhớ mà DAMON_LRU_SORT sẽ hoạt động
chống lại.  Theo mặc định, Hệ thống RAM lớn nhất được sử dụng làm khu vực.

addr_unit
---------

Hệ số tỷ lệ cho địa chỉ bộ nhớ và byte.

Tham số này dùng để cài đặt và lấy tham số ZZ0000ZZ của phiên bản DAMON cho DAMON_RECLAIM.

ZZ0000ZZ và ZZ0001ZZ nên được cung cấp trong phần này
đơn vị.  Ví dụ: giả sử ZZ0002ZZ, ZZ0003ZZ và
ZZ0004ZZ được đặt lần lượt là ZZ0005ZZ, ZZ0006ZZ và ZZ0007ZZ.
Sau đó, DAMON_LRU_SORT sẽ hoạt động với phạm vi địa chỉ vật lý có độ dài 10 KiB
bắt đầu từ địa chỉ 0 (ZZ0008ZZ tính bằng byte).

Các tham số thống kê có tiền tố ZZ0000ZZ cũng có trong đơn vị này.  Ví dụ,
giả sử các giá trị của ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ là ZZ0004ZZ, ZZ0005ZZ và ZZ0006ZZ,
tương ứng.  Vậy thì có nghĩa là DAMON_LRU_SORT đã thử LRU-loại 42 KiB nóng
bộ nhớ và tổng cộng 32 KiB bộ nhớ được sắp xếp thành công theo LRU.

Nếu không chắc chắn, chỉ sử dụng giá trị mặc định (ZZ0000ZZ) và quên điều này.

kdamond_pid
-----------

PID của luồng DAMON.

Nếu DAMON_LRU_SORT được bật, thì đây sẽ trở thành PID của luồng công nhân.  Khác,
-1.

nr_lru_sort_tried_hot_khu vực
-----------------------------

Số vùng bộ nhớ nóng đã được sắp xếp theo LRU.

byte_lru_sort_tried_hot_khu vực
--------------------------------

Tổng số byte của vùng bộ nhớ nóng đã được sắp xếp theo LRU.

nr_lru_sorted_hot_khu vực
-------------------------

Số vùng bộ nhớ nóng được sắp xếp thành công LRU.

byte_lru_sorted_hot_khu vực
----------------------------

Tổng số byte của vùng bộ nhớ nóng được sắp xếp thành công theo LRU.

nr_hot_quota_vượt quá
---------------------

Số lần vượt quá giới hạn hạn ngạch thời gian cho các vùng nóng.

nr_lru_sort_tried_cold_khu vực
------------------------------

Số vùng bộ nhớ nguội đã cố gắng sắp xếp theo LRU.

byte_lru_sort_tried_cold_khu vực
---------------------------------

Tổng số byte vùng bộ nhớ nguội đã cố gắng sắp xếp theo LRU.

nr_lru_sorted_cold_khu vực
--------------------------

Số vùng bộ nhớ nguội được sắp xếp LRU thành công.

byte_lru_sorted_cold_khu vực
-----------------------------

Tổng số byte của vùng bộ nhớ nguội được sắp xếp thành công theo LRU.

nr_cold_quota_vượt quá
----------------------

Số lần vượt quá giới hạn hạn ngạch thời gian đối với vùng lạnh.

Ví dụ
=======

Các lệnh ví dụ thời gian chạy bên dưới giúp DAMON_LRU_SORT tìm các vùng bộ nhớ
có tần suất truy cập >=50% và ưu tiên LRU trong khi giảm mức độ ưu tiên LRU
vùng bộ nhớ không được truy cập trong 120 giây.  Sự ưu tiên và
việc khử ưu tiên được giới hạn thực hiện chỉ với thời gian tối đa 1% CPU để tránh
DAMON_LRU_SORT tiêu tốn quá nhiều thời gian cho việc (hủy) ưu tiên của CPU.  Nó cũng
yêu cầu DAMON_LRU_SORT không làm gì nếu tốc độ bộ nhớ trống của hệ thống cao hơn
50%, nhưng hãy bắt đầu công việc thực sự nếu nó thấp hơn 40%.  Nếu DAMON_RECLAIM
không đạt được tiến bộ và do đó tốc độ bộ nhớ trống trở nên thấp hơn
20%, nó yêu cầu DAMON_LRU_SORT không làm gì nữa để chúng ta có thể quay lại
cải tạo độ chi tiết của trang dựa trên danh sách LRU. ::

# cd/sys/module/damon_lru_sort/tham số
    # echo 500 > hot_thres_access_freq
    # echo 120000000 > lạnh_min_age
    # echo 10 > hạn ngạch_ms
    # echo 1000 > hạn ngạch_reset_interval_ms
    # echo 500 > wmarks_high
    # echo 400 > wmarks_mid
    # echo 200 > wmarks_low
    # echo Y > đã bật

Lưu ý rằng mô-đun này (damon_lru_sort) không thể chạy đồng thời với mô-đun khác
Các mô-đun chuyên dụng dựa trên DAMON.  Tham khảo ZZ0000ZZ
để biết thêm chi tiết.