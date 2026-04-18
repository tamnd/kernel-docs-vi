.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/sentelic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=====================
Bàn di chuột Sentelic
=====================


:Bản quyền: ZZ0000ZZ 2002-2011 Tập đoàn Sentelic.

:Cập nhật lần cuối: Dec-07-2011

Bàn phím cảm biến ngón tay Chế độ Intellimouse (bánh xe cuộn, nút thứ 4 và thứ 5)
============================================================================

A) MSID 4: Chế độ bánh xe cuộn cộng với trang Chuyển tiếp (nút thứ 4) và Lùi lại
   trang (nút thứ 5)

1. Đặt tốc độ mẫu thành 200;
2. Đặt tốc độ mẫu thành 200;
3. Đặt tốc độ mẫu thành 80;
4. Đưa ra lệnh "Nhận ID thiết bị" (0xF2) và chờ phản hồi;
5. FSP sẽ phản hồi 0x04.

::

Gói 1
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 |Y|X|y|x|1|M|R|L|  2  |X|X|X|X|X|X|X|X| 3 ZZ0013ZZYZZ0014ZZYZZ0015ZZYZZ0016ZZYZZ0017ZZ ZZ0018ZZBZZ0019ZZWZZ0020ZZWZZ0021ZZ
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7 => Tràn Y
	    Bit6 => X tràn
	    Bit5 => Bit dấu Y
	    Bit4 => Bit dấu X
	    Bit3 => 1
	    Bit2 => Nút giữa, 1 được nhấn, 0 không được nhấn.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Chuyển động X (số nguyên bù 9 bit 2)
    Byte 3: Chuyển động Y (số nguyên bù 9 bit 2)
    Byte 4: Bit3~Bit0 => chuyển động của con lăn kể từ lần báo cáo dữ liệu cuối cùng.
			giá trị hợp lệ, -8 ~ +7
	    Bit4 => 1 = Nhấn nút chuột thứ 4, Forward một trang.
		    0 = Nút chuột thứ 4 không được nhấn.
	    Bit5 => 1 = Nhấn nút chuột thứ 5, Lùi lại một trang.
		    0 = nút chuột thứ 5 không được nhấn.

B) MSID 6: Cuộn ngang và cuộn dọc

- Đặt bit 1 trong thanh ghi 0x40 thành 1

FSP thay thế chuyển động của bánh xe cuộn thành 4 bit để hiển thị theo chiều ngang và
cuộn dọc.

::

Gói 1
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 |Y|X|y|x|1|M|R|L|  2  |X|X|X|X|X|X|X|X| 3 ZZ0013ZZYZZ0014ZZYZZ0015ZZYZZ0016ZZYZZ0017ZZ | |B|F|r|l|u|d|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7 => Tràn Y
	    Bit6 => X tràn
	    Bit5 => Bit dấu Y
	    Bit4 => Bit dấu X
	    Bit3 => 1
	    Bit2 => Nút giữa, 1 được nhấn, 0 không được nhấn.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Chuyển động X (số nguyên bù 9 bit 2)
    Byte 3: Chuyển động Y (số nguyên bù 9 bit 2)
    Byte 4: Bit0 => chuyển động cuộn dọc xuống dưới.
	    Bit1 => chuyển động cuộn dọc lên trên.
	    Bit2 => chuyển động cuộn ngang sang trái.
	    Bit3 => chuyển động cuộn ngang sang phải.
	    Bit4 => 1 = Nhấn nút chuột thứ 4, Forward một trang.
		    0 = Nút chuột thứ 4 không được nhấn.
	    Bit5 => 1 = Nhấn nút chuột thứ 5, Lùi lại một trang.
		    0 = nút chuột thứ 5 không được nhấn.

C) MSID 7

FSP sử dụng 2 gói (8 Byte) để biểu thị Vị trí tuyệt đối.
vì vậy chúng ta có PACKET NUMBER để xác định các gói.

Nếu PACKET NUMBER bằng 0 thì gói đó là Gói 1.
  Nếu PACKET NUMBER là 1 thì gói đó là Gói 2.
  Hãy đếm số này trong chương trình.

Gói đặc biệt MSID6 sẽ được kích hoạt cùng lúc khi kích hoạt MSID 7.

Vị trí tuyệt đối cho STL3886-G0
================================

1. Đặt bit 2 hoặc 3 trong thanh ghi 0x40 thành 1
2. Đặt bit 6 trong thanh ghi 0x40 thành 1

::

Gói 1 (ABSOLUTE POSITION)
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ1ZZ0005ZZ1ZZ0006ZZMZZ0007ZZLZZ0008ZZXZZ0009ZZXZZ0010ZZXZZ0011ZZXZZ0012ZZ 3 |Y|Y|Y|Y|Y|Y|Y|Y|  4 |r|l|d|u|X|X|Y|Y|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói phối hợp tuyệt đối
		    => 10, Gói thông báo
	    Bit5 => bit hợp lệ
	    Bit4 => 1
	    Bit3 => 1
	    Bit2 => Nút giữa, 1 được nhấn, 0 không được nhấn.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Tọa độ X (xpos[9:2])
    Byte 3: Tọa độ Y (ypos[9:2])
    Byte 4: Bit1~Bit0 => Tọa độ Y (xpos[1:0])
	    Bit3~Bit2 => Tọa độ X (ypos[1:0])
	    Bit4 => cuộn lên
	    Bit5 => cuộn xuống
	    Bit6 => cuộn sang trái
	    Bit7 => cuộn sang phải

Gói thông báo cho G0
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ0ZZ0005ZZ1ZZ0006ZZMZZ0007ZZLZZ0008ZZCZZ0009ZZCZZ0010ZZCZZ0011ZZCZZ0012ZZ 3 ZZ0013ZZMZZ0014ZZMZZ0015ZZMZZ0016ZZMZZ0017ZZ0ZZ0018ZZ0ZZ0019ZZ0ZZ0020ZZ0ZZ0021ZZ
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói phối hợp tuyệt đối
		    => 10, Gói thông báo
	    Bit5 => 0
	    Bit4 => 1
	    Bit3 => 1
	    Bit2 => Nút giữa, 1 được nhấn, 0 không được nhấn.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Loại thông báo => 0x5A (Bật/Tắt gói trạng thái)
	    Loại chế độ => 0xA5 (Trạng thái chế độ Bình thường/Biểu tượng)
    Byte 3: Loại thông báo => 0x00 (Đã tắt)
			=> 0x01 (Đã bật)
	    Loại chế độ => 0x00 (Bình thường)
			=> 0x01 (Biểu tượng)
    Byte 4: Bit7~Bit0 => Không quan tâm

Vị trí tuyệt đối cho STL3888-Ax
================================

::

Gói 1 (ABSOLUTE POSITION)
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ1ZZ0005ZZAZZ0006ZZLZZ0007ZZ1ZZ0008ZZXZZ0009ZZXZZ0010ZZXZZ0011ZZXZZ0012ZZ 3 |Y|Y|Y|Y|Y|Y|Y|Y|  4 |x|x|y|y|X|X|Y|Y|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói phối hợp tuyệt đối
		    => 10, Gói thông báo
		    => 11, Gói dữ liệu bình thường với cú nhấp chuột trên bàn phím
	    Bit5 => Bit hợp lệ, 0 nghĩa là tọa độ không hợp lệ hoặc giơ ngón tay lên.
		    Khi cả hai ngón tay đều giơ lên, hai báo cáo cuối cùng không có giá trị
		    chút.
	    Bit4 => cung
	    Bit3 => 1
	    Bit2 => Nút trái, nhấn 1, nhả 0.
	    Bit1 => 0
	    Bit0 => 1
    Byte 2: Tọa độ X (xpos[9:2])
    Byte 3: Tọa độ Y (ypos[9:2])
    Byte 4: Bit1~Bit0 => Tọa độ Y (xpos[1:0])
	    Bit3~Bit2 => Tọa độ X (ypos[1:0])
	    Bit5~Bit4 => y1_g
	    Bit7~Bit6 => x1_g

Gói 2 (ABSOLUTE POSITION)
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ1ZZ0005ZZAZZ0006ZZRZZ0007ZZ0ZZ0008ZZXZZ0009ZZXZZ0010ZZXZZ0011ZZXZZ0012ZZ 3 |Y|Y|Y|Y|Y|Y|Y|Y|  4 |x|x|y|y|X|X|Y|Y|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói tọa độ tuyệt đối
		    => 10, Gói thông báo
		    => 11, Gói dữ liệu bình thường với cú nhấp chuột trên bàn phím
	    Bit5 => Bit hợp lệ, 0 nghĩa là tọa độ không hợp lệ hoặc giơ ngón tay lên.
		    Khi cả hai ngón tay đều giơ lên, hai báo cáo cuối cùng không có giá trị
		    chút.
	    Bit4 => cung
	    Bit3 => 1
	    Bit2 => Nút phải, nhấn 1, nhả 0.
	    Bit1 => 1
	    Bit0 => 0
    Byte 2: Tọa độ X (xpos[9:2])
    Byte 3: Tọa độ Y (ypos[9:2])
    Byte 4: Bit1~Bit0 => Tọa độ Y (xpos[1:0])
	    Bit3~Bit2 => Tọa độ X (ypos[1:0])
	    Bit5~Bit4 => y2_g
	    Bit7~Bit6 => x2_g

Gói thông báo cho STL3888-Axe
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ0ZZ0005ZZPZZ0006ZZMZZ0007ZZLZZ0008ZZCZZ0009ZZCZZ0010ZZCZZ0011ZZCZZ0012ZZ 3 |0|0|F|F|0|0|0|i|  4 |r|l|d|u|0|0|0|0|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói tọa độ tuyệt đối
		    => 10, Gói thông báo
		    => 11, Gói dữ liệu bình thường với cú nhấp chuột trên bàn phím
	    Bit5 => 1
	    Bit4 => khi ở chế độ tọa độ tuyệt đối (hợp lệ khi EN_PKT_GO là 1):
		    0: nút trái được tạo bằng lệnh trên bàn phím
		    1: nút bên trái được tạo bởi nút bên ngoài
	    Bit3 => 1
	    Bit2 => Nút giữa, 1 được nhấn, 0 không được nhấn.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Loại thông báo => 0xB7 (Chế độ Đa ngón tay, Đa tọa độ)
    Byte 3: Bit7~Bit6 => Không quan tâm
	    Bit5~Bit4 => Số ngón tay
	    Bit3~Bit1 => Dành riêng
	    Bit0 => 1: vào chế độ cử chỉ; 0: rời khỏi chế độ cử chỉ
    Byte 4: Bit7 => di chuyển nút sang phải
	    Bit6 => nút cuộn sang trái
	    Bit5 => nút cuộn xuống
	    Bit4 => nút cuộn lên
		* Lưu ý rằng nếu cử chỉ và nút bổ sung (Bit4~Bit7)
		xảy ra cùng lúc, thông tin nút sẽ không
		được gửi đi.
	    Bit3~Bit0 => Dành riêng

Trình tự mẫu của chế độ Đa ngón tay, Đa tọa độ:

gói thông báo (bit hợp lệ == 1), abs pkt 1, abs pkt 2, abs pkt 1,
	abs pkt 2, ..., gói thông báo (bit hợp lệ == 0)

Vị trí tuyệt đối cho STL3888-B0
================================

::

Gói 1(ABSOLUTE POSITION)
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ1ZZ0005ZZFZZ0006ZZ0ZZ0007ZZLZZ0008ZZXZZ0009ZZXZZ0010ZZXZZ0011ZZXZZ0012ZZ 3 |Y|Y|Y|Y|Y|Y|Y|Y|  4 |r|l|u|d|X|X|Y|Y|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói tọa độ tuyệt đối
		    => 10, Gói thông báo
		    => 11, Gói dữ liệu bình thường với cú nhấp chuột trên bàn phím
	    Bit5 => Bit hợp lệ, 0 nghĩa là tọa độ không hợp lệ hoặc giơ ngón tay lên.
		    Khi cả hai ngón tay đều giơ lên, hai báo cáo cuối cùng không có giá trị
		    chút.
	    Bit4 => thông tin ngón tay lên/xuống. 1: ngón tay hướng xuống, 0: ngón tay hướng lên.
	    Bit3 => 1
	    Bit2 => ngón trỏ, 0 là ngón đầu tiên, 1 là ngón thứ hai.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Tọa độ X (xpos[9:2])
    Byte 3: Tọa độ Y (ypos[9:2])
    Byte 4: Bit1~Bit0 => Tọa độ Y (xpos[1:0])
	    Bit3~Bit2 => Tọa độ X (ypos[1:0])
	    Bit4 => nút cuộn xuống
	    Bit5 => nút cuộn lên
	    Bit6 => nút cuộn sang trái
	    Bit7 => nút cuộn sang phải

Gói 2 (ABSOLUTE POSITION)
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ1ZZ0005ZZFZZ0006ZZ1ZZ0007ZZLZZ0008ZZXZZ0009ZZXZZ0010ZZXZZ0011ZZXZZ0012ZZ 3 |Y|Y|Y|Y|Y|Y|Y|Y|  4 |r|l|u|d|X|X|Y|Y|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói phối hợp tuyệt đối
		    => 10, Gói thông báo
		    => 11, Gói dữ liệu bình thường với cú nhấp chuột trên bàn phím
	    Bit5 => Bit hợp lệ, 0 nghĩa là tọa độ không hợp lệ hoặc giơ ngón tay lên.
		    Khi cả hai ngón tay đều giơ lên, hai báo cáo cuối cùng không có giá trị
		    chút.
	    Bit4 => thông tin ngón tay lên/xuống. 1: ngón tay hướng xuống, 0: ngón tay hướng lên.
	    Bit3 => 1
	    Bit2 => ngón trỏ, 0 là ngón đầu tiên, 1 là ngón thứ hai.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Tọa độ X (xpos[9:2])
    Byte 3: Tọa độ Y (ypos[9:2])
    Byte 4: Bit1~Bit0 => Tọa độ Y (xpos[1:0])
	    Bit3~Bit2 => Tọa độ X (ypos[1:0])
	    Bit4 => nút cuộn xuống
	    Bit5 => nút cuộn lên
	    Bit6 => nút cuộn sang trái
	    Bit7 => nút cuộn sang phải

Gói thông báo cho STL3888-B0::

Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ0ZZ0005ZZPZZ0006ZZMZZ0007ZZLZZ0008ZZCZZ0009ZZCZZ0010ZZCZZ0011ZZCZZ0012ZZ 3 |0|0|F|F|0|0|0|i|  4 |r|l|u|d|0|0|0|0|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói phối hợp tuyệt đối
		    => 10, Gói thông báo
		    => 11, Gói dữ liệu bình thường với cú nhấp chuột trên bàn phím
	    Bit5 => 1
	    Bit4 => khi ở chế độ tọa độ tuyệt đối (hợp lệ khi EN_PKT_GO là 1):
		    0: nút trái được tạo bằng lệnh trên bàn phím
		    1: nút bên trái được tạo bởi nút bên ngoài
	    Bit3 => 1
	    Bit2 => Nút giữa, 1 được nhấn, 0 không được nhấn.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Loại thông báo => 0xB7 (Chế độ Đa ngón tay, Đa tọa độ)
    Byte 3: Bit7~Bit6 => Không quan tâm
	    Bit5~Bit4 => Số ngón tay
	    Bit3~Bit1 => Dành riêng
	    Bit0 => 1: vào chế độ cử chỉ; 0: rời khỏi chế độ cử chỉ
    Byte 4: Bit7 => di chuyển nút sang phải
	    Bit6 => nút cuộn sang trái
	    Bit5 => nút cuộn lên
	    Bit4 => nút cuộn xuống
		* Lưu ý rằng nếu cử chỉ và nút bổ sung (Bit4~Bit7)
		xảy ra cùng lúc, thông tin nút sẽ không
		được gửi đi.
	    Bit3~Bit0 => Dành riêng

Trình tự mẫu của chế độ Đa ngón tay, Đa tọa độ:

gói thông báo (bit hợp lệ == 1), abs pkt 1, abs pkt 2, abs pkt 1,
	abs pkt 2, ..., gói thông báo (bit hợp lệ == 0)

Vị trí tuyệt đối cho STL3888-Cx và STL3888-Dx
===============================================

::

Một ngón tay, Chế độ tọa độ tuyệt đối (SFAC)
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ1ZZ0005ZZPZZ0006ZZMZZ0007ZZLZZ0008ZZXZZ0009ZZXZZ0010ZZXZZ0011ZZXZZ0012ZZ 3 |Y|Y|Y|Y|Y|Y|Y|Y|  4 |r|l|B|F|X|X|Y|Y|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói tọa độ tuyệt đối
		    => 10, Gói thông báo
	    Bit5 => Chế độ tọa độ (luôn bằng 0 ở chế độ SFAC):
		    0: chế độ tọa độ tuyệt đối bằng một ngón tay (SFAC)
		    1: chế độ nhiều ngón tay, nhiều tọa độ (MFMC)
	    Bit4 => 0: Nút LEFT được tạo bằng lệnh trên bàn phím (OPC)
		    1: Nút LEFT được tạo bởi nút bên ngoài
		    Mặc định là 1 ngay cả khi không nhấn nút LEFT.
	    Bit3 => Luôn là 1, như được chỉ định bởi giao thức PS/2.
	    Bit2 => Nút giữa, 1 được nhấn, 0 không được nhấn.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Tọa độ X (xpos[9:2])
    Byte 3: Tọa độ Y (ypos[9:2])
    Byte 4: Bit1~Bit0 => Tọa độ Y (xpos[1:0])
	    Bit3~Bit2 => Tọa độ X (ypos[1:0])
	    Bit4 => nút chuột thứ 4 (chuyển tiếp một trang)
	    Bit5 => nút chuột thứ 5 (lùi một trang)
	    Bit6 => nút cuộn sang trái
	    Bit7 => nút cuộn sang phải

Chế độ nhiều ngón tay, nhiều tọa độ (MFMC):
    Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ1ZZ0005ZZPZZ0006ZZFZZ0007ZZLZZ0008ZZXZZ0009ZZXZZ0010ZZXZZ0011ZZXZZ0012ZZ 3 |Y|Y|Y|Y|Y|Y|Y|Y|  4 |r|l|B|F|X|X|Y|Y|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói phối hợp tuyệt đối
		    => 10, Gói thông báo
	    Bit5 => Chế độ tọa độ (luôn là 1 ở chế độ MFMC):
		    0: chế độ tọa độ tuyệt đối bằng một ngón tay (SFAC)
		    1: chế độ nhiều ngón tay, nhiều tọa độ (MFMC)
	    Bit4 => 0: Nút LEFT được tạo bằng lệnh trên bàn phím (OPC)
		    1: Nút LEFT được tạo bởi nút bên ngoài
		    Mặc định là 1 ngay cả khi không nhấn nút LEFT.
	    Bit3 => Luôn là 1, như được chỉ định bởi giao thức PS/2.
	    Bit2 => Ngón trỏ, 0 là ngón đầu tiên, 1 là ngón thứ hai.
		    Nếu bit 1 và 0 đều là 1 và bit 4 là 0 thì phần bên ngoài ở giữa
		    nút được nhấn.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Tọa độ X (xpos[9:2])
    Byte 3: Tọa độ Y (ypos[9:2])
    Byte 4: Bit1~Bit0 => Tọa độ Y (xpos[1:0])
	    Bit3~Bit2 => Tọa độ X (ypos[1:0])
	    Bit4 => nút chuột thứ 4 (chuyển tiếp một trang)
	    Bit5 => nút chuột thứ 5 (lùi một trang)
	    Bit6 => nút cuộn sang trái
	    Bit7 => nút cuộn sang phải

Khi một trong hai ngón tay giơ lên, thiết bị sẽ xuất ra bốn liên tiếp
MFMC#0 báo cáo các gói không có X và Y để thể hiện ngón tay thứ nhất hướng lên hoặc
bốn gói báo cáo MFMC#1 liên tiếp có 0 X và Y để thể hiện điều đó
ngón thứ 2 giơ lên.  Mặt khác, nếu cả hai ngón tay đều hướng lên, thiết bị
sẽ xuất ra bốn gói tọa độ tuyệt đối, một ngón tay liên tiếp (SFAC)
với 0 X và Y.

Gói thông báo cho STL3888-Cx/Dx::

Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZ0ZZ0005ZZPZZ0006ZZMZZ0007ZZLZZ0008ZZCZZ0009ZZCZZ0010ZZCZZ0011ZZCZZ0012ZZ 3 |0|0|F|F|0|0|0|i|  4 |r|l|u|d|0|0|0|0|
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

Byte 1: Bit7~Bit6 => 00, Gói dữ liệu thông thường
		    => 01, Gói tọa độ tuyệt đối
		    => 10, Gói thông báo
	    Bit5 => Luôn là 0
	    Bit4 => 0: Nút LEFT được tạo bằng lệnh trên bàn phím (OPC)
		    1: Nút LEFT được tạo bởi nút bên ngoài
		    Mặc định là 1 ngay cả khi không nhấn nút LEFT.
	    Bit3 => 1
	    Bit2 => Nút giữa, 1 được nhấn, 0 không được nhấn.
	    Bit1 => Nút phải, 1 được nhấn, 0 không được nhấn.
	    Bit0 => Nút trái, 1 được nhấn, 0 không được nhấn.
    Byte 2: Loại thông báo:
	    0xba => thông tin cử chỉ
	    0xc0 => cử chỉ xoay giữ một ngón tay
    Byte 3: Tham số đầu tiên cho tin nhắn nhận được:
	    0xba => ID cử chỉ (tham khảo phần 'ID cử chỉ')
	    0xc0 => ID vùng
    Byte 4: Tham số thứ hai cho tin nhắn nhận được:
	    0xba => Không áp dụng
	    0xc0 => thông tin ngón tay lên/xuống

Trình tự mẫu của chế độ Đa ngón tay, Đa tọa độ:

gói thông báo (bit hợp lệ == 1), gói MFMC 1 (byte 1, bit 2 == 0),
	MFMC gói 2 (byte 1, bit 2 == 1), MFMC gói 1, MFMC gói 2,
	..., notify packet (valid bit == 0)

Nghĩa là khi thiết bị ở chế độ MFMC, máy chủ sẽ nhận được
	các gói tọa độ tuyệt đối xen kẽ cho mỗi ngón tay.

FSP Bật/Tắt gói
=========================

::

Bit 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0
    BYTE ZZ0000ZZBYTE ZZ0001ZZBYTEZZ0002ZZBYTEZZ0003ZZ
      1 ZZ0004ZZXZZ0005ZZ0ZZ0006ZZMZZ0007ZZLZZ0008ZZ0ZZ0009ZZ0ZZ0010ZZ1ZZ0011ZZ1ZZ0012ZZ 3 ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ ZZ0021ZZ
	  ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ

FSP sẽ gửi gói kích hoạt/vô hiệu hóa khi FSP nhận được kích hoạt/vô hiệu hóa PS/2
    lệnh. Máy chủ sẽ nhận gói mà nút Giữa, Phải, Trái sẽ
    được thiết lập. Gói chỉ sử dụng byte 0 và byte 1 làm mẫu của gói gốc.
    Bỏ qua các byte khác của gói.

Byte 1: Bit7 => 0, tràn Y
	    Bit6 => 0, X tràn
	    Bit5 => 0, bit dấu Y
	    Bit4 => 0, bit dấu X
	    Bit3 => 1
	    Bit2 => 1, Nút giữa
	    Bit1 => 1, Nút phải
	    Bit0 => 1, Nút trái
    Byte 2: Bit7~1 => (0101101b)
	    Bit0 => 1 = Kích hoạt
		    0 = Tắt
    Byte 3: Không quan tâm
    Byte 4: Không quan tâm (MOUSE ID 3, 4)
    Byte 5~8: Không quan tâm (Gói tuyệt đối)

Bộ lệnh PS/2
================

FSP hỗ trợ các chế độ và bộ lệnh PS/2 cơ bản, hãy tham khảo URL sau đây để biết
chi tiết về lệnh PS/2:

ZZ0000ZZ

Trình tự lập trình để xác định luồng phân tích gói
========================================================

1. Xác định FSP bằng cách đọc đăng ký ID thiết bị (0x00) và phiên bản (0x01)

2. Đối với phiên bản FSP < STL3888 Cx, hãy xác định số lượng nút bằng cách đọc
   thanh ghi 'trạng thái chế độ kiểm tra' (0x20)::

nút = reg [0x20] & 0x30

nếu nút == 0x30 hoặc nút == 0x20:
		# two/bốn nút
		Tham khảo 'Bàn phím cảm biến ngón tay PS/2 Chuột Intellimouse'
		phần A để biết chi tiết phân tích gói (bỏ qua byte 4, bit ~ 7)
	nút Elif == 0x10:
		Nút # 6
		Tham khảo 'Bàn phím cảm biến ngón tay PS/2 Chuột Intellimouse'
		phần B để biết chi tiết phân tích gói
	nút Elif == 0x00:
		Nút # 6
		Tham khảo 'Bàn phím cảm biến ngón tay PS/2 Chuột Intellimouse'
		phần A để biết chi tiết phân tích gói

3. Đối với phiên bản FSP >= STL3888 Cx:
	Tham khảo 'Bàn phím cảm biến ngón tay PS/2 Chuột Intellimouse'
	phần A để biết chi tiết phân tích gói (bỏ qua byte 4, bit ~ 7)

Trình tự lập trình để đọc/ghi thanh ghi
=================================================

Đăng ký yêu cầu đảo ngược:

Các giá trị sau cần được đảo ngược (toán tử '~' trong C) trước khi được
đã gửi tới FSP::

0xe8, 0xe9, 0xee, 0xf2, 0xf3 và 0xff.

Yêu cầu chuyển đổi đăng ký:

Các giá trị sau cần thiết để có 4 bit cao hơn và 4 bit thấp hơn
được hoán đổi trước khi được gửi tới FSP::

10, 20, 40, 60, 80, 100 và 200.

Đăng ký trình tự đọc:

1. gửi lệnh 0xf3 PS/2 tới FSP;

2. gửi lệnh 0x66 PS/2 tới FSP;

3. gửi lệnh 0x88 PS/2 tới FSP;

4. gửi lệnh 0xf3 PS/2 tới FSP;

5. nếu địa chỉ thanh ghi đang được đọc thì không bắt buộc phải là
	đảo ngược(tham khảo phần 'Đăng ký yêu cầu đảo ngược'),
	chuyển sang bước 6

Một. gửi lệnh 0x68 PS/2 tới FSP;

b. gửi địa chỉ đăng ký đảo ngược tới FSP và chuyển đến bước 8;

6. nếu địa chỉ thanh ghi đang được đọc thì không bắt buộc phải là
	đã hoán đổi (tham khảo phần 'Đăng ký yêu cầu hoán đổi'),
	chuyển sang bước 7

Một. gửi lệnh 0xcc PS/2 tới FSP;

b. gửi địa chỉ thanh ghi đã hoán đổi tới FSP và thực hiện bước 8;

7. gửi lệnh 0x66 PS/2 tới FSP;

Một. gửi địa chỉ đăng ký ban đầu tới FSP và chuyển đến bước 8;

8. gửi lệnh PS/2 0xe9(yêu cầu trạng thái) tới FSP;

9. Byte thứ 4 của phản hồi được đọc từ FSP phải là byte
	giá trị đăng ký được yêu cầu (?? cho biết byte không quan tâm)::

máy chủ: 0xe9
		3888: 0xfa (??) (??) (val)

* Lưu ý rằng kể từ khi phát hành Cx, phần cứng sẽ trả về 1
	  phần bù của giá trị thanh ghi ở byte thứ 3 của yêu cầu trạng thái
	  kết quả::

máy chủ: 0xe9
		3888: 0xfa (??) (~val) (val)

Đăng ký trình tự viết:

1. gửi lệnh 0xf3 PS/2 tới FSP;

2. nếu địa chỉ đăng ký được ghi không bắt buộc phải là
	đảo ngược(tham khảo phần 'Đăng ký yêu cầu đảo ngược'),
	chuyển sang bước 3

Một. gửi lệnh 0x74 PS/2 tới FSP;

b. gửi địa chỉ đăng ký đảo ngược tới FSP và chuyển sang bước 5;

3. nếu địa chỉ đăng ký được ghi không bắt buộc phải là
	đã hoán đổi (tham khảo phần 'Đăng ký yêu cầu hoán đổi'),
	chuyển sang bước 4

Một. gửi lệnh 0x77 PS/2 tới FSP;

b. gửi địa chỉ thanh ghi đã hoán đổi tới FSP và thực hiện bước 5;

4. gửi lệnh 0x55 PS/2 tới FSP;

Một. gửi địa chỉ đăng ký tới FSP và thực hiện bước 5;

5. gửi lệnh 0xf3 PS/2 tới FSP;

6. nếu giá trị đăng ký để ghi không bắt buộc phải là
	đảo ngược(tham khảo phần 'Đăng ký yêu cầu đảo ngược'),
	chuyển sang bước 7

Một. gửi lệnh 0x47 PS/2 tới FSP;

b. gửi giá trị thanh ghi đảo ngược tới FSP và chuyển sang bước 9;

7. nếu giá trị đăng ký để ghi không bắt buộc phải là
	đã hoán đổi (tham khảo phần 'Đăng ký yêu cầu hoán đổi'),
	chuyển sang bước 8

Một. gửi lệnh 0x44 PS/2 tới FSP;

b. gửi giá trị thanh ghi đã hoán đổi tới FSP và chuyển đến bước 9;

8. gửi lệnh 0x33 PS/2 tới FSP;

Một. gửi giá trị đăng ký tới FSP;

9. trình tự ghi sổ đăng ký được hoàn thành.

* Kể từ khi phát hành Cx, phần cứng sẽ trả về 1
	  phần bù của giá trị thanh ghi ở byte thứ 3 của yêu cầu trạng thái
	  kết quả. Máy chủ có thể tùy chọn gửi 0xe9 khác (yêu cầu trạng thái) PS/2
	  lệnh tới FSP khi kết thúc quá trình ghi đăng ký để xác minh rằng
	  thao tác ghi đăng ký thành công (?? biểu thị không quan tâm
	  byte)::

máy chủ: 0xe9
		3888: 0xfa (??) (~val) (val)

Trình tự lập trình để đọc/ghi đăng ký trang
======================================================

Để khắc phục hạn chế về số lượng thanh ghi tối đa
được hỗ trợ, phần cứng sẽ tách thanh ghi thành các nhóm khác nhau được gọi là
'trang.' Mỗi trang có thể bao gồm tối đa 255 thanh ghi.

Trang mặc định sau khi bật nguồn là 0x82; do đó, nếu người ta phải có được
truy cập để đăng ký 0x8301, người ta phải sử dụng trình tự sau để chuyển đổi
đến trang 0x83, sau đó bắt đầu đọc/ghi từ/đến offset 0x01 bằng cách sử dụng
trình tự đọc/ghi thanh ghi được mô tả ở phần trước.

Trình tự đọc đăng ký trang:

1. gửi lệnh 0xf3 PS/2 tới FSP;

2. gửi lệnh 0x66 PS/2 tới FSP;

3. gửi lệnh 0x88 PS/2 tới FSP;

4. gửi lệnh 0xf3 PS/2 tới FSP;

5. gửi lệnh 0x83 PS/2 tới FSP;

6. gửi lệnh 0x88 PS/2 tới FSP;

7. gửi lệnh PS/2 0xe9(yêu cầu trạng thái) tới FSP;

8. phản hồi được đọc từ FSP phải là giá trị trang được yêu cầu.


Trình tự viết đăng ký trang:

1. gửi lệnh 0xf3 PS/2 tới FSP;

2. gửi lệnh 0x38 PS/2 tới FSP;

3. gửi lệnh 0x88 PS/2 tới FSP;

4. gửi lệnh 0xf3 PS/2 tới FSP;

5. nếu địa chỉ trang được viết không bắt buộc phải là
	đảo ngược(tham khảo phần 'Đăng ký yêu cầu đảo ngược'),
	chuyển sang bước 6

Một. gửi lệnh 0x47 PS/2 tới FSP;

b. gửi địa chỉ trang đảo ngược tới FSP và thực hiện bước 9;

6. nếu địa chỉ trang được viết không bắt buộc phải là
	đã hoán đổi (tham khảo phần 'Đăng ký yêu cầu hoán đổi'),
	chuyển sang bước 7

Một. gửi lệnh 0x44 PS/2 tới FSP;

b. gửi địa chỉ trang đã hoán đổi tới FSP và thực hiện bước 9;

7. gửi lệnh 0x33 PS/2 tới FSP;

8. gửi địa chỉ trang tới FSP;

9. trình tự ghi trang đăng ký được hoàn thành.

ID cử chỉ
==========

Không giống như các thiết bị khác gửi tọa độ của nhiều ngón tay đến máy chủ,
FSP xử lý tọa độ của nhiều ngón tay bên trong và chuyển đổi chúng
thành số nguyên 8 bit, cụ thể là 'ID cử chỉ.'  Sau đây là danh sách
ID cử chỉ được hỗ trợ:

======= ======================================
	Mô tả ID
	======= ======================================
	0x86 2 ngón tay thẳng lên
	0x82 2 ngón tay thẳng xuống
	0x80 2 ngón tay thẳng phải
	0x84 2 ngón tay thẳng trái
	0x8f phóng to 2 ngón tay
	0x8b thu nhỏ 2 ngón tay
	0xc0 2 ngón tay cong, ngược chiều kim đồng hồ
	0xc4 đường cong 2 ngón tay, theo chiều kim đồng hồ
	0x2e 3 ngón tay thẳng lên
	0x2a 3 ngón tay thẳng xuống
	0x28 3 ngón tay thẳng phải
	0x2c 3 ngón thẳng trái
	lòng bàn tay 0x38
	======= ======================================

Đăng ký danh sách
================

Các thanh ghi được biểu diễn bằng các giá trị 16 bit. 8 bit cao hơn thể hiện
địa chỉ trang và 8 bit thấp hơn biểu thị độ lệch tương đối trong
trang cụ thể đó.  Tham khảo 'Trình tự lập trình cho Đăng ký trang
Phần Đọc/Viết' để biết hướng dẫn cách thay đổi trang hiện tại
địa chỉ::

tên r/w mặc định có chiều rộng bù đắp
 0x8200 bit7~bit0 0x01 ID thiết bị RO

0x8201 bit7~bit0 ID phiên bản RW
					0xc1: Rìu STL3888
					0xd0 ~ 0xd2: STL3888 Bx
					0xe0 ~ 0xe1: STL3888 Cx
					0xe2 ~ 0xe3: STL3888 Dx

0x8202 bit7~bit0 0x01 ID nhà cung cấp RO

0x8203 bit7~bit0 0x01 ID sản phẩm RO

0x8204 bit3~bit0 0x01 ID sửa đổi RW

Trạng thái chế độ kiểm tra 0x820b 1
	bit3 1 RO 0: xoay 180 độ
					1: không quay
					*chỉ được hỗ trợ bởi H/W trước Cx

Kiểm soát trang tập tin đăng ký 0x820f
	bit2 0 RW 1: xoay 180 độ
					0: không quay
					*được hỗ trợ kể từ Cx

bit0 0 RW 1 để kích hoạt các tập tin đăng ký trang 1
					*chỉ được hỗ trợ bởi H/W trước Cx

Điều khiển hệ thống 0x8210 RW 1
	bit0 1 RW Dự trữ, phải là 1
	bit1 0 RW Dự trữ, phải bằng 0
	bit4 0 RW Dự trữ, phải bằng 0
	kích hoạt tính năng kiểm soát đồng hồ đăng ký bit5 1 RW
					0: chỉ đọc, 1: cho phép đọc/ghi
	(Lưu ý rằng các thanh ghi sau đây không yêu cầu phải có cổng đồng hồ.
	được bật trước khi ghi: 05 06 07 08 09 0c 0f 10 11 12 16 17 18 23 2e
	40 41 42 43. Ngoài ra, bit này phải bằng 1 khi cử chỉ
	chế độ được kích hoạt)

Trạng thái chế độ kiểm tra 0x8220
	bit5~bit4 RO số lượng nút
					11 => 2, lbtn/rbtn
					10 => 4, lbtn/rbtn/scru/scrd
					01 => 6, lbtn/rbtn/scru/scrd/scrl/scrr
					00 => 6, lbtn/rbtn/scru/scrd/fbtn/bbtn
					*chỉ được hỗ trợ bởi H/W trước Cx

Phát hiện lệnh trên bàn phím 0x8231 RW
	bit7 0 RW lệnh on-pad thẻ nút xuống bên trái
					kích hoạt
					0: tắt, 1: bật
					*chỉ được hỗ trợ bởi H/W trước Cx

Điều khiển lệnh trên bàn phím 0x8234 RW 5
	bit4~bit0 0x05 RW XLO trong 0s/4/1, vậy 03h = 0010.1b = 2.5
	(Lưu ý rằng đơn vị vị trí nằm trong dòng quét 0,5)
					*chỉ được hỗ trợ bởi H/W trước Cx

bit7 0 RW bật vùng nhấn trên pad
					0: tắt, 1: bật
					*chỉ được hỗ trợ bởi H/W trước Cx

Điều khiển lệnh trên bàn phím 0x8235 RW 6
	bit4~bit0 0x1d RW XHI trong 0s/4/1, vậy 19h = 1100.1b = 12.5
	(Lưu ý rằng đơn vị vị trí nằm trong dòng quét 0,5)
					*chỉ được hỗ trợ bởi H/W trước Cx

0x8236 RW điều khiển lệnh trên bàn phím 7
	bit4~bit0 0x04 RW YLO trong 0s/4/1, vậy 03h = 0010.1b = 2.5
	(Lưu ý rằng đơn vị vị trí nằm trong dòng quét 0,5)
					*chỉ được hỗ trợ bởi H/W trước Cx

0x8237 RW điều khiển lệnh trên bàn phím 8
	bit4~bit0 0x13 RW YHI trong 0s/4/1, vậy 11h = 1000.1b = 8.5
	(Lưu ý rằng đơn vị vị trí nằm trong dòng quét 0,5)
					*chỉ được hỗ trợ bởi H/W trước Cx

Điều khiển hệ thống 0x8240 RW 5
	bit1 0 RW FSP bật chế độ Intellimouse
					0: tắt, 1: bật
					*chỉ được hỗ trợ bởi H/W trước Cx

chuyển động bit2 0 RW + cơ bụng. bật chế độ tọa độ
					0: tắt, 1: bật
	(Lưu ý rằng chức năng này có chức năng của bit 1 ngay cả khi
	bit 1 chưa được thiết lập. Tuy nhiên, định dạng khác với bit 1.
	Ngoài ra, khi bit 1 và bit 2 được thiết lập cùng lúc, bit 2 sẽ
	ghi đè bit 1.)
					*chỉ được hỗ trợ bởi H/W trước Cx

bit3 0 RW cơ bản. bật chế độ chỉ tọa độ
					0: tắt, 1: bật
	(Lưu ý rằng chức năng này có chức năng của bit 1 ngay cả khi
	bit 1 chưa được thiết lập. Tuy nhiên, định dạng khác với bit 1.
	Ngoài ra, khi bit 1, bit 2 và bit 3 được đặt cùng lúc,
	bit 3 sẽ ghi đè bit 1 và 2.)
					*chỉ được hỗ trợ bởi H/W trước Cx

bật tự động chuyển đổi bit5 0 RW
					0: tắt, 1: bật
					*chỉ được hỗ trợ bởi H/W trước Cx

bit6 0 RW G0 cơ bụng. + thông báo kích hoạt định dạng gói
					0: tắt, 1: bật
	(Lưu ý rằng đầu ra tọa độ tuyệt đối/tương đối vẫn phụ thuộc vào
	bit 2 và 3. Nghĩa là, nếu bất kỳ bit nào trong số đó là 1, máy chủ sẽ nhận được
	tọa độ tuyệt đối; mặt khác, máy chủ chỉ nhận các gói có
	tọa độ tương đối.)
					*chỉ được hỗ trợ bởi H/W trước Cx

bit7 0 RW EN_PS2_F2: Chế độ cử chỉ PS/2 thứ 2
					kích hoạt gói ngón tay
					0: tắt, 1: bật
					*chỉ được hỗ trợ bởi H/W trước Cx

Điều khiển trên bàn phím 0x8243 RW
	bật điều khiển trên pad bit0 0 RW
					0: tắt, 1: bật
	(Lưu ý nếu bit này bị xóa thì bit 3/5 sẽ không có hiệu lực)
					*chỉ được hỗ trợ bởi H/W trước Cx

bit3 0 RW sửa lỗi trên pad cho phép cuộn dọc
					0: tắt, 1: bật
					*chỉ được hỗ trợ bởi H/W trước Cx

bit5 0 RW on-pad sửa lỗi cho phép cuộn ngang
					0: tắt, 1: bật
					*chỉ được hỗ trợ bởi H/W trước Cx

Thanh ghi điều khiển phần mềm 0x8290 RW 1
	chế độ phối hợp tuyệt đối bit0 0 RW
					0: tắt, 1: bật
					*được hỗ trợ kể từ Cx

đầu ra ID cử chỉ bit1 0 RW
					0: tắt, 1: bật
					*được hỗ trợ kể từ Cx

bit2 0 RW đầu ra tọa độ của hai ngón tay
					0: tắt, 1: bật
					*được hỗ trợ kể từ Cx

bit3 0 RW ngón tay lên một gói đầu ra
					0: tắt, 1: bật
					*được hỗ trợ kể từ Cx

bit4 0 RW phối hợp tuyệt đối chế độ liên tục
					0: tắt, 1: bật
					*được hỗ trợ kể từ Cx

Lựa chọn nhóm cử chỉ bit6~bit5 00 RW
					00: cơ bản
					01: bộ
					10: bộ chuyên nghiệp
					11: nâng cao
					*được hỗ trợ kể từ Cx

Chế độ tương thích đầu ra gói bit7 0 RW Bx
					0: tắt, 1: bật
					*được hỗ trợ kể từ Cx
					*được hỗ trợ kể từ Cx


Điều khiển lệnh trên bàn phím 0x833d RW 1
	bit7 1 RW cho phép phát hiện lệnh trên pad
					0: tắt, 1: bật
					*được hỗ trợ kể từ Cx

Phát hiện lệnh trên bàn phím 0x833e RW
	bit7 0 RW lệnh on-pad thẻ nút xuống bên trái
					kích hoạt. Chỉ hoạt động trong PS/2 dựa trên H/W
					chế độ gói dữ liệu
					0: tắt, 1: bật
					*được hỗ trợ kể từ Cx
