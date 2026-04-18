.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/video-output.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Điều khiển bộ chuyển đổi đầu ra video
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2006 luming.yu@intel.com

Trình điều khiển lớp sysfs đầu ra cung cấp một lớp đầu ra video trừu tượng
có thể được sử dụng để kết nối các phương thức cụ thể của nền tảng để bật/tắt đầu ra video
thiết bị thông qua giao diện sysfs chung. Ví dụ: trên IBM ThinkPad T42 của tôi
máy tính xách tay, Trình điều khiển video ACPI đã đăng ký các thiết bị đầu ra và đọc/ghi
phương thức cho 'trạng thái' với lớp sysfs đầu ra. Giao diện người dùng trong sysfs là::

linux:/sys/class/video_output # tree .
  .
  |-- CRT0
  ZZ0002ZZ-- thiết bị -> ../../../devices/pci0000:00/0000:00:01.0
  ZZ0003ZZ-- trạng thái
  ZZ0004ZZ-- hệ thống con -> ../../../class/video_output
  |   ZZ0000ZZ-- sự kiện
  |-- LCD0
  ZZ0005ZZ-- thiết bị -> ../../../devices/pci0000:00/0000:00:01.0
  ZZ0006ZZ-- trạng thái
  ZZ0007ZZ-- hệ thống con -> ../../../class/video_output
  |   ZZ0001ZZ-- TV0
     |-- thiết bị -> ../../../devices/pci0000:00/0000:00:01.0
     |-- tiểu bang
     |-- hệ thống con -> ../../../class/video_output
     `-- sự kiện

