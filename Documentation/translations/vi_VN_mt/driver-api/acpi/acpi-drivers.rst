.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/acpi/acpi-drivers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

=============================================
Tại sao sử dụng trình điều khiển ACPI không phải là một ý tưởng hay
=========================================

:Bản quyền: ZZ0000ZZ 2026, Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Mặc dù liên kết trực tiếp các trình điều khiển với các đối tượng struct acpi_device
được gọi là "nút thiết bị ACPI", cho phép cung cấp chức năng cơ bản
ít nhất trong một số trường hợp, nó có vấn đề, liên quan đến những vấn đề chung
tính nhất quán, bố cục sysfs, thứ tự vận hành quản lý nguồn và mã
sự sạch sẽ.

Trước hết, các nút thiết bị ACPI đại diện cho các thực thể phần sụn chứ không phải
phần cứng và trong nhiều trường hợp chúng cung cấp thông tin phụ trợ trên thiết bị
được liệt kê độc lập (như thiết bị hoặc CPU PCI).  Vì thế nhìn chung nó
có vấn đề về việc phân bổ tài nguyên cho chúng vì các thực thể được đại diện bởi
chúng không giải mã địa chỉ trong bộ nhớ hoặc không gian địa chỉ I/O và không
tạo ra các ngắt hoặc tương tự (tất cả điều đó được thực hiện bằng phần cứng).

Thứ hai, theo nguyên tắc chung, struct acpi_device chỉ có thể là cha của một struct khác
cấu trúc acpi_device.  Nếu không phải như vậy thì vị trí của thiết bị con
trong hệ thống phân cấp thiết bị ít nhất là khó hiểu và có thể không đơn giản
để xác định phần cứng cung cấp chức năng được đại diện bởi nó.
Tuy nhiên, việc liên kết trình điều khiển trực tiếp với nút thiết bị ACPI có thể khiến điều đó
xảy ra nếu trình điều khiển nhất định đăng ký thiết bị đầu vào hoặc nguồn đánh thức bên dưới nó,
chẳng hạn.

Tiếp theo, sử dụng hệ thống tạm dừng và tiếp tục gọi lại trực tiếp trên các nút thiết bị ACPI
cũng có vấn đề vì nó có thể khiến vấn đề đặt hàng xuất hiện.  Cụ thể là,
Các nút thiết bị ACPI được đăng ký trước khi liệt kê phần cứng tương ứng với
chúng và chúng nằm trong danh sách PM trước phần lớn các thiết bị khác
đồ vật.  Do đó, thứ tự thực hiện lệnh gọi lại PM của họ có thể
different from what is generally expected.  Ngoài ra, nói chung, sự phụ thuộc
được trả về bởi các đối tượng _DEP không ảnh hưởng đến bản thân các nút thiết bị ACPI, nhưng
các thiết bị "vật lý" được liên kết với chúng, có khả năng là một nguồn nữa
về sự không nhất quán liên quan đến việc coi các nút thiết bị ACPI là thiết bị "thực"
đại diện.

Tất cả những điều trên có nghĩa là các trình điều khiển liên kết với các nút thiết bị ACPI sẽ
thường nên tránh và do đó không nên sử dụng các đối tượng struct acpi_driver.

Hơn nữa, cần có ID thiết bị để liên kết trực tiếp trình điều khiển với thiết bị ACPI
nút, nhưng ID thiết bị thường không được liên kết với tất cả chúng.  Một số
chúng chứa thông tin thay thế cho phép các phần tương ứng của
phần cứng được xác định, ví dụ được biểu thị bằng trả về đối tượng _ADR
giá trị và ID thiết bị không được sử dụng trong những trường hợp đó.  Kết quả là, gây nhầm lẫn
đủ, việc liên kết trình điều khiển ACPI với nút thiết bị ACPI thậm chí có thể là không thể.

Khi điều đó xảy ra, phần cứng tương ứng với thiết bị ACPI nhất định
nút được đại diện bởi một đối tượng thiết bị khác, như struct pci_dev và
Nút thiết bị ACPI là "người bạn đồng hành của ACPI" của thiết bị đó, có thể truy cập thông qua nó
con trỏ fwnode được macro ACPI_COMPANION() sử dụng.  Người bạn đồng hành ACPI nắm giữ
thông tin bổ sung về cấu hình thiết bị và có thể một số "công thức nấu ăn"
về thao tác trên thiết bị ở dạng mã byte AML (ACPI Ngôn ngữ máy)
được cung cấp bởi phần mềm nền tảng.  Do đó, vai trò của nút thiết bị ACPI là
tương tự như vai trò của struct device_node trên hệ thống có Device Tree
được sử dụng để mô tả nền tảng.

Để nhất quán, phương pháp này đã được mở rộng cho các trường hợp ACPI
ID thiết bị được sử dụng.  Cụ thể, trong những trường hợp đó, một đối tượng thiết bị bổ sung là
được tạo để đại diện cho phần cứng tương ứng với thiết bị ACPI nhất định
nút.  Theo mặc định, nó là thiết bị nền tảng, nhưng nó cũng có thể là thiết bị PNP, một thiết bị
Thiết bị CPU hoặc loại thiết bị khác, tùy thuộc vào phần đã cho
phần cứng thực sự là như vậy.  Thậm chí có trường hợp có nhiều thiết bị
"được hỗ trợ" hoặc "đi kèm" bởi một nút thiết bị ACPI (ví dụ: các nút thiết bị ACPI
tương ứng với các GPU có thể cung cấp giao diện phần sụn cho đèn nền
kiểm soát độ sáng ngoài thông tin cấu hình GPU).

Điều này có nghĩa là thực sự không bao giờ cần thiết phải liên kết trực tiếp trình điều khiển với
nút thiết bị ACPI vì có một đối tượng thiết bị "phù hợp" đại diện cho
phần cứng tương ứng có thể được liên kết bởi trình điều khiển "phù hợp" bằng cách sử dụng
nút thiết bị ACPI đã cho làm nút đồng hành ACPI của thiết bị.  Như vậy, về nguyên tắc,
không có lý do gì để sử dụng trình điều khiển ACPI và nếu tất cả chúng đã được thay thế bằng trình điều khiển khác
loại trình điều khiển (ví dụ: trình điều khiển nền tảng), một số mã có thể bị bỏ và
một số phức tạp sẽ biến mất.