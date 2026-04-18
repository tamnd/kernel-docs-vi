.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/af_xdp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
AF_XDP
======

Tổng quan
========

AF_XDP là họ địa chỉ được tối ưu hóa cho hiệu suất cao
xử lý gói tin.

Tài liệu này giả định rằng người đọc đã quen thuộc với BPF và XDP. Nếu
không, dự án Cilium có hướng dẫn tham khảo tuyệt vời tại
ZZ0000ZZ

Sử dụng hành động XDP_REDIRECT từ chương trình XDP, chương trình có thể
chuyển hướng các khung xâm nhập sang các netdev đã kích hoạt XDP khác, bằng cách sử dụng
hàm bpf_redirect_map(). Ổ cắm AF_XDP cho phép khả năng
Các chương trình XDP để chuyển hướng khung hình đến bộ nhớ đệm trong không gian người dùng
ứng dụng.

Ổ cắm AF_XDP (XSK) được tạo bằng socket() thông thường
syscall. Liên kết với mỗi XSK là hai vòng: vòng RX và vòng
nhẫn TX. Một socket có thể nhận các gói trên vòng RX và nó có thể gửi
gói tin trên vòng TX. Những chiếc nhẫn này được đăng ký và có kích thước với
setockopts XDP_RX_RING và XDP_TX_RING tương ứng. Nó là bắt buộc
phải có ít nhất một trong các vòng này cho mỗi ổ cắm. RX hoặc TX
vòng mô tả trỏ đến vùng đệm dữ liệu trong vùng bộ nhớ được gọi là
UMEM. RX và TX có thể chia sẻ cùng một UMEM để gói không có
được sao chép giữa RX và TX. Hơn nữa, nếu một gói tin cần được giữ
trong một thời gian do có thể truyền lại, bộ mô tả trỏ tới
đến gói đó có thể được thay đổi để trỏ tới gói khác và được sử dụng lại ngay
đi xa. Điều này một lần nữa tránh việc sao chép dữ liệu.

UMEM bao gồm một số khối có kích thước bằng nhau. Một bộ mô tả trong
một trong các vòng tham chiếu đến khung bằng cách tham chiếu địa chỉ của nó. địa chỉ
chỉ đơn giản là phần bù trong toàn bộ vùng UMEM. Không gian người dùng
phân bổ bộ nhớ cho UMEM này bằng cách sử dụng bất kỳ phương tiện nào nó cảm thấy phù hợp nhất
thích hợp (malloc, mmap, các trang lớn, v.v.). Vùng nhớ này sau đó được
đã đăng ký với kernel bằng setsockopt XDP_UMEM_REG mới. các
UMEM cũng có hai vòng: vòng FILL và vòng COMPLETION. các
Vòng FILL được ứng dụng sử dụng để gửi addr xuống cho kernel
để điền dữ liệu gói RX. Các tham chiếu đến các khung này sau đó sẽ
xuất hiện trong vòng RX sau khi nhận được mỗi gói. các
Mặt khác, vòng COMPLETION chứa khung addr mà
kernel đã được truyền hoàn toàn và bây giờ người dùng có thể sử dụng lại
không gian, cho TX hoặc RX. Vì vậy, các bộ bổ sung khung xuất hiện trong
Vòng COMPLETION là các bộ cộng đã được truyền trước đó bằng cách sử dụng
nhẫn TX. Tóm lại, các vòng RX và FILL được sử dụng cho đường dẫn RX
và các vòng TX và COMPLETION được sử dụng cho đường dẫn TX.

Sau đó, ổ cắm cuối cùng được liên kết bằng lệnh gọi bind() tới một thiết bị và một
id hàng đợi cụ thể trên thiết bị đó và phải đến khi liên kết được
hoàn thành và lưu lượng truy cập bắt đầu chảy.

UMEM có thể được chia sẻ giữa các tiến trình nếu muốn. Nếu một quá trình
muốn làm điều này, nó chỉ cần bỏ qua việc đăng ký UMEM và
hai vòng tương ứng, đặt cờ XDP_SHARED_UMEM trong liên kết
gọi và gửi XSK của quy trình mà nó muốn chia sẻ UMEM
cũng như ổ cắm XSK mới được tạo ra của riêng nó. Quy trình mới sẽ
sau đó nhận các tham chiếu khung addr trong vòng RX của chính nó trỏ tới
điều này đã chia sẻ UMEM. Lưu ý rằng vì các cấu trúc vòng là
người tiêu dùng đơn lẻ / người sản xuất đơn lẻ (vì lý do hiệu suất), cái mới
quá trình phải tạo ổ cắm riêng với các vòng RX và TX liên quan,
vì nó không thể chia sẻ điều này với quá trình khác. Đây cũng là
lý do là chỉ có một bộ vòng FILL và COMPLETION cho mỗi
UMEM. Trách nhiệm của một quy trình duy nhất là xử lý UMEM.

Sau đó, các gói được phân phối từ chương trình XDP tới XSK như thế nào? Ở đó
là bản đồ BPF có tên XSKMAP (hoặc BPF_MAP_TYPE_XSKMAP đầy đủ). các
ứng dụng không gian người dùng có thể đặt XSK ở một vị trí tùy ý trong này
bản đồ. Chương trình XDP sau đó có thể chuyển hướng gói đến một chỉ mục cụ thể trong
bản đồ này và tại thời điểm này XDP xác nhận rằng XSK trong bản đồ đó là
thực sự bị ràng buộc với thiết bị và số chuông đó. Nếu không, gói tin sẽ
bị rơi. Nếu bản đồ trống ở chỉ mục đó thì gói tin cũng
bị rơi. Điều này cũng có nghĩa là hiện tại bắt buộc phải có XDP
chương trình đã được tải (và một XSK trong XSKMAP) để có thể nhận được bất kỳ
lưu lượng truy cập vào không gian người dùng thông qua XSK.

AF_XDP có thể hoạt động ở hai chế độ khác nhau: XDP_SKB và XDP_DRV. Nếu
trình điều khiển không hỗ trợ XDP hoặc XDP_SKB được chọn rõ ràng
khi tải chương trình XDP, chế độ XDP_SKB sử dụng SKB được sử dụng
cùng với sự hỗ trợ chung của XDP và sao chép dữ liệu tới người dùng
không gian. Chế độ dự phòng hoạt động cho mọi thiết bị mạng. Mặt khác
tay, nếu trình điều khiển có hỗ trợ cho XDP, nó sẽ được AF_XDP sử dụng
mã để cung cấp hiệu suất tốt hơn, nhưng vẫn còn một bản sao của
dữ liệu vào không gian người dùng.

Khái niệm
========

Để sử dụng ổ cắm AF_XDP, một số đối tượng liên quan cần
để được thiết lập. Những đối tượng này và các lựa chọn của chúng được giải thích trong phần
các phần sau.

Để biết tổng quan về cách AF_XDP hoạt động, bạn cũng có thể xem
Bài viết của Linux Plumbers từ năm 2018 về chủ đề:
ZZ0000ZZ Làm
NOT tham khảo bài viết năm 2017 về "AF_PACKET v4", lần thử đầu tiên
tại AF_XDP. Gần như mọi thứ đã thay đổi kể từ đó. Jonathan Corbet có
cũng đã viết một bài báo xuất sắc trên LWN, "Tăng tốc mạng
với AF_XDP". Nó có thể được tìm thấy tại ZZ0001ZZ

UMEM
----

UMEM là vùng bộ nhớ ảo liền kề, được chia thành
khung có kích thước bằng nhau. UMEM được liên kết với netdev và một địa chỉ cụ thể
id hàng đợi của netdev đó. Nó được tạo và cấu hình (kích thước chunk,
khoảng trống, địa chỉ bắt đầu và kích thước) bằng cách sử dụng XDP_UMEM_REG setsockopt
cuộc gọi hệ thống. UMEM được liên kết với netdev và id hàng đợi, thông qua liên kết ()
cuộc gọi hệ thống.

AF_XDP là ổ cắm được liên kết với một UMEM duy nhất, nhưng một UMEM có thể có
nhiều ổ cắm AF_XDP. Để chia sẻ UMEM được tạo thông qua một ổ cắm A,
socket B tiếp theo có thể thực hiện việc này bằng cách đặt cờ XDP_SHARED_UMEM trong
struct sockaddr_xdp thành viên sxdp_flags và chuyển bộ mô tả tệp
của A tới struct sockaddr_xdp thành viên sxdp_shared_umem_fd.

UMEM có hai vòng dành cho một nhà sản xuất/một người tiêu dùng được sử dụng
để chuyển quyền sở hữu các khung UMEM giữa kernel và
ứng dụng không gian người dùng.

Nhẫn
-----

Có bốn loại vòng khác nhau: FILL, COMPLETION, RX và
TX. Tất cả các vòng đều là một nhà sản xuất/một người tiêu dùng, vì vậy không gian người dùng
ứng dụng cần đồng bộ hóa rõ ràng nhiều
các tiến trình/luồng đang đọc/ghi vào chúng.

UMEM sử dụng hai vòng: FILL và COMPLETION. Mỗi ổ cắm liên kết
với UMEM phải có hàng đợi RX, hàng đợi TX hoặc cả hai. Nói rằng ở đó
là một thiết lập có bốn ổ cắm (tất cả đều hoạt động TX và RX). Sau đó sẽ có
một vòng FILL, một vòng COMPLETION, bốn vòng TX và bốn vòng RX.

Các vòng là các vòng dựa trên đầu (nhà sản xuất)/đuôi (người tiêu dùng). Một nhà sản xuất
ghi vòng dữ liệu vào chỉ mục được chỉ ra bởi struct xdp_ring
thành viên sản xuất và tăng chỉ số nhà sản xuất. Một người tiêu dùng đọc
vòng dữ liệu tại chỉ mục được chỉ ra bởi người tiêu dùng struct xdp_ring
thành viên và tăng chỉ số tiêu dùng.

Các vòng được cấu hình và tạo thông qua hệ thống setsockopt _RING
gọi và mmapped vào không gian người dùng bằng cách sử dụng offset thích hợp cho mmap()
(XDP_PGOFF_RX_RING, XDP_PGOFF_TX_RING, XDP_UMEM_PGOFF_FILL_RING và
XDP_UMEM_PGOFF_COMPLETION_RING).

Kích thước của các vòng phải có kích thước bằng hai.

Vòng điền UMEM
~~~~~~~~~~~~~~

Vòng FILL được sử dụng để chuyển quyền sở hữu các khung UMEM từ
không gian người dùng sang không gian kernel. Các bộ cộng UMEM được truyền vào vòng. Như
một ví dụ: nếu UMEM là 64k và mỗi đoạn là 4k thì UMEM có
16 khối và có thể chuyển các bộ cộng trong khoảng từ 0 đến 64k.

Các khung được truyền tới kernel được sử dụng cho đường dẫn vào (các vòng RX).

Ứng dụng người dùng tạo ra các bộ bổ sung UMEM cho vòng này. Lưu ý rằng, nếu
chạy ứng dụng với chế độ chunk được căn chỉnh, kernel sẽ che dấu
địa chỉ đến.  Ví dụ. đối với kích thước chunk là 2k, log2(2048) LSB của
addr sẽ bị che đi, nghĩa là 2048, 2050 và 3000 đề cập đến
vào cùng một đoạn. Nếu ứng dụng người dùng được chạy ở chế độ không được căn chỉnh
chế độ chunk, thì addr đến sẽ không bị ảnh hưởng.


Vòng hoàn thành UMEM
~~~~~~~~~~~~~~~~~~~~

Vòng COMPLETION được sử dụng để chuyển quyền sở hữu các khung UMEM từ
không gian kernel sang không gian người dùng. Giống như vòng FILL, chỉ số UMEM là
đã sử dụng.

Các khung được truyền từ kernel tới không gian người dùng là các khung đã được
đã gửi (vòng TX) và có thể được sử dụng lại bởi không gian người dùng.

Ứng dụng người dùng sử dụng bộ bổ sung UMEM từ vòng này.


Vòng RX
~~~~~~~

Vòng RX là phía nhận của ổ cắm. Mỗi mục trong vòng
là một bộ mô tả struct xdp_desc. Bộ mô tả chứa phần bù UMEM
(addr) và độ dài của dữ liệu (len).

Nếu không có khung nào được chuyển tới kernel thông qua vòng FILL, thì không
bộ mô tả sẽ (hoặc có thể) xuất hiện trên vòng RX.

Ứng dụng người dùng sử dụng các bộ mô tả struct xdp_desc từ đây
chiếc nhẫn.

Nhẫn TX
~~~~~~~

Vòng TX được sử dụng để gửi khung. Bộ mô tả struct xdp_desc là
được lấp đầy (chỉ số, chiều dài và độ lệch) và chuyển vào vòng.

Để bắt đầu chuyển, cần có lệnh gọi hệ thống sendmsg(). Điều này có thể
được thư giãn trong tương lai.

Ứng dụng người dùng tạo ra các mô tả struct xdp_desc cho điều này
chiếc nhẫn.

Libbpf
======

Libbpf là thư viện trợ giúp cho eBPF và XDP giúp sử dụng các thư viện này
công nghệ đơn giản hơn rất nhiều. Nó cũng chứa các chức năng trợ giúp cụ thể
trong tools/testing/selftests/bpf/xsk.h để tạo điều kiện thuận lợi cho việc sử dụng
AF_XDP. Nó chứa hai loại chức năng: những loại có thể được sử dụng để
giúp việc thiết lập ổ cắm AF_XDP dễ dàng hơn và những ổ cắm có thể được sử dụng trong
mặt phẳng dữ liệu để truy cập các vòng một cách an toàn và nhanh chóng.

Chúng tôi khuyên bạn nên sử dụng thư viện này trừ khi bạn đã trở thành một thế lực
người dùng. Nó sẽ làm cho chương trình của bạn đơn giản hơn rất nhiều.

XSKMAP / BPF_MAP_TYPE_XSKMAP
============================

Về phía XDP có loại bản đồ BPF BPF_MAP_TYPE_XSKMAP (XSKMAP)
được sử dụng cùng với bpf_redirect_map() để vượt qua lối vào
khung vào một ổ cắm.

Ứng dụng người dùng chèn ổ cắm vào bản đồ, thông qua bpf()
cuộc gọi hệ thống.

Lưu ý rằng nếu một chương trình XDP cố gắng chuyển hướng đến một ổ cắm có
không khớp với cấu hình hàng đợi và netdev, khung sẽ bị
bị rơi. Ví dụ. một ổ cắm AF_XDP được liên kết với netdev eth0 và
hàng đợi 17. Chỉ chương trình XDP thực thi cho eth0 và hàng đợi 17 mới
truyền dữ liệu thành công vào ổ cắm. Hãy tham khảo mẫu
ứng dụng (mẫu/bpf/) làm ví dụ.

Cờ cấu hình và tùy chọn ổ cắm
======================================

Đây là các cờ cấu hình khác nhau có thể được sử dụng để kiểm soát
và giám sát hoạt động của ổ cắm AF_XDP.

Cờ liên kết XDP_COPY và XDP_ZEROCOPY
------------------------------------

Khi bạn liên kết với một ổ cắm, trước tiên kernel sẽ cố gắng sử dụng tính năng không sao chép
sao chép. Nếu không hỗ trợ bản sao, nó sẽ quay trở lại sử dụng bản sao
chế độ, tức là sao chép tất cả các gói ra không gian người dùng. Nhưng nếu bạn muốn
muốn buộc một chế độ nhất định, bạn có thể sử dụng các cờ sau. Nếu bạn
chuyển cờ XDP_COPY cho lệnh gọi liên kết, kernel sẽ buộc
socket vào chế độ sao chép. Nếu nó không thể sử dụng chế độ sao chép, lệnh gọi liên kết sẽ
thất bại với một lỗi. Ngược lại, cờ XDP_ZEROCOPY sẽ buộc
chuyển sang chế độ không sao chép hoặc bị lỗi.

Cờ liên kết XDP_SHARED_UMEM
-------------------------

Cờ này cho phép bạn liên kết nhiều ổ cắm với cùng một UMEM. Nó
hoạt động trên cùng một id hàng đợi, giữa các id hàng đợi và giữa
netdev/thiết bị. Ở chế độ này, mỗi ổ cắm có RX và TX riêng
đổ chuông như thường lệ, nhưng bạn sẽ có một hoặc nhiều FILL và
Cặp vòng COMPLETION. Bạn phải tạo một trong những cặp này cho mỗi
bộ dữ liệu id hàng đợi và netdev duy nhất mà bạn liên kết.

Bắt đầu với trường hợp này, chúng tôi muốn chia sẻ UMEM giữa
ổ cắm được liên kết với cùng một netdev và id hàng đợi. UMEM (được gắn với
ổ cắm nắm tay được tạo) sẽ chỉ có một vòng FILL duy nhất và một
COMPLETION đổ chuông vì chỉ có bộ dữ liệu netdev,queue_id duy nhất mới có
chúng tôi đã ràng buộc. Để sử dụng chế độ này, hãy tạo socket đầu tiên và liên kết
nó theo cách thông thường. Tạo ổ cắm thứ hai và tạo RX và TX
đổ chuông, hoặc ít nhất một trong số chúng, nhưng không có FILL hoặc COMPLETION đổ chuông như
những cái từ ổ cắm đầu tiên sẽ được sử dụng. Trong cuộc gọi liên kết, đặt anh ấy
Tùy chọn XDP_SHARED_UMEM và cung cấp fd của ổ cắm ban đầu trong
trường sxdp_shared_umem_fd. Bạn có thể đính kèm một số lượng bổ sung tùy ý
ổ cắm theo cách này.

Gói tin sẽ đến ổ cắm nào? Việc này do XDP quyết định
chương trình. Đặt tất cả các ổ cắm vào XSK_MAP và chỉ ra ổ cắm nào
chỉ mục trong mảng bạn muốn gửi từng gói tới. Một cách đơn giản
ví dụ vòng tròn về phân phối gói được hiển thị bên dưới:

.. code-block:: c

   #include <linux/bpf.h>
   #include "bpf_helpers.h"

   #define MAX_SOCKS 16

   struct {
       __uint(type, BPF_MAP_TYPE_XSKMAP);
       __uint(max_entries, MAX_SOCKS);
       __uint(key_size, sizeof(int));
       __uint(value_size, sizeof(int));
   } xsks_map SEC(".maps");

   static unsigned int rr;

   SEC("xdp_sock") int xdp_sock_prog(struct xdp_md *ctx)
   {
       rr = (rr + 1) & (MAX_SOCKS - 1);

       return bpf_redirect_map(&xsks_map, rr, XDP_DROP);
   }

Lưu ý rằng vì chỉ có một bộ FILL và COMPLETION duy nhất
nhẫn và họ là nhà sản xuất duy nhất, vòng tiêu dùng duy nhất, bạn cần
để đảm bảo rằng nhiều tiến trình hoặc luồng không sử dụng các vòng này
đồng thời. Không có nguyên thủy đồng bộ hóa trong
mã libbpf bảo vệ nhiều người dùng tại thời điểm này.

Libbpf sử dụng chế độ này nếu bạn tạo nhiều hơn một socket gắn với
cùng UMEM. Tuy nhiên, lưu ý rằng bạn cần cung cấp
XSK_LIBBPF_FLAGS__INHIBIT_PROG_LOAD libbpf_flag với
xsk_socket__tạo cuộc gọi và tải chương trình XDP của riêng bạn vì không có
được tích hợp sẵn trong libbpf sẽ định tuyến lưu lượng truy cập cho bạn.

Trường hợp thứ hai là khi bạn chia sẻ UMEM giữa các ổ cắm
bị ràng buộc với các id hàng đợi và/hoặc netdev khác nhau. Trong trường hợp này bạn phải
tạo một vòng FILL và một vòng COMPLETION cho mỗi vòng duy nhất
cặp netdev,queue_id. Giả sử bạn muốn tạo hai ổ cắm bị ràng buộc
tới hai id hàng đợi khác nhau trên cùng một netdev. Tạo ổ cắm đầu tiên
và ràng buộc nó theo cách thông thường. Tạo ổ cắm thứ hai và tạo RX
và một vòng TX, hoặc ít nhất một trong số chúng, sau đó là một FILL và
Vòng COMPLETION cho ổ cắm này. Sau đó, trong lệnh gọi liên kết, hãy đặt anh ấy
Tùy chọn XDP_SHARED_UMEM và cung cấp fd của ổ cắm ban đầu trong
trường sxdp_shared_umem_fd khi bạn đăng ký UMEM trên đó
ổ cắm. Hai ổ cắm này bây giờ sẽ dùng chung một UMEM.

Không cần phải cung cấp chương trình XDP như chương trình trước
trường hợp ổ cắm được liên kết với cùng một id hàng đợi và
thiết bị. Thay vào đó, hãy sử dụng khả năng điều khiển gói của NIC để điều khiển
các gói vào đúng hàng đợi. Trong ví dụ trước, chỉ có
một hàng đợi được chia sẻ giữa các ổ cắm, vì vậy NIC không thể thực hiện việc điều khiển này. Nó
chỉ có thể lái giữa các hàng đợi.

Trong libbpf, bạn cần sử dụng xsk_socket__create_shared() API vì nó
tham chiếu đến vòng FILL và vòng COMPLETION sẽ
được tạo cho bạn và được liên kết với UMEM được chia sẻ. Bạn có thể sử dụng cái này
chức năng cho tất cả các ổ cắm bạn tạo hoặc bạn có thể sử dụng nó cho
cái thứ hai và những cái tiếp theo và sử dụng xsk_socket__create() cho cái đầu tiên
một. Cả hai phương pháp đều mang lại kết quả như nhau.

Lưu ý rằng UMEM có thể được chia sẻ giữa các ổ cắm trên cùng một id hàng đợi
và thiết bị, cũng như giữa các hàng đợi trên cùng một thiết bị và giữa
các thiết bị cùng một lúc.

Cờ liên kết XDP_USE_NEED_WAKEUP
-----------------------------

Tùy chọn này thêm hỗ trợ cho một cờ mới có tên là need_wakeup.
có trong vòng FILL và vòng TX, các vòng dành cho người dùng
không gian là một nhà sản xuất. Khi tùy chọn này được đặt trong lệnh gọi liên kết,
cờ need_wakeup sẽ được đặt nếu kernel cần rõ ràng
được đánh thức bởi một cuộc gọi hệ thống để tiếp tục xử lý các gói tin. Nếu cờ là
không, không cần syscall.

Nếu cờ được đặt trên vòng FILL, ứng dụng cần gọi
poll() để có thể tiếp tục nhận gói tin trên vòng RX. Cái này
có thể xảy ra, ví dụ, khi kernel phát hiện ra rằng không có
nhiều bộ đệm hơn trên vòng FILL và không còn bộ đệm nào trên vòng RX HW của
NIC. Trong trường hợp này, các ngắt bị tắt vì NIC không thể
nhận bất kỳ gói nào (vì không có bộ đệm để đặt chúng vào) và
cờ need_wakeup được đặt để không gian người dùng có thể đặt bộ đệm trên
FILL đổ chuông rồi gọi thăm dò ý kiến() để trình điều khiển hạt nhân có thể đặt những thứ này
bộ đệm trên vòng CTNH và bắt đầu nhận gói.

Nếu cờ được đặt cho vòng TX, điều đó có nghĩa là ứng dụng
cần thông báo rõ ràng cho kernel để gửi bất kỳ gói nào được đặt trên
nhẫn TX. Điều này có thể được thực hiện bằng lệnh gọi poll(), như trong
Đường dẫn RX hoặc bằng cách gọi sendto().

Một ví dụ về việc sử dụng các trình trợ giúp libbpf sẽ trông như thế này cho
Đường dẫn TX:

.. code-block:: c

   if (xsk_ring_prod__needs_wakeup(&my_tx_ring))
       sendto(xsk_socket__fd(xsk_handle), NULL, 0, MSG_DONTWAIT, NULL, 0);

Tức là chỉ sử dụng syscall nếu cờ được đặt.

Chúng tôi khuyên bạn luôn bật chế độ này vì nó thường dẫn đến
hiệu suất tốt hơn đặc biệt nếu bạn chạy ứng dụng và
trình điều khiển trên cùng một lõi cũng như nếu bạn sử dụng các lõi khác nhau cho
ứng dụng và trình điều khiển hạt nhân, vì nó làm giảm số lượng
syscalls cần thiết cho đường dẫn TX.

XDP_{RXZZ0000ZZUMEM_FILL|UMEM_COMPLETION}_RING bộ khóa
------------------------------------------------------

Các setsockopt này đặt số lượng bộ mô tả mà RX, TX,
Các vòng FILL và COMPLETION tương ứng nên có. Nó là bắt buộc
để đặt kích thước của ít nhất một trong các vòng RX và TX. Nếu bạn đặt
cả hai, bạn sẽ có thể vừa nhận và gửi lưu lượng truy cập từ
ứng dụng, nhưng nếu bạn chỉ muốn thực hiện một trong số đó, bạn có thể lưu
tài nguyên bằng cách chỉ thiết lập một trong số chúng. Cả vòng FILL và
Vòng COMPLETION là bắt buộc vì bạn cần phải gắn UMEM vào
ổ cắm. Nhưng nếu cờ XDP_SHARED_UMEM được sử dụng, bất kỳ socket nào sau cờ này
cái đầu tiên không có UMEM và trong trường hợp đó sẽ không có bất kỳ
Các vòng FILL hoặc COMPLETION được tạo giống như các vòng từ UMEM được chia sẻ sẽ
được sử dụng. Lưu ý rằng những chiếc nhẫn là người tiêu dùng đơn lẻ, một nhà sản xuất, vì vậy
đừng cố truy cập chúng từ nhiều quy trình cùng một lúc
thời gian. Xem phần XDP_SHARED_UMEM.

Trong libbpf, bạn có thể tạo các ổ cắm chỉ Rx và chỉ Tx bằng cách cung cấp
NULL cho các đối số rx và tx tương ứng với
hàm xsk_socket__create.

Nếu bạn tạo một ổ cắm chỉ dành cho Tx, chúng tôi khuyên bạn không nên đặt bất kỳ ổ cắm nào
các gói trên vòng điền. Nếu bạn làm điều này, người lái xe có thể nghĩ rằng bạn
sẽ nhận được thứ gì đó trong khi thực tế bạn sẽ không nhận được, và điều này có thể
tác động tiêu cực đến hiệu suất.

Bộ XDP_UMEM_REGsockopt
-----------------------

setsockopt này đăng ký UMEM vào ổ cắm. Đây là khu vực mà
chứa tất cả các bộ đệm mà gói có thể cư trú. Cuộc gọi mất một
con trỏ đến phần đầu của vùng này và kích thước của nó. Hơn nữa, nó
cũng có tham số gọi là chunk_size, đó là kích thước của UMEM
chia thành. Hiện tại nó chỉ có thể là 2K hoặc 4K. Nếu bạn có một
Vùng UMEM có kích thước 128K và kích thước chunk là 2K, điều này có nghĩa là bạn
sẽ có thể chứa tối đa 128K / 2K = 64 gói trong UMEM của bạn
diện tích và kích thước gói lớn nhất của bạn có thể là 2K.

Ngoài ra còn có một tùy chọn để đặt khoảng trống của từng bộ đệm trong
UMEM. Nếu bạn đặt giá trị này thành N byte, điều đó có nghĩa là gói sẽ
bắt đầu N byte vào bộ đệm để lại N byte đầu tiên cho
ứng dụng để sử dụng. Tùy chọn cuối cùng là trường cờ, nhưng nó sẽ
được xử lý trong các phần riêng biệt cho mỗi cờ UMEM.

Bộ SO_BINDTODEVICEsockopt
--------------------------

Đây là tùy chọn SOL_SOCKET chung có thể được sử dụng để buộc AF_XDP
socket vào một giao diện mạng cụ thể.  Nó rất hữu ích khi một ổ cắm
được tạo bởi một quy trình đặc quyền và được chuyển đến một quy trình không có đặc quyền.
Khi tùy chọn được đặt, kernel sẽ từ chối các nỗ lực liên kết ổ cắm đó
sang một giao diện khác.  Cập nhật giá trị yêu cầu CAP_NET_RAW.

Bộ XDP_MAX_TX_SKB_BUDGETsockopt
--------------------------------

setsockopt này đặt số lượng mô tả tối đa có thể được xử lý
và chuyển cho trình điều khiển trong một lần gửi syscall. Nó được áp dụng trong bản sao
chế độ cho phép ứng dụng điều chỉnh số lần lặp tối đa trên mỗi ổ cắm cho
thông lượng tốt hơn và tần suất gửi syscall ít hơn.
Phạm vi được phép là [32, xs->tx->nentries].

XDP_STATISTICS bị khóa
-------------------------

Nhận số liệu thống kê về ổ cắm có thể hữu ích cho việc gỡ lỗi
mục đích. Các số liệu thống kê được hỗ trợ được hiển thị dưới đây:

.. code-block:: c

   struct xdp_statistics {
       __u64 rx_dropped; /* Dropped for reasons other than invalid desc */
       __u64 rx_invalid_descs; /* Dropped due to invalid descriptor */
       __u64 tx_invalid_descs; /* Dropped due to invalid descriptor */
   };

XDP_OPTIONS bị khóa
----------------------

Nhận các tùy chọn từ ổ cắm XDP. Người duy nhất được hỗ trợ cho đến nay là
XDP_OPTIONS_ZEROCOPY cho bạn biết liệu tính năng không sao chép có được bật hay không.

Hỗ trợ nhiều bộ đệm
====================

Với sự hỗ trợ đa bộ đệm, các chương trình sử dụng ổ cắm AF_XDP có thể nhận được
và truyền các gói bao gồm nhiều bộ đệm cả ở dạng bản sao và
chế độ không sao chép. Ví dụ, một gói có thể bao gồm hai
khung/bộ đệm, một có tiêu đề và một có dữ liệu,
hoặc khung jumbo Ethernet 9K có thể được xây dựng bằng cách kết nối với nhau
ba khung hình 4K.

Một số định nghĩa:

* Một gói bao gồm một hoặc nhiều khung

* Bộ mô tả trong một trong các vòng AF_XDP luôn đề cập đến một
  khung. Trong trường hợp gói bao gồm một khung duy nhất,
  bộ mô tả đề cập đến toàn bộ gói.

Để bật hỗ trợ nhiều bộ đệm cho ổ cắm AF_XDP, hãy sử dụng liên kết mới
cờ XDP_USE_SG. Nếu điều này không được cung cấp, tất cả các gói nhiều bộ đệm
sẽ bị loại bỏ như trước. Lưu ý rằng chương trình XDP cũng được tải
cần phải ở chế độ đa bộ đệm. Điều này có thể được thực hiện bằng cách sử dụng
"xdp.frags" là tên phần của chương trình XDP được sử dụng.

Để biểu diễn một gói gồm nhiều khung, một cờ mới được gọi là
XDP_PKT_CONTD được giới thiệu trong trường tùy chọn của Rx và Tx
những người mô tả. Nếu đúng (1) gói tiếp tục với gói tiếp theo
bộ mô tả và nếu nó sai (0) thì có nghĩa đây là bộ mô tả cuối cùng
của gói tin. Tại sao lại tìm thấy logic ngược của cờ kết thúc gói (eop)
trong nhiều NIC? Chỉ để duy trì khả năng tương thích với không có nhiều bộ đệm
các ứng dụng có bit này được đặt thành false cho tất cả các gói trên Rx,
và các ứng dụng đặt trường tùy chọn về 0 cho Tx, như mọi thứ khác
sẽ được coi là một mô tả không hợp lệ.

Đây là ngữ nghĩa để tạo các gói trên vòng Tx AF_XDP
bao gồm nhiều khung:

* Khi tìm thấy một bộ mô tả không hợp lệ, tất cả các mô tả khác
  mô tả/khung của gói này được đánh dấu là không hợp lệ và không
  hoàn thành. Bộ mô tả tiếp theo được coi là sự khởi đầu của một mô tả mới
  gói tin, ngay cả khi đây không phải là mục đích (vì chúng ta không thể đoán được
  ý định). Như trước đây, nếu chương trình của bạn tạo ra lỗi không hợp lệ
  mô tả bạn có một lỗi cần phải sửa.

* Bộ mô tả có độ dài bằng 0 được coi là bộ mô tả không hợp lệ.

* Đối với chế độ sao chép, số lượng khung hình được hỗ trợ tối đa trong một gói là
  bằng CONFIG_MAX_SKB_FRAGS + 1. Nếu vượt quá, tất cả
  mô tả được tích lũy cho đến nay sẽ bị loại bỏ và được coi là
  không hợp lệ. Để tạo ra một ứng dụng sẽ hoạt động trên mọi hệ thống
  bất kể cài đặt cấu hình này như thế nào, hãy giới hạn số lượng phân đoạn ở mức 18,
  vì giá trị tối thiểu của cấu hình là 17.

* Đối với chế độ không sao chép, giới hạn lên tới NIC HW
  hỗ trợ. Thông thường có ít nhất năm trên NIC mà chúng tôi đã kiểm tra. Chúng tôi
  có ý thức chọn cách không thực thi một giới hạn cứng nhắc (chẳng hạn như
  CONFIG_MAX_SKB_FRAGS + 1) cho chế độ không sao chép, như lẽ ra nó phải có
  dẫn đến các hành động sao chép ngầm để phù hợp với giới hạn của
  NIC hỗ trợ. Loại đánh bại mục đích của chế độ không sao chép. Làm thế nào để
  đầu dò cho giới hạn này được giải thích trong phần "thăm dò cho nhiều bộ đệm
  phần hỗ trợ".

Trên đường dẫn Rx ở chế độ sao chép, lõi xsk sao chép dữ liệu XDP vào
nhiều bộ mô tả, nếu cần và đặt cờ XDP_PKT_CONTD là
chi tiết trước đó. Chế độ không sao chép hoạt động tương tự, tuy nhiên dữ liệu thì không
được sao chép. Khi ứng dụng nhận được bộ mô tả với XDP_PKT_CONTD
cờ được đặt thành một, điều đó có nghĩa là gói bao gồm nhiều bộ đệm
và nó tiếp tục với bộ đệm tiếp theo sau
mô tả. Khi nhận được bộ mô tả có XDP_PKT_CONTD == 0, nó
có nghĩa đây là bộ đệm cuối cùng của gói. AF_XDP đảm bảo
rằng chỉ có một gói hoàn chỉnh (tất cả các khung trong gói) được gửi đến
ứng dụng. Nếu không có đủ dung lượng trong vòng AF_XDP Rx, tất cả
khung của gói sẽ bị loại bỏ.

Nếu ứng dụng đọc một loạt các bộ mô tả, ví dụ như sử dụng libxdp
giao diện, không đảm bảo rằng lô sẽ kết thúc với đầy đủ
gói. Nó có thể kết thúc ở giữa gói và phần còn lại của
bộ đệm của gói đó sẽ đến vào đầu đợt tiếp theo,
vì giao diện libxdp không đọc toàn bộ vòng (trừ khi bạn
có kích thước lô rất lớn hoặc kích thước vòng rất nhỏ).

Có thể tìm thấy một chương trình ví dụ cho từng hỗ trợ đa bộ đệm Rx và Tx
sau này trong tài liệu này.

Cách sử dụng
-----

Để sử dụng ổ cắm AF_XDP, cần có hai phần. Không gian người dùng
ứng dụng và chương trình XDP. Để có ví dụ thiết lập và sử dụng hoàn chỉnh,
vui lòng tham khảo dự án xdp tại
ZZ0000ZZ

Mẫu mã XDP như sau:

.. code-block:: c

   SEC("xdp_sock") int xdp_sock_prog(struct xdp_md *ctx)
   {
       int index = ctx->rx_queue_index;

       // A set entry here means that the corresponding queue_id
       // has an active AF_XDP socket bound to it.
       if (bpf_map_lookup_elem(&xsks_map, &index))
           return bpf_redirect_map(&xsks_map, index, 0);

       return XDP_PASS;
   }

Một vòng dequeue và enqueue có thể trông đơn giản nhưng không hiệu quả lắm
như thế này:

.. code-block:: c

    // struct xdp_rxtx_ring {
    //     __u32 *producer;
    //     __u32 *consumer;
    //     struct xdp_desc *desc;
    // };

    // struct xdp_umem_ring {
    //     __u32 *producer;
    //     __u32 *consumer;
    //     __u64 *desc;
    // };

    // typedef struct xdp_rxtx_ring RING;
    // typedef struct xdp_umem_ring RING;

    // typedef struct xdp_desc RING_TYPE;
    // typedef __u64 RING_TYPE;

    int dequeue_one(RING *ring, RING_TYPE *item)
    {
        __u32 entries = *ring->producer - *ring->consumer;

        if (entries == 0)
            return -1;

        // read-barrier!

        *item = ring->desc[*ring->consumer & (RING_SIZE - 1)];
        (*ring->consumer)++;
        return 0;
    }

    int enqueue_one(RING *ring, const RING_TYPE *item)
    {
        u32 free_entries = RING_SIZE - (*ring->producer - *ring->consumer);

        if (free_entries == 0)
            return -1;

        ring->desc[*ring->producer & (RING_SIZE - 1)] = *item;

        // write-barrier!

        (*ring->producer)++;
        return 0;
    }

Nhưng vui lòng sử dụng các hàm libbpf vì chúng được tối ưu hóa và sẵn sàng
sử dụng. Sẽ làm cho cuộc sống của bạn dễ dàng hơn.

Cách sử dụng Multi-Buffer Rx
---------------------

Đây là một ví dụ mã giả đường dẫn Rx đơn giản (sử dụng giao diện libxdp
để đơn giản). Đường dẫn lỗi đã được loại trừ để giữ cho nó ngắn gọn:

.. code-block:: c

    void rx_packets(struct xsk_socket_info *xsk)
    {
        static bool new_packet = true;
        u32 idx_rx = 0, idx_fq = 0;
        static char *pkt;

        int rcvd = xsk_ring_cons__peek(&xsk->rx, opt_batch_size, &idx_rx);

        xsk_ring_prod__reserve(&xsk->umem->fq, rcvd, &idx_fq);

        for (int i = 0; i < rcvd; i++) {
            struct xdp_desc *desc = xsk_ring_cons__rx_desc(&xsk->rx, idx_rx++);
            char *frag = xsk_umem__get_data(xsk->umem->buffer, desc->addr);
            bool eop = !(desc->options & XDP_PKT_CONTD);

            if (new_packet)
                pkt = frag;
            else
                add_frag_to_pkt(pkt, frag);

            if (eop)
                process_pkt(pkt);

            new_packet = eop;

            *xsk_ring_prod__fill_addr(&xsk->umem->fq, idx_fq++) = desc->addr;
        }

        xsk_ring_prod__submit(&xsk->umem->fq, rcvd);
        xsk_ring_cons__release(&xsk->rx, rcvd);
    }

Cách sử dụng Multi-Buffer Tx
---------------------

Dưới đây là một ví dụ về mã giả đường dẫn Tx (sử dụng giao diện libxdp cho
đơn giản) bỏ qua rằng umem có kích thước hữu hạn và chúng ta
cuối cùng sẽ hết gói để gửi. Cũng giả sử pkts.addr
trỏ đến một vị trí hợp lệ trong umem.

.. code-block:: c

    void tx_packets(struct xsk_socket_info *xsk, struct pkt *pkts,
                    int batch_size)
    {
        u32 idx, i, pkt_nb = 0;

        xsk_ring_prod__reserve(&xsk->tx, batch_size, &idx);

        for (i = 0; i < batch_size;) {
            u64 addr = pkts[pkt_nb].addr;
            u32 len = pkts[pkt_nb].size;

            do {
                struct xdp_desc *tx_desc;

                tx_desc = xsk_ring_prod__tx_desc(&xsk->tx, idx + i++);
                tx_desc->addr = addr;

                if (len > xsk_frame_size) {
                    tx_desc->len = xsk_frame_size;
                    tx_desc->options = XDP_PKT_CONTD;
                } else {
                    tx_desc->len = len;
                    tx_desc->options = 0;
                    pkt_nb++;
                }
                len -= tx_desc->len;
                addr += xsk_frame_size;

                if (i == batch_size) {
                    /* Remember len, addr, pkt_nb for next iteration.
                     * Skipped for simplicity.
                     */
                    break;
                }
            } while (len);
        }

        xsk_ring_prod__submit(&xsk->tx, i);
    }

Thăm dò hỗ trợ nhiều bộ đệm
--------------------------------

Để khám phá xem trình điều khiển có hỗ trợ nhiều bộ đệm AF_XDP trong SKB hay DRV
chế độ, hãy sử dụng tính năng XDP_FEATURES của netlink trong linux/netdev.h để
truy vấn hỗ trợ NETDEV_XDP_ACT_RX_SG. Đây là lá cờ tương tự như đối với
truy vấn hỗ trợ đa bộ đệm XDP. Nếu XDP hỗ trợ nhiều bộ đệm trong
một trình điều khiển thì AF_XDP cũng sẽ hỗ trợ trình điều khiển đó ở chế độ SKB và DRV.

Để khám phá xem trình điều khiển có hỗ trợ nhiều bộ đệm AF_XDP ở chế độ không sao chép hay không
chế độ, hãy sử dụng XDP_FEATURES và trước tiên hãy kiểm tra NETDEV_XDP_ACT_XSK_ZEROCOPY
cờ. Nếu nó được đặt, điều đó có nghĩa là ít nhất không có bản sao nào được hỗ trợ và
bạn nên đi kiểm tra thuộc tính netlink
NETDEV_A_DEV_XDP_ZC_MAX_SEGS trong linux/netdev.h. Số nguyên không dấu
giá trị sẽ được trả về cho biết số lượng phân đoạn tối đa
được thiết bị này hỗ trợ ở chế độ không sao chép. Đây là những điều có thể
giá trị trả về:

1: Thiết bị này không hỗ trợ nhiều bộ đệm cho tính năng không sao chép, ở mức tối đa
   một đoạn được hỗ trợ có nghĩa là không thể sử dụng nhiều bộ đệm.

>=2: Hỗ trợ nhiều bộ đệm ở chế độ không sao chép cho thiết bị này. các
     số được trả về biểu thị số lượng phân đoạn tối đa được hỗ trợ.

Để biết ví dụ về cách sử dụng chúng thông qua libbpf, vui lòng lấy
hãy xem công cụ/kiểm tra/selftests/bpf/xskxceiver.c.

Hỗ trợ nhiều bộ đệm cho trình điều khiển không sao chép
------------------------------------------

Trình điều khiển không sao chép thường sử dụng API theo đợt cho Rx và Tx
xử lý. Lưu ý rằng lô Tx API đảm bảo rằng nó sẽ cung cấp
một loạt các bộ mô tả Tx kết thúc bằng gói đầy đủ ở cuối. Cái này
để tạo điều kiện mở rộng trình điều khiển không sao chép với sự hỗ trợ đa bộ đệm.

Ứng dụng mẫu
==================
Có thể tìm thấy ứng dụng kiểm tra/đo chuẩn xdpsock tại
ZZ0000ZZ
trình bày cách sử dụng ổ cắm AF_XDP với quyền riêng tư
UMEM. Giả sử bạn muốn lưu lượng UDP của mình từ cổng 4242 kết thúc
ở hàng đợi 16, chúng tôi sẽ bật AF_XDP. Ở đây, chúng tôi sử dụng ethtool
vì điều này::

ethtool -N p3p2 rx-flow-hash udp4 fn
      ethtool -N p3p2 kiểu luồng udp4 src-port 4242 dst-port 4242 \
          hành động 16

Sau đó có thể thực hiện chạy điểm chuẩn rxdrop ở chế độ XDP_DRV
sử dụng::

mẫu/bpf/xdpsock -i p3p2 -q 16 -r -N

Đối với chế độ XDP_SKB, sử dụng công tắc "-S" thay vì "-N" và tất cả các tùy chọn
có thể được hiển thị với "-h", như thường lệ.

Ứng dụng mẫu này sử dụng libbpf để thiết lập và sử dụng
AF_XDP đơn giản hơn. Nếu bạn muốn biết uapi thô của AF_XDP như thế nào
thực sự được sử dụng để tạo ra thứ gì đó cao cấp hơn, hãy xem libbpf
mã trong tools/testing/selftests/bpf/xsk.[ch].

FAQ
=======

Hỏi: Tôi không thấy bất kỳ lưu lượng truy cập nào trên ổ cắm. Tôi đang làm gì sai?

Trả lời: Khi khởi tạo netdev của NIC vật lý, Linux thường
   phân bổ một cặp hàng đợi RX và TX cho mỗi lõi. Vì vậy, trên hệ thống 8 lõi,
   id hàng đợi từ 0 đến 7 sẽ được phân bổ, mỗi id một lõi. Trong AF_XDP
   lệnh gọi liên kết hoặc lệnh gọi hàm xsk_socket__create libbpf, bạn
   chỉ định một id hàng đợi cụ thể để liên kết và đó chỉ là lưu lượng truy cập
   về phía hàng đợi mà bạn sẽ nhận được trên ổ cắm của mình. Vì vậy trong
   ví dụ ở trên, nếu bạn liên kết với hàng đợi 0, bạn NOT sẽ nhận được bất kỳ
   lưu lượng được phân phối đến hàng đợi từ 1 đến 7. Nếu bạn
   may mắn thay, bạn sẽ thấy giao thông, nhưng thường thì nó sẽ kết thúc ở một
   trong số hàng đợi mà bạn không bị ràng buộc.

Có nhiều cách để giải quyết vấn đề lấy
   lưu lượng truy cập bạn muốn đến id hàng đợi mà bạn bị ràng buộc. Nếu bạn muốn xem
   tất cả lưu lượng truy cập, bạn có thể buộc netdev chỉ có 1 hàng đợi, hàng đợi
   id 0, sau đó liên kết với hàng đợi 0. Bạn có thể sử dụng ethtool để thực hiện việc này ::

sudo ethtool -L <giao diện> kết hợp 1

Nếu bạn chỉ muốn xem một phần lưu lượng truy cập, bạn có thể lập trình
   NIC thông qua ethtool để lọc lưu lượng truy cập của bạn đến một id hàng đợi duy nhất
   mà bạn có thể liên kết ổ cắm XDP của mình với. Đây là một ví dụ trong đó
   Lưu lượng UDP đến và đi từ cổng 4242 được gửi đến hàng đợi 2 ::

sudo ethtool -N <giao diện> rx-flow-hash udp4 fn
     sudo ethtool -N <interface> loại luồng udp4 src-port 4242 dst-port \
     4242 hành động 2

Một số cách khác có thể thực hiện được tùy thuộc vào khả năng của
   chiếc NIC mà bạn có.

Câu hỏi: Tôi có thể sử dụng XSKMAP để thực hiện chuyển đổi giữa các umem khác nhau không
   ở chế độ sao chép?

Đáp: Câu trả lời ngắn gọn là không, hiện tại tính năng này không được hỗ trợ. các
   XSKMAP chỉ có thể được sử dụng để chuyển đổi lưu lượng truy cập vào hàng đợi id X
   tới các ổ cắm được liên kết với cùng một hàng đợi id X. XSKMAP có thể chứa
   ổ cắm được liên kết với các id hàng đợi khác nhau, ví dụ X và Y, nhưng chỉ
   lưu lượng truy cập đi vào từ hàng đợi id Y có thể được chuyển hướng đến các ổ cắm bị ràng buộc
   đến cùng id hàng đợi Y. Ở chế độ không sao chép, bạn nên sử dụng
   chuyển đổi hoặc cơ chế phân phối khác trong NIC của bạn để chỉ đạo
   lưu lượng truy cập đến id hàng đợi và ổ cắm chính xác.

Hỏi: Các gói tin của tôi đôi khi bị hỏng. Có chuyện gì vậy?

Đáp: Cần phải cẩn thận để không nạp cùng bộ đệm trong UMEM vào
   nhiều hơn một chiếc chuông cùng một lúc. Ví dụ: nếu bạn cho ăn
   cùng một bộ đệm vào vòng FILL và vòng TX cùng một lúc,
   NIC có thể nhận dữ liệu vào bộ đệm cùng lúc
   gửi nó. Điều này sẽ khiến một số gói bị hỏng. giống nhau
   điều xảy ra khi đưa cùng một bộ đệm vào các vòng FILL
   thuộc các id hàng đợi hoặc netdev khác nhau bị ràng buộc với
   Cờ XDP_SHARED_UMEM.

Tín dụng
=======

- Björn Töpel (lõi AF_XDP)
- Magnus Karlsson (lõi AF_XDP)
- Alexander Duyck
- Alexei Starovoitov
- Daniel Borkmann
- Jesper Dangaard Brouer
- John Fastabend
- Jonathan Corbet (bảo hiểm LWN)
- Michael S. Tsirkin
- Tề Z Trương
- Willem de Bruijn