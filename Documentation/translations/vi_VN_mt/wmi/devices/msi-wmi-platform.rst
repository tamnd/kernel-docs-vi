.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/wmi/devices/msi-wmi-platform.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================================
Trình điều khiển tính năng nền tảng MSI WMI (msi-wmi-platform)
==============================================================

Giới thiệu
============

Nhiều máy tính xách tay MSI hỗ trợ nhiều tính năng khác nhau như đọc cảm biến quạt. Tính năng này được điều khiển
bởi bộ điều khiển nhúng, với phần sụn ACPI hiển thị giao diện ACPI WMI tiêu chuẩn ở trên cùng
của giao diện bộ điều khiển nhúng.

Mô tả giao diện WMI
=========================

Mô tả giao diện WMI có thể được giải mã từ mã nhị phân MOF (bmof) được nhúng
dữ liệu bằng tiện ích ZZ0000ZZ:

::

[WMI, Ngôn ngữ("MS\0x409"),
   Description("Lớp này chứa định nghĩa của gói được sử dụng trong các lớp khác"),
   hướng dẫn ("{ABBC0F60-8EA1-11d1-00A0-C90629100000}")]
  Gói lớp {
    [WmiDataId(1), đọc, ghi, Mô tả("16 byte dữ liệu")] uint8 Byte[16];
  };

[WMI, Ngôn ngữ("MS\0x409"),
   Description("Lớp này chứa định nghĩa của gói được sử dụng trong các lớp khác"),
   hướng dẫn ("{ABBC0F63-8EA1-11d1-00A0-C90629100000}")]
  gói lớp_32 {
    [WmiDataId(1), đọc, ghi, Mô tả("32 byte dữ liệu")] uint8 Byte[32];
  };

[WMI, Động, Nhà cung cấp("WmiProv"), Ngôn ngữ("MS\0x409"),
   Description("Lớp dùng để vận hành các phương thức trên một gói"),
   hướng dẫn ("{ABBC0F6E-8EA1-11d1-00A0-C90629100000}")]
  lớp MSI_ACPI {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiMethodId(1), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void GetPackage([out, id(0)] Dữ liệu gói);

[WmiMethodId(2), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của gói")]
    void SetPackage([in, id(0)] Dữ liệu gói);

[WmiMethodId(3), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_EC([out, id(0)] Dữ liệu gói_32);

[WmiMethodId(4), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_EC([in, id(0)] Dữ liệu gói_32);

[WmiMethodId(5), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_BIOS([vào, ra, id(0)] Dữ liệu gói_32);

[WmiMethodId(6), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_BIOS([vào, ra, id(0)] Dữ liệu gói_32);

[WmiMethodId(7), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_SMBUS([vào, ra, id(0)] Dữ liệu gói_32);

[WmiMethodId(8), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của gói")]
    void Set_SMBUS([vào, ra, id(0)] Dữ liệu gói_32);

[WmiMethodId(9), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_MasterBattery([in, out, id(0)] Package_32 Data);

[WmiMethodId(10), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của gói")]
    void Set_MasterBattery([in, out, id(0)] Package_32 Data);

[WmiMethodId(11), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_SlaveBattery([in, out, id(0)] Package_32 Data);

[WmiMethodId(12), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_SlaveBattery([in, out, id(0)] Package_32 Data);

[WmiMethodId(13), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_Temperature([in, out, id(0)] Package_32 Data);

[WmiMethodId(14), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_Temperature([in, out, id(0)] Package_32 Data);

[WmiMethodId(15), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_Thermal([in, out, id(0)] Package_32 Data);

[WmiMethodId(16), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_Thermal([in, out, id(0)] Package_32 Data);

[WmiMethodId(17), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_Fan([in, out, id(0)] Package_32 Data);

[WmiMethodId(18), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_Fan([in, out, id(0)] Gói_32 Dữ liệu);

[WmiMethodId(19), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_Device([in, out, id(0)] Package_32 Data);

[WmiMethodId(20), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_Device([in, out, id(0)] Package_32 Data);

[WmiMethodId(21), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_Power([in, out, id(0)] Package_32 Data);

[WmiMethodId(22), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_Power([in, out, id(0)] Gói_32 Dữ liệu);

[WmiMethodId(23), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_Debug([in, out, id(0)] Package_32 Data);

[WmiMethodId(24), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_Debug([in, out, id(0)] Package_32 Data);

[WmiMethodId(25), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_AP([vào, ra, id(0)] Dữ liệu gói_32);

[WmiMethodId(26), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_AP([vào, ra, id(0)] Dữ liệu gói_32);

[WmiMethodId(27), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_Data([in, out, id(0)] Package_32 Data);

[WmiMethodId(28), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của một gói")]
    void Set_Data([in, out, id(0)] Package_32 Data);

[WmiMethodId(29), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của một gói")]
    void Get_WMI([out, id(0)] Gói_32 Dữ liệu);
  };

Do tính đặc thù trong cách Windows xử lý toán tử ZZ0000ZZ ACPI (chỉ lỗi
xảy ra khi cuối cùng trường byte không hợp lệ được truy cập), tất cả các phương thức đều yêu cầu đầu vào 32 byte
đệm, ngay cả khi MOF nhị phân nói khác.

Bộ đệm đầu vào chứa một byte đơn để chọn tính năng phụ được truy cập và 31 byte
dữ liệu đầu vào, ý nghĩa của nó phụ thuộc vào tính năng phụ được truy cập.

Bộ đệm đầu ra chứa một byte đơn báo hiệu thành công hay thất bại (ZZ0000ZZ khi thất bại)
và 31 byte dữ liệu đầu ra, ý nghĩa nếu phụ thuộc vào tính năng phụ được truy cập.

.. note::
   The ACPI control method responsible for handling the WMI method calls is not thread-safe.
   This is a firmware bug that needs to be handled inside the driver itself.

Phương thức WMI Get_EC()
------------------------

Trả về thông tin bộ điều khiển được nhúng, tính năng phụ được chọn không thành vấn đề. Đầu ra
dữ liệu chứa một byte cờ và chuỗi phiên bản phần mềm điều khiển 28 byte.

4 bit đầu tiên của byte cờ chứa phiên bản phụ của giao diện bộ điều khiển nhúng,
với 2 bit tiếp theo chứa phiên bản chính của giao diện bộ điều khiển nhúng.

Bit thứ 7 báo hiệu nếu trang bộ điều khiển nhúng thay đổi (không rõ ý nghĩa chính xác) và
tín hiệu bit cuối cùng nếu nền tảng là nền tảng Tigerlake.

Phần mềm MSI dường như chỉ sử dụng giao diện này khi bit cuối cùng được đặt.

Phương thức WMI Get_Fan()
-------------------------

Cảm biến tốc độ quạt có thể được truy cập bằng cách chọn tính năng phụ ZZ0000ZZ. Dữ liệu đầu ra chứa
tối đa bốn số đọc tốc độ quạt 16 bit ở định dạng big-endian. Hầu hết các máy không hỗ trợ tất cả
bốn cảm biến tốc độ quạt, do đó số đọc còn lại được mã hóa cứng thành ZZ0001ZZ.

Chỉ số RPM của quạt có thể được tính theo công thức sau:

RPM = 480000 / <đọc tốc độ quạt>

Nếu số đọc tốc độ quạt bằng 0 thì quạt RPM cũng bằng 0.

Phương thức WMI Get_WMI()
-------------------------

Trả về phiên bản của giao diện ACPI WMI, tính năng phụ được chọn không thành vấn đề.
Dữ liệu đầu ra chứa hai byte, byte đầu tiên chứa phiên bản chính và byte cuối cùng
chứa bản sửa đổi nhỏ của giao diện ACPI WMI.

Phần mềm MSI dường như chỉ sử dụng giao diện này khi phiên bản chính lớn hơn hai.

Kỹ thuật đảo ngược giao diện Nền tảng MSI WMI
==================================================

.. warning:: Randomly poking the embedded controller interface can potentially cause damage
             to the machine and other unwanted side effects, please be careful.

Giao diện bộ điều khiển nhúng cơ bản được trình điều khiển ZZ0000ZZ sử dụng và có vẻ như
nhiều phương pháp chỉ sao chép một phần bộ nhớ của bộ điều khiển nhúng vào bộ đệm đầu ra.

Điều này có nghĩa là các phương pháp WMI còn lại có thể được thiết kế ngược bằng cách xem phần nào của
bộ nhớ bộ điều khiển nhúng được truy cập bằng mã ACPI AML. Trình điều khiển cũng hỗ trợ một
Giao diện debugfs để thực hiện trực tiếp các phương thức WMI. Ngoài ra, mọi kiểm tra an toàn liên quan đến
phần cứng không được hỗ trợ có thể bị vô hiệu hóa bằng cách tải mô-đun bằng ZZ0000ZZ.

Bạn có thể tìm thêm thông tin về giao diện bộ điều khiển nhúng MSI tại
ZZ0000ZZ.

Cảm ơn đặc biệt đến người dùng github ZZ0000ZZ vì đã chỉ ra cách giải mã số đọc tốc độ quạt.