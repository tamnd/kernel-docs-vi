.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/intel/ice.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================================================================
Trình điều khiển cơ sở Linux cho Bộ điều khiển Ethernet Intel(R) dòng 800
=================================================================

Trình điều khiển Intel Ice Linux.
Bản quyền(c) 2018-2021 Tập đoàn Intel.

Nội dung
========

- Tổng quan
- Xác định bộ chuyển đổi của bạn
- Ghi chú quan trọng
- Các tính năng và cấu hình bổ sung
- Tối ưu hóa hiệu suất


Trình điều khiển Chức năng Ảo (VF) được liên kết cho trình điều khiển này là iavf.

Thông tin trình điều khiển có thể được lấy bằng ethtool và lspci.

Đối với các câu hỏi liên quan đến yêu cầu phần cứng, hãy tham khảo tài liệu
được cung cấp cùng với bộ điều hợp Intel của bạn. Tất cả các yêu cầu phần cứng được liệt kê đều áp dụng để sử dụng
với Linux.

Trình điều khiển này hỗ trợ XDP (Đường dẫn dữ liệu nhanh) và không sao chép AF_XDP. Lưu ý rằng
XDP bị chặn đối với kích thước khung hình lớn hơn 3KB.


Xác định bộ điều hợp của bạn
========================
Để biết thông tin về cách xác định bộ điều hợp của bạn và để có phiên bản Intel mới nhất
trình điều khiển mạng, hãy tham khảo trang web Hỗ trợ của Intel:
ZZ0000ZZ


Ghi chú quan trọng
===============

Việc giảm gói có thể xảy ra khi nhận được căng thẳng
-------------------------------------------
Các thiết bị dựa trên Bộ điều khiển Ethernet Intel(R) Series 800 được thiết kế để
chịu được độ trễ hệ thống ở mức giới hạn trong các giao dịch PCIe và DMA.
Nếu các giao dịch này mất nhiều thời gian hơn độ trễ có thể chấp nhận được thì nó có thể ảnh hưởng đến
khoảng thời gian các gói được lưu vào bộ đệm trong thiết bị và bộ nhớ liên quan,
có thể dẫn đến các gói bị rơi. Những gói tin này bị rơi thường không có
tác động đáng chú ý đến thông lượng và hiệu suất trong khối lượng công việc tiêu chuẩn.

Nếu những lần giảm gói này có vẻ ảnh hưởng đến khối lượng công việc của bạn thì những điều sau đây có thể được cải thiện
tình hình:

1) Đảm bảo rằng bộ nhớ vật lý của hệ thống của bạn có hiệu suất cao
   cấu hình, theo khuyến nghị của nhà cung cấp nền tảng. Một điểm chung
   khuyến nghị là tất cả các kênh nên được điền một DIMM duy nhất
   mô-đun.
2) Trong cài đặt BIOS/UEFI trên hệ thống của bạn, hãy chọn cấu hình "Hiệu suất".
3) Bản phân phối của bạn có thể cung cấp các công cụ như "điều chỉnh", có thể giúp điều chỉnh
   cài đặt kernel để đạt được cài đặt tiêu chuẩn tốt hơn cho các khối lượng công việc khác nhau.


Định cấu hình SR-IOV để cải thiện bảo mật mạng
------------------------------------------------
Trong môi trường ảo hóa, trên Bộ điều hợp mạng Ethernet Intel(R)
hỗ trợ SR-IOV, chức năng ảo (VF) có thể có hành vi nguy hiểm.
Lớp hai khung do phần mềm tạo ra, như IEEE 802.3x (điều khiển luồng liên kết), IEEE
802.1Qbb (điều khiển luồng dựa trên mức độ ưu tiên) và các loại khác thuộc loại này thì không
dự kiến và có thể điều tiết lưu lượng giữa máy chủ và bộ chuyển mạch ảo,
giảm hiệu suất. Để giải quyết vấn đề này và đảm bảo cách ly khỏi
luồng lưu lượng truy cập ngoài ý muốn, định cấu hình tất cả các cổng được bật SR-IOV để gắn thẻ VLAN
từ giao diện quản trị trên PF. Cấu hình này cho phép
các khung hình không mong muốn và có khả năng độc hại sẽ bị loại bỏ.

Xem "Định cấu hình gắn thẻ VLAN trên cổng bộ điều hợp đã bật SR-IOV" sau trong phần này
README để được hướng dẫn cấu hình.


Không dỡ trình điều khiển cổng nếu VF có VM đang hoạt động được liên kết với nó
-------------------------------------------------------------
Không dỡ trình điều khiển của cổng nếu Chức năng ảo (VF) có chức năng ảo đang hoạt động
Máy (VM) bị ràng buộc với nó. Làm như vậy sẽ khiến cổng có vẻ bị treo.
Khi VM tắt hoặc giải phóng VF, lệnh sẽ
hoàn thành.


Các tính năng và cấu hình bổ sung
======================================

công cụ đạo đức
-------
Trình điều khiển sử dụng giao diện ethtool để cấu hình trình điều khiển và
chẩn đoán cũng như hiển thị thông tin thống kê. Công cụ đạo đức mới nhất
Phiên bản này là cần thiết cho chức năng này. Tải xuống tại:
ZZ0000ZZ

NOTE: Giá trị rx_bytes của ethtool không khớp với giá trị rx_bytes của
Netdev, do CRC 4 byte bị thiết bị tước bỏ. Sự khác biệt
giữa hai giá trị rx_bytes sẽ là 4 x số lượng gói Rx. cho
ví dụ: nếu gói Rx là 10 và Netdev (thống kê phần mềm) hiển thị
rx_bytes là "X", thì ethtool (thống kê phần cứng) sẽ hiển thị rx_bytes là
"X+40" (4 byte CRC x 10 gói).

thiết lập lại ethtool
-------------
Trình điều khiển hỗ trợ 3 loại thiết lập lại:

- Đặt lại PF - chỉ đặt lại các thành phần được liên kết với PF đã cho, không
  tác động đến các PF khác

- Đặt lại CORE - toàn bộ bộ điều hợp bị ảnh hưởng, đặt lại tất cả PF

- Đặt lại GLOBAL - giống như CORE nhưng các thành phần mac và phy cũng được khởi tạo lại

Chúng được ánh xạ tới các cờ đặt lại ethtool như sau:

- Thiết lập lại PF:

# ethtool --reset <ethX> giảm tải bộ lọc irq dma

- Đặt lại CORE:

# ethtool --reset <ethX> irq-shared dma-shared filter-shared offload-shared \
  chia sẻ ram

- Đặt lại GLOBAL:

# ethtool --reset <ethX> irq-shared dma-shared filter-shared offload-shared \
  chia sẻ phy chia sẻ ram chia sẻ mac

Trong chế độ switchdev, bạn có thể đặt lại VF bằng cách sử dụng biểu tượng cổng:

# ethtool --reset <repr> giảm tải bộ lọc irq dma


Xem tin nhắn liên kết
---------------------
Thông báo liên kết sẽ không được hiển thị trên bảng điều khiển nếu việc phân phối
hạn chế tin nhắn hệ thống. Để xem thông báo liên kết trình điều khiển mạng trên
bảng điều khiển của bạn, hãy đặt dmesg thành 8 bằng cách nhập thông tin sau::

# dmesg-n 8

NOTE: Cài đặt này không được lưu trong các lần khởi động lại.


Cá nhân hóa thiết bị động
------------------------------
Cá nhân hóa thiết bị động (DDP) cho phép bạn thay đổi cách xử lý gói
đường dẫn của thiết bị bằng cách áp dụng gói hồ sơ cho thiết bị khi chạy.
Cấu hình có thể được sử dụng để, ví dụ, thêm hỗ trợ cho các giao thức mới, thay đổi
các giao thức hiện có hoặc thay đổi cài đặt mặc định. Cấu hình DDP cũng có thể được cuộn
trở lại mà không cần khởi động lại hệ thống.

Tải gói DDP trong quá trình khởi tạo thiết bị. Người lái xe tìm
ZZ0000ZZ trong root firmware của bạn (thường là ZZ0001ZZ
hoặc ZZ0002ZZ) và kiểm tra xem nó có chứa gói DDP hợp lệ không
tập tin.

NOTE: Bản phân phối của bạn có thể đã cung cấp tệp DDP mới nhất, nhưng nếu
Ice.pkg bị thiếu, bạn có thể tìm thấy nó trong kho phần mềm linux hoặc từ
intel.com.

Nếu driver không tải được gói DDP thì máy sẽ vào Safe
Chế độ. Chế độ an toàn vô hiệu hóa các tính năng nâng cao và hiệu suất và chỉ hỗ trợ
lưu lượng truy cập cơ bản và chức năng tối thiểu, chẳng hạn như cập nhật NVM hoặc
tải xuống trình điều khiển mới hoặc gói DDP. Chế độ an toàn chỉ áp dụng cho người bị ảnh hưởng
chức năng vật lý và không ảnh hưởng đến bất kỳ PF nào khác. Xem "Ethernet Intel(R)
Hướng dẫn sử dụng bộ điều hợp và thiết bị" để biết thêm chi tiết về DDP và Chế độ an toàn.

NOTES:

- Nếu bạn gặp sự cố với tệp gói DDP, bạn có thể cần phải tải xuống
  trình điều khiển được cập nhật hoặc tệp gói DDP. Xem thông điệp tường trình để biết thêm
  thông tin.

- File Ice.pkg là một liên kết tượng trưng đến file gói DDP mặc định.

- Bạn không thể cập nhật gói DDP nếu bất kỳ trình điều khiển PF nào đã được tải. Đến
  ghi đè lên một gói, dỡ bỏ tất cả các PF và sau đó tải lại trình điều khiển bằng gói mới
  gói.

- Chỉ PF được tải đầu tiên trên mỗi thiết bị mới có thể tải xuống gói cho thiết bị đó.

Bạn có thể cài đặt các tệp gói DDP cụ thể cho các thiết bị vật lý khác nhau trong
cùng một hệ thống. Để cài đặt tệp gói DDP cụ thể:

1. Tải xuống tệp gói DDP mà bạn muốn cho thiết bị của mình.

2. Đổi tên tệp Ice-xxxxxxxxxxxxxxxx.pkg, trong đó 'xxxxxxxxxxxxxxxx' là
   số sê-ri thiết bị PCI Express 64-bit duy nhất (ở dạng hex) của thiết bị bạn
   muốn gói được tải xuống. Tên tập tin phải bao gồm đầy đủ
   số sê-ri (bao gồm số 0 đứng đầu) và tất cả đều là chữ thường. Ví dụ,
   nếu số sê-ri 64-bit là b887a3ffffca0568 thì tên tệp sẽ là
   băng-b887a3ffffca0568.pkg.

Để tìm số sê-ri từ địa chỉ bus PCI, bạn có thể sử dụng
   lệnh sau::

# lspci -vv -s af:00.0 | grep -i nối tiếp
     Khả năng: [150 v1] Số sê-ri thiết bị b8-87-a3-ff-ff-ca-05-68

Bạn có thể sử dụng lệnh sau để định dạng số sê-ri mà không cần
   dấu gạch ngang::

# lspci -vv -s af:00.0 ZZ0000ZZ awk '{print $7}' | sed s/-//g
     b887a3ffffca0568

3. Sao chép tệp gói DDP đã đổi tên vào
   ZZ0000ZZ. Nếu thư mục chưa có
   tồn tại, hãy tạo nó trước khi sao chép tập tin.

4. Dỡ bỏ tất cả PF trên thiết bị.

5. Tải lại trình điều khiển bằng gói mới.

NOTE: Sự hiện diện của tệp gói DDP dành riêng cho thiết bị sẽ ghi đè quá trình tải
của tệp gói DDP mặc định (ice.pkg).


Giám đốc luồng Ethernet Intel(R)
-------------------------------
Giám đốc luồng Ethernet Intel thực hiện các tác vụ sau:

- Chỉ đạo nhận các gói theo luồng của chúng đến các hàng đợi khác nhau
- Cho phép kiểm soát chặt chẽ việc định tuyến luồng trong nền tảng
- Phù hợp với các luồng và lõi CPU cho mối quan hệ dòng chảy

NOTE: Trình điều khiển này hỗ trợ các loại luồng sau:

-IPv4
- TCPv4
- UDPv4
- SCTPv4
-IPv6
- TCPv6
- UDPv6
- SCTPv6

Mỗi loại luồng hỗ trợ các kết hợp địa chỉ IP hợp lệ (nguồn hoặc
đích) và các cổng UDP/TCP/SCTP (nguồn và đích). Bạn có thể cung cấp
chỉ địa chỉ IP nguồn, địa chỉ IP nguồn và cổng đích hoặc bất kỳ địa chỉ nào
sự kết hợp của một hoặc nhiều trong số bốn tham số này.

NOTE: Trình điều khiển này cho phép bạn lọc lưu lượng dựa trên linh hoạt do người dùng xác định
mẫu hai byte và bù đắp bằng cách sử dụng các trường mặt nạ và def người dùng ethtool. Chỉ
Các loại luồng L3 và L4 được hỗ trợ cho các bộ lọc linh hoạt do người dùng xác định. Đối với một
loại luồng nhất định, bạn phải xóa tất cả các bộ lọc Intel Ethernet Flow Director trước khi
thay đổi bộ đầu vào (đối với loại luồng đó).


Bộ lọc giám đốc luồng
---------------------
Bộ lọc Giám đốc luồng được sử dụng để điều hướng lưu lượng truy cập phù hợp với quy định
đặc điểm. Chúng được kích hoạt thông qua giao diện ntuple của ethtool. Để kích hoạt
hoặc tắt Intel Ethernet Flow Director và các bộ lọc sau::

# ethtool -K <ethX> ntuple <tắt|bật>

NOTE: Khi bạn tắt nhiều bộ lọc, tất cả các bộ lọc do người dùng lập trình sẽ
bị xóa khỏi bộ đệm trình điều khiển và phần cứng. Tất cả các bộ lọc cần thiết phải được thêm lại
khi ntuple được kích hoạt lại.

Để hiển thị tất cả các bộ lọc đang hoạt động::

# ethtool -u <ethX>

Để thêm bộ lọc mới::

# ethtool -U <ethX> loại luồng <type> src-ip <ip> [m <ip_mask>] dst-ip <ip>
  [m <ip_mask>] src-port <port> [m <port_mask>] dst-port <port> [m <port_mask>]
  hành động <hàng đợi>

Ở đâu:
    <ethX> - thiết bị Ethernet để lập trình
    <loại> - có thể là ip4, tcp4, udp4, sctp4, ip6, tcp6, udp6, sctp6
    <ip> - địa chỉ IP cần khớp
    <ip_mask> - địa chỉ IPv4 cần che dấu
              NOTE: Những bộ lọc này sử dụng mặt nạ đảo ngược.
    <port> - số cổng cần khớp
    <port_mask> - số nguyên 16 bit để tạo mặt nạ
              NOTE: Những bộ lọc này sử dụng mặt nạ đảo ngược.
    <queue> - hàng đợi hướng lưu lượng truy cập tới (-1 loại bỏ
              lưu lượng truy cập phù hợp)

Để xóa bộ lọc::

# ethtool -U <ethX> xóa <N>

Trong đó <N> là ID bộ lọc được hiển thị khi in tất cả các bộ lọc đang hoạt động,
  và cũng có thể được chỉ định bằng cách sử dụng "loc <N>" khi thêm bộ lọc.

EXAMPLES:

Để thêm bộ lọc chuyển gói đến hàng đợi 2::

# ethtool -U <ethX> loại luồng tcp4 src-ip 192.168.10.1 dst-ip \
  192.168.10.2 src-port 2000 dst-port 2001 hành động 2 [loc 1]

Để đặt bộ lọc chỉ sử dụng địa chỉ IP nguồn và đích::

# ethtool -U <ethX> loại luồng tcp4 src-ip 192.168.10.1 dst-ip \
  192.168.10.2 hành động 2 [loc 1]

Để đặt bộ lọc dựa trên mẫu và phần bù do người dùng xác định ::

# ethtool -U <ethX> loại luồng tcp4 src-ip 192.168.10.1 dst-ip \
  192.168.10.2 hành động 0x4FFFF do người dùng xác định 2 [loc 1]

trong đó giá trị của trường user-def chứa phần bù (4 byte) và
  mẫu (0xffff).

Để phù hợp với lưu lượng truy cập TCP được gửi từ 192.168.0.1, cổng 5300, được chuyển hướng đến 192.168.0.5,
cổng 80, sau đó gửi nó đến hàng đợi 7::

# ethtool -U enp130s0 kiểu luồng tcp4 src-ip 192.168.0.1 dst-ip 192.168.0.5
  src-port 5300 dst-port 80 hành động 7

Để thêm bộ lọc TCPv4 có mặt nạ một phần cho mạng con IP nguồn::

# ethtool -U <ethX> loại luồng tcp4 src-ip 192.168.0.0 m 0.255.255.255 dst-ip
  192.168.5.12 src-port 12600 dst-port 31 hành động 12

NOTES:

Đối với mỗi loại luồng, các bộ lọc được lập trình đều phải có cùng một kết quả phù hợp.
bộ đầu vào. Ví dụ: có thể chấp nhận việc đưa ra hai lệnh sau::

# ethtool -U enp130s0 loại luồng ip4 src-ip 192.168.0.1 src-port 5300 hành động 7
  # ethtool -U enp130s0 kiểu luồng ip4 src-ip 192.168.0.5 src-port 55 hành động 10

Tuy nhiên, việc đưa ra hai lệnh tiếp theo là không được chấp nhận vì lệnh đầu tiên
chỉ định src-ip và thứ hai chỉ định dst-ip::

# ethtool -U enp130s0 loại luồng ip4 src-ip 192.168.0.1 src-port 5300 hành động 7
  # ethtool -U enp130s0 loại luồng ip4 dst-ip 192.168.0.5 src-port 55 hành động 10

Lệnh thứ hai sẽ thất bại và có lỗi. Bạn có thể lập trình nhiều bộ lọc
với cùng các trường, sử dụng các giá trị khác nhau, nhưng trên một thiết bị, bạn không thể
lập trình hai bộ lọc tcp4 với các trường khớp khác nhau.

Trình điều khiển băng không hỗ trợ khớp trên một phần phụ của trường, do đó
các trường mặt nạ một phần không được hỗ trợ.


Bộ lọc Giám đốc Luồng Flex Byte
-------------------------------
Trình điều khiển cũng hỗ trợ khớp dữ liệu do người dùng xác định trong tải trọng gói.
Dữ liệu linh hoạt này được chỉ định bằng trường "user-def" của ethtool
lệnh theo cách sau:

.. table::

    ============================== ============================
    ``31    28    24    20    16`` ``15    12    8    4    0``
    ``offset into packet payload`` ``2 bytes of flexible data``
    ============================== ============================

Ví dụ,

::

  ... user-def 0x4FFFF ...

yêu cầu bộ lọc tìm 4 byte vào tải trọng và khớp giá trị đó với
0xFFFF. Phần bù dựa trên phần đầu của tải trọng chứ không phải phần
đầu của gói tin. Như vậy

::

loại luồng tcp4 ... user-def 0x8BEAF ...

sẽ khớp các gói TCP/IPv4 có giá trị 0xBEAF 8 byte vào
Tải trọng TCP/IPv4.

Lưu ý rằng tiêu đề ICMP được phân tích cú pháp thành 4 byte tiêu đề và 4 byte tải trọng.
Do đó, để khớp với byte đầu tiên của tải trọng, bạn thực sự phải thêm 4 byte vào
sự bù đắp. Cũng lưu ý rằng bộ lọc ip4 phù hợp với cả khung ICMP cũng như khung thô.
(không xác định) khung ip4, trong đó tải trọng sẽ là tải trọng L3 của IP4
khung.

Độ lệch tối đa là 64. Phần cứng sẽ chỉ đọc tối đa 64 byte dữ liệu
từ tải trọng. Phần bù phải chẵn vì dữ liệu linh hoạt là 2 byte
dài và phải được căn chỉnh theo byte 0 của tải trọng gói.

Phần bù linh hoạt do người dùng xác định cũng được coi là một phần của bộ đầu vào và
không thể lập trình riêng cho nhiều bộ lọc cùng loại. Tuy nhiên,
dữ liệu linh hoạt không phải là một phần của bộ đầu vào và nhiều bộ lọc có thể sử dụng
cùng một offset nhưng khớp với các dữ liệu khác nhau.


Luồng băm RSS
-------------
Cho phép bạn đặt byte băm cho mỗi loại luồng và bất kỳ sự kết hợp nào của một hoặc
nhiều tùy chọn hơn cho cấu hình byte băm Nhận tỷ lệ bên (RSS).

::

# ethtool -N <ethX> rx-flow-hash <loại> <tùy chọn>

<loại> ở đâu:
    tcp4 biểu thị TCP qua IPv4
    udp4 biểu thị UDP qua IPv4
    gtpc4 biểu thị GTP-C qua IPv4
    gtpc4t biểu thị GTP-C (bao gồm TEID) qua IPv4
    gtpu4 biểu thị GTP-U trên IPV4
    gtpu4e biểu thị GTP-U và Tiêu đề mở rộng trên IPV4
    gtpu4u biểu thị GTP-U PSC Đường lên trên IPV4
    gtpu4d biểu thị GTP-U PSC Đường xuống qua IPV4
    tcp6 biểu thị TCP qua IPv6
    udp6 biểu thị UDP qua IPv6
    gtpc6 biểu thị GTP-C qua IPv6
    gtpc6t biểu thị GTP-C (bao gồm TEID) qua IPv6
    gtpu6 biểu thị GTP-U trên IPV6
    gtpu6e biểu thị GTP-U và Tiêu đề mở rộng trên IPV6
    gtpu6u biểu thị GTP-U PSC Đường lên trên IPV6
    gtpu6d biểu thị GTP-U PSC Đường xuống qua IPV6
  Và <option> là một hoặc nhiều trong số:
    s Hash trên địa chỉ nguồn IP của gói Rx.
    d Băm địa chỉ đích IP của gói Rx.
    f Băm byte 0 và 1 của tiêu đề Lớp 4 của gói Rx.
    n Băm byte 2 và 3 của tiêu đề lớp 4 của gói Rx.
    e Băm gói GTP trên TEID (4byte) của gói Rx.


Điều khiển luồng nhận tăng tốc (aRFS)
----------------------------------------
Các thiết bị dựa trên bộ điều khiển Ethernet Intel(R) Series 800 hỗ trợ
Điều khiển luồng nhận tăng tốc (aRFS) trên PF. aRFS là cân bằng tải
cơ chế cho phép bạn hướng các gói tới cùng một CPU trong đó
ứng dụng đang chạy hoặc sử dụng các gói trong luồng đó.

NOTES:

- aRFS yêu cầu bật tính năng lọc ntuple thông qua ethtool.
- Hỗ trợ aRFS được giới hạn ở các loại gói sau:

- TCP qua IPv4 và IPv6
    - UDP qua IPv4 và IPv6
    - Gói không bị phân mảnh

- aRFS chỉ hỗ trợ các bộ lọc Flow Director, bao gồm
  địa chỉ IP nguồn/đích và cổng nguồn/đích.
- Giao diện ntuple của aRFS và ethtool đều sử dụng Flow Director của thiết bị. aRFS
  và nhiều tính năng có thể cùng tồn tại nhưng bạn có thể gặp phải những kết quả không mong muốn nếu
  có xung đột giữa yêu cầu aRFS và ntuple. Xem "Ethernet Intel(R)
  Giám đốc luồng" để biết thêm thông tin.

Để thiết lập aRFS:

1. Kích hoạt Intel Ethernet Flow Director và các bộ lọc ntuple bằng ethtool.

::

Bật # ethtool -K <ethX>

2. Thiết lập số lượng mục trong bảng luồng chung. Ví dụ:

::

# ZZ0000ZZ=16384
   # echo $NUM_RPS_ENTRIES > /proc/sys/net/core/rps_sock_flow_entries

3. Thiết lập số lượng mục trong bảng luồng trên mỗi hàng đợi. Ví dụ:

::

# ZZ0000ZZ=64
   Tệp # for trong /sys/class/net/$IFACE/queues/rx-*/rps_flow_cnt; làm
   # echo $(($NUM_RPS_ENTRIES/$NUM_RX_QUEUES)) > tệp $;
   # done

4. Vô hiệu hóa daemon cân bằng IRQ (đây chỉ là điểm dừng tạm thời của dịch vụ
   cho đến lần khởi động lại tiếp theo).

::

# systemctl dừng mất cân bằng

5. Cấu hình mối quan hệ ngắt.

Xem ZZ0000ZZ


Để tắt aRFS bằng ethtool::

Tắt # ethtool -K <ethX>

NOTE: Lệnh này sẽ vô hiệu hóa các bộ lọc ntuple và xóa mọi bộ lọc aRFS trong
phần mềm và phần cứng.

Trường hợp sử dụng ví dụ:

1. Đặt ứng dụng máy chủ trên CPU mong muốn (ví dụ: CPU 4).

::

# taskset -c 4 máy chủ mạng

2. Sử dụng netperf để định tuyến lưu lượng truy cập từ máy khách đến CPU 4 trên máy chủ với
   cấu hình aRFS. Ví dụ này sử dụng TCP qua IPv4.

::

# netperf -H <Địa chỉ IPv4 máy chủ> -t TCP_STREAM


Kích hoạt chức năng ảo (VF)
--------------------------------
Sử dụng sysfs để kích hoạt các chức năng ảo (VF).

Ví dụ: bạn có thể tạo 4 VF như sau::

# echo 4 > /sys/class/net/<ethX>/device/sriov_numvfs

Để tắt VF, hãy ghi 0 vào cùng một tệp::

# echo 0 > /sys/class/net/<ethX>/device/sriov_numvfs

Tổng số VF tối đa cho trình điều khiển băng là 256 (tất cả các cổng). Để kiểm tra
mỗi PF hỗ trợ bao nhiêu VF, hãy sử dụng lệnh sau::

# cat /sys/class/net/<ethX>/device/sriov_totalvfs

Lưu ý: Bạn không thể sử dụng SR-IOV khi tập hợp liên kết (LAG)/liên kết đang hoạt động và
ngược lại. Để thực thi điều này, trình điều khiển sẽ kiểm tra sự loại trừ lẫn nhau này.


Hiển thị số liệu thống kê VF trên PF
----------------------------------
Sử dụng lệnh sau để hiển thị số liệu thống kê cho PF và các VF của nó::

# ip -s hiển thị liên kết dev <ethX>

NOTE: Đầu ra của lệnh này có thể rất lớn do số lượng tối đa
VF có thể có.

Trình điều khiển PF sẽ hiển thị một tập hợp con các số liệu thống kê cho PF và cho tất cả các
VF được cấu hình. PF sẽ luôn in khối thống kê cho mỗi
trong số các VF có thể có và nó sẽ hiển thị số 0 cho tất cả các VF chưa được định cấu hình.


Định cấu hình gắn thẻ VLAN trên các cổng bộ điều hợp đã bật SR-IOV
--------------------------------------------------------
Để định cấu hình gắn thẻ VLAN cho các cổng trên bộ điều hợp hỗ trợ SR-IOV, hãy sử dụng
lệnh sau. Cấu hình VLAN phải được thực hiện trước trình điều khiển VF
được tải hoặc VM được khởi động. VF không biết thẻ VLAN đang được
được chèn vào khi truyền và loại bỏ trên các khung nhận được (đôi khi được gọi là "cổng
chế độ VLAN").

::

Bộ liên kết # ip dev <ethX> vf <id> vlan <vlan id>

Ví dụ: phần sau đây sẽ định cấu hình PF eth0 và VF đầu tiên trên VLAN 10::

Bộ liên kết # ip dev eth0 vf 0 vlan 10


Kích hoạt liên kết VF nếu cổng bị ngắt kết nối
----------------------------------------------
Nếu liên kết chức năng vật lý (PF) bị hỏng, bạn có thể buộc liên kết lên (từ
PF máy chủ) trên bất kỳ chức năng ảo (VF) nào được liên kết với PF.

Ví dụ: để buộc liên kết trên VF 0 được liên kết với PF eth0::

Bộ liên kết # ip bật trạng thái eth0 vf 0

Lưu ý: Nếu lệnh không hoạt động, có thể hệ thống của bạn không hỗ trợ lệnh này.


Đặt địa chỉ MAC cho VF
--------------------------------
Để thay đổi địa chỉ MAC cho VF được chỉ định::

Bộ liên kết # ip <ethX> vf 0 mac <địa chỉ>

Ví dụ::

Bộ liên kết # ip <ethX> vf 0 mac 00:01:02:03:04:05

Cài đặt này kéo dài cho đến khi PF được tải lại.

NOTE: Việc chỉ định địa chỉ MAC cho VF từ máy chủ sẽ vô hiệu hóa mọi
các yêu cầu tiếp theo để thay đổi địa chỉ MAC từ bên trong VM. Đây là một
tính năng bảo mật. VM không nhận thức được hạn chế này, vì vậy nếu đây là
đã thử trong VM, nó sẽ kích hoạt các sự kiện MDD.


VF đáng tin cậy và Chế độ lăng nhăng VF
-----------------------------------
Tính năng này cho phép bạn chỉ định một VF cụ thể là đáng tin cậy và cho phép điều đó
VF tin cậy yêu cầu chế độ lăng nhăng có chọn lọc trên Chức năng Vật lý (PF).

Để đặt VF là đáng tin cậy hoặc không đáng tin cậy, hãy nhập lệnh sau vào hộp
Giám sát viên::

Bộ liên kết # ip dev <ethX> vf 1 tin cậy [bật|tắt]

NOTE: Điều quan trọng là đặt VF thành đáng tin cậy trước khi đặt chế độ lăng nhăng.
Nếu VM không đáng tin cậy, PF sẽ bỏ qua các yêu cầu chế độ lăng nhăng từ
VF. Nếu máy ảo trở nên đáng tin cậy sau khi tải trình điều khiển VF, bạn phải tạo một
yêu cầu mới để đặt VF thành lăng nhăng.

Khi VF được chỉ định là đáng tin cậy, hãy sử dụng các lệnh sau trong VM để
đặt VF ở chế độ lăng nhăng.

Dành cho người lăng nhăng tất cả::

Đã bật liên kết # ip <ethX>
  Trong đó <ethX> là giao diện VF trong VM

Đối với Multicast lăng nhăng::

Đã bật liên kết # ip <ethX> allmulticast
  Trong đó <ethX> là giao diện VF trong VM

NOTE: Theo mặc định, cờ riêng ethtool vf-true-promisc-support được đặt thành
"tắt", nghĩa là chế độ lăng nhăng cho VF sẽ bị hạn chế. Để thiết lập
chế độ lăng nhăng để VF thành lăng nhăng thực sự và cho phép VF nhìn thấy tất cả
truy cập vào, sử dụng lệnh sau ::

# ethtool --set-priv-flags <ethX> bật vf-true-promisc-support

Cờ riêng vf-true-promisc-support không kích hoạt chế độ lăng nhăng;
đúng hơn, nó chỉ định loại chế độ lăng nhăng nào (có giới hạn hoặc đúng) mà bạn sẽ
nhận được khi bạn bật chế độ lăng nhăng bằng cách sử dụng các lệnh liên kết ip ở trên. Lưu ý
rằng đây là cài đặt chung ảnh hưởng đến toàn bộ thiết bị. Tuy nhiên,
Cờ riêng vf-true-promisc-support chỉ được hiển thị với PF đầu tiên của
thiết bị. PF vẫn ở chế độ bừa bãi hạn chế bất kể
cài đặt vf-true-promisc-support.

Tiếp theo, thêm giao diện VLAN trên giao diện VF. Ví dụ::

Liên kết # ip thêm liên kết eth2 tên eth2.100 loại vlan id 100

Lưu ý rằng thứ tự bạn đặt VF ở chế độ hỗn tạp và thêm
Giao diện VLAN không thành vấn đề (bạn có thể thực hiện trước). Kết quả trong việc này
ví dụ là VF sẽ nhận được tất cả lưu lượng truy cập được gắn thẻ VLAN 100.


Phát hiện trình điều khiển độc hại (MDD) cho VF
----------------------------------------
Một số thiết bị Intel Ethernet sử dụng tính năng Phát hiện trình điều khiển độc hại (MDD) để phát hiện
lưu lượng truy cập độc hại từ VF và vô hiệu hóa hàng đợi Tx/Rx hoặc loại bỏ hành vi vi phạm
gói cho đến khi thiết lập lại trình điều khiển VF xảy ra. Bạn có thể xem tin nhắn MDD trong PF
nhật ký hệ thống bằng lệnh dmesg.

- Nếu trình điều khiển PF ghi lại các sự kiện MDD từ VF, hãy xác nhận rằng VF chính xác
  trình điều khiển đã được cài đặt.
- Để khôi phục chức năng, bạn có thể tải lại VF hoặc VM theo cách thủ công hoặc bật
  tự động đặt lại VF.
- Khi bật tính năng đặt lại VF tự động, trình điều khiển PF sẽ ngay lập tức đặt lại
  VF và hàng đợi có thể kích hoạt lại khi nó phát hiện các sự kiện MDD trên đường nhận.
- Nếu việc đặt lại VF tự động bị tắt, PF sẽ không tự động đặt lại
  VF khi phát hiện các sự kiện MDD.

Để bật hoặc tắt tính năng đặt lại VF tự động, hãy sử dụng lệnh sau::

# ethtool --set-priv-flags <ethX> mdd-auto-reset-vf bật|tắt


Tính năng chống giả mạo MAC và VLAN cho VF
------------------------------------------
Khi trình điều khiển độc hại trên giao diện Chức năng ảo (VF) cố gắng gửi một
gói tin giả mạo, nó sẽ bị phần cứng loại bỏ và không được truyền đi.

NOTE: Tính năng này có thể bị tắt đối với một VF cụ thể::

Bộ liên kết # ip <ethX> vf <vf id> spoofchk {tắt|bật}


Khung Jumbo
------------
Hỗ trợ Khung Jumbo được bật bằng cách thay đổi Đơn vị truyền tối đa (MTU)
đến giá trị lớn hơn giá trị mặc định là 1500.

Sử dụng lệnh ifconfig để tăng kích thước MTU. Ví dụ: nhập
theo sau trong đó <ethX> là số giao diện::

# ifconfig <ethX> mtu 9000 trở lên

Ngoài ra, bạn có thể sử dụng lệnh ip như sau ::

Bộ liên kết # ip mtu 9000 dev <ethX>
  Liên kết # ip thiết lập dev <ethX>

Cài đặt này không được lưu trong các lần khởi động lại.


NOTE: Cài đặt MTU tối đa cho khung jumbo là 9702. Điều này tương ứng với
kích thước khung jumbo tối đa là 9728 byte.

NOTE: Trình điều khiển này sẽ cố gắng sử dụng nhiều bộ đệm có kích thước trang để nhận
mỗi gói lớn. Điều này sẽ giúp tránh được vấn đề thiếu bộ đệm khi
phân bổ các gói nhận.

NOTE: Việc mất gói có thể ảnh hưởng lớn hơn đến thông lượng khi bạn sử dụng jumbo
khung. Nếu bạn nhận thấy hiệu suất giảm sau khi bật khung hình lớn,
cho phép kiểm soát luồng có thể giảm thiểu vấn đề.


Cấu hình tốc độ và song công
------------------------------
Khi giải quyết các vấn đề về tốc độ và cấu hình song công, bạn cần phân biệt
giữa bộ điều hợp dựa trên đồng và bộ điều hợp dựa trên sợi quang.

Ở chế độ mặc định, Bộ điều hợp mạng Ethernet Intel(R) sử dụng cáp đồng
các kết nối sẽ cố gắng tự động đàm phán với đối tác liên kết của mình để xác định
thiết lập tốt nhất. Nếu bộ điều hợp không thể thiết lập liên kết với đối tác liên kết
bằng cách sử dụng tính năng tự động đàm phán, bạn có thể cần phải định cấu hình bộ điều hợp và liên kết theo cách thủ công
hợp tác với các cài đặt giống hệt nhau để thiết lập các gói liên kết và truyền. Điều này nên
chỉ cần thiết khi cố gắng liên kết với một switch cũ hơn không
hỗ trợ tự động đàm phán hoặc một tốc độ cụ thể hoặc
chế độ song công. Đối tác liên kết của bạn phải phù hợp với cài đặt bạn chọn. Tốc độ 1 Gbps
và cao hơn không thể bị ép buộc. Sử dụng cài đặt quảng cáo tự động thương lượng để
đặt thủ công các thiết bị ở tốc độ 1 Gbps trở lên.

Quảng cáo tốc độ, song công và tự động thương lượng được định cấu hình thông qua
tiện ích ethtool. Để có phiên bản mới nhất, hãy tải xuống và cài đặt ethtool từ
trang web sau:

ZZ0000ZZ

Để xem cấu hình tốc độ mà thiết bị của bạn hỗ trợ, hãy chạy như sau ::

# ethtool <ethX>

Thận trọng: Chỉ những quản trị viên mạng có kinh nghiệm mới nên buộc tốc độ và song công
hoặc thay đổi quảng cáo tự động đàm phán theo cách thủ công. Các cài đặt ở công tắc phải
luôn phù hợp với cài đặt bộ chuyển đổi. Hiệu suất của bộ điều hợp có thể bị ảnh hưởng hoặc
bộ chuyển đổi có thể không hoạt động nếu bạn định cấu hình bộ chuyển đổi khác với
chuyển đổi.


Cầu nối trung tâm dữ liệu (DCB)
--------------------------
NOTE: Hạt nhân giả định rằng TC0 có sẵn và sẽ tắt Luồng ưu tiên
Điều khiển (PFC) trên thiết bị nếu TC0 không khả dụng. Để khắc phục điều này, hãy đảm bảo TC0 được
được bật khi thiết lập DCB trên bộ chuyển mạch của bạn.

DCB là cấu hình triển khai Chất lượng dịch vụ trong phần cứng. Nó sử dụng
thẻ ưu tiên VLAN (802.1p) để lọc lưu lượng. Điều đó có nghĩa là có 8
các mức độ ưu tiên khác nhau mà lưu lượng truy cập có thể được lọc vào. Nó cũng cho phép
điều khiển luồng ưu tiên (802.1Qbb) có thể hạn chế hoặc loại bỏ số lượng
rớt gói tin khi mạng căng thẳng. Băng thông có thể được phân bổ cho từng
những ưu tiên này được thực thi ở cấp độ phần cứng (802.1Qaz).

DCB thường được cấu hình trên mạng bằng giao thức DCBX (802.1Qaz), một
chuyên môn của LLDP (802.1AB). Trình điều khiển băng hỗ trợ những điều sau
các biến thể loại trừ lẫn nhau của hỗ trợ DCBX:

1) Tác nhân LLDP dựa trên phần sụn
2) Tác nhân LLDP dựa trên phần mềm

Ở chế độ dựa trên phần sụn, phần sụn chặn tất cả lưu lượng LLDP và xử lý DCBX
đàm phán một cách minh bạch cho người dùng. Ở chế độ này, bộ chuyển đổi hoạt động ở chế độ
Chế độ DCBX "sẵn sàng", nhận cài đặt DCB từ đối tác liên kết (thường là
chuyển đổi). Người dùng cục bộ chỉ có thể truy vấn cấu hình DCB đã thương lượng. cho
thông tin về cách cấu hình các tham số DCBX trên switch, vui lòng tham khảo
chuyển đổi tài liệu của nhà sản xuất.

Ở chế độ dựa trên phần mềm, lưu lượng LLDP được chuyển tiếp đến ngăn xếp mạng và người dùng
không gian, nơi tác nhân phần mềm có thể xử lý nó. Ở chế độ này, bộ chuyển đổi có thể
hoạt động ở chế độ DCBX "sẵn sàng" hoặc "không sẵn sàng" và cấu hình DCB có thể
vừa được truy vấn vừa được đặt cục bộ. Chế độ này yêu cầu Tác nhân LLDP dựa trên FW để
bị vô hiệu hóa.

NOTE:

- Bạn có thể bật và tắt Tác nhân LLDP dựa trên phần sụn bằng cách sử dụng ethtool
  cờ riêng. Tham khảo "FW-LLDP (Giao thức khám phá lớp liên kết chương trình cơ sở)"
  trong README này để biết thêm thông tin.
- Ở chế độ DCBX dựa trên phần mềm, bạn có thể định cấu hình các thông số DCB bằng phần mềm
  Các tác nhân LLDP/DCBX có giao diện với DCB Netlink API của nhân Linux. Chúng tôi
  khuyên bạn nên sử dụng OpenLLDP làm tác nhân DCBX khi chạy ở chế độ phần mềm. cho
  để biết thêm thông tin, hãy xem trang man OpenLLDP và
  ZZ0000ZZ
- Trình điều khiển triển khai lớp giao diện netlink DCB để cho phép không gian người dùng
  để liên lạc với trình điều khiển và truy vấn cấu hình DCB cho cổng.
- iSCSI với DCB không được hỗ trợ.


FW-LLDP (Giao thức khám phá lớp liên kết chương trình cơ sở)
------------------------------------------------
Sử dụng ethtool để thay đổi cài đặt FW-LLDP. Cài đặt FW-LLDP dành cho mỗi cổng và
vẫn tồn tại trên ủng.

Để bật LLDP::

# ethtool --set-priv-flags <ethX> fw-lldp-agent bật

Để tắt LLDP::

# ethtool --set-priv-flags <ethX> tắt tác nhân fw-lldp

Để kiểm tra cài đặt LLDP hiện tại::

# ethtool --show-priv-flags <ethX>

NOTE: Bạn phải bật thuộc tính UEFI HII "LLDP Agent" cho cài đặt này để
có hiệu lực. Nếu "LLDP AGENT" được đặt thành tắt, bạn không thể bật nó từ
hệ điều hành.


Kiểm soát dòng chảy
------------
Kiểm soát luồng Ethernet (IEEE 802.3x) có thể được cấu hình bằng ethtool để kích hoạt
nhận và truyền các khung tạm dừng cho băng. Khi truyền được kích hoạt,
các khung tạm dừng được tạo ra khi bộ đệm gói nhận vượt qua vùng đệm được xác định trước
ngưỡng. Khi nhận được kích hoạt, thiết bị truyền sẽ tạm dừng trong một thời gian
độ trễ được chỉ định khi nhận được khung tạm dừng.

NOTE: Bạn phải có đối tác liên kết có khả năng kiểm soát luồng.

Kiểm soát luồng bị tắt theo mặc định.

Sử dụng ethtool để thay đổi cài đặt kiểm soát luồng.

Để bật hoặc tắt Kiểm soát luồng Rx hoặc Tx::

# ethtool -A <ethX> rx <on|off> tx <on|off>

Lưu ý: Lệnh này chỉ bật hoặc tắt Kiểm soát luồng nếu tự động đàm phán được
bị vô hiệu hóa. Nếu bật tự động đàm phán, lệnh này sẽ thay đổi các tham số
được sử dụng để tự động đàm phán với đối tác liên kết.

Lưu ý: Tự động đàm phán Kiểm soát luồng là một phần của tự động đàm phán liên kết. Tùy theo
trên thiết bị của bạn, bạn có thể không thay đổi được cài đặt tự động thương lượng.

NOTE:

- Trình điều khiển băng yêu cầu kiểm soát luồng trên cả cổng và đối tác liên kết. Nếu
  Kiểm soát luồng bị vô hiệu hóa ở một trong các bên, cổng có thể bị treo
  giao thông đông đúc.
- Bạn có thể gặp phải sự cố với điều khiển luồng cấp liên kết (LFC) sau khi tắt
  DCB. Trạng thái LFC có thể hiển thị là đã bật nhưng lưu lượng truy cập không bị tạm dừng. Để giải quyết
  vấn đề này, hãy vô hiệu hóa và kích hoạt lại LFC bằng ethtool::

# ethtool -A <ethX> tắt rx tắt tx
   # ethtool -A <ethX> rx trên tx trên


NAPI
----

Trình điều khiển này hỗ trợ NAPI (chế độ bỏ phiếu Rx).

Xem ZZ0000ZZ để biết thêm thông tin.

MACVLAN
-------
Trình điều khiển này hỗ trợ MACVLAN. Hỗ trợ hạt nhân cho MACVLAN có thể được kiểm tra bằng cách
kiểm tra xem trình điều khiển MACVLAN đã được tải chưa. Bạn có thể chạy 'lsmod | grep macvlan' tới
xem driver MACVLAN đã được nạp chưa hay chạy 'modprobe macvlan' để thử tải
trình điều khiển MACVLAN.

NOTE:

- Ở chế độ passthru, bạn chỉ có thể thiết lập một thiết bị MACVLAN. Nó sẽ kế thừa
  Địa chỉ MAC của thiết bị PF (Chức năng vật lý) cơ bản.


Hỗ trợ IEEE 802.1ad (QinQ)
---------------------------
Tiêu chuẩn IEEE 802.1ad, được gọi một cách không chính thức là QinQ, cho phép nhiều VLAN
ID trong một khung Ethernet duy nhất. ID VLAN đôi khi được gọi là
Do đó, "thẻ" và nhiều ID VLAN được gọi là "ngăn xếp thẻ". Ngăn xếp thẻ
cho phép tạo đường hầm L2 và khả năng phân chia lưu lượng trong một phạm vi cụ thể
ID VLAN, cùng với các mục đích sử dụng khác.

NOTES:

- Nhận giảm tải tổng kiểm tra và khả năng tăng tốc VLAN không được hỗ trợ cho 802.1ad
  (QinQ) gói.

- Lưu lượng truy cập 0x88A8 sẽ không được nhận trừ khi tính năng tước VLAN bị tắt với
  lệnh sau::

Tắt # ethtool -K <ethX> rxvlan

- Không thể sử dụng Vlan kép 0x88A8/0x8100 với 0x8100 hoặc 0x8100/0x8100 VLANS
  được cấu hình trên cùng một cổng. Lưu lượng truy cập 0x88a8/0x8100 sẽ không được nhận nếu
  0x8100 Vlan được cấu hình.

- VF chỉ có thể truyền lưu lượng 0x88A8/0x8100 (tức là 802.1ad/802.1Q) nếu:

1) VF không được gán cổng VLAN.
    2) spoofchk bị vô hiệu hóa khỏi PF. Nếu bạn kích hoạt spoofchk, VF sẽ
       không truyền lưu lượng 0x88A8/0x8100.

- VF có thể không nhận được tất cả lưu lượng truy cập mạng dựa trên tiêu đề VLAN bên trong
  khi chế độ lăng nhăng thực sự của VF (vf-true-promisc-support) và Vlan kép được
  được bật ở chế độ SR-IOV.

Sau đây là ví dụ về cách định cấu hình 802.1ad (QinQ)::

Liên kết # ip thêm liên kết eth0 eth0.24 loại vlan proto 802.1ad id 24
  Liên kết # ip thêm liên kết eth0.24 eth0.24.371 loại vlan proto 802.1Q id 371

Trong đó "24" và "371" là ID VLAN mẫu.


Giảm tải không trạng thái đường hầm/lớp phủ
---------------------------------
Các đường hầm và lớp phủ được hỗ trợ bao gồm VXLAN, GENEVE và các lớp phủ khác tùy thuộc vào
cấu hình phần cứng và phần mềm. Giảm tải không trạng thái được bật theo mặc định.

Để xem trạng thái hiện tại của tất cả các lần giảm tải::

# ethtool -k <ethX>


Giảm tải phân đoạn UDP
------------------------
Cho phép bộ chuyển đổi giảm tải phân đoạn truyền tải của các gói UDP bằng
tải trọng lên tới 64K vào các khung Ethernet hợp lệ. Bởi vì phần cứng của bộ điều hợp là
có thể hoàn thành việc phân đoạn dữ liệu nhanh hơn nhiều so với phần mềm hệ điều hành,
tính năng này có thể cải thiện hiệu suất truyền tải.
Ngoài ra, bộ điều hợp có thể sử dụng ít tài nguyên CPU hơn.

NOTE:

- Ứng dụng gửi gói UDP phải hỗ trợ giảm tải phân đoạn UDP.

Để bật/tắt Giảm tải phân đoạn UDP, hãy ra lệnh sau ::

# ethtool -K <ethX> phân đoạn tx-udp [tắt|bật]

Giao diện chân PTP
-----------------
Tất cả các bộ điều hợp đều hỗ trợ giao diện pin PTP tiêu chuẩn. SDP (Pin có thể xác định bằng phần mềm)
là các chân đơn có cả đầu ra định kỳ và dấu thời gian bên ngoài
được hỗ trợ. Ngoài ra còn có các chân đầu vào/đầu ra vi sai cụ thể (TIME_SYNC,
1PPS) chỉ với một trong các chức năng được hỗ trợ.

Có các bộ điều hợp với DPLL, trong đó các chân được kết nối với DPLL thay vì
được phơi bày trên bảng. Bạn phải biết rằng trong những cấu hình đó,
chỉ có các chân SDP lộ ra ngoài và mỗi chân có hướng cố định riêng.
Để xem tín hiệu đầu vào trên các chân PTP đó, bạn cần cấu hình DPLL đúng cách.
Tín hiệu đầu ra chỉ hiển thị trên DPLL và để gửi nó đến các chân SMA/U.FL trên bo mạch,
Các chân đầu ra DPLL phải được cấu hình thủ công.

Mô-đun GNSS
-----------
Yêu cầu kernel được biên dịch với CONFIG_GNSS=y hoặc CONFIG_GNSS=m.
Cho phép người dùng đọc tin nhắn từ mô-đun phần cứng GNSS và hỗ trợ viết
lệnh. Nếu mô-đun hiện diện về mặt vật lý, thiết bị GNSS sẽ được sinh ra:
ZZ0000ZZ.
Giao thức của lệnh ghi phụ thuộc vào mô-đun phần cứng GNSS vì
trình điều khiển ghi byte thô bằng đối tượng GNSS vào bộ thu thông qua i2c. làm ơn
tham khảo tài liệu mô-đun GNSS phần cứng để biết chi tiết cấu hình.


Ghi nhật ký chương trình cơ sở (FW)
---------------------
Trình điều khiển chỉ hỗ trợ ghi nhật ký FW thông qua giao diện debugfs trên PF 0. FW
chạy trên NIC phải hỗ trợ ghi nhật ký FW; nếu FW không hỗ trợ ghi nhật ký FW
tệp 'fwlog' sẽ không được tạo trong thư mục Ice debugfs.

Cấu hình mô-đun
~~~~~~~~~~~~~~~~~~~~
Ghi nhật ký chương trình cơ sở được định cấu hình trên cơ sở từng mô-đun. Mỗi mô-đun có thể được đặt thành
một giá trị độc lập với các mô-đun khác (trừ khi mô-đun 'tất cả' được chỉ định).
Các mô-đun sẽ được khởi tạo trong thư mục 'fwlog/modules'.

Người dùng có thể đặt mức nhật ký cho mô-đun bằng cách ghi vào tệp mô-đun như
cái này::

# echo <log_level> > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/modules/<module>

Ở đâu

* log_level là tên như được mô tả bên dưới. Mỗi cấp độ bao gồm
  tin nhắn từ cấp độ trước/thấp hơn

* không có
      * lỗi
      * cảnh báo
      * bình thường
      * dài dòng

* mô-đun là tên đại diện cho mô-đun nhận sự kiện. các
  tên mô-đun là

* chung
      * ctrl
      * liên kết
      * link_topo
      * dnl
      * i2c
      * sdp
      * mdio
      * quản trị viên
      * hdma
      * lldp
      * dcbx
      * dcb
      * xlr
      * nvm
      * xác thực
      * vpd
      * iosf
      * trình phân tích cú pháp
      * sw
      * lập lịch
      *txq
      * trả lời
      * bài đăng
      * cơ quan giám sát
      * nhiệm vụ_công văn
      * mg
      * đồng bộ hóa
      * sức khỏe
      * tsdrv
      *preg
      * mdlver
      * tất cả

Tên 'all' rất đặc biệt và cho phép người dùng đặt tất cả các mô-đun thành
log_level được chỉ định hoặc để đọc log_level của tất cả các mô-đun.

Ví dụ sử dụng để cấu hình các mô-đun
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Để đặt một mô-đun thành 'tiết tiết'::

# echo dài dòng > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/modules/link

Để thiết lập nhiều mô-đun, hãy ra lệnh nhiều lần::

# echo dài dòng > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/modules/link
  Cảnh báo # echo > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/modules/ctrl
  # echo không có > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/modules/dcb

Để đặt tất cả các mô-đun thành cùng một giá trị::

# echo bình thường > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/modules/all

Để đọc log_level của một mô-đun cụ thể (ví dụ: mô-đun 'chung')::

# cat /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/modules/general

Để đọc log_level của tất cả các mô-đun::

# cat /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/modules/all

Bật nhật ký FW
~~~~~~~~~~~~~~~
Việc định cấu hình các mô-đun sẽ cho FW biết rằng các mô-đun được định cấu hình sẽ
tạo ra các sự kiện mà trình điều khiển quan tâm nhưng ZZ0000ZZ lại gửi
các sự kiện tới trình điều khiển cho đến khi thông báo kích hoạt được gửi đến FW. Để làm điều này
người dùng có thể viết 1 (bật) hoặc 0 (tắt) vào 'fwlog/enable'. Một ví dụ
là::

# echo 1 > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/enable

Truy xuất dữ liệu nhật ký FW
~~~~~~~~~~~~~~~~~~~~~~
Dữ liệu nhật ký FW có thể được truy xuất bằng cách đọc từ 'fwlog/data'. Người dùng có thể
ghi bất kỳ giá trị nào vào 'fwlog/data' để xóa dữ liệu. Dữ liệu chỉ có thể bị xóa
khi tính năng ghi nhật ký FW bị tắt. Dữ liệu nhật ký FW là một tệp nhị phân được gửi tới
Intel và được sử dụng để giúp gỡ lỗi các vấn đề của người dùng.

Một ví dụ để đọc dữ liệu là::

# cat /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/data > fwlog.bin

Một ví dụ để xóa dữ liệu là::

# echo 0 > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/data

Thay đổi tần suất gửi sự kiện nhật ký tới trình điều khiển
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển nhận dữ liệu nhật ký FW từ Hàng đợi Nhận của Quản trị viên (ARQ). các
tần số mà FW gửi các sự kiện ARQ có thể được cấu hình bằng cách ghi vào
'fwlog/nr_messages'. Phạm vi là 1-128 (1 có nghĩa là đẩy mọi thông điệp tường trình, 128
có nghĩa là chỉ đẩy khi bộ đệm lệnh AQ tối đa đầy). Giá trị được đề xuất là
10. Người dùng có thể xem giá trị được cấu hình bằng cách đọc
'fwlog/nr_messages'. Một ví dụ để đặt giá trị là::

# echo 50 > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/nr_messages

Định cấu hình dung lượng bộ nhớ được sử dụng để lưu trữ dữ liệu nhật ký FW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển lưu trữ dữ liệu nhật ký FW trong trình điều khiển. Kích thước mặc định của bộ nhớ
dùng để lưu trữ dữ liệu là 1MB. Một số trường hợp sử dụng có thể yêu cầu nhiều hoặc ít dữ liệu hơn
người dùng có thể thay đổi dung lượng bộ nhớ được phân bổ cho dữ liệu nhật ký FW.
Để thay đổi dung lượng bộ nhớ, hãy ghi vào 'fwlog/log_size'. Giá trị phải là
một trong: 128K, 256K, 512K, 1M hoặc 2M. Ghi nhật ký FW phải được tắt để thay đổi
giá trị. Một ví dụ về việc thay đổi giá trị là::

# echo 128K > /sys/kernel/debug/ice/0000\:18\:00.0/fwlog/log_size


Tối ưu hóa hiệu suất
========================
Các cài đặt mặc định của trình điều khiển nhằm mục đích phù hợp với nhiều khối lượng công việc khác nhau, nhưng nếu tiếp tục
cần phải tối ưu hóa, chúng tôi khuyên bạn nên thử nghiệm những điều sau
cài đặt.


Kích thước vòng mô tả Rx
-----------------------
Để giảm số lượng gói Rx bị loại bỏ, hãy tăng số lượng Rx
mô tả cho mỗi vòng Rx bằng ethtool.

Kiểm tra xem giao diện có bị rớt gói Rx do bộ đệm đầy không
  (rx_dropped.nic có thể có nghĩa là không có băng thông PCIe)::

# ethtool -S <ethX> | grep "rx_dropped"

Nếu lệnh trước đó hiển thị số lần giảm trên hàng đợi, nó có thể giúp tăng
  số lượng mô tả sử dụng 'ethtool -G'::

# ethtool -G <ethX> rx <N>
    Trong đó <N> là số lượng mục/mô tả vòng mong muốn

Điều này có thể cung cấp bộ đệm tạm thời cho các vấn đề tạo ra độ trễ trong khi
  các bộ mô tả quy trình của CPU.


Giới hạn tốc độ ngắt
-----------------------
Trình điều khiển này hỗ trợ cơ chế điều chỉnh tốc độ ngắt thích ứng (ITR)
được điều chỉnh cho khối lượng công việc chung. Người dùng có thể tùy chỉnh tốc độ ngắt
kiểm soát khối lượng công việc cụ thể, thông qua ethtool, điều chỉnh số lượng
micro giây giữa các lần ngắt.

Để đặt tốc độ ngắt theo cách thủ công, bạn phải tắt chế độ thích ứng::

# ethtool -C <ethX> tắt Adaptive-rx Tắt Adaptive-tx

Để sử dụng CPU thấp hơn:

Vô hiệu hóa ITR thích ứng và giảm các ngắt Rx và Tx. Các ví dụ dưới đây
  ảnh hưởng đến mọi hàng đợi của giao diện được chỉ định.

Đặt rx-usecs và tx-usecs thành 80 sẽ giới hạn số lần ngắt ở khoảng
  12.500 ngắt mỗi giây trên mỗi hàng đợi::

# ethtool -C <ethX> thích ứng-rx tắt thích ứng-tx tắt rx-usecs 80 tx-usecs 80

Để giảm độ trễ:

Tắt ITR và ITR thích ứng bằng cách đặt rx-usecs và tx-usecs thành 0
  sử dụng ethtool::

# ethtool -C <ethX> thích ứng-rx tắt thích ứng-tx tắt rx-usecs 0 tx-usecs 0

Cài đặt tốc độ ngắt trên mỗi hàng đợi:

Các ví dụ sau dành cho hàng đợi 1 và 3, nhưng bạn có thể điều chỉnh các
  hàng đợi.

Để tắt ITR thích ứng Rx và đặt Rx ITR tĩnh thành 10 micro giây hoặc
  khoảng 100.000 ngắt/giây, đối với hàng đợi 1 và 3::

# ethtool --per-queue <ethX> queue_mask 0xa --tắt liên kết thích ứng-rx
    rx-usecs 10

Để hiển thị cài đặt hợp nhất hiện tại cho hàng đợi 1 và 3::

# ethtool --per-queue <ethX> queue_mask 0xa --show-coalesce

Giới hạn tỷ lệ ngắt bằng cách sử dụng rx-usecs-high:

:Phạm vi hợp lệ: 0-236 (0=không giới hạn)

Phạm vi từ 0-236 micro giây cung cấp phạm vi hiệu quả từ 4.237 đến
   250.000 ngắt mỗi giây. Giá trị của rx-usecs-high có thể được đặt
   độc lập với rx-usecs và tx-usecs trong cùng một lệnh ethtool và là
   cũng độc lập với thuật toán điều tiết ngắt thích ứng. các
   phần cứng cơ bản hỗ trợ độ chi tiết trong khoảng thời gian 4 micro giây, do đó
   các giá trị liền kề có thể dẫn đến cùng một tốc độ ngắt.

Lệnh sau sẽ vô hiệu hóa điều tiết ngắt thích ứng và cho phép
  tối đa là 5 micro giây trước khi cho biết việc nhận hoặc truyền đã được thực hiện
  hoàn thành. Tuy nhiên, thay vì gây ra tới 200.000 lần ngắt mỗi lần
  thứ hai, nó giới hạn tổng số lần ngắt mỗi giây ở mức 50.000 thông qua rx-usecs-high
  tham số.

  ::

# ethtool -C <ethX> thích ứng-rx tắt thích ứng-tx tắt rx-usecs-cao 20
    rx-usecs 5 tx-usecs 5


Môi trường ảo hóa
------------------------
Ngoài những gợi ý khác trong phần này, những điều sau đây có thể
hữu ích để tối ưu hóa hiệu suất trong VM.

Sử dụng cơ chế thích hợp (vcpupin) trong VM, ghim CPU vào
  LCPU riêng lẻ, đảm bảo sử dụng một bộ CPU có trong
  local_cpulist của thiết bị: ZZ0000ZZ.

Định cấu hình càng nhiều hàng đợi Rx/Tx trong VM càng tốt. (Xem trình điều khiển iavf
  tài liệu về số lượng hàng đợi được hỗ trợ.) Ví dụ::

# ethtool -L <virt_interface> rx <max> tx <max>


Ủng hộ
=======
Để biết thông tin chung, hãy truy cập trang web hỗ trợ của Intel tại:
ZZ0000ZZ

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến sự cố
tới intel-wired-lan@lists.osuosl.org.


Nhãn hiệu
==========
Intel là nhãn hiệu hoặc nhãn hiệu đã đăng ký của Tập đoàn Intel hoặc
các công ty con ở Hoa Kỳ và/hoặc các quốc gia khác.

* Các tên và thương hiệu khác có thể được coi là tài sản của người khác.