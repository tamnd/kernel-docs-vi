.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/intel/iavf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================================================================
Trình điều khiển cơ sở Linux cho chức năng ảo thích ứng Ethernet Intel(R)
=================================================================

Trình điều khiển Linux chức năng ảo thích ứng Intel Ethernet.
Bản quyền(c) 2013-2018 Tập đoàn Intel.

Nội dung
========

- Tổng quan
- Xác định bộ chuyển đổi của bạn
- Cấu hình bổ sung
- Các vấn đề đã biết/Xử lý sự cố
- Hỗ trợ

Tổng quan
========

Tệp này mô tả Trình điều khiển cơ sở Linux iavf. Người lái xe này trước đây
được gọi là i40evf.

Trình điều khiển iavf hỗ trợ các thiết bị chức năng ảo được đề cập bên dưới và
chỉ có thể được kích hoạt trên các hạt nhân chạy i40e hoặc mới hơn
(PF) được biên dịch bằng CONFIG_PCI_IOV.  Trình điều khiển iavf yêu cầu
CONFIG_PCI_MSI sẽ được kích hoạt.

Hệ điều hành khách tải trình điều khiển iavf phải hỗ trợ các ngắt MSI-X.

Xác định bộ điều hợp của bạn
========================

Trình điều khiển trong kernel này tương thích với các thiết bị dựa trên:
 * Chức năng ảo Intel(R) XL710 X710
 * Chức năng ảo Intel(R) X722
 * Chức năng ảo Intel(R) XXV710
 * Chức năng ảo thích ứng Ethernet Intel(R)

Để có hiệu suất tốt nhất, hãy đảm bảo cài đặt NVM/FW mới nhất trên máy tính của bạn
thiết bị.

Để biết thông tin về cách xác định bộ chuyển đổi của bạn và về NVM/FW mới nhất
hình ảnh và trình điều khiển mạng Intel, hãy tham khảo trang web Hỗ trợ Intel:
ZZ0000ZZ


Các tính năng và cấu hình bổ sung
======================================

Xem tin nhắn liên kết
---------------------
Thông báo liên kết sẽ không được hiển thị trên bảng điều khiển nếu việc phân phối
hạn chế tin nhắn hệ thống. Để xem thông báo liên kết trình điều khiển mạng trên
bảng điều khiển của bạn, hãy đặt dmesg thành 8 bằng cách nhập thông tin sau::

# dmesg-n 8

NOTE:
  Cài đặt này không được lưu trong các lần khởi động lại.

công cụ đạo đức
-------
Trình điều khiển sử dụng giao diện ethtool để cấu hình trình điều khiển và
chẩn đoán cũng như hiển thị thông tin thống kê. Công cụ đạo đức mới nhất
Phiên bản này là cần thiết cho chức năng này. Tải xuống tại:
ZZ0000ZZ

Cài đặt tước thẻ VLAN
--------------------------
Nếu bạn có các ứng dụng yêu cầu Chức năng ảo (VF) để nhận
các gói có thẻ VLAN, bạn có thể tắt tính năng tước thẻ VLAN cho VF. các
Chức năng Vật lý (PF) xử lý các yêu cầu được đưa ra từ VF để kích hoạt hoặc
vô hiệu hóa việc tước thẻ VLAN. Lưu ý rằng nếu PF đã gán VLAN cho VF,
thì yêu cầu từ VF đó để thiết lập tính năng tước thẻ VLAN sẽ bị bỏ qua.

Để bật/tắt tính năng tước thẻ VLAN cho VF, hãy đưa ra lệnh sau
từ bên trong VM nơi bạn đang chạy VF::

# ethtool -K <if_name> bật/tắt rxvlan

hoặc cách khác::

# ethtool --offload <if_name> bật/tắt rxvlan

Chức năng ảo thích ứng
-------------------------
Chức năng ảo thích ứng (AVF) cho phép trình điều khiển chức năng ảo hoặc VF
thích ứng với việc thay đổi bộ tính năng của trình điều khiển chức năng vật lý (PF) mà
nó được liên kết. Điều này cho phép quản trị viên hệ thống cập nhật PF mà không cần
phải cập nhật tất cả các VF liên quan đến nó. Tất cả các AVF đều có một điểm chung duy nhất
ID thiết bị và chuỗi nhãn hiệu.

AVF có một bộ tính năng tối thiểu được gọi là "chế độ cơ bản", nhưng có thể cung cấp
các tính năng bổ sung tùy thuộc vào những tính năng nào có sẵn trong PF với
mà AVF được liên kết. Sau đây là các tính năng của chế độ cơ bản:

- 4 cặp hàng đợi (QP) và các thanh ghi trạng thái cấu hình (CSR) liên quan
  cho Tx/Rx
- mô tả i40e và định dạng vòng
- Hoàn thành việc ghi lại bộ mô tả
- 1 hàng đợi điều khiển, với bộ mô tả i40e, CSR và định dạng chuông
- 5 vectơ ngắt MSI-X và CSR i40e tương ứng
- Chỉ số 1 ngắt ga (ITR)
- 1 Giao diện trạm ảo (VSI) trên mỗi VF
- 1 loại lưu lượng (TC), TC0
- Nhận Side Scaling (RSS) với 64 bảng và khóa hướng dẫn nhập,
  được cấu hình thông qua PF
- 1 địa chỉ unicast MAC dành riêng cho mỗi VF
- 16 bộ lọc địa chỉ MAC cho mỗi VF
- Giảm tải không trạng thái - tổng kiểm tra không có đường hầm
- ID thiết bị AVF
- Hộp thư HW được sử dụng để liên lạc từ VF đến PF (bao gồm cả trên Windows)

Hỗ trợ IEEE 802.1ad (QinQ)
---------------------------
Tiêu chuẩn IEEE 802.1ad, được gọi một cách không chính thức là QinQ, cho phép nhiều VLAN
ID trong một khung Ethernet duy nhất. ID VLAN đôi khi được gọi là
Do đó, "thẻ" và nhiều ID VLAN được gọi là "ngăn xếp thẻ". Ngăn xếp thẻ
cho phép tạo đường hầm L2 và khả năng phân chia lưu lượng trong một phạm vi cụ thể
ID VLAN, cùng với các mục đích sử dụng khác.

Sau đây là ví dụ về cách định cấu hình 802.1ad (QinQ)::

Liên kết # ip thêm liên kết eth0 eth0.24 loại vlan proto 802.1ad id 24
    Liên kết # ip thêm liên kết eth0.24 eth0.24.371 loại vlan proto 802.1Q id 371

Trong đó "24" và "371" là ID VLAN mẫu.

NOTES:
  Không nhận được giảm tải tổng kiểm tra, bộ lọc đám mây và khả năng tăng tốc VLAN
  được hỗ trợ cho các gói 802.1ad (QinQ).

Hàng đợi thiết bị ứng dụng (ADq)
-------------------------------
Hàng đợi thiết bị ứng dụng (ADq) cho phép bạn dành một hoặc nhiều hàng đợi cho một
ứng dụng cụ thể. Điều này có thể giảm độ trễ cho ứng dụng được chỉ định,
và cho phép lưu lượng Tx bị giới hạn tốc độ cho mỗi ứng dụng. Thực hiện theo các bước dưới đây
để thiết lập ADq.

Yêu cầu:

- Phải tải các mô-đun sch_mqprio, Act_mirred và cls_flower
- Phiên bản mới nhất của iproute2
- Nếu trình điều khiển khác (ví dụ: DPDK) đã đặt bộ lọc đám mây thì bạn không thể
  kích hoạt ADQ
- Tùy thuộc vào thiết bị PF cơ bản, ADQ không thể được bật khi
  các tính năng sau được kích hoạt:

+ Cầu nối trung tâm dữ liệu (DCB)
  + Nhiều chức năng trên mỗi cổng (MFP)
  + Bộ lọc dải biên

1. Tạo các lớp lưu lượng truy cập (TC). Có thể tạo tối đa 8 TC trên mỗi giao diện.
Tham số bw_rlimit của bộ tạo hình là tùy chọn.

Ví dụ: Thiết lập hai tcs, tc0 và tc1, với mỗi hàng 16 hàng đợi và đặt tốc độ tx tối đa
đến 1Gbit cho tc0 và 3Gbit cho tc1.

::

tc qdisc thêm dev <interface> root mqprio num_tc 2 bản đồ 0 0 0 0 1 1 1 1
    hàng đợi 16@0 16@16 hw 1 chế độ định hình kênh bw_rlimit min_rate 1Gbit 2Gbit
    tốc độ tối đa 1Gbit 3Gbit

bản đồ: ánh xạ ưu tiên cho tối đa 16 mức độ ưu tiên cho tcs (ví dụ: bản đồ 0 0 0 0 1 1 1 1
đặt mức độ ưu tiên 0-3 để sử dụng tc0 và 4-7 để sử dụng tc1)

hàng đợi: với mỗi tc, <num queues>@<offset> (ví dụ: hàng đợi 16@0 16@16 được gán
16 hàng đợi tới tc0 ở offset 0 và 16 hàng đợi đến tc1 ở offset 16. Tổng tối đa
số hàng đợi cho tất cả tcs là 64 hoặc số lõi, tùy theo số nào thấp hơn.)

kênh chế độ hw 1: 'kênh' với 'hw' được đặt thành 1 là phần cứng mới mới
chế độ giảm tải trong mqprio sử dụng đầy đủ các tùy chọn mqprio,
TC, cấu hình hàng đợi và tham số QoS.

Shaper bw_rlimit: với mỗi tc, đặt tốc độ băng thông tối thiểu và tối đa.
Tổng số phải bằng hoặc nhỏ hơn tốc độ cổng.

Ví dụ: min_rate 1Gbit 3Gbit: Xác minh giới hạn băng thông sử dụng mạng
các công cụ giám sát như ZZ0000ZZ hoặc ZZ0001ZZ

NOTE:
  Thiết lập kênh qua ethtool (ethtool -L) không được hỗ trợ khi
  TC được định cấu hình bằng mqprio.

2. Kích hoạt tính năng giảm tải CTNH trên giao diện::

# ethtool -K <giao diện> bật hw-tc-offload

3. Áp dụng TC cho luồng giao diện đi vào (RX)::

# tc qdisc thêm lối vào dev <interface>

NOTES:
 - Chạy tất cả các lệnh tc từ thư mục iproute2 <pathtoiproute2>/tc/
 - ADq không tương thích với bộ lọc đám mây
 - Không hỗ trợ thiết lập kênh qua ethtool (ethtool -L) khi TC
   được cấu hình bằng mqprio
 - Bạn phải có iproute2 phiên bản mới nhất
 - Yêu cầu NVM phiên bản 6.01 trở lên
 - Không thể bật ADq khi bật bất kỳ tính năng nào sau đây: Dữ liệu
   Cầu nối trung tâm (DCB), Nhiều chức năng trên mỗi cổng (MFP) hoặc Bộ lọc dải bên
 - Nếu trình điều khiển khác (ví dụ: DPDK) đã đặt bộ lọc đám mây thì bạn không thể
   kích hoạt ADq
 - Bộ lọc đường hầm không được hỗ trợ trong ADq. Nếu các gói được đóng gói đến
   ở chế độ không có đường hầm, việc lọc sẽ được thực hiện trên các tiêu đề bên trong.  Ví dụ,
   đối với lưu lượng VXLAN ở chế độ không có đường hầm, PCTYPE được xác định là VXLAN
   gói được đóng gói, các tiêu đề bên ngoài sẽ bị bỏ qua. Vì vậy, các tiêu đề bên trong là
   khớp.
 - Nếu bộ lọc TC trên PF khớp với lưu lượng trên VF (trên PF), lưu lượng đó
   sẽ được chuyển đến hàng đợi thích hợp của PF và sẽ không được chuyển tiếp
   VF. Lưu lượng truy cập như vậy cuối cùng sẽ giảm lên cao hơn trong TCP/IP
   ngăn xếp vì nó không khớp với dữ liệu địa chỉ PF.
 - Nếu lưu lượng khớp với nhiều bộ lọc TC trỏ đến các TC khác nhau thì
   lưu lượng truy cập sẽ được nhân đôi và gửi đến tất cả các hàng đợi TC phù hợp.  Phần cứng
   chuyển đổi phản chiếu gói vào danh sách VSI khi có nhiều bộ lọc khớp với nhau.


Sự cố đã biết/Khắc phục sự cố
============================

Liên kết không thành công với các VF được liên kết với thiết bị dòng Intel(R) Ethernet Controller 700
---------------------------------------------------------------------------------
Nếu bạn liên kết các Chức năng Ảo (VF) với Bộ điều khiển Ethernet Intel(R) 700
thiết bị dựa trên sê-ri, các thiết bị phụ VF có thể bị lỗi khi chúng trở thành thiết bị phụ hoạt động.
Nếu địa chỉ MAC của VF được thiết lập bởi PF (Chức năng vật lý) của
thiết bị, khi bạn thêm một thiết bị phụ hoặc thay đổi thiết bị phụ dự phòng hoạt động, liên kết Linux
cố gắng đồng bộ hóa địa chỉ MAC của thiết bị phụ dự phòng với cùng địa chỉ MAC như địa chỉ
nô lệ tích cực. Liên kết Linux sẽ thất bại vào thời điểm này. Vấn đề này sẽ không xảy ra
nếu địa chỉ MAC của VF không được PF đặt.

Lưu lượng truy cập không được truyền giữa VM và máy khách
-------------------------------------------------
Bạn có thể không truyền được lưu lượng giữa hệ thống máy khách và hệ thống
Máy ảo (VM) chạy trên một máy chủ riêng nếu Chức năng ảo
(VF hoặc Virtual NIC) không ở chế độ đáng tin cậy và tính năng kiểm tra giả mạo được bật
trên VF. Lưu ý rằng tình huống này có thể xảy ra ở bất kỳ sự kết hợp nào của khách hàng,
máy chủ và hệ điều hành khách. Để biết thông tin về cách đặt VF thành
chế độ tin cậy, hãy tham khảo phần "Chỉ đạo gói thẻ VLAN" trong phần này
tài liệu readme. Để biết thông tin về cài đặt kiểm tra giả mạo, hãy tham khảo
phần "Tính năng chống giả mạo MAC và VLAN" trong tài liệu readme này.

Không dỡ trình điều khiển cổng nếu VF có VM đang hoạt động được liên kết với nó
-------------------------------------------------------------
Không dỡ trình điều khiển của cổng nếu Chức năng ảo (VF) có chức năng ảo đang hoạt động
Máy (VM) bị ràng buộc với nó. Làm như vậy sẽ khiến cổng có vẻ bị treo.
Khi VM tắt hoặc giải phóng VF, lệnh sẽ hoàn tất.

Sử dụng bốn lớp lưu lượng không thành công
--------------------------------
Đừng cố dự trữ nhiều hơn ba loại lưu lượng trong trình điều khiển iavf. Đang làm
do đó sẽ không thiết lập được bất kỳ loại lưu lượng truy cập nào và sẽ khiến trình điều khiển phải viết
lỗi đối với thiết bị xuất chuẩn. Sử dụng tối đa ba hàng đợi để tránh vấn đề này.

Nhiều thông báo lỗi nhật ký khi xóa trình điều khiển iavf
--------------------------------------------------
Nếu bạn có một số VF và bạn loại bỏ trình điều khiển iavf, một số phiên bản của
các lỗi nhật ký sau được ghi vào nhật ký::

Không thể gửi opcode 2 tới PF, err I40E_ERR_QUEUE_EMPTY, aq_err ok
    Không thể gửi tin nhắn đến VF 2 aq_err 12
    Đã phát hiện lỗi tràn ARQ

Máy ảo không nhận được link
---------------------------------
Nếu máy ảo có nhiều hơn một cổng ảo được gán cho nó và những cổng đó
cổng ảo được liên kết với các cổng vật lý khác nhau, bạn có thể không nhận được liên kết
tất cả các cổng ảo. Lệnh sau có thể giải quyết vấn đề này::

# ethtool -r <PF>

Trong đó <PF> là giao diện PF trong máy chủ, ví dụ: p5p1. Bạn có thể cần phải
chạy lệnh nhiều lần để nhận liên kết trên tất cả các cổng ảo.

Địa chỉ MAC của Chức năng ảo thay đổi bất ngờ
----------------------------------------------------
Nếu địa chỉ MAC của Chức năng ảo không được chỉ định trong máy chủ thì VF
Trình điều khiển (chức năng ảo) sẽ sử dụng địa chỉ MAC ngẫu nhiên. MAC ngẫu nhiên này
địa chỉ có thể thay đổi mỗi lần tải lại trình điều khiển VF. Bạn có thể chỉ định một tĩnh
Địa chỉ MAC trong máy chủ. Địa chỉ MAC tĩnh này sẽ tồn tại
tải lại trình điều khiển VF.

Sửa lỗi tràn bộ đệm trình điều khiển
--------------------------
Bản sửa lỗi để giải quyết CVE-2016-8105, được tham chiếu trong Intel SA-00069
ZZ0000ZZ
được bao gồm trong phiên bản này và các phiên bản tương lai của trình điều khiển.

Nhiều giao diện trên cùng một mạng phát sóng Ethernet
------------------------------------------------------
Do hành vi ARP mặc định trên Linux nên không thể có một hệ thống
trên hai mạng IP trong cùng một miền quảng bá Ethernet (không được phân vùng
switch) hoạt động như mong đợi. Tất cả các giao diện Ethernet sẽ phản hồi lưu lượng IP
cho bất kỳ địa chỉ IP nào được gán cho hệ thống. Điều này dẫn đến việc nhận không cân bằng
giao thông.

Nếu bạn có nhiều giao diện trong một máy chủ, hãy bật tính năng lọc ARP bằng cách
nhập::

# echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter

NOTE:
  Cài đặt này không được lưu trong các lần khởi động lại. Việc thay đổi cấu hình có thể
  được thực hiện vĩnh viễn bằng cách thêm dòng sau vào tệp /etc/sysctl.conf::

net.ipv4.conf.all.arp_filter = 1

Một cách khác là cài đặt các giao diện trong các miền quảng bá riêng biệt
(trong các switch khác nhau hoặc trong một switch được phân vùng thành Vlan).

Lỗi phân bổ trang Rx
-------------------------
'Lỗi phân bổ trang. order:0' lỗi có thể xảy ra khi bị căng thẳng.
Điều này là do cách nhân Linux báo cáo tình trạng căng thẳng này.


Ủng hộ
=======
Để biết thông tin chung, hãy truy cập trang web hỗ trợ của Intel tại:
ZZ0000ZZ

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến sự cố
tới intel-wired-lan@lists.osuosl.org.