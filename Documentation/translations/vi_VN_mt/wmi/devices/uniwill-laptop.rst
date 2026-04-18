.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/wmi/devices/uniwill-laptop.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Trình điều khiển Uniwill Notebook (uniwill-laptop)
==================================================

Giới thiệu
============

Nhiều máy tính xách tay do Uniwill sản xuất (trực tiếp hoặc dưới dạng ODM) cung cấp giao diện EC
để kiểm soát các cài đặt nền tảng khác nhau như cảm biến và điều khiển quạt. Giao diện này là
được trình điều khiển ZZ0000ZZ sử dụng để ánh xạ các tính năng đó lên giao diện hạt nhân tiêu chuẩn.

Mô tả giao diện EC WMI
============================

Mô tả giao diện EC WMI có thể được giải mã từ mã nhị phân MOF (bmof) được nhúng
dữ liệu bằng tiện ích ZZ0000ZZ:

::

[WMI, Động, Nhà cung cấp("WmiProv"), Ngôn ngữ("MS\\0x409"),
   Description("Lớp được sử dụng để vận hành các phương thức trên ULong"),
   hướng dẫn ("{ABBC0F6F-8EA1-11d1-00A0-C90629100000}")]
  lớp AcpiTest_MULong {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiMethodId(1), Đã triển khai, đọc, viết, Mô tả("Trả về nội dung của ULong")]
    void GetULong([out, Description("Ulong Data")] uint32 Data);

[WmiMethodId(2), Đã triển khai, đọc, viết, Mô tả("Đặt nội dung của ULong")]
    void SetULong([in, Description("Ulong Data")] uint32 Data);

[WmiMethodId(3), Đã triển khai, đọc, viết,
     Description("Tạo sự kiện chứa dữ liệu ULong")]
    void FireULong([in, Description("WMI yêu cầu tham số")] uint32 Hack);

[WmiMethodId(4), Đã triển khai, đọc, viết, Mô tả("Lấy và Đặt nội dung của ULong")]
    void GetSetULong([in, Description("Ulong Data")] uint64 Data,
                     [out, Description("Ulong Data")] uint32 Return);

[WmiMethodId(5), Đã triển khai, đọc, viết,
     Description("Nhận và đặt nội dung của nút ULong cho Dollby")]
    void GetButton([in, Description("Ulong Data")] uint64 Data,
                   [out, Description("Ulong Data")] uint32 Return);
  };

Hầu hết mã liên quan đến WMI đã được sao chép từ các mẫu trình điều khiển Windows, điều này rất tiếc có nghĩa là
rằng WMI-GUID không phải là duy nhất. Điều này làm cho WMI-GUID không thể sử dụng được để tự động tải.

Phương thức WMI GetULong()
--------------------------

Phương pháp WMI này được sao chép từ các mẫu trình điều khiển Windows và không có chức năng.

Phương thức WMI SetULong()
--------------------------

Phương pháp WMI này được sao chép từ các mẫu trình điều khiển Windows và không có chức năng.

Phương thức WMI FireULong()
---------------------------

Phương thức WMI này cho phép chèn sự kiện WMI với tải trọng 32 bit. Mục đích chính của nó có vẻ
đang được gỡ lỗi.

Phương thức WMI GetSetULong()
-----------------------------

Phương thức WMI này được sử dụng để liên lạc với EC. Đối số ZZ0000ZZ có nội dung sau
thông tin (bắt đầu bằng byte có ý nghĩa nhỏ nhất):

1. Địa chỉ 16 bit
2. Dữ liệu 16 bit (đặt thành ZZ0000ZZ khi đọc)
3. Hoạt động 16 bit (ZZ0001ZZ để đọc và ZZ0002ZZ để ghi)
4. Dự trữ 16 bit (đặt thành ZZ0003ZZ)

8 bit đầu tiên của giá trị ZZ0000ZZ chứa dữ liệu được EC trả về khi đọc.
Giá trị đặc biệt ZZ0001ZZ được sử dụng để biểu thị lỗi giao tiếp với EC.

Phương thức WMI GetButton()
---------------------------

Phương pháp WMI này không được triển khai trên tất cả các máy và không rõ mục đích.

Kỹ thuật đảo ngược giao diện EC WMI
========================================

.. warning:: Randomly poking the EC can potentially cause damage to the machine and other unwanted
             side effects, please be careful.

EC đằng sau phương pháp ZZ0000ZZ được sử dụng bởi phần mềm OEM do nhà sản xuất cung cấp.
Kỹ thuật đảo ngược phần mềm này rất khó vì nó sử dụng bộ làm xáo trộn, tuy nhiên một số phần
không bị xáo trộn. Trong trường hợp này ZZ0001ZZ cũng có thể hữu ích.

EC có thể được truy cập trong Windows bằng powershell (yêu cầu quyền quản trị viên):

::

> $obj = Get-CimInstance -Không gian tên root/wmi -ClassName AcpiTest_MULong | Chọn-Đối tượng -Đầu tiên 1
  > Gọi-CimMethod -InputObject $obj -MethodName GetSetULong -Arguments @{Data = <input>}

Mô tả giao diện sự kiện WMI
===============================

Mô tả giao diện WMI cũng có thể được giải mã từ mã nhị phân MOF (bmof) được nhúng
dữ liệu:

::

[WMI, Động, Nhà cung cấp("WmiProv"), Ngôn ngữ("MS\\0x409"),
   Description("Lớp chứa dữ liệu ULong được tạo bởi sự kiện"),
   hướng dẫn ("{ABBC0F72-8EA1-11d1-00A0-C90629100000}")]
  lớp AcpiTest_EventULong : WmiEvent {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, ghi, Mô tả("ULong Data")] uint32 ULong;
  };

Hầu hết các mã liên quan đến WMI một lần nữa được sao chép từ các mẫu trình điều khiển Windows, gây ra lỗi WMI này
phải chịu những hạn chế tương tự như giao diện EC WMI được mô tả ở trên.

Dữ liệu sự kiện WMI
-------------------

Dữ liệu sự kiện WMI chứa một giá trị 32 bit duy nhất được sử dụng để biểu thị các sự kiện nền tảng khác nhau.

Kỹ thuật đảo ngược giao diện sự kiện Uniwill WMI
===================================================

Trình điều khiển ghi lại thông báo gỡ lỗi khi nhận được sự kiện WMI. Do đó việc kích hoạt các thông báo gỡ lỗi sẽ
hữu ích cho việc tìm kiếm mã sự kiện không xác định.

Mô tả giao diện EC ACPI
=============================

Thiết bị ZZ0000ZZ ACPI là một thiết bị ảo được sử dụng để truy cập vào các thanh ghi phần cứng khác nhau
có sẵn trên máy tính xách tay do Uniwill sản xuất. Việc đọc và ghi những thanh ghi đó xảy ra
bằng cách gọi các phương thức điều khiển ACPI. Trình điều khiển ZZ0001ZZ sử dụng thiết bị này để liên lạc
với EC vì các phương pháp điều khiển ACPI nhanh hơn các phương pháp WMI được mô tả ở trên.

Các phương thức điều khiển ACPI được sử dụng để đọc các thanh ghi lấy một số nguyên ACPI duy nhất chứa địa chỉ
của thanh ghi để đọc và trả về số nguyên ACPI chứa dữ liệu bên trong thanh ghi nói trên. ACPI
Tuy nhiên, các phương thức điều khiển được sử dụng để ghi các thanh ghi lấy hai số nguyên ACPI, cộng thêm
Số nguyên ACPI chứa dữ liệu được ghi vào thanh ghi. Các phương thức điều khiển ACPI như vậy trả về
không có gì.

Bộ nhớ hệ thống
---------------

Bộ nhớ hệ thống có thể được truy cập với mức độ chi tiết của một byte đơn (ZZ0000ZZ để đọc và
ZZ0001ZZ để ghi) hoặc bốn byte (ZZ0002ZZ để đọc và ZZ0003ZZ để ghi). Những chiếc ACPI đó
các phương pháp điều khiển không được sử dụng vì chúng không mang lại lợi ích gì khi so sánh với bộ nhớ riêng
truy cập các chức năng được cung cấp bởi kernel.

EC RAM
------

RAM nội bộ của EC có thể được truy cập với mức độ chi tiết của một byte đơn bằng cách sử dụng ZZ0000ZZ
(đọc) và ZZ0001ZZ (ghi) phương thức điều khiển ACPI, với địa chỉ thanh ghi tối đa là ZZ0002ZZ.
Phần mềm OEM đợi 6 ms sau khi gọi một trong các phương thức điều khiển ACPI đó, có thể tránh được
áp đảo EC khi được kết nối qua LPC.

Không gian cấu hình PCI
-----------------------

Không gian cấu hình PCI có thể được truy cập với độ chi tiết bốn byte bằng cách sử dụng ZZ0000ZZ (đọc) và
ZZ0001ZZ (ghi) Phương pháp điều khiển ACPI. Định dạng địa chỉ chính xác không xác định và chọc ngẫu nhiên PCI
các thiết bị có thể gây nhầm lẫn cho hệ thống con PCI. Do đó, các phương pháp điều khiển ACPI đó không được sử dụng.

cổng IO
--------

Các cổng IO có thể được truy cập với độ chi tiết bốn byte bằng cách sử dụng ZZ0000ZZ (đọc) và ZZ0001ZZ
(viết) Phương pháp điều khiển ACPI. Các phương pháp kiểm soát ACPI đó không được sử dụng vì chúng không mang lại lợi ích gì
khi so sánh với các chức năng truy cập cổng IO gốc do kernel cung cấp.

CMOS RAM
--------

CMOS RAM có thể được truy cập với mức độ chi tiết của một byte đơn bằng cách sử dụng ZZ0000ZZ (đọc) và
Phương pháp điều khiển ZZ0001ZZ ACPI. Việc sử dụng các phương pháp ACPI đó có thể ảnh hưởng đến CMOS RAM gốc
truy cập các chức năng do kernel cung cấp do sử dụng IO được lập chỉ mục nên không được sử dụng.

IO được lập chỉ mục
-------------------

IO được lập chỉ mục với các cổng IO với độ chi tiết của một byte đơn có thể được thực hiện bằng ZZ0000ZZ
(đọc) và ZZ0001ZZ (ghi) phương pháp điều khiển ACPI. Các phương thức ACPI đó không được sử dụng vì chúng
không mang lại lợi ích gì khi so sánh với các chức năng truy cập cổng IO gốc do kernel cung cấp.

Cảm ơn đặc biệt tới người dùng github ZZ0002ZZ đã phát triển
Trình điều khiển ZZ0000ZZ mà trình điều khiển này dựa trên một phần.
Điều tương tự cũng đúng với Tuxedo Computers, hãng đã phát triển
Gói ZZ0001ZZ
cũng đóng vai trò là nền tảng cho trình điều khiển này.