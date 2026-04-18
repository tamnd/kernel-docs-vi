.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/3com/vortex.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Trình điều khiển thiết bị 3Com Vortex
=====================================

Andrew Morton

30 tháng 4 năm 2000


Tài liệu này mô tả cách sử dụng và lỗi của thiết bị 3Com "Vortex"
trình điều khiển cho Linux, 3c59x.c.

Trình điều khiển được viết bởi Donald Becker <becker@scyld.com>

Don không còn là người duy trì chính phiên bản trình điều khiển này nữa.
Vui lòng báo cáo vấn đề cho một hoặc nhiều trong số:

- Andrew Morton
- Danh sách gửi thư Netdev <netdev@vger.kernel.org>
- Danh sách gửi thư nhân Linux <linux-kernel@vger.kernel.org>

Vui lòng lưu ý phần 'Báo cáo và chẩn đoán sự cố' ở cuối
của tập tin này.


Kể từ kernel 2.3.99-pre6, trình điều khiển này kết hợp hỗ trợ cho
Thẻ Cardbus dòng 3c575 từng được xử lý bởi 3c575_cb.c.

Trình điều khiển này hỗ trợ phần cứng sau:

- 3c590 Vortex 10Mbps
	- 3c592 EISA 10Mbps Quỷ/Vortex
	- 3c597 EISA Quỷ/Vortex nhanh
	- 3c595 Vortex 100baseTx
	- 3c595 Vortex 100baseT4
	- 3c595 Vortex 100base-MII
	- 3c900 Boomerang 10baseT
	- Combo 3c900 Boomerang 10Mbps
	- 3c900 Lốc xoáy 10Mbps TPO
	- Combo 3c900 Cyclone 10Mbps
	- 3c900 Lốc xoáy 10Mbps TPC
	- 3c900B-FL Lốc xoáy 10base-FL
	- 3c905 Boomerang 100baseTx
	- 3c905 Boomerang 100baseT4
	- 3c905B Lốc xoáy 100baseTx
	- 3c905B Lốc xoáy 10/100/BNC
	- 3c905B-FX Lốc xoáy 100baseFx
	- Lốc xoáy 3c905C
	- 3c920B-EMB-WNM (ATI Radeon 9100 IGP)
	- Lốc xoáy 3c980
	- 3c980C Python-T
	- Bão 3cSOHO100-TX
	- Bão Laptop 3c555
	- Lốc Xoáy Laptop 3c556
	- Bão Laptop 3c556B
	- 3c575 [Megahertz] 10/100 LAN CardBus
	- Xe buýt thẻ Boomerang 3c575
	- Bus thẻ lốc xoáy 3CCFE575BT
	- Xe buýt thẻ lốc xoáy 3CCFE575CT
	- Bus thẻ lốc xoáy 3CCFE656
	- 3CCFEM656B Cyclone+Winmodem CardBus
	- 3CXFEM656C Tornado+Winmodem CardBus
	- Lốc xoáy 3c450 HomePNA
	- Lốc xoáy 3c920
	- 3c982 Hydra Cổng Kép A
	- 3c982 Hydra Cổng kép B
	- 3c905B-T4
	- Lốc xoáy 3c920B-EMB-WNM

Thông số mô-đun
=================

Có một số thông số có thể được cung cấp cho người lái xe khi
mô-đun của nó đã được tải.  Chúng thường được đặt trong ZZ0000ZZ
các tập tin cấu hình.  Ví dụ::

tùy chọn 3c59x debug=3 rx_copybreak=300

Nếu bạn đang sử dụng công cụ PCMCIA (cardmgr) thì các tùy chọn có thể là
được đặt trong /etc/pcmcia/config.opts::

mô-đun "3c59x" chọn "debug=3 rx_copybreak=300"


Các tham số được hỗ trợ là:

gỡ lỗi=N

Trong đó N là một số từ 0 đến 7. Bất cứ số nào trên 3 đều tạo ra rất nhiều
  đầu ra trong nhật ký hệ thống của bạn.  debug=1 là mặc định.

tùy chọn=N1,N2,N3,...

Mỗi số trong danh sách cung cấp một tùy chọn cho số tương ứng
  card mạng.  Vì vậy, nếu bạn có hai 3c905 và bạn muốn cung cấp
  chúng với tùy chọn 0x204 bạn sẽ sử dụng ::

tùy chọn=0x204,0x204

Các tùy chọn riêng lẻ bao gồm một số trường bit
  có những ý nghĩa sau:

Cài đặt loại phương tiện có thể

=====================================
	0 10baseT
	1 10Mbs AUI
	2 không xác định
	3 10base2 (BNC)
	4 100base-TX
	5 100base-FX
	6 MII (Giao diện độc lập với phương tiện truyền thông)
	7 Sử dụng cài đặt mặc định từ EEPROM
	8 Tự động thương lượng
	9 MII bên ngoài
	10 Sử dụng cài đặt mặc định từ EEPROM
	=====================================

Khi tạo giá trị cho cài đặt 'tùy chọn', phương tiện trên
  các giá trị lựa chọn có thể được OR'ed (hoặc thêm vào) như sau:

====== =================================================
  0x8000 Đặt mức gỡ lỗi trình điều khiển thành 7
  0x4000 Đặt mức gỡ lỗi trình điều khiển thành 2
  0x0400 Kích hoạt Wake-on-LAN
  0x0200 Buộc chế độ song công hoàn toàn.
  0x0010 Bit kích hoạt Bus-master (chỉ thẻ Vortex cũ)
  ====== =================================================

Ví dụ::

tùy chọn insmod 3c59x=0x204

sẽ buộc 100base-TX song công hoàn toàn, thay vì cho phép thông thường
  tự thương lượng.

toàn cầu_options=N

Đặt tham số ZZ0000ZZ cho tất cả NIC 3c59x trong máy.
  Các mục trong mảng ZZ0001ZZ ở trên sẽ ghi đè mọi cài đặt của
  cái này.

full_duplex=N1,N2,N3...

Tương tự như bit 9 của 'tùy chọn'.  Buộc thẻ tương ứng vào
  chế độ song công hoàn toàn.  Vui lòng sử dụng tùy chọn này thay vì ZZ0000ZZ
  tham số.

Trên thực tế, xin vui lòng không sử dụng điều này! Tốt hơn hết là bạn nên nhận
  tự động đàm phán hoạt động tốt.

toàn cầu_full_duplex=N1

Đặt chế độ song công hoàn toàn cho tất cả các NIC 3c59x trong máy.  Bài dự thi
  trong mảng ZZ0000ZZ ở trên sẽ ghi đè mọi cài đặt này.

flow_ctrl=N1,N2,N3...

Sử dụng điều khiển luồng lớp 802.3x MAC.  Thẻ 3com chỉ hỗ trợ
  Lệnh PAUSE, có nghĩa là họ sẽ ngừng gửi gói tin trong một thời gian
  trong thời gian ngắn nếu họ nhận được khung PAUSE từ đối tác liên kết.

Trình điều khiển chỉ cho phép điều khiển luồng trên liên kết đang hoạt động trong
  chế độ song công hoàn toàn.

Tính năng này dường như không hoạt động trên 3c905 - chỉ 3c905B và
  3c905C đã được thử nghiệm.

Thẻ 3com dường như chỉ phản hồi với các khung PAUSE
  được gửi đến địa chỉ đích dành riêng là 01:80:c2:00:00:01.  Họ
  không tôn trọng các khung PAUSE được gửi đến địa chỉ trạm MAC.

rx_copybreak=M

Trình điều khiển phân bổ trước 32 bộ đệm mạng có kích thước đầy đủ (1536 byte)
  để nhận.  Khi một gói tin đến, trình điều khiển phải quyết định
  nên để gói tin trong bộ đệm có kích thước đầy đủ hay phân bổ
  một bộ đệm nhỏ hơn và sao chép gói tin vào đó.

Đây là sự cân bằng giữa tốc độ/không gian.

Giá trị của rx_copybreak được sử dụng để quyết định thời điểm tạo bản sao.
  Nếu kích thước gói nhỏ hơn rx_copybreak thì gói sẽ được sao chép.
  Giá trị mặc định cho rx_copybreak là 200 byte.

max_interrupt_work=N

Thói quen phục vụ ngắt của trình điều khiển có thể xử lý nhiều việc nhận và
  truyền các gói trong một lệnh gọi duy nhất.  Nó thực hiện điều này trong một vòng lặp.
  Giá trị của max_interrupt_work quy định số lần ngắt
  thói quen dịch vụ sẽ lặp lại.  Giá trị mặc định là 32 vòng.  Nếu điều này
  vượt quá quy trình phục vụ ngắt sẽ từ bỏ và tạo ra một
  thông báo cảnh báo "eth0: Quá nhiều công việc bị gián đoạn".

hw_checksums=N1,N2,N3,...

Các NIC 3com gần đây có thể tạo tổng kiểm tra IPv4, TCP và UDP
  trong phần cứng.  Linux đã sử dụng tính năng kiểm tra tổng Rx trong một thời gian dài.
  Bản vá "không sao chép" được lên kế hoạch cho loạt hạt nhân 2.4
  cho phép bạn sử dụng phân tán/thu thập và truyền DMA của NIC
  kiểm tra là tốt.

Trình điều khiển được thiết lập sao cho khi áp dụng bản vá zerocopy,
  tất cả các thiết bị Tornado và Cyclone sẽ sử dụng tổng kiểm tra S/G và Tx.

Tham số mô-đun này đã được cung cấp để bạn có thể ghi đè lên tham số này
  quyết định.  Nếu bạn cho rằng tổng kiểm tra Tx đang gây ra sự cố, thì bạn
  có thể tắt tính năng này bằng ZZ0000ZZ.

Nếu bạn cho rằng NIC của bạn nên thực hiện kiểm tra tổng hợp Tx và
  trình điều khiển không kích hoạt nó, bạn có thể buộc sử dụng phần cứng Tx
  kiểm tra tổng bằng ZZ0000ZZ.

Trình điều khiển gửi một thông báo vào tệp nhật ký để cho biết liệu
  không phải nó đang sử dụng phân tán/thu thập phần cứng và tổng kiểm tra Tx phần cứng.

Tổng kiểm tra phân tán/thu thập và phần cứng cung cấp đáng kể
  cải thiện hiệu suất cho lệnh gọi hệ thống sendfile(), nhưng một chút
  giảm thông lượng cho gửi().  Không có hiệu lực khi nhận
  hiệu quả.

compaq_ioaddr=N,
compaq_irq=N,
compaq_device_id=N

"Các biến để giải quyết vấn đề Compaq PCI BIOS32"...

cơ quan giám sát=N

Đặt khoảng thời gian (tính bằng mili giây) sau đó kernel
  quyết định rằng máy phát đã bị kẹt và cần được thiết lập lại.
  Điều này chủ yếu nhằm mục đích gỡ lỗi, mặc dù nó có thể có lợi
  để tăng giá trị này trên các mạng LAN có tỷ lệ xung đột rất cao.
  Giá trị mặc định là 5000 (5,0 giây).

Enable_wol=N1,N2,N3,...

Bật hỗ trợ Wake-on-LAN cho giao diện liên quan.  Donald
  Ứng dụng ZZ0000ZZ của Becker có thể được sử dụng để đánh thức bị treo
  máy móc.

Đồng thời cho phép hỗ trợ quản lý năng lượng của NIC.

toàn cầu_enable_wol=N

Đặt chế độ Enable_wol cho tất cả NIC 3c59x trong máy.  Bài viết trong
  mảng ZZ0000ZZ ở trên sẽ ghi đè mọi cài đặt này.

Lựa chọn phương tiện
--------------------

Một số NIC cũ hơn như dòng 3c590 và 3c900 có
Giao diện 10base2 và AUI.

Trước tháng 1 năm 2001, trình điều khiển này sẽ tự động chọn 10base2 hoặc AUI
port nếu nó không phát hiện hoạt động trên cổng 10baseT.  Sau đó nó sẽ
bị kẹt trên cổng 10base2 và cần phải tải lại trình điều khiển để
chuyển về 10baseT.  Hành vi này không thể được ngăn chặn bằng
ghi đè tùy chọn mô-đun.

Các phiên bản mới hơn (hiện tại) của trình điều khiển _do_ hỗ trợ khóa
loại phương tiện truyền thông.  Vì vậy, nếu bạn tải mô-đun trình điều khiển bằng

tùy chọn modprobe 3c59x=0

nó sẽ chọn vĩnh viễn cổng 10baseT.  Tự động lựa chọn
các loại phương tiện truyền thông khác không xảy ra.


Lỗi truyền, thanh ghi trạng thái Tx 82
--------------------------------------

Đây là một lỗi phổ biến hầu như luôn xảy ra do một máy chủ khác trên
cùng một mạng đang ở chế độ song công hoàn toàn, trong khi máy chủ này ở chế độ
chế độ bán song công.  Bạn cần tìm máy chủ khác và cho nó chạy vào
chế độ bán song công hoặc sửa máy chủ này để chạy ở chế độ song công hoàn toàn.

Phương án cuối cùng là bạn có thể buộc trình điều khiển 3c59x chuyển sang chế độ song công hoàn toàn
với

tùy chọn 3c59x full_duplex=1

nhưng điều này phải được xem như một giải pháp cho thiết bị mạng bị hỏng và
chỉ thực sự được sử dụng cho các thiết bị không thể tự động đàm phán.


Tài nguyên bổ sung
--------------------

Chi tiết về việc triển khai trình điều khiển thiết bị nằm ở đầu tệp nguồn.

Tài liệu bổ sung có sẵn tại trang Trình điều khiển Linux của Don Becker:

ZZ0000ZZ

Trang web phát triển trình điều khiển của Donald Becker:

ZZ0000ZZ

Chương trình vortex-diag của Donald rất hữu ích để kiểm tra trạng thái của NIC:

ZZ0000ZZ

Chương trình mii-diag của Donald có thể được sử dụng để kiểm tra và thao tác
Hệ thống con Giao diện độc lập với phương tiện của NIC:

ZZ0000ZZ

Trang đánh thức LAN của Donald:

ZZ0000ZZ

Ứng dụng dựa trên DOS của 3Com để thiết lập EEPROM NIC:

ftp://ftp.3com.com/pub/nic/3c90x/3c90xx2.exe


Ghi chú tự động đàm phán
------------------------

Người lái xe sử dụng nhịp tim một phút để thích ứng với những thay đổi trong
  môi trường LAN bên ngoài nếu liên kết hoạt động và 5 giây nếu liên kết không hoạt động.
  Điều này có nghĩa là, ví dụ như khi một máy được rút phích cắm ra khỏi hubbed
  10baseT LAN cắm vào 100baseT LAN đã chuyển mạch, thông lượng
  sẽ khá khủng khiếp trong tối đa sáu mươi giây.  Hãy kiên nhẫn.

Ghi chú về khả năng tương tác của Cisco từ Walter Wong <wcw+@CMU.EDU>:

Ngoài ra, việc thêm HAS_NWAY dường như có một vấn đề với
  Bộ chuyển mạch Cisco 6509.  Cụ thể, bạn cần thay đổi khoảng cách
  tham số cây cho cổng mà máy được cắm vào 'portfast'
  chế độ.  Nếu không, cuộc đàm phán sẽ thất bại.  Đây đã là một vấn đề
  chúng tôi đã để ý từ lâu nhưng chưa có thời gian để theo dõi.

Thiết bị chuyển mạch Cisco (Jeff Busch <jbusch@deja.com>)

"Cấu hình tiêu chuẩn" của tôi dành cho các cổng mà PC/máy chủ kết nối trực tiếp ::

giao diện FastEthernet0/N
	mô tả tên máy
	khoảng thời gian tải 30
	portfast cây bao trùm

Nếu quá trình tự động thương lượng gặp vấn đề, bạn có thể cần chỉ định "tốc độ
    100" và "song công hoàn toàn" (hoặc "tốc độ 10" và "song công một nửa").

WARNING: DO NOT kết nối các trung tâm/công tắc/cầu nối với những thiết bị này
    cổng được cấu hình đặc biệt! Công tắc sẽ trở nên rất bối rối.


Báo cáo và chẩn đoán vấn đề
---------------------------------

Người bảo trì thấy rằng các báo cáo vấn đề chính xác và đầy đủ được
vô giá trong việc giải quyết các vấn đề về trình điều khiển.  Chúng tôi thường xuyên không thể
tái tạo các vấn đề và phải dựa vào sự kiên nhẫn và nỗ lực của bạn để giải quyết
tận cùng của vấn đề.

Nếu bạn cho rằng mình có vấn đề về trình điều khiển thì đây là một số
các bước bạn nên thực hiện:

- Có thực sự là vấn đề về tài xế không?

Loại bỏ một số biến: thử các thẻ khác nhau, khác nhau
   máy tính, các loại cáp khác nhau, các cổng khác nhau trên switch/hub,
   các phiên bản khác nhau của kernel hoặc của trình điều khiển, v.v.

- Được rồi, đó là vấn đề về tài xế.

Bạn cần tạo một báo cáo.  Thông thường đây là một email gửi tới
   người bảo trì và/hoặc netdev@vger.kernel.org.  của người bảo trì
   địa chỉ email sẽ nằm trong nguồn trình điều khiển hoặc trong tệp MAINTAINERS.

- Nội dung báo cáo của bạn sẽ thay đổi rất nhiều tùy thuộc vào
  vấn đề.  Nếu đó là lỗi kernel thì bạn nên tham khảo
  'Tài liệu/admin-guide/reporting-issues.rst'.

Nhưng đối với hầu hết các vấn đề, sẽ rất hữu ích nếu cung cấp những thông tin sau:

- Phiên bản hạt nhân, phiên bản trình điều khiển

- Bản sao của thông báo biểu ngữ mà trình điều khiển tạo ra khi
     nó được khởi tạo.  Ví dụ:

eth0: 3Com PCI 3c905C Cơn lốc xoáy ở 0xa400, 00:50:da:6a:88:f0, IRQ 19
     Giao diện RAM 5:3 Rx:Tx rộng 8K byte, tự động chọn/tự động đàm phán.
     Bộ thu phát MII được tìm thấy tại địa chỉ 24, trạng thái 782d.
     Cho phép truyền bus-master và nhận toàn bộ khung.

NOTE: Bạn phải cung cấp tùy chọn modprobe ZZ0000ZZ để tạo
     một thông báo phát hiện đầy đủ.  Hãy làm điều này::

modprobe 3c59x gỡ lỗi = 2

- Nếu là thiết bị PCI, đầu ra liên quan từ 'lspci -vx', ví dụ::

00:09.0 Bộ điều khiển Ethernet: 3Com Corporation 3c905C-TX [Fast Etherlink] (rev 74)
	       Hệ thống con: Tập đoàn 3Com: Không rõ thiết bị 9200
	       Cờ: bus master, devsel trung bình, độ trễ 32, IRQ 19
	       Cổng I/O ở a400 [size=128]
	       Bộ nhớ tại db000000 (32-bit, không thể tìm nạp trước) [size=128]
	       Mở rộng ROM tại <chưa được chỉ định> [đã tắt] [size=128K]
	       Khả năng: [dc] Quản lý nguồn phiên bản 2
       00: b7 10 00 92 07 00 10 02 74 00 00 02 08 20 00 00
       10: 01 a4 00 00 00 00 00 db 00 00 00 00 00 00 00 00
       20: 00 00 00 00 00 00 00 00 00 00 00 00 b7 10 00 10
       30: 00 00 00 00 dc 00 00 00 00 00 00 00 05 01 0a 0a

- Mô tả môi trường: 10baseT? 100baseT?
     song công hoàn toàn/bán song công? chuyển đổi hoặc trung tâm?

- Bất kỳ thông số mô-đun bổ sung nào mà bạn có thể cung cấp cho trình điều khiển.

- Bất kỳ nhật ký hạt nhân nào được tạo ra.  Càng nhiều càng vui.
     Nếu đây là một tệp lớn và bạn đang gửi báo cáo của mình tới một
     danh sách gửi thư, hãy đề cập rằng bạn có tệp nhật ký nhưng không gửi
     nó.  Nếu bạn đang báo cáo trực tiếp cho người bảo trì thì chỉ cần gửi
     nó.

Để đảm bảo rằng tất cả nhật ký kernel đều có sẵn, hãy thêm
     dòng sau tới /etc/syslog.conf::

kern.* /var/log/messages

Sau đó khởi động lại syslogd với::

/etc/rc.d/init.d/syslog khởi động lại

(Phần trên có thể khác nhau, tùy thuộc vào bản phân phối Linux mà bạn sử dụng).

- Nếu vấn đề của bạn có thể tái hiện được thì thật tuyệt.  Hãy thử
      sau đây:

1) Tăng mức độ gỡ lỗi.  Thông thường việc này được thực hiện thông qua:

a) gỡ lỗi trình điều khiển modprobe = 7
	 b) Trong /etc/modprobe.d/driver.conf:
	    gỡ lỗi trình điều khiển tùy chọn = 7

2) Tạo lại sự cố với mức gỡ lỗi cao hơn,
	 gửi tất cả nhật ký cho người bảo trì.

3) Tải xuống công cụ chẩn đoán thẻ của bạn từ Donald
	 Trang web của Becker <ZZ0000ZZ
	 Tải xuống mii-diag.c.  Xây dựng những thứ này.

a) Chạy 'vortex-diag -aaee' và 'mii-diag -v' khi thẻ được
	    hoạt động chính xác  Lưu kết quả đầu ra.

b) Chạy các lệnh trên khi thẻ gặp trục trặc.  Gửi
	    cả hai bộ đầu ra.

Cuối cùng, hãy kiên nhẫn và chuẩn bị thực hiện một số công việc.  Bạn có thể
kết thúc việc giải quyết vấn đề này trong một tuần hoặc hơn với tư cách là người bảo trì
đặt nhiều câu hỏi hơn, yêu cầu thực hiện nhiều bài kiểm tra hơn, yêu cầu cung cấp các bản vá lỗi
được áp dụng, v.v. Cuối cùng, vấn đề thậm chí có thể vẫn còn
chưa được giải quyết.