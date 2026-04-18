.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/watchdog/wdt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================================
Giao diện hẹn giờ Watchdog WDT cho hệ điều hành Linux
============================================================

Đánh giá lần cuối: 05/10/2007

Alan Cox <alan@lxorguk.ukuu.org.uk>

-ICS WDT501-P
	- ICS WDT501-P (không có máy đo tốc độ quạt)
	- ICS WDT500-P

Tất cả các giao diện đều cung cấp /dev/watchdog, khi mở phải ghi
trong khoảng thời gian chờ nếu không máy sẽ khởi động lại. Mỗi lần ghi sẽ trì hoãn việc khởi động lại
thời gian chờ khác. Trong trường hợp cơ quan giám sát phần mềm, khả năng
việc khởi động lại sẽ phụ thuộc vào trạng thái của máy và các ngắt. Phần cứng
các bo mạch kéo máy xuống khỏi bộ hẹn giờ trên bo mạch của chính chúng và
sẽ khởi động lại từ hầu hết mọi thứ.

Giao diện giám sát nhiệt độ thứ hai có sẵn trên thẻ WDT501P.
Điều này cung cấp/dev/nhiệt độ. Đây là nhiệt độ bên trong máy
độ F. Mỗi lần đọc trả về một byte đơn cho nhiệt độ.

Giao diện thứ ba ghi lại các thông báo kernel về các sự kiện cảnh báo bổ sung.

Không thể thăm dò thẻ wdt ICS ISA-bus một cách an toàn. Thay vào đó bạn cần phải
truyền địa chỉ IO và tham số khởi động IRQ.  Ví dụ.::

wdt.io=0x240 wdt.irq=11

Các thông số trình điều khiển "wdt" khác là:

=========== ===========================================================
	nhịp tim Nhịp tim của cơ quan giám sát tính bằng giây (mặc định 60)
	nowout Không thể dừng Watchdog một khi đã khởi động (kernel
			tham số xây dựng)
	hỗ trợ máy đo tốc độ quạt WDT501-P (0=tắt, mặc định=0)
	loại WDT501-P Loại thẻ (500 hoặc 501, mặc định=500)
	=========== ===========================================================

Đặc trưng
--------

===============================
		   WDT501P WDT500P
===============================
Hẹn giờ khởi động lại X X
Khởi động lại bên ngoài X X
Giám sát cổng I/O o o
Nhiệt độ X o
Tốc độ quạt X o
Nguồn Dưới X o
Mất điện X o
Quá nóng X o
===============================

Các giao diện sự kiện bên ngoài trên bảng WDT hiện không được hỗ trợ.
Tuy nhiên, số lượng nhỏ được phân bổ cho nó.


Trình điều khiển Watchdog ví dụ:

xem mẫu/cơ quan giám sát/watchdog-simple.c
