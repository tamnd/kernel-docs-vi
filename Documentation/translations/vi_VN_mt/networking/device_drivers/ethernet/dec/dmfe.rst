.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/dec/dmfe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================================
Trình điều khiển ethernet nhanh Davicom DM9102(A)/DM9132/DM9801 cho Linux
==============================================================

Lưu ý: Trình điều khiển này không có bộ bảo trì.


Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc
sửa đổi nó theo các điều khoản của Giấy phép Công cộng GNU
do Tổ chức Phần mềm Tự do xuất bản; cả phiên bản 2
của Giấy phép hoặc (tùy theo lựa chọn của bạn) bất kỳ phiên bản nào sau này.

Chương trình này được phân phối với hy vọng rằng nó sẽ hữu ích,
nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
Giấy phép Công cộng GNU để biết thêm chi tiết.


Trình điều khiển này cung cấp hỗ trợ kernel cho thẻ ethernet Davicom DM9102(A)/DM9132/DM9801 ( CNET
Card ethernet 10/100 cũng sử dụng chipset Davicom nên driver này cũng hỗ trợ card CNET). Nếu bạn
không biên dịch trình điều khiển này thành một mô-đun, nó sẽ tự động tải khi khởi động và in một
dòng tương tự như::

dmfe: Trình điều khiển mạng Davicom DM9xxx, phiên bản 1.36.4 (17-01-2002)

Nếu bạn biên dịch trình điều khiển này dưới dạng mô-đun, bạn phải tải nó khi khởi động. Bạn có thể tải nó bằng lệnh::

insmod dmfe

Bằng cách này, nó sẽ tự động phát hiện chế độ thiết bị. Đây là cách được đề xuất để tải mô-đun. Hoặc bạn có thể chuyển
a mode= cài đặt thành mô-đun trong khi tải, như ::

chế độ insmod dmfe=0 # Force 10M Bán song công
	chế độ insmod dmfe=1 # Force 100M Bán song công
	chế độ insmod dmfe=4 # Force 10M song công hoàn toàn
	chế độ insmod dmfe=5 # Force 100M song công hoàn toàn

Tiếp theo, bạn nên định cấu hình giao diện mạng của mình bằng lệnh tương tự như ::

ifconfig eth0 172.22.3.18
		      ^^ ^^^ ^^ ^^ ^^ ^^
		     Địa chỉ IP của bạn

Sau đó, bạn có thể phải sửa đổi bảng định tuyến mặc định bằng lệnh::

tuyến đường thêm eth0 mặc định


Bây giờ thẻ ethernet của bạn đã hoạt động.


TODO:

- Triển khai các phương thức quản lý năng lượng pci_driver::suspend() và pci_driver::resume().
- Kiểm tra các hộp 64 bit.
- Kiểm tra và sửa chữa các hộp endian lớn.
- Kiểm tra và đảm bảo độ trễ PCI hiện chính xác cho mọi trường hợp.


tác giả:

Sten Wang <sten_wang@davicom.com.tw > : Tác giả gốc

Người đóng góp:

- Marcelo Tosatti <marcelo@conectiva.com.br>
- Alan Cox <alan@lxorguk.ukuu.org.uk>
- Jeff Garzik <jgarzik@pobox.com>
- Vojtech Pavlik <vojtech@suse.cz>