.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ipvs-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
IPvs-sysctl
============

/proc/sys/net/ipv4/vs/* Các biến:
==================================

am_droprate - INTEGER
	mặc định 10

Nó đặt tốc độ giảm chế độ luôn, được sử dụng ở chế độ 3
	của phòng thủ drop_rate.

amemthresh - INTEGER
	mặc định 1024

Nó đặt ngưỡng bộ nhớ khả dụng (tính bằng trang), tức là
	được sử dụng trong các phương thức phòng thủ tự động. Khi không có
	đủ bộ nhớ khả dụng, chiến lược tương ứng sẽ là
	được bật và biến được tự động đặt thành 2, nếu không
	chiến lược bị vô hiệu hóa và biến được đặt thành 1.

chỉ sao lưu - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Nếu được đặt, hãy tắt chức năng giám đốc trong khi máy chủ đang hoạt động.
	ở chế độ sao lưu để tránh các vòng lặp gói đối với các phương thức DR/TUN.

conn_lfactor - INTEGER
	Các giá trị có thể có: -8 (bảng lớn hơn) .. 8 (bảng nhỏ hơn)

Mặc định: -4

Kiểm soát kích thước của bảng băm kết nối dựa trên
	hệ số tải (số lượng kết nối trên mỗi nhóm bảng):

2^conn_lfactor = nút/nhóm

Kết quả là bảng sẽ tăng lên nếu tải tăng và co lại khi
	tải giảm trong khoảng 2^8 - 2^conn_tab_bits (mô-đun
	tham số).
	Giá trị là số ca trong đó các giá trị âm được chọn
	xô = (nút băm kết nối << -value) trong khi dương
	giá trị chọn nhóm = (nút băm kết nối >> giá trị). các
	giá trị âm làm giảm va chạm và giảm thời gian cho
	tra cứu nhưng tăng kích thước bảng. Các giá trị dương sẽ
	chịu được tải trên 100% khi sử dụng bàn nhỏ hơn
	được ưu tiên hơn với chi phí va chạm nhiều hơn. Nếu sử dụng NAT
	các kết nối xem xét việc giảm giá trị bằng một vì
	họ thêm hai nút vào bảng băm.

Ví dụ:
	-4: tăng nếu tải vượt quá 6% (nhóm = nút * 16)
	2: tăng nếu tải vượt quá 400% (nhóm = nút / 4)

conn_reuse_mode - INTEGER
	1 - mặc định

Kiểm soát cách ipv xử lý các kết nối được phát hiện
	tái sử dụng cổng. Nó là một bitmap, với các giá trị là:

0: vô hiệu hóa mọi xử lý đặc biệt khi sử dụng lại cổng. cái mới
	kết nối sẽ được gửi đến cùng một máy chủ thực sự đã được
	phục vụ kết nối trước đó.

bit 1: cho phép sắp xếp lại các kết nối mới khi an toàn.
	Nghĩa là, bất cứ khi nào hết hạn_nodest_conn và đối với ổ cắm TCP, khi
	kết nối ở trạng thái TIME_WAIT (điều này chỉ có thể thực hiện được nếu
	bạn sử dụng chế độ NAT).

bit 2: là bit 1 plus, đối với kết nối TCP, khi kết nối
	đang ở trạng thái FIN_WAIT, vì đây là trạng thái cuối cùng được nhìn thấy bởi tải
	bộ cân bằng ở chế độ Định tuyến trực tiếp. Bit này giúp thêm vào mới
	các máy chủ thực đến một cụm rất bận rộn.

conntrack - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Nếu được đặt, hãy duy trì các mục theo dõi kết nối cho
	các kết nối được xử lý bởi IPVS.

Điều này sẽ được kích hoạt nếu các kết nối được xử lý bởi IPVS
	cũng được xử lý bởi các quy tắc tường lửa có trạng thái. Tức là, quy tắc iptables
	sử dụng tính năng theo dõi kết nối.  Đó là một màn trình diễn
	tối ưu hóa để tắt cài đặt này nếu không.

Các kết nối được xử lý bởi mô-đun ứng dụng IPVS FTP
	sẽ có các mục theo dõi kết nối bất kể cài đặt này.

Chỉ khả dụng khi IPVS được biên dịch với CONFIG_IP_VS_NFCT được bật.

cache_bypass - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Nếu nó được bật, hãy chuyển tiếp gói đến đích ban đầu
	trực tiếp khi không có máy chủ bộ đệm và đích
	địa chỉ không phải là địa chỉ cục bộ (iph->daddr là RTN_UNICAST). Nó chủ yếu là
	được sử dụng trong cụm bộ đệm web trong suốt.

debug_level - INTEGER
	- 0 - thông báo lỗi truyền tải (mặc định)
	- 1 - thông báo lỗi không nghiêm trọng
	- 2 - cấu hình
	- 3 - thùng rác đích
	- 4 - thả mục
	- 5 - tra cứu dịch vụ
	- 6 - lập kế hoạch
	- 7 - kết nối mới/hết hạn, tra cứu và đồng bộ hóa
	- 8 - chuyển trạng thái
	- 9 - đích ràng buộc, kiểm tra mẫu và ứng dụng
	- 10 - Truyền gói IPVS
	- 11 - IPVS xử lý gói tin (ip_vs_in/ip_vs_out)
	- 12 hoặc nhiều hơn - truyền gói

Chỉ khả dụng khi IPVS được biên dịch với CONFIG_IP_VS_DEBUG được bật.

Mức độ gỡ lỗi cao hơn bao gồm các thông báo gỡ lỗi thấp hơn
	cấp độ, do đó, cài đặt gỡ lỗi cấp độ 2, bao gồm cấp độ 0, 1 và 2
	tin nhắn. Do đó, việc ghi nhật ký ngày càng dài dòng hơn.
	mức độ.

drop_entry - INTEGER
	- 0 - bị vô hiệu hóa (mặc định)

Việc bảo vệ drop_entry là thả ngẫu nhiên các mục trong
	bảng băm kết nối, chỉ để thu thập lại một số
	bộ nhớ cho các kết nối mới. Trong mã hiện tại,
	Thủ tục drop_entry có thể được kích hoạt mỗi giây, sau đó nó
	quét ngẫu nhiên 1/32 toàn bộ và bỏ các mục có trong
	trạng thái SYN-RECV/SYNACK, sẽ có hiệu quả chống lại
	cuộc tấn công đồng loạt.

Các giá trị hợp lệ của drop_entry là từ 0 đến 3, trong đó 0 có nghĩa là
	rằng chiến lược này luôn bị vô hiệu hóa, 1 và 2 có nghĩa là tự động
	các chế độ (khi không có đủ bộ nhớ khả dụng, chiến lược
	được bật và biến được tự động đặt thành 2,
	nếu không thì chiến lược sẽ bị vô hiệu hóa và biến được đặt thành
	1) và 3 có nghĩa là chiến lược luôn được kích hoạt.

drop_packet - INTEGER
	- 0 - bị vô hiệu hóa (mặc định)

Cơ chế phòng thủ drop_packet được thiết kế để loại bỏ các gói 1/tỷ lệ
	trước khi chuyển tiếp chúng đến các máy chủ thực sự. Nếu tỷ lệ là 1 thì
	loại bỏ tất cả các gói tin đến.

Định nghĩa giá trị giống với định nghĩa của drop_entry. trong
	ở chế độ tự động, tốc độ được xác định như sau
	công thức: rate = amemthresh / (amemthresh - available_memory)
	khi bộ nhớ khả dụng nhỏ hơn bộ nhớ khả dụng
	ngưỡng. Khi chế độ 3 được đặt, tốc độ giảm chế độ luôn
	được điều khiển bởi /proc/sys/net/ipv4/vs/am_droprate.

est_cpulist - CPULIST
	CPU được phép để ước tính kthread

Cú pháp: định dạng cpulist tiêu chuẩn
	danh sách trống - dừng các tác vụ và ước tính kthread
	mặc định - CPU quản lý hệ thống cho kthread

Ví dụ:
	"all": tất cả các CPU có thể
	"0-N": tất cả các CPU có thể, N biểu thị số CPU cuối cùng
	"0,1-N:1/2": đầu tiên và tất cả các CPU có số lẻ
	"": danh sách trống

est_nice - INTEGER
	mặc định 0
	Phạm vi hợp lệ: -20 (thuận lợi hơn) .. 19 (kém thuận lợi hơn)

Giá trị độ đẹp được sử dụng cho các kthread ước tính (lập kế hoạch
	ưu tiên)

hết hạn_nodest_conn - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Giá trị mặc định là 0, cân bằng tải sẽ âm thầm giảm
	gói tin khi máy chủ đích của nó không có sẵn. Nó có thể
	hữu ích khi chương trình giám sát không gian người dùng xóa
	máy chủ đích (do máy chủ quá tải hoặc sai
	phát hiện) và thêm lại máy chủ sau và các kết nối
	đến máy chủ có thể tiếp tục.

Nếu tính năng này được bật, bộ cân bằng tải sẽ hết hạn
	kết nối ngay lập tức khi một gói đến và
	máy chủ đích không có sẵn thì chương trình máy khách sẽ
	sẽ được thông báo rằng kết nối đã bị đóng. Đây là
	tương đương với tính năng mà một số người yêu cầu để xả nước
	kết nối khi đích đến của nó không có sẵn.

hết hạn_quiescent_template - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Khi được đặt thành giá trị khác 0, bộ cân bằng tải sẽ hết hạn
	các mẫu liên tục khi máy chủ đích không hoạt động.
	Điều này có thể hữu ích khi người dùng tạo một máy chủ đích
	không hoạt động bằng cách đặt trọng số của nó thành 0 và mong muốn rằng
	các kết nối liên tục tiếp theo sẽ được gửi đến một
	máy chủ đích khác nhau.  Theo mặc định mới liên tục
	kết nối được phép đến các máy chủ đích không hoạt động.

Nếu tính năng này được bật, bộ cân bằng tải sẽ hết hạn
	mẫu kiên trì nếu nó được sử dụng để lập kế hoạch mới
	kết nối và máy chủ đích không hoạt động.

bỏ qua_tunneled - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Nếu được đặt, ipvs sẽ đặt ipvs_property trên tất cả các gói thuộc
	giao thức không được công nhận.  Điều này ngăn chúng tôi định tuyến theo đường hầm
	các giao thức như ipip, rất hữu ích để ngăn chặn việc sắp xếp lại
	các gói đã được chuyển đến máy chủ ipvs (tức là để ngăn chặn
	vòng lặp định tuyến ipvs khi ipvs cũng hoạt động như một máy chủ thực sự).

nat_icmp_send - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Nó kiểm soát việc gửi thông báo lỗi icmp (ICMP_DEST_UNREACH)
	dành cho VS/NAT khi bộ cân bằng tải nhận gói từ mạng thực
	máy chủ nhưng các mục kết nối không tồn tại.

pmtu_disc - BOOLEAN
	- 0 - bị vô hiệu hóa
	- không phải 0 - đã bật (mặc định)

Theo mặc định, từ chối với FRAG_NEEDED tất cả các gói DF vượt quá
	PMTU, bất kể phương thức chuyển tiếp. Đối với phương pháp TUN
	cờ có thể bị vô hiệu hóa để phân mảnh các gói như vậy.

an toàn_tcp - INTEGER
	- 0 - bị vô hiệu hóa (mặc định)

Cách bảo vệ safe_tcp là sử dụng trạng thái TCP phức tạp hơn
	bảng chuyển tiếp. Đối với VS/NAT, nó cũng trì hoãn việc nhập
	Trạng thái TCP ESTABLISHED cho đến khi quá trình bắt tay ba bước hoàn tất.

Định nghĩa giá trị giống như định nghĩa của drop_entry và
	drop_packet.

svc_lfactor - INTEGER
	Các giá trị có thể có: -8 (bảng lớn hơn) .. 8 (bảng nhỏ hơn)

Mặc định: -3

Kiểm soát kích thước của bảng băm dịch vụ dựa trên
	hệ số tải (số lượng dịch vụ trên mỗi nhóm bảng). cái bàn
	sẽ tăng trưởng và co lại trong khoảng 2^4 - 2^20.
	Xem conn_lfactor để được giải thích.

sync_threshold - vectơ của 2 INTEGER: sync_threshold, sync_ Period
	mặc định 3 50

Nó đặt ngưỡng đồng bộ hóa, là số lượng tối thiểu
	của các gói đến mà kết nối cần nhận trước khi
	kết nối sẽ được đồng bộ hóa. Một kết nối sẽ được
	được đồng bộ hóa, mỗi khi số lượng gói tin đến của nó
	mô-đun sync_ Period bằng với ngưỡng. Phạm vi của
	ngưỡng là từ 0 đến sync_ Period.

Khi sync_ Period và sync_refresh_ Period bằng 0, chỉ gửi đồng bộ hóa
	để thay đổi trạng thái hoặc chỉ một lần khi gói khớp với ngưỡng sync_threshold

đồng bộ_refresh_thời gian - UNSIGNED INTEGER
	mặc định 0

Tính bằng giây, sự khác biệt về bộ đếm thời gian kết nối được báo cáo sẽ kích hoạt
	tin nhắn đồng bộ mới. Nó có thể được sử dụng để tránh các tin nhắn đồng bộ cho
	khoảng thời gian được chỉ định (hoặc một nửa thời gian chờ kết nối nếu thấp hơn)
	nếu trạng thái kết nối không thay đổi kể từ lần đồng bộ hóa cuối cùng.

Điều này rất hữu ích cho các kết nối bình thường với lưu lượng truy cập cao để giảm
	tốc độ đồng bộ hóa. Ngoài ra, hãy thử lại sync_retries lần với khoảng thời gian
	sync_refresh_ Period/8.

sync_retries - INTEGER
	mặc định 0

Xác định số lần thử đồng bộ hóa với khoảng thời gian sync_refresh_ Period/8. Hữu ích
	để bảo vệ chống mất tin nhắn đồng bộ. Phạm vi của
	sync_retries là từ 0 đến 3.

sync_qlen_max - UNSIGNED LONG

Giới hạn cứng đối với các tin nhắn đồng bộ hóa được xếp hàng đợi chưa được gửi. Nó
	mặc định là 1/32 trang bộ nhớ nhưng thực tế đại diện cho
	số lượng tin nhắn. Nó sẽ bảo vệ chúng ta khỏi việc phân bổ số tiền lớn
	các phần của bộ nhớ khi tốc độ gửi thấp hơn tốc độ xếp hàng
	tỷ lệ.

sync_sock_size - INTEGER
	mặc định 0

Cấu hình giới hạn ổ cắm SNDBUF (chính) hoặc RCVBUF (phụ).
	Giá trị mặc định là 0 (giữ nguyên giá trị mặc định của hệ thống).

cổng đồng bộ - INTEGER
	mặc định 1

Số lượng luồng mà máy chủ chính và máy chủ dự phòng có thể sử dụng cho
	đồng bộ lưu lượng. Mỗi luồng sẽ sử dụng một cổng UDP, luồng 0 sẽ
	sử dụng cổng mặc định 8848 trong khi luồng cuối cùng sẽ sử dụng cổng
	8848+sync_ports-1.

snat_reroute - BOOLEAN
	- 0 - bị vô hiệu hóa
	- không phải 0 - đã bật (mặc định)

Nếu được bật, hãy tính toán lại lộ trình của các gói SNATed từ
	máy chủ thực để chúng được định tuyến như thể chúng bắt nguồn từ
	giám đốc. Ngược lại chúng sẽ được định tuyến như thể chúng được chuyển tiếp bởi
	giám đốc.

Nếu định tuyến chính sách có hiệu lực thì có thể tuyến đường đó
	của một gói có nguồn gốc từ một giám đốc được định tuyến khác với một
	gói được chuyển tiếp bởi giám đốc.

Nếu định tuyến chính sách không có hiệu lực thì tuyến được tính toán lại sẽ
	luôn giống với lộ trình ban đầu nên đây là một sự tối ưu hóa
	để tắt snat_reroute và tránh việc tính toán lại.

sync_persist_mode - INTEGER
	mặc định 0

Kiểm soát việc đồng bộ hóa các kết nối khi sử dụng tính kiên trì

0: Tất cả các loại kết nối đều được đồng bộ

1: Cố gắng giảm lưu lượng đồng bộ hóa tùy thuộc vào
	kiểu kết nối. Đối với các dịch vụ liên tục, tránh đồng bộ hóa
	đối với các kết nối thông thường, chỉ thực hiện việc đó đối với các mẫu bền vững.
	Trong trường hợp như vậy, đối với TCP và SCTP, có thể cần bật sloppy_tcp và
	cờ sloppy_sctp trên máy chủ dự phòng. Đối với các dịch vụ không liên tục
	tối ưu hóa như vậy không được áp dụng, chế độ 0 được giả định.

đồng bộ_version - INTEGER
	mặc định 1

Phiên bản của giao thức đồng bộ hóa được sử dụng khi gửi
	tin nhắn đồng bộ hóa.

0 chọn giao thức đồng bộ hóa gốc (phiên bản 0). Cái này
	nên được sử dụng khi gửi tin nhắn đồng bộ hóa tới một di sản
	hệ thống chỉ hiểu giao thức đồng bộ hóa ban đầu.

1 chọn giao thức đồng bộ hóa hiện tại (phiên bản 1). Cái này
	nên được sử dụng khi có thể.

Hạt nhân có mục sync_version này có thể nhận tin nhắn
	của cả phiên bản 1 và phiên bản 2 của giao thức đồng bộ hóa.

run_estimation - BOOLEAN
	0 - bị vô hiệu hóa
	không phải 0 - đã bật (mặc định)

Nếu bị tắt, quá trình ước tính sẽ bị tạm dừng và các tác vụ kthread sẽ bị tạm dừng.
	dừng lại.

Bạn luôn có thể bật lại ước tính bằng cách đặt giá trị này thành 1.
	Nhưng hãy cẩn thận, ước tính đầu tiên sau khi kích hoạt lại không phải là
	chính xác.