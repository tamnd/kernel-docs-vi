.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/bonding.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Trình điều khiển liên kết Ethernet Linux HOWTO
==============================================

Cập nhật mới nhất: ngày 27 tháng 4 năm 2011

Bản phát hành lần đầu: Thomas Davis <tadavis tại lbl.gov>

Sửa chữa, mở rộng HA: 2000/10/03-15:

- Willy Tarreau <willy tại meta-x.org>
  - Constantine Gavrilov <const-g tại xpert.com>
  - Chad N. Tindel <ctindel tại ieee dot org>
  - Janice Girouard <girouard với chúng tôi dot ibm dot com>
  - Jay Vosburgh <fubar at us dot ibm dot com>

Được tổ chức lại và cập nhật vào tháng 2 năm 2005 bởi Jay Vosburgh
Đã thêm thông tin Sysfs: 24/04/2006

- Mitch Williams <mitch.a.williams tại intel.com>

Giới thiệu
============

Trình điều khiển liên kết Linux cung cấp một phương pháp tổng hợp
nhiều giao diện mạng thành một giao diện "liên kết" logic duy nhất.
Hoạt động của các giao diện được liên kết phụ thuộc vào chế độ; nói chung
nói, các chế độ cung cấp dịch vụ dự phòng nóng hoặc cân bằng tải.
Ngoài ra, việc giám sát tính toàn vẹn của liên kết có thể được thực hiện.

Trình điều khiển liên kết ban đầu đến từ Donald Becker's
bản vá lỗi beowulf cho kernel 2.0. Nó đã thay đổi khá nhiều kể từ đó, và
các công cụ gốc từ các trang web cực đoan và beowulf sẽ không hoạt động
với phiên bản trình điều khiển này.

Đối với các phiên bản trình điều khiển mới, các công cụ không gian người dùng được cập nhật và
ai cần giúp đỡ, vui lòng theo các liên kết ở cuối tập tin này.

.. Table of Contents

   1. Bonding Driver Installation

   2. Bonding Driver Options

   3. Configuring Bonding Devices
   3.1	Configuration with Sysconfig Support
   3.1.1		Using DHCP with Sysconfig
   3.1.2		Configuring Multiple Bonds with Sysconfig
   3.2	Configuration with Initscripts Support
   3.2.1		Using DHCP with Initscripts
   3.2.2		Configuring Multiple Bonds with Initscripts
   3.3	Configuring Bonding Manually with Ifenslave
   3.3.1		Configuring Multiple Bonds Manually
   3.4	Configuring Bonding Manually via Sysfs
   3.5	Configuration with Interfaces Support
   3.6	Overriding Configuration for Special Cases
   3.7 Configuring LACP for 802.3ad mode in a more secure way

   4. Querying Bonding Configuration
   4.1	Bonding Configuration
   4.2	Network Configuration

   5. Switch Configuration

   6. 802.1q VLAN Support

   7. Link Monitoring
   7.1	ARP Monitor Operation
   7.2	Configuring Multiple ARP Targets
   7.3	MII Monitor Operation

   8. Potential Trouble Sources
   8.1	Adventures in Routing
   8.2	Ethernet Device Renaming
   8.3	Painfully Slow Or No Failed Link Detection By Miimon

   9. SNMP agents

   10. Promiscuous mode

   11. Configuring Bonding for High Availability
   11.1	High Availability in a Single Switch Topology
   11.2	High Availability in a Multiple Switch Topology
   11.2.1		HA Bonding Mode Selection for Multiple Switch Topology
   11.2.2		HA Link Monitoring for Multiple Switch Topology

   12. Configuring Bonding for Maximum Throughput
   12.1	Maximum Throughput in a Single Switch Topology
   12.1.1		MT Bonding Mode Selection for Single Switch Topology
   12.1.2		MT Link Monitoring for Single Switch Topology
   12.2	Maximum Throughput in a Multiple Switch Topology
   12.2.1		MT Bonding Mode Selection for Multiple Switch Topology
   12.2.2		MT Link Monitoring for Multiple Switch Topology

   13. Switch Behavior Issues
   13.1	Link Establishment and Failover Delays
   13.2	Duplicated Incoming Packets

   14. Hardware Specific Considerations
   14.1	IBM BladeCenter

   15. Frequently Asked Questions

   16. Resources and Links


1. Cài đặt trình điều khiển liên kết
==============================

Các hạt nhân phân phối phổ biến nhất đều có trình điều khiển liên kết
đã có sẵn dưới dạng một mô-đun. Nếu bản phân phối của bạn không có hoặc bạn
phải biên dịch liên kết từ nguồn (ví dụ: định cấu hình và
cài đặt kernel chính từ kernel.org), bạn sẽ cần thực hiện
các bước sau:

1.1 Cấu hình và xây dựng kernel bằng liên kết
-----------------------------------------------

Phiên bản hiện tại của trình điều khiển liên kết có sẵn trong
thư mục con driver/net/bonding của nguồn kernel gần đây nhất
(có sẵn trên ZZ0000ZZ Hầu hết người dùng "cuộn
own" sẽ muốn sử dụng kernel mới nhất từ kernel.org.

Định cấu hình kernel bằng "make menuconfig" (hoặc "make xconfig" hoặc
"make config"), sau đó chọn "Hỗ trợ trình điều khiển liên kết" trong phần "Mạng
phần hỗ trợ thiết bị".  Bạn nên cấu hình
driver dưới dạng mô-đun vì hiện tại đây là cách duy nhất để truyền tham số
tới trình điều khiển hoặc cấu hình nhiều thiết bị liên kết.

Xây dựng và cài đặt kernel và mô-đun mới.

1.2 Tiện ích kiểm soát liên kết
---------------------------

Nên cấu hình liên kết qua iproute2 (netlink)
hoặc sysfs, tiện ích điều khiển ifenslave cũ đã lỗi thời.

2. Tùy chọn trình điều khiển liên kết
=========================

Các tùy chọn cho trình điều khiển liên kết được cung cấp dưới dạng tham số cho
mô-đun liên kết tại thời điểm tải hoặc được chỉ định thông qua sysfs.

Các tùy chọn mô-đun có thể được cung cấp dưới dạng đối số dòng lệnh cho
lệnh insmod hoặc modprobe, nhưng thường được chỉ định trong
Các tệp cấu hình ZZ0000ZZ hoặc trong một bản phân phối cụ thể
tệp cấu hình (một số tệp được trình bày chi tiết trong phần tiếp theo).

Thông tin chi tiết về hỗ trợ liên kết cho sysfs được cung cấp trong
Phần "Định cấu hình liên kết thủ công qua Sysfs" bên dưới.

Các tham số trình điều khiển liên kết có sẵn được liệt kê dưới đây. Nếu một
tham số không được chỉ định giá trị mặc định được sử dụng.  Khi ban đầu
định cấu hình một liên kết, bạn nên sử dụng "tail -f /var/log/messages"
chạy trong một cửa sổ riêng để xem thông báo lỗi trình điều khiển liên kết.

Điều quan trọng là miimon hoặc arp_interval và
tham số arp_ip_target phải được chỉ định, nếu không thì mạng nghiêm trọng
sự xuống cấp sẽ xảy ra khi liên kết bị lỗi.  Rất ít thiết bị không
Hỗ trợ ít nhất là miimon nên thực sự không có lý do gì để không sử dụng nó.

Các tùy chọn có giá trị văn bản sẽ chấp nhận tên văn bản
hoặc, để tương thích ngược, giá trị tùy chọn.  Ví dụ:
"mode=802.3ad" và "mode=4" đặt cùng một chế độ.

Các thông số như sau:

active_slave

Chỉ định nô lệ hoạt động mới cho các chế độ hỗ trợ nó
	(active-backup, Balance-alb và Balance-tlb).  Giá trị có thể
	là tên của bất kỳ giao diện hiện đang bị nô lệ nào hoặc một giao diện trống
	chuỗi.  Nếu tên được đặt, nô lệ và liên kết của nó phải theo thứ tự
	được chọn làm nô lệ hoạt động mới.  Nếu một chuỗi trống là
	được chỉ định, nô lệ hoạt động hiện tại sẽ bị xóa và hoạt động mới
	nô lệ được chọn tự động.

Lưu ý rằng điều này chỉ khả dụng thông qua giao diện sysfs. Không có mô-đun
	tham số có tên này tồn tại.

Giá trị bình thường của tùy chọn này là tên của hiện tại
	nô lệ hoạt động hoặc chuỗi trống nếu không có nô lệ hoạt động hoặc
	chế độ hiện tại không sử dụng nô lệ hoạt động.

ad_actor_sys_prio

Trong hệ thống AD, điều này chỉ định mức độ ưu tiên của hệ thống. Phạm vi cho phép
	là 1 - 65535. Nếu giá trị không được chỉ định, nó sẽ lấy 65535 làm
	giá trị mặc định.

Tham số này chỉ có hiệu lực ở chế độ 802.3ad và có sẵn thông qua
	Giao diện SysF.

diễn viên_port_prio

Trong hệ thống AD, điều này chỉ định mức độ ưu tiên của cổng. Phạm vi cho phép
	là 1 - 65535. Nếu giá trị không được chỉ định, nó sẽ lấy 255 làm giá trị
	giá trị mặc định.

Tham số này chỉ có hiệu lực ở chế độ 802.3ad và có sẵn thông qua
	giao diện liên kết mạng.

ad_actor_system

Trong hệ thống AD, điều này chỉ định địa chỉ mac cho tác nhân trong
	trao đổi gói giao thức (LACPDU). Giá trị không thể là multicast
	địa chỉ. Nếu tất cả các số 0 MAC được chỉ định, liên kết bên trong sẽ
	sử dụng MAC của chính trái phiếu đó. Tốt hơn là nên có
	bit quản trị cục bộ được đặt cho máy mac này nhưng trình điều khiển không thực thi nó. Nếu
	giá trị không được đưa ra thì hệ thống sẽ mặc định sử dụng giá trị chính
	địa chỉ mac làm địa chỉ hệ thống của diễn viên.

Tham số này chỉ có hiệu lực ở chế độ 802.3ad và có sẵn thông qua
	Giao diện SysF.

ad_select

Chỉ định logic lựa chọn tổng hợp 802.3ad sẽ sử dụng.  các
	các giá trị có thể có và tác dụng của chúng là:

ổn định hoặc 0

Bộ tổng hợp hoạt động được chọn bởi tổng hợp lớn nhất
		băng thông.

Việc chọn lại bộ tổng hợp hoạt động chỉ xảy ra khi tất cả
		nô lệ của bộ tổng hợp hoạt động không hoạt động hoặc đang hoạt động
		tập hợp không có nô lệ.

Đây là giá trị mặc định.

băng thông hoặc 1

Bộ tổng hợp hoạt động được chọn bởi tổng hợp lớn nhất
		băng thông.  Việc chọn lại xảy ra nếu:

- Một nô lệ được thêm vào hoặc xóa khỏi liên kết

- Bất kỳ trạng thái liên kết nào của nô lệ đều thay đổi

- Bất kỳ trạng thái liên kết 802.3ad nào của nô lệ đều thay đổi

- Trạng thái hành chính của trái phiếu thay đổi lên

đếm hoặc 2

Bộ tổng hợp hoạt động được chọn bởi số lượng lớn nhất
		cổng (nô lệ).  Việc chọn lại xảy ra như được mô tả trong phần
		cài đặt "băng thông" ở trên.

diễn viên_port_prio hoặc 3

Bộ tổng hợp hoạt động được chọn theo tổng số cao nhất của
		mức độ ưu tiên của cổng tác nhân trên các cổng đang hoạt động của nó. Lưu ý điều này
		mức độ ưu tiên là diễn viên_port_prio, không phải trên mỗi cổng ưu tiên, tức là
		được sử dụng để chọn lại chính.

Các chính sách lựa chọn băng thông, số lượng và diễn viên_port_prio cho phép
	chuyển đổi dự phòng của tập hợp 802.3ad khi hoạt động bị lỗi một phần
	tập hợp xảy ra. Điều này giữ cho trình tổng hợp ở mức cao nhất
	tính khả dụng (về băng thông, số lượng cổng hoặc tổng giá trị
	ưu tiên của cổng) luôn hoạt động.

Tùy chọn này đã được thêm vào trong phiên bản liên kết 3.4.0.

ad_user_port_key

Trong hệ thống AD, khóa cổng có ba phần như dưới đây -

==================
	   Sử dụng bit
	   ==================
	   00 song công
	   01-05 Tốc độ
	   06-15 Do người dùng xác định
	   ==================

Điều này xác định 10 bit trên của khóa cổng. Các giá trị có thể là
	từ 0 - 1023. Nếu không được cung cấp, hệ thống sẽ mặc định là 0.

Tham số này chỉ có hiệu lực ở chế độ 802.3ad và có sẵn thông qua
	Giao diện SysF.

all_slaves_active

Chỉ định rằng các khung trùng lặp (được nhận trên các cổng không hoạt động) phải được
	bị rơi (0) hoặc được giao (1).

Thông thường, liên kết sẽ loại bỏ các khung trùng lặp (được nhận khi không hoạt động).
	cổng), điều này được hầu hết người dùng mong muốn. Nhưng có một số lúc
	thật tuyệt khi cho phép phân phối các khung trùng lặp.

Giá trị mặc định là 0 (bỏ các khung trùng lặp nhận được trên không hoạt động
	cổng).

arp_interval

Chỉ định tần số giám sát liên kết ARP tính bằng mili giây.

Màn hình ARP hoạt động bằng cách kiểm tra định kỳ máy phụ
	thiết bị để xác định xem chúng đã gửi hay nhận
	lưu lượng truy cập gần đây (tiêu chí chính xác phụ thuộc vào
	chế độ liên kết và trạng thái của nô lệ).  Giao thông thường xuyên là
	được tạo thông qua các đầu dò ARP được cấp cho các địa chỉ được chỉ định bởi
	tùy chọn arp_ip_target.

Hành vi này có thể được sửa đổi bằng tùy chọn arp_validate,
	bên dưới.

Nếu giám sát ARP được sử dụng ở chế độ tương thích với kênh ether
	(chế độ 0 và 2), công tắc phải được cấu hình ở chế độ
	phân phối đồng đều các gói trên tất cả các liên kết. Nếu
	switch được cấu hình để phân phối các gói trong XOR
	thời trang, tất cả các phản hồi từ các mục tiêu ARP sẽ được nhận vào
	liên kết tương tự có thể khiến các thành viên khác trong nhóm
	thất bại.  Không nên sử dụng giám sát ARP cùng với
	miimon.  Giá trị 0 sẽ tắt giám sát ARP.  Mặc định
	giá trị là 0.

arp_ip_target

Chỉ định các địa chỉ IP để sử dụng làm đồng nghiệp giám sát ARP khi
	arp_interval là > 0. Đây là mục tiêu của yêu cầu ARP
	được gửi đi để xác định tình trạng của liên kết đến các mục tiêu.
	Chỉ định các giá trị này ở định dạng ddd.ddd.ddd.ddd.  Nhiều IP
	địa chỉ phải được phân tách bằng dấu phẩy.  Ít nhất một IP
	địa chỉ phải được cung cấp để giám sát ARP hoạt động.  các
	số lượng mục tiêu tối đa có thể được chỉ định là 16.
	giá trị mặc định là không có địa chỉ IP.

ns_ip6_target

Chỉ định các địa chỉ IPv6 để sử dụng làm đồng nghiệp giám sát IPv6 khi
	arp_interval là > 0. Đây là mục tiêu của yêu cầu NS
	được gửi đi để xác định tình trạng của liên kết đến các mục tiêu.
	Chỉ định các giá trị này ở định dạng ffff:ffff::ffff:ffff.  Nhiều IPv6
	địa chỉ phải được phân tách bằng dấu phẩy.  Ít nhất một IPv6
	địa chỉ phải được cung cấp để giám sát NS/NA hoạt động.  các
	số lượng mục tiêu tối đa có thể được chỉ định là 16.
	giá trị mặc định là không có địa chỉ IPv6.

arp_validate

Chỉ định xem có nên sử dụng đầu dò và phản hồi ARP hay không
	được xác thực ở bất kỳ chế độ nào hỗ trợ giám sát arp hoặc liệu
	lưu lượng truy cập không phải ARP phải được lọc (bỏ qua) cho liên kết
	mục đích giám sát.

Các giá trị có thể là:

không có hoặc 0

Không có xác nhận hoặc lọc được thực hiện.

đang hoạt động hoặc 1

Việc xác thực chỉ được thực hiện đối với nô lệ đang hoạt động.

dự phòng hoặc 2

Việc xác nhận chỉ được thực hiện đối với các máy phụ dự phòng.

tất cả hoặc 3

Xác nhận được thực hiện cho tất cả các nô lệ.

bộ lọc hoặc 4

Lọc được áp dụng cho tất cả các nô lệ. Không có xác nhận là
		được thực hiện.

filter_active hoặc 5

Quá trình lọc được áp dụng cho tất cả các nô lệ, quá trình xác thực được thực hiện
		chỉ dành cho nô lệ tích cực.

filter_backup hoặc 6

Quá trình lọc được áp dụng cho tất cả các nô lệ, quá trình xác thực được thực hiện
		chỉ dành cho nô lệ dự phòng.

Xác thực:

Việc bật xác thực sẽ khiến màn hình ARP kiểm tra dữ liệu đến
	ARP yêu cầu và trả lời, đồng thời chỉ coi nô lệ hoạt động nếu nó
	đang nhận được lưu lượng truy cập ARP thích hợp.

Đối với một nô lệ đang hoạt động, quá trình xác thực sẽ kiểm tra các phản hồi ARP để xác nhận
	rằng chúng được tạo bởi arp_ip_target.  Vì nô lệ dự phòng
	thường không nhận được những phản hồi này, việc xác thực được thực hiện
	đối với các nô lệ dự phòng nằm trong yêu cầu ARP được phát sóng được gửi qua
	nô lệ tích cực.  Có thể một số switch hoặc mạng
	cấu hình có thể dẫn đến tình huống trong đó các máy phụ dự phòng
	không nhận được yêu cầu ARP; trong tình huống như vậy, xác nhận
	của các nô lệ dự phòng phải bị vô hiệu hóa.

Việc xác thực các yêu cầu ARP trên các máy chủ dự phòng chủ yếu giúp ích
	liên kết để quyết định những nô lệ nào có nhiều khả năng làm việc hơn trong trường hợp
	lỗi nô lệ đang hoạt động, nó không thực sự đảm bảo rằng
	nô lệ dự phòng sẽ hoạt động nếu nó được chọn làm nô lệ hoạt động tiếp theo.

Việc xác thực rất hữu ích trong các cấu hình mạng trong đó có nhiều
	các máy chủ liên kết đang đồng thời phát hành ARP cho một hoặc nhiều mục tiêu
	ngoài một công tắc thông thường.  Nên liên kết giữa switch và
	mục tiêu không thành công (nhưng không phải bản thân công tắc), lưu lượng thăm dò
	được tạo ra bởi nhiều phiên bản liên kết sẽ đánh lừa tiêu chuẩn
	Màn hình ARP xem xét các liên kết vẫn còn hoạt động.  Sử dụng
	xác thực có thể giải quyết vấn đề này vì màn hình ARP sẽ chỉ xem xét
	ARP yêu cầu và trả lời liên quan đến phiên bản riêng của nó
	sự gắn kết.

Lọc:

Việc bật tính năng lọc khiến màn hình ARP chỉ sử dụng ARP đến
	các gói tin cho mục đích sẵn sàng liên kết.  Các gói đến được
	không phải ARP được phân phối bình thường nhưng không được tính khi xác định
	nếu có sẵn một nô lệ.

Quá trình lọc hoạt động bằng cách chỉ xem xét việc tiếp nhận ARP
	các gói (bất kỳ gói ARP nào, bất kể nguồn hay đích) khi
	xác định xem một nô lệ đã nhận được lưu lượng truy cập để biết tính khả dụng của liên kết
	mục đích.

Lọc rất hữu ích trong các cấu hình mạng trong đó
	mức độ lưu lượng phát sóng của bên thứ ba sẽ đánh lừa tiêu chuẩn
	Màn hình ARP xem xét các liên kết vẫn còn hoạt động.  Sử dụng
	quá trình lọc có thể giải quyết vấn đề này vì chỉ lưu lượng truy cập ARP được xem xét cho
	mục đích sẵn có của liên kết.

Tùy chọn này đã được thêm vào trong phiên bản liên kết 3.1.0.

arp_all_target

Chỉ định số lượng arp_ip_target phải có thể truy cập được
	để màn hình ARP coi một nô lệ đang hoạt động.
	Tùy chọn này chỉ ảnh hưởng đến chế độ sao lưu hoạt động cho các máy phụ có
	kích hoạt arp_validation.

Các giá trị có thể là:

bất kỳ hoặc 0

chỉ xem xét nô lệ khi có bất kỳ arp_ip_target nào
		có thể truy cập được

tất cả hoặc 1

chỉ xem xét nô lệ khi tất cả arp_ip_target
		có thể truy cập được

arp_missed_max

Chỉ định số lần kiểm tra màn hình arp_interval phải
	không thành công để màn hình ARP đánh dấu giao diện.

Để cung cấp ngữ nghĩa chuyển đổi dự phòng có trật tự, các giao diện sao lưu
	được phép kiểm tra giám sát bổ sung (tức là chúng phải thất bại
	arp_missed_max + 1 lần trước khi bị đánh dấu xuống).

Giá trị mặc định là 2 và phạm vi cho phép là 1 - 255.

điều khiển ghép nối

Chỉ định xem MUX của máy trạng thái LACP có ở chế độ 802.3ad hay không
    nên có trạng thái Thu thập và Phân phối riêng biệt.

Điều này là bằng cách thực hiện máy trạng thái điều khiển độc lập cho mỗi
    IEEE 802.1AX-2008 5.4.15 ngoài điều khiển ghép nối hiện có
    máy trạng thái.

Giá trị mặc định là 1. Cài đặt này không tách riêng phần Thu thập
    và Trạng thái phân phối, duy trì liên kết trong điều khiển kết hợp.

sự trì hoãn

Chỉ định thời gian, tính bằng mili giây, chờ trước khi tắt
	một Slave sau khi phát hiện được lỗi liên kết.  Tùy chọn này
	chỉ hợp lệ cho màn hình liên kết miimon.  Sự chậm trễ
	giá trị phải là bội số của giá trị miimon; nếu không thì nó
	sẽ được làm tròn xuống bội số gần nhất.  Mặc định
	giá trị là 0.

thất bại_over_mac

Chỉ định xem chế độ sao lưu hoạt động có nên đặt tất cả các máy phụ thành
	cùng một địa chỉ MAC lúc nô lệ (truyền thống
	hành vi), hoặc, khi được bật, thực hiện xử lý đặc biệt đối với
	địa chỉ MAC của trái phiếu theo chính sách đã chọn.

Các giá trị có thể là:

không có hoặc 0

Cài đặt này vô hiệu hóa failed_over_mac và khiến
		liên kết để đặt tất cả các nô lệ của liên kết dự phòng hoạt động thành
		cùng một địa chỉ MAC tại thời điểm nô lệ.  Đây là
		mặc định.

đang hoạt động hoặc 1

Chính sách "hoạt động" failed_over_mac chỉ ra rằng
		Địa chỉ MAC của trái phiếu phải luôn là MAC
		địa chỉ của nô lệ hiện đang hoạt động.  MAC
		địa chỉ của nô lệ không thay đổi; thay vào đó là MAC
		địa chỉ của trái phiếu thay đổi trong quá trình chuyển đổi dự phòng.

Chính sách này hữu ích cho các thiết bị không bao giờ có thể
		thay đổi địa chỉ MAC của họ hoặc đối với các thiết bị từ chối
		các chương trình phát sóng đến với nguồn MAC riêng của họ (mà
		can thiệp vào màn hình ARP).

Mặt trái của chính sách này là mọi thiết bị trên
		mạng phải được cập nhật qua ARP miễn phí,
		so với việc chỉ cập nhật một công tắc hoặc một bộ công tắc (mà
		thường diễn ra đối với bất kỳ lưu lượng truy cập nào, không chỉ ARP
		lưu lượng truy cập, nếu switch theo dõi lưu lượng truy cập đến
		cập nhật các bảng của nó) cho phương pháp truyền thống.  Nếu
		ARP vô cớ bị mất, liên lạc có thể bị gián đoạn
		bị gián đoạn.

Khi chính sách này được sử dụng cùng với mii
		màn hình, các thiết bị xác nhận liên kết trước khi được
		có thể thực sự truyền và nhận được đặc biệt
		dễ bị mất ARP vô cớ và
		cài đặt độ trễ cập nhật thích hợp có thể được yêu cầu.

theo dõi hoặc 2

Chính sách "theo dõi" failed_over_mac gây ra MAC
		địa chỉ của trái phiếu được chọn bình thường (thông thường
		địa chỉ MAC của nô lệ đầu tiên được thêm vào liên kết).
		Tuy nhiên, phần phụ thứ hai và tiếp theo không được đặt
		tới địa chỉ MAC này khi chúng đang ở vai trò dự phòng; một
		nô lệ được lập trình với địa chỉ MAC của trái phiếu tại
		thời gian chuyển đổi dự phòng (và nô lệ hoạt động trước đó sẽ nhận được
		địa chỉ MAC của nô lệ mới hoạt động).

Chính sách này hữu ích cho các thiết bị đa cổng
		trở nên bối rối hoặc phải chịu một hình phạt về hiệu suất
		khi nhiều cổng được lập trình với cùng một MAC
		địa chỉ.


Chính sách mặc định là không có, trừ khi nô lệ đầu tiên không thể
	thay đổi địa chỉ MAC của nó, trong trường hợp đó chính sách hoạt động là
	được chọn theo mặc định.

Tùy chọn này chỉ có thể được sửa đổi thông qua sysfs khi không có nô lệ nào
	hiện diện trong trái phiếu.

Tùy chọn này đã được thêm vào trong phiên bản liên kết 3.2.0.  Việc "theo dõi"
	chính sách đã được thêm vào trong phiên bản liên kết 3.3.0.

lacp_active
	Tùy chọn chỉ định có gửi khung LACPDU theo định kỳ hay không.

tắt hoặc 0
		Khung LACPDU hoạt động như "nói khi được nói".

trên hoặc 1
		Các khung LACPDU được gửi dọc theo các liên kết được định cấu hình
		định kỳ. Xem lacp_rate để biết thêm chi tiết.

Mặc định là bật.

lacp_rate

Tùy chọn chỉ định tỷ lệ chúng tôi sẽ yêu cầu đối tác liên kết của mình
	để truyền các gói LACPDU ở chế độ 802.3ad.  Giá trị có thể
	là:

chậm hoặc 0
		Yêu cầu đối tác truyền LACPDU cứ sau 30 giây

nhanh hoặc 1
		Yêu cầu đối tác truyền LACPDU cứ sau 1 giây

Mặc định là chậm.

phát_hàng xóm

Tùy chọn chỉ định có phát các gói ARP/ND tới tất cả hay không
	nô lệ tích cực.  Tùy chọn này không có tác dụng ở các chế độ khác ngoài
	chế độ 802.3ad.  Mặc định là tắt (0).

max_bonds

Chỉ định số lượng thiết bị liên kết cần tạo cho việc này
	ví dụ của trình điều khiển liên kết.  Ví dụ: nếu max_bonds là 3 và
	trình điều khiển liên kết chưa được tải, sau đó là bond0, bond1
	và trái phiếu2 sẽ được tạo.  Giá trị mặc định là 1. Chỉ định
	giá trị 0 sẽ tải liên kết nhưng sẽ không tạo ra bất kỳ thiết bị nào.

miimon

Chỉ định tần số giám sát liên kết MII tính bằng mili giây.
	Điều này xác định tần suất trạng thái liên kết của mỗi nô lệ được
	được kiểm tra các lỗi liên kết.  Giá trị 0 sẽ vô hiệu hóa MII
	giám sát liên kết.  Giá trị 100 là điểm khởi đầu tốt.

Giá trị mặc định là 100 nếu arp_interval không được đặt.

liên kết tối thiểu

Chỉ định số lượng liên kết tối thiểu phải hoạt động trước khi
	khẳng định người vận chuyển. Nó tương tự như các liên kết tối thiểu Cisco EtherChannel
	tính năng. Điều này cho phép thiết lập số lượng cổng thành viên tối thiểu
	phải ở trạng thái bật (trạng thái liên kết) trước khi đánh dấu thiết bị liên kết là lên
	(bật nhà mạng). Điều này hữu ích cho những tình huống mà các dịch vụ cấp cao hơn
	chẳng hạn như phân cụm muốn đảm bảo số lượng băng thông thấp tối thiểu
	liên kết đang hoạt động trước khi chuyển đổi. Tùy chọn này chỉ ảnh hưởng đến 802.3ad
	chế độ.

Giá trị mặc định là 0. Điều này sẽ khiến sóng mang được xác nhận (đối với
	chế độ 802.3ad) bất cứ khi nào có bộ tổng hợp hoạt động, bất kể
	số lượng liên kết có sẵn trong tập hợp đó. Lưu ý rằng, bởi vì một
	trình tổng hợp không thể hoạt động nếu không có ít nhất một liên kết có sẵn,
	đặt tùy chọn này thành 0 hoặc 1 đều có tác dụng tương tự.

cách thức

Chỉ định một trong các chính sách liên kết. Mặc định là
	Balance-rr (vòng tròn).  Các giá trị có thể là:

số dư-rr hoặc 0

Chính sách quay vòng: Truyền các gói theo tuần tự
		đặt hàng từ nô lệ có sẵn đầu tiên thông qua
		cuối cùng.  Chế độ này cung cấp khả năng cân bằng tải và lỗi
		sự khoan dung.

sao lưu hoạt động hoặc 1

Chính sách sao lưu tích cực: Chỉ có một nô lệ trong liên kết được
		hoạt động.  Một nô lệ khác sẽ hoạt động khi và chỉ
		nếu, nô lệ hoạt động bị lỗi.  Địa chỉ MAC của trái phiếu là
		chỉ hiển thị bên ngoài trên một cổng (bộ điều hợp mạng)
		để tránh gây nhầm lẫn cho switch.

Trong phiên bản liên kết 2.6.2 trở lên, khi chuyển đổi dự phòng
		xảy ra ở chế độ sao lưu tích cực, liên kết sẽ tạo ra một
		hoặc nhiều ARP vô cớ trên nô lệ mới hoạt động.
		Một ARP miễn phí được cấp cho chủ liên kết
		giao diện và mỗi giao diện VLAN được định cấu hình ở trên
		nó, miễn là giao diện có ít nhất một IP
		địa chỉ được cấu hình.  ARP miễn phí được phát hành cho VLAN
		các giao diện được gắn thẻ với id VLAN thích hợp.

Chế độ này cung cấp khả năng chịu lỗi.  chính
		tùy chọn, được ghi lại bên dưới, ảnh hưởng đến hành vi của điều này
		chế độ.

cân bằng-xor hoặc 2

Chính sách XOR: Truyền dựa trên truyền đã chọn
		chính sách băm.  Chính sách mặc định là [(nguồn
		Địa chỉ MAC XOR'd với địa chỉ MAC đích XOR
		ID loại gói) số lượng nô lệ modulo].  Truyền thay thế
		chính sách có thể được chọn thông qua tùy chọn xmit_hash_policy,
		được mô tả dưới đây.

Chế độ này cung cấp khả năng cân bằng tải và khả năng chịu lỗi.

phát sóng hoặc 3

Chính sách phát sóng: truyền mọi thứ trên tất cả nô lệ
		giao diện.  Chế độ này cung cấp khả năng chịu lỗi.

802.3ad hoặc 4

IEEE 802.3ad Tổng hợp liên kết động.  Tạo
		các nhóm tổng hợp có cùng tốc độ và
		cài đặt song công.  Sử dụng tất cả nô lệ trong hoạt động
		tập hợp theo đặc tả 802.3ad.

Việc lựa chọn phụ cho lưu lượng đi được thực hiện theo
		sang chính sách băm truyền, có thể được thay đổi từ
		chính sách XOR đơn giản mặc định thông qua xmit_hash_policy
		tùy chọn, được ghi lại dưới đây.  Lưu ý rằng không phải tất cả đều truyền
		chính sách có thể tuân thủ 802.3ad, đặc biệt là trong
		liên quan đến các yêu cầu đặt hàng sai gói của
		mục 43.2.4 của tiêu chuẩn 802.3ad.  Khác biệt
		việc triển khai ngang hàng sẽ có dung sai khác nhau đối với
		sự không tuân thủ.

Điều kiện tiên quyết:

1. Hỗ trợ Ethtool trong trình điều khiển cơ sở để truy xuất
		tốc độ và song công của mỗi nô lệ.

2. Switch hỗ trợ IEEE 802.3ad Dynamic link
		tổng hợp.

Hầu hết các thiết bị chuyển mạch sẽ yêu cầu một số loại cấu hình
		để bật chế độ 802.3ad.

số dư-tlb hoặc 5

Cân bằng tải truyền thích ứng: liên kết kênh
		không yêu cầu bất kỳ sự hỗ trợ chuyển đổi đặc biệt nào.

Ở chế độ tlb_dynamic_lb=1; lưu lượng đi là
		được phân bổ theo tải hiện tại (tính
		tương ứng với tốc độ) trên mỗi nô lệ.

Ở chế độ tlb_dynamic_lb=0; cân bằng tải dựa trên
		tải hiện tại bị vô hiệu hóa và tải được phân phối
		chỉ sử dụng phân phối băm.

Lưu lượng truy cập đến được nhận bởi nô lệ hiện tại.
		Nếu nô lệ nhận thất bại, nô lệ khác sẽ tiếp quản
		địa chỉ MAC của nô lệ nhận không thành công.

Điều kiện tiên quyết:

Hỗ trợ Ethtool trong trình điều khiển cơ sở để truy xuất
		tốc độ của mỗi nô lệ.

cân bằng-alb hoặc 6

Cân bằng tải thích ứng: bao gồm Balance-tlb plus
		nhận cân bằng tải (rlb) cho lưu lượng IPV4 và
		không yêu cầu bất kỳ sự hỗ trợ chuyển đổi đặc biệt nào.  các
		nhận cân bằng tải đạt được bằng cách đàm phán ARP.
		Trình điều khiển liên kết chặn các câu trả lời ARP được gửi bởi
		hệ thống cục bộ đang trên đường thoát ra và ghi đè lên
		địa chỉ phần cứng nguồn với phần cứng duy nhất
		địa chỉ của một trong những nô lệ trong trái phiếu sao cho
		các đồng nghiệp khác nhau sử dụng các địa chỉ phần cứng khác nhau cho
		máy chủ.

Nhận lưu lượng truy cập từ các kết nối được tạo bởi máy chủ
		cũng được cân bằng.  Khi hệ thống cục bộ gửi ARP
		Yêu cầu bản sao trình điều khiển liên kết và lưu trình điều khiển ngang hàng
		Thông tin IP từ gói ARP.  Khi ARP
		Trả lời đến từ thiết bị ngang hàng, địa chỉ phần cứng của nó là
		được truy xuất và trình điều khiển liên kết khởi tạo ARP
		trả lời ngang hàng này gán nó cho một trong những nô lệ
		trong trái phiếu.  Kết quả có vấn đề khi sử dụng ARP
		đàm phán để cân bằng là mỗi lần một
		Yêu cầu ARP được phát đi, nó sử dụng địa chỉ phần cứng
		của trái phiếu.  Do đó, các đồng nghiệp tìm hiểu địa chỉ phần cứng
		của trái phiếu và sự cân bằng của lưu lượng nhận
		sụp đổ thành nô lệ hiện tại.  Việc này được xử lý bởi
		gửi thông tin cập nhật (Trả lời ARP) tới tất cả các đồng nghiệp có
		địa chỉ phần cứng được gán riêng của họ sao cho
		lưu lượng được phân phối lại.  Nhận lưu lượng truy cập cũng được
		được phân phối lại khi một nô lệ mới được thêm vào trái phiếu
		và khi một nô lệ không hoạt động được kích hoạt lại.  các
		tải nhận được phân phối tuần tự (vòng tròn)
		trong nhóm nô lệ tốc độ cao nhất trong mối liên kết.

Khi một liên kết được kết nối lại hoặc một nô lệ mới tham gia vào
		liên kết lưu lượng nhận được phân phối lại cho tất cả
		nô lệ tích cực trong liên kết bằng cách bắt đầu ARP
		với địa chỉ MAC đã chọn cho mỗi địa chỉ
		khách hàng. Tham số updelay (chi tiết bên dưới) phải
		được đặt thành giá trị bằng hoặc lớn hơn giá trị của công tắc
		trì hoãn chuyển tiếp để các Trả lời ARP được gửi tới
		các đồng nghiệp sẽ không bị chặn bởi switch.

Điều kiện tiên quyết:

1. Hỗ trợ Ethtool trong trình điều khiển cơ sở để truy xuất
		tốc độ của mỗi nô lệ.

2. Hỗ trợ driver cơ bản cho việc cài đặt phần cứng
		địa chỉ của một thiết bị khi nó đang mở.  Đây là
		cần thiết để luôn có một nô lệ trong
		nhóm sử dụng địa chỉ phần cứng trái phiếu (địa chỉ
		curr_active_slave) trong khi có phần cứng độc đáo
		địa chỉ của mỗi nô lệ trong trái phiếu.  Nếu
		curr_active_slave không thành công, địa chỉ phần cứng của nó là
		được đổi chỗ bằng Curr_active_slave mới
		được chọn.

num_grat_arp,
num_unsol_na

Chỉ định số lượng thông báo ngang hàng (ARP miễn phí và
	Quảng cáo hàng xóm IPv6 không được yêu cầu) sẽ được phát hành sau một
	sự kiện chuyển đổi dự phòng.  Ngay khi có liên kết trên nô lệ mới
	(có thể ngay lập tức) một thông báo ngang hàng được gửi trên
	thiết bị liên kết và mỗi thiết bị phụ VLAN. Điều này được lặp lại ở
	tốc độ được chỉ định bởi ngang hàng_notif_delay nếu số đó là
	lớn hơn 1.

Phạm vi hợp lệ là 0 - 255; giá trị mặc định là 1. Các tùy chọn này
	ảnh hưởng đến chế độ sao lưu hoạt động hoặc 802.3ad (bật Broadcast_neighbor).
	Các tùy chọn này đã được thêm vào cho phiên bản liên kết 3.3.0 và 3.4.0
	tương ứng.

Từ Linux 3.0 và phiên bản liên kết 3.7.1, những thông báo này
	được tạo bởi mã ipv4 và ipv6 và số lượng
	sự lặp lại không thể được thiết lập một cách độc lập.

gói_per_slave

Chỉ định số lượng gói để truyền qua một nô lệ trước
	chuyển sang cái tiếp theo. Khi được đặt thành 0 thì một nô lệ được chọn tại
	ngẫu nhiên.

Phạm vi hợp lệ là 0 - 65535; giá trị mặc định là 1. Tùy chọn này
	chỉ có hiệu lực ở chế độ Balance-rr.

ngang hàng_notif_delay

Chỉ định độ trễ, tính bằng mili giây, giữa mỗi thiết bị ngang hàng
	thông báo (ARP miễn phí và IPv6 Neighbor không được yêu cầu
	Quảng cáo) khi chúng được phát hành sau một sự kiện chuyển đổi dự phòng.
	Độ trễ này phải là bội số của khoảng thời gian giám sát liên kết MII
	(miimon).

Phạm vi hợp lệ là 0 - 300000. Giá trị mặc định là 0, có nghĩa là
	để khớp với giá trị của khoảng thời gian giám sát liên kết MII.

trước
	Ưu tiên nô lệ. Số cao hơn có nghĩa là mức độ ưu tiên cao hơn.
	Slave chính có mức độ ưu tiên cao nhất. Tùy chọn này cũng
	tuân theo quy tắc Primary_reselect.

Tùy chọn này chỉ có thể được định cấu hình qua liên kết mạng và chỉ hợp lệ
	cho chế độ active-backup(1), Balance-tlb (5) và Balance-alb (6).
	Phạm vi giá trị hợp lệ là số nguyên 32 bit có dấu.

Giá trị mặc định là 0.

sơ đẳng

Một chuỗi (eth0, eth2, v.v.) chỉ định nô lệ nào là
	thiết bị sơ cấp.  Thiết bị được chỉ định sẽ luôn là thiết bị
	nô lệ hoạt động trong khi nó có sẵn.  Chỉ khi chính là
	ngoại tuyến sẽ sử dụng các thiết bị thay thế.  Điều này rất hữu ích khi
	một nô lệ được ưu tiên hơn một nô lệ khác, ví dụ: khi một nô lệ có
	thông lượng cao hơn khác.

Tùy chọn chính chỉ hợp lệ cho sao lưu hoạt động (1),
	chế độ cân bằng-tlb (5) và cân bằng-alb (6).

chính_reselect

Chỉ định chính sách lựa chọn lại cho nô lệ chính.  Cái này
	ảnh hưởng đến cách chọn nô lệ chính để trở thành nô lệ tích cực
	khi lỗi của nô lệ hoạt động hoặc sự phục hồi của nô lệ chính
	xảy ra.  Tùy chọn này được thiết kế để ngăn chặn việc chuyển đổi giữa
	nô lệ chính và các nô lệ khác.  Các giá trị có thể là:

luôn luôn hoặc 0 (mặc định)

Nô lệ chính trở thành nô lệ tích cực bất cứ khi nào nó
		quay trở lại.

tốt hơn hoặc 1

Nô lệ chính trở thành nô lệ tích cực khi có
		sao lưu, nếu tốc độ và song công của nô lệ chính là
		tốt hơn tốc độ và song công của hoạt động hiện tại
		nô lệ.

thất bại hoặc 2

Nô lệ chính chỉ trở thành nô lệ hoạt động nếu
		nô lệ hoạt động hiện tại bị lỗi và nô lệ chính vẫn hoạt động.

Cài đặt Primary_reselect bị bỏ qua trong hai trường hợp:

Nếu không có nô lệ nào hoạt động thì nô lệ đầu tiên được phục hồi là
		làm nô lệ tích cực.

Khi bắt đầu làm nô lệ, nô lệ chính luôn được tạo ra
		nô lệ tích cực.

Việc thay đổi chính sách Primary_reselect thông qua sysfs sẽ gây ra lỗi
	lựa chọn ngay lập tức nô lệ tích cực tốt nhất theo tiêu chuẩn mới
	chính sách.  Điều này có thể hoặc không thể dẫn đến sự thay đổi hoạt động
	nô lệ, tùy theo hoàn cảnh.

Tùy chọn này đã được thêm vào cho phiên bản liên kết 3.6.0.

tlb_dynamic_lb

Chỉ định xem tính năng xáo trộn động của các luồng có được bật trong tlb hay không
	hoặc chế độ alb. Giá trị này không ảnh hưởng đến bất kỳ chế độ nào khác.

Hành vi mặc định của chế độ tlb là xáo trộn các luồng hoạt động qua
	nô lệ dựa trên tải trong khoảng thời gian đó. Điều này mang lại cho lb tốt đẹp
	đặc điểm nhưng có thể gây ra sự sắp xếp lại gói. Nếu đặt hàng lại là
	mối quan tâm sử dụng biến này để vô hiệu hóa việc xáo trộn luồng và dựa vào
	cân bằng tải chỉ được cung cấp bởi phân phối băm.
	xmit-hash-policy có thể được sử dụng để chọn hàm băm thích hợp cho
	việc thiết lập.

Mục sysfs có thể được sử dụng để thay đổi cài đặt cho mỗi thiết bị liên kết
	và giá trị ban đầu được lấy từ tham số mô-đun. các
	mục nhập sysfs chỉ được phép thay đổi nếu thiết bị liên kết được
	xuống.

Giá trị mặc định là "1" cho phép xáo trộn luồng trong khi giá trị "0"
	vô hiệu hóa nó. Tùy chọn này đã được thêm vào trình điều khiển liên kết 3.7.1


trì hoãn cập nhật

Chỉ định thời gian, tính bằng mili giây, chờ trước khi kích hoạt
	Slave sau khi phát hiện được việc khôi phục liên kết.  Tùy chọn này là
	chỉ hợp lệ cho màn hình liên kết miimon.  Giá trị độ trễ cập nhật
	phải là bội số của giá trị miimon; nếu không thì sẽ như vậy
	làm tròn xuống bội số gần nhất.  Giá trị mặc định là 0.

use_carrier

Tùy chọn lỗi thời đã được chọn trước đó giữa MII /
	ETHTOOL ioctls và netif_carrier_ok() để xác định liên kết
	trạng thái.

Tất cả việc kiểm tra trạng thái liên kết hiện được thực hiện bằng netif_carrier_ok().

Để tương thích ngược, giá trị của tùy chọn này có thể được kiểm tra
	hoặc thiết lập.  Cài đặt hợp lệ duy nhất là 1.

chính sách xmit_hash_

Chọn chính sách băm truyền để sử dụng cho việc lựa chọn nô lệ trong
	các chế độ cân bằng-xor, 802.3ad và tlb.  Các giá trị có thể là:

lớp 2

Sử dụng XOR của địa chỉ MAC phần cứng và ID loại gói
		trường để tạo hàm băm. Công thức là

hàm băm = nguồn MAC[5] XOR đích MAC[5] ID loại gói XOR
		số nô lệ = số lượng nô lệ modulo băm

Thuật toán này sẽ đặt tất cả lưu lượng truy cập vào một địa chỉ cụ thể
		mạng ngang hàng trên cùng một nô lệ.

Thuật toán này tuân thủ 802.3ad.

lớp2+3

Chính sách này sử dụng kết hợp layer2 và layer3
		thông tin giao thức để tạo ra hàm băm.

Sử dụng XOR của địa chỉ MAC phần cứng và địa chỉ IP để
		tạo ra hàm băm.  Công thức là

hàm băm = nguồn MAC[5] XOR đích MAC[5] ID loại gói XOR
		hàm băm = hàm băm XOR IP nguồn XOR IP đích
		hàm băm = hàm băm XOR (băm RSHIFT 16)
		hàm băm = hàm băm XOR (băm RSHIFT 8)
		Và sau đó hàm băm được giảm số lượng nô lệ theo modulo.

Nếu giao thức là IPv6 thì nguồn và đích
		địa chỉ được băm đầu tiên bằng ipv6_addr_hash.

Thuật toán này sẽ đặt tất cả lưu lượng truy cập vào một địa chỉ cụ thể
		mạng ngang hàng trên cùng một nô lệ.  Đối với lưu lượng không phải IP,
		công thức tương tự như đối với truyền lớp 2
		chính sách băm.

Chính sách này nhằm mục đích cung cấp một sự cân bằng hơn
		phân phối lưu lượng hơn so với lớp 2, đặc biệt là
		trong môi trường có thiết bị cổng lớp 3
		cần thiết để đến được hầu hết các điểm đến.

Thuật toán này tuân thủ 802.3ad.

lớp3+4

Chính sách này sử dụng thông tin giao thức lớp trên,
		khi có sẵn, để tạo hàm băm.  Điều này cho phép
		lưu lượng truy cập đến một mạng ngang hàng cụ thể trải rộng trên nhiều mạng
		nô lệ, mặc dù một kết nối duy nhất sẽ không trải dài
		nhiều nô lệ.

Công thức cho các gói TCP và UDP không bị phân mảnh là

hash = cổng nguồn, cổng đích (như trong tiêu đề)
		hàm băm = hàm băm XOR IP nguồn XOR IP đích
		hàm băm = hàm băm XOR (băm RSHIFT 16)
		hàm băm = hàm băm XOR (băm RSHIFT 8)
		hàm băm = hàm băm RSHIFT 1
		Và sau đó hàm băm được giảm số lượng nô lệ theo modulo.

Nếu giao thức là IPv6 thì nguồn và đích
		địa chỉ được băm đầu tiên bằng ipv6_addr_hash.

Đối với các gói TCP hoặc UDP bị phân mảnh và tất cả các gói IPv4 và
		Lưu lượng giao thức IPv6, cổng nguồn và cổng đích
		thông tin bị bỏ qua.  Đối với lưu lượng không phải IP,
		công thức tương tự như đối với hàm băm truyền lớp 2
		chính sách.

Thuật toán này không hoàn toàn tuân thủ 802.3ad.  A
		một cuộc hội thoại TCP hoặc UDP chứa cả hai
		các gói bị phân mảnh và không bị phân mảnh sẽ thấy các gói
		sọc trên hai giao diện.  Điều này có thể dẫn đến
		về việc giao hàng.  Hầu hết các loại lưu lượng truy cập sẽ không đáp ứng
		tiêu chí này, vì TCP hiếm khi phân đoạn lưu lượng truy cập và
		hầu hết lưu lượng truy cập UDP không liên quan đến việc mở rộng
		cuộc trò chuyện.  Việc triển khai khác của 802.3ad có thể
		hoặc có thể không chấp nhận sự không tuân thủ này.

đóng gói2+3

Chính sách này sử dụng công thức tương tự như layer2+3 nhưng nó
		dựa vào skb_flow_dissect để lấy các trường tiêu đề
		điều này có thể dẫn đến việc sử dụng các tiêu đề bên trong nếu
		giao thức đóng gói được sử dụng. Ví dụ như điều này sẽ
		cải thiện hiệu suất cho người dùng đường hầm vì
		các gói sẽ được phân phối theo cách thức được đóng gói
		chảy.

đóng gói3+4

Chính sách này sử dụng công thức tương tự như layer3+4 nhưng nó
		dựa vào skb_flow_dissect để lấy các trường tiêu đề
		điều này có thể dẫn đến việc sử dụng các tiêu đề bên trong nếu
		giao thức đóng gói được sử dụng. Ví dụ như điều này sẽ
		cải thiện hiệu suất cho người dùng đường hầm vì
		các gói sẽ được phân phối theo cách thức được đóng gói
		chảy.

vlan+srcmac

Chính sách này sử dụng ID vlan và mac nguồn rất thô sơ
		băm để lưu lượng cân bằng tải trên mỗi vlan, có chuyển đổi dự phòng
		nếu một chân bị gãy. Trường hợp sử dụng dự định là cho một trái phiếu
		được chia sẻ bởi nhiều máy ảo, tất cả đều được cấu hình để
		sử dụng vlan của riêng họ để cung cấp chức năng giống như lacp
		mà không yêu cầu phần cứng chuyển mạch có khả năng lacp.

Công thức cho hàm băm đơn giản là

hàm băm = (vlan ID) XOR (nguồn nhà cung cấp MAC) XOR (nguồn nhà phát triển MAC)

Giá trị mặc định là layer2.  Tùy chọn này đã được thêm vào trong liên kết
	phiên bản 2.6.3.  Trong các phiên bản liên kết trước đó, tham số này
	không tồn tại và chính sách layer2 là chính sách duy nhất.  các
	Giá trị layer2+3 đã được thêm vào cho phiên bản liên kết 3.2.2.

gửi lại_igmp

Chỉ định số lượng báo cáo thành viên IGMP sẽ được phát hành sau
	một sự kiện chuyển đổi dự phòng. Một báo cáo thành viên được ban hành ngay sau khi
	chuyển đổi dự phòng, các gói tiếp theo sẽ được gửi trong mỗi khoảng thời gian 200ms.

Phạm vi hợp lệ là 0 - 255; giá trị mặc định là 1. Giá trị 0
	ngăn không cho báo cáo thành viên IGMP được đưa ra để phản hồi
	đến sự kiện chuyển đổi dự phòng.

Tùy chọn này hữu ích cho các chế độ liên kết Balance-rr (0), active-backup
	(1), Balance-tlb (5) và Balance-alb (6), trong đó chuyển đổi dự phòng có thể
	chuyển lưu lượng IGMP từ nô lệ này sang nô lệ khác.  Vì thế một loại tươi
	Báo cáo IGMP phải được đưa ra để khiến switch chuyển tiếp dữ liệu đến
	Lưu lượng IGMP qua nô lệ mới được chọn.

Tùy chọn này đã được thêm vào cho phiên bản liên kết 3.7.0.

lp_interval

Chỉ định số giây giữa các trường hợp liên kết
	trình điều khiển gửi các gói học đến từng switch ngang hàng của Slave.

Phạm vi hợp lệ là 1 - 0x7fffffff; giá trị mặc định là 1. Tùy chọn này
	chỉ có hiệu lực ở chế độ cân bằng-tlb và cân bằng-alb.

3. Cấu hình thiết bị liên kết
==============================

Bạn có thể định cấu hình liên kết bằng mạng của bản phân phối của mình
tập lệnh khởi tạo hoặc sử dụng thủ công iproute2 hoặc
giao diện sysfs.  Các bản phân phối thường sử dụng một trong ba gói cho
tập lệnh khởi tạo mạng: initscripts, sysconfig hoặc giao diện.
Các phiên bản gần đây của các gói này có hỗ trợ liên kết, trong khi các phiên bản cũ hơn
các phiên bản thì không.

Đầu tiên chúng tôi sẽ mô tả các tùy chọn để cấu hình liên kết cho
các bản phân phối sử dụng các phiên bản initscripts, sysconfig và giao diện có đầy đủ
hoặc hỗ trợ một phần cho việc liên kết, sau đó cung cấp thông tin về cách kích hoạt
liên kết mà không có sự hỗ trợ từ các tập lệnh khởi tạo mạng (tức là
phiên bản cũ hơn của initscripts hoặc sysconfig).

Nếu bạn không chắc liệu bản phân phối của mình có sử dụng sysconfig hay không,
bản initscript hoặc giao diện, hoặc không biết nó có đủ mới hay không, đừng lo lắng.
Việc xác định điều này khá đơn giản.

Đầu tiên, hãy tìm tệp có tên giao diện trong thư mục /etc/network.
Nếu tệp này có trong hệ thống của bạn thì hệ thống của bạn sẽ sử dụng giao diện. Xem
Cấu hình với hỗ trợ giao diện.

Ngược lại, ra lệnh::

$ vòng/phút -qf /sbin/ifup

Nó sẽ phản hồi bằng một dòng văn bản bắt đầu bằng một trong hai
"initscripts" hoặc "sysconfig," theo sau là một số con số.  Đây là
gói cung cấp tập lệnh khởi tạo mạng của bạn.

Tiếp theo, để xác định xem cài đặt của bạn có hỗ trợ liên kết hay không,
ra lệnh::

$ grep ifenslave /sbin/ifup

Nếu điều này trả về bất kỳ kết quả phù hợp nào thì bản initscript hoặc
sysconfig có hỗ trợ liên kết.

3.1 Cấu hình với Hỗ trợ Sysconfig
----------------------------------------

Phần này áp dụng cho các bản phân phối sử dụng phiên bản sysconfig
với sự hỗ trợ liên kết, ví dụ: SuSE Linux Enterprise Server 9.

Hệ thống cấu hình mạng của SuSE SLES 9 có hỗ trợ
tuy nhiên, tại thời điểm viết bài này, việc liên kết cấu hình hệ thống YaST
giao diện người dùng không cung cấp bất kỳ phương tiện nào để làm việc với các thiết bị liên kết.
Tuy nhiên, các thiết bị liên kết có thể được quản lý bằng tay như sau.

Đầu tiên, nếu chúng chưa được cấu hình, hãy cấu hình
thiết bị nô lệ.  Trên SLES 9, việc này được thực hiện dễ dàng nhất bằng cách chạy
tiện ích cấu hình sysconfig yast2.  Mục tiêu là để tạo ra một
ifcfg-id cho từng thiết bị phụ.  Cách đơn giản nhất để thực hiện
đây là để định cấu hình các thiết bị cho DHCP (việc này chỉ để lấy
tệp ifcfg-id đã được tạo; xem bên dưới để biết một số vấn đề với DHCP).  các
Tên file cấu hình cho mỗi thiết bị sẽ có dạng::

ifcfg-id-xx:xx:xx:xx:xx:xx

Trong đó phần "xx" sẽ được thay thế bằng các chữ số từ
địa chỉ MAC cố định của thiết bị.

Khi tập hợp các tệp ifcfg-id-xx:xx:xx:xx:xx:xx đã được
được tạo ra cần phải chỉnh sửa các file cấu hình cho Slave
các thiết bị (địa chỉ MAC tương ứng với địa chỉ của các thiết bị phụ).
Trước khi chỉnh sửa, tập tin sẽ chứa nhiều dòng và sẽ trông giống như
một cái gì đó như thế này::

BOOTPROTO='dhcp'
	STARTMODE='bật'
	USERCTL='không'
	UNIQUE='XNzu.WeZGOGF+4wE'
	_nm_name='bus-pci-0001:61:01.0'

Thay đổi dòng BOOTPROTO và STARTMODE thành dòng sau::

BOOTPROTO='không có'
	STARTMODE='tắt'

Không thay đổi dòng UNIQUE hoặc _nm_name.  Loại bỏ bất kỳ cái nào khác
dòng (USERCTL, v.v.).

Khi các tệp ifcfg-id-xx:xx:xx:xx:xx:xx đã được sửa đổi,
đã đến lúc tạo file cấu hình cho thiết bị liên kết
chính nó.  Tệp này có tên là ifcfg-bondX, trong đó X là số của
thiết bị liên kết cần tạo, bắt đầu từ 0. Tệp đầu tiên như vậy là
ifcfg-bond0, thứ hai là ifcfg-bond1, v.v.  Cấu hình hệ thống
hệ thống cấu hình mạng sẽ khởi động chính xác nhiều phiên bản
của sự gắn kết.

Nội dung của tệp ifcfg-bondX như sau ::

BOOTPROTO="tĩnh"
	BROADCAST="10.0.2.255"
	IPADDR="10.0.2.10"
	NETMASK="255.255.0.0"
	NETWORK="10.0.2.0"
	REMOTE_IPADDR=""
	STARTMODE="khi khởi động"
	BONDING_MASTER="có"
	BONDING_MODULE_OPTS="mode=active-backup miimon=100"
	BONDING_SLAVE0="eth0"
	BONDING_SLAVE1="bus-pci-0000:06:08.1"

Thay thế mẫu BROADCAST, IPADDR, NETMASK và NETWORK
các giá trị có giá trị thích hợp cho mạng của bạn.

STARTMODE chỉ định thời điểm thiết bị được kết nối trực tuyến.
Các giá trị có thể là:

====================================================================
	onboot Thiết bị được khởi động vào lúc khởi động.  Nếu bạn không
		 chắc chắn, đây có lẽ là điều bạn muốn.

hướng dẫn sử dụng Thiết bị chỉ được khởi động khi ifup được gọi
		 bằng tay.  Các thiết bị liên kết có thể được cấu hình theo cách này
		 nếu bạn không muốn chúng tự động bắt đầu
		 lúc khởi động vì lý do nào đó.

hotplug Thiết bị được khởi động bởi một sự kiện hotplug.  Đây không phải là
		 một sự lựa chọn hợp lệ cho một thiết bị liên kết.

tắt hoặc Cấu hình thiết bị bị bỏ qua.
	bỏ qua
	====================================================================

Dòng BONDING_MASTER='yes' chỉ ra rằng thiết bị là một
thiết bị chủ liên kết.  Giá trị hữu ích duy nhất là "có."

Nội dung của BONDING_MODULE_OPTS được cung cấp cho
ví dụ về mô-đun liên kết cho thiết bị này.  Chỉ định các tùy chọn
về chế độ liên kết, giám sát liên kết, v.v. tại đây.  Không bao gồm
tham số liên kết max_bonds; điều này sẽ gây nhầm lẫn cấu hình
hệ thống nếu bạn có nhiều thiết bị liên kết.

Cuối cùng, cung cấp một BONDING_SLAVEn="thiết bị phụ" cho mỗi thiết bị
nô lệ.  trong đó "n" là giá trị tăng dần, một giá trị cho mỗi nô lệ.  các
"thiết bị phụ" là tên giao diện, ví dụ: "eth0" hoặc thiết bị
chỉ định cho thiết bị mạng.  Tên giao diện dễ dàng hơn
find, nhưng tên ethN có thể thay đổi khi khởi động nếu, ví dụ:
một thiết bị đầu tiên trong chuỗi đã bị lỗi.  Bộ chỉ định thiết bị
(bus-pci-0000:06:08.1 trong ví dụ trên) chỉ định cấu hình vật lý
thiết bị mạng và sẽ không thay đổi trừ khi vị trí bus của thiết bị
thay đổi (ví dụ: nó được chuyển từ khe PCI này sang khe PCI khác).  các
ví dụ trên sử dụng một trong mỗi loại cho mục đích trình diễn; nhất
cấu hình sẽ chọn cái này hoặc cái kia cho tất cả các thiết bị phụ.

Khi tất cả các tập tin cấu hình đã được sửa đổi hoặc tạo,
mạng phải được khởi động lại để thực hiện các thay đổi về cấu hình
hiệu ứng.  Điều này có thể được thực hiện thông qua những điều sau đây::

# /etc/init.d/khởi động lại mạng

Lưu ý rằng tập lệnh điều khiển mạng (/sbin/ifdown) sẽ
loại bỏ mô-đun liên kết như một phần của quá trình tắt mạng,
vì vậy không cần thiết phải tháo mô-đun bằng tay nếu, ví dụ:
các tham số mô-đun đã thay đổi.

Ngoài ra, tại thời điểm viết bài này, YaST/YaST2 sẽ không quản lý việc liên kết
thiết bị (chúng không hiển thị giao diện liên kết trên danh sách mạng của nó
thiết bị).  Cần phải chỉnh sửa tập tin cấu hình bằng tay để
thay đổi cấu hình liên kết.

Các tùy chọn chung và chi tiết bổ sung của tệp ifcfg
định dạng có thể được tìm thấy trong một ví dụ tệp mẫu ifcfg ::

/etc/sysconfig/network/ifcfg.template

Lưu ý rằng mẫu không ghi lại các loại ZZ0000ZZ khác nhau
cài đặt được mô tả ở trên nhưng lại mô tả nhiều tùy chọn khác.

3.1.1 Sử dụng DHCP với Sysconfig
-------------------------------

Trong sysconfig, định cấu hình thiết bị với BOOTPROTO='dhcp'
sẽ khiến nó truy vấn DHCP để biết thông tin địa chỉ IP của nó.  Lúc này
viết, điều này không hoạt động đối với các thiết bị liên kết; kịch bản
cố gắng lấy địa chỉ thiết bị từ DHCP trước khi thêm bất kỳ địa chỉ nào
các thiết bị nô lệ.  Nếu không có nô lệ hoạt động, các yêu cầu DHCP sẽ không được thực hiện
được gửi tới mạng.

3.1.2 Cấu hình nhiều liên kết với Sysconfig
-----------------------------------------------

Hệ thống khởi tạo mạng sysconfig có khả năng
xử lý nhiều thiết bị liên kết.  Tất cả những gì cần thiết là dành cho mỗi người
phiên bản liên kết để có tệp ifcfg-bondX được cấu hình phù hợp
(như đã mô tả ở trên).  Không chỉ định tham số "max_bonds" cho bất kỳ
ví dụ về liên kết, vì điều này sẽ gây nhầm lẫn cho sysconfig.  Nếu bạn yêu cầu
nhiều thiết bị liên kết có thông số giống hệt nhau, tạo ra nhiều
các tệp ifcfg-bondX.

Bởi vì các tập lệnh sysconfig cung cấp mô-đun liên kết
các tùy chọn trong tệp ifcfg-bondX, không cần thiết phải thêm chúng vào
các tập tin cấu hình hệ thống ZZ0000ZZ.

3.2 Cấu hình với hỗ trợ Initscripts
------------------------------------------

Phần này áp dụng cho các bản phân phối sử dụng phiên bản gần đây của
các bản initscript có hỗ trợ liên kết, ví dụ: Red Hat Enterprise Linux
phiên bản 3 trở lên, Fedora, v.v. Trên các hệ thống này, mạng
các tập lệnh khởi tạo có kiến thức về liên kết và có thể được cấu hình để
điều khiển các thiết bị liên kết.  Lưu ý rằng các phiên bản cũ hơn của bản initscript
gói có mức hỗ trợ liên kết thấp hơn; điều này sẽ được ghi chú ở đâu
áp dụng.

Các bản phân phối này sẽ không tự động tải bộ điều hợp mạng
driver trừ khi thiết bị ethX được định cấu hình bằng địa chỉ IP.
Vì hạn chế này, người dùng phải cấu hình thủ công một
tập tin tập lệnh mạng cho tất cả các bộ điều hợp vật lý sẽ là thành viên của
một liên kết bondX.  Các tập tin script mạng được đặt trong thư mục:

/etc/sysconfig/network-scripts

Tên tệp phải có tiền tố là "ifcfg-eth" và có hậu tố
với số bộ điều hợp vật lý của bộ điều hợp.  Ví dụ, kịch bản
đối với eth0 sẽ được đặt tên là /etc/sysconfig/network-scripts/ifcfg-eth0.
Đặt văn bản sau vào tệp::

DEVICE=eth0
	USERCTL=không
	ONBOOT=có
	MASTER=trái phiếu0
	SLAVE=có
	BOOTPROTO=không có

Dòng DEVICE= sẽ khác nhau đối với mỗi thiết bị ethX và
phải tương ứng với tên của tệp, tức là ifcfg-eth1 phải có
một dòng thiết bị DEVICE=eth1.  Cài đặt của dòng MASTER= sẽ
cũng phụ thuộc vào tên giao diện liên kết cuối cùng được chọn cho liên kết của bạn.
Giống như các thiết bị mạng khác, các thiết bị này thường bắt đầu từ 0 và tăng lên
một cho mỗi thiết bị, tức là phiên bản liên kết đầu tiên là bond0, phiên bản
thứ hai là bond1, v.v.

Tiếp theo, tạo tập lệnh mạng trái phiếu.  Tên tập tin cho việc này
tập lệnh sẽ là /etc/sysconfig/network-scripts/ifcfg-bondX trong đó X là
số lượng trái phiếu.  Đối với bond0, tệp có tên là "ifcfg-bond0",
đối với trái phiếu1, nó được đặt tên là "ifcfg-bond1", v.v.  Trong tập tin đó,
đặt văn bản sau::

DEVICE=trái phiếu0
	IPADDR=192.168.1.1
	NETMASK=255.255.255.0
	NETWORK=192.168.1.0
	BROADCAST=192.168.1.255
	ONBOOT=có
	BOOTPROTO=không có
	USERCTL=không

Đảm bảo thay đổi các dòng cụ thể của mạng (IPADDR,
NETMASK, NETWORK và BROADCAST) để phù hợp với cấu hình mạng của bạn.

Đối với các phiên bản mới hơn của bản initscript, chẳng hạn như phiên bản được tìm thấy với Fedora
7 (hoặc mới hơn) và Red Hat Enterprise Linux phiên bản 5 (hoặc mới hơn), có thể,
và, thực sự, tốt hơn là chỉ định các tùy chọn liên kết trong ifcfg-bond0
tập tin, ví dụ: một dòng có định dạng::

BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254"

sẽ cấu hình liên kết với các tùy chọn được chỉ định.  Các tùy chọn
được chỉ định trong BONDING_OPTS giống hệt với các tham số mô-đun liên kết
ngoại trừ trường arp_ip_target khi sử dụng các phiên bản initscript cũ hơn
hơn và 8.57 (Fedora 8) và 8.45.19 (Red Hat Enterprise Linux 5.2).  Khi nào
sử dụng các phiên bản cũ hơn, mỗi mục tiêu nên được đưa vào dưới dạng một tùy chọn riêng biệt và
phải được đặt trước bởi dấu '+' để cho biết nó cần được thêm vào danh sách
mục tiêu được truy vấn, ví dụ:::

arp_ip_target=+192.168.1.1 arp_ip_target=+192.168.1.2

là cú pháp thích hợp để chỉ định nhiều mục tiêu.  Khi chỉ định
tùy chọn qua BONDING_OPTS, không cần chỉnh sửa
ZZ0000ZZ.

Đối với các phiên bản cũ hơn của bản initscript không hỗ trợ
BONDING_OPTS, cần phải chỉnh sửa /etc/modprobe.d/*.conf, tùy thuộc vào
bản phân phối của bạn) để tải mô-đun liên kết với các tùy chọn mong muốn của bạn khi
giao diện bond0 được đưa lên.  Các dòng sau trong /etc/modprobe.d/*.conf
sẽ tải mô-đun liên kết và chọn các tùy chọn của nó:

liên kết bí danh bond0
	tùy chọn bond0 mode=balance-alb miimon=100

Thay thế các tham số mẫu bằng bộ thông số thích hợp
tùy chọn cho cấu hình của bạn.

Cuối cùng chạy "/etc/rc.d/init.d/network restart" với quyền root.  Cái này
sẽ khởi động lại hệ thống con mạng và liên kết trái phiếu của bạn bây giờ sẽ là
lên và chạy.

3.2.1 Sử dụng DHCP với bản initscript
---------------------------------

Các phiên bản gần đây của initscript (phiên bản được cung cấp cùng với Fedora
Core 3 và Red Hat Enterprise Linux 4 hoặc các phiên bản mới hơn được báo cáo tới
work) có hỗ trợ gán thông tin IP cho các thiết bị liên kết thông qua
DHCP.

Để định cấu hình liên kết cho DHCP, hãy định cấu hình nó như mô tả
ở trên, ngoại trừ thay thế dòng "BOOTPROTO=none" bằng "BOOTPROTO=dhcp"
và thêm một dòng bao gồm "TYPE=Bonding".  Lưu ý rằng giá trị TYPE
có phân biệt chữ hoa chữ thường.

3.2.2 Định cấu hình nhiều liên kết bằng chữ initscript
-------------------------------------------------

Các gói initscripts đi kèm với Fedora 7 và Red Hat
Enterprise Linux 5 hỗ trợ nhiều giao diện liên kết bằng cách đơn giản
chỉ định BONDING_OPTS= thích hợp trong ifcfg-bondX trong đó X là
số trái phiếu.  Hỗ trợ này yêu cầu hỗ trợ sysfs trong kernel,
và trình điều khiển liên kết phiên bản 3.0.0 trở lên.  Các cấu hình khác có thể
không hỗ trợ phương pháp này để chỉ định nhiều giao diện liên kết; cho
những trường hợp đó, hãy xem phần "Định cấu hình nhiều liên kết theo cách thủ công",
bên dưới.

3.3 Định cấu hình liên kết thủ công với iproute2
-----------------------------------------------

Phần này áp dụng cho các bản phân phối có quá trình khởi tạo mạng
các tập lệnh (gói sysconfig hoặc initscripts) không có địa chỉ cụ thể
kiến thức về sự gắn kết.  Một bản phân phối như vậy là SuSE Linux Enterprise Server
phiên bản 8.

Phương pháp chung cho các hệ thống này là đặt liên kết
tham số mô-đun vào tệp cấu hình trong /etc/modprobe.d/ (dưới dạng
thích hợp cho bản phân phối đã cài đặt), sau đó thêm modprobe và/hoặc
Các lệnh ZZ0000ZZ tới tập lệnh init toàn cầu của hệ thống.  Tên của
tập lệnh init toàn cầu khác nhau; đối với sysconfig, nó là
/etc/init.d/boot.local và đối với initscript thì đó là /etc/rc.d/rc.local.

Ví dụ: nếu bạn muốn tạo một liên kết đơn giản gồm hai e100
các thiết bị (được cho là eth0 và eth1) và tồn tại trên khắp
khởi động lại, chỉnh sửa tệp thích hợp (/etc/init.d/boot.local hoặc
/etc/rc.d/rc.local) và thêm thông tin sau ::

chế độ liên kết modprobe=balance-alb miimon=100
	modprobe e100
	ifconfig bond0 192.168.1.1 netmask 255.255.255.0 trở lên
	bộ liên kết ip eth0 trái phiếu chính0
	liên kết ip đặt eth1 master bond0

Thay thế các tham số mô-đun liên kết ví dụ và bond0
cấu hình mạng (địa chỉ IP, netmask, v.v.) với thông tin thích hợp
giá trị cho cấu hình của bạn.

Thật không may, phương pháp này sẽ không cung cấp hỗ trợ cho
tập lệnh ifup và ifdown trên thiết bị liên kết.  Để tải lại liên kết
cấu hình, cần phải chạy tập lệnh khởi tạo, ví dụ:::

# /etc/init.d/boot.local

hoặc::

# /etc/rc.d/rc.local

Trong trường hợp như vậy, có thể nên tạo một tập lệnh riêng
chỉ khởi tạo cấu hình liên kết, sau đó gọi đó
tập lệnh riêng biệt từ bên trong boot.local.  Điều này cho phép sự liên kết được
được kích hoạt mà không cần chạy lại toàn bộ tập lệnh init toàn cục.

Để tắt các thiết bị liên kết, trước tiên cần phải
đánh dấu chính thiết bị liên kết đang ngừng hoạt động, sau đó tháo
mô-đun trình điều khiển thiết bị thích hợp.  Đối với ví dụ của chúng tôi ở trên, bạn có thể làm
sau đây::

# ifconfig trái phiếu0 xuống
	Liên kết # rmmod
	# rmmod e100

Một lần nữa, để thuận tiện, có thể nên tạo một tập lệnh
với các lệnh này.


3.3.1 Cấu hình nhiều liên kết theo cách thủ công
-----------------------------------------

Phần này chứa thông tin về cách cấu hình nhiều
các thiết bị liên kết với các tùy chọn khác nhau cho những hệ thống có mạng
tập lệnh khởi tạo thiếu hỗ trợ để định cấu hình nhiều liên kết.

Nếu bạn yêu cầu nhiều thiết bị liên kết nhưng tất cả đều có cùng một
tùy chọn, bạn có thể muốn sử dụng tham số mô-đun "max_bonds",
được ghi lại ở trên.

Để tạo ra nhiều thiết bị liên kết với các tùy chọn khác nhau, cần
tốt hơn là sử dụng các tham số liên kết được xuất bởi sysfs, được ghi lại trong
phần bên dưới.

Đối với các phiên bản liên kết không hỗ trợ sysfs, phương tiện duy nhất để
cung cấp nhiều trường hợp liên kết với các tùy chọn khác nhau là tải
trình điều khiển liên kết nhiều lần.  Lưu ý rằng các phiên bản hiện tại của
tập lệnh khởi tạo mạng sysconfig tự động xử lý việc này; nếu
bản phân phối của bạn sử dụng các tập lệnh này, không cần thực hiện hành động đặc biệt nào.  Xem
phần Định cấu hình Thiết bị Liên kết ở trên, nếu bạn không chắc chắn về
kịch bản khởi tạo mạng.

Để tải nhiều phiên bản của mô-đun, cần phải
chỉ định một tên khác nhau cho mỗi phiên bản (hệ thống tải mô-đun
yêu cầu mọi mô-đun được tải, thậm chí nhiều phiên bản của cùng một
mô-đun, có một tên duy nhất).  Điều này được thực hiện bằng cách cung cấp nhiều
bộ tùy chọn liên kết trong ZZ0000ZZ, ví dụ::

liên kết bí danh bond0
	tùy chọn bond0 -o bond0 mode=balance-rr miimon=100

liên kết bí danh bond1
	tùy chọn bond1 -o bond1 mode=balance-alb miimon=50

sẽ tải mô-đun liên kết hai lần.  Trường hợp đầu tiên là
được đặt tên là "bond0" và tạo thiết bị bond0 ở chế độ Balance-rr với
miimon là 100. Phiên bản thứ hai có tên là "bond1" và tạo ra
thiết bị bond1 ở chế độ cân bằng alb với miimon là 50.

Trong một số trường hợp (thường là với các bản phân phối cũ hơn),
ở trên không hoạt động và trường hợp liên kết thứ hai không bao giờ nhìn thấy
các tùy chọn của nó.  Trong trường hợp đó, dòng tùy chọn thứ hai có thể được thay thế
như sau::

cài đặt bond1 /sbin/modprobe --ignore-install liên kết -o bond1 \
				     mode=cân bằng-alb miimon=50

Điều này có thể được lặp lại bất kỳ số lần nào, chỉ định một địa chỉ mới và
tên duy nhất thay cho bond1 cho mỗi phiên bản tiếp theo.

Người ta nhận thấy rằng một số hạt nhân do Red Hat cung cấp không thể
để đổi tên các mô-đun tại thời điểm tải (phần "-o bond1").  Nỗ lực vượt qua
tùy chọn modprobe đó sẽ tạo ra lỗi "Thao tác không được phép".
Điều này đã được báo cáo trên một số hạt nhân Fedora Core và đã được nhìn thấy trên
RHEL 4 cũng vậy.  Trên các hạt nhân có vấn đề này, sẽ không thể
để định cấu hình nhiều liên kết với các tham số khác nhau (vì chúng cũ hơn
hạt nhân và cũng thiếu hỗ trợ sysfs).

3.4 Định cấu hình liên kết thủ công thông qua Sysfs
------------------------------------------

Bắt đầu từ phiên bản 3.0.0, Liên kết kênh có thể được định cấu hình
thông qua giao diện sysfs.  Giao diện này cho phép cấu hình động
của tất cả các liên kết trong hệ thống mà không cần dỡ bỏ mô-đun.  Nó cũng
cho phép thêm và xóa trái phiếu khi chạy.  Ifenslave thì không
cần nhiều thời gian hơn, mặc dù nó vẫn được hỗ trợ.

Việc sử dụng giao diện sysfs cho phép bạn sử dụng nhiều liên kết
với các cấu hình khác nhau mà không cần phải tải lại mô-đun.
Nó cũng cho phép bạn sử dụng nhiều liên kết có cấu hình khác nhau khi
liên kết được biên dịch vào kernel.

Bạn phải gắn hệ thống tập tin sysfs để định cấu hình
gắn kết theo cách này.  Các ví dụ trong tài liệu này giả định rằng bạn
đang sử dụng điểm gắn kết tiêu chuẩn cho sysfs, ví dụ: /sys.  Nếu bạn
hệ thống tập tin sysfs được gắn ở nơi khác, bạn sẽ cần điều chỉnh
đường dẫn ví dụ tương ứng.

Tạo và hủy bỏ trái phiếu
-----------------------------
Để thêm một trái phiếu mới foo::

# echo +foo > /sys/class/net/bonding_masters

Để xóa thanh trái phiếu hiện có::

# echo -bar > /sys/class/net/bonding_masters

Để hiển thị tất cả các trái phiếu hiện có::

# cat /sys/class/net/bonding_masters

.. note::

   due to 4K size limitation of sysfs files, this list may be
   truncated if you have more than a few hundred bonds.  This is unlikely
   to occur under normal operating conditions.

Thêm và xóa nô lệ
--------------------------
Các giao diện có thể bị bắt làm nô lệ cho một trái phiếu bằng cách sử dụng tệp
/sys/class/net/<bond>/bonding/slaves.  Ngữ nghĩa của tập tin này
giống như đối với tệp Bond_masters.

Để biến giao diện eth0 thành nô lệ cho trái phiếu0::

# ifconfig trái phiếu0 lên
	# echo +eth0 > /sys/class/net/bond0/bonding/slaves

Để giải phóng nô lệ eth0 khỏi trái phiếu bond0::

# echo -eth0 > /sys/class/net/bond0/bonding/slaves

Khi một giao diện bị bắt làm nô lệ cho một liên kết, các liên kết tượng trưng giữa
hai cái được tạo trong hệ thống tập tin sysfs.  Trong trường hợp này, bạn sẽ nhận được
/sys/class/net/bond0/slave_eth0 trỏ đến /sys/class/net/eth0 và
/sys/class/net/eth0/master trỏ đến /sys/class/net/bond0.

Điều này có nghĩa là bạn có thể nhanh chóng biết liệu một
giao diện bị bắt làm nô lệ bằng cách tìm kiếm liên kết tượng trưng chính.  Như vậy:
# echo -eth0 > /sys/class/net/eth0/master/bonding/slaves
sẽ giải phóng eth0 khỏi bất kỳ mối ràng buộc nào mà nó bị bắt làm nô lệ, bất kể
tên của giao diện trái phiếu.

Thay đổi cấu hình của trái phiếu
-------------------------------
Mỗi liên kết có thể được cấu hình riêng lẻ bằng cách thao tác
các tập tin nằm trong /sys/class/net/<bond name>/bonding

Tên của các tệp này tương ứng trực tiếp với lệnh-
các tham số dòng được mô tả ở nơi khác trong tệp này và với
ngoại trừ arp_ip_target, chúng chấp nhận các giá trị giống nhau.  Để xem
cài đặt hiện tại, chỉ cần chọn tệp thích hợp.

Một vài ví dụ sẽ được đưa ra ở đây; để sử dụng cụ thể
hướng dẫn cho từng tham số, hãy xem phần thích hợp trong phần này
tài liệu.

Để định cấu hình bond0 cho chế độ cân bằng alb::

# ifconfig trái phiếu0 xuống
	# echo 6 > /sys/class/net/bond0/bonding/mode
	- hoặc -
	Cân bằng # echo-alb > /sys/class/net/bond0/bonding/mode

.. note::

   The bond interface must be down before the mode can be changed.

Để bật giám sát MII trên bond0 với khoảng thời gian 1 giây::

# echo 1000 > /sys/class/net/bond0/bonding/miimon

.. note::

   If ARP monitoring is enabled, it will disabled when MII
   monitoring is enabled, and vice-versa.

Để thêm mục tiêu ARP::

# echo +192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target
	# echo +192.168.0.101 > /sys/class/net/bond0/bonding/arp_ip_target

.. note::

   up to 16 target addresses may be specified.

Để xóa mục tiêu ARP::

# echo -192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target

Để định cấu hình khoảng thời gian giữa các lần truyền gói học::

# echo 12 > /sys/class/net/bond0/bonding/lp_interval

.. note::

   the lp_interval is the number of seconds between instances where
   the bonding driver sends learning packets to each slaves peer switch.  The
   default interval is 1 second.

Cấu hình ví dụ
---------------------
Chúng ta bắt đầu với ví dụ tương tự được trình bày trong phần 3.3,
được thực thi bằng sysfs và không sử dụng ifenslave.

Để tạo liên kết đơn giản giữa hai thiết bị e100 (được coi là eth0
và eth1), và để nó tồn tại qua các lần khởi động lại, hãy chỉnh sửa phần thích hợp
tệp (/etc/init.d/boot.local hoặc /etc/rc.d/rc.local) và thêm
sau đây::

liên kết modprobe
	modprobe e100
	echo Balance-alb > /sys/class/net/bond0/bonding/mode
	ifconfig bond0 192.168.1.1 netmask 255.255.255.0 trở lên
	echo 100 > /sys/class/net/bond0/bonding/miimon
	echo +eth0 > /sys/class/net/bond0/bonding/slaves
	echo +eth1 > /sys/class/net/bond0/bonding/slaves

Để thêm liên kết thứ hai, với hai giao diện e1000 trong
chế độ sao lưu hoạt động, sử dụng giám sát ARP, thêm các dòng sau vào
tập lệnh init của bạn::

modprobe e1000
	echo +bond1 > /sys/class/net/bonding_masters
	echo active-backup > /sys/class/net/bond1/bonding/mode
	ifconfig bond1 192.168.2.1 netmask 255.255.255.0 trở lên
	echo +192.168.2.100 /sys/class/net/bond1/bonding/arp_ip_target
	echo 2000 > /sys/class/net/bond1/bonding/arp_interval
	echo +eth2 > /sys/class/net/bond1/bonding/slaves
	echo +eth3 > /sys/class/net/bond1/bonding/slaves

3.5 Cấu hình với hỗ trợ giao diện
-----------------------------------------

Phần này áp dụng cho các bản phân phối sử dụng tệp /etc/network/interfaces
để mô tả cấu hình giao diện mạng, đáng chú ý nhất là Debian và
các dẫn xuất.

Các lệnh ifup và ifdown trên Debian không hỗ trợ liên kết ra khỏi
cái hộp. Nên cài đặt gói ifenslave-2.6 để cung cấp liên kết
hỗ trợ.  Sau khi cài đặt, gói này sẽ cung cấp các tùy chọn ZZ0000ZZ
được sử dụng vào /etc/network/interfaces.

Lưu ý rằng gói ifenslave-2.6 sẽ tải mô-đun liên kết và sử dụng
lệnh ifenslave khi thích hợp.

Cấu hình ví dụ
----------------------

Trong /etc/network/interfaces, khổ thơ sau sẽ cấu hình bond0, trong
chế độ sao lưu hoạt động, với eth0 và eth1 làm nô lệ::

trái phiếu tự động0
	iface bond0 inet dhcp
		nô lệ trái phiếu eth0 eth1
		sao lưu hoạt động chế độ liên kết
		trái phiếu-miimon 100
		trái phiếu chính eth0 eth1

Nếu cấu hình trên không hoạt động, có thể hệ thống của bạn đang sử dụng
upstart để khởi động hệ thống. Điều này đặc biệt đúng đối với gần đây
Các phiên bản Ubuntu. Đoạn thơ sau trong /etc/network/interfaces sẽ
tạo ra kết quả tương tự trên các hệ thống đó ::

trái phiếu tự động0
	iface bond0 inet dhcp
		không có nô lệ nào cả
		sao lưu hoạt động chế độ liên kết
		trái phiếu-miimon 100

tự động eth0
	hướng dẫn sử dụng iface eth0 inet
		trái phiếu chủ trái phiếu0
		trái phiếu chính eth0 eth1

tự động eth1
	hướng dẫn sử dụng iface eth1 inet
		trái phiếu chủ trái phiếu0
		trái phiếu chính eth0 eth1

Để biết danh sách đầy đủ các tùy chọn được hỗ trợ ZZ0000ZZ trong /etc/network/interfaces và
một số ví dụ nâng cao hơn phù hợp với các bản phân phối cụ thể của bạn, hãy xem các tệp trong
/usr/share/doc/ifenslave-2.6.

3.6 Cấu hình ghi đè cho các trường hợp đặc biệt
----------------------------------------------

Khi sử dụng trình điều khiển liên kết, cổng vật lý truyền khung là
thường được chọn bởi trình điều khiển liên kết và không liên quan đến người dùng hoặc
quản trị viên hệ thống.  Cổng đầu ra được chọn đơn giản bằng cách sử dụng các chính sách của
chế độ liên kết đã chọn.  Tuy nhiên, đôi khi, sẽ rất hữu ích khi hướng dẫn một số
các lớp lưu lượng đến các giao diện vật lý nhất định trên đầu ra để thực hiện
chính sách phức tạp hơn một chút.  Ví dụ: để truy cập máy chủ web qua
giao diện ngoại quan trong đó eth0 kết nối với mạng riêng, trong khi eth1
kết nối thông qua mạng công cộng, có thể muốn làm thiên vị trái phiếu để gửi nói trên
lưu lượng truy cập qua eth0 trước tiên, chỉ sử dụng eth1 làm dự phòng, trong khi tất cả lưu lượng truy cập khác
có thể được gửi một cách an toàn qua một trong hai giao diện.  Cấu hình như vậy có thể đạt được
sử dụng các tiện ích điều khiển lưu lượng vốn có trong linux.

Theo mặc định, trình điều khiển liên kết nhận biết nhiều hàng đợi và 16 hàng đợi được tạo
khi trình điều khiển khởi chạy (xem Tài liệu/mạng/multiqueue.rst
để biết chi tiết).  Nếu muốn có nhiều hoặc ít hàng đợi thì tham số mô-đun
tx_queues có thể được sử dụng để thay đổi giá trị này.  Không có tham số sysfs
có sẵn khi việc phân bổ được thực hiện tại thời điểm bắt đầu mô-đun.

Đầu ra của tệp /proc/net/bonding/bondX đã thay đổi nên Hàng đợi đầu ra
ID hiện được in cho mỗi nô lệ::

Chế độ liên kết: khả năng chịu lỗi (sao lưu tích cực)
	Nô lệ chính: Không có
	Nô lệ hiện đang hoạt động: eth0
	MII Trạng thái: lên
	Khoảng thời gian bỏ phiếu MII (ms): 0
	Độ trễ lên (ms): 0
	Độ trễ xuống (ms): 0

Giao diện nô lệ: eth0
	MII Trạng thái: lên
	Số lỗi liên kết: 0
	Địa chỉ CTNH cố định: 00:1a:a0:12:8f:cb
	ID hàng đợi nô lệ: 0

Giao diện nô lệ: eth1
	MII Trạng thái: lên
	Số lỗi liên kết: 0
	Địa chỉ CTNH cố định: 00:1a:a0:12:8f:cc
	ID hàng đợi nô lệ: 2

queue_id cho nô lệ có thể được đặt bằng lệnh ::

# echo "eth1:2" > /sys/class/net/bond0/bonding/queue_id

Bất kỳ giao diện nào cần bộ queue_id đều phải đặt nó với nhiều lệnh gọi
tương tự như trên cho đến khi mức độ ưu tiên phù hợp được đặt cho tất cả các giao diện.  Bật
các bản phân phối cho phép cấu hình thông qua initscripts, nhiều 'queue_id'
các đối số có thể được thêm vào BONDING_OPTS để đặt tất cả các hàng đợi nô lệ cần thiết.

Các id hàng đợi này có thể được sử dụng cùng với tiện ích tc để định cấu hình
một qdisc nhiều hàng đợi và các bộ lọc để phân biệt lưu lượng truy cập nhất định để truyền trên một số
thiết bị nô lệ.  Ví dụ: giả sử chúng tôi muốn, trong cấu hình trên
buộc tất cả lưu lượng truy cập bị ràng buộc tới 192.168.1.100 sử dụng eth1 trong trái phiếu làm đầu ra
thiết bị. Các lệnh sau sẽ thực hiện điều này::

# tc qdisc thêm dev bond0 xử lý 1 root multiq

Bộ lọc # tc thêm giao thức dev bond0 ip parent 1: prio 1 u32 match ip \
		dst 192.168.1.100 hành động skbedit queue_mapping 2

Các lệnh này yêu cầu kernel đính kèm kỷ luật hàng đợi nhiều hàng đợi vào
giao diện bond0 và lọc lưu lượng truy cập vào hàng đợi đó, sao cho các gói có dst
ip của 192.168.1.100 có giá trị ánh xạ hàng đợi đầu ra được ghi đè thành 2.
Giá trị này sau đó được chuyển vào trình điều khiển, khiến đường dẫn đầu ra bình thường
chính sách lựa chọn sẽ bị ghi đè, thay vào đó hãy chọn qid 2, ánh xạ tới eth1.

Lưu ý rằng giá trị qid bắt đầu từ 1. Qid 0 được dành riêng để khởi tạo trình điều khiển
việc lựa chọn chính sách đầu ra bình thường sẽ diễn ra.  Một lợi ích đơn giản là
để qi cho nô lệ về 0 là nhận thức đa hàng đợi trong liên kết
trình điều khiển hiện có.  Nhận thức này cho phép các bộ lọc tc được đặt trên
thiết bị phụ cũng như thiết bị liên kết và trình điều khiển liên kết sẽ chỉ hoạt động như
chuyển qua để chọn hàng đợi đầu ra trên thiết bị phụ thay vì
lựa chọn cổng đầu ra.

Tính năng này lần đầu tiên xuất hiện trong phiên bản trình điều khiển liên kết 3.7.0 và hỗ trợ cho
Lựa chọn nô lệ đầu ra bị giới hạn ở chế độ quay vòng và sao lưu hoạt động.

3.7 Định cấu hình LACP cho chế độ 802.3ad theo cách an toàn hơn
----------------------------------------------------------

Khi sử dụng chế độ liên kết 802.3ad, Tác nhân (máy chủ) và Đối tác (chuyển đổi)
trao đổi LACPDU.  Những LACPDU này không thể bị đánh hơi được vì chúng
nhằm mục đích liên kết các địa chỉ mac cục bộ (các switch/bridge nào không được
phải chuyển tiếp).  Tuy nhiên, hầu hết các giá trị đều có thể dự đoán dễ dàng
hoặc đơn giản là địa chỉ MAC của máy (được mọi người biết đến một cách tầm thường).
các máy chủ khác trong cùng L2).  Điều này ngụ ý rằng các máy khác trong L2
miền có thể giả mạo các gói LACPDU từ các máy chủ khác tới bộ chuyển mạch và có khả năng
gây ra tình trạng hỗn loạn bằng cách tham gia (từ quan điểm của công tắc) một cái khác
tổng hợp của máy, do đó nhận được một phần trong số các máy chủ gửi đến
lưu lượng truy cập và/hoặc giả mạo lưu lượng truy cập từ chính máy đó (có khả năng
thậm chí chấm dứt thành công một số phần của luồng). Mặc dù đây không phải là
một tình huống có thể xảy ra, người ta có thể tránh khả năng này bằng cách cấu hình
Một số thông số liên kết:

(a) ad_actor_system : Bạn có thể đặt địa chỉ mac ngẫu nhiên có thể được sử dụng cho
       các sàn giao dịch LACPDU này. Giá trị không thể là NULL hoặc Multicast.
       Ngoài ra, tốt nhất là đặt bit quản trị viên cục bộ. Theo mã shell
       tạo một địa chỉ mac ngẫu nhiên như được mô tả ở trên ::

# sys_mac_addr=$(printf '%02x:%02x:%02x:%02x:%02x:%02x' \
				       $(((RANDOM & 0xFE) | 0x02 )) \
				       $(( RANDOM & 0xFF )) \
				       $(( RANDOM & 0xFF )) \
				       $(( RANDOM & 0xFF )) \
				       $(( RANDOM & 0xFF )) \
				       $(( RANDOM & 0xFF )))
	      # echo $sys_mac_addr > /sys/class/net/bond0/bonding/ad_actor_system

(b) ad_actor_sys_prio : Chọn ngẫu nhiên mức độ ưu tiên của hệ thống. Giá trị mặc định
       là 65535, nhưng hệ thống có thể lấy giá trị từ 1 - 65535. Shell sau
       mã tạo mức độ ưu tiên ngẫu nhiên và đặt nó ::

# sys_prio=$(( 1 + RANDOM + RANDOM ))
	    # echo $sys_prio > /sys/class/net/bond0/bonding/ad_actor_sys_prio

(c) ad_user_port_key : Sử dụng phần người dùng của khóa cổng. Mặc định
       giữ trống này. Đây là 10 bit trên của khóa cổng và giá trị
       nằm trong khoảng từ 0 - 1023. Mã shell sau đây tạo ra 10 bit này và
       đặt nó::

# usr_port_key=$((RANDOM & 0x3FF ))
	    # echo $usr_port_key > /sys/class/net/bond0/bonding/ad_user_port_key


4 Truy vấn cấu hình liên kết
=================================

4.1 Cấu hình liên kết
-------------------------

Mỗi thiết bị liên kết có một tệp chỉ đọc nằm trong
thư mục /proc/net/bonding.  Nội dung tập tin bao gồm thông tin
về cấu hình liên kết, các tùy chọn và trạng thái của từng nô lệ.

Ví dụ: nội dung của /proc/net/bonding/bond0 sau
trình điều khiển được tải với các tham số mode=0 và miimon=1000 là
chung như sau::

Trình điều khiển liên kết kênh Ethernet: 2.6.1 (29 tháng 10 năm 2004)
	Chế độ liên kết: cân bằng tải (quay vòng)
	Nô lệ hiện đang hoạt động: eth0
	MII Trạng thái: lên
	Khoảng thời gian bỏ phiếu MII (ms): 1000
	Độ trễ lên (ms): 0
	Độ trễ xuống (ms): 0

Giao diện nô lệ: eth1
	MII Trạng thái: lên
	Số lỗi liên kết: 1

Giao diện nô lệ: eth0
	MII Trạng thái: lên
	Số lỗi liên kết: 1

Định dạng và nội dung chính xác sẽ thay đổi tùy theo
cấu hình liên kết, trạng thái và phiên bản của trình điều khiển liên kết.

4.2 Cấu hình mạng
-------------------------

Cấu hình mạng có thể được kiểm tra bằng ifconfig
lệnh.  Các thiết bị liên kết sẽ có bộ cờ MASTER; nô lệ liên kết
các thiết bị sẽ có bộ cờ SLAVE.  Đầu ra ifconfig không
chứa thông tin về nô lệ nào được liên kết với chủ nào.

Trong ví dụ dưới đây, giao diện bond0 là giao diện chính
(MASTER) trong khi eth0 và eth1 là nô lệ (SLAVE). Chú ý tất cả nô lệ của
bond0 có cùng địa chỉ MAC (HWaddr) như bond0 cho tất cả các chế độ ngoại trừ
TLB và ALB yêu cầu địa chỉ MAC duy nhất cho mỗi nô lệ::

# /sbin/ifconfig
  bond0 Gói liên kết:Ethernet HWaddr 00:C0:F0:1F:37:B4
	    địa chỉ inet:XXX.XXX.XXX.YYY Bcast:XXX.XXX.XXX.255 Mặt nạ:255.255.252.0
	    LÊN BROADCAST RUNNING MASTER MULTICAST MTU:1500 Số liệu:1
	    Gói RX: 7224794 lỗi: 0 bị rớt: 0 tràn: 0 khung: 0
	    Gói TX:3286647 lỗi:1 bị rớt:0 tràn:1 sóng mang:0
	    va chạm:0 txqueuelen:0

eth0 Gói liên kết:Ethernet HWaddr 00:C0:F0:1F:37:B4
	    LÊN BROADCAST RUNNING SLAVE MULTICAST MTU:1500 Số liệu:1
	    Gói RX: 3573025 lỗi: 0 bị rớt: 0 tràn: 0 khung: 0
	    Gói TX: 1643167 lỗi: 1 bị rớt: 0 tràn: 1 sóng mang: 0
	    va chạm:0 txqueuelen:100
	    Ngắt: 10 Địa chỉ cơ sở: 0x1080

eth1 Gói liên kết:Ethernet HWaddr 00:C0:F0:1F:37:B4
	    LÊN BROADCAST RUNNING SLAVE MULTICAST MTU:1500 Số liệu:1
	    Gói RX: 3651769 lỗi: 0 bị rớt: 0 tràn: 0 khung: 0
	    Gói TX: 1643480 lỗi: 0 bị rớt: 0 tràn: 0 nhà cung cấp dịch vụ: 0
	    va chạm:0 txqueuelen:100
	    Ngắt: 9 Địa chỉ cơ sở: 0x1400

5. Cấu hình chuyển đổi
=======================

Đối với phần này, "chuyển đổi" đề cập đến bất kỳ hệ thống nào
các thiết bị ngoại quan được kết nối trực tiếp với (tức là nơi đầu kia của
cáp cắm vào).  Đây có thể là một thiết bị chuyển mạch chuyên dụng thực sự,
hoặc nó có thể là một hệ thống thông thường khác (ví dụ: một máy tính khác đang chạy
Linux),

Các chế độ active-backup, Balance-tlb và Balance-alb không
yêu cầu bất kỳ cấu hình cụ thể nào của switch.

Chế độ 802.3ad yêu cầu switch có
các cổng được định cấu hình dưới dạng tập hợp 802.3ad.  Phương pháp chính xác được sử dụng
để cấu hình điều này thay đổi tùy theo từng switch, nhưng, ví dụ, một
Bộ chuyển mạch dòng Cisco 3550 yêu cầu các cổng thích hợp trước tiên phải được
được nhóm lại với nhau trong một phiên bản etherchannel duy nhất, thì điều đó
etherchannel được đặt ở chế độ "lacp" để bật 802.3ad (thay vì
EtherChannel tiêu chuẩn).

Các chế độ Balance-rr, Balance-xor và phát sóng nói chung
yêu cầu switch phải nhóm các cổng thích hợp lại với nhau.
Danh pháp cho một nhóm như vậy khác nhau giữa các thiết bị chuyển mạch, nó có thể
được gọi là "etherchannel" (như trong ví dụ của Cisco ở trên), một "trung kế
nhóm" hoặc một số biến thể tương tự khác.  Đối với các chế độ này, mỗi công tắc
cũng sẽ có các tùy chọn cấu hình riêng cho việc truyền tải của switch.
chính sách đối với trái phiếu.  Các lựa chọn điển hình bao gồm XOR của MAC hoặc
Địa chỉ IP.  Chính sách truyền tải của hai đồng nghiệp không cần phải
trận đấu.  Đối với ba chế độ này, chế độ liên kết thực sự chọn một
chính sách truyền tải cho nhóm EtherChannel; cả ba sẽ tương tác với nhau
với một nhóm EtherChannel khác.


6. Hỗ trợ 802.1q VLAN
======================

Có thể định cấu hình các thiết bị VLAN qua giao diện liên kết
sử dụng trình điều khiển 8021q.  Tuy nhiên, chỉ các gói đến từ 8021q
driver và chuyển qua liên kết sẽ được gắn thẻ theo mặc định.  bản thân
các gói được tạo, ví dụ: gói học tập của liên kết hoặc ARP
các gói được tạo bởi chế độ ALB hoặc cơ chế giám sát ARP, đều được
được gắn thẻ nội bộ bằng cách liên kết chính nó.  Kết quả là sự liên kết phải
"tìm hiểu" ID VLAN được định cấu hình ở trên và sử dụng các ID đó để gắn thẻ
các gói tin tự tạo.

Vì lý do đơn giản và để hỗ trợ việc sử dụng bộ điều hợp
có thể thực hiện giảm tải tăng tốc phần cứng VLAN, liên kết
giao diện tự tuyên bố là có khả năng giảm tải phần cứng hoàn toàn, nó sẽ nhận được
thông báo add_vid/kill_vid để thu thập thông tin cần thiết
thông tin, và nó truyền bá những hành động đó đến các nô lệ.  Trong trường hợp
của các loại bộ điều hợp hỗn hợp, các gói được gắn thẻ được tăng tốc phần cứng
nên thông qua một bộ chuyển đổi không có khả năng giảm tải
"không được tăng tốc" bởi trình điều khiển liên kết nên thẻ VLAN nằm trong
vị trí thường xuyên.

Giao diện VLAN ZZ0000ZZ được thêm vào bên trên giao diện liên kết
chỉ sau khi bắt ít nhất một nô lệ làm nô lệ.  Giao diện liên kết có
địa chỉ phần cứng là 00:00:00:00:00:00 cho đến khi Slave đầu tiên được thêm vào.
Nếu giao diện VLAN được tạo trước lần nô lệ đầu tiên, nó
sẽ nhận địa chỉ phần cứng toàn số 0.  Từng là nô lệ đầu tiên
được gắn vào liên kết, chính thiết bị liên kết sẽ nhận
địa chỉ phần cứng của nô lệ, sau đó có sẵn cho thiết bị VLAN.

Ngoài ra, hãy lưu ý rằng vấn đề tương tự có thể xảy ra nếu tất cả nô lệ
được giải phóng khỏi một liên kết vẫn còn một hoặc nhiều giao diện VLAN trên
trên hết.  Khi một nô lệ mới được thêm vào, giao diện liên kết sẽ
lấy địa chỉ phần cứng của nó từ nô lệ đầu tiên, có thể không
khớp với địa chỉ phần cứng của giao diện VLAN (được
cuối cùng được sao chép từ một nô lệ trước đó).

Có hai phương pháp để đảm bảo thiết bị VLAN hoạt động
với địa chỉ phần cứng chính xác nếu tất cả các nô lệ bị xóa khỏi một
giao diện trái phiếu:

1. Xóa tất cả các giao diện VLAN sau đó tạo lại chúng

2. Đặt địa chỉ phần cứng của giao diện liên kết sao cho nó
khớp với địa chỉ phần cứng của giao diện VLAN.

Lưu ý rằng việc thay đổi địa chỉ CTNH của giao diện VLAN sẽ đặt
thiết bị cơ bản -- tức là giao diện liên kết -- với sự bừa bãi
chế độ, có thể không phải là điều bạn muốn.


7. Giám sát liên kết
==================

Trình điều khiển liên kết hiện nay hỗ trợ hai sơ đồ cho
giám sát trạng thái liên kết của thiết bị phụ: màn hình ARP và MII
màn hình.

Hiện nay, do những hạn chế trong việc triển khai
chính trình điều khiển liên kết, không thể kích hoạt cả ARP và MII
giám sát đồng thời.

7.1 ARP Giám sát hoạt động
-------------------------

Màn hình ARP hoạt động đúng như tên gọi của nó: nó gửi ARP
truy vấn tới một hoặc nhiều hệ thống ngang hàng được chỉ định trên mạng và
sử dụng phản hồi như một dấu hiệu cho thấy liên kết đang hoạt động.  Cái này
đưa ra một số đảm bảo rằng lưu lượng truy cập thực sự đang chảy đến và đi từ một
hoặc nhiều đồng nghiệp trên mạng cục bộ.

7.2 Định cấu hình nhiều mục tiêu ARP
------------------------------------

Mặc dù việc giám sát ARP có thể được thực hiện chỉ với một mục tiêu, nhưng nó có thể
hữu ích trong thiết lập Tính sẵn sàng cao để có một số mục tiêu cần thực hiện
màn hình.  Trong trường hợp chỉ có một mục tiêu, bản thân mục tiêu đó có thể đi
ngừng hoạt động hoặc gặp sự cố khiến nó không phản hồi với các yêu cầu ARP.  có
một mục tiêu bổ sung (hoặc một số) làm tăng độ tin cậy của ARP
giám sát.

Nhiều mục tiêu ARP phải được phân tách bằng dấu phẩy như sau::

Tùy chọn # example để giám sát ARP với ba mục tiêu
 liên kết bí danh bond0
 tùy chọn trái phiếu0 arp_interval=60 arp_ip_target=192.168.0.1,192.168.0.3,192.168.0.9

Đối với chỉ một mục tiêu duy nhất, các tùy chọn sẽ giống ::

Tùy chọn # example để giám sát ARP với một mục tiêu
    liên kết bí danh bond0
    tùy chọn trái phiếu0 arp_interval=60 arp_ip_target=192.168.0.100


7.3 MII Giám sát hoạt động
-------------------------

Màn hình MII chỉ giám sát trạng thái sóng mang của mạng cục bộ
giao diện mạng.  Nó thực hiện điều này theo một trong ba cách: bằng cách
tùy thuộc vào trình điều khiển thiết bị để duy trì trạng thái sóng mang của nó, bằng cách
truy vấn các thanh ghi MII của thiết bị hoặc bằng cách thực hiện truy vấn ethtool tới
thiết bị.

Màn hình MII dựa vào trình điều khiển để biết thông tin trạng thái sóng mang (thông qua
hệ thống con netif_carrier).

8. Nguồn rắc rối tiềm ẩn
===============================

8.1 Cuộc phiêu lưu trong định tuyến
-------------------------

Khi liên kết được cấu hình, điều quan trọng là thiết bị phụ
thiết bị không có tuyến đường thay thế tuyến đường chính (hoặc,
nói chung là không có lộ trình nào cả).  Ví dụ, giả sử liên kết
thiết bị bond0 có hai nô lệ, eth0 và eth1 và bảng định tuyến là
như sau::

Bảng định tuyến IP hạt nhân
  Cờ Genmask Cổng đích MSS Cửa sổ irtt Ifa
  10.0.0.0 0.0.0.0 255.255.0.0 U 40 0 0 eth0
  10.0.0.0 0.0.0.0 255.255.0.0 U 40 0 0 eth1
  10.0.0.0 0.0.0.0 255.255.0.0 U 40 0 0 trái phiếu0
  127.0.0.0 0.0.0.0 255.0.0.0 U 40 0 0 lo

Cấu hình định tuyến này có thể vẫn sẽ cập nhật
thời gian nhận/truyền trong trình điều khiển (cần thiết cho màn hình ARP), nhưng
có thể bỏ qua trình điều khiển liên kết (vì lưu lượng truy cập đi tới, trong này
trường hợp, một máy chủ khác trên mạng 10 sẽ sử dụng eth0 hoặc eth1 trước bond0).

Màn hình ARP (và chính ARP) có thể bị nhầm lẫn vì điều này
cấu hình, vì các yêu cầu ARP (được tạo bởi màn hình ARP)
sẽ được gửi trên một giao diện (bond0), nhưng phản hồi tương ứng
sẽ đến trên một giao diện khác (eth0).  Câu trả lời này trông giống như ARP
dưới dạng một câu trả lời ARP không được yêu cầu (vì ARP khớp với các câu trả lời trên một
cơ sở giao diện) và bị loại bỏ.  Màn hình MII không bị ảnh hưởng
theo trạng thái của bảng định tuyến.

Giải pháp ở đây đơn giản là đảm bảo rằng nô lệ không có
các tuyến đường riêng của chúng, và nếu vì lý do nào đó mà chúng phải làm như vậy thì các tuyến đường đó sẽ
không thay thế các tuyến đường của chủ nhân của họ.  Điều này nói chung phải là
trường hợp, nhưng cấu hình bất thường hoặc sai sót thủ công hoặc tĩnh tự động
việc bổ sung tuyến đường có thể gây rắc rối.

8.2 Đổi tên thiết bị Ethernet
----------------------------

Trên các hệ thống có tập lệnh cấu hình mạng không
liên kết trực tiếp các thiết bị vật lý với tên giao diện mạng (vì vậy
rằng cùng một thiết bị vật lý luôn có cùng tên "ethX"), nó có thể
cần thêm một số logic đặc biệt vào các tập tin cấu hình trong
/etc/modprobe.d/.

Ví dụ: cho một module.conf chứa các mục sau ::

liên kết bí danh bond0
	tùy chọn bond0 mode=some-mode miimon=50
	bí danh eth0 tg3
	bí danh eth1 tg3
	bí danh eth2 e1000
	bí danh eth3 e1000

Nếu cả eth0 và eth1 đều không phải là nô lệ của bond0 thì khi
Giao diện bond0 xuất hiện, các thiết bị có thể được sắp xếp lại.  Cái này
xảy ra vì liên kết được tải trước, sau đó là thiết bị phụ của nó
trình điều khiển được tải tiếp theo.  Vì không có trình điều khiển nào khác được tải,
khi trình điều khiển e1000 tải, nó sẽ nhận được eth0 và eth1 cho
thiết bị, nhưng cấu hình liên kết cố gắng bắt eth2 và eth3 làm nô lệ
(sau này có thể được gán cho các thiết bị tg3).

Thêm các mục sau::

thêm liên kết ở trên e1000 tg3

khiến modprobe tải e1000 rồi tg3, theo thứ tự đó, khi
liên kết được tải.  Lệnh này được ghi lại đầy đủ trong
trang hướng dẫn module.conf.

Trên các hệ thống sử dụng modprobe, vấn đề tương tự có thể xảy ra.
Trong trường hợp này, phần sau có thể được thêm vào tệp cấu hình trong
/etc/modprobe.d/ dưới dạng::

liên kết softdep trước: tg3 e1000

Điều này sẽ tải các mô-đun tg3 và e1000 trước khi tải mô-đun liên kết.
Tài liệu đầy đủ về điều này có thể được tìm thấy trong modprobe.d và modprobe
các trang hướng dẫn.

9. Đại lý SNMP
===============

Nếu chạy tác nhân SNMP, trình điều khiển liên kết phải được tải
trước bất kỳ trình điều khiển mạng nào tham gia vào trái phiếu.  Yêu cầu này
là do chỉ mục giao diện (ipAdEntIfIndex) được liên kết với
giao diện đầu tiên được tìm thấy với một địa chỉ IP nhất định.  Tức là có
chỉ một ipAdEntIfIndex cho mỗi địa chỉ IP.  Ví dụ: nếu eth0 và
eth1 là nô lệ của bond0 và trình điều khiển cho eth0 được tải trước
trình điều khiển liên kết, giao diện cho địa chỉ IP sẽ được liên kết
với giao diện eth0.  Cấu hình này được hiển thị bên dưới, IP
địa chỉ 192.168.1.1 có chỉ mục giao diện là 2, lập chỉ mục cho eth0
trong bảng ifDescr (ifDescr.2).

::

giao diện.ifTable.ifEntry.ifDescr.1 = lo
     giao diện.ifTable.ifEntry.ifDescr.2 = eth0
     giao diện.ifTable.ifEntry.ifDescr.3 = eth1
     giao diện.ifTable.ifEntry.ifDescr.4 = eth2
     giao diện.ifTable.ifEntry.ifDescr.5 = eth3
     giao diện.ifTable.ifEntry.ifDescr.6 = bond0
     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.10.10.10 = 5
     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.192.168.1.1 = 2
     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.74.20.94 = 4
     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.127.0.0.1 = 1

Vấn đề này có thể tránh được bằng cách tải trình điều khiển liên kết trước
bất kỳ trình điều khiển mạng nào tham gia vào một trái phiếu.  Dưới đây là một ví dụ về
tải trình điều khiển liên kết trước, địa chỉ IP 192.168.1.1 là
được liên kết chính xác với ifDescr.2.

giao diện.ifTable.ifEntry.ifDescr.1 = lo
     giao diện.ifTable.ifEntry.ifDescr.2 = bond0
     giao diện.ifTable.ifEntry.ifDescr.3 = eth0
     giao diện.ifTable.ifEntry.ifDescr.4 = eth1
     giao diện.ifTable.ifEntry.ifDescr.5 = eth2
     giao diện.ifTable.ifEntry.ifDescr.6 = eth3
     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.10.10.10 = 6
     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.192.168.1.1 = 2
     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.10.74.20.94 = 5
     ip.ipAddrTable.ipAddrEntry.ipAdEntIfIndex.127.0.0.1 = 1

Mặc dù một số bản phân phối có thể không báo cáo tên giao diện trong
ifDescr, mối liên kết giữa địa chỉ IP và IfIndex vẫn còn
và các chức năng SNMP như Interface_Scan_Next sẽ báo cáo rằng
hiệp hội.

10. Chế độ lăng nhăng
====================

Khi chạy các công cụ giám sát mạng, ví dụ: tcpdump, nó
phổ biến để kích hoạt chế độ lăng nhăng trên thiết bị, để tất cả lưu lượng truy cập
được nhìn thấy (thay vì chỉ nhìn thấy lưu lượng truy cập dành cho máy chủ cục bộ).
Trình điều khiển liên kết xử lý các thay đổi chế độ bừa bãi đối với liên kết
thiết bị chính (ví dụ: bond0) và truyền cài đặt tới thiết bị phụ
thiết bị.

Đối với các chế độ Balance-rr, Balance-xor, Broadcast và 802.3ad,
cài đặt chế độ lăng nhăng được truyền tới tất cả các nô lệ.

Đối với các chế độ active-backup, Balance-tlb và Balance-alb,
cài đặt chế độ lăng nhăng chỉ được truyền tới nô lệ đang hoạt động.

Đối với chế độ Balance-tlb, nô lệ hoạt động hiện tại là nô lệ
nhận lưu lượng truy cập vào.

Đối với chế độ cân bằng alb, nô lệ hoạt động là nô lệ được sử dụng làm
"sơ cấp."  Slave này được sử dụng cho lưu lượng điều khiển theo chế độ cụ thể, cho
gửi đến các đồng nghiệp chưa được chỉ định hoặc nếu tải không cân bằng.

Đối với các chế độ active-backup, Balance-tlb và Balance-alb, khi
các thay đổi nô lệ đang hoạt động (ví dụ: do lỗi liên kết),
cài đặt lăng nhăng sẽ được truyền tới nô lệ hoạt động mới.

11. Định cấu hình liên kết để có tính sẵn sàng cao
=============================================

Tính sẵn sàng cao đề cập đến các cấu hình cung cấp
tính khả dụng của mạng tối đa bằng cách có các thiết bị dự phòng hoặc dự phòng,
liên kết hoặc chuyển đổi giữa máy chủ và phần còn lại của thế giới.  các
Mục tiêu là cung cấp khả năng sẵn sàng tối đa của kết nối mạng
(tức là mạng luôn hoạt động), mặc dù các cấu hình khác
có thể cung cấp thông lượng cao hơn.

11.1 Tính sẵn sàng cao trong cấu trúc liên kết chuyển mạch đơn
--------------------------------------------------

Nếu hai máy chủ (hoặc một máy chủ và một switch) được kết nối trực tiếp
được kết nối qua nhiều liên kết vật lý thì không có sẵn
hình phạt để tối ưu hóa băng thông tối đa.  Trong trường hợp này, có
chỉ có một switch (hoặc ngang hàng), nên nếu hỏng thì không có lựa chọn nào khác
quyền truy cập vào thất bại.  Ngoài ra, các chế độ cân bằng tải liên kết
hỗ trợ giám sát liên kết của các thành viên của họ, vì vậy nếu các liên kết riêng lẻ không thành công,
tải sẽ được cân bằng lại trên các thiết bị còn lại.

Xem Phần 12, "Cấu hình liên kết để có thông lượng tối đa"
để biết thông tin về cách định cấu hình liên kết với một thiết bị ngang hàng.

11.2 Tính sẵn sàng cao trong cấu trúc liên kết nhiều switch
----------------------------------------------------

Với nhiều công tắc, cấu hình liên kết và
mạng thay đổi đáng kể.  Trong nhiều cấu trúc liên kết chuyển mạch, có
sự đánh đổi giữa tính khả dụng của mạng và băng thông có thể sử dụng.

Dưới đây là mạng mẫu, được cấu hình để tối đa hóa
tính khả dụng của mạng::

ZZ0000ZZ
		ZZ0001ZZ
	  +------+----+ +------+----+
	  |          |port2 ISL cổng2|          |
	  ZZ0004ZZ
	  ZZ0005ZZ ZZ0006ZZ
	  +------+----+ +------++---+
		ZZ0007ZZ
		ZZ0008ZZ
		+-------------+ máy chủ1 +--------------+
			 eth0 +-------+ eth1

Trong cấu hình này, có một liên kết giữa hai
công tắc (ISL hoặc liên kết công tắc liên) và nhiều cổng kết nối với
thế giới bên ngoài ("port3" trên mỗi switch).  Không có kỹ thuật
lý do là điều này không thể được mở rộng sang công tắc thứ ba.

11.2.1 Lựa chọn chế độ liên kết HA cho cấu trúc liên kết nhiều công tắc
-------------------------------------------------------------

Trong cấu trúc liên kết như ví dụ trên, hoạt động sao lưu và
chế độ phát sóng là chế độ liên kết hữu ích duy nhất khi tối ưu hóa cho
sẵn có; các chế độ khác yêu cầu tất cả các liên kết phải kết thúc trên
cùng một người để họ cư xử hợp lý.

sao lưu tích cực:
	Đây thường là chế độ ưa thích, đặc biệt nếu
	các công tắc có ISL và hoạt động tốt với nhau.  Nếu
	cấu hình mạng sao cho một switch được thiết kế riêng
	một công tắc dự phòng (ví dụ: có công suất thấp hơn, chi phí cao hơn, v.v.),
	thì tùy chọn chính có thể được sử dụng để đảm bảo rằng
	liên kết ưa thích luôn được sử dụng khi nó có sẵn.

phát sóng:
	Chế độ này thực sự là một chế độ có mục đích đặc biệt và phù hợp
	chỉ dành cho những nhu cầu rất cụ thể.  Ví dụ, nếu hai
	các thiết bị chuyển mạch chưa được kết nối (không có ISL) và các mạng bên ngoài
	chúng hoàn toàn độc lập.  Trong trường hợp này, nếu nó
	cần thiết cho một số phương tiện giao thông một chiều cụ thể để tiếp cận cả hai
	mạng độc lập thì chế độ phát sóng có thể phù hợp.

11.2.2 Lựa chọn giám sát liên kết HA cho cấu trúc liên kết nhiều switch
----------------------------------------------------------------

Việc lựa chọn giám sát liên kết cuối cùng phụ thuộc vào
chuyển đổi.  Nếu bộ chuyển mạch có thể bị hỏng các cổng một cách đáng tin cậy để đáp ứng với các cổng khác
không thành công thì màn hình MII hoặc ARP sẽ hoạt động.  cho
Ví dụ, trong ví dụ trên, nếu liên kết "port3" bị lỗi ở điều khiển từ xa
Cuối cùng, màn hình MII không có phương tiện trực tiếp nào để phát hiện điều này.  ARP
màn hình có thể được cấu hình với mục tiêu ở đầu xa của cổng3,
do đó phát hiện lỗi đó mà không cần hỗ trợ chuyển đổi.

Tuy nhiên, nói chung, trong cấu trúc liên kết nhiều switch, ARP
màn hình có thể cung cấp mức độ tin cậy cao hơn trong việc phát hiện điểm cuối
lỗi kết nối cuối (có thể do lỗi của bất kỳ thiết bị nào
thành phần riêng lẻ để vượt qua lưu lượng truy cập vì bất kỳ lý do gì).  Ngoài ra,
màn hình ARP phải được cấu hình với nhiều mục tiêu (ít nhất
một cho mỗi switch trong mạng).  Điều này sẽ đảm bảo rằng,
bất kể công tắc nào đang hoạt động, màn hình ARP đều có công tắc phù hợp
mục tiêu để truy vấn.

Ngoài ra, xin lưu ý rằng gần đây nhiều thiết bị chuyển mạch hiện hỗ trợ chức năng
thường được gọi là "chuyển đổi dự phòng đường trục".  Đây là một tính năng của
switch khiến trạng thái liên kết của một cổng switch cụ thể được thiết lập
xuống (hoặc tăng) khi trạng thái của cổng switch khác giảm (hoặc tăng).
Mục đích của nó là truyền bá các lỗi liên kết từ các cổng "bên ngoài" một cách hợp lý
tới các cổng "nội bộ" hợp lý mà liên kết có thể giám sát thông qua
miimon.  Tính khả dụng và cấu hình cho chuyển đổi dự phòng đường trục khác nhau tùy theo
chuyển đổi, nhưng đây có thể là giải pháp thay thế khả thi cho màn hình ARP khi sử dụng
công tắc phù hợp.

12. Định cấu hình liên kết để có thông lượng tối đa
==============================================

12.1 Tối đa hóa thông lượng trong cấu trúc liên kết chuyển mạch đơn
------------------------------------------------------

Trong cấu hình một switch, phương pháp tốt nhất để tối đa hóa
thông lượng phụ thuộc vào ứng dụng và môi trường mạng.  các
các chế độ cân bằng tải khác nhau đều có điểm mạnh và điểm yếu trong
môi trường khác nhau, như chi tiết dưới đây.

Đối với cuộc thảo luận này, chúng tôi sẽ chia các cấu trúc liên kết thành
hai loại.  Tùy thuộc vào điểm đến của hầu hết lưu lượng truy cập, chúng tôi
phân loại chúng thành cấu hình "cổng" hoặc "cục bộ".

Trong cấu hình có cổng, "công tắc" hoạt động chủ yếu
với tư cách là một bộ định tuyến và phần lớn lưu lượng truy cập đi qua bộ định tuyến này đến
các mạng khác.  Một ví dụ sẽ là như sau::


+----------+ +----------+
     |          |eth0 port1|          | sang các mạng khác
     | Máy chủ A +----------------------+ bộ định tuyến +------------------->
     ZZ0002ZZ Máy chủ B và C đã hết
     |          |eth1 port2|          | ở đây đâu đó
     +----------+ +----------+

Bộ định tuyến có thể là một thiết bị định tuyến chuyên dụng hoặc một máy chủ khác
đóng vai trò là cửa ngõ.  Đối với cuộc thảo luận của chúng tôi, điểm quan trọng là
phần lớn lưu lượng truy cập từ Máy A sẽ đi qua bộ định tuyến tới
một số mạng khác trước khi đến đích cuối cùng.

Trong cấu hình mạng có cổng nối, mặc dù Máy chủ A có thể
giao tiếp với nhiều hệ thống khác, tất cả lưu lượng của nó sẽ được gửi
và được nhận qua một thiết bị ngang hàng khác trên mạng cục bộ, bộ định tuyến.

Lưu ý rằng trường hợp hai hệ thống được kết nối trực tiếp qua
nhiều liên kết vật lý, nhằm mục đích cấu hình liên kết,
giống như cấu hình cổng vào.  Trong trường hợp đó, điều đó xảy ra là tất cả
lưu lượng truy cập được dành cho chính "cổng" chứ không phải một số mạng khác
ngoài cổng.

Trong cấu hình cục bộ, "công tắc" hoạt động chủ yếu như
một công tắc và phần lớn lưu lượng truy cập đi qua công tắc này tới
đến các trạm khác trên cùng một mạng.  Một ví dụ sẽ là
sau đây::

+----------+ +----------+ +--------+
    |          |eth0 cổng1|          +-------+ Host B |
    |  Host A  +------------+  switch  |port3 +--------+
    ZZ0003ZZ +--------+
    |          |eth1 cổng2|          +------------------+ Host C |
    +----------+ +----------+port4 +--------+


Một lần nữa, bộ chuyển mạch có thể là một thiết bị chuyển mạch chuyên dụng hoặc một thiết bị chuyển mạch khác.
máy chủ hoạt động như một cổng.  Đối với cuộc thảo luận của chúng tôi, điểm quan trọng là
rằng phần lớn lưu lượng truy cập từ Máy chủ A được dành cho các máy chủ khác
trên cùng một mạng cục bộ (Máy chủ B và C trong ví dụ trên).

Tóm lại, trong cấu hình có cổng, lưu lượng truy cập đến và đi từ
thiết bị được liên kết sẽ ở cùng cấp độ MAC trên mạng
(chính cổng đó, tức là bộ định tuyến), bất kể kết quả cuối cùng của nó là gì.
điểm đến.  Trong cấu hình cục bộ, lưu lượng truy cập chảy trực tiếp đến và
từ các đích cuối cùng, do đó, mỗi đích (Máy chủ B, Máy chủ C)
sẽ được giải quyết trực tiếp bằng địa chỉ MAC riêng lẻ của họ.

Sự khác biệt giữa mạng cổng và mạng cục bộ
cấu hình rất quan trọng vì nhiều chế độ cân bằng tải
có sẵn, sử dụng địa chỉ MAC của nguồn mạng cục bộ và
đích để đưa ra quyết định cân bằng tải.  Hành vi của mỗi
chế độ được mô tả dưới đây.


12.1.1 Lựa chọn chế độ liên kết MT cho cấu trúc liên kết chuyển mạch đơn
-----------------------------------------------------------

Cấu hình này là dễ thiết lập và dễ hiểu nhất,
mặc dù bạn sẽ phải quyết định chế độ liên kết nào phù hợp nhất với
nhu cầu.  Sự đánh đổi cho từng chế độ được trình bày chi tiết dưới đây:

số dư-rr:
	Chế độ này là chế độ duy nhất cho phép một
	Kết nối TCP/IP để phân luồng lưu lượng trên nhiều
	giao diện. Do đó, đây là chế độ duy nhất cho phép
	một luồng TCP/IP để sử dụng nhiều giao diện
	giá trị thông lượng.  Tuy nhiên, điều này phải trả giá:
	việc phân loại thường dẫn đến các hệ thống ngang hàng nhận các gói tin đi
	trật tự, khiến hệ thống kiểm soát tắc nghẽn của TCP/IP bị ảnh hưởng
	trong, thường bằng cách truyền lại các phân đoạn.

Có thể điều chỉnh giới hạn tắc nghẽn của TCP/IP bằng cách
	thay đổi tham số sysctl net.ipv4.tcp_reordering.  các
	giá trị mặc định thông thường là 3. Nhưng hãy nhớ rằng ngăn xếp TCP có thể
	để tự động tăng mức này khi phát hiện các đơn đặt hàng lại.

Lưu ý rằng tỷ lệ các gói sẽ được phân phối ra khỏi
	thứ tự rất thay đổi và khó có thể bằng 0.  cấp độ
	việc sắp xếp lại đơn hàng phụ thuộc vào nhiều yếu tố, bao gồm
	giao diện mạng, bộ chuyển mạch và cấu trúc liên kết của
	cấu hình.  Nói một cách tổng quát thì mạng tốc độ cao hơn
	thẻ tạo ra nhiều sự sắp xếp lại hơn (do các yếu tố như gói
	hợp nhất) và cấu trúc liên kết "nhiều đến nhiều" sẽ sắp xếp lại theo một
	tốc độ cao hơn cấu hình "nhiều chậm đến một nhanh".

Nhiều thiết bị chuyển mạch không hỗ trợ bất kỳ chế độ phân chia lưu lượng nào
	(thay vì chọn cổng dựa trên địa chỉ cấp IP hoặc MAC);
	đối với những thiết bị đó, lưu lượng truy cập cho một kết nối cụ thể đang chảy
	thông qua việc chuyển sang trái phiếu cân bằng-rr sẽ không sử dụng được nhiều hơn
	hơn giá trị băng thông của một giao diện.

Nếu bạn đang sử dụng các giao thức khác ngoài TCP/IP, UDP cho
	ví dụ và ứng dụng của bạn có thể chịu đựng được tình trạng không theo thứ tự
	phân phối thì chế độ này có thể cho phép gói dữ liệu một luồng
	hiệu suất tăng gần như tuyến tính khi các giao diện được thêm vào
	đến trái phiếu.

Chế độ này yêu cầu switch phải có cổng thích hợp
	được định cấu hình cho "etherchannel" hoặc "trung kế".

sao lưu tích cực:
	Không có nhiều lợi thế trong cấu trúc liên kết mạng này để
	chế độ sao lưu hoạt động, vì tất cả các thiết bị sao lưu không hoạt động đều
	được kết nối với cùng một thiết bị ngang hàng với thiết bị chính.  Trong trường hợp này, một
	chế độ cân bằng tải (với giám sát liên kết) sẽ cung cấp
	cùng mức độ sẵn có của mạng, nhưng với mức tăng
	băng thông sẵn có.  Về mặt tích cực, chế độ sao lưu tích cực
	không yêu cầu bất kỳ cấu hình nào của switch, vì vậy nó có thể
	có giá trị nếu phần cứng sẵn có không hỗ trợ bất kỳ
	các chế độ cân bằng tải.

cân bằng-xor:
	Chế độ này sẽ hạn chế lưu lượng sao cho các gói được gửi đến
	đối với các đồng nghiệp cụ thể sẽ luôn được gửi qua cùng một
	giao diện.  Vì đích đến được xác định bởi MAC
	địa chỉ liên quan, chế độ này hoạt động tốt nhất trong mạng "cục bộ"
	cấu hình (như được mô tả ở trên), với tất cả các đích trên
	cùng một mạng cục bộ.  Chế độ này có thể chưa tối ưu
	nếu tất cả lưu lượng truy cập của bạn được truyền qua một bộ định tuyến duy nhất (tức là một
	cấu hình mạng "cổng", như được mô tả ở trên).

Giống như Balance-rr, các cổng chuyển mạch cần được cấu hình để
	"etherchannel" hoặc "trung kế".

phát sóng:
	Giống như sao lưu hoạt động, việc này không có nhiều lợi thế
	trong loại cấu trúc liên kết mạng này.

802.3ad:
	Chế độ này có thể là một lựa chọn tốt cho loại mạng này
	cấu trúc liên kết.  Chế độ 802.3ad là tiêu chuẩn IEEE, vì vậy tất cả các thiết bị ngang hàng
	việc triển khai 802.3ad sẽ tương tác tốt.  802.3ad
	giao thức bao gồm cấu hình tự động của các tập hợp,
	vì vậy cần có cấu hình thủ công tối thiểu của công tắc
	(thường chỉ để chỉ định rằng một số bộ thiết bị được
	có sẵn cho 802.3ad).  Chuẩn 802.3ad cũng bắt buộc
	các khung đó được phân phối theo thứ tự (trong giới hạn nhất định), vì vậy
	nói chung các kết nối đơn lẻ sẽ không thấy thứ tự sai của
	gói.  Chế độ 802.3ad có một số nhược điểm:
	tiêu chuẩn yêu cầu tất cả các thiết bị trong tổng thể hoạt động ở
	cùng tốc độ và song công.  Ngoài ra, như với tất cả các tải liên kết
	các chế độ cân bằng khác ngoài Balance-rr, sẽ không có kết nối đơn lẻ nào
	có thể sử dụng nhiều giá trị của một giao diện
	băng thông.

Ngoài ra, việc triển khai 802.3ad liên kết linux
	phân phối lưu lượng truy cập theo ngang hàng (sử dụng địa chỉ XOR của MAC
	và ID loại gói), vì vậy trong cấu hình "cổng", tất cả
	lưu lượng đi ra thường sẽ sử dụng cùng một thiết bị.  Đang đến
	lưu lượng truy cập cũng có thể kết thúc trên một thiết bị duy nhất, nhưng đó là
	phụ thuộc vào chính sách cân bằng của 802.3ad của thiết bị ngang hàng
	thực hiện.  Trong cấu hình "cục bộ", lưu lượng truy cập sẽ được
	được phân phối trên các thiết bị trong liên kết.

Cuối cùng, chế độ 802.3ad bắt buộc sử dụng màn hình MII,
	do đó, màn hình ARP không khả dụng ở chế độ này.

số dư-tlb:
	Chế độ cân bằng-tlb cân bằng lưu lượng đi theo ngang hàng.
	Vì việc cân bằng được thực hiện theo địa chỉ MAC nên trong
	cấu hình "gatewayed" (như mô tả ở trên), chế độ này sẽ
	gửi tất cả lưu lượng truy cập trên một thiết bị.  Tuy nhiên, trong một
	cấu hình mạng "cục bộ", chế độ này cân bằng nhiều
	mạng cục bộ ngang hàng trên các thiết bị trong một môi trường thông minh mơ hồ
	(không phải XOR đơn giản như ở chế độ Balance-xor hoặc 802.3ad),
	do đó các địa chỉ MAC không may mắn về mặt toán học (tức là các địa chỉ
	XOR thành cùng một giá trị) sẽ không "tập hợp" tất cả lại trên một
	giao diện.

Không giống như 802.3ad, các giao diện có thể có tốc độ khác nhau và không
	cấu hình chuyển đổi đặc biệt là cần thiết.  Ở phía dưới,
	trong chế độ này tất cả lưu lượng truy cập đến đều đến qua một
	giao diện, chế độ này yêu cầu hỗ trợ ethtool nhất định trong
	trình điều khiển thiết bị mạng của các giao diện phụ và ARP
	màn hình không có sẵn.

cân bằng-alb:
	Chế độ này là tất cả những gì có trong Balance-tlb và hơn thế nữa.
	Nó có tất cả các tính năng (và hạn chế) của Balance-tlb,
	và cũng sẽ cân bằng lưu lượng truy cập đến từ mạng cục bộ
	ngang hàng (như được mô tả trong phần Tùy chọn mô-đun liên kết,
	ở trên).

Mặt trái duy nhất của chế độ này là mạng
	trình điều khiển thiết bị phải hỗ trợ thay đổi địa chỉ phần cứng trong khi
	thiết bị đang mở.

12.1.2 Giám sát liên kết MT cho cấu trúc liên kết chuyển mạch đơn
----------------------------------------------------

Việc lựa chọn giám sát liên kết có thể phụ thuộc phần lớn vào việc
chế độ bạn chọn sử dụng.  Các chế độ cân bằng tải nâng cao hơn không
hỗ trợ việc sử dụng màn hình ARP và do đó bị hạn chế sử dụng
màn hình MII (không cung cấp mức độ hoàn thiện cao
đảm bảo như màn hình ARP).

12.2 Thông lượng tối đa trong cấu trúc liên kết nhiều chuyển mạch
-----------------------------------------------------

Nhiều công tắc có thể được sử dụng để tối ưu hóa thông lượng
khi chúng được cấu hình song song như một phần của mạng bị cô lập
giữa hai hoặc nhiều hệ thống, ví dụ::

+----------+
		       ZZ0000ZZ
		       +-+---+---+-+
			 ZZ0001ZZ |
		+--------+ |   +----------+
		ZZ0002ZZ |
	 +------+---+ +------+----+ +------+----+
	 ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ
	 +------+---+ +------+----+ +------+----+
		ZZ0006ZZ |
		+--------+ |   +----------+
			 ZZ0007ZZ |
		       +-+---+---+-+
		       ZZ0008ZZ
		       +----------+

Trong cấu hình này, các công tắc được cách ly với một
cái khác.  Một lý do để sử dụng cấu trúc liên kết như thế này là để
mạng bị cô lập với nhiều máy chủ (một cụm được cấu hình cho tốc độ cao
hiệu suất chẳng hạn), sử dụng nhiều công tắc nhỏ hơn có thể hiệu quả hơn.
hiệu quả về mặt chi phí hơn so với một bộ chuyển mạch lớn hơn, ví dụ: trên mạng có 24
máy chủ, ba thiết bị chuyển mạch 24 cổng có thể rẻ hơn đáng kể so với
một switch 72 cổng duy nhất.

Nếu cần truy cập ngoài mạng, một máy chủ riêng lẻ
có thể được trang bị thêm một thiết bị mạng được kết nối với một
mạng bên ngoài; máy chủ này sau đó cũng hoạt động như một cổng.

12.2.1 Lựa chọn chế độ liên kết MT cho cấu trúc liên kết nhiều công tắc
-------------------------------------------------------------

Trong thực tế, chế độ liên kết thường được sử dụng trong
cấu hình loại này là Balance-rr.  Về mặt lịch sử, trong này
cấu hình mạng, những cảnh báo thông thường về gói không đúng thứ tự
việc phân phối được giảm thiểu bằng cách sử dụng bộ điều hợp mạng không thực hiện
bất kỳ loại kết hợp gói nào (thông qua việc sử dụng NAPI, hoặc do
bản thân thiết bị không tạo ra các ngắt cho đến khi một số
gói đã đến).  Khi được sử dụng theo cách này, số dư-rr
chế độ cho phép các kết nối riêng lẻ giữa hai máy chủ được thực hiện một cách hiệu quả
sử dụng băng thông lớn hơn của một giao diện.

12.2.2 Giám sát liên kết MT cho cấu trúc liên kết nhiều switch
------------------------------------------------------

Một lần nữa, trong thực tế thực tế, màn hình MII được sử dụng thường xuyên nhất
trong cấu hình này, vì hiệu suất được ưu tiên hơn
sự sẵn có.  Màn hình ARP sẽ hoạt động trong cấu trúc liên kết này, nhưng nó
ưu điểm so với màn hình MII bị giảm thiểu do khối lượng đầu dò
cần thiết khi số lượng hệ thống liên quan tăng lên (hãy nhớ rằng mỗi
máy chủ trong mạng được cấu hình bằng liên kết).

13. Vấn đề về hành vi chuyển đổi
==========================

13.1 Trì hoãn thiết lập liên kết và chuyển đổi dự phòng
-------------------------------------------

Một số thiết bị chuyển mạch thể hiện hành vi không mong muốn liên quan đến
thời gian báo cáo liên kết lên xuống của switch.

Đầu tiên, khi một liên kết xuất hiện, một số công tắc có thể chỉ ra rằng
liên kết đã hoạt động (có sẵn nhà cung cấp dịch vụ), nhưng không chuyển lưu lượng truy cập qua
giao diện trong một khoảng thời gian.  Sự chậm trễ này thường là do
một số loại giao thức tự động đàm phán hoặc định tuyến, nhưng cũng có thể xảy ra
trong quá trình khởi tạo switch (ví dụ: trong quá trình khôi phục sau khi switch
thất bại).  Nếu bạn thấy đây là một vấn đề, hãy chỉ định một giải pháp thích hợp
giá trị cho tùy chọn mô-đun liên kết updelay để trì hoãn việc sử dụng
(các) giao diện liên quan.

Thứ hai, một số switch có thể "trả lại" trạng thái liên kết một hoặc nhiều
lần trong khi một liên kết đang thay đổi trạng thái.  Điều này xảy ra phổ biến nhất khi
switch đang khởi tạo.  Một lần nữa, giá trị độ trễ cập nhật thích hợp có thể
giúp đỡ.

Lưu ý rằng khi giao diện liên kết không có liên kết hoạt động,
trình điều khiển sẽ ngay lập tức sử dụng lại liên kết đầu tiên đi lên, ngay cả khi
tham số updelay đã được chỉ định (updelay bị bỏ qua trong này
trường hợp).  Nếu có giao diện nô lệ đang chờ hết thời gian chờ cập nhật
hết hạn, giao diện đầu tiên chuyển sang trạng thái đó sẽ là
tái sử dụng ngay.  Điều này làm giảm thời gian ngừng hoạt động của mạng nếu
giá trị của độ trễ cập nhật đã được đánh giá quá cao và vì điều này chỉ xảy ra ở
trường hợp không có kết nối thì không bị phạt thêm
bỏ qua sự chậm trễ.

Ngoài những lo ngại về thời gian chuyển đổi, nếu
các thiết bị chuyển mạch mất nhiều thời gian để chuyển sang chế độ dự phòng, điều này có thể được mong muốn
để không kích hoạt giao diện dự phòng ngay sau khi liên kết bị hỏng.
Quá trình chuyển đổi dự phòng có thể bị trì hoãn thông qua tùy chọn mô-đun liên kết độ trễ.

13.2 Gói tin đến trùng lặp
--------------------------------

NOTE: Bắt đầu từ phiên bản 3.0.2, trình điều khiển liên kết có logic để
ngăn chặn các gói trùng lặp, điều này sẽ loại bỏ phần lớn vấn đề này.
Mô tả sau đây được giữ để tham khảo.

Không có gì lạ khi quan sát thấy một loạt các bản sao ngắn
lưu lượng truy cập khi thiết bị liên kết được sử dụng lần đầu tiên hoặc sau khi nó được sử dụng
nhàn rỗi trong một khoảng thời gian.  Điều này được quan sát dễ dàng nhất bằng cách đưa ra
"ping" tới một số máy chủ khác trên mạng và nhận thấy rằng
đầu ra từ các bản sao cờ ping (thường là một bản sao cho mỗi nô lệ).

Ví dụ: trên một liên kết ở chế độ dự phòng tích cực có năm nô lệ
tất cả được kết nối với một công tắc, đầu ra có thể xuất hiện như sau::

# ping-n 10.0.4.2
	PING 10.0.4.2 (10.0.4.2) từ 10.0.3.10 : 56(84) byte dữ liệu.
	64 byte từ 10.0.4.2: icmp_seq=1 ttl=64 time=13,7 ms
	64 byte từ 10.0.4.2: icmp_seq=1 ttl=64 time=13,8 ms (DUP!)
	64 byte từ 10.0.4.2: icmp_seq=1 ttl=64 time=13,8 ms (DUP!)
	64 byte từ 10.0.4.2: icmp_seq=1 ttl=64 time=13,8 ms (DUP!)
	64 byte từ 10.0.4.2: icmp_seq=1 ttl=64 time=13,8 ms (DUP!)
	64 byte từ 10.0.4.2: icmp_seq=2 ttl=64 time=0,216 ms
	64 byte từ 10.0.4.2: icmp_seq=3 ttl=64 time=0,267 ms
	64 byte từ 10.0.4.2: icmp_seq=4 ttl=64 time=0,222 ms

Điều này không phải do lỗi trong trình điều khiển liên kết mà là do nó
là một tác dụng phụ của việc có bao nhiêu thiết bị chuyển mạch cập nhật chuyển tiếp MAC của họ
các bảng.  Ban đầu, switch không liên kết địa chỉ MAC trong
gói có cổng chuyển mạch cụ thể và do đó nó có thể gửi
lưu lượng truy cập đến tất cả các cổng cho đến khi bảng chuyển tiếp MAC của nó được cập nhật.  Kể từ khi
các giao diện gắn liền với liên kết có thể chiếm nhiều cổng trên một
một công tắc, khi công tắc (tạm thời) làm ngập lưu lượng truy cập tới tất cả
cổng, thiết bị liên kết sẽ nhận được nhiều bản sao của cùng một gói
(một cho mỗi thiết bị nô lệ).

Hành vi gói trùng lặp phụ thuộc vào chuyển đổi, một số
thiết bị chuyển mạch thể hiện điều này, và một số thì không.  Trên các switch hiển thị thông tin này
hành vi này, nó có thể được tạo ra bằng cách xóa bảng chuyển tiếp MAC (trên
hầu hết các thiết bị chuyển mạch của Cisco, lệnh đặc quyền "xóa bảng địa chỉ mac
Dynamic" sẽ thực hiện được điều này).

14. Những cân nhắc cụ thể về phần cứng
====================================

Phần này chứa thông tin bổ sung để định cấu hình
liên kết trên nền tảng phần cứng cụ thể hoặc để liên kết giao tiếp
với các công tắc cụ thể hoặc các thiết bị khác.

Trung tâm Blade 14.1 IBM
--------------------

Điều này áp dụng cho JS20 và các hệ thống tương tự.

Trên các lưỡi JS20, trình điều khiển liên kết chỉ hỗ trợ
các chế độ Balance-rr, Active-backup, Balance-tlb và Balance-alb.  Đây là
phần lớn là do cấu trúc liên kết mạng bên trong BladeCenter, chi tiết
bên dưới.

Thông tin bộ điều hợp mạng JS20
--------------------------------

Tất cả các JS20 đều có hai cổng Broadcom Gigabit Ethernet
được tích hợp trên mặt phẳng (đó là "bo mạch chủ" trong IBM-speak).  trong
Khung máy BladeCenter, cổng eth0 của tất cả các lưỡi JS20 được nối cứng với
Mô-đun I/O #1; tương tự, tất cả các cổng eth1 đều được nối với Mô-đun I/O #2.
Thẻ con Broadcom bổ sung có thể được cài đặt trên JS20 để cung cấp
thêm hai cổng Gigabit Ethernet.  Các cổng này, eth2 và eth3, là
được nối dây tương ứng với Mô-đun I/O 3 và 4.

Mỗi Mô-đun I/O có thể chứa một công tắc hoặc một bộ truyền qua
mô-đun (cho phép các cổng được kết nối trực tiếp với thiết bị bên ngoài
chuyển đổi).  Một số chế độ liên kết yêu cầu nội bộ BladeCenter cụ thể
cấu trúc liên kết mạng để hoạt động; những điều này được trình bày chi tiết dưới đây.

Thông tin mạng cụ thể bổ sung của BladeCenter có thể được
được tìm thấy trong hai Sách đỏ IBM (www.ibm.com/redbooks):

- "Tùy chọn mạng IBM eServer BladeCenter"
- "Chuyển mạng lớp 2-7 của IBM eServer BladeCenter"

Cấu hình mạng BladeCenter
------------------------------------

Bởi vì BladeCenter có thể được cấu hình với số lượng rất lớn
theo nhiều cách, cuộc thảo luận này sẽ được giới hạn trong việc mô tả cơ bản
cấu hình.

Thông thường, Mô-đun chuyển mạch Ethernet (ESM) được sử dụng trong I/O
mô-đun 1 và 2. Trong cấu hình này, cổng eth0 và eth1 của
JS20 sẽ được kết nối với các công tắc bên trong khác nhau (trong
mô-đun I/O tương ứng).

Mô-đun chuyển tiếp (OPM hoặc CPM, quang hoặc đồng,
mô-đun chuyển tiếp) kết nối trực tiếp mô-đun I/O với một thiết bị bên ngoài
chuyển đổi.  Bằng cách sử dụng PM trong mô-đun I/O #1 và #2, eth0 và eth1
giao diện của JS20 có thể được chuyển hướng ra thế giới bên ngoài và
được kết nối với một công tắc chung bên ngoài.

Tùy thuộc vào sự kết hợp giữa ESM và PM, mạng sẽ
dường như liên kết dưới dạng cấu trúc liên kết chuyển mạch đơn (tất cả các PM) hoặc dưới dạng
nhiều cấu trúc liên kết chuyển mạch (một hoặc nhiều ESM, 0 hoặc nhiều PM).  Đó là
cũng có thể kết nối các ESM với nhau, tạo ra một cấu hình
giống như ví dụ trong "Tính sẵn sàng cao trong nhiều thiết bị chuyển mạch
Cấu trúc liên kết," ở trên.

Yêu cầu đối với các chế độ cụ thể
-------------------------------

Chế độ cân bằng-rr yêu cầu sử dụng các mô-đun chuyển tiếp
đối với các thiết bị trong liên kết, tất cả đều được kết nối với một công tắc chung bên ngoài.
Công tắc đó phải được cấu hình cho "etherchannel" hoặc "trunk" trên
các cổng thích hợp, như thường lệ đối với Balance-rr.

Các chế độ Balance-alb và Balance-tlb sẽ hoạt động với
chuyển đổi mô-đun hoặc mô-đun chuyển tiếp (hoặc kết hợp).  duy nhất
yêu cầu cụ thể cho các chế độ này là tất cả các giao diện mạng
phải có khả năng tiếp cận tất cả các điểm đến cho lưu lượng được gửi qua
thiết bị liên kết (tức là mạng phải hội tụ tại một số điểm bên ngoài
BladeCenter).

Chế độ sao lưu hoạt động không có yêu cầu bổ sung.

Vấn đề giám sát liên kết
----------------------

Khi có Mô-đun chuyển mạch Ethernet, chỉ có ARP
màn hình sẽ phát hiện tình trạng mất liên kết với bộ chuyển mạch bên ngoài một cách đáng tin cậy.  Đây là
không có gì bất thường, nhưng việc kiểm tra tủ BladeCenter sẽ
gợi ý rằng các cổng mạng "bên ngoài" là các cổng ethernet cho
hệ thống, trong khi thực tế là có sự chuyển đổi giữa các "bên ngoài" này
cổng và các thiết bị trên chính hệ thống JS20.  Màn hình MII là
chỉ có thể phát hiện lỗi liên kết giữa ESM và hệ thống JS20.

Khi có mô-đun chuyển tiếp, màn hình MII sẽ thực hiện
phát hiện lỗi đối với cổng "bên ngoài", sau đó trực tiếp
được kết nối với hệ thống JS20.

Những mối quan tâm khác
--------------

Liên kết Serial Over LAN (SoL) được thiết lập qua mạng chính
do đó chỉ có ethernet (eth0), do đó, bất kỳ sự mất liên kết nào tới eth0 sẽ dẫn đến
trong việc mất kết nối SoL của bạn.  Nó sẽ không thất bại với những thứ khác
lưu lượng mạng, vì hệ thống SoL nằm ngoài tầm kiểm soát của
trình điều khiển liên kết.

Có thể nên tắt cây bao trùm trên switch
(Mô-đun chuyển mạch Ethernet bên trong hoặc bộ chuyển mạch bên ngoài) sang
tránh các vấn đề chậm trễ khi sử dụng liên kết.


15. Câu hỏi thường gặp
==============================

1. SMP có an toàn không?
-------------------

Đúng. Bản vá liên kết kênh 2.0.xx cũ không an toàn cho SMP.
Trình điều khiển mới được thiết kế để đảm bảo an toàn cho SMP ngay từ đầu.

2. Loại thẻ nào sẽ hoạt động với nó?
-----------------------------------------

Bất kỳ loại thẻ Ethernet nào (thậm chí bạn có thể kết hợp các thẻ - Intel
Ví dụ: EtherExpress PRO/100 và 3com 3c905b).  Đối với hầu hết các chế độ,
các thiết bị không cần phải có cùng tốc độ.

Bắt đầu từ phiên bản 3.2.1, việc liên kết cũng hỗ trợ Infiniband
nô lệ ở chế độ hoạt động sao lưu.

3. Tôi có thể có bao nhiêu thiết bị liên kết?
----------------------------------------

Không có giới hạn.

4. Một thiết bị liên kết có thể có bao nhiêu nô lệ?
----------------------------------------------

Điều này chỉ bị giới hạn bởi số lượng giao diện mạng Linux
hỗ trợ và/hoặc số lượng card mạng bạn có thể đặt trong
hệ thống.

5. Điều gì xảy ra khi một liên kết nô lệ bị hỏng?
----------------------------------------

Nếu tính năng giám sát liên kết được bật thì thiết bị bị lỗi sẽ
bị vô hiệu hóa.  Chế độ sao lưu hoạt động sẽ chuyển sang liên kết dự phòng và
các chế độ khác sẽ bỏ qua liên kết bị lỗi.  Liên kết sẽ tiếp tục
được theo dõi và nếu nó phục hồi, nó sẽ tham gia lại liên kết (trong bất kỳ trường hợp nào
cách phù hợp với chế độ đó). Xem các phần trên Cao
Tính sẵn có và tài liệu cho từng chế độ để biết thêm
thông tin.

Giám sát liên kết có thể được kích hoạt thông qua miimon hoặc
tham số arp_interval (được mô tả trong phần tham số mô-đun,
ở trên).  Nói chung, miimon giám sát trạng thái sóng mang được cảm nhận bởi
thiết bị mạng cơ bản và trình giám sát arp (arp_interval)
giám sát kết nối với máy chủ khác trên mạng cục bộ.

Nếu không có giám sát liên kết nào được cấu hình, trình điều khiển liên kết sẽ
không thể phát hiện lỗi liên kết và sẽ cho rằng tất cả các liên kết đều
luôn có sẵn.  Điều này có thể dẫn đến mất gói tin và
dẫn đến suy giảm hiệu suất.  Mất hiệu suất chính xác
phụ thuộc vào chế độ liên kết và cấu hình mạng.

6. Có thể sử dụng liên kết để có tính sẵn sàng cao không?
----------------------------------------------

Đúng.  Xem phần về Tính sẵn sàng cao để biết chi tiết.

7. Nó hoạt động với những công tắc/hệ thống nào?
---------------------------------------------

Câu trả lời đầy đủ cho điều này phụ thuộc vào chế độ mong muốn.

Trong các chế độ cân bằng cơ bản (balance-rr và Balance-xor), nó
hoạt động với mọi hệ thống hỗ trợ etherchannel (còn được gọi là
đường trục).  Hầu hết các thiết bị chuyển mạch được quản lý hiện có đều có
hỗ trợ và nhiều thiết bị chuyển mạch không được quản lý.

Các chế độ cân bằng nâng cao (balance-tlb và Balance-alb) thực hiện
không có yêu cầu chuyển đổi đặc biệt nhưng cần trình điều khiển thiết bị
hỗ trợ các tính năng cụ thể (được mô tả trong phần thích hợp bên dưới
tham số mô-đun ở trên).

Ở chế độ 802.3ad, nó hoạt động với các hệ thống hỗ trợ IEEE
Tập hợp liên kết động 802.3ad.  Được quản lý nhiều nhất và nhiều không được quản lý
các thiết bị chuyển mạch hiện có hỗ trợ 802.3ad.

Chế độ sao lưu hoạt động sẽ hoạt động với bất kỳ công tắc Lớp II nào.

8. Thiết bị liên kết lấy địa chỉ MAC từ đâu?
---------------------------------------------------------

Khi sử dụng các thiết bị phụ có địa chỉ MAC cố định hoặc khi
tùy chọn failed_over_mac được bật, địa chỉ MAC của thiết bị liên kết là
địa chỉ MAC của nô lệ đang hoạt động.

Đối với các cấu hình khác, nếu không được cấu hình rõ ràng (với
ifconfig hoặc ip link), địa chỉ MAC của thiết bị liên kết được lấy từ
thiết bị nô lệ đầu tiên của nó.  Địa chỉ MAC này sau đó được chuyển cho tất cả những người sau
nô lệ và vẫn tồn tại dai dẳng (ngay cả khi nô lệ đầu tiên bị loại bỏ) cho đến khi
thiết bị liên kết được đưa xuống hoặc được cấu hình lại.

Nếu bạn muốn thay đổi địa chỉ MAC, bạn có thể đặt địa chỉ đó bằng
liên kết ifconfig hoặc ip::

# ifconfig trái phiếu0 hw ether 00:11:22:33:44:55

Bộ liên kết # ip địa chỉ bond0 66:77:88:99:aa:bb

Địa chỉ MAC cũng có thể được thay đổi bằng cách đưa xuống/lên
thiết bị và sau đó thay đổi nô lệ của nó (hoặc thứ tự của chúng)::

# ifconfig trái phiếu0 xuống; liên kết modprobe -r
	# ifconfig trái phiếu0 .... lên
	# ifenslave trái phiếu0 đạo đức...

Phương pháp này sẽ tự động lấy địa chỉ từ địa chỉ tiếp theo
nô lệ được thêm vào.

Để khôi phục địa chỉ MAC của nô lệ, bạn cần tách chúng ra
từ trái phiếu (ZZ0000ZZ). Trình điều khiển liên kết sẽ
sau đó khôi phục địa chỉ MAC mà nô lệ đã có trước khi
làm nô lệ.

9. Chế độ liên kết nào hỗ trợ XDP gốc?
------------------------------------------

* cân bằng-rr (0)
  * sao lưu tích cực (1)
  * cân bằng-xor (2)
  * 802.3ad (4)

Lưu ý rằng chính sách băm vlan+srcmac không hỗ trợ XDP gốc.
Đối với các chế độ liên kết khác, chương trình XDP phải được tải ở chế độ chung.

16. Tài nguyên và liên kết
=======================

Bạn có thể tìm thấy phiên bản mới nhất của trình điều khiển liên kết trong phiên bản mới nhất
phiên bản hạt nhân linux, được tìm thấy trên ZZ0000ZZ

Phiên bản mới nhất của tài liệu này có thể được tìm thấy trong kernel mới nhất
nguồn (có tên là Documentation/networking/bonding.rst).

Các cuộc thảo luận liên quan đến sự phát triển của trình điều khiển liên kết diễn ra
trên danh sách gửi thư chính của mạng Linux, được lưu trữ tại vger.kernel.org. Danh sách
địa chỉ là:

netdev@vger.kernel.org

Giao diện quản trị (để đăng ký hoặc hủy đăng ký) có thể
được tìm thấy tại:

ZZ0000ZZ