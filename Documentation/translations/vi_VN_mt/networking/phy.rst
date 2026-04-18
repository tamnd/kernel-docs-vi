.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/phy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Lớp trừu tượng PHY
=====================

Mục đích
=======

Hầu hết các thiết bị mạng bao gồm bộ thanh ghi cung cấp giao diện
tới lớp MAC, lớp này giao tiếp với kết nối vật lý thông qua một
PHY.  PHY liên quan đến việc đàm phán các tham số liên kết với liên kết
đối tác ở phía bên kia của kết nối mạng (thông thường là mạng ethernet
cáp) và cung cấp giao diện đăng ký để cho phép trình điều khiển xác định những gì
cài đặt đã được chọn và định cấu hình những cài đặt nào được phép.

Mặc dù các thiết bị này khác biệt với các thiết bị mạng và tuân theo một
cách bố trí tiêu chuẩn cho các thanh ghi, thông thường việc tích hợp
mã quản lý PHY với trình điều khiển mạng.  Điều này đã dẫn đến kết quả lớn
lượng mã dư thừa.  Ngoài ra, trên các hệ thống nhúng có nhiều (và
đôi khi khá khác nhau) bộ điều khiển ethernet được kết nối với cùng một
quản lý xe buýt, khó đảm bảo sử dụng xe buýt an toàn.

Vì PHY là thiết bị và các bus quản lý mà qua đó chúng được
trên thực tế, được truy cập là các bus, Lớp trừu tượng PHY (PAL) xử lý chúng như vậy.
Khi làm như vậy, nó có những mục tiêu sau:

#. Tăng khả năng tái sử dụng mã
#. Tăng khả năng bảo trì mã tổng thể
#. Thời gian phát triển tốc độ cho trình điều khiển mạng mới và cho hệ thống mới

Về cơ bản, lớp này nhằm cung cấp giao diện cho các thiết bị PHY
cho phép người viết trình điều khiển mạng viết ít mã nhất có thể, trong khi
vẫn cung cấp một bộ tính năng đầy đủ.

Xe buýt MDIO
============

Hầu hết các thiết bị mạng được kết nối với PHY bằng bus quản lý.
Các thiết bị khác nhau sử dụng các bus khác nhau (mặc dù một số có chung giao diện).
Để tận dụng PAL, mỗi giao diện bus cần phải được
được đăng ký như một thiết bị riêng biệt.

#. chức năng đọc và ghi phải được thực hiện. Nguyên mẫu của họ là::

int write(struct mii_bus *bus, int mii_id, int regnum, giá trị u16);
	int read(struct mii_bus *bus, int mii_id, int regnum);

mii_id là địa chỉ trên bus dành cho PHY và regnum là thanh ghi
   số.  Các chức năng này được đảm bảo không được gọi từ ngắt
   thời gian nên họ chặn là an toàn, chờ có tín hiệu ngắt
   hoạt động đã hoàn tất

#. Chức năng đặt lại là tùy chọn. Điều này được sử dụng để đưa xe buýt trở lại một
   trạng thái khởi tạo.

#. Một chức năng thăm dò là cần thiết.  Chức năng này sẽ thiết lập mọi thứ trên xe buýt
   nhu cầu của trình điều khiển, thiết lập cấu trúc mii_bus và đăng ký với PAL bằng cách sử dụng
   mdiobus_register.  Tương tự, có chức năng xóa để hoàn tác tất cả
   cái đó (sử dụng mdiobus_unregister).

#. Giống như bất kỳ trình điều khiển nào, cấu trúc device_driver phải được cấu hình và init
   chức năng thoát được sử dụng để đăng ký trình điều khiển.

#. Xe buýt cũng phải được khai báo ở đâu đó dưới dạng thiết bị và được đăng ký.

Để làm ví dụ về cách một trình điều khiển triển khai trình điều khiển bus mdio, hãy xem
driver/net/ethernet/freescale/fsl_pq_mdio.c và tệp DTS được liên kết
cho một trong những người dùng. (ví dụ: "git grep fsl,.*-mdio Arch/powerpc/boot/dts/")

(RG)MII/các cân nhắc về giao diện điện
===========================================

Giao diện độc lập trung bình Gigabit giảm (RGMII) là giao diện 12 chân
giao diện tín hiệu điện sử dụng tín hiệu đồng hồ 125 MHz đồng bộ và một số
các dòng dữ liệu. Do quyết định thiết kế này, phải thêm độ trễ 1,5ns đến 2ns
giữa dòng đồng hồ (RXC hoặc TXC) và các dòng dữ liệu để cho phép PHY (đồng hồ
sink) có thiết lập đủ lớn và thời gian lưu giữ để lấy mẫu chính xác các dòng dữ liệu. các
Thư viện PHY cung cấp các loại giá trị PHY_INTERFACE_MODE_RGMII* khác nhau để cho phép
trình điều khiển PHY và trình điều khiển MAC tùy chọn, thực hiện độ trễ cần thiết. các
các giá trị của phy_interface_t phải được hiểu từ góc độ của PHY
bản thân thiết bị, dẫn đến những điều sau:

* PHY_INTERFACE_MODE_RGMII: PHY không chịu trách nhiệm chèn bất kỳ
  độ trễ bên trong, nó giả định rằng Ethernet MAC (nếu có khả năng)
  hoặc dấu vết PCB chèn độ trễ 1,5-2ns chính xác

* PHY_INTERFACE_MODE_RGMII_TXID: PHY sẽ chèn độ trễ bên trong
  cho các đường truyền dữ liệu (TXD[3:0]) được xử lý bởi thiết bị PHY

* PHY_INTERFACE_MODE_RGMII_RXID: PHY sẽ chèn độ trễ bên trong
  đối với các đường dữ liệu nhận (RXD[3:0]) được xử lý bởi thiết bị PHY

* PHY_INTERFACE_MODE_RGMII_ID: PHY sẽ chèn độ trễ bên trong cho
  cả hai đều truyền AND nhận các đường dữ liệu từ/đến thiết bị PHY

Bất cứ khi nào có thể, hãy sử dụng độ trễ RGMII bên PHY vì những lý do sau:

* Các thiết bị PHY có thể cung cấp độ chi tiết dưới nano giây theo cách chúng cho phép
  Độ trễ phía máy thu/máy phát (ví dụ: 0,5, 1,0, 1,5ns) sẽ được chỉ định. Như vậy
  độ chính xác có thể được yêu cầu để giải thích sự khác biệt về độ dài vết PCB

* Các thiết bị PHY thường đủ tiêu chuẩn cho nhiều ứng dụng
  (công nghiệp, y tế, ô tô...), và chúng cung cấp liên tục và
  độ trễ đáng tin cậy trên các phạm vi nhiệt độ/áp suất/điện áp

* Trình điều khiển thiết bị PHY trong PHYLIB về bản chất có thể tái sử dụng được, có thể
  định cấu hình chính xác độ trễ được chỉ định cho phép nhiều thiết kế hơn có độ trễ tương tự
  Yêu cầu vận hành chính xác

Đối với các trường hợp PHY không có khả năng cung cấp độ trễ này, nhưng
Trình điều khiển Ethernet MAC có khả năng làm như vậy, giá trị phy_interface_t chính xác
phải là PHY_INTERFACE_MODE_RGMII và trình điều khiển Ethernet MAC phải là
được cấu hình đúng để cung cấp khả năng truyền và/hoặc nhận được yêu cầu
độ trễ bên từ góc nhìn của thiết bị PHY. Ngược lại, nếu Ethernet
Trình điều khiển MAC xem xét giá trị phy_interface_t đối với bất kỳ chế độ nào khác ngoại trừ
PHY_INTERFACE_MODE_RGMII, cần đảm bảo rằng độ trễ ở mức MAC được
bị vô hiệu hóa.

Trong trường hợp cả Ethernet MAC và PHY đều không có khả năng cung cấp
độ trễ cần thiết, như được xác định theo tiêu chuẩn RGMII, một số tùy chọn có thể
có sẵn:

* Một số SoC có thể cung cấp bảng ghim/mux/bộ điều khiển có khả năng định cấu hình một
  tập hợp cường độ, độ trễ và điện áp của chân; và nó có thể phù hợp
  tùy chọn để chèn độ trễ RGMII dự kiến là 2ns.

* Sửa đổi thiết kế PCB để bao gồm độ trễ cố định (ví dụ: sử dụng
  được thiết kế ngoằn ngoèo), có thể không yêu cầu cấu hình phần mềm nào cả.

Các vấn đề thường gặp với độ trễ không khớp của RGMII
-----------------------------------------

Khi có độ trễ RGMII không khớp giữa Ethernet MAC và PHY, điều này
rất có thể sẽ dẫn đến tín hiệu đồng hồ và đường dữ liệu không ổn định khi
PHY hoặc MAC chụp nhanh các tín hiệu này để chuyển chúng thành logic
1 hoặc 0 và xây dựng lại dữ liệu đang được truyền/nhận. Điển hình
symptoms include:

* Việc truyền/nhận hoạt động một phần và xảy ra thường xuyên hoặc thỉnh thoảng
  quan sát thấy mất gói

* Ethernet MAC có thể báo cáo một số hoặc tất cả các gói đi vào có lỗi FCS/CRC,
  hoặc chỉ cần loại bỏ tất cả

* Chuyển sang tốc độ thấp hơn như 10/100Mbits/giây sẽ giải quyết được vấn đề
  (vì có đủ thời gian thiết lập/giữ trong trường hợp đó)

Kết nối với PHY
===================

Đôi khi trong quá trình khởi động, trình điều khiển mạng cần thiết lập kết nối
giữa thiết bị PHY và thiết bị mạng.  Lúc này, xe buýt của PHY
và tất cả các trình điều khiển cần phải được tải để sẵn sàng kết nối.
Tại thời điểm này, có một số cách để kết nối với PHY:

#. PAL xử lý mọi thứ và chỉ gọi trình điều khiển mạng khi
   the link state changes, so it can react.

#. PAL xử lý mọi thứ ngoại trừ các ngắt (thường là do
   bộ điều khiển có các thanh ghi ngắt).

#. PAL xử lý mọi thứ nhưng vẫn kiểm tra trình điều khiển mỗi giây,
   cho phép trình điều khiển mạng phản ứng trước với bất kỳ thay đổi nào trước PAL
   có.

#. PAL chỉ phục vụ như một thư viện chức năng với thiết bị mạng
   gọi các chức năng theo cách thủ công để cập nhật trạng thái và định cấu hình PHY


Để Lớp trừu tượng PHY làm mọi thứ
===============================================

Nếu bạn chọn phương án 1 (Hy vọng là tài xế nào cũng được, nhưng vẫn được
hữu ích cho những trình điều khiển không thể), việc kết nối với PHY rất đơn giản:

Đầu tiên, bạn cần một hàm để phản ứng với những thay đổi trong trạng thái liên kết.  Cái này
chức năng tuân theo giao thức này ::

static void adjustment_link(struct net_device *dev);

Tiếp theo, bạn cần biết tên thiết bị PHY được kết nối với thiết bị này.
Tên sẽ trông giống như "0:00", trong đó số đầu tiên là
id xe buýt và thứ hai là địa chỉ của PHY trên xe buýt đó.  Thông thường,
xe buýt có trách nhiệm làm cho ID của nó là duy nhất.

Bây giờ, để kết nối, chỉ cần gọi hàm này::

phydev = phy_connect(dev, phy_name, & adjustment_link, giao diện);

ZZ0000ZZ là một con trỏ tới cấu trúc phy_device đại diện cho PHY.
Nếu phy_connect thành công, nó sẽ trả về con trỏ.  dev, đây là
con trỏ tới net_device của bạn.  Sau khi thực hiện xong, chức năng này sẽ bắt đầu
Máy trạng thái phần mềm của PHY và đã đăng ký ngắt của PHY, nếu nó
có một cái.  Cấu trúc phydev sẽ chứa thông tin về
trạng thái hiện tại, mặc dù PHY vẫn chưa thực sự hoạt động vào lúc này
điểm.

Các cờ dành riêng cho PHY phải được đặt trong phydev->dev_flags trước cuộc gọi
tới phy_connect() sao cho trình điều khiển PHY cơ bản có thể kiểm tra cờ
và thực hiện các hoạt động cụ thể dựa trên chúng.
Điều này rất hữu ích nếu hệ thống đã đặt các hạn chế về phần cứng
PHY/bộ điều khiển, trong đó PHY cần phải biết.

ZZ0000ZZ là u32 chỉ định loại kết nối được sử dụng
giữa bộ điều khiển và PHY.  Ví dụ như GMII, MII,
RGMII và SGMII.  Xem "Chế độ giao diện PHY" bên dưới.  Để có đầy đủ
danh sách, xem include/linux/phy.h

Bây giờ chỉ cần đảm bảo rằng phydev->được hỗ trợ và phydev->quảng cáo có bất kỳ
các giá trị được cắt bớt khỏi chúng sẽ không có ý nghĩa đối với bộ điều khiển của bạn (10/100
bộ điều khiển có thể được kết nối với PHY có khả năng gigabit, vì vậy bạn cần phải
tắt mặt nạ SUPPORTED_1000baseT*).  Xem include/linux/ethtool.h để biết định nghĩa
cho các bitfield này. Lưu ý rằng bạn không nên sử dụng SET bất kỳ bit nào, ngoại trừ
Các bit SUPPORTED_Pause và SUPPORTED_AsymPause (xem bên dưới) hoặc PHY có thể nhận được
đưa vào trạng thái không được hỗ trợ.

Cuối cùng, khi bộ điều khiển đã sẵn sàng xử lý lưu lượng mạng, bạn gọi
phy_start(phydev).  Điều này cho PAL biết rằng bạn đã sẵn sàng và định cấu hình
PHY để kết nối với mạng. Nếu MAC làm gián đoạn trình điều khiển mạng của bạn
cũng xử lý các thay đổi trạng thái PHY, chỉ cần đặt phydev->irq thành PHY_MAC_INTERRUPT
trước khi bạn gọi phy_start và sử dụng phy_mac_interrupt() từ mạng
người lái xe. Nếu bạn không muốn sử dụng ngắt, hãy đặt phydev->irq thành PHY_POLL.
phy_start() cho phép ngắt PHY (nếu có) và bắt đầu
máy trạng thái phylib.

Khi bạn muốn ngắt kết nối khỏi mạng (dù chỉ trong thời gian ngắn), bạn gọi
phy_stop(phydev). Chức năng này cũng dừng máy trạng thái phylib và
vô hiệu hóa các ngắt PHY.

Chế độ giao diện PHY
===================

Chế độ giao diện PHY được cung cấp trong nhóm chức năng phy_connect()
xác định chế độ hoạt động ban đầu của giao diện PHY.  Đây không phải là
được đảm bảo không đổi; có những PHY thay đổi linh hoạt
chế độ giao diện của chúng mà không cần tương tác phần mềm tùy thuộc vào
kết quả đàm phán.

Một số chế độ giao diện được mô tả dưới đây:

ZZ0000ZZ
    Đây là MII nối tiếp, tốc độ 125 MHz, hỗ trợ tốc độ 100M và 10M.
    Một số chi tiết có thể được tìm thấy trong
    ZZ0001ZZ

ZZ0000ZZ
    Điều này xác định liên kết serdes một làn 1000BASE-X như được xác định bởi
    Tiêu chuẩn 802.3 phần 36. Liên kết hoạt động ở tốc độ bit cố định là
    1,25Gbaud sử dụng sơ đồ mã hóa 10B/8B, dẫn đến kết quả cơ bản
    tốc độ dữ liệu 1Gbps.  Được nhúng trong luồng dữ liệu là bộ điều khiển 16 bit
    từ được sử dụng để đàm phán chế độ song công và tạm dừng với
    đầu xa.  Điều này không bao gồm các biến thể "tăng tốc" chẳng hạn như 2,5Gbps
    tốc độ (xem bên dưới.)

ZZ0000ZZ
    Điều này xác định một biến thể của 1000BASE-X có tốc độ nhanh gấp 2,5 lần
    như chuẩn 802.3, cho tốc độ bit cố định là 3.125Gbaud.

ZZ0000ZZ
    Cái này được sử dụng cho Cisco SGMII, đây là bản sửa đổi của 1000BASE-X
    như được định nghĩa bởi tiêu chuẩn 802.3.  Liên kết SGMII bao gồm một
    làn serdes chạy ở tốc độ bit cố định 1,25Gbaud với 10B/8B
    mã hóa.  Tốc độ dữ liệu cơ bản là 1Gbps, với tốc độ chậm hơn là
    Tốc độ 100Mbps và 10Mbps đạt được thông qua việc sao chép từng ký hiệu dữ liệu.
    Từ điều khiển 802.3 được tái mục đích để gửi tốc độ đã thương lượng và
    thông tin song công từ MAC và để MAC xác nhận
    biên nhận.  Điều này không bao gồm các biến thể "tăng tốc" chẳng hạn như 2,5Gbps
    tốc độ.

Lưu ý: cấu hình SGMII so với 1000BASE-X trên một liên kết có thể không khớp
    truyền dữ liệu thành công trong một số trường hợp, nhưng điều khiển 16-bit
    từ sẽ không được diễn giải chính xác, điều này có thể gây ra sự không khớp trong
    song công, tạm dừng hoặc các cài đặt khác.  Điều này phụ thuộc vào MAC và/hoặc
    Hành vi của PHY.

ZZ0000ZZ
    Đây là giao thức 5GBASE-R được xác định theo IEEE 802.3 Điều 129. Đó là
    giống với giao thức 10GBASE-R được xác định trong Điều 49, với
    ngoại lệ là nó hoạt động ở một nửa tần số. Vui lòng tham khảo
    Tiêu chuẩn IEEE cho định nghĩa.

ZZ0000ZZ
    Đây là giao thức IEEE 802.3 Điều 49 được xác định 10GBASE-R được sử dụng với
    nhiều phương tiện khác nhau. Vui lòng tham khảo tiêu chuẩn IEEE để biết
    định nghĩa về điều này.

Lưu ý: 10GBASE-R chỉ là một giao thức có thể được sử dụng với XFI và SFI.
    XFI và SFI cho phép nhiều giao thức trên một làn SERDES duy nhất và
    cũng xác định các đặc tính điện của tín hiệu với máy chủ
    bo mạch tuân thủ được cắm vào đầu nối XFP/SFP của máy chủ. Vì vậy,
    XFI và SFI không phải là loại giao diện PHY.

ZZ0000ZZ
    Đây là IEEE 802.3 Điều 49 được xác định 10GBASE-R với Điều 73
    tự thương lượng. Vui lòng tham khảo tiêu chuẩn IEEE để biết thêm
    thông tin.

Lưu ý: do cách sử dụng cũ, một số cách sử dụng 10GBASE-R không chính xác sẽ khiến
    việc sử dụng định nghĩa này.

ZZ0000ZZ
    Đây là IEEE 802.3 PCS Điều 107 được xác định giao thức 25GBASE-R.
    PCS giống hệt 10GBASE-R, tức là được mã hóa 64B/66B
    chạy nhanh như 2,5, cho tốc độ bit cố định là 25,78125 Gbaud.
    Vui lòng tham khảo tiêu chuẩn IEEE để biết thêm thông tin.

ZZ0000ZZ
    Điều này xác định IEEE 802.3 Điều 24. Liên kết hoạt động ở tốc độ dữ liệu cố định
    tốc độ 125Mpbs bằng cách sử dụng sơ đồ mã hóa 4B/5B, dẫn đến
    tốc độ dữ liệu 100Mpbs.

ZZ0000ZZ
    Điều này xác định chế độ Quad USGMII của Cisco, là biến thể Quad của
    liên kết USGMII (Universal SGMII). Nó rất giống với QSGMII, nhưng sử dụng
    Tiêu đề Kiểm soát Gói (PCH) thay vì phần mở đầu 7 byte để không mang theo
    chỉ id cổng mà còn được gọi là "phần mở rộng". Tài liệu duy nhất
    Phần mở rộng cho đến nay trong đặc tả là bao gồm các dấu thời gian, cho
    PHY hỗ trợ PTP. Chế độ này không tương thích với QSGMII nhưng cung cấp
    khả năng tương tự về tốc độ liên kết và đàm phán.

ZZ0000ZZ
    Đây là 1000BASE-X như được xác định bởi IEEE 802.3 Điều 36 với Điều 73
    tự thương lượng. Nói chung, nó sẽ được sử dụng với Điều 70 PMD. Đến
    tương phản với chế độ phy 1000BASE-X được sử dụng cho Điều 38 và 39 PMD, chế độ này
    chế độ giao diện có khả năng tự động đàm phán khác nhau và chỉ hỗ trợ song công hoàn toàn.

ZZ0000ZZ
    Đây là chế độ Penta SGMII, nó tương tự như QSGMII nhưng nó kết hợp 5
    SGMII xếp thành một liên kết duy nhất so với 4 trên QSGMII.

ZZ0000ZZ
    Đại diện cho giao diện 10G-QXGMII PHY-MAC như được xác định bởi Cisco USXGMII
    Tài liệu giao diện đồng đa cổng. Nó hỗ trợ 4 cổng trên băng tần 10,3125 GHz
    Làn SerDes, mỗi cổng đạt tốc độ 2.5G/1G/100M/10M
    thông qua việc sao chép biểu tượng. PCS mong đợi từ mã USXGMII tiêu chuẩn.

ZZ0000ZZ
    Chế độ MII không chuẩn, đơn giản hóa, không có tín hiệu TXER, RXER, CRS và COL
    như được định nghĩa cho MII. Việc thiếu tín hiệu COL tạo nên liên kết bán song công
    không thể thực hiện được các chế độ này nhưng không can thiệp vào các chế độ liên kết BroadR-Reach trên
    Các PHY Broadcom (và Ethernet hai dây khác), vì chúng ở chế độ song công hoàn toàn
    chỉ.

Tạm dừng khung/điều khiển luồng
===========================

PHY không tham gia trực tiếp vào các khung điều khiển/tạm dừng luồng ngoại trừ
đảm bảo rằng các bit SUPPORTED_Pause và SUPPORTED_AsymPause được đặt trong
MII_ADVERTISE để thông báo cho đối tác liên kết rằng Ethernet MAC
bộ điều khiển hỗ trợ một điều như vậy. Kể từ khi tạo khung điều khiển/tạm dừng
liên quan đến trình điều khiển Ethernet MAC, nên trình điều khiển này nên cẩn thận
chỉ ra quảng cáo và hỗ trợ chính xác cho các tính năng đó bằng cách cài đặt
các bit SUPPORTED_Pause và SUPPORTED_AsymPause tương ứng. Điều này có thể được thực hiện
trước hoặc sau phy_connect() và/hoặc do việc triển khai
tính năng ethtool::set_pauseparam.


Theo dõi chặt chẽ trên PAL
=============================

Có thể máy trạng thái tích hợp của PAL cần một chút trợ giúp để
giữ cho thiết bị mạng của bạn và PHY được đồng bộ hóa đúng cách.  Nếu vậy, bạn có thể
đăng ký chức năng trợ giúp khi kết nối với PHY, chức năng này sẽ được gọi
mỗi giây trước khi máy trạng thái phản ứng với bất kỳ thay đổi nào.  Để làm điều này, bạn
cần gọi thủ công phy_attach() và phy_prepare_link(), sau đó gọi
phy_start_machine() với đối số thứ hai được đặt để trỏ đến địa chỉ đặc biệt của bạn
người xử lý.

Hiện tại không có ví dụ nào về cách sử dụng chức năng này và việc thử nghiệm
trên đó đã bị hạn chế vì tác giả không có bất kỳ trình điều khiển nào sử dụng
nó (tất cả họ đều sử dụng tùy chọn 1).  Vì vậy hãy cẩn thận Emptor.

Tự mình làm tất cả
=====================

Có khả năng rất cao là máy trạng thái tích hợp của PAL không thể theo dõi
các tương tác phức tạp giữa PHY và thiết bị mạng của bạn.  Nếu đây là
vì vậy, bạn có thể chỉ cần gọi phy_attach() chứ không gọi phy_start_machine hoặc
phy_prepare_link().  Điều này có nghĩa là phydev->state hoàn toàn thuộc về bạn
xử lý (phy_start và phy_stop chuyển đổi giữa một số trạng thái, do đó bạn
có thể cần phải tránh chúng).

Một nỗ lực đã được thực hiện để đảm bảo rằng chức năng hữu ích có thể được
được truy cập mà không cần máy trạng thái chạy và hầu hết các chức năng này đều được
bắt nguồn từ các hàm không tương tác với một máy trạng thái phức tạp.
Tuy nhiên, một lần nữa, cho đến nay vẫn chưa có nỗ lực nào để thử nghiệm việc chạy mà không có
máy trạng thái, vì vậy người thử hãy cẩn thận.

Dưới đây là tóm tắt ngắn gọn về các chức năng::

int phy_read(struct phy_device *phydev, u16 regnum);
 int phy_write(struct phy_device *phydev, u16 regnum, u16 val);

Đọc/ghi đơn giản.  Họ gọi chức năng đọc/ghi của xe buýt
con trỏ.
::

void phy_print_status(struct phy_device *phydev);

Một chức năng tiện lợi để in trạng thái PHY một cách gọn gàng.
::

void phy_request_interrupt(struct phy_device *phydev);

Yêu cầu IRQ cho các ngắt PHY.
::

cấu trúc phy_device * phy_attach(struct net_device *dev, const char *phy_id,
		                giao diện phy_interface_t);

Gắn thiết bị mạng vào một PHY cụ thể, liên kết PHY với một thiết bị chung
driver nếu không tìm thấy trong quá trình khởi tạo xe buýt.
::

int phy_start_aneg(struct phy_device *phydev);

Sử dụng các biến bên trong cấu trúc phydev để định cấu hình quảng cáo
và đặt lại tính năng tự động thương lượng hoặc vô hiệu hóa tính năng tự động thương lượng và định cấu hình
cài đặt bắt buộc.
::

int int tĩnh phy_read_status(struct phy_device *phydev);

Điền vào cấu trúc phydev với thông tin cập nhật về hiện tại
cài đặt trong PHY.
::

int phy_ethtool_ksettings_set(struct phy_device *phydev,
                               const struct ethtool_link_ksettings *cmd);

Chức năng tiện lợi của Ethtool.
::

int phy_mii_ioctl(struct phy_device *phydev,
                   struct mii_ioctl_data *mii_data, int cmd);

MII ioctl.  Lưu ý rằng chức năng này sẽ làm hỏng hoàn toàn trạng thái
máy nếu bạn ghi các thanh ghi như BMCR, BMSR, ADVERTISE, v.v. Tốt nhất nên
chỉ sử dụng cái này để ghi các thanh ghi không chuẩn và không đặt ra
một cuộc đàm phán lại.

Trình điều khiển thiết bị PHY
==================

Với Lớp trừu tượng PHY, việc bổ sung hỗ trợ cho PHY mới là
khá dễ dàng. Trong một số trường hợp, không cần phải làm gì cả! Tuy nhiên,
nhiều PHY yêu cầu phải cầm tay một chút để thiết lập và chạy.

Trình điều khiển PHY chung
------------------

Nếu PHY mong muốn không có bất kỳ lỗi, lỗi hoặc đặc biệt nào
các tính năng bạn muốn hỗ trợ thì tốt nhất bạn không nên thêm
hỗ trợ và để Trình điều khiển PHY chung của Lớp trừu tượng PHY
làm tất cả công việc.

Viết trình điều khiển PHY
--------------------

Nếu bạn cần viết trình điều khiển PHY, điều đầu tiên cần làm là
đảm bảo nó có thể được kết hợp với thiết bị PHY thích hợp.
Việc này được thực hiện trong quá trình khởi tạo bus bằng cách đọc thông tin của thiết bị.
UID (được lưu trong thanh ghi 2 và 3), sau đó so sánh nó với từng thanh ghi
trường phy_id của trình điều khiển bằng cách ANDing nó với mỗi trình điều khiển
trường phy_id_mask.  Ngoài ra, nó cần một cái tên.  Đây là một ví dụ::

cấu trúc tĩnh phy_driver dm9161_driver = {
         .phy_id = 0x0181b880,
	 .name = "Davicom DM9161E",
	 .phy_id_mask = 0x0ffffff0,
	 ...
   }

Tiếp theo, bạn cần chỉ định những tính năng nào (tốc độ, song công, tự động,
v.v.) hỗ trợ trình điều khiển và thiết bị PHY của bạn.  Hầu hết các PHY đều hỗ trợ
PHY_BASIC_FEATURES, nhưng bạn có thể tìm trong include/mii.h để biết thông tin khác
tính năng.

Mỗi trình điều khiển bao gồm một số con trỏ hàm, được ghi lại
trong include/linux/phy.h dưới cấu trúc phy_driver.

Trong số này, chỉ cần config_aneg và read_status
được chỉ định bởi mã trình điều khiển.  Phần còn lại là tùy chọn.  Ngoài ra, nó là
ưu tiên sử dụng phiên bản trình điều khiển phy chung của hai phiên bản này
hoạt động nếu có thể: genphy_read_status và
genphy_config_aneg.  Nếu điều này là không thể thì rất có thể
bạn chỉ cần thực hiện một số hành động trước và sau khi gọi
các hàm này và do đó các hàm của bạn sẽ bao bọc chung
những cái đó.

Vui lòng xem các trình điều khiển Marvell, Cicada và Davicom trong
driver/net/phy/ làm ví dụ (trình điều khiển lxt và qsemi có
chưa được kiểm tra tính đến thời điểm viết bài này).

Quyền truy cập đăng ký MMD của PHY được xử lý bởi khung PAL
theo mặc định, nhưng có thể bị ghi đè bởi trình điều khiển PHY cụ thể nếu
được yêu cầu. Điều này có thể xảy ra nếu PHY được phát hành trong
sản xuất trước khi định nghĩa đăng ký MMD PHY được
được tiêu chuẩn hóa bởi IEEE. Hầu hết các PHY hiện đại đều có thể sử dụng
khung PAL chung để truy cập vào các thanh ghi MMD của PHY.
Một ví dụ về việc sử dụng như vậy là để hỗ trợ Ethernet hiệu quả năng lượng,
được triển khai trong PAL. Hỗ trợ này sử dụng PAL để truy cập MMD
đăng ký truy vấn và cấu hình EEE nếu PHY hỗ trợ
cơ chế truy cập tiêu chuẩn IEEE hoặc có thể sử dụng cơ chế truy cập cụ thể của PHY
truy cập các giao diện nếu bị ghi đè bởi trình điều khiển PHY cụ thể. Xem
trình điều khiển Micrel trong driver/net/phy/ để biết ví dụ về cách thực hiện điều này
có thể được thực hiện.

Sửa chữa bảng
============

Đôi khi sự tương tác cụ thể giữa nền tảng và PHY yêu cầu
xử lý đặc biệt.  Ví dụ: để thay đổi vị trí đầu vào đồng hồ của PHY,
hoặc để thêm độ trễ nhằm giải quyết các vấn đề về độ trễ trong đường dẫn dữ liệu.  theo thứ tự
để hỗ trợ các trường hợp dự phòng như vậy, Lớp PHY cho phép mã nền tảng đăng ký
các bản sửa lỗi sẽ được chạy khi PHY được khởi chạy (hoặc sau đó được đặt lại).

Khi Lớp PHY hiển thị PHY, nó sẽ kiểm tra xem có bản sửa lỗi nào không
đã đăng ký, khớp dựa trên UID (có trong phy_id của thiết bị PHY
trường) và mã định danh bus (có trong phydev->dev.bus_id).  Cả hai đều phải
khớp, tuy nhiên hai hằng số PHY_ANY_ID và PHY_ANY_UID được cung cấp dưới dạng
ký tự đại diện cho ID bus và UID tương ứng.

Khi tìm thấy kết quả khớp, lớp PHY sẽ gọi hàm chạy được liên kết
với bản sửa lỗi.  Hàm này được truyền một con trỏ tới phy_device của
tiền lãi.  Do đó, nó chỉ nên hoạt động trên PHY đó.

Mã nền tảng có thể đăng ký bản sửa lỗi bằng một trong::

int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
		int (ZZ0000ZZ));
 int phy_register_fixup_for_id(const char *phy_id,
		int (ZZ0001ZZ));

Tiêu chuẩn
=========

IEEE Tiêu chuẩn 802.3: Phương pháp truy cập CSMA/CD và thông số kỹ thuật của lớp vật lý, Phần hai:
ZZ0000ZZ

RGMII v1.3:
ZZ0000ZZ

RGMII v2.0:
ZZ0000ZZ
