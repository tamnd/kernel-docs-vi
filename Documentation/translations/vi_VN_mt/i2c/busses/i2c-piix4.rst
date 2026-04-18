.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-piix4.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================
Trình điều khiển hạt nhân i2c-piix4
===================================

Bộ điều hợp được hỗ trợ:
  * Intel 82371AB PIIX4 và PIIX4E
  * Intel 82443MX (440MX)
    Bảng dữ liệu: Có sẵn công khai tại trang web của Intel
  * Cầu nam ServerWorks OSB4, CSB5, CSB6, HT-1000 và HT-1100
    Bảng dữ liệu: Chỉ có sẵn qua NDA từ ServerWorks
  * Cầu nam ATI IXP200, IXP300, IXP400, SB600, SB700 và SB800
    Bảng dữ liệu: Không có sẵn công khai
    Tham khảo đăng ký SB700 có sẵn tại:
    ZZ0000ZZ
  * AMD SP5100 (dẫn xuất SB700 được tìm thấy trên một số bo mạch chính của máy chủ)
    Bảng dữ liệu: Có sẵn công khai tại trang web AMD
    ZZ0001ZZ
  * AMD Hudson-2, ML, CZ
    Bảng dữ liệu: Không có sẵn công khai
  * Hygon CZ
    Bảng dữ liệu: Không có sẵn công khai
  * Cầu nam tiêu chuẩn Microsystems (SMSC) SLC90E66 (Victory66)
    Bảng dữ liệu: Có sẵn công khai tại trang web SMSC ZZ0002ZZ

tác giả:
	- Frodo Looijaard <frodol@dds.nl>
	- Philip Edelbrock <phil@netroedge.com>


Thông số mô-đun
-----------------

* lực: int
  Buộc kích hoạt PIIX4. DANGEROUS!
* Force_addr: int
  Buộc kích hoạt PIIX4 tại địa chỉ đã cho. EXTREMELY DANGEROUS!


Sự miêu tả
-----------

PIIX4 (được gọi đúng là 82371AB) là một chip Intel có rất nhiều
chức năng. Trong số những thứ khác, nó triển khai bus PCI. Một trong số đó
các chức năng nhỏ đang triển khai Bus quản lý hệ thống. Đây là sự thật
SMBus - bạn không thể truy cập nó ở cấp độ I2C. Tin tốt là nó
thực sự hiểu các lệnh SMBus và bạn không phải lo lắng về
vấn đề về thời gian. Tin xấu là các thiết bị không phải SMBus được kết nối với nó có thể
làm nó bối rối quá. Vâng, điều này được biết là xảy ra ...

Thực hiện ZZ0000ZZ và xem liệu nó có chứa mục như thế này không::

0000:00:02.3 Cầu nối: Intel Corp. 82371AB/EB/MB PIIX4 ACPI (rev 02)
	       Cờ: devsel trung bình, IRQ 9

Số bus và số thiết bị có thể khác nhau nhưng số chức năng phải là
giống hệt nhau (giống như nhiều thiết bị PCI, PIIX4 kết hợp một số
'chức năng' khác nhau, có thể được coi là các thiết bị riêng biệt). Nếu bạn
tìm thấy mục như vậy, bạn có bộ điều khiển SMBus PIIX4.

Trên một số máy tính (đáng chú ý nhất là một số máy Dell), SMBus bị vô hiệu hóa bởi
mặc định. Nếu bạn sử dụng tham số insmod 'force=1', mô-đun hạt nhân sẽ
cố gắng kích hoạt nó. THIS LÀ VERY DANGEROUS! Nếu BIOS không thiết lập
địa chỉ chính xác cho mô-đun này, bạn có thể gặp rắc rối lớn (đọc:
sự cố, hỏng dữ liệu, v.v.). Chỉ thử cách này như là phương sách cuối cùng (thử BIOS
chẳng hạn như cập nhật trước) và sao lưu trước! Một điều thậm chí còn nguy hiểm hơn
tùy chọn là 'force_addr=<IOPORT>'. Điều này sẽ không chỉ kích hoạt PIIX4 như
'bắt buộc' thì có, nhưng nó cũng sẽ đặt địa chỉ cổng I/O cơ sở mới. SMBus
các bộ phận của PIIX4 cần có 8 địa chỉ trong số này để hoạt động
một cách chính xác. Nếu những địa chỉ này đã được đặt trước bởi một số thiết bị khác,
bạn sẽ gặp rắc rối lớn! DON'T USE THIS NẾU YOU ARE NOT VERY SURE
ABOUT WHAT YOU ARE DOING!

PIIX4E chỉ là phiên bản mới của PIIX4; nó cũng được hỗ trợ.
PIIX/PIIX3 không triển khai bus SMBus hoặc I2C, vì vậy bạn không thể sử dụng
trình điều khiển này trên các bo mạch chính đó.

Southbridges của ServerWorks, Intel 440MX và Victory66 là
giống hệt PIIX4 trong hỗ trợ I2C/SMBus.

Các chipset AMD SB700, SB800, SP5100 và Hudson-2 triển khai hai
Bộ điều khiển SMBus tương thích PIIX4. Nếu BIOS của bạn khởi tạo
bộ điều khiển thứ cấp, nó sẽ được trình điều khiển này phát hiện dưới dạng
"Bộ điều khiển máy chủ SMBus phụ trợ".

Nếu bạn sở hữu bo mạch chủ Force CPCI735 hoặc các hệ thống dựa trên OSB4 khác, bạn có thể cần
để thay đổi thanh ghi Chọn ngắt SMBus để bộ điều khiển SMBus sử dụng
chế độ SMI.

1) Sử dụng lệnh ZZ0000ZZ và định vị thiết bị PCI bằng bộ điều khiển SMBus:
   00:0f.0 Cầu ISA: Cầu Nam ServerWorks OSB4 (rev 4f)
   Dòng này có thể khác nhau đối với các chipset khác nhau. Vui lòng tham khảo nguồn driver
   cho tất cả các id PCI có thể có (và ZZ0001ZZ để khớp với chúng). Hãy giả sử
   thiết bị được đặt tại 00:0f.0.
2) Bây giờ bạn chỉ cần thay đổi giá trị trong thanh ghi 0xD2. Nhận nó đầu tiên với
   lệnh: ZZ0002ZZ
   Nếu giá trị là 0x3 thì bạn cần thay đổi thành 0x1:
   ZZ0003ZZ

Xin lưu ý rằng bạn không cần phải làm điều đó trong mọi trường hợp, chỉ khi SMBus
không hoạt động đúng cách


Các vấn đề cụ thể về phần cứng
------------------------

Trình điều khiển này sẽ từ chối tải trên hệ thống IBM bằng Intel PIIX4 SMBus.
Một số máy này có RFID EEPROM (24RF08) được kết nối với SMBus,
có thể dễ dàng bị hỏng do lỗi máy trạng thái. Đây chủ yếu là
Máy tính xách tay Thinkpad nhưng hệ thống máy tính để bàn cũng có thể bị ảnh hưởng. Chúng tôi không có danh sách
của tất cả các hệ thống bị ảnh hưởng, vì vậy giải pháp an toàn duy nhất là ngăn chặn quyền truy cập vào
SMBus trên tất cả các hệ thống IBM (được phát hiện bằng dữ liệu DMI.)


Mô tả trong mã ACPI
----------------------------

Trình điều khiển thiết bị cho chip PIIX4 tạo một bus I2C riêng cho mỗi chip của nó
cổng::

$ i2c detect -l
    ...
i2c-7 cổng bộ chuyển đổi SMBus PIIX4 không xác định 0 ở 0b00 N/A
    i2c-8 cổng bộ chuyển đổi SMBus PIIX4 không xác định 2 ở mức 0b00 N/A
    i2c-9 cổng bộ điều hợp SMBus PIIX4 không xác định 1 ở 0b20 N/A
    ...

Do đó, nếu bạn muốn truy cập một trong các bus này bằng mã ACPI, hãy cổng
các thiết bị con cần được khai báo bên trong thiết bị PIIX::

Phạm vi (\_SB_.PCI0.SMBS)
    {
        Tên (_ADR, 0x00140000)

Thiết bị (SMB0) {
            Tên (_ADR, 0)
        }
        Thiết bị (SMB1) {
            Tên (_ADR, 1)
        }
        Thiết bị (SMB2) {
            Tên (_ADR, 2)
        }
    }

Nếu chương trình cơ sở UEFI của bạn không gặp trường hợp này và bạn không có quyền truy cập vào
mã nguồn, bạn có thể sử dụng Lớp phủ ACPI SSDT để cung cấp các phần còn thiếu. chỉ
hãy nhớ rằng trong trường hợp này bạn sẽ cần tải thêm bảng SSDT của mình
trước khi trình điều khiển piix4 khởi động, tức là bạn nên cung cấp SSDT qua initrd hoặc EFI
các phương thức thay đổi và không thông qua configfs.

Ví dụ về cách sử dụng ở đây là đoạn mã ACPI sẽ gán jc42
trình điều khiển tới thiết bị 0x1C trên bus I2C được tạo bởi cổng PIIX 0::

Thiết bị (JC42) {
        Tên (_HID, "PRP0001")
        Tên (_DDN, "JC42 Cảm biến nhiệt độ")
        Tên (_CRS, ResourceTemplate () {
            I2cSerialBusV2 (
                0x001c,
                Bộ điều khiển được khởi tạo,
                100000,
                Địa chỉMode7Bit,
                "\\_SB.PCI0.SMBS.SMB0",
                0
            )
        })

Tên (_DSD, Gói () {
            ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
            Gói () {
                Gói () { "tương thích", Gói() { "jedec,jc-42.4-temp" } },
            }
        })
    }
