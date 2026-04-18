.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-sis96x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Trình điều khiển hạt nhân i2c-sis96x
====================================

Thay thế 2.4.x i2c-sis645

Bộ điều hợp được hỗ trợ:

* Tập đoàn Hệ thống Tích hợp Silicon (SiS)

Bất kỳ sự kết hợp nào của các cầu nối máy chủ này:
	645, 645DX (còn gọi là 646), 648, 650, 651, 655, 735, 745, 746

và những cây cầu phía nam này:
	961, 962, 963(L)

Tác giả: Mark M. Hoffman <mhoffman@lightlink.com>

Sự miêu tả
-----------

Trình điều khiển duy nhất SMBus này được biết là hoạt động trên các bo mạch chủ có cấu hình trên
kết hợp chipset được đặt tên. Trình điều khiển được phát triển mà không có lợi ích gì
bảng dữ liệu thích hợp từ SiS. Các thanh ghi SMBus được cho là tương thích với
của SiS630, mặc dù chúng nằm ở một vị trí hoàn toàn khác
nơi. Cảm ơn Alexander Malysh <amalysh@web.de> đã cung cấp
Bảng dữ liệu SiS630 (và trình điều khiển).

Lệnh ZZ0000ZZ với quyền root sẽ tạo ra nội dung giống như những dòng sau::

00:00.0 Cầu chủ: Hệ thống tích hợp Silicon [SiS]: Thiết bị không xác định 0645
  00:02.0 Cầu ISA: Hệ thống tích hợp silicon [SiS] 85C503/5513
  00:02.1 SMBus: Hệ thống tích hợp silicon [SiS]: Thiết bị không xác định 0016

hoặc có lẽ thế này::

00:00.0 Cầu chủ: Hệ thống tích hợp Silicon [SiS]: Thiết bị không xác định 0645
  00:02.0 Cầu ISA: Hệ thống tích hợp silicon [SiS]: Thiết bị không xác định 0961
  00:02.1 SMBus: Hệ thống tích hợp silicon [SiS]: Thiết bị không xác định 0016

(các phiên bản kernel muộn hơn 2.4.18 có thể điền vào phần "Không xác định")

Nếu bạn không thể nhìn thấy nó, vui lòng xem quirk_sis_96x_smbus
(drivers/pci/quirks.c) (cũng như nếu phát hiện cầu nam không thành công)

Tôi nghi ngờ rằng trình điều khiển này có thể được tạo để hoạt động cho SiS sau
cả chipset: 635 và 635T. Nếu có ai sở hữu một bảng với những con chip đó
AND sẵn sàng mạo hiểm phá hỏng và đốt cháy một hạt nhân hoạt động tốt
nhân danh tiến độ... vui lòng liên hệ với tôi theo địa chỉ <mhoffman@lightlink.com> hoặc
thông qua danh sách gửi thư linux-i2c: <linux-i2c@vger.kernel.org>.  Vui lòng gửi lỗi
các báo cáo và/hoặc các câu chuyện thành công.


Việc cần làm
------------

* Trình điều khiển không hỗ trợ đọc/ghi khối SMBus; Tôi có thể thêm chúng nếu một
  kịch bản được tìm thấy ở nơi họ cần.


Cảm ơn
---------

Mark D. Studebaker <mdsxyz123@yahoo.com>
 - gợi ý thiết kế và sửa lỗi

Alexander Maylsh <amalysh@web.de>
 - cũng như vậy, cùng với một bảng dữ liệu quan trọng... gần như là bảng dữ liệu tôi thực sự muốn

Hans-Günter Lütke Uphues <hg_lu@t-online.de>
 - bản vá cho SiS735

Robert Zwerus <arzie@dds.nl>
 - kiểm tra SiS645DX

Kianusch Sayah Karadji <kianusch@sk-tech.net>
 - bản vá cho SiS645DX/962

Ken Healy
 - bản vá cho SiS655

Gửi đến những người khác đã viết thư có phản hồi, cảm ơn!
