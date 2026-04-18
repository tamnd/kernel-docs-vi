.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/peci-dimmtemp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân peci-dimmtemp
=======================================

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

Trình điều khiển này triển khai tính năng hwmon PECI chung cung cấp
Cảm biến nhiệt độ trên số đọc DIMM có thể truy cập được thông qua giao diện PECI của bộ xử lý.

Tất cả các giá trị nhiệt độ được tính bằng mili độ C và sẽ có thể đo được
chỉ khi CPU mục tiêu được bật nguồn.

Giao diện hệ thống
-------------------

====================================================================================

temp[N]_label Cung cấp chuỗi "DIMM CI", trong đó C là kênh DIMM và
			I là chỉ số DIMM của DIMM được điền.
temp[N]_input Cung cấp nhiệt độ hiện tại của DIMM được điền.
temp[N]_max Cung cấp nhiệt độ kiểm soát nhiệt của DIMM.
temp[N]_crit Cung cấp nhiệt độ tắt máy của DIMM.

====================================================================================

Lưu ý:
	Thuộc tính nhiệt độ DIMM sẽ xuất hiện khi BIOS của client CPU
	hoàn thành việc đào tạo và kiểm tra trí nhớ.