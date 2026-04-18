.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/inspur-ipsps1.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân inspur-ipsps1
=======================================

Chip được hỗ trợ:

* Bộ cấp nguồn của Hệ thống điện Inspur

Tác giả: John Wang <wangzqbj@inspur.com>

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ bộ nguồn Inspur Power System. Người lái xe này
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
curr1_input Đo dòng điện đầu vào
curr1_label "iin"
curr1_max Dòng điện tối đa
curr1_max_alarm Báo động cao hiện tại
curr2_input Dòng điện đầu ra đo được tính bằng mA.
curr2_label "iout1"
Curr2_crit Dòng tối đa tới hạn
curr2_crit_alarm Báo động nghiêm trọng hiện tại ở mức cao
curr2_max Dòng điện tối đa
curr2_max_alarm Báo động cao hiện tại

fan1_alarm Cảnh báo quạt 1.
fan1_fault Lỗi quạt 1.
fan1_input Tốc độ quạt 1 trong RPM.

in1_alarm Báo động điện áp đầu vào thấp hơn.
in1_input Đo điện áp đầu vào tính bằng mV.
in1_label "vin"
in2_input Đo điện áp đầu ra tính bằng mV.
in2_label "vout1"
in2_lcrit Điện áp đầu ra tối thiểu quan trọng
in2_lcrit_alarm Báo động điện áp đầu ra cực thấp
in2_max Điện áp đầu ra tối đa
in2_max_alarm Báo động điện áp đầu ra cao
in2_min Điện áp đầu ra tối thiểu
in2_min_alarm Báo động điện áp đầu ra thấp

power1_alarm Lỗi đầu vào hoặc cảnh báo.
power1_input Công suất đầu vào được đo bằng uW.
power1_label "pin"
power1_max Giới hạn công suất đầu vào
power2_max_alarm Báo động công suất đầu ra cao
power2_max Giới hạn công suất đầu ra
power2_input Công suất đầu ra đo được tính bằng uW.
power2_label "bĩu môi"

temp[1-3]_input Nhiệt độ đo được
temp[1-2]_max Nhiệt độ tối đa
temp[1-3]_max_alarm Báo động nhiệt độ cao

nhà cung cấp Tên nhà sản xuất
mô hình mô hình sản phẩm
part_number Mã sản phẩm
serial_number Số sê-ri sản phẩm
fw_version Phiên bản phần mềm
hw_version Phiên bản phần cứng
chế độ Chế độ làm việc. Có thể được đặt thành hoạt động hoặc
			chế độ chờ, khi được đặt ở chế độ chờ, PSU sẽ
			tự động chuyển đổi giữa chế độ chờ
			và chế độ dự phòng.
===================================================================================
