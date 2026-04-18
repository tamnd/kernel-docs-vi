.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/representors.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _representors:

================================
Đại diện chức năng mạng
=============================

Tài liệu này mô tả ngữ nghĩa và cách sử dụng các thiết bị mạng đại diện, như
được sử dụng để kiểm soát chuyển đổi nội bộ trên SmartNIC.  Đối với cảng có quan hệ mật thiết
đại diện trên các thiết bị chuyển mạch vật lý (đa cổng), xem
ZZ0000ZZ.

Động lực
----------

Kể từ giữa những năm 2010, card mạng đã bắt đầu cung cấp các giải pháp phức tạp hơn
khả năng ảo hóa hơn so với phương pháp SR-IOV truyền thống (với cách tiếp cận đơn giản
Mô hình chuyển mạch dựa trên MAC/VLAN) có thể hỗ trợ.  Điều này dẫn đến mong muốn giảm tải
các mạng được xác định bằng phần mềm (chẳng hạn như OpenVSwitch) tới các NIC này để chỉ định
kết nối mạng của từng chức năng.  Các thiết kế kết quả là khác nhau
được gọi là SmartNIC hoặc DPU.

Các đại diện chức năng mạng mang ngăn xếp mạng Linux tiêu chuẩn đến
thiết bị chuyển mạch ảo và thiết bị IOV.  Giống như mỗi cổng vật lý của Linux-
switch được điều khiển có một netdev riêng, mỗi cổng ảo của một switch ảo cũng vậy
chuyển đổi.
Khi hệ thống khởi động và trước khi bất kỳ hoạt động giảm tải nào được cấu hình, tất cả các gói từ
các chức năng ảo xuất hiện trong ngăn xếp mạng của PF thông qua
đại diện.  Do đó, PF luôn có thể giao tiếp tự do với mạng ảo
chức năng.
PF có thể định cấu hình chuyển tiếp Linux tiêu chuẩn giữa các đại diện, đường lên
hoặc bất kỳ netdev nào khác (định tuyến, bắc cầu, phân loại TC).

Vì vậy, một đại diện vừa là một đối tượng mặt phẳng điều khiển (biểu diễn hàm trong
lệnh quản trị) và đối tượng mặt phẳng dữ liệu (một đầu của đường ống ảo).
Là điểm cuối liên kết ảo, trình đại diện có thể được cấu hình giống như bất kỳ điểm cuối nào khác
thiết bị mạng; trong một số trường hợp (ví dụ: trạng thái liên kết), người đại diện sẽ tuân theo
cấu hình của người đại diện, trong khi ở những cấu hình khác có các API riêng biệt để
cấu hình người đại diện.

định nghĩa
-----------

Tài liệu này sử dụng thuật ngữ "chức năng switchdev" để chỉ chức năng PCIe
which has administrative control over the virtual switch on the device.
Thông thường, đây sẽ là một PF, nhưng có thể hình dung NIC có thể được cấu hình để cấp
thay vào đó, các đặc quyền quản trị này chuyển sang VF hoặc SF (chức năng con).
Tùy thuộc vào thiết kế NIC, NIC nhiều cổng có thể có một chức năng switchdev duy nhất
cho toàn bộ thiết bị hoặc có thể có một công tắc ảo riêng và do đó
chức năng switchdev, cho mỗi cổng mạng vật lý.
Nếu NIC hỗ trợ chuyển mạch lồng nhau, có thể có switchdev riêng
các hàm cho mỗi switch lồng nhau, trong trường hợp đó mỗi hàm switchdev sẽ
chỉ tạo đại diện cho các cổng trên (phụ) chuyển đổi trực tiếp
quản lý.

“Người đại diện” là đối tượng mà người đại diện đại diện.  Vì vậy, ví dụ như trong
trường hợp đại diện VF thì người đại diện là VF tương ứng.

Người đại diện làm gì?
---------------------------

Một người đại diện có ba vai trò chính.

1. Nó được sử dụng để định cấu hình kết nối mạng mà người đại diện nhìn thấy, ví dụ:
   liên kết lên/xuống, MTU, v.v. Ví dụ: đưa người đại diện
   về mặt hành chính UP sẽ khiến người đại diện nhìn thấy liên kết lên / nhà cung cấp dịch vụ
   về sự kiện.
2. Nó cung cấp đường dẫn chậm cho lưu lượng truy cập không bị giảm tải
   quy tắc đường đi nhanh trong switch ảo.  Các gói được truyền trên
   netdevice đại diện phải được giao cho người đại diện; gói
   được truyền bởi người đại diện không phù hợp với bất kỳ quy tắc chuyển đổi nào sẽ
   được nhận trên netdevice đại diện.  (Tức là có một ống ảo
   kết nối người đại diện với người được đại diện, có khái niệm tương tự như veth
   cặp.)
   Điều này cho phép triển khai chuyển đổi phần mềm (chẳng hạn như OpenVSwitch hoặc Linux
   bridge) để chuyển tiếp các gói tin giữa người được đại diện và phần còn lại của mạng.
3. Nó hoạt động như một công cụ điều khiển để các quy tắc chuyển đổi (chẳng hạn như bộ lọc TC) có thể tham chiếu
   cho người đại diện, cho phép các quy tắc này được giảm tải.

Sự kết hợp của 2) và 3) có nghĩa là hành vi (ngoài hiệu suất)
phải giống nhau cho dù bộ lọc TC có được giảm tải hay không.  Ví dụ. quy tắc TC
trên bộ đại diện VF áp dụng trong phần mềm cho các gói nhận được trên bộ đại diện đó
netdevice, trong khi giảm tải phần cứng, nó sẽ áp dụng cho các gói được truyền bởi
người đại diện VF.  Ngược lại, chuyển hướng đi ra được nhân đôi tới đại diện VF
tương ứng về mặt phần cứng với việc giao hàng trực tiếp tới VF của người đại diện.

Những chức năng nào nên có một đại diện?
-----------------------------------------

Về cơ bản, đối với mỗi cổng ảo trên switch bên trong của thiết bị, có
phải là người đại diện.
Một số nhà cung cấp đã chọn bỏ qua các đại diện cho đường lên và đường truyền vật lý
cổng mạng, có thể đơn giản hóa việc sử dụng (netdev đường lên có hiệu lực
đại diện của cổng vật lý) nhưng không khái quát hóa cho các thiết bị có nhiều
cổng hoặc đường lên.

Vì vậy, tất cả những điều sau đây nên có người đại diện:

- VF thuộc hàm switchdev.
 - Các PF khác trên bộ điều khiển PCIe cục bộ và bất kỳ VF nào thuộc về chúng.
 - PF và VF trên bộ điều khiển PCIe bên ngoài trên thiết bị (ví dụ: đối với mọi thiết bị nhúng
   Hệ thống trên chip trong SmartNIC).
 - PF và VF có các tính cách khác, bao gồm các thiết bị chặn mạng (chẳng hạn như
   dưới dạng vDPA virtio-blk PF được hỗ trợ bởi bộ lưu trữ từ xa/phân phối), nếu (và chỉ
   nếu) việc truy cập mạng của họ được thực hiện thông qua cổng chuyển mạch ảo. [#]_
   Lưu ý rằng các chức năng như vậy có thể yêu cầu một người đại diện mặc dù người đại diện
   không có netdev.
 - Các chức năng con (SF) thuộc bất kỳ PF hoặc VF nào ở trên, nếu chúng có
   cổng riêng của họ trên switch (ngược lại với việc sử dụng cổng của PF mẹ).
 - Bất kỳ trình tăng tốc hoặc plugin nào trên thiết bị có giao diện với mạng
   thông qua cổng chuyển đổi ảo, ngay cả khi chúng không có PCIe tương ứng
   PF hoặc VF.

Điều này cho phép kiểm soát toàn bộ hành vi chuyển đổi của NIC thông qua
quy tắc TC đại diện.

Đó là một sự hiểu lầm phổ biến khi kết hợp các cổng ảo với cổng ảo PCIe
chức năng hoặc netdevs của họ.  Trong khi trong những trường hợp đơn giản sẽ có tỷ lệ 1:1
sự tương ứng giữa các thiết bị mạng VF và đại diện VF, thiết bị tiên tiến hơn
cấu hình có thể không tuân theo điều này.
Chức năng PCIe không có quyền truy cập mạng thông qua bộ chuyển mạch bên trong
(thậm chí không gián tiếp thông qua việc triển khai phần cứng của bất kỳ dịch vụ nào
chức năng cung cấp) nếu ZZ0000ZZ có một đại diện (ngay cả khi nó có một
netdev).
Chức năng như vậy không có cổng ảo chuyển đổi để người đại diện định cấu hình hoặc
là đầu kia của đường ống ảo.
Đại diện đại diện cho cổng ảo, không phải chức năng PCIe cũng như 'end'
netdevice của người dùng.

.. [#] The concept here is that a hardware IP stack in the device performs the
   translation between block DMA requests and network packets, so that only
   network packets pass through the virtual port onto the switch.  The network
   access that the IP stack "sees" would then be configurable through tc rules;
   e.g. its traffic might all be wrapped in a specific VLAN or VxLAN.  However,
   any needed configuration of the block device *qua* block device, not being a
   networking entity, would not be appropriate for the representor and would
   thus use some other channel such as devlink.
   Contrast this with the case of a virtio-blk implementation which forwards the
   DMA requests unchanged to another PF whose driver then initiates and
   terminates IP traffic in software; in that case the DMA traffic would *not*
   run over the virtual switch and the virtio-blk PF should thus *not* have a
   representor.

Người đại diện được tạo ra như thế nào?
-----------------------------

Phiên bản trình điều khiển được gắn vào hàm switchdev, đối với mỗi phiên bản ảo, sẽ
trên switch, tạo một thiết bị mạng thuần phần mềm có một số dạng
tham chiếu trong kernel tới netdevice hoặc trình điều khiển riêng của hàm switchdev
dữ liệu (ZZ0000ZZ).
Điều này có thể bằng cách liệt kê các cổng tại thời điểm thăm dò, phản ứng linh hoạt với
tạo và phá hủy các cổng trong thời gian chạy hoặc kết hợp cả hai.

Các hoạt động của netdevice đại diện nói chung sẽ liên quan đến việc thực hiện
thông qua hàm switchdev.  Ví dụ: ZZ0000ZZ có thể gửi
gói thông qua hàng đợi TX phần cứng được gắn với chức năng switchdev, với
siêu dữ liệu gói hoặc cấu hình hàng đợi đánh dấu nó để phân phối đến
người đại diện.

Người đại diện được xác định như thế nào?
--------------------------------

Netdevice đại diện phải là ZZ0008ZZ trực tiếp đề cập đến thiết bị PCIe (ví dụ:
thông qua ZZ0001ZZ / ZZ0002ZZ), một trong hai
người đại diện hoặc của hàm switchdev.
Thay vào đó, trình điều khiển nên sử dụng macro ZZ0003ZZ để
gán một phiên bản cổng devlink cho netdevice trước khi đăng ký
thiết bị mạng; kernel sử dụng cổng devlink để cung cấp ZZ0004ZZ
và các nút sysfs ZZ0005ZZ.
(Một số trình điều khiển cũ triển khai ZZ0006ZZ và
trực tiếp ZZ0007ZZ, nhưng điều này không được dùng nữa.) Xem
ZZ0000ZZ dành cho
chi tiết của API này.

Dự kiến vùng người dùng sẽ sử dụng thông tin này (ví dụ: thông qua các quy tắc udev)
để xây dựng một tên hoặc bí danh có thông tin thích hợp cho thiết bị mạng.  cho
Ví dụ, nếu hàm switchdev là ZZ0000ZZ thì một đại diện có
ZZ0001ZZ của ZZ0002ZZ có thể được đổi tên thành ZZ0003ZZ.

Vẫn chưa có quy ước nào được thiết lập để đặt tên cho người đại diện mà không
tương ứng với các chức năng PCIe (ví dụ: bộ tăng tốc và phần bổ trợ).

Người đại diện tương tác với quy tắc TC như thế nào?
-------------------------------------------

Bất kỳ quy tắc TC nào trên bộ đại diện đều áp dụng (trong TC phần mềm) cho các gói được nhận bởi
đại diện netdevice đó.  Vì vậy, nếu phần phân phối của quy tắc tương ứng
sang một cổng khác trên switch ảo, trình điều khiển có thể chọn chuyển nó sang
phần cứng, áp dụng nó vào các gói được truyền bởi người đại diện.

Tương tự, vì một hành động đầu ra được nhân bản TC nhắm mục tiêu vào người đại diện sẽ (trong
mềm) gửi gói thông qua người đại diện (và do đó gián tiếp phân phối
cho người được đại diện), việc giảm tải phần cứng sẽ được hiểu là việc chuyển giao tới
người đại diện.

Một ví dụ đơn giản, nếu ZZ0000ZZ là đại diện cổng vật lý và
ZZ0001ZZ là đại diện VF, các quy tắc sau::

bộ lọc tc thêm dev $REP_DEV cha mẹ ffff: giao thức ipv4 hoa \
        hành động chuyển hướng đi ra được nhân đôi của nhà phát triển $PORT_DEV
    bộ lọc tc thêm dev $PORT_DEV cha mẹ ffff: giao thức ipv4 hoa Skip_sw \
        nhà phát triển gương đi ra được nhân đôi hành động $REP_DEV

có nghĩa là tất cả các gói IPv4 từ VF đều được gửi ra cổng vật lý và
tất cả các gói IPv4 nhận được trên cổng vật lý sẽ được gửi đến VF trong
ngoài ZZ0000ZZ.  (Lưu ý rằng nếu không có ZZ0001ZZ ở quy tắc thứ hai,
VF sẽ nhận được hai bản sao, giống như việc nhận gói trên ZZ0002ZZ sẽ
kích hoạt lại quy tắc TC và phản chiếu gói tới ZZ0003ZZ.)

Trên các thiết bị không có cổng đại diện và đường lên riêng biệt, ZZ0000ZZ sẽ
thay vào đó hãy là netdevice đường lên của chính hàm switchdev.

Tất nhiên các quy tắc có thể (nếu được NIC hỗ trợ) bao gồm việc sửa đổi gói
các hành động (ví dụ: đẩy/bật VLAN), phải được thực hiện bằng công tắc ảo.

Việc đóng gói và giải mã đường hầm khá phức tạp hơn vì chúng
liên quan đến thiết bị mạng thứ ba (một netdev đường hầm hoạt động ở chế độ siêu dữ liệu, chẳng hạn như
một thiết bị VxLAN được tạo bằng ZZ0000ZZ) và
yêu cầu địa chỉ IP được liên kết với thiết bị cơ sở (ví dụ: switchdev
chức năng đường lên netdev hoặc đại diện cổng).  Các quy tắc TC như::

bộ lọc tc thêm dev $REP_DEV cha mẹ ffff: hoa \
        hành động đường hầm_key đặt id $VNI src_ip $LOCAL_IP dst_ip $REMOTE_IP \
                              dst_port 4789 \
        hành động chuyển hướng đi ra được nhân đôi dev vxlan0
    bộ lọc tc thêm dev vxlan0 cha mẹ ffff: hoa enc_src_ip $REMOTE_IP \
        enc_dst_ip $LOCAL_IP enc_key_id $VNI enc_dst_port 4789 \
        hành động đường hầm_key hủy đặt hành động chuyển hướng đi ra được nhân đôi của nhà phát triển $REP_DEV

trong đó ZZ0000ZZ là địa chỉ IP được liên kết với ZZ0001ZZ và ZZ0002ZZ là
một địa chỉ IP khác trên cùng mạng con, có nghĩa là các gói được gửi bởi VF sẽ
được đóng gói VxLAN và gửi ra cổng vật lý (trình điều khiển phải suy ra
điều này bằng cách tra cứu tuyến đường của ZZ0003ZZ dẫn đến ZZ0004ZZ, đồng thời
thực hiện tra cứu ARP/bảng lân cận để tìm địa chỉ MAC để sử dụng trong
khung Ethernet bên ngoài), trong khi các gói UDP nhận được trên cổng vật lý với UDP
cổng 4789 phải được phân tích cú pháp dưới dạng VxLAN và nếu VSID của chúng khớp với ZZ0005ZZ,
được giải mã và chuyển tiếp đến VF.

Nếu tất cả điều này có vẻ phức tạp, chỉ cần nhớ 'quy tắc vàng' của việc giảm tải TC:
phần cứng phải đảm bảo kết quả cuối cùng giống như khi các gói được
được xử lý thông qua đường dẫn chậm, đi qua phần mềm TC (ngoại trừ việc bỏ qua bất kỳ
quy tắc ZZ0000ZZ và áp dụng bất kỳ quy tắc ZZ0001ZZ nào) và được truyền hoặc
nhận được thông qua netdevices đại diện.

Định cấu hình MAC của người đại diện
---------------------------------

Trạng thái liên kết của người đại diện được kiểm soát thông qua người đại diện.  Thiết lập
người đại diện về mặt hành chính UP hoặc DOWN sẽ khiến nhà cung cấp dịch vụ ON hoặc OFF tại
người đại diện.

Việc đặt MTU trên bộ đại diện sẽ khiến MTU tương tự được báo cáo cho
người đại diện.
(Trên phần cứng cho phép định cấu hình các giá trị MTU và MRU riêng biệt và khác biệt,
người đại diện MTU phải tương ứng với MRU của người đại diện và ngược lại.)

Hiện tại không có cách nào để sử dụng người đại diện để đặt trạm vĩnh viễn
Địa chỉ MAC của người đại diện; các phương pháp khác có sẵn để làm điều này bao gồm:

- di sản SR-IOV (ZZ0001ZZ)
 - chức năng cổng devlink (xem ZZ0002ZZ và
   ZZ0000ZZ)