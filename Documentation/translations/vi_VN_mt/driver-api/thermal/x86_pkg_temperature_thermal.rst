.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/thermal/x86_pkg_temperature_thermal.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Trình điều khiển hạt nhân: x86_pkg_temp_thermal
===================================

Chip được hỗ trợ:

* x86: với quản lý nhiệt ở cấp độ gói

(Xác minh bằng cách sử dụng: CPUID.06H:EAX[bit 6] =1)

Tác giả: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>

Thẩm quyền giải quyết
---------

Hướng dẫn dành cho nhà phát triển phần mềm kiến trúc Intel® 64 và IA-32 (tháng 1 năm 2013):
Chương 14.6: PACKAGE LEVEL THERMAL MANAGEMENT

Sự miêu tả
-----------

Trình điều khiển này đăng ký cảm biến mức gói nhiệt độ kỹ thuật số CPU dưới dạng nhiệt
vùng có tối đa hai điểm ngắt có thể cấu hình ở chế độ người dùng. Số điểm chuyến đi
tùy thuộc vào khả năng của gói. Một khi điểm chuyến đi bị vi phạm,
chế độ người dùng có thể nhận thông báo qua cơ chế thông báo nhiệt và có thể
thực hiện bất kỳ hành động nào để kiểm soát nhiệt độ.


Quản lý ngưỡng
--------------------
Mỗi gói sẽ đăng ký dưới dạng vùng nhiệt trong /sys/class/thermal.

Ví dụ::

/sys/class/nhiệt/thermal_zone1

Điều này có hai điểm chuyến đi:

- trip_point_0_temp
- trip_point_1_temp

Người dùng có thể đặt bất kỳ nhiệt độ nào trong khoảng từ 0 đến nhiệt độ TJ-Max. Đơn vị nhiệt độ
được tính bằng mili độ C. Tham khảo "Tài liệu/driver-api/thermal/sysfs-api.rst" để biết
chi tiết hệ thống nhiệt.

Bất kỳ giá trị nào khác 0 trong các điểm ngắt này đều có thể kích hoạt thông báo nhiệt.
Đang đặt 0, dừng gửi thông báo nhiệt.

Thông báo nhiệt:
Để nhận thông báo kobject-uevent, hãy đặt vùng nhiệt
chính sách thành "user_space".

Ví dụ::

echo -n "user_space"> chính sách
