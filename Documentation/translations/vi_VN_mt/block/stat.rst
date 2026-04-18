.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/stat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Thống kê lớp khối trong /sys/block/<dev>/stat
====================================================

Tệp này ghi lại nội dung của tệp /sys/block/<dev>/stat.

Tệp stat cung cấp một số số liệu thống kê về trạng thái khối
thiết bị <dev>.

Q.
   Tại sao có nhiều số liệu thống kê trong một tập tin?  Không có sysfs
   thường chứa một giá trị duy nhất cho mỗi tập tin?

A.
   Bằng cách có một tệp duy nhất, hạt nhân có thể đảm bảo rằng số liệu thống kê
   thể hiện một ảnh chụp nhanh nhất quán về trạng thái của thiết bị.  Nếu
   số liệu thống kê được xuất dưới dạng nhiều tệp chứa một thống kê
   mỗi cái, sẽ không thể đảm bảo rằng một tập hợp các bài đọc
   đại diện cho một thời điểm duy nhất.

Tệp thống kê bao gồm một dòng văn bản chứa 17 số thập phân
các giá trị cách nhau bởi khoảng trắng.  Các trường được tóm tắt trong
bảng sau và được mô tả chi tiết hơn dưới đây.


================ ====================================================================
Tên đơn vị mô tả
================ ====================================================================
yêu cầu đọc I/O số lượng yêu cầu I/O đọc được xử lý
đọc hợp nhất yêu cầu số lượng I/O đã đọc được hợp nhất với I/O trong hàng đợi
đọc các lĩnh vực lĩnh vực số lượng lĩnh vực đọc
đọc tích tắc mili giây tổng thời gian chờ cho yêu cầu đọc
yêu cầu ghi I/O số lượng I/O ghi được xử lý
ghi hợp nhất yêu cầu số lượng I/O ghi được hợp nhất với I/O trong hàng đợi
viết các lĩnh vực các lĩnh vực số lượng các lĩnh vực được viết
ghi tích tắc mili giây tổng thời gian chờ cho yêu cầu ghi
in_flight yêu cầu số lượng I/O hiện đang trong chuyến bay
io_ticks tổng thời gian mili giây thiết bị khối này đã hoạt động
tổng thời gian chờ time_in_queue mili giây cho tất cả yêu cầu
loại bỏ các yêu cầu I/O số lượng yêu cầu I/O loại bỏ được xử lý
loại bỏ các yêu cầu hợp nhất số lượng I/O loại bỏ được hợp nhất với I/O trong hàng đợi
loại bỏ các lĩnh vực số lĩnh vực bị loại bỏ
loại bỏ tích tắc mili giây tổng thời gian chờ để loại bỏ yêu cầu
số lượng yêu cầu I/O tuôn ra được xử lý
tích tắc xóa mili giây tổng thời gian chờ cho các yêu cầu xóa
================ ====================================================================

đọc I/O, ghi I/O, loại bỏ I/0
===================================

Các giá trị này tăng dần khi yêu cầu I/O hoàn thành.

xả I/O
==========

Các giá trị này tăng lên khi yêu cầu I/O tuôn ra hoàn tất.

Lớp khối kết hợp các yêu cầu tuôn ra và thực hiện nhiều nhất một yêu cầu cùng một lúc.
Điều này đếm các yêu cầu tuôn ra được thực hiện bởi đĩa. Không được theo dõi cho các phân vùng.

đọc sự hợp nhất, viết sự hợp nhất, loại bỏ sự hợp nhất
======================================================

Các giá trị này tăng lên khi một yêu cầu I/O được hợp nhất với một
already-queued I/O request.

đọc các cung, viết các cung, loại bỏ_sector
============================================

Các giá trị này đếm số lượng lĩnh vực được đọc từ, ghi vào hoặc
bị loại bỏ khỏi thiết bị khối này.  Các “ngành” được đề cập là
Các cung 512 byte UNIX tiêu chuẩn, không dành riêng cho bất kỳ thiết bị hoặc hệ thống tệp nào
kích thước khối.  Bộ đếm được tăng lên khi I/O hoàn thành.

đọc dấu tích, viết dấu tích, loại bỏ dấu tích, xóa dấu tích
===========================================================

Các giá trị này đếm số mili giây mà các yêu cầu I/O có
chờ đợi trên thiết bị khối này.  Nếu có nhiều yêu cầu I/O đang chờ,
những giá trị này sẽ tăng với tốc độ lớn hơn 1000/giây; cho
ví dụ: nếu 60 yêu cầu đọc chờ trung bình 30 ms thì read_ticks
trường sẽ tăng thêm 60*30 = 1800.

trong_chuyến bay
================

Giá trị này đếm số lượng yêu cầu I/O đã được gửi tới
driver thiết bị nhưng vẫn chưa hoàn thiện.  Nó không bao gồm I/O
các yêu cầu đang trong hàng đợi nhưng chưa được gửi tới trình điều khiển thiết bị.

io_ticks
========

Giá trị này đếm số mili giây mà thiết bị có
có yêu cầu I/O được xếp hàng đợi.

thời gian_in_queue
==================

Giá trị này đếm số mili giây mà các yêu cầu I/O đã chờ
trên thiết bị khối này.  Nếu có nhiều yêu cầu I/O đang chờ, điều này
giá trị sẽ tăng theo tích của số mili giây nhân với
số lượng yêu cầu đang chờ (xem ví dụ "đọc dấu tích" ở trên).
