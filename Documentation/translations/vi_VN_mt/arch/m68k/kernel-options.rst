.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/m68k/kernel-options.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Tùy chọn dòng lệnh cho Linux/m68k
===================================

Cập nhật lần cuối: ngày 2 tháng 5 năm 1999

Phiên bản Linux/m68k: 2.2.6

Tác giả: Roman.Hodek@informatik.uni-erlangen.de (Roman Hodek)

Cập nhật: jds@kom.auc.dk (Jes Sorensen) và faq@linux-m68k.org (Chris Lawrence)

0) Giới thiệu
===============

Tôi thường được hỏi Linux/m68k có những tùy chọn dòng lệnh nào
kernel hiểu hoặc cú pháp chính xác cho tùy chọn ... là như thế nào, hoặc
... about the option ... . I hope, this document supplies all the
câu trả lời...

Lưu ý rằng một số tùy chọn có thể đã lỗi thời, mô tả của chúng
không đầy đủ hoặc thiếu. Vui lòng cập nhật thông tin và gửi
các bản vá lỗi.


1) Tổng quan về quá trình xử lý tùy chọn của hạt nhân
=============================================

Hạt nhân biết ba loại tùy chọn trên dòng lệnh của nó:

1) tùy chọn hạt nhân
  2) cài đặt môi trường
  3) đối số cho init

Đối số thuộc về lớp nào trong số các lớp này được xác định là
sau: Nếu tùy chọn này được biết đến bởi chính kernel, tức là nếu tên
(phần trước '=') hoặc, trong một số trường hợp, toàn bộ chuỗi đối số
kernel đã biết thì nó thuộc lớp 1. Ngược lại, nếu
đối số chứa '=', nó thuộc lớp 2 và định nghĩa được đặt
vào môi trường của init. Tất cả các đối số khác được chuyển đến init dưới dạng
tùy chọn dòng lệnh.

Tài liệu này mô tả các tùy chọn kernel hợp lệ cho Linux/m68k trong
phiên bản được đề cập ở đầu tập tin này. Những sửa đổi sau này có thể
thêm các tùy chọn mới như vậy và một số tùy chọn có thể bị thiếu trong các phiên bản cũ hơn.

Nói chung, giá trị (phần sau dấu '=') của một tùy chọn là một
danh sách các giá trị được phân tách bằng dấu phẩy. Việc giải thích các giá trị này
tùy thuộc vào người lái xe "sở hữu" tùy chọn. Hiệp hội này của
các tùy chọn với trình điều khiển cũng là lý do khiến một số tùy chọn còn xa hơn
được chia nhỏ.


2) Tùy chọn hạt nhân chung
=========================

2.1) gốc=
----------

:Cú pháp: root=/dev/<device>
:hoặc: root=<hex_number>

Điều này cho kernel biết thiết bị nào sẽ được gắn làm root
hệ thống tập tin. Thiết bị phải là thiết bị khối có hệ thống tệp hợp lệ
trên đó.

Cú pháp đầu tiên cung cấp tên thiết bị. Những tên này được chuyển đổi
thành số chính/số phụ bên trong kernel theo một cách khác thường.
Thông thường, việc "chuyển đổi" này được thực hiện bởi các tập tin thiết bị trong /dev, nhưng
điều này là không thể ở đây, bởi vì hệ thống tập tin gốc (với/dev)
chưa được gắn kết... Vì vậy, hạt nhân sẽ phân tích tên của chính nó, với một số
tên được mã hóa cứng để ánh xạ số. Tên phải luôn là một
sự kết hợp của hai hoặc ba chữ cái, theo sau là một số thập phân.
Tên hợp lệ là::

/dev/ram: -> 0x0100 (đĩa ram ban đầu)
  /dev/hda: -> 0x0300 (đĩa IDE đầu tiên)
  /dev/hdb: -> 0x0340 (đĩa IDE thứ hai)
  /dev/sda: -> 0x0800 (đĩa SCSI đầu tiên)
  /dev/sdb: -> 0x0810 (đĩa SCSI thứ hai)
  /dev/sdc: -> 0x0820 (đĩa SCSI thứ ba)
  /dev/sdd: -> 0x0830 (đĩa SCSI thứ tư)
  /dev/sde: -> 0x0840 (đĩa SCSI thứ năm)
  /dev/fd : -> 0x0200 (đĩa mềm)

Theo sau tên phải là số thập phân, viết tắt của
số phân vùng. Trong nội bộ, giá trị của số chỉ là
được thêm vào số thiết bị được đề cập trong bảng trên. các
ngoại lệ là /dev/ram và /dev/fd, trong đó /dev/ram đề cập đến một
đĩa RAM ban đầu được tải bởi chương trình khởi động của bạn (vui lòng tham khảo
hướng dẫn cho chương trình khởi động của bạn để tìm hiểu cách tải một
đĩa RAM ban đầu). Kể từ phiên bản kernel 2.0.18, bạn phải chỉ định
/dev/ram làm thiết bị gốc nếu bạn muốn khởi động từ thiết bị đầu tiên
ramdisk. Đối với các thiết bị đĩa mềm, /dev/fd, số này tượng trưng cho
số ổ đĩa mềm (không có phân vùng trên đĩa mềm). tức là,
/dev/fd0 là viết tắt của ổ đĩa đầu tiên, /dev/fd1 là ổ đĩa thứ hai, v.v.
trên. Vì số vừa được thêm vào nên bạn cũng có thể buộc định dạng đĩa
bằng cách cộng một số lớn hơn 3. Nếu bạn nhìn vào /dev
thư mục, sử dụng có thể thấy /dev/fd0D720 có 2 trưởng và 16 phụ. Bạn
có thể chỉ định thiết bị này cho FS gốc bằng cách viết "root=/dev/fd16" trên
dòng lệnh hạt nhân.

[Những thứ kỳ lạ và có thể không thú vị BẬT]

Bản dịch tên thiết bị bất thường này có một số điểm kỳ lạ
hậu quả: Ví dụ: nếu bạn có một liên kết tượng trưng từ /dev/fd
thành /dev/fd0D720 là tên viết tắt của trình điều khiển đĩa mềm #0 ở định dạng DD,
bạn không thể sử dụng tên này để chỉ định thiết bị gốc, bởi vì
kernel không thể nhìn thấy liên kết tượng trưng này trước khi gắn FS gốc và nó
không có trong bảng trên. Nếu bạn sử dụng nó, thiết bị root sẽ không được
được đặt mà không có thông báo lỗi. Một ví dụ khác: Bạn không thể sử dụng
phân vùng trên ví dụ: đĩa SCSI thứ sáu làm hệ thống tập tin gốc, nếu bạn
muốn chỉ định nó theo tên. Điều này là do chỉ những thiết bị có tối đa
/dev/sde nằm trong bảng trên, nhưng không có trong /dev/sdf. Mặc dù, bạn có thể
sử dụng đĩa SCSI thứ sáu cho FS gốc, nhưng bạn phải chỉ định
thiết bị theo số... (xem bên dưới). Hoặc, thậm chí còn kỳ lạ hơn, bạn có thể sử dụng
thực tế là không có phạm vi kiểm tra số phân vùng và
biết rằng mỗi đĩa sử dụng 16 trẻ vị thành niên và viết "root=/dev/sde17"
(đối với/dev/sdf1).

[Thứ kỳ lạ và có thể không thú vị OFF]

Nếu thiết bị chứa phân vùng gốc của bạn không có trong bảng
ở trên, bạn cũng có thể chỉ định nó bằng số chính và số phụ. Đây là
được viết bằng hex, không có tiền tố và không có dấu phân cách giữa. Ví dụ, nếu bạn
có một đĩa CD có nội dung thích hợp làm hệ thống tập tin gốc trong lần đầu tiên
Ổ SCSI CD-ROM, bạn khởi động từ nó bằng lệnh "root=0b00". Ở đây, hệ thập lục phân "0b" =
Số thập phân 11 là số chính của CD-ROM SCSI và số 0 phụ là viết tắt của
đầu tiên trong số này. Bạn có thể tìm ra tất cả các số chính hợp lệ bằng cách
đang xem xét include/linux/major.h.

Ngoài các số chính và số phụ, nếu thiết bị chứa số của bạn
phân vùng gốc sử dụng định dạng bảng phân vùng với phân vùng duy nhất
số nhận dạng thì bạn có thể sử dụng chúng.  Ví dụ,
"root=PARTUUID=00112233-4455-6677-8899-AABBCCDDEEFF".  Nó cũng là
có thể tham chiếu một phân vùng khác trên cùng một thiết bị bằng cách sử dụng
phân vùng UUID được biết đến là điểm bắt đầu.  Ví dụ,
nếu phân vùng 5 của thiết bị có UUID của
00112233-4455-6677-8899-AABBCCDDEEFF thì phân vùng 3 có thể được tìm thấy dưới dạng
sau:

PARTUUID=00112233-4455-6677-8899-AABBCCDDEEFF/PARTNROFF=-2

Thông tin có thẩm quyền có thể được tìm thấy trong
"Tài liệu/admin-guide/kernel-parameters.rst".


2.2) ro, rw
-----------

:Cú pháp: ro
:hoặc: rw

Hai tùy chọn này cho kernel biết có nên mount root hay không
hệ thống tập tin chỉ đọc hoặc đọc-ghi. Mặc định là chỉ đọc, ngoại trừ
đối với ramdisks, mặc định là đọc-ghi.


2.3) gỡ lỗi
----------

:Cú pháp: gỡ lỗi

Điều này làm tăng mức nhật ký kernel lên 10 (mặc định là 7). Đây là
cùng mức được đặt bởi lệnh "dmesg", chỉ là mức tối đa
có thể lựa chọn bởi dmesg là 8.


2.4) gỡ lỗi=
-----------

:Cú pháp: gỡ lỗi=<thiết bị>

Tùy chọn này khiến một số thông báo kernel nhất định được in tới vùng đã chọn
thiết bị gỡ lỗi. Điều này có thể hỗ trợ việc gỡ lỗi kernel, vì
tin nhắn có thể được ghi lại và phân tích trên một số máy khác. Cái nào
các thiết bị có thể thực hiện được tùy thuộc vào loại máy. Không có kiểm tra
về tính hợp lệ của tên thiết bị. Nếu thiết bị không được triển khai,
không có gì xảy ra.

Các thông báo được ghi theo cách này thường nằm trong các ngăn xếp sau kernel
lỗi bộ nhớ hoặc bẫy kernel xấu, và kernel hoảng loạn. Nói chính xác là: tất cả
thông báo cấp 0 (tin nhắn hoảng loạn) và tất cả các thông báo được in trong khi
cấp độ nhật ký là 8 trở lên (cấp độ của chúng không thành vấn đề). Trước ngăn xếp
dumps, kernel sẽ tự động đặt mức nhật ký thành 10. Một mức độ
ít nhất 8 cũng có thể được đặt bằng tùy chọn dòng lệnh "gỡ lỗi" (xem
2.3) và tại thời điểm chạy với "dmesg -n 8".

Các thiết bị có thể sử dụng cho Amiga:

- "ser":
	  cổng nối tiếp tích hợp; thông số: 9600bps, 8N1
 - "tôi":
	  Lưu tin nhắn vào vùng dành riêng trong chip mem. Sau
          khởi động lại, chúng có thể được đọc trong AmigaOS bằng công cụ
          'dmesg'.

Các thiết bị có thể sử dụng cho Atari:

- "ser1":
	   Cổng nối tiếp ST-MFP ("Modem1"); thông số: 9600bps, 8N1
 - "ser2":
	   Cổng nối tiếp kênh B SCC ("Modem2"); thông số: 9600bps, 8N1
 - "ser" :
	   cổng nối tiếp mặc định
           Đây là "ser2" cho Falcon và "ser1" cho bất kỳ máy nào khác
 - "midi":
	   Cổng MIDI; thông số: 31250bps, 8N1
 - "ngang bằng" :
	   cổng song song

Quy trình in cho việc này thực hiện thời gian chờ cho
           trường hợp không có máy in nào được kết nối (nếu không hạt nhân sẽ
           khóa lại). Thời gian chờ không chính xác nhưng thường là một vài
           giây.


2.6) ramdisk_size=
------------------

:Cú pháp: ramdisk_size=<size>

Tùy chọn này hướng dẫn kernel thiết lập một đĩa RAM có kích thước đã cho
kích thước tính bằng KBytes. Không sử dụng tùy chọn này nếu nội dung đĩa RAM
được thông qua bởi bootstrap! Trong trường hợp này, kích thước được chọn tự động
và không nên ghi đè.

Ứng dụng duy nhất dành cho hệ thống tập tin gốc trên đĩa mềm, đó là
nên được tải vào bộ nhớ. Để làm điều đó, chọn tương ứng
kích thước của đĩa theo kích thước ramdisk và đặt thiết bị gốc vào đĩa
ổ đĩa (có "root=").


2.7) trao đổi =

Tôi không thể tìm thấy bất kỳ dấu hiệu nào của tùy chọn này trong 2.2.6.

2.8) tăng cường=
-----------

Tôi không thể tìm thấy bất kỳ dấu hiệu nào của tùy chọn này trong 2.2.6.


3) Tùy chọn thiết bị chung (Amiga và Atari)
===========================================

3.1) ete=
-----------

:Cú pháp: ether=[<irq>[,<base_addr>[,<mem_start>[,<mem_end>]]]],<dev-name>

<dev-name> là tên của trình điều khiển mạng, như được chỉ định trong
driver/net/Space.c trong nguồn Linux. Nổi bật nhất là eth0,...
eth3, sl0, ... sl3, ppp0, ..., ppp3, giả và lo.

Các trình điều khiển không phải ethernet (sl, ppp, dummy, lo) rõ ràng bỏ qua
cài đặt bằng tùy chọn này. Ngoài ra, trình điều khiển ethernet hiện có cho
Linux/m68k (ariadne, a2065, hydra) không sử dụng chúng vì bo mạch Zorro
thực sự là Plug-'n-Play, vì vậy tùy chọn "ether=" hoàn toàn vô dụng
dành cho Linux/m68k.


3.2) hd=
--------

:Cú pháp: hd=<xi lanh>,<heads>,<sector>

Tùy chọn này đặt hình dạng đĩa của đĩa IDE. HD đầu tiên =
tùy chọn dành cho đĩa IDE đầu tiên, tùy chọn thứ hai dành cho đĩa thứ hai.
(Tức là bạn có thể đưa ra tùy chọn này hai lần.) Trong hầu hết các trường hợp, bạn sẽ không có
để sử dụng tùy chọn này, vì kernel có thể lấy dữ liệu hình học
chính nó. Nó tồn tại chỉ trong trường hợp điều này không thành công đối với một trong các bạn
đĩa.


3.3) max_scsi_luns=
-------------------

:Cú pháp: max_scsi_luns=<n>

Đặt số LUN (đơn vị logic) tối đa của thiết bị SCSI thành
được quét. Các giá trị hợp lệ cho <n> nằm trong khoảng từ 1 đến 8. Mặc định là 8 nếu
"Thăm dò tất cả LUN trên mỗi thiết bị SCSI" đã được chọn trong kernel
cấu hình, khác 1.


3.4) st=
--------

:Cú pháp: st=<buffer_size>,[<write_thres>,[<max_buffers>]]

Đặt một số tham số của trình điều khiển băng SCSI. <buffer_size> là
số lượng bộ đệm 512 byte dành riêng cho các hoạt động băng cho mỗi bộ đệm
thiết bị. <write_thres> đặt số khối phải được điền
để bắt đầu một thao tác ghi thực sự vào băng. Giá trị tối đa là
tổng số bộ đệm. <max_buffer> giới hạn tổng số
bộ đệm được phân bổ cho tất cả các thiết bị băng.


3.5) dmasound=
--------------

:Cú pháp: dmasound=[<buffers>,<buffer-size>[,<catch-radius>]]

Tùy chọn này kiểm soát một số cấu hình của âm thanh Linux/m68k DMA
trình điều khiển (Amiga và Atari): <buffers> là số lượng bộ đệm bạn muốn
để sử dụng (tối thiểu 4, mặc định 4), <buffer-size> là kích thước của mỗi
bộ đệm tính bằng kilobyte (tối thiểu 4, mặc định 32) và <catch-radius> cho biết
bao nhiêu phần trăm lỗi sẽ được chấp nhận khi đặt tần số
(tối đa 10, mặc định 0). Ví dụ với 3% bạn có thể phát 8000Hz
AU-Files trên Falcon với tần số phần cứng là 8195Hz và do đó
không cần phải mở rộng âm thanh.



4) Tùy chọn chỉ dành cho Atari
=========================

4.1) video=
-----------

:Cú pháp: video=<fbname>:<sub-options...>

Tham số <fbname> chỉ định tên của bộ đệm khung,
ví dụ. hầu hết người dùng atari sẽ muốn chỉ định ZZ0000ZZ ở đây. các
<sub-options> là danh sách các tùy chọn phụ được phân tách bằng dấu phẩy được liệt kê
bên dưới.

Lưu ý:
    Xin lưu ý rằng tùy chọn này đã được đổi tên từ ZZ0000ZZ thành
    ZZ0001ZZ trong quá trình phát triển hạt nhân 1.3.x, do đó bạn
    có thể cần cập nhật tập lệnh khởi động nếu nâng cấp lên 2.x từ
    hạt nhân 1.2.x.

NBB:
    Hành vi của video= đã được thay đổi trong 2.1.57 nên khuyến nghị
    tùy chọn là chỉ định tên của bộ đệm khung.

4.1.1) Chế độ video
-----------------

Tùy chọn phụ này có thể là bất kỳ chế độ video nào được xác định trước, như được liệt kê
trong atari/atafb.c trong cây nguồn Linux/m68k. Hạt nhân sẽ
kích hoạt chế độ video đã cho khi khởi động và đặt nó làm mặc định
chế độ, nếu phần cứng cho phép. Tên được xác định hiện tại là:

- tốc độ : 320x200x4
 - stmid, mặc định5 : 640x200x2
 - Sthigh, mặc định4: 640x400x1
 - ttlow : 320x480x8, chỉ TT
 - ttmid, mặc định1 : 640x480x4, chỉ TT
 - tthigh, mặc định2: 1280x960x1, chỉ TT
 - vga2 : 640x480x1, chỉ Falcon
 - vga4 : 640x480x2, chỉ Falcon
 - vga16, default3 : 640x480x4, chỉ Falcon
 - vga256 : 640x480x8, chỉ Falcon
 - falh2 : 896x608x1, chỉ Falcon
 - falh16 : 896x608x4, chỉ Falcon

Nếu không có chế độ video nào được cung cấp trên dòng lệnh, kernel sẽ thử
lần lượt đặt tên các chế độ "default<n>" cho đến khi có thể thực hiện được với
phần cứng đang sử dụng.

Cài đặt chế độ video sẽ không có ý nghĩa nếu trình điều khiển bên ngoài
được kích hoạt bởi tùy chọn phụ "bên ngoài:".

4.1.2) nghịch đảo
--------------

Đảo ngược màn hình. Điều này chỉ ảnh hưởng đến bảng điều khiển văn bản.
Thông thường, nền được chọn là màu đen. Với cái này
tùy chọn, bạn có thể làm cho nền màu trắng.

4.1.3) phông chữ
-----------

:Cú pháp: phông chữ:<tên phông chữ>

Chỉ định phông chữ để sử dụng trong chế độ văn bản. Hiện tại bạn chỉ có thể chọn
giữa ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ. ZZ0003ZZ là mặc định, nếu
kích thước dọc của màn hình nhỏ hơn 400 pixel hàng. Nếu không,
Phông chữ ZZ0004ZZ là mặc định.

4.1.4) ZZ0000ZZ
------------------

:Cú pháp: ZZ0000ZZ

Số dòng bộ nhớ video bổ sung cần dự trữ cho
tăng tốc độ cuộn ("cuộn phần cứng"). Cuộn phần cứng
chỉ có thể thực hiện được nếu hạt nhân có thể đặt địa chỉ cơ sở video theo các bước
đủ ổn. Điều này đúng với STE, MegaSTE, TT và Falcon. Nó không phải
có thể thực hiện được với ST đơn giản và card đồ họa (Trước đây vì
địa chỉ cơ sở phải nằm trên ranh giới 256 byte ở đó, địa chỉ sau vì
kernel hoàn toàn không biết cách đặt địa chỉ cơ sở.)

Theo mặc định, <n> được đặt thành số dòng văn bản hiển thị trên
hiển thị. Do đó, dung lượng bộ nhớ video được tăng gấp đôi so với không có
cuộn phần cứng. Bạn có thể tắt hoàn toàn tính năng cuộn phần cứng
bằng cách đặt <n> thành 0.

4.1.5) nội bộ:
----------------

:Cú pháp: nội bộ:<xres>;<yres>[;<xres_max>;<yres_max>;<offset>]

Tùy chọn này chỉ định khả năng của một số video nội bộ mở rộng
phần cứng, chẳng hạn như Quét quá mức. <xres> và <yres> cung cấp (mở rộng)
kích thước của màn hình.

Nếu OverScan của bạn cần viền đen, bạn phải viết phần cuối cùng
ba đối số của "nội bộ:". <xres_max> là dòng tối đa
độ dài phần cứng cho phép, <yres_max> số lượng dòng tối đa.
<offset> là phần bù của phần hiển thị của bộ nhớ màn hình so với phần của nó
bắt đầu vật lý, tính bằng byte.

Thông thường, phần cứng video có khoảng thời gian mở rộng phải được kích hoạt bằng cách nào đó.
Để biết điều này, hãy xem các tùy chọn "sw_*" bên dưới.

4.1.6) bên ngoài:
----------------

:Cú pháp:
  bên ngoài:<xres>;<yres>;<độ sâu>;<org>;<scrmem>[;<scrlen>[;<vgabase>
  [;<colw>[;<coltype>[;<xres_virtual>]]]]]

.. I had to break this line...

Đây có lẽ là tham số phức tạp nhất... Nó chỉ rõ rằng
bạn có một số phần cứng video bên ngoài (bo mạch đồ họa) và cách
sử dụng nó trong Linux/m68k. Kernel không thể biết thêm về phần cứng
hơn là bạn nói nó ở đây! Hạt nhân cũng không thể thiết lập hoặc thay đổi bất kỳ
chế độ video, vì nó không biết về bất kỳ bảng nội bộ nào. Vì vậy, bạn
phải chuyển sang chế độ video đó trước khi khởi động Linux và không thể
chuyển sang chế độ khác khi Linux đã khởi động.

3 tham số đầu tiên của tùy chọn phụ này phải rõ ràng: <xres>,
<yres> và <deep> cho biết kích thước của màn hình và số lượng
mặt phẳng (độ sâu). Độ sâu là logarit cơ số 2 của số
về màu sắc có thể. (Hoặc ngược lại: Số lượng màu là
2^độ sâu).

Hơn nữa, bạn phải nói cho kernel biết bộ nhớ video như thế nào
có tổ chức. Việc này được thực hiện bằng một chữ cái dưới dạng tham số <org>:

'n':
      "mặt phẳng bình thường", tức là toàn bộ mặt phẳng này đến mặt phẳng khác
 'tôi':
      "các mặt phẳng xen kẽ", tức là 16 bit của mặt phẳng đầu tiên, hơn 16 bit
      của phần tiếp theo, v.v... Chế độ này chỉ được sử dụng với
      chế độ video Atari tích hợp, tôi nghĩ không có thẻ nào
      hỗ trợ chế độ này.
 'p':
      "pixel đóng gói", tức là <độ sâu> các bit liên tiếp đại diện cho tất cả
      mặt phẳng một pixel; đây là chế độ phổ biến nhất cho 8 mặt phẳng
      (256 màu) trên card đồ họa
 't':
      "màu sắc trung thực" (nhiều hoặc ít pixel được đóng gói nhưng không có màu
      bảng tra cứu); thường độ sâu là 24

Đối với chế độ đơn sắc (tức là <độ sâu> là 1), chữ cái <org> có
ý nghĩa khác nhau:

'n':
      màu sắc bình thường, tức là 0=trắng, 1=đen
 'tôi':
      màu đảo ngược, tức là 0=đen, 1=trắng

Thông tin quan trọng tiếp theo về phần cứng video là cơ sở
địa chỉ của bộ nhớ video. Điều đó được đưa ra trong tham số <scrmem>,
dưới dạng số thập lục phân có tiền tố "0x". Bạn phải tìm hiểu điều này
địa chỉ trong tài liệu phần cứng của bạn.

Tham số tiếp theo, <scrlen>, cho kernel biết kích thước của
bộ nhớ video. Nếu thiếu, kích thước được tính từ <xres>,
<yres> và <độ sâu>. Hiện tại, việc viết một giá trị ở đây không hữu ích.
Nó sẽ chỉ được sử dụng để cuộn phần cứng (điều này là không thể
với trình điều khiển bên ngoài, vì kernel không thể thiết lập cơ sở video
địa chỉ) hoặc cho các độ phân giải ảo theo X (mà máy chủ X
chưa hỗ trợ). Vì vậy, tốt nhất hiện tại bạn nên rời khỏi lĩnh vực này
trống, bằng cách kết thúc "external:" sau địa chỉ video hoặc bằng
viết hai dấu chấm phẩy liên tiếp, nếu bạn muốn cho <vgabase>
(được phép để trống tham số này).

Tham số <vgabase> là tùy chọn. Nếu nó không được cung cấp, kernel
không thể đọc hoặc ghi bất kỳ thanh ghi màu nào của phần cứng video và
do đó bạn phải đặt màu thích hợp trước khi khởi động Linux. Nhưng nếu
thẻ của bạn bằng cách nào đó tương thích với VGA, bạn có thể cho kernel biết cơ sở
địa chỉ của bộ thanh ghi VGA nên có thể thay đổi tra cứu màu
cái bàn. Bạn phải tra cứu địa chỉ này trong tài liệu của hội đồng quản trị của bạn.
Để tránh hiểu lầm: <vgabase> là địa chỉ _base_, tức là 4k
địa chỉ phù hợp. Để đọc/ghi các thanh ghi màu, kernel
sử dụng địa chỉ vgabase+0x3c7...vgabase+0x3c9. <vgabase>
tham số được viết bằng hệ thập lục phân với tiền tố "0x", giống như
<scrmem>.

<colw> chỉ có ý nghĩa nếu <vgabase> được chỉ định. Nó kể cho
kernel mỗi thanh ghi màu rộng bao nhiêu, tức là số bit
mỗi màu duy nhất (đỏ/xanh/xanh). Mặc định là 6, một cái khác khá bình thường
giá trị là 8.

Ngoài ra <coltype> được sử dụng cùng với <vgabase>. Nó báo cho kernel
về mô hình đăng ký màu của bảng gfx của bạn. Hiện nay, các loại
"vga" (cũng là mặc định) và "mv300" (SANG MV300) là
được thực hiện.

Tham số <xres_virtual> là bắt buộc đối với thẻ ProMST hoặc ET4000 trong đó
chiều dài đường truyền vật lý khác với chiều dài nhìn thấy được. Với ProMST,
xres_virtual phải được đặt thành 2048. Đối với ET4000, xres_virtual phụ thuộc vào
khởi tạo card màn hình.
Nếu bạn thiếu yres_virtual tương ứng: phần bên ngoài là di sản,
do đó chúng tôi không hỗ trợ các chức năng phụ thuộc vào phần cứng như cuộn phần cứng,
xoay hoặc làm trống.

4.1.7) đồng hồ:
--------------

Đồng hồ pixel bên ngoài được gắn vào bộ chuyển động Falcon VIDEL. Cái này
hiện chỉ hoạt động với ScreenWonder!

4.1.8) màn hình:
-------------------

:Cú pháp: màn hình:<vmin>;<vmax>;<hmin>;<hmax>

Phần này mô tả khả năng của màn hình đa đồng bộ. Đừng sử dụng nó
với một màn hình tần số cố định! Hiện tại, chỉ có bộ đệm khung Falcon
sử dụng cài đặt của "monitorcap:".

<vmin> và <vmax> lần lượt là tần số dọc tối thiểu và tối đa
màn hình của bạn có thể hoạt động với, tính bằng Hz. <hmin> và <hmax> giống nhau
tần số ngang, tính bằng kHz.

Giá trị mặc định là 58;62;31;32 (tương thích với VGA).

Các giá trị mặc định cho TV/SC1224/SC1435 bao gồm cả tiêu chuẩn PAL và NTSC.

4.1.9) giữ lại
------------

Nếu tùy chọn này được đưa ra, thiết bị bộ đệm khung sẽ không thực hiện bất kỳ video nào
tính toán và cài đặt chế độ riêng. Thiết bị fb Atari duy nhất
hiện đang thực hiện điều này là Falcon.

Những gì bạn đạt được với điều này: Cài đặt cho tiện ích mở rộng video không xác định
không bị trình điều khiển ghi đè nên bạn vẫn có thể sử dụng chế độ được tìm thấy
khi khởi động, khi driver không biết tự cài đặt chế độ này.
Nhưng điều này cũng có nghĩa là bạn không thể chuyển đổi chế độ video nữa...

Một ví dụ mà bạn có thể muốn sử dụng "keep" là ScreenBlaster dành cho
chim ưng.


4.2) atamouse=
--------------

:Cú pháp: atamouse=<x-threshold>,[<y-threshold>]

Với tùy chọn này, bạn có thể đặt ngưỡng báo cáo chuyển động của chuột.
Đây là số pixel di chuyển của chuột phải tích lũy
trước khi IKBD gửi gói chuột mới tới kernel. Giá trị cao hơn
giảm tải gián đoạn chuột và do đó giảm nguy cơ bàn phím
vượt quá. Giá trị thấp hơn cho phản ứng chuột nhanh hơn một chút và
theo dõi chuột tốt hơn một chút.

Bạn có thể đặt ngưỡng theo x và y riêng biệt, nhưng thông thường đây là
ít có tác dụng thực tế. Nếu chỉ có một số trong tùy chọn, nó
được sử dụng cho cả hai chiều. Giá trị mặc định là 2 cho cả hai
ngưỡng.


4.3) ataflop=
-------------

:Cú pháp: ataflop=<loại ổ>[,<trackbuffering>[,<steprateA>[,<steprateB>]]]

Loại ổ đĩa có thể là 0, 1 hoặc 2 cho DD, HD và ED, tương ứng. Cái này
   cài đặt ảnh hưởng đến số lượng bộ đệm được dành riêng và định dạng nào được lưu trữ.
   đã được thăm dò (xem thêm bên dưới). Mặc định là 1 (HD). Chỉ có một loại ổ đĩa
   có thể được chọn. Nếu bạn có hai ổ đĩa, hãy chọn "tốt hơn"
   loại.

Tham số thứ hai <trackbuffer> cho kernel biết có nên sử dụng
   đệm theo dõi (1) hay không (0). Mặc định là phụ thuộc vào máy:
   không đối với Medusa và có đối với tất cả những người khác.

Với hai tham số sau, bạn có thể thay đổi mặc định
   steprate được sử dụng cho ổ A và B, tương ứng.


4.4) atascsi=
-------------

:Cú pháp: atascsi=<can_queue>[,<cmd_per_lun>[,<scat-gat>[,<host-id>[,<tagged>]]]]

Tùy chọn này đặt một số tham số cho trình điều khiển SCSI gốc Atari.
Nói chung, bất kỳ số lượng đối số nào cũng có thể được bỏ qua ở cuối. Và
đối với mỗi số, giá trị âm có nghĩa là "sử dụng mặc định". các
các giá trị mặc định tùy thuộc vào việc SCSI kiểu TT hay kiểu Falcon được sử dụng.
Bên dưới, giá trị mặc định được ghi chú là n/m, trong đó giá trị đầu tiên đề cập đến
TT-SCSI và sau này là Falcon-SCSI. Nếu một giá trị bất hợp pháp được đưa ra
đối với một tham số, một thông báo lỗi sẽ được in và một cài đặt đó được
bị bỏ qua (những người khác không bị ảnh hưởng).

<can_queue>:
    Đây là số lượng lệnh SCSI tối đa được xếp hàng nội bộ vào
    Trình điều khiển Atari SCSI. Giá trị 1 sẽ tắt trình điều khiển một cách hiệu quả
    đa nhiệm nội bộ (nếu nó gây ra vấn đề). Giá trị pháp lý là >=
    1. <can_queue> có thể cao bao nhiêu tùy thích, nhưng giá trị lớn hơn
    <cmd_per_lun> nhân với số lượng mục tiêu SCSI (LUN) mà bạn có
    không có ý nghĩa. Mặc định: 16/8.

<cmd_per_lun>:
    Số lượng lệnh SCSI tối đa được cấp cho trình điều khiển cho một lệnh
    đơn vị logic (LUN, thường là một mục tiêu SCSI). Giá trị pháp lý bắt đầu
    từ 1. Nếu hàng đợi được gắn thẻ (xem bên dưới) không được sử dụng, giá trị lớn hơn
    hơn 2 không có ý nghĩa, nhưng lãng phí bộ nhớ. Nếu không thì tối đa
    là số lượng thẻ lệnh có sẵn cho trình điều khiển (hiện tại
    32). Mặc định: 1/8. (Lưu ý: Giá trị > 1 dường như gây ra sự cố trên
    Falcon, nguyên nhân vẫn chưa được biết.)

Giá trị <cmd_per_lun> phần lớn quyết định số lượng
    bộ nhớ SCSI dự trữ cho chính nó. Công thức khá là
    phức tạp, nhưng tôi có thể cho bạn một số gợi ý:

không phân tán-thu thập:
	cmd_per_lun * 232 byte
      thu thập phân tán đầy đủ:
	cmd_per_lun * khoảng. 17 Kbyte

<scat-gat>:
    Kích thước của bảng thu thập phân tán, tức là số lượng yêu cầu
    liên tiếp trên đĩa có thể được hợp nhất thành một lệnh SCSI.
    Giá trị pháp lý nằm trong khoảng từ 0 đến 255. Mặc định: 255/0. Lưu ý: Cái này
    giá trị bị buộc về 0 trên Falcon, vì việc thu thập phân tán không
    có thể thực hiện được với ST-DMA. Không sử dụng tính năng thu thập phân tán gây tổn hại
    hiệu suất đáng kể.

<ID máy chủ>:
    ID SCSI sẽ được người khởi tạo (Atari của bạn) sử dụng. Đây là
    thường là 7, ID cao nhất có thể. Mọi ID trên xe buýt SCSI phải
    trở nên độc đáo. Mặc định: được xác định trong thời gian chạy: Nếu tổng kiểm tra NV-RAM
    là hợp lệ và bit 7 trong byte 30 của NV-RAM được đặt, 3 thấp hơn
    các bit của byte này được sử dụng làm ID máy chủ. (Phương pháp này được xác định
    bởi Atari và cũng được sử dụng bởi một số trình điều khiển TOS HD.) Nếu ở trên
    không được cung cấp, ID mặc định là 7. (cả TT và Falcon).

<được gắn thẻ>:
    0 nghĩa là tắt hỗ trợ xếp hàng được gắn thẻ, tất cả các giá trị khác > 0 nghĩa là
    sử dụng hàng đợi được gắn thẻ cho các mục tiêu hỗ trợ nó. Mặc định: hiện tại
    tắt, nhưng điều này có thể thay đổi khi việc xử lý hàng đợi được gắn thẻ đã được thực hiện
    đã được chứng minh là đáng tin cậy.

Xếp hàng được gắn thẻ có nghĩa là có thể đưa ra nhiều lệnh cho
    một LUN và chính thiết bị SCSI sẽ sắp xếp các yêu cầu để chúng
    có thể được thực hiện theo thứ tự tối ưu. Không phải tất cả các thiết bị SCSI đều hỗ trợ
    xếp hàng được gắn thẻ (:-().

4.5 công tắc=
-------------

:Cú pháp: switch=<danh sách các switch>

Với tùy chọn này bạn có thể chuyển đổi một số dòng phần cứng thường
được sử dụng để bật/tắt một số phần mở rộng phần cứng nhất định. Ví dụ là
OverScan, ép xung, ...

<danh sách các switch> là danh sách được phân tách bằng dấu phẩy gồm các mục sau
các mục:

ikbd:
	đặt RTS của bàn phím ACIA ở mức cao
  người trung gian:
	đặt RTS của MIDI ACIA ở mức cao
  snd6:
	đặt bit 6 của cổng A PSG
  snd7:
	đặt bit 6 của cổng A PSG

Sẽ vô nghĩa nếu đề cập đến một công tắc nhiều lần (không
chỉ khác nhau một lần), nhưng bạn có thể chuyển đổi bao nhiêu tùy thích
muốn kích hoạt các tính năng khác nhau. Các đường chuyển đổi được thiết lập sớm
càng tốt trong quá trình khởi tạo kernel (ngay cả trước khi xác định
phần cứng hiện tại.)

Tất cả các mục cũng có thể được bắt đầu bằng ZZ0000ZZ, tức là ZZ0001ZZ,
ZZ0002ZZ, ... Các tùy chọn này dùng để bật OverScan
phần mở rộng video. Sự khác biệt so với tùy chọn trần là
việc bật được thực hiện sau khi khởi tạo video và được đồng bộ hóa bằng cách nào đó
đến HBLANK. Điều đặc biệt là ov_ikbd và ov_midi được chuyển đổi
tắt trước khi khởi động lại, để OverScan bị tắt và TOS khởi động
một cách chính xác.

Nếu bạn đưa ra cả hai tùy chọn, có và không có tiền tố ZZ0000ZZ, thì
việc khởi tạo trước đó (ZZ0001ZZ-less) được ưu tiên. Nhưng
tắt khi đặt lại vẫn xảy ra trong trường hợp này.

5) Tùy chọn chỉ dành cho Amiga:
==========================

5.1) video=
-----------

:Cú pháp: video=<fbname>:<sub-options...>

Tham số <fbname> chỉ định tên của bộ đệm khung, hợp lệ
các tùy chọn là ZZ0000ZZ, ZZ0001ZZ, 'virge', ZZ0002ZZ và ZZ0003ZZ, được cung cấp
rằng các thiết bị đệm khung tương ứng đã được biên dịch vào
kernel (hoặc được biên dịch thành các mô-đun có thể tải được). Hành vi của <fbname>
tùy chọn đã được thay đổi trong 2.1.57 vì vậy hiện tại nên chỉ định tùy chọn này
tùy chọn.

<sub-options> là danh sách các tùy chọn phụ được phân tách bằng dấu phẩy được liệt kê
bên dưới. Tùy chọn này được tổ chức tương tự như phiên bản Atari của
tùy chọn "video" (4.1), nhưng biết ít tùy chọn phụ hơn.

5.1.1) chế độ video
-----------------

Một lần nữa, tương tự như chế độ video của Atari (xem 4.1.1). Được xác định trước
các chế độ phụ thuộc vào thiết bị đệm khung được sử dụng.

Các máy OCS, ECS và AGA đều sử dụng bộ đệm khung màu. Sau đây
chế độ video được xác định trước có sẵn:

Chế độ NTSC:
 - ntsc : 640x200, 15 kHz, 60 Hz
 - ntsc-lace : 640x400, 15 kHz, 60 Hz xen kẽ

Chế độ PAL:
 - tần số: 640x256, 15 kHz, 50 Hz
 - pal-ren : 640x512, 15 kHz, 50 Hz xen kẽ

Chế độ ECS:
 - quét đa điểm: 640x480, 29 kHz, 57 Hz
 - Multiscan-ren : 640x960, 29 kHz, 57 Hz xen kẽ
 - euro36 : 640x200, 15 kHz, 72 Hz
 - ren euro36 : 640x400, 15 kHz, 72 Hz xen kẽ
 - euro72 : 640x400, 29 kHz, 68 Hz
 - euro72-ren : 640x800, 29 kHz, 68 Hz xen kẽ
 - super72 : 800x300, 23 kHz, 70 Hz
 - super72-ren : 800x600, 23 kHz, 70 Hz xen kẽ
 - dblntsc-ff : 640x400, 27 kHz, 57 Hz
 - dblntsc-lace : 640x800, 27 kHz, 57 Hz xen kẽ
 - dblpal-ff : 640x512, 27 kHz, 47 Hz
 - dblpal-lace : 640x1024, 27 kHz, 47 Hz xen kẽ
 - dblntsc : quét đôi 640x200, 27 kHz, 57 Hz
 - dblpal : 640x256, 27 kHz, quét kép 47 Hz

Chế độ VGA:
 - vga : 640x480, 31 kHz, 60 Hz
 - vga70 : 640x400, 31 kHz, 70 Hz

Xin lưu ý rằng chế độ ECS và VGA yêu cầu ECS hoặc AGA
chipset và các chế độ này được giới hạn ở màu 2 bit cho ECS
chipset và màu 8 bit cho chipset AGA.

5.1.2) độ sâu
------------

:Cú pháp: độ sâu:<nr. của mặt phẳng bit>

Chỉ định số lượng mặt phẳng bit cho chế độ video đã chọn.

5.1.3) nghịch đảo
--------------

Sử dụng màn hình đảo ngược (màu đen trên nền trắng). Về mặt chức năng tương tự như
tùy chọn phụ "nghịch đảo" cho Atari.

5.1.4) phông chữ
-----------

:Cú pháp: phông chữ:<tên phông chữ>

Chỉ định phông chữ để sử dụng trong chế độ văn bản. Về mặt chức năng tương tự như
Tùy chọn phụ "phông chữ" cho Atari, ngoại trừ ZZ0000ZZ được sử dụng thay thế
của ZZ0001ZZ nếu kích thước dọc của màn hình nhỏ hơn 400 pixel
hàng.

5.1.5) màn hình:
-------------------

:Cú pháp: màn hình:<vmin>;<vmax>;<hmin>;<hmax>

Phần này mô tả khả năng của màn hình đa đồng bộ. Hiện tại chỉ có
bộ đệm khung màu sử dụng cài đặt của "monitorcap:".

<vmin> và <vmax> lần lượt là tần số dọc tối thiểu và tối đa
màn hình của bạn có thể hoạt động với, tính bằng Hz. <hmin> và <hmax> giống nhau
tần số ngang, tính bằng kHz.

Giá trị mặc định là 50;90;15;38 (Màn hình đa đồng bộ Amiga chung).


5.2) fd_def_df0=
----------------

:Cú pháp: fd_def_df0=<giá trị>

Đặt giá trị df0 cho ổ đĩa mềm "im lặng". Giá trị phải ở
thập lục phân với tiền tố "0x".


5.3) wd33c93=
-------------

:Cú pháp: wd33c93=<tùy chọn phụ...>

Các tùy chọn này ảnh hưởng đến A590/A2091, A3000 và GVP Series II SCSI
bộ điều khiển.

<sub-options> là danh sách các tùy chọn phụ được phân tách bằng dấu phẩy được liệt kê
bên dưới.

5.3.1) không đồng bộ
-------------

:Cú pháp: nosync:bitmask

bitmask là một byte trong đó 7 bit đầu tiên tương ứng với 7 bit
các thiết bị SCSI có thể. Đặt một chút để ngăn chặn việc đàm phán đồng bộ hóa trên đó
thiết bị. Để duy trì khả năng tương thích ngược, một dòng lệnh như
"wd33c93=255" sẽ được tự động dịch sang
"wd33c93=nosync:0xff". Mặc định là tắt thương lượng đồng bộ hóa cho
tất cả các thiết bị, ví dụ. nosync:0xff.

5.3.2) kỳ
-------------

:Cú pháp: dấu chấm:ns

ZZ0000ZZ là nano giây # of tối thiểu trong quá trình truyền dữ liệu SCSI
kỳ. Mặc định là 500; giá trị chấp nhận được là 250 - 1000.

5.3.3) ngắt kết nối
-----------------

:Cú pháp: ngắt kết nối:x

Chỉ định x = 0 để không bao giờ cho phép ngắt kết nối, 2 để luôn cho phép chúng.
x = 1 thực hiện ngắt kết nối 'thích ứng', đây là mặc định và thường
sự lựa chọn tốt nhất

5.3.4) gỡ lỗi
------------

:Cú pháp: gỡ lỗi:x

Nếu ZZ0000ZZ được xác định, x là mặt nạ bit gây ra nhiều
các loại đầu ra gỡ lỗi được in - xem DB_xxx định nghĩa trong
wd33c93.h.

5.3.5) đồng hồ
------------

:Cú pháp: đồng hồ:x

x = đầu vào đồng hồ tính bằng MHz cho chip WD33c93. Giá trị bình thường sẽ là từ
8 đến 20. Giá trị mặc định phụ thuộc vào (các) chương trình máy chủ của bạn,
mặc định cho bộ điều khiển bên trong A3000 là 14, đối với A2091 là 8
và đối với bộ điều hợp máy chủ GVP, nó là 8 hoặc 14, tùy thuộc vào
Hostadapter và jumper đồng hồ SCSI có trên một số GVP
máy chủ lưu trữ.

5.3.6) tiếp theo
-----------

Không có tranh luận. Dùng để phân tách các khối từ khóa khi có nhiều hơn
hơn một bộ điều hợp máy chủ dựa trên wd33c93 trong hệ thống.

5.3.7) gật đầu
------------

:Cú pháp: gật đầu:x

Nếu x là 1 (hoặc nếu tùy chọn chỉ được viết là "nodma"), WD33c93
bộ điều khiển sẽ không sử dụng DMA (= truy cập bộ nhớ trực tiếp) để truy cập
Ký ức của Amiga.  Điều này hữu ích cho một số hệ thống (như A3000 và
A4000 với bộ tăng tốc A3640, phiên bản 3.0) có vấn đề
sử dụng DMA vào bộ nhớ chip.  Giá trị mặc định là 0, tức là sử dụng DMA nếu
có thể.


5.4) gvp11=
-----------

:Cú pháp: gvp11=<addr-mask>

Các phiên bản trước của trình điều khiển GVP không xử lý được DMA
cài đặt mặt nạ địa chỉ một cách chính xác, điều này khiến một số người cần
mọi người sử dụng tùy chọn này để có được bộ điều khiển GVP của họ
chạy dưới Linux. Những vấn đề này hy vọng đã được giải quyết và
việc sử dụng tùy chọn này hiện không được khuyến khích!

Việc sử dụng không đúng cách có thể dẫn đến hành vi không thể đoán trước, vì vậy vui lòng chỉ sử dụng
tùy chọn này nếu bạn ZZ0000ZZ bạn đang làm gì và có lý do để làm
vậy. Trong mọi trường hợp nếu bạn gặp vấn đề và cần sử dụng
tùy chọn, vui lòng thông báo cho chúng tôi về nó bằng cách gửi thư tới nhân Linux/68k
danh sách gửi thư.

Mặt nạ địa chỉ được đặt theo tùy chọn này chỉ định địa chỉ nào được
hợp lệ cho DMA với bộ điều khiển GVP Series II SCSI. Một địa chỉ là
hợp lệ, nếu không có bit nào được đặt ngoại trừ các bit được đặt trong mặt nạ,
quá.

Một số phiên bản của GVP chỉ có thể đưa DMA vào dải địa chỉ 24 bit,
một số có thể giải quyết dải địa chỉ 25 bit trong khi một số khác có thể sử dụng toàn bộ
Dải địa chỉ 32 bit cho DMA. Cài đặt chính xác tùy thuộc vào bạn
bộ điều khiển và phải được trình điều khiển tự động phát hiện. Một ví dụ là
Vùng 24 bit được chỉ định bởi mặt nạ 0x00fffffe.
