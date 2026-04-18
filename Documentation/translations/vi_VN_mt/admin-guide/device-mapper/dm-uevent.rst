.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-uevent.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
sự kiện ánh xạ thiết bị
====================

Mã sự kiện của trình ánh xạ thiết bị bổ sung khả năng cho trình ánh xạ thiết bị để tạo
và gửi các sự kiện kobject (uevent).  Các sự kiện ánh xạ thiết bị trước đây chỉ
có sẵn thông qua giao diện ioctl.  Ưu điểm của giao diện ueevent
là sự kiện chứa các thuộc tính môi trường cung cấp bối cảnh gia tăng cho
sự kiện tránh được nhu cầu truy vấn trạng thái của thiết bị ánh xạ thiết bị sau
sự kiện được nhận.

Hiện tại có hai chức năng dành cho các sự kiện ánh xạ thiết bị.  Chức năng đầu tiên
được liệt kê tạo ra sự kiện và hàm thứ hai sẽ gửi (các) sự kiện::

void dm_path_uevent(enum dm_uevent_type sự kiện_type, struct dm_target *ti,
                      const char *path, nr_valid_paths không dấu)

void dm_send_uevents(struct list_head *events, struct kobject *kobj)


Các biến được thêm vào môi trường uevent là:

Tên biến: DM_TARGET
------------------------
:(Các) hành động sự kiện: KOBJ_CHANGE
:Loại: chuỗi
:Mô tả:
:Giá trị: Tên của mục tiêu ánh xạ thiết bị đã tạo ra sự kiện.

Tên biến: DM_ACTION
------------------------
:(Các) hành động sự kiện: KOBJ_CHANGE
:Loại: chuỗi
:Mô tả:
:Giá trị: Hành động cụ thể của trình ánh xạ thiết bị đã gây ra hành động sự kiện.
	PATH_FAILED - Đường dẫn bị lỗi;
	PATH_REINSTATED - Một đường dẫn đã được khôi phục.

Tên biến: DM_SEQNUM
------------------------
:(Các) hành động sự kiện: KOBJ_CHANGE
:Type: số nguyên không dấu
:Mô tả: Số thứ tự cho thiết bị ánh xạ thiết bị cụ thể này.
:Value: Phạm vi số nguyên không dấu hợp lệ.

Tên biến: DM_PATH
----------------------
:(Các) hành động sự kiện: KOBJ_CHANGE
:Loại: chuỗi
:Mô tả: Số chính và số phụ của thiết bị đường dẫn liên quan đến điều này
	      sự kiện.
:Value: Tên đường dẫn ở dạng "Major:Minor"

Tên biến: DM_NR_VALID_PATHS
--------------------------------
:(Các) hành động sự kiện: KOBJ_CHANGE
:Type: số nguyên không dấu
:Mô tả:
:Value: Phạm vi số nguyên không dấu hợp lệ.

Tên biến: DM_NAME
----------------------
:(Các) hành động sự kiện: KOBJ_CHANGE
:Loại: chuỗi
:Mô tả: Tên của thiết bị ánh xạ thiết bị.
:Giá trị: Tên

Tên biến: DM_UUID
----------------------
:(Các) hành động sự kiện: KOBJ_CHANGE
:Loại: chuỗi
:Mô tả: UUID của thiết bị ánh xạ thiết bị.
:Giá trị: UUID. (Chuỗi trống nếu không có.)

Một ví dụ về các sự kiện được tạo bởi udevmonitor được hiển thị
bên dưới

1.) Lỗi đường dẫn::

UEVENT[1192521009.711215] thay đổi@/block/dm-3
	ACTION=thay đổi
	DEVPATH=/khối/dm-3
	SUBSYSTEM=khối
	DM_TARGET=đa đường
	DM_ACTION=PATH_FAILED
	DM_SEQNUM=1
	DM_PATH=8:32
	DM_NR_VALID_PATHS=0
	DM_NAME=mpath2
	DM_UUID=mpath-353333333000002328
	MINOR=3
	MAJOR=253
	SEQNUM=1130

2.) Đường dẫn khôi phục::

UEVENT[1192521132.989927] thay đổi@/block/dm-3
	ACTION=thay đổi
	DEVPATH=/khối/dm-3
	SUBSYSTEM=khối
	DM_TARGET=đa đường
	DM_ACTION=PATH_REINSTATED
	DM_SEQNUM=2
	DM_PATH=8:32
	DM_NR_VALID_PATHS=1
	DM_NAME=mpath2
	DM_UUID=mpath-353333333000002328
	MINOR=3
	MAJOR=253
	SEQNUM=1131
