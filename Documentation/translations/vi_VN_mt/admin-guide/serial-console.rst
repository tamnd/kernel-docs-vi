.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/serial-console.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _serial_console:

Bảng điều khiển nối tiếp Linux
====================

Để sử dụng cổng nối tiếp làm bảng điều khiển, bạn cần biên dịch hỗ trợ vào
kernel - theo mặc định, nó không được biên dịch. Đối với các cổng nối tiếp kiểu PC
đó là tùy chọn cấu hình bên cạnh tùy chọn menu:

ZZ0000ZZ

Bạn phải biên dịch hỗ trợ nối tiếp vào kernel chứ không phải dưới dạng mô-đun.

Có thể chỉ định nhiều thiết bị cho đầu ra của bàn điều khiển. bạn có thể
xác định tùy chọn dòng lệnh kernel mới để chọn (các) thiết bị nào sẽ
sử dụng cho đầu ra giao diện điều khiển.

Định dạng của tùy chọn này là::

console=thiết bị,tùy chọn

thiết bị: tty0 cho bảng điều khiển ảo nền trước
			ttyX cho bất kỳ bảng điều khiển ảo nào khác
			ttySx cho một cổng nối tiếp
			lp0 cho cổng song song đầu tiên
			ttyUSB0 cho thiết bị nối tiếp USB đầu tiên

tùy chọn: phụ thuộc vào trình điều khiển. Đối với cổng nối tiếp, điều này
			định nghĩa điều khiển tốc độ baud/chẵn lẻ/bit/luồng của
			cổng, ở định dạng BBBBPNF, trong đó BBBB là
			tốc độ, P là tính chẵn lẻ (n/o/e), N là số bit,
			và F là điều khiển luồng ('r' cho RTS). Mặc định là
			9600n8. Tốc độ baud tối đa là 115200.

Bạn có thể chỉ định nhiều tùy chọn console= trên dòng lệnh kernel.

Hành vi được xác định rõ ràng khi mỗi loại thiết bị chỉ được đề cập một lần.
Trong trường hợp này, đầu ra sẽ xuất hiện trên tất cả các bảng điều khiển được yêu cầu. Và
thiết bị cuối cùng sẽ được sử dụng khi bạn mở ZZ0000ZZ.
Vì vậy, ví dụ::

bảng điều khiển=ttyS1,9600 bảng điều khiển=tty0

xác định rằng việc mở ZZ0000ZZ sẽ giúp bạn có được nền trước hiện tại
bảng điều khiển ảo và thông báo kernel sẽ xuất hiện trên cả VGA
bảng điều khiển và cổng nối tiếp thứ 2 (ttyS1 hoặc COM2) ở tốc độ 9600 baud.

Hành vi phức tạp hơn khi cùng một loại thiết bị được xác định nhiều hơn
lần. Trong trường hợp này, có hai quy tắc sau:

1. Đầu ra sẽ chỉ xuất hiện trên thiết bị đầu tiên của từng loại được xác định.

2. ZZ0000ZZ sẽ được liên kết với thiết bị đã đăng ký đầu tiên.
   Trường hợp thứ tự đăng ký phụ thuộc vào cách kernel khởi tạo các loại khác nhau
   các hệ thống con.

Quy tắc này cũng được sử dụng khi tham số console= cuối cùng không được sử dụng
   vì những lý do khác. Ví dụ: vì lỗi đánh máy hoặc vì
   phần cứng không có sẵn.

Kết quả có thể đáng ngạc nhiên. Ví dụ: hai lệnh sau
dòng có kết quả tương tự::

console=ttyS1,9600 console=tty0 console=tty1
	console=tty0 console=ttyS1,9600 console=tty1

Thông báo kernel chỉ được in trên ZZ0000ZZ và ZZ0001ZZ. Và
ZZ0002ZZ được liên kết với ZZ0003ZZ. Đó là vì hạt nhân
cố gắng đăng ký bảng điều khiển đồ họa trước bảng nối tiếp. Nó làm điều đó
do hành vi mặc định khi không có thiết bị bảng điều khiển nào được chỉ định,
xem bên dưới.

Lưu ý rằng tham số ZZ0000ZZ cuối cùng vẫn tạo ra sự khác biệt.
Dòng lệnh kernel cũng được sử dụng bởi systemd. Nó sẽ sử dụng cái cuối cùng
đã xác định ZZ0001ZZ làm bảng điều khiển đăng nhập.

Nếu không có thiết bị bảng điều khiển nào được chỉ định thì thiết bị đầu tiên được tìm thấy có khả năng
hoạt động như một bảng điều khiển hệ thống sẽ được sử dụng. Lúc này, hệ thống
đầu tiên hãy tìm thẻ VGA và sau đó tìm cổng nối tiếp. Vì vậy nếu bạn không
có thẻ VGA trong hệ thống của bạn, cổng nối tiếp đầu tiên sẽ tự động
trở thành bàn điều khiển, trừ khi kernel được cấu hình bằng
Tùy chọn CONFIG_NULL_TTY_DEFAULT_CONSOLE thì nó sẽ mặc định sử dụng
thiết bị ttynull.

Bạn sẽ cần tạo một thiết bị mới để sử dụng ZZ0000ZZ. quan chức
ZZ0001ZZ hiện là thiết bị ký tự 5,1.

(Bạn cũng có thể sử dụng thiết bị mạng làm bảng điều khiển. Xem
ZZ0000ZZ để biết thông tin về điều đó.)

Đây là một ví dụ sẽ sử dụng ZZ0000ZZ (COM2) làm bảng điều khiển.
Thay thế các giá trị mẫu nếu cần.

1. Tạo ZZ0000ZZ (bàn điều khiển thực) và ZZ0001ZZ (bàn điều khiển ảo chính)
   bảng điều khiển)::

cd /dev
     bảng điều khiển rm -f tty0
     bảng điều khiển mknod -m 622 c 5 1
     mknod -m 622 tty0 c 4 0

2. LILO cũng có thể nhận đầu vào từ thiết bị nối tiếp. Đây là một điều rất
   tùy chọn hữu ích. Để yêu cầu LILO sử dụng cổng nối tiếp:
   Trong lilo.conf (phần toàn cầu)::

nối tiếp = 1.9600n8 (ttyS1, 9600 bd, không có chẵn lẻ, 8 bit)

3. Điều chỉnh cờ kernel cho kernel mới,
   một lần nữa trong lilo.conf (phần kernel)::

nối thêm = "console=ttyS1,9600"

4. Đảm bảo getty chạy trên cổng nối tiếp để bạn có thể đăng nhập vào
   nó sau khi hệ thống khởi động xong. Điều này được thực hiện bằng cách thêm một dòng
   như thế này với ZZ0000ZZ (cú pháp chính xác tùy thuộc vào getty của bạn)::

S1:23:respawn:/sbin/getty -L ttyS1 9600 vt100

5. Ban đầu và ZZ0000ZZ

Sysvinit ghi nhớ các cài đặt stty của nó trong một tệp trong ZZ0000ZZ, được gọi là
   ZZ0001ZZ. REMOVE THIS FILE trước khi sử dụng nối tiếp
   console lần đầu tiên, vì nếu không init có thể sẽ
   đặt tốc độ baudrate thành 38400 (tốc độ baud của bảng điều khiển ảo).

6. ZZ0000ZZ và X
   Các chương trình muốn làm điều gì đó với bảng điều khiển ảo thường
   mở ZZ0001ZZ. Nếu bạn đã tạo thiết bị ZZ0002ZZ mới,
   và bảng điều khiển của bạn là NOT bảng điều khiển ảo, một số chương trình sẽ bị lỗi.
   Đó là những chương trình muốn truy cập vào giao diện VT và sử dụng
   ZZ0003ZZ. Một số chương trình đó là::

Xfree86, svgalib, gpm, SVGATextMode

Tuy nhiên, nó cần được sửa trong các phiên bản hiện đại của các chương trình này.

Lưu ý rằng nếu bạn khởi động mà không có tùy chọn ZZ0000ZZ (hoặc có
   ZZ0001ZZ), ZZ0002ZZ giống như ZZ0003ZZ.
   Trong trường hợp đó mọi thứ vẫn sẽ hoạt động.

7. Cảm ơn

Cảm ơn Geert Uytterhoeven <geert@linux-m68k.org>
   để chuyển các bản vá từ 2.1.4x sang 2.1.6x để chăm sóc
   việc tích hợp các bản vá này vào m68k, ppc và alpha.

Miquel van Smoorenburg <miquels@cistron.nl>, 11-06-2000
