.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/wmi/devices/dell-wmi-ddv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================
Trình điều khiển giao diện Dell DDV WMI (dell-wmi-ddv)
======================================================

Giới thiệu
============

Nhiều máy tính xách tay Dell được sản xuất sau ~ năm 2020 hỗ trợ giao diện dựa trên WMI cho
truy xuất nhiều dữ liệu hệ thống khác nhau như nhiệt độ pin, ePPID, dữ liệu chẩn đoán
và dữ liệu cảm biến quạt/nhiệt.

Giao diện này có thể được sử dụng bởi phần mềm ZZ0001ZZ trên Windows,
vì vậy nó được gọi là ZZ0002ZZ. Hiện tại trình điều khiển ZZ0000ZZ hỗ trợ
phiên bản 2 và 3 của giao diện, có hỗ trợ các phiên bản giao diện mới
dễ dàng thêm vào.

.. warning:: The interface is regarded as internal by Dell, so no vendor
             documentation is available. All knowledge was thus obtained by
             trial-and-error, please keep that in mind.

Dell ePPID (Nhận dạng bộ phận điện tử)
=================================================

Dell ePPID được sử dụng để nhận dạng duy nhất các thành phần trong máy Dell,
bao gồm cả pin. Nó có hình dạng tương tự ZZ0000ZZ
và chứa các thông tin sau:

* Mã nước xuất xứ (CC).
* Mã bộ phận với ký tự đầu tiên là số điền (PPPPPP).
* Nhận dạng sản xuất (MMMMM).
* Năm/Tháng/Ngày sản xuất (YMD) trong cơ sở 36, với Y là chữ số cuối cùng
  của năm.
* Số thứ tự sản xuất (SSSS).
* Phiên bản/bản sửa đổi phần sụn tùy chọn (FFF).

Có thể sử dụng tiện ích python ZZ0000ZZ
để giải mã và hiển thị thông tin này.

Tất cả thông tin liên quan đến Dell ePPID được thu thập bằng cách sử dụng bộ phận hỗ trợ của Dell
tài liệu và ZZ0000ZZ.

Mô tả giao diện WMI
=========================

Mô tả giao diện WMI có thể được giải mã từ mã nhị phân MOF (bmof) được nhúng
dữ liệu bằng tiện ích ZZ0000ZZ:

::

[WMI, Động, Nhà cung cấp("WmiProv"), Locale("MS\\0x409"), Description("WMI Function"), guid("{8A42EA14-4F2A-FD45-6422-0087F7A7E608}")]
 lớp DDVWmiMethodFunction {
   [phím, đọc] chuỗi Tên phiên bản;
   [đọc] boolean Hoạt động;

[WmiMethodId(1), Đã triển khai, đọc, ghi, Mô tả("Trả về dung lượng thiết kế pin.")] ​​void BatteryDesignCapacity([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(2), Đã triển khai, đọc, ghi, Mô tả("Trả lại dung lượng sạc đầy pin.")] ​​void BatteryFullChargeCapacity([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(3), Đã triển khai, đọc, viết, Mô tả("Trả lại tên nhà sản xuất pin.")] ​​void Battery ManufacturingName([in] uint32 arg2, [out] string argr);
   [WmiMethodId(4), Đã triển khai, đọc, viết, Mô tả("Trả lại ngày sản xuất pin.")] ​​void Battery ManufacturingDate([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(5), Đã triển khai, đọc, ghi, Mô tả("Trả lại số sê-ri pin.")] ​​void BatterySerialNumber([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(6), Đã triển khai, đọc, ghi, Mô tả("Trả về giá trị hóa học của pin.")] ​​void BatteryChemistryValue([in] uint32 arg2, [out] string argr);
   [WmiMethodId(7), Đã triển khai, đọc, ghi, Mô tả("Trả về nhiệt độ pin.")] ​​void BatteryTemperature([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(8), Đã triển khai, đọc, ghi, Mô tả("Trả lại dòng điện của pin.")] ​​void BatteryCurrent([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(9), Đã triển khai, đọc, ghi, Mô tả("Trả về điện áp pin.")] ​​void BatteryVoltage([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(10), Đã triển khai, đọc, viết, Mô tả("Trả lại quyền truy cập sản xuất pin (mã MA).")] void Battery ManufacturingAceess([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(11), Đã triển khai, đọc, ghi, Mô tả("Trả lại trạng thái sạc tương đối của pin.")] ​​void BatteryRelativeStateOfCharge([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(12), Đã triển khai, đọc, ghi, Mô tả("Trả về số chu kỳ pin")] void BatteryCycleCount([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(13), Đã triển khai, đọc, ghi, Mô tả("Trả lại pin ePPID")] void BatteryePPID([in] uint32 arg2, [out] string argr);
   [WmiMethodId(14), Đã triển khai, đọc, ghi, Mô tả("Trả lại pin thô Bắt đầu phân tích thô")] void BatteryeRawAnalyticsStart([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(15), Đã triển khai, đọc, ghi, Mô tả("Trả lại phân tích thô về pin")] void BatteryeRawAnalytics([in] uint32 arg2, [out] uint32 RawSize, [out, WmiSizeIs("RawSize") : ToInstance] uint8 RawData[]);
   [WmiMethodId(16), Đã triển khai, đọc, ghi, Mô tả("Trả về điện áp thiết kế pin.")] ​​void BatteryDesignVoltage([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(17), Đã triển khai, đọc, ghi, Mô tả("Trả lại khối pin thô phân tích thô")] void BatteryeRawAnalyticsABlock([in] uint32 arg2, [out] uint32 RawSize, [out, WmiSizeIs("RawSize") : ToInstance] uint8 RawData[]);
   [WmiMethodId(18), Đã triển khai, đọc, viết, Mô tả("Phiên bản trả về.")] void ReturnVersion([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(32), Đã triển khai, đọc, ghi, Mô tả("Trả về thông tin cảm biến quạt")] void FanSensorInformation([in] uint32 arg2, [out] uint32 RawSize, [out, WmiSizeIs("RawSize") : ToInstance] uint8 RawData[]);
   [WmiMethodId(34), Đã triển khai, đọc, ghi, Mô tả("Trả về thông tin cảm biến nhiệt")] void ThermalSensorInformation([in] uint32 arg2, [out] uint32 RawSize, [out, WmiSizeIs("RawSize") : ToInstance] uint8 RawData[]);
 };

Mỗi phương thức WMI lấy bộ đệm ACPI chứa chỉ mục 32 bit làm đối số đầu vào,
với 8 bit đầu tiên được sử dụng để chỉ định pin khi sử dụng liên quan đến pin
Phương pháp WMI. Các phương thức WMI khác có thể bỏ qua đối số này hoặc giải thích nó
khác nhau. Định dạng đầu ra của phương thức WMI khác nhau:

* nếu hàm chỉ có một đầu ra duy nhất thì đối tượng ACPI
  thuộc loại tương ứng được trả về
* nếu chức năng có nhiều đầu ra, khi gói ACPI
  chứa các đầu ra theo cùng thứ tự được trả về

Định dạng của đầu ra cần được kiểm tra kỹ lưỡng vì nhiều phương pháp có thể
trả về dữ liệu không đúng định dạng trong trường hợp có lỗi.

Định dạng dữ liệu của nhiều phương pháp liên quan đến pin dường như dựa trên
ZZ0000ZZ, vì vậy các phương pháp liên quan đến pin chưa được xác định là
có khả năng tuân theo tiêu chuẩn này theo một cách nào đó.

Phương thức WMI GetBatteryDesignCapacity()
------------------------------------------

Trả về dung lượng thiết kế của pin tính bằng mAh dưới dạng u16.

Phương thức WMI PinFullCharge()
-------------------------------

Trả về dung lượng sạc đầy của pin tính bằng mAh dưới dạng u16.

Phương thức WMI PinSản xuấtName()
-----------------------------------

Trả về tên nhà sản xuất của pin dưới dạng chuỗi ASCII.

Phương thức WMI BatterySản xuấtDate()
-------------------------------------

Trả về ngày sản xuất của pin là u16.
Ngày được mã hóa theo cách sau:

- Các bit từ 0 đến 4 chứa ngày sản xuất.
- bit 5 đến 8 chứa tháng sản xuất.
- bit 9 đến 15 chứa năm sản xuất bị sai lệch bởi năm 1980.

Phương thức WMI BatterySerialNumber()
-------------------------------------

Trả về số sê-ri của pin là u16.

Phương thức WMI BatteryChemistryValue()
---------------------------------------

Trả về thành phần hóa học của pin dưới dạng chuỗi ASCII.
Các giá trị được biết là:

- "Li-I" cho Li-Ion

Phương thức WMI BatteryTemperature()
------------------------------------

Trả về nhiệt độ của pin theo độ 10 kelvin dưới dạng u16.

Phương thức WMI Battery Current()
---------------------------------

Trả về dòng điện hiện tại của pin tính bằng mA dưới dạng s16.
Giá trị âm cho biết đang xả.

Phương thức WMI PinĐiện áp()
----------------------------

Trả về dòng điện áp của pin tính bằng mV dưới dạng u16.

Phương pháp WMI BatterySản xuấtAccess()
---------------------------------------

Trả về trạng thái sức khỏe của pin là u16.
Tình trạng sức khỏe được mã hóa theo cách sau:

- nibble thứ ba chứa chế độ lỗi chung
 - nibble thứ tư chứa mã lỗi cụ thể

Các chế độ lỗi hợp lệ là:

- hỏng vĩnh viễn (ZZ0000ZZ)
 - lỗi quá nhiệt (ZZ0001ZZ)
 - Lỗi quá dòng (ZZ0002ZZ)

Tất cả các dạng hư hỏng khác được coi là bình thường.

Các mã lỗi sau đây hợp lệ cho lỗi vĩnh viễn:

- cầu chì bị đứt (ZZ0000ZZ)
 - mất cân bằng tế bào (ZZ0001ZZ)
 - quá điện áp (ZZ0002ZZ)
 - suy thai (ZZ0003ZZ)

Hai bit cuối cùng của mã lỗi sẽ bị bỏ qua khi pin
báo hiệu một sự thất bại vĩnh viễn.

Các mã lỗi sau đây hợp lệ cho lỗi quá nhiệt:

- quá nóng khi bắt đầu sạc (ZZ0000ZZ)
 - quá nóng trong khi sạc (ZZ0001ZZ)
 - quá nóng trong quá trình xả (ZZ0002ZZ)

Các mã lỗi sau đây hợp lệ cho lỗi quá dòng:

- quá dòng trong khi sạc (ZZ0000ZZ)
 - quá dòng trong quá trình xả (ZZ0001ZZ)

Phương thức WMI BatteryRelativeStateOfCharge()
----------------------------------------------

Trả về dung lượng của pin theo phần trăm dưới dạng u16.

Phương thức WMI BatteryCycleCount()
-----------------------------------

Trả về số chu kỳ của pin là u16.

Phương thức WMI PinePPID()
--------------------------

Trả về ePPID của pin dưới dạng chuỗi ASCII.

Phương pháp WMI BatteryeRawAnalyticsStart()
-------------------------------------------

Thực hiện phân tích pin và trả về mã trạng thái:

- ZZ0000ZZ: Thành công
- ZZ0001ZZ: Giao diện không được hỗ trợ
- ZZ0002ZZ: Lỗi/Hết thời gian

.. note::
   The meaning of this method is still largely unknown.

Phương pháp WMI BatteryeRawAnalytics()
--------------------------------------

Trả về bộ đệm thường chứa 12 khối dữ liệu phân tích.
Các khối đó chứa:

- số khối bắt đầu bằng 0 (u8)
- 31 byte dữ liệu không xác định

.. note::
   The meaning of this method is still largely unknown.

Phương thức WMI BatteryDesignVoltage()
--------------------------------------

Trả về điện áp thiết kế của pin tính bằng mV dưới dạng u16.

Phương pháp WMI BatteryeRawAnalyticsABlock()
--------------------------------------------

Trả về một khối dữ liệu phân tích, với byte thứ hai
của chỉ mục đang được sử dụng để chọn số khối.

ZZ0000ZZ

.. note::
   The meaning of this method is still largely unknown.

Phương thức WMI ReturnVersion()
-------------------------------

Trả về phiên bản giao diện WMI dưới dạng u32.

Phương thức WMI FanSensorInformation()
--------------------------------------

Trả về bộ đệm chứa các mục cảm biến quạt, đã kết thúc
với một chiếc ZZ0000ZZ duy nhất.
Những mục đó có chứa:

- loại quạt (u8)
- tốc độ quạt trong RPM (endian nhỏ u16)

Phương thức WMI ThermalSensorInformation()
------------------------------------------

Trả về bộ đệm chứa các mục cảm biến nhiệt, đã kết thúc
với một chiếc ZZ0000ZZ duy nhất.
Những mục đó có chứa:

- loại nhiệt (u8)
- nhiệt độ hiện tại (s8)
- phút. nhiệt độ (s8)
- tối đa. nhiệt độ (s8)
- trường không xác định (u8)

.. note::
   TODO: Find out what the meaning of the last byte is.

Thuật toán khớp pin ACPI
===============================

Thuật toán được sử dụng để khớp pin ACPI với các chỉ số dựa trên thông tin
được tìm thấy bên trong thông báo ghi nhật ký của phần mềm OEM.

Về cơ bản đối với mỗi pin ACPI mới, số sê-ri của pin phía sau
chỉ số 1 đến 3 được so sánh với số sê-ri của pin ACPI.
Vì số sê-ri của pin ACPI có thể được mã hóa như bình thường
số nguyên hoặc dưới dạng giá trị thập lục phân, cả hai trường hợp đều cần được kiểm tra. đầu tiên
sau đó chỉ mục có số sê-ri phù hợp sẽ được chọn.

Số sê-ri bằng 0 cho biết chỉ mục tương ứng không được liên kết
với pin thực tế hoặc không có pin liên quan.

Một số máy như Dell Inspiron 3505 chỉ hỗ trợ một pin duy nhất và do đó
bỏ qua chỉ số pin. Vì điều này mà trình điều khiển phụ thuộc vào pin ACPI
cơ chế móc để khám phá pin.

Kỹ thuật đảo ngược giao diện DDV WMI
=========================================

1. Tìm máy tính xách tay Dell được hỗ trợ, thường được sản xuất sau ~ năm 2020.
2. Kết xuất các bảng ACPI và tìm kiếm thiết bị WMI (thường được gọi là "ADDV").
3. Giải mã dữ liệu bmof tương ứng và xem mã ASL.
4. Cố gắng suy luận ý nghĩa của một phương pháp WMI nào đó bằng cách so sánh điều khiển
   chảy với các phương pháp ACPI khác (_BIX hoặc _BIF cho các phương pháp liên quan đến pin
   chẳng hạn).
5. Sử dụng công cụ chẩn đoán UEFI tích hợp để xem các loại/giá trị cảm biến cho quạt/nhiệt
   các phương pháp liên quan (đôi khi có thể sử dụng ghi đè các trường dữ liệu ACPI tĩnh
   để kiểm tra các giá trị loại cảm biến khác nhau, vì trên một số máy, dữ liệu này
   không được khởi động lại khi thiết lập lại ấm).

Ngoài ra:

1. Tải trình điều khiển ZZ0000ZZ, sử dụng thông số mô-đun ZZ0001ZZ
   nếu cần thiết.
2. Sử dụng giao diện debugfs để truy cập dữ liệu bộ đệm cảm biến nhiệt/quạt thô.
3. So sánh dữ liệu với chẩn đoán UEFI tích hợp.

Trong trường hợp phiên bản giao diện DDV WMI có sẵn trên máy tính xách tay Dell của bạn không có
được hỗ trợ hoặc bạn thấy cảm biến quạt/nhiệt không xác định, vui lòng gửi
báo cáo lỗi trên ZZ0001ZZ để có thể thêm chúng
tới trình điều khiển ZZ0000ZZ.

Xem Tài liệu/admin-guide/reporting-issues.rst để biết thêm thông tin.