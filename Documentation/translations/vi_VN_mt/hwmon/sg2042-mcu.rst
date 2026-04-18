.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sg2042-mcu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân sg2042-mcu
========================

Chip được hỗ trợ:

* MCU trên bo mạch cho sg2042

Địa chỉ được quét: -

Tiền tố: 'sg2042-mcu'

tác giả:

- Inochi Amaoto <inochiama@outlook.com>

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ giám sát phần cứng cho MCU trên bo mạch với
giao diện i2c.

Ghi chú sử dụng
-----------

Trình điều khiển này không tự động phát hiện thiết bị. Bạn sẽ phải khởi tạo
các thiết bị một cách rõ ràng.
Vui lòng xem Documentation/i2c/instantiating-devices.rst để biết chi tiết.

Thuộc tính Sysfs
----------------

Bảng sau đây hiển thị các mục tiêu chuẩn được hỗ trợ bởi trình điều khiển:

============================================================================
Tên Mô tả
============================================================================
temp1_input Đo nhiệt độ của SoC
temp1_crit Nhiệt độ cao tới hạn
khôi phục nhiệt độ trễ temp1_crit_hyst từ Quan trọng
temp2_input Đo nhiệt độ của bo mạch chủ
============================================================================

Bảng sau đây hiển thị các mục bổ sung được hỗ trợ bởi trình điều khiển
(thiết bị MCU nằm trong hệ thống con i2c):

=========================================================================
Tên Perm Mô tả
=========================================================================
reset_count RO Đặt lại số lượng của SoC
thời gian hoạt động RO Giây sau khi MCU được cấp nguồn
reset_reason RO Lý do đặt lại cho lần đặt lại cuối cùng
repower_policy RW Chính sách thực thi khi kích hoạt repower
=========================================================================

ZZ0000ZZ
  Việc cấp lại năng lượng được kích hoạt khi nhiệt độ của SoC giảm xuống dưới
  nhiệt độ trễ sau khi kích hoạt tắt máy do
  đạt tới nhiệt độ tới hạn.
  Các giá trị hợp lệ cho mục này là "cấp lại năng lượng" và "giữ". "giữ" sẽ
  để SoC ngừng hoạt động khi kích hoạt cấp lại năng lượng và "cấp lại năng lượng" sẽ
  khởi động SoC.

Giao diện gỡ lỗi
------------------

Nếu có debugfs, trình điều khiển này sẽ hiển thị một số phần cứng cụ thể
dữ liệu trong ZZ0000ZZ.

=========================================================================
Tên Định dạng Mô tả
=========================================================================
firmware_version 0x%02x phiên bản phần sụn của MCU
pcb_version 0x%02x số phiên bản của bo mạch cơ sở
board_type 0x%02x số nhận dạng cho bảng cơ sở
mcu_type %d loại của MCU: 0 là STM32, 1 là GD32
=========================================================================