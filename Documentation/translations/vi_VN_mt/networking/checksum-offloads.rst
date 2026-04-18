.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/checksum-offloads.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Tổng kiểm tra giảm tải
======================


Giới thiệu
============

Tài liệu này mô tả một tập hợp các kỹ thuật trong ngăn xếp mạng Linux để
tận dụng khả năng giảm tải tổng kiểm tra của các NIC khác nhau.

Các công nghệ sau đây được mô tả:

* Giảm tải tổng kiểm tra TX
* LCO: Giảm tải tổng kiểm tra cục bộ
* RCO: Giảm tải tổng kiểm tra từ xa

Những điều cần được ghi lại ở đây nhưng chưa có:

* Giảm tải tổng kiểm tra RX
* Chuyển đổi CHECKSUM_UNNECESSARY


Giảm tải tổng kiểm tra TX
===================

Giao diện để tải tổng kiểm tra truyền tới một thiết bị được giải thích trong
chi tiết trong các nhận xét gần đầu include/linux/skbuff.h.

Tóm lại, nó cho phép yêu cầu thiết bị điền vào một phần bổ sung duy nhất
tổng kiểm tra được xác định bởi các trường sk_buff skb->csum_start và skb->csum_offset.
Thiết bị sẽ tính toán tổng kiểm tra phần bù 16 bit (tức là
tổng kiểm tra 'kiểu IP') từ csum_start đến cuối gói và điền vào
kết quả tại (csum_start + csum_offset).

Vì csum_offset không thể âm nên điều này đảm bảo rằng giá trị trước đó của
trường tổng kiểm tra được bao gồm trong tính toán tổng kiểm tra, do đó nó có thể được sử dụng
để cung cấp bất kỳ sự điều chỉnh cần thiết nào cho tổng kiểm tra (chẳng hạn như tổng của
tiêu đề giả cho UDP hoặc TCP).

Giao diện này chỉ cho phép tải xuống một tổng kiểm tra duy nhất.  Ở đâu
đóng gói được sử dụng, gói có thể có nhiều trường tổng kiểm tra trong
các lớp tiêu đề khác nhau và phần còn lại sẽ phải được xử lý bởi lớp khác
cơ chế như LCO hoặc RCO.

CRC32c cũng có thể được giảm tải bằng giao diện này bằng cách điền vào
skb->csum_start và skb->csum_offset như được mô tả ở trên và cài đặt
skb->csum_not_inet: xem bình luận skbuff.h (phần 'D') để biết thêm chi tiết.

Không thực hiện giảm tải tổng kiểm tra tiêu đề IP; nó luôn luôn được thực hiện trong
phần mềm.  Điều này không sao vì khi chúng ta xây dựng tiêu đề IP, rõ ràng chúng ta đã có nó
trong bộ nhớ đệm nên việc tính tổng không tốn kém.  Nó cũng khá ngắn.

Các yêu cầu đối với GSO phức tạp hơn vì khi phân đoạn một
gói được đóng gói cả tổng kiểm tra bên trong và bên ngoài có thể cần được chỉnh sửa hoặc
được tính toán lại cho từng phân đoạn kết quả.  Xem bình luận skbuff.h (phần 'E')
để biết thêm chi tiết.

Trình điều khiển khai báo khả năng giảm tải của nó trong netdev->hw_features; xem
Tài liệu/mạng/netdev-features.rst để biết thêm.  Lưu ý rằng một thiết bị
chỉ quảng cáo NETIF_F_IP[V6]_CSUM vẫn phải tuân theo csum_start và
csum_offset được đưa ra trong SKB; nếu nó cố gắng tự suy luận những điều này trong phần cứng
(như một số NIC thực hiện) trình điều khiển nên kiểm tra xem các giá trị trong SKB có khớp không
những cái mà phần cứng sẽ suy ra, và nếu không, sẽ quay lại kiểm tra tổng hợp
thay vào đó bằng phần mềm (với skb_csum_hwoffload_help() hoặc một trong các
các hàm skb_checksum_help() / skb_crc32c_csum_help, như đã đề cập trong
bao gồm/linux/skbuff.h).

Phần lớn, ngăn xếp nên giả định rằng việc giảm tải tổng kiểm tra được hỗ trợ
bởi thiết bị cơ bản.  Nơi duy nhất cần kiểm tra là
valid_xmit_skb() và các hàm mà nó gọi trực tiếp hoặc gián tiếp.  Đó
so sánh các tính năng giảm tải mà SKB yêu cầu (có thể bao gồm
giảm tải khác ngoài Giảm tải tổng kiểm tra TX) và nếu chúng không được hỗ trợ hoặc
được bật trên thiết bị (được xác định bởi netdev->features), thực hiện
giảm tải tương ứng trong phần mềm.  Trong trường hợp Giảm tải tổng kiểm tra TX, điều đó
có nghĩa là gọi skb_csum_hwoffload_help(skb, feature).


LCO: Giảm tải tổng kiểm tra cục bộ
===========================

LCO là một kỹ thuật tính toán hiệu quả tổng kiểm tra bên ngoài của một
datagram được đóng gói khi tổng kiểm tra bên trong sắp được dỡ tải.

Tổng số bù của gói TCP hoặc UDP được kiểm tra chính xác là bằng nhau
phần bù của tổng của tiêu đề giả, bởi vì mọi thứ khác đều có
'bị hủy bỏ' bởi trường tổng kiểm tra.  Điều này là do tổng số tiền đã
được bổ sung trước khi được ghi vào trường tổng kiểm tra.

Tổng quát hơn, điều này đúng trong mọi trường hợp khi những cái 'kiểu IP' bổ sung cho
tổng kiểm tra được sử dụng và do đó bất kỳ tổng kiểm tra nào mà TX Checksum Offload hỗ trợ.

Nghĩa là, nếu chúng tôi đã thiết lập Giảm tải tổng kiểm tra TX với cặp bắt đầu/bù, chúng tôi
biết rằng sau khi thiết bị điền vào tổng kiểm tra đó, tổng số đó sẽ bổ sung
từ csum_start đến cuối gói sẽ bằng phần bù của
bất kỳ giá trị nào chúng tôi đặt trước vào trường tổng kiểm tra.  Điều này cho phép chúng tôi
tính toán tổng kiểm tra bên ngoài mà không cần nhìn vào tải trọng: chúng ta chỉ cần dừng lại
tính tổng khi chúng ta đến csum_start, sau đó thêm phần bù của từ 16 bit
tại (csum_start + csum_offset).

Sau đó, khi tổng kiểm tra bên trong thực sự được điền vào (bằng phần cứng hoặc bằng
skb_checksum_help()), tổng kiểm tra bên ngoài sẽ trở nên chính xác nhờ vào
số học.

LCO được thực hiện bởi ngăn xếp khi xây dựng tiêu đề UDP bên ngoài cho một
đóng gói như VXLAN hoặc GENEVE, trong udp_set_csum().  Tương tự đối với
Tương đương với IPv6, trong udp6_set_csum().

Nó cũng được thực hiện khi xây dựng tiêu đề IPv4 GRE, trong
net/ipv4/ip_gre.c:build_header().  Đó là ZZ0000ZZ hiện đang được thực hiện khi
xây dựng tiêu đề IPv6 GRE; tổng kiểm tra GRE được tính toán trên toàn bộ
gói trong net/ipv6/ip6_gre.c:ip6gre_xmit2(), nhưng có thể sử dụng
LCO ở đây là IPv6 GRE vẫn sử dụng tổng kiểm tra kiểu IP.

Tất cả các triển khai LCO đều sử dụng hàm trợ giúp lco_csum(), trong
bao gồm/linux/skbuff.h.

LCO có thể được sử dụng một cách an toàn để đóng gói lồng nhau; trong trường hợp này, bên ngoài
lớp đóng gói sẽ tổng hợp cả tiêu đề của chính nó và tiêu đề 'ở giữa'.
Điều này không có nghĩa là tiêu đề 'ở giữa' sẽ được tính tổng nhiều lần, nhưng
dường như không có cách nào để tránh điều đó mà không phải chịu chi phí lớn hơn
(ví dụ: trong SKB sưng lên).


RCO: Giảm tải tổng kiểm tra từ xa
============================

RCO là một kỹ thuật để loại bỏ tổng kiểm tra bên trong của một datagram được đóng gói,
cho phép tổng kiểm tra bên ngoài được giảm tải.  Tuy nhiên, nó bao gồm một
thay đổi các giao thức đóng gói mà người nhận cũng phải hỗ trợ.
Vì lý do này, nó bị tắt theo mặc định.

RCO được trình bày chi tiết trong Bản nháp Internet sau:

* ZZ0000ZZ
* ZZ0001ZZ

Trong Linux, RCO được triển khai riêng lẻ trong từng giao thức đóng gói và
hầu hết các loại đường hầm đều có cờ kiểm soát việc sử dụng nó.  Ví dụ: VXLAN có
cờ VXLAN_F_REMCSUM_TX (theo struct vxlan_rdst) để chỉ ra rằng RCO phải
được sử dụng khi truyền đến một đích từ xa nhất định.