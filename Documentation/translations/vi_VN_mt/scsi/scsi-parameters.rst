.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/scsi-parameters.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Thông số hạt nhân SCSI
========================

Xem Documentation/admin-guide/kernel-parameters.rst để biết thông tin chung về
chỉ định các tham số mô-đun.

Tài liệu này có thể không hoàn toàn cập nhật và đầy đủ. Lệnh
ZZ0000ZZ hiển thị danh sách hiện tại của tất cả các tham số có thể tải
mô-đun. Các mô-đun có thể tải, sau khi được tải vào kernel đang chạy, cũng
tiết lộ các tham số của chúng trong /sys/module/${modulename}/parameters/. Một số trong số này
các tham số có thể được thay đổi trong thời gian chạy bằng lệnh
ZZ0001ZZ.

::

advansys= [HW,SCSI]
			Xem tiêu đề của trình điều khiển/scsi/advansys.c.

aha152x= [HW,SCSI]
			Xem Tài liệu/scsi/aha152x.rst.

aha1542= [HW,SCSI]
			Định dạng: <portbase>[,<buson>,<busoff>[,<dmaspeed>]]

aic7xxx= [HW,SCSI]
			Xem Tài liệu/scsi/aic7xxx.rst.

aic79xx= [HW,SCSI]
			Xem Tài liệu/scsi/aic79xx.rst.

atascsi= [HW,SCSI]
			Xem trình điều khiển/scsi/atari_scsi.c.

BusLogic= [HW,SCSI]
			Xem trình điều khiển/scsi/BusLogic.c, nhận xét trước chức năng
			BusLogic_ParseDriverOptions().

gvp11= [HW,SCSI]

ips= [HW,SCSI] Bộ điều khiển Adaptec / IBM ServeRAID
			Xem tiêu đề của driver/scsi/ips.c.

mac5380= [HW,SCSI]
			Xem trình điều khiển/scsi/mac_scsi.c.

scsi_mod.max_luns=
			[SCSI] Số LUN tối đa cần thăm dò.
			Nên nằm trong khoảng từ 1 đến 2^32-1.

scsi_mod.max_report_luns=
			[SCSI] Số lượng LUN tối đa nhận được.
			Phải nằm trong khoảng từ 1 đến 16384.

NCR_D700= [HW,SCSI]
			Xem tiêu đề của trình điều khiển/scsi/NCR_D700.c.

ncr5380= [HW,SCSI]
			Xem Tài liệu/scsi/g_NCR5380.rst.

ncr53c400= [HW,SCSI]
			Xem Tài liệu/scsi/g_NCR5380.rst.

ncr53c400a= [HW,SCSI]
			Xem Tài liệu/scsi/g_NCR5380.rst.

ncr53c8xx= [HW,SCSI]

osst= [HW,SCSI] Trình điều khiển băng SCSI
			Định dạng: <buffer_size>,<write_threshold>
			Xem thêm Tài liệu/scsi/st.rst.

scsi_debug_*= [SCSI]
			Xem trình điều khiển/scsi/scsi_debug.c.

scsi_mod.default_dev_flags=
			[SCSI] Cờ thiết bị mặc định SCSI
			Định dạng: <số nguyên>

scsi_mod.dev_flags=
			[SCSI] Mục nhập danh sách đen/trắng dành cho nhà cung cấp và kiểu máy
			Định dạng: <nhà cung cấp>:<model>:<flags>
			(cờ là giá trị số nguyên)

scsi_mod.scsi_logging_level=
			[SCSI] một chút mặt nạ về mức độ ghi nhật ký
			Xem driver/scsi/scsi_logging.h để biết bit.  Ngoài ra
			có thể giải quyết qua sysctl tại dev.scsi.logging_level
			(/proc/sys/dev/scsi/logging_level).
			Ngoài ra còn có một tập lệnh 'scsi_logging_level' hay trong
			Gói công cụ S390, có sẵn để tải xuống tại
			ZZ0000ZZ

scsi_mod.scan= Đồng bộ hóa [SCSI] (mặc định) quét các bus SCSI như hiện tại
			được phát hiện.  async quét chúng trong các luồng nhân,
			cho phép tiến hành khởi động.  không ai bỏ qua họ, mong đợi
			không gian người dùng để thực hiện quét.

sim710= [SCSI,HW]
			Xem tiêu đề của trình điều khiển/scsi/sim710.c.

st= [HW,SCSI] Thông số băng SCSI (bộ đệm, v.v.)
			Xem Tài liệu/scsi/st.rst.

wd33c93= [HW,SCSI]
			Xem tiêu đề của trình điều khiển/scsi/wd33c93.c.