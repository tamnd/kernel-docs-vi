.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/elantech.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển bàn di chuột Elantech
========================

Bản quyền (C) 2007-2008 Arjan Opmeer <arjan@opmeer.net>

Thông tin bổ sung cho phiên bản phần cứng 1 được tìm thấy và
	được cung cấp bởi Steve Havelka

Hỗ trợ phần cứng phiên bản 2 (EeePC) dựa trên các bản vá
	nhận được từ Woody ở Xandros và chuyển tiếp cho tôi
	bởi người dùng StewieGriffin tại diễn đàn eeeuser.com

.. Contents

 1. Introduction
 2. Extra knobs
 3. Differentiating hardware versions
 4. Hardware version 1
    4.1 Registers
    4.2 Native relative mode 4 byte packet format
    4.3 Native absolute mode 4 byte packet format
 5. Hardware version 2
    5.1 Registers
    5.2 Native absolute mode 6 byte packet format
        5.2.1 Parity checking and packet re-synchronization
        5.2.2 One/Three finger touch
        5.2.3 Two finger touch
 6. Hardware version 3
    6.1 Registers
    6.2 Native absolute mode 6 byte packet format
        6.2.1 One/Three finger touch
        6.2.2 Two finger touch
 7. Hardware version 4
    7.1 Registers
    7.2 Native absolute mode 6 byte packet format
        7.2.1 Status packet
        7.2.2 Head packet
        7.2.3 Motion packet
 8. Trackpoint (for Hardware version 3 and 4)
    8.1 Registers
    8.2 Native relative mode 6 byte packet format
        8.2.1 Status Packet



Giới thiệu
~~~~~~~~~~~~

Hiện tại trình điều khiển bàn di chuột Linux Elantech nhận biết được bốn loại khác nhau
phiên bản phần cứng được gọi một cách không tưởng tượng là phiên bản 1, phiên bản 2, phiên bản 3
và phiên bản 4. Phiên bản 1 được tìm thấy trong các máy tính xách tay "cũ" hơn và sử dụng 4 byte cho mỗi
gói. Phiên bản 2 dường như được giới thiệu với EeePC và sử dụng 6 byte
mỗi gói và cung cấp các tính năng bổ sung như vị trí của hai ngón tay,
và chiều rộng của cảm ứng.  Phiên bản phần cứng 3 sử dụng 6 byte cho mỗi gói (và
cho 2 ngón tay nối hai gói 6 byte) và cho phép theo dõi
lên tới 3 ngón tay. Phiên bản phần cứng 4 sử dụng 6 byte cho mỗi gói và có thể
kết hợp một gói trạng thái với nhiều gói đầu hoặc gói chuyển động. Phiên bản phần cứng
4 cho phép theo dõi tối đa 5 ngón tay.

Một số Phần cứng phiên bản 3 và phiên bản 4 cũng có trackpoint sử dụng
dạng gói riêng biệt. Nó cũng là 6 byte cho mỗi gói.

Trình điều khiển cố gắng hỗ trợ cả hai phiên bản phần cứng và phải tương thích
với trình điều khiển bàn di chuột Xorg Synaptics và cấu hình đồ họa của nó
tiện ích.

Lưu ý rằng nút chuột cũng được liên kết với bàn di chuột hoặc bàn di chuột.
trackpoint khi có trackpoint.  Vô hiệu hóa Touchpad trong xorg
(TouchPadOff=0) cũng sẽ tắt các nút liên kết với bàn di chuột.

Ngoài ra, hoạt động của bàn di chuột có thể được thay đổi bằng cách điều chỉnh
nội dung của một số thanh ghi nội bộ của nó. Các thanh ghi này được biểu diễn
bởi trình điều khiển dưới dạng các mục nhập sysfs trong /sys/bus/serio/drivers/psmouse/serio?
có thể được đọc và ghi vào.

Hiện tại chỉ có các thanh ghi cho phiên bản phần cứng 1 mới được hiểu phần nào.
Phiên bản phần cứng 2 dường như sử dụng một số thanh ghi tương tự nhưng thực tế không phải vậy.
biết liệu các bit trong thanh ghi có đại diện cho cùng một thứ hay không hoặc có thể
đã thay đổi ý nghĩa của chúng.

Ngoài ra, một số cài đặt đăng ký chỉ có hiệu lực khi bàn di chuột được bật.
ở chế độ tương đối và không ở chế độ tuyệt đối. Như bàn di chuột Linux Elantech
driver luôn đặt phần cứng ở chế độ tuyệt đối chứ không phải tất cả thông tin
được đề cập dưới đây có thể được sử dụng ngay lập tức. Nhưng vì không có tự do
tài liệu Elantech có sẵn, thông tin vẫn được cung cấp ở đây cho
vì sự trọn vẹn.


Núm phụ
~~~~~~~~~~~

Hiện tại trình điều khiển bàn di chuột Linux Elantech cung cấp thêm ba nút bấm bên dưới
/sys/bus/serio/drivers/psmouse/serio? cho người dùng.

* gỡ lỗi

BẬT các cấp độ gỡ lỗi khác nhau hoặc OFF.

Bằng cách lặp lại "0" cho tệp này, tất cả việc gỡ lỗi sẽ được chuyển sang OFF.

Hiện tại giá trị "1" sẽ bật một số lỗi cơ bản và giá trị của
   "2" sẽ bật gỡ lỗi gói. Đối với phiên bản phần cứng 1, mặc định là
   OFF. Đối với phiên bản 2, mặc định là "1".

Bật gỡ lỗi gói sẽ khiến trình điều khiển kết xuất mọi gói
   nhận được vào nhật ký hệ thống trước khi xử lý nó. Được cảnh báo rằng điều này có thể
   tạo ra khá nhiều dữ liệu!

* kiểm tra tính chẵn lẻ

BẬT kiểm tra chẵn lẻ hoặc OFF.

Bằng cách lặp lại "0" cho tệp này, việc kiểm tra tính chẵn lẻ sẽ được chuyển thành OFF. bất kỳ
   giá trị khác 0 sẽ BẬT nó. Đối với phiên bản phần cứng 1, mặc định là BẬT.
   Đối với phiên bản 2, mặc định là OFF.

Phiên bản phần cứng 1 cung cấp khả năng xác minh tính toàn vẹn dữ liệu cơ bản bằng cách
   tính toán bit chẵn lẻ cho 3 byte cuối cùng của mỗi gói. Người lái xe
   có thể kiểm tra các bit này và từ chối bất kỳ gói nào có vẻ bị lỗi. sử dụng
   núm này bạn có thể bỏ qua việc kiểm tra đó.

Phiên bản phần cứng 2 không cung cấp các bit chẵn lẻ giống nhau. Chỉ một số cơ bản
   kiểm tra tính nhất quán dữ liệu có thể được thực hiện. Hiện tại việc kiểm tra bị vô hiệu hóa bởi
   mặc định. Hiện tại ngay cả việc bật nó lên cũng không làm gì cả.

* crc_enabled

Đặt crc_enabled thành 0/1. Tên "crc_enabled" là tên chính thức của
   kiểm tra tính toàn vẹn này, mặc dù nó không phải là sự dư thừa theo chu kỳ thực tế
   kiểm tra.

Tùy thuộc vào trạng thái của crc_enabled, tính toàn vẹn dữ liệu cơ bản nhất định
   việc xác minh được thực hiện bởi trình điều khiển trên phiên bản phần cứng 3 và 4.
   trình điều khiển sẽ từ chối bất kỳ gói nào có vẻ bị hỏng. Sử dụng núm này,
   Trạng thái của crc_enabled có thể được thay đổi bằng núm này.

Đọc giá trị crc_enabled sẽ hiển thị giá trị đang hoạt động. Tiếng vang
   "0" hoặc "1" cho tệp này sẽ đặt trạng thái thành "0" hoặc "1".

Phân biệt phiên bản phần cứng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để phát hiện phiên bản phần cứng, hãy đọc số phiên bản dưới dạng param[0].param[1].param[2]::

Phiên bản 4 byte: (sau mũi tên là tên trong driver do Dell cung cấp)
 02.00.22 => EF013
 02.06.00 => EF019

Trong thực tế, dường như có nhiều phiên bản hơn, chẳng hạn như 00.01.64, 01.00.21,
02.00.00, 02.00.04, 02.00.06::

6 byte:
 02.00.30 => EF113
 02.08.00 => EF023
 02.08.XX => EF123
 02.0B.00 => EF215
 04.01.XX => Scroll_EF051
 04.02.XX => EF051

Trong thực tế, dường như có nhiều phiên bản hơn, chẳng hạn như 04.03.01, 04.04.11. Ở đó
dường như hầu như không có sự khác biệt, ngoại trừ EF113, không báo cáo
áp suất/chiều rộng và có các kiểm tra tính nhất quán dữ liệu khác nhau.

Có lẽ tất cả các phiên bản có param[0] <= 01 đều có thể được coi là
4 byte/chương trình cơ sở 1. Các phiên bản < 02.08.00, ngoại trừ 02.00.30, như
4 byte/chương trình cơ sở 2. Mọi thứ >= 02.08.00 có thể được coi là 6 byte.


Phiên bản phần cứng 1
~~~~~~~~~~~~~~~~~~

Đăng ký
---------

Bằng cách lặp lại một giá trị thập lục phân vào một thanh ghi, nội dung của nó có thể bị thay đổi.

Ví dụ::

echo -n 0x16 > reg_10

* reg_10::

bit 7 6 5 4 3 2 1 0
         B C T D L A S E

E: 1 = kích hoạt các cạnh thông minh vô điều kiện
         S: 1 = chỉ bật cạnh thông minh khi kéo
         A: 1 = chế độ tuyệt đối (cần gói 4 byte, xem reg_11)
         L: 1 = bật khóa kéo (xem reg_22)
         D: 1 = tắt độ phân giải động
         T: 1 = tắt tính năng chạm
         C: 1 = bật tính năng chạm vào góc
         B: 1 = hoán đổi nút trái và phải

* reg_11::

bit 7 6 5 4 3 2 1 0
         1 0 0 H V 1 F P

P: 1 = bật kiểm tra tính chẵn lẻ cho chế độ tương đối
         F: 1 = bật chế độ gói 4 byte gốc
         V: 1 = bật vùng cuộn dọc
         H: 1 = bật vùng cuộn ngang

* reg_20::

chiều rộng một ngón tay?

* reg_21::

chiều rộng vùng cuộn (nhỏ: 0x40 ... rộng: 0xff)

* reg_22::

kéo thời gian khóa ra (ngắn: 0x14 ... dài: 0xfe;
                             0xff = chạm lại để thả ra)

* reg_23::

nhấn làm cho thời gian chờ?

* reg_24::

hết thời gian phát hành nhấn?

* reg_25::

tốc độ con trỏ cạnh thông minh (0x02 = chậm, 0x03 = trung bình, 0x04 = nhanh)

* reg_26::

chiều rộng vùng kích hoạt cạnh thông minh?


Chế độ tương đối gốc Định dạng gói 4 byte
-----------------------------------------

byte 0::

bit 7 6 5 4 3 2 1 0
         c c p2 p1 1 M R L

L, R, M = 1 khi nhấn nút trái, phải, chuột giữa
            một số mô hình có M là bit chẵn lẻ byte 3
         khi kiểm tra tính chẵn lẻ được kích hoạt (reg_11, P = 1):
            p1..p2 = bit chẵn lẻ byte 1 và 2
         c = 1 khi phát hiện thấy thao tác chạm vào góc

byte 1::

bit 7 6 5 4 3 2 1 0
        dx7 dx6 dx5 dx4 dx3 dx2 dx1 dx0

dx7..dx0 = x chuyển động;   dương = phải, âm = trái
         byte 1 = 0xf0 khi phát hiện chạm vào góc

byte 2::

bit 7 6 5 4 3 2 1 0
        dy7 dy6 dy5 dy4 dy3 dy2 dy1 dy0

dy7..dy0 = chuyển động của y;   dương = lên, âm = xuống

byte 3::

đã bật kiểm tra tính chẵn lẻ (reg_11, P = 1):

bit 7 6 5 4 3 2 1 0
            w h n1 n0 ds3 ds2 ds1 ds0

thông thường:
               ds3..ds0 = số lượng và hướng bánh xe cuộn
                          dương = xuống hoặc sang trái
                          âm = lên hoặc phải
            khi phát hiện thấy thao tác chạm vào góc:
               ds0 = 1 khi chạm vào góc trên bên phải
               ds1 = 1 khi chạm vào góc dưới bên phải
               ds2 = 1 khi chạm vào góc dưới bên trái
               ds3 = 1 khi chạm vào góc trên bên trái
            n1..n0 = số ngón tay trên bàn di chuột
               chỉ những mẫu có phần sụn 2.x mới báo cáo điều này, những mẫu có
               firmware 1.x dường như ánh xạ các thao tác chạm một, hai và ba ngón tay
               trực tiếp tới các nút chuột L, M và R
            h = 1 khi thực hiện thao tác cuộn ngang
            w = 1 khi chạm ngón tay rộng?

mặt khác (reg_11, P = 0):

bit 7 6 5 4 3 2 1 0
           ds7 ds6 ds5 ds4 ds3 ds2 ds1 ds0

ds7..ds0 = số lượng và hướng cuộn dọc
                       tiêu cực = lên
                       tích cực = giảm


Chế độ tuyệt đối gốc Định dạng gói 4 byte
-----------------------------------------

EF013 và EF019 có hành vi đặc biệt (do lỗi trong phần sụn?) và
khi 1 ngón tay chạm vào thì phải loại bỏ 2 báo cáo vị trí đầu tiên.
Việc đếm này được đặt lại bất cứ khi nào có số ngón tay khác được báo cáo.

byte 0::

phiên bản phần sụn 1.x:

bit 7 6 5 4 3 2 1 0
            D U p1 p2 1 p3 R L

L, R = 1 khi nhấn chuột trái, chuột phải
            p1..p3 = byte 1..3 bit chẵn lẻ lẻ
            D, U = 1 khi nhấn công tắc điều khiển Lên, Xuống

phiên bản phần sụn 2.x:

bit 7 6 5 4 3 2 1 0
           n1 n0 p2 p1 1 p3 R L

L, R = 1 khi nhấn chuột trái, chuột phải
            p1..p3 = byte 1..3 bit chẵn lẻ lẻ
            n1..n0 = số ngón tay trên bàn di chuột

byte 1::

phiên bản phần sụn 1.x:

bit 7 6 5 4 3 2 1 0
            f 0 th tw x9 x8 y9 y8

tw = 1 khi hai ngón tay chạm nhau
            th = 1 khi chạm 3 ngón tay
            f = 1 khi chạm ngón tay

phiên bản phần sụn 2.x:

bit 7 6 5 4 3 2 1 0
            .   .   .   .  x9 x8 y9 y8

byte 2::

bit 7 6 5 4 3 2 1 0
        x7 x6 x5 x4 x3 x2 x1 x0

x9..x0 = giá trị x tuyệt đối (ngang)

byte 3::

bit 7 6 5 4 3 2 1 0
        y7 y6 y5 y4 y3 y2 y1 y0

y9..y0 = giá trị y tuyệt đối (dọc)


Phiên bản phần cứng 2
~~~~~~~~~~~~~~~~~~


Đăng ký
---------

Bằng cách lặp lại một giá trị thập lục phân vào một thanh ghi, nội dung của nó có thể bị thay đổi.

Ví dụ::

echo -n 0x56 > reg_10

* reg_10::

bit 7 6 5 4 3 2 1 0
         0 1 0 1 0 1 D 0

D: 1 = cho phép kéo và thả

* reg_11::

bit 7 6 5 4 3 2 1 0
         1 0 0 0 S 0 1 0

S: 1 = bật cuộn dọc

* reg_21::

không xác định (0x00)

* reg_22::

kéo và thả hết thời gian nhả (ngắn: 0x70 ... dài 0x7e;
                                   0x7f = không bao giờ, tức là nhấn lại để nhả)


Chế độ tuyệt đối gốc Định dạng gói 6 byte
-----------------------------------------

Kiểm tra chẵn lẻ và đồng bộ lại gói
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Không có kiểm tra tính chẵn lẻ, tuy nhiên một số kiểm tra tính nhất quán có thể được thực hiện.

Ví dụ cho EF113::

SA1= gói [0];
        A1 = gói [1];
        B1 = gói [2];
        SB1= gói [3];
        C1 = gói [4];
        D1 = gói [5];
        if( (((SA1 & 0x3C) != 0x3C) && ((SA1 & 0xC0) != 0x80)) || // kiểm tra Byte 1
            (((SA1 & 0x0C) != 0x0C) && ((SA1 & 0xC0) == 0x80)) || // kiểm tra Byte 1 (nhấn một ngón tay)
            (((SA1 & 0xC0) != 0x80) && (( A1 & 0xF0) != 0x00)) || // kiểm tra Byte 2
            (((SB1 & 0x3E) != 0x38) && ((SA1 & 0xC0) != 0x80)) || // kiểm tra Byte 4
            (((SB1 & 0x0E) != 0x08) && ((SA1 & 0xC0) == 0x80)) || // kiểm tra Byte 4 (nhấn một ngón tay)
            (((SA1 & 0xC0) != 0x80) && (( C1 & 0xF0) != 0x00)) ) // kiểm tra Byte 5
		// phát hiện lỗi

Đối với tất cả những cái khác, chỉ có một vài bit không đổi ::

if( ((gói[0] & 0x0C) != 0x04) ||
            ((gói[3] & 0x0f) != 0x02) )
		// phát hiện lỗi


Trong trường hợp phát hiện lỗi, tất cả các gói sẽ được dịch chuyển một (và gói [0] sẽ bị loại bỏ).

Chạm một/ba ngón tay
^^^^^^^^^^^^^^^^^^^^^^

byte 0::

bit 7 6 5 4 3 2 1 0
	 n1 n0 w3 w2 .   .   RL

L, R = 1 khi nhấn chuột trái, chuột phải
         n1..n0 = số ngón tay trên bàn di chuột

byte 1::

bit 7 6 5 4 3 2 1 0
	 p7 p6 p5 p4 x11 x10 x9 x8

byte 2::

bit 7 6 5 4 3 2 1 0
	 x7 x6 x5 x4 x3 x2 x1 x0

x11..x0 = giá trị x tuyệt đối (ngang)

byte 3::

bit 7 6 5 4 3 2 1 0
	 n4 vf w1 w0 .   .   .  b2

n4 = đặt nếu có nhiều hơn 3 ngón tay (chỉ ở chế độ 3 ngón tay)
	 vf = một loại cờ? (chỉ trên EF123, 0 khi ngón tay ở trên một
	      trong số các nút, 1 nếu không)
	 w3..w0 = chiều rộng của ngón tay chạm (không phải EF113)
	 b2 (chỉ trên EF113, 0 nếu không), b2.R.L biểu thị một nút được nhấn:
		0 = không
		1 = Trái
		2 = Đúng
		3 = Giữa (Trái và Phải)
		4 = Chuyển tiếp
		5 = Quay lại
		6 = Một cái khác
		7 = Một cái khác

byte 4::

bit 7 6 5 4 3 2 1 0
        p3 p1 p2 p0 y11 y10 y9 y8

p7..p0 = áp suất (không phải EF113)

byte 5::

bit 7 6 5 4 3 2 1 0
        y7 y6 y5 y4 y3 y2 y1 y0

y11..y0 = giá trị y tuyệt đối (dọc)


Chạm hai ngón tay
^^^^^^^^^^^^^^^^

Lưu ý rằng hai cặp tọa độ không chính xác là tọa độ của
hai ngón tay, nhưng chỉ có cặp tọa độ phía dưới bên trái và phía trên bên phải.
Vì vậy, các ngón tay thực tế có thể nằm trên đường chéo khác của hình vuông
được xác định bởi hai điểm này.

byte 0::

bit 7 6 5 4 3 2 1 0
        n1 n0 ay8 ax8 .   .   RL

L, R = 1 khi nhấn chuột trái, chuột phải
         n1..n0 = số ngón tay trên bàn di chuột

byte 1::

bit 7 6 5 4 3 2 1 0
        ax7 ax6 ax5 ax4 ax3 ax2 ax1 ax0

ax8..ax0 = giá trị x tuyệt đối của ngón tay dưới bên trái

byte 2::

bit 7 6 5 4 3 2 1 0
        ay7 ay6 ay5 ay4 ay3 ay2 ay1 ay0

ay8..ay0 = giá trị y tuyệt đối của ngón tay dưới bên trái

byte 3::

bit 7 6 5 4 3 2 1 0
         .   .  bởi8 bx8 .   .   .   .

byte 4::

bit 7 6 5 4 3 2 1 0
        bx7 bx6 bx5 bx4 bx3 bx2 bx1 bx0

bx8..bx0 = giá trị x tuyệt đối của ngón tay trên bên phải

byte 5::

bit 7 6 5 4 3 2 1 0
        by7 by8 by5 by4 by3 by2 by1 by0

by8..by0 = giá trị y tuyệt đối của ngón tay trên bên phải

Phiên bản phần cứng 3
~~~~~~~~~~~~~~~~~~

Đăng ký
---------

* reg_10::

bit 7 6 5 4 3 2 1 0
         0 0 0 0 R F T A

A: 1 = bật theo dõi tuyệt đối
         T: 1 = bật chế độ hai ngón tay tự động sửa
         F: 1 = tắt Bộ lọc vị trí ABS
         R: 1 = bật độ phân giải phần cứng thực

Chế độ tuyệt đối gốc Định dạng gói 6 byte
-----------------------------------------

Chạm bằng 1 và 3 ngón tay có chung định dạng gói 6 byte, ngoại trừ điều đó
Chạm 3 ngón tay chỉ báo vị trí tâm của cả 3 ngón tay.

Phần sụn sẽ gửi 12 byte dữ liệu cho 2 lần chạm ngón tay.

Lưu ý khi gỡ lỗi:
Trong trường hợp hộp có nguồn điện không ổn định hoặc các sự cố về điện khác, hoặc
khi số lượng ngón tay thay đổi, F/W sẽ gửi "gói gỡ lỗi" để thông báo
trình điều khiển rằng phần cứng đang ở trạng thái gỡ lỗi.
Gói gỡ lỗi có chữ ký sau::

byte 0: 0xc4
    byte 1: 0xff
    byte 2: 0xff
    byte 3: 0x02
    byte 4: 0xff
    byte 5: 0xff

Khi gặp loại gói tin này, chúng tôi chỉ cần bỏ qua nó.

Chạm một/ba ngón tay
^^^^^^^^^^^^^^^^^^^^^^

byte 0::

bit 7 6 5 4 3 2 1 0
        n1 n0 w3 w2 0 1 R L

L, R = 1 khi nhấn chuột trái, chuột phải
        n1..n0 = số ngón tay trên bàn di chuột

byte 1::

bit 7 6 5 4 3 2 1 0
        p7 p6 p5 p4 x11 x10 x9 x8

byte 2::

bit 7 6 5 4 3 2 1 0
        x7 x6 x5 x4 x3 x2 x1 x0

x11..x0 = giá trị x tuyệt đối (ngang)

byte 3::

bit 7 6 5 4 3 2 1 0
         0 0 w1 w0 0 0 1 0

w3..w0 = chiều rộng của ngón tay chạm

byte 4::

bit 7 6 5 4 3 2 1 0
        p3 p1 p2 p0 y11 y10 y9 y8

p7..p0 = áp suất

byte 5::

bit 7 6 5 4 3 2 1 0
        y7 y6 y5 y4 y3 y2 y1 y0

y11..y0 = giá trị y tuyệt đối (dọc)

Chạm hai ngón tay
^^^^^^^^^^^^^^^^

Định dạng gói hoàn toàn giống nhau khi chạm bằng hai ngón tay, ngoại trừ phần cứng
gửi hai gói 6 byte. Gói đầu tiên chứa dữ liệu cho ngón tay đầu tiên,
gói thứ hai có dữ liệu cho ngón tay thứ hai. Vì vậy, để hai ngón tay chạm vào một
tổng cộng 12 byte được gửi.

Phiên bản phần cứng 4
~~~~~~~~~~~~~~~~~~

Đăng ký
---------

* reg_07::

bit 7 6 5 4 3 2 1 0
         0 0 0 0 0 0 0 A

A: 1 = bật theo dõi tuyệt đối

Chế độ tuyệt đối gốc Định dạng gói 6 byte
-----------------------------------------

Phần cứng v4 là một bàn di chuột cảm ứng đa điểm đích thực, có khả năng theo dõi tới 5 ngón tay.
Thật không may, do băng thông hạn chế của PS/2 nên định dạng gói của nó khá khó khăn.
phức tạp.

Bất cứ khi nào số lượng hoặc nhận dạng của các ngón tay thay đổi, phần cứng sẽ gửi một thông báo
gói trạng thái để cho biết có bao nhiêu và ngón tay nào đang ở trên bàn di chuột, sau đó là
gói đầu hoặc gói chuyển động. Gói đầu chứa dữ liệu id ngón tay, ngón tay
vị trí (giá trị tuyệt đối x, y), chiều rộng và áp suất. Một gói chuyển động chứa
vị trí delta của hai ngón tay.

Ví dụ: khi gói trạng thái thông báo có 2 ngón tay trên bàn di chuột thì chúng tôi
có thể mong đợi hai gói đầu sau. Nếu trạng thái ngón tay không thay đổi,
các gói sau đây sẽ là gói chuyển động, chỉ gửi delta của ngón tay
vị trí, cho đến khi chúng tôi nhận được một gói trạng thái.

Một ngoại lệ là chạm một ngón tay. khi một gói trạng thái cho chúng ta biết chỉ có
một ngón tay, phần cứng sẽ chỉ gửi các gói đầu sau đó.

Gói trạng thái
^^^^^^^^^^^^^

byte 0::

bit 7 6 5 4 3 2 1 0
         .   .   .   .   0 1 R L

L, R = 1 khi nhấn chuột trái, chuột phải

byte 1::

bit 7 6 5 4 3 2 1 0
         .   .   . ft4 ft3 ft2 ft1 ft0

ft4 ft3 ft2 ft1 ft0 ftn = 1 khi ngón tay n ở trên bàn di chuột

byte 2::

không được sử dụng

byte 3::

bit 7 6 5 4 3 2 1 0
         .   .   .   1 0 0 0 0

bit không đổi

byte 4::

bit 7 6 5 4 3 2 1 0
         p.   .   .   .   .   .   .

p = 1 cho lòng bàn tay

byte 5::

không được sử dụng

Gói đầu
^^^^^^^^^^^

byte 0::

bit 7 6 5 4 3 2 1 0
        w3 w2 w1 w0 0 1 R L

L, R = 1 khi nhấn chuột trái, chuột phải
        w3..w0 = chiều rộng ngón tay (kéo dài bao nhiêu đường)

byte 1::

bit 7 6 5 4 3 2 1 0
        p7 p6 p5 p4 x11 x10 x9 x8

byte 2::

bit 7 6 5 4 3 2 1 0
        x7 x6 x5 x4 x3 x2 x1 x0

x11..x0 = giá trị x tuyệt đối (ngang)

byte 3::

bit 7 6 5 4 3 2 1 0
       id2 id1 id0 1 0 0 0 1

id2..id0 = id ngón tay

byte 4::

bit 7 6 5 4 3 2 1 0
        p3 p1 p2 p0 y11 y10 y9 y8

p7..p0 = áp suất

byte 5::

bit 7 6 5 4 3 2 1 0
        y7 y6 y5 y4 y3 y2 y1 y0

y11..y0 = giá trị y tuyệt đối (dọc)

Gói chuyển động
^^^^^^^^^^^^^

byte 0::

bit 7 6 5 4 3 2 1 0
       id2 id1 id0 w 0 1 R L

L, R = 1 khi nhấn chuột trái, chuột phải
       id2..id0 = id ngón tay
       w = 1 khi delta tràn (> 127 hoặc < -128), trong trường hợp này
       chương trình cơ sở gửi cho chúng tôi (delta x / 5) và (delta y / 5)

byte 1::

bit 7 6 5 4 3 2 1 0
        x7 x6 x5 x4 x3 x2 x1 x0

x7..x0 = delta x (bù hai)

byte 2::

bit 7 6 5 4 3 2 1 0
        y7 y6 y5 y4 y3 y2 y1 y0

y7..y0 = delta y (bù hai)

byte 3::

bit 7 6 5 4 3 2 1 0
       id2 id1 id0 1 0 0 1 0

id2..id0 = id ngón tay

byte 4::

bit 7 6 5 4 3 2 1 0
        x7 x6 x5 x4 x3 x2 x1 x0

x7..x0 = delta x (bù hai)

byte 5::

bit 7 6 5 4 3 2 1 0
        y7 y6 y5 y4 y3 y2 y1 y0

y7..y0 = delta y (bù hai)

byte 0 ~ 2 cho một ngón tay
        byte 3 ~ 5 cho cái khác


Trackpoint (dành cho phiên bản Phần cứng 3 và 4)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đăng ký
---------

Không có sổ đăng ký đặc biệt đã được xác định.

Chế độ tương đối gốc Định dạng gói 6 byte
-----------------------------------------

Gói trạng thái
^^^^^^^^^^^^^

byte 0::

bit 7 6 5 4 3 2 1 0
         0 0 sx sy 0 M R L

byte 1::

bit 7 6 5 4 3 2 1 0
       ~sx 0 0 0 0 0 0 0

byte 2::

bit 7 6 5 4 3 2 1 0
       ~sy 0 0 0 0 0 0 0

byte 3::

bit 7 6 5 4 3 2 1 0
         0 0 ~sy ~sx 0 1 1 0

byte 4::

bit 7 6 5 4 3 2 1 0
        x7 x6 x5 x4 x3 x2 x1 x0

byte 5::

bit 7 6 5 4 3 2 1 0
        y7 y6 y5 y4 y3 y2 y1 y0


x và y được viết dưới dạng chênh lệch hai
             trên 9 bit với sx/sy là bit trên cùng tương đối và
             x7..x0 và y7..y0 các bit thấp hơn.
	 ~sx là nghịch đảo của sx, ~sy là nghịch đảo của sy.
         Dấu của y ngược với những gì trình điều khiển đầu vào
             mong đợi một chuyển động tương đối
