.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/intel/ixgbe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================================================
Trình điều khiển cơ sở Linux cho bộ điều hợp Intel(R) Ethernet 10 Gigabit PCI Express
===========================================================================

Trình điều khiển Intel 10 Gigabit Linux.
Bản quyền(c) 1999-2018 Tập đoàn Intel.

Nội dung
========

- Xác định bộ chuyển đổi của bạn
- Tham số dòng lệnh
- Cấu hình bổ sung
- Các vấn đề đã biết
- Hỗ trợ

Xác định bộ điều hợp của bạn
========================
Trình điều khiển tương thích với các thiết bị dựa trên những điều sau:

* Bộ điều khiển Ethernet Intel(R) 82598
 * Bộ điều khiển Ethernet Intel(R) 82599
 * Bộ điều khiển Ethernet Intel(R) X520
 * Bộ điều khiển Ethernet Intel(R) X540
 * Bộ điều khiển Ethernet Intel(R) x550
 * Bộ điều khiển Ethernet Intel(R) X552
 * Bộ điều khiển Ethernet Intel(R) X553

Để biết thông tin về cách xác định bộ điều hợp của bạn và để có phiên bản Intel mới nhất
trình điều khiển mạng, hãy tham khảo trang web Hỗ trợ của Intel:
ZZ0000ZZ

Thiết bị SFP+ có Quang học có thể cắm được
----------------------------------

82599-BASED ADAPTERS
~~~~~~~~~~~~~~~~~~~~
NOTES:
- Nếu Bộ điều hợp mạng Intel(R) dựa trên 82599 của bạn đi kèm với cáp quang Intel hoặc là một
Bộ điều hợp máy chủ Ethernet Intel(R) X520-2, sau đó nó chỉ hỗ trợ cáp quang Intel
và/hoặc các cáp gắn trực tiếp được liệt kê bên dưới.
- Khi các thiết bị SFP+ dựa trên 82599 được kết nối ngược nhau, chúng phải được đặt
đến cùng cài đặt Tốc độ thông qua ethtool. Kết quả có thể thay đổi nếu bạn trộn tốc độ
cài đặt.

+--------------+---------------------------------------+-------------------+
ZZ0000ZZ Loại ZZ0001ZZ
+============================================================================================================================================================
ZZ0002ZZ
+--------------+---------------------------------------+-------------------+
ZZ0003ZZ DUAL RATE 1G/10G SFP+ SR (bảo lãnh) ZZ0004ZZ
+--------------+---------------------------------------+-------------------+
ZZ0005ZZ DUAL RATE 1G/10G SFP+ SR (bảo lãnh) ZZ0006ZZ
+--------------+---------------------------------------+-------------------+
ZZ0007ZZ DUAL RATE 1G/10G SFP+ SR (bảo lãnh) ZZ0008ZZ
+--------------+---------------------------------------+-------------------+
ZZ0009ZZ
+--------------+---------------------------------------+-------------------+
ZZ0010ZZ DUAL RATE 1G/10G SFP+ LR (bảo lãnh) ZZ0011ZZ
+--------------+---------------------------------------+-------------------+
ZZ0012ZZ DUAL RATE 1G/10G SFP+ LR (bảo lãnh) ZZ0013ZZ
+--------------+---------------------------------------+-------------------+
ZZ0014ZZ DUAL RATE 1G/10G SFP+ LR (bảo lãnh) ZZ0015ZZ
+--------------+---------------------------------------+-------------------+

Sau đây là danh sách các mô-đun SFP+ của bên thứ 3 đã nhận được một số
thử nghiệm. Không phải tất cả các mô-đun đều có thể áp dụng cho tất cả các thiết bị.

+--------------+---------------------------------------+-------------------+
ZZ0000ZZ Loại ZZ0001ZZ
+============================================================================================================================================================
ZZ0002ZZ SFP+ SR bảo lãnh, 10g tốc độ đơn ZZ0003ZZ
+--------------+---------------------------------------+-------------------+
ZZ0004ZZ SFP+ SR được bảo lãnh, tốc độ đơn 10g ZZ0005ZZ
+--------------+---------------------------------------+-------------------+
ZZ0006ZZ SFP+ LR bảo lãnh, 10g tốc độ đơn ZZ0007ZZ
+--------------+---------------------------------------+-------------------+
ZZ0008ZZ DUAL RATE 1G/10G SFP+ SR (Không bảo lãnh) ZZ0009ZZ
+--------------+---------------------------------------+-------------------+
ZZ0010ZZ DUAL RATE 1G/10G SFP+ SR (Không bảo lãnh) ZZ0011ZZ
+--------------+---------------------------------------+-------------------+
ZZ0012ZZ DUAL RATE 1G/10G SFP+ LR (Không bảo lãnh) ZZ0013ZZ
+--------------+---------------------------------------+-------------------+
ZZ0014ZZ DUAL RATE 1G/10G SFP+ LR (Không bảo lãnh) ZZ0015ZZ
+--------------+---------------------------------------+-------------------+
ZZ0016ZZ 1000BASE-T SFP ZZ0017ZZ
+--------------+---------------------------------------+-------------------+
ZZ0018ZZ 1000BASE-T ZZ0019ZZ
+--------------+---------------------------------------+-------------------+
ZZ0020ZZ 1000BASE-SX SFP ZZ0021ZZ
+--------------+---------------------------------------+-------------------+

Bộ điều hợp dựa trên 82599 hỗ trợ tất cả các kết nối trực tiếp giới hạn thụ động và chủ động
cáp tuân thủ thông số kỹ thuật SFF-8431 v4.1 và SFF-8472 v10.4.

Laser tắt cho SFP+ khi ifconfig ethX ngừng hoạt động
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"ifconfig ethX down" tắt tia laser cho bộ điều hợp sợi SFP+ dựa trên 82599.
"ifconfig ethX up" bật tia laser.
Ngoài ra, bạn có thể sử dụng "ip link set [down/up] dev ethX" để chuyển
tắt và bật tia laser.


Bộ điều hợp QSFP+ dựa trên 82599
~~~~~~~~~~~~~~~~~~~~~~~~~~
NOTES:
- Nếu Bộ điều hợp mạng Intel(R) dựa trên 82599 của bạn đi kèm với quang Intel, nó chỉ
hỗ trợ quang học Intel.
- Bộ điều hợp QSFP+ dựa trên 82599 chỉ hỗ trợ kết nối 4x10 Gbps.  1x40Gbps
kết nối không được hỗ trợ. Đối tác liên kết QSFP+ phải được định cấu hình cho
4x10Gbps.
- Bộ điều hợp QSFP+ dựa trên 82599 không hỗ trợ phát hiện tốc độ liên kết tự động.
Tốc độ liên kết phải được định cấu hình thành 10 Gbps hoặc 1 Gbps để phù hợp với liên kết
khả năng tốc độ của đối tác. Cấu hình tốc độ không chính xác sẽ dẫn đến
không liên kết được.
- Bộ điều hợp mạng hội tụ Ethernet Intel(R) X520-Q1 chỉ hỗ trợ quang học
và cáp gắn trực tiếp được liệt kê dưới đây.

+--------------+---------------------------------------+-------------------+
ZZ0000ZZ Loại ZZ0001ZZ
+============================================================================================================================================================
ZZ0002ZZ DUAL RATE 1G/10G QSFP+ SRL (bảo lãnh) ZZ0003ZZ
+--------------+---------------------------------------+-------------------+

Bộ điều hợp QSFP+ dựa trên 82599 hỗ trợ tất cả QSFP+ giới hạn thụ động và chủ động
cáp gắn trực tiếp tuân theo thông số kỹ thuật SFF-8436 v4.1.

82598-BASED ADAPTERS
~~~~~~~~~~~~~~~~~~~~
NOTES:
- Bộ điều hợp mạng Ethernet Intel(r) hỗ trợ các mô-đun quang có thể tháo rời
chỉ hỗ trợ loại mô-đun gốc của chúng (ví dụ: Intel(R) 10 Gigabit
Mô-đun SR Dual Port Express chỉ hỗ trợ các mô-đun quang SR). Nếu bạn cắm vào
một loại mô-đun khác, trình điều khiển sẽ không tải.
- Không hỗ trợ mô-đun quang trao đổi nóng/cắm nóng.
- Chỉ hỗ trợ tốc độ đơn, mô-đun 10 gigabit.
- LAN trên Bo mạch chủ (LOM) có thể hỗ trợ các mô-đun DA, SR hoặc LR. Mô-đun khác
các loại không được hỗ trợ. Vui lòng xem tài liệu hệ thống của bạn để biết chi tiết.

Sau đây là danh sách các mô-đun SFP+ và cáp gắn trực tiếp có
nhận được một số thử nghiệm. Không phải tất cả các mô-đun đều có thể áp dụng cho tất cả các thiết bị.

+--------------+---------------------------------------+-------------------+
ZZ0000ZZ Loại ZZ0001ZZ
+============================================================================================================================================================
ZZ0002ZZ SFP+ SR bảo lãnh, 10g tốc độ đơn ZZ0003ZZ
+--------------+---------------------------------------+-------------------+
ZZ0004ZZ SFP+ SR bảo lãnh, tốc độ đơn 10g ZZ0005ZZ
+--------------+---------------------------------------+-------------------+
ZZ0006ZZ SFP+ LR bảo lãnh, 10g tốc độ đơn ZZ0007ZZ
+--------------+---------------------------------------+-------------------+

Bộ điều hợp dựa trên 82598 hỗ trợ tất cả các loại cáp gắn trực tiếp thụ động tuân thủ
Thông số kỹ thuật SFF-8431 v4.1 và SFF-8472 v10.4. Cáp gắn trực tiếp chủ động
không được hỗ trợ.

Các mô-đun quang và cáp quang của bên thứ ba được đề cập ở trên chỉ được liệt kê cho
mục đích làm nổi bật các thông số kỹ thuật và tiềm năng của bên thứ ba
khả năng tương thích, và không phải là khuyến nghị hoặc xác nhận hoặc tài trợ của
bất kỳ sản phẩm nào của bên thứ ba của Intel. Intel không xác nhận hay quảng bá
sản phẩm do bất kỳ bên thứ ba nào sản xuất và tài liệu tham khảo của bên thứ ba được cung cấp
chỉ để chia sẻ thông tin về các mô-đun và cáp quang nhất định với
thông số kỹ thuật trên. Có thể có những nhà sản xuất hoặc nhà cung cấp khác đang sản xuất
hoặc cung cấp các mô-đun và cáp quang có mô tả tương tự hoặc phù hợp.
Khách hàng phải sử dụng quyền quyết định và sự siêng năng của riêng mình để mua quang
mô-đun và cáp từ bất kỳ bên thứ ba nào mà họ lựa chọn. Khách hàng chỉ được
chịu trách nhiệm đánh giá sự phù hợp của sản phẩm và/hoặc thiết bị và
để lựa chọn nhà cung cấp để mua bất kỳ sản phẩm nào. THE OPTIC MODULES
AND CABLES REFERRED ĐẾN ABOVE ARE NOT WARRANTED HOẶC SUPPORTED BỞI INTEL. INTEL
ASSUMES KHÔNG LIABILITY WHATSOEVER, AND INTEL DISCLAIMS ANY EXPRESS HOẶC IMPLIED
WARRANTY, RELATING ĐẾN SALE AND/HOẶC USE CỦA SUCH THIRD PARTY PRODUCTS HOẶC
SELECTION CỦA VENDOR BỞI CUSTOMERS.

Tham số dòng lệnh
=======================

max_vfs
-------
:Phạm vi hợp lệ: 1-63

Tham số này bổ sung hỗ trợ cho SR-IOV. Nó khiến người lái xe phải sinh ra
giá trị max_vfs của các hàm ảo.
Nếu giá trị lớn hơn 0 thì nó cũng sẽ buộc tham số VMDq là 1 hoặc
nhiều hơn nữa.

NOTE: Tham số này chỉ được sử dụng trên kernel 3.7.x trở xuống. Trên hạt nhân 3.8.x
trở lên, hãy sử dụng sysfs để kích hoạt VF. Ngoài ra, đối với các bản phân phối của Red Hat, điều này
tham số chỉ được sử dụng trên phiên bản 6.6 trở lên. Đối với phiên bản 6.7 trở lên, hãy sử dụng
sysfs. Ví dụ::

#echo $num_vf_enabled > /sys/class/net/$dev/device/sriov_numvfs // bật VF
  #echo 0 > /sys/class/net/$dev/device/sriov_numvfs // vô hiệu hóa VF

Các thông số cho trình điều khiển được tham chiếu theo vị trí. Vì vậy, nếu bạn có một
bộ điều hợp cổng kép hoặc nhiều bộ điều hợp trong hệ thống của bạn và muốn N ảo
chức năng trên mỗi cổng, bạn phải chỉ định một số cho mỗi cổng với mỗi tham số
cách nhau bằng dấu phẩy. Ví dụ::

modprobe ixgbe max_vfs=4

Điều này sẽ sinh ra 4 VF trên cổng đầu tiên.

::

modprobe ixgbe max_vfs=2,4

Điều này sẽ sinh ra 2 VF ở cổng đầu tiên và 4 VF ở cổng thứ hai.

NOTE: Phải thận trọng khi tải trình điều khiển có các thông số này.
Tùy thuộc vào cấu hình hệ thống của bạn, số lượng khe cắm, v.v., điều đó là không thể
để dự đoán trong mọi trường hợp các vị trí sẽ nằm trên dòng lệnh.

NOTE: Cả thiết bị và trình điều khiển đều không kiểm soát cách ánh xạ VF vào cấu hình
không gian. Bố cục xe buýt sẽ thay đổi tùy theo hệ điều hành. Trên các hệ điều hành có
hỗ trợ nó, bạn có thể kiểm tra sysfs để tìm ánh xạ.

NOTE: Khi chế độ SR-IOV hoặc chế độ VMDq được bật, tính năng lọc VLAN phần cứng
và tính năng tước/chèn thẻ VLAN sẽ vẫn được bật. Hãy loại bỏ cái cũ
Bộ lọc VLAN trước khi thêm bộ lọc VLAN mới. Ví dụ,

::

liên kết ip đặt eth0 vf 0 vlan 100 // đặt VLAN 100 cho VF 0
  liên kết ip được đặt eth0 vf 0 vlan 0 // Xóa VLAN 100
  liên kết ip được đặt eth0 vf 0 vlan 200 // đặt VLAN 200 mới cho VF 0

Với kernel 3.6, trình điều khiển hỗ trợ sử dụng đồng thời max_vfs và DCB
các tính năng, tuân theo các ràng buộc được mô tả dưới đây. Trước kernel 3.6,
trình điều khiển không hỗ trợ hoạt động đồng thời của max_vfs lớn hơn 0 và
các tính năng DCB (nhiều lớp lưu lượng sử dụng Kiểm soát luồng ưu tiên và
Lựa chọn truyền mở rộng).

Khi DCB được bật, lưu lượng mạng sẽ được truyền và nhận thông qua
nhiều lớp lưu lượng (bộ đệm gói trong NIC). Giao thông có liên quan
với một lớp cụ thể dựa trên mức độ ưu tiên, có giá trị từ 0 đến 7 được sử dụng
trong thẻ VLAN. Khi SR-IOV không được bật, mỗi loại lưu lượng sẽ được liên kết
với một tập hợp các cặp hàng đợi mô tả nhận/truyền. Số lượng hàng đợi
các cặp cho một lớp lưu lượng nhất định phụ thuộc vào cấu hình phần cứng. Khi nào
SR-IOV được bật, các cặp hàng đợi mô tả được nhóm thành nhóm. các
Hàm vật lý (PF) và mỗi Hàm ảo (VF) được phân bổ một nhóm
nhận/truyền các cặp hàng đợi mô tả. Khi có nhiều lớp lưu lượng
được định cấu hình (ví dụ: DCB được bật), mỗi nhóm chứa một cặp hàng đợi từ
từng loại lưu lượng. Khi một lớp lưu lượng được cấu hình trong phần cứng,
các nhóm chứa nhiều cặp hàng đợi từ một lớp lưu lượng truy cập duy nhất.

Số lượng VF có thể được phân bổ tùy thuộc vào số lượng lưu lượng truy cập
các lớp có thể được kích hoạt. Số lượng các lớp lưu lượng có thể cấu hình cho
mỗi VF được kích hoạt như sau:
0 - 15 VF = Tối đa 8 loại lưu lượng, tùy thuộc vào hỗ trợ của thiết bị
16 - 31 VF = Tối đa 4 loại lưu lượng
32 - 63 VF = 1 loại lưu lượng

Khi VF được định cấu hình, PF cũng được phân bổ một nhóm. PF hỗ trợ
các tính năng của DCB với ràng buộc là mỗi lớp lưu lượng sẽ chỉ sử dụng một
cặp hàng đợi đơn. Khi không có VF nào được cấu hình, PF có thể hỗ trợ nhiều
cặp hàng đợi cho mỗi lớp lưu lượng.

allow_unsupported_sfp
---------------------
:Phạm vi hợp lệ: 0,1
: Giá trị mặc định: 0 (bị tắt)

Tham số này cho phép các mô-đun SFP+ không được hỗ trợ và chưa được kiểm tra trên nền tảng 82599
bộ điều hợp, miễn là trình điều khiển biết loại mô-đun.

gỡ lỗi
-----
:Phạm vi hợp lệ: 0-16 (0=none,...,16=all)
: Giá trị mặc định: 0

Thông số này điều chỉnh mức độ thông báo debug hiển thị trong hệ thống
nhật ký.


Các tính năng và cấu hình bổ sung
======================================

Kiểm soát dòng chảy
------------
Kiểm soát luồng Ethernet (IEEE 802.3x) có thể được cấu hình bằng ethtool để kích hoạt
nhận và truyền các khung tạm dừng cho ixgbe. Khi truyền được kích hoạt,
các khung tạm dừng được tạo ra khi bộ đệm gói nhận vượt qua vùng đệm được xác định trước
ngưỡng. Khi nhận được kích hoạt, thiết bị truyền sẽ tạm dừng trong một thời gian
độ trễ được chỉ định khi nhận được khung tạm dừng.

NOTE: Bạn phải có đối tác liên kết có khả năng kiểm soát luồng.

Kiểm soát luồng được bật theo mặc định.

Sử dụng ethtool để thay đổi cài đặt kiểm soát luồng. Để bật hoặc tắt Rx hoặc
Kiểm soát dòng chảy Tx::

ethtool -Một eth? rx <on|off> tx <on|off>

Lưu ý: Lệnh này chỉ bật hoặc tắt Kiểm soát luồng nếu tự động đàm phán được
bị vô hiệu hóa. Nếu bật tự động đàm phán, lệnh này sẽ thay đổi các tham số
được sử dụng để tự động đàm phán với đối tác liên kết.

Để bật hoặc tắt tính năng tự động đàm phán::

ethtool -s eth? autoneg <bật|tắt>

Lưu ý: Tự động đàm phán Kiểm soát luồng là một phần của tự động đàm phán liên kết. Tùy theo
trên thiết bị của bạn, bạn có thể không thay đổi được cài đặt tự động thương lượng.

NOTE: Đối với 82598 thẻ bảng nối đa năng vào chế độ 1 gigabit, mặc định điều khiển luồng
hành vi được thay đổi thành tắt. Kiểm soát luồng ở chế độ 1 gigabit trên các thiết bị này có thể
dẫn tới việc truyền tải bị treo.

Giám đốc luồng Ethernet Intel(R)
-------------------------------
Giám đốc luồng Ethernet Intel thực hiện các tác vụ sau:

- Chỉ đạo nhận các gói theo luồng của chúng đến các hàng đợi khác nhau.
- Cho phép kiểm soát chặt chẽ việc định tuyến luồng trong nền tảng.
- Phù hợp với các luồng và lõi CPU cho mối quan hệ dòng chảy.
- Hỗ trợ nhiều tham số để phân loại dòng chảy và tải linh hoạt
  cân bằng (chỉ ở chế độ SFP).

NOTE: Mặt nạ Intel Ethernet Flow Director hoạt động theo cách ngược lại với
mặt nạ mạng con. Trong lệnh sau::

#ethtool -N eth11 loại luồng ip4 src-ip 172.4.1.2 m 255.0.0.0 dst-ip \
  172.21.1.1 m 255.128.0.0 hành động 31

Giá trị src-ip được ghi vào bộ lọc sẽ là 0.4.1.2, không phải 172.0.0.0
như có thể được mong đợi. Tương tự, giá trị dst-ip được ghi vào bộ lọc sẽ là
0.21.1.1, không phải 172.0.0.0.

Để bật hoặc tắt Intel Ethernet Flow Director::

# ethtool -K ethX ntuple <bật|tắt>

Khi tắt nhiều bộ lọc, tất cả các bộ lọc do người dùng lập trình sẽ bị xóa khỏi
bộ đệm trình điều khiển và phần cứng. Tất cả các bộ lọc cần thiết phải được thêm lại khi ntuple
được kích hoạt lại.

Để thêm bộ lọc hướng gói đến hàng đợi 2, hãy sử dụng khóa chuyển -U hoặc -N ::

# ethtool -N ethX loại luồng tcp4 src-ip 192.168.10.1 dst-ip \
  192.168.10.2 src-port 2000 dst-port 2001 hành động 2 [loc 1]

Để xem danh sách các bộ lọc hiện có::

# ethtool <-u|-n> ethX

Bộ lọc hoàn hảo Sideband
------------------------
Bộ lọc hoàn hảo dải biên được sử dụng để điều hướng lưu lượng truy cập phù hợp với quy định
đặc điểm. Chúng được kích hoạt thông qua giao diện ntuple của ethtool. Để thêm một
bộ lọc mới sử dụng lệnh sau ::

ethtool -U <device> loại luồng <type> src-ip <ip> dst-ip <ip> src-port <port> \
  dst-port <port> hành động <hàng đợi>

Ở đâu:
  <device> - thiết bị ethernet để lập trình
  <loại> - có thể là ip4, tcp4, udp4 hoặc sctp4
  <ip> - địa chỉ IP cần khớp
  <port> - số cổng cần khớp
  <queue> - hàng đợi hướng lưu lượng truy cập tới (-1 loại bỏ lưu lượng truy cập phù hợp)

Sử dụng lệnh sau để xóa bộ lọc::

ethtool -U <thiết bị> xóa <N>

Trong đó <N> là id bộ lọc được hiển thị khi in tất cả các bộ lọc đang hoạt động và
cũng có thể được chỉ định bằng cách sử dụng "loc <N>" khi thêm bộ lọc.

Ví dụ sau khớp với lưu lượng truy cập TCP được gửi từ 192.168.0.1, cổng 5300,
được chuyển hướng đến 192.168.0.5, cổng 80 và gửi nó đến hàng đợi 7::

ethtool -U enp130s0 kiểu luồng tcp4 src-ip 192.168.0.1 dst-ip 192.168.0.5 \
  src-port 5300 dst-port 80 hành động 7

Đối với mỗi loại luồng, các bộ lọc được lập trình đều phải có cùng một kết quả phù hợp.
bộ đầu vào. Ví dụ: có thể chấp nhận việc đưa ra hai lệnh sau::

ethtool -U enp130s0 loại luồng ip4 src-ip 192.168.0.1 src-port 5300 hành động 7
  ethtool -U enp130s0 loại luồng ip4 src-ip 192.168.0.5 src-port 55 hành động 10

Tuy nhiên, việc đưa ra hai lệnh tiếp theo là không được chấp nhận vì lệnh đầu tiên
chỉ định src-ip và thứ hai chỉ định dst-ip::

ethtool -U enp130s0 loại luồng ip4 src-ip 192.168.0.1 src-port 5300 hành động 7
  ethtool -U enp130s0 loại luồng ip4 dst-ip 192.168.0.5 src-port 55 hành động 10

Lệnh thứ hai sẽ thất bại và có lỗi. Bạn có thể lập trình nhiều bộ lọc
với cùng các trường, sử dụng các giá trị khác nhau, nhưng trên một thiết bị, bạn không thể
lập trình hai bộ lọc TCP4 với các trường khớp khác nhau.

Việc khớp trên một phần phụ của trường không được trình điều khiển ixgbe hỗ trợ, do đó
các trường mặt nạ một phần không được hỗ trợ.

Để tạo các bộ lọc hướng lưu lượng truy cập đến một Chức năng ảo cụ thể, hãy sử dụng
tham số "người dùng-def". Chỉ định user-def là giá trị 64 bit, trong đó giá trị 32 thấp hơn
bit đại diện cho số hàng đợi, trong khi 8 bit tiếp theo đại diện cho VF nào.
Lưu ý rằng 0 là PF, do đó mã định danh VF được bù bằng 1. Ví dụ::

  ... user-def 0x800000002 ...

chỉ định hướng lưu lượng truy cập đến Chức năng ảo 7 (8 trừ 1) vào hàng đợi 2 của
VF đó.

Lưu ý rằng các bộ lọc này sẽ không vi phạm các quy tắc định tuyến nội bộ và sẽ không
định tuyến lưu lượng truy cập mà lẽ ra sẽ không được gửi đến Virtual được chỉ định
Chức năng.

Khung Jumbo
------------
Hỗ trợ Khung Jumbo được bật bằng cách thay đổi Đơn vị truyền tối đa (MTU)
đến giá trị lớn hơn giá trị mặc định là 1500.

Sử dụng lệnh ifconfig để tăng kích thước MTU. Ví dụ: nhập
sau đây trong đó <x> là số giao diện::

ifconfig eth<x> mtu 9000 trở lên

Ngoài ra, bạn có thể sử dụng lệnh ip như sau ::

bộ liên kết ip mtu 9000 dev eth<x>
  liên kết ip thiết lập dev eth<x>

Cài đặt này không được lưu trong các lần khởi động lại. Việc thay đổi cài đặt có thể được thực hiện
vĩnh viễn bằng cách thêm 'MTU=9000' vào tệp::

/etc/sysconfig/network-scripts/ifcfg-eth<x> // cho RHEL
  /etc/sysconfig/network/<config_file> // cho SLES

NOTE: Cài đặt MTU tối đa cho Khung Jumbo là 9710. Giá trị này trùng khớp
với kích thước Khung Jumbo tối đa là 9728 byte.

NOTE: Trình điều khiển này sẽ cố gắng sử dụng nhiều bộ đệm có kích thước trang để nhận
mỗi gói lớn. Điều này sẽ giúp tránh được vấn đề thiếu bộ đệm khi
phân bổ các gói nhận.

NOTE: Đối với các kết nối mạng dựa trên 82599, nếu bạn đang bật các khung jumbo trong
một chức năng ảo (VF), các khung jumbo trước tiên phải được kích hoạt trong môi trường vật lý
chức năng (PF). Cài đặt VF MTU không thể lớn hơn PF MTU.

Hỗ trợ NBASE-T
---------------
Trình điều khiển ixgbe hỗ trợ NBASE-T trên một số thiết bị. Tuy nhiên, quảng cáo
tốc độ của NBASE-T bị chặn theo mặc định để phù hợp với mạng bị hỏng
các công tắc không thể đáp ứng được tốc độ NBASE-T được quảng cáo. Sử dụng công cụ đạo đức
lệnh để bật quảng cáo tốc độ NBASE-T trên các thiết bị hỗ trợ nó ::

ethtool -s eth? quảng cáo 0x1800000001028

Trên các hệ thống Linux có INTERFACES(5), điều này có thể được chỉ định làm lệnh chuẩn bị
trong /etc/network/interfaces để giao diện luôn được hiển thị
Hỗ trợ NBASE-T, ví dụ::

iface eth? inet dhcp
       chuẩn bị trước ethtool -s eth? quảng cáo 0x1800000001028 || ĐÚNG VẬY

Giảm tải nhận chung, hay còn gọi là GRO
--------------------------------
Trình điều khiển hỗ trợ triển khai phần mềm trong kernel của GRO. GRO có
đã chỉ ra rằng bằng cách kết hợp lưu lượng Rx thành các khối dữ liệu lớn hơn, CPU
việc sử dụng có thể giảm đáng kể khi chịu tải Rx lớn. GRO là một
sự phát triển của giao diện LRO được sử dụng trước đây. GRO có thể kết hợp lại
các giao thức khác ngoài TCP. Nó cũng an toàn khi sử dụng với các cấu hình
là vấn đề đối với LRO, cụ thể là cầu nối và iSCSI.

Cầu nối trung tâm dữ liệu (DCB)
--------------------------
NOTE:
Hạt nhân giả định rằng TC0 có sẵn và sẽ tắt Luồng ưu tiên
Điều khiển (PFC) trên thiết bị nếu TC0 không khả dụng. Để khắc phục điều này, hãy đảm bảo TC0 được
được bật khi thiết lập DCB trên bộ chuyển mạch của bạn.

DCB là cấu hình triển khai Chất lượng dịch vụ trong phần cứng. Nó sử dụng
thẻ ưu tiên VLAN (802.1p) để lọc lưu lượng. Điều đó có nghĩa là có 8
các mức độ ưu tiên khác nhau mà lưu lượng truy cập có thể được lọc vào. Nó cũng cho phép
điều khiển luồng ưu tiên (802.1Qbb) có thể hạn chế hoặc loại bỏ số lượng
rớt gói tin khi mạng căng thẳng. Băng thông có thể được phân bổ cho từng
những ưu tiên này được thực thi ở cấp độ phần cứng (802.1Qaz).

Phần sụn bộ điều hợp triển khai các tác nhân giao thức LLDP và DCBX theo 802.1AB và
802.1Qaz tương ứng. Tác nhân DCBX dựa trên phần sụn chỉ chạy ở chế độ sẵn sàng
và có thể chấp nhận cài đặt từ thiết bị ngang hàng có khả năng DCBX. Cấu hình phần mềm của
Các tham số DCBX qua dcbtool/lldptool không được hỗ trợ.

Trình điều khiển ixgbe triển khai lớp giao diện liên kết mạng DCB để cho phép không gian người dùng
để liên lạc với trình điều khiển và truy vấn cấu hình DCB cho cổng.

công cụ đạo đức
-------
Trình điều khiển sử dụng giao diện ethtool để cấu hình trình điều khiển và
chẩn đoán cũng như hiển thị thông tin thống kê. Công cụ đạo đức mới nhất
Phiên bản này là cần thiết cho chức năng này. Tải xuống tại:
ZZ0000ZZ

FCoE
----
Trình điều khiển ixgbe hỗ trợ Kênh sợi quang qua Ethernet (FCoE) và Trung tâm dữ liệu
Cầu nối (DCB). Mã này không có tác dụng mặc định trên trình điều khiển thông thường
hoạt động. Việc định cấu hình DCB và FCoE nằm ngoài phạm vi của README này. tham khảo
tới ZZ0000ZZ để biết thông tin dự án FCoE và liên hệ
ixgbe-eedc@lists.sourceforge.net để biết thông tin về DCB.

Tính năng chống giả mạo MAC và VLAN
----------------------------------
Khi một trình điều khiển độc hại cố gắng gửi một gói giả mạo, nó sẽ bị loại bỏ.
phần cứng và không được truyền đi.

Một ngắt được gửi tới trình điều khiển PF để thông báo về nỗ lực giả mạo. Khi một
gói giả mạo được phát hiện, trình điều khiển PF sẽ gửi thông báo sau tới
nhật ký hệ thống (được hiển thị bằng lệnh "dmesg")::

ixgbe ethX: ixgbe_spoof_check: phát hiện n gói giả mạo

trong đó "x" là số giao diện PF; và "n" là số lượng gói tin giả mạo.
NOTE: Tính năng này có thể bị tắt đối với một Chức năng ảo (VF) cụ thể::

bộ liên kết ip <pf dev> vf <vf id> spoofchk {tắt|bật}

Giảm tải IPsec
-------------
Trình điều khiển ixgbe hỗ trợ Giảm tải phần cứng IPsec.  Khi tạo Bảo mật
Các liên kết với "ip xfrm ..." tùy chọn thẻ 'offload' có thể được sử dụng để
đăng ký IPsec SA với trình điều khiển để có được thông lượng cao hơn trong
các thông tin liên lạc an toàn.

Việc giảm tải cũng được hỗ trợ cho các VF của ixgbe, nhưng VF phải được đặt là
'đáng tin cậy' và hỗ trợ phải được bật bằng::

ethtool --set-priv-flags eth<x> vf-ipsec bật
  liên kết ip đặt eth<x> vf <y> tin tưởng vào


Sự cố đã biết/Khắc phục sự cố
============================

Kích hoạt SR-IOV trong hệ điều hành khách Microsoft Windows Server 2012/R2 64-bit
---------------------------------------------------------------------
Linux KVM Hypervisor/VMM hỗ trợ gán trực tiếp thiết bị PCIe cho máy ảo.
Điều này bao gồm các thiết bị PCIe truyền thống cũng như các thiết bị dựa trên SR-IOV
trên Bộ điều khiển Ethernet Intel XL710.


Ủng hộ
=======
Để biết thông tin chung, hãy truy cập trang web hỗ trợ của Intel tại:
ZZ0000ZZ

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến sự cố
tới intel-wired-lan@lists.osuosl.org.