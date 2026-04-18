.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/arcnet-hardware.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Phần cứng ARCnet
=================

:Tác giả: Avery Pennarun <apenwarr@worldvisions.ca>

.. note::

   1) This file is a supplement to arcnet.rst.  Please read that for general
      driver configuration help.
   2) This file is no longer Linux-specific.  It should probably be moved out
      of the kernel sources.  Ideas?

Bởi vì rất nhiều người (bao gồm cả tôi) dường như đã có được thẻ ARCnet
không có hướng dẫn sử dụng, tệp này chứa phần giới thiệu nhanh về phần cứng ARCnet,
một số mẹo đi cáp và danh sách tất cả các cài đặt jumper mà tôi có thể tìm thấy. Nếu bạn
có bất kỳ cài đặt nào cho thẻ cụ thể của bạn và/hoặc bất kỳ thông tin nào khác mà bạn
đã có thì đừng ngần ngại đến với ZZ0000ZZ.


Giới thiệu về ARCnet
======================

ARCnet là loại mạng hoạt động tương tự như Ethernet phổ biến
mạng nhưng cũng khác nhau ở một số điểm rất quan trọng.

Trước hết, bạn có thể nhận thẻ ARCnet ở ít nhất hai tốc độ: 2,5 Mbps
(chậm hơn Ethernet) và 100 Mbps (nhanh hơn Ethernet thông thường).  Trên thực tế,
cũng có những cái khác, nhưng những cái này ít phổ biến hơn.  Phần cứng khác nhau
theo như tôi biết, các loại không tương thích và do đó bạn không thể nối dây
Thẻ 100 Mbps sang thẻ 2,5 Mbps, v.v.  Theo những gì tôi nghe được thì tài xế của tôi làm
hoạt động với thẻ 100 Mbps, nhưng tôi chưa thể tự mình xác minh điều này,
vì tôi chỉ có loại 2,5 Mbps.  Có lẽ nó sẽ không bão hòa
thẻ 100 Mbps của bạn.  Đừng phàn nàn nữa. :)

Bạn cũng không thể kết nối thẻ ARCnet với bất kỳ loại thẻ Ethernet nào và
mong đợi nó hoạt động.

Có hai "loại" ARCnet - cấu trúc liên kết STAR và cấu trúc liên kết BUS.  Cái này
đề cập đến cách các thẻ được kết nối với nhau.  Theo hầu hết
tài liệu có sẵn, bạn chỉ có thể kết nối thẻ STAR với thẻ STAR và
Thẻ BUS sang thẻ BUS.  Điều đó có ý nghĩa, phải không?  Ừm, nó không hẳn
đúng; xem bên dưới trong phần "Cáp".

Khi bạn vượt qua được những trở ngại nhỏ này, ARCnet thực sự là một
tiêu chuẩn được thiết kế tốt.  Nó sử dụng cái gọi là "chuyển mã thông báo đã sửa đổi"
điều này làm cho nó hoàn toàn không tương thích với cái gọi là thẻ "Token Ring",
nhưng điều này làm cho việc truyền tải trở nên đáng tin cậy hơn nhiều so với Ethernet.  Trên thực tế,
ARCnet sẽ đảm bảo gói tin đến đích an toàn và
ngay cả khi nó không thể được giao đúng cách (tức là do cáp
bị hỏng hoặc do máy tính đích không tồn tại) ít nhất nó sẽ
nói với người gửi về nó.

Do hành động được xác định cẩn thận của "mã thông báo", nó sẽ luôn tạo ra
vượt qua "vòng" trong khoảng thời gian tối đa.  Điều này làm cho nó
hữu ích cho các mạng thời gian thực.

Ngoài ra, tất cả các thẻ ARCnet đã biết đều có chương trình (gần như) giống hệt nhau.
giao diện.  Điều này có nghĩa là với một trình điều khiển ARCnet bạn có thể hỗ trợ bất kỳ
thẻ, trong khi với Ethernet mỗi nhà sản xuất đôi khi sử dụng một
giao diện lập trình hoàn toàn khác nhau, dẫn đến rất nhiều giao diện khác nhau,
đôi khi rất giống nhau, trình điều khiển Ethernet.  Tất nhiên, luôn sử dụng cùng một
giao diện lập trình cũng có nghĩa là khi phần cứng hiệu năng cao
xuất hiện tiện ích như PCI làm chủ xe buýt DMA, khó mà tận dụng được
họ.  Chúng ta đừng đi sâu vào vấn đề đó.

Tuy nhiên, một điều khiến thẻ ARCnet khó lập trình là
giới hạn kích thước gói tin của họ; ARCnet tiêu chuẩn chỉ có thể gửi các gói
dài tới 508 byte.  Cái này nhỏ hơn Internet ở mức "tối thiểu"
576 byte, chứ chưa nói đến Ethernet MTU là 1500. Để bù lại, một khoản bổ sung
mức độ đóng gói được xác định bởi RFC1201, mà tôi gọi là "gói
chia nhỏ", cho phép "gói ảo" phát triển lớn tới 64K mỗi gói,
mặc dù chúng thường được giữ ở mức 1500 byte kiểu Ethernet.

Để biết thêm thông tin về mạng ARCnet, hãy truy cập "Trung tâm tài nguyên ARCNET"
Trang WWW tại:

ZZ0000ZZ


Đi cáp Mạng ARCnet
=======================

Phần này được viết lại bởi

Vojtech Pavlik <vojtech@suse.cz>

sử dụng thông tin từ nhiều người, bao gồm:

- Avery Pennraun <apenwarr@worldvisions.ca>
	- Stephen A. Wood <saw@hallc1.cebaf.gov>
	- John Paul Morrison <jmorriso@bogomips.ee.ubc.ca>
	- Joachim Koenig <jojo@repas.de>

và Avery đã chỉnh sửa nó một chút theo yêu cầu của Vojtech.

ARCnet (phiên bản 2,5 Mbps cổ điển) có thể được kết nối bằng hai
loại cáp: cáp đồng trục và cáp xoắn đôi.  Các mạng loại ARCnet khác
(100 Mbps TCNS và 320 kbps - 32 Mbps ARCnet Plus) sử dụng các loại
cáp (Type1, Fiber, C1, C4, C5).

Đối với mạng cáp đồng trục, bạn “nên” sử dụng cáp RG-62 93 Ohm.  Nhưng các loại cáp khác
cũng hoạt động tốt vì ARCnet là mạng rất ổn định. Cá nhân tôi sử dụng 75
Cáp ăng-ten TV Ohm.

Thẻ dành cho cáp đồng trục được vận chuyển theo hai biến thể khác nhau: dành cho BUS và
Cấu trúc liên kết mạng STAR.  Chúng hầu hết đều giống nhau.  Sự khác biệt duy nhất
nằm trong chip lai được cài đặt.  Thẻ BUS sử dụng đầu ra trở kháng cao,
trong khi STAR sử dụng trở kháng thấp.  Thẻ trở kháng thấp (STAR) được cấp điện
bằng trở kháng cao có lắp đặt đầu cuối.

Thông thường, mạng ARCnet được xây dựng từ thẻ và hub STAR.  Ở đó
có hai loại trung tâm - chủ động và thụ động.  Hub thụ động là những hộp nhỏ
với bốn đầu nối BNC chứa bốn điện trở 47 Ohm::

Dây ZZ0000ZZ
	   Ngã ba R +
	-R-+-R- R Điện trở 47 Ohm
	   R
	   |

Tấm chắn được kết nối với nhau.  Các trung tâm hoạt động phức tạp hơn nhiều;
chúng được cấp nguồn và chứa các thiết bị điện tử để khuếch đại tín hiệu và gửi nó
tới các phân đoạn khác của mạng.  Chúng thường có tám đầu nối.  Đang hoạt động
trung tâm có hai biến thể - ngu ngốc và thông minh.  Biến thể câm chỉ
khuếch đại, nhưng thiết bị thông minh sẽ giải mã thành kỹ thuật số và mã hóa lại tất cả các gói
đang đi qua.  Điều này sẽ tốt hơn nhiều nếu bạn có nhiều hub trên mạng,
vì nhiều trung tâm hoạt động không hoạt động có thể làm giảm chất lượng tín hiệu.

Và bây giờ đến hệ thống cáp.  Những gì bạn có thể kết nối với nhau:

1. Thẻ này sang thẻ khác.  Đây là cách đơn giản nhất để tạo 2 máy tính
   mạng.

2. Thẻ tới một trung tâm thụ động.  Hãy nhớ rằng tất cả các đầu nối không được sử dụng trên hub
   phải được kết thúc đúng cách với 93 Ohm (hoặc thứ gì khác nếu bạn không
   có những cái đúng) thiết bị đầu cuối.

(Ghi chú của Avery: ôi, tôi không biết điều đó. Của tôi (cáp TV) hoạt động được
	dù sao đi nữa.)

3. Thẻ tới một trung tâm đang hoạt động.  Ở đây không cần phải chấm dứt việc không sử dụng
   kết nối ngoại trừ một số loại cảm giác thẩm mỹ.  Nhưng, có thể không có
   hơn 11 hub hoạt động giữa hai máy tính bất kỳ.  Điều đó tất nhiên
   không giới hạn số lượng hub hoạt động trên mạng.

4. Một trung tâm hoạt động cho một trung tâm khác.

5. Từ trung tâm hoạt động đến trung tâm thụ động.

Hãy nhớ rằng bạn không thể kết nối hai hub thụ động với nhau.  Mất điện
ngụ ý rằng kết nối như vậy là quá cao để mạng có thể hoạt động đáng tin cậy.

Một ví dụ về mạng ARCnet điển hình::

R S - STAR loại thẻ
    S------H--------A-------S R - Kẻ Hủy Diệt
	   ZZ0000ZZ H-Hub
	   ZZ0001ZZ A - Trung tâm hoạt động
	   |   S----H----S
	   S |
		    |
		    S

Cấu trúc liên kết BUS rất giống với cấu trúc được sử dụng bởi Ethernet.  duy nhất
sự khác biệt nằm ở cáp và đầu cuối: chúng phải là 93 Ohm.  Ethernet
sử dụng trở kháng 50 Ohm. Bạn sử dụng đầu nối chữ T để đặt các máy tính vào một
đường dây cáp, xe buýt. Bạn phải đặt các thiết bị đầu cuối ở cả hai đầu của
cáp. Mạng ARCnet BUS điển hình trông giống như::

RT----T------T------T------T------TR
     B B B B B B

B - Thẻ loại BUS
  R - Kẻ Hủy Diệt
  Đầu nối T - T

Nhưng đó không phải là tất cả! Hai loại có thể được kết nối với nhau.  Theo
tài liệu chính thức cách duy nhất để kết nối chúng là sử dụng một
trung tâm::

A------T------T------TR
	 |      B B B
     S---H---S
	 |
	 S

Các tài liệu chính thức cũng nêu rõ rằng bạn có thể sử dụng thẻ STAR ở cuối
Mạng BUS thay cho thẻ BUS và thiết bị đầu cuối::

S------T------T------S
	    B B

Tuy nhiên, theo thử nghiệm của riêng tôi, bạn có thể chỉ cần treo thẻ loại BUS
bất cứ nơi nào ở giữa cáp trong mạng cấu trúc liên kết STAR.  Và hơn thế nữa - bạn
có thể sử dụng thẻ xe buýt thay cho bất kỳ thẻ sao nào nếu bạn sử dụng bộ kết thúc. Sau đó
bạn có thể xây dựng các mạng rất phức tạp đáp ứng mọi nhu cầu của bạn!  Một
ví dụ::

S
				  |
	   RT------T-------T------H------S
	    B B B |
				  |       R
    S------A------T-------T-------A-------H------TR
	   ZZ0000ZZ |      B
	   ZZ0001ZZ
	   ZZ0002ZZ |  S----A----S
    S------H---A----S ZZ0003ZZ
	   ZZ0004ZZ S------T----H---S |
	   S S B R S

Một sơ đồ cáp cơ bản khác được sử dụng với cáp Twisted Pair. Mỗi
của thẻ TP có hai đầu nối RJ (kiểu dây điện thoại).  Các thẻ là
sau đó nối với nhau bằng cáp kết nối hai hàng xóm
thẻ.  Các đầu được kết thúc bằng đầu cuối RJ 93 Ohm cắm vào
các đầu nối trống của thẻ ở đầu chuỗi.  Một ví dụ::

___________ ___________
      _R_ZZ0000ZZ_ZZ0001ZZ_R_
     ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ
     ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
     ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ


Ngoài ra còn có các trung tâm cho cấu trúc liên kết TP.  Không có gì khó khăn
tham gia vào việc sử dụng chúng; bạn chỉ cần kết nối chuỗi TP với một trung tâm ở bất kỳ đầu nào hoặc
thậm chí ở cả hai.  Bằng cách này bạn có thể tạo hầu hết mọi cấu hình mạng.
Ở đây áp dụng tối đa 11 hub giữa hai máy tính bất kỳ trên mạng.
tốt.  Một ví dụ::

RP-------P-------P-------H-----P------P----PR
			       |
      RP------H--------P--------H------P------PR
	     ZZ0000ZZ
	     PR PR

R - Kẻ Hủy Diệt RJ
    Thẻ P - TP
    H - TP Hub

Giống như bất kỳ mạng nào, ARCnet có chiều dài cáp giới hạn.  Đây là mức tối đa
chiều dài cáp giữa hai đầu hoạt động (đầu hoạt động là một hub hoạt động hoặc
thẻ STAR).

========== ======= ============
		RG-62 93 Ohm lên tới 650 m
		RG-59/U 75 Ohm lên tới 457 m
		RG-11/U 75 Ohm lên tới 533 m
		IBM Loại 1 150 Ohm lên tới 200 m
		IBM Loại 3 100 Ohm lên tới 100 m
		========== ======= ============

Độ dài tối đa của tất cả các cáp kết nối với hub thụ động được giới hạn ở mức 65
mét cho cáp RG-62; ít hơn cho người khác.  Bạn có thể thấy rằng bằng cách sử dụng thụ động
trung tâm trong một mạng lớn là một ý tưởng tồi. Độ dài tối đa của một "BUS"
Trunk" là khoảng 300 mét đối với RG-62. Khoảng cách tối đa giữa hai
điểm xa nhất của lưới được giới hạn ở 3000 mét. Chiều dài tối đa
của cáp TP giữa hai card/hub là 650 mét.


Cài đặt Jumper
===================

Tất cả các thẻ ARCnet phải có tổng cộng bốn hoặc năm cài đặt khác nhau:

- địa chỉ I/O: đây là "cổng" thẻ ARCnet của bạn được bật.  thăm dò
    các giá trị trong trình điều khiển Linux ARCnet chỉ từ 0x200 đến 0x3F0. (Nếu
    Thẻ của bạn có thẻ bổ sung, nếu có thể, vui lòng cho tôi biết.) Cái này
    không được giống với bất kỳ thiết bị nào khác trên hệ thống của bạn.  Theo
    một tài liệu tôi nhận được từ Novell, MS Windows ưu tiên các giá trị từ 0x300 trở lên,
    ăn các kết nối mạng trên hệ thống của tôi (ít nhất).  tôi đoán là
    điều này có thể là do, nếu thẻ của bạn ở mức 0x2E0, việc thăm dò cổng nối tiếp
    tại 0x2E8 sẽ thiết lập lại thẻ và có thể làm mọi thứ rối tung lên.

- Avery yêu thích: 0x300.

- IRQ: trên thẻ 8 bit, nó có thể là 2 (9), 3, 4, 5 hoặc 7.
	     trên thẻ 16 bit, nó có thể là 2 (9), 3, 4, 5, 7 hoặc 10-15.

Đảm bảo rằng thẻ này khác với bất kỳ thẻ nào khác trên hệ thống của bạn.  Lưu ý
    rằng IRQ2 cũng giống như IRQ9, đối với Linux.  bạn có thể
    "cat /proc/interrupts" để biết danh sách khá đầy đủ về những cái nào có trong đó
    sử dụng vào bất kỳ thời điểm nào.  Dưới đây là danh sách các cách sử dụng phổ biến từ Vojtech
    Pavlik <vojtech@suse.cz>:

("Không có trên xe buýt" có nghĩa là không có cách nào để thẻ tạo ra điều này
	ngắt)

====== ===============================================================
	IRQ 0 Hẹn giờ 0 (Không có trên xe buýt)
	Bàn phím IRQ 1 (Không có trên xe buýt)
	IRQ 2 IRQ Bộ điều khiển 2 (Không trên bus, cũng không làm gián đoạn CPU)
	IRQ 3 COM2
	IRQ 4 COM1
	IRQ 5 FREE (LPT2 nếu bạn có; đôi khi là COM3; có thể là PLIP)
	IRQ 6 Bộ điều khiển đĩa mềm
	IRQ 7 FREE (LPT1 nếu bạn không sử dụng trình điều khiển bỏ phiếu; PLIP)
	IRQ 8 Ngắt đồng hồ thời gian thực (Không phải trên xe buýt)
	IRQ 9 FREE (Ngắt đồng bộ dọc VGA nếu được bật)
	IRQ 10 FREE
	IRQ 11 FREE
	IRQ 12 FREE
	Bộ đồng xử lý số IRQ 13 (Không có trên xe buýt)
	Bộ điều khiển đĩa cố định IRQ 14
	IRQ 15 FREE (Bộ điều khiển đĩa cố định 2 nếu bạn có)
	====== ===============================================================


	.. note::

	   IRQ 9 is used on some video cards for the "vertical retrace"
	   interrupt.  This interrupt would have been handy for things like
	   video games, as it occurs exactly once per screen refresh, but
	   unfortunately IBM cancelled this feature starting with the original
	   VGA and thus many VGA/SVGA cards do not support it.  For this
	   reason, no modern software uses this interrupt and it can almost
	   always be safely disabled, if your video card supports it at all.

Nếu thẻ của bạn vì lý do nào đó CANNOT vô hiệu hóa IRQ này (thường có
	là một jumper), một giải pháp là cắt mạch in
	liên hệ trên bảng: đó là liên hệ thứ tư từ bên trái trên bảng
	mặt sau.  Tôi không chịu trách nhiệm nếu bạn thử điều này.

- Avery yêu thích: IRQ2 (thực ra là IRQ9).  Tuy nhiên, hãy xem VGA đó.

- địa chỉ bộ nhớ: Không giống như hầu hết các thẻ, ARCnets sử dụng "bộ nhớ dùng chung" cho
    sao chép bộ đệm xung quanh.  Tạo SURE nó không xung đột với bất kỳ cái nào khác
    bộ nhớ đã sử dụng trong hệ thống của bạn!

    ::

A0000 - Bộ nhớ đồ họa VGA (ok nếu bạn không có VGA)
	B0000 - Chế độ văn bản đơn sắc
	C0000 \ Một trong số đó là VGA BIOS của bạn - thường là C0000.
	E0000 /
	F0000 - Hệ thống BIOS

Bất cứ điều gì nhỏ hơn 0xA0000 đều là ý tưởng BAD vì nó không ở trên
    640k.

- Avery yêu thích: 0xD0000

- địa chỉ trạm: Mỗi thẻ ARCnet có mạng "duy nhất" riêng
    địa chỉ từ 0 đến 255. Không giống như Ethernet, bạn có thể đặt địa chỉ này
    chính mình bằng một nút nhảy hoặc công tắc (hoặc trên một số thẻ, có đặc biệt
    phần mềm).  Vì chỉ có 8 bit nên bạn chỉ có thể có 254 thẻ ARCnet
    trên một mạng.  DON'T sử dụng 0 hoặc 255, vì chúng được bảo lưu (mặc dù
    những thứ gọn gàng có thể sẽ xảy ra nếu bạn CÓ sử dụng chúng).  Nhân tiện, nếu bạn
    chưa đoán được, đừng đặt cái này giống với bất kỳ ARCnet nào khác trên
    mạng của bạn!

- Avery thích nhất: 3 và 4. Điều đó không quan trọng.

- Có thể có cài đặt ETS1 và ETS2.  Những điều này có thể hoặc không thể tạo nên
    sự khác biệt trên thẻ của bạn (nhiều sách hướng dẫn gọi chúng là "dành riêng"), nhưng
    được sử dụng để thay đổi độ trễ được sử dụng khi bật nguồn máy tính trên
    mạng.  Điều này chỉ cần thiết khi nối dây ARCnet tầm xa VERY
    mạng lưới, khoảng 4km hoặc hơn; trong mọi trường hợp, điều thực sự duy nhất
    yêu cầu ở đây là tất cả các thẻ trên mạng có ETS1 và ETS2
    người nhảy có chúng ở cùng một vị trí.  Chris Hindy <chrish@io.org>
    được gửi trong biểu đồ với các giá trị thực tế cho việc này:

============== =======================================
	ET1 ET2 Thời gian đáp ứng Thời gian cấu hình lại
	============== =======================================
	mở mở 74.7us 840us
	mở đóng 283.4us 1680us
	đóng mở 561.8us 1680us
	đóng cửa đóng 1118.6us 1680us
	============== =======================================

Đảm bảo bạn đặt ETS1 và ETS2 thành SAME VALUE cho tất cả các thẻ trên
    mạng.

Ngoài ra, trên nhiều thẻ (không phải của tôi) có LED màu đỏ và xanh lục.
Vojtech Pavlik <vojtech@suse.cz> cho tôi biết đây là ý nghĩa của chúng:

========================================================================
	Trạng thái GREEN RED
	========================================================================
	OFF OFF Tắt nguồn
	OFF Nhấp nháy ngắn Sự cố về cáp (cáp bị hỏng hoặc không
					chấm dứt)
	OFF (ngắn) ON Card init
	BẬT TRÊN Trạng thái bình thường - mọi thứ đều ổn, không có gì
					xảy ra
	BẬT Nhấp nháy dài Truyền dữ liệu
	TRÊN OFF Không bao giờ xảy ra (có thể khi sai ID)
	========================================================================


Sau đây là tất cả thông tin cụ thể mà mọi người đã gửi cho tôi
thẻ ARCnet cụ thể của riêng họ.  Nó chính thức là một mớ hỗn độn và chứa đựng
lượng lớn thông tin trùng lặp.  Tôi không có thời gian để sửa nó.  Nếu bạn
muốn, PLEASE LÀM!  Chỉ cần gửi cho tôi 'diff -u' về tất cả những thay đổi của bạn.

Mẫu # is được liệt kê ngay phía trên thông số cụ thể của thẻ đó, vì vậy bạn nên
có thể sử dụng chức năng "tìm kiếm" của trình xem văn bản để tìm mục bạn muốn.
Nếu bạn không biết KNOW bạn có loại thẻ gì, hãy thử xem qua
các sơ đồ khác nhau để xem liệu bạn có thể nói được không.

Nếu kiểu máy của bạn không được liệt kê và/hoặc có các cài đặt khác, PLEASE PLEASE
kể cho tôi nghe.  Tôi đã phải tìm ra cách của mình mà không có hướng dẫn sử dụng, và nó là WASN'T FUN!

Ngay cả khi mô hình ARCnet của bạn không được liệt kê nhưng có cùng bộ nhảy như mô hình khác
mô hình đó, xin vui lòng gửi email cho tôi để nói như vậy.

Các thẻ được liệt kê trong tệp này (chủ yếu theo thứ tự này):

======================================== ====
	Nhà sản xuất Model #			Bits
	======================================== ====
	SMC PC100 8
	SMC PC110 8
	SMC PC120 8
	SMC PC130 8
	SMC PC270E 8
	SMC PC500 16
	SMC PC500Longboard 16
	SMC PC550Longboard 16
	SMC PC600 16
	SMC PC710 8
	SMC?		LCS-8830(-T) 16/8
	Dữ liệu thuần túy PDI507 8
	CNet Tech CN120-Series 8
	CNet Tech CN160-Dòng 16
	Lantech?	Chipset UM9065L 8
	Acer 5210-003 8
	Điểm dữ liệu?	LAN-ARC-8 8
	Topware TA-ARC/10 8
	Thomas-Conrad 500-6242-0097 REV A 8
	Waterloo?	(C)1985 Waterloo Micro. 8
	Không Tên -- 16/8
	Không có tên Đài Loan R.O.C?		8
	STT Tên Model 9058 8
	Tiara Tiara Lancard?		8
	======================================== ====


* SMC = Standard Microsystems Corp.
* CNet Tech = CNet Technology, Inc.

Nội dung chưa được phân loại
==================

- Xin vui lòng gửi bất kỳ thông tin khác mà bạn có thể tìm thấy.

- Và một số nội dung khác (chào mừng thêm thông tin!)::

Từ: root@ultraworld.xs4all.nl (Timo Hilbrink)
     Tới: apenwarr@foxnet.net (Avery Pennarun)
     Ngày: Thứ Tư, 26/10/1994 02:10:32 +0000 (GMT)
     Trả lời: timoh@xs4all.nl

[...các phần đã bị xóa...]

Giới thiệu về jumper: Trên PC130 của tôi còn có một jumper nữa, nằm gần
     đầu nối cáp và nó dùng để thay đổi cấu trúc liên kết hình sao hoặc bus;
     đóng: sao - mở: xe buýt
     Trên PC500 có thêm một số chân nhảy, một khối được gắn nhãn RX,PDN,TXI
     và một cái khác có ALE,LA17,LA18,LA19, những thứ này không có giấy tờ..

[...nhiều phần đã bị xóa...]

--- CUT ---

Tập đoàn Microsystems tiêu chuẩn (SMC)
================================

PC100, PC110, PC120, PC130 (thẻ 8 bit) và PC500, PC600 (thẻ 16 bit)
------------------------------------------------------------------------

- chủ yếu từ Avery Pennarun <apenwarr@worldvisions.ca>.  Giá trị được mô tả
    là từ sự thiết lập của Avery.
  - lời cảm ơn đặc biệt tới Timo Hilbrink <timoh@xs4all.nl> vì đã lưu ý rằng PC120,
    130, 500 và 600 đều có công tắc giống như PC100 của Avery.
    Tuy nhiên, PC500/600 có một số chân bổ sung, không có giấy tờ. (?)
  - Cài đặt PC110 đã được xác minh bởi Stephen A. Wood <saw@cebaf.gov>
  - Ngoài ra, số JP- và S có thể không khớp chính xác với thẻ của bạn.  Hãy thử
    để tìm các nút nhảy/công tắc có cùng số lượng cài đặt - đó là
    có lẽ đáng tin cậy hơn.

::

JP5 [|] : : : :
	(Cài đặt IRQ) IRQ2 IRQ3 IRQ4 IRQ5 IRQ7
			Đặt chính xác một nút nhảy vào đúng một bộ ghim.


1 2 3 4 5 6 7 8 9 10
	     S1 /-----------------------------------\
	(I/O và bộ nhớ ZZ0000ZZ
	 địa chỉ) \-----------------------------------/
				  ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
				  (a) (b) (m)

WARNING.  Điều này rất quan trọng khi thiết lập những cách này
			bạn đang cầm lá bài và bạn nghĩ hướng nào là '1'!

Nếu bạn nghi ngờ rằng cài đặt của mình không được thực hiện
			chính xác, hãy thử đảo ngược hướng hoặc đảo ngược
			chuyển đổi vị trí.

a: Chữ số đầu tiên của địa chỉ I/O.
				Giá trị cài đặt
				------- -----
				00 0
				01 1
				10 2
				11 3

b: Chữ số thứ hai của địa chỉ I/O.
				Giá trị cài đặt
				------- -----
				0000 0
				0001 1
				0010 2
				...		...
1110 Đ
				1111 F

Địa chỉ I/O có dạng ab0.  Ví dụ, nếu
			a là 0x2 và b là 0xE thì địa chỉ sẽ là 0x2E0.

LÀM NOT SET THIS LESS THAN 0x200!!!!!


m: Chữ số đầu tiên của địa chỉ bộ nhớ.
				Giá trị cài đặt
				------- -----
				0000 0
				0001 1
				0010 2
				...		...
1110 Đ
				1111 F

Địa chỉ bộ nhớ có dạng m0000.  Ví dụ, nếu
			m là D thì địa chỉ sẽ là 0xD0000.

LÀM NOT SET THIS ĐẾN C0000, F0000, HOẶC LESS THAN A0000!

1 2 3 4 5 6 7 8
	     S2 /--------------------------\
	(Địa chỉ trạm) ZZ0000ZZ
			       \--------------------------/

Giá trị cài đặt
				------- -----
				00000000 00
				10000000 01
				01000000 02
				...
01111111 FE
				11111111 FF

Lưu ý rằng đây là hệ nhị phân với các chữ số bị đảo ngược!

LÀM NOT SET THIS LÊN 0 HOẶC 255 (0xFF)!


PC130E/PC270E (thẻ 8 bit)
---------------------------

- từ Juergen Seifert <seifert@htwm.de>

Mô tả này được viết bởi Juergen Seifert <seifert@htwm.de>
sử dụng thông tin từ Sách hướng dẫn SMC gốc sau đây

"Hướng dẫn cấu hình cho mạng ARCNET(R)-PC130E/PC270
	     Ban điều khiển Pub. # 900.044A Tháng 6 năm 1989"

ARCNET là nhãn hiệu đã đăng ký của Tập đoàn Datapoint
SMC là nhãn hiệu đã đăng ký của Standard Microsystems Corporation

PC130E là phiên bản nâng cao của bo mạch PC130, được trang bị một
Đầu nối cái BNC tiêu chuẩn để kết nối với cáp đồng trục RG-62/U.
Vì bo mạch này được thiết kế cho cả kết nối điểm-điểm theo hình sao
mạng và để kết nối với mạng xe buýt, nó tương thích hướng xuống
với tất cả các bo mạch tiêu chuẩn khác được thiết kế cho mạng cáp đồng trục (nghĩa là,
các bo mạch cấu trúc liên kết hình sao PC120, PC110 và PC100 và PC220, PC210 và
Bảng cấu trúc liên kết xe buýt PC200).

PC270E là phiên bản nâng cao của bo mạch PC260, được trang bị hai
giắc cắm loại RJ11 mô-đun để kết nối với dây xoắn đôi.
Nó có thể được sử dụng trong mạng hình sao hoặc mạng nối tiếp nhau.

::

8 7 6 5 4 3 2 1
    ________________________________________________________________
   ZZ0000ZZ S1 ZZ0001ZZ
   ZZ0002ZZ_________________ZZ0003ZZ
   |    Offs|Base ZZ0005ZZ
   ZZ0006ZZ ___|
   ZZ0007ZZ___|
   ZZ0008ZZ \/ ZZ0009ZZ___|
   ZZ0010ZZ PROM ZZ0011ZZ
   ZZ0012ZZ ZZ0013ZZ | 8
   ZZ0014ZZ SOCKET ZZ0015ZZ | 7
   ZZ0016ZZ________ZZ0017ZZ | 6
   ZZ0018ZZ | 5
   ZZ0019ZZ ZZ0020ZZ S | 4
   |       |oo| EXT2  | ZZ0023ZZ 2 | 3
   |       |oo| EXT1  | SMC ZZ0026ZZ | 2
   |       |oo| ROM   | 90C63 ZZ0029ZZ___| 1
   |       |oo| IRQ7  | |               |o|  _____|
   |       |oo| IRQ5  | |               |o| | J1 |
   |       |oo| IRQ4  | ZZ0040ZZ_____|
   |       |oo| IRQ3  | ZZ0043ZZ J2 |
   |       |oo| IRQ2  |__________________|                   |_____|
   ZZ0047ZZ
       ZZ0048ZZ
       ZZ0049ZZ

Huyền thoại::

SMC 90C63 ARCNET Bộ điều khiển / Bộ thu phát / Logic
  S1 1-3: Chọn địa chỉ cơ sở I/O
	4-6: Chọn địa chỉ cơ sở bộ nhớ
	7-8: Chọn bù RAM
  S2 1-8: Chọn ID nút
  EXT Chọn thời gian chờ kéo dài
  ROM ROM Bật Chọn
  STAR đã chọn - Cấu trúc liên kết sao (chỉ PC130E)
		Đã bỏ chọn - Cấu trúc liên kết xe buýt (chỉ PC130E)
  Đèn LED chẩn đoán CR3/CR4
  Đầu nối J1 BNC RG62/U (chỉ PC130E)
  Giắc cắm điện thoại 6 vị trí J1 (chỉ PC270E)
  Giắc cắm điện thoại 6 vị trí J2 (chỉ PC270E)

Đặt một trong các công tắc thành Tắt/Mở có nghĩa là "1", Bật/Đóng có nghĩa là "0".


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong nhóm S2 được sử dụng để đặt ID nút.
Các công tắc này hoạt động theo cách tương tự như các thẻ dòng PC100; thấy điều đó
mục để biết thêm thông tin.


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ba công tắc đầu tiên trong nhóm công tắc S1 được sử dụng để chọn một công tắc
trong số tám địa chỉ Cơ sở I/O có thể sử dụng bảng sau::


Chuyển đổi | I/O lục giác
   1 2 3 | Địa chỉ
   -------|-------
   0 0 0 |  260
   0 0 1 |  290
   0 1 0 |  2E0 (Mặc định của nhà sản xuất)
   0 1 1 |  2F0
   1 0 0 |  300
   1 0 1 |  350
   1 1 0 |  380
   1 1 1 |  3E0


Đặt địa chỉ bộ đệm Bộ nhớ cơ sở (RAM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhớ đệm yêu cầu 2K của khối RAM 16K. Cơ sở của điều này
Khối 16K có thể được đặt ở bất kỳ vị trí nào trong tám vị trí.
Switch 4-6 của switch nhóm S1 chọn Base của khối 16K.
Trong không gian địa chỉ 16K đó, bộ đệm có thể được gán bất kỳ một trong bốn
vị trí, được xác định bằng độ lệch, công tắc 7 và 8 của nhóm S1.

::

Chuyển đổi ZZ0000ZZ Hex ROM
   4 5 6 7 8 ZZ0001ZZ Địa chỉ *)
   -----------ZZ0002ZZ----------
   0 0 0 0 0 ZZ0003ZZ C2000
   0 0 0 0 1 ZZ0004ZZ C2000
   0 0 0 1 0 ZZ0005ZZ C2000
   0 0 0 1 1 ZZ0006ZZ C2000
	      ZZ0007ZZ
   0 0 1 0 0 ZZ0008ZZ C6000
   0 0 1 0 1 ZZ0009ZZ C6000
   0 0 1 1 0 ZZ0010ZZ C6000
   0 0 1 1 1 ZZ0011ZZ C6000
	      ZZ0012ZZ
   0 1 0 0 0 ZZ0013ZZ CE000
   0 1 0 0 1 ZZ0014ZZ CE000
   0 1 0 1 0 ZZ0015ZZ CE000
   0 1 0 1 1 ZZ0016ZZ CE000
	      ZZ0017ZZ
   0 1 1 0 0 ZZ0018ZZ D2000 (Mặc định của nhà sản xuất)
   0 1 1 0 1 ZZ0019ZZ D2000
   0 1 1 1 0 ZZ0020ZZ D2000
   0 1 1 1 1 ZZ0021ZZ D2000
	      ZZ0022ZZ
   1 0 0 0 0 ZZ0023ZZ D6000
   1 0 0 0 1 ZZ0024ZZ D6000
   1 0 0 1 0 ZZ0025ZZ D6000
   1 0 0 1 1 ZZ0026ZZ D6000
	      ZZ0027ZZ
   1 0 1 0 0 ZZ0028ZZ DA000
   1 0 1 0 1 ZZ0029ZZ DA000
   1 0 1 1 0 ZZ0030ZZ DA000
   1 0 1 1 1 ZZ0031ZZ DA000
	      ZZ0032ZZ
   1 1 0 0 0 ZZ0033ZZ DE000
   1 1 0 0 1 ZZ0034ZZ DE000
   1 1 0 1 0 ZZ0035ZZ DE000
   1 1 0 1 1 ZZ0036ZZ DE000
	      ZZ0037ZZ
   1 1 1 0 0 ZZ0038ZZ E2000
   1 1 1 0 1 ZZ0039ZZ E2000
   1 1 1 1 0 ZZ0040ZZ E2000
   1 1 1 1 1 ZZ0041ZZ E2000

*) Để kích hoạt 8K Boot PROM, hãy cài đặt jumper ROM.
     Mặc định là jumper ROM chưa được cài đặt.


Đặt thời gian chờ và ngắt
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các jumper có nhãn EXT1 và EXT2 được sử dụng để xác định thời gian chờ
các thông số. Hai jumper này thường được để mở.

Để chọn mức ngắt phần cứng, hãy đặt một (chỉ một!) trong số các nút nhảy
IRQ2, IRQ3, IRQ4, IRQ5, IRQ7. Mặc định của Nhà sản xuất là IRQ2.


Định cấu hình PC130E cho cấu trúc liên kết sao hoặc bus
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Jumper đơn có nhãn STAR được sử dụng để cấu hình bo mạch PC130E cho
cấu trúc liên kết sao hoặc xe buýt.
Khi jumper được cài đặt, bo mạch có thể được sử dụng trong mạng sao, khi
nó được gỡ bỏ, bo mạch có thể được sử dụng trong cấu trúc liên kết xe buýt.


Đèn LED chẩn đoán
^^^^^^^^^^^^^^^

Hai đèn LED chẩn đoán có thể nhìn thấy ở giá đỡ phía sau của bo mạch.
LED màu xanh lá cây giám sát hoạt động mạng: màu đỏ hiển thị
hoạt động hội đồng::

Trạng thái ZZ0000ZZ màu xanh lá cây
 -------ZZ0001ZZ-------------------
  về truyền dữ liệu ZZ0002ZZ
  nhấp nháy ZZ0003ZZ không truyền dữ liệu;
  tắt ZZ0004ZZ bộ nhớ không chính xác hoặc
	Địa chỉ I/O ZZ0005ZZ


PC500/PC550 Longboard (thẻ 16-bit)
------------------------------------

- từ Juergen Seifert <seifert@htwm.de>


  .. note::

      There is another Version of the PC500 called Short Version, which
      is different in hard- and software! The most important differences
      are:

      - The long board has no Shared memory.
      - On the long board the selection of the interrupt is done by binary
công tắc được mã hóa, trên bảng ngắn trực tiếp bằng dây nhảy.

[Lưu ý của Avery: đặc biệt chú ý đến điều đó: bảng dài HAS NO SHARED
MEMORY.  Điều này có nghĩa là trình điều khiển Linux-ARCnet hiện tại không thể sử dụng các thẻ này.
Tôi đã có được PC500Longboard và sẽ thực hiện một số thử nghiệm trên nó trong
tương lai, nhưng đừng nín thở.  Một lần nữa xin cảm ơn Juergen Seifert vì
lời khuyên của anh ấy về việc này!]

Mô tả này được viết bởi Juergen Seifert <seifert@htwm.de>
sử dụng thông tin từ Sách hướng dẫn SMC gốc sau đây

"Hướng dẫn cấu hình cho SMC ARCNET-PC500/PC550
	 Series Bảng Điều Khiển Mạng Pub. # 900.033 Rev. A
	 Tháng 11 năm 1989"

ARCNET là nhãn hiệu đã đăng ký của Tập đoàn Datapoint
SMC là nhãn hiệu đã đăng ký của Standard Microsystems Corporation

PC500 được trang bị đầu nối cái BNC tiêu chuẩn để kết nối
đến cáp đồng trục RG-62/U.
Bảng mạch được thiết kế cho cả kết nối điểm-điểm trong mạng sao
và để kết nối với mạng lưới xe buýt.

PC550 được trang bị hai giắc cắm loại RJ11 mô-đun để kết nối
đến dây xoắn đôi.
Nó có thể được sử dụng trong mạng hình sao hoặc mạng nối tiếp (BUS).

::

1
       0 9 8 7 6 5 4 3 2 1 6 5 4 3 2 1
    ____________________________________________________________________
   < ZZ0000ZZ ZZ0001ZZ |
   > ZZ0002ZZ ZZ0003ZZ |
   < IRQ ZZ0004ZZ
   > ___|
   < CR4 ZZ0005ZZ
   > CR3 ZZ0006ZZ
   < ___|
   > N ZZ0007ZZ 8
   < o ZZ0008ZZ 7
   > d ZZ0009ZZ 6
   < e ZZ0010ZZ 5
   > MỘT ZZ0011ZZ 4
   < d ZZ0012ZZ 3
   > d ZZ0013ZZ 2
   < r ZZ0014ZZ 1
   > ZZ0015ZZ _____|
   < ZZ0016ZZ ZZ0017ZZ
   > 3 1 JP6 ZZ0018ZZ
   < |o|o| JP2                                                    | J2 |
   > |o|o|                                                        |_____|
   < 4 2__ ______________|
   > ZZ0023ZZ |
   <____ZZ0024ZZ_____________________________________________|

Huyền thoại::

SW1 1-6: Chọn địa chỉ cơ sở I/O
	7-10: Chọn ngắt
  SW2 1-6: Dự trữ để sử dụng trong tương lai
  SW3 1-8: Chọn ID nút
  JP2 1-4: Chọn thời gian chờ kéo dài
  JP6 đã chọn - Cấu trúc liên kết sao (chỉ PC500)
		Đã bỏ chọn - Cấu trúc liên kết xe buýt (chỉ PC500)
  CR3 Green Giám sát hoạt động mạng
  Hoạt động của bảng giám sát màu đỏ CR4
  Đầu nối J1 BNC RG62/U (chỉ PC500)
  Giắc cắm điện thoại 6 vị trí J1 (chỉ PC550)
  Giắc cắm điện thoại 6 vị trí J2 (chỉ PC550)

Đặt một trong các công tắc thành Tắt/Mở có nghĩa là "1", Bật/Đóng có nghĩa là "0".


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong nhóm SW3 được sử dụng để đặt ID nút. Mỗi nút
được gắn vào mạng phải có ID nút duy nhất phải được
khác với 0.
Công tắc 1 đóng vai trò là bit ít quan trọng nhất (LSB).

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là::

Chuyển đổi | Giá trị
    -------|-------
      1 |   1
      2 |   2
      3 |   4
      4 |   8
      5 |  16
      6 |  32
      7 |  64
      8 | 128

Một số ví dụ::

Chuyển đổi số thập phân ZZ0000ZZ
   8 7 6 5 4 3 2 1 ID nút ZZ0001ZZ
   -------ZZ0002ZZ----------
   0 0 0 0 0 0 0 0 |    không được phép
   0 0 0 0 0 0 0 1 ZZ0003ZZ 1
   0 0 0 0 0 0 1 0 ZZ0004ZZ 2
   0 0 0 0 0 0 1 1 ZZ0005ZZ 3
       . . .       ZZ0006ZZ
   0 1 0 1 0 1 0 1 ZZ0007ZZ 85
       . . .       ZZ0008ZZ
   1 0 1 0 1 0 1 0 ZZ0009ZZ 170
       . . .       ZZ0010ZZ
   1 1 1 1 1 1 0 1 ZZ0011ZZ 253
   1 1 1 1 1 1 1 0 ZZ0012ZZ 254
   1 1 1 1 1 1 1 1 ZZ0013ZZ 255


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sáu công tắc đầu tiên trong nhóm công tắc SW1 được sử dụng để chọn một công tắc
trong số 32 địa chỉ cơ sở I/O có thể sử dụng bảng sau::

Chuyển đổi | I/O lục giác
   6 5 4 3 2 1 | Địa chỉ
   -------------|-------
   0 1 0 0 0 0 |  200
   0 1 0 0 0 1 |  210
   0 1 0 0 1 0 |  220
   0 1 0 0 1 1 |  230
   0 1 0 1 0 0 |  240
   0 1 0 1 0 1 |  250
   0 1 0 1 1 0 |  260
   0 1 0 1 1 1 |  270
   0 1 1 0 0 0 |  280
   0 1 1 0 0 1 |  290
   0 1 1 0 1 0 |  2A0
   0 1 1 0 1 1 |  2B0
   0 1 1 1 0 0 |  2C0
   0 1 1 1 0 1 |  2D0
   0 1 1 1 1 0 |  2E0 (Mặc định của nhà sản xuất)
   0 1 1 1 1 1 |  2F0
   1 1 0 0 0 0 |  300
   1 1 0 0 0 1 |  310
   1 1 0 0 1 0 |  320
   1 1 0 0 1 1 |  330
   1 1 0 1 0 0 |  340
   1 1 0 1 0 1 |  350
   1 1 0 1 1 0 |  360
   1 1 0 1 1 1 |  370
   1 1 1 0 0 0 |  380
   1 1 1 0 0 1 |  390
   1 1 1 0 1 0 |  3A0
   1 1 1 0 1 1 |  3B0
   1 1 1 1 0 0 |  3C0
   1 1 1 1 0 1 |  3D0
   1 1 1 1 1 0 |  3E0
   1 1 1 1 1 1 |  3F0


Đặt ngắt
^^^^^^^^^^^^^^^^^^^^^

Công tắc bảy đến mười của nhóm chuyển mạch SW1 được sử dụng để chọn
mức độ gián đoạn. Mức ngắt được mã hóa nhị phân, do đó các lựa chọn
có thể từ 0 đến 15, nhưng chỉ có tám giá trị sau đây
được hỗ trợ: 3, 4, 5, 7, 9, 10, 11, 12.

::

Chuyển đổi | IRQ
   10 9 8 7 |
   ---------|-------
    0 0 1 1 |  3
    0 1 0 0 |  4
    0 1 0 1 |  5
    0 1 1 1 |  7
    1 0 0 1 |  9 (=2) (mặc định)
    1 0 1 0 | 10
    1 0 1 1 | 11
    1 1 0 0 | 12


Đặt thời gian chờ
^^^^^^^^^^^^^^^^^^^^

Hai jumper JP2 (1-4) được sử dụng để xác định các tham số thời gian chờ.
Hai jumper này thường được để mở.
Tham khảo Bảng dữ liệu COM9026 để biết các cấu hình thay thế.


Định cấu hình PC500 cho cấu trúc liên kết sao hoặc bus
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Jumper đơn có nhãn JP6 được sử dụng để cấu hình bo mạch PC500 cho
cấu trúc liên kết sao hoặc xe buýt.
Khi jumper được cài đặt, bo mạch có thể được sử dụng trong mạng sao, khi
nó được gỡ bỏ, bo mạch có thể được sử dụng trong cấu trúc liên kết xe buýt.


Đèn LED chẩn đoán
^^^^^^^^^^^^^^^

Hai đèn LED chẩn đoán có thể nhìn thấy ở giá đỡ phía sau của bo mạch.
LED màu xanh lá cây giám sát hoạt động mạng: màu đỏ hiển thị
hoạt động hội đồng::

Trạng thái ZZ0000ZZ màu xanh lá cây
 -------ZZ0001ZZ-------------------
  về truyền dữ liệu ZZ0002ZZ
  nhấp nháy ZZ0003ZZ không truyền dữ liệu;
  tắt ZZ0004ZZ bộ nhớ không chính xác hoặc
	Địa chỉ I/O ZZ0005ZZ


PC710 (thẻ 8 bit)
------------------

- từ J.S. van Oosten <jvoosten@compiler.tdcnet.nl>

Lưu ý: dữ liệu này được thu thập bằng cách thử nghiệm và xem xét thông tin của người khác
thẻ. Tuy nhiên, tôi chắc chắn rằng mình đã cài đặt đúng 99%.

Thẻ SMC710 giống với thẻ PC270 nhưng cơ bản hơn nhiều (tức là không
đèn LED, giắc cắm RJ11, v.v.) và 8 bit. Đây là một bức vẽ nhỏ::

_______________________________________
   ZZ0000ZZ____
   ZZ0001ZZ S2 ZZ0002ZZ S1 ZZ0003ZZ
   ZZ0004ZZ
   ZZ0005ZZ
   ZZ0006ZZ
   ZZ0007ZZ R ZZ0008ZZ | X-tal ###ZZ0034ZZ
   ZZ0009ZZ O ZZ0010ZZ__ZZ0011ZZ
   ZZ0012ZZ M ZZ0013ZZ|                        ###
   ZZ0039ZZ
   ZZ0015ZZ
   ZZ0016ZZ
   ZZ0017ZZ chip lớn ZZ0018ZZ
   ZZ0019ZZ 90C63 ZZ0020ZZ
   ZZ0021ZZ ZZ0022ZZ
   ZZ0023ZZ
    ------- ----------
	   |||||||||||||||||||||

Hàng jumper tại JP1 thực sự bao gồm 8 jumper, (đôi khi
được dán nhãn) giống như trên PC270, từ trên xuống dưới: EXT2, EXT1, ROM,
IRQ7, IRQ5, IRQ4, IRQ3, IRQ2 (gee, tự hỏi họ sẽ làm gì? :-) )

S1 và S2 thực hiện chức năng tương tự như trên PC270, chỉ có số của chúng
được hoán đổi (S1 là địa chỉ nút, S2 đặt địa chỉ IO- và RAM).

Tôi biết nó hoạt động khi được kết nối với bảng ARCnet loại PC110.


**********************************************************************************

Có thể là SMC
============

LCS-8830(-T) (thẻ 8 và 16 bit)
---------------------------------

- từ Mathias Katzer <mkatzer@HRZ.Uni-Bielefeld.DE>
  - Marek Michalkiewicz <marekm@i17linuxb.ists.pwr.wroc.pl> nói
    LCS-8830 hơi khác so với LCS-8830-T.  Đây là 8 bit, BUS
    chỉ (dục nối JP0 được nối dây cứng) và chỉ BNC.

Đây là chiếc LCS-8830-T do SMC sản xuất, tôi nghĩ ('SMC' chỉ xuất hiện trên một chiếc PLCC,
không nơi nào khác, thậm chí không có trên một vài tờ giấy được sao chép từ sách hướng dẫn).

SMC Loại bo mạch ARCnet LCS-8830-T::

-----------------------------------
    ZZ0000ZZ
    ZZ0001ZZ
    ZZ0002ZZ \ |
    ZZ0003ZZ
    ZZ0004ZZ
    Giắc cắm điện thoại ZZ0005ZZ
    ZZ0006ZZ
    ZZ0007ZZ ZZ0008ZZ
    ZZ0009ZZ ZZ0010ZZ
    ZZ0011ZZ ZZ0012ZZ
    ZZ0013ZZ ZZ0014ZZ
    |  -- ##### ####  ZZ0032ZZ Đầu nối
    |                                   ####
    ZZ0033ZZ
    ZZ0016ZZ
     ---------
       |||||||||||||||||||||||||||
	-----------------


SW1: DIP-Switch cho địa chỉ trạm
  SW2: DIP-Switches cho các địa chỉ cơ sở bộ nhớ và cơ sở I/O

JP0: Nếu đóng, chấm dứt nội bộ bật (mở mặc định)
  JP1: Máy nhảy IRQ
  JP2: Bật Boot-ROM nếu đóng
  JP3: Jumper cho thời gian chờ phản hồi

U3: Ổ cắm Boot-ROM


ET1 ET2 Thời gian phản hồi Thời gian nhàn rỗi Thời gian cấu hình lại

78 86 840
   X 285 316 1680
       X 563 624 1680
   X X 1130 1237 1680

(X có nghĩa là jumper đóng)

(DIP-Chuyển xuống có nghĩa là "0")

Địa chỉ trạm được mã hóa nhị phân bằng SW1.

Địa chỉ cơ sở I/O được mã hóa bằng DIP-Switches 6,7 và 8 của SW2:

=================
Đế công tắc
Địa chỉ 678
=================
000 260-26f
100 290-29f
010 2e0-2ef
110 2f0-2ff
001 300-30f
101 350-35f
011 380-38f
111 3e0-3ef
=================


DIP Chuyển 1-5 của SW2 mã hóa Dải địa chỉ RAM và ROM:

====================== ==================
Công tắc RAM ROM
12345 Phạm vi địa chỉ Phạm vi địa chỉ
====================== ==================
00000 C:0000-C:07ff C:2000-C:3fff
10000 C:0800-C:0fff
01000 C:1000-C:17ff
11000 C:1800-C:1fff
00100 C:4000-C:47ff C:6000-C:7fff
10100 C:4800-C:4fff
01100 C:5000-C:57ff
11100 C:5800-C:5fff
00010 C:C000-C:C7ff C:E000-C:ffff
10010 C:C800-C:Cfff
01010 C:D000-C:D7ff
11010 C:D800-C:Dfff
00110 D:0000-D:07ff D:2000-D:3fff
10110 D:0800-D:0fff
01110 D:1000-D:17ff
11110 D:1800-D:1fff
00001 D:4000-D:47ff D:6000-D:7fff
10001 D:4800-D:4fff
01001 D:5000-D:57ff
11001 D:5800-D:5fff
00101 D:8000-D:87ff D:A000-D:bfff
10101 D:8800-D:8fff
01101 D:9000-D:97ff
11101 D:9800-D:9fff
00011 D:C000-D:c7ff D:E000-D:ffff
10011 D:C800-D:cfff
01011 D:D000-D:d7ff
11011 D:D800-D:dfff
00111 E:0000-E:07ff E:2000-E:3fff
10111 E:0800-E:0fff
01111 E:1000-E:17ff
11111 E:1800-E:1fff
====================== ==================


Tập đoàn PureData
=============

PDI507 (thẻ 8 bit)
--------------------

- từ Mark Rejhon <mdrejhon@magi.com> (sửa đổi một chút bởi Avery)
  - Lưu ý của Avery: Tôi nghĩ là thẻ PDI508 (nhưng chắc chắn là thẻ NOT PDI508Plus)
    hầu hết đều giống như thế này.  Thẻ PDI508Plus dường như chủ yếu
    được cấu hình bằng phần mềm.

Người nhảy:

Có dãy jumper ở dưới đáy thẻ, gần mép
	đầu nối.  Mảng này được dán nhãn J1.  Họ kiểm soát IRQ và
	một cái gì đó khác.  Chỉ đặt một jumper trên các chân IRQ.

ETS1, ETS2 dành cho việc định thời gian trên các mạng có khoảng cách rất xa.  Xem
	thông tin tổng quát hơn ở gần đầu tập tin này.

Có một jumper J2 trên hai chân.  Nên mặc áo liền quần cho họ,
	vì nó đã ở đó khi tôi nhận được thẻ.  Tôi không biết cái gì
	mặc dù vậy, chiếc áo liền quần này là dành cho.

Có một mảng hai bước nhảy cho J3.  Tôi không biết nó dùng để làm gì,
	nhưng đã có hai cái jumper trên đó khi tôi nhận được thẻ.  Đó là
	một lưới sáu chân theo kiểu hai nhân ba.  Những người nhảy cầu đã
	được cấu hình như sau::

-------.
	 o ZZ0000ZZ
	   :-------: ------> Đầu thẻ có thể truy cập được bằng các đầu nối
	 o ZZ0001ZZ theo hướng này ------->
	   `-------'

Carl de Billy <CARL@carainfo.com> giải thích về J3 và J4:

Sơ đồ J3::

-------.
	 o ZZ0001ZZ
	   :-------: Công nghệ TWIST
	 o ZZ0002ZZ
	   ZZ0000ZZ-------'

- Nếu sử dụng cáp đồng trục trong cấu trúc liên kết bus thì phải loại bỏ jumper J4;
    đặt nó trên một pin.

- Nếu sử dụng cấu trúc liên kết bus với dây xoắn đôi, hãy di chuyển J3
    jumper để chúng kết nối chân giữa và các chân gần nhất với RJ11
    Đầu nối.  Ngoài ra, jumper J4 cũng phải được loại bỏ; đặt nó trên một chốt của
    Jumper J4 để lưu trữ.

- Nếu sử dụng cấu trúc liên kết hình sao với dây xoắn đôi, hãy di chuyển J3
    jumper để chúng kết nối chân giữa và các chân gần nhất với RJ11
    đầu nối.


Công tắc DIP:

Công tắc DIP có thể truy cập được ở đầu thẻ có thể truy cập được trong khi
	nó đã được cài đặt, được sử dụng để đặt địa chỉ ARCnet.  Có 8
	công tắc.  Sử dụng địa chỉ từ 1 đến 254

======================================
	Số chuyển đổi Địa chỉ ARCnet
	12345678
	======================================
	00000000 FF (Đừng sử dụng cái này!)
	00000001 FE
	00000010 FD
	...
11111101 2
	11111110 1
	11111111 0 (Đừng sử dụng cái này!)
	======================================

Có một dãy tám công tắc DIP khác ở đầu
	thẻ.  Có năm nhãn MS0-MS4 dường như kiểm soát
	địa chỉ bộ nhớ và ba địa chỉ khác có nhãn IO0-IO2 dường như
	kiểm soát địa chỉ I/O cơ sở của thẻ.

Điều này khó kiểm tra bằng cách thử và sai và địa chỉ I/O
	đang theo một trật tự kỳ lạ.  Điều này đã được kiểm tra bằng cách cài đặt các công tắc DIP,
	khởi động lại máy tính và thử tải ARCETHER ở nhiều chế độ khác nhau
	địa chỉ (chủ yếu là từ 0x200 đến 0x400).  Địa chỉ gây ra
	LED truyền màu đỏ để nhấp nháy, là cái mà tôi nghĩ là có tác dụng.

Ngoài ra, địa chỉ 0x3D0 dường như có một ý nghĩa đặc biệt, vì
	Trình điều khiển gói ARCETHER được tải tốt nhưng không có LED màu đỏ
	nhấp nháy.  Tôi không biết 0x3D0 dùng để làm gì.  Tôi khuyên bạn nên sử dụng
	địa chỉ 0x300 vì Windows có thể không thích các địa chỉ bên dưới
	0x300.

============== ============
	Số công tắc IO. Địa chỉ I/O
	210
	============== ============
	111 0x260
	110 0x290
	101 0x2E0
	100 0x2F0
	011 0x300
	010 0x350
	001 0x380
	000 0x3E0
	============== ============

Các công tắc bộ nhớ đặt không gian địa chỉ dành riêng là 0x1000 byte
	(Đơn vị phân đoạn 0x100 hoặc 4k).  Ví dụ: nếu tôi đặt địa chỉ của
	0xD000, nó sẽ sử dụng hết địa chỉ 0xD000 đến 0xD100.

Các công tắc bộ nhớ đã được kiểm tra bằng cách khởi động bằng tính năng ẩn QEMM386,
	và sử dụng LOADHI để xem địa chỉ nào tự động bị loại trừ
	từ các vùng bộ nhớ phía trên và sau đó thử tải ARCETHER
	sử dụng các địa chỉ này.

Tôi khuyên bạn nên sử dụng địa chỉ bộ nhớ ARCnet là 0xD000 và đặt
	khung trang EMS ở 0xC000 trong khi sử dụng chế độ ẩn QEMM.  Đó
	Nhân tiện, bạn sẽ có được bộ nhớ cao liên tục từ 0xD100 gần như suốt chặng đường
	sự kết thúc của megabyte.

Memory Switch 0 (MS0) dường như không hoạt động bình thường khi được đặt thành OFF
	trên thẻ của tôi.  Nó có thể bị trục trặc trên thẻ của tôi.  Thử nghiệm với
	trước tiên nó BẬT và nếu nó không hoạt động, hãy đặt nó thành OFF.  (Nó có thể là một
	công cụ sửa đổi cho bit 0x200?)

==============================================================
	Số công tắc MS
	43210 Địa chỉ bộ nhớ
	==============================================================
	00001 0xE100 (đoán - không được QEMM phát hiện)
	00011 0xE000 (đoán - không được QEMM phát hiện)
	00101 0xDD00
	00111 0xDC00
	01001 0xD900
	01011 0xD800
	01101 0xD500
	01111 0xD400
	10001 0xD100
	10011 0xD000
	10101 0xCD00
	10111 0xCC00
	11001 0xC900 (đoán - hệ thống đã thử nghiệm sự cố)
	11011 0xC800 (đoán - hệ thống đã thử nghiệm sự cố)
	11101 0xC500 (đoán - hệ thống đã thử nghiệm sự cố)
	11111 0xC400 (đoán - hệ thống đã thử nghiệm sự cố)
	==============================================================

CNet Technology Inc. (thẻ 8 bit)
==================================

Dòng 120 (thẻ 8 bit)
------------------------
- từ Juergen Seifert <seifert@htwm.de>

Mô tả này được viết bởi Juergen Seifert <seifert@htwm.de>
sử dụng thông tin từ Hướng dẫn sử dụng CNet gốc sau đây

"ARCNET USER'S MANUAL dành cho
	      CN120A
	      CN120AB
	      CN120TP
	      CN120ST
	      CN120SBT
	      P/N:12-01-0007
	      Bản sửa đổi 3.00"

ARCNET là nhãn hiệu đã đăng ký của Tập đoàn Datapoint

- P/N 120A ARCNET 8 bit XT/AT Sao
- P/N 120AB ARCNET 8 bit XT/AT Bus
- Cặp xoắn P/N 120TP ARCNET 8 bit XT/AT
- P/N 120ST ARCNET 8 bit XT/AT Star, Cặp xoắn
- P/N 120SBT ARCNET 8 bit XT/AT Star, Bus, Twisted Pair

::

__________________________________________________________________
   ZZ0000ZZ
   ZZ0001ZZ
   ZZ0002ZZ___|
   ZZ0003ZZ
   ZZ0004ZZ | ID7
   ZZ0005ZZ | ID6
   ZZ0006ZZ S | ID5
   ZZ0007ZZ W | ID4
   ZZ0008ZZ 2 | ID3
   ZZ0009ZZ ZZ0010ZZ | ID2
   ZZ0011ZZ ZZ0012ZZ | ID1
   ZZ0013ZZ ZZ0014ZZ___| ID0
   ZZ0015ZZ 90C65 |ZZ0016ZZ ____|
   ZZ0017ZZ |ZZ0018ZZ ZZ0019ZZ
   |    |o|o| JP1 ZZ0022ZZ ZZ0023ZZ
   |    |o|o| ZZ0026ZZ ZZ0027ZZ JP 1 1 1 ZZ0028ZZ
   ZZ0029ZZ ZZ0030ZZ____|
   ZZ0031ZZ PROM |  |__________________|           |o|o|o|  _____|
   ZZ0036ZZ JP 6 5 4 3 2 |o|o|o| ZZ0039ZZ
   |  |______________|    |o|o|o|o|o|                   |o|o|o| |_____|
   |_____                 |o|o|o|o|o|                   ______________|
	 ZZ0051ZZ
	 ZZ0052ZZ

Huyền thoại::

Đầu dò 90C65 ARCNET
  S1 1-5: Chọn địa chỉ bộ nhớ cơ sở
      6-8: Chọn địa chỉ I/O cơ sở
  S2 1-8: Chọn ID nút (ID0-ID7)
  JP1 ROM Bật Chọn
  JP2 IRQ2
  JP3 IRQ3
  JP4 IRQ4
  JP5 IRQ5
  JP6 IRQ7
  Thông số thời gian chờ JP7/JP8 ET1, ET2
  Chọn cặp đồng trục / xoắn JP10/JP11 (chỉ CN120ST/SBT)
  Chọn Kẻ hủy diệt JP12 (chỉ CN120AB/ST/SBT)
  Đầu nối J1 BNC RG62/U (tất cả ngoại trừ CN120TP)
  J2 Hai giắc cắm điện thoại 6 vị trí (chỉ CN120TP/ST/SBT)

Đặt một trong các công tắc thành Tắt có nghĩa là "1", Bật có nghĩa là "0".


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong SW2 được sử dụng để đặt ID nút. Mỗi nút đính kèm
vào mạng phải có ID nút duy nhất phải khác 0.
Công tắc 1 (ID0) đóng vai trò là bit ít quan trọng nhất (LSB).

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là:

======= ====== =====
   Chuyển đổi giá trị nhãn
   ======= ====== =====
     1 ID0 1
     2 ID1 2
     3 ID2 4
     4 ID3 8
     5 ID4 16
     6 ID5 32
     7 ID6 64
     8 ID7 128
   ======= ====== =====

Một số ví dụ::

Chuyển đổi số thập phân ZZ0000ZZ
   8 7 6 5 4 3 2 1 ID nút ZZ0001ZZ
   -------ZZ0002ZZ----------
   0 0 0 0 0 0 0 0 |    không được phép
   0 0 0 0 0 0 0 1 ZZ0003ZZ 1
   0 0 0 0 0 0 1 0 ZZ0004ZZ 2
   0 0 0 0 0 0 1 1 ZZ0005ZZ 3
       . . .       ZZ0006ZZ
   0 1 0 1 0 1 0 1 ZZ0007ZZ 85
       . . .       ZZ0008ZZ
   1 0 1 0 1 0 1 0 ZZ0009ZZ 170
       . . .       ZZ0010ZZ
   1 1 1 1 1 1 0 1 ZZ0011ZZ 253
   1 1 1 1 1 1 1 0 ZZ0012ZZ 254
   1 1 1 1 1 1 1 1 ZZ0013ZZ 255


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ba công tắc cuối cùng trong khối chuyển mạch SW1 được sử dụng để chọn một công tắc
trong số tám địa chỉ Cơ sở I/O có thể sử dụng bảng sau::


Chuyển đổi | I/O lục giác
    6 7 8 | Địa chỉ
   ------------|-------
   TRÊN TRÊN TRÊN |  260
   OFF BẬT |  290
   TRÊN OFF TRÊN |  2E0 (Mặc định của nhà sản xuất)
   OFF OFF BẬT |  2F0
   BẬT TRÊN OFF |  300
   OFF TRÊN OFF |  350
   TRÊN OFF OFF |  380
   OFF OFF OFF |  3E0


Đặt địa chỉ bộ đệm Bộ nhớ cơ sở (RAM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhớ đệm (RAM) yêu cầu 2K. Cơ sở của bộ đệm này có thể là
nằm ở bất kỳ vị trí nào trong tám vị trí. Địa chỉ của Boot Prom là
cơ sở bộ nhớ + 8K hoặc cơ sở bộ nhớ + 0x2000.
Công tắc 1-5 của khối chuyển mạch SW1 chọn địa chỉ Cơ sở bộ nhớ.

::

Chuyển đổi ZZ0000ZZ Hex ROM
    1 2 3 4 5 ZZ0001ZZ Địa chỉ *)
   --------------------ZZ0002ZZ----------
   BẬT BẬT BẬT TRÊN ZZ0003ZZ C2000
   BẬT TRÊN OFF BẬT TRÊN ZZ0004ZZ C6000
   BẬT TRÊN OFF TRÊN ZZ0005ZZ CE000
   BẬT TRÊN OFF OFF TRÊN ZZ0006ZZ D2000 (Mặc định của Nhà sản xuất)
   BẬT BẬT BẬT TRÊN OFF ZZ0007ZZ D6000
   BẬT TRÊN OFF TRÊN OFF ZZ0008ZZ DA000
   BẬT TRÊN OFF OFF ZZ0009ZZ DE000
   BẬT TRÊN OFF OFF OFF ZZ0010ZZ E2000

*) Để kích hoạt Boot ROM, hãy cài đặt jumper JP1

.. note::

      Since the switches 1 and 2 are always set to ON it may be possible
      that they can be used to add an offset of 2K, 4K or 6K to the base
      address, but this feature is not documented in the manual and I
      haven't tested it yet.


Đặt đường ngắt
^^^^^^^^^^^^^^^^^^^^^^^^^^

Để chọn mức ngắt phần cứng, hãy cài đặt một (chỉ một!) jumper
JP2, JP3, JP4, JP5, JP6. JP2 là mặc định::

Nhảy | IRQ
   -------|------
     2 |  2
     3 |  3
     4 |  4
     5 |  5
     6 |  7


Đặt Bộ kết thúc bên trong trên CN120AB/TP/SBT
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Jumper JP12 được sử dụng để kích hoạt bộ kết thúc bên trong::

-----
       0 ZZ0000ZZ
     ----- TRÊN ZZ0001ZZ TRÊN
    ZZ0002ZZ ZZ0003ZZ
    ZZ0004ZZ OFF ----- OFF
    ZZ0005ZZ 0
     -----
   Kẻ hủy diệt Kẻ hủy diệt
    đã tắt đã bật


Chọn loại trình kết nối trên CN120ST/SBT
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

JP10 JP11 JP10 JP11
			 ----- -----
       0 0 ZZ0000ZZ ZZ0001ZZ
     ----- ----- ZZ0002ZZ ZZ0003ZZ
    ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
    ZZ0008ZZ ZZ0009ZZ ----- -----
    ZZ0010ZZ ZZ0011ZZ 0 0
     ----- -----
     Cáp đồng trục Cáp xoắn đôi
       (Mặc định)


Đặt tham số thời gian chờ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các jumper có nhãn EXT1 và EXT2 được sử dụng để xác định thời gian chờ
các thông số. Hai jumper này thường được để mở.


CNet Technology Inc. (thẻ 16-bit)
===================================

Dòng 160 (thẻ 16-bit)
-------------------------
- từ Juergen Seifert <seifert@htwm.de>

Mô tả này được viết bởi Juergen Seifert <seifert@htwm.de>
sử dụng thông tin từ Hướng dẫn sử dụng CNet gốc sau đây

"ARCNET USER'S MANUAL dành cho
	      CN160A CN160AB CN160TP
	      P/N:12-01-0006 Phiên bản 3.00"

ARCNET là nhãn hiệu đã đăng ký của Tập đoàn Datapoint

- P/N 160A ARCNET 16 bit XT/AT Sao
- P/N 160AB ARCNET 16 bit XT/AT Bus
- Cặp xoắn P/N 160TP ARCNET 16 bit XT/AT

::

___________________________________________________________________
  < _________________________ ___|
  > ZZ0000ZZ JP2 ZZ0001ZZ LED ZZ0002ZZ
  < ZZ0003ZZ JP1 ZZ0004ZZ LED ZZ0005ZZ
  > ZZ0006ZZ ___|
  < N ZZ0007ZZ ID7
  > 1 o ZZ0008ZZ ID6
  < 1 2 3 4 5 6 7 8 9 0 d ZZ0009ZZ ID5
  > _______________ _____________________ và ZZ0010ZZ ID4
  < ZZ0011ZZ ZZ0012ZZ A ZZ0013ZZ ID3
  > > SOCKET ZZ0014ZZ_____________________ZZ0015ZZ | ID2
  < ZZ0016ZZ ZZ0017ZZ MEM ZZ0018ZZ | ID1
  > r ZZ0019ZZ ID0
  < ____|
  > ZZ0020ZZ
  < ZZ0021ZZ
  > ZZ0022ZZ
  < ZZ0023ZZ
  > 1 1 1 1 |
  < 3 4 5 6 7 JP 8 9 0 1 2 3 |
  > |o|o|o|o|o| |o|o|o|o|o|o|                               |
  < |o|o|o|o|o| __ |o|o|o|o|o|o|                    ___________|
  > ZZ0038ZZ |
  <____________ZZ0039ZZ_______________________________________|

Huyền thoại::

Đầu dò 9026 ARCNET
  SW1 1-6: Chọn địa chỉ I/O cơ sở
      7-10: Chọn địa chỉ bộ nhớ cơ sở
  SW2 1-8: Chọn ID nút (ID0-ID7)
  Thông số thời gian chờ JP1/JP2 ET1, ET2
  Chọn ngắt JP3-JP13
  Đầu nối J1 BNC RG62/U (chỉ CN160A/AB)
  J1 Hai giắc cắm điện thoại 6 vị trí (chỉ CN160TP)
  LED

Đặt một trong các công tắc thành Tắt có nghĩa là "1", Bật có nghĩa là "0".


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong SW2 được sử dụng để đặt ID nút. Mỗi nút đính kèm
vào mạng phải có ID nút duy nhất phải khác 0.
Công tắc 1 (ID0) đóng vai trò là bit ít quan trọng nhất (LSB).

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là::

Chuyển đổi giá trị ZZ0000ZZ
   -------ZZ0001ZZ-------
     1 ZZ0002ZZ 1
     2 ZZ0003ZZ 2
     3 ZZ0004ZZ 4
     4 ZZ0005ZZ 8
     5 ZZ0006ZZ 16
     6 ZZ0007ZZ 32
     7 ZZ0008ZZ 64
     8 ZZ0009ZZ 128

Một số ví dụ::

Chuyển đổi số thập phân ZZ0000ZZ
   8 7 6 5 4 3 2 1 ID nút ZZ0001ZZ
   -------ZZ0002ZZ----------
   0 0 0 0 0 0 0 0 |    không được phép
   0 0 0 0 0 0 0 1 ZZ0003ZZ 1
   0 0 0 0 0 0 1 0 ZZ0004ZZ 2
   0 0 0 0 0 0 1 1 ZZ0005ZZ 3
       . . .       ZZ0006ZZ
   0 1 0 1 0 1 0 1 ZZ0007ZZ 85
       . . .       ZZ0008ZZ
   1 0 1 0 1 0 1 0 ZZ0009ZZ 170
       . . .       ZZ0010ZZ
   1 1 1 1 1 1 0 1 ZZ0011ZZ 253
   1 1 1 1 1 1 1 0 ZZ0012ZZ 254
   1 1 1 1 1 1 1 1 ZZ0013ZZ 255


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sáu công tắc đầu tiên trong khối chuyển mạch SW1 được sử dụng để chọn Cơ sở I/O
địa chỉ sử dụng bảng sau::

Chuyển đổi | I/O lục giác
    1 2 3 4 5 6 | Địa chỉ
   ---------------|-------
   OFF BẬT TRÊN OFF OFF BẬT |  260
   OFF TRÊN OFF TRÊN OFF |  290
   OFF TRÊN OFF OFF OFF TRÊN |  2E0 (Mặc định của nhà sản xuất)
   OFF TRÊN OFF OFF OFF OFF |  2F0
   OFF OFF BẬT TRÊN TRÊN TRÊN |  300
   OFF OFF TRÊN OFF TRÊN OFF |  350
   OFF OFF OFF BẬT BẬT |  380
   OFF OFF OFF OFF OFF BẬT |  3E0

Lưu ý: Các địa chỉ IO-Base khác dường như có thể được chọn, nhưng chỉ các địa chỉ trên
      sự kết hợp được ghi lại.


Đặt địa chỉ bộ đệm Bộ nhớ cơ sở (RAM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các công tắc 7-10 của khối chuyển mạch SW1 được sử dụng để chọn Bộ nhớ
Địa chỉ cơ sở của RAM (2K) và PROM::

Chuyển đổi ZZ0000ZZ Hex ROM
    7 8 9 10 ZZ0001ZZ Địa chỉ
   -------ZZ0002ZZ----------
   OFF OFF BẬT TRÊN ZZ0003ZZ C8000
   OFF OFF TRÊN OFF ZZ0004ZZ D8000 (Mặc định)
   OFF OFF OFF TRÊN ZZ0005ZZ E8000

.. note::

      Other MEM-Base addresses seem to be selectable, but only the above
      combinations are documented.


Đặt đường ngắt
^^^^^^^^^^^^^^^^^^^^^^^^^^

Để chọn mức ngắt phần cứng, hãy cài đặt một (chỉ một!) jumper
JP3 đến JP13 sử dụng bảng sau::

Nhảy | IRQ
   -------|--------
     3 |  14
     4 |  15
     5 |  12
     6 |  11
     7 |  10
     8 |   3
     9 |   4
    10 |   5
    11 |   6
    12 |   7
    13 |   2 (=9) Mặc định!

.. note::

       - Do not use JP11=IRQ6, it may conflict with your Floppy Disk
	 Controller
       - Use JP3=IRQ14 only, if you don't have an IDE-, MFM-, or RLL-
	 Hard Disk, it may conflict with their controllers


Đặt tham số thời gian chờ
------------------------------

Các jumper có nhãn JP1 và JP2 được sử dụng để xác định thời gian chờ
các thông số. Hai jumper này thường được để mở.


Lantech
=======

Thẻ 8 bit, mẫu không xác định
-------------------------
- từ Vlad Lungu <vlungu@ugal.ro> - địa chỉ email của anh ấy dường như bị hỏng tại
    lần tôi cố gắng tiếp cận anh ấy.  Xin lỗi Vlad, nếu bạn không nhận được câu trả lời của tôi.

::

________________________________________________________________
   ZZ0000ZZ
   ZZ0001ZZ
   ZZ0002ZZ SW1 ZZ0003ZZ__|
   ZZ0004ZZ__________ZZ0005ZZ
   ZZ0006ZZ
   ZZ0007ZZS | 8
   ZZ0008ZZ ZZ0009ZZW |
   ZZ0010ZZ ZZ0011ZZ2 |
   ZZ0012ZZ ZZ0013ZZ__| 1
   ZZ0014ZZ UM9065L |     |o|  JP4         ____|____
   ZZ0017ZZ |     |o|              | CN |
   ZZ0020ZZ ZZ0021ZZ________|
   ZZ0022ZZ ZZ0023ZZ
   ZZ0024ZZ___________________ZZ0025ZZ
   ZZ0026ZZ
   ZZ0027ZZ
   ZZ0028ZZ
   ZZ0029ZZ ZZ0030ZZ
   ZZ0031ZZ PROM |        |ooooo|  JP6                       |
   |      |____________|        |ooooo|                            |
   ZZ0037ZZ
		ZZ0038ZZ ZZ0039ZZ


UM9065L : Bộ điều khiển ARCnet

SW 1 : Địa chỉ bộ nhớ dùng chung và cơ sở I/O

::

BẬT=0

12345|Địa chỉ bộ nhớ
	-----|--------------
	00001|  D4000
	00010|  CC000
	00110|  D0000
	01110|  D1000
	01101|  D9000
	10010|  CC800
	10011|  DC800
	11110|  D1800

Có vẻ như các bit được xem xét theo thứ tự ngược lại.  Ngoài ra, bạn phải
nhận thấy rằng một số địa chỉ đó là bất thường và tôi đã không thăm dò chúng; tôi
đã sử dụng kết xuất bộ nhớ trong DOS để xác định chúng.  Đối với cấu hình 00000 và
một số khác mà tôi không viết ở đây thẻ dường như mâu thuẫn với
card màn hình (S3 GENDAC). Tôi để lại việc giải mã đầy đủ các địa chỉ đó cho
bạn.

::

678| Địa chỉ vào/ra
	---|-------------
	000|    260
	001|    thăm dò thất bại
	010|    2E0
	011|    380
	100|    290
	101|    350
	110|    thăm dò thất bại
	111|    3E0

SW 2 : ID nút (mã nhị phân)

JP 4 : Khởi động PROM bật CLOSE - đã bật
			     OPEN - bị vô hiệu hóa

JP 6 : Bộ IRQ (Bộ nhảy ONLY ONE trên 1-5 cho IRQ 2-6)


Acer
====

Thẻ 8 bit, Model 5210-003
--------------------------

- từ Vojtech Pavlik <vojtech@suse.cz> sử dụng các phần của hệ thống hiện có
    tập tin phần cứng arcnet.

Đây là thẻ dựa trên 90C26.  Cấu hình của nó có vẻ giống SMC
PC100, nhưng có một số jumper bổ sung mà tôi không biết ý nghĩa của nó.

::

__
	      ZZ0000ZZ
   ___________ZZ0001ZZ_________________________
  ZZ0002ZZ ZZ0003ZZ
  ZZ0004ZZ BNC ZZ0005ZZ
  ZZ0006ZZ______ZZ0007ZZ
  ZZ0008ZZ___
  ZZ0009ZZ ZZ0010ZZ
  IC lai ZZ0011ZZ ZZ0012ZZ
  ZZ0013ZZ |       o|o J1 |
  ZZ0015ZZ_____________________ZZ0016ZZ8 |
  ZZ0017ZZ8 J5 |
  |                               o|o |
  ZZ0019ZZ8 |
  ZZ0020ZZ8 |
 (ZZ0021ZZ LED o|o      |
  ZZ0023ZZ8 |
  ZZ0024ZZ8 J15 |
  ZZ0025ZZ
  ZZ0026ZZ
  ZZ0027ZZ ZZ0028ZZ
  ZZ0029ZZ ZZ0030ZZ ZZ0031ZZ
  ZZ0032ZZ ZZ0033ZZ ZZ0034ZZ
  ZZ0035ZZ ROM ZZ0036ZZ UFS ZZ0037ZZ
  ZZ0038ZZ ZZ0039ZZ ZZ0040ZZ ZZ0041ZZ
  ZZ0042ZZ ZZ0043ZZ ZZ0044ZZ ZZ0045ZZ
  ZZ0046ZZ ZZ0047ZZ ZZ0048ZZ__.__ZZ0049ZZ__.__ZZ0050ZZ
  ZZ0051ZZ NCR ZZ0052ZZXTLZZ0053ZZ
  ZZ0054ZZ ZZ0055ZZ___ZZ0056ZZ ZZ0057ZZ ZZ0058ZZ
  ZZ0059ZZ90C26ZZ0060ZZ ZZ0061ZZ ZZ0062ZZ
  ZZ0063ZZ ZZ0064ZZ RAM ZZ0065ZZ UFS ZZ0066ZZ
  ZZ0067ZZ | J17 o|o ZZ0069ZZ ZZ0070ZZ |
  ZZ0071ZZ | J16 o|o ZZ0073ZZ ZZ0074ZZ |
  ZZ0075ZZ__.__ZZ0076ZZ__.__ZZ0077ZZ__.__ZZ0078ZZ
  ZZ0079ZZ
  ZZ0080ZZ ZZ0081ZZ
  ZZ0082ZZSW2ZZ0083ZZ
  ZZ0084ZZ ZZ0085ZZ
  ZZ0086ZZ___ZZ0087ZZ
  ZZ0088ZZ
  ZZ0089ZZ |10           J18 o|o |
  ZZ0091ZZ |                 o|o |
  | |SW1|                 o|o |
  ZZ0095ZZ |             J21 o|o |
  ZZ0097ZZ___ZZ0098ZZ
  ZZ0099ZZ
  ZZ0100ZZ


Huyền thoại::

Chip 90C26 ARCNET
  Tinh thể XTL 20 MHz
  Chọn địa chỉ I/O cơ sở SW1 1-6
      7-10 Chọn địa chỉ bộ nhớ
  Chọn ID nút SW2 1-8 (ID0-ID7)
  J1-J5 IRQ Chọn
  J6-J21 Không xác định (Có thể có thêm thời gian chờ & kích hoạt ROM ...)
  LED1 Hoạt động LED
  Đầu nối đồng trục BNC (STAR ARCnet)
  RAM 2k của SRAM
  Ổ cắm ROM Boot ROM
  Ổ cắm bay không xác định UFS


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong SW2 được sử dụng để đặt ID nút. Mỗi nút đính kèm
vào mạng phải có ID nút duy nhất không được bằng 0.
Công tắc 1 (ID0) đóng vai trò là bit ít quan trọng nhất (LSB).

Đặt một trong các công tắc thành OFF có nghĩa là "1", BẬT có nghĩa là "0".

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là::

Chuyển đổi | Giá trị
   -------|-------
     1 |   1
     2 |   2
     3 |   4
     4 |   8
     5 |  16
     6 |  32
     7 |  64
     8 | 128

Đừng đặt giá trị này thành 0 hoặc 255; những giá trị này được bảo lưu.


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các công tắc từ 1 đến 6 của khối chuyển mạch SW1 được sử dụng để chọn một
trong số 32 địa chỉ cơ sở I/O có thể sử dụng các bảng sau::

| lục giác
   Chuyển đổi | Giá trị
   -------|-------
     1 | 200
     2 | 100
     3 |  80
     4 |  40
     5 |  20
     6 |  10

Địa chỉ I/O là tổng của tất cả các switch được đặt thành "1". Hãy nhớ điều đó
không gian địa chỉ I/O dưới 0x200 là RESERVED cho bo mạch chính, vì vậy
công tắc 1 phải là ALWAYS SET TO OFF.


Đặt địa chỉ bộ đệm Bộ nhớ cơ sở (RAM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhớ đệm (RAM) yêu cầu 2K. Cơ sở của bộ đệm này có thể là
nằm ở bất kỳ vị trí nào trong số mười sáu vị trí. Tuy nhiên, những địa chỉ dưới đây
A0000 có thể gây treo hệ thống vì có RAM chính.

Jumper 7-10 của khối chuyển mạch SW1 chọn địa chỉ Cơ sở bộ nhớ::

Chuyển đổi | Lục giác RAM
    7 8 9 10 | Địa chỉ
   ----------------|--------
   OFF OFF OFF OFF |  F0000 (xung đột với BIOS chính)
   OFF OFF OFF TRÊN |  E0000
   OFF OFF TRÊN OFF |  D0000
   OFF OFF BẬT |  C0000 (xung đột với video BIOS)
   OFF TRÊN OFF OFF |  B0000 (xung đột với video đơn sắc)
   OFF TRÊN OFF TRÊN |  A0000 (xung đột với đồ họa)


Đặt đường ngắt
^^^^^^^^^^^^^^^^^^^^^^^^^^

Jumper 1-5 của khối jumper J1 kiểm soát mức IRQ. BẬT có nghĩa là
bị rút ngắn, OFF có nghĩa là mở::

Nhảy |  IRQ
    1 2 3 4 5 |
   ----------------------------
    TRÊN OFF OFF OFF OFF |  7
    OFF TRÊN OFF OFF OFF |  5
    OFF OFF TRÊN OFF OFF |  4
    OFF OFF OFF TRÊN OFF |  3
    OFF OFF OFF OFF TRÊN |  2


Bộ nhảy và ổ cắm không xác định
^^^^^^^^^^^^^^^^^^^^^^^^^

Tôi không biết gì về những điều này. Tôi chỉ đoán rằng J16&J17 đã hết thời gian chờ
jumper và có thể một trong những J18-J21 chọn ROM. Ngoài ra J6-J10 và
J11-J15 đang kết nối IRQ2-7 với một số chân trên UFS. tôi không thể
đoán mục đích.

Điểm dữ liệu?
==========

LAN-ARC-8, thẻ 8 bit
------------------------

- từ Vojtech Pavlik <vojtech@suse.cz>

Đây là một thẻ ARCnet dựa trên SMC 90C65 khác. Tôi không thể xác định được
nhà sản xuất, nhưng có thể là DataPoint, vì thẻ có
logo arcNet gốc ở góc trên bên phải của nó.

::

_______________________________________________________
	 ZZ0000ZZ
	 ZZ0001ZZ SW2 ZZ0002ZZ
	 ZZ0003ZZ_________ZZ0004ZZ
	 ZZ0005ZZ | 8
	 ZZ0006ZZ ZZ0007ZZ XTAL ZZ0008ZZ S |
	 ZZ0009ZZ ZZ0010ZZZZ0011ZZ ZZ0012ZZ
	 ZZ0013ZZ_____________ZZ0014ZZ H ZZ0015ZZ 3 |
	 ZZ0016ZZ_____ và ZZ0017ZZ___| 1
	 ZZ0018ZZ |     |b ZZ0020ZZ
	 ZZ0021ZZ_________ZZ0022ZZ |     |r ZZ0024ZZ
	 ZZ0025ZZ SMC |     |i ZZ0027ZZ
	 ZZ0028ZZ 90C65|     |d ZZ0030ZZ
	 ZZ0031ZZ ZZ0032ZZ ZZ0033ZZ
	 ZZ0034ZZ SW1 ZZ0035ZZ ZZ0036ZZI ZZ0037ZZ
	 ZZ0038ZZ_________ZZ0039ZZ_________ZZ0040ZZ _____|
	 ZZ0041ZZ ZZ0042ZZ |___
	 ZZ0043ZZ ZZ0044ZZ BNC ZZ0045ZZ
	 ZZ0046ZZ ZZ0047ZZ____________ZZ0048ZZ_____|
	 ZZ0049ZZ _____________ |
	 ZZ0050ZZ______________ZZ0051ZZ_____________ZZ0052ZZ
	 ZZ0053ZZ
	 ZZ0054ZZ
	 ZZ0055ZZ

Huyền thoại::

Chip 90C65 ARCNET
  SW1 1-5: Chọn địa chỉ bộ nhớ cơ sở
      6-8: Chọn địa chỉ I/O cơ sở
  SW2 1-8: Chọn ID nút
  SW3 1-5: IRQ Chọn
      6-7: Hết thời gian bù giờ
      8 : Kích hoạt ROM
  Đầu nối đồng trục BNC
  Pha lê XTAL 20 MHz


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong SW3 được sử dụng để đặt ID nút. Mỗi nút đính kèm
vào mạng phải có ID nút duy nhất không được bằng 0.
Công tắc 1 đóng vai trò là bit ít quan trọng nhất (LSB).

Đặt một trong các công tắc thành Tắt có nghĩa là "1", Bật có nghĩa là "0".

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là::

Chuyển đổi | Giá trị
   -------|-------
     1 |   1
     2 |   2
     3 |   4
     4 |   8
     5 |  16
     6 |  32
     7 |  64
     8 | 128


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ba công tắc cuối cùng trong khối chuyển mạch SW1 được sử dụng để chọn một công tắc
trong số tám địa chỉ Cơ sở I/O có thể sử dụng bảng sau::


Chuyển đổi | I/O lục giác
    6 7 8 | Địa chỉ
   ------------|-------
   TRÊN TRÊN TRÊN |  260
   OFF BẬT |  290
   TRÊN OFF TRÊN |  2E0 (Mặc định của nhà sản xuất)
   OFF OFF BẬT |  2F0
   BẬT TRÊN OFF |  300
   OFF TRÊN OFF |  350
   TRÊN OFF OFF |  380
   OFF OFF OFF |  3E0


Đặt địa chỉ bộ đệm Bộ nhớ cơ sở (RAM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhớ đệm (RAM) yêu cầu 2K. Cơ sở của bộ đệm này có thể là
nằm ở bất kỳ vị trí nào trong tám vị trí. Địa chỉ của Boot Prom là
cơ sở bộ nhớ + 0x2000.

Jumper 3-5 của khối chuyển mạch SW1 chọn địa chỉ Cơ sở bộ nhớ.

::

Chuyển đổi ZZ0000ZZ Hex ROM
    1 2 3 4 5 ZZ0001ZZ Địa chỉ *)
   --------------------ZZ0002ZZ----------
   BẬT BẬT BẬT TRÊN ZZ0003ZZ C2000
   BẬT TRÊN OFF BẬT TRÊN ZZ0004ZZ C6000
   BẬT TRÊN OFF TRÊN ZZ0005ZZ CE000
   BẬT TRÊN OFF OFF TRÊN ZZ0006ZZ D2000 (Mặc định của Nhà sản xuất)
   BẬT BẬT BẬT TRÊN OFF ZZ0007ZZ D6000
   BẬT TRÊN OFF TRÊN OFF ZZ0008ZZ DA000
   BẬT TRÊN OFF OFF ZZ0009ZZ DE000
   BẬT TRÊN OFF OFF OFF ZZ0010ZZ E2000

*) Để kích hoạt Boot ROM, đặt công tắc 8 của khối công tắc SW3 sang vị trí BẬT.

Các công tắc 1 và 2 có thể thêm 0x0800 và 0x1000 vào địa chỉ cơ sở RAM.


Đặt đường ngắt
^^^^^^^^^^^^^^^^^^^^^^^^^^

Công tắc 1-5 của khối công tắc SW3 điều khiển mức IRQ::

Nhảy |  IRQ
    1 2 3 4 5 |
   ----------------------------
    TRÊN OFF OFF OFF OFF |  3
    OFF TRÊN OFF OFF OFF |  4
    OFF OFF TRÊN OFF OFF |  5
    OFF OFF OFF TRÊN OFF |  7
    OFF OFF OFF OFF TRÊN |  2


Đặt tham số thời gian chờ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các công tắc 6-7 của khối chuyển mạch SW3 được sử dụng để xác định thời gian chờ
các thông số.  Hai công tắc này thường được để ở vị trí OFF.


Topware
=======

Thẻ 8-bit, TA-ARC/10
---------------------

- từ Vojtech Pavlik <vojtech@suse.cz>

Đây là một thẻ 90C65 khác rất giống. Hầu hết các công tắc và jumper
giống như trên các bản sao khác.

::

_____________________________________________________________________
  ZZ0000ZZ ZZ0001ZZ
  ZZ0002ZZSW2 NODE IDZZ0003ZZ ZZ0004ZZ XTAL ZZ0005ZZ
  IC lai ZZ0006ZZ___________ZZ0007ZZ ZZ0008ZZ______ZZ0009ZZ
  ZZ0010ZZ ZZ0011ZZ
  ZZ0012ZZSW1 MEM+I/OZZ0013ZZ_________________________ZZ0014ZZ__|)
  ZZ0015ZZ___________ZZ0016ZZ
  |                     J3 |o|o| TIMEOUT ______|
  |     ______________     |o|o| ZZ0021ZZ
  ZZ0022ZZ ZZ0023ZZ RJ |
  ZZ0024ZZ ZZ0025ZZ------|
  ZZ0026ZZ______________ZZ0027ZZ ZZ0028ZZ |
  |ZZ0029ZZ ZZ0030ZZ ZZ0031ZZ
  |ZZ0032ZZ ROM ENABLE ZZ0033ZZ _________ |
  ZZ0034ZZ 90C65 ZZ0035ZZ_________ZZ0036ZZ
  ZZ0037ZZ ZZ0038ZZ ZZ0039ZZ |___
  ZZ0040ZZ ZZ0041ZZ ZZ0042ZZ___|
  ZZ0043ZZ_____________ZZ0044ZZ ZZ0045ZZ_____|
  ZZ0046ZZ____________________ZZ0047ZZ
  ZZ0048ZZ
  |ZZ0049ZZ |o|o|o|o|o| ZZ0053ZZ |
  |________   J1|o|o|o|o|o|                               ______________|
	   ZZ0058ZZ
	   ZZ0059ZZ

Huyền thoại::

Chip 90C65 ARCNET
  Tinh thể XTAL 20 MHz
  Chọn địa chỉ bộ nhớ cơ sở SW1 1-5
      6-8 Chọn địa chỉ I/O cơ sở
  Chọn ID nút SW2 1-8 (ID0-ID7)
  J1 IRQ Chọn
  Kích hoạt J2 ROM
  Hết thời gian chờ thêm J3
  LED1 Hoạt động LED
  Đầu nối đồng trục BNC (BUS ARCnet)
  Đầu nối cặp xoắn RJ (chuỗi cúc)


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong SW2 được sử dụng để đặt ID nút. Mỗi nút gắn liền với
mạng phải có ID nút duy nhất không được bằng 0. Switch 1 (ID0)
đóng vai trò là bit có trọng số thấp nhất (LSB).

Đặt một trong các công tắc thành Tắt có nghĩa là "1", Bật có nghĩa là "0".

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là::

Chuyển đổi giá trị ZZ0000ZZ
   -------ZZ0001ZZ-------
     1 ZZ0002ZZ 1
     2 ZZ0003ZZ 2
     3 ZZ0004ZZ 4
     4 ZZ0005ZZ 8
     5 ZZ0006ZZ 16
     6 ZZ0007ZZ 32
     7 ZZ0008ZZ 64
     8 ZZ0009ZZ 128

Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ba công tắc cuối cùng trong khối chuyển mạch SW1 được sử dụng để chọn một công tắc
trong số tám địa chỉ Cơ sở I/O có thể sử dụng bảng sau::


Chuyển đổi | I/O lục giác
    6 7 8 | Địa chỉ
   ------------|-------
   TRÊN TRÊN TRÊN |  260 (Mặc định của nhà sản xuất)
   OFF BẬT |  290
   TRÊN OFF TRÊN |  2E0
   OFF OFF BẬT |  2F0
   BẬT TRÊN OFF |  300
   OFF TRÊN OFF |  350
   TRÊN OFF OFF |  380
   OFF OFF OFF |  3E0


Đặt địa chỉ bộ đệm Bộ nhớ cơ sở (RAM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhớ đệm (RAM) yêu cầu 2K. Cơ sở của bộ đệm này có thể là
nằm ở bất kỳ vị trí nào trong tám vị trí. Địa chỉ của Boot Prom là
cơ sở bộ nhớ + 0x2000.

Jumper 3-5 của khối chuyển mạch SW1 chọn địa chỉ Cơ sở bộ nhớ.

::

Chuyển đổi ZZ0000ZZ Hex ROM
    1 2 3 4 5 ZZ0001ZZ Địa chỉ *)
   --------------------ZZ0002ZZ----------
   BẬT BẬT BẬT TRÊN ZZ0003ZZ C2000
   BẬT TRÊN OFF BẬT TRÊN ZZ0004ZZ C6000 (Mặc định của Nhà sản xuất)
   BẬT TRÊN OFF TRÊN ZZ0005ZZ CE000
   BẬT TRÊN OFF OFF TRÊN ZZ0006ZZ D2000
   BẬT BẬT BẬT TRÊN OFF ZZ0007ZZ D6000
   BẬT TRÊN OFF TRÊN OFF ZZ0008ZZ DA000
   BẬT TRÊN OFF OFF ZZ0009ZZ DE000
   BẬT TRÊN OFF OFF OFF ZZ0010ZZ E2000

*) Để kích hoạt Boot ROM hãy rút ngắn jumper J2.

Bộ nhảy 1 và 2 có thể thêm 0x0800 và 0x1000 vào địa chỉ RAM.


Đặt đường ngắt
^^^^^^^^^^^^^^^^^^^^^^^^^^

Jumper 1-5 của khối jumper J1 kiểm soát mức IRQ.  BẬT có nghĩa là
bị rút ngắn, OFF có nghĩa là mở::

Nhảy |  IRQ
    1 2 3 4 5 |
   ----------------------------
    TRÊN OFF OFF OFF OFF |  2
    OFF TRÊN OFF OFF OFF |  3
    OFF OFF TRÊN OFF OFF |  4
    OFF OFF OFF TRÊN OFF |  5
    OFF OFF OFF OFF TRÊN |  7


Đặt tham số thời gian chờ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Jumper J3 được sử dụng để thiết lập các tham số thời gian chờ. Hai cái này
jumper thường được để mở.

Thomas-Conrad
=============

Model #500-6242-0097 REV A (thẻ 8 bit)
---------------------------------------

- từ Lars Karlsson <100617.3473@compuserve.com>

::

________________________________________________________
   ZZ0000ZZ_____
   ZZ0001ZZ........ZZ0002ZZ........ZZ0003ZZ
   ZZ0004ZZ________ZZ0005ZZ________ZZ0006ZZ
   ZZ0007ZZ |
   ZZ0008ZZ |
   ZZ0009ZZ |
   ZZ0010ZZ |
   ZZ0011ZZ ZZ0012ZZ |
   ZZ0013ZZ ZZ0014ZZ___|
   ZZ0015ZZ ZZ0016ZZ___._
   ZZ0017ZZ______ZZ0018ZZ______ZZ0019ZZ BNC
   Đầu nối ZZ0020ZZ
   ZZ0021ZZ'
   Đầu nối RJ ZZ0022ZZ ZZ0023ZZ
   ZZ0024ZZ_ZZ0025ZZ với 110 Ohm
   Kẻ hủy diệt ZZ0026ZZ__
   ZZ0027ZZ
   ZZ0028ZZ..........ZZ0029ZZ Giắc cắm RJ
   ZZ0030ZZ..........ZZ0031ZZ (chưa sử dụng)
   ZZ0032ZZ___________ZZ0033ZZ_____ZZ0034ZZ__
   Chẩn đoán ZZ0035ZZ_
   ZZ0036ZZ LED (đỏ)
	    ZZ0037ZZ ZZ0038ZZ ZZ0039ZZ ZZ0040ZZ ZZ0041ZZ ZZ0042ZZ ZZ0043ZZ ZZ0044ZZ ZZ0045ZZ ZZ0046ZZ ZZ0047ZZ
	    ZZ0048ZZ ZZ0049ZZ ZZ0050ZZ ZZ0051ZZ ZZ0052ZZ ZZ0053ZZ ZZ0054ZZ ZZ0055ZZ ZZ0056ZZ ZZ0057ZZ ZZ0058ZZ
							      |
							      |

Và đây là cài đặt cho một số công tắc và nút nhảy trên thẻ.

::

Vào/ra

1 2 3 4 5 6 7 8

2E0---- 0 0 0 1 0 0 0 1
  2F0------ 0 0 0 1 0 0 0 0
  300------ 0 0 0 0 1 1 1 1
  350---- 0 0 0 0 1 1 1 0

"0" trong ví dụ trên có nghĩa là công tắc tắt "1" có nghĩa là công tắc đang bật.

::

Địa chỉ ShMem.

1 2 3 4 5 6 7 8

CX00--0 0 1 1 ZZ0000ZZ |
  DX00--0 0 1 0 |
  X000-------- 1 1 |
  X400--------- 1 0 |
  X800---------- 0 1 |
  XC00---------- 0 0
  ENHANCED---------- 1
  COMPATIBLE--------- 0

::

IRQ


3 4 5 7 2
     . . . . .
     . . . . .


Có DIP-switch với 8 switch, dùng để thiết lập địa chỉ bộ nhớ dùng chung
được sử dụng. 6 switch đầu tiên đặt địa chỉ, switch thứ 7 không có
chức năng và công tắc thứ 8 được sử dụng để chọn "tương thích" hoặc "nâng cao".
Khi tôi nhận được hai thẻ của mình, một trong số chúng đã đặt công tắc này thành "nâng cao". Đó
Thẻ hoàn toàn không hoạt động, tài xế thậm chí còn không nhận ra nó. Cái khác
thẻ đã đặt công tắc này thành "tương thích" và nó hoạt động hoàn toàn bình thường. tôi
đoán rằng công tắc trên một trong các thẻ chắc chắn đã bị thay đổi một cách vô tình
khi thẻ được lấy ra khỏi máy chủ cũ của nó. Câu hỏi vẫn còn
chưa được trả lời, mục đích của quan điểm "nâng cao" là gì?

[Lưu ý của Avery: "nâng cao" có thể vô hiệu hóa bộ nhớ dùng chung (sử dụng IO
thay vào đó là cổng) hoặc vô hiệu hóa cổng IO (thay vào đó hãy sử dụng địa chỉ bộ nhớ).  Cái này
thay đổi tùy theo loại thẻ liên quan.  Tôi không hiểu một trong hai điều này như thế nào
tăng cường bất cứ điều gì.  Gửi cho tôi thông tin chi tiết hơn về chế độ này, hoặc
thay vào đó chỉ cần sử dụng chế độ "tương thích".]

Công ty vi mô Waterloo ??
=============================

Thẻ 8 bit (C) 1985
-------------------
- từ Robert Michael Best <rmb117@cs.usask.ca>

[Lưu ý của Avery: vì lý do nào đó, những thứ này không hoạt động với trình điều khiển của tôi.  Những thẻ này
SEEM có cài đặt tương tự như PDI508Plus, đó là
được cấu hình bằng phần mềm và cũng không hoạt động với trình điều khiển của tôi.  "Waterloo
chip" là một chiếc boot PROM, có lẽ được thiết kế dành riêng cho Đại học
Waterloo.  Nếu bạn có thêm thông tin gì về thẻ này, vui lòng
gửi email cho tôi.]

Đầu dò không thể phát hiện thẻ trên bất kỳ cài đặt J2 nào,
và tôi đã thử lại với chip "Waterloo" đã được gỡ bỏ.

::

_____________________________________________________________________
  ZZ0000ZZ
  ZZ0001ZZ^ZZ0002ZZ M |ZZ0003ZZZZ0004ZZ |
  ZZ0005ZZ_ZZ0006ZZ 5 |ZZ0007ZZZZ0008ZZ C3 |
  ZZ0009ZZ___|ZZ0010ZZZZ0011ZZ |
  ZZ0012ZZ ZZ0013ZZ
  ZZ0014ZZ \/ |ZZ0015ZZ |
  ZZ0016ZZ |ZZ0017ZZ |
  ZZ0018ZZ |ZZ0019ZZ |
  ZZ0020ZZ |ZZ0021ZZ \/ _____|
  ZZ0022ZZ C6 |ZZ0023ZZ C9 ZZ0024ZZ___
  ZZ0025ZZ |ZZ0026ZZ -- ZZ0027ZZ___|
  ZZ0028ZZ |ZZ0029ZZ >C7ZZ0030ZZ_____|
  ZZ0031ZZ |ZZ0032ZZ |
  ZZ0033ZZ____|ZZ0034ZZ 1 2 3 6 |
  |ZZ0035ZZ >C4|                      |o|o|o|o|o|o| J2 >C4ZZ0040ZZ
  |ZZ0041ZZ |o|o|o|o|o|o|                  |
  |ZZ0046ZZ >C4ZZ0047ZZ |
  |ZZ0048ZZ >C8ZZ0049ZZ
  |ZZ0050ZZ 2 3 4 5 6 7 IRQ >C4ZZ0051ZZ
  |ZZ0052ZZ |o|o|o|o|o|o| J3                                        |
  |_______      |o|o|o|o|o|o| _______________|
	  ZZ0061ZZ
	  ZZ0062ZZ

C1 -- "COM9026
	 SMC 8638"
	Trong một ổ cắm chip.

C2 -- "@Bản quyền
	 Công ty TNHH Hệ thống vi mô Waterloo
	 1985"
	Trong ổ cắm chip có thông tin được in trên nhãn che cửa sổ tròn
	hiển thị mạch bên trong. (Cửa sổ cho biết đó là chip EPROM.)

C3 -- "COM9032
	 SMC 8643"
	Trong một ổ cắm chip.

C4 -- "74LS"
	Tổng cộng 9 không có ổ cắm.

M5 -- "50006-136
	 20.000000 MHZ
	 MTQ-T1-S3
	 0 M-TRON 86-40"
	Vỏ kim loại có 4 chân, không có ổ cắm.

C6 -- "MOSTEK@TC8643
	 MK6116N-20
	 MALAYSIA"
	Không có ổ cắm.

C7 -- Không có tem hoặc nhãn nhưng nằm trong ổ cắm chip 20 chân.

C8 -- "PAL10L8CN
	 8623"
	Trong ổ cắm 20 chân.

C9 -- "PAl16R4A-2CN
	 8641"
	Trong ổ cắm 20 chân.

C10 -- "M8640
	    NMC
	  9306N"
	 Trong một ổ cắm 8 chân.

?? -- Một số thành phần trên bảng nhỏ hơn và được gắn bằng 20 chân
	dọc theo phía gần đầu nối BNC nhất.  Chúng được phủ trong bóng tối
	nhựa.

Trên bảng có hai dãy jumper có nhãn J2 và J3. các
nhà sản xuất đã không đưa J1 lên bảng. Hai bảng tôi có cả hai
đi kèm với một hộp nhảy cho mỗi ngân hàng.

::

J2 -- Được đánh số 1 2 3 4 5 6.
	4 và 5 không được đóng dấu do có điểm hàn.

J3 -- IRQ 2 3 4 5 6 7

Bản thân bảng có hình lá phong được đóng dấu ngay phía trên dây nhảy irq
và "-2 46-86" bên cạnh C2. Giữa C1 và C6 "ASS 'Y 300163" và "@1986
CORMAN CUSTOM ELECTRONICS CORP." được đóng dấu ngay bên dưới đầu nối BNC.
Bên dưới "MADE TRONG CANADA"

Không Tên
=======

Thẻ 8 bit, thẻ 16 bit
-------------------------

- từ Juergen Seifert <seifert@htwm.de>

Tôi đã đặt tên thẻ ARCnet này là "NONAME", vì không có tên nào
của nhà sản xuất trên Hướng dẫn lắp đặt cũng như trên hộp vận chuyển. duy nhất
gợi ý về sự tồn tại của một nhà sản xuất được viết bằng đồng,
đó là "Sản xuất tại Đài Loan"

Mô tả này được viết bởi Juergen Seifert <seifert@htwm.de>
sử dụng thông tin từ bản gốc

"Hướng dẫn cài đặt ARCnet"

::

________________________________________________________________
   ZZ0000ZZSTARZZ0001ZZ T/PZZ0002ZZ
   ZZ0003ZZ____ZZ0004ZZ____ZZ0005ZZ
   ZZ0006ZZ
   ZZ0007ZZ ZZ0008ZZ
   ZZ0009ZZ ZZ0010ZZ
   ZZ0011ZZ ZZ0012ZZ
   ZZ0013ZZ SMC ZZ0014ZZ
   ZZ0015ZZ ZZ0016ZZ
   ZZ0017ZZ COM90C65 ZZ0018ZZ
   ZZ0019ZZ ZZ0020ZZ
   ZZ0021ZZ ZZ0022ZZ
   ZZ0023ZZ__________-__________ZZ0024ZZ
   ZZ0025ZZ
   ZZ0026ZZ CN |
   ZZ0027ZZ PROM ZZ0028ZZ_____|
   ZZ0029ZZ |
   ZZ0030ZZ_______________ZZ0031ZZ
   ZZ0032ZZ
   |           |o|o|o|o|o|o|o|o| ZZ0038ZZZZ0039ZZ|
   |           |o|o|o|o|o|o|o|o| ZZ0045ZZZZ0046ZZ|
   ZZ0047ZZ__MEM____|
       ZZ0048ZZ
       ZZ0049ZZ

Huyền thoại::

COM90C65: Đầu dò ARCnet
  S1 1-8: Chọn ID nút
  S2 1-3: Chọn địa chỉ cơ sở I/O
      4-6: Chọn địa chỉ cơ sở bộ nhớ
      7-8: Chọn bù RAM
  ET1, ET2 Chọn thời gian chờ kéo dài
  ROM ROM Bật Chọn
  Đầu nối đồng trục CN RG62
  STARZZ0000ZZ T/P Ba trường để đặt biển báo (vòng tròn màu)
		  chỉ ra cấu trúc liên kết của thẻ

Đặt một trong các công tắc thành Tắt có nghĩa là "1", Bật có nghĩa là "0".


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong nhóm SW1 được sử dụng để đặt ID nút.
Mỗi nút được gắn vào mạng phải có một ID nút duy nhất
phải khác 0.
Switch 8 đóng vai trò là bit ít quan trọng nhất (LSB).

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là::

Chuyển đổi | Giá trị
    -------|-------
      8 |   1
      7 |   2
      6 |   4
      5 |   8
      4 |  16
      3 |  32
      2 |  64
      1 | 128

Một số ví dụ::

Chuyển đổi số thập phân ZZ0000ZZ
   1 2 3 4 5 6 7 8 ZZ0001ZZ ID nút
   -------ZZ0002ZZ----------
   0 0 0 0 0 0 0 0 |    không được phép
   0 0 0 0 0 0 0 1 ZZ0003ZZ 1
   0 0 0 0 0 0 1 0 ZZ0004ZZ 2
   0 0 0 0 0 0 1 1 ZZ0005ZZ 3
       . . .       ZZ0006ZZ
   0 1 0 1 0 1 0 1 ZZ0007ZZ 85
       . . .       ZZ0008ZZ
   1 0 1 0 1 0 1 0 ZZ0009ZZ 170
       . . .       ZZ0010ZZ
   1 1 1 1 1 1 0 1 ZZ0011ZZ 253
   1 1 1 1 1 1 1 0 ZZ0012ZZ 254
   1 1 1 1 1 1 1 1 ZZ0013ZZ 255


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ba công tắc đầu tiên trong nhóm công tắc SW2 được sử dụng để chọn một công tắc
trong số tám địa chỉ Cơ sở I/O có thể sử dụng bảng sau::

Chuyển đổi | I/O lục giác
    1 2 3 | Địa chỉ
   ------------|-------
   TRÊN TRÊN TRÊN |  260
   TRÊN OFF |  290
   TRÊN OFF TRÊN |  2E0 (Mặc định của nhà sản xuất)
   TRÊN OFF OFF |  2F0
   OFF BẬT |  300
   OFF TRÊN OFF |  350
   OFF OFF BẬT |  380
   OFF OFF OFF |  3E0


Đặt địa chỉ bộ đệm Bộ nhớ cơ sở (RAM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhớ đệm yêu cầu 2K của khối RAM 16K. Cơ sở của điều này
Khối 16K có thể được đặt ở bất kỳ vị trí nào trong tám vị trí.
Switch 4-6 của nhóm switch SW2 chọn Base của khối 16K.
Trong không gian địa chỉ 16K đó, bộ đệm có thể được gán bất kỳ một trong bốn
các vị trí, được xác định bằng độ lệch, công tắc 7 và 8 của nhóm SW2.

::

Chuyển đổi ZZ0000ZZ Hex ROM
   4 5 6 7 8 ZZ0001ZZ Địa chỉ *)
   -----------ZZ0002ZZ----------
   0 0 0 0 0 ZZ0003ZZ C2000
   0 0 0 0 1 ZZ0004ZZ C2000
   0 0 0 1 0 ZZ0005ZZ C2000
   0 0 0 1 1 ZZ0006ZZ C2000
	      ZZ0007ZZ
   0 0 1 0 0 ZZ0008ZZ C6000
   0 0 1 0 1 ZZ0009ZZ C6000
   0 0 1 1 0 ZZ0010ZZ C6000
   0 0 1 1 1 ZZ0011ZZ C6000
	      ZZ0012ZZ
   0 1 0 0 0 ZZ0013ZZ CE000
   0 1 0 0 1 ZZ0014ZZ CE000
   0 1 0 1 0 ZZ0015ZZ CE000
   0 1 0 1 1 ZZ0016ZZ CE000
	      ZZ0017ZZ
   0 1 1 0 0 ZZ0018ZZ D2000 (Mặc định của nhà sản xuất)
   0 1 1 0 1 ZZ0019ZZ D2000
   0 1 1 1 0 ZZ0020ZZ D2000
   0 1 1 1 1 ZZ0021ZZ D2000
	      ZZ0022ZZ
   1 0 0 0 0 ZZ0023ZZ D6000
   1 0 0 0 1 ZZ0024ZZ D6000
   1 0 0 1 0 ZZ0025ZZ D6000
   1 0 0 1 1 ZZ0026ZZ D6000
	      ZZ0027ZZ
   1 0 1 0 0 ZZ0028ZZ DA000
   1 0 1 0 1 ZZ0029ZZ DA000
   1 0 1 1 0 ZZ0030ZZ DA000
   1 0 1 1 1 ZZ0031ZZ DA000
	      ZZ0032ZZ
   1 1 0 0 0 ZZ0033ZZ DE000
   1 1 0 0 1 ZZ0034ZZ DE000
   1 1 0 1 0 ZZ0035ZZ DE000
   1 1 0 1 1 ZZ0036ZZ DE000
	      ZZ0037ZZ
   1 1 1 0 0 ZZ0038ZZ E2000
   1 1 1 0 1 ZZ0039ZZ E2000
   1 1 1 1 0 ZZ0040ZZ E2000
   1 1 1 1 1 ZZ0041ZZ E2000

*) Để kích hoạt 8K Boot PROM, hãy cài đặt jumper ROM.
      Mặc định là jumper ROM chưa được cài đặt.


Đặt dòng yêu cầu ngắt (IRQ)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Để chọn mức ngắt phần cứng, hãy đặt một (chỉ một!) trong số các nút nhảy
IRQ2, IRQ3, IRQ4, IRQ5 hoặc IRQ7. Mặc định của nhà sản xuất là IRQ2.


Đặt thời gian chờ
^^^^^^^^^^^^^^^^^^^^

Hai jumper có nhãn ET1 và ET2 được sử dụng để xác định thời gian chờ
các thông số (thời gian đáp ứng và cấu hình lại). Mỗi nút trong một mạng
phải được đặt thành cùng giá trị thời gian chờ.

::

ET1 ET2 ZZ0000ZZ Thời gian cấu hình lại (ms)
   --------ZZ0001ZZ--------------------------
   Tắt Tắt ZZ0002ZZ 840 (Mặc định)
   Tắt Bật ZZ0003ZZ 1680
   Bật Tắt ZZ0004ZZ 1680
   Bật Trên ZZ0005ZZ 1680

Bật có nghĩa là jumper đã được cài đặt, Tắt có nghĩa là jumper chưa được cài đặt


16-BIT ARCNET
-------------

Hướng dẫn sử dụng Thẻ ARCnet 8 bit NONAME của tôi chứa một mô tả khác
của Thẻ cặp đồng trục / xoắn 16-bit. Mô tả này không đầy đủ,
vì tập sách hướng dẫn sử dụng bị thiếu hai trang. (Cái bàn
về nội dung trang báo cáo... 2-9, 2-11, 2-12, 3-1, ... nhưng bên trong
tập sách nhỏ có cách đếm khác ... 2-9, 2-10, A-1,
(trang trống), 3-1, ..., 3-18, A-1 (lại), A-2)
Ngoài ra hình ảnh bố cục bảng cũng không đẹp bằng hình ảnh của
Thẻ 8-bit, vì không có chữ cái nào như "SW1" được ghi vào thẻ
hình ảnh.

Nếu ai đó có một bảng như vậy, xin vui lòng hoàn thành nó
mô tả hoặc gửi thư cho tôi!

Mô tả này được viết bởi Juergen Seifert <seifert@htwm.de>
sử dụng thông tin từ bản gốc

"Hướng dẫn cài đặt ARCnet"

::

___________________________________________________________________
  < _________________ _________________ |
  > ZZ0000ZZZZ0001ZZ |
  < ZZ0002ZZZZ0003ZZ |
  > ____________________ |
  < ZZ0004ZZ |
  > ZZ0005ZZ |
  < ZZ0006ZZ |
  > ZZ0007ZZ |
  < ZZ0008ZZ |
  > ZZ0009ZZ |
  < ZZ0010ZZ |
  > ZZ0011ZZ |
  < ____|
  > ____________________ ZZ0012ZZ
  < ZZ0013ZZ ZZ0014ZZ
  > ZZ0015ZZ |
  < ZZ0016ZZ ? ? ? ? ? ?     ZZ0017ZZ
  > |o|o|o|o|o|o|         |
  < |o|o|o|o|o|o|         |
  > |
  < __ ___________|
  > ZZ0026ZZ |
  <____________ZZ0027ZZ_______________________________________|


Đặt một trong các công tắc thành Tắt có nghĩa là "1", Bật có nghĩa là "0".


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong nhóm SW2 được sử dụng để đặt ID nút.
Mỗi nút được gắn vào mạng phải có một ID nút duy nhất
phải khác 0.
Switch 8 đóng vai trò là bit ít quan trọng nhất (LSB).

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là::

Chuyển đổi | Giá trị
    -------|-------
      8 |   1
      7 |   2
      6 |   4
      5 |   8
      4 |  16
      3 |  32
      2 |  64
      1 | 128

Một số ví dụ::

Chuyển đổi số thập phân ZZ0000ZZ
   1 2 3 4 5 6 7 8 ZZ0001ZZ ID nút
   -------ZZ0002ZZ----------
   0 0 0 0 0 0 0 0 |    không được phép
   0 0 0 0 0 0 0 1 ZZ0003ZZ 1
   0 0 0 0 0 0 1 0 ZZ0004ZZ 2
   0 0 0 0 0 0 1 1 ZZ0005ZZ 3
       . . .       ZZ0006ZZ
   0 1 0 1 0 1 0 1 ZZ0007ZZ 85
       . . .       ZZ0008ZZ
   1 0 1 0 1 0 1 0 ZZ0009ZZ 170
       . . .       ZZ0010ZZ
   1 1 1 1 1 1 0 1 ZZ0011ZZ 253
   1 1 1 1 1 1 1 0 ZZ0012ZZ 254
   1 1 1 1 1 1 1 1 ZZ0013ZZ 255


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ba công tắc đầu tiên trong nhóm công tắc SW1 được sử dụng để chọn một công tắc
trong số tám địa chỉ Cơ sở I/O có thể sử dụng bảng sau::

Chuyển đổi | I/O lục giác
    3 2 1 | Địa chỉ
   ------------|-------
   TRÊN TRÊN TRÊN |  260
   TRÊN OFF |  290
   TRÊN OFF TRÊN |  2E0 (Mặc định của nhà sản xuất)
   TRÊN OFF OFF |  2F0
   OFF BẬT |  300
   OFF TRÊN OFF |  350
   OFF OFF BẬT |  380
   OFF OFF OFF |  3E0


Đặt địa chỉ bộ đệm Bộ nhớ cơ sở (RAM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhớ đệm yêu cầu 2K của khối RAM 16K. Cơ sở của điều này
Khối 16K có thể được đặt ở bất kỳ vị trí nào trong tám vị trí.
Switch 6-8 của nhóm switch SW1 chọn Base của khối 16K.
Trong không gian địa chỉ 16K đó, bộ đệm có thể được gán bất kỳ một trong bốn
vị trí, được xác định bằng độ lệch, công tắc 4 và 5 của nhóm SW1::

Chuyển đổi ZZ0000ZZ Hex ROM
   8 7 6 5 4 ZZ0001ZZ Địa chỉ
   -----------ZZ0002ZZ----------
   0 0 0 0 0 ZZ0003ZZ C2000
   0 0 0 0 1 ZZ0004ZZ C2000
   0 0 0 1 0 ZZ0005ZZ C2000
   0 0 0 1 1 ZZ0006ZZ C2000
	      ZZ0007ZZ
   0 0 1 0 0 ZZ0008ZZ C6000
   0 0 1 0 1 ZZ0009ZZ C6000
   0 0 1 1 0 ZZ0010ZZ C6000
   0 0 1 1 1 ZZ0011ZZ C6000
	      ZZ0012ZZ
   0 1 0 0 0 ZZ0013ZZ CE000
   0 1 0 0 1 ZZ0014ZZ CE000
   0 1 0 1 0 ZZ0015ZZ CE000
   0 1 0 1 1 ZZ0016ZZ CE000
	      ZZ0017ZZ
   0 1 1 0 0 ZZ0018ZZ D2000 (Mặc định của nhà sản xuất)
   0 1 1 0 1 ZZ0019ZZ D2000
   0 1 1 1 0 ZZ0020ZZ D2000
   0 1 1 1 1 ZZ0021ZZ D2000
	      ZZ0022ZZ
   1 0 0 0 0 ZZ0023ZZ D6000
   1 0 0 0 1 ZZ0024ZZ D6000
   1 0 0 1 0 ZZ0025ZZ D6000
   1 0 0 1 1 ZZ0026ZZ D6000
	      ZZ0027ZZ
   1 0 1 0 0 ZZ0028ZZ DA000
   1 0 1 0 1 ZZ0029ZZ DA000
   1 0 1 1 0 ZZ0030ZZ DA000
   1 0 1 1 1 ZZ0031ZZ DA000
	      ZZ0032ZZ
   1 1 0 0 0 ZZ0033ZZ DE000
   1 1 0 0 1 ZZ0034ZZ DE000
   1 1 0 1 0 ZZ0035ZZ DE000
   1 1 0 1 1 ZZ0036ZZ DE000
	      ZZ0037ZZ
   1 1 1 0 0 ZZ0038ZZ E2000
   1 1 1 0 1 ZZ0039ZZ E2000
   1 1 1 1 0 ZZ0040ZZ E2000
   1 1 1 1 1 ZZ0041ZZ E2000


Đặt dòng yêu cầu ngắt (IRQ)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

????????????????????????????????????????


Đặt thời gian chờ
^^^^^^^^^^^^^^^^^^^^

????????????????????????????????????????


Thẻ 8-bit ("Sản xuất tại Đài Loan R.O.C.")
-------------------------------------

- từ Vojtech Pavlik <vojtech@suse.cz>

Tôi đã đặt tên thẻ ARCnet này là "NONAME", vì tôi chỉ có thẻ có
không có sách hướng dẫn nào cả và văn bản duy nhất xác định nhà sản xuất là
Dòng chữ "MADE IN TAIWAN R.O.C" được in trên thẻ.

::

____________________________________________________________
	 ZZ0000ZZ
	 | |o|o| JP1 o|o|o|o|o|o|o|o| TRÊN |
	 |  +              o|o|o|o|o|o|o|o|                        ___|
	 |  _____________  o|o|o|o|o|o|o|o| OFF         _____     | | ID7
	 ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ | ID6
	 ZZ0020ZZ ____________________ ZZ0021ZZ ZZ0022ZZ ID5
	 ZZ0023ZZ_____________ZZ0024ZZ |ZZ0025ZZ ZZ0026ZZ ID4
	 ZZ0027ZZ |ZZ0028ZZ ZZ0029ZZ ID3
	 ZZ0030ZZ |ZZ0031ZZ ZZ0032ZZ ID2
	 ZZ0033ZZ |ZZ0034ZZ ZZ0035ZZ ID1
	 ZZ0036ZZ 90C65 |ZZ0037ZZ ZZ0038ZZ ID0
	 ZZ0039ZZ |ZZ0040ZZ |
	 | |o|o|o|o|o|o|o|o| TRÊN ZZ0046ZZZZ0047ZZ |
	 | |o|o|o|o|o|o|o|o| ZZ0053ZZZZ0054ZZ |
	 | |o|o|o|o|o|o|o|o| OFF ZZ0060ZZZZ0061ZZ _____|
	 ZZ0062ZZ ZZ0063ZZ |___
	 ZZ0064ZZ ZZ0065ZZ BNC ZZ0066ZZ
	 ZZ0067ZZ ZZ0068ZZ_____ZZ0069ZZ_____|
	 ZZ0070ZZ |
	 ZZ0071ZZ______________ZZ0072ZZ
	 ZZ0073ZZ
	 ZZ0074ZZ
	 ZZ0075ZZ

Huyền thoại::

Chip 90C65 ARCNET
  SW1 1-5: Chọn địa chỉ bộ nhớ cơ sở
      6-8: Chọn địa chỉ I/O cơ sở
  SW2 1-8: Chọn ID nút (ID0-ID7)
  SW3 1-5: IRQ Chọn
      6-7: Hết thời gian bù giờ
      8 : Kích hoạt ROM
  Đầu nối Led JP1
  Đầu nối đồng trục BNC

Mặc dù dây nhảy SW1 và SW3 được đánh dấu SW chứ không phải JP nhưng chúng là dây nhảy chứ không phải
công tắc.

Đặt nút nhảy thành BẬT có nghĩa là kết nối hai chân trên, ngoài đáy
hai - hoặc - trong trường hợp cài đặt IRQ, không kết nối cái nào cả.

Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong SW2 được sử dụng để đặt ID nút. Mỗi nút đính kèm
vào mạng phải có ID nút duy nhất không được bằng 0.
Công tắc 1 (ID0) đóng vai trò là bit ít quan trọng nhất (LSB).

Đặt một trong các công tắc thành Tắt có nghĩa là "1", Bật có nghĩa là "0".

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là::

Chuyển đổi giá trị ZZ0000ZZ
   -------ZZ0001ZZ-------
     1 ZZ0002ZZ 1
     2 ZZ0003ZZ 2
     3 ZZ0004ZZ 4
     4 ZZ0005ZZ 8
     5 ZZ0006ZZ 16
     6 ZZ0007ZZ 32
     7 ZZ0008ZZ 64
     8 ZZ0009ZZ 128

Một số ví dụ::

Chuyển đổi số thập phân ZZ0000ZZ
   8 7 6 5 4 3 2 1 ID nút ZZ0001ZZ
   -------ZZ0002ZZ----------
   0 0 0 0 0 0 0 0 |    không được phép
   0 0 0 0 0 0 0 1 ZZ0003ZZ 1
   0 0 0 0 0 0 1 0 ZZ0004ZZ 2
   0 0 0 0 0 0 1 1 ZZ0005ZZ 3
       . . .       ZZ0006ZZ
   0 1 0 1 0 1 0 1 ZZ0007ZZ 85
       . . .       ZZ0008ZZ
   1 0 1 0 1 0 1 0 ZZ0009ZZ 170
       . . .       ZZ0010ZZ
   1 1 1 1 1 1 0 1 ZZ0011ZZ 253
   1 1 1 1 1 1 1 0 ZZ0012ZZ 254
   1 1 1 1 1 1 1 1 ZZ0013ZZ 255


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ba công tắc cuối cùng trong khối chuyển mạch SW1 được sử dụng để chọn một công tắc
trong số tám địa chỉ Cơ sở I/O có thể sử dụng bảng sau::


Chuyển đổi | I/O lục giác
    6 7 8 | Địa chỉ
   ------------|-------
   TRÊN TRÊN TRÊN |  260
   OFF BẬT |  290
   TRÊN OFF TRÊN |  2E0 (Mặc định của nhà sản xuất)
   OFF OFF BẬT |  2F0
   BẬT TRÊN OFF |  300
   OFF TRÊN OFF |  350
   TRÊN OFF OFF |  380
   OFF OFF OFF |  3E0


Đặt địa chỉ bộ đệm Bộ nhớ cơ sở (RAM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhớ đệm (RAM) yêu cầu 2K. Cơ sở của bộ đệm này có thể là
nằm ở bất kỳ vị trí nào trong tám vị trí. Địa chỉ của Boot Prom là
cơ sở bộ nhớ + 0x2000.

Jumper 3-5 của khối jumper SW1 chọn địa chỉ Memory Base.

::

Chuyển đổi ZZ0000ZZ Hex ROM
    1 2 3 4 5 ZZ0001ZZ Địa chỉ *)
   --------------------ZZ0002ZZ----------
   BẬT BẬT BẬT TRÊN ZZ0003ZZ C2000
   BẬT TRÊN OFF BẬT TRÊN ZZ0004ZZ C6000
   BẬT TRÊN OFF TRÊN ZZ0005ZZ CE000
   BẬT TRÊN OFF OFF TRÊN ZZ0006ZZ D2000 (Mặc định của Nhà sản xuất)
   BẬT BẬT BẬT TRÊN OFF ZZ0007ZZ D6000
   BẬT TRÊN OFF TRÊN OFF ZZ0008ZZ DA000
   BẬT TRÊN OFF OFF ZZ0009ZZ DE000
   BẬT TRÊN OFF OFF OFF ZZ0010ZZ E2000

*) Để kích hoạt Boot ROM, hãy đặt jumper 8 của khối jumper SW3 ở vị trí BẬT.

Bộ nhảy 1 và 2 có thể thêm các bộ cộng 0x0800, 0x1000 và 0x1800 vào RAM.

Đặt đường ngắt
^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhảy 1-5 của khối nhảy SW3 điều khiển cấp độ IRQ::

Nhảy |  IRQ
    1 2 3 4 5 |
   ----------------------------
    TRÊN OFF OFF OFF OFF |  2
    OFF TRÊN OFF OFF OFF |  3
    OFF OFF TRÊN OFF OFF |  4
    OFF OFF OFF TRÊN OFF |  5
    OFF OFF OFF OFF TRÊN |  7


Đặt tham số thời gian chờ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các jumper 6-7 của khối jumper SW3 được sử dụng để xác định thời gian chờ
các thông số. Hai jumper này thường được để ở vị trí OFF.



(Mẫu chung 9058)
--------------------
- từ Andrew J. Kroll <ag784@freenet.buffalo.edu>
  - Xin lỗi, việc này đã nằm trong hộp việc cần làm của tôi quá lâu, Andrew! (yike - hơn một
    năm!)

::

_____
								     |    <
								     | .---'
    ________________________________________________________________ ZZ0000ZZ
   ZZ0001ZZ SW2 ZZ0002ZZ |
   ZZ0003ZZ_____________ZZ0004ZZ |
   ZZ0005ZZ ZZ0006ZZ |
   ZZ0007ZZ _________ 8 ZZ0008ZZ |
   |  |___________|        |20MHzXtal|                        7 | ZZ0012ZZ
   ZZ0013ZZ_________ZZ0014ZZ S ZZ0015ZZ
   ZZ0016ZZ ZZ0017ZZ W ZZ0018ZZ
   ZZ0019ZZ E ZZ0020ZZ ZZ0021ZZ
   ZZ0022ZZ ______________ZZ0023ZZ- 3 ZZ0024ZZ |
   ZZ0025ZZ ZZ0026ZZ- 2 ZZ0027ZZ |
   ZZ0028ZZ ZZ0029ZZ- 1 ZZ0030ZZ |
   ZZ0031ZZ ZZ0032ZZ- ZZ0033ZZ
   ZZ0034ZZ SW1 ZZ0035ZZ SL90C65 ZZ0036ZZ- ZZ0037ZZ
   ZZ0038ZZ________________ZZ0039ZZ ZZ0040ZZ- ZZ0041ZZ
   ZZ0042ZZ ZZ0043ZZ- ZZ0044ZZ
   |                         |________o___|..../ A   |- _______ZZ0047ZZ
   ZZ0048ZZ R ZZ0049ZZ |------,
   ZZ0050ZZ ZZ0051ZZ D ZZ0052ZZ BNC ZZ0053ZZ
   ZZ0054ZZ ZZ0055ZZ- ZZ0056ZZ------'
   ZZ0057ZZ____________________ZZ0058ZZ |
   ZZ0059ZZ <- 74LS245 ZZ0060ZZ
   ZZ0061ZZ |
   ZZ0062ZZ |
       ZZ0063ZZ ZZ0064ZZ
       ZZ0065ZZ ZZ0066ZZ
								      \|

Huyền thoại::

Bộ điều khiển / Bộ thu phát / Logic SL90C65 ARCNET
  SW1 1-5: IRQ Chọn
	  6: ET1
	  7: ET2
	  8: ROM ENABLE
  SW2 1-3: Bộ nhớ đệm/Địa chỉ PROM
	3-6: Bản đồ địa chỉ I/O
  SW3 1-8: Chọn ID nút
  Kết nối BNC BNC RG62/U
		ZZ0000ZZ đã thành công khi sử dụng RG59B/U với đầu cuối ZZ0001ZZ!
		Cái gì mang lại?!

SW1: Hết giờ, Ngắt và ROM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Để chọn mức ngắt phần cứng, hãy đặt một (chỉ một!) công tắc nhúng
lên (bật) SW1...(chuyển 1-5)
IRQ3, IRQ4, IRQ5, IRQ7, IRQ2. Mặc định của Nhà sản xuất là IRQ2.

Các công tắc trên SW1 có nhãn EXT1 (công tắc 6) và EXT2 (công tắc 7)
được sử dụng để xác định các tham số thời gian chờ. Hai công tắc nhúng này
thường bị tắt (xuống).

Để bật vị trí 8K Boot PROM SW1, hãy bật 8 (UP) có nhãn ROM.
   Mặc định là jumper ROM chưa được cài đặt.


Đặt địa chỉ cơ sở I/O
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ba công tắc cuối cùng trong nhóm công tắc SW2 được sử dụng để chọn một công tắc
trong số tám địa chỉ Cơ sở I/O có thể sử dụng bảng sau::


Chuyển đổi | I/O lục giác
   4 5 6 | Địa chỉ
   -------|-------
   0 0 0 |  260
   0 0 1 |  290
   0 1 0 |  2E0 (Mặc định của nhà sản xuất)
   0 1 1 |  2F0
   1 0 0 |  300
   1 0 1 |  350
   1 1 0 |  380
   1 1 1 |  3E0


Đặt địa chỉ bộ nhớ cơ sở (RAM & ROM)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bộ nhớ đệm yêu cầu 2K của khối RAM 16K. Cơ sở của điều này
Khối 16K có thể được đặt ở bất kỳ vị trí nào trong tám vị trí.
Switch 1-3 của nhóm switch SW2 chọn Base của khối 16K.
(0 = DOWN, 1 = LÊN)
Tuy nhiên, tôi chỉ có thể xác minh hai cài đặt...


::

Chuyển đổi| Hex RAM | Hex ROM
   1 2 3 ZZ0001ZZ Địa chỉ
   ------ZZ0002ZZ----------
   0 0 0 ZZ0003ZZ E2000
   0 0 1 ZZ0004ZZ D2000 (Mặc định của nhà sản xuất)
   0 1 0 ZZ0005ZZ ?????
   0 1 1 ZZ0006ZZ ?????
   1 0 0 ZZ0007ZZ ?????
   1 0 1 ZZ0008ZZ ?????
   1 1 0 ZZ0009ZZ ?????
   1 1 1 ZZ0010ZZ ?????


Đặt ID nút
^^^^^^^^^^^^^^^^^^^

Tám công tắc trong nhóm SW3 được sử dụng để đặt ID nút.
Mỗi nút được gắn vào mạng phải có một ID nút duy nhất
phải khác 0.
Công tắc 1 đóng vai trò là bit ít quan trọng nhất (LSB).
công tắc ở vị trí DOWN là OFF (0) và ở vị trí UP là ON (1)

ID nút là tổng giá trị của tất cả các công tắc được đặt thành "1"
Những giá trị này là::

Chuyển đổi | Giá trị
    -------|-------
      1 |   1
      2 |   2
      3 |   4
      4 |   8
      5 |  16
      6 |  32
      7 |  64
      8 | 128

Một số ví dụ::

Switch#     ZZ0014ZZ thập phân
  8 7 6 5 4 3 2 1 ID nút ZZ0001ZZ
  -------ZZ0002ZZ----------
  0 0 0 0 0 0 0 0 |    không được phép <-.
  0 0 0 0 0 0 0 1 ZZ0003ZZ 1 |
  0 0 0 0 0 0 1 0 ZZ0004ZZ 2 |
  0 0 0 0 0 0 1 1 ZZ0005ZZ 3 |
      . . .       ZZ0006ZZ |
  0 1 0 1 0 1 0 1 ZZ0007ZZ 85 |
      . . .       ZZ0008ZZ + Không sử dụng 0 hoặc 255!
  1 0 1 0 1 0 1 0 ZZ0009ZZ 170 |
      . . .       ZZ0010ZZ |
  1 1 1 1 1 1 0 1 ZZ0011ZZ 253 |
  1 1 1 1 1 1 1 0 ZZ0012ZZ 254 |
  1 1 1 1 1 1 1 1 ZZ0013ZZ 255 <-'


vương miện
=====

(không rõ mẫu)
---------------

- từ Christoph Lameter <cl@gentwo.org>


Đây là thông tin về thẻ của tôi theo như tôi có thể tìm ra::


----------------------------------------------- vương miện
  Tiara LanCard của Hệ thống máy tính Tiara.

+---------------------------------------------- +
  !           ! Đơn vị phát sóng!               !
  !           +----------+ -------
  !          Đầu nối đồng trục MEM
  !  ROM 7654321 <- I/O -------
  !  : : +--------+ !
  !  : : ! 90C66LJ!                         +++
  !  : : !        !                         !D Chuyển sang cài đặt
  !  : : !        !                         !Tôi là số nút
  !  : : +--------+ !P
  !                                            !++
  !         234567 <- IRQ !
  +-------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!--------+
	       !!!!!!!!!!!!!!!!!!!!!!!!

- 0 = Đã cài đặt Jumper
- 1 = Mở

Dòng Jumper trên cùng Bit 7 = ROM Kích hoạt 654=Vị trí bộ nhớ 321=I/O

Cài đặt cho vị trí bộ nhớ (Dòng nhảy trên cùng)

=== ==================
456 Địa chỉ được chọn
=== ==================
000 C0000
001 C4000
010 CC000
011 D0000
100 D4000
101 D8000
110 DC000
111 E0000
=== ==================

Cài đặt cho Địa chỉ I/O (Dòng nhảy trên cùng)

=== ====
Cảng 123
=== ====
000 260
001 290
010 2E0
011 2F0
100 300
101 350
110 380
111 3E0
=== ====

Cài đặt cho lựa chọn IRQ (Dòng nhảy dưới)

====== =====
234567
====== =====
011111 IRQ 2
101111 IRQ 3
110111 IRQ 4
111011 IRQ 5
111110 IRQ 7
====== =====

Thẻ khác
===========

Hiện tại tôi không có thông tin về các mẫu thẻ ARCnet khác.

Cảm ơn.