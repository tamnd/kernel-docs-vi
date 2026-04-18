.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/segmentation-offloads.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Giảm tải phân khúc
=======================


Giới thiệu
============

Tài liệu này mô tả một tập hợp các kỹ thuật trong ngăn xếp mạng Linux
để tận dụng khả năng giảm tải phân đoạn của các NIC khác nhau.

Các công nghệ sau đây được mô tả:
 * Giảm tải phân đoạn TCP - TSO
 * Giảm tải phân mảnh UDP - UFO
 * Giảm tải đường hầm IPIP, SIT, GRE và UDP
 * Giảm tải phân đoạn chung - GSO
 * Giảm tải nhận chung - GRO
 * Giảm tải phân khúc chung một phần - GSO_PARTIAL
 * Tăng tốc SCTP với GSO - GSO_BY_FRAGS


Giảm tải phân đoạn TCP
========================

Phân đoạn TCP cho phép thiết bị phân đoạn một khung hình thành nhiều
các khung có kích thước tải trọng dữ liệu được chỉ định trong skb_shinfo()->gso_size.
Khi phân đoạn TCP yêu cầu bit cho SKB_GSO_TCPV4 hoặc
SKB_GSO_TCPV6 phải được đặt trong skb_shinfo()->gso_type và
skb_shinfo()->gso_size phải được đặt thành giá trị khác 0.

Phân đoạn TCP phụ thuộc vào sự hỗ trợ cho việc sử dụng tổng kiểm tra một phần
giảm tải.  Vì lý do này TSO thường bị vô hiệu hóa nếu tổng kiểm tra Tx
giảm tải cho một thiết bị nhất định bị vô hiệu hóa.

Để hỗ trợ giảm tải phân đoạn TCP, cần phải điền
độ lệch tiêu đề mạng và vận chuyển của skbuff để thiết bị
trình điều khiển sẽ có thể xác định độ lệch của tiêu đề IP hoặc IPv6 và
Tiêu đề TCP.  Ngoài ra, CHECKSUM_PARTIAL là bắt buộc nên csum_start nên
cũng trỏ đến tiêu đề TCP của gói.

Đối với phân đoạn IPv4, chúng tôi hỗ trợ một trong hai loại về ID IP.
Hành vi mặc định là tăng ID IP với mỗi phân đoạn.  Nếu
GSO loại SKB_GSO_TCP_FIXEDID được chỉ định thì chúng tôi sẽ không tăng IP
ID và tất cả các phân đoạn sẽ sử dụng cùng một ID IP.

Đối với các gói được đóng gói, SKB_GSO_TCP_FIXEDID chỉ đề cập đến tiêu đề bên ngoài.
SKB_GSO_TCP_FIXEDID_INNER có thể được sử dụng để chỉ định tương tự cho tiêu đề bên trong.
Bất kỳ sự kết hợp nào của hai loại GSO này đều được cho phép.

Nếu một thiết bị đã đặt NETIF_F_TSO_MANGLEID thì ID IP có thể bị bỏ qua khi
thực hiện TSO và chúng tôi sẽ tăng ID IP cho tất cả các khung hoặc để lại
nó ở một giá trị tĩnh dựa trên sở thích của người lái xe.  Đối với các gói được đóng gói,
NETIF_F_TSO_MANGLEID có liên quan cho cả tiêu đề bên ngoài và bên trong, trừ khi
Bit DF không được đặt ở tiêu đề bên ngoài, trong trường hợp đó trình điều khiển thiết bị phải
đảm bảo rằng trường IP ID được tăng lên trong tiêu đề bên ngoài với mỗi
phân đoạn.


Giảm tải phân mảnh UDP
=========================

Giảm tải phân mảnh UDP cho phép thiết bị phân mảnh UDP quá khổ
datagram thành nhiều đoạn IPv4.  Nhiều yêu cầu đối với UDP
giảm tải phân mảnh giống như TSO.  Tuy nhiên ID IPv4 cho
các đoạn không được tăng lên khi một gói dữ liệu IPv4 bị phân mảnh.

UFO không được dùng nữa: các hạt nhân hiện đại sẽ không còn tạo ra các skbs UFO nữa, nhưng có thể
vẫn nhận được chúng từ Tuntap và các thiết bị tương tự. Giảm tải dựa trên UDP
giao thức đường hầm vẫn được hỗ trợ.


Đường hầm IPIP, SIT, GRE, UDP và Giảm tải tổng kiểm tra từ xa
=============================================================

Ngoài việc giảm tải được mô tả ở trên, một khung có thể
chứa các tiêu đề bổ sung như đường hầm bên ngoài.  Để hạch toán
đối với những trường hợp như vậy, một tập hợp bổ sung các loại giảm tải phân đoạn đã được
được giới thiệu bao gồm SKB_GSO_IPXIP4, SKB_GSO_IPXIP6, SKB_GSO_GRE và
SKB_GSO_UDP_TUNNEL.  Các loại phân đoạn bổ sung này được sử dụng để xác định
trường hợp có nhiều hơn 1 bộ tiêu đề.  Ví dụ như trong
trường hợp của IPIP và SIT chúng ta nên di chuyển các tiêu đề mạng và truyền tải
từ danh sách tiêu đề tiêu chuẩn đến phần bù tiêu đề "bên trong".

Hiện tại chỉ có hai cấp độ tiêu đề được hỗ trợ.  Công ước là để
coi các tiêu đề đường hầm là các tiêu đề bên ngoài, trong khi các tiêu đề được đóng gói
dữ liệu thường được gọi là các tiêu đề bên trong.  Dưới đây là danh sách
các cuộc gọi để truy cập các tiêu đề đã cho:

Đường hầm IPIP/SIT::

bên ngoài bên trong
  MAC skb_mac_header
  Mạng skb_network_header skb_inner_network_header
  Vận chuyển skb_transport_header

Đường hầm UDP/GRE::

bên ngoài bên trong
  MAC skb_mac_header skb_inner_mac_header
  Mạng skb_network_header skb_inner_network_header
  Vận chuyển skb_transport_header skb_inner_transport_header

Ngoài các loại đường hầm trên còn có SKB_GSO_GRE_CSUM và
SKB_GSO_UDP_TUNNEL_CSUM.  Hai loại đường hầm bổ sung này phản ánh
thực tế là tiêu đề bên ngoài cũng yêu cầu có tổng kiểm tra khác 0
bao gồm trong tiêu đề bên ngoài.

Cuối cùng là SKB_GSO_TUNNEL_REMCSUM cho biết rằng một đường hầm nhất định
tiêu đề đã yêu cầu giảm tải tổng kiểm tra từ xa.  Trong trường hợp này bên trong
các tiêu đề sẽ được để lại một phần tổng kiểm tra và chỉ có tiêu đề bên ngoài
tổng kiểm tra sẽ được tính toán.


Giảm tải phân đoạn chung
============================

Giảm tải phân khúc chung là giảm tải phần mềm thuần túy nhằm mục đích
xử lý các trường hợp trình điều khiển thiết bị không thể thực hiện việc giảm tải được mô tả
ở trên.  Điều xảy ra trong GSO là một skbuff nhất định sẽ bị hỏng dữ liệu
trên nhiều skbuff đã được thay đổi kích thước để phù hợp với MSS được cung cấp
thông qua skb_shinfo()->gso_size.

Trước khi kích hoạt bất kỳ phân đoạn phần cứng nào, hãy tải xuống phần mềm tương ứng
giảm tải là bắt buộc trong GSO.  Nếu không, một khung có thể
được định tuyến lại giữa các thiết bị và cuối cùng không thể truyền được.


Giảm tải nhận chung
=======================

Giảm tải nhận chung là phần bổ sung cho GSO.  Lý tưởng nhất là bất kỳ khung hình nào
được lắp ráp bởi GRO nên được phân đoạn để tạo ra một chuỗi giống hệt nhau
các khung sử dụng GSO và bất kỳ chuỗi khung nào được phân đoạn bởi GSO đều phải được
có thể được lắp ráp lại thành bản gốc bằng GRO.


Giảm tải phân khúc chung một phần
====================================

Giảm tải phân đoạn chung một phần là sự kết hợp giữa TSO và GSO.  cái gì
nó thực sự tận dụng được những đặc điểm nhất định của TCP và các đường hầm
để thay vì phải viết lại tiêu đề gói cho mỗi phân đoạn
chỉ tiêu đề truyền tải trong cùng và có thể là mạng ngoài cùng
tiêu đề cần được cập nhật.  Điều này cho phép các thiết bị không hỗ trợ đường hầm
giảm tải hoặc giảm tải đường hầm với tổng kiểm tra để vẫn sử dụng phân đoạn.

Với việc giảm tải một phần, điều xảy ra là tất cả các tiêu đề ngoại trừ
Tiêu đề vận chuyển bên trong được cập nhật sao cho chúng chứa đúng
giá trị nếu tiêu đề chỉ được sao chép đơn giản.  Một ngoại lệ cho điều này
là trường ID IPv4 bên ngoài.  Việc đảm bảo là tùy thuộc vào trình điều khiển thiết bị
trường ID IPv4 được tăng lên trong trường hợp một tiêu đề đã cho
không có tập hợp bit DF.


Tăng tốc SCTP với GSO
===========================

SCTP - mặc dù thiếu hỗ trợ phần cứng - vẫn có thể tận dụng
GSO để truyền một gói lớn qua ngăn xếp mạng, thay vì
nhiều gói nhỏ.

Điều này đòi hỏi một cách tiếp cận khác với các hoạt động giảm tải khác, vì các gói SCTP
không thể chỉ được phân đoạn thành (P)MTU. Đúng hơn, các khối phải được chứa trong
Phân đoạn IP, phần đệm được tôn trọng. Vì vậy, không giống như GSO thông thường, SCTP không thể chỉ
tạo một skb lớn, đặt gso_size thành điểm phân mảnh và phân phối nó
tới lớp IP.

Thay vào đó, lớp giao thức SCTP xây dựng một skb với các phân đoạn chính xác
được đệm và lưu trữ dưới dạng skbs được xâu chuỗi và skb_segment() phân tách dựa trên các skbs đó.
Để báo hiệu điều này, gso_size được đặt thành giá trị đặc biệt GSO_BY_FRAGS.

Do đó, bất kỳ mã nào trong ngăn xếp mạng lõi đều phải nhận biết được
khả năng gso_size sẽ là GSO_BY_FRAGS và xử lý trường hợp đó
một cách thích hợp.

Có một số trợ giúp để thực hiện việc này dễ dàng hơn:

- skb_is_gso(skb) && skb_is_gso_sctp(skb) là cách tốt nhất để xem liệu
  một skb là một skb SCTP GSO.

- Để kiểm tra kích thước, nhóm trợ giúp skb_gso_validate_*_len chính xác
  xem xét GSO_BY_FRAGS.

- Để thao tác với gói tin, skb_increase_gso_size và skb_decrease_gso_size
  sẽ kiểm tra GSO_BY_FRAGS và WARN nếu được yêu cầu thao tác với các skbs này.

Điều này cũng ảnh hưởng đến trình điều khiển với các bit NETIF_F_FRAGLIST & NETIF_F_GSO_SCTP
thiết lập. Cũng lưu ý rằng NETIF_F_GSO_SCTP được bao gồm trong NETIF_F_GSO_SOFTWARE.