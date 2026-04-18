.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/cache-policies.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Hướng dẫn viết chính sách
================================

Cố gắng giữ giao dịch ra khỏi nó.  Cốt lõi là cẩn thận để
tránh hỏi về bất cứ điều gì đang di chuyển.  Đây là một nỗi đau, nhưng
làm cho việc viết các chính sách trở nên dễ dàng hơn.

Ánh xạ được tải vào chính sách tại thời điểm xây dựng.

Mọi tiểu sử được mục tiêu ánh xạ đều được tham chiếu đến chính sách.
Chính sách có thể trả về HIT hoặc MISS đơn giản hoặc thực hiện di chuyển.

Hiện tại không có cách nào để chính sách đưa ra công việc nền,
ví dụ: để bắt đầu viết lại các khối bẩn sắp bị loại bỏ
sớm thôi.

Bởi vì chúng tôi ánh xạ bios, thay vì yêu cầu nên chính sách dễ dàng
để bị đánh lừa bởi nhiều tiểu sử nhỏ.  Vì lý do này mục tiêu cốt lõi
đưa ra các đánh dấu định kỳ cho chính sách.  Có ý kiến cho rằng chính sách
không cập nhật trạng thái (ví dụ: số lần truy cập) cho một khối nhiều lần
cho mỗi tích tắc.  Phần cốt lõi hoạt động bằng cách xem bios hoàn chỉnh, v.v.
đang cố gắng xem khi nào bộ lập lịch io cho phép ios chạy.


Tổng quan về các chính sách thay thế bộ đệm được cung cấp
=========================================================

nhiều hàng đợi (mq)
-------------------

Chính sách này hiện là bí danh cho smq (xem bên dưới).

Các điều chỉnh sau đây được chấp nhận nhưng không có hiệu lực::

'ngưỡng_tuần tự <#nr_sequential_ios>'
	'ngưỡng_ngẫu nhiên <#nr_random_ios>'
	'read_promote_ adjustment <giá trị>'
	'write_promote_ adjustment <giá trị>'
	'discard_promote_ adjustment <giá trị>'

Đa hàng đợi ngẫu nhiên (smq)
----------------------------

Chính sách này là mặc định.

Chính sách nhiều hàng đợi ngẫu nhiên (smq) giải quyết một số vấn đề
với chính sách đa hàng đợi (mq).

Chính sách smq (so với mq) hứa hẹn sử dụng ít bộ nhớ hơn,
cải thiện hiệu suất và tăng khả năng thích ứng khi đối mặt với sự thay đổi
khối lượng công việc.  smq cũng không có bất kỳ nút điều chỉnh rườm rà nào.

Người dùng có thể chuyển từ "mq" sang "smq" chỉ bằng cách tải lại một cách thích hợp
Bảng DM đang sử dụng mục tiêu bộ đệm.  Làm như vậy sẽ gây ra tất cả
gợi ý của chính sách mq sẽ bị loại bỏ.  Ngoài ra, hiệu suất của bộ đệm có thể
giảm nhẹ cho đến khi smq tính toán lại các điểm nóng của thiết bị gốc
cái đó nên được lưu vào bộ nhớ đệm.

Sử dụng bộ nhớ
^^^^^^^^^^^^^^

Chính sách mq sử dụng nhiều bộ nhớ; 88 byte cho mỗi khối bộ đệm trên 64
máy bit.

smq sử dụng các chỉ mục 28bit để triển khai cấu trúc dữ liệu của nó thay vì
con trỏ.  Nó tránh lưu trữ số lần truy cập rõ ràng cho mỗi khối.  Nó
có hàng đợi 'điểm phát sóng', thay vì bộ đệm trước, sử dụng một phần tư
các mục (mỗi khối điểm phát sóng bao phủ một khu vực lớn hơn một khối
khối bộ đệm).

Tất cả điều này có nghĩa là smq sử dụng ~25byte cho mỗi khối bộ đệm.  Vẫn còn rất nhiều
bộ nhớ, nhưng dù sao cũng có sự cải thiện đáng kể.

Cân bằng cấp độ
^^^^^^^^^^^^^^^

mq đặt các mục ở các cấp độ khác nhau của cấu trúc nhiều hàng đợi
dựa trên số lần truy cập của họ (~ln(số lần truy cập)).  Điều này có nghĩa là đáy
các cấp độ thường có nhiều mục nhất và những cấp độ cao nhất có rất nhiều
ít.  Có mức độ không cân bằng như thế này làm giảm hiệu quả của
nhiều hàng đợi.

smq không duy trì số lần truy cập, thay vào đó nó hoán đổi các mục truy cập bằng
mục nhập ít được sử dụng gần đây nhất từ ​​cấp trên.  tổng thể
thứ tự là một tác dụng phụ của quá trình ngẫu nhiên này.  Với cái này
lược đồ chúng ta có thể quyết định có bao nhiêu mục chiếm mỗi cấp độ nhiều hàng đợi,
đưa đến những quyết định thăng chức/ giáng chức tốt hơn.

Khả năng thích ứng:
Chính sách mq duy trì số lần truy cập cho mỗi khối bộ đệm.  Đối với một
khối khác để được thăng cấp vào bộ đệm, số lần truy cập của nó phải
vượt quá mức thấp nhất hiện tại trong bộ đệm.  Điều này có nghĩa là nó có thể mất một
mất nhiều thời gian để bộ đệm thích ứng giữa các mẫu IO khác nhau.

smq không duy trì số lần truy cập, vì vậy rất nhiều vấn đề này sẽ biến mất
đi xa.  Ngoài ra, nó còn theo dõi hiệu suất của hàng đợi điểm phát sóng,
được sử dụng để quyết định khối nào sẽ được quảng bá.  Nếu hàng đợi điểm phát sóng là
hoạt động kém thì nó bắt đầu di chuyển các mục nhanh hơn giữa
cấp độ.  Điều này cho phép nó thích ứng với các mẫu IO mới rất nhanh.

Hiệu suất
^^^^^^^^^^^

Kiểm tra smq cho thấy hiệu suất tốt hơn đáng kể so với mq.

sạch hơn
--------

Trình dọn dẹp ghi lại tất cả các khối bẩn trong bộ đệm để ngừng hoạt động.

Ví dụ
========

Cú pháp của một bảng là::

bộ nhớ đệm <nhà phát triển siêu dữ liệu> <nhà phát triển bộ đệm> <nhà phát triển nguồn gốc> <kích thước khối>
	<#feature_args> [<tính năng đối số>]*
	<chính sách> <#policy_args> [<đối số chính sách>]*

Cú pháp để gửi tin nhắn bằng lệnh dmsetup là::

thông báo dmsetup <thiết bị được ánh xạ> 0 tuần tự_threshold 1024
	thông báo dmsetup <thiết bị được ánh xạ> 0 ngưỡng ngẫu nhiên 8

Sử dụng dmsetup::

dmsetup tạo blah --table "0 268435456 bộ đệm /dev/sdb /dev/sdc \
	    /dev/sdd 512 0 mq 4 tuần tự_threshold 1024 ngẫu nhiên_threshold 8"
	tạo một thiết bị được ánh xạ lớn 128 GB có tên 'blah' với
	ngưỡng tuần tự được đặt thành 1024 và ngưỡng ngẫu nhiên được đặt thành 8.
