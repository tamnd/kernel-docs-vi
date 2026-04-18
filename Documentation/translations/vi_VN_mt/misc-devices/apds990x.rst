.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/apds990x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Trình điều khiển hạt nhân apds990x
======================

Chip được hỗ trợ:
Avago APDS990X

Bảng dữ liệu:
Không có sẵn miễn phí

tác giả:
Samu Onkalo <samu.p.onkalo@nokia.com>

Sự miêu tả
-----------

APDS990x là cảm biến tiệm cận và ánh sáng xung quanh kết hợp. ALS và sự gần gũi
chức năng được kết nối cao. Đường dẫn đo ALS phải đang chạy
trong khi chức năng lân cận được kích hoạt.

ALS tạo ra các giá trị đo thô cho hai kênh: Xóa kênh
(hồng ngoại + ánh sáng nhìn thấy) và chỉ IR. Tuy nhiên, việc so sánh ngưỡng xảy ra
chỉ sử dụng kênh rõ ràng. Giá trị Lux và mức ngưỡng trên CTNH
có thể thay đổi khá nhiều tùy thuộc vào quang phổ của nguồn sáng.

Trình điều khiển thực hiện các chuyển đổi cần thiết sang cả hai hướng để người dùng xử lý
chỉ có giá trị lux. Giá trị Lux được tính bằng cách sử dụng thông tin từ cả hai
các kênh. Mức ngưỡng CTNH được tính từ giá trị lux đã cho để phù hợp
với loại sét hiện tại. Đôi khi ước tính không chính xác
dẫn đến ngắt sai, nhưng điều đó không gây hại.

ALS chứa 4 bước khuếch đại khác nhau. Trình điều khiển tự động
lựa chọn bước tăng phù hợp. Sau mỗi lần đo, độ tin cậy của kết quả
được ước tính và phép đo mới sẽ được kích hoạt nếu cần thiết.

Dữ liệu nền tảng có thể cung cấp các giá trị được điều chỉnh cho các công thức chuyển đổi nếu
các giá trị đã được biết. Mặt khác, các giá trị mặc định của cảm biến đơn giản sẽ được sử dụng.

Phía gần thì đơn giản hơn một chút. Không cần chuyển đổi phức tạp.
Nó tạo ra các giá trị có thể sử dụng trực tiếp.

Trình điều khiển kiểm soát trạng thái hoạt động của chip bằng khung pm_runtime.
Bộ điều chỉnh điện áp được điều khiển dựa trên trạng thái hoạt động của chip.

SYSFS
-----


chip_id
	RO - hiển thị loại và phiên bản chip được phát hiện

trạng thái sức mạnh
	RW - bật/tắt chip. Sử dụng logic đếm

1 kích hoạt chip
	     0 vô hiệu hóa chip
lux0_input
	RO - giá trị lux đo được

sysfs_notify được gọi khi xảy ra ngắt ngưỡng

lux0_sensor_range
	RO - giá trị tối đa lux0_input.

Trên thực tế không bao giờ đạt được vì cảm biến có xu hướng
	     để bão hòa nhiều trước đó. Giá trị thực tối đa thay đổi tùy theo
	     trên quang phổ ánh sáng, v.v.

lux0_rate
	RW - tốc độ đo tính bằng Hz

lux0_rate_avail
	RO - tốc độ đo được hỗ trợ

lux0_calibscale
	RW - giá trị hiệu chuẩn.

Đặt thành giá trị trung tính theo mặc định.
	     Kết quả đầu ra được nhân với calibscale/calibscale_default
	     giá trị.

lux0_calibscale_default
	RO - giá trị hiệu chuẩn trung tính

lux0_thresh_above_value
	RW - Giá trị ngưỡng mức HI.

Tất cả các kết quả trên giá trị
	     gây ra một sự gián đoạn. 65535 (tức là cảm biến_range) vô hiệu hóa các mục trên
	     ngắt lời.

lux0_thresh_below_value
	RW - Giá trị ngưỡng mức LO.

Tất cả các kết quả dưới giá trị
	     gây ra một sự gián đoạn. 0 vô hiệu hóa ngắt bên dưới.

prox0_raw
	RO - giá trị lân cận đo được

sysfs_notify được gọi khi xảy ra ngắt ngưỡng

prox0_sensor_range
	RO - giá trị tối đa prox0_raw (1023)

prox0_raw_en
	RW - bật/tắt vùng lân cận - sử dụng logic đếm

- 1 cho phép sự gần gũi
	     - 0 vô hiệu hóa sự gần gũi

prox0_reporting_mode
	RW - kích hoạt / định kỳ.

Trong chế độ "kích hoạt", trình điều khiển sẽ cho biết hai điều có thể xảy ra
	     giá trị: giá trị 0 hoặc prox0_sensor_range. 0 có nghĩa là không có khoảng cách gần,
	     1023 có nghĩa là sự gần gũi. Điều này gây ra số lượng ngắt tối thiểu.
	     Ở chế độ "định kỳ", trình điều khiển báo cáo tất cả các giá trị trên
	     prox0_thresh_above. Điều này gây ra nhiều gián đoạn hơn, nhưng nó có thể mang lại
	     _rough_ ước tính về khoảng cách.

prox0_reporting_mode_avail
	RO - các giá trị được chấp nhận cho prox0_reporting_mode (kích hoạt, định kỳ)

prox0_thresh_above_value
	RW - mức ngưỡng kích hoạt các sự kiện lân cận.