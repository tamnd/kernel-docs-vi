.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/damon/stat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Thống kê kết quả giám sát truy cập dữ liệu
===================================

Thống kê kết quả giám sát truy cập dữ liệu (DAMON_STAT) là một mô-đun hạt nhân tĩnh
nhằm mục đích được sử dụng để giám sát mẫu truy cập đơn giản.  Nó giám sát các truy cập
trên toàn bộ bộ nhớ vật lý của hệ thống bằng DAMON và cung cấp đơn giản hóa
truy cập số liệu thống kê kết quả giám sát, cụ thể là phần trăm thời gian nhàn rỗi và
băng thông bộ nhớ ước tính

.. _damon_stat_monitoring_accuracy_overhead:

Giám sát độ chính xác và chi phí chung
================================

DAMON_STAT sử dụng khoảng thời gian giám sát ZZ0000ZZ để nâng cao độ chính xác và
chi phí tối thiểu.  Nó tự động điều chỉnh các khoảng thời gian nhằm đạt 4% quyền truy cập có thể quan sát được
các sự kiện được ghi lại trong mỗi ảnh chụp nhanh, đồng thời hạn chế việc lấy mẫu kết quả
khoảng thời gian tối thiểu là 5 mili giây và tối đa là 10 giây.  Trên một số
hệ thống máy chủ sản xuất, kết quả là chỉ tiêu tốn 0,x % thời gian CPU đơn lẻ,
trong khi nắm bắt được chất lượng hợp lý của các mẫu truy cập.  Kết quả điều chỉnh
khoảng thời gian có thể được truy xuất thông qua ZZ0002ZZ ZZ0001ZZ.

Giao diện: Thông số mô-đun
============================

Để sử dụng tính năng này, trước tiên bạn phải đảm bảo hệ thống của mình đang chạy trên kernel
được xây dựng với ZZ0000ZZ.  Tính năng này có thể được kích hoạt bởi
mặc định tại thời điểm xây dựng, bằng cách đặt ZZ0001ZZ đúng.

Để cho phép quản trị hệ thống bật hoặc tắt nó khi khởi động và/hoặc thời gian chạy, đồng thời đọc
kết quả giám sát, DAMON_STAT cung cấp các thông số mô-đun.  Đang theo dõi
phần là mô tả của các tham số.

đã bật
-------

Bật hoặc tắt DAMON_STAT.

Bạn có thể kích hoạt DAMON_STAT bằng cách đặt giá trị của tham số này là ZZ0000ZZ.
Đặt nó là ZZ0001ZZ sẽ tắt DAMON_STAT.  Giá trị mặc định được đặt bởi
Tùy chọn cấu hình xây dựng ZZ0002ZZ.

Lưu ý rằng mô-đun này (damon_stat) không thể chạy đồng thời với mô-đun khác
Các mô-đun chuyên dụng dựa trên DAMON.  Tham khảo ZZ0000ZZ
để biết thêm chi tiết.

.. _damon_stat_aggr_interval_us:

aggr_interval_us
----------------

Khoảng thời gian tổng hợp được điều chỉnh tự động tính bằng micro giây.

Người dùng có thể đọc khoảng thời gian tổng hợp của DAMON đang được sử dụng bởi
Phiên bản DAMON dành cho DAMON_STAT.  Đó là ZZ0000ZZ và do đó giá trị là
được thay đổi một cách năng động.

ước tính_memory_bandwidth
--------------------------

Ước tính mức tiêu thụ băng thông bộ nhớ (byte trên giây) của hệ thống.

DAMON_STAT đọc các sự kiện truy cập được quan sát trên ảnh chụp nhanh kết quả DAMON hiện tại
và chuyển đổi nó thành ước tính mức tiêu thụ băng thông bộ nhớ tính bằng byte trên giây.
Chỉ số kết quả được hiển thị cho người dùng thông qua thông số chỉ đọc này.  Bởi vì
DAMON sử dụng lấy mẫu, đây chỉ là ước tính về cường độ truy cập chứ không phải
hơn băng thông bộ nhớ chính xác.

bộ nhớ_idle_ms_percentiles
--------------------------

Phần trăm thời gian rảnh trên mỗi byte (mili giây) của hệ thống.

DAMON_STAT tính toán thời gian mỗi byte bộ nhớ không được truy cập cho đến khi
bây giờ (thời gian nhàn rỗi), dựa trên ảnh chụp nhanh kết quả DAMON hiện tại.  Đối với khu vực
có tần số truy cập (nr_accesses) lớn hơn 0, dòng điện kéo dài bao lâu
mức tần số truy cập được giữ nhân với ZZ0000ZZ trở thành thời gian rảnh của
mỗi byte của khu vực.  Nếu một vùng có tần số truy cập bằng 0 (nr_accesses),
khu vực đã giữ tần số truy cập bằng 0 (tuổi) trong bao lâu sẽ trở thành
thời gian nhàn rỗi của từng byte trong vùng.  Sau đó, DAMON_STAT hiển thị
phần trăm của giá trị thời gian nhàn rỗi thông qua tham số chỉ đọc này.  Đọc
tham số trả về 101 giá trị thời gian nhàn rỗi tính bằng mili giây, được phân tách bằng dấu phẩy.
Mỗi giá trị đại diện cho phân vị thứ 0, thứ 1, thứ 2, thứ 3, ..., thứ 99 và thứ 100 không hoạt động
lần.