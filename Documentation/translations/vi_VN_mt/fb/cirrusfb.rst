.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/cirrusfb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Trình điều khiển bộ đệm khung cho chipset Cirrus Logic
============================================

Bản quyền 1999 Jeff Garzik <jgarzik@pobox.com>


.. just a little something to get people going; contributors welcome!


Gia đình chip được hỗ trợ:
	-SD64
	- Piccolo
	- Picasso
	- Quang phổ
	- Núi cao (GD-543x/4x)
	- Picasso4 (GD-5446)
	- GD-5480
	- Laguna (GD-546x)

Xe buýt được hỗ trợ:
	-PCI
	- Zorro

Kiến trúc được hỗ trợ:
	- i386
	- Alpha
	- PPC (Motorola Powerstack)
	- m68k (Amiga)



Chế độ video mặc định
-------------------
Hiện tại, có hai đối số dòng lệnh kernel được hỗ trợ:

-chế độ:640x480
-chế độ: 800x600
- chế độ: 1024x768

Hỗ trợ đầy đủ cho các chế độ video khởi động (modedb) sẽ sớm được tích hợp.

Phiên bản 1.9.9.1
---------------
* Sửa lỗi phát hiện bộ nhớ cho trường hợp 512kB
* Chế độ 800x600
* Thời gian cố định
* Gợi ý cho AXP: Sử dụng -accel false -vyres -1 khi thay đổi độ phân giải


Phiên bản 1.9.4.4
---------------
* Hỗ trợ Laguna sơ bộ
* Đại tu thói quen đăng ký màu.
* Liên kết với những điều trên, màu sắc của bảng điều khiển hiện được lấy từ LUT
  được gọi là 'bảng màu' thay vì từ các thanh ghi VGA.  Mã này đã được
  được mô hình hóa sau đó trong atyfb và matroxfb.
* Dọn dẹp mã, thêm bình luận.
* Đại tu xử lý SR07.
* Sửa lỗi.


Phiên bản 1.9.4.3
---------------
* Đặt chính xác chế độ video khởi động mặc định.
* Không ghi đè cài đặt kích thước ram.  Xác định
  CLGEN_USE_HARDCODED_RAM_SETTINGS nếu bạn _do_ muốn ghi đè RAM
  thiết lập.
* Biên dịch các bản sửa lỗi liên quan đến các thay đổi biểu tượng 2.3.x IORESOURCE_IO[PORT] mới.
* Sử dụng phân bổ tài nguyên 2.3.x mới.
* Một số mã dọn dẹp.


Phiên bản 1.9.4.2
---------------
* Sửa lỗi truyền.
* Các xác nhận không còn gây ra lỗi cố ý nữa.
* Sửa lỗi.


Phiên bản 1.9.4.1
---------------
* Thêm hỗ trợ tương thích.  Hiện yêu cầu kernel 2.1.x, 2.2.x hoặc 2.3.x.


Phiên bản 1.9.4
-------------
* Một số cải tiến, dung lượng bộ nhớ nhỏ hơn, một số sửa lỗi.
* Yêu cầu kernel 2.3.14-pre1 trở lên.


Phiên bản 1.9.3
-------------
* Đi kèm với kernel 2.3.14-pre1 trở lên.
