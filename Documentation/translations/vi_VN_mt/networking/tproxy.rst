.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tproxy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Hỗ trợ proxy minh bạch
===========================

Tính năng này bổ sung hỗ trợ proxy trong suốt giống Linux 2.2 cho các hạt nhân hiện tại.
Để sử dụng nó, hãy kích hoạt khớp ổ cắm và mục tiêu TPROXY trong cấu hình kernel của bạn.
Bạn cũng sẽ cần định tuyến chính sách, vì vậy hãy nhớ bật tính năng đó.

Hỗ trợ proxy minh bạch từ Linux 4.18 cũng có sẵn trong nf_tables.

1. Làm cho các ổ cắm không cục bộ hoạt động
================================

Ý tưởng là bạn xác định các gói có địa chỉ đích khớp với địa chỉ cục bộ
socket trên hộp của bạn, đặt dấu gói thành một giá trị nhất định ::

# iptables -t mangle -N DIVERT
    # iptables -t mangle -A PREROUTING -p tcp -m socket --transparent -j DIVERT
    # iptables -t mangle -A DIVERT -j MARK --set-mark 1
    # iptables -t mangle -A DIVERT -j ACCEPT

Ngoài ra, bạn có thể thực hiện việc này trong nft bằng các lệnh sau ::

# nft thêm bộ lọc bảng
    # nft thêm chuyển hướng bộ lọc chuỗi "{ loại móc lọc ưu tiên định tuyến trước -150; }"
    # nft thêm bộ lọc quy tắc chuyển hướng meta l4proto tcp socket trong suốt 1 bộ dấu meta 1 chấp nhận

Và sau đó khớp giá trị đó bằng cách sử dụng định tuyến chính sách để có các gói đó
giao hàng tận nơi::

Quy tắc # ip thêm fwmark 1 tra cứu 100
    Tuyến đường # ip thêm 0.0.0.0/0 cục bộ dev lo bảng 100

Do những hạn chế nhất định trong mã đầu ra định tuyến IPv4, bạn sẽ phải
sửa đổi ứng dụng của bạn để cho phép nó gửi datagram _from_ IP không phải cục bộ
địa chỉ. Tất cả những gì bạn phải làm là kích hoạt ổ cắm (SOL_IP, IP_TRANSPARENT)
tùy chọn trước khi gọi liên kết::

fd = ổ cắm(AF_INET, SOCK_STREAM, 0);
    /* - 8< -*/
    giá trị int = 1;
    setsockopt(fd, SOL_IP, IP_TRANSPARENT, &value, sizeof(value));
    /* - 8< -*/
    tên.sin_family = AF_INET;
    name.sin_port = htons(0xCAFE);
    name.sin_addr.s_addr = htonl(0xDEADBEEF);
    bind(fd, &name, sizeof(name));

Một bản vá tầm thường cho netcat có sẵn ở đây:
ZZ0000ZZ


2. Chuyển hướng giao thông
======================

Proxy minh bạch thường liên quan đến việc "chặn" lưu lượng truy cập trên bộ định tuyến. Đây là
thường được thực hiện với mục tiêu iptables REDIRECT; tuy nhiên, có những vấn đề nghiêm trọng
hạn chế của phương pháp đó. Một trong những vấn đề chính là nó thực sự
sửa đổi các gói để thay đổi địa chỉ đích -- địa chỉ này có thể không đúng
chấp nhận được trong những tình huống nhất định. (Ví dụ: hãy nghĩ đến việc ủy quyền UDP: bạn sẽ không
có thể tìm ra địa chỉ đích ban đầu. Ngay cả trong trường hợp TCP
nhận được địa chỉ đích ban đầu là không phù hợp.)

Mục tiêu 'TPROXY' cung cấp chức năng tương tự mà không cần dựa vào NAT. Đơn giản thôi
thêm các quy tắc như thế này vào bộ quy tắc iptables ở trên ::

# iptables -t mangle -A PREROUTING -p tcp --dport 80 -j TPROXY \
      --tproxy-mark 0x1/0x1 --trên cổng 50080

Hoặc quy tắc sau cho nft::

# nft thêm bộ lọc quy tắc chuyển hướng tcp dport 80 tproxy sang :50080 meta mark set 1 chấp nhận

Lưu ý rằng để tính năng này hoạt động, bạn sẽ phải sửa đổi proxy để bật (SOL_IP,
IP_TRANSPARENT) cho ổ cắm nghe.

Như một ví dụ triển khai, tcpdrr có sẵn ở đây:
ZZ0000ZZ
Công cụ này được viết bởi Florian Westphal và nó được sử dụng để thử nghiệm trong quá trình
triển khai nf_tables.

3. Tiện ích mở rộng Iptables và nf_tables
====================================

Để sử dụng tproxy, bạn cần phải biên dịch các mô-đun sau cho iptables:

-NETFILTER_XT_MATCH_SOCKET
 -NETFILTER_XT_TARGET_TPROXY

Hoặc các mô-đun chảy cho nf_tables:

-NFT_SOCKET
 -NFT_TPROXY

4. Hỗ trợ ứng dụng
======================

4.1. mực
----------

Squid 3.HEAD có hỗ trợ tích hợp. Để sử dụng nó, hãy vượt qua
'--enable-linux-netfilter' để định cấu hình và bật tùy chọn 'tproxy'
trình nghe HTTP mà bạn chuyển hướng lưu lượng truy cập đến bằng iptables TPROXY
mục tiêu.

Để biết thêm thông tin, vui lòng tham khảo trang sau về Squid
viwiki: ZZ0000ZZ