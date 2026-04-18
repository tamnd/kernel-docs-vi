.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/lineage-pem.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Dòng trình điều khiển hạt nhân-pem
==================================

Các thiết bị được hỗ trợ:

* Mô-đun nhập nguồn dòng điện nhỏ gọn của Lineage

Tiền tố: 'dòng-pem'

Địa chỉ được quét: -

Tài liệu:

ZZ0000ZZ

Tác giả: Guenter Roeck <linux@roeck-us.net>


Sự miêu tả
-----------

Trình điều khiển này hỗ trợ nhiều dòng điện Lineage Compact DC/DC và AC/DC
các bộ chuyển đổi như CP1800, CP2000AC, CP2000DC, CP2100DC và các bộ chuyển đổi khác.

Các mô-đun nhập nguồn Lineage CPL trên danh nghĩa tuân thủ PMBus. Tuy nhiên, hầu hết
các lệnh PMBus tiêu chuẩn không được hỗ trợ. Cụ thể, tất cả việc giám sát phần cứng
và các lệnh báo cáo trạng thái là không chuẩn. Vì lý do này, một tiêu chuẩn
Không thể sử dụng trình điều khiển PMBus.


Ghi chú sử dụng
---------------

Trình điều khiển này không thăm dò các thiết bị Lineage CPL vì không có đăng ký
có thể được sử dụng một cách an toàn để nhận dạng chip. Bạn sẽ phải khởi tạo
các thiết bị một cách rõ ràng.

Ví dụ: phần sau sẽ tải trình điều khiển cho Lineage PEM tại địa chỉ 0x40
trên xe buýt I2C #1::

$ modprobe dòng dõi-pem
	$ echo lineage-pem 0x40 > /sys/bus/i2c/devices/i2c-1/new_device

Tất cả các mô-đun đầu vào nguồn Lineage CPL đều có bộ chọn chính bus I2C tích hợp
(PCA9541). Để đảm bảo quyền truy cập thiết bị, chỉ nên sử dụng trình điều khiển này làm ứng dụng khách
trình điều khiển sang trình điều khiển bộ chọn chính pca9541 I2C.


Mục nhập hệ thống
-----------------

Tất cả các thiết bị Lineage CPL đều báo cáo điện áp đầu ra và nhiệt độ thiết bị cũng như
báo động về điện áp đầu ra, nhiệt độ, điện áp đầu vào, dòng điện đầu vào, nguồn điện đầu vào,
và trạng thái của người hâm mộ.

Điện áp đầu vào, dòng điện đầu vào, công suất đầu vào và đo tốc độ quạt chỉ được cung cấp
được hỗ trợ trên các thiết bị mới hơn. Trình điều khiển sẽ phát hiện xem các thuộc tính đó có được hỗ trợ hay không,
và chỉ tạo các mục sysfs tương ứng nếu có.

==========================================================
in1_input Điện áp đầu ra (mV)
in1_min_alarm Cảnh báo điện áp đầu ra thấp
in1_max_alarm Báo động quá áp đầu ra
in1_crit Cảnh báo quan trọng về điện áp đầu ra

in2_input Điện áp đầu vào (mV, tùy chọn)
in2_alarm Báo động điện áp đầu vào

curr1_input Dòng điện đầu vào (mA, tùy chọn)
curr1_alarm Đầu vào cảnh báo quá dòng

power1_input Nguồn điện đầu vào (uW, tùy chọn)
power1_alarm Báo động nguồn đầu vào

fan1_input Tốc độ quạt 1 (vòng/phút, tùy chọn)
fan2_input Tốc độ quạt 2 (rpm, tùy chọn)
fan3_input Tốc độ quạt 3 (rpm, tùy chọn)

temp1_input
temp1_max
temp1_crit
temp1_alarm
temp1_crit_alarm
temp1_fault
==========================================================
