.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/smartpqi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================
SMARTPQI - Trình điều khiển lưu trữ thông minh Microchip SCSI
=============================================================

Tệp này mô tả trình điều khiển smartpqi SCSI cho Microchip
(Bộ điều khiển ZZ0000ZZ PQI. Trình điều khiển smartpqi
là trình điều khiển SCSI thế hệ tiếp theo của Microchip Corp. Smartpqi
trình điều khiển là trình điều khiển SCSI đầu tiên triển khai mô hình xếp hàng PQI.

Trình điều khiển smartpqi sẽ thay thế trình điều khiển aacraid cho Adaptec Series 9
bộ điều khiển. Khách hàng chạy kernel cũ hơn (Pre-4.9) bằng Adaptec
Bộ điều khiển Series 9 sẽ phải định cấu hình trình điều khiển smartpqi hoặc trình điều khiển của chúng
khối lượng sẽ không được thêm vào hệ điều hành.

Để hỗ trợ bộ điều khiển Smartpqi của Microchip, hãy bật trình điều khiển smartpqi
khi cấu hình kernel.

Để biết thêm thông tin về Giao diện xếp hàng PQI, vui lòng xem:

-ZZ0000ZZ
-ZZ0001ZZ

Thiết bị được hỗ trợ
=================
<Tên bộ điều khiển sẽ được thêm vào khi chúng được cung cấp công khai.>

các mục cụ thể của smartpqi trong/sys
=================================

Thuộc tính máy chủ Smartpqi
------------------------
- /sys/class/scsi_host/host*/rescan
  - /sys/class/scsi_host/host*/driver_version

Thuộc tính quét lại máy chủ là thuộc tính chỉ ghi. Viết cho cái này
  thuộc tính sẽ kích hoạt trình điều khiển quét tìm mới, thay đổi hoặc xóa
  thiết bị và thông báo cho lớp giữa SCSI về bất kỳ thay đổi nào được phát hiện.

Thuộc tính phiên bản chỉ đọc và sẽ trả về phiên bản trình điều khiển
  và phiên bản phần sụn của bộ điều khiển.
  Ví dụ::

tài xế: 0.9.13-370
              phần sụn: 0,01-522

thuộc tính thiết bị smartpqi sas
------------------------------
Các thiết bị HBA được thêm vào lớp vận chuyển SAS. Những thuộc tính này là
  được tự động thêm vào bởi lớp vận chuyển SAS.

/sys/class/sas_device/end_device-X:X/sas_address
  /sys/class/sas_device/end_device-X:X/enclosure_identifier
  /sys/class/sas_device/end_device-X:X/scsi_target_id

ioctls cụ thể của smartpqi
========================

Để tương thích với các ứng dụng được viết cho giao thức cciss.

CCISS_DEREGDISK, CCISS_REGNEWDISK, CCISS_REGNEWD
	Ba ioctls trên đều thực hiện chính xác điều tương tự, đó là khiến trình điều khiển
	để quét lại các thiết bị mới.  Việc này thực hiện chính xác giống như việc viết thư cho
	Thuộc tính "quét lại" máy chủ cụ thể của Smartpqi.

CCISS_GETPCIINFO
	Trả về miền PCI, bus, thiết bị và chức năng cũng như "ID bo mạch" (ID hệ thống con PCI).

CCISS_GETDRIVVER
	Trả về phiên bản trình điều khiển theo ba byte được mã hóa dưới dạng::

(DRIVER_MAJOR << 28) ZZ0000ZZ (DRIVER_RELEASE << 16) | DRIVER_REVISION;

CCISS_PASSTHRU
	Cho phép truyền các lệnh "BMIC" và "CISS" tới Mảng lưu trữ thông minh.
	Chúng được sử dụng rộng rãi bởi Tiện ích cấu hình mảng SSA, bộ lưu trữ SNMP
	đại lý, v.v.