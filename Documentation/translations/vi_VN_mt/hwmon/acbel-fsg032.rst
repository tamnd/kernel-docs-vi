.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/acbel-fsg032.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân acbel-fsg032
======================================

Chip được hỗ trợ:

* Bộ nguồn ACBEL FSG032-00xG.

Tác giả: Lakshmi Yadlapati <lakshmiy@us.ibm.com>

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ Bộ nguồn ACBEL FSG032-00xG. Người lái xe này
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
Curr1_crit Dòng tối đa tới hạn.
curr1_crit_alarm Nhập cảnh báo quan trọng hiện tại.
curr1_input Đo dòng điện đầu ra.
curr1_label "iin"
curr1_max Dòng điện đầu vào tối đa.
curr1_max_alarm Báo động cao hiện tại đầu vào tối đa.
curr1_rated_max Dòng điện đầu vào định mức tối đa.
Curr2_crit Dòng tối đa tới hạn.
curr2_crit_alarm Xuất cảnh báo quan trọng hiện tại.
curr2_input Đo dòng điện đầu ra.
curr2_label "iout1"
curr2_max Dòng điện đầu ra tối đa.
curr2_max_alarm Xuất cảnh báo hiện tại ở mức cao.
curr2_rated_max Dòng điện đầu ra định mức tối đa.


fan1_alarm Cảnh báo quạt 1.
fan1_fault Lỗi quạt 1.
fan1_input Tốc độ quạt 1 trong RPM.
fan1_target Đặt tham chiếu tốc độ quạt.

in1_alarm Báo động điện áp đầu vào thấp hơn.
in1_input Đo điện áp đầu vào.
in1_label "vin"
in1_rated_max Điện áp đầu vào định mức tối đa.
in1_rated_min Điện áp đầu vào định mức tối thiểu.
in2_crit Điện áp đầu ra tối đa tới hạn.
in2_crit_alarm Báo động điện áp đầu ra tới hạn cao.
in2_input Đo điện áp đầu ra.
in2_label "vout1"
in2_lcrit Điện áp đầu ra tối thiểu tới hạn.
in2_lcrit_alarm Báo động điện áp đầu ra cực thấp.
in2_rated_max Điện áp đầu ra định mức tối đa.
in2_rated_min Điện áp đầu ra định mức tối thiểu.

power1_alarm Lỗi đầu vào hoặc cảnh báo.
power1_input Đo công suất đầu vào.
power1_label "pin"
power1_max Giới hạn công suất đầu vào.
power1_rated_max Công suất đầu vào định mức tối đa.
power2_crit Giới hạn công suất đầu ra quan trọng.
power2_crit_alarm Đã vượt quá giới hạn cảnh báo crit công suất đầu ra.
power2_input Đo công suất đầu ra.
power2_label "bĩu môi"
power2_max Giới hạn công suất đầu ra.
power2_max_alarm Báo động công suất đầu ra cao.
power2_rated_max Công suất đầu ra định mức tối đa.

temp[1-3]_input Đo nhiệt độ.
temp[1-2]_max Nhiệt độ tối đa.
temp[1-3]_rated_max Cảnh báo nhiệt độ cao.
===================================================================================
