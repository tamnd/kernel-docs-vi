.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/hpsa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================
HPSA - Trình điều khiển mảng thông minh Hewlett Packard
=======================================================

Tệp này mô tả trình điều khiển hpsa SCSI cho bộ điều khiển HP Smart Array.
Trình điều khiển hpsa nhằm thay thế trình điều khiển cciss mới hơn
Bộ điều khiển mảng thông minh.  Trình điều khiển hpsa là trình điều khiển SCSI, trong khi
trình điều khiển cciss là trình điều khiển "chặn".  Thực ra cciss vừa là một khối
trình điều khiển (cho ổ đĩa logic) AND trình điều khiển SCSI (cho ổ băng từ). Cái này
Thiết kế “chia não” của driver cciss là nguồn gốc của sự dư thừa
sự phức tạp và loại bỏ sự phức tạp đó là một trong những lý do
để hpsa tồn tại.

Thiết bị được hỗ trợ
=================

- Mảng thông minh P212
- Mảng thông minh P410
- Mảng thông minh P410i
- Mảng thông minh P411
- Mảng thông minh P812
- Mảng thông minh P712m
- Mảng thông minh P711m
- StorageWorks P1210m

Ngoài ra, Smart Arrays cũ hơn có thể hoạt động với trình điều khiển hpsa nếu kernel
tham số khởi động "hpsa_allow_any=1" được chỉ định, tuy nhiên chúng không được kiểm tra
cũng không được HP hỗ trợ với trình điều khiển này.  Đối với Mảng thông minh cũ hơn, cciss
driver vẫn nên dùng.

Tham số khởi động "hpsa_simple_mode=1" có thể được sử dụng để ngăn trình điều khiển khỏi
đưa bộ điều khiển vào chế độ "hiệu suất".  Sự khác biệt là ở chỗ đơn giản
chế độ, mỗi lần hoàn thành lệnh yêu cầu ngắt, trong khi với "chế độ hiệu suất"
(mặc định và thường hoạt động tốt hơn) có thể có nhiều
hoàn thành lệnh được chỉ định bởi một ngắt duy nhất.

Các mục cụ thể của HPSA trong /sys
=============================

Ngoài các thuộc tính SCSI chung có sẵn trong /sys, hpsa còn hỗ trợ
  các thuộc tính sau:

Thuộc tính máy chủ cụ thể của HPSA
=============================

  ::

/sys/class/scsi_host/host*/rescan
    /sys/class/scsi_host/host*/firmware_revision
    /sys/class/scsi_host/host*/có thể đặt lại
    /sys/class/scsi_host/host*/transport_mode

thuộc tính "quét lại" của máy chủ là thuộc tính chỉ ghi.  Viết cho cái này
  thuộc tính sẽ khiến trình điều khiển quét các thiết bị mới, đã thay đổi hoặc bị xóa
  (ví dụ: các ổ băng từ được cắm nóng hoặc các ổ đĩa logic mới được cấu hình hoặc bị xóa,
  v.v.) và thông báo cho lớp giữa SCSI về bất kỳ thay đổi nào được phát hiện.  Thông thường đây là
  được kích hoạt tự động bởi Tiện ích cấu hình mảng của HP (GUI hoặc
  dòng lệnh) nên đối với những thay đổi ổ đĩa logic, người dùng không nên
  bình thường phải dùng cái này  Nó có thể hữu ích khi cắm nóng các thiết bị như
  ổ băng từ hoặc toàn bộ hộp lưu trữ chứa các ổ đĩa logic được cấu hình sẵn.

Thuộc tính "firmware_revision" chứa phiên bản phần sụn của Smart Array.
  Ví dụ::

root@host:/sys/class/scsi_host/host4# cat firmware_revision
	7.14

Transport_mode cho biết bộ điều khiển có ở trạng thái "hoạt động" hay không
  hoặc chế độ "đơn giản".  Điều này được điều khiển bởi mô-đun "hpsa_simple_mode"
  tham số.

Thuộc tính chỉ đọc "có thể đặt lại" cho biết liệu một
  bộ điều khiển có thể tôn vinh tham số kernel "reset_devices".  Nếu
  thiết bị có thể đặt lại được, tệp này sẽ chứa "1", nếu không thì là "0".  Cái này
  tham số được sử dụng bởi kdump, ví dụ, để thiết lập lại bộ điều khiển tại trình điều khiển
  thời gian tải để loại bỏ mọi lệnh còn sót lại trên bộ điều khiển và nhận
  bộ điều khiển sang trạng thái đã biết để i/o khởi tạo kdump sẽ hoạt động bình thường
  và không bị gián đoạn dưới bất kỳ hình thức nào bởi các lệnh cũ hoặc trạng thái cũ khác
  còn lại trên bộ điều khiển từ kernel trước.  Thuộc tính này cho phép
  kexec để cảnh báo người dùng nếu họ cố gắng chỉ định một thiết bị
  không thể tôn vinh tham số kernel reset_devices làm thiết bị kết xuất.

Thuộc tính đĩa cụ thể của HPSA
-----------------------------

  ::

/sys/class/scsi_disk/c:b:t:l/device/unique_id
    /sys/class/scsi_disk/c:b:t:l/device/raid_level
    /sys/class/scsi_disk/c:b:t:l/device/lunid

(trong đó c:b:t:l là bộ điều khiển, bus, đích và lun của thiết bị)

Ví dụ::

root@host:/sys/class/scsi_disk/4:0:0:0/device# cat Unique_id
	600508B1001044395355323037570F77
	root@host:/sys/class/scsi_disk/4:0:0:0/device# cat lunid
	0x0000004000000000
	root@host:/sys/class/scsi_disk/4:0:0:0/device# cat raid_level
	RAID 0

Ioctls cụ thể của HPSA
====================

Để tương thích với các ứng dụng được viết cho trình điều khiển cciss, nhiều, nhưng
  không phải tất cả ioctls được trình điều khiển cciss hỗ trợ cũng được hỗ trợ bởi
  trình điều khiển hpsa.  Cấu trúc dữ liệu được sử dụng bởi chúng được mô tả trong
  bao gồm/linux/cciss_ioctl.h

CCISS_DEREGDISK, CCISS_REGNEWDISK, CCISS_REGNEWD
	Ba ioctls trên đều thực hiện chính xác điều tương tự, đó là khiến trình điều khiển
	để quét lại các thiết bị mới.  Việc này thực hiện chính xác giống như việc viết thư cho
	thuộc tính "quét lại" máy chủ cụ thể của hpsa.

CCISS_GETPCIINFO
	Trả về miền PCI, bus, thiết bị và chức năng cũng như "ID bo mạch" (ID hệ thống con PCI).

CCISS_GETDRIVVER
	Trả về phiên bản trình điều khiển theo ba byte được mã hóa dưới dạng::

(phiên bản chính << 16) ZZ0000ZZ (phiên bản phụ)

CCISS_PASSTHRU, CCISS_BIG_PASSTHRU
	Cho phép truyền lệnh "BMIC" và "CISS" tới Smart Array.
	Chúng được sử dụng rộng rãi bởi Tiện ích Cấu hình HP Array, bộ lưu trữ SNMP
	đại lý, v.v. Xem cciss_vol_status tại ZZ0000ZZ để biết một số ví dụ.