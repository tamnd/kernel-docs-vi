.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/aha152x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===============================================================
Trình điều khiển Adaptec AHA-1520/1522 SCSI cho Linux (aha152x)
===============================================================

Bản quyền ZZ0000ZZ 1993-1999 Jürgen Fischer <fischer@norbit.de>

Bản vá TC1550 của Luuk van Dijk (ldz@xs4all.nl)


Trong Phiên bản 2 trình điều khiển đã được sửa đổi rất nhiều (đặc biệt là
trình xử lý nửa dưới hoàn thành()).

Driver bây giờ sạch hơn nhiều, có hỗ trợ bản mới
mã xử lý lỗi trong phiên bản 2.3, tạo ra tải CPU ít hơn (nhiều
ít vòng bỏ phiếu hơn), có thông lượng cao hơn một chút (tại
ít nhất là trên hộp thử nghiệm cổ xưa của tôi; i486/33Mhz/20MB).


Đối số cấu hình
=======================

============= ====================================================================
Địa chỉ io cơ sở IOPORT (0x340/0x140)
Mức ngắt IRQ (9-12; mặc định 11)
SCSI_ID scsi id của bộ điều khiển (0-7; mặc định 7)
RECONNECT cho phép các mục tiêu ngắt kết nối khỏi bus (0/1; mặc định 1 [bật])
PARITY cho phép kiểm tra tính chẵn lẻ (0/1; mặc định 1 [bật])
SYNCHRONOUS cho phép truyền đồng bộ (0/1; mặc định 1 [bật])
DELAY: độ trễ đặt lại bus (mặc định 100)
EXT_TRANS: bật dịch mở rộng (0/1: mặc định 0 [tắt])
              (xem NOTES)
============= ====================================================================

Biên dịch cấu hình thời gian
============================

(đi vào AHA152X trong trình điều khiển/scsi/Makefile):

-DAUTOCONF
    sử dụng cấu hình mà bộ điều khiển báo cáo (chỉ AHA-152x)

-DSKIP_BIOSTEST
    Không kiểm tra chữ ký BIOS (AHA-1510 hoặc BIOS bị vô hiệu hóa)

- DSETUP0="{ IOPORT, IRQ, SCSI_ID, RECONNECT, PARITY, SYNCHRONOUS, DELAY, EXT_TRANS }"
    ghi đè cho bộ điều khiển đầu tiên

- DSETUP1="{ IOPORT, IRQ, SCSI_ID, RECONNECT, PARITY, SYNCHRONOUS, DELAY, EXT_TRANS }"
    ghi đè cho bộ điều khiển thứ hai

-DAHA152X_DEBUG
    bật đầu ra gỡ lỗi

-DAHA152X_STAT
    kích hoạt một số thống kê


Tùy chọn dòng lệnh LILO
=========================

 ::

aha152x=<IOPORT>[,<IRQ>[,<SCSI-ID>[,<RECONNECT>[,<PARITY>[,<SYNCHRONOUS>[,<DELAY> [,<EXT_TRANS]]]]]]]

Cấu hình bình thường có thể được ghi đè bằng cách chỉ định một dòng lệnh.
 Khi bạn thực hiện việc này, bài kiểm tra BIOS sẽ bị bỏ qua. Các giá trị được nhập phải là
 hợp lệ (đã biết).  Không sử dụng các giá trị không được hỗ trợ theo cách thông thường
 hoạt động.  Nếu bạn nghĩ rằng bạn cần các giá trị khác: hãy liên hệ với tôi.
 Đối với hai bộ điều khiển, hãy sử dụng câu lệnh aha152x hai lần.


Ký hiệu cho cấu hình mô-đun
================================

Chọn từ 2 phương án thay thế:

1. chỉ định mọi thứ (cũ)::

aha152x=IOPORT,IRQ,SCSI_ID,RECONNECT,PARITY,SYNCHRONOUS,DELAY,EXT_TRANS

ghi đè cấu hình cho bộ điều khiển đầu tiên

  ::

aha152x1=IOPORT,IRQ,SCSI_ID,RECONNECT,PARITY,SYNCHRONOUS,DELAY,EXT_TRANS

ghi đè cấu hình cho bộ điều khiển thứ hai

2. chỉ xác định những gì bạn cần (irq hoặc io là bắt buộc; mới)

io=IOPORT0[,IOPORT1]
  IOPORT cho bộ điều khiển thứ nhất và thứ hai

irq=IRQ0[,IRQ1]
  IRQ cho bộ điều khiển thứ nhất và thứ hai

scsiid=SCSIID0[,SCSIID1]
  SCSIID cho bộ điều khiển thứ nhất và thứ hai

kết nối lại=RECONNECT0[,RECONNECT1]
  cho phép mục tiêu ngắt kết nối đối với bộ điều khiển thứ nhất và thứ hai

chẵn lẻ=PAR0[PAR1]
  sử dụng tính chẵn lẻ cho bộ điều khiển thứ nhất và thứ hai

đồng bộ=SYNCHRONOUS0[,SYNCHRONOUS1]
  cho phép truyền đồng bộ cho bộ điều khiển thứ nhất và thứ hai

độ trễ=DELAY0[,DELAY1]
  đặt lại DELAY cho bộ điều khiển thứ nhất và thứ hai

exttrans=EXTTRANS0[,EXTTRANS1]
  bật dịch mở rộng cho bộ điều khiển thứ nhất và thứ hai


Nếu bạn sử dụng cả hai lựa chọn thay thế thì lựa chọn đầu tiên sẽ được thực hiện.


Ghi chú về EXT_TRANS
====================

SCSI sử dụng số khối để đánh địa chỉ các khối/cung trên thiết bị.
BIOS sử dụng sơ đồ địa chỉ hình trụ/đầu/sector (C/H/S)
kế hoạch thay thế.  DOS mong đợi BIOS hoặc trình điều khiển hiểu được điều này
Địa chỉ C/H/S.

Số lượng hình trụ/đầu/sung được gọi là hình học và bắt buộc phải có
làm cơ sở cho các yêu cầu về địa chỉ C/H/S.  SCSI chỉ biết về
tổng dung lượng của đĩa tính theo khối (sector).

Do đó, trình điều khiển SCSI BIOS/DOS phải tính toán logic/ảo
hình học chỉ để có thể hỗ trợ sơ đồ địa chỉ đó.  Hình học
được trả về bởi SCSI BIOS là một phép tính thuần túy và không có gì để
làm với hình dạng thực/vật lý của đĩa (thường là
dù sao cũng không liên quan).

Về cơ bản điều này không ảnh hưởng gì đến Linux cả, vì nó cũng sử dụng khối
thay vì đánh địa chỉ C/H/S.  Thật không may, địa chỉ C/H/S cũng được sử dụng
trong bảng phân vùng và do đó mọi hệ điều hành đều phải biết
hình học phù hợp để có thể diễn giải nó.

Hơn nữa, có một số hạn chế nhất định đối với sơ đồ đánh địa chỉ C/H/S,
cụ thể là không gian địa chỉ được giới hạn tối đa 255 đầu, tối đa 63 lĩnh vực
và tối đa là 1023 xi lanh.

AHA-1522 BIOS tính toán hình học bằng cách cố định số lượng đầu
đến 64, số ngành là 32 và bằng cách tính số lượng
trụ bằng cách chia dung lượng được báo cáo bởi đĩa cho 64*32 (1 MB).
Đây được coi là bản dịch mặc định.

Đối với giới hạn 1023 xi lanh sử dụng C/H/S, bạn chỉ có thể
giải quyết GB đầu tiên của đĩa của bạn trong bảng phân vùng.  Vì thế
BIOS của một số bộ điều khiển mới hơn dựa trên hỗ trợ AIC-6260/6360
dịch mở rộng.  Điều này có nghĩa là BIOS sử dụng 255 cho đầu,
63 cho các cung rồi chia dung lượng của đĩa cho 255*63
(khoảng 8 MB), ngay khi nó nhìn thấy một đĩa lớn hơn 1 GB.  Kết quả đó
trong không gian đĩa có địa chỉ tối đa khoảng 8 GB trong bảng phân vùng
(nhưng ngày nay đã có những đĩa lớn hơn).

Để làm cho nó phức tạp hơn nữa, chế độ dịch có thể/có thể
không thể cấu hình được trong một số thiết lập BIOS nhất định.

Trình điều khiển này ít nhiều thực hiện một số dự đoán an toàn để có được
hình học đúng trong hầu hết các trường hợp:

- đối với đĩa <1GB: sử dụng bản dịch mặc định (C/32/64)

- đối với đĩa> 1GB:

- lấy hình học hiện tại từ bảng phân vùng
    (sử dụng scsicam_bios_param và chỉ chấp nhận hình học 'hợp lệ',
    tức là. (C/32/64) hoặc (C/63/255)).  Điều này có thể được mở rộng dịch
    ngay cả khi nó không được kích hoạt trong trình điều khiển.

- nếu không thành công, hãy sử dụng bản dịch mở rộng nếu được bật bằng cách ghi đè,
    tham số hạt nhân hoặc mô-đun, nếu không thì lấy bản dịch mặc định và
    yêu cầu người dùng xác minh.  Điều này có thể chưa được phân vùng
    đĩa.


Tài liệu tham khảo được sử dụng
===============================

"Thông số kỹ thuật chip AIC-6260 SCSI", Tập đoàn Adaptec.

"SCSI COMPUTER SYSTEM INTERFACE - 2 (SCSI-2)", X3T9.2/86-109 rev. 10h

"Viết trình điều khiển thiết bị SCSI cho Linux", Rik Faith (faith@cs.unc.edu)

"Hướng dẫn dành cho hacker hạt nhân", Michael K. Johnson (johnsonm@sunsite.unc.edu)

"Hướng dẫn sử dụng Adaptec 1520/1522", Tập đoàn Adaptec.

Michael K. Johnson (johnsonm@sunsite.unc.edu)

Drew Eckhardt (drew@cs.colorado.edu)

Eric Youngdale (eric@andante.org)

lời cảm ơn đặc biệt tới Eric Youngdale vì đã cung cấp (!) miễn phí
 tài liệu trên chip.