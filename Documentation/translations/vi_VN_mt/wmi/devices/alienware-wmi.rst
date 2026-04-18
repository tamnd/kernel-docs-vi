.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/wmi/devices/alienware-wmi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Trình điều khiển giao diện Dell AWCC WMI (alienware-wmi)
==============================================

Giới thiệu
============

Thiết bị WMI WMAX đã được triển khai cho nhiều dòng Alienware và G-Series của Dell
các mô hình. Trong suốt các mô hình này, hai cách triển khai đã được xác định. các
cái đầu tiên, được sử dụng bởi các hệ thống cũ hơn, xử lý HDMI, độ sáng, RGB, bộ khuếch đại
và kiểm soát giấc ngủ sâu. Cái thứ hai được sử dụng bởi các hệ thống mới hơn chủ yếu giải quyết
với điều khiển nhiệt và ép xung.

Người ta nghi ngờ rằng cái sau được sử dụng bởi Alienware Command Center (AWCC) để
quản lý hồ sơ nhiệt được xác định trước của nhà sản xuất. Trình điều khiển Alienware-wmi
hiển thị các phương thức Thermal_Information và Thermal_Control thông qua Nền tảng
Lập hồ sơ API để bắt chước hành vi của AWCC.

Giao diện mới hơn này, có tên AWCCMethodFunction đã được thiết kế ngược, như
Dell chưa cung cấp bất kỳ tài liệu chính thức nào. Chúng tôi sẽ cố gắng mô tả cho
trong khả năng tốt nhất của chúng tôi, nó đã phát hiện ra hoạt động bên trong của nó.

.. note::
   The following method description may be incomplete and some operations have
   different implementations between devices.

Mô tả giao diện WMI
-------------------------

Mô tả giao diện WMI có thể được giải mã từ mã nhị phân MOF (bmof) được nhúng
dữ liệu bằng tiện ích ZZ0000ZZ:

::

[WMI, Động, Nhà cung cấp("WmiProv"), Locale("MS\\0x409"), Description("WMI Function"), guid("{A70591CE-A997-11DA-B012-B622A1EF5492}")]
 lớp AWCCWmiMethodFunction {
   [phím, đọc] chuỗi Tên phiên bản;
   [đọc] boolean Hoạt động;

[WmiMethodId(13), Đã triển khai, đọc, viết, Mô tả("Trả về báo cáo ép xung.")] void Return_OverclockingReport([out] uint32 argr);
   [WmiMethodId(14), Đã triển khai, đọc, viết, Mô tả("Đặt điều khiển OCUIBIOS.")] void Set_OCUIBIOSControl([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(15), Đã triển khai, đọc, viết, Mô tả("Xóa cờ FailSafe OC.")] void Clear_OCFailSafeFlag([out] uint32 argr);
   [WmiMethodId(19), Đã triển khai, đọc, viết, Mô tả("Nhận cảm biến quạt.")] void GetFanSensors([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(20), Đã triển khai, đọc, viết, Mô tả("Thông tin nhiệt.")] void Thermal_Information([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(21), Đã triển khai, đọc, viết, Mô tả("Điều khiển nhiệt.")] void Thermal_Control([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(23), Đã triển khai, đọc, ghi, Mô tả("MemoryOCControl.")] void MemoryOCControl([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(26), Đã triển khai, đọc, viết, Mô tả("Thông tin hệ thống.")] void SystemInformation([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(28), Đã triển khai, đọc, viết, Mô tả("Thông tin nguồn.")] ​​void PowerInformation([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(32), Đã triển khai, đọc, viết, Mô tả("FW Update GPIO chuyển đổi.")] void FWUpdateGPIOtoggle([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(33), Đã triển khai, đọc, viết, Mô tả("Đọc Tổng số GPIO.")] void ReadTotalofGPIOs([out] uint32 argr);
   [WmiMethodId(34), Đã triển khai, đọc, viết, Mô tả("Đọc Trạng thái pin GPIO.")] void ReadGPIOpPinStatus([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(35), Đã triển khai, đọc, ghi, Mô tả("Đọc màu khung.")] void ReadChassisColor([out] uint32 argr);
   [WmiMethodId(36), Đã triển khai, đọc, viết, Mô tả("Đọc Thuộc tính Nền tảng.")] void ReadPlatformProperties([out] uint32 argr);
   [WmiMethodId(37), Đã triển khai, đọc, viết, Mô tả("Trạng thái thay đổi trò chơi.")] void GameShiftStatus([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(128), Đã triển khai, đọc, viết, Mô tả("Cài đặt Caldera SW.")] void CalderaSWInstallation([out] uint32 argr);
   [WmiMethodId(129), Đã triển khai, đọc, viết, Mô tả("Caldera SW được phát hành.")] void CalderaSWReleased([out] uint32 argr);
   [WmiMethodId(130), Đã triển khai, đọc, viết, Mô tả("Trạng thái kết nối Caldera.")] void CalderaConnectionStatus([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(131), Đã triển khai, đọc, viết, Mô tả("Trạng thái cờ chưa được cắm bất ngờ.")] void Ngạc nhiênUnpluggedFlagStatus([out] uint32 argr);
   [WmiMethodId(132), Đã triển khai, đọc, viết, Mô tả("Xóa cờ chưa cắm bất ngờ.")] void ClearSurpriseUnpluggedFlag([out] uint32 argr);
   [WmiMethodId(133), Đã triển khai, đọc, viết, Mô tả("Hủy yêu cầu tháo rời.")] void CancelUndockRequest([out] uint32 argr);
   [WmiMethodId(135), Đã triển khai, đọc, viết, Mô tả("Các thiết bị ở Caldera.")] void DevicesInCaldera([in] uint32 arg2, [out] uint32 argr);
   [WmiMethodId(136), Đã triển khai, đọc, viết, Mô tả("Thông báo cho BIOS về việc SW đã sẵn sàng ngắt kết nối Caldera.")] void NotifyBIOSForSWReadyToDisconnectCaldera([out] uint32 argr);
   [WmiMethodId(160), Đã triển khai, đọc, viết, Mô tả("Cài đặt Tobii SW.")] void TobiiSWinstallation([out] uint32 argr);
   [WmiMethodId(161), Đã triển khai, đọc, viết, Mô tả("Tobii SW đã phát hành.")] void TobiiSWReleased([out] uint32 argr);
   [WmiMethodId(162), Đã triển khai, đọc, viết, Mô tả("Đặt lại nguồn máy ảnh Tobii.")] void TobiiCameraPowerReset([out] uint32 argr);
   [WmiMethodId(163), Đã triển khai, đọc, viết, Mô tả("Tobii Camera Power On.")] ​​void TobiiCameraPowerOn([out] uint32 argr);
   [WmiMethodId(164), Đã triển khai, đọc, viết, Mô tả("Tobii Camera Power Off.")] void TobiiCameraPowerOff([out] uint32 argr);
 };

Các phương pháp không được mô tả trong tài liệu sau đây có hành vi không xác định.

Cấu trúc đối số
------------------

Tất cả các đối số đầu vào đều có loại ZZ0000ZZ và cấu trúc của chúng rất giống nhau
giữa các phương pháp. Thông thường, byte đầu tiên tương ứng với ZZ0001ZZ cụ thể
phương thức thực hiện và các byte tiếp theo tương ứng với ZZ0002ZZ được truyền
đến chiếc ZZ0003ZZ này. Ví dụ: nếu một thao tác có mã 0x01 và yêu cầu
ID 0xA0, đối số bạn sẽ chuyển cho phương thức là 0xA001.


Phương pháp nhiệt
===============

Phương thức WMI GetFanSensors([in] uint32 arg2, [out] uint32 argr)
-------------------------------------------------------------

+-------------------+--------------------------------------+-------------------+
ZZ0000ZZ Mô tả ZZ0001ZZ
+=======================================================================================================================
ZZ0002ZZ Lấy số nhiệt độ ZZ0003ZZ
Cảm biến ZZ0004ZZ liên quan đến ID quạt ZZ0005ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0006ZZ Nhận ID cảm biến nhiệt độ ZZ0007ZZ
ZZ0008ZZ liên quan đến cảm biến quạt ID ZZ0009ZZ
+-------------------+--------------------------------------+-------------------+

Phương thức WMI Thermal_Information([in] uint32 arg2, [out] uint32 argr)
-------------------------------------------------------------------

+-------------------+--------------------------------------+-------------------+
ZZ0002ZZ Mô tả ZZ0003ZZ
+=======================================================================================================================
ZZ0004ZZ Không rõ.                           ZZ0005ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0006ZZ Nhận số mô tả hệ thống với ZZ0007ZZ
ZZ0008ZZ cấu trúc sau: ZZ0009ZZ
ZZ0010ZZ ZZ0011ZZ
ZZ0012ZZ - Byte 0: Số lượng quạt ZZ0013ZZ
ZZ0014ZZ - Byte 1: Số nhiệt độ ZZ0015ZZ
Cảm biến ZZ0016ZZ ZZ0017ZZ
ZZ0018ZZ - Byte 2: ZZ0019ZZ không xác định
ZZ0020ZZ - Byte 3: Số lượng nhiệt ZZ0021ZZ
Hồ sơ ZZ0022ZZ ZZ0023ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0024ZZ Liệt kê ID hoặc tài nguyên tại ZZ0025ZZ nhất định
Chỉ số ZZ0026ZZ. ID quạt, ID nhiệt độ, ZZ0027ZZ
ZZ0028ZZ ID không xác định và hồ sơ nhiệt ZZ0029ZZ
ID ZZ0030ZZ được liệt kê chính xác trong ZZ0031ZZ đó
Đơn hàng ZZ0032ZZ.                             ZZ0033ZZ
ZZ0034ZZ ZZ0035ZZ
ZZ0036ZZ Hoạt động 0x02 được sử dụng để biết ZZ0037ZZ
ZZ0038ZZ lập chỉ mục ánh xạ tới ZZ0039ZZ nào
Tài nguyên ZZ0040ZZ.                         ZZ0041ZZ
ZZ0042ZZ ZZ0043ZZ
ZZ0044ZZ ZZ0001ZZ ID tại một chỉ mục nhất định ZZ0045ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0046ZZ Nhận nhiệt độ hiện tại cho ZZ0047ZZ
Cảm biến nhiệt độ ZZ0048ZZ.          ZZ0049ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0050ZZ Nhận RPM hiện tại cho ZZ0051ZZ nhất định
Quạt ZZ0052ZZ.                               ZZ0053ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0054ZZ Nhận phần trăm tốc độ quạt. (không phải ZZ0055ZZ
ZZ0056ZZ được triển khai trong mọi kiểu máy) ZZ0057ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0058ZZ Không rõ.                           ZZ0059ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0060ZZ Nhận RPM tối thiểu cho một FAN ZZ0061ZZ nhất định
Mã số ZZ0062ZZ.                                ZZ0063ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0064ZZ Nhận RPM tối đa cho một FAN ZZ0065ZZ nhất định
Mã số ZZ0066ZZ.                                ZZ0067ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0068ZZ Nhận ID hồ sơ nhiệt cân bằng.   ZZ0069ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0070ZZ Nhận ID hồ sơ nhiệt hiện tại.    ZZ0071ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0072ZZ Nhận giá trị ZZ0000ZZ hiện tại cho ZZ0073ZZ
ZZ0074ZZ được cấp ID người hâm mộ.                      ZZ0075ZZ
+-------------------+--------------------------------------+-------------------+

Phương thức WMI Thermal_Control([in] uint32 arg2, [out] uint32 argr)
---------------------------------------------------------------

+-------------------+--------------------------------------+-------------------+
ZZ0001ZZ Mô tả ZZ0002ZZ
+=======================================================================================================================
ZZ0003ZZ Kích hoạt một cấu hình nhiệt nhất định.  ZZ0004ZZ
ZZ0005ZZ ZZ0006ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0007ZZ Đặt giá trị ZZ0000ZZ cho ZZ0008ZZ nhất định
ID người hâm mộ ZZ0009ZZ.                            ZZ0010ZZ
+-------------------+--------------------------------------+-------------------+

Đây là các mã hồ sơ nhiệt đã biết:

+------------------------------+----------+------+
ZZ0000ZZ Loại ZZ0001ZZ
+=========================================================+
ZZ0002ZZ Đặc biệt ZZ0003ZZ
+------------------------------+----------+------+
ZZ0004ZZ Đặc biệt ZZ0005ZZ
+------------------------------+----------+------+
ZZ0006ZZ Di sản ZZ0007ZZ
+------------------------------+----------+------+
ZZ0008ZZ Di sản ZZ0009ZZ
+------------------------------+----------+------+
ZZ0010ZZ Di sản ZZ0011ZZ
+------------------------------+----------+------+
ZZ0012ZZ Di sản ZZ0013ZZ
+------------------------------+----------+------+
ZZ0014ZZ USTT ZZ0015ZZ
+------------------------------+----------+------+
ZZ0016ZZ USTT ZZ0017ZZ
+------------------------------+----------+------+
ZZ0018ZZ USTT ZZ0019ZZ
+------------------------------+----------+------+
ZZ0020ZZ USTT ZZ0021ZZ
+------------------------------+----------+------+
ZZ0022ZZ USTT ZZ0023ZZ
+------------------------------+----------+------+
ZZ0024ZZ USTT ZZ0025ZZ
+------------------------------+----------+------+

Nếu một model hỗ trợ cấu hình Bàn nhiệt có thể lựa chọn của người dùng (USTT), nó sẽ
không hỗ trợ cấu hình Legacy và ngược lại.

Mọi model đều hỗ trợ cấu hình nhiệt CUSTOM (0x00). GMODE thay thế
PERFORMANCE trong máy tính xách tay G-Series.

Phương thức WMI GameShiftStatus([in] uint32 arg2, [out] uint32 argr)
---------------------------------------------------------------

+-------------------+--------------------------------------+-------------------+
ZZ0002ZZ Mô tả ZZ0003ZZ
+=======================================================================================================================
ZZ0004ZZ Chuyển đổi ZZ0000ZZ.               ZZ0005ZZ
+-------------------+--------------------------------------+-------------------+
ZZ0006ZZ Nhận trạng thái ZZ0001ZZ.           ZZ0007ZZ
+-------------------+--------------------------------------+-------------------+

Trạng thái chuyển trò chơi không thay đổi cấu hình tốc độ quạt nhưng có thể thay đổi một số
loại cấu hình nguồn CPU/GPU. Điểm chuẩn chưa được thực hiện.

Phương pháp này chỉ có trên máy tính xách tay G-Series của Dell và nó được triển khai
ngụ ý có sẵn cấu hình nhiệt GMODE, ngay cả khi hoạt động 0x03 của
Thermal_Information không liệt kê nó.

Phím G trên laptop G-Series của Dell cũng thay đổi trạng thái Game Shift nên cả hai đều
liên quan trực tiếp.

Phương pháp ép xung
====================

Phương thức WMI MemoryOCControl([in] uint32 arg2, [out] uint32 argr)
---------------------------------------------------------------

AWCC hỗ trợ ép xung bộ nhớ, nhưng phương pháp này rất phức tạp và có
vẫn chưa được giải mã.

Phương pháp điều khiển GPIO
====================

Các thiết bị Alienware và Dell G Series có giao diện AWCC thường có
Bộ điều khiển chiếu sáng STM32 RGB được nhúng với các tính năng USB/HID. Đó là ID nhà cung cấp
là ZZ0000ZZ trong khi ID sản phẩm của nó có thể khác nhau tùy theo kiểu máy.

Việc điều khiển hai chân GPIO của MCU này được hiển thị dưới dạng phương thức WMI để gỡ lỗi
mục đích.

+--------------+-------------------------------------------------------------- +
ZZ0004ZZ Mô tả |
+====================================================================================================================================================================
Cập nhật chương trình cơ sở thiết bị ZZ0005ZZ (DFU) ZZ0006ZZ
Chân chế độ ZZ0007ZZ.                     ZZ0008ZZ
ZZ0009ZZ +------------------------------ +
ZZ0010ZZ ZZ0011ZZ
ZZ0012ZZ ZZ0013ZZ
+--------------+------------------------------+---------------------+
Chân đặt lại âm ZZ0014ZZ (NRST).    ZZ0015ZZ
ZZ0016ZZ ZZ0017ZZ
ZZ0018ZZ +------------------------------ +
ZZ0019ZZ ZZ0020ZZ
ZZ0021ZZ ZZ0022ZZ
+--------------+------------------------------+---------------------+

Xem ZZ0000ZZ để biết thêm thông tin về MCU này.

.. note::
   Some GPIO control methods break the usual argument structure and take a
   **Pin number** instead of an operation on the first byte.

Phương thức WMI FWUpdateGPIOtoggle([in] uint32 arg2, [out] uint32 argr)
------------------------------------------------------------------

+-------------------+--------------------------------------+-------------------+
ZZ0000ZZ Mô tả ZZ0001ZZ
+=======================================================================================================================
ZZ0002ZZ Đặt trạng thái pin ZZ0003ZZ
ZZ0004ZZ ZZ0005ZZ
+-------------------+--------------------------------------+-------------------+

Phương thức WMI ReadTotalofGPIOs([out] uint32 argr)
----------------------------------------------

+-------------------+--------------------------------------+-------------------+
ZZ0000ZZ Mô tả ZZ0001ZZ
+=======================================================================================================================
ZZ0002ZZ Lấy tổng số GPIO ZZ0003ZZ
+-------------------+--------------------------------------+-------------------+

.. note::
   Due to how WMI methods are implemented on the firmware level, this method
   requires a dummy uint32 input argument when invoked.

Phương thức WMI ReadGPIOpPinStatus([in] uint32 arg2, [out] uint32 argr)
------------------------------------------------------------------

+-------------------+--------------------------------------+-------------------+
ZZ0000ZZ Mô tả ZZ0001ZZ
+=======================================================================================================================
ZZ0002ZZ Nhận trạng thái pin ZZ0003ZZ
+-------------------+--------------------------------------+-------------------+

.. note::
   There known firmware bug in some laptops where reading the status of a pin
   also flips it.

Thông tin khác
=========================

Phương thức WMI ReadChassisColor([out] uint32 argr)
----------------------------------------------

Trả về ID bên trong màu khung.

.. _acknowledgements:

Lời cảm ơn
================

Cảm ơn

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ

để ghi lại và kiểm tra một số chức năng của thiết bị này, làm cho nó
có thể khái quát trình điều khiển này.