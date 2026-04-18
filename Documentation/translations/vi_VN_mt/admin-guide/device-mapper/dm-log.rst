.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-log.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Ghi nhật ký trình ánh xạ thiết bị
=================================
Mã ghi nhật ký của trình ánh xạ thiết bị được một số người trong trình ánh xạ thiết bị sử dụng.
RAID nhắm mục tiêu theo dõi các vùng đĩa không nhất quán.
Một vùng (hoặc một phần không gian địa chỉ) của đĩa có thể
không nhất quán vì sọc RAID hiện đang được vận hành trên hoặc
một chiếc máy đã chết trong khi khu vực đang được thay đổi.  Trong trường hợp của
gương, một vùng sẽ bị coi là bẩn/không nhất quán khi bạn
đang viết cho nó bởi vì việc viết cần phải được sao chép cho tất cả
chân gương và có thể không chạm tới chân gương cùng một lúc.
Khi tất cả quá trình ghi hoàn tất, khu vực đó sẽ được coi là sạch trở lại.

Có một giao diện ghi nhật ký chung mà trình ánh xạ thiết bị RAID
việc triển khai sử dụng để thực hiện các hoạt động ghi nhật ký (xem
dm_dirty_log_type trong include/linux/dm-dirty-log.h).  Khác nhau khác nhau
việc triển khai ghi nhật ký có sẵn và cung cấp các
khả năng.  Danh sách bao gồm:

==================================================================================
Nhập tệp
==================================================================================
trình điều khiển đĩa/md/dm-log.c
trình điều khiển cốt lõi/md/dm-log.c
trình điều khiển không gian người dùng/md/dm-log-userspace* bao gồm/linux/dm-log-userspace.h
============================================================================================

Loại nhật ký "đĩa"
-------------------
Việc triển khai nhật ký này cam kết trạng thái nhật ký vào đĩa.  Bằng cách này,
trạng thái ghi nhật ký vẫn tồn tại sau khi khởi động lại/gặp sự cố.

Loại nhật ký "cốt lõi"
----------------------
Việc triển khai nhật ký này sẽ giữ trạng thái nhật ký trong bộ nhớ.  Trạng thái nhật ký
sẽ không tồn tại sau khi khởi động lại hoặc gặp sự cố, nhưng có thể có một sự gia tăng nhỏ về
hiệu suất.  Phương pháp này cũng có thể được sử dụng nếu không có thiết bị lưu trữ
có sẵn để lưu trữ trạng thái nhật ký.

Loại nhật ký "không gian người dùng"
------------------------------------
Loại nhật ký này chỉ cung cấp cách xuất nhật ký API sang không gian người dùng,
vì vậy việc triển khai nhật ký có thể được thực hiện ở đó.  Điều này được thực hiện bằng cách chuyển tiếp hầu hết
ghi nhật ký các yêu cầu vào không gian người dùng, nơi daemon nhận và xử lý
yêu cầu.

Cấu trúc được sử dụng để liên lạc giữa kernel và không gian người dùng là
nằm trong include/linux/dm-log-userspace.h.  Do tần số,
tính đa dạng và tính chất giao tiếp 2 chiều của sự trao đổi giữa
kernel và không gian người dùng, 'trình kết nối' được sử dụng làm giao diện cho
giao tiếp.

Hiện tại có hai triển khai nhật ký không gian người dùng tận dụng điều này
framework - "clustered-disk" và "clustered-core".  Những triển khai này
cung cấp nhật ký kết hợp cụm cho bộ nhớ dùng chung.  Phản chiếu trình ánh xạ thiết bị
có thể được sử dụng trong môi trường lưu trữ dùng chung khi triển khai nhật ký cụm
đang được tuyển dụng.
