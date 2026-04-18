.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/plip.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
PLIP: Thiết bị giao thức Internet đường song song
================================================

Donald Becker (becker@super.org)
I.D.A. Trung tâm nghiên cứu siêu máy tính, Bowie MD 20715

Tại một thời điểm nào đó, T. Thorn có thể sẽ đóng góp văn bản,
Tommy Thorn (tthorn@daimi.aau.dk)

Giới thiệu PLIP
-----------------

Tài liệu này mô tả bộ đẩy gói cổng song song cho Net/LGX.
Giao diện thiết bị này cho phép kết nối điểm-điểm giữa hai
các cổng song song xuất hiện dưới dạng giao diện mạng IP.

PLIP là gì?
=============

PLIP là Parallel Line IP, tức là vận chuyển các gói IP
qua một cổng song song. Trong trường hợp của PC, sự lựa chọn hiển nhiên là
cổng máy in.  PLIP không phải là tiêu chuẩn, nhưng [có thể sử dụng] sử dụng tiêu chuẩn
Cáp máy in null LapLink [cũng có thể hoạt động ở chế độ turbo, với PLIP
cáp]. [Giao thức được sử dụng để đóng gói các gói IP là một giao thức đơn giản
do Crynwr khởi xướng.]

Ưu điểm của PLIP
==================

Nó rẻ, có sẵn ở mọi nơi và dễ dàng.

Cáp PLIP là tất cả những gì cần thiết để kết nối hai hộp Linux và nó
có thể được xây dựng với rất ít đô la.

Việc kết nối hai hộp Linux chỉ mất một giây quyết định
vài phút làm việc, không cần phải tìm kiếm Netcard [được hỗ trợ]. Điều này có thể
thậm chí còn đặc biệt quan trọng trong trường hợp máy tính xách tay, nơi mà Netcard
không dễ dàng có được.

Không yêu cầu Netcard cũng có nghĩa là ngoài việc kết nối
cáp, mọi thứ khác đều là cấu hình phần mềm [về nguyên tắc
có thể được thực hiện rất dễ dàng.]

Nhược điểm của PLIP
=====================

Không hoạt động trên modem, như SLIP và PPP. Phạm vi giới hạn, 15 m.
Chỉ có thể được sử dụng để kết nối ba hộp Linux (?). Không kết nối với
một Ethernet hiện có. Không phải là tiêu chuẩn (thậm chí không phải là tiêu chuẩn thực tế, như
SLIP).

Hiệu suất
===========

PLIP dễ dàng hoạt động tốt hơn các card Ethernet....(ôi, tôi đang mơ, nhưng
ZZ0000ZZ đang bị trễ. EOB)

Chi tiết trình điều khiển PLIP
-------------------

Trình điều khiển Linux PLIP là một triển khai của giao thức Crynwr gốc,
sử dụng hệ thống con cổng song song của hạt nhân để thực hiện đúng cách
chia sẻ các cổng song song giữa PLIP và các dịch vụ khác.

IRQ và thời gian chờ kích hoạt
=========================

Khi một cổng song song được sử dụng cho trình điều khiển PLIP có IRQ được cấu hình cho nó,
Trình điều khiển PLIP được báo hiệu bất cứ khi nào dữ liệu được gửi tới nó qua cáp, chẳng hạn như
khi không có dữ liệu, trình điều khiển sẽ không được sử dụng.

Tuy nhiên, trên một số máy, việc định cấu hình IRQ là khó, nếu không nói là không thể.
tới một cổng song song nhất định, chủ yếu là do nó được sử dụng bởi một số thiết bị khác.
Trên các máy này, trình điều khiển PLIP có thể được sử dụng ở chế độ không có IRQ, trong đó
trình điều khiển PLIP sẽ liên tục thăm dò cổng song song để chờ dữ liệu,
và nếu dữ liệu đó có sẵn, hãy xử lý nó. Chế độ này kém hiệu quả hơn
chế độ IRQ, vì trình điều khiển phải kiểm tra cổng song song nhiều lần
mỗi giây, ngay cả khi không có dữ liệu nào được gửi đi. Một số phép đo thô
cho biết rằng không có hiện tượng giảm hiệu suất đáng chú ý khi sử dụng IRQ-less
so với chế độ IRQ về tốc độ truyền dữ liệu.
Có sự sụt giảm hiệu suất trên máy lưu trữ trình điều khiển.

Khi trình điều khiển PLIP được sử dụng ở chế độ IRQ, thời gian chờ được sử dụng để kích hoạt
truyền dữ liệu (thời gian tối đa mà trình điều khiển PLIP cho phép phía bên kia
trước khi thông báo thời gian chờ, khi cố gắng bắt tay chuyển một số
data) theo mặc định là 500usec. Vì việc giao hàng IRQ ít nhiều diễn ra ngay lập tức,
thời gian chờ này là khá đủ.

Khi ở chế độ không có IRQ, trình điều khiển PLIP sẽ thăm dò cổng song song HZ lần
mỗi giây (trong đó HZ thường là 100 trên hầu hết các nền tảng và 1024 trên
Alpha, tính đến thời điểm viết bài này). Giữa hai cuộc thăm dò như vậy, có 10^6/HZ usec.
Ví dụ: trên i386, 10^6/100 = 10000usec. Dễ dàng nhận thấy đó là
hoàn toàn có thể hết thời gian chờ kích hoạt giữa hai cuộc thăm dò như vậy, như
thời gian chờ chỉ dài 500usec. Kết quả là, cần phải thay đổi
thời gian chờ kích hoạt ở phía ZZ0000ZZ của kết nối PLIP, khoảng
10^6/HZ sử dụng. Nếu cả hai phía của kết nối PLIP được sử dụng ở chế độ không có IRQ,
thời gian chờ này là bắt buộc ở cả hai bên.

Có vẻ như trong thực tế, thời gian chờ kích hoạt có thể ngắn hơn trong
tính toán trên. Đó không phải là vấn đề quan trọng, trừ khi dây bị lỗi,
trong trường hợp đó, thời gian chờ lâu sẽ khiến máy bị treo khi, vì bất kỳ lý do gì
lý do, bit bị bỏ.

Một tiện ích có thể thực hiện thay đổi này trong Linux là plipconfig, một phần
của gói công cụ mạng (vị trí của nó có thể được tìm thấy trong
Tệp tài liệu/Thay đổi). Một lệnh ví dụ sẽ là
'plipconfig plipX trigger 10000', trong đó plipX là thích hợp
Thiết bị PLIP.

Kết nối phần cứng PLIP
-----------------------------

PLIP sử dụng một số phương thức truyền dữ liệu khác nhau.  The first (and the
chỉ một cái được triển khai trong phiên bản đầu tiên của mã) sử dụng một tiêu chuẩn
cáp "null" của máy in để truyền dữ liệu bốn bit cùng một lúc bằng cách sử dụng
đầu ra bit dữ liệu được kết nối với đầu vào bit trạng thái.

Phương thức truyền dữ liệu thứ hai dựa trên cả hai máy có
Các cổng song song hai chiều, thay vì ZZ0000ZZ chỉ có đầu ra
cổng.  Điều này cho phép truyền tải toàn byte và tránh việc xây dựng lại
gặm nhấm thành từng byte, dẫn đến việc truyền tải nhanh hơn nhiều.

Cáp truyền song song 0
==============================

Cáp cho chế độ truyền đầu tiên là tiêu chuẩn
cáp "null" của máy in truyền dữ liệu bốn bit cùng một lúc bằng cách sử dụng
đầu ra bit dữ liệu của cổng đầu tiên (máy T) được kết nối với
đầu vào bit trạng thái của cổng thứ hai (máy R).  Có năm
đầu vào trạng thái và chúng được sử dụng làm bốn đầu vào dữ liệu và đồng hồ (dữ liệu
nhấp nháy), được sắp xếp sao cho các bit đầu vào dữ liệu xuất hiện liền kề nhau
bit với việc thực hiện đăng ký trạng thái tiêu chuẩn.

Cáp thực hiện giao thức này có sẵn trên thị trường dưới dạng
Cáp "Null Printer" hoặc "Turbo Laplink".  Nó có thể được xây dựng với
hai đầu nối đực DB-25 được kết nối đối xứng như sau ::

STROBE đầu ra 1*
    D0->ERROR 2 - 15 15 - 2
    D1->SLCT 3 - 13 13 - 3
    D2->PAPOUT 4 - 12 12 - 4
    D3->ACK 5 - 10 10 - 5
    D4->BUSY 6 - 11 11 - 6
    D5,D6,D7 là 7*, 8*, 9*
    AUTOFD đầu ra 14*
    INIT đầu ra 16*
    SLCTIN 17 - 17
    căn cứ bổ sung là 18*,19*,20*,21*,22*,23*,24*
    GROUND 25 - 25

* Không kết nối các chân này ở hai đầu

Nếu cáp bạn đang sử dụng có tấm chắn kim loại thì nó phải
chỉ được kết nối với vỏ DB-25 kim loại ở một đầu.

Chế độ truyền song song 1
========================

Phương thức truyền dữ liệu thứ hai dựa trên cả hai máy có
Các cổng song song hai chiều, thay vì ZZ0000ZZ chỉ có đầu ra
cổng.  Điều này cho phép truyền tải toàn byte và tránh việc xây dựng lại
gặm nhấm thành byte.  Cáp này không nên được sử dụng một chiều
Các cổng ZZ0001ZZ (ngược lại với ZZ0002ZZ) hoặc khi máy
không được định cấu hình cho PLIP, vì nó sẽ dẫn đến trình điều khiển đầu ra
xung đột và khả năng thiệt hại (không thể xảy ra).

Cáp cho chế độ truyền này phải được kết cấu như sau::

STROBE->BUSY 1 - 11
    D0->D0 2 - 2
    D1->D1 3 - 3
    D2->D2 4 - 4
    D3->D3 5 - 5
    D4->D4 6 - 6
    D5->D5 7 - 7
    D6->D6 8 - 8
    D7->D7 9 - 9
    INIT -> ACK 16 - 10
    AUTOFD->PAPOUT 14 - 12
    SLCT->SLCTIN 13 - 17
    GND->ERROR 18 - 15
    căn cứ bổ sung là 19*,20*,21*,22*,23*,24*
    GROUND 25 - 25

* Không kết nối các chân này ở hai đầu

Một lần nữa, nếu cáp bạn đang sử dụng có tấm chắn kim loại thì nó sẽ
chỉ được kết nối với vỏ DB-25 kim loại ở một đầu.

Giao thức truyền PLIP Chế độ 0
=============================

Trình điều khiển PLIP tương thích với chuyển cổng song song "Crynwr"
tiêu chuẩn ở Chế độ 0. Tiêu chuẩn đó chỉ định giao thức sau::

gửi tiêu đề nibble '0x8'
   octet đếm thấp
   octet đếm cao
   ... data octets
tổng kiểm tra octet

Mỗi octet được gửi dưới dạng::

<chờ rx. '0x1?'> <gửi 0x10+(octet&0x0F)>
	<chờ rx. '0x0?'> <gửi 0x00+((octet>>4)&0x0F)>

Để bắt đầu truyền, máy phát sẽ xuất ra một nibble 0x08.
Điều đó làm tăng dòng ACK, gây ra sự gián đoạn trong quá trình nhận
máy.  Máy nhận vô hiệu hóa các ngắt và tăng ACK của chính nó
dòng.

Đã trình bày lại::

(OUT là bit 0-4, OUT.j là bit j từ OUT. IN tương tự)
  Gửi_Byte:
     OUT := ngòi thấp, OUT.4 := 1
     WAIT FOR TRONG.4 = 1
     OUT := ngòi cao, OUT.4 := 0
     WAIT FOR TRONG.4 = 0