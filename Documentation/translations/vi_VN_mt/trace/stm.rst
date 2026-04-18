.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/stm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Mô-đun theo dõi hệ thống
========================

Mô-đun theo dõi hệ thống (STM) là một thiết bị được mô tả trong thông số kỹ thuật MIPI STP như
Trình tạo luồng dấu vết STP. STP (Giao thức theo dõi hệ thống) là một dấu vết
dữ liệu ghép kênh giao thức từ nhiều nguồn theo dõi, mỗi nguồn
được gán một cặp chủ và kênh duy nhất. Trong khi một số
các kênh chính và kênh này được phân bổ tĩnh cho một số
nguồn theo dõi phần cứng, những nguồn khác có sẵn cho phần mềm. Phần mềm
nguồn dấu vết thường được tự do lựa chọn bất kỳ
kết hợp chính/kênh từ nhóm này.

Ở đầu nhận của luồng STP này (phía bộ giải mã), theo dõi
nguồn chỉ có thể được xác định bằng cách kết hợp kênh chính/kênh, vì vậy trong
để bộ giải mã có thể hiểu được dấu vết đó
liên quan đến nhiều nguồn dấu vết, nó cần có khả năng ánh xạ những nguồn đó
cặp kênh chính/kênh với các nguồn theo dõi mà nó hiểu được.

Ví dụ, thật hữu ích khi biết rằng các thông báo nhật ký hệ thống xuất hiện
master 7 kênh 15, trong khi ứng dụng người dùng tùy ý có thể sử dụng master
48 đến 63 và các kênh từ 0 đến 127.

Để giải quyết vấn đề ánh xạ này, lớp stm cung cấp một cơ chế quản lý chính sách
cơ chế thông qua configfs, cho phép xác định các quy tắc ánh xạ chuỗi
mã định danh cho phạm vi chủ và kênh. Nếu những quy định (chính sách) này
phù hợp với những gì bộ giải mã mong đợi, nó sẽ có thể
xử lý dữ liệu theo dõi.

Chính sách này là một cấu trúc cây chứa các quy tắc (policy_node)
có một tên (mã định danh chuỗi) và một loạt các chủ và kênh
được liên kết với nó, nằm trong thư mục hệ thống con "stp-policy" trong
configfs. Tên của thư mục trên cùng (chính sách) được định dạng là
tên thiết bị STM được áp dụng chính sách này và tên tùy ý
định danh chuỗi được phân tách bằng dấu dừng. Từ ví dụ trên, một quy tắc
có thể trông như thế này::

$ ls /config/stp-policy/dummy_stm.my-policy/user
	kênh bậc thầy
	$ cat /config/stp-policy/dummy_stm.my-policy/user/masters
	48 63
	$ cat /config/stp-policy/dummy_stm.my-policy/user/channels
	0 127

điều đó có nghĩa là nhóm phân bổ chính cho quy tắc này bao gồm
masters 48 đến 63 và nhóm phân bổ kênh có các kênh 0
qua 127 trong đó. Bây giờ, bất kỳ nhà sản xuất nào (nguồn theo dõi) tự xác định
với chuỗi nhận dạng "người dùng" sẽ được cấp phát chủ và
kênh từ trong phạm vi này.

Các quy tắc này có thể được lồng vào nhau, ví dụ: người ta có thể định nghĩa một quy tắc "giả"
trong thư mục "người dùng" từ ví dụ trên và quy tắc mới này sẽ
được sử dụng cho các nguồn theo dõi có chuỗi id là "người dùng/giả".

Các nguồn theo dõi phải mở nút của thiết bị lớp stm và ghi
theo dõi dữ liệu vào bộ mô tả tập tin của nó.

Để tìm một nút chính sách thích hợp cho một nguồn theo dõi nhất định,
một số cơ chế có thể được sử dụng. Đầu tiên, một nguồn theo dõi có thể rõ ràng
tự xác định bằng cách gọi STP_POLICY_ID_SET ioctl trên ký tự
bộ mô tả tập tin của thiết bị, cung cấp chuỗi id của chúng, trước khi chúng ghi
bất kỳ dữ liệu nào ở đó. Thứ hai, nếu họ chọn không thực hiện hành vi rõ ràng
nhận dạng (vì bạn có thể không muốn vá phần mềm hiện có
để làm điều này), họ có thể bắt đầu ghi dữ liệu, tại thời điểm đó
lõi stm sẽ cố gắng tìm một nút chính sách có tên khớp với
tên của tác vụ (ví dụ: "syslogd") và nếu có, nó sẽ được sử dụng.
Thứ ba, nếu không thể tìm thấy tên tác vụ trong số các nút chính sách, thì
mục nhập toàn bộ "mặc định" sẽ được sử dụng nếu nó tồn tại. Mục này cũng
cần được tạo và cấu hình bởi quản trị viên hệ thống hoặc
bất kỳ công cụ nào đang đảm nhiệm việc cấu hình chính sách. Cuối cùng,
nếu tất cả các bước trên không thành công, ghi() vào bộ mô tả tệp stm
sẽ trả về lỗi (EINVAL).

Trước đây, nếu không tìm thấy nút chính sách nào cho nguồn theo dõi, thì stm
lớp sẽ âm thầm quay trở lại việc phân bổ những gì có sẵn đầu tiên
phạm vi chính/kênh liền kề từ đầu thiết bị
phạm vi chủ/kênh. Yêu cầu mới để tồn tại một nút chính sách
sẽ giúp các lập trình viên và quản trị viên hệ thống xác định các lỗ hổng trong cấu hình
và kiểm soát tốt hơn các nguồn không xác định.

Một số thiết bị STM có thể cho phép ánh xạ trực tiếp các vùng mmio của kênh
vào không gian người dùng để viết không sao chép. Một trang có thể ánh xạ (về mặt
mmu) thường sẽ chứa mmios của nhiều kênh, do đó người dùng sẽ
cần phân bổ nhiều kênh đó cho chính họ (thông qua
lệnh gọi ioctl() đã nói ở trên) để có thể thực hiện việc này. Nghĩa là, nếu bạn
vùng mmio kênh của thiết bị stm là 64 byte và kích thước trang phần cứng là
4096 byte, sau cuộc gọi STP_POLICY_ID_SET ioctl() thành công với
width==64, bạn sẽ có thể mmap() một trang trên tệp này
bộ mô tả và có quyền truy cập trực tiếp vào vùng mmio cho 64 kênh.

Ví dụ về các thiết bị STM là Intel(R) Trace Hub [1] và Coresight STM
[2].

stm_source
==========

Đối với các nguồn theo dõi dựa trên kernel, có thiết bị "stm_source"
lớp học. Các thiết bị thuộc loại này có thể được kết nối và ngắt kết nối đến/từ
thiết bị stm khi chạy thông qua thuộc tính sysfs có tên là "stm_source_link"
bằng cách viết tên của thiết bị stm mong muốn vào đó, ví dụ::

$ echo dummy_stm.0 > /sys/class/stm_source/console/stm_source_link

Để biết ví dụ về cách sử dụng giao diện stm_source trong kernel, hãy tham khảo
tới trình điều khiển stm_console, stm_heartbeat hoặc stm_ftrace.

Mỗi thiết bị stm_source sẽ cần có một thiết bị chính và một phạm vi
kênh, tùy thuộc vào số lượng kênh nó yêu cầu. Đây là
được phân bổ cho thiết bị theo cấu hình chính sách. Nếu
có một nút trong thư mục gốc của thư mục chính sách khớp với
tên thiết bị stm_source (ví dụ: "console"), nút này sẽ là
được sử dụng để phân bổ số chủ và số kênh. Nếu không có chính sách đó
nút, lõi stm sẽ sử dụng mục nhập bắt tất cả "mặc định", nếu một
tồn tại. Nếu không có nút chính sách nào tồn tại, thì write() tới stm_source_link
sẽ trả về một lỗi.

stm_console
===========

Một triển khai của giao diện này cũng được sử dụng trong ví dụ trên là
trình điều khiển "stm_console", về cơ bản cung cấp bảng điều khiển một chiều
cho các tin nhắn kernel trên thiết bị stm.

Để định cấu hình cặp kênh chính/kênh sẽ được gán cho kênh này
console trong luồng STP, hãy tạo mục nhập chính sách "bàn điều khiển" (xem phần
đầu văn bản này về cách thực hiện điều đó). Khi khởi tạo, nó sẽ
tiêu thụ một kênh.

stm_ftrace
==========

Đây là một thiết bị "stm_source" khác sau khi stm_ftrace đã được
được liên kết với thiết bị stm và nếu bộ theo dõi "chức năng" được bật,
địa chỉ hàm và địa chỉ hàm cha mà hệ thống con Ftrace
sẽ lưu vào bộ đệm vòng sẽ được xuất qua thiết bị stm tại
cùng một lúc.

Hiện tại chỉ hỗ trợ trình theo dõi "chức năng" Ftrace.

* [1] ZZ0000ZZ
* [2] ZZ0001ZZ