.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/crps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân crps
==================

Chip được hỗ trợ:

* Intel CRPS185

Tiền tố: 'crps185'

Địa chỉ được quét: -

Bảng dữ liệu: Chỉ có sẵn dưới NDA.

tác giả:
    Ninad Palsule <ninad@linux.ibm.com>


Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ cho nguồn điện dự phòng chung của Intel với
Hỗ trợ PMBus.

Trình điều khiển là trình điều khiển máy khách cho trình điều khiển PMBus cốt lõi.
Vui lòng xem Tài liệu/hwmon/pmbus.rst để biết chi tiết về trình điều khiển máy khách PMBus.


Ghi chú sử dụng
-----------

Trình điều khiển này không tự động phát hiện thiết bị. Bạn sẽ phải khởi tạo
thiết bị một cách rõ ràng. Vui lòng xem Documentation/i2c/instantiating-devices.rst để biết
chi tiết.


Mục nhập hệ thống
-------------

===================================================================================
curr1_label "iin"
curr1_input Đo dòng điện đầu vào
curr1_max Dòng điện đầu vào tối đa
curr1_max_alarm Nhập cảnh báo mức cao hiện tại tối đa
curr1_crit Dòng đầu vào cao tới hạn
curr1_crit_alarm Nhập cảnh báo dòng tới hạn ở mức cao
curr1_rated_max Dòng đầu vào định mức tối đa

curr2_label "iout1"
curr2_input Đo dòng điện đầu ra
curr2_max Dòng điện đầu ra tối đa
curr2_max_alarm Đầu ra báo động cao hiện tại tối đa
curr2_crit Dòng điện đầu ra cao tới hạn
curr2_crit_alarm Đầu ra cảnh báo dòng tới hạn ở mức cao
curr2_rated_max Dòng điện đầu ra định mức tối đa

in1_label "vin"
in1_input Đo điện áp đầu vào
in1_crit Đầu vào quá điện áp quan trọng
in1_crit_alarm Cảnh báo quá điện áp đầu vào quan trọng
in1_max Quá áp đầu vào tối đa
in1_max_alarm Cảnh báo quá điện áp đầu vào tối đa
in1_rated_min Điện áp đầu vào định mức tối thiểu
in1_rated_max Điện áp đầu vào định mức tối đa

in2_label "vout1"
in2_input Đo điện áp đầu vào
in2_crit Đầu vào quá điện áp quan trọng
in2_crit_alarm Cảnh báo quá điện áp đầu vào quan trọng
in2_lcrit Lỗi đầu vào quan trọng do điện áp
in2_lcrit_alarm Báo động lỗi điện áp đầu vào quan trọng
in2_max Quá áp đầu vào tối đa
in2_max_alarm Cảnh báo quá điện áp đầu vào tối đa
in2_min Đầu vào tối thiểu dưới cảnh báo điện áp
in2_min_alarm Cảnh báo đầu vào tối thiểu dưới điện áp
in2_rated_min Điện áp đầu vào định mức tối thiểu
in2_rated_max Điện áp đầu vào định mức tối đa

power1_label "pin"
power1_input Công suất đầu vào đo được
power1_alarm Báo động nguồn điện đầu vào cao
power1_max Công suất đầu vào tối đa
power1_rated_max Công suất đầu vào định mức tối đa

temp[1-2]_input Nhiệt độ đo được
temp[1-2]_crit Nhiệt độ tới hạn
temp[1-2]_crit_alarm Cảnh báo nhiệt độ tới hạn
temp[1-2]_max Nhiệt độ tối đa
temp[1-2]_max_alarm Báo động nhiệt độ tối đa
temp[1-2]_rated_max Nhiệt độ định mức tối đa

fan1_alarm Cảnh báo quạt 1.
fan1_fault Lỗi quạt 1.
fan1_input Tốc độ quạt 1 trong RPM.
fan1_target Mục tiêu của người hâm mộ 1.
===================================================================================