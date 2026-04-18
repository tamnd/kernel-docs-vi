.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/dps920ab.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân dps920ab
==================================

Chip được hỗ trợ:

* Đồng bằng DPS920AB

Tiền tố: 'dps920ab'

Địa chỉ được quét: -

tác giả:
    Robert Marko <robert.marko@sartura.hr>


Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ cho đầu ra đơn Delta DPS920AB 920W 54V DC
cung cấp điện với sự hỗ trợ PMBus.

Trình điều khiển là trình điều khiển máy khách cho trình điều khiển PMBus cốt lõi.
Vui lòng xem Tài liệu/hwmon/pmbus.rst để biết chi tiết về trình điều khiển máy khách PMBus.


Ghi chú sử dụng
---------------

Trình điều khiển này không tự động phát hiện thiết bị. Bạn sẽ phải khởi tạo
thiết bị một cách rõ ràng. Vui lòng xem Documentation/i2c/instantiating-devices.rst để biết
chi tiết.


Mục nhập hệ thống
-----------------

===================================================================================
curr1_label "iin"
curr1_input Đo dòng điện đầu vào
curr1_alarm Nhập cảnh báo hiện tại ở mức cao

curr2_label "iout1"
curr2_input Đo dòng điện đầu ra
curr2_max Dòng điện đầu ra tối đa
curr2_rated_max Dòng điện đầu ra định mức tối đa

in1_label "vin"
in1_input Đo điện áp đầu vào
in1_alarm Báo động điện áp đầu vào

in2_label "vout1"
in2_input Đo điện áp đầu ra
in2_rated_min Điện áp đầu ra định mức tối thiểu
in2_rated_max Điện áp đầu ra định mức tối đa
in2_alarm Cảnh báo điện áp đầu ra

power1_label "pin"
power1_input Công suất đầu vào đo được
power1_alarm Báo động nguồn điện đầu vào cao

power2_label "bĩu môi1"
power2_input Công suất đầu ra đo được
power2_rated_max Công suất đầu ra định mức tối đa

temp[1-3]_input Nhiệt độ đo được
temp[1-3]_alarm Báo động nhiệt độ

fan1_alarm Cảnh báo quạt 1.
fan1_fault Lỗi quạt 1.
fan1_input Tốc độ quạt 1 trong RPM.
===================================================================================