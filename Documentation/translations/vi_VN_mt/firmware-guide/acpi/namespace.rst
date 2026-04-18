.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/namespace.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

========================================================
Cây thiết bị ACPI - Đại diện của không gian tên ACPI
===================================================

:Bản quyền: ZZ0000ZZ 2013, Tập đoàn Intel

:Tác giả: Lv Zheng <lv.zheng@intel.com>

:Credit: Cảm ơn sự giúp đỡ của Zhang Rui <rui.zhang@intel.com> và
           Rafael J.Wysocki <rafael.j.wysocki@intel.com>.

Tóm tắt
========
Hệ thống con Linux ACPI chuyển đổi các đối tượng không gian tên ACPI thành Linux
cây thiết bị trong /sys/devices/LNXSYSTM:00 và cập nhật nó theo
nhận các sự kiện thông báo cắm nóng ACPI.  Đối với từng đối tượng thiết bị
trong hệ thống phân cấp này có một liên kết tượng trưng tương ứng trong
/sys/bus/acpi/thiết bị.

Tài liệu này minh họa cấu trúc của cây thiết bị ACPI.

Khối định nghĩa ACPI
======================

Phần sụn ACPI thiết lập RSDP (Con trỏ mô tả hệ thống gốc) trong
không gian địa chỉ bộ nhớ hệ thống trỏ đến XSDT (Hệ thống mở rộng
Bảng mô tả).  XSDT luôn trỏ đến FADT (Đã sửa lỗi ACPI
Bảng Mô tả) sử dụng mục nhập đầu tiên, dữ liệu trong FADT
bao gồm nhiều mục có độ dài cố định khác nhau mô tả các tính năng ACPI cố định
của phần cứng.  FADT chứa một con trỏ tới DSDT
(Bảng mô tả hệ thống khác biệt).  XSDT cũng chứa
các mục trỏ đến có thể có nhiều SSDT (Hệ thống phụ
Bảng mô tả).

Dữ liệu DSDT và SSDT được tổ chức theo cấu trúc dữ liệu được gọi là định nghĩa
các khối chứa định nghĩa của các đối tượng khác nhau, bao gồm ACPI
phương pháp điều khiển, được mã hóa bằng AML (Ngôn ngữ máy ACPI).  Khối dữ liệu
của DSDT cùng với nội dung của SSDT thể hiện sự phân cấp
cấu trúc dữ liệu được gọi là không gian tên ACPI có cấu trúc liên kết phản ánh
cấu trúc của nền tảng phần cứng cơ bản.

Mối quan hệ giữa các Bảng định nghĩa hệ thống ACPI được mô tả ở trên
được minh họa trong sơ đồ sau::

+----------+ +-------+ +--------+ +---------------+
   ZZ0000ZZ +->ZZ0001ZZ +->ZZ0002ZZ ZZ0003ZZ
   +----------+ ZZ0004ZZ +--------+ +-ZZ0005ZZ DSDT ZZ0006ZZ
   ZZ0007ZZ ZZ0008ZZ Mục ZZ0009ZZ ...... ZZ0010ZZ ZZ0011ZZ
   +----------+ ZZ0012ZZ X_DSDT ZZ0013ZZ ZZ0014ZZ |
   ZZ0015ZZ-+ ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ
   +----------+ +-------+ +--------+ ZZ0019ZZ
                  ZZ0020ZZ-------------------ZZ0021ZZ SSDT ZZ0022ZZ
                  +- - - -+ ZZ0023ZZ |
                  ZZ0024ZZ - - - - - - -+ ZZ0025ZZ Khối định nghĩa ZZ0026ZZ
                  +- - - -+ ZZ0027ZZ +-------------------+ |
                                           ZZ0028ZZ +- - - - - - - - - -+ |
                                           +-ZZ0029ZZ SSDT ZZ0030ZZ
                                             ZZ0031ZZ
                                             Khối định nghĩa ZZ0032ZZ ZZ0033ZZ
                                             ZZ0034ZZ
                                             +---------------+
                                                          |
                                             Đang tải OSPM |
                                                         \|/
                                                   +----------------+
                                                   ZZ0035ZZ
                                                   +----------------+

Hình 1. Khối định nghĩa ACPI

.. note:: RSDP can also contain a pointer to the RSDT (Root System
   Description Table).  Platforms provide RSDT to enable
   compatibility with ACPI 1.0 operating systems.  The OS is expected
   to use XSDT, if present.


Ví dụ về không gian tên ACPI
======================

Tất cả các khối định nghĩa được tải vào một không gian tên duy nhất.  Không gian tên
là một hệ thống phân cấp của các đối tượng được xác định bằng tên và đường dẫn.
Các quy ước đặt tên sau đây áp dụng cho tên đối tượng trong ACPI
không gian tên:

1. Tất cả các tên đều dài 32 bit.
   2. Byte đầu tiên của tên phải là một trong các ký tự 'A' - 'Z', '_'.
   3. Mỗi byte còn lại của tên phải là một trong các 'A' - 'Z', '0'
      - '9', '_'.
   4. Tên bắt đầu bằng '_' được bảo lưu theo đặc tả ACPI.
   5. Ký hiệu '\' thể hiện phần gốc của không gian tên (tức là các tên
      được thêm vào trước '\' có liên quan đến gốc không gian tên).
   6. Ký hiệu '^' đại diện cho nút cha của nút không gian tên hiện tại
      (tức là các tên được thêm vào trước '^' có liên quan đến tên gốc của
      nút không gian tên hiện tại).

Hình bên dưới hiển thị một không gian tên ACPI mẫu::

+------+
   Gốc ZZ0000ZZ
   +------+
     |
     | +------+
     +-ZZ0001ZZ Scope(_PR): không gian tên bộ xử lý
     | +------+
     ZZ0002ZZ
     ZZ0003ZZ +------+
     ZZ0004ZZ CPU0 |             Bộ xử lý (CPU0): bộ xử lý đầu tiên
     |     +------+
     |
     | +------+
     +-ZZ0005ZZ Scope(_SB): không gian tên bus hệ thống
     | +------+
     ZZ0006ZZ
     ZZ0007ZZ +------+
     ZZ0008ZZ LID0 |             Thiết bị (LID0); thiết bị nắp
     ZZ0009ZZ +------+
     ZZ0010ZZ |
     ZZ0011ZZ | +------+
     Tên ZZ0012ZZ +-ZZ0013ZZ(_HID, "PNP0C0D"): ID phần cứng
     ZZ0014ZZ | +------+
     ZZ0015ZZ |
     ZZ0016ZZ | +------+
     Phương thức ZZ0017ZZ +-ZZ0018ZZ(_STA): phương thức kiểm soát trạng thái
     ZZ0019ZZ +------+
     ZZ0020ZZ
     ZZ0021ZZ +------+
     ZZ0022ZZ PCI0 |             Thiết bị (PCI0); cầu gốc PCI
     |     +------+
     ZZ0023ZZ
     ZZ0024ZZ +------+
     ZZ0025ZZ _HID |         Tên (_HID, "PNP0A08"): ID phần cứng
     ZZ0026ZZ +------+
     ZZ0027ZZ
     ZZ0028ZZ +------+
     ZZ0029ZZ _CID |         Tên (_CID, "PNP0A03"): ID tương thích
     ZZ0030ZZ +------+
     ZZ0031ZZ
     ZZ0032ZZ +------+
     ZZ0033ZZ RP03 |         Phạm vi (RP03): phạm vi năng lượng PCI0
     ZZ0034ZZ +------+
     ZZ0035ZZ |
     ZZ0036ZZ | +------+
     ZZ0037ZZ +-ZZ0038ZZ PowerResource(PXP3): nguồn năng lượng PCI0
     ZZ0039ZZ +------+
     ZZ0040ZZ
     ZZ0041ZZ +------+
     ZZ0042ZZ GFX0 |         Thiết bị (GFX0): bộ điều hợp đồ họa
     |         +------+
     ZZ0043ZZ
     ZZ0044ZZ +------+
     ZZ0045ZZ _ADR |     Tên (_ADR, 0x00020000): địa chỉ xe buýt PCI
     ZZ0046ZZ +------+
     ZZ0047ZZ
     ZZ0048ZZ +------+
     ZZ0049ZZ DD01 |     Thiết bị (DD01): thiết bị đầu ra LCD
     |             +------+
     ZZ0050ZZ
     ZZ0051ZZ +------+
     ZZ0052ZZ _BCL | Method(_BCL): phương pháp điều khiển đèn nền
     |                 +------+
     |
     | +------+
     +-ZZ0053ZZ Scope(_TZ): không gian tên vùng nhiệt
     | +------+
     ZZ0054ZZ
     ZZ0055ZZ +------+
     ZZ0056ZZ FN00 |             PowerResource(FN00): nguồn năng lượng FAN0
     ZZ0057ZZ +------+
     ZZ0058ZZ
     ZZ0059ZZ +------+
     ZZ0060ZZ FAN0 |             Thiết bị (FAN0): thiết bị làm mát FAN0
     ZZ0061ZZ +------+
     ZZ0062ZZ |
     ZZ0063ZZ | +------+
     Tên ZZ0064ZZ +-ZZ0065ZZ(_HID, "PNP0A0B"): ID phần cứng
     ZZ0066ZZ +------+
     ZZ0067ZZ
     ZZ0068ZZ +------+
     ZZ0069ZZ TZ00 |             ThermalZone(TZ00); vùng nhiệt FAN
     |     +------+
     |
     | +------+
     +-ZZ0070ZZ Scope(_GPE): không gian tên GPE
       +------+

Hình 2. Ví dụ về không gian tên ACPI


Đối tượng thiết bị Linux ACPI
=========================

Hệ thống con ACPI lõi của nhân Linux tạo struct acpi_device
đối tượng cho không gian tên ACPI đối tượng đại diện cho thiết bị, nguồn điện
bộ xử lý, vùng nhiệt.  Những đối tượng đó được xuất sang không gian người dùng thông qua
sysfs làm thư mục trong cây con bên dưới /sys/devices/LNXSYSTM:00.  các
định dạng tên của chúng là <bus_id:instance>, trong đó 'bus_id' đề cập đến
Biểu diễn không gian tên ACPI của đối tượng đã cho và 'thể hiện' được sử dụng
để phân biệt các đối tượng khác nhau của cùng một 'bus_id' (đó là
biểu diễn thập phân hai chữ số của một số nguyên không dấu).

Giá trị của 'bus_id' phụ thuộc vào loại đối tượng có tên đó
một phần như được liệt kê trong bảng dưới đây::

+---+--------+-------+----------+
                ZZ0000ZZ Đối tượng/Tính năng ZZ0001ZZ bus_id |
                +---+--------+-------+----------+
                ZZ0002ZZ Gốc ZZ0003ZZ LNXSYSTM |
                +---+--------+-------+----------+
                Thiết bị ZZ0004ZZ ZZ0005ZZ _HID |
                +---+--------+-------+----------+
                ZZ0006ZZ Bộ xử lý ZZ0007ZZ LNXCPU |
                +---+--------+-------+----------+
                ZZ0008ZZ ThermalZone ZZ0009ZZ LNXTHERM |
                +---+--------+-------+----------+
                ZZ0010ZZ Nguồn điện ZZ0011ZZ LNXPOWER |
                +---+--------+-------+----------+
                ZZ0012ZZ Thiết bị khác Thiết bị ZZ0013ZZ |
                +---+--------+-------+----------+
                ZZ0014ZZ PWR_BUTTON ZZ0015ZZ LNXPWRBN |
                +---+--------+-------+----------+
                ZZ0016ZZ SLP_BUTTON ZZ0017ZZ LNXSLPBN |
                +---+--------+-------+----------+
                Phần mở rộng video ZZ0018ZZ ZZ0019ZZ LNXVIDEO |
                +---+--------+-------+----------+
                Bộ điều khiển ZZ0020ZZ ATA ZZ0021ZZ LNXIOBAY |
                +---+--------+-------+----------+
                Trạm nối ZZ0022ZZ ZZ0023ZZ LNXDOCK |
                +---+--------+-------+----------+

Bảng 1. Ánh xạ đối tượng không gian tên ACPI

Các quy tắc sau áp dụng khi tạo đối tượng struct acpi_device trên
cơ sở nội dung của Bảng mô tả hệ thống ACPI (như
được biểu thị bằng chữ cái ở cột đầu tiên và ký hiệu ở
cột thứ hai của bảng trên):

N:
      Nguồn của đối tượng là một nút không gian tên ACPI (như được biểu thị bởi
      loại đối tượng được đặt tên trong cột thứ hai).  Trong trường hợp đó đối tượng
      thư mục trong sysfs sẽ chứa thuộc tính 'path' có giá trị là
      đường dẫn đầy đủ đến nút từ gốc không gian tên.
   F:
      Đối tượng struct acpi_device được tạo cho phần cứng cố định
      tính năng (như được biểu thị bằng tên của cờ tính năng cố định trong phần thứ hai
      cột), do đó thư mục sysfs của nó sẽ không chứa 'path'
      thuộc tính.
   M:
      Đối tượng struct acpi_device được tạo cho nút không gian tên ACPI
      với các phương pháp điều khiển cụ thể (như được chỉ ra bởi ACPI được xác định
      loại thiết bị ở cột thứ hai).  Thuộc tính 'đường dẫn' chứa
      đường dẫn không gian tên của nó sẽ có trong thư mục sysfs của nó.  cho
      ví dụ: nếu phương thức _BCL hiện diện cho nút không gian tên ACPI, thì một
      đối tượng struct acpi_device với LNXVIDEO 'bus_id' sẽ được tạo cho
      nó.

Cột thứ ba của bảng trên cho biết Hệ thống ACPI nào
Bảng mô tả chứa thông tin được sử dụng để tạo ra
các đối tượng struct acpi_device được biểu thị bằng hàng đã cho (xSDT có nghĩa là DSDT
hoặc SSDT).

Cột thứ tư của bảng trên cho biết thế hệ 'bus_id'
quy tắc của đối tượng struct acpi_device:

_HID:
      _HID ở cột cuối cùng của bảng có nghĩa là bus_id của đối tượng
      được bắt nguồn từ các đối tượng nhận dạng _HID/_CID có trong
      nút không gian tên ACPI tương ứng. Thư mục sysfs của đối tượng
      sau đó sẽ chứa các thuộc tính 'hid' và 'modalias' có thể được
      được sử dụng để truy xuất _HID và _CID của đối tượng đó.
   LNXxxxxxx:
      Thuộc tính 'modalias' cũng có trong struct acpi_device
      các đối tượng có bus_id ở dạng "LNXxxxxx" (thiết bị giả), trong
      trường hợp nào nó chứa chính chuỗi bus_id.
   thiết bị:
      'thiết bị' ở cột cuối cùng của bảng cho biết rằng đối tượng
      bus_id không thể được xác định từ _HID/_CID của tương ứng
      Nút không gian tên ACPI, mặc dù đối tượng đó đại diện cho một thiết bị (ví dụ:
      ví dụ: nó có thể là thiết bị PCI có _ADR được xác định và không có _HID
      hoặc _CID).  Trong trường hợp đó, chuỗi 'thiết bị' sẽ được sử dụng làm
      bus_id của đối tượng.


Keo dán thiết bị vật lý Linux ACPI
===============================

Các đối tượng thiết bị ACPI (tức là struct acpi_device) có thể được liên kết với các đối tượng khác
các đối tượng trong hệ thống phân cấp thiết bị của Linux đại diện cho các thiết bị "vật lý"
(ví dụ: các thiết bị trên bus PCI).  Nếu điều đó xảy ra thì có nghĩa là
đối tượng thiết bị ACPI là "bạn đồng hành" của thiết bị nếu không
được biểu diễn theo một cách khác và được sử dụng (1) để cung cấp cấu hình
thông tin trên thiết bị đó mà không thể có được bằng các phương tiện khác và
(2) thực hiện những việc cụ thể với thiết bị với sự trợ giúp của ACPI
các phương pháp kiểm soát.  Một đối tượng thiết bị ACPI có thể được liên kết theo cách này với
nhiều thiết bị "vật lý".

Nếu một đối tượng thiết bị ACPI được liên kết với một thiết bị "vật lý", sysfs của nó
thư mục chứa liên kết tượng trưng "physical_node" tới sysfs
thư mục của đối tượng thiết bị mục tiêu.  Đổi lại, thiết bị mục tiêu
thư mục sysfs sau đó sẽ chứa liên kết tượng trưng "firmware_node" tới
thư mục sysfs của đối tượng thiết bị ACPI đồng hành.
Cơ chế liên kết dựa vào nhận dạng thiết bị được cung cấp bởi
Không gian tên ACPI.  Ví dụ: nếu có một đối tượng không gian tên ACPI
đại diện cho một thiết bị PCI (tức là một đối tượng thiết bị trong không gian tên ACPI
đối tượng đại diện cho cầu PCI) có _ADR trả về 0x00020000 và
số bus của cầu PCI gốc là 0, thư mục sysfs
đại diện cho đối tượng struct acpi_device được tạo cho ACPI đó
đối tượng không gian tên sẽ chứa liên kết tượng trưng 'physical_node' tới
/sys/devices/pci0000:00/0000:00:02:0/ thư mục sysfs của
thiết bị PCI tương ứng.

Cơ chế liên kết nói chung là dành riêng cho xe buýt.  Cốt lõi của nó
việc triển khai nằm trong tệp driver/acpi/glue.c, nhưng có
các bộ phận bổ sung tùy thuộc vào loại xe buýt được đề cập
ở nơi khác.  Ví dụ: phần dành riêng cho PCI của nó nằm ở
trình điều khiển/pci/pci-acpi.c.


Ví dụ cây thiết bị Linux ACPI
=================================

Hệ thống phân cấp sysfs của các đối tượng struct acpi_device tương ứng với
ví dụ không gian tên ACPI được minh họa trong Hình 2 với việc bổ sung
các thiết bị PWR_BUTTON/SLP_BUTTON cố định được hiển thị bên dưới::

+--------------+---+-----------------+
   ZZ0000ZZ \ ZZ0001ZZ
   +--------------+---+-----------------+
     |
     | +-------------+------+-------+
     +-ZZ0002ZZ Không áp dụng ZZ0003ZZ
     | +-------------+------+-------+
     |
     | +-------------+------+-------+
     +-ZZ0004ZZ Không áp dụng ZZ0005ZZ
     | +-------------+------+-------+
     |
     | +----------+-------------+--------------+
     +-ZZ0006ZZ \_PR_.CPU0 ZZ0007ZZ
     | +----------+-------------+--------------+
     |
     | +-------------+-------+-------+
     +-ZZ0008ZZ \_SB_ ZZ0009ZZ
     | +-------------+-------+-------+
     ZZ0010ZZ
     ZZ0011ZZ +- - - - - - - +- - - - - - +- - - - - - - -+
     ZZ0012ZZ PNP0C0D:00 ZZ0013ZZ acpi:PNP0C0D: |
     ZZ0014ZZ +- - - - - - - +- - - - - - +- - - - - - - -+
     ZZ0015ZZ
     ZZ0016ZZ +-------------+--------------+--------------+
     ZZ0017ZZ PNP0A08:00 ZZ0018ZZ acpi:PNP0A08:PNP0A03: |
     |     +-------------+-------------+--------------+
     ZZ0019ZZ
     ZZ0020ZZ +-------------+------+------+
     Thiết bị ZZ0021ZZ:00 ZZ0022ZZ N/A |
     ZZ0023ZZ +-------------+-------------------+------+
     ZZ0024ZZ |
     ZZ0025ZZ | +-------------+----------------------+----------------+
     ZZ0026ZZ +-ZZ0027ZZ \_SB_.PCI0.RP03.PXP3 ZZ0028ZZ
     ZZ0029ZZ +-------------+----------------------+----------------+
     ZZ0030ZZ
     ZZ0031ZZ +-------------+-----------------+----------------+
     ZZ0032ZZ LNXVIDEO:00 ZZ0033ZZ acpi:LNXVIDEO: |
     |         +-------------+-------------------+----------------+
     ZZ0034ZZ
     ZZ0035ZZ +-------------+-----------------+------+
     Thiết bị ZZ0036ZZ:01 ZZ0037ZZ N/A |
     |             +----------+-----+------+
     |
     | +-------------+-------+-------+
     +-ZZ0038ZZ \_TZ_ ZZ0039ZZ
       +-------------+-------+-------+
         |
         | +-------------+-------------+-------+
         +-ZZ0040ZZ \_TZ_.FN00 ZZ0041ZZ
         | +-------------+-------------+-------+
         |
         | +-------------+-------------+---------------+
         +-ZZ0042ZZ \_TZ_.FAN0 ZZ0043ZZ
         | +-------------+-------------+---------------+
         |
         | +-------------+-------------+-------+
         +-ZZ0044ZZ \_TZ_.TZ00 ZZ0045ZZ
           +-------------+-------------+-------+

Hình 3. Ví dụ về cây thiết bị Linux ACPI

.. note:: Each node is represented as "object/path/modalias", where:

   1. 'object' is the name of the object's directory in sysfs.
   2. 'path' is the ACPI namespace path of the corresponding
      ACPI namespace object, as returned by the object's 'path'
      sysfs attribute.
   3. 'modalias' is the value of the object's 'modalias' sysfs
      attribute (as described earlier in this document).

.. note:: N/A indicates the device object does not have the 'path' or the
   'modalias' attribute.