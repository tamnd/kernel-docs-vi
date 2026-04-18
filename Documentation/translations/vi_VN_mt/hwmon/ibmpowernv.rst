.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/ibmpowernv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân IBMPOWERNV
========================

Các hệ thống được hỗ trợ:

* Bất kỳ máy chủ IBM P nào gần đây dựa trên nền tảng POWERNV

Tác giả: Neelesh Gupta

Sự miêu tả
-----------

Trình điều khiển này thực hiện việc đọc dữ liệu cảm biến nền tảng như nhiệt độ/quạt/
điện áp/nguồn cho nền tảng 'POWERNV'.

Trình điều khiển sử dụng cơ sở hạ tầng thiết bị nền tảng. Nó thăm dò cây thiết bị
cho các thiết bị cảm biến trong giai đoạn __init và đăng ký chúng với 'hwmon'.
'hwmon' điền vào cây 'sysfs' có các tệp thuộc tính, mỗi tệp cho một
loại cảm biến và dữ liệu thuộc tính của nó.

Tất cả các nút trong DT xuất hiện dưới "/ibm,opal/sensors" và mỗi nút hợp lệ trong
DT ánh xạ tới tệp thuộc tính trong 'sysfs'. Nút xuất 'id cảm biến' duy nhất
mà trình điều khiển sử dụng để thực hiện lệnh gọi OPAL tới phần sụn.

ghi chú sử dụng
-----------
Trình điều khiển được xây dựng tĩnh với kernel bằng cách kích hoạt cấu hình
CONFIG_SENSORS_IBMPOWERNV. Nó cũng có thể được xây dựng dưới dạng mô-đun 'ibmpowernv'.

Thuộc tính Sysfs
----------------

====================================================================================
fanX_input Giá trị RPM được đo.
fanX_min Ngưỡng RPM để tạo cảnh báo.
fanX_fault - 0: Không có tình trạng lỗi
			- 1: Quạt hỏng

tempX_input Đã đo nhiệt độ môi trường.
tempX_max Ngưỡng nhiệt độ môi trường xung quanh để tạo cảnh báo.
tempX_highest Nhiệt độ tối đa lịch sử
tempX_lowest Nhiệt độ tối thiểu lịch sử
tempX_enable Bật/tắt tất cả các cảm biến nhiệt độ thuộc về
			tiểu nhóm. Trong POWER9, thuộc tính này tương ứng với
			mỗi chiếc OCC. Sử dụng thuộc tính này mỗi OCC có thể được yêu cầu
			vô hiệu hóa/kích hoạt tất cả các cảm biến nhiệt độ của nó.

- 1: Kích hoạt
			- 0: Tắt

inX_input Đo điện áp nguồn (millivolt)
inX_fault - 0: Không có tình trạng lỗi.
			- 1: Lỗi nguồn điện.
inX_highest Điện áp tối đa lịch sử
inX_lowest Điện áp tối thiểu lịch sử
inX_enable Bật/tắt tất cả các cảm biến điện áp thuộc về
			tiểu nhóm. Trong POWER9, thuộc tính này tương ứng với
			mỗi chiếc OCC. Sử dụng thuộc tính này mỗi OCC có thể được yêu cầu
			vô hiệu hóa/kích hoạt tất cả các cảm biến điện áp của nó.

- 1: Kích hoạt
			- 0: Tắt

powerX_input Công suất tiêu thụ (microWatt)
powerX_input_highest Công suất tối đa lịch sử
powerX_input_lowest Công suất tối thiểu lịch sử
powerX_enable Bật/tắt tất cả các cảm biến nguồn thuộc về
			tiểu nhóm. Trong POWER9, thuộc tính này tương ứng với
			mỗi chiếc OCC. Sử dụng thuộc tính này mỗi OCC có thể được yêu cầu
			vô hiệu hóa/kích hoạt tất cả các cảm biến năng lượng của nó.

- 1: Kích hoạt
			- 0: Tắt

currX_input Dòng điện đo được (milliampere)
currX_highest Dòng điện tối đa lịch sử
currX_lowest Dòng điện tối thiểu lịch sử
currX_enable Bật/tắt tất cả các cảm biến hiện tại thuộc về
			tiểu nhóm. Trong POWER9, thuộc tính này tương ứng với
			mỗi chiếc OCC. Sử dụng thuộc tính này mỗi OCC có thể được yêu cầu
			vô hiệu hóa/kích hoạt tất cả các cảm biến hiện tại của nó.

- 1: Kích hoạt
			- 0: Tắt

energyX_input Năng lượng tích lũy (microJoule)
====================================================================================
