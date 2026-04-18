.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/netdev-features.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================
Netdev có tính năng lộn xộn và cách thoát khỏi nó mà còn sống
=============================================================

tác giả:
	Michał Mirosław <mirq-linux@rere.qmqm.pl>



Phần I: Bộ tính năng
====================

Đã qua lâu rồi cái thời card mạng chỉ nhận và gửi gói tin
nguyên văn.  Các thiết bị ngày nay bổ sung nhiều tính năng và lỗi (đọc: giảm tải)
giúp hệ điều hành giảm bớt các tác vụ khác nhau như tạo và kiểm tra tổng kiểm tra,
tách các gói, phân loại chúng.  Những khả năng đó và trạng thái của chúng
thường được gọi là các tính năng netdev trong thế giới nhân Linux.

Hiện tại có ba bộ tính năng liên quan đến trình điều khiển và
một cái được sử dụng nội bộ bởi lõi mạng:

1. bộ netdev->hw_features chứa các tính năng có trạng thái có thể
    được thay đổi (bật hoặc tắt) cho một thiết bị cụ thể bởi người dùng
    yêu cầu.  Bộ này phải được khởi tạo trong lệnh gọi lại ndo_init chứ không phải
    đã thay đổi sau này.

2. netdev->bộ tính năng chứa các tính năng hiện được bật
    cho một thiết bị.  Điều này chỉ nên được thay đổi bởi lõi mạng hoặc trong
    đường dẫn lỗi của cuộc gọi lại ndo_set_features.

3. Bộ netdev->vlan_features chứa các tính năng có trạng thái được kế thừa
    bởi các thiết bị VLAN con (giới hạn netdev->bộ tính năng).  Đây là hiện tại
    được sử dụng cho tất cả các thiết bị VLAN cho dù thẻ bị tước hay chèn vào
    phần cứng hoặc phần mềm.

4. Bộ netdev->wanted_features chứa bộ tính năng được người dùng yêu cầu.
    Bộ này được lọc bởi lệnh gọi lại ndo_fix_features bất cứ khi nào nó hoặc
    một số điều kiện cụ thể của thiết bị thay đổi. Bộ này là nội bộ của
    lõi mạng và không nên được tham chiếu trong trình điều khiển.



Phần II: Kiểm soát các tính năng được kích hoạt
=====================================

Khi bộ tính năng hiện tại (netdev->features) được thay đổi, bộ tính năng mới
được tính toán và lọc bằng cách gọi lại ndo_fix_features
và netdev_fix_features(). Nếu tập kết quả khác với hiện tại
được đặt, nó sẽ được chuyển tới lệnh gọi lại ndo_set_features và (nếu lệnh gọi lại
trả về thành công) thay thế giá trị được lưu trữ trong netdev->features.
Thông báo NETDEV_FEAT_CHANGE được đưa ra sau đó bất cứ khi nào hiện tại
bộ có thể đã thay đổi.

Các sự kiện sau kích hoạt tính toán lại:
 1. đăng ký thiết bị, sau khi ndo_init trả về thành công
 2. người dùng yêu cầu thay đổi trạng thái tính năng
 3. netdev_update_features() được gọi

Lệnh gọi lại ndo_*_features được gọi khi rtnl_lock được giữ. Thiếu lệnh gọi lại
được coi là luôn mang lại thành công.

Trình điều khiển muốn kích hoạt tính toán lại phải thực hiện bằng cách gọi
netdev_update_features() trong khi giữ rtnl_lock. Điều này không nên được thực hiện
từ các cuộc gọi lại ndo_*_features. netdev->các tính năng không nên được sửa đổi bởi
driver ngoại trừ bằng cách gọi lại ndo_fix_features.



Phần III: Gợi ý triển khai
==============================

*ndo_fix_features:

Tất cả sự phụ thuộc giữa các tính năng sẽ được giải quyết ở đây. Kết quả
bộ có thể được giảm bớt hơn nữa bằng các giới hạn áp đặt trong lõi mạng (như được mã hóa
trong netdev_fix_features()). Vì lý do này, việc tắt một tính năng sẽ an toàn hơn
khi các phần phụ thuộc của nó không được đáp ứng thay vì buộc phải phụ thuộc vào.

Cuộc gọi lại này không được sửa đổi phần cứng cũng như trạng thái trình điều khiển (nên
không quốc tịch).  Nó có thể được gọi nhiều lần giữa các lần liên tiếp
cuộc gọi ndo_set_features.

Gọi lại không được thay đổi các tính năng có trong NETIF_F_SOFT_FEATURES hoặc
Bộ NETIF_F_NEVER_CHANGE. Ngoại lệ là NETIF_F_VLAN_CHALLENGED nhưng
phải cẩn thận vì thay đổi sẽ không ảnh hưởng đến các Vlan đã được cấu hình.

*ndo_set_features:

Phần cứng phải được cấu hình lại để phù hợp với bộ tính năng đã được thông qua. bộ
không nên thay đổi trừ khi có điều kiện lỗi nào đó xảy ra mà không thể
được phát hiện một cách đáng tin cậy trong ndo_fix_features. Trong trường hợp này, lệnh gọi lại
nên cập nhật các tính năng netdev-> để phù hợp với trạng thái phần cứng kết quả.
Các lỗi được trả về không (và không thể) được lan truyền ở bất kỳ đâu ngoại trừ dmesg.
(Lưu ý: trả về thành công bằng 0, >0 có nghĩa là lỗi im lặng.)



Phần IV: Đặc điểm
=================

Để biết danh sách tính năng hiện tại, hãy xem include/linux/netdev_features.h.
Phần này mô tả ngữ nghĩa của một số trong số chúng.

* Truyền tổng kiểm tra

Để biết mô tả đầy đủ, hãy xem các nhận xét ở gần đầu include/linux/skbuff.h.

Lưu ý: NETIF_F_HW_CSUM là siêu bộ của NETIF_F_IP_CSUM + NETIF_F_IPV6_CSUM.
Điều đó có nghĩa là thiết bị có thể điền tổng kiểm tra giống TCP/UDP ở bất kỳ đâu trong gói
bất kỳ tiêu đề nào có thể có.

* Truyền tải phân đoạn TCP

NETIF_F_TSO_ECN có nghĩa là phần cứng có thể phân chia các gói một cách chính xác bằng bit CWR
được đặt, có thể là TCPv4 (khi NETIF_F_TSO được bật) hoặc TCPv6 (NETIF_F_TSO6).

* Truyền tải phân đoạn UDP

NETIF_F_GSO_UDP_L4 chấp nhận một tiêu đề UDP duy nhất có tải trọng vượt quá
gso_size. Khi phân đoạn, nó phân đoạn tải trọng theo ranh giới gso_size và
sao chép mạng và các tiêu đề UDP (sửa tiêu đề cuối cùng nếu ít hơn
gso_size).

* Truyền DMA từ bộ nhớ cao

Trên các nền tảng có liên quan, NETIF_F_HIGHDMA báo hiệu rằng
ndo_start_xmit có thể xử lý skbs có phân đoạn trong bộ nhớ cao.

* Truyền phân tán-thu thập

Những tính năng đó nói rằng ndo_start_xmit có thể xử lý các skbs bị phân mảnh:
NETIF_F_SG --- skbs phân trang (skb_shinfo()->frags), NETIF_F_FRAGLIST ---
skbs được xâu chuỗi (skb->danh sách tiếp theo/trước).

* Tính năng phần mềm

Các tính năng có trong NETIF_F_SOFT_FEATURES là các tính năng của mạng
ngăn xếp. Người lái xe không nên thay đổi hành vi dựa trên chúng.

* VLAN được thử thách

NETIF_F_VLAN_CHALLENGED nên được đặt cho các thiết bị không thể xử lý VLAN
tiêu đề. Một số trình điều khiển đặt cài đặt này vì thẻ không thể xử lý MTU lớn hơn.
[FIXME: Những trường hợp đó có thể được khắc phục bằng mã VLAN bằng cách chỉ cho phép giảm-MTU
VLAN. Tuy nhiên, điều này có thể không hữu ích.]

* rx-fcs

Điều này yêu cầu NIC nối thêm Tổng kiểm tra khung Ethernet (FCS)
đến cuối dữ liệu skb.  Điều này cho phép các công cụ đánh hơi và các công cụ khác
đọc CRC được NIC ghi lại khi nhận được gói.

* rx-tất cả

Điều này yêu cầu NIC nhận tất cả các khung có thể, bao gồm cả khung bị lỗi.
khung (chẳng hạn như FCS xấu, v.v.).  Điều này có thể hữu ích khi đánh hơi một liên kết với
các gói xấu trên đó.  Một số NIC có thể nhận được nhiều gói hơn nếu được đặt ở chế độ bình thường
Chế độ PROMISC.

* rx-gro-hw

Điều này yêu cầu NIC kích hoạt Phần cứng GRO (giảm tải nhận chung).
Phần cứng GRO về cơ bản là đảo ngược hoàn toàn của TSO và nói chung là
chặt chẽ hơn Phần cứng LRO.  Luồng gói được hợp nhất bởi Phần cứng GRO phải
có thể được phân đoạn lại bởi GSO hoặc TSO để trở lại luồng gói ban đầu chính xác.
Phần cứng GRO phụ thuộc vào RXCSUM vì mọi gói được hợp nhất thành công
bằng phần cứng cũng phải có tổng kiểm tra được xác minh bằng phần cứng.

* hsr-tag-in-giảm tải

Điều này nên được đặt cho các thiết bị có lắp HSR (Tính sẵn sàng cao liền mạch
Redundancy) hoặc thẻ PRP (Giao thức dự phòng song song) tự động.

* hsr-tag-rm-giảm tải

Điều này nên được đặt cho các thiết bị loại bỏ HSR (Tính sẵn sàng cao liền mạch
Dự phòng) hoặc thẻ PRP (Giao thức dự phòng song song) tự động.

* hsr-fwd-giảm tải

Điều này nên được đặt cho các thiết bị chuyển tiếp HSR (Tính sẵn sàng cao liền mạch
Dự phòng) chuyển khung từ cổng này sang cổng khác trong phần cứng.

* hsr-dup-giảm tải

Điều này nên được đặt cho các thiết bị sao chép HSR gửi đi (Tính sẵn sàng cao
Tự động gắn thẻ Dự phòng liền mạch) hoặc PRP (Giao thức dự phòng song song)
khung trong phần cứng.

* netmem-tx

This should be set for devices which support netmem TX. Xem
Tài liệu/mạng/netmem.rst