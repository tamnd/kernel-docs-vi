.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/bridge.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Cầu nối Ethernet
=================

Giới thiệu
============

Tiêu chuẩn IEEE 802.1Q-2022 (Cầu nối và Mạng cầu nối) xác định
hoạt động của các bridge trong mạng máy tính. Một cây cầu, trong bối cảnh này
tiêu chuẩn, là thiết bị kết nối hai hoặc nhiều phân đoạn mạng và hoạt động
ở lớp liên kết dữ liệu (Lớp 2) của OSI (Kết nối hệ thống mở)
mô hình. Mục đích của bridge là lọc và chuyển tiếp các khung giữa
các phân đoạn khác nhau dựa trên địa chỉ MAC (Kiểm soát truy cập phương tiện) đích.

Cầu kAPI
===========

Dưới đây là một số cấu trúc cốt lõi của mã cầu. Lưu ý rằng kAPI là ZZ0000ZZ,
và có thể được thay đổi bất cứ lúc nào.

.. kernel-doc:: net/bridge/br_private.h
   :identifiers: net_bridge_vlan

Cầu nối uAPI
===========

uAPI cầu Linux hiện đại được truy cập thông qua giao diện Netlink. Bạn có thể tìm thấy
bên dưới các tệp nơi các thuộc tính liên kết mạng của cổng cầu và cổng cầu được xác định.

Thuộc tính liên kết mạng cầu nối
-------------------------

.. kernel-doc:: include/uapi/linux/if_link.h
   :doc: Bridge enum definition

Thuộc tính liên kết mạng của cổng cầu
------------------------------

.. kernel-doc:: include/uapi/linux/if_link.h
   :doc: Bridge port enum definition

hệ thống cầu nối
------------

Giao diện sysfs không được dùng nữa và không nên mở rộng nếu mới
các tùy chọn được thêm vào.

STP
===

Triển khai STP (Giao thức cây kéo dài) trong trình điều khiển cầu nối Linux
là một tính năng quan trọng giúp ngăn chặn các vòng lặp và các cơn bão quảng bá trong
Mạng Ethernet bằng cách xác định và vô hiệu hóa các liên kết dư thừa. Trong một Linux
bối cảnh cầu nối, STP rất quan trọng đối với sự ổn định và tính khả dụng của mạng.

STP là giao thức Lớp 2 hoạt động ở Lớp liên kết dữ liệu của OSI
mô hình. Ban đầu nó được phát triển dưới tên IEEE 802.1D và từ đó đã phát triển thành
nhiều phiên bản, bao gồm Giao thức cây kéo dài nhanh (RSTP) và
ZZ0000ZZ.

Thay vào đó, 802.1D-2004 đã loại bỏ Giao thức Spanning Tree ban đầu
kết hợp Giao thức cây kéo dài nhanh (RSTP). Đến năm 2014, tất cả
chức năng được xác định bởi IEEE 802.1D đã được tích hợp vào
IEEE 802.1Q (Cầu nối và Mạng cầu nối) hoặc IEEE 802.1AC (Dịch vụ MAC
định nghĩa). 802.1D đã chính thức bị loại bỏ vào năm 2022.

Cổng cầu và trạng thái STP
---------------------------

Trong ngữ cảnh của STP, các cổng cầu có thể ở một trong các trạng thái sau:
  * Chặn: Cổng bị vô hiệu hóa đối với lưu lượng dữ liệu và chỉ lắng nghe
    BPDU (Đơn vị dữ liệu giao thức cầu nối) từ các thiết bị khác để xác định
    topo mạng.
  * Nghe: Cổng bắt đầu tham gia vào quá trình STP và lắng nghe
    cho các BPDU.
  * Đang học: Cổng tiếp tục lắng nghe BPDU và bắt đầu học MAC
    địa chỉ từ các khung đến nhưng không chuyển tiếp khung dữ liệu.
  * Chuyển tiếp: Cổng hoạt động đầy đủ và chuyển tiếp cả BPDU và
    các khung dữ liệu.
  * Đã tắt: Cổng bị vô hiệu hóa về mặt quản trị và không tham gia
    trong quy trình STP. Việc chuyển tiếp khung dữ liệu cũng bị vô hiệu hóa.

Cầu gốc và sự hội tụ
---------------------------

Trong bối cảnh kết nối mạng và cầu nối Ethernet trong Linux, cầu gốc
là một công tắc được chỉ định trong mạng cầu nối đóng vai trò là điểm tham chiếu
cho thuật toán cây bao trùm để tạo ra cấu trúc liên kết không có vòng lặp.

Đây là cách STP hoạt động và cầu gốc được chọn:
  1. Mức độ ưu tiên của cầu: Mỗi cầu chạy giao thức cây bao trùm, có một
     giá trị Ưu tiên Cầu có thể định cấu hình. Giá trị càng thấp thì giá trị càng cao
     ưu tiên. Theo mặc định, Bridge Priority được đặt thành giá trị tiêu chuẩn
     (ví dụ: 32768).
  2. Bridge ID: Bridge ID bao gồm hai thành phần: Bridge Priority
     và địa chỉ MAC của bridge. Nó xác định duy nhất từng cây cầu
     trong mạng. Bridge ID được sử dụng để so sánh mức độ ưu tiên của
     những cây cầu khác nhau.
  3. Bầu cử cầu: Khi mạng bắt đầu, tất cả các cầu ban đầu đều giả định
     rằng họ là cây cầu gốc. Họ bắt đầu quảng cáo Bridge Protocol
     Đơn vị dữ liệu (BPDU) tới hàng xóm của chúng, chứa ID cầu nối của chúng và
     thông tin khác.
  4. So sánh BPDU: Các cầu nối trao đổi BPDU để xác định cầu gốc.
     Mỗi cây cầu sẽ kiểm tra các BPDU nhận được, bao gồm cả Mức độ ưu tiên của cầu nối
     và Bridge ID, để xác định xem có nên điều chỉnh mức độ ưu tiên của riêng mình hay không.
     Cây cầu có ID cầu thấp nhất sẽ trở thành cây cầu gốc.
  5. Thông báo Root Bridge: Khi root bridge được xác định, nó sẽ gửi
     BPDU có thông tin về root bridge tới tất cả các bridge khác trong
     mạng. Thông tin này được sử dụng bởi các cây cầu khác để tính toán
     đường đi ngắn nhất tới root bridge và khi làm như vậy sẽ tạo ra một đường dẫn không có vòng lặp
     cấu trúc liên kết.
  6. Cổng chuyển tiếp: Sau khi đã chọn được bridge gốc và cây bao trùm
     cấu trúc liên kết được thiết lập, mỗi cây cầu sẽ xác định cổng nào của nó sẽ
     ở trạng thái chuyển tiếp (được sử dụng cho lưu lượng dữ liệu) và phải ở trạng thái
     trạng thái chặn (được sử dụng để ngăn chặn vòng lặp). Các cổng của root bridge là
     tất cả đều ở trạng thái chuyển tiếp. trong khi những cây cầu khác có một số cổng ở
     trạng thái chặn để tránh vòng lặp.
  7. Root Ports: Sau khi chọn root bridge và cây bao trùm
     cấu trúc liên kết được thiết lập, mỗi cầu nối không phải gốc sẽ xử lý các
     BPDU và xác định cổng nào của nó cung cấp đường đi ngắn nhất tới
     cầu gốc dựa trên thông tin trong BPDU nhận được. Cảng này là
     được chỉ định là cổng gốc. Và nó ở trạng thái Chuyển tiếp, cho phép
     nó để chủ động chuyển tiếp lưu lượng mạng.
  8. Cổng được chỉ định: Cổng được chỉ định là cổng mà qua đó máy chủ không phải root
     bridge sẽ chuyển tiếp lưu lượng tới đoạn được chỉ định. Cảng được chỉ định
     được đặt ở trạng thái Chuyển tiếp. Tất cả các cổng khác trên máy không root
     cây cầu không được chỉ định cho các đoạn cụ thể sẽ được đặt trong
     Trạng thái chặn để ngăn chặn vòng lặp mạng.

STP đảm bảo sự hội tụ mạng bằng cách tính toán đường đi ngắn nhất và vô hiệu hóa
liên kết dư thừa. Khi xảy ra thay đổi cấu trúc liên kết mạng (ví dụ: lỗi liên kết),
STP tính toán lại cấu trúc liên kết mạng để khôi phục kết nối đồng thời tránh bị lặp.

Cấu hình đúng các tham số STP, chẳng hạn như mức độ ưu tiên của cầu nối, có thể
ảnh hưởng đến hiệu suất mạng, lựa chọn đường dẫn và cây cầu nào sẽ trở thành
Cầu Gốc.

Không gian người dùng Trình trợ giúp STP
---------------------

Không gian người dùng STP trợ giúp ZZ0003ZZ là một chương trình để kiểm soát xem có nên sử dụng hay không
cây bao trùm chế độ người dùng. ZZ0000ZZ là
được gọi bởi kernel khi STP được bật/tắt trên bridge
(thông qua ZZ0001ZZ hoặc ZZ0002ZZ).  Kernel kích hoạt chế độ user_stp nếu lệnh đó trả về
0 hoặc bật chế độ kernel_stp nếu lệnh đó trả về bất kỳ giá trị nào khác.

Lựa chọn chế độ STP
------------------

Thuộc tính cầu nối ZZ0000ZZ cho phép kiểm soát rõ ràng cách thức
STP hoạt động khi được bật, bỏ qua trình trợ giúp ZZ0001ZZ
hoàn toàn dành cho chế độ ZZ0002ZZ và ZZ0003ZZ.

.. kernel-doc:: include/uapi/linux/if_link.h
   :doc: Bridge STP mode values

Chế độ mặc định là ZZ0000ZZ, duy trì chế độ truyền thống
hành vi gọi trình trợ giúp ZZ0001ZZ. ZZ0002ZZ và
Chế độ ZZ0003ZZ đặc biệt hữu ích trong môi trường không gian tên mạng
nơi không có cơ chế trợ giúp, như ZZ0004ZZ
bị giới hạn trong không gian tên mạng ban đầu.

Ví dụ::

bộ liên kết ip dev br0 loại cầu stp_mode người dùng stp_state 1

Chế độ chỉ có thể được thay đổi khi STP bị tắt.

VLAN
====

LAN (Mạng cục bộ) là mạng bao phủ một khu vực địa lý nhỏ,
thường trong một tòa nhà hoặc một khuôn viên trường. Mạng LAN được sử dụng để kết nối
máy tính, máy chủ, máy in và các thiết bị nối mạng khác trong phạm vi địa phương
khu vực. Mạng LAN có thể có dây (sử dụng cáp Ethernet) hoặc không dây (sử dụng Wi-Fi).

VLAN (Mạng cục bộ ảo) là một phân đoạn logic của mạng vật lý
mạng thành nhiều miền quảng bá bị cô lập. VLAN được sử dụng để phân chia
một LAN vật lý duy nhất thành nhiều mạng LAN ảo, cho phép các nhóm khác nhau
các thiết bị có thể giao tiếp như thể chúng ở trên các mạng vật lý riêng biệt.

Thông thường có hai triển khai VLAN, IEEE 802.1Q và IEEE 802.1ad
(còn được gọi là QinQ). IEEE 802.1Q là tiêu chuẩn để gắn thẻ VLAN trong Ethernet
mạng. Nó cho phép quản trị viên mạng tạo các Vlan logic trên một
mạng vật lý và gắn thẻ các khung Ethernet với thông tin VLAN, đó là
được gọi là ZZ0001ZZ. IEEE 802.1ad, thường được gọi là QinQ hoặc Double
VLAN, là phần mở rộng của tiêu chuẩn IEEE 802.1Q. QinQ cho phép
xếp chồng nhiều thẻ VLAN trong một khung Ethernet duy nhất. Linux
cầu hỗ trợ cả IEEE 802.1Q và ZZ0000ZZ
giao thức gắn thẻ VLAN.

ZZ0000ZZ
trên cầu bị tắt theo mặc định. Sau khi kích hoạt tính năng lọc VLAN trên bridge,
nó sẽ bắt đầu chuyển tiếp các khung tới các đích thích hợp dựa trên
địa chỉ MAC đích và thẻ VLAN (cả hai đều phải khớp).

Đa phương tiện
=========

Trình điều khiển cầu Linux có hỗ trợ multicast cho phép nó xử lý Internet
Giao thức quản lý nhóm (IGMP) hoặc Multicast Listener Discovery (MLD)
tin nhắn và chuyển tiếp các gói dữ liệu multicast một cách hiệu quả. Cây cầu
trình điều khiển hỗ trợ IGMPv2/IGMPv3 và MLDv1/MLDv2.

Theo dõi đa phương tiện
------------------

Multicast snooping là một công nghệ mạng cho phép chuyển mạch mạng
để quản lý lưu lượng phát đa hướng một cách thông minh trong mạng cục bộ (LAN).

Switch duy trì một bảng nhóm multicast, bảng này ghi lại sự liên kết
giữa các địa chỉ nhóm multicast và các cổng nơi các máy chủ đã tham gia các địa chỉ này
các nhóm. Bảng nhóm được cập nhật động dựa trên các thông báo IGMP/MLD
đã nhận được. Với thông tin nhóm multicast được thu thập thông qua việc theo dõi,
switch tối ưu hóa việc chuyển tiếp lưu lượng multicast. Thay vì mù quáng
phát lưu lượng multicast đến tất cả các cổng, nó sẽ gửi multicast
lưu lượng dựa trên địa chỉ MAC đích chỉ tới các cổng có
đã đăng ký nhóm multicast đích tương ứng.

Khi được tạo, các thiết bị cầu nối Linux có tính năng theo dõi phát đa hướng được kích hoạt bởi
mặc định. Nó duy trì cơ sở dữ liệu chuyển tiếp Multicast (MDB) để theo dõi
của các mối quan hệ cổng và nhóm.

Hỗ trợ IGMPv3/MLDv2 EHT
------------------------

Cầu Linux hỗ trợ IGMPv3/MLDv2 EHT (Theo dõi máy chủ rõ ràng),
đã được thêm bởi ZZ0000ZZ

Việc theo dõi máy chủ rõ ràng cho phép thiết bị theo dõi từng
máy chủ riêng lẻ được tham gia vào một nhóm hoặc kênh cụ thể. chính
Lợi ích của việc theo dõi máy chủ rõ ràng trong IGMP là cho phép nghỉ phép tối thiểu
độ trễ khi máy chủ rời khỏi nhóm hoặc kênh multicast.

Khoảng thời gian từ khi máy chủ muốn rời đi cho đến khi thiết bị dừng lại
chuyển tiếp lưu lượng được gọi là độ trễ rời IGMP. Một thiết bị được cấu hình
với IGMPv3 hoặc MLDv2 và theo dõi rõ ràng có thể dừng chuyển tiếp ngay lập tức
lưu lượng truy cập nếu máy chủ cuối cùng yêu cầu nhận lưu lượng truy cập từ thiết bị
cho biết rằng nó không còn muốn nhận lưu lượng truy cập nữa. Độ trễ nghỉ phép
do đó chỉ bị ràng buộc bởi độ trễ truyền gói trong đa truy cập
mạng và thời gian xử lý trong thiết bị.

Các tính năng phát đa hướng khác
------------------------

Cầu Linux cũng hỗ trợ ZZ0000ZZ,
bị tắt theo mặc định nhưng có thể được bật. Và ZZ0001ZZ,
giúp xác định vị trí của các bộ định tuyến multicast.

chuyển đổi
=========

Linux Bridge Switchdev là một tính năng trong nhân Linux giúp mở rộng
khả năng của cầu nối Linux truyền thống để hoạt động hiệu quả hơn với
switch phần cứng hỗ trợ switchdev. Với Linux Bridge Switchdev, chắc chắn
các chức năng mạng như chuyển tiếp, lọc và học Ethernet
các khung có thể được giảm tải tới một bộ chuyển mạch phần cứng. Việc giảm tải này làm giảm
gánh nặng cho nhân Linux và CPU, dẫn đến hiệu suất mạng được cải thiện
và độ trễ thấp hơn.

Để sử dụng Linux Bridge Switchdev, bạn cần có bộ chuyển mạch phần cứng hỗ trợ
giao diện switchdev. Điều này có nghĩa là phần cứng của switch cần phải có
trình điều khiển và chức năng cần thiết để hoạt động cùng với Linux
hạt nhân.

Vui lòng xem tài liệu ZZ0000ZZ để biết thêm chi tiết.

Bộ lọc mạng
=========

Mô-đun bộ lọc mạng cầu nối là một tính năng cũ cho phép lọc cầu nối
các gói có iptables và ip6tables. Việc sử dụng nó không được khuyến khích. Người dùng nên
hãy cân nhắc việc sử dụng nftables để lọc gói.

Công cụ ebtables cũ hơn bị hạn chế về tính năng hơn so với nftables, nhưng
giống như nftables, nó cũng không cần mô-đun này để hoạt động.

Mô-đun br_netfilter chặn các gói đi vào cầu, thực hiện
kiểm tra độ tỉnh táo tối thiểu trên các gói ipv4 và ipv6 rồi giả vờ rằng
những gói này đang được định tuyến, không được bắc cầu. br_netfilter sau đó gọi
các móc nối bộ lọc mạng ip và ipv6 từ lớp cầu nối, tức là các bảng ip(6)
bộ quy tắc cũng sẽ thấy các gói này.

br_netfilter cũng là lý do dẫn đến trận đấu iptables ZZ0000ZZ:
Trận đấu này là cách duy nhất để thông báo một cách đáng tin cậy các gói được định tuyến và bắc cầu
tách biệt trong một bộ quy tắc iptables.

Lưu ý rằng ebtables và nftables sẽ hoạt động tốt mà không cần mô-đun br_netfilter.
iptables/ip6tables/arptables không hoạt động đối với lưu lượng cầu nối vì chúng
cắm vào ngăn xếp định tuyến. Các quy tắc nftables trong dòng ip/ip6/inet/arp sẽ không
cũng có thể thấy lưu lượng truy cập được chuyển tiếp qua một cây cầu, nhưng đó thực chất là cách nó
nên như vậy.

Về mặt lịch sử, bộ tính năng của ebtables rất hạn chế (hiện tại vẫn vậy),
mô-đun này đã được thêm vào để giả vờ các gói được định tuyến và gọi ipv4/ipv6
các móc nối netfilter từ cầu nối để người dùng có quyền truy cập vào nhiều tính năng hơn
khả năng kết hợp iptables (bao gồm cả conntrack). nftables không có
hạn chế này, hầu như tất cả các tính năng đều hoạt động bất kể họ giao thức.

Vì vậy, br_netfilter chỉ cần thiết nếu người dùng, vì lý do nào đó, cần sử dụng
bảng ip(6) để lọc các gói được chuyển tiếp bởi cầu nối hoặc cầu nối NAT
giao thông. Để lọc lớp liên kết thuần túy, mô-đun này không cần thiết.

Các tính năng khác
==============

Cầu Linux cũng hỗ trợ ZZ0000ZZ,
ZZ0001ZZ,
ZZ0002ZZ,
ZZ0003ZZ,
và ZZ0004ZZ.

FAQ
===

Cây cầu có tác dụng gì?
----------------------

Một cây cầu chuyển tiếp lưu lượng truy cập giữa nhiều giao diện mạng một cách minh bạch.
Trong tiếng Anh đơn giản, điều này có nghĩa là một cây cầu kết nối hai hoặc nhiều vật lý
Mạng Ethernet, để tạo thành một mạng Ethernet (logic) lớn hơn.

Giao thức L3 có độc lập không?
------------------------------

Đúng. Cây cầu nhìn thấy tất cả các khung, nhưng ZZ0000ZZ chỉ có tiêu đề/thông tin L2.
Như vậy, chức năng bắc cầu là giao thức độc lập và cần có
không gặp khó khăn gì khi chuyển tiếp IPX, NetBEUI, IP, IPv6, v.v.

Thông tin liên hệ
============

Mã hiện được duy trì bởi Roopa Prabhu <roopa@nvidia.com> và
Nikolay Aleksandrov <razor@blackwall.org>. Lỗi cầu và cải tiến
được thảo luận trên danh sách gửi thư linux-netdev netdev@vger.kernel.org và
bridge@lists.linux.dev.

Danh sách này dành cho bất kỳ ai quan tâm: ZZ0000ZZ

Liên kết ngoài
==============

Tài liệu cũ về cầu nối Linux đã có trên:
ZZ0000ZZ