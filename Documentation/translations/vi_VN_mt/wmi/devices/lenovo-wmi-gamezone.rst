.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/wmi/devices/lenovo-wmi-gamezone.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================================
Trình điều khiển Gamezone giao diện Lenovo WMI (lenovo-wmi-gamezone)
====================================================================

Giới thiệu
============
Giao diện gamezone của Lenovo WMI được chia thành nhiều GUID,
"Gamezone" GUID chính cung cấp các tính năng nâng cao như quạt
hồ sơ và ép xung. Nó được ghép nối với nhiều GUID sự kiện
và GUID khối dữ liệu cung cấp ngữ cảnh cho các phương pháp khác nhau.

Dữ liệu gamezone
----------------

WMI GUID ZZ0000ZZ

Giao diện Gamezone Data WMI cung cấp cấu hình nền tảng và đường cong quạt
cài đặt cho các thiết bị thuộc "Dòng trò chơi" của thiết bị Lenovo.
Nó sử dụng chuỗi thông báo để thông báo cho các trình điều khiển giao diện Lenovo WMI khác về
cấu hình nền tảng hiện tại khi nó thay đổi. Cấu hình hiện được thiết lập có thể
do người dùng xác định trên phần cứng bằng cách nhìn vào màu sắc của nguồn điện
hoặc hồ sơ LED, tùy thuộc vào kiểu máy.

Các cấu hình nền tảng sau được hỗ trợ:
 - LED màu xanh, năng lượng thấp
 - LED cân bằng, màu trắng
 - hiệu suất, LED màu đỏ
 - công suất tối đa, màu tím LED
 - tùy chỉnh, màu tím LED

Chế độ cực đoan
~~~~~~~~~~~~~~~~~~~~
Một số máy tính xách tay "Gaming Series" mới hơn của Lenovo có cấu hình "Extreme Mode"
được kích hoạt trong BIOS của họ. Khi có sẵn, chế độ này sẽ được biểu thị bằng
hồ sơ nền tảng công suất tối đa.

Đối với một tập hợp con của các thiết bị này, cấu hình "Chế độ cực đoan" chưa hoàn chỉnh trong
BIOS và cài đặt nó sẽ gây ra hành vi không xác định. Bảng giải quyết lỗi BIOS
được cung cấp để đảm bảo các thiết bị này không thể đặt "Chế độ cực đoan" từ trình điều khiển.

Hồ sơ tùy chỉnh
~~~~~~~~~~~~~~~
Cấu hình tùy chỉnh thể hiện chế độ phần cứng trên các thiết bị Lenovo cho phép
sửa đổi của người dùng đối với Theo dõi công suất gói (PPT) và cài đặt đường cong quạt.
Khi một thuộc tính được hiển thị bởi giao diện WMI ở Chế độ khác được sửa đổi,
trình điều khiển Gamezone trước tiên phải được chuyển sang cấu hình "tùy chỉnh" theo cách thủ công,
hoặc cài đặt sẽ không có hiệu lực. Nếu một cấu hình khác được đặt từ danh sách
trong số các cấu hình được hỗ trợ, BIOS sẽ ghi đè mọi cài đặt PPT của người dùng khi
chuyển sang hồ sơ đó.

Sự kiện chế độ nhiệt Gamezone
-----------------------------

WMI GUID ZZ0000ZZ

Giao diện Sự kiện Chế độ Nhiệt của Gamezone sẽ thông báo cho hệ thống khi nền tảng
cấu hình đã thay đổi, thông qua sự kiện phần cứng (Fn+Q cho máy tính xách tay hoặc
Legion + Y cho Go Series) hoặc thông qua giao diện Gamezone WMI. Sự kiện này là
được triển khai trong trình điều khiển Sự kiện Lenovo WMI (lenovo-wmi-event).


Mô tả giao diện WMI
=========================

Mô tả giao diện WMI có thể được giải mã từ mã nhị phân MOF (bmof) được nhúng
dữ liệu bằng tiện ích ZZ0000ZZ:

::

[WMI, Động, Nhà cung cấp("WmiProv"), Locale("MS\\0x409"), Description("LENOVO_GAMEZONE_DATA class"), guid("{887B54E3-DDDC-4B2C-8B88-68A26A8835D0}")]
  lớp LENOVO_GAMEZONE_DATA {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

    [WmiMethodId(4), Implemented, Description("Is SupportGpu OverClock")] void IsSupportGpuOC([out, Description("Is SupportGpu OverClock")] uint32 Data);
    [WmiMethodId(11), Implemented, Description("Get AslCode Version")] void GetVersion ([out, Description("AslCode version")] UINT32 Data);
    [WmiMethodId(12), Implemented, Description("Fan cooling capability")] void IsSupportFanCooling([out, Description("Fan cooling capability")] UINT32 Data);
    [WmiMethodId(13), Implemented, Description("Set Fan cooling on/off")] void SetFanCooling ([in, Description("Set Fan cooling on/off")] UINT32 Data);
    [WmiMethodId(14), Implemented, Description("cpu oc capability")] void IsSupportCpuOC ([out, Description("cpu oc capability")] UINT32 Data);
    [WmiMethodId(15), Implemented, Description("bios has overclock capability")] void IsBIOSSupportOC ([out, Description("bios has overclock capability")] UINT32 Data);
    [WmiMethodId(16), Implemented, Description("enable or disable overclock in bios")] void SetBIOSOC ([in, Description("enable or disable overclock in bios")] UINT32 Data);
    [WmiMethodId(18), Implemented, Description("Get CPU temperature")] void GetCPUTemp ([out, Description("Get CPU temperature")] UINT32 Data);
    [WmiMethodId(19), Implemented, Description("Get GPU temperature")] void GetGPUTemp ([out, Description("Get GPU temperature")] UINT32 Data);
    [WmiMethodId(20), Implemented, Description("Get Fan cooling on/off status")] void GetFanCoolingStatus ([out, Description("Get Fan cooling on/off status")] UINT32 Data);
    [WmiMethodId(21), Implemented, Description("EC support disable windows key capability")] void IsSupportDisableWinKey ([out, Description("EC support disable windows key capability")] UINT32 Data);
    [WmiMethodId(22), Implemented, Description("Set windows key disable/enable")] void SetWinKeyStatus ([in, Description("Set windows key disable/enable")] UINT32 Data);
    [WmiMethodId(23), Implemented, Description("Get windows key disable/enable status")] void GetWinKeyStatus ([out, Description("Get windows key disable/enable status")] UINT32 Data);
    [WmiMethodId(24), Implemented, Description("EC support disable touchpad capability")] void IsSupportDisableTP ([out, Description("EC support disable touchpad capability")] UINT32 Data);
    [WmiMethodId(25), Implemented, Description("Set touchpad disable/enable")] void SetTPStatus ([in, Description("Set touchpad disable/enable")] UINT32 Data);
    [WmiMethodId(26), Implemented, Description("Get touchpad disable/enable status")] void GetTPStatus ([out, Description("Get touchpad disable/enable status")] UINT32 Data);
    [WmiMethodId(30), Implemented, Description("Get Keyboard feature list")] void GetKeyboardfeaturelist ([out, Description("Get Keyboard feature list")] UINT32 Data);
    [WmiMethodId(31), Implemented, Description("Get Memory OC Information")] void GetMemoryOCInfo ([out, Description("Get Memory OC Information")] UINT32 Data);
    [WmiMethodId(32), Implemented, Description("Water Cooling feature capability")] void IsSupportWaterCooling ([out, Description("Water Cooling feature capability")] UINT32 Data);
    [WmiMethodId(33), Implemented, Description("Set Water Cooling status")] void SetWaterCoolingStatus ([in, Description("Set Water Cooling status")] UINT32 Data);
    [WmiMethodId(34), Implemented, Description("Get Water Cooling status")] void GetWaterCoolingStatus ([out, Description("Get Water Cooling status")] UINT32 Data);
    [WmiMethodId(35), Implemented, Description("Lighting feature capability")] void IsSupportLightingFeature ([out, Description("Lighting feature capability")] UINT32 Data);
    [WmiMethodId(36), Implemented, Description("Set keyboard light off or on to max")] void SetKeyboardLight ([in, Description("keyboard light off or on switch")] UINT32 Data);
    [WmiMethodId(37), Implemented, Description("Get keyboard light on/off status")] void GetKeyboardLight ([out, Description("Get keyboard light on/off status")] UINT32 Data);
    [WmiMethodId(38), Implemented, Description("Get Macrokey scan code")] void GetMacrokeyScancode ([in, Description("Macrokey index")] UINT32 idx, [out, Description("Scan code")] UINT32 scancode);
    [WmiMethodId(39), Implemented, Description("Get Macrokey count")] void GetMacrokeyCount ([out, Description("Macrokey count")] UINT32 Data);
    [WmiMethodId(40), Implemented, Description("Support G-Sync feature")] void IsSupportGSync ([out, Description("Support G-Sync feature")] UINT32 Data);
    [WmiMethodId(41), Implemented, Description("Get G-Sync Status")] void GetGSyncStatus ([out, Description("Get G-Sync Status")] UINT32 Data);
    [WmiMethodId(42), Implemented, Description("Set G-Sync Status")] void SetGSyncStatus ([in, Description("Set G-Sync Status")] UINT32 Data);
    [WmiMethodId(43), Implemented, Description("Support Smart Fan feature")] void IsSupportSmartFan ([out, Description("Support Smart Fan feature")] UINT32 Data);
    [WmiMethodId(44), Implemented, Description("Set Smart Fan Mode")] void SetSmartFanMode ([in, Description("Set Smart Fan Mode")] UINT32 Data);
    [WmiMethodId(45), Implemented, Description("Get Smart Fan Mode")] void GetSmartFanMode ([out, Description("Get Smart Fan Mode")] UINT32 Data);
    [WmiMethodId(46), Implemented, Description("Get Smart Fan Setting Mode")] void GetSmartFanSetting ([out, Description("Get Smart Setting Mode")] UINT32 Data);
    [WmiMethodId(47), Implemented, Description("Get Power Charge Mode")] void GetPowerChargeMode ([out, Description("Get Power Charge Mode")] UINT32 Data);
    [WmiMethodId(48), Implemented, Description("Get Gaming Product Info")] void GetProductInfo ([out, Description("Get Gaming Product Info")] UINT32 Data);
    [WmiMethodId(49), Implemented, Description("Over Drive feature capability")] void IsSupportOD ([out, Description("Over Drive feature capability")] UINT32 Data);
    [WmiMethodId(50), Implemented, Description("Get Over Drive status")] void GetODStatus ([out, Description("Get Over Drive status")] UINT32 Data);
    [WmiMethodId(51), Implemented, Description("Set Over Drive status")] void SetODStatus ([in, Description("Set Over Drive status")] UINT32 Data);
    [WmiMethodId(52), Implemented, Description("Set Light Control Owner")] void SetLightControlOwner ([in, Description("Set Light Control Owner")] UINT32 Data);
    [WmiMethodId(53), Implemented, Description("Set DDS Control Owner")] void SetDDSControlOwner ([in, Description("Set DDS Control Owner")] UINT32 Data);
    [WmiMethodId(54), Implemented, Description("Get the flag of restore OC value")] void IsRestoreOCValue ([in, Description("Clean this flag")] UINT32 idx, [out, Description("Restore oc value flag")] UINT32 Data);
    [WmiMethodId(55), Implemented, Description("Get Real Thremal Mode")] void GetThermalMode ([out, Description("Real Thremal Mode")] UINT32 Data);
    [WmiMethodId(56), Implemented, Description("Get the OC switch status in BIOS")] void GetBIOSOCMode ([out, Description("OC Mode")] UINT32 Data);
    [WmiMethodId(59), Implemented, Description("Get hardware info support version")] void GetHardwareInfoSupportVersion ([out, Description("version")] UINT32 Data);
    [WmiMethodId(60), Implemented, Description("Get Cpu core 0 max frequency")] void GetCpuFrequency ([out, Description("frequency")] UINT32 Data);
    [WmiMethodId(62), Implemented, Description("Check the Adapter type fit for OC")] void IsACFitForOC ([out, Description("AC check result")] UINT32 Data);
    [WmiMethodId(63), Implemented, Description("Is support IGPU mode")] void IsSupportIGPUMode ([out, Description("IGPU modes")] UINT32 Data);
    [WmiMethodId(64), Implemented, Description("Get IGPU Mode Status")] void GetIGPUModeStatus([out, Description("IGPU Mode Status")] UINT32 Data);
    [WmiMethodId(65), Implemented, Description("Set IGPU Mode")] void SetIGPUModeStatus([in, Description("IGPU Mode")] UINT32 mode, [out, Description("return code")] UINT32 Data);
    [WmiMethodId(66), Implemented, Description("Notify DGPU Status")] void NotifyDGPUStatus([in, Description("DGPU status")] UINT32 status, [out, Description("return code")] UINT32 Data);
    [WmiMethodId(67), Implemented, Description("Is changed Y log")] void IsChangedYLog([out, Description("Is changed Y Log")] UINT32 Data);
    [WmiMethodId(68), Implemented, Description("Get DGPU Hardwawre ID")] void GetDGPUHWId([out, Description("Get DGPU Hardware ID")] string Data);
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("Định nghĩa danh sách tham số CPU OC"), guid("{B7F3CA0A-ACDC-42D2-9217-77C6C628FBD2}")]
  lớp LENOVO_GAMEZONE_CPU_OC_DATA {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, Mô tả("OC tune id.")] uint32 Tuneid;
    [WmiDataId(2), đọc, Mô tả("Giá trị mặc định.")] uint32 DefaultValue;
    [WmiDataId(3), đọc, Mô tả("Giá trị OC.")] uint32 OCValue;
    [WmiDataId(4), đọc, Mô tả("Giá trị Tối thiểu.")] uint32 MinValue;
    [WmiDataId(5), đọc, Mô tả("Giá trị Tối đa.")] uint32 MaxValue;
    [WmiDataId(6), đọc, Mô tả("Giá trị tỷ lệ.")] uint32 ScalValue;
    [WmiDataId(7), đọc, Mô tả("Id đơn hàng OC.")] uint32 OCOrderid;
    [WmiDataId(8), đọc, Mô tả("NON-OC Id đơn hàng.")] uint32 NOCOrderid;
    [WmiDataId(9), đọc, Mô tả("Thời gian trễ tính bằng ms.")] uint32 Khoảng thời gian;
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("Định nghĩa danh sách tham số GPU OC"), guid("{887B54E2-DDDC-4B2C-8B88-68A26A8835D0}")]
  lớp LENOVO_GAMEZONE_GPU_OC_DATA {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, Mô tả("ID trạng thái P.")] uint32 PStateID;
    [WmiDataId(2), đọc, Mô tả("CLOCK ID.")] uint32 ClockID;
    [WmiDataId(3), đọc, Mô tả("Giá trị mặc định.")] uint32 giá trị mặc định;
    [WmiDataId(4), đọc, Mô tả("Tần số bù OC.")] uint32 OCOffsetFreq;
    [WmiDataId(5), read, Description("OC Min offset value.")] uint32 OCMinOffset;
    [WmiDataId(6), read, Description("OC Max offset value.")] uint32 OCMaxOffset;
    [WmiDataId(7), đọc, Mô tả("Tỷ lệ bù OC.")] uint32 OCOffsetScale;
    [WmiDataId(8), đọc, Mô tả("Id đơn hàng OC.")] uint32 OCOrderid;
    [WmiDataId(9), đọc, Mô tả("NON-OC Id đơn hàng.")] uint32 NOCOrderid;
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("Sự kiện kết thúc làm mát quạt"), guid("{BC72A435-E8C1-4275-B3E2-D8B8074ABA59}")]
  lớp LENOVO_GAMEZONE_FAN_COOLING_EVENT: WMIEvent {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, Mô tả("Sự kiện hoàn thiện làm sạch quạt")] uint32 EventId;
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("Sự kiện thay đổi chế độ Quạt thông minh"), guid("{D320289E-8FEA-41E0-86F9-611D83151B5F}")]
  lớp LENOVO_GAMEZONE_SMART_FAN_MODE_EVENT: WMIEvent {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, Mô tả("Sự kiện thay đổi Chế độ Quạt Thông minh")] chế độ uint32;
    [WmiDataId(2), đọc, Mô tả("phiên bản của FN+Q")] phiên bản uint32;
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("Sự kiện thay đổi chế độ cài đặt Quạt thông minh"), guid("{D320289E-8FEA-41E1-86F9-611D83151B5F}")]
  lớp LENOVO_GAMEZONE_SMART_FAN_SETTING_EVENT: WMIEvent {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), read, Description("Sự kiện thay đổi chế độ cài đặt quạt thông minh")] chế độ uint32;
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("POWER CHARGE MODE Thay đổi EVENT"), guid("{D320289E-8FEA-41E0-86F9-711D83151B5F}")]
  lớp LENOVO_GAMEZONE_POWER_CHARGE_MODE_EVENT: WMIEvent {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, Mô tả("POWER CHARGE MODE Thay đổi EVENT")] chế độ uint32;
  };

[WMI, Dynamic, Provider("WmiProv"), Locale("MS\\0x409"), Description("Sự kiện thay đổi chế độ thực ở chế độ nhiệt"), guid("{D320289E-8FEA-41E0-86F9-911D83151B5F}")]
  lớp LENOVO_GAMEZONE_THERMAL_MODE_EVENT: WMIEvent {
    [phím, đọc] chuỗi Tên phiên bản;
    [đọc] boolean Hoạt động;

[WmiDataId(1), đọc, Mô tả("Chế độ nhiệt Chế độ thực")] chế độ uint32;
  };