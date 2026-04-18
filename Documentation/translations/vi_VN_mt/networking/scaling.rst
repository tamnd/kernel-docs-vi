.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/scaling.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Mở rộng quy mô trong ngăn xếp mạng Linux
========================================


Giới thiệu
============

Tài liệu này mô tả một tập hợp các kỹ thuật bổ sung trong Linux
ngăn xếp mạng để tăng tính song song và cải thiện hiệu suất cho
hệ thống đa bộ xử lý.

Các công nghệ sau đây được mô tả:

- RSS: Nhận tỷ lệ bên
- RPS: Nhận chỉ đạo gói
- RFS: Nhận chỉ đạo luồng
- Điều khiển luồng nhận tăng tốc
- XPS: Chỉ đạo gói truyền


RSS: Nhận tỷ lệ bên
=========================

NIC hiện đại hỗ trợ nhiều hàng đợi mô tả nhận và truyền
(nhiều hàng đợi). Khi tiếp nhận, NIC có thể gửi các gói khác nhau đến các
hàng đợi để phân phối việc xử lý giữa các CPU. NIC phân phối các gói bằng cách
áp dụng bộ lọc cho mỗi gói gán nó cho một trong số ít
của các luồng logic. Các gói cho mỗi luồng được chuyển đến một nơi nhận riêng biệt
hàng đợi, do đó có thể được xử lý bởi các CPU riêng biệt. Cơ chế này là
thường được gọi là “Chia tỷ lệ bên nhận” (RSS). Mục tiêu của RSS và
các kỹ thuật mở rộng quy mô khác là để tăng hiệu suất một cách đồng đều.
Phân phối nhiều hàng đợi cũng có thể được sử dụng để ưu tiên lưu lượng truy cập, nhưng
đó không phải là trọng tâm của những kỹ thuật này.

Bộ lọc được sử dụng trong RSS thường là hàm băm qua mạng
và/hoặc các tiêu đề của lớp vận chuyển-- ví dụ: hàm băm 4 bộ trên
Địa chỉ IP và cổng TCP của gói. Phần cứng phổ biến nhất
việc triển khai RSS sử dụng bảng hướng dẫn trong đó mỗi mục nhập
lưu trữ một số hàng đợi. Hàng đợi nhận cho một gói được xác định
bằng cách lập chỉ mục cho bảng hướng dẫn với các bit bậc thấp của
hàm băm được tính toán cho gói (thường là hàm băm Toeplitz).

Bảng định hướng giúp phân bố đều lưu lượng khi xếp hàng
số đếm không phải là lũy thừa của hai. NIC nên cung cấp bảng hướng dẫn
lớn hơn ít nhất 4 lần so với số lượng hàng đợi. Bảng 4x cho kết quả ~16%
mất cân bằng giữa các hàng đợi, điều này có thể chấp nhận được đối với hầu hết các ứng dụng.

Một số NIC hỗ trợ băm RSS đối xứng trong đó, nếu IP (địa chỉ nguồn,
địa chỉ đích) và các bộ dữ liệu TCP/UDP (cổng nguồn, cổng đích)
được hoán đổi, hàm băm được tính toán là như nhau. Điều này có lợi ở một số
các ứng dụng giám sát luồng TCP/IP (IDS, tường lửa, ... vv) và cần
cả hai hướng của luồng đều đến trên cùng một hàng đợi Rx (và CPU). các
"Symmetric-XOR" và "Symmetric-OR-XOR" là các loại thuật toán RSS
đạt được tính đối xứng băm này bằng XOR/ORing nguồn đầu vào và đích
các trường của giao thức IP và/hoặc L4. Tuy nhiên, điều này dẫn đến giảm
entropy đầu vào và có thể được khai thác.

Cụ thể, thuật toán "Symmetric-XOR" XOR đầu vào
như sau::

# (SRC_IP ^ DST_IP, SRC_IP ^ DST_IP, SRC_PORT ^ DST_PORT, SRC_PORT ^ DST_PORT)

Mặt khác, thuật toán "Symmetric-OR-XOR" biến đổi đầu vào thành
sau::

# (SRC_IP ZZ0000ZZ DST_PORT, SRC_PORT ^ DST_PORT)

Kết quả sau đó được đưa vào thuật toán RSS cơ bản.

Một số NIC nâng cao cho phép các gói điều khiển được xếp hàng dựa trên
bộ lọc lập trình được. Ví dụ: máy chủ web giới hạn cổng TCP 80 gói
có thể được chuyển đến hàng đợi nhận của riêng họ. Những bộ lọc “n-tuple” như vậy có thể
được cấu hình từ ethtool (--config-ntuple).


Cấu hình RSS
-----------------

Trình điều khiển cho NIC có khả năng đa hàng đợi thường cung cấp kernel
tham số mô-đun để chỉ định số lượng hàng đợi phần cứng cần
cấu hình. Ví dụ: trong trình điều khiển bnx2x, tham số này được gọi
num_queues. Cấu hình RSS điển hình sẽ có một hàng đợi nhận
cho mỗi CPU nếu thiết bị hỗ trợ đủ hàng đợi hoặc ít nhất
một cho mỗi miền bộ nhớ, trong đó miền bộ nhớ là một tập hợp các CPU
chia sẻ một mức bộ nhớ cụ thể (nút L1, L2, NUMA, v.v.).

Bảng gián tiếp của thiết bị RSS, giải quyết hàng đợi bằng mặt nạ
hàm băm, thường được trình điều khiển lập trình khi khởi tạo. các
ánh xạ mặc định là phân phối đồng đều các hàng đợi trong bảng, nhưng
bảng gián tiếp có thể được truy xuất và sửa đổi trong thời gian chạy bằng ethtool
các lệnh (--show-rxfh-indir và --set-rxfh-indir). Sửa đổi
bảng hướng dẫn có thể được thực hiện để cung cấp cho các hàng đợi khác nhau những cách khác nhau
trọng số tương đối.


Cấu hình RSS IRQ
~~~~~~~~~~~~~~~~~~~~~

Mỗi hàng đợi nhận có một IRQ riêng được liên kết với nó. Trình kích hoạt NIC
điều này để thông báo cho CPU khi các gói mới đến hàng đợi nhất định. các
đường dẫn tín hiệu cho các thiết bị PCIe sử dụng các ngắt được báo hiệu bằng tin nhắn (MSI-X),
có thể định tuyến từng ngắt tới một CPU cụ thể. Bản đồ hoạt động
số hàng đợi đến IRQ có thể được xác định từ /proc/interrupts. Theo mặc định,
IRQ có thể được xử lý trên bất kỳ CPU nào. Bởi vì một phần không thể bỏ qua của gói
quá trình xử lý diễn ra trong quá trình xử lý ngắt nhận, điều đó là thuận lợi
để truyền bá các ngắt nhận giữa các CPU. Để điều chỉnh thủ công IRQ
mối quan hệ của từng ngắt, xem Tài liệu/core-api/irq/irq-affinity.rst. Một số hệ thống
sẽ chạy Irqbalance, một daemon tối ưu hóa IRQ một cách linh hoạt
các bài tập và do đó có thể ghi đè mọi cài đặt thủ công.


Cấu hình đề xuất
~~~~~~~~~~~~~~~~~~~~~~~

RSS phải được bật khi độ trễ là vấn đề đáng lo ngại hoặc bất cứ khi nào nhận được
xử lý ngắt tạo thành một nút cổ chai. Phân tán tải giữa các CPU
giảm chiều dài hàng đợi. Đối với mạng có độ trễ thấp, cài đặt tối ưu
là phân bổ số lượng hàng đợi bằng số CPU trong hệ thống (hoặc
NIC tối đa, nếu thấp hơn). Cấu hình tốc độ cao hiệu quả nhất
có thể là hàng có số lượng hàng đợi nhận nhỏ nhất mà không có
nhận được tình trạng tràn hàng đợi do CPU bão hòa, vì theo mặc định
chế độ có bật tính năng kết hợp ngắt, tổng số
các ngắt (và do đó hoạt động) tăng lên theo mỗi hàng đợi bổ sung.

Tải trên mỗi CPU có thể được quan sát bằng tiện ích mpstat, nhưng lưu ý rằng trên
bộ xử lý có siêu phân luồng (HT), mỗi siêu phân luồng được biểu diễn dưới dạng
một CPU riêng biệt. Để xử lý ngắt, HT không mang lại lợi ích gì trong
các thử nghiệm ban đầu, do đó hãy giới hạn số lượng hàng đợi ở số lõi CPU
trong hệ thống.

Bối cảnh RSS chuyên dụng
~~~~~~~~~~~~~~~~~~~~~~

Các NIC hiện đại hỗ trợ tạo nhiều cấu hình RSS cùng tồn tại
được lựa chọn dựa trên các quy tắc kết hợp rõ ràng. Điều này có thể rất
hữu ích khi ứng dụng muốn hạn chế tập hợp hàng đợi nhận
giao thông chẳng hạn một cổng đích hoặc địa chỉ IP cụ thể.
Ví dụ bên dưới cho thấy cách chuyển hướng tất cả lưu lượng truy cập đến cổng TCP 22
đến hàng đợi 0 và 1.

Để tạo bối cảnh RSS bổ sung, hãy sử dụng ::

# ethtool -X eth0 hfunc toeplitz bối cảnh mới
  Bối cảnh RSS mới là 1

Kernel báo cáo lại ID của bối cảnh được phân bổ (mặc định, luôn
bối cảnh RSS hiện tại có ID là 0). Bối cảnh mới có thể được truy vấn và
được sửa đổi bằng cách sử dụng các API giống như bối cảnh mặc định::

# ethtool -x eth0 bối cảnh 1
  Bảng hướng dẫn băm luồng RX cho eth0 với 13 vòng RX:
    0: 0 1 2 3 4 5 6 7
    8: 8 9 10 11 12 0 1 2
  […]
  # ethtool -X eth0 bằng 2 bối cảnh 1
  # ethtool -x eth0 bối cảnh 1
  Bảng hướng dẫn băm luồng RX cho eth0 với 13 vòng RX:
    0: 0 1 0 1 0 1 0 1
    8: 0 1 0 1 0 1 0 1
  […]

Để sử dụng ngữ cảnh mới, hãy hướng lưu lượng truy cập tới ngữ cảnh đó bằng cách sử dụng n-Tuple
bộ lọc::

# ethtool -N eth0 loại luồng tcp6 dst-port 22 ngữ cảnh 1
  Đã thêm quy tắc với ID 1023

Khi hoàn tất, hãy xóa bối cảnh và quy tắc::

# ethtool -N eth0 xóa 1023
  # ethtool -X eth0 bối cảnh 1 xóa


RPS: Nhận chỉ đạo gói
============================

Nhận chỉ đạo gói (RPS) về mặt logic là một phần mềm triển khai
RSS. Ở trong phần mềm, nó nhất thiết phải được gọi sau trong đường dẫn dữ liệu.
Trong khi đó RSS chọn hàng đợi và do đó CPU sẽ chạy phần cứng
trình xử lý ngắt, RPS chọn CPU để thực hiện xử lý giao thức
phía trên bộ xử lý ngắt. Điều này được thực hiện bằng cách đặt gói
trên hàng đợi tồn đọng của CPU mong muốn và đánh thức CPU để xử lý.
RPS có một số ưu điểm so với RSS:

1) nó có thể được sử dụng với bất kỳ NIC nào
2) các bộ lọc phần mềm có thể dễ dàng được thêm vào hàm băm qua các giao thức mới
3) nó không làm tăng tốc độ gián đoạn thiết bị phần cứng (mặc dù nó làm
   giới thiệu các ngắt liên bộ xử lý (IPI))

RPS được gọi trong nửa dưới của trình xử lý ngắt nhận, khi
trình điều khiển gửi gói lên ngăn xếp mạng bằng netif_rx() hoặc
netif_receive_skb(). Chúng gọi hàm get_rps_cpu(),
chọn hàng đợi sẽ xử lý một gói.

Bước đầu tiên trong việc xác định CPU mục tiêu cho RPS là tính toán
hàm băm luồng qua các địa chỉ hoặc cổng của gói (băm 2 bộ hoặc 4 bộ
tùy thuộc vào giao thức). Điều này phục vụ như một hàm băm nhất quán của
luồng liên quan của gói. Hàm băm được cung cấp bởi phần cứng
hoặc sẽ được tính toán trong ngăn xếp. Phần cứng có khả năng có thể chuyển hàm băm vào
bộ mô tả nhận cho gói; điều này thường sẽ giống nhau
hàm băm được sử dụng cho RSS (ví dụ: hàm băm Toeplitz được tính toán). Hàm băm được lưu trong
skb->hash và có thể được sử dụng ở nơi khác trong ngăn xếp dưới dạng hàm băm của
luồng của gói.

Mỗi hàng đợi phần cứng nhận có một danh sách CPU liên quan
RPS có thể xếp các gói vào hàng đợi để xử lý. Đối với mỗi gói nhận được,
một chỉ mục trong danh sách được tính toán từ modulo băm luồng theo kích thước
của danh sách. CPU được lập chỉ mục là mục tiêu để xử lý gói,
và gói được xếp ở cuối hàng đợi tồn đọng của CPU đó. Tại
khi kết thúc quy trình nửa dưới, IPI được gửi tới bất kỳ CPU nào có
các gói đã được xếp vào hàng đợi tồn đọng của chúng. IPI đánh thức tồn đọng
xử lý trên CPU từ xa và mọi gói được xếp hàng đợi sau đó sẽ được xử lý
lên ngăn xếp mạng.


Cấu hình RPS
-----------------

RPS yêu cầu kernel được biên dịch bằng ký hiệu kconfig CONFIG_RPS (trên
theo mặc định cho SMP). Ngay cả khi được biên dịch vào, RPS vẫn bị tắt cho đến khi
được cấu hình rõ ràng. Danh sách các CPU mà RPS có thể chuyển tiếp lưu lượng truy cập
có thể được cấu hình cho mỗi hàng đợi nhận bằng cách sử dụng mục nhập tệp sysfs ::

/sys/class/net/<dev>/queues/rx-<n>/rps_cpus

Tệp này thực hiện một bitmap của CPU. RPS bị vô hiệu hóa khi nó bằng 0
(mặc định), trong trường hợp đó các gói được xử lý trên thiết bị bị gián đoạn
CPU. Documentation/core-api/irq/irq-affinity.rst giải thích cách gán CPU cho
bản đồ bit.


Cấu hình đề xuất
~~~~~~~~~~~~~~~~~~~~~~~

Đối với một thiết bị xếp hàng đơn, cấu hình RPS điển hình sẽ được đặt
rps_cpus tới các CPU trong cùng miền bộ nhớ bị gián đoạn
CPU. Nếu vị trí NUMA không phải là vấn đề thì đây cũng có thể là tất cả các CPU trong
hệ thống. Ở tốc độ ngắt cao, có thể là khôn ngoan nếu loại trừ
làm gián đoạn CPU khỏi bản đồ vì điều đó đã thực hiện được nhiều việc.

Đối với hệ thống nhiều hàng đợi, nếu RSS được cấu hình sao cho phần cứng
hàng đợi nhận được ánh xạ tới từng CPU, thì RPS có thể là dư thừa
và không cần thiết. Nếu có ít hàng đợi phần cứng hơn CPU thì
RPS có thể có ích nếu rps_cpus cho mỗi hàng đợi là những thứ
chia sẻ cùng miền bộ nhớ với CPU bị gián đoạn cho hàng đợi đó.


Giới hạn lưu lượng RPS
--------------

RPS chia tỷ lệ kernel nhận xử lý trên các CPU mà không cần giới thiệu
sắp xếp lại. Sự đánh đổi để gửi tất cả các gói từ cùng một luồng
đối với cùng một CPU là mất cân bằng tải CPU nếu các luồng có tốc độ gói khác nhau.
Trong trường hợp cực đoan, một luồng duy nhất sẽ thống trị lưu lượng. Đặc biệt là trên
khối lượng công việc máy chủ phổ biến với nhiều kết nối đồng thời, chẳng hạn như
hành vi chỉ ra một vấn đề chẳng hạn như cấu hình sai hoặc giả mạo
nguồn tấn công từ chối dịch vụ.

Giới hạn luồng là tính năng RPS tùy chọn ưu tiên các luồng nhỏ
trong quá trình tranh chấp CPU bằng cách loại bỏ nhẹ các gói từ các luồng lớn
trước những dòng chảy nhỏ. Nó chỉ hoạt động khi có RPS hoặc RFS
đích CPU tiến tới bão hòa.  Khi gói đầu vào của CPU
hàng đợi vượt quá một nửa độ dài hàng đợi tối đa (như được đặt bởi sysctl
net.core.netdev_max_backlog), kernel khởi động gói trên mỗi luồng
đếm trên 256 gói cuối cùng. Nếu lưu lượng vượt quá tỷ lệ đã đặt (bằng
mặc định, một nửa) trong số các gói này khi có gói mới đến, thì
gói mới bị loại bỏ. Các gói từ các luồng khác vẫn chỉ
bị loại bỏ khi hàng đợi gói đầu vào đạt tới netdev_max_backlog.
Không có gói nào bị loại bỏ khi độ dài hàng đợi gói đầu vào thấp hơn
ngưỡng, do đó giới hạn luồng không cắt đứt hoàn toàn các kết nối:
ngay cả các luồng lớn cũng duy trì kết nối.


Giao diện
~~~~~~~~~

Giới hạn luồng được biên dịch theo mặc định (CONFIG_NET_FLOW_LIMIT), nhưng không
đã bật. Nó được triển khai độc lập cho từng CPU (để tránh khóa
và xung đột bộ đệm) và được bật/tắt trên mỗi CPU bằng cách đặt bit liên quan
trong sysctl net.core.flow_limit_cpu_bitmap. Nó hiển thị CPU tương tự
giao diện bitmap dưới dạng rps_cpus (xem bên trên) khi được gọi từ Procfs::

/proc/sys/net/core/flow_limit_cpu_bitmap

Tốc độ trên mỗi luồng được tính bằng cách băm từng gói vào một bảng băm
xô và tăng bộ đếm trên mỗi nhóm. Hàm băm là
tương tự như việc chọn CPU trong RPS, nhưng số lượng nhóm có thể
lớn hơn nhiều so với số lượng CPU, giới hạn luồng được xử lý chi tiết hơn
xác định các dòng chảy lớn và ít kết quả dương tính giả hơn. Mặc định
bảng có 4096 thùng. Giá trị này có thể được sửa đổi thông qua sysctl::

net.core.flow_limit_table_len

Giá trị chỉ được tham khảo khi một bảng mới được phân bổ. sửa đổi
nó không cập nhật các bảng hoạt động.


Cấu hình đề xuất
~~~~~~~~~~~~~~~~~~~~~~~

Giới hạn luồng rất hữu ích trên các hệ thống có nhiều kết nối đồng thời,
trong đó một kết nối chiếm 50% CPU cho thấy có sự cố.
Trong những môi trường như vậy, hãy bật tính năng này trên tất cả các CPU xử lý
ngắt mạng rx (như được đặt trong /proc/irq/N/smp_affinity).

Tính năng này phụ thuộc vào độ dài hàng đợi gói đầu vào vượt quá
ngưỡng giới hạn luồng (50%) + độ dài lịch sử luồng (256).
Đặt net.core.netdev_max_backlog thành 1000 hoặc 10000
thực hiện tốt các thí nghiệm.


RFS: Nhận chỉ đạo luồng
==========================

Trong khi RPS điều khiển các gói chỉ dựa trên hàm băm và do đó nói chung
cung cấp khả năng phân phối tải tốt, nó không tính đến
địa phương ứng dụng. Điều này được thực hiện bằng cách nhận chỉ đạo luồng
(RFS). Mục tiêu của RFS là tăng tốc độ truy cập bộ đệm dữ liệu bằng cách điều khiển
xử lý kernel của các gói tới CPU nơi luồng ứng dụng
tiêu thụ gói đang chạy. RFS dựa trên cơ chế RPS tương tự
để xếp các gói vào hàng tồn đọng của một CPU khác và đánh thức nó
CPU.

Trong RFS, các gói không được chuyển tiếp trực tiếp theo giá trị băm của chúng,
nhưng hàm băm được sử dụng làm chỉ mục cho bảng tra cứu luồng. Bản đồ bảng này
chảy đến CPU nơi các luồng đó đang được xử lý. Hàm băm dòng chảy
(xem phần RPS ở trên) được dùng để tính chỉ số vào bảng này.
CPU được ghi trong mỗi mục nhập là mục xử lý luồng cuối cùng.
Nếu một mục không chứa CPU hợp lệ thì các gói được ánh xạ tới mục đó
được điều khiển bằng RPS đơn giản. Nhiều mục trong bảng có thể trỏ đến
cùng CPU. Thật vậy, với nhiều luồng và ít CPU, rất có thể
một luồng ứng dụng duy nhất xử lý các luồng với nhiều hàm băm luồng khác nhau.

rps_sock_flow_table là bảng luồng toàn cầu chứa ZZ0000ZZ CPU
đối với các luồng: CPU hiện đang xử lý luồng trong không gian người dùng.
Mỗi giá trị bảng là một chỉ mục CPU được cập nhật trong khi gọi tới recvmsg
và sendmsg (cụ thể là inet_recvmsg(), inet_sendmsg() và
tcp_splice_read()).

Khi bộ lập lịch di chuyển một luồng sang CPU mới trong khi nó có lỗi chưa xử lý
nhận các gói trên CPU cũ, các gói có thể đến không đúng thứ tự. Đến
tránh điều này, RFS sử dụng bảng luồng thứ hai để theo dõi các gói chưa xử lý
đối với mỗi luồng: rps_dev_flow_table là một bảng dành riêng cho từng phần cứng
nhận hàng đợi của từng thiết bị. Mỗi giá trị bảng lưu trữ một chỉ mục CPU và một
quầy. Chỉ số CPU đại diện cho ZZ0000ZZ CPU trên gói nào
đối với luồng này được xếp vào hàng đợi để xử lý kernel tiếp theo. Lý tưởng nhất là hạt nhân
và quá trình xử lý không gian người dùng diễn ra trên cùng một CPU và do đó có chỉ mục CPU
trong cả hai bảng là giống hệt nhau. Điều này có thể sai nếu bộ lập lịch có
gần đây đã di chuyển một luồng không gian người dùng trong khi kernel vẫn còn các gói
được xếp hàng để xử lý kernel trên CPU cũ.

Bộ đếm trong các giá trị rps_dev_flow_table ghi lại độ dài của dòng điện
Sự tồn đọng của CPU khi một gói trong luồng này được đưa vào hàng đợi lần cuối. Mỗi hồ sơ tồn đọng
hàng đợi có bộ đếm đầu được tăng lên trên dequeue. Máy đếm đuôi
được tính bằng bộ đếm đầu + chiều dài hàng đợi. Nói cách khác, bộ đếm
trong rps_dev_flow[i] ghi lại phần tử cuối cùng trong luồng i có
đã được xếp vào hàng đợi CPU hiện được chỉ định cho luồng i (tất nhiên,
mục i thực sự được chọn bởi hàm băm và nhiều luồng có thể băm vào
cùng một mục i).

Và bây giờ là mẹo để tránh các gói không đúng thứ tự: khi chọn
CPU để xử lý gói (từ get_rps_cpu()) bảng rps_sock_flow
và bảng rps_dev_flow của hàng đợi nơi gói tin được nhận
được so sánh. Nếu CPU mong muốn cho luồng (được tìm thấy trong
bảng rps_sock_flow) khớp với CPU hiện tại (được tìm thấy trong rps_dev_flow
table), gói được đưa vào danh sách tồn đọng của CPU đó. Nếu chúng khác nhau,
CPU hiện tại được cập nhật để phù hợp với CPU mong muốn nếu một trong
sau đây là đúng:

- Bộ đếm đầu hàng đợi của CPU hiện tại >= bộ đếm đuôi được ghi
    giá trị trong rps_dev_flow[i]
  - CPU hiện tại chưa được đặt (>= nr_cpu_ids)
  - CPU hiện tại đang ngoại tuyến

Sau lần kiểm tra này, gói được gửi đến địa chỉ hiện tại (có thể được cập nhật).
CPU. Các quy tắc này nhằm đảm bảo rằng luồng chỉ chuyển sang CPU mới khi
không có gói nào còn sót lại trên CPU cũ, vì gói còn thiếu
các gói có thể đến muộn hơn các gói sắp được xử lý trên mạng mới
CPU.


Cấu hình RFS
-----------------

RFS chỉ khả dụng nếu biểu tượng kconfig CONFIG_RPS được bật (bật
theo mặc định cho SMP). Chức năng vẫn bị vô hiệu hóa cho đến khi rõ ràng
được cấu hình. Số lượng mục trong bảng luồng toàn cầu được đặt thông qua::

/proc/sys/net/core/rps_sock_flow_entries

Số lượng mục trong bảng luồng trên mỗi hàng đợi được đặt thông qua::

/sys/class/net/<dev>/queues/rx-<n>/rps_flow_cnt


Cấu hình đề xuất
~~~~~~~~~~~~~~~~~~~~~~~

Cả hai điều này cần phải được đặt trước khi RFS được bật cho hàng đợi nhận.
Giá trị của cả hai đều được làm tròn đến lũy thừa gần nhất của hai. các
số lượng luồng được đề xuất phụ thuộc vào số lượng kết nối hoạt động dự kiến
tại bất kỳ thời điểm nào, có thể ít hơn đáng kể so với số lần mở
kết nối. Chúng tôi nhận thấy rằng giá trị 65536 cho rps_sock_flow_entries
hoạt động khá tốt trên một máy chủ được tải vừa phải. Các máy chủ lớn có thể
cần giá trị 1048576 hoặc thậm chí cao hơn.

Trên máy chủ NUMA, nên phổ biến rps_sock_flow_entries trên tất cả các nút.

numactl --interleave=all bash -c "echo 1048576 >/proc/sys/net/core/rps_sock_flow_entries"

Đối với một thiết bị xếp hàng đơn, giá trị rps_flow_cnt cho một hàng đợi
thường sẽ được cấu hình có cùng giá trị với rps_sock_flow_entries.
Đối với thiết bị nhiều hàng đợi, rps_flow_cnt cho mỗi hàng đợi có thể là
được định cấu hình là rps_sock_flow_entries / N, trong đó N là số lượng
hàng đợi. Vì vậy, ví dụ: nếu rps_sock_flow_entries được đặt thành 131072 và ở đó
có 16 hàng đợi nhận được định cấu hình, rps_flow_cnt cho mỗi hàng đợi có thể là
được cấu hình là 8192.


Tăng tốc RFS
===============

RFS được tăng tốc là RFS RSS là RPS: tải được tăng tốc phần cứng
cơ chế cân bằng sử dụng trạng thái mềm để điều khiển các luồng dựa trên vị trí
luồng ứng dụng tiêu thụ các gói của mỗi luồng đang chạy.
RFS được tăng tốc sẽ hoạt động tốt hơn RFS vì các gói được gửi
trực tiếp đến CPU cục bộ trong luồng tiêu thụ dữ liệu. Mục tiêu CPU
sẽ giống CPU nơi ứng dụng chạy hoặc ít nhất là CPU
là cục bộ của CPU của luồng ứng dụng trong hệ thống phân cấp bộ đệm.

Để kích hoạt RFS được tăng tốc, ngăn xếp mạng gọi
Chức năng trình điều khiển ndo_rx_flow_steer để giao tiếp với phần cứng mong muốn
hàng đợi các gói phù hợp với một luồng cụ thể. Ngăn xếp mạng
tự động gọi chức năng này mỗi khi có một luồng vào
rps_dev_flow_table đã được cập nhật. Người lái xe lần lượt sử dụng một thiết bị cụ thể
phương pháp lập trình NIC để điều khiển các gói.

Hàng đợi phần cứng cho một luồng được lấy từ CPU được ghi trong
rps_dev_flow_table. Ngăn xếp tham khảo bản đồ hàng đợi phần cứng CPU
được duy trì bởi trình điều khiển NIC. Đây là bản đồ đảo ngược được tạo tự động của
bảng ái lực IRQ được hiển thị bởi /proc/interrupts. Trình điều khiển có thể sử dụng
các chức năng trong thư viện hạt nhân cpu_rmap (“Bản đồ đảo ngược mối quan hệ CPU”)
để điền vào bản đồ. Ngoài ra, trình điều khiển có thể ủy quyền cpu_rmap
quản lý Kernel bằng cách gọi netif_enable_cpu_rmap(). Đối với mỗi CPU,
hàng đợi tương ứng trong bản đồ được đặt thành hàng đợi xử lý CPU
gần nhất trong vùng nhớ đệm.


Cấu hình RFS được tăng tốc
-----------------------------

RFS được tăng tốc chỉ khả dụng nếu kernel được biên dịch bằng
CONFIG_RFS_ACCEL và hỗ trợ được cung cấp bởi trình điều khiển và thiết bị NIC.
Nó cũng yêu cầu bật tính năng lọc ntuple thông qua ethtool. Bản đồ
của CPU vào hàng đợi được tự động suy ra từ mối quan hệ IRQ
được cấu hình cho mỗi hàng đợi nhận bởi trình điều khiển, do đó không cần thêm
cấu hình cần thiết.


Cấu hình đề xuất
~~~~~~~~~~~~~~~~~~~~~~~

Kỹ thuật này nên được kích hoạt bất cứ khi nào người ta muốn sử dụng RFS và
NIC hỗ trợ tăng tốc phần cứng.


XPS: Chỉ đạo gói truyền
=============================

Điều khiển gói truyền là một cơ chế để lựa chọn một cách thông minh
hàng đợi truyền tải nào sẽ được sử dụng khi truyền gói tin trên nhiều hàng đợi
thiết bị. Điều này có thể được thực hiện bằng cách ghi lại hai loại bản đồ, hoặc
ánh xạ CPU tới (các) hàng đợi phần cứng hoặc ánh xạ (các) hàng đợi nhận
tới (các) hàng đợi truyền phần cứng.

1. XPS sử dụng bản đồ CPU

Mục tiêu của việc ánh xạ này thường là gán các hàng đợi
dành riêng cho một tập hợp con CPU, trong đó quá trình truyền hoàn tất cho
các hàng đợi này được xử lý trên CPU trong bộ này. Sự lựa chọn này
mang lại hai lợi ích. Đầu tiên, tranh chấp về khóa hàng đợi thiết bị là
giảm đáng kể do có ít CPU tranh giành cùng một hàng đợi hơn
(tranh chấp có thể được loại bỏ hoàn toàn nếu mỗi CPU có riêng
hàng đợi truyền). Thứ hai, tỷ lệ lỗi bộ đệm khi hoàn thành truyền tải là
giảm, đặc biệt đối với các dòng bộ đệm dữ liệu chứa sk_buff
các cấu trúc.

2. XPS sử dụng bản đồ hàng đợi nhận

Ánh xạ này được sử dụng để chọn hàng đợi truyền dựa trên nhận
cấu hình bản đồ hàng đợi do quản trị viên đặt. Một bộ nhận
hàng đợi có thể được ánh xạ tới một tập hợp hàng đợi truyền (nhiều: nhiều), mặc dù
trường hợp sử dụng phổ biến là ánh xạ 1: 1. Điều này sẽ cho phép gửi các gói
trên cùng một liên kết hàng đợi để truyền và nhận. Điều này hữu ích cho
bận rộn thăm dò khối lượng công việc đa luồng nơi có những thách thức trong
liên kết CPU nhất định với một luồng ứng dụng nhất định. ứng dụng
các luồng không được ghim vào CPU và mỗi luồng xử lý các gói
nhận được trên một hàng đợi. Số hàng đợi nhận được lưu trữ trong
ổ cắm để kết nối. Trong mô hình này, việc gửi các gói trên cùng một
hàng đợi truyền tương ứng với hàng đợi nhận liên quan có lợi ích
trong việc giữ chi phí cho CPU ở mức thấp. Công việc hoàn thành truyền tải bị khóa vào
cùng một liên kết hàng đợi mà một ứng dụng nhất định đang bỏ phiếu. Cái này
tránh được chi phí kích hoạt ngắt trên một CPU khác. Khi
ứng dụng dọn dẹp các gói trong quá trình thăm dò bận rộn, hoàn thành truyền tải
có thể được xử lý cùng với nó trong cùng ngữ cảnh luồng và do đó dẫn đến
giảm độ trễ.

XPS được định cấu hình cho mỗi hàng đợi truyền bằng cách đặt bitmap của
CPU/hàng đợi nhận có thể sử dụng hàng đợi đó để truyền. Ngược lại
ánh xạ, từ CPU đến hàng đợi truyền hoặc từ hàng đợi nhận đến truyền
hàng đợi, được tính toán và duy trì cho từng thiết bị mạng. Khi nào
truyền gói đầu tiên trong một luồng, hàm get_xps_queue() là
được gọi để chọn hàng đợi. Hàm này sử dụng ID của hàng đợi nhận
cho kết nối ổ cắm để khớp trong hàng đợi nhận-để-truyền
bảng tra cứu. Ngoài ra, chức năng này cũng có thể sử dụng ID của
chạy CPU làm chìa khóa vào bảng tra cứu CPU-to-queue. Nếu
ID khớp với một hàng đợi duy nhất được sử dụng để truyền. Nếu nhiều
hàng đợi khớp nhau, một hàng đợi được chọn bằng cách sử dụng hàm băm luồng để tính chỉ mục
vào bộ. Khi chọn hàng đợi truyền dựa trên (các) hàng đợi nhận
bản đồ, thiết bị truyền không được xác thực đối với thiết bị nhận vì nó
yêu cầu thao tác tra cứu tốn kém trong đường dẫn dữ liệu.

Hàng đợi được chọn để truyền một luồng cụ thể sẽ được lưu trong
cấu trúc ổ cắm tương ứng cho luồng (ví dụ: kết nối TCP).
Hàng đợi truyền này được sử dụng cho các gói tiếp theo được gửi trên luồng tới
ngăn chặn các gói không theo thứ tự (ooo). Sự lựa chọn cũng làm giảm chi phí
gọi get_xps_queues() trên tất cả các gói trong luồng. Để tránh
oo, hàng đợi cho một luồng sau đó chỉ có thể được thay đổi nếu
skb->ooo_okay được đặt cho một gói trong luồng. Cờ này chỉ ra rằng
không có gói nào còn sót lại trong luồng, do đó hàng đợi truyền có thể
thay đổi mà không có nguy cơ tạo ra các gói không đúng thứ tự. các
lớp vận chuyển chịu trách nhiệm thiết lập ooo_okay một cách thích hợp. TCP,
ví dụ: đặt cờ khi tất cả dữ liệu cho kết nối đã được
thừa nhận.

Cấu hình XPS
-----------------

XPS chỉ khả dụng nếu biểu tượng kconfig CONFIG_XPS được bật (bật bởi
mặc định cho SMP). Nếu được biên dịch, nó phụ thuộc vào trình điều khiển hay không, và
làm thế nào, XPS được cấu hình ở thiết bị init. Ánh xạ CPU/hàng đợi nhận
để truyền hàng đợi có thể được kiểm tra và định cấu hình bằng sysfs:

Để lựa chọn dựa trên bản đồ CPU::

/sys/class/net/<dev>/queues/tx-<n>/xps_cpus

Để lựa chọn dựa trên bản đồ hàng đợi nhận::

/sys/class/net/<dev>/queues/tx-<n>/xps_rxqs


Cấu hình đề xuất
~~~~~~~~~~~~~~~~~~~~~~~

Đối với thiết bị mạng có một hàng đợi truyền đơn, cấu hình XPS
không có hiệu lực, vì không có sự lựa chọn trong trường hợp này. Trong nhiều hàng đợi
hệ thống, XPS tốt nhất nên được cấu hình sao cho mỗi CPU ánh xạ vào một hàng đợi.
Nếu có nhiều hàng đợi bằng số CPU trong hệ thống thì mỗi hàng đợi
hàng đợi cũng có thể ánh xạ lên một CPU, tạo ra các cặp độc quyền
không có kinh nghiệm tranh chấp. Nếu có ít hàng đợi hơn CPU thì
CPU tốt nhất để chia sẻ một hàng đợi nhất định có lẽ là những CPU chia sẻ bộ đệm
với CPU xử lý việc hoàn thành truyền tải cho hàng đợi đó
(truyền ngắt).

Để lựa chọn hàng đợi truyền dựa trên (các) hàng đợi nhận, XPS phải
được định cấu hình rõ ràng (các) hàng đợi nhận để ánh xạ (các) hàng đợi truyền. Nếu
cấu hình người dùng cho bản đồ hàng đợi nhận không được áp dụng thì việc truyền
hàng đợi được chọn dựa trên bản đồ CPU.


Giới hạn tốc độ hàng đợi trên mỗi TX
============================

Đây là các cơ chế giới hạn tỷ lệ do CTNH thực hiện, hiện tại
thuộc tính tốc độ tối đa được hỗ trợ bằng cách đặt giá trị Mbps thành::

/sys/class/net/<dev>/queues/tx-<n>/tx_maxrate

Giá trị bằng 0 có nghĩa là bị vô hiệu hóa và đây là giá trị mặc định.


Thông tin thêm
===================
RPS và RFS đã được giới thiệu trong kernel 2.6.35. XPS đã được tích hợp vào
2.6.38. Các bản vá ban đầu được gửi bởi Tom Herbert
(therbert@google.com)

RFS tăng tốc đã được giới thiệu trong 2.6.35. Các bản vá ban đầu đã được
gửi bởi Ben Hutchings (bwh@kernel.org)

tác giả:

- Tom Herbert (therbert@google.com)
- Willem de Bruijn (willemb@google.com)