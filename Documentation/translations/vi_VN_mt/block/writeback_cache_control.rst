.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/writeback_cache_control.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Kiểm soát bộ đệm ghi lại dễ bay hơi rõ ràng
==============================================

Giới thiệu
------------

Nhiều thiết bị lưu trữ, đặc biệt là trên thị trường tiêu dùng, có tính ổn định
ghi lại bộ nhớ đệm.  Điều đó có nghĩa là các thiết bị báo hiệu việc hoàn thành I/O tới
hệ điều hành trước khi dữ liệu thực sự được lưu trữ vào bộ lưu trữ cố định.  Cái này
hành vi rõ ràng tăng tốc khối lượng công việc khác nhau, nhưng nó có nghĩa là hoạt động
hệ thống cần buộc dữ liệu ra bộ lưu trữ cố định khi nó thực hiện
hoạt động toàn vẹn dữ liệu như fsync, đồng bộ hóa hoặc ngắt kết nối.

Lớp khối Linux cung cấp hai cơ chế đơn giản cho phép hệ thống tập tin
kiểm soát hành vi bộ nhớ đệm của thiết bị lưu trữ.  Những cơ chế này được
xóa bộ nhớ đệm bắt buộc và cờ Truy cập đơn vị bắt buộc (FUA) cho các yêu cầu.


Xóa bộ nhớ đệm rõ ràng
----------------------

Cờ REQ_PREFLUSH có thể được OR chỉnh sửa thành cờ r/w của tiểu sử được gửi từ
hệ thống tập tin và sẽ đảm bảo bộ đệm dễ bay hơi của thiết bị lưu trữ
đã được xóa trước khi hoạt động I/O thực tế được bắt đầu.  Điều này rõ ràng
đảm bảo rằng các yêu cầu ghi đã hoàn thành trước đó ở trạng thái không thay đổi
lưu trữ trước khi bắt đầu tiểu sử được gắn cờ. Ngoài ra, cờ REQ_PREFLUSH có thể
được thiết lập trên một cấu trúc sinh học trống rỗng, điều này chỉ gây ra một bộ nhớ đệm rõ ràng
tuôn ra mà không có bất kỳ I/O phụ thuộc nào.  Nên sử dụng
trình trợ giúp blkdev_issue_flush() để xóa bộ nhớ đệm thuần túy.


Truy cập đơn vị bắt buộc
------------------------

Cờ REQ_FUA có thể được OR chỉnh sửa thành cờ r/w của tiểu sử được gửi từ
hệ thống tập tin và sẽ đảm bảo rằng việc hoàn thành I/O cho yêu cầu này chỉ
được báo hiệu sau khi dữ liệu đã được chuyển sang lưu trữ cố định.


Chi tiết triển khai cho hệ thống tập tin
----------------------------------------

Hệ thống tập tin có thể chỉ cần đặt các bit REQ_PREFLUSH và REQ_FUA và không cần phải
lo lắng liệu các thiết bị cơ bản có cần xóa bộ nhớ đệm rõ ràng hay không và cách
Quyền truy cập đơn vị bắt buộc được triển khai.  Cờ REQ_PREFLUSH và REQ_FUA
cả hai đều có thể được đặt trên một tiểu sử.

Cài đặt tính năng cho trình điều khiển khối
-------------------------------------------

Đối với các thiết bị không hỗ trợ bộ đệm ghi dễ bay hơi thì không có trình điều khiển
cần hỗ trợ, lớp khối sẽ hoàn thành các yêu cầu REQ_PREFLUSH trống trước
nhập trình điều khiển và loại bỏ các bit REQ_PREFLUSH và REQ_FUA khỏi
các yêu cầu có tải trọng.

Đối với các thiết bị có bộ đệm ghi dễ thay đổi, trình điều khiển cần thông báo cho lớp khối
rằng nó hỗ trợ xóa bộ nhớ đệm bằng cách thiết lập

BLK_FEAT_WRITE_CACHE

cờ trong trường tính năng queue_limits.  Đối với các thiết bị cũng hỗ trợ FUA
bit, lớp khối cần được yêu cầu truyền bit REQ_FUA bằng cách cài đặt
cái

BLK_FEAT_FUA

cờ trong trường tính năng của cấu trúc queue_limits.

Chi tiết triển khai cho trình điều khiển khối dựa trên sinh học
---------------------------------------------------------------

Đối với trình điều khiển dựa trên sinh học, bit REQ_PREFLUSH và REQ_FUA chỉ được chuyển tới
trình điều khiển nếu trình điều khiển đặt cờ BLK_FEAT_WRITE_CACHE và trình điều khiển
cần phải xử lý chúng.

ZZ0000ZZ: Bit REQ_FUA cũng được truyền khi cờ BLK_FEAT_FUA được bật
_không_ đặt.  Bất kỳ trình điều khiển dựa trên sinh học nào thiết lập BLK_FEAT_WRITE_CACHE cũng cần phải
xử lý REQ_FUA.

Để ánh xạ lại trình điều khiển, các bit REQ_FUA cần được truyền tới cơ sở
các thiết bị và việc xóa toàn bộ cần phải được triển khai cho bios với
Bộ bit REQ_PREFLUSH.

Chi tiết triển khai cho trình điều khiển blk-mq
-----------------------------------------------

Khi cờ BLK_FEAT_WRITE_CACHE được đặt, REQ_OP_WRITE | Yêu cầu REQ_PREFLUSH
với tải trọng sẽ tự động được chuyển thành chuỗi REQ_OP_FLUSH
yêu cầu theo sau là ghi thực tế của lớp khối.

Khi cờ BLK_FEAT_FUA được đặt, bit REQ_FUA chỉ được chuyển cho
Yêu cầu REQ_OP_WRITE, nếu không thì yêu cầu REQ_OP_FLUSH được gửi bởi lớp khối
sau khi hoàn thành yêu cầu viết để gửi tiểu sử bằng REQ_FUA
tập bit.
