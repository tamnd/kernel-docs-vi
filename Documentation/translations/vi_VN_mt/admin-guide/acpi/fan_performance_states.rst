.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/acpi/fan_performance_states.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Trạng thái hiệu suất của quạt ACPI
==================================

Khi đối tượng _FPS tùy chọn xuất hiện trong thiết bị ACPI đại diện cho một
quạt (ví dụ: PNP0C0B hoặc INT3404), trình điều khiển quạt ACPI tạo thêm
thuộc tính "state*" trong thư mục sysfs của thiết bị ACPI được đề cập.
Các thuộc tính này liệt kê các thuộc tính của trạng thái hoạt động của quạt.

Để biết thêm thông tin về _FPS, hãy tham khảo thông số kỹ thuật của ACPI tại:

ZZ0000ZZ

Ví dụ: nội dung của thư mục sysfs của thiết bị INT3404 ACPI
có thể trông như sau::

$ ls -l /sys/bus/acpi/devices/INT3404:00/
 tổng 0
 ...
-r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái0
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái1
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái10
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái11
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 state2
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái3
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái4
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái5
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái6
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái7
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 state8
 -r--r--r-- 1 gốc gốc 4096 Ngày 13 tháng 12 20:38 trạng thái9
 -r--r--r-- 1 gốc gốc 4096 Trạng thái 13 tháng 12 01:00
 ...

trong đó mỗi tệp "trạng thái*" thể hiện một trạng thái hiệu suất của quạt
và chứa danh sách 5 số nguyên (trường) được phân tách bằng dấu hai chấm với
giải thích sau đây::

control_percent:trip_point_index:speed_rpm:noise_level_mdb:power_mw

* ZZ0000ZZ: Giá trị phần trăm được sử dụng để đặt tốc độ quạt ở mức
  mức cụ thể bằng cách sử dụng đối tượng _FSL (0-100).

* ZZ0000ZZ: Số điểm ngắt hoạt động làm mát tương ứng
  đến trạng thái hiệu suất này (0-9).

* ZZ0000ZZ: Tốc độ quay của quạt tính theo vòng/phút.

* ZZ0000ZZ: Tiếng ồn phát ra từ quạt ở trạng thái này
  milidecibel.

* ZZ0000ZZ: Công suất tiêu thụ của quạt ở trạng thái này tính bằng miliwatt.

Ví dụ::

$cat /sys/bus/acpi/devices/INT3404:00/state1
 25:0:3200:12500:1250

Khi một trường nhất định không được điền hoặc giá trị của nó không được nền tảng cung cấp
chương trình cơ sở không hợp lệ, chuỗi "không xác định" được hiển thị thay vì giá trị.

Kiểm soát hạt mịn của quạt ACPI
===============================

Khi đối tượng _FIF chỉ định hỗ trợ kiểm soát hạt mịn thì tốc độ quạt sẽ
có thể được đặt từ 0 đến 100% với "kích thước bước" tối thiểu được đề xuất thông qua
Đối tượng _FSL. Người dùng có thể điều chỉnh tốc độ quạt bằng thiết bị làm mát hệ thống nhiệt.

Ở đây, người sử dụng có thể xem trạng thái hiệu suất của quạt để biết tốc độ tham chiếu (speed_rpm)
và thiết lập nó bằng cách thay đổi cur_state của thiết bị làm mát. Nếu kiểm soát hạt mịn
được hỗ trợ thì người dùng cũng có thể điều chỉnh theo một số tốc độ khác
không được xác định trong các trạng thái hiệu suất.

Sự hỗ trợ kiểm soát hạt mịn được thể hiện thông qua thuộc tính sysfs
"fine_grain_control". Nếu có kiểm soát hạt mịn, thuộc tính này
sẽ hiển thị "1" nếu không "0".

Thuộc tính sysfs này được trình bày trong cùng thư mục với trạng thái hiệu suất.

Phản hồi về hiệu suất của quạt ACPI
===================================

Đối tượng _FST tùy chọn cung cấp thông tin trạng thái cho thiết bị quạt.
Điều này bao gồm trường để cung cấp tốc độ quạt hiện tại tính bằng số vòng quay mỗi phút
tại đó quạt đang quay.

Tốc độ này được trình bày trong sysfs bằng thuộc tính "fan_speed_rpm",
trong cùng thư mục với trạng thái hiệu suất.