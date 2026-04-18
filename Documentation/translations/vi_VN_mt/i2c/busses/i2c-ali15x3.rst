.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-ali15x3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Trình điều khiển hạt nhân i2c-ali15x3
=====================================

Bộ điều hợp được hỗ trợ:
  * Acer Labs, Inc. ALI 1533 và 1543C (cầu phía nam)

Bảng dữ liệu: Hiện thuộc NDA
	ZZ0000ZZ

tác giả:
	- Frodo Looijaard <frodol@dds.nl>,
	- Philip Edelbrock <phil@netroedge.com>,
	- Mark D. Studebaker <mdsxyz123@yahoo.com>

Thông số mô-đun
-----------------

* Force_addr: int
    Khởi tạo địa chỉ cơ sở của bộ điều khiển i2c


Ghi chú
-------

Tham số Force_addr hữu ích cho các bảng không đặt địa chỉ trong
BIOS. Không tạo ra lực PCI; thiết bị vẫn phải có mặt trong
lspci. Không sử dụng địa chỉ này trừ khi người lái xe phàn nàn rằng địa chỉ cơ sở là
không được thiết lập.

Ví dụ::

modprobe i2c-ali15x3 Force_addr=0xe800

SMBus bị treo định kỳ trên bo mạch chủ ASUS P5A và chỉ có thể xóa được
bằng một chu kỳ điện. Không rõ nguyên nhân (xem Sự cố bên dưới).


Sự miêu tả
-----------

Đây là trình điều khiển cho Bộ điều khiển máy chủ SMB trên Acer Labs Inc. (ALI)
Cầu Nam M1541 và M1543C.

M1543C là cầu nối phía Nam dành cho hệ thống máy tính để bàn.

M1541 là cầu nối phía Nam dành cho các hệ thống di động.

Chúng là một phần của chipset ALI sau:

* "Aladdin Pro 2" bao gồm cầu Bắc M1621 Slot 1 với AGP và
   Xe buýt phía trước 100 MHz CPU
 * "Aladdin V" bao gồm cầu nối phía Bắc M1541 Ổ cắm 7 với AGP và 100 MHz
   Xe buýt phía trước CPU

Một số bo mạch chủ Aladdin V:
	- Asus P5A
	- Atrend ATC-5220
	-BCM/GVC VP1541
	- Sao sinh học M5ALA
	- Gigabyte GA-5AX (Nói chung là không hoạt động vì BIOS không
	  kích hoạt thiết bị 7101!)
	- Tôi sẽ XA100 Plus
	- Micronics C200
	- Vi sao (MSI) MS-5169

* "Aladdin IV" bao gồm cầu nối phía Bắc M1541 Ổ cắm 7
    với bus chủ lên tới 83,3 MHz.

Để biết tổng quan về các chip này, hãy xem ZZ0000ZZ Tại thời điểm này
toàn bộ bảng dữ liệu trên trang web đều được bảo vệ bằng mật khẩu, tuy nhiên nếu bạn
hãy liên hệ với văn phòng ALI ở San Jose, họ có thể cung cấp cho bạn mật khẩu.

Các thiết bị M1533/M1543C xuất hiện dưới dạng các thiết bị FOUR riêng biệt trên bus PCI. Một
đầu ra của lspci sẽ hiển thị nội dung tương tự như sau ::

00:02.0 Bộ điều khiển USB: Acer Laboratories Inc. M5237 (rev 03)
  00:03.0 Cầu nối: Acer Laboratories Inc. M7101 <= THIS IS THE ONE WE NEED
  00:07.0 Cầu ISA: Acer Laboratories Inc. M1533 (rev c3)
  00:0f.0 Giao diện IDE: Acer Laboratories Inc. M5229 (rev c1)

.. important::

   If you have a M1533 or M1543C on the board and you get
   "ali15x3: Error: Can't detect ali15x3!"
   then run lspci.

   If you see the 1533 and 5229 devices but NOT the 7101 device,
   then you must enable ACPI, the PMU, SMB, or something similar
   in the BIOS.

   The driver won't work if it can't find the M7101 device.

Bộ điều khiển SMB là một phần của thiết bị M7101, tương thích với ACPI
Bộ quản lý nguồn (PMU).

Toàn bộ thiết bị M7101 phải được kích hoạt để SMB hoạt động. bạn không thể
chỉ cần kích hoạt SMB thôi. SMB và ACPI có không gian I/O riêng biệt.
Chúng tôi đảm bảo rằng SMB đã được bật. Chúng tôi để ACPI yên.

Đặc trưng
---------

Trình điều khiển này chỉ điều khiển Máy chủ SMB. Nô lệ SMB
bộ điều khiển trên M15X3 không được bật. Trình điều khiển này không sử dụng
ngắt quãng.


Vấn đề
------

Trình điều khiển này yêu cầu không gian I/O chỉ cho SMB
sổ đăng ký. Nó không sử dụng vùng ACPI.

Trên bo mạch chủ ASUS P5A, có một số báo cáo cho rằng
SMBus sẽ bị treo và điều này chỉ có thể được giải quyết bằng
tắt nguồn máy tính. Nó có vẻ tệ hơn khi hội đồng quản trị
bị nóng, ví dụ như khi tải CPU nặng hoặc vào mùa hè.
Có thể có vấn đề về điện trên bảng này.
Trên P5A, chip cảm biến W83781D có trên cả ISA và
SMBus. Do đó, việc treo SMBus thường có thể tránh được
bằng cách chỉ truy cập W83781D trên xe buýt ISA.
