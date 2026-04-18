.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/dsa/dsa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Kiến trúc
=============

Tài liệu này mô tả hệ thống con ZZ0000ZZ
nguyên tắc thiết kế, những hạn chế, sự tương tác với các hệ thống con khác và cách
phát triển trình điều khiển cho hệ thống con này cũng như TODO dành cho các nhà phát triển quan tâm
trong việc tham gia nỗ lực.

Nguyên tắc thiết kế
===================

Hệ thống con Kiến trúc chuyển mạch phân tán được thiết kế chủ yếu để
hỗ trợ bộ chuyển mạch Marvell Ethernet (MV88E6xxx, hay còn gọi là sản phẩm Link Street
line) bằng Linux, nhưng từ đó cũng đã phát triển để hỗ trợ các nhà cung cấp khác.

Triết lý ban đầu đằng sau thiết kế này là có thể sử dụng các vật liệu chưa được sửa đổi
Các công cụ Linux như bridge, iproute2, ifconfig hoạt động minh bạch cho dù
họ đã định cấu hình/truy vấn thiết bị mạng cổng chuyển đổi hoặc mạng thông thường
thiết bị.

Một bộ chuyển mạch Ethernet thường bao gồm nhiều cổng ở mặt trước và một
hoặc nhiều CPU hoặc cổng quản lý. Hệ thống con DSA hiện dựa trên
sự hiện diện của một cổng quản lý được kết nối với bộ điều khiển Ethernet có khả năng
nhận các khung Ethernet từ switch. Đây là một thiết lập rất phổ biến cho tất cả
các loại thiết bị chuyển mạch Ethernet có trong các sản phẩm dành cho Gia đình và Văn phòng Nhỏ: bộ định tuyến,
cổng, hoặc thậm chí các thiết bị chuyển mạch trên cùng. Bộ điều khiển Ethernet máy chủ này sẽ
sau này được gọi là "ống dẫn" và "cpu" trong thuật ngữ và mã DSA.

Chữ D trong DSA là viết tắt của Distributed, vì hệ thống con đã được thiết kế
với khả năng cấu hình và quản lý các switch xếp chồng lên nhau
sử dụng các liên kết Ethernet ngược dòng và hạ lưu giữa các thiết bị chuyển mạch. Những điều cụ thể này
cổng được gọi là cổng "dsa" trong thuật ngữ và mã DSA. Một bộ sưu tập
nhiều switch được kết nối với nhau được gọi là "cây chuyển mạch".

Đối với mỗi cổng bảng mặt trước, DSA tạo ra các thiết bị mạng chuyên dụng
được sử dụng làm điểm cuối kiểm soát và truyền dữ liệu để mạng Linux sử dụng
ngăn xếp. Các giao diện mạng chuyên dụng này được gọi là mạng "người dùng".
giao diện trong thuật ngữ và mã DSA.

Trường hợp lý tưởng để sử dụng DSA là khi bộ chuyển mạch Ethernet hỗ trợ "thẻ chuyển đổi"
đây là một tính năng phần cứng giúp công tắc chèn một thẻ cụ thể cho mỗi
Khung Ethernet mà nó nhận được đến/từ các cổng cụ thể để giúp quản lý
giao diện tìm ra:

- khung này đến từ cổng nào
- lý do tại sao khung này được chuyển tiếp
- cách gửi lưu lượng truy cập có nguồn gốc CPU đến các cổng cụ thể

Hệ thống con hỗ trợ các bộ chuyển mạch không có khả năng chèn/tước thẻ, nhưng
các tính năng có thể bị hạn chế một chút trong trường hợp đó (tách giao thông phụ thuộc vào
trên ID VLAN dựa trên cổng).

Lưu ý rằng DSA hiện không tạo giao diện mạng cho "cpu" và
cổng "dsa" vì:

- cổng "cpu" là phía đối diện của bộ chuyển mạch Ethernet của phần quản lý
  bộ điều khiển và như vậy sẽ tạo ra sự trùng lặp về tính năng, vì bạn
  sẽ nhận được hai giao diện cho cùng một ống dẫn: ống dẫn netdev và "cpu" netdev

- (các) cổng "dsa" chỉ là ống dẫn giữa hai hoặc nhiều công tắc và như vậy
  cũng không thể thực sự được sử dụng làm giao diện mạng thích hợp, chỉ có
  xuôi dòng hoặc giao diện ngược dòng trên cùng có ý nghĩa với mô hình đó

Lưu ý: trong 15 năm qua, hệ thống con DSA đã sử dụng các thuật ngữ
"chính chủ" (chứ không phải "ống dẫn") và "nô lệ" (chứ không phải "người dùng"). Những điều khoản này
đã bị xóa khỏi cơ sở mã DSA và bị loại bỏ khỏi uAPI.

Chuyển đổi giao thức gắn thẻ
----------------------------

DSA hỗ trợ nhiều giao thức gắn thẻ dành riêng cho nhà cung cấp, một giao thức được xác định bằng phần mềm
giao thức gắn thẻ và chế độ không có thẻ (ZZ0000ZZ).

Định dạng chính xác của giao thức thẻ là dành riêng cho nhà cung cấp, nhưng nói chung, chúng
tất cả đều chứa một cái gì đó:

- xác định cổng Ethernet đến từ/nên được gửi đến
- cung cấp lý do tại sao khung này được chuyển tiếp đến giao diện quản lý

Tất cả các giao thức gắn thẻ đều có trong tệp ZZ0000ZZ và triển khai
các phương pháp của cấu trúc ZZ0001ZZ, được trình bày chi tiết dưới đây.

Các giao thức gắn thẻ thường thuộc một trong ba loại:

1. Tiêu đề khung dành riêng cho bộ chuyển mạch được đặt trước tiêu đề Ethernet,
   chuyển sang phải (từ góc nhìn của khung ống dẫn DSA
   trình phân tích cú pháp) MAC DA, MAC SA, EtherType và toàn bộ tải trọng L2.
2. Tiêu đề khung dành riêng cho switch được đặt trước EtherType, giữ nguyên
   MAC DA và MAC SA được lắp đặt từ góc nhìn của ống dẫn DSA, nhưng
   chuyển tải trọng EtherType và L2 'thực' sang bên phải.
3. Tiêu đề khung dành riêng cho bộ chuyển mạch nằm ở phần cuối của gói,
   giữ tất cả các tiêu đề khung tại chỗ và không thay đổi chế độ xem của gói
   mà bộ phân tích khung của ống dẫn DSA có.

Giao thức gắn thẻ có thể gắn thẻ tất cả các gói bằng thẻ chuyển đổi có cùng độ dài hoặc
độ dài thẻ có thể khác nhau (ví dụ: các gói có dấu thời gian PTP có thể
yêu cầu thẻ chuyển đổi mở rộng hoặc có thể có một độ dài thẻ trên TX và
khác nhau trên RX). Dù bằng cách nào, trình điều khiển giao thức gắn thẻ phải điền vào
ZZ0000ZZ và/hoặc ZZ0001ZZ
với độ dài tính bằng octet của tiêu đề/đoạn giới thiệu khung chuyển đổi dài nhất. DSA
framework sẽ tự động điều chỉnh MTU của giao diện ống dẫn để
phù hợp với kích thước bổ sung này để các cổng người dùng DSA hỗ trợ
tiêu chuẩn MTU (độ dài tải trọng L2) là 1500 octet. ZZ0002ZZ và
Thuộc tính ZZ0003ZZ cũng được sử dụng để yêu cầu từ ngăn xếp mạng,
trên cơ sở nỗ lực tối đa, việc phân bổ các gói có đủ không gian bổ sung như
rằng hành động đẩy thẻ chuyển mạch khi truyền gói tin không
khiến nó phải phân bổ lại do thiếu bộ nhớ.

Mặc dù các ứng dụng không được yêu cầu phân tích các tiêu đề khung dành riêng cho DSA,
định dạng trên dây của giao thức gắn thẻ biểu thị một Ứng dụng nhị phân
Giao diện được kernel hiển thị hướng tới không gian người dùng, dành cho các bộ giải mã như
ZZ0000ZZ. Trình điều khiển giao thức gắn thẻ phải điền vào thành viên ZZ0001ZZ của
ZZ0002ZZ với giá trị mô tả duy nhất
đặc điểm của sự tương tác cần thiết giữa phần cứng chuyển mạch và
trình điều khiển đường dẫn dữ liệu: độ lệch của từng trường bit trong tiêu đề khung và bất kỳ
xử lý trạng thái cần thiết để xử lý các khung (như có thể được yêu cầu đối với
Dấu thời gian PTP).

Từ góc độ ngăn xếp mạng, tất cả các thiết bị chuyển mạch trong cùng một DSA
cây chuyển đổi sử dụng cùng một giao thức gắn thẻ. Trong trường hợp gói tin chuyển tiếp
kết cấu có nhiều hơn một công tắc, tiêu đề khung dành riêng cho công tắc sẽ được chèn vào
bởi công tắc đầu tiên trong kết cấu mà gói tin được nhận. Tiêu đề này
thường chứa thông tin liên quan đến loại của nó (cho dù đó là điều khiển
khung phải được giữ lại vào CPU hoặc khung dữ liệu cần được chuyển tiếp).
Các khung điều khiển chỉ được giải mã bằng đường dẫn dữ liệu phần mềm, trong khi
khung dữ liệu cũng có thể được chuyển tiếp tự động tới các cổng người dùng khác của
các công tắc khác từ cùng một loại vải và trong trường hợp này là công tắc ngoài cùng
các cổng phải giải mã gói tin.

Lưu ý rằng trong một số trường hợp nhất định, có thể định dạng gắn thẻ được sử dụng
bằng công tắc lá (không được kết nối trực tiếp với CPU) không giống như những gì
ngăn xếp mạng nhìn thấy. Điều này có thể được nhìn thấy với cây chuyển đổi Marvell, trong đó
Cổng CPU có thể được cấu hình để sử dụng DSA hoặc Ethertype DSA (EDSA)
định dạng, nhưng các liên kết DSA được định cấu hình để sử dụng định dạng ngắn hơn (không có Ethertype)
Tiêu đề khung DSA, để giảm chi phí chuyển tiếp gói tự động.
Trường hợp này vẫn xảy ra nếu cây chuyển đổi DSA được cấu hình cho
Giao thức gắn thẻ EDSA, hệ điều hành sẽ thấy các gói được gắn thẻ EDSA từ
các công tắc lá đã gắn thẻ chúng với tiêu đề DSA ngắn hơn. Điều này có thể được thực hiện
vì bộ chuyển mạch Marvell được kết nối trực tiếp với CPU được cấu hình để
thực hiện dịch thẻ giữa DSA và EDSA (đơn giản là hoạt động của
thêm hoặc xóa ZZ0000ZZ EtherType và một số octet đệm).

Có thể xây dựng các thiết lập xếp tầng của các bộ chuyển mạch DSA ngay cả khi chúng
các giao thức gắn thẻ không tương thích với nhau. Trong trường hợp này, có
không có liên kết DSA nào trong kết cấu này và mỗi công tắc tạo thành một công tắc DSA rời rạc
cây. Các liên kết DSA được xem đơn giản là một cặp ống dẫn DSA (đường dẫn hướng ra ngoài
cổng của bộ chuyển mạch DSA ngược dòng) và cổng CPU (cổng đối diện của
công tắc DSA xuôi dòng).

Có thể xem giao thức gắn thẻ của cây chuyển mạch DSA đính kèm thông qua
Thuộc tính sysfs ZZ0000ZZ của ống dẫn DSA::

cat /sys/class/net/eth0/dsa/tagging

Nếu phần cứng và trình điều khiển có khả năng, giao thức gắn thẻ của bộ chuyển mạch DSA
cây có thể được thay đổi trong thời gian chạy. Điều này được thực hiện bằng cách viết thẻ mới
tên giao thức cho cùng thuộc tính thiết bị sysfs như trên (ống dẫn DSA và
tất cả các cổng chuyển đổi kèm theo phải ngừng hoạt động trong khi thực hiện việc này).

Điều mong muốn là tất cả các giao thức gắn thẻ đều có thể kiểm tra được với ZZ0000ZZ
trình điều khiển mô phỏng, có thể được gắn vào bất kỳ giao diện mạng nào. Mục tiêu là vậy
bất kỳ giao diện mạng nào cũng phải có khả năng truyền cùng một gói tin trong
theo cùng một cách và người gắn thẻ phải giải mã cùng một gói nhận được theo cùng một cách
bất kể trình điều khiển được sử dụng cho đường dẫn điều khiển công tắc và trình điều khiển được sử dụng
cho ống dẫn DSA.

Việc truyền gói tin thông qua chức năng ZZ0000ZZ của trình gắn thẻ.
ZZ0001ZZ đã qua có ZZ0002ZZ trỏ vào
ZZ0003ZZ, tức là tại địa chỉ MAC đích và đã chuyển
ZZ0004ZZ đại diện cho giao diện mạng người dùng DSA ảo
gói phần cứng phải được chuyển đến (tức là ZZ0005ZZ).
Công việc của phương pháp này là chuẩn bị skb sao cho switch sẽ
hiểu gói tin dùng cho cổng đầu ra nào (và không phân phối nó tới cổng khác
cổng). Thông thường, điều này được thực hiện bằng cách đẩy tiêu đề khung. Kiểm tra
không cần thiết kích thước không đủ trong khoảng không gian đầu hoặc đuôi skb với điều kiện là
thuộc tính ZZ0006ZZ và ZZ0007ZZ đã được điền
đúng cách, vì DSA đảm bảo có đủ không gian trước khi gọi phương thức này.

Việc tiếp nhận gói thông qua chức năng ZZ0000ZZ của trình gắn thẻ. các
đã vượt qua ZZ0001ZZ có ZZ0002ZZ chỉ vào
Các octet ZZ0003ZZ, tức là vị trí của octet đầu tiên sau đó
EtherType sẽ có nếu khung này không được gắn thẻ. Vai trò của điều này
phương pháp là sử dụng tiêu đề khung, điều chỉnh ZZ0004ZZ để thực sự trỏ vào
octet đầu tiên sau EtherType và thay đổi ZZ0005ZZ để trỏ đến
Giao diện mạng người dùng DSA ảo tương ứng với mặt trước vật lý
cổng chuyển đổi mà gói tin đã được nhận.

Vì việc gắn thẻ các giao thức trong danh mục 1 và 2 phá vỡ phần mềm (và thường xuyên nhất cũng
phần cứng) phân tích gói trên ống dẫn DSA, các tính năng như RPS (Nhận
Chỉ đạo gói) trên ống dẫn DSA sẽ bị hỏng. Ưu đãi khung DSA
với điều này bằng cách nối vào bộ phân tích dòng chảy và dịch chuyển phần bù tại đó
tiêu đề IP sẽ được tìm thấy trong khung được gắn thẻ như được nhìn thấy bởi ống dẫn DSA.
Hành vi này là tự động dựa trên giá trị ZZ0000ZZ của việc gắn thẻ
giao thức. Nếu không phải tất cả các gói đều có kích thước bằng nhau thì trình gắn thẻ có thể thực hiện
Phương thức ZZ0001ZZ của ZZ0002ZZ và ghi đè lên phương thức này
hành vi mặc định bằng cách chỉ định khoản bù đắp chính xác mà mỗi cá nhân phải gánh chịu
Gói RX. Trình gắn thẻ đuôi không gây ra vấn đề cho bộ phân tích dòng chảy.

Giảm tải tổng kiểm tra sẽ hoạt động với trình gắn thẻ loại 1 và 2 khi ống dẫn DSA
trình điều khiển khai báo NETIF_F_HW_CSUM trong vlan_features và xem csum_start và
csum_offset. Đối với những trường hợp đó, DSA sẽ thay đổi điểm bắt đầu và bù tổng kiểm tra bằng cách
kích thước thẻ. Nếu trình điều khiển ống dẫn DSA vẫn sử dụng NETIF_F_IP_CSUM cũ
hoặc NETIF_F_IPV6_CSUM trong vlan_features, việc giảm tải chỉ có thể hoạt động nếu
phần cứng giảm tải đã mong đợi thẻ cụ thể đó (có lẽ do khớp
nhà cung cấp). Các cổng người dùng DSA kế thừa các cờ đó từ ống dẫn và tùy thuộc vào
trình điều khiển quay trở lại tổng kiểm tra phần mềm một cách chính xác khi không có tiêu đề IP
nơi phần cứng mong đợi. Nếu việc kiểm tra đó không hiệu quả, các gói có thể đi
vào mạng mà không có tổng kiểm tra thích hợp (trường tổng kiểm tra sẽ có
tổng tiêu đề IP giả). Đối với loại 3, khi phần cứng giảm tải không
đã mong đợi thẻ chuyển đổi được sử dụng, tổng kiểm tra phải được tính toán trước bất kỳ
thẻ được chèn vào (tức là bên trong trình gắn thẻ). Nếu không, ống dẫn DSA sẽ
bao gồm thẻ đuôi trong phép tính tổng kiểm tra (phần mềm hoặc phần cứng). Sau đó,
khi thẻ bị công tắc tước bỏ trong quá trình truyền, nó sẽ để lại một
tổng kiểm tra IP không chính xác tại chỗ.

Vì nhiều lý do khác nhau (phổ biến nhất là các trình gắn thẻ loại 1 được liên kết
với các ống dẫn không nhận biết DSA, đọc sai những gì ống dẫn coi là MAC DA),
giao thức gắn thẻ có thể yêu cầu ống dẫn DSA hoạt động ở chế độ bừa bãi, để
nhận tất cả các khung bất kể giá trị của MAC DA. Điều này có thể được thực hiện bởi
thiết lập thuộc tính ZZ0000ZZ của ZZ0001ZZ.
Lưu ý rằng điều này giả sử trình điều khiển ống dẫn không nhận biết DSA, đây là tiêu chuẩn.

Thiết bị mạng ống dẫn
-----------------------

Thiết bị mạng ống dẫn là trình điều khiển thiết bị mạng Linux thông thường, chưa sửa đổi dành cho
giao diện Ethernet CPU/quản lý. Người lái xe như vậy đôi khi có thể cần phải
biết liệu DSA có được bật hay không (ví dụ: để bật/tắt các tính năng giảm tải cụ thể),
nhưng hệ thống con DSA đã được chứng minh là hoạt động với các trình điều khiển tiêu chuẩn công nghiệp:
ZZ0000ZZ ZZ0001ZZ, v.v. mà không cần phải sửa đổi những thứ này
trình điều khiển. Các thiết bị mạng như vậy cũng thường được gọi là mạng ống dẫn
các thiết bị vì chúng hoạt động như một đường ống giữa bộ xử lý chủ và phần cứng
Bộ chuyển mạch Ethernet.

Móc ngăn xếp mạng
----------------------

Khi sử dụng ống dẫn netdev với DSA, một móc nhỏ được đặt trong
ngăn xếp mạng là để hệ thống con DSA xử lý Ethernet
chuyển đổi giao thức gắn thẻ cụ thể. DSA thực hiện điều này bằng cách đăng ký một
loại Ethernet cụ thể (và giả) (sau này trở thành ZZ0000ZZ) với
ngăn xếp mạng, nó còn được gọi là ZZ0001ZZ hoặc ZZ0002ZZ. Một điển hình
Trình tự nhận khung Ethernet trông như thế này:

Thiết bị mạng ống dẫn (ví dụ: e1000e):

1. Nhận các đám cháy gián đoạn:

- chức năng nhận được gọi
        - xử lý gói cơ bản được thực hiện: nhận được độ dài, trạng thái, v.v.
        - gói được chuẩn bị để được xử lý bởi lớp Ethernet bằng cách gọi
          ZZ0000ZZ

2. net/ethernet/eth.c::

eth_type_trans(skb, dev)
                  nếu (dev->dsa_ptr != NULL)
                          -> skb->giao thức = ETH_P_XDSA

3. trình điều khiển/net/ethernet/\*::

netif_receive_skb(skb)
                  -> lặp lại packet_type đã đăng ký
                          -> gọi trình xử lý cho ETH_P_XDSA, gọi dsa_switch_rcv()

4. net/dsa/dsa.c::

-> dsa_switch_rcv()
                  -> gọi trình xử lý giao thức cụ thể của thẻ chuyển đổi trong 'net/dsa/tag_*.c'

5. net/dsa/tag_*.c:

- kiểm tra và loại bỏ giao thức thẻ chuyển đổi để xác định cổng gốc
        - định vị thiết bị mạng trên mỗi cổng
        - gọi ZZ0000ZZ bằng thiết bị mạng người dùng DSA
        - gọi ZZ0001ZZ

Sau thời điểm này, các thiết bị mạng người dùng DSA sẽ được cung cấp Ethernet thông thường
các khung có thể được xử lý bởi ngăn xếp mạng.

Thiết bị mạng người dùng
------------------------

Các thiết bị mạng người dùng do DSA tạo được xếp chồng lên nhau trên mạng ống dẫn của họ
thiết bị, mỗi giao diện mạng này sẽ chịu trách nhiệm là một
điểm cuối điều khiển và truyền dữ liệu cho mỗi cổng ở mặt trước của bộ chuyển mạch.
Các giao diện này được chuyên biệt hóa để:

- chèn/xóa giao thức thẻ chuyển đổi (nếu nó tồn tại) khi gửi lưu lượng
  đến/từ các cổng chuyển đổi cụ thể
- truy vấn công tắc cho các hoạt động ethtool: thống kê, trạng thái liên kết,
  Wake-on-LAN, đăng ký kết xuất...
- quản lý PHY bên ngoài/nội bộ: liên kết, tự động đàm phán, v.v.

Các thiết bị mạng người dùng này có chức năng net_device_ops và ethtool_ops tùy chỉnh
con trỏ cho phép DSA giới thiệu mức độ phân lớp giữa mạng
stack/ethtool và triển khai trình điều khiển chuyển đổi.

Khi truyền khung từ các thiết bị mạng người dùng này, DSA sẽ tra cứu thiết bị nào
giao thức gắn thẻ chuyển đổi hiện đã được đăng ký với các thiết bị mạng này và
gọi một quy trình truyền cụ thể đảm nhiệm việc bổ sung các thông tin liên quan
thẻ chuyển đổi trong khung Ethernet.

Các khung này sau đó được xếp hàng đợi để truyền bằng thiết bị mạng ống dẫn
Chức năng ZZ0000ZZ. Vì chúng chứa thẻ chuyển đổi thích hợp nên
Bộ chuyển mạch Ethernet sẽ có thể xử lý các khung đến này từ
giao diện quản lý và đưa chúng đến cổng chuyển mạch vật lý.

Khi sử dụng nhiều cổng CPU, có thể xếp chồng một LAG (liên kết/nhóm)
thiết bị giữa thiết bị người dùng DSA và ống dẫn DSA vật lý. LAG
do đó, thiết bị cũng là một ống dẫn DSA, nhưng các thiết bị phụ LAG vẫn tiếp tục là DSA
cả các ống dẫn (chỉ là không có cổng người dùng nào được gán cho chúng; điều này là cần thiết cho
phục hồi trong trường hợp ống dẫn LAG DSA biến mất). Do đó, đường dẫn dữ liệu của LAG
Ống dẫn DSA được sử dụng không đối xứng. Trên RX, trình xử lý ZZ0000ZZ,
gọi ZZ0001ZZ, được gọi sớm (trên ống dẫn DSA vật lý;
LAG nô lệ). Do đó, đường dẫn dữ liệu RX của ống dẫn LAG DSA không được sử dụng.
Mặt khác, TX diễn ra tuyến tính: ZZ0002ZZ gọi
ZZ0003ZZ, gọi ZZ0004ZZ tới ống dẫn LAG DSA.
Cái sau gọi ZZ0005ZZ tới một ống dẫn DSA vật lý hoặc
khác và trong cả hai trường hợp, gói thoát khỏi hệ thống thông qua đường dẫn phần cứng
về phía công tắc.

Biểu diễn đồ họa
------------------------

Tóm tắt, về cơ bản đây là giao diện của DSA từ một thiết bị mạng
quan điểm::

Ứng dụng không xác định
              mở và liên kết ổ cắm
                       |  ^
                       ZZ0000ZZ
           +----------v--|----------------------+
           ZZ0001ZZ
           |ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ|
           ZZ0006ZZ
           ZZ0007ZZ
           +-----------------------------------+
                         |        ^
            Thẻ được thêm bởi ZZ0008ZZ Thẻ được sử dụng bởi
           trình điều khiển chuyển đổi ZZ0009ZZ trình điều khiển chuyển đổi
                         v |
           +-----------------------------------+
           Phần mềm ZZ0010ZZ
   ---------+-----------------------------------+-------------
           Phần cứng ZZ0011ZZ
           +-----------------------------------+
                         |        ^
         Thẻ được sử dụng bởi ZZ0012ZZ Thẻ được thêm bởi
         phần cứng chuyển đổi ZZ0013ZZ phần cứng chuyển đổi
                         v |
           +-----------------------------------+
           ZZ0014ZZ
           ZZ0015ZZ
           |ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ|
           ++------+-+------+-+------+-+------++

Xe buýt MDIO của người dùng
---------------------------

Để có thể đọc đến/từ một switch PHY được tích hợp trong nó, DSA tạo ra một
người dùng bus MDIO cho phép trình điều khiển chuyển mạch cụ thể chuyển hướng và chặn
MDIO đọc/ghi vào các địa chỉ PHY cụ thể. Trong hầu hết các kết nối MDIO
chuyển mạch, các chức năng này sẽ sử dụng chế độ địa chỉ PHY trực tiếp hoặc gián tiếp
để trả về các thanh ghi MII tiêu chuẩn từ PHY tích hợp trong switch, cho phép PHY
thư viện và/hoặc để trả về trạng thái liên kết, liên kết các trang đối tác, tự động đàm phán
kết quả, v.v.

Đối với các bộ chuyển mạch Ethernet có cả bus MDIO bên ngoài và bên trong,
bus MII của người dùng có thể được sử dụng để mux/demux MDIO đọc và ghi vào một trong hai
các thiết bị MDIO bên trong hoặc bên ngoài, công tắc này có thể được kết nối với: bên trong
PHY, PHY bên ngoài hoặc thậm chí các bộ chuyển mạch bên ngoài.

Cấu trúc dữ liệu
----------------

Cấu trúc dữ liệu DSA được xác định trong ZZ0000ZZ cũng như
ZZ0001ZZ:

- ZZ0000ZZ: cấu hình dữ liệu nền tảng cho một thiết bị chuyển mạch nhất định,
  Cấu trúc này mô tả thiết bị mẹ của thiết bị chuyển mạch, địa chỉ của nó, như
  cũng như các thuộc tính khác nhau của các cổng của nó: tên/nhãn và cuối cùng là định tuyến
  chỉ báo bảng (khi chuyển mạch xếp tầng)

- ZZ0000ZZ: cấu trúc được gán cho thiết bị mạng ống dẫn theo
  ZZ0001ZZ, cấu trúc này tham chiếu cấu trúc dsa_platform_data cũng như
  giao thức gắn thẻ được hỗ trợ bởi cây chuyển mạch và nhận/truyền
  các hook chức năng sẽ được gọi, thông tin về các hook được đính kèm trực tiếp
  công tắc cũng được cung cấp: cổng CPU. Cuối cùng, một bộ sưu tập dsa_switch là
  được tham chiếu đến địa chỉ của các switch riêng lẻ trong cây.

- ZZ0000ZZ: cấu trúc mô tả một thiết bị switch trên cây, tham chiếu
  ZZ0001ZZ làm con trỏ ngược, thiết bị mạng người dùng, mạng ống dẫn
  thiết bị và tham chiếu đến backing``dsa_switch_ops``

- ZZ0000ZZ: cấu trúc con trỏ hàm tham chiếu, xem bên dưới để biết
  mô tả đầy đủ.

Hạn chế về thiết kế
===================

Thiếu thiết bị mạng CPU/DSA
-------------------------------

DSA hiện không tạo thiết bị mạng người dùng cho các cổng CPU hoặc DSA, vì
được mô tả trước đó. Đây có thể là một vấn đề trong các trường hợp sau:

- không thể tìm nạp bộ đếm thống kê cổng CPU của switch bằng ethtool, điều này
  có thể khiến việc gỡ lỗi công tắc MDIO được kết nối bằng giao diện xMII trở nên khó khăn hơn

- không thể định cấu hình các tham số liên kết cổng CPU dựa trên Ethernet
  khả năng điều khiển gắn liền với nó: ZZ0000ZZ

- không thể định cấu hình ID VLAN / Vlan trung kế cụ thể giữa các thiết bị chuyển mạch
  khi sử dụng thiết lập xếp tầng

Những cạm bẫy thường gặp khi sử dụng thiết lập DSA
--------------------------------------------------

Khi thiết bị mạng ống dẫn được định cấu hình để sử dụng DSA (dev->dsa_ptr sẽ trở thành
không phải NULL) và công tắc phía sau nó yêu cầu giao thức gắn thẻ, mạng này
giao diện chỉ có thể được sử dụng độc quyền như một giao diện ống dẫn. Gửi gói
trực tiếp qua giao diện này (ví dụ: mở ổ cắm bằng giao diện này)
sẽ không khiến chúng ta phải thực hiện chức năng truyền giao thức gắn thẻ chuyển đổi, vì vậy
bộ chuyển mạch Ethernet ở đầu bên kia, dự kiến thẻ thường sẽ loại bỏ điều này
khung.

Tương tác với các hệ thống con khác
===================================

DSA hiện tận dụng các hệ thống con sau:

- Thư viện MDIO/PHY: ZZ0000ZZ, ZZ0001ZZ
- Chuyển mạch:ZZ0002ZZ
- Cây thiết bị cho nhiều chức năng of_* khác nhau
- Liên kết nhà phát triển: ZZ0003ZZ

Thư viện MDIO/PHY
-----------------

Các thiết bị mạng người dùng được hiển thị bởi DSA có thể có hoặc không giao tiếp với PHY
thiết bị (ZZ0000ZZ như được định nghĩa trong ZZ0001ZZ, nhưng DSA
hệ thống con xử lý tất cả các kết hợp có thể có:

- các thiết bị PHY bên trong, được tích hợp trong phần cứng chuyển mạch Ethernet
- các thiết bị PHY bên ngoài, được kết nối qua bus MDIO bên trong hoặc bên ngoài
- các thiết bị PHY bên trong, được kết nối qua bus MDIO bên trong
- các thiết bị PHY đặc biệt, không được tự động thương lượng hoặc không được MDIO quản lý: SFP, MoCA; hay còn gọi là
  PHY cố định

Cấu hình PHY được thực hiện bởi chức năng ZZ0000ZZ và
logic về cơ bản trông như thế này:

- nếu sử dụng Cây thiết bị, thiết bị PHY sẽ được tra cứu bằng tiêu chuẩn
  Thuộc tính "phy-handle", nếu tìm thấy, thiết bị PHY này sẽ được tạo và đăng ký
  sử dụng ZZ0000ZZ

- nếu Cây thiết bị được sử dụng và thiết bị PHY được "cố định", nghĩa là tuân thủ
  định nghĩa về PHY không phải MDIO được quản lý như được định nghĩa trong
  ZZ0000ZZ, PHY đã được đăng ký
  và được kết nối trong suốt bằng trình điều khiển bus MDIO cố định đặc biệt

- cuối cùng, nếu PHY được tích hợp vào bộ chuyển mạch, điều này rất phổ biến với
  gói chuyển đổi độc lập, PHY được thử nghiệm bằng cách sử dụng bus MII do người dùng tạo
  bởi DSA


SWITCHDEV
---------

DSA sử dụng trực tiếp SWITCHDEV khi giao tiếp với lớp cầu nối và
cụ thể hơn với phần lọc VLAN của nó khi cấu hình VLAN ở trên cùng
của các thiết bị mạng người dùng trên mỗi cổng. Tính đến hôm nay, các đối tượng SWITCHDEV duy nhất
được DSA hỗ trợ là các đối tượng FDB và VLAN.

liên kết nhà phát triển
-----------------------

DSA đăng ký một thiết bị liên kết phát triển cho mỗi công tắc vật lý trong kết cấu.
Đối với mỗi thiết bị devlink, mọi cổng vật lý (tức là cổng người dùng, cổng CPU, DSA
liên kết hoặc các cổng không được sử dụng) được hiển thị dưới dạng cổng devlink.

Trình điều khiển DSA có thể sử dụng các tính năng liên kết phát triển sau:

- Khu vực: tính năng gỡ lỗi cho phép không gian người dùng kết xuất do trình điều khiển xác định
  các vùng thông tin phần cứng ở định dạng nhị phân cấp thấp. Cả toàn cầu
  các khu vực cũng như khu vực trên mỗi cổng đều được hỗ trợ. Có thể xuất khẩu
  các vùng liên kết phát triển ngay cả đối với các phần dữ liệu đã được hiển thị theo một cách nào đó
  tới các chương trình không gian người dùng iproute2 tiêu chuẩn (ip-link, bridge), như địa chỉ
  bảng và bảng VLAN. Ví dụ, điều này có thể hữu ích nếu các bảng
  chứa các chi tiết bổ sung dành riêng cho phần cứng mà không thể nhìn thấy được thông qua
  sự trừu tượng hóa iproute2 hoặc có thể hữu ích khi kiểm tra các bảng này trên
  các cổng không phải của người dùng cũng vô hình đối với iproute2 vì không có mạng
  giao diện được đăng ký cho họ.
- Params: một tính năng cho phép người dùng định cấu hình một số điều chỉnh ở mức độ thấp nhất định
  các nút liên quan đến thiết bị. Trình điều khiển có thể triển khai chung có thể áp dụng
  thông số liên kết nhà phát triển hoặc có thể thêm thông số liên kết nhà phát triển mới dành riêng cho thiết bị.
- Tài nguyên: một tính năng giám sát cho phép người dùng xem mức độ
  việc sử dụng các bảng phần cứng nhất định trong thiết bị, chẳng hạn như FDB, VLAN, v.v.
- Bộ đệm dùng chung: tính năng QoS để điều chỉnh và phân vùng bộ nhớ và khung
  đặt chỗ cho mỗi cổng và mỗi loại lưu lượng, ở lối vào và lối ra
  hướng dẫn sao cho lưu lượng truy cập số lượng lớn có mức độ ưu tiên thấp không cản trở
  xử lý lưu lượng truy cập quan trọng có mức độ ưu tiên cao.

Để biết thêm chi tiết, hãy tham khảo ZZ0000ZZ.

Cây thiết bị
------------

DSA có một ràng buộc tiêu chuẩn hóa được ghi lại trong
ZZ0000ZZ. Trình trợ giúp thư viện PHY/MDIO
các hàm như ZZ0001ZZ, ZZ0002ZZ cũng được sử dụng để truy vấn
Chi tiết cụ thể về PHY trên mỗi cổng: kết nối giao diện, vị trí bus MDIO, v.v.

Phát triển trình điều khiển
===========================

Trình điều khiển chuyển đổi DSA cần triển khai cấu trúc ZZ0000ZZ để
chứa các thành viên khác nhau được mô tả dưới đây.

Thăm dò, đăng ký và tuổi thọ thiết bị
-----------------------------------------

Công tắc DSA là cấu trúc ZZ0000ZZ thông thường trên xe buýt (có thể là nền tảng, SPI,
I2C, MDIO hoặc cách khác). Khung DSA không tham gia vào quá trình thăm dò của họ
với lõi thiết bị.

Chuyển đổi đăng ký từ góc độ của người lái xe có nghĩa là vượt qua hợp lệ
Con trỏ ZZ0000ZZ tới ZZ0001ZZ, thường là từ
chuyển đổi chức năng thăm dò của trình điều khiển. Các thành viên sau đây phải hợp lệ trong
provided structure:

- ZZ0000ZZ: sẽ dùng để phân tích dữ liệu nút OF hoặc nền tảng của switch.

- ZZ0000ZZ: sẽ dùng để tạo port list cho switch này, và
  để xác thực các chỉ số cổng được cung cấp trong nút OF.

- ZZ0000ZZ: con trỏ tới cấu trúc ZZ0001ZZ đang giữ DSA
  việc triển khai phương pháp.

- ZZ0000ZZ: con trỏ ngược tới cấu trúc dữ liệu riêng tư của trình điều khiển có thể
  được truy xuất trong tất cả các lệnh gọi lại phương thức DSA tiếp theo.

Ngoài ra, các cờ sau trong cấu trúc ZZ0000ZZ có thể tùy chọn
được cấu hình để có được hành vi dành riêng cho trình điều khiển từ lõi DSA. của họ
hành vi khi thiết lập được ghi lại thông qua các nhận xét trong ZZ0001ZZ.

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

Trong nội bộ, DSA giữ một loạt cây chuyển mạch (nhóm chuyển mạch) trên toàn cầu để
kernel và gắn cấu trúc ZZ0000ZZ vào cây khi đăng ký.
ID cây mà switch được gắn vào được xác định bởi u32 đầu tiên
số thuộc tính ZZ0001ZZ của nút OF của công tắc (0 nếu thiếu).
ID chuyển đổi trong cây được xác định bởi số u32 thứ hai của
cùng thuộc tính OF (0 nếu thiếu). Đăng ký nhiều switch với cùng một switch
ID chuyển đổi và ID cây là bất hợp pháp và sẽ gây ra lỗi. Sử dụng dữ liệu nền tảng,
cho phép sử dụng một công tắc đơn và một cây công tắc duy nhất.

Trong trường hợp cây có nhiều công tắc, việc thăm dò diễn ra không đối xứng.
Người gọi N-1 đầu tiên của ZZ0000ZZ chỉ thêm cổng của họ vào
danh sách cổng của cây (ZZ0001ZZ), mỗi cổng có một con trỏ ngược tới cổng của nó
công tắc liên quan (ZZ0002ZZ). Sau đó, các công tắc này thoát khỏi
ZZ0003ZZ gọi sớm, vì ZZ0004ZZ
đã xác định rằng cây chưa hoàn chỉnh (không phải tất cả các cổng được tham chiếu bởi
Các liên kết DSA có trong danh sách cổng của cây). Cây trở nên hoàn chỉnh khi
công tắc cuối cùng gọi ZZ0005ZZ và điều này kích hoạt hiệu quả
tiếp tục khởi tạo (bao gồm lệnh gọi tới ZZ0006ZZ) cho
tất cả các switch trong cây đó, tất cả đều là một phần của ngữ cảnh gọi của cái cuối cùng
chức năng thăm dò của switch.

Việc ngược lại với việc đăng ký diễn ra khi gọi ZZ0000ZZ,
loại bỏ các cổng của switch khỏi danh sách cổng của cây. Toàn bộ cây
bị phá bỏ khi switch đầu tiên hủy đăng ký.

Trình điều khiển chuyển đổi DSA bắt buộc phải triển khai lệnh gọi lại ZZ0000ZZ
của xe buýt tương ứng của họ và gọi ZZ0001ZZ từ đó (tối thiểu
phiên bản phân tích đầy đủ được thực hiện bởi ZZ0002ZZ).
Lý do là DSA giữ một tham chiếu trên thiết bị mạng ống dẫn và nếu
trình điều khiển cho thiết bị ống dẫn quyết định hủy liên kết khi tắt máy, tham chiếu của DSA
sẽ chặn hoạt động đó hoàn tất.

Phải gọi ZZ0000ZZ hoặc ZZ0001ZZ,
nhưng không phải cả hai và mô hình trình điều khiển thiết bị cho phép phương thức ZZ0002ZZ của xe buýt
được gọi ngay cả khi ZZ0003ZZ đã được gọi. Vì vậy, các tài xế đang
dự kiến sẽ triển khai phương pháp loại trừ lẫn nhau giữa ZZ0004ZZ và
ZZ0005ZZ bằng cách đặt drvdata của họ thành NULL sau khi bất kỳ dữ liệu nào trong số này đã chạy và
kiểm tra xem drvdata có phải là NULL hay không trước khi tiếp tục thực hiện bất kỳ hành động nào.

Sau khi ZZ0000ZZ hoặc ZZ0001ZZ được gọi, không
các cuộc gọi lại tiếp theo thông qua ZZ0002ZZ được cung cấp có thể diễn ra và
trình điều khiển có thể giải phóng cấu trúc dữ liệu được liên kết với ZZ0003ZZ.

Chuyển đổi cấu hình
--------------------

- ZZ0000ZZ: điều này cho biết loại giao thức gắn thẻ là gì
  được hỗ trợ, phải là giá trị hợp lệ từ enum ZZ0001ZZ.
  Thông tin trả về không nhất thiết phải ở trạng thái tĩnh; người lái xe đã được thông qua
  Số cổng CPU, cũng như giao thức gắn thẻ của một cổng có thể được xếp chồng lên nhau
  chuyển mạch ngược dòng, trong trường hợp có những hạn chế về phần cứng về mặt hỗ trợ
  các định dạng thẻ.

- ZZ0000ZZ: khi giao thức gắn thẻ mặc định có khả năng tương thích
  vấn đề với ống dẫn hoặc các vấn đề khác, người lái xe có thể hỗ trợ thay đổi nó
  trong thời gian chạy, thông qua thuộc tính cây thiết bị hoặc thông qua sysfs. Trong đó
  trường hợp, các cuộc gọi tiếp theo tới ZZ0001ZZ sẽ báo cáo giao thức trong
  sử dụng hiện tại.

- ZZ0000ZZ: chức năng setup cho switch, chức năng này có nhiệm vụ cài đặt
  nâng cấp cấu trúc riêng ZZ0001ZZ với tất cả những gì nó cần: đăng ký bản đồ,
  ngắt, mutex, khóa, v.v. Chức năng này cũng được kỳ vọng sẽ hoạt động đúng cách
  định cấu hình bộ chuyển mạch để tách tất cả các giao diện mạng khỏi nhau, điều đó
  nghĩa là chúng phải được cách ly bởi chính phần cứng của bộ chuyển mạch, thường bằng cách tạo
  ID VLAN dựa trên cổng cho mỗi cổng và chỉ cho phép cổng CPU và
  cổng cụ thể nằm trong vectơ chuyển tiếp. Các cổng không được sử dụng bởi
  nền tảng nên bị vô hiệu hóa. Sau chức năng này, công tắc dự kiến sẽ được
  được cấu hình đầy đủ và sẵn sàng phục vụ mọi loại yêu cầu. Nó được khuyến khích
  thực hiện cài đặt lại phần mềm của công tắc trong chức năng thiết lập này để
  tránh dựa vào những gì tác nhân phần mềm trước đó chẳng hạn như bộ tải khởi động/chương trình cơ sở
  có thể đã được cấu hình trước đó. Phương thức chịu trách nhiệm hoàn tác bất kỳ
  phân bổ hoặc hoạt động áp dụng được thực hiện ở đây là ZZ0002ZZ.

- ZZ0000ZZ và ZZ0001ZZ: các phương thức khởi tạo và
  phá hủy cấu trúc dữ liệu trên mỗi cổng. Nó là bắt buộc đối với một số hoạt động
  chẳng hạn như đăng ký và hủy đăng ký các vùng cổng devlink được thực hiện từ
  những phương pháp này, nếu không thì chúng là tùy chọn. Một cảng sẽ chỉ bị phá bỏ nếu
  nó đã được thiết lập trước đó. Có thể thiết lập một cổng trong quá trình
  thăm dò chỉ để bị phá bỏ ngay sau đó, ví dụ như trong trường hợp nó
  Không thể tìm thấy PHY. Trong trường hợp này, việc thăm dò công tắc DSA vẫn tiếp tục
  không có cổng cụ thể đó.

- ZZ0000ZZ: phương pháp mà qua đó ái lực (kết hợp được sử dụng
  cho mục đích chấm dứt lưu lượng) giữa cổng người dùng và cổng CPU có thể
  đã thay đổi. Theo mặc định, tất cả các cổng người dùng từ một cây được gán cho cổng đầu tiên
  cổng CPU có sẵn phù hợp với họ (hầu hết các trường hợp điều này có nghĩa là
  tất cả các cổng người dùng của cây đều được gán cho cùng một cổng CPU, ngoại trừ H
  cấu trúc liên kết như được mô tả trong cam kết 2c0b03258b8b). Đối số ZZ0001ZZ
  đại diện cho chỉ mục của cổng người dùng và đối số ZZ0002ZZ đại diện cho
  ống dẫn DSA ZZ0003ZZ mới. Cổng CPU được liên kết với cổng mới
  ống dẫn có thể được lấy ra bằng cách nhìn vào ZZ0004ZZ. Ngoài ra, ống dẫn cũng có thể là thiết bị LAG trong đó
  tất cả các thiết bị phụ đều là ống dẫn DSA vật lý. LAG DSA cũng có
  con trỏ ZZ0005ZZ hợp lệ, tuy nhiên đây không phải là con trỏ duy nhất mà là một
  bản sao của ống dẫn DSA vật lý đầu tiên (LAG phụ) ZZ0006ZZ. Trong trường hợp
  của ống dẫn LAG DSA, một lệnh gọi tiếp theo tới ZZ0007ZZ sẽ được phát ra
  riêng cho các cổng CPU vật lý được liên kết với DSA vật lý
  ống dẫn, yêu cầu họ tạo phần cứng LAG được liên kết với LAG
  giao diện.

Quản lý liên kết và thiết bị PHY
--------------------------------

- ZZ0000ZZ: Một số thiết bị chuyển mạch được giao tiếp với nhiều loại PHY Ethernet khác nhau,
  nếu thư viện PHY thì trình điều khiển PHY cần biết về thông tin thì nó không thể lấy được
  của chính nó (ví dụ: đến từ các thanh ghi ánh xạ bộ nhớ chuyển đổi), chức năng này
  sẽ trả về một bitmask 32 bit của "cờ" riêng tư giữa công tắc
  trình điều khiển và trình điều khiển Ethernet PHY trong ZZ0001ZZ.

- ZZ0000ZZ: Chức năng được gọi bởi bus MDIO của người dùng DSA khi cố đọc
  cổng chuyển đổi MDIO đăng ký. Nếu không có sẵn, hãy trả về 0xffff cho mỗi lần đọc.
  Đối với các PHY chuyển mạch Ethernet tích hợp, chức năng này sẽ cho phép đọc liên kết
  trạng thái, kết quả đàm phán tự động, liên kết các trang đối tác, v.v.

- ZZ0000ZZ: Chức năng được gọi bởi bus MDIO của người dùng DSA khi cố gắng ghi
  đến các thanh ghi cổng chuyển đổi MDIO. Nếu không có sẵn, trả về lỗi tiêu cực
  mã.

- ZZ0000ZZ: Chức năng được thư viện PHY gọi khi thiết bị mạng người dùng
  được gắn vào thiết bị PHY. Chức năng này chịu trách nhiệm thích hợp
  cấu hình các thông số liên kết cổng switch: tốc độ, song công, tạm dừng dựa trên
  những gì ZZ0001ZZ đang cung cấp.

- ZZ0000ZZ: Hàm được gọi bởi thư viện PHY và cụ thể là bởi
  trình điều khiển PHY đã sửa lỗi yêu cầu trình điều khiển chuyển mạch về các tham số liên kết có thể
  không được tự động thương lượng hoặc có được bằng cách đọc các thanh ghi PHY thông qua MDIO.
  Điều này đặc biệt hữu ích cho các loại phần cứng cụ thể như QSGMII,
  MoCA hoặc các loại PHY được quản lý không phải MDIO khác ở ngoài liên kết băng tần
  thông tin thu được

Hoạt động của Ethtool
---------------------

- ZZ0000ZZ: hàm ethtool dùng để truy vấn chuỗi của driver, sẽ
  thường trả về chuỗi thống kê, chuỗi cờ riêng, v.v.

- ZZ0000ZZ: hàm ethtool dùng để truy vấn số liệu thống kê trên mỗi cổng và
  trả về giá trị của chúng. DSA phủ lên số liệu thống kê chung về thiết bị mạng của người dùng:
  Bộ đếm RX/TX từ thiết bị mạng, với số liệu thống kê cụ thể về trình điều khiển chuyển đổi
  mỗi cổng

- ZZ0000ZZ: hàm ethtool dùng để truy vấn số lượng mục thống kê

- ZZ0000ZZ: chức năng ethtool được sử dụng để lấy cài đặt Wake-on-LAN trên mỗi cổng, cái này
  đối với một số triển khai nhất định, chức năng này cũng có thể truy vấn thiết bị mạng ống dẫn
  Cài đặt Wake-on-LAN nếu giao diện này cần tham gia Wake-on-LAN

- ZZ0000ZZ: chức năng ethtool được sử dụng để định cấu hình cài đặt Wake-on-LAN trên mỗi cổng,
  đối tác trực tiếp với set_wol với những hạn chế tương tự

- ZZ0000ZZ: chức năng ethtool dùng để cấu hình cổng switch EEE (Xanh lục
  Ethernet), có thể tùy chọn gọi thư viện PHY để bật EEE tại
  Mức PHY nếu có liên quan. Chức năng này sẽ kích hoạt EEE tại cổng chuyển đổi MAC
  logic điều khiển và xử lý dữ liệu

- ZZ0000ZZ: chức năng ethtool được sử dụng để truy vấn cài đặt cổng chuyển đổi EEE,
  chức năng này sẽ trả về trạng thái EEE của cổng chuyển đổi bộ điều khiển MAC
  và logic xử lý dữ liệu cũng như truy vấn PHY để biết cấu hình hiện tại của nó
  Cài đặt EEE

- ZZ0000ZZ: hàm ethtool trả về một switch nhất định EEPROM
  chiều dài/kích thước tính bằng byte

- ZZ0000ZZ: hàm ethtool trả về nội dung EEPROM cho một switch đã cho

- ZZ0000ZZ: hàm ethtool ghi dữ liệu được chỉ định vào một switch nhất định EEPROM

- ZZ0000ZZ: hàm ethtool trả về độ dài thanh ghi cho một giá trị nhất định
  chuyển đổi

- ZZ0000ZZ: chức năng ethtool trả về thanh ghi nội bộ của bộ chuyển mạch Ethernet
  nội dung. Chức năng này có thể yêu cầu mã đất của người dùng trong ethtool để
  giá trị và thanh ghi in đẹp

Quản lý nguồn điện
------------------

- ZZ0000ZZ: chức năng được gọi bởi thiết bị nền tảng DSA khi hệ thống chuyển sang
  tạm dừng, sẽ dừng mọi hoạt động của bộ chuyển mạch Ethernet, nhưng vẫn giữ các cổng
  tham gia hoạt động Wake-on-LAN cũng như logic đánh thức bổ sung nếu
  được hỗ trợ

- ZZ0000ZZ: chức năng được thiết bị nền tảng DSA gọi khi hệ thống hoạt động trở lại,
  sẽ tiếp tục tất cả các hoạt động của bộ chuyển mạch Ethernet và định cấu hình lại bộ chuyển mạch thành
  ở trạng thái hoạt động hoàn toàn

- ZZ0000ZZ: chức năng được gọi bởi thiết bị mạng người dùng DSA ndo_open
  chức năng khi một cổng được đưa lên về mặt quản lý, chức năng này sẽ
  kích hoạt đầy đủ một cổng chuyển đổi nhất định. DSA đảm nhiệm việc đánh dấu cổng bằng
  ZZ0001ZZ nếu cổng là thành viên cầu nối hoặc ZZ0002ZZ nếu cổng đó là thành viên cầu nối
  thì không, và việc truyền bá những thay đổi này xuống phần cứng

- ZZ0000ZZ: chức năng được gọi bởi thiết bị mạng người dùng DSA ndo_close
  chức năng khi một cổng bị ngừng hoạt động về mặt quản lý, chức năng này sẽ
  vô hiệu hóa hoàn toàn một cổng chuyển đổi nhất định. DSA đảm nhiệm việc đánh dấu cổng bằng
  ZZ0001ZZ và truyền bá các thay đổi tới phần cứng nếu cổng này được
  bị khuyết tật khi là thành viên bridge

Cơ sở dữ liệu địa chỉ
---------------------

Phần cứng chuyển mạch dự kiến sẽ có một bảng cho các mục FDB, tuy nhiên không phải tất cả
trong số họ đang hoạt động cùng một lúc. Cơ sở dữ liệu địa chỉ là tập hợp con (phân vùng)
trong số các mục FDB đang hoạt động (có thể khớp với việc học địa chỉ trên RX hoặc FDB
tra cứu trên TX) tùy thuộc vào trạng thái của cổng. Cơ sở dữ liệu địa chỉ có thể
đôi khi được gọi là "FID" (ID lọc) trong tài liệu này, mặc dù
việc triển khai cơ bản có thể chọn bất cứ thứ gì có sẵn cho phần cứng.

Ví dụ: tất cả các cổng thuộc về cầu nối không xác định VLAN (được
ZZ0000ZZ VLAN-unware) dự kiến sẽ tìm hiểu các địa chỉ nguồn trong
cơ sở dữ liệu được trình điều khiển liên kết với cây cầu đó (chứ không phải với cây cầu khác
VLAN-cầu không biết). Trong quá trình chuyển tiếp và tra cứu FDB, một gói được nhận trên
Cổng cầu nối không nhận biết VLAN sẽ có thể tìm thấy mục nhập VLAN không nhận biết FDB có
cùng MAC DA với gói, hiện có trên một thành viên cổng khác của
cùng một cây cầu. Đồng thời, quá trình tra cứu FDB phải không thể tìm thấy
một mục FDB có cùng MAC DA với gói, nếu mục đó hướng tới
một cổng là thành viên của một cây cầu không nhận biết VLAN khác (và do đó
liên kết với cơ sở dữ liệu địa chỉ khác).

Tương tự, mỗi VLAN của mỗi cây cầu nhận biết VLAN được giảm tải phải có một
cơ sở dữ liệu địa chỉ liên quan, được chia sẻ bởi tất cả các cổng là thành viên của
VLAN đó, nhưng không được chia sẻ bởi các cổng thuộc các cầu nối khác nhau
thành viên của cùng một VID.

Trong ngữ cảnh này, cơ sở dữ liệu không nhận biết VLAN có nghĩa là tất cả các gói được mong đợi
khớp với nó bất kể ID VLAN (chỉ tra cứu địa chỉ MAC), trong khi
Cơ sở dữ liệu nhận biết VLAN có nghĩa là các gói phải khớp dựa trên VLAN
ID từ tiêu đề 802.1Q đã được phân loại (hoặc pvid nếu không được gắn thẻ).

Ở lớp cầu nối, các mục FDB không biết VLAN có giá trị VID đặc biệt là 0,
trong khi các mục FDB nhận biết VLAN có các giá trị VID khác 0. Lưu ý rằng một
Cầu nối không nhận biết VLAN có thể có các mục nhập FDB nhận biết VLAN (khác 0) FDB và một
Cầu nối nhận biết VLAN có thể có các mục nhập FDB không nhận biết VLAN. Giống như trong phần cứng,
cầu phần mềm giữ các cơ sở dữ liệu địa chỉ riêng biệt và chuyển tải cho phần cứng
Các mục FDB thuộc các cơ sở dữ liệu này, thông qua switchdev, không đồng bộ
liên quan đến thời điểm cơ sở dữ liệu hoạt động hoặc không hoạt động.

Khi một cổng người dùng hoạt động ở chế độ độc lập, trình điều khiển của nó sẽ cấu hình nó để
sử dụng một cơ sở dữ liệu riêng biệt gọi là cơ sở dữ liệu cổng riêng. Điều này khác với
cơ sở dữ liệu được mô tả ở trên và sẽ cản trở hoạt động như một cổng độc lập
(gói vào, gói ra cổng CPU) càng ít càng tốt. Ví dụ,
khi xâm nhập, nó không nên cố gắng tìm hiểu MAC SA của lưu lượng truy cập xâm nhập, vì
học tập là một dịch vụ lớp cầu nối và đây là một cổng độc lập, do đó
nó sẽ tiêu tốn không gian vô dụng. Không cần học địa chỉ, cổng riêng
cơ sở dữ liệu phải trống trong quá trình triển khai đơn giản và trong trường hợp này, tất cả
các gói nhận được sẽ được tràn vào cổng CPU một cách tầm thường.

Các cổng DSA (xếp tầng) và CPU còn được gọi là cổng "chia sẻ" vì chúng phục vụ
nhiều cơ sở dữ liệu địa chỉ và cơ sở dữ liệu mà một gói sẽ được liên kết
to thường được nhúng trong thẻ DSA. Điều này có nghĩa là cổng CPU có thể
đồng thời vận chuyển các gói đến từ một cổng độc lập (được
được phân loại theo phần cứng trong một cơ sở dữ liệu địa chỉ) và từ một cổng cầu (được
được phân loại vào cơ sở dữ liệu địa chỉ khác).

Trình điều khiển chuyển đổi đáp ứng các tiêu chí nhất định có thể tối ưu hóa giao diện đơn giản
cấu hình bằng cách xóa cổng CPU khỏi miền tràn của bộ chuyển mạch,
và chỉ lập trình phần cứng với các mục FDB hướng về cổng CPU
mà người ta biết rằng phần mềm quan tâm đến các địa chỉ MAC đó.
Các gói không khớp với mục nhập FDB đã biết sẽ không được gửi đến CPU,
điều này sẽ tiết kiệm các chu kỳ CPU cần thiết để tạo skb chỉ để thả nó đi.

DSA có thể thực hiện lọc địa chỉ máy chủ cho các loại địa chỉ sau:
địa chỉ:

- Địa chỉ unicast MAC chính của các cổng (ZZ0000ZZ). Đây là
  được liên kết với cơ sở dữ liệu cổng riêng của cổng người dùng tương ứng,
  và trình điều khiển được thông báo cài đặt chúng thông qua ZZ0001ZZ theo hướng
  cổng CPU.

- Địa chỉ cổng unicast và multicast MAC thứ cấp (đã thêm địa chỉ
  thông qua ZZ0000ZZ và ZZ0001ZZ). Những điều này cũng liên quan
  với cơ sở dữ liệu cổng riêng của cổng người dùng tương ứng.

- Các mục FDB cầu cục bộ/vĩnh viễn (ZZ0000ZZ). Đây là MAC
  địa chỉ của các cổng cầu mà các gói phải được kết thúc cục bộ
  và không được chuyển tiếp. Chúng được liên kết với cơ sở dữ liệu địa chỉ cho điều đó
  cầu.

- Các mục FDB cầu tĩnh được cài đặt hướng tới các giao diện nước ngoài (không phải DSA)
  hiện diện trong cùng một cầu nối với một số cổng chuyển đổi DSA. Đây cũng là
  được liên kết với cơ sở dữ liệu địa chỉ cho cây cầu đó.

- Tự động học các mục FDB trên các giao diện nước ngoài có trong cùng một
  bridge như một số cổng chuyển đổi DSA, chỉ khi ZZ0000ZZ
  được trình điều khiển đặt thành true. Chúng được liên kết với cơ sở dữ liệu địa chỉ
  cho cây cầu đó.

Đối với các hoạt động khác nhau được nêu chi tiết bên dưới, DSA cung cấp cấu trúc ZZ0000ZZ
có thể thuộc các loại sau:

- ZZ0000ZZ: mục FDB (hoặc MDB) được cài đặt hoặc xóa thuộc về
  cơ sở dữ liệu cổng riêng của cổng người dùng ZZ0001ZZ.
- ZZ0002ZZ: mục thuộc về một trong các cơ sở dữ liệu địa chỉ của bridge
  ZZ0003ZZ. Tách biệt giữa cơ sở dữ liệu không biết VLAN và mỗi VID
  dự kiến cơ sở dữ liệu của cây cầu này sẽ do người lái xe thực hiện.
- ZZ0004ZZ: mục nhập thuộc cơ sở dữ liệu địa chỉ của LAG ZZ0005ZZ.
  Lưu ý: ZZ0006ZZ hiện không được sử dụng và có thể bị xóa trong tương lai.

Các trình điều khiển hoạt động dựa trên đối số ZZ0000ZZ trong ZZ0001ZZ,
ZZ0002ZZ, v.v. nên khai báo ZZ0003ZZ là đúng.

DSA liên kết từng cây cầu đã giảm tải và mỗi LAG đã giảm tải với một ID dựa trên một
(ZZ0000ZZ, ZZ0001ZZ) nhằm mục đích
đếm lại địa chỉ trên các cổng được chia sẻ. Người lái xe có thể cõng theo cách đánh số của DSA
lược đồ (ID có thể đọc được thông qua ZZ0002ZZ và ZZ0003ZZ hoặc có thể
thực hiện của riêng mình.

Chỉ những trình điều khiển tuyên bố hỗ trợ cách ly FDB mới được thông báo về FDB
các mục trên cổng CPU thuộc cơ sở dữ liệu ZZ0000ZZ.
Vì lý do tương thích/cũ, địa chỉ ZZ0001ZZ được thông báo cho
trình điều khiển ngay cả khi chúng không hỗ trợ cách ly FDB. Tuy nhiên, ZZ0002ZZ
và ZZ0003ZZ luôn được đặt thành 0 trong trường hợp đó (để biểu thị việc thiếu
cách ly, nhằm mục đích hoàn thuế).

Lưu ý rằng trình điều khiển chuyển đổi không bắt buộc phải triển khai vật lý
cơ sở dữ liệu địa chỉ riêng biệt cho từng cổng người dùng độc lập. Vì các mục FDB trong
cơ sở dữ liệu cổng riêng sẽ luôn trỏ đến cổng CPU, không có rủi ro
cho các quyết định chuyển tiếp không chính xác. Trong trường hợp này, tất cả các cổng độc lập có thể
chia sẻ cùng một cơ sở dữ liệu, nhưng việc đếm tham chiếu các địa chỉ do máy chủ lọc
(không xóa mục nhập FDB cho địa chỉ MAC của cổng nếu nó vẫn được sử dụng bởi
cổng khác) trở thành trách nhiệm của người lái xe, vì DSA không biết
rằng cơ sở dữ liệu cổng trên thực tế được chia sẻ. Điều này có thể đạt được bằng cách gọi
ZZ0000ZZ và ZZ0001ZZ.
Nhược điểm là trên thực tế, danh sách lọc RX của từng cổng người dùng
được chia sẻ, điều đó có nghĩa là cổng người dùng A có thể chấp nhận gói có MAC DA.
không nên có, chỉ vì địa chỉ MAC đó nằm trong danh sách lọc RX của
cổng người dùng B. Tuy nhiên, các gói này vẫn sẽ bị loại bỏ trong phần mềm.

Lớp cầu
------------

Việc giảm tải mặt phẳng chuyển tiếp cầu là tùy chọn và được xử lý bằng các phương pháp
bên dưới. Họ có thể vắng mặt, trả về -EOPNOTSUPP, hoặc ZZ0000ZZ có thể
khác 0 và vượt quá, và trong trường hợp này, việc tham gia một cổng cầu vẫn là
có thể, nhưng việc chuyển tiếp gói sẽ diễn ra trong phần mềm và các cổng
dưới cầu phần mềm phải được cấu hình theo cách tương tự như đối với
hoạt động độc lập, tức là có tất cả các chức năng dịch vụ bắc cầu (địa chỉ
learning, v.v.) bị vô hiệu hóa và chỉ gửi tất cả các gói đã nhận đến cổng CPU.

Cụ thể, một cảng bắt đầu dỡ tải mặt phẳng chuyển tiếp của một cây cầu sau khi nó
trả về thành công cho phương thức ZZ0000ZZ và ngừng thực hiện sau
ZZ0001ZZ đã được gọi. Bốc cầu nghĩa là tự chủ
tìm hiểu các mục nhập FDB theo trạng thái của cổng cầu nối phần mềm và
tự động chuyển tiếp (hoặc làm ngập) các gói đã nhận mà không cần sự can thiệp của CPU.
Đây là tùy chọn ngay cả khi dỡ tải một cổng cầu. Gắn thẻ trình điều khiển giao thức
dự kiến sẽ gọi ZZ0002ZZ cho các gói
đã được chuyển tiếp tự động trong miền chuyển tiếp của
cổng chuyển mạch vào. DSA, đến ZZ0003ZZ, xem xét tất cả
chuyển đổi một phần cổng của cùng một ID cây thành một phần của cùng một chuyển tiếp cầu
miền (có khả năng tự động chuyển tiếp cho nhau).

Giảm tải quá trình chuyển tiếp TX của bridge là một khái niệm khác biệt với
chỉ đơn giản là giảm tải mặt phẳng chuyển tiếp của nó và đề cập đến khả năng của một số
sự kết hợp giao thức trình điều khiển và thẻ để truyền một skb duy nhất đến từ
chức năng truyền của thiết bị cầu nối tới nhiều cổng đầu ra tiềm năng (và
do đó tránh được việc sao chép nó trong phần mềm).

Các gói mà bridge yêu cầu hành vi này được gọi là mặt phẳng dữ liệu
các gói và đặt ZZ0000ZZ thành true trong giao thức thẻ
chức năng ZZ0001ZZ của trình điều khiển. Các gói mặt phẳng dữ liệu phải được tra cứu FDB,
học phần cứng trên cổng CPU và không ghi đè trạng thái cổng STP.
Ngoài ra, việc sao chép các gói dữ liệu (multicast, Flooding)
được xử lý bằng phần cứng và trình điều khiển cầu nối sẽ truyền một skb duy nhất cho mỗi
gói có thể cần hoặc không cần sao chép.

Khi tính năng giảm tải chuyển tiếp TX được bật, trình điều khiển giao thức thẻ sẽ
chịu trách nhiệm đưa các gói vào mặt phẳng dữ liệu của phần cứng hướng tới
miền cầu nối chính xác (FID) mà cổng là một phần trong đó. Cảng có thể là
VLAN-không biết và trong trường hợp này FID phải bằng FID được sử dụng bởi
trình điều khiển cho cơ sở dữ liệu địa chỉ không xác định VLAN được liên kết với cây cầu đó.
Ngoài ra, cây cầu có thể nhận biết được VLAN và trong trường hợp đó, nó được đảm bảo
gói đó cũng được gắn thẻ VLAN với ID VLAN mà cầu đã xử lý
gói này vào. Phần cứng có trách nhiệm gỡ thẻ VID trên
các cổng không được gắn thẻ đầu ra hoặc giữ thẻ trên các cổng được gắn thẻ đầu ra.

- ZZ0000ZZ: chức năng lớp cầu được gọi khi một cổng chuyển mạch nhất định được kích hoạt
  được thêm vào bridge, chức năng này sẽ thực hiện những gì cần thiết tại switch
  mức cho phép cổng tham gia được thêm vào logic liên quan
  miền để nó có thể truy cập vào/ra lưu lượng truy cập với các thành viên khác của bridge.
  Bằng cách đặt đối số ZZ0001ZZ thành true, quá trình chuyển tiếp TX
  của cây cầu này cũng được giảm tải.

- ZZ0000ZZ: chức năng lớp cầu được gọi khi một cổng chuyển mạch nhất định được kích hoạt
  bị xóa khỏi cầu, chức năng này sẽ thực hiện những gì cần thiết tại
  mức chuyển đổi để từ chối cổng rời khỏi lưu lượng truy cập vào/ra từ cổng
  thành viên cầu còn lại.

- ZZ0000ZZ: chức năng lớp cầu nối được gọi khi một cổng chuyển mạch nhất định STP
  trạng thái được tính toán bởi lớp cầu và cần được truyền bá sang chuyển mạch
  phần cứng để chuyển tiếp/chặn/tìm hiểu lưu lượng.

- ZZ0000ZZ: chức năng lớp cầu được gọi khi một cổng phải
  định cấu hình cài đặt của nó, ví dụ: tràn ngập lưu lượng truy cập hoặc địa chỉ nguồn không xác định
  học tập. Trình điều khiển chuyển đổi chịu trách nhiệm thiết lập ban đầu của
  các cổng độc lập bị vô hiệu hóa khả năng học địa chỉ và tràn ngập tất cả các cổng
  loại lưu lượng truy cập thì lõi DSA sẽ thông báo về bất kỳ thay đổi nào đối với cổng cầu
  cờ khi cảng tham gia và rời khỏi một cây cầu. DSA hiện không quản lý
  cờ cổng cầu cho cổng CPU. Giả định là địa chỉ đó
  việc học phải được kích hoạt tĩnh (nếu được phần cứng hỗ trợ) trên
  Cổng CPU và tính năng tràn về phía cổng CPU cũng phải được bật do
  thiếu cơ chế lọc địa chỉ rõ ràng trong lõi DSA.

- ZZ0000ZZ: chức năng lớp cầu được gọi khi xóa
  Các mục nhập FDB được học động trên cổng là cần thiết. Điều này được gọi khi
  chuyển từ trạng thái STP nơi việc học sẽ diễn ra sang STP
  nêu rõ nơi nào không nên làm, hoặc khi rời cầu, hoặc khi giải quyết việc học
  được tắt thông qua ZZ0001ZZ.

Lọc cầu VLAN
---------------------

- ZZ0000ZZ: chức năng lớp cầu được gọi khi cầu được
  được định cấu hình để bật hoặc tắt tính năng lọc VLAN. Nếu không có gì cụ thể cần
  được thực hiện ở cấp độ phần cứng, cuộc gọi lại này không cần phải được thực hiện.
  Khi tính năng lọc VLAN được bật, phần cứng phải được lập trình với
  từ chối các khung 802.1Q có ID VLAN nằm ngoài phạm vi cho phép được lập trình
  Bản đồ/quy tắc ID VLAN.  Nếu không có PVID được lập trình vào cổng chuyển đổi,
  các khung không được gắn thẻ cũng phải bị từ chối. Khi tắt công tắc phải
  chấp nhận bất kỳ khung 802.1Q nào bất kể ID VLAN của chúng và các khung không được gắn thẻ là
  được phép.

- ZZ0000ZZ: chức năng lớp cầu nối được gọi khi VLAN được cấu hình
  (được gắn thẻ hoặc không được gắn thẻ) cho cổng chuyển đổi nhất định. Cổng CPU trở thành thành viên
  của VLAN chỉ khi một cảng cầu nước ngoài cũng là thành viên của nó (và
  việc chuyển tiếp cần diễn ra trong phần mềm) hoặc VLAN được cài đặt vào
  Nhóm VLAN của chính thiết bị cầu nối, nhằm mục đích chấm dứt
  (ZZ0001ZZ). Vlan trên các cổng chia sẻ là
  tham chiếu được tính và xóa khi không còn người dùng. Trình điều khiển không cần
  để cài đặt thủ công VLAN trên cổng CPU.

- ZZ0000ZZ: chức năng lớp cầu nối được gọi khi VLAN bị xóa khỏi
  cổng chuyển đổi nhất định

- ZZ0000ZZ: chức năng lớp cầu được gọi khi cầu muốn cài đặt một
  Mục nhập Cơ sở dữ liệu chuyển tiếp, phần cứng chuyển mạch phải được lập trình với
  địa chỉ được chỉ định trong Id VLAN được chỉ định trong cơ sở dữ liệu chuyển tiếp
  được liên kết với ID VLAN này.

- ZZ0000ZZ: chức năng lớp cầu được gọi khi cầu muốn loại bỏ một
  Chuyển tiếp mục nhập Cơ sở dữ liệu, phần cứng chuyển mạch cần được lập trình để xóa
  địa chỉ MAC được chỉ định từ ID VLAN được chỉ định nếu nó được ánh xạ vào
  cơ sở dữ liệu chuyển tiếp cổng này

- ZZ0000ZZ: chức năng bỏ qua cầu được ZZ0001ZZ gọi trên
  giao diện cổng DSA vật lý. Vì DSA không cố gắng giữ đồng bộ nên nó
  các mục FDB phần cứng với cầu nối phần mềm, phương pháp này được triển khai như
  một phương tiện để xem các mục hiển thị trên cổng người dùng trong cơ sở dữ liệu phần cứng.
  Các mục được báo cáo bởi chức năng này có cờ ZZ0002ZZ ở đầu ra của
  lệnh ZZ0003ZZ.

- ZZ0000ZZ: chức năng lớp cầu được gọi khi cầu muốn cài đặt
  một mục nhập cơ sở dữ liệu multicast. Phần cứng của switch nên được lập trình với
  địa chỉ được chỉ định trong ID VLAN được chỉ định trong cơ sở dữ liệu chuyển tiếp
  được liên kết với ID VLAN này.

- ZZ0000ZZ: chức năng lớp cầu được gọi khi cầu muốn loại bỏ một
  mục nhập cơ sở dữ liệu multicast, phần cứng của switch phải được lập trình để xóa
  địa chỉ MAC được chỉ định từ ID VLAN được chỉ định nếu nó được ánh xạ vào
  cơ sở dữ liệu chuyển tiếp cổng này.

Tổng hợp liên kết
-----------------

Tập hợp liên kết được triển khai trong ngăn xếp mạng Linux bằng liên kết
và trình điều khiển nhóm, được mô hình hóa dưới dạng giao diện mạng ảo, có thể xếp chồng lên nhau.
DSA có khả năng giảm tải nhóm tổng hợp liên kết (LAG) sang phần cứng
hỗ trợ tính năng này và hỗ trợ kết nối giữa các cổng vật lý và LAG,
cũng như giữa các LAG. Giao diện liên kết/nhóm chứa nhiều
các cổng tạo thành một cổng logic, mặc dù DSA không có khái niệm rõ ràng về cổng
cổng logic vào thời điểm hiện tại. Do đó, các sự kiện trong đó LAG tham gia/rời khỏi
cầu được xử lý như thể tất cả các cổng vật lý riêng lẻ là thành viên của cầu đó
LAG tham gia/rời cầu. Thuộc tính cổng Switchdev (lọc VLAN, STP
trạng thái, v.v.) và các đối tượng (Vlan, mục nhập MDB) được tải xuống LAG dưới dạng cổng cầu nối
được xử lý tương tự: DSA giảm tải cùng thuộc tính cổng/đối tượng switchdev
trên tất cả các thành viên của LAG. Chưa có mục nhập cầu tĩnh FDB trên LAG
được hỗ trợ, vì trình điều khiển DSA API không có khái niệm về cổng logic
ID.

- ZZ0000ZZ: chức năng được gọi khi một cổng chuyển đổi nhất định được thêm vào
  LAG. Trình điều khiển có thể trả về ZZ0001ZZ và trong trường hợp này, DSA sẽ bị loại
  quay lại triển khai phần mềm trong đó tất cả lưu lượng truy cập từ cổng này được gửi đến
  CPU.
- ZZ0002ZZ: chức năng được gọi khi một cổng chuyển mạch nhất định rời khỏi LAG
  và trở lại hoạt động như một cổng độc lập.
- ZZ0003ZZ: hàm được gọi khi trạng thái liên kết của bất kỳ thành viên nào trong
  LAG thay đổi và hàm băm cần cân bằng lại để chỉ sử dụng
  của tập hợp con các cổng thành viên LAG vật lý đang hoạt động.

Trình điều khiển được hưởng lợi từ việc có ID được liên kết với mỗi LAG được giảm tải
có thể tùy chọn điền ZZ0000ZZ từ ZZ0001ZZ
phương pháp. Sau đó, ID LAG được liên kết với giao diện nhóm/liên kết có thể được
được truy xuất bởi trình điều khiển chuyển đổi DSA bằng chức năng ZZ0002ZZ.

IEC 62439-2 (MRP)
-----------------

Giao thức dự phòng đa phương tiện là giao thức quản lý cấu trúc liên kết được tối ưu hóa cho
thời gian phục hồi lỗi nhanh cho mạng vòng, trong đó có một số thành phần
được thực hiện như một chức năng của trình điều khiển cầu. MRP sử dụng PDU quản lý
(Kiểm tra, Cấu trúc liên kết, LinkDown/Up, Tùy chọn) được gửi tại đích phát đa hướng MAC
phạm vi địa chỉ là 01:15:4e:00:00:0x và với EtherType là 0x88e3.
Tùy thuộc vào vai trò của nút trong vòng (MRM: Trình quản lý dự phòng phương tiện,
MRC: Máy khách dự phòng phương tiện, MRA: Trình quản lý tự động dự phòng phương tiện), một số MRP
Các PDU có thể cần phải được chấm dứt cục bộ và các PDU khác có thể cần được chuyển tiếp.
MRM cũng có thể được hưởng lợi từ việc giảm tải cho phần cứng để tạo và
truyền một số PDU MRP nhất định (Thử nghiệm).

Thông thường, một phiên bản MRP có thể được tạo trên bất kỳ giao diện mạng nào,
tuy nhiên, trong trường hợp thiết bị có đường dẫn dữ liệu được giảm tải như DSA, thì đó là
cần thiết cho phần cứng, ngay cả khi nó không nhận biết được MRP, để có thể giải nén
PDU MRP từ kết cấu trước khi trình điều khiển có thể tiếp tục với phần mềm
thực hiện. DSA ngày nay không có trình điều khiển nhận biết MRP, do đó nó chỉ
lắng nghe các đối tượng switchdev tối thiểu cần thiết để hỗ trợ phần mềm
để làm việc đúng cách. Các hoạt động được trình bày chi tiết dưới đây.

- ZZ0000ZZ và ZZ0001ZZ: thông báo cho trình điều khiển khi có phiên bản MRP
  với một ID vòng nhất định, mức độ ưu tiên, cổng chính và cổng phụ là
  được tạo/xóa.
- ZZ0002ZZ và ZZ0003ZZ: hàm được gọi
  khi một phiên bản MRP thay đổi vai trò vòng giữa MRM hoặc MRC. Điều này ảnh hưởng
  PDU MRP nào sẽ được giữ vào phần mềm và PDU nào sẽ được tự động
  chuyển tiếp.

IEC 62439-3 (HSR/PRP)
---------------------

Giao thức dự phòng song song (PRP) là giao thức dự phòng mạng
hoạt động bằng cách sao chép và đánh số thứ tự các gói thông qua hai L2 độc lập
các mạng (không biết về thẻ đuôi PRP có trong các gói) và
loại bỏ các bản sao ở máy thu. Tính sẵn sàng cao liền mạch
Giao thức dự phòng (HSR) có khái niệm tương tự, ngoại trừ tất cả các nút mang
lưu lượng dư thừa biết rằng nó được gắn thẻ HSR (vì HSR
sử dụng tiêu đề có EtherType là 0x892f) và được kết nối vật lý trong một
cấu trúc liên kết vòng. Cả HSR và PRP đều sử dụng khung giám sát để giám sát
tình trạng của mạng và để khám phá các nút khác.

Trong Linux, cả HSR và PRP đều được triển khai trong trình điều khiển hsr.
khởi tạo một giao diện mạng ảo, có thể xếp chồng lên nhau với hai cổng thành viên.
Trình điều khiển chỉ thực hiện các vai trò cơ bản của DANH (Nút đính kèm đôi
triển khai HSR), DANP (Nút đính kèm kép triển khai PRP) và RedBox
(cho phép các thiết bị không phải HSR kết nối với vòng thông qua cổng Interlink).

Trình điều khiển có khả năng giảm tải một số chức năng nhất định phải khai báo
các tính năng netdev tương ứng như được chỉ ra bởi tài liệu tại
ZZ0000ZZ. Ngoài ra, sau đây
phải thực hiện các phương pháp:

- ZZ0000ZZ: chức năng được gọi khi một cổng chuyển đổi nhất định được thêm vào
  DANP/DANH. Trình điều khiển có thể trả về ZZ0001ZZ và trong trường hợp này, DSA sẽ
  quay lại triển khai phần mềm trong đó tất cả lưu lượng truy cập từ cổng này được
  được gửi đến CPU.
- ZZ0002ZZ: chức năng được gọi khi một cổng chuyển mạch nhất định rời khỏi cổng
  DANP/DANH và trở lại hoạt động bình thường dưới dạng một cổng độc lập.

Lưu ý rằng tính năng ZZ0000ZZ dựa vào việc truyền tới
nhiều cổng, thường có sẵn bất cứ khi nào giao thức gắn thẻ sử dụng
chức năng trợ giúp ZZ0001ZZ. Nếu người trợ giúp được sử dụng, HSR
tính năng giảm tải cũng nên được thiết lập. ZZ0002ZZ và
Các phương thức ZZ0003ZZ có thể được sử dụng làm triển khai chung
của ZZ0004ZZ và ZZ0005ZZ, nếu đây là phiên bản duy nhất được hỗ trợ
tính năng giảm tải.

TODO
====

Làm cho SWITCHDEV và DSA hội tụ hướng tới một cơ sở mã thống nhất
-----------------------------------------------------------------

SWITCHDEV xử lý đúng cách việc trừu tượng hóa ngăn xếp mạng bằng giảm tải
phần cứng có khả năng, nhưng không thực thi mô hình trình điều khiển thiết bị chuyển mạch nghiêm ngặt. Bật
DSA khác thực thi mô hình trình điều khiển thiết bị khá nghiêm ngặt và xử lý hầu hết
của công tắc cụ thể. Tại một thời điểm nào đó chúng ta nên hình dung ra sự hợp nhất giữa những
hai hệ thống con và tận dụng tối đa cả hai hệ thống.
