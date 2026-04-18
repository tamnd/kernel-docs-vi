.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/ultrasoc-smb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
UltraSoc - Truy tìm phần mềm được hỗ trợ trên SoC
=================================================
:Tác giả: Tề Lưu <liuqi115@huawei.com>
   :Ngày: Tháng 1 năm 2023

Giới thiệu
------------

UltraSoc SMB là phần cứng trên mỗi SCCL (Super CPU Cluster). Nó cung cấp một
cách đệm và lưu trữ tin nhắn theo dõi CPU trong một vùng của hệ thống dùng chung
trí nhớ. Thiết bị này hoạt động như một thiết bị chìm coresight và
bộ tạo dấu vết tương ứng (ETM) được đính kèm dưới dạng thiết bị nguồn.

Các tập tin và thư mục Sysfs
---------------------------

Các thiết bị SMB xuất hiện trên bus coresight hiện có cùng với các thiết bị khác
thiết bị::

$# ls /sys/bus/coresight/thiết bị/
	ultra_smb0 ultra_smb1 ultra_smb2 ultra_smb3

ZZ0000ZZ đặt tên cho thiết bị SMB được liên kết với SCCL.::

$# ls /sys/bus/coresight/devices/ultra_smb0
	Enable_sink mgmt
	$# ls /sys/bus/coresight/devices/ultra_smb0/mgmt
	buf_size buf_status read_pos write_pos

Các mục tập tin chính là:

* ZZ0000ZZ: Hiển thị giá trị trên thanh ghi con trỏ đọc.
   * ZZ0001ZZ: Hiển thị giá trị trên thanh ghi con trỏ ghi.
   * ZZ0002ZZ: Hiển thị giá trị trên thanh ghi trạng thái.
     BIT(0) có giá trị bằng 0, nghĩa là bộ đệm trống.
   * ZZ0003ZZ: Hiển thị kích thước bộ đệm của từng thiết bị.

Ràng buộc phần sụn
-----------------

Thiết bị chỉ được hỗ trợ với ACPI. Ràng buộc của nó mô tả thiết bị
mã định danh, thông tin tài nguyên và cấu trúc đồ thị.

Thiết bị được xác định là ACPI HID "HISI03A1". Tài nguyên thiết bị được phân bổ
bằng phương pháp _CRS. Mỗi thiết bị phải trình bày hai địa chỉ cơ sở; cái đầu tiên
là địa chỉ cơ sở cấu hình của thiết bị, địa chỉ thứ hai là 32 bit
địa chỉ cơ sở của bộ nhớ hệ thống dùng chung.

Ví dụ::

Thiết bị(USMB) { \
      Tên(_HID, "HISI03A1") \
      Tên(_CRS, ResourceTemplate() { \
          QWordMemory (ResourceConsumer, , MinFixed, MaxFixed, NonCacheable, \
		       ĐọcWrite, 0x0, 0x95100000, 0x951FFFFF, 0x0, 0x100000) \
          QWordMemory (ResourceConsumer, , MinFixed, MaxFixed, Có thể lưu vào bộ nhớ đệm, \
		       ĐọcWrite, 0x0, 0x50000000, 0x53FFFFFF, 0x0, 0x4000000) \
      }) \
      Tên(_DSD, Gói() { \
        ToUUID("ab02a46b-74c7-45a2-bd68-f7d344ef2153"), \
	/* Sử dụng các liên kết CoreSight Graph ACPI để mô tả cấu trúc liên kết kết nối */
        Gói() { \
          0, \
          1, \
          Gói() { \
            1, \
            ToUUID("3ecbc8b6-1d0e-4fb3-8107-e627f805c6cd"), \
            8, \
            Gói() {0x8, 0, \_SB.S00.SL11.CL28.F008, 0}, \
            Gói() {0x9, 0, \_SB.S00.SL11.CL29.F009, 0}, \
            Gói() {0xa, 0, \_SB.S00.SL11.CL2A.F010, 0}, \
            Gói() {0xb, 0, \_SB.S00.SL11.CL2B.F011, 0}, \
            Gói() {0xc, 0, \_SB.S00.SL11.CL2C.F012, 0}, \
            Gói() {0xd, 0, \_SB.S00.SL11.CL2D.F013, 0}, \
            Gói() {0xe, 0, \_SB.S00.SL11.CL2E.F014, 0}, \
            Gói() {0xf, 0, \_SB.S00.SL11.CL2F.F015, 0}, \
          } \
        } \
      }) \
    }