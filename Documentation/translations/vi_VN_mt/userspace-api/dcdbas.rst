.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/dcdbas.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Trình điều khiển cơ sở quản lý hệ thống Dell
===================================

Tổng quan
========

Trình điều khiển cơ sở quản lý hệ thống Dell cung cấp giao diện sysfs cho
phần mềm quản lý hệ thống như Dell OpenManager để thực hiện hệ thống
ngắt quản lý và các hành động điều khiển máy chủ (chu kỳ nguồn hệ thống hoặc
tắt nguồn sau khi tắt hệ điều hành) trên một số hệ thống Dell nhất định.

Dell OpenManager yêu cầu trình điều khiển này trên các hệ thống Dell PowerEdge sau:
300, 1300, 1400, 400SC, 500SC, 1500SC, 1550, 600SC, 1600SC, 650, 1655MC,
700 và 750. Các phần mềm khác của Dell như dự án libsmbios mã nguồn mở
dự kiến sẽ sử dụng trình điều khiển này và nó có thể bao gồm việc sử dụng trình điều khiển này
trình điều khiển trên các hệ thống Dell khác.

Dự án libsmbios của Dell nhằm mục đích cung cấp quyền truy cập vào càng nhiều BIOS
thông tin nhất có thể.  Xem ZZ0000ZZ để biết
thêm thông tin về dự án libsmbios.


Ngắt quản lý hệ thống
===========================

Trên một số hệ thống Dell, phần mềm quản lý hệ thống phải truy cập một số
thông tin quản lý thông qua ngắt quản lý hệ thống (SMI).  Dữ liệu SMI
bộ đệm phải nằm trong không gian địa chỉ 32 bit và địa chỉ vật lý của
cần có bộ đệm cho SMI.  Trình điều khiển duy trì bộ nhớ cần thiết cho
SMI và cung cấp cách để ứng dụng tạo SMI.
Trình điều khiển tạo các mục sysfs sau để quản lý hệ thống
phần mềm để thực hiện các ngắt quản lý hệ thống này::

/sys/thiết bị/nền tảng/dcdbas/smi_data
	/sys/devices/platform/dcdbas/smi_data_buf_phys_addr
	/sys/thiết bị/nền tảng/dcdbas/smi_data_buf_size
	/sys/thiết bị/nền tảng/dcdbas/smi_request

Phần mềm quản lý hệ thống phải thực hiện các bước sau để thực thi
SMI sử dụng trình điều khiển này:

1) Khóa smi_data.
2) Viết lệnh quản lý hệ thống vào smi_data.
3) Viết "1" vào smi_request để tạo giao diện gọi SMI hoặc
   "2" để tạo SMI thô.
4) Đọc phản hồi lệnh quản lý hệ thống từ smi_data.
5) Mở khóa smi_data.


Hành động điều khiển máy chủ
===================

Dell OpenManager hỗ trợ tính năng điều khiển máy chủ cho phép quản trị viên
để thực hiện một chu trình cấp nguồn hoặc tắt nguồn hệ thống sau khi hệ điều hành kết thúc
đang tắt.  Trên một số hệ thống Dell, tính năng điều khiển máy chủ này yêu cầu
trình điều khiển thực hiện SMI sau khi hệ điều hành tắt xong.

Trình điều khiển tạo các mục sysfs sau cho phần mềm quản lý hệ thống
để lên lịch cho trình điều khiển thực hiện chu trình cấp nguồn hoặc tắt nguồn điều khiển máy chủ
hành động sau khi hệ thống đã tắt xong:

/sys/thiết bị/nền tảng/dcdbas/host_control_action
/sys/thiết bị/nền tảng/dcdbas/host_control_smi_type
/sys/thiết bị/nền tảng/dcdbas/host_control_on_shutdown

Dell OpenManager thực hiện các bước sau để thực hiện chu trình cấp nguồn hoặc
tắt nguồn hành động điều khiển máy chủ bằng trình điều khiển này:

1) Viết hành động điều khiển máy chủ sẽ được thực hiện vào Host_control_action.
2) Ghi loại SMI mà trình điều khiển cần thực hiện vào Host_control_smi_type.
3) Viết "1" vào Host_control_on_shutdown để kích hoạt hành động điều khiển máy chủ.
4) Bắt đầu tắt hệ điều hành.
   (Trình điều khiển sẽ thực hiện điều khiển máy chủ SMI khi được thông báo rằng HĐH
   đã tắt xong.)


Điều khiển máy chủ Loại SMI
=====================

Bảng sau hiển thị giá trị cần ghi vào Host_control_smi_type tới
thực hiện chu kỳ nguồn hoặc tắt nguồn hành động điều khiển máy chủ:

==========================================
Điều khiển máy chủ hệ thống PowerEdge Loại SMI
==========================================
      300HC_SMITYPE_TYPE1
     1300 HC_SMITYPE_TYPE1
     1400 HC_SMITYPE_TYPE2
      500SC HC_SMITYPE_TYPE2
     1500SC HC_SMITYPE_TYPE2
     1550 HC_SMITYPE_TYPE2
      600SC HC_SMITYPE_TYPE2
     1600SC HC_SMITYPE_TYPE2
      650 HC_SMITYPE_TYPE2
     1655MC HC_SMITYPE_TYPE2
      700 HC_SMITYPE_TYPE3
      750 HC_SMITYPE_TYPE3
==========================================
