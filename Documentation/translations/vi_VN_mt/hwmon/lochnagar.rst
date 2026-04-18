.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/lochnagar.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân Lochnagar
===================================

Các hệ thống được hỗ trợ:
  * Logic Xiếc: Lochnagar 2

Tác giả: Lucas A. Tanure Alves

Sự miêu tả
-----------

Lochnagar 2 có mạch Giám sát Hiện tại tích hợp cho phép
đo cả điện áp và dòng điện trên tối đa tám điện áp cung cấp
đường ray được cung cấp cho các thẻ nhỏ. Màn hình hiện tại không yêu cầu bất kỳ
sửa đổi phần cứng hoặc mạch bên ngoài để hoạt động.

Các phép đo dòng điện và điện áp thu được thông qua thanh ghi tiêu chuẩn
giao diện bản đồ tới bộ điều khiển bảng Lochnagar và do đó có thể được giám sát
bằng phần mềm.

Thuộc tính Sysfs
----------------

====================================================================================
temp1_input Nhiệt độ bảng Lochnagar (milliCelsius)
in0_input Điện áp đo được cho DBVDD1 (milliVolt)
in0_label "DBVDD1"
curr1_input Dòng điện đo được cho DBVDD1 (milliAmps)
curr1_label "DBVDD1"
power1_average Công suất trung bình đo được cho DBVDD1 (microWatts)
power1_average_interval Đầu vào thời gian trung bình công suất hợp lệ từ 1 đến 1708mS
power1_label "DBVDD1"
in1_input Đo điện áp cho 1V8 DSP (milliVolt)
in1_label "1V8 DSP"
curr2_input Dòng điện đo được cho 1V8 DSP (milliAmps)
curr2_label "1V8 DSP"
power2_average Công suất trung bình đo được cho 1V8 DSP (microWatt)
power2_average_interval Đầu vào thời gian trung bình công suất hợp lệ từ 1 đến 1708mS
power2_label "1V8 DSP"
in2_input Đo điện áp cho 1V8 CDC (milliVolt)
in2_label "1V8 CDC"
curr3_input Dòng điện đo được cho 1V8 CDC (milliAmps)
curr3_label "1V8 CDC"
power3_average Công suất trung bình đo được cho 1V8 CDC (microWatt)
power3_average_interval Đầu vào thời gian trung bình công suất hợp lệ từ 1 đến 1708mS
power3_label "1V8 CDC"
in3_input Điện áp đo được cho VDDCORE DSP (milliVolt)
in3_label "VDDCORE DSP"
curr4_input Dòng điện đo được cho VDDCORE DSP (milliAmps)
curr4_label "VDDCORE DSP"
power4_average Công suất trung bình đo được cho VDDCORE DSP (microWatt)
power4_average_interval Đầu vào thời gian trung bình công suất hợp lệ từ 1 đến 1708mS
power4_label "VDDCORE DSP"
in4_input Đo điện áp cho AVDD 1V8 (milliVolt)
in4_label "AVDD 1V8"
curr5_input Dòng điện đo được cho AVDD 1V8 (milliAmps)
curr5_label "AVDD 1V8"
power5_average Công suất trung bình đo được cho AVDD 1V8 (microWatt)
power5_average_interval Đầu vào thời gian trung bình công suất hợp lệ từ 1 đến 1708mS
power5_label "AVDD 1V8"
curr6_input Dòng điện đo được cho SYSVDD (milliAmps)
curr6_label "SYSVDD"
power6_average Công suất trung bình đo được cho SYSVDD (microWatts)
power6_average_interval Đầu vào thời gian trung bình công suất hợp lệ từ 1 đến 1708mS
power6_label "SYSVDD"
in6_input Điện áp đo được cho VDDCORE CDC (milliVolt)
in6_label "VDDCORE CDC"
curr7_input Dòng điện đo được cho VDDCORE CDC (milliAmps)
curr7_label "VDDCORE CDC"
power7_average Công suất trung bình đo được cho VDDCORE CDC (microWatt)
power7_average_interval Đầu vào thời gian trung bình công suất hợp lệ từ 1 đến 1708mS
power7_label "VDDCORE CDC"
in7_input Điện áp đo được cho MICVDD (milliVolt)
in7_label "MICVDD"
curr8_input Dòng điện đo được cho MICVDD (milliAmps)
curr8_label "MICVDD"
power8_average Công suất trung bình đo được cho MICVDD (microWatts)
power8_average_interval Đầu vào thời gian trung bình công suất hợp lệ từ 1 đến 1708mS
power8_label "MICVDD"
====================================================================================

Lưu ý:
    Không thể đo điện áp trên đường ray SYSVDD.
