.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/damon/reclaim.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Cải tạo dựa trên DAMON
==========================

Reclaimation dựa trên DAMON (DAMON_RECLAIM) là một mô-đun hạt nhân tĩnh nhằm mục đích
được sử dụng để thu hồi chủ động và nhẹ nhàng dưới áp lực bộ nhớ nhẹ.
Nó không nhằm mục đích thay thế việc cải tạo page_grainarity dựa trên danh sách LRU, nhưng
được sử dụng có chọn lọc cho các mức độ áp lực và yêu cầu bộ nhớ khác nhau.

Cần chủ động thu hồi ở đâu?
========================================

Trên các hệ thống đã cam kết quá mức bộ nhớ chung, chủ động lấy lại các trang lạnh
giúp tiết kiệm bộ nhớ và giảm độ trễ đột ngột phát sinh do hoạt động trực tiếp
lấy lại quy trình hoặc tiêu thụ kswapd CPU, trong khi chỉ phát sinh
suy giảm hiệu suất tối thiểu [1]_ [2]_ .

Báo cáo trang miễn phí [3]_ các hệ thống ảo hóa vượt quá cam kết bộ nhớ dựa trên
ví dụ tốt về các trường hợp.  Trong các hệ thống như vậy, các VM khách sẽ báo cáo
bộ nhớ cho máy chủ và máy chủ sẽ phân bổ lại bộ nhớ được báo cáo cho các khách khác.
Kết quả là bộ nhớ của hệ thống được sử dụng đầy đủ.  Tuy nhiên,
khách có thể không tốn quá nhiều bộ nhớ, chủ yếu là do một số hệ thống con kernel và
các ứng dụng không gian người dùng được thiết kế để sử dụng càng nhiều bộ nhớ càng tốt.  Sau đó,
khách chỉ có thể báo cáo một lượng nhỏ bộ nhớ còn trống cho máy chủ, dẫn đến
giảm mức sử dụng bộ nhớ của hệ thống.  Tiến hành việc khai hoang chủ động ở
khách có thể giảm thiểu vấn đề này.

Nó hoạt động như thế nào?
=========================

DAMON_RECLAIM tìm các vùng bộ nhớ không được truy cập trong thời gian cụ thể
thời lượng và trang ra.  Để tránh tiêu tốn quá nhiều CPU cho việc phân trang
hoạt động, giới hạn tốc độ có thể được cấu hình.  Dưới giới hạn tốc độ, nó trang
ra các vùng bộ nhớ không được truy cập trong thời gian dài hơn trước.  Hệ thống
quản trị viên cũng có thể định cấu hình trong tình huống nào thì chương trình này sẽ
tự động kích hoạt và hủy kích hoạt với ba hình mờ áp lực bộ nhớ.

Giao diện: Thông số mô-đun
============================

Để sử dụng tính năng này, trước tiên bạn phải đảm bảo hệ thống của mình đang chạy trên kernel
được xây dựng với ZZ0000ZZ.

Để cho phép quản trị viên hệ thống bật hoặc tắt nó và điều chỉnh cho hệ thống nhất định,
DAMON_RECLAIM sử dụng các tham số mô-đun.  Tức là bạn có thể đặt
ZZ0000ZZ trên dòng lệnh khởi động kernel hoặc ghi
giá trị thích hợp cho các tệp ZZ0001ZZ.

Dưới đây là mô tả của từng thông số.

đã bật
-------

Bật hoặc tắt DAMON_RECLAIM.

Bạn có thể kích hoạt DAMON_RCLAIM bằng cách đặt giá trị của tham số này là ZZ0000ZZ.
Đặt nó là ZZ0001ZZ sẽ tắt DAMON_RECLAIM.  Lưu ý rằng DAMON_RECLAIM có thể làm được
không có sự giám sát và thu hồi thực sự do kích hoạt dựa trên hình mờ
điều kiện.  Tham khảo các mô tả bên dưới để biết thông số hình mờ cho việc này.

cam kết_input
-------------

Làm cho DAMON_RECLAIM đọc lại các tham số đầu vào, ngoại trừ ZZ0000ZZ.

Các tham số đầu vào được cập nhật trong khi DAMON_RECLAIM đang chạy không được áp dụng
theo mặc định.  Khi tham số này được đặt thành ZZ0000ZZ, DAMON_RECLAIM sẽ đọc các giá trị
của các tham số ngoại trừ ZZ0001ZZ một lần nữa.  Sau khi đọc lại xong, điều này
tham số được đặt là ZZ0002ZZ.  Nếu tìm thấy các tham số không hợp lệ trong khi
đọc lại, DAMON_RECLAIM sẽ bị vô hiệu hóa.

tuổi tối thiểu
--------------

Ngưỡng thời gian để xác định vùng bộ nhớ lạnh tính bằng micro giây.

Nếu vùng bộ nhớ không được truy cập trong thời gian này hoặc lâu hơn, DAMON_RECLAIM
xác định khu vực này là lạnh và đòi lại nó.

120 giây theo mặc định.

hạn ngạch_ms
------------

Giới hạn thời gian thu hồi tính bằng mili giây.

DAMON_RECLAIM cố gắng chỉ sử dụng đến thời điểm này trong một khoảng thời gian
(quota_reset_interval_ms) để thử thu hồi các trang lạnh.  Đây có thể là
được sử dụng để hạn chế mức tiêu thụ CPU của DAMON_RECLAIM.  Nếu giá trị bằng 0 thì
giới hạn bị vô hiệu hóa.

10 mili giây theo mặc định.

hạn ngạch_sz
------------

Giới hạn kích thước bộ nhớ để thu hồi tính bằng byte.

DAMON_RECLAIM tính phí lượng bộ nhớ mà nó đã cố gắng lấy lại trong một thời gian
cửa sổ (quota_reset_interval_ms) và không thử vượt quá giới hạn này.
Điều này có thể được sử dụng để hạn chế mức tiêu thụ CPU và IO.  Nếu giá trị này là
không, giới hạn bị vô hiệu hóa.

128 MiB theo mặc định.

hạn ngạch_reset_interval_ms
---------------------------

Khoảng thời gian đặt lại phí hạn ngạch thời gian/kích thước tính bằng mili giây.

Khoảng thời gian đặt lại phí cho hạn ngạch thời gian (hạn ngạch_ms) và kích thước
(hạn ngạch_sz).  Nghĩa là, DAMON_RECLAIM không cố gắng thu hồi lâu hơn
Quota_ms mili giây hoặc Quota_sz byte trong Quota_reset_interval_ms
mili giây.

1 giây theo mặc định.

hạn ngạch_mem_áp lực_us
-----------------------

Mức thời gian ngừng áp suất bộ nhớ mong muốn tính bằng micro giây.

Trong khi vẫn giữ giới hạn do các hạn ngạch khác đặt ra, DAMON_RECLAIM sẽ tự động
tăng và giảm mức hữu hiệu của hạn ngạch nhằm vào mức này
áp lực bộ nhớ phát sinh.  Bộ nhớ ZZ0000ZZ toàn hệ thống PSI tính bằng micro giây
mỗi khoảng thời gian đặt lại hạn ngạch (ZZ0001ZZ) được thu thập và
so sánh với giá trị này để xem liệu mục tiêu có được thỏa mãn hay không.  Giá trị 0 có nghĩa là
vô hiệu hóa tính năng tự động điều chỉnh này.

Bị tắt theo mặc định.

hạn ngạch_autotune_feedback
---------------------------

Phản hồi do người dùng chỉ định để tự động điều chỉnh hạn ngạch hiệu quả.

Trong khi vẫn giữ giới hạn do các hạn ngạch khác đặt ra, DAMON_RECLAIM sẽ tự động
tăng và giảm mức hiệu quả của hạn ngạch nhằm nhận được hạn ngạch này
phản hồi về giá trị ZZ0000ZZ từ người dùng.  DAMON_RECLAIM giả định phản hồi
giá trị và hạn ngạch tỷ lệ thuận với nhau.  Giá trị 0 có nghĩa là vô hiệu hóa
tính năng tự động điều chỉnh này.

Bị tắt theo mặc định.

wmarks_interval
---------------

Thời gian chờ đợi tối thiểu trước khi kiểm tra hình mờ, khi DAMON_RECLAIM
được bật nhưng không hoạt động do quy tắc hình mờ của nó.

wmark_high
-----------

Tỷ lệ bộ nhớ trống (trên một nghìn) cho hình mờ cao.

Nếu bộ nhớ trống của hệ thống tính bằng byte trên nghìn byte cao hơn mức này,
DAMON_RECLAIM không hoạt động nên nó không làm gì cả mà chỉ kiểm tra định kỳ
các hình mờ.

wmarks_mid
----------

Tỷ lệ bộ nhớ trống (trên một nghìn) cho hình mờ ở giữa.

Nếu bộ nhớ trống của hệ thống tính bằng byte trên một nghìn byte nằm giữa giá trị này và
hình mờ thấp, DAMON_RECLAIM sẽ hoạt động, do đó bắt đầu giám sát và
sự đòi lại.

wmark_thấp
----------

Tỷ lệ bộ nhớ trống (trên một nghìn) cho hình mờ thấp.

Nếu bộ nhớ trống của hệ thống tính bằng byte trên nghìn byte thấp hơn mức này,
DAMON_RECLAIM trở nên không hoạt động nên nó không làm gì ngoài việc kiểm tra định kỳ
hình mờ.  Trong trường hợp, hệ thống quay trở lại trang dựa trên danh sách LRU
logic cải tạo chi tiết.

sample_interval
---------------

Khoảng thời gian lấy mẫu để theo dõi tính bằng micro giây.

Khoảng thời gian lấy mẫu của DAMON để theo dõi bộ nhớ nguội.  Vui lòng tham khảo
tài liệu DAMON (ZZ0000ZZ) để biết thêm chi tiết.

aggr_interval
-------------

Khoảng thời gian tổng hợp để theo dõi tính bằng micro giây.

Khoảng thời gian tổng hợp của DAMON để theo dõi bộ nhớ nguội.  làm ơn
tham khảo tài liệu DAMON (ZZ0000ZZ) để biết thêm chi tiết.

phút_nr_khu vực
---------------

Số lượng khu vực giám sát tối thiểu.

Số vùng giám sát tối thiểu của DAMON cho bộ nhớ nguội
giám sát.  Điều này có thể được sử dụng để đặt giới hạn dưới của chất lượng giám sát.
Tuy nhiên, việc đặt mức này quá cao có thể dẫn đến tăng chi phí giám sát.
Vui lòng tham khảo tài liệu DAMON (ZZ0000ZZ) để biết thêm chi tiết.

Lưu ý rằng điều này phải là 3 hoặc cao hơn. Vui lòng tham khảo phần ZZ0000ZZ của tài liệu thiết kế để biết lý do
đằng sau giới hạn dưới này.

max_nr_khu vực
--------------

Số lượng vùng giám sát tối đa.

Số vùng giám sát tối đa của DAMON cho bộ nhớ lạnh
giám sát.  Điều này có thể được sử dụng để đặt giới hạn trên của chi phí giám sát.
Tuy nhiên, cài đặt mức này quá thấp có thể dẫn đến chất lượng giám sát kém.  làm ơn
tham khảo tài liệu DAMON (ZZ0000ZZ) để biết thêm chi tiết.

màn hình_khu vực_start
----------------------

Bắt đầu vùng nhớ đích trong địa chỉ vật lý.

Địa chỉ vật lý bắt đầu của vùng bộ nhớ mà DAMON_RECLAIM sẽ hoạt động
chống lại.  Tức là DAMON_RECLAIM sẽ tìm các vùng bộ nhớ lạnh trong vùng này
và đòi lại.  Theo mặc định, Hệ thống RAM lớn nhất được sử dụng làm khu vực.

màn hình_khu vực_end
--------------------

Kết thúc vùng bộ nhớ đích trong địa chỉ vật lý.

Địa chỉ vật lý cuối cùng của vùng bộ nhớ mà DAMON_RECLAIM sẽ hoạt động
chống lại.  Tức là DAMON_RECLAIM sẽ tìm các vùng bộ nhớ lạnh trong vùng này
và đòi lại.  Theo mặc định, Hệ thống RAM lớn nhất được sử dụng làm khu vực.

addr_unit
---------

Hệ số tỷ lệ cho địa chỉ bộ nhớ và byte.

Tham số này dùng để cài đặt và lấy tham số ZZ0000ZZ của phiên bản DAMON cho DAMON_RECLAIM.

ZZ0000ZZ và ZZ0001ZZ nên được cung cấp trong phần này
đơn vị.  Ví dụ: giả sử ZZ0002ZZ, ZZ0003ZZ và
ZZ0004ZZ được đặt lần lượt là ZZ0005ZZ, ZZ0006ZZ và ZZ0007ZZ.
Sau đó, DAMON_RECLAIM sẽ hoạt động với phạm vi địa chỉ vật lý có độ dài 10 KiB
bắt đầu từ địa chỉ 0 (ZZ0008ZZ tính bằng byte).

ZZ0000ZZ và ZZ0001ZZ cũng có trong
đơn vị này.  Ví dụ: giả sử các giá trị của ZZ0002ZZ,
ZZ0003ZZ và ZZ0004ZZ là ZZ0005ZZ,
ZZ0006ZZ và ZZ0007ZZ tương ứng.  Vậy có nghĩa là DAMON_RECLAIM đã cố gắng đòi lại
Bộ nhớ 42 KiB và lấy lại thành công tổng cộng 32 bộ nhớ KiB.

Nếu không chắc chắn, chỉ sử dụng giá trị mặc định (ZZ0000ZZ) và quên điều này.

bỏ qua_anon
-----------

Bỏ qua việc cải tạo các trang ẩn danh.

Nếu tham số này được đặt là ZZ0000ZZ, DAMON_RECLAIM sẽ không lấy lại ẩn danh
trang.  Theo mặc định, ZZ0001ZZ.


kdamond_pid
-----------

PID của luồng DAMON.

Nếu DAMON_RECLAIM được bật, thì đây sẽ trở thành PID của luồng công nhân.  Khác,
-1.

nr_reclaim_tried_khu vực
------------------------

Số vùng bộ nhớ đã được DAMON_RECLAIM thu hồi.

byte_reclaim_tried_khu vực
---------------------------

Tổng số byte vùng bộ nhớ đã được DAMON_RECLAIM thu hồi.

nr_reclaimed_khu vực
--------------------

Số vùng bộ nhớ được DAMON_RECLAIM thu hồi thành công.

byte_reclaimed_khu vực
-----------------------

Tổng số byte vùng bộ nhớ được DAMON_RECLAIM thu hồi thành công.

nr_quota_vượt quá
-----------------

Số lần vượt quá giới hạn hạn ngạch thời gian/không gian.

Ví dụ
=======

Các lệnh ví dụ thời gian chạy bên dưới giúp DAMON_RECLAIM tìm các vùng bộ nhớ
không được truy cập trong 30 giây trở lên và bị mất trang.  Việc thu hồi bị hạn chế
chỉ được thực hiện tối đa 1 GiB mỗi giây để tránh tiêu thụ DAMON_RECLAIM
CPU tốn nhiều thời gian cho hoạt động phân trang.  Nó cũng yêu cầu DAMON_RECLAIM thực hiện
không có gì nếu tỷ lệ bộ nhớ trống của hệ thống lớn hơn 50%, nhưng hãy bắt đầu thực
hoạt động nếu nó trở nên thấp hơn 40%.  Nếu DAMON_RECLAIM không tiến bộ và
do đó tốc độ bộ nhớ trống trở nên thấp hơn 20%, nó yêu cầu DAMON_RECLAIM
không làm gì nữa để chúng ta có thể quay lại trang dựa trên danh sách LRU
thu hồi độ chi tiết. ::

# cd/sys/mô-đun/damon_reclaim/tham số
    # echo 30000000 > tuổi tối thiểu
    # echo $((1 * 1024 * 1024 * 1024)) > hạn ngạch_sz
    # echo 1000 > hạn ngạch_reset_interval_ms
    # echo 500 > wmarks_high
    # echo 400 > wmarks_mid
    # echo 200 > wmarks_low
    # echo Y > đã bật

Lưu ý rằng mô-đun này (damon_reclaim) không thể chạy đồng thời với mô-đun khác
Các mô-đun chuyên dụng dựa trên DAMON.  Tham khảo ZZ0000ZZ
để biết thêm chi tiết.

.. [1] https://research.google/pubs/pub48551/
.. [2] https://lwn.net/Articles/787611/
.. [3] https://www.kernel.org/doc/html/latest/mm/free_page_reporting.html