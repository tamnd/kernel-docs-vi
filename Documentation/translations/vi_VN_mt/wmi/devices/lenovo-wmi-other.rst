.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/wmi/devices/lenovo-wmi-other.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================================================
Trình điều khiển Chế độ Khác Giao diện Lenovo WMI (lenovo-wmi-other)
===========================================================

Giới thiệu
============
Giao diện Other Mode của Lenovo WMI được chia thành nhiều GUID,
Giao diện Chế độ khác chính cung cấp các tính năng điều chỉnh nguồn nâng cao
chẳng hạn như Theo dõi năng lượng gói (PPT). Nó được ghép nối với nhiều khối dữ liệu
GUID cung cấp ngữ cảnh cho các phương pháp khác nhau.


Chế độ khác
----------

WMI GUID ZZ0000ZZ

Giao diện WMI ở Chế độ khác sử dụng lớp firmware_attributes để hiển thị
các thuộc tính WMI khác nhau được cung cấp bởi giao diện trong sysfs. Điều này cho phép
Điều chỉnh giới hạn công suất CPU và GPU cũng như nhiều thuộc tính khác cho
các thiết bị thuộc "Dòng trò chơi" của thiết bị Lenovo. Mỗi
thuộc tính được hiển thị bởi giao diện Chế độ khác có tương ứng
khối dữ liệu khả năng cho phép người lái thăm dò chi tiết về
thuộc tính. Mỗi thuộc tính có nhiều trang, một trang cho mỗi nền tảng
hồ sơ được quản lý bởi giao diện Gamezone. Các thuộc tính được hiển thị trong sysfs
theo đường dẫn sau:

::

/sys/class/firmware-attributes/lenovo-wmi-other/attributes/<attribute>/

Ngoài ra, trình điều khiển này cũng xuất các thuộc tính sang HWMON.

LENOVO_CAPABILITY_DATA_00
-------------------------

WMI GUID ZZ0000ZZ

Giao diện LENOVO_CAPABILITY_DATA_00 cung cấp nhiều thông tin khác nhau
không dựa vào chế độ nhiệt của gamezone.

Các thuộc tính HWMON sau đây được triển khai:
 - fanX_div: ước số RPM nội bộ
 - fanX_input: RPM hiện tại
 - fanX_target: mục tiêu RPM (có thể điều chỉnh, 0=auto)

Do có bộ chia RPM bên trong, RPM hiện tại/mục tiêu được làm tròn xuống thành
bội số gần nhất của nó. Bản thân số chia không nhất thiết phải là lũy thừa của hai.

LENOVO_CAPABILITY_DATA_01
-------------------------

WMI GUID ZZ0000ZZ

Giao diện LENOVO_CAPABILITY_DATA_01 cung cấp nhiều thông tin khác nhau
dựa vào chế độ nhiệt của gamezone, bao gồm giới hạn năng lượng của thiết bị tích hợp
Các thành phần CPU và GPU.

Mỗi thuộc tính có các thuộc tính sau:
 - giá trị hiện tại
 - giá trị mặc định
 - tên_hiển thị
 - giá trị tối đa
 - giá trị tối thiểu
 - vô hướng_increment
 - gõ

Các thuộc tính phần sụn sau đây được triển khai:
 - ppt_pl1_spl: Giới hạn năng lượng duy trì theo dõi hồ sơ nền tảng
 - ppt_pl2_sppt: Theo dõi hồ sơ nền tảng Theo dõi sức mạnh gói chậm
 - ppt_pl3_fppt: Theo dõi hồ sơ nền tảng Theo dõi sức mạnh gói nhanh

LENOVO_FAN_TEST_DATA
-------------------------

WMI GUID ZZ0000ZZ

Giao diện LENOVO_FAN_TEST_DATA cung cấp dữ liệu tham khảo để tự kiểm tra
quạt làm mát.

Các thuộc tính HWMON sau đây được triển khai:
 - fanX_max: RPM tối đa
 - fanX_min: RPM tối thiểu

Mô tả giao diện WMI
=========================

Mô tả giao diện WMI có thể được giải mã từ mã nhị phân MOF (bmof) được nhúng
dữ liệu bằng tiện ích ZZ0000ZZ:

::

[WMI, Động, Nhà cung cấp("WmiProv"), Locale("MS\\0x409"), Description("LENOVO_OTHER_METHOD class"), guid("{dc2a8805-3a8c-41ba-a6f7-092e0089cd3b}")]
  lớp LENOVO_OTHER_METHOD {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiMethodId(17), Đã triển khai, Mô tả("Nhận giá trị tính năng ")] void GetFeatureValue([in] ID uint32, [out] giá trị uint32);
    [WmiMethodId(18), Đã triển khai, Mô tả("Đặt giá trị tính năng ")] void SetFeatureValue([in] ID uint32, [in] giá trị uint32);
    [WmiMethodId(19), Đã triển khai, Mô tả("Lấy dữ liệu bằng lệnh ")] void GetDataByCommand([in] uint32 IDs, [in] uint32 Command, [out] uint32 DataSize, [out, WmiSizeIs("DataSize")] uint32 Data[]);
    [WmiMethodId(99), Đã triển khai, Mô tả("Lấy dữ liệu theo gói cho TAC")] void GetDataByPackage([in, Max(40)] uint8 input[], [out] uint32 DataSize, [out, WmiSizeIs("DataSize")] uint8 Data[]);
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("LENOVO CAPABILITY DATA 00"), guid("{362a3afe-3d96-4665-8530-96dad5bb300e}")]
  lớp LENOVO_CAPABILITY_DATA_00 {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, Mô tả(" ID.")] uint32 ID;
    [WmiDataId(2), đọc, Mô tả("Khả năng.")] Khả năng uint32;
    [WmiDataId(3), đọc, Mô tả("Giá trị mặc định khả năng.")] uint32 DefaultValue;
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("LENOVO CAPABILITY DATA 01"), guid("{7a8f5407-cb67-4d6e-b547-39b3be018154}")]
  lớp LENOVO_CAPABILITY_DATA_01 {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, Mô tả(" ID.")] uint32 ID;
    [WmiDataId(2), đọc, Mô tả("Khả năng.")] Khả năng uint32;
    [WmiDataId(3), đọc, Mô tả("Giá trị mặc định.")] uint32 DefaultValue;
    [WmiDataId(4), đọc, Mô tả("Bước.")] uint32 Bước;
    [WmiDataId(5), đọc, Mô tả("Giá trị Tối thiểu.")] uint32 MinValue;
    [WmiDataId(6), đọc, Mô tả("Giá trị Tối đa.")] uint32 MaxValue;
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("LENOVO CAPABILITY DATA 02"), guid("{bbf1f790-6c2f-422b-bc8c-4e7369c7f6ab}")]
  lớp LENOVO_CAPABILITY_DATA_02 {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, Mô tả(" ID.")] uint32 ID;
    [WmiDataId(2), đọc, Mô tả("Khả năng.")] Khả năng uint32;
    [WmiDataId(3), đọc, Mô tả("Kích thước dữ liệu.")] uint32 DataSize;
    [WmiDataId(4), đọc, Mô tả("Giá trị mặc định"), WmiSizeIs("DataSize")] uint8 DefaultValue[];
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("Định nghĩa dữ liệu kiểm tra quạt"), guid("{B642801B-3D21-45DE-90AE-6E86F164FB21}")]
  lớp LENOVO_FAN_TEST_DATA {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;
    [WmiDataId(1), đọc, Mô tả("Chế độ.")] uint32 NumOfFans;
    [WmiDataId(2), đọc, Mô tả("Fan ID."), WmiSizeIs("NumOfFans")] uint32 FanId[];
    [WmiDataId(3), đọc, Mô tả("Tốc độ quạt tối đa."), WmiSizeIs("NumOfFans")] uint32 FanMaxSpeed[];
    [WmiDataId(4), read, Description("Tốc độ quạt tối thiểu."), WmiSizeIs("NumOfFans")] uint32 FanMinSpeed[];
  };