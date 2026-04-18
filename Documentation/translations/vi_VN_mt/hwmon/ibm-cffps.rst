.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/ibm-cffps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân ibm-cffps
===================================

Chip được hỗ trợ:

* Bộ nguồn IBM dạng phổ biến

Tác giả: Eddie James <eajames@us.ibm.com>

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ bộ nguồn IBM Common Form Factor (CFF). Người lái xe này
là một ứng dụng khách của trình điều khiển PMBus cốt lõi.

Ghi chú sử dụng
---------------

Trình điều khiển này không tự động phát hiện thiết bị. Bạn sẽ phải khởi tạo
thiết bị một cách rõ ràng. Vui lòng xem Documentation/i2c/instantiating-devices.rst để biết
chi tiết.

Mục nhập hệ thống
-----------------

Các thuộc tính sau được hỗ trợ:

===================================================================================
curr1_alarm Xuất cảnh báo quá dòng hiện tại.
curr1_input Dòng điện đầu ra đo được tính bằng mA.
curr1_label "iout1"

fan1_alarm Cảnh báo quạt 1.
fan1_fault Lỗi quạt 1.
fan1_input Tốc độ quạt 1 trong RPM.
fan2_alarm Cảnh báo của người hâm mộ 2.
fan2_fault Lỗi quạt 2.
fan2_input Tốc độ quạt 2 trong RPM.

in1_alarm Báo động điện áp đầu vào thấp hơn.
in1_input Đo điện áp đầu vào tính bằng mV.
in1_label "vin"
in2_alarm Báo động quá áp điện áp đầu ra.
in2_input Đo điện áp đầu ra tính bằng mV.
in2_label "vout1"

power1_alarm Lỗi đầu vào hoặc cảnh báo.
power1_input Công suất đầu vào được đo bằng uW.
power1_label "pin"

temp1_alarm PSU báo động quá nhiệt độ môi trường đầu vào.
temp1_input Đã đo nhiệt độ môi trường đầu vào PSU tính bằng mili độ C.
temp2_alarm Cảnh báo quá nhiệt độ của bộ chỉnh lưu thứ cấp.
temp2_input Đo nhiệt độ của bộ chỉnh lưu thứ cấp tính bằng mili độ C.
temp3_alarm ORing FET báo động quá nhiệt.
temp3_input Đo ORing nhiệt độ FET tính bằng mili độ C.
===================================================================================
