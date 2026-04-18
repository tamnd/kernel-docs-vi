.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/acpi-info.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Những cân nhắc về ACPI cho cầu nối máy chủ PCI
==============================================

Nguyên tắc chung là không gian tên ACPI phải mô tả mọi thứ
Hệ điều hành có thể sử dụng trừ khi có cách khác để hệ điều hành tìm thấy nó [1, 2].

Ví dụ: không có cơ chế phần cứng tiêu chuẩn để liệt kê PCI
các cầu nối máy chủ, do đó không gian tên ACPI phải mô tả từng cầu nối máy chủ,
phương pháp truy cập không gian cấu hình PCI bên dưới nó, cửa sổ không gian địa chỉ
cầu nối máy chủ chuyển tiếp tới PCI (sử dụng _CRS) và định tuyến kế thừa
Ngắt INTx (sử dụng _PRT).

Các thiết bị PCI nằm bên dưới cầu nối máy chủ thường không cần phải
được mô tả qua ACPI.  Hệ điều hành có thể khám phá chúng thông qua PCI tiêu chuẩn
cơ chế liệt kê, sử dụng quyền truy cập cấu hình để khám phá và xác định
thiết bị và đọc và định cỡ BAR của chúng.  Tuy nhiên, ACPI có thể mô tả PCI
thiết bị nếu nó cung cấp chức năng quản lý nguồn hoặc cắm nóng cho chúng
hoặc nếu thiết bị có ngắt INTx được kết nối bằng ngắt nền tảng
bộ điều khiển và _PRT là cần thiết để mô tả các kết nối đó.

Mô tả tài nguyên ACPI được thực hiện thông qua các đối tượng _CRS của thiết bị trong ACPI
không gian tên [2].   _CRS giống như PCI BAR tổng quát: HĐH có thể đọc
_CRS và tìm ra tài nguyên nào đang được tiêu thụ ngay cả khi nó không có
trình điều khiển cho thiết bị [3].  Điều đó quan trọng vì nó có nghĩa là hệ điều hành cũ
có thể hoạt động chính xác ngay cả trên hệ thống có các thiết bị mới không xác định được hệ điều hành.
Các thiết bị mới có thể không làm được gì cả, nhưng hệ điều hành ít nhất có thể đảm bảo không
nguồn lực xung đột với họ.

Các bảng tĩnh như MCFG, HPET, ECDT, v.v., là các cơ chế ZZ0000ZZ cho
dành riêng không gian địa chỉ.  Các bảng tĩnh dành cho những thứ mà hệ điều hành cần
biết sớm khi khởi động, trước khi nó có thể phân tích không gian tên ACPI.  Nếu một bảng mới
được xác định, một hệ điều hành cũ cần hoạt động chính xác ngay cả khi nó bỏ qua
cái bàn.  _CRS cho phép điều đó bởi vì nó mang tính chung chung và được hiểu theo cách cũ
hệ điều hành; một bảng tĩnh thì không.

Nếu HĐH dự kiến ​​sẽ quản lý một thiết bị không thể phát hiện được mô tả qua
ACPI, thiết bị đó sẽ có _HID/_CID cụ thể cho hệ điều hành biết điều gì
trình điều khiển liên kết với nó và _CRS sẽ thông báo cho hệ điều hành và trình điều khiển nơi
thanh ghi của thiết bị là.

Cầu nối máy chủ PCI là thiết bị PNP0A03 hoặc PNP0A08.  _CRS của họ nên
mô tả tất cả không gian địa chỉ mà họ sử dụng.  Điều này bao gồm tất cả các cửa sổ
chúng chuyển tiếp xuống bus PCI, cũng như các thanh ghi của cầu chủ
chính nó không được chuyển tiếp tới PCI.  Các thanh ghi cầu chủ bao gồm
những thứ như thanh ghi xe buýt phụ/cấp dưới xác định xe buýt
phạm vi bên dưới cầu, thanh ghi cửa sổ mô tả khẩu độ, v.v.
Đây đều là những thứ dành riêng cho thiết bị, không có kiến trúc, vì vậy cách duy nhất
Trình điều khiển PNP0A03/PNP0A08 có thể quản lý chúng thông qua _PRS/_CRS/_SRS, chứa
các chi tiết cụ thể của thiết bị.  Các thanh ghi cầu nối máy chủ cũng bao gồm ECAM
không gian vì nó được sử dụng bởi cầu chủ.

ACPI xác định bit Người tiêu dùng/Nhà sản xuất để phân biệt các thanh ghi cầu nối
("Người tiêu dùng") từ khẩu độ cầu ("Nhà sản xuất") [4, 5], nhưng sớm
BIOS không sử dụng bit đó một cách chính xác.  Kết quả là ACPI hiện tại
thông số kỹ thuật chỉ xác định Người tiêu dùng/Nhà sản xuất cho Không gian địa chỉ mở rộng
mô tả; bit này sẽ bị bỏ qua trong QWord/DWord/Word cũ hơn
Bộ mô tả không gian địa chỉ.  Do đó, hệ điều hành phải đảm nhận tất cả
Bộ mô tả QWord/DWord/Word là cửa sổ.

Trước khi bổ sung các bộ mô tả Không gian địa chỉ mở rộng, lỗi của
Người tiêu dùng/Nhà sản xuất có nghĩa là không có cách nào để mô tả các thanh ghi cầu nối trong
chính thiết bị PNP0A03/PNP0A08.  Cách giải quyết là mô tả
các thanh ghi cầu nối (bao gồm không gian ECAM) trong các thiết bị bắt tất cả PNP0C02 [6].
Ngoại trừ ECAM, không gian thanh ghi cầu nối dành riêng cho thiết bị
dù sao đi nữa, vì vậy trình điều khiển PNP0A03/PNP0A08 chung (pci_root.c) không cần phải
biết về nó.

Kiến trúc mới sẽ có thể sử dụng Không gian địa chỉ mở rộng "Người tiêu dùng"
bộ mô tả trong thiết bị PNP0A03 cho các thanh ghi cầu nối, bao gồm ECAM,
mặc dù cách giải thích chặt chẽ của [6] có thể cấm điều này.  X86 cũ và
Hạt nhân ia64 giả sử tất cả các bộ mô tả không gian địa chỉ, bao gồm cả "Người tiêu dùng"
Không gian địa chỉ mở rộng là các cửa sổ, vì vậy sẽ không an toàn khi sử dụng
mô tả các thanh ghi cầu theo cách này trên các kiến trúc đó.

Các thiết bị "bo mạch chủ" PNP0C02 về cơ bản là một sản phẩm tổng hợp.  không có
mô hình lập trình cho họ ngoài việc "không sử dụng những tài nguyên này cho
bất cứ điều gì khác."  Vì vậy, PNP0C02 _CRS sẽ yêu cầu bất kỳ không gian địa chỉ nào
(1) không được _CRS xác nhận quyền sở hữu dưới bất kỳ đối tượng thiết bị nào khác trong không gian tên ACPI
và (2) hệ điều hành không nên gán cho thứ gì khác.

Thông số PCIe yêu cầu Phương thức truy cập cấu hình nâng cao (ECAM)
trừ khi có giao diện chương trình cơ sở tiêu chuẩn để truy cập cấu hình, ví dụ:
giao diện ia64 SAL [7].  Cầu máy chủ tiêu tốn không gian địa chỉ bộ nhớ ECAM
và chuyển đổi quyền truy cập bộ nhớ thành quyền truy cập cấu hình PCI.  Thông số kỹ thuật
xác định chức năng và bố cục không gian địa chỉ ECAM; chỉ có cơ sở của
không gian địa chỉ dành riêng cho thiết bị.  Hệ điều hành ACPI học địa chỉ cơ sở
từ bảng MCFG tĩnh hoặc phương thức _CBA trong thiết bị PNP0A03.

Bảng MCFG phải mô tả không gian ECAM của máy chủ không thể cắm nóng
cầu [8].  Vì MCFG là một bảng tĩnh và không thể cập nhật bằng hotplug,
phương thức _CBA trong thiết bị PNP0A03 mô tả không gian ECAM của một
cầu nối máy chủ có thể cắm nóng [9].  Lưu ý rằng đối với cả MCFG và _CBA, cơ sở
địa chỉ luôn tương ứng với bus 0, ngay cả khi phạm vi bus ở dưới cầu
(được báo cáo qua _CRS) không bắt đầu từ 0.


[1] ACPI 6.2, giây 6.1:
    Đối với bất kỳ thiết bị nào nằm trên loại bus không thể đếm được (ví dụ: một
    Bus ISA), OSPM liệt kê (các) mã định danh của thiết bị và ACPI
    chương trình cơ sở hệ thống phải cung cấp đối tượng _HID ... cho mỗi thiết bị
    kích hoạt OSPM để làm điều đó.

[2] ACPI 6.2, giây 3.7:
    Hệ điều hành liệt kê các thiết bị bo mạch chủ chỉ bằng cách đọc qua
    Không gian tên ACPI tìm kiếm thiết bị có ID phần cứng.

Mỗi thiết bị được liệt kê bởi ACPI bao gồm các đối tượng được xác định bởi ACPI trong
    Không gian tên ACPI báo cáo tài nguyên phần cứng mà thiết bị có thể
    chiếm [_PRS], một đối tượng báo cáo các tài nguyên hiện đang
    được thiết bị [_CRS] sử dụng và các đối tượng để định cấu hình các tài nguyên đó
    [_SRS].  Thông tin được hệ điều hành Plug and Play (OSPM) sử dụng để
    cấu hình các thiết bị.

[3] ACPI 6.2, giây 6.2:
    OSPM sử dụng các đối tượng cấu hình thiết bị để định cấu hình tài nguyên phần cứng
    cho các thiết bị được liệt kê qua ACPI.  Đối tượng cấu hình thiết bị cung cấp
    thông tin về các yêu cầu nguồn lực hiện tại và có thể,
    mối quan hệ giữa các tài nguyên được chia sẻ và các phương pháp cấu hình
    tài nguyên phần cứng.

Khi OSPM liệt kê một thiết bị, nó sẽ gọi _PRS để xác định tài nguyên
    yêu cầu của thiết bị.  Nó cũng có thể gọi _CRS để tìm hiện tại
    cài đặt tài nguyên cho thiết bị.  Sử dụng thông tin này, Plug and
    Hệ thống Play xác định những tài nguyên nào thiết bị sẽ tiêu thụ và
    đặt các tài nguyên đó bằng cách gọi phương thức điều khiển _SRS của thiết bị.

Trong ACPI, các thiết bị có thể tiêu thụ tài nguyên (ví dụ: bàn phím cũ),
    cung cấp tài nguyên (ví dụ: cầu nối PCI độc quyền) hoặc thực hiện cả hai.
    Trừ khi có quy định khác, tài nguyên cho thiết bị được coi là
    được lấy từ tài nguyên phù hợp gần nhất phía trên thiết bị trong thiết bị
    thứ bậc.

[4] ACPI 6.2, giây 6.4.3.5.1, 2, 3, 4:
    Bộ mô tả không gian địa chỉ QWord/DWord/Word (.1, .2, .3)
      Cờ chung: Bit [0] bị bỏ qua

Bộ mô tả không gian địa chỉ mở rộng (.4)
      Cờ chung: Bit [0] Người tiêu dùng/Nhà sản xuất:

* 1 – Thiết bị này tiêu thụ tài nguyên này
        * 0 – Thiết bị này sản xuất và tiêu thụ tài nguyên này

[5] ACPI 6.2, giây 19.6.43:
    ResourceUsage chỉ định xem phạm vi Bộ nhớ có được sử dụng bởi
    thiết bị này (ResourceConsumer) hoặc được chuyển sang thiết bị con
    (Nhà sản xuất tài nguyên).  Nếu không có gì được chỉ định thì
    ResourceConsumer được giả định.

[6] Firmware PCI 3.2, giây 4.1.2:
    Nếu hệ điều hành không hiểu rõ về việc bảo lưu
    Vùng MMCFG, vùng MMCFG phải được bảo lưu bằng chương trình cơ sở.  các
    dải địa chỉ được báo cáo trong bảng MCFG hoặc bằng phương pháp _CBA (xem Phần
    4.1.3) phải được bảo lưu bằng cách khai báo tài nguyên bo mạch chủ.  Đối với hầu hết
    hệ thống, tài nguyên bo mạch chủ sẽ xuất hiện ở thư mục gốc của ACPI
    không gian tên (dưới \_SB) trong một nút có _HID là EISAID (PNP0C02) và
    các tài nguyên trong trường hợp này không nên được yêu cầu trong bus PCI gốc
    _CRS.  Các tài nguyên có thể được trả về theo tùy chọn trong Int15 E820 hoặc
    EFIGetMemoryMap là bộ nhớ dành riêng nhưng phải luôn được báo cáo thông qua
    ACPI làm tài nguyên bo mạch chủ.

[7] PCI Express 4.0, giây 7.2.2:
    Đối với các hệ thống tương thích với PC hoặc không triển khai
    Tiêu chuẩn giao diện phần sụn dành riêng cho kiến trúc bộ xử lý cho phép
    truy cập vào Không gian cấu hình, cần có ECAM như được xác định trong
    phần này.

[8] Phần mềm PCI 3.2, giây 4.1.2:
    Bảng MCFG là bảng ACPI được sử dụng để giao tiếp cơ sở
    địa chỉ tương ứng với Nhóm phân đoạn PCI không nóng có thể tháo rời
    phạm vi trong Nhóm phân đoạn PCI có sẵn cho hệ điều hành tại
    khởi động. Điều này là cần thiết cho các hệ thống tương thích với PC.

Bảng MCFG chỉ được sử dụng để liên lạc các địa chỉ cơ sở
    tương ứng với các Nhóm phân đoạn PCI có sẵn cho hệ thống tại
    khởi động.

[9] Phần mềm PCI 3.2, giây 4.1.3:
    Phương thức điều khiển _CBA (Địa chỉ cơ sở cấu hình được ánh xạ bộ nhớ) là
    một đối tượng ACPI tùy chọn trả về bộ nhớ 64-bit được ánh xạ
    địa chỉ cơ sở cấu hình cho cầu nối máy chủ có khả năng cắm nóng. các
    địa chỉ cơ sở được trả về bởi _CBA là địa chỉ tương đối của bộ xử lý. _CBA
    phương thức điều khiển đánh giá thành một Số nguyên.

Phương thức điều khiển này xuất hiện dưới đối tượng cầu nối máy chủ. Khi _CBA
    phương thức xuất hiện dưới một đối tượng cầu nối máy chủ đang hoạt động, hệ điều hành
    đánh giá cấu trúc này để xác định cấu hình ánh xạ bộ nhớ
    địa chỉ cơ sở tương ứng với Nhóm phân đoạn PCI cho số xe buýt
    phạm vi được chỉ định trong phương pháp _CRS. Một đối tượng không gian tên ACPI chứa
    phương thức _CBA cũng phải chứa phương thức _SEG tương ứng.