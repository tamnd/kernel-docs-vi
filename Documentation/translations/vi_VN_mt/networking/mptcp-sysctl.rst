.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/mptcp-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Biến hệ thống MPTCP
=====================

/proc/sys/net/mptcp/* Các biến
===============================

add_addr_timeout - INTEGER (giây)
	Đặt giá trị thời gian chờ tối đa sau đó có thông báo điều khiển ADD_ADDR
	sẽ được gửi lại tới một máy ngang hàng MPTCP chưa thừa nhận trước đó
	Tin nhắn ADD_ADDR. Thời gian chờ truyền lại được ước tính động dựa trên
	trên kết nối ước tính, thời gian khứ hồi được sử dụng nếu giá trị này là
	thấp hơn mức tối đa.

Không truyền lại nếu được đặt thành 0.

Giá trị mặc định khớp với TCP_RTO_MAX. Đây là một không gian tên
	sysctl.

Mặc định: 120

allow_join_initial_addr_port - BOOLEAN
	Cho phép các đồng nghiệp gửi yêu cầu tham gia đến địa chỉ IP và số cổng được sử dụng
	bởi luồng con ban đầu nếu giá trị là 1. Điều này kiểm soát một cờ
	được gửi đến thiết bị ngang hàng tại thời điểm kết nối và liệu các yêu cầu tham gia đó có được thực hiện hay không
	được chấp nhận hoặc bị từ chối.

Việc tham gia vào các địa chỉ được quảng cáo bằng ADD_ADDR không bị ảnh hưởng bởi điều này
	giá trị.

Đây là một sysctl theo không gian tên.

Mặc định: 1

có sẵn_path_managers - STRING
	Hiển thị các lựa chọn quản lý đường dẫn có sẵn đã được đăng ký. Thêm
	trình quản lý đường dẫn có thể có sẵn nhưng không được tải.

có sẵn_schedulers - STRING
	Hiển thị các lựa chọn lập lịch có sẵn đã được đăng ký. Thêm gói
	bộ lập lịch có thể có sẵn nhưng không được tải.

blackhole_timeout - INTEGER (giây)
	Khoảng thời gian ban đầu tính bằng giây để tắt MPTCP trên ổ cắm MPTCP đang hoạt động
	khi xảy ra sự cố lỗ đen tường lửa MPTCP. Khoảng thời gian này sẽ
	tăng theo cấp số nhân khi nhiều vấn đề về lỗ đen được phát hiện ngay sau đó
	MPTCP được kích hoạt lại và sẽ đặt lại về giá trị ban đầu khi
	vấn đề lỗ đen biến mất.

0 để tắt tính năng phát hiện lỗ đen. Đây là một sysctl theo không gian tên.

Mặc định: 3600

tổng kiểm tra_enables - BOOLEAN
	Kiểm soát xem có thể bật tổng kiểm tra DSS hay không.

Tổng kiểm tra DSS có thể được bật nếu giá trị khác 0. Đây là một
	mỗi không gian tên sysctl.

Mặc định: 0

close_timeout - INTEGER (giây)
	Đặt thời gian chờ thực hiện sau giờ nghỉ: trong trường hợp không có bất kỳ thao tác đóng hoặc
	tắt syscall, ổ cắm MPTCP sẽ duy trì trạng thái
	không thay đổi trong thời gian đó, sau lần loại bỏ luồng con cuối cùng, trước
	chuyển sang TCP_CLOSE.

Giá trị mặc định khớp với TCP_TIMEWAIT_LEN. Đây là một không gian tên
	sysctl.

Mặc định: 60

đã bật - BOOLEAN
	Kiểm soát xem có thể tạo ổ cắm MPTCP hay không.

Ổ cắm MPTCP có thể được tạo nếu giá trị là 1. Đây là một
	mỗi không gian tên sysctl.

Mặc định: 1 (đã bật)

path_manager - STRING
	Đặt tên trình quản lý đường dẫn mặc định để sử dụng cho mỗi MPTCP mới
	ổ cắm. Quản lý đường dẫn trong kernel sẽ kiểm soát luồng con
	kết nối và địa chỉ quảng cáo theo
	giá trị trên mỗi không gian tên được định cấu hình qua liên kết mạng MPTCP
	API. Quản lý đường dẫn không gian người dùng đặt luồng con kết nối trên mỗi MPTCP
	quyết định kết nối và địa chỉ quảng cáo dưới sự kiểm soát của
	một chương trình không gian người dùng đặc quyền, với chi phí là nhiều liên kết mạng hơn
	lưu lượng truy cập để truyền bá tất cả các sự kiện và lệnh liên quan.

Đây là một sysctl theo không gian tên.

* "kernel" - Trình quản lý đường dẫn trong kernel
	* "không gian người dùng" - Trình quản lý đường dẫn không gian người dùng

Mặc định: "hạt nhân"

pm_type - INTEGER
	Đặt loại trình quản lý đường dẫn mặc định để sử dụng cho mỗi MPTCP mới
	ổ cắm. Quản lý đường dẫn trong kernel sẽ kiểm soát luồng con
	kết nối và địa chỉ quảng cáo theo
	giá trị trên mỗi không gian tên được định cấu hình qua liên kết mạng MPTCP
	API. Quản lý đường dẫn không gian người dùng đặt luồng con kết nối trên mỗi MPTCP
	quyết định kết nối và địa chỉ quảng cáo dưới sự kiểm soát của
	một chương trình không gian người dùng đặc quyền, với chi phí là nhiều liên kết mạng hơn
	lưu lượng truy cập để truyền bá tất cả các sự kiện và lệnh liên quan.

Đây là một sysctl theo không gian tên.

Không được dùng nữa kể từ phiên bản 6.15, thay vào đó hãy sử dụng path_manager.

* 0 - Trình quản lý đường dẫn trong kernel
	* 1 - Trình quản lý đường dẫn không gian người dùng

Mặc định: 0

bộ lập lịch - STRING
	Chọn lịch trình bạn chọn.

Hỗ trợ lựa chọn các lịch trình khác nhau. Đây là một không gian tên
	sysctl.

Mặc định: "mặc định"

stale_loss_cnt - INTEGER
	Số khoảng thời gian truyền lại cấp MPTCP không có lưu lượng và
	dữ liệu đang chờ xử lý trên một luồng con nhất định cần được tuyên bố là cũ.
	Bộ lập lịch gói bỏ qua các luồng con cũ.
	Giá trị stale_loss_cnt thấp cho phép chuyển đổi dự phòng hoạt động nhanh chóng,
	giá trị cao tối đa hóa việc sử dụng liên kết trong các tình huống biên, ví dụ: mất mát
	liên kết với BER cao hoặc tạm dừng xử lý dữ liệu ngang hàng.

Đây là một sysctl theo không gian tên.

Mặc định: 4

syn_retrans_b Before_tcp_fallback - INTEGER
	Số lần truyền lại SYN + MP_CAPABLE trước khi quay trở lại
	TCP, tức là bỏ các tùy chọn MPTCP. Nói cách khác, nếu tất cả các gói
	bị rơi trên đường đi thì sẽ có:

* SYN ban đầu có hỗ trợ MPTCP
	* Số SYN này được truyền lại với sự hỗ trợ của MPTCP
	* Các lần truyền lại SYN tiếp theo sẽ không được hỗ trợ MPTCP

0 có nghĩa là lần truyền lại đầu tiên sẽ được thực hiện mà không có tùy chọn MPTCP.
	>= 128 có nghĩa là tất cả các lần truyền lại SYN sẽ giữ các tùy chọn MPTCP. A
	số thấp hơn có thể làm tăng khả năng phát hiện lỗ đen MPTCP dương tính giả.
	Đây là một sysctl theo không gian tên.

Mặc định: 2