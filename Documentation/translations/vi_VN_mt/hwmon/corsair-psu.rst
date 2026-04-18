.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/corsair-psu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân corsair-psu
=========================

Các thiết bị được hỗ trợ:

* Bộ nguồn Corsair

Corsair HX550i

Corsair HX650i

Corsair HX750i

Corsair HX850i

Corsair HX1000i (Di sản và Series 2023)

Corsair HX1200i (Di sản, Dòng 2023 và Dòng 2025)

Corsair HX1500i (Di sản và Series 2023)

Corsair RM550i

Corsair RM650i

Corsair RM750i

Corsair RM850i

Corsair RM1000i

Tác giả: Wilken Gottwalt

Sự miêu tả
-----------

Trình điều khiển này triển khai giao diện sysfs cho PSU Corsair với giao thức HID
giao diện của dòng HXi và RMi.
Những bộ nguồn này cung cấp khả năng truy cập vào bộ điều khiển vi mô có 2 bộ nguồn kèm theo
cảm biến nhiệt độ, 1 cảm biến vòng tua quạt, 4 cảm biến đo mức điện áp, 4 cảm biến đo mức điện áp
mức sử dụng năng lượng và 4 cảm biến cho mức hiện tại và thông tin bổ sung không có cảm biến
như thời gian hoạt động.

Mục nhập hệ thống
-------------

=====================================================================================
curr1_input Tổng mức sử dụng hiện tại
curr2_input Dòng điện trên đường ray psu 12v
curr2_crit Giá trị tới hạn tối đa hiện tại trên đường ray psu 12v
curr3_input Dòng điện trên đường ray psu 5v
curr3_crit Giá trị tới hạn tối đa hiện tại trên đường ray psu 5v
curr4_input Dòng điện trên đường ray psu 3,3v
curr4_crit Giá trị tới hạn tối đa hiện tại trên đường ray psu 3,3v
fan1_input RPM của quạt psu
in0_input Điện áp của đầu vào psu ac
in1_input Điện áp của đường ray psu 12v
in1_crit Giá trị tới hạn tối đa của điện áp trên đường ray psu 12v
in1_lcrit Giá trị tới hạn điện áp tối thiểu trên đường ray psu 12v
in2_input Điện áp của đường ray psu 5v
in2_crit Giá trị tới hạn tối đa của điện áp trên đường ray psu 5v
in2_lcrit Giá trị tới hạn điện áp tối thiểu trên đường ray psu 5v
in3_input Điện áp của đường ray psu 3,3v
in3_crit Giá trị tới hạn tối đa của điện áp trên đường ray psu 3,3v
in3_lcrit Giá trị tới hạn điện áp tối thiểu trên đường ray psu 3,3v
power1_input Tổng mức sử dụng năng lượng
power2_input Mức sử dụng năng lượng của đường ray psu 12v
power3_input Mức sử dụng năng lượng của đường ray psu 5v
power4_input Mức sử dụng năng lượng của đường ray psu 3,3v
Giá trị pwm1 PWM, chỉ đọc
pwm1_enable chế độ PWM, chỉ đọc
temp1_input Nhiệt độ của thành phần psu vrm
temp1_crit Giá trị nhiệt độ tối đa của thành phần psu vrm
temp2_input Nhiệt độ của vỏ psu
temp2_crit Giá trị tới hạn tối đa của nhiệt độ của trường hợp psu
=====================================================================================

Ghi chú sử dụng
-----------

Nó là thiết bị USB HID nên được tự động phát hiện, hỗ trợ trao đổi nóng và
một số thiết bị cùng một lúc.

Các giá trị nhấp nháy ở cấp điện áp đường ray có thể là dấu hiệu cho thấy sự cố
PSU. Theo kế hoạch tốc độ quạt tự động mặc định, quạt bắt đầu vào khoảng
30% định mức công suất. Nếu điều này không xảy ra thì có thể quạt đã bị hỏng. các
trình điều khiển cũng cung cấp một số giá trị hữu ích bổ sung thông qua debugfs, không phù hợp
vào lớp hwmon.

Mục gỡ lỗi
---------------

=====================================================================================
ocpmode Chế độ đơn hoặc đa đường ray của đầu nối nguồn PCIe
sản phẩm Tên sản phẩm của psu
thời gian hoạt động phiên thời gian hoạt động của psu
uptime_total Tổng thời gian hoạt động của psu
nhà cung cấp Tên nhà cung cấp của psu
=====================================================================================