.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/lpit.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Bàn nhàn rỗi công suất thấp (LPIT)
==================================

Để liệt kê các trạng thái Không sử dụng năng lượng thấp của nền tảng, các nền tảng Intel đang sử dụng
“Bàn nhàn rỗi công suất thấp” (LPIT). Thông tin chi tiết về bảng này có thể được
được tải xuống từ:
ZZ0000ZZ

Có thể đọc thông tin cư trú cho từng trạng thái năng lượng thấp qua FFH
(Chức năng phần cứng cố định) hoặc giao diện ánh xạ bộ nhớ.

Trên các nền tảng hỗ trợ trạng thái ngủ S0ix, có thể có hai loại
nơi cư trú:

- CPU PKG C10 (Đọc qua giao diện FFH)
  - Platform Controller Hub (PCH) SLP_S0 (Đọc qua giao diện ánh xạ bộ nhớ)

Các thuộc tính sau đây được thêm động vào cpuidle
nhóm thuộc tính sysfs::

/sys/devices/system/cpu/cpuidle/low_power_idle_cpu_residency_us
  /sys/devices/system/cpu/cpuidle/low_power_idle_system_residency_us

Thuộc tính "low_power_idle_cpu_residency_us" hiển thị thời gian sử dụng
bởi gói CPU trong PKG C10

Thuộc tính "low_power_idle_system_residency_us" hiển thị SLP_S0
khẳng định nơi cư trú hoặc thời gian hệ thống dành cho SLP_S0# signal.
Đây là trạng thái năng lượng hệ thống thấp nhất có thể, chỉ đạt được khi CPU ở trạng thái
PKG C10 và tất cả các khối chức năng trong PCH đều ở trạng thái năng lượng thấp.