.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ip-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
Hệ thống IP
===========

/proc/sys/net/ipv4/* Các biến
==============================

ip_forward - BOOLEAN
	Chuyển tiếp gói tin giữa các giao diện.

Biến này rất đặc biệt, sự thay đổi của nó sẽ đặt lại tất cả cấu hình
	tham số về trạng thái mặc định của chúng (RFC1122 cho máy chủ, RFC1812
	dành cho bộ định tuyến)

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

ip_default_ttl - INTEGER
	Giá trị mặc định của trường TTL (Thời gian tồn tại) cho dữ liệu gửi đi (nhưng không phải
	chuyển tiếp) gói IP. Phải nằm trong khoảng từ 1 đến 255.
	Mặc định: 64 (theo khuyến nghị của RFC1700)

ip_no_pmtu_disc - INTEGER
	Vô hiệu hóa đường dẫn MTU Discovery. Nếu được bật ở chế độ 1 và
	đã nhận được ICMP yêu cầu phân mảnh, PMTU cho điều này
	đích sẽ được đặt ở mức nhỏ nhất của MTU cũ để
	điểm đến này và min_pmtu (xem bên dưới). Bạn sẽ cần
	để nâng min_pmtu lên giao diện nhỏ nhất MTU trên hệ thống của bạn
	theo cách thủ công nếu bạn muốn tránh các đoạn được tạo cục bộ.

Ở chế độ 2, các thông báo Path MTU Discovery đến sẽ được
	bị loại bỏ. Các khung gửi đi được xử lý giống như ở chế độ 1,
	ngầm thiết lập IP_PMTUDISC_DONT trên mọi ổ cắm được tạo.

Chế độ 3 là chế độ khám phá pmtu cứng cáp. Hạt nhân sẽ chỉ
	chấp nhận các lỗi cần phân mảnh nếu giao thức cơ bản
	có thể xác minh chúng bên cạnh việc tra cứu ổ cắm đơn giản. hiện tại
	các giao thức mà các sự kiện pmtu sẽ được vinh danh là TCP và
	SCTP khi họ xác minh, ví dụ: số thứ tự hoặc
	hiệp hội. Chế độ này không nên được kích hoạt trên toàn cầu nhưng được
	chỉ nhằm mục đích bảo mật, ví dụ: máy chủ tên trong không gian tên nơi
	Đường dẫn TCP mtu vẫn phải hoạt động nhưng đường dẫn MTU thông tin của khác
	các giao thức nên được loại bỏ. Nếu được bật trên toàn cầu, chế độ này
	có thể phá vỡ các giao thức khác.

Các giá trị có thể có: 0-3

Mặc định: FALSE

phút_pmtu - INTEGER
	mặc định 552 - Đường dẫn tối thiểu MTU. Trừ khi điều này được thay đổi bằng tay,
	mỗi pmtu được lưu trong bộ nhớ cache sẽ không bao giờ thấp hơn cài đặt này.

ip_forward_use_pmtu - BOOLEAN
	Theo mặc định, chúng tôi không tin tưởng MTU đường dẫn giao thức trong khi chuyển tiếp
	vì chúng có thể dễ dàng bị giả mạo và có thể dẫn đến những sai sót không mong muốn.
	sự phân mảnh của bộ định tuyến.
	Bạn chỉ cần kích hoạt tính năng này nếu bạn có phần mềm không gian người dùng
	nó cố gắng tự mình khám phá đường dẫn mtus và phụ thuộc vào
	kernel tôn vinh thông tin này. Thông thường đây không phải là
	trường hợp.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

fwmark_reflect - BOOLEAN
	Kiểm soát fwmark của các gói trả lời IPv4 do kernel tạo ra không phải
	được liên kết với ổ cắm chẳng hạn như phản hồi tiếng vang TCP RST hoặc ICMP).
	Nếu bị tắt, các gói này có fwmark bằng 0. Nếu được bật, họ có
	fwmark của gói họ đang trả lời.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

fib_multipath_use_neigh - BOOLEAN
	Sử dụng trạng thái của mục lân cận hiện có khi xác định bước nhảy tiếp theo cho
	các tuyến đường đa đường. Nếu bị tắt, thông tin hàng xóm sẽ không được sử dụng và
	các gói có thể được chuyển hướng tới một chặng tiếp theo bị lỗi. Chỉ hợp lệ cho hạt nhân
	được xây dựng với kích hoạt CONFIG_IP_ROUTE_MULTIPATH.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

fib_multipath_hash_policy - INTEGER
	Kiểm soát chính sách băm nào sẽ được sử dụng cho các tuyến đường đa đường. Chỉ hợp lệ
	đối với các hạt nhân được xây dựng với CONFIG_IP_ROUTE_MULTIPATH được kích hoạt.

Mặc định: 0 (Lớp 3)

Các giá trị có thể:

- 0 - Lớp 3
	- 1 - Lớp 4
	- 2 - Lớp 3 hoặc Lớp 3 bên trong nếu có
	- 3 - Băm đa đường tùy chỉnh. Các trường được sử dụng để tính toán băm đa đường
	  được xác định bởi fib_multipath_hash_fields sysctl

fib_multipath_hash_fields - UNSIGNED INTEGER
	Khi fib_multipath_hash_policy được đặt thành 3 (băm đa đường tùy chỉnh),
	các trường được sử dụng để tính toán băm đa đường được xác định bởi điều này
	sysctl.

Giá trị này là một bitmask cho phép các trường khác nhau cho hàm băm đa đường
	tính toán.

Các trường có thể là:

====== ===============================
	0x0001 Địa chỉ IP nguồn
	0x0002 Địa chỉ IP đích
	Giao thức IP 0x0004
	0x0008 Không sử dụng (Nhãn luồng)
	Cổng nguồn 0x0010
	Cổng đích 0x0020
	0x0040 Địa chỉ IP nguồn bên trong
	0x0080 Địa chỉ IP đích bên trong
	0x0100 Giao thức IP bên trong
	Nhãn dòng chảy bên trong 0x0200
	0x0400 Cổng nguồn bên trong
	0x0800 Cổng đích bên trong
	====== ===============================

Mặc định: 0x0007 (IP nguồn, IP đích và giao thức IP)

fib_multipath_hash_seed - UNSIGNED INTEGER
	Giá trị gốc được sử dụng khi tính toán hàm băm cho các tuyến đường đa đường. Áp dụng
	cho cả đường dẫn dữ liệu IPv4 và IPv6. Chỉ hiện diện cho các hạt nhân được xây dựng bằng
	Đã bật CONFIG_IP_ROUTE_MULTIPATH.

Khi được đặt thành 0, giá trị gốc được sử dụng cho định tuyến đa đường mặc định là
	một được tạo ngẫu nhiên nội bộ.

Thuật toán băm thực tế không được chỉ định -- không có gì đảm bảo
	rằng sự phân bổ bước nhảy tiếp theo được thực hiện bởi một hạt giống nhất định sẽ giữ ổn định
	trên các phiên bản kernel.

Mặc định: 0 (ngẫu nhiên)

fib_sync_mem - UNSIGNED INTEGER
	Lượng bộ nhớ bẩn từ các mục fib có thể bị tồn đọng trước đó
	bắt buộc phải đồng bộ hóa_rcu.

Mặc định: 512kB Tối thiểu: 64kB Tối đa: 64MB

ip_forward_update_priority - INTEGER
	Có cập nhật mức độ ưu tiên SKB từ trường "TOS" trong tiêu đề IPv4 sau trường đó hay không
	được chuyển tiếp. Mức độ ưu tiên SKB mới được ánh xạ từ giá trị trường TOS
	theo bảng rt_tos2priority (xem ví dụ man tc-prio).

Mặc định: 1 (Ưu tiên cập nhật.)

Các giá trị có thể:

- 0 - Không cập nhật mức độ ưu tiên.
	- 1 - Cập nhật mức độ ưu tiên.

tuyến đường/max_size - INTEGER
	Số lượng tuyến đường tối đa được phép trong kernel.  tăng
	điều này khi sử dụng số lượng lớn giao diện và/hoặc tuyến đường.

Từ kernel linux 3.6 trở đi, tính năng này không được dùng cho ipv4
	vì bộ đệm tuyến đường không còn được sử dụng nữa.

Từ kernel linux 6.3 trở đi, tính năng này không được dùng cho ipv6
	vì bộ sưu tập rác quản lý các mục tuyến được lưu trong bộ nhớ cache.

lân/mặc định/gc_thresh1 - INTEGER
	Số lượng mục tối thiểu cần giữ.  Người thu gom rác sẽ không
	xóa các mục nếu có ít hơn con số này.

Mặc định: 128

lân/mặc định/gc_thresh2 - INTEGER
	Ngưỡng khi người thu gom rác trở nên tích cực hơn về
	thanh lọc các mục. Các mục cũ hơn 5 giây sẽ bị xóa
	khi vượt qua con số này.

Mặc định: 512

lân/mặc định/gc_thresh3 - INTEGER
	Số mục nhập lân cận không phải PERMANENT tối đa được phép.  tăng
	điều này khi sử dụng số lượng lớn giao diện và khi giao tiếp
	với số lượng lớn các đồng nghiệp được kết nối trực tiếp.

Mặc định: 1024

lân cận/mặc định/gc_interval - INTEGER
	Chỉ định tần suất thu gom rác cho các mục hàng xóm
	nên chạy. Giá trị này áp dụng cho toàn bộ bảng, không
	các mục riêng lẻ. Không được sử dụng kể từ kernel v2.6.8.

Mặc định: 30 giây

lân/mặc định/gc_stale_time - INTEGER
	Xác định khoảng thời gian một mục hàng xóm có thể không được sử dụng trước khi nó được sử dụng
	được coi là cũ và đủ điều kiện để thu gom rác. Các mục có
	không được sử dụng lâu hơn thời gian này sẽ bị rác bỏ đi
	bộ sưu tập, trừ khi chúng có tham chiếu đang hoạt động, được đánh dấu là PERMANENT,
	hoặc mang cờ NTF_EXT_LEARNED hoặc NTF_EXT_VALIDATED. Mục cũ
	chỉ bị GC định kỳ loại bỏ khi có ít nhất gc_thresh1
	hàng xóm trong bảng.

Mặc định: 60 giây

lân/mặc định/unres_qlen_bytes - INTEGER
	Số byte tối đa có thể được sử dụng bởi các gói
	được xếp hàng đợi cho từng địa chỉ chưa được giải quyết bởi các lớp mạng khác.
	(được thêm vào linux 3.3)

Đặt giá trị âm là vô nghĩa và sẽ trả về lỗi.

Mặc định: SK_WMEM_DEFAULT, (giống như net.core.wmem_default).

Giá trị chính xác phụ thuộc vào kiến trúc và tùy chọn kernel,
		nhưng đủ để cho phép xếp hàng 256 gói
		có kích thước trung bình.

lân/mặc định/unres_qlen - INTEGER
	Số lượng gói tối đa có thể được xếp hàng đợi cho mỗi gói
	địa chỉ chưa được giải quyết bởi các lớp mạng khác.

(không dùng nữa trong linux 3.3): thay vào đó hãy sử dụng unres_qlen_bytes.

Trước linux 3.3, giá trị mặc định là 3 có thể gây ra
	mất gói bất ngờ. Giá trị mặc định hiện tại được tính toán
	theo giá trị mặc định của unres_qlen_bytes và kích thước thật của
	gói.

Mặc định: 101

lân cận/mặc định/interval_probe_time_ms - INTEGER
	Khoảng thời gian thăm dò cho các mục hàng xóm có cờ NTF_MANAGED,
	giá trị tối thiểu là 1.

Mặc định: 5000

mtu_hết hạn - INTEGER
	Thời gian, tính bằng giây, thông tin PMTU được lưu trong bộ nhớ đệm sẽ được lưu giữ.

min_adv_mss - INTEGER
	MSS được quảng cáo phụ thuộc vào tuyến chặng đầu tiên MTU, nhưng sẽ
	không bao giờ thấp hơn cài đặt này.

fib_notify_on_flag_change - INTEGER
        Có phát thông báo RTM_NEWROUTE bất cứ khi nào RTM_F_OFFLOAD/
        Cờ RTM_F_TRAP/RTM_F_OFFLOAD_FAILED được thay đổi.

Sau khi cài đặt tuyến đường tới kernel, không gian người dùng sẽ nhận được một
        xác nhận, có nghĩa là tuyến đường đã được cài đặt trong kernel,
        nhưng không nhất thiết phải ở phần cứng.
        Cũng có thể tuyến đường đã được cài đặt trong phần cứng có thể thay đổi
        hành động của nó và do đó cờ của nó. Ví dụ: một tuyến máy chủ được
        Các gói bẫy có thể được "thúc đẩy" để thực hiện việc giải mã sau
        việc cài đặt đường hầm IPinIP/VXLAN.
        Các thông báo sẽ cho người dùng biết trạng thái của tuyến đường.

Mặc định: 0 (Không phát ra thông báo.)

Các giá trị có thể:

- 0 - Không phát ra thông báo.
        - 1 - Phát ra thông báo.
        - 2 - Chỉ phát ra thông báo khi thay đổi cờ RTM_F_OFFLOAD_FAILED.

Phân mảnh IP:

ipfrag_high_thresh - LONG INTEGER
	Bộ nhớ tối đa được sử dụng để tập hợp lại các đoạn IP.

ipfrag_low_thresh - LONG INTEGER
	(Lỗi thời kể từ linux-4.17)
	Bộ nhớ tối đa được sử dụng để tập hợp lại các đoạn IP trước kernel
	bắt đầu loại bỏ các hàng đợi phân đoạn không đầy đủ để giải phóng tài nguyên.
	Kernel vẫn chấp nhận các đoạn mới để chống phân mảnh.

ipfrag_time - INTEGER
	Thời gian tính bằng giây để giữ một đoạn IP trong bộ nhớ.

ipfrag_max_dist - INTEGER
	ipfrag_max_dist là một giá trị nguyên không âm xác định
	"sự rối loạn" tối đa được phép giữa các mảnh có chung một
	địa chỉ nguồn IP chung. Lưu ý rằng việc sắp xếp lại các gói tin là
	không có gì bất thường, nhưng nếu một số lượng lớn các mảnh vỡ đến từ một nguồn
	Địa chỉ IP trong khi hàng đợi phân đoạn cụ thể vẫn chưa đầy đủ, nó
	có thể chỉ ra rằng một hoặc nhiều đoạn thuộc hàng đợi đó
	đã bị mất. Khi ipfrag_max_dist dương tính, hãy kiểm tra bổ sung
	được thực hiện trên các đoạn trước khi chúng được thêm vào hàng đợi tập hợp lại - nếu
	Các đoạn ipfrag_max_dist (hoặc nhiều hơn) đã đến từ một IP cụ thể
	địa chỉ giữa các phần bổ sung vào bất kỳ hàng đợi phân đoạn IP nào sử dụng nguồn đó
	địa chỉ, người ta cho rằng một hoặc nhiều đoạn trong hàng đợi được
	bị mất. Hàng đợi phân đoạn hiện có sẽ bị loại bỏ và một hàng đợi mới
	bắt đầu. Giá trị ipfrag_max_dist bằng 0 sẽ vô hiệu hóa việc kiểm tra này.

Sử dụng một giá trị rất nhỏ, ví dụ: 1 hoặc 2, đối với ipfrag_max_dist có thể
	dẫn đến việc loại bỏ các hàng đợi phân đoạn một cách không cần thiết khi bình thường
	việc sắp xếp lại các gói xảy ra, điều này có thể dẫn đến ứng dụng kém
	hiệu suất. Sử dụng một giá trị rất lớn, ví dụ: 50000, tăng
	khả năng tập hợp lại các đoạn IP có nguồn gốc không chính xác
	từ các gói dữ liệu IP khác nhau, điều này có thể dẫn đến hỏng dữ liệu.
	Mặc định: 64

bc_forwarding - INTEGER
	bc_forwarding bật tính năng được mô tả trong rfc1812#section-5.3.5.2
	và rfc2644. Nó cho phép bộ định tuyến chuyển tiếp chương trình phát sóng có hướng.
	Để kích hoạt tính năng này, mục nhập 'tất cả' và mục nhập giao diện đầu vào
	nên được đặt thành 1.
	Mặc định: 0

Bộ nhớ ngang hàng INET
=================

inet_peer_threshold - INTEGER
	Kích thước gần đúng của bộ lưu trữ.  Bắt đầu từ ngưỡng này
	các mục sẽ được ném mạnh mẽ.  Ngưỡng này cũng xác định
	thời gian tồn tại của các mục và khoảng thời gian giữa việc thu gom rác
	vượt qua.  Nhiều mục hơn, thời gian tồn tại ít hơn, khoảng thời gian GC ít hơn.

inet_peer_minttl - INTEGER
	Thời gian tồn tại tối thiểu của các mục.  Sẽ đủ để che đi mảnh vỡ
	thời gian tồn tại ở phía lắp ráp lại.  Thời gian tồn tại tối thiểu này là
	được đảm bảo nếu kích thước nhóm nhỏ hơn inet_peer_threshold.
	Tính bằng giây.

inet_peer_maxttl - INTEGER
	Thời gian tồn tại tối đa của các mục.  Các mục không sử dụng sẽ hết hạn sau
	khoảng thời gian này nếu không có áp lực bộ nhớ trên hồ bơi (tức là
	khi số lượng mục trong nhóm rất nhỏ).
	Tính bằng giây.

Biến TCP
=============

somaxconn - INTEGER
	Giới hạn tồn đọng của ổ cắm listen(), được gọi trong không gian người dùng là SOMAXCONN.
	Mặc định là 4096. (Là 128 trước linux-5.4)
	Xem thêm tcp_max_syn_backlog để điều chỉnh bổ sung cho ổ cắm TCP.

tcp_abort_on_overflow - BOOLEAN
	Nếu dịch vụ nghe quá chậm để chấp nhận kết nối mới,
	thiết lập lại chúng. Trạng thái mặc định là FALSE. Nó có nghĩa là nếu tràn
	xảy ra do một vụ nổ, kết nối sẽ phục hồi. Kích hoạt tính năng này
	tùy chọn _only_ nếu bạn thực sự chắc chắn rằng daemon đang nghe
	không thể điều chỉnh để chấp nhận kết nối nhanh hơn. Kích hoạt tính năng này
	tùy chọn có thể gây hại cho khách hàng của máy chủ của bạn.

tcp_adv_win_scale - INTEGER
	Lỗi thời kể từ linux-6.6
	Đếm chi phí đệm dưới dạng byte/2^tcp_adv_win_scale
	(nếu tcp_adv_win_scale > 0) hoặc byte-byte/2^(-tcp_adv_win_scale),
	nếu nó là <= 0.

Các giá trị có thể có là [-31, 31], bao gồm.

Mặc định: 1

tcp_allowed_congestion_control - STRING
	Hiển thị/đặt các lựa chọn kiểm soát tắc nghẽn có sẵn cho người không có đặc quyền
	quá trình. Danh sách này là một tập hợp con của những danh sách được liệt kê trong
	tcp_available_congestion_control.

Mặc định là "reno" và cài đặt mặc định (tcp_congestion_control).

tcp_app_win - INTEGER
	Dự trữ tối đa(window/2^tcp_app_win, mss) cửa sổ cho ứng dụng
	bộ đệm. Giá trị 0 là đặc biệt, nghĩa là không có gì được bảo lưu.

Các giá trị có thể có là [0, 31], bao gồm.

Mặc định: 31

tcp_autocorking - BOOLEAN
	Kích hoạt tính năng tự động đóng nút TCP:
	Khi các ứng dụng thực hiện các lệnh gọi hệ thống write()/sendmsg() nhỏ liên tiếp,
	chúng tôi cố gắng kết hợp những bài viết nhỏ này càng nhiều càng tốt để giảm
	tổng số gói đã gửi. Việc này được thực hiện nếu ít nhất một lần trước
	gói cho luồng đang chờ trong hàng đợi Qdisc hoặc thiết bị truyền
	xếp hàng. Các ứng dụng vẫn có thể sử dụng TCP_CORK để có hoạt động tối ưu
	khi nào họ biết cách/khi nào nên mở ổ cắm của mình.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_available_congestion_control - STRING
	Hiển thị các lựa chọn kiểm soát tắc nghẽn có sẵn đã được đăng ký.
	Nhiều thuật toán kiểm soát tắc nghẽn có thể có sẵn dưới dạng mô-đun,
	nhưng không được tải.

tcp_base_mss - INTEGER
	Giá trị ban đầu của search_low sẽ được sử dụng bởi lớp đóng gói
	Đường dẫn khám phá MTU (thăm dò MTU).  Nếu tính năng thăm dò MTU được bật,
	đây là MSS ban đầu được kết nối sử dụng.

tcp_mtu_probe_floor - INTEGER
	Nếu tính năng thăm dò MTU được bật thì điều này sẽ giới hạn MSS tối thiểu được sử dụng cho search_low
	cho kết nối.

Mặc định: 48

tcp_min_snd_mss - INTEGER
	Tin nhắn TCP SYN và SYNACK thường quảng cáo tùy chọn ADVMSS,
	như được mô tả trong RFC 1122 và RFC 6691.

Nếu tùy chọn ADVMSS này nhỏ hơn tcp_min_snd_mss,
	nó được âm thầm giới hạn ở tcp_min_snd_mss.

Mặc định: 48 (ít nhất 8 byte tải trọng cho mỗi phân đoạn)

tcp_congestion_control - STRING
	Thiết lập thuật toán điều khiển tắc nghẽn để sử dụng cho các
	kết nối. Thuật toán "reno" luôn có sẵn, nhưng
	các lựa chọn bổ sung có thể có sẵn dựa trên cấu hình kernel.
	Mặc định được đặt như một phần của cấu hình kernel.
	Đối với các kết nối thụ động, lựa chọn kiểm soát tắc nghẽn của người nghe
	được kế thừa.

[xem setsockopt(listenfd, SOL_TCP, TCP_CONGESTION, "tên" ...)]

tcp_dsack - BOOLEAN
	Cho phép TCP gửi SACK "trùng lặp".

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_early_retrans - INTEGER
	Đầu dò mất đuôi (TLP) chuyển đổi RTO xảy ra do đuôi
	tổn thất cần phục hồi nhanh (RFC8985). Lưu ý rằng
	TLP yêu cầu RACK hoạt động bình thường (xem tcp_recovery bên dưới)

Các giá trị có thể:

- 0 vô hiệu hóa TLP
		- 3 hoặc 4 kích hoạt TLP

Mặc định: 3

tcp_ecn - INTEGER
	Kiểm soát việc sử dụng Thông báo tắc nghẽn rõ ràng (ECN) của TCP.
	ECN chỉ được sử dụng khi cả hai đầu của kết nối TCP đều hỗ trợ
	cho nó. Tính năng này rất hữu ích trong việc tránh tổn thất do tắc nghẽn bởi
	cho phép các bộ định tuyến hỗ trợ báo hiệu tắc nghẽn trước khi phải loại bỏ
	gói. Một máy chủ hỗ trợ ECN đều gửi ECN ở lớp IP và
	phản hồi lại ECN ở lớp TCP. Biến thể cao nhất của phản hồi ECN
	mà cả hai đồng nghiệp hỗ trợ được chọn bằng đàm phán ECN (ECN chính xác,
	ECN, hoặc không có ECN).

Biến thể được đàm phán cao nhất cho các yêu cầu kết nối đến
	và biến thể cao nhất được yêu cầu bởi kết nối đi
	cố gắng:

===== ===========================================
	Giá trị Kết nối đến Kết nối đi
	===== ===========================================
	0 Không ECN Không ECN
	1 ECN ECN
	2 ECN Không ECN
	3 AccECN AccECN
	4 AccECN ECN
	5 AccECN số ECN
	===== ===========================================

Mặc định: 2

tcp_ecn_option - INTEGER
	Kiểm soát việc gửi tùy chọn ECN (AccECN) chính xác khi AccECN đã được kích hoạt
	đàm phán thành công trong quá trình bắt tay. Gửi logic ức chế
	gửi tùy chọn AccECN bất kể cài đặt này khi không có AccECN
	tùy chọn đã được nhìn thấy cho hướng ngược lại.

Các giá trị có thể là:

= =================================================================
	0 Không bao giờ gửi tùy chọn AccECN. Điều này cũng vô hiệu hóa việc gửi AccECN
	  tùy chọn trong SYN/ACK trong quá trình bắt tay.
	1 Gửi tùy chọn AccECN tiết kiệm theo tùy chọn tối thiểu
	  các quy tắc được nêu trong Draft-ietf-tcpm-accurate-ecn.
	2 Gửi tùy chọn AccECN trên mỗi gói bất cứ khi nào nó phù hợp với TCP
	  không gian tùy chọn ngoại trừ khi dự phòng AccECN được kích hoạt.
	3 Gửi tùy chọn AccECN trên mỗi gói bất cứ khi nào nó phù hợp với TCP
	  không gian tùy chọn ngay cả khi dự phòng AccECN được kích hoạt.
	= =================================================================

Mặc định: 2

tcp_ecn_option_beacon - INTEGER
	Kiểm soát tần suất gửi tùy chọn ECN (AccECN) chính xác trên mỗi RTT và nó
	chỉ có hiệu lực khi tcp_ecn_option được đặt thành 2.

Mặc định: 3 (AccECN sẽ được gửi ít nhất 3 lần cho mỗi RTT)

tcp_ecn_fallback - BOOLEAN
	Nếu kernel phát hiện kết nối ECN hoạt động sai, hãy bật tính năng rơi
	trở lại không phải ECN. Hiện tại, núm này thực hiện dự phòng
	từ RFC3168, phần 6.1.1.1., nhưng chúng tôi bảo lưu điều đó trong tương lai,
	cơ chế phát hiện bổ sung có thể được thực hiện theo điều này
	núm vặn. Giá trị này không được sử dụng nếu tcp_ecn hoặc trên mỗi tuyến (hoặc tắc nghẽn
	control) Cài đặt ECN bị tắt.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_fack - BOOLEAN
	Đây là một lựa chọn cũ, nó không còn tác dụng nữa.

tcp_fin_timeout - INTEGER
	Khoảng thời gian một đứa trẻ mồ côi (không còn được nhắc đến bởi bất kỳ
	application) kết nối sẽ vẫn ở trạng thái FIN_WAIT_2
	trước khi nó bị hủy bỏ ở đầu cục bộ.  Trong khi một cách hoàn hảo
	trạng thái "chỉ nhận" hợp lệ cho một kết nối không mồ côi, một
	kết nối mồ côi ở trạng thái FIN_WAIT_2 có thể chờ
	mãi mãi để điều khiển từ xa đóng kết nối.

Cf. tcp_max_orphans

Mặc định: 60 giây

tcp_frto - INTEGER
	Cho phép Chuyển tiếp RTO-Recovery (F-RTO) được xác định trong RFC5682.
	F-RTO là thuật toán phục hồi nâng cao để truyền lại TCP
	hết thời gian chờ.  Nó đặc biệt có lợi trong các mạng nơi
	RTT dao động (ví dụ: không dây). F-RTO chỉ dành cho phía người gửi
	sửa đổi. Nó không yêu cầu bất kỳ sự hỗ trợ nào từ đồng nghiệp.

Theo mặc định, nó được bật với giá trị khác 0. 0 vô hiệu hóa F-RTO.

tcp_fwmark_accept - BOOLEAN
	Nếu được bật, các kết nối đến tới ổ cắm nghe không có
	dấu ổ cắm sẽ đặt dấu của ổ cắm chấp nhận thành fwmark của
	gói SYN đến. Điều này sẽ khiến tất cả các gói trên kết nối đó
	(bắt đầu từ SYNACK đầu tiên) được gửi cùng với dấu fwmark đó. các
	dấu của ổ cắm nghe không thay đổi. Ổ cắm nghe đã có
	có một fwmark được đặt thông qua setsockopt(SOL_SOCKET, SO_MARK, ...)
	không bị ảnh hưởng.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_invalid_ratelimit - INTEGER
	Giới hạn tốc độ tối đa để gửi xác nhận trùng lặp
	để phản hồi các gói TCP đến dành cho gói hiện có
	kết nối nhưng không hợp lệ vì bất kỳ lý do nào sau đây:

(a) số thứ tự ngoài cửa sổ,
	  (b) số xác nhận ngoài cửa sổ, hoặc
	  (c) Lỗi kiểm tra PAWS (Bảo vệ chống lại các số thứ tự được gói)

Điều này có thể giúp giảm thiểu các cuộc tấn công DoS "vòng lặp ack" đơn giản, trong đó
	hộp trung gian có lỗi hoặc độc hại hoặc kẻ trung gian có thể
	viết lại các trường tiêu đề TCP theo cách gây ra từng điểm cuối
	nghĩ rằng người kia đang gửi các phân đoạn TCP không hợp lệ, do đó
	khiến mỗi bên gửi một luồng bản sao không ngừng nghỉ
	xác nhận cho các phân đoạn không hợp lệ.

Việc sử dụng 0 sẽ vô hiệu hóa việc giới hạn tốc độ của các gói song công để đáp ứng với
	phân đoạn không hợp lệ; mặt khác giá trị này chỉ định mức tối thiểu
	khoảng cách giữa việc gửi các gói du lịch như vậy, tính bằng mili giây.

Mặc định: 500 (mili giây).

tcp_keepalive_time - INTEGER
	Tần suất TCP gửi tin nhắn lưu giữ khi tính năng lưu giữ được bật.
	Mặc định: 2 giờ.

tcp_keepalive_probes - INTEGER
	Có bao nhiêu đầu dò cố định TCP gửi đi cho đến khi quyết định rằng
	kết nối bị hỏng. Giá trị mặc định: 9.

tcp_keepalive_intvl - INTEGER
	Tần suất các đầu dò được gửi đi. nhân với
	tcp_keepalive_probes đã đến lúc loại bỏ kết nối không phản hồi,
	sau khi cuộc thăm dò bắt đầu. Giá trị mặc định: 75 giây tức là kết nối
	sẽ bị hủy bỏ sau ~11 phút thử lại.

tcp_l3mdev_accept - BOOLEAN
	Cho phép các ổ cắm con kế thừa chỉ mục thiết bị chính L3.
	Việc bật tùy chọn này cho phép ổ cắm nghe "toàn cầu" hoạt động
	trên các miền chính L3 (ví dụ: VRF) với các ổ cắm được kết nối
	bắt nguồn từ ổ cắm nghe để được liên kết với miền L3 trong
	mà các gói có nguồn gốc. Chỉ hợp lệ khi kernel đã được
	được biên dịch bằng CONFIG_NET_L3_MASTER_DEV.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_low_latency - BOOLEAN
	Đây là một lựa chọn cũ, nó không còn tác dụng nữa.

tcp_max_orphans - INTEGER
	Số lượng ổ cắm TCP tối đa không được gắn vào bất kỳ trình xử lý tệp người dùng nào,
	được giữ bởi hệ thống.	Nếu vượt quá con số này, các kết nối mồ côi sẽ bị
	đặt lại ngay lập tức và cảnh báo được in ra. Giới hạn này tồn tại
	chỉ để ngăn chặn các cuộc tấn công DoS đơn giản, bạn _không được_ dựa vào điều này
	hoặc hạ thấp giới hạn một cách giả tạo mà thay vào đó hãy tăng nó lên
	(có thể là sau khi tăng bộ nhớ đã cài đặt),
	nếu điều kiện mạng yêu cầu nhiều hơn giá trị mặc định,
	và điều chỉnh các dịch vụ mạng để kéo dài và tiêu diệt các trạng thái đó
	quyết liệt hơn. Để tôi nhắc lại: từng đứa trẻ mồ côi ăn
	lên tới ~64K bộ nhớ không thể tráo đổi.

tcp_max_syn_backlog - INTEGER
	Số lượng yêu cầu kết nối được ghi nhớ tối đa (SYN_RECV),
	chưa nhận được xác nhận từ máy khách kết nối.

Đây là giới hạn cho mỗi người nghe.

Giá trị tối thiểu là 128 đối với máy có bộ nhớ thấp và nó sẽ
	tăng tỷ lệ thuận với bộ nhớ của máy.

Nếu máy chủ bị quá tải, hãy thử tăng con số này lên.

Hãy nhớ kiểm tra /proc/sys/net/core/somaxconn
	Ổ cắm yêu cầu SYN_RECV tiêu thụ khoảng 304 byte bộ nhớ.

tcp_max_tw_buckets - INTEGER
	Số lượng ổ cắm chờ thời gian tối đa được hệ thống giữ đồng thời.
	Nếu vượt quá số lượng này thì ổ cắm chờ sẽ bị hủy ngay lập tức
	và cảnh báo được in ra. Giới hạn này tồn tại chỉ để ngăn chặn
	các cuộc tấn công DoS đơn giản, bạn _không được_ hạ thấp giới hạn một cách giả tạo,
	mà là tăng nó lên (có thể là sau khi tăng bộ nhớ đã cài đặt),
	nếu điều kiện mạng yêu cầu nhiều hơn giá trị mặc định.

tcp_mem - vectơ 3 INTEGER: tối thiểu, áp suất, tối đa
	tối thiểu: dưới số trang này TCP không bận tâm về nó
	sự thèm ăn trí nhớ.

áp lực: khi lượng bộ nhớ được phân bổ bởi TCP vượt quá con số này
	của trang, TCP kiểm duyệt mức tiêu thụ bộ nhớ của nó và nhập vào bộ nhớ
	chế độ áp suất, được thoát khi mức tiêu thụ bộ nhớ giảm
	dưới "phút".

tối đa: số lượng trang được phép xếp hàng bởi tất cả các ổ cắm TCP.

Các giá trị mặc định được tính vào thời điểm khởi động từ số lượng có sẵn
	trí nhớ.

tcp_min_rtt_wlen - INTEGER
	Độ dài cửa sổ của bộ lọc tối thiểu cửa sổ để theo dõi RTT tối thiểu.
	Cửa sổ ngắn hơn cho phép luồng nhận thông tin mới nhanh hơn (cao hơn)
	RTT tối thiểu khi nó được di chuyển sang một đường dẫn dài hơn (ví dụ: do giao thông
	kỹ thuật). Cửa sổ dài hơn giúp bộ lọc có khả năng chống RTT cao hơn
	lạm phát như tắc nghẽn thoáng qua. Đơn vị là giây.

Các giá trị có thể có: 0 - 86400 (1 ngày)

Mặc định: 300

tcp_moderate_rcvbuf - BOOLEAN
	Nếu được bật, TCP sẽ thực hiện tự động điều chỉnh bộ đệm nhận, cố gắng
	tự động kích thước bộ đệm (không lớn hơn tcp_rmem[2]) thành
	phù hợp với kích thước mà đường dẫn yêu cầu để có thông lượng đầy đủ.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_rcvbuf_low_rtt - INTEGER
	Việc tự động dò RCvbuf có thể ước tính quá mức RCvbuf ổ cắm cuối cùng, điều này
	có thể dẫn đến việc xóa bộ nhớ đệm đối với các luồng thông lượng cao.

Đối với các luồng RTT nhỏ (dưới tcp_rcvbuf_low_rtt usecs), chúng ta có thể thư giãn
	tăng trưởng rcvbuf: Thêm vài mili giây để đạt đến kết quả cuối cùng (và nhỏ hơn)
	rcvbuf là một sự cân bằng tốt.

Mặc định: 1000 (1 mili giây)

tcp_mtu_probing - INTEGER
	Kiểm soát TCP Đường dẫn lớp gói gói MTU Discovery.  Mất ba
	giá trị:

- 0 - Bị vô hiệu hóa
	- 1 - Bị tắt theo mặc định, được bật khi phát hiện thấy lỗ đen ICMP
	- 2 - Luôn được bật, sử dụng MSS ban đầu của tcp_base_mss.

tcp_probe_interval - UNSIGNED INTEGER
	Kiểm soát tần suất khởi động TCP Đường dẫn lớp gói gói MTU
	Thăm dò khám phá. Mặc định là dò lại sau mỗi 10 phút vì
	theo RFC4821.

tcp_probe_threshold - INTEGER
	Kiểm soát khi thăm dò Đường dẫn lớp gói gói TCP MTU Discovery
	sẽ dừng lại đối với độ rộng của phạm vi tìm kiếm tính bằng byte. Mặc định
	là 8 byte.

tcp_no_metrics_save - BOOLEAN
	Theo mặc định, TCP lưu các số liệu kết nối khác nhau trong bộ đệm tuyến đường
	khi kết nối đóng lại, do đó các kết nối được thiết lập trong
	tương lai gần có thể sử dụng những điều này để thiết lập các điều kiện ban đầu.  Thông thường, điều này
	tăng hiệu suất tổng thể, nhưng đôi khi có thể gây ra hiệu suất
	sự xuống cấp.  Nếu được bật, TCP sẽ không lưu số liệu vào bộ đệm khi đóng
	kết nối.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_no_ssthresh_metrics_save - BOOLEAN
	Kiểm soát xem TCP có lưu số liệu ssthresh trong bộ đệm tuyến đường hay không.
	Nếu được bật, số liệu ssthresh sẽ bị tắt.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_orphan_retries - INTEGER
	Giá trị này ảnh hưởng đến thời gian chờ của kết nối TCP đóng cục bộ,
	khi việc truyền lại RTO vẫn không được xác nhận.
	Xem tcp_retries2 để biết thêm chi tiết.

Giá trị mặc định là 8.

Nếu máy của bạn là máy chủ WEB đã được tải,
	bạn nên nghĩ đến việc giảm giá trị này, những ổ cắm như vậy
	có thể tiêu thụ tài nguyên đáng kể. Cf. tcp_max_orphans.

tcp_recovery - INTEGER
	Giá trị này là một bitmap để cho phép phục hồi tổn thất thử nghiệm khác nhau
	tính năng.

============================================================================
	RACK: 0x1 cho phép phát hiện mất mát RACK, để phát hiện nhanh các mất mát
		    truyền lại và giảm đuôi, và khả năng phục hồi
		    sắp xếp lại. hiện tại, việc đặt bit này thành 0 không có
		    có hiệu lực, vì RACK là tính năng phát hiện mất mát được hỗ trợ duy nhất
		    thuật toán.

RACK: 0x2 làm cho cửa sổ sắp xếp lại của RACK ở trạng thái tĩnh (min_rtt/4).

RACK: 0x4 vô hiệu hóa heuristic ngưỡng DUPACK của RACK
	============================================================================

Mặc định: 0x1

tcp_reflect_tos - BOOLEAN
	Đối với ổ cắm nghe, hãy sử dụng lại giá trị DSCP của thông báo SYN ban đầu
	cho các gói gửi đi. Điều này cho phép có cả hai hướng của TCP
	luồng để sử dụng cùng một giá trị DSCP, giả sử DSCP không thay đổi trong
	tuổi thọ của kết nối.

Tùy chọn này ảnh hưởng đến cả IPv4 và IPv6.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_reordering - INTEGER
	Mức độ sắp xếp lại ban đầu của các gói trong luồng TCP.
	Sau đó, ngăn xếp TCP có thể tự động điều chỉnh mức độ sắp xếp lại luồng
	giữa giá trị ban đầu này và tcp_max_reordering

Mặc định: 3

tcp_max_reordering - INTEGER
	Mức sắp xếp lại tối đa các gói trong luồng TCP.
	300 là một giá trị khá thận trọng nhưng bạn có thể tăng nó lên
	nếu đường dẫn đang sử dụng cân bằng tải trên mỗi gói (như chế độ rr liên kết)

Mặc định: 300

tcp_retrans_collapse - BOOLEAN
	Khả năng tương thích giữa các lỗi với một số máy in bị hỏng.
	Khi truyền lại, hãy thử gửi các gói lớn hơn để khắc phục lỗi trong
	một số ngăn xếp TCP nhất định.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_retries1 - INTEGER
	Giá trị này ảnh hưởng đến thời gian, sau đó TCP quyết định rằng
	có gì đó không ổn do việc truyền lại RTO không được xác nhận,
	và báo cáo sự nghi ngờ này cho lớp mạng.
	Xem tcp_retries2 để biết thêm chi tiết.

RFC 1122 khuyến nghị ít nhất 3 lần truyền lại, đó là
	mặc định.

tcp_retries2 - INTEGER
	Giá trị này ảnh hưởng đến thời gian chờ của kết nối TCP còn hoạt động,
	khi việc truyền lại RTO vẫn không được xác nhận.
	Cho giá trị N, kết nối TCP giả định sau
	thời gian chờ theo cấp số nhân với RTO ban đầu là TCP_RTO_MIN sẽ
	truyền lại N lần trước khi ngắt kết nối ở RTO thứ (N+1).

Giá trị mặc định là 15 mang lại thời gian chờ giả định là 924,6
	giây và là giới hạn dưới cho thời gian chờ hiệu quả.
	TCP sẽ hết thời gian chờ ở RTO đầu tiên vượt quá thời gian
	thời gian chờ giả định.
	Nếu tcp_rto_max_ms bị giảm, bạn cũng nên
	thay đổi tcp_retries2.

RFC 1122 khuyến nghị thời gian chờ ít nhất là 100 giây,
	tương ứng với giá trị ít nhất là 8.

tcp_rfc1337 - BOOLEAN
	Nếu được bật, ngăn xếp TCP sẽ hoạt động tuân theo RFC1337. Nếu không đặt,
	chúng tôi không tuân thủ RFC nhưng ngăn chặn TCP TIME_WAIT
	vụ ám sát.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_rmem - vectơ 3 INTEGER: tối thiểu, mặc định, tối đa
	min: Kích thước tối thiểu của bộ đệm nhận được sử dụng bởi ổ cắm TCP.
	Nó được đảm bảo cho từng ổ cắm TCP, ngay cả với bộ nhớ vừa phải
	áp lực.

Mặc định: 4K

mặc định: kích thước ban đầu của bộ đệm nhận được sử dụng bởi ổ cắm TCP.
	Giá trị này ghi đè net.core.rmem_default được các giao thức khác sử dụng.
	Mặc định: 131072 byte.
	Giá trị này dẫn đến cửa sổ ban đầu là 65535.

max: kích thước tối đa của bộ đệm nhận được phép tự động
	bộ đệm máy thu được chọn cho ổ cắm TCP.
	Gọi setsockopt() khi tắt SO_RCVBUF
	tự động điều chỉnh kích thước bộ đệm nhận của ổ cắm đó, trong đó
	trường hợp giá trị này bị bỏ qua.
	Mặc định: trong khoảng từ 131072 đến 32 MB, tùy thuộc vào kích thước RAM.

tcp_sack - BOOLEAN
	Cho phép xác nhận chọn (SACKS).

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_comp_sack_rtt_percent - INTEGER
	Phần trăm SRTT được sử dụng cho tính năng SACK đã nén.
	Xem tcp_comp_sack_nr, tcp_comp_sack_delay_ns, tcp_comp_sack_slack_ns.

Giá trị có thể: 1 - 1000

Mặc định: 33 %

tcp_comp_sack_delay_ns - LONG INTEGER
	TCP cố gắng giảm số lượng SACK được gửi bằng cách sử dụng bộ hẹn giờ dựa trên
	trên tcp_comp_sack_rtt_percent của SRTT, được giới hạn bởi sysctl này
	trong nano giây.
	Giá trị mặc định là 1ms, dựa trên khoảng thời gian tự động định cỡ TSO.

Mặc định: 1.000.000 ns (1 ms)

tcp_comp_sack_slack_ns - LONG INTEGER
	Hệ thống này kiểm soát độ chùng được sử dụng khi trang bị vũ khí cho
	bộ đếm thời gian được sử dụng bởi nén SACK. Điều này mang lại thêm thời gian
	cho các luồng RTT nhỏ và giảm chi phí hệ thống bằng cách cho phép
	giảm thiểu cơ hội các ngắt hẹn giờ.
	Giá trị quá lớn có thể làm giảm sản lượng.

Mặc định: 10.000 ns (10 us)

tcp_comp_sack_nr - INTEGER
	Số SACK tối đa có thể được nén.
	Sử dụng 0 sẽ tắt tính năng nén SACK.

Mặc định: 44

tcp_backlog_ack_defer - BOOLEAN
	Nếu được bật, tồn đọng ổ cắm xử lý luồng của người dùng sẽ thử gửi
	một ACK cho toàn bộ hàng đợi. Điều này giúp tránh khả năng
	độ trễ dài ở cuối tòa nhà ổ cắm TCP.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_slow_start_after_idle - BOOLEAN
	Nếu được bật, hãy cung cấp hành vi RFC2861 và hết thời gian tắc nghẽn
	cửa sổ sau một thời gian nhàn rỗi.  Khoảng thời gian nhàn rỗi được xác định tại
	RTO hiện tại.  Nếu không được đặt, cửa sổ tắc nghẽn sẽ không
	bị hết thời gian chờ sau một thời gian nhàn rỗi.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_stdurg - BOOLEAN
	Sử dụng diễn giải các yêu cầu Máy chủ của trường con trỏ khẩn cấp TCP.
	Hầu hết các máy chủ đều sử dụng cách giải thích BSD cũ hơn, vì vậy nếu được bật,
	Linux có thể không giao tiếp chính xác với họ.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_synack_retries - INTEGER
	Số lần SYNACK cho lần thử kết nối TCP thụ động sẽ
	được truyền lại. Không được cao hơn 255. Giá trị mặc định
	là 5, tương ứng với 31 giây cho đến lần truyền lại cuối cùng
	với RTO ban đầu hiện tại là 1 giây. Với điều này, thời gian chờ cuối cùng
	đối với kết nối TCP thụ động sẽ diễn ra sau 63 giây.

tcp_syncookies - INTEGER
	Chỉ hợp lệ khi kernel được biên dịch bằng CONFIG_SYN_COOKIES
	Gửi cookie đồng bộ khi hàng đợi tồn đọng đồng bộ của ổ cắm
	tràn. Điều này nhằm ngăn chặn cuộc tấn công lũ lụt SYN phổ biến
	Mặc định: 1

Lưu ý rằng syncookies là cơ sở dự phòng.
	Nó MUST NOT được sử dụng để giúp các máy chủ có tải trọng cao đứng vững
	so với tỷ lệ kết nối hợp pháp. Nếu bạn thấy cảnh báo lũ SYN
	trong nhật ký của bạn, nhưng điều tra cho thấy chúng xảy ra
	vì quá tải với các kết nối pháp lý, bạn nên điều chỉnh
	tham số khác cho đến khi cảnh báo này biến mất.
	Xem: tcp_max_syn_backlog, tcp_synack_retries, tcp_abort_on_overflow.

syncookie vi phạm nghiêm trọng giao thức TCP, không cho phép
	sử dụng phần mở rộng TCP, có thể dẫn đến suy thoái nghiêm trọng
	của một số dịch vụ (ví dụ: chuyển tiếp SMTP), bạn không thể nhìn thấy,
	mà là khách hàng và người chuyển tiếp của bạn, đang liên hệ với bạn. Trong khi bạn nhìn thấy
	Cảnh báo lũ SYN trong nhật ký không thực sự bị ngập, máy chủ của bạn
	bị cấu hình sai nghiêm trọng.

Nếu bạn muốn kiểm tra xem cookie đồng bộ có tác dụng gì đối với
	kết nối mạng, bạn có thể đặt núm này thành 2 để bật
	tạo ra các syncookie vô điều kiện.

tcp_migrate_req - BOOLEAN
	Kết nối đến được gắn với một ổ cắm nghe cụ thể khi
	gói SYN ban đầu được nhận trong quá trình bắt tay ba chiều.
	Khi một trình nghe bị đóng, các ổ cắm yêu cầu đang hoạt động trong quá trình
	bắt tay và các ổ cắm được thiết lập trong hàng đợi chấp nhận bị hủy bỏ.

Nếu trình nghe đã bật SO_REUSEPORT, các trình nghe khác trên
	cùng một cổng có thể chấp nhận các kết nối như vậy. Cái này
	tùy chọn cho phép di chuyển các ổ cắm con đó sang ổ cắm khác
	người nghe sau khi đóng() hoặc tắt máy().

Loại chương trình eBPF BPF_SK_REUSEPORT_SELECT_OR_MIGRATE sẽ
	thường được sử dụng để xác định chính sách chọn người nghe còn sống.
	Ngược lại, kernel sẽ chọn ngẫu nhiên một người nghe còn sống nếu
	tùy chọn này được kích hoạt.

Lưu ý rằng việc di chuyển giữa các trình nghe với các cài đặt khác nhau có thể
	ứng dụng gặp sự cố. Giả sử việc di chuyển xảy ra từ người nghe A đến
	B và chỉ B mới kích hoạt TCP_SAVE_SYN. B không thể đọc dữ liệu SYN từ
	các yêu cầu được di chuyển từ A. Để tránh tình huống như vậy, hãy hủy
	di chuyển bằng cách trả về SK_DROP dưới dạng chương trình eBPF hoặc
	vô hiệu hóa tùy chọn này.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_fastopen - INTEGER
	Kích hoạt TCP Fast Open (RFC7413) để gửi và chấp nhận dữ liệu khi mở
	Gói SYN.

Hỗ trợ khách hàng được bật theo cờ 0x1 (bật theo mặc định). khách hàng
	thì phải sử dụng sendmsg() hoặc sendto() với cờ MSG_FASTOPEN,
	thay vì connect() để gửi dữ liệu trong SYN.

Hỗ trợ máy chủ được bật theo cờ 0x2 (tắt theo mặc định). Sau đó
	bật cho tất cả người nghe bằng cờ khác (0x400) hoặc
	cho phép từng người nghe thông qua tùy chọn ổ cắm TCP_FASTOPEN với
	giá trị tùy chọn là độ dài của tồn đọng dữ liệu đồng bộ.

Các giá trị (bitmap) là

===== ======== ===========================================================
	  0x1 (máy khách) cho phép gửi dữ liệu trong SYN đang mở trên máy khách.
	  0x2 (máy chủ) cho phép hỗ trợ máy chủ, tức là cho phép dữ liệu trong
			một gói SYN được chấp nhận và chuyển đến
			ứng dụng trước khi quá trình bắt tay 3 bước kết thúc.
	  0x4 (máy khách) gửi dữ liệu trong SYN đang mở bất kể cookie
			tính khả dụng và không có tùy chọn cookie.
	0x200 (máy chủ) chấp nhận dữ liệu trong SYN mà không có bất kỳ tùy chọn cookie nào.
	0x400 (máy chủ) cho phép tất cả người nghe hỗ trợ Mở nhanh bằng cách
			mặc định không có tùy chọn ổ cắm TCP_FASTOPEN rõ ràng.
	===== ======== ===========================================================

Mặc định: 0x1

Lưu ý rằng các tính năng máy khách hoặc máy chủ bổ sung chỉ
	có hiệu lực nếu hỗ trợ cơ bản (0x1 và 0x2) được bật tương ứng.

tcp_fastopen_blackhole_timeout_sec - INTEGER
	Khoảng thời gian ban đầu tính bằng giây để tắt Fastopen trên ổ cắm TCP đang hoạt động
	khi xảy ra sự cố lỗ đen tường lửa TFO.
	Khoảng thời gian này sẽ tăng theo cấp số nhân khi có nhiều vấn đề về lỗ đen hơn
	được phát hiện ngay sau khi Fastopen được kích hoạt lại và sẽ đặt lại về
	giá trị ban đầu khi vấn đề lỗ đen biến mất.
	0 để tắt tính năng phát hiện lỗ đen.

Theo mặc định, nó được đặt thành 0 (tính năng bị tắt).

tcp_fastopen_key - danh sách các INTEGER thập lục phân 32 chữ số được phân tách bằng dấu phẩy
	Danh sách bao gồm khóa chính và khóa dự phòng tùy chọn. các
	khóa chính được sử dụng cho cả việc tạo và xác thực cookie, trong khi
	khóa dự phòng tùy chọn chỉ được sử dụng để xác thực cookie. Mục đích của
	khóa dự phòng nhằm tối đa hóa xác thực TFO khi xoay phím.

Khóa chính được chọn ngẫu nhiên có thể được cấu hình bởi kernel nếu
	sysctl tcp_fastopen được đặt thành 0x400 (xem ở trên) hoặc nếu
	Tên tùy chọn TCP_FASTOPEN setsockopt() đã được đặt và khóa chưa được đặt
	được cấu hình trước đó thông qua sysctl. Nếu các phím được cấu hình thông qua
	setsockopt() bằng cách sử dụng tên lựa chọn TCP_FASTOPEN_KEY, sau đó
	các khóa trên mỗi ổ cắm sẽ được sử dụng thay vì bất kỳ khóa nào được chỉ định thông qua
	sysctl.

Một khóa được chỉ định là 4 số nguyên thập lục phân 8 chữ số được phân tách
	bởi một '-' như: xxxxxxxx-xxxxxxx-xxxxxxxx-xxxxxxxx. Số 0 đứng đầu có thể là
	bỏ qua. Khóa chính và khóa dự phòng có thể được chỉ định bằng cách tách chúng ra
	bằng dấu phẩy. Nếu chỉ có một khóa được chỉ định, nó sẽ trở thành khóa chính và
	mọi khóa dự phòng được định cấu hình trước đó sẽ bị xóa.

tcp_syn_retries - INTEGER
	Số lần SYN ban đầu cho lần thử kết nối TCP đang hoạt động
	sẽ được truyền lại. Không được cao hơn 127. Giá trị mặc định
	là 6, tương ứng với 67 giây (với tcp_syn_Tuyến_timeouts = 4)
	cho đến lần truyền lại cuối cùng với RTO ban đầu hiện tại là 1 giây.
	Đây là thời gian chờ cuối cùng cho nỗ lực kết nối TCP đang hoạt động
	sẽ xảy ra sau 131 giây.

tcp_timestamps - INTEGER
	Bật dấu thời gian như được xác định trong RFC1323.

- 0: Vô hiệu hóa.
	- 1: Kích hoạt dấu thời gian như được xác định trong RFC1323 và sử dụng độ lệch ngẫu nhiên cho
	  mỗi kết nối thay vì chỉ sử dụng thời gian hiện tại.
	- 2: Giống 1, nhưng không có độ lệch ngẫu nhiên.

Mặc định: 1

tcp_min_tso_segs - INTEGER
	Số lượng phân đoạn tối thiểu trên mỗi khung TSO.

Kể từ linux-3.12, TCP thực hiện tự động định cỡ khung TSO,
	tùy thuộc vào tốc độ luồng, thay vì lấp đầy các gói 64Kbyte.
	Đối với các mục đích sử dụng cụ thể, có thể buộc TCP xây dựng lớn
	Khung TSO. Lưu ý rằng ngăn xếp TCP có thể chia các gói TSO quá lớn
	nếu cửa sổ có sẵn quá nhỏ.

Mặc định: 2

tcp_tso_rtt_log - INTEGER
	Điều chỉnh kích thước gói TSO dựa trên min_rtt

Bắt đầu từ linux-5.18, việc tự động hóa TCP có thể được điều chỉnh
	đối với các luồng có RTT nhỏ.

Tính năng tự động hóa cũ đã chia ngân sách tốc độ để gửi 1024 TSO
	mỗi giây.

tso_packet_size = sk->sk_pacing_rate / 1024;

Với cơ chế mới, chúng tôi tăng kích thước TSO này bằng cách sử dụng:

khoảng cách = min_rtt_usec / (2^tcp_tso_rtt_log)
	tso_packet_size += gso_max_size >> khoảng cách;

Điều này có nghĩa là các luồng giữa các máy chủ rất gần nhau có thể sử dụng lớn hơn
	Gói TSO, giảm chi phí CPU.

Nếu bạn muốn sử dụng tính năng tự động định cỡ cũ, hãy đặt sysctl này thành 0.

Mặc định: 9 (2^9 = 512 usec)

tcp_pacing_ss_ratio - INTEGER
	sk->sk_pacing_rate được thiết lập bởi ngăn xếp TCP sử dụng tỷ lệ được áp dụng
	đến tỷ giá hiện tại. (current_rate = cwnd * mss / srtt)
	Nếu TCP khởi động chậm, tcp_pacing_ss_ratio sẽ được áp dụng
	để cho phép TCP thăm dò tốc độ lớn hơn, giả sử cwnd có thể
	nhân đôi mỗi RTT khác.

Mặc định: 200

tcp_pacing_ca_ratio - INTEGER
	sk->sk_pacing_rate được thiết lập bởi ngăn xếp TCP sử dụng tỷ lệ được áp dụng
	đến tỷ giá hiện tại. (current_rate = cwnd * mss / srtt)
	Nếu TCP đang trong giai đoạn tránh tắc nghẽn, tcp_pacing_ca_ratio
	được áp dụng để thăm dò thận trọng để có thông lượng lớn hơn.

Mặc định: 120

tcp_syn_Tuyến_timeouts - INTEGER
	Số lần kết nối TCP đang hoạt động truyền lại SYN với
	thời gian chờ chờ tuyến tính trước khi mặc định là thời gian chờ theo cấp số nhân
	hết thời gian chờ. Điều này không ảnh hưởng đến SYNACK ở phía TCP thụ động.

Với RTO ban đầu là 1 và tcp_syn_Tuyến_timeouts = 4, chúng tôi sẽ
	dự kiến RTO SYN là: 1, 1, 1, 1, 1, 2, 4, ... (4 thời gian chờ tuyến tính,
	và độ lùi lũy thừa đầu tiên sử dụng 2^0 * init_RTO).
	Mặc định: 4

tcp_tso_win_divisor - INTEGER
	Điều này cho phép kiểm soát bao nhiêu phần trăm của cửa sổ tắc nghẽn
	có thể được sử dụng bởi một khung TSO duy nhất.
	Việc cài đặt tham số này là sự lựa chọn giữa mức độ bùng nổ và
	xây dựng các khung TSO lớn hơn.

Mặc định: 3

tcp_tw_reuse - INTEGER
	Cho phép tái sử dụng ổ cắm TIME-WAIT cho các kết nối mới khi có
	an toàn từ quan điểm giao thức.

- 0 - vô hiệu hóa
	- 1 - kích hoạt toàn cầu
	- 2 - chỉ kích hoạt lưu lượng truy cập vòng lặp

Không nên thay đổi nếu không có lời khuyên/yêu cầu của bộ phận kỹ thuật
	các chuyên gia.

Mặc định: 2

tcp_tw_reuse_delay - UNSIGNED INTEGER
        Độ trễ tính bằng mili giây trước khi ổ cắm TIME-WAIT có thể được sử dụng lại bởi
        kết nối mới, nếu việc tái sử dụng ổ cắm TIME-WAIT được bật. Tái sử dụng thực tế
        ngưỡng nằm trong phạm vi [N, N+1], trong đó N là độ trễ được yêu cầu trong
        mili giây, để đảm bảo khoảng thời gian trễ không bao giờ ngắn hơn thời gian trễ
        giá trị được cấu hình.

Cài đặt này chứa giả định về đồng hồ dấu thời gian TCP khác
        khoảng đánh dấu. Nó không nên được đặt thành giá trị thấp hơn giá trị ngang hàng
        tiếng tích tắc đồng hồ cho PAWS (Bảo vệ chống lại các số thứ tự được gói)
        cơ chế hoạt động chính xác cho kết nối được sử dụng lại.

Mặc định: 1000 (mili giây)

tcp_window_scaling - BOOLEAN
	Kích hoạt tính năng chia tỷ lệ cửa sổ như được xác định trong RFC1323.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

tcp_shrink_window - BOOLEAN
	Điều này thay đổi cách tính cửa sổ nhận TCP.

RFC 7323, phần 2.4, cho biết có những trường hợp khi rút lại
	cửa sổ có thể được cung cấp và việc triển khai TCP MUST đảm bảo
	rằng họ xử lý cửa sổ thu nhỏ, như được chỉ định trong RFC 1122.

Các giá trị có thể:

- 0 (tắt) - Cửa sổ không bao giờ bị thu nhỏ.
	- 1 (đã bật) - Cửa sổ được thu nhỏ khi cần thiết vẫn ở trong
	  giới hạn bộ nhớ được đặt bằng cách tự động điều chỉnh (sk_rcvbuf).
	  Điều này chỉ xảy ra nếu cửa sổ nhận khác 0
	  hệ số tỷ lệ cũng có hiệu lực.

Mặc định: 0 (đã tắt)

tcp_wmem - vectơ 3 INTEGER: tối thiểu, mặc định, tối đa
	tối thiểu: Dung lượng bộ nhớ dành riêng cho bộ đệm gửi cho ổ cắm TCP.
	Mỗi ổ cắm TCP đều có quyền sử dụng nó do thực tế ra đời của nó.

Mặc định: 4K

mặc định: kích thước ban đầu của bộ đệm gửi được sử dụng bởi ổ cắm TCP.  Cái này
	giá trị ghi đè net.core.wmem_default được các giao thức khác sử dụng.

Nó thường thấp hơn net.core.wmem_default.

Mặc định: 16K

max: Dung lượng bộ nhớ tối đa được phép để điều chỉnh tự động
	gửi bộ đệm cho ổ cắm TCP. Giá trị này không ghi đè
	net.core.wmem_max.  Gọi setsockopt() khi tắt SO_SNDBUF
	tự động điều chỉnh kích thước bộ đệm gửi của ổ cắm đó, trong trường hợp đó
	giá trị này bị bỏ qua.

Mặc định: từ 64K đến 4MB, tùy thuộc vào kích thước RAM.

tcp_notsent_lowat - UNSIGNED INTEGER
	Ổ cắm TCP có thể kiểm soát số lượng byte chưa gửi trong hàng đợi ghi của nó,
	nhờ tùy chọn ổ cắm TCP_NOTSENT_LOWAT. thăm dò ý kiến()/select()/epoll()
	báo cáo các sự kiện POLLOUT nếu số lượng byte chưa gửi thấp hơn một
	giá trị socket và nếu hàng đợi ghi không đầy. sendmsg() sẽ
	cũng không thêm bộ đệm mới nếu đạt đến giới hạn.

Biến toàn cục này kiểm soát lượng dữ liệu chưa gửi cho
	ổ cắm không sử dụng TCP_NOTSENT_LOWAT. Đối với những ổ cắm này, một sự thay đổi
	vào biến toàn cục có hiệu lực ngay lập tức.

Mặc định: UINT_MAX (0xFFFFFFFF)

tcp_workaround_signed_windows - BOOLEAN
	Nếu được bật, giả sử không nhận được tùy chọn chia tỷ lệ cửa sổ có nghĩa là
	điều khiển từ xa TCP bị hỏng và coi cửa sổ là số lượng đã ký.
	Nếu bị tắt, giả sử TCP từ xa không bị hỏng ngay cả khi chúng tôi làm như vậy
	không nhận được tùy chọn mở rộng cửa sổ từ họ.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_thin_line_timeouts - BOOLEAN
	Bật kích hoạt động thời gian chờ tuyến tính cho các luồng mỏng.
	Nếu được bật, việc kiểm tra sẽ được thực hiện khi truyền lại trước thời gian chờ tới
	xác định xem luồng có mỏng hay không (ít hơn 4 gói trong chuyến bay).
	Miễn là luồng được phát hiện là mỏng, lên tới 6 tuyến tính
	thời gian chờ có thể được thực hiện trước khi chế độ chờ theo cấp số nhân được kích hoạt.
	khởi xướng. Điều này cải thiện độ trễ truyền lại cho
	các dòng mỏng không xâm lấn, thường phụ thuộc vào thời gian.
	Để biết thêm thông tin về dòng mỏng, xem
	Tài liệu/mạng/tcp-thin.rst

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_limit_output_bytes - INTEGER
	Kiểm soát giới hạn hàng đợi nhỏ TCP trên mỗi ổ cắm tcp.
	Người gửi số lượng lớn TCP có xu hướng tăng các gói trong chuyến bay cho đến khi
	nhận được thông báo tổn thất. Với tính năng tự dò SNDBUF, điều này có thể
	dẫn đến một lượng lớn gói được xếp hàng đợi trên máy cục bộ
	(ví dụ: qdiscs, CPU tồn đọng hoặc thiết bị) làm ảnh hưởng đến độ trễ của thiết bị khác
	luồng, dành cho qdiscs pfifo_fast điển hình.  tcp_limit_output_bytes
	giới hạn số byte trên qdisc hoặc thiết bị để giảm bớt sự giả tạo
	RTT/cwnd và giảm tình trạng phồng bộ đệm.

Mặc định: 4194304 (4 MB)

tcp_challenge_ack_limit - INTEGER
	Giới hạn số lượng Thử thách ACK được gửi mỗi giây, theo khuyến nghị
	trong RFC 5961 (Cải thiện tính mạnh mẽ của TCP trước các cuộc tấn công mù trong cửa sổ)
	Lưu ý rằng giới hạn tốc độ trên mỗi mạng này có thể cho phép một số kênh bên
	các cuộc tấn công và có lẽ không nên được kích hoạt.
	Dù sao thì ngăn xếp TCP vẫn thực hiện theo giới hạn ổ cắm TCP.
	Mặc định: INT_MAX (không giới hạn)

tcp_ehash_entries - INTEGER
	Hiển thị số lượng nhóm băm cho ổ cắm TCP hiện tại
	không gian tên mạng.

Giá trị âm có nghĩa là không gian tên mạng không sở hữu nó
	nhóm băm và chia sẻ không gian tên của mạng ban đầu.

tcp_child_ehash_entries - INTEGER
	Kiểm soát số lượng nhóm băm cho ổ cắm TCP ở trẻ em
	không gian tên mạng, phải được đặt trước clone() hoặc unshare().

Nếu giá trị khác 0, kernel sử dụng giá trị được làm tròn lên 2^n
	bằng kích thước nhóm băm thực tế.  0 là một giá trị đặc biệt, nghĩa là
	không gian tên mạng con sẽ chia sẻ mạng ban đầu
	nhóm băm của không gian tên.

Lưu ý rằng trẻ sẽ sử dụng cái toàn cục trong trường hợp kernel
	không phân bổ đủ bộ nhớ.  Ngoài ra, hàm băm toàn cầu
	các nhóm được trải rộng trên các nút NUMA có sẵn, nhưng việc phân bổ
	của bảng băm con phụ thuộc vào NUMA của quy trình hiện tại
	chính sách, điều này có thể dẫn đến sự khác biệt về hiệu suất.

Cũng lưu ý rằng giá trị mặc định của tcp_max_tw_buckets và
	tcp_max_syn_backlog phụ thuộc vào kích thước nhóm băm.

Các giá trị có thể có: 0, 2^n (n: 0 - 24 (16Mi))

Mặc định: 0

tcp_plb_enabled - BOOLEAN
	Nếu được bật và kiểm soát tắc nghẽn cơ bản (ví dụ DCTCP) sẽ hỗ trợ
	và kích hoạt tính năng PLB, TCP PLB (Cân bằng tải bảo vệ) là
	đã bật. PLB được mô tả trong bài viết sau:
	ZZ0000ZZ Dựa trên các thông số PLB,
	khi cảm nhận được tình trạng tắc nghẽn kéo dài, TCP sẽ kích hoạt một sự thay đổi trong
	trường nhãn luồng cho các gói IPv6 gửi đi. Thay đổi nhãn luồng
	trường có khả năng thay đổi đường dẫn của các gói gửi đi cho các thiết bị chuyển mạch
	sử dụng ECMP/WCMP để định tuyến.

PLB thay đổi txhash ổ cắm dẫn đến thay đổi Nhãn luồng IPv6
	trường và hiện không hoạt động đối với các tiêu đề IPv4. Có thể
	để áp dụng PLB cho IPv4 với các trường tiêu đề mạng khác (ví dụ: TCP
	hoặc tùy chọn IPv4) hoặc sử dụng tính năng đóng gói khi sử dụng tiêu đề bên ngoài
	bằng các switch để xác định bước nhảy tiếp theo. Trong cả hai trường hợp, máy chủ tiếp theo
	và sẽ cần phải thay đổi bên chuyển đổi.

Nếu được bật, PLB giả định rằng tín hiệu tắc nghẽn (ví dụ ECN) được tạo
	có sẵn và được sử dụng bởi mô-đun điều khiển tắc nghẽn để ước tính
	thước đo tắc nghẽn (ví dụ: ce_ratio). PLB cần một biện pháp chống tắc nghẽn để
	đưa ra quyết định sửa lỗi.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

tcp_plb_idle_rehash_rounds - INTEGER
	Số vòng tắc nghẽn liên tiếp (RTT) được nhìn thấy sau đó
	việc thử lại có thể được thực hiện nếu không có gói nào trong chuyến bay.
	Điều này được gọi là M trong bài báo PLB:
	ZZ0000ZZ

Giá trị có thể: 0 - 31

Mặc định: 3

tcp_plb_rehash_rounds - INTEGER
	Số vòng tắc nghẽn liên tiếp (RTT) được nhìn thấy sau đó
	việc thử lại bắt buộc có thể được thực hiện. Hãy cẩn thận khi thiết lập điều này
	tham số, vì một giá trị nhỏ sẽ làm tăng nguy cơ truyền lại.
	Điều này được gọi là N trong bài báo PLB:
	ZZ0000ZZ

Giá trị có thể: 0 - 31

Mặc định: 12

tcp_plb_suspend_rto_sec - INTEGER
	Thời gian, tính bằng giây, để tạm dừng PLB trong trường hợp xảy ra RTO. Để tránh
	có đường dẫn lại PLB vào một "lỗ đen" kết nối, sau RTO và TCP
	kết nối tạm dừng việc truyền lại PLB trong khoảng thời gian ngẫu nhiên từ 1x đến
	2x của tham số này. Tính ngẫu nhiên được thêm vào để tránh việc luyện tập lại đồng thời
	của nhiều kết nối TCP. Điều này nên được đặt tương ứng với
	lượng thời gian cần thiết để sửa chữa một liên kết bị lỗi.

Giá trị có thể: 0 - 255

Mặc định: 60

tcp_plb_cong_thresh - INTEGER
	Tỷ lệ các gói được đánh dấu tắc nghẽn trong một vòng (RTT) đến
	gắn thẻ vòng đó là tắc nghẽn. Điều này được gọi là K trong bài báo PLB:
	ZZ0000ZZ

Phạm vi phân số 0-1 được ánh xạ tới phạm vi 0-256 để tránh nổi
	các thao tác điểm. Ví dụ: 128 có nghĩa là nếu ít nhất 50%
	các gói trong một vòng được đánh dấu là tắc nghẽn thì vòng đó
	sẽ được gắn thẻ là tắc nghẽn.

Đặt ngưỡng thành 0 có nghĩa là PLB sẽ truy cập lại mọi RTT bất kể
	của tắc nghẽn. Đây không phải là hành vi có chủ ý đối với PLB và nên được thực hiện
	chỉ được sử dụng cho mục đích thử nghiệm.

Giá trị có thể: 0 - 256

Mặc định: 128

tcp_pingpong_thresh - INTEGER
	Số lượng dữ liệu trả lời ước tính được gửi cho dữ liệu đến ước tính
	các yêu cầu phải xảy ra trước khi TCP coi rằng kết nối là một
	Kết nối "ping-pong" (yêu cầu-phản hồi) bị trì hoãn
	sự thừa nhận có thể mang lại lợi ích.

Ngưỡng này theo mặc định là 1, nhưng một số ứng dụng có thể cần ngưỡng cao hơn
	ngưỡng cho hiệu suất tối ưu.

Giá trị có thể: 1 - 255

Mặc định: 1

tcp_rto_min_us - INTEGER
	Thời gian chờ truyền lại TCP tối thiểu (tính bằng micro giây). Lưu ý rằng
	Tùy chọn tuyến đường rto_min có mức độ ưu tiên cao nhất để định cấu hình tùy chọn này
	cài đặt, tiếp theo là ổ cắm TCP_BPF_RTO_MIN và TCP_RTO_MIN_US
	tùy chọn, theo sau là tcp_rto_min_us sysctl.

Cách thực hành được khuyến nghị là sử dụng giá trị nhỏ hơn hoặc bằng 200000
	micro giây.

Các giá trị có thể có: 1 - INT_MAX

Mặc định: 200000

tcp_rto_max_ms - INTEGER
	Thời gian chờ truyền lại TCP tối đa (tính bằng ms).
	Lưu ý rằng tùy chọn ổ cắm TCP_RTO_MAX_MS có mức độ ưu tiên cao hơn.

Khi thay đổi tcp_rto_max_ms, điều quan trọng là phải hiểu
	tcp_retries2 có thể cần thay đổi.

Giá trị có thể: 1000 - 120.000

Mặc định: 120.000

Biến UDP
=============

udp_l3mdev_accept - BOOLEAN
	Việc bật tùy chọn này cho phép ổ cắm được liên kết "toàn cầu" hoạt động
	trên các miền chính L3 (ví dụ: VRF) với các gói có khả năng
	được nhận bất kể miền L3 mà chúng chứa trong đó
	bắt nguồn. Chỉ hợp lệ khi kernel được biên dịch bằng
	CONFIG_NET_L3_MASTER_DEV.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

udp_mem - vectơ 3 INTEGER: tối thiểu, áp suất, tối đa
	Số lượng trang được phép xếp hàng bởi tất cả các ổ cắm UDP.

tối thiểu: Số lượng trang được phép xếp hàng bởi tất cả các ổ cắm UDP.

áp lực: Giá trị này được giới thiệu theo định dạng của tcp_mem.

max: Giá trị này được giới thiệu theo định dạng của tcp_mem.

Mặc định được tính khi khởi động từ dung lượng bộ nhớ khả dụng.

udp_rmem_min - INTEGER
	Kích thước tối thiểu của bộ đệm nhận được ổ cắm UDP sử dụng ở mức độ vừa phải.
	Mỗi ổ cắm UDP có thể sử dụng kích thước để nhận dữ liệu, ngay cả khi
	tổng số trang của ổ cắm UDP vượt quá áp suất udp_mem. Đơn vị là byte.

Mặc định: 4K

udp_wmem_min - INTEGER
	UDP không có tính năng tính toán bộ nhớ tx và khả năng điều chỉnh này không có tác dụng.

udp_hash_entries - INTEGER
	Hiển thị số lượng nhóm băm cho ổ cắm UDP hiện tại
	không gian tên mạng.

Giá trị âm có nghĩa là không gian tên mạng không sở hữu nó
	nhóm băm và chia sẻ không gian tên của mạng ban đầu.

udp_child_hash_entries - INTEGER
	Kiểm soát số lượng nhóm băm cho ổ cắm UDP ở trẻ em
	không gian tên mạng, phải được đặt trước clone() hoặc unshare().

Nếu giá trị khác 0, kernel sử dụng giá trị được làm tròn lên 2^n
	bằng kích thước nhóm băm thực tế.  0 là một giá trị đặc biệt, nghĩa là
	không gian tên mạng con sẽ chia sẻ mạng ban đầu
	nhóm băm của không gian tên.

Lưu ý rằng trẻ sẽ sử dụng cái toàn cục trong trường hợp kernel
	không phân bổ đủ bộ nhớ.  Ngoài ra, hàm băm toàn cầu
	các nhóm được trải rộng trên các nút NUMA có sẵn, nhưng việc phân bổ
	của bảng băm con phụ thuộc vào NUMA của quy trình hiện tại
	chính sách, điều này có thể dẫn đến sự khác biệt về hiệu suất.

Các giá trị có thể có: 0, 2^n (n: 7 (128) - 16 (64K))

Mặc định: 0


Biến RAW
=============

raw_l3mdev_accept - BOOLEAN
	Việc bật tùy chọn này cho phép ổ cắm được liên kết "toàn cầu" hoạt động
	trên các miền chính L3 (ví dụ: VRF) với các gói có khả năng
	được nhận bất kể miền L3 mà chúng chứa trong đó
	bắt nguồn. Chỉ hợp lệ khi kernel được biên dịch bằng
	CONFIG_NET_L3_MASTER_DEV.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

Biến CIPSOv4
=================

cipso_cache_enable - BOOLEAN
	Nếu được bật, hãy bật tính năng bổ sung và tra cứu từ ánh xạ nhãn CIPSO
	bộ đệm.  Nếu bị tắt, các phần bổ sung sẽ bị bỏ qua và việc tra cứu luôn dẫn đến kết quả
	thưa cô.  Tuy nhiên, bất kể cài đặt nào, bộ nhớ đệm vẫn
	vô hiệu khi được yêu cầu khi có nghĩa là bạn có thể bật tính năng này một cách an toàn và
	tắt và bộ đệm sẽ luôn "an toàn".

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

cipso_cache_bucket_size - INTEGER
	Bộ đệm nhãn CIPSO bao gồm một bảng băm có kích thước cố định với mỗi bảng
	nhóm băm chứa một số mục trong bộ đệm.  Biến này giới hạn
	số lượng mục trong mỗi nhóm băm; giá trị càng lớn thì
	nhiều ánh xạ nhãn CIPSO hơn có thể được lưu vào bộ nhớ đệm.  Khi số lượng
	các mục trong một nhóm băm nhất định đạt đến giới hạn này khi thêm các mục mới
	khiến mục nhập cũ nhất trong nhóm bị loại bỏ để nhường chỗ.

Mặc định: 10

cipso_rbm_optfmt - BOOLEAN
	Bật "Định dạng thẻ 1 được tối ưu hóa" như được xác định trong phần 3.4.2.6 của
	đặc tả dự thảo CIPSO (xem Tài liệu/nhãn mạng để biết chi tiết).
	Điều này có nghĩa là khi đặt thẻ CIPSO sẽ được đệm bằng khoảng trống
	các danh mục để làm cho dữ liệu gói được căn chỉnh 32 bit.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

cipso_rbm_strictvalid - BOOLEAN
	Nếu được bật, hãy kiểm tra thật kỹ tùy chọn CIPSO khi
	ip_options_compile() được gọi.  Nếu bị vô hiệu hóa, hãy thư giãn các bước kiểm tra được thực hiện trong quá trình
	ip_options_compile().  Cách nào cũng "an toàn" vì sẽ phát hiện được lỗi khác
	trong mã xử lý CIPSO nhưng việc đặt giá trị này thành 0 (Sai) sẽ
	dẫn đến công việc ít hơn (tức là phải nhanh hơn) nhưng có thể gây ra sự cố
	với các triển khai khác yêu cầu kiểm tra nghiêm ngặt.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

Biến IP
============

ip_local_port_range - 2 INTEGERS
	Xác định phạm vi cổng cục bộ được TCP và UDP sử dụng để
	chọn cổng địa phương. Số đầu tiên là số đầu tiên
	thứ hai là số cổng cục bộ cuối cùng.
	Nếu có thể thì tốt hơn là những con số này có tính chẵn lẻ khác nhau
	(một giá trị chẵn và một giá trị lẻ).
	Phải lớn hơn hoặc bằng ip_unprivileged_port_start.
	Giá trị mặc định lần lượt là 32768 và 60999.

ip_local_reserved_ports - danh sách các phạm vi được phân tách bằng dấu phẩy
	Chỉ định các cổng được dành riêng cho bên thứ ba đã biết
	ứng dụng. Các cổng này sẽ không được sử dụng bởi cổng tự động
	các bài tập (ví dụ: khi gọi connect() hoặc bind() bằng cổng
	số 0). Hành vi phân bổ cổng rõ ràng không thay đổi.

Định dạng được sử dụng cho cả đầu vào và đầu ra được phân tách bằng dấu phẩy
	danh sách các phạm vi (ví dụ: "1,2-4,10-10" cho các cổng 1, 2, 3, 4 và
	10). Việc ghi vào tập tin sẽ xóa tất cả các dữ liệu đã đặt trước đó
	cổng và cập nhật danh sách hiện tại với danh sách được đưa ra trong
	đầu vào.

Lưu ý rằng ip_local_port_range và ip_local_reserved_ports
	cài đặt độc lập và cả hai đều được kernel xem xét
	khi xác định cổng nào có sẵn cho cổng tự động
	bài tập.

Bạn có thể dự trữ các cổng không có trong hiện tại
	ip_local_port_range, ví dụ::

$ cat /proc/sys/net/ipv4/ip_local_port_range
	    32000 60999
	    $ cat /proc/sys/net/ipv4/ip_local_reserved_ports
	    8080,9148

mặc dù điều này là dư thừa. Tuy nhiên, cài đặt như vậy rất hữu ích
	nếu sau này phạm vi cổng được thay đổi thành một giá trị sẽ
	bao gồm các cổng dành riêng. Cũng nên nhớ rằng, sự chồng chéo
	của các phạm vi này có thể ảnh hưởng đến xác suất chọn phù du
	cổng ngay sau khối cổng dành riêng.

Mặc định: Trống

ip_local_port_step_width - INTEGER
        Xác định mức tăng tối đa bằng số giữa các cổng liên tiếp
        phân bổ trong phạm vi cổng tạm thời khi có cổng không khả dụng
        đạt tới. Điều này có thể được sử dụng để giảm thiểu các nút tích lũy trong cổng
        phân phối khi các cổng dành riêng đã được cấu hình. Xin lưu ý rằng
        va chạm cổng có thể xảy ra thường xuyên hơn trong một hệ thống có tải rất cao.

Nên đặt giá trị này lớn hơn giá trị lớn nhất
        khối cổng liền kề được định cấu hình trong ip_local_reserved_ports. cho
        phạm vi cổng dành riêng lớn, đặt kích thước này lên gấp 3 hoặc 4 lần kích thước của
        khối lớn nhất được khuyên. Sử dụng giá trị bằng hoặc lớn hơn giá trị cục bộ
        kích thước phạm vi cổng giải quyết hoàn toàn vấn đề phân phối cổng không đồng đều,
        nhưng nó có thể làm giảm hiệu suất trong các tình huống cạn kiệt cổng.

Mặc định: 0 (đã tắt)

ip_unprivileged_port_start - INTEGER
	Đây là một sysctl theo không gian tên.  Nó xác định điều đầu tiên
	cổng không có đặc quyền trong không gian tên mạng.  Cổng đặc quyền
	yêu cầu root hoặc CAP_NET_BIND_SERVICE để liên kết với chúng.
	Để tắt tất cả các cổng đặc quyền, hãy đặt giá trị này thành 0. Chúng không được phép
	trùng lặp với ip_local_port_range.

Mặc định: 1024

ip_nonlocal_bind - BOOLEAN
	Nếu được bật, cho phép các tiến trình liên kết() với các địa chỉ IP không cục bộ,
	điều này có thể khá hữu ích - nhưng có thể làm hỏng một số ứng dụng.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

ip_autobind_reuse - BOOLEAN
	Theo mặc định, bind() không tự động chọn các cổng ngay cả khi
	ổ cắm mới và tất cả các ổ cắm được liên kết với cổng đều có SO_REUSEADDR.
	ip_autobind_reuse cho phép bind() sử dụng lại cổng và điều này rất hữu ích
	khi bạn sử dụng bind()+connect() nhưng có thể làm hỏng một số ứng dụng.
	Giải pháp ưu tiên là sử dụng IP_BIND_ADDRESS_NO_PORT và giải pháp này
	tùy chọn chỉ nên được thiết lập bởi các chuyên gia.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

ip_dynaddr - INTEGER
	Nếu được đặt khác 0, hãy bật hỗ trợ cho địa chỉ động.
	Nếu được đặt thành giá trị khác 0 lớn hơn 1, nhật ký kernel
	thông báo sẽ được in khi viết lại địa chỉ động
	xảy ra.

Mặc định: 0

ip_early_demux - BOOLEAN
	Tối ưu hóa việc xử lý gói đầu vào xuống còn một demux cho
	một số loại ổ cắm cục bộ.  Hiện tại chúng tôi chỉ làm điều này
	dành cho ổ cắm TCP đã được thiết lập và ổ cắm UDP được kết nối.

Nó có thể tăng thêm chi phí cho khối lượng công việc định tuyến thuần túy
	làm giảm thông lượng tổng thể, trong trường hợp đó bạn nên tắt nó.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

ping_group_range - 2 INTEGERS
	Hạn chế ổ cắm datagram ICMP_PROTO cho người dùng trong phạm vi nhóm.
	Giá trị mặc định là "1 0", nghĩa là không ai (kể cả root) có thể
	tạo ổ cắm ping.  Đặt nó thành "100 100" sẽ cấp quyền
	vào nhóm duy nhất. "0 4294967294" sẽ kích hoạt tính năng này cho cả thế giới, "100
	4294967294" sẽ kích hoạt nó cho người dùng chứ không phải cho daemon.

tcp_early_demux - BOOLEAN
	Kích hoạt tính năng giải mã sớm cho các ổ cắm TCP đã được thiết lập.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

udp_early_demux - BOOLEAN
	Kích hoạt tính năng giải mã sớm cho các ổ cắm UDP được kết nối. Vô hiệu hóa điều này nếu
	hệ thống của bạn có thể gặp nhiều tải không được kết nối hơn.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

icmp_echo_ignore_all - BOOLEAN
	Nếu được bật thì kernel sẽ bỏ qua tất cả ICMP ECHO
	yêu cầu gửi đến nó.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

icmp_echo_enable_probe - BOOLEAN
        Nếu được bật thì kernel sẽ phản hồi RFC 8335 PROBE
        yêu cầu gửi đến nó.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

icmp_echo_ignore_broadcasts - BOOLEAN
	Nếu được bật thì kernel sẽ bỏ qua tất cả ICMP ECHO và
	Các yêu cầu TIMESTAMP được gửi tới nó thông qua quảng bá/phát đa hướng.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

icmp_ratelimit - INTEGER
	Giới hạn tốc độ tối đa để gửi các gói ICMP có loại phù hợp
	icmp_ratemask (xem bên dưới) cho các mục tiêu cụ thể.
	0 để vô hiệu hóa mọi giới hạn,
	mặt khác, khoảng cách tối thiểu giữa các phản hồi tính bằng mili giây.
	Lưu ý rằng một sysctl khác, icmp_msgs_per_sec giới hạn số lượng
	trong số các gói ICMP được gửi trên tất cả các mục tiêu.

Mặc định: 1000

icmp_msgs_per_sec - INTEGER
	Giới hạn số lượng gói ICMP tối đa được gửi mỗi giây từ máy chủ này.
	Chỉ những tin nhắn có loại khớp với icmp_ratemask (xem bên dưới) mới được
	được kiểm soát bởi giới hạn này. Vì lý do bảo mật, số đếm chính xác
	số tin nhắn mỗi giây là ngẫu nhiên.

Mặc định: 10000

icmp_msgs_burst - INTEGER
	icmp_msgs_per_sec kiểm soát số lượng gói ICMP được gửi mỗi giây,
	trong khi icmp_msgs_burst kiểm soát kích thước nhóm mã thông báo.
	Vì lý do bảo mật, kích thước cụm chính xác được chọn ngẫu nhiên.

Mặc định: 10000

icmp_ratemask - INTEGER
	Mặt nạ làm từ loại ICMP có mức giá hạn chế.

Các bit quan trọng: IHGFEDCBA9876543210

Mặt nạ mặc định: 0000001100000011000 (6168)

Định nghĩa bit (xem include/linux/icmp.h):

= ===========================
		0 Tiếng vọng Trả lời
		3 Đích đến không thể truy cập [1]_
		4 nguồn dập tắt [1]_
		5 Chuyển hướng
		8 Yêu cầu tiếng vang
		Đã vượt quá thời gian B [1]_
		Vấn đề tham số C [1]_
		D Yêu cầu dấu thời gian
		E Dấu thời gian Trả lời
		F Yêu cầu thông tin
		Thông tin G Trả lời
		Yêu cầu mặt nạ địa chỉ H
		Tôi trả lời mặt nạ địa chỉ
		= ===========================

	.. [1] These are rate limited by default (see default mask above)

icmp_ignore_bogus_error_responses - BOOLEAN
	Một số bộ định tuyến vi phạm RFC1122 bằng cách gửi phản hồi không có thật để phát sóng
	khung.  Những vi phạm như vậy thường được ghi lại thông qua cảnh báo kernel.
	Nếu được bật, kernel sẽ không đưa ra những cảnh báo như vậy.
	sẽ tránh được sự lộn xộn của tệp nhật ký.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

icmp_errors_use_inbound_ifaddr - BOOLEAN

Nếu bị tắt, thông báo lỗi icmp sẽ được gửi cùng với địa chỉ chính của
	giao diện thoát.

Nếu được bật, tin nhắn sẽ được gửi với địa chỉ chính của
	giao diện nhận gói gây ra lỗi icmp.
	Đây là hành vi mà nhiều quản trị viên mạng mong đợi
	một bộ định tuyến. Và nó có thể gỡ lỗi các bố cục mạng phức tạp
	dễ dàng hơn nhiều.

Lưu ý rằng nếu không có địa chỉ chính cho giao diện được chọn,
	sau đó là địa chỉ chính của giao diện không vòng lặp ngược đầu tiên
	có một cái sẽ được sử dụng bất kể cài đặt này.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

icmp_errors_extension_mask - UNSIGNED INTEGER
	Bitmask của phần mở rộng ICMP để thêm vào thông báo lỗi ICMPv4
	("Không thể truy cập đích", "Đã vượt quá thời gian" và "Vấn đề về thông số").
	Datagram gốc được cắt bớt/đệm xuống còn 128 byte để
	tương thích với các ứng dụng không tuân thủ RFC 4884.

Các phần mở rộng có thể có là:

==== ====================================================================
	0x01 Thông tin giao diện IP đến theo RFC 5837.
	     Tiện ích mở rộng sẽ bao gồm chỉ mục, địa chỉ IPv4 (nếu có),
	     tên và MTU của giao diện IP đã nhận datagram
	     đã gây ra lỗi ICMP.
	==== ====================================================================

Mặc định: 0x00 (không có phần mở rộng)

igmp_max_memberships - INTEGER
	Thay đổi số lượng nhóm multicast tối đa mà chúng tôi có thể đăng ký.
	Mặc định: 20

Giá trị tối đa theo lý thuyết bị giới hạn bởi việc phải gửi thành viên
	báo cáo trong một datagram duy nhất (tức là báo cáo không thể trải rộng trên nhiều
	datagram, hoặc có nguy cơ gây nhầm lẫn cho việc chuyển đổi và rời khỏi các nhóm mà bạn không
	có ý định).

Số lượng nhóm được hỗ trợ 'M' được giới hạn bởi số lượng nhóm
	các mục báo cáo mà bạn có thể đưa vào một datagram duy nhất có dung lượng 65535 byte.

M = 65536-sizeof (tiêu đề ip)/(sizeof(Bản ghi nhóm))

Các bản ghi nhóm có độ dài thay đổi, tối thiểu là 12 byte.
	Vì vậy, net.ipv4.igmp_max_memberships không nên được đặt cao hơn:

(65536-24) / 12 = 5459

Giá trị 5459 giả định không có tùy chọn tiêu đề IP, vì vậy trong thực tế
	con số này có thể thấp hơn.

igmp_max_msf - INTEGER
	Số lượng địa chỉ tối đa được phép trong danh sách bộ lọc nguồn cho một
	nhóm phát đa hướng.

Mặc định: 10

igmp_qrv - INTEGER
	Kiểm soát biến độ mạnh của truy vấn IGMP (xem RFC2236 8.1).

Mặc định: 2 (như được chỉ định bởi RFC2236 8.1)

Tối thiểu: 1 (như được chỉ định bởi RFC6636 4.5)

lực_igmp_version - INTEGER
	- 0 - (mặc định) Không thực thi phiên bản IGMP, dự phòng IGMPv1/v2
	  được phép. Sẽ quay lại chế độ IGMPv3 lần nữa nếu tất cả IGMPv1/v2 Querier
	  Đồng hồ hiện tại hết hạn.
	- 1 - Buộc sử dụng IGMP phiên bản 1. Cũng sẽ trả lời báo cáo IGMPv1 nếu
	  nhận truy vấn IGMPv2/v3.
	- 2 - Buộc sử dụng IGMP phiên bản 2. Sẽ chuyển sang IGMPv1 nếu nhận được
	  Thông báo truy vấn IGMPv1. Sẽ trả lời báo cáo nếu nhận được truy vấn IGMPv3.
	- 3 - Buộc sử dụng IGMP phiên bản 3. Phản ứng tương tự với mặc định 0.

	.. note::

	   this is not the same with force_mld_version because IGMPv3 RFC3376
	   Security Considerations does not have clear description that we could
	   ignore other version messages completely as MLDv2 RFC3810. So make
	   this value as default 0 is recommended.

ZZ0000ZZ
	thay đổi cài đặt đặc biệt cho mỗi giao diện (trong đó
	giao diện" là tên giao diện mạng của bạn)

ZZ0000ZZ
	  là đặc biệt, thay đổi cài đặt cho tất cả các giao diện

log_martians - BOOLEAN
	Ghi nhật ký các gói có địa chỉ không thể vào nhật ký kernel.
	log_martians cho giao diện sẽ được kích hoạt nếu ít nhất một trong
	conf/{all,interface}/log_martians được đặt thành TRUE,
	nếu không nó sẽ bị vô hiệu hóa

chấp nhận_redirects - BOOLEAN
	Chấp nhận tin nhắn chuyển hướng ICMP.
	Accept_redirects cho giao diện sẽ được bật nếu:

- cả hai conf/{all,interface}/accept_redirects đều là TRUE trong trường hợp này
	  chuyển tiếp cho giao diện được kích hoạt

hoặc

- ít nhất một trong các conf/{all,interface}/accept_redirects là TRUE trong
	  chuyển tiếp trường hợp cho giao diện bị vô hiệu hóa

Chấp nhận_redirects cho giao diện sẽ bị vô hiệu hóa nếu không

mặc định:

- TRUE (máy chủ)
		- FALSE (bộ định tuyến)

chuyển tiếp - BOOLEAN
	Kích hoạt tính năng chuyển tiếp IP trên giao diện này.  Điều này kiểm soát xem các gói
	đã nhận _on_ giao diện này có thể được chuyển tiếp.

mc_forwarding - BOOLEAN
	Thực hiện định tuyến multicast. Kernel cần được biên dịch bằng CONFIG_MROUTE
	và cần có một daemon định tuyến multicast.
	conf/all/mc_forwarding cũng phải được đặt thành TRUE để bật tính năng phát đa hướng
	định tuyến cho giao diện

Medium_id - INTEGER
	Giá trị số nguyên được sử dụng để phân biệt các thiết bị theo phương tiện chúng
	được gắn vào. Hai thiết bị có thể có giá trị id khác nhau khi
	các gói tin quảng bá chỉ được nhận trên một trong số chúng.
	Giá trị mặc định 0 nghĩa là thiết bị là giao diện duy nhất
	đối với phương tiện của nó, giá trị -1 có nghĩa là phương tiện đó không được biết đến.

Hiện tại, nó được sử dụng để thay đổi hành vi proxy_arp:
	tính năng proxy_arp được bật cho các gói được chuyển tiếp giữa
	hai thiết bị được gắn vào các phương tiện khác nhau.

proxy_arp - BOOLEAN
	Làm proxy arp.

proxy_arp cho giao diện sẽ được bật nếu ít nhất một trong
	conf/{all,interface}/proxy_arp được đặt thành TRUE,
	nếu không nó sẽ bị vô hiệu hóa

proxy_arp_pvlan - BOOLEAN
	Arp proxy VLAN riêng tư.

Về cơ bản cho phép trả lời proxy arp trở lại cùng một giao diện
	(từ đó đã nhận được yêu cầu/gợi ý ARP).

Điều này được thực hiện để hỗ trợ các tính năng chuyển đổi (ethernet), như RFC
	3069, trong đó các cổng riêng lẻ là NOT được phép
	giao tiếp với nhau, nhưng họ được phép nói chuyện với
	bộ định tuyến ngược dòng.  Như được mô tả trong RFC 3069, có thể
	để cho phép các máy chủ này giao tiếp thông qua thượng nguồn
	bộ định tuyến bằng proxy_arp'ing. Không cần phải sử dụng cùng với
	proxy_arp.

Công nghệ này được biết đến với nhiều tên khác nhau:

- Trong RFC 3069 nó được gọi là Tập hợp VLAN.
	- Cisco và Allied Telesyn gọi nó là Private VLAN.
	- Hewlett-Packard gọi nó là lọc Nguồn-Cổng hoặc cách ly cổng.
	- Ericsson gọi nó là Chuyển tiếp cưỡng bức MAC (RFC Draft).

proxy_delay - INTEGER
	Trì hoãn phản hồi proxy.

Trì hoãn phản hồi đối với lời mời chào của hàng xóm khi proxy_arp
	hoặc proxy_ndp được bật. Giá trị ngẫu nhiên trong khoảng [0, proxy_delay)
	sẽ được chọn, đặt về 0 nghĩa là trả lời không chậm trễ.
	Giá trị trong nháy mắt. Mặc định là 80.

chia sẻ_media - BOOLEAN
	Gửi (bộ định tuyến) hoặc chấp nhận (máy chủ) chuyển hướng phương tiện được chia sẻ RFC1620.
	Ghi đè safe_redirects.

Shared_media cho giao diện sẽ được bật nếu ít nhất một trong
	conf/{all,interface}/shared_media được đặt thành TRUE,
	nếu không nó sẽ bị vô hiệu hóa

mặc định TRUE

safe_redirects - BOOLEAN
	Chỉ chấp nhận tin nhắn chuyển hướng ICMP tới các cổng được liệt kê trong
	danh sách cổng hiện tại của giao diện. Ngay cả khi bị tắt, RFC1122 vẫn chuyển hướng
	các quy tắc vẫn được áp dụng.

Bị ghi đè bởi Shared_media.

safe_redirects cho giao diện sẽ được bật nếu ít nhất một trong
	conf/{all,interface}/secure_redirects được đặt thành TRUE,
	nếu không nó sẽ bị vô hiệu hóa

mặc định TRUE

gửi_redirects - BOOLEAN
	Gửi chuyển hướng, nếu router.

send_redirects cho giao diện sẽ được bật nếu ít nhất một trong
	conf/{all,interface}/send_redirects được đặt thành TRUE,
	nếu không nó sẽ bị vô hiệu hóa

Mặc định: TRUE

bootp_relay - BOOLEAN
	Chấp nhận các gói có địa chỉ nguồn 0.b.c.d đích
	không phải với máy chủ này như máy chủ địa phương. Người ta cho rằng, đó
	Daemon chuyển tiếp BOOTP sẽ bắt và chuyển tiếp các gói như vậy.
	conf/all/bootp_relay cũng phải được đặt thành TRUE để bật chuyển tiếp BOOTP
	cho giao diện

mặc định FALSE

Chưa được triển khai.

chấp nhận_source_route - BOOLEAN
	Chấp nhận các gói với tùy chọn SRR.
	conf/all/accept_source_route cũng phải được đặt thành TRUE để chấp nhận gói
	với tùy chọn SRR trên giao diện

mặc định

-TRUE (bộ định tuyến)
		- FALSE (máy chủ)

chấp nhận_local - BOOLEAN
	Chấp nhận các gói có địa chỉ nguồn cục bộ. Kết hợp với
	định tuyến phù hợp, điều này có thể được sử dụng để định hướng các gói giữa hai
	giao diện cục bộ qua dây và chúng được chấp nhận đúng cách.
	mặc định FALSE

tuyến_localnet - BOOLEAN
	Không coi địa chỉ loopback là nguồn hoặc đích của sao Hỏa
	trong khi định tuyến. Điều này cho phép sử dụng 127/8 cho mục đích định tuyến cục bộ.

mặc định FALSE

rp_filter - INTEGER
	- 0 - Không xác thực nguồn.
	- 1 - Chế độ nghiêm ngặt như được xác định trong Đường dẫn ngược nghiêm ngặt RFC3704
	  Mỗi gói đến được kiểm tra dựa trên FIB và nếu giao diện
	  không phải là đường dẫn ngược tốt nhất nên việc kiểm tra gói sẽ thất bại.
	  Theo mặc định, các gói bị lỗi sẽ bị loại bỏ.
	- 2 - Chế độ lỏng lẻo như được xác định trong Đường dẫn ngược lỏng lẻo RFC3704
	  Địa chỉ nguồn của mỗi gói đến cũng được kiểm tra dựa trên FIB
	  và nếu địa chỉ nguồn không thể truy cập được qua bất kỳ giao diện nào
	  việc kiểm tra gói sẽ thất bại.

Cách thực hiện được đề xuất hiện tại trong RFC3704 là bật chế độ nghiêm ngặt
	để ngăn chặn việc giả mạo IP từ các cuộc tấn công DDos. Nếu sử dụng định tuyến bất đối xứng
	hoặc định tuyến phức tạp khác thì nên sử dụng chế độ lỏng lẻo.

Giá trị tối đa từ conf/{all,interface}/rp_filter được sử dụng
	khi thực hiện xác thực nguồn trên {interface}.

Giá trị mặc định là 0. Lưu ý rằng một số bản phân phối cho phép nó
	trong các kịch bản khởi động.

src_valid_mark - BOOLEAN
	- 0 - Fwmark của gói không được đưa vào đường dẫn ngược
	  tra cứu lộ trình.  Điều này cho phép cấu hình định tuyến không đối xứng
	  chỉ sử dụng dấu fwmark theo một hướng, ví dụ: trong suốt
	  ủy quyền.

- 1 - Fwmark của gói được bao gồm trong tuyến đường dẫn ngược
	  tra cứu.  Điều này cho phép rp_filter hoạt động khi fwmark được
	  được sử dụng để định tuyến lưu lượng theo cả hai hướng.

Cài đặt này cũng ảnh hưởng đến việc sử dụng fmwark khi
	thực hiện lựa chọn địa chỉ nguồn cho các phản hồi ICMP hoặc
	xác định địa chỉ được lưu trữ cho IPOPT_TS_TSANDADDR và
	Tùy chọn IP IPOPT_RR.

Giá trị tối đa từ conf/{all,interface}/src_valid_mark được sử dụng.

Giá trị mặc định là 0.

arp_filter - BOOLEAN
	- 1 - Cho phép bạn có nhiều giao diện mạng trên cùng một
	  mạng con và có ARP cho mỗi giao diện được trả lời
	  dựa trên việc hạt nhân có định tuyến gói tin từ
	  ARP'd IP out giao diện đó (do đó bạn phải sử dụng nguồn
	  định tuyến dựa trên để làm việc này). Nói cách khác nó cho phép kiểm soát
	  trong đó thẻ (thường là 1) sẽ phản hồi yêu cầu arp.

- 0 - (mặc định) Kernel có thể đáp ứng các yêu cầu arp bằng địa chỉ
	  từ các giao diện khác. Điều này có vẻ sai nhưng nó thường khiến
	  có ý nghĩa vì nó làm tăng cơ hội giao tiếp thành công.
	  Địa chỉ IP được sở hữu bởi toàn bộ máy chủ trên Linux chứ không phải bởi
	  các giao diện cụ thể. Chỉ dành cho các thiết lập phức tạp hơn như tải-
	  cân bằng, hành vi này có gây ra vấn đề không.

arp_filter cho giao diện sẽ được bật nếu ít nhất một trong
	conf/{all,interface}/arp_filter được đặt thành TRUE,
	nếu không nó sẽ bị vô hiệu hóa

arp_announce - INTEGER
	Xác định các mức hạn chế khác nhau để thông báo địa phương
	địa chỉ IP nguồn từ các gói IP trong các yêu cầu ARP được gửi đi
	giao diện:

- 0 - (mặc định) Sử dụng bất kỳ địa chỉ cục bộ nào, được định cấu hình trên bất kỳ giao diện nào
	- 1 - Cố gắng tránh các địa chỉ cục bộ không nằm trong mục tiêu
	  mạng con cho giao diện này. Chế độ này hữu ích khi mục tiêu
	  máy chủ có thể truy cập qua giao diện này yêu cầu IP nguồn
	  địa chỉ trong ARP yêu cầu trở thành một phần của mạng logic của họ
	  được cấu hình trên giao diện nhận. Khi chúng ta tạo ra
	  yêu cầu chúng tôi sẽ kiểm tra tất cả các mạng con bao gồm
	  IP mục tiêu và sẽ giữ nguyên địa chỉ nguồn nếu nó đến từ
	  mạng con như vậy. Nếu không có mạng con như vậy, chúng tôi chọn nguồn
	  địa chỉ theo quy định cấp 2.
	- 2 - Luôn sử dụng địa chỉ cục bộ tốt nhất cho mục tiêu này.
	  Trong chế độ này, chúng tôi bỏ qua địa chỉ nguồn trong gói IP
	  và cố gắng chọn địa chỉ địa phương mà chúng tôi muốn nói chuyện
	  máy chủ mục tiêu. Địa chỉ cục bộ như vậy được chọn bằng cách tìm kiếm
	  cho các địa chỉ IP chính trên tất cả các mạng con của chúng tôi trên đường đi
	  giao diện bao gồm địa chỉ IP mục tiêu. Nếu không phù hợp
	  địa chỉ cục bộ được tìm thấy, chúng tôi chọn địa chỉ cục bộ đầu tiên
	  chúng tôi có trên giao diện gửi đi hoặc trên tất cả các giao diện khác,
	  với hy vọng chúng tôi sẽ nhận được câu trả lời cho yêu cầu của mình và
	  thậm chí đôi khi bất kể địa chỉ IP nguồn mà chúng tôi công bố.

Giá trị tối đa từ conf/{all,interface}/arp_announce được sử dụng.

Việc tăng mức hạn chế mang lại nhiều cơ hội hơn cho
	nhận được câu trả lời từ mục tiêu đã giải quyết trong khi giảm
	cấp độ thông báo thông tin người gửi hợp lệ hơn.

arp_ignore - INTEGER
	Xác định các chế độ khác nhau để gửi phản hồi để đáp lại
	đã nhận được các yêu cầu ARP giải quyết các địa chỉ IP mục tiêu cục bộ:

- 0 - (mặc định): trả lời mọi địa chỉ IP mục tiêu cục bộ, được định cấu hình
	  trên bất kỳ giao diện nào
	- 1 - chỉ trả lời nếu địa chỉ IP mục tiêu là địa chỉ cục bộ
	  được cấu hình trên giao diện đến
	- 2 - chỉ trả lời nếu địa chỉ IP mục tiêu là địa chỉ cục bộ
	  được cấu hình trên giao diện đến và cả với
	  địa chỉ IP của người gửi là một phần của cùng một mạng con trên giao diện này
	- 3 - không trả lời các địa chỉ cục bộ được định cấu hình với máy chủ phạm vi,
	  chỉ có độ phân giải cho địa chỉ toàn cầu và liên kết mới được phản hồi
	- 4-7 - dành riêng
	- 8 - không trả lời tất cả các địa chỉ cục bộ

Giá trị tối đa từ conf/{all,interface}/arp_ignore được sử dụng
	khi nhận được yêu cầu ARP trên {interface}

arp_notify - BOOLEAN
	Xác định chế độ thông báo thay đổi địa chỉ và thiết bị.

================================================================
	  0 (mặc định): không làm gì
	  1 Tạo các yêu cầu arp miễn phí khi thiết bị được đưa lên
	     hoặc thay đổi địa chỉ phần cứng.
	 ================================================================

arp_accept - INTEGER
	Xác định hành vi chấp nhận các khung ARP (garp) vô cớ từ các thiết bị
	chưa có trong bảng ARP:

- 0 - không tạo mục mới trong bảng ARP
	- 1 - tạo các mục mới trong bảng ARP
	- 2 - chỉ tạo mục mới nếu địa chỉ IP nguồn giống nhau
	  mạng con dưới dạng địa chỉ được định cấu hình trên giao diện nhận được
	  tin nhắn garp.

Cả hai loại trả lời và yêu cầu arp vô cớ sẽ kích hoạt
	Bảng ARP sẽ được cập nhật nếu cài đặt này được bật.

Nếu bảng ARP đã chứa địa chỉ IP của
	khung arp miễn phí, bảng arp sẽ được cập nhật bất kể
	nếu cài đặt này được bật hoặc tắt.

arp_evict_nocarrier - BOOLEAN
	Xóa bộ đệm ARP trên các sự kiện NOCARRIER. Tùy chọn này rất quan trọng đối với
	các thiết bị không dây không được xóa bộ nhớ đệm ARP khi chuyển vùng
	giữa các điểm truy cập trên cùng một mạng. Trong hầu hết các trường hợp, điều này nên
	vẫn giữ nguyên như mặc định (1).

Các giá trị có thể:

- 0 (đã tắt) - Không xóa bộ đệm ARP trên các sự kiện NOCARRIER
	- 1 (đã bật) - Xóa bộ đệm ARP trên các sự kiện NOCARRIER

Mặc định: 1 (đã bật)

mcast_solicit - INTEGER
	Số lượng đầu dò phát đa hướng tối đa ở trạng thái INCOMPLETE,
	khi địa chỉ phần cứng liên quan không xác định.  Mặc định
	đến 3.

ucast_solicit - INTEGER
	Số lượng đầu dò unicast tối đa ở trạng thái PROBE, khi
	địa chỉ phần cứng đang được xác nhận lại.  Mặc định là 3.

app_solicit - INTEGER
	Số lượng đầu dò tối đa để gửi tới không gian người dùng daemon ARP
	qua netlink trước khi quay lại thăm dò multicast (xem
	mcast_resolicit).  Mặc định là 0.

mcast_resolicit - INTEGER
	Số lượng đầu dò multicast tối đa sau unicast và
	thăm dò ứng dụng ở trạng thái PROBE.  Mặc định là 0.

vô hiệu hóa_chính sách - BOOLEAN
	Vô hiệu hóa chính sách IPSEC (SPD) cho giao diện này

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

vô hiệu hóa_xfrm - BOOLEAN
	Vô hiệu hóa mã hóa IPSEC trên giao diện này, bất kể chính sách nào

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

igmpv2_unsolicited_report_interval - INTEGER
	Khoảng thời gian tính bằng mili giây trong đó lần gửi tiếp theo không được yêu cầu
	Việc truyền lại báo cáo IGMPv1 hoặc IGMPv2 sẽ diễn ra.

Mặc định: 10000 (10 giây)

igmpv3_unsolicited_report_interval - INTEGER
	Khoảng thời gian tính bằng mili giây trong đó lần gửi tiếp theo không được yêu cầu
	Việc truyền lại báo cáo IGMPv3 sẽ diễn ra.

Mặc định: 1000 (1 giây)

bỏ qua_routes_with_linkdown - BOOLEAN
        Bỏ qua các tuyến có liên kết bị hỏng khi thực hiện tra cứu FIB.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

Promote_secondaries - BOOLEAN
	Khi địa chỉ IP chính bị xóa khỏi giao diện này
	quảng bá địa chỉ IP phụ tương ứng thay vì
	loại bỏ tất cả các địa chỉ IP phụ tương ứng.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

drop_unicast_in_l2_multicast - BOOLEAN
	Loại bỏ mọi gói IP unicast được nhận trong lớp liên kết
	khung multicast (hoặc quảng bá).

Hành vi này (đối với phát đa hướng) thực sự là SHOULD trong RFC
	1122 nhưng bị tắt theo mặc định vì lý do tương thích.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

drop_gratuitous_arp - BOOLEAN
	Bỏ tất cả các khung ARP vô cớ, chẳng hạn như nếu đã biết
	proxy ARP tốt trên mạng và không cần sử dụng các khung như vậy
	(hoặc trong trường hợp 802.11, không được sử dụng để ngăn chặn các cuộc tấn công.)

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)


thẻ - INTEGER
	Cho phép bạn viết một số, có thể được sử dụng theo yêu cầu.

Giá trị mặc định là 0.

xfrm4_gc_thresh - INTEGER
	(Lỗi thời kể từ linux-4.14)
	Ngưỡng mà chúng tôi sẽ bắt đầu thu thập rác cho IPv4
	mục bộ đệm đích.  Với giá trị gấp đôi này, hệ thống sẽ
	từ chối phân bổ mới

igmp_link_local_mcast_reports - BOOLEAN
	Kích hoạt báo cáo IGMP để liên kết các nhóm multicast cục bộ trong
	Phạm vi 224.0.0.X.

TRUE mặc định

Alexey Kuznetsov.
kuznet@ms2.inr.ac.ru

Cập nhật bởi:

- Andi Kleen
  ak@muc.de
- Nicolas Delon
  delon.nicolas@wanadoo.fr




/proc/sys/net/ipv6/* Các biến
==============================

IPv6 không có các biến toàn cục như cài đặt tcp_*.  tcp_* trong ipv4/
áp dụng cho IPv6 [XXX?].

bindv6only - BOOLEAN
	Giá trị mặc định cho tùy chọn ổ cắm IPV6_V6ONLY,
	hạn chế việc sử dụng ổ cắm IPv6 cho giao tiếp IPv6
	chỉ.

Các giá trị có thể:

- 0 (đã tắt) - bật tính năng địa chỉ được ánh xạ IPv4
	- 1 (đã bật) - tắt tính năng địa chỉ được ánh xạ IPv4

Mặc định: 0 (đã tắt)

flowlabel_consistency - BOOLEAN
	Bảo vệ tính nhất quán (và tính thống nhất) của nhãn luồng.
	Bạn phải tắt nó để sử dụng cờ IPV6_FL_F_REFLECT trên
	quản lý nhãn luồng.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

nhãn tự động - INTEGER
	Tự động tạo nhãn luồng dựa trên hàm băm luồng của
	gói. Điều này cho phép các thiết bị trung gian, chẳng hạn như bộ định tuyến,
	xác định các luồng gói cho các cơ chế như Đa đường chi phí bằng nhau
	Định tuyến (xem RFC 6438).

= ================================================================
	0 nhãn luồng tự động bị vô hiệu hóa hoàn toàn
	1 nhãn luồng tự động được bật theo mặc định, chúng có thể
	   bị vô hiệu hóa trên cơ sở từng ổ cắm bằng IPV6_AUTOFLOWLABEL
	   tùy chọn ổ cắm
	Cho phép 2 nhãn luồng tự động, chúng có thể được bật trên một
	   trên mỗi ổ cắm bằng tùy chọn ổ cắm IPV6_AUTOFLOWLABEL
	3 nhãn luồng tự động được bật và thực thi, chúng không thể
	   bị vô hiệu hóa bởi tùy chọn ổ cắm
	= ================================================================

Mặc định: 1

flowlabel_state_ranges - BOOLEAN
	Chia không gian số nhãn luồng thành hai phạm vi. 0-0x7FFFF là
	dành riêng cho cơ sở quản lý luồng IPv6, 0x80000-0xFFFFF
	được dành riêng cho nhãn luồng không trạng thái như được mô tả trong RFC6437.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)


flowlabel_reflect - INTEGER
	Kiểm soát phản ánh nhãn dòng chảy. Cần thiết cho đường dẫn MTU
	Discovery hoạt động với Định tuyến đa đường chi phí bằng nhau trong Anycast
	môi trường. Xem RFC 7690 và:
	ZZ0000ZZ

Đây là một mặt nạ bit.

- 1: được kích hoạt cho các luồng đã thiết lập

Lưu ý rằng điều này ngăn cản việc thay đổi nhãn luồng tự động, như đã thực hiện
	  trong "tcp: thay đổi nhãn luồng IPv6 khi nhận được truyền lại giả"
	  và "tcp: Thay đổi txhash trên mỗi lần truyền lại SYN và RTO"

- 2: được bật cho các gói TCP RESET (không có trình nghe hoạt động)
	  Nếu được đặt, gói RST được gửi để phản hồi gói SYN trên mạng đã đóng
	  cổng sẽ phản ánh nhãn luồng đến.

- 4: kích hoạt cho tin nhắn trả lời tiếng vang ICMPv6.

Mặc định: 0

fib_multipath_hash_policy - INTEGER
	Kiểm soát chính sách băm nào sẽ được sử dụng cho các tuyến đường đa đường.

Mặc định: 0 (Lớp 3)

Các giá trị có thể:

- 0 - Lớp 3 (địa chỉ nguồn và đích cộng với nhãn luồng)
	- 1 - Lớp 4 (tiêu chuẩn 5 tuple)
	- 2 - Lớp 3 hoặc Lớp 3 bên trong nếu có
	- 3 - Băm đa đường tùy chỉnh. Các trường được sử dụng để tính toán băm đa đường
	  được xác định bởi fib_multipath_hash_fields sysctl

fib_multipath_hash_fields - UNSIGNED INTEGER
	Khi fib_multipath_hash_policy được đặt thành 3 (băm đa đường tùy chỉnh),
	các trường được sử dụng để tính toán băm đa đường được xác định bởi điều này
	sysctl.

Giá trị này là một bitmask cho phép các trường khác nhau cho hàm băm đa đường
	tính toán.

Các trường có thể là:

====== ===============================
	0x0001 Địa chỉ IP nguồn
	0x0002 Địa chỉ IP đích
	Giao thức IP 0x0004
	Nhãn luồng 0x0008
	Cổng nguồn 0x0010
	Cổng đích 0x0020
	0x0040 Địa chỉ IP nguồn bên trong
	0x0080 Địa chỉ IP đích bên trong
	0x0100 Giao thức IP bên trong
	Nhãn dòng chảy bên trong 0x0200
	0x0400 Cổng nguồn bên trong
	0x0800 Cổng đích bên trong
	====== ===============================

Mặc định: 0x0007 (IP nguồn, IP đích và giao thức IP)

Anycast_src_echo_reply - BOOLEAN
	Kiểm soát việc sử dụng địa chỉ Anycast làm địa chỉ nguồn cho ICMPv6
	tiếng vang trả lời

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)


idgen_delay - INTEGER
	Kiểm soát độ trễ tính bằng giây, sau đó thử lại
	tạo địa chỉ ổn định về quyền riêng tư nếu xảy ra xung đột DAD
	được phát hiện.

Mặc định: 1 (như được chỉ định trong RFC7217)

idgen_retries - INTEGER
	Kiểm soát số lần thử lại để tạo sự riêng tư ổn định
	địa chỉ nếu phát hiện xung đột DAD.

Mặc định: 3 (như được chỉ định trong RFC7217)

mld_qrv - INTEGER
	Kiểm soát biến độ mạnh của truy vấn MLD (xem RFC3810 9.1).

Mặc định: 2 (như được chỉ định bởi RFC3810 9.1)

Tối thiểu: 1 (như được chỉ định bởi RFC6636 4.5)

max_dst_opts_number - INTEGER
	Số lượng TLV không đệm tối đa được phép ở một Đích
	tiêu đề mở rộng tùy chọn. Nếu giá trị này nhỏ hơn 0
	thì các tùy chọn chưa biết sẽ không được phép và số lượng đã biết
	TLV được phép là giá trị tuyệt đối của con số này.

Mặc định: 8

max_hbh_opts_number - INTEGER
	Số TLV không đệm tối đa được phép trong Hop-by-Hop
	tiêu đề mở rộng tùy chọn. Nếu giá trị này nhỏ hơn 0
	thì các tùy chọn chưa biết sẽ không được phép và số lượng đã biết
	TLV được phép là giá trị tuyệt đối của con số này.

Mặc định: 8

max_dst_opts_length - INTEGER
	Độ dài tối đa được phép cho tiện ích mở rộng Tùy chọn điểm đến
	tiêu đề.

Mặc định: INT_MAX (không giới hạn)

max_hbh_length - INTEGER
	Độ dài tối đa được phép cho tiện ích mở rộng tùy chọn Hop-by-Hop
	tiêu đề.

Mặc định: INT_MAX (không giới hạn)

Skip_notify_on_dev_down - BOOLEAN
	Kiểm soát xem thông báo RTM_DELROUTE có được tạo cho các tuyến đường hay không
	bị xóa khi một thiết bị bị gỡ xuống hoặc bị xóa. IPv4 không
	tạo thông báo này; IPv6 thực hiện theo mặc định. Đặt sysctl này
	thành true sẽ bỏ qua tin nhắn, làm cho IPv4 và IPv6 ngang bằng với việc dựa vào
	trên bộ đệm vùng người dùng để theo dõi các sự kiện liên kết và loại bỏ các tuyến đường.

Các giá trị có thể:

- 0 (đã tắt) - tạo thông báo
	- 1 (đã bật) - bỏ qua việc tạo tin nhắn

Mặc định: 0 (đã tắt)

nexthop_compat_mode - BOOLEAN
	Nexthop API mới cung cấp phương tiện để quản lý các nexthop độc lập với
	tiền tố. Khả năng tương thích ngược với định dạng tuyến đường cũ được bật bởi
	mặc định có nghĩa là các kết xuất tuyến đường và thông báo chứa thông tin mới
	thuộc tính nexthop mà còn là định nghĩa nexthop đầy đủ, mở rộng.
	Hơn nữa, việc cập nhật hoặc xóa cấu hình nexthop sẽ tạo ra tuyến đường
	thông báo cho mỗi mục fib bằng cách sử dụng nexthop. Một khi là một hệ thống
	hiểu API mới, hệ thống này có thể bị vô hiệu hóa để đạt được đầy đủ
	lợi ích hiệu suất của API mới bằng cách vô hiệu hóa tính năng mở rộng nexthop
	và các thông báo không liên quan.

Lưu ý rằng với tư cách là một chế độ tương thích ngược, việc loại bỏ các tính năng hiện đại
	có thể chưa đầy đủ hoặc sai. Ví dụ, các nhóm kiên cường sẽ không
	được hiển thị như vậy mà chỉ là danh sách các bước nhảy tiếp theo. Cũng có trọng lượng đó
	không vừa với 8 bit sẽ hiển thị không chính xác.

Mặc định: true (chế độ tương thích ngược)

fib_notify_on_flag_change - INTEGER
        Có phát thông báo RTM_NEWROUTE bất cứ khi nào RTM_F_OFFLOAD/
        Cờ RTM_F_TRAP/RTM_F_OFFLOAD_FAILED được thay đổi.

Sau khi cài đặt tuyến đường tới kernel, không gian người dùng sẽ nhận được một
        xác nhận, có nghĩa là tuyến đường đã được cài đặt trong kernel,
        nhưng không nhất thiết phải ở phần cứng.
        Cũng có thể tuyến đường đã được cài đặt trong phần cứng có thể thay đổi
        hành động của nó và do đó cờ của nó. Ví dụ: một tuyến máy chủ được
        Các gói bẫy có thể được "thúc đẩy" để thực hiện việc giải mã sau
        việc cài đặt đường hầm IPinIP/VXLAN.
        Các thông báo sẽ cho người dùng biết trạng thái của tuyến đường.

Mặc định: 0 (Không phát ra thông báo.)

Các giá trị có thể:

- 0 - Không phát ra thông báo.
        - 1 - Phát ra thông báo.
        - 2 - Chỉ phát ra thông báo khi thay đổi cờ RTM_F_OFFLOAD_FAILED.

ioam6_id - INTEGER
        Xác định id IOAM của nút này. Chỉ sử dụng 24 bit trong tổng số 32 bit.

Phạm vi giá trị có thể:

- Tối thiểu: 0
        - Tối đa: 0xFFFFFF

Mặc định: 0xFFFFFF

ioam6_id_wide - LONG INTEGER
        Xác định id IOAM rộng của nút này. Chỉ sử dụng 56 bit trong số 64 in
        tổng cộng. Có thể khác với ioam6_id.

Phạm vi giá trị có thể:

- Tối thiểu: 0
        - Tối đa: 0xFFFFFFFFFFFFFF

Mặc định: 0xFFFFFFFFFFFFFF

Phân mảnh IPv6:

ip6frag_high_thresh - INTEGER
	Bộ nhớ tối đa được sử dụng để tập hợp lại các đoạn IPv6. Khi nào
	ip6frag_high_thresh byte bộ nhớ được phân bổ cho mục đích này,
	trình xử lý phân đoạn sẽ ném các gói cho đến khi ip6frag_low_thresh
	đã đạt được.

ip6frag_low_thresh - INTEGER
	Xem ip6frag_high_thresh

ip6frag_time - INTEGER
	Thời gian tính bằng giây để giữ một đoạn IPv6 trong bộ nhớ.

ZZ0000ZZ:
	Thay đổi cài đặt mặc định dành riêng cho giao diện.

Những cài đặt này sẽ được sử dụng trong quá trình tạo giao diện mới.


ZZ0000ZZ:
	Thay đổi tất cả các cài đặt dành riêng cho giao diện.

[XXX: Các tính năng đặc biệt khác ngoài chuyển tiếp?]

conf/all/disable_ipv6 - BOOLEAN
	Thay đổi giá trị này cũng giống như thay đổi ZZ0000ZZ
	cài đặt và tất cả các cài đặt ZZ0001ZZ trên mỗi giao diện giống nhau
	giá trị.

Đọc giá trị này không có bất kỳ ý nghĩa cụ thể nào. Nó không nói
	hỗ trợ IPv6 được bật hay tắt. Giá trị trả về có thể là 1
	cũng trong trường hợp khi một số giao diện có ZZ0000ZZ được đặt thành 0 và
	đã cấu hình địa chỉ IPv6.

conf/tất cả/chuyển tiếp - BOOLEAN
	Cho phép chuyển tiếp IPv6 toàn cầu giữa tất cả các giao diện.

Ở đây IPv4 và IPv6 hoạt động khác nhau; cờ ZZ0000ZZ phải
	được sử dụng để kiểm soát giao diện nào có thể chuyển tiếp gói.

Điều này cũng đặt cài đặt Máy chủ/Bộ định tuyến của tất cả các giao diện
	'chuyển tiếp' đến giá trị được chỉ định.  Xem bên dưới để biết chi tiết.

Điều này được gọi là chuyển tiếp toàn cầu.

proxy_ndp - BOOLEAN
	Làm proxy ndp.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

buộc_chuyển tiếp - BOOLEAN
	Chỉ cho phép chuyển tiếp trên giao diện này -- bất kể cài đặt trên
	ZZ0000ZZ. Khi đặt ZZ0001ZZ thành 0,
	cờ ZZ0002ZZ sẽ được đặt lại trên tất cả các giao diện.

fwmark_reflect - BOOLEAN
	Kiểm soát fwmark của các gói trả lời IPv6 do kernel tạo ra không
	được liên kết với ổ cắm chẳng hạn như phản hồi tiếng vang TCP RST hoặc ICMPv6).
	Nếu bị tắt, các gói này có fwmark bằng 0. Nếu được bật, họ có
	fwmark của gói họ đang trả lời.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

ZZ0000ZZ:
	Thay đổi cài đặt đặc biệt cho mỗi giao diện.

Hoạt động chức năng đối với một số cài đặt nhất định là khác nhau
	tùy thuộc vào việc chuyển tiếp cục bộ có được bật hay không.

chấp nhận_ra - INTEGER
	Chấp nhận quảng cáo bộ định tuyến; tự động cấu hình bằng cách sử dụng chúng.

Nó cũng xác định có truyền Router hay không
	Lời kêu gọi. Nếu và chỉ nếu cài đặt chức năng là
	chấp nhận Quảng cáo trên Bộ định tuyến, Lời chào mời của Bộ định tuyến sẽ
	được truyền đi.

Các giá trị có thể là:

==================================================================
		 0 Không chấp nhận Quảng cáo Bộ định tuyến.
		 1 Chấp nhận Quảng cáo Bộ định tuyến nếu chuyển tiếp bị tắt.
		 2 Ghi đè hành vi chuyển tiếp. Chấp nhận quảng cáo bộ định tuyến
		    ngay cả khi tính năng chuyển tiếp được bật.
		==================================================================

Mặc định chức năng:

- được bật nếu chuyển tiếp cục bộ bị tắt.
		- bị vô hiệu hóa nếu chuyển tiếp cục bộ được bật.

chấp nhận_ra_defrtr - BOOLEAN
	Tìm hiểu bộ định tuyến mặc định trong Quảng cáo bộ định tuyến.

Mặc định chức năng:

- được bật nếu Accept_ra được bật.
		- bị vô hiệu hóa nếu Accept_ra bị vô hiệu hóa.

ra_defrtr_metric - UNSIGNED INTEGER
	Chỉ số tuyến đường cho tuyến đường mặc định đã học trong Quảng cáo bộ định tuyến. Giá trị này
	sẽ được chỉ định làm số liệu cho tuyến đường mặc định được học qua Bộ định tuyến IPv6
	Quảng cáo. Chỉ ảnh hưởng nếu Accept_ra_defrtr được bật.

Các giá trị có thể:
		1 đến 0xFFFFFFFF

Mặc định: IP6_RT_PRIO_USER tức là 1024.

chấp nhận_ra_from_local - BOOLEAN
	Chấp nhận RA với địa chỉ nguồn được tìm thấy trên máy cục bộ
	nếu RA phù hợp và có thể được chấp nhận.

Mặc định là NOT chấp nhận những điều này vì đây có thể là một hành động ngoài ý muốn
	vòng lặp mạng.

Mặc định chức năng:

- được bật nếu Accept_ra_from_local được bật
	     trên một giao diện cụ thể.
	   - bị vô hiệu hóa nếu Accept_ra_from_local bị vô hiệu hóa
	     trên một giao diện cụ thể.

chấp nhận_ra_min_hop_limit - INTEGER
	Thông tin giới hạn bước nhảy tối thiểu trong Quảng cáo bộ định tuyến.

Thông tin giới hạn hop trong Quảng cáo bộ định tuyến ít hơn thông tin này
	biến sẽ bị bỏ qua.

Mặc định: 1

chấp nhận_ra_min_lft - INTEGER
	Giá trị lâu dài tối thiểu có thể chấp nhận được trong Quảng cáo bộ định tuyến.

Các phần RA có tuổi thọ nhỏ hơn giá trị này sẽ là
	bị phớt lờ. Không có cuộc đời nào bị ảnh hưởng.

Mặc định: 0

chấp nhận_ra_pinfo - BOOLEAN
	Tìm hiểu thông tin tiền tố trong quảng cáo bộ định tuyến.

Mặc định chức năng:

- được bật nếu Accept_ra được bật.
		- bị vô hiệu hóa nếu Accept_ra bị vô hiệu hóa.

ra_honor_pio_life - BOOLEAN
	Có nên sử dụng RFC4862 Mục 5.5.3e để xác định giá trị hợp lệ hay không
	thời gian tồn tại của một địa chỉ khớp với tiền tố được gửi trong Bộ định tuyến
	Tùy chọn thông tin tiền tố quảng cáo.

Các giá trị có thể:

- 0 (bị vô hiệu hóa) - RFC4862 phần 5.5.3e được sử dụng để xác định
	  thời gian tồn tại hợp lệ của địa chỉ.
	- 1 (đã bật) - thời gian tồn tại hợp lệ của PIO sẽ luôn được tôn trọng.

Mặc định: 0 (đã tắt)

ra_honor_pio_pflag - BOOLEAN
	Cờ P tùy chọn thông tin tiền tố cho biết mạng có thể
	phân bổ tiền tố IPv6 duy nhất cho mỗi khách hàng bằng DHCPv6-PD.
	Sysctl này có thể được kích hoạt khi máy khách DHCPv6-PD trong không gian người dùng
	đang chạy để khiến cờ P có hiệu lực: tức là
	Cờ P ngăn chặn mọi tác động của cờ A trong cùng một
	PIO. Đối với PIO nhất định, P=1 và A=1 được coi là A=0.

Các giá trị có thể:

- 0 (bị vô hiệu hóa) - cờ P bị bỏ qua.
	- 1 (đã bật) - cờ P sẽ tắt tính năng tự động cấu hình SLAAC
	  cho Tùy chọn Thông tin Tiền tố đã cho.

Mặc định: 0 (đã tắt)

chấp nhận_ra_rt_info_min_plen - INTEGER
	Độ dài tiền tố tối thiểu của Thông tin tuyến đường trong RA.

Thông tin tuyến đường với tiền tố nhỏ hơn biến này sẽ
	bị bỏ qua.

Mặc định chức năng:

* 0 nếu chấp nhận_ra_rtr_pref được bật.
		* -1 nếu chấp nhận_ra_rtr_pref bị tắt.

chấp nhận_ra_rt_info_max_plen - INTEGER
	Độ dài tiền tố tối đa của Thông tin tuyến đường trong RA.

Thông tin tuyến đường với tiền tố lớn hơn biến này sẽ
	bị bỏ qua.

Mặc định chức năng:

* 0 nếu chấp nhận_ra_rtr_pref được bật.
		* -1 nếu chấp nhận_ra_rtr_pref bị tắt.

chấp nhận_ra_rtr_pref - BOOLEAN
	Chấp nhận tùy chọn bộ định tuyến trong RA.

Mặc định chức năng:

- được bật nếu Accept_ra được bật.
		- bị vô hiệu hóa nếu Accept_ra bị vô hiệu hóa.

chấp nhận_ra_mtu - BOOLEAN
	Áp dụng giá trị MTU được chỉ định trong tùy chọn RA 5 (RFC4861). Nếu
	bị vô hiệu hóa, MTU được chỉ định trong RA sẽ bị bỏ qua.

Mặc định chức năng:

- được bật nếu Accept_ra được bật.
		- bị vô hiệu hóa nếu Accept_ra bị vô hiệu hóa.

chấp nhận_redirects - BOOLEAN
	Chấp nhận chuyển hướng.

Mặc định chức năng:

- được bật nếu chuyển tiếp cục bộ bị tắt.
		- bị vô hiệu hóa nếu chuyển tiếp cục bộ được bật.

chấp nhận_source_route - INTEGER
	Chấp nhận định tuyến nguồn (tiêu đề mở rộng định tuyến).

- >= 0: Chỉ chấp nhận tiêu đề định tuyến loại 2.
	- < 0: Không chấp nhận tiêu đề định tuyến.

Mặc định: 0

autoconf - BOOLEAN
	Tự động định cấu hình địa chỉ bằng Thông tin tiền tố trong Bộ định tuyến
	Quảng cáo.

Mặc định chức năng:

- được bật nếu Accept_ra_pinfo được bật.
		- bị vô hiệu hóa nếu Accept_ra_pinfo bị vô hiệu hóa.

bố_truyền - INTEGER
	Số lượng thăm dò Phát hiện địa chỉ trùng lặp cần gửi.

Mặc định: 1

chuyển tiếp - INTEGER
	Định cấu hình hoạt động của Máy chủ/Bộ định tuyến theo giao diện cụ thể.

	.. note::

	   It is recommended to have the same setting on all
	   interfaces; mixed router/host scenarios are rather uncommon.

Các giá trị có thể là:

- 0 Chuyển tiếp bị vô hiệu hóa
		- Đã kích hoạt 1 chuyển tiếp

ZZ0000ZZ:

Theo mặc định, hành vi của Máy chủ được giả định.  Điều này có nghĩa là:

1. Cờ IsRouter không được đặt trong Quảng cáo hàng xóm.
	2. Nếu Accept_ra là TRUE (mặc định), hãy truyền Router
	   Lời kêu gọi.
	3. Nếu Accept_ra là TRUE (mặc định), hãy chấp nhận Bộ định tuyến
	   Quảng cáo (và thực hiện cấu hình tự động).
	4. Nếu Accept_redirects là TRUE (mặc định), hãy chấp nhận Chuyển hướng.

ZZ0000ZZ:

Nếu chuyển tiếp cục bộ được bật, hành vi của Bộ định tuyến sẽ được giả định.
	Điều này có nghĩa chính xác là ngược lại từ trên:

1. Cờ IsRouter được đặt trong Quảng cáo hàng xóm.
	2. Lời mời của bộ định tuyến không được gửi trừ khi Accept_ra là 2.
	3. Quảng cáo bộ định tuyến bị bỏ qua trừ khi Accept_ra là 2.
	4. Chuyển hướng bị bỏ qua.

Mặc định: 0 (bị tắt) nếu chuyển tiếp toàn cầu bị tắt (mặc định),
	nếu không thì 1 (đã bật).

hop_limit - INTEGER
	Giới hạn bước nhảy mặc định cần đặt.

Mặc định: 64

mtu - INTEGER
	Đơn vị chuyển tối đa mặc định

Mặc định: 1280 (yêu cầu tối thiểu IPv6)

ip_nonlocal_bind - BOOLEAN
	Nếu được bật, cho phép các quy trình liên kết() với các địa chỉ IPv6 không cục bộ,
	điều này có thể khá hữu ích - nhưng có thể làm hỏng một số ứng dụng.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

bộ định tuyến_probe_interval - INTEGER
	Khoảng thời gian tối thiểu (tính bằng giây) giữa việc thăm dò bộ định tuyến được mô tả
	trong RFC4191.

Mặc định: 60

router_solicitation_delay - INTEGER
	Số giây chờ sau khi giao diện được hiển thị
	trước khi gửi Lời mời định tuyến.

Mặc định: 1

router_solicitation_interval - INTEGER
	Số giây chờ giữa các lần chào mời bộ định tuyến.

Mặc định: 4

router_solicitations - INTEGER
	Số lượng bản chào mời bộ định tuyến để gửi cho đến khi giả sử không có
	các bộ định tuyến có mặt.

Mặc định: 3

use_oif_addrs_only - BOOLEAN
	Khi được bật, địa chỉ nguồn ứng viên cho các đích
	được định tuyến qua giao diện này bị giới hạn ở tập hợp địa chỉ
	được định cấu hình trên giao diện này (vis. RFC 6724, phần 4).

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

use_tempaddr - INTEGER
	Ưu tiên cho Tiện ích mở rộng quyền riêng tư (RFC3041).

* <= 0 : tắt Tiện ích mở rộng quyền riêng tư
	  * == 1 : bật Tiện ích mở rộng quyền riêng tư nhưng thích công khai hơn
	    địa chỉ trên các địa chỉ tạm thời.
	  * > 1 : bật Tiện ích mở rộng quyền riêng tư và ưu tiên tạm thời
	    địa chỉ trên các địa chỉ công cộng.

Mặc định:

* 0 (đối với hầu hết các thiết bị)
		* -1 (đối với thiết bị point-to-point và thiết bị loopback)

temp_valid_lft - INTEGER
	thời gian tồn tại hợp lệ (tính bằng giây) đối với các địa chỉ tạm thời. Nếu ít hơn
	thời gian tồn tại yêu cầu tối thiểu (thường là 5-7 giây), địa chỉ tạm thời
	sẽ không được tạo ra.

Mặc định: 172800 (2 ngày)

temp_prefered_lft - INTEGER
	Thời gian tồn tại ưu tiên (tính bằng giây) cho các địa chỉ tạm thời. Nếu
	temp_prefered_lft nhỏ hơn thời gian tồn tại tối thiểu được yêu cầu (thường
	5-7 giây), thời gian tồn tại ưa thích là yêu cầu tối thiểu. Nếu
	temp_prefered_lft lớn hơn temp_valid_lft, thời gian tồn tại ưu tiên
	là temp_valid_lft.

Mặc định: 86400 (1 ngày)

keep_addr_on_down - INTEGER
	Giữ tất cả các địa chỉ IPv6 trong trường hợp giao diện bị hỏng. Nếu đặt tĩnh
	địa chỉ toàn cầu không có thời gian hết hạn sẽ không bị xóa.

* >0 : đã bật
	* 0 : mặc định hệ thống
	* <0 : bị vô hiệu hóa

Mặc định: 0 (địa chỉ bị xóa)

max_desync_factor - INTEGER
	Giá trị tối đa cho DESYNC_FACTOR, là giá trị ngẫu nhiên
	điều đó đảm bảo rằng các máy khách không đồng bộ hóa với nhau
	khác và tạo địa chỉ mới cùng một lúc.
	giá trị tính bằng giây.

Mặc định: 600

regen_min_advance - INTEGER
	Khoảng thời gian tối thiểu trước (tính bằng giây) để tạo một bản ghi tạm thời mới
	địa chỉ trước khi địa chỉ hiện tại không được dùng nữa. Giá trị này được thêm vào
	lượng thời gian có thể cần thiết để phát hiện địa chỉ trùng lặp
	để xác định khi nào cần tạo một địa chỉ mới. Linux cho phép thiết lập điều này
	giá trị nhỏ hơn giá trị mặc định là 2 giây, nhưng giá trị nhỏ hơn 2
	không phù hợp với RFC 8981.

Mặc định: 2

regen_max_retry - INTEGER
	Số lần thử trước khi từ bỏ việc cố gắng tạo
	địa chỉ tạm thời hợp lệ.

Mặc định: 5

địa chỉ tối đa - INTEGER
	Số lượng địa chỉ được cấu hình tự động tối đa trên mỗi giao diện.  Cài đặt
	về 0 sẽ vô hiệu hóa giới hạn.  Không nên thiết lập điều này
	giá trị quá lớn (hoặc bằng 0) vì đó sẽ là một cách dễ dàng để
	làm hỏng kernel bằng cách cho phép tạo quá nhiều địa chỉ.

Mặc định: 16

vô hiệu hóa_ipv6 - BOOLEAN
	Vô hiệu hóa hoạt động IPv6.  Nếu Accept_dad được đặt thành 2, giá trị này
	sẽ được đặt động thành TRUE nếu DAD không thành công đối với liên kết cục bộ
	địa chỉ.

Mặc định: FALSE (cho phép hoạt động IPv6)

Khi giá trị này được thay đổi từ 1 thành 0 (IPv6 đang được bật),
	nó sẽ tự động tạo một địa chỉ liên kết cục bộ trên địa chỉ đã cho
	giao diện và bắt đầu Phát hiện địa chỉ trùng lặp, nếu cần.

Khi giá trị này được thay đổi từ 0 thành 1 (IPv6 đang bị tắt),
	nó sẽ tự động xóa tất cả các địa chỉ và tuyến đường trên
	giao diện. Từ giờ trở đi sẽ không thể thêm địa chỉ/tuyến đường
	vào giao diện đã chọn.

chấp nhận_dad - INTEGER
	Có chấp nhận DAD (Phát hiện địa chỉ trùng lặp) hay không.

=====================================================================
	  0 Tắt DAD
	  1 Kích hoạt DAD (mặc định)
	  2 Kích hoạt DAD và vô hiệu hóa hoạt động IPv6 nếu trùng lặp dựa trên MAC
	     địa chỉ liên kết cục bộ đã được tìm thấy.
	 =====================================================================

Hoạt động và chế độ DAD trên một giao diện nhất định sẽ được chọn theo
	tới giá trị tối đa của conf/{all,interface}/accept_dad.

lực_tllao - BOOLEAN
	Cho phép gửi tùy chọn địa chỉ lớp liên kết đích ngay cả khi
	đáp lại lời mời hàng xóm unicast.

Mặc định: FALSE

Trích dẫn từ RFC 2461, phần 4.4, Địa chỉ lớp liên kết đích:

"Tùy chọn MUST được đưa vào cho các yêu cầu phát đa hướng để
	tránh "đệ quy" Neighbor Solicitation vô hạn khi nút ngang hàng
	không có mục nhập bộ đệm để trả về Quảng cáo hàng xóm
	tin nhắn.  Khi trả lời các yêu cầu unicast, tùy chọn có thể là
	bị bỏ qua vì người gửi lời chào mời có liên kết chính xác-
	địa chỉ lớp; nếu không nó sẽ không thể gửi unicast
	lời kêu gọi ngay từ đầu. Tuy nhiên, bao gồm cả lớp liên kết
	địa chỉ trong trường hợp này bổ sung thêm ít chi phí và loại bỏ khả năng
	tình trạng chủng tộc trong đó người gửi xóa địa chỉ lớp liên kết được lưu trong bộ nhớ cache
	trước khi nhận được phản hồi cho lời mời chào trước đó."

ndisc_notify - BOOLEAN
	Xác định chế độ thông báo thay đổi địa chỉ và thiết bị.

Các giá trị có thể:

- 0 (tắt) - không làm gì
	- 1 (đã bật) - Tạo quảng cáo hàng xóm không được yêu cầu khi mang thiết bị
	  lên hoặc thay đổi địa chỉ phần cứng.

Mặc định: 0 (đã tắt)

ndisc_tclass - INTEGER
	Lớp lưu lượng IPv6 được sử dụng theo mặc định khi gửi Hàng xóm IPv6
	Khám phá (Gợi ý bộ định tuyến, Quảng cáo bộ định tuyến, Hàng xóm
	Thông báo chào mời, quảng cáo hàng xóm, chuyển hướng).
	8 bit này có thể được hiểu là 6 bit bậc cao chứa DSCP
	giá trị và 2 bit bậc thấp đại diện cho ECN (mà bạn có thể muốn
	để lại rõ ràng).

* 0 - (mặc định)

ndisc_evict_nocarrier - BOOLEAN
	Xóa bảng khám phá hàng xóm trong các sự kiện NOCARRIER. Tùy chọn này là
	quan trọng đối với các thiết bị không dây nơi bộ nhớ đệm khám phá hàng xóm sẽ
	không bị xóa khi chuyển vùng giữa các điểm truy cập trên cùng một mạng.
	Trong hầu hết các trường hợp, giá trị này sẽ được giữ nguyên như mặc định (1).

Các giá trị có thể:

- 0 (đã tắt) - Không xóa bộ nhớ đệm khám phá hàng xóm trên các sự kiện NOCARRIER.
	- 1 (đã bật) - Xóa bộ đệm phát hiện hàng xóm trên các sự kiện NOCARRIER.

Mặc định: 1 (đã bật)

mldv1_unsolicited_report_interval - INTEGER
	Khoảng thời gian tính bằng mili giây trong đó lần gửi tiếp theo không được yêu cầu
	Việc truyền lại báo cáo MLDv1 sẽ diễn ra.

Mặc định: 10000 (10 giây)

mldv2_unsolicited_report_interval - INTEGER
	Khoảng thời gian tính bằng mili giây trong đó lần gửi tiếp theo không được yêu cầu
	Việc truyền lại báo cáo MLDv2 sẽ diễn ra.

Mặc định: 1000 (1 giây)

lực_mld_version - INTEGER
	* 0 - (mặc định) Không thực thi phiên bản MLD, cho phép dự phòng MLDv1
	* 1 - Buộc sử dụng MLD phiên bản 1
	* 2 - Buộc sử dụng MLD phiên bản 2

đàn áp_frag_ndisc - INTEGER
	Kiểm soát RFC 6980 (Ý nghĩa bảo mật của phân mảnh IPv6
	với hành vi IPv6 Neighbor Discovery):

* 1 - (mặc định) loại bỏ các gói khám phá hàng xóm bị phân mảnh
	* 0 - cho phép các gói khám phá hàng xóm bị phân mảnh

lạc quan_dad - BOOLEAN
	Có thực hiện Phát hiện địa chỉ trùng lặp lạc quan hay không (RFC 4429)

Tính năng phát hiện địa chỉ trùng lặp lạc quan cho giao diện sẽ được bật
	nếu ít nhất một trong số conf/{all,interface}/optimistic_dad được đặt thành 1,
	nếu không nó sẽ bị vô hiệu hóa.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)


use_optimistic - BOOLEAN
	Nếu được bật, không phân loại các địa chỉ lạc quan là không được dùng nữa trong
	lựa chọn địa chỉ nguồn.  Địa chỉ ưa thích vẫn sẽ được chọn
	trước các địa chỉ lạc quan, tùy thuộc vào xếp hạng khác trong nguồn
	thuật toán chọn địa chỉ.

Điều này sẽ được kích hoạt nếu ít nhất một trong
	conf/{all,interface}/use_optimistic được đặt thành 1, nếu không thì bị tắt.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

ổn định_secret - địa chỉ IPv6
	Địa chỉ IPv6 này sẽ được sử dụng làm bí mật để tạo IPv6
	địa chỉ cho các địa chỉ liên kết cục bộ và được cấu hình tự động
	những cái đó. Tất cả các địa chỉ được tạo sau khi thiết lập bí mật này sẽ
	theo mặc định là quyền riêng tư ổn định. Điều này có thể được thay đổi thông qua
	liên kết ip addrgenmode. conf/default/stable_secret được sử dụng làm
	bí mật cho không gian tên, giao diện cụ thể có thể
	ghi đè lên đó. Việc ghi vào conf/all/stable_secret bị từ chối.

Nên tạo bí mật này trong khi cài đặt
	của một hệ thống và giữ cho nó ổn định sau đó.

Theo mặc định, bí mật ổn định không được đặt.

addr_gen_mode - INTEGER
	Xác định cách tạo địa chỉ link-local và autoconf.

= ======================================================================
	0 tạo địa chỉ dựa trên EUI64 (mặc định)
	1 không tạo địa chỉ liên kết cục bộ, sử dụng EUI64 cho địa chỉ
	   được tạo từ autoconf
	2 tạo địa chỉ riêng tư ổn định, sử dụng bí mật từ
	   ổn định_secret (RFC7217)
	3 tạo địa chỉ bảo mật ổn định, sử dụng bí mật ngẫu nhiên nếu không được đặt
	= ======================================================================

drop_unicast_in_l2_multicast - BOOLEAN
	Loại bỏ mọi gói IPv6 unicast được nhận trong lớp liên kết
	khung multicast (hoặc quảng bá).

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

drop_không được yêu cầu_na - BOOLEAN
	Bỏ tất cả các quảng cáo hàng xóm không được yêu cầu, ví dụ nếu có
	một proxy NA tốt đã được biết đến trên mạng và các khung như vậy không cần phải được sử dụng
	(hoặc trong trường hợp 802.11, không được sử dụng để ngăn chặn các cuộc tấn công.)

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (bị tắt).

chấp nhận_untracked_na - INTEGER
	Xác định hành vi chấp nhận quảng cáo hàng xóm từ các thiết bị
	không có trong bộ đệm hàng xóm:

- 0 - (mặc định) Không chấp nhận hàng xóm không được yêu cầu và không bị theo dõi
	  quảng cáo.

- 1 - Thêm mục nhập bộ đệm lân cận mới ở trạng thái STALE cho các bộ định tuyến trên
	  nhận được quảng cáo hàng xóm (được yêu cầu hoặc không được yêu cầu)
	  với tùy chọn địa chỉ lớp liên kết đích được chỉ định nếu không có mục nhập lân cận
	  đã có sẵn cho địa chỉ IPv6 được quảng cáo. Nếu không có núm này,
	  NA nhận được cho các địa chỉ không được theo dõi (không có trong bộ đệm lân cận) là
	  im lặng phớt lờ.

Đây là hành vi phía bộ định tuyến được ghi lại trong RFC9131.

Điều này có mức độ ưu tiên thấp hơn drop_unsolicited_na.

Điều này sẽ tối ưu hóa đường dẫn trở lại cho liên kết ngoại tuyến ban đầu
	  giao tiếp được bắt đầu bởi một máy chủ được kết nối trực tiếp, bởi
	  đảm bảo rằng bộ định tuyến bước nhảy đầu tiên bật cài đặt này không
	  phải đệm các gói trả về ban đầu để thực hiện việc chào mời hàng xóm.
	  Điều kiện tiên quyết là máy chủ được cấu hình để gửi không theo yêu cầu
	  quảng cáo hàng xóm trên giao diện mang lại. Cài đặt này phải được
	  được sử dụng cùng với cài đặt ndisc_notify trên máy chủ để
	  thỏa mãn điều kiện tiên quyết này.

- 2 - Tùy chọn mở rộng (1) để thêm mục nhập bộ đệm lân cận mới chỉ nếu
	  địa chỉ IP nguồn nằm trong cùng mạng con với địa chỉ được định cấu hình trên
	  giao diện nhận được quảng cáo hàng xóm.

nâng cao_dad - BOOLEAN
	Bao gồm tùy chọn nonce trong các thông báo mời hàng xóm IPv6 được sử dụng cho
	phát hiện địa chỉ trùng lặp trên mỗi RFC7527. DAD NS nhận được sẽ chỉ phát tín hiệu
	một địa chỉ trùng lặp nếu nonce khác. Điều này tránh mọi sai lầm
	phát hiện các bản sao do lặp lại các tin nhắn NS mà chúng tôi gửi.
	Tùy chọn nonce sẽ được gửi trên một giao diện trừ khi cả hai
	conf/{all,interface}/enhanced_dad được đặt thành FALSE.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)

ZZ0000ZZ:
===========

giới hạn tỷ lệ - INTEGER
	Giới hạn tốc độ tối đa để gửi tin nhắn ICMPv6 tới một địa chỉ cụ thể
	ngang hàng.

0 để vô hiệu hóa mọi giới hạn,
	nếu không thì khoảng cách giữa các phản hồi tính bằng mili giây.

Mặc định: 100

ratemask - danh sách các phạm vi được phân tách bằng dấu phẩy
	Đối với các loại thông báo ICMPv6 khớp với phạm vi trong mặt nạ tốc độ, hãy giới hạn
	việc gửi tin nhắn theo tham số ratelimit.

Định dạng được sử dụng cho cả đầu vào và đầu ra được phân tách bằng dấu phẩy
	danh sách các phạm vi (ví dụ: "0-127.129" cho loại tin nhắn ICMPv6 từ 0 đến 127 và
	129). Việc ghi vào tệp sẽ xóa tất cả các phạm vi ICMPv6 trước đó
	loại thông báo và cập nhật danh sách hiện tại với đầu vào.

Tham khảo: ZZ0000ZZ
	đối với các giá trị số của loại thông báo ICMPv6, ví dụ: yêu cầu echo là 128
	và phản hồi echo là 129.

Mặc định: 0-1,3-127 (giới hạn tỷ lệ lỗi ICMPv6 ngoại trừ Packet Too Big)

echo_ignore_all - BOOLEAN
	Nếu được bật thì kernel sẽ bỏ qua tất cả ICMP ECHO
	yêu cầu được gửi đến nó qua giao thức IPv6.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

echo_ignore_multicast - BOOLEAN
	Nếu được bật thì kernel sẽ bỏ qua tất cả ICMP ECHO
	các yêu cầu được gửi tới nó qua giao thức IPv6 thông qua multicast.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

echo_ignore_anycast - BOOLEAN
	Nếu được bật thì kernel sẽ bỏ qua tất cả ICMP ECHO
	các yêu cầu được gửi tới nó qua giao thức IPv6 được gửi đến địa chỉ Anycast.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

error_anycast_as_unicast - BOOLEAN
	Nếu được bật thì kernel sẽ phản hồi với Lỗi ICMP
	kết quả từ các yêu cầu được gửi tới nó qua giao thức IPv6 được định sẵn
	đến địa chỉ Anycast về cơ bản coi Anycast là unicast.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 0 (đã tắt)

lỗi_extension_mask - UNSIGNED INTEGER
	Bitmask của phần mở rộng ICMP để thêm vào thông báo lỗi ICMPv6
	("Không thể truy cập đích" và "Đã vượt quá thời gian"). Gói dữ liệu gốc
	được cắt bớt/ độn xuống còn 128 byte để tương thích với
	các ứng dụng không tuân thủ RFC 4884.

Các phần mở rộng có thể có là:

==== ====================================================================
	0x01 Thông tin giao diện IP đến theo RFC 5837.
	     Tiện ích mở rộng sẽ bao gồm chỉ mục, địa chỉ IPv6 (nếu có),
	     tên và MTU của giao diện IP đã nhận datagram
	     đã gây ra lỗi ICMP.
	==== ====================================================================

Mặc định: 0x00 (không có phần mở rộng)

xfrm6_gc_thresh - INTEGER
	(Lỗi thời kể từ linux-4.14)
	Ngưỡng mà chúng tôi sẽ bắt đầu thu thập rác cho IPv6
	mục bộ đệm đích.  Với giá trị gấp đôi này, hệ thống sẽ
	từ chối phân bổ mới


Cập nhật IPv6 bởi:
Pekka Savola <pekkas@netcore.fi>
Dự án YOSHIFUJI Hideaki / USAGI <yoshfuji@linux-ipv6.org>


/proc/sys/net/bridge/* Các biến:
=================================

bridge-nf-call-arptables - BOOLEAN

Các giá trị có thể:

- 0 (đã tắt) - tắt cái này đi.
	- 1 (đã bật) - chuyển lưu lượng ARP được bắc cầu tới chuỗi FORWARD của arptables.

Mặc định: 1 (đã bật)

bridge-nf-call-iptables - BOOLEAN

Các giá trị có thể:

- 0 (đã tắt) - tắt cái này đi.
	- 1 (đã bật) - chuyển lưu lượng IPv4 bắc cầu tới chuỗi của iptables.

Mặc định: 1 (đã bật)

bridge-nf-call-ip6tables - BOOLEAN

Các giá trị có thể:

- 0 (đã tắt) - tắt cái này đi.
	- 1 (đã bật) - chuyển lưu lượng IPv6 được bắc cầu tới chuỗi của ip6tables.

Mặc định: 1 (đã bật)

bridge-nf-filter-vlan-tagged - BOOLEAN

Các giá trị có thể:

- 0 (đã tắt) - tắt cái này đi.
	- 1 (đã bật) - chuyển lưu lượng truy cập ARP/IP/IPv6 được gắn thẻ vlan tới các bảng {arp,ip,ip6}

Mặc định: 0 (đã tắt)

bridge-nf-filter-pppoe-tagged - BOOLEAN

Các giá trị có thể:

- 0 (đã tắt) - tắt cái này đi.
	- 1 (đã bật) - chuyển lưu lượng truy cập IP/IPv6 được gắn thẻ pppoe tới các bảng {ip,ip6}.

Mặc định: 0 (đã tắt)

cầu-nf-pass-vlan-input-dev - BOOLEAN
	- 1: nếu bridge-nf-filter-vlan-tagged được bật, hãy thử tìm vlan
	  giao diện trên bridge và đặt thiết bị đầu vào netfilter thành
	  vlan. Điều này cho phép sử dụng ví dụ: "iptables -i br0.1" và tạo
	  Mục tiêu REDIRECT hoạt động với giao diện vlan-on-top-of-bridge.  Khi không
	  tìm thấy giao diện vlan phù hợp hoặc công tắc này tắt, đầu vào
	  thiết bị được đặt thành giao diện cầu nối.

- 0: vô hiệu hóa tra cứu giao diện bridge netfilter vlan.

Mặc định: 0

Biến ZZ0000ZZ:
==================================

addip_enable - BOOLEAN
	Bật hoặc tắt tiện ích mở rộng Cấu hình lại địa chỉ động
	(ADD-IP) chức năng được chỉ định trong RFC5061.  Phần mở rộng này cung cấp
	khả năng tự động thêm và xóa địa chỉ mới cho SCTP
	hiệp hội.

Các giá trị có thể:

- 0 (đã tắt) - tắt tiện ích mở rộng.
	- 1 (đã bật) - bật tiện ích mở rộng

Mặc định: 0 (đã tắt)

pf_enable - INTEGER
	Bật hoặc tắt trạng thái pf (pf là viết tắt của trạng thái có khả năng bị lỗi). Một giá trị
	của pf_retrans > path_max_retrans cũng vô hiệu hóa trạng thái pf. Tức là một trong
	cả pf_enable và pf_retrans > path_max_retrans đều có thể tắt trạng thái pf.
	Vì pf_retrans và path_max_retrans có thể được thay đổi bởi không gian người dùng
	ứng dụng, đôi khi người dùng muốn tắt trạng thái pf bằng giá trị của
	pf_retrans > path_max_retrans, nhưng đôi khi giá trị của pf_retrans
	hoặc path_max_retrans được ứng dụng người dùng thay đổi, trạng thái pf này là
	đã bật. Vì vậy, cần phải thêm phần này để kích hoạt động
	và vô hiệu hóa trạng thái pf. Xem:
	ZZ0000ZZ cho
	chi tiết.

Các giá trị có thể:

- 1: Kích hoạt pf.
	- 0: Tắt pf.

Mặc định: 1

pf_expose - INTEGER
	Bỏ đặt hoặc bật/tắt trạng thái pf (pf là viết tắt của trạng thái có khả năng bị lỗi)
	tiếp xúc.  Các ứng dụng có thể kiểm soát mức độ hiển thị của trạng thái đường dẫn PF
	trong sự kiện SCTP_PEER_ADDR_CHANGE và quyền truy cập trạng thái SCTP_PF
	thông tin vận chuyển qua sockopt SCTP_GET_PEER_ADDR_INFO.

Các giá trị có thể:

- 0: Bỏ đặt mức hiển thị trạng thái pf (tương thích với các ứng dụng cũ). Không
	  sự kiện sẽ được gửi nhưng thông tin vận chuyển có thể được truy vấn.
	- 1: Tắt hiển thị trạng thái pf. Sẽ không có sự kiện nào được gửi và cố gắng
	  lấy thông tin vận chuyển sẽ trả về -EACCESS.
	- 2: Bật hiển thị trạng thái pf. Sự kiện sẽ được gửi đi để vận chuyển
	  trở thành trạng thái SCTP_PF và thông tin vận chuyển có thể được lấy.

Mặc định: 0

addip_noauth_enable - BOOLEAN
	Cấu hình lại địa chỉ động (ADD-IP) yêu cầu sử dụng
	xác thực để bảo vệ các hoạt động thêm hoặc xóa mới
	địa chỉ.  Yêu cầu này là bắt buộc để các máy chủ trái phép
	sẽ không thể chiếm quyền điều khiển các hiệp hội.  Tuy nhiên, lớn tuổi hơn
	việc triển khai có thể chưa thực hiện được yêu cầu này trong khi
	cho phép phần mở rộng ADD-IP.  Vì lý do khả năng tương tác,
	chúng tôi cung cấp biến này để kiểm soát việc thực thi
	yêu cầu xác thực.

======================================================================
	1 Cho phép sử dụng tiện ích mở rộng ADD-IP mà không cần xác thực.  Cái này
	   chỉ nên đặt trong môi trường khép kín để có khả năng tương tác
	   với các triển khai cũ hơn.

0 Thực thi yêu cầu xác thực
	======================================================================

Mặc định: 0

auth_enable - BOOLEAN
	Bật hoặc tắt tiện ích mở rộng Chunks đã xác thực.  Phần mở rộng này
	cung cấp khả năng gửi và nhận các khối được xác thực và
	cần thiết để vận hành an toàn Cấu hình lại địa chỉ động
	(ADD-IP) phần mở rộng.

Các giá trị có thể:

- 0 (đã tắt) - tắt tiện ích mở rộng.
	- 1 (đã bật) - bật tiện ích mở rộng

Mặc định: 0 (đã tắt)

prsctp_enable - BOOLEAN
	Bật hoặc tắt tiện ích mở rộng Độ tin cậy một phần (RFC3758)
	được sử dụng để thông báo cho các đồng nghiệp rằng DATA nhất định sẽ không còn được mong đợi nữa.

Các giá trị có thể:

- 0 (đã tắt) - tắt tiện ích mở rộng.
	- 1 (đã bật) - bật tiện ích mở rộng

Mặc định: 1 (đã bật)

max_burst - INTEGER
	Giới hạn số lượng gói mới có thể được gửi ban đầu.  Nó
	kiểm soát mức độ bùng nổ của lưu lượng truy cập được tạo.

Mặc định: 4

hiệp hội_max_retrans - INTEGER
	Đặt số lần truyền lại tối đa mà một liên kết có thể
	cố gắng quyết định rằng đầu từ xa không thể truy cập được.  Nếu giá trị này
	vượt quá, sự liên kết bị chấm dứt.

Mặc định: 10

max_init_retransmits - INTEGER
	Số lần truyền lại tối đa của các khối INIT và COOKIE-ECHO
	mà một hiệp hội sẽ thử trước khi khai báo điểm đến
	không thể truy cập và chấm dứt.

Mặc định: 8

path_max_retrans - INTEGER
	Số lần truyền lại tối đa sẽ được thử trên một địa chỉ nhất định
	con đường.  Khi vượt quá ngưỡng này, đường dẫn được coi là
	không thể truy cập được và lưu lượng truy cập mới sẽ sử dụng một đường dẫn khác khi
	hiệp hội là nhiều nhà.

Mặc định: 5

pf_retrans - INTEGER
	Số lần truyền lại sẽ được thử trên một đường dẫn nhất định
	trước khi lưu lượng truy cập được chuyển hướng đến một phương tiện giao thông thay thế (nếu
	tồn tại).  Lưu ý rằng điều này khác với path_max_retrans, vì là đường dẫn
	vượt qua ngưỡng pf_retrans vẫn có thể được sử dụng.  chỉ của nó
	bị loại bỏ khi đường truyền được chọn bởi ngăn xếp.  Cái này
	cài đặt chủ yếu được sử dụng để kích hoạt cơ chế chuyển đổi dự phòng nhanh mà không cần
	phải giảm path_max_retrans xuống giá trị rất thấp.  Xem:
	ZZ0000ZZ
	để biết chi tiết.  Cũng lưu ý rằng giá trị của pf_retrans > path_max_retrans
	vô hiệu hóa tính năng này. Vì cả pf_retrans và path_max_retrans đều có thể
	được thay đổi bởi ứng dụng không gian người dùng, một biến pf_enable được sử dụng để
	vô hiệu hóa trạng thái pf.

Mặc định: 0

ps_retrans - INTEGER
	Primary.Switchover.Max.Retrans (PSMR), đây là một tham số có thể điều chỉnh sắp ra mắt
	từ phần 5 "Chuyển đổi đường dẫn chính" trong rfc7829.  Đường dẫn chính
	sẽ được thay đổi thành một đường dẫn hoạt động khác khi bộ đếm lỗi đường dẫn bật
	đường dẫn chính cũ vượt quá PSMR, do đó "người gửi SCTP được phép
	để tiếp tục truyền dữ liệu trên đường làm việc mới ngay cả khi đường làm việc cũ
	địa chỉ đích chính sẽ hoạt động trở lại".   Lưu ý tính năng này
	bị vô hiệu hóa bằng cách khởi tạo 'ps_retrans' trên mỗi mạng dưới dạng 0xffff theo mặc định,
	và giá trị của nó không được nhỏ hơn 'pf_retrans' khi thay đổi bằng sysctl.

Mặc định: 0xffff

rto_initial - INTEGER
	Giá trị thời gian chờ khứ hồi ban đầu tính bằng mili giây sẽ được sử dụng
	trong việc tính toán thời gian khứ hồi.  Đây là khoảng thời gian ban đầu
	cho việc truyền lại.

Mặc định: 3000

rto_max - INTEGER
	Giá trị tối đa (tính bằng mili giây) của thời gian chờ khứ hồi.  Cái này
	là khoảng thời gian lớn nhất có thể trôi qua giữa các lần truyền lại.

Mặc định: 60000

rto_min - INTEGER
	Giá trị tối thiểu (tính bằng mili giây) của thời gian chờ khứ hồi.  Cái này
	là khoảng thời gian nhỏ nhất có thể trôi qua giữa các lần truyền lại.

Mặc định: 1000

hb_interval - INTEGER
	Khoảng thời gian (tính bằng mili giây) giữa các khối HEARTBEAT.  Những khối này
	được gửi vào khoảng thời gian xác định trên các đường dẫn nhàn rỗi để thăm dò trạng thái của
	một đường dẫn nhất định giữa 2 hiệp hội.

Mặc định: 30000

bao_timeout - INTEGER
	Lượng thời gian (tính bằng mili giây) mà quá trình triển khai sẽ chờ
	để gửi SACK.

Mặc định: 200

valid_cookie_life - INTEGER
	Thời gian tồn tại mặc định của cookie SCTP (tính bằng mili giây).  cái bánh quy
	được sử dụng trong quá trình thành lập hiệp hội.

Mặc định: 60000

cookie_preserve_enable - BOOLEAN
	Bật hoặc tắt khả năng kéo dài tuổi thọ của cookie SCTP
	được sử dụng trong giai đoạn thiết lập liên kết SCTP

Các giá trị có thể:

- 0 (bị vô hiệu hóa) - vô hiệu hóa.
	- 1 (đã bật) - bật tiện ích mở rộng thời gian tồn tại của cookie.

Mặc định: 1 (đã bật)

cookie_hmac_alg - STRING
	Chọn thuật toán hmac được sử dụng khi tạo giá trị cookie được gửi bởi
	một ổ cắm sctp đang nghe tới máy khách đang kết nối trong đoạn INIT-ACK.
	Các giá trị hợp lệ là:

* sha256
	* không có

Mặc định: sha256

rcvbuf_policy - INTEGER
	Xác định xem bộ đệm nhận được quy cho ổ cắm hay cho
	hiệp hội.   SCTP hỗ trợ khả năng tạo nhiều
	các liên kết trên một ổ cắm duy nhất.  Khi sử dụng khả năng này, nó
	có thể là một liên kết bị đình trệ đang tải rất nhiều
	dữ liệu có thể chặn các hiệp hội khác cung cấp dữ liệu của họ bằng cách
	tiêu thụ hết không gian bộ đệm nhận.  Để giải quyết vấn đề này,
	RCvbuf_policy có thể được đặt để phân bổ không gian bộ đệm của máy thu
	đến mỗi liên kết thay vì ổ cắm.  Điều này ngăn cản mô tả
	chặn.

- 1: không gian RCvbuf cho mỗi liên kết
	- 0: không gian RCvbuf trên mỗi ổ cắm

Mặc định: 0

sndbuf_policy - INTEGER
	Tương tự như rcvbuf_policy ở trên, điều này áp dụng để gửi dung lượng bộ đệm.

- 1: Bộ đệm gửi được theo dõi trên mỗi liên kết
	- 0: Bộ đệm gửi được theo dõi trên mỗi ổ cắm.

Mặc định: 0

sctp_mem - vectơ 3 INTEGER: tối thiểu, áp suất, tối đa
	Số lượng trang được phép xếp hàng bởi tất cả các ổ cắm SCTP.

* min: Dưới số trang này SCTP không bận tâm về nó
	  sử dụng bộ nhớ. Khi dung lượng bộ nhớ được phân bổ bởi SCTP vượt quá
	  con số này, SCTP bắt đầu giảm mức sử dụng bộ nhớ.
	* áp lực: Giá trị này được giới thiệu theo định dạng của tcp_mem.
	*max: Số lượng trang tối đa cho phép.

Mặc định được tính khi khởi động từ dung lượng bộ nhớ khả dụng.

sctp_rmem - vectơ 3 INTEGER: tối thiểu, mặc định, tối đa
	Chỉ giá trị đầu tiên ("min") được sử dụng, "mặc định" và "tối đa" là
	bị phớt lờ.

* min: Kích thước tối thiểu của bộ đệm nhận được sử dụng bởi ổ cắm SCTP.
	  Nó được đảm bảo cho từng ổ cắm SCTP (nhưng không liên kết) ngay cả
	  dưới áp lực bộ nhớ vừa phải.

Mặc định: 4K

sctp_wmem - vectơ 3 INTEGER: tối thiểu, mặc định, tối đa
	Chỉ giá trị đầu tiên ("min") được sử dụng, "mặc định" và "tối đa" là
	bị phớt lờ.

* tối thiểu: Kích thước tối thiểu của bộ đệm gửi có thể được sử dụng bởi ổ cắm SCTP.
	  Nó được đảm bảo cho từng ổ cắm SCTP (nhưng không liên kết) ngay cả
	  dưới áp lực bộ nhớ vừa phải.

Mặc định: 4K

addr_scope_policy - INTEGER
	Kiểm soát phạm vi địa chỉ IPv4 (xem
	ZZ0000ZZ
	để biết chi tiết).

- 0 - Tắt phạm vi địa chỉ IPv4
	- 1 - Kích hoạt phạm vi địa chỉ IPv4
	- 2 - Thực hiện theo dự thảo nhưng cho phép địa chỉ riêng IPv4
	- 3 - Thực hiện theo dự thảo nhưng cho phép địa chỉ cục bộ liên kết IPv4

Mặc định: 1

udp_port - INTEGER
	Cổng nghe cho tất đường hầm UDP cục bộ. Thông thường nó là
	sử dụng số cổng UDP được chỉ định cho IANA là 9899 (đường hầm sctp).

Chiếc tất UDP này được sử dụng để xử lý gói UDP được đóng gói đến
	Các gói SCTP (từ RFC6951) và được chia sẻ bởi tất cả các ứng dụng trong
	cùng một không gian tên mạng. Chiếc tất UDP này sẽ bị đóng khi giá trị là
	đặt thành 0.

Giá trị này cũng sẽ được sử dụng để đặt cổng src của tiêu đề UDP
	đối với các gói SCTP được đóng gói UDP gửi đi. Đối với cảng đích,
	vui lòng tham khảo 'encap_port' bên dưới.

Mặc định: 0

encap_port - INTEGER
	Cổng đóng gói UDP từ xa mặc định.

Giá trị này được sử dụng để đặt cổng đích của tiêu đề UDP cho
	theo mặc định, các gói SCTP được đóng gói UDP gửi đi. Người dùng cũng có thể
	thay đổi giá trị cho mỗi sock/asoc/transport bằng cách sử dụng setsockopt.
	Để biết thêm thông tin, vui lòng tham khảo RFC6951.

Lưu ý rằng khi kết nối với máy chủ từ xa, máy khách nên đặt
	cổng này tới cổng mà đường hầm UDP trên máy chủ ngang hàng đang sử dụng
	nghe và tất đường hầm UDP cục bộ trên máy khách cũng
	phải được bắt đầu. Trên máy chủ, nó sẽ nhận được encap_port từ
	cổng nguồn của gói tin đến.

Mặc định: 0

plpmtud_probe_interval - INTEGER
        Khoảng thời gian (tính bằng mili giây) cho bộ hẹn giờ đầu dò PLPMTUD,
        được cấu hình để hết hạn sau khoảng thời gian này để nhận được
        xác nhận gói thăm dò. Đây cũng là khoảng thời gian
        giữa các đầu dò cho pmtu hiện tại khi tìm kiếm đầu dò
        đã xong.

PLPMTUD sẽ bị tắt khi 0 được đặt và các giá trị khác cho nó
        phải >= 5000.

Mặc định: 0

reconf_enable - BOOLEAN
        Bật hoặc tắt phần mở rộng của chức năng Cấu hình lại luồng
        được chỉ định trong RFC6525. Tiện ích mở rộng này cung cấp khả năng "đặt lại"
        một luồng và nó bao gồm các Tham số của "SSN đi/đến
        Đặt lại", "Đặt lại SSN/TSN" và "Thêm luồng đi/đến".

Các giá trị có thể:

- 0 (đã tắt) - Tắt tiện ích mở rộng.
	- 1 (đã bật) - Kích hoạt tiện ích mở rộng.

Mặc định: 0 (đã tắt)

intl_enable - BOOLEAN
        Bật hoặc tắt phần mở rộng của chức năng xen kẽ tin nhắn của người dùng
        được chỉ định trong RFC8260. Tiện ích mở rộng này cho phép xen kẽ người dùng
        tin nhắn được gửi trên các luồng khác nhau. Khi bật tính năng này, I-DATA
        chunk sẽ thay thế chunk DATA để mang tin nhắn của người dùng nếu được hỗ trợ
        bởi người ngang hàng. Lưu ý để sử dụng tính năng này cần thiết lập tùy chọn này
        thành 1 và cũng cần đặt tùy chọn ổ cắm SCTP_FRAGMENT_INTERLEAVE thành 2
        và SCTP_INTERLEAVING_SUPPORTED lên 1.

Các giá trị có thể:

- 0 (đã tắt) - Tắt tiện ích mở rộng.
	- 1 (đã bật) - Kích hoạt tiện ích mở rộng.

Mặc định: 0 (đã tắt)

ecn_enable - BOOLEAN
        Kiểm soát việc sử dụng Thông báo tắc nghẽn rõ ràng (ECN) của SCTP.
        Giống như trong TCP, ECN chỉ được sử dụng khi cả hai đầu của kết nối SCTP
        cho biết sự hỗ trợ cho nó. Tính năng này rất hữu ích trong việc tránh tổn thất
        do tắc nghẽn bằng cách cho phép các bộ định tuyến hỗ trợ báo hiệu tắc nghẽn
        trước khi phải bỏ gói tin.

Các giá trị có thể:

- 0 (đã tắt) - Tắt ecn.
	- 1 (đã bật) - Bật ecn.

Mặc định: 1 (đã bật)

l3mdev_accept - BOOLEAN
	Việc bật tùy chọn này cho phép ổ cắm được liên kết "toàn cầu" hoạt động
	trên các miền chính L3 (ví dụ: VRF) với các gói có khả năng
	được nhận bất kể miền L3 mà chúng chứa trong đó
	bắt nguồn. Chỉ hợp lệ khi kernel được biên dịch bằng
	CONFIG_NET_L3_MASTER_DEV.

Các giá trị có thể:

- 0 (bị vô hiệu hóa)
	- 1 (đã bật)

Mặc định: 1 (đã bật)


ZZ0000ZZ
========================

Vui lòng xem: Documentation/admin-guide/sysctl/net.rst để biết mô tả về các mục này.


ZZ0000ZZ
========================

max_dgram_qlen - INTEGER
	Độ dài tối đa của hàng đợi nhận ổ cắm dgram

Mặc định: 10
