.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/m68k/buddha-driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Trình điều khiển Phật Amiga và Catweasel IDE
=====================================

Trình điều khiển Amiga Buddha và Catweasel IDE (một phần của ide.c) được viết bởi
Geert Uytterhoeven dựa trên các thông số kỹ thuật sau:

-------------------------------------------------------------------------

Đăng ký bản đồ của bộ điều khiển Buddha IDE và
Phần phật của phiên bản Catweasel Zorro-II

Tính năng Tự động cấu hình đã được triển khai giống như Commodore
được mô tả trong sách hướng dẫn của họ, không có thủ thuật nào được sử dụng (đối với
ví dụ bỏ một số dòng địa chỉ ra khỏi phương trình...).
Nếu bạn muốn tự mình cấu hình bảng (ví dụ:
nhân Linux cấu hình thẻ), hãy xem Commodore
Tài liệu.  Đọc nibbles sẽ cung cấp thông tin này::

Số nhà cung cấp: 4626 ($1212)
  Mã sản phẩm: 0 (42 cho Catweasel Z-II)
  Số sê-ri: 0
  Rom-vector: $1000

Card phải là board Z-II, size 64K, không phải freemem
danh sách, Rom-Vektor hợp lệ, không có bảng Autoconfig thứ hai trên
cùng một thẻ, không có tùy chọn khoảng trống, hỗ trợ "Shutup_forever".

Việc đặt địa chỉ cơ sở phải được thực hiện theo hai bước, chỉ cần
như Amiga Kickstart đã làm: Phần dưới của 8-Bit
địa chỉ được ghi vào $4a, sau đó toàn bộ Byte được ghi vào
$48, trong khi tần suất bạn viết thư cho $4a không quan trọng
miễn là $48 không được chạm tới.  Sau khi $48 được viết,
toàn bộ thẻ biến mất khỏi $e8 và được ánh xạ tới thẻ mới
địa chỉ vừa viết.  Đảm bảo $4a được viết trước $48,
nếu không thì cơ hội của bạn chỉ là 1:16 để tìm thấy bảng :-).

Bản đồ bộ nhớ cục bộ thậm chí còn hoạt động khi được ánh xạ tới $e8:

=============================================================
$0-$7e Autokonfig-space, xem tài liệu Z-II.

đặt trước $80-$7fd

$7fe Đăng ký chọn tốc độ: Đọc & Viết
		(mô tả xem thêm bên dưới)

$800-$8ff IDE-Chọn 0 (Cổng 0, Bộ đăng ký 0)

$900-$9ff IDE-Chọn 1 (Cổng 0, Bộ đăng ký 1)

$a00-$aff IDE-Select 2 (Cổng 1, Bộ thanh ghi 0)

$b00-$bff IDE-Chọn 3 (Cổng 1, Bộ thanh ghi 1)

$c00-$cff IDE-Chọn 4 (Cổng 2, Bộ đăng ký 0,
                Chỉ dành cho chồn mèo!)

$d00-$dff IDE-Select 5 (Cổng 3, Bộ thanh ghi 1,
		Chỉ dành cho chồn mèo!)

Cổng mở rộng cục bộ $e00-$eff, trên Catweasel Z-II
		Sổ đăng ký Catweasel cũng được ánh xạ ở đây.
		Không bao giờ chạm vào, hãy sử dụng multidisk.device!

$f00 chỉ đọc, Truy cập byte: Bit 7 hiển thị
		cấp độ của dòng IRQ của cổng IDE 0.

$f01-$f3f gương của $f00

$f40 chỉ đọc, Truy cập byte: Bit 7 hiển thị
		cấp độ của dòng IRQ của cổng IDE 1.

$f41-$f7f gương của $f40

$f80 chỉ đọc, Truy cập byte: Bit 7 hiển thị
		cấp độ của dòng IRQ của cổng IDE 2.
		(Chỉ dành cho chồn mèo!)

$f81-$fbf gương của $f80

$fc0 chỉ ghi: Viết bất kỳ giá trị nào vào đây
		thanh ghi cho phép các IRQ được chuyển từ
		Cổng IDE tới xe buýt Zorro. Cơ chế này
		đã được triển khai để tương thích với
		đĩa cứng bị lỗi hoặc có
		một chương trình cơ sở bị lỗi và kéo dòng IRQ lên
		trong khi khởi động. Nếu ngắt sẽ
		luôn được chuyển tới xe buýt, máy tính
		có thể không khởi động được. Sau khi được bật, cờ này
		không thể bị vô hiệu hóa một lần nữa. Mức độ của
		cờ không thể được xác định bằng phần mềm
		(để làm gì? Hãy viết thư cho tôi nếu cần thiết!).

$fc1-$fff phản chiếu của $fc0

$1000-$ffff Buddha-Rom có bù $1000 trong rom
		chip. Các địa chỉ từ $0 đến $fff của rom
		chip không thể đọc được. Rom rộng Byte và
		được ánh xạ tới các địa chỉ chẵn.
=============================================================

Các cổng IDE phát hành INT2.  Bạn có thể đọc mức độ của
Các dòng IRQ của cổng IDE bằng cách đọc từ ba (hai
chỉ dành cho Phật) đăng ký $f00, $f40 và $f80.  Lối này
nhiều yêu cầu I/O có thể được xử lý và bạn có thể dễ dàng
xác định trình điều khiển nào phải phục vụ INT2.  Đức Phật và
Bo mạch mở rộng Catweasel có thể phát ra INT6.  riêng biệt
bản đồ bộ nhớ có sẵn cho mô-đun I/O và hệ thống quản lý
Mô-đun vào/ra.

Các cổng IDE được cung cấp bởi các dòng địa chỉ A2 đến A4, giống như
có cổng Amiga 1200 và Amiga 4000 IDE.  Lối này
trình điều khiển hiện có có thể dễ dàng được chuyển sang Buddha.  Một động thái.l
thăm dò hai từ trong cùng một địa chỉ của cổng IDE kể từ
mỗi từ được phản ánh một lần.  chuyển động là không thể, nhưng
điều đó cũng không cần thiết vì bạn chỉ có thể tăng tốc
68000 hệ thống có kỹ thuật này.   Một hệ thống 68020 với
fastmem nhanh hơn với move.l.

Nếu bạn đang sử dụng các thanh ghi được phản chiếu của các cổng IDE với
A6=1, Đức Phật không quan tâm đến tốc độ mà bạn có
được chọn trong thanh ghi tốc độ (xem thêm bên dưới).  Với
A6=1 (ví dụ: $840 cho cổng 0, bộ thanh ghi 0), 780ns
truy cập đang được thực hiện.  Những thanh ghi này nên được sử dụng cho một
lệnh truy cập vào đĩa cứng/CD-Rom, vì lệnh
quyền truy cập có dung lượng byte rộng và phải được thực hiện chậm hơn tùy theo
vào hướng dẫn sử dụng ATA-X3T9.

Bây giờ đối với thanh ghi tốc độ: Thanh ghi có độ rộng byte và
chỉ có ba bit trên được sử dụng (Bit 7 đến 5).  Bit 4
phải luôn được đặt là 1 để tương thích với Phật sau này
phiên bản này (nếu tôi cập nhật phiên bản này).  Tôi đoán rằng
Tôi sẽ không bao giờ sử dụng bốn bit thấp hơn, nhưng chúng phải được đặt
đến 1 theo định nghĩa.

Các giá trị trong bảng này phải được dịch chuyển 5 bit sang
left và or'd với $1f (điều này đặt 5 bit thấp hơn).

Tất cả các thời gian đều có điểm chung: Chọn và IOR/IOW tăng ở mức
cùng một lúc.   IOR và IOW có độ trễ truyền sóng là
khoảng 30ns so với đồng hồ trên xe buýt Zorro, đó là lý do tại sao
các giá trị không phải là bội số của 71. Một chu kỳ xung nhịp dài 71ns
(chính xác là 70,5 ở 14,18 Mhz trên hệ thống PAL).

giá trị 0 (Mặc định sau khi đặt lại)
  497ns Chọn (7 chu kỳ xung nhịp), IOR/IOW sau 172ns (2 chu kỳ xung nhịp)
  (cùng thời gian với Amiga 1200 trên cổng IDE mà không có
  thẻ tăng tốc)

giá trị 1
  639ns Chọn (9 chu kỳ xung nhịp), IOR/IOW sau 243ns (3 chu kỳ xung nhịp)

giá trị 2
  781ns Chọn (11 chu kỳ xung nhịp), IOR/IOW sau 314ns (4 chu kỳ xung nhịp)

giá trị 3
  355ns Chọn (5 chu kỳ xung nhịp), IOR/IOW sau 101ns (1 chu kỳ xung nhịp)

giá trị 4
  355ns Chọn (5 chu kỳ xung nhịp), IOR/IOW sau 172ns (2 chu kỳ xung nhịp)

giá trị 5
  355ns Chọn (5 chu kỳ xung nhịp), IOR/IOW sau 243ns (3 chu kỳ xung nhịp)

giá trị 6
  1065ns Chọn (15 chu kỳ xung nhịp), IOR/IOW sau 314ns (4 chu kỳ xung nhịp)

giá trị 7
  355ns Chọn, (5 chu kỳ xung nhịp), IOR/IOW sau 101ns (1 chu kỳ xung nhịp)

Khi truy cập các thanh ghi IDE với A6=1 (ví dụ $84x),
thời gian sẽ luôn ở chế độ 0, tương thích 8 bit, bất kể
những gì bạn đã chọn trong thanh ghi tốc độ:

Chọn 781ns, IOR/IOW sau 4 chu kỳ xung nhịp (=314ns) hoạt động.

Tất cả các thời gian có tín hiệu chọn rất ngắn (355ns
truy cập nhanh) tùy thuộc vào thẻ tăng tốc được sử dụng trong
hệ thống: Đôi khi hai chu kỳ đồng hồ nữa được chèn vào bởi
giao diện bus, làm cho toàn bộ truy cập dài 497ns.  Cái này
không ảnh hưởng đến độ tin cậy của bộ điều khiển cũng như
hiệu suất của thẻ, vì điều này không xảy ra nhiều
thường xuyên.

Tất cả thời gian được tính toán và chỉ được xác nhận bởi
phép đo cho phép tôi đếm chu kỳ đồng hồ.  Nếu
hệ thống được điều khiển bởi một bộ dao động khác ngoài 28.37516
Mhz (ví dụ: tần số NTSC 28,63636 Mhz), mỗi
chu kỳ đồng hồ được rút ngắn xuống dưới 70ns một chút (không đáng
đề cập).   Bạn có thể nghĩ đến việc tăng hiệu suất nhỏ
bằng cách ép xung hệ thống, nhưng bạn sẽ cần một
màn hình đa đồng bộ hoặc card đồ họa và nội bộ của bạn
ổ đĩa sẽ phát điên, đó là lý do tại sao bạn không nên điều chỉnh
Amiga lối này.

Cung cấp cho bạn khả năng viết phần mềm
tương thích với cả Đức Phật và Catweasel Z-II, The
Đức Phật hành động giống như Catweasel Z-II không có thiết bị
được kết nối với cổng IDE thứ ba.   Đăng ký IRQ $f80
luôn hiển thị "không có IRQ ở đây" trên Đức Phật và truy cập vào
cổng IDE thứ ba sẽ đi vào Nirwana của dữ liệu trên
Phật.

Jens Schönfeld ngày 19 tháng 2 năm 1997

cập nhật ngày 27 tháng 5 năm 1997

Email: sysop@nostlgic.tng.oche.de
