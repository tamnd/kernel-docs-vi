.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/chipidea.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Trình điều khiển vai trò kép tốc độ cao ChipIdea
==================================================

1. Cách kiểm tra OTG FSM(HNP và SRP)
------------------------------------

Để hiển thị cách demo các chức năng OTG HNP và SRP thông qua các tệp đầu vào sys
với 2 bảng SD Freescale i.MX6Q saber.

1.1 Cách kích hoạt OTG FSM
--------------------------

1.1.1 Chọn CONFIG_USB_OTG_FSM trong menuconfig, build lại kernel
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hình ảnh và mô-đun. Nếu bạn muốn kiểm tra một số nội bộ
biến cho otg fsm, mount debugfs, có 2 file
có thể hiển thị các biến otg fsm và một số giá trị thanh ghi bộ điều khiển ::

mèo /sys/kernel/debug/ci_hdrc.0/otg
	mèo /sys/kernel/debug/ci_hdrc.0/register

1.1.2 Thêm các mục bên dưới vào tệp dts cho nút điều khiển của bạn
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

otg-rev = <0x0200>;
	vô hiệu hóa quảng cáo;

1.2 Hoạt động thử nghiệm
------------------------

1) Cấp nguồn cho 2 bảng SD saber Freescale i.MX6Q đã được tải trình điều khiển lớp tiện ích
   (ví dụ: g_mass_storage).

2) Kết nối 2 bo mạch bằng cáp usb: một đầu là phích cắm micro A, đầu còn lại
   là phích cắm micro B.

Thiết bị A (đã cắm phích cắm micro A) sẽ liệt kê thiết bị B.

3) Chuyển đổi vai trò

Trên thiết bị B::

echo 1 > /sys/bus/platform/devices/ci_hdrc.0/inputs/b_bus_req

Thiết bị B sẽ đóng vai trò máy chủ và liệt kê thiết bị A.

4) Thiết bị A chuyển về máy chủ.

Trên thiết bị B::

echo 0 > /sys/bus/platform/devices/ci_hdrc.0/inputs/b_bus_req

hoặc bằng cách giới thiệu tính năng bỏ phiếu HNP, B-Host có thể biết khi nào thiết bị ngoại vi A muốn
   giữ vai trò chủ nhà, vì vậy việc chuyển đổi vai trò này cũng có thể được kích hoạt trong
   Bên A-ngoại vi bằng cách trả lời thăm dò từ B-Host. Điều này có thể được thực hiện trên
   Thiết bị A::

echo 1 > /sys/bus/platform/devices/ci_hdrc.0/inputs/a_bus_req

Thiết bị A sẽ chuyển về máy chủ và liệt kê thiết bị B.

5) Tháo thiết bị B (rút phích cắm micro B) và cắm lại sau 10 giây;
   Thiết bị A sẽ liệt kê lại thiết bị B.

6) Tháo thiết bị B (rút phích cắm micro B) và cắm lại sau 10 giây;
   Thiết bị A nên NOT liệt kê thiết bị B.

nếu thiết bị A muốn sử dụng bus:

Trên thiết bị A::

echo 0 > /sys/bus/platform/devices/ci_hdrc.0/inputs/a_bus_drop
	echo 1 > /sys/bus/platform/devices/ci_hdrc.0/inputs/a_bus_req

nếu thiết bị B muốn sử dụng xe buýt:

Trên thiết bị B::

echo 1 > /sys/bus/platform/devices/ci_hdrc.0/inputs/b_bus_req

7) Thiết bị A tắt nguồn trên xe buýt.

Trên thiết bị A::

echo 1 > /sys/bus/platform/devices/ci_hdrc.0/inputs/a_bus_drop

Thiết bị A nên ngắt kết nối với thiết bị B và tắt nguồn xe buýt.

8) Thiết bị B thực hiện xung dữ liệu cho SRP.

Trên thiết bị B::

echo 1 > /sys/bus/platform/devices/ci_hdrc.0/inputs/b_bus_req

Thiết bị A sẽ tiếp tục bus usb và liệt kê thiết bị B.

1.3 Tài liệu tham khảo
----------------------
"Bổ sung máy chủ nhúng và di động cho thông số kỹ thuật USB phiên bản 2.0
Ngày 27 tháng 7 năm 2012 Phiên bản 2.0 phiên bản 1.1a"

2. Cách bật USB làm nguồn đánh thức hệ thống
--------------------------------------------
Dưới đây là ví dụ về cách bật USB làm nguồn đánh thức hệ thống
trên nền tảng imx6.

2.1 Kích hoạt tính năng đánh thức của lõi::

bật tiếng vang> /sys/bus/platform/devices/ci_hdrc.0/power/wakeup

2.2 Kích hoạt tính năng đánh thức lớp keo::

bật tiếng vang> /sys/bus/platform/devices/2184000.usb/power/wakeup

2.3 Kích hoạt tính năng đánh thức PHY (tùy chọn)::

đã bật tiếng vang> /sys/bus/platform/devices/20c9000.usbphy/power/wakeup

2.4 Kích hoạt tính năng đánh thức của roothub::

đã bật tiếng vang> /sys/bus/usb/devices/usb1/power/wakeup

2.5 Kích hoạt tính năng đánh thức thiết bị liên quan::

đã bật tiếng vang> /sys/bus/usb/devices/1-1/power/wakeup

Nếu hệ thống chỉ có một cổng usb và bạn muốn đánh thức usb ở cổng này, bạn
có thể sử dụng tập lệnh bên dưới để kích hoạt tính năng đánh thức usb ::

for i in $(find /sys -name Wakeup | grep usb);do echoenabled > $i;done;
