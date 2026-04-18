.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/peci-cputemp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân peci-cputemp
======================================

Chip được hỗ trợ:
	Một trong các CPU máy chủ Intel được liệt kê bên dưới được kết nối với bus PECI.
		* Bộ xử lý máy chủ Intel Xeon E5/E7 v3
			Dòng Intel Xeon E5-14xx v3
			Dòng Intel Xeon E5-24xx v3
			Dòng Intel Xeon E5-16xx v3
			Dòng Intel Xeon E5-26xx v3
			Dòng Intel Xeon E5-46xx v3
			Dòng Intel Xeon E7-48xx v3
			Dòng Intel Xeon E7-88xx v3
		* Bộ xử lý máy chủ Intel Xeon E5/E7 v4
			Dòng Intel Xeon E5-16xx v4
			Dòng Intel Xeon E5-26xx v4
			Dòng Intel Xeon E5-46xx v4
			Dòng Intel Xeon E7-48xx v4
			Dòng Intel Xeon E7-88xx v4
		* Bộ xử lý máy chủ Intel Xeon có thể mở rộng
			Dòng Intel Xeon D
			Dòng Intel Xeon Đồng
			Dòng Intel Xeon Bạc
			Gia đình Intel Xeon Gold
			Dòng Intel Xeon Platinum

Bảng dữ liệu: Có sẵn từ ZZ0000ZZ

Tác giả: Jae Hyun Yoo <jae.hyun.yoo@linux.intel.com>

Sự miêu tả
-----------

Trình điều khiển này triển khai tính năng hwmon PECI chung cung cấp kỹ thuật số
Số đọc nhiệt của Cảm biến nhiệt (DTS) của gói CPU và lõi CPU
có thể truy cập thông qua giao diện bộ xử lý PECI.

Tất cả các giá trị nhiệt độ được tính bằng mili độ C và sẽ có thể đo được
chỉ khi CPU mục tiêu được bật nguồn.

Giao diện hệ thống
-------------------

====================================================================================
temp1_label "Chết"
temp1_input Cung cấp nhiệt độ khuôn hiện tại của gói CPU.
temp1_max Cung cấp nhiệt độ kiểm soát nhiệt của gói CPU
			còn được gọi là Tcontrol.
temp1_crit Cung cấp nhiệt độ tắt máy của gói CPU
			còn được gọi là điểm nối bộ xử lý tối đa
			nhiệt độ, Tjmax hoặc Tprochot.
temp1_crit_hyst Cung cấp nhiệt độ trễ của CPU
			gói. Trả về Tcontrol, nhiệt độ tại đó
			tình trạng nguy kịch đã khỏi.

temp2_label "DTS"
temp2_input Cung cấp nhiệt độ hiện tại của gói CPU được chia tỷ lệ
			để phù hợp với cấu hình nhiệt DTS.
temp2_max Cung cấp nhiệt độ kiểm soát nhiệt của gói CPU
			còn được gọi là Tcontrol.
temp2_crit Cung cấp nhiệt độ tắt máy của gói CPU
			còn được gọi là điểm nối bộ xử lý tối đa
			nhiệt độ, Tjmax hoặc Tprochot.
temp2_crit_hyst Cung cấp nhiệt độ trễ của CPU
			gói. Trả về Tcontrol, nhiệt độ tại đó
			tình trạng nguy kịch đã khỏi.

temp3_label "Điều khiển"
temp3_input Cung cấp nhiệt độ điều khiển T hiện tại của CPU
			gói còn được gọi là mục tiêu Nhiệt độ quạt.
			Cho biết giá trị tương đối từ hành trình giám sát nhiệt
			nhiệt độ mà quạt nên hoạt động.
temp3_crit Cung cấp giá trị quan trọng Tcontrol của gói CPU
			tương tự với Tjmax.

temp4_label "Bướm ga"
temp4_input Cung cấp nhiệt độ bướm ga hiện tại của CPU
			gói. Được sử dụng để điều chỉnh nhiệt độ. Nếu giá trị này
			được cho phép và thấp hơn Tjmax - ga sẽ
			xảy ra và báo cáo ở mức thấp hơn Tjmax.

temp5_label "Tjmax"
temp5_input Cung cấp nhiệt độ tiếp giáp tối đa, Tjmax của
			Gói CPU.

temp[6-N]_label Cung cấp chuỗi "Core X", trong đó X được phân giải lõi
			số.
temp[6-N]_input Cung cấp nhiệt độ hiện tại của từng lõi.

====================================================================================