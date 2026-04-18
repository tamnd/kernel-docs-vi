.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/bareudp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============================================
Tài liệu mô-đun đường hầm UDP trần
========================================

Có nhiều tiêu chuẩn đóng gói L3 khác nhau sử dụng UDP đang được thảo luận để
tận dụng khả năng cân bằng tải dựa trên UDP của các mạng khác nhau.
MPLSoUDP (ZZ0000ZZ là một trong số đó.

Mô-đun đường hầm Bareudp cung cấp hỗ trợ đóng gói L3 chung cho
tạo đường hầm cho các giao thức L3 khác nhau như MPLS, IP, NSH, v.v. bên trong đường hầm UDP.

Xử lý đặc biệt
----------------

Thiết bị bareudp hỗ trợ xử lý đặc biệt cho MPLS & IP khi chúng có thể có
nhiều loại ether.
Giao thức MPLS có thể có các loại ethertypes ETH_P_MPLS_UC (unicast) & ETH_P_MPLS_MC (multicast).
Giao thức IP có thể có các loại ethertypes ETH_P_IP (v4) & ETH_P_IPV6 (v6).
Việc xử lý đặc biệt này chỉ có thể được kích hoạt cho các loại ethertype ETH_P_IP & ETH_P_MPLS_UC
với một lá cờ gọi là chế độ multiproto.

Cách sử dụng
------

1) Tạo và xóa thiết bị

a) liên kết ip thêm dev bareudp0 gõ bareudp dstport 6635 ethertype mpls_uc

Điều này tạo ra một thiết bị đường hầm bareudp giúp điều chỉnh lưu lượng L3 bằng ethertype
       0x8847 (lưu lượng MPLS). Cổng đích của tiêu đề UDP sẽ được đặt thành
       6635. Thiết bị sẽ lắng nghe trên cổng UDP 6635 để nhận lưu lượng.

b) liên kết ip xóa bareudp0

2) Tạo thiết bị có bật chế độ multiproto

Chế độ multiproto cho phép các đường hầm bareudp xử lý một số giao thức của
cùng một gia đình. Nó hiện chỉ có sẵn cho IP và MPLS. Chế độ này phải
được kích hoạt rõ ràng bằng cờ "multiproto".

a) liên kết ip thêm dev bareudp0 loại bareudp dstport 6635 ethertype ipv4 multiproto

Đối với đường hầm IPv4, chế độ multiproto cho phép đường hầm cũng xử lý
       IPv6.

b) liên kết ip thêm dev bareudp0 loại bareudp dstport 6635 ethertype mpls_uc multiproto

Đối với MPLS, chế độ multiproto cho phép đường hầm xử lý cả unicast
       và các gói MPLS đa hướng.

3) Sử dụng thiết bị

Thiết bị bareudp có thể được sử dụng cùng với OVS hoặc bộ lọc hoa trong TC.
Lớp hoa OVS hoặc TC phải đặt thông tin đường hầm trong trường dst SKB trước
gửi bộ đệm gói đến thiết bị bareudp để truyền. Khi tiếp nhận,
thiết bị bareUDP trích xuất và lưu trữ thông tin đường hầm trong trường dst SKB trước đó
chuyển bộ đệm gói tới ngăn xếp mạng.