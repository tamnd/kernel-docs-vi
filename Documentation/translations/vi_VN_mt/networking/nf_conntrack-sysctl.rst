.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/nf_conntrack-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Các biến của Netfilter Conntrack Sysfs
===================================

/proc/sys/net/netfilter/nf_conntrack_* Các biến:
=================================================

nf_conntrack_acct - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Bật tính năng tính toán luồng theo dõi kết nối. Byte và gói 64 bit
	bộ đếm trên mỗi luồng được thêm vào.

nf_conntrack_buckets - INTEGER
	Kích thước của bảng băm. Nếu không được chỉ định làm tham số trong mô-đun
	đang tải, kích thước mặc định được tính bằng cách chia tổng bộ nhớ
	đến 16384 để xác định số lượng thùng. Bảng băm sẽ
	không bao giờ có ít hơn 1024 và không bao giờ nhiều hơn 262144 thùng.
	Sysctl này chỉ có thể ghi được trong không gian tên mạng ban đầu.

nf_conntrack_checksum - BOOLEAN
	- 0 - bị vô hiệu hóa
	- không phải 0 - đã bật (mặc định)

Xác minh tổng kiểm tra các gói đến. Các gói có tổng kiểm tra sai là
	ở trạng thái INVALID. Nếu tính năng này được bật, các gói như vậy sẽ không được
	được xem xét để theo dõi kết nối.

nf_conntrack_count - INTEGER (chỉ đọc)
	Số lượng mục luồng hiện được phân bổ.

nf_conntrack_events - BOOLEAN
	- 0 - bị vô hiệu hóa
	- 1 - đã bật
	- 2 - tự động (mặc định)

Nếu tùy chọn này được bật, mã theo dõi kết nối sẽ
	cung cấp không gian người dùng với các sự kiện theo dõi kết nối qua ctnetlink.
	Mặc định phân bổ phần mở rộng nếu chương trình không gian người dùng được
	nghe các sự kiện ctnetlink.

nf_conntrack_expect_max - INTEGER
	Kích thước tối đa của bảng kỳ vọng.  Giá trị mặc định là
	nf_conntrack_buckets / 256. Tối thiểu là 1.

nf_conntrack_frag6_high_thresh - INTEGER
	mặc định 262144

Bộ nhớ tối đa được sử dụng để tập hợp lại các đoạn IPv6.  Khi nào
	nf_conntrack_frag6_high_thresh byte bộ nhớ được phân bổ cho việc này
	mục đích, trình xử lý phân đoạn sẽ ném các gói cho đến khi
	đã đạt được nf_conntrack_frag6_low_thresh.

nf_conntrack_frag6_low_thresh - INTEGER
	mặc định 196608

Xem nf_conntrack_frag6_low_thresh

nf_conntrack_frag6_timeout - INTEGER (giây)
	mặc định 60

Đã đến lúc giữ một đoạn IPv6 trong bộ nhớ.

nf_conntrack_generic_timeout - INTEGER (giây)
	mặc định 600

Mặc định cho thời gian chờ chung.  Điều này đề cập đến lớp 4 không xác định/không được hỗ trợ
	giao thức.

nf_conntrack_icmp_timeout - INTEGER (giây)
	mặc định 30

Mặc định cho thời gian chờ ICMP.

nf_conntrack_icmpv6_timeout - INTEGER (giây)
	mặc định 30

Mặc định cho thời gian chờ ICMP6.

nf_conntrack_log_invalid - INTEGER
	- 0 - tắt (mặc định)
	- 1 - ghi lại các gói ICMP
	- 6 - ghi lại các gói TCP
	- 17 - ghi lại các gói UDP
	- 41 - ghi nhật ký gói ICMPv6
	- 136 - ghi lại các gói UDPLITE
	- 255 - gói nhật ký của bất kỳ giao thức nào

Ghi lại các gói không hợp lệ thuộc loại được chỉ định bởi giá trị.

nf_conntrack_max - INTEGER
        Số lượng mục theo dõi kết nối tối đa được phép. Giá trị này được đặt
        thành nf_conntrack_buckets theo mặc định.
        Lưu ý rằng các mục theo dõi kết nối được thêm vào bảng hai lần -- một lần
        cho hướng ban đầu và một lần cho hướng trả lời (tức là với
        địa chỉ đảo ngược). Điều này có nghĩa là với cài đặt mặc định, mức tối đa
        table sẽ có độ dài chuỗi băm trung bình là 2 chứ không phải 1.

nf_conntrack_tcp_be_liberal - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Hãy thận trọng trong những gì bạn làm, hãy tự do trong những gì bạn chấp nhận từ người khác.
	Nếu nó khác 0, chúng tôi chỉ đánh dấu các phân đoạn RST ngoài cửa sổ là INVALID.

nf_conntrack_tcp_ignore_invalid_rst - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- 1 - đã bật

Nếu là 1, chúng tôi sẽ không đánh dấu các phân đoạn RST ngoài cửa sổ là INVALID.

nf_conntrack_tcp_loose - BOOLEAN
	- 0 - bị vô hiệu hóa
	- không phải 0 - đã bật (mặc định)

Nếu nó được đặt thành 0, chúng tôi sẽ vô hiệu hóa việc chọn đã được thiết lập
	kết nối.

nf_conntrack_tcp_max_retrans - INTEGER
	mặc định 3

Số gói tối đa có thể được truyền lại mà không cần
	đã nhận được ACK (có thể chấp nhận) từ đích. Nếu con số này
	đạt được, thời gian hẹn giờ ngắn hơn sẽ được bắt đầu.

nf_conntrack_tcp_timeout_close - INTEGER (giây)
	mặc định 10

nf_conntrack_tcp_timeout_close_wait - INTEGER (giây)
	mặc định 60

nf_conntrack_tcp_timeout_thành lập - INTEGER (giây)
	mặc định 432000 (5 ngày)

nf_conntrack_tcp_timeout_fin_wait - INTEGER (giây)
	mặc định 120

nf_conntrack_tcp_timeout_last_ack - INTEGER (giây)
	mặc định 30

nf_conntrack_tcp_timeout_max_retrans - INTEGER (giây)
	mặc định 300

nf_conntrack_tcp_timeout_syn_recv - INTEGER (giây)
	mặc định 60

nf_conntrack_tcp_timeout_syn_sent - INTEGER (giây)
	mặc định 120

nf_conntrack_tcp_timeout_time_wait - INTEGER (giây)
	mặc định 120

nf_conntrack_tcp_timeout_unacknowd - INTEGER (giây)
	mặc định 300

nf_conntrack_timestamp - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Bật tính năng đánh dấu thời gian của luồng theo dõi kết nối.

nf_conntrack_sctp_timeout_closed - INTEGER (giây)
	mặc định 10

nf_conntrack_sctp_timeout_cookie_wait - INTEGER (giây)
	mặc định 3

nf_conntrack_sctp_timeout_cookie_echoed - INTEGER (giây)
	mặc định 3

nf_conntrack_sctp_timeout_thành lập - INTEGER (giây)
	mặc định 210

Mặc định được đặt thành (hb_interval * path_max_retrans + rto_max)

nf_conntrack_sctp_timeout_shutdown_sent - INTEGER (giây)
	mặc định 3

nf_conntrack_sctp_timeout_shutdown_recd - INTEGER (giây)
	mặc định 3

nf_conntrack_sctp_timeout_shutdown_ack_sent - INTEGER (giây)
	mặc định 3

nf_conntrack_sctp_timeout_heartbeat_sent - INTEGER (giây)
	mặc định 30

Thời gian chờ này được sử dụng để thiết lập mục nhập conntrack trên các đường dẫn phụ.
	Mặc định được đặt thành hb_interval.

nf_conntrack_udp_timeout - INTEGER (giây)
	mặc định 30

nf_conntrack_udp_timeout_stream - INTEGER (giây)
	mặc định 120

Thời gian chờ kéo dài này sẽ được sử dụng trong trường hợp có luồng UDP
	được phát hiện.

nf_conntrack_gre_timeout - INTEGER (giây)
	mặc định 30

nf_conntrack_gre_timeout_stream - INTEGER (giây)
	mặc định 180

Thời gian chờ kéo dài này sẽ được sử dụng trong trường hợp có luồng GRE
	được phát hiện.

nf_hooks_lwtunnel - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Nếu tùy chọn này được bật, các móc bộ lọc mạng đường hầm nhẹ sẽ được
	đã bật. Tùy chọn này không thể bị tắt khi nó được bật.

nf_flowtable_tcp_timeout - INTEGER (giây)
        mặc định 30

Kiểm soát thời gian chờ giảm tải cho các kết nối tcp.
        Các kết nối TCP có thể được giảm tải từ nf conntrack sang bảng luồng nf.
        Khi đã cũ, kết nối sẽ được trả về nf conntrack.

nf_flowtable_udp_timeout - INTEGER (giây)
        mặc định 30

Kiểm soát thời gian chờ giảm tải cho các kết nối udp.
        Các kết nối UDP có thể được giảm tải từ nf conntrack sang bảng luồng nf.
        Khi đã cũ, kết nối sẽ được trả về nf conntrack.