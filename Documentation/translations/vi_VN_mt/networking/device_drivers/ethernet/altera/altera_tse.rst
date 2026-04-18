.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/altera/altera_tse.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

==========================================
Trình điều khiển MAC Ethernet ba tốc độ của Altera
=======================================

Bản quyền ZZ0000ZZ 2008-2014 Tập đoàn Altera

Đây là trình điều khiển cho bộ điều khiển Altera Triple-Speed Ethernet (TSE)
sử dụng các thành phần IP mềm DMA SGDMA và MSGDMA. Người lái xe sử dụng
bus nền tảng để lấy tài nguyên thành phần. Các thiết kế được sử dụng để kiểm tra điều này
trình điều khiển được xây dựng cho bo mạch Cyclone(R) V SOC FPGA, bo mạch Cyclone(R) V FPGA,
và được thử nghiệm riêng biệt với máy chủ bộ xử lý ARM và NIOS. Công dụng dự kiến
trường hợp là các giao tiếp đơn giản giữa một hệ thống nhúng và một thiết bị ngang hàng bên ngoài
để biết trạng thái và cấu hình đơn giản của hệ thống nhúng.

Để biết thêm thông tin, hãy truy cập www.altera.com và www.rocketboards.org. Hỗ trợ
diễn đàn dành cho người lái xe có thể được tìm thấy trên www.rocketboards.org và một thiết kế được sử dụng
để kiểm tra trình điều khiển này cũng có thể được tìm thấy ở đó. Hỗ trợ cũng có sẵn từ
người duy trì trình điều khiển này, được tìm thấy trong MAINTAINERS.

Các thành phần Ethernet ba tốc độ, SGDMA và MSGDMA đều là IP mềm
các bộ phận có thể được lắp ráp và tích hợp vào FPGA bằng Altera
Chuỗi công cụ Quartus. Quartus 13.1 và 14.0 được sử dụng để xây dựng thiết kế
trình điều khiển này đã được thử nghiệm chống lại. Công cụ sopc2dts được sử dụng để tạo
cây thiết bị cho trình điều khiển và có thể tìm thấy tại rocketboards.org.

Chức năng thăm dò trình điều khiển kiểm tra cây thiết bị và xác định xem
Phiên bản Ethernet ba tốc độ đang sử dụng thành phần SGDMA hoặc MSGDMA. các
chức năng thăm dò sau đó sẽ cài đặt tập hợp các quy trình DMA thích hợp để
khởi tạo, thiết lập truyền, nhận và xử lý ngắt nguyên thủy cho
các cấu hình tương ứng.

Thành phần SGDMA sẽ không được dùng nữa trong tương lai gần (trong vòng 1-2 năm tới
năm kể từ thời điểm viết bài này vào đầu năm 2014) để ủng hộ thành phần MSGDMA.
Hỗ trợ SGDMA được bao gồm cho các thiết kế và tài liệu tham khảo hiện có trong trường hợp
nhà phát triển mong muốn hỗ trợ trình điều khiển và logic DMA mềm của riêng họ. bất kỳ
thiết kế mới không nên sử dụng SGDMA.

SGDMA chỉ hỗ trợ một hoạt động truyền hoặc nhận duy nhất tại một thời điểm và
do đó sẽ không hoạt động tốt bằng IP mềm MSGDMA. làm ơn
hãy truy cập www.altera.com để biết lỗi SGDMA đã được ghi lại.

DMA thu thập phân tán không được SGDMA hoặc MSGDMA hỗ trợ tại thời điểm này.
DMA thu thập phân tán sẽ được thêm vào bản cập nhật bảo trì trong tương lai cho bản này
người lái xe.

Khung Jumbo không được hỗ trợ tại thời điểm này.

Trình điều khiển giới hạn hoạt động của PHY ở mức 10/100Mbps và chưa được hỗ trợ đầy đủ
đã thử nghiệm ở tốc độ 1Gbps. Hỗ trợ này sẽ được bổ sung trong bản cập nhật bảo trì trong tương lai.

1. Cấu hình hạt nhân
=======================

Tùy chọn cấu hình kernel là ALTERA_TSE:

Trình điều khiển thiết bị ---> Hỗ trợ thiết bị mạng ---> Hỗ trợ trình điều khiển Ethernet --->
 Hỗ trợ Ethernet ba tốc độ MAC của Altera (ALTERA_TSE)

2. Danh sách thông số driver
=========================

- gỡ lỗi: mức thông báo (0: không có đầu ra, 16: tất cả);
	- dma_rx_num: Số lượng ký tự mô tả trong danh sách RX (mặc định là 64);
	- dma_tx_num: Số lượng ký tự mô tả trong danh sách TX (mặc định là 64).

3. Tùy chọn dòng lệnh
=======================

Các tham số trình điều khiển cũng có thể được truyền trong dòng lệnh bằng cách sử dụng::

altera_tse=dma_rx_num:128,dma_tx_num:512

4. Thông tin và lưu ý về tài xế
===============================

4.1. Quá trình truyền tải
---------------------
Khi chương trình truyền của trình điều khiển được gọi bởi kernel, nó sẽ thiết lập một
bộ mô tả truyền bằng cách gọi thủ tục truyền DMA cơ bản (SGDMA hoặc
MSGDMA) và bắt đầu hoạt động truyền. Sau khi quá trình truyền hoàn tất, một
ngắt được điều khiển bởi logic DMA truyền. Người lái xe xử lý việc truyền
hoàn thành trong bối cảnh chuỗi xử lý ngắt bằng cách tái chế
tài nguyên cần thiết để gửi và theo dõi hoạt động truyền được yêu cầu.

4.2. Quá trình nhận
--------------------
Trình điều khiển sẽ đăng bộ đệm nhận vào logic DMA nhận trong quá trình điều khiển
khởi tạo. Bộ đệm nhận có thể được xếp hàng đợi hoặc không tùy thuộc vào
logic DMA cơ bản (MSGDMA có thể xếp hàng nhận bộ đệm, SGDMA không thể
để xếp hàng các bộ đệm nhận vào logic nhận SGDMA). Khi một gói được
nhận được, logic DMA sẽ tạo ra một ngắt. Người lái xe xử lý việc nhận
ngắt bằng cách lấy trạng thái logic nhận DMA, thu nhận
hoàn thành cho đến khi không còn nhận được hoàn thành nào nữa.

4.3. Giảm thiểu gián đoạn
-------------------------
Trình điều khiển có thể giảm thiểu số lần ngắt DMA của nó
sử dụng NAPI cho các hoạt động nhận. Giảm thiểu gián đoạn chưa được hỗ trợ
cho các hoạt động truyền tải, nhưng sẽ được bổ sung trong bản phát hành bảo trì trong tương lai.

4.4) Hỗ trợ Ethtool
--------------------
Ethtool được hỗ trợ. Thống kê trình điều khiển và lỗi nội bộ có thể được thực hiện bằng cách sử dụng:
Lệnh ethtool -S ethX. Có thể kết xuất các thanh ghi, v.v.

4.5) Hỗ trợ PHY
----------------
Trình điều khiển tương thích với PAL để hoạt động với các thiết bị PHY và GPHY.

4.7) Danh sách file nguồn:
--------------------------
- Kconfig
 - Tập tin tạo
 - altera_tse_main.c: driver thiết bị mạng chính
 - altera_tse_ethtool.c: hỗ trợ ethtool
 - altera_tse.h: cấu trúc trình điều khiển riêng và các định nghĩa chung
 - altera_msgdma.h: Định nghĩa hàm triển khai MSGDMA
 - altera_sgdma.h: Định nghĩa hàm triển khai SGDMA
 - altera_msgdma.c: triển khai MSGDMA
 - altera_sgdma.c: triển khai SGDMA
 - altera_sgdmahw.h: định nghĩa mô tả và đăng ký SGDMA
 - altera_msgdmahw.h: định nghĩa mô tả và đăng ký MSGDMA
 - altera_utils.c: Chức năng tiện ích của driver
 - altera_utils.h: Định nghĩa chức năng tiện ích của trình điều khiển

5. Thông tin gỡ lỗi
====================

Trình điều khiển xuất thông tin gỡ lỗi như số liệu thống kê nội bộ,
thông tin gỡ lỗi, các thanh ghi MAC và DMA, v.v.

Người dùng có thể sử dụng hỗ trợ ethtool để lấy số liệu thống kê:
ví dụ: sử dụng: ethtool -S ethX (hiển thị bộ đếm thống kê)
hoặc xem các thanh ghi MAC: ví dụ: sử dụng: ethtool -d ethX

Nhà phát triển cũng có thể sử dụng tham số mô-đun "gỡ lỗi" để nhận
thêm thông tin gỡ lỗi.

6. Hỗ trợ thống kê
=====================

Bộ điều khiển và trình điều khiển hỗ trợ kết hợp các số liệu thống kê được xác định theo tiêu chuẩn IEEE,
Thống kê được xác định bởi RFC và số liệu thống kê do trình điều khiển hoặc Altera xác định. Bốn
thông số kỹ thuật chứa các định nghĩa tiêu chuẩn cho các số liệu thống kê này là
như sau:

- IEEE 802.3-2012 - IEEE Tiêu chuẩn cho Ethernet.
 - RFC 2863 được tìm thấy tại ZZ0000ZZ
 - RFC 2819 được tìm thấy tại ZZ0001ZZ
 - Hướng dẫn sử dụng Ethernet ba tốc độ của Altera, có tại ZZ0002ZZ

Số liệu thống kê được TSE và trình điều khiển thiết bị hỗ trợ như sau:

"tx_packets" tương đương với aFramesTransmitOK được xác định trong IEEE 802.3-2012,
Mục 5.2.2.1.2. Thống kê này là số lượng khung hình được thành công
được truyền đi.

"rx_packets" tương đương với aFramesReceuredOK được xác định trong IEEE 802.3-2012,
Mục 5.2.2.1.5. Thống kê này là số lượng khung hình được thực hiện thành công
đã nhận được. Số lượng này không bao gồm bất kỳ gói lỗi nào như lỗi CRC,
lỗi về độ dài hoặc lỗi căn chỉnh.

"rx_crc_errors" tương đương với aFrameCheckSequenceErrors được xác định trong IEEE
802.3-2012, Mục 5.2.2.1.6. Thống kê này là số lượng khung hình được
một số nguyên byte có chiều dài và không vượt qua bài kiểm tra CRC dưới dạng khung
được nhận.

"rx_align_errors" tương đương với aAlignmentErrors được xác định trong IEEE 802.3-2012,
Mục 5.2.2.1.7. Thống kê này là số lượng khung hình không phải là
số nguyên byte có chiều dài và không vượt qua bài kiểm tra CRC vì khung
đã nhận được.

"tx_bytes" tương đương với aOctetsTransmitOK được xác định trong IEEE 802.3-2012,
Mục 5.2.2.1.8. Thống kê này là số lượng dữ liệu và byte đệm
được truyền thành công từ giao diện.

"rx_bytes" tương đương với aOctetsReceivedOK được xác định trong IEEE 802.3-2012,
Mục 5.2.2.1.14. Thống kê này là số lượng dữ liệu và byte đệm
được bộ điều khiển nhận thành công.

"tx_pause" tương đương với aPAUSEMACCtrlFramesTransmit được xác định trong IEEE
802.3-2012, Mục 30.3.4.2. Thống kê này là số lượng khung hình PAUSE
được truyền từ bộ điều khiển mạng.

"rx_pause" tương đương với aPAUSEMACCtrlFramesReceived được xác định trong IEEE
802.3-2012, Mục 30.3.4.3. Thống kê này là số lượng khung hình PAUSE
được bộ điều khiển mạng nhận được.

"rx_errors" tương đương với ifInErrors được xác định trong RFC 2863. Thống kê này là
đếm số gói nhận được có lỗi ngăn cản việc
gói tin được chuyển đến giao thức cấp cao hơn.

"tx_errors" tương đương với ifOutErrors được xác định trong RFC 2863. Thống kê này
là số lượng gói không thể truyền được do lỗi.

"rx_unicast" tương đương với ifInUcastPkts được xác định trong RFC 2863. Điều này
thống kê là số lượng gói nhận được không được xử lý
đến địa chỉ quảng bá hoặc một nhóm multicast.

"rx_multicast" tương đương với ifInMulticastPkts được xác định trong RFC 2863. Điều này
thống kê là số lượng gói nhận được được gửi đến
một nhóm địa chỉ multicast.

"rx_broadcast" tương đương với ifInBroadcastPkts được xác định trong RFC 2863. Điều này
thống kê là số lượng gói nhận được được gửi đến
địa chỉ quảng bá.

"tx_discards" tương đương với ifOutDiscards được xác định trong RFC 2863. Điều này
thống kê là số lượng gói tin gửi đi không được truyền đi mặc dù
lỗi không được phát hiện. Một ví dụ về lý do điều này có thể xảy ra là để giải phóng
không gian đệm bên trong.

"tx_unicast" tương đương với ifOutUcastPkts được xác định trong RFC 2863. Điều này
thống kê đếm số gói được truyền đi không có địa chỉ
một nhóm multicast hoặc địa chỉ quảng bá.

"tx_multicast" tương đương với ifOutMulticastPkts được xác định trong RFC 2863. Điều này
thống kê đếm số gói được truyền đi có địa chỉ đến một
nhóm phát đa hướng.

"tx_broadcast" tương đương với ifOutBroadcastPkts được xác định trong RFC 2863. Điều này
thống kê đếm số gói được truyền đi có địa chỉ đến một
địa chỉ quảng bá.

"ether_drops" tương đương với etherStatsDropEvents được xác định trong RFC 2819.
Thống kê này đếm số lượng gói tin bị rớt do thiếu nội bộ
tài nguyên điều khiển.

"rx_total_bytes" tương đương với etherStatsOctets được xác định trong RFC 2819.
Thống kê này đếm tổng số byte mà bộ điều khiển nhận được,
bao gồm cả các gói lỗi và các gói bị loại bỏ.

"rx_total_packets" tương đương với etherStatsPkts được xác định trong RFC 2819.
Thống kê này đếm tổng số gói mà bộ điều khiển nhận được,
bao gồm các gói lỗi, gói bị loại bỏ, gói unicast, gói multicast và gói quảng bá.

"rx_undersize" tương đương với etherStatsUndersizePkts được xác định trong RFC 2819.
Thống kê này đếm số lượng gói được hình thành chính xác nhận được ít hơn
dài hơn 64 byte.

"rx_oversize" tương đương với etherStatsOversizePkts được xác định trong RFC 2819.
Thống kê này đếm số lượng gói được hình thành chính xác lớn hơn 1518
dài byte.

"rx_64_bytes" tương đương với etherStatsPkts64Octets được xác định trong RFC 2819.
Thống kê này đếm tổng số gói nhận được là 64 octet
về chiều dài.

"rx_65_127_bytes" tương đương với etherStatsPkts65to127Octets được xác định trong RFC
2819. Thống kê này đếm tổng số gói nhận được
bao gồm chiều dài từ 65 đến 127 octet.

"rx_128_255_bytes" tương đương với etherStatsPkts128to255Octets được xác định trong
RFC 2819. Thống kê này là tổng số gói nhận được
bao gồm chiều dài từ 128 đến 255 octet.

"rx_256_511_bytes" tương đương với etherStatsPkts256to511Octets được xác định trong
RFC 2819. Thống kê này là tổng số gói nhận được
bao gồm chiều dài từ 256 đến 511 octet.

"rx_512_1023_bytes" tương đương với etherStatsPkts512to1023Octets được xác định trong
RFC 2819. Thống kê này là tổng số gói nhận được
bao gồm chiều dài từ 512 đến 1023 octet.

"rx_1024_1518_bytes" tương đương với etherStatsPkts1024to1518Octets xác định
trong RFC 2819. Thống kê này là tổng số gói nhận được
bao gồm chiều dài từ 1024 đến 1518 octet.

"rx_gte_1519_bytes" là một thống kê được xác định cụ thể cho hành vi của
Altera TSE. Thống kê này đếm số lượng hàng nhận được và bị lỗi
khung giữa độ dài 1519 và độ dài khung tối đa được định cấu hình
trong thanh ghi frm_length. Xem Hướng dẫn sử dụng Altera TSE để biết thêm chi tiết.

"rx_jabbers" tương đương với etherStatsJabbers được xác định trong RFC 2819. Điều này
thống kê là tổng số gói nhận được dài hơn 1518
octet và có CRC xấu với số octet nguyên (Lỗi CRC)
hoặc CRC xấu có số octet không nguyên (Lỗi căn chỉnh).

"rx_runts" tương đương với etherStatsFragments được xác định trong RFC 2819. Điều này
thống kê là tổng số gói nhận được nhỏ hơn 64 octet
dài và có một CRC xấu với số nguyên octet (CRC
lỗi) hoặc CRC xấu với số octet không nguyên (Lỗi căn chỉnh).